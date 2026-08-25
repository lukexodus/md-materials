## DevOps Integration on Linux


### CI/CD Concepts

Continuous Integration and Continuous Deployment (CI/CD) represents a methodology for automating software development workflows, from code integration through production deployment. These practices enable rapid, reliable software delivery while maintaining quality standards.

**Key Points:**

- Continuous Integration merges code changes frequently with automated testing
- Continuous Deployment automates the release process to production environments
- CI/CD pipelines reduce manual errors and deployment time
- Infrastructure as Code (IaC) treats infrastructure configuration as versioned code

**Continuous Integration Fundamentals:** CI focuses on integrating code changes from multiple developers into a shared repository frequently, typically multiple times per day. Each integration triggers automated builds and tests to detect issues early.

**Essential CI practices:**

- Automated build processes that compile and package applications
- Comprehensive test suites including unit, integration, and functional tests
- Code quality checks through static analysis and linting
- Artifact generation for deployment stages
- Notification systems for build status and failures

**Continuous Deployment Pipeline Stages:**

1. **Source**: Code committed to version control triggers pipeline
2. **Build**: Application compilation and dependency resolution
3. **Test**: Automated testing across multiple levels
4. **Package**: Creation of deployable artifacts
5. **Deploy**: Automated deployment to target environments
6. **Monitor**: Post-deployment validation and monitoring

**Pipeline Configuration Example (GitLab CI):**

```yaml
stages:
  - build
  - test
  - package
  - deploy

variables:
  DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

build:
  stage: build
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - dist/

test:
  stage: test
  script:
    - npm run test:unit
    - npm run test:integration
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'

package:
  stage: package
  script:
    - docker build -t $DOCKER_IMAGE .
    - docker push $DOCKER_IMAGE

deploy:
  stage: deploy
  script:
    - kubectl set image deployment/app app=$DOCKER_IMAGE
    - kubectl rollout status deployment/app
  only:
    - main
```

**Environment Management:**

- **Development**: Immediate deployment for feature testing
- **Staging**: Production-like environment for integration testing
- **Production**: Live environment with careful deployment strategies

**Deployment Strategies:**

- **Blue-Green**: Maintain two identical production environments, switching between them
- **Rolling**: Gradual replacement of instances with new versions
- **Canary**: Limited release to subset of users before full deployment
- **Feature Flags**: Control feature visibility without code deployment

### Version Control with Git

Git serves as the foundational tool for version control in DevOps workflows, providing distributed version control capabilities that enable collaborative development and change tracking.

**Key Points:**

- Git uses a distributed model where each repository contains complete history
- Branching strategies determine how teams organize development work
- Remote repositories enable collaboration and serve as pipeline triggers
- Git hooks provide automation points for quality checks and deployments

**Git Workflow Models:**

**GitFlow Model:**

```bash
# Main branches
git checkout main        # Production-ready code
git checkout develop     # Integration branch for features

# Feature development
git checkout -b feature/user-authentication develop
# Development work
git checkout develop
git merge --no-ff feature/user-authentication

# Release preparation
git checkout -b release/1.2.0 develop
# Bug fixes and version updates
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
```

**GitHub Flow (Simplified):**

```bash
# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/api-endpoints

# Development and commits
git add .
git commit -m "Add user API endpoints"
git push origin feature/api-endpoints

# Pull request and merge to main
# Deploy from main branch
```

**Advanced Git Operations for DevOps:**

**Interactive Rebase for Clean History:**

```bash
git rebase -i HEAD~3  # Rebase last 3 commits
# Options: pick, reword, edit, squash, fixup, drop
```

**Git Hooks for Automation:**

```bash
# Pre-commit hook (.git/hooks/pre-commit)
#!/bin/bash
npm run lint
npm run test:unit
if [ $? -ne 0 ]; then
  echo "Tests failed. Commit aborted."
  exit 1
fi
```

**Submodules for Dependencies:**

```bash
git submodule add https://github.com/example/library.git libs/library
git submodule update --init --recursive
```

**Git Configuration for Teams:**

```bash
# Global configuration
git config --global user.name "DevOps Team"
git config --global user.email "devops@company.com"
git config --global core.autocrlf input
git config --global pull.rebase true

# Repository-specific configuration
git config core.hooksPath .githooks
```

