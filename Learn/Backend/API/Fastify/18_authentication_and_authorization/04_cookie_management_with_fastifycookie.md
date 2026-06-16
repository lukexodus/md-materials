## Cookie Management with @fastify/cookie

### Overview

`@fastify/cookie` is the official Fastify plugin for parsing and setting HTTP cookies. It integrates directly into Fastify's request/reply lifecycle, adding cookie-reading capabilities to `request.cookies` and cookie-writing methods to `reply`. It is commonly used alongside session and authentication plugins, but is fully functional as a standalone cookie utility.

---

### Installation

bash

```bash
npm install @fastify/cookie
```

---

### Registration

js

```js
import Fastify from 'fastify'
import cookie from '@fastify/cookie'

const fastify = Fastify()

await fastify.register(cookie, {
  secret: 'my-secret-key', // for signed cookies
  parseOptions: {}         // options passed to the cookie parser
})
```

**Key Points:**

- `secret` can be a string or an array of strings (for key rotation).
- `parseOptions` accepts any options supported by the underlying `cookie` npm package (e.g., `decode`).
- Registration must complete before routes that use cookies are defined — though with `fastify-plugin`, encapsulation boundaries can be crossed.

---

### Reading Cookies

Once the plugin is registered, all incoming cookies are available on `request.cookies` as a plain object.

js

```js
fastify.get('/profile', async (request, reply) => {
  const token = request.cookies.authToken
  if (!token) {
    return reply.status(401).send({ error: 'No token' })
  }
  return { token }
})
```

**Output** (assuming cookie `authToken=abc123` was sent):

json

```json
{ "token": "abc123" }
```

---

### Setting Cookies

Use `reply.setCookie(name, value, options)` to write cookies to the response.

js

```js
fastify.post('/login', async (request, reply) => {
  // ... validate credentials
  reply.setCookie('authToken', 'abc123', {
    httpOnly: true,
    secure: true,
    sameSite: 'Strict',
    path: '/',
    maxAge: 60 * 60 * 24 // 1 day in seconds
  })
  return { status: 'logged in' }
})
```

**Key Points:**

- `httpOnly: true` — cookie inaccessible to JavaScript (mitigates XSS exposure).
- `secure: true` — cookie sent only over HTTPS.
- `sameSite` — controls cross-site sending behavior (`'Strict'`, `'Lax'`, or `'None'`).
- `maxAge` — expiry in seconds; alternatively use `expires` with a `Date` object.
- `path` — scopes the cookie to a URL path.
- `domain` — scopes to a specific domain or subdomain.

---

### Clearing Cookies

js

```js
fastify.post('/logout', async (request, reply) => {
  reply.clearCookie('authToken', { path: '/' })
  return { status: 'logged out' }
})
```

**Key Points:**

- `clearCookie` sets the cookie's expiry to the past, instructing the browser to delete it.
- The `path` option in `clearCookie` must match the `path` used when the cookie was set, or the browser will not remove it.

---

### Signed Cookies

Signed cookies include an HMAC signature appended to the value, allowing the server to verify that the cookie was not tampered with client-side.

#### Setting a Signed Cookie

js

```js
reply.setCookie('session', 'user-42', {
  signed: true,
  httpOnly: true,
  path: '/'
})
```

The cookie value stored in the browser will look like:

```
s:user-42.HMAC_SIGNATURE_HERE
```

#### Reading a Signed Cookie

js

```js
fastify.get('/dashboard', async (request, reply) => {
  const { value, valid, renew } = request.unsignCookie(request.cookies.session ?? '')

  if (!valid) {
    return reply.status(401).send({ error: 'Invalid or tampered cookie' })
  }

  return { userId: value }
})
```

**Key Points:**

- `request.unsignCookie(value)` returns `{ value, valid, renew }`.
- `valid: false` means the signature did not match — the cookie may have been tampered with.
- `renew: true` means the cookie was signed with an older secret (key rotation scenario) and should be re-signed with the current secret.
- `reply.unsignCookie()` is also available and behaves identically.

---

### Key Rotation with Multiple Secrets

Passing an array to `secret` supports seamless secret rotation. The first element is always used for signing new cookies. All elements are tried when verifying.

js

```js
await fastify.register(cookie, {
  secret: ['new-secret', 'old-secret']
})
```

js

