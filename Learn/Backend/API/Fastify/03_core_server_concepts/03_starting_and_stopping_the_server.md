## Starting and Stopping the Server

### Overview

Fastify's server lifecycle is managed through an asynchronous API. Starting and stopping the server involves binding to a port and address, initializing plugins, and gracefully shutting down connections. Understanding this lifecycle is foundational to building reliable Fastify applications.

---

### The `listen` Method

The primary way to start a Fastify server is through `fastify.listen()`. It triggers the plugin initialization chain (via `fastify.ready()`) and then binds the HTTP server to a port.

**Signature:**

```js
fastify.listen(options, callback)
// or
await fastify.listen(options)
```

**Key Points:**
- `listen` internally calls `fastify.ready()`, so you do not need to call `ready()` separately before `listen()`
- It returns a Promise, making it compatible with `async/await`
- The callback form is also supported for legacy usage

---

### Listen Options

The options object passed to `listen()` accepts the following commonly used properties:

| Option | Type | Default | Description |
|---|---|---|---|
| `port` | `number` | `0` | Port to bind to. `0` assigns a random available port |
| `host` | `string` | `'127.0.0.1'` | Hostname or IP address to bind |
| `path` | `string` | — | Unix socket path (overrides `port` and `host`) |
| `backlog` | `number` | `511` | Max length of pending connections queue |
| `listenTextResolver` | `function` | — | Custom function to resolve the listening text |

**Example:**

```js
const fastify = require('fastify')({ logger: true })

await fastify.listen({ port: 3000, host: '0.0.0.0' })
console.log('Server is listening')
```

**Output:**
```
{"level":30,"msg":"Server listening at http://0.0.0.0:3000"}
```

---

### Host Binding Considerations

**Key Points:**
- The default host is `127.0.0.1` (localhost), meaning the server is not reachable externally by default
- For containerized or cloud environments, bind to `0.0.0.0` to accept connections on all interfaces
- Binding to `0.0.0.0` in development may expose the server on your local network — use with awareness

**Example (container-friendly binding):**

```js
await fastify.listen({ port: 8080, host: '0.0.0.0' })
```

---

### Using `async/await`

The recommended pattern for modern Fastify applications:

```js
const fastify = require('fastify')({ logger: true })

fastify.get('/', async (request, reply) => {
  return { hello: 'world' }
})

const start = async () => {
  try {
    await fastify.listen({ port: 3000, host: '0.0.0.0' })
  } catch (err) {
    fastify.log.error(err)
    process.exit(1)
  }
}

start()
```

**Key Points:**
- Wrapping in a `try/catch` is important — errors during plugin initialization or port binding surface here
- Calling `process.exit(1)` on failure is a common pattern to signal an unhealthy startup to process managers

---

### Using Callbacks

The callback form receives `(err, address)`:

```js
fastify.listen({ port: 3000 }, (err, address) => {
  if (err) {
    fastify.log.error(err)
    process.exit(1)
  }
  console.log(`Server listening at ${address}`)
})
```

---

### Getting the Bound Address

After the server has started, you can retrieve the address it is listening on:

```js
await fastify.listen({ port: 0 }) // port 0 = random port
const address = fastify.server.address()
console.log(address)
// { address: '127.0.0.1', family: 'IPv4', port: 54321 }
```

This is particularly useful in testing, where `port: 0` avoids port conflicts.

---

### Stopping the Server — `fastify.close()`

`fastify.close()` initiates a graceful shutdown. It:

1. Stops the server from accepting new connections
2. Runs all registered `onClose` hooks
3. Resolves the returned Promise (or invokes the callback) when shutdown is complete

**Signature:**

```js
await fastify.close()
// or
fastify.close(callback)
```

**Example:**

```js
const start = async () => {
  await fastify.listen({ port: 3000 })

  // Simulate shutdown after 10 seconds
  setTimeout(async () => {
    await fastify.close()
    console.log('Server closed')
  }, 10000)
}

start()
```

**Key Points:**
- `fastify.close()` does not forcibly terminate in-flight requests — it stops accepting new ones and waits for hooks to complete. Whether existing connections are drained depends on the Node.js HTTP server behavior and any keep-alive settings. [Inference]
- Plugin teardown logic (e.g., closing database connections) should be registered using `fastify.addHook('onClose', ...)` to run automatically during shutdown

---

### Graceful Shutdown with OS Signals

In production, it is standard practice to listen for `SIGINT` and `SIGTERM` signals and call `fastify.close()` in response:

```js
const closeGracefully = async (signal) => {
  console.log(`Received signal: ${signal}`)
  await fastify.close()
  process.exit(0)
}

process.on('SIGINT', closeGracefully)
process.on('SIGTERM', closeGracefully)
```

**Key Points:**
- `SIGTERM` is typically sent by orchestrators like Kubernetes when terminating a pod
- `SIGINT` is sent when pressing `Ctrl+C` in a terminal
- Not handling these signals may result in abrupt process termination without running `onClose` hooks

---

### The `onClose` Hook

Register cleanup logic to run during `fastify.close()`:

```js
fastify.addHook('onClose', async (instance) => {
  await instance.db.disconnect() // example: close a DB connection
  console.log('Database disconnected')
})
```

