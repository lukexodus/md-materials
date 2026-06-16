## End-to-End Type Safety Explained

### What "End-to-End Type Safety" Means

"End-to-end type safety" is one of tRPC's most cited properties, but the phrase is often used without precision. This section defines it carefully, shows how tRPC achieves it mechanically, and distinguishes it from weaker forms of type safety that are sometimes conflated with it.

**A precise definition:**

End-to-end type safety means that a single type definition — written once — flows from the server through to the client, such that a change in the server's input or output shape produces a type error at the call site in the client without any manual synchronization step.

This is distinct from:
- Having types on both the server and the client independently (parallel types)
- Generating client types from a schema file (codegen-based types)
- Runtime validation that throws errors on shape mismatches

All three of those approaches provide some safety. tRPC's model is specifically about **inference without an intermediate artifact**.

---

### The Problem tRPC Solves

Consider a standard REST setup without any schema tooling:

**Server (Express):**

```ts
app.get("/user", (req, res) => {
  res.json({ id: 1, name: "Alice", role: "admin" });
});
```

**Client (fetch):**

```ts
const res = await fetch("/user");
const user = await res.json();
// user is typed as `any`
// Nothing stops: user.naem, user.Role, user.nonExistentField
```

The client has no knowledge of what the server returns. TypeScript cannot help here because `fetch` returns `Promise<any>`. The developer must either:

- Cast manually: `const user = data as User` — which is an assertion, not a guarantee
- Maintain a shared type file — which drifts silently when the server changes
- Run a codegen tool — which requires a pipeline and a separate schema artifact

Each of these introduces a gap where the type system stops enforcing correctness.

---

### How tRPC Closes the Gap

tRPC uses TypeScript's **structural type inference** to propagate types from the server procedure definition to the client call site. There is no intermediate file, no schema language, and no generation step.

The mechanism works in three stages:

---

#### Stage 1 — The Procedure Defines the Shape

When a procedure is defined on the server, TypeScript infers the output type from the return value:

```ts
const appRouter = t.router({
  getUser: t.procedure
    .input(z.object({ id: z.number() }))
    .query(({ input }) => {
      return { id: input.id, name: "Alice", role: "admin" };
      //     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      //     TypeScript infers: { id: number; name: string; role: string }
    }),
});
```

The return type is inferred — it does not need to be declared explicitly. If the return value changes, the inferred type changes with it.

---

#### Stage 2 — The Router Type Is Exported

The router's type — not its runtime value — is exported from the server module:

```ts
export type AppRouter = typeof appRouter;
```

`AppRouter` is a pure TypeScript type. It contains the complete type signature of every procedure: their names, input types, and output types. It has zero runtime presence — it is erased during compilation.

---

#### Stage 3 — The Client Imports the Type

The client imports `AppRouter` as a type-only import and passes it to the tRPC client factory:

```ts
import type { AppRouter } from "../server/router";
import { createTRPCClient, httpBatchLink } from "@trpc/client";

const trpc = createTRPCClient<AppRouter>({
  links: [httpBatchLink({ url: "/api/trpc" })],
});
```

From this point, `trpc` is a fully typed proxy object. Every procedure on the router is accessible as a typed method:

```ts
const user = await trpc.getUser.query({ id: 1 });
//    ^^^^
//    Typed as: { id: number; name: string; role: string }
//    Inferred directly from the server procedure's return value
```

---

### What TypeScript Enforces at Each Point

Once the type flows through, TypeScript enforces correctness at every interaction point:

#### Input validation at the call site

```ts
// Correct
trpc.getUser.query({ id: 1 });

// Type error — id must be a number
trpc.getUser.query({ id: "one" });
//                        ^^^^^
//                        Argument of type 'string' is not assignable to 'number'
```

#### Output shape on the result

```ts
const user = await trpc.getUser.query({ id: 1 });

console.log(user.name);  // ✓ valid
console.log(user.naem);  // ✗ type error — property 'naem' does not exist
console.log(user.email); // ✗ type error — property 'email' does not exist
```

#### Propagation into consuming code

```ts
function displayUser(user: { name: string; role: string }) {
  return `${user.name} (${user.role})`;
}

const user = await trpc.getUser.query({ id: 1 });
displayUser(user); // ✓ compatible — TypeScript verifies the shape matches
```

---

### The Inference Chain Visualized

```
Server procedure return value
         │
         │  TypeScript infers output type
         ▼
  AppRouter type (typeof appRouter)
         │
         │  Exported as type-only
         ▼
  createTRPCClient<AppRouter>
         │
         │  tRPC constructs typed proxy
         ▼
  trpc.getUser.query(...)
         │
         │  Input checked against z.object({ id: z.number() })
         │  Output typed as { id: number; name: string; role: string }
         ▼
  Consuming code — TypeScript enforces shape
```

