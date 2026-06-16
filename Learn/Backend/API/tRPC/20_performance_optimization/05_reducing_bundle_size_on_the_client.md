## Reducing Bundle Size on the Client

tRPC's client-side footprint is modest by design, but the surrounding ecosystem — React Query, Zod, superjson, custom links — contributes meaningfully to bundle size. In applications where JavaScript payload is a performance constraint, deliberate choices at each layer reduce what is shipped to the browser.

---

### What Contributes to Bundle Size

Before optimizing, identify what is actually being bundled. The relevant packages in a typical tRPC client setup are:

| Package | Approximate Minified + Gzipped Size | Role |
| --- | --- | --- |
| `@trpc/client` | ~8–12KB | Core client, links |
| `@trpc/react-query` | ~4–6KB | React Query integration |
| `@tanstack/react-query` | ~12–16KB | Server state management |
| `zod` | ~12–15KB | Input validation (if imported client-side) |
| `superjson` | ~6–8KB | Data transformer |
| Router type import | 0KB (type-only) | Type safety; erased at compile time |

[Unverified: package sizes vary by version and change frequently. Measure your actual bundle using the tools described below rather than relying on these approximations.]

---

### Measure Before Optimizing

Optimizing without measurement produces effort with unknown impact. Two tools are standard for Next.js and Vite projects.

**Next.js — `@next/bundle-analyzer`:**

```bash
npm install --save-dev @next/bundle-analyzer
```

```ts
// next.config.ts
import withBundleAnalyzer from '@next/bundle-analyzer';

export default withBundleAnalyzer({
  enabled: process.env.ANALYZE === 'true',
})({
  // your Next.js config
});
```

```bash
ANALYZE=true npm run build
```

**Vite — `rollup-plugin-visualizer`:**

```bash
npm install --save-dev rollup-plugin-visualizer
```

```ts
// vite.config.ts
import { defineConfig } from 'vite';
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    visualizer({ open: true, gzipSize: true }),
  ],
});
```

Run `vite build` and the visualizer opens automatically in the browser, showing a treemap of all modules and their sizes.

---

### Keep Router Types Server-Only

The tRPC router type (`AppRouter`) is imported client-side solely for type inference. Because it is imported using `import type`, it is erased entirely at compile time and contributes zero bytes to the bundle.

```ts
// Correct — type-only import, zero bundle impact
import type { AppRouter } from '../server/router';

const trpc = createTRPCProxyClient<AppRouter>({ links: [...] });
```

```ts
// Incorrect — value import, pulls in server-side code
import { appRouter } from '../server/router';
```

**Key Points**

- If your bundler warns about server-only modules appearing in the client bundle, the most likely cause is a value import of the router rather than a type-only import.
- In Next.js, importing server-side code into a client component produces a build error when server-only packages (e.g., database drivers) are transitively included. The `import type` pattern prevents this.

---

### Avoid Importing Zod Client-Side

Zod schemas defined in the server router are used for input validation. They should never be imported into client-side code. The router type carries only the TypeScript types derived from the Zod schemas — not the Zod runtime itself.

**Problematic pattern:**

```ts
// client component — inadvertently imports Zod
import { userSchema } from '../server/schemas/user';

function MyForm() {
  // Using userSchema for client-side validation — pulls in Zod
  const parsed = userSchema.parse(formData);
}
```

**Preferred pattern — separate client and server schemas:**

```ts
// src/shared/schemas/user.client.ts
// A lightweight client-side validation that does not import Zod
export function validateUserForm(data: unknown): { name: string; email: string } | null {
  if (
    typeof data === 'object' &&
    data !== null &&
    typeof (data as any).name === 'string' &&
    typeof (data as any).email === 'string'
  ) {
    return data as { name: string; email: string };
  }
  return null;
}
```

If Zod is genuinely needed client-side (e.g., for form validation with react-hook-form), use a lazy import or a dedicated client validation library such as `valibot` (~1KB gzipped) as an alternative.

---

### Replace superjson with a Lighter Transformer

superjson supports rich types (`Date`, `Map`, `Set`, `BigInt`, `undefined`) at the cost of ~6–8KB. If your application does not use these types across the client–server boundary, a lighter transformer reduces bundle size.

**Option 1 — No transformer (default):**

If all data exchanged between client and server is JSON-serializable (`string`, `number`, `boolean`, `null`, `object`, `array`), omit the transformer entirely.

