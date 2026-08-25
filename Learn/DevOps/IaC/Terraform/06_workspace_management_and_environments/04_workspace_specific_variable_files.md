## Workspace-Specific Variable Files


Variable files can be organized to support different workspace configurations:

**Workspace-Specific tfvars Files**:

```
├── terraform.tfvars.dev
├── terraform.tfvars.staging
├── terraform.tfvars.prod
└── main.tf
```

**Conditional Variable Loading**:

```hcl
locals {
  env_vars = terraform.workspace == "prod" ? var.prod_config : var.dev_config
}
```

**Workspace Variable Interpolation**:

```hcl
variable "instance_counts" {
  type = map(number)
  default = {
    dev     = 1
    staging = 2
    prod    = 5
  }
}

resource "aws_instance" "web" {
  count = var.instance_counts[terraform.workspace]
}
```

