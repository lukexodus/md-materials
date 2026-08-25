## Azure Kubernetes Service (AKS)


AKS provides managed Kubernetes orchestration for containerized applications, handling cluster management tasks while users focus on application deployment and scaling.

**Key Points:**

- Managed Kubernetes control plane with automatic updates
- Integration with Azure Container Registry for image storage
- Role-based access control (RBAC) with Azure Active Directory
- Network policies and Azure CNI for advanced networking
- Azure Monitor integration for cluster and application monitoring
- Support for Windows and Linux node pools

**Cluster Components:**

- **Control Plane**: Managed by Microsoft, includes API server, etcd, scheduler
- **Node Pools**: Virtual machine scale sets running kubelet and container runtime
- **System Node Pool**: Runs system pods and cluster infrastructure
- **User Node Pools**: Runs application workloads with customizable configurations

**Networking Options:**

- **kubenet**: Basic networking with NAT for outbound connectivity
- **Azure CNI**: Advanced networking with direct pod IP addresses
- **Azure CNI Overlay**: Efficient IP address usage for large clusters
- **Bring Your Own CNI**: Custom network plugins for specific requirements

**Security Features:**

- Pod security standards and admission controllers
- Azure Key Vault integration for secrets management
- Network security groups and application gateway integration
- Private clusters with private API server endpoints

