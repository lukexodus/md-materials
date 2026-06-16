## WebSocket Route Handlers

WebSocket route handlers in Fastify are defined using the same routing API as HTTP routes, with `{ websocket: true }` in the route options. The handler signature, lifecycle, and available APIs differ meaningfully from HTTP handlers — understanding these differences is essential for writing correct WebSocket logic.

---

### Handler Signature

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  // socket — ws WebSocket instance
  // request — Fastify request object (from the upgrade handshake)
})
```

**Key Points**

- The handler is not `async` by default — it is a synchronous event-driven function that registers listeners
- `socket` is a `ws` `WebSocket` instance, not a Fastify construct
- `request` is the standard Fastify `FastifyRequest` object, populated from the HTTP upgrade request
- There is no `reply` parameter — responses are sent via `socket.send()`
- The handler fires once per connection, not once per message

---

### Async Handlers

The handler can be declared `async`, but this has a specific implication: the returned promise is awaited before the connection is considered fully set up. Rejecting the promise closes the connection.

js

```js
app.get('/ws', { websocket: true }, async (socket, request) => {
  const user = await authenticateFromRequest(request)

  if (!user) {
    socket.close(1008, 'Policy violation')
    return
  }

  socket.on('message', (msg) => {
    socket.send(`Hello, ${user.name}: ${msg.toString()}`)
  })
})
```

**Key Points**

- Any `await` before registering event listeners means messages arriving during that gap may be missed [Inference — behavior depends on `ws` buffering; verify with your version]
- For async setup, register listeners immediately and perform async work inside the `message` handler, or use a ready flag
- Throwing inside an async handler closes the socket [Inference]

---

### Registering Socket Event Listeners

The core of every WebSocket handler is registering listeners on the `socket` object:

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  socket.on('message', (data, isBinary) => {
    // Fired for each incoming message frame
  })

  socket.on('close', (code, reason) => {
    // Fired when the connection is closed (by either side)
  })

  socket.on('error', (err) => {
    // Fired on socket-level errors
  })

  socket.on('pong', () => {
    // Fired when client responds to a ping
  })

  socket.on('ping', (data) => {
    // Fired when client sends a ping (ws responds automatically)
  })
})
```

**Key Points**

- All listeners must be registered synchronously inside the handler (or synchronously before any `await`)
- `message` fires for every complete WebSocket message frame received
- `close` fires regardless of which side initiated the close
- `error` must always be handled — an unhandled `error` event causes an uncaught exception in Node.js
- `ws` automatically responds to client-initiated pings with a pong — you do not need to handle this manually [Inference — verify against your `ws` version]

---

### The `message` Event in Detail

js

```js
socket.on('message', (data, isBinary) => {
  // data: Buffer (always a Buffer in ws v8+)
  // isBinary: boolean — true if the frame was sent as binary
})
```

#### Text messages

js

```js
socket.on('message', (data, isBinary) => {
  if (!isBinary) {
    const text = data.toString('utf8')
    console.log('Text received:', text)
  }
})
```

#### JSON messages

js

```js
socket.on('message', (data, isBinary) => {
  if (isBinary) return

  let parsed
  try {
    parsed = JSON.parse(data.toString())
  } catch {
    socket.send(JSON.stringify({ error: 'Invalid JSON' }))
    return
  }

  handleMessage(socket, parsed)
})
```

#### Binary messages

js

```js
socket.on('message', (data, isBinary) => {
  if (isBinary) {
    // data is a Buffer of arbitrary binary content
    const view = new Uint8Array(data)
    socket.send(data) // echo binary back
  }
})
```

**Key Points**

- `data` is always a `Buffer` regardless of `isBinary` in `ws` v8+ [Unverified — verify against your installed `ws` version]
- `isBinary` reflects the WebSocket opcode: `0x1` (text frame) → `false`, `0x2` (binary frame) → `true`
- The WebSocket protocol does not enforce UTF-8 validity on binary frames — invalid UTF-8 in text frames may cause client-side errors

---

### Sending Messages

js

