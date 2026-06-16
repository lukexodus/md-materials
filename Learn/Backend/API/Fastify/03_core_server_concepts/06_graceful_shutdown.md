## Graceful Shutdown

### Overview

Graceful shutdown is the process of stopping a server in a controlled manner — ceasing to accept new connections, completing or draining in-flight requests, running cleanup logic, and then exiting the process. Without it, abrupt termination can cause dropped requests, corrupted data, or unreleased resources. Fastify provides `fastify.close()` and the `onClose` hook as the foundation for graceful shutdown, but a complete implementation also requires OS signal handling and awareness of the Node.js process lifecycle.

---

### What Graceful Shutdown Involves

A complete graceful shutdown sequence typically covers:

1. Receiving a termination signal (`SIGTERM`, `SIGINT`, etc.)
2. Stopping acceptance of new connections
3. Waiting for in-flight requests to complete (connection draining)
4. Running registered cleanup hooks (`onClose`)
5. Releasing external resources (database connections, message queue consumers, file handles)
6. Exiting the process with an appropriate code

**Key Points:**
- Fastify handles steps 2 and 4 via `fastify.close()`
- Steps 3, 5, and 6 require explicit application-level implementation
- Skipping any step can result in data loss, hanging processes, or zombie connections [Inference]

---

### `fastify.close()` Recap

```js
await fastify.close()
```

- Stops the underlying HTTP server from accepting new connections
- Executes all registered `onClose` hooks in registration order
- Returns a Promise that resolves when all hooks have completed

**Key Points:**
- `fastify.close()` does not forcibly terminate in-flight requests — it stops new ones from being accepted
- Whether keep-alive connections are closed immediately depends on Node.js HTTP server behavior and connection settings [Inference]
- Calling `fastify.close()` more than once may produce unexpected behavior — guard against repeated calls [Inference]

---

### Handling OS Signals

Process managers, container orchestrators, and terminal input send signals to indicate the process should stop:

| Signal | Sender | Typical Meaning |
|---|---|---|
| `SIGTERM` | Kubernetes, systemd, Docker, PM2 | Polite request to shut down |
| `SIGINT` | `Ctrl+C` in terminal | Interactive interruption |
| `SIGUSR2` | Nodemon | Restart signal |
| `SIGKILL` | OS (unkillable) | Forced kill — cannot be caught |

**Basic signal handler:**

```js
const closeGracefully = async (signal) => {
  fastify.log.info(`Received signal: ${signal}`)
  await fastify.close()
  process.exit(0)
}

process.on('SIGTERM', closeGracefully)
process.on('SIGINT', closeGracefully)
```

**Key Points:**
- `SIGKILL` cannot be caught or handled — graceful shutdown must complete before the OS sends it
- Kubernetes sends `SIGTERM` and waits for `terminationGracePeriodSeconds` (default 30s) before sending `SIGKILL` — your shutdown must complete within that window
- `process.exit(0)` signals success to the process manager; use `process.exit(1)` if shutdown fails

---

### Preventing Duplicate Shutdown Calls

Signal handlers can fire multiple times (e.g., user pressing `Ctrl+C` twice). Guard against calling `fastify.close()` more than once:

```js
let isShuttingDown = false

const closeGracefully = async (signal) => {
  if (isShuttingDown) return
  isShuttingDown = true

  fastify.log.info(`Received ${signal} — shutting down`)

  try {
    await fastify.close()
    process.exit(0)
  } catch (err) {
    fastify.log.error({ err }, 'Error during shutdown')
    process.exit(1)
  }
}

process.on('SIGTERM', closeGracefully)
process.on('SIGINT', closeGracefully)
```

---

### The `onClose` Hook

The `onClose` hook is the primary mechanism for registering cleanup logic in Fastify:

```js
fastify.addHook('onClose', async (instance) => {
  await instance.db.disconnect()
  fastify.log.info('Database connection closed')
})
```

**Key Points:**
- Multiple `onClose` hooks can be registered — they run in registration order
- Async hooks are fully supported; Fastify awaits each before proceeding
- The hook receives the Fastify instance, giving access to decorators and plugins
- `onClose` hooks registered inside plugins are scoped to that plugin's instance but still execute on `fastify.close()` [Inference — verify with encapsulation behavior in your version]

**Example with multiple hooks:**

```js
fastify.addHook('onClose', async (instance) => {
  await instance.db.disconnect()
})

fastify.addHook('onClose', async (instance) => {
  await instance.redis.quit()
})

fastify.addHook('onClose', async (instance) => {
  await instance.messageQueue.close()
})
```

---

### Registering Cleanup Inside Plugins

When resources are created inside plugins, register their cleanup in the same plugin:

```js
const dbPlugin = async (fastify, options) => {
  const db = await connectToDatabase(options.connectionString)
  fastify.decorate('db', db)

  fastify.addHook('onClose', async (instance) => {
    await instance.db.disconnect()
  })
}

fastify.register(dbPlugin, { connectionString: process.env.DB_URL })
```

