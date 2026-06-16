## Inner and Outer Context Pattern

The inner and outer context pattern splits context creation into two functions with distinct responsibilities: an outer function that handles HTTP-specific concerns, and an inner function that holds the core application context. This separation improves testability and keeps concerns clearly bounded.

---

### The Problem It Solves

A standard `createContext` function receives raw HTTP objects (`req`, `res`) and does everything in one place — parsing headers, resolving sessions, attaching database clients. This creates two friction points:

- **Testing:** Procedures cannot be tested without constructing or mocking HTTP request objects.
- **Coupling:** Business-relevant context (user, database) is entangled with transport-layer objects (`req`, `res`).

The inner/outer pattern addresses both.

---

### Structure Overview

```
createContext (outer)
│
├── Receives: req, res (adapter-specific)
├── Extracts: token, session, headers
│
└── calls createInnerContext (inner)
    │
    ├── Receives: derived data only (user, session)
    ├── Attaches: prisma, redis, logger, etc.
    └── Returns: the core context object
```

The outer context handles the HTTP boundary. The inner context holds everything procedures actually use.

---

### Basic Implementation

#### Inner Context

```typescript
// server/context.ts
import { prisma } from '../lib/prisma';
import { type Session } from '../types/session';

type CreateInnerContextOptions = {
  session: Session;
};

export async function createInnerContext(opts: CreateInnerContextOptions) {
  return {
    session: opts.session,
    prisma,
  };
}

export type InnerContext = Awaited<ReturnType<typeof createInnerContext>>;
```

**Key Points**

- `createInnerContext` takes plain data — no `req`, no `res`.
- It can be called from anywhere: the outer context, a test, a script.
- All fields relevant to procedures live here.

#### Outer Context

```typescript
// server/context.ts (continued)
import { getServerSession } from 'next-auth';
import { authOptions } from '../pages/api/auth/[...nextauth]';
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getServerSession(req, res, authOptions);

  return {
    ...(await createInnerContext({ session })),
    req,
    res,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points**

- The outer context resolves session from HTTP, then delegates to the inner context.
- `req` and `res` are spread in at the outer level — procedures that need them still have access, but the inner context does not depend on them.

---

### Why This Enables Testing

Without this pattern, testing a procedure requires constructing a mock HTTP request to satisfy `createContext`. With it, tests call `createInnerContext` directly with plain data.

#### Without the Pattern

```typescript
// Requires a mock HTTP request object — awkward and fragile
const ctx = await createContext({
  req: { headers: { authorization: 'Bearer test-token' } } as any,
  res: {} as any,
});
```

#### With the Pattern

```typescript
// Clean — no HTTP objects needed
const ctx = await createInnerContext({
  session: {
    user: { id: '1', email: 'alice@example.com', role: 'user' },
  },
});

const caller = appRouter.createCaller(ctx);
const result = await caller.me();
```

[Inference] This is one of the more significant practical benefits of the pattern. The actual reduction in test complexity depends on how much your procedures rely on `req`/`res` directly.

---

### Extending the Pattern: Multiple Extraction Steps

The outer context can perform several extraction steps before calling the inner context, keeping each concern explicit.

```typescript
export async function createContext({ req, res }: CreateNextContextOptions) {
  // Step 1: Extract raw token
  const token = req.headers.authorization?.split(' ')[1] ?? null;

  // Step 2: Resolve user from token
  const user = token ? await verifyJwt(token) : null;

  // Step 3: Resolve request metadata
  const requestId = req.headers['x-request-id'] ?? crypto.randomUUID();

  // Step 4: Build inner context from derived data
  const inner = await createInnerContext({ user, requestId });

  return {
    ...inner,
    req,
    res,
  };
}
```

Each step is independently readable and can be tested in isolation if needed.

---

### Typing the Inner Context Options Explicitly

Keeping the options type explicit makes it easier to see what the inner context depends on and to construct it in tests.

```typescript
type CreateInnerContextOptions = {
  user: AuthUser | null;
  requestId: string;
};

