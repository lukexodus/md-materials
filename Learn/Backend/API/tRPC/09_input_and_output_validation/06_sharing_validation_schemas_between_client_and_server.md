## Sharing Validation Schemas Between Client and Server

One of tRPC's core architectural advantages is that it operates within a single TypeScript monorepo or shared module boundary, making schema sharing between client and server a natural and low-friction pattern. Shared schemas eliminate duplication, enforce consistency, and serve as the single source of truth for data contracts across the stack.

---

### Why Schema Sharing Matters

Without a shared schema strategy, validation logic tends to drift: the server validates one shape, the client independently re-implements a similar but subtly different check, and the two fall out of sync as the codebase evolves.

**Key Points**

- Duplicated schemas create maintenance burden and silent divergence risk
- A shared schema means any change propagates to both client and server automatically
- In tRPC's full-stack TypeScript model, the tooling already encourages colocation of types and logic

---

### The Monorepo Model

The most common pattern for schema sharing in tRPC projects is a shared package inside a monorepo. Both the client application and the tRPC server import from this package directly.

```
apps/
  web/          ← Next.js or React client
  server/       ← tRPC API server
packages/
  schemas/      ← shared Zod schemas, types, constants
    src/
      user.ts
      post.ts
      index.ts
```

The `packages/schemas` package is a plain TypeScript module with no runtime dependencies beyond your validator library (e.g., Zod). Both `apps/web` and `apps/server` declare it as a dependency.

**Example** — `packages/schemas/src/user.ts`:

```ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  username: z.string().min(3).max(32),
  email: z.string().email(),
  password: z.string().min(8),
});

export type CreateUserInput = z.infer<typeof CreateUserSchema>;
```

**Server** — `apps/server/routers/user.ts`:

```ts
import { CreateUserSchema } from '@myapp/schemas';
import { publicProcedure } from '../trpc';

export const createUser = publicProcedure
  .input(CreateUserSchema)
  .mutation(async ({ input }) => {
    // input is fully typed as CreateUserInput
    return createUserInDb(input);
  });
```

**Client** — `apps/web/components/RegisterForm.tsx`:

```ts
import { CreateUserSchema, CreateUserInput } from '@myapp/schemas';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

const form = useForm<CreateUserInput>({
  resolver: zodResolver(CreateUserSchema),
});
```

The same schema validates on form submission client-side and again on the server — with no duplication.

---

### Colocation Inside the tRPC Router (Simpler Projects)

For projects that are not monorepos — such as a Next.js app with both frontend and API routes in the same codebase — schemas can be colocated in a shared directory within the single project.

```
src/
  schemas/
    user.ts
    post.ts
  server/
    routers/
      user.ts
  components/
    RegisterForm.tsx
```

Both the router and the component import from `src/schemas/user.ts`. This achieves the same sharing goal without the overhead of a monorepo package structure.

[Inference] This colocation pattern is common in Next.js App Router projects using tRPC, where the API and frontend live in the same repository and often the same build.

---

### What to Put in a Shared Schema

Not everything belongs in a shared schema package. A useful mental model is to ask whether the schema describes a *data contract* that both sides need to agree on.

| Belongs in Shared Schema | Belongs Server-Side Only |
|---|---|
| Input shapes for mutations and queries | Database query construction logic |
| Enum values used in forms and API alike | Internal server validation (e.g., rate limit checks) |
| Output shapes exposed to clients | Sensitive field definitions not exposed to clients |
| Reusable field validators (email, slug, etc.) | Auth token validation logic |
| Pagination parameter schemas | Business rule validators tied to DB state |

**Key Points**

- Shared schemas should be pure — no server-only imports, no database clients, no environment variable access
- If a schema imports from a server-only module, it will break or leak context when imported on the client
- Keep shared schemas as thin, self-contained validation definitions

---

### Avoiding Client Bundle Pollution

A shared schema package must not transitively import server-only code. This is especially important in frameworks like Next.js where server and client code share the same build pipeline.

Common pitfalls:

