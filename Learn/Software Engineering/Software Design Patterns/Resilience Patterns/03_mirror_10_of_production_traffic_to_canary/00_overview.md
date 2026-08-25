## Overview

gor --input-raw :8080 \
    --output-http "http://canary:8080|10%" \
    --output-http-track-response \
    --http-disallow-url /healthz
```

**Shadow Mode** Route traffic to both versions but only return stable version responses. Compare outputs for behavioral parity without user impact.

```python
async def shadow_request(request):
    stable_future = httpx.AsyncClient().post(STABLE_URL, json=request)
    canary_future = httpx.AsyncClient().post(CANARY_URL, json=request)
    
    stable_resp = await stable_future
    canary_resp = await canary_future  # Fire-and-forget
    
    # Async comparison and alerting
    asyncio.create_task(compare_responses(stable_resp, canary_resp))
    
    return stable_resp
```

**Multi-Armed Bandit** Dynamically adjust traffic distribution based on observed performance using reinforcement learning. Optimize for business objectives (revenue, engagement) rather than fixed promotion schedule.

**Ring Deployment** Expand canary across geographic rings or availability zones. Deploy to single zone, validate, expand to region, then globally.

### Compliance Considerations

**Audit Trail** Maintain immutable record of:

- Deployment trigger (commit SHA, author, timestamp)
- Traffic distribution history
- Automated decision rationale (metric values at rollback)
- Manual interventions

**Feature Flag Coordination** Combine canary releases with feature flags for defense-in-depth. Canary version has flag enabled; rollback both traffic routing and flag state.

```go
if featureFlags.IsEnabled("new-payment-flow") && 
   deploymentManager.GetVersion() == "canary" {
    return newPaymentFlow(ctx, order)
}
return legacyPaymentFlow(ctx, order)
```

**Data Residency** Canary versions processing sensitive data (PII, PHI, PCI) require identical compliance controls as stable. Separate canary infrastructure may not inherit existing audit logging or encryption configurations.

### Operational Metrics

Track canary process effectiveness:

- Mean time to detect (MTTD) regressions
- False positive rollback rate
- Canary duration (deployment to full promotion)
- Manual intervention frequency
- User impact (users exposed to bugs before rollback)

Related topics: Blue-green deployments, feature flags, progressive delivery, chaos engineering, A/B testing, traffic shadowing, service mesh routing.

---

## Rolling Deployment

A release strategy that incrementally replaces running application instances with new versions while maintaining service availability, distributing deployment risk across time and infrastructure subsets. The deployment progresses in waves, with each wave replacing a percentage of instances, validating health, then proceeding or rolling back based on success criteria.

### Wave Sizing and Progression

**Percentage-Based Waves**: Replace fixed percentage of fleet per wave (e.g., 10%, 25%, 50%, 100%). Smaller percentages reduce blast radius but extend total deployment time. Large initial waves accelerate deployment but amplify impact of defects. Common progression: 10% canary, 50% expansion, 100% completion—balances risk and velocity.

**Absolute Count Waves**: Replace fixed number of instances per wave regardless of fleet size. Provides consistent blast radius across environments but may be inappropriate for small fleets (one instance = 100% in single-instance deployment) or massive fleets (10 instances = 0.01% in 100K-instance fleet).

**Progressive Expansion**: Exponentially increase wave size (1, 2, 4, 8, 16...) or use Fibonacci sequence (1, 1, 2, 3, 5, 8...). Detects problems quickly with minimal impact in early waves while accelerating deployment once confidence established. Requires automated health validation to prevent exponential error propagation.

### Health Validation Between Waves

**Passive Health Checks**: Monitor standard telemetry (error rates, latency percentiles, resource utilization) for regressions. Compare new version metrics against baseline established by previous version. Statistical significance testing required to distinguish noise from genuine regressions—single anomalous request should not halt deployment.

**Active Health Checks**: Execute synthetic transactions against newly deployed instances before admitting them to production traffic. Validates application startup, dependency connectivity, and critical paths. Distinguishes deployment failures (application won't start) from runtime regressions (application starts but behaves incorrectly under load).

**Soak Period**: Pause between waves allowing new instances to process production traffic for duration sufficient to expose time-dependent issues (memory leaks, connection pool exhaustion, cache warming). Soak duration proportional to issue detection time—bugs manifesting within seconds need shorter soaks than issues appearing after hours. Excessive soak periods delay deployments unnecessarily; insufficient soaks miss latent defects.

**Automated Rollback Triggers**: Define quantitative thresholds that automatically abort deployment and revert affected instances. Example criteria: error rate exceeds baseline by 2 standard deviations, p99 latency increases 50%, any 5XX response on health endpoint, memory usage exceeds 90%. Thresholds must account for warm-up effects—newly started instances often exhibit degraded performance until caches populate.

### Traffic Management During Rollout

**Load Balancer Configuration**: Remove instance from load balancer rotation before terminating old version. Prevents in-flight requests from being dropped. Requires health check endpoint that fails after receiving shutdown signal, giving load balancer time to deregister instance before process termination. Drain period must exceed maximum request duration to ensure no in-flight requests remain.

**Connection Draining**: Wait for existing connections to close naturally before terminating instance. Prevents abrupt connection termination for long-lived connections (WebSockets, streaming responses, persistent HTTP/2 connections). Drain timeout required to force termination of stuck connections—infinite draining prevents deployment completion.

**Session Affinity Complications**: Sticky sessions route users to same instance, creating inconsistent user experience during rollout. Some users see old version, others see new version, creating support burden when behaviors differ. Mitigation requires session state externalization or accepting temporary inconsistency. Blue-green deployments may be preferable when session affinity critical.

**Partial Traffic Shifting**: Route percentage of requests to new instances independent of fleet replacement percentage. Enables testing new version with production traffic before deploying to significant portion of fleet. Requires sophisticated routing layer (service mesh, API gateway) capable of weighted traffic distribution. Distinction between instance count and traffic volume becomes critical—10% of instances may receive 50% of traffic if old instances are overloaded.

### Database Schema Compatibility

**Backwards Compatible Migrations**: New version must operate with old schema, and old version must tolerate new schema. Deployment order ambiguity—cannot guarantee whether code or schema deploys first—necessitates compatibility in both directions. Achieve through expansion/contraction pattern: add new columns/tables while preserving old ones, deploy code changes, remove old schema only after old code version completely replaced.

**Multi-Phase Deployments**: Separate schema changes from code changes across multiple deployment cycles. Phase 1: add new schema elements (columns, tables, indexes), deploy. Phase 2: deploy code reading from new schema while writing to both old and new. Phase 3: deploy code exclusively using new schema. Phase 4: remove old schema elements. Slow but eliminates compatibility risks.

**Read-Write Split**: New version writes to new schema but reads from old schema. Background migration job copies data from old to new schema. Once migration complete, switch new version to read from new schema. Requires dual-write period where updates write to both schemas, introducing consistency complexity.

### Configuration Management

**Feature Flags for Behavior Changes**: Decouple deployment from feature activation. Deploy new code with features disabled, validate deployment health, then enable features gradually via runtime configuration. Permits instant rollback of feature without redeployment. Adds complexity—code must handle feature flag evaluation, testing requires covering all flag combinations, stale flags accumulate as technical debt.

**Immutable Configuration**: Bake configuration into deployment artifact (container image, AMI) to ensure configuration-code consistency. Prevents configuration drift where different instances have different configurations despite running same code version. Configuration changes require full redeployment, slowing iteration on configuration-only changes.

**External Configuration Stores**: Retrieve configuration from central store (Consul, etcd, AWS Parameter Store) at runtime. Enables configuration updates without redeployment but creates runtime dependency on configuration store. Configuration changes invisible in deployment audit trail. Version skew occurs when instances fetch configuration at different times during rolling deployment.

### Instance Replacement Strategies

**In-Place Updates**: Update existing instances without creating new infrastructure. Minimizes infrastructure churn and resource utilization but cannot guarantee clean state. Previous version's file system artifacts, environment variables, or background processes may persist. Rollback requires second in-place update, doubling rollback time.

**Immutable Infrastructure**: Terminate old instances and launch new instances with new version. Guarantees clean slate for each deployment. Requires orchestration platform support (Kubernetes, ECS, Auto Scaling Groups). Slower than in-place updates due to instance startup time. Temporary capacity reduction during replacement unless overprovisioning.

**Blue-Green Hybrid**: Maintain old instances (blue) while launching new instances (green). Once green instances healthy, shift traffic from blue to green, then terminate blue. Requires double infrastructure capacity during deployment window. Provides instant rollback by shifting traffic back to blue instances. Cost prohibitive for large fleets.

### Rollback Mechanics

**Automatic vs Manual**: Automated rollback based on health metrics eliminates human response latency but risks false positive rollbacks from transient issues. Manual rollback requires on-call intervention, introducing human latency and potential for delayed response during off-hours. Hybrid approach: automated rollback for severe regressions (5XX errors, process crashes), manual approval for subtle degradations (latency increases, elevated error rates).

**Progressive Rollback**: Revert waves in reverse order, validating health after each rollback wave. Prevents thundering herd if rollback itself introduces issues. Time-consuming when urgent rollback needed.

**Instant Rollback**: Simultaneously revert all instances to previous version. Fastest rollback but creates instantaneous load spike and maximum blast radius if rollback process itself is flawed.

**Forward Fix**: Deploy new version fixing issue instead of rolling back. Appropriate when rollback is riskier than forward fix (database migrations applied, external integrations updated, contract changes published). Requires rapid development and deployment pipeline.

### Multi-Region Deployment Sequencing

**Sequential Regional Rollout**: Deploy to one region completely before proceeding to next region. Limits blast radius to single region but extends global deployment time linearly with region count. First region serves as implicit canary for subsequent regions.

**Parallel Regional Rollout**: Deploy to all regions simultaneously, with each region progressing through its own wave sequence. Fastest global deployment but multiplies blast radius—defect impacts all regions simultaneously. Coordination complexity when shared resources (global databases, central services) involved.

**Follow-the-Sun Rollout**: Deploy during local business hours for each region. Ensures engineers awake and available to monitor deployment. Extends deployment window across 24 hours but maximizes human oversight. Timezone gaps create coordination windows where no region actively deploying.

### Monitoring Deployment Quality

**Deployment Success Rate**: Percentage of deployments completing without rollback. Low success rate indicates inadequate pre-deployment validation or overly aggressive rollback triggers. Track separately by component, team, and time period to identify patterns.

**Mean Time to Rollback**: Duration from rollback initiation to service restoration. Measures rollback efficiency. Increasing MTTR suggests rollback automation degradation or increasing system complexity requiring more manual intervention.

**Deployment Duration**: Time from deployment start to completion. Increasing duration indicates infrastructure scaling issues or insufficient parallelization. Separate metrics for nominal deployments vs deployments requiring manual intervention.

**Blast Radius Metrics**: Number of users, requests, or revenue affected by deployment-related incidents. More meaningful than deployment count for assessing deployment risk management effectiveness.

### Anti-Patterns

**Unbounded Wave Duration**: Proceeding to next wave immediately after previous wave completes health checks without soak period. Misses time-dependent issues like memory leaks or gradual resource exhaustion.

**Uniform Health Check Intervals**: Using same health check frequency throughout deployment. Early waves warrant aggressive monitoring (seconds), later waves can reduce frequency (minutes) to avoid alert fatigue and monitoring overhead.

**Ignoring Long-Tail Latencies**: Focusing solely on error rates while ignoring latency regressions. Many performance issues manifest as latency increases before causing errors. P99 and P999 latencies often reveal issues invisible in P50 or average metrics.

**Single Health Metric**: Declaring instance healthy based solely on HTTP 200 response from health endpoint. Comprehensive health requires validating dependencies, resource levels, and business-critical functionality. Health endpoint should exercise actual application logic, not merely return hardcoded success.

**Deployment During Peak Traffic**: Rolling deployments during high load amplify risk—reduced capacity from terminated instances combines with increased error rates from defects to overwhelm remaining capacity. Deploy during traffic valleys when spare capacity available to absorb issues.

**Version Skew Ignorance**: Running mixed versions without testing cross-version interactions. Assumes versions operate independently but RPC contracts, shared caches, or database state create implicit coupling. Incompatible versions may corrupt shared state or fail on cross-version requests.

Related topics: Blue-green deployment, Canary releases, Feature flag systems, Database migration strategies, Service mesh traffic splitting, Chaos engineering for deployment resilience, Automated remediation systems, Deployment pipeline optimization

---

