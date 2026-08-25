## Provisioners


### When to Use Provisioners

Provisioners should be used as a last resort when native Terraform resources or cloud-init/user-data aren't sufficient. Common use cases include:

- Running commands after resource creation
- Copying files to remote systems
- Bootstrapping configuration management tools
- Integration with external systems

### File Provisioner

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.web.id]
  
  # File provisioner to copy configuration files
  provisioner "file" {
    source      = "${path.module}/config/"
    destination = "/tmp/config"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  # Copy a single file with different permissions
  provisioner "file" {
    content = templatefile("${path.module}/app.conf.tpl", {
      database_url = aws_db_instance.main.endpoint
      redis_url    = aws_elasticache_cluster.main.cache_nodes[0].address
      app_secret   = var.app_secret
    })
    destination = "/tmp/app.conf"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  tags = {
    Name = "web-server"
  }
}
```

### Remote-Exec Provisioner

```hcl
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  # Remote-exec provisioner for initial setup
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx docker.io",
      "sudo systemctl enable nginx",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
      timeout     = "5m"
    }
  }
  
  # Configure application after copying files
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/app.conf /etc/myapp/app.conf",
      "sudo chown root:root /etc/myapp/app.conf",
      "sudo chmod 640 /etc/myapp/app.conf",
      "sudo systemctl restart myapp"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  tags = {
    Name = "app-server"
  }
}
```

### Local-Exec Provisioner

```hcl
resource "aws_instance" "database" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  
  vpc_security_group_ids = [aws_security_group.database.id]
  
  # Local-exec to update local inventory file
  provisioner "local-exec" {
    command = "echo '${self.private_ip} database-server' >> /etc/ansible/hosts"
  }
  
  # Local-exec to trigger external configuration management
  provisioner "local-exec" {
    command = "ansible-playbook -i /etc/ansible/hosts database-setup.yml --limit ${self.private_ip}"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      DB_PASSWORD = var.db_password
    }
  }
  
  # Local-exec for cleanup on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "sed -i '/${self.private_ip}/d' /etc/ansible/hosts"
  }
  
  tags = {
    Name = "database-server"
  }
}
```

### Advanced Provisioner Patterns

```hcl
# Null resource for provisioner-only operations
resource "null_resource" "cluster_setup" {
  # Triggers ensure this runs when cluster configuration changes
  triggers = {
    cluster_instance_ids = join(",", aws_instance.cluster[*].id)
    cluster_config_hash  = md5(jsonencode(var.cluster_config))
  }
  
  # Setup cluster configuration
  provisioner "local-exec" {
    command = templatefile("${path.module}/setup-cluster.sh.tpl", {
      master_ip = aws_instance.cluster[0].private_ip
      worker_ips = slice(aws_instance.cluster[*].private_ip, 1, length(aws_instance.cluster))
      cluster_token = var.cluster_token
    })
    
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig"
    }
  }
  
  # Cleanup on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl drain --all --ignore-daemonsets --force || true"
    
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig"
    }
  }
  
  depends_on = [aws_instance.cluster]
}

# Multiple instances with coordinated provisioning
resource "aws_instance" "cluster" {
  count = var.cluster_size
  
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index % length(var.subnet_ids)]
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.cluster.id]
  
  # Install base software on all nodes
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io kubeadm kubelet kubectl",
      "sudo systemctl enable docker kubelet"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  # Master node specific setup
  provisioner "remote-exec" {
    count = count.index == 0 ? 1 : 0
    
    inline = [
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  tags = {
    Name = "cluster-node-${count.index + 1}"
    Role = count.index == 0 ? "master" : "worker"
  }
}
```

### Provisioner Error Handling and Best Practices

```hcl
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  # Provisioner with error handling
  provisioner "remote-exec" {
    inline = [
      "set -e",  # Exit on any error
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "# Verify nginx is running",
      "sudo systemctl is-active nginx"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
      timeout     = "10m"
      
      # Connection retry logic
      agent       = false
      host_key    = ""
    }
    
    # Continue on failure for non-critical setup
    on_failure = continue
  }
  
  # Critical provisioner that must succeed
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/myapp",
      "sudo chown ubuntu:ubuntu /opt/myapp"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
    
    # Fail the entire resource if this fails
    on_failure = fail
  }
  
  tags = {
    Name = "app-server"
  }
}

# Alternative: Using cloud-init instead of provisioners
resource "aws_instance" "app_cloudinit" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  # cloud-init is more reliable than provisioners
  user_data = base64encode(templatefile("${path.module}/cloud-init.yml", {
    app_config = var.app_config
    database_url = aws_db_instance.main.endpoint
  }))
  
  tags = {
    Name = "app-server-cloudinit"
  }
}
```

### Provisioner Alternatives and Best Practices

```yaml
# cloud-init.yml - Better alternative to provisioners
#cloud-config
package_update: true
package_upgrade: true

packages:
  - nginx
  - docker.io
  - awscli

runcmd:
  - systemctl enable nginx docker
  - systemctl start nginx docker
  - usermod -aG docker ubuntu
  - |
    cat > /etc/nginx/sites-available/default <<EOF
    server {
        listen 80;
        location / {
            proxy_pass http://localhost:3000;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
    EOF
  - systemctl reload nginx

write_files:
  - path: /opt/app/config.json
    content: |
      ${jsonencode(app_config)}
    permissions: '0644'
  - path: /opt/app/database.conf
    content: |
      DATABASE_URL=${database_url}
    permissions: '0600'
    owner: ubuntu:ubuntu

final_message: "System setup completed successfully"
```

**Summary**

This guide covers the essential advanced Terraform configuration patterns:

**Local Values and Computed Values** help you avoid repetition and create dynamic configurations based on complex logic.

**Conditional Expressions** enable environment-specific and feature-flag-driven infrastructure provisioning.

**For Expressions and Loops** provide powerful ways to transform and manipulate data structures, enabling dynamic resource creation.

**Dynamic Blocks** allow you to create flexible resource configurations that adapt to input variables and conditions.

**Built-in Functions** offer extensive capabilities for string manipulation, numeric operations, collection processing, and date/time handling.

**Resource Dependencies** ensure proper creation order through both implicit references and explicit dependency declarations.

**Resource Lifecycle Rules** provide fine-grained control over resource creation, updates, and destruction patterns.

**Provisioners** should be used judiciously as a last resort, with cloud-init and native resources preferred when possible.

These patterns enable you to create more maintainable, flexible, and robust Terraform configurations that can adapt to changing requirements while following infrastructure-as-code best practices.

---

