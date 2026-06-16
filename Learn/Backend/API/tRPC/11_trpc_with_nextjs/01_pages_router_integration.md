## Pages Router Integration

tRPC integrates with Next.js Pages Router through a dedicated adapter that maps Next.js API route conventions to tRPC's handler interface. This covers the full integration: server setup, client configuration, React Query wiring, context creation, and patterns specific to the Pages Router environment.

---

### Overview of the Integration Architecture

In the Pages Router, tRPC is served from a single catch-all API route. The client is configured once and used throughout the application via React Query. Server-side rendering utilities (`getStaticProps`, `getServerSideProps`) use a separate caller pattern to invoke procedures without an HTTP round-trip.

```mermaid
flowchart TD
    A[Browser / SSR] -->|HTTP| B[pages/api/trpc/trpc.ts\ncatch-all API route]
    B --> C[createNextApiHandler\n@trpc/server/adapters/next]
    C --> D[appRouter]
    D --> E[Procedures\nquery / mutation / subscription]

    F[React Component] -->|useQuery / useMutation| G[tRPC React Client\n@trpc/react-query]
    G -->|httpBatchLink| B

    H[getServerSideProps / getStaticProps] -->|Direct call| I[createCallerFactory\nno HTTP]
    I --> D
```

---

### Installation

```bash
npm install @trpc/server @trpc/client @trpc/react-query @trpc/next @tanstack/react-query zod
```

| Package | Role |
|---|---|
| `@trpc/server` | Router and procedure builder |
| `@trpc/client` | Vanilla client, links |
| `@trpc/react-query` | React hooks, TanStack Query integration |
| `@trpc/next` | Next.js-specific utilities (`createNextApiHandler`, SSR helpers) |
| `@tanstack/react-query` | Query client and provider |
| `zod` | Input validation (conventional choice; others are supported) |

---

### Project Structure

A conventional structure for tRPC in a Pages Router project:

```
src/
  server/
    trpc.ts          # initTRPC, base procedures
    context.ts       # createContext
    routers/
      user.ts
      post.ts
      _app.ts        # root router (appRouter)
  utils/
    trpc.ts          # client-side tRPC + React Query setup
  pages/
    api/
      trpc/
        [trpc].ts    # catch-all API route
    _app.tsx         # QueryClientProvider + trpc.Provider
    index.tsx
```

---

### Server Setup

#### `server/trpc.ts` — Initializing tRPC

```ts
import { initTRPC, TRPCError } from '@trpc/server';
import { type Context } from './context';
import superjson from 'superjson';

const t = initTRPC.context<Context>().create({
  transformer: superjson, // Optional but recommended for Date, Map, Set support
});

export const router = t.router;
export const publicProcedure = t.procedure;

// Protected procedure — reusable middleware
export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return next({ ctx: { ...ctx, user: ctx.session.user } });
});
```

#### `server/context.ts` — Creating Context

Context is created once per request. In the Next.js adapter, the context factory receives the raw `NextApiRequest` and `NextApiResponse`.

```ts
import type { NextApiRequest, NextApiResponse } from 'next';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/pages/api/auth/[...nextauth]';
import { prisma } from '@/lib/prisma';

export async function createContext({
  req,
  res,
}: {
  req: NextApiRequest;
  res: NextApiResponse;
}) {
  const session = await getServerSession(req, res, authOptions);

  return {
    req,
    res,
    session,
    db: prisma,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points**
- Context is typed and threaded through every procedure as `ctx`.
- Including `req` and `res` in context is optional but allows procedures to read headers or set cookies directly when needed.
- Session libraries like NextAuth expose `getServerSession` for use in API routes without additional configuration.

#### `server/routers/_app.ts` — Root Router

```ts
import { router } from '../trpc';
import { userRouter } from './user';
import { postRouter } from './post';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
});

export type AppRouter = typeof appRouter;
```

#### `server/routers/post.ts` — Example Sub-router

```ts
import { z } from 'zod';
import { router, publicProcedure, protectedProcedure } from '../trpc';

