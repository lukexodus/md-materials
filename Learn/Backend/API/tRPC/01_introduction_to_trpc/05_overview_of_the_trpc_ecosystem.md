## Overview of the tRPC Ecosystem

### What "Ecosystem" Means Here

tRPC is not a single package — it is a small family of packages, adapters, and integrations that together cover different deployment targets, validation libraries, and framework combinations. This section maps that ecosystem so you know what exists, what each part does, and how the pieces relate.

---

### Core Packages

#### `@trpc/server`

The foundation. This package contains everything needed to define a router, procedures, context, and middleware on the server side. It has no dependency on any HTTP framework — it is transport-agnostic at its core.

**Provides:**
- `initTRPC` — the entry point for creating a tRPC instance
- `router()` — for composing procedures into a router
- `publicProcedure`, `middleware` — for defining procedure behavior
- Context creation utilities

This package is always required on the server.

#### `@trpc/client`

The client-side counterpart. It consumes the router type exported from `@trpc/server` and provides a typed client that can make procedure calls.

**Key point:** `@trpc/client` imports only the *type* of the router — no server code is included in the client bundle. The type import is erased at compile time.

```ts
import type { AppRouter } from "../server/router";
import { createTRPCClient } from "@trpc/client";
```

#### `@trpc/react-query`

An integration layer between tRPC and TanStack Query (formerly React Query). This is the most commonly used client package in React applications.

It wraps tRPC procedure calls in TanStack Query hooks, providing:
- `useQuery` for queries
- `useMutation` for mutations
- `useInfiniteQuery` for paginated queries
- `useSubscription` for subscriptions (where supported)

This package sits on top of `@trpc/client` — it does not replace it.

#### `@trpc/next`

A thin adapter that integrates tRPC with Next.js. It provides:
- A request handler compatible with Next.js API routes (Pages Router)
- Helper utilities for server-side rendering with tRPC
- Compatibility with `@trpc/react-query` in a Next.js context

For App Router usage in Next.js 13+, patterns differ from the Pages Router and are still evolving. [Inference: based on the pace of Next.js App Router development; specific recommendations may change]

---

### Adapters

tRPC's server core is framework-agnostic. Adapters connect `@trpc/server` to specific HTTP frameworks and runtimes.

| Adapter | Target |
|---|---|
| `fetchRequestHandler` | Fetch API — works with Next.js App Router, Cloudflare Workers, Deno |
| `nodeHTTPRequestHandler` | Node.js `http` / `https` modules directly |
| `@trpc/server/adapters/express` | Express.js |
| `@trpc/server/adapters/fastify` | Fastify |
| `@trpc/server/adapters/aws-lambda` | AWS Lambda |
| `@trpc/server/adapters/ws` | WebSockets (for subscriptions) |

These adapters are included in `@trpc/server` — no separate installation is required for most of them.

**Example — Express adapter:**

```ts
import express from "express";
import { createExpressMiddleware } from "@trpc/server/adapters/express";
import { appRouter } from "./router";

const app = express();

app.use(
  "/trpc",
  createExpressMiddleware({
    router: appRouter,
    createContext: () => ({}),
  })
);
```

---

### Input Validation Libraries

tRPC does not bundle a validation library. It accepts any validator that conforms to its expected interface — typically a schema object with a `parse` method. The most common choices are:

#### Zod

The most widely used pairing with tRPC. Zod schemas both validate input at runtime and contribute to TypeScript type inference.

```ts
import { z } from "zod";

publicProcedure
  .input(z.object({ id: z.number() }))
  .query(({ input }) => {
    // input is typed as { id: number }
  });
```

#### Yup

Supported via tRPC's validator interface. Less common in tRPC projects than Zod. [Inference: based on community usage patterns; no official usage statistics verified]

#### Valibot

A newer, modular alternative to Zod with a smaller bundle size. tRPC supports it via the same validator interface. [Unverified: level of community adoption and long-term maintenance trajectory not confirmed]

#### `@trpc/server`'s Own Validator Interface

tRPC exposes a `t.procedure.input()` method that accepts anything implementing:

```ts
{ parse: (input: unknown) => TOutput }
```

This means custom validators or other schema libraries can be integrated without official support, provided they match this shape. Behavior with non-standard validators may vary depending on implementation. [Inference]

---

### Framework Integrations

Beyond the official packages, tRPC has documented or community-supported patterns for:

#### Next.js (Pages Router)

The most established integration. Uses `@trpc/next` with `@trpc/react-query`. The T3 Stack is built on this combination.

#### Next.js (App Router)

Uses `fetchRequestHandler` with Route Handlers. Server Components can call tRPC procedures directly as server-side functions without going through HTTP, since both run on the server. Patterns here are newer and less settled. [Inference]

#### Remix

tRPC can be used with Remix via the Fetch adapter, but Remix's own data loading conventions (loaders and actions) overlap significantly with what tRPC provides. The combination is less common. [Inference]

#### SvelteKit

Community support exists for tRPC with SvelteKit via the Fetch adapter. Not officially maintained by the tRPC core team. [Unverified: stability and maintenance status not confirmed]

#### SolidStart

Similarly, community adapters exist. [Unverified]

---

### Subscriptions and WebSockets

