## Express Adapter Setup

tRPC is framework-agnostic at its core. The Express adapter bridges tRPC's router and procedure system to Express's middleware and routing model, allowing tRPC to be mounted as a route handler within an existing or standalone Express application.

---

### Installation

```bash
npm install @trpc/server express
npm install --save-dev @types/express
```

The Express adapter is included in `@trpc/server` — no separate adapter package is required.

---

### Minimal Server Setup

A complete, working tRPC + Express server requires four parts: a tRPC instance, a router, an Express app, and the adapter middleware.

```ts
// server.ts
import express from 'express';
import { createExpressMiddleware } from '@trpc/server/adapters/express';
import { initTRPC } from '@trpc/server';

const t = initTRPC.create();

const appRouter = t.router({
  hello: t.procedure
    .input(z.object({ name: z.string() }))
    .query(({ input }) => {
      return { greeting: `Hello, ${input.name}` };
    }),
});

export type AppRouter = typeof appRouter;

const app = express();

app.use(
  '/trpc',
  createExpressMiddleware({
    router: appRouter,
  })
);

app.listen(3000, () => {
  console.log('Server listening on http://localhost:3000');
});
```

All tRPC procedures are accessible under `/trpc`. A query named `hello` is called at `/trpc/hello`.

---

### `createExpressMiddleware` Options

The adapter accepts a configuration object with several options beyond the required `router`.

```ts
createExpressMiddleware({
  router: appRouter,
  createContext,
  onError,
  middleware,
  batching,
  responseMeta,
})
```

#### `router`

**Required.** The root tRPC router instance.

#### `createContext`

A function that receives the Express `req` and `res` objects and returns the context object passed to all procedures.

```ts
import { CreateExpressContextOptions } from '@trpc/server/adapters/express';

export const createContext = ({ req, res }: CreateExpressContextOptions) => {
  const token = req.headers.authorization?.split(' ')[1] ?? null;
  return { token, req, res };
};

export type Context = Awaited<ReturnType<typeof createContext>>;
```

```ts
app.use(
  '/trpc',
  createExpressMiddleware({
    router: appRouter,
    createContext,
  })
);
```

#### `onError`

A callback invoked when any procedure throws. Receives the error, path, input, context, and type of the failed procedure. Useful for centralized logging.

```ts
createExpressMiddleware({
  router: appRouter,
  createContext,
  onError({ error, type, path, input, ctx }) {
    console.error(`[tRPC Error] ${type} ${path}:`, error.message);
    if (error.code === 'INTERNAL_SERVER_ERROR') {
      // forward to external error tracker
    }
  },
});
```

#### `batching`

Controls whether the adapter accepts batched requests from the client. Enabled by default.

```ts
createExpressMiddleware({
  router: appRouter,
  batching: { enabled: false }, // disable request batching
});
```

#### `responseMeta`

A function that returns additional HTTP metadata (status codes, headers) to attach to responses. Useful for cache control, CORS headers on responses, or custom status codes.

```ts
createExpressMiddleware({
  router: appRouter,
  responseMeta({ ctx, paths, type, errors }) {
    const allOk = errors.length === 0;
    const isQuery = type === 'query';
    if (allOk && isQuery) {
      return {
        headers: {
          'cache-control': 'max-age=60',
        },
      };
    }
    return {};
  },
});
```

---

### Context Creation in Detail

The context function is the primary integration point between Express and tRPC. It runs before every procedure call and its return value is available as `ctx` inside all procedures and middleware.

```ts
// context.ts
import { CreateExpressContextOptions } from '@trpc/server/adapters/express';
import { verifyToken } from './auth';
import { db } from './db';

export const createContext = async ({ req, res }: CreateExpressContextOptions) => {
  const authHeader = req.headers.authorization;
  const user = authHeader
    ? await verifyToken(authHeader.replace('Bearer ', ''))
    : null;

  return {
    db,
    user,
    req,
    res,
  };
};

export type Context = Awaited<ReturnType<typeof createContext>>;
```

```ts
// trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return next({ ctx: { ...ctx, user: ctx.user } });
});
```

---

### Mounting Alongside REST Routes

Because `createExpressMiddleware` returns a standard Express middleware function, tRPC coexists naturally with existing REST routes, static file serving, and other Express middleware.

