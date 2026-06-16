## Health Check Endpoints

Health check endpoints are the primary interface between a Fastify application and the infrastructure that manages it — Kubernetes probes, load balancers, uptime monitors, and service meshes all depend on these endpoints to make routing, restart, and alerting decisions. This module covers design, implementation, dependency checking, and operational considerations in depth.

---

### Why Health Checks Matter

A process being alive is not the same as a process being healthy or ready to serve traffic. Health endpoints expose the internal state of the application to external observers that cannot otherwise inspect it.

**Key Points:**
- Kubernetes uses liveness probes to decide whether to restart a Pod, and readiness probes to decide whether to route traffic to it — these are distinct decisions requiring distinct endpoints
- Load balancers use health checks to remove unhealthy upstream instances before clients notice
- Monitoring systems use health endpoints to trigger alerts and dashboards
- Health checks provide a forcing function to instrument critical dependency connectivity at the application layer rather than relying solely on infrastructure-level metrics

---

### The Three Standard Endpoints

Modern cloud-native applications typically expose three distinct health endpoints, each serving a different consumer.

| Endpoint | Consumer | Failing means |
|---|---|---|
| `/healthz` | Kubernetes liveness probe | Restart the Pod |
| `/readyz` | Kubernetes readiness probe, LB | Remove from traffic rotation |
| `/livez` | Uptime monitors, dashboards | Alert on-call |

**Key Points:**
- `/healthz` and `/livez` are sometimes unified into one endpoint; separating them allows liveness (process health) to be distinguished from a broader alive signal consumed by external monitors [Inference]
- `/readyz` is the most operationally sensitive — a false negative pulls a healthy Pod from rotation; a false positive routes traffic to an unready instance
- Naming conventions (`/healthz`, `/readyz`, `/livez`) are not mandated by any specification but are widely adopted from Kubernetes internal conventions [Unverified — your organization may prefer `/health`, `/ready`, `/live`]

---

### Basic Implementation

**Example — inline registration:**

```js
import Fastify from 'fastify'

const app = Fastify({ logger: true })

app.get('/healthz', { logLevel: 'silent' }, async () => {
  return { status: 'ok' }
})

app.get('/readyz', { logLevel: 'silent' }, async () => {
  return { status: 'ready' }
})

await app.listen({ port: 3000, host: '0.0.0.0' })
```

**Key Points:**
- `logLevel: 'silent'` suppresses per-request log entries for probe endpoints — Kubernetes polls these every few seconds, producing enormous log volume at default log levels
- Returning a structured JSON body rather than a plain string allows consumers to parse detail fields when needed
- This basic form is only appropriate for the simplest applications — production deployments require dependency-aware checks

---

### Health Plugin with Lifecycle Integration

Wrapping health endpoints in a `fastify-plugin` decorated module integrates them cleanly with Fastify's initialization lifecycle.

**Example — `plugins/health.js`:**

```js
import fp from 'fastify-plugin'

export default fp(async function healthPlugin(app, opts) {
  let isReady = false
  const startTime = Date.now()

  // onReady fires after all plugins are registered and server is listening
  app.addHook('onReady', async () => {
    isReady = true
    app.log.info('Health plugin: application ready')
  })

  // Liveness — is the process responsive?
  app.get('/healthz', {
    logLevel: 'silent',
    schema: {
      response: {
        200: {
          type: 'object',
          properties: {
            status: { type: 'string' },
            uptime: { type: 'number' },
            timestamp: { type: 'string' },
          },
        },
      },
    },
  }, async () => {
    return {
      status: 'ok',
      uptime: Math.floor((Date.now() - startTime) / 1000),
      timestamp: new Date().toISOString(),
    }
  })

  // Readiness — is the app ready to serve traffic?
  app.get('/readyz', {
    logLevel: 'silent',
    schema: {
      response: {
        200: {
          type: 'object',
          properties: {
            status: { type: 'string' },
          },
        },
        503: {
          type: 'object',
          properties: {
            status: { type: 'string' },
          },
        },
      },
    },
  }, async (req, reply) => {
    if (!isReady) {
      return reply.code(503).send({ status: 'not ready' })
    }
    return { status: 'ready' }
  })
}, {
  name: 'health-plugin',
})
```

