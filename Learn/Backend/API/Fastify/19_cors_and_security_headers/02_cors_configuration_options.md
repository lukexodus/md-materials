## CORS Configuration Options

### Overview

`@fastify/cors` exposes a configuration surface that controls every aspect of the CORS response — which origins are permitted, which methods and headers are allowed, how long preflight results are cached, and whether credentials travel with requests. This topic covers every option in depth: accepted value types, behavioral nuances, interaction effects between options, and the HTTP headers each option produces.

---

### How Options Map to HTTP Headers

originAccess-Control-Allow-OrigincredentialsAccess-Control-Allow-CredentialsmethodsAccess-Control-Allow-MethodsallowedHeadersAccess-Control-Allow-HeadersexposedHeadersAccess-Control-Expose-HeadersmaxAgeAccess-Control-Max-Age

---

### `origin`

Controls the value of `Access-Control-Allow-Origin` in the response.

#### `false` — Block All Cross-Origin Requests (default)

js

```js
await fastify.register(cors, { origin: false })
```

No `Access-Control-Allow-Origin` header is added. Browsers block all cross-origin responses.

---

#### `true` — Reflect Request Origin

js

```js
await fastify.register(cors, { origin: true })
```

Reflects the incoming `Origin` header back as the allowed origin:

```
Access-Control-Allow-Origin: https://whatever-origin-sent.com
```

**Key Points:**

- Functionally permits all origins.
- Unlike `'*'`, reflection is compatible with `credentials: true` because the browser receives a specific origin, not a wildcard.
- [Inference] Use only in fully public, unauthenticated APIs where any origin is genuinely acceptable.

---

#### `'*'` — Wildcard

js

```js
await fastify.register(cors, { origin: '*' })
```

```
Access-Control-Allow-Origin: *
```

**Key Points:**

- Incompatible with `credentials: true` — browsers reject credentialed responses with a wildcard origin.
- Does not support the `Vary: Origin` header — caching intermediaries treat all origins identically.
- Prefer `origin: true` (reflection) over `'*'` in most cases — it is equally permissive but credentials-compatible.

---

#### String — Single Explicit Origin

js

```js
await fastify.register(cors, {
  origin: 'https://app.example.com'
})
```

```
Access-Control-Allow-Origin: https://app.example.com
Vary: Origin
```

**Key Points:**

- `Vary: Origin` is added automatically when a specific origin is set — this tells CDNs and proxies that the response differs per origin, preventing cross-origin cache poisoning.
- The comparison is exact — `http://app.example.com` and `https://app.example.com` are different origins. Protocol, hostname, and port must all match.

---

#### Array — Multiple Explicit Origins

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

**Behavior:**

- `@fastify/cors` checks the request's `Origin` against each entry in turn.
- If a match is found, that origin is reflected back.
- If no match, no `Access-Control-Allow-Origin` header is set.

**Key Points:**

- Array entries can be strings or `RegExp` instances — mixed arrays are supported.
- `Vary: Origin` is set regardless of whether the origin matched.

---

#### RegExp — Pattern Matching

js

```js
await fastify.register(cors, {
  origin: /^https:\/\/[\w-]+\.example\.com$/
})
```

Allows any subdomain of `example.com` over HTTPS.

js

```js
// Multiple patterns in an array
await fastify.register(cors, {
  origin: [
    /^https:\/\/[\w-]+\.example\.com$/,
    /^https:\/\/[\w-]+\.partner\.io$/,
    'https://specific-origin.com'
  ]
})
```

**Key Points:**

- The pattern is tested with `RegExp.prototype.test(origin)`.
- Anchoring patterns (`^` and `$`) is important — an unanchored pattern like `/example\.com/` matches `https://evil-example.com` as well. [Inference]
- Test regex patterns carefully — overly broad patterns can inadvertently allow unintended origins.

---

#### Function — Dynamic Per-Request Logic

Synchronous callback form:

js

```js
await fastify.register(cors, {
  origin: (origin, callback) => {
    if (!origin) return callback(null, true)  // non-browser / same-origin

    const allowed = checkAllowlist(origin)
    if (allowed) {
      callback(null, true)
    } else {
      callback(new Error('Origin not permitted'), false)
    }
  }
})
```

Async form:

js

```js
await fastify.register(cors, {
  origin: async (origin) => {
    if (!origin) return true
    return await db.allowedOrigins.has(origin)
  }
})
```

