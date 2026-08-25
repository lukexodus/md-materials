## Kubernetes Monitoring Stack


### Overview

A comprehensive Kubernetes monitoring stack is essential for maintaining cluster health, application performance, and operational visibility. The monitoring ecosystem typically consists of metrics collection, storage, visualization, and alerting components working together to provide end-to-end observability. The combination of Prometheus for metrics collection, Grafana for visualization, and Alertmanager for notifications forms the foundation of most Kubernetes monitoring solutions.

### Metrics Collection with Prometheus

Prometheus is a time-series database and monitoring system specifically designed for cloud-native environments. It uses a pull-based model to scrape metrics from various targets and stores them in a highly efficient time-series format.

#### Prometheus Architecture

The Prometheus ecosystem consists of several key components:

**Prometheus Server**: The core component that scrapes and stores metrics data, evaluates recording and alerting rules, and provides a query interface through PromQL.

**Exporters**: Specialized components that expose metrics from various systems and applications in Prometheus format.

**Pushgateway**: Allows ephemeral jobs to push metrics to Prometheus for batch jobs and short-lived processes.

**Alertmanager**: Handles alerts sent by Prometheus and routes them to various notification channels.

#### Prometheus Installation

**Example** Prometheus deployment using the kube-prometheus-stack:

```yaml
# Using Helm to install the complete monitoring stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=100Gi \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.retention=30d
```

#### Custom Prometheus Configuration

