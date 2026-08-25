## Workload Controllers


### Deployment

Deployments are the standard way to run stateless applications. They manage a ReplicaSet, which manages Pods.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-container
          image: nginx:1.25
          ports:
            - containerPort: 80
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Max Pods above desired count during update
      maxUnavailable: 0  # Max Pods below desired count during update
```

```bash
# Scale
kubectl scale deployment my-deployment --replicas=5

# View rollout status
kubectl rollout status deployment/my-deployment

# Rollout history
kubectl rollout history deployment/my-deployment

# Roll back to previous version
kubectl rollout undo deployment/my-deployment

# Roll back to specific revision
kubectl rollout undo deployment/my-deployment --to-revision=2

# Pause/resume a rollout
kubectl rollout pause deployment/my-deployment
kubectl rollout resume deployment/my-deployment
```

### ReplicaSet

A ReplicaSet ensures a specified number of Pod replicas are running at all times. Deployments manage ReplicaSets — you rarely create ReplicaSets directly.

### StatefulSet

StatefulSets manage stateful applications. Unlike Deployments, each Pod gets a stable, unique identity and persistent storage.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: my-db
spec:
  serviceName: "my-db"
  replicas: 3
  selector:
    matchLabels:
      app: my-db
  template:
    metadata:
      labels:
        app: my-db
    spec:
      containers:
        - name: db
          image: postgres:15
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 10Gi
```

Key properties of StatefulSets:

- Pods are named with an ordinal index: `my-db-0`, `my-db-1`, `my-db-2`
- Pods are created and deleted in order
- Each Pod gets its own PersistentVolumeClaim
- Stable DNS hostnames: `my-db-0.my-db.default.svc.cluster.local`

### DaemonSet

A DaemonSet ensures one Pod runs on every (or selected) node. Used for cluster-wide agents like log collectors, monitoring agents, or network plugins.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
        - name: fluentd
          image: fluentd:v1.16
```

### Job

A Job runs one or more Pods to completion. It retries on failure until the desired completions are reached.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-migration
spec:
  completions: 1
  parallelism: 1
  backoffLimit: 4
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: migrate
          image: my-app:1.0
          command: ["python", "migrate.py"]
```

### CronJob

A CronJob creates Jobs on a schedule:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-backup
spec:
  schedule: "0 2 * * *"    # Every day at 2:00 AM
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: backup
              image: my-backup:1.0
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
```

---

