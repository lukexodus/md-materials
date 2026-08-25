## Overview

repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
-   repo: https://github.com/psf/black
    rev: 23.1.0
    hooks:
    -   id: black
-   repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
    -   id: flake8
```

### Server-side Hooks for Policy Enforcement

Server-side hooks run on the Git server when repositories receive pushed changes, providing a central point for policy enforcement.

#### Common Server-side Hook Uses

1. **Access Control**
    - Restrict who can push to specific branches
    - Enforce branch protection rules
    - Validate committer identities
2. **Quality Gates**
    - Block non-compliant commits (e.g., failing tests)
    - Enforce code review requirements
    - Check for minimum code coverage
3. **Process Enforcement**
    - Ensure commit messages follow conventions
    - Validate ticket/issue references
    - Enforce branch naming conventions
4. **Integration Triggering**
    - Start CI/CD pipelines
    - Update issue tracking systems
    - Send notifications
5. **Auditing**
    - Log all repository changes
    - Track sensitive file modifications
    - Generate compliance reports

**Example**

```bash
#!/bin/bash
