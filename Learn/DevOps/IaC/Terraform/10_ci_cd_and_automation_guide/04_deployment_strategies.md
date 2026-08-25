## Deployment Strategies


### Blue-Green Deployment

**Infrastructure Setup**

```hcl
# blue-green.tf
resource "aws_launch_template" "blue" {
  count = var.active_environment == "blue" ? 1 : 0
  # Blue environment configuration
}

resource "aws_launch_template" "green" {
  count = var.active_environment == "green" ? 1 : 0
  # Green environment configuration
}

resource "aws_lb_target_group" "active" {
  name = "${var.environment}-active-tg"
  # Points to active environment
}

resource "aws_lb_target_group" "staging" {
  name = "${var.environment}-staging-tg"
  # Points to staging environment
}
```

**Deployment Process**

```bash
#!/bin/bash
# blue-green-deploy.sh

CURRENT_ENV=$(terraform output current_environment)
NEW_ENV=$([ "$CURRENT_ENV" = "blue" ] && echo "green" || echo "blue")

# Deploy to inactive environment
terraform apply -var="deploy_environment=$NEW_ENV"

# Health checks
./health-check.sh $NEW_ENV

# Switch traffic
terraform apply -var="active_environment=$NEW_ENV"

# Cleanup old environment
terraform apply -var="cleanup_environment=$CURRENT_ENV"
```

### Canary Deployment

**Traffic Splitting**

```hcl
# canary.tf
resource "aws_lb_listener_rule" "canary" {
  count = var.canary_enabled ? 1 : 0
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.canary.arn
    weight           = var.canary_weight # Start with 5-10%
  }
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.production.arn
    weight           = 100 - var.canary_weight
  }
}
```

**Gradual Rollout**

```yaml
# canary-pipeline.yml
stages:
  - name: Deploy Canary (5%)
    terraform_vars:
      canary_weight: 5
  
  - name: Monitor Metrics
    run: ./monitor-canary.sh
    duration: 30m
  
  - name: Increase Traffic (25%)
    terraform_vars:
      canary_weight: 25
  
  - name: Full Rollout (100%)
    terraform_vars:
      canary_weight: 100
      canary_enabled: false
```

