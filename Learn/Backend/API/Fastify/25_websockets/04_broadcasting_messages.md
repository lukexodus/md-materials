## Broadcasting Messages

Broadcasting sends a message to multiple connected WebSocket clients simultaneously. Fastify provides no built-in broadcast API — broadcasting is implemented by iterating over client collections and calling `socket.send()` on each eligible connection.

---

### The `websocketServer.clients` Set

`@fastify/websocket` exposes the underlying `ws.Server` instance on `app.websocketServer`. Its `clients` property is a `Set` of all currently connected `WebSocket` instances across all WebSocket routes.

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  socket.on('message', (data) => {
    // Broadcast to every connected client
    for (const client of app.websocketServer.clients) {
      if (client.readyState === client.OPEN) {
        client.send(data.toString())
      }
    }
  })
})
```

**Key Points**

- `clients` is a live `Set` — it reflects the current connection state at the time of iteration
- Always check `client.readyState === client.OPEN` before sending — clients in `CLOSING` or `CLOSED` states will throw
- `clients` includes all clients across all WebSocket routes on the server, not just those connected to the current route [Inference — verify if route isolation is required]
- Modifying `clients` directly is not supported — it is managed internally by `ws`

---

### Broadcast Patterns

#### Broadcast to all clients

js

```js
function broadcast(wss, message) {
  const data = typeof message === 'string' ? message : JSON.stringify(message)

  for (const client of wss.clients) {
    if (client.readyState === client.OPEN) {
      client.send(data)
    }
  }
}

app.get('/ws', { websocket: true }, (socket, request) => {
  socket.on('message', (data) => {
    broadcast(app.websocketServer, { text: data.toString() })
  })
})
```

#### Broadcast to all except sender

js

```js
function broadcastExcept(wss, sender, message) {
  const data = typeof message === 'string' ? message : JSON.stringify(message)

  for (const client of wss.clients) {
    if (client !== sender && client.readyState === client.OPEN) {
      client.send(data)
    }
  }
}

app.get('/ws/chat', { websocket: true }, (socket, request) => {
  socket.on('message', (data) => {
    broadcastExcept(app.websocketServer, socket, data.toString())
  })
})
```

#### Send to a specific client

js

```js
function sendTo(target, message) {
  if (target.readyState === target.OPEN) {
    target.send(typeof message === 'string' ? message : JSON.stringify(message))
  }
}
```

---

### Per-Route Client Tracking

`websocketServer.clients` contains all clients globally. When you have multiple WebSocket routes and need to broadcast only within a route, maintain a separate `Set` per route:

js

```js
const chatClients = new Set()

app.get('/ws/chat', { websocket: true }, (socket, request) => {
  chatClients.add(socket)

  socket.on('message', (data) => {
    for (const client of chatClients) {
      if (client.readyState === client.OPEN) {
        client.send(data.toString())
      }
    }
  })

  socket.on('close', () => {
    chatClients.delete(socket)
  })
})
```

**Key Points**

- Always remove the socket from the `Set` in the `close` handler — closed sockets retained in a `Set` are a memory leak
- Module-level `Set` instances persist for the lifetime of the process — appropriate for global route state
- For plugin-scoped client sets, declare the `Set` inside the plugin function

---

### Room-Based Broadcasting

A room groups clients that share a subscription or context. Rooms are typically identified by a string key and stored in a `Map` of `Set`s.

js

```js
const rooms = new Map()

function joinRoom(roomId, socket) {
  if (!rooms.has(roomId)) {
    rooms.set(roomId, new Set())
  }
  rooms.get(roomId).add(socket)
}

function leaveRoom(roomId, socket) {
  const room = rooms.get(roomId)
  if (!room) return
  room.delete(socket)
  if (room.size === 0) rooms.delete(roomId)
}

function broadcastToRoom(roomId, message, exclude = null) {
  const room = rooms.get(roomId)
  if (!room) return

  const data = typeof message === 'string' ? message : JSON.stringify(message)

  for (const client of room) {
    if (client !== exclude && client.readyState === client.OPEN) {
      client.send(data)
    }
  }
}

app.get('/ws/room/:roomId', { websocket: true }, (socket, request) => {
  const { roomId } = request.params

  joinRoom(roomId, socket)
  broadcastToRoom(roomId, { event: 'join', roomId }, socket)

  socket.on('message', (data) => {
    let msg
    try {
      msg = JSON.parse(data.toString())
    } catch {
      socket.send(JSON.stringify({ error: 'Invalid JSON' }))
      return
    }

    broadcastToRoom(roomId, { event: 'message', text: msg.text }, socket)
  })

  socket.on('close', () => {
    leaveRoom(roomId, socket)
    broadcastToRoom(roomId, { event: 'leave', roomId })
  })
})
```

---

### Attaching Metadata to Sockets

Sockets are plain objects — attaching metadata makes filtering and targeted sends straightforward:

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  socket.userId = request.query.userId
  socket.role = request.query.role ?? 'user'
  socket.rooms = new Set()

  socket.on('close', () => {
    for (const roomId of socket.rooms) {
      leaveRoom(roomId, socket)
    }
  })
})
```

