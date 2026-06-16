## Zero-Downtime Restarts

Zero-downtime restarts allow a Fastify application to reload — for a new deployment, config change, or code update — without dropping a single in-flight request or returning an error to any client. This module covers the mechanisms, patterns, and infrastructure coordination required to achieve this across local process managers and Kubernetes environments.

---

### What Zero-Downtime Restart Requires

A restart is only zero-downtime if three conditions hold simultaneously:

1. **New instances are ready before old ones stop accepting connections** — traffic is never left with nowhere to go
2. **In-flight requests on old instances complete before the process exits** — no connections are torn mid-response
3. **The load balancer or proxy is notified before and after** — it routes away from draining instances and toward ready ones

Failing any single condition produces dropped connections, `ECONNRESET` errors, or 502/503 responses visible to clients. [Inference — exact failure mode depends on the proxy, protocol, and timing]

---

### Graceful Shutdown as a Prerequisite

Zero-downtime restarts depend entirely on correct graceful shutdown behavior. The restart sequence is:

```
start new instance → new instance ready → drain old instance → old instance exits
```

The drain step requires the old Fastify instance to:
- Stop accepting new connections
- Complete all in-flight requests
- Close plugins and database pools cleanly
- Exit with code `0`

**Example — canonical graceful shutdown in Fastify:**

```js
// server.js
import Fastify from 'fastify'

const app = Fastify({ logger: true })

// ... register plugins and routes ...

const shutdown = async (signal) => {
  app.log.info({ signal }, 'Received shutdown signal')
  try {
    await app.close()
    app.log.info('Server closed cleanly')
    process.exit(0)
  } catch (err) {
    app.log.error(err, 'Error during shutdown')
    process.exit(1)
  }
}

process.on('SIGTERM', () => shutdown('SIGTERM'))
process.on('SIGINT',  () => shutdown('SIGINT'))

await app.listen({ port: 3000, host: '0.0.0.0' })
```

**Key Points:**
- `app.close()` calls `server.close()` internally, which stops accepting new connections and waits for existing ones to finish before resolving
- `SIGTERM` is the signal sent by Kubernetes, systemd, and most process managers during controlled shutdown
- `SIGINT` handles local `Ctrl+C` during development
- A shutdown timeout should be added for production — `app.close()` may hang if a connection is kept alive indefinitely [see the timeout pattern below]

---

### Shutdown Timeout Guard

`app.close()` resolves only when all connections finish. A misbehaving keep-alive client can hold this open indefinitely. A hard timeout prevents the process from hanging.

**Example:**

```js
const shutdown = async (signal) => {
  app.log.info({ signal }, 'Shutdown initiated')

  const timeout = setTimeout(() => {
    app.log.error('Shutdown timed out — forcing exit')
    process.exit(1)
  }, 10_000) // 10 second hard limit

  timeout.unref() // don't let the timer itself block exit

  try {
    await app.close()
    clearTimeout(timeout)
    process.exit(0)
  } catch (err) {
    app.log.error(err, 'Shutdown error')
    clearTimeout(timeout)
    process.exit(1)
  }
}
```

**Key Points:**
- `timeout.unref()` prevents the timer from keeping the event loop alive if everything else finishes first
- The timeout value should exceed your p99 request duration; 10–30 seconds is common for API servers [Inference]
- Align this value with `terminationGracePeriodSeconds` in Kubernetes Deployments and the `kill_timeout` in PM2 config

---

### Zero-Downtime Restarts with PM2

PM2's cluster mode runs multiple Fastify worker processes behind an internal load balancer and can perform rolling restarts — cycling workers one at a time.

**Example — `ecosystem.config.cjs`:**

```js
module.exports = {
  apps: [
    {
      name: 'fastify-app',
      script: './src/server.js',
      instances: 'max',           // one worker per CPU core
      exec_mode: 'cluster',
      listen_timeout: 8000,       // ms to wait for a new worker to be ready
      kill_timeout: 10000,        // ms to wait for graceful shutdown before SIGKILL
      wait_ready: true,           // wait for process.send('ready') before routing traffic
      max_memory_restart: '512M',
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
    },
  ],
}
```

**Example — signaling readiness to PM2:**

```js
// server.js
await app.listen({ port: 3000, host: '0.0.0.0' })

// Signal PM2 that this worker is ready to receive traffic
if (process.send) {
  process.send('ready')
}
```

**Performing a zero-downtime restart:**

```bash
# Rolling restart — cycles workers one at a time
pm2 reload fastify-app

# Full restart (not zero-downtime — avoid in production)
pm2 restart fastify-app
```

