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