**Example — `server.js`:**

```js
import Fastify from 'fastify'
import healthPlugin from './plugins/health.js'
import dbPlugin from './plugins/db.js'

const app = Fastify({ logger: true })

// Health registered first — available even if later plugins fail
await app.register(healthPlugin)
await app.register(dbPlugin)
// ... other plugins

await app.listen({ port: 3000, host: '0.0.0.0' })
```

**Key Points:**
- Registering the health plugin first means `/healthz` responds even if a later plugin (e.g., database) fails to initialize — useful for diagnosing startup failures
- The `onReady` hook fires only after `app.listen()` completes, making `isReady` a reliable signal that all plugins have registered and the server is accepting connections
- Wrapping with `fp` exposes the `isReady` state and any decorations to the full app scope rather than scoping them to the plugin's encapsulation context

---

### Dependency-Aware Readiness Checks

A shallow readiness check (process alive + `onReady` fired) is often insufficient. If the database connection pool is exhausted or the cache is unreachable, the app may be running but unable to serve requests correctly.

**Example — multi-dependency readiness check:**

```js
import fp from 'fastify-plugin'

export default fp(async function healthPlugin(app) {
  let isReady = false

  app.addHook('onReady', async () => {
    isReady = true
  })

  app.get('/readyz', { logLevel: 'silent' }, async (req, reply) => {
    if (!isReady) {
      return reply.code(503).send({ status: 'initializing' })
    }

    const checks = await runChecks(app)
    const allPassed = checks.every(c => c.status === 'ok')
    const httpStatus = allPassed ? 200 : 503

    return reply.code(httpStatus).send({
      status: allPassed ? 'ready' : 'degraded',
      checks,
      timestamp: new Date().toISOString(),
    })
  })
})

async function runChecks(app) {
  return Promise.all([
    checkDatabase(app),
    checkRedis(app),
  ])
}

async function checkDatabase(app) {
  try {
    await app.db.raw('SELECT 1')
    return { name: 'database', status: 'ok' }
  } catch (err) {
    return { name: 'database', status: 'error', message: err.message }
  }
}

async function checkRedis(app) {
  try {
    await app.redis.ping()
    return { name: 'redis', status: 'ok' }
  } catch (err) {
    return { name: 'redis', status: 'error', message: err.message }
  }
}
```

**Output — healthy:**

```json
{
  "status": "ready",
  "checks": [
    { "name": "database", "status": "ok" },
    { "name": "redis", "status": "ok" }
  ],
  "timestamp": "2025-06-09T10:00:00.000Z"
}
```

**Output — degraded:**

```json
{
  "status": "degraded",
  "checks": [
    { "name": "database", "status": "ok" },
    { "name": "redis", "status": "error", "message": "connect ECONNREFUSED 127.0.0.1:6379" }
  ],
  "timestamp": "2025-06-09T10:00:01.123Z"
}
```

**Key Points:**
- `Promise.all` runs dependency checks concurrently — check latency is bounded by the slowest check, not their sum
- Returning `checks` in the body gives operators immediate diagnostic detail without needing to inspect logs or dashboards
- The decision to fail readiness on a single dependency failure should be deliberate — if Redis is used only for optional caching, a Redis outage should not remove the Pod from rotation [Inference]
- Expose only non-sensitive diagnostic information in health response bodies — connection strings, internal IPs, and stack traces must not appear in health endpoint responses

---

### Separating Critical from Non-Critical Dependencies

Not all dependency failures warrant pulling a Pod from rotation. Classifying dependencies by criticality allows finer-grained readiness logic.

**Example — tiered dependency checks:**

