## Metrics with Prometheus and @fastify/metrics

Prometheus is the dominant metrics collection system in cloud-native infrastructure. Integrating it with Fastify exposes request rates, latencies, error counts, and custom application metrics to a scrape-based collection pipeline that feeds dashboards, alerts, and autoscaling decisions. This module covers installation, default metrics, custom instrumentation, cardinality management, and production configuration.

---

### How Prometheus Metrics Work

Prometheus operates on a pull model — it scrapes a `/metrics` HTTP endpoint on a configured interval rather than receiving pushed data. The application maintains in-memory metric state; Prometheus reads it periodically.

**Key Points:**
- The `/metrics` endpoint returns text in Prometheus exposition format — a line-based protocol parseable by Prometheus, Grafana Agent, OpenTelemetry Collector, and compatible tooling
- Metrics are stored as time series identified by a metric name and a set of key-value labels
- Four core metric types exist: Counter, Gauge, Histogram, and Summary — each suited to different measurement semantics
- Fastify's request lifecycle and plugin system make it straightforward to instrument at the framework level, capturing metrics across all routes without per-route boilerplate

---

### Metric Types

#### Counter

A monotonically increasing value. Never decreases except on process restart.

```
http_requests_total{method="GET", status="200", route="/users"} 4821
```

Use for: request counts, error counts, bytes sent, events processed.

#### Gauge

A value that can increase or decrease arbitrarily.

```
nodejs_active_handles_total 12
process_resident_memory_bytes 98304000
```

Use for: active connections, queue depth, memory usage, concurrent requests.

#### Histogram

Samples observations into configurable buckets, also tracking sum and count.

```
http_request_duration_seconds_bucket{le="0.05"} 2400
http_request_duration_seconds_bucket{le="0.1"}  3200
http_request_duration_seconds_bucket{le="0.5"}  4750
http_request_duration_seconds_bucket{le="+Inf"} 4821
http_request_duration_seconds_sum 312.4
http_request_duration_seconds_count 4821
```

Use for: request latency, response sizes. Enables percentile calculation in Prometheus (`histogram_quantile`).

#### Summary

Computes quantiles client-side over a sliding time window. Less flexible than histograms for aggregation across replicas.

**Key Points:**
- Histograms are preferred over Summaries in Kubernetes environments because histogram buckets can be aggregated across multiple Pod replicas in PromQL; Summary quantiles cannot [Inference]
- The bucket boundaries on a Histogram must be configured in advance — poorly chosen buckets lose precision where it matters most

---

### Installation

```bash
npm install @fastify/metrics prom-client
```

**Key Points:**
- `@fastify/metrics` is the official Fastify plugin; it wraps `prom-client`, the standard Node.js Prometheus client library
- `prom-client` is a peer dependency and must be installed explicitly
- Both packages should be pinned to compatible versions; check `@fastify/metrics` release notes for supported `prom-client` ranges [Unverified — verify current compatibility at time of installation]

---

### Basic Registration

**Example — `plugins/metrics.js`:**

```js
import fp from 'fastify-plugin'
import metricsPlugin from '@fastify/metrics'

export default fp(async function metrics(app, opts) {
  await app.register(metricsPlugin, {
    endpoint: '/metrics',
    routeMetrics: {
      enabled: true,
      registeredRoutesOnly: false,
      groupStatusCodes: false,
      methodBlacklist: ['OPTIONS'],
    },
    defaultMetrics: {
      enabled: true,
      prefix: 'nodejs_',
    },
  })
}, {
  name: 'metrics-plugin',
})
```

**Example — `server.js`:**

```js
import Fastify from 'fastify'
import metricsPlugin from './plugins/metrics.js'
import healthPlugin from './plugins/health.js'
import routes from './routes/index.js'

const app = Fastify({ logger: true })

await app.register(metricsPlugin)
await app.register(healthPlugin)
await app.register(routes)

await app.listen({ port: 3000, host: '0.0.0.0' })
```

**Output — scraping `/metrics`:**

```
# HELP http_request_duration_seconds request duration in seconds
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.005",method="GET",route="/users",status_code="200"} 120
http_request_duration_seconds_bucket{le="0.01",method="GET",route="/users",status_code="200"} 340
...
http_request_duration_seconds_sum{method="GET",route="/users",status_code="200"} 18.43
http_request_duration_seconds_count{method="GET",route="/users",status_code="200"} 540

# HELP nodejs_heap_size_used_bytes Process heap size used from Node.js in bytes
# TYPE nodejs_heap_size_used_bytes gauge
nodejs_heap_size_used_bytes 52428800
```

