## Locale-Aware Validation

### What Is Locale-Aware Validation?

Locale-aware validation is the practice of adapting input validation rules and error messages to the user's locale. This goes beyond simply translating error strings — it means recognizing that what constitutes a *valid* value can differ by locale. A valid phone number, postal code, date format, or number representation varies by country and region.

**Key Points:**

- Zod validates structure and constraints. It has no built-in locale awareness.
- Locale-awareness is layered on top of Zod through custom refinements, preprocessors, and message overrides.
- Two distinct concerns must be separated: locale-specific *format validation* (is this input valid for this locale?) and locale-specific *error messages* (what does the failure say?).
- Both concerns require `ctx.locale` to be resolved before validation runs — this builds on the locale-in-context and localized error messages patterns.

---

### The Two Dimensions

```
Locale-Aware Validation
│
├── 1. Format Validation
│       Does the value conform to locale-specific rules?
│       Examples:
│         • Phone: +1 (555) 000-0000  vs  +33 6 00 00 00 00
│         • Postal code: 10001  vs  75001  vs  EC1A 1BB
│         • Date input: MM/DD/YYYY  vs  DD/MM/YYYY  vs  YYYY-MM-DD
│         • Number: 1,234.56  vs  1.234,56
│
└── 2. Message Localization
        Does the validation failure message reflect the user's locale?
        Covered in depth in the Localized Error Messages topic.
        Summarized here as it intersects with format validation.
```

---

### Architecture: Where Locale-Aware Validation Lives

Zod schemas are defined statically. They cannot accept `ctx.locale` directly because they are constructed before a request exists. The pattern is to build schemas *from* locale at request time inside the procedure, or to use Zod's `.superRefine()` for runtime locale injection.

```
Request arrives
      │
      ▼
createContext() → { locale: 'de-DE', user: ... }
      │
      ▼
Procedure handler receives ctx
      │
      ├── Option A: Build schema from locale
      │   const schema = buildSchema(ctx.locale)
      │   schema.parse(input)
      │
      └── Option B: Static schema + superRefine with locale
          staticSchema
            .superRefine(localeRefinement(ctx.locale))
            .parse(input)
```

---

### Building Locale-Specific Schemas

#### Postal code validation

Postal code formats vary significantly by country. A schema factory accepts a locale and returns the appropriate Zod schema.

```ts
// lib/validation/postalCode.ts
import { z } from 'zod';
import type { SupportedLocale } from '../locale';

const postalCodePatterns: Record<SupportedLocale, RegExp> = {
  'en-US': /^\d{5}(-\d{4})?$/,           // 10001 or 10001-1234
  'en-GB': /^[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}$/i, // EC1A 1BB
  'de-DE': /^\d{5}$/,                     // 10115
  'fr-FR': /^\d{5}$/,                     // 75001
  'ja-JP': /^\d{3}-?\d{4}$/,             // 100-0001 or 1000001
  'es-ES': /^\d{5}$/,                     // 28001
};

const postalCodeExamples: Record<SupportedLocale, string> = {
  'en-US': '10001 or 10001-1234',
  'en-GB': 'EC1A 1BB',
  'de-DE': '10115',
  'fr-FR': '75001',
  'ja-JP': '100-0001',
  'es-ES': '28001',
};

export function postalCodeSchema(locale: SupportedLocale) {
  const pattern = postalCodePatterns[locale];
  const example = postalCodeExamples[locale];

  return z
    .string()
    .trim()
    .refine(
      (val) => pattern.test(val),
      { message: `Invalid postal code for this region. Example: ${example}` }
    );
}
```

Usage in a procedure:

```ts
updateAddress: protectedProcedure
  .mutation(async ({ ctx, input }) => {
    // Schema built from resolved locale
    const schema = z.object({
      street: z.string().min(1).max(255),
      city: z.string().min(1).max(100),
      postalCode: postalCodeSchema(ctx.locale),
    });

    const parsed = schema.parse(input);

    await db.address.update({
      where: { userId: ctx.user.id },
      data: parsed,
    });

    return { updated: true };
  }),
```

