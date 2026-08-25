## Environment Separation Patterns


Several patterns exist for organizing environments with Terraform:

**Workspace-Based Separation**:

```hcl
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
  tags = {
    Environment = terraform.workspace
  }
}
```

**Directory-Based Separation**:

```
environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
```

**Branch-Based Separation**: Different Git branches for each environment

- Each environment exists on its own branch
- Promotes through merging branches
- Can be combined with directory or workspace patterns

**Repository-Based Separation**: Separate repositories for each environment

- Complete isolation between environments
- Independent access controls and workflows
- Higher maintenance overhead