```js
const dependencies = {
  critical: [
    { name: 'database', check: (app) => app.db.raw('SELECT 1') },
  ],
  nonCritical: [
    { name: 'redis',       check: (app) => app.redis.ping() },
    { name: 'search',      check: (app) => app.elastic.ping() },
    { name: 'featureFlags',check: (app) => app.flags.ping() },
  ],
}

async function runTieredChecks(app) {
  const run = async ({ name, check }) => {
    try {
      await Promise.race([
        check(app),
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error('timeout')), 2000)
        ),
      ])
      return { name, status: 'ok' }
    } catch (err) {
      return { name, status: 'error', message: err.message }
    }
  }

  const [critical, nonCritical] = await Promise.all([
    Promise.all(dependencies.critical.map(run)),
    Promise.all(dependencies.nonCritical.map(run)),
  ])

  const criticalPassed = critical.every(c => c.status === 'ok')

  return {
    ready: criticalPassed,
    critical,
    nonCritical,
  }
}
```

**Key Points:**
- Wrapping each check in `Promise.race` with a timeout prevents a slow dependency from blocking the health endpoint indefinitely — a health endpoint that times out is treated as a failure by most probes
- The 2-second timeout per check should be shorter than the probe's `timeoutSeconds` in Kubernetes config [Inference]
- Non-critical failures are reported in the body for observability but do not affect the HTTP status code

---

### Detailed Status Endpoint (`/livez`)

A richer endpoint intended for monitoring dashboards and alerting systems, returning application metadata, version, and resource usage.

**Example:**

```js
import { readFileSync } from 'fs'

// Read once at startup — avoid fs calls per request
const { version, name } = JSON.parse(
  readFileSync(new URL('../package.json', import.meta.url))
)

const startTime = Date.now()

app.get('/livez', { logLevel: 'silent' }, async () => {
  const mem = process.memoryUsage()

  return {
    status: 'ok',
    name,
    version,
    nodeVersion: process.version,
    env: process.env.NODE_ENV,
    uptime: process.uptime(),
    uptimeHuman: formatUptime(process.uptime()),
    memory: {
      heapUsed:  Math.round(mem.heapUsed  / 1024 / 1024) + ' MB',
      heapTotal: Math.round(mem.heapTotal / 1024 / 1024) + ' MB',
      rss:       Math.round(mem.rss       / 1024 / 1024) + ' MB',
      external:  Math.round(mem.external  / 1024 / 1024) + ' MB',
    },
    pid: process.pid,
    timestamp: new Date().toISOString(),
  }
})

function formatUptime(seconds) {
  const d = Math.floor(seconds / 86400)
  const h = Math.floor((seconds % 86400) / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = Math.floor(seconds % 60)
  return `${d}d ${h}h ${m}m ${s}s`
}
```

**Output:**

```json
{
  "status": "ok",
  "name": "fastify-app",
  "version": "1.4.2",
  "nodeVersion": "v20.11.0",
  "env": "production",
  "uptime": 86432.1,
  "uptimeHuman": "1d 0h 0m 32s",
  "memory": {
    "heapUsed": "48 MB",
    "heapTotal": "72 MB",
    "rss": "94 MB",
    "external": "3 MB"
  },
  "pid": 1,
  "timestamp": "2025-06-09T10:00:00.000Z"
}
```

**Key Points:**
- Reading `package.json` once at startup avoids repeated synchronous filesystem access per request
- `process.memoryUsage()` is cheap and synchronous — safe to call on every request
- `heapUsed` trending upward without stabilizing is a signal for memory leaks; monitoring this endpoint over time provides early warning [Inference]
- Do not expose internal IPs, full dependency URLs, or secrets in this response

---

### Securing Health Endpoints

Health endpoints are typically unauthenticated — probes from Kubernetes cannot carry auth headers by default. However, they should still be protected against misuse.

**Example — restrict to internal network only (nginx):**

```nginx
location /healthz {
  allow 10.0.0.0/8;
  allow 172.16.0.0/12;
  deny  all;
  proxy_pass http://fastify_backend;
}
```

