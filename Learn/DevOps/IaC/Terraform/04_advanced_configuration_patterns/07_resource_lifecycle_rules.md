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