export async function createInnerContext({
  user,
  requestId,
}: CreateInnerContextOptions) {
  return {
    user,
    requestId,
    prisma,
    logger: createLogger({ requestId }),
  };
}
```

**Example** — Constructing the inner context in a test with a specific user role:

```typescript
const ctx = await createInnerContext({
  user: { id: '42', email: 'bob@example.com', role: 'admin' },
  requestId: 'test-request-001',
});
```

---

### Using InnerContext as the Middleware Base

When defining protected procedures, the middleware can safely operate on the inner context shape, since the narrowed context passed via `next()` is what procedures actually see.

```typescript
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import { type Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;

export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  return next({
    ctx: {
      ...ctx,
      user: ctx.user, // narrowed: user is non-null here
    },
  });
});
```

[Inference] TypeScript's ability to narrow `ctx.user` to non-null here depends on how the context type and middleware return type are structured. Behavior may vary by tRPC version and TypeScript configuration.

---

### Diagram

<svg viewBox="0 0 680 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <!-- Background --> <rect width="680" height="420" fill="#0f1117" rx="12"/> <!-- HTTP Layer label -->

<text x="36" y="36" fill="#6b7280" font-size="11" letter-spacing="1">HTTP LAYER</text>

<!-- Outer context box --> <rect x="24" y="48" width="300" height="130" rx="8" fill="#1e2130" stroke="#374151" stroke-width="1.5"/> <text x="44" y="72" fill="#93c5fd" font-size="13" font-weight="bold">createContext (outer)</text> <text x="44" y="96" fill="#d1d5db">req, res ──▶ extract token</text> <text x="44" y="116" fill="#d1d5db">token ──▶ verifyJwt()</text> <text x="44" y="136" fill="#d1d5db">headers ──▶ requestId</text> <text x="44" y="160" fill="#6b7280">spreads req, res into final ctx</text> <!-- Arrow outer to inner --> <line x1="324" y1="113" x2="372" y2="113" stroke="#6b7280" stroke-width="1.5" marker-end="url(#arrow)"/> <text x="330" y="108" fill="#6b7280" font-size="10">calls</text> <!-- Inner context box --> <rect x="372" y="48" width="284" height="130" rx="8" fill="#1e2130" stroke="#374151" stroke-width="1.5"/> <text x="392" y="72" fill="#86efac" font-size="13" font-weight="bold">createInnerContext (inner)</text> <text x="392" y="96" fill="#d1d5db">user, requestId (plain data)</text> <text x="392" y="116" fill="#d1d5db">attaches: prisma, logger</text> <text x="392" y="136" fill="#d1d5db">returns: core context object</text> <text x="392" y="160" fill="#6b7280">no req / res dependency</text> <!-- Divider --> <line x1="24" y1="210" x2="656" y2="210" stroke="#1f2937" stroke-width="1.5" stroke-dasharray="6,4"/> <!-- Final context label -->

<text x="36" y="234" fill="#6b7280" font-size="11" letter-spacing="1">FINAL CONTEXT (merged)</text>

<!-- Final context box --> <rect x="24" y="248" width="300" height="110" rx="8" fill="#1e2130" stroke="#374151" stroke-width="1.5"/> <text x="44" y="272" fill="#fde68a" font-size="13" font-weight="bold">Context (procedures see)</text> <text x="44" y="296" fill="#d1d5db">user ← inner</text> <text x="44" y="314" fill="#d1d5db">prisma ← inner</text> <text x="44" y="332" fill="#d1d5db">logger ← inner</text> <text x="44" y="350" fill="#9ca3af">req, res ← outer (if needed)</text> <!-- Test box --> <rect x="372" y="248" width="284" height="110" rx="8" fill="#1e2130" stroke="#374151" stroke-width="1.5"/> <text x="392" y="272" fill="#c4b5fd" font-size="13" font-weight="bold">Tests (bypass outer)</text> <text x="392" y="296" fill="#d1d5db">createInnerContext({</text> <text x="392" y="314" fill="#d1d5db"> user: mockUser,</text> <text x="392" y="332" fill="#d1d5db"> requestId: 'test-id'</text> <text x="392" y="350" fill="#d1d5db">})</text> <!-- Arrow outer to final --> <line x1="174" y1="178" x2="174" y2="246" stroke="#374151" stroke-width="1.5" marker-end="url(#arrow)"/> <!-- Arrow inner to test --> <line x1="514" y1="178" x2="514" y2="246" stroke="#374151" stroke-width="1.5" marker-end="url(#arrow)"/> <!-- Arrow defs --> <defs> <marker id="arrow" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#6b7280"/> </marker> </defs> <!-- Footer note -->

<text x="24" y="400" fill="#4b5563" font-size="11">Outer context handles HTTP boundary. Inner context holds procedure-relevant data. Tests call inner directly.</text> </svg>

---

### Common Mistakes

#### Putting `req`/`res` Inside the Inner Context

```typescript
// Avoid — defeats the purpose of the split
export async function createInnerContext({ req, res, user }) {
  return { req, res, user, prisma };
}
```

If `req`/`res` are in the inner context, tests must supply them again, removing the testability benefit.

#### Forgetting to Spread the Inner Context

```typescript
// Incorrect — inner context is nested, not merged
export async function createContext({ req, res }) {
  const inner = await createInnerContext({ user });
  return { inner, req, res }; // ctx.inner.prisma — not ctx.prisma
}

// Correct — inner context fields are at the top level
export async function createContext({ req, res }) {
  const inner = await createInnerContext({ user });
  return { ...inner, req, res }; // ctx.prisma
}
```

#### Over-engineering the Split

[Inference] For small projects or simple APIs, the inner/outer split adds boilerplate without meaningful benefit. The pattern is most valuable when procedures are unit-tested frequently or when the context is complex enough that HTTP coupling would be genuinely obstructive.

---

### When to Use This Pattern

| Situation                                    | Recommendation                                                  |
| -------------------------------------------- | --------------------------------------------------------------- |
| Writing unit tests for procedures            | Strongly recommended                                            |
| Large context with many resolved fields      | Recommended                                                     |
| Simple API with few procedures               | [Inference] May be unnecessary overhead                         |
| Shared context used across multiple adapters | Recommended — inner context is adapter-agnostic                 |
| Context that only attaches static clients    | [Inference] Optional — minimal benefit without async resolution |
