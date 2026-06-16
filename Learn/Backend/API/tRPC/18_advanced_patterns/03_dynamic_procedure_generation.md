## Dynamic Procedure Generation

---

### Overview

Dynamic procedure generation refers to programmatically constructing tRPC procedures and routers at runtime or module initialization time, rather than defining each procedure explicitly by hand. Instead of writing out every procedure individually, you derive them from data structures, schemas, configuration objects, or external sources.

This is a natural extension of the higher-order router pattern — where higher-order routers compose known procedures, dynamic generation produces the procedures themselves from a description.

---

### When It Is Appropriate

Dynamic generation introduces indirection that can reduce readability. It is appropriate when:

- A set of procedures shares a uniform structure and only differs in configuration (e.g., a procedure per database entity)
- Procedures are derived from an external schema or configuration file
- A plugin or library needs to expose procedures without knowing the consuming application's shape in advance
- Boilerplate reduction across many similar routes is a meaningful maintenance concern

It is generally not appropriate when procedures differ significantly in logic, input shape, or authorization — in those cases, explicit definitions remain clearer.

---

### Pattern: Generating Procedures from an Entity Map

The most common dynamic generation pattern iterates over a map of entity descriptors and produces a router per entity.

```ts
// server/lib/generateEntityRouter.ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';
import type { PrismaClient } from '@prisma/client';

interface EntityConfig {
  model: keyof PrismaClient;
  createSchema: z.ZodTypeAny;
  updateSchema: z.ZodTypeAny;
}

export function generateEntityRouter(
  db: PrismaClient,
  config: EntityConfig
) {
  const model = db[config.model] as any;

  return router({
    list: publicProcedure
      .query(() => model.findMany()),

    get: publicProcedure
      .input(z.object({ id: z.string() }))
      .query(({ input }) => model.findUnique({ where: { id: input.id } })),

    create: publicProcedure
      .input(config.createSchema)
      .mutation(({ input }) => model.create({ data: input })),

    update: publicProcedure
      .input(z.object({ id: z.string(), data: config.updateSchema }))
      .mutation(({ input }) => model.update({
        where: { id: input.id },
        data: input.data,
      })),

    delete: publicProcedure
      .input(z.object({ id: z.string() }))
      .mutation(({ input }) => model.delete({ where: { id: input.id } })),
  });
}
```

**Usage:**

```ts
// server/routers/index.ts
import { generateEntityRouter } from '../lib/generateEntityRouter';
import { db } from '../db';
import { z } from 'zod';

const postCreateSchema = z.object({ title: z.string(), body: z.string() });
const postUpdateSchema = z.object({ title: z.string().optional(), body: z.string().optional() });

const tagCreateSchema = z.object({ name: z.string() });
const tagUpdateSchema = z.object({ name: z.string().optional() });

export const appRouter = router({
  post: generateEntityRouter(db, {
    model: 'post',
    createSchema: postCreateSchema,
    updateSchema: postUpdateSchema,
  }),
  tag: generateEntityRouter(db, {
    model: 'tag',
    createSchema: tagCreateSchema,
    updateSchema: tagUpdateSchema,
  }),
});
```

**Key Points:**

- The router shape (`list`, `get`, `create`, `update`, `delete`) is uniform — adding a new entity requires only a new config entry
- Schemas remain explicitly defined per entity, preserving type safety at the boundary
- The `any` cast on `model` is a known trade-off when working with dynamic Prisma model access [Inference: stricter Prisma generics are possible but require significant additional typing effort]

---

### Pattern: Generating from a Configuration Array

When entities or resources are described in a configuration array, you can reduce the router assembly to a single loop.

```ts
// server/config/resources.ts
import { z } from 'zod';

export const resources = [
  {
    name: 'category',
    createSchema: z.object({ label: z.string() }),
    updateSchema: z.object({ label: z.string().optional() }),
  },
  {
    name: 'author',
    createSchema: z.object({ name: z.string(), bio: z.string().optional() }),
    updateSchema: z.object({ name: z.string().optional(), bio: z.string().optional() }),
  },
] as const;
```

```ts
// server/routers/generated.ts
import { router } from '../trpc';
import { resources } from '../config/resources';
import { generateEntityRouter } from '../lib/generateEntityRouter';
import { db } from '../db';

const generatedRouters = Object.fromEntries(
  resources.map((resource) => [
    resource.name,
    generateEntityRouter(db, {
      model: resource.name as any,
      createSchema: resource.createSchema,
      updateSchema: resource.updateSchema,
    }),
  ])
);

export const generatedRouter = router(generatedRouters);
```

**Key Points:**

- `Object.fromEntries` converts the array of `[name, router]` pairs into the shape `t.router()` expects
- TypeScript may not infer the keys of `generatedRouters` as a strict literal union from this pattern — downstream type inference may be wider than ideal [Inference: exact behavior depends on TypeScript version and whether `as const` is applied to intermediate values]
- This pattern trades some static type precision for significant reduction in boilerplate

---

### Pattern: Schema-Driven Generation

Procedures can be generated directly from a Zod schema by reflecting on its shape. This is useful when a schema is the canonical source of truth for a data model.

```ts
// server/lib/schemaRouter.ts
import { z } from 'zod';
import { router, protectedProcedure } from '../trpc';

type ZodObjectShape = z.ZodObject<any>;

export function createSchemaRouter<T extends ZodObjectShape>(
  name: string,
  schema: T,
  db: any
) {
  const model = db[name];

  return router({
    list: protectedProcedure
      .output(z.array(schema))
      .query(() => model.findMany()),

    get: protectedProcedure
      .input(z.object({ id: z.string() }))
      .output(schema.nullable())
      .query(({ input }) => model.findUnique({ where: { id: input.id } })),

    create: protectedProcedure
      .input(schema.omit({ id: true, createdAt: true, updatedAt: true }))
      .output(schema)
      .mutation(({ input }) => model.create({ data: input })),
  });
}
```

