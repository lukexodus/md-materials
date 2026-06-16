## Runtime Output Validation Trade-offs

Runtime output validation in tRPC refers to the optional practice of validating procedure return values against a defined schema before sending them to the client. Unlike input validation — which is always enforced — output validation is opt-in and carries meaningful performance, safety, and architectural implications.

---

### What Output Validation Does

By default, tRPC trusts that your resolver returns data conforming to the TypeScript type inferred from your procedure definition. Output validation adds a runtime schema check on the return value before it is serialized and sent.

```ts
import { z } from 'zod';
import { publicProcedure } from './trpc';

export const getUser = publicProcedure
  .output(
    z.object({
      id: z.string(),
      email: z.string().email(),
      role: z.enum(['admin', 'user']),
    })
  )
  .query(async ({ ctx }) => {
    return ctx.db.user.findFirst(); // validated at runtime before response
  });
```

If the resolver returns a value that fails the output schema (e.g., `role` is `null`), tRPC throws an `INTERNAL_SERVER_ERROR` before the client receives anything.

---

### Why Output Validation Is Opt-in

tRPC's design philosophy separates concerns: input validation protects the server, output validation protects the client. The asymmetry is intentional.

**Key Points**

- Input always arrives from untrusted external sources — validation is non-negotiable
- Output originates from your own code and database — trust is higher by default
- TypeScript's type system already catches many output shape mismatches at compile time
- Output validation adds CPU cost on every procedure call for data that is often already typed

[Inference] The decision to make output validation opt-in reflects a deliberate trade-off toward performance and developer velocity for internal-trust data paths.

---

### The Case For Output Validation

#### Catching Database Drift

Your database schema can diverge from your TypeScript types silently. A column added, renamed, or changed in a migration may not be reflected in your ORM model immediately — or ever, if types are manually maintained.

```ts
// TypeScript says this returns { id: string; name: string }
// but your DB added a nullable `deletedAt` column you forgot to model
const user = await ctx.db.user.findFirst({ where: { id: input.id } });
// Without output validation, `deletedAt` leaks to the client silently
```

Output validation strips or rejects fields not present in the schema, depending on your validator's configuration (e.g., Zod's `.strip()` vs `.strict()`).

#### Preventing Sensitive Data Leaks

Even when types are correct, resolvers can inadvertently include sensitive fields:

```ts
// resolver accidentally returns the full DB row
return ctx.db.user.findFirst(); 
// includes passwordHash, internalFlags, auditLog, etc.
```

An output schema acts as an explicit allowlist. Only fields declared in the schema are forwarded.

#### Enforcing Contract Stability

In systems where multiple consumers depend on a tRPC procedure, an output schema documents and enforces the contract. If a future resolver change breaks the shape, the error surfaces server-side immediately rather than propagating silently to all clients.

#### Validating External Data

When your resolver fetches from a third-party API or an untyped data source, output validation becomes essential:

```ts
const result = await fetch('https://api.external.com/data').then(r => r.json());
// `result` is `any` — output schema validates before forwarding
return result;
```

---

### The Case Against Output Validation

#### Performance Cost

Every validated response pays a schema traversal cost proportional to the complexity and size of the output object. For high-throughput procedures returning large payloads, this overhead can be meaningful.

[Inference] For most CRUD-style endpoints returning small objects, the cost is likely negligible. For endpoints returning arrays of hundreds of objects with nested structures, profiling is advisable before enabling output validation in production.

#### Redundancy With Strong Typing

If your ORM generates types directly from your schema (e.g., Prisma's generated types, Drizzle's inferred types), the TypeScript compiler already enforces output shape at build time. Runtime validation may duplicate work the type system already does.

```ts
// Prisma-generated type is authoritative and matches DB schema
const user: User = await ctx.db.user.findUniqueOrThrow({ where: { id } });
// Output schema here is largely redundant
```

#### False Security in Complex Scenarios

Output validation catches shape mismatches but does not validate business logic correctness, data integrity beyond the schema, or referential consistency. It is not a substitute for integration tests or database constraints.

#### Maintenance Overhead

