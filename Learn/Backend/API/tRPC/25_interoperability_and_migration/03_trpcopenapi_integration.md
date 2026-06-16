## trpc-openapi Integration

`trpc-openapi` is the bridge package that connects tRPC's procedure model to the OpenAPI ecosystem. Beyond generating a spec document, it provides runtime middleware that accepts standard REST requests and translates them into tRPC procedure calls — meaning the same procedure code handles both the tRPC client path and the REST path simultaneously. This topic covers the full integration in depth.

---

### Package Overview and Architecture

`trpc-openapi` operates on two levels:

- **Build time** — `generateOpenApiDocument` introspects the router and its Zod schemas to produce an OpenAPI 3.0 document
- **Runtime** — adapter-specific middleware (`createOpenApiExpressMiddleware`, `createOpenApiNextHandler`, etc.) intercepts incoming REST HTTP requests, maps them to procedures, validates input, calls the procedure, and formats the response as plain JSON

The two levels are independent. You can generate the spec without mounting the REST middleware, and vice versa — though both together is the typical configuration.

---

### Installation and Peer Dependencies

```bash
npm install trpc-openapi
```

**Peer dependencies (must already be installed):**

```bash
npm install @trpc/server zod
```

**Key Points:**
- `trpc-openapi` requires Zod as the input/output validator — procedures using other validators are excluded from the spec and REST handler
- The package targets tRPC v10+ — earlier versions used a different integration model [Unverified — verify against your tRPC version]
- No additional Zod version constraints are documented by the package, but mismatches between your Zod version and the one expected by `trpc-openapi` can cause subtle schema introspection failures [Inference]

---

### Configuring the tRPC Instance

The tRPC instance must be initialized with `OpenApiMeta` to type the `.meta()` call on procedures.

**Example — `src/server/trpc.ts`:**

```ts
import { initTRPC, TRPCError } from "@trpc/server";
import { OpenApiMeta } from "trpc-openapi";
import superjson from "superjson";
import type { Context } from "./context";

const t = initTRPC.context<Context>().meta<OpenApiMeta>().create({
  transformer: superjson,
});

export const router = t.router;
export const middleware = t.middleware;
export const publicProcedure = t.procedure;

const isAuthed = t.middleware(({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({ code: "UNAUTHORIZED" });
  }
  return next({ ctx: { ...ctx, user: ctx.session.user } });
});

export const protectedProcedure = t.procedure.use(isAuthed);
```

**Key Points:**
- `.meta<OpenApiMeta>()` is chained between `.context<Context>()` and `.create()` — placement matters [Inference — based on tRPC builder chain convention]
- SuperJSON transformer continues to work for the tRPC client path; the OpenAPI REST middleware bypasses SuperJSON and returns plain JSON regardless [Inference — verify against current package behavior]

---

### Procedure Meta Reference

Every procedure exposed via OpenAPI must declare an `openapi` key in `.meta()`. The full set of supported fields:

```ts
.meta({
  openapi: {
    // Required
    method: "GET" | "POST" | "PUT" | "PATCH" | "DELETE",
    path: "/resource/{param}",          // OpenAPI path syntax

    // Strongly recommended
    summary: "Short description",       // shown as operation title in Swagger UI
    description: "Longer explanation",  // shown in expanded view
    tags: ["ResourceName"],             // groups operations in Swagger UI

    // Auth
    protect: true,                      // adds security requirement to operation

    // Optional
    deprecated: true,                   // marks operation as deprecated in spec
    contentTypes: ["application/json"], // request content types accepted
    headers: [                          // declare expected request headers
      {
        name: "x-request-id",
        required: false,
        schema: { type: "string" },
      },
    ],
    successDescription: "User returned",   // overrides default 200 description
    errorResponses: [400, 401, 404, 500],  // documents these error status codes
  },
})
```

**Key Points:**
- Procedures without `.meta({ openapi: ... })` are silently excluded from both the spec and the REST middleware routing table
- `method` and `path` together form the operation's unique identity — duplicate combinations cause undefined behavior [Inference]
- `errorResponses` documents the codes in the spec but does not enforce them — actual error codes are determined by tRPC error mapping at runtime

---

### HTTP Method and Path Design

tRPC queries conventionally map to `GET` and mutations map to `POST`, `PUT`, `PATCH`, or `DELETE`. The mapping is not automatic — you declare it explicitly in `.meta()`.

**Conventional mapping:**

| tRPC type | Typical HTTP method | Use case |
|---|---|---|
| `query` | `GET` | Read, fetch, list |
| `mutation` | `POST` | Create |
| `mutation` | `PUT` | Full replace |
| `mutation` | `PATCH` | Partial update |
| `mutation` | `DELETE` | Remove |