export const postRouter = router({
  list: publicProcedure
    .input(z.object({ limit: z.number().min(1).max(100).default(10) }))
    .query(async ({ ctx, input }) => {
      return ctx.db.post.findMany({ take: input.limit });
    }),

  byId: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      const post = await ctx.db.post.findUnique({ where: { id: input.id } });
      if (!post) throw new TRPCError({ code: 'NOT_FOUND' });
      return post;
    }),

  create: protectedProcedure
    .input(z.object({ title: z.string().min(1), content: z.string() }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.post.create({
        data: { ...input, authorId: ctx.user.id },
      });
    }),
});
```

---

### API Route Setup

#### `pages/api/trpc/[trpc].ts` — Catch-All Handler

```ts
import { createNextApiHandler } from '@trpc/server/adapters/next';
import { appRouter } from '@/server/routers/_app';
import { createContext } from '@/server/context';

export default createNextApiHandler({
  router: appRouter,
  createContext,
  onError:
    process.env.NODE_ENV === 'development'
      ? ({ path, error }) => {
          console.error(`tRPC error on ${path ?? 'unknown'}:`, error);
        }
      : undefined,
});
```

**Key Points**
- The filename `[trpc].ts` is a Next.js dynamic route. The `trpc` segment captures the procedure path (e.g., `post.list`, `user.byId`).
- `createNextApiHandler` returns a standard Next.js API handler (`(req, res) => void`).
- `onError` is useful for development logging. Avoid logging full error details in production as they may leak internal information.

#### Body Parser Configuration

tRPC's Next.js adapter handles body parsing internally. If the default Next.js body parser conflicts, disable it:

```ts
export const config = {
  api: {
    bodyParser: false,
  },
};

export default createNextApiHandler({ ... });
```

**Key Points**
- Whether `bodyParser: false` is necessary depends on tRPC version and Next.js version. Test behavior in your specific environment. [Unverified for all version combinations]
- For webhook routes colocated on the same server (separate API files), `bodyParser: false` must be set per-route as described in the prior topic.

---

### Client Setup

#### `utils/trpc.ts` — Client and Hooks

```ts
import { createTRPCNext } from '@trpc/next';
import { httpBatchLink, loggerLink } from '@trpc/client';
import superjson from 'superjson';
import type { AppRouter } from '@/server/routers/_app';

function getBaseUrl() {
  if (typeof window !== 'undefined') return ''; // Browser — relative URL
  if (process.env.VERCEL_URL) return `https://${process.env.VERCEL_URL}`; // Vercel SSR
  return `http://localhost:${process.env.PORT ?? 3000}`; // Local SSR
}

export const trpc = createTRPCNext<AppRouter>({
  config() {
    return {
      transformer: superjson,
      links: [
        loggerLink({
          enabled: (opts) =>
            process.env.NODE_ENV === 'development' ||
            (opts.direction === 'down' && opts.result instanceof Error),
        }),
        httpBatchLink({
          url: `${getBaseUrl()}/api/trpc`,
        }),
      ],
    };
  },
  ssr: false, // See SSR section below
});
```

**Key Points**
- `createTRPCNext` is specific to `@trpc/next` and wraps `createTRPCReact` with Next.js-aware SSR utilities.
- `getBaseUrl()` must return an absolute URL during SSR (server-to-server) and an empty string (relative) on the client. Relative URLs are not valid in Node.js `fetch`.
- `transformer: superjson` must be set identically on both client and server. Mismatch will cause serialization errors.

#### `pages/_app.tsx` — Provider Setup

```tsx
import type { AppProps } from 'next/app';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { useState } from 'react';
import { trpc } from '@/utils/trpc';

function App({ Component, pageProps }: AppProps) {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1 minute
        retry: 1,
      },
    },
  }));

  return (
    <trpc.Provider client={trpc.createClient({ ... })} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>
        <Component {...pageProps} />
        <ReactQueryDevtools initialIsOpen={false} />
      </QueryClientProvider>
    </trpc.Provider>
  );
}

export default trpc.withTRPC(App);
```

**Key Points**
- `trpc.withTRPC(App)` is a higher-order component from `@trpc/next` that handles client instantiation and SSR dehydration. It replaces the need to manually wire `trpc.Provider` and `QueryClientProvider` in some configurations — the exact API surface depends on `@trpc/next` version. [Unverified for all versions]
- `useState(() => new QueryClient(...))` prevents the client from being shared across requests during SSR, which would cause data leakage between users.
- `staleTime` controls how long cached query data is considered fresh. Setting it to `0` causes refetching on every mount.

---

### Using tRPC in Components

```tsx
import { trpc } from '@/utils/trpc';

