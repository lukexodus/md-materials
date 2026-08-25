## Kubernetes Architecture Deep Dive


### Master Node Components

#### API Server

The Kubernetes API Server serves as the central management entity and the primary interface for all administrative tasks. It exposes the Kubernetes API through RESTful endpoints and handles all API requests, whether they come from users, management devices, or command-line interfaces like kubectl.

The API Server performs several critical functions: it validates and configures data for API objects including pods, services, and replication controllers. It also serves as the gateway for all REST commands used to control the cluster. Every operation that modifies the cluster state must go through the API Server, making it the single source of truth for cluster configuration.

Authentication and authorization are handled at this level, with the API Server supporting multiple authentication mechanisms including client certificates, bearer tokens, and authenticating proxies. It also implements role-based access control (RBAC) to ensure proper authorization for different users and service accounts.

**Key points:**

- Acts as the front-end for the Kubernetes control plane
- Handles all REST operations and serves as the API gateway
- Implements authentication, authorization, and admission control
- Validates and persists API objects to etcd
- Provides the interface for kubectl and other management tools

#### etcd

etcd is a distributed key-value store that serves as Kubernetes' backing store for all cluster data. It stores the configuration data, state data, and metadata for the entire cluster. This includes information about pods, services, secrets, accounts, and more.

As a distributed system, etcd ensures high availability and consistency across the cluster. It uses the Raft consensus algorithm to maintain consistency among multiple etcd instances. When you have multiple master nodes, etcd typically runs on each master node, forming a cluster that can tolerate failures of minority nodes.

The API Server is the only component that directly communicates with etcd, acting as a proxy for all other components. This design ensures data consistency and provides a single point of access control for the cluster's persistent state.

**Key points:**

- Distributed key-value store for all cluster data
- Uses Raft consensus algorithm for consistency
- Stores configuration, state, and metadata
- Only accessible directly by the API Server
- Critical for cluster recovery and backup procedures

#### Controller Manager

The Controller Manager runs controller processes that regulate the state of the cluster. It's actually a collection of several controllers bundled into a single binary for simplicity. Each controller watches the shared state of the cluster through the API Server and makes changes attempting to move the current state towards the desired state.

Key controllers include the Replication Controller, which ensures the specified number of pod replicas are running; the Endpoints Controller, which manages endpoint objects; the Service Account and Token Controllers, which create default accounts and API access tokens for new namespaces; and the Node Controller, which monitors node health and updates node status.

The Controller Manager implements the control loop pattern, continuously monitoring the cluster state and making corrections when the actual state deviates from the desired state. This self-healing capability is fundamental to Kubernetes' reliability.

**Key points:**

- Runs multiple controller processes in a single binary
- Implements control loops to maintain desired state
- Includes replication, endpoints, service account, and node controllers
- Provides self-healing capabilities for the cluster
- Watches cluster state through the API Server

#### Scheduler

The Kubernetes Scheduler is responsible for assigning pods to nodes based on resource requirements, policies, and constraints. It watches for newly created pods with no assigned node and selects the most suitable node for each pod.

The scheduling process involves two main phases: filtering and scoring. During filtering, the scheduler eliminates nodes that don't meet the pod's requirements, such as resource constraints, node selectors, or affinity rules. In the scoring phase, it ranks the remaining nodes and selects the best fit based on various factors like resource utilization, data locality, and load balancing.

The scheduler considers multiple factors including CPU and memory requirements, storage needs, network policies, pod and node affinity/anti-affinity rules, taints and tolerations, and custom scheduling policies. It aims to optimize cluster resource utilization while respecting constraints and maintaining high availability.

**Key points:**

- Assigns pods to appropriate nodes based on requirements and constraints
- Uses filtering and scoring phases for optimal placement
- Considers resource requirements, affinity rules, and policies
- Optimizes cluster resource utilization
- Supports custom scheduling policies and multiple schedulers

### Worker Node Components

#### kubelet

