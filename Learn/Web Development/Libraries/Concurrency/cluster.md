# Comprehensive Guide to Node.js `cluster` Module

---

## Table of Contents

1. [Overview](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#overview)
2. [Why Clustering Exists](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#why-clustering-exists)
3. [How It Works](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#how-it-works)
4. [Basic Usage](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#basic-usage)
5. [API Reference](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#api-reference)
    - [cluster object](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#cluster-object)
    - [Worker class](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#worker-class)
6. [Inter-Process Communication (IPC)](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#inter-process-communication-ipc)
7. [Load Balancing Strategies](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#load-balancing-strategies)
8. [Lifecycle and Events](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#lifecycle-and-events)
9. [Graceful Shutdown](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#graceful-shutdown)
10. [Fault Tolerance and Auto-Restart](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#fault-tolerance-and-auto-restart)
11. [Sharing State Between Workers](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#sharing-state-between-workers)
12. [Common Patterns](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#common-patterns)
13. [Limitations](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#limitations)
14. [Comparison with Related Tools](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#comparison-with-related-tools)
15. [Security Considerations](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#security-considerations)
16. [Debugging](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#debugging)
17. [Known Gotchas](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#known-gotchas)

---

## Overview

`cluster` is a built-in Node.js module that allows a single Node.js application to spawn multiple child processes (workers), each running on the same port, to take advantage of multi-core systems.

**Module source:** `require('cluster')` (CommonJS) or `import cluster from 'cluster'` (ESM, Node.js v16+)

**No installation required.** It is part of the Node.js standard library.

**Supported since:** Node.js v0.6 (stable since v0.8; significantly improved in later versions)

---

## Why Clustering Exists

Node.js runs JavaScript in a single thread. The event loop is non-blocking and handles concurrency well for I/O-bound workloads, but a single process can use only one CPU core at a time. On a machine with 8 cores, a single Node.js process leaves 7 cores idle.

The `cluster` module addresses this by forking multiple worker processes from a single master (primary) process, each handling a share of incoming connections.

### What clustering helps with

- CPU-bound workloads where multiple requests compete for the event loop
- Maximizing throughput on multi-core hardware
- Process-level fault isolation (one crashing worker does not kill others)
- Zero-downtime restarts (rolling worker replacement)

### What clustering does not help with

- True parallelism within a single request (use `worker_threads` for that)
- Sharing in-memory state between workers (workers have separate memory spaces)
- Single-core machines (overhead with no throughput benefit)

---

## How It Works

When you call `cluster.fork()`, the primary process uses `child_process.fork()` internally to spawn a new Node.js process running the same script file. The forked process is called a **worker**.

Workers and the primary process communicate over an IPC (inter-process communication) channel automatically set up by Node.js.

The primary process listens on a port and distributes incoming connections to workers using one of two scheduling policies (see [Load Balancing Strategies](https://claude.ai/chat/97b12f8a-11d3-450e-b36a-68479e4d7aed#load-balancing-strategies)).

```
           ┌──────────────────────┐
           │   Primary Process    │
           │  (cluster.isMaster)  │
           └──────┬───────────────┘
                  │ fork()
       ┌──────────┼──────────┐
       ▼          ▼          ▼
  ┌─────────┐ ┌─────────┐ ┌─────────┐
  │Worker 0 │ │Worker 1 │ │Worker N │
  │ (isWorker)│ │(isWorker)│ │(isWorker)│
  └─────────┘ └─────────┘ └─────────┘
```

Each worker runs the full script, so conditional logic using `cluster.isPrimary` (or the older `cluster.isMaster`) is required to separate primary and worker behavior.

---

## Basic Usage

```js
const cluster = require('cluster');
const http = require('http');
const os = require('os');

const numCPUs = os.availableParallelism?.() ?? os.cpus().length;

if (cluster.isPrimary) {
  console.log(`Primary process ${process.pid} is running`);

  // Fork one worker per CPU core
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} exited (code: ${code}, signal: ${signal})`);
  });

} else {
  // Workers share the same port
  http.createServer((req, res) => {
    res.writeHead(200);
    res.end(`Hello from worker ${process.pid}\n`);
  }).listen(3000);

  console.log(`Worker ${process.pid} started`);
}
```

### ESM equivalent (Node.js v16.9+)

```js
import cluster from 'cluster';
import http from 'http';
import { availableParallelism } from 'os';

const numCPUs = availableParallelism();

if (cluster.isPrimary) {
  for (let i = 0; i < numCPUs; i++) cluster.fork();
} else {
  http.createServer((req, res) => {
    res.end(`Worker ${process.pid}`);
  }).listen(3000);
}
```

---

## API Reference

### cluster object

The `cluster` module exports an object that is an instance of `EventEmitter`.

#### Properties

|Property|Type|Description|
|---|---|---|
|`cluster.isPrimary`|`boolean`|`true` in the primary process. Added in Node.js v16.0.0.|
|`cluster.isMaster`|`boolean`|Deprecated alias for `isPrimary`. Still functional but avoid in new code.|
|`cluster.isWorker`|`boolean`|`true` in a worker process.|
|`cluster.workers`|`Object`|Dictionary of active worker objects, keyed by `worker.id`. Only accessible in the primary process.|
|`cluster.settings`|`Object`|Configuration object set by `cluster.setupPrimary()`.|
|`cluster.worker`|`Worker`|Reference to the current worker object. Only defined in worker processes.|
|`cluster.schedulingPolicy`|`number`|Either `cluster.SCHED_RR` or `cluster.SCHED_NONE`.|

#### Methods

##### `cluster.fork([env])`

Spawns a new worker process.

- `env` (optional): Object of key-value pairs to add to the worker's environment.
- Returns: a `Worker` instance.
- Only callable from the primary process.

```js
const worker = cluster.fork({ WORKER_ROLE: 'api' });
```

##### `cluster.setupPrimary([settings])`

Configure options before forking. Must be called before any `cluster.fork()` calls.

- `settings.exec` — path to the worker script (default: `__filename`)
- `settings.args` — array of string arguments passed to workers
- `settings.silent` — if `true`, worker stdout/stderr are piped to the primary; if `false` (default), they are inherited
- `settings.stdio` — overrides `silent`; full stdio configuration array
- `settings.uid` — sets the user identity of the worker process
- `settings.gid` — sets the group identity of the worker process
- `settings.inspectPort` — debugger port for workers (function or number)
- `settings.serialization` — IPC serialization mode: `'json'` (default) or `'advanced'` (supports more types)
- `settings.cwd` — working directory for worker processes
- `settings.windowsHide` — hides the spawned process console window on Windows (default: `false`)

```js
cluster.setupPrimary({
  exec: './worker.js',
  args: ['--use-openssl-ca'],
  silent: false
});
```

`setupMaster()` is the deprecated alias.

##### `cluster.disconnect([callback])`

Calls `.disconnect()` on all workers. The `callback` is invoked when all workers have disconnected and their handles are closed.

---

### Worker class

Each object in `cluster.workers` is an instance of `Worker`.

#### Properties

|Property|Type|Description|
|---|---|---|
|`worker.id`|`number`|Unique worker ID assigned sequentially from 1.|
|`worker.process`|`ChildProcess`|The underlying `child_process.ChildProcess` object.|
|`worker.exitedAfterDisconnect`|`boolean`|`true` if the worker exited after calling `disconnect()` or `kill()`. Useful to distinguish intentional exits from crashes.|

#### Methods

##### `worker.send(message[, sendHandle[, options]][, callback])`

Sends a message to the worker (or to the primary, if called from a worker). Uses IPC channel.

- `message`: any JSON-serializable value (or more with `serialization: 'advanced'`)
- `sendHandle`: optional — a `net.Socket` or `net.Server` handle to pass
- `callback(err)`: called when the message has been sent

```js
worker.send({ type: 'reload', config: newConfig });
```

From a worker, to send to the primary:

```js
process.send({ type: 'status', data: metrics });
```

##### `worker.disconnect()`

Closes the IPC channel. No new connections are accepted by the worker after this. The worker exits once existing connections close.

##### `worker.kill([signal])`

Sends a signal to the worker process. Default signal is `'SIGTERM'`. Does not wait for the worker to exit gracefully; use `disconnect()` for that.

##### `worker.isConnected()`

Returns `true` if the worker is still connected to the primary via IPC.

##### `worker.isDead()`

Returns `true` if the worker process has exited.

---

## Inter-Process Communication (IPC)

Workers and the primary can exchange messages over the IPC channel using `.send()` and the `'message'` event.

### Primary sending to a specific worker

```js
for (const id in cluster.workers) {
  cluster.workers[id].send({ type: 'config-update', payload: newConfig });
}
```

### Worker sending to primary

```js
// Inside worker
process.send({ type: 'metric', value: responseTime });
```

### Primary receiving from workers

```js
cluster.on('message', (worker, message) => {
  if (message.type === 'metric') {
    console.log(`Worker ${worker.id} reported: ${message.value}`);
  }
});
```

### Worker receiving from primary

```js
// Inside worker
process.on('message', (message) => {
  if (message.type === 'config-update') {
    applyConfig(message.payload);
  }
});
```

### Sending handles (sockets/servers)

The IPC channel can pass live socket handles between processes using the second argument to `.send()`.

```js
// In primary
const server = require('net').createServer();
server.listen(3000, () => {
  for (const id in cluster.workers) {
    cluster.workers[id].send('server', server);
  }
});

// In worker
process.on('message', (msg, handle) => {
  if (msg === 'server') {
    handle.on('connection', handleConnection);
  }
});
```

### Serialization modes

By default, IPC messages are serialized as JSON. This means:

- `undefined` values are stripped
- `Date` objects become strings
- Circular references throw

Use `serialization: 'advanced'` in `setupPrimary` to enable the V8 serialization format, which supports `Date`, `Map`, `Set`, `BigInt`, `RegExp`, `ArrayBuffer`, `TypedArray`, and more — but not functions.

---

## Load Balancing Strategies

The primary process distributes incoming connections to workers using one of two scheduling policies, set via `cluster.schedulingPolicy` before any `fork()` calls, or via the `NODE_CLUSTER_SCHED_POLICY` environment variable.

### Round-Robin (`cluster.SCHED_RR`)

The default on all platforms except Windows. The primary listens on the socket and passes each new connection to a worker in round-robin order.

- Predictable, even distribution under uniform request cost
- Primary process handles accept() for all connections
- Recommended for most use cases

```js
cluster.schedulingPolicy = cluster.SCHED_RR;
```

### None (`cluster.SCHED_NONE`)

The primary passes the socket to workers and lets the OS distribute connections. Default on Windows.

- Less predictable distribution
- May result in some workers being overloaded
- Lower overhead on the primary

```js
cluster.schedulingPolicy = cluster.SCHED_NONE;
```

**Note:** The scheduling policy affects which process calls `accept()` on incoming connections, not how workers handle them afterward.

---

## Lifecycle and Events

### Events on the `cluster` object (primary only)

|Event|Arguments|Fired when|
|---|---|---|
|`'fork'`|`worker`|A worker has been forked|
|`'online'`|`worker`|A worker process has started and is running|
|`'listening'`|`worker, address`|A worker calls `listen()` and the server is ready|
|`'disconnect'`|`worker`|A worker's IPC channel has been disconnected|
|`'exit'`|`worker, code, signal`|A worker process has exited|
|`'message'`|`worker, message, handle`|Primary received a message from a worker|
|`'setup'`|`settings`|`setupPrimary()` was called|

### Events on a `Worker` instance

|Event|Arguments|Fired when|
|---|---|---|
|`'message'`|`message, handle`|Message received from the primary|
|`'online'`|—|Worker process is running|
|`'listening'`|`address`|Worker's server is listening|
|`'disconnect'`|—|IPC channel disconnected|
|`'exit'`|`code, signal`|Worker process exited|
|`'error'`|`error`|Error occurred in the worker process|

### Full worker lifecycle

```
fork() → 'fork' → [process starts] → 'online'
       → [server.listen()] → 'listening'
       → [work happens]
       → disconnect() or kill()
       → 'disconnect'
       → 'exit'
```

---

## Graceful Shutdown

A graceful shutdown lets in-flight requests complete before the worker exits. This is important for production deployments.

```js
// Worker-side graceful shutdown
process.on('SIGTERM', () => {
  server.close(() => {
    // All connections drained
    process.exit(0);
  });
});
```

```js
// Primary initiating graceful shutdown of all workers
function gracefulShutdown() {
  for (const id in cluster.workers) {
    cluster.workers[id].disconnect();
  }
}

process.on('SIGINT', gracefulShutdown);
```

### Zero-downtime rolling restart

Replace workers one at a time so the server keeps serving while restarting:

```js
function rollingRestart() {
  const workers = Object.values(cluster.workers);
  let i = 0;

  function restartNext() {
    if (i >= workers.length) return;
    const worker = workers[i++];

    worker.once('exit', () => {
      cluster.fork();
      // Brief delay before restarting the next worker
      setTimeout(restartNext, 500);
    });

    worker.disconnect();
  }

  restartNext();
}
```

---

## Fault Tolerance and Auto-Restart

Workers can crash. The primary can detect this and fork a replacement.

```js
cluster.on('exit', (worker, code, signal) => {
  if (!worker.exitedAfterDisconnect) {
    // Unexpected crash — replace the worker
    console.warn(`Worker ${worker.id} crashed. Forking replacement.`);
    cluster.fork();
  } else {
    console.log(`Worker ${worker.id} shut down intentionally.`);
  }
});
```

### Crash loop protection

If a worker repeatedly crashes, forking indefinitely wastes resources. Add backoff logic:

```js
const MAX_RESTARTS = 5;
const RESTART_WINDOW_MS = 10000;
let restartTimestamps = [];

cluster.on('exit', (worker, code, signal) => {
  if (worker.exitedAfterDisconnect) return;

  const now = Date.now();
  restartTimestamps = restartTimestamps.filter(t => now - t < RESTART_WINDOW_MS);

  if (restartTimestamps.length >= MAX_RESTARTS) {
    console.error('Too many worker crashes in a short period. Not restarting.');
    // Consider alerting or exiting the primary
    return;
  }

  restartTimestamps.push(now);
  cluster.fork();
});
```

---

## Sharing State Between Workers

Workers are separate OS processes with independent memory. They **cannot** directly share JavaScript objects or variables.

### Options for shared state

#### 1. External store

The most common approach. Use Redis, Memcached, PostgreSQL, or another out-of-process store.

```js
const redis = require('ioredis');
const client = new redis();

// Worker A writes
await client.set('session:abc', JSON.stringify(sessionData));

// Worker B reads
const data = JSON.parse(await client.get('session:abc'));
```

#### 2. Primary as coordinator

Workers send state to the primary; the primary aggregates and can broadcast.

```js
// Worker sends metrics
process.send({ type: 'metric', key: 'requests', value: 1 });

// Primary tracks totals
const totals = {};
cluster.on('message', (worker, msg) => {
  if (msg.type === 'metric') {
    totals[msg.key] = (totals[msg.key] || 0) + msg.value;
  }
});
```

#### 3. SharedArrayBuffer (limited use)

`SharedArrayBuffer` can be passed via IPC when using `serialization: 'advanced'`. Workers can then read/write a shared memory region, but you must implement your own synchronization (e.g., with `Atomics`). This is an advanced, low-level option.

```js
// Primary creates buffer
const sab = new SharedArrayBuffer(4);
worker.send({ buffer: sab }, undefined, { serialization: 'advanced' });

// Worker receives and uses it
process.on('message', ({ buffer }) => {
  const view = new Int32Array(buffer);
  Atomics.add(view, 0, 1); // atomic increment
});
```

> [!NOTE]  
> `SharedArrayBuffer` requires specific HTTP headers (`Cross-Origin-Opener-Policy`, `Cross-Origin-Embedder-Policy`) when used in browser contexts. This restriction does not apply to Node.js itself, but keep it in mind if your code runs in multiple environments.

---

## Common Patterns

### Pattern 1: HTTP server with clustering

```js
const cluster = require('cluster');
const http = require('http');
const { availableParallelism } = require('os');

if (cluster.isPrimary) {
  const n = availableParallelism();
  for (let i = 0; i < n; i++) cluster.fork();

  cluster.on('exit', (worker) => {
    if (!worker.exitedAfterDisconnect) cluster.fork();
  });
} else {
  http.createServer(app).listen(process.env.PORT || 3000);
}
```

### Pattern 2: Worker pool for CPU-bound tasks

Cluster is designed for network servers, not general worker pools. For CPU-bound tasks, `worker_threads` or `child_process` may be more appropriate. However, if you use cluster for this:

```js
// Primary distributes tasks via IPC
let nextWorkerId = 1;
const workerIds = [];

cluster.on('online', (worker) => workerIds.push(worker.id));

function dispatchTask(task) {
  const id = workerIds[nextWorkerId % workerIds.length];
  nextWorkerId++;
  cluster.workers[id]?.send(task);
}
```

### Pattern 3: Environment-based worker specialization

```js
if (cluster.isPrimary) {
  cluster.fork({ ROLE: 'web' });
  cluster.fork({ ROLE: 'web' });
  cluster.fork({ ROLE: 'background' });
} else {
  const role = process.env.ROLE;
  if (role === 'web') require('./web-server');
  if (role === 'background') require('./background-jobs');
}
```

### Pattern 4: Logging worker stderr/stdout in the primary

```js
cluster.setupPrimary({ silent: true });

cluster.on('fork', (worker) => {
  worker.process.stdout.on('data', (chunk) => {
    process.stdout.write(`[Worker ${worker.id}] ${chunk}`);
  });
  worker.process.stderr.on('data', (chunk) => {
    process.stderr.write(`[Worker ${worker.id}] ${chunk}`);
  });
});
```

---

## Limitations

- **No shared memory by default.** Each worker has its own heap. Sharing state requires an external store or IPC.
- **Primary is a single point of failure.** If the primary crashes, all workers become orphans. Consider a process manager like PM2 to supervise the primary itself.
- **IPC is synchronous on the receiving end.** Large or frequent messages can block the event loop. Keep IPC payloads small.
- **Not suited for CPU-parallelism within a single request.** For that, use `worker_threads`.
- **Cluster does not manage sticky sessions.** If your app requires a user to always reach the same worker (e.g., WebSocket state stored in memory), you must implement sticky load balancing at the reverse proxy level (e.g., Nginx `ip_hash`) or move session state out of worker memory.
- **Windows scheduling.** `SCHED_NONE` is the default on Windows; distribution may be uneven.
- **Forking is slow.** `cluster.fork()` starts a new Node.js process including V8 initialization. It is not suitable for frequent on-demand spawning. Fork workers at startup time.
- **`cluster.workers` is only populated in the primary.** It is `undefined` in worker processes.

---

## Comparison with Related Tools

|Feature|`cluster`|`worker_threads`|`child_process.fork`|PM2|
|---|---|---|---|---|
|Purpose|Multi-core HTTP serving|CPU parallelism, shared memory|General child processes|Process management|
|Shared port|Yes (built-in)|No|No|Yes (via cluster mode)|
|Shared memory|Via `SharedArrayBuffer` + IPC|Yes (natively)|No|No|
|Restart on crash|Manual (via event)|Manual|Manual|Automatic|
|IPC|Built-in|`postMessage`|Built-in|Via cluster|
|Overhead|Process-level|Thread-level|Process-level|Wraps cluster|
|Use case fit|Network servers|CPU-bound tasks|Arbitrary scripts|Production process supervision|

### When to use `worker_threads` instead of `cluster`

- You need true parallelism within a single task (e.g., image processing, cryptography, data crunching)
- You need to share memory (`SharedArrayBuffer`) efficiently between concurrent tasks
- You do not need to share a network port

### When to use PM2 instead of raw `cluster`

- You want built-in log aggregation, monitoring, and auto-restart without writing lifecycle code
- You want `cluster` behavior with zero boilerplate (`pm2 start app.js -i max`)
- You need a production process supervisor with a CLI

---

## Security Considerations

- **IPC is not authenticated.** Any code in the worker process can call `process.send()`. Do not assume messages on the IPC channel are trustworthy if the worker runs untrusted code.
- **Environment variables are inherited.** Workers inherit the parent's `process.env`, including secrets. Be deliberate about what is in the environment before forking.
- **`uid`/`gid` options.** You can drop privileges on workers using `cluster.setupPrimary({ uid, gid })`, so workers run as a less-privileged user. This requires the primary to run as root.
- **`silent: true` captures worker output.** If you pipe worker stdout/stderr to the primary, be careful about logging sensitive data.

---

## Debugging

### Debugging workers with `--inspect`

Each worker needs a unique debugger port. Node.js handles this automatically when you use `--inspect`:

```bash
node --inspect primary.js
```

Workers get sequential ports: `9229`, `9230`, etc.

To set ports explicitly:

```js
cluster.setupPrimary({
  inspectPort: () => {
    // Return a unique port per worker
    return 9230 + Object.keys(cluster.workers).length;
  }
});
```

Then attach a debugger (e.g., Chrome DevTools at `chrome://inspect`) to each port.

### Logging worker IDs

`process.pid` gives you the OS PID. For cluster-specific logging, use the worker ID:

```js
// In a worker process
const workerId = cluster.worker?.id ?? 'primary';
console.log(`[Worker ${workerId}] Request received`);
```

### Detecting which process you're in

```js
console.log(cluster.isPrimary ? 'PRIMARY' : `WORKER ${cluster.worker.id}`);
```

---

## Known Gotchas

### 1. `cluster.isMaster` is deprecated

As of Node.js v16, use `cluster.isPrimary`. The old name still works but will be removed in a future major version.

### 2. Forking too many workers harms performance

More workers than CPU cores means more context switching. A common starting point is `os.availableParallelism()` (Node.js v18.14+) or `os.cpus().length`. Profile before tuning.

### 3. In-memory sessions break across workers

If you store session data in a `Map` or variable inside a worker, another worker handling the next request will not see it. Use a shared external store.

### 4. `server.close()` does not terminate existing connections by default

`server.close()` stops new connections but waits indefinitely for existing ones to finish. Add a timeout or use the `server.closeAllConnections()` method (added in Node.js v18.2) for a harder close.

```js
server.close(() => process.exit(0));
server.closeAllConnections(); // Node.js v18.2+
```

### 5. `cluster.fork()` after `cluster.setupPrimary()` only

Calling `setupPrimary()` after a fork has no effect on already-forked workers.

### 6. `process.on('exit')` vs `worker.on('exit')`

`process.on('exit')` in the primary fires when the **primary** exits, not when a worker exits. Use `cluster.on('exit', handler)` or `worker.on('exit', handler)` to watch workers.

### 7. Windows named pipe behavior

On Windows, Node.js HTTP servers use named pipes internally rather than TCP sockets. Behavior around handle passing can differ subtly from POSIX systems. If you observe unexpected behavior on Windows, check whether `SCHED_NONE` is contributing.

### 8. `worker.exitedAfterDisconnect` is `false` until set

The property is `false` by default and becomes `true` only after `disconnect()` or `kill()` is called programmatically. If you check it inside the `'exit'` handler, it will be `true` for intentional exits and `false` for crashes.

---

## Further Reading

- [Node.js official documentation — cluster](https://nodejs.org/api/cluster.html)
- [Node.js official documentation — worker_threads](https://nodejs.org/api/worker_threads.html)
- [Node.js official documentation — child_process](https://nodejs.org/api/child_process.html)
- [PM2 process manager](https://pm2.keymetrics.io/)