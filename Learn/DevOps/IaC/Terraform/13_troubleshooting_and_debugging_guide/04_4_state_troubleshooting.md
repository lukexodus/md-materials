## 4. State Troubleshooting


### State File Issues

#### State Lock Problems

```bash
# Error: Error locking state
Error: Error acquiring the state lock

# Solutions:
# 1. Wait for lock to release naturally
# 2. Force unlock (use carefully)
terraform force-unlock LOCK_ID

# 3. Check who has the lock (AWS DynamoDB)
aws dynamodb get-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"path/to/state"}}'
```

#### State Drift Detection

```bash
# Check for drift between state and reality
terraform plan -refresh-only

# Show what has changed
terraform show -json | jq '.values.root_module.resources[] | select(.values != .prior_state.values)'

# Fix drift by refreshing state
terraform apply -refresh-only
```

### State Recovery Techniques

#### Backup and Restore

```bash
# Create state backup before risky operations
cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)

# Restore from backup
cp terraform.tfstate.backup.20230728_100000 terraform.tfstate

# For remote state (S3)
aws s3 cp s3://my-tf-state/terraform.tfstate terraform.tfstate.backup
```

#### Moving Resources Between States

```bash
# Move resource to different state file
terraform state mv aws_instance.web module.compute.aws_instance.web

# Remove resource from state (keeps real resource)
terraform state rm aws_instance.web

# Import existing resource into state
terraform import aws_instance.web i-1234567890abcdef0
```

#### State File Corruption Recovery

```bash
# If state file is corrupted:

# 1. Try to recover from backup
ls -la terraform.tfstate.backup*

# 2. Use remote state versioning (S3)
aws s3api list-object-versions --bucket my-tf-state --prefix terraform.tfstate

# 3. Rebuild state by importing resources
terraform import aws_vpc.main vpc-12345678
terraform import aws_subnet.public subnet-12345678
# ... continue for all resources
```

### Working with Remote State Issues

```bash
# S3 backend troubleshooting

# Check S3 bucket access
aws s3 ls s3://my-terraform-state/

# Verify DynamoDB table for locking
aws dynamodb describe-table --table-name terraform-locks

# Test backend configuration
terraform init -backend-config="bucket=my-terraform-state"
```

