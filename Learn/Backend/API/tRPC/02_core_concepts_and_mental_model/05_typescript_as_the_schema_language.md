## TypeScript as the Schema Language in tRPC

### What "Schema Language" Means Here

In many API frameworks, you define your API's shape using a dedicated schema format — OpenAPI YAML, GraphQL SDL, Protobuf files, and so on. These schemas are separate artifacts that describe what the API accepts and returns, and code is either generated from them or validated against them at runtime.

tRPC takes a different approach: **TypeScript itself is the schema**. The types you write in TypeScript — for inputs, outputs, and errors — are the authoritative description of your API's contract. There is no separate schema file, no code generation step, and no secondary format to keep in sync.

---

### How TypeScript Types Become the Contract

When you define a tRPC procedure, you annotate it with TypeScript types (often inferred from a validator). That type information is what the client uses to know what it can send and what it will receive.

**Example**

```ts
// server/router.ts
import { z } from 'zod';
import { publicProcedure, router } from './trpc';

export const appRouter = router({
  greet: publicProcedure
    .input(z.object({ name: z.string() }))
    .query(({ input }) => {
      return { message: `Hello, ${input.name}` };
    }),
});

export type AppRouter = typeof appRouter;
```

The exported `AppRouter` type encodes the entire API surface — procedure names, input shapes, and return types — as a TypeScript type. No schema file is produced. The type *is* the schema.

On the client:

```ts
// client.ts
import { createTRPCProxyClient, httpBatchLink } from '@trpc/client';
import type { AppRouter } from '../server/router';

const trpc = createTRPCProxyClient<AppRouter>({
  links: [httpBatchLink({ url: 'http://localhost:3000/api/trpc' })],
});

// TypeScript knows: input must have { name: string }
// TypeScript knows: result has { message: string }
const result = await trpc.greet.query({ name: 'Luke' });
```

The client imports only the *type* of `AppRouter` — not the implementation. This import is erased at compile time and has zero runtime cost.

---

### The Role of Validators

TypeScript types alone are a compile-time construct. They do not exist at runtime and cannot validate incoming HTTP request payloads. tRPC bridges this gap by integrating with runtime validators.

The most common pairing is with **Zod**, though tRPC supports others (Yup, Valibot, ArkType, and custom validators via its inference interface).

When you pass a Zod schema to `.input()`:

1. **At runtime** — the Zod schema validates the raw incoming data.
2. **At compile time** — tRPC infers the TypeScript type from the Zod schema and applies it to the procedure signature.

This means the runtime validator and the compile-time type stay in sync automatically, because they are derived from the same source — the Zod schema object.

**Key Point:** You write the shape once (as a Zod schema). tRPC gives you both runtime safety and compile-time types from that single definition.

---

### Type Inference vs. Type Annotation

tRPC leans heavily on TypeScript's **type inference** rather than manual type annotation. You rarely write explicit return types for procedures. Instead, TypeScript infers the return type from whatever the resolver function actually returns.

```ts
// The return type { message: string } is inferred — not written manually.
.query(({ input }) => {
  return { message: `Hello, ${input.name}` };
});
```

**Key Point:** If you change what the resolver returns, the client-side type updates automatically on the next TypeScript check. No schema regeneration, no manual type update.

This is a meaningful difference from code-generation workflows, where you must regenerate types after changing a schema, and the client can be out of sync in the interval between changes.

---

### What Is Shared Between Server and Client

In a tRPC project, the boundary between server and client is explicit:

| What is shared | How it is shared |
|---|---|
| `AppRouter` type | Imported as a type-only import |
| Input/output shapes | Inferred from the router type |
| Procedure names | Encoded in the router type |
| Implementation code | Never shared; stays on the server |
| Zod schemas | Optionally shared, but not required |

The client never imports server implementation code. Only the type flows across the boundary, and only at compile time.

---

### Structural Typing and Its Implications

TypeScript uses **structural typing**: a type is compatible with another if its shape matches, regardless of its declared name. This has practical implications for tRPC.

If a procedure returns an object with fields `{ id: number, name: string }`, the client type will reflect exactly that structure. If you later add a field on the server, the client type gains that field automatically. If you remove a field, the client type loses it, and any client code referencing the removed field becomes a compile error.

[Inference] This structural coupling is what makes tRPC's approach feel cohesive — changes propagate through the type system rather than through a schema diff tool. However, this also means the TypeScript compiler is load-bearing in your development workflow. Behavior at runtime depends on the validator, not the TypeScript type, and TypeScript's guarantees apply only within a correctly typed codebase.

---

### Limitations of TypeScript as the Schema

Using TypeScript as the schema has real constraints worth understanding.

**It is a compile-time boundary only.** TypeScript types are erased at runtime. If you call a tRPC endpoint from a non-TypeScript client, or via raw HTTP, you get no type safety — only whatever runtime validation the validator provides.

**It requires a shared type boundary.** The `AppRouter` type must be accessible to the client. In a monorepo this is straightforward. Across separate repositories, it requires publishing the type (e.g., as an npm package), which introduces its own versioning and synchronization considerations.

**It does not produce a language-agnostic schema.** Unlike OpenAPI or Protobuf, the tRPC type contract is not portable to other languages or tooling ecosystems without additional tooling (such as `trpc-openapi`). [Inference] This makes tRPC a stronger fit for TypeScript-only stacks than for polyglot systems.

**Types do not enforce runtime behavior.** A TypeScript type that says a field is `string` does not prevent a misconfigured server from returning something else at runtime. The validator handles that. If no input validator is provided for a procedure, tRPC does not validate incoming data, regardless of what the TypeScript type says.

---

### Summary

| Concept | tRPC approach |
|---|---|
| Schema format | TypeScript types (inferred from validators) |
| Runtime validation | Delegated to Zod or equivalent |
| Code generation | Not required |
| Client-server sync | Via shared `AppRouter` type |
| Cross-language support | Not native; requires additional tooling |
| Type source of truth | The router definition itself |

**Conclusion:** TypeScript as the schema language means the type system does the work that schema files and code generators do in other frameworks. The tradeoff is a tight coupling to TypeScript and a reliance on the compiler as a correctness tool — which is a sound tradeoff for TypeScript-first projects, but a constraint to evaluate carefully for anything beyond that.