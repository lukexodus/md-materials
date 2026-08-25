## Resources and Resource Arguments


Resources represent infrastructure objects in your configuration:

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1d0"
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.public.id
  
  user_data = file("${path.module}/user_data.sh")
  
  tags = {
    Name = "WebServer"
  }
}
```

Resource arguments define the desired configuration. Each resource type has specific required and optional arguments documented by the provider.

