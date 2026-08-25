## 6. Advanced State Management Patterns


### State Backend Strategies

#### Multi-Environment State Management

```hcl
# Backend configuration with environment-specific buckets
terraform {
  backend "s3" {
    bucket         = "terraform-state-${var.environment}-${random_id.bucket_suffix.hex}"
    key            = "infrastructure/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    kms_key_id     = aws_kms_key.terraform_state.arn
    dynamodb_table = "terraform-locks-${var.environment}"
    
    # Workspace-specific state paths
    workspace_key_prefix = "workspaces"
  }
}

# State bucket with versioning and lifecycle
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-state-${var.environment}-${random_id.bucket_suffix.hex}"
  force_destroy = false
  
  tags = {
    Name        = "Terraform State"
    Environment = var.environment
    Purpose     = "TerraformState"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    id     = "state_file_lifecycle"
    status = "Enabled"
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}
```

#### State Locking and Concurrency

```hcl
# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_state.arn
  }
  
  tags = {
    Name        = "Terraform State Locks"
    Environment = var.environment
    Purpose     = "TerraformStateLocking"
  }
}

# KMS key for state encryption
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Terraform to use the key"
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.terraform_execution.arn
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name        = "Terraform State KMS Key"
    Environment = var.environment
    Purpose     = "TerraformStateEncryption"
  }
}

# KMS key alias
resource "aws_kms_alias" "terraform_state" {
  name          = "alias/terraform-state-${var.environment}"
  target_key_id = aws_kms_key.terraform_state.key_id
}
```

### State Migration and Import Strategies

#### Bulk Import Module

```hcl
# State import automation module
module "state_import" {
  source = "./modules/state-import"
  
  # Resources to import
  import_resources = {
    "aws_vpc.main" = {
      resource_id = "vpc-12345678"
      resource_type = "aws_vpc"
    }
    "aws_subnet.public[0]" = {
      resource_id = "subnet-abcdef12"
      resource_type = "aws_subnet"
    }
    "aws_subnet.public[1]" = {
      resource_id = "subnet-abcdef34"
      resource_type = "aws_subnet"
    }
  }
  
  # Import validation
  validate_imports = true
  
  # Backup existing state
  backup_state = true
}

# Import script generation
resource "local_file" "import_script" {
  content = templatefile("${path.module}/templates/import_script.sh.tpl", {
    resources = var.import_resources
  })
  filename = "import_resources.sh"
  
  file_permission = "0755"
}
```

#### State Splitting Strategy

```hcl
# State splitting for large infrastructures
# Original monolithic state -> Multiple focused states

# Network state (separate workspace)
# terraform/network/
terraform {
  backend "s3" {
    bucket = "terraform-state-prod"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Application state (separate workspace)  
# terraform/applications/web-app/
terraform {
  backend "s3" {
    bucket = "terraform-state-prod"
    key    = "applications/web-app/terraform.tfstate"
    region = "us-east-1"
  }
}

# Cross-state data sources
data "terraform_remote_state" "network" {
  backend = "s3"
  
  config = {
    bucket = "terraform-state-prod"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use network outputs in application
resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_id
  vpc_security_group_ids = [
    data.terraform_remote_state.network.outputs.web_security_group_id
  ]
  
  # ... other configuration
}
```

