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

