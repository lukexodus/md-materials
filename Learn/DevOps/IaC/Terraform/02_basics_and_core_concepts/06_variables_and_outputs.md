## Variables and Outputs


**Input Variables** parameterize configurations:

```hcl
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

**Output Values** export information about your infrastructure:

```hcl
output "instance_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.web_server.public_ip
}

output "instance_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.web_server.public_dns
  sensitive   = false
}
```

Variables can be set via command line (`-var`), environment variables (`TF_VAR_name`), `.tfvars` files, or interactively.

