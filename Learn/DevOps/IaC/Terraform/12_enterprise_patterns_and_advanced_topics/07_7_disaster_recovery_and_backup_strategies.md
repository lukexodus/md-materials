## 7. Disaster Recovery and Backup Strategies


### State Backup and Recovery

#### Automated State Backup

```hcl
# Lambda function for state backup
resource "aws_lambda_function" "state_backup" {
  filename      = "state_backup.zip"
  function_name = "terraform-state-backup"
  role          = aws_iam_role.lambda_backup.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 300
  
  environment {
    variables = {
      BACKUP_BUCKET = aws_s3_bucket.state_backups.bucket
      SOURCE_BUCKET = aws_s3_bucket.terraform_state.bucket
    }
  }
  
  tags = {
    Name    = "Terraform State Backup"
    Purpose = "DisasterRecovery"
  }
}

# CloudWatch event rule for scheduled backups
resource "aws_cloudwatch_event_rule" "state_backup_schedule" {
  name                = "terraform-state-backup-schedule"
  description         = "Trigger state backup every 6 hours"
  schedule_expression = "rate(6 hours)"
}

resource "aws_cloudwatch_event_target" "state_backup_target" {
  rule      = aws_cloudwatch_event_rule.state_backup_schedule.name
  target_id = "TerraformStateBackupTarget"
  arn       = aws_lambda_function.state_backup.arn
}

# Cross-region backup bucket
resource "aws_s3_bucket" "state_backups" {
  bucket = "terraform-state-backups-${random_id.backup_suffix.hex}"
  
  tags = {
    Name    = "Terraform State Backups"
    Purpose = "DisasterRecovery"
  }
}

resource "aws_s3_bucket_replication_configuration" "state_backup_replication" {
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.state_backups.id
  
  rule {
    id     = "replicate-state-backups"
    status = "Enabled"
    
    destination {
      bucket        = aws_s3_bucket.dr_backups.arn
      storage_class = "STANDARD_IA"
    }
  }
  
  depends_on = [aws_s3_bucket_versioning.state_backups]
}
```

#### Cross-Region Disaster Recovery

```hcl
# DR region provider
provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

# DR state bucket
resource "aws_s3_bucket" "terraform_state_dr" {
  provider = aws.dr
  bucket   = "terraform-state-dr-${var.environment}-${random_id.dr_suffix.hex}"
  
  tags = {
    Name        = "Terraform State DR"
    Environment = var.environment
    Purpose     = "DisasterRecovery"
  }
}

# Cross-region replication
resource "aws_s3_bucket_replication_configuration" "state_dr_replication" {
  role   = aws_iam_role.state_replication.arn
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    id     = "replicate-to-dr"
    status = "Enabled"
    
    destination {
      bucket             = aws_s3_bucket.terraform_state_dr.arn
      storage_class      = "STANDARD_IA"
      replica_kms_key_id = aws_kms_key.terraform_state_dr.arn
    }
  }
}

# DR DynamoDB table
resource "aws_dynamodb_table" "terraform_locks_dr" {
  provider     = aws.dr
  name         = "terraform-locks-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  global_table {
    region = var.primary_region
  }
  
  tags = {
    Name        = "Terraform State Locks DR"
    Environment = var.environment
    Purpose     = "DisasterRecovery"
  }
}
```

### Infrastructure Recovery Automation

#### Recovery Runbooks

```hcl
# Systems Manager document for recovery procedures
resource "aws_ssm_document" "disaster_recovery_runbook" {
  name          = "TerraformDisasterRecovery"
  document_type = "Automation"
  document_format = "YAML"
  
  content = yamlencode({
    schemaVersion = "0.3"
    description   = "Terraform infrastructure disaster recovery procedures"
    assumeRole    = aws_iam_role.ssm_automation.arn
    
    parameters = {
      Environment = {
        type        = "String"
        description = "Environment to recover"
      }
      BackupTimestamp = {
        type        = "String"
        description = "Backup timestamp to restore from"
      }
    }
    
    mainSteps = [
      {
        name   = "ValidateBackup"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "headObject"
          Bucket  = aws_s3_bucket.state_backups.bucket
          Key     = "{{Environment}}/{{BackupTimestamp}}/terraform.tfstate"
        }
      },
      {
        name   = "RestoreState"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "copyObject"
          Bucket  = aws_s3_bucket.terraform_state.bucket
          Key     = "terraform.tfstate"
          CopySource = "${aws_s3_bucket.state_backups.bucket}/{{Environment}}/{{BackupTimestamp}}/terraform.tfstate"
        }
      },
      {
        name   = "NotifyRecoveryComplete"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "sns"
          Api     = "publish"
          TopicArn = aws_sns_topic.disaster_recovery.arn
          Message  = "Terraform state recovery completed for {{Environment}}"
        }
      }
    ]
  })
  
  tags = {
    Name    = "Terraform DR Runbook"
    Purpose = "DisasterRecovery"
  }
}

# SNS topic for DR notifications
resource "aws_sns_topic" "disaster_recovery" {
  name = "terraform-disaster-recovery"
  
  tags = {
    Name    = "Terraform DR Notifications"
    Purpose = "DisasterRecovery"
  }
}
```

