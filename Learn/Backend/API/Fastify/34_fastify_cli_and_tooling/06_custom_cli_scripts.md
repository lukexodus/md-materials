## Custom CLI Scripts

Beyond the built-in `fastify start`, `fastify generate`, and diagnostic commands, real-world Fastify applications frequently require custom CLI scripts — database migrations, seed scripts, scheduled jobs, administrative tasks, and health checks — that need access to the fully initialized Fastify application context, including its plugins, decorators, and connections.

---

### The Core Problem

Custom scripts often need access to application infrastructure — database connections, configuration, logging — that is managed by Fastify plugins. Simply requiring `app.js` and calling plugin code directly does not work because plugins are registered asynchronously and the Fastify instance is not ready until `fastify.ready()` resolves.

```js
// ❌ Incorrect — plugins have not loaded, fastify.db is undefined
const app = require('fastify')()
app.register(require('./plugins/db'))
console.log(app.db) // undefined
```

The correct approach is to await the fully initialized Fastify instance before accessing decorators.

---

### `fastify-cli/helper` — Building the App Programmatically

`fastify-cli` exposes a `helper` module that builds a fully initialized Fastify instance in the same way `fastify start` does. This is the same helper used in generated test files.

```js
const { build } = require('fastify-cli/helper')
const path = require('path')

async function main () {
  const app = await build([path.resolve(__dirname, '../app.js')], {
    // Fastify instance options
    logger: true
  })

  // app is fully initialized — all plugins loaded, decorators available
  await app.db.query('SELECT 1')

  await app.close()
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
```

**Key Points:**
- The first argument to `build` is an array: `[appFilePath, ...cliArgs]`. Additional strings after the path are interpreted as CLI arguments.
- The second argument is an options object passed to the Fastify instance.
- `await build(...)` resolves only after all plugins have loaded (`fastify.ready()` is called internally).
- Always call `await app.close()` to trigger `onClose` hooks and release connections.

---

### Standalone Script Without `fastify-cli/helper`

For scripts that do not need the full CLI loading mechanism, build the app directly:

```js
// scripts/run-task.js
'use strict'

const Fastify = require('fastify')
const app = require('../app')

async function main () {
  const fastify = Fastify({ logger: true })
  fastify.register(app)

  await fastify.ready()

  // All plugins are initialized
  await fastify.db.migrate()

  await fastify.close()
}

main().catch((err) => {
  fastify.log.error(err)
  process.exit(1)
})
```

This pattern gives full control over the Fastify instance options and avoids the `fastify-cli/helper` dependency.

---

### Script Structure Best Practices

A reusable structure for any custom script:

```js
// scripts/seed.js
'use strict'

const Fastify = require('fastify')
const appPlugin = require('../app')

async function buildApp () {
  const fastify = Fastify({
    logger: {
      level: process.env.LOG_LEVEL || 'info'
    }
  })
  fastify.register(appPlugin)
  await fastify.ready()
  return fastify
}

async function seed (fastify) {
  fastify.log.info('Starting seed...')

  await fastify.db.query(`
    INSERT INTO users (name, email)
    VALUES ('Admin', 'admin@example.com')
    ON CONFLICT DO NOTHING
  `)

  fastify.log.info('Seed complete.')
}

async function main () {
  const fastify = await buildApp()

  try {
    await seed(fastify)
  } finally {
    await fastify.close()  // Always close, even on error
  }
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
```

**Key Points:**
- Wrapping the task in `try/finally` with `app.close()` in the `finally` block helps ensure connections are released even when the task throws.
- `process.exit(1)` on unhandled errors signals failure to the calling process (CI pipelines, process managers).
- Separating `buildApp` from task logic makes the script testable in isolation.

---

### Registering Scripts as npm Scripts

Define custom scripts in `package.json` for consistent invocation:

```json
{
  "scripts": {
    "start": "fastify start app.js",
    "dev": "fastify start app.js --watch --pretty-logs",
    "migrate": "node scripts/migrate.js",
    "migrate:rollback": "node scripts/migrate.js --rollback",
    "seed": "node scripts/seed.js",
    "seed:test": "NODE_ENV=test node scripts/seed.js",
    "admin:create-user": "node scripts/create-user.js"
  }
}
```

Invoke with:

```bash
npm run migrate
npm run seed
NODE_ENV=production npm run migrate
```

---

### Accepting Arguments in Scripts

Use `process.argv` directly or a lightweight argument parser:

#### Raw `process.argv`

```js
// scripts/create-user.js
const args = process.argv.slice(2)
const email = args[0]
const role = args[1] || 'user'

if (!email) {
  console.error('Usage: node scripts/create-user.js <email> [role]')
  process.exit(1)
}
```

Run with:

```bash
node scripts/create-user.js admin@example.com admin
```

#### Using `parseArgs` (Node.js 18.3+)

```js
const { parseArgs } = require('node:util')

const { values } = parseArgs({
  options: {
    email: { type: 'string' },
    role: { type: 'string', default: 'user' },
    dryRun: { type: 'boolean', default: false }
  }
})

console.log(values.email)   // --email admin@example.com
console.log(values.role)    // --role admin
console.log(values.dryRun)  // --dry-run
```

Run with:

```bash
node scripts/create-user.js --email admin@example.com --role admin --dry-run
```

