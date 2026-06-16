## Basic Auth with @fastify/basic-auth

### Overview

`@fastify/basic-auth` is the official Fastify plugin for HTTP Basic Authentication. It implements [RFC 7617](https://datatracker.ietf.org/doc/html/rfc7617), where credentials are transmitted as a Base64-encoded `username:password` pair in the `Authorization` header. The plugin does not dictate how credentials are validated — it extracts and decodes them, then delegates to a user-supplied `validate` function, making it adaptable to any credential store.

Basic auth is most appropriate for internal tools, machine-to-machine APIs, and development environments. It should always be used over HTTPS in production, as credentials are not encrypted at the transport layer.

---

### Installation

bash

```bash
npm install @fastify/basic-auth
```

---

### How HTTP Basic Auth Works

FastifyClientFastifyClientalt[Valid][Invalid]GET /protected (no credentials)401 Unauthorized\nWWW-Authenticate: Basic realm="..."GET /protected\nAuthorization: Basic base64(user:pass)Decode → validate(user, pass)200 OK + response body401 Unauthorized

**Key Points:**

- The `Authorization: Basic <token>` header carries `btoa('username:password')`.
- The server responds with `WWW-Authenticate: Basic realm="..."` on a 401 to prompt browsers to show a login dialog.
- Credentials are encoded, not encrypted — HTTPS is mandatory in any production use.

---

### Registration

js

```js
import Fastify from 'fastify'
import basicAuth from '@fastify/basic-auth'

const fastify = Fastify({ logger: true })

await fastify.register(basicAuth, {
  validate: async function (username, password, request, reply) {
    if (username !== 'admin' || password !== 'secret') {
      return new Error('Invalid credentials')
    }
    // Return nothing (or undefined) to signal success
  },
  authenticate: true  // sends WWW-Authenticate header on 401
})
```

**Key Points:**

- `validate` is required. It receives `(username, password, request, reply)` and must return an `Error` instance to signal failure, or nothing to signal success.
- `authenticate: true` enables the `WWW-Authenticate` response header, causing browsers to show a native login dialog. Set to `false` to suppress it for API clients.
- `authenticate` can also be an object to customize the realm: `{ realm: 'My App' }`.

---

### The `validate` Function

The validate function is the integration point with your credential store. It supports both async and callback styles.

#### Async Style

js

```js
validate: async function (username, password, request, reply) {
  const user = await db.users.findOne({ username })

  if (!user) {
    return new Error('Unknown user')
  }

  const match = await bcrypt.compare(password, user.passwordHash)
  if (!match) {
    return new Error('Invalid password')
  }
  // success: return nothing
}
```

#### Callback Style

js

```js
validate: function (username, password, request, reply, done) {
  if (username === 'admin' && password === 'secret') {
    done()           // success
  } else {
    done(new Error('Unauthorized'))  // failure
  }
}
```

**Key Points:**

- Returning or calling `done` with an `Error` triggers a 401 response.
- The `request` and `reply` objects are available inside `validate` — useful for logging, attaching user data, or conditional logic based on route context.
- [Inference] Timing differences between valid and invalid credential checks can leak information. Use constant-time comparison where possible (e.g., `crypto.timingSafeEqual`).

---

### Applying Basic Auth to Routes

`@fastify/basic-auth` registers a Fastify hook called `fastify.basicAuth` that can be applied selectively using `onRequest` at the route or plugin level.

#### Per-Route

js

```js
fastify.get('/protected', {
  onRequest: fastify.basicAuth
}, async (request, reply) => {
  return { message: 'Authenticated' }
})
```

#### Route Group via `register`

Scoping basic auth to a subset of routes using Fastify's encapsulation:

js

```js
fastify.register(async function (instance) {
  instance.addHook('onRequest', instance.basicAuth)

  instance.get('/admin/users', async (request, reply) => {
    return { users: await db.users.findAll() }
  })

  instance.get('/admin/stats', async (request, reply) => {
    return { uptime: process.uptime() }
  })
})
```

**Key Points:**

- Routes outside the encapsulated scope are unaffected.
- This pattern avoids repeating `onRequest: fastify.basicAuth` on every route definition.

---

### Customizing the 401 Response

By default, failed authentication returns a generic 401. Override `onUnauthorized` to customize the error body:

js

```js
await fastify.register(basicAuth, {
  validate: async function (username, password, request, reply) {
    if (username !== 'admin' || password !== 'pass') {
      return new Error('Bad credentials')
    }
  },
  authenticate: { realm: 'Admin Area' },
  onUnauthorized: function (error, request, reply) {
    reply.code(401).send({
      statusCode: 401,
      error: 'Unauthorized',
      message: 'Valid credentials are required to access this resource'
    })
  }
})
```

---

### Attaching User Data to `request`

Since `validate` receives the full `request` object, you can decorate the request with user information for use in downstream handlers:

js

```js
await fastify.register(basicAuth, {
  validate: async function (username, password, request, reply) {
    const user = await db.users.findOne({ username })
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      return new Error('Unauthorized')
    }
    request.user = user  // attach for use in route handlers
  },
  authenticate: true
})

fastify.get('/me', { onRequest: fastify.basicAuth }, async (request, reply) => {
  return { id: request.user.id, username: request.user.username }
})
```

**Key Points:**

- TypeScript users should augment the `FastifyRequest` interface to type `request.user` correctly.
- [Inference] This pattern is a lightweight alternative to session management for stateless API authentication.

---

### Multiple Validators

`@fastify/basic-auth` supports registering multiple instances with different validators using Fastify's encapsulation. This is useful when different route groups have different credential stores or policies.

js

```js
// Admin routes — validate against admin credentials
fastify.register(async function adminScope (instance) {
  await instance.register(basicAuth, {
    validate: async (username, password) => {
      if (username !== 'admin' || password !== process.env.ADMIN_PASS) {
        return new Error('Admin credentials required')
      }
    },
    authenticate: { realm: 'Admin' }
  })

  instance.get('/admin/config', { onRequest: instance.basicAuth }, async () => {
    return { config: 'sensitive data' }
  })
})

// Metrics routes — validate against a separate token
fastify.register(async function metricsScope (instance) {
  await instance.register(basicAuth, {
    validate: async (username, password) => {
      if (password !== process.env.METRICS_TOKEN) {
        return new Error('Invalid metrics token')
      }
    },
    authenticate: { realm: 'Metrics' }
  })

  instance.get('/metrics', { onRequest: instance.basicAuth }, async () => {
    return { requests: 42 }
  })
})
```

---

### Timing-Safe Credential Comparison

To reduce timing attack exposure, use `crypto.timingSafeEqual` when comparing credentials:

js

```js
import { timingSafeEqual, createHash } from 'crypto'

function safeCompare (a, b) {
  const bufA = Buffer.from(createHash('sha256').update(a).digest())
  const bufB = Buffer.from(createHash('sha256').update(b).digest())
  return bufA.length === bufB.length && timingSafeEqual(bufA, bufB)
}

await fastify.register(basicAuth, {
  validate: async function (username, password, request, reply) {
    const validUser = process.env.BASIC_AUTH_USER
    const validPass = process.env.BASIC_AUTH_PASS

    if (!safeCompare(username, validUser) || !safeCompare(password, validPass)) {
      return new Error('Unauthorized')
    }
  },
  authenticate: true
})
```

**Key Points:**

- `timingSafeEqual` requires both buffers to be the same length — hashing both sides first normalizes lengths and prevents length-based leaks.
- This does not replace proper password hashing (bcrypt, argon2) for user-facing credential stores — it is most applicable to static API keys or tokens. [Inference]

---

### Combining with Other Auth Strategies

Basic auth can coexist with JWT or OAuth2 on different route groups:

js

```js
// Public routes — no auth
fastify.get('/health', async () => ({ status: 'ok' }))

// API routes — JWT auth
fastify.register(async function apiScope (instance) {
  instance.addHook('onRequest', async (request, reply) => {
    await request.jwtVerify()
  })
  instance.get('/api/data', async () => ({ data: [] }))
})

// Admin routes — basic auth
fastify.register(async function adminScope (instance) {
  await instance.register(basicAuth, {
    validate: async (u, p) => {
      if (u !== 'admin' || p !== process.env.ADMIN_PASS) return new Error('Unauthorized')
    },
    authenticate: { realm: 'Admin' }
  })
  instance.get('/admin', { onRequest: instance.basicAuth }, async () => ({ panel: true }))
})
```

---

### Plugin Options Reference

| Option | Type | Description |
| --- | --- | --- |
| `validate` | function | Required. Credential validation logic |
| `authenticate` | boolean | object | Sends `WWW-Authenticate` header on 401. Object form: `{ realm: 'name' }` |
| `onUnauthorized` | function | Custom handler for failed authentication |
| `utf8` | boolean | Enables UTF-8 charset in `WWW-Authenticate` header (default: `false`) |
| `strictCredentials` | boolean | Rejects malformed Authorization headers (default: `true`) |

---

### Security Considerations

- Always serve basic auth routes over HTTPS. Credentials transmitted over HTTP are trivially interceptable.
- Do not hardcode credentials — load from environment variables or a secrets manager.
- For user-facing systems, hash stored passwords with bcrypt or argon2. Plain-text or MD5/SHA1 password storage is insufficient.
- Use `timingSafeEqual` or equivalent for credential comparisons to reduce timing attack surface.
- Consider rate limiting brute-force attempts with `@fastify/rate-limit` on protected routes.
- The `authenticate: true` option triggers browser login dialogs — for API clients, set it to `false` to avoid unexpected UX.
- Basic auth does not support logout in the traditional sense — the browser caches credentials for the session. [Inference] Credential invalidation requires either a credential change server-side or instructing the client to clear cached auth.

---

### Minimal Working Example

js

```js
import Fastify from 'fastify'
import basicAuth from '@fastify/basic-auth'

const fastify = Fastify({ logger: true })

await fastify.register(basicAuth, {
  validate: async function (username, password, request, reply) {
    if (username !== process.env.AUTH_USER || password !== process.env.AUTH_PASS) {
      return new Error('Invalid credentials')
    }
  },
  authenticate: { realm: 'My App' }
})

fastify.get('/public', async () => ({ message: 'No auth required' }))

fastify.get('/private', { onRequest: fastify.basicAuth }, async (request, reply) => {
  return { message: 'Authenticated successfully' }
})

await fastify.listen({ port: 3000 })
```

**Testing with curl:**

bash

```bash
# No credentials — expect 401
curl -i http://localhost:3000/private

# Valid credentials
curl -i -u admin:secret http://localhost:3000/private

# Invalid credentials
curl -i -u admin:wrong http://localhost:3000/private
```

---

**Related Topics:**

- Rate limiting basic auth routes with `@fastify/rate-limit`
- Replacing basic auth with JWT for stateless token-based auth
- Digest authentication as a slightly stronger alternative to basic auth
- Using `@fastify/auth` to compose multiple auth strategies on a single route
- Securing internal microservice-to-microservice communication
- Password hashing with bcrypt and argon2 in Node.js
- Brute-force protection patterns in Fastify