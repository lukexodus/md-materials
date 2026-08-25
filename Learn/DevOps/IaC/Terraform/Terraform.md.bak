# Syllabus

## 1. Infrastructure as Code Fundamentals

- What is Infrastructure as Code?
- Traditional vs. IaC approaches
- Terraform vs. CloudFormation vs. Ansible vs. Pulumi
- HashiCorp Configuration Language (HCL) introduction
- Terraform architecture and workflow

## 2. Terraform Basics and Core Concepts

- Terraform workflow: init, plan, apply, destroy
- HCL syntax deep dive
- Providers and provider configuration
- Resources and resource arguments
- Data sources
- Variables and outputs
- Comments and formatting

## 3. State Management

- What is Terraform state?
- State file structure and contents
- Local state limitations
- Remote state backends (S3, Azure Storage, GCS)
- State locking mechanisms
- State file security considerations
- Terraform import command
- State manipulation commands

## 4. Advanced Configuration Patterns

- Local values and computed values
- Conditional expressions and logic
- For expressions and loops
- Dynamic blocks
- Built-in functions (string, numeric, collection, date)
- Resource dependencies (implicit and explicit)
- Resource lifecycle rules
- Provisioners (when and how to use them)

## 5. Modules and Code Organization

- Module fundamentals and structure
- Input variables, outputs, and locals in modules
- Module composition and nesting
- Module sources (local, Git, registry)
- Module versioning strategies
- Terraform Registry usage
- Module testing approaches
- Documentation best practices

## 6. Workspace Management and Environments

- Terraform workspaces concept
- Local vs. remote workspaces
- Environment separation patterns
- Workspace-specific variable files
- Directory structure strategies
- Configuration drift management
- Environment promotion workflows

## 7. Advanced Provider Features

- Provider aliases and multiple instances
- Provider configuration inheritance
- Custom provider development basics
- Multi-cloud patterns
- Provider version constraints
- Authentication and credential management
- Provider-specific best practices (AWS, Azure, GCP)

## 8. Security and Compliance

- Sensitive data handling
- Secret management integration (Vault, AWS Secrets Manager)
- Terraform Cloud/Enterprise security features
- Compliance scanning and policy as code
- Resource tagging strategies
- Access control and permissions
- Audit logging and monitoring

## 9. Testing and Validation

- Unit testing with Terratest
- Integration testing strategies
- Policy testing with OPA/Sentinel
- Static analysis tools (tflint, checkov)
- Validation rules and custom validations
- Contract testing between modules
- Performance testing for large deployments

## 10. CI/CD and Automation

- Git workflows for infrastructure
- CI/CD pipeline design patterns
- Automated testing integration
- Deployment strategies (blue-green, canary)
- Rollback and disaster recovery
- Terraform Cloud/Enterprise integration
- GitHub Actions, GitLab CI, Jenkins integration

## 11. Performance and Scalability

- Performance optimization techniques
- Parallelism and resource graphs
- State file optimization
- Large-scale deployment strategies
- Resource targeting and partial deployments
- Terraform plan optimization
- Memory and CPU considerations

## 12. Enterprise Patterns and Advanced Topics

- Multi-account/subscription strategies
- Terraform Enterprise features
- Policy as Code with Sentinel
- Cost management and optimization
- Governance and compliance at scale
- Advanced state management patterns
- Disaster recovery and backup strategies

## 13. Troubleshooting and Debugging

- Common error patterns and solutions
- Debugging techniques and tools
- Log analysis and interpretation
- State troubleshooting
- Provider-specific issues
- Performance troubleshooting
- Recovery from failed deployments

## 14. Advanced Use Cases and Integration

- Multi-cloud deployments
- Hybrid cloud architectures
- Infrastructure automation patterns
- Integration with configuration management tools
- Container orchestration integration
- Serverless infrastructure patterns
- Network and security automation

---

# Infrastructure as Code Fundamentals

## What is Infrastructure as Code?

Infrastructure as Code (IaC) is a practice where infrastructure resources are defined, provisioned, and managed through machine-readable configuration files rather than manual processes. Instead of clicking through web consoles or running individual commands, you write code that describes your desired infrastructure state, and tools automatically create and maintain that infrastructure.

The core principle is treating infrastructure with the same practices used for application code: version control, automated testing, code reviews, and reproducible deployments.

## Traditional vs. IaC Approaches

**Traditional Infrastructure Management:**
- Manual provisioning through web consoles or CLI commands
- Point-and-click configuration changes
- Documentation often becomes outdated
- Difficult to reproduce environments consistently
- Human error prone
- Limited visibility into change history
- Scaling requires repetitive manual work

**Infrastructure as Code Approach:**
- Declarative configuration files define desired state
- Version-controlled infrastructure definitions
- Automated provisioning and updates
- Consistent, reproducible environments
- Reduced human error through automation
- Complete audit trail of changes
- Easy environment replication and scaling

## Terraform vs. CloudFormation vs. Ansible vs. Pulumi

**Terraform:**
- Cloud-agnostic tool by HashiCorp
- Uses HashiCorp Configuration Language (HCL)
- Declarative approach with state management
- Extensive provider ecosystem (AWS, Azure, GCP, etc.)
- Strong community and third-party modules
- Plan-and-apply workflow for safe changes

**AWS CloudFormation:**
- AWS-native service for AWS resources only
- Uses JSON or YAML templates
- Integrated with AWS services and IAM
- No additional tooling required for AWS environments
- Stack-based resource management
- Built-in rollback capabilities

**Ansible:**
- Configuration management tool that can handle infrastructure
- Uses YAML playbooks
- Agentless architecture
- Procedural approach (describes steps to take)
- Strong for configuration management and application deployment
- Can integrate with other IaC tools

**Pulumi:**
- Uses familiar programming languages (Python, TypeScript, Go, C#)
- Cloud-agnostic with multiple providers
- Object-oriented approach to infrastructure
- Combines benefits of general-purpose languages with infrastructure management
- Built-in testing capabilities using standard language tools

## HashiCorp Configuration Language (HCL) Introduction

HCL is a structured configuration language designed to be both human and machine-readable. It strikes a balance between JSON's machine-readability and YAML's human-friendliness.

**Key HCL Syntax Elements:**

```hcl
# Comments start with hash
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1d0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "ExampleInstance"
  }
}

# Variables
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

# Outputs
output "instance_ip" {
  value = aws_instance.example.public_ip
}
```

**HCL Features:**
- Block-based structure with resource types and names
- Attribute assignment using equals sign
- Support for strings, numbers, booleans, lists, and maps
- Interpolation syntax for dynamic values
- Comments using # or /* */
- Functions for data manipulation and validation

## Terraform Architecture and Workflow

**Core Components:**

1. **Configuration Files:** Define desired infrastructure state using HCL
2. **Providers:** Plugins that interact with APIs (AWS, Azure, etc.)
3. **State File:** Tracks current infrastructure state and metadata
4. **Backend:** Stores state file (local, remote, or cloud storage)
5. **Modules:** Reusable configuration packages

**Terraform Workflow:**

1. **Write:** Create configuration files defining infrastructure
2. **Plan:** Run `terraform plan` to preview changes
3. **Apply:** Execute `terraform apply` to create/modify infrastructure
4. **Manage:** Use `terraform destroy`, `terraform import`, etc. for lifecycle management

**Key Commands:**
- `terraform init`: Initialize working directory and download providers
- `terraform plan`: Create execution plan showing proposed changes
- `terraform apply`: Execute planned changes
- `terraform destroy`: Remove all managed infrastructure
- `terraform validate`: Check configuration syntax
- `terraform fmt`: Format configuration files consistently

**State Management:**
Terraform maintains a state file that maps configuration to real-world resources. This state file is crucial for determining what changes need to be made during subsequent runs. For team environments, remote state storage (like AWS S3 with DynamoDB locking) prevents conflicts and ensures consistency.

The declarative nature means you describe what you want, not how to achieve it. Terraform figures out the necessary steps, handles dependencies, and can safely update infrastructure by comparing desired state with current state.

---

# Basics and Core Concepts

## Terraform Workflow

The standard Terraform workflow follows four primary commands:

**terraform init**: Initializes a working directory containing Terraform configuration files. Downloads and installs provider plugins, initializes backend configuration, and prepares the directory for other commands.

**terraform plan**: Creates an execution plan showing what actions Terraform will take to reach the desired state defined in configuration files. This is a preview that doesn't make any changes to actual infrastructure.

**terraform apply**: Executes the actions proposed in a plan to create, update, or destroy infrastructure. Requires confirmation unless the `-auto-approve` flag is used.

**terraform destroy**: Destroys all remote objects managed by the Terraform configuration. Essentially the reverse of `terraform apply`.

## HCL Syntax Deep Dive

HashiCorp Configuration Language (HCL) is Terraform's configuration syntax:

**Basic Structure**:

```hcl
block_type "block_label" "block_name" {
  argument_name = argument_value
  
  nested_block {
    nested_argument = "value"
  }
}
```

**Data Types**:

- **String**: `"hello world"`
- **Number**: `42` or `3.14`
- **Boolean**: `true` or `false`
- **List**: `["item1", "item2", "item3"]`
- **Map**: `{key1 = "value1", key2 = "value2"}`
- **Object**: Complex nested structures with typed attributes

**Expressions**:

- **References**: `var.example`, `resource.aws_instance.web.id`
- **Interpolation**: `"Hello ${var.name}"`
- **Functions**: `length(var.list)`, `join(",", var.items)`
- **Conditionals**: `var.environment == "prod" ? "large" : "small"`

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

## Resources and Resource Arguments

Resources represent infrastructure objects in your configuration:

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1d0"
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.public.id
  
  user_data = file("${path.module}/user_data.sh")
  
  tags = {
    Name = "WebServer"
  }
}
```

Resource arguments define the desired configuration. Each resource type has specific required and optional arguments documented by the provider.

## Data Sources

Data sources allow Terraform to fetch information from existing infrastructure or external systems:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}
```

Data sources are read-only and don't create or manage infrastructure.

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

## Comments and Formatting

**Comments**:

- Single line: `# This is a comment`
- Multi-line: `/* This is a multi-line comment */`

**Formatting Best Practices**:

- Use `terraform fmt` to automatically format code
- Indent nested blocks with 2 spaces
- Align argument values in blocks
- Use blank lines to separate logical sections
- Group related resources together

**File Organization**:

- `main.tf`: Primary configuration
- `variables.tf`: Input variable declarations
- `outputs.tf`: Output value declarations
- `versions.tf`: Provider version constraints
- `terraform.tfvars`: Variable value assignments

These concepts form the foundation for Infrastructure as Code with Terraform, enabling reproducible, version-controlled infrastructure management across multiple environments and cloud providers.

---

# State Management

## What is Terraform State?

Terraform state is a JSON file that maps your configuration to the real-world infrastructure resources. It serves as Terraform's "memory" of what resources exist, their current attributes, and the relationships between them. The state file acts as the source of truth for Terraform to determine what changes need to be made during planning and execution.

## State File Structure and Contents

The Terraform state file is a JSON document containing several key sections:

- **Version**: The state file format version
- **Serial**: A counter that increments with each state change
- **Lineage**: A unique identifier for the state file's history
- **Resources**: An array of all managed resources with their attributes and metadata
- **Outputs**: Values from output blocks in your configuration
- **Dependencies**: Resource dependency information for proper ordering

Each resource entry includes the resource type, name, provider information, current attributes, and metadata like creation timestamps.

## Local State Limitations

Local state files (stored as `terraform.tfstate` in your working directory) have significant limitations:

- **No collaboration**: Multiple team members cannot safely work with the same infrastructure
- **No locking**: Concurrent operations can corrupt the state file
- **Security risks**: Sensitive data is stored in plain text locally
- **No versioning**: Limited ability to track changes or recover from corruption
- **Backup responsibility**: Manual backup management required

## Remote State Backends

Remote backends store state files in shared, centralized locations:

**AWS S3 Backend**: Stores state in S3 buckets with optional DynamoDB for locking

- Supports versioning and encryption
- Integrates with AWS IAM for access control
- Requires bucket and DynamoDB table configuration

**Azure Storage Backend**: Uses Azure Storage Accounts for state storage

- Supports blob versioning and access tiers
- Integrates with Azure AD for authentication
- Can use lease-based locking

**Google Cloud Storage (GCS) Backend**: Stores state in GCS buckets

- Supports object versioning and lifecycle management
- Integrates with Google Cloud IAM
- Provides built-in encryption

## State Locking Mechanisms

State locking prevents concurrent modifications that could corrupt the state file:

- **DynamoDB locking** (AWS S3 backend): Uses a DynamoDB table to store lock information
- **Blob leases** (Azure backend): Uses Azure Storage blob leases for locking
- **Native locking** (GCS backend): Built-in locking mechanism
- **Consul backend**: Distributed locking through Consul's key-value store

When a lock is acquired, other Terraform operations wait or fail depending on configuration.

## State File Security Considerations

State files contain sensitive information requiring protection:

- **Encryption at rest**: Enable backend encryption (S3 SSE, Azure Storage encryption, etc.)
- **Encryption in transit**: Use HTTPS/TLS for all state operations
- **Access control**: Implement strict IAM policies limiting state file access
- **Sensitive data**: State files may contain passwords, keys, and other secrets
- **Audit logging**: Enable access logging for compliance and security monitoring
- **Network security**: Use private endpoints where available

## Terraform Import Command

The `terraform import` command associates existing infrastructure with Terraform resources:

```bash
terraform import resource_type.resource_name resource_id
```

Key considerations:

- Only imports the resource into state, not the configuration
- Requires manual creation of corresponding configuration blocks
- Different resource types use different identifier formats
- Some resources cannot be imported due to API limitations
- Import operations modify state files and should be carefully planned

## State Manipulation Commands

Several commands allow direct state file manipulation:

**terraform state list**: Shows all resources in the state file **terraform state show**: Displays detailed information about specific resources **terraform state mv**: Moves resources within state (useful for refactoring) **terraform state rm**: Removes resources from state without destroying infrastructure **terraform state pull**: Downloads and displays the current state **terraform state push**: Uploads a local state file to the backend **terraform refresh**: Updates state file with real-world resource changes **terraform force-unlock**: Manually releases stuck state locks

[Inference] These commands require careful use as they directly modify the state file, and incorrect usage could lead to infrastructure management issues.

State manipulation should typically be performed in controlled environments with proper backups and team coordination to avoid conflicts or data loss.

---

# Advanced Configuration Patterns

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

## Conditional Expressions and Logic

### Basic Conditional Expressions

```hcl
# Ternary operator: condition ? true_val : false_val
resource "aws_instance" "web" {
  instance_type = var.environment == "production" ? "t3.large" : "t3.micro"
  
  # Conditional resource creation
  count = var.create_instance ? 1 : 0
  
  ami = var.ami_id
  
  tags = {
    Name = var.environment == "production" ? "prod-web-server" : "dev-web-server"
  }
}

# Complex conditional logic
locals {
  storage_type = var.environment == "production" ? (
    var.high_performance ? "gp3" : "gp2"
  ) : "gp2"
  
  backup_retention = (
    var.environment == "production" ? 30 :
    var.environment == "staging" ? 7 : 1
  )
}
```

### Conditional Resource Creation Patterns

```hcl
# Pattern 1: Count-based conditional creation
resource "aws_cloudwatch_log_group" "app_logs" {
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

# Pattern 2: for_each with conditional logic
resource "aws_security_group_rule" "ingress" {
  for_each = var.enable_web_access ? toset(["http", "https"]) : toset([])
  
  type              = "ingress"
  from_port         = each.key == "http" ? 80 : 443
  to_port           = each.key == "http" ? 80 : 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

# Pattern 3: Conditional data sources
data "aws_ami" "ubuntu" {
  count       = var.use_custom_ami ? 0 : 1
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

locals {
  ami_id = var.use_custom_ami ? var.custom_ami_id : data.aws_ami.ubuntu[0].id
}
```

## For Expressions and Loops

### For Expressions with Lists

```hcl
variable "users" {
  description = "List of users"
  type = list(object({
    name  = string
    role  = string
    email = string
  }))
  default = [
    { name = "alice", role = "admin", email = "alice@example.com" },
    { name = "bob", role = "user", email = "bob@example.com" },
    { name = "charlie", role = "admin", email = "charlie@example.com" }
  ]
}

locals {
  # Transform list to map
  user_map = {
    for user in var.users : user.name => user
  }
  
  # Filter and transform
  admin_emails = [
    for user in var.users : user.email
    if user.role == "admin"
  ]
  
  # Create uppercase names
  uppercase_names = [
    for user in var.users : upper(user.name)
  ]
  
  # Complex transformation
  user_policies = {
    for user in var.users : user.name => {
      policy_name = "${user.name}-policy"
      permissions = user.role == "admin" ? ["read", "write", "delete"] : ["read"]
    }
  }
}

# Using for expressions in resources
resource "aws_iam_user" "users" {
  for_each = local.user_map
  name     = each.value.name
  
  tags = {
    Role  = each.value.role
    Email = each.value.email
  }
}
```

### For Expressions with Maps

```hcl
variable "environments" {
  description = "Environment configurations"
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
    subnets       = list(string)
  }))
  default = {
    dev = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 2
      subnets       = ["subnet-123", "subnet-456"]
    }
    prod = {
      instance_type = "t3.large"
      min_size      = 3
      max_size      = 10
      subnets       = ["subnet-789", "subnet-abc"]
    }
  }
}

locals {
  # Transform map values
  environment_tags = {
    for env_name, env_config in var.environments : env_name => {
      Environment = env_name
      InstanceType = env_config.instance_type
      AutoScaling = "${env_config.min_size}-${env_config.max_size}"
    }
  }
  
  # Flatten nested structures
  all_subnets = flatten([
    for env_name, env_config in var.environments : [
      for subnet in env_config.subnets : {
        environment = env_name
        subnet_id   = subnet
      }
    ]
  ])
  
  # Create subnet map
  subnet_environments = {
    for item in local.all_subnets : item.subnet_id => item.environment
  }
}
```

### Advanced For Expression Patterns

```hcl
# Grouping and aggregation
variable "servers" {
  type = list(object({
    name         = string
    environment  = string
    instance_type = string
    cost_center  = string
  }))
}

locals {
  # Group by environment
  servers_by_env = {
    for server in var.servers : server.environment => server...
  }
  
  # Count by instance type
  instance_type_counts = {
    for server in var.servers : server.instance_type => length([
      for s in var.servers : s if s.instance_type == server.instance_type
    ])...
  }
  
  # Multi-level grouping
  servers_by_env_and_type = {
    for server in var.servers : "${server.environment}-${server.instance_type}" => {
      environment   = server.environment
      instance_type = server.instance_type
      servers       = [for s in var.servers : s.name if s.environment == server.environment && s.instance_type == server.instance_type]
    }...
  }
}
```

## Dynamic Blocks

### Basic Dynamic Block Usage

```hcl
variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]
}

resource "aws_security_group" "web" {
  name_prefix = "web-sg"
  vpc_id      = var.vpc_id
  
  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  
  # Static egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Complex Dynamic Block Patterns

```hcl
variable "load_balancer_config" {
  type = object({
    listeners = list(object({
      port     = number
      protocol = string
      ssl_policy = optional(string)
      certificate_arn = optional(string)
      default_actions = list(object({
        type             = string
        target_group_arn = optional(string)
        redirect = optional(object({
          host        = optional(string)
          path        = optional(string)
          port        = optional(string)
          protocol    = optional(string)
          status_code = string
        }))
      }))
    }))
  })
}

resource "aws_lb_listener" "main" {
  for_each = {
    for idx, listener in var.load_balancer_config.listeners : idx => listener
  }
  
  load_balancer_arn = aws_lb.main.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = each.value.certificate_arn
  
  # Dynamic default actions
  dynamic "default_action" {
    for_each = each.value.default_actions
    content {
      type             = default_action.value.type
      target_group_arn = default_action.value.target_group_arn
      
      # Nested dynamic block for redirect
      dynamic "redirect" {
        for_each = default_action.value.redirect != null ? [default_action.value.redirect] : []
        content {
          host        = redirect.value.host
          path        = redirect.value.path
          port        = redirect.value.port
          protocol    = redirect.value.protocol
          status_code = redirect.value.status_code
        }
      }
    }
  }
}
```

### Dynamic Blocks with Conditions

```hcl
variable "environment_config" {
  type = object({
    name = string
    monitoring_enabled = bool
    backup_enabled = bool
    encryption_enabled = bool
    tags = map(string)
  })
}

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  # Conditional dynamic block for monitoring
  dynamic "monitoring" {
    for_each = var.environment_config.monitoring_enabled ? [1] : []
    content {
      enabled = true
    }
  }
  
  # Conditional dynamic block for EBS encryption
  dynamic "root_block_device" {
    for_each = var.environment_config.encryption_enabled ? [1] : []
    content {
      encrypted = true
      kms_key_id = aws_kms_key.ebs[0].arn
    }
  }
  
  tags = var.environment_config.tags
}

