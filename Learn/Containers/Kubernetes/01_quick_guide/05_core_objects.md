## Core Objects


### Pod

A Pod is the smallest deployable unit in Kubernetes. It wraps one or more containers that share network and storage.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: my-app
spec:
  containers:
    - name: my-container
      image: nginx:1.25
      ports:
        - containerPort: 80
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "500m"
          memory: "256Mi"
      env:
        - name: ENV_VAR
          value: "hello"
      volumeMounts:
        - name: my-volume
          mountPath: /data
  volumes:
    - name: my-volume
      emptyDir: {}
```

Pods are ephemeral. They are not typically created directly — use higher-level controllers (Deployments, StatefulSets, etc.) that manage Pod lifecycle.

### Multi-Container Pods

Containers in the same Pod share the same network namespace (same IP, same localhost) and can share volumes:

```yaml
spec:
  containers:
    - name: app
      image: my-app:1.0
    - name: sidecar
      image: log-forwarder:1.0
      volumeMounts:
        - name: logs
          mountPath: /var/log
  volumes:
    - name: logs
      emptyDir: {}
```

Common multi-container patterns: sidecar (logging, proxies), init containers (setup tasks), ambassador (proxying external services).

### Init Containers

Init containers run and complete before the main containers start:

```yaml
spec:
  initContainers:
    - name: wait-for-db
      image: busybox
      command: ['sh', '-c', 'until nc -z db-service 5432; do sleep 2; done']
  containers:
    - name: app
      image: my-app:1.0
```

---

