## Setting Up with Vite and React

### Overview

Vite with React is a purely client-side setup. Unlike Next.js, there is no server-side rendering layer or built-in API route system. tRPC's client runs in the browser and communicates with a separately running backend server — typically a standalone Node.js server, Express, or Fastify instance. This means the Vite/React setup only covers the **client half** of the tRPC stack; the server must be configured independently.

---

### Architecture

```
┌─────────────────────────┐        HTTP         ┌─────────────────────────┐
│   Vite + React (client) │  ────────────────►  │  Node.js server         │
│   trpc.createClient()   │  ◄────────────────  │  appRouter + adapter    │
└─────────────────────────┘                     └─────────────────────────┘
```

The `AppRouter` type is shared across both sides — either via a monorepo package, a shared path alias, or by copying the type export. No runtime server code is bundled into the Vite client.

---

### Dependencies

**Client (Vite/React project):**

```bash
npm install @trpc/client @trpc/react-query @tanstack/react-query
```

**Server (separate Node.js project or monorepo package):**

```bash
npm install @trpc/server zod
```

**Key Points**
- `@trpc/react-query` provides React hooks (`useQuery`, `useMutation`, etc.) built on top of TanStack Query.
- `@tanstack/react-query` is a peer dependency and must be installed explicitly.
- Zod is installed server-side for input validation. The client does not require Zod unless you use it for client-side logic independently.

---

### Project Structure

#### Standalone (separate client and server directories)

```
project-root/
├── client/                        # Vite + React
│   ├── src/
│   │   ├── utils/
│   │   │   └── trpc.ts            # tRPC client hook object
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── vite.config.ts
│   └── package.json
└── server/                        # Node.js tRPC server
    ├── src/
    │   ├── trpc.ts
    │   ├── context.ts
    │   └── router/
    │       └── index.ts
    └── package.json
```

#### Monorepo (recommended for type sharing)

```
project-root/
├── packages/
│   ├── api/                       # tRPC server package
│   │   └── src/
│   │       ├── trpc.ts
│   │       ├── context.ts
│   │       └── router/
│   │           └── index.ts       # exports AppRouter type
│   └── web/                       # Vite + React
│       └── src/
│           └── utils/
│               └── trpc.ts
├── package.json                   # workspace root
└── turbo.json                     # if using Turborepo
```

---

### Server Setup (Reference)

A minimal Express server to accompany the Vite client. This mirrors the standalone Node.js setup covered previously, included here for completeness.

```ts
// server/src/trpc.ts
import { initTRPC } from '@trpc/server';

const t = initTRPC.create();

export const router = t.router;
export const publicProcedure = t.procedure;
```

```ts
// server/src/router/index.ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

export const appRouter = router({
  example: router({
    hello: publicProcedure
      .input(z.object({ name: z.string() }))
      .query(({ input }) => {
        return { greeting: `Hello, ${input.name}` };
      }),
  }),
});

export type AppRouter = typeof appRouter;
```

```ts
// server/src/index.ts
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { appRouter } from './router';

const server = createHTTPServer({
  router: appRouter,
  createContext() {
    return {};
  },
  middleware(req, res, next) {
    res.setHeader('Access-Control-Allow-Origin', 'http://localhost:5173');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method === 'OPTIONS') {
      res.writeHead(204);
      res.end();
      return;
    }
    next();
  },
});

server.listen(3000);
```

**Key Points**
- `http://localhost:5173` is the default Vite dev server origin. Restrict the CORS origin to this value during development; use the production domain in production.
- CORS must be configured on the server when the Vite client and tRPC server run on different ports, which they always do in local development.

---

### Client Setup

#### Step 1 — Create the tRPC Hook Object

```ts
// client/src/utils/trpc.ts
import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '../../server/src/router'; // adjust path or package name

export const trpc = createTRPCReact<AppRouter>();
```

**Key Points**
- Only the `AppRouter` type is imported. TypeScript erases type-only imports at compile time — no server code enters the client bundle.
- In a monorepo, replace the relative path with the package name: `import type { AppRouter } from '@my-org/api'`.
- If co-location is not possible, the `AppRouter` type can be copied manually, though this introduces a maintenance burden. [Inference]

#### Step 2 — Configure the tRPC Client

```ts
// client/src/utils/trpc.ts (extended)
import { createTRPCReact } from '@trpc/react-query';
import { httpBatchLink } from '@trpc/client';
import type { AppRouter } from '../../server/src/router';

export const trpc = createTRPCReact<AppRouter>();

export function createTRPCClient() {
  return trpc.createClient({
    links: [
      httpBatchLink({
        url: 'http://localhost:3000',
      }),
    ],
  });
}
```