```ts
// ❌ Bad — shared schema imports a server-only module
import { db } from '../server/db'; // pulls database client into client bundle
import { env } from '../env.server'; // exposes server environment variables

export const UserSchema = z.object({ ... });
```

```ts
// ✅ Good — shared schema has no runtime dependencies beyond the validator
import { z } from 'zod';

export const UserSchema = z.object({ ... });
```

[Inference] In Next.js specifically, using the `server-only` package in server modules and keeping shared schemas free of those imports is the standard mitigation pattern. Behavior may vary across bundlers and framework versions.

---

### Schema Composition Across Shared and Server Layers

A practical pattern is to define a base schema in the shared package and extend it server-side with additional fields or refinements that clients should not see or send.

```ts
// packages/schemas/src/user.ts — shared
export const CreateUserInputSchema = z.object({
  username: z.string().min(3),
  email: z.string().email(),
  password: z.string().min(8),
});
```

```ts
// apps/server/routers/user.ts — server-only extension
import { CreateUserInputSchema } from '@myapp/schemas';

const ServerCreateUserSchema = CreateUserInputSchema.extend({
  createdByAdminId: z.string().optional(), // added server-side after auth check
  ipAddress: z.string(),                   // injected from request context
});
```

This pattern keeps the client-facing contract clean while allowing the server to work with a richer internal shape.

---

### Reusable Field Validators

Shared schemas benefit from defining atomic field validators that are composed into larger schemas. This prevents subtle inconsistencies where the same field (e.g., `username`) is validated differently in two places.

```ts
// packages/schemas/src/fields.ts
import { z } from 'zod';

export const UsernameField = z.string().min(3).max(32).regex(/^[a-zA-Z0-9_]+$/);
export const EmailField = z.string().email().toLowerCase();
export const SlugField = z.string().regex(/^[a-z0-9-]+$/);
export const CursorField = z.string().uuid();
export const PaginationSchema = z.object({
  cursor: CursorField.optional(),
  limit: z.number().int().min(1).max(100).default(20),
});
```

These primitives are then composed into feature schemas:

```ts
import { UsernameField, EmailField } from './fields';

export const CreateUserSchema = z.object({
  username: UsernameField,
  email: EmailField,
});

export const UpdateProfileSchema = z.object({
  username: UsernameField.optional(),
  email: EmailField.optional(),
});
```

**Key Points**

- Field-level validators are the smallest unit of reuse
- Changing a field's rules in one place propagates to all schemas that use it
- This pattern is especially valuable for fields that appear across many procedures (e.g., pagination, IDs, slugs)

---

### TypeScript Type Inference From Shared Schemas

Shared schemas double as the source of inferred TypeScript types for both sides of the stack. Using `z.infer` at the schema definition site means the type travels with the schema automatically.

```ts
// packages/schemas/src/user.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  username: z.string(),
  email: z.string().email(),
});

export type CreateUserInput = z.infer<typeof CreateUserSchema>;
// exported and usable in both client components and server handlers
```

This eliminates the need to maintain separate type files alongside schema files — the schema *is* the type definition.

---

### Versioning and Schema Evolution

When shared schemas are consumed by multiple packages, changes carry cross-cutting impact. A breaking schema change (removing a required field, narrowing a type) will surface as TypeScript errors across all consumers immediately — which is the desired behavior.

**Key Points**

- Additive changes (adding optional fields) are generally safe and non-breaking
- Removing or narrowing fields is a breaking change that affects all consumers
- In monorepo setups, TypeScript's project references or the build tool's dependency graph surfaces these errors at build time before deployment
- [Inference] For long-lived APIs with external consumers, schema versioning strategies (separate schema files per version, or versioned routers) may be warranted, though this is uncommon in internal full-stack tRPC usage

---

### Testing Shared Schemas

Shared schemas benefit from their own test suite, independent of the procedures that use them.

