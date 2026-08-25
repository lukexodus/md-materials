## 4. Compliance Scanning and Policy as Code


### Sentinel Policies (Enterprise)

```sentinel
# Cost management policy
import "tfplan/v2" as tfplan
import "decimal"

main = rule {
  all tfplan.resource_changes as _, changes {
    changes.type is "aws_instance" and
    changes.change.after.instance_type in ["t3.micro", "t3.small", "t3.medium"]
  }
}
```

### Open Policy Agent (OPA) Integration

```rego
package terraform.security

# Deny S3 buckets without encryption
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not resource.change.after.server_side_encryption_configuration
  
  msg := sprintf("S3 bucket %s must have encryption enabled", [resource.address])
}

# Require specific tags
required_tags := ["Environment", "Owner", "Project"]

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"
  missing_tags := required_tags - object.get(resource.change.after, "tags", {})
  count(missing_tags) > 0
  
  msg := sprintf("Instance %s missing required tags: %v", [resource.address, missing_tags])
}
```

### Static Analysis Tools Configuration

#### tfsec

```yaml
# .tfsec/config.yml
exclude:
  - aws-s3-enable-logging
  - aws-vpc-enable-flow-logs

severity_overrides:
  aws-s3-encryption-customer-key: ERROR
```

#### Checkov

```yaml
# .checkov.yaml
framework:
  - terraform
quiet: true
skip-check:
  - CKV_AWS_18  # S3 Bucket should have access logging configured
output: sarif
```

