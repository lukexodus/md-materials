## Localized Error Messages

### What Are Localized Error Messages?

Localized error messages are server-returned error strings adapted to the requesting user's language and regional conventions. In a tRPC application, errors surface through `TRPCError` and reach the client via the error shape. Localization means the `message` field — or a custom field in the error data — reflects the user's locale rather than always returning English.

**Key Points:**

- tRPC errors are structured objects. The `message` field is a plain string with no built-in i18n support.
- Localization can target the `message` field directly, or a separate `data` field carrying a translation key and localized string alongside each other.
- The locale must already be resolved in context before error construction — this topic builds directly on locale-in-context patterns.
- Localizing error messages is not always the right choice. The tradeoff between server-side and client-side translation responsibility is worth evaluating explicitly.

---

### Where tRPC Errors Surface

```
Procedure throws TRPCError
         │
         ▼
  tRPC error formatter
  (formatError in initTRPC)
         │
         ▼
  HTTP response body:
  {
    error: {
      message: "...",       ← localized here, or
      data: {
        code: "NOT_FOUND",
        translationKey: "error.notFound",   ← or carry key here
        localizedMessage: "..."             ← alongside raw message
      }
    }
  }
         │
         ▼
  Client receives via TRPCClientError
  error.message / error.data
```

Localization can intercept at two points: inside the procedure when constructing the `TRPCError`, or inside `formatError` when shaping the outgoing error response.

---

### Approach 1: Localize at Throw Site

The simplest approach. The procedure has access to `ctx.locale` and passes a localized string directly to `TRPCError`.

```ts
// lib/i18n/errors.ts

export const errorCatalog = {
  'error.notFound': {
    'en-US': 'The requested resource was not found.',
    'fr-FR': 'La ressource demandée est introuvable.',
    'de-DE': 'Die angeforderte Ressource wurde nicht gefunden.',
    'ja-JP': 'リクエストされたリソースが見つかりません。',
    'es-ES': 'El recurso solicitado no fue encontrado.',
  },
  'error.unauthorized': {
    'en-US': 'You are not authorized to perform this action.',
    'fr-FR': "Vous n'êtes pas autorisé à effectuer cette action.",
    'de-DE': 'Sie sind nicht berechtigt, diese Aktion durchzuführen.',
    'ja-JP': 'この操作を実行する権限がありません。',
    'es-ES': 'No está autorizado para realizar esta acción.',
  },
  'error.validation': {
    'en-US': 'The provided input is invalid.',
    'fr-FR': "Les données fournies sont invalides.",
    'de-DE': 'Die eingegebenen Daten sind ungültig.',
    'ja-JP': '入力されたデータが無効です。',
    'es-ES': 'Los datos proporcionados no son válidos.',
  },
  'error.rateLimited': {
    'en-US': 'Too many requests. Please try again later.',
    'fr-FR': 'Trop de requêtes. Veuillez réessayer plus tard.',
    'de-DE': 'Zu viele Anfragen. Bitte versuchen Sie es später erneut.',
    'ja-JP': 'リクエストが多すぎます。後でもう一度お試しください。',
    'es-ES': 'Demasiadas solicitudes. Por favor, inténtelo más tarde.',
  },
} satisfies Record<string, Record<string, string>>;

export type ErrorKey = keyof typeof errorCatalog;
export const DEFAULT_LOCALE = 'en-US';

export function t(key: ErrorKey, locale: string): string {
  const entry = errorCatalog[key];
  return entry[locale] ?? entry[DEFAULT_LOCALE] ?? key;
}
```

```ts
// In a procedure
import { TRPCError } from '@trpc/server';
import { t } from '../lib/i18n/errors';

getDocument: protectedProcedure
  .input(z.object({ docId: z.string() }))
  .query(async ({ input, ctx }) => {
    const doc = await db.document.findFirst({
      where: { id: input.docId, userId: ctx.user.id },
    });

    if (!doc) {
      throw new TRPCError({
        code: 'NOT_FOUND',
        message: t('error.notFound', ctx.locale),
      });
    }

    return doc;
  }),
```

**Key Points:**

- Simple to implement. No custom error formatter required.
- `message` always arrives localized. No client-side translation needed.
- Translation keys are invisible to the client — only the final string is sent.

**Limitations:**

- If the client needs the translation key (for logging, analytics, or re-translation), it is not available.
- Errors thrown by tRPC itself (e.g., input validation failures from Zod) are not localized by this approach — only manually thrown errors.

---

