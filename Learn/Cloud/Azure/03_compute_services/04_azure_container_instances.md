## Azure Container Instances


Azure Container Instances (ACI) provides serverless container hosting for simple applications and task execution without cluster management overhead.

**Key Points:**

- Serverless container execution with per-second billing
- Fast startup times typically under 60 seconds
- Support for both Linux and Windows containers
- Integration with virtual networks for private connectivity
- Persistent volume mounting with Azure Files
- Multi-container groups for sidecar patterns

**Use Cases:**

- CI/CD build agents and automation tasks
- Batch processing and data transformation jobs
- Development and testing environments
- Event-driven applications triggered by Logic Apps or Functions
- Temporary workloads and proof-of-concept deployments

**Resource Allocation:**

- CPU allocation from 0.1 to 4 vCPUs per container
- Memory allocation from 0.1 to 16 GB per container
- GPU support for AI and machine learning workloads
- Custom resource configurations for specific requirements

