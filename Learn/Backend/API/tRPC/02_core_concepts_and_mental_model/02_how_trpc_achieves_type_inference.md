## How tRPC Achieves Type Inference

### What This Section Covers

The previous section established *what* end-to-end type safety means in tRPC. This section goes one level deeper: *how* TypeScript's type system makes it possible. No tRPC-specific magic is required — the mechanism is built entirely from standard TypeScript features. Understanding these features demystifies tRPC's internals and makes debugging type errors significantly easier.

---

### The Four TypeScript Features tRPC Depends On

tRPC's inference model is built on four TypeScript capabilities used in combination:

1. **`typeof` on values** — extracting a type from a runtime value
2. **Generic type parameters** — passing types through function boundaries
3. **Conditional and mapped types** — transforming type shapes
4. **Type-only imports** — sharing types across module boundaries at zero runtime cost

Each is covered below before showing how they combine inside tRPC.

---

### Feature 1 — `typeof` on Values

TypeScript can extract the type of any value using the `typeof` operator in a type position:

```ts
const user = { id: 1, name: "Alice" };
type User = typeof user;
// Equivalent to: type User = { id: number; name: string }
```

This works on functions too:

```ts
function getUser() {
  return { id: 1, name: "Alice" };
}

type GetUserReturn = ReturnType<typeof getUser>;
// { id: number; name: string }
```

tRPC uses exactly this mechanism on the router object. When you write:

```ts
export type AppRouter = typeof appRouter;
```

TypeScript extracts the complete type structure of the router — including every procedure name, its input type, and its output type — directly from the runtime value. Nothing is declared manually.

---

### Feature 2 — Generic Type Parameters

Generics allow a type to be parameterized, so that a function or object can carry type information through to its consumers:

```ts
function identity<T>(value: T): T {
  return value;
}

const result = identity("hello");
// result is typed as string, not as the wider type `unknown`
```

tRPC's client factory uses generics to accept the router type and thread it through to the proxy object it returns:

```ts
// Simplified conceptual signature
function createTRPCClient<TRouter extends AnyRouter>(
  opts: ClientConfig
): TRPCClient<TRouter> { ... }
```

When called as `createTRPCClient<AppRouter>(...)`, TypeScript binds `TRouter` to `AppRouter` and propagates it into the return type `TRPCClient<AppRouter>`. From that point, every property access on the client is typed against the procedures defined in `AppRouter`.

---

### Feature 3 — Conditional and Mapped Types

tRPC's typed client proxy is not hand-written for each router shape. It is constructed using mapped types — types that transform another type's structure programmatically.

**Mapped type example:**

```ts
type Readonly<T> = {
  readonly [K in keyof T]: T[K];
};
```

tRPC uses a similar pattern to transform `AppRouter`'s procedure map into a client proxy shape. For each key in the router, it generates a corresponding client method with the correct input and output types.

**Simplified conceptual illustration** — not actual tRPC source:

```ts
type ClientProxy<TRouter> = {
  [K in keyof TRouter]: TRouter[K] extends QueryProcedure<infer TInput, infer TOutput>
    ? { query: (input: TInput) => Promise<TOutput> }
    : TRouter[K] extends MutationProcedure<infer TInput, infer TOutput>
    ? { mutate: (input: TInput) => Promise<TOutput> }
    : never;
};
```

This pattern says: for each key in the router, look at what kind of procedure it is, extract its input and output types using `infer`, and produce the corresponding client method type.

> **Disclaimer:** The above is a simplified illustration of the concept. Actual tRPC internals are more complex and have changed across versions. Do not use this as a reference for tRPC's implementation details.

---

### Feature 4 — Type-Only Imports

TypeScript supports importing only the type of a module export, with no runtime dependency:

```ts
import type { AppRouter } from "../server/router";
```

The `import type` syntax is completely erased during compilation. The JavaScript output contains no reference to the server module. This is what makes it safe to import server types into client code — the server's runtime code never enters the client bundle.

