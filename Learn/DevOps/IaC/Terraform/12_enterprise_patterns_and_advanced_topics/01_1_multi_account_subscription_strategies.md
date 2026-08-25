## 1. Multi-Account/Subscription Strategies


### AWS Multi-Account Architecture

#### Account Structure Design

```hcl
# Organization setup
resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com"
  ]
  
  feature_set = "ALL"
  
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

# Core accounts structure
locals {
  core_accounts = {
    security = {
      name  = "Security"
      email = "aws-security@company.com"
    }
    logging = {
      name  = "Logging"
      email = "aws-logging@company.com"
    }
    shared_services = {
      name  = "Shared Services"
      email = "aws-shared@company.com"
    }
  }
  
  workload_accounts = {
    dev = {
      name  = "Development"
      email = "aws-dev@company.com"
    }
    staging = {
      name  = "Staging"
      email = "aws-staging@company.com"
    }
    prod = {
      name  = "Production"
      email = "aws-prod@company.com"
    }
  }
}

# Create accounts
resource "aws_organizations_account" "core_accounts" {
  for_each = local.core_accounts
  
  name      = each.value.name
  email     = each.value.email
  role_name = "OrganizationAccountAccessRole"
  
  tags = {
    AccountType = "Core"
    Environment = "Shared"
  }
}

resource "aws_organizations_account" "workload_accounts" {
  for_each = local.workload_accounts
  
  name      = each.value.name
  email     = each.value.email
  role_name = "OrganizationAccountAccessRole"
  
  tags = {
    AccountType = "Workload"
    Environment = each.key
  }
}
```

#### Cross-Account Access Patterns

```hcl
# Central IAM role for cross-account access
resource "aws_iam_role" "cross_account_terraform" {
  name = "TerraformCrossAccountRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.management_account_id}:root"
          ]
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
}

# Provider configuration for multi-account
provider "aws" {
  alias  = "security"
  region = var.aws_region
  
  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.core_accounts["security"].id}:role/TerraformCrossAccountRole"
    external_id  = var.external_id
    session_name = "terraform-security"
  }
}

provider "aws" {
  alias  = "production"
  region = var.aws_region
  
  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.workload_accounts["prod"].id}:role/TerraformCrossAccountRole"
    external_id  = var.external_id
    session_name = "terraform-production"
  }
}
```

#### Service Control Policies (SCPs)

```hcl
# Prevent deletion of CloudTrail
resource "aws_organizations_policy" "deny_cloudtrail_deletion" {
  name = "DenyCloudTrailDeletion"
  type = "SERVICE_CONTROL_POLICY"
  
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCloudTrailDeletion"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::*:role/OrganizationAccountAccessRole"
            ]
          }
        }
      }
    ]
  })
}

# Attach SCP to production OU
resource "aws_organizations_policy_attachment" "prod_scp" {
  policy_id = aws_organizations_policy.deny_cloudtrail_deletion.id
  target_id = aws_organizations_organizational_unit.production.id
}
```

### Azure Multi-Subscription Strategy

#### Management Group Structure

```hcl
# Root management group
resource "azurerm_management_group" "root" {
  display_name = "Company Root"
  
  subscription_ids = []
}

# Platform management groups
resource "azurerm_management_group" "platform" {
  display_name         = "Platform"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "connectivity" {
  display_name         = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  display_name         = "Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Landing zones
resource "azurerm_management_group" "landing_zones" {
  display_name         = "Landing Zones"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "corp" {
  display_name         = "Corp"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "online" {
  display_name         = "Online"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}
```

#### Subscription Vending Machine

```hcl
# Subscription creation module
module "subscription_vending" {
  source = "./modules/subscription-vending"
  
  for_each = var.subscription_requests
  
  subscription_name     = each.value.name
  management_group_id   = each.value.management_group_id
  billing_account_name  = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
  
  tags = merge(var.default_tags, each.value.tags)
}

# Policy assignments
resource "azurerm_management_group_policy_assignment" "corp_policies" {
  name                 = "corp-baseline-policies"
  policy_definition_id = azurerm_policy_set_definition.corp_baseline.id
  management_group_id  = azurerm_management_group.corp.id
  
  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
  })
}
```

### GCP Organization Hierarchy

#### Folder Structure

```hcl
# Organization-level folder structure
resource "google_folder" "environments" {
  display_name = "Environments"
  parent       = "organizations/${var.organization_id}"
}

resource "google_folder" "shared_services" {
  display_name = "Shared Services"
  parent       = "organizations/${var.organization_id}"
}

resource "google_folder" "dev" {
  display_name = "Development"
  parent       = google_folder.environments.name
}

resource "google_folder" "prod" {
  display_name = "Production"
  parent       = google_folder.environments.name
}

# Project factory pattern
module "project_factory" {
  source = "./modules/project-factory"
  
  for_each = var.projects
  
  name       = each.value.name
  folder_id  = each.value.folder_id
  billing_account = var.billing_account
  
  activate_apis = each.value.apis
  
  labels = merge(var.default_labels, each.value.labels)
}
```

