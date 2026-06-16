## Generating an OpenAPI Spec from tRPC

tRPC does not produce an OpenAPI specification natively. Its type safety is expressed through TypeScript inference, not a language-agnostic schema format. Generating an OpenAPI spec from a tRPC router requires a bridge layer — either a community package that introspects the router, or a manual translation approach. The result enables REST clients, API explorers (Swagger UI, Redoc), and code generators to consume a tRPC backend without knowing anything about tRPC.

---

### Why Generate OpenAPI from tRPC

**Key Points:**
- External consumers (mobile teams, third-party integrators, non-TypeScript services) expect REST + OpenAPI, not tRPC's HTTP envelope
- OpenAPI enables automatic client generation in any language via tools like `openapi-generator` and `swagger-typescript-api`
- API documentation portals (Swagger UI, Redoc, Stoplight) consume OpenAPI natively
- Some organizations require an OpenAPI contract as a delivery artifact for compliance or partner integration [Inference]

---

### Primary Tool: `trpc-openapi`

The most widely adopted community package for this purpose is `trpc-openapi`. It extends tRPC procedures with OpenAPI metadata and generates a spec from the router.

**Installation:**

```bash
npm install trpc-openapi
```

**Key Points:**
- `trpc-openapi` requires Zod as the input validator — procedures without Zod input schemas cannot be included in the generated spec [Inference — verify against current package version]
- The package adds an `.meta()` call to procedures where OpenAPI metadata (method, path, summary, tags) is declared
- Output is a standard OpenAPI 3.0 object that can be serialized to JSON or YAML

---

### Marking Procedures with OpenAPI Metadata

Each procedure that should appear in the spec is annotated with `.meta()` containing an `openapi` key.

**Example — router with OpenAPI metadata (`src/server/routers/user.ts`):**

```ts
import { z } from "zod";
import { router, publicProcedure, protectedProcedure } from "../trpc";

export const userRouter = router({
  getById: publicProcedure
    .meta({
      openapi: {
        method: "GET",
        path: "/users/{id}",
        summary: "Get a user by ID",
        description: "Returns a single user record by their unique identifier.",
        tags: ["Users"],
      },
    })
    .input(z.object({ id: z.string() }))
    .output(z.object({
      id: z.string(),
      name: z.string(),
      email: z.string().email(),
      createdAt: z.string().datetime(),
    }))
    .query(({ input }) => getUserById(input.id)),

  create: protectedProcedure
    .meta({
      openapi: {
        method: "POST",
        path: "/users",
        summary: "Create a new user",
        tags: ["Users"],
        protect: true,         // marks endpoint as requiring auth in the spec
      },
    })
    .input(z.object({
      name: z.string().min(1),
      email: z.string().email(),
    }))
    .output(z.object({
      id: z.string(),
      name: z.string(),
      email: z.string().email(),
    }))
    .mutation(({ input }) => createUser(input)),

  list: publicProcedure
    .meta({
      openapi: {
        method: "GET",
        path: "/users",
        summary: "List all users",
        tags: ["Users"],
      },
    })
    .input(z.object({
      limit: z.number().int().min(1).max(100).default(20),
      offset: z.number().int().min(0).default(0),
    }))
    .output(z.array(z.object({
      id: z.string(),
      name: z.string(),
    })))
    .query(({ input }) => listUsers(input)),
});
```

**Key Points:**
- `path` uses OpenAPI path parameter syntax (`{id}`), not tRPC's dot notation
- `output` schema is required for accurate response schema generation — procedures without `.output()` may produce incomplete specs [Inference]
- `protect: true` adds a security requirement to the operation in the generated spec
- Procedures without `.meta({ openapi: ... })` are silently excluded from the spec

---

### Initializing tRPC with OpenAPI Support

`trpc-openapi` provides its own `initTRPC` wrapper that adds the metadata type to procedures.

**Example — `src/server/trpc.ts`:**

```ts
import { initTRPC } from "@trpc/server";
import { OpenApiMeta } from "trpc-openapi";
import type { Context } from "./context";

const t = initTRPC.context<Context>().meta<OpenApiMeta>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
export const protectedProcedure = t.procedure.use(authMiddleware);
```

**Key Points:**
- `.meta<OpenApiMeta>()` types the `.meta()` call on every procedure — without it, TypeScript does not recognize the `openapi` key
- This is additive — existing procedures that do not use `.meta()` continue to work normally

