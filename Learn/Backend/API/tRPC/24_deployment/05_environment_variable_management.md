## Environment Variable Management

Environment variables in tRPC applications bridge configuration between deployment environments and runtime behavior. Because tRPC sits across both server and client boundaries, managing env vars requires deliberate separation — leaking server secrets to the client bundle is a real risk without explicit discipline.

---

### Why Environment Variables Require Special Care in tRPC

tRPC routers run on the server, but tRPC clients run in the browser. Bundlers like Next.js, Vite, and webpack can inadvertently inline server-side variables into the client bundle if imports are not carefully scoped.

**Key Points:**
- Server-side env vars (e.g., `DATABASE_URL`, `JWT_SECRET`) must never be imported in client-facing modules
- Client-safe vars are typically prefixed (e.g., `NEXT_PUBLIC_`, `VITE_`) and exposed intentionally
- tRPC itself does not manage env vars — the responsibility lies with your runtime and validation layer

---

### Validating Environment Variables at Startup

Raw `process.env` access is untyped and silently returns `undefined` for missing variables. The recommended pattern is to validate and parse env vars at startup using a schema library, so misconfiguration fails loudly at boot rather than silently at runtime.

**Example — using Zod for env validation (`src/env.ts`):**

```ts
import { z } from "zod";

const serverSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  NODE_ENV: z.enum(["development", "production", "test"]),
});

const clientSchema = z.object({
  NEXT_PUBLIC_API_URL: z.string().url(),
});

// Validate server vars — only safe to import in server modules
export const serverEnv = serverSchema.parse({
  DATABASE_URL: process.env.DATABASE_URL,
  JWT_SECRET: process.env.JWT_SECRET,
  NODE_ENV: process.env.NODE_ENV,
});

// Validate client vars — safe to import anywhere
export const clientEnv = clientSchema.parse({
  NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
});
```

**Key Points:**
- Parsing at module load time causes the process to throw on startup if a required variable is absent or malformed
- Separating `serverEnv` and `clientEnv` into distinct exports enforces the boundary at the import level
- Zod's `.url()`, `.min()`, `.email()`, and `.enum()` provide semantic validation beyond mere presence checks

---

### Wiring Server Env into tRPC Context

The validated `serverEnv` object should be consumed inside the tRPC context factory, making configuration available to all procedures without scattering `process.env` calls across the router.

**Example — injecting env into context (`src/server/context.ts`):**

```ts
import { serverEnv } from "../env";
import { db } from "./db";

export async function createContext() {
  return {
    db,
    env: serverEnv,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Example — accessing env in a procedure:**

```ts
export const appRouter = router({
  secretInfo: protectedProcedure.query(({ ctx }) => {
    // ctx.env is fully typed and validated
    return { nodeEnv: ctx.env.NODE_ENV };
  }),
});
```

**Key Points:**
- Centralizing env access in context prevents ad-hoc `process.env` calls in individual procedures
- The context type carries full TypeScript inference from the Zod schema, so `ctx.env.DATABASE_URL` is typed as `string`

---

### Preventing Server Env Leakage to the Client

In Next.js specifically, any module imported by a client component can have its contents bundled into the browser. A common mistake is importing a shared utility that internally imports `serverEnv`.

**Example — unsafe pattern:**

```ts
// utils/format.ts — imported by both server and client
import { serverEnv } from "../env"; // ❌ leaks to client bundle

export function formatLabel() {
  return serverEnv.NODE_ENV === "production" ? "Prod" : "Dev";
}
```

**Example — safe pattern:**

```ts
// utils/format.ts — no server env dependency
export function formatLabel(nodeEnv: string) {
  return nodeEnv === "production" ? "Prod" : "Dev";
}