```ts
// Both client and server must agree — no transformer on either side
export const trpc = createTRPCProxyClient<AppRouter>({
  links: [httpBatchLink({ url: '/api/trpc' })],
  // No transformer
});
```

```ts
// server
const t = initTRPC.create(); // No transformer
```

**Option 2 — `devalue` (~2KB gzipped):**

`devalue` handles cyclical references and some extended types without the full superjson overhead.

```bash
npm install devalue
```

[Inference: a custom tRPC transformer adapter for `devalue` requires wrapping it to conform to the `DataTransformerOptions` interface. Verify whether a community package provides this before writing one manually.]

**Option 3 — `valibot` as a schema alternative:**

If superjson was introduced primarily to handle `Date` serialization and you can normalize dates to ISO strings, removing superjson and standardizing on ISO strings across the API eliminates the dependency entirely.

---

### Use `httpLink` Instead of `httpBatchLink` When Batching Is Unnecessary

`httpBatchLink` includes batching logic that `httpLink` does not. The size difference is small, but in edge deployments or minimal clients where every byte counts, `httpLink` is the leaner choice.

[Inference: the size difference between `httpBatchLink` and `httpLink` is small — likely under 1KB — and may not justify the trade-off of losing batching for most applications. Measure before switching.]

---

### Lazy-Load the tRPC Client

In applications where tRPC is not needed on the initial render (e.g., it is only used behind a login gate or on a specific route), the client initialization can be deferred.

**Next.js App Router — lazy client initialization:**

```ts
// src/utils/trpc.lazy.ts
let _trpc: ReturnType<typeof createTRPCProxyClient<AppRouter>> | null = null;

export function getTRPCClient() {
  if (!_trpc) {
    const { createTRPCProxyClient, httpBatchLink } = require('@trpc/client');
    _trpc = createTRPCProxyClient<AppRouter>({
      links: [httpBatchLink({ url: '/api/trpc' })],
    });
  }
  return _trpc;
}
```

[Inference: dynamic `require()` inside a function body prevents static analysis from including the module in the initial chunk. Bundler behavior varies; verify that your bundler actually splits the chunk as expected by inspecting the output.]

---

### Tree-Shaking tRPC Links

Only import the links you use. Named exports from `@trpc/client` are tree-shakeable in bundlers that support ES module static analysis.

```ts
// Import only what is used
import { createTRPCProxyClient, httpBatchLink } from '@trpc/client';

// Avoid importing the entire module namespace
import * as trpcClient from '@trpc/client'; // prevents tree-shaking
```

Verify that your bundler is configured for tree-shaking. In Vite, this is enabled by default. In webpack, `mode: 'production'` enables it.

---

### Separate Client and Server Code Boundaries

In Next.js App Router, server components run on the server and are never included in the client bundle. Procedures called from server components do not require shipping any tRPC client code to the browser.

```ts
// app/posts/page.tsx — Server Component
// This code runs on the server. No tRPC client is included in the browser bundle.
import { createCaller } from '../../server/router';
import { createContext } from '../../server/context';

export default async function PostsPage() {
  const ctx = await createContext();
  const caller = createCaller(ctx);
  const posts = await caller.public.getPosts();

  return (
    <ul>
      {posts.map((post) => <li key={post.id}>{post.title}</li>)}
    </ul>
  );
}
```

```ts
// app/posts/InteractiveWidget.tsx — Client Component
'use client';
// Only this component ships the tRPC client to the browser
import { trpc } from '../../utils/trpc';

export function InteractiveWidget() {
  const { data } = trpc.public.getPosts.useQuery();
  return <div>{/* ... */}</div>;
}
```

**Key Points**

- Server components calling `createCaller` directly produce zero client bundle impact for those data fetches.
- Client components using `trpc.*.useQuery()` include the tRPC client, React Query, and related code in the browser bundle.
- The goal is to minimize the surface area of client components that import from `@trpc/react-query`.

---

### Code Splitting tRPC-Heavy Routes

In single-page applications without a framework that handles server components, code-split routes that use tRPC so the client code loads only when the route is visited.

**React with React Router — lazy route:**

tsx

