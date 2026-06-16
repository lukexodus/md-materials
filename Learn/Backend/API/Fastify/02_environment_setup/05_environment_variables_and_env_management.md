## Environment Variables and .env Management

Fastify does not include built-in environment variable management. Handling environment variables in a Fastify project requires explicit configuration, typically through a combination of Node.js `process.env`, `.env` files, and optionally a validation layer. The patterns described here reflect community convention and official plugin recommendations.

---

### Why Environment Variables Matter in Fastify Projects

Environment variables externalize configuration — database connection strings, ports, secrets, feature flags — from application code. This keeps sensitive values out of source control and allows the same codebase to run in different environments (development, staging, production) without code changes.

[Inference] Fastify's plugin-based architecture makes it straightforward to centralize environment variable access in a single plugin and expose validated config values as decorators. Actual behavior depends on implementation.

---

### Native Access via `process.env`

Node.js exposes environment variables through `process.env`. No additional library is required to read them.

**Example**:

```js
const fastify = require('fastify')({ logger: true })

const PORT = process.env.PORT || 3000
const HOST = process.env.HOST || '0.0.0.0'

fastify.listen({ port: PORT, host: HOST })
```

**Key Points**

- All `process.env` values are strings; numeric values must be explicitly cast (`Number(process.env.PORT)`)
- Missing variables return `undefined` unless a fallback is provided
- There is no type validation or schema enforcement at this level

---

### .env Files

A `.env` file stores key-value pairs that are loaded into `process.env` at startup. This file is kept out of version control via `.gitignore`.

**Example** — `.env`:

```
PORT=3000
HOST=0.0.0.0
DATABASE_URL=postgres://user:password@localhost:5432/mydb
LOG_LEVEL=info
NODE_ENV=development
```

**Key Points**

- `.env` files are not loaded automatically by Node.js; a loader library is required
- A `.env.example` file (committed to version control) documents required variables without exposing real values
- Multiple `.env` files for different environments (`.env.development`, `.env.production`) are supported by some loaders

---

### Loading .env Files with `dotenv`

`dotenv` is the most widely used library for loading `.env` files into `process.env`.

**Installation**:

```bash
npm install dotenv
```

**Usage** — load as early as possible, before any other imports that depend on `process.env`:

```js
require('dotenv').config()

const fastify = require('fastify')({ logger: true })
```

Or using ES Modules:

```js
import 'dotenv/config'
import Fastify from 'fastify'
```

**Key Points**

- `dotenv` does not override existing environment variables by default; variables already set in the shell take precedence
- Call `.config()` before importing application modules that read `process.env` at module load time
- `dotenv` reads `.env` from `process.cwd()` by default; the path can be overridden via `{ path: '...' }`

---

### Schema Validation with `@fastify/env`

`@fastify/env` is an official Fastify plugin that loads and validates environment variables against a JSON Schema, then decorates the Fastify instance with the validated config object.

**Installation**:

```bash
npm install @fastify/env
```

**Example**:

```js
const fastify = require('fastify')({ logger: true })
const fastifyEnv = require('@fastify/env')

const schema = {
  type: 'object',
  required: ['PORT', 'DATABASE_URL'],
  properties: {
    PORT: { type: 'integer', default: 3000 },
    DATABASE_URL: { type: 'string' },
    LOG_LEVEL: { type: 'string', default: 'info' },
    NODE_ENV: {
      type: 'string',
      enum: ['development', 'staging', 'production'],
      default: 'development'
    }
  }
}

const options = {
  schema,
  dotenv: true  // enables built-in dotenv loading; no separate dotenv call needed
}

await fastify.register(fastifyEnv, options)

// Validated config is now available as fastify.config
console.log(fastify.config.PORT)
console.log(fastify.config.DATABASE_URL)
```

**Key Points**

- Registration throws an error at startup if required variables are missing or fail type coercion — this surfaces misconfiguration early
- The `dotenv: true` option delegates `.env` loading to an internal dotenv call; a separate `require('dotenv').config()` is not needed when using this option
- `fastify.config` is a decorated property available throughout the application after registration
- Type coercion is applied: a `type: 'integer'` property will be cast from string automatically [Inference — coercion behavior depends on the underlying `env-schema` and `ajv` versions in use]