// Call site (server only)
formatLabel(ctx.env.NODE_ENV);
```

**Key Points:**
- Pass env values as function arguments rather than importing server env inside shared utilities
- Tools like `@t3-oss/env-nextjs` enforce this boundary at build time by analyzing import graphs [Unverified — behavior depends on version and bundler configuration]

---

### Using t3-env for Structured Env Management

The `@t3-oss/env-nextjs` (and `@t3-oss/env-core`) packages were built specifically to address tRPC + Next.js env patterns. They wrap Zod validation with explicit server/client partitioning and emit build-time errors when the boundary is violated.

**Example — `src/env.ts` with t3-env:**

```ts
import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    JWT_SECRET: z.string().min(32),
    NODE_ENV: z.enum(["development", "production", "test"]),
  },
  client: {
    NEXT_PUBLIC_API_URL: z.string().url(),
  },
  runtimeEnv: {
    DATABASE_URL: process.env.DATABASE_URL,
    JWT_SECRET: process.env.JWT_SECRET,
    NODE_ENV: process.env.NODE_ENV,
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
  },
});
```

**Key Points:**
- `createEnv` validates both server and client schemas at startup
- Accessing `env.server.JWT_SECRET` inside a client component will throw a build or runtime error, depending on bundler support [Inference — exact behavior depends on Next.js version and tree-shaking]
- The `runtimeEnv` map is explicit to avoid bundler magic and maintain transparency

---

### Environment-Specific Configuration Patterns

Different environments (development, staging, production) typically require different values for the same variables. Common strategies include:

#### `.env` File Layering

Most runtimes support cascading `.env` files resolved in priority order:

```
.env                  # shared defaults, committed
.env.local            # local overrides, gitignored
.env.development      # dev-specific, committed
.env.production       # prod-specific, committed
.env.production.local # prod secrets, gitignored
```

**Key Points:**
- Never commit secrets to any `.env` file that is not gitignored
- `.env.example` (committed, values redacted) documents required variables for new developers

#### Runtime Injection in Production

In containerized or serverless deployments, env vars are typically injected at the platform level rather than from files:

```bash
# Docker
docker run -e DATABASE_URL=postgres://... -e JWT_SECRET=... myapp

# Kubernetes — via Secret and ConfigMap references in pod spec
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: app-secrets
        key: database-url
