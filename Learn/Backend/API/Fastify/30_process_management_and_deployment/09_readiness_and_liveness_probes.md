## Readiness and Liveness Probes

Readiness and liveness probes are Kubernetes mechanisms that continuously interrogate a running Pod to make traffic routing and restart decisions. While health check endpoints define *what* the application reports, probes define *how* and *when* Kubernetes acts on those reports. This module covers probe types, configuration parameters, failure semantics, timing strategy, and interaction effects in depth.

---

### Probe Taxonomy

Kubernetes provides three probe types, each serving a distinct operational purpose.

| Probe | Question asked | Action on failure |
|---|---|---|
| **Liveness** | Is this container still functioning? | Kill and restart the container |
| **Readiness** | Is this container ready to serve traffic? | Remove from Service endpoint list |
| **Startup** | Has this container finished initializing? | Kill and restart if deadline exceeded |

**Key Points:**
- Liveness and readiness failures have fundamentally different consequences — a liveness failure causes a restart; a readiness failure causes traffic removal without restart
- Startup probes gate liveness and readiness probes — neither fires until the startup probe passes, preventing premature restarts during slow initialization
- All three probes run independently and concurrently once startup succeeds [Inference — Kubernetes schedules probe execution via the kubelet; exact timing is not deterministic]
- A Pod can be simultaneously not-ready (removed from LB) and liveness-passing (no restart) — this is the intended state during graceful drain

---

### Probe Mechanisms

Each probe type supports three invocation mechanisms regardless of which probe role it fills.

#### HTTP GET

The kubelet makes an HTTP GET to the specified path and port. Any response with status code `200–399` is a success.

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 3000
    httpHeaders:
      - name: X-Health-Check
        value: kubernetes
    scheme: HTTP   # or HTTPS
```

**Key Points:**
- HTTP GET is the most common mechanism for Fastify applications — it leverages existing HTTP infrastructure and allows response body inspection in logs
- Custom headers can be used to distinguish probe traffic from regular traffic in logs, even with `logLevel: 'silent'` suppressed [Inference]
- `scheme: HTTPS` requires the container to serve TLS directly; most deployments terminate TLS at the Ingress and use plain HTTP internally

#### TCP Socket

The kubelet attempts to open a TCP connection. Success means the port is accepting connections.

```yaml
livenessProbe:
  tcpSocket:
    port: 3000
```

**Key Points:**
- TCP probes succeed as soon as the port is open — before Fastify has finished registering plugins or connecting to the database
- TCP probes are appropriate for non-HTTP workloads (raw TCP servers, gRPC without reflection); for Fastify, HTTP GET probes are strongly preferred [Inference]
- A TCP probe passing does not mean the application is healthy — only that the process is listening on the port

#### Exec

The kubelet executes a command inside the container. Exit code `0` is success; any other exit code is failure.

```yaml
livenessProbe:
  exec:
    command:
      - node
      - scripts/healthcheck.js
```

**Key Points:**
- Exec probes spawn a new process inside the container on every probe interval — this has non-trivial CPU and memory overhead in high-frequency configurations [Inference]
- Exec probes are typically a last resort when HTTP is unavailable; for Fastify they offer no advantages over HTTP GET
- The spawned process inherits the container's environment variables, making it possible to perform authenticated checks if credentials are available in env

---

### Probe Configuration Parameters

Every probe shares the same set of timing and threshold parameters.

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 3000
  initialDelaySeconds: 10
  periodSeconds: 15
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 3
```

#### Parameter Reference

| Parameter | Default | Meaning |
|---|---|---|
| `initialDelaySeconds` | 0 | Seconds after container start before first probe |
| `periodSeconds` | 10 | Interval between probe executions |
| `timeoutSeconds` | 1 | Seconds before a probe attempt is considered failed |
| `successThreshold` | 1 | Consecutive successes needed to mark healthy |
| `failureThreshold` | 3 | Consecutive failures needed to trigger action |