---

### Generating the OpenAPI Document

The spec is generated from the root router using `generateOpenApiDocument`.

**Example — `src/server/openapi.ts`:**

```ts
import { generateOpenApiDocument } from "trpc-openapi";
import { appRouter } from "./routers/_app";

export const openApiDocument = generateOpenApiDocument(appRouter, {
  title: "My API",
  version: "1.0.0",
  baseUrl: "https://api.example.com",
  docsUrl: "https://docs.example.com",
  tags: ["Users", "Posts", "Auth"],
});
```

**Output shape (partial):**

```json
{
  "openapi": "3.0.3",
  "info": {
    "title": "My API",
    "version": "1.0.0"
  },
  "paths": {
    "/users/{id}": {
      "get": {
        "summary": "Get a user by ID",
        "tags": ["Users"],
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "schema": { "type": "string" }
          }
        ],
        "responses": {
          "200": {
            "description": "Successful response",
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "id": { "type": "string" },
                    "name": { "type": "string" },
                    "email": { "type": "string", "format": "email" }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

---

### Serving the Spec and Swagger UI

The generated document is served as a JSON endpoint. Swagger UI can be mounted alongside it.

**Example — Express (`src/server.ts`):**

```ts
import express from "express";
import { createExpressMiddleware } from "@trpc/server/adapters/express";
import { createOpenApiExpressMiddleware } from "trpc-openapi";
import swaggerUi from "swagger-ui-express";
import { appRouter } from "./routers/_app";
import { openApiDocument } from "./openapi";
import { createContext } from "./context";

const app = express();

// tRPC handler (original path)
app.use("/trpc", createExpressMiddleware({ router: appRouter, createContext }));

// OpenAPI-compatible REST handler (trpc-openapi translates REST → tRPC)
app.use("/api", createOpenApiExpressMiddleware({ router: appRouter, createContext }));

// Serve the OpenAPI spec
app.get("/openapi.json", (_req, res) => res.json(openApiDocument));

// Swagger UI
app.use("/docs", swaggerUi.serve, swaggerUi.setup(openApiDocument));

app.listen(3000);
```

**Key Points:**
- `createOpenApiExpressMiddleware` is a second handler that translates incoming REST requests into tRPC procedure calls — the same procedures handle both tRPC and REST traffic
- The original `/trpc` handler continues to work — both coexist
- `swagger-ui-express` serves an interactive Swagger UI at `/docs` [Unverified — verify package compatibility with your Express version]

---

### Next.js: Serving the Spec and OpenAPI Handler

**Example — `app/api/openapi.json/route.ts`:**

```ts
import { NextResponse } from "next/server";
import { openApiDocument } from "@/server/openapi";

export function GET() {
  return NextResponse.json(openApiDocument);
}
```

**Example — `app/api/[...trpc]/route.ts` (existing tRPC handler, unchanged):**

```ts
// Standard tRPC Next.js handler — no changes needed
```

**Example — `app/api/rest/[...path]/route.ts` (OpenAPI REST handler):**

```ts
import { createOpenApiNextHandler } from "trpc-openapi";
import { appRouter } from "@/server/routers/_app";
import { createContext } from "@/server/context";

const handler = createOpenApiNextHandler({
  router: appRouter,
  createContext,
});

