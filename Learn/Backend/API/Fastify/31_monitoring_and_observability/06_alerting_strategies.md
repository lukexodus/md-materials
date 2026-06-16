## Alerting Strategies for Fastify

Alerting bridges observability data — metrics, logs, traces, errors — and human response. Effective alerting pages the right person at the right time with enough context to act. Poorly designed alerting creates noise, alert fatigue, and missed incidents. This topic covers alert design principles, signal sources, tooling, and Fastify-specific patterns.

---

### Core Alerting Principles

#### Alert on Symptoms, Not Causes
Alert on what users experience — high error rate, slow responses, unavailability — not on internal indicators like CPU usage or memory pressure. Internal metrics are useful for dashboards and diagnosis, but rarely justify waking someone up on their own.

| Symptom alert (preferred) | Cause alert (avoid as primary) |
|---|---|
| Error rate > 5% for 5 min | CPU > 80% |
| P99 latency > 2s | Heap memory > 85% |
| Service unavailable | Event loop lag > 100ms |
| Successful request rate drops 20% | GC pause duration high |

Cause-based metrics belong in dashboards and runbooks as diagnostic aids, not as primary alerting signals. [Inference]

#### The Four Golden Signals
Derived from Google's SRE practice, these four signals cover the space of user-visible service health:

- **Latency** — How long requests take, including error latency separately
- **Traffic** — Request rate; volume of demand on the system
- **Errors** — Rate of failed requests (explicit 5xx, implicit wrong results)
- **Saturation** — How full the service is; utilization of the most constrained resource

Build at least one alert per golden signal for each critical Fastify service.

#### Alert Fatigue
Alerts that fire too often — even correctly — train responders to ignore them. Every alert should be:

- **Actionable** — There is a clear response action
- **Urgent** — The condition warrants interrupting someone now
- **Novel** — Not a known, accepted background condition

Non-urgent conditions belong in tickets, not pages.

---

### Alert Anatomy

Every alert should encode:

```
WHAT:        Which service, which signal
CONDITION:   The threshold and duration
SEVERITY:    How urgent is the response
CONTEXT:     Links to dashboard, runbook, recent deploys
ACTION:      What should the responder do first
```

**Example** — A well-formed alert notification:

```
[CRITICAL] fastify-order-service — High Error Rate
Environment: production
Condition:   Error rate 8.3% (threshold: 5%) for 4 minutes
Dashboard:   https://grafana.internal/d/fastify-overview?var-job=fastify-order-service
Runbook:     https://wiki.internal/runbooks/high-error-rate
Recent deploy: v2.14.1 deployed 12 minutes ago (suspect)
```

---

### Signal Sources for Fastify Alerts

#### Prometheus Metrics (via `@fastify/metrics` + `prom-client`)

The primary source for rate, latency, and saturation signals.

```
http_request_duration_seconds_count  — request rate, error rate
http_request_duration_seconds_bucket — latency percentiles
nodejs_eventloop_lag_seconds         — event loop saturation
nodejs_heap_used_bytes               — memory pressure
process_cpu_seconds_total            — CPU saturation
```

#### Loki Logs (via Pino structured logs)

Secondary signal — useful for error pattern detection and low-traffic services where metrics lack statistical significance.

#### Sentry

Issue-level alerting: new errors, regressions, error volume thresholds.

#### Uptime / Synthetic Checks

External probes that verify the service is reachable and returning correct responses — catches incidents invisible to internal metrics (network partitions, load balancer failures, DNS issues).

---

### Prometheus Alerting Rules

Prometheus evaluates alerting rules on a configurable interval and routes firing alerts to Alertmanager.

#### Full Alerting Rule File