#### Step 3 — Set Up Providers in `main.tsx`

```tsx
// client/src/main.tsx
import React, { useState } from 'react';
import ReactDOM from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { trpc, createTRPCClient } from './utils/trpc';
import App from './App';

function Root() {
  const [queryClient] = useState(() => new QueryClient());
  const [trpcClient] = useState(() => createTRPCClient());

  return (
    <trpc.Provider client={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    </trpc.Provider>
  );
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Root />
  </React.StrictMode>,
);
```

**Key Points**
- `useState` is used to initialize both clients so they are created once per component mount, not on every render.
- Both `trpc.Provider` and `QueryClientProvider` must wrap the component tree. The order shown here is conventional — `trpc.Provider` outer, `QueryClientProvider` inner.
- `Root` is a named component rather than an inline JSX block to keep `useState` inside a valid React component scope.

---

### Usage in Components

```tsx
// client/src/App.tsx
import { trpc } from './utils/trpc';

export default function App() {
  const hello = trpc.example.hello.useQuery({ name: 'Alice' });

  if (hello.isLoading) return <p>Loading…</p>;
  if (hello.error) return <p>Error: {hello.error.message}</p>;

  return <p>{hello.data?.greeting}</p>;
}
```

**Output** (rendered in browser)

```
Hello, Alice
```

---

### Vite Proxy Configuration

Instead of configuring CORS on the server, you can proxy API requests through Vite's dev server. This avoids cross-origin requests entirely during development.

```ts
// client/vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/trpc': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
    },
  },
});
```

Update the tRPC client URL to use the proxied path:

```ts
httpBatchLink({
  url: '/trpc',  // proxied by Vite, no CORS headers needed
}),
```

**Key Points**
- With this approach, the browser sends requests to `http://localhost:5173/trpc/...`, and Vite forwards them to `http://localhost:3000/trpc/...`.
- The server no longer needs CORS headers for local development when using the proxy.
- This proxy only applies during `vite dev`. In production, your deployment infrastructure must handle routing.

---

### Vanilla Client (Without React Query)

If you are not using React Query hooks, the vanilla tRPC client can be used directly. This is useful in non-component contexts such as utility functions or service modules.

```ts
// client/src/utils/client.ts
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import type { AppRouter } from '../../server/src/router';

export const client = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({
      url: 'http://localhost:3000',
    }),
  ],
});
```

```ts
// Usage anywhere in the client
import { client } from './utils/client';

const result = await client.example.hello.query({ name: 'Alice' });
console.log(result.greeting); // Hello, Alice
```

**Key Points**
- The vanilla client does not require `QueryClient`, React, or any provider setup.
- It does not provide caching, deduplication, or loading state management. Those are features of TanStack Query, not of the tRPC transport layer.
- [Inference] The vanilla client is useful for scripts, CLI tools, or server-to-server calls where React is not present.

---

### Environment Variable for Server URL

Avoid hard-coding `http://localhost:3000` in the client bundle:

```ts
httpBatchLink({
  url: import.meta.env.VITE_API_URL ?? 'http://localhost:3000',
}),
```

```
# client/.env.local
VITE_API_URL=http://localhost:3000
```

```
# client/.env.production
VITE_API_URL=https://api.myapp.com
```

**Key Points**
- Vite exposes env variables prefixed with `VITE_` via `import.meta.env`.
- `.env.local` is gitignored by Vite's default `.gitignore` template and is appropriate for local secrets.
- Do not store sensitive credentials in `VITE_` variables — they are inlined into the client bundle.

---

### Setup Checklist

| Step | Location | Status Indicator |
|---|---|---|
| Install `@trpc/server`, `zod` | Server | Server starts without error |
| Install `@trpc/client`, `@trpc/react-query`, `@tanstack/react-query` | Client | No missing peer dependency warnings |
| Define `appRouter`, export `AppRouter` type | Server | TypeScript resolves `AppRouter` |
| Configure CORS or Vite proxy | Server or `vite.config.ts` | No CORS errors in browser console |
| Create `trpc` hook object with `createTRPCReact<AppRouter>()` | Client | Hook object is fully typed |
| Wrap app in `trpc.Provider` + `QueryClientProvider` | `main.tsx` | Hooks resolve without context error |