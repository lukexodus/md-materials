## Configuration Management Integration


### Ansible Integration

```hcl
# ansible-integration.tf
resource "aws_instance" "web_servers" {
  count                  = var.instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id             = aws_subnet.private[count.index % length(aws_subnet.private)].id
  
  user_data = templatefile("${path.module}/templates/user_data.sh", {
    ansible_pull_url = var.ansible_repo_url
    environment     = var.environment
  })
  
  tags = {
    Name        = "${var.environment}-web-${count.index + 1}"
    Environment = var.environment
    AnsibleGroup = "webservers"
  }
}

# Generate Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    web_servers = aws_instance.web_servers[*].private_ip
    db_servers  = aws_instance.db_servers[*].private_ip
    environment = var.environment
  })
  filename = "${path.module}/ansible/inventory/${var.environment}"
  
  depends_on = [aws_instance.web_servers, aws_instance.db_servers]
}

# Execute Ansible playbook
resource "null_resource" "ansible_provisioning" {
  triggers = {
    instance_ids = join(",", aws_instance.web_servers[*].id)
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/ansible
      ansible-playbook -i inventory/${var.environment} site.yml
    EOT
  }
  
  depends_on = [local_file.ansible_inventory]
}
```

### Chef Integration

```hcl
# chef-integration.tf
resource "aws_instance" "chef_nodes" {
  count         = var.node_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name
  
  user_data = templatefile("${path.module}/templates/chef_bootstrap.sh", {
    chef_server_url = var.chef_server_url
    validator_key   = var.chef_validator_key
    node_name      = "${var.environment}-node-${count.index + 1}"
    run_list       = var.chef_run_list
  })
  
  tags = {
    Name = "${var.environment}-chef-node-${count.index + 1}"
    ChefEnvironment = var.environment
  }
}

# Chef environment configuration
resource "chef_environment" "main" {
  name = var.environment
  
  default_attributes_json = jsonencode({
    application = {
      database_url = aws_db_instance.main.endpoint
      cache_url    = aws_elasticache_cluster.main.cache_nodes[0].address
    }
  })
}

# Chef role
resource "chef_role" "web_server" {
  name = "${var.environment}-webserver"
  
  run_list = [
    "recipe[nginx]",
    "recipe[application::deploy]"
  ]
  
  default_attributes_json = jsonencode({
    nginx = {
      worker_processes = 2
      keepalive_timeout = 65
    }
  })
}
```

### Puppet Integration

```hcl
# puppet-integration.tf
resource "aws_instance" "puppet_agents" {
  count         = var.agent_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  user_data = templatefile("${path.module}/templates/puppet_bootstrap.sh", {
    puppet_master = aws_instance.puppet_master.private_ip
    environment  = var.environment
    certname     = "${var.environment}-agent-${count.index + 1}"
  })
  
  tags = {
    Name = "${var.environment}-puppet-agent-${count.index + 1}"
    PuppetEnvironment = var.environment
  }
}

# Puppet Master
resource "aws_instance" "puppet_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  
  user_data = templatefile("${path.module}/templates/puppet_master.sh", {
    domain_name = var.domain_name
  })
  
  tags = {
    Name = "${var.environment}-puppet-master"
    Role = "puppet-master"
  }
}

# External data source for Puppet facts
data "external" "puppet_facts" {
  count   = length(aws_instance.puppet_agents)
  program = ["python3", "${path.module}/scripts/get_puppet_facts.py"]
  
  query = {
    host = aws_instance.puppet_agents[count.index].private_ip
  }
}
```