No step in this chain requires a manually written type, a schema file, or a code generation command.

---

### How This Differs From Codegen-Based Type Safety

GraphQL with codegen (e.g., GraphQL Code Generator) also provides types on the client. The difference is structural:

| Property | tRPC | GraphQL + Codegen |
|---|---|---|
| Source of truth | TypeScript return type | GraphQL SDL schema |
| Sync mechanism | TypeScript compiler | Codegen pipeline must be re-run |
| Intermediate artifact | None | Generated `.ts` files |
| Staleness risk | None — types are always current | Yes — if codegen is not re-run after schema change |
| Language requirement | TypeScript only | Any language |

With codegen, there is a window between a schema change and the next codegen run during which the client types are stale. tRPC has no equivalent window — if the server return type changes, the client type changes in the same TypeScript compilation.

> **Disclaimer:** The claim that tRPC types are "always current" assumes both server and client code are compiled together or share a type resolution path. In setups where they are compiled independently without access to the server's type, this property does not hold. [Inference]

---

### What End-to-End Type Safety Does Not Cover

tRPC's type safety is a compile-time property. It does not extend to all possible failure modes:

#### Runtime data from external sources

If a procedure fetches data from a database or external API and returns it directly, TypeScript infers the type from the declared or inferred shape — not from what the database actually returns at runtime:

```ts
.query(async ({ input }) => {
  const user = await db.user.findUnique({ where: { id: input.id } });
  return user;
  // If Prisma's generated types are accurate, this is fine.
  // If the database schema diverges from Prisma's types, TypeScript cannot detect it.
})
```

The type system trusts what TypeScript knows. It cannot verify what the database returns at runtime. [Inference: behavior depends on ORM and its type generation accuracy]

#### Network errors and runtime failures

Type safety says nothing about whether the network request succeeds, whether the server is running, or whether a runtime exception occurs inside the procedure. These are handled separately through error handling patterns.

#### `any` and type assertions

If `any` appears anywhere in the inference chain — in the procedure return type, in the input schema, or in consuming code — type safety at that point is silently lost. tRPC cannot compensate for `any` propagation.

---

### Zod's Role in the Inference Chain

Input validation in tRPC is typically done with Zod. Zod participates in type inference in two ways:

**1. Runtime validation** — Zod's `parse` method throws if the input does not match the schema. This catches malformed requests at the boundary.

**2. Compile-time inference** — Zod's schema types are consumed by TypeScript to infer the input type of the procedure:

```ts
const schema = z.object({
  id: z.number(),
  name: z.string().optional(),
});

// Zod infers: { id: number; name?: string | undefined }
// tRPC uses this inference for the procedure's input type
// The client's call site is typed accordingly
```

This means the input type at the client call site is derived from the Zod schema on the server — not from a separately written TypeScript interface. The schema and the type are the same artifact.

---

### A Practical Illustration of the Safety in Action

**Scenario:** A developer renames a field on the server.

**Before:**

```ts
// Server
.query(() => ({ userId: 1, fullName: "Alice" }))

// Client
const user = await trpc.getUser.query({});
console.log(user.fullName); // ✓
```

**After renaming `fullName` to `displayName` on the server:**

```ts
// Server
.query(() => ({ userId: 1, displayName: "Alice" }))

// Client — immediately produces a type error
console.log(user.fullName);
//               ^^^^^^^^^
//               Property 'fullName' does not exist on type '{ userId: number; displayName: string }'
```

No test needs to run. No browser needs to open. The editor reports the error as soon as TypeScript re-checks the client file. This is the practical value of end-to-end type safety — the feedback loop collapses from runtime discovery to edit-time discovery.

> **Disclaimer:** The immediacy of this feedback depends on the editor's TypeScript language server being active and the project being set up so that the client has access to the server's type. In CI without a type check step, this error would only surface if `tsc` is run. Behavior is not guaranteed without correct configuration.

---

### Summary of the Mechanism

| Step | What happens |
|---|---|
| Procedure defined | TypeScript infers output type from return value |
| Router assembled | All procedure types collected into `AppRouter` |
| Type exported | `export type AppRouter = typeof appRouter` — zero runtime cost |
| Client initialized | `createTRPCClient<AppRouter>` — typed proxy constructed |
| Procedure called | Input and output types enforced by TypeScript at call site |
| Field accessed | TypeScript verifies the field exists on the inferred output type |

---

**Conclusion**

End-to-end type safety in tRPC is not a feature that is toggled on — it is a property that emerges from TypeScript's inference flowing uninterrupted from the server procedure to the client call site. The absence of an intermediate artifact is what makes it different from codegen approaches. Its limits are the limits of the type system itself: it cannot verify runtime data from external sources, and it degrades silently wherever `any` enters the chain.

**Next Steps**

The next topic covers setting up a tRPC project from scratch: installing packages, creating the server, and wiring up the client.