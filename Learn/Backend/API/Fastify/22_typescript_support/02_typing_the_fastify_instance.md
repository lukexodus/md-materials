## Typing the Fastify Instance

### What "Typing the Instance" Means

When you call `Fastify()`, the returned object is a `FastifyInstance`. However, that instance is not a simple flat object — it is a generic type parameterized by the underlying HTTP server type, the request type, and the reply type. Understanding how these generics compose gives you precise control over what TypeScript knows about your server, its decorators, and the objects passed through the request lifecycle.

---

### The `FastifyInstance` Generic Signature

The full generic signature of `FastifyInstance` is:

```typescript
FastifyInstance
  Server,        // HTTP server type
  Request,       // Incoming message type
  Reply,         // Server response type
  Logger,        // Logger type
  TypeProvider   // Type provider (for schema inference)
>
```

In practice, you rarely need to supply all five. TypeScript infers them from the arguments passed to `Fastify()`.

**Example — default instance with inferred types:**

```typescript
import Fastify, { FastifyInstance } from 'fastify'

const app: FastifyInstance = Fastify({ logger: true })
```

Here, `FastifyInstance` defaults to:

| Parameter | Default |
|---|---|
| `Server` | `http.Server` |
| `Request` | `http.IncomingMessage` |
| `Reply` | `http.ServerResponse` |
| `Logger` | `FastifyBaseLogger` |
| `TypeProvider` | `FastifyTypeProviderDefault` |

---

### HTTP, HTTPS, and HTTP/2 Server Types

The `Server` generic changes when you configure TLS or HTTP/2. TypeScript needs to know this to correctly type low-level server access.

**HTTP (default):**

```typescript
import Fastify from 'fastify'
import { FastifyInstance } from 'fastify'
import http from 'http'

const app: FastifyInstance<http.Server> = Fastify()
```

**HTTPS:**

```typescript
import Fastify from 'fastify'
import { FastifyInstance } from 'fastify'
import https from 'https'
import fs from 'fs'

const app: FastifyInstance<https.Server> = Fastify({
  https: {
    key: fs.readFileSync('./key.pem'),
    cert: fs.readFileSync('./cert.pem')
  }
})
```

**HTTP/2 (insecure):**

```typescript
import Fastify from 'fastify'
import { FastifyInstance } from 'fastify'
import http2 from 'http2'

const app: FastifyInstance<http2.Http2Server> = Fastify({ http2: true })
```

**HTTP/2 with TLS:**

```typescript
import http2 from 'http2'
import { FastifyInstance } from 'fastify'

const app: FastifyInstance<http2.Http2SecureServer> = Fastify({
  http2: true,
  https: { /* cert and key */ }
})
```

**Key Points:**
- If you access `app.server` (the raw Node.js server), TypeScript will type it correctly based on the `Server` generic
- Mismatching the generic with the actual config will not cause a runtime error, but will produce incorrect types for `app.server`

---

### Typing the Instance in a Factory Function

A common pattern is to construct the Fastify instance in a dedicated function. Annotating the return type explicitly makes the instance portable and type-safe across modules.

```typescript
import Fastify, { FastifyInstance } from 'fastify'

function buildApp(): FastifyInstance {
  const app = Fastify({ logger: true })

  app.get('/health', async () => {
    return { status: 'ok' }
  })

  return app
}
```

**Key Points:**
- Annotating `FastifyInstance` as the return type catches errors early if the function accidentally returns an incompatible object
- The inferred generics from `Fastify()` propagate through the return type automatically — you do not need to restate them unless you are being explicit about HTTPS or HTTP/2

---

### Accessing `app.server`

`app.server` exposes the underlying Node.js HTTP/HTTPS/HTTP2 server. Its type is determined by the `Server` generic:

```typescript
import Fastify from 'fastify'
import http from 'http'

const app = Fastify()

// app.server is typed as http.Server
app.server.on('connection', (socket) => {
  console.log('New connection from', socket.remoteAddress)
})
```

If you use `http2`, `app.server` becomes `http2.Http2Server` or `http2.Http2SecureServer`, and you gain access to HTTP/2-specific events and methods with correct typing.

---

### Decorating the Instance and Typing Decorators

Fastify allows you to attach custom properties to the instance using `app.decorate()`. TypeScript does not automatically know about these — you must augment the type manually using declaration merging or the `decorate` generic overload.

**Option 1 — Module Augmentation (recommended for plugins):**

```typescript
import { FastifyInstance } from 'fastify'

declare module 'fastify' {
  interface FastifyInstance {
    config: {
      db_url: string
      port: number
    }
  }
}
```

After this declaration, `app.config` is known to TypeScript everywhere `FastifyInstance` is used.

**Usage:**

