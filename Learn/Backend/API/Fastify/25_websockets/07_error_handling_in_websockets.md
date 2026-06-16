## Error Handling in WebSockets

WebSocket error handling differs fundamentally from HTTP error handling. There is no `reply` object, no centralized error serializer, and no automatic status code mapping. Errors surface through socket events, close codes, and application-level message protocols — all of which must be managed explicitly.

---

### Sources of Errors

| Source | Event or mechanism |
| --- | --- |
| Socket-level transport error | `socket.on('error')` |
| Remote end closed abnormally | `socket.on('close')` with code `1006` |
| Application logic error (thrown in handler) | Uncaught exception or async rejection |
| Invalid message format | Manual detection in `message` handler |
| Failed authentication | `preHandler` reply — HTTP before upgrade |
| Token expiry mid-connection | Manual detection per message |
| Broadcast to non-open socket | `Error` thrown by `socket.send()` |
| Plugin or decorator failure during setup | Async handler rejection |

---

### The `error` Event

Every WebSocket socket emits `error` for transport-level failures. An unhandled `error` event causes an uncaught exception in Node.js — always attach a listener.

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  socket.on('error', (err) => {
    app.log.error({ err, socketId: request.id }, 'WebSocket error')
    // socket may or may not still be open after this — check readyState
  })

  socket.on('message', (data) => {
    socket.send(data.toString())
  })
})
```

**Key Points**

- `error` does not automatically close the socket — check `socket.readyState` and call `socket.close()` or `socket.terminate()` if appropriate [Inference — behavior may vary by error type; verify with your `ws` version]
- `error` is followed by `close` in most cases, but do not assume this — handle cleanup in `close`, not in `error`
- Log the error with context (socket ID, user ID, remote address) before deciding whether to close

---

### Errors from `socket.send()`

`socket.send()` does not throw synchronously for most failures — errors surface through its optional callback:

js

```js
socket.send(JSON.stringify({ event: 'update' }), (err) => {
  if (err) {
    app.log.warn({ err }, 'Failed to send message')
    // Do not attempt to re-send here — the socket may be closing
  }
})
```

**Sending to a non-OPEN socket throws synchronously:**

js

```js
function safeSend(socket, data) {
  if (socket.readyState !== socket.OPEN) {
    app.log.warn('Attempted to send to non-open socket')
    return
  }

  const payload = typeof data === 'string' ? data : JSON.stringify(data)

  socket.send(payload, (err) => {
    if (err) app.log.warn({ err }, 'Send error')
  })
}
```

**Key Points**

- Calling `socket.send()` when `readyState` is `CLOSING` or `CLOSED` throws a synchronous `Error`
- Always guard with `readyState === socket.OPEN` when sending outside the `message` handler
- The send callback fires when the data is written to the OS buffer, not when the client has received it [Inference]

---

### Errors in the `message` Handler

Exceptions thrown inside a `message` listener are not caught by Fastify's error handler — they propagate to Node.js's uncaught exception machinery unless handled explicitly.

#### Wrapping the message handler

js

```js
socket.on('message', (data) => {
  try {
    const msg = JSON.parse(data.toString())
    handleMessage(socket, msg)
  } catch (err) {
    app.log.error({ err }, 'Message handling error')
    safeSend(socket, { error: 'Internal error', code: 'INTERNAL' })
  }
})
```

#### Async message handler

js

```js
socket.on('message', async (data) => {
  try {
    const msg = JSON.parse(data.toString())
    await handleMessage(socket, msg)
  } catch (err) {
    app.log.error({ err }, 'Async message error')
    safeSend(socket, { error: 'Internal error' })
  }
})
```

**Key Points**

- `socket.on('message', async ...)` does not propagate rejected promises to any Fastify error handler — the `try/catch` inside the handler is mandatory [Inference]
- Do not re-throw inside the `message` listener — there is no surrounding catch boundary
- Distinguish between client errors (bad input) and server errors (unexpected failure) in your error response

---

### Application-Level Error Protocol

WebSocket has no built-in mechanism for structured error responses. Define an application-level error message format and send it over the socket:

js

```js
function sendError(socket, code, message, details = null) {
  safeSend(socket, {
    type: 'error',
    code,
    message,
    ...(details && { details }),
    timestamp: Date.now()
  })
}
```

js

```js
socket.on('message', (data) => {
  let msg

  try {
    msg = JSON.parse(data.toString())
  } catch {
    sendError(socket, 'PARSE_ERROR', 'Message must be valid JSON')
    return
  }

  if (!msg.type) {
    sendError(socket, 'MISSING_TYPE', 'Message must include a type field')
    return
  }

  const handler = messageHandlers[msg.type]

  if (!handler) {
    sendError(socket, 'UNKNOWN_TYPE', `Unknown message type: ${msg.type}`)
    return
  }

  try {
    handler(socket, msg)
  } catch (err) {
    app.log.error({ err, type: msg.type }, 'Handler error')
    sendError(socket, 'INTERNAL', 'An internal error occurred')
  }
})
```

**Key Points**

- A consistent error envelope (`type`, `code`, `message`) makes client-side error handling predictable
- Avoid including stack traces or internal details in error messages sent to clients
- `code` as a string constant (e.g. `'PARSE_ERROR'`) is more stable across versions than numeric codes [Inference]

---

### WebSocket Close Codes for Errors

When an error warrants closing the connection, use a meaningful close code:

js

```js
// Policy violation — e.g. unauthenticated message
socket.close(1008, 'Policy violation')

