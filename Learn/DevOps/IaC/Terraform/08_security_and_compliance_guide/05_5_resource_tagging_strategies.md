## 5. Resource Tagging Strategies


### Default Tags Configuration

```hcl
provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment   = var.environment
      ManagedBy     = "Terraform"
      Project       = var.project_name
      Owner         = var.owner
      CostCenter    = var.cost_center
      Compliance    = var.compliance_framework
    }
  }
}
```

### Dynamic Tagging Module

```hcl
# modules/tagging/main.tf
locals {
  common_tags = {
    Environment    = var.environment
    Project        = var.project
    Owner          = var.owner
    CreatedBy      = "Terraform"
    CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
    LastModified   = formatdate("YYYY-MM-DD", timestamp())
  }
  
  compliance_tags = var.compliance_framework != "" ? {
    ComplianceFramework = var.compliance_framework
    DataClassification  = var.data_classification
    RetentionPeriod    = var.retention_period
  } : {}
  
  all_tags = merge(local.common_tags, local.compliance_tags, var.additional_tags)
}

output "tags" {
  value = local.all_tags
}
```

### Cost Allocation Tags

```hcl
locals {
  cost_tags = {
    CostCenter    = var.cost_center
    Department    = var.department
    Application   = var.application_name
    Environment   = var.environment
    BillingCode   = var.billing_code
  }
}
```

