## Fastify Hooks — onReady and onClose

### Overview

The `onReady` and `onClose` hooks are lifecycle hooks in Fastify that execute at critical moments in the server's lifespan — just before the server begins accepting requests, and just before the server shuts down. They are essential for managing startup and teardown logic cleanly.

---

### onReady Hook

The `onReady` hook fires after `fastify.ready()` resolves but before the server starts listening for incoming connections. It is useful for performing final initialization tasks that depend on all plugins and routes already being registered.

**Key Points:**
- Registered via `fastify.addHook('onReady', fn)`
- Receives no `request` or `reply` objects — it operates at the server level
- Supports async functions and callback-style functions
- If it throws or calls `done(err)`, the server startup is aborted
- Executed in the order hooks are registered

**Syntax:**

```js
fastify.addHook('onReady', async function () {
  // initialization logic
});
```

Or with a callback:

```js
fastify.addHook('onReady', function (done) {
  // initialization logic
  done();
});
```

**Example — Verifying a Database Connection Before Accepting Traffic:**

```js
import Fastify from 'fastify';
import { connectDB } from './db.js';

const fastify = Fastify({ logger: true });

fastify.addHook('onReady', async function () {
  const isConnected = await connectDB();
  if (!isConnected) {
    throw new Error('Database connection failed. Aborting startup.');
  }
  fastify.log.info('Database verified. Ready to accept requests.');
});

await fastify.listen({ port: 3000 });
```

**Output:**
```
{"level":"info","msg":"Database verified. Ready to accept requests."}
{"level":"info","msg":"Server listening at http://127.0.0.1:3000"}
```

> **Disclaimer:** Actual log output format and ordering may vary depending on Fastify version and logger configuration.

---

### onClose Hook

The `onClose` hook fires when `fastify.close()` is called, intended to gracefully shut down the server. It is the appropriate place to release resources such as database connections, message queue consumers, file handles, or caches.

**Key Points:**
- Registered via `fastify.addHook('onClose', fn)`
- Receives the `fastify` instance as its first argument
- Supports async functions and callback-style functions
- Hooks are executed in **reverse registration order** (LIFO — last in, first out)
- If a hook throws or calls `done(err)`, the error is propagated but shutdown continues [Unverified: whether all subsequent hooks still execute after an error]

**Syntax:**

```js
fastify.addHook('onClose', async function (instance) {
  // teardown logic
});
```

Or with a callback:

```js
fastify.addHook('onClose', function (instance, done) {
  // teardown logic
  done();
});
```

**Example — Closing a Database Pool on Shutdown:**

```js
import Fastify from 'fastify';
import { dbPool } from './db.js';

const fastify = Fastify({ logger: true });

fastify.addHook('onClose', async function (instance) {
  instance.log.info('Closing database pool...');
  await dbPool.end();
  instance.log.info('Database pool closed.');
});

// Graceful shutdown on SIGINT
process.on('SIGINT', async () => {
  await fastify.close();
  process.exit(0);
});

await fastify.listen({ port: 3000 });
```

**Output:**
```
{"level":"info","msg":"Closing database pool..."}
{"level":"info","msg":"Database pool closed."}
```

---

### Execution Order — LIFO for onClose

Unlike most Fastify hooks that execute in registration order (FIFO), `onClose` hooks execute in **reverse** order. This mirrors the natural teardown sequence — the last resource opened is typically the first to close.

**Example:**

```js
fastify.addHook('onClose', async () => { console.log('onClose: Hook 1'); });
fastify.addHook('onClose', async () => { console.log('onClose: Hook 2'); });
fastify.addHook('onClose', async () => { console.log('onClose: Hook 3'); });

await fastify.close();
```

**Output:**
```
onClose: Hook 3
onClose: Hook 2
onClose: Hook 1
```

---

### Encapsulation Behavior

Both hooks respect Fastify's plugin encapsulation model.

- A hook registered inside a plugin with `fastify-plugin` (which breaks encapsulation) is visible at the root level
- A hook registered inside a scoped plugin (without `fastify-plugin`) is **only triggered within that scope**

**Example:**

```js
import fp from 'fastify-plugin';

// This onClose hook IS visible at root scope
fastify.register(fp(async function (instance) {
  instance.addHook('onClose', async () => {
    console.log('Teardown from fp plugin');
  });
}));

// This onClose hook is scoped and only applies within this plugin
fastify.register(async function (instance) {
  instance.addHook('onClose', async () => {
    console.log('Teardown from scoped plugin');
  });
});
```

> **Disclaimer:** Encapsulation behavior with hooks can be subtle and may vary based on plugin registration order and nesting depth.

---

### onReady vs onClose — Comparison

| Feature | `onReady` | `onClose` |
|---|---|---|
| Trigger point | After `ready()`, before `listen()` | When `close()` is called |
| Arguments | None | `fastify` instance |
| Execution order | FIFO | LIFO |
| Abort on error | Yes — prevents `listen()` | No — shutdown continues |
| Typical use | Pre-flight checks, cache warm-up | DB teardown, connection cleanup |

---

### Common Patterns

#### Cache Warm-Up in onReady

```js
fastify.addHook('onReady', async function () {
  const data = await fetchCriticalConfig();
  fastify.decorate('config', data);
  fastify.log.info('Config cache loaded.');
});
```

#### Signal-Based Graceful Shutdown with onClose

```js
const signals = ['SIGINT', 'SIGTERM'];

for (const signal of signals) {
  process.on(signal, async () => {
    fastify.log.info(`Received ${signal}. Shutting down...`);
    await fastify.close();
    process.exit(0);
  });
}
```

#### Using onClose in a Plugin

```js
async function myPlugin(fastify, options) {
  const client = await createClient(options);

  fastify.addHook('onClose', async (instance) => {
    await client.disconnect();
  });
}

export default fp(myPlugin);
```

This pattern is idiomatic in Fastify — the plugin that opens a resource is responsible for registering its own `onClose` to clean it up.

---

### Error Handling Considerations

**In onReady:**
Throwing an error or passing an error to `done()` will cause `fastify.listen()` to reject, preventing the server from accepting requests. This makes `onReady` a reliable gate for pre-flight validation.

```js
fastify.addHook('onReady', async function () {
  if (!process.env.SECRET_KEY) {
    throw new Error('SECRET_KEY is not set. Cannot start.');
  }
});
```

**In onClose:**
Errors thrown in `onClose` hooks propagate to the caller of `fastify.close()`. Wrapping `fastify.close()` in a try/catch is advisable in production shutdown routines.

```js
try {
  await fastify.close();
} catch (err) {
  console.error('Error during shutdown:', err);
  process.exit(1);
}
```

---

**Conclusion:**
`onReady` and `onClose` provide structured control over the boundaries of a Fastify server's active life. `onReady` acts as a pre-flight checkpoint, blocking traffic until the application is fully prepared. `onClose` enables deterministic resource cleanup, executing teardown logic in a predictable reverse order. Together, they form the foundation of robust lifecycle management in production Fastify applications.