```

**Key Points:**
- `.env` files are generally not present in production containers — the platform owns the env [Inference — varies by deployment strategy]
- The Zod validation layer catches missing injected vars immediately at cold start

---

### Type-Safe Access Pattern Summary

<svg viewBox="0 0 720 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace, sans-serif" font-size="13">
  <!-- Background -->
  <rect width="720" height="400" fill="#0f1117" rx="12"/>

  <!-- Title -->
  <text x="360" y="34" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Env Var Flow in a tRPC Application</text>

  <!-- Platform / .env box -->
  <rect x="30" y="60" width="160" height="60" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="110" y="85" text-anchor="middle" fill="#94a3b8" font-size="12">Platform / .env Files</text>
  <text x="110" y="105" text-anchor="middle" fill="#64748b" font-size="11">raw process.env</text>

  <!-- Arrow down -->
  <line x1="110" y1="120" x2="110" y2="155" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Zod validation box -->
  <rect x="30" y="155" width="160" height="60" rx="8" fill="#1e3a5f" stroke="#2563eb" stroke-width="1.5"/>
  <text x="110" y="180" text-anchor="middle" fill="#93c5fd" font-size="12">Zod / t3-env</text>
  <text x="110" y="198" text-anchor="middle" fill="#60a5fa" font-size="11">startup validation</text>

  <!-- Arrow to serverEnv -->
  <line x1="190" y1="185" x2="270" y2="145" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
  <!-- Arrow to clientEnv -->
  <line x1="190" y1="185" x2="270" y2="255" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- serverEnv box -->
  <rect x="270" y="110" width="150" height="60" rx="8" fill="#1a2e1a" stroke="#16a34a" stroke-width="1.5"/>
  <text x="345" y="135" text-anchor="middle" fill="#86efac" font-size="12">serverEnv</text>
  <text x="345" y="153" text-anchor="middle" fill="#4ade80" font-size="11">DATABASE_URL, JWT_SECRET</text>

  <!-- clientEnv box -->
  <rect x="270" y="220" width="150" height="60" rx="8" fill="#2a1a1a" stroke="#dc2626" stroke-width="1.5"/>
  <text x="345" y="245" text-anchor="middle" fill="#fca5a5" font-size="12">clientEnv</text>
  <text x="345" y="263" text-anchor="middle" fill="#f87171" font-size="11">NEXT_PUBLIC_API_URL</text>

  <!-- Arrow serverEnv to context -->
  <line x1="420" y1="140" x2="500" y2="140" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- tRPC Context box -->
  <rect x="500" y="110" width="180" height="60" rx="8" fill="#1e1a2e" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="590" y="135" text-anchor="middle" fill="#c4b5fd" font-size="12">tRPC Context</text>
  <text x="590" y="153" text-anchor="middle" fill="#a78bfa" font-size="11">ctx.env (typed)</text>

  <!-- Arrow context to procedures -->
  <line x1="590" y1="170" x2="590" y2="220" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Procedures box -->
  <rect x="500" y="220" width="180" height="60" rx="8" fill="#1e2a1e" stroke="#059669" stroke-width="1.5"/>
  <text x="590" y="245" text-anchor="middle" fill="#6ee7b7" font-size="12">Procedures</text>
  <text x="590" y="263" text-anchor="middle" fill="#34d399" font-size="11">ctx.env.DATABASE_URL</text>

  <!-- clientEnv to tRPC client (arrow down right) -->
  <line x1="345" y1="280" x2="345" y2="330" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
  <rect x="260" y="330" width="170" height="50" rx="8" fill="#2a1a1a" stroke="#b45309" stroke-width="1.5"/>
  <text x="345" y="352" text-anchor="middle" fill="#fcd34d" font-size="12">tRPC Client / Browser</text>
  <text x="345" y="370" text-anchor="middle" fill="#fbbf24" font-size="11">safe vars only</text>

  <!-- X mark on serverEnv to client (blocked) -->
  <line x1="420" y1="250" x2="470" y2="320" stroke="#ef4444" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="458" y="305" fill="#ef4444" font-size="16" font-weight="bold">✕</text>

  <!-- Arrow marker def -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
  </defs>
</svg>

---

### Common Mistakes and Mitigations

#### Accessing `process.env` Directly in Procedures

```ts
// ❌ Unvalidated, untyped, silently undefined if missing
const dbUrl = process.env.DATABASE_URL;

// ✅ Validated at startup, typed, fails loudly
const dbUrl = ctx.env.DATABASE_URL;
```

#### Forgetting to Add New Variables to the Schema

When a new env var is added, it must be added to both the Zod schema and the `.env.example` file. Omitting either causes silent failures or missing documentation for teammates.

#### Using `NEXT_PUBLIC_` Prefix for Secrets

Variables prefixed `NEXT_PUBLIC_` are statically inlined into the client bundle by Next.js at build time. Assigning a secret to a `NEXT_PUBLIC_` var exposes it irreversibly in the shipped JavaScript. [Key Point — the inlining happens at build, not runtime, so rotating the secret requires a full redeploy]

---

### `.env.example` Template Pattern

```bash
# .env.example — commit this file, omit real values

# Server-only
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
JWT_SECRET=<min-32-char-random-string>
NODE_ENV=development

# Client-safe
NEXT_PUBLIC_API_URL=http://localhost:3000/api/trpc
```

**Key Points:**
- `.env.example` serves as living documentation and onboarding aid
- CI pipelines can validate that all keys in `.env.example` are present in the injected environment before running tests [Inference — requires custom scripting or tooling]

---

**Conclusion:**
Robust environment variable management in tRPC applications requires three layers working together: schema-based validation at startup (Zod or t3-env), explicit separation of server and client env objects, and centralized injection through tRPC context. These layers collectively reduce the risk of misconfiguration reaching production and prevent accidental exposure of server secrets to the client bundle. Behavior of bundler-level enforcement varies by framework version and configuration and should be verified in your specific deployment setup.