**Key Points:**
- Registering `metricsPlugin` with `fp` (via `fastify-plugin`) exposes `app.metrics` across the full plugin tree, not just within the plugin's scope
- `registeredRoutesOnly: false` includes metrics for unmatched routes (404s) under a catch-all label — useful for detecting scanning traffic [Inference]
- `groupStatusCodes: false` creates a label value per exact status code (`200`, `404`, `500`); `true` groups into `2xx`, `4xx`, `5xx` — grouping reduces cardinality but loses granularity
- `methodBlacklist` suppresses metrics for specified HTTP methods; OPTIONS is commonly excluded as it generates preflight traffic that skews request counts

---

### Default Metrics

`prom-client`'s default metrics collection covers the Node.js runtime automatically when `defaultMetrics.enabled` is `true`.

| Metric | Type | Description |
|---|---|---|
| `nodejs_heap_size_total_bytes` | Gauge | Total V8 heap allocated |
| `nodejs_heap_size_used_bytes` | Gauge | V8 heap currently in use |
| `nodejs_external_memory_bytes` | Gauge | Memory used by C++ objects bound to JS |
| `nodejs_heap_space_size_*` | Gauge | Per-space heap metrics (new, old, code, etc.) |
| `nodejs_gc_duration_seconds` | Histogram | GC pause duration by GC type |
| `nodejs_eventloop_lag_seconds` | Gauge | Current event loop lag |
| `nodejs_eventloop_lag_p50_seconds` | Gauge | Event loop lag percentiles |
| `nodejs_active_handles_total` | Gauge | Active libuv handles |
| `nodejs_active_requests_total` | Gauge | Active libuv requests |
| `process_cpu_seconds_total` | Counter | CPU time consumed |
| `process_resident_memory_bytes` | Gauge | RSS memory usage |
| `process_start_time_seconds` | Gauge | Unix timestamp of process start |

**Key Points:**
- `nodejs_gc_duration_seconds` broken down by `kind` label (`major`, `minor`, `incremental`) reveals GC pressure patterns — frequent major GCs indicate memory pressure [Inference]
- `nodejs_eventloop_lag_seconds` is a critical signal for Fastify performance — event loop lag above 100ms suggests CPU-bound work blocking the loop [Inference]
- Default metrics are collected on a timer interval (default 10 seconds in `prom-client`) — they reflect snapshots, not instantaneous values

---

### Route Metrics

`@fastify/metrics` automatically instruments every registered Fastify route using the `onResponse` hook.

**Metrics produced per route:**

| Metric | Type | Labels |
|---|---|---|
| `http_request_duration_seconds` | Histogram | `method`, `route`, `status_code` |
| `http_requests_total` | Counter | `method`, `route`, `status_code` |
| `http_request_summary_seconds` | Summary | `method`, `route`, `status_code` |

**Key Points:**
- The `route` label uses the Fastify route pattern (`/users/:id`), not the actual request URL — this is critical for cardinality control; using the raw URL would create one time series per unique user ID [Inference]
- `http_request_summary_seconds` computes quantiles client-side; in multi-replica deployments prefer `histogram_quantile` over the summary's quantile labels for accurate aggregated percentiles
- Routes excluded from metrics (e.g., `/metrics` itself, `/healthz`) should be explicitly blacklisted to avoid polluting latency histograms with probe traffic

**Example — excluding health and metrics routes:**

```js
await app.register(metricsPlugin, {
  endpoint: '/metrics',
  routeMetrics: {
    routeBlacklist: ['/healthz', '/readyz', '/livez', '/metrics'],
  },
})
```

---

### Custom Metrics

Application-level business metrics require manual instrumentation using `prom-client` directly.

**Example — `plugins/appMetrics.js`:**