#### Broadcast to a role

js

```js
function broadcastToRole(wss, role, message) {
  const data = JSON.stringify(message)

  for (const client of wss.clients) {
    if (client.role === role && client.readyState === client.OPEN) {
      client.send(data)
    }
  }
}

broadcastToRole(app.websocketServer, 'admin', { event: 'alert', text: 'Server restarting' })
```

#### Broadcast to a specific user ID

js

```js
function sendToUser(wss, userId, message) {
  const data = JSON.stringify(message)

  for (const client of wss.clients) {
    if (client.userId === userId && client.readyState === client.OPEN) {
      client.send(data)
    }
  }
}
```

**Key Points**

- A user may have multiple concurrent connections — iterating all clients and matching by `userId` handles this naturally
- Attaching metadata directly to `socket` is a common pattern but mixes transport and application concerns [Inference — a `WeakMap` keyed on `socket` is a cleaner alternative]

---

### Using a `WeakMap` for Metadata

js

```js
const meta = new WeakMap()

app.get('/ws', { websocket: true }, (socket, request) => {
  meta.set(socket, {
    userId: request.query.userId,
    role: request.query.role ?? 'user',
    connectedAt: Date.now()
  })

  socket.on('close', () => {
    // WeakMap entry released automatically when socket is GC'd
  })
})

function broadcastToRole(wss, role, message) {
  const data = JSON.stringify(message)

  for (const client of wss.clients) {
    const m = meta.get(client)
    if (m?.role === role && client.readyState === client.OPEN) {
      client.send(data)
    }
  }
}
```

**Key Points**

- `WeakMap` entries are automatically eligible for garbage collection when the key (`socket`) is no longer reachable
- External collections (rooms, role indexes) still require explicit cleanup in `close` handlers
- `WeakMap` is not iterable — you cannot enumerate all metadata entries; use `wss.clients` as the source of truth for active connections

---

### Encapsulating Broadcast Logic in a Fastify Plugin

Keeping broadcast utilities as a Fastify decorator makes them available throughout the application:

js

```js
// src/plugins/broadcast.js
import fp from 'fastify-plugin'

async function broadcastPlugin(app, opts) {
  function broadcastAll(message) {
    const data = typeof message === 'string' ? message : JSON.stringify(message)
    for (const client of app.websocketServer.clients) {
      if (client.readyState === client.OPEN) {
        client.send(data)
      }
    }
  }

  function broadcastExcept(exclude, message) {
    const data = typeof message === 'string' ? message : JSON.stringify(message)
    for (const client of app.websocketServer.clients) {
      if (client !== exclude && client.readyState === client.OPEN) {
        client.send(data)
      }
    }
  }

  function broadcastToRoom(room, message, exclude = null) {
    const data = typeof message === 'string' ? message : JSON.stringify(message)
    for (const client of room) {
      if (client !== exclude && client.readyState === client.OPEN) {
        client.send(data)
      }
    }
  }

  app.decorate('broadcast', { broadcastAll, broadcastExcept, broadcastToRoom })
}

export default fp(broadcastPlugin)
```

js

```js
// usage in a route
app.get('/ws/chat', { websocket: true }, (socket, request) => {
  socket.on('message', (data) => {
    app.broadcast.broadcastExcept(socket, { text: data.toString() })
  })
})

// usage from an HTTP route (e.g. push a server-side event)
app.post('/admin/announce', async (request, reply) => {
  app.broadcast.broadcastAll({ event: 'announcement', text: request.body.text })
  return { sent: true }
})
```

**Key Points**

- `fp()` ensures the decorator is registered on the root Fastify instance, visible to all scopes
- Triggering broadcasts from HTTP routes is a common pattern for server-initiated push events
- `app.websocketServer` must be available at the time `broadcastPlugin` executes — register `@fastify/websocket` before this plugin [Inference]

---

### Server-Initiated Broadcasting

Broadcasts do not have to originate from a WebSocket message. Any part of the application can trigger one:

js

