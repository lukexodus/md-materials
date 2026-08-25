## Horizontal Pod Autoscaling (HPA)


### Overview

Horizontal Pod Autoscaling (HPA) is a Kubernetes feature that automatically scales the number of pods in a deployment, replica set, or stateful set based on observed CPU utilization, memory usage, or custom metrics. HPA works by periodically querying metrics and adjusting the replica count to maintain target resource utilization levels.

### How HPA Works

The HPA controller runs as a control loop that periodically queries the Metrics Server for resource utilization data. By default, it checks metrics every 15 seconds and makes scaling decisions based on the average resource utilization across all pods in the target deployment. The controller calculates the desired number of replicas using the formula:

```
desiredReplicas = ceil[currentReplicas * (currentMetricValue / desiredMetricValue)]
```

The HPA controller respects scaling policies to prevent thrashing, including cooldown periods and scaling limits. It will not scale down if the last scale-up occurred within the past 3 minutes, and it will not scale up if the last scale-down occurred within the past 1 minute.

### Metrics-Based Scaling

HPA supports three types of metrics for scaling decisions:

#### Resource Metrics

These are built-in Kubernetes resource metrics like CPU and memory utilization, collected by the Metrics Server.

#### Pod Metrics

Custom metrics specific to pods, such as requests per second, queue length, or application-specific performance indicators.

#### Object Metrics

Metrics from Kubernetes objects like Ingress controllers, Services, or custom resources that aren't directly associated with pods.

### CPU and Memory-Based Autoscaling

#### CPU-Based Scaling

CPU-based autoscaling is the most common HPA configuration. It monitors CPU utilization as a percentage of requested CPU resources.

**Example** basic CPU-based HPA configuration:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

#### Memory-Based Scaling

Memory-based autoscaling monitors memory utilization as a percentage of requested memory resources. Memory scaling is more complex than CPU scaling because memory is not as readily released by applications.

**Example** memory-based HPA configuration:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-memory-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 15
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

#### Combined CPU and Memory Scaling

HPA can use multiple metrics simultaneously. When multiple metrics are specified, HPA calculates the desired replica count for each metric and uses the highest value.

**Example** combined metrics configuration:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-combined-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 3
  maxReplicas: 20
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
        type: Utilization
        averageUtilization: 80
```

### Custom Metrics Scaling

Custom metrics scaling allows HPA to make decisions based on application-specific metrics or external metrics from monitoring systems like Prometheus, Datadog, or cloud provider monitoring services.

#### Application Metrics

These metrics come directly from your applications and are typically exposed through the Custom Metrics API.

**Example** custom metrics configuration:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-custom-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 25
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
  - type: Object
    object:
      metric:
        name: requests_per_second
      describedObject:
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        name: webapp-ingress
      target:
        type: Value
        value: "1000"
```

#### External Metrics

External metrics come from systems outside the Kubernetes cluster, such as cloud provider metrics, message queue lengths, or database connection pools.

**Example** external metrics configuration:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-external-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 50
  metrics:
  - type: External
    external:
      metric:
        name: sqs_queue_length
        selector:
          matchLabels:
            queue_name: webapp-tasks
      target:
        type: Value
        value: "30"
```

### HPA Configuration Options

#### Scaling Policies

HPA v2 supports advanced scaling policies that provide fine-grained control over scaling behavior:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: webapp-policy-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 100
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
      - type: Pods
        value: 5
        periodSeconds: 60
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
      selectPolicy: Min
```

#### Target Types

HPA supports different target types for metrics:

- **Utilization**: Percentage of requested resources
- **AverageValue**: Target average value across all pods
- **Value**: Absolute target value for object metrics

### Prerequisites and Setup

#### Metrics Server

HPA requires the Metrics Server to be installed and running in the cluster. The Metrics Server collects resource metrics from kubelets and provides them through the Metrics API.

#### Resource Requests

For CPU and memory-based scaling, pods must have resource requests defined. HPA calculates utilization as a percentage of requested resources.

**Example** deployment with resource requests:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:latest
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

#### Custom Metrics API

For custom metrics scaling, you need to deploy a custom metrics adapter such as:

- Prometheus Adapter
- Datadog Cluster Agent
- Azure Monitor Adapter
- Google Cloud Monitoring Adapter

### Monitoring and Troubleshooting

#### HPA Status

Monitor HPA status using kubectl commands:

```bash
kubectl get hpa
kubectl describe hpa webapp-hpa
kubectl get hpa webapp-hpa -o yaml
```

#### Common Issues

- Insufficient metrics data due to missing Metrics Server
- Incorrect resource requests leading to inaccurate utilization calculations
- Scaling thrashing due to inadequate stabilization windows
- Custom metrics not available due to missing or misconfigured metrics adapters

#### Debugging Commands

```bash
# Check HPA events
kubectl describe hpa webapp-hpa

# View HPA logs
kubectl logs -n kube-system deployment/metrics-server

# Check metrics availability
kubectl top pods
kubectl top nodes
```

### Vertical Pod Autoscaling (VPA) Overview

Vertical Pod Autoscaling (VPA) is complementary to HPA and focuses on automatically adjusting the CPU and memory requests and limits of containers within pods. While HPA scales the number of pods horizontally, VPA scales the resources of individual pods vertically.

#### VPA Components

- **VPA Recommender**: Monitors resource usage and provides recommendations
- **VPA Updater**: Evicts pods that need resource updates
- **VPA Admission Controller**: Sets resource requests on new pods

#### VPA Update Modes

- **Off**: Only provides recommendations without making changes
- **Initial**: Sets resource requests when pods are created
- **Recreation**: Updates resource requests by recreating pods
- **Auto**: Automatically updates resource requests (experimental)

#### VPA vs HPA

VPA and HPA can work together but require careful configuration to avoid conflicts. Generally, HPA should be used for CPU-based scaling while VPA handles memory optimization.

**Example** VPA configuration:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: webapp-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: webapp
      maxAllowed:
        cpu: 1
        memory: 2Gi
      minAllowed:
        cpu: 100m
        memory: 128Mi
```

### Best Practices

#### Scaling Strategy

- Start with conservative scaling policies and adjust based on application behavior
- Use multiple metrics for more accurate scaling decisions
- Set appropriate minimum and maximum replica counts
- Configure stabilization windows to prevent scaling thrashing

#### Resource Management

- Always define resource requests for containers
- Set realistic resource limits to prevent resource exhaustion
- Monitor actual resource usage to optimize requests and limits
- Use VPA recommendations to right-size container resources

#### Testing and Validation

- Test scaling behavior under load in staging environments
- Validate that applications can handle rapid scaling events
- Monitor scaling events and adjust policies based on observed behavior
- Implement proper health checks to ensure pod readiness

**Key points**: HPA provides automatic horizontal scaling based on metrics, requires proper resource requests and monitoring setup, supports multiple scaling strategies, and works best when combined with appropriate scaling policies and monitoring. VPA complements HPA by optimizing individual pod resources vertically.

For production deployments, consider implementing both HPA and VPA with careful configuration to avoid conflicts, comprehensive monitoring to track scaling behavior, and proper testing to validate scaling policies under various load conditions.

---

