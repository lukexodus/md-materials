### Setting Up a Standalone Node.js Server

#### Overview

tRPC can run on a standalone Node.js HTTP server without any framework like Next.js. This is appropriate when building a dedicated backend service, a microservice, or when you want full control over the server layer. tRPC provides an adapter for Node.js's native `http` module, and integrations with Express and Fastify are also available as first-party adapters.

---

#### Dependencies

Install the core packages:

```bash
npm install @trpc/server zod
```

For a raw Node.js HTTP server, no additional adapter package is needed — the adapter is included in `@trpc/server`. For Express or Fastify, additional packages are required (covered in their respective sections below).

---

#### Project Structure

```
src/
├── server/
│   ├── trpc.ts           # initTRPC, exported procedures and router
│   ├── context.ts        # createContext function
│   └── router/
│       ├── index.ts      # Root appRouter
│       └── example.router.ts
├── index.ts              # HTTP server entry point
├── package.json
└── tsconfig.json
```

---

#### Step 1 — Initialize tRPC

```ts
// src/server/trpc.ts
import { initTRPC } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
```

---

#### Step 2 — Define Context

```ts
// src/server/context.ts
import type { IncomingMessage, ServerResponse } from 'http';

export async function createContext({
  req,
  res,
}: {
  req: IncomingMessage;
  res: ServerResponse;
}) {
  return { req, res };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points**

- The context receives the raw Node.js `IncomingMessage` and `ServerResponse` objects.
- You can extract headers, session tokens, or other request data here before procedures execute.

---

#### Step 3 — Define a Router

```ts
// src/server/router/example.router.ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

export const exampleRouter = router({
  hello: publicProcedure
    .input(z.object({ name: z.string() }))
    .query(({ input }) => {
      return { greeting: `Hello, ${input.name}` };
    }),
});
```

```ts
// src/server/router/index.ts
import { router } from '../trpc';
import { exampleRouter } from './example.router';

export const appRouter = router({
  example: exampleRouter,
});

export type AppRouter = typeof appRouter;
```

---

#### Step 4 — Create the HTTP Server

tRPC provides `createHTTPServer` from `@trpc/server/adapters/standalone` for this purpose.

```ts
// src/index.ts
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { appRouter } from './server/router';
import { createContext } from './server/context';

const server = createHTTPServer({
  router: appRouter,
  createContext,
});

server.listen(3000);
console.log('tRPC server listening on http://localhost:3000');
```

**Key Points**

- `createHTTPServer` wraps Node.js's `http.createServer` internally.
- All tRPC procedures are reachable under the root path by default (e.g., `http://localhost:3000/example.hello`).
- No manual route registration is needed — the adapter handles routing to procedures.

---

#### Request and Response Shape

tRPC over HTTP follows a specific convention:

| Procedure Type | HTTP Method | Data Location |
| --- | --- | --- |
| `query` | `GET` | URL query string (`?input=...`) |
| `mutation` | `POST` | JSON request body |

**Example** — calling the `example.hello` query via `curl`:

```bash
curl "http://localhost:3000/example.hello?input=%7B%22name%22%3A%22Alice%22%7D"
```

The `input` parameter is a URL-encoded JSON string. In practice, the tRPC client handles this encoding automatically.

**Output**

```json
{
  "result": {
    "data": {
      "greeting": "Hello, Alice"
    }
  }
}
```

---

#### CORS Configuration

The standalone adapter does not apply CORS headers by default. For browser-based clients, you need to handle this explicitly.

```ts
// src/index.ts
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { appRouter } from './server/router';
import { createContext } from './server/context';

const server = createHTTPServer({
  router: appRouter,
  createContext,
  middleware(req, res, next) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.writeHead(204);
      res.end();
      return;
    }

    next();
  },
});

server.listen(3000);
```

**Key Points**

- The `middleware` option in `createHTTPServer` runs before tRPC handles the request.
- Setting `Access-Control-Allow-Origin: *` is permissive. In production, restrict this to known origins.
- Preflight `OPTIONS` requests must be handled and terminated before reaching the tRPC handler.

---

#### Using Express Instead

If you need middleware ecosystem support (logging, auth libraries, body parsers), Express is a common choice.

```bash
npm install express @trpc/server
npm install --save-dev @types/express
```

```ts
// src/index.ts
import express from 'express';
import * as trpcExpress from '@trpc/server/adapters/express';
import { appRouter } from './server/router';
import { createContext } from './server/context';

const app = express();

app.use(
  '/trpc',
  trpcExpress.createExpressMiddleware({
    router: appRouter,
    createContext,
  }),
);

app.listen(3000, () => {
  console.log('Express + tRPC server listening on http://localhost:3000');
});
```

**Key Points**

- The tRPC middleware is mounted at a path prefix (`/trpc` here). All procedure paths are appended to this prefix.
- `createContext` for Express receives Express-typed `req` and `res` objects. Update the context type accordingly:

```ts
// src/server/context.ts (Express variant)
import type { CreateExpressContextOptions } from '@trpc/server/adapters/express';

export async function createContext({ req, res }: CreateExpressContextOptions) {
  return { req, res };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

---

#### Using Fastify Instead

```bash
npm install fastify @trpc/server @trpc/server/adapters/fastify
```

```ts
// src/index.ts
import Fastify from 'fastify';
import { fastifyTRPCPlugin } from '@trpc/server/adapters/fastify';
import { appRouter } from './server/router';
import { createContext } from './server/context';

const server = Fastify();

server.register(fastifyTRPCPlugin, {
  prefix: '/trpc',
  trpcOptions: {
    router: appRouter,
    createContext,
  },
});

server.listen({ port: 3000 }, () => {
  console.log('Fastify + tRPC server listening on http://localhost:3000');
});
```

**Key Points**

- The Fastify adapter is registered as a Fastify plugin via `register`.
- [Inference] Fastify's plugin encapsulation model may affect how context and middleware interact with the tRPC plugin scope. Verify behavior against the tRPC Fastify adapter documentation for your specific version.

---

#### TypeScript Configuration

A minimal `tsconfig.json` for a standalone Node.js tRPC server:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"]
}
```

**Key Points**

- `strict: true` is strongly recommended. tRPC's type inference relies on strict TypeScript settings; disabling strict mode may produce unexpected type behavior, though the exact impact depends on which strict flags are disabled. [Inference]
- `moduleResolution: "node"` is appropriate for CommonJS targets. For ESM projects, use `"bundler"` or `"node16"` depending on your setup.

---

#### Running the Server

Add scripts to `package.json`:

```json
{
  "scripts": {
    "dev": "ts-node src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  }
}
```

For development with hot reload:

```bash
npm install --save-dev ts-node nodemon
```

```json
{
  "scripts": {
    "dev": "nodemon --exec ts-node src/index.ts"
  }
}
```

---

#### Adapter Comparison

| Adapter | Package Path | Use Case |
| --- | --- | --- |
| Standalone | `@trpc/server/adapters/standalone` | Minimal Node.js, no framework |
| Express | `@trpc/server/adapters/express` | Existing Express apps, middleware |
| Fastify | `@trpc/server/adapters/fastify` | Performance-focused, plugin model |
| Fetch | `@trpc/server/adapters/fetch` | Edge runtimes, Cloudflare Workers |