```js
import fp from 'fastify-plugin'
import { Counter, Histogram, Gauge, register } from 'prom-client'

export default fp(async function appMetrics(app) {
  // Counter — total user registrations
  const userRegistrations = new Counter({
    name: 'app_user_registrations_total',
    help: 'Total number of user registrations',
    labelNames: ['plan'],  // 'free', 'pro', 'enterprise'
  })

  // Histogram — external API call latency
  const externalApiDuration = new Histogram({
    name: 'app_external_api_duration_seconds',
    help: 'Duration of external API calls in seconds',
    labelNames: ['service', 'method', 'status'],
    buckets: [0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
  })

  // Gauge — current queue depth
  const queueDepth = new Gauge({
    name: 'app_job_queue_depth',
    help: 'Current number of jobs pending in the queue',
    labelNames: ['queue_name'],
  })

  // Gauge — active WebSocket connections
  const activeConnections = new Gauge({
    name: 'app_websocket_connections_active',
    help: 'Number of active WebSocket connections',
  })

  // Decorate app so all plugins and routes can access these
  app.decorate('metrics', {
    userRegistrations,
    externalApiDuration,
    queueDepth,
    activeConnections,
  })
}, {
  name: 'app-metrics-plugin',
})
```

**Example — using custom metrics in a route:**

```js
// routes/auth.js
export default async function authRoutes(app) {
  app.post('/register', async (req, reply) => {
    const user = await createUser(req.body)

    // Increment registration counter with plan label
    app.metrics.userRegistrations.inc({ plan: req.body.plan ?? 'free' })

    return reply.code(201).send(user)
  })
}
```

**Example — timing an external call:**

```js
async function callPaymentService(payload) {
  const end = app.metrics.externalApiDuration.startTimer({
    service: 'stripe',
    method: 'createCharge',
  })

  try {
    const result = await stripeClient.charges.create(payload)
    end({ status: 'success' })
    return result
  } catch (err) {
    end({ status: 'error' })
    throw err
  }
}
```

**Key Points:**
- `startTimer()` returns a function that, when called, records the elapsed duration and accepts additional labels — a clean pattern for timing async operations
- Decorating `app.metrics` via `fastify-plugin` makes all custom metrics accessible across the full plugin tree without importing `prom-client` in every file
- Custom metric names should follow Prometheus naming conventions: `<namespace>_<subsystem>_<name>_<unit>` — the unit suffix (`_total`, `_seconds`, `_bytes`) is mandatory for clarity and tooling compatibility [Inference — Prometheus documentation recommends but does not enforce naming conventions]
- Every Counter name should end in `_total` per Prometheus conventions

---

### Cardinality Management

Cardinality is the number of unique time series a metric produces. High cardinality is the primary operational risk in Prometheus deployments — it causes memory exhaustion in the Prometheus server and query performance degradation.

**Cardinality formula:**

```
time_series_count = PRODUCT of unique_values_per_label
```

**Example — cardinality explosion:**

```js
// DANGEROUS — user ID in label creates one series per user
const requestsByUser = new Counter({
  name: 'app_requests_total',
  labelNames: ['route', 'user_id'],  // user_id can be millions of values
})

// CORRECT — aggregate at a higher level
const requestsByPlan = new Counter({
  name: 'app_requests_total',
  labelNames: ['route', 'plan'],  // plan has 3 values: free, pro, enterprise
})
```

**High-cardinality label values to avoid:**

| Label | Why dangerous |
|---|---|
| `user_id` | Unbounded — one value per user |
| `request_id` / `trace_id` | Unique per request |
| Raw URL path | Contains IDs, query strings |
| IP address | Unbounded |
| Full error message | Highly variable strings |

**Safe label values:**

| Label | Why safe |
|---|---|
| `method` | Fixed set: GET, POST, PUT, DELETE, PATCH |
| `status_code` (grouped) | Fixed set: 2xx, 4xx, 5xx |
| `route` (Fastify pattern) | Fixed set: one per registered route |
| `plan` / `tier` | Small enum |
| `region` | Small enum |
| `error_type` | Controlled vocabulary |

**Key Points:**
- A Prometheus server with millions of active time series can experience severe memory pressure — cardinality management is a production concern from day one [Inference]
- `@fastify/metrics` uses Fastify's route pattern as the `route` label precisely to avoid this problem — a route like `/users/:id` is a single label value regardless of how many unique IDs are requested
- Prometheus's `--storage.tsdb.retention.time` and `--query.max-samples` flags can partially mitigate cardinality issues but do not substitute for correct label design [Inference]

---

### Histogram Bucket Configuration

Default histogram buckets in `prom-client` are designed for general HTTP latency. Customizing them improves resolution where it matters for your application.

