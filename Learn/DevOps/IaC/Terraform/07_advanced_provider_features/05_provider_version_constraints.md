## Provider Version Constraints


Version constraints ensure consistent and predictable provider behavior:

**Constraint Operators**:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"      # Pessimistic constraint
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"  # Range constraint
    }
    google = {
      source  = "hashicorp/google"
      version = "= 4.47.0"    # Exact version
    }
  }
}
```

**Version Constraint Best Practices**:

- Use pessimistic constraints (`~>`) for stability
- Pin to specific versions for critical production environments
- Test provider upgrades in non-production environments first
- Document known compatibility issues and requirements

**Provider Lock File** (`.terraform.lock.hcl`): Records exact provider versions used in the configuration to ensure consistency across team members and environments.

