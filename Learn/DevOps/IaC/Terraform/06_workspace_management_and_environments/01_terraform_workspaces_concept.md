## Terraform Workspaces Concept


Terraform workspaces are named containers that allow you to manage multiple instances of the same infrastructure configuration. Each workspace maintains its own separate state file, enabling you to deploy the same Terraform configuration to different environments (development, staging, production) or for different purposes.

The concept addresses the need to maintain separate infrastructure instances while sharing the same configuration code. Workspaces operate on the principle of state isolation - each workspace has its own state file, but they all use the same Terraform configuration files.

Key characteristics of workspaces:

- Each workspace maintains independent state
- The same configuration can produce different infrastructure
- Workspace names can be referenced in configurations using `terraform.workspace`
- The "default" workspace is created automatically and cannot be deleted

