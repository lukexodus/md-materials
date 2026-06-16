## Environment-Specific Configuration

Managing configuration across development, staging, and production environments is a foundational concern in any Fastify deployment. This module covers how to load, validate, type-safe, and inject environment-specific values — from local `.env` files through to Kubernetes-native config delivery.

---

### Why Configuration Management Matters

Hardcoding values creates brittle, insecure, environment-coupled applications. A well-structured config system allows the same Docker image to run in any environment with only external inputs changed — a core principle of the Twelve-Factor App methodology.

**Key Points:**
- Secrets (database URLs, API keys) must never be committed to source control
- Configuration should be validated at startup so the app fails fast with a clear error rather than crashing at runtime on a missing value
- The same image artifact should be promotable from staging to production without rebuild [Inference — assumes no config is baked into the image layer]
- Fastify's plugin system and `decorate` API make injected config accessible throughout the app cleanly

---

### Environment Variables as the Foundation

Environment variables are the universal config primitive across all deployment targets — local Docker, Kubernetes, AWS Lambda, and bare metal alike.

**Example — minimal reading:**

```js
// server.js
const port = process.env.PORT ?? 3000
const host = process.env.HOST ?? '0.0.0.0'
const logLevel = process.env.LOG_LEVEL ?? 'info'
```

**Key Points:**
- `process.env` values are always strings — numeric and boolean coercion must be explicit
- Defaulting with `??` (nullish coalescing) is safer than `||`, which swallows intentional `0` or `''` values
- Raw `process.env` access scattered across the codebase makes auditing and refactoring difficult — centralizing config is strongly preferred

---

### Centralizing Config with a Dedicated Module

Rather than reading `process.env` inline, collect all config into a single validated module loaded once at startup.

**Example — `config/index.js`:**

```js
// config/index.js
export function loadConfig() {
  return {
    server: {
      port: Number(process.env.PORT ?? 3000),
      host: process.env.HOST ?? '0.0.0.0',
      logLevel: process.env.LOG_LEVEL ?? 'info',
    },
    db: {
      url: requireEnv('DATABASE_URL'),
      poolMin: Number(process.env.DB_POOL_MIN ?? 2),
      poolMax: Number(process.env.DB_POOL_MAX ?? 10),
    },
    auth: {
      jwtSecret: requireEnv('JWT_SECRET'),
      jwtExpiry: process.env.JWT_EXPIRY ?? '1h',
    },
    app: {
      env: process.env.NODE_ENV ?? 'development',
      isProd: process.env.NODE_ENV === 'production',
    },
  }
}

function requireEnv(key) {
  const value = process.env[key]
  if (!value) throw new Error(`Missing required environment variable: ${key}`)
  return value
}
```

**Example — `server.js`:**

```js
import Fastify from 'fastify'
import { loadConfig } from './config/index.js'

const config = loadConfig() // throws immediately if required vars are absent

const app = Fastify({ logger: { level: config.server.logLevel } })

await app.listen({ port: config.server.port, host: config.server.host })
```

**Key Points:**
- `requireEnv` throws synchronously at startup — the process exits before binding any port, making misconfiguration immediately visible
- Grouping by domain (`server`, `db`, `auth`) prevents a flat, unmanageable object
- This module is easily unit-testable by temporarily setting `process.env` values in test setup

---

### Schema Validation with `@fastify/env`

`@fastify/env` integrates with Fastify's plugin system to validate environment variables against a JSON Schema (or `fluent-json-schema`) at startup, decorating the app instance with a typed config object.

**Installation:**

```bash
npm install @fastify/env
```

**Example:**

```js
import Fastify from 'fastify'
import fastifyEnv from '@fastify/env'

const schema = {
  type: 'object',
  required: ['PORT', 'DATABASE_URL', 'JWT_SECRET'],
  properties: {
    PORT: { type: 'integer', default: 3000 },
    HOST: { type: 'string', default: '0.0.0.0' },
    LOG_LEVEL: {
      type: 'string',
      enum: ['trace', 'debug', 'info', 'warn', 'error', 'fatal'],
      default: 'info',
    },
    NODE_ENV: {
      type: 'string',
      enum: ['development', 'staging', 'production', 'test'],
      default: 'development',
    },
    DATABASE_URL: { type: 'string' },
    JWT_SECRET: { type: 'string', minLength: 32 },
    JWT_EXPIRY: { type: 'string', default: '1h' },
    DB_POOL_MAX: { type: 'integer', default: 10 },
  },
  additionalProperties: false,
}

const app = Fastify()

await app.register(fastifyEnv, {
  schema,
  dotenv: true, // loads .env file in non-production environments
  confKey: 'config', // app.config
})

// app.config is now available and fully validated
console.log(app.config.PORT) // number, not string
```

