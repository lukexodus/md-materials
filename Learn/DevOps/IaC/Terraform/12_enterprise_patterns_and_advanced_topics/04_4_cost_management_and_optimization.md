## 4. Cost Management and Optimization


### Cost Estimation and Budgets

#### Terraform Cloud Cost Estimation

```hcl
# Workspace with cost estimation enabled
resource "tfe_workspace" "cost_monitored" {
  name         = "cost-monitored-workspace"
  organization = var.tfe_organization
  
  # Enable cost estimation
  structured_run_output_enabled = true
  
  # Cost estimation settings (Enterprise feature)
  cost_estimation_enabled = true
}

# AWS Budget integration
resource "aws_budgets_budget" "terraform_monthly" {
  name         = "terraform-monthly-budget"
  budget_type  = "COST"
  limit_amount = "1000"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  cost_filters = {
    Tag = {
      "ManagedBy" = ["Terraform"]
    }
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = [var.budget_alert_email]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_alert_email]
  }
}
```

### Resource Right-Sizing

#### Auto-Scaling Policies

```hcl
# CloudWatch-based auto-scaling
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
  
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}
```

#### Spot Instance Integration

```hcl
# Mixed instance policy for cost optimization
resource "aws_autoscaling_group" "cost_optimized" {
  name                = "cost-optimized-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type   = "ELB"
  
  min_size         = 2
  max_size         = 10
  desired_capacity = 4
  
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.main.id
        version           = "$Latest"
      }
      
      override {
        instance_type     = "t3.medium"
        weighted_capacity = "1"
      }
      
      override {
        instance_type     = "t3.large"
        weighted_capacity = "2"
      }
    }
    
    instances_distribution {
      on_demand_base_capacity                  = 2
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }
  
  tag {
    key                 = "Name"
    value               = "cost-optimized-instance"
    propagate_at_launch = true
  }
}
```

### Cost Allocation and Tracking

#### Detailed Cost Tagging

```hcl
# Cost allocation tags module
module "cost_allocation_tags" {
  source = "./modules/cost-allocation-tags"
  
  # Cost center mapping
  cost_centers = {
    "engineering" = "CC001"
    "marketing"   = "CC002"
    "sales"       = "CC003"
  }
  
  # Project codes
  project_codes = {
    "web-app"     = "PRJ001"
    "mobile-app"  = "PRJ002"
    "data-platform" = "PRJ003"
  }
  
  # Environment
  environment = var.environment
  
  # Additional metadata
  additional_tags = {
    BusinessUnit = var.business_unit
    Application  = var.application_name
    Owner        = var.owner
  }
}

# Apply tags to resources
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = merge(
    module.cost_allocation_tags.tags,
    {
      Name = "app-server-${var.environment}"
      Role = "application"
    }
  )
}
```