```js
// Broadcast on a timer
setInterval(() => {
  app.broadcast.broadcastAll({
    event: 'heartbeat',
    timestamp: Date.now()
  })
}, 10_000)

// Broadcast from an HTTP endpoint
app.post('/notify', async (request, reply) => {
  const { userId, message } = request.body

  for (const client of app.websocketServer.clients) {
    if (client.userId === userId && client.readyState === client.OPEN) {
      client.send(JSON.stringify({ event: 'notify', message }))
    }
  }

  return { delivered: true }
})
```

---

### Multi-Instance Broadcasting with Redis Pub/Sub

A single Node.js process only has access to its own `wss.clients`. In a multi-instance deployment (multiple Fastify processes behind a load balancer), each process has its own client set. A message received by instance A cannot directly reach clients connected to instance B.

Redis pub/sub bridges this gap:

js

```js
import { createClient } from 'redis'

const publisher = createClient({ url: process.env.REDIS_URL })
const subscriber = createClient({ url: process.env.REDIS_URL })

await publisher.connect()
await subscriber.connect()

// Subscribe to the broadcast channel
await subscriber.subscribe('ws:broadcast', (message) => {
  // Deliver to all local clients when a broadcast arrives
  for (const client of app.websocketServer.clients) {
    if (client.readyState === client.OPEN) {
      client.send(message)
    }
  }
})

// Publish from any instance
app.post('/notify', async (request, reply) => {
  await publisher.publish('ws:broadcast', JSON.stringify(request.body))
  return { published: true }
})

// Broadcast from a WebSocket handler via Redis
app.get('/ws/chat', { websocket: true }, (socket, request) => {
  socket.on('message', async (data) => {
    await publisher.publish('ws:broadcast', data.toString())
  })
})
```

**Key Points**

- Each instance subscribes to the same Redis channel and delivers to its own local clients
- The publishing instance will also receive its own published message via the subscriber — filter by `instanceId` if self-delivery should be skipped [Inference]
- Redis pub/sub does not persist messages — clients that are offline when a message is published do not receive it
- For room-based multi-instance broadcasting, use per-room Redis channels: `ws:room:${roomId}`

---

### Broadcasting Flow

All clientsExclude senderRoomUser IDYesNoYesNoMessage sourceWS message or HTTProute or timerScopeIterate wss.clientsIterate wss.clientsskip senderIterate room SetIterate wss.clientsfilter by userIdreadyState === OPEN?client.send dataSkip clientNext clientMore clients?Broadcast complete

---

### Performance Considerations

**Serialization inside the loop**
Serialize message data once before the loop, not inside it:

js

```js
// Correct — serialize once
const data = JSON.stringify(message)
for (const client of wss.clients) {
  if (client.readyState === client.OPEN) client.send(data)
}

// Incorrect — serializes on every iteration
for (const client of wss.clients) {
  if (client.readyState === client.OPEN) client.send(JSON.stringify(message))
}
```

**Large client sets**
Iterating thousands of clients synchronously blocks the event loop. For very large sets, consider chunking with `setImmediate`:

js

```js
async function broadcastChunked(clients, data, chunkSize = 100) {
  const arr = [...clients]
  for (let i = 0; i < arr.length; i += chunkSize) {
    const chunk = arr.slice(i, i + chunkSize)
    for (const client of chunk) {
      if (client.readyState === client.OPEN) client.send(data)
    }
    await new Promise(resolve => setImmediate(resolve))
  }
}
```

**Key Points**

- `setImmediate` yields to the event loop between chunks, allowing other I/O to proceed [Inference — measure actual impact before applying; overhead may outweigh benefit for moderate client counts]
- For broadcast-heavy workloads, consider dedicated WebSocket libraries or worker threads [Speculation]

---

### Common Pitfalls

**Not checking `readyState` before sending**
Sending to a non-`OPEN` socket throws. Always guard.

**Serializing inside the broadcast loop**
`JSON.stringify` on every iteration is wasteful for large client sets. Serialize once before the loop.

**Not removing sockets from room Sets on close**
Stale closed sockets in room Sets accumulate over time and cause errors when broadcast attempts to send to them.

**Using `websocketServer.clients` for per-route broadcasting**
It contains all clients across all routes. Use a dedicated per-route or per-room `Set` when scoping is needed.

**Blocking the event loop with large synchronous broadcasts**
Broadcasting synchronously to thousands of clients without yielding can delay other requests. Profile before optimizing.

---

**Related Topics**

- Pub/sub patterns with Redis Streams for ordered message delivery
- Presence tracking (online/offline user lists)
- Acknowledging messages and implementing delivery guarantees
- Rate limiting per-client message sends
- Backpressure detection and slow client handling
- Namespacing broadcast channels for multi-tenant applications
- Testing broadcast behavior with multiple injected connections