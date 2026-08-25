## Automated Testing Integration


### Testing Pyramid for Infrastructure

**Unit Tests (Terraform Modules)**

```hcl
# tests/unit/vpc_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCCreation(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/vpc",
        Vars: map[string]interface{}{
            "cidr_block": "10.0.0.0/16",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

**Integration Tests**

```yaml
# .github/workflows/integration-test.yml
- name: Integration Tests
  run: |
    cd tests/integration
    go test -v -timeout 30m
```

**Policy Tests (OPA/Conftest)**

```rego
# policies/security.rego
package terraform.security

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not resource.change.after.server_side_encryption_configuration
    msg := "S3 buckets must have encryption enabled"
}
```

**Compliance Tests**

```yaml
# compliance-test.yml
- name: Compliance Check
  run: |
    inspec exec aws-baseline \
      --target aws:// \
      --reporter cli json:compliance-report.json
```

