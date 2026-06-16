## WebSocket Support with @fastify/websocket

`@fastify/websocket` integrates WebSocket handling directly into Fastify's routing system. WebSocket routes coexist with regular HTTP routes, share the same plugin and hook infrastructure, and are defined using familiar Fastify syntax.

---

### How It Works

`@fastify/websocket` is built on top of the `ws` library. When a client sends an HTTP Upgrade request, Fastify detects the WebSocket handshake and routes the connection to the appropriate handler. Non-upgrade requests to the same path are handled as normal HTTP routes.

**Key Points**

- The underlying WebSocket server is a `ws` instance exposed as `app.websocketServer`
- Each WebSocket connection produces a `socket` object — a standard `ws` `WebSocket` instance
- Fastify hooks (`onRequest`, `preHandler`, etc.) run before the WebSocket connection is established, enabling authentication at the hook level
- WebSocket handlers do not use `reply.send()` — all communication goes through the `socket` API directly

---

### Installation

bash

```bash
npm install @fastify/websocket
```

---

### Basic Registration

js

```js
// src/app.js
import Fastify from 'fastify'
import websocket from '@fastify/websocket'

const app = Fastify({ logger: true })

await app.register(websocket)

export default app
```

**Key Points**

- `websocket` must be registered before any WebSocket routes are defined
- Registration is async — use `await` or `.after()` before defining routes

---

### Defining a WebSocket Route

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  socket.on('message', (message) => {
    socket.send(`Echo: ${message}`)
  })

  socket.on('close', () => {
    console.log('Client disconnected')
  })

  socket.on('error', (err) => {
    console.error('Socket error:', err)
  })
})
```

**Key Points**

- `{ websocket: true }` in the route options signals that this handler receives WebSocket connections
- The handler signature is `(socket, request)` — not `(request, reply)`
- `socket` is a `ws` `WebSocket` instance; all standard `ws` events and methods apply
- `request` is the Fastify request object from the upgrade handshake — headers, query parameters, and params are accessible here

---

### WebSocket Route Alongside HTTP Route

The same path can serve both HTTP and WebSocket traffic:

js

```js
// HTTP handler
app.get('/status', async (request, reply) => {
  return { status: 'ok' }
})

// WebSocket handler on the same path prefix (different path)
app.get('/ws/status', { websocket: true }, (socket, request) => {
  socket.send(JSON.stringify({ status: 'connected' }))
})
```

[Inference] Fastify distinguishes WebSocket upgrade requests from regular HTTP requests at the routing level — a `GET /ws/status` HTTP request and a WebSocket upgrade to `/ws/status` are dispatched to different handlers. Verify this behavior with your specific version of `@fastify/websocket`.

---

### Sending and Receiving Messages

#### Sending text

js

```js
socket.send('Hello, client')
```

#### Sending JSON

js

```js
socket.send(JSON.stringify({ type: 'welcome', payload: { userId: 42 } }))
```

#### Receiving and parsing JSON

js

```js
socket.on('message', (rawMessage) => {
  let parsed

  try {
    parsed = JSON.parse(rawMessage.toString())
  } catch {
    socket.send(JSON.stringify({ error: 'Invalid JSON' }))
    return
  }

  console.log('Received:', parsed)
})
```

**Key Points**

- `message` events deliver a `Buffer` by default — call `.toString()` before `JSON.parse()`
- `socket.send()` accepts strings, Buffers, or typed arrays
- `socket.send()` is asynchronous; errors surface via its optional callback: `socket.send(data, (err) => { ... })`

---

### Closing Connections

js

```js
// Close from the server side
socket.close()

// Close with a code and reason
socket.close(1000, 'Normal closure')

