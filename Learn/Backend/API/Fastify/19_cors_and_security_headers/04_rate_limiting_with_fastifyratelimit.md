## Rate Limiting with @fastify/rate-limit

Rate limiting controls how many requests a client can make within a time window. Without it, a single client can exhaust server resources, degrade service for others, or conduct brute-force attacks. @fastify/rate-limit integrates directly with Fastify's plugin system and supports both in-memory and Redis-backed storage.

---

### How Rate Limiting Works

A rate limiter tracks request counts per identifier (typically IP address) within a sliding or fixed time window. When a client exceeds the configured limit, the server responds with `429 Too Many Requests` and optionally includes headers indicating when the client may retry.

Store (Memory/Redis)Fastify + rate-limitClientStore (Memory/Redis)Fastify + rate-limitClientalt[count <= limit][count > limit]RequestIncrement counter for client keyCurrent count200 OK (with RateLimit headers)429 Too Many Requests (with Retry-After)

---

### Installation

bash

```bash
npm install @fastify/rate-limit
```

For Redis-backed storage:

bash

```bash
npm install @fastify/rate-limit ioredis
```

---

### Basic Registration

js

```js
import Fastify from 'fastify'
import rateLimit from '@fastify/rate-limit'

const fastify = Fastify()

await fastify.register(rateLimit, {
  max: 100,        // Maximum requests per window
  timeWindow: '1 minute',
})

fastify.get('/', async () => {
  return { hello: 'world' }
})

await fastify.listen({ port: 3000 })
```

With this configuration, every client IP is limited to 100 requests per minute across all routes globally.

---

### Configuration Options

#### Core Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `max` | `number` | `function` | `1000` | Max requests per window |
| `timeWindow` | `string` | `number` | `60000` | Window duration (ms or human-readable) |
| `ban` | `number` | `null` | Bans client after N violations |
| `global` | `boolean` | `true` | Apply to all routes |
| `allowList` | `array` | `function` | `[]` | IPs or function to skip limiting |
| `keyGenerator` | `function` | IP-based | Custom key extraction |
| `errorResponseBuilder` | `function` | Default 429 | Custom error response shape |
| `enableDraftSpec` | `boolean` | `false` | Use IETF draft RateLimit headers |
| `addHeadersOnExceeding` | `object` | All `true` | Which headers to send under limit |
| `addHeaders` | `object` | All `true` | Which headers to send on limit exceeded |

#### `timeWindow` Formats

js

```js
timeWindow: 60000           // milliseconds
timeWindow: '1 minute'      // human-readable
timeWindow: '15 minutes'
timeWindow: '1 hour'
timeWindow: '1 day'
```

Human-readable strings are parsed by the `@fastify/rate-limit` package internally. [Inference: parsing uses a lightweight time-string utility — always verify supported formats in the version in use.]

---

### Response Headers

When a request is within the limit, @fastify/rate-limit adds informational headers:

```
x-ratelimit-limit: 100
x-ratelimit-remaining: 87
x-ratelimit-reset: 1718000000
```

When the limit is exceeded:

```
x-ratelimit-limit: 100
x-ratelimit-remaining: 0
x-ratelimit-reset: 1718000000
retry-after: 37
```

#### IETF Draft Spec Headers

Enable standardized headers (recommended for new APIs):

js

```js
await fastify.register(rateLimit, {
  max: 100,
  timeWindow: '1 minute',
  enableDraftSpec: true,
})
```

**Output headers:**

```
ratelimit-limit: 100
ratelimit-remaining: 87
ratelimit-reset: 37
retry-after: 37
```

---

### Per-Route Configuration

Override global settings on individual routes using the `config.rateLimit` option:

js

```js
await fastify.register(rateLimit, {
  global: true,
  max: 100,
  timeWindow: '1 minute',
})

// Tighter limit for auth endpoints
fastify.post('/login', {
  config: {
    rateLimit: {
      max: 5,
      timeWindow: '1 minute',
    },
  },
  handler: async (request, reply) => {
    return { token: 'signed-jwt' }
  },
})

// Relaxed limit for a public feed
fastify.get('/feed', {
  config: {
    rateLimit: {
      max: 500,
      timeWindow: '1 minute',
    },
  },
  handler: async () => {
    return { items: [] }
  },
})

// Disable rate limiting on a specific route
fastify.get('/healthcheck', {
  config: { rateLimit: false },
  handler: async () => ({ status: 'ok' }),
})
```

**Key Points:**

- `config.rateLimit: false` completely disables limiting for that route.
- Per-route limits are independent of the global counter — they maintain their own stores.

---

### Custom Key Generator

By default, the client identifier is the request IP. You can replace this with any value derived from the request — API key, user ID, tenant, or a composite.

js