```js
// Text
socket.send('Hello')

// JSON
socket.send(JSON.stringify({ type: 'ack', id: 42 }))

// Buffer (binary)
socket.send(Buffer.from([0x01, 0x02, 0x03]))

// With callback for error detection
socket.send('Hello', (err) => {
  if (err) {
    console.error('Send failed:', err)
  }
})

// With options
socket.send('Hello', { compress: true, binary: false, fin: true }, (err) => {
  if (err) console.error(err)
})
```

**Key Points**

- `socket.send()` is non-blocking — it queues the data and returns immediately
- The optional callback fires when the data has been flushed to the OS network buffer, not when the client has received it [Inference]
- `socket.bufferedAmount` is not available on the server-side `ws` instance (it is a browser API) — use `socket.readyState` and the callback to manage backpressure [Inference]
- Calling `socket.send()` when `readyState` is not `OPEN` throws an error

---

### Checking `readyState` Before Sending

js

```js
function safeSend(socket, data) {
  if (socket.readyState === socket.OPEN) {
    socket.send(data)
  }
}
```

| `readyState` | Value | Meaning |
| --- | --- | --- |
| `CONNECTING` | `0` | Handshake in progress |
| `OPEN` | `1` | Connection is active |
| `CLOSING` | `2` | Close handshake initiated |
| `CLOSED` | `3` | Connection fully closed |

---

### The `close` Event in Detail

js

```js
socket.on('close', (code, reason) => {
  // code: number — WebSocket close code
  // reason: Buffer — close reason string as Buffer
  console.log(`Closed: ${code} — ${reason.toString()}`)
})
```

#### Common close codes

| Code | Meaning |
| --- | --- |
| `1000` | Normal closure |
| `1001` | Going away (endpoint shutting down) |
| `1006` | Abnormal closure — connection lost without close frame |
| `1008` | Policy violation |
| `1011` | Internal server error |

**Key Points**

- `reason` is a `Buffer` in `ws` — call `.toString()` to read it
- Code `1006` is generated locally by the `ws` library when the TCP connection drops without a clean close frame — it is never sent over the wire [Inference]
- Always clean up external resources (timers, room memberships, DB subscriptions) in the `close` handler

---

### Route Parameters and Query Strings

The `request` object gives access to the upgrade request's URL data:

js

```js
app.get('/ws/room/:roomId', { websocket: true }, (socket, request) => {
  const { roomId } = request.params       // route params
  const { token } = request.query         // query string
  const ua = request.headers['user-agent']

  socket.send(JSON.stringify({ joined: roomId }))
})
```

**Key Points**

- `request.params` and `request.query` are parsed by Fastify using the same mechanisms as HTTP routes
- `request.body` is not populated for WebSocket upgrade requests — body data is not part of the upgrade handshake
- `request.id` is available and unique per connection — useful for logging

---

### Route Schema for WebSocket Routes

Schema validation applies to the upgrade request's `querystring`, `params`, and `headers` — not to WebSocket message bodies (which are outside Fastify's schema system).

js

```js
app.get('/ws/room/:roomId', {
  websocket: true,
  schema: {
    params: {
      type: 'object',
      properties: {
        roomId: { type: 'string', minLength: 1 }
      },
      required: ['roomId']
    },
    querystring: {
      type: 'object',
      properties: {
        token: { type: 'string' }
      },
      required: ['token']
    }
  }
}, (socket, request) => {
  socket.send(JSON.stringify({ room: request.params.roomId }))
})
```

**Key Points**

- Validation failure returns a `400` HTTP response before the WebSocket upgrade completes — the client never establishes a socket connection
- `response` schema has no effect on WebSocket routes — there is no structured HTTP response body to serialize
- Message-level schema validation must be implemented manually in the `message` handler

---

### Message Routing by Type

For protocols that send structured messages, dispatch by type in the `message` handler:

js

```js
const handlers = {
  ping: (socket, payload) => {
    socket.send(JSON.stringify({ type: 'pong' }))
  },
  subscribe: (socket, payload) => {
    subscribeToChannel(socket, payload.channel)
  },
  unsubscribe: (socket, payload) => {
    unsubscribeFromChannel(socket, payload.channel)
  }
}

app.get('/ws', { websocket: true }, (socket, request) => {
  socket.on('message', (data) => {
    let msg

    try {
      msg = JSON.parse(data.toString())
    } catch {
      socket.send(JSON.stringify({ error: 'Invalid JSON' }))
      return
    }

    const handler = handlers[msg.type]

    if (!handler) {
      socket.send(JSON.stringify({ error: `Unknown type: ${msg.type}` }))
      return
    }

    handler(socket, msg.payload ?? {})
  })
})
```

