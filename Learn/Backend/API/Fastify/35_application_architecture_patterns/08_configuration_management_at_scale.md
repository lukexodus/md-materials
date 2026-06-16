## Configuration Management at Scale in Fastify

Configuration management at scale addresses how Fastify applications load, validate, type, and distribute configuration across environments, services, and deployment targets without becoming fragile or insecure.

---

### What Configuration Management Encompasses

At small scale, `process.env.PORT` scattered across files is workable. At scale, this breaks down because:

- Environment variables are untyped and unvalidated at the language level
- Secrets intermingle with non-sensitive config
- Different environments (dev, staging, prod) require different values with no enforcement
- Distributed services share config with no single source of truth
- Misconfiguration surfaces at runtime, not at startup

A mature configuration layer addresses all of these concerns before the first route is registered.

---

### Approach 1: `@fastify/env` with JSON Schema Validation

[`@fastify/env`](https://github.com/fastify/fastify-env) is the official Fastify plugin for environment variable loading and validation. It validates `process.env` against a JSON Schema at startup and decorates the Fastify instance with a typed config object.

```bash
npm install @fastify/env
```

```ts
// src/plugins/env.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import fastifyEnv from '@fastify/env';

const schema = {
  type: 'object',
  required: [
    'NODE_ENV',
    'PORT',
    'DATABASE_URL',
    'JWT_SECRET',
  ],
  properties: {
    NODE_ENV: {
      type: 'string',
      enum: ['development', 'test', 'staging', 'production'],
    },
    PORT: {
      type: 'integer',
      default: 3000,
    },
    HOST: {
      type: 'string',
      default: '0.0.0.0',
    },
    DATABASE_URL: {
      type: 'string',
    },
    DATABASE_POOL_MIN: {
      type: 'integer',
      default: 2,
    },
    DATABASE_POOL_MAX: {
      type: 'integer',
      default: 10,
    },
    JWT_SECRET: {
      type: 'string',
      minLength: 32,
    },
    JWT_EXPIRY: {
      type: 'string',
      default: '1h',
    },
    SMTP_URL: {
      type: 'string',
    },
    LOG_LEVEL: {
      type: 'string',
      enum: ['trace', 'debug', 'info', 'warn', 'error', 'fatal'],
      default: 'info',
    },
  },
} as const;

const envPlugin: FastifyPluginAsync = async (fastify) => {
  await fastify.register(fastifyEnv, {
    schema,
    dotenv: true, // loads .env in development; requires dotenv installed
    confKey: 'config', // fastify.config
  });
};

export default fp(envPlugin, { name: 'env' });
```

#### TypeScript Augmentation

```ts
// src/@types/fastify/index.d.ts

declare module 'fastify' {
  interface FastifyInstance {
    config: {
      NODE_ENV: 'development' | 'test' | 'staging' | 'production';
      PORT: number;
      HOST: string;
      DATABASE_URL: string;
      DATABASE_POOL_MIN: number;
      DATABASE_POOL_MAX: number;
      JWT_SECRET: string;
      JWT_EXPIRY: string;
      SMTP_URL: string;
      LOG_LEVEL: string;
    };
  }
}
```

**Key Points:**
- Validation runs before any other plugin if `env` is the first registration
- Missing required variables cause an immediate startup failure with a descriptive error
- `dotenv: true` loads `.env` files automatically in local development; in production, environment variables are set by the runtime or orchestrator
- `confKey` can be changed from the default `config` to any name

---

### Approach 2: `env-schema` for Standalone Validation

[`env-schema`](https://github.com/fastify/env-schema) validates environment variables independently of Fastify, producing a plain typed object. This is useful when configuration must be available before the Fastify instance is constructed — for example, to pass database config into a pool that is itself passed into Fastify.

```bash
npm install env-schema
```

```ts
// src/config.ts

import envSchema from 'env-schema';
import { Static, Type } from '@sinclair/typebox';

const schema = Type.Object({
  NODE_ENV: Type.Union([
    Type.Literal('development'),
    Type.Literal('test'),
    Type.Literal('staging'),
    Type.Literal('production'),
  ]),
  PORT: Type.Integer({ default: 3000 }),
  DATABASE_URL: Type.String(),
  DATABASE_POOL_MIN: Type.Integer({ default: 2 }),
  DATABASE_POOL_MAX: Type.Integer({ default: 10 }),
  JWT_SECRET: Type.String({ minLength: 32 }),
  LOG_LEVEL: Type.String({ default: 'info' }),
});

export type AppConfig = Static<typeof schema>;

export const config: AppConfig = envSchema({
  schema,
  dotenv: true,
});
```

```ts
// src/app.ts

import { config } from './config';
import { Pool } from 'pg';

// config is available before Fastify is instantiated
const pool = new Pool({
  connectionString: config.DATABASE_URL,
  min: config.DATABASE_POOL_MIN,
  max: config.DATABASE_POOL_MAX,
});

const fastify = Fastify({ logger: { level: config.LOG_LEVEL } });
```

[Inference] `env-schema` uses `ajv` under the hood for validation. The exact set of supported JSON Schema keywords depends on the `ajv` version bundled with `env-schema` at the time of installation. Verify supported keywords against the installed version.

---

### Approach 3: Zod-Based Configuration

[`zod`](https://github.com/colinhacks/zod) is a TypeScript-first schema library. Using it for configuration provides richer error messages and a more ergonomic API than JSON Schema for complex transformations.

```bash
npm install zod
```

```ts
// src/config.ts

import { z } from 'zod';
import 'dotenv/config';

const configSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'staging', 'production']),
  PORT: z.coerce.number().int().positive().default(3000),
  HOST: z.string().default('0.0.0.0'),
  DATABASE_URL: z.string().url(),
  DATABASE_POOL_MIN: z.coerce.number().int().default(2),
  DATABASE_POOL_MAX: z.coerce.number().int().default(10),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRY: z.string().default('1h'),
  LOG_LEVEL: z
    .enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal'])
    .default('info'),
  SMTP_URL: z.string().url().optional(),
});

const parsed = configSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('Invalid configuration:');
  console.error(parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const config = parsed.data;
export type AppConfig = typeof config;
```

**Key Points:**
- `z.coerce.number()` handles the fact that all environment variables are strings — it parses `"3000"` to `3000`
- `safeParse` collects all errors before failing, rather than throwing on the first one
- `process.exit(1)` at startup is intentional — misconfiguration is not recoverable
- Zod is not natively supported by `@fastify/env`, so this approach bypasses the plugin and loads config as a plain module

---

### Grouping Configuration by Domain

Flat config objects become unmanageable past a certain size. Grouping by domain reduces cognitive load.

```ts
// src/config.ts (grouped)

import { z } from 'zod';

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'staging', 'production']),
  PORT: z.coerce.number().default(3000),
  HOST: z.string().default('0.0.0.0'),

  DATABASE_URL: z.string(),
  DATABASE_POOL_MIN: z.coerce.number().default(2),
  DATABASE_POOL_MAX: z.coerce.number().default(10),
  DATABASE_SSL: z.coerce.boolean().default(false),

  JWT_SECRET: z.string().min(32),
  JWT_EXPIRY: z.string().default('1h'),
  JWT_REFRESH_EXPIRY: z.string().default('7d'),

  SMTP_URL: z.string().optional(),
  SMTP_FROM: z.string().email().optional(),

  REDIS_URL: z.string().optional(),
  REDIS_TTL_SECONDS: z.coerce.number().default(3600),

  LOG_LEVEL: z
    .enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal'])
    .default('info'),
  LOG_PRETTY: z.coerce.boolean().default(false),
});

const raw = schema.parse(process.env);

export const config = {
  env: raw.NODE_ENV,
  server: {
    port: raw.PORT,
    host: raw.HOST,
  },
  database: {
    url: raw.DATABASE_URL,
    pool: { min: raw.DATABASE_POOL_MIN, max: raw.DATABASE_POOL_MAX },
    ssl: raw.DATABASE_SSL,
  },
  auth: {
    jwtSecret: raw.JWT_SECRET,
    jwtExpiry: raw.JWT_EXPIRY,
    jwtRefreshExpiry: raw.JWT_REFRESH_EXPIRY,
  },
  mail: {
    smtpUrl: raw.SMTP_URL,
    from: raw.SMTP_FROM,
  },
  redis: {
    url: raw.REDIS_URL,
    ttl: raw.REDIS_TTL_SECONDS,
  },
  logging: {
    level: raw.LOG_LEVEL,
    pretty: raw.LOG_PRETTY,
  },
} as const;

export type AppConfig = typeof config;
```

Usage becomes self-documenting:

```ts
const pool = new Pool({
  connectionString: config.database.url,
  min: config.database.pool.min,
  max: config.database.pool.max,
  ssl: config.database.ssl,
});
```

---

### Environment Files Per Environment

```
.env                    # local development defaults (never committed)
.env.example            # committed; documents all required variables
.env.test               # test environment overrides
.env.staging            # staging (if file-based; otherwise use runtime env)
```

`.env.example` is the contract:

```ini
# .env.example

NODE_ENV=development
PORT=3000
HOST=0.0.0.0

DATABASE_URL=postgresql://user:password@localhost:5432/appdb
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10
DATABASE_SSL=false

JWT_SECRET=<minimum-32-character-secret-here>
JWT_EXPIRY=1h
JWT_REFRESH_EXPIRY=7d

SMTP_URL=smtp://localhost:1025
SMTP_FROM=noreply@example.com

REDIS_URL=redis://localhost:6379
REDIS_TTL_SECONDS=3600

LOG_LEVEL=info
LOG_PRETTY=true
```

`.env` is in `.gitignore`. `.env.example` is committed and kept current with every new config variable added.

---

### Secrets Handling

Environment variables are not suitable for secrets in all deployment contexts. [Inference] The following are common patterns used in production environments; specific security properties depend on the platform, configuration, and operational practices of each provider.

#### Pattern: Secrets Injected at Runtime by Orchestrator

In Kubernetes, Docker Swarm, or AWS ECS, secrets are mounted as environment variables or files by the orchestrator. The application reads them identically to other environment variables.

```ts
// No change to application code — the secret arrives as an env var
JWT_SECRET=<injected-by-orchestrator>
```

#### Pattern: Secrets Manager Integration

For environments where secrets must be fetched at startup from a secrets manager (AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager), load them before configuration validation runs.

```ts
// src/secrets.ts

import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

export const loadSecrets = async (): Promise<void> => {
  if (process.env.NODE_ENV !== 'production') return;

  const client = new SecretsManagerClient({ region: process.env.AWS_REGION });

  const command = new GetSecretValueCommand({
    SecretId: process.env.SECRET_ARN,
  });

  const response = await client.send(command);
  const secrets = JSON.parse(response.SecretString ?? '{}');

  // Merge secrets into process.env before config validation runs
  Object.assign(process.env, secrets);
};
```

```ts
// src/main.ts

import { loadSecrets } from './secrets';
import { config } from './config'; // validated after secrets are loaded

const start = async () => {
  await loadSecrets();          // populate process.env from secrets manager
  const { config } = await import('./config'); // now parse and validate
  const { buildApp } = await import('./app');
  const app = await buildApp(config);
  await app.listen({ port: config.server.port, host: config.server.host });
};

start();
```

**Key Points:**
- Secrets are merged into `process.env` before config validation runs
- Using dynamic `import()` for `config` after `loadSecrets` ensures the validated config sees the populated secrets
- [Inference] This approach assumes the process has IAM or equivalent permissions to access the secret. Misconfigured permissions will surface as a startup error

---

### Configuration in Plugin Registration

Config is consumed when constructing infrastructure and passed into Fastify via decorators or directly:

```ts
// src/app.ts

import Fastify from 'fastify';
import { config } from './config';
import { Pool } from 'pg';
import fp from 'fastify-plugin';

export const buildApp = async () => {
  const fastify = Fastify({
    logger: {
      level: config.logging.level,
      transport: config.logging.pretty
        ? { target: 'pino-pretty' }
        : undefined,
    },
  });

  const pool = new Pool({
    connectionString: config.database.url,
    min: config.database.pool.min,
    max: config.database.pool.max,
  });

  fastify.decorate('config', config);
  fastify.decorate('pg', { pool });

  fastify.addHook('onClose', async () => {
    await pool.end();
  });

  await fastify.register(import('./plugins/repositories.plugin'));
  await fastify.register(import('./plugins/services.plugin'));
  await fastify.register(import('./routes'), { prefix: '/api' });

  return fastify;
};
```

---

### Testing with Configuration

Tests require isolated, predictable configuration. Two patterns are common.

#### Pattern: Test Config Module

```ts
// src/config.test.ts (or tests/helpers/config.ts)

import { AppConfig } from '../src/config';

export const testConfig: AppConfig = {
  env: 'test',
  server: { port: 0, host: '127.0.0.1' }, // port 0 = OS assigns free port
  database: {
    url: process.env.TEST_DATABASE_URL ?? 'postgresql://localhost/appdb_test',
    pool: { min: 1, max: 2 },
    ssl: false,
  },
  auth: {
    jwtSecret: 'test-secret-minimum-32-characters-long',
    jwtExpiry: '1h',
    jwtRefreshExpiry: '7d',
  },
  mail: { smtpUrl: undefined, from: undefined },
  redis: { url: undefined, ttl: 60 },
  logging: { level: 'silent', pretty: false },
};
```

```ts
// tests/helpers/build-test-app.ts

import { buildApp } from '../../src/app';
import { testConfig } from './config';

export const buildTestApp = () => buildApp(testConfig);
```

#### Pattern: Environment Variable Override in Tests

```ts
// vitest.config.ts

export default {
  test: {
    env: {
      NODE_ENV: 'test',
      DATABASE_URL: 'postgresql://localhost/appdb_test',
      JWT_SECRET: 'test-secret-minimum-32-characters-long',
      LOG_LEVEL: 'silent',
    },
  },
};
```

---

### Architecture Diagram

<svg viewBox="0 0 740 500" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4a90d9"/>
    </marker>
    <marker id="arrG" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4caf77"/>
    </marker>
    <marker id="arrO" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f0a020"/>
    </marker>
    <marker id="arrR" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#e05050"/>
    </marker>
  </defs>

  <!-- Sources -->
  <text x="370" y="22" text-anchor="middle" fill="#888" font-size="11">Configuration Sources</text>
  <rect x="30" y="30" width="130" height="50" rx="6" fill="#1a1a2a" stroke="#5050a0" stroke-width="1.2"/>
  <text x="95" y="52" text-anchor="middle" fill="#a0a0e0">.env file</text>
  <text x="95" y="70" text-anchor="middle" fill="#6060a0" font-size="10">local dev only</text>

  <rect x="190" y="30" width="130" height="50" rx="6" fill="#1a1a2a" stroke="#5050a0" stroke-width="1.2"/>
  <text x="255" y="52" text-anchor="middle" fill="#a0a0e0">process.env</text>
  <text x="255" y="70" text-anchor="middle" fill="#6060a0" font-size="10">runtime / CI / CD</text>

  <rect x="350" y="30" width="130" height="50" rx="6" fill="#1a1a2a" stroke="#5050a0" stroke-width="1.2"/>
  <text x="415" y="52" text-anchor="middle" fill="#a0a0e0">Secrets Manager</text>
  <text x="415" y="70" text-anchor="middle" fill="#6060a0" font-size="10">Vault / AWS / GCP</text>

  <rect x="510" y="30" width="130" height="50" rx="6" fill="#1a1a2a" stroke="#5050a0" stroke-width="1.2"/>
  <text x="575" y="52" text-anchor="middle" fill="#a0a0e0">Config Server</text>
  <text x="575" y="70" text-anchor="middle" fill="#6060a0" font-size="10">etcd / Consul</text>

  <!-- Arrows to validation -->
  <line x1="95" y1="80" x2="200" y2="145" stroke="#5050a0" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="255" y1="80" x2="255" y2="145" stroke="#5050a0" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="415" y1="80" x2="340" y2="145" stroke="#5050a0" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="575" y1="80" x2="390" y2="145" stroke="#5050a0" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- Validation -->
  <rect x="120" y="145" width="400" height="70" rx="8" fill="#0d1f33" stroke="#4a90d9" stroke-width="1.5"/>
  <text x="320" y="168" text-anchor="middle" fill="#6aa0cc" font-size="11">Validation Layer</text>
  <text x="200" y="193" text-anchor="middle" fill="#c8e0ff" font-size="11">@fastify/env (JSON Schema)</text>
  <line x1="290" y1="185" x2="310" y2="185" stroke="#4a90d9" stroke-width="1"/>
  <text x="400" y="193" text-anchor="middle" fill="#c8e0ff" font-size="11">Zod / env-schema</text>

  <!-- Fail path -->
  <rect x="560" y="155" width="150" height="50" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1.2"/>
  <text x="635" y="178" text-anchor="middle" fill="#f08080">Startup Failure</text>
  <text x="635" y="196" text-anchor="middle" fill="#c06060" font-size="10">process.exit(1)</text>
  <line x1="520" y1="180" x2="560" y2="180" stroke="#e05050" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#arrR)"/>
  <text x="540" y="172" text-anchor="middle" fill="#e05050" font-size="9">invalid</text>

  <!-- Typed config -->
  <line x1="320" y1="215" x2="320" y2="260" stroke="#4caf77" stroke-width="1.5" marker-end="url(#arrG)"/>

  <rect x="120" y="260" width="400" height="60" rx="8" fill="#0d2213" stroke="#4caf77" stroke-width="1.5"/>
  <text x="320" y="283" text-anchor="middle" fill="#b8f0cc">Typed Config Object</text>
  <text x="320" y="302" text-anchor="middle" fill="#80c8a0" font-size="10">config.database.url  ·  config.auth.jwtSecret  ·  config.server.port</text>

  <!-- Distribution -->
  <line x1="200" y1="320" x2="120" y2="375" stroke="#4a90d9" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="320" y1="320" x2="320" y2="375" stroke="#4a90d9" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="440" y1="320" x2="540" y2="375" stroke="#4a90d9" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- Consumers -->
  <rect x="30" y="375" width="160" height="50" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="110" y="398" text-anchor="middle" fill="#c8e0ff">Infrastructure</text>
  <text x="110" y="415" text-anchor="middle" fill="#80b0e0" font-size="10">Pool, Logger, Redis</text>

  <rect x="230" y="375" width="160" height="50" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="310" y="398" text-anchor="middle" fill="#c8e0ff">Plugins</text>
  <text x="310" y="415" text-anchor="middle" fill="#80b0e0" font-size="10">fastify.decorate('config')</text>

  <rect x="430" y="375" width="160" height="50" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="510" y="398" text-anchor="middle" fill="#c8e0ff">Services</text>
  <text x="510" y="415" text-anchor="middle" fill="#80b0e0" font-size="10">constructor injection</text>

  <rect x="620" y="375" width="100" height="50" rx="6" fill="#1a3a28" stroke="#4caf77" stroke-width="1.2"/>
  <text x="670" y="398" text-anchor="middle" fill="#b8f0cc">Tests</text>
  <text x="670" y="415" text-anchor="middle" fill="#80c8a0" font-size="10">testConfig</text>
</svg>

---

### Configuration Drift Prevention

At scale, configuration drift — where running services diverge from documented or expected config — becomes a reliability risk.

**Key Points:**
- `.env.example` is the canonical documentation of all variables; CI checks that it stays current
- Config validation at startup catches drift between what is documented and what is deployed
- Structured config objects (grouped by domain) make auditing easier than flat key lists
- [Inference] Tools like `dotenv-linter` or custom CI scripts can compare `.env.example` against production environment variable lists, though the exact coverage depends on implementation

---

### Feature Flags via Configuration

Simple feature flags can be expressed as boolean environment variables without a dedicated flag service.

```ts
const schema = z.object({
  // ...existing fields
  FEATURE_NEW_CHECKOUT: z.coerce.boolean().default(false),
  FEATURE_RATE_LIMITING: z.coerce.boolean().default(true),
});
```

```ts
// In a plugin or route
if (config.features.newCheckout) {
  await fastify.register(import('./plugins/new-checkout.plugin'));
}
```

[Inference] Environment-variable-based feature flags require a process restart to change state. For runtime toggling without restarts, a dedicated flag service (LaunchDarkly, Unleash, Flipt) is a better fit. Behavior of either approach depends heavily on infrastructure and deployment configuration.

---

### Common Mistakes

#### Accessing `process.env` Outside the Config Module

```ts
// Bad — bypasses validation and typing
const secret = process.env.JWT_SECRET;
```

```ts
// Correct — always read from the validated config object
import { config } from '../config';
const secret = config.auth.jwtSecret;
```

#### Committing `.env` Files

`.env` must be in `.gitignore`. Only `.env.example` is committed. Committing secrets — even in private repositories — is a security risk, and secrets may persist in git history after removal.

#### Validating Config Inside Route Handlers

Config validation runs once at startup. Route handlers must not re-validate or re-parse environment variables on each request.

#### Using `any` for Config Types

Annotating config as `any` defeats the purpose of validation. The TypeScript type should be derived directly from the schema — either via `z.infer<typeof schema>` (Zod) or a manual interface aligned with the JSON Schema.

---

**Related Topics:**
- Secret rotation without downtime — reloading secrets without restarting the process
- Multi-environment deployment strategies — per-environment config in Kubernetes ConfigMaps and Secrets
- `pino` logger configuration in depth — transport, redaction of sensitive fields
- Feature flag services (Unleash, Flipt) integrated with Fastify plugins
- Config validation in CI — linting `.env.example` and checking for undocumented variables
- `@fastify/env` with `ajv` custom keywords for advanced validation rules
- Twelve-factor app configuration principles applied to Fastify