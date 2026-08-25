## HCL Syntax Deep Dive


HashiCorp Configuration Language (HCL) is Terraform's configuration syntax:

**Basic Structure**:

```hcl
block_type "block_label" "block_name" {
  argument_name = argument_value
  
  nested_block {
    nested_argument = "value"
  }
}
```

**Data Types**:

- **String**: `"hello world"`
- **Number**: `42` or `3.14`
- **Boolean**: `true` or `false`
- **List**: `["item1", "item2", "item3"]`
- **Map**: `{key1 = "value1", key2 = "value2"}`
- **Object**: Complex nested structures with typed attributes

**Expressions**:

- **References**: `var.example`, `resource.aws_instance.web.id`
- **Interpolation**: `"Hello ${var.name}"`
- **Functions**: `length(var.list)`, `join(",", var.items)`
- **Conditionals**: `var.environment == "prod" ? "large" : "small"`