**Key Points:**
- `pm2 reload` (not `restart`) is the zero-downtime command — it sends SIGINT to one worker, waits for `kill_timeout`, then starts a replacement before moving to the next
- `wait_ready: true` combined with `process.send('ready')` means PM2 only routes traffic to a new worker after the Fastify server is fully listening and all plugins are registered
- Without `wait_ready`, PM2 routes traffic as soon as the process starts — before Fastify has finished plugin registration [Inference — behavior depends on PM2 version]
- `listen_timeout` defines how long PM2 waits for the `ready` signal; if the app takes longer, PM2 marks it as failed

#### PM2 Cluster Mode Architecture

```
                    ┌─────────────────────────┐
     Incoming       │         PM2             │
     Requests  ───► │   Internal LB / IPC     │
                    └────┬──────┬──────┬──────┘
                         │      │      │
                    ┌────▼─┐ ┌──▼──┐ ┌─▼────┐
                    │ W-0  │ │ W-1 │ │ W-2  │
                    │:3000 │ │:3000│ │:3000 │
                    └──────┘ └─────┘ └──────┘
                      Fastify workers (cluster mode)
```

During `pm2 reload`, PM2 replaces workers sequentially — new worker starts, receives `ready`, old worker drains and exits.

---

### Zero-Downtime Restarts with Kubernetes

Kubernetes rolling updates are the primary zero-downtime restart mechanism for containerized Fastify apps. The Deployment controller replaces Pods incrementally based on the configured strategy.

**Example — Deployment with zero-downtime strategy:**

```yaml
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0   # never reduce below desired replica count
      maxSurge: 1         # allow one extra Pod during rollout
  template:
    spec:
      terminationGracePeriodSeconds: 30
      containers:
        - name: fastify-app
          image: your-registry/fastify-app:2.0.0
          readinessProbe:
            httpGet:
              path: /readyz
              port: 3000
            initialDelaySeconds: 3
            periodSeconds: 5
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /healthz
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 5"]
```

**Key Points:**
- `maxUnavailable: 0` is the critical setting — no Pod is terminated until its replacement passes readiness checks
- `maxSurge: 1` creates one extra Pod temporarily, keeping total capacity above the desired count during rollout
- `preStop` sleep of 5 seconds gives the kube-proxy and cloud load balancer time to drain the endpoint before SIGTERM is sent — without it, requests may still arrive during the shutdown window [Inference — actual drain latency is provider-dependent]
- `terminationGracePeriodSeconds` must exceed the `preStop` duration plus the time needed for `app.close()` to complete

#### Kubernetes Rolling Restart Sequence

```
State 0:  [Pod-A ready] [Pod-B ready] [Pod-C ready]
                          ↓ kubectl rollout (new image)
State 1:  [Pod-A ready] [Pod-B ready] [Pod-C ready] [Pod-D starting]
State 2:  [Pod-A ready] [Pod-B ready] [Pod-C ready] [Pod-D ready]
                          ↓ Pod-A receives SIGTERM (preStop sleep → drain → exit)
State 3:  [Pod-A draining] [Pod-B ready] [Pod-C ready] [Pod-D ready]
State 4:  [Pod-B ready] [Pod-C ready] [Pod-D ready] [Pod-E starting]
                          ... continues per replica
```

**Triggering a rolling restart without a code change:**

```bash
# Force a rolling restart by annotating the Deployment (no image change needed)
kubectl rollout restart deployment/fastify-app -n production

# Monitor progress
kubectl rollout status deployment/fastify-app -n production

# Rollback if the new version is unhealthy
kubectl rollout undo deployment/fastify-app -n production
```

---

### Readiness Probe Correctness

The readiness probe is the gating mechanism for zero-downtime behavior in Kubernetes. A Pod only receives traffic when its readiness probe passes; it is removed from the Service endpoint list when the probe fails.

**Example — readiness probe that reflects plugin initialization:**

```js
// plugins/health.js
import fp from 'fastify-plugin'

export default fp(async function health(app) {
  let ready = false

  // onReady fires after all plugins are initialized and server is listening
  app.addHook('onReady', async () => {
    ready = true
  })

  // Optionally check downstream dependencies
  app.get('/readyz', { logLevel: 'silent' }, async (req, reply) => {
    if (!ready) {
      return reply.code(503).send({ status: 'not ready' })
    }

    // Optional: probe a critical dependency
    try {
      await app.db.raw('SELECT 1') // example: knex health check
    } catch (err) {
      app.log.warn(err, 'Database not reachable during readiness check')
      return reply.code(503).send({ status: 'db unavailable' })
    }

    return { status: 'ready' }
  })

  app.get('/healthz', { logLevel: 'silent' }, async () => {
    return { status: 'ok' }
  })
})
```

**Key Points:**
- Liveness and readiness probes serve distinct roles — do not conflate them
- A failing readiness probe removes the Pod from load balancing without restarting it; a failing liveness probe triggers a restart
- Including a shallow database ping in `/readyz` catches cases where the app starts but its dependencies are not reachable — at the cost of making the probe dependent on an external system [Inference — this tradeoff should be evaluated per application]
- Overly aggressive readiness probes (short `periodSeconds`, low `failureThreshold`) can cause unnecessary Pod thrashing during transient dependency blips

