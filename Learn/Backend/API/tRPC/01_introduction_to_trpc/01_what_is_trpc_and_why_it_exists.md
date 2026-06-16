## What is tRPC and Why It Exists

### The Problem It Solves

Modern full-stack TypeScript applications typically separate their codebase into a frontend and a backend. Traditionally, these two sides communicate over HTTP using REST or GraphQL APIs. This introduces a persistent and painful problem: **type safety breaks at the network boundary**.

When a frontend developer calls a REST endpoint, they have no compile-time guarantee that:

- The endpoint actually exists
- The request payload matches what the server expects
- The response shape matches what the client assumes

Any mismatch is only discovered at runtime — often in production.

**Example** of the traditional problem:

```typescript
// Backend defines this response shape
type User = { id: number; name: string; email: string };

// Frontend assumes this shape (manually kept in sync — error-prone)
const res = await fetch("/api/user/1");
const user = await res.json(); // typed as `any` — no safety
console.log(user.emal); // typo — no error at compile time
```

This mismatch between backend contracts and frontend consumption is what tRPC was designed to eliminate.

---

### What tRPC Is

**tRPC** (TypeScript Remote Procedure Call) is an open-source library that allows you to build fully type-safe APIs without schemas, code generation, or a separate API description language. It does this by sharing TypeScript types directly between your server and client.

It is **not** a runtime data serialization format. It is **not** a replacement for HTTP. It is a developer experience layer that infers and propagates types from your backend router definitions to your frontend calls — all within a single TypeScript project (or monorepo).

**Key Points:**
- No code generation step required
- No schema definition language (unlike GraphQL's SDL or OpenAPI's YAML)
- Types flow automatically via TypeScript's inference system
- Works with existing HTTP adapters (Next.js, Express, Fastify, etc.)

---

### Core Concept: The Router as the Contract

In tRPC, the server defines **procedures** (queries, mutations, subscriptions) inside a **router**. The router's TypeScript type is then exported and used on the client side. The client never imports any runtime server code — only the *type* of the router.

```typescript
// server/router.ts
import { initTRPC } from '@trpc/server';

const t = initTRPC.create();

export const appRouter = t.router({
  getUser: t.procedure
    .input(z.object({ id: z.number() }))
    .query(({ input }) => {
      return { id: input.id, name: 'Alice', email: 'alice@example.com' };
    }),
});

// Export only the TYPE — no runtime code crosses to the client
export type AppRouter = typeof appRouter;
```

```typescript
// client/index.ts
import { createTRPCClient } from '@trpc/client';
import type { AppRouter } from '../server/router'; // type-only import

const client = createTRPCClient<AppRouter>({ ... });

const user = await client.getUser.query({ id: 1 });
console.log(user.name);  // fully typed — autocomplete works
console.log(user.emal);  // ❌ TypeScript compile error — caught immediately
```

---

### Why It Exists: Historical Context

Before tRPC (created by Alex Johansson, first released around 2021), the common approaches to typed API communication were:

| Approach | Problem |
|---|---|
| REST + manual types | Types drift from reality; no enforcement |
| OpenAPI + codegen | Requires schema maintenance; codegen adds friction |
| GraphQL | Powerful but heavy; requires SDL, resolvers, codegen, separate client setup |
| Shared monorepo types | Informal; no enforcement of input/output contracts |

tRPC emerged as a lightweight alternative specifically for **TypeScript monorepos or full-stack frameworks** (like Next.js) where the client and server share the same codebase or package boundary. It trades protocol universality (REST/GraphQL can serve any client) for maximum developer ergonomics within a TypeScript-only environment.

---

### What tRPC Is Not

Understanding tRPC's boundaries is important:

- **Not a REST API.** tRPC uses HTTP under the hood, but does not conform to REST conventions.
- **Not suitable for public APIs.** Because tRPC's type safety depends on TypeScript consumers, it is not designed for third-party API consumption. [Inference: Teams building public APIs consumed by non-TypeScript clients would not benefit from tRPC's core value proposition — behavior may vary by use case.]
- **Not a database ORM or query builder.** It handles transport and type safety only; data fetching logic is your responsibility.
- **Not framework-specific.** While often associated with Next.js (via `create-t3-app`), tRPC has adapters for Express, Fastify, Nuxt, SolidStart, and others.

---

### The End-to-End Type Safety Guarantee

The phrase **"end-to-end type safety"** is commonly used to describe tRPC. To be precise about what this means:

[Inference] tRPC propagates types from procedure definitions to client calls through TypeScript's structural type system. This means that if you change a procedure's output shape on the server, the TypeScript compiler will surface type errors on the client at build time — provided both sides share the same `AppRouter` type.

> **Disclaimer:** This behavior depends on your TypeScript configuration, build tooling, and whether the type-only import boundary is correctly maintained. Actual behavior may vary by project setup.

---

### Where tRPC Fits in the Stack

```
┌─────────────────────────────────────────┐
│           Frontend (React, etc.)        │
│  tRPC Client  ←── AppRouter Type ───┐  │
└────────────────────────────┬────────┼──┘
                             │ HTTP   │ Type only
                             ▼        │
┌─────────────────────────────────────┴──┐
│           Backend (Node.js)            │
│  tRPC Router → Procedures → Handlers  │
└─────────────────────────────────────────┘
```

The HTTP request/response still happens normally. tRPC wraps it with a type-aware client and server layer so that the TypeScript compiler can reason about both ends simultaneously.

---

### Summary

**Conclusion:**

tRPC exists because TypeScript's type system stops at module boundaries, and HTTP is a module boundary. Traditional API approaches require manual effort — schemas, codegen, or informal conventions — to bridge that gap. tRPC removes that gap for TypeScript full-stack projects by making the server router's type the single source of truth, inferred automatically by the compiler on both sides. The result is faster development, fewer runtime errors from API mismatches, and a significantly improved developer experience within TypeScript ecosystems.