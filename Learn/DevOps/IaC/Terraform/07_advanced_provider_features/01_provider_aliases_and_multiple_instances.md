## Provider Aliases and Multiple Instances


Provider aliases enable using multiple configurations of the same provider within a single Terraform configuration. This is essential when managing resources across different regions, accounts, or with different authentication contexts.

**Basic Alias Configuration**:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_instance" "east" {
  # Uses default provider (us-east-1)
  ami           = "ami-12345678"
  instance_type = "t3.micro"
}

resource "aws_instance" "west" {
  provider      = aws.west
  ami           = "ami-87654321"
  instance_type = "t3.micro"
}
```

**Multi-Account AWS Configuration**:

```hcl
provider "aws" {
  alias  = "production"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::111111111111:role/TerraformRole"
  }
}

provider "aws" {
  alias  = "development"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::222222222222:role/TerraformRole"
  }
}
```

**Module Provider Passing**:

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  providers = {
    aws = aws.west
  }
}
```

