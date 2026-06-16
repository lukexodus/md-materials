## Injecting Auth Session into Context

Injecting an auth session into tRPC context makes the current user's identity available to all procedures through `ctx`, enabling authentication checks and user-specific logic without re-fetching the session inside each handler.

---

### Why Inject Session via Context?

Session resolution typically involves reading a cookie, verifying a token, or querying a session store — operations that are request-scoped and should happen once per request, not once per procedure.

**Key Points**
- Session data is resolved at the context layer, before any procedure runs.
- Procedures receive either a populated `session` or `null`/`undefined` and handle it accordingly.
- The session shape is typed through the context type, giving procedures full type safety.

---

### Session Shape

Before writing context code, define what a session looks like. This is typically determined by your auth library.

```typescript
// types/session.ts
export type AuthUser = {
  id: string;
  email: string;
  role: 'admin' | 'user';
};

export type Session = {
  user: AuthUser;
} | null;
```

`null` represents an unauthenticated request.

---

### Pattern 1 — NextAuth.js (next-auth)

NextAuth stores sessions server-side and exposes them via `getServerSession`.

#### Context Setup

```typescript
// server/context.ts
import { getServerSession } from 'next-auth';
import { authOptions } from '../pages/api/auth/[...nextauth]';
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getServerSession(req, res, authOptions);

  return {
    session,
    req,
    res,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points**
- `session` will be `null` if the user is not signed in.
- `getServerSession` requires `req`, `res`, and your `authOptions` — all available at the context layer.

#### Using Session in a Procedure

```typescript
export const appRouter = router({
  me: publicProcedure.query(({ ctx }) => {
    if (!ctx.session) {
      throw new TRPCError({ code: 'UNAUTHORIZED' });
    }
    return ctx.session.user;
  }),
});
```

---

### Pattern 2 — JWT in Authorization Header

When using stateless JWT authentication (e.g., a custom backend or a mobile client), the token arrives in the `Authorization` header.

#### Context Setup

```typescript
// server/context.ts
import { verifyJwt } from '../lib/jwt';
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ')
    ? authHeader.slice(7)
    : null;

  const user = token ? await verifyJwt(token) : null;

  return {
    user,
    req,
    res,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points**
- `verifyJwt` should return `null` (or throw and be caught) on invalid or expired tokens, not propagate the error uncaught.
- [Inference] If `verifyJwt` throws an unhandled error, `createContext` may fail before any procedure runs. Adapter behavior in this case may vary.

#### Example `verifyJwt` Implementation

```typescript
// lib/jwt.ts
import jwt from 'jsonwebtoken';
import { type AuthUser } from '../types/session';

export async function verifyJwt(token: string): Promise<AuthUser | null> {
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as AuthUser;
    return payload;
  } catch {
    return null;
  }
}
```

---

### Pattern 3 — Cookie-Based Sessions (e.g., iron-session)

`iron-session` stores encrypted session data directly in a cookie, without a session store.

#### Context Setup

```typescript
// server/context.ts
import { getIronSession } from 'iron-session';
import { sessionOptions } from '../lib/session';
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';
import { type AuthUser } from '../types/session';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getIronSession<{ user?: AuthUser }>(
    req,
    res,
    sessionOptions
  );

  return {
    session,
    req,
    res,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

```typescript
// lib/session.ts
import { type SessionOptions } from 'iron-session';

export const sessionOptions: SessionOptions = {
  cookieName: 'app_session',
  password: process.env.SESSION_SECRET!,
  cookieOptions: {
    secure: process.env.NODE_ENV === 'production',
  },
};
```

#### Using in a Procedure

```typescript
me: publicProcedure.query(({ ctx }) => {
  if (!ctx.session.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return ctx.session.user;
}),
```

---

### Narrowing the Session Type with a Protected Procedure

Checking `if (!ctx.session)` inside every procedure is repetitive. A protected procedure middleware can perform the check once and narrow the type.

```typescript
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import { type Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;

export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.session || !ctx.session.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  return next({
    ctx: {
      ...ctx,
      session: ctx.session,
    },
  });
});
```

**Key Points**
- `protectedProcedure` replaces `publicProcedure` for routes that require authentication.
- After the middleware runs, `ctx.session` is typed as non-null inside the handler — the null branch has been eliminated structurally.
- [Inference] TypeScript's narrowing here depends on how the context and middleware types are structured. Actual inference behavior may vary depending on your tRPC version and TypeScript configuration.

#### Usage

```typescript
export const appRouter = router({
  dashboard: protectedProcedure.query(({ ctx }) => {
    // ctx.session.user is non-null here
    return { welcome: `Hello, ${ctx.session.user.email}` };
  }),
});
```

---

### Combining Session and Database Client

A common pattern is to attach both the session and the database client to context, then use both in protected procedures.

```typescript
export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getServerSession(req, res, authOptions);

  return {
    session,
    prisma,
    req,
    res,
  };
}
```

```typescript
myProfile: protectedProcedure.query(async ({ ctx }) => {
  return await ctx.prisma.user.findUnique({
    where: { id: ctx.session.user.id },
  });
}),
```

---

### Testing with a Mocked Session

Using the inner context pattern allows session data to be injected directly in tests without going through HTTP.

```typescript
// server/context.ts
export type InnerContext = {
  session: Session;
  prisma: PrismaClient;
};

export async function createInnerContext(opts: InnerContext) {
  return opts;
}

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getServerSession(req, res, authOptions);

  return {
    ...(await createInnerContext({ session, prisma })),
    req,
    res,
  };
}
```

In a test:

```typescript
test('dashboard returns welcome message', async () => {
  const ctx = await createInnerContext({
    session: { user: { id: '1', email: 'alice@example.com', role: 'user' } },
    prisma: mockPrisma,
  });

  const caller = appRouter.createCaller(ctx);
  const result = await caller.dashboard();

  expect(result.welcome).toBe('Hello, alice@example.com');
});
```

[Inference] `createCaller` bypasses HTTP and invokes procedures directly with a provided context. This is the recommended approach for unit testing tRPC procedures, but behavior depends on your tRPC version.

---

### Session Security Considerations

These are general points, not guarantees:

- Always verify tokens server-side. Do not trust client-supplied user IDs without validation.
- [Inference] Storing sensitive data (e.g., raw passwords, full PII) in the session object is generally discouraged, as session data may be logged or serialized in unexpected places depending on your setup.
- Treat `session` as `null` until proven otherwise — defensive checks in middleware are preferable to checks scattered across procedures.