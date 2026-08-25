## Overview

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/organization/infra-repo.git
    targetRevision: HEAD
    path: kubernetes/myapp
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

#### Release Tagging and Automation

Automating the release process with Git tags:

- **Semantic versioning**: Automated version calculation
- **Changelog generation**: Automated from commit history
- **Release builds**: Triggered by tag creation
- **Artifact publishing**: Based on Git tags
- **Environment promotion**: Releases deployed to environments by tag

```yaml
