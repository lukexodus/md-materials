## Installing tRPC Server and Client Packages

### Overview

tRPC is distributed as a set of focused packages. You install only what your stack requires. This section covers what each package does, how to install it, and how the packages relate to one another.

---

### Package Architecture

tRPC separates server-side and client-side concerns into distinct packages. They do not bundle together.

```
@trpc/server        — router, procedures, context, adapters
@trpc/client        — vanilla HTTP client
@trpc/react-query   — React integration (wraps @trpc/client + TanStack Query)
@trpc/next          — Next.js-specific helpers
```

`@trpc/server` is always required on the server. Everything else is additive depending on your client environment.

---

### Installing the Server Package

```bash
# npm
npm install @trpc/server

# pnpm
pnpm add @trpc/server

# yarn
yarn add @trpc/server
```

`@trpc/server` contains:

- `initTRPC` — the entry point for creating your tRPC instance
- Procedure builders (`publicProcedure`, etc.)
- The `router()` function
- All server-side adapters (Express, Fastify, Fetch, standalone, etc.)
- Middleware utilities
- Error classes (`TRPCError`)

There are no required peer dependencies for `@trpc/server` beyond Node.js itself and a TypeScript-compatible environment.

---

### Installing the Client Package

```bash
npm install @trpc/client
```

`@trpc/client` contains:

- `createTRPCProxyClient` — the primary vanilla client factory
- Link primitives (`httpLink`, `httpBatchLink`, `splitLink`, etc.)
- Client-side error types
- WebSocket client support (via `wsLink`)

**Key Point:** `@trpc/client` requires a `fetch`-compatible API at runtime. In Node.js 18+, this is available natively. In Node.js 16 and below, you must polyfill it.

**Polyfilling `fetch` in older Node.js versions**

```bash
npm install node-fetch
```

```ts
// At the top of your client entry point
import fetch from 'node-fetch';

const trpc = createTRPCProxyClient<AppRouter>({
  links: [
    httpBatchLink({
      url: 'http://localhost:3000/api/trpc',
      fetch: fetch as typeof globalThis.fetch,
    }),
  ],
});
```

[Inference] Passing a custom `fetch` implementation via the link options is the intended escape hatch for environments where `globalThis.fetch` is unavailable. Behavior depends on the compatibility of the polyfill with the Fetch API spec.

---

### Installing the React Integration

If you are using React, install the React adapter and its peer dependency TanStack Query together.

```bash
npm install @trpc/react-query @tanstack/react-query
```

**Version pairing matters.** `@trpc/react-query` is built against a specific major version of `@tanstack/react-query`. As of tRPC v11, the required peer is `@tanstack/react-query` v5.

[Unverified — confirm peer dependency requirements against the `@trpc/react-query` package.json for your installed version, as this changes across tRPC major releases.]

Mismatched versions between `@trpc/react-query` and `@tanstack/react-query` are a common source of type errors and runtime failures. Check both versions explicitly.

```bash
# Verify installed versions
npm list @trpc/react-query @tanstack/react-query
```

---

### Installing the Next.js Adapter

For Next.js projects using the Pages Router:

```bash
npm install @trpc/next
```

`@trpc/next` provides:

- `createNextApiHandler` — mounts the tRPC router on a Next.js API route
- SSR/SSG helpers (`createServerSideHelpers`)
- Next.js-specific type utilities

For Next.js App Router, `@trpc/next` is not used. You use the Fetch adapter from `@trpc/server/adapters/fetch` and wire it manually into a Route Handler. [Inference] This reflects the architectural shift in App Router toward standard web APIs rather than Next.js-specific abstractions.

---

### Full Installation by Stack

**Minimal — server only (e.g., Express API)**

```bash
npm install @trpc/server zod
npm install express
npm install --save-dev @types/express
```

**Next.js Pages Router (full stack)**

```bash
npm install @trpc/server @trpc/client @trpc/react-query @trpc/next
npm install @tanstack/react-query zod
```

**Next.js App Router (full stack)**

```bash
npm install @trpc/server @trpc/client @trpc/react-query
npm install @tanstack/react-query zod
```

**Vanilla client only (non-React frontend)**

```bash
npm install @trpc/client zod
```

**Standalone Node.js server with vanilla client**

```bash
npm install @trpc/server @trpc/client zod
```

---

### Verifying the Installation

After installing, verify that TypeScript can resolve the packages and that your `tsconfig.json` is compatible.

```bash
npx tsc --noEmit
```

If TypeScript cannot find types for a package, confirm that `skipLibCheck` is set appropriately in your `tsconfig.json`, and that you are not mixing ESM and CJS module resolution in a way that confuses the resolver.

You can also spot-check the installed versions directly:

```bash
npm list @trpc/server @trpc/client @trpc/react-query
```

**Example output**

```
your-project@1.0.0
├── @trpc/client@11.x.x
├── @trpc/react-query@11.x.x
└── @trpc/server@11.x.x
```

All tRPC packages in a project should be on the same major version. Mixing major versions (e.g., `@trpc/server@10` with `@trpc/client@11`) is not supported and will produce type errors or runtime failures.

---

### Keeping Versions in Sync

Because tRPC's type safety depends on shared types flowing between `@trpc/server` and `@trpc/client`, version mismatches between these packages break the type contract.

**Key Point:** Always install all `@trpc/*` packages at the same version. Use an exact version or a consistent range across your `package.json`.

In a monorepo, enforce this with a shared root `package.json` or a workspace protocol:

```json
// packages/api/package.json
{
  "dependencies": {
    "@trpc/server": "11.x.x"
  }
}

// apps/web/package.json
{
  "dependencies": {
    "@trpc/client": "11.x.x",
    "@trpc/react-query": "11.x.x"
  }
}
```

[Inference] Package managers like pnpm with workspace protocols (`workspace:*`) make this easier to enforce, but version discipline is ultimately the developer's responsibility regardless of tooling.

---

### What Is Not Installed With tRPC

tRPC deliberately excludes the following from its packages:

- **A validation library** — you bring your own (Zod, Valibot, etc.)
- **An HTTP server** — you bring your own (Express, Fastify, Next.js, etc.)
- **A React state manager** — `@trpc/react-query` delegates to TanStack Query
- **A WebSocket server** — you bring your own if using subscriptions

This separation keeps tRPC's own surface area small and avoids duplicating functionality that other well-maintained libraries already handle.