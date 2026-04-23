# express-rate-limit — Comprehensive Guide

`express-rate-limit` is a middleware package for Express.js applications that counts incoming requests per client and rejects requests that exceed a configured threshold. It is published on npm and maintained as an open-source project.

---

## Installation

```bash
npm install express-rate-limit
```

For older Node.js environments or CommonJS-only projects, confirm that your Node.js version meets the package's peer dependency requirements before installing. As of the v6/v7 generation, the package ships as an ES module with a CommonJS compatibility layer.

---

## Basic Usage

The simplest setup applies a single rate limiter to all routes:

```js
import rateLimit from 'express-rate-limit';
import express from 'express';

const app = express();

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  limit: 100,                // max requests per window per IP
});

app.use(limiter);
```

`rateLimit()` returns a standard Express middleware function. You can mount it globally with `app.use()`, apply it to a router, or attach it to individual route handlers.

---

## Configuration Options

### windowMs

Type: `number`  
Default: `60000` (1 minute)

The duration of the rate-limiting window in milliseconds. After the window expires, the request count for a client resets.

```js
windowMs: 15 * 60 * 1000  // 15-minute window
```

### limit

Type: `number | function`  
Default: `5`

The maximum number of requests allowed per client within a single window. Can be a static number or a function that receives `(req, res)` and returns a number (or a Promise resolving to one), allowing per-route or per-user limits.

```js
limit: 100

// Dynamic
limit: (req, res) => req.user?.isPremium ? 1000 : 100
```

> **Note:** In v6 and earlier, this option was called `max`. The `max` alias still works in current versions but `limit` is the preferred name.

### message

Type: `string | object | function`  
Default: `'Too many requests, please try again later.'`

The response body sent when the limit is exceeded. Pass an object to respond with JSON, or a function `(req, res) => value` for dynamic responses.

```js
message: { error: 'Rate limit exceeded. Try again in 15 minutes.' }
```

### statusCode

Type: `number`  
Default: `429`

The HTTP status code returned when the limit is exceeded. `429 Too Many Requests` is the standard; changing this is generally not recommended unless an upstream system requires a different code.

### handler

Type: `function`  
Default: internal handler that sends `statusCode` and `message`

A custom Express handler `(req, res, next, options)` called when the limit is exceeded. Overrides both `message` and `statusCode` if provided.

```js
handler: (req, res, next, options) => {
  res.status(options.statusCode).json({
    error: 'Too many requests',
    retryAfter: Math.ceil(options.windowMs / 1000),
  });
}
```

### keyGenerator

Type: `function`  
Default: uses `req.ip`

A function `(req, res) => string` that returns a unique key for the client. The default uses the request's IP address. Override this to key by user ID, API token, or any other identifier.

```js
keyGenerator: (req) => req.headers['x-api-key'] ?? req.ip
```

### skip

Type: `function`  
Default: `() => false`

A function `(req, res) => boolean` (or Promise) that, when it returns `true`, bypasses rate limiting entirely for that request.

```js
skip: (req) => req.ip === '127.0.0.1'
```

### skipSuccessfulRequests

Type: `boolean`  
Default: `false`

When `true`, only failed requests (responses with status >= 400) count toward the limit. Successful responses are not counted.

### skipFailedRequests

Type: `boolean`  
Default: `false`

When `true`, only successful requests (responses with status < 400) count. Failed requests are not counted.

### requestWasSuccessful

Type: `function`  
Default: `(req, res) => res.statusCode < 400`

Determines what counts as "successful" for the `skipSuccessfulRequests` and `skipFailedRequests` options. Override if your API uses non-standard status codes to indicate failure.

### standardHeaders

Type: `boolean | string`  
Default: `'draft-7'` (as of v7)

Controls which rate limit headers are sent in responses. Accepted values:

- `false` — no rate limit headers
- `'draft-6'` — sends `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`
- `'draft-7'` — sends a combined `RateLimit` header per the IETF draft-7 specification
- `true` — alias for `'draft-6'` in older versions; behavior may differ by version

### legacyHeaders

Type: `boolean`  
Default: `false` (as of v7)

