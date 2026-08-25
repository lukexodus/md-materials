## Inventory Variables and host_vars/group_vars


Variable management through inventory structure provides hierarchical configuration control with precedence rules governing variable resolution. The `host_vars` and `group_vars` directories enable organized variable storage separate from inventory files.

**Directory Structure:**

```
inventory/
├── hosts
├── group_vars/
│   ├── all.yml
│   ├── webservers.yml
│   ├── databases.yml
│   └── production/
│       ├── vars.yml
│       └── vault.yml
└── host_vars/
    ├── web1.example.com.yml
    ├── web2.example.com.yml
    └── db1.example.com/
        ├── vars.yml
        └── vault.yml
```

**Variable Precedence Order:** [Unverified] The exact precedence order may vary between Ansible versions, but generally follows this pattern:

1. Extra vars (`-e` command line)
2. Task vars
3. Block vars
4. Role and include vars
5. Set_facts
6. Registered vars
7. Host facts
8. Play vars
9. Host vars
10. Group vars
11. Inventory vars

**Group Variables Example:**

```yaml
# group_vars/webservers.yml
---
http_port: 80
max_clients: 200
document_root: /var/www/html
ssl_enabled: false

# Environment-specific overrides
# group_vars/production/webservers.yml
---
max_clients: 500
ssl_enabled: true
ssl_cert_path: /etc/ssl/certs/production.crt
```

**Host Variables Example:**

```yaml
# host_vars/web1.example.com.yml
---
ansible_host: 192.168.1.10
http_port: 8080
max_clients: 300
local_storage_path: /opt/app/storage
backup_enabled: true
```

**Complex Variable Structures:**

```yaml
# group_vars/databases.yml
---
mysql:
  port: 3306
  max_connections: 100
  innodb_buffer_pool_size: "1G"
  
backup_config:
  enabled: true
  schedule: "0 2 * * *"
  retention_days: 30
  destinations:
    - type: s3
      bucket: mysql-backups
      region: us-east-1
    - type: local
      path: /backup/mysql
```

**Variable Merging Behavior:**

```yaml
# group_vars/all.yml
app_config:
  database:
    host: localhost
    port: 5432
  cache:
    enabled: false

# group_vars/production.yml  
app_config:
  database:
    host: prod-db.example.com
  logging:
    level: warn
    
# Merged result for production hosts:
# app_config:
#   database:
#     host: prod-db.example.com  # Overridden
#     port: 5432                 # Inherited
#   cache:
#     enabled: false             # Inherited
#   logging:                     # Added
#     level: warn
```

**Encrypted Variables (Vault):**

```yaml
# group_vars/production/vault.yml (encrypted)
---
database_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653762346137383731373436336237613964323033373764303739666366663532313632
          6563373734656138303636323238353464643833343565650a626435636231633966356632383734

# group_vars/production/vars.yml (plaintext)
---
database_user: prod_user
database_host: prod-db.internal.example.com
```

**Dynamic Variable Assignment:**

```yaml
# Conditional variables based on host characteristics
# group_vars/webservers.yml
---
http_port: "{{ '443' if ssl_enabled else '80' }}"
worker_processes: "{{ ansible_processor_vcpus | default(2) }}"
memory_limit: "{{ (ansible_memtotal_mb * 0.8) | int }}M"
```

**Variable Validation:**

```yaml
# host_vars/web1.example.com.yml
---
# Required variables with validation
http_port: 80
ssl_enabled: true

# Validation in playbook
- name: Validate required variables
  assert:
    that:
      - http_port is defined
      - http_port | int > 0 and http_port | int < 65536
      - ssl_enabled is boolean
    fail_msg: "Invalid configuration detected"
```

**Important Related Topics:**

- Ansible Vault for sensitive data encryption
- Variable templating with Jinja2 expressions
- Inventory script development and testing
- Performance optimization for large inventories

---