**Key Points:**

- `origin` is `undefined` for same-origin requests and requests from non-browser clients (curl, server-to-server).
- Returning or calling `callback(null, true)` allows the origin — the actual origin string is reflected back.
- Returning or calling `callback(error, false)` denies the origin — no CORS headers are set, and `@fastify/cors` does not send the error itself.
- [Inference] Async origin functions should handle DB or cache failures gracefully — an unhandled rejection may result in a 500 instead of a 403/no-header response.

---

### `methods`

Controls `Access-Control-Allow-Methods` in preflight responses.

js

```js
await fastify.register(cors, {
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS']
})
```

```
Access-Control-Allow-Methods: GET,POST,PUT,PATCH,DELETE,OPTIONS
```

Also accepts a comma-separated string:

js

```js
methods: 'GET,POST,PUT,PATCH,DELETE'
```

**Key Points:**

- Default is `GET,HEAD,PUT,PATCH,POST,DELETE` — `OPTIONS` is not included by default since `@fastify/cors` handles it internally.
- Preflight requests for methods not listed will fail — the browser blocks the subsequent actual request.
- `HEAD` is safe to include alongside `GET` — it shares semantics and rarely causes issues.
- `CONNECT`, `TRACE`, and `TRACK` are forbidden methods — browsers will not send them regardless of this header. [Inference]

---

### `allowedHeaders`

Controls `Access-Control-Allow-Headers` — the headers a client is permitted to include in a cross-origin request.

js

```js
await fastify.register(cors, {
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID', 'X-API-Key']
})
```

```
Access-Control-Allow-Headers: content-type,authorization,x-request-id,x-api-key
```

Also accepts a comma-separated string:

js

```js
allowedHeaders: 'Content-Type,Authorization'
```

#### Default Behavior — Header Reflection

When `allowedHeaders` is not set, `@fastify/cors` reflects whatever the preflight sends in `Access-Control-Request-Headers`:

```
// Preflight sends:
Access-Control-Request-Headers: authorization, x-custom-header

// Response reflects:
Access-Control-Allow-Headers: authorization, x-custom-header
```

**Key Points:**

- Reflection is permissive — it allows any header the client requests. Restrict in security-sensitive environments.
- Always-allowed headers (the CORS safe list: `Accept`, `Accept-Language`, `Content-Language`, `Content-Type` with certain values) do not require explicit listing.
- Header names are case-insensitive per HTTP spec — `Authorization` and `authorization` are equivalent.
- If the client sends a preflight requesting a header not in `allowedHeaders`, the preflight fails and the browser blocks the request.

---

### `exposedHeaders`

Controls `Access-Control-Expose-Headers` — which response headers JavaScript can read on the client side.

js

```js
await fastify.register(cors, {
  exposedHeaders: ['X-Total-Count', 'X-Page', 'X-Per-Page', 'X-Request-ID', 'X-RateLimit-Remaining']
})
```

```
Access-Control-Expose-Headers: x-total-count,x-page,x-per-page,x-request-id,x-ratelimit-remaining
```

Also accepts a comma-separated string.

**Key Points:**

- Without this header, browser JavaScript can only access the CORS-safe response headers: `Cache-Control`, `Content-Language`, `Content-Length`, `Content-Type`, `Expires`, `Last-Modified`, `Pragma`.
- Custom headers (pagination counts, rate limit info, trace IDs) must be explicitly exposed to be readable via `response.headers.get('X-Total-Count')`.
- This header appears on actual responses, not just preflight responses.
- `exposedHeaders` does not affect server-side access — only browser-side JavaScript is restricted.

---

### `credentials`

Controls `Access-Control-Allow-Credentials`.

js

```js
await fastify.register(cors, {
  origin: 'https://app.example.com',
  credentials: true
})
```

```
Access-Control-Allow-Credentials: true
```

**Key Points:**

- Enables the browser to send cookies, HTTP authentication headers, and TLS client certificates with cross-origin requests.
- **Requires an explicit origin** — `credentials: true` with `origin: '*'` is a browser-rejected combination. Use a specific string, array, regex, or function instead.
- The client must also opt in — `fetch` requires `credentials: 'include'`; `axios` requires `withCredentials: true`.
- Setting this to `false` (the default) does not prevent the server from receiving cookies — it only prevents the browser from sending them with cross-origin requests. [Inference]