```js
const { value, valid, renew } = request.unsignCookie(request.cookies.session ?? '')

if (valid && renew) {
  // Re-sign with the current (first) secret
  reply.setCookie('session', value, { signed: true, httpOnly: true, path: '/' })
}
```

**Key Points:**

- This pattern lets you rotate secrets without immediately invalidating all existing sessions.
- `renew: true` is the signal that re-issuance is needed.

---

### Cookie Options Reference

| Option | Type | Description |
| --- | --- | --- |
| `httpOnly` | boolean | Blocks JS access to the cookie |
| `secure` | boolean | HTTPS-only transmission |
| `sameSite` | string | `'Strict'`, `'Lax'`, or `'None'` |
| `path` | string | URL path scope |
| `domain` | string | Domain scope |
| `maxAge` | number | Seconds until expiry |
| `expires` | Date | Absolute expiry date |
| `signed` | boolean | Enables HMAC signing |
| `encode` | function | Custom value encoder |

---

### Parsing Options (`parseOptions`)

These are passed directly to the underlying `cookie.parse()` call.

js

```js
await fastify.register(cookie, {
  parseOptions: {
    decode: (str) => decodeURIComponent(str)
  }
})
```

[Inference] Custom decoders are useful when cookies are encoded in a non-standard way by a third-party client or legacy system.

---

### Hook-Level Cookie Access

Cookie values are available in any hook that runs after the request parsing phase.

js

```js
fastify.addHook('preHandler', async (request, reply) => {
  const token = request.cookies.authToken
  if (!token) {
    return reply.status(401).send({ error: 'Unauthorized' })
  }
})
```

**Key Points:**

- `onRequest` hooks run before cookie parsing — `request.cookies` will be empty at that stage.
- `preParsing`, `preValidation`, `preHandler`, and `onSend` all have access to parsed cookies.

---

### Using with @fastify/session or @fastify/jwt

`@fastify/cookie` is a peer dependency of both `@fastify/session` and `@fastify/jwt` (when using cookie-based JWT transport). Register `@fastify/cookie` first.

js

```js
await fastify.register(cookie, { secret: 'cookie-secret' })
await fastify.register(session, {
  secret: 'session-secret',
  cookie: { secure: true }
})
```

[Inference] In production, cookie and session secrets should be loaded from environment variables or a secrets manager, not hardcoded.

---

### Security Considerations

- Always use `httpOnly: true` for authentication cookies to reduce XSS exposure. This does not fully prevent all XSS attack vectors — behavior may vary depending on browser and application context.
- Use `secure: true` in production to restrict cookies to HTTPS. In development over HTTP, omit this flag or the cookie will not be sent.
- Use `sameSite: 'Strict'` or `'Lax'` to reduce CSRF risk. `'None'` requires `secure: true` and is needed for cross-site contexts (e.g., embedded iframes, third-party integrations).
- Signed cookies verify integrity, not confidentiality — the value is still readable by the client. Use encryption (e.g., `@fastify/secure-session`) if the cookie value must remain secret.
- Rotate secrets periodically and use the array form of `secret` to avoid invalidating active sessions during rotation.

---

### Minimal Working Example

js

```js
import Fastify from 'fastify'
import cookie from '@fastify/cookie'

const fastify = Fastify({ logger: true })

await fastify.register(cookie, {
  secret: process.env.COOKIE_SECRET ?? 'dev-secret'
})

fastify.post('/login', async (request, reply) => {
  reply.setCookie('user', 'arya', {
    signed: true,
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'Strict',
    path: '/',
    maxAge: 86400
  })
  return { ok: true }
})

fastify.get('/me', async (request, reply) => {
  const { value, valid } = request.unsignCookie(request.cookies.user ?? '')
  if (!valid) return reply.status(401).send({ error: 'Unauthorized' })
  return { user: value }
})

fastify.delete('/logout', async (request, reply) => {
  reply.clearCookie('user', { path: '/' })
  return { ok: true }
})

await fastify.listen({ port: 3000 })
```

---

**Related Topics:**

- Session management with `@fastify/session`
- Stateless sessions with `@fastify/secure-session`
- JWT authentication with `@fastify/jwt` (cookie transport mode)
- CSRF protection with `@fastify/csrf-protection`
- `httpOnly` and `SameSite` cookie security deep dive
- Cookie-based remember-me / persistent login patterns
- Multi-domain cookie sharing strategies