export { handler as GET, handler as POST, handler as PUT, handler as DELETE, handler as PATCH };
```

---

### Zod-to-OpenAPI Schema Mapping

`trpc-openapi` uses Zod's schema introspection to generate JSON Schema / OpenAPI schema objects. Common mappings:

| Zod Schema | OpenAPI Schema |
|---|---|
| `z.string()` | `{ "type": "string" }` |
| `z.string().email()` | `{ "type": "string", "format": "email" }` |
| `z.string().uuid()` | `{ "type": "string", "format": "uuid" }` |
| `z.number().int()` | `{ "type": "integer" }` |
| `z.boolean()` | `{ "type": "boolean" }` |
| `z.array(z.string())` | `{ "type": "array", "items": { "type": "string" } }` |
| `z.object({...})` | `{ "type": "object", "properties": {...} }` |
| `z.enum(["a","b"])` | `{ "type": "string", "enum": ["a","b"] }` |
| `z.optional(z.string())` | schema without `required` constraint |
| `z.union([...])` | `{ "oneOf": [...] }` |

**Key Points:**
- Complex Zod types (discriminated unions, recursive schemas, `z.lazy()`) may not map cleanly to OpenAPI 3.0 — verify generated output for these cases [Inference]
- `z.date()` serialization in OpenAPI depends on transformer configuration — without SuperJSON, dates arrive as strings and should be modeled as `z.string().datetime()` in the output schema

---

### Adding Security Schemes

Authentication requirements are declared in the document options and referenced per-procedure via `protect: true`.

**Example — bearer token security scheme:**

```ts
export const openApiDocument = generateOpenApiDocument(appRouter, {
  title: "My API",
  version: "1.0.0",
  baseUrl: "https://api.example.com",
  securitySchemes: {
    bearerAuth: {
      type: "http",
      scheme: "bearer",
      bearerFormat: "JWT",
    },
  },
  security: [{ bearerAuth: [] }],  // default security for all protected endpoints
});
```

**Key Points:**
- `security` at the document level sets a default; individual operations can override it
- `protect: true` on a procedure's OpenAPI meta causes `trpc-openapi` to include the security requirement on that operation [Inference — verify exact behavior in current package version]

---

### Spec Generation Flow

<svg viewBox="0 0 680 320" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <rect width="680" height="320" fill="#0f1117" rx="12"/>
  <text x="340" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">OpenAPI Generation and Request Flow</text>

  <!-- tRPC Router box -->
  <rect x="30" y="55" width="160" height="60" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="110" y="80" text-anchor="middle" fill="#94a3b8" font-size="12" font-weight="bold">tRPC Router</text>
  <text x="110" y="98" text-anchor="middle" fill="#64748b" font-size="11">+ .meta(openapi)</text>

  <!-- arrow right to generateOpenApiDocument -->
  <line x1="190" y1="85" x2="255" y2="85" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>

  <!-- generateOpenApiDocument box -->
  <rect x="255" y="55" width="180" height="60" rx="8" fill="#1e3a5f" stroke="#2563eb" stroke-width="1.5"/>
  <text x="345" y="78" text-anchor="middle" fill="#93c5fd" font-size="12" font-weight="bold">generateOpenApiDocument</text>
  <text x="345" y="96" text-anchor="middle" fill="#60a5fa" font-size="11">Zod → JSON Schema</text>

  <!-- arrow right to OpenAPI doc -->
  <line x1="435" y1="85" x2="495" y2="85" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>

  <!-- OpenAPI doc box -->
  <rect x="495" y="55" width="155" height="60" rx="8" fill="#1a2e1a" stroke="#16a34a" stroke-width="1.5"/>
  <text x="572" y="78" text-anchor="middle" fill="#86efac" font-size="12" font-weight="bold">OpenAPI 3.0 Doc</text>
  <text x="572" y="96" text-anchor="middle" fill="#4ade80" font-size="11">JSON / YAML</text>

  <!-- arrow down from OpenAPI doc to consumers -->
  <line x1="572" y1="115" x2="572" y2="160" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>

  <!-- Swagger UI -->
  <rect x="460" y="160" width="130" height="48" rx="8" fill="#1e293b" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="525" y="180" text-anchor="middle" fill="#fcd34d" font-size="11" font-weight="bold">Swagger UI</text>
  <text x="525" y="198" text-anchor="middle" fill="#92400e" font-size="10">/docs</text>

  <!-- Code gen -->
  <rect x="460" y="225" width="130" height="48" rx="8" fill="#1e293b" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="525" y="245" text-anchor="middle" fill="#c4b5fd" font-size="11" font-weight="bold">Client Codegen</text>
  <text x="525" y="263" text-anchor="middle" fill="#6d28d9" font-size="10">openapi-generator</text>

  <!-- OpenAPI REST middleware -->
  <rect x="30" y="160" width="200" height="48" rx="8" fill="#1a2e1a" stroke="#059669" stroke-width="1.5"/>
  <text x="130" y="180" text-anchor="middle" fill="#6ee7b7" font-size="11" font-weight="bold">OpenAPI REST Middleware</text>
  <text x="130" y="198" text-anchor="middle" fill="#34d399" font-size="10">createOpenApiExpressMiddleware</text>

  <!-- arrow from router down to middleware -->
  <line x1="110" y1="115" x2="110" y2="160" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>

  <!-- REST client -->
  <rect x="30" y="225" width="200" height="48" rx="8" fill="#1e293b" stroke="#dc2626" stroke-width="1.5"/>
  <text x="130" y="245" text-anchor="middle" fill="#fca5a5" font-size="11" font-weight="bold">REST Client</text>
  <text x="130" y="263" text-anchor="middle" fill="#f87171" font-size="10">Python / Swift / Kotlin / curl</text>

  <!-- arrow middleware to REST client -->
  <line x1="130" y1="208" x2="130" y2="225" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>

  <defs>
    <marker id="a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
  </defs>
</svg>

---

### Exporting the Spec to a File

For CI pipelines, partner delivery, or documentation build processes, the spec can be written to disk as a build step.

**Example — `scripts/generate-openapi.ts`:**

```ts
import { writeFileSync } from "fs";
import { openApiDocument } from "../src/server/openapi";

