## HashiCorp Configuration Language (HCL) Introduction


HCL is a structured configuration language designed to be both human and machine-readable. It strikes a balance between JSON's machine-readability and YAML's human-friendliness.

**Key HCL Syntax Elements:**

```hcl
# Comments start with hash
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1d0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "ExampleInstance"
  }
}

# Variables
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

# Outputs
output "instance_ip" {
  value = aws_instance.example.public_ip
}
```

**HCL Features:**
- Block-based structure with resource types and names
- Attribute assignment using equals sign
- Support for strings, numbers, booleans, lists, and maps
- Interpolation syntax for dynamic values
- Comments using # or /* */
- Functions for data manipulation and validation