# Supporting resources
resource "aws_kms_key" "ebs" {
  count       = var.environment_config.encryption_enabled ? 1 : 0
  description = "EBS encryption key"
}
```

## Built-in Functions

### String Functions

```hcl
locals {
  # String manipulation
  app_name = "MyApplication"
  
  # Case conversion
  lower_name = lower(local.app_name)           # "myapplication"
  upper_name = upper(local.app_name)           # "MYAPPLICATION"
  title_name = title(local.app_name)           # "Myapplication"
  
  # String operations
  trimmed = trimspace("  hello world  ")       # "hello world"
  replaced = replace(local.app_name, "App", "Service")  # "MyServicelication"
  
  # String splitting and joining
  parts = split("-", "web-app-prod")           # ["web", "app", "prod"]
  joined = join("-", ["web", "app", "prod"])   # "web-app-prod"
  
  # Substring operations
  prefix = substr(local.app_name, 0, 2)        # "My"
  suffix = substr(local.app_name, -4, -1)      # "tion"
  
  # String formatting
  formatted = format("Hello, %s! You have %d messages.", "Alice", 5)
  padded = format("%04d", 42)                  # "0042"
  
  # Regular expressions
  regex_match = regex("([A-Z][a-z]+)", local.app_name)  # "My"
  all_matches = regexall("[A-Z][a-z]+", local.app_name) # ["My", "Application"]
  
  # String validation
  is_valid_email = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.email))
}

# Practical string function usage
resource "aws_s3_bucket" "logs" {
  bucket = lower(replace("${var.company_name}-${var.app_name}-logs", " ", "-"))
  
  tags = {
    Name = title(replace(local.app_name, "-", " "))
  }
}
```

### Numeric Functions

```hcl
locals {
  numbers = [1, 5, 3, 9, 2, 7]
  
  # Basic math
  sum_result = sum(local.numbers)              # 27
  minimum = min(local.numbers...)              # 1
  maximum = max(local.numbers...)              # 9
  
  # Rounding
  pi = 3.14159265359
  rounded = round(local.pi, 2)                 # 3.14
  ceiling = ceil(local.pi)                     # 4
  floor_val = floor(local.pi)                  # 3
  absolute = abs(-42)                          # 42
  
  # Power and logarithms
  power = pow(2, 8)                           # 256
  logarithm = log(100, 10)                    # 2
  
  # Random values (use with caution in Terraform)
  # random_id = random_integer.example.result
}

# Practical numeric function usage
resource "aws_autoscaling_group" "app" {
  name             = var.asg_name
  min_size         = max(1, var.min_size)
  max_size         = max(var.min_size, var.max_size)
  desired_capacity = max(var.min_size, min(var.desired_capacity, var.max_size))
  
  target_group_arns = var.target_group_arns
}
```

### Collection Functions

```hcl
variable "servers" {
  type = list(object({
    name = string
    type = string
    zone = string
  }))
  default = [
    { name = "web-1", type = "web", zone = "us-east-1a" },
    { name = "web-2", type = "web", zone = "us-east-1b" },
    { name = "db-1", type = "db", zone = "us-east-1a" }
  ]
}

locals {
  # List operations
  server_names = [for s in var.servers : s.name]
  web_servers = [for s in var.servers : s if s.type == "web"]
  
  # Collection functions
  unique_zones = distinct([for s in var.servers : s.zone])
  server_count = length(var.servers)
  
  # Set operations
  zones_set = toset(local.unique_zones)
  
  # List manipulation
  first_server = element(var.servers, 0)
  last_server = element(var.servers, length(var.servers) - 1)
  
  # Slicing
  first_two = slice(var.servers, 0, 2)
  
  # Reversing
  reversed_servers = reverse(var.servers)
  
  # Sorting
  sorted_by_name = sort([for s in var.servers : s.name])
  
  # Map operations
  server_map = { for s in var.servers : s.name => s }
  
  # Flattening
  nested_list = [["a", "b"], ["c", "d"]]
  flattened = flatten(local.nested_list)        # ["a", "b", "c", "d"]
  
  # Set operations
  set_a = toset(["a", "b", "c"])
  set_b = toset(["b", "c", "d"])
  union_set = setunion(local.set_a, local.set_b)        # ["a", "b", "c", "d"]
  intersect_set = setintersection(local.set_a, local.set_b)  # ["b", "c"]
  subtract_set = setsubtract(local.set_a, local.set_b)       # ["a"]
  
  # Checking membership
  contains_web = contains([for s in var.servers : s.type], "web")  # true
  
  # Index operations
  web_index = index([for s in var.servers : s.type], "web")  # 0
}
```

### Date and Time Functions

```hcl
locals {
  # Current timestamp
  current_time = timestamp()                   # "2024-01-15T10:30:00Z"
  
  # Date formatting
  formatted_date = formatdate("YYYY-MM-DD", local.current_time)
  human_readable = formatdate("MMM DD, YYYY", local.current_time)
  
  # Time calculations (using timeadd)
  future_time = timeadd(local.current_time, "720h")  # 30 days from now
  past_time = timeadd(local.current_time, "-24h")    # 24 hours ago
  
  # Common date patterns
  date_suffix = formatdate("YYYYMMDD", local.current_time)
  backup_timestamp = formatdate("YYYY-MM-DD-hhmm", local.current_time)
}

# Practical date function usage
resource "aws_s3_bucket_object" "backup" {
  bucket = aws_s3_bucket.backups.bucket
  key    = "backup-${local.date_suffix}.tar.gz"
  source = "/tmp/backup.tar.gz"
  
  tags = {
    CreatedDate = local.formatted_date
    ExpiryDate  = formatdate("YYYY-MM-DD", local.future_time)
  }
}
```

### Advanced Function Combinations

```hcl
variable "configuration" {
  type = map(any)
  default = {
    environments = ["dev", "staging", "prod"]
    regions = ["us-east-1", "us-west-2"]
    instance_types = {
      dev = "t3.micro"
      staging = "t3.small"
      prod = "t3.large"
    }
  }
}

locals {
  # Complex function chaining
  all_combinations = flatten([
    for env in var.configuration.environments : [
      for region in var.configuration.regions : {
        environment = env
        region = region
        instance_type = lookup(var.configuration.instance_types, env, "t3.micro")
        name = "${env}-${region}"
      }
    ]
  ])
  
  # Validation using functions
  valid_environments = alltrue([
    for env in var.configuration.environments : 
    contains(keys(var.configuration.instance_types), env)
  ])
  
  # Conditional function usage
  processed_config = {
    for combo in local.all_combinations : combo.name => merge(combo, {
      backup_enabled = combo.environment == "prod"
      monitoring_level = combo.environment == "prod" ? "detailed" : "basic"
    })
  }
}
```

## Resource Dependencies

### Implicit Dependencies

```hcl
# Terraform automatically creates dependencies based on resource references
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  count = 2
  
  # Implicit dependency on aws_vpc.main
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

resource "aws_internet_gateway" "main" {
  # Implicit dependency on aws_vpc.main
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public" {
  # Implicit dependency on aws_vpc.main
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    # Implicit dependency on aws_internet_gateway.main
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "public-rt"
  }
}
```

### Explicit Dependencies

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public[0].id
  
  # Explicit dependency - ensures S3 bucket exists before instance creation
  depends_on = [
    aws_s3_bucket.app_data,
    aws_iam_role_policy_attachment.s3_access
  ]
  
  user_data = templatefile("${path.module}/user_data.sh", {
    bucket_name = aws_s3_bucket.app_data.bucket
  })
  
  tags = {
    Name = "web-server"
  }
}

resource "aws_s3_bucket" "app_data" {
  bucket = "my-app-data-${random_string.bucket_suffix.result}"
  
  tags = {
    Name = "application-data"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  
  # This resource has implicit dependency on aws_iam_role.ec2_role
  # but we might reference it in depends_on elsewhere
}
```

### Data Source Dependencies

```hcl
# Data sources also create dependencies
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "app-template"
  # Implicit dependency on data.aws_ami.ubuntu
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  # Implicit dependency on aws_iam_instance_profile.app
  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    # These create implicit dependencies
    database_url = aws_db_instance.main.endpoint
    cache_url    = aws_elasticache_cluster.main.cache_nodes[0].address
  }))
}
```

### Complex Dependency Scenarios

```hcl
# Module with complex dependencies
module "networking" {
  source = "./modules/networking"
  
  vpc_cidr = "10.0.0.0/16"
  azs      = data.aws_availability_zones.available.names
}

module "database" {
  source = "./modules/database"
  
  # Explicit dependency on networking module
  depends_on = [module.networking]
  
  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnet_ids
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

module "application" {
  source = "./modules/application"
  
  # Multiple dependencies
  depends_on = [
    module.networking,
    module.database,
    aws_ssm_parameter.app_config
  ]
  
  vpc_id           = module.networking.vpc_id
  public_subnets   = module.networking.public_subnet_ids
  private_subnets  = module.networking.private_subnet_ids
  database_url     = module.database.connection_string
  
  app_version = var.app_version
}

# Parameter that might be created by external process
resource "aws_ssm_parameter" "app_config" {
  name  = "/app/config"
  type  = "String"
  value = jsonencode({
    feature_flags = var.feature_flags
    api_keys     = var.api_keys
  })
  
  tags = {
    Environment = var.environment
  }
}
```

## Resource Lifecycle Rules

### Basic Lifecycle Rules

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = true
    
    # Create new resource before destroying old one
    create_before_destroy = true
    
    # Ignore changes to specific attributes
    ignore_changes = [
      ami,           # Ignore AMI changes
      user_data,     # Ignore user data changes
      tags["LastUpdated"]  # Ignore specific tag changes
    ]
  }
  
  tags = {
    Name        = "web-server"
    LastUpdated = timestamp()
  }
}
```

### Environment-Specific Lifecycle Rules

```hcl
locals {
  is_production = var.environment == "production"
}

resource "aws_db_instance" "main" {
  identifier = "${var.app_name}-${var.environment}-db"
  
  engine         = "postgres"
  engine_version = "13.7"
  instance_class = var.db_instance_class
  
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  
  backup_window      = "03:00-04:00"
  backup_retention_period = local.is_production ? 30 : 7
  
  lifecycle {
    # Production databases should never be accidentally destroyed
    prevent_destroy = local.is_production
    
    # For production, create new before destroying to minimize downtime
    create_before_destroy = local.is_production
    
    # Ignore changes that might be managed outside Terraform
    ignore_changes = [
      password,              # Password might be rotated externally
      backup_window,         # Backup window might be adjusted for maintenance
      maintenance_window     # Maintenance window might be managed separately
    ]
  }
  
  tags = {
    Name        = "${var.app_name}-${var.environment}-database"
    Environment = var.environment
    BackupPolicy = local.is_production ? "critical" : "standard"
  }
}
```

### Advanced Lifecycle Patterns

```hcl
# Blue-Green Deployment Pattern
resource "aws_launch_template" "app" {
  name_prefix = "${var.app_name}-${var.environment}-"
  
  image_id      = var.ami_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  lifecycle {
    # Always create new launch template before destroying old one
    create_before_destroy = true
    
    # Ignore changes to the name since we're using name_prefix
    ignore_changes = [name]
  }
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    app_version = var.app_version
    config_hash = md5(jsonencode(var.app_config))
  }))
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.app_name}-${var.environment}"
      Version = var.app_version
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name = "${var.app_name}-${var.environment}-asg"
  
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  
  # Reference the latest launch template
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  
  lifecycle {
    # Create new ASG before destroying old one for zero-downtime deployments
    create_before_destroy = true
    
    # Ignore changes to desired_capacity as it might be managed by auto-scaling
    ignore_changes = [desired_capacity]
  }
  
  # Instance refresh configuration for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup       = 300
    }
  }
  
  tag {
    key                 = "Name"
    value               = "${var.app_name}-${var.environment}-instance"
    propagate_at_launch = true
  }
}
```

### Conditional Lifecycle Rules

```hcl
resource "aws_s3_bucket" "data" {
  bucket = var.bucket_name
  
  lifecycle {
    # Only prevent destruction in production
    prevent_destroy = var.environment == "production"
    
    # Ignore changes to lifecycle configuration if managed externally
    ignore_changes = var.external_lifecycle_management ? [
      lifecycle_rule
    ] : []
  }
  
  tags = {
    Environment = var.environment
    DataClassification = var.environment == "production" ? "sensitive" : "internal"
  }
}

# Lifecycle rule that varies by environment
resource "aws_s3_bucket_lifecycle_configuration" "data" {
  count  = var.external_lifecycle_management ? 0 : 1
  bucket = aws_s3_bucket.data.id
  
  rule {
    id     = "main_lifecycle_rule"
    status = "Enabled"
    
    expiration {
      days = var.environment == "production" ? 2555 : 30  # 7 years vs 30 days
    }
    
    noncurrent_version_expiration {
      noncurrent_days = var.environment == "production" ? 90 : 1
    }
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
```

## Provisioners

### When to Use Provisioners

Provisioners should be used as a last resort when native Terraform resources or cloud-init/user-data aren't sufficient. Common use cases include:

- Running commands after resource creation
- Copying files to remote systems
- Bootstrapping configuration management tools
- Integration with external systems

### File Provisioner

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.web.id]
  
  # File provisioner to copy configuration files
  provisioner "file" {
    source      = "${path.module}/config/"
    destination = "/tmp/config"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  # Copy a single file with different permissions
  provisioner "file" {
    content = templatefile("${path.module}/app.conf.tpl", {
      database_url = aws_db_instance.main.endpoint
      redis_url    = aws_elasticache_cluster.main.cache_nodes[0].address
      app_secret   = var.app_secret
    })
    destination = "/tmp/app.conf"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  tags = {
    Name = "web-server"
  }
}
```

### Remote-Exec Provisioner

```hcl
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  # Remote-exec provisioner for initial setup
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx docker.io",
      "sudo systemctl enable nginx",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
      timeout     = "5m"
    }
  }
  
  # Configure application after copying files
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/app.conf /etc/myapp/app.conf",
      "sudo chown root:root /etc/myapp/app.conf",
      "sudo chmod 640 /etc/myapp/app.conf",
      "sudo systemctl restart myapp"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  tags = {
    Name = "app-server"
  }
}
```

### Local-Exec Provisioner

```hcl
resource "aws_instance" "database" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  
  vpc_security_group_ids = [aws_security_group.database.id]
  
  # Local-exec to update local inventory file
  provisioner "local-exec" {
    command = "echo '${self.private_ip} database-server' >> /etc/ansible/hosts"
  }
  
  # Local-exec to trigger external configuration management
  provisioner "local-exec" {
    command = "ansible-playbook -i /etc/ansible/hosts database-setup.yml --limit ${self.private_ip}"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      DB_PASSWORD = var.db_password
    }
  }
  
  # Local-exec for cleanup on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "sed -i '/${self.private_ip}/d' /etc/ansible/hosts"
  }
  
  tags = {
    Name = "database-server"
  }
}
```

### Advanced Provisioner Patterns

```hcl
# Null resource for provisioner-only operations
resource "null_resource" "cluster_setup" {
  # Triggers ensure this runs when cluster configuration changes
  triggers = {
    cluster_instance_ids = join(",", aws_instance.cluster[*].id)
    cluster_config_hash  = md5(jsonencode(var.cluster_config))
  }
  
  # Setup cluster configuration
  provisioner "local-exec" {
    command = templatefile("${path.module}/setup-cluster.sh.tpl", {
      master_ip = aws_instance.cluster[0].private_ip
      worker_ips = slice(aws_instance.cluster[*].private_ip, 1, length(aws_instance.cluster))
      cluster_token = var.cluster_token
    })
    
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig"
    }
  }
  
  # Cleanup on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl drain --all --ignore-daemonsets --force || true"
    
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig"
    }
  }
  
  depends_on = [aws_instance.cluster]
}

# Multiple instances with coordinated provisioning
resource "aws_instance" "cluster" {
  count = var.cluster_size
  
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index % length(var.subnet_ids)]
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.cluster.id]
  
  # Install base software on all nodes
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io kubeadm kubelet kubectl",
      "sudo systemctl enable docker kubelet"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  # Master node specific setup
  provisioner "remote-exec" {
    count = count.index == 0 ? 1 : 0
    
    inline = [
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  tags = {
    Name = "cluster-node-${count.index + 1}"
    Role = count.index == 0 ? "master" : "worker"
  }
}
```

### Provisioner Error Handling and Best Practices

```hcl
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  # Provisioner with error handling
  provisioner "remote-exec" {
    inline = [
      "set -e",  # Exit on any error
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "# Verify nginx is running",
      "sudo systemctl is-active nginx"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
      timeout     = "10m"
      
      # Connection retry logic
      agent       = false
      host_key    = ""
    }
    
    # Continue on failure for non-critical setup
    on_failure = continue
  }
  
  # Critical provisioner that must succeed
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/myapp",
      "sudo chown ubuntu:ubuntu /opt/myapp"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
    
    # Fail the entire resource if this fails
    on_failure = fail
  }
  
  tags = {
    Name = "app-server"
  }
}

# Alternative: Using cloud-init instead of provisioners
resource "aws_instance" "app_cloudinit" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  # cloud-init is more reliable than provisioners
  user_data = base64encode(templatefile("${path.module}/cloud-init.yml", {
    app_config = var.app_config
    database_url = aws_db_instance.main.endpoint
  }))
  
  tags = {
    Name = "app-server-cloudinit"
  }
}
```

### Provisioner Alternatives and Best Practices

```yaml
# cloud-init.yml - Better alternative to provisioners
#cloud-config
package_update: true
package_upgrade: true

packages:
  - nginx
  - docker.io
  - awscli

runcmd:
  - systemctl enable nginx docker
  - systemctl start nginx docker
  - usermod -aG docker ubuntu
  - |
    cat > /etc/nginx/sites-available/default <<EOF
    server {
        listen 80;
        location / {
            proxy_pass http://localhost:3000;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
    EOF
  - systemctl reload nginx

write_files:
  - path: /opt/app/config.json
    content: |
      ${jsonencode(app_config)}
    permissions: '0644'
  - path: /opt/app/database.conf
    content: |
      DATABASE_URL=${database_url}
    permissions: '0600'
    owner: ubuntu:ubuntu

final_message: "System setup completed successfully"
```

**Summary**

This guide covers the essential advanced Terraform configuration patterns:

**Local Values and Computed Values** help you avoid repetition and create dynamic configurations based on complex logic.

**Conditional Expressions** enable environment-specific and feature-flag-driven infrastructure provisioning.

**For Expressions and Loops** provide powerful ways to transform and manipulate data structures, enabling dynamic resource creation.

**Dynamic Blocks** allow you to create flexible resource configurations that adapt to input variables and conditions.

**Built-in Functions** offer extensive capabilities for string manipulation, numeric operations, collection processing, and date/time handling.

**Resource Dependencies** ensure proper creation order through both implicit references and explicit dependency declarations.

**Resource Lifecycle Rules** provide fine-grained control over resource creation, updates, and destruction patterns.

**Provisioners** should be used judiciously as a last resort, with cloud-init and native resources preferred when possible.

These patterns enable you to create more maintainable, flexible, and robust Terraform configurations that can adapt to changing requirements while following infrastructure-as-code best practices.

---

# Modules and Code Organization

## Module Fundamentals and Structure

Terraform modules are containers for multiple resources that work together to provide a specific functionality. Every Terraform configuration is technically a module, with the root module being your main working directory.

A well-structured module typically follows this directory layout:

```
module-name/
├── main.tf          # Primary resource definitions
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output value declarations
├── versions.tf      # Provider and Terraform version constraints
├── README.md        # Module documentation
└── examples/        # Usage examples
    └── basic/
        ├── main.tf
        └── variables.tf
```

The core principle is separation of concerns: each module should have a single, well-defined purpose and encapsulate related resources that are commonly deployed together.

## Input Variables, Outputs, and Locals in Modules

**Input Variables** define the module's interface, allowing customization:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.small, or t3.medium."
  }
}
```

**Outputs** expose values from the module for use by calling modules:

```hcl
output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.example.id
}
```

**Locals** define computed values used within the module:

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
```

## Module Composition and Nesting

Modules can call other modules, creating hierarchical compositions. This enables building complex infrastructure from smaller, reusable components:

```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}

module "web_servers" {
  source    = "./modules/ec2-cluster"
  vpc_id    = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
}
```

Best practices for composition include:

- Keep nesting levels reasonable (typically 2-3 levels maximum)
- Pass data between modules through outputs and variables
- Avoid tight coupling between modules
- Design modules to be independently testable

## Module Sources

Terraform supports multiple module sources:

**Local Paths**: Modules in the same repository

```hcl
module "example" {
  source = "./modules/example"
}
```

**Git Repositories**: Modules stored in version control

```hcl
module "example" {
  source = "git::https://github.com/company/terraform-modules.git//modules/example?ref=v1.0.0"
}
```