// Internal server error
socket.close(1011, 'Internal server error')

// Normal closure after completing a task
socket.close(1000, 'Done')

// Going away — server shutting down
socket.close(1001, 'Server restarting')
```

| Code | Name | When to use |
| --- | --- | --- |
| `1000` | Normal closure | Intentional, clean close |
| `1001` | Going away | Server shutting down |
| `1002` | Protocol error | Invalid WebSocket framing |
| `1003` | Unsupported data | Wrong message type (text vs binary) |
| `1007` | Invalid frame payload | Malformed UTF-8 in text frame |
| `1008` | Policy violation | Auth failure, rule breach |
| `1009` | Message too big | Payload exceeds server limit |
| `1011` | Internal server error | Unexpected server-side failure |

**Key Points**

- The reason string in `socket.close(code, reason)` has a maximum length of 123 bytes [Unverified — verify against the WebSocket RFC and your `ws` version]
- Codes `1000`–`1015` are reserved by the WebSocket protocol; application-defined codes use `4000`–`4999`
- `socket.terminate()` sends no close frame — use it only for unresponsive connections

#### Application-defined close codes

js

```js
const WS_CLOSE_CODES = {
  AUTH_FAILED: 4001,
  TOKEN_EXPIRED: 4002,
  RATE_LIMITED: 4003,
  DUPLICATE_CONNECTION: 4004,
  IDLE_TIMEOUT: 4005
}

socket.close(WS_CLOSE_CODES.TOKEN_EXPIRED, 'Token has expired')
```

---

### Errors in Async WebSocket Handlers

If the WebSocket handler itself is `async` and throws or rejects, `@fastify/websocket` may close the socket [Inference — verify behavior with your installed version]:

js

```js
app.get('/ws', { websocket: true }, async (socket, request) => {
  // This runs before event listeners are registered
  const user = await loadUser(request.user.sub)

  if (!user) {
    socket.close(4001, 'User not found')
    return // Return here — do not register listeners on a closing socket
  }

  socket.on('message', async (data) => {
    try {
      await processMessage(socket, user, data)
    } catch (err) {
      app.log.error({ err }, 'processMessage failed')
      sendError(socket, 'INTERNAL', 'Processing failed')
    }
  })

  socket.on('error', (err) => {
    app.log.error({ err }, 'Socket error')
  })

  socket.on('close', () => {
    app.log.info({ userId: user.id }, 'Connection closed')
  })
})
```

**Key Points**

- Any `await` before listener registration creates a window where incoming messages are unhandled
- Explicitly return after calling `socket.close()` to prevent registering listeners on a closing socket
- Wrap async setup logic in `try/catch` and close the socket on failure

---

### Centralized Error Handling via a Wrapper

Encapsulate error handling logic in a wrapper function to apply it consistently across all WebSocket handlers:

js

```js
// src/lib/ws-handler.js
export function wsHandler(app, fn) {
  return async (socket, request) => {
    socket.on('error', (err) => {
      app.log.error({ err, reqId: request.id }, 'Socket error')
    })

    try {
      await fn(socket, request)
    } catch (err) {
      app.log.error({ err, reqId: request.id }, 'WebSocket handler error')

      if (socket.readyState === socket.OPEN) {
        socket.close(1011, 'Internal server error')
      }
    }
  }
}
```

js

```js
import { wsHandler } from '../lib/ws-handler.js'