**Key Points:**
- JSON Schema `type: 'integer'` causes `@fastify/env` to coerce the string `"3000"` to the number `3000` automatically
- `enum` constraints reject unexpected values at startup rather than silently using them
- `minLength: 32` on `JWT_SECRET` enforces a minimum security standard at the config layer
- `additionalProperties: false` rejects unknown keys, preventing accidental reliance on undeclared variables [Inference — behavior may vary with schema version and ajv configuration]
- `confKey` sets the decoration name on the Fastify instance; defaults to `'config'`

---

### `.env` Files for Local Development

`.env` files provide a local override mechanism. They should never be committed to version control.

**Example — `.env`:**

```dotenv
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=debug
NODE_ENV=development
DATABASE_URL=postgres://user:pass@localhost:5432/mydb_dev
JWT_SECRET=dev-only-secret-at-least-32-characters-long
JWT_EXPIRY=7d
DB_POOL_MAX=5
```

**Example — `.env.example` (committed to source control):**

```dotenv
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=info
NODE_ENV=development
DATABASE_URL=          # Required: postgres connection string
JWT_SECRET=            # Required: min 32 chars
JWT_EXPIRY=1h
DB_POOL_MAX=10
```

**`.gitignore` entry:**

```
.env
.env.local
.env.*.local
```

**Key Points:**
- `.env.example` documents all required and optional variables without exposing real values — commit this, never `.env`
- `@fastify/env`'s `dotenv: true` option calls `dotenv` under the hood; alternatively use the `dotenv` package directly with `dotenv/config` imported before app initialization
- In production, `.env` files should not exist — values come from the platform (Kubernetes Secrets, AWS Parameter Store, etc.)
- Multiple `.env` file variants (`.env.test`, `.env.staging`) can coexist locally; load the correct one via a `NODE_ENV`-aware loader [Inference]

---

### Env Validation with Zod (Alternative Pattern)

For teams already using Zod (common in tRPC stacks or TypeScript-heavy codebases), Zod provides a more ergonomic validation and inference experience.

**Example:**

```js
import { z } from 'zod'
import 'dotenv/config'

const envSchema = z.object({
  PORT: z.coerce.number().int().positive().default(3000),
  HOST: z.string().default('0.0.0.0'),
  LOG_LEVEL: z.enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal']).default('info'),
  NODE_ENV: z.enum(['development', 'staging', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRY: z.string().default('1h'),
  DB_POOL_MAX: z.coerce.number().int().positive().default(10),
})

const parsed = envSchema.safeParse(process.env)

if (!parsed.success) {
  console.error('Invalid environment configuration:')
  console.error(parsed.error.flatten().fieldErrors)
  process.exit(1)
}

export const env = parsed.data
```

**Key Points:**
- `z.coerce.number()` handles the string-to-number conversion that `process.env` always produces
- `safeParse` returns a result object rather than throwing, allowing structured error reporting before exit
- `parsed.error.flatten().fieldErrors` produces a readable field-by-field error map
- This pattern does not use `@fastify/env` but is fully compatible — pass `env` into a Fastify plugin that decorates `app.config`

---

### Injecting Config into the Fastify Instance

Once validated, config should be accessible across all plugins and routes via `app.config` without importing the config module everywhere.

**Example — config plugin:**

```js
// plugins/config.js
import fp from 'fastify-plugin'
import fastifyEnv from '@fastify/env'

const schema = { /* ... as above ... */ }

export default fp(async function configPlugin(app) {
  await app.register(fastifyEnv, { schema, dotenv: true })
  // app.config is now decorated and available to all plugins
  // registered after this one
})
```

**Example — consuming config in a route plugin:**

```js
// routes/users.js
export default async function userRoutes(app) {
  app.get('/users/token-info', async (req, reply) => {
    return {
      expiry: app.config.JWT_EXPIRY,
      env: app.config.NODE_ENV,
    }
  })
}
```

**Key Points:**
- Wrapping with `fastify-plugin` (via `fp`) prevents encapsulation — the decoration is visible to the entire app instance
- Without `fp`, decorations registered inside a plugin are scoped to that plugin's subtree only
- Route handlers access `app.config` through closure over the `app` reference passed to the route plugin — no imports required

---

### Per-Environment Behavior

Some application behavior should differ by environment beyond simple variable values.

**Example — environment-aware app setup:**

