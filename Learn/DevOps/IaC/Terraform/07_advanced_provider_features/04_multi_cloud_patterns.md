## Multi-Cloud Patterns


Multi-cloud deployments require careful provider management and resource organization:

**Provider Declaration for Multiple Clouds**:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
```

**Cross-Cloud Resource Dependencies**:

```hcl
# AWS VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Azure Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "example-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = "East US"
  resource_group_name = azurerm_resource_group.main.name
}

# Data sharing between clouds via outputs
output "aws_vpc_id" {
  value = aws_vpc.main.id
}
```

**Multi-Cloud Networking Patterns**:

- VPN connections between cloud providers
- Transit gateway implementations
- Shared services architectures
- Data replication and synchronization

