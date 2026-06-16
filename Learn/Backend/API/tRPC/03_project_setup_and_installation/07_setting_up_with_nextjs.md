### Setting Up with Next.js

#### Overview

tRPC integrates with Next.js through adapters that map tRPC procedures to Next.js API routes. Two distinct setups exist depending on which Next.js router you use: the **Pages Router** (traditional `pages/api/` structure) and the **App Router** (introduced in Next.js 13, stable in 14+). The two require different adapters and context signatures because they operate on different request primitives.

---

#### Dependencies

```bash
npm install @trpc/server @trpc/client @trpc/react-query @tanstack/react-query zod
```

For Next.js specifically, no additional adapter package is needed beyond `@trpc/server` — the Next.js adapters are included within it.

---

#### Project Structure

```
src/
├── server/
│   ├── trpc.ts
│   ├── context.ts
│   └── router/
│       ├── index.ts
│       └── example.router.ts
├── utils/
│   └── trpc.ts                        # Client-side tRPC hook object
├── pages/                             # Pages Router
│   ├── api/
│   │   └── trpc/
│   │       └── [trpc].ts              # Catch-all API route handler
│   └── index.tsx
└── app/                               # App Router (alternative)
    └── api/
        └── trpc/
            └── [trpc]/
                └── route.ts           # Route handler
```

In practice, a project uses one router model, not both. The structure above shows both for reference.

---

#### Shared Setup — tRPC Instance and Router

These files are identical regardless of which Next.js router you use.

```ts
// src/server/trpc.ts
import { initTRPC } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
```

```ts
// src/server/router/example.router.ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

export const exampleRouter = router({
  hello: publicProcedure
    .input(z.object({ name: z.string() }))
    .query(({ input }) => {
      return { greeting: `Hello, ${input.name}` };
    }),
});
```

```ts
// src/server/router/index.ts
import { router } from '../trpc';
import { exampleRouter } from './example.router';

export const appRouter = router({
  example: exampleRouter,
});

export type AppRouter = typeof appRouter;
```

---

#### Pages Router Setup

##### Context

The Pages Router exposes Node.js `req` and `res` objects. The context factory receives these via `CreateNextContextOptions`.

```ts
// src/server/context.ts
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return { req, res };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

##### API Route Handler

A single catch-all route handles all tRPC procedure calls.

```ts
// src/pages/api/trpc/[trpc].ts
import { createNextApiHandler } from '@trpc/server/adapters/next';
import { appRouter } from '../../../server/router';
import { createContext } from '../../../server/context';

export default createNextApiHandler({
  router: appRouter,
  createContext,
});
```

**Key Points**

- The filename `[trpc].ts` is a Next.js dynamic route. The segment name (`trpc`) is arbitrary — it does not affect procedure routing.
- All tRPC procedures are reachable under `/api/trpc/<procedure.path>`.
- `createNextApiHandler` returns a standard Next.js API handler function.

##### Client Setup

```ts
// src/utils/trpc.ts
import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '../server/router';

export const trpc = createTRPCReact<AppRouter>();
```

##### Provider Setup

Wrap your application with the tRPC and React Query providers in `_app.tsx`.

tsx

```
// src/pages/_app.tsx
import type { AppProps } from 'next/app';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { httpBatchLink } from '@trpc/client';
import { useState } from 'react';
import { trpc } from '../utils/trpc';

