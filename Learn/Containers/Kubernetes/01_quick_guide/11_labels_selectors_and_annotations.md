## Labels, Selectors, and Annotations


### Labels

Labels are key-value pairs attached to objects. They are used to organize and select subsets of objects.

```yaml
metadata:
  labels:
    app: my-app
    env: production
    version: "1.5"
    tier: frontend
```

```bash
# Filter by label
kubectl get pods -l app=my-app
kubectl get pods -l 'env in (production, staging)'
kubectl get pods -l 'env notin (dev)'
kubectl get pods -l app=my-app,env=production
```

### Annotations

Annotations store arbitrary non-identifying metadata. They are not used for selection but are useful for tools, CI systems, and documentation:

```yaml
metadata:
  annotations:
    description: "Main web frontend"
    git-commit: "a3f7c2d"
    kubernetes.io/change-cause: "Updated to nginx 1.25"
```

---

