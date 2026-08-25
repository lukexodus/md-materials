## Overview

variables:
  PROTECTED_BRANCHES: "main,release/*"

workflow:
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^($PROTECTED_BRANCHES)$/ && $CI_PIPELINE_SOURCE == "merge_request_event"'
      when: never
    - when: always
```

#### Enterprise RBAC Models

- Developer: Can push to development branches but not protected branches
- Maintainer: Can push to protected branches, merge PRs, manage releases
- Admin: Full repository control, including settings and security policies
- Security Officer: Audit access, manage secrets, enforce compliance

#### Integrating with Enterprise Identity Management

```bash
