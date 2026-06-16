## Enabling CORS with @fastify/cors

### Overview

Cross-Origin Resource Sharing (CORS) is an HTTP mechanism that controls which origins outside the serving domain are permitted to make requests to a server. Browsers enforce a same-origin policy by default — requests from `https://app.example.com` to `https://api.example.com` are blocked unless the server explicitly permits them via CORS headers. `@fastify/cors` is the official Fastify plugin that manages these headers, handling both simple requests and preflight `OPTIONS` requests automatically.

---

### How CORS Works

Fastify API (api.example.com)BrowserFastify API (api.example.com)BrowserSimple Request (GET, POST with basic headers)Preflight Request (PUT, DELETE, custom headers)GET /data\nOrigin: https://app.example.com200 OK\nAccess-Control-Allow-Origin: https://app.example.comOPTIONS /data\nOrigin: https://app.example.com\nAccess-Control-Request-Method: PUT\nAccess-Control-Request-Headers: Authorization204 No Content\nAccess-Control-Allow-Origin: https://app.example.com\nAccess-Control-Allow-Methods: GET,PUT,DELETE\nAccess-Control-Allow-Headers: Authorization\nAccess-Control-Max-Age: 86400PUT /data\nOrigin: https://app.example.com\nAuthorization: Bearer ...200 OK + response body

**Key Points:**

- **Simple requests** — GET, HEAD, POST with standard headers — do not trigger a preflight. The browser sends the request and checks the response headers.
- **Preflight requests** — browsers automatically send an `OPTIONS` request before any request that uses non-simple methods, custom headers, or credentials. The server must respond correctly before the actual request is sent.
- CORS is enforced by the **browser** — it does not protect server-to-server communication. A curl or Postman request ignores CORS headers entirely.
- `@fastify/cors` handles preflight `OPTIONS` routes automatically — no manual route definition is needed.

---

### Installation

bash

```bash
npm install @fastify/cors
```

---

### Basic Registration

js

```js
import Fastify from 'fastify'
import cors from '@fastify/cors'

const fastify = Fastify({ logger: true })

await fastify.register(cors, {
  origin: 'https://app.example.com'
})

fastify.get('/data', async () => ({ hello: 'world' }))

await fastify.listen({ port: 3000 })
```

With this configuration, only requests from `https://app.example.com` receive the `Access-Control-Allow-Origin` header. All other origins are denied.

---

### `origin` Option — Controlling Allowed Origins

The `origin` option is the most important CORS configuration. It accepts several forms:

#### Boolean — Allow All or None

js

```js
// Allow all origins (equivalent to Access-Control-Allow-Origin: *)
await fastify.register(cors, { origin: true })

// Block all cross-origin requests
await fastify.register(cors, { origin: false })
```

**Key Points:**

- `origin: true` reflects the request's `Origin` header back as the allowed origin — functionally equivalent to `*` but compatible with credentialed requests.
- `origin: false` disables CORS entirely.

#### String — Single Origin

js

```js
await fastify.register(cors, {
  origin: 'https://app.example.com'
})
```

#### Array — Multiple Origins

js

```js
await fastify.register(cors, {
  origin: [
    'https://app.example.com',
    'https://admin.example.com',
    'https://staging.example.com'
  ]
})
```

#### RegExp — Pattern Matching

js

```js
await fastify.register(cors, {
  origin: /\.example\.com$/  // matches any subdomain of example.com
})
```

#### Function — Dynamic Per-Request Logic

js

```js
await fastify.register(cors, {
  origin: (origin, callback) => {
    // origin is undefined for same-origin or non-browser requests
    if (!origin) return callback(null, true)

    const allowedOrigins = new Set([
      'https://app.example.com',
      'https://admin.example.com'
    ])

    if (allowedOrigins.has(origin)) {
      callback(null, true)   // allow
    } else {
      callback(new Error('Not allowed by CORS'), false)  // deny
    }
  }
})
```