**Usage:**

```ts
const PostSchema = z.object({
  id: z.string(),
  title: z.string(),
  body: z.string(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

export const postRouter = createSchemaRouter('post', PostSchema, db);
```

**Key Points:**

- `.omit()` on the Zod schema derives the create input from the full schema, removing server-managed fields
- `.output()` attaches runtime validation to responses, catching resolver mismatches early
- [Inference: the Zod `.omit()` approach assumes the schema has known, stable field names to omit — dynamic schemas with variable shapes may not work reliably with this pattern]

---

### Pattern: Conditional Procedure Inclusion

Dynamic generation can selectively include or exclude procedures based on a capability flag per entity.

```ts
// server/lib/generateResourceRouter.ts
import { z } from 'zod';
import { router } from '../trpc';

interface ResourceConfig {
  procedure: any;
  model: any;
  capabilities?: {
    list?: boolean;
    get?: boolean;
    create?: boolean;
    delete?: boolean;
  };
}

export function generateResourceRouter({
  procedure,
  model,
  capabilities = { list: true, get: true, create: true, delete: true },
}: ResourceConfig) {
  const procedures: Record<string, any> = {};

  if (capabilities.list) {
    procedures.list = procedure.query(() => model.findMany());
  }

  if (capabilities.get) {
    procedures.get = procedure
      .input(z.object({ id: z.string() }))
      .query(({ input }: any) => model.findUnique({ where: { id: input.id } }));
  }

  if (capabilities.create) {
    procedures.create = procedure
      .input(z.unknown())
      .mutation(({ input }: any) => model.create({ data: input }));
  }

  if (capabilities.delete) {
    procedures.delete = procedure
      .input(z.object({ id: z.string() }))
      .mutation(({ input }: any) => model.delete({ where: { id: input.id } }));
  }

  return router(procedures);
}
```

**Usage:**

```ts
// Read-only resource — no create or delete
const configRouter = generateResourceRouter({
  procedure: adminProcedure,
  model: db.config,
  capabilities: { list: true, get: true, create: false, delete: false },
});
```

---

### Visualizing Dynamic Generation Flow

mapObject.fromEntriesomit / extendconditional inclusionEntity Config ArraygenerateEntityRouter x NgeneratedRouters objectt.router - generatedRouterZod SchemacreateSchemaRouterschema-bound routerCapability FlagsgenerateResourceRouterpartial routerappRouter

---

### Type Inference Limitations

Dynamic generation introduces a well-known tension with tRPC's type system. tRPC's end-to-end type safety depends on TypeScript being able to statically infer the full shape of `appRouter`. When routers are assembled dynamically, this inference can degrade.

**Specific situations where type inference weakens:**

- `Object.fromEntries` typically infers `Record<string, V>` rather than a keyed literal type, losing procedure-level type specificity on the client
- Procedures typed as `any` inside factory functions break the inference chain for that procedure's input and output
- Schemas passed as `z.ZodTypeAny` (rather than a concrete generic) lose their shape information downstream

**Mitigation — explicit return type annotation:**

```ts
import type { AnyRouter } from '@trpc/server';

export function generateEntityRouter(
  db: PrismaClient,
  config: EntityConfig
): AnyRouter {
  // ...
}
```

Annotating as `AnyRouter` sacrifices per-procedure type inference on the client in exchange for a stable, compilable type. [Inference: the right trade-off depends on whether the client needs strongly typed access to dynamically generated procedures]

**Mitigation — manual type assertion at assembly:**

```ts
export const appRouter = router({
  post: generateEntityRouter(db, postConfig) as ReturnType<typeof buildPostRouter>,
  tag: generateEntityRouter(db, tagConfig) as ReturnType<typeof buildTagRouter>,
});
```

This restores client-side type inference at the cost of an explicit assertion per route. [Inference: correctness of the assertion is not enforced — it is the developer's responsibility to keep the cast accurate]

---

### Runtime vs. Module-Load-Time Generation

All examples above generate procedures at **module load time** — when the server starts, the router is assembled once and remains static for the lifetime of the process.

Generating procedures at **request time** (inside a request handler) is not supported by tRPC's architecture and would be counterproductive — the router shape must be known ahead of time for the client-side type system to function. [Inference: this reflects tRPC's design intent; attempting runtime router mutation would bypass the type system entirely]

---

### Common Pitfalls

**Pitfall 1 — Overgeneralizing too early:**
Generating procedures from a config is most valuable when the config entries are genuinely uniform. If individual entities need meaningfully different behavior, forcing them into a shared factory produces a factory that accumulates special cases and becomes harder to reason about than explicit procedures.

**Pitfall 2 — Losing error context:**
Errors thrown inside dynamically generated procedures may be harder to trace because the procedure's name in stack traces may be generic. Adding explicit `path` or `name` annotations in error messages where possible aids debugging.

**Pitfall 3 — Schema drift:**
When Zod schemas are passed into factories and then used both for input validation and output validation, a mismatch between the schema and the actual database model can cause runtime errors that are not caught at compile time. Keep schemas co-located with their models and update them together.

---

**Conclusion**

Dynamic procedure generation is a powerful tool for reducing structural boilerplate when a set of procedures is genuinely uniform in shape and differs only in configuration. The core patterns — entity map generation, config array loops, and schema-driven derivation — all operate at module load time and pass procedure builders into factory functions rather than constructing procedures after the router is finalized. The primary cost is a reduction in TypeScript's ability to infer precise client-side types; this trade-off should be evaluated per use case, and explicit type annotations or assertions used where full inference cannot be preserved.