## DevOps Integration


### Container Management Scripts

Container management forms the backbone of modern DevOps workflows, with bash scripts serving as powerful automation tools for Docker, Podman, and Kubernetes operations. These scripts handle container lifecycle management, from building and deploying to monitoring and cleanup operations.

Docker container management scripts typically include image building automation, multi-stage build processes, and registry operations. Scripts can automate the creation of standardized base images, implement security scanning workflows, and manage image versioning strategies. Container orchestration scripts handle service discovery, load balancing configuration, and network management across distributed environments.

Kubernetes integration scripts manage pod deployments, service configurations, and resource scaling operations. These scripts often include kubectl wrapper functions, cluster health checks, and automated rollback mechanisms. Advanced container management involves implementing blue-green deployments, canary releases, and automated testing pipelines that validate container functionality before production deployment.

**Key points:**

- Automate Docker image builds with multi-stage processes and security scanning
- Implement Kubernetes deployment scripts with rollback capabilities
- Create container cleanup and resource optimization routines
- Develop service mesh configuration and management scripts

**Example:**

```bash
#!/bin/bash
deploy_container() {
    local image=$1
    local tag=$2
    local environment=$3
    
    # Build and tag image
    docker build -t "${image}:${tag}" .
    
    # Security scan
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy "${image}:${tag}"
    
    # Deploy based on environment
    case $environment in
        "prod")
            kubectl apply -f k8s/production/
            kubectl set image deployment/app app="${image}:${tag}"
            ;;
        "staging")
            kubectl apply -f k8s/staging/
            kubectl set image deployment/app app="${image}:${tag}"
            ;;
    esac
}
```

### Infrastructure as Code Helpers

Infrastructure as Code (IaC) helper scripts bridge the gap between bash automation and cloud infrastructure management tools like Terraform, Ansible, and CloudFormation. These scripts provide wrapper functions, validation mechanisms, and deployment orchestration that simplifies complex infrastructure operations.

Terraform helper scripts manage state file operations, workspace switching, and plan validation processes. Scripts can implement automated terraform plan reviews, cost estimation calculations, and compliance checks before applying infrastructure changes. Advanced helpers include drift detection mechanisms that compare actual infrastructure state against defined configurations.

Ansible integration scripts handle inventory management, playbook execution, and variable templating across multiple environments. These scripts often include vault operations for secrets management, dynamic inventory generation from cloud providers, and parallel execution coordination for large-scale deployments.

CloudFormation and ARM template helpers manage stack operations, parameter validation, and cross-stack dependency resolution. Scripts can implement stack update strategies, rollback procedures, and resource tagging automation that ensures consistent infrastructure governance.

**Key points:**

- Create Terraform wrapper scripts with state management and validation
- Implement Ansible orchestration with dynamic inventory and secrets handling
- Develop CloudFormation stack management with dependency resolution
- Build infrastructure testing and compliance validation scripts

**Example:**

```bash
#!/bin/bash
terraform_deploy() {
    local environment=$1
    local workspace=$2
    
    # Switch workspace
    terraform workspace select "$workspace" || terraform workspace new "$workspace"
    
    # Validate configuration
    terraform validate || exit 1
    
    # Generate and review plan
    terraform plan -var-file="environments/${environment}.tfvars" -out=tfplan
    
    # Cost estimation (if tools available)
    if command -v infracost &> /dev/null; then
        infracost breakdown --path . --terraform-plan-path tfplan
    fi
    
    # Apply with approval
    read -p "Apply changes? (y/N): " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply tfplan
    fi
}
```

### Monitoring and Alerting Systems

Monitoring and alerting scripts create comprehensive observability solutions that track system health, application performance, and business metrics. These scripts integrate with monitoring platforms like Prometheus, Grafana, Datadog, and custom logging solutions to provide real-time insights and automated incident response.

System monitoring scripts collect metrics on CPU usage, memory consumption, disk space, and network performance. Advanced monitoring includes application-specific metrics, database performance indicators, and custom business logic measurements. Scripts can implement threshold-based alerting, anomaly detection algorithms, and predictive failure analysis.

Log aggregation and analysis scripts parse application logs, system logs, and security audit trails to identify patterns, errors, and security incidents. These scripts often include real-time log streaming, pattern matching with regular expressions, and automated log rotation management.

Alerting system scripts manage notification routing, escalation procedures, and incident documentation. Integration with communication platforms like Slack, PagerDuty, and email systems ensures rapid response to critical issues. Advanced alerting includes intelligent noise reduction, correlation analysis, and automated remediation triggers.

**Key points:**

- Implement comprehensive system and application monitoring with custom metrics
- Create intelligent alerting with threshold management and escalation procedures
- Develop log aggregation and analysis with pattern recognition
- Build automated incident response and documentation systems

**Example:**

```bash
#!/bin/bash
monitor_system() {
    local threshold_cpu=80
    local threshold_memory=85
    local threshold_disk=90
    
    # CPU monitoring
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    if (( $(echo "$cpu_usage > $threshold_cpu" | bc -l) )); then
        send_alert "HIGH_CPU" "CPU usage at ${cpu_usage}%"
    fi
    
    # Memory monitoring
    memory_usage=$(free | grep Mem | awk '{printf("%.1f"), ($3/$2) * 100.0}')
    if (( $(echo "$memory_usage > $threshold_memory" | bc -l) )); then
        send_alert "HIGH_MEMORY" "Memory usage at ${memory_usage}%"
    fi
    
    # Disk monitoring
    while IFS= read -r line; do
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        mount=$(echo "$line" | awk '{print $6}')
        if [[ $usage -gt $threshold_disk ]]; then
            send_alert "HIGH_DISK" "Disk usage at ${usage}% on ${mount}"
        fi
    done < <(df -h | grep -vE '^Filesystem|tmpfs|cdrom')
}

send_alert() {
    local severity=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log alert
    echo "[$timestamp] $severity: $message" >> /var/log/monitoring.log
    
    # Send to Slack
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"🚨 $severity: $message\"}" \
        "$SLACK_WEBHOOK_URL"
}
```