**Key Points:**
- `trpc-openapi` does not enforce REST semantics — a `query` can be mapped to `POST` if needed (e.g., for queries with complex filter bodies that cannot fit in a query string) [Inference]
- Path parameters (`{id}`) must correspond exactly to field names in the Zod input schema — a mismatch causes a runtime error when the REST middleware tries to extract the value

**Example — path param alignment:**

```ts
// path: "/users/{userId}" → input must have field named "userId"
.input(z.object({ userId: z.string() }))   // ✅ matches {userId}
.input(z.object({ id: z.string() }))       // ❌ mismatch — runtime error
```

---

### Input Handling by HTTP Method

How `trpc-openapi` extracts procedure input from the request differs by method:

#### GET, DELETE — Query String and Path Params

Input fields are extracted from path parameters and query string parameters. Complex nested objects are not supported cleanly in query strings.

```
GET /users/123?includeProfile=true
```

Maps to Zod input:

```ts
z.object({
  id: z.string(),                             // from path param {id}
  includeProfile: z.boolean().optional(),     // from query string
})
```

#### POST, PUT, PATCH — Request Body

Input is extracted from the JSON request body. Path parameters are also extracted and merged.

```
POST /users/123/posts
Content-Type: application/json

{ "title": "Hello", "body": "World" }
```

Maps to Zod input:

```ts
z.object({
  userId: z.string(),         // from path param {userId}
  title: z.string(),          // from request body
  body: z.string(),           // from request body
})
```

**Key Points:**
- For GET requests, all input fields that are not path parameters become query string parameters — deeply nested schemas produce awkward query strings and should be avoided [Inference]
- Boolean and number coercion from query strings requires Zod's `.coerce` variants: `z.coerce.boolean()`, `z.coerce.number()` — plain `z.boolean()` will fail to parse `"true"` from a query string [Inference — verify against current package version]

---

### Output Schema Requirements

`.output()` on procedures is required for accurate response schema generation. Without it, the spec shows an empty or `any` response schema.

**Example — typed output:**

```ts
const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email(),
  role: z.enum(["admin", "user", "guest"]),
  createdAt: z.string().datetime(),
});

export const userRouter = router({
  getById: publicProcedure
    .meta({ openapi: { method: "GET", path: "/users/{id}", tags: ["Users"] } })
    .input(z.object({ id: z.string().uuid() }))
    .output(UserSchema)
    .query(({ input }) => getUserById(input.id)),
});
```

**Key Points:**
- `z.string().datetime()` rather than `z.date()` is the appropriate output type for timestamps when not using SuperJSON, because dates are serialized as ISO strings in plain JSON
- Reusing schema objects (e.g., `UserSchema`) across multiple procedures reduces spec verbosity via `$ref` if the package supports schema deduplication [Unverified — check current package behavior]

---

### Express Integration: Full Setup

**Example — `src/server.ts`:**

```ts
import express from "express";
import cors from "cors";
import { createExpressMiddleware } from "@trpc/server/adapters/express";
import { createOpenApiExpressMiddleware } from "trpc-openapi";
import swaggerUi from "swagger-ui-express";
import { appRouter } from "./routers/_app";
import { openApiDocument } from "./openapi";
import { createContext } from "./context";

const app = express();

app.use(cors());
app.use(express.json());

// 1. tRPC handler — original typed client path
app.use("/trpc", createExpressMiddleware({
  router: appRouter,
  createContext,
}));

// 2. OpenAPI REST handler — translates REST → tRPC procedures
app.use("/api", createOpenApiExpressMiddleware({
  router: appRouter,
  createContext,
  responseMeta: ({ data, errors }) => {
    // Customize response headers per operation
    if (errors.length > 0) {
      return { headers: { "x-error": "true" } };
    }
    return {};
  },
}));

// 3. OpenAPI spec endpoint
app.get("/openapi.json", (_req, res) => res.json(openApiDocument));

// 4. Swagger UI
app.use("/docs", swaggerUi.serve, swaggerUi.setup(openApiDocument, {
  swaggerOptions: { persistAuthorization: true },
}));

app.listen(3000, () => console.log("Server running on port 3000"));
```

**Key Points:**
- `/trpc` and `/api` are separate prefixes — both are active simultaneously
- `responseMeta` is a hook for customizing response headers and status codes per operation without modifying procedure logic [Inference — verify signature against current package version]
- `persistAuthorization: true` in Swagger UI options retains the bearer token across page refreshes, improving developer experience