**Key Points:**
- Co-locating resource creation and cleanup inside the same plugin improves maintainability
- This pattern is the standard convention used by official Fastify plugins (e.g., `@fastify/mongodb`, `@fastify/redis`)

---

### Connection Draining

Fastify's `close()` stops accepting new connections but does not wait for existing ones to finish. For HTTP keep-alive connections, clients may hold connections open indefinitely.

Strategies for draining connections:

**Option 1 — Set a keep-alive timeout:**

```js
const fastify = require('fastify')()

fastify.server.keepAliveTimeout = 5000 // 5 seconds
```

**Option 2 — Use a shutdown manager library:**

Libraries such as `close-with-grace` are designed to handle connection draining gracefully:

```js
const closeWithGrace = require('close-with-grace')

closeWithGrace({ delay: 500 }, async ({ signal, err, manual }) => {
  if (err) fastify.log.error({ err }, 'Unhandled error — shutting down')
  await fastify.close()
})
```

**Key Points:**
- `close-with-grace` is authored by Matteo Collina (a Fastify core maintainer) and is commonly recommended in the Fastify ecosystem [Unverified — verify current maintainership]
- The `delay` option gives in-flight requests time to complete before forced closure
- Without connection draining, clients on persistent connections may receive abrupt disconnections

---

### Shutdown Timeout

To prevent shutdown from hanging indefinitely (e.g., a stuck `onClose` hook), enforce a maximum shutdown duration:

```js
const closeGracefully = async (signal) => {
  fastify.log.info(`Received ${signal}`)

  const shutdownTimeout = setTimeout(() => {
    fastify.log.error('Shutdown timed out — forcing exit')
    process.exit(1)
  }, 10_000) // 10 second hard limit

  shutdownTimeout.unref() // don't keep process alive just for this timer

  try {
    await fastify.close()
    clearTimeout(shutdownTimeout)
    process.exit(0)
  } catch (err) {
    fastify.log.error({ err }, 'Shutdown error')
    clearTimeout(shutdownTimeout)
    process.exit(1)
  }
}
```

**Key Points:**
- `unref()` on the timeout prevents it from keeping the Node.js event loop alive if everything else has exited
- The timeout value should be less than the orchestrator's `terminationGracePeriodSeconds` to avoid a `SIGKILL`

---

### Handling Uncaught Errors During Shutdown

Unhandled rejections or exceptions during shutdown should be caught and logged:

```js
process.on('unhandledRejection', (reason) => {
  fastify.log.error({ reason }, 'Unhandled rejection')
  process.exit(1)
})

process.on('uncaughtException', (err) => {
  fastify.log.error({ err }, 'Uncaught exception')
  process.exit(1)
})
```

**Key Points:**
- These handlers act as a safety net — they should not be the primary error handling strategy
- Exiting on uncaught exceptions is generally recommended for server processes, as the application state may be inconsistent [Inference]

---

### Kubernetes-Specific Considerations

In Kubernetes, graceful shutdown interacts with pod lifecycle management:

```
Pod deletion
    │
    ├─► preStop hook executes (if configured)
    │       └─► sleep or drain logic here
    │
    ├─► SIGTERM sent to container
    │       └─► fastify.close() triggered
    │
    └─► terminationGracePeriodSeconds countdown begins
            └─► SIGKILL sent if process has not exited
```

**Key Points:**
- There is a race condition between `SIGTERM` delivery and Kubernetes removing the pod from service endpoints — a `preStop` sleep of a few seconds mitigates this [Inference — a known Kubernetes operational pattern]
- The `preStop` hook in Kubernetes is defined in the pod spec, not in application code
- Keep total shutdown time (preStop delay + application shutdown) under `terminationGracePeriodSeconds`

**Example `preStop` in a Kubernetes pod spec:**

```yaml
lifecycle:
  preStop:
    exec:
      command: ["sleep", "5"]
```

---

### Complete Shutdown Implementation

A production-ready shutdown pattern combining the above:

```js
const fastify = require('fastify')({ logger: true })
const closeWithGrace = require('close-with-grace')

// Register routes and plugins
fastify.register(require('./plugins/db'))
fastify.register(require('./routes'))

// Graceful shutdown via close-with-grace
closeWithGrace(
  { delay: process.env.FASTIFY_CLOSE_GRACE_DELAY ?? 500 },
  async ({ signal, err, manual }) => {
    if (err) {
      fastify.log.error({ err }, 'Closing due to unhandled error')
    } else {
      fastify.log.info(`Received ${signal} — starting graceful shutdown`)
    }
    await fastify.close()
  }
)

// Start server
try {
  await fastify.listen({
    port: parseInt(process.env.PORT ?? '3000', 10),
    host: process.env.HOST ?? '0.0.0.0'
  })
} catch (err) {
  fastify.log.error(err)
  process.exit(1)
}
```

---

### Shutdown Sequence Diagram

