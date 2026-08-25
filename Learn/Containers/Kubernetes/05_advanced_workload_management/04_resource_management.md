## Resource Management


### Resource Requests and Limits

Resource requests and limits are fundamental mechanisms for controlling compute resource allocation in Kubernetes. They define the minimum resources a container needs (requests) and the maximum resources it can consume (limits).

**Resource requests** specify the minimum amount of CPU and memory that must be available on a node for a pod to be scheduled there. The scheduler uses these values to make placement decisions, ensuring nodes have sufficient capacity before scheduling pods.

**Resource limits** define the maximum amount of resources a container can use. When a container exceeds its memory limit, it gets terminated (OOMKilled). When it exceeds CPU limits, it gets throttled rather than terminated.

**Key points:**

- CPU is measured in cores (1000m = 1 core)
- Memory is measured in bytes (Ki, Mi, Gi, Ti)
- Requests affect scheduling decisions
- Limits affect runtime behavior
- Missing requests can lead to resource contention
- Missing limits can cause resource exhaustion

**Example:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
```

### Quality of Service Classes

Kubernetes automatically assigns QoS classes to pods based on their resource specifications. These classes determine pod eviction priority during resource pressure situations.

**Guaranteed QoS** applies when all containers have equal requests and limits for both CPU and memory. These pods receive the highest priority and are evicted last during resource pressure.

**Burstable QoS** applies when pods have resource requests but limits are either higher than requests or unspecified. These pods can use additional resources when available but may be evicted before Guaranteed pods.

**BestEffort QoS** applies when pods have no resource requests or limits specified. These pods can use any available resources but are evicted first during resource pressure.

**Key points:**

- QoS classes are automatically assigned based on resource specifications
- Guaranteed > Burstable > BestEffort in eviction priority
- QoS affects scheduling and eviction behavior
- Cannot be manually set - determined by resource configuration
- Critical for cluster stability under resource pressure

### Resource Quotas and Limit Ranges

Resource quotas and limit ranges provide namespace-level controls for resource consumption, preventing individual namespaces or objects from consuming excessive cluster resources.

**Resource quotas** set aggregate limits on resource consumption within a namespace. They can limit total CPU, memory, storage, and object counts (pods, services, secrets, etc.). Quotas prevent any single namespace from monopolizing cluster resources.

**Limit ranges** define default, minimum, and maximum resource values for individual objects within a namespace. They automatically apply defaults when objects don't specify resources and enforce boundaries on resource specifications.

**Key points:**

- Resource quotas control namespace-level consumption
- Limit ranges control individual object specifications
- Both enforce resource governance policies
- Quotas prevent resource exhaustion at namespace level
- Limit ranges ensure consistent resource specifications
- Essential for multi-tenant environments

**Example:**

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: namespace-quota
  namespace: development
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "10"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: namespace-limits
  namespace: development
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "2"
      memory: "2Gi"
    min:
      cpu: "50m"
      memory: "64Mi"
    type: Container
```

### Node Affinity and Anti-Affinity

Node affinity and anti-affinity provide sophisticated mechanisms for controlling pod placement based on node characteristics, enabling fine-grained scheduling decisions beyond basic resource requirements.

**Node affinity** allows pods to specify preferences or requirements for nodes based on labels. It supports both hard requirements (requiredDuringSchedulingIgnoredDuringExecution) and soft preferences (preferredDuringSchedulingIgnoredDuringExecution).

**Anti-affinity** works similarly but ensures pods are scheduled away from nodes matching certain criteria. This is useful for spreading workloads across failure domains or avoiding resource conflicts.

**Key points:**

- Affinity attracts pods to specific nodes
- Anti-affinity repels pods from specific nodes
- Supports both required and preferred rules
- Based on node labels and selectors
- More flexible than nodeSelector
- Essential for workload distribution strategies

