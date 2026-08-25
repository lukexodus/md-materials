## Infrastructure Automation Patterns


### Event-Driven Infrastructure

```hcl
# event-driven-infrastructure.tf
# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "infrastructure_change" {
  name        = "${var.environment}-infra-change"
  description = "Trigger infrastructure changes"
  
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["terminated"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.infrastructure_change.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.infrastructure_handler.arn
}

# Lambda function for infrastructure automation
resource "aws_lambda_function" "infrastructure_handler" {
  filename         = "infrastructure_handler.zip"
  function_name    = "${var.environment}-infra-handler"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  
  environment {
    variables = {
      TERRAFORM_WORKSPACE = var.environment
      S3_BUCKET          = aws_s3_bucket.terraform_state.bucket
    }
  }
}
```

### Auto-Scaling Infrastructure Patterns

```hcl
# auto-scaling-patterns.tf
# Predictive Scaling with CloudWatch
resource "aws_autoscaling_policy" "predictive" {
  name                   = "${var.environment}-predictive-scaling"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
  
  predictive_scaling_configuration {
    metric_specifications {
      target_value = 70.0
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
    }
    mode                         = "ForecastAndScale"
    scheduling_buffer_time       = 300
    max_capacity_breach_behavior = "HonorMaxCapacity"
    max_capacity_buffer          = 10
  }
}

# Custom Metrics Auto Scaling
resource "aws_cloudwatch_metric_alarm" "custom_scale_up" {
  alarm_name          = "${var.environment}-custom-scale-up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "QueueDepth"
  namespace           = "Custom/Application"
  period              = "60"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "This metric monitors queue depth"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
}
```

### Infrastructure State Machine

```hcl
# infrastructure-state-machine.tf
resource "aws_sfn_state_machine" "infrastructure_deployment" {
  name     = "${var.environment}-infra-deployment"
  role_arn = aws_iam_role.step_function_role.arn
  
  definition = jsonencode({
    Comment = "Infrastructure deployment state machine"
    StartAt = "ValidateConfiguration"
    States = {
      ValidateConfiguration = {
        Type     = "Task"
        Resource = aws_lambda_function.validate_config.arn
        Next     = "PlanInfrastructure"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "HandleError"
        }]
      }
      PlanInfrastructure = {
        Type     = "Task"
        Resource = aws_lambda_function.terraform_plan.arn
        Next     = "ApprovalRequired"
      }
      ApprovalRequired = {
        Type = "Choice"
        Choices = [{
          Variable      = "$.requiresApproval"
          BooleanEquals = true
          Next          = "WaitForApproval"
        }]
        Default = "ApplyInfrastructure"
      }
      WaitForApproval = {
        Type = "Wait"
        Seconds = 3600
        Next = "ApplyInfrastructure"
      }
      ApplyInfrastructure = {
        Type     = "Task"
        Resource = aws_lambda_function.terraform_apply.arn
        End      = true
      }
      HandleError = {
        Type = "Task"
        Resource = aws_lambda_function.error_handler.arn
        End = true
      }
    }
  })
}
```

