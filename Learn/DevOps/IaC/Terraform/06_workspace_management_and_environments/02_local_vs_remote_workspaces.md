## Local vs. Remote Workspaces


**Local Workspaces** store state files in subdirectories of your working directory:

- State files are stored in `terraform.tfstate.d/<workspace-name>/`
- Limited to single-user scenarios
- No built-in collaboration features
- Workspace switching is immediate and local

**Remote Workspaces** are managed by remote backends like Terraform Cloud:

- Each workspace has its own remote state storage
- Support for team collaboration and access controls
- Integrated CI/CD capabilities
- Variable management and run history
- Workspace-level permissions and policies

[Inference] Remote workspaces provide better collaboration and governance features, making them more suitable for team environments and production use cases.

