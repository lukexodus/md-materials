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

