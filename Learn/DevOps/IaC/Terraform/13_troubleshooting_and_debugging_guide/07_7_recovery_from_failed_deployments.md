## 7. Recovery from Failed Deployments


### Partial Apply Failures

#### Understanding Apply Failures

```bash
# When apply fails partway through:
Error: Error creating instance: RequestLimitExceeded

# Check what was created successfully
terraform show
terraform state list

# Continue with remaining resources
terraform apply -target=aws_security_group.web
terraform apply -target=aws_instance.database
```

#### Manual Resource Recovery

```bash
# If resources exist but not in state:

# 1. Identify orphaned resources
aws ec2 describe-instances --filters "Name=tag:Environment,Values=production"

# 2. Import into Terraform state
terraform import aws_instance.web i-1234567890abcdef0

# 3. Verify configuration matches
terraform plan
```

### Rollback Strategies

#### Infrastructure Rollback

```bash
# Option 1: Destroy and recreate
terraform destroy -target=aws_instance.web
terraform apply -target=aws_instance.web

# Option 2: Revert to previous configuration
git checkout HEAD~1 -- main.tf
terraform plan
terraform apply

# Option 3: Use workspace for rollback
terraform workspace select previous-version
terraform apply
```

#### State File Recovery

```bash
# Recover from state backup
cp terraform.tfstate.backup terraform.tfstate

# For remote state with versioning
aws s3api get-object \
  --bucket my-tf-state \
  --key terraform.tfstate \
  --version-id VERSION_ID \
  terraform.tfstate
```

### Database and Critical Resource Recovery

```bash
# For database disasters:

# 1. Check for automated backups
aws rds describe-db-snapshots --db-instance-identifier mydb

# 2. Restore from snapshot
resource "aws_db_instance" "restored" {
  identifier     = "mydb-restored"
  snapshot_identifier = "mydb-snapshot-20230728"
  # ... other configuration
}

# 3. Update application configuration
# 4. Test connectivity and data integrity
```