```js
await fastify.register(rateLimit, {
  max: 200,
  timeWindow: '1 minute',
  keyGenerator: (request) => {
    // Use authenticated user ID when available, fall back to IP
    return request.user?.id ?? request.ip
  },
})
```

#### API Key-Based Limiting

js

```js
keyGenerator: (request) => {
  const apiKey = request.headers['x-api-key']
  if (apiKey) return `apikey:${apiKey}`
  return `ip:${request.ip}`
}
```

#### Tenant-Based Limiting

js

```js
keyGenerator: (request) => {
  return `tenant:${request.headers['x-tenant-id'] ?? request.ip}`
}
```

**Key Points:**

- The key must be a string.
- Keep keys consistent across restarts if using in-memory storage, otherwise counters reset.
- Avoid including sensitive values (passwords, tokens) directly in keys.

---

### Dynamic `max` via Function

`max` can be a function, allowing per-client or per-route limits resolved at request time:

js

```js
await fastify.register(rateLimit, {
  timeWindow: '1 minute',
  max: async (request, key) => {
    // Premium users get a higher limit
    if (request.user?.tier === 'premium') return 1000
    if (request.user?.tier === 'basic') return 200
    return 50  // Unauthenticated
  },
})
```

**Key Points:**

- The function receives the `request` object and the resolved `key`.
- Async functions are supported.
- The return value must be a number. [Inference: errors thrown inside the function may propagate as 500 responses — wrap in try/catch if the source is unreliable.]

---

### Allow List

Skip rate limiting for trusted IPs or conditions:

#### Static IP Allow List

js

```js
await fastify.register(rateLimit, {
  max: 100,
  timeWindow: '1 minute',
  allowList: ['127.0.0.1', '::1', '10.0.0.5'],
})
```

#### Dynamic Allow List Function

js

```js
await fastify.register(rateLimit, {
  max: 100,
  timeWindow: '1 minute',
  allowList: async (request, key) => {
    // Allow internal services presenting a shared secret
    return request.headers['x-internal-token'] === process.env.INTERNAL_TOKEN
  },
})
```

**Key Points:**

- When `allowList` returns `true`, the request bypasses counting entirely — no headers are added.
- Async functions are supported.

---

### Redis-Backed Storage

In-memory storage does not share state across multiple Fastify instances. For horizontally scaled deployments, use Redis.

js

```js
import Fastify from 'fastify'
import rateLimit from '@fastify/rate-limit'
import Redis from 'ioredis'

const fastify = Fastify()

const redis = new Redis({ host: 'localhost', port: 6379 })

await fastify.register(rateLimit, {
  max: 100,
  timeWindow: '1 minute',
  redis,
})
```

**Key Points:**

- The `redis` option accepts an `ioredis` client instance.
- All Fastify instances sharing the same Redis instance share rate limit counters.
- Redis connection failures may affect request handling — implement appropriate error handling and circuit-breaking at the Redis client level.
- [Inference: @fastify/rate-limit does not automatically fall back to in-memory storage on Redis failure. Behavior may vary by version.]

#### Redis Cluster

js

```js
import { Cluster } from 'ioredis'

const redis = new Cluster([
  { host: 'redis-node-1', port: 6379 },
  { host: 'redis-node-2', port: 6379 },
])

await fastify.register(rateLimit, { max: 100, timeWindow: '1 minute', redis })
```

---

### Banning Repeat Violators

The `ban` option tracks how many times a client has exceeded the limit. After `ban` violations, the server responds with `403 Forbidden` instead of `429`.

js

```js
await fastify.register(rateLimit, {
  max: 10,
  timeWindow: '1 minute',
  ban: 3,  // After 3 rate-limit violations, ban the client
})
```

**Key Points:**

- The ban counter persists for the duration of the time window.
- A banned client receives `403`, not `429`.
- [Inference: ban state is stored in the same store as the counter — in-memory bans do not persist across restarts or instances.]

---

### Custom Error Response

Replace the default 429 response body with a structure that fits your API:

js

```js
await fastify.register(rateLimit, {
  max: 100,
  timeWindow: '1 minute',
  errorResponseBuilder: (request, context) => {
    return {
      statusCode: 429,
      error: 'Too Many Requests',
      message: `Rate limit exceeded. Try again in ${context.after}.`,
      retryAfter: context.after,
      limit: context.max,
    }
  },
})
```

**Available `context` properties:**

| Property | Description |
| --- | --- |
| `context.after` | Human-readable time until reset (e.g., `"37 seconds"`) |
| `context.max` | The configured maximum |
| `context.ttl` | Time-to-live in milliseconds |

---

### Controlling Which Headers Are Sent

Fine-tune header emission for both normal and exceeded states:

js

