## Overview

apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: payment-service
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: payment-service
  service:
    port: 8080
  analysis:
    interval: 1m
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
    - name: request-success-rate
      thresholdRange:
        min: 99.5
      interval: 1m
    - name: request-duration
      thresholdRange:
        max: 500
      interval: 1m
```

**User Cohort Targeting** Route specific user segments to canary versions based on attributes:

- Internal employees (dogfooding)
- Beta program participants
- Geographic regions (APAC before EMEA before Americas)
- Account tiers (free users before premium)

```go
func getVersionForUser(userID string, canaryWeight float64) string {
    hash := fnv.New32a()
    hash.Write([]byte(userID))
    bucket := float64(hash.Sum32()%100) / 100.0
    
    if bucket < canaryWeight {
        return "canary"
    }
    return "stable"
}
```

**Session Affinity** Pin users to single version for session duration. Prevents mid-session version switching that could corrupt state or create inconsistent UX.

```nginx
upstream backend {
    hash $cookie_version_affinity consistent;
    server stable-v1:8080;
    server canary-v2:8080;
}

map $http_cookie $version_cookie {
    default "";
    "~*version_affinity=(?<version>[^;]+)" $version;
}
```

### Health Signal Collection

**Golden Signals** Monitor four critical metrics per Google SRE practices:

1. **Latency**: P50, P95, P99 response times
2. **Traffic**: Requests per second, bandwidth
3. **Errors**: 5xx rate, exception count, business logic failures
4. **Saturation**: CPU, memory, connection pool utilization

**Statistical Significance** Require minimum sample size before comparing canary to baseline. Mann-Whitney U test or two-proportion z-test validates observed differences aren't noise.

```python
from scipy import stats

def is_canary_acceptable(baseline_errors, canary_errors, 
                         baseline_requests, canary_requests):
    # Require minimum 1000 requests per variant
    if canary_requests < 1000 or baseline_requests < 1000:
        return None  # Insufficient data
    
    baseline_rate = baseline_errors / baseline_requests
    canary_rate = canary_errors / canary_requests
    
    # Two-proportion z-test
    z_stat, p_value = stats.proportions_ztest(
        [canary_errors, baseline_errors],
        [canary_requests, baseline_requests]
    )
    
    # Reject if statistically significantly worse (p < 0.05)
    # AND absolute error rate increase > 0.1%
    return not (p_value < 0.05 and canary_rate > baseline_rate + 0.001)
```

**Business Metrics** Technical health doesn't guarantee business success. Track:

- Conversion rate (checkout completion, signup)
- Revenue per session
- Feature adoption rate
- Time-on-site, bounce rate

```sql
-- Real-time business metric comparison
SELECT 
    version,
    COUNT(DISTINCT session_id) as sessions,
    COUNT(DISTINCT CASE WHEN purchased THEN session_id END) as conversions,
    SAFE_DIVIDE(
        COUNT(DISTINCT CASE WHEN purchased THEN session_id END),
        COUNT(DISTINCT session_id)
    ) as conversion_rate,
    SUM(revenue) as total_revenue
FROM events
WHERE timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 15 MINUTE)
GROUP BY version;
```

### Rollback Automation

**Threshold-Based Triggers** Define automated rollback conditions:

- Error rate > 1% (absolute) or 2x baseline (relative)
- P99 latency > 2000ms or 1.5x baseline
- Business metric degradation > 5% (conversion rate, revenue)
- Crash rate > 0.1%

**Progressive Rollback** Gradually reduce canary traffic before full removal to distinguish transient spikes from sustained degradation.

```javascript
class CanaryController {
    async evaluateCanary(canaryMetrics, baselineMetrics) {
        const analysis = this.compareMetrics(canaryMetrics, baselineMetrics);
        
        if (analysis.severity === 'CRITICAL') {
            // Immediate rollback
            await this.setCanaryWeight(0);
            await this.alertOncall('Canary auto-rollback: critical failure');
        } else if (analysis.severity === 'WARNING') {
            // Progressive rollback
            const currentWeight = await this.getCanaryWeight();
            const newWeight = Math.max(0, currentWeight - 10);
            await this.setCanaryWeight(newWeight);
            
            if (newWeight === 0) {
                await this.alertOncall('Canary rolled back after warnings');
            }
        } else {
            // Promotion
            const currentWeight = await this.getCanaryWeight();
            if (currentWeight < 100) {
                await this.setCanaryWeight(Math.min(100, currentWeight + 10));
            }
        }
    }
}
```

**Manual Override** Provide kill switch for immediate rollback independent of automated analysis. Circuit breaker for canary promotion process.

### Infrastructure Requirements

**Parallel Capacity** Run both versions simultaneously during canary window. Provision resources for 100% traffic on each version to handle rapid rollback without capacity constraints.

**Version Isolation** Deploy canary to dedicated infrastructure subset to prevent noisy neighbor effects from contaminating baseline metrics. Use separate:

- Kubernetes namespaces or node pools
- AWS target groups with distinct Auto Scaling Groups
- Database connection pools with separate limits

**Configuration Management**

```yaml
