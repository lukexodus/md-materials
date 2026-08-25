## CI/CD Pipeline Design Patterns


### Standard Pipeline Flow

```
Code Push → Validate → Plan → Review → Apply → Test → Deploy
```

### Multi-Environment Pipeline

```yaml
# Example GitHub Actions workflow
name: Terraform CI/CD
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform fmt -check
      - run: terraform validate
      - run: terraform plan -out=tfplan

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Checkov
        run: checkov -d . --framework terraform

  plan:
    needs: [validate, security-scan]
    runs-on: ubuntu-latest
    environment: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform plan -var-file="${{ github.ref == 'refs/heads/main' && 'prod' || 'staging' }}.tfvars"

  apply:
    needs: plan
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    steps:
      - run: terraform apply -auto-approve
```

### Pipeline Patterns

**1. Sequential Pipeline**

```
Dev → Staging → Production
```

**2. Parallel Pipeline**

```
Feature Branch → Dev + Test
                     ↓
                 Staging
                     ↓
                Production
```

**3. Matrix Pipeline**

```
Code → [AWS, Azure, GCP] → Environments
```

