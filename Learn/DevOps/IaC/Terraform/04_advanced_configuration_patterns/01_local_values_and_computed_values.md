## Local Values and Computed Values


### Local Values

Local values help you avoid repeating the same values or expressions multiple times within your configuration.

```hcl
locals {
  # Simple local values
  environment = "production"
  project_name = "my-app"
  
  # Computed local values
  common_tags = {
    Environment = local.environment
    Project     = local.project_name
    Owner       = "devops-team"
    CreatedBy   = "terraform"
  }
  
  # Complex computations
  instance_count = var.environment == "production" ? 3 : 1
  
  # String interpolation
  bucket_name = "${local.project_name}-${local.environment}-data"
  
  # List operations
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  
  # Map operations
  subnet_config = {
    for az in local.availability_zones : az => {
      cidr_block = cidrsubnet(var.vpc_cidr, 8, index(local.availability_zones, az))
      public     = true
    }
  }
}

# Using local values
resource "aws_s3_bucket" "data" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

resource "aws_instance" "app" {
  count         = local.instance_count
  ami           = var.ami_id
  instance_type = "t3.micro"
  tags          = merge(local.common_tags, {
    Name = "${local.project_name}-app-${count.index + 1}"
  })
}
```

### Computed Values Best Practices

```hcl
locals {
  # Use locals for complex expressions
  database_url = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.main.endpoint}/${var.db_name}"
  
  # Environment-specific configurations
  app_config = {
    development = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 2
    }
    production = {
      instance_type = "t3.large"
      min_size      = 3
      max_size      = 10
    }
  }
  
  current_config = local.app_config[var.environment]
  
  # Security group rules as locals
  web_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