**Default buckets:**

```js
[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]
```

**Example — overriding route metric buckets:**

```js
await app.register(metricsPlugin, {
  endpoint: '/metrics',
  routeMetrics: {
    overrides: {
      histogram: {
        name: 'http_request_duration_seconds',
        buckets: [0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1],
      },
    },
  },
})
```

**Key Points:**
- Buckets should bracket the observed p50, p95, and p99 latencies — if p99 is 80ms, buckets above 250ms add no resolution and waste storage [Inference]
- For internal microservices with sub-10ms latency targets, shift buckets left: `[0.001, 0.002, 0.005, 0.01, 0.025, 0.05, 0.1]`
- For services calling external APIs (payments, email), shift buckets right: `[0.1, 0.25, 0.5, 1, 2.5, 5, 10, 30]`
- Bucket boundaries cannot be changed after metrics are registered without restarting the process and losing accumulated data [Inference]

---

### Securing the `/metrics` Endpoint

The `/metrics` endpoint exposes internal application state and must not be publicly accessible.

**Option 1 — Separate internal port:**

```js
import Fastify from 'fastify'
import metricsPlugin from '@fastify/metrics'
import { register } from 'prom-client'

const app = Fastify({ logger: true })
// ... business routes, no metrics endpoint here

// Internal-only metrics server
const metricsApp = Fastify({ logger: false })

metricsApp.get('/metrics', async (req, reply) => {
  reply.header('content-type', register.contentType)
  return register.metrics()
})

await metricsApp.listen({ port: 9091, host: '127.0.0.1' })
await app.listen({ port: 3000, host: '0.0.0.0' })
```

**Option 2 — Bearer token authentication:**

```js
await app.register(metricsPlugin, { endpoint: null }) // disable auto endpoint

app.get('/metrics', {
  onRequest: async (req, reply) => {
    const token = req.headers['authorization']?.replace('Bearer ', '')
    if (token !== app.config.METRICS_TOKEN) {
      return reply.code(401).send({ error: 'Unauthorized' })
    }
  },
}, async (req, reply) => {
  reply.header('content-type', app.metrics.client.register.contentType)
  return app.metrics.client.register.metrics()
})
```

**Kubernetes ServiceMonitor with separate port:**

```yaml
# In the Deployment
ports:
  - name: http
    containerPort: 3000
  - name: metrics
    containerPort: 9091

# ServiceMonitor for Prometheus Operator
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: fastify-app
spec:
  selector:
    matchLabels:
      app: fastify-app
  endpoints:
    - port: metrics
      path: /metrics
      interval: 15s
```

**Key Points:**
- Exposing `/metrics` on a separate port bound to `127.0.0.1` prevents external access without any authentication layer — the simplest and most robust option for Kubernetes deployments
- The Prometheus Operator's `ServiceMonitor` CRD is the standard declarative way to configure scrape targets in Kubernetes; it eliminates manual Prometheus configuration [Inference — requires Prometheus Operator to be installed in the cluster]
- Bearer token auth is appropriate when a separate port is not feasible; rotate the token via Kubernetes Secrets and mount it as an environment variable

---

### Useful PromQL Queries

Once metrics are being scraped, the following PromQL expressions cover the most common operational questions.

**Request rate (per second over 5 minutes):**

```promql
rate(http_requests_total{app="fastify-app"}[5m])
```

**Error rate (5xx as fraction of total):**

