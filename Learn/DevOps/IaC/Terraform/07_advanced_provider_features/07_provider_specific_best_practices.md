## Provider-Specific Best Practices


### AWS Best Practices

**Resource Tagging Strategy**:

```hcl
locals {
  common_tags = {
    Environment   = var.environment
    Project       = var.project_name
    ManagedBy     = "terraform"
    CostCenter    = var.cost_center
    Owner         = var.owner
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}
```

**IAM Resource Management**:

- Use data sources for existing IAM resources when possible
- Implement proper IAM policy versioning
- Avoid overly permissive policies
- Use IAM roles instead of users for application access

**Cost Optimization Patterns**:

- Implement proper resource lifecycle management
- Use appropriate instance sizing
- Leverage spot instances where applicable
- Implement automated resource cleanup

### Azure Best Practices

**Resource Group Organization**:

```hcl
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
```

**Naming Convention Implementation**:

```hcl
locals {
  naming_convention = {
    resource_group = "${var.project}-${var.environment}-rg"
    storage_account = "${var.project}${var.environment}sa"
    key_vault = "${var.project}-${var.environment}-kv"
  }
}
```

### Google Cloud Platform Best Practices

**Project Organization**:

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com"
  ])
  
  service = each.key
  
  disable_dependent_services = true
}
```

**IAM and Security**:

- Use service accounts for application authentication
- Implement proper IAM role bindings
- Enable audit logging and monitoring
- Use Google Cloud KMS for encryption key management

[Inference] These best practices are based on commonly recommended patterns, but specific implementations may vary based on organizational requirements and security policies.

[Unverified] The exact syntax and available features for provider configurations may vary between different provider versions and may change with future updates.

---

