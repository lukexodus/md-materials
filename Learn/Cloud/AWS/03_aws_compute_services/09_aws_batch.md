## AWS Batch


Batch enables efficient execution of batch computing workloads by dynamically provisioning compute resources based on job requirements.

**Job Queues and Definitions** Job queues hold submitted jobs until compute resources become available. Job definitions specify how jobs run, including Docker images, vCPU and memory requirements, and IAM roles. Multi-node parallel jobs distribute work across multiple instances for high-performance computing workloads.

**Compute Environments** Managed compute environments automatically scale EC2 instances based on job queue demand. Unmanaged compute environments use existing compute resources under user control. Compute environments support On-Demand, Spot, and mixed instance types to optimize costs.

**Key Points**

- EC2 provides flexible virtual servers with multiple instance families optimized for different workloads
- Multiple pricing models (On-Demand, Reserved, Spot) optimize costs based on usage patterns
- Auto Scaling automatically adjusts capacity based on demand and defined policies
- Load balancers distribute traffic across multiple targets with different Layer 4/7 capabilities
- Lambda executes code serverlessly in response to events without server management
- ECS orchestrates containers on EC2 or Fargate infrastructure
- EKS provides managed Kubernetes control plane with flexible worker node options
- Fargate runs containers serverlessly without infrastructure management
- Batch efficiently processes batch workloads with automatic resource provisioning

---