```yaml
# alerts/fastify.yml
groups:
  - name: fastify-service-slos
    interval: 30s
    rules:

      # ── Availability ──────────────────────────────────────────

      - alert: FastifyHighErrorRate
        expr: |
          (
            sum(rate(http_request_duration_seconds_count{
              job="fastify-service",
              status_code=~"5.."
            }[5m]))
            /
            sum(rate(http_request_duration_seconds_count{
              job="fastify-service"
            }[5m]))
          ) > 0.05
        for: 2m
        labels:
          severity: critical
          team: backend
        annotations:
          summary: "High error rate on {{ $labels.job }}"
          description: >
            Error rate is {{ $value | humanizePercentage }} over the last 5 minutes.
            Threshold: 5%.
          dashboard: "https://grafana.internal/d/fastify?var-job={{ $labels.job }}"
          runbook: "https://wiki.internal/runbooks/high-error-rate"

      - alert: FastifyRouteErrorSpike
        expr: |
          sum by (route, method) (
            rate(http_request_duration_seconds_count{
              job="fastify-service",
              status_code=~"5.."
            }[5m])
          ) > 1
        for: 3m
        labels:
          severity: warning
          team: backend
        annotations:
          summary: "Error spike on {{ $labels.method }} {{ $labels.route }}"
          description: >
            Route {{ $labels.method }} {{ $labels.route }} is producing
            {{ $value | humanize }} errors/sec.

      # ── Latency ───────────────────────────────────────────────

      - alert: FastifyHighP99Latency
        expr: |
          histogram_quantile(0.99,
            sum by (le, route) (
              rate(http_request_duration_seconds_bucket{
                job="fastify-service"
              }[5m])
            )
          ) > 2.0
        for: 5m
        labels:
          severity: warning
          team: backend
        annotations:
          summary: "P99 latency above 2s on {{ $labels.route }}"
          description: >
            P99 latency for {{ $labels.route }} is
            {{ $value | humanizeDuration }} over the last 5 minutes.

      - alert: FastifyHighP50Latency
        expr: |
          histogram_quantile(0.50,
            sum by (le) (
              rate(http_request_duration_seconds_bucket{
                job="fastify-service"
              }[5m])
            )
          ) > 0.5
        for: 5m
        labels:
          severity: warning
          team: backend
        annotations:
          summary: "Median latency above 500ms on fastify-service"

      # ── Traffic ───────────────────────────────────────────────

      - alert: FastifyTrafficDrop
        expr: |
          (
            sum(rate(http_request_duration_seconds_count{job="fastify-service"}[5m]))
            /
            sum(rate(http_request_duration_seconds_count{job="fastify-service"}[5m] offset 1h))
          ) < 0.5
        for: 5m
        labels:
          severity: critical
          team: backend
        annotations:
          summary: "Traffic dropped more than 50% compared to 1 hour ago"
          description: >
            Current request rate is less than 50% of the rate from 1 hour ago.
            Possible upstream failure, load balancer issue, or service crash.

      # ── Saturation ────────────────────────────────────────────

      - alert: FastifyEventLoopLag
        expr: nodejs_eventloop_lag_seconds{job="fastify-service"} > 0.1
        for: 2m
        labels:
          severity: warning
          team: backend
        annotations:
          summary: "Node.js event loop lag above 100ms"
          description: >
            Event loop lag is {{ $value | humanizeDuration }}.
            Possible CPU-bound work, synchronous blocking, or GC pressure.

      - alert: FastifyHeapMemoryPressure
        expr: |
          (
            nodejs_heap_used_bytes{job="fastify-service"}
            /
            nodejs_heap_size_total_bytes{job="fastify-service"}
          ) > 0.90
        for: 5m
        labels:
          severity: warning
          team: backend
        annotations:
          summary: "Heap memory usage above 90%"
          description: >
            Heap utilization is {{ $value | humanizePercentage }}.
            Risk of OOM crash or GC thrashing if sustained.

      - alert: FastifyProcessRestart
        expr: |
          changes(process_start_time_seconds{job="fastify-service"}[15m]) > 0
        labels:
          severity: warning
          team: backend
        annotations:
          summary: "Fastify process restarted in the last 15 minutes"
          description: >
            The process restart may indicate an unhandled exception crash,
            OOM kill, or deliberate deployment. Verify recent deploy history.

      # ── Availability (uptime) ─────────────────────────────────

      - alert: FastifyServiceDown
        expr: up{job="fastify-service"} == 0
        for: 1m
        labels:
          severity: critical
          team: backend
        annotations:
          summary: "Fastify service is unreachable by Prometheus"
          description: >
            Prometheus cannot scrape {{ $labels.instance }}.
            The process may be down, the /metrics endpoint may be failing,
            or there is a network partition.
```

---

### Alertmanager Configuration

Alertmanager receives Prometheus alerts and handles routing, grouping, deduplication, and silencing.