export function PostList() {
  const { data, isLoading, error } = trpc.post.list.useQuery({ limit: 20 });

  const createPost = trpc.post.create.useMutation({
    onSuccess: () => {
      // Invalidate and refetch the list after a successful mutation
      trpc.post.list.useUtils().invalidate();
    },
  });

  if (isLoading) return <p>Loading...</p>;
  if (error) return <p>Error: {error.message}</p>;

  return (
    <ul>
      {data?.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}
```

---

### Cache Invalidation Pattern

The `useUtils()` hook provides access to the tRPC query utilities, which wrap TanStack Query's `queryClient` methods:

```ts
const utils = trpc.useUtils();

// Invalidate a specific query
await utils.post.byId.invalidate({ id: '123' });

// Invalidate all queries under post
await utils.post.invalidate();

// Optimistic update
utils.post.list.setData({ limit: 20 }, (old) =>
  old ? [newPost, ...old] : [newPost]
);
```

---

### Server-Side Data Fetching

#### `getServerSideProps` — Per-Request SSR

To fetch tRPC data server-side without an HTTP round-trip, use `createCallerFactory` (tRPC v11+) or `createCaller` (v10):

```ts
import type { GetServerSideProps } from 'next';
import { createCallerFactory } from '@trpc/server';
import { appRouter } from '@/server/routers/_app';
import { createContext } from '@/server/context';

const createCaller = createCallerFactory(appRouter);

export const getServerSideProps: GetServerSideProps = async (ctx) => {
  const context = await createContext({
    req: ctx.req as any,
    res: ctx.res as any,
  });

  const caller = createCaller(context);

  const posts = await caller.post.list({ limit: 10 });

  return {
    props: {
      posts: JSON.parse(JSON.stringify(posts)), // Serialize for Next.js props
    },
  };
};
```

**Key Points**
- `createCallerFactory` creates a factory; calling it with a context produces a caller for that request. The caller invokes procedures directly in the same Node.js process — no HTTP request is made.
- Next.js requires `props` to be JSON-serializable. If `superjson` is used as a transformer, the data must be serialized manually before returning from `getServerSideProps`, or use a helper like `superjson.serialize` and deserialize on the client.
- The caller respects all middleware defined on procedures, including auth checks.

#### `getStaticProps` — Build-Time SSR

```ts
import type { GetStaticProps } from 'next';

export const getStaticProps: GetStaticProps = async () => {
  const context = await createContext({ req: {} as any, res: {} as any });
  const caller = createCaller(context);

  const posts = await caller.post.list({ limit: 10 });

  return {
    props: { posts: JSON.parse(JSON.stringify(posts)) },
    revalidate: 60, // ISR — revalidate every 60 seconds
  };
};
```

**Key Points**
- `getStaticProps` runs at build time and has no real `req`/`res`. Passing empty objects is a common workaround but means context-dependent logic (sessions, cookies) is unavailable. Procedures that depend on auth context should not be called from `getStaticProps`. [Inference]
- ISR (`revalidate`) causes `getStaticProps` to re-run on the server after the specified interval, which does have a real request context available during revalidation.

#### SSR with Prefetching and Dehydration (Alternative Pattern)

`@trpc/next` also supports a prefetch-and-dehydrate pattern using `createSSGHelpers` (v10) or `createServerSideHelpers` (v11), which populates the React Query cache server-side so components hydrate without loading states:

```ts
import { createServerSideHelpers } from '@trpc/react-query/server';
import superjson from 'superjson';

export const getServerSideProps: GetServerSideProps = async (ctx) => {
  const helpers = createServerSideHelpers({
    router: appRouter,
    ctx: await createContext({ req: ctx.req as any, res: ctx.res as any }),
    transformer: superjson,
  });

  // Prefetch — populates cache
  await helpers.post.list.prefetch({ limit: 10 });

  return {
    props: {
      trpcState: helpers.dehydrate(),
    },
  };
};
```

In `_app.tsx`, pass `trpcState` to `trpc.withTRPC` (or manually to `Hydrate` from TanStack Query) so the cache is rehydrated on the client. The `useQuery` hook will see the data immediately without a loading state.

**Key Points**
- This pattern avoids prop-drilling fetched data through `pageProps`. Components call `useQuery` normally and find the cache pre-populated.
- `dehydrate()` produces a serializable snapshot of the query cache.
- The exact API (`createSSGHelpers` vs `createServerSideHelpers`) changed between tRPC v10 and v11. Verify against the version in use. [Unverified for all version combinations]

---

### Error Handling

#### Procedure-Level Errors

Throw `TRPCError` inside procedures for typed, structured errors:

```ts
import { TRPCError } from '@trpc/server';

.query(async ({ ctx, input }) => {
  const record = await ctx.db.find(input.id);
  if (!record) throw new TRPCError({ code: 'NOT_FOUND', message: 'Record not found' });
  return record;
});
```

#### Client-Side Error Handling

```tsx
const { error } = trpc.post.byId.useQuery({ id });

if (error?.data?.code === 'NOT_FOUND') {
  return <p>Post not found.</p>;
}
if (error) {
  return <p>Unexpected error: {error.message}</p>;
}
```

**Key Points**
- `error.data.code` maps to the `TRPCError` code thrown server-side.
- `error.data.httpStatus` reflects the HTTP status code tRPC assigned to the error code.
- TanStack Query's `retry` option will retry failed queries. For errors that are definitively client-side (e.g., `NOT_FOUND`, `UNAUTHORIZED`), configure `retry: false` or use `shouldRetryOnError`.

---

### Response Metadata — Custom Headers and Status Codes

tRPC procedures cannot set HTTP headers or status codes directly. Use `responseMeta` in the handler for server-rendered pages or global response customization:

```ts
export default createNextApiHandler({
  router: appRouter,
  createContext,
  responseMeta({ ctx, paths, type, errors }) {
    const allOk = errors.length === 0;
    const isQuery = type === 'query';

    if (ctx?.res && allOk && isQuery) {
      return {
        headers: {
          'Cache-Control': 's-maxage=60, stale-while-revalidate=300',
        },
      };
    }

    return {};
  },
});
```

**Key Points**
- `responseMeta` receives the resolved context, the procedure paths in the batch, the request type, and any errors.
- This is the correct location for setting cache headers, custom response headers, or modifying the HTTP status code at the transport layer.
- Individual procedures cannot return HTTP headers. Any header-setting logic belongs here or in middleware that writes to `ctx.res` directly.

---

### tRPC v10 vs v11 in Pages Router Context

| Feature | v10 | v11 |
|---|---|---|
| Caller factory | `appRouter.createCaller(ctx)` | `createCallerFactory(appRouter)(ctx)` |
| SSG helpers | `createSSGHelpers` from `@trpc/react-query/ssg` | `createServerSideHelpers` from `@trpc/react-query/server` |
| React Query peer | v4 | v5 |
| `useUtils` | `useContext` | `useUtils` (preferred) |
| Transformer config | Top-level in `initTRPC.create()` | Same, but `superjson` import path may differ |

Check the installed version with `npm list @trpc/server` and consult the corresponding documentation. Mixing v10 client utilities with a v11 server (or vice versa) will produce runtime errors.

---

### Common Mistakes

| Mistake | Effect | Resolution |
|---|---|---|
| Relative URL in SSR `getBaseUrl` | `fetch` fails on server — invalid URL | Return absolute URL when `typeof window === 'undefined'` |
| Transformer mismatch (client vs server) | Serialization errors, garbled data | Set identical `transformer` in both `initTRPC.create()` and `createTRPCNext` |
| Non-serializable `getServerSideProps` props | Next.js serialization error | Serialize with `JSON.parse(JSON.stringify(...))` or `superjson` |
| `new QueryClient()` outside `useState` | Query cache shared across SSR requests | Always initialize inside `useState` or per-request |
| Calling auth-dependent procedures in `getStaticProps` | Missing session context | Use `getServerSideProps` for session-dependent data |
| `bodyParser` conflict | Request body not available to tRPC | Set `export const config = { api: { bodyParser: false } }` |

---

**Conclusion**

Pages Router integration follows a clear pattern: a catch-all API route serves all tRPC procedures, `createTRPCNext` wires the client to React Query, and `createCallerFactory` enables direct server-side calls without HTTP overhead. The most significant Pages Router-specific concerns are `getBaseUrl` correctness for SSR, transformer consistency, and cache hydration for SSR-prefetched data.

**Next Steps**
- tRPC with Next.js — App Router integration
- tRPC with Next.js — server components and React Server Component patterns