// Close with an error code
socket.close(1011, 'Internal server error')
```

**Standard WebSocket close codes:**

| Code | Meaning |
| --- | --- |
| `1000` | Normal closure |
| `1001` | Going away (server shutting down) |
| `1002` | Protocol error |
| `1003` | Unsupported data |
| `1008` | Policy violation |
| `1011` | Internal server error |

---

### Accessing Query Parameters and Headers

The `request` object in the WebSocket handler comes from the HTTP upgrade request:

js

```js
app.get('/ws/feed', { websocket: true }, (socket, request) => {
  const { channel } = request.query   // ?channel=news
  const token = request.headers['authorization']

  socket.send(JSON.stringify({ subscribed: channel }))
})
```

**Key Points**

- Query string parsing follows Fastify's normal `querystringParser` configuration
- Route parameters (`:id`) are available on `request.params`
- Body is not available on WebSocket upgrade requests — data arrives via `socket` messages after connection

---

### Authentication with Hooks

Fastify hooks run before the WebSocket connection is established. Use `preHandler` or `onRequest` to authenticate:

js

```js
async function verifyToken(request, reply) {
  const token = request.headers['authorization']?.replace('Bearer ', '')

  if (!token || token !== 'valid-token') {
    reply.code(401).send({ error: 'Unauthorized' })
    // Returning a reply here aborts the upgrade — no WebSocket connection is made
  }
}

app.get('/ws/secure', {
  websocket: true,
  preHandler: verifyToken
}, (socket, request) => {
  socket.send('Authenticated connection established')
})
```

**Key Points**

- Sending a reply in `preHandler` prevents the WebSocket upgrade from completing
- The client receives a standard HTTP 401 response rather than a WebSocket connection
- This is the recommended pattern for guarding WebSocket routes [Inference — behavior depends on `@fastify/websocket` version; verify]

---

### Broadcasting to All Connected Clients

`app.websocketServer.clients` is a `Set` of all active `ws` connections:

js

```js
app.get('/ws/chat', { websocket: true }, (socket, request) => {
  socket.on('message', (rawMessage) => {
    const message = rawMessage.toString()

    // Broadcast to all connected clients
    for (const client of app.websocketServer.clients) {
      if (client.readyState === client.OPEN) {
        client.send(message)
      }
    }
  })
})
```

**Key Points**

- Always check `client.readyState === client.OPEN` before sending — clients may be in `CONNECTING`, `CLOSING`, or `CLOSED` states
- `app.websocketServer.clients` includes all clients across all WebSocket routes, not just the current route [Inference — verify if per-route client tracking is needed]
- For production broadcast patterns, a more structured pub/sub approach (per-room Maps, Redis pub/sub) is advisable [Inference]

---

### Per-Route Client Tracking

To track clients per route or channel, maintain your own `Set`:

js

```js
const rooms = new Map()

app.get('/ws/room/:roomId', { websocket: true }, (socket, request) => {
  const { roomId } = request.params

  if (!rooms.has(roomId)) {
    rooms.set(roomId, new Set())
  }

  const room = rooms.get(roomId)
  room.add(socket)

  socket.on('message', (rawMessage) => {
    for (const client of room) {
      if (client.readyState === client.OPEN) {
        client.send(rawMessage.toString())
      }
    }
  })

  socket.on('close', () => {
    room.delete(socket)
    if (room.size === 0) {
      rooms.delete(roomId)
    }
  })
})
```

---

### Ping / Pong and Connection Keep-Alive

The `ws` library supports ping/pong frames for detecting stale connections:

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  let isAlive = true

  socket.on('pong', () => {
    isAlive = true
  })

  const interval = setInterval(() => {
    if (!isAlive) {
      socket.terminate()
      return
    }
    isAlive = false
    socket.ping()
  }, 30_000)

  socket.on('close', () => {
    clearInterval(interval)
  })

  socket.on('message', (msg) => {
    socket.send(msg.toString())
  })
})
```

**Key Points**

- `socket.ping()` sends a WebSocket ping frame; the client responds with a pong automatically
- `socket.terminate()` forcibly destroys the connection without a close handshake — use when a client is unresponsive
- `socket.close()` sends a close frame and waits for the client to acknowledge — prefer this for graceful disconnection
- Always clear intervals in the `close` handler to avoid memory leaks

---

### Plugin-Scoped WebSocket Routes