const json = JSON.stringify(openApiDocument, null, 2);
writeFileSync("./openapi.json", json, "utf-8");
console.log("OpenAPI spec written to openapi.json");
```

**Run with:**

```bash
npx tsx scripts/generate-openapi.ts
```

**Key Points:**
- Add this script to the CI pipeline to detect spec drift — if the generated output differs from a committed `openapi.json`, the build fails [Inference — requires a diff check step in CI]
- The committed `openapi.json` can be consumed by documentation platforms (Stoplight, ReadMe) via Git sync integrations

---

### Known Limitations

**Key Points:**
- `trpc-openapi` requires Zod — procedures using other validators (Yup, Valibot, custom) are not supported without adaptation [Inference — verify against current package]
- Subscription procedures (WebSocket-based) cannot be represented in OpenAPI 3.0 and are excluded from the generated spec
- Complex Zod refinements (`.refine()`, `.superRefine()`) may not produce meaningful OpenAPI constraints — the schema will validate correctly at runtime but the spec may show a looser type [Inference]
- Path parameter names in `.meta({ openapi: { path: "/users/{id}" } })` must match Zod input field names exactly — mismatches cause runtime errors [Inference]
- `trpc-openapi` is a community package with no official Anthropic or tRPC core team backing — assess maintenance status before adopting in production [Unverified — check current repository activity]

---

### Alternative: `zod-to-openapi` with Manual Router Mapping

For teams that need more control over the output or cannot use `trpc-openapi`, `@asteasolutions/zod-to-openapi` converts Zod schemas directly to OpenAPI schema objects, and procedures are mapped manually.

**Example — manual mapping:**

```ts
import { OpenApiGeneratorV3, OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";

const registry = new OpenAPIRegistry();

const UserSchema = registry.register(
  "User",
  z.object({
    id: z.string().openapi({ example: "usr_123" }),
    name: z.string().openapi({ example: "Alice" }),
    email: z.string().email(),
  })
);

registry.registerPath({
  method: "get",
  path: "/users/{id}",
  summary: "Get user by ID",
  request: {
    params: z.object({ id: z.string() }),
  },
  responses: {
    200: {
      description: "User found",
      content: { "application/json": { schema: UserSchema } },
    },
    404: { description: "User not found" },
  },
});

const generator = new OpenApiGeneratorV3(registry.definitions);
const document = generator.generateDocument({
  openapi: "3.0.0",
  info: { title: "My API", version: "1.0.0" },
  servers: [{ url: "https://api.example.com" }],
});
```

**Key Points:**
- This approach is more verbose but gives full control over the generated spec
- Schema registration with `registry.register()` enables `$ref` reuse across paths, producing a cleaner spec
- The REST handler must be implemented separately — unlike `trpc-openapi`, this approach does not provide a middleware that translates REST to tRPC [Inference]

---

**Conclusion:**
Generating an OpenAPI spec from tRPC is achieved primarily through `trpc-openapi`, which adds OpenAPI metadata to procedures and derives JSON Schema from Zod validators. The same procedures simultaneously serve the original tRPC HTTP interface and an OpenAPI-compatible REST interface via a companion middleware. The generated spec integrates with Swagger UI for documentation, `openapi-generator` for client generation, and CI pipelines for contract validation. Limitations around complex Zod types, non-Zod validators, and subscriptions should be assessed before committing to this approach in production. All behavioral claims about `trpc-openapi` should be verified against the current package version, as the package is community-maintained and its API surface may evolve.