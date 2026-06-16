## Passing Locale Through Context

### What Is Locale in This Context?

Locale refers to a combination of language and regional formatting preferences — typically expressed as a BCP 47 tag such as `en-US`, `fr-FR`, or `ja-JP`. In a tRPC application, locale influences how the server formats responses: translated strings, date and number formatting, error messages, and currency display.

**Key Points:**

- Locale is a per-request concern. It belongs in tRPC context, not in global state.
- The server may use locale for response formatting, error message translation, or data filtering — or delegate all formatting to the client and use locale only for content selection.
- Multiple locale sources exist: HTTP headers, cookies, user preferences stored in the database, and explicit procedure input. Each has different reliability and precedence.

---

### Locale Sources and Precedence

```
┌─────────────────────────────────────────┐
│           Locale Resolution             │
│                                         │
│  1. User preference (DB)   ← highest    │
│  2. Explicit input param               │
│  3. Cookie (locale=fr-FR)              │
│  4. Accept-Language header             │
│  5. Application default    ← lowest    │
└─────────────────────────────────────────┘
```

[Inference] Authenticated users with a stored preference should have that preference take priority over browser-negotiated headers, as it reflects an explicit choice. Unauthenticated requests typically fall back to header or cookie negotiation. The exact precedence is an application-level decision — no single ordering is universally correct.

---

### Extracting Locale from the Request

#### From `Accept-Language` header

```ts
// lib/locale.ts

const SUPPORTED_LOCALES = ['en-US', 'fr-FR', 'de-DE', 'ja-JP', 'es-ES'] as const;
export type SupportedLocale = typeof SUPPORTED_LOCALES[number];
export const DEFAULT_LOCALE: SupportedLocale = 'en-US';

export function parseAcceptLanguage(header: string | undefined): SupportedLocale {
  if (!header) return DEFAULT_LOCALE;

  // Accept-Language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7
  const preferred = header
    .split(',')
    .map((part) => {
      const [tag, q] = part.trim().split(';q=');
      return { tag: tag.trim(), quality: q ? parseFloat(q) : 1.0 };
    })
    .sort((a, b) => b.quality - a.quality)
    .map((p) => p.tag);

  for (const tag of preferred) {
    // Exact match
    const exact = SUPPORTED_LOCALES.find((l) => l === tag);
    if (exact) return exact;

    // Language-only fallback: 'fr' matches 'fr-FR'
    const lang = tag.split('-')[0];
    const partial = SUPPORTED_LOCALES.find((l) => l.startsWith(lang + '-'));
    if (partial) return partial;
  }

  return DEFAULT_LOCALE;
}

export function isSupported(locale: string): locale is SupportedLocale {
  return (SUPPORTED_LOCALES as readonly string[]).includes(locale);
}
```

#### From a cookie

```ts
import { parse as parseCookies } from 'cookie';

export function parseLocaleCookie(cookieHeader: string | undefined): SupportedLocale | null {
  if (!cookieHeader) return null;
  const cookies = parseCookies(cookieHeader);
  const value = cookies['locale'];
  return value && isSupported(value) ? value : null;
}
```

---

### Context Definition

```ts
// server/context.ts
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import {
  parseAcceptLanguage,
  parseLocaleCookie,
  isSupported,
  DEFAULT_LOCALE,
  type SupportedLocale,
} from '../lib/locale';

export async function createContext({ req }: CreateNextContextOptions) {
  // Resolve authenticated user (abbreviated)
  const user = await getUserFromRequest(req);

  // Locale resolution in priority order
  let locale: SupportedLocale = DEFAULT_LOCALE;

  // 1. User preference from database (highest priority)
  if (user?.preferredLocale && isSupported(user.preferredLocale)) {
    locale = user.preferredLocale;
  }
  // 2. Cookie override
  else {
    const cookieLocale = parseLocaleCookie(req.headers.cookie);
    if (cookieLocale) {
      locale = cookieLocale;
    }
    // 3. Accept-Language header
    else {
      locale = parseAcceptLanguage(req.headers['accept-language']);
    }
  }

  return {
    user,
    locale,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

---

### Using Locale in Procedures

Once locale is in context, every procedure has access to it without needing it as explicit input.

#### Basic usage

```ts
// routers/products.ts
import { router, publicProcedure } from '../trpc';
import { z } from 'zod';
import { t } from '../lib/i18n';

