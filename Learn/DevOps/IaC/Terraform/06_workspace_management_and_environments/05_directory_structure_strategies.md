## Directory Structure Strategies


**Monolithic Structure** (single directory with workspaces):

```
project/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.dev
├── terraform.tfvars.staging
└── terraform.tfvars.prod
```

**Environment-per-Directory Structure**:

```
project/
├── modules/
│   ├── vpc/
│   ├── ec2/
│   └── rds/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── shared/
    └── common.tf
```

**Layered Structure** (infrastructure layers):

```
project/
├── global/
│   ├── iam/
│   └── route53/
├── environments/
│   └── prod/
│       ├── networking/
│       ├── compute/
│       └── data/
└── modules/
```

[Inference] The choice of directory structure depends on factors like team size, complexity of infrastructure, deployment patterns, and organizational preferences.