**Example — separate port for health endpoints (Fastify):**

```js
import Fastify from 'fastify'
import http from 'http'

const app = Fastify({ logger: true })
// ... register business routes

// Separate health-only server on internal port
const healthApp = Fastify({ logger: false })

healthApp.get('/healthz', async () => ({ status: 'ok' }))
healthApp.get('/readyz', async () => ({ status: 'ready' }))

// Bind health to localhost only — not exposed externally
await healthApp.listen({ port: 9090, host: '127.0.0.1' })

// Bind main app to all interfaces
await app.listen({ port: 3000, host: '0.0.0.0' })
```

**Kubernetes probe on the internal port:**

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 9090
readinessProbe:
  httpGet:
    path: /readyz
    port: 9090
ports:
  - name: http
    containerPort: 3000
  - name: health
    containerPort: 9090
```

**Key Points:**
- Separating health endpoints onto a dedicated internal port prevents them from appearing in the public API surface or being rate-limited by business-logic middleware
- `127.0.0.1` binding on the health port ensures it is only reachable from within the Pod — Kubernetes probes originate from within the node and can reach `127.0.0.1` on the container [Inference — probe network access depends on the CNI plugin and Kubernetes version; verify in your cluster]
- `/livez` with process metadata should be particularly restricted — memory usage and version information can aid attackers [Inference]

---

### Probe Configuration in Kubernetes

Probe parameters must be tuned to the application's actual startup and response characteristics.

**Example — well-tuned probe config:**

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 3000
  initialDelaySeconds: 10     # time before first probe — allow full startup
  periodSeconds: 15           # probe every 15s
  timeoutSeconds: 3           # fail if no response within 3s
  successThreshold: 1         # one success to mark healthy
  failureThreshold: 3         # three consecutive failures to trigger restart

readinessProbe:
  httpGet:
    path: /readyz
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 3         # three consecutive failures to remove from LB

startupProbe:
  httpGet:
    path: /healthz
    port: 3000
  failureThreshold: 30        # allow up to 30 * periodSeconds for startup
  periodSeconds: 5            # 150s maximum startup window
```

**Key Points:**
- `startupProbe` disables liveness and readiness probes until it passes — preventing premature restarts during slow first-boot scenarios (initial DB migration, cache warming) [Inference — available since Kubernetes 1.16]
- `initialDelaySeconds` is a simpler alternative to `startupProbe` for apps with predictable startup times; `startupProbe` is preferable for variable-duration startups
- `failureThreshold: 3` with `periodSeconds: 15` means a liveness failure triggers a restart after 45 seconds — tune this to balance responsiveness against noise from transient failures
- `timeoutSeconds` on the probe must exceed the worst-case response time of the health endpoint, including any dependency check timeouts

---

### Health Check Architecture Diagram