```
import { lazy, Suspense } from 'react';
import { Route } from 'react-router-dom';

const Dashboard = lazy(() => import('./pages/Dashboard'));
// Dashboard.tsx imports @trpc/react-query — loaded only when /dashboard is visited

export function AppRoutes() {
  return (
    <Route
      path="/dashboard"
      element={
        <Suspense fallback={<div>Loading...</div>}>
          <Dashboard />
        </Suspense>
      }
    />
  );
}
```

---

### `TRPCClientError` — Avoid Importing Unnecessarily

`TRPCClientError` is used for error type narrowing. If you only need to check the error code without the class, extract what you need from the error object directly rather than importing the class.

```ts
// Imports TRPCClientError — adds to bundle
import { TRPCClientError } from '@trpc/client';
if (error instanceof TRPCClientError) { ... }

// Alternative — no import needed for simple code checks
if (
  typeof error === 'object' &&
  error !== null &&
  'data' in error &&
  (error as any).data?.code === 'UNAUTHORIZED'
) { ... }
```

[Inference: `TRPCClientError` is likely already included in the bundle if `@trpc/client` is used at all, since it is part of the core module. The benefit of avoiding the import depends on whether your bundler can tree-shake it independently. Measure before applying this optimization.]

---

### Bundle Composition Diagram

```
flowchart TD
    subgraph Server["Server Bundle (never sent to browser)"]
        RT[appRouter — full router]
        ZS[Zod schemas]
        DB[Database client]
        MW[Middleware]
    end

    subgraph Client["Client Bundle (shipped to browser)"]
        TC[@trpc/client — links]
        TRQ[@trpc/react-query]
        RQ[@tanstack/react-query]
        TY[AppRouter — type only, 0 bytes]
        SJ[superjson — optional]
    end

    Server -.->|import type only| TY
    TY -.->|erased at compile time| Client
```

---

### Optimization Impact Summary

| Optimization | Estimated Saving | Complexity |
| --- | --- | --- |
| `import type` for router | Prevents server code leaking | Low |
| Remove superjson (if unused types) | ~6–8KB | Low–Medium |
| Separate Zod to server-only | ~12–15KB (if Zod removed entirely) | Medium |
| Server components for data fetching | Eliminates `@trpc/react-query` per route | Medium |
| Code-split tRPC-heavy routes | Defers full client until needed | Medium |
| Lazy-load tRPC client | Defers initialization cost | Medium |
| `httpLink` over `httpBatchLink` | <1KB | Low |

[Unverified: the savings estimates above are approximate and depend on your exact package versions and what else is in your bundle. Always measure after applying any optimization.]

---

### Common Pitfalls

**Optimizing without measuring** — Bundle size changes interact with tree-shaking, code splitting, and chunking in non-obvious ways. An optimization that appears significant in isolation may have no effect on the final gzipped output if the module was already shared in a common chunk.

**Removing superjson when `Date` is used across the boundary** — `Date` objects serialize to strings via `JSON.stringify`. If server procedures return `Date` values and the client treats them as `Date` objects, removing superjson silently converts them to strings, producing type errors or runtime bugs.

**Importing Zod in client components via a shared barrel file** — A `src/shared/index.ts` that re-exports both client and server utilities causes Zod, database types, and other server-only code to be pulled into the client bundle. Keep server and client exports in separate files.

**Assuming `import type` is enforced** — TypeScript enforces `import type` only with `"verbatimModuleSyntax": true` or `"importsNotUsedAsValues": "error"` in `tsconfig.json`. Without these, a developer may accidentally convert a type import to a value import and introduce server code into the client bundle silently.

```json
// tsconfig.json — enforce type-only imports
{
  "compilerOptions": {
    "verbatimModuleSyntax": true
  }
}
```

**Over-optimizing small packages** — `@trpc/client` at ~10KB gzipped is smaller than a single unoptimized image. Focus bundle optimization effort on the largest contributors first; micro-optimizations on already-small packages yield diminishing returns relative to image optimization, font subsetting, or code splitting large routes.

---

### Summary

Reducing tRPC client bundle size centers on three principles: keep server code on the server (router types as `import type`, Zod server-only, `createCaller` in server components); minimize client-side dependencies (remove superjson if rich types are not needed, tree-shake unused links); and defer loading (code-split tRPC-heavy routes, lazy-initialize the client). Measure with a bundle analyzer before and after each change — bundle optimization has many non-obvious interactions with chunking and tree-shaking that make intuition unreliable without data.