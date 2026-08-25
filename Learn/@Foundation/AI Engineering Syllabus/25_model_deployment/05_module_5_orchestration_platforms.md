## Module 5: Orchestration Platforms


### 5.1 Kubernetes Fundamentals

- Kubernetes architecture
- Master and worker nodes
- Control plane components
- etcd cluster store
- Declarative configuration
- Desired state management

### 5.2 Core Kubernetes Objects

- Pods
    - Pod lifecycle
    - Multi-container pods
    - Init containers
    - Sidecar patterns
- ReplicaSets
- Deployments
    - Rolling updates
    - Rollback strategies
    - Deployment strategies
- Services
    - ClusterIP
    - NodePort
    - LoadBalancer
    - ExternalName
- ConfigMaps and Secrets
- Namespaces

### 5.3 Kubernetes Deployment Patterns

- StatefulSets for stateful applications
- DaemonSets for node-level operations
- Jobs and CronJobs
- Horizontal Pod Autoscaler (HPA)
- Vertical Pod Autoscaler (VPA)
- Cluster Autoscaler

### 5.4 Networking in Kubernetes

- Service discovery
- DNS resolution
- Ingress controllers
    - NGINX Ingress
    - Traefik
    - HAProxy
- Network policies
- Service mesh introduction (Istio, Linkerd)

### 5.5 Storage Management

- Persistent Volumes (PV)
- Persistent Volume Claims (PVC)
- Storage Classes
- Dynamic provisioning
- Volume types (EBS, GCE PD, NFS)
- Model storage strategies

### 5.6 ML-Specific Kubernetes Tools

- KubeFlow
    - Pipeline orchestration
    - Katib for hyperparameter tuning
    - KFServing/KServe
    - Training operators
- Seldon Core
    - Advanced deployment strategies
    - Explainers integration
    - Outlier detection
- BentoML on Kubernetes

### 5.7 Kubernetes Configuration Management

- Helm charts
    - Chart structure
    - Values files
    - Template functions
    - Chart repositories
- Kustomize
    - Base and overlays
    - Patches
    - Environment-specific configs

### 5.8 Monitoring & Observability

- Prometheus for metrics
- Grafana dashboards
- Logging with Fluentd/Fluent Bit
- Distributed tracing (Jaeger, Zipkin)
- Custom metrics for ML models

### 5.9 Resource Management

- Resource requests and limits
- Quality of Service (QoS) classes
- ResourceQuotas
- LimitRanges
- GPU resource management
- Node affinity and taints/tolerations

### 5.10 Production Best Practices

- Health checks (liveness, readiness, startup)
- Graceful shutdown handling
- Pod disruption budgets
- Security contexts
- RBAC (Role-Based Access Control)
- Network policies
- Pod security policies/standards

### 5.11 Managed Kubernetes Services

- Amazon EKS
- Google GKE
- Azure AKS
- Service-specific features
- Cost optimization strategies

---