tRPC supports real-time communication through subscriptions, using either:

- **WebSockets** via `@trpc/server/adapters/ws` and the `wsLink` on the client
- **Server-Sent Events (SSE)** via `httpSubscriptionLink` — available in tRPC v11+

Subscriptions use the `subscription` procedure type, which is distinct from `query` and `mutation`:

```ts
publicProcedure
  .subscription(() => {
    return observable<string>((emit) => {
      const interval = setInterval(() => emit.next("ping"), 1000);
      return () => clearInterval(interval);
    });
  });
```

> **Disclaimer:** Subscription support depends on the adapter and deployment environment. Not all hosting platforms support persistent WebSocket connections or SSE. Behavior varies by infrastructure.

---

### Links

On the client, tRPC uses a **link chain** — a pipeline of middleware-like units that process requests before they reach the server. This is analogous to middleware on the server side.

**Built-in links:**

| Link | Purpose |
|---|---|
| `httpBatchLink` | Batches multiple procedure calls into a single HTTP request |
| `httpLink` | Sends each call as a separate HTTP request |
| `wsLink` | Routes calls over a WebSocket connection |
| `httpSubscriptionLink` | Routes subscriptions over SSE |
| `splitLink` | Routes calls conditionally between two links |
| `loggerLink` | Logs requests and responses for debugging |
| `retryLink` | Retries failed requests |

**Example — splitting queries and subscriptions:**

```ts
const client = createTRPCClient<AppRouter>({
  links: [
    splitLink({
      condition: (op) => op.type === "subscription",
      true: wsLink({ client: wsClient }),
      false: httpBatchLink({ url: "/api/trpc" }),
    }),
  ],
});
```

---

### Batching

`httpBatchLink` merges multiple concurrent procedure calls into a single HTTP request, reducing round trips. The server automatically unbatches and processes them.

**Example — what happens under the hood:**

```
Client calls: trpc.getUser.query({ id: 1 })
              trpc.getPosts.query({ userId: 1 })

Without batching → 2 HTTP requests
With httpBatchLink → 1 HTTP request: GET /api/trpc/getUser,getPosts?batch=1&...
```

Batching is enabled by default when using `httpBatchLink`. It can be disabled per-call or globally. [Inference: specific batching behavior may vary by version]

---

### The T3 Stack

The T3 Stack is an opinionated full-stack TypeScript starter created by Theo (t3.gg). It is the most prominent community scaffold built around tRPC and has significantly influenced how tRPC is introduced to new developers.

**Composition:**
- Next.js
- tRPC
- Prisma
- Tailwind CSS
- NextAuth.js (optional)
- TypeScript throughout

The `create-t3-app` CLI scaffolds a project with all of these integrated. tRPC's growth in adoption is partly attributable to T3's popularity. [Inference]

---

### Developer Tooling

#### tRPC Panel

An unofficial UI for inspecting and calling tRPC procedures during development — similar in concept to GraphiQL or Swagger UI. [Unverified: maintenance status and feature completeness not confirmed]

#### tRPC OpenAPI

A community package (`trpc-openapi`) that generates an OpenAPI specification from a tRPC router. This allows tRPC to serve a REST-compatible API alongside its native interface, and enables Swagger UI integration.

> **Disclaimer:** `trpc-openapi` is a community package, not officially maintained by the tRPC core team. Compatibility with newer tRPC versions should be verified before use. [Unverified: current compatibility status]

#### TypeScript Language Server

Because tRPC's type safety is delivered through TypeScript's own inference, the primary "tooling" is the TypeScript language server itself — autocomplete, hover types, and inline errors work without any plugin.

---

### Version Landscape

As of the knowledge cutoff (August 2025), tRPC v11 is the current major version. Key changes from v10 to v11 include:

- Server-Sent Events support via `httpSubscriptionLink`
- Improved support for Next.js App Router
- Refined middleware and context APIs

> **Disclaimer:** Version-specific details may have changed after August 2025. Verify against the official tRPC changelog at [trpc.io](https://trpc.io) before applying version-specific guidance.

---

### Ecosystem Map

```
@trpc/server
  ├── Router & Procedure definitions
  ├── Middleware & Context
  └── Adapters
        ├── Express
        ├── Fastify
        ├── Fetch API (Next.js App Router, Cloudflare Workers)
        ├── AWS Lambda
        └── WebSockets

@trpc/client
  └── Typed client (imports router type only)

@trpc/react-query
  └── TanStack Query hooks (useQuery, useMutation, etc.)

@trpc/next
  └── Next.js Pages Router helpers

Validation (bring your own)
  ├── Zod (most common)
  ├── Valibot
  └── Yup

Community
  ├── trpc-openapi
  ├── tRPC Panel
  └── Framework adapters (SvelteKit, SolidStart, Remix)
```

---

**Conclusion**

The tRPC ecosystem is intentionally small and focused. The core packages cover server definition, client consumption, and React integration. Adapters extend it to different runtimes and frameworks. Validation is deliberately left to external libraries. The T3 Stack is currently the primary community vehicle through which tRPC reaches new developers, and its influence on tRPC's conventions is significant.

**Next Steps**

The next topic covers project setup: installing tRPC packages, initializing the server, and wiring up the client for the first time.