### Approach 2: Carry Both Key and Localized Message

Add a structured `data` payload to the error alongside the localized `message`. The client receives both the key and the string.

```ts
// lib/errors.ts
import { TRPCError } from '@trpc/server';
import { t, type ErrorKey } from './i18n/errors';
import type { SupportedLocale } from './locale';
import type { TRPC_ERROR_CODE_KEY } from '@trpc/server/rpc';

interface LocalizedErrorOptions {
  code: TRPC_ERROR_CODE_KEY;
  key: ErrorKey;
  locale: SupportedLocale;
  cause?: unknown;
}

export function localizedTRPCError(opts: LocalizedErrorOptions): TRPCError {
  return new TRPCError({
    code: opts.code,
    message: t(opts.key, opts.locale),
    cause: opts.cause,
  });
}
```

To carry the key in `data`, use a custom error formatter (covered in Approach 3). Alternatively, encode the key in a structured `message`:

```ts
// Encoding key as structured message — not recommended for production
// as it couples key format to the message field
throw new TRPCError({
  code: 'NOT_FOUND',
  message: JSON.stringify({
    key: 'error.notFound',
    message: t('error.notFound', ctx.locale),
  }),
});
```

> ⚠️ Encoding JSON in `message` is fragile. Prefer a custom error formatter for structured error data.

---

### Approach 3: Custom Error Formatter

`initTRPC` accepts a `errorFormatter` option that shapes every outgoing error. This is the cleanest place to attach translation keys and localized strings without modifying throw sites.

#### Define error metadata type

```ts
// lib/i18n/errorMeta.ts
export interface LocalizedErrorData {
  translationKey?: string;
  localizedMessage?: string;
  locale?: string;
  zodErrors?: Record<string, string[]>; // field-level errors
}
```

#### Custom formatter

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import { ZodError } from 'zod';
import type { Context } from './context';
import { t, errorCatalog } from '../lib/i18n/errors';

const trpcErrorCodeToKey: Partial<Record<string, keyof typeof errorCatalog>> = {
  NOT_FOUND: 'error.notFound',
  UNAUTHORIZED: 'error.unauthorized',
  BAD_REQUEST: 'error.validation',
  TOO_MANY_REQUESTS: 'error.rateLimited',
};

export const tRPC = initTRPC.context<Context>().create({
  errorFormatter({ shape, error, ctx }) {
    const locale = ctx?.locale ?? 'en-US';

    // Attempt to derive a translation key from tRPC error code
    const derivedKey = trpcErrorCodeToKey[shape.data.code];

    // Use message as-is if already localized at throw site
    // Attach key and locale for client use
    return {
      ...shape,
      data: {
        ...shape.data,
        locale,
        translationKey: derivedKey ?? null,
        localizedMessage: derivedKey
          ? t(derivedKey, locale)
          : shape.message,
        // Attach Zod field errors if present
        zodErrors:
          error.cause instanceof ZodError
            ? localizeZodErrors(error.cause, locale)
            : null,
      },
    };
  },
});
```

**Output shape:**

```json
{
  "error": {
    "message": "The requested resource was not found.",
    "data": {
      "code": "NOT_FOUND",
      "httpStatus": 404,
      "locale": "fr-FR",
      "translationKey": "error.notFound",
      "localizedMessage": "La ressource demandée est introuvable.",
      "zodErrors": null
    }
  }
}
```

[Inference] The `errorFormatter` runs for every error, including internal tRPC errors and uncaught exceptions. Errors without a matching `ctx` (e.g., errors during context creation) may have `ctx` as `undefined` — always guard with a fallback locale.

---

### Localizing Zod Validation Errors

Zod errors from `.input()` parsing are the most common source of client-facing errors. They are not `TRPCError` instances — they surface as `BAD_REQUEST` with a `ZodError` as the cause.

#### Field-level localization

```ts
// lib/i18n/zodErrors.ts

const zodErrorMessages: Record<string, Record<string, string>> = {
  'zod.required': {
    'en-US': 'This field is required.',
    'fr-FR': 'Ce champ est obligatoire.',
    'de-DE': 'Dieses Feld ist erforderlich.',
    'ja-JP': 'このフィールドは必須です。',
  },
  'zod.string.min': {
    'en-US': 'Must be at least {min} characters.',
    'fr-FR': 'Doit contenir au moins {min} caractères.',
    'de-DE': 'Muss mindestens {min} Zeichen lang sein.',
    'ja-JP': '{min}文字以上である必要があります。',
  },
  'zod.string.max': {
    'en-US': 'Must be at most {max} characters.',
    'fr-FR': 'Ne doit pas dépasser {max} caractères.',
    'de-DE': 'Darf höchstens {max} Zeichen lang sein.',
    'ja-JP': '{max}文字以下である必要があります。',
  },
  'zod.string.email': {
    'en-US': 'Must be a valid email address.',
    'fr-FR': 'Doit être une adresse e-mail valide.',
    'de-DE': 'Muss eine gültige E-Mail-Adresse sein.',
    'ja-JP': '有効なメールアドレスを入力してください。',
  },
};

