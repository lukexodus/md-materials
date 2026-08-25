## Overview

name: CI Pipeline

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
      - name: Build
        run: ./gradlew build
      - name: Test
        run: ./gradlew test
```

#### Pipeline Configuration as Code

Modern CI/CD systems store pipeline configurations in the Git repository itself, often called "Pipeline as Code" or "Configuration as Code":

- **Jenkins**: Jenkinsfile
- **GitHub Actions**: YAML files in .github/workflows/
- **GitLab CI**: .gitlab-ci.yml
- **Azure DevOps**: azure-pipelines.yml
- **CircleCI**: .circleci/config.yml

This approach ensures that pipeline changes are versioned alongside the code they build, providing complete traceability.

### Git Hooks for Automation

Git hooks are scripts that Git executes before or after events such as commit, push, and receive. They provide powerful integration points for automating workflows and enforcing standards.

#### Types of Git Hooks

Git hooks fall into two main categories:

1. **Client-side hooks**: Run on the developer's local machine
    - pre-commit: Before commit creation
    - prepare-commit-msg: Before the commit message editor is launched
    - commit-msg: After the commit message is created
    - post-commit: After the commit is complete
    - pre-rebase: Before rebasing
    - post-checkout: After checking out a branch
    - pre-push: Before pushing commits
2. **Server-side hooks**: Run on the Git server
    - pre-receive: Before accepting pushed commits
    - update: Similar to pre-receive but runs once per branch
    - post-receive: After the entire push process is completed

#### Implementing Git Hooks

Git hooks are stored in the `.git/hooks` directory of a repository. To implement a hook:

1. Create an executable script with the appropriate name
2. Place it in the `.git/hooks` directory
3. Ensure it has execute permissions

```bash
