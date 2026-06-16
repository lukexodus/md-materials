## WebSocket Authentication

WebSocket connections begin as HTTP requests, which means standard HTTP authentication mechanisms — headers, cookies, query parameters — are available during the upgrade handshake. After the connection is established, the WebSocket protocol has no built-in authentication layer. All authentication must occur before or at the point of upgrade.

---

### When Authentication Can Occur

| Stage | Mechanism | Access to Fastify hooks |
| --- | --- | --- |
| HTTP upgrade request | Headers, cookies, query params | Yes — full hook pipeline |
| `preHandler` hook | Token validation, session lookup | Yes |
| Inside WebSocket handler | First message as auth payload | No hooks — manual only |
| Post-connection (per message) | Re-validate token on each message | No hooks — manual only |

**Key Points**

- The upgrade handshake is the preferred and most secure point to authenticate — rejecting here sends an HTTP response before any WebSocket resources are allocated
- Authenticating inside the handler (after connection) means the socket is already open while validation is pending — unauthenticated clients hold a connection slot
- The browser `WebSocket` API does not support custom headers — tokens must arrive via cookies or query parameters from browser clients
- Non-browser clients (server-to-server, CLI tools) can send arbitrary headers including `Authorization`

---

### Authentication via `preHandler`

`preHandler` runs before the upgrade completes. Calling `reply.send()` here rejects the upgrade with an HTTP response.

#### Bearer token in `Authorization` header

js

```js
async function verifyBearer(request, reply) {
  const header = request.headers['authorization']

  if (!header?.startsWith('Bearer ')) {
    reply.code(401).send({ error: 'Missing or malformed Authorization header' })
    return
  }

  const token = header.slice(7)

  try {
    const payload = verifyJwt(token) // your JWT verification logic
    request.user = payload
  } catch {
    reply.code(401).send({ error: 'Invalid token' })
  }
}

app.get('/ws', {
  websocket: true,
  preHandler: verifyBearer
}, (socket, request) => {
  // request.user is available here
  socket.send(JSON.stringify({ event: 'connected', userId: request.user.sub }))

  socket.on('message', (data) => {
    socket.send(data.toString())
  })
})
```

**Key Points**

- `request.user` set in `preHandler` is accessible in the WebSocket handler via the same `request` object
- Throwing inside `preHandler` triggers Fastify's error handler — explicitly call `reply.send()` for controlled error responses
- `preHandler` can be an array of functions for composing multiple checks

---

### Authentication via Query Parameter (Browser Clients)

The browser `WebSocket` constructor does not accept custom headers. Tokens are commonly passed as query parameters:

js

```js
// Browser client
const ws = new WebSocket('wss://example.com/ws?token=eyJhbGci...')
```

js

```js
// Server
async function verifyQueryToken(request, reply) {
  const { token } = request.query

  if (!token) {
    reply.code(401).send({ error: 'Missing token' })
    return
  }

  try {
    request.user = verifyJwt(token)
  } catch {
    reply.code(401).send({ error: 'Invalid token' })
  }
}

app.get('/ws', {
  websocket: true,
  schema: {
    querystring: {
      type: 'object',
      properties: {
        token: { type: 'string' }
      },
      required: ['token']
    }
  },
  preHandler: verifyQueryToken
}, (socket, request) => {
  socket.send(JSON.stringify({ userId: request.user.sub }))
})
```

**Key Points**

- Tokens in query parameters appear in server access logs and browser history — mitigate by using short-lived tokens and HTTPS exclusively [Inference]
- The `schema.querystring` validation runs before `preHandler` — it provides a structured 400 if `token` is absent before JWT verification is attempted
- Short-lived tokens (30–60 seconds) issued immediately before the WebSocket connection reduce the exposure window of query-parameter tokens [Inference]

---

### Authentication via Cookie

Cookies are sent automatically by browsers on WebSocket upgrade requests to the same origin, making them a natural fit for session-based authentication.

bash

```bash
npm install @fastify/cookie @fastify/session
```

js

```js
import cookie from '@fastify/cookie'
import session from '@fastify/session'

await app.register(cookie)
await app.register(session, {
  secret: process.env.SESSION_SECRET,
  cookie: { secure: true, httpOnly: true, sameSite: 'strict' }
})
```

js

```js
async function verifySession(request, reply) {
  const user = request.session.get('user')

  if (!user) {
    reply.code(401).send({ error: 'Not authenticated' })
  }

  request.user = user
}

app.get('/ws', {
  websocket: true,
  preHandler: verifySession
}, (socket, request) => {
  socket.send(JSON.stringify({ event: 'connected', user: request.user }))
})
```

**Key Points**

