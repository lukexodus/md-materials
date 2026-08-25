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

