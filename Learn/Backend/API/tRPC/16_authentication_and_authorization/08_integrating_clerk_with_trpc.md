## Integrating Clerk with tRPC

Clerk is an authentication platform that provides hosted sign-in/sign-up UI, session management, and user management. Unlike NextAuth, Clerk manages sessions externally and exposes them via SDK helpers. Integration with tRPC means reading the Clerk session on the server inside `createContext` and making the authenticated user available to all procedures.

---

### Prerequisites and Setup

```bash
npm install @clerk/nextjs @trpc/server @trpc/client @trpc/next @tanstack/react-query zod
```

Required environment variables:

env

```
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...
```

---

### Clerk Middleware (Next.js App Router)

Clerk requires a middleware file at the project root to protect routes and inject session data into requests.

```ts
// middleware.ts
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server';

const isPublicRoute = createRouteMatcher([
  '/sign-in(.*)',
  '/sign-up(.*)',
  '/api/trpc(.*)', // tRPC handles its own auth internally
]);

export default clerkMiddleware((auth, req) => {
  if (!isPublicRoute(req)) {
    auth().protect();
  }
});

export const config = {
  matcher: ['/((?!_next|.*\\..*).*)'],
};
```

**Key Points:**

- Marking `/api/trpc` as a public route at the middleware level lets tRPC handle authorization itself, rather than redirecting unauthenticated API calls to a sign-in page
- `auth().protect()` on non-public routes redirects unauthenticated users automatically — behavior is handled by Clerk's SDK and may vary across versions [Unverified: verify against your installed `@clerk/nextjs` version]

---

### Building the tRPC Context with Clerk

```ts
// server/context.ts
import { auth } from '@clerk/nextjs/server';
import { db } from './db';

export async function createContext() {
  const { userId, sessionId, orgId } = auth();

  return {
    userId,
    sessionId,
    orgId,
    db,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points:**

- Clerk's `auth()` helper (App Router) reads session data from the request headers injected by Clerk middleware — no `req`/`res` objects need to be passed manually
- `userId` is `null` when no session is present, making it straightforward to gate access
- `orgId` is available when Clerk Organizations are enabled; it is `null` otherwise

For the Pages Router, use `getAuth` instead:

```ts
// server/context.ts (Pages Router)
import { getAuth } from '@clerk/nextjs/server';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { db } from './db';

export async function createContext({ req }: CreateNextContextOptions) {
  const { userId, sessionId, orgId } = getAuth(req);

  return {
    userId,
    sessionId,
    orgId,
    db,
  };
}
```

---

### Initializing tRPC with the Context

```ts
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;

export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.userId) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  return next({
    ctx: {
      ...ctx,
      userId: ctx.userId, // narrowed to string (non-null)
    },
  });
});
```

**Key Points:**

- The narrowing of `userId` from `string | null` to `string` means TypeScript will not require null-checks inside any procedure built on `protectedProcedure`
- Type narrowing depends on your TypeScript configuration and tRPC version [Inference]

---

### tRPC API Route

**App Router:**

```ts
// app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { appRouter } from '../../../../server/routers/_app';
import { createContext } from '../../../../server/context';
import type { NextRequest } from 'next/server';

const handler = (req: NextRequest) =>
  fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext,
  });

export { handler as GET, handler as POST };
```

**Pages Router:**

```ts
// pages/api/trpc/[trpc].ts
import { createNextApiHandler } from '@trpc/server/adapters/next';
import { appRouter } from '../../../server/routers/_app';
import { createContext } from '../../../server/context';

export default createNextApiHandler({
  router: appRouter,
  createContext,
});
```

---

### Wrapping the App with ClerkProvider

tsx

```
// app/layout.tsx (App Router)
import { ClerkProvider } from '@clerk/nextjs';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body>{children}</body>
      </html>
    </ClerkProvider>
  );
}
```

tsx

```
// pages/_app.tsx (Pages Router)
import { ClerkProvider } from '@clerk/nextjs';
import { trpc } from '../utils/trpc';
import type { AppProps } from 'next/app';

function App({ Component, pageProps }: AppProps) {
  return (
    <ClerkProvider {...pageProps}>
      <Component {...pageProps} />
    </ClerkProvider>
  );
}

export default trpc.withTRPC(App);
```

---

### tRPC Client Setup

```ts
// utils/trpc.ts
import { createTRPCNext } from '@trpc/next';
import { httpBatchLink } from '@trpc/client';
import type { AppRouter } from '../server/routers/_app';