The kubelet is the primary node agent that runs on every worker node. It ensures that containers are running in pods as specified by the pod specifications received from the API Server. The kubelet takes a set of PodSpecs and ensures that the containers described in those specs are running and healthy.

The kubelet communicates with the container runtime to manage container lifecycle operations including pulling images, starting containers, monitoring container health, and reporting container and pod status back to the API Server. It also manages mounted volumes and handles pod-level operations like setting up networking and storage.

Health monitoring is a critical function of the kubelet, which performs both liveness and readiness probes as defined in pod specifications. It can restart containers that fail health checks and reports pod status to the control plane, enabling proper cluster management and troubleshooting.

**Key points:**

- Primary node agent running on every worker node
- Manages container lifecycle through container runtime interface
- Handles pod networking and storage setup
- Performs health monitoring with liveness and readiness probes
- Reports node and pod status to the control plane

#### kube-proxy

kube-proxy is a network proxy that runs on each worker node and maintains network rules for service discovery and load balancing. It implements the Kubernetes service concept by maintaining network rules that allow network communication to pods from network sessions inside or outside the cluster.

The primary responsibility of kube-proxy is to route traffic to the appropriate backend pods based on service definitions. It supports multiple proxy modes including iptables mode, which uses iptables rules for load balancing, and IPVS mode, which provides better performance for large clusters with many services.

kube-proxy also handles service discovery by maintaining a mapping of service names to pod IP addresses. When a service is created or updated, kube-proxy updates the local networking rules to ensure traffic is properly routed to the correct pods.

**Key points:**

- Network proxy running on each worker node
- Implements service discovery and load balancing
- Supports multiple proxy modes (iptables, IPVS)
- Maintains network rules for service-to-pod communication
- Handles both internal and external traffic routing

#### Container Runtime

The container runtime is the software responsible for running containers on each worker node. Kubernetes supports multiple container runtimes through the Container Runtime Interface (CRI), including Docker, containerd, and CRI-O.

The container runtime handles low-level container operations including pulling container images from registries, creating and starting containers, managing container storage and networking, and monitoring container processes. It works closely with the kubelet to ensure containers are running according to pod specifications.

Modern Kubernetes deployments typically use containerd or CRI-O as the container runtime, as Docker has been deprecated as a container runtime (though Docker-built images continue to work). The container runtime must implement the CRI specification to integrate properly with Kubernetes.

**Key points:**

- Software responsible for running containers on nodes
- Integrates with Kubernetes through Container Runtime Interface (CRI)
- Handles image pulling, container creation, and process management
- Supports multiple runtimes including containerd and CRI-O
- Works closely with kubelet for container lifecycle management

### Pod Networking and Service Discovery

#### Pod Networking Model

Kubernetes implements a flat networking model where every pod gets its own IP address and can communicate with any other pod in the cluster without NAT. This model simplifies networking and makes it easier to migrate applications from traditional environments to Kubernetes.

The pod networking model is implemented through Container Network Interface (CNI) plugins. Popular CNI plugins include Flannel, Calico, Weave, and Cilium, each offering different features and capabilities. These plugins handle IP address management, routing, and network policy enforcement.

Within a pod, containers share the same network namespace, meaning they can communicate with each other using localhost and share the same IP address. This design allows for sidecar patterns and simplifies inter-container communication within pods.

**Key points:**

- Every pod receives a unique IP address
- Flat networking model without NAT between pods
- Implemented through CNI plugins
- Containers within a pod share network namespace
- Supports various networking solutions and policies

#### Service Discovery Mechanisms

Kubernetes provides multiple mechanisms for service discovery, allowing applications to find and communicate with other services in the cluster. The primary method is through Kubernetes Services, which provide stable endpoints for accessing groups of pods.

DNS-based service discovery is built into Kubernetes through the cluster DNS service (typically CoreDNS). Services are automatically registered in DNS, allowing applications to discover services by name. The DNS service creates records for both services and pods, enabling flexible service discovery patterns.