#### Interaction Matrix

| `origin` value | `credentials: true` | Result |
| --- | --- | --- |
| `'*'` | `true` | Browser rejects — invalid combination |
| `true` (reflect) | `true` | Works — specific origin reflected |
| String | `true` | Works — specific origin set |
| Array | `true` | Works — matched origin reflected |
| Function → `true` | `true` | Works — origin reflected |
| `false` | `true` | No CORS headers — moot |

---

### `maxAge`

Controls `Access-Control-Max-Age` — how long (in seconds) the browser caches preflight results.

js

```js
await fastify.register(cors, {
  maxAge: 86400  // 24 hours
})
```

```
Access-Control-Max-Age: 86400
```

**Key Points:**

- During the cache window, the browser skips the preflight `OPTIONS` request and sends the actual request directly — reduces latency for non-simple requests.
- Different browsers impose different maximum values — Chrome caps at 7200 seconds, Firefox at 86400 seconds. Values above the browser cap are silently clamped. [Unverified — browser behavior may change across versions]
- Setting `maxAge: 0` disables preflight caching — every non-simple request is preceded by a fresh preflight.
- Not setting `maxAge` means no `Access-Control-Max-Age` header is sent — browsers apply their own default (typically 5 seconds). [Unverified]
- Long `maxAge` values mean that changes to `methods` or `allowedHeaders` take time to propagate to clients — cached preflight results are not invalidated by server config changes.

---

### `preflight`

Controls whether `@fastify/cors` automatically handles `OPTIONS` requests.

js

```js
await fastify.register(cors, {
  preflight: false  // default: true
})
```

**Key Points:**

- `preflight: true` (default) — `@fastify/cors` registers an `onRequest` hook that intercepts all `OPTIONS` requests and responds with CORS headers and a `204`.
- `preflight: false` — `OPTIONS` requests are not automatically handled. Manual `OPTIONS` route definitions are required.
- [Inference] `preflight: false` is rarely needed — the default behavior is correct for the vast majority of applications. Use only when completely custom preflight handling is required.

---

### `preflightContinue`

Controls whether preflight requests are passed through to the next handler after CORS headers are set.

js

```js
await fastify.register(cors, {
  preflightContinue: true  // default: false
})

// Custom OPTIONS handler receives the request after CORS headers are set
fastify.options('/special-route', async (request, reply) => {
  // additional preflight logic
  return reply.status(204).send()
})
```

**Key Points:**

- `preflightContinue: false` (default) — CORS headers are set and the response is sent immediately. No further handlers run.
- `preflightContinue: true` — CORS headers are set but the request continues to the next matching handler. Useful for custom preflight logic on specific routes.
- When `preflightContinue: true`, the custom handler is responsible for sending the response — if it does not, the request hangs.

---

### `optionsSuccessStatus`

The HTTP status code returned for successful preflight responses.

js

```js
await fastify.register(cors, {
  optionsSuccessStatus: 200  // default: 204
})
```

**Key Points:**

- Default is `204 No Content` — the standard for preflight responses (no body, minimal overhead).
- Some older browsers (notably IE11) handle `200` better than `204` for `OPTIONS` requests. [Inference] Modern browsers handle `204` correctly — this option exists for legacy compatibility.
- `200` responses may include a body; `204` must not — aligning the status code with the actual response behavior avoids ambiguity.

---

### `strictPreflight`

Controls whether malformed preflight requests are rejected.

js

```js
await fastify.register(cors, {
  strictPreflight: false  // default: true
})
```

**Key Points:**

- `strictPreflight: true` (default) — `OPTIONS` requests missing `Origin` or `Access-Control-Request-Method` headers receive a `400 Bad Request`. These headers are required by the CORS spec for a valid preflight.
- `strictPreflight: false` — all `OPTIONS` requests are handled regardless of headers, responding with CORS headers and a `204`.
- [Inference] `strictPreflight: false` is useful for debugging or for handling non-standard clients that send `OPTIONS` without full preflight headers.

---

### `hideOptionsRoute`

Controls whether auto-generated `OPTIONS` routes appear in Swagger/OpenAPI output.

js

```js
await fastify.register(cors, {
  hideOptionsRoute: false  // default: true
})
```

**Key Points:**

