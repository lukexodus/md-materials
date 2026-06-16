## CSRF Protection with @fastify/csrf-protection

Cross-Site Request Forgery (CSRF) tricks an authenticated user's browser into sending an unintended request to a server where the user is already authenticated. @fastify/csrf-protection provides token-based CSRF mitigation that integrates with Fastify's plugin system and works alongside session or cookie plugins.

---

### How CSRF Attacks Work

A CSRF attack exploits the browser's automatic inclusion of cookies with cross-origin requests. If a user is logged into `bank.example.com`, a malicious page at `evil.example.com` can trigger a form submission or fetch request to `bank.example.com` — and the browser attaches the session cookie automatically.

evil.example.combank.example.comUser Browserevil.example.combank.example.comUser BrowserLogin → receives session cookieVisits malicious pageReturns page with hidden form targeting bank.example.comBrowser auto-submits form with session cookieProcesses transfer (attacker's intent)200 OK (damage done)

A CSRF token breaks this by requiring a secret value that the malicious page cannot read due to the Same-Origin Policy.

---

### When CSRF Protection Is Needed

CSRF protection is most relevant when:

- Your API is consumed by a browser using **cookie-based session authentication**
- You serve **HTML forms** that submit to your Fastify routes
- State-mutating operations (POST, PUT, PATCH, DELETE) are performed via browser requests

**When it may not be needed:**

- APIs authenticated exclusively via `Authorization: Bearer` headers — browsers do not auto-attach these cross-origin
- APIs consumed only by non-browser clients (mobile apps, server-to-server)
- When `SameSite=Strict` or `SameSite=Lax` cookies are in use — [Inference: these attributes substantially reduce CSRF risk but are not universally considered a complete replacement for token-based protection, particularly for `Lax` with GET-triggered navigations]

---

### Installation

@fastify/csrf-protection requires a session or cookie store to persist the CSRF secret. Install the appropriate companion plugin:

bash

```bash
# Core plugin
npm install @fastify/csrf-protection

# Choose one store:
npm install @fastify/cookie       # Cookie-based (stateless)
npm install @fastify/session      # Server-side session
npm install @fastify/secure-session  # Encrypted cookie session
```

---

### How Token Validation Works

FastifyBrowserFastifyBrowseralt[valid][invalid or missing]GET /formGenerate secret, store in cookie/sessionGenerate CSRF token from secretHTML form with hidden _csrf token fieldPOST /form (form data + _csrf token)Read secret from cookie/sessionVerify token matches secret200 OK403 Forbidden

The secret is stored server-side (or in a signed/encrypted cookie). The token is derived from the secret and sent to the client. On subsequent requests, the plugin re-derives a token from the stored secret and compares it to the submitted token.

---

### Setup with @fastify/cookie

The simplest stateless approach — the CSRF secret is stored in a cookie.

js

```js
import Fastify from 'fastify'
import cookie from '@fastify/cookie'
import csrf from '@fastify/csrf-protection'

const fastify = Fastify()

await fastify.register(cookie, {
  secret: process.env.COOKIE_SECRET,  // For signed cookies
})

await fastify.register(csrf, {
  sessionPlugin: '@fastify/cookie',
})

fastify.get('/form', async (request, reply) => {
  const token = await reply.generateCsrf()
  return reply.view('form.html', { csrfToken: token })
})

fastify.post('/form', async (request, reply) => {
  // Validation is automatic — reaching here means the token was valid
  return { success: true }
})

await fastify.listen({ port: 3000 })
```

**Key Points:**

- `reply.generateCsrf()` stores the secret in a cookie and returns the token.
- The plugin validates the token on every state-mutating request automatically.
- No manual validation call is needed in the route handler.

---

### Setup with @fastify/session

js

```js
import Fastify from 'fastify'
import session from '@fastify/session'
import cookie from '@fastify/cookie'
import csrf from '@fastify/csrf-protection'

const fastify = Fastify()

await fastify.register(cookie)

await fastify.register(session, {
  secret: process.env.SESSION_SECRET,
  cookie: { secure: true, httpOnly: true, sameSite: 'strict' },
})

await fastify.register(csrf, {
  sessionPlugin: '@fastify/session',
})

fastify.get('/form', async (request, reply) => {
  const token = await reply.generateCsrf()
  return reply.view('form.html', { csrfToken: token })
})

fastify.post('/submit', async (request, reply) => {
  return { received: request.body }
})

await fastify.listen({ port: 3000 })
```

---

### Setup with @fastify/secure-session

js

```js
import Fastify from 'fastify'
import secureSession from '@fastify/secure-session'
import csrf from '@fastify/csrf-protection'
import { readFileSync } from 'node:fs'

const fastify = Fastify()

await fastify.register(secureSession, {
  key: readFileSync('./secret-key'),
  cookie: { path: '/', httpOnly: true },
})

await fastify.register(csrf, {
  sessionPlugin: '@fastify/secure-session',
})

fastify.get('/form', async (request, reply) => {
  const token = await reply.generateCsrf()
  return reply.view('form.html', { csrfToken: token })
})

fastify.post('/submit', async (request, reply) => {
  return { ok: true }
})
```

---

### Token Delivery Methods

The generated token must reach the client and be returned on subsequent requests. There are several patterns for this.

#### Hidden Form Field (Traditional HTML Forms)

html

```html
<form method="POST" action="/submit">
  <input type="hidden" name="_csrf" value="{{ csrfToken }}" />
  <input type="text" name="username" />
  <button type="submit">Submit</button>
</form>
```

#### Meta Tag (JavaScript/SPA Consumption)

html

```html
<meta name="csrf-token" content="{{ csrfToken }}" />
```

js

```js
// Read from meta tag and attach to all fetch requests
const csrfToken = document.querySelector('meta[name="csrf-token"]').content

fetch('/api/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'csrf-token': csrfToken,
  },
  body: JSON.stringify({ key: 'value' }),
})
```

#### Dedicated Token Endpoint (API-first)

js

```js
fastify.get('/csrf-token', async (request, reply) => {
  const token = await reply.generateCsrf()
  return { csrfToken: token }
})
```

The SPA calls this endpoint first, stores the token, and includes it in subsequent mutation requests.

---

### Where the Plugin Looks for the Token

By default, @fastify/csrf-protection checks these locations in order:

1. `request.body._csrf` — form field
2. `request.query._csrf` — query string (not recommended for production)
3. `request.headers['csrf-token']`
4. `request.headers['xsrf-token']`
5. `request.headers['x-csrf-token']`
6. `request.headers['x-xsrf-token']`

The first non-empty value found is used for validation. [Inference: exact lookup order may vary by version — consult the source if order matters for your implementation.]

---

### Configuration Options

js

```js
await fastify.register(csrf, {
  sessionPlugin: '@fastify/cookie',

  // Custom cookie/session key for storing the secret
  cookieKey: '_csrfsecret',        // Default: '_csrf'
  sessionKey: '_csrfsecret',       // For session-based storage

  // Custom field/header names to check for the token
  getToken: (request) => {
    return request.headers['x-my-csrf-token']
      ?? request.body?._csrf
  },

  // CSRF protection only applies to these methods
  // Default: POST, PUT, PATCH, DELETE, TRACE, OPTIONS
  // (GET, HEAD, OPTIONS, TRACE are typically safe methods)

  // Cookie options (when using @fastify/cookie)
  cookieOpts: {
    httpOnly: true,
    sameSite: 'strict',
    secure: true,
    path: '/',
  },

  // Custom response on validation failure
  onError: (request, reply) => {
    reply.status(403).send({
      statusCode: 403,
      error: 'Forbidden',
      message: 'Invalid CSRF token',
    })
  },
})
```

---

### Per-Route Control

#### Disable CSRF on Specific Routes

Some routes may legitimately need to accept cross-origin POST requests (webhooks, public APIs). Disable protection selectively:

js

```js
await fastify.register(csrf, {
  sessionPlugin: '@fastify/cookie',
})

// Webhook from a third-party — no session, no CSRF token possible
fastify.post('/webhooks/stripe', {
  config: { csrf: { skip: true } },
  handler: async (request, reply) => {
    // Validate Stripe signature instead
    return { received: true }
  },
})
```

[Unverified: the exact route-level config key (`csrf.skip` or similar) may differ by version — check the plugin documentation for the version in use.]

#### Apply CSRF Only to Specific Scopes

Use Fastify's encapsulation to limit protection to a prefix:

js

```js
// Public/API routes — no CSRF
fastify.register(async (publicScope) => {
  publicScope.get('/status', async () => ({ status: 'ok' }))
})

// Browser-facing routes — CSRF protected
fastify.register(async (webScope) => {
  await webScope.register(csrf, { sessionPlugin: '@fastify/cookie' })

  webScope.get('/dashboard', async (request, reply) => {
    const token = await reply.generateCsrf()
    return reply.view('dashboard.html', { csrfToken: token })
  })

  webScope.post('/profile', async (request, reply) => {
    return { updated: true }
  })
}, { prefix: '/web' })
```

---

### CSRF with JSON APIs and SPAs

For Single Page Applications that use cookie-based auth (e.g., `HttpOnly` session cookies), a common flow:

js

```js
// 1. On app load or login, fetch a token
fastify.get('/api/csrf-token', async (request, reply) => {
  const token = await reply.generateCsrf()
  return { token }
})

// 2. Subsequent mutating calls include the token in a header
fastify.post('/api/profile', async (request, reply) => {
  return { user: request.body }
})
```

js

```js
// Client-side setup (e.g., Axios interceptor)
const { data } = await axios.get('/api/csrf-token')
const csrfToken = data.token

axios.defaults.headers.common['csrf-token'] = csrfToken
```

**Key Points:**

- This pattern is sometimes called the **Synchronizer Token Pattern** for SPAs.
- The token endpoint itself should only be accessible to authenticated users if CSRF protection is tied to authenticated state.
- Storing the token in a JavaScript variable (not a cookie) means it is inaccessible to cross-origin scripts due to the Same-Origin Policy.

---

### CSRF and SameSite Cookies

`SameSite=Strict` prevents the browser from sending cookies on any cross-site request. `SameSite=Lax` allows cookies on top-level GET navigations but blocks cross-site POST. Both reduce CSRF risk significantly.

| Cookie Attribute | Cross-site GET | Cross-site POST | CSRF Risk |
| --- | --- | --- | --- |
| No `SameSite` | Sent | Sent | High |
| `SameSite=Lax` | Sent | Blocked | Reduced |
| `SameSite=Strict` | Blocked | Blocked | Minimal |

**Key Points:**

- `SameSite=Strict` with token-based CSRF is defense-in-depth — two independent mitigations.
- `SameSite=Lax` alone may not protect against all CSRF vectors, particularly when GET requests trigger state changes. [Inference: some older browsers have incomplete `SameSite` support — token-based protection remains a reliable fallback.]
- Do not rely solely on `SameSite` if you need to support a wide browser matrix.

---

### Generating the Token Correctly

`reply.generateCsrf()` must be called before the response is sent. It is async and must be awaited:

js

```js
// Correct
fastify.get('/page', async (request, reply) => {
  const token = await reply.generateCsrf()
  return reply.view('page.html', { csrfToken: token })
})

// Incorrect — token will be undefined
fastify.get('/page', async (request, reply) => {
  const token = reply.generateCsrf()  // Missing await
  return reply.view('page.html', { csrfToken: token })
})
```

---

### Testing CSRF Protection

js

```js
import { test } from 'node:test'
import assert from 'node:assert'
import Fastify from 'fastify'
import cookie from '@fastify/cookie'
import csrf from '@fastify/csrf-protection'

async function buildApp() {
  const app = Fastify()
  await app.register(cookie, { secret: 'test-secret-minimum-32-chars-long' })
  await app.register(csrf, { sessionPlugin: '@fastify/cookie' })

  app.get('/token', async (request, reply) => {
    const token = await reply.generateCsrf()
    return { token }
  })

  app.post('/submit', async () => ({ ok: true }))
  await app.ready()
  return app
}

test('rejects POST without CSRF token', async () => {
  const app = await buildApp()
  const res = await app.inject({ method: 'POST', url: '/submit' })
  assert.strictEqual(res.statusCode, 403)
})

test('accepts POST with valid CSRF token', async () => {
  const app = await buildApp()

  // Get token and capture the cookie
  const tokenRes = await app.inject({ method: 'GET', url: '/token' })
  const { token } = JSON.parse(tokenRes.body)
  const cookies = tokenRes.headers['set-cookie']

  const res = await app.inject({
    method: 'POST',
    url: '/submit',
    headers: {
      'csrf-token': token,
      cookie: Array.isArray(cookies) ? cookies.join('; ') : cookies,
    },
  })

  assert.strictEqual(res.statusCode, 200)
})
```

**Key Points:**

- The cookie returned by the token endpoint must be forwarded with the subsequent POST — it carries the secret that validates the token.
- Without forwarding the cookie, validation will always fail even with the correct token.

---

### Common Pitfalls

#### Forgetting to Forward the Cookie in Tests

The CSRF secret lives in the cookie. If your test does not forward the cookie set during token generation, the POST request will always be rejected with 403.

#### Using CSRF on Webhook Routes

Third-party services (Stripe, GitHub, Twilio) POST to your server without a CSRF token. These routes must be excluded from CSRF protection and validated using the provider's own signature mechanism instead.

#### Token Not Refreshed After Use

[Inference: some CSRF implementations rotate the token after each use (per-request tokens). @fastify/csrf-protection uses a secret-based approach where the token is derived from a persistent secret, meaning the same secret can generate valid tokens repeatedly within the session. This is sometimes called the **Encrypted Token Pattern**. Verify behavior for your version.]

#### Applying CSRF to GET Routes

CSRF tokens should only be validated on state-mutating methods. Applying validation to GET requests breaks normal navigation and provides no additional security benefit since GET requests should not change state.

#### Mixed HTTP/HTTPS with Secure Cookies

If `cookieOpts.secure: true` is set, the CSRF secret cookie will not be sent over HTTP. In local development without HTTPS, either set `secure: false` conditionally or use a local HTTPS setup.

js

```js
cookieOpts: {
  secure: process.env.NODE_ENV === 'production',
  httpOnly: true,
  sameSite: 'strict',
}
```

---

**Related Topics:**

- `@fastify/cookie` — cookie management, signing, and options
- `@fastify/session` and `@fastify/secure-session` — session storage strategies
- `@fastify/helmet` — complementary security headers including `SameSite` guidance
- `@fastify/cors` — restricting cross-origin access as a complementary measure
- Webhook signature verification — alternative to CSRF for server-to-server POST endpoints
- Authentication patterns in Fastify — JWT vs session cookies and their CSRF implications
- Defense-in-depth strategies — layering CSRF tokens, `SameSite`, CORS, and HTTPS