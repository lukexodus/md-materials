## Environment Flags

Environment flags in the context of `fastify-cli` refer to environment variables that configure runtime behavior as an alternative to — or in combination with — CLI flags. Beyond `fastify-cli`'s own variable set, a production-grade Fastify application requires a coherent strategy for consuming environment configuration inside the application itself: validating it, typing it, and making it available to plugins and routes.

---

### `fastify-cli` Native Environment Variables

`fastify-cli` reads the following variables from `process.env` at startup. They map directly to their CLI flag equivalents and are applied before the application plugin is loaded.

| Variable | CLI Equivalent | Type | Default |
|---|---|---|---|
| `FASTIFY_PORT` | `--port` | Number | `3000` |
| `FASTIFY_ADDRESS` | `--address` | String | `127.0.0.1` |
| `FASTIFY_SOCKET` | `--socket` | String | — |
| `FASTIFY_LOG_LEVEL` | `--log-level` | String | `info` |
| `FASTIFY_PRETTY_LOGS` | `--pretty-logs` | Boolean | `false` |
| `FASTIFY_WATCH` | `--watch` | Boolean | `false` |
| `FASTIFY_PREFIX` | `--prefix` | String | — |
| `FASTIFY_PLUGIN_TIMEOUT` | `--plugin-timeout` | Number | `10000` |
| `FASTIFY_BODY_LIMIT` | `--body-limit` | Number | — |
| `FASTIFY_OPTIONS` | `--options` | JSON string | — |

> [Unverified] The complete and authoritative list of supported variables may differ across `fastify-cli` versions. Always verify against `fastify start --help` and the changelog for your installed version.

---

### Precedence Between Flags and Variables

When both a CLI flag and its corresponding environment variable are set, one takes precedence over the other. 

> [Unverified] The exact precedence order (CLI flag vs. environment variable) is not consistently documented across `fastify-cli` versions. Avoid setting both simultaneously; rely on one source of configuration per deployment context to prevent ambiguity.

---

### Loading Environment Variables from `.env`

`fastify-cli` does not natively load `.env` files. Use `dotenv` via the `--require` flag:

```bash
fastify start app.js --require dotenv/config
```

Or in `package.json` scripts:

```json
{
  "scripts": {
    "dev": "fastify start app.js -w -P --require dotenv/config",
    "start": "fastify start app.js --require dotenv/config"
  }
}
```

**`.env` file:**

```env
FASTIFY_PORT=4000
FASTIFY_ADDRESS=0.0.0.0
FASTIFY_LOG_LEVEL=debug
FASTIFY_PRETTY_LOGS=true
DATABASE_URL=postgres://user:pass@localhost:5432/mydb
API_SECRET=supersecret
```

`dotenv` loads the file before the app initializes, so all variables are available in `process.env` when the CLI reads them and when your plugin code executes.

---

### Consuming Environment Variables Inside the Application

Raw access to `process.env` is possible anywhere in your application, but it is untyped and unvalidated by default:

```js
// ⚠ Works but provides no validation or type safety
const dbUrl = process.env.DATABASE_URL
const port = Number(process.env.PORT)
```

A structured approach using `@fastify/env` is preferred.

---

### `@fastify/env` — Validated Environment Configuration

`@fastify/env` validates `process.env` against a JSON Schema (or `fluent-json-schema`) at startup and decorates the Fastify instance with a typed config object.

```bash
npm install @fastify/env
```

#### Basic Usage

```js
// plugins/env.js
'use strict'

const fp = require('fastify-plugin')
const fastifyEnv = require('@fastify/env')

const schema = {
  type: 'object',
  required: ['DATABASE_URL', 'API_SECRET'],
  properties: {
    NODE_ENV: {
      type: 'string',
      default: 'development'
    },
    PORT: {
      type: 'integer',
      default: 3000
    },
    DATABASE_URL: {
      type: 'string'
    },
    API_SECRET: {
      type: 'string',
      minLength: 16
    },
    LOG_LEVEL: {
      type: 'string',
      default: 'info'
    }
  }
}

module.exports = fp(async function (fastify, opts) {
  await fastify.register(fastifyEnv, {
    schema,
    dotenv: true,        // Loads .env automatically (wraps dotenv internally)
    confKey: 'config'    // Decorator name on fastify instance (default: 'config')
  })
})
```

> **Note:** Setting `dotenv: true` in `@fastify/env` options loads the `.env` file internally. If you are also using `--require dotenv/config`, the file may be loaded twice — this is generally harmless but redundant.

#### Accessing Config in Routes and Plugins

Because `env.js` uses `fastify-plugin` (`fp`), the `fastify.config` decorator is available throughout the application:

```js
// routes/users.js
'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/db-status', async (req, reply) => {
    // fastify.config is typed and validated
    const dbUrl = fastify.config.DATABASE_URL
    return { connected: !!dbUrl }
  })
}
```

#### Validation Failure at Startup

If a required variable is missing or fails schema validation, `@fastify/env` throws during plugin initialization — before the server accepts requests:

```
Error: env must have required property 'DATABASE_URL'
```

This is a deliberate fail-fast behavior. [Inference] It prevents the application from starting in a misconfigured state, though it does not guarantee correct runtime behavior of the variables' consumers.

---

### Schema Patterns for Common Variable Types

#### Integers with Defaults

```js
PORT: {
  type: 'integer',
  default: 3000
}
```

`@fastify/env` coerces the string value from `process.env` to the declared type automatically.

#### Booleans

```js
ENABLE_CACHE: {
  type: 'boolean',
  default: false
}
```

String values `"true"` and `"false"` are coerced to booleans. [Inference] Coercion behavior depends on the underlying `env-schema` library; verify edge cases (e.g., `"1"`, `"yes"`) for your version.