export const productsRouter = router({
  list: publicProcedure
    .input(z.object({
      categoryId: z.string().optional(),
    }))
    .query(async ({ input, ctx }) => {
      const { locale } = ctx;

      const products = await db.product.findMany({
        where: { categoryId: input.categoryId },
      });

      return products.map((product) => ({
        id: product.id,
        name: product.translations[locale] ?? product.translations['en-US'],
        price: formatCurrency(product.priceUsd, locale),
        availableLabel: t('product.available', locale),
      }));
    }),
});
```

---

### Locale-Aware Error Messages

tRPC errors default to English. To return localized error messages, use the locale from context in your error construction.

```ts
// lib/i18n/errors.ts
const errorMessages: Record<string, Record<string, string>> = {
  'error.notFound': {
    'en-US': 'The requested resource was not found.',
    'fr-FR': 'La ressource demandée est introuvable.',
    'de-DE': 'Die angeforderte Ressource wurde nicht gefunden.',
    'ja-JP': 'リクエストされたリソースが見つかりません。',
  },
  'error.unauthorized': {
    'en-US': 'You are not authorized to perform this action.',
    'fr-FR': 'Vous n\'êtes pas autorisé à effectuer cette action.',
    'de-DE': 'Sie sind nicht berechtigt, diese Aktion durchzuführen.',
    'ja-JP': 'この操作を実行する権限がありません。',
  },
};

export function localizedError(
  key: string,
  locale: string,
  fallback = 'en-US'
): string {
  return errorMessages[key]?.[locale]
    ?? errorMessages[key]?.[fallback]
    ?? key;
}
```

```ts
// In a procedure
import { TRPCError } from '@trpc/server';
import { localizedError } from '../lib/i18n/errors';

getDocument: protectedProcedure
  .input(z.object({ docId: z.string() }))
  .query(async ({ input, ctx }) => {
    const doc = await db.document.findFirst({
      where: { id: input.docId, userId: ctx.user.id },
    });

    if (!doc) {
      throw new TRPCError({
        code: 'NOT_FOUND',
        message: localizedError('error.notFound', ctx.locale),
      });
    }

    return doc;
  }),
```

[Inference] Localizing tRPC error messages is useful when the client displays `error.message` directly. If the client handles all error presentation itself (mapping error codes to UI strings), server-side error translation may be redundant. Evaluate per application architecture.

---

### Locale-Aware Middleware

For procedures that always require locale-dependent behavior, encapsulate the pattern in a middleware-enhanced base procedure.

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

// Base locale-aware procedure — adds locale to every downstream handler
export const localeProcedure = t.procedure.use(({ ctx, next }) => {
  // Optionally validate locale is resolved before proceeding
  if (!ctx.locale) {
    return next({ ctx: { ...ctx, locale: 'en-US' as const } });
  }
  return next({ ctx });
});
```

Procedures built on `localeProcedure` are guaranteed to have `ctx.locale` available without each handler needing to guard against undefined.

---

### Allowing Per-Procedure Locale Override

Some use cases require a caller to explicitly request a specific locale — for example, an admin generating a report in a user's preferred language, or a preview endpoint.

```ts
import { z } from 'zod';
import { SUPPORTED_LOCALES } from '../lib/locale';

const localeOverrideProcedure = t.procedure
  .input(
    z.object({
      _locale: z.enum(SUPPORTED_LOCALES).optional(),
    }).passthrough() // allow other input fields
  )
  .use(({ ctx, input, next }) => {
    const locale = input._locale ?? ctx.locale;
    return next({
      ctx: { ...ctx, locale },
      // Strip _locale from input before it reaches the handler
      // Note: input modification in middleware is version-dependent
      // [Unverified] — verify stripping behavior in your tRPC version
    });
  });
```

[Unverified: the ability to strip or transform `input` within middleware depends on your tRPC version. Consult the changelog for your version before relying on this pattern.]

---

### Storing and Updating User Locale Preference

```ts
// routers/user.ts
export const userRouter = router({
  setLocale: protectedProcedure
    .input(z.object({
      locale: z.enum(SUPPORTED_LOCALES),
    }))
    .mutation(async ({ input, ctx }) => {
      await db.user.update({
        where: { id: ctx.user.id },
        data: { preferredLocale: input.locale },
      });

      return { locale: input.locale };
    }),

  getPreferences: protectedProcedure
    .query(async ({ ctx }) => {
      const user = await db.user.findUnique({
        where: { id: ctx.user.id },
        select: { preferredLocale: true },
      });

      return {
        locale: user?.preferredLocale ?? ctx.locale,
      };
    }),
});
```

The client can call `setLocale` after a user changes their language preference in settings. On the next request, `createContext` picks up the updated preference from the database.

---

### Locale in Next.js App Router

In Next.js App Router with `fetchRequestHandler`, locale can be extracted from Next.js's routing system or from the request directly.

```ts
// app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { appRouter } from '@/server/router';
import { headers } from 'next/headers';

async function handler(req: Request) {
  const headersList = await headers();

  return fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext: async () => {
      const acceptLanguage = headersList.get('accept-language') ?? undefined;
      const cookieHeader = headersList.get('cookie') ?? undefined;

      const locale = parseLocaleCookie(cookieHeader)
        ?? parseAcceptLanguage(acceptLanguage);

      return { locale };
    },
  });
}

export { handler as GET, handler as POST };
```

