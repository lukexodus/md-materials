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

