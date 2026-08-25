## Common Patterns and Best Practices


### Resource Requests and Limits

Always set resource requests and limits on every container. Without requests, the scheduler cannot make informed placement decisions. Without limits, a runaway container can starve other workloads on the same node.

### Liveness and Readiness Probes

Always define both. Readiness probes prevent traffic from reaching Pods that are not yet ready. Liveness probes allow Kubernetes to recover from deadlocks or corrupted states.

### Use Namespaces for Isolation

Separate teams, environments, or applications into namespaces. Combine with ResourceQuotas and NetworkPolicies for hard boundaries.

### Avoid Running as Root

```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
    - name: app
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
```

### Use Image Tags Explicitly

Avoid `latest` in production — it makes deployments non-deterministic and hard to roll back. Pin to a specific digest or semantic version tag.

### Use Deployment Strategies Deliberately

`RollingUpdate` with `maxUnavailable: 0` ensures zero downtime but requires your application to handle running two versions simultaneously. `Recreate` stops all old Pods before starting new ones — causes downtime but is simpler.

### Separate Config from Code

Use ConfigMaps and Secrets to inject configuration. Do not bake environment-specific values into container images.

### Labels and Selectors

Use a consistent labeling schema across all resources:

```yaml
labels:
  app.kubernetes.io/name: my-app
  app.kubernetes.io/version: "1.5.0"
  app.kubernetes.io/component: frontend
  app.kubernetes.io/part-of: my-platform
  app.kubernetes.io/managed-by: helm
```

### Pod Disruption Budgets

Limit disruption during voluntary operations (node drains, rolling updates):

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-pdb
spec:
  minAvailable: 2      # or maxUnavailable: 1
  selector:
    matchLabels:
      app: my-app
```

### Use Horizontal Pod Autoscaler with Appropriate Headroom

Set HPA targets (e.g. 70% CPU) to leave headroom for traffic spikes before the autoscaler adds more replicas.

---

