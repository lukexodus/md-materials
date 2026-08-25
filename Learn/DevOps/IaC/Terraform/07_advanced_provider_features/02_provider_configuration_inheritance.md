## Provider Configuration Inheritance


Provider configurations can be inherited and customized across different levels of your Terraform configuration:

**Root Module Provider Configuration**: The root module defines default provider configurations that child modules inherit unless explicitly overridden.

**Module Provider Requirements**:

```hcl
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.alternate]
    }
  }
}
```

**Provider Configuration Block Inheritance**: Child modules inherit provider configurations from their parent, but can specify required provider aliases for specific configurations.

[Inference] Provider inheritance follows Terraform's scoping rules, where child modules receive provider instances from their calling context unless explicitly configured otherwise.

