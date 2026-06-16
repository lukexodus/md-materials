## Metrics and Dashboards

Metrics provide aggregate, time-series views of system behavior — distinct from traces (single-request detail) and errors (individual failures). For tRPC, the primary metric sources are procedure invocation counts, latency distributions, error rates, and infrastructure-level signals from the underlying HTTP server.

---

### Metric Types

Understanding the four fundamental metric types determines which to use for each measurement:

| Type | Description | tRPC Use Case |
|---|---|---|
| **Counter** | Monotonically increasing integer | Total procedure invocations, total errors |
| **Histogram** | Distribution of values across configurable buckets | Procedure latency, payload size |
| **Gauge** | Point-in-time value, can go up or down | Active subscriptions, connection pool size |
| **Summary** | Pre-computed quantiles (less flexible than histogram) | Avoid — histograms are preferable for aggregation across instances |

> [Inference] Summaries cannot be aggregated across multiple server instances because quantiles are not composable. Histograms can be aggregated and are the standard choice for latency in multi-instance deployments.

---

### Instrumentation Layer Options

Three practical options exist for exposing metrics from a tRPC server:

**Prometheus + `prom-client`** — pull-based; a Prometheus server scrapes an `/metrics` endpoint. Dominant in Kubernetes and self-hosted environments.

**OpenTelemetry Metrics SDK** — push or pull; vendor-neutral. Covered in the OpenTelemetry section. Preferred when an OTel Collector is already deployed.

**Datadog / statsd** — push-based UDP; used in Datadog-centric infrastructure.

This section focuses on `prom-client` (Prometheus) as the most common self-hosted option, with OTel Metrics as the secondary path.

---

### Installation

```bash
npm install prom-client
```

---

### Metric Definitions

Define metrics in a shared module. Importing this module registers metrics with the default Prometheus registry.

```ts
// src/lib/metrics.ts
import {
  Counter,
  Histogram,
  Gauge,
  Registry,
  collectDefaultMetrics,
} from 'prom-client';

export const registry = new Registry();

// Collect Node.js default metrics: event loop lag, heap, GC, etc.
collectDefaultMetrics({ register: registry });

export const procedureInvocations = new Counter({
  name: 'trpc_procedure_invocations_total',
  help: 'Total number of tRPC procedure invocations',
  labelNames: ['path', 'type', 'status'] as const,
  registers: [registry],
});

export const procedureDuration = new Histogram({
  name: 'trpc_procedure_duration_seconds',
  help: 'tRPC procedure execution duration in seconds',
  labelNames: ['path', 'type', 'status'] as const,
  // Buckets in seconds — tune to your expected latency range
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
  registers: [registry],
});

export const procedureErrors = new Counter({
  name: 'trpc_procedure_errors_total',
  help: 'Total number of tRPC procedure errors by error code',
  labelNames: ['path', 'type', 'error_code'] as const,
  registers: [registry],
});

export const activeSubscriptions = new Gauge({
  name: 'trpc_active_subscriptions',
  help: 'Number of currently active tRPC subscriptions',
  labelNames: ['path'] as const,
  registers: [registry],
});
```

**Key Points:**
- Use a dedicated `Registry` instance rather than the global default to avoid conflicts when running multiple registries in tests or monorepo setups
- Bucket selection is critical for histograms — too coarse loses resolution; too fine wastes memory. Start with the defaults above and adjust based on observed p99
- `collectDefaultMetrics` adds ~30 Node.js runtime metrics including heap usage, GC pause time, and event loop lag — these are useful for diagnosing server-level issues alongside procedure metrics

---

### tRPC Middleware for Metrics

```ts
// src/trpc/middleware/metrics.ts
import { middleware } from '../trpc';
import { TRPCError } from '@trpc/server';
import {
  procedureInvocations,
  procedureDuration,
  procedureErrors,
} from '../../lib/metrics';

export const metricsMiddleware = middleware(async ({ path, type, next }) => {
  const stopTimer = procedureDuration.startTimer({ path, type });

  try {
    const result = await next();
    stopTimer({ status: 'success' });
    procedureInvocations.inc({ path, type, status: 'success' });
    return result;
  } catch (error) {
    const errorCode = error instanceof TRPCError
      ? error.code
      : 'INTERNAL_SERVER_ERROR';

    stopTimer({ status: 'error' });
    procedureInvocations.inc({ path, type, status: 'error' });
    procedureErrors.inc({ path, type, error_code: errorCode });

    throw error;
  }
});
```

`Histogram.startTimer()` returns a function that, when called, records the elapsed duration since `startTimer()` was invoked. Labels passed to `startTimer` (constant labels like `path`, `type`) are combined with labels passed to the returned function (variable labels like `status`).

