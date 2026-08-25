## RBAC — Role-Based Access Control


### Core Concepts

- **Role** — grants permissions within a namespace
- **ClusterRole** — grants permissions cluster-wide
- **RoleBinding** — binds a Role to users/groups/service accounts within a namespace
- **ClusterRoleBinding** — binds a ClusterRole cluster-wide

### Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
  - apiGroups: [""]        # "" = core API group
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
```

### ClusterRole

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-viewer
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "watch"]
```

### RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
  - kind: User
    name: alice
    apiGroup: rbac.authorization.k8s.io
  - kind: ServiceAccount
    name: my-service-account
    namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### ServiceAccount

ServiceAccounts provide an identity for Pods to authenticate to the API server:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
```

```yaml
spec:
  serviceAccountName: my-service-account
  containers:
    - name: app
      image: my-app:1.0
```

---

