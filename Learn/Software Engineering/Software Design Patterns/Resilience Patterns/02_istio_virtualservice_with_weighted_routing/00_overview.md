## Overview

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: payment-service
spec:
  hosts:
  - payment-service
  http:
  - match:
    - headers:
        x-canary:
          exact: "true"
    route:
    - destination:
        host: payment-service
        subset: canary
      weight: 100
  - route:
    - destination:
        host: payment-service
        subset: stable
      weight: 90
    - destination:
        host: payment-service
        subset: canary
      weight: 10
```

### Observability Integration

**Distributed Tracing** Tag spans with version identifiers for request-level analysis:

```
span.SetTag("app.version", "v2.3.1-canary")
span.SetTag("deployment.type", "canary")
```

Enables error trace comparison between versions and identification of version-specific code paths causing regressions.

**Log Aggregation** Structured logging with version context:

```json
{
  "timestamp": "2026-01-03T10:15:30Z",
  "level": "ERROR",
  "service": "payment-service",
  "version": "v2.3.1",
  "deployment": "canary",
  "error": "PaymentGatewayTimeout",
  "user_id": "usr_abc123"
}
```

Query patterns: `service:payment-service deployment:canary level:ERROR | stats count by error`

**Metric Dimensions** Add version label to all Prometheus metrics:

```go
requestDuration := prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        Name: "http_request_duration_seconds",
        Buckets: prometheus.DefBuckets,
    },
    []string{"method", "endpoint", "status", "version"},
)

// Recording
requestDuration.WithLabelValues(
    req.Method, 
    req.URL.Path, 
    strconv.Itoa(statusCode),
    appVersion,
).Observe(duration.Seconds())
```

### Anti-Patterns

**Insufficient Bake Time** [Inference] Promoting canary after 5 minutes of 1% traffic provides statistically insignificant data. Minimum 30-60 minutes per stage with meaningful traffic volume (1000+ requests).

**Ignoring Off-Peak Effects** Deploying canary at 3 AM with minimal traffic masks issues that manifest under load. Schedule canaries during representative traffic periods.

**Single Metric Focus** Monitoring only error rate misses latency regressions, resource leaks, or business metric degradation. Require multi-dimensional health validation.

**Blast Radius Ignorance** [Inference] 50% canary traffic exposes half your users to potential bugs. Conservative maximum: 25% for customer-facing services, 50% for internal APIs.

**Skipped Rollback Testing** [Inference] Untested rollback procedures fail during incidents. Regularly execute rollback drills and validate automation triggers with synthetic failures.

**Version Skew Dependencies** Canary introduces API incompatibilities with downstream services still on stable version. Maintain backward compatibility or coordinate multi-service canary releases.

**Database Migration Conflicts** Canary version applies schema migration incompatible with stable version. Use expand-contract pattern: add columns (backward compatible), deploy canary, remove old columns.

### Advanced Patterns

**Synthetic Traffic Generation** Replay production traffic patterns against canary before live user exposure. Tools: GoReplay, Diffy, Gor.

```bash
