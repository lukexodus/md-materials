## Kubernetes Basics


### Introduction to Kubernetes

Kubernetes (K8s) is an open-source container orchestration platform designed to automate the deployment, scaling, and management of containerized applications. Originally developed by Google and now maintained by the Cloud Native Computing Foundation (CNCF), Kubernetes has become the industry standard for container orchestration.

**Key Points**:

- Kubernetes works with container runtimes like Docker, containerd, and CRI-O
- Provides declarative configuration approach using YAML or JSON
- Follows a master-worker architecture with control plane and node components
- Self-healing capabilities automatically restart failed containers
- Built-in scaling and load balancing mechanisms

### Architecture Overview

Kubernetes follows a distributed architecture consisting of a control plane (master components) and worker nodes.

The control plane includes:

- API Server: Communication hub for all cluster components
- etcd: Distributed key-value store that persists cluster state
- Scheduler: Assigns workloads to nodes based on constraints and resources
- Controller Manager: Runs controller processes to regulate cluster state
- Cloud Controller Manager: Interfaces with cloud provider APIs

Worker nodes contain:

- kubelet: Agent ensuring containers run in a pod
- kube-proxy: Maintains network rules for pod communication
- Container Runtime: Software executing containers (Docker, containerd, etc.)

### Pods, ReplicaSets, and Deployments

#### Pods

A Pod is the smallest deployable unit in Kubernetes. It's a logical host for one or more containers that share network namespace, storage, and lifecycle.

**Key Points**:

- Pods are ephemeral and can be terminated at any time
- Containers within a pod share the same IP address and port space
- Pods are scheduled on nodes as complete units
- Best practice is to run a single application container per pod

**Example**:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

#### ReplicaSets

ReplicaSets ensure a specified number of pod replicas are running at any given time, providing high availability and fault tolerance.

**Key Points**:

- Maintains a stable set of replica pods
- Uses a selector to identify which pods it can manage
- Creates new pods when existing ones fail, are deleted, or terminated
- Generally not used directly; Deployments are preferred

**Example**:

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

#### Deployments

Deployments provide declarative updates for Pods and ReplicaSets, managing application rollout and rollback.

**Key Points**:

- Manages ReplicaSets and provides updates to pods
- Enables rolling updates and rollbacks
- Maintains application availability during updates
- Records deployment history for reverting if needed
- Most common way to deploy containerized applications

**Example**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

### Services and Ingress

#### Services

Services provide stable network endpoints to access pods regardless of their lifecycle changes. They enable pod-to-pod communication and expose applications to external users.

**Key Points**:

- Uses labels and selectors to target pods
- Provides stable IP address and DNS name
- Load balances traffic across multiple pod replicas
- Supports different service types for various access scenarios

Service types:

- ClusterIP (default): Internal access only
- NodePort: Exposes on each node's IP at a static port
- LoadBalancer: Provisions an external load balancer
- ExternalName: Maps to an external DNS name

**Example**:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

#### Ingress

Ingress manages external access to services, typically HTTP/HTTPS routing, providing TLS termination, name-based virtual hosting, and more.

**Key Points**:

- Acts as an entry point to the cluster
- Requires an Ingress Controller to work (NGINX, Traefik, HAProxy, etc.)
- Supports path-based and host-based routing
- Can handle TLS/SSL termination
- Enables complex routing rules not possible with Services alone

**Example**:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls-secret
```

### ConfigMaps and Secrets

#### ConfigMaps

ConfigMaps allow you to decouple configuration from container images, making applications more portable and environment-agnostic.

**Key Points**:

- Store non-sensitive configuration data
- Can be mounted as files, environment variables, or command-line arguments
- Enables configuration changes without rebuilding container images
- Can be created from literal values, files, or directories

**Example**:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.url: "db.example.com:3306"
  app.log.level: "INFO"
  config.json: |
    {
      "cache": true,
      "maxConnections": 100
    }
```

Using a ConfigMap in a pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.url
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
```

#### Secrets

Secrets store sensitive information like passwords, tokens, and keys, with base64 encoding and access controls.

**Key Points**:

- Store sensitive data separate from pod definitions
- Not encrypted by default, only base64 encoded
- Can be mounted as files or exposed as environment variables
- Should be used with RBAC and encryption at rest for security
- Various types: generic, TLS, docker-registry, etc.

**Example**:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded "admin"
  password: cGFzc3dvcmQxMjM=  # base64 encoded "password123"
```