function interpolate(template: string, vars: Record<string, unknown>): string {
  return template.replace(/\{(\w+)\}/g, (_, key) => String(vars[key] ?? `{${key}}`));
}

function zodIssueToKey(issue: import('zod').ZodIssue): string {
  if (issue.code === 'too_small' && issue.type === 'string') return 'zod.string.min';
  if (issue.code === 'too_big' && issue.type === 'string') return 'zod.string.max';
  if (issue.code === 'invalid_string' && issue.validation === 'email') return 'zod.string.email';
  if (issue.code === 'invalid_type' && issue.received === 'undefined') return 'zod.required';
  return 'zod.required'; // fallback
}

export function localizeZodErrors(
  error: import('zod').ZodError,
  locale: string
): Record<string, string[]> {
  const result: Record<string, string[]> = {};

  for (const issue of error.issues) {
    const path = issue.path.join('.') || '_root';
    const key = zodIssueToKey(issue);
    const template = zodErrorMessages[key]?.[locale]
      ?? zodErrorMessages[key]?.['en-US']
      ?? issue.message;

    const vars: Record<string, unknown> = {};
    if ('minimum' in issue) vars['min'] = issue.minimum;
    if ('maximum' in issue) vars['max'] = issue.maximum;

    const message = interpolate(template, vars);

    if (!result[path]) result[path] = [];
    result[path].push(message);
  }

  return result;
}
```

**Output for a validation error:**

```json
{
  "error": {
    "message": "Les données fournies sont invalides.",
    "data": {
      "code": "BAD_REQUEST",
      "locale": "fr-FR",
      "translationKey": "error.validation",
      "zodErrors": {
        "email": ["Doit être une adresse e-mail valide."],
        "username": ["Doit contenir au moins 3 caractères."]
      }
    }
  }
}
```

[Inference] Zod's own `error.issues` structure is stable across minor versions but may change across major versions. Verify `issue.code` and related fields against the Zod version in your project.

---

### Inferring Error Data Types on the Client

With a custom error formatter, the client can infer the shape of `error.data` using tRPC's router type.

```ts
// client/trpc.ts
import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '../server/router';

export const trpc = createTRPCReact<AppRouter>();
```

```ts
// In a React component
const mutation = trpc.documents.create.useMutation({
  onError(error) {
    // error.data is typed from your errorFormatter return shape
    const { zodErrors, localizedMessage, locale } = error.data ?? {};

    if (zodErrors) {
      // Set field errors in your form library
      Object.entries(zodErrors).forEach(([field, messages]) => {
        form.setError(field, { message: messages[0] });
      });
    } else if (localizedMessage) {
      toast.error(localizedMessage);
    }
  },
});
```

[Inference] The `error.data` type inference works when the `errorFormatter` return type is statically known. If the formatter conditionally returns different shapes, TypeScript may widen the type. Keep the formatter's return shape consistent for reliable inference.

---

### Localizing Errors Not in Your Catalog

Not all errors come from your own `throw` statements. Internal tRPC errors, uncaught exceptions, and third-party library errors all pass through `errorFormatter`. Handle these gracefully:

```ts
errorFormatter({ shape, error, ctx }) {
  const locale = ctx?.locale ?? 'en-US';
  const derivedKey = trpcErrorCodeToKey[shape.data.code];

  // For errors without a catalog entry, use a generic fallback
  const localizedMessage = derivedKey
    ? t(derivedKey, locale)
    : t('error.generic', locale); // always have a generic fallback

  return {
    ...shape,
    // In production, do not expose raw internal error messages
    message: process.env.NODE_ENV === 'production'
      ? localizedMessage
      : shape.message,
    data: {
      ...shape.data,
      locale,
      localizedMessage,
      translationKey: derivedKey ?? null,
      zodErrors: error.cause instanceof ZodError
        ? localizeZodErrors(error.cause, locale)
        : null,
    },
  };
},
```

> ⚠️ In production, avoid surfacing raw internal error messages in `shape.message`. They may expose implementation details, stack traces, or database error strings. Replace with a localized generic message, and log the original error server-side.

---

### External Translation Files

For larger applications, maintaining translations inline in TypeScript becomes unwieldy. Load them from JSON files instead:

```
locales/
  en-US/
    errors.json
  fr-FR/
    errors.json
  de-DE/
    errors.json