<svg viewBox="0 0 740 480" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="740" height="480" fill="#0f1117" rx="12"/>
  <text x="370" y="32" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Health Endpoint Consumers and Decision Paths</text>

  <!-- Fastify App box -->
  <rect x="270" y="170" width="200" height="140" rx="10" fill="#0f172a" stroke="#334155" stroke-width="1.5"/>
  <text x="370" y="192" text-anchor="middle" fill="#94a3b8" font-size="11">Fastify App</text>
  <rect x="285" y="200" width="170" height="28" rx="5" fill="#14291f" stroke="#4ade80" stroke-width="1.2"/>
  <text x="370" y="219" text-anchor="middle" fill="#4ade80">/healthz</text>
  <rect x="285" y="235" width="170" height="28" rx="5" fill="#1e2d40" stroke="#818cf8" stroke-width="1.2"/>
  <text x="370" y="254" text-anchor="middle" fill="#818cf8">/readyz</text>
  <rect x="285" y="270" width="170" height="28" rx="5" fill="#1e1a2e" stroke="#c084fc" stroke-width="1.2"/>
  <text x="370" y="289" text-anchor="middle" fill="#c084fc">/livez</text>

  <!-- Kubernetes Liveness -->
  <rect x="30" y="60" width="170" height="60" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="115" y="83" text-anchor="middle" fill="#38bdf8" font-weight="bold">K8s Liveness</text>
  <text x="115" y="100" text-anchor="middle" fill="#94a3b8" font-size="10">Probe → restart on fail</text>

  <!-- Kubernetes Readiness -->
  <rect x="30" y="200" width="170" height="60" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="115" y="223" text-anchor="middle" fill="#38bdf8" font-weight="bold">K8s Readiness</text>
  <text x="115" y="240" text-anchor="middle" fill="#94a3b8" font-size="10">Probe → remove from LB</text>

  <!-- Load Balancer -->
  <rect x="30" y="340" width="170" height="60" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="115" y="363" text-anchor="middle" fill="#38bdf8" font-weight="bold">Load Balancer</text>
  <text x="115" y="380" text-anchor="middle" fill="#94a3b8" font-size="10">Health check → drain</text>

  <!-- Uptime Monitor -->
  <rect x="540" y="60" width="170" height="60" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="625" y="83" text-anchor="middle" fill="#38bdf8" font-weight="bold">Uptime Monitor</text>
  <text x="625" y="100" text-anchor="middle" fill="#94a3b8" font-size="10">Alert on-call on fail</text>

  <!-- Dashboard -->
  <rect x="540" y="200" width="170" height="60" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="625" y="223" text-anchor="middle" fill="#38bdf8" font-weight="bold">Dashboard</text>
  <text x="625" y="240" text-anchor="middle" fill="#94a3b8" font-size="10">Memory / uptime metrics</text>

  <!-- Service Mesh -->
  <rect x="540" y="340" width="170" height="60" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.3"/>
  <text x="625" y="363" text-anchor="middle" fill="#38bdf8" font-weight="bold">Service Mesh</text>
  <text x="625" y="380" text-anchor="middle" fill="#94a3b8" font-size="10">Outlier detection</text>

  <!-- Left arrows -->
  <line x1="200" y1="90" x2="270" y2="214" stroke="#4ade80" stroke-width="1.3" stroke-dasharray="5,3" marker-end="url(#arrowG)"/>
  <line x1="200" y1="230" x2="270" y2="249" stroke="#818cf8" stroke-width="1.3" stroke-dasharray="5,3" marker-end="url(#arrowP)"/>
  <line x1="200" y1="370" x2="270" y2="249" stroke="#818cf8" stroke-width="1.3" stroke-dasharray="5,3" marker-end="url(#arrowP)"/>

  <!-- Right arrows -->
  <line x1="470" y1="214" x2="540" y2="90" stroke="#4ade80" stroke-width="1.3" stroke-dasharray="5,3" marker-end="url(#arrowG)"/>
  <line x1="470" y1="284" x2="540" y2="230" stroke="#c084fc" stroke-width="1.3" stroke-dasharray="5,3" marker-end="url(#arrowV)"/>
  <line x1="470" y1="284" x2="540" y2="370" stroke="#c084fc" stroke-width="1.3" stroke-dasharray="5,3" marker-end="url(#arrowV)"/>

  <!-- Labels on lines -->
  <text x="215" y="148" fill="#4ade80" font-size="10">/healthz</text>
  <text x="205" y="258" fill="#818cf8" font-size="10">/readyz</text>
  <text x="205" y="322" fill="#818cf8" font-size="10">/readyz</text>
  <text x="480" y="140" fill="#4ade80" font-size="10">/healthz</text>
  <text x="475" y="258" fill="#c084fc" font-size="10">/livez</text>
  <text x="475" y="338" fill="#c084fc" font-size="10">/livez</text>

  <!-- Defs -->
  <defs>
    <marker id="arrowG" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4ade80"/>
    </marker>
    <marker id="arrowP" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#818cf8"/>
    </marker>
    <marker id="arrowV" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#c084fc"/>
    </marker>
  </defs>

  <!-- Legend -->
  <rect x="270" y="430" width="200" height="36" rx="6" fill="#0f172a" stroke="#334155" stroke-width="1"/>
  <line x1="285" y1="452" x2="305" y2="452" stroke="#4ade80" stroke-width="1.3" stroke-dasharray="4,2"/>
  <text x="312" y="456" fill="#94a3b8" font-size="10">liveness path</text>
  <line x1="380" y1="452" x2="400" y2="452" stroke="#818cf8" stroke-width="1.3" stroke-dasharray="4,2"/>
  <text x="407" y="456" fill="#94a3b8" font-size="10">readiness path</text>