```js
import Fastify from 'fastify'
import { env } from './config/env.js'

const app = Fastify({
  logger: env.NODE_ENV === 'production'
    ? { level: 'info' }
    : { level: 'debug', transport: { target: 'pino-pretty' } },
  disableRequestLogging: env.NODE_ENV === 'test',
})

// Register Swagger only outside production
if (env.NODE_ENV !== 'production') {
  await app.register(import('@fastify/swagger'), { /* ... */ })
  await app.register(import('@fastify/swagger-ui'), { /* ... */ })
}

// Register rate limiting only in production
if (env.NODE_ENV === 'production') {
  await app.register(import('@fastify/rate-limit'), {
    max: 100,
    timeWindow: '1 minute',
  })
}
```

**Key Points:**
- `pino-pretty` transport provides readable local logs; raw JSON is preferable in production for log aggregators (Datadog, Loki, CloudWatch)
- Conditional plugin registration keeps dev tooling out of production builds
- Avoid deeply nested `if (isProd)` branches — prefer config-driven feature flags or separate plugin files per environment for larger apps [Inference]

---

### Config in Kubernetes: The Full Chain

In Kubernetes, config values flow from cluster-level resources into the container's `process.env`.

```
ConfigMap / Secret
      ↓
  envFrom / env[].valueFrom in Deployment spec
      ↓
  Container process.env
      ↓
  @fastify/env or Zod validation at startup
      ↓
  app.config decoration
      ↓
  Routes and plugins
```

**Example — Deployment referencing both sources:**

```yaml
containers:
  - name: fastify-app
    image: your-registry/fastify-app:1.2.0
    envFrom:
      - configMapRef:
          name: fastify-config      # Non-sensitive values
      - secretRef:
          name: fastify-secrets     # Sensitive values
    env:
      - name: NODE_ENV
        value: production           # Inline override takes precedence
```

**Key Points:**
- `envFrom` bulk-injects all keys from a ConfigMap or Secret; `env[].valueFrom.configMapKeyRef` allows selective injection of individual keys
- Inline `env` entries override `envFrom` entries for the same key [Inference — Kubernetes merge order may vary; test explicitly]
- The Fastify app's validation layer catches any missing or malformed values before the server binds, preventing a silently misconfigured Pod from joining the Service

---

### External Secret Management

For production environments, plain Kubernetes Secrets (which are only base64-encoded, not encrypted at rest by default) are often insufficient.

**Common patterns:**

| Tool | Mechanism | Notes |
|---|---|---|
| AWS Secrets Manager + External Secrets Operator | Syncs AWS secrets into Kubernetes Secrets automatically | Requires ESO installation |
| HashiCorp Vault + Vault Agent Injector | Injects secrets as files or env vars into Pods | Complex setup; strong audit trail |
| Sealed Secrets (Bitnami) | Encrypts Secrets for safe Git storage | Simpler than Vault; cluster-scoped keys |
| Doppler | Cloud secret manager with Kubernetes sync | SaaS; low operational overhead [Unverified — evaluate for your compliance requirements] |

**Key Points:**
- Regardless of the secret delivery mechanism, the Fastify app's config layer remains unchanged — values arrive in `process.env` as normal
- External secret managers add rotation capability; the Fastify app should handle graceful restart or dynamic config reload when secrets rotate [Inference — zero-downtime secret rotation in a stateless app typically means rolling restart]

---

### Testing with Environment Config

Config validation must not interfere with test environments.

**Example — `vitest` / `jest` setup:**

```js
// test/setup.js
process.env.PORT = '3000'
process.env.HOST = '0.0.0.0'
process.env.NODE_ENV = 'test'
process.env.DATABASE_URL = 'postgres://user:pass@localhost:5432/mydb_test'
process.env.JWT_SECRET = 'test-secret-value-at-least-32-chars-long'
process.env.LOG_LEVEL = 'silent'
```

**Example — `vitest.config.js`:**

```js
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    setupFiles: ['./test/setup.js'],
    env: {
      NODE_ENV: 'test',
    },
  },
})
```

**Key Points:**
- Set all required env vars before the Fastify app initializes; `@fastify/env` runs during plugin registration, so vars must exist before `app.ready()` or `app.listen()` is called
- `LOG_LEVEL: 'silent'` suppresses log output during test runs without disabling the logger entirely
- A dedicated `.env.test` file loaded via `dotenv` in the test setup file is an alternative to inline `process.env` assignments

---

### Config Lifecycle Diagram

