## Default Input and Output Types in tRPC Procedures

When a tRPC procedure is defined without explicitly attaching an `.input()` or `.output()` validator, tRPC assigns default types to those positions. Understanding what those defaults are — and what they imply — is essential for writing predictable, type-safe procedures.

---

### What Happens Without `.input()`

If you define a procedure without calling `.input()`, tRPC treats the input as `undefined` by default. This means the procedure does not expect any argument from the caller.

**Example**

```ts
const appRouter = router({
  ping: publicProcedure.query(() => {
    return 'pong';
  }),
});
```

On the client side, calling `ping` without arguments is valid and type-checked accordingly:

```ts
const result = await trpc.ping.query(); // no argument required or accepted
```

Attempting to pass an argument here will produce a TypeScript error because the inferred input type is `void` / `undefined`.

---

### What Happens Without `.output()`

If `.output()` is not specified, tRPC infers the return type directly from whatever the resolver function returns. There is no runtime validation applied to the output.

**Example**

```ts
const appRouter = router({
  getUser: publicProcedure.query(() => {
    return { id: 1, name: 'Alice' };
  }),
});
```

The return type `{ id: number; name: string }` is inferred statically by TypeScript. The client receives full type inference for this shape.

**Key Points**

- No schema validator runs on the output at runtime.
- The type exists only at the TypeScript level — it is a compile-time guarantee, not a runtime one.
- If the resolver returns a shape inconsistent with what TypeScript infers (e.g., due to a type assertion or an external data source), the discrepancy will not be caught at runtime unless `.output()` is explicitly added.

---

### The `void` Input Type

When no `.input()` is provided, the TypeScript type for the input parameter in the resolver is `void`. This is distinct from `unknown` or `any`.

```ts
publicProcedure.query(({ input }) => {
  // input is typed as void here
  console.log(input); // undefined at runtime
});
```

**Key Points**

- `void` input means the procedure explicitly signals it takes no input.
- Callers cannot pass arbitrary data without TypeScript complaining.
- At runtime, the input value will be `undefined`.

---

### Behavior with `unknown` vs. Inferred Output

| Scenario | Input Type | Output Type | Runtime Validation |
|---|---|---|---|
| No `.input()`, no `.output()` | `void` | Inferred from resolver | None |
| `.input(schema)`, no `.output()` | Schema-defined | Inferred from resolver | Input only |
| No `.input()`, `.output(schema)` | `void` | Schema-defined | Output only |
| `.input(schema)`, `.output(schema)` | Schema-defined | Schema-defined | Both |

---

### Why This Matters

**[Inference]** Because output types are only inferred — not validated at runtime by default — a procedure returning data from an external source (a database, a third-party API) could return a shape that differs from what TypeScript expects. TypeScript would not flag this during compilation if the type assertion is incorrect. *Behavior may vary depending on how strict your type declarations are.*

**Key Points**

- Relying solely on inferred output types is sufficient for many internal use cases where the resolver is self-contained.
- For data crossing a trust boundary (e.g., raw database rows, external APIs), adding an explicit `.output()` validator provides an additional layer of runtime assurance.
- Omitting `.input()` is a deliberate signal — it communicates that the procedure is not parameterized.

---

### Practical Implications for Callers

On the tRPC client, the absence of `.input()` directly shapes the call signature:

```ts
// Valid — no argument
await trpc.ping.query();

// TypeScript error — argument not expected
await trpc.ping.query({ id: 1 });
```

This strict call-site enforcement is a direct consequence of the `void` default input type, and it works without any additional configuration.

---

**Conclusion**

Default input and output types in tRPC are not permissive fallbacks — they are deliberate, typed defaults. A missing `.input()` produces a `void`-typed, non-parameterized procedure. A missing `.output()` produces an inferred, TypeScript-only type with no runtime validation. Knowing the distinction between compile-time inference and runtime validation helps you make an informed decision about when explicit validators are worth adding.