```ts
const app = express();

// Standard Express middleware
app.use(express.json());
app.use(cors());

// Existing REST routes
app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.use('/api/webhooks', webhookRouter); // REST webhook handler

// tRPC mounted at /trpc
app.use(
  '/trpc',
  createExpressMiddleware({
    router: appRouter,
    createContext,
  })
);

// Static files
app.use(express.static('public'));

app.listen(3000);
```

**Key Points**

- tRPC middleware does not interfere with other Express routes
- The mount path (`/trpc`) is arbitrary — it can be any valid Express path
- Express middleware registered before `createExpressMiddleware` (e.g., `cors()`, `express.json()`) runs before tRPC context creation

---

### CORS Configuration

When the tRPC client runs in a browser on a different origin, CORS headers are required. The standard approach is to use the `cors` package as Express middleware before the tRPC handler.

```bash
npm install cors
npm install --save-dev @types/cors
```

```ts
import cors from 'cors';

app.use(
  cors({
    origin: 'http://localhost:5173', // client origin
    credentials: true,
  })
);

app.use(
  '/trpc',
  createExpressMiddleware({
    router: appRouter,
    createContext,
  })
);
```

[Inference] Placing `cors()` before the tRPC middleware is the common pattern. Applying CORS only to the `/trpc` path is also valid and more restrictive:

```ts
app.use('/trpc', cors({ origin: 'http://localhost:5173' }), createExpressMiddleware({ ... }));
```

---

### Project File Structure

A conventional layout for a standalone tRPC Express server:

```
src/
  index.ts          ← Express app setup and listen
  trpc.ts           ← initTRPC, base procedures, middleware
  context.ts        ← createContext function and Context type
  routers/
    index.ts        ← root appRouter merging all sub-routers
    user.ts
    post.ts
  db.ts             ← database client
```

```ts
// src/routers/index.ts
import { router } from '../trpc';
import { userRouter } from './user';
import { postRouter } from './post';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
});

export type AppRouter = typeof appRouter;
```

```ts
// src/index.ts
import express from 'express';
import { createExpressMiddleware } from '@trpc/server/adapters/express';
import { appRouter } from './routers';
import { createContext } from './context';

const app = express();

app.use(express.json());

app.use(
  '/trpc',
  createExpressMiddleware({
    router: appRouter,
    createContext,
  })
);

app.listen(3000, () => console.log('Listening on :3000'));
```

---

### Accessing `req` and `res` Inside Procedures

Passing `req` and `res` through context is the standard way to access them inside procedures. There is no direct Express request/response injection into procedures outside of context.

```ts
// context.ts
export const createContext = ({ req, res }: CreateExpressContextOptions) => ({
  req,
  res,
});
```

```ts
// procedure
export const getClientIp = publicProcedure.query(({ ctx }) => {
  return { ip: ctx.req.ip };
});
```

**Key Points**

- Avoid coupling procedures directly to `req`/`res` where possible — prefer extracting only what is needed into context (e.g., `user`, `token`, `ip`) rather than passing the raw objects
- [Inference] Passing raw `req`/`res` is convenient but makes procedures harder to test in isolation, since tests must construct mock Express objects rather than plain context values

---

### Setting Response Headers and Cookies From Procedures

Because `res` is available in context, procedures can set cookies and headers directly:

```ts
export const login = publicProcedure
  .input(z.object({ email: z.string(), password: z.string() }))
  .mutation(async ({ input, ctx }) => {
    const user = await authenticateUser(input.email, input.password);
    ctx.res.cookie('session', user.sessionToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
    });
    return { userId: user.id };
  });
```

[Inference] This pattern works but couples the procedure to the HTTP transport layer. For stricter separation, `responseMeta` is the preferred mechanism for headers, and cookie logic can be abstracted into a context helper.

---

### Diagram: Request Flow Through the Express Adapter