</svg>

---

### Using `@fastify/under-pressure`

`@fastify/under-pressure` automatically monitors event loop lag, heap usage, and active handles, and can automatically mark the app as unhealthy when thresholds are exceeded.

**Installation:**

```bash
npm install @fastify/under-pressure
```

**Example:**

```js
import underPressure from '@fastify/under-pressure'

await app.register(underPressure, {
  maxEventLoopDelay: 1000,      // ms — fail if event loop lags > 1s
  maxHeapUsedBytes: 200_000_000,// 200 MB heap limit
  maxRssBytes: 300_000_000,     // 300 MB RSS limit
  maxEventLoopUtilization: 0.98,// fail at 98% event loop utilization
  message: 'Service under pressure',
  retryAfter: 50,
  healthCheck: async (app) => {
    // Custom check merged with automatic pressure checks
    await app.db.raw('SELECT 1')
    return true
  },
  healthCheckInterval: 5000,    // run custom check every 5s
  exposeStatusRoute: {
    url: '/readyz',
    routeOpts: { logLevel: 'silent' },
  },
})
```

**Key Points:**
- When thresholds are exceeded, `@fastify/under-pressure` returns `503 Service Unavailable` automatically on all routes — not just the health endpoint [Inference — behavior may vary by version; review the plugin's documentation]
- `maxEventLoopUtilization` (ELU) is a more accurate pressure metric than raw event loop delay; it measures the fraction of time the event loop is active versus idle [Inference]
- `healthCheckInterval` runs the custom `healthCheck` function on a timer rather than per-request, reducing dependency probe load
- `exposeStatusRoute` creates the readiness endpoint automatically — avoid duplicating it manually if using this plugin

---

### Common Mistakes

#### Liveness Probe Checks Dependencies

If `/healthz` checks the database and the database becomes temporarily unreachable, Kubernetes will restart all Pods — a cascading failure that makes a transient dependency outage permanent. Liveness should only check that the process itself is responsive.

#### No Timeout on Dependency Checks

A hanging database connection in `/readyz` will block the probe until Kubernetes times it out. Always wrap dependency checks in a `Promise.race` with an explicit timeout shorter than the probe's `timeoutSeconds`.

#### High-Frequency Readiness Probes Without `logLevel: 'silent'`

With `periodSeconds: 5` and three replicas, a standard-level logger generates 36 log lines per minute from probes alone. Multiply across services and log aggregation costs increase substantially. Always set `logLevel: 'silent'` on probe routes.

#### Returning 200 for a Degraded State

Some implementations always return HTTP 200 and encode health in the body. Kubernetes probes only inspect the HTTP status code — a 200 with `{ "status": "error" }` in the body is treated as healthy. Always use the correct HTTP status code (503 for not ready / unhealthy).

---

**Related Topics:**
- `@fastify/under-pressure` advanced configuration and custom pressure strategies
- Startup probes for applications with variable initialization duration
- Kubernetes Pod Disruption Budgets coordinating with readiness signals
- Distributed health checks across microservices with aggregated status endpoints
- Synthetic transaction checks as an alternative to shallow dependency pings
- Integrating health data with Prometheus metrics (`/metrics` endpoint)
- Circuit breaker patterns triggered by repeated dependency check failures