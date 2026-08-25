## 4. Static Analysis Tools


### TFLint Configuration

```hcl
# .tflint.hcl
plugin "aws" {
    enabled = true
    version = "0.21.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_deprecated_interpolation" {
    enabled = true
}

rule "terraform_unused_declarations" {
    enabled = true
}

rule "terraform_comment_syntax" {
    enabled = true
}

rule "terraform_documented_outputs" {
    enabled = true
}

rule "terraform_documented_variables" {
    enabled = true
}

rule "terraform_typed_variables" {
    enabled = true
}

rule "terraform_module_pinned_source" {
    enabled = true
}

rule "terraform_naming_convention" {
    enabled = true
    format  = "snake_case"
}

rule "terraform_standard_module_structure" {
    enabled = true
}
```

### Checkov Configuration

```yaml
# .checkov.yml
framework:
  - terraform
  - terraform_plan

skip-check:
  - CKV_AWS_20  # S3 Bucket should not allow public read access
  - CKV_AWS_21  # S3 Bucket should not allow public write access

soft-fail: true

output: cli
quiet: false
compact: false

include-all-checkov-policies: true

evaluate-variables: true
```

### CI/CD Integration

```yaml
# .github/workflows/terraform-validation.yml
name: Terraform Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Format
      run: terraform fmt -check -recursive
    
    - name: Terraform Init
      run: terraform init
    
    - name: Terraform Validate
      run: terraform validate
    
    - name: Setup TFLint
      uses: terraform-linters/setup-tflint@v3
    
    - name: Run TFLint
      run: |
        tflint --init
        tflint
    
    - name: Run Checkov
      uses: bridgecrewio/checkov-action@master
      with:
        directory: .
        framework: terraform
        soft_fail: true
```

