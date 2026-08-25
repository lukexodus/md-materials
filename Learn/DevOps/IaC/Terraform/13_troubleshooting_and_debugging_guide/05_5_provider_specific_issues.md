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

