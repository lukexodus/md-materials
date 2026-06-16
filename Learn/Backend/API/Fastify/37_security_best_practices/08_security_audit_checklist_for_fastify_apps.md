## Security Audit Checklist for Fastify Apps

A security audit for a Fastify application covers configuration, authentication, input handling, dependency hygiene, transport security, logging, and runtime behavior. This checklist is organized by domain. Each item describes what to verify and why it matters.

---

### Transport Security

| # | Check | What to Verify |
| --- | --- | --- |
| 1 | HTTPS enforced | TLS is terminated at the app or upstream proxy; HTTP requests are redirected or rejected |
| 2 | TLS version | TLS 1.2 minimum; TLS 1.3 preferred; SSLv3/TLS 1.0/1.1 disabled |
| 3 | Certificate validity | Cert is not expired, covers the correct domain, and is from a trusted CA |
| 4 | HSTS header present | `Strict-Transport-Security` is set with an appropriate `max-age` |
| 5 | Secure cookies | All cookies use `Secure`, `HttpOnly`, and `SameSite` flags |

**Example — Redirect HTTP to HTTPS with `@fastify/http-proxy` or at the route level:**

js

```js
fastify.addHook('onRequest', async (request, reply) => {
  if (request.headers['x-forwarded-proto'] === 'http') {
    const httpsUrl = `https://${request.hostname}${request.url}`
    return reply.redirect(301, httpsUrl)
  }
})
```

[Inference] If your app sits behind a reverse proxy (Nginx, AWS ALB), TLS termination may happen upstream. Verify that `x-forwarded-proto` is set by the proxy and trusted by Fastify via `trustProxy`. Behavior depends on your infrastructure configuration.

---

### HTTP Security Headers

| # | Check | What to Verify |
| --- | --- | --- |
| 6 | `@fastify/helmet` installed | Helmet sets secure defaults for a broad set of headers |
| 7 | `Content-Security-Policy` | CSP is configured and not left at the default `*` |
| 8 | `X-Content-Type-Options` | Set to `nosniff` |
| 9 | `X-Frame-Options` | Set to `DENY` or `SAMEORIGIN` |
| 10 | `Referrer-Policy` | Set to `no-referrer` or `strict-origin-when-cross-origin` |
| 11 | Server header suppressed | Fastify's default `server` header is removed or replaced |

**Example — Helmet with a custom CSP:**

js

```js
await fastify.register(import('@fastify/helmet'), {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
})
```

**Example — Remove the `server` header:**

js

```js
fastify.addHook('onSend', async (request, reply) => {
  reply.removeHeader('server')
})
```

---

### Authentication

| # | Check | What to Verify |
| --- | --- | --- |
| 12 | Auth applied to all protected routes | No protected route is reachable without a valid authentication hook |
| 13 | JWT secret strength | Secrets are at minimum 256-bit random values; not hardcoded |
| 14 | JWT algorithm pinned | `algorithm` is explicitly set; `none` algorithm is rejected |
| 15 | Token expiry enforced | `exp` claim is verified; short-lived tokens are preferred |
| 16 | Refresh token rotation | Refresh tokens are single-use and invalidated after rotation |
| 17 | Session fixation prevented | New session IDs are issued after login |
| 18 | Logout invalidates token | Token blacklist or short expiry strategy is in place |

**Example — Pin algorithm in `@fastify/jwt`:**

js

```js
await fastify.register(import('@fastify/jwt'), {
  secret: process.env.JWT_SECRET,
  sign: { algorithm: 'HS256', expiresIn: '15m' },
  verify: { algorithms: ['HS256'] }, // reject all other algorithms
})
```

[Inference] Whether token blacklisting fully covers logout depends on your storage backend and TTL strategy. Behavior is not guaranteed without explicit testing.

---

### Authorization

| # | Check | What to Verify |
| --- | --- | --- |
| 19 | Role checks per route | Each sensitive route verifies the caller's role, not just their identity |
| 20 | IDOR prevention | Resource ownership is validated; users cannot access other users' resources by changing an ID |
| 21 | Privilege escalation paths | No route allows a user to self-assign elevated roles |
| 22 | Least privilege scoping | Auth hooks are scoped; no unnecessary global hooks on public routes |
| 23 | Admin routes isolated | Admin endpoints are in a separate encapsulated scope with stricter controls |

**Example — IDOR check:**

js

```js
fastify.get('/orders/:orderId', {
  onRequest: [fastify.authenticate],
}, async (request, reply) => {
  const order = await getOrder(request.params.orderId)

  if (order.userId !== request.user.id) {
    return reply.code(403).send({ error: 'Forbidden' })
  }

  return order
})
```

---

### Input Validation

| # | Check | What to Verify |
| --- | --- | --- |
| 24 | JSON Schema on all routes | Every route with a body, params, querystring, or headers defines a schema |
| 25 | `additionalProperties: false` | Body schemas reject unexpected fields |
| 26 | String length limits | `maxLength` is set on all string inputs |
| 27 | Number bounds | `minimum` and `maximum` are set on numeric inputs where applicable |
| 28 | Enum constraints | Fields with a fixed set of values use `enum` |
| 29 | File upload limits | `Content-Length` limits and multipart field size caps are enforced |
| 30 | Content-Type enforcement | Routes expecting JSON reject non-JSON content types |

**Example — Strict schema with length constraints:**

js

```js
fastify.post('/message', {
  schema: {
    body: {
      type: 'object',
      properties: {
        recipient: { type: 'string', format: 'email', maxLength: 254 },
        content: { type: 'string', maxLength: 2000 },
        priority: { type: 'string', enum: ['low', 'normal', 'high'] },
      },
      required: ['recipient', 'content'],
      additionalProperties: false,
    },
  },
}, async (request) => {
  return sendMessage(request.body)
})
```

---

### Output Handling

| # | Check | What to Verify |
| --- | --- | --- |
| 31 | Response schemas defined | `response` schemas are set to strip internal fields from output |
| 32 | No stack traces in production | Error handlers do not return `stack` properties to clients |
| 33 | No internal IDs leaked | Database primary keys or internal identifiers are not unnecessarily exposed |
| 34 | Error messages are generic | Auth failures return `401 Unauthorized`, not `"user not found"` vs `"wrong password"` |

**Example — Custom error handler that suppresses stack traces:**

js

```js
fastify.setErrorHandler((error, request, reply) => {
  const statusCode = error.statusCode ?? 500

  if (statusCode >= 500) {
    request.log.error(error) // log internally
    return reply.code(500).send({ error: 'Internal Server Error' })
  }

  return reply.code(statusCode).send({ error: error.message })
})
```

**Example — Response schema strips internal fields:**

js

```js
fastify.get('/user/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string' },
          email: { type: 'string' },
          // passwordHash, internalRole, etc. are omitted — they will not appear in output
        },
      },
    },
  },
}, async (request) => {
  return getUser(request.params.id) // returns full DB object; schema strips extras
})
```

---

### Rate Limiting and Abuse Prevention

| # | Check | What to Verify |
| --- | --- | --- |
| 35 | Rate limiting on auth routes | `/login`, `/register`, `/forgot-password` have strict per-IP limits |
| 36 | Global rate limiting configured | A baseline rate limit applies to all routes |
| 37 | Payload size limits | `bodyLimit` is set on the Fastify instance or per-route |
| 38 | Slowdown or lockout on repeated failures | Auth failures trigger increasing delays or temporary lockout [Speculation — depends on implementation] |

**Example — Set global `bodyLimit`:**

js

```js
const fastify = Fastify({
  bodyLimit: 1048576, // 1MB
})
```

**Example — Per-route rate limit:**

js

```js
fastify.post('/login', {
  config: {
    rateLimit: { max: 5, timeWindow: '1 minute' },
  },
}, async (request, reply) => {
  return attemptLogin(request.body)
})
```

---

### CORS Configuration

| # | Check | What to Verify |
| --- | --- | --- |
| 39 | CORS origin is not `*` in production | `origin: true` or `origin: '*'` is acceptable only for fully public APIs |
| 40 | Allowed methods are restricted | Only HTTP methods actually used are listed |
| 41 | Credentials mode is explicit | `credentials: true` is set only when cookies or auth headers are needed cross-origin |
| 42 | Preflight caching configured | `maxAge` is set to reduce preflight request overhead |

**Example — Restrictive CORS:**

js

```js
await fastify.register(import('@fastify/cors'), {
  origin: ['https://app.example.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true,
  maxAge: 86400,
})
```

---

### Dependency and Supply Chain

| # | Check | What to Verify |
| --- | --- | --- |
| 43 | `npm audit` passes | No high or critical severity vulnerabilities in the dependency tree |
| 44 | Dependencies are pinned | `package.json` uses exact versions or a lockfile is committed |
| 45 | Unused dependencies removed | `node_modules` does not include packages not referenced in code |
| 46 | Fastify version is current | The installed Fastify version receives active security patches |
| 47 | Plugin provenance checked | Only official `@fastify/*` plugins or well-maintained community plugins are used |

bash

```bash
# Run audit
npm audit --audit-level=high

# Check for outdated packages
npm outdated
```

---

### Logging and Observability

| # | Check | What to Verify |
| --- | --- | --- |
| 48 | Sensitive data not logged | Passwords, tokens, PII, and secrets are not present in log output |
| 49 | Request IDs propagated | Each request has a unique `requestId` for tracing |
| 50 | Auth failures are logged | Failed login attempts are recorded with IP and timestamp |
| 51 | Log level appropriate for environment | `debug` is not used in production; `info` or `warn` is preferred |
| 52 | Logs are shipped externally | Log output goes to a durable external sink, not just stdout |

**Example — Redact sensitive fields from Pino logs:**

js

```js
const fastify = Fastify({
  logger: {
    level: 'info',
    redact: {
      paths: ['req.headers.authorization', 'req.body.password', 'req.body.token'],
      censor: '[REDACTED]',
    },
  },
})
```

---

### Environment and Secrets Management

| # | Check | What to Verify |
| --- | --- | --- |
| 53 | No secrets in source code | API keys, DB credentials, JWT secrets are loaded from environment variables |
| 54 | `.env` files excluded from VCS | `.gitignore` includes `.env` and all variants |
| 55 | Secrets manager in use | Production secrets come from a vault (AWS Secrets Manager, HashiCorp Vault, etc.) |
| 56 | `NODE_ENV` is set correctly | `process.env.NODE_ENV === 'production'` in production environments |
| 57 | Debug mode disabled in production | No development-only routes, verbose errors, or introspection endpoints exposed |

---

### Plugin and Fastify Instance Configuration

| # | Check | What to Verify |
| --- | --- | --- |
| 58 | `trustProxy` configured correctly | Set only when a trusted reverse proxy is in the chain; not set to `true` blindly |
| 59 | `exposeHeadRoutes` reviewed | Auto-generated HEAD routes do not bypass authorization |
| 60 | Graceful shutdown implemented | `SIGTERM` and `SIGINT` close the server cleanly without dropping in-flight requests |
| 61 | Plugin registration order | Security plugins (helmet, cors, rate-limit) register before route plugins |

**Example — Graceful shutdown:**

js

```js
const close = async () => {
  await fastify.close()
  process.exit(0)
}

process.on('SIGTERM', close)
process.on('SIGINT', close)
```

---

### Summary Audit Matrix

```
Domain                    Items     Priority
─────────────────────────────────────────────
Transport Security         1–5      Critical
HTTP Headers               6–11     High
Authentication            12–18     Critical
Authorization             19–23     Critical
Input Validation          24–30     High
Output Handling           31–34     High
Rate Limiting             35–38     High
CORS                      39–42     Medium
Dependencies              43–47     High
Logging                   48–52     Medium
Secrets Management        53–57     Critical
Fastify Configuration     58–61     Medium
```

[Inference] Priority ratings above reflect common industry practice for web API security. They are not derived from a specific Fastify security standard and should be adjusted to your threat model.

---

**Related Topics:**

- Penetration testing strategies for REST APIs
- `@fastify/helmet` CSP configuration in depth
- OWASP API Security Top 10 mapped to Fastify
- Secrets management with HashiCorp Vault and Fastify
- Structured audit logging with Pino and external sinks
- Dependency scanning automation in CI pipelines
- mTLS and certificate-based authentication in Fastify