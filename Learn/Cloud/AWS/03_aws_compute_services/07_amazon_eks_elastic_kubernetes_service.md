## Amazon EKS (Elastic Kubernetes Service)


EKS provides managed Kubernetes control plane, handling master node provisioning, scaling, and maintenance while users manage worker nodes and applications.

**Control Plane Management** EKS runs Kubernetes control plane across multiple Availability Zones for high availability. AWS manages etcd backups, security patches, and version upgrades. Control plane API endpoints support both public and private access configurations.

**Node Groups** Managed node groups automatically provision and manage EC2 instances running Kubernetes worker nodes. They support Auto Scaling, rolling updates, and multiple instance types. Self-managed node groups provide more control over worker node configuration but require manual management.

**Networking and Security** EKS uses Amazon VPC CNI for pod networking, assigning VPC IP addresses directly to pods. AWS Load Balancer Controller integrates with ALB and NLB for ingress traffic management. IAM roles provide authentication and authorization for pods through service accounts.