When `true`, sends the older `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and `X-RateLimit-Reset` headers. These are non-standard but widely supported by client libraries and proxies.

### store

Type: `Store`  
Default: `MemoryStore` (built-in)

The backing store used to track request counts. See the Stores section for details.

### requestPropertyName

Type: `string`  
Default: `'rateLimit'`

The property added to `req` that exposes rate limit info (`limit`, `used`, `remaining`, `resetTime`) to downstream middleware and route handlers.

```js
app.get('/status', (req, res) => {
  res.json(req.rateLimit);
});
```

---

## Response Headers

By default (v7+), `express-rate-limit` sends standard IETF headers so clients know their current quota. With `standardHeaders: 'draft-7'`:

```
RateLimit: limit=100, remaining=87, reset=1713600000
```

With `legacyHeaders: true`:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1713600000
Retry-After: 900
```

The `Retry-After` header is automatically included in the response when the limit is exceeded.

---

## Stores

The store is responsible for persisting and incrementing request counts. By default, `express-rate-limit` uses a built-in `MemoryStore`.

### MemoryStore (default)

Counts are kept in process memory. This is appropriate for single-process, single-server deployments. It does not share state across multiple server instances or worker processes.

```js
import { MemoryStore } from 'express-rate-limit';

rateLimit({
  store: new MemoryStore(),
});
```

### External Stores

For multi-instance deployments, you need an external store. Several community-maintained stores are available as separate packages:

- `rate-limit-redis` — backed by Redis
- `rate-limit-mongo` — backed by MongoDB
- `rate-limit-postgresql` — backed by PostgreSQL
- `rate-limit-memcached` — backed by Memcached
- `@express-rate-limit/precise-memory-rate-limit` — alternative memory store

Each store must implement the `Store` interface: `increment`, `decrement`, `resetKey`, and optionally `resetAll` methods.

### Custom Store

You can implement your own store by satisfying the interface:

```js
const customStore = {
  async increment(key) {
    // Atomically increment and return { totalHits, resetTime }
  },
  async decrement(key) {
    // Decrement count for key
  },
  async resetKey(key) {
    // Clear count for key
  },
};
```

---

## Applying Limiters to Specific Routes

Rather than applying one limiter globally, you can create multiple limiters with different configurations for different routes:

```js
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 200,
});

const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,  // 1 hour
  limit: 10,
  message: 'Too many login attempts. Please try again in an hour.',
});

const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 30,
});

app.use(globalLimiter);
app.post('/auth/login', authLimiter, loginHandler);
app.use('/api', apiLimiter);
```

---

## Working Behind a Proxy

When your Express app runs behind a reverse proxy (nginx, Cloudflare, a load balancer, etc.), `req.ip` may resolve to the proxy's IP rather than the real client IP. To pass through the correct IP, configure Express's trust proxy setting:

```js
// Trust the first hop (e.g. one nginx in front of your app)
app.set('trust proxy', 1);
```

For multiple proxy layers, set the number to match the number of trusted hops, or provide a specific IP/subnet string. Incorrect proxy trust settings can allow clients to spoof their IP by setting a fake `X-Forwarded-For` header.

> The `express-rate-limit` documentation recommends reviewing the Express `trust proxy` documentation carefully before deploying behind a proxy, as misconfiguration is a common source of the limiter applying to all traffic identically or being trivially bypassed.

---

## Programmatic Access to Rate Limit State

The rate limit info for a request is attached to `req` under `req.rateLimit` (or the name set by `requestPropertyName`):

```js
app.get('/quota', (req, res) => {
  const { limit, used, remaining, resetTime } = req.rateLimit;
  res.json({ limit, used, remaining, resetTime });
});
```

You can also reset a specific key programmatically using the store's `resetKey` method:

```js
// After a user successfully completes CAPTCHA, reset their login limiter
await authLimiter.resetKey(req.ip);
```

---

## Using a Dynamic Limit Based on Request Context

The `limit` option accepts a function, which makes it straightforward to vary the limit based on authentication status, subscription tier, or any other context:

```js
rateLimit({
  windowMs: 60 * 1000,
  limit: async (req) => {
    if (!req.user) return 20;
    const tier = await getUserTier(req.user.id);
    return tier === 'premium' ? 500 : 100;
  },
});
```

[Inference] The function is called on every request, so expensive lookups should be cached. Behavior of the async path is not guaranteed to be consistent across all store implementations — test with your specific store.

---

## Combining with Other Middleware

`express-rate-limit` is designed to work alongside other Express middleware. Common patterns:

