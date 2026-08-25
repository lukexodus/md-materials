## Module Composition and Nesting


Modules can call other modules, creating hierarchical compositions. This enables building complex infrastructure from smaller, reusable components:

```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}

module "web_servers" {
  source    = "./modules/ec2-cluster"
  vpc_id    = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
}
```

Best practices for composition include:

- Keep nesting levels reasonable (typically 2-3 levels maximum)
- Pass data between modules through outputs and variables
- Avoid tight coupling between modules
- Design modules to be independently testable

