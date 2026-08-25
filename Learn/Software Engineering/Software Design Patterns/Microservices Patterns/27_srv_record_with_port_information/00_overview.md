## Overview

dig @consul-server payment-service.service.consul SRV

;; ANSWER SECTION:
payment-service.service.consul. 0 IN SRV 1 1 8080 10.0.1.5
payment-service.service.consul. 0 IN SRV 1 1 8080 10.0.1.6
```

**Output:** Application configures database connection as `postgres.service.consul:5432`. DNS resolves to current healthy PostgreSQL instance. If instance fails health check, DNS no longer returns its IP. Application automatically connects to healthy instance on next query.

### Monitoring and Observability

#### Registry Metrics

**Key Metrics to Track:**

- Number of registered services
- Number of healthy/unhealthy instances per service
- Registration rate
- Deregistration rate
- Query latency
- Query rate
- Health check pass/fail rates

**Example Metrics:**

```
service_registry_services_total{environment="prod"} 45
service_registry_instances_total{service="order-service",status="healthy"} 12
service_registry_instances_total{service="order-service",status="unhealthy"} 1
service_registry_query_duration_seconds{service="order-service",quantile="0.95"} 0.003
service_registry_health_checks_failed_total{service="payment-service"} 23
```

#### Alerting

**Critical Alerts:**

- Registry cluster unhealthy (lost quorum)
- Service has zero healthy instances
- High rate of health check failures
- Registry query latency spike
- Registry unavailable

**Example Alert:**

```yaml
alert: ServiceHasNoHealthyInstances
expr: service_registry_instances_total{status="healthy"} == 0
for: 2m
labels:
  severity: critical
annotations:
  summary: "Service {{ $labels.service }} has no healthy instances"
  description: "All instances of {{ $labels.service }} are failing health checks"
```

#### Audit Logging

Track registry operations for security and debugging.

**Events to Log:**

- Service registration/deregistration
- Health status changes
- Configuration changes
- Authentication failures
- Query patterns

**Example Log Entry:**

```json
{
  "timestamp": "2025-12-20T10:15:30Z",
  "event": "service_registered",
  "service": "payment-service",
  "instance_id": "payment-1",
  "address": "10.0.1.45:8080",
  "tags": ["v2", "production"],
  "client_ip": "10.0.2.100",
  "auth_token": "token-abc123"
}
```

### Integration with Container Orchestration

#### Kubernetes Service Discovery

Kubernetes has built-in service discovery that can be integrated with external registries.

**Native Kubernetes Discovery:**

- Services create stable DNS names
- kube-dns/CoreDNS resolves service names
- Endpoints automatically updated as pods start/stop
- No external registry needed for cluster-internal discovery

**Example:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  selector:
    app: order-service
  ports:
  - port: 8080
    targetPort: 8080
```

Pods can access service at `order-service.default.svc.cluster.local:8080`. Kubernetes automatically load balances to healthy pods.

**Integration with External Registry:**

- Export Kubernetes services to Consul/Eureka
- Allow external clients to discover Kubernetes services
- Hybrid environments (VMs + containers)

**Example with Consul:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: order-service
  annotations:
    "consul.hashicorp.com/service-sync": "true"
    "consul.hashicorp.com/service-tags": "v2,production"
spec:
  selector:
    app: order-service
  ports:
  - port: 8080
```

Consul K8s sync controller watches Kubernetes API, automatically registers services in Consul. External services can discover Kubernetes services through Consul.

#### Docker Service Discovery

**Docker Swarm:**

- Built-in service discovery via DNS
- Services get VIP (virtual IP)
- Swarm routing mesh load balances requests

**Docker with External Registry:**

- Registrator watches Docker events
- Automatically registers containers
- Uses container labels for metadata

**Example:**

```bash