```promql
sum(rate(http_requests_total{status_code=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

**p99 latency per route:**

```promql
histogram_quantile(
  0.99,
  sum by (route, le) (
    rate(http_request_duration_seconds_bucket[5m])
  )
)
```

**Event loop lag (current):**

```promql
nodejs_eventloop_lag_seconds{app="fastify-app"}
```

**Heap usage as percentage of limit:**

```promql
nodejs_heap_size_used_bytes / nodejs_heap_size_total_bytes * 100
```

**Active request concurrency:**

```promql
sum(nodejs_active_requests_total{app="fastify-app"})
```

**Key Points:**
- `histogram_quantile` requires `rate()` over a time window rather than raw bucket values — computing quantiles on cumulative counters without `rate()` produces incorrect results [Inference]
- Summing by `le` before passing to `histogram_quantile` is required for correct cross-replica aggregation
- Alert thresholds should be calibrated against observed baselines, not assumed values — collect at least a week of production data before setting p99 SLO alerts [Inference]

---

### Metrics Architecture Diagram

<svg viewBox="0 0 760 460" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="760" height="460" fill="#0f1117" rx="12"/>
  <text x="380" y="32" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Prometheus Metrics Pipeline: Fastify → Grafana</text>

  <!-- Fastify Pod -->
  <rect x="30" y="60" width="220" height="280" rx="10" fill="#0f172a" stroke="#334155" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="140" y="83" text-anchor="middle" fill="#64748b" font-size="11">Fastify Pod</text>

  <rect x="50" y="95" width="180" height="36" rx="6" fill="#14291f" stroke="#4ade80" stroke-width="1.2"/>
  <text x="140" y="110" text-anchor="middle" fill="#4ade80">Route Hooks</text>
  <text x="140" y="124" text-anchor="middle" fill="#94a3b8" font-size="10">onResponse instrumentation</text>

  <rect x="50" y="145" width="180" height="36" rx="6" fill="#1e1a2e" stroke="#c084fc" stroke-width="1.2"/>
  <text x="140" y="160" text-anchor="middle" fill="#c084fc">prom-client Registry</text>
  <text x="140" y="174" text-anchor="middle" fill="#94a3b8" font-size="10">in-memory metric state</text>

  <rect x="50" y="195" width="180" height="36" rx="6" fill="#1e2d40" stroke="#818cf8" stroke-width="1.2"/>
  <text x="140" y="210" text-anchor="middle" fill="#818cf8">Custom Metrics</text>
  <text x="140" y="224" text-anchor="middle" fill="#94a3b8" font-size="10">Counter / Histogram / Gauge</text>

  <rect x="50" y="245" width="180" height="36" rx="6" fill="#1e293b" stroke="#38bdf8" stroke-width="1.2"/>
  <text x="140" y="260" text-anchor="middle" fill="#38bdf8">Default Metrics</text>
  <text x="140" y="274" text-anchor="middle" fill="#94a3b8" font-size="10">heap / GC / event loop</text>

  <rect x="50" y="295" width="180" height="36" rx="6" fill="#291e1e" stroke="#f87171" stroke-width="1.2"/>
  <text x="140" y="310" text-anchor="middle" fill="#f87171">GET /metrics :9091</text>
  <text x="140" y="324" text-anchor="middle" fill="#94a3b8" font-size="10">Prometheus exposition format</text>

  <!-- Arrow: hooks → registry -->
  <line x1="140" y1="131" x2="140" y2="145" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="140" y1="181" x2="140" y2="195" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="140" y1="231" x2="140" y2="245" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="140" y1="281" x2="140" y2="295" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- Prometheus -->
  <rect x="310" y="140" width="180" height="80" rx="8" fill="#1e293b" stroke="#f97316" stroke-width="1.5"/>
  <text x="400" y="165" text-anchor="middle" fill="#f97316" font-weight="bold">Prometheus</text>
  <text x="400" y="183" text-anchor="middle" fill="#94a3b8" font-size="10">scrapes /metrics every 15s</text>
  <text x="400" y="198" text-anchor="middle" fill="#94a3b8" font-size="10">stores time series (TSDB)</text>

  <!-- Scrape arrow -->
  <line x1="310" y1="180" x2="230" y2="313" stroke="#f97316" stroke-width="1.5" stroke-dasharray="6,3" marker-end="url(#arrO)"/>
  <text x="248" y="248" fill="#f97316" font-size="10" transform="rotate(-32,248,248)">scrape</text>

  <!-- Alertmanager -->
  <rect x="310" y="280" width="180" height="60" rx="8" fill="#1e293b" stroke="#fb923c" stroke-width="1.3"/>
  <text x="400" y="305" text-anchor="middle" fill="#fb923c" font-weight="bold">Alertmanager</text>
  <text x="400" y="323" text-anchor="middle" fill="#94a3b8" font-size="10">routes firing alerts</text>

  <!-- Arrow Prometheus → Alertmanager -->
  <line x1="400" y1="220" x2="400" y2="280" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- Grafana -->
  <rect x="550" y="140" width="170" height="80" rx="8" fill="#1e293b" stroke="#34d399" stroke-width="1.5"/>
  <text x="635" y="165" text-anchor="middle" fill="#34d399" font-weight="bold">Grafana</text>
  <text x="635" y="183" text-anchor="middle" fill="#94a3b8" font-size="10">dashboards + PromQL</text>
  <text x="635" y="198" text-anchor="middle" fill="#94a3b8" font-size="10">SLO tracking</text>

  <!-- Arrow Prometheus → Grafana -->
  <line x1="490" y1="180" x2="550" y2="180" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- PagerDuty / Slack -->
  <rect x="550" y="280" width="170" height="60" rx="8" fill="#1e293b" stroke="#fb923c" stroke-width="1.3"/>
  <text x="635" y="305" text-anchor="middle" fill="#fb923c" font-weight="bold">PagerDuty / Slack</text>
  <text x="635" y="323" text-anchor="middle" fill="#94a3b8" font-size="10">on-call notifications</text>

  <!-- Arrow Alertmanager → Notification -->
  <line x1="490" y1="310" x2="550" y2="310" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- HPA -->
  <rect x="310" y="390" width="180" height="50" rx="8" fill="#1e293b" stroke="#818cf8" stroke-width="1.3"/>
  <text x="400" y="412" text-anchor="middle" fill="#818cf8" font-weight="bold">HPA / KEDA</text>
  <text x="400" y="428" text-anchor="middle" fill="#94a3b8" font-size="10">scale on custom metrics</text>

  <!-- Arrow Prometheus → HPA -->
  <line x1="400" y1="360" x2="400" y2="390" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- Defs -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
    <marker id="arrO" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f97316"/>
    </marker>
  </defs>
</svg>

---

### Metrics in Testing

Custom metrics accumulate across test runs if the `prom-client` default registry is not cleared between tests.

**Example — clearing the registry between tests:**

```js
import { register } from 'prom-client'
import { beforeEach, afterEach } from 'vitest'
import { buildApp } from '../src/app.js'