**Branch Protection and Policies:** Most Git platforms support branch protection rules:

- Require pull request reviews before merging
- Require status checks to pass (CI pipeline success)
- Require up-to-date branches before merging
- Restrict who can push to protected branches
- Require signed commits for security

### Pipeline Automation

Pipeline automation orchestrates the entire software delivery process, from code commit to production deployment, using various tools and platforms to ensure consistent, reliable deployments.

**Key Points:**

- Pipeline-as-Code defines build and deployment processes in version-controlled files
- Parallel execution reduces pipeline duration
- Conditional logic enables different paths based on branch, environment, or conditions
- Artifact management ensures consistent deployments across environments

**Jenkins Pipeline Example:**

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'registry.company.com'
        APP_NAME = 'web-application'
        KUBECONFIG = credentials('kubernetes-config')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/company/app.git'
            }
        }
        
        stage('Build') {
            parallel {
                stage('Compile') {
                    steps {
                        sh 'mvn clean compile'
                    }
                }
                stage('Frontend Build') {
                    steps {
                        sh 'npm ci && npm run build'
                    }
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'mvn test'
                        publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                    }
                }
                stage('Security Scan') {
                    steps {
                        sh 'npm audit --audit-level moderate'
                    }
                }
            }
        }
        
        stage('Package') {
            steps {
                script {
                    def image = docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}")
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'registry-credentials') {
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh """
                        helm upgrade --install ${APP_NAME} ./helm-chart \
                        --set image.tag=${BUILD_NUMBER} \
                        --set image.repository=${DOCKER_REGISTRY}/${APP_NAME} \
                        --namespace production
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            emailext (
                subject: "Pipeline Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output at ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

**GitHub Actions Workflow:**

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14, 16, 18]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test -- --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v3
      with:
        context: .
        push: true
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
    
    - name: Deploy to Kubernetes
      uses: azure/k8s-deploy@v1
      with:
        manifests: |
          k8s/deployment.yaml
          k8s/service.yaml
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
```

**Infrastructure as Code Integration:**

```yaml
# Terraform pipeline stage
terraform-plan:
  stage: infrastructure
  script:
    - terraform init
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - tfplan

terraform-apply:
  stage: infrastructure
  script:
    - terraform apply -auto-approve tfplan
  when: manual
  only:
    - main
```

**Pipeline Optimization Strategies:**

- **Caching**: Store dependencies and build artifacts between runs
- **Parallel Execution**: Run independent tasks simultaneously
- **Conditional Stages**: Skip unnecessary steps based on changes
- **Pipeline Templates**: Reuse common pipeline configurations
- **Matrix Builds**: Test across multiple environments simultaneously

### Monitoring Integration

Monitoring integration within DevOps pipelines ensures system health, performance tracking, and rapid incident response through automated observability and alerting mechanisms.

**Key Points:**

- Observability encompasses metrics, logs, and distributed tracing
- Infrastructure monitoring tracks system resources and service health
- Application Performance Monitoring (APM) provides insights into application behavior
- Alerting systems notify teams of issues requiring immediate attention

**Monitoring Stack Components:**

**Metrics Collection and Storage:** Prometheus serves as a popular metrics collection system with time-series database capabilities:

```yaml
# prometheus.yml configuration
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

**Application Metrics Instrumentation:**

```python
# Python application with Prometheus metrics
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time

REQUEST_COUNT = Counter('app_requests_total', 'Total requests', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('app_request_duration_seconds', 'Request latency')
ACTIVE_CONNECTIONS = Gauge('app_active_connections', 'Active connections')

@REQUEST_LATENCY.time()
def process_request(method, endpoint):
    REQUEST_COUNT.labels(method=method, endpoint=endpoint).inc()
    # Application logic here
    time.sleep(0.1)  # Simulated processing time

# Start metrics server
start_http_server(8000)
```

**Log Aggregation with ELK Stack:**

**Filebeat configuration:**

```yaml
filebeat.inputs:
- type: log
  paths:
    - /var/log/application/*.log
  fields:
    service: web-app
    environment: production
  fields_under_root: true

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "application-logs-%{+yyyy.MM.dd}"

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
```

**Logstash pipeline configuration:**

```ruby
input {
  beats {
    port => 5044
  }
}

filter {
  if [service] == "web-app" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{DATA:logger} - %{GREEDYDATA:message}" }
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    mutate {
      remove_field => [ "@version", "beat", "input_type", "offset" ]
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logstash-application-%{+YYYY.MM.dd}"
  }
}
```

**Distributed Tracing Integration:**

```yaml
# Jaeger deployment configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:latest
        ports:
        - containerPort: 16686
        - containerPort: 14268
        env:
        - name: COLLECTOR_ZIPKIN_HTTP_PORT
          value: "9411"
```

**Application tracing instrumentation:**

```javascript
// Node.js application with OpenTelemetry
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');

const jaegerExporter = new JaegerExporter({
  endpoint: 'http://jaeger:14268/api/traces',
});

const sdk = new NodeSDK({
  traceExporter: jaegerExporter,
  instrumentations: [getNodeAutoInstrumentations()]
});

sdk.start();
```

**Alert Rules and Notification:**

```yaml
# Prometheus alert rules
groups:
- name: application-alerts
  rules:
  - alert: HighErrorRate
    expr: rate(app_requests_total{status=~"5.."}[5m]) > 0.1
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value }} errors per second"

  - alert: HighLatency
    expr: histogram_quantile(0.95, rate(app_request_duration_seconds_bucket[5m])) > 1
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "High latency detected"
      description: "95th percentile latency is {{ $value }} seconds"

  - alert: ServiceDown
    expr: up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Service is down"
      description: "{{ $labels.instance }} has been down for more than 1 minute"
```

**Alertmanager configuration:**

```yaml
global:
  smtp_smarthost: 'mail.company.com:587'
  smtp_from: 'alerts@company.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
  routes:
  - match:
      severity: critical
    receiver: 'critical-alerts'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://slack-webhook/webhook'

- name: 'critical-alerts'
  email_configs:
  - to: 'oncall@company.com'
    subject: 'Critical Alert: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      Alert: {{ .Annotations.summary }}
      Description: {{ .Annotations.description }}
      {{ end }}
  pagerduty_configs:
  - service_key: 'your-pagerduty-service-key'
```

**Grafana Dashboard Configuration:**

```json
{
  "dashboard": {
    "title": "Application Monitoring",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(app_requests_total[5m])",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "singlestat",
        "targets": [
          {
            "expr": "rate(app_requests_total{status=~\"5..\"}[5m]) / rate(app_requests_total[5m]) * 100"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(app_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      }
    ]
  }
}
```

**CI/CD Pipeline Monitoring Integration:**

```yaml
# GitLab CI with monitoring integration
deploy:
  stage: deploy
  script:
    - kubectl apply -f k8s/
    - kubectl rollout status deployment/app
  after_script:
    # Create deployment annotation in Grafana
    - |
      curl -X POST "http://grafana:3000/api/annotations" \
        -H "Authorization: Bearer $GRAFANA_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
          "text": "Deployment completed",
          "tags": ["deployment", "production"],
          "time": '$(date +%s000)'
        }'
```

**Synthetic Monitoring:**

```yaml
# Prometheus blackbox exporter configuration
modules:
  http_2xx:
    prober: http
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
      valid_status_codes: [200]
      method: GET
      follow_redirects: true

# Prometheus configuration for synthetic monitoring
- job_name: 'blackbox'
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
      - https://api.company.com/health
      - https://app.company.com
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: blackbox-exporter:9115
```

**Security Monitoring Integration:**

```yaml
# Falco rules for runtime security monitoring
- rule: Suspicious Network Activity
  desc: Detect suspicious network connections
  condition: >
    spawned_process and
    (proc.name in (nc, ncat, netcat) or
     proc.cmdline contains "bash -i" or
     proc.cmdline contains "/dev/tcp")
  output: >
    Suspicious network activity detected
    (user=%user.name command=%proc.cmdline container=%container.name)
  priority: WARNING
```

**Performance Testing Integration:**

```yaml
# K6 performance testing in pipeline
performance-test:
  stage: test
  script:
    - k6 run --out influxdb=http://influxdb:8086/k6 performance-test.js
  artifacts:
    reports:
      performance: performance-report.json
```

Regular monitoring assessment should include reviewing alert effectiveness, dashboard relevance, and metric accuracy. Teams should establish Service Level Objectives (SLOs) and Service Level Indicators (SLIs) to measure system reliability and user experience systematically.

---

