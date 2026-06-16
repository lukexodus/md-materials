## Client-Server Contract Without Code Generation

### What "Contract" Means in This Context

In traditional API design, a **contract** is the agreed-upon shape of requests and responses between a client and a server. Both sides must honor it — the server must produce what it promises, and the client must send what the server expects.

In REST or GraphQL with code generation, this contract is made explicit through artifacts: OpenAPI specs, `.graphql` schema files, or generated TypeScript types. These artifacts are produced, committed, and consumed as a separate step.

tRPC takes a different approach: **the contract is the TypeScript type system itself**, and no separate artifact is produced.

---

### The Problem Code Generation Solves (and Creates)

To understand tRPC's approach, it helps to understand why code generation exists in the first place.

**Why code generation is used:**

- Servers and clients are written in different languages or runtimes
- The API shape must be described in a language-neutral format (JSON Schema, Protocol Buffers, GraphQL SDL)
- Types for the client must be derived from that neutral format

**What code generation introduces:**

- A build step that must be run when the API changes
- A generated file that can fall out of sync with the actual implementation
- A layer of indirection between the real code and the types the client uses
- Tooling that must be configured, maintained, and understood by the team

**Key Point:** Code generation solves a real problem — sharing type information across a boundary — but it does so by creating an intermediate representation that can drift from the source of truth.

---

### How tRPC Eliminates the Intermediate Representation

tRPC works only in full-stack TypeScript environments where the server and client code exist in the same repository (or at minimum, share a TypeScript package). This constraint is what makes the approach possible.

Because both sides are TypeScript, the server's type definitions **are** the contract. There is no translation step.

```
┌─────────────────────────────────────────────┐
│              Your TypeScript Repo            │
│                                             │
│   Server (router definition)                │
│       │                                     │
│       │  TypeScript types flow directly     │
│       ▼                                     │
│   Client (uses inferred types)              │
│                                             │
│   No generated file. No build step.         │
└─────────────────────────────────────────────┘
```

The mechanism is TypeScript's `typeof` operator combined with tRPC's `inferRouterInputs` and `inferRouterOutputs` utility types. The client imports the **type** of the router — not the router itself — and tRPC uses that to type every call the client makes.

---

### The Router as the Source of Truth

In tRPC, the server defines a **router** — a collection of procedures, each with an input schema and an output shape.

```ts
// server/router.ts
import { z } from 'zod';
import { router, publicProcedure } from './trpc';

export const appRouter = router({
  getUser: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input }) => {
      return { id: input.id, name: 'Alice' };
    }),
});

export type AppRouter = typeof appRouter;
```

`AppRouter` is a pure TypeScript type. It carries no runtime code. It is the only thing the client needs to import from the server.

```ts
// client/trpc.ts
import { createTRPCClient } from '@trpc/client';
import type { AppRouter } from '../server/router'; // type-only import

const client = createTRPCClient<AppRouter>({ /* transport config */ });
```

**Key Point:** The `import type` directive means **zero server code crosses the client boundary at runtime**. Only type information is used, and only at compile time.

---

### What the Client Knows, and How

Once the client is typed with `AppRouter`, TypeScript can infer:

- Which procedures exist (`getUser`, etc.)
- What input each procedure expects (`{ id: string }`)
- What output each procedure returns (`{ id: string, name: string }`)

This is not tRPC doing anything special at runtime. It is TypeScript's standard structural type inference operating on the router's type.

```ts
// TypeScript knows the shape of this call without any generated file
const user = await client.getUser.query({ id: '123' });
//    ^? { id: string, name: string }
```

If you change the server — say, adding a required field to the input — TypeScript will produce a type error on the client **immediately**, in your editor, with no build step required.

---

### Comparison: Code Generation vs. tRPC's Approach

| Concern             | Code Generation (e.g., OpenAPI → TS)    | tRPC                                   |
| ------------------- | --------------------------------------- | -------------------------------------- |
| Source of truth     | Schema file (`.yaml`, `.graphql`, etc.) | Router definition (`.ts`)              |
| Type delivery       | Generated file, committed to repo       | Direct type inference                  |
| Sync mechanism      | Re-run generator after API changes      | TypeScript compiler (always live)      |
| Out-of-sync risk    | Yes — generator must be re-run          | Reduced — types derived from live code |
| Language constraint | None — works across languages           | Requires full-stack TypeScript         |
| Runtime overhead    | None (types stripped at build)          | None (types stripped at build)         |

> **Disclaimer:** "Reduced out-of-sync risk" is an [Inference] based on the architectural design. Actual behavior depends on how the project is structured, whether monorepo tooling is configured correctly, and whether the type-only import is maintained. Behavior is not guaranteed.

---

### The Boundary: What tRPC Does Not Do

It is worth being precise about what this approach does **not** provide:

- **No runtime validation on the client.** tRPC types are compile-time only. The client does not validate that the server's response matches the expected shape at runtime unless you add that explicitly.
- **No cross-language support.** If any part of your stack is not TypeScript (e.g., a mobile app in Swift, a service in Go), tRPC's contract mechanism does not apply to that boundary.
- **No versioning artifact.** Because there is no generated schema file, there is also no document you can diff, version, or share with external consumers. This is a tradeoff, not a flaw.

---

### Why This Matters for Developer Experience

The practical consequence of this design is that the feedback loop between server and client is collapsed.

In a code-generation workflow:

1. Change the server
2. Run the generator
3. Commit the generated file
4. Client now has updated types

In tRPC:

1. Change the server
2. Client immediately shows type errors (or not) in the editor

[Inference] This tighter loop is likely to reduce the category of bugs caused by a client calling an endpoint with stale type assumptions — but this depends on the team consistently using TypeScript strictly and not bypassing the type system with `any` or type assertions.

---

### Summary

tRPC replaces the code generation step by making TypeScript itself the contract mechanism. The server router's type is exported and consumed by the client as a pure type import. No intermediate schema file is produced, no generator is run, and no artifact can fall out of sync — because the type **is** the implementation.

This is only possible when both client and server are TypeScript and share access to the same type definitions. Within that constraint, it eliminates an entire class of tooling and a common source of API drift.