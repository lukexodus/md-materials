## Managing Connections

Connection management covers tracking active WebSocket connections, associating metadata with them, detecting and removing stale connections, handling disconnections cleanly, and controlling resource usage as connection counts grow. Without explicit management, connections accumulate state, leak memory, and degrade server performance.

---

### What Needs Managing

- **Tracking** — knowing which connections are active at any moment
- **Metadata** — associating application-level data (user ID, role, rooms) with each connection
- **Liveness** — detecting connections that are broken but not yet closed
- **Cleanup** — releasing resources when a connection closes
- **Limits** — rejecting connections when capacity is reached
- **Graceful shutdown** — closing all connections cleanly when the server stops

---

### The `clients` Set

`app.websocketServer.clients` is the canonical source of active connections managed by `ws`:

js

```js
// Count active connections
const count = app.websocketServer.clients.size

// Iterate all active connections
for (const socket of app.websocketServer.clients) {
  console.log(socket.readyState)
}
```

**Key Points**

- `clients` is updated by `ws` automatically — sockets are added on connection and removed after the close handshake completes
- `clients.size` reflects connections across all WebSocket routes
- Do not mutate `clients` directly — it is managed internally by `ws`
- A socket remains in `clients` until the close handshake fully completes, not at the moment `close` fires on the handler side [Inference — verify against your `ws` version]

---

### Per-Route Connection Tracking

When multiple WebSocket routes exist, maintain separate tracking structures per route:

js

```js
// src/plugins/connections.js
import fp from 'fastify-plugin'

async function connectionsPlugin(app, opts) {
  const connections = new Map() // routeKey -> Set<WebSocket>

  function register(routeKey, socket) {
    if (!connections.has(routeKey)) {
      connections.set(routeKey, new Set())
    }
    connections.get(routeKey).add(socket)
  }

  function unregister(routeKey, socket) {
    const set = connections.get(routeKey)
    if (!set) return
    set.delete(socket)
    if (set.size === 0) connections.delete(routeKey)
  }

  function getConnections(routeKey) {
    return connections.get(routeKey) ?? new Set()
  }

  function countAll() {
    let total = 0
    for (const set of connections.values()) total += set.size
    return total
  }

  app.decorate('connections', { register, unregister, getConnections, countAll })
}

export default fp(connectionsPlugin)
```

js

```js
app.get('/ws/chat', { websocket: true }, (socket, request) => {
  app.connections.register('chat', socket)

  socket.on('close', () => {
    app.connections.unregister('chat', socket)
  })
})
```

---

### Associating Metadata with Connections

#### Direct property attachment

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  socket.userId = request.query.userId
  socket.role = request.headers['x-role'] ?? 'user'
  socket.connectedAt = Date.now()
})
```

#### `WeakMap`-based metadata (preferred for separation of concerns)

js

```js
const meta = new WeakMap()

app.get('/ws', { websocket: true }, (socket, request) => {
  meta.set(socket, {
    userId: request.query.userId,
    role: request.headers['x-role'] ?? 'user',
    connectedAt: Date.now(),
    messageCount: 0
  })

  socket.on('message', () => {
    const m = meta.get(socket)
    m.messageCount++
  })

  socket.on('close', () => {
    // No manual cleanup needed — WeakMap entry released when socket is GC'd
    // Clean up external references (rooms, indexes) here instead
  })
})
```

**Key Points**

- `WeakMap` does not prevent garbage collection of the socket — when all references to the socket are gone, the entry is released automatically
- `WeakMap` is not iterable — use `wss.clients` as the source of iteration and look up metadata per socket
- Direct property attachment is simpler but mixes transport and application state

---

### Connection Registry with Indexing

For efficient lookup by user ID or other attributes, maintain indexes alongside the client set:

js

```js
// src/plugins/registry.js
import fp from 'fastify-plugin'

async function registryPlugin(app, opts) {
  const byUserId = new Map()   // userId -> Set<WebSocket>
  const bySocket = new WeakMap() // socket -> { userId, ... }

  function add(socket, metadata) {
    bySocket.set(socket, metadata)

    const { userId } = metadata
    if (userId) {
      if (!byUserId.has(userId)) byUserId.set(userId, new Set())
      byUserId.get(userId).add(socket)
    }
  }

  function remove(socket) {
    const metadata = bySocket.get(socket)
    if (!metadata) return

    const { userId } = metadata
    if (userId) {
      const set = byUserId.get(userId)
      if (set) {
        set.delete(socket)
        if (set.size === 0) byUserId.delete(userId)
      }
    }
  }

  function getByUserId(userId) {
    return byUserId.get(userId) ?? new Set()
  }

  function getMeta(socket) {
    return bySocket.get(socket)
  }

  app.decorate('registry', { add, remove, getByUserId, getMeta })
}