app.get('/ws/chat', { websocket: true }, wsHandler(app, async (socket, request) => {
  const user = await loadUser(request.user.sub)

  socket.on('message', async (data) => {
    try {
      await handleChatMessage(socket, user, data)
    } catch (err) {
      app.log.error({ err }, 'Chat message error')
      sendError(socket, 'INTERNAL', 'Failed to process message')
    }
  })
}))
```

---

### Handling Errors During Broadcast

Broadcasting iterates multiple sockets — individual send failures must not abort the entire broadcast:

js

```js
function safeBroadcast(clients, message) {
  const data = JSON.stringify(message)
  const errors = []

  for (const client of clients) {
    if (client.readyState !== client.OPEN) continue

    client.send(data, (err) => {
      if (err) {
        errors.push({ client, err })
        app.log.warn({ err }, 'Broadcast send failed')
      }
    })
  }

  return errors
}
```

**Key Points**

- Each `send` callback fires independently — a failure on one client does not affect others
- Collect errors for logging but do not throw — a partial broadcast is usually preferable to an aborted one [Inference]
- A failed send does not close the socket automatically — check `readyState` on the next iteration

---

### Error Propagation from Plugins and Decorators

If a plugin decorator used inside a WebSocket handler throws, the error is not caught by Fastify's `setErrorHandler`:

js

```js
app.get('/ws', { websocket: true }, async (socket, request) => {
  socket.on('message', async (data) => {
    try {
      // app.db is a decorator — if it throws, catch it here
      const result = await app.db.query('SELECT * FROM users')
      socket.send(JSON.stringify(result.rows))
    } catch (err) {
      app.log.error({ err }, 'DB error in WebSocket handler')
      sendError(socket, 'DB_ERROR', 'Database unavailable')
    }
  })
})
```

**Key Points**

- Fastify's `setErrorHandler` applies to HTTP routes only — it does not intercept WebSocket message handler errors
- Treat every external call inside a `message` handler as a potential failure point
- For transient errors (DB timeout, network failure), consider sending an error message and keeping the connection open rather than closing it

---

### Logging WebSocket Errors

js

```js
app.get('/ws', { websocket: true }, (socket, request) => {
  const log = request.log.child({
    wsRoute: '/ws',
    userId: request.user?.sub,
    remoteAddress: request.socket.remoteAddress
  })

  socket.on('error', (err) => {
    log.error({ err }, 'Socket transport error')
  })

  socket.on('close', (code, reason) => {
    log.info({ code, reason: reason.toString() }, 'Connection closed')
  })

  socket.on('message', (data) => {
    try {
      const msg = JSON.parse(data.toString())
      log.debug({ type: msg.type }, 'Message received')
      handleMessage(socket, msg)
    } catch (err) {
      log.error({ err }, 'Message error')
      sendError(socket, 'INTERNAL', 'Message handling failed')
    }
  })
})
```

**Key Points**

- `request.log` is Fastify's per-request logger — it carries the request ID automatically
- `.child()` adds persistent fields to all subsequent log calls from this handler
- Log at `error` for unexpected failures, `warn` for client-caused issues (bad input, policy violations), and `info` for lifecycle events (connect, disconnect)

---

### Error Handling Flow

Parse failsParse succeedsInvalidValidHandler throwsYesNoHandler succeedsYesNoIncoming messageParse JSONsendError PARSE_ERRORkeep connection openValidate message shapesendErrorVALIDATION_ERRORkeep connection openDispatch to handlercatch errlog.errorRecoverable?sendError INTERNALkeep connection opensocket.close 1011socket.send responsesocket error eventlog.errorreadyState OPEN?socket.close 1011Wait for close eventclose event — cleanup

---

### Common Pitfalls

**Not attaching `socket.on('error')`**
An unhandled `error` event crashes the Node.js process. Every WebSocket handler must attach an error listener.

**Assuming `error` is followed by `close`**
In most cases it is, but do not perform cleanup in `error` — perform it in `close`, which always fires at end of connection.

**Throwing inside `socket.on('message', async ...)`**
Async listener rejections are not caught by any framework boundary. Always `try/catch` inside async message handlers.

**Calling `socket.close()` and then continuing to send**
After `socket.close()`, the socket enters `CLOSING` state. Subsequent `send()` calls throw. Return immediately after closing.

**Using Fastify's `setErrorHandler` to catch WebSocket errors**
`setErrorHandler` applies to HTTP routes only. It is not invoked for errors occurring inside WebSocket event handlers.

**Including stack traces in client error messages**
Error details sent to clients can leak internal implementation information. Send only a code and a human-readable message; log the full error server-side.

---

**Related Topics**

- Structured logging for WebSocket connections with Pino
- Reconnection and error recovery strategies on the client side
- Rate limiting to prevent error amplification from malicious clients
- Testing error paths in WebSocket handlers with mock sockets
- Dead letter handling for failed message processing
- Circuit breaker patterns for external calls inside WebSocket handlers
- Monitoring WebSocket error rates with Prometheus and `@fastify/metrics`