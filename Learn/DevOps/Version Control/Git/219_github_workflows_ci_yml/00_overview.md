## Overview

name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0  # Fetch all history for proper versioning
        
    - name: Set up JDK
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
        
    - name: Build with Maven
      run: mvn -B package
      
    - name: Run tests
      run: mvn test
      
    - name: Deploy if main branch
      if: github.ref == 'refs/heads/main'
      run: ./deploy.sh
      env:
        DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
```

#### GitLab CI/CD

GitLab offers an integrated CI/CD system with comprehensive Git integration:

- **Auto DevOps**: Automatic CI/CD pipeline configuration
- **.gitlab-ci.yml**: Pipeline configuration file
- **Pipeline graphs**: Visual representation of stages and jobs
- **Review Apps**: Dynamic environments for merge requests
- **GitLab Runners**: Self-hosted or GitLab-hosted execution

```yaml
