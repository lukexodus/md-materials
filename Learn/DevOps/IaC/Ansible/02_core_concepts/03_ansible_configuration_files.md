## Ansible Configuration Files


### ansible.cfg Structure and Precedence

Ansible searches for configuration files in this order:

1. `ANSIBLE_CONFIG` environment variable
2. `ansible.cfg` in current directory
3. `~/.ansible.cfg` in home directory
4. `/etc/ansible/ansible.cfg` system-wide

**Configuration Sections:**

```ini
[defaults]
inventory = ./inventory
host_key_checking = False
timeout = 30
forks = 10
remote_user = ansible
private_key_file = ~/.ssh/ansible_key
roles_path = ./roles:~/.ansible/roles
callback_whitelist = profile_tasks, timer

[inventory]
enable_plugins = aws_ec2, gcp_compute, azure_rm

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
control_path = ~/.ansible/cp/%%h-%%p-%%r
```

### Critical Configuration Parameters

**Performance Settings:**

- `forks`: Number of parallel processes (default: 5)
- `pipelining`: Reduces SSH operations by executing multiple commands in single connection
- `ssh_args`: SSH connection optimization parameters

**Security Settings:**

- `host_key_checking`: Disable for dynamic environments (use cautiously)
- `private_key_file`: Default SSH private key
- `remote_user`: Default user for connections

**Behavioral Settings:**

- `timeout`: Connection timeout in seconds
- `gathering`: Fact gathering policy (implicit, explicit, smart)
- `retry_files_enabled`: Create retry files for failed hosts