---

### Next.js App Router Integration: Full Setup

**Example — directory structure:**

```
app/
  api/
    trpc/
      [...trpc]/
        route.ts          ← tRPC handler
    openapi/
      [...path]/
        route.ts          ← OpenAPI REST handler
    spec/
      route.ts            ← serves openapi.json
  docs/
    page.tsx              ← Swagger UI page (client component)
```

**Example — `app/api/openapi/[...path]/route.ts`:**

```ts
import { createOpenApiNextHandler } from "trpc-openapi";
import { appRouter } from "@/server/routers/_app";
import { createContext } from "@/server/context";
import { NextRequest } from "next/server";

const handler = (req: NextRequest) =>
  createOpenApiNextHandler({
    router: appRouter,
    createContext: async () => createContext({ req }),
  })(req);

export {
  handler as GET,
  handler as POST,
  handler as PUT,
  handler as PATCH,
  handler as DELETE,
};
```

**Example — `app/api/spec/route.ts`:**

```ts
import { NextResponse } from "next/server";
import { openApiDocument } from "@/server/openapi";

export function GET() {
  return NextResponse.json(openApiDocument);
}
```

**Example — `app/docs/page.tsx` (Swagger UI via CDN):**

```tsx
"use client";

import { useEffect } from "react";

export default function DocsPage() {
  useEffect(() => {
    // Dynamically load swagger-ui-dist to avoid SSR issues
    async function load() {
      const SwaggerUIBundle = (await import("swagger-ui-dist/swagger-ui-bundle.js" as any)).default;
      SwaggerUIBundle({
        url: "/api/spec",
        dom_id: "#swagger-ui",
        presets: [SwaggerUIBundle.presets.apis, SwaggerUIBundle.SwaggerUIStandalonePreset],
        layout: "StandaloneLayout",
      });
    }
    load();
  }, []);

  return (
    <>
      <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist/swagger-ui.css" />
      <div id="swagger-ui" />
    </>
  );
}
```

**Key Points:**
- Swagger UI must be loaded as a client component in Next.js — it manipulates the DOM directly and is incompatible with SSR [Inference]
- The CDN stylesheet approach avoids bundling the large swagger-ui-dist CSS through Next.js
- `createContext` in the OpenAPI handler receives the raw `NextRequest`, which may differ from the context shape used in the tRPC handler — align the two carefully [Inference]

---

### Error Mapping: tRPC Errors to HTTP Status Codes

`trpc-openapi` maps tRPC error codes to HTTP status codes automatically:

| tRPC Error Code | HTTP Status |
|---|---|
| `BAD_REQUEST` | 400 |
| `UNAUTHORIZED` | 401 |
| `FORBIDDEN` | 403 |
| `NOT_FOUND` | 404 |
| `METHOD_NOT_SUPPORTED` | 405 |
| `TIMEOUT` | 408 |
| `CONFLICT` | 409 |
| `PRECONDITION_FAILED` | 412 |
| `PAYLOAD_TOO_LARGE` | 413 |
| `TOO_MANY_REQUESTS` | 429 |
| `INTERNAL_SERVER_ERROR` | 500 |

**Example — throwing mapped errors:**

```ts
import { TRPCError } from "@trpc/server";

.query(({ input, ctx }) => {
  const user = db.user.findUnique({ where: { id: input.id } });

  if (!user) {
    throw new TRPCError({
      code: "NOT_FOUND",
      message: `User ${input.id} not found`,
    });
  }

  return user;
})
```

**REST response for NOT_FOUND:**

```json
{
  "message": "User 123 not found",
  "code": "NOT_FOUND"
}
```

**Key Points:**
- The REST error response is plain JSON, not the tRPC envelope — it does not have the `[{ "error": { "json": ... } }]` array wrapper
- Custom error formatting via `errorFormatter` in the tRPC instance affects tRPC client responses but may not propagate fully to the OpenAPI REST handler [Inference — verify behavior]

---

### `responseMeta` Hook

The `responseMeta` callback customizes headers and status codes for REST responses without modifying procedure logic.

**Example — custom cache headers and status:**

```ts
createOpenApiExpressMiddleware({
  router: appRouter,
  createContext,
  responseMeta({ data, errors, ctx, paths, type }) {
    const allOk = errors.length === 0;
    const isQuery = type === "query";

    if (allOk && isQuery) {
      return {
        status: 200,
        headers: {
          "Cache-Control": "public, max-age=60, stale-while-revalidate=300",
        },
      };
    }

    if (!allOk) {
      const httpStatus =
        errors[0]?.data?.httpStatus ?? 500;
      return { status: httpStatus };
    }

    return {};
  },
})
```

