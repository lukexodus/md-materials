## Multi-Cloud Deployments


### Provider Configuration Strategy

```hcl
# main.tf - Multi-cloud provider setup
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

# AWS Provider Configuration
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}

# Azure Provider Configuration
provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

# GCP Provider Configuration
provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
}
```

### Multi-Cloud Architecture Pattern

```hcl
# multi-cloud-infrastructure.tf
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# AWS Infrastructure
module "aws_infrastructure" {
  source = "./modules/aws"
  
  providers = {
    aws = aws.us_east
  }
  
  vpc_cidr = "10.0.0.0/16"
  tags     = local.common_tags
}

# Azure Infrastructure
module "azure_infrastructure" {
  source = "./modules/azure"
  
  resource_group_location = "East US"
  vnet_address_space     = ["10.1.0.0/16"]
  tags                   = local.common_tags
}

# GCP Infrastructure
module "gcp_infrastructure" {
  source = "./modules/gcp"
  
  network_cidr = "10.2.0.0/16"
  labels       = local.common_tags
}

# Cross-cloud connectivity
resource "aws_vpn_gateway" "aws_to_azure" {
  vpc_id = module.aws_infrastructure.vpc_id
  tags   = local.common_tags
}

resource "azurerm_virtual_network_gateway" "azure_to_aws" {
  name                = "vng-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  type     = "Vpn"
  vpn_type = "RouteBased"
  
  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"
  
  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}
```

### Multi-Cloud Module Structure

```
terraform/
├── modules/
│   ├── aws/
│   │   ├── compute/
│   │   ├── networking/
│   │   └── storage/
│   ├── azure/
│   │   ├── compute/
│   │   ├── networking/
│   │   └── storage/
│   ├── gcp/
│   │   ├── compute/
│   │   ├── networking/
│   │   └── storage/
│   └── shared/
│       ├── monitoring/
│       ├── security/
│       └── networking/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── scripts/
    └── multi-cloud-deploy.sh
```

### Cloud Abstraction Layer

```hcl
# modules/shared/compute/main.tf
variable "cloud_provider" {
  description = "Target cloud provider"
  type        = string
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be aws, azure, or gcp."
  }
}

# Compute abstraction
locals {
  compute_configs = {
    aws = {
      instance_type = "t3.medium"
      ami_filter    = "ubuntu/images/hvm-ssd/ubuntu-20.04-amd64-server-*"
    }
    azure = {
      vm_size        = "Standard_B2s"
      publisher      = "Canonical"
      offer          = "0001-com-ubuntu-server-focal"
      sku            = "20_04-lts-gen2"
    }
    gcp = {
      machine_type = "e2-medium"
      image        = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
}

module "aws_compute" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "../aws/compute"
  
  instance_type = local.compute_configs.aws.instance_type
  ami_filter    = local.compute_configs.aws.ami_filter
}

module "azure_compute" {
  count  = var.cloud_provider == "azure" ? 1 : 0
  source = "../azure/compute"
  
  vm_size   = local.compute_configs.azure.vm_size
  publisher = local.compute_configs.azure.publisher
  offer     = local.compute_configs.azure.offer
  sku       = local.compute_configs.azure.sku
}

module "gcp_compute" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "../gcp/compute"
  
  machine_type = local.compute_configs.gcp.machine_type
  image        = local.compute_configs.gcp.image
}
```