export const trpc = createTRPCNext<AppRouter>({
  config() {
    return {
      links: [
        httpBatchLink({
          url: '/api/trpc',
        }),
      ],
    };
  },
});
```

**Key Points:**

- Clerk automatically attaches session tokens to outgoing requests via cookies when `ClerkProvider` is present — no manual token injection in tRPC links is required for same-origin requests [Inference: based on Clerk's documented cookie-based session model; verify for your deployment setup]
- For cross-origin deployments, you may need to attach the session token manually as a header (see below)

---

### Cross-Origin Token Attachment

When the tRPC API and the frontend are on different origins, cookies may not be sent automatically. In that case, attach the Clerk session token explicitly.

```ts
// utils/trpc.ts
import { createTRPCNext } from '@trpc/next';
import { httpBatchLink } from '@trpc/client';
import { useAuth } from '@clerk/nextjs';
import type { AppRouter } from '../server/routers/_app';

function getBaseUrl() {
  if (typeof window !== 'undefined') return '';
  return process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3000';
}

export const trpc = createTRPCNext<AppRouter>({
  config() {
    return {
      links: [
        httpBatchLink({
          url: `${getBaseUrl()}/api/trpc`,
          async headers() {
            const { getToken } = useAuth();
            const token = await getToken();
            return token ? { Authorization: `Bearer ${token}` } : {};
          },
        }),
      ],
    };
  },
});
```

Then read the token in context:

```ts
// server/context.ts — cross-origin variant
import { verifyToken } from '@clerk/nextjs/server';

export async function createContext({ req }: CreateNextContextOptions) {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];

  if (!token) return { userId: null, db };

  const payload = await verifyToken(token, {
    secretKey: process.env.CLERK_SECRET_KEY!,
  });

  return {
    userId: payload.sub,
    db,
  };
}
```

**Key Points:**

- `useAuth` is a React hook and cannot be called inside a non-component config function directly — the pattern above is illustrative; in practice, wrap the tRPC client setup to call `getToken` per-request [Inference]
- `verifyToken` validates the JWT locally using Clerk's secret key without a network round-trip [Inference: based on standard JWT verification patterns; behavior may vary]

---

### Using Clerk Data in Procedures

```ts
// server/routers/user.ts
import { router, protectedProcedure, publicProcedure } from '../trpc';
import { clerkClient } from '@clerk/nextjs/server';
import { z } from 'zod';

export const userRouter = router({
  me: protectedProcedure.query(async ({ ctx }) => {
    // Fetch full Clerk user object by userId from context
    const user = await clerkClient.users.getUser(ctx.userId);

    return {
      id: user.id,
      email: user.emailAddresses[0]?.emailAddress,
      name: `${user.firstName} ${user.lastName}`,
      imageUrl: user.imageUrl,
    };
  }),

  updateUsername: protectedProcedure
    .input(z.object({ username: z.string().min(3).max(32) }))
    .mutation(async ({ ctx, input }) => {
      return clerkClient.users.updateUser(ctx.userId, {
        username: input.username,
      });
    }),
});
```

**Key Points:**

- `clerkClient` is Clerk's server-side SDK for reading and mutating user data — it makes network calls to Clerk's API and may add latency [Inference]
- Cache or store frequently accessed Clerk user fields in your own database if per-request `clerkClient.users.getUser` calls become a bottleneck [Inference]

---

### Organization-Based Authorization

When Clerk Organizations are used, `orgId` and `orgRole` are available in the session.

```ts
// server/trpc.ts — org-scoped procedure
export const orgAdminProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.userId) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  if (!ctx.orgId) {
    throw new TRPCError({
      code: 'FORBIDDEN',
      message: 'No active organization.',
    });
  }

  return next({
    ctx: {
      ...ctx,
      userId: ctx.userId,
      orgId: ctx.orgId,
    },
  });
});
```

```ts
// server/context.ts — include orgRole
export async function createContext() {
  const { userId, sessionId, orgId, orgRole } = auth();

  return { userId, sessionId, orgId, orgRole, db };
}
```

```ts
// Procedure that checks org role
deleteOrgResource: orgAdminProcedure
  .input(z.object({ resourceId: z.string() }))
  .mutation(async ({ ctx, input }) => {
    if (ctx.orgRole !== 'org:admin') {
      throw new TRPCError({ code: 'FORBIDDEN' });
    }

    return ctx.db.resource.delete({
      where: { id: input.resourceId, orgId: ctx.orgId },
    });
  }),
