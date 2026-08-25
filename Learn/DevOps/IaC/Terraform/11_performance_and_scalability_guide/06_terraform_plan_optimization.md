## Terraform Plan Optimization


### Plan Generation Performance

```bash
# Generate plan file for reuse
terraform plan -out=tfplan

# Apply pre-generated plan
terraform apply tfplan

# Detailed plan timing
terraform plan -detailed-timing
```

### Plan Optimization Techniques

- **Use plan files**: Generate once, apply multiple times in CI/CD
- **Selective planning**: Use `-target` for large infrastructures
- **Plan caching**: Store plans in CI/CD artifacts
- **Parallel planning**: Run multiple targeted plans concurrently

### Plan Analysis and Debugging

```bash
# Show plan in JSON format
terraform show -json tfplan

# Analyze plan changes
terraform plan -detailed-timing > plan_timing.log
```

