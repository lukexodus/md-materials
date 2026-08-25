## 6. Access Control and Permissions


### IAM Roles for Terraform

```hcl
# Terraform execution role
resource "aws_iam_role" "terraform_role" {
  name = "TerraformExecutionRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Least privilege policy
resource "aws_iam_role_policy" "terraform_policy" {
  name = "TerraformPolicy"
  role = aws_iam_role.terraform_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### Cross-Account Access

```hcl
# Assume role provider
provider "aws" {
  alias  = "production"
  region = "us-east-1"
  
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/TerraformCrossAccountRole"
  }
}
```

### Service Account Management

```hcl
# Google Cloud service account
resource "google_service_account" "terraform_sa" {
  account_id   = "terraform-sa"
  display_name = "Terraform Service Account"
  project      = var.project_id
}

resource "google_service_account_key" "terraform_key" {
  service_account_id = google_service_account.terraform_sa.name
}

# Azure service principal
resource "azuread_application" "terraform_app" {
  display_name = "Terraform Application"
}

resource "azuread_service_principal" "terraform_sp" {
  application_id = azuread_application.terraform_app.application_id
}
```