Using a Secret in a pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database-pod
spec:
  containers:
  - name: database
    image: postgres:13
    env:
    - name: POSTGRES_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
```

### Storage Concepts

#### Volumes

Volumes provide persistent storage for containers that survives pod restarts and container crashes.

**Key Points**:

- Shared between containers in a pod
- Lifecycle tied to the pod's lifecycle
- Many types: emptyDir, hostPath, nfs, configMap, secret, persistentVolumeClaim
- Can be mounted at specific paths within containers

**Example**:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-processor
spec:
  containers:
  - name: processor
    image: data-processor:1.0
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    emptyDir: {}
```

#### Persistent Volumes (PV) and Persistent Volume Claims (PVC)

PVs are cluster resources that provide storage independent of pod lifecycle. PVCs are requests for storage by users that can be fulfilled by PVs.

**Key Points**:

- PVs are provisioned by administrators or dynamically via storage classes
- PVCs specify storage requirements like size and access modes
- Storage Classes define provisioners for automatic PV creation
- Access modes include ReadWriteOnce, ReadOnlyMany, ReadWriteMany
- Reclaim policies: Retain, Delete, Recycle

**Example**: PersistentVolume:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /data/pv
```

PersistentVolumeClaim:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
```

Using PVC in a pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database
spec:
  containers:
  - name: postgres
    image: postgres:13
    volumeMounts:
    - name: postgres-data
      mountPath: /var/lib/postgresql/data
  volumes:
  - name: postgres-data
    persistentVolumeClaim:
      claimName: data-pvc
```

#### Storage Classes

Storage Classes enable dynamic provisioning of PVs based on predefined storage types and parameters.

**Key Points**:

- Define provisioners for different storage backends
- Enable automatic creation of PVs when PVCs are created
- Can specify default storage class for the cluster
- Configure storage-specific parameters
- Support provisioners for cloud providers, local storage, etc.

**Example**:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iopsPerGB: "10"
  encrypted: "true"
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

### StatefulSets

StatefulSets manage stateful applications with unique network identities, stable persistent storage, and ordered deployment and scaling.

**Key Points**:

- Manage pods with stable, unique network identifiers
- Provide ordered, graceful deployment and scaling
- Create volumeClaimTemplates for stable storage
- Ideal for databases, distributed systems, and stateful applications
- Pod names follow the pattern `<statefulset-name>-<ordinal-index>`

**Example**:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

### DaemonSets

DaemonSets ensure that a copy of a pod runs on all or selected nodes in the cluster, useful for node monitoring, log collection, and storage services.

**Key Points**:

- Runs one pod per node (or selected nodes)
- Automatically adds pods to new nodes as they join the cluster
- Removes pods when nodes are drained or removed
- Perfect for infrastructure-related tasks
- Common uses: log collectors, monitoring agents, storage daemons

**Example**:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-daemon
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluentd:v1.14
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 100Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

### Kubernetes RBAC (Role-Based Access Control)

RBAC is Kubernetes' native authorization mechanism that regulates access to cluster resources based on roles assigned to users.

**Key Points**:

- Core components: Roles, ClusterRoles, RoleBindings, ClusterRoleBindings
- Roles define permissions within a namespace
- ClusterRoles define permissions across all namespaces
- Bindings assign roles to users, groups, or service accounts
- Follows principle of least privilege

**Example**: Role:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

RoleBinding:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### Kubernetes Networking

Kubernetes implements a flat network model where all pods can communicate with each other without NAT, regardless of the node they're running on.

**Key Points**:

- Each pod gets a unique IP address
- Container Network Interface (CNI) implements the network model
- Popular CNI plugins: Calico, Flannel, Weave Net, Cilium
- Network policies control pod-to-pod communication
- Services abstract pod addressing and provide load balancing

**Example** of a Network Policy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: backend
    ports:
    - protocol: TCP
      port: 5432
```

### Recommended related topics:

- Helm - Package manager for Kubernetes
- Kubernetes Operators - Extensions that use custom resources to manage applications
- Service Mesh solutions (Istio, Linkerd)
- GitOps workflows with ArgoCD or Flux
- Kubernetes security best practices
- Multi-cluster management and Federation

---

