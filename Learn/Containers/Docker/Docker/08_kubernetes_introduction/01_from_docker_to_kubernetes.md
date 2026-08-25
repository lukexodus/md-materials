## From Docker to Kubernetes


### Docker vs. Kubernetes

Docker and Kubernetes serve different but complementary roles in container technology. Understanding their relationship helps clarify when and how to use each technology.

**Key Points:**

- Docker is a platform for developing, shipping, and running containers
- Kubernetes is a container orchestration system for automating deployment and management
- Docker focuses on building and running individual containers
- Kubernetes focuses on coordinating multiple containers across multiple hosts
- Docker provides the container runtime that Kubernetes often uses
- Kubernetes adds scheduling, scaling, load balancing, and self-healing capabilities

Functionality comparison:

|Feature|Docker|Kubernetes|
|---|---|---|
|Container runtime|Yes|No (uses container runtimes like Docker)|
|Container building|Yes|No|
|Container registry|Yes (Docker Hub)|No (uses external registries)|
|Auto-scaling|Limited (Swarm)|Yes|
|Service discovery|Basic (Swarm)|Advanced|
|Rolling updates|Basic (Swarm)|Advanced|
|Health checks|Basic|Advanced|
|Self-healing|Limited|Comprehensive|
|Load balancing|Basic|Advanced|
|Storage orchestration|Basic|Advanced|
|Batch execution|No|Yes|
|Declarative configuration|Limited|Yes|

**Example:** With Docker alone, you might run:

```bash
docker run -d --name web -p 80:80 nginx
docker run -d --name api --link db -p 8080:8080 myapi
docker run -d --name db -v data:/var/lib/mysql mysql
```

With Kubernetes, you define these as part of a deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

### When to Use Kubernetes

Kubernetes adds complexity but provides significant benefits for specific use cases. Understanding when to adopt Kubernetes is critical for successful container strategy.

**Key Points:**

- Kubernetes is most beneficial for larger, more complex applications
- Smaller applications may be better served by simpler solutions
- Consider your team's operational expertise and learning curve
- Evaluate the tradeoff between setup complexity and operational benefits
- On-premise deployments generally require more setup work than managed services

Kubernetes is particularly valuable when you need:

1. **High availability and fault tolerance**
    
    - Automatic recovery from failures
    - Distribution across multiple nodes and zones
2. **Scalability**
    
    - Horizontal scaling of applications
    - Automatic scaling based on metrics
3. **Resource efficiency**
    
    - Better utilization of infrastructure
    - Bin-packing of containers on nodes
4. **Deployment automation**
    
    - Rolling updates with zero downtime
    - Canary deployments
    - Rollbacks
5. **Multi-environment consistency**
    
    - Uniform deployments across development, testing, and production

**Example:** Consider Kubernetes when:

```
- Your application consists of multiple microservices
- You need to handle variable traffic patterns
- You require consistent deployments across environments
- You have multiple teams working on different services
- You need advanced networking policies and security
```

Consider simpler alternatives when:

```
- You have a small team with limited DevOps resources
- Your application is a monolith or has few components
- You're operating at a small scale (few servers)
- The application doesn't require high availability
- Development speed is prioritized over operational robustness
```

### Kubernetes Architecture

Kubernetes follows a distributed architecture with clear separation of concerns between components, enabling its powerful orchestration capabilities.

**Key Points:**

- Architecture divided into control plane and worker nodes
- Control plane manages the cluster state and decisions
- Worker nodes run the application containers
- Declarative configuration through API objects
- Extensible through custom resources and operators
- High availability through component redundancy

Control plane components (master):

- API Server: Communication hub for all cluster components
- etcd: Distributed key-value store for cluster state
- Scheduler: Assigns workloads to nodes
- Controller Manager: Maintains desired state
- Cloud Controller Manager: Interfaces with cloud providers

Worker node components:

- Kubelet: Ensures containers are running in a Pod
- Container Runtime: Runs containers (Docker, containerd, CRI-O)
- Kube-proxy: Maintains network rules for service access

**Example:** A simplified view of how Kubernetes handles a deployment:

1. User submits a Deployment manifest to API Server
2. API Server validates and stores in etcd
3. Controller Manager notices the new Deployment
4. Controller Manager creates ReplicaSet objects
5. Scheduler assigns Pods to suitable nodes
6. Kubelet on each assigned node creates containers
7. Kubelet monitors container health, restarting as needed

### Kubernetes Components

Kubernetes consists of several key components that work together to provide container orchestration functionality. Understanding these components is essential for effective Kubernetes usage.

**Key Points:**

- Components interact through the Kubernetes API
- Most components follow a declarative model
- Multiple layers of abstractions build on each other
- Extensions can add functionality without modifying core components
- Components are designed for resilience and high availability

#### Core Kubernetes Objects

**Pods**:

- Smallest deployable unit in Kubernetes
- Group of one or more containers with shared storage/network
- Containers in a pod are co-located and co-scheduled
- Pods are ephemeral by design

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```

**Services**:

- Stable networking endpoint for pods
- Load balancing across multiple pod instances
- Service discovery through DNS
- Can expose pods internally or externally

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
  type: ClusterIP  # or NodePort, LoadBalancer
```

**Deployments**:

- Manages ReplicaSets and provides declarative updates
- Enables rolling updates and rollbacks
- Maintains deployment history
- Self-healing based on defined state

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
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

**ConfigMaps and Secrets**:

- Store configuration information and sensitive data
- Can be mounted as files or environment variables
- Separate configuration from container images
- Enable config changes without rebuilding containers

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    environment=production
    log.level=info
```

#### Additional Components

**Volumes**:

- Abstractions for persistent storage
- Multiple volume types (cloud, local, network)
- Storage lifecycle managed independently from pods
- Support for various storage backends

**Namespaces**:

- Virtual clusters within a physical cluster
- Resource isolation and organization
- Role-based access control per namespace
- Resource quotas per namespace

**StatefulSets**:

- Manages stateful applications
- Provides persistent identities for pods
- Ordered, graceful deployment and scaling
- Stable network identities and storage

**DaemonSets**:

- Ensures specific pods run on all nodes
- Used for cluster-wide services
- Examples: log collection, monitoring agents
- Automatically handles node additions/removals

**Jobs and CronJobs**:

- Run-to-completion tasks
- Batch processing capabilities
- Scheduled jobs (cron-like)
- Retry logic for failed jobs

**Example:** Combining components for a complete application:

```yaml
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: web-app

---
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: web-app
data:
  nginx.conf: |
    server {
      listen 80;
      location / {
        root /usr/share/nginx/html;
      }
    }

---
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/conf.d/
      volumes:
      - name: config
        configMap:
          name: nginx-config

---
# Service
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: web-app
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

### Kubernetes Control Plane Deep Dive

The control plane is the brain of Kubernetes, managing the cluster state and making global decisions.

**Key Points:**

- Consists of multiple components that work together
- Can be replicated for high availability
- Maintains the desired state of the cluster
- Exposes the Kubernetes API
- Often runs on dedicated nodes in production

**API Server**:

- Entry point for all REST commands
- Validates and processes API requests
- Persists state to etcd
- Only component that communicates with etcd
- Horizontal scaling for high availability

**etcd**:

- Distributed key-value store
- Stores all cluster configuration
- Highly consistent and available
- Uses the Raft consensus algorithm
- Critical for cluster recovery

**Scheduler**:

- Watches for new pods without assigned nodes
- Considers constraints, resources, affinity
- Makes binding decisions for pod placement
- Pluggable scheduling algorithms
- Aware of topology and hardware constraints

**Controller Manager**:

- Runs controller processes
- Node Controller: notices and responds to node failures
- Replication Controller: maintains correct pod counts
- Endpoints Controller: populates endpoint objects
- Service Account & Token Controllers: manage access accounts

**Cloud Controller Manager**:

- Interfaces with cloud provider APIs
- Node controller for cloud instance verification
- Route controller for network routes setup
- Service controller for load balancer provisioning
- Volume controller for storage attachment

### Node Components Deep Dive

Worker nodes are the machines that run your containerized applications and are managed by the control plane.

**Key Points:**

- Each node runs the necessary services to host pods
- Nodes can be physical or virtual machines
- Can span multiple cloud providers or on-premises environments
- Managed by the node controller in the control plane
- Can be added and removed dynamically

**Kubelet**:

- Primary node agent running on each node
- Ensures containers are running in pods
- Takes PodSpecs and ensures containers match specifications
- Reports node and pod status to API server
- Handles pod lifecycle events

**Container Runtime**:

- Software responsible for running containers
- Common options include Docker, containerd, CRI-O
- Implements Container Runtime Interface (CRI)
- Handles image pulling and container execution
- Manages container resources and isolation

**Kube-proxy**:

- Network proxy on each node
- Implements part of the Kubernetes Service concept
- Maintains network rules for pod communication
- Performs connection forwarding or load balancing
- Implements different proxy modes (iptables, IPVS)

### Kubernetes Networking Model

Kubernetes defines a specific networking model that facilitates communication between pods, services, and external clients.

**Key Points:**

- Every Pod gets its own IP address
- Pods can communicate with all other pods without NAT
- Agents on a node can communicate with all pods on that node
- Network plugins implement the Container Network Interface (CNI)
- Service abstraction provides stable endpoints for pods

**Pod Networking**:

- Pods share a network namespace
- Containers within a pod can communicate via localhost
- Each pod has a unique IP address
- Communication between pods uses pod IPs directly

**Service Networking**:

- Services abstract pod IPs behind a stable virtual IP
- ClusterIP: Internal-only virtual IP
- NodePort: Exposes service on each node's IP at a static port
- LoadBalancer: Provisions external load balancer with static IP
- ExternalName: Maps service to DNS name

**Network Policies**:

- Specify how pods communicate with network endpoints
- Apply policy to selected pods using labels
- Control ingress and egress traffic
- Implemented by network plugins
- Default is allow-all if not specified

**Example:** Network policy restricting pod access:

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

### Related Topics

- Kubernetes installation and setup methods
- kubectl command-line tool
- Kubernetes Dashboard and UIs
- Cluster autoscaling
- Helm package manager
- Custom Resource Definitions (CRDs)
- Admission controllers
- Service meshes with Kubernetes
- Kubernetes operators
- GitOps and continuous deployment

---