export default fp(registryPlugin)
```

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  app.registry.add(socket, {
    userId: request.query.userId,
    connectedAt: Date.now()
  })

  socket.on('close', () => {
    app.registry.remove(socket)
  })
})

// Send to all connections for a specific user
app.post('/notify/:userId', async (request, reply) => {
  const sockets = app.registry.getByUserId(request.params.userId)
  const data = JSON.stringify(request.body)

  for (const socket of sockets) {
    if (socket.readyState === socket.OPEN) {
      socket.send(data)
    }
  }

  return { delivered: sockets.size }
})
```

---

### Liveness Detection — Ping / Pong Heartbeat

TCP connections can silently drop without a close frame being sent (network interruption, client crash, NAT timeout). A heartbeat detects these stale connections.

js

```js
// src/plugins/heartbeat.js
import fp from 'fastify-plugin'

async function heartbeatPlugin(app, opts) {
  const interval = opts.interval ?? 30_000
  const isAlive = new WeakMap()

  let timer

  app.addHook('onReady', async () => {
    timer = setInterval(() => {
      for (const socket of app.websocketServer.clients) {
        if (isAlive.get(socket) === false) {
          // Did not respond to last ping — terminate
          socket.terminate()
          return
        }

        isAlive.set(socket, false)
        socket.ping()
      }
    }, interval)
  })

  app.addHook('onClose', async () => {
    clearInterval(timer)
  })

  // Routes register sockets with the heartbeat system
  app.decorate('heartbeat', {
    track(socket) {
      isAlive.set(socket, true)

      socket.on('pong', () => {
        isAlive.set(socket, true)
      })
    }
  })
}

export default fp(heartbeatPlugin)
```

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  app.heartbeat.track(socket)

  socket.on('message', (data) => {
    socket.send(data.toString())
  })
})
```

**Key Points**

- `socket.ping()` sends a WebSocket ping control frame; `ws` automatically sends pong back from the client side
- `socket.terminate()` forcibly destroys the TCP connection without a close handshake — use only for unresponsive sockets
- `socket.close()` initiates a clean close handshake — prefer this when the remote end is still reachable
- The heartbeat interval fires on `onReady` to ensure `app.websocketServer` is available [Inference]
- `WeakMap` for `isAlive` avoids retaining references to closed sockets

---

### Connection Limits

Reject new connections when a capacity limit is reached:

js

```js
const MAX_CONNECTIONS = 1000

app.get('/ws', {
  websocket: true,
  preHandler: async (request, reply) => {
    if (app.websocketServer.clients.size >= MAX_CONNECTIONS) {
      reply.code(503).send({ error: 'Server at capacity' })
    }
  }
}, (socket, request) => {
  socket.send('Connected')
})
```

**Key Points**

- `preHandler` runs before the WebSocket upgrade completes — rejecting here sends an HTTP response, not a WebSocket close frame
- `wss.clients.size` at the time of the check reflects currently connected clients; the new connection is not yet in the set [Inference]
- For per-user connection limits, check `registry.getByUserId(userId).size` before accepting

#### Per-user connection limit

js

```js
const MAX_PER_USER = 3

app.get('/ws', {
  websocket: true,
  preHandler: async (request, reply) => {
    const userId = request.query.userId
    const existing = app.registry.getByUserId(userId)

    if (existing.size >= MAX_PER_USER) {
      reply.code(429).send({ error: 'Connection limit reached' })
    }
  }
}, (socket, request) => {
  app.registry.add(socket, { userId: request.query.userId })

  socket.on('close', () => {
    app.registry.remove(socket)
  })
})
```

---

### Tracking Connection Duration and Activity

js

```js
const meta = new WeakMap()

app.get('/ws', { websocket: true }, (socket, request) => {
  meta.set(socket, {
    connectedAt: Date.now(),
    lastMessageAt: null,
    messageCount: 0
  })

  socket.on('message', () => {
    const m = meta.get(socket)
    m.lastMessageAt = Date.now()
    m.messageCount++
  })

  socket.on('close', (code, reason) => {
    const m = meta.get(socket)
    const duration = Date.now() - m.connectedAt
    app.log.info({
      event: 'ws_close',
      code,
      reason: reason.toString(),
      duration,
      messageCount: m.messageCount
    })
  })
})
```

---

### Idle Connection Timeout

Disconnect clients that have not sent a message within a time window:

js

```js
const IDLE_TIMEOUT_MS = 5 * 60 * 1000 // 5 minutes