---

### Zero-Downtime with a Reverse Proxy (nginx / Caddy)

When running Fastify behind nginx on a single host (common in smaller deployments or VMs), zero-downtime restarts require starting the new process before stopping the old one and using the proxy's upstream health checks to gate traffic.

**Approach — port swap with upstream health check:**

```nginx
upstream fastify_backend {
  server 127.0.0.1:3000 max_fails=3 fail_timeout=10s;
  server 127.0.0.1:3001 backup;
}

server {
  listen 80;
  location / {
    proxy_pass http://fastify_backend;
    proxy_next_upstream error timeout http_502 http_503;
  }
}
```

**Restart script:**

```bash
#!/bin/bash
# Start new instance on port 3001
PORT=3001 node src/server.js &
NEW_PID=$!

# Wait for the new instance to be healthy
until curl -sf http://127.0.0.1:3001/healthz; do
  sleep 1
done

# Promote new instance to primary (nginx reload is zero-downtime)
sed -i 's/3001 backup/3001/' /etc/nginx/conf.d/app.conf
nginx -s reload

# Drain old instance
OLD_PID=$(cat /run/fastify.pid)
kill -SIGTERM "$OLD_PID"

# Wait for clean exit
wait "$OLD_PID"

# Save new PID
echo "$NEW_PID" > /run/fastify.pid
```

**Key Points:**
- `nginx -s reload` performs a zero-downtime nginx configuration reload — workers finish their current requests before the config is swapped [Inference — behavior consistent across nginx versions but verify in your environment]
- `proxy_next_upstream` retries failed requests on the next upstream, reducing client-visible errors during the transition window
- This pattern is operationally fragile compared to Kubernetes rolling updates and is primarily relevant for single-node or resource-constrained deployments [Inference]

---

### Connection Draining and Keep-Alive

HTTP keep-alive connections complicate graceful shutdown. A client maintaining a persistent connection does not release it until the server signals closure, potentially blocking `app.close()`.

**Example — setting keep-alive timeout:**

```js
const app = Fastify({
  logger: true,
  keepAliveTimeout: 5000,      // 5s — close idle keep-alive connections sooner
  connectionTimeout: 10000,    // 10s — abort connections that never send a request
})
```

**Example — sending `Connection: close` on shutdown:**

```js
// During shutdown, add a hook to send Connection: close on all responses
// This signals clients to not reuse the connection
const shutdown = async (signal) => {
  app.log.info({ signal }, 'Shutdown: adding Connection: close header')

  app.addHook('onSend', async (req, reply) => {
    reply.header('connection', 'close')
  })

  const timeout = setTimeout(() => process.exit(1), 10_000)
  timeout.unref()

  await app.close()
  clearTimeout(timeout)
  process.exit(0)
}
```

**Key Points:**
- `keepAliveTimeout` defaults to `72000` ms (72 seconds) in Node.js — this is far too long for graceful shutdown in most deployments; lower it to 5–15 seconds [Inference — exact default varies by Node.js version]
- Sending `Connection: close` during the drain phase encourages clients and proxies to open new connections to a healthy instance rather than reusing the draining one
- Load balancers (nginx, ALB, Envoy) also maintain their own keep-alive connections to upstream instances; the `preStop` sleep addresses the upstream side of this problem

---

### Full Zero-Downtime Checklist

| Concern | Mechanism | Notes |
|---|---|---|
| Stop accepting new connections | `app.close()` → `server.close()` | Automatic in Fastify |
| Complete in-flight requests | `app.close()` waits for open connections | May hang on keep-alive; use timeout guard |
| Signal readiness before traffic | `process.send('ready')` / readiness probe | PM2: `wait_ready`; K8s: `readinessProbe` |
| Signal unreadiness before shutdown | `preStop` hook / readiness probe failure | K8s: `preStop` sleep; PM2: automatic |
| Hard shutdown timeout | `setTimeout` → `process.exit(1)` | Align with infra grace period |
| Keep-alive connection handling | `keepAliveTimeout` + `Connection: close` | Lower default; header on drain |
| Liveness vs readiness separation | Separate `/healthz` and `/readyz` | Do not conflate |
| Rolling update strategy | `maxUnavailable: 0`, `maxSurge: 1` | Kubernetes only |

---

**Related Topics:**
- Pod Disruption Budgets (PDB) for availability guarantees during node drain
- Horizontal Pod Autoscaler behavior during rolling restarts
- `SIGTERM` vs `SIGKILL` handling in containerized Node.js
- Circuit breaker patterns to shed load during partial unavailability
- Blue-green and canary deployment strategies as alternatives to rolling updates
- Connection pool drain strategies for PostgreSQL and Redis during shutdown
- Fastify `onClose` hook for plugin-level cleanup ordering