<svg viewBox="0 0 720 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="720" height="400" fill="#0f1117" rx="12"/>
  <text x="360" y="32" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Config Lifecycle: Source → Validation → Injection</text>

  <!-- Sources row -->
  <text x="80" y="65" text-anchor="middle" fill="#64748b" font-size="11">Sources</text>

  <rect x="20" y="75" width="110" height="44" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="75" y="93" text-anchor="middle" fill="#38bdf8">.env file</text>
  <text x="75" y="110" text-anchor="middle" fill="#94a3b8" font-size="10">local dev</text>

  <rect x="145" y="75" width="110" height="44" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="200" y="93" text-anchor="middle" fill="#38bdf8">ConfigMap</text>
  <text x="200" y="110" text-anchor="middle" fill="#94a3b8" font-size="10">non-sensitive</text>

  <rect x="270" y="75" width="110" height="44" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="325" y="93" text-anchor="middle" fill="#38bdf8">Secret</text>
  <text x="325" y="110" text-anchor="middle" fill="#94a3b8" font-size="10">sensitive values</text>

  <rect x="395" y="75" width="130" height="44" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="460" y="93" text-anchor="middle" fill="#38bdf8">Ext. Secret Mgr</text>
  <text x="460" y="110" text-anchor="middle" fill="#94a3b8" font-size="10">Vault / ESO</text>

  <rect x="540" y="75" width="150" height="44" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="615" y="93" text-anchor="middle" fill="#38bdf8">CI/CD Injection</text>
  <text x="615" y="110" text-anchor="middle" fill="#94a3b8" font-size="10">GitHub Actions etc.</text>

  <!-- Arrows down to process.env -->
  <line x1="75" y1="119" x2="75" y2="155" stroke="#475569" stroke-width="1.3" marker-end="url(#arr)"/>
  <line x1="200" y1="119" x2="200" y2="155" stroke="#475569" stroke-width="1.3" marker-end="url(#arr)"/>
  <line x1="325" y1="119" x2="325" y2="155" stroke="#475569" stroke-width="1.3" marker-end="url(#arr)"/>
  <line x1="460" y1="119" x2="460" y2="155" stroke="#475569" stroke-width="1.3" marker-end="url(#arr)"/>
  <line x1="615" y1="119" x2="615" y2="155" stroke="#475569" stroke-width="1.3" marker-end="url(#arr)"/>

  <!-- process.env box -->
  <rect x="20" y="155" width="680" height="44" rx="7" fill="#14291f" stroke="#4ade80" stroke-width="1.5"/>
  <text x="360" y="175" text-anchor="middle" fill="#4ade80" font-weight="bold">process.env</text>
  <text x="360" y="191" text-anchor="middle" fill="#94a3b8" font-size="10">all sources merged into the Node.js process environment</text>

  <!-- Arrow down to validation -->
  <line x1="360" y1="199" x2="360" y2="235" stroke="#475569" stroke-width="1.3" marker-end="url(#arr)"/>

  <!-- Validation box -->
  <rect x="160" y="235" width="400" height="44" rx="7" fill="#1e1a2e" stroke="#c084fc" stroke-width="1.5"/>
  <text x="360" y="255" text-anchor="middle" fill="#c084fc" font-weight="bold">@fastify/env or Zod validation</text>
  <text x="360" y="271" text-anchor="middle" fill="#94a3b8" font-size="10">type coercion · required checks · enum constraints · fail fast</text>

  <!-- Arrow down to app.config -->
  <line x1="360" y1="279" x2="360" y2="315" stroke="#475569" stroke-width="1.3" marker-end="url(#arr)"/>

  <!-- app.config box -->
  <rect x="200" y="315" width="320" height="44" rx="7" fill="#1e2d40" stroke="#818cf8" stroke-width="1.5"/>
  <text x="360" y="335" text-anchor="middle" fill="#818cf8" font-weight="bold">app.config decoration</text>
  <text x="360" y="351" text-anchor="middle" fill="#94a3b8" font-size="10">typed · validated · accessible across all plugins and routes</text>

  <!-- Arrow marker -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
  </defs>
</svg>

---

### Summary of Approaches

| Approach | Best For | Type Safety | Validation |
|---|---|---|---|
| Raw `process.env` | Prototypes | None | None |
| Centralized `loadConfig()` | Small apps, no extra deps | Manual coercion | Manual `requireEnv` |
| `@fastify/env` + JSON Schema | Fastify-native integration | Coercion via schema | Full JSON Schema |
| Zod schema | TypeScript / tRPC stacks | Full inference | Rich error output |

---

**Related Topics:**
- Feature flags and runtime config toggling without restart
- Dynamic config reload with Kubernetes ConfigMap watches
- Secret rotation and zero-downtime credential refresh
- Multi-tenant config isolation per request context
- Config auditing and change tracking in production
- `pino` transport configuration per environment
- TypeScript `satisfies` and `as const` for config type narrowing