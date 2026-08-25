## Configuration Management


### Ansible Basics

Ansible provides agentless configuration management through SSH connections, using YAML-based playbooks to define system states. The architecture consists of a control node executing tasks against managed nodes without requiring specialized software installation on target systems.

#### Core Architecture Components

**Inventory management** defines target systems and grouping strategies:

```yaml
# inventory.yml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
      vars:
        http_port: 80
    databases:
      hosts:
        db1.example.com:
        db2.example.com:
      vars:
        mysql_port: 3306
```

**Playbook structure** organizes tasks into logical execution units:

```yaml
---
- name: Web server configuration
  hosts: webservers
  become: yes
  vars:
    package_list:
      - nginx
      - php-fpm
      - mysql-client
  
  tasks:
    - name: Install web packages
      package:
        name: "{{ item }}"
        state: present
      loop: "{{ package_list }}"
      
    - name: Configure nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        backup: yes
      notify: restart nginx
      
  handlers:
    - name: restart nginx
      service:
        name: nginx
        state: restarted
```

#### Module System and Task Execution

Ansible modules provide idempotent operations across different system types. Common modules include:

**System modules:**

- `package`: Cross-platform package management
- `service`: Service state management
- `user`: User account management
- `file`: File and directory operations

**Cloud modules:**

- `ec2`: AWS EC2 instance management
- `azure_rm_virtualmachine`: Azure VM operations
- `gcp_compute_instance`: Google Cloud instance management

**Example** comprehensive system configuration:

```yaml
- name: System hardening playbook
  hosts: all
  become: yes
  
  tasks:
    - name: Update system packages
      package:
        name: "*"
        state: latest
      when: ansible_os_family == "RedHat"
      
    - name: Configure SSH security
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
        backup: yes
      loop:
        - { regexp: '^PermitRootLogin', line: 'PermitRootLogin no' }
        - { regexp: '^PasswordAuthentication', line: 'PasswordAuthentication no' }
      notify: restart sshd
      
    - name: Install security packages
      package:
        name: "{{ security_packages }}"
        state: present
      vars:
        security_packages:
          - fail2ban
          - aide
          - rkhunter
```

#### Variable Management and Precedence

Ansible variable precedence follows a specific hierarchy [Unverified - exact precedence order may vary between versions]:

1. Extra vars (command line `-e`)
2. Task vars
3. Block vars
4. Role and include vars
5. Play vars
6. Host facts
7. Inventory vars
8. Group vars
9. Role defaults

**Variable organization strategies:**

```yaml
# group_vars/webservers.yml
nginx_worker_processes: "{{ ansible_processor_vcpus }}"
nginx_worker_connections: 1024
ssl_certificate_path: /etc/ssl/certs/server.crt

# host_vars/web1.example.com.yml
nginx_worker_processes: 4
custom_modules:
  - mod_rewrite
  - mod_ssl
```

#### Role Development and Structure

Ansible roles provide reusable configuration components with standardized directory structures:

```
roles/
└── webserver/
    ├── tasks/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── templates/
    │   └── nginx.conf.j2
    ├── files/
    │   └── index.html
    ├── vars/
    │   └── main.yml
    ├── defaults/
    │   └── main.yml
    └── meta/
        └── main.yml
```

**Role implementation example:**

```yaml
# roles/webserver/tasks/main.yml
---
- name: Install nginx
  package:
    name: nginx
    state: present
    
- name: Configure nginx virtual hosts
  template:
    src: vhost.conf.j2
    dest: "/etc/nginx/sites-available/{{ item.name }}"
  loop: "{{ virtual_hosts }}"
  notify: reload nginx
  
- name: Enable virtual hosts
  file:
    src: "/etc/nginx/sites-available/{{ item.name }}"
    dest: "/etc/nginx/sites-enabled/{{ item.name }}"
    state: link
  loop: "{{ virtual_hosts }}"
```

### Puppet Introduction

Puppet implements declarative configuration management using a client-server architecture with agents reporting to a central Puppet server. The system uses a domain-specific language (DSL) to define desired system states.

#### Architecture Components

**Puppet Master/Server** manages configuration catalogs, serves files, and coordinates agent communications. Modern Puppet uses Puppet Server built on JVM for improved performance.

**Puppet Agent** runs on managed nodes, executing catalogs received from the Puppet server and reporting results back.

**PuppetDB** stores configuration data, facts, and reports for query and analysis purposes.

#### Manifest Structure and Resource Types

Puppet manifests define system resources using declarative syntax:

```puppet
# site.pp - main manifest
node 'web1.example.com' {
  include profile::webserver
  include profile::monitoring
}

node /^db\d+\.example\.com$/ {
  include profile::database
}

# Default node configuration
node default {
  include profile::base
}
```

**Resource declarations** specify desired system states:

```puppet
# Basic resource examples
package { 'nginx':
  ensure => installed,
}

service { 'nginx':
  ensure  => running,
  enable  => true,
  require => Package['nginx'],
}

file { '/etc/nginx/nginx.conf':
  ensure  => file,
  content => template('nginx/nginx.conf.erb'),
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  notify  => Service['nginx'],
}

user { 'webuser':
  ensure     => present,
  uid        => '1001',
  gid        => 'webgroup',
  home       => '/home/webuser',
  managehome => true,
  shell      => '/bin/bash',
}
```

#### Classes and Modules Organization

**Classes** group related resources and provide parameterized configuration:

```puppet
# modules/nginx/manifests/init.pp
class nginx (
  String $worker_processes = $nginx::params::worker_processes,
  Integer $worker_connections = $nginx::params::worker_connections,
  Boolean $ssl_enabled = false,
) inherits nginx::params {
  
  package { 'nginx':
    ensure => installed,
  }
  
  file { '/etc/nginx/nginx.conf':
    ensure  => file,
    content => epp('nginx/nginx.conf.epp', {
      'worker_processes'   => $worker_processes,
      'worker_connections' => $worker_connections,
      'ssl_enabled'        => $ssl_enabled,
    }),
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
  
  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => File['/etc/nginx/nginx.conf'],
  }
}
```

**Module structure** follows established conventions:

```
modules/
└── nginx/
    ├── manifests/
    │   ├── init.pp
    │   ├── config.pp
    │   └── params.pp
    ├── templates/
    │   └── nginx.conf.epp
    ├── files/
    │   └── default.conf
    ├── lib/
    │   └── facter/
    └── metadata.json
```

#### Facts and Conditional Logic

Puppet automatically collects system facts for conditional configuration:

```puppet
case $facts['os']['family'] {
  'RedHat': {
    $package_name = 'httpd'
    $service_name = 'httpd'
    $config_path = '/etc/httpd/conf/httpd.conf'
  }
  'Debian': {
    $package_name = 'apache2'
    $service_name = 'apache2'
    $config_path = '/etc/apache2/apache2.conf'
  }
  default: {
    fail("Unsupported OS family: ${facts['os']['family']}")
  }
}

if $facts['memory']['system']['total_bytes'] > 8589934592 {
  $worker_processes = $facts['processors']['count'] * 2
} else {
  $worker_processes = $facts['processors']['count']
}
```

### Configuration Templates

Configuration templates provide dynamic content generation based on variables and system facts, enabling consistent configuration across diverse environments.

#### Jinja2 Templates in Ansible

Ansible uses Jinja2 templating engine for dynamic configuration generation:

```jinja2
{# nginx.conf.j2 #}
user {{ nginx_user }};
worker_processes {{ nginx_worker_processes | default(ansible_processor_vcpus) }};
pid {{ nginx_pid_file }};

events {
    worker_connections {{ nginx_worker_connections | default(1024) }};
    {% if nginx_multi_accept %}
    multi_accept on;
    {% endif %}
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    {% for upstream in upstreams %}
    upstream {{ upstream.name }} {
        {% for server in upstream.servers %}
        server {{ server.address }}:{{ server.port }}{% if server.weight is defined %} weight={{ server.weight }}{% endif %};
        {% endfor %}
    }
    {% endfor %}
    
    {% for vhost in virtual_hosts %}
    server {
        listen {{ vhost.port | default(80) }};
        server_name {{ vhost.server_name }};
        root {{ vhost.document_root }};
        
        {% if vhost.ssl_enabled | default(false) %}
        ssl_certificate {{ ssl_certificate_path }};
        ssl_certificate_key {{ ssl_private_key_path }};
        {% endif %}
        
        location / {
            try_files $uri $uri/ =404;
        }
    }
    {% endfor %}
}
```

**Template usage with variable passing:**

```yaml
- name: Configure nginx with templates
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    backup: yes
  vars:
    upstreams:
      - name: webapp
        servers:
          - { address: "192.168.1.10", port: 8080, weight: 3 }
          - { address: "192.168.1.11", port: 8080, weight: 1 }
    virtual_hosts:
      - server_name: example.com
        document_root: /var/www/html
        port: 80
        ssl_enabled: false
```

#### Embedded Puppet Templates (EPP)

Puppet's native EPP templating provides integration with Puppet variables and functions:

```epp
<%# apache.conf.epp %>
<% | String $server_name,
     Integer $port = 80,
     Array[Hash] $virtual_hosts = [],
     Boolean $ssl_enabled = false
| -%>

ServerName <%= $server_name %>
Listen <%= $port %>

<% if $ssl_enabled { -%>
LoadModule ssl_module modules/mod_ssl.so
SSLEngine on
SSLProtocol all -SSLv2 -SSLv3
<% } -%>

<% $virtual_hosts.each |$vhost| { -%>
<VirtualHost *:<%= $vhost['port'] %>>
    ServerName <%= $vhost['server_name'] %>
    DocumentRoot <%= $vhost['document_root'] %>
    
    <% if $vhost['ssl_enabled'] { -%>
    SSLCertificateFile <%= $vhost['ssl_cert'] %>
    SSLCertificateKeyFile <%= $vhost['ssl_key'] %>
    <% } -%>
    
    <Directory "<%= $vhost['document_root'] %>">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
<% } -%>
```

#### Template Best Practices

**Variable validation** within templates improves reliability:

```jinja2
{# Validate required variables #}
{% if nginx_worker_processes is not defined %}
  {% set nginx_worker_processes = ansible_processor_vcpus %}
{% endif %}

{% if nginx_worker_connections is not defined %}
  {% set nginx_worker_connections = 1024 %}
{% endif %}

{# Input validation #}
{% if nginx_worker_processes | int > 32 %}
  {# Cap worker processes for stability #}
  {% set nginx_worker_processes = 32 %}
{% endif %}
```

**Conditional configuration blocks** handle environment differences:

```jinja2
{% if inventory_hostname in groups['production'] %}
# Production optimizations
worker_rlimit_nofile 65535;
{% elif inventory_hostname in groups['development'] %}
# Development debugging
error_log /var/log/nginx/error.log debug;
{% endif %}
```

### Infrastructure as Code

Infrastructure as Code (IaC) treats infrastructure provisioning and configuration as software development, using version control, testing, and automated deployment practices.

#### Terraform Integration with Configuration Management

Terraform handles infrastructure provisioning while configuration management tools handle post-deployment configuration:

```hcl
# main.tf
resource "aws_instance" "web_servers" {
  count         = var.web_server_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  
  tags = {
    Name = "web-server-${count.index + 1}"
    Role = "webserver"
    Environment = var.environment
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3 python3-pip",
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "[webservers]" > inventory.ini
      echo "${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.private_key_path}" >> inventory.ini
      ansible-playbook -i inventory.ini webserver.yml
    EOT
  }
}
```

#### GitOps Workflow Implementation

GitOps principles apply version control workflows to infrastructure management:

**Repository structure:**

```
infrastructure/
├── terraform/
│   ├── environments/
│   │   ├── production/
│   │   ├── staging/
│   │   └── development/
│   └── modules/
│       ├── vpc/
│       ├── ec2/
│       └── rds/
├── ansible/
│   ├── playbooks/
│   ├── roles/
│   ├── inventories/
│   └── group_vars/
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml
│       └── ansible-deploy.yml
└── README.md
```

**Automated deployment pipeline:**

```yaml
# .github/workflows/infrastructure-deploy.yml
name: Infrastructure Deployment
on:
  push:
    branches: [main]
    paths: ['terraform/**', 'ansible/**']

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
          
      - name: Terraform Plan
        run: |
          cd terraform/environments/production
          terraform init
          terraform plan -out=tfplan
          
      - name: Terraform Apply
        run: |
          cd terraform/environments/production
          terraform apply tfplan
          
  ansible:
    needs: terraform
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Ansible
        run: |
          pip install ansible
          ansible-galaxy install -r requirements.yml
          
      - name: Run Ansible Playbook
        run: |
          cd ansible
          ansible-playbook -i inventories/production site.yml
```

#### Configuration Drift Detection

Automated drift detection identifies configuration changes outside of managed processes:

**Ansible drift detection:**

```yaml
- name: Configuration compliance check
  hosts: all
  tasks:
    - name: Check package versions
      package_facts:
        manager: auto
        
    - name: Validate service states
      service_facts:
      
    - name: Compare against baseline
      assert:
        that:
          - ansible_facts.packages['nginx'][0].version == expected_nginx_version
          - ansible_facts.services['nginx.service'].state == 'running'
        fail_msg: "Configuration drift detected"
        success_msg: "Configuration compliant"
```

**Puppet drift detection through reporting:**

```puppet
# Enable detailed reporting
class { 'puppet':
  report_server => 'puppet.example.com',
  reports       => ['store', 'http'],
}

# Custom fact for compliance checking
Facter.add('compliance_status') do
  setcode do
    # Check critical configuration files
    config_hash = Digest::SHA256.hexdigest(File.read('/etc/nginx/nginx.conf'))
    expected_hash = 'abc123def456...'
    
    if config_hash == expected_hash
      'compliant'
    else
      'drift_detected'
    end
  end
end
```

#### Testing Infrastructure Code

Infrastructure testing validates both syntax and functionality:

**Ansible testing with Molecule:**

```yaml
# molecule/default/molecule.yml
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance
    image: ubuntu:20.04
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible
```

**Test scenarios:**

```yaml
# molecule/default/verify.yml
- name: Verify web server configuration
  hosts: all
  tasks:
    - name: Check nginx is installed
      package:
        name: nginx
        state: present
      check_mode: yes
      register: nginx_check
      
    - name: Verify nginx service is running
      service:
        name: nginx
        state: started
      check_mode: yes
      register: service_check
      
    - name: Test web server response
      uri:
        url: http://localhost:80
        status_code: 200
```

**Key points:**

- Configuration management tools provide declarative infrastructure state management
- Template systems enable dynamic configuration generation across diverse environments
- Infrastructure as Code practices apply software development methodologies to infrastructure management
- Automated testing and drift detection maintain configuration compliance and reliability

**Conclusion:** Modern configuration management requires integration of multiple tools and practices, combining provisioning automation with configuration state management. Success depends on establishing consistent workflows, comprehensive testing, and continuous compliance monitoring [Inference based on DevOps best practices].

---