```

---

### Full Integration Flow Diagram

<svg viewBox="0 0 740 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="740" height="520" fill="#0f1117" rx="12"/>
<text x="370" y="34" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Clerk + tRPC Integration Flow</text>
<!-- Client -->
<rect x="30" y="70" width="130" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="95" y="97" text-anchor="middle" fill="#94a3b8">React Client</text>
<!-- Arrow to Clerk Middleware -->
<line x1="160" y1="92" x2="240" y2="92" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<text x="200" y="84" text-anchor="middle" fill="#64748b" font-size="10">HTTP + cookie</text>
<!-- Clerk Middleware -->
<rect x="240" y="70" width="160" height="44" rx="8" fill="#1e1a3a" stroke="#7c3aed" stroke-width="1.5"/>
<text x="320" y="90" text-anchor="middle" fill="#c4b5fd">Clerk Middleware</text>
<text x="320" y="106" text-anchor="middle" fill="#a78bfa" font-size="10">middleware.ts</text>
<!-- Arrow down -->
<line x1="320" y1="114" x2="320" y2="150" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- tRPC API Route -->
<rect x="230" y="150" width="180" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="320" y="177" text-anchor="middle" fill="#94a3b8">/api/trpc/[trpc]</text>
<!-- Arrow down -->
<line x1="320" y1="194" x2="320" y2="230" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- createContext -->
<rect x="225" y="230" width="190" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="320" y="257" text-anchor="middle" fill="#94a3b8">createContext()</text>
<!-- Arrow to auth() -->
<line x1="320" y1="274" x2="320" y2="310" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- auth() -->
<rect x="215" y="310" width="210" height="44" rx="8" fill="#1e1a3a" stroke="#7c3aed" stroke-width="1.5"/>
<text x="320" y="330" text-anchor="middle" fill="#c4b5fd">auth() / getAuth()</text>
<text x="320" y="346" text-anchor="middle" fill="#a78bfa" font-size="10">reads injected session headers</text>
<!-- Arrow to Clerk API -->
<line x1="425" y1="332" x2="510" y2="332" stroke="#7c3aed" stroke-width="1.5" marker-end="url(#apurple)"/>
<text x="467" y="324" text-anchor="middle" fill="#a78bfa" font-size="10">optional</text>
<!-- Clerk API -->
<rect x="510" y="310" width="160" height="44" rx="8" fill="#1e1a3a" stroke="#7c3aed" stroke-width="1.5"/>
<text x="590" y="330" text-anchor="middle" fill="#c4b5fd">Clerk API</text>
<text x="590" y="346" text-anchor="middle" fill="#a78bfa" font-size="10">clerkClient.users.\*</text>
<!-- return arrow -->
<line x1="510" y1="348" x2="425" y2="348" stroke="#22c55e" stroke-width="1.5" marker-end="url(#agreen)"/>
<text x="467" y="364" text-anchor="middle" fill="#86efac" font-size="10">userId, orgId…</text>
<!-- Arrow down to ctx -->
<line x1="320" y1="354" x2="320" y2="390" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- ctx -->
<rect x="215" y="390" width="210" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="320" y="412" text-anchor="middle" fill="#94a3b8">ctx =</text>
<text x="320" y="430" text-anchor="middle" fill="#64748b" font-size="11">{ userId, orgId, orgRole, db }</text>
<!-- Arrow to middleware -->
<line x1="270" y1="444" x2="200" y2="478" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Arrow to procedure -->
<line x1="370" y1="444" x2="440" y2="478" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Auth middleware box -->
<rect x="120" y="478" width="130" height="36" rx="8" fill="#1e1a3a" stroke="#7c3aed" stroke-width="1.5"/>
<text x="185" y="500" text-anchor="middle" fill="#c4b5fd">protectedProcedure</text>
<!-- Procedure box -->
<rect x="390" y="478" width="130" height="36" rx="8" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
<text x="455" y="500" text-anchor="middle" fill="#86efac">Handler / Response</text>
<defs>
<marker id="a1" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#475569"/>
</marker>
<marker id="apurple" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#7c3aed"/>
</marker>
<marker id="agreen" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#22c55e"/>
</marker>
</defs>
</svg>

---

### Clerk vs NextAuth in tRPC Context

| Concern | Clerk | NextAuth |
| --- | --- | --- |
| Session source | Injected headers via middleware | Cookie read by `getServerSession` |
| Context setup | `auth()` — no args needed (App Router) | `getServerSession(req, res, authOptions)` |
| User data | `clerkClient.users.getUser(userId)` | Embedded in session object |
| Type augmentation | Not required — `userId` is a plain string | Required for `session.user.id` |
| Org/team support | Built-in via `orgId`, `orgRole` | Manual implementation |
| Hosted UI | Provided by Clerk | DIY or third-party |

---

### Common Issues

| Problem                               | Likely Cause                               | Resolution                                                                        |
| ------------------------------------- | ------------------------------------------ | --------------------------------------------------------------------------------- |
| `userId` always `null`                | Clerk middleware not running on the route  | Check `matcher` in `middleware.ts` covers the request path                        |
| `auth is not a function` error        | Mixing App Router and Pages Router imports | Use `auth` from `@clerk/nextjs/server` for App Router; `getAuth` for Pages Router |
| Session not available in tRPC context | `ClerkProvider` missing from layout        | Wrap root layout or `_app.tsx` with `ClerkProvider`                               |
| `clerkClient` rate limits             | Fetching full user per request             | Cache user data in your own DB after first fetch                                  |
| Cross-origin requests unauthenticated | Cookies not sent across origins            | Use token-based auth with `Authorization` header                                  |

---

**Next Steps:** JWT-based authentication in tRPC context — for stateless API consumers, mobile clients, or microservice-to-microservice calls that do not rely on cookie sessions.