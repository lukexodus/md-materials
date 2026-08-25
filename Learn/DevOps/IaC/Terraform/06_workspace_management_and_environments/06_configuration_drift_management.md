## Configuration Drift Management


Configuration drift occurs when the actual infrastructure state differs from what Terraform expects based on its state file:

**Detection Methods**:

- `terraform plan`: Shows differences between desired and current state
- `terraform refresh`: Updates state file with current resource attributes
- Automated drift detection tools and monitoring
- Regular plan runs in CI/CD pipelines

**Common Causes of Drift**:

- Manual changes made outside of Terraform
- External systems modifying resources
- Resource attribute changes by cloud provider policies
- Incomplete or failed Terraform runs

**Prevention Strategies**:

- Implement proper access controls and policies
- Use resource-level protection mechanisms
- Regular automated plan checks
- Team training on Terraform workflows
- Documentation of approved manual intervention procedures

**Remediation Approaches**:

- `terraform apply`: Brings infrastructure back to desired state
- `terraform import`: Incorporates manually created resources
- Configuration updates to match intentional changes
- State file manipulation for complex scenarios

