## Rollback and Disaster Recovery


### State Management for Rollbacks

**State Backup Strategy**

```bash
#!/bin/bash
# backup-state.sh

# Backup before changes
aws s3 cp terraform.tfstate s3://tfstate-backup/$(date +%Y%m%d-%H%M%S)/

# Tag successful deployments
git tag -a "deploy-$(date +%Y%m%d-%H%M%S)" -m "Successful deployment"
```

**Rollback Procedures**

```yaml
# rollback-pipeline.yml
rollback:
  steps:
    - name: Identify Last Good State
      run: |
        LAST_GOOD_TAG=$(git tag -l "deploy-*" | sort -V | tail -1)
        echo "Rolling back to: $LAST_GOOD_TAG"
    
    - name: Restore Configuration
      run: |
        git checkout $LAST_GOOD_TAG
        terraform init
    
    - name: Plan Rollback
      run: terraform plan -out=rollback.tfplan
    
    - name: Execute Rollback
      run: terraform apply rollback.tfplan
    
    - name: Verify Rollback
      run: ./health-check.sh
```

### Disaster Recovery

**Multi-Region Setup**

```hcl
# disaster-recovery.tf
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

provider "aws" {
  alias  = "disaster_recovery"
  region = "us-west-2"
}

module "primary_infrastructure" {
  source = "./modules/infrastructure"
  providers = {
    aws = aws.primary
  }
}

module "dr_infrastructure" {
  source = "./modules/infrastructure"
  providers = {
    aws = aws.disaster_recovery
  }
  
  # Reduced capacity for DR
  instance_count = var.primary_instance_count * 0.5
}
```

**Automated DR Testing**

```bash
#!/bin/bash
# dr-test.sh

# Simulate primary region failure
terraform apply -var="primary_region_enabled=false"

# Activate DR region
terraform apply -var="dr_region_active=true"

# Run health checks
./health-check.sh dr-region

# Restore primary (after testing)
terraform apply -var="primary_region_enabled=true" -var="dr_region_active=false"
```

