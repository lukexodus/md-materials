## Helm — Package Manager for Kubernetes


Helm is the standard package manager for Kubernetes. It bundles Kubernetes manifests into **charts**, manages versioning, and supports templating.

### Installation

```bash
brew install helm
```

### Core Concepts

- **Chart** — a package of pre-configured Kubernetes resources
- **Release** — a deployed instance of a chart
- **Repository** — a collection of charts
- **Values** — configuration inputs to a chart

### Common Commands

```bash
# Add a chart repository
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Search for charts
helm search repo nginx
helm search hub wordpress

# Install a chart
helm install my-release bitnami/nginx
helm install my-release bitnami/nginx --namespace my-ns --create-namespace

# Install with custom values
helm install my-release bitnami/nginx -f my-values.yaml
helm install my-release bitnami/nginx --set service.type=LoadBalancer

# List releases
helm list
helm list -A   # All namespaces

# Upgrade a release
helm upgrade my-release bitnami/nginx -f my-values.yaml

# Rollback
helm rollback my-release 1   # Rollback to revision 1

# Uninstall
helm uninstall my-release

# Inspect chart values
helm show values bitnami/nginx

# Render templates locally (dry run)
helm template my-release bitnami/nginx -f my-values.yaml
```

### Creating a Chart

```bash
helm create my-chart
```

Generated structure:

```
my-chart/
  Chart.yaml           # Chart metadata
  values.yaml          # Default configuration values
  templates/           # Kubernetes manifest templates
    deployment.yaml
    service.yaml
    ingress.yaml
    _helpers.tpl       # Template helper functions
  charts/              # Chart dependencies
```

### Template Example

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-chart.fullname" . }}
  labels:
    {{- include "my-chart.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.service.targetPort }}
```

---