```ts
// packages/schemas/src/__tests__/user.test.ts
import { CreateUserSchema } from '../user';

describe('CreateUserSchema', () => {
  it('accepts valid input', () => {
    expect(() =>
      CreateUserSchema.parse({ username: 'alice', email: 'alice@example.com', password: 'hunter2!' })
    ).not.toThrow();
  });

  it('rejects short username', () => {
    const result = CreateUserSchema.safeParse({ username: 'al', email: 'alice@example.com', password: 'hunter2!' });
    expect(result.success).toBe(false);
  });

  it('rejects malformed email', () => {
    const result = CreateUserSchema.safeParse({ username: 'alice', email: 'not-an-email', password: 'hunter2!' });
    expect(result.success).toBe(false);
  });
});
```

Testing schemas in isolation confirms the validation logic is correct before it is relied upon in procedures or form resolvers.

---

### Diagram: Schema Sharing Flow

<svg viewBox="0 0 680 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Shared Schema Package -->
  <rect x="230" y="20" width="220" height="70" rx="8" fill="#1e293b" stroke="#6366f1" stroke-width="2"/>
  <text x="340" y="48" text-anchor="middle" fill="#a5b4fc" font-size="13" font-weight="bold">packages/schemas</text>
  <text x="340" y="68" text-anchor="middle" fill="#94a3b8" font-size="11">CreateUserSchema</text>
  <text x="340" y="84" text-anchor="middle" fill="#94a3b8" font-size="11">type CreateUserInput</text>

  <!-- Arrow down-left to Client -->
  <line x1="280" y1="90" x2="140" y2="170" stroke="#6366f1" stroke-width="1.5" stroke-dasharray="5,3"/>
  <polygon points="140,170 148,158 152,168" fill="#6366f1"/>

  <!-- Arrow down-right to Server -->
  <line x1="400" y1="90" x2="540" y2="170" stroke="#6366f1" stroke-width="1.5" stroke-dasharray="5,3"/>
  <polygon points="540,170 532,158 542,162" fill="#6366f1"/>

  <!-- Client Box -->
  <rect x="30" y="175" width="220" height="80" rx="8" fill="#0f172a" stroke="#22d3ee" stroke-width="2"/>
  <text x="140" y="200" text-anchor="middle" fill="#67e8f9" font-size="13" font-weight="bold">Client (React)</text>
  <text x="140" y="220" text-anchor="middle" fill="#94a3b8" font-size="11">zodResolver(CreateUserSchema)</text>
  <text x="140" y="238" text-anchor="middle" fill="#94a3b8" font-size="11">useForm&lt;CreateUserInput&gt;</text>

  <!-- Server Box -->
  <rect x="430" y="175" width="220" height="80" rx="8" fill="#0f172a" stroke="#34d399" stroke-width="2"/>
  <text x="540" y="200" text-anchor="middle" fill="#6ee7b7" font-size="13" font-weight="bold">Server (tRPC)</text>
  <text x="540" y="220" text-anchor="middle" fill="#94a3b8" font-size="11">.input(CreateUserSchema)</text>
  <text x="540" y="238" text-anchor="middle" fill="#94a3b8" font-size="11">input: CreateUserInput</text>

  <!-- Labels -->
  <text x="175" y="148" text-anchor="middle" fill="#818cf8" font-size="11">import</text>
  <text x="495" y="148" text-anchor="middle" fill="#818cf8" font-size="11">import</text>

  <!-- Bottom note -->
  <rect x="160" y="295" width="360" height="32" rx="6" fill="#1e293b" stroke="#475569" stroke-width="1"/>
  <text x="340" y="315" text-anchor="middle" fill="#94a3b8" font-size="11">Single schema — validated client-side and server-side</text>
</svg>

---

**Conclusion**

Sharing validation schemas between client and server is one of the highest-leverage patterns available in a tRPC stack. It eliminates schema drift, reduces duplicated validation logic, and makes the shared Zod schema the authoritative source for both runtime behavior and TypeScript types. The primary implementation choices — monorepo shared package vs. single-project colocation — are largely determined by project structure rather than technical constraints. In either case, keeping shared schemas pure, dependency-free, and composed from reusable field primitives maximizes their long-term maintainability.