```yaml
# alertmanager.yml
global:
  resolve_timeout: 5m
  slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'

route:
  receiver: default
  group_by: ['alertname', 'job', 'severity']
  group_wait: 30s        # wait before sending first notification in a group
  group_interval: 5m     # how long to wait before re-notifying on new alerts in a group
  repeat_interval: 4h    # how often to re-notify on ongoing alerts

  routes:
    # Critical alerts → PagerDuty immediately
    - match:
        severity: critical
      receiver: pagerduty-critical
      group_wait: 10s
      repeat_interval: 1h

    # Warning alerts → Slack only
    - match:
        severity: warning
      receiver: slack-warnings
      repeat_interval: 6h

    # Backend team routing
    - match:
        team: backend
      receiver: slack-backend

receivers:
  - name: default
    slack_configs:
      - channel: '#alerts-general'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

  - name: pagerduty-critical
    pagerduty_configs:
      - routing_key: '{{ env "PAGERDUTY_ROUTING_KEY" }}'
        description: '{{ .GroupLabels.alertname }}: {{ .CommonAnnotations.summary }}'
        details:
          dashboard: '{{ .CommonAnnotations.dashboard }}'
          runbook: '{{ .CommonAnnotations.runbook }}'

  - name: slack-warnings
    slack_configs:
      - channel: '#alerts-backend'
        color: 'warning'
        title: '[WARNING] {{ .GroupLabels.alertname }}'
        text: |
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
          *Dashboard:* {{ .CommonAnnotations.dashboard }}
          *Runbook:* {{ .CommonAnnotations.runbook }}

  - name: slack-backend
    slack_configs:
      - channel: '#backend-alerts'

inhibit_rules:
  # If the service is down, suppress latency and error alerts for the same job
  - source_match:
      alertname: FastifyServiceDown
    target_match_re:
      alertname: FastifyHighErrorRate|FastifyHighP99Latency
    equal: ['job']
```

**Key Points:**
- `group_by` prevents alert storms — multiple related alerts fire as one grouped notification.
- `inhibit_rules` suppress child alerts when a parent cause is already firing. A service-down alert should suppress latency and error alerts for the same service.
- `repeat_interval` controls ongoing alert fatigue — tune based on how often an unresolved alert needs re-attention.

---

### Loki-Based Log Alerting

For low-traffic services where metric-based rate calculations lack statistical reliability, log-based alerting on error patterns is more appropriate:

#### Grafana Alert Rule (LogQL)

```logql
# Count error log lines in the last 5 minutes
sum(count_over_time({service="fastify-service"} | json | level="error" [5m]))
```

Alert condition: value > 10 over 5 minutes.

#### Specific Error Pattern Alert

```logql
count_over_time(
  {service="fastify-service"}
    | json
    | msg =~ ".*database connection.*"
    | level = "error"
  [5m]
)
```

Alert condition: value > 0 — any database connection error in 5 minutes triggers.

---

### Sentry Alert Strategies

#### Issue Alerts

```
Trigger:   A new issue is created
Filter:    Issue level is error or fatal
Filter:    Environment is production
Action:    Notify Slack #backend-alerts
Action:    Assign to on-call user via PagerDuty
```

```
Trigger:   An issue changes state from resolved to unresolved (regression)
Action:    Notify Slack with [REGRESSION] prefix
Action:    Page on-call — regressions are high urgency
```

#### Metric Alerts

```
Metric:    Number of errors
Window:    10 minutes
Critical:  > 100 errors     → PagerDuty
Warning:   > 25 errors      → Slack
```

```
Metric:    Number of affected users
Window:    5 minutes
Critical:  > 50 users       → PagerDuty
```

**Key Points:**
- Sentry's "number of affected users" metric is a strong complement to error count — a bug affecting one user is different from one affecting thousands.
- Use Sentry's `ignoreErrors` and `beforeSend` (covered in the Sentry topic) to reduce noise before it reaches the alerting layer.

---

### SLO-Based Alerting

Service Level Objectives express reliability as a target (e.g., 99.9% of requests succeed within 500ms over 30 days). Alerting on **error budget burn rate** is more precise than fixed thresholds — it fires earlier when an incident will exhaust the monthly budget and stays quiet for minor blips.

#### Error Budget Concept

```
SLO target:       99.5% success rate over 30 days
Error budget:     0.5% of requests may fail = ~216 minutes of downtime
Current burn:     If error rate is 5% now, budget burns 10× faster than normal
```

#### Multi-Window Burn Rate Alert (Prometheus)