**Example:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-demo
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/arch
            operator: In
            values:
            - amd64
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 80
        preference:
          matchExpressions:
          - key: instance-type
            operator: In
            values:
            - c5.large
            - c5.xlarge
  containers:
  - name: app
    image: nginx
```

### Taints and Tolerations

Taints and tolerations work together to ensure pods are not scheduled onto inappropriate nodes. This mechanism provides node-level control over pod placement, complementing affinity rules.

**Taints** are applied to nodes to repel pods that don't have matching tolerations. They consist of a key, value, and effect (NoSchedule, PreferNoSchedule, or NoExecute). Taints mark nodes as unsuitable for certain workloads.

**Tolerations** are applied to pods to allow them to be scheduled on nodes with matching taints. They must match the taint's key, value, and effect to overcome the repulsion.

**Key points:**

- Taints repel pods from nodes
- Tolerations allow pods to ignore taints
- Three effects: NoSchedule, PreferNoSchedule, NoExecute
- NoExecute can evict running pods
- Useful for dedicated nodes and special hardware
- Master nodes typically have taints by default

**Example:**

```yaml
# Taint a node (kubectl command)
kubectl taint nodes node1 special=gpu:NoSchedule

# Pod with toleration
apiVersion: v1
kind: Pod
metadata:
  name: toleration-demo
spec:
  tolerations:
  - key: "special"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  containers:
  - name: app
    image: nvidia/cuda:latest
```

### Resource Monitoring and Observability

Effective resource management requires comprehensive monitoring and observability to understand actual resource utilization patterns and identify optimization opportunities.

**Metrics collection** involves gathering CPU, memory, disk, and network utilization data from nodes and pods. The Metrics Server provides basic resource metrics, while Prometheus offers detailed monitoring capabilities.

**Resource utilization analysis** helps identify over-provisioned or under-provisioned resources, enabling better capacity planning and cost optimization. Tools like Vertical Pod Autoscaler (VPA) can provide recommendations based on historical usage patterns.

**Key points:**

- Metrics Server provides basic resource metrics
- Prometheus offers comprehensive monitoring
- VPA provides resource recommendations
- Horizontal Pod Autoscaler (HPA) scales based on metrics
- Custom metrics enable advanced scaling scenarios
- Proper monitoring prevents resource waste

### Cluster Autoscaling

Cluster autoscaling automatically adjusts the number of nodes in a cluster based on resource demands, ensuring optimal resource utilization while maintaining application availability.

**Cluster Autoscaler** monitors pod scheduling failures and resource utilization to make scaling decisions. It adds nodes when pods cannot be scheduled due to resource constraints and removes nodes when they become underutilized.

**Node pools** and **instance groups** provide different scaling profiles for different workload types. This allows optimization for various compute requirements, from CPU-intensive to memory-intensive workloads.

**Key points:**

- Automatically scales cluster size based on demand
- Prevents resource waste through node removal
- Supports multiple node pools with different configurations
- Integrates with cloud provider APIs
- Considers pod disruption budgets during scale-down
- Essential for cost optimization in dynamic environments

### Best Practices and Optimization

Implementing effective resource management requires following established best practices and continuously optimizing based on actual usage patterns.

**Right-sizing** involves setting appropriate resource requests and limits based on application requirements and observed behavior. This prevents both resource waste and performance issues.

**Resource efficiency** can be improved through techniques like resource sharing, workload consolidation, and using appropriate instance types for different workload characteristics.

**Key points:**

- Always set resource requests for production workloads
- Use limits to prevent resource exhaustion
- Implement resource quotas in multi-tenant environments
- Monitor actual vs. requested resource usage
- Use affinity rules for optimal placement
- Regular review and optimization of resource specifications

**Conclusion:** Resource management in Kubernetes requires a comprehensive approach combining requests/limits, QoS classes, quotas, scheduling controls, and monitoring. Proper implementation ensures efficient resource utilization, application stability, and cost optimization while maintaining the flexibility to scale based on demand.

---

