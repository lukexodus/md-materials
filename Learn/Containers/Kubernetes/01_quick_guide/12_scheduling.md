## Scheduling


### Resource Requests and Limits

Requests are used by the scheduler to find a suitable node. Limits cap the container's resource usage at runtime.

```yaml
resources:
  requests:
    cpu: "250m"     # 250 millicores = 0.25 CPU
    memory: "128Mi"
  limits:
    cpu: "1"
    memory: "512Mi"
```

If a container exceeds its memory limit it is OOMKilled. If it exceeds its CPU limit it is throttled.

### Node Selector

Schedule Pods on nodes with specific labels:

```yaml
spec:
  nodeSelector:
    disktype: ssd
    region: us-east-1
```

Label a node:

```bash
kubectl label node my-node disktype=ssd
```

### Node Affinity

More expressive than `nodeSelector`:

```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: disktype
                operator: In
                values:
                  - ssd
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          preference:
            matchExpressions:
              - key: region
                operator: In
                values:
                  - us-east-1
```

### Pod Affinity and Anti-Affinity

Schedule Pods relative to other Pods:

```yaml
spec:
  affinity:
    # Co-locate with Pods that have app=cache
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app: cache
          topologyKey: kubernetes.io/hostname

    # Spread away from Pods that have app=my-app
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app: my-app
            topologyKey: kubernetes.io/hostname
```

### Taints and Tolerations

Taints repel Pods from nodes. Tolerations allow Pods to be scheduled onto tainted nodes.

```bash
# Add a taint to a node
kubectl taint nodes my-node dedicated=gpu:NoSchedule

# Remove a taint
kubectl taint nodes my-node dedicated=gpu:NoSchedule-
```

```yaml
# Tolerate the taint in a Pod
spec:
  tolerations:
    - key: "dedicated"
      operator: "Equal"
      value: "gpu"
      effect: "NoSchedule"
```

Taint effects:

- `NoSchedule` — New Pods will not be scheduled unless they tolerate the taint
- `PreferNoSchedule` — Scheduler tries to avoid placing Pods but is not strict
- `NoExecute` — Existing Pods without the toleration are evicted

### Topology Spread Constraints

Evenly distribute Pods across failure domains (zones, nodes):

```yaml
spec:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: DoNotSchedule
      labelSelector:
        matchLabels:
          app: my-app
```

---

