## Overview

name: CI/CD

on:
  push:
    branches: [ main, develop, 'feature/**' ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # Common build steps...
      
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to production
        if: github.ref == 'refs/heads/main'
        run: ./deploy.sh production
        
      - name: Deploy to staging
        if: github.ref == 'refs/heads/develop'
        run: ./deploy.sh staging
        
      - name: Deploy to feature environment
        if: startsWith(github.ref, 'refs/heads/feature/')
        run: ./deploy.sh feature-$(echo $GITHUB_REF | sed 's|refs/heads/feature/||')
```

#### GitOps Approaches

GitOps uses Git as the source of truth for declarative infrastructure and application configuration:

- **Infrastructure as Code**: Git repositories contain infrastructure definitions
- **Configuration as Code**: All system configurations stored in Git
- **Automated Reconciliation**: Systems automatically sync with Git state
- **Pull-based Deployment**: Agents pull changes from Git to update systems

```yaml