---

### Using `fastify.config` Across Plugins

Because `@fastify/env` registers `config` as a Fastify decorator, it is accessible in any plugin registered after it within the same encapsulation scope.

**Example**:

```js
// plugins/db.js
const fp = require('fastify-plugin')

module.exports = fp(async function (fastify) {
  // fastify.config is available because @fastify/env was registered first
  const db = await connectToDatabase(fastify.config.DATABASE_URL)
  fastify.decorate('db', db)
})
```

**Key Points**

- Plugin registration order matters; `@fastify/env` must be registered before any plugin that reads `fastify.config`
- Wrapping with `fastify-plugin` is necessary to share `fastify.config` across encapsulation boundaries

---

### Alternative: `env-schema` Standalone

`env-schema` is the underlying library used by `@fastify/env`. It can be used independently of Fastify for projects that prefer to validate environment variables outside the plugin system.

**Installation**:

```bash
npm install env-schema
```

**Example**:

```js
const envSchema = require('env-schema')

const config = envSchema({
  schema: {
    type: 'object',
    required: ['PORT'],
    properties: {
      PORT: { type: 'integer', default: 3000 },
      DATABASE_URL: { type: 'string' }
    }
  },
  dotenv: true
})

module.exports = config
```

This returns a plain object that can be imported anywhere without Fastify dependency.

---

### .gitignore and .env.example Convention

**`.gitignore`** — exclude `.env` and any environment-specific variants:

```
.env
.env.local
.env.*.local
```

**`.env.example`** — committed to version control; documents all expected variables with placeholder or safe default values:

```
PORT=3000
HOST=0.0.0.0
DATABASE_URL=postgres://user:password@localhost:5432/mydb
LOG_LEVEL=info
NODE_ENV=development
```

**Key Points**

- `.env.example` serves as documentation for new developers and CI/CD pipelines
- Actual secret values never appear in `.env.example`
- Some teams use `.env.example` as the basis for automated environment setup scripts

---

### Environment Variable Naming Conventions

| Convention | Example | Notes |
|---|---|---|
| Uppercase with underscores | `DATABASE_URL` | Standard; follows POSIX convention |
| Prefixed by service | `DB_HOST`, `DB_PORT` | Groups related variables |
| `NODE_ENV` | `development`, `production` | Widely used; not enforced by Node.js itself |
| Feature flags | `FEATURE_NEW_CHECKOUT=true` | Boolean values are strings; must be parsed explicitly |

[Inference] There is no enforced naming convention in Node.js or Fastify. The patterns above are community norms and may vary across projects and organizations.

---

### Handling `NODE_ENV`

`NODE_ENV` is a widely recognized convention for indicating the runtime environment. It is not set automatically by Node.js.

**Example** — reading `NODE_ENV` safely:

```js
const isProduction = process.env.NODE_ENV === 'production'

const fastify = require('fastify')({
  logger: isProduction ? true : { transport: { target: 'pino-pretty' } }
})
```

**Key Points**

- `NODE_ENV` must be set explicitly in the shell, CI pipeline, or `.env` file
- It is a string; comparisons must be exact (`=== 'production'`, not loose equality)
- Some libraries change behavior based on `NODE_ENV` internally [Unverified — depends on the specific library]

---

### Comparison of Approaches

| Approach | Validation | .env Loading | Fastify Integration | Complexity |
|---|---|---|---|---|
| `process.env` directly | None | Manual | None | Minimal |
| `dotenv` | None | Automatic | None | Low |
| `env-schema` | JSON Schema | Optional | None | Medium |
| `@fastify/env` | JSON Schema | Optional | Decorator | Medium |

---

**Conclusion**

The recommended approach for most Fastify projects is `@fastify/env`, which combines `.env` loading, JSON Schema validation, and Fastify decorator integration in a single plugin registration. For simpler projects, `dotenv` alone is sufficient. In all cases, `.env` files should be excluded from version control and documented via a committed `.env.example` file. [Inference] Early validation of environment variables at startup is likely to reduce runtime errors caused by missing or malformed configuration, though exact behavior depends on schema definition and plugin version.