**Terraform Registry**: Public and private module registries

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
}
```

**HTTP URLs**: Modules distributed via HTTP

```hcl
module "example" {
  source = "https://example.com/modules/example.zip"
}
```

## Module Versioning Strategies

[Inference] Effective versioning is crucial for maintaining stable infrastructure:

**Semantic Versioning**: Follow semver (MAJOR.MINOR.PATCH) principles

- MAJOR: Breaking changes that require configuration updates
- MINOR: New features that are backward compatible
- PATCH: Bug fixes and small improvements

**Git Tagging Strategy**:

```bash
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin v1.2.3
```

**Version Constraints** in module calls:

```hcl
module "example" {
  source  = "company/example/aws"
  version = "~> 1.2"  # Allow 1.2.x, but not 1.3.x
}
```

**Branch-based Development**:

- Use `main` or `master` for stable releases
- Feature branches for development
- Release branches for preparing new versions

## Terraform Registry Usage

The Terraform Registry hosts both public and private modules:

**Public Registry** (registry.terraform.io):

- Browse verified modules from major cloud providers
- Community-contributed modules
- Automatic documentation generation
- Usage statistics and examples

**Private Registry**:

- Enterprise-only feature for proprietary modules
- Same interface as public registry
- Access control and organization management
- Integration with version control systems

**Publishing Modules**:

- Follow naming convention: `terraform-<PROVIDER>-<NAME>`
- Include proper documentation and examples
- Use semantic versioning with Git tags
- Maintain backward compatibility when possible

## Module Testing Approaches

[Inference] Several strategies exist for testing Terraform modules:

**Static Analysis**:

- `terraform validate`: Validates syntax and configuration
- `terraform fmt`: Ensures consistent formatting
- Third-party tools like `tflint` for additional checks

**Unit Testing**:

- Tools like Terratest (Go-based) for automated testing
- Test individual modules in isolation
- Verify outputs match expected values
- Clean up resources after tests

**Integration Testing**:

- Deploy complete infrastructure stacks
- Test interactions between modules
- Validate end-to-end functionality
- Performance and scalability testing

**Example Terratest Structure**:

```go
func TestTerraformExample(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/basic",
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Verify outputs
    instanceID := terraform.Output(t, terraformOptions, "instance_id")
    assert.NotEmpty(t, instanceID)
}
```

## Documentation Best Practices

Comprehensive documentation improves module adoption and maintenance:

**README.md Structure**:

- Purpose and use cases
- Usage examples with code blocks
- Input and output descriptions
- Requirements and dependencies
- Contributing guidelines

**Automated Documentation**:

- Tools like `terraform-docs` generate documentation from code
- Keep descriptions in variable and output blocks current
- Include validation rules and constraints

**Examples Directory**:

- Provide working examples for common use cases
- Include minimal and comprehensive scenarios
- Ensure examples are tested and maintained

**Inline Comments**:

- Explain complex logic or business requirements
- Document resource naming conventions
- Clarify non-obvious dependencies or relationships

**Changelog Maintenance**:

- Document breaking changes between versions
- List new features and bug fixes
- Provide migration guides for major version updates

[Unverified] The specific implementation details of testing frameworks and documentation tools may vary based on the versions and configurations used in different environments.

---

# Workspace Management and Environments

## Terraform Workspaces Concept

Terraform workspaces are named containers that allow you to manage multiple instances of the same infrastructure configuration. Each workspace maintains its own separate state file, enabling you to deploy the same Terraform configuration to different environments (development, staging, production) or for different purposes.

The concept addresses the need to maintain separate infrastructure instances while sharing the same configuration code. Workspaces operate on the principle of state isolation - each workspace has its own state file, but they all use the same Terraform configuration files.

Key characteristics of workspaces:

- Each workspace maintains independent state
- The same configuration can produce different infrastructure
- Workspace names can be referenced in configurations using `terraform.workspace`
- The "default" workspace is created automatically and cannot be deleted

## Local vs. Remote Workspaces

**Local Workspaces** store state files in subdirectories of your working directory:

- State files are stored in `terraform.tfstate.d/<workspace-name>/`
- Limited to single-user scenarios
- No built-in collaboration features
- Workspace switching is immediate and local

**Remote Workspaces** are managed by remote backends like Terraform Cloud:

- Each workspace has its own remote state storage
- Support for team collaboration and access controls
- Integrated CI/CD capabilities
- Variable management and run history
- Workspace-level permissions and policies

[Inference] Remote workspaces provide better collaboration and governance features, making them more suitable for team environments and production use cases.

## Environment Separation Patterns

Several patterns exist for organizing environments with Terraform:

**Workspace-Based Separation**:

```hcl
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
  tags = {
    Environment = terraform.workspace
  }
}
```

**Directory-Based Separation**:

```
environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
```

**Branch-Based Separation**: Different Git branches for each environment

- Each environment exists on its own branch
- Promotes through merging branches
- Can be combined with directory or workspace patterns

**Repository-Based Separation**: Separate repositories for each environment

- Complete isolation between environments
- Independent access controls and workflows
- Higher maintenance overhead

## Workspace-Specific Variable Files

Variable files can be organized to support different workspace configurations:

**Workspace-Specific tfvars Files**:

```
├── terraform.tfvars.dev
├── terraform.tfvars.staging
├── terraform.tfvars.prod
└── main.tf
```

**Conditional Variable Loading**:

```hcl
locals {
  env_vars = terraform.workspace == "prod" ? var.prod_config : var.dev_config
}
```

**Workspace Variable Interpolation**:

```hcl
variable "instance_counts" {
  type = map(number)
  default = {
    dev     = 1
    staging = 2
    prod    = 5
  }
}

resource "aws_instance" "web" {
  count = var.instance_counts[terraform.workspace]
}
```

## Directory Structure Strategies

**Monolithic Structure** (single directory with workspaces):

```
project/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.dev
├── terraform.tfvars.staging
└── terraform.tfvars.prod
```

**Environment-per-Directory Structure**:

```
project/
├── modules/
│   ├── vpc/
│   ├── ec2/
│   └── rds/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── shared/
    └── common.tf
```

**Layered Structure** (infrastructure layers):

```
project/
├── global/
│   ├── iam/
│   └── route53/
├── environments/
│   └── prod/
│       ├── networking/
│       ├── compute/
│       └── data/
└── modules/
```

[Inference] The choice of directory structure depends on factors like team size, complexity of infrastructure, deployment patterns, and organizational preferences.

## Configuration Drift Management

Configuration drift occurs when the actual infrastructure state differs from what Terraform expects based on its state file:

**Detection Methods**:

- `terraform plan`: Shows differences between desired and current state
- `terraform refresh`: Updates state file with current resource attributes
- Automated drift detection tools and monitoring
- Regular plan runs in CI/CD pipelines

**Common Causes of Drift**:

- Manual changes made outside of Terraform
- External systems modifying resources
- Resource attribute changes by cloud provider policies
- Incomplete or failed Terraform runs

**Prevention Strategies**:

- Implement proper access controls and policies
- Use resource-level protection mechanisms
- Regular automated plan checks
- Team training on Terraform workflows
- Documentation of approved manual intervention procedures

**Remediation Approaches**:

- `terraform apply`: Brings infrastructure back to desired state
- `terraform import`: Incorporates manually created resources
- Configuration updates to match intentional changes
- State file manipulation for complex scenarios

## Environment Promotion Workflows

[Inference] Several patterns exist for promoting changes through environments:

**Linear Promotion Workflow**:

```
Dev Environment → Staging Environment → Production Environment
```

- Changes flow sequentially through environments
- Each environment serves as a gate for the next
- Allows for testing and validation at each stage

**GitOps-Based Promotion**:

- Configuration changes committed to version control
- Automated pipelines deploy to environments based on branches/tags
- Pull request reviews serve as approval gates
- Audit trail through Git history

**Blue-Green Deployment Pattern**:

- Maintain parallel environments (blue and green)
- Deploy to inactive environment first
- Switch traffic after validation
- Provides quick rollback capability

**Canary Deployment Integration**:

- Deploy changes to subset of infrastructure first
- Monitor metrics and performance
- Gradually expand deployment scope
- Automatic rollback on failure detection

**Approval and Gating Mechanisms**:

- Manual approval steps for production deployments
- Automated testing gates between environments
- Policy-as-code validation (Sentinel, OPA)
- Integration with change management systems

**Rollback Strategies**:

- Version-tagged infrastructure configurations
- State file backups before major changes
- Infrastructure snapshots where applicable
- Documented rollback procedures and runbooks

[Unverified] The specific implementation details of promotion workflows may vary significantly based on the tools, platforms, and organizational processes used in different environments.

The effectiveness of these workflows depends on proper implementation of monitoring, testing, and rollback procedures, which should be validated through regular practice and documentation updates.

---

# Advanced Provider Features

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

## Provider Configuration Inheritance

Provider configurations can be inherited and customized across different levels of your Terraform configuration:

**Root Module Provider Configuration**: The root module defines default provider configurations that child modules inherit unless explicitly overridden.

**Module Provider Requirements**:

```hcl
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.alternate]
    }
  }
}
```

**Provider Configuration Block Inheritance**: Child modules inherit provider configurations from their parent, but can specify required provider aliases for specific configurations.

[Inference] Provider inheritance follows Terraform's scoping rules, where child modules receive provider instances from their calling context unless explicitly configured otherwise.

## Custom Provider Development Basics

Custom providers extend Terraform's capabilities to manage resources not covered by existing providers:

**Provider Framework Structure**:

- Provider schema definition
- Resource and data source implementations
- CRUD operations (Create, Read, Update, Delete)
- Error handling and validation

**Basic Provider Structure** (using Terraform Plugin Framework):

```go
func New() provider.Provider {
    return &ExampleProvider{}
}

type ExampleProvider struct{}

func (p *ExampleProvider) Schema(context.Context, provider.SchemaRequest, *provider.SchemaResponse) {
    // Define provider configuration schema
}

func (p *ExampleProvider) Configure(context.Context, provider.ConfigureRequest, *provider.ConfigureResponse) {
    // Configure provider client
}
```

**Development Requirements**:

- Go programming language knowledge
- Understanding of the target API or system
- Terraform Plugin SDK or Framework
- Testing infrastructure and methodologies

**Distribution Methods**:

- Terraform Registry (public or private)
- Local development builds
- Direct binary distribution
- Version control system integration

[Unverified] The specific implementation details and APIs for custom provider development may change with different versions of the Terraform Plugin SDK or Framework.

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

## Provider-Specific Best Practices

### AWS Best Practices

**Resource Tagging Strategy**:

```hcl
locals {
  common_tags = {
    Environment   = var.environment
    Project       = var.project_name
    ManagedBy     = "terraform"
    CostCenter    = var.cost_center
    Owner         = var.owner
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}
```

**IAM Resource Management**:

- Use data sources for existing IAM resources when possible
- Implement proper IAM policy versioning
- Avoid overly permissive policies
- Use IAM roles instead of users for application access

**Cost Optimization Patterns**:

- Implement proper resource lifecycle management
- Use appropriate instance sizing
- Leverage spot instances where applicable
- Implement automated resource cleanup

### Azure Best Practices

**Resource Group Organization**:

```hcl
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
```

**Naming Convention Implementation**:

```hcl
locals {
  naming_convention = {
    resource_group = "${var.project}-${var.environment}-rg"
    storage_account = "${var.project}${var.environment}sa"
    key_vault = "${var.project}-${var.environment}-kv"
  }
}
```

### Google Cloud Platform Best Practices

**Project Organization**:

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com"
  ])
  
  service = each.key
  
  disable_dependent_services = true
}
```

**IAM and Security**:

- Use service accounts for application authentication
- Implement proper IAM role bindings
- Enable audit logging and monitoring
- Use Google Cloud KMS for encryption key management

[Inference] These best practices are based on commonly recommended patterns, but specific implementations may vary based on organizational requirements and security policies.

[Unverified] The exact syntax and available features for provider configurations may vary between different provider versions and may change with future updates.

---

# Security and Compliance Guide

## 1. Sensitive Data Handling

### State File Security

- **Remote State Storage**: Always use remote backends with encryption
    - S3 with server-side encryption (SSE-S3, SSE-KMS)
    - Azure Blob Storage with encryption
    - GCS with server-side encryption
    - Terraform Cloud with encryption at rest
- **State Locking**: Prevent concurrent modifications using DynamoDB (AWS) or similar
- **Access Control**: Limit state file access to authorized users/systems only
- **Backup Strategy**: Implement versioning and backup for state files

### Sensitive Variables and Outputs

```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

output "database_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = false
}

output "database_password" {
  value     = var.database_password
  sensitive = true
}
```

### Environment Variables

- Use `TF_VAR_` prefix for sensitive variables
- Avoid hardcoding secrets in `.tf` files
- Use `.tfvars` files with proper access controls (never commit to VCS)

## 2. Secret Management Integration

### HashiCorp Vault Integration

#### Basic Vault Provider Configuration

```hcl
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

provider "vault" {
  address = "https://vault.example.com"
  # Authentication methods: token, aws, kubernetes, etc.
}
```

#### Dynamic Database Credentials

```hcl
# Configure database secrets engine
resource "vault_database_secrets_mount" "db" {
  path = "database"

  mysql {
    name           = "my-database"
    connection_url = "{{username}}:{{password}}@tcp(localhost:3306)/"
    username       = "vault"
    password       = "vault-password"
  }
}

# Create database role
resource "vault_database_secret_backend_role" "role" {
  backend     = vault_database_secrets_mount.db.path
  name        = "app-role"
  db_name     = "my-database"
  creation_statements = [
    "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';",
    "GRANT SELECT ON *.* TO '{{name}}'@'%';"
  ]
  default_ttl = 3600
  max_ttl     = 7200
}

# Generate dynamic credentials
data "vault_generic_secret" "db_creds" {
  path = "${vault_database_secrets_mount.db.path}/creds/${vault_database_secret_backend_role.role.name}"
}
```

#### PKI Certificate Management

```hcl
resource "vault_pki_secret_backend" "pki" {
  path        = "pki"
  default_ttl = 3600
  max_ttl     = 86400
}

resource "vault_pki_secret_backend_role" "role" {
  backend        = vault_pki_secret_backend.pki.path
  name           = "web-server"
  allowed_domains = ["example.com"]
  allow_subdomains = true
  max_ttl        = 86400
}

data "vault_pki_secret_backend_cert" "cert" {
  backend     = vault_pki_secret_backend.pki.path
  role        = vault_pki_secret_backend_role.role.name
  common_name = "web.example.com"
}
```

### AWS Secrets Manager Integration

#### Creating and Managing Secrets

```hcl
resource "aws_secretsmanager_secret" "app_secret" {
  name        = "app/database/credentials"
  description = "Database credentials for application"
  
  replica {
    region = "us-west-2"
  }
}

resource "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
  })
}

# Automatic rotation
resource "aws_secretsmanager_secret_rotation" "app_secret_rotation" {
  secret_id           = aws_secretsmanager_secret.app_secret.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn
  
  rotation_rules {
    automatically_after_days = 30
  }
}
```

#### Retrieving Secrets

```hcl
data "aws_secretsmanager_secret" "app_secret" {
  name = "app/database/credentials"
}

data "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id = data.aws_secretsmanager_secret.app_secret.id
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.app_secret_version.secret_string)
}

resource "aws_db_instance" "main" {
  # ... other configuration
  username = local.db_creds.username
  password = local.db_creds.password
}
```

### Azure Key Vault Integration

```hcl
data "azurerm_key_vault" "main" {
  name                = "example-keyvault"
  resource_group_name = "example-rg"
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "database-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_mysql_server" "main" {
  # ... other configuration
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value
}
```

## 3. Terraform Cloud/Enterprise Security Features

### Workspace Security

- **Private Module Registry**: Centralized, version-controlled modules
- **Environment Variables**: Marked as sensitive to prevent exposure
- **VCS Integration**: Branch protection and pull request workflows
- **Run Environment**: Isolated execution environments

### Access Control

```hcl
# Organization-level permissions
resource "tfe_organization_membership" "member" {
  organization = "my-org"
  email        = "user@example.com"
}

# Team-based access
resource "tfe_team" "developers" {
  name         = "developers"
  organization = "my-org"
}

resource "tfe_team_access" "workspace_access" {
  access       = "write"
  team_id      = tfe_team.developers.id
  workspace_id = tfe_workspace.main.id
}
```

### SSO Integration

- SAML 2.0 support
- OIDC integration
- Multi-factor authentication enforcement
- Just-in-time user provisioning

## 4. Compliance Scanning and Policy as Code

### Sentinel Policies (Enterprise)

```sentinel
# Cost management policy
import "tfplan/v2" as tfplan
import "decimal"

main = rule {
  all tfplan.resource_changes as _, changes {
    changes.type is "aws_instance" and
    changes.change.after.instance_type in ["t3.micro", "t3.small", "t3.medium"]
  }
}
```

### Open Policy Agent (OPA) Integration

```rego
package terraform.security

# Deny S3 buckets without encryption
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not resource.change.after.server_side_encryption_configuration
  
  msg := sprintf("S3 bucket %s must have encryption enabled", [resource.address])
}

# Require specific tags
required_tags := ["Environment", "Owner", "Project"]

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"
  missing_tags := required_tags - object.get(resource.change.after, "tags", {})
  count(missing_tags) > 0
  
  msg := sprintf("Instance %s missing required tags: %v", [resource.address, missing_tags])
}
```

### Static Analysis Tools Configuration

#### tfsec

```yaml
# .tfsec/config.yml
exclude:
  - aws-s3-enable-logging
  - aws-vpc-enable-flow-logs

severity_overrides:
  aws-s3-encryption-customer-key: ERROR
```

#### Checkov

```yaml
# .checkov.yaml
framework:
  - terraform
quiet: true
skip-check:
  - CKV_AWS_18  # S3 Bucket should have access logging configured
output: sarif
```

## 5. Resource Tagging Strategies

### Default Tags Configuration

```hcl
provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment   = var.environment
      ManagedBy     = "Terraform"
      Project       = var.project_name
      Owner         = var.owner
      CostCenter    = var.cost_center
      Compliance    = var.compliance_framework
    }
  }
}
```

### Dynamic Tagging Module

```hcl
# modules/tagging/main.tf
locals {
  common_tags = {
    Environment    = var.environment
    Project        = var.project
    Owner          = var.owner
    CreatedBy      = "Terraform"
    CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
    LastModified   = formatdate("YYYY-MM-DD", timestamp())
  }
  
  compliance_tags = var.compliance_framework != "" ? {
    ComplianceFramework = var.compliance_framework
    DataClassification  = var.data_classification
    RetentionPeriod    = var.retention_period
  } : {}
  
  all_tags = merge(local.common_tags, local.compliance_tags, var.additional_tags)
}

output "tags" {
  value = local.all_tags
}
```

### Cost Allocation Tags

```hcl
locals {
  cost_tags = {
    CostCenter    = var.cost_center
    Department    = var.department
    Application   = var.application_name
    Environment   = var.environment
    BillingCode   = var.billing_code
  }
}
```

## 6. Access Control and Permissions

### IAM Roles for Terraform

```hcl
# Terraform execution role
resource "aws_iam_role" "terraform_role" {
  name = "TerraformExecutionRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Least privilege policy
resource "aws_iam_role_policy" "terraform_policy" {
  name = "TerraformPolicy"
  role = aws_iam_role.terraform_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### Cross-Account Access

```hcl
# Assume role provider
provider "aws" {
  alias  = "production"
  region = "us-east-1"
  
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/TerraformCrossAccountRole"
  }
}
```

### Service Account Management

```hcl
# Google Cloud service account
resource "google_service_account" "terraform_sa" {
  account_id   = "terraform-sa"
  display_name = "Terraform Service Account"
  project      = var.project_id
}

resource "google_service_account_key" "terraform_key" {
  service_account_id = google_service_account.terraform_sa.name
}

# Azure service principal
resource "azuread_application" "terraform_app" {
  display_name = "Terraform Application"
}

resource "azuread_service_principal" "terraform_sp" {
  application_id = azuread_application.terraform_app.application_id
}
```

## 7. Audit Logging and Monitoring

### Terraform Cloud Audit Logs

- All API operations logged
- Plan and apply execution records
- State file access tracking
- User authentication events
- Policy evaluation results

### Cloud Provider Integration

#### AWS CloudTrail

```hcl
resource "aws_cloudtrail" "terraform_audit" {
  name           = "terraform-audit-trail"
  s3_bucket_name = aws_s3_bucket.audit_logs.bucket
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.terraform_state.arn}/*"]
    }
  }
  
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
}
```

#### Azure Activity Log Integration

```hcl
resource "azurerm_monitor_activity_log_alert" "terraform_changes" {
  name                = "terraform-resource-changes"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_resource_group.main.id]
  
  criteria {
    resource_provider = "Microsoft.Resources"
    operation_name    = "Microsoft.Resources/deployments/write"
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}
```

### Monitoring and Alerting

```hcl
# CloudWatch alarms for Terraform operations
resource "aws_cloudwatch_metric_alarm" "terraform_failures" {
  alarm_name          = "terraform-apply-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors terraform apply failures"
  
  dimensions = {
    FunctionName = aws_lambda_function.terraform_runner.function_name
  }
}
```

### Compliance Reporting

```hcl
# Generate compliance reports
data "aws_caller_identity" "current" {}

locals {
  compliance_report = {
    account_id        = data.aws_caller_identity.current.account_id
    terraform_version = "1.5.0"
    last_scan_date   = timestamp()
    policy_violations = []
    encrypted_resources = [
      # List of encrypted resources
    ]
  }
}

resource "local_file" "compliance_report" {
  content  = jsonencode(local.compliance_report)
  filename = "compliance-report-${formatdate("YYYY-MM-DD", timestamp())}.json"
}
```

## Best Practices Summary

### Security Checklist

- [ ] Remote state with encryption enabled
- [ ] Sensitive variables properly marked
- [ ] Secrets managed through dedicated services
- [ ] Least privilege IAM policies
- [ ] Regular credential rotation
- [ ] Audit logging enabled
- [ ] Compliance scanning integrated
- [ ] Consistent resource tagging
- [ ] Network security controls
- [ ] Regular security assessments

### Compliance Framework Alignment

- **SOC 2**: Audit logging, access controls, encryption
- **PCI DSS**: Network segmentation, encryption, access monitoring
- **HIPAA**: Data encryption, access controls, audit trails
- **GDPR**: Data protection, access controls, audit capabilities
- **ISO 27001**: Security management, risk assessment, controls

### Continuous Improvement

- Regular policy updates
- Security training for teams
- Automated compliance checking
- Incident response procedures
- Regular access reviews
- Vulnerability assessments

---

# Testing and Validation Guide

## 1. Unit Testing with Terratest

### What is Terratest?

Terratest is a Go testing library that provides patterns and helper functions for testing infrastructure code. It allows you to write automated tests that deploy real infrastructure and validate it works correctly.

### Basic Setup

```go
// test/terraform_example_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformBasicExample(t *testing.T) {
    t.Parallel()

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../examples/basic",
        Vars: map[string]interface{}{
            "instance_name": "terratest-example",
            "instance_type": "t2.micro",
        },
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Validate outputs
    instanceId := terraform.Output(t, terraformOptions, "instance_id")
    publicIp := terraform.Output(t, terraformOptions, "public_ip")
    
    assert.NotEmpty(t, instanceId)
    assert.Regexp(t, `^i-[a-zA-Z0-9]+$`, instanceId)
    assert.Regexp(t, `^\d+\.\d+\.\d+\.\d+$`, publicIp)
}
```

### Advanced Terratest Patterns

```go
func TestTerraformWithRetries(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/web-server",
        RetryableTerraformErrors: map[string]string{
            "RequestError: send request failed": "Temporary AWS API error",
        },
        MaxRetries:         3,
        TimeBetweenRetries: 5 * time.Second,
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Test HTTP endpoint
    url := terraform.Output(t, terraformOptions, "url")
    http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 5*time.Second)
}
```

### Testing Multiple Environments

```go
func TestTerraformMultipleEnvironments(t *testing.T) {
    environments := []string{"dev", "staging", "prod"}
    
    for _, env := range environments {
        env := env // capture range variable
        t.Run(env, func(t *testing.T) {
            t.Parallel()
            
            terraformOptions := &terraform.Options{
                TerraformDir: "../environments/" + env,
                VarFiles: []string{"../config/" + env + ".tfvars"},
            }
            
            defer terraform.Destroy(t, terraformOptions)
            terraform.InitAndApply(t, terraformOptions)
            
            // Environment-specific validations
            validateEnvironment(t, terraformOptions, env)
        })
    }
}
```

## 2. Integration Testing Strategies

### Cross-Module Testing

```go
func TestNetworkingAndCompute(t *testing.T) {
    // Deploy networking first
    networkOptions := &terraform.Options{
        TerraformDir: "../modules/networking",
    }
    defer terraform.Destroy(t, networkOptions)
    terraform.InitAndApply(t, networkOptions)

    // Get networking outputs
    vpcId := terraform.Output(t, networkOptions, "vpc_id")
    subnetIds := terraform.OutputList(t, networkOptions, "subnet_ids")

    // Deploy compute using networking outputs
    computeOptions := &terraform.Options{
        TerraformDir: "../modules/compute",
        Vars: map[string]interface{}{
            "vpc_id":     vpcId,
            "subnet_ids": subnetIds,
        },
    }
    defer terraform.Destroy(t, computeOptions)
    terraform.InitAndApply(t, computeOptions)

    // Validate integration
    instanceId := terraform.Output(t, computeOptions, "instance_id")
    validateInstanceInVPC(t, instanceId, vpcId)
}
```

### End-to-End Testing

```go
func TestCompleteInfrastructure(t *testing.T) {
    // Deploy complete stack
    terraformOptions := &terraform.Options{
        TerraformDir: "../complete-example",
        VarFiles: []string{"test.tfvars"},
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Test application functionality
    loadBalancerUrl := terraform.Output(t, terraformOptions, "load_balancer_url")
    
    // Test health endpoints
    http_helper.HttpGetWithRetry(t, loadBalancerUrl+"/health", nil, 200, "OK", 30, 5*time.Second)
    
    // Test database connectivity
    dbEndpoint := terraform.Output(t, terraformOptions, "database_endpoint")
    validateDatabaseConnectivity(t, dbEndpoint)
    
    // Test auto-scaling
    validateAutoScaling(t, terraformOptions)
}
```

## 3. Policy Testing with OPA/Sentinel

### Open Policy Agent (OPA) Testing

#### Policy Example

```rego
# policies/security.rego
package terraform.security

import data.terraform.plan as tfplan

# Deny S3 buckets without encryption
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not resource.change.after.server_side_encryption_configuration
    
    msg := sprintf("S3 bucket '%s' must have encryption enabled", [resource.address])
}

# Require specific instance types
allowed_instance_types := ["t2.micro", "t2.small", "t3.micro", "t3.small"]

deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_instance"
    not resource.change.after.instance_type in allowed_instance_types
    
    msg := sprintf("Instance '%s' uses disallowed instance type '%s'", 
        [resource.address, resource.change.after.instance_type])
}
```

#### Testing Policies

```bash
# Test policy with sample plan
opa test policies/ test_data/

# Run policy against Terraform plan
terraform plan -out=plan.out
terraform show -json plan.out > plan.json
opa eval -d policies/ -i plan.json "data.terraform.security.deny[x]"
```

### Sentinel Testing

#### Policy Example

```hcl
# policies/aws-security.sentinel
import "tfplan/v2" as tfplan

# Find all S3 buckets
s3_buckets = filter tfplan.resource_changes as _, rc {
    rc.type is "aws_s3_bucket" and
    rc.mode is "managed" and
    (rc.change.actions contains "create" or rc.change.actions contains "update")
}

# Rule: S3 buckets must have versioning enabled
bucket_versioning_enabled = rule {
    all s3_buckets as _, bucket {
        bucket.change.after.versioning[0].enabled is true
    }
}

# Main rule
main = rule {
    bucket_versioning_enabled
}
```

#### Testing Sentinel Policies

```bash
# Test policy
sentinel test

# Apply policy to plan
sentinel apply -config=sentinel.hcl aws-security.sentinel
```

## 4. Static Analysis Tools

### TFLint Configuration

```hcl
# .tflint.hcl
plugin "aws" {
    enabled = true
    version = "0.21.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_deprecated_interpolation" {
    enabled = true
}

rule "terraform_unused_declarations" {
    enabled = true
}

rule "terraform_comment_syntax" {
    enabled = true
}

rule "terraform_documented_outputs" {
    enabled = true
}

rule "terraform_documented_variables" {
    enabled = true
}

rule "terraform_typed_variables" {
    enabled = true
}

rule "terraform_module_pinned_source" {
    enabled = true
}

rule "terraform_naming_convention" {
    enabled = true
    format  = "snake_case"
}

rule "terraform_standard_module_structure" {
    enabled = true
}
```

### Checkov Configuration

```yaml
# .checkov.yml
framework:
  - terraform
  - terraform_plan

skip-check:
  - CKV_AWS_20  # S3 Bucket should not allow public read access
  - CKV_AWS_21  # S3 Bucket should not allow public write access

soft-fail: true

output: cli
quiet: false
compact: false

include-all-checkov-policies: true

evaluate-variables: true
```

### CI/CD Integration

```yaml
# .github/workflows/terraform-validation.yml
name: Terraform Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Format
      run: terraform fmt -check -recursive
    
    - name: Terraform Init
      run: terraform init
    
    - name: Terraform Validate
      run: terraform validate
    
    - name: Setup TFLint
      uses: terraform-linters/setup-tflint@v3
    
    - name: Run TFLint
      run: |
        tflint --init
        tflint
    
    - name: Run Checkov
      uses: bridgecrewio/checkov-action@master
      with:
        directory: .
        framework: terraform
        soft_fail: true
```

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

## 6. Contract Testing Between Modules

### Module Interface Testing

```go
// test/module_contract_test.go
func TestModuleContract(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/networking",
        Vars: map[string]interface{}{
            "cidr_block": "10.0.0.0/16",
            "environment": "test",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Test required outputs exist
    requiredOutputs := []string{
        "vpc_id",
        "public_subnet_ids",
        "private_subnet_ids",
        "vpc_cidr_block",
    }
    
    for _, output := range requiredOutputs {
        value := terraform.Output(t, terraformOptions, output)
        assert.NotEmpty(t, value, "Output %s should not be empty", output)
    }
    
    // Test output formats
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.Regexp(t, `^vpc-[a-zA-Z0-9]+$`, vpcId)
    
    subnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
    assert.GreaterOrEqual(t, len(subnetIds), 2, "Should create at least 2 public subnets")
    
    for _, subnetId := range subnetIds {
        assert.Regexp(t, `^subnet-[a-zA-Z0-9]+$`, subnetId)
    }
}
```

### Module Compatibility Testing

```hcl
# test/compatibility/main.tf
module "networking" {
  source = "../../modules/networking"
  
  cidr_block  = "10.0.0.0/16"
  environment = "test"
}

module "compute" {
  source = "../../modules/compute"
  
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.networking.default_security_group_id]
}

# Test that modules work together
output "integration_test" {
  value = {
    vpc_id      = module.networking.vpc_id
    instance_id = module.compute.instance_id
    # This should not error if modules are compatible
    test_passed = length(module.compute.instance_id) > 0
  }
}
```

## 7. Performance Testing for Large Deployments

### Performance Test Setup

```go
func TestLargeDeploymentPerformance(t *testing.T) {
    startTime := time.Now()
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/large-deployment",
        Vars: map[string]interface{}{
            "instance_count": 100,
            "parallelism": 10,
        },
        PlanFilePath: "large-deployment.tfplan",
    }
    
    // Measure plan time
    planStart := time.Now()
    terraform.InitAndPlan(t, terraformOptions)
    planDuration := time.Since(planStart)
    
    // Measure apply time
    applyStart := time.Now()
    terraform.Apply(t, terraformOptions)
    applyDuration := time.Since(applyStart)
    
    defer func() {
        destroyStart := time.Now()
        terraform.Destroy(t, terraformOptions)
        destroyDuration := time.Since(destroyStart)
        
        t.Logf("Performance metrics:")
        t.Logf("Plan duration: %v", planDuration)
        t.Logf("Apply duration: %v", applyDuration)
        t.Logf("Destroy duration: %v", destroyDuration)
        t.Logf("Total duration: %v", time.Since(startTime))
    }()
    
    // Performance assertions
    assert.Less(t, planDuration, 10*time.Minute, "Plan should complete within 10 minutes")
    assert.Less(t, applyDuration, 30*time.Minute, "Apply should complete within 30 minutes")
}
```

### State Management Performance

```bash
#!/bin/bash
# performance-test.sh

# Test state operations with large state file
echo "Testing state operations..."

# Measure state list time
time terraform state list > /dev/null

# Measure state show time for random resource
RESOURCE=$(terraform state list | shuf -n 1)
time terraform state show "$RESOURCE" > /dev/null

# Measure refresh time
time terraform refresh > /dev/null

# Test with different parallelism settings
for parallelism in 5 10 20 50; do
    echo "Testing with parallelism: $parallelism"
    time terraform plan -parallelism=$parallelism -out="plan-$parallelism.tfplan" > /dev/null
done
```

### Memory and Resource Monitoring

```go
func TestMemoryUsage(t *testing.T) {
    // Monitor memory usage during large deployments
    var memStats runtime.MemStats
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/memory-intensive",
    }
    
    runtime.GC()
    runtime.ReadMemStats(&memStats)
    initialMem := memStats.Alloc
    
    terraform.InitAndApply(t, terraformOptions)
    defer terraform.Destroy(t, terraformOptions)
    
    runtime.GC()
    runtime.ReadMemStats(&memStats)
    finalMem := memStats.Alloc
    
    memoryIncrease := finalMem - initialMem
    t.Logf("Memory increase during test: %d bytes", memoryIncrease)
    
    // Assert memory usage is reasonable (example: less than 1GB increase)
    assert.Less(t, memoryIncrease, uint64(1024*1024*1024), 
        "Memory usage should not increase by more than 1GB")
}
```

## Best Practices Summary

### Test Organization

- Use the test pyramid: static analysis → unit tests → integration tests → e2e tests
- Run static analysis on every commit
- Execute unit tests on pull requests
- Perform integration tests in isolated environments
- Run performance tests periodically

### CI/CD Integration

```yaml
# Complete testing pipeline
stages:
  - validate
  - unit-test
  - integration-test
  - policy-check
  - performance-test

validate:
  script:
    - terraform fmt -check
    - terraform validate
    - tflint
    - checkov -d .

unit-test:
  script:
    - go test -v ./test/unit/...

integration-test:
  script:
    - go test -v ./test/integration/...

policy-check:
  script:
    - terraform plan -out=plan.out
    - terraform show -json plan.out | opa eval -d policies/
```

### Testing Guidelines

1. **Isolate tests**: Each test should clean up after itself
2. **Use realistic data**: Test with production-like configurations
3. **Test failure scenarios**: Verify error handling and rollback
4. **Document test cases**: Include test descriptions and expected outcomes
5. **Monitor test performance**: Track test execution times and resource usage

---

# CI/CD and Automation Guide

## Git Workflows for Infrastructure

### GitFlow for Infrastructure

```
main (production)
├── develop (staging)
├── feature/vpc-update
├── hotfix/security-patch
└── release/v1.2.0
```

**Branch Strategy:**

- `main`: Production-ready infrastructure
- `develop`: Integration branch for staging
- `feature/*`: Individual infrastructure changes
- `hotfix/*`: Emergency production fixes
- `release/*`: Preparation for production deployment

### Environment Branching

```
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── modules/
    ├── vpc/
    ├── ec2/
    └── rds/
```

**Best Practices:**

- Separate directories for environments
- Shared modules for reusability
- Environment-specific variable files
- Protected branches for production

## CI/CD Pipeline Design Patterns

### Standard Pipeline Flow

```
Code Push → Validate → Plan → Review → Apply → Test → Deploy
```

### Multi-Environment Pipeline

```yaml
# Example GitHub Actions workflow
name: Terraform CI/CD
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform fmt -check
      - run: terraform validate
      - run: terraform plan -out=tfplan

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Checkov
        run: checkov -d . --framework terraform

  plan:
    needs: [validate, security-scan]
    runs-on: ubuntu-latest
    environment: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform plan -var-file="${{ github.ref == 'refs/heads/main' && 'prod' || 'staging' }}.tfvars"

  apply:
    needs: plan
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    steps:
      - run: terraform apply -auto-approve
```

### Pipeline Patterns

**1. Sequential Pipeline**

```
Dev → Staging → Production
```

**2. Parallel Pipeline**

```
Feature Branch → Dev + Test
                     ↓
                 Staging
                     ↓
                Production
```

**3. Matrix Pipeline**

```
Code → [AWS, Azure, GCP] → Environments
```

## Automated Testing Integration

### Testing Pyramid for Infrastructure

**Unit Tests (Terraform Modules)**

```hcl
# tests/unit/vpc_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCCreation(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/vpc",
        Vars: map[string]interface{}{
            "cidr_block": "10.0.0.0/16",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

**Integration Tests**

```yaml
# .github/workflows/integration-test.yml
- name: Integration Tests
  run: |
    cd tests/integration
    go test -v -timeout 30m
```

**Policy Tests (OPA/Conftest)**

```rego
# policies/security.rego
package terraform.security

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not resource.change.after.server_side_encryption_configuration
    msg := "S3 buckets must have encryption enabled"
}
```

**Compliance Tests**

```yaml
# compliance-test.yml
- name: Compliance Check
  run: |
    inspec exec aws-baseline \
      --target aws:// \
      --reporter cli json:compliance-report.json
```

## Deployment Strategies

### Blue-Green Deployment

**Infrastructure Setup**

```hcl
# blue-green.tf
resource "aws_launch_template" "blue" {
  count = var.active_environment == "blue" ? 1 : 0
  # Blue environment configuration
}

resource "aws_launch_template" "green" {
  count = var.active_environment == "green" ? 1 : 0
  # Green environment configuration
}

resource "aws_lb_target_group" "active" {
  name = "${var.environment}-active-tg"
  # Points to active environment
}

resource "aws_lb_target_group" "staging" {
  name = "${var.environment}-staging-tg"
  # Points to staging environment
}
```

**Deployment Process**

```bash
#!/bin/bash
# blue-green-deploy.sh

CURRENT_ENV=$(terraform output current_environment)
NEW_ENV=$([ "$CURRENT_ENV" = "blue" ] && echo "green" || echo "blue")

# Deploy to inactive environment
terraform apply -var="deploy_environment=$NEW_ENV"

# Health checks
./health-check.sh $NEW_ENV

# Switch traffic
terraform apply -var="active_environment=$NEW_ENV"

# Cleanup old environment
terraform apply -var="cleanup_environment=$CURRENT_ENV"
```

### Canary Deployment

**Traffic Splitting**

```hcl
# canary.tf
resource "aws_lb_listener_rule" "canary" {
  count = var.canary_enabled ? 1 : 0
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.canary.arn
    weight           = var.canary_weight # Start with 5-10%
  }
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.production.arn
    weight           = 100 - var.canary_weight
  }
}
```

**Gradual Rollout**

```yaml
# canary-pipeline.yml
stages:
  - name: Deploy Canary (5%)
    terraform_vars:
      canary_weight: 5
  
  - name: Monitor Metrics
    run: ./monitor-canary.sh
    duration: 30m
  
  - name: Increase Traffic (25%)
    terraform_vars:
      canary_weight: 25
  
  - name: Full Rollout (100%)
    terraform_vars:
      canary_weight: 100
      canary_enabled: false
```

## Rollback and Disaster Recovery

### State Management for Rollbacks

**State Backup Strategy**

```bash
#!/bin/bash
# backup-state.sh

# Backup before changes
aws s3 cp terraform.tfstate s3://tfstate-backup/$(date +%Y%m%d-%H%M%S)/

# Tag successful deployments
git tag -a "deploy-$(date +%Y%m%d-%H%M%S)" -m "Successful deployment"
```

**Rollback Procedures**

```yaml
# rollback-pipeline.yml
rollback:
  steps:
    - name: Identify Last Good State
      run: |
        LAST_GOOD_TAG=$(git tag -l "deploy-*" | sort -V | tail -1)
        echo "Rolling back to: $LAST_GOOD_TAG"
    
    - name: Restore Configuration
      run: |
        git checkout $LAST_GOOD_TAG
        terraform init
    
    - name: Plan Rollback
      run: terraform plan -out=rollback.tfplan
    
    - name: Execute Rollback
      run: terraform apply rollback.tfplan
    
    - name: Verify Rollback
      run: ./health-check.sh
```

### Disaster Recovery

**Multi-Region Setup**

```hcl
# disaster-recovery.tf
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

provider "aws" {
  alias  = "disaster_recovery"
  region = "us-west-2"
}

module "primary_infrastructure" {
  source = "./modules/infrastructure"
  providers = {
    aws = aws.primary
  }
}

module "dr_infrastructure" {
  source = "./modules/infrastructure"
  providers = {
    aws = aws.disaster_recovery
  }
  
  # Reduced capacity for DR
  instance_count = var.primary_instance_count * 0.5
}
```

**Automated DR Testing**

```bash
#!/bin/bash
# dr-test.sh

# Simulate primary region failure
terraform apply -var="primary_region_enabled=false"

# Activate DR region
terraform apply -var="dr_region_active=true"

# Run health checks
./health-check.sh dr-region

# Restore primary (after testing)
terraform apply -var="primary_region_enabled=true" -var="dr_region_active=false"
```

## Terraform Cloud/Enterprise Integration

### Workspace Configuration

```hcl
# terraform.tf
terraform {
  cloud {
    organization = "my-org"
    
    workspaces {
      name = "infrastructure-prod"
    }
  }
}
```

### Variable Sets

```json
{
  "data": {
    "type": "variable-sets",
    "attributes": {
      "name": "aws-credentials",
      "description": "AWS credentials for all workspaces",
      "global": true
    }
  }
}
```

### Policy as Code

```hcl
# sentinel/aws-security.sentinel
import "tfplan/v2" as tfplan

# Require encryption for S3 buckets
main = rule {
  all tfplan.resource_changes as _, changes {
    changes.type is "aws_s3_bucket" implies
      changes.change.after.server_side_encryption_configuration is not null
  }
}
```

### Run Triggers

```yaml
# tfc-integration.yml
- name: Trigger Terraform Cloud Run
  uses: hashicorp/tfc-workflows-github/actions/create-run@v1.0.0
  with:
    workspace: "infrastructure-prod"
    message: "Triggered by GitHub Actions"
```

## Platform-Specific Integrations

### GitHub Actions

**Complete Workflow**

```yaml
# .github/workflows/terraform.yml
name: Terraform Infrastructure

on:
  push:
    branches: [main, develop]
    paths: ['terraform/**']
  pull_request:
    branches: [main]
    paths: ['terraform/**']

env:
  TF_VERSION: 1.5.0
  AWS_REGION: us-east-1

jobs:
  terraform:
    name: Terraform
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        environment: [dev, staging, prod]
        
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}
        
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}
        
    - name: Terraform Init
      working-directory: terraform/environments/${{ matrix.environment }}
      run: terraform init
      
    - name: Terraform Validate
      working-directory: terraform/environments/${{ matrix.environment }}
      run: terraform validate
      
    - name: Terraform Plan
      working-directory: terraform/environments/${{ matrix.environment }}
      run: terraform plan -out=tfplan
      
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && matrix.environment == 'prod'
      working-directory: terraform/environments/${{ matrix.environment }}
      run: terraform apply tfplan
```

### GitLab CI

**GitLab CI Configuration**

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - plan
  - apply
  - test

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform
  TF_ADDRESS: ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/default

before_script:
  - cd ${TF_ROOT}
  - terraform init
    -backend-config="address=${TF_ADDRESS}"
    -backend-config="lock_address=${TF_ADDRESS}/lock"
    -backend-config="unlock_address=${TF_ADDRESS}/lock"
    -backend-config="username=gitlab-ci-token"
    -backend-config="password=${CI_JOB_TOKEN}"
    -backend-config="lock_method=POST"
    -backend-config="unlock_method=DELETE"
    -backend-config="retry_wait_min=5"

validate:
  stage: validate
  script:
    - terraform validate
    - terraform fmt -check

plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - ${TF_ROOT}/tfplan

apply:
  stage: apply
  script:
    - terraform apply tfplan
  dependencies:
    - plan
  only:
    - main
```

### Jenkins Integration

**Jenkinsfile**

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Target environment'
        )
        booleanParam(
            name: 'DESTROY',
            defaultValue: false,
            description: 'Destroy infrastructure'
        )
    }
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VAR_environment = "${params.ENVIRONMENT}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir("terraform/environments/${params.ENVIRONMENT}") {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir("terraform/environments/${params.ENVIRONMENT}") {
                    script {
                        if (params.DESTROY) {
                            sh 'terraform plan -destroy -out=tfplan'
                        } else {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }
        
        stage('Approval') {
            when {
                environment name: 'ENVIRONMENT', value: 'prod'
            }
            steps {
                script {
                    def userInput = input(
                        id: 'userInput',
                        message: 'Apply Terraform plan?',
                        parameters: [
                            choice(
                                choices: ['Apply', 'Abort'],
                                description: 'Apply or abort the plan',
                                name: 'action'
                            )
                        ]
                    )
                    
                    if (userInput != 'Apply') {
                        error('User aborted the deployment')
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir("terraform/environments/${params.ENVIRONMENT}") {
                    sh 'terraform apply tfplan'
                }
            }
        }
        
        stage('Post-Deploy Tests') {
            steps {
                script {
                    sh './scripts/health-check.sh'
                    sh './scripts/integration-tests.sh'
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: '**/tfplan', allowEmptyArchive: true
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'reports',
                reportFiles: 'terraform-report.html',
                reportName: 'Terraform Report'
            ])
        }
        
        failure {
            script {
                if (params.ENVIRONMENT == 'prod') {
                    // Trigger rollback pipeline
                    build job: 'terraform-rollback',
                          parameters: [
                              string(name: 'ENVIRONMENT', value: params.ENVIRONMENT)
                          ]
                }
            }
        }
    }
}
```

## Best Practices Summary

### Security

- Store sensitive variables in CI/CD secrets
- Use least privilege IAM roles
- Enable audit logging
- Implement policy as code
- Regular security scans

### State Management

- Use remote state backends
- Enable state locking
- Regular state backups
- Environment isolation
- State file encryption

### Testing

- Implement multiple test levels
- Automated compliance checks
- Infrastructure validation
- Performance testing
- Disaster recovery testing

### Monitoring

- Infrastructure drift detection
- Cost monitoring
- Performance metrics
- Security alerting
- Compliance reporting

---

# Performance and Scalability Guide

## Performance Optimization Techniques

### Resource Configuration Best Practices

- **Minimize API calls**: Group related resources in modules to reduce provider API round trips
- **Use data sources efficiently**: Cache data source results when possible, avoid repeated lookups
- **Optimize resource dependencies**: Use explicit `depends_on` only when necessary
- **Provider version pinning**: Pin provider versions to avoid compatibility checks during initialization

### Module Design Patterns

- **Granular modules**: Create small, focused modules rather than monolithic ones
- **Resource grouping**: Group resources with similar lifecycles together
- **Input validation**: Use variable validation to catch errors early in the planning phase
- **Output optimization**: Only expose necessary outputs to reduce state complexity

### Provider-Specific Optimizations

- **AWS**: Use `aws_caller_identity` data source sparingly
- **Azure**: Leverage resource group scoping for faster API responses
- **GCP**: Use project-scoped resources when possible

## Parallelism and Resource Graphs

### Understanding Terraform's Resource Graph

Terraform builds a directed acyclic graph (DAG) of resources based on:

- Explicit dependencies (`depends_on`)
- Implicit dependencies (resource references)
- Provider constraints

### Parallelism Configuration

```bash
# Default parallelism is 10
terraform apply -parallelism=20

# Environment variable
export TF_CLI_ARGS_apply="-parallelism=15"
```

### Optimizing Resource Dependencies

- **Minimize cross-resource dependencies**: Design resources to be as independent as possible
- **Use locals for computed values**: Reduce dependency chains
- **Avoid unnecessary depends_on**: Let Terraform infer dependencies automatically

### Resource Graph Analysis

```bash
# Generate visual dependency graph
terraform graph | dot -Tpng > graph.png

# Show resource dependencies
terraform show -json | jq '.planned_values.root_module.resources'
```

## State File Optimization

### Remote State Backend Selection

**Performance Characteristics by Backend:**

- **S3**: Good for large teams, supports state locking with DynamoDB
- **Azure Blob**: Integrated with Azure environments, good performance
- **GCS**: Excellent for GCP workloads, built-in locking
- **Terraform Cloud**: Optimized for Terraform operations, built-in collaboration features

### State File Size Management

- **Resource lifecycle management**: Remove unused resources regularly
- **State pruning**: Use `terraform state rm` for resources no longer managed
- **Workspace separation**: Split large state files across multiple workspaces

### State Locking Optimization

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### State Refresh Optimization

```bash
# Skip refresh during plan for faster execution
terraform plan -refresh=false

# Refresh only specific resources
terraform refresh -target=aws_instance.example
```

## Large-Scale Deployment Strategies

### Workspace Organization Patterns

#### Environment-Based Workspaces

```
production/
├── networking/
├── compute/
├── databases/
└── monitoring/

staging/
├── networking/
├── compute/
└── databases/
```

#### Service-Based Workspaces

```
shared-services/
├── networking/
├── security/
└── monitoring/

application-services/
├── web-tier/
├── api-tier/
└── data-tier/
```

### Modular Architecture Strategies

- **Layer-based separation**: Network, compute, data layers
- **Service-oriented modules**: Independent service deployments
- **Shared resource modules**: Common infrastructure components

### Cross-Workspace Data Sharing

```hcl
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket"
    key    = "networking/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.networking.outputs.subnet_id
}
```

## Resource Targeting and Partial Deployments

### Strategic Resource Targeting

```bash
# Target specific resources
terraform apply -target=aws_instance.web
terraform apply -target=module.database

# Target resource types
terraform apply -target='aws_security_group.*'

# Multiple targets
terraform apply -target=aws_instance.web -target=aws_instance.api
```

### Partial Deployment Strategies

- **Infrastructure layers**: Deploy foundation first, then applications
- **Blue-green deployments**: Use targeting for gradual rollouts
- **Emergency fixes**: Apply critical fixes without full deployment

### Resource Replacement Strategies

```bash
# Force resource replacement
terraform apply -replace=aws_instance.web

# Plan replacement without applying
terraform plan -replace=aws_instance.web
```

## Terraform Plan Optimization

### Plan Generation Performance

```bash
# Generate plan file for reuse
terraform plan -out=tfplan

# Apply pre-generated plan
terraform apply tfplan

# Detailed plan timing
terraform plan -detailed-timing
```

### Plan Optimization Techniques

- **Use plan files**: Generate once, apply multiple times in CI/CD
- **Selective planning**: Use `-target` for large infrastructures
- **Plan caching**: Store plans in CI/CD artifacts
- **Parallel planning**: Run multiple targeted plans concurrently

### Plan Analysis and Debugging

```bash
# Show plan in JSON format
terraform show -json tfplan

# Analyze plan changes
terraform plan -detailed-timing > plan_timing.log
```

## Memory and CPU Considerations

### Memory Optimization

- **State file size**: Large state files consume more memory
- **Provider memory usage**: Some providers cache more data than others
- **Concurrent operations**: Each parallel operation uses additional memory

### Memory Configuration

```bash
# Increase Go runtime memory limit
export GOMEMLIMIT=2GiB

# Monitor memory usage during operations
terraform apply -parallelism=5  # Reduce if memory constrained
```

### CPU Optimization

- **Parallelism tuning**: Balance between speed and resource usage
- **Provider efficiency**: Some providers are more CPU-intensive
- **Plan complexity**: Complex expressions require more CPU

### Resource Monitoring

```bash
# Monitor Terraform process
top -p $(pgrep terraform)

# Memory usage tracking
/usr/bin/time -v terraform apply
```

### Hardware Recommendations

**For Large Deployments:**

- **Memory**: 8GB+ RAM (16GB+ for very large state files)
- **CPU**: Multi-core processors (4+ cores recommended)
- **Storage**: SSD for local state and plan files
- **Network**: High bandwidth for remote state operations

## Performance Monitoring and Troubleshooting

### Timing Analysis

```bash
# Enable detailed timing
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Analyze timing patterns
grep "timing" terraform.log | sort -k3 -n
```

### Common Performance Bottlenecks

1. **Large state files**: Split into smaller, focused workspaces
2. **Slow providers**: Check provider documentation for optimization tips
3. **Complex dependencies**: Simplify resource relationships
4. **Network latency**: Use regional backends close to execution environment

### Performance Testing

```bash
# Benchmark different parallelism settings
time terraform apply -parallelism=5
time terraform apply -parallelism=10
time terraform apply -parallelism=20
```

## Best Practices Summary

1. **Design for scalability**: Use modular, loosely-coupled architectures
2. **Optimize state management**: Use appropriate backends and workspace strategies
3. **Monitor performance**: Track plan/apply times and resource usage
4. **Use targeting judiciously**: Leverage partial deployments for large infrastructures
5. **Tune parallelism**: Find the optimal balance for your environment
6. **Regular maintenance**: Clean up unused resources and optimize configurations
7. **Profile operations**: Use timing and logging to identify bottlenecks

---

# Enterprise Patterns and Advanced Topics

## 1. Multi-Account/Subscription Strategies

### AWS Multi-Account Architecture

#### Account Structure Design

```hcl
# Organization setup
resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com"
  ]
  
  feature_set = "ALL"
  
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

# Core accounts structure
locals {
  core_accounts = {
    security = {
      name  = "Security"
      email = "aws-security@company.com"
    }
    logging = {
      name  = "Logging"
      email = "aws-logging@company.com"
    }
    shared_services = {
      name  = "Shared Services"
      email = "aws-shared@company.com"
    }
  }
  
  workload_accounts = {
    dev = {
      name  = "Development"
      email = "aws-dev@company.com"
    }
    staging = {
      name  = "Staging"
      email = "aws-staging@company.com"
    }
    prod = {
      name  = "Production"
      email = "aws-prod@company.com"
    }
  }
}

# Create accounts
resource "aws_organizations_account" "core_accounts" {
  for_each = local.core_accounts
  
  name      = each.value.name
  email     = each.value.email
  role_name = "OrganizationAccountAccessRole"
  
  tags = {
    AccountType = "Core"
    Environment = "Shared"
  }
}

resource "aws_organizations_account" "workload_accounts" {
  for_each = local.workload_accounts
  
  name      = each.value.name
  email     = each.value.email
  role_name = "OrganizationAccountAccessRole"
  
  tags = {
    AccountType = "Workload"
    Environment = each.key
  }
}
```

#### Cross-Account Access Patterns

```hcl
# Central IAM role for cross-account access
resource "aws_iam_role" "cross_account_terraform" {
  name = "TerraformCrossAccountRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.management_account_id}:root"
          ]
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
}

# Provider configuration for multi-account
provider "aws" {
  alias  = "security"
  region = var.aws_region
  
  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.core_accounts["security"].id}:role/TerraformCrossAccountRole"
    external_id  = var.external_id
    session_name = "terraform-security"
  }
}

provider "aws" {
  alias  = "production"
  region = var.aws_region
  
  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.workload_accounts["prod"].id}:role/TerraformCrossAccountRole"
    external_id  = var.external_id
    session_name = "terraform-production"
  }
}
```

#### Service Control Policies (SCPs)

```hcl
# Prevent deletion of CloudTrail
resource "aws_organizations_policy" "deny_cloudtrail_deletion" {
  name = "DenyCloudTrailDeletion"
  type = "SERVICE_CONTROL_POLICY"
  
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCloudTrailDeletion"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::*:role/OrganizationAccountAccessRole"
            ]
          }
        }
      }
    ]
  })
}

# Attach SCP to production OU
resource "aws_organizations_policy_attachment" "prod_scp" {
  policy_id = aws_organizations_policy.deny_cloudtrail_deletion.id
  target_id = aws_organizations_organizational_unit.production.id
}
```

### Azure Multi-Subscription Strategy

#### Management Group Structure

```hcl
# Root management group
resource "azurerm_management_group" "root" {
  display_name = "Company Root"
  
  subscription_ids = []
}

# Platform management groups
resource "azurerm_management_group" "platform" {
  display_name         = "Platform"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "connectivity" {
  display_name         = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  display_name         = "Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Landing zones
resource "azurerm_management_group" "landing_zones" {
  display_name         = "Landing Zones"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "corp" {
  display_name         = "Corp"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "online" {
  display_name         = "Online"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}
```

#### Subscription Vending Machine

```hcl
# Subscription creation module
module "subscription_vending" {
  source = "./modules/subscription-vending"
  
  for_each = var.subscription_requests
  
  subscription_name     = each.value.name
  management_group_id   = each.value.management_group_id
  billing_account_name  = var.billing_account_name
  enrollment_account_name = var.enrollment_account_name
  
  tags = merge(var.default_tags, each.value.tags)
}

# Policy assignments
resource "azurerm_management_group_policy_assignment" "corp_policies" {
  name                 = "corp-baseline-policies"
  policy_definition_id = azurerm_policy_set_definition.corp_baseline.id
  management_group_id  = azurerm_management_group.corp.id
  
  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
  })
}
```

### GCP Organization Hierarchy

#### Folder Structure

```hcl
# Organization-level folder structure
resource "google_folder" "environments" {
  display_name = "Environments"
  parent       = "organizations/${var.organization_id}"
}

resource "google_folder" "shared_services" {
  display_name = "Shared Services"
  parent       = "organizations/${var.organization_id}"
}

resource "google_folder" "dev" {
  display_name = "Development"
  parent       = google_folder.environments.name
}

resource "google_folder" "prod" {
  display_name = "Production"
  parent       = google_folder.environments.name
}

# Project factory pattern
module "project_factory" {
  source = "./modules/project-factory"
  
  for_each = var.projects
  
  name       = each.value.name
  folder_id  = each.value.folder_id
  billing_account = var.billing_account
  
  activate_apis = each.value.apis
  
  labels = merge(var.default_labels, each.value.labels)
}
```

## 2. Terraform Enterprise Features

### Workspace Management

#### Workspace Configuration

```hcl
# Terraform Cloud/Enterprise workspace
resource "tfe_workspace" "app_production" {
  name         = "app-production"
  organization = var.tfe_organization
  
  # VCS integration
  vcs_repo {
    identifier     = "company/infrastructure"
    branch         = "main"
    oauth_token_id = var.vcs_oauth_token
  }
  
  # Execution mode
  execution_mode = "remote"
  
  # Terraform version constraint
  terraform_version = "~> 1.5.0"
  
  # Working directory
  working_directory = "environments/production"
  
  # Auto-apply
  auto_apply = false
  
  # Queue all runs
  queue_all_runs = false
  
  # Speculative plans
  speculative_enabled = true
  
  # Structured run output
  structured_run_output_enabled = true
  
  # Tags
  tag_names = ["production", "critical", "app"]
}

# Workspace variables
resource "tfe_variable" "aws_region" {
  key          = "aws_region"
  value        = "us-east-1"
  category     = "terraform"
  workspace_id = tfe_workspace.app_production.id
  description  = "AWS region for resources"
}

resource "tfe_variable" "aws_access_key" {
  key          = "AWS_ACCESS_KEY_ID"
  value        = var.aws_access_key_id
  category     = "env"
  workspace_id = tfe_workspace.app_production.id
  sensitive    = true
}
```

#### Workspace Sets and Organization-Level Policies

```hcl
# Workspace set for environment grouping
resource "tfe_workspace_set" "production_workspaces" {
  name         = "production-workspaces"
  description  = "All production workspaces"
  organization = var.tfe_organization
  global       = false
}

# Add workspaces to set
resource "tfe_workspace_set_workspace" "prod_members" {
  for_each = toset([
    tfe_workspace.app_production.id,
    tfe_workspace.database_production.id,
    tfe_workspace.network_production.id
  ])
  
  workspace_set_id = tfe_workspace_set.production_workspaces.id
  workspace_id     = each.value
}

# Variable set for common variables
resource "tfe_variable_set" "aws_credentials" {
  name         = "AWS Credentials"
  description  = "AWS access credentials"
  organization = var.tfe_organization
  global       = false
}

resource "tfe_workspace_set_variable_set" "aws_creds_assignment" {
  variable_set_id   = tfe_variable_set.aws_credentials.id
  workspace_set_id  = tfe_workspace_set.production_workspaces.id
}
```

### Private Module Registry

#### Module Publishing

```hcl
# Module registry configuration
resource "tfe_registry_module" "vpc_module" {
  organization = var.tfe_organization
  
  vcs_repo {
    display_identifier = "company/terraform-aws-vpc"
    identifier         = "company/terraform-aws-vpc"
    oauth_token_id     = var.vcs_oauth_token
  }
}

# Module versioning and publishing
resource "tfe_registry_module_version" "vpc_v2" {
  organization = var.tfe_organization
  namespace    = var.tfe_organization
  name         = "vpc"
  provider     = "aws"
  version      = "2.0.0"
  
  # Optional: specify the module registry module
  registry_module_id = tfe_registry_module.vpc_module.id
}
```

### Run Triggers and Automation

#### Workspace Dependencies

```hcl
# Run trigger between workspaces
resource "tfe_run_trigger" "network_to_app" {
  workspace_id    = tfe_workspace.app_production.id
  sourceable_id   = tfe_workspace.network_production.id
  sourceable_type = "workspace"
}

# Notification configuration
resource "tfe_notification_configuration" "slack_notifications" {
  name             = "slack-production-alerts"
  enabled          = true
  destination_type = "slack"
  triggers         = ["run:needs_attention", "run:errored"]
  url              = var.slack_webhook_url
  workspace_id     = tfe_workspace.app_production.id
}
```

## 3. Policy as Code with Sentinel

### Sentinel Policy Framework

#### Basic Policy Structure

```sentinel
# Policy: enforce-mandatory-tags.sentinel
import "tfplan-functions" as plan
import "strings"
import "types"

# Required tags for all resources
mandatory_tags = ["Environment", "Owner", "Project", "CostCenter"]

# Get all resource instances
allResourceInstances = plan.find_resources_from_plan()

# Function to validate tags
validate_tags = func(resource_instances) {
    validated = true
    for resource_instances as address, r {
        # Skip if resource doesn't support tags
        if "tags" not in keys(r.applied) {
            continue
        }
        
        current_tags = keys(r.applied.tags else {})
        missing_tags = []
        
        for mandatory_tags as tag {
            if tag not in current_tags {
                append(missing_tags, tag)
            }
        }
        
        if length(missing_tags) > 0 {
            print("Resource", address, "is missing mandatory tags:", missing_tags)
            validated = false
        }
    }
    return validated
}

# Main rule
main = rule {
    validate_tags(allResourceInstances)
}
```

#### Cost Control Policies

```sentinel
# Policy: limit-ec2-instance-types.sentinel
import "tfplan-functions" as plan

# Allowed instance types by environment
allowed_instance_types = {
    "development": ["t3.micro", "t3.small", "t3.medium"],
    "staging": ["t3.small", "t3.medium", "t3.large"],
    "production": ["t3.medium", "t3.large", "t3.xlarge", "m5.large", "m5.xlarge"]
}

# Get environment from workspace name or variables
get_environment = func() {
    if "environment" in keys(tfplan.variables) {
        return tfplan.variables.environment.value
    }
    
    # Fallback to workspace name parsing
    workspace_name = strings.split(tfplan.terraform_version, "-")
    if length(workspace_name) > 1 {
        return workspace_name[1]
    }
    
    return "development"
}

# Validate EC2 instance types
validate_instance_types = func() {
    environment = get_environment()
    allowed_types = allowed_instance_types[environment] else ["t3.micro"]
    
    ec2_instances = plan.find_resources("aws_instance")
    
    for ec2_instances as address, r {
        instance_type = r.applied.instance_type
        if instance_type not in allowed_types {
            print("Instance", address, "uses", instance_type, 
                  "which is not allowed in", environment, "environment")
            return false
        }
    }
    return true
}

main = rule {
    validate_instance_types()
}
```

#### Security Compliance Policies

```sentinel
# Policy: require-encryption.sentinel
import "tfplan-functions" as plan

# Resources that must be encrypted
encryption_required_resources = [
    "aws_s3_bucket",
    "aws_db_instance", 
    "aws_rds_cluster",
    "aws_ebs_volume"
]

# Validate encryption settings
validate_encryption = func() {
    violations = []
    
    # Check S3 buckets
    s3_buckets = plan.find_resources("aws_s3_bucket")
    for s3_buckets as address, r {
        if "server_side_encryption_configuration" not in keys(r.applied) {
            append(violations, address + " missing encryption configuration")
        }
    }
    
    # Check RDS instances
    rds_instances = plan.find_resources("aws_db_instance")
    for rds_instances as address, r {
        if r.applied.storage_encrypted is not true {
            append(violations, address + " storage not encrypted")
        }
    }
    
    # Check EBS volumes
    ebs_volumes = plan.find_resources("aws_ebs_volume")
    for ebs_volumes as address, r {
        if r.applied.encrypted is not true {
            append(violations, address + " not encrypted")
        }
    }
    
    if length(violations) > 0 {
        print("Encryption violations found:")
        for violations as violation {
            print("-", violation)
        }
        return false
    }
    
    return true
}

main = rule {
    validate_encryption()
}
```

### Policy Set Management

```hcl
# Policy set configuration
resource "tfe_policy_set" "security_policies" {
  name         = "security-baseline"
  description  = "Security baseline policies for all workspaces"
  organization = var.tfe_organization
  kind         = "sentinel"
  
  # Policy enforcement level
  policies_path = "policies/"
  
  # VCS integration
  vcs_repo {
    identifier     = "company/terraform-policies"
    branch         = "main"
    oauth_token_id = var.vcs_oauth_token
  }
  
  # Apply to workspace sets
  workspace_ids = []
}

# Attach policy set to workspace set
resource "tfe_policy_set_workspace_set" "security_to_production" {
  policy_set_id     = tfe_policy_set.security_policies.id
  workspace_set_id  = tfe_workspace_set.production_workspaces.id
}
```

## 4. Cost Management and Optimization

### Cost Estimation and Budgets

#### Terraform Cloud Cost Estimation

```hcl
# Workspace with cost estimation enabled
resource "tfe_workspace" "cost_monitored" {
  name         = "cost-monitored-workspace"
  organization = var.tfe_organization
  
  # Enable cost estimation
  structured_run_output_enabled = true
  
  # Cost estimation settings (Enterprise feature)
  cost_estimation_enabled = true
}

# AWS Budget integration
resource "aws_budgets_budget" "terraform_monthly" {
  name         = "terraform-monthly-budget"
  budget_type  = "COST"
  limit_amount = "1000"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  cost_filters = {
    Tag = {
      "ManagedBy" = ["Terraform"]
    }
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = [var.budget_alert_email]
  }
  
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_alert_email]
  }
}
```

### Resource Right-Sizing

#### Auto-Scaling Policies

```hcl
# CloudWatch-based auto-scaling
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
  
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}
```

#### Spot Instance Integration

```hcl
# Mixed instance policy for cost optimization
resource "aws_autoscaling_group" "cost_optimized" {
  name                = "cost-optimized-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type   = "ELB"
  
  min_size         = 2
  max_size         = 10
  desired_capacity = 4
  
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.main.id
        version           = "$Latest"
      }
      
      override {
        instance_type     = "t3.medium"
        weighted_capacity = "1"
      }
      
      override {
        instance_type     = "t3.large"
        weighted_capacity = "2"
      }
    }
    
    instances_distribution {
      on_demand_base_capacity                  = 2
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }
  
  tag {
    key                 = "Name"
    value               = "cost-optimized-instance"
    propagate_at_launch = true
  }
}
```

### Cost Allocation and Tracking

#### Detailed Cost Tagging

```hcl
# Cost allocation tags module
module "cost_allocation_tags" {
  source = "./modules/cost-allocation-tags"
  
  # Cost center mapping
  cost_centers = {
    "engineering" = "CC001"
    "marketing"   = "CC002"
    "sales"       = "CC003"
  }
  
  # Project codes
  project_codes = {
    "web-app"     = "PRJ001"
    "mobile-app"  = "PRJ002"
    "data-platform" = "PRJ003"
  }
  
  # Environment
  environment = var.environment
  
  # Additional metadata
  additional_tags = {
    BusinessUnit = var.business_unit
    Application  = var.application_name
    Owner        = var.owner
  }
}

# Apply tags to resources
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = merge(
    module.cost_allocation_tags.tags,
    {
      Name = "app-server-${var.environment}"
      Role = "application"
    }
  )
}
```

## 5. Governance and Compliance at Scale

### Organizational Policies

#### Azure Policy Integration

```hcl
# Custom policy definition
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-mandatory-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require mandatory tags"
  description  = "Require specific tags on all resources"
  
  metadata = jsonencode({
    category = "Tags"
  })
  
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Resources/subscriptions/resourceGroups"
        },
        {
          anyOf = [
            {
              field  = "tags['Environment']"
              exists = "false"
            },
            {
              field  = "tags['Owner']"
              exists = "false"
            }
          ]
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
  
  parameters = jsonencode({
    requiredTags = {
      type = "Array"
      metadata = {
        displayName = "Required tag names"
        description = "List of required tag names"
      }
      defaultValue = ["Environment", "Owner", "Project"]
    }
  })
}

# Policy assignment
resource "azurerm_management_group_policy_assignment" "require_tags" {
  name                 = "require-tags-assignment"
  policy_definition_id = azurerm_policy_definition.require_tags.id
  management_group_id  = azurerm_management_group.corp.id
  
  parameters = jsonencode({
    requiredTags = {
      value = ["Environment", "Owner", "Project", "CostCenter"]
    }
  })
}
```

#### Google Cloud Organization Policies

```hcl
# Restrict VM external IP
resource "google_organization_policy" "vm_external_ip_access" {
  org_id     = var.organization_id
  constraint = "compute.vmExternalIpAccess"
  
  list_policy {
    deny {
      all = true
    }
  }
}

# Allowed machine types
resource "google_organization_policy" "vm_instance_types" {
  org_id     = var.organization_id
  constraint = "compute.vmInstanceTypes"
  
  list_policy {
    allow {
      values = [
        "projects/*/zones/*/machineTypes/n1-standard-1",
        "projects/*/zones/*/machineTypes/n1-standard-2",
        "projects/*/zones/*/machineTypes/n1-standard-4"
      ]
    }
  }
}
```

### Compliance Frameworks

#### SOC 2 Compliance Implementation

```hcl
# SOC 2 compliance module
module "soc2_compliance" {
  source = "./modules/soc2-compliance"
  
  # Security controls
  enable_cloudtrail        = true
  enable_config            = true
  enable_guardduty         = true
  enable_security_hub      = true
  
  # Access controls
  enable_mfa_enforcement   = true
  enable_password_policy   = true
  enable_access_logging    = true
  
  # Monitoring and alerting
  enable_cloudwatch_alarms = true
  notification_endpoints   = [var.security_notification_email]
  
  # Data protection
  enable_encryption_at_rest = true
  enable_encryption_in_transit = true
  enable_backup_encryption  = true
  
  # Change management
  require_approval_for_changes = true
  enable_change_logging        = true
  
  tags = {
    Compliance = "SOC2"
    Framework  = "SOC2-Type2"
  }
}
```

#### GDPR Compliance Controls

```hcl
# GDPR compliance implementation
module "gdpr_compliance" {
  source = "./modules/gdpr-compliance"
  
  # Data protection
  enable_data_encryption     = true
  enable_data_classification = true
  enable_data_retention      = true
  
  # Access controls
  enable_rbac               = true
  enable_audit_logging      = true
  enable_access_reviews     = true
  
  # Data subject rights
  enable_data_portability   = true
  enable_right_to_erasure   = true
  enable_data_breach_notification = true
  
  # Privacy by design
  enable_privacy_impact_assessment = true
  enable_data_minimization        = true
  
  # Data processing agreements
  dpa_requirements = {
    lawful_basis = "legitimate_interest"
    data_categories = ["personal_data", "special_categories"]
    processing_purposes = ["service_delivery", "analytics"]
  }
  
  tags = {
    Compliance = "GDPR"
    DataClassification = "PersonalData"
  }
}
```

## 6. Advanced State Management Patterns

### State Backend Strategies

#### Multi-Environment State Management

```hcl
# Backend configuration with environment-specific buckets
terraform {
  backend "s3" {
    bucket         = "terraform-state-${var.environment}-${random_id.bucket_suffix.hex}"
    key            = "infrastructure/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    kms_key_id     = aws_kms_key.terraform_state.arn
    dynamodb_table = "terraform-locks-${var.environment}"
    
    # Workspace-specific state paths
    workspace_key_prefix = "workspaces"
  }
}

# State bucket with versioning and lifecycle
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-state-${var.environment}-${random_id.bucket_suffix.hex}"
  force_destroy = false
  
  tags = {
    Name        = "Terraform State"
    Environment = var.environment
    Purpose     = "TerraformState"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    id     = "state_file_lifecycle"
    status = "Enabled"
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}
```

#### State Locking and Concurrency

```hcl
# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_state.arn
  }
  
  tags = {
    Name        = "Terraform State Locks"
    Environment = var.environment
    Purpose     = "TerraformStateLocking"
  }
}

# KMS key for state encryption
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Terraform to use the key"
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.terraform_execution.arn
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name        = "Terraform State KMS Key"
    Environment = var.environment
    Purpose     = "TerraformStateEncryption"
  }
}

# KMS key alias
resource "aws_kms_alias" "terraform_state" {
  name          = "alias/terraform-state-${var.environment}"
  target_key_id = aws_kms_key.terraform_state.key_id
}
```

### State Migration and Import Strategies

#### Bulk Import Module

```hcl
# State import automation module
module "state_import" {
  source = "./modules/state-import"
  
  # Resources to import
  import_resources = {
    "aws_vpc.main" = {
      resource_id = "vpc-12345678"
      resource_type = "aws_vpc"
    }
    "aws_subnet.public[0]" = {
      resource_id = "subnet-abcdef12"
      resource_type = "aws_subnet"
    }
    "aws_subnet.public[1]" = {
      resource_id = "subnet-abcdef34"
      resource_type = "aws_subnet"
    }
  }
  
  # Import validation
  validate_imports = true
  
  # Backup existing state
  backup_state = true
}

# Import script generation
resource "local_file" "import_script" {
  content = templatefile("${path.module}/templates/import_script.sh.tpl", {
    resources = var.import_resources
  })
  filename = "import_resources.sh"
  
  file_permission = "0755"
}
```

#### State Splitting Strategy

```hcl
# State splitting for large infrastructures
# Original monolithic state -> Multiple focused states

# Network state (separate workspace)
# terraform/network/
terraform {
  backend "s3" {
    bucket = "terraform-state-prod"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Application state (separate workspace)  
# terraform/applications/web-app/
terraform {
  backend "s3" {
    bucket = "terraform-state-prod"
    key    = "applications/web-app/terraform.tfstate"
    region = "us-east-1"
  }
}

# Cross-state data sources
data "terraform_remote_state" "network" {
  backend = "s3"
  
  config = {
    bucket = "terraform-state-prod"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use network outputs in application
resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_id
  vpc_security_group_ids = [
    data.terraform_remote_state.network.outputs.web_security_group_id
  ]
  
  # ... other configuration
}
```

## 7. Disaster Recovery and Backup Strategies

### State Backup and Recovery

#### Automated State Backup

```hcl
# Lambda function for state backup
resource "aws_lambda_function" "state_backup" {
  filename      = "state_backup.zip"
  function_name = "terraform-state-backup"
  role          = aws_iam_role.lambda_backup.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 300
  
  environment {
    variables = {
      BACKUP_BUCKET = aws_s3_bucket.state_backups.bucket
      SOURCE_BUCKET = aws_s3_bucket.terraform_state.bucket
    }
  }
  
  tags = {
    Name    = "Terraform State Backup"
    Purpose = "DisasterRecovery"
  }
}

# CloudWatch event rule for scheduled backups
resource "aws_cloudwatch_event_rule" "state_backup_schedule" {
  name                = "terraform-state-backup-schedule"
  description         = "Trigger state backup every 6 hours"
  schedule_expression = "rate(6 hours)"
}

resource "aws_cloudwatch_event_target" "state_backup_target" {
  rule      = aws_cloudwatch_event_rule.state_backup_schedule.name
  target_id = "TerraformStateBackupTarget"
  arn       = aws_lambda_function.state_backup.arn
}

# Cross-region backup bucket
resource "aws_s3_bucket" "state_backups" {
  bucket = "terraform-state-backups-${random_id.backup_suffix.hex}"
  
  tags = {
    Name    = "Terraform State Backups"
    Purpose = "DisasterRecovery"
  }
}

resource "aws_s3_bucket_replication_configuration" "state_backup_replication" {
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.state_backups.id
  
  rule {
    id     = "replicate-state-backups"
    status = "Enabled"
    
    destination {
      bucket        = aws_s3_bucket.dr_backups.arn
      storage_class = "STANDARD_IA"
    }
  }
  
  depends_on = [aws_s3_bucket_versioning.state_backups]
}
```

#### Cross-Region Disaster Recovery

```hcl
# DR region provider
provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

# DR state bucket
resource "aws_s3_bucket" "terraform_state_dr" {
  provider = aws.dr
  bucket   = "terraform-state-dr-${var.environment}-${random_id.dr_suffix.hex}"
  
  tags = {
    Name        = "Terraform State DR"
    Environment = var.environment
    Purpose     = "DisasterRecovery"
  }
}

# Cross-region replication
resource "aws_s3_bucket_replication_configuration" "state_dr_replication" {
  role   = aws_iam_role.state_replication.arn
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    id     = "replicate-to-dr"
    status = "Enabled"
    
    destination {
      bucket             = aws_s3_bucket.terraform_state_dr.arn
      storage_class      = "STANDARD_IA"
      replica_kms_key_id = aws_kms_key.terraform_state_dr.arn
    }
  }
}

# DR DynamoDB table
resource "aws_dynamodb_table" "terraform_locks_dr" {
  provider     = aws.dr
  name         = "terraform-locks-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  global_table {
    region = var.primary_region
  }
  
  tags = {
    Name        = "Terraform State Locks DR"
    Environment = var.environment
    Purpose     = "DisasterRecovery"
  }
}
```

### Infrastructure Recovery Automation

#### Recovery Runbooks

```hcl
# Systems Manager document for recovery procedures
resource "aws_ssm_document" "disaster_recovery_runbook" {
  name          = "TerraformDisasterRecovery"
  document_type = "Automation"
  document_format = "YAML"
  
  content = yamlencode({
    schemaVersion = "0.3"
    description   = "Terraform infrastructure disaster recovery procedures"
    assumeRole    = aws_iam_role.ssm_automation.arn
    
    parameters = {
      Environment = {
        type        = "String"
        description = "Environment to recover"
      }
      BackupTimestamp = {
        type        = "String"
        description = "Backup timestamp to restore from"
      }
    }
    
    mainSteps = [
      {
        name   = "ValidateBackup"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "headObject"
          Bucket  = aws_s3_bucket.state_backups.bucket
          Key     = "{{Environment}}/{{BackupTimestamp}}/terraform.tfstate"
        }
      },
      {
        name   = "RestoreState"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "copyObject"
          Bucket  = aws_s3_bucket.terraform_state.bucket
          Key     = "terraform.tfstate"
          CopySource = "${aws_s3_bucket.state_backups.bucket}/{{Environment}}/{{BackupTimestamp}}/terraform.tfstate"
        }
      },
      {
        name   = "NotifyRecoveryComplete"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "sns"
          Api     = "publish"
          TopicArn = aws_sns_topic.disaster_recovery.arn
          Message  = "Terraform state recovery completed for {{Environment}}"
        }
      }
    ]
  })
  
  tags = {
    Name    = "Terraform DR Runbook"
    Purpose = "DisasterRecovery"
  }
}

# SNS topic for DR notifications
resource "aws_sns_topic" "disaster_recovery" {
  name = "terraform-disaster-recovery"
  
  tags = {
    Name    = "Terraform DR Notifications"
    Purpose = "DisasterRecovery"
  }
}
```

#### Multi-Cloud Backup Strategy

```hcl
# Azure backup for AWS Terraform state
resource "azurerm_storage_account" "terraform_backup" {
  name                     = "tfstatebackup${random_string.backup_suffix.result}"
  resource_group_name      = azurerm_resource_group.backup.name
  location                 = var.azure_region
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 90
    }
  }
  
  tags = {
    Purpose = "TerraformStateBackup"
    Source  = "AWS"
  }
}

# Cross-cloud backup function
resource "aws_lambda_function" "cross_cloud_backup" {
  filename      = "cross_cloud_backup.zip"
  function_name = "terraform-cross-cloud-backup"
  role          = aws_iam_role.cross_cloud_backup.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 600
  
  environment {
    variables = {
      AZURE_STORAGE_ACCOUNT = azurerm_storage_account.terraform_backup.name
      AZURE_CONTAINER_NAME  = "terraform-state"
      AWS_SOURCE_BUCKET     = aws_s3_bucket.terraform_state.bucket
    }
  }
  
  tags = {
    Name    = "Cross-Cloud Terraform Backup"
    Purpose = "DisasterRecovery"
  }
}
```

### Business Continuity Planning

#### RTO/RPO Implementation

```hcl
# Recovery Time Objective (RTO) and Recovery Point Objective (RPO) configuration
locals {
  # Business requirements
  rto_requirements = {
    critical     = "1h"   # 1 hour
    important    = "4h"   # 4 hours
    standard     = "24h"  # 24 hours
  }
  
  rpo_requirements = {
    critical     = "15m"  # 15 minutes
    important    = "1h"   # 1 hour
    standard     = "24h"  # 24 hours
  }
}

# High-frequency backup for critical workloads
resource "aws_cloudwatch_event_rule" "critical_backup_schedule" {
  name                = "terraform-critical-backup-schedule"
  description         = "Backup critical Terraform states every 15 minutes"
  schedule_expression = "rate(15 minutes)"
  
  tags = {
    WorkloadTier = "Critical"
    RPO          = local.rpo_requirements.critical
  }
}

# Standard backup for non-critical workloads
resource "aws_cloudwatch_event_rule" "standard_backup_schedule" {
  name                = "terraform-standard-backup-schedule"
  description         = "Backup standard Terraform states daily"
  schedule_expression = "rate(1 day)"
  
  tags = {
    WorkloadTier = "Standard"
    RPO          = local.rpo_requirements.standard
  }
}
```

#### Recovery Testing Automation

```hcl
# Automated DR testing
resource "aws_lambda_function" "dr_test" {
  filename      = "dr_test.zip"
  function_name = "terraform-dr-test"
  role          = aws_iam_role.dr_test.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 900
  
  environment {
    variables = {
      TEST_ENVIRONMENT = "dr-test"
      BACKUP_BUCKET    = aws_s3_bucket.state_backups.bucket
      TEST_RESULTS_TOPIC = aws_sns_topic.dr_test_results.arn
    }
  }
  
  tags = {
    Name    = "DR Test Automation"
    Purpose = "DisasterRecoveryTesting"
  }
}

# Monthly DR test schedule
resource "aws_cloudwatch_event_rule" "dr_test_schedule" {
  name                = "terraform-dr-test-schedule"
  description         = "Run DR tests monthly"
  schedule_expression = "cron(0 2 1 * ? *)"  # 2 AM on the 1st of every month
}

resource "aws_cloudwatch_event_target" "dr_test_target" {
  rule      = aws_cloudwatch_event_rule.dr_test_schedule.name
  target_id = "TerraformDRTestTarget"
  arn       = aws_lambda_function.dr_test.arn
}
```

## Best Practices Summary

### Enterprise Architecture Principles

- **Separation of Concerns**: Separate network, security, and application infrastructure
- **Least Privilege**: Implement fine-grained access controls
- **Defense in Depth**: Multiple layers of security controls
- **Automation First**: Automate deployment, testing, and recovery processes
- **Observability**: Comprehensive logging, monitoring, and alerting
- **Compliance by Design**: Build compliance controls into infrastructure

### Operational Excellence

- **GitOps Workflows**: Version-controlled infrastructure changes
- **Policy as Code**: Automated compliance and governance
- **Cost Optimization**: Continuous cost monitoring and optimization
- **Disaster Recovery**: Tested backup and recovery procedures
- **Change Management**: Controlled and auditable infrastructure changes
- **Documentation**: Comprehensive runbooks and procedures

### Scalability Considerations

- **Modular Design**: Reusable, composable infrastructure modules
- **State Management**: Appropriate state splitting and organization
- **Multi-Account Strategy**: Proper account/subscription boundaries
- **Resource Organization**: Logical grouping and tagging strategies
- **Automation Scaling**: Self-service infrastructure provisioning
- **Performance Monitoring**: Proactive capacity planning

This comprehensive guide covers enterprise-grade Terraform patterns suitable for large-scale, multi-cloud deployments with strict governance, compliance, and operational requirements.

---

# Troubleshooting and Debugging Guide

## 1. Common Error Patterns and Solutions

### Configuration Errors

#### Syntax and Validation Errors

```hcl
# Common Issue: Missing quotes in string values
resource "aws_instance" "web" {
  ami           = ami-12345678  # ❌ Missing quotes
  instance_type = "t2.micro"
}

# Solution: Proper quoting
resource "aws_instance" "web" {
  ami           = "ami-12345678"  # ✅ Quoted string
  instance_type = "t2.micro"
}
```

**Error Message:**

```
Error: Invalid expression
Expected the start of an expression, but found an invalid expression token.
```

**Solution Steps:**

1. Run `terraform validate` to catch syntax errors
2. Use `terraform fmt` to fix formatting issues
3. Check for missing quotes, brackets, or braces

#### Resource Reference Errors

```hcl
# Common Issue: Incorrect resource reference
resource "aws_security_group_rule" "web" {
  security_group_id = aws_security_group.web.name  # ❌ Wrong attribute
  # ... other configuration
}

# Solution: Use correct attribute
resource "aws_security_group_rule" "web" {
  security_group_id = aws_security_group.web.id    # ✅ Correct attribute
  # ... other configuration
}
```

**Error Message:**

```
Error: Unsupported attribute
This object does not have an attribute named "name".
```

### Dependency and Ordering Issues

#### Implicit vs Explicit Dependencies

```hcl
# Issue: Race condition in resource creation
resource "aws_instance" "web" {
  ami             = "ami-12345678"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web.name]
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Instance started" > /tmp/status
  EOF
}

resource "aws_security_group" "web" {
  name_prefix = "web-"
  # ... rules
}

# Solution: Use explicit depends_on when needed
resource "aws_instance" "web" {
  ami             = "ami-12345678"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web.name]
  
  depends_on = [aws_security_group.web]  # ✅ Explicit dependency
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Instance started" > /tmp/status
  EOF
}
```

### Authentication and Authorization Errors

#### AWS Provider Authentication

```bash
# Common authentication issues and solutions

# Issue 1: Missing credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-west-2"

# Issue 2: Incorrect IAM permissions
# Check IAM policy has required permissions:
# - ec2:*
# - iam:*
# - s3:*
# etc.

# Issue 3: MFA token expired
aws sts get-caller-identity  # Verify current identity
```

**Error Message:**

```
Error: error configuring Terraform AWS Provider: no valid credential sources found
```

### Resource Conflicts and Dependencies

#### Resource Already Exists

```bash
# Error when resource exists outside Terraform
Error: Error creating security group: InvalidGroup.Duplicate

# Solutions:
# 1. Import existing resource
terraform import aws_security_group.web sg-12345678

# 2. Rename Terraform resource
# 3. Use data source instead of resource
data "aws_security_group" "existing" {
  name = "existing-sg-name"
}
```

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

## 3. Log Analysis and Interpretation

### Understanding Terraform Logs

#### Log Level Hierarchy

```
TRACE > DEBUG > INFO > WARN > ERROR
```

#### Common Log Patterns

```bash
# Provider initialization
2023-07-28T10:00:00.000Z [DEBUG] provider.terraform-provider-aws: configuring client

# Resource planning
2023-07-28T10:00:01.000Z [TRACE] dag/walk: walking "aws_instance.web"
2023-07-28T10:00:01.000Z [DEBUG] aws_instance.web: planning...

# API calls
2023-07-28T10:00:02.000Z [DEBUG] provider.terraform-provider-aws: making API call: RunInstances

# Errors
2023-07-28T10:00:03.000Z [ERROR] aws_instance.web: error creating instance: InvalidAMIID.NotFound
```

### Analyzing Provider Logs

```bash
# Example AWS provider debug output analysis
grep "HTTP Request" terraform.log    # API requests
grep "HTTP Response" terraform.log   # API responses
grep "ERROR" terraform.log          # Error messages
grep "Rate limited" terraform.log   # Rate limiting issues

# Look for specific patterns
grep -A 5 -B 5 "InvalidAMIID" terraform.log  # Context around AMI errors
```

### Log Parsing Script

```bash
#!/bin/bash
# parse_tf_logs.sh

LOG_FILE=${1:-terraform.log}

echo "=== Error Summary ==="
grep "\[ERROR\]" "$LOG_FILE" | cut -d' ' -f4- | sort | uniq -c

echo -e "\n=== Warning Summary ==="
grep "\[WARN\]" "$LOG_FILE" | cut -d' ' -f4- | sort | uniq -c

echo -e "\n=== API Call Summary ==="
grep "making API call" "$LOG_FILE" | awk '{print $NF}' | sort | uniq -c

echo -e "\n=== Resource Operations ==="
grep -E "(Creating|Updating|Destroying)" "$LOG_FILE" | awk '{print $4, $5}' | sort | uniq -c
```

## 4. State Troubleshooting

### State File Issues

#### State Lock Problems

```bash
# Error: Error locking state
Error: Error acquiring the state lock

# Solutions:
# 1. Wait for lock to release naturally
# 2. Force unlock (use carefully)
terraform force-unlock LOCK_ID

# 3. Check who has the lock (AWS DynamoDB)
aws dynamodb get-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"path/to/state"}}'
```

#### State Drift Detection

```bash
# Check for drift between state and reality
terraform plan -refresh-only

# Show what has changed
terraform show -json | jq '.values.root_module.resources[] | select(.values != .prior_state.values)'

# Fix drift by refreshing state
terraform apply -refresh-only
```

### State Recovery Techniques

#### Backup and Restore

```bash
# Create state backup before risky operations
cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)

# Restore from backup
cp terraform.tfstate.backup.20230728_100000 terraform.tfstate

# For remote state (S3)
aws s3 cp s3://my-tf-state/terraform.tfstate terraform.tfstate.backup
```

#### Moving Resources Between States

```bash
# Move resource to different state file
terraform state mv aws_instance.web module.compute.aws_instance.web

# Remove resource from state (keeps real resource)
terraform state rm aws_instance.web

# Import existing resource into state
terraform import aws_instance.web i-1234567890abcdef0
```

#### State File Corruption Recovery

```bash
# If state file is corrupted:

# 1. Try to recover from backup
ls -la terraform.tfstate.backup*

# 2. Use remote state versioning (S3)
aws s3api list-object-versions --bucket my-tf-state --prefix terraform.tfstate

# 3. Rebuild state by importing resources
terraform import aws_vpc.main vpc-12345678
terraform import aws_subnet.public subnet-12345678
# ... continue for all resources
```

### Working with Remote State Issues

```bash
# S3 backend troubleshooting

# Check S3 bucket access
aws s3 ls s3://my-terraform-state/

# Verify DynamoDB table for locking
aws dynamodb describe-table --table-name terraform-locks

# Test backend configuration
terraform init -backend-config="bucket=my-terraform-state"
```

## 5. Provider-Specific Issues

### AWS Provider Issues

#### Common AWS Errors and Solutions

```hcl
# Issue: InvalidAMIID.NotFound
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id  # ✅ Dynamic AMI lookup
  instance_type = "t2.micro"
}
```

#### Rate Limiting Handling

```hcl
# Configure provider with retry settings
provider "aws" {
  region = "us-west-2"
  
  retry_mode      = "adaptive"
  max_retries     = 25
  
  # For high-throughput operations
  skip_credentials_validation = true
  skip_region_validation     = true
  skip_requesting_account_id = true
}
```

### Azure Provider Issues

#### Authentication Problems

```bash
# Azure CLI authentication
az login
az account show
az account set --subscription "subscription-id"

# Service Principal authentication
export ARM_CLIENT_ID="client-id"
export ARM_CLIENT_SECRET="client-secret"
export ARM_SUBSCRIPTION_ID="subscription-id"
export ARM_TENANT_ID="tenant-id"
```

### Google Cloud Provider Issues

#### Project and Authentication Setup

```bash
# Authenticate with Google Cloud
gcloud auth login
gcloud auth application-default login

# Set project
gcloud config set project PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
```

## 6. Performance Troubleshooting

### Identifying Performance Bottlenecks

#### Plan Performance Issues

```bash
# Measure plan time with different parallelism
time terraform plan -parallelism=1
time terraform plan -parallelism=10
time terraform plan -parallelism=50

# Profile plan operations
TF_LOG=DEBUG terraform plan 2>&1 | grep -E "(duration|took)"
```

#### Large State File Issues

```bash
# Analyze state file size and complexity
du -h terraform.tfstate
jq '.resources | length' terraform.tfstate
jq '.resources | group_by(.type) | map({type: .[0].type, count: length})' terraform.tfstate

# Split large configurations into smaller modules
# Use data sources instead of resource references where possible
```

### Memory and Resource Optimization

```bash
# Monitor Terraform memory usage
/usr/bin/time -v terraform plan

# For large deployments:
# 1. Increase system memory
# 2. Use smaller parallelism values
# 3. Split into multiple state files
# 4. Use targeted operations
terraform plan -target=module.compute
```

### Network Performance Issues

```bash
# Test provider API connectivity
curl -w "@curl-format.txt" -s -o /dev/null https://ec2.us-west-2.amazonaws.com

# curl-format.txt content:
#     time_namelookup:  %{time_namelookup}\n
#        time_connect:  %{time_connect}\n
#     time_appconnect:  %{time_appconnect}\n
#    time_pretransfer:  %{time_pretransfer}\n
#       time_redirect:  %{time_redirect}\n
#  time_starttransfer:  %{time_starttransfer}\n
#                     ----------\n
#          time_total:  %{time_total}\n
```

## 7. Recovery from Failed Deployments

### Partial Apply Failures

#### Understanding Apply Failures

```bash
# When apply fails partway through:
Error: Error creating instance: RequestLimitExceeded

# Check what was created successfully
terraform show
terraform state list

# Continue with remaining resources
terraform apply -target=aws_security_group.web
terraform apply -target=aws_instance.database
```

#### Manual Resource Recovery

```bash
# If resources exist but not in state:

# 1. Identify orphaned resources
aws ec2 describe-instances --filters "Name=tag:Environment,Values=production"

# 2. Import into Terraform state
terraform import aws_instance.web i-1234567890abcdef0

# 3. Verify configuration matches
terraform plan
```

### Rollback Strategies

#### Infrastructure Rollback

```bash
# Option 1: Destroy and recreate
terraform destroy -target=aws_instance.web
terraform apply -target=aws_instance.web

# Option 2: Revert to previous configuration
git checkout HEAD~1 -- main.tf
terraform plan
terraform apply

# Option 3: Use workspace for rollback
terraform workspace select previous-version
terraform apply
```

#### State File Recovery

```bash
# Recover from state backup
cp terraform.tfstate.backup terraform.tfstate

# For remote state with versioning
aws s3api get-object \
  --bucket my-tf-state \
  --key terraform.tfstate \
  --version-id VERSION_ID \
  terraform.tfstate
```

### Database and Critical Resource Recovery

```bash
# For database disasters:

# 1. Check for automated backups
aws rds describe-db-snapshots --db-instance-identifier mydb

# 2. Restore from snapshot
resource "aws_db_instance" "restored" {
  identifier     = "mydb-restored"
  snapshot_identifier = "mydb-snapshot-20230728"
  # ... other configuration
}

# 3. Update application configuration
# 4. Test connectivity and data integrity
```

## Troubleshooting Checklist

### Pre-Deployment Checks

- [ ] Run `terraform validate`
- [ ] Run `terraform fmt -check`
- [ ] Execute `terraform plan` and review changes
- [ ] Verify authentication and permissions
- [ ] Check resource quotas and limits
- [ ] Backup current state

### During Issues

- [ ] Enable debug logging (`TF_LOG=DEBUG`)
- [ ] Check Terraform and provider versions
- [ ] Verify network connectivity
- [ ] Check API rate limits
- [ ] Review IAM permissions
- [ ] Examine state file for inconsistencies

### Post-Failure Recovery

- [ ] Document the failure and resolution
- [ ] Update runbooks and procedures
- [ ] Review monitoring and alerting
- [ ] Consider infrastructure changes to prevent recurrence
- [ ] Update team knowledge base

## Common Commands Reference

```bash
# Diagnostic commands
terraform version
terraform providers
terraform validate
terraform fmt -check -diff

# State management
terraform state list
terraform state show RESOURCE
terraform state mv SOURCE DEST
terraform state rm RESOURCE
terraform import ADDR ID

# Recovery commands
terraform refresh
terraform apply -refresh-only
terraform force-unlock LOCK_ID
terraform workspace list

# Debugging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform console
terraform graph | dot -Tpng > graph.png
```

Remember: Always backup your state file before making significant changes, and test recovery procedures in non-production environments first.

---

# Advanced Use Cases and Integration Patterns

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

## Hybrid Cloud Architectures

### On-Premises to Cloud Connectivity

```hcl
# hybrid-connectivity.tf
# AWS Direct Connect
resource "aws_dx_gateway" "main" {
  name = "${var.environment}-dx-gateway"
}

resource "aws_dx_gateway_association" "main" {
  dx_gateway_id  = aws_dx_gateway.main.id
  vpn_gateway_id = aws_vpn_gateway.main.id
}

# Azure ExpressRoute
resource "azurerm_express_route_circuit" "main" {
  name                  = "${var.environment}-expressroute"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  service_provider_name = var.express_route_provider
  peering_location      = var.express_route_location
  bandwidth_in_mbps     = var.express_route_bandwidth
  
  sku {
    tier   = "Standard"
    family = "MeteredData"
  }
}

# Google Cloud Interconnect
resource "google_compute_interconnect_attachment" "main" {
  name                     = "${var.environment}-interconnect"
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  type                     = "PARTNER"
  router                   = google_compute_router.main.id
  region                   = var.gcp_region
}
```

### Hybrid DNS Configuration

```hcl
# hybrid-dns.tf
# AWS Route 53 Resolver
resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "${var.environment}-inbound"
  direction = "INBOUND"
  
  security_group_ids = [aws_security_group.dns_resolver.id]
  
  dynamic "ip_address" {
    for_each = var.resolver_subnets
    content {
      subnet_id = ip_address.value
    }
  }
}

resource "aws_route53_resolver_rule" "onprem" {
  domain_name          = var.onprem_domain
  name                 = "${var.environment}-onprem-rule"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id
  
  dynamic "target_ip" {
    for_each = var.onprem_dns_servers
    content {
      ip = target_ip.value
    }
  }
}

# Azure Private DNS
resource "azurerm_private_dns_zone" "main" {
  name                = var.private_domain
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "${var.environment}-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = true
}
```

### Identity Federation

```hcl
# identity-federation.tf
# AWS SAML Identity Provider
resource "aws_iam_saml_identity_provider" "main" {
  name                   = "${var.environment}-saml-provider"
  saml_metadata_document = file("${path.module}/saml-metadata.xml")
}

# Azure AD Integration
resource "azuread_application" "main" {
  display_name = "${var.environment}-terraform-app"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "main" {
  application_id = azuread_application.main.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

# GCP Workload Identity
resource "google_service_account" "main" {
  account_id   = "${var.environment}-terraform-sa"
  display_name = "Terraform Service Account"
}

resource "google_service_account_iam_binding" "workload_identity" {
  service_account_id = google_service_account.main.name
  role               = "roles/iam.workloadIdentityUser"
  
  members = [
    "serviceAccount:${var.gcp_project}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]"
  ]
}
```

## Infrastructure Automation Patterns

### Event-Driven Infrastructure

```hcl
# event-driven-infrastructure.tf
# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "infrastructure_change" {
  name        = "${var.environment}-infra-change"
  description = "Trigger infrastructure changes"
  
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["terminated"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.infrastructure_change.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.infrastructure_handler.arn
}

# Lambda function for infrastructure automation
resource "aws_lambda_function" "infrastructure_handler" {
  filename         = "infrastructure_handler.zip"
  function_name    = "${var.environment}-infra-handler"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  
  environment {
    variables = {
      TERRAFORM_WORKSPACE = var.environment
      S3_BUCKET          = aws_s3_bucket.terraform_state.bucket
    }
  }
}
```

### Auto-Scaling Infrastructure Patterns

```hcl
# auto-scaling-patterns.tf
# Predictive Scaling with CloudWatch
resource "aws_autoscaling_policy" "predictive" {
  name                   = "${var.environment}-predictive-scaling"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
  
  predictive_scaling_configuration {
    metric_specifications {
      target_value = 70.0
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
    }
    mode                         = "ForecastAndScale"
    scheduling_buffer_time       = 300
    max_capacity_breach_behavior = "HonorMaxCapacity"
    max_capacity_buffer          = 10
  }
}

# Custom Metrics Auto Scaling
resource "aws_cloudwatch_metric_alarm" "custom_scale_up" {
  alarm_name          = "${var.environment}-custom-scale-up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "QueueDepth"
  namespace           = "Custom/Application"
  period              = "60"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "This metric monitors queue depth"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
}
```

### Infrastructure State Machine

```hcl
# infrastructure-state-machine.tf
resource "aws_sfn_state_machine" "infrastructure_deployment" {
  name     = "${var.environment}-infra-deployment"
  role_arn = aws_iam_role.step_function_role.arn
  
  definition = jsonencode({
    Comment = "Infrastructure deployment state machine"
    StartAt = "ValidateConfiguration"
    States = {
      ValidateConfiguration = {
        Type     = "Task"
        Resource = aws_lambda_function.validate_config.arn
        Next     = "PlanInfrastructure"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "HandleError"
        }]
      }
      PlanInfrastructure = {
        Type     = "Task"
        Resource = aws_lambda_function.terraform_plan.arn
        Next     = "ApprovalRequired"
      }
      ApprovalRequired = {
        Type = "Choice"
        Choices = [{
          Variable      = "$.requiresApproval"
          BooleanEquals = true
          Next          = "WaitForApproval"
        }]
        Default = "ApplyInfrastructure"
      }
      WaitForApproval = {
        Type = "Wait"
        Seconds = 3600
        Next = "ApplyInfrastructure"
      }
      ApplyInfrastructure = {
        Type     = "Task"
        Resource = aws_lambda_function.terraform_apply.arn
        End      = true
      }
      HandleError = {
        Type = "Task"
        Resource = aws_lambda_function.error_handler.arn
        End = true
      }
    }
  })
}
```

## Configuration Management Integration

### Ansible Integration

```hcl
# ansible-integration.tf
resource "aws_instance" "web_servers" {
  count                  = var.instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id             = aws_subnet.private[count.index % length(aws_subnet.private)].id
  
  user_data = templatefile("${path.module}/templates/user_data.sh", {
    ansible_pull_url = var.ansible_repo_url
    environment     = var.environment
  })
  
  tags = {
    Name        = "${var.environment}-web-${count.index + 1}"
    Environment = var.environment
    AnsibleGroup = "webservers"
  }
}

# Generate Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    web_servers = aws_instance.web_servers[*].private_ip
    db_servers  = aws_instance.db_servers[*].private_ip
    environment = var.environment
  })
  filename = "${path.module}/ansible/inventory/${var.environment}"
  
  depends_on = [aws_instance.web_servers, aws_instance.db_servers]
}

# Execute Ansible playbook
resource "null_resource" "ansible_provisioning" {
  triggers = {
    instance_ids = join(",", aws_instance.web_servers[*].id)
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/ansible
      ansible-playbook -i inventory/${var.environment} site.yml
    EOT
  }
  
  depends_on = [local_file.ansible_inventory]
}
```

### Chef Integration

```hcl
# chef-integration.tf
resource "aws_instance" "chef_nodes" {
  count         = var.node_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name
  
  user_data = templatefile("${path.module}/templates/chef_bootstrap.sh", {
    chef_server_url = var.chef_server_url
    validator_key   = var.chef_validator_key
    node_name      = "${var.environment}-node-${count.index + 1}"
    run_list       = var.chef_run_list
  })
  
  tags = {
    Name = "${var.environment}-chef-node-${count.index + 1}"
    ChefEnvironment = var.environment
  }
}

# Chef environment configuration
resource "chef_environment" "main" {
  name = var.environment
  
  default_attributes_json = jsonencode({
    application = {
      database_url = aws_db_instance.main.endpoint
      cache_url    = aws_elasticache_cluster.main.cache_nodes[0].address
    }
  })
}

# Chef role
resource "chef_role" "web_server" {
  name = "${var.environment}-webserver"
  
  run_list = [
    "recipe[nginx]",
    "recipe[application::deploy]"
  ]
  
  default_attributes_json = jsonencode({
    nginx = {
      worker_processes = 2
      keepalive_timeout = 65
    }
  })
}
```

### Puppet Integration

```hcl
# puppet-integration.tf
resource "aws_instance" "puppet_agents" {
  count         = var.agent_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  user_data = templatefile("${path.module}/templates/puppet_bootstrap.sh", {
    puppet_master = aws_instance.puppet_master.private_ip
    environment  = var.environment
    certname     = "${var.environment}-agent-${count.index + 1}"
  })
  
  tags = {
    Name = "${var.environment}-puppet-agent-${count.index + 1}"
    PuppetEnvironment = var.environment
  }
}

# Puppet Master
resource "aws_instance" "puppet_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  
  user_data = templatefile("${path.module}/templates/puppet_master.sh", {
    domain_name = var.domain_name
  })
  
  tags = {
    Name = "${var.environment}-puppet-master"
    Role = "puppet-master"
  }
}

# External data source for Puppet facts
data "external" "puppet_facts" {
  count   = length(aws_instance.puppet_agents)
  program = ["python3", "${path.module}/scripts/get_puppet_facts.py"]
  
  query = {
    host = aws_instance.puppet_agents[count.index].private_ip
  }
}
```

## Container Orchestration Integration

### Kubernetes Infrastructure

```hcl
# kubernetes-infrastructure.tf
# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version
  
  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = var.public_access_enabled
    public_access_cidrs    = var.public_access_cidrs
  }
  
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

# Node Groups
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-nodes"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = aws_subnet.private[*].id
  
  capacity_type  = "ON_DEMAND"
  instance_types = var.node_instance_types
  
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }
  
  update_config {
    max_unavailable_percentage = 25
  }
  
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

# Fargate Profile
resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.environment}-fargate"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
  subnet_ids            = aws_subnet.private[*].id
  
  selector {
    namespace = "fargate"
  }
  
  selector {
    namespace = "kube-system"
    labels = {
      k8s-app = "kube-dns"
    }
  }
}

# IRSA (IAM Roles for Service Accounts)
module "irsa_aws_load_balancer_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  
  role_name = "${var.environment}-aws-load-balancer-controller"
  
  attach_load_balancer_controller_policy = true
  
  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}
```

### Kubernetes Resources via Terraform

```hcl
# kubernetes-resources.tf
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name]
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name]
    }
  }
}

# AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.1"
  
  values = [
    yamlencode({
      clusterName = aws_eks_cluster.main.name
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.irsa_aws_load_balancer_controller.iam_role_arn
        }
      }
    })
  ]
  
  depends_on = [aws_eks_node_group.main]
}

# Ingress Controller
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  
  values = [
    yamlencode({
      controller = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          }
        }
        metrics = {
          enabled = true
        }
      }
    })
  ]
}

# Application Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "${var.app_name}-deployment"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = var.app_name
    }
  }
  
  spec {
    replicas = var.app_replicas
    
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }
      
      spec {
        container {
          image = "${var.app_image}:${var.app_version}"
          name  = var.app_name
          
          port {
            container_port = var.app_port
          }
          
          env {
            name  = "DATABASE_URL"
            value = aws_db_instance.main.endpoint
          }
          
          env {
            name = "REDIS_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "redis-url"
              }
            }
          }
          
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = var.app_port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}
```

### Docker Swarm Integration

```hcl
# docker-swarm.tf
resource "aws_instance" "swarm_manager" {
  count         = var.manager_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.manager_instance_type
  key_name      = aws_key_pair.main.key_name
  
  vpc_security_group_ids = [aws_security_group.swarm_manager.id]
  subnet_id             = aws_subnet.private[count.index % length(aws_subnet.private)].id
  
  user_data = templatefile("${path.module}/templates/swarm_manager.sh", {
    is_primary = count.index == 0
    join_token_command = count.index == 0 ? "" : data.external.swarm_tokens.result.manager_token
  })
  
  tags = {
    Name = "${var.environment}-swarm-manager-${count.index + 1}"
    Role = "swarm-manager"
  }
}

resource "aws_instance" "swarm_worker" {
  count         = var.worker_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.worker_instance_type
  key_name      = aws_key_pair.main.key_name
  
  vpc_security_group_ids = [aws_security_group.swarm_worker.id]
  subnet_id             = aws_subnet.private[count.index % length(aws_subnet.private)].id
  
  user_data = templatefile("${path.module}/templates/swarm_worker.sh", {
    manager_ip = aws_instance.swarm_manager[0].private_ip
    join_token = data.external.swarm_tokens.result.worker_token
  })
  
  tags = {
    Name = "${var.environment}-swarm-worker-${count.index + 1}"
    Role = "swarm-worker"
  }
  
  depends_on = [aws_instance.swarm_manager]
}

# Get Swarm join tokens
data "external" "swarm_tokens" {
  program = ["bash", "${path.module}/scripts/get_swarm_tokens.sh"]
  
  query = {
    manager_ip = aws_instance.swarm_manager[0].private_ip
    key_file   = aws_key_pair.main.key_name
  }
  
  depends_on = [aws_instance.swarm_manager]
}

# Deploy stack via Docker Compose
resource "null_resource" "deploy_stack" {
  triggers = {
    compose_file_hash = filemd5("${path.module}/docker-compose.yml")
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      docker -H ssh://ubuntu@${aws_instance.swarm_manager[0].public_ip} \
        stack deploy -c ${path.module}/docker-compose.yml ${var.stack_name}
    EOT
  }
  
  depends_on = [aws_instance.swarm_worker]
}
```

## Serverless Infrastructure Patterns

### AWS Lambda with Infrastructure

```hcl
# serverless-patterns.tf
# Lambda Function
resource "aws_lambda_function" "api_handler" {
  filename         = "api_handler.zip"
  function_name    = "${var.environment}-api-handler"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 256
  
  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }
  
  environment {
    variables = {
      DB_HOST     = aws_db_instance.main.endpoint
      REDIS_HOST  = aws_elasticache_cluster.main.cache_nodes[0].address
      S3_BUCKET   = aws_s3_bucket.app_storage.bucket
      ENVIRONMENT = var.environment
    }
  }
  
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
  
  tracing_config {
    mode = "Active"
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# API Gateway Integration
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.environment}-api"
  description = "Serverless API Gateway"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.allowed_ips
          }
        }
      }
    ]
  })
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "ANY"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.api_handler.invoke_arn
}

# Step Functions for Orchestration
resource "aws_sfn_state_machine" "order_processing" {
  name     = "${var.environment}-order-processing"
  role_arn = aws_iam_role.step_function.arn
  
  definition = jsonencode({
    Comment = "Order processing workflow"
    StartAt = "ValidateOrder"
    States = {
      ValidateOrder = {
        Type     = "Task"
        Resource = aws_lambda_function.validate_order.arn
        Next     = "ProcessPayment"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException"]
            IntervalSeconds = 2
            MaxAttempts     = 6
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "OrderFailed"
          }
        ]
      }
      ProcessPayment = {
        Type     = "Task"
        Resource = aws_lambda_function.process_payment.arn
        Next     = "UpdateInventory"
      }
      UpdateInventory = {
        Type     = "Task"
        Resource = aws_lambda_function.update_inventory.arn
        Next     = "SendNotification"
      }
      SendNotification = {
        Type     = "Task"
        Resource = aws_lambda_function.send_notification.arn
        End      = true
      }
      OrderFailed = {
        Type   = "Fail"
        Cause  = "Order processing failed"
      }
    }
  })
}

# EventBridge for Event-Driven Architecture
resource "aws_cloudwatch_event_rule" "order_created" {
  name        = "${var.environment}-order-created"
  description = "Trigger when order is created"
  
  event_pattern = jsonencode({
    source      = ["custom.orders"]
    detail-type = ["Order Created"]
  })
}

resource "aws_cloudwatch_event_target" "step_function" {
  rule      = aws_cloudwatch_event_rule.order_created.name
  target_id = "OrderProcessingStepFunction"
  arn       = aws_sfn_state_machine.order_processing.arn
  role_arn  = aws_iam_role.eventbridge_step_function.arn
}

# SQS for Async Processing
resource "aws_sqs_queue" "order_queue" {
  name                       = "${var.environment}-order-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 300
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.order_queue.arn
  function_name    = aws_lambda_function.order_processor.arn
  batch_size       = 10
  
  scaling_config {
    maximum_concurrency = 100
  }
}

# DynamoDB for Serverless Database
resource "aws_dynamodb_table" "orders" {
  name           = "${var.environment}-orders"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "order_id"
  range_key      = "created_at"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  
  attribute {
    name = "order_id"
    type = "S"
  }
  
  attribute {
    name = "created_at"
    type = "S"
  }
  
  attribute {
    name = "customer_id"
    type = "S"
  }
  
  global_secondary_index {
    name     = "customer-index"
    hash_key = "customer_id"
    
    projection_type = "ALL"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb.arn
  }
  
  tags = {
    Name        = "${var.environment}-orders"
    Environment = var.environment
  }
}

# DynamoDB Streams Lambda Trigger
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.orders.stream_arn
  function_name     = aws_lambda_function.stream_processor.arn
  starting_position = "LATEST"
  batch_size        = 100
  
  filter_criteria {
    filter {
      pattern = jsonencode({
        eventName = ["INSERT", "MODIFY"]
      })
    }
  }
}

## Azure Serverless Patterns

# Azure Functions
resource "azurerm_storage_account" "functions" {
  name                     = "${var.environment}funcsa"
  resource_group_name      = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "functions" {
  name                = "${var.environment}-functions-plan"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  os_type            = "Linux"
  sku_name           = "Y1"
}

resource "azurerm_linux_function_app" "main" {
  name                = "${var.environment}-functions"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  
  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  service_plan_id           = azurerm_service_plan.functions.id
  
  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
  
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "COSMOS_DB_CONNECTION_STRING" = azurerm_cosmosdb_account.main.connection_strings[0]
    "SERVICE_BUS_CONNECTION_STRING" = azurerm_servicebus_namespace.main.default_primary_connection_string
  }
}

# Logic Apps for Workflow
resource "azurerm_logic_app_workflow" "order_processing" {
  name                = "${var.environment}-order-workflow"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  workflow_schema    = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version   = "1.0.0.0"
  
  parameters = {
    cosmosdb_connection = {
      type = "string"
      value = azurerm_cosmosdb_account.main.connection_strings[0]
    }
  }
}

## Google Cloud Serverless Patterns

# Cloud Functions
resource "google_cloudfunctions_function" "api_handler" {
  name        = "${var.environment}-api-handler"
  description = "API request handler"
  runtime     = "python39"
  
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.functions.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  trigger {
    http_trigger {
      url = null
    }
  }
  
  environment_variables = {
    DATABASE_URL = google_sql_database_instance.main.connection_name
    PROJECT_ID   = var.gcp_project_id
  }
  
  vpc_connector                 = google_vpc_access_connector.main.name
  vpc_connector_egress_settings = "ALL_TRAFFIC"
}

# Cloud Run for Containerized Serverless
resource "google_cloud_run_service" "api" {
  name     = "${var.environment}-api"
  location = var.gcp_region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.gcp_project_id}/${var.app_name}:${var.app_version}"
        
        env {
          name  = "DATABASE_URL"
          value = google_sql_database_instance.main.connection_name
        }
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        ports {
          container_port = 8080
        }
      }
      
      container_concurrency = 80
      timeout_seconds      = 300
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "100"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.main.connection_name
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.name
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Pub/Sub for Event-Driven Architecture
resource "google_pubsub_topic" "orders" {
  name = "${var.environment}-orders"
  
  message_storage_policy {
    allowed_persistence_regions = [var.gcp_region]
  }
}

resource "google_pubsub_subscription" "order_processor" {
  name  = "${var.environment}-order-processor"
  topic = google_pubsub_topic.orders.name
  
  message_retention_duration = "1200s"
  retain_acked_messages     = true
  ack_deadline_seconds      = 20
  
  expiration_policy {
    ttl = "300000.5s"
  }
  
  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
  
  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = 10
  }
}

# Cloud Workflows
resource "google_workflows_workflow" "order_processing" {
  name            = "${var.environment}-order-workflow"
  region          = var.gcp_region
  description     = "Order processing workflow"
  service_account = google_service_account.workflow.email
  
  source_contents = yamlencode({
    main = {
      steps = [
        {
          validate_order = {
            call = "http.post"
            args = {
              url = "${google_cloud_run_service.api.status[0].url}/validate"
              body = "${args.order}"
            }
            result = "validation_result"
          }
        },
        {
          process_payment = {
            call = "http.post"
            args = {
              url = "${google_cloud_run_service.api.status[0].url}/payment"
              body = {
                order_id = "${validation_result.body.order_id}"
                amount   = "${validation_result.body.amount}"
              }
            }
            result = "payment_result"
          }
        },
        {
          update_inventory = {
            call = "googleapis.firestore.v1.documents.patch"
            args = {
              name = "projects/${var.gcp_project_id}/databases/(default)/documents/inventory/${args.order.product_id}"
              body = {
                fields = {
                  quantity = {
                    integerValue = "${args.order.quantity - 1}"
                  }
                }
              }
            }
          }
        }
      ]
    }
  })
}

## Network and Security Automation

### Multi-Cloud Network Mesh
resource "aws_transit_gateway" "main" {
  description                     = "${var.environment} Transit Gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {
    Name = "${var.environment}-tgw"
  }
}

resource "aws_transit_gateway_vpc_attachment" "vpc_attachments" {
  count = length(var.vpc_ids)
  
  subnet_ids         = var.tgw_subnet_ids[count.index]
  transit_gateway_id = aws_transit_gateway.main.id
  vpc_id            = var.vpc_ids[count.index]
  
  tags = {
    Name = "${var.environment}-tgw-attachment-${count.index}"
  }
}

# AWS Network Firewall
resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.environment}-firewall-policy"
  
  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
    
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.allow_icmp.arn
    }
    
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.domain_filtering.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "domain_filtering" {
  capacity = 100
  name     = "${var.environment}-domain-filtering"
  type     = "STATEFUL"
  
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = ["10.0.0.0/16", "192.168.0.0/16"]
        }
      }
    }
    
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types        = ["HTTP_HOST", "TLS_SNI"]
        targets             = var.blocked_domains
      }
    }
  }
}

resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.environment}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id             = var.firewall_vpc_id
  
  dynamic "subnet_mapping" {
    for_each = var.firewall_subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }
}

### Zero Trust Network Architecture
resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "${var.environment} Client VPN"
  server_certificate_arn = aws_acm_certificate.vpn_server.arn
  client_cidr_block     = "172.16.0.0/16"
  
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn_client.arn
  }
  
  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }
  
  dns_servers = ["8.8.8.8", "8.8.4.4"]
  
  tags = {
    Name = "${var.environment}-client-vpn"
  }
}

# Service Mesh with Istio (EKS)
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  version    = var.istio_version
  
  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  version    = var.istio_version
  
  values = [
    yamlencode({
      global = {
        meshID      = var.environment
        network     = "network1"
        hub         = "docker.io/istio"
        tag         = var.istio_version
      }
      pilot = {
        env = {
          EXTERNAL_ISTIOD = false
        }
      }
    })
  ]
  
  depends_on = [helm_release.istio_base]
}

# Network Policies
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny"
    namespace = "default"
  }
  
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "allow_frontend_to_backend" {
  metadata {
    name      = "allow-frontend-to-backend"
    namespace = "default"
  }
  
  spec {
    pod_selector {
      match_labels = {
        app = "backend"
      }
    }
    
    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "frontend"
          }
        }
      }
      
      ports {
        protocol = "TCP"
        port     = "8080"
      }
    }
    
    policy_types = ["Ingress"]
  }
}

### Security Automation Patterns

# AWS Config Rules
resource "aws_config_configuration_recorder" "main" {
  name     = "${var.environment}-config-recorder"
  role_arn = aws_iam_role.config.arn
  
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "${var.environment}-s3-bucket-public-read-prohibited"
  
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_remediation_configuration" "s3_bucket_public_read" {
  config_rule_name = aws_config_config_rule.s3_bucket_public_read_prohibited.name
  
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-RemoveS3BucketPolicy"
  target_version   = "1"
  
  parameter {
    name           = "AutomationAssumeRole"
    static_value   = aws_iam_role.config_remediation.arn
  }
  
  parameter {
    name                = "BucketName"
    resource_value      = "RESOURCE_ID"
  }
  
  automatic          = true
  maximum_automatic_attempts = 3
}

# Security Hub Custom Insights
resource "aws_securityhub_insight" "critical_findings" {
  filters {
    severity_label {
      comparison = "EQUALS"
      value      = "CRITICAL"
    }
    
    record_state {
      comparison = "EQUALS"
      value      = "ACTIVE"
    }
  }
  
  group_by_attribute = "ProductArn"
  name              = "${var.environment}-critical-findings"
}

# CloudWatch Security Metrics
resource "aws_cloudwatch_metric_alarm" "high_failed_logins" {
  alarm_name          = "${var.environment}-high-failed-logins"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FailedLoginAttempts"
  namespace           = "CustomSecurity"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors failed login attempts"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
  
  insufficient_data_actions = []
}

# AWS Systems Manager for Patch Management
resource "aws_ssm_patch_baseline" "main" {
  name             = "${var.environment}-patch-baseline"
  description      = "Patch baseline for ${var.environment}"
  operating_system = "UBUNTU"
  
  approval_rule {
    approve_after_days = 7
    
    patch_filter {
      key    = "PRIORITY"
      values = ["Required", "Important"]
    }
    
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Bugfix", "Enhancement"]
    }
  }
  
  rejected_patches = ["kernel*"]
}

resource "aws_ssm_patch_group" "main" {
  baseline_id = aws_ssm_patch_baseline.main.id
  patch_group = "${var.environment}-servers"
}

resource "aws_ssm_maintenance_window" "main" {
  name     = "${var.environment}-maintenance-window"
  schedule = "cron(0 2 ? * SUN *)"
  duration = 3
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "main" {
  window_id     = aws_ssm_maintenance_window.main.id
  name          = "${var.environment}-maintenance-target"
  description   = "Maintenance window target"
  resource_type = "INSTANCE"
  
  targets {
    key    = "tag:PatchGroup"
    values = ["${var.environment}-servers"]
  }
}

resource "aws_ssm_maintenance_window_task" "patch_task" {
  max_concurrency = "2"
  max_errors      = "1"
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.main.id
  
  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.main.id]
  }
  
  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      
      timeout_seconds = 3600
    }
  }
}
```

## Best Practices Summary

### Multi-Cloud Strategy
- Use provider aliases for multi-region deployments
- Implement cloud abstraction layers for portability
- Standardize tagging and naming conventions
- Plan for cross-cloud networking requirements

### Hybrid Cloud Considerations
- Design for network latency and bandwidth constraints
- Implement proper identity federation
- Plan data residency and sovereignty requirements
- Consider disaster recovery across environments

### Infrastructure Automation
- Use event-driven patterns for responsive infrastructure
- Implement infrastructure state machines for complex workflows
- Design for idempotency and error handling
- Monitor and alert on infrastructure drift

### Container Orchestration
- Separate infrastructure and application concerns
- Use IRSA/Workload Identity for secure service access
- Implement proper network policies and security contexts
- Plan for multi-region and disaster recovery scenarios

### Serverless Architecture
- Design for stateless, event-driven patterns
- Implement proper error handling and dead letter queues
- Use managed services for databases and messaging
- Monitor cold starts and optimize performance

### Security Automation
- Implement security as code with policy frameworks
- Use automated compliance checking and remediation
- Design zero-trust network architectures
- Implement comprehensive logging and monitoring
