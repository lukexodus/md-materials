## 3. Policy Testing with OPA/Sentinel


### Open Policy Agent (OPA) Testing

#### Policy Example

```rego
# policies/security.rego
package terraform.security

import data.terraform.plan as tfplan

# Deny S3 buckets without encryption
deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not resource.change.after.server_side_encryption_configuration
    
    msg := sprintf("S3 bucket '%s' must have encryption enabled", [resource.address])
}

# Require specific instance types
allowed_instance_types := ["t2.micro", "t2.small", "t3.micro", "t3.small"]

deny[msg] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_instance"
    not resource.change.after.instance_type in allowed_instance_types
    
    msg := sprintf("Instance '%s' uses disallowed instance type '%s'", 
        [resource.address, resource.change.after.instance_type])
}
```

#### Testing Policies

```bash
# Test policy with sample plan
opa test policies/ test_data/

# Run policy against Terraform plan
terraform plan -out=plan.out
terraform show -json plan.out > plan.json
opa eval -d policies/ -i plan.json "data.terraform.security.deny[x]"
```

### Sentinel Testing

#### Policy Example

```hcl
# policies/aws-security.sentinel
import "tfplan/v2" as tfplan

# Find all S3 buckets
s3_buckets = filter tfplan.resource_changes as _, rc {
    rc.type is "aws_s3_bucket" and
    rc.mode is "managed" and
    (rc.change.actions contains "create" or rc.change.actions contains "update")
}

# Rule: S3 buckets must have versioning enabled
bucket_versioning_enabled = rule {
    all s3_buckets as _, bucket {
        bucket.change.after.versioning[0].enabled is true
    }
}

# Main rule
main = rule {
    bucket_versioning_enabled
}
```

#### Testing Sentinel Policies

```bash
# Test policy
sentinel test

# Apply policy to plan
sentinel apply -config=sentinel.hcl aws-security.sentinel
```