#### Multi-Cloud Backup Strategy

```hcl
# Azure backup for AWS Terraform state
resource "azurerm_storage_account" "terraform_backup" {
  name                     = "tfstatebackup${random_string.backup_suffix.result}"
  resource_group_name      = azurerm_resource_group.backup.name
  location                 = var.azure_region
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 90
    }
  }
  
  tags = {
    Purpose = "TerraformStateBackup"
    Source  = "AWS"
  }
}

# Cross-cloud backup function
resource "aws_lambda_function" "cross_cloud_backup" {
  filename      = "cross_cloud_backup.zip"
  function_name = "terraform-cross-cloud-backup"
  role          = aws_iam_role.cross_cloud_backup.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 600
  
  environment {
    variables = {
      AZURE_STORAGE_ACCOUNT = azurerm_storage_account.terraform_backup.name
      AZURE_CONTAINER_NAME  = "terraform-state"
      AWS_SOURCE_BUCKET     = aws_s3_bucket.terraform_state.bucket
    }
  }
  
  tags = {
    Name    = "Cross-Cloud Terraform Backup"
    Purpose = "DisasterRecovery"
  }
}
```

### Business Continuity Planning

#### RTO/RPO Implementation

```hcl
# Recovery Time Objective (RTO) and Recovery Point Objective (RPO) configuration
locals {
  # Business requirements
  rto_requirements = {
    critical     = "1h"   # 1 hour
    important    = "4h"   # 4 hours
    standard     = "24h"  # 24 hours
  }
  
  rpo_requirements = {
    critical     = "15m"  # 15 minutes
    important    = "1h"   # 1 hour
    standard     = "24h"  # 24 hours
  }
}

# High-frequency backup for critical workloads
resource "aws_cloudwatch_event_rule" "critical_backup_schedule" {
  name                = "terraform-critical-backup-schedule"
  description         = "Backup critical Terraform states every 15 minutes"
  schedule_expression = "rate(15 minutes)"
  
  tags = {
    WorkloadTier = "Critical"
    RPO          = local.rpo_requirements.critical
  }
}

# Standard backup for non-critical workloads
resource "aws_cloudwatch_event_rule" "standard_backup_schedule" {
  name                = "terraform-standard-backup-schedule"
  description         = "Backup standard Terraform states daily"
  schedule_expression = "rate(1 day)"
  
  tags = {
    WorkloadTier = "Standard"
    RPO          = local.rpo_requirements.standard
  }
}
```

#### Recovery Testing Automation

```hcl
# Automated DR testing
resource "aws_lambda_function" "dr_test" {
  filename      = "dr_test.zip"
  function_name = "terraform-dr-test"
  role          = aws_iam_role.dr_test.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 900
  
  environment {
    variables = {
      TEST_ENVIRONMENT = "dr-test"
      BACKUP_BUCKET    = aws_s3_bucket.state_backups.bucket
      TEST_RESULTS_TOPIC = aws_sns_topic.dr_test_results.arn
    }
  }
  
  tags = {
    Name    = "DR Test Automation"
    Purpose = "DisasterRecoveryTesting"
  }
}

# Monthly DR test schedule
resource "aws_cloudwatch_event_rule" "dr_test_schedule" {
  name                = "terraform-dr-test-schedule"
  description         = "Run DR tests monthly"
  schedule_expression = "cron(0 2 1 * ? *)"  # 2 AM on the 1st of every month
}

resource "aws_cloudwatch_event_target" "dr_test_target" {
  rule      = aws_cloudwatch_event_rule.dr_test_schedule.name
  target_id = "TerraformDRTestTarget"
  arn       = aws_lambda_function.dr_test.arn
}
```