```typescript
app.decorate('config', {
  db_url: 'postgres://localhost/mydb',
  port: 3000
})

// Now TypeScript knows about app.config
console.log(app.config.db_url)
```

**Option 2 — Inline generic (for local/one-off decorators):**

This is less common and more verbose. Module augmentation is generally preferred for anything shared across files.

**Key Points:**
- Module augmentation must be in a file that is a module (i.e., has at least one `import` or `export` statement); otherwise it affects the global scope unintentionally
- The actual `decorate()` call at runtime must still match the declared type — TypeScript cannot verify this automatically [Inference]
- Behavior of decorator typing may vary depending on TypeScript version and `strict` mode settings

---

### The Logger Generic

Fastify's logger generic defaults to `FastifyBaseLogger`, which covers the standard `pino`-based logger interface. If you use a custom logger, you can type it explicitly:

```typescript
import Fastify, { FastifyInstance, FastifyBaseLogger } from 'fastify'

// Using the default logger — no change needed
const app: FastifyInstance
  import('http').Server,
  import('http').IncomingMessage,
  import('http').ServerResponse,
  FastifyBaseLogger
> = Fastify({ logger: true })
```

In most cases, you will not need to override the logger generic explicitly. The default `FastifyBaseLogger` covers `info`, `warn`, `error`, `debug`, `trace`, and `fatal`.

---

### The TypeProvider Generic

The fifth generic, `TypeProvider`, controls how Fastify maps JSON Schema to TypeScript types. The default (`FastifyTypeProviderDefault`) provides basic inference. Replacing it with a type provider like `TypeBoxTypeProvider` or `JsonSchemaToTsProvider` unlocks schema-driven type inference for request bodies, params, and responses.

This is a large topic of its own, but the instance-level wiring looks like this:

```typescript
import Fastify from 'fastify'
import { TypeBoxTypeProvider } from '@fastify/type-provider-typebox'

const app = Fastify().withTypeProvider<TypeBoxTypeProvider>()
```

`withTypeProvider<T>()` returns a new instance reference typed with the given provider — the original `app` variable remains typed with the default provider. [Inference] This means you should reassign or use the returned value directly; assigning back to a `FastifyInstance` annotation without the provider generic will lose the provider type information.

---

### Passing the Instance Between Modules

When you pass `app` to a plugin or helper function, the parameter type should be `FastifyInstance`:

```typescript
// routes/users.ts
import { FastifyInstance } from 'fastify'

export async function userRoutes(app: FastifyInstance): Promise<void> {
  app.get('/users', async () => {
    return []
  })
}
```

```typescript
// app.ts
import { userRoutes } from './routes/users'

app.register(userRoutes)
```

**Key Points:**
- `app.register()` accepts a function with the signature `(instance: FastifyInstance, opts: object) => Promise<void>`, which matches the pattern above
- The plugin receives a *scoped child instance*, not the root instance — decorators added inside the plugin are not visible outside unless `fastify-plugin` is used
- TypeScript types the child instance as `FastifyInstance` just like the root, though encapsulation is a runtime behavior, not a type-level distinction

---

### Full Reference: `FastifyInstance` Import Paths

All core types are exported from the top-level `'fastify'` package:

```typescript
import {
  FastifyInstance,
  FastifyRequest,
  FastifyReply,
  FastifyBaseLogger,
  FastifyTypeProviderDefault,
  RawServerDefault,        // Alias for http.Server
  RawRequestDefaultExpression,  // Alias for http.IncomingMessage
  RawReplyDefaultExpression     // Alias for http.ServerResponse
} from 'fastify'
```

You do not need to import from deep paths like `fastify/types/*` — the public API surface is fully re-exported from the root.

---

### Summary Table

| Concern | Type / Approach |
|---|---|
| Default instance | `FastifyInstance` |
| HTTPS instance | `FastifyInstance<https.Server>` |
| HTTP/2 instance | `FastifyInstance<http2.Http2Server>` |
| Custom decorator | `declare module 'fastify' { interface FastifyInstance { ... } }` |
| Typed type provider | `.withTypeProvider<TypeBoxTypeProvider>()` |
| Plugin parameter | `(app: FastifyInstance) => Promise<void>` |
| Raw server access | `app.server` (typed by `Server` generic) |

---

**Related Topics:**

- Typed plugins with `fastify-plugin` and TypeScript
- Type providers: TypeBox, Zod, and `json-schema-to-ts`
- Typing `FastifyRequest` and `FastifyReply` generics
- Declaration merging for `FastifyRequest` and `FastifyReply` decorators
- Scoped vs. non-scoped plugins and type visibility
- Using `withTypeProvider` across the full route lifecycle
- Typing hooks with `FastifyInstance` generics
- Custom logger types with `pino` and Fastify