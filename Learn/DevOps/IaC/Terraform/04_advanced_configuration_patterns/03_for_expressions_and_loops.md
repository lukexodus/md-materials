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

