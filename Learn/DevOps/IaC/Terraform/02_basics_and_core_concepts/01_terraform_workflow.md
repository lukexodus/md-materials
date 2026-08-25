## Terraform Workflow


The standard Terraform workflow follows four primary commands:

**terraform init**: Initializes a working directory containing Terraform configuration files. Downloads and installs provider plugins, initializes backend configuration, and prepares the directory for other commands.

**terraform plan**: Creates an execution plan showing what actions Terraform will take to reach the desired state defined in configuration files. This is a preview that doesn't make any changes to actual infrastructure.

**terraform apply**: Executes the actions proposed in a plan to create, update, or destroy infrastructure. Requires confirmation unless the `-auto-approve` flag is used.

**terraform destroy**: Destroys all remote objects managed by the Terraform configuration. Essentially the reverse of `terraform apply`.

