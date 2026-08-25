## Terraform vs. CloudFormation vs. Ansible vs. Pulumi


**Terraform:**
- Cloud-agnostic tool by HashiCorp
- Uses HashiCorp Configuration Language (HCL)
- Declarative approach with state management
- Extensive provider ecosystem (AWS, Azure, GCP, etc.)
- Strong community and third-party modules
- Plan-and-apply workflow for safe changes

**AWS CloudFormation:**
- AWS-native service for AWS resources only
- Uses JSON or YAML templates
- Integrated with AWS services and IAM
- No additional tooling required for AWS environments
- Stack-based resource management
- Built-in rollback capabilities

**Ansible:**
- Configuration management tool that can handle infrastructure
- Uses YAML playbooks
- Agentless architecture
- Procedural approach (describes steps to take)
- Strong for configuration management and application deployment
- Can integrate with other IaC tools

**Pulumi:**
- Uses familiar programming languages (Python, TypeScript, Go, C#)
- Cloud-agnostic with multiple providers
- Object-oriented approach to infrastructure
- Combines benefits of general-purpose languages with infrastructure management
- Built-in testing capabilities using standard language tools