Every schema change requires updating both the internal types and the output schema. In fast-moving codebases, this can become a source of friction and drift if not managed carefully.

---

### Zod Behavior: Strip vs Strict

The behavior of output validation depends heavily on how the schema is configured.

| Mode | Behavior | Use Case |
|---|---|---|
| `.strip()` (default) | Extra fields are silently removed | Safe allowlisting of response fields |
| `.strict()` | Extra fields throw a validation error | Strict contract enforcement |
| `.passthrough()` | Extra fields are forwarded as-is | Debugging or loose contracts |

```ts
// Strip mode — default Zod behavior
z.object({ id: z.string() }) // extra fields removed silently

// Strict mode — extra fields throw
z.object({ id: z.string() }).strict()

// Passthrough — extra fields forwarded
z.object({ id: z.string() }).passthrough()
```

[Inference] For security-sensitive procedures, `.strip()` or `.strict()` is preferable. `.passthrough()` effectively disables the allowlisting benefit.

---

### Interaction With TypeScript Inference

When `.output()` is defined, tRPC uses the schema's inferred type as the procedure's return type on both the server and client side. This means:

- The resolver's return type is narrowed to the output schema's type
- The client receives the schema-inferred type, not the resolver's raw return type
- TypeScript will error if the resolver returns a shape incompatible with the output schema

```ts
.output(z.object({ id: z.string() }))
.query(() => {
  return { id: '123', secret: 'hidden' };
  // TypeScript: OK (extra fields allowed by TS structural typing)
  // Runtime: 'secret' stripped by Zod's default .strip()
});
```

**Key Points**

- TypeScript structural typing allows extra properties — Zod `.strip()` removes them at runtime
- This means TypeScript alone does not guarantee the same behavior as runtime validation in all cases
- The two layers are complementary, not redundant, for security-critical paths

---

### When to Use Output Validation

| Scenario | Recommendation |
|---|---|
| Procedure returns data from a third-party or untyped source | Use output validation |
| Sensitive fields exist on the DB row that must not leak | Use output validation with `.strip()` |
| High-throughput endpoint with large array payloads | Profile before enabling; consider selective use |
| Fully typed ORM with tight schema control, no sensitive fields | Optional; TypeScript coverage may be sufficient |
| Public API surface with stable contracts | Use output validation to enforce and document the contract |
| Internal server-to-server calls with full type control | Optional; evaluate performance vs. safety trade-off |

---

### Output Validation and Error Behavior

When output validation fails, tRPC returns an `INTERNAL_SERVER_ERROR` to the client. This is intentional — a validation failure on output indicates a server-side bug, not a client mistake.

```ts
// Client receives:
{
  error: {
    code: 'INTERNAL_SERVER_ERROR',
    message: 'Output validation failed'
  }
}
```

**Key Points**

- The original validation error details are not forwarded to the client by default
- Server logs will contain the full Zod error for debugging
- This behavior may vary depending on your error formatter configuration

---

### Architecture Pattern: Selective Output Validation

Rather than applying output validation globally or never, a practical approach is to apply it selectively based on risk:

```ts
// High-risk: external data source, sensitive context
export const getPaymentDetails = privateProcedure
  .output(PaymentDetailsSchema)
  .query(async ({ ctx }) => fetchFromPaymentGateway(ctx.userId));

// Low-risk: fully typed internal query, no sensitive fields
export const getConfig = publicProcedure
  .query(async () => getAppConfig()); // no .output() — trust TypeScript
```

[Inference] This selective approach balances performance, safety, and maintainability more effectively than a blanket policy in either direction.

---

**Conclusion**

Runtime output validation in tRPC is a deliberate opt-in mechanism that trades some performance overhead for meaningful safety guarantees — preventing sensitive field leakage, catching database drift, and enforcing client-facing contracts. It is most valuable when data originates from untrusted or loosely typed sources, or when security requirements demand an explicit response allowlist. For fully typed internal data paths with no sensitive exposure risk, TypeScript's compile-time guarantees may be sufficient. The right policy is almost always context-dependent rather than universal.