```js
await fastify.register(rateLimit, {
  max: 100,
  timeWindow: '1 minute',
  addHeadersOnExceeding: {
    'x-ratelimit-limit': true,
    'x-ratelimit-remaining': true,
    'x-ratelimit-reset': true,
  },
  addHeaders: {
    'x-ratelimit-limit': true,
    'x-ratelimit-remaining': true,
    'x-ratelimit-reset': true,
    'retry-after': true,
  },
})
```

Set any header to `false` to suppress it.

---

### Rate Limiting in Plugins and Scoped Contexts

@fastify/rate-limit respects Fastify's encapsulation model. Registering it within a scoped plugin applies it only to that scope:

js

```js
fastify.register(async (scope) => {
  await scope.register(rateLimit, {
    max: 10,
    timeWindow: '1 minute',
  })

  scope.post('/login', async (request, reply) => {
    return { token: '...' }
  })

  scope.post('/register', async (request, reply) => {
    return { user: '...' }
  })
}, { prefix: '/auth' })

// Routes outside this scope are not rate limited by the above
fastify.get('/public', async () => ({ data: '...' }))
```

---

### Handling Proxies and Forwarded IPs

When Fastify runs behind a reverse proxy (nginx, Caddy, AWS ALB), the client IP seen by Fastify may be the proxy's IP rather than the real client. Use Fastify's `trustProxy` option:

js

```js
const fastify = Fastify({ trustProxy: true })
```

With `trustProxy: true`, Fastify reads the real IP from `X-Forwarded-For`. @fastify/rate-limit then uses this value in its default key generator.

**Key Points:**

- Only enable `trustProxy` if your deployment guarantees a trusted proxy sets `X-Forwarded-For`. Clients can spoof this header if there is no proxy stripping it upstream.
- [Inference: in environments where the header can be spoofed, IP-based rate limiting is weakened — prefer API key or authenticated user ID as the key generator in those cases.]

---

### Combining with Authentication

A common pattern: apply a loose global limit, then tighter per-route limits on sensitive endpoints, using authenticated identity as the key:

js

```js
await fastify.register(rateLimit, {
  global: true,
  max: 300,
  timeWindow: '1 minute',
  keyGenerator: (request) => request.user?.id ?? request.ip,
})

fastify.post('/password-reset', {
  config: {
    rateLimit: { max: 3, timeWindow: '15 minutes' },
  },
  preHandler: fastify.auth([fastify.verifyJWT]),
  handler: async (request, reply) => {
    // ...
  },
})
```

---

### Testing Rate Limits

Inject requests programmatically using Fastify's built-in test helper:

js

```js
import { test } from 'node:test'
import assert from 'node:assert'
import Fastify from 'fastify'
import rateLimit from '@fastify/rate-limit'

test('returns 429 after limit exceeded', async (t) => {
  const app = Fastify()

  await app.register(rateLimit, { max: 2, timeWindow: 1000 })

  app.get('/', async () => ({ ok: true }))
  await app.ready()

  await app.inject({ method: 'GET', url: '/' })  // 1st
  await app.inject({ method: 'GET', url: '/' })  // 2nd

  const res = await app.inject({ method: 'GET', url: '/' })  // 3rd — should be blocked

  assert.strictEqual(res.statusCode, 429)
})
```

**Key Points:**

- `app.inject` simulates real requests without starting a TCP server.
- In-memory storage is used by default in tests, so counters reset per `Fastify()` instance.
- Time-window testing may require mocking `Date.now` or using small `timeWindow` values.

---

### Common Pitfalls

#### Global Flag Not Disabling Routes Correctly

If `global: true` (default) and a route sets `config.rateLimit: false`, the route-level config takes precedence. If `global: false`, routes receive no limiting unless explicitly configured. Mixing these without awareness leads to unexpected open or over-limited routes.

#### In-Memory State Lost on Restart

In-memory counters reset when the process restarts. Under normal operation this is acceptable, but during rolling deployments or crash loops, clients may effectively get their window reset. Use Redis for persistence across restarts if this matters.

#### IP Spoofing Without `trustProxy`

Without `trustProxy: true`, all requests from behind a proxy share the proxy's IP as the key — effectively one counter for all clients. With it enabled carelessly, clients can spoof `X-Forwarded-For`.

#### Miscounting with Multiple Fastify Instances

Without a shared Redis store, each instance maintains its own counter. A client hitting 3 instances gets 3× the configured limit effectively. Always use Redis in multi-instance deployments.

---

**Related Topics:**

- Redis integration with ioredis in Fastify — connection management, clustering, and error handling
- `@fastify/helmet` — layering security headers alongside rate limiting
- Authentication and JWT with `@fastify/jwt` — using authenticated identity as a rate limit key
- Fastify plugin encapsulation — scoping rate limits to specific route prefixes
- Brute-force protection strategies — combining rate limiting with account lockout logic
- Circuit breakers and resilience patterns — protecting downstream dependencies
- Monitoring rate limit metrics — exposing counters to Prometheus or similar observability tools