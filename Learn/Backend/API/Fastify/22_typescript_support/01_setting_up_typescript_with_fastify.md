## Setting up TypeScript with Fastify

### Why TypeScript with Fastify

Fastify has first-class TypeScript support built into its core package — no separate `@types/` package is needed as of Fastify v4+. Its type definitions cover the full lifecycle: server creation, route declarations, request/reply objects, hooks, and plugins. This makes it one of the more type-safe Node.js frameworks available without requiring third-party augmentation.

---

### Prerequisites

Before setting up a Fastify TypeScript project, the following must be present:

- **Node.js** — v18 or later recommended
- **npm** or **pnpm** or **yarn**
- **TypeScript** — v5 recommended (v4.7+ minimum for full compatibility)
- **ts-node** or **tsx** — for running TypeScript directly during development (optional but common)

---

### Project Initialization

```bash
mkdir fastify-ts-app
cd fastify-ts-app
npm init -y
```

---

### Installing Dependencies

**Runtime dependency:**

```bash
npm install fastify
```

**Development dependencies:**

```bash
npm install -D typescript ts-node @types/node
```

> `@types/node` is required because Fastify's types reference Node.js built-in types (e.g., `Buffer`, `IncomingMessage`).

**Optional — faster dev runner (alternative to ts-node):**

```bash
npm install -D tsx
```

---

### TypeScript Configuration

Generate a base `tsconfig.json`:

```bash
npx tsc --init
```

Then tailor it for a Fastify project:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**Key Points:**
- `strict: true` — activates all strict type checks; strongly recommended with Fastify's generics
- `esModuleInterop: true` — needed for clean default imports from CommonJS modules
- `skipLibCheck: true` — avoids errors from type conflicts inside `node_modules`
- `resolveJsonModule: true` — useful if you load config or schema JSON files
- `target: ES2020` — [Inference] aligned with Fastify's own internal usage; lower targets may require additional polyfills

---

### Project Structure

A conventional layout for a Fastify TypeScript project:

```
fastify-ts-app/
├── src/
│   ├── app.ts          # Fastify instance creation and plugin registration
│   ├── server.ts       # Entry point — starts the server
│   └── routes/
│       └── example.ts  # Route definitions
├── dist/               # Compiled output (generated)
├── tsconfig.json
└── package.json
```

---

### Creating the Fastify Instance

**`src/app.ts`**

```typescript
import Fastify, { FastifyInstance } from 'fastify'

export function buildApp(): FastifyInstance {
  const app = Fastify({
    logger: true
  })

  app.get('/ping', async (request, reply) => {
    return { pong: true }
  })

  return app
}
```

**Key Points:**
- `FastifyInstance` is the primary type for the server object
- The `async` route handler automatically infers the return type and serializes it
- `request` and `reply` are typed as `FastifyRequest` and `FastifyReply` respectively when not explicitly declared — Fastify infers these from context

---

### Entry Point

**`src/server.ts`**

```typescript
import { buildApp } from './app'

const app = buildApp()

app.listen({ port: 3000, host: '0.0.0.0' }, (err, address) => {
  if (err) {
    app.log.error(err)
    process.exit(1)
  }
  app.log.info(`Server listening at ${address}`)
})
```

Alternatively, using `async/await`:

```typescript
import { buildApp } from './app'

const start = async () => {
  const app = buildApp()

  try {
    await app.listen({ port: 3000, host: '0.0.0.0' })
  } catch (err) {
    app.log.error(err)
    process.exit(1)
  }
}

start()
```

---

### Scripts in `package.json`

```json
{
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js"
  }
}
```

**Key Points:**
- `tsx watch` provides hot-reload during development without a separate build step
- `tsc` compiles to `./dist` as configured in `tsconfig.json`
- Production runs the compiled JavaScript in `dist/`

---

### Typed Request and Reply Generics

Fastify's route methods accept generics to type the request body, params, querystring, and headers explicitly:

```typescript
import { FastifyRequest, FastifyReply } from 'fastify'

interface CreateUserBody {
  name: string
  email: string
}

interface UserParams {
  id: string
}

app.post<{ Body: CreateUserBody }>(
  '/users',
  async (request: FastifyRequest<{ Body: CreateUserBody }>, reply: FastifyReply) => {
    const { name, email } = request.body // fully typed
    return reply.status(201).send({ id: '123', name, email })
  }
)

app.get<{ Params: UserParams }>(
  '/users/:id',
  async (request, reply) => {
    const { id } = request.params // typed as string
    return { id }
  }
)
```

The generic slots available on route definitions are:

| Generic Key   | Maps to              |
|---------------|----------------------|
| `Body`        | `request.body`       |
| `Params`      | `request.params`     |
| `Querystring` | `request.query`      |
| `Headers`     | `request.headers`    |
| `Reply`       | `reply.send()` types |

---

### ESM vs CommonJS

The configuration above uses `"module": "CommonJS"`, which is the most compatible default for Node.js projects. ESM (`"module": "ESNext"` or `"module": "NodeNext"`) is supported but requires:

- `"type": "module"` in `package.json`
- `.js` extensions in all import paths (even when writing `.ts` files)
- Careful handling of `__dirname` and `__filename` (not available natively in ESM)

[Inference] CommonJS is the path of least friction for most Fastify TypeScript setups. ESM is viable but introduces additional configuration complexity that may not be immediately obvious.

---

### Verifying the Setup

Run in development mode:

```bash
npm run dev
```

Test the endpoint:

```bash
curl http://localhost:3000/ping
```

**Expected Output:**
```json
{ "pong": true }
```

Build for production:

```bash
npm run build
node dist/server.js
```

---

### Common Setup Errors

| Error | Likely Cause |
|---|---|
| `Cannot find module 'fastify'` | Package not installed; run `npm install fastify` |
| `Type 'X' is not assignable to...` | Strict mode catching a type mismatch — review generics |
| `esModuleInterop` errors | Missing `esModuleInterop: true` in `tsconfig.json` |
| `__dirname is not defined` | Using ESM without a CommonJS shim |
| Declaration errors in `node_modules` | Add `skipLibCheck: true` |

---

**Related Topics:**

- Typing route schemas with `@fastify/type-provider-typebox` or `@fastify/type-provider-json-schema-to-ts`
- Typed plugins and `fastify-plugin` with TypeScript
- Typing decorators (`request.user`, `app.db`, etc.)
- Using Zod as a type provider with `fastify-type-provider-zod`
- Configuring path aliases in `tsconfig.json` for cleaner imports
- Writing type-safe hooks (`onRequest`, `preHandler`, etc.)
- Testing TypeScript Fastify apps with `tap` or `vitest`
- Generating OpenAPI/Swagger docs from TypeScript types