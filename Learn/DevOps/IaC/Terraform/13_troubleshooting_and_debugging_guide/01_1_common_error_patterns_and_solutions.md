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