```yaml
# Alerts when error budget burns at a rate that exhausts it too quickly
# Uses two windows to avoid false positives from short spikes

- alert: FastifyErrorBudgetBurnHigh
  expr: |
    (
      sum(rate(http_request_duration_seconds_count{
        job="fastify-service", status_code=~"5.."
      }[1h]))
      /
      sum(rate(http_request_duration_seconds_count{
        job="fastify-service"
      }[1h]))
    ) > (14.4 * 0.005)   # 14.4× burn rate on 1h window for 99.5% SLO
    and
    (
      sum(rate(http_request_duration_seconds_count{
        job="fastify-service", status_code=~"5.."
      }[5m]))
      /
      sum(rate(http_request_duration_seconds_count{
        job="fastify-service"
      }[5m]))
    ) > (14.4 * 0.005)   # Same burn rate on 5m window (short-term confirmation)
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "Error budget burning at 14.4× — will exhaust monthly budget in ~2 hours"

- alert: FastifyErrorBudgetBurnMedium
  expr: |
    (
      sum(rate(http_request_duration_seconds_count{
        job="fastify-service", status_code=~"5.."
      }[6h]))
      /
      sum(rate(http_request_duration_seconds_count{
        job="fastify-service"
      }[6h]))
    ) > (6 * 0.005)      # 6× burn rate — will exhaust budget in ~5 days
    and
    (
      sum(rate(http_request_duration_seconds_count{
        job="fastify-service", status_code=~"5.."
      }[30m]))
      /
      sum(rate(http_request_duration_seconds_count{
        job="fastify-service"
      }[30m]))
    ) > (6 * 0.005)
  for: 15m
  labels:
    severity: warning
  annotations:
    summary: "Error budget burning at 6× — review in next business hours"
```

**Key Points:**
- The multiplier (14.4 for critical, 6 for warning) is derived from how many hours of burn at that rate would exhaust a 30-day budget. These are standard values from Google's SRE Workbook. [Unverified for all SLO configurations — adjust to your SLO target and burn rate windows.]
- The two-window approach (short + long) reduces false positives from brief spikes while still catching sustained incidents quickly.

---

### Synthetic Monitoring

Internal metrics cannot detect failures visible only from outside the service — DNS failures, TLS expiry, load balancer misconfiguration, or network partitions between the probe and the service.

#### Blackbox Exporter (Prometheus)

```yaml
# blackbox.yml
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
      valid_status_codes: [200]
      method: GET
      fail_if_body_not_matches_regexp:
        - '"status":"ok"'   # validate response body, not just status code
      tls_config:
        insecure_skip_verify: false
```

```yaml
# prometheus.yml — blackbox scrape job
- job_name: fastify-blackbox
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
        - https://api.myservice.com/health
        - https://api.myservice.com/readiness
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: blackbox-exporter:9115
```

#### Alert on Probe Failure

```yaml
- alert: FastifyHealthCheckFailing
  expr: probe_success{job="fastify-blackbox"} == 0
  for: 1m
  labels:
    severity: critical
  annotations:
    summary: "Health check failing for {{ $labels.instance }}"
    description: >
      External probe cannot reach {{ $labels.instance }}.
      This may indicate a network issue, TLS failure, or service crash
      not visible to internal Prometheus.

- alert: FastifyTLSExpiringSoon
  expr: (probe_ssl_earliest_cert_expiry - time()) / 86400 < 14
  labels:
    severity: warning
  annotations:
    summary: "TLS certificate expires in less than 14 days"
    description: >
      Certificate for {{ $labels.instance }} expires in
      {{ $value | humanize }} days.
```

---

### Alerting for Background Jobs and Workers

Fastify services often run background workers — queue consumers, scheduled jobs, cron tasks. These require different alerting patterns than HTTP services.

#### Dead Worker Detection

```js
// Heartbeat metric — updated by the worker every iteration
const workerHeartbeat = new Gauge({
  name: 'worker_last_heartbeat_timestamp_seconds',
  help: 'Unix timestamp of the last worker heartbeat',
  labelNames: ['worker_name'],
})

// In the worker loop
async function processQueue() {
  while (true) {
    await processNextBatch()
    workerHeartbeat.set({ worker_name: 'order-processor' }, Date.now() / 1000)
    await sleep(5000)
  }
}
```

```yaml
- alert: WorkerHeartbeatMissing
  expr: |
    time() - worker_last_heartbeat_timestamp_seconds{job="fastify-service"} > 60
  for: 0m   # fire immediately — no `for` grace period
  labels:
    severity: critical
  annotations:
    summary: "Worker {{ $labels.worker_name }} has not reported in 60 seconds"
```