<svg viewBox="0 0 680 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <!-- HTTP Request -->
  <rect x="20" y="20" width="140" height="44" rx="7" fill="#1e293b" stroke="#6366f1" stroke-width="2"/>
  <text x="90" y="42" text-anchor="middle" fill="#a5b4fc" font-weight="bold">HTTP Request</text>
  <text x="90" y="58" text-anchor="middle" fill="#94a3b8" font-size="11">POST /trpc/user.create</text>

  <!-- Arrow -->
  <line x1="160" y1="42" x2="210" y2="42" stroke="#475569" stroke-width="1.5"/>
  <polygon points="210,42 200,37 200,47" fill="#475569"/>

  <!-- Express Middleware Stack -->
  <rect x="210" y="20" width="160" height="44" rx="7" fill="#1e293b" stroke="#22d3ee" stroke-width="2"/>
  <text x="290" y="40" text-anchor="middle" fill="#67e8f9" font-weight="bold">Express Middleware</text>
  <text x="290" y="58" text-anchor="middle" fill="#94a3b8" font-size="11">cors, json, auth...</text>

  <!-- Arrow -->
  <line x1="370" y1="42" x2="420" y2="42" stroke="#475569" stroke-width="1.5"/>
  <polygon points="420,42 410,37 410,47" fill="#475569"/>

  <!-- createExpressMiddleware -->
  <rect x="420" y="20" width="230" height="44" rx="7" fill="#1e293b" stroke="#f59e0b" stroke-width="2"/>
  <text x="535" y="40" text-anchor="middle" fill="#fcd34d" font-weight="bold">createExpressMiddleware</text>
  <text x="535" y="58" text-anchor="middle" fill="#94a3b8" font-size="11">tRPC Express adapter</text>

  <!-- Arrow down -->
  <line x1="535" y1="64" x2="535" y2="110" stroke="#475569" stroke-width="1.5"/>
  <polygon points="535,110 530,100 540,100" fill="#475569"/>

  <!-- createContext -->
  <rect x="400" y="110" width="270" height="44" rx="7" fill="#0f172a" stroke="#34d399" stroke-width="2"/>
  <text x="535" y="130" text-anchor="middle" fill="#6ee7b7" font-weight="bold">createContext(req, res)</text>
  <text x="535" y="148" text-anchor="middle" fill="#94a3b8" font-size="11">builds ctx: user, db, req, res</text>

  <!-- Arrow down -->
  <line x1="535" y1="154" x2="535" y2="200" stroke="#475569" stroke-width="1.5"/>
  <polygon points="535,200 530,190 540,190" fill="#475569"/>

  <!-- Router -->
  <rect x="400" y="200" width="270" height="44" rx="7" fill="#0f172a" stroke="#818cf8" stroke-width="2"/>
  <text x="535" y="220" text-anchor="middle" fill="#a5b4fc" font-weight="bold">tRPC Router</text>
  <text x="535" y="238" text-anchor="middle" fill="#94a3b8" font-size="11">resolves path → procedure</text>

  <!-- Arrow down -->
  <line x1="535" y1="244" x2="535" y2="290" stroke="#475569" stroke-width="1.5"/>
  <polygon points="535,290 530,280 540,280" fill="#475569"/>

  <!-- Procedure -->
  <rect x="400" y="290" width="270" height="44" rx="7" fill="#0f172a" stroke="#f472b6" stroke-width="2"/>
  <text x="535" y="310" text-anchor="middle" fill="#f9a8d4" font-weight="bold">Procedure Handler</text>
  <text x="535" y="328" text-anchor="middle" fill="#94a3b8" font-size="11">input validated → resolver runs</text>

  <!-- Response arrow back left -->
  <line x1="400" y1="312" x2="90" y2="312" stroke="#475569" stroke-width="1.5" stroke-dasharray="5,3"/>
  <line x1="90" y1="312" x2="90" y2="64" stroke="#475569" stroke-width="1.5" stroke-dasharray="5,3"/>
  <polygon points="90,64 85,74 95,74" fill="#475569"/>
  <text x="240" y="330" text-anchor="middle" fill="#64748b" font-size="11">serialized JSON response</text>
</svg>

---

**Conclusion**

The Express adapter is a thin, well-integrated bridge that mounts tRPC as standard Express middleware. Its primary configuration surface — `createContext`, `onError`, and `responseMeta` — covers the majority of real-world integration needs. Because it behaves as ordinary middleware, it composes cleanly with the full Express ecosystem: existing REST routes, CORS handlers, authentication middleware, and static file serving all coexist without conflict. The context function is the critical seam where Express's request model meets tRPC's type-safe procedure system.