<svg viewBox="0 0 660 500" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="660" height="500" fill="#1e1e2e" rx="12"/>
  <text x="330" y="32" text-anchor="middle" fill="#cdd6f4" font-size="14" font-weight="bold">Graceful Shutdown Sequence</text>

  <!-- Step boxes -->
  <!-- 1 -->
  <rect x="210" y="55" width="240" height="38" rx="6" fill="#313244" stroke="#f38ba8" stroke-width="1.5"/>
  <text x="330" y="70" text-anchor="middle" fill="#f38ba8">① OS Signal Received</text>
  <text x="330" y="85" text-anchor="middle" fill="#6c7086">(SIGTERM / SIGINT)</text>

  <line x1="330" y1="93" x2="330" y2="115" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- 2 -->
  <rect x="210" y="115" width="240" height="38" rx="6" fill="#313244" stroke="#fab387" stroke-width="1.5"/>
  <text x="330" y="130" text-anchor="middle" fill="#fab387">② Shutdown Guard Check</text>
  <text x="330" y="145" text-anchor="middle" fill="#6c7086">(prevent duplicate calls)</text>

  <line x1="330" y1="153" x2="330" y2="175" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- 3 -->
  <rect x="210" y="175" width="240" height="38" rx="6" fill="#313244" stroke="#fab387" stroke-width="1.5"/>
  <text x="330" y="190" text-anchor="middle" fill="#fab387">③ Shutdown Timeout Started</text>
  <text x="330" y="205" text-anchor="middle" fill="#6c7086">(hard limit enforced)</text>

  <line x1="330" y1="213" x2="330" y2="235" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- 4 -->
  <rect x="210" y="235" width="240" height="38" rx="6" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="330" y="250" text-anchor="middle" fill="#89b4fa">④ fastify.close() called</text>
  <text x="330" y="265" text-anchor="middle" fill="#6c7086">(stop accepting connections)</text>

  <line x1="330" y1="273" x2="330" y2="295" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- 5 -->
  <rect x="210" y="295" width="240" height="38" rx="6" fill="#313244" stroke="#cba6f7" stroke-width="1.5"/>
  <text x="330" y="310" text-anchor="middle" fill="#cba6f7">⑤ onClose hooks run</text>
  <text x="330" y="325" text-anchor="middle" fill="#6c7086">(db, cache, queue teardown)</text>

  <line x1="330" y1="333" x2="330" y2="355" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- 6 -->
  <rect x="210" y="355" width="240" height="38" rx="6" fill="#313244" stroke="#a6e3a1" stroke-width="1.5"/>
  <text x="330" y="370" text-anchor="middle" fill="#a6e3a1">⑥ Timeout cleared</text>
  <text x="330" y="385" text-anchor="middle" fill="#6c7086">(shutdown completed in time)</text>

  <line x1="330" y1="393" x2="330" y2="415" stroke="#6c7086" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- 7 -->
  <rect x="240" y="415" width="180" height="38" rx="19" fill="#a6e3a1" stroke="#40a02b" stroke-width="1.5"/>
  <text x="330" y="438" text-anchor="middle" fill="#1e1e2e" font-weight="bold">process.exit(0)</text>

  <!-- Timeout branch -->
  <rect x="490" y="235" width="140" height="38" rx="6" fill="#313244" stroke="#f38ba8" stroke-width="1.5"/>
  <text x="560" y="250" text-anchor="middle" fill="#f38ba8">Timeout fires</text>
  <text x="560" y="265" text-anchor="middle" fill="#6c7086">(forced exit)</text>
  <line x1="450" y1="252" x2="488" y2="252" stroke="#f38ba8" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arre)"/>

  <rect x="505" y="295" width="110" height="30" rx="15" fill="#f38ba8" stroke="#e64553" stroke-width="1.5"/>
  <text x="560" y="315" text-anchor="middle" fill="#1e1e2e" font-weight="bold">process.exit(1)</text>
  <line x1="560" y1="273" x2="560" y2="293" stroke="#f38ba8" stroke-width="1.5" marker-end="url(#arre)"/>

  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#6c7086"/>
    </marker>
    <marker id="arre" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#f38ba8"/>
    </marker>
  </defs>
</svg>

---

### Checklist

| Concern | Covered By |
|---|---|
| Stop accepting new connections | `fastify.close()` |
| Release DB connections | `onClose` hook |
| Release cache/queue connections | `onClose` hook |
| Handle `SIGTERM` / `SIGINT` | `process.on(signal, handler)` |
| Prevent duplicate shutdowns | Guard flag (`isShuttingDown`) |
| Enforce maximum shutdown time | `setTimeout` with `unref()` |
| Connection draining | `keepAliveTimeout` or `close-with-grace` |
| Kubernetes pod lifecycle | `preStop` hook in pod spec |

---

**Conclusion:** Graceful shutdown in Fastify requires combining `fastify.close()`, `onClose` hooks, OS signal handlers, a duplicate-call guard, and a shutdown timeout. For production environments — especially containerized deployments — connection draining via `close-with-grace` and awareness of orchestrator signal timing are also necessary. Each layer addresses a distinct failure mode; omitting any one can lead to dropped requests, resource leaks, or hung processes.