WebSocket routes participate in Fastify's encapsulation model:

js

```js
// src/routes/chat.js
import fp from 'fastify-plugin'

async function chatRoutes(app, opts) {
  app.get('/ws/chat', { websocket: true }, (socket, request) => {
    socket.on('message', (msg) => {
      socket.send(`[chat] ${msg.toString()}`)
    })
  })
}

export default chatRoutes
```

js

```js
// src/app.js
import websocket from '@fastify/websocket'
import chatRoutes from './routes/chat.js'

await app.register(websocket)
await app.register(chatRoutes, { prefix: '/api' })
// WebSocket route available at /api/ws/chat
```

**Key Points**

- Route prefixes apply to WebSocket routes the same way they apply to HTTP routes
- `@fastify/websocket` must be registered at or above the scope where WebSocket routes are defined

---

### Handling Binary Messages

js

```js
app.get('/ws/binary', { websocket: true }, (socket, request) => {
  socket.on('message', (data, isBinary) => {
    if (isBinary) {
      // data is a Buffer
      console.log('Received binary:', data.byteLength, 'bytes')
      socket.send(data) // echo back as binary
    } else {
      socket.send(`Text: ${data.toString()}`)
    }
  })
})
```

**Key Points**

- The `message` event callback receives `(data, isBinary)` in `ws` v8+ [Unverified — verify against your installed `ws` version]
- Binary data arrives as a `Buffer`
- `socket.send(buffer)` sends binary frames when passed a `Buffer`

---

### Graceful Shutdown

Fastify's `app.close()` closes the HTTP server. WebSocket connections must also be terminated:

js

```js
process.on('SIGTERM', async () => {
  // Close all active WebSocket connections
  for (const client of app.websocketServer.clients) {
    client.close(1001, 'Server shutting down')
  }

  await app.close()
  process.exit(0)
})
```

**Key Points**

- `@fastify/websocket` registers a `onClose` hook that closes the underlying `ws` server when Fastify closes [Inference — verify with your version]
- Explicitly closing individual clients with code `1001` (Going Away) is courteous and enables clients to reconnect
- `client.close()` is not instantaneous — clients may still send messages during the close handshake

---

### Connection Lifecycle

WebSocket HandlerpreHandler HookFastifyClientWebSocket HandlerpreHandler HookFastifyClientloop[Connection open]alt[Auth fails][Auth passes]HTTP GET /ws (Upgrade: websocket)onRequest / preHandler401 Unauthorized (HTTP)continue101 Switching Protocols(socket, request)message eventsocket.send()close eventcleanup (clearInterval, room.delete)

---

### Common Pitfalls

**Not checking `readyState` before sending**
Calling `socket.send()` on a closing or closed socket throws an error. Always check `client.readyState === client.OPEN`.

**Not handling the `error` event**
Unhandled `error` events on a `ws` socket cause an uncaught exception. Always attach `socket.on('error', handler)`.

**Memory leaks from uncleaned intervals or room sets**
Intervals and external references to closed sockets persist in memory. Clear all intervals and remove sockets from tracking structures in the `close` handler.

**Calling `reply.send()` in WebSocket handlers**
WebSocket handlers do not use `reply`. Calling `reply.send()` in a WebSocket handler produces an error or has no effect. [Inference]

**Expecting `request.body` in WebSocket handlers**
The upgrade request has no body. Data exchange happens over the WebSocket connection itself after the handshake.

**Registering `@fastify/websocket` after routes**
WebSocket routes defined before `@fastify/websocket` is registered will not function correctly. Register the plugin first.

---

**Related Topics**

- Testing WebSocket routes with `app.inject()` and `@fastify/websocket` test utilities
- Authentication strategies for WebSocket connections (JWT via query param vs header)
- Using Redis pub/sub for multi-instance WebSocket broadcasting
- WebSocket rate limiting and abuse prevention
- Integrating WebSocket with Fastify's `onError` hook
- `ws` library advanced configuration (per-message deflate compression)
- Server-Sent Events (SSE) as an alternative to WebSockets for unidirectional streaming