#### Queue Depth Alert

```js
const queueDepth = new Gauge({
  name: 'job_queue_depth',
  help: 'Number of jobs waiting in the queue',
  labelNames: ['queue_name'],
})
```

```yaml
- alert: JobQueueBacklogHigh
  expr: job_queue_depth{job="fastify-service"} > 1000
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Queue {{ $labels.queue_name }} has {{ $value }} pending jobs"
```

---

### Alert Severity Model

Establish a consistent severity taxonomy across all services:

| Severity | Definition | Response | Examples |
|---|---|---|---|
| **Critical** | User-facing outage or data loss in progress | Page on-call immediately, 24/7 | Service down, error rate > 5%, payment failures |
| **Warning** | Degradation likely to become critical soon | Notify during business hours, ticket | P99 > 2s, memory > 90%, queue backing up |
| **Info** | Notable event, no immediate action needed | Log, no notification | Deployment completed, cert expiring in 30 days |

Map these to routing tiers in Alertmanager and Sentry — critical to PagerDuty, warning to Slack, info to a log or suppressed.

---

### Runbook Linking

Every alert annotation should include a `runbook` URL. A minimal runbook covers:

```markdown
# Runbook: FastifyHighErrorRate

## What this alert means
The 5xx error rate for fastify-order-service has exceeded 5% for 2+ minutes.

## Immediate steps
1. Check the dashboard: [link]
2. Check recent deployments: `kubectl rollout history deployment/fastify-order-service`
3. Check error logs: [Loki query link]
4. Check downstream dependencies (DB, Redis, external APIs)

## Common causes
- Bad deployment (roll back with `kubectl rollout undo`)
- Database connection pool exhausted
- Upstream service returning errors

## Escalation
If not resolved in 15 minutes, escalate to backend lead.
```

Runbooks should be living documents — updated after each incident with new causes and resolution steps.

---

### Alert Noise Reduction Patterns

#### `for` Duration
The `for` clause in Prometheus rules requires the condition to be continuously true for a duration before firing. This suppresses transient spikes:

```yaml
# Fires only after 5 minutes of sustained violation — not on brief spikes
for: 5m
```

Use shorter `for` on critical alerts (1–2 min) and longer on warnings (5–10 min).

#### Inhibition Rules
Suppress downstream alerts when a root cause is already firing:

```yaml
inhibit_rules:
  - source_match:
      alertname: FastifyServiceDown
    target_match_re:
      alertname: FastifyHighErrorRate|FastifyHighP99Latency|FastifyEventLoopLag
    equal: ['job', 'instance']
```

#### Dead Man's Switch
An always-firing alert that confirms the alerting pipeline is functional. If it stops firing, the pipeline itself is broken:

```yaml
- alert: AlertingPipelineAlive
  expr: vector(1)
  labels:
    severity: info
  annotations:
    summary: "Alerting pipeline heartbeat — this alert should always be firing"
```

Route this to a dedicated Alertmanager receiver that sends to a "deadmanssnitch" service (e.g., Dead Man's Snitch, Healthchecks.io) which pages if the check-in stops.

---

### On-Call Practices

Well-designed alerts are necessary but not sufficient — on-call practices determine whether alerts lead to resolution or fatigue:

- **Track alert frequency** — Review which alerts fire most often weekly. High-frequency warnings that never become critical are candidates for removal or threshold adjustment.
- **Post-incident reviews** — After every critical alert, document: what fired, what the cause was, how long resolution took, and how the alert could be improved.
- **Scheduled alert review** — Treat alert rules as code. Review and prune quarterly.
- **Avoid alert-only debugging** — Alerts should initiate investigation, not replace it. Dashboard links and runbooks in annotations do the heavy lifting.

---

**Related Topics:**

- SLO definition and error budget management with Sloth or pyrra
- Alertmanager advanced routing — per-team ownership, time-based routing
- PagerDuty escalation policies and on-call scheduling
- Grafana OnCall for alert routing and escalation
- Chaos engineering to validate alert coverage (Chaos Monkey, Gremlin)
- Uptime Kuma and Checkly for synthetic monitoring
- Multi-window multi-burn-rate alerting (Google SRE Workbook patterns)
- Incident management workflows — runbooks, postmortems, blameless culture