**With `helmet`:**

```js
import helmet from 'helmet';
app.use(helmet());
app.use(limiter);
```

**With `express-slow-down`** (progressive delay instead of hard rejection):

```js
import slowDown from 'express-slow-down';

const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000,
  delayAfter: 50,
  delayMs: (used) => (used - 50) * 100,
});

app.use(speedLimiter);
app.use(limiter);
```

Both limiters share the same `keyGenerator` and can optionally share the same store instance.

---

## TypeScript Support

`express-rate-limit` ships with TypeScript type definitions. No `@types` package is required:

```ts
import rateLimit, { Options, RateLimitInfo } from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 100,
} satisfies Partial<Options>);

// Augment the Express Request type to include rateLimit
declare global {
  namespace Express {
    interface Request {
      rateLimit: RateLimitInfo;
    }
  }
}
```

---

## Testing

When writing tests, you may want to:

- Use a fresh `MemoryStore` instance per test to avoid state leakage.
- Set a very short `windowMs` (e.g. 100ms) so you can test limit-exceeded behavior without sleeping long.
- Pass `skip: () => true` in test environments to disable limiting entirely.

```js
const testLimiter = rateLimit({
  windowMs: 100,
  limit: 3,
  store: new MemoryStore(),
});
```

---

## Common Mistakes and Pitfalls

**Using MemoryStore in a clustered or multi-process deployment.** Each process maintains its own counter, so the effective limit is `limit × numberOfProcesses`. Use an external shared store for multi-process setups.

**Forgetting to set `trust proxy`.** If `req.ip` always resolves to the same IP (often `::1` or the proxy's address), all clients share one counter and the limit fires for everyone simultaneously.

**Setting `windowMs` too short for the use case.** Very short windows (under 1 second) can produce high contention in external stores, particularly Redis, under load.

**Relying on IP-based limiting alone for authenticated routes.** A single user behind NAT or a shared IP may be blocked by another user's traffic. Keying by authenticated user ID (`keyGenerator: (req) => req.user?.id ?? req.ip`) is more appropriate for routes that require authentication.

**Not handling the `Retry-After` header on the client side.** Clients that ignore `Retry-After` and immediately retry will continue to consume quota and may loop indefinitely.

---

## Version Migration Notes

### v6 to v7

- `max` was renamed to `limit`. The `max` alias still works but triggers a deprecation warning.
- `standardHeaders` default changed from `false` to `'draft-7'`.
- `legacyHeaders` default changed from `true` to `false`.
- The package became a pure ES module. CommonJS interop (`require()`) still functions via the compatibility layer, but explicit `.cjs` imports may be needed in some bundler configurations.

### v5 to v6

- The store API changed. Third-party stores written for v5 are not compatible with v6+ without updates. Check the store package's changelog before upgrading.

---

## Full Configuration Reference

|Option|Type|Default|Description|
|---|---|---|---|
|`windowMs`|number|60000|Window duration in ms|
|`limit`|number \| fn|5|Max requests per window|
|`message`|string \| object \| fn|`'Too many requests…'`|Response body on limit exceeded|
|`statusCode`|number|429|HTTP status on limit exceeded|
|`handler`|function|internal|Custom handler on limit exceeded|
|`keyGenerator`|function|`req.ip`|Client identifier function|
|`skip`|function|`() => false`|Skip rate limiting for a request|
|`skipSuccessfulRequests`|boolean|false|Only count failed requests|
|`skipFailedRequests`|boolean|false|Only count successful requests|
|`requestWasSuccessful`|function|`res.statusCode < 400`|Success definition|
|`standardHeaders`|boolean \| string|`'draft-7'`|IETF standard headers|
|`legacyHeaders`|boolean|false|X-RateLimit-* headers|
|`store`|Store|MemoryStore|Backing store|
|`requestPropertyName`|string|`'rateLimit'`|Property name on `req`|

---

## Resources

- npm: https://www.npmjs.com/package/express-rate-limit
- GitHub: https://github.com/express-rate-limit/express-rate-limit
- IETF RateLimit Headers Draft: https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-ratelimit-headers

---

_This document reflects the publicly documented behavior of `express-rate-limit`. Any claims about runtime behavior are [Inference] unless sourced from the official documentation. Behavior is not guaranteed and may vary by version, store implementation, and environment._