**Key Points:**
- `timeoutSeconds` defaults to `1` — this is dangerously low for dependency-aware `/readyz` endpoints that perform database pings; always set it explicitly
- `successThreshold` must be `1` for liveness and startup probes; values greater than `1` are only valid for readiness probes [Inference — Kubernetes validation enforces this]
- `failureThreshold * periodSeconds` defines the detection window — with defaults, a liveness failure triggers restart after 30 seconds
- `initialDelaySeconds` is a blunt instrument; `startupProbe` is the preferred solution for variable-duration startup [see below]

---

### Startup Probe

The startup probe solves the tension between fast failure detection during normal operation and tolerance for slow first-boot initialization. While the startup probe is pending, liveness and readiness probes are suspended.

```yaml
startupProbe:
  httpGet:
    path: /healthz
    port: 3000
  failureThreshold: 30
  periodSeconds: 5
  timeoutSeconds: 3
```

**Key Points:**
- This configuration allows up to `30 × 5 = 150` seconds for startup before Kubernetes kills the container — far more than `initialDelaySeconds` can safely provide without inflating liveness probe latency during steady-state operation
- Once the startup probe passes once, it is disabled for the lifetime of the container — liveness and readiness take over
- If the startup probe never passes within `failureThreshold × periodSeconds`, the container is killed and the restart policy applies
- Fastify applications with heavy plugin initialization (running migrations, warming caches, precompiling routes) benefit most from startup probes [Inference]

#### Startup Probe Timeline

```
Container starts
      │
      ├─── startupProbe polling begins (every periodSeconds)
      │         │
      │         ├─ attempt 1: 503 (still initializing)
      │         ├─ attempt 2: 503 (plugins loading)
      │         ├─ attempt 3: 200 ✓ startup probe PASSES
      │         │
      │    livenessProbe + readinessProbe now active
      │         │
      ├─── readinessProbe: 200 → Pod added to Service endpoints
      │
      └─── steady-state: liveness + readiness poll independently
```

---

### Timing Interaction Between Probes

Probe timing must be designed holistically — each probe's parameters interact with the others and with the application's lifecycle hooks.

```
t=0    Container starts
t=0    startupProbe begins
t=15   startupProbe passes (Fastify onReady fired, /healthz returns 200)
t=15   livenessProbe begins  (initialDelaySeconds=0 after startup passes)
t=18   readinessProbe: first check (initialDelaySeconds=3)
t=18   readinessProbe passes → Pod enters Service endpoints
t=33   livenessProbe: second check
t=23   readinessProbe: second check
       ... steady state ...
t=900  Database becomes unreachable
t=900  readinessProbe fails (1st)
t=905  readinessProbe fails (2nd)
t=910  readinessProbe fails (3rd) → Pod removed from endpoints
t=910  livenessProbe still passing → no restart
t=930  Database recovers
t=935  readinessProbe passes → Pod re-enters endpoints
```

**Key Points:**
- The separation of readiness and liveness in this timeline is the correct behavior — the Pod is removed from traffic rotation but not restarted during a transient dependency outage
- Had liveness also checked the database, all three failures would have triggered a restart, potentially cascading across replicas [Inference]
- Probe timing diagrams like this are useful for validating that `initialDelaySeconds`, `periodSeconds`, and `failureThreshold` values produce the intended behavior before deploying to production

---

### Fastify Application: Full Probe-Compatible Implementation

**Example — `plugins/probes.js`:**