```

```json
// locales/fr-FR/errors.json
{
  "error.notFound": "La ressource demandée est introuvable.",
  "error.unauthorized": "Vous n'êtes pas autorisé à effectuer cette action.",
  "error.validation": "Les données fournies sont invalides.",
  "error.generic": "Une erreur inattendue est survenue."
}
```

```ts
// lib/i18n/loader.ts
import type { SupportedLocale } from '../locale';

type ErrorTranslations = Record<string, string>;
const cache = new Map<SupportedLocale, ErrorTranslations>();

export async function loadErrorTranslations(
  locale: SupportedLocale
): Promise<ErrorTranslations> {
  if (cache.has(locale)) return cache.get(locale)!;

  const translations = await import(`../../locales/${locale}/errors.json`);
  cache.set(locale, translations.default);
  return translations.default;
}
```

[Inference] Dynamic imports with variable paths may not be supported in all bundlers or runtimes. Verify that your bundler includes the locale JSON files in the output. In serverless environments, filesystem access at runtime is constrained — bundle translations at build time where possible.

---

### Testing Localized Errors

```ts
// tests/localizedErrors.test.ts
import { createCallerFactory } from '@trpc/server';
import { appRouter } from '../server/router';

const createCaller = createCallerFactory(appRouter);

describe('localized error messages', () => {
  it('returns French error for fr-FR locale', async () => {
    const caller = createCaller({ user: null, locale: 'fr-FR' });

    await expect(
      caller.documents.get({ docId: 'nonexistent' })
    ).rejects.toMatchObject({
      message: 'La ressource demandée est introuvable.',
    });
  });

  it('falls back to en-US for unsupported locale', async () => {
    const caller = createCaller({ user: null, locale: 'en-US' });

    await expect(
      caller.documents.get({ docId: 'nonexistent' })
    ).rejects.toMatchObject({
      message: 'The requested resource was not found.',
    });
  });

  it('includes zodErrors in data for validation failures', async () => {
    const caller = createCaller({ user: null, locale: 'de-DE' });

    await expect(
      caller.users.create({ email: 'not-an-email', username: 'a' })
    ).rejects.toMatchObject({
      data: {
        zodErrors: {
          email: ['Muss eine gültige E-Mail-Adresse sein.'],
          username: expect.arrayContaining([expect.stringContaining('3')]),
        },
      },
    });
  });
});
```

---

### Server-Side vs. Client-Side Translation: Decision Guide

| Factor | Favor server-side | Favor client-side |
| --- | --- | --- |
| Client type | Non-JS (native app, third-party) | React / web SPA |
| Translation ownership | Backend team owns strings | Frontend team owns strings |
| Caching | Not a concern | Important — responses vary by locale |
| Key visibility | Client does not need keys | Client needs keys for analytics/logging |
| Zod error presentation | Server formats field messages | Client maps Zod issues to strings |
| Bundle size | No impact on client bundle | Translation files add to client bundle |
| Runtime locale switching | Requires new request | Can switch without network call |

[Inference] Most React-based tRPC applications benefit from client-side translation using a library such as `react-i18next` or `next-intl`, with tRPC returning translation keys rather than localized strings. Server-side localization is most valuable for non-JS clients or when the backend independently serves multiple client types.

---

**Conclusion:**
Localized error messages in tRPC can be implemented at three levels: at the throw site using `ctx.locale`, in a custom `errorFormatter` applied globally, or as structured data carrying both a key and a localized string. The `errorFormatter` is the most systematic approach, as it covers all errors including Zod validation failures and internal tRPC errors. In production, always replace raw internal messages with generic localized strings and log the originals server-side. Whether to localize on the server or client is an architectural choice — evaluate it before building the catalog, as it affects response shape, caching behavior, and where translation strings are maintained.

**Next Steps:**

- Define a generic fallback error key (`error.generic`) before building domain-specific ones — uncatalogued errors always need somewhere to go
- Suppress raw internal error messages in production through the `errorFormatter` before adding any localization
- Decide server-side vs. client-side translation ownership explicitly with your team — retrofitting this decision is expensive