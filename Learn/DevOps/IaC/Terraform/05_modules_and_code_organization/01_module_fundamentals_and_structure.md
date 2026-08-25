## Module Fundamentals and Structure


Terraform modules are containers for multiple resources that work together to provide a specific functionality. Every Terraform configuration is technically a module, with the root module being your main working directory.

A well-structured module typically follows this directory layout:

```
module-name/
├── main.tf          # Primary resource definitions
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output value declarations
├── versions.tf      # Provider and Terraform version constraints
├── README.md        # Module documentation
└── examples/        # Usage examples
    └── basic/
        ├── main.tf
        └── variables.tf
```

The core principle is separation of concerns: each module should have a single, well-defined purpose and encapsulate related resources that are commonly deployed together.

