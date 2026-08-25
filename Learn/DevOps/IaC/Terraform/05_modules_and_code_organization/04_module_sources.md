## Module Sources


Terraform supports multiple module sources:

**Local Paths**: Modules in the same repository

```hcl
module "example" {
  source = "./modules/example"
}
```

**Git Repositories**: Modules stored in version control

```hcl
module "example" {
  source = "git::https://github.com/company/terraform-modules.git//modules/example?ref=v1.0.0"
}
```

**Terraform Registry**: Public and private module registries

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
}
```

**HTTP URLs**: Modules distributed via HTTP

```hcl
module "example" {
  source = "https://example.com/modules/example.zip"
}
```