> [Inference] `parseArgs` is available from Node.js 18.3 without additional packages. For older Node.js versions, a third-party parser such as `minimist` or `yargs` is required.

---

### Database Migration Script Pattern

A common real-world use case — running migrations using the Fastify app context:

```js
// scripts/migrate.js
'use strict'

const Fastify = require('fastify')
const appPlugin = require('../app')
const { parseArgs } = require('node:util')

const { values } = parseArgs({
  options: {
    rollback: { type: 'boolean', default: false },
    steps: { type: 'string', default: '1' }
  }
})

async function main () {
  const fastify = Fastify({ logger: { level: 'info' } })
  fastify.register(appPlugin)
  await fastify.ready()

  try {
    if (values.rollback) {
      fastify.log.info(`Rolling back ${values.steps} migration(s)...`)
      await fastify.db.migrate.rollback({}, parseInt(values.steps))
    } else {
      fastify.log.info('Running pending migrations...')
      await fastify.db.migrate.latest()
    }
    fastify.log.info('Done.')
  } finally {
    await fastify.close()
  }
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
```

---

### Script That Does Not Need the Full App

Not every script requires a fully initialized Fastify instance. Scripts that only need environment configuration or operate independently of application plugins can be simpler:

```js
// scripts/check-env.js
'use strict'

require('dotenv').config()

const required = ['DATABASE_URL', 'API_SECRET', 'NODE_ENV']
const missing = required.filter((key) => !process.env[key])

if (missing.length > 0) {
  console.error('Missing required environment variables:', missing.join(', '))
  process.exit(1)
}

console.log('All required environment variables are set.')
```

---

### Sharing App Initialization Logic

When multiple scripts all build the app the same way, extract a shared factory:

```js
// scripts/lib/build-app.js
'use strict'

const Fastify = require('fastify')
const appPlugin = require('../../app')

async function buildApp (opts = {}) {
  const fastify = Fastify({
    logger: { level: process.env.LOG_LEVEL || 'info' },
    ...opts
  })
  fastify.register(appPlugin)
  await fastify.ready()
  return fastify
}

module.exports = { buildApp }
```

Scripts import from this shared factory:

```js
// scripts/seed.js
const { buildApp } = require('./lib/build-app')

async function main () {
  const fastify = await buildApp()
  try {
    await fastify.db.seed()
  } finally {
    await fastify.close()
  }
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
```

---

### TypeScript Custom Scripts

```ts
// scripts/migrate.ts
import Fastify from 'fastify'
import app from '../src/app'

async function main (): Promise<void> {
  const fastify = Fastify({ logger: true })
  fastify.register(app)
  await fastify.ready()

  try {
    await (fastify as any).db.migrate.latest()
    fastify.log.info('Migrations complete.')
  } finally {
    await fastify.close()
  }
}

main().catch((err: Error) => {
  console.error(err.message)
  process.exit(1)
})
```

Run without compiling using `ts-node`:

```bash
npx ts-node scripts/migrate.ts
```

Or compile and run:

```bash
npx tsc && node dist/scripts/migrate.js
```

Add as an npm script:

```json
{
  "scripts": {
    "migrate": "ts-node scripts/migrate.ts"
  }
}
```

> [Inference] `ts-node` interprets TypeScript at runtime and is appropriate for development scripts. For production or performance-sensitive script execution, compile to JavaScript first.

---

### Testing Custom Scripts

Because scripts are structured around a `buildApp` factory, they are straightforward to test:

```js
// test/scripts/seed.test.js
const { test } = require('node:test')
const { buildApp } = require('../../scripts/lib/build-app')

test('seed script populates users table', async (t) => {
  const fastify = await buildApp()
  t.after(() => fastify.close())

  await fastify.db.seed()

  const result = await fastify.db.query('SELECT COUNT(*) FROM users')
  t.assert.ok(Number(result.rows[0].count) > 0)
})
```

---

### Script Timeout and Long-Running Tasks

For long-running scripts, Node.js may stay alive waiting for open handles (e.g., connection pools). Calling `fastify.close()` in `finally` triggers `onClose` hooks which should release those handles.

If a script hangs after completion:

```js
// Force exit after cleanup as a last resort
await fastify.close()
process.exit(0)
```

> [Inference] Relying on `process.exit(0)` to terminate a script bypasses any remaining async cleanup. It is preferable to identify and properly close the handle keeping the process alive — typically a database connection pool or timer not managed by `onClose`.

---

### CI and Automation Integration

Scripts integrate naturally with CI pipelines:

```yaml
# .github/workflows/deploy.yml (excerpt)
- name: Run migrations
  run: npm run migrate
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
    NODE_ENV: production

- name: Start application
  run: npm start
```

Exit code `1` from `process.exit(1)` causes the CI step to fail, blocking subsequent steps.

---

**Related Topics:**
- `fastify-cli/helper` API and test integration
- Fastify `onClose` hook for resource teardown
- `@fastify/env` for validated config in scripts
- Database migration tools with Fastify (`knex`, `db-migrate`, `node-pg-migrate`)
- `node:util` `parseArgs` for argument parsing
- TypeScript `ts-node` for script execution without compilation
- Process managers (PM2) for scheduled and persistent scripts