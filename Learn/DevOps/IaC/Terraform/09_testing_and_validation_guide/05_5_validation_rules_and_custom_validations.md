## 5. Validation Rules and Custom Validations


### Variable Validation

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  
  validation {
    condition = can(regex("^[tm][2-5]\\.(nano|micro|small|medium|large)$", var.instance_type))
    error_message = "Instance type must be a valid t2-t5 or m2-m5 instance type."
  }
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  
  validation {
    condition = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
  
  validation {
    condition = split("/", var.cidr_block)[1] >= 16 && split("/", var.cidr_block)[1] <= 28
    error_message = "CIDR block must have a prefix between /16 and /28."
  }
}
```

### Resource Lifecycle Rules

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  lifecycle {
    precondition {
      condition     = data.aws_ami.ubuntu.architecture == "x86_64"
      error_message = "AMI must be for x86_64 architecture."
    }
    
    postcondition {
      condition     = self.public_ip != ""
      error_message = "Instance must have a public IP address."
    }
  }
  
  tags = {
    Name = "web-server"
  }
}
```

### Custom Validation Functions

```hcl
# locals.tf
locals {
  # Custom validation for naming conventions
  valid_name = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.resource_name))
  
  # Validate environment-specific configurations
  valid_config = var.environment == "prod" ? (
    var.instance_count >= 2 && var.backup_enabled == true
  ) : true
  
  # Complex validation logic
  validation_errors = concat(
    !local.valid_name ? ["Resource name must start with lowercase letter and contain only lowercase letters, numbers, and hyphens"] : [],
    !local.valid_config ? ["Production environment requires at least 2 instances and backup enabled"] : [],
    var.database_password != null && length(var.database_password) < 12 ? ["Database password must be at least 12 characters"] : []
  )
}

# Use in resource
resource "null_resource" "validation" {
  count = length(local.validation_errors) > 0 ? 1 : 0
  
  provisioner "local-exec" {
    command = "echo 'Validation errors: ${join(", ", local.validation_errors)}' && exit 1"
  }
}
```