Environment variables provide another service discovery mechanism, where Kubernetes automatically injects service information into pod containers. This includes service IP addresses and ports, making it easy for applications to discover services without DNS lookups.

**Key points:**

- Multiple service discovery mechanisms available
- DNS-based discovery through cluster DNS service
- Environment variable injection for service information
- Services provide stable endpoints for pod groups
- Automatic service registration and resolution

#### Network Policies

Network policies in Kubernetes provide a way to control traffic flow between pods and services. They act as a firewall at the pod level, allowing administrators to define rules about which pods can communicate with each other and with external services.

Network policies are implemented by CNI plugins that support policy enforcement. Not all CNI plugins support network policies, so choosing the right networking solution is important for environments requiring traffic segmentation.

Policies can be defined based on pod selectors, namespace selectors, and IP blocks. They support both ingress and egress rules, providing fine-grained control over network traffic. This capability is essential for implementing security best practices and compliance requirements.

**Key points:**

- Provide pod-level traffic control and segmentation
- Implemented by CNI plugins with policy support
- Support ingress and egress rule definitions
- Based on pod selectors, namespaces, and IP blocks
- Essential for security and compliance requirements

### Kubernetes API and Resource Model

#### REST API Architecture

The Kubernetes API follows REST principles and is organized around resources and operations. Resources represent the state of the cluster, including pods, services, deployments, and configmaps. The API supports standard HTTP methods (GET, POST, PUT, DELETE) for managing these resources.

The API is versioned to ensure backward compatibility as features evolve. API versions include alpha (experimental), beta (pre-release), and stable (production-ready). This versioning scheme allows for safe feature development while maintaining cluster stability.

Resource paths follow a consistent pattern: `/api/v1/namespaces/{namespace}/{resource-type}/{resource-name}`. This structure makes the API predictable and easy to use programmatically. The API also supports bulk operations and filtering for efficient resource management.

**Key points:**

- RESTful API architecture with standard HTTP methods
- Versioned API with alpha, beta, and stable versions
- Consistent resource path structure
- Supports bulk operations and filtering
- Designed for both human and programmatic access

#### Resource Types and Hierarchy

Kubernetes resources are organized into a hierarchy with different scopes and relationships. Cluster-scoped resources like nodes and persistent volumes exist at the cluster level, while namespaced resources like pods and services exist within specific namespaces.

Core resources include pods (the smallest deployable units), services (stable network endpoints), and deployments (declarative pod management). Higher-level resources like StatefulSets and DaemonSets provide specialized pod management for specific use cases.

Custom Resource Definitions (CRDs) allow users to extend the Kubernetes API with their own resource types. This extensibility enables the development of operators and custom controllers that manage complex applications and infrastructure.

**Key points:**

- Hierarchical resource organization with cluster and namespace scopes
- Core resources provide fundamental cluster functionality
- Higher-level resources offer specialized management patterns
- Custom Resource Definitions enable API extension
- Resources have defined relationships and dependencies

#### API Groups and Versions

The Kubernetes API is organized into groups to manage complexity and enable independent evolution of different feature sets. The core API group contains fundamental resources like pods and services, while specialized features are organized into their own groups.

API groups have their own versioning scheme, allowing different parts of the API to evolve independently. This design enables new features to be developed and tested without affecting stable core functionality.

**Example** of API groups:

- Core group (v1): pods, services, nodes, namespaces
- Apps group (v1): deployments, replicasets, daemonsets
- Batch group (v1): jobs, cronjobs
- Extensions group: ingresses, network policies

**Key points:**

- API organized into groups for better management
- Independent versioning for different feature sets
- Core group contains fundamental resources
- Specialized groups for specific functionality
- Enables parallel development of different features

**Next steps** for deeper understanding include exploring specific CNI implementations, diving into custom resource development, studying operator patterns, and examining cluster security models. Advanced topics like multi-cluster networking, service mesh integration, and cluster autoscaling build upon these foundational concepts.

---