- `httpOnly: true` prevents JavaScript from reading the session cookie — it is sent automatically by the browser but inaccessible to `document.cookie`
- `sameSite: 'strict'` mitigates cross-site request forgery on the cookie — important for WebSocket endpoints [Inference]
- Cookie-based auth is not available to non-browser clients without explicit cookie header management

---

### Using `@fastify/jwt`

`@fastify/jwt` provides `request.jwtVerify()` as a convenience method:

bash

```bash
npm install @fastify/jwt
```

js

```js
import jwt from '@fastify/jwt'

await app.register(jwt, {
  secret: process.env.JWT_SECRET
})
```

js

```js
app.get('/ws', {
  websocket: true,
  preHandler: async (request, reply) => {
    // jwtVerify reads from Authorization header by default
    // Can be configured to read from cookies or query params
    await request.jwtVerify()
    // request.user is populated on success
  }
}, (socket, request) => {
  socket.send(JSON.stringify({ userId: request.user.sub }))
})
```

#### Configuring `jwtVerify` to read from query parameter

js

```js
await app.register(jwt, {
  secret: process.env.JWT_SECRET,
  decode: { complete: true },
  sign: { algorithm: 'HS256' }
})

app.decorateRequest('jwtVerifyFromQuery', async function (reply) {
  const token = this.query.token

  if (!token) {
    reply.code(401).send({ error: 'Missing token' })
    return
  }

  try {
    this.user = await app.jwt.verify(token)
  } catch {
    reply.code(401).send({ error: 'Invalid token' })
  }
})

app.get('/ws', {
  websocket: true,
  preHandler: async function (request, reply) {
    await request.jwtVerifyFromQuery(reply)
  }
}, (socket, request) => {
  socket.send(JSON.stringify({ userId: request.user.sub }))
})
```

---

### First-Message Authentication

When header and cookie options are not viable, the client sends credentials as the first WebSocket message. The server holds the connection open but does not process subsequent messages until authentication succeeds.

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  let authenticated = false
  let user = null

  socket.once('message', async (data) => {
    let msg

    try {
      msg = JSON.parse(data.toString())
    } catch {
      socket.close(1008, 'Invalid auth payload')
      return
    }

    if (msg.type !== 'auth' || !msg.token) {
      socket.close(1008, 'Expected auth message')
      return
    }

    try {
      user = verifyJwt(msg.token)
      authenticated = true
      socket.send(JSON.stringify({ event: 'authenticated', userId: user.sub }))
    } catch {
      socket.close(1008, 'Invalid token')
      return
    }

    // Register the ongoing message handler only after auth succeeds
    socket.on('message', (data) => {
      if (!authenticated) return
      handleMessage(socket, user, data)
    })
  })

  // Guard against messages arriving before auth completes
  socket.on('message', (data) => {
    if (!authenticated) {
      socket.close(1008, 'Authenticate first')
    }
  })
})
```

**Key Points**

- `socket.once('message', ...)` fires only for the first message, then removes itself
- The connection is open and holding a slot before auth completes — a malicious client can hold connections indefinitely without sending an auth message
- Pair with a short auth timeout to mitigate unauthenticated connection holding [Inference]

#### Auth timeout

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  let authenticated = false

  const authTimeout = setTimeout(() => {
    if (!authenticated) {
      socket.close(1008, 'Authentication timeout')
    }
  }, 10_000) // 10 seconds to authenticate

  socket.once('message', (data) => {
    clearTimeout(authTimeout)
    // ... auth logic
  })

  socket.on('close', () => {
    clearTimeout(authTimeout)
  })
})
```

---

### Token Expiry and Re-Authentication

JWTs expire. For long-lived WebSocket connections, token expiry must be handled explicitly.

#### Server-side expiry check on each message

js

```js
app.get('/ws', {
  websocket: true,
  preHandler: async (request, reply) => {
    await request.jwtVerify()
  }
}, (socket, request) => {
  const tokenExp = request.user.exp * 1000 // exp is in seconds

  socket.on('message', (data) => {
    if (Date.now() > tokenExp) {
      socket.close(1008, 'Token expired')
      return
    }

    handleMessage(socket, data)
  })
})
```

#### Client-initiated token refresh

The client sends a refresh message before expiry; the server validates the new token and updates the session:

js

```js
app.get('/ws', {
  websocket: true,
  preHandler: async (request, reply) => {
    await request.jwtVerify()
  }
}, (socket, request) => {
  let currentUser = request.user

  socket.on('message', (data) => {
    let msg

    try {
      msg = JSON.parse(data.toString())
    } catch {
      socket.send(JSON.stringify({ error: 'Invalid JSON' }))
      return
    }

    if (msg.type === 'refresh') {
      try {
        currentUser = app.jwt.verify(msg.token)
        socket.send(JSON.stringify({ event: 'refreshed', userId: currentUser.sub }))
      } catch {
        socket.close(1008, 'Invalid refresh token')
      }
      return
    }

    handleMessage(socket, currentUser, msg)
  })
})
```