**Key Points:**
- `responseMeta` fires after the procedure resolves — it cannot abort the request or modify the response body
- `errors[0]?.data?.httpStatus` retrieves the HTTP status that tRPC derived from the error code — using this avoids hardcoding status logic in `responseMeta` [Inference]

---

### Integration Architecture

<svg viewBox="0 0 700 370" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <rect width="700" height="370" fill="#0f1117" rx="12"/>
  <text x="350" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">trpc-openapi Runtime Request Flow</text>

  <!-- tRPC Client -->
  <rect x="30" y="55" width="140" height="48" rx="8" fill="#1e293b" stroke="#2563eb" stroke-width="1.5"/>
  <text x="100" y="75" text-anchor="middle" fill="#93c5fd" font-size="12" font-weight="bold">tRPC Client</text>
  <text x="100" y="93" text-anchor="middle" fill="#64748b" font-size="10">POST /trpc/user.getById</text>

  <!-- REST Client -->
  <rect x="30" y="130" width="140" height="48" rx="8" fill="#1e293b" stroke="#dc2626" stroke-width="1.5"/>
  <text x="100" y="150" text-anchor="middle" fill="#fca5a5" font-size="12" font-weight="bold">REST Client</text>
  <text x="100" y="168" text-anchor="middle" fill="#64748b" font-size="10">GET /api/users/123</text>

  <!-- Spec Consumer -->
  <rect x="30" y="205" width="140" height="48" rx="8" fill="#1e293b" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="100" y="225" text-anchor="middle" fill="#fcd34d" font-size="12" font-weight="bold">Swagger UI</text>
  <text x="100" y="243" text-anchor="middle" fill="#64748b" font-size="10">GET /openapi.json</text>

  <!-- tRPC handler -->
  <rect x="240" y="42" width="175" height="60" rx="8" fill="#1e3a5f" stroke="#2563eb" stroke-width="1.5"/>
  <text x="327" y="65" text-anchor="middle" fill="#93c5fd" font-size="11" font-weight="bold">tRPC Express Middleware</text>
  <text x="327" y="83" text-anchor="middle" fill="#60a5fa" font-size="10">createExpressMiddleware</text>
  <text x="327" y="97" text-anchor="middle" fill="#475569" font-size="10">prefix: /trpc</text>

  <!-- OpenAPI middleware -->
  <rect x="240" y="118" width="175" height="60" rx="8" fill="#1a2e1a" stroke="#16a34a" stroke-width="1.5"/>
  <text x="327" y="141" text-anchor="middle" fill="#86efac" font-size="11" font-weight="bold">OpenAPI Middleware</text>
  <text x="327" y="159" text-anchor="middle" fill="#4ade80" font-size="10">createOpenApiExpressMiddleware</text>
  <text x="327" y="173" text-anchor="middle" fill="#475569" font-size="10">prefix: /api</text>

  <!-- Spec endpoint -->
  <rect x="240" y="194" width="175" height="60" rx="8" fill="#2a1a1a" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="327" y="217" text-anchor="middle" fill="#fcd34d" font-size="11" font-weight="bold">Spec Endpoint</text>
  <text x="327" y="235" text-anchor="middle" fill="#d97706" font-size="10">generateOpenApiDocument</text>
  <text x="327" y="249" text-anchor="middle" fill="#475569" font-size="10">GET /openapi.json</text>

  <!-- appRouter box -->
  <rect x="490" y="118" width="175" height="60" rx="8" fill="#1e1a2e" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="577" y="141" text-anchor="middle" fill="#c4b5fd" font-size="12" font-weight="bold">appRouter</text>
  <text x="577" y="159" text-anchor="middle" fill="#a78bfa" font-size="10">user.getById procedure</text>
  <text x="577" y="173" text-anchor="middle" fill="#475569" font-size="10">+ Zod schema</text>

  <!-- Arrows: clients to handlers -->
  <line x1="170" y1="79" x2="240" y2="72" stroke="#2563eb" stroke-width="1.2" marker-end="url(#a)" opacity="0.7"/>
  <line x1="170" y1="154" x2="240" y2="148" stroke="#16a34a" stroke-width="1.2" marker-end="url(#a)" opacity="0.7"/>
  <line x1="170" y1="229" x2="240" y2="224" stroke="#f59e0b" stroke-width="1.2" marker-end="url(#a)" opacity="0.7"/>

  <!-- Arrows: handlers to router -->
  <line x1="415" y1="72" x2="490" y2="138" stroke="#475569" stroke-width="1.2" marker-end="url(#a)"/>
  <line x1="415" y1="148" x2="490" y2="148" stroke="#475569" stroke-width="1.2" marker-end="url(#a)"/>

  <!-- Context label on OpenAPI → router arrow -->
  <text x="445" y="136" fill="#64748b" font-size="10">path map +</text>
  <text x="445" y="148" fill="#64748b" font-size="10">input parse</text>

  <!-- Procedure response arrow back -->
  <line x1="490" y1="168" x2="415" y2="168" stroke="#475569" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#a)"/>
  <text x="430" y="185" fill="#64748b" font-size="10">plain JSON</text>

  <!-- legend -->
  <rect x="30" y="290" width="620" height="60" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1"/>
  <text x="50" y="312" fill="#93c5fd" font-size="11">■ tRPC path</text>
  <text x="155" y="312" fill="#86efac" font-size="11">■ REST path (OpenAPI middleware)</text>
  <text x="380" y="312" fill="#fcd34d" font-size="11">■ Spec generation</text>
  <text x="50" y="335" fill="#64748b" font-size="10">Both paths invoke the same appRouter procedures — no duplicate logic</text>

  <defs>
    <marker id="a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
  </defs>