> ⚠️ Postal code regex patterns above are illustrative approximations. Real-world postal code validation is more complex — many countries have exceptions, territories, and edge cases. Consider a dedicated library such as `i18n-postal-code` for production use. [Unverified: library availability and maintenance status — verify before adopting.]

---

#### Phone number validation

Phone number format varies by country calling code, digit count, and local conventions.

```ts
// lib/validation/phoneNumber.ts
import { z } from 'zod';
import type { SupportedLocale } from '../locale';

// Basic pattern approach — for production, prefer libphonenumber-js
const phonePatterns: Record<SupportedLocale, RegExp> = {
  'en-US': /^\+?1?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}$/,
  'en-GB': /^\+?44\s?\d{4}\s?\d{6}$|^0\d{4}\s?\d{6}$/,
  'de-DE': /^\+?49\s?\d{3,4}\s?\d{6,8}$|^0\d{3,4}\s?\d{6,8}$/,
  'fr-FR': /^\+?33\s?[1-9](\s?\d{2}){4}$|^0[1-9](\s?\d{2}){4}$/,
  'ja-JP': /^\+?81[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{4}$|^0\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{4}$/,
  'es-ES': /^\+?34\s?\d{9}$|^[6789]\d{8}$/,
};

export function phoneSchema(locale: SupportedLocale) {
  const pattern = phonePatterns[locale];

  return z
    .string()
    .trim()
    .refine(
      (val) => pattern.test(val),
      { message: 'Invalid phone number format for this region.' }
    );
}
```