#### Enumerations

```js
NODE_ENV: {
  type: 'string',
  enum: ['development', 'production', 'test'],
  default: 'development'
}
```

#### Optional Variables

Omit the field from `required` and provide a `default`:

```js
properties: {
  REDIS_URL: {
    type: 'string',
    default: ''
  }
}
// Do NOT include REDIS_URL in required[]
```

#### Arrays from Comma-Separated Strings

[Inference] `@fastify/env` does not natively split comma-separated strings into arrays. A workaround is to consume the variable as a string and split manually:

```js
// Read as string in schema
ALLOWED_ORIGINS: {
  type: 'string',
  default: 'http://localhost:3000'
}

// Split in plugin
const origins = fastify.config.ALLOWED_ORIGINS.split(',')
```

---

### `@fastify/env` with `fluent-json-schema`

For a programmatic schema definition style:

```bash
npm install fluent-json-schema
```

```js
const S = require('fluent-json-schema')

const schema = S.object()
  .prop('NODE_ENV', S.string().enum(['development', 'production', 'test']).default('development'))
  .prop('PORT', S.integer().default(3000))
  .prop('DATABASE_URL', S.string().required())
  .prop('API_SECRET', S.string().minLength(16).required())
```

Pass directly to `@fastify/env`:

```js
fastify.register(fastifyEnv, { schema: schema.valueOf(), dotenv: true })
```

---

### TypeScript: Typed Config Decorator

When using TypeScript, augment the Fastify type interface to get full type inference on `fastify.config`:

```ts
// types/fastify.d.ts
import 'fastify'

declare module 'fastify' {
  interface FastifyInstance {
    config: {
      NODE_ENV: string
      PORT: number
      DATABASE_URL: string
      API_SECRET: string
      LOG_LEVEL: string
    }
  }
}
```

```ts
// plugins/env.ts
import fp from 'fastify-plugin'
import fastifyEnv from '@fastify/env'
import { FastifyPluginAsync } from 'fastify'

const schema = {
  type: 'object',
  required: ['DATABASE_URL', 'API_SECRET'],
  properties: {
    NODE_ENV: { type: 'string', default: 'development' },
    PORT: { type: 'integer', default: 3000 },
    DATABASE_URL: { type: 'string' },
    API_SECRET: { type: 'string', minLength: 16 },
    LOG_LEVEL: { type: 'string', default: 'info' }
  }
}

const envPlugin: FastifyPluginAsync = async (fastify) => {
  await fastify.register(fastifyEnv, { schema, dotenv: true })
}

export default fp(envPlugin)
```

---

### Plugin Load Order and Config Availability

`@fastify/env` must be registered before any plugin that consumes `fastify.config`. In a generated project, place the env plugin first in the `plugins/` directory or control load order explicitly:

```
plugins/
├── env.js       ← loads first (alphabetically, or by explicit ordering)
├── db.js        ← can safely access fastify.config.DATABASE_URL
└── support.js
```

> [Inference] `@fastify/autoload` loads files alphabetically by default. Prefixing filenames (e.g., `00-env.js`, `01-db.js`) is a common pattern for enforcing load order, though explicit registration in `app.js` is more deterministic.

**Explicit ordering in `app.js`:**

```js
module.exports = async function (fastify, opts) {
  // Register env first, explicitly
  await fastify.register(require('./plugins/env'))
  await fastify.register(require('./plugins/db'))

  // Then autoload routes
  fastify.register(require('@fastify/autoload'), {
    dir: path.join(__dirname, 'routes')
  })
}
```

---

### Environment-Specific Configuration Patterns

#### NODE_ENV-Based Behavior

```js
module.exports = fp(async function (fastify, opts) {
  const isProd = fastify.config.NODE_ENV === 'production'

  if (!isProd) {
    await fastify.register(require('@fastify/swagger'), { ... })
    await fastify.register(require('@fastify/swagger-ui'), { ... })
  }
})
```

#### Separate `.env` Files per Environment

```
.env                  ← base defaults (committed, no secrets)
.env.development      ← development overrides
.env.production       ← production overrides (never committed)
.env.test             ← test-specific values
```

Load the appropriate file by composing `dotenv` calls:

```js
// config/env-loader.js
require('dotenv').config({ path: `.env.${process.env.NODE_ENV}` })
require('dotenv').config() // fallback to .env
```

Require before app load:

```bash
fastify start app.js --require ./config/env-loader.js
```

> [Inference] Variable precedence when multiple `.env` files are loaded depends on `dotenv`'s behavior — by default, already-set variables are not overridden. Load more specific files first.

---

### Security Considerations

- Never commit `.env` files containing secrets to version control. Add `.env*` to `.gitignore` (excluding `.env.example`).
- In production, inject secrets via the deployment environment (container env vars, secrets manager) rather than `.env` files.
- `@fastify/env` validation does not sanitize values — it only checks type and constraints. [Inference] Downstream consumers of config values are responsible for treating them appropriately (e.g., not logging secrets).
- Use `minLength` constraints on secret fields to catch accidentally empty or placeholder values at startup.

```env
# .env.example — committed, contains no real values
DATABASE_URL=postgres://user:pass@host:5432/db
API_SECRET=changeme_min_16_chars
NODE_ENV=development
```

---

**Related Topics:**
- `@fastify/env` schema options and `env-schema` internals
- `fluent-json-schema` for programmatic schema construction
- `@fastify/autoload` file ordering and `ignorePattern`
- Fastify plugin load order and encapsulation
- Secret management in production (AWS Secrets Manager, Vault, Doppler)
- TypeScript declaration merging for Fastify instance types
- Twelve-Factor App methodology and environment-based configuration