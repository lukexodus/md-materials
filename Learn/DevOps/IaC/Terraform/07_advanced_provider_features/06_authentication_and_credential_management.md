## Authentication and Credential Management


Secure credential management is crucial for provider security:

**AWS Authentication Methods**:

```hcl
# Environment variables (recommended)
provider "aws" {
  region = "us-east-1"
  # Uses AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
}

# Shared credentials file
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "production"
}

# IAM roles (for EC2 instances)
provider "aws" {
  region = "us-east-1"
  # Automatically uses instance profile
}

# Assume role
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn     = "arn:aws:iam::123456789012:role/TerraformRole"
    session_name = "terraform-session"
  }
}
```

**Azure Authentication Methods**:

```hcl
# Service Principal with Client Secret
provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

# Managed Identity (for Azure VMs)
provider "azurerm" {
  features {}
  use_msi = true
}
```

**Security Best Practices**:

- Never hardcode credentials in configuration files
- Use environment variables or secure credential stores
- Implement least-privilege access principles
- Rotate credentials regularly
- Use temporary credentials when possible
- Enable audit logging for credential usage