[Inference] Regex-based phone validation is inherently incomplete. `libphonenumber-js` (a port of Google's libphonenumber) handles real-world phone number parsing and validation far more accurately across locales, at the cost of bundle size. For any production use case involving phone numbers, prefer a dedicated library over hand-written regex.

```ts
// lib/validation/phoneNumber.libphonenumber.ts
import { parsePhoneNumberWithError, isValidPhoneNumber } from 'libphonenumber-js';
import { z } from 'zod';
import type { SupportedLocale } from '../locale';

// Map your locale codes to ISO 3166-1 alpha-2 country codes
const localeToCountry: Record<SupportedLocale, string> = {
  'en-US': 'US',
  'en-GB': 'GB',
  'de-DE': 'DE',
  'fr-FR': 'FR',
  'ja-JP': 'JP',
  'es-ES': 'ES',
};

export function phoneSchema(locale: SupportedLocale) {
  const country = localeToCountry[locale];

  return z
    .string()
    .trim()
    .refine(
      (val) => {
        try {
          return isValidPhoneNumber(val, country as any);
        } catch {
          return false;
        }
      },
      { message: 'Invalid phone number for this region.' }
    );
}
```

---

#### Date input validation

Date strings from user input vary in format by locale. The server should normalize them to a canonical representation after locale-aware parsing.

```ts
// lib/validation/date.ts
import { z } from 'zod';
import type { SupportedLocale } from '../locale';

// Expected input format per locale (user-facing)
const dateFormats: Record<SupportedLocale, {
  pattern: RegExp;
  parse: (val: string) => Date | null;
  example: string;
}> = {
  'en-US': {
    pattern: /^(0?[1-9]|1[0-2])\/(0?[1-9]|[12]\d|3[01])\/\d{4}$/,
    example: 'MM/DD/YYYY',
    parse: (val) => {
      const [m, d, y] = val.split('/').map(Number);
      const date = new Date(y, m - 1, d);
      return isNaN(date.getTime()) ? null : date;
    },
  },
  'en-GB': {
    pattern: /^(0?[1-9]|[12]\d|3[01])\/(0?[1-9]|1[0-2])\/\d{4}$/,
    example: 'DD/MM/YYYY',
    parse: (val) => {
      const [d, m, y] = val.split('/').map(Number);
      const date = new Date(y, m - 1, d);
      return isNaN(date.getTime()) ? null : date;
    },
  },
  'de-DE': {
    pattern: /^(0?[1-9]|[12]\d|3[01])\.(0?[1-9]|1[0-2])\.\d{4}$/,
    example: 'DD.MM.YYYY',
    parse: (val) => {
      const [d, m, y] = val.split('.').map(Number);
      const date = new Date(y, m - 1, d);
      return isNaN(date.getTime()) ? null : date;
    },
  },
  'fr-FR': {
    pattern: /^(0?[1-9]|[12]\d|3[01])\/(0?[1-9]|1[0-2])\/\d{4}$/,
    example: 'DD/MM/YYYY',
    parse: (val) => {
      const [d, m, y] = val.split('/').map(Number);
      const date = new Date(y, m - 1, d);
      return isNaN(date.getTime()) ? null : date;
    },
  },
  'ja-JP': {
    pattern: /^\d{4}\/(0?[1-9]|1[0-2])\/(0?[1-9]|[12]\d|3[01])$/,
    example: 'YYYY/MM/DD',
    parse: (val) => {
      const [y, m, d] = val.split('/').map(Number);
      const date = new Date(y, m - 1, d);
      return isNaN(date.getTime()) ? null : date;
    },
  },
  'es-ES': {
    pattern: /^(0?[1-9]|[12]\d|3[01])\/(0?[1-9]|1[0-2])\/\d{4}$/,
    example: 'DD/MM/YYYY',
    parse: (val) => {
      const [d, m, y] = val.split('/').map(Number);
      const date = new Date(y, m - 1, d);
      return isNaN(date.getTime()) ? null : date;
    },
  },
};

export function localeDateStringSchema(locale: SupportedLocale) {
  const format = dateFormats[locale];

  return z
    .string()
    .trim()
    .refine(
      (val) => format.pattern.test(val),
      { message: `Date must be in ${format.example} format.` }
    )
    .transform((val) => {
      const parsed = format.parse(val);
      if (!parsed) throw new Error('Invalid date value.');
      return parsed; // Returns a Date object
    });
}
```

**Key Points:**

- The schema transforms a locale-formatted string into a `Date`. Downstream code works with `Date` objects, not locale strings.
- Invalid calendar dates (e.g., February 30) are caught by the `parse` function returning `null`.
- [Inference] If your client sends ISO 8601 strings (`YYYY-MM-DD`) regardless of locale, locale-aware date parsing is unnecessary — use `z.coerce.date()` instead and handle display formatting on the client.

---

#### Number input validation

Numbers are formatted differently across locales: `1,234.56` in `en-US` versus `1.234,56` in `de-DE`. If the server receives user-typed number strings rather than raw numeric values, locale-aware parsing is necessary.

```ts
// lib/validation/number.ts
import { z } from 'zod';
import type { SupportedLocale } from '../locale';

const numberFormats: Record<SupportedLocale, {
  thousandsSep: string;
  decimalSep: string;
}> = {
  'en-US': { thousandsSep: ',', decimalSep: '.' },
  'en-GB': { thousandsSep: ',', decimalSep: '.' },
  'de-DE': { thousandsSep: '.', decimalSep: ',' },
  'fr-FR': { thousandsSep: '\u00A0', decimalSep: ',' }, // non-breaking space
  'ja-JP': { thousandsSep: ',', decimalSep: '.' },
  'es-ES': { thousandsSep: '.', decimalSep: ',' },
};

export function localeNumberStringSchema(locale: SupportedLocale) {
  const fmt = numberFormats[locale];

  return z
    .string()
    .trim()
    .transform((val, ctx) => {
      // Remove thousands separator, normalize decimal separator
      const normalized = val
        .split(fmt.thousandsSep).join('')
        .replace(fmt.decimalSep, '.');

      const num = Number(normalized);

      if (isNaN(num)) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: `Invalid number format. Expected format: ${
            (12345.67).toLocaleString(locale)
          }`,
        });
        return z.NEVER;
      }

      return num; // Returns a JavaScript number
    });
}
```

**Example:**

```ts
const schema = localeNumberStringSchema('de-DE');

schema.parse('1.234,56'); // → 1234.56
schema.parse('1,234.56'); // → NaN → ZodError
```

---

### Combining Locale Schemas in a Procedure

```ts
// routers/profile.ts
import { router, protectedProcedure } from '../trpc';
import { postalCodeSchema } from '../lib/validation/postalCode';
import { phoneSchema } from '../lib/validation/phoneNumber';
import { localeDateStringSchema } from '../lib/validation/date';
import { z } from 'zod';

export const profileRouter = router({
  updateProfile: protectedProcedure
    .mutation(async ({ ctx, input }) => {
      // Build locale-aware schema at request time
      const schema = z.object({
        displayName: z.string().min(1).max(100),
        phone: phoneSchema(ctx.locale),
        postalCode: postalCodeSchema(ctx.locale),
        birthDate: localeDateStringSchema(ctx.locale),
      });

      // Parse and transform — throws TRPCError on failure via middleware
      const parsed = schema.parse(input);

      await db.profile.update({
        where: { userId: ctx.user.id },
        data: {
          displayName: parsed.displayName,
          phone: parsed.phone,
          postalCode: parsed.postalCode,
          birthDate: parsed.birthDate, // already a Date
        },
      });

      return { updated: true };
    }),
});
```

[Inference] Building schemas inside the procedure handler on every request has a small runtime cost. For high-frequency procedures, memoize schema construction by locale. Behavior and performance impact vary by schema complexity and request volume.

---

### Memoizing Locale Schemas

For procedures called at high volume, avoid rebuilding the same schema on every invocation:

```ts
// lib/validation/schemaCache.ts
import type { SupportedLocale } from '../locale';
import { z } from 'zod';
import { postalCodeSchema } from './postalCode';
import { phoneSchema } from './phoneNumber';

type ProfileSchema = ReturnType<typeof buildProfileSchema>;
const profileSchemaCache = new Map<SupportedLocale, ProfileSchema>();

function buildProfileSchema(locale: SupportedLocale) {
  return z.object({
    displayName: z.string().min(1).max(100),
    phone: phoneSchema(locale),
    postalCode: postalCodeSchema(locale),
  });
}

export function getProfileSchema(locale: SupportedLocale): ProfileSchema {
  if (!profileSchemaCache.has(locale)) {
    profileSchemaCache.set(locale, buildProfileSchema(locale));
  }
  return profileSchemaCache.get(locale)!;
}
```

[Inference] Because `SupportedLocale` is a finite set, the cache will hold at most one schema per locale per schema type. Memory impact is bounded. This pattern is safe for module-level caching in both long-running servers and serverless environments where module cache persists across warm invocations.

---

### Integrating with the Custom Error Formatter

Locale-aware Zod errors surface through the same `errorFormatter` established in the Localized Error Messages topic. Field paths and messages from locale-specific refinements are included automatically:

```ts
// Already covered in errorFormatter — no additional setup needed
zodErrors:
  error.cause instanceof ZodError
    ? localizeZodErrors(error.cause, locale)
    : null,
```

For custom refinement messages that already contain locale-specific text (as in the schemas above), the `localizeZodErrors` function passes them through without translation, since they are already localized at schema construction time.

[Inference] This means locale-aware schemas and the localized error catalog are complementary: schema-level messages handle format-specific text; catalog messages handle generic error codes. Both reach the client through the same `zodErrors` map.

---

### Locale-Aware Schema for `.input()`

tRPC's `.input()` runs Zod parsing before the procedure body. To use a locale-aware schema in `.input()`, you must defer schema construction — which `.input()` does not natively support since it receives a static schema.

The practical solution is to accept raw input through a permissive `.input()` schema and re-validate with the locale-aware schema inside the handler:

```ts
updateProfile: protectedProcedure
  // Accept raw strings — locale-aware parsing happens inside
  .input(z.object({
    displayName: z.string(),
    phone: z.string(),
    postalCode: z.string(),
    birthDate: z.string(),
  }))
  .mutation(async ({ input, ctx }) => {
    // Second-pass locale-aware validation and transformation
    const localeSchema = z.object({
      displayName: z.string().min(1).max(100),
      phone: phoneSchema(ctx.locale),
      postalCode: postalCodeSchema(ctx.locale),
      birthDate: localeDateStringSchema(ctx.locale),
    });

    // Throw TRPCError manually to keep error shape consistent
    const result = localeSchema.safeParse(input);

    if (!result.success) {
      throw new TRPCError({
        code: 'BAD_REQUEST',
        message: 'Validation failed',
        cause: result.error,
      });
    }

    const parsed = result.data;
    // ... continue with parsed
  }),
```

**Key Points:**

- The first `.input()` schema acts as a structural guard — it ensures fields are present and are strings.
- The second `localeSchema.safeParse()` performs semantic, locale-aware validation.
- Passing `cause: result.error` (the `ZodError`) ensures the `errorFormatter` picks it up and populates `zodErrors` correctly.

---

### Locale Mismatch Considerations

A user may have `ctx.locale = 'en-US'` but type a number in German format. This is a real edge case — users who switch locales mid-session, paste from external sources, or use browser autofill.

Strategies:

| Strategy | Description |
| --- | --- |
| Strict locale validation | Reject input that does not match resolved locale. Return a clear format hint in the error message. |
| Multi-locale fallback | Try parsing with the resolved locale first; if it fails, try other supported locales. Accept on first match. |
| Normalization hint | Return a `suggestion` field in the error data showing the expected format. |
| Client-side format enforcement | Use input masking on the client to prevent locale-mismatched input from being submitted. [Inference] |

[Inference] Multi-locale fallback risks accepting ambiguous values: `01/02/2025` is January 2 in `en-US` and February 1 in `en-GB`. Strict validation is safer where date ambiguity matters. Client-side input masking removes the ambiguity at the source.

---

### Testing Locale-Aware Schemas

```ts
// tests/localeValidation.test.ts
import { postalCodeSchema } from '../lib/validation/postalCode';
import { localeDateStringSchema } from '../lib/validation/date';
import { localeNumberStringSchema } from '../lib/validation/number';

describe('postalCodeSchema', () => {
  it('accepts valid US zip code', () => {
    expect(postalCodeSchema('en-US').parse('10001')).toBe('10001');
    expect(postalCodeSchema('en-US').parse('10001-1234')).toBe('10001-1234');
  });

  it('rejects US format for de-DE locale', () => {
    expect(() => postalCodeSchema('de-DE').parse('10001-1234')).toThrow();
  });

  it('accepts valid UK postcode', () => {
    expect(() => postalCodeSchema('en-GB').parse('EC1A 1BB')).not.toThrow();
  });
});

describe('localeDateStringSchema', () => {
  it('parses en-US MM/DD/YYYY and returns Date', () => {
    const result = localeDateStringSchema('en-US').parse('01/15/2025');
    expect(result).toBeInstanceOf(Date);
    expect(result.getMonth()).toBe(0); // January
    expect(result.getDate()).toBe(15);
  });

  it('parses de-DE DD.MM.YYYY correctly', () => {
    const result = localeDateStringSchema('de-DE').parse('15.01.2025');
    expect(result.getMonth()).toBe(0);
    expect(result.getDate()).toBe(15);
  });

  it('rejects ambiguous cross-locale format', () => {
    // en-GB expects DD/MM/YYYY — 13/01/2025 is valid; 01/13/2025 is not
    expect(() => localeDateStringSchema('en-GB').parse('01/13/2025')).toThrow();
  });
});

describe('localeNumberStringSchema', () => {
  it('parses de-DE formatted number', () => {
    expect(localeNumberStringSchema('de-DE').parse('1.234,56')).toBe(1234.56);
  });

  it('rejects en-US format for de-DE locale', () => {
    expect(() => localeNumberStringSchema('de-DE').parse('1,234.56')).toThrow();
  });
});
```

---

**Conclusion:**
Locale-aware validation in tRPC is a two-part problem: validating that input conforms to locale-specific formats, and returning error messages in the user's language. Zod schemas are constructed statically, so locale must be injected at request time — either by building schemas inside the procedure handler or through `superRefine`. Postal codes, phone numbers, date strings, and number formats are the most common cases requiring locale-specific rules. For production use, prefer dedicated libraries (`libphonenumber-js`, `i18n-postal-code`) over regex approximations, and memoize schema construction by locale for high-frequency procedures.

**Next Steps:**

- Audit your existing `.input()` schemas for fields that implicitly assume a single locale format
- Add client-side input masking for locale-sensitive fields to prevent format mismatches before submission
- Memoize locale schema construction before load-testing — measure whether construction cost is significant for your traffic profile