</svg>

---

### Testing the OpenAPI REST Endpoint

REST endpoints generated by `trpc-openapi` are plain HTTP and can be tested with `curl`, `httpx`, Postman, or any HTTP client.

**Example — curl:**

```bash
# Query (GET with path param)
curl http://localhost:3000/api/users/123

# Query (GET with query param)
curl "http://localhost:3000/api/users?limit=10&offset=0"

# Mutation (POST)
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice", "email": "alice@example.com"}'

# Protected endpoint
curl http://localhost:3000/api/users/123 \
  -H "Authorization: Bearer <token>"
```

**Example — integration test with `supertest`:**

```ts
import request from "supertest";
import { app } from "../src/server";

describe("REST API", () => {
  it("GET /api/users/:id returns a user", async () => {
    const res = await request(app)
      .get("/api/users/123")
      .expect(200);

    expect(res.body).toMatchObject({
      id: "123",
      name: expect.any(String),
    });
  });

  it("POST /api/users creates a user", async () => {
    const res = await request(app)
      .post("/api/users")
      .send({ name: "Alice", email: "alice@example.com" })
      .expect(200);

    expect(res.body.id).toBeDefined();
  });

  it("returns 404 for unknown user", async () => {
    const res = await request(app)
      .get("/api/users/nonexistent")
      .expect(404);

    expect(res.body.code).toBe("NOT_FOUND");
  });
});
```

---

### Common Integration Mistakes

#### Path Parameter Name Mismatch

```ts
// ❌ path uses {userId} but input field is named id
.meta({ openapi: { method: "GET", path: "/users/{userId}" } })
.input(z.object({ id: z.string() }))

// ✅ names match
.meta({ openapi: { method: "GET", path: "/users/{id}" } })
.input(z.object({ id: z.string() }))
```

#### Boolean Query Params Not Coerced

```ts
// ❌ z.boolean() cannot parse the string "true" from a query string
.input(z.object({ active: z.boolean().optional() }))

// ✅ coerce handles string → boolean conversion
.input(z.object({ active: z.coerce.boolean().optional() }))
```

#### Missing `.output()` Causing Empty Response Schema

```ts
// ❌ spec shows empty response schema
.query(({ input }) => getUserById(input.id))

// ✅ output schema drives spec response definition
.output(UserSchema)
.query(({ input }) => getUserById(input.id))
```

#### Forgetting to Export All HTTP Methods in Next.js

```ts
// ❌ PUT and PATCH requests return 405
export { handler as GET, handler as POST };

// ✅ all methods exported
export { handler as GET, handler as POST, handler as PUT, handler as PATCH, handler as DELETE };
```

---

**Conclusion:**
`trpc-openapi` integrates at two levels — a spec generator that converts Zod schemas and procedure metadata into an OpenAPI 3.0 document, and a runtime middleware that translates REST HTTP requests into tRPC procedure calls. The same router serves both the tRPC typed client and the REST surface with no duplication. Critical integration details — path parameter naming alignment, Zod coercion for query string values, `.output()` schema declarations, and HTTP method exports in Next.js — determine whether the integration works correctly at runtime and produces an accurate spec. All behavioral claims should be verified against the current `trpc-openapi` version, as this is a community-maintained package and its API surface continues to evolve.