**Key Points:**

- The function form receives `(origin, callback)` — call `callback(null, true)` to allow, `callback(error, false)` to deny.
- The async form is also supported — return a boolean or throw:

js

```js
await fastify.register(cors, {
  origin: async (origin) => {
    if (!origin) return true
    const allowed = await db.allowedOrigins.exists(origin)
    return allowed  // true or false
  }
})
```

- The dynamic function form is useful for database-driven allowlists, per-tenant origin policies, or environments where the origin list changes without a redeploy. [Inference]

---

### Full Options Reference

js

```js
await fastify.register(cors, {
  origin: 'https://app.example.com',   // see above
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
  exposedHeaders: ['X-Total-Count', 'X-Page-Count'],
  credentials: true,
  maxAge: 86400,          // preflight cache duration in seconds
  preflightContinue: false,  // pass preflight to next handler (default: false)
  optionsSuccessStatus: 204, // status code for preflight response
  preflight: true,           // handle OPTIONS requests (default: true)
  strictPreflight: true,     // reject OPTIONS without Origin/Access-Control-Request-Method
  hideOptionsRoute: true     // hide OPTIONS routes from Swagger/OpenAPI output
})
```

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | varies | `false` | Allowed origins — see above |
| `methods` | string | string[] | `GET,HEAD,PUT,PATCH,POST,DELETE` | Allowed HTTP methods |
| `allowedHeaders` | string | string[] | Reflects request headers | Headers the client may send |
| `exposedHeaders` | string | string[] | `undefined` | Headers the browser may read from the response |
| `credentials` | boolean | `false` | Enables `Access-Control-Allow-Credentials` |
| `maxAge` | number | `undefined` | Preflight cache duration in seconds |
| `preflightContinue` | boolean | `false` | Pass preflight to next handler instead of responding |
| `optionsSuccessStatus` | number | `204` | Status code for successful preflight |
| `preflight` | boolean | `true` | Auto-handle OPTIONS requests |
| `strictPreflight` | boolean | `true` | Reject malformed preflight requests |
| `hideOptionsRoute` | boolean | `true` | Exclude OPTIONS from API docs |

---

### Credentials and Cookies

When the browser sends credentialed requests (cookies, `Authorization` headers, TLS client certificates), both sides must opt in:

js

```js
await fastify.register(cors, {
  origin: 'https://app.example.com',  // must be explicit — not '*' or true
  credentials: true
})
```

The browser side must also set:

js

```js
// fetch
fetch('https://api.example.com/me', { credentials: 'include' })

// axios
axios.get('https://api.example.com/me', { withCredentials: true })
```

**Key Points:**

- `credentials: true` adds `Access-Control-Allow-Credentials: true` to responses.
- When `credentials: true`, `origin` must be a specific origin — not `*`. Browsers reject credentialed responses with a wildcard origin.
- [Inference] A common misconfiguration is setting `credentials: true` with `origin: '*'` — the browser will block the response even though the server sent it.

---

### `exposedHeaders` — Making Response Headers Readable

By default, browsers restrict which response headers JavaScript can access to a small safe list (`Cache-Control`, `Content-Type`, etc.). Use `exposedHeaders` to allow access to custom headers:

js

```js
await fastify.register(cors, {
  origin: 'https://app.example.com',
  exposedHeaders: ['X-Total-Count', 'X-Request-ID', 'X-RateLimit-Remaining']
})
```

js

```js
// Client-side — now readable
const total = response.headers.get('X-Total-Count')
```

**Key Points:**

- Without `exposedHeaders`, custom response headers are sent but inaccessible to browser JavaScript.
- This is relevant for pagination metadata, rate limit indicators, and request tracing headers.

---

### `allowedHeaders` — Controlling Request Headers

By default, `@fastify/cors` reflects whatever the client sends in `Access-Control-Request-Headers` back as `Access-Control-Allow-Headers`. To restrict this:

js

```js
await fastify.register(cors, {
  origin: 'https://app.example.com',
  allowedHeaders: ['Content-Type', 'Authorization']
})
```

**Key Points:**

- Explicit `allowedHeaders` prevents clients from sending arbitrary custom headers.
- If a client sends a preflight requesting a header not in `allowedHeaders`, the preflight fails.
- [Inference] Reflecting all requested headers (the default) is permissive — restrict in high-security contexts.

---

### `maxAge` — Preflight Caching

Preflight requests add a round-trip for every non-simple request. `maxAge` tells the browser how long to cache the preflight result:

js

```js
await fastify.register(cors, {
  origin: 'https://app.example.com',
  maxAge: 86400  // 24 hours
})
```

**Key Points:**

- During the cache window, the browser skips the preflight and sends the actual request directly.
- Browsers impose their own maximum on `maxAge` — Chrome caps it at 7200 seconds (2 hours), Firefox at 86400 seconds. [Unverified — browser limits may change]
- Setting `maxAge` to `0` disables preflight caching.

---

### Per-Route CORS Configuration

`@fastify/cors` applies globally by default. For per-route overrides, use `fastify-plugin` to expose the cors decorator and apply it selectively, or use different registered instances in scoped plugins.

#### Different Origins per Scope

js

```js
// Public API scope — open CORS
fastify.register(async function publicScope (instance) {
  await instance.register(cors, { origin: true })

  instance.get('/public/data', async () => ({ public: true }))
})

// Partner API scope — restricted CORS
fastify.register(async function partnerScope (instance) {
  await instance.register(cors, {
    origin: ['https://partner-a.com', 'https://partner-b.com'],
    credentials: true
  })

  instance.get('/partner/data', async () => ({ partner: true }))
})
```

**Key Points:**

- Each `register` scope gets its own CORS configuration.
- Fastify's encapsulation prevents the CORS plugin in one scope from affecting another.
- Routes outside any registered scope inherit the top-level CORS config (if any).

---

### Environment-Aware Configuration

CORS configuration commonly differs between development and production:

js

```js
const isDev = process.env.NODE_ENV !== 'production'

await fastify.register(cors, {
  origin: isDev
    ? true  // allow all origins in development
    : [
        'https://app.example.com',
        'https://admin.example.com'
      ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count'],
  maxAge: isDev ? 0 : 86400
})
```

**Key Points:**

- Never use `origin: true` or `origin: '*'` in production if the API handles authenticated or sensitive requests.
- [Inference] Loading allowed origins from an environment variable (comma-separated string split into an array) supports per-environment configuration without code changes.

js

```js
const allowedOrigins = process.env.CORS_ORIGINS?.split(',') ?? []

await fastify.register(cors, {
  origin: allowedOrigins.length > 0 ? allowedOrigins : false,
  credentials: true
})
```

---

### Preflight Handling Details

`@fastify/cors` registers an `OPTIONS` handler automatically. By default:

- It responds with `204 No Content` and appropriate CORS headers.
- `strictPreflight: true` rejects `OPTIONS` requests missing `Origin` or `Access-Control-Request-Method` headers with a `400`.

To pass preflight requests through to a custom handler:

js

```js
await fastify.register(cors, {
  preflightContinue: true,
  strictPreflight: false
})

fastify.options('/data', async (request, reply) => {
  // custom preflight handling
  reply.status(204).send()
})
```

**Key Points:**

- `preflightContinue: true` is rarely needed — the default auto-handling is sufficient for most cases.
- `hideOptionsRoute: true` (default) suppresses auto-generated OPTIONS routes from Swagger/OpenAPI output, keeping API docs clean.

---

### Debugging CORS Issues

Common failure modes and their causes:

| Symptom | Likely Cause |
| --- | --- |
| `No 'Access-Control-Allow-Origin' header` | Origin not in allowlist; `origin: false` |
| Preflight returns `400` | `strictPreflight: true` and missing headers |
| Credentialed request blocked | `origin: '*'` with `credentials: true` |
| Custom response header unreadable | Header not in `exposedHeaders` |
| Preflight succeeds but actual request fails | Auth guard rejecting `OPTIONS` before CORS handler runs |
| CORS works in dev but not production | Environment-specific origin mismatch |

#### Logging the Origin Decision

js

```js
await fastify.register(cors, {
  origin: (origin, callback) => {
    fastify.log.debug({ origin }, 'CORS origin check')
    const allowed = origin === 'https://app.example.com'
    fastify.log.debug({ allowed }, 'CORS decision')
    callback(null, allowed)
  }
})
```

---

### CORS and Auth Guards — Hook Order

A common issue: auth hooks running before CORS headers are set, causing preflight `OPTIONS` requests to fail with `401`:

No token on preflightOPTIONS PreflightonRequest: JWT verify401 UnauthorizedBrowser blocks actualrequest

**Resolution — exempt OPTIONS from auth:**

js

```js
fastify.addHook('onRequest', async (request, reply) => {
  if (request.method === 'OPTIONS') return  // let CORS handle preflight

  try {
    await request.jwtVerify()
  } catch {
    return reply.status(401).send({ error: 'Unauthorized' })
  }
})
```

Or scope the auth hook to exclude preflight at the decorator level:

js

```js
fastify.decorate('authenticate', async function (request, reply) {
  if (request.method === 'OPTIONS') return
  await request.jwtVerify()
})
```

**Key Points:**

- CORS preflight requests do not carry credentials or auth tokens — auth guards must not reject them.
- `@fastify/cors` processes its hook early, but hook registration order can affect whether CORS headers appear on a `401` response. [Inference] Register `@fastify/cors` before auth plugins to help it run first.
- If a `401` response lacks `Access-Control-Allow-Origin`, the browser reports a CORS error rather than an auth error, which can obscure debugging.

---

### Minimal Production-Ready Example

js

```js
import Fastify from 'fastify'
import cors from '@fastify/cors'

const fastify = Fastify({ logger: true })

const allowedOrigins = (process.env.CORS_ORIGINS ?? '').split(',').filter(Boolean)

await fastify.register(cors, {
  origin: (origin, cb) => {
    if (!origin || allowedOrigins.includes(origin)) return cb(null, true)
    cb(new Error('Origin not allowed'), false)
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count', 'X-Request-ID'],
  maxAge: 86400
})

fastify.get('/data', async () => ({ hello: 'world' }))

await fastify.listen({ port: 3000 })
```

---

### Security Considerations

- Never use `origin: '*'` with `credentials: true` — it is both a browser-rejected configuration and a potential security risk if somehow bypassed.
- Allowlist specific origins explicitly in production — wildcard origins disable a meaningful browser-enforced security boundary.
- CORS does not protect against server-side request forgery (SSRF), direct API access from non-browser clients, or attacks that originate from allowed origins.
- Do not rely on CORS as a primary security control — it supplements, but does not replace, authentication and authorization.
- Restrict `allowedHeaders` to the minimum set your API actually requires — reflecting all headers by default is permissive.
- Validate that your CORS origin function handles `undefined` origin (same-origin or non-browser requests) explicitly — treat it as trusted or untrusted based on your threat model.
- Rotate and review allowed origin lists when decommissioning client applications or partner integrations.

---

**Related Topics:**

- `@fastify/helmet` for complementary security headers (CSP, HSTS, X-Frame-Options)
- Coordinating CORS with `@fastify/jwt` auth hooks
- Per-route CORS with scoped plugin registration
- CORS behavior differences across browsers
- CSRF protection with `@fastify/csrf-protection`
- Reverse proxy CORS header forwarding (nginx, AWS ALB)
- OpenAPI/Swagger and CORS header documentation