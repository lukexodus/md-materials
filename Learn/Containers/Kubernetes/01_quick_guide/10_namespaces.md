## Namespaces


Namespaces provide a logical partitioning of cluster resources. They are useful for separating environments (dev, staging, prod) or teams within a single cluster.

```bash
# List namespaces
kubectl get namespaces

# Create a namespace
kubectl create namespace my-namespace

# Run commands in a namespace
kubectl get pods -n my-namespace

# Set default namespace for current context
kubectl config set-context --current --namespace=my-namespace
```

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace
```

Default namespaces in a cluster:

- `default` — where resources land if no namespace is specified
- `kube-system` — system components (DNS, scheduler, controller-manager)
- `kube-public` — publicly readable resources
- `kube-node-lease` — node heartbeat leases

### Resource Quotas

Limit total resource consumption in a namespace:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: my-quota
  namespace: my-namespace
spec:
  hard:
    pods: "20"
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    persistentvolumeclaims: "10"
```

### LimitRange

Set default and maximum resource limits for Pods in a namespace:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: my-limits
  namespace: my-namespace
spec:
  limits:
    - type: Container
      default:
        cpu: 200m
        memory: 256Mi
      defaultRequest:
        cpu: 100m
        memory: 128Mi
      max:
        cpu: "2"
        memory: 2Gi
```

---