---

### Exposing the `/metrics` Endpoint

Prometheus scrapes metrics via HTTP. Add a dedicated route outside the tRPC router:

```ts
// src/server.ts (Express example)
import express from 'express';
import { registry } from './lib/metrics';
import { createExpressMiddleware } from '@trpc/server/adapters/express';
import { appRouter } from './trpc/router';
import { createContext } from './trpc/context';

const app = express();

// tRPC handler
app.use('/trpc', createExpressMiddleware({ router: appRouter, createContext }));

// Prometheus metrics endpoint — restrict access in production
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', registry.contentType);
  res.end(await registry.metrics());
});

app.listen(3000);
```

> [Inference] The `/metrics` endpoint should not be publicly accessible. Options for restricting it include: binding it to a separate internal port, using network-level access controls (Kubernetes NetworkPolicy, security groups), or adding a shared-secret middleware check. Behavior of any specific approach depends on your deployment environment.

---

### Subscription Metrics

Subscriptions require explicit gauge management — there is no automatic entry/exit detection:

```ts
// src/trpc/routers/events.ts
import { activeSubscriptions } from '../../lib/metrics';
import { observable } from '@trpc/server/observable';

export const eventsRouter = router({
  onUpdate: publicProcedure
    .input(z.object({ channel: z.string() }))
    .subscription(({ input }) => {
      return observable<UpdateEvent>((emit) => {
        activeSubscriptions.inc({ path: 'events.onUpdate' });

        const handler = (event: UpdateEvent) => emit.next(event);
        eventBus.on(input.channel, handler);

        return () => {
          activeSubscriptions.dec({ path: 'events.onUpdate' });
          eventBus.off(input.channel, handler);
        };
      });
    }),
});
```

The cleanup function returned from the observable is called when the subscription terminates (client disconnect, server-side close). Decrementing in the cleanup function keeps the gauge accurate across normal and abnormal disconnections.

---

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'trpc-server'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/metrics'
    scrape_interval: 10s
```

For Kubernetes, use a `ServiceMonitor` (Prometheus Operator) instead of static config:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: trpc-server
spec:
  selector:
    matchLabels:
      app: trpc-server
  endpoints:
    - port: http
      path: /metrics
      interval: 10s
```

---

### Key PromQL Queries

PromQL is the query language for Prometheus and Grafana. The following queries cover the primary tRPC observability use cases.

**Request rate (per-procedure, per second, 5-minute window):**

```promql
rate(trpc_procedure_invocations_total[5m])
```

**Error rate as a fraction of total invocations:**

```promql
rate(trpc_procedure_errors_total[5m])
/
rate(trpc_procedure_invocations_total[5m])
```

**p50, p95, p99 latency per procedure:**

```promql
histogram_quantile(0.95,
  sum by (path, le) (
    rate(trpc_procedure_duration_seconds_bucket[5m])
  )
)
```

**Top 5 slowest procedures by p99:**

```promql
topk(5,
  histogram_quantile(0.99,
    sum by (path, le) (
      rate(trpc_procedure_duration_seconds_bucket[5m])
    )
  )
)
```

**Active subscriptions:**

```promql
trpc_active_subscriptions
```

**Node.js event loop lag (from `collectDefaultMetrics`):**

```promql
nodejs_eventloop_lag_seconds
```

---

### Grafana Dashboard Structure

A practical tRPC Grafana dashboard organizes panels into three rows:

**Row 1 — Traffic Overview**

- Total RPS across all procedures (stat panel)
- RPS broken down by procedure path (time series)
- Error rate % (gauge or stat with threshold coloring)
- Active subscriptions (stat)

**Row 2 — Latency**

- p50 / p95 / p99 latency per procedure (time series, multi-line)
- Latency heatmap (`trpc_procedure_duration_seconds_bucket`) — shows distribution shape over time
- Slowest procedures table (table panel, sorted by p99)

**Row 3 — Errors**

- Error rate by procedure (time series)
- Error breakdown by `error_code` label (bar chart)
- Error count over time (time series)

**Row 4 — Runtime Health**

- Heap used / heap total (time series)
- GC pause duration (time series)
- Event loop lag (time series)
- CPU usage (time series)

---

### Grafana Dashboard as Code

Grafana dashboards can be version-controlled as JSON. A minimal panel definition for p95 latency:

```json
{
  "title": "p95 Latency by Procedure",
  "type": "timeseries",
  "targets": [
    {
      "expr": "histogram_quantile(0.95, sum by (path, le) (rate(trpc_procedure_duration_seconds_bucket[5m])))",
      "legendFormat": "{{path}}"
    }
  ],
  "fieldConfig": {
    "defaults": {
      "unit": "s",
      "thresholds": {
        "steps": [
          { "color": "green", "value": null },
          { "color": "yellow", "value": 0.5 },
          { "color": "red", "value": 1.0 }
        ]
      }
    }
  }
}
```

For structured dashboard management, use Grafonnet (Jsonnet library) or Terraform's Grafana provider.

---

### Alerting Rules

Prometheus alerting rules define conditions that fire when metrics cross thresholds. Rules live in a YAML file loaded by Prometheus or the Alertmanager.

```yaml
# alerts/trpc.yml
groups:
  - name: trpc
    rules:
      - alert: HighErrorRate
        expr: |
          (
            rate(trpc_procedure_errors_total[5m])
            /
            rate(trpc_procedure_invocations_total[5m])
          ) > 0.05
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High tRPC error rate on {{ $labels.path }}"
          description: "Error rate is {{ $value | humanizePercentage }} over the last 5 minutes."

      - alert: HighLatencyP99
        expr: |
          histogram_quantile(0.99,
            sum by (path, le) (
              rate(trpc_procedure_duration_seconds_bucket[5m])
            )
          ) > 1.0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "p99 latency above 1s for {{ $labels.path }}"

      - alert: TRPCServerDown
        expr: up{job="trpc-server"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "tRPC server is unreachable"
```

The `for` clause prevents flapping — the condition must hold continuously for the specified duration before the alert fires.

---

### SLO-Based Alerting

Service Level Objectives define a reliability target (e.g., 99.5% of requests succeed, p99 latency < 500ms). Alerting on SLO burn rate is more actionable than raw threshold alerts.

**Error budget burn rate alert (fast burn):**

```promql
# Fires if the error budget is being consumed 14x faster than sustainable
(
  rate(trpc_procedure_errors_total[1h])
  /
  rate(trpc_procedure_invocations_total[1h])
) > 14 * (1 - 0.995)
```

> [Inference] SLO burn rate alerting (as described in the Google SRE workbook) requires careful calibration of the burn rate multiplier and window lengths. The values above are illustrative starting points, not universal recommendations.

---

### OTel Metrics Path

If OTel is the primary instrumentation layer, the metric definitions from the OpenTelemetry section apply. Export to Prometheus via the OTel Prometheus exporter:

```ts
// src/instrumentation.ts
import { PrometheusExporter } from '@opentelemetry/exporter-prometheus';
import { MeterProvider } from '@opentelemetry/sdk-metrics';

const exporter = new PrometheusExporter({ port: 9464 });

const meterProvider = new MeterProvider({
  readers: [exporter],
});

// OTel metrics are now available at http://localhost:9464/metrics
```

This approach produces an identical Prometheus scrape target. The same PromQL queries and Grafana panels apply regardless of whether `prom-client` or the OTel SDK generated the metrics.

> [Inference] Running both `prom-client` and the OTel Metrics SDK simultaneously on the same registry may produce duplicate metric names. Use one or the other as the primary metric collection layer. Behavior depends on configuration.

---

### Label Cardinality

High-cardinality labels cause memory and performance problems in Prometheus. Common mistakes in tRPC instrumentation:

| Label | Safe? | Reason |
|---|---|---|
| `path` (procedure name) | Yes | Low cardinality — finite set of procedures |
| `type` (query/mutation/subscription) | Yes | 3 values |
| `status` (success/error) | Yes | 2 values |
| `error_code` | Yes | ~15 tRPC error codes |
| `user_id` | **No** | Unbounded — one label value per user |
| `input` values | **No** | Unbounded |
| `trace_id` | **No** | Unbounded |

> Unbounded label values cause the Prometheus time series database to grow without limit, degrading query performance and increasing memory usage. Trace IDs and user IDs belong in traces and logs, not metrics.

---

### Summary

| Component | Role |
|---|---|
| `prom-client` / OTel Metrics | Metric collection and registration |
| `metricsMiddleware` | Per-procedure invocation, latency, error recording |
| `/metrics` endpoint | Prometheus scrape target |
| Prometheus | Time-series storage and alerting |
| Grafana | Visualization and dashboard |
| PromQL | Query language for aggregation and alerting |
| Alertmanager | Alert routing to Slack, PagerDuty, etc. |

**Next Steps:**
- Implement multi-window burn rate alerting (1h + 6h) for more robust SLO alerting with reduced false positives
- Add a Grafana annotation whenever a new release is deployed — correlates latency or error rate changes to specific code changes on the dashboard
- Explore Grafana Tempo integration to jump directly from a high-latency histogram bucket in Grafana to representative traces via exemplars