let app

beforeEach(async () => {
  register.clear() // reset all metrics before each test
  app = buildApp()
  await app.ready()
})

afterEach(async () => {
  await app.close()
})
```

**Example — asserting on metric values:**

```js
import { test, expect } from 'vitest'
import { register } from 'prom-client'

test('increments registration counter on POST /register', async () => {
  await app.inject({
    method: 'POST',
    url: '/register',
    payload: { email: 'test@example.com', plan: 'pro' },
  })

  const metric = await register.getSingleMetric('app_user_registrations_total')
  const values = await metric.get()

  const proCount = values.values.find(v => v.labels.plan === 'pro')
  expect(proCount.value).toBe(1)
})
```

**Key Points:**
- `register.clear()` in `beforeEach` prevents counter values from carrying across test cases — without it, accumulated values from earlier tests corrupt assertions in later ones
- `register.getSingleMetric(name)` returns the metric object; `.get()` returns the current values and labels
- For integration tests that spin up multiple Fastify instances, use a fresh `Registry` instance per app rather than the global default registry to avoid cross-instance metric collision [Inference]

---

### Production Configuration Checklist

| Concern | Recommendation |
|---|---|
| Endpoint security | Bind `/metrics` to internal port `127.0.0.1:9091` |
| Scrape interval | 15s default; 30s for lower-volume services |
| Histogram buckets | Calibrate to observed latency distribution |
| Label cardinality | Never use unbounded values (IDs, URLs, IPs) |
| Health route exclusion | Blacklist `/healthz`, `/readyz`, `/metrics` from route metrics |
| Default metrics prefix | Use a service-specific prefix to disambiguate in multi-service deployments |
| Registry isolation in tests | Call `register.clear()` in `beforeEach` |
| `groupStatusCodes` | `false` for granularity; `true` if time series count is a concern |
| Retention | Align Prometheus `--storage.tsdb.retention.time` with alerting lookback windows |

---

**Related Topics:**
- Grafana dashboard templates for Node.js and Fastify (community dashboards on grafana.com)
- Prometheus Operator and `ServiceMonitor` CRD for Kubernetes-native scrape configuration
- KEDA (Kubernetes Event-Driven Autoscaling) scaling Fastify Deployments on custom Prometheus metrics
- OpenTelemetry SDK as a unified metrics, traces, and logs API replacing direct `prom-client` usage
- `@fastify/otel` for OpenTelemetry-native instrumentation
- Distributed tracing with Jaeger and trace-to-metrics correlation
- SLO alerting with `sloth` or Pyrra for error budget tracking