---

### Attaching State to a Connection

The `ws` `WebSocket` instance is a plain object — you can attach arbitrary properties to track per-connection state:

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  // Attach state directly to the socket object
  socket.userId = request.query.userId
  socket.rooms = new Set()
  socket.isAlive = true

  socket.on('message', (data) => {
    console.log(`Message from user ${socket.userId}`)
  })

  socket.on('close', () => {
    for (const room of socket.rooms) {
      room.delete(socket)
    }
  })
})
```

**Key Points**

- Attaching state to `socket` is a common pattern but couples state to the transport layer [Inference — consider a `WeakMap` keyed on `socket` for cleaner separation]
- Properties survive across messages for the lifetime of the connection
- Properties are garbage-collected when the socket is closed and all references to it are released

---

### Using a `WeakMap` for Connection State

js

```js
const connectionState = new WeakMap()

app.get('/ws', { websocket: true }, (socket, request) => {
  connectionState.set(socket, {
    userId: request.query.userId,
    rooms: new Set(),
    connectedAt: Date.now()
  })

  socket.on('message', (data) => {
    const state = connectionState.get(socket)
    console.log(`Message from ${state.userId}`)
  })

  socket.on('close', () => {
    // WeakMap entry is automatically eligible for GC
    // once socket is no longer referenced
  })
})
```

**Key Points**

- `WeakMap` holds keys weakly — when the `socket` object is garbage-collected, the state entry is eligible for collection too
- No manual cleanup needed in the `close` handler for the `WeakMap` entry itself
- External references (room sets, broadcast lists) still need explicit cleanup in `close`

---

### Multiple WebSocket Routes

Each route gets its own handler scope. Routes are matched by path as normal:

js

```js
app.get('/ws/chat', { websocket: true }, (socket, request) => {
  socket.send('Welcome to chat')
})

app.get('/ws/notifications', { websocket: true }, (socket, request) => {
  socket.send('Subscribed to notifications')
})

app.get('/ws/admin', {
  websocket: true,
  preHandler: requireAdminRole
}, (socket, request) => {
  socket.send('Admin channel open')
})
```

**Key Points**

- `app.websocketServer.clients` contains all connected clients across all WebSocket routes
- Per-route client tracking requires maintaining your own data structures
- `preHandler` hooks are route-scoped and run before the upgrade completes

---

### Handler Lifecycle Diagram

NoYesmessagepingerrorcloseClient sends UpgraderequestFastify runs onRequesthooksFastify runs preHandlerhooksHooks passed?HTTP error responseUpgrade rejectedws completes handshake101 Switching ProtocolsWebSocket handler firessocket + requestEvent listeners registeredEventsmessage handlerAuto pong sent by wserror handlerclose handlerCleanup runsSocket eligible for GC

---

### Common Pitfalls

**Forgetting `socket.on('error')`**
Every WebSocket handler must attach an error listener. An unhandled `error` event crashes the process.

**Registering listeners after an `await`**
Messages can arrive between the `await` and the listener registration. Register all listeners synchronously at the top of the handler.

**Sending without checking `readyState`**
Calling `socket.send()` on a non-`OPEN` socket throws. Always guard with a `readyState` check when sending outside the `message` handler.

**Not cleaning up in `close`**
Timers, room memberships, and external subscriptions attached to a socket must be explicitly removed in the `close` handler.

**Using `reply` in a WebSocket handler**
WebSocket handlers have no `reply`. Any attempt to use it will fail or have no effect.

**Assuming `request.body` is populated**
The upgrade handshake has no body. Initial client data must arrive as a WebSocket message after the connection is established.

---

**Related Topics**

- Broadcasting and per-room connection management
- Ping/pong heartbeat implementation for stale connection detection
- Integrating WebSocket handlers with Fastify decorators and services
- Error handling strategies in WebSocket message dispatchers
- Testing WebSocket handlers with `@fastify/websocket` test utilities
- Backpressure management for high-throughput WebSocket streams
- Structured message protocols (`graphql-ws`, custom binary protocols)