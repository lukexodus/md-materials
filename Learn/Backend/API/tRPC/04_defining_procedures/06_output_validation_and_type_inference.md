## Output Validation and Type Inference

### Overview

tRPC's type safety flows in two directions: input types from client to server, and output types from server to client. Output types are inferred automatically from resolver return values by default — no annotation is required. Optionally, `.output()` adds runtime validation of what the resolver returns before it is sent to the client. Understanding how tRPC infers, constrains, and validates output types is essential for building a reliable, type-safe API.

---

### How Output Types Flow

```
Resolver return value
        │
        ▼
TypeScript infers output type
        │
        ├── .output() present → Runtime validation runs
        │                        ├── Pass → Validated (and stripped) value sent to client
        │                        └── Fail → INTERNAL_SERVER_ERROR, client receives error
        │
        └── .output() absent  → No runtime validation
                                 Inferred type sent to client as-is
                                 Client receives fully typed response
```

**Key Points**
- Whether or not `.output()` is present, the client always receives a typed response. The difference is whether the output is validated at runtime.
- Without `.output()`, the type the client sees is exactly what TypeScript infers from the resolver's return statement. If the resolver conditionally returns different shapes, the client type is the union of those shapes.
- With `.output()`, the client type is derived from the output schema, not from TypeScript's inference of the resolver body.

---

### Automatic Type Inference (No `.output()`)

The simplest and most common pattern. TypeScript infers the output type from what the resolver returns.

```ts
getUser: publicProcedure
  .input(z.object({ id: z.string() }))
  .query(({ input }) => {
    return {
      id: input.id,
      name: 'Alice',
      email: 'alice@example.com',
      createdAt: new Date(),
    };
  }),
```

The client receives:

```ts
// Inferred type on client:
{
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}
```

**Key Points**
- tRPC serializes the response over the wire. `Date` objects are serialized as ISO strings by default and deserialized back to `Date` on the client when using `superjson` as the transformer. Without a transformer, `Date` becomes a `string` on the client despite appearing as `Date` in the inferred type — a common source of runtime errors. [Inference] Transformer behavior depends on your configuration.
- The inferred type on the client is a structural type derived from the resolver. Adding or removing fields from the resolver's return value immediately updates the client's type without any additional steps.

---

### Async Resolver Inference

Async resolvers are handled correctly. TypeScript unwraps the `Promise` automatically.

```ts
getUser: publicProcedure
  .input(z.object({ id: z.string() }))
  .query(async ({ input }) => {
    const user = await db.user.findUnique({ where: { id: input.id } });
    return user; // Promise<User | null> → client sees User | null
  }),
```