app.get('/ws', { websocket: true }, (socket, request) => {
  let idleTimer = setTimeout(() => {
    socket.close(1001, 'Idle timeout')
  }, IDLE_TIMEOUT_MS)

  function resetIdle() {
    clearTimeout(idleTimer)
    idleTimer = setTimeout(() => {
      socket.close(1001, 'Idle timeout')
    }, IDLE_TIMEOUT_MS)
  }

  socket.on('message', () => {
    resetIdle()
    // handle message
  })

  socket.on('close', () => {
    clearTimeout(idleTimer)
  })
})
```

**Key Points**

- Always clear the timer in `close` — failing to do so keeps the timer reference alive and may call `socket.close()` on an already-closed socket
- `socket.close()` on an already-closed socket is a no-op in `ws` [Inference — verify against your version]
- Idle timeouts and heartbeat intervals serve different purposes: heartbeats detect dead TCP connections; idle timeouts disconnect inactive but live connections

---

### Graceful Shutdown

When Fastify receives a shutdown signal, all WebSocket connections should be closed cleanly:

js

```js
async function shutdown() {
  app.log.info('Shutting down — closing WebSocket connections')

  const closing = []

  for (const socket of app.websocketServer.clients) {
    closing.push(
      new Promise((resolve) => {
        socket.once('close', resolve)
        socket.close(1001, 'Server shutting down')
      })
    )
  }

  // Wait for all connections to close, with a timeout
  await Promise.race([
    Promise.all(closing),
    new Promise((resolve) => setTimeout(resolve, 5000))
  ])

  await app.close()
  process.exit(0)
}

process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)
```

**Key Points**

- `socket.close(1001, ...)` initiates a clean close handshake — clients receive the code and reason and can reconnect
- The `Promise.race` with a timeout prevents shutdown from hanging if a client does not respond to the close frame
- After the timeout, `app.close()` closes the HTTP server; `@fastify/websocket` closes the `ws.Server`, terminating any remaining connections [Inference]
- `process.exit(0)` after `app.close()` ensures the process exits even if open handles remain

---

### Exposing Connection Metrics via HTTP

js

```js
app.get('/metrics/connections', async (request, reply) => {
  const total = app.websocketServer.clients.size
  const open = [...app.websocketServer.clients]
    .filter(c => c.readyState === c.OPEN).length

  return {
    total,
    open,
    closing: total - open
  }
})
```

---

### Connection Lifecycle

RejectedAcceptedmessage eventping intervalYesNoIdle timeoutClient closesServer shutdownClient sends UpgraderequestpreHandler — auth + limitchecksHTTP 401 / 429 / 503101 Switching ProtocolsHandler firesMetadata registeredHeartbeat trackedConnection activeHandle messageReset idle timerUpdate lastMessageAtisAlive?Set isAlive falseSend pingsocket.terminatesocket.close 1001close event firesCleanupRemove from registryClear timersLeave roomsSocket eligible for GC

---

### Common Pitfalls

**Not removing sockets from tracking structures on close**
Closed sockets retained in `Map` or `Set` instances are memory leaks. Always call cleanup in the `close` handler.

**Using `clients.size` as an exact capacity check**
The new socket is not in `clients` yet when `preHandler` runs — off-by-one behavior is possible under high concurrency [Inference].

**Not clearing timers in `close`**
Idle timers and heartbeat intervals that reference a closed socket can call methods on it after closure. Always `clearTimeout` / `clearInterval` in `close`.

**Assuming `close` fires immediately on network drop**
A broken TCP connection without a close frame may not trigger `close` until the heartbeat times out. Do not rely on `close` for prompt stale connection detection.

**Calling `socket.terminate()` for routine disconnection**
`terminate()` destroys the TCP connection abruptly. Prefer `socket.close(code, reason)` for intentional disconnections so clients can handle the code and attempt reconnection.

---

**Related Topics**

- Room-based connection grouping and membership management
- Rate limiting per-connection message throughput
- Distributing connection state across multiple instances with Redis
- Monitoring connection counts with Fastify metrics plugins (`@fastify/metrics`, Prometheus)
- Reconnection strategies and session resumption on the client side
- WebSocket connection pooling for server-to-server communication
- Testing connection lifecycle events with mock WebSocket clients