**Example** Prometheus configuration for custom scraping:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
    - /etc/prometheus/rules/*.yml
    
    scrape_configs:
    - job_name: 'kubernetes-apiservers'
      kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names:
          - default
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https
    
    - job_name: 'kubernetes-nodes'
      kubernetes_sd_configs:
      - role: node
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
    
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: kubernetes_pod_name
```

#### ServiceMonitor for Custom Applications

ServiceMonitor is a Prometheus Operator custom resource that defines how to scrape metrics from Kubernetes services.

**Example** ServiceMonitor configuration:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: webapp-metrics
  namespace: monitoring
  labels:
    app: webapp
spec:
  selector:
    matchLabels:
      app: webapp
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
    honorLabels: true
  namespaceSelector:
    matchNames:
    - production
    - staging
```

#### Application Metrics Exposure

**Example** application with Prometheus metrics endpoint:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-with-metrics
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: webapp
        image: webapp:latest
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 9090
          name: metrics
        env:
        - name: METRICS_PORT
          value: "9090"
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: production
  labels:
    app: webapp
spec:
  selector:
    app: webapp
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: metrics
    port: 9090
    targetPort: 9090
```

#### PromQL Queries for Kubernetes

**Example** essential PromQL queries for Kubernetes monitoring:

```promql
# CPU utilization by pod
rate(container_cpu_usage_seconds_total{container!="POD",container!=""}[5m]) * 100

# Memory utilization by pod
container_memory_working_set_bytes{container!="POD",container!=""} / container_spec_memory_limit_bytes * 100

# Pod restart count
increase(kube_pod_container_status_restarts_total[1h])

# Node CPU utilization
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Disk usage by node
(node_filesystem_size_bytes{fstype!="tmpfs"} - node_filesystem_free_bytes{fstype!="tmpfs"}) / node_filesystem_size_bytes{fstype!="tmpfs"} * 100

# HTTP request rate
sum(rate(http_requests_total[5m])) by (service, method, status)

# Application error rate
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100
```

### Visualization with Grafana

Grafana provides powerful visualization capabilities for Prometheus metrics, offering customizable dashboards, alerting, and data exploration features.

#### Grafana Installation and Configuration

**Example** Grafana deployment with persistent storage:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
        - name: GF_INSTALL_PLUGINS
          value: "grafana-kubernetes-app"
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config
          mountPath: /etc/grafana/provisioning
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-pvc
      - name: grafana-config
        configMap:
          name: grafana-config
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-pvc
  namespace: monitoring
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

#### Grafana Data Source Configuration

**Example** Prometheus data source configuration:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: monitoring
data:
  datasources.yaml: |
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus-server:9090
      isDefault: true
      editable: true
    - name: Loki
      type: loki
      access: proxy
      url: http://loki:3100
      editable: true
    - name: Jaeger
      type: jaeger
      access: proxy
      url: http://jaeger-query:16686
      editable: true
```

#### Custom Dashboard Creation

**Example** Kubernetes cluster overview dashboard configuration:

```json
{
  "dashboard": {
    "title": "Kubernetes Cluster Overview",
    "tags": ["kubernetes", "cluster"],
    "timezone": "browser",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "{{instance}}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "thresholds": {
              "steps": [
                {"color": "green", "value": 0},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 90}
              ]
            }
          }
        }
      },
      {
        "title": "Memory Usage",
        "type": "timeseries",
        "targets": [
          {
            "expr": "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100",
            "legendFormat": "{{instance}}"
          }
        ]
      },
      {
        "title": "Pod Status",
        "type": "piechart",
        "targets": [
          {
            "expr": "sum by (phase) (kube_pod_status_phase)",
            "legendFormat": "{{phase}}"
          }
        ]
      }
    ]
  }
}
```

#### Dashboard Provisioning

**Example** dashboard provisioning configuration:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboards-config
  namespace: monitoring
data:
  dashboards.yaml: |
    apiVersion: 1
    providers:
    - name: 'kubernetes-dashboards'
      orgId: 1
      folder: 'Kubernetes'
      type: file
      disableDeletion: false
      updateIntervalSeconds: 30
      options:
        path: /var/lib/grafana/dashboards/kubernetes
    - name: 'application-dashboards'
      orgId: 1
      folder: 'Applications'
      type: file
      disableDeletion: false
      updateIntervalSeconds: 30
      options:
        path: /var/lib/grafana/dashboards/applications
```

### Alerting and Notification Systems

Alerting systems monitor metrics and send notifications when predefined conditions are met. Prometheus Alertmanager handles alert routing, grouping, and delivery to various notification channels.

#### Prometheus Alerting Rules

**Example** comprehensive alerting rules:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kubernetes-alerts
  namespace: monitoring
spec:
  groups:
  - name: kubernetes.rules
    rules:
    - alert: KubernetesNodeReady
      expr: kube_node_status_condition{condition="Ready",status="true"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Kubernetes node not ready"
        description: "Node {{ $labels.node }} has been not ready for more than 5 minutes"
    
    - alert: KubernetesPodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is crash looping"
    
    - alert: KubernetesHighCPUUsage
      expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "Node {{ $labels.instance }} has CPU usage above 80% for more than 10 minutes"
    
    - alert: KubernetesHighMemoryUsage
      expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage detected"
        description: "Node {{ $labels.instance }} has memory usage above 85% for more than 10 minutes"
    
    - alert: KubernetesPodNotReady
      expr: kube_pod_status_ready{condition="false"} == 1
      for: 15m
      labels:
        severity: warning
      annotations:
        summary: "Pod not ready"
        description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} has been not ready for more than 15 minutes"
    
    - alert: KubernetesDeploymentReplicasMismatch
      expr: kube_deployment_spec_replicas != kube_deployment_status_available_replicas
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "Deployment replicas mismatch"
        description: "Deployment {{ $labels.deployment }} in namespace {{ $labels.namespace }} has {{ $value }} available replicas, expected {{ $labels.spec_replicas }}"
```

#### Alertmanager Configuration

**Example** Alertmanager configuration for multiple notification channels:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
      smtp_from: 'alerts@company.com'
      smtp_auth_username: 'alerts@company.com'
      smtp_auth_password: 'password'
    
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'default-receiver'
      routes:
      - match:
          severity: critical
        receiver: 'critical-receiver'
        group_wait: 5s
        repeat_interval: 30m
      - match:
          severity: warning
        receiver: 'warning-receiver'
        group_wait: 15s
        repeat_interval: 4h
    
    receivers:
    - name: 'default-receiver'
      slack_configs:
      - api_url: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'
        channel: '#alerts'
        title: 'Kubernetes Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
    
    - name: 'critical-receiver'
      email_configs:
      - to: 'oncall@company.com'
        subject: 'CRITICAL: Kubernetes Alert'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
      slack_configs:
      - api_url: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'
        channel: '#critical-alerts'
        title: 'CRITICAL: Kubernetes Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
      webhook_configs:
      - url: 'https://pagerduty.com/api/v1/alerts'
        send_resolved: true
    
    - name: 'warning-receiver'
      slack_configs:
      - api_url: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'
        channel: '#warnings'
        title: 'Warning: Kubernetes Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

#### Multi-Channel Notification Setup

**Example** PagerDuty integration configuration:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: pagerduty-config
  namespace: monitoring
type: Opaque
stringData:
  pagerduty.yml: |
    receivers:
    - name: 'pagerduty-critical'
      pagerduty_configs:
      - service_key: 'YOUR_PAGERDUTY_SERVICE_KEY'
        description: 'Critical Kubernetes Alert: {{ .GroupLabels.alertname }}'
        client: 'Kubernetes Alertmanager'
        client_url: 'https://grafana.company.com'
        details:
          alert_count: '{{ .Alerts | len }}'
          alerts: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

### Key Performance Indicators (KPIs)

Effective Kubernetes monitoring requires tracking specific KPIs that provide insights into cluster health, application performance, and resource utilization.

#### Infrastructure KPIs

**Cluster Health Metrics**:

- Node availability and readiness status
- API server response time and availability
- etcd performance and storage usage
- Control plane component health

**Resource Utilization Metrics**:

- CPU utilization per node and pod
- Memory usage and available memory
- Disk I/O and storage utilization
- Network throughput and packet loss

**Example** infrastructure KPI dashboard queries:

```promql
# Node availability percentage
(count(kube_node_status_condition{condition="Ready",status="true"}) / count(kube_node_status_condition{condition="Ready"})) * 100

# API server request rate
sum(rate(apiserver_request_total[5m])) by (verb, resource)

# API server request latency
histogram_quantile(0.95, sum(rate(apiserver_request_duration_seconds_bucket[5m])) by (verb, resource, le))

# etcd request latency
histogram_quantile(0.95, sum(rate(etcd_request_duration_seconds_bucket[5m])) by (operation, le))

# Cluster CPU utilization
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Cluster memory utilization
(1 - (sum(node_memory_MemAvailable_bytes) / sum(node_memory_MemTotal_bytes))) * 100
```

#### Application KPIs

**Performance Metrics**:

- Request rate and throughput
- Response time and latency percentiles
- Error rate and success rate
- Queue depth and processing time

**Availability Metrics**:

- Service uptime and availability
- Pod restart frequency
- Deployment rollout success rate
- Health check success rate

**Example** application KPI queries:

```promql
# Request rate per service
sum(rate(http_requests_total[5m])) by (service)

# 95th percentile response time
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (service, le))

# Error rate percentage
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100

# Service availability
up{job="kubernetes-pods"} * 100

# Pod restart rate
rate(kube_pod_container_status_restarts_total[1h])

# Deployment success rate
kube_deployment_status_replicas_available / kube_deployment_spec_replicas * 100
```

#### Business KPIs

**User Experience Metrics**:

- Page load time and user session duration
- Transaction success rate
- Feature adoption and usage metrics
- Customer satisfaction scores

**Operational Metrics**:

- Deployment frequency and lead time
- Mean time to recovery (MTTR)
- Change failure rate
- Service level objective (SLO) compliance

**Example** SLO configuration:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: slo-rules
  namespace: monitoring
spec:
  groups:
  - name: slo.rules
    rules:
    - record: slo:availability:rate5m
      expr: |
        sum(rate(http_requests_total{status!~"5.."}[5m])) /
        sum(rate(http_requests_total[5m]))
    
    - record: slo:latency:rate5m
      expr: |
        histogram_quantile(0.95,
          sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
        )
    
    - alert: SLOAvailabilityBreach
      expr: slo:availability:rate5m < 0.99
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "SLO availability breach"
        description: "Service availability is {{ $value | humanizePercentage }} which is below the 99% SLO"
```

#### Custom Metrics and Business Logic

**Example** custom metrics for business KPIs:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: business-metrics-exporter
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: business-metrics-exporter
  template:
    metadata:
      labels:
        app: business-metrics-exporter
    spec:
      containers:
      - name: exporter
        image: business-metrics-exporter:latest
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          value: "postgresql://user:password@database:5432/business"
        - name: METRICS_QUERIES
          value: |
            active_users:SELECT COUNT(*) FROM users WHERE last_active > NOW() - INTERVAL '5 minutes'
            orders_per_minute:SELECT COUNT(*) FROM orders WHERE created_at > NOW() - INTERVAL '1 minute'
            revenue_per_hour:SELECT SUM(total_amount) FROM orders WHERE created_at > NOW() - INTERVAL '1 hour'
```

### Advanced Monitoring Patterns

#### Multi-Cluster Monitoring

**Example** federated Prometheus setup:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-federation-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    
    scrape_configs:
    - job_name: 'federate'
      scrape_interval: 15s
      honor_labels: true
      metrics_path: '/federate'
      params:
        'match[]':
          - '{job=~"kubernetes-.*"}'
          - '{__name__=~"node_.*"}'
          - '{__name__=~"container_.*"}'
      static_configs:
      - targets:
        - 'cluster1-prometheus:9090'
        - 'cluster2-prometheus:9090'
        - 'cluster3-prometheus:9090'
```

#### Monitoring as Code

**Example** GitOps approach for monitoring configuration:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monitoring-stack
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/company/k8s-monitoring'
    targetRevision: HEAD
    path: monitoring
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: monitoring
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

**Key points**: A comprehensive Kubernetes monitoring stack requires careful planning of metrics collection, storage, visualization, and alerting components. Prometheus provides robust metrics collection and storage, while Grafana offers powerful visualization capabilities. Effective alerting depends on well-defined rules and proper routing to appropriate notification channels. Key performance indicators should cover infrastructure health, application performance, and business metrics to provide complete operational visibility.

The monitoring stack should be treated as infrastructure-as-code, with configurations stored in version control and deployed using GitOps practices. Regular review and optimization of dashboards, alerts, and KPIs ensure the monitoring system continues to provide value as the Kubernetes environment evolves.

---

