## Providers and Provider Configuration


Providers are plugins that interact with APIs of cloud platforms, SaaS providers, and other services:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "my-project"
    }
  }
}
```

Provider configuration blocks specify settings like authentication credentials, API endpoints, and default values applied to all resources from that provider.

