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