**Key Points:**
- Multiple `onClose` hooks can be registered and will execute in registration order
- The hook receives the Fastify instance as its argument
- Async hooks are supported; Fastify will await them before completing shutdown

---

### `fastify.ready()`

`ready()` initializes all plugins and decorators without starting the HTTP listener. It is useful for testing or inspecting the fully-initialized instance before binding to a port.

```js
await fastify.ready()
// All plugins loaded, but no port is open yet

await fastify.listen({ port: 3000 })
// Now the port is open
```

**Key Points:**
- `listen()` calls `ready()` internally, so calling both is redundant in normal application startup
- `ready()` is most commonly used in test setups with injection (`fastify.inject()`)

---

### Server Lifecycle State

Fastify exposes methods to check the server's current state:

| Method | Returns | Description |
|---|---|---|
| `fastify.server` | `http.Server` | The underlying Node.js HTTP server |
| `fastify.addresses()` | `Array` | All addresses the server is bound to (Fastify v4.11+) [Unverified — verify against your version] |

---

### Common Startup Errors

| Error | Likely Cause |
|---|---|
| `EADDRINUSE` | Port is already in use by another process |
| `EACCES` | Insufficient permissions to bind (e.g., port < 1024 without elevated privileges) |
| Plugin initialization error | A plugin threw during `ready()` — check plugin registration and dependencies |

---

### Lifecycle Diagram

The following diagram illustrates the flow from `listen()` call to server ready, and from `close()` call to shutdown:

<svg viewBox="0 0 640 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Background -->
  <rect width="640" height="520" fill="#1e1e2e" rx="12"/>

  <!-- Title -->
  <text x="320" y="36" text-anchor="middle" fill="#cdd6f4" font-size="15" font-weight="bold">Fastify Server Lifecycle</text>

  <!-- START -->
  <rect x="260" y="60" width="120" height="36" rx="18" fill="#a6e3a1" stroke="#40a02b" stroke-width="1.5"/>
  <text x="320" y="83" text-anchor="middle" fill="#1e1e2e" font-weight="bold">fastify.listen()</text>

  <!-- Arrow -->
  <line x1="320" y1="96" x2="320" y2="118" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- ready() -->
  <rect x="240" y="118" width="160" height="36" rx="6" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="320" y="141" text-anchor="middle" fill="#89b4fa">fastify.ready()</text>

  <!-- Arrow -->
  <line x1="320" y1="154" x2="320" y2="176" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Plugins -->
  <rect x="220" y="176" width="200" height="36" rx="6" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="320" y="199" text-anchor="middle" fill="#89b4fa">Initialize plugins &amp; decorators</text>

  <!-- Arrow -->
  <line x1="320" y1="212" x2="320" y2="234" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Bind port -->
  <rect x="230" y="234" width="180" height="36" rx="6" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="320" y="257" text-anchor="middle" fill="#89b4fa">Bind to port / host</text>

  <!-- Arrow -->
  <line x1="320" y1="270" x2="320" y2="292" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Listening -->
  <rect x="245" y="292" width="150" height="36" rx="18" fill="#89dceb" stroke="#04a5e5" stroke-width="1.5"/>
  <text x="320" y="315" text-anchor="middle" fill="#1e1e2e" font-weight="bold">Server Listening</text>

  <!-- Divider -->
  <line x1="80" y1="350" x2="560" y2="350" stroke="#45475a" stroke-width="1" stroke-dasharray="6,4"/>
  <text x="320" y="346" text-anchor="middle" fill="#6c7086" font-size="11">── shutdown ──</text>

  <!-- close() -->
  <line x1="320" y1="328" x2="320" y2="370" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>
  <rect x="240" y="370" width="160" height="36" rx="6" fill="#313244" stroke="#f38ba8" stroke-width="1.5"/>
  <text x="320" y="393" text-anchor="middle" fill="#f38ba8">fastify.close()</text>

  <!-- Arrow -->
  <line x1="320" y1="406" x2="320" y2="428" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- onClose hooks -->
  <rect x="210" y="428" width="220" height="36" rx="6" fill="#313244" stroke="#f38ba8" stroke-width="1.5"/>
  <text x="320" y="451" text-anchor="middle" fill="#f38ba8">Run onClose hooks</text>

  <!-- Arrow -->
  <line x1="320" y1="464" x2="320" y2="484" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Closed -->
  <rect x="255" y="484" width="130" height="30" rx="15" fill="#f38ba8" stroke="#e64553" stroke-width="1.5"/>
  <text x="320" y="504" text-anchor="middle" fill="#1e1e2e" font-weight="bold">Server Closed</text>

  <!-- Arrow marker -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#6c7086"/>
    </marker>
  </defs>
</svg>

---

### Summary

| Action | Method | Notes |
|---|---|---|
| Start server | `fastify.listen(options)` | Calls `ready()` internally |
| Initialize only | `fastify.ready()` | No port binding |
| Stop server | `fastify.close()` | Runs `onClose` hooks |
| Register teardown | `fastify.addHook('onClose', fn)` | For cleanup tasks |
| Get bound address | `fastify.server.address()` | Available after `listen()` |

**Conclusion:** Starting and stopping a Fastify server correctly — including graceful shutdown and proper signal handling — is essential for production reliability. The combination of `listen()`, `close()`, and `onClose` hooks gives you precise control over the full server lifecycle.