```js
import fp from 'fastify-plugin'

export default fp(async function probesPlugin(app, opts) {
  const {
    readyzPath    = '/readyz',
    healthzPath   = '/healthz',
    logLevel      = 'silent',
    criticalChecks = [],
  } = opts

  let appReady = false
  let startTime = Date.now()

  app.addHook('onReady', async () => {
    appReady = true
    app.log.info('Probe plugin: application marked ready')
  })

  // Liveness — process responsiveness only, no dependency checks
  app.get(healthzPath, { logLevel }, async () => ({
    status: 'ok',
    uptime: Math.floor((Date.now() - startTime) / 1000),
    timestamp: new Date().toISOString(),
  }))

  // Readiness — initialization state + critical dependencies
  app.get(readyzPath, { logLevel }, async (req, reply) => {
    if (!appReady) {
      return reply.code(503).send({
        status: 'initializing',
        timestamp: new Date().toISOString(),
      })
    }

    if (criticalChecks.length === 0) {
      return { status: 'ready', timestamp: new Date().toISOString() }
    }

    const PROBE_TIMEOUT_MS = 2000

    const results = await Promise.all(
      criticalChecks.map(async ({ name, check }) => {
        try {
          await Promise.race([
            check(app),
            new Promise((_, reject) =>
              setTimeout(
                () => reject(new Error(`${name} check timed out`)),
                PROBE_TIMEOUT_MS
              )
            ),
          ])
          return { name, status: 'ok' }
        } catch (err) {
          app.log.warn({ name, err }, 'Readiness check failed')
          return { name, status: 'error', message: err.message }
        }
      })
    )

    const allPassed = results.every(r => r.status === 'ok')

    return reply.code(allPassed ? 200 : 503).send({
      status: allPassed ? 'ready' : 'degraded',
      checks: results,
      timestamp: new Date().toISOString(),
    })
  })
}, {
  name: 'probes-plugin',
  fastify: '4.x || 5.x',
})
```

**Example — registering with critical checks:**

```js
import Fastify from 'fastify'
import probesPlugin from './plugins/probes.js'
import dbPlugin from './plugins/db.js'
import redisPlugin from './plugins/redis.js'

const app = Fastify({ logger: true })

await app.register(probesPlugin, {
  criticalChecks: [
    { name: 'postgres', check: (app) => app.db.raw('SELECT 1') },
    { name: 'redis',    check: (app) => app.redis.ping() },
  ],
})

await app.register(dbPlugin)
await app.register(redisPlugin)

await app.listen({ port: 3000, host: '0.0.0.0' })
```

**Key Points:**
- Registering `probesPlugin` before `dbPlugin` and `redisPlugin` means `/healthz` responds even if those plugins fail to initialize — startup failures are diagnosable via the liveness endpoint
- The `criticalChecks` option makes the plugin reusable across services with different dependency profiles
- Per-check timeout of 2000ms is shorter than a typical `timeoutSeconds: 3` on the probe — the check returns a structured error before Kubernetes considers the probe timed out [Inference]
- `fastify: '4.x || 5.x'` in the plugin options declares compatibility; update to match your actual Fastify version

---

### Probe Failure Semantics in Detail

#### Readiness Failure Behavior

```
readinessProbe fails failureThreshold times consecutively
          ↓
kubelet removes Pod's IP from Endpoints object
          ↓
kube-proxy updates iptables / IPVS rules on all nodes
          ↓
Service stops routing new connections to this Pod
          ↓
In-flight connections on existing keep-alive connections
may continue until they complete or are closed
          ↓
readinessProbe passes successThreshold times
          ↓
Pod IP re-added to Endpoints — traffic resumes
```

**Key Points:**
- There is propagation latency between the kubelet removing the endpoint and kube-proxy updating routing rules — typically milliseconds to low seconds depending on cluster size [Inference — actual propagation time varies significantly]
- Requests already in flight on persistent connections are not immediately dropped — graceful connection handling on the application side remains important
- A Pod removed from readiness does not receive new connections from the Service but may still receive direct Pod IP traffic from other Pods [Inference]

#### Liveness Failure Behavior

