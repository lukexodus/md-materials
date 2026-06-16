## Integrating NextAuth with tRPC

NextAuth (Auth.js) handles session management, OAuth providers, and credential-based login. Integrating it with tRPC means making the authenticated session available inside tRPC context, so procedures can access the current user without redundant session fetches.

---

### Prerequisites and Setup

This guide assumes:

- Next.js project (Pages Router or App Router)
- `next-auth` installed and configured with at least one provider
- `@trpc/server`, `@trpc/client`, `@trpc/next` installed

```bash
npm install next-auth @trpc/server @trpc/client @trpc/next @tanstack/react-query zod
```

---

### NextAuth Configuration

Define your NextAuth options in a shared location so they can be reused when fetching sessions server-side.

```ts
// server/auth.ts
import { NextAuthOptions } from 'next-auth';
import GithubProvider from 'next-auth/providers/github';
import { PrismaAdapter } from '@next-auth/prisma-adapter';
import { db } from './db';

export const authOptions: NextAuthOptions = {
  adapter: PrismaAdapter(db),
  providers: [
    GithubProvider({
      clientId: process.env.GITHUB_ID!,
      clientSecret: process.env.GITHUB_SECRET!,
    }),
  ],
  callbacks: {
    session({ session, user }) {
      // Attach database user id to the session object
      if (session.user) {
        session.user.id = user.id;
      }
      return session;
    },
  },
};
```

**Key Points:**

- Exporting `authOptions` separately from the API route allows `getServerSession(authOptions)` to be called anywhere on the server, including tRPC context
- The `session` callback is where you attach extra fields (like `user.id`) that aren't included by default

---

### NextAuth API Route

```ts
// pages/api/auth/[...nextauth].ts
import NextAuth from 'next-auth';
import { authOptions } from '../../../server/auth';

export default NextAuth(authOptions);
```

For the App Router:

```ts
// app/api/auth/[...nextauth]/route.ts
import NextAuth from 'next-auth';
import { authOptions } from '../../../../server/auth';

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
```

---

### Building the tRPC Context with NextAuth Session

The context creation function is where the session is fetched and attached. All procedures then receive it via `ctx`.

```ts
// server/context.ts
import { getServerSession } from 'next-auth';
import { authOptions } from './auth';
import { db } from './db';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getServerSession(req, res, authOptions);

  return {
    session,
    user: session?.user ?? null,
    db,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points:**

- `getServerSession` is preferred over `getSession` for server-side usage — it reads the session directly without an extra HTTP round-trip [Inference: based on NextAuth documentation conventions; verify against your NextAuth version]
- The `user` shortcut on context (`session?.user ?? null`) simplifies access in procedures

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
  if (!ctx.session || !ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  return next({
    ctx: {
      ...ctx,
      // Narrow the type: user is guaranteed non-null past this point
      session: ctx.session,
      user: ctx.user,
    },
  });
});
```

**Key Points:**

- `protectedProcedure` narrows `ctx.user` to non-null, so TypeScript will not require null-checks inside procedures that use it
- Type narrowing behavior depends on your TypeScript configuration and tRPC version [Inference]

---

### tRPC API Route

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

For the App Router, use the fetch adapter:

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
    createContext: () => createContext({ req } as any),
  });

export { handler as GET, handler as POST };
```

---

### Using Session in Procedures

```ts
// server/routers/user.ts
import { router, protectedProcedure, publicProcedure } from '../trpc';
import { TRPCError } from '@trpc/server';

export const userRouter = router({
  // Public: no session required
  hello: publicProcedure.query(() => {
    return { message: 'Hello, world.' };
  }),

  // Protected: session is guaranteed by middleware
  me: protectedProcedure.query(({ ctx }) => {
    return {
      id: ctx.user.id,
      name: ctx.user.name,
      email: ctx.user.email,
    };
  }),

  // Protected with per-resource check
  updateBio: protectedProcedure
    .input(z.object({ bio: z.string().max(300) }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.user.update({
        where: { id: ctx.user.id },
        data: { bio: input.bio },
      });
    }),
});
```

---

### Client-Side Setup

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

tsx

```
// pages/_app.tsx
import { SessionProvider } from 'next-auth/react';
import { trpc } from '../utils/trpc';
import type { AppProps } from 'next/app';

function App({ Component, pageProps: { session, ...pageProps } }: AppProps) {
  return (
    <SessionProvider session={session}>
      <Component {...pageProps} />
    </SessionProvider>
  );
}

export default trpc.withTRPC(App);
```

**Key Points:**

- `SessionProvider` is needed for client-side `useSession()` hooks, but tRPC context reads the session server-side via `getServerSession` — the two are independent
- Passing `session` from `pageProps` to `SessionProvider` avoids an extra client-side fetch on initial load

---

### Session Shape Augmentation

By default, `session.user` only contains `name`, `email`, and `image`. To add fields like `id` or `role`, augment the NextAuth types.

```ts
// types/next-auth.d.ts
import { DefaultSession } from 'next-auth';

declare module 'next-auth' {
  interface Session {
    user: {
      id: string;
      role: string;
    } & DefaultSession['user'];
  }