[Inference] If you use Next.js i18n routing (`/fr/dashboard`, `/en/dashboard`), the locale segment can be extracted from the URL pathname and passed into context as a higher-priority source than the `Accept-Language` header. Verify against your Next.js version's i18n documentation.

---

### Locale and Date / Number Formatting

Pass locale into `Intl` APIs for consistent server-side formatting:

```ts
// lib/format.ts
export function formatCurrency(
  amountUsd: number,
  locale: string,
  currency = 'USD'
): string {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
  }).format(amountUsd);
}

export function formatDate(
  date: Date,
  locale: string,
  options: Intl.DateTimeFormatOptions = { dateStyle: 'medium' }
): string {
  return new Intl.DateTimeFormat(locale, options).format(date);
}

export function formatRelativeTime(
  date: Date,
  locale: string
): string {
  const now = Date.now();
  const diffMs = date.getTime() - now;
  const diffSeconds = Math.round(diffMs / 1000);

  const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' });

  if (Math.abs(diffSeconds) < 60) return rtf.format(diffSeconds, 'second');
  if (Math.abs(diffSeconds) < 3600) return rtf.format(Math.round(diffSeconds / 60), 'minute');
  if (Math.abs(diffSeconds) < 86400) return rtf.format(Math.round(diffSeconds / 3600), 'hour');
  return rtf.format(Math.round(diffSeconds / 86400), 'day');
}
```

Usage in a procedure:

```ts
getInvoice: protectedProcedure
  .input(z.object({ invoiceId: z.string() }))
  .query(async ({ input, ctx }) => {
    const invoice = await db.invoice.findFirst({
      where: { id: input.invoiceId, userId: ctx.user.id },
    });

    if (!invoice) {
      throw new TRPCError({ code: 'NOT_FOUND' });
    }

    return {
      id: invoice.id,
      total: formatCurrency(invoice.totalUsd, ctx.locale),
      issuedAt: formatDate(invoice.issuedAt, ctx.locale),
      due: formatRelativeTime(invoice.dueAt, ctx.locale),
    };
  }),
```

[Inference] `Intl` API availability and behavior are consistent in Node.js 18+ with full ICU data. Older Node.js versions or builds with small-icu may produce incomplete or incorrect locale formatting for non-Latin locales. Verify your runtime's ICU configuration.

---

### Testing Locale-Dependent Procedures

```ts
// tests/locale.test.ts
import { createCallerFactory } from '@trpc/server';
import { appRouter } from '../server/router';

const createCaller = createCallerFactory(appRouter);

describe('locale in context', () => {
  it('formats currency according to locale', async () => {
    const caller = createCaller({
      user: mockUser,
      locale: 'de-DE',
    });

    const invoice = await caller.invoices.get({ invoiceId: 'inv_001' });

    // German locale uses comma as decimal separator
    expect(invoice.total).toMatch(/[0-9]+,[0-9]+/);
  });

  it('falls back to en-US for unsupported locale', async () => {
    const caller = createCaller({
      user: mockUser,
      locale: 'en-US', // resolved by parseAcceptLanguage fallback
    });

    const invoice = await caller.invoices.get({ invoiceId: 'inv_001' });
    expect(invoice.total).toMatch(/^\$/);
  });
});
```

---

### Locale Responsibility: Server vs. Client

A deliberate architectural choice affects how much locale logic lives in tRPC:

| Responsibility | Server-side locale | Client-side locale |
| --- | --- | --- |
| Translation | tRPC returns translated strings | tRPC returns string keys; client translates |
| Date formatting | `Intl` in procedure | Client formats raw `Date` |
| Currency | `Intl` in procedure | Client formats raw number |
| Error messages | Localized in `TRPCError.message` | Client maps error codes to strings |
| Complexity location | Server procedures | Client i18n library (e.g., `react-i18next`) |
| Caching | Harder — responses vary by locale | Easier — responses are locale-neutral |

[Inference] Server-side locale formatting simplifies clients that are not JavaScript (native apps, third-party integrations). Client-side formatting allows better caching and reduces server response variation. Most web applications with a React frontend benefit from client-side formatting — server-side locale is most valuable when the client is thin or non-JS.

---

**Conclusion:**
Locale belongs in tRPC context because it is a per-request property derived from the incoming HTTP request and user preferences. The `createContext` function is the correct place to resolve it, using a priority chain from user database preference down to application default. Once in context, locale is available to all procedures without explicit input plumbing. Whether the server uses that locale for formatting or delegates formatting to the client is an architectural choice — both are valid, and the right answer depends on client diversity and caching requirements.

**Next Steps:**

- Decide server-side vs. client-side formatting responsibility early — it affects response shape and caching strategy
- Validate supported locales against your Node.js runtime's ICU data before deploying non-Latin locale formatting
- Add locale to structured logs alongside `userId` and `path` for debugging locale-specific issues in production