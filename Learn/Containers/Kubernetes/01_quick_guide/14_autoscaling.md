## Autoscaling


### Horizontal Pod Autoscaler (HPA)

Scales the number of Pod replicas based on observed metrics:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: AverageValue
          averageValue: 200Mi
```

HPA requires the Metrics Server to be installed in the cluster.

```bash
kubectl get hpa
kubectl describe hpa my-hpa
```

### Vertical Pod Autoscaler (VPA)

Automatically adjusts CPU/memory requests and limits for containers. Requires installing the VPA controller separately.

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-deployment
  updatePolicy:
    updateMode: Auto  # Auto, Recreate, Initial, or Off
```

### Cluster Autoscaler

Scales the number of nodes in a cluster based on pending Pods and underutilized nodes. Typically configured at the cloud provider level (not a Kubernetes object).

---