- Default `true` — `OPTIONS` routes are hidden from `@fastify/swagger` documentation. This keeps API docs clean since preflight routes are an implementation detail, not API endpoints.
- Set to `false` only if there is a specific need to expose `OPTIONS` routes in the schema (rare). [Inference]

---

### Option Interactions and Common Combinations

#### Public Read-Only API

js

```js
await fastify.register(cors, {
  origin: '*',
  methods: ['GET', 'HEAD'],
  credentials: false,
  maxAge: 86400
})
```

#### Authenticated SPA — Single Origin

js

```js
await fastify.register(cors, {
  origin: 'https://app.example.com',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count', 'X-Request-ID'],
  maxAge: 3600
})
```

#### Multi-Tenant SaaS — Dynamic Origins

js

```js
await fastify.register(cors, {
  origin: async (origin) => {
    if (!origin) return true
    return db.tenants.isAllowedOrigin(origin)
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Tenant-ID'],
  exposedHeaders: ['X-Total-Count'],
  maxAge: 600  // short cache — origin list may change
})
```

#### Partner API — Subdomain Pattern

js

```js
await fastify.register(cors, {
  origin: [
    /^https:\/\/[\w-]+\.trusted-partner\.com$/,
    'https://direct-partner.io'
  ],
  credentials: false,
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'X-API-Key'],
  maxAge: 86400
})
```

#### Development — Permissive

js

```js
await fastify.register(cors, {
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: true,  // reflect all headers
  maxAge: 0
})
```

---

### Response Header Summary by Request Type

#### Simple Cross-Origin Request (no preflight)

```
Response headers set by @fastify/cors:
  Access-Control-Allow-Origin: https://app.example.com
  Access-Control-Allow-Credentials: true        (if credentials: true)
  Access-Control-Expose-Headers: X-Total-Count  (if exposedHeaders set)
  Vary: Origin
```

#### Preflight `OPTIONS` Request

```
Response headers set by @fastify/cors:
  Access-Control-Allow-Origin: https://app.example.com
  Access-Control-Allow-Methods: GET,POST,PUT,PATCH,DELETE
  Access-Control-Allow-Headers: content-type,authorization
  Access-Control-Allow-Credentials: true        (if credentials: true)
  Access-Control-Max-Age: 86400                 (if maxAge set)
  Vary: Origin
```

---

### `Vary: Origin` — Why It Matters

When the `origin` option is anything other than a static `'*'`, `@fastify/cors` adds `Vary: Origin` to responses:

```
Vary: Origin
```

**Key Points:**

- `Vary: Origin` tells CDNs, proxies, and browser caches that the response may differ depending on the `Origin` header.
- Without it, a cached response for `https://app.example.com` might be served to `https://other.com` with the wrong `Access-Control-Allow-Origin` value — causing CORS failures for legitimate requests or unintended access for illegitimate ones.
- `@fastify/cors` handles this automatically when using dynamic or multi-origin configurations. [Inference] If a reverse proxy strips or modifies this header, CORS behavior may become unpredictable.

---

### Security Considerations

- Restrict `origin` to the minimum set of origins your application genuinely serves — open CORS is a meaningful reduction in browser-enforced isolation.
- `origin: '*'` combined with `credentials: true` is both browser-rejected and indicative of a misconfiguration — avoid it.
- Anchor regex patterns carefully — `/example\.com/` matches `https://evil-example.com`. Use `^` and `$` anchors.
- Restrict `allowedHeaders` explicitly rather than relying on reflection — reflected headers permit any header the client claims to need.
- Keep `maxAge` values moderate — very long cache windows mean that tightening CORS policy takes time to reach all clients.
- Dynamic `origin` functions that query a database introduce latency on every cross-origin request — consider an in-memory cache with a TTL for the allowlist. [Inference]
- Do not treat CORS as a security boundary on the server side — it is a browser-enforced hint. Server-side authentication and authorization remain necessary regardless of CORS configuration.

---

**Related Topics:**

- Per-scope CORS configuration using Fastify encapsulation
- Coordinating CORS with `@fastify/jwt` and `@fastify/cookie`
- `@fastify/helmet` for complementary HTTP security headers
- Reverse proxy CORS header handling (nginx, AWS ALB, Cloudflare)
- `Vary` header behavior in CDN caching (CloudFront, Fastly)
- CSRF protection and its relationship to CORS
- Browser CORS enforcement differences across Chrome, Firefox, and Safari