Without `import type`, a regular import would pull in the server module's runtime code, including any Node.js-specific dependencies, which would break in a browser environment.

---

### How These Features Combine in tRPC

The full inference chain can now be traced step by step using only these four features:

#### Step 1 — Procedure output type is inferred from return value

```ts
const appRouter = t.router({
  getUser: t.procedure
    .input(z.object({ id: z.number() }))
    .query(({ input }) => {
      return { id: input.id, name: "Alice" };
    }),
});
```

TypeScript infers the return type of the `.query()` callback as `{ id: number; name: string }`. This inference is stored inside the router object's type.

#### Step 2 — `typeof appRouter` captures the complete procedure map

```ts
export type AppRouter = typeof appRouter;
```

`AppRouter` now contains a type-level description of every procedure:

```ts
// What AppRouter looks like at the type level (simplified)
type AppRouter = {
  getUser: {
    _def: {
      _input_in: { id: number };
      _output_out: { id: number; name: string };
      type: "query";
    };
  };
};
```

The `_def` structure is tRPC's internal representation of a procedure's type contract. It is not part of the public API and should not be accessed directly. [Inference: internal structure varies across tRPC versions]

#### Step 3 — The client factory accepts `AppRouter` as a generic parameter

```ts
import type { AppRouter } from "../server/router";

const trpc = createTRPCClient<AppRouter>({
  links: [httpBatchLink({ url: "/api/trpc" })],
});
```

`createTRPCClient<AppRouter>` binds `AppRouter` to the factory's generic parameter. The factory returns a proxy typed as `TRPCClient<AppRouter>`.

#### Step 4 — Mapped types construct the client proxy shape

Internally, tRPC maps over `AppRouter`'s keys and constructs typed methods for each procedure. The result is that `trpc` has the following effective type:

```ts
// Effective type of `trpc` after inference
{
  getUser: {
    query: (input: { id: number }) => Promise<{ id: number; name: string }>;
  };
}
```

This type was never written by the developer. It was derived entirely from the server's procedure definition.

#### Step 5 — TypeScript enforces the derived types at the call site

```ts
const user = await trpc.getUser.query({ id: 1 });
//    ^^^^
//    Typed as: { id: number; name: string }
//    Enforced by TypeScript — no cast, no assertion
```

---

### Inference With Zod — Input Types

Zod schemas contribute to the inference chain on the input side. Zod uses its own generic type system to expose the TypeScript type that a schema validates:

```ts
const schema = z.object({ id: z.number() });
type Input = z.infer<typeof schema>;
// { id: number }
```

When passed to `.input()`, tRPC extracts this type and uses it as the procedure's input type. The client call site's argument type comes from the Zod schema — not from a separately declared TypeScript interface.

This means input types and runtime validation share a single source of truth:

```
z.object({ id: z.number() })
        │
        ├── Runtime: validates that the input has id as a number
        └── Compile-time: TypeScript infers { id: number }
```

If the Zod schema changes, both the runtime validation and the TypeScript type update simultaneously.

---

### Inference With Explicit Return Types

By default, tRPC infers the output type from the procedure's return value. You can also declare an explicit output schema using `.output()`:

```ts
t.procedure
  .input(z.object({ id: z.number() }))
  .output(z.object({ id: z.number(), name: z.string() }))
  .query(({ input }) => {
    return { id: input.id, name: "Alice" };
  });
```

When `.output()` is used:
- The return value is validated at runtime against the output schema
- The client's inferred type comes from the output schema rather than the return value's inferred type

This is useful when the return value's inferred type is wider than intended, or when runtime output validation is required.

> **Disclaimer:** Whether `.output()` adds meaningful safety over inferred return types depends on the specific use case. It does not prevent all runtime mismatches — for example, if an external data source returns unexpected data, that mismatch occurs before the output schema validates it. Behavior depends on implementation.

---

### Router Composition and Nested Inference

tRPC routers can be composed — a router can contain sub-routers. Type inference propagates through this nesting:

```ts
const userRouter = t.router({
  get: t.procedure.input(z.object({ id: z.number() })).query(({ input }) => ({
    id: input.id,
    name: "Alice",
  })),
});

const postRouter = t.router({
  list: t.procedure.query(() => [{ id: 1, title: "Hello" }]),
});

const appRouter = t.router({
  user: userRouter,
  post: postRouter,
});

export type AppRouter = typeof appRouter;
```

The client proxy mirrors this nesting:

```ts
const user = await trpc.user.get.query({ id: 1 });
//    ^^^^  typed as { id: number; name: string }

const posts = await trpc.post.list.query();
//    ^^^^^  typed as { id: number; title: string }[]
```

The mapped type construction in tRPC handles arbitrarily nested routers recursively. [Inference: depth limits, if any, depend on TypeScript's recursive type evaluation limits, which vary by TypeScript version and project complexity]

---

### Why Inference Can Break

Understanding the mechanism reveals why inference sometimes fails or degrades:

#### Circular return types

If a procedure's return type references itself or creates a type cycle, TypeScript may widen the type to `any` or produce an error. This is a TypeScript limitation, not specific to tRPC.

#### Excessive type complexity

Very large routers with many procedures and deeply nested structures can approach TypeScript's recursive type instantiation limits. Symptoms include slow editor response and type errors that reference instantiation depth. [Inference: threshold depends on TypeScript version and machine resources]

#### `any` in the return value

If any part of the return value is typed as `any` — for example, the result of an untyped database call — the inferred output type becomes `any`. The client then loses type information for that procedure.

```ts
.query(async () => {
  const result = await someUntypedFunction(); // returns `any`
  return result; // output type is `any` — inference collapses
})
```

#### Missing `export type`

If `AppRouter` is exported without the `type` keyword in certain configurations, or if the import on the client side is a value import rather than a type import, bundlers may attempt to include server code in the client bundle, causing build failures.

```ts
// Correct
export type AppRouter = typeof appRouter;
import type { AppRouter } from "../server/router";

// Potentially problematic depending on bundler configuration
export { AppRouter }; // not a type export
import { AppRouter } from "../server/router"; // not a type import
```

---

### Visualizing the Full Type Flow

```
z.object({ id: z.number() })         ← Zod schema
          │
          │  z.infer<typeof schema> → { id: number }
          ▼
t.procedure.input(schema).query(fn)  ← Procedure definition
          │
          │  fn return type inferred → { id: number; name: string }
          ▼
t.router({ getUser: procedure })     ← Router assembly
          │
          │  typeof appRouter
          ▼
AppRouter (pure TypeScript type)     ← Type export
          │
          │  import type { AppRouter }
          ▼
createTRPCClient<AppRouter>          ← Generic binding
          │
          │  Mapped types construct proxy
          ▼
trpc.getUser.query({ id: number })   ← Typed call site
          │
          │  Return typed as { id: number; name: string }
          ▼
Consuming code                       ← TypeScript enforces shape
```

---

### What tRPC Does Not Invent

It is worth being explicit: tRPC does not implement a novel type system. Every mechanism described in this section — `typeof`, generics, mapped types, conditional types, `infer`, type-only imports — is standard TypeScript. tRPC's contribution is in assembling these features into a coherent pattern that makes the inference chain automatic for the developer.

This also means that when something goes wrong with tRPC's types, the tools for diagnosing it are standard TypeScript tools: hovering types in an editor, using `tsc --noEmit`, and reading TypeScript error messages carefully.

---

**Conclusion**

tRPC's type inference is the result of four TypeScript features working together: `typeof` extracts the router's type, generics thread it into the client factory, mapped types transform it into a typed proxy, and type-only imports carry it across the module boundary at zero runtime cost. Zod participates by making input schemas and TypeScript types the same artifact. The entire system degrades predictably when `any` enters the chain or when TypeScript's complexity limits are approached — understanding the mechanism makes those failure modes diagnosable.

**Next Steps**

The next topic covers setting up a tRPC project from scratch: installing packages, initializing the server, and connecting the client for the first time.