### Deployment Automation

Deployment automation scripts orchestrate the entire software delivery pipeline, from code integration to production deployment. These scripts implement continuous integration and continuous deployment (CI/CD) practices, ensuring reliable, repeatable, and fast software releases.

CI/CD pipeline scripts manage source code checkout, dependency installation, automated testing, and artifact generation. Advanced pipelines include parallel test execution, code quality analysis, security vulnerability scanning, and performance benchmarking. Integration with version control systems enables automated triggering based on git hooks, pull requests, and release tags.

Blue-green and canary deployment scripts minimize downtime and reduce deployment risks through sophisticated traffic routing and health checking mechanisms. These scripts manage load balancer configurations, database migration coordination, and automated rollback procedures when issues are detected.

Multi-environment deployment scripts handle the complexities of promoting code through development, staging, and production environments. Scripts manage environment-specific configurations, secrets management, and compliance requirements while maintaining deployment consistency across all stages.

Database deployment scripts coordinate schema migrations, data transformations, and backup procedures. Advanced database deployment includes zero-downtime migration strategies, data validation procedures, and automated rollback capabilities for both schema and data changes.

**Key points:**

- Create comprehensive CI/CD pipelines with automated testing and quality gates
- Implement zero-downtime deployment strategies with automated rollback
- Develop multi-environment promotion with configuration management
- Build database deployment automation with migration and backup coordination

**Example:**

```bash
#!/bin/bash
deploy_application() {
    local version=$1
    local environment=$2
    local strategy=${3:-"rolling"}
    
    # Pre-deployment checks
    check_dependencies() {
        local deps=("kubectl" "docker" "curl")
        for dep in "${deps[@]}"; do
            command -v "$dep" >/dev/null 2>&1 || {
                echo "Error: $dep is required but not installed."
                exit 1
            }
        done
    }
    
    # Health check function
    health_check() {
        local endpoint=$1
        local max_attempts=30
        local attempt=1
        
        while [[ $attempt -le $max_attempts ]]; do
            if curl -f "$endpoint/health" >/dev/null 2>&1; then
                echo "Health check passed"
                return 0
            fi
            echo "Health check attempt $attempt failed, retrying..."
            sleep 10
            ((attempt++))
        done
        return 1
    }
    
    # Deployment strategy execution
    case $strategy in
        "blue-green")
            # Deploy to inactive environment
            kubectl apply -f "k8s/${environment}/blue-green/"
            kubectl set image deployment/app-green app="myapp:${version}"
            
            # Wait for rollout and health check
            kubectl rollout status deployment/app-green
            if health_check "http://green.${environment}.example.com"; then
                # Switch traffic
                kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'
                echo "Blue-green deployment successful"
            else
                echo "Health check failed, keeping current version"
                exit 1
            fi
            ;;
        "canary")
            # Deploy canary version
            kubectl apply -f "k8s/${environment}/canary/"
            kubectl set image deployment/app-canary app="myapp:${version}"
            
            # Gradual traffic increase
            for traffic in 10 25 50 75 100; do
                kubectl patch virtualservice app-vs --type merge -p "{\"spec\":{\"http\":[{\"route\":[{\"destination\":{\"host\":\"app-canary\"},\"weight\":${traffic}},{\"destination\":{\"host\":\"app-stable\"},\"weight\":$((100-traffic))}]}]}}"
                sleep 300  # Wait 5 minutes
                
                # Check metrics and error rates
                if ! check_canary_metrics; then
                    echo "Canary metrics failed, rolling back"
                    kubectl patch virtualservice app-vs --type merge -p '{"spec":{"http":[{"route":[{"destination":{"host":"app-stable"},"weight":100}]}]}}'
                    exit 1
                fi
            done
            ;;
    esac
    
    # Post-deployment tasks
    update_monitoring_dashboards "$version"
    send_deployment_notification "$version" "$environment" "SUCCESS"
}

check_canary_metrics() {
    # Query Prometheus for error rates and latency
    local error_rate=$(curl -s "http://prometheus:9090/api/v1/query?query=rate(http_requests_total{job=\"app-canary\",status=~\"5..\"}[5m])" | jq -r '.data.result[0].value[1]')
    local p95_latency=$(curl -s "http://prometheus:9090/api/v1/query?query=histogram_quantile(0.95,rate(http_request_duration_seconds_bucket{job=\"app-canary\"}[5m]))" | jq -r '.data.result[0].value[1]')
    
    # Define thresholds
    if (( $(echo "$error_rate > 0.01" | bc -l) )); then
        echo "Error rate too high: $error_rate"
        return 1
    fi
    
    if (( $(echo "$p95_latency > 0.5" | bc -l) )); then
        echo "Latency too high: $p95_latency"
        return 1
    fi
    
    return 0
}
```

**Conclusion:** DevOps integration through bash scripting provides the automation foundation that enables reliable, scalable, and efficient software delivery. These scripts bridge the gap between development and operations teams, creating standardized processes that reduce manual errors and increase deployment velocity.

**Next steps:** Consider exploring advanced topics like GitOps workflows, service mesh automation, chaos engineering scripts, and observability automation to further enhance your DevOps capabilities.

---