  interface User {
    role: string;
  }
}
```

```ts
// server/auth.ts — update session callback
callbacks: {
  session({ session, user }) {
    if (session.user) {
      session.user.id = user.id;
      session.user.role = user.role;
    }
    return session;
  },
},
```

**Key Points:**

- Without this augmentation, TypeScript will not recognize `session.user.id` as a valid field
- The `User` interface augmentation tells NextAuth's adapter that the database user has a `role` field

---

### Full Request Flow Diagram

<svg viewBox="0 0 720 500" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="720" height="500" fill="#0f1117" rx="12"/>
<text x="360" y="34" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">NextAuth + tRPC Request Flow</text>
<!-- Client -->
<rect x="30" y="60" width="130" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="95" y="87" text-anchor="middle" fill="#94a3b8">React Client</text>
<!-- Arrow: client to tRPC API -->
<line x1="160" y1="82" x2="240" y2="82" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<text x="200" y="75" text-anchor="middle" fill="#64748b" font-size="10">HTTP</text>
<!-- tRPC API Route -->
<rect x="240" y="60" width="150" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="315" y="87" text-anchor="middle" fill="#94a3b8">/api/trpc/[trpc]</text>
<!-- Arrow down to createContext -->
<line x1="315" y1="104" x2="315" y2="140" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- createContext -->
<rect x="220" y="140" width="190" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="315" y="167" text-anchor="middle" fill="#94a3b8">createContext()</text>
<!-- Arrow: createContext to getServerSession -->
<line x1="315" y1="184" x2="315" y2="220" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- getServerSession -->
<rect x="210" y="220" width="210" height="44" rx="8" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
<text x="315" y="247" text-anchor="middle" fill="#93c5fd">getServerSession()</text>
<!-- Arrow: getServerSession to NextAuth -->
<line x1="420" y1="242" x2="500" y2="242" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#ablue)"/>
<!-- NextAuth / Session Store -->
<rect x="500" y="220" width="150" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="575" y="240" text-anchor="middle" fill="#94a3b8">NextAuth</text>
<text x="575" y="256" text-anchor="middle" fill="#94a3b8">Session Store</text>
<!-- Return arrow -->
<line x1="500" y1="256" x2="420" y2="256" stroke="#22c55e" stroke-width="1.5" marker-end="url(#agreen)"/>
<text x="460" y="272" text-anchor="middle" fill="#86efac" font-size="10">session | null</text>
<!-- Arrow down: session into ctx -->
<line x1="315" y1="264" x2="315" y2="300" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- ctx object -->
<rect x="210" y="300" width="210" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="315" y="322" text-anchor="middle" fill="#94a3b8">ctx =</text>
<text x="315" y="340" text-anchor="middle" fill="#64748b" font-size="11">{ session, user, db }</text>
<!-- Arrow down to middleware -->
<line x1="315" y1="354" x2="315" y2="390" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Middleware -->
<rect x="190" y="390" width="130" height="44" rx="8" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
<text x="255" y="410" text-anchor="middle" fill="#93c5fd">Auth</text>
<text x="255" y="426" text-anchor="middle" fill="#93c5fd">Middleware</text>
<!-- Procedure -->
<rect x="360" y="390" width="130" height="44" rx="8" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
<text x="425" y="410" text-anchor="middle" fill="#86efac">Procedure</text>
<text x="425" y="426" text-anchor="middle" fill="#86efac">Handler</text>
<!-- Arrow middleware to procedure -->
<line x1="320" y1="412" x2="360" y2="412" stroke="#22c55e" stroke-width="1.5" marker-end="url(#agreen)"/>
<!-- UNAUTHORIZED branch -->
<line x1="255" y1="434" x2="255" y2="468" stroke="#ef4444" stroke-width="1.5" marker-end="url(#ared)"/>
<text x="255" y="482" text-anchor="middle" fill="#fca5a5" font-size="11">UNAUTHORIZED</text>
<!-- Response from procedure -->
<line x1="425" y1="434" x2="425" y2="468" stroke="#22c55e" stroke-width="1.5" marker-end="url(#agreen)"/>
<text x="425" y="482" text-anchor="middle" fill="#86efac" font-size="11">Response</text>
<defs>
<marker id="a1" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#475569"/>
</marker>
<marker id="ablue" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#3b82f6"/>
</marker>
<marker id="agreen" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#22c55e"/>
</marker>
<marker id="ared" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#ef4444"/>
</marker>
</defs>
</svg>

---

### Server-Side Session Access in Pages

For SSR pages that also call tRPC procedures, you can pass the session into the tRPC caller directly.

```ts
// pages/dashboard.tsx
import { getServerSideProps } from 'next';
import { getServerSession } from 'next-auth';
import { authOptions } from '../server/auth';
import { createCaller } from '../server/routers/_app';
import { createContext } from '../server/context';

export const getServerSideProps = async ({ req, res }) => {
  const session = await getServerSession(req, res, authOptions);

  if (!session) {
    return { redirect: { destination: '/login', permanent: false } };
  }

  const ctx = await createContext({ req, res });
  const caller = createCaller(ctx);
  const me = await caller.user.me();

  return { props: { me } };
};
```

**Key Points:**

- `createCaller` bypasses HTTP and calls procedures directly on the server — useful in `getServerSideProps` and React Server Components
- The session is fetched once and shared between the redirect guard and the tRPC caller via the shared context

---

### Common Issues

| Problem | Likely Cause | Resolution |
| --- | --- | --- |
| `ctx.user` is always `null` | `getServerSession` not receiving correct `req`/`res` | Confirm you are passing `req` and `res` from the Next.js handler, not reconstructed objects |
| `session.user.id` TypeScript error | Missing module augmentation | Add `next-auth.d.ts` with `Session` interface extension |
| Session works in browser but not in tRPC | Using `getSession` (client) instead of `getServerSession` | Replace with `getServerSession(req, res, authOptions)` |
| Infinite loop on protected route | Redirect in `getServerSideProps` not exiting early | Return `redirect` before calling any tRPC procedures |

---

**Next Steps:** Handling token-based authentication (JWT) in tRPC context — for API consumers that do not use cookie-based sessions.