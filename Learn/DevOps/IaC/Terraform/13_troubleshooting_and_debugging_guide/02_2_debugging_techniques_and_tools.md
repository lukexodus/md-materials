## 2. Debugging Techniques and Tools


### Enable Debug Logging

```bash
# Enable different log levels
export TF_LOG=TRACE    # Most verbose
export TF_LOG=DEBUG    # Debug information
export TF_LOG=INFO     # General information
export TF_LOG=WARN     # Warnings only
export TF_LOG=ERROR    # Errors only

# Log to file
export TF_LOG_PATH="./terraform.log"

# Provider-specific logging
export TF_LOG_PROVIDER=TRACE

# Run Terraform with logging
terraform plan
terraform apply
```

### Using Terraform Console for Debugging

```bash
# Start interactive console
terraform console

# Test expressions and functions
> var.environment
"production"

> local.common_tags
{
  "Environment" = "production"
  "Project"     = "web-app"
}

# Test resource references
> aws_vpc.main.id
"vpc-12345678"

# Test functions
> cidrsubnet("10.0.0.0/16", 8, 1)
"10.0.1.0/24"

# Exit console
> exit
```

### State Inspection Commands

```bash
# List all resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Show state file (be careful with sensitive data)
terraform show

# Show state in JSON format
terraform show -json

# Refresh state to match real infrastructure
terraform refresh
```

### Plan Analysis

```bash
# Generate detailed plan
terraform plan -out=tfplan

# Show plan in different formats
terraform show tfplan
terraform show -json tfplan

# Show only changes
terraform plan -detailed-exitcode

# Target specific resources
terraform plan -target=aws_instance.web
```

