## 7. Audit Logging and Monitoring


### Terraform Cloud Audit Logs

- All API operations logged
- Plan and apply execution records
- State file access tracking
- User authentication events
- Policy evaluation results

### Cloud Provider Integration

#### AWS CloudTrail

```hcl
resource "aws_cloudtrail" "terraform_audit" {
  name           = "terraform-audit-trail"
  s3_bucket_name = aws_s3_bucket.audit_logs.bucket
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.terraform_state.arn}/*"]
    }
  }
  
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
}
```

#### Azure Activity Log Integration

```hcl
resource "azurerm_monitor_activity_log_alert" "terraform_changes" {
  name                = "terraform-resource-changes"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_resource_group.main.id]
  
  criteria {
    resource_provider = "Microsoft.Resources"
    operation_name    = "Microsoft.Resources/deployments/write"
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}
```

### Monitoring and Alerting

```hcl
# CloudWatch alarms for Terraform operations
resource "aws_cloudwatch_metric_alarm" "terraform_failures" {
  alarm_name          = "terraform-apply-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors terraform apply failures"
  
  dimensions = {
    FunctionName = aws_lambda_function.terraform_runner.function_name
  }
}
```

### Compliance Reporting

```hcl
# Generate compliance reports
data "aws_caller_identity" "current" {}

locals {
  compliance_report = {
    account_id        = data.aws_caller_identity.current.account_id
    terraform_version = "1.5.0"
    last_scan_date   = timestamp()
    policy_violations = []
    encrypted_resources = [
      # List of encrypted resources
    ]
  }
}

resource "local_file" "compliance_report" {
  content  = jsonencode(local.compliance_report)
  filename = "compliance-report-${formatdate("YYYY-MM-DD", timestamp())}.json"
}
```