export default function App({ Component, pageProps }: AppProps) {
  const [queryClient] = useState(() => new QueryClient());
  const [trpcClient] = useState(() =>
    trpc.createClient({
      links: [
        httpBatchLink({
          url: '/api/trpc',
        }),
      ],
    }),
  );

  return (
    <trpc.Provider client={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>
        <Component {...pageProps} />
      </QueryClientProvider>
    </trpc.Provider>
  );
}
```

**Key Points**

- `QueryClient` and `trpcClient` are initialized inside `useState` to avoid sharing state across requests during SSR.
- The `url` in `httpBatchLink` must match the path where the API handler is mounted (`/api/trpc`).
- `trpc.Provider` and `QueryClientProvider` are both required. `trpc.Provider` does not replace `QueryClientProvider`.

##### Usage in a Page Component

tsx

```
// src/pages/index.tsx
import { trpc } from '../utils/trpc';

export default function Home() {
  const hello = trpc.example.hello.useQuery({ name: 'Alice' });

  if (hello.isLoading) return <p>Loading...</p>;
  if (hello.error) return <p>Error: {hello.error.message}</p>;

  return <p>{hello.data?.greeting}</p>;
}
```

---

#### App Router Setup

The App Router uses the Fetch API (`Request` / `Response`) rather than Node.js `req`/`res`. This requires a different adapter and context type.

##### Context

```ts
// src/server/context.ts
import type { FetchCreateContextFnOptions } from '@trpc/server/adapters/fetch';

export async function createContext({ req }: FetchCreateContextFnOptions) {
  return { req };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points**

- There is no `res` object in the Fetch-based context. Response construction is handled by the adapter.
- Headers can be read from `req.headers` as with any standard `Request` object.

##### Route Handler

```ts
// src/app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { appRouter } from '../../../../server/router';
import { createContext } from '../../../../server/context';

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext,
  });

export { handler as GET, handler as POST };
```

**Key Points**

- Both `GET` and `POST` are exported from the same handler. Next.js App Router requires named exports per HTTP method.
- The `endpoint` value must match the URL path where the route is mounted. This is used internally for path resolution.
- The directory `[trpc]` is a dynamic segment. The folder name does not affect procedure routing.

##### Client Setup for App Router

For App Router, the recommended pattern separates server-side and client-side tRPC usage.

**Client component hook object:**

```ts
// src/utils/trpc.ts
'use client';

import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '../server/router';

export const trpc = createTRPCReact<AppRouter>();
```

**Provider component:**

tsx

```
// src/app/_trpc/Provider.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { httpBatchLink } from '@trpc/client';
import { useState } from 'react';
import { trpc } from '../../utils/trpc';

export function TRPCProvider({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  const [trpcClient] = useState(() =>
    trpc.createClient({
      links: [
        httpBatchLink({
          url: '/api/trpc',
        }),
      ],
    }),
  );

  return (
    <trpc.Provider client={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    </trpc.Provider>
  );
}
```

**Root layout:**

tsx

```
// src/app/layout.tsx
import { TRPCProvider } from './_trpc/Provider';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <TRPCProvider>{children}</TRPCProvider>
      </body>
    </html>
  );
}
```

##### Server-Side Calls in Server Components

In App Router, React Server Components can call tRPC procedures directly without going through HTTP, using a server-side caller.

```ts
// src/server/caller.ts
import { appRouter } from './router';
import { createContext } from './context';

export const createCaller = appRouter.createCaller;
```

tsx

```
// src/app/page.tsx  (Server Component)
import { createCaller } from '../server/caller';

export default async function Page() {
  const caller = createCaller(
    await createContext({ req: new Request('http://localhost') }),
  );

  const result = await caller.example.hello({ name: 'Alice' });

  return <p>{result.greeting}</p>;
}
```

**Key Points**

- `createCaller` bypasses HTTP entirely. Procedures execute in-process on the server.
- [Inference] Passing a synthetic `Request` object to `createContext` for server component callers is a workaround, since there is no real incoming request at that call site. The appropriate context construction depends on your auth and session strategy.
- This pattern avoids network overhead for data that can be fetched at render time on the server.

---

#### Adapter Comparison — Pages vs App Router

| Aspect | Pages Router | App Router |
| --- | --- | --- |
| Adapter | `createNextApiHandler` | `fetchRequestHandler` |
| Import path | `@trpc/server/adapters/next` | `@trpc/server/adapters/fetch` |
| Context type | `CreateNextContextOptions` | `FetchCreateContextFnOptions` |
| Request primitive | Node.js `IncomingMessage` | Fetch API `Request` |
| Response object in context | Yes (`res`) | No |
| Server component direct call | Not applicable | Via `createCaller` |
| Handler file | `pages/api/trpc/[trpc].ts` | `app/api/trpc/[trpc]/route.ts` |

---

#### CORS in Next.js

Next.js same-origin deployments typically do not require explicit CORS configuration for tRPC. If your frontend and tRPC API are on separate origins, add CORS headers in the route handler or via Next.js middleware.

[Inference] For most Next.js monolithic deployments where the API and frontend share the same origin, CORS headers are not required. Behavior may vary in split-deployment configurations.

---

#### Environment Variable for API URL

Hard-coding `/api/trpc` works for local development but may need to be dynamic in production:

```ts
httpBatchLink({
  url: `${process.env.NEXT_PUBLIC_APP_URL}/api/trpc`,
}),
```

Define `NEXT_PUBLIC_APP_URL` in `.env.local`:

```
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

**Key Points**

- Environment variables prefixed with `NEXT_PUBLIC_` are inlined into the client bundle at build time by Next.js.
- Do not put sensitive values in `NEXT_PUBLIC_` variables.