**Key Points**
- If the resolver can return `null` (as Prisma's `findUnique` can), the client type includes `null`. The client must handle the `null` case — TypeScript will enforce this.
- Returning a Prisma model directly exposes all model fields, including sensitive ones (e.g., `passwordHash`). Explicitly select or omit fields, or use `.output()` to enforce a safe shape.

---

### Explicit Output Validation with `.output()`

`.output()` accepts a Zod schema (or any Standard Schema-compatible validator) and validates the resolver's return value before sending it to the client.

```ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

const UserOutputSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
});

getUser: publicProcedure
  .input(z.object({ id: z.string() }))
  .output(UserOutputSchema)
  .query(async ({ input }) => {
    const user = await db.user.findUnique({ where: { id: input.id } });

    if (!user) {
      throw new TRPCError({ code: 'NOT_FOUND' });
    }

    return user; // validated against UserOutputSchema before sending
  }),
```

**Key Points**
- If the resolver returns a field not declared in `UserOutputSchema` (e.g., `passwordHash`), Zod strips it by default. The client never receives the undeclared field.
- If the resolver returns a value that fails the schema (e.g., a missing required field), tRPC throws an `INTERNAL_SERVER_ERROR` before the response is sent. The client receives an error, not malformed data.
- The client's inferred output type is derived from `UserOutputSchema`, not from the resolver's return type. If the two diverge, TypeScript surfaces a type error at the resolver's return statement.

---

### Field Stripping as a Safety Mechanism

Zod's default behavior strips unknown fields during `.parse()`. This makes `.output()` useful for preventing accidental data leakage.

```ts
const SafeUserSchema = z.object({
  id: z.string(),
  name: z.string(),
  // email, passwordHash, internalNotes — not declared, will be stripped
});

getUser: publicProcedure
  .output(SafeUserSchema)
  .query(async () => {
    // Returns full DB row including sensitive fields
    return await db.user.findFirstOrThrow();
  }),
```

**Output sent to client:**

```json
{
  "id": "user-123",
  "name": "Alice"
}
```

**Key Points**
- Fields not in the output schema are silently removed. No error is thrown for extra fields — only for missing required fields or wrong types.
- This stripping behavior is Zod's default (`z.object()` uses strip mode). Using `z.object().passthrough()` disables stripping. Using `z.object().strict()` throws an error on unknown fields instead. Behavior with `.output()` follows whichever Zod object mode is used.
- [Inference] Field stripping is not a substitute for access control. A determined attacker with control over the server process can bypass it. Use it as a defense-in-depth measure alongside proper authorization.

---

### Inferring Output Types on the Client

#### Using `inferRouterOutputs`

```ts
import type { inferRouterOutputs } from '@trpc/server';
import type { AppRouter } from '../server/router';

type RouterOutputs = inferRouterOutputs<AppRouter>;

type GetUserOutput = RouterOutputs['user']['getUser'];
// { id: string; name: string; email: string; createdAt: Date }
```

**Key Points**
- `inferRouterOutputs` produces a mapped type covering all procedures in the router. Access individual procedure output types via bracket notation.
- This is useful for typing variables, function parameters, and component props that accept tRPC output data without importing the resolver or schema directly.
- Pair it with `inferRouterInputs` for full input/output type access:

```ts
import type { inferRouterInputs, inferRouterOutputs } from '@trpc/server';

type RouterInputs = inferRouterInputs<AppRouter>;
type RouterOutputs = inferRouterOutputs<AppRouter>;

type CreatePostInput = RouterInputs['post']['create'];
type CreatePostOutput = RouterOutputs['post']['create'];
```

---

### Typing Component Props with Inferred Outputs

```tsx
import type { inferRouterOutputs } from '@trpc/server';
import type { AppRouter } from '../../server/router';

type RouterOutputs = inferRouterOutputs<AppRouter>;
type Post = RouterOutputs['post']['getById'];

function PostCard({ post }: { post: Post }) {
  return (
    <article>
      <h2>{post.title}</h2>
      <p>{post.body}</p>
    </article>
  );
}
```

**Key Points**
- Deriving component prop types from `inferRouterOutputs` keeps the component type in sync with the server's output type automatically. When the resolver's return shape changes, the component's prop type updates without any manual intervention.
- This pattern reduces duplication: no separate `Post` interface needs to be maintained alongside the resolver.

---

### Output Schema Placement Conventions

Define output schemas close to where they are used, or in a shared schema file:

```
src/
├── server/
│   └── router/
│       └── user.router.ts        # procedure definitions
├── shared/
│   └── schemas/
│       ├── user.input.schema.ts  # input schemas (shared with client)
│       └── user.output.schema.ts # output schemas (typically server-only)
```

**Key Points**
- Output schemas are usually server-only — they define what the server guarantees it will return. They do not need to be shared with the client unless you are validating response data client-side, which is uncommon.
- Input schemas are frequently shared with the client for form validation. Output schemas typically are not, because the client already has the inferred types via `AppRouter`.
- [Inference] Placing input and output schemas in separate files reduces the risk of accidentally importing server-only output logic into the client bundle.

---

### Combining `.input()` and `.output()`

Both can be present on the same procedure:

```ts
const CreatePostInput = z.object({
  title: z.string().min(1).max(255),
  body: z.string(),
});

const CreatePostOutput = z.object({
  id: z.string(),
  title: z.string(),
  createdAt: z.string().datetime(),
});

create: publicProcedure
  .input(CreatePostInput)
  .output(CreatePostOutput)
  .mutation(async ({ input }) => {
    const post = await db.post.create({ data: input });
    return {
      id: post.id,
      title: post.title,
      createdAt: post.createdAt.toISOString(),
    };
  }),
```

**Key Points**
- The order `.input().output().mutation()` is conventional. tRPC does not enforce ordering of `.input()` and `.output()` relative to each other. [Inference]
- When both are present, TypeScript checks that the resolver's return type satisfies the output schema type. A mismatch is a compile-time error.

---

### Type Narrowing Without `.output()`

When `.output()` is omitted, you can still narrow the output type using TypeScript's type system directly in the resolver:

```ts
type SafeUser = {
  id: string;
  name: string;
};

getUser: publicProcedure
  .input(z.object({ id: z.string() }))
  .query(async ({ input }): Promise<SafeUser> => {
    const user = await db.user.findUniqueOrThrow({ where: { id: input.id } });
    return { id: user.id, name: user.name }; // must satisfy SafeUser
  }),
```

**Key Points**
- Annotating the resolver's return type as `Promise<SafeUser>` constrains what the resolver can return at the TypeScript level. It does not add runtime validation.
- The client's inferred type becomes `SafeUser`, matching the annotation.
- This approach provides compile-time safety but not the runtime stripping or validation that `.output()` provides.

---

### When to Use `.output()`

| Scenario | Use `.output()`? | Reason |
|---|---|---|
| Returning a DB row with sensitive fields | Yes | Strip fields not intended for the client |
| Simple procedure with a small, stable return shape | Optional | Type inference is sufficient |
| Public API with a guaranteed contract | Yes | Runtime enforcement of the contract shape |
| Internal API consumed only by a typed client | Optional | TypeScript inference covers most cases |
| Returning data from an external API | Yes | External data shape may drift from expectations |
| Performance-critical hot paths | Consider omitting | `.output()` adds a parsing step on every response [Inference] |

---

### Serialization and the `superjson` Transformer

tRPC serializes responses as JSON by default. Types that are not JSON-native (`Date`, `Map`, `Set`, `BigInt`, `undefined`) require a transformer to survive the serialization round-trip correctly.

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import superjson from 'superjson';

const t = initTRPC.create({
  transformer: superjson,
});
```

```ts
// client/utils/trpc.ts
import { createTRPCReact } from '@trpc/react-query';
import { httpBatchLink } from '@trpc/client';
import superjson from 'superjson';
import type { AppRouter } from '../../server/router';

export const trpc = createTRPCReact<AppRouter>();

export function createTRPCClient() {
  return trpc.createClient({
    links: [
      httpBatchLink({
        url: '/api/trpc',
        transformer: superjson,
      }),
    ],
  });
}
```

Install superjson:

```bash
npm install superjson
```

**Key Points**
- The transformer must be configured identically on both the server and client. A mismatch causes deserialization errors. [Inference]
- Without `superjson`, a `Date` returned from a resolver is serialized as an ISO string. The client's inferred type says `Date`, but the runtime value is a `string`. This is a common, subtle bug.
- `superjson` preserves `Date`, `Map`, `Set`, `BigInt`, `undefined`, `RegExp`, and other non-JSON types across the wire.
- `.output()` schemas that include `z.date()` work correctly only when the transformer preserves `Date` objects. Without a transformer, the parsed value would be a string, failing `z.date()` validation. [Inference]

---

### Common Output Type Pitfalls

#### Pitfall 1 — `Date` without transformer

```ts
// Resolver returns Date
.query(() => ({ createdAt: new Date() }))

// Client inferred type: { createdAt: Date }
// Client runtime value: { createdAt: "2026-01-01T00:00:00.000Z" } ← string, not Date
```

**Resolution:** Configure `superjson` as the transformer on both client and server.

---

#### Pitfall 2 — Exposing sensitive fields without `.output()`

```ts
// Resolver returns entire Prisma user row
.query(async ({ input }) => db.user.findUniqueOrThrow({ where: { id: input.id } }))
// passwordHash, twoFactorSecret, etc. are sent to the client
```

**Resolution:** Explicitly select fields or use `.output()` with a schema that omits sensitive fields.

---

#### Pitfall 3 — Output type mismatch with `.output()`

```ts
.output(z.object({ id: z.string(), name: z.string() }))
.query(() => ({ id: 123, name: 'Alice' }))
// id is number, schema expects string → INTERNAL_SERVER_ERROR at runtime
// TypeScript also surfaces this as a compile-time error
```

**Resolution:** Align the resolver's return value with the output schema.

---

#### Pitfall 4 — Union return types widening the client type

```ts
.query(({ input }) => {
  if (input.detailed) {
    return { id: '1', name: 'Alice', bio: 'Developer' };
  }
  return { id: '1', name: 'Alice' };
})
// Client type: { id: string; name: string; bio: string } | { id: string; name: string }
// Client must narrow before accessing bio
```

**Resolution:** Use `.output()` with a stable schema, or restructure the resolver to always return the same shape with optional fields.