**Key Points**

- `request.user` from `preHandler` is fixed at connection time — store it in a mutable variable to allow updates [Inference]
- Token refresh over the WebSocket channel avoids requiring the client to reconnect
- Validate the refresh token with the same rigor as the initial token — signature, expiry, issuer [Inference]

---

### Scoped Route Authentication with Fastify Plugins

Encapsulating authentication in a plugin scope avoids repeating `preHandler` on every route:

js

```js
// src/plugins/ws-auth.js
import fp from 'fastify-plugin'

async function wsAuthPlugin(app, opts) {
  app.addHook('preHandler', async (request, reply) => {
    // Only apply to WebSocket upgrade requests
    if (request.headers.upgrade?.toLowerCase() !== 'websocket') return

    const token = request.query.token ?? request.headers['authorization']?.slice(7)

    if (!token) {
      reply.code(401).send({ error: 'Unauthorized' })
      return
    }

    try {
      request.user = app.jwt.verify(token)
    } catch {
      reply.code(401).send({ error: 'Invalid token' })
    }
  })
}

export default fp(wsAuthPlugin)
```

js

```js
// Applied to all routes in the registered scope
await app.register(async function authenticatedScope(scope) {
  scope.register(wsAuthPlugin)

  scope.get('/ws/chat', { websocket: true }, (socket, request) => {
    socket.send(JSON.stringify({ userId: request.user.sub }))
  })

  scope.get('/ws/notifications', { websocket: true }, (socket, request) => {
    socket.send(JSON.stringify({ userId: request.user.sub }))
  })
})
```

**Key Points**

- The `upgrade` header check prevents the WebSocket auth hook from interfering with regular HTTP routes in the same scope
- `fp()` is not used here — the plugin is intentionally scoped, not global
- This pattern is analogous to guarding HTTP routes with a scoped `preHandler` hook

---

### Authentication Flow

WebSocket HandlerpreHandlerFastifyClientWebSocket HandlerpreHandlerFastifyClientloop[Messages]alt[Token missing or invalid][Token valid]GET /ws (Upgrade: websocket)\nAuthorization: Bearer <token>run preHandler hooksHTTP 401 Unauthorized\n(no WebSocket connection made)request.user = decoded payloadcontinue101 Switching Protocols(socket, request)send connected eventmessagecheck token expiryresponse

---

### Security Considerations

**Never trust client-supplied identity after the handshake**
Always derive user identity from the verified token, not from a field the client sends in a message (e.g. `{ userId: 'admin' }`).

**Use HTTPS/WSS exclusively**
Tokens in query parameters or headers are exposed in plaintext over unencrypted connections. `wss://` encrypts the entire exchange including the upgrade request. [Inference]

**Validate token claims beyond signature**
Check `exp` (expiry), `iss` (issuer), and `aud` (audience) in addition to the signature. A valid signature on an expired or wrong-audience token should be rejected. [Inference]

**Short-lived tokens for query-parameter auth**
Issue a dedicated short-lived token (30–120 seconds) from an HTTP endpoint, used only for the WebSocket upgrade. Rotate it after the connection is established if your protocol supports it. [Inference]

**Rate-limit upgrade requests**
Repeated failed upgrade attempts can be used to enumerate valid tokens or overwhelm `preHandler` logic. Apply `@fastify/rate-limit` to WebSocket routes as with any HTTP route. [Inference]

---

### Common Pitfalls

**Relying on `Authorization` header from browser clients**
The browser `WebSocket` API does not support custom headers. Use cookies or query parameters for browser-originated connections.

**Not handling token expiry on long-lived connections**
A token valid at connection time will expire while the connection is open. Check `exp` on each message or implement a refresh mechanism.

**Leaving unauthenticated connections open**
First-message auth leaves the socket open during validation. Add an auth timeout and close unauthenticated connections promptly.

**Setting `request.user` after `await` in `preHandler` without error handling**
If `jwtVerify` throws and the error is not caught, Fastify's default error handler sends a 500. Always wrap in `try/catch` and send a specific 401.

**Using the same long-lived token for WebSocket and REST**
Long-lived tokens passed in URLs accumulate in logs and caches. Issue short-lived, purpose-specific tokens for WebSocket upgrades where query-parameter delivery is required. [Inference]

---

**Related Topics**

- Refresh token rotation over an active WebSocket connection
- Role-based access control per WebSocket route
- Authenticating server-to-server WebSocket connections with mTLS
- Rate limiting WebSocket upgrade attempts with `@fastify/rate-limit`
- Revoking active WebSocket sessions on logout (token blocklist)
- Testing authenticated WebSocket routes with `preHandler` mocks
- Combining cookie and header auth with a fallback chain in `preHandler`