```
livenessProbe fails failureThreshold times consecutively
          ↓
kubelet sends SIGTERM to PID 1 in the container
          ↓
terminationGracePeriodSeconds countdown begins
          ↓
Fastify receives SIGTERM → calls app.close()
          ↓
app.close() stops accepting new connections,
drains in-flight requests
          ↓
Process exits cleanly (exit 0)
          ↓
If process has not exited by terminationGracePeriodSeconds:
kubelet sends SIGKILL — immediate termination
          ↓
kubelet starts a new container (restartPolicy: Always)
```

**Key Points:**
- The liveness failure → SIGTERM path is identical to a normal Pod termination — graceful shutdown handlers apply equally
- `restartPolicy` on the Pod spec governs whether and how many times a container is restarted; for Deployments this defaults to `Always`
- Kubernetes applies an exponential backoff to restart delays after repeated failures: 10s, 20s, 40s, up to 5 minutes — a Pod in `CrashLoopBackOff` is experiencing this [Inference — exact backoff values may vary across Kubernetes versions]
- `CrashLoopBackOff` is the observable symptom of a liveness probe that is misconfigured to check a dependency that is itself unavailable — a common and painful misconfiguration

---

### Probe Tuning by Application Profile

Different Fastify application profiles require different probe configurations. Behavior described below may vary depending on cluster version and configuration.

#### Fast-Starting API Server

```yaml
startupProbe:
  httpGet:
    path: /healthz
    port: 3000
  failureThreshold: 6
  periodSeconds: 3       # 18s maximum startup window

livenessProbe:
  httpGet:
    path: /healthz
    port: 3000
  periodSeconds: 15
  timeoutSeconds: 3
  failureThreshold: 3    # restart after 45s of liveness failure

readinessProbe:
  httpGet:
    path: /readyz
    port: 3000
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3    # remove from LB after 15s of readiness failure
```

#### Slow-Starting Server (Migrations, Cache Warm-Up)

```yaml
startupProbe:
  httpGet:
    path: /healthz
    port: 3000
  failureThreshold: 60
  periodSeconds: 5       # 300s = 5 minute startup window

livenessProbe:
  httpGet:
    path: /healthz
    port: 3000
  periodSeconds: 20
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /readyz
    port: 3000
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

#### High-Availability Service (Minimize Unnecessary Removals)

```yaml
readinessProbe:
  httpGet:
    path: /readyz
    port: 3000
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 5    # tolerate more transient failures before removal
  successThreshold: 2    # require two consecutive successes to re-enter rotation
```

**Key Points:**
- `successThreshold: 2` on readiness prevents flapping — a Pod that passes once during intermittent instability does not immediately re-enter rotation
- Higher `failureThreshold` values on readiness reduce sensitivity to transient dependency blips at the cost of slower removal during genuine failures
- `timeoutSeconds` on the probe must always exceed the maximum expected response time of the health endpoint under load, including dependency check latency [Inference]

---

### Probe Configuration Interactions with Deployment Strategy

Probe parameters interact directly with rolling update behavior.

```yaml
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  template:
    spec:
      containers:
        - name: fastify-app
          readinessProbe:
            httpGet:
              path: /readyz
              port: 3000
            periodSeconds: 5
            failureThreshold: 3
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 5"]
      terminationGracePeriodSeconds: 30
```

**The gating sequence during a rolling update:**

```
New Pod scheduled
      │
      ├── startupProbe polling
      ├── startupProbe passes
      ├── readinessProbe passes (successThreshold met)
      │
      ↓
Pod added to Service endpoints   ← Kubernetes waits here before
                                    terminating an old Pod
      │
Old Pod receives SIGTERM (after preStop sleep)
      ↓
Old Pod drains and exits
```

**Key Points:**
- `maxUnavailable: 0` means Kubernetes will not send SIGTERM to an old Pod until a new Pod's readiness probe has passed — the readiness probe is the gate
- If the readiness probe is too slow to pass (high `initialDelaySeconds` without a startup probe, or dependency check timeouts), rolling updates stall and can time out [Inference]
- The `progressDeadlineSeconds` field on the Deployment (default: 600s) defines how long a rollout can stall before being marked as failed

---

### Probe Observability

Probe activity should be observable without adding log noise.

**Example — conditional probe logging:**

```js
app.get('/readyz', {
  logLevel: 'silent', // suppress per-request logs
}, async (req, reply) => {
  const result = await runChecks(app)

  // Log only on state change, not every probe
  if (!result.ready && app.lastReadyState !== false) {
    app.log.warn({ checks: result.checks }, 'Readiness transitioned to NOT READY')
  } else if (result.ready && app.lastReadyState === false) {
    app.log.info({ checks: result.checks }, 'Readiness transitioned to READY')
  }

  app.lastReadyState = result.ready

  return reply
    .code(result.ready ? 200 : 503)
    .send(result)
})
```

**Key Points:**
- Logging on state transitions rather than every probe call preserves signal — a readiness flip is worth logging; every passing probe is not
- `app.lastReadyState` is a simple decoration; for multi-replica deployments each Pod tracks its own state independently
- Probe results can be pushed to a Prometheus counter or gauge via `@fastify/metrics` for fleet-wide readiness visibility [Inference — requires metrics plugin integration]

---

### Full Probe Configuration Reference

```yaml
startupProbe:
  httpGet:
    path: /healthz
    port: 3000
    scheme: HTTP
  initialDelaySeconds: 0   # startup probe begins immediately
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1      # must be 1 for startup probe
  failureThreshold: 30     # 150s total startup budget

livenessProbe:
  httpGet:
    path: /healthz
    port: 3000
  initialDelaySeconds: 0   # startup probe gates this; initialDelay redundant
  periodSeconds: 15
  timeoutSeconds: 3
  successThreshold: 1      # must be 1 for liveness probe
  failureThreshold: 3      # restart after 45s of consecutive failure

readinessProbe:
  httpGet:
    path: /readyz
    port: 3000
  initialDelaySeconds: 0
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 3      # remove from LB after 15s of consecutive failure
```

---

### Anti-Patterns

#### Liveness Probe Checks External Dependencies

The most common and damaging misconfiguration. If `/healthz` queries the database and the database has a transient outage, Kubernetes restarts all Pods simultaneously — converting a recoverable outage into a full service restart cascade.

#### `timeoutSeconds: 1` with Dependency Checks

The default `timeoutSeconds` of `1` second is insufficient for any check that touches a network dependency. A probe that times out counts as a failure. Set `timeoutSeconds` to at least `3–5` seconds for dependency-aware readiness endpoints.

#### No Startup Probe on Slow-Starting Apps

Without a startup probe, the liveness probe begins immediately after `initialDelaySeconds`. If startup takes longer than `initialDelaySeconds + (failureThreshold × periodSeconds)`, Kubernetes restarts the container before it finishes initializing — creating an infinite restart loop.

#### Identical Liveness and Readiness Endpoints

Using the same endpoint for both probes eliminates the ability to distinguish between "this Pod needs a restart" and "this Pod should be temporarily removed from rotation." These are operationally distinct conditions requiring separate signals.

#### `successThreshold > 1` on Liveness

Kubernetes does not allow `successThreshold > 1` for liveness or startup probes and will reject the manifest. This constraint is enforced at the API server level.

---

**Related Topics:**
- Pod Disruption Budgets controlling availability during node drain and probe failures
- `terminationGracePeriodSeconds` alignment with probe failure window and shutdown duration
- Horizontal Pod Autoscaler interactions with readiness — unready Pods are excluded from HPA metrics calculations
- gRPC health checking protocol as an alternative to HTTP GET for gRPC-serving Fastify apps
- Service mesh sidecar probe interception in Istio and Linkerd
- Custom liveness logic for stateful workers and queue consumers
- Prometheus alerting rules based on Kubernetes probe failure metrics