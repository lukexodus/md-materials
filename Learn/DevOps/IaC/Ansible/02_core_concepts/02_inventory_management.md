## Inventory Management


### Static Inventory

Static inventory files define hosts and groups in INI or YAML format. The default location is `/etc/ansible/hosts`, but custom files can be specified using `-i` flag or in ansible.cfg.

**INI Format Structure:**

```ini
[webservers]
web1.example.com
web2.example.com ansible_host=192.168.1.10

[databases]
db1.example.com ansible_user=dbadmin
db2.example.com

[production:children]
webservers
databases

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

**YAML Format Structure:**

```yaml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
          ansible_host: 192.168.1.10
    databases:
      hosts:
        db1.example.com:
          ansible_user: dbadmin
        db2.example.com:
  vars:
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Dynamic Inventory

Dynamic inventory scripts or plugins generate host information from external sources like cloud providers, CMDB systems, or databases. These return JSON data structures containing hosts, groups, and variables.

**Common Dynamic Inventory Sources:**

- AWS EC2 instances using aws_ec2 plugin
- Azure virtual machines using azure_rm plugin
- Google Cloud Platform using gcp_compute plugin
- VMware vSphere using vmware_vm_inventory plugin
- Custom scripts returning JSON format

**Dynamic Inventory Plugin Configuration:**

```yaml
# inventory.aws_ec2.yml
plugin: aws_ec2
regions:
  - us-east-1
  - us-west-2
keyed_groups:
  - key: tags
    prefix: tag
  - key: instance_type
    prefix: type
hostnames:
  - dns-name
  - private-ip-address
```

### Inventory Variables and Host/Group Variables

Variables can be defined at multiple levels with specific precedence rules. Host variables override group variables, and variables defined in playbooks override inventory variables.

**Host and Group Variables:**

```ini
[webservers]
web1.example.com http_port=8080 max_connections=200
web2.example.com http_port=8081

[webservers:vars]
ntp_server=pool.ntp.org
max_connections=100
```

**Variable Files:**

- `host_vars/hostname.yml` - Host-specific variables
- `group_vars/groupname.yml` - Group-specific variables
- `group_vars/all.yml` - Variables for all hosts

