## Resource Targeting and Partial Deployments


### Strategic Resource Targeting

```bash
# Target specific resources
terraform apply -target=aws_instance.web
terraform apply -target=module.database

# Target resource types
terraform apply -target='aws_security_group.*'

# Multiple targets
terraform apply -target=aws_instance.web -target=aws_instance.api
```

### Partial Deployment Strategies

- **Infrastructure layers**: Deploy foundation first, then applications
- **Blue-green deployments**: Use targeting for gradual rollouts
- **Emergency fixes**: Apply critical fixes without full deployment

### Resource Replacement Strategies

```bash
# Force resource replacement
terraform apply -replace=aws_instance.web

# Plan replacement without applying
terraform plan -replace=aws_instance.web
```

