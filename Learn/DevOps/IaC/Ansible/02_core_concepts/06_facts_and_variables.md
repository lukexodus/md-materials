## Facts and Variables


### Ansible Facts System

Facts are system properties automatically discovered by Ansible during the gathering phase. The setup module collects facts about hardware, operating system, network configuration, and installed software.

**Fact Gathering Control:**

```yaml
- hosts: all
  gather_facts: yes  # Default behavior
  fact_caching: memory
  fact_caching_timeout: 86400
```

**Disabling Fact Gathering:**

```yaml
- hosts: all
  gather_facts: no
  tasks:
    - name: Gather only specific facts
      setup:
        filter: ansible_*_mb
```

### Fact Categories and Structure

**System Facts:**

- `ansible_hostname`: System hostname
- `ansible_fqdn`: Fully qualified domain name
- `ansible_distribution`: OS distribution name
- `ansible_distribution_version`: OS version
- `ansible_kernel`: Kernel version
- `ansible_architecture`: System architecture

**Hardware Facts:**

- `ansible_processor`: CPU information
- `ansible_processor_cores`: Number of CPU cores
- `ansible_memtotal_mb`: Total memory in MB
- `ansible_devices`: Storage device information
- `ansible_mounts`: Mounted filesystems

**Network Facts:**

- `ansible_interfaces`: Network interface list
- `ansible_default_ipv4`: Default IPv4 configuration
- `ansible_all_ipv4_addresses`: All IPv4 addresses
- `ansible_dns`: DNS configuration

**Example Fact Usage:**

```yaml
- name: Display system information
  debug:
    msg: |
      Hostname: {{ ansible_hostname }}
      OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
      Memory: {{ ansible_memtotal_mb }} MB
      CPU Cores: {{ ansible_processor_cores }}
      Default IP: {{ ansible_default_ipv4.address }}
```

### Custom Facts

Custom facts extend Ansible's built-in fact system by placing executable scripts or JSON files in `/etc/ansible/facts.d/` on managed hosts.

**JSON Custom Fact (/etc/ansible/facts.d/app.fact):**

```json
{
    "version": "1.2.3",
    "environment": "production",
    "last_updated": "2024-01-15"
}
```

**Script Custom Fact (/etc/ansible/facts.d/database.fact):**

```bash
#!/bin/bash
echo '{'
echo '  "connections": '$(netstat -an | grep :5432 | wc -l)','
echo '  "uptime": "'$(uptime -p)'"'
echo '}'
```

**Accessing Custom Facts:**

```yaml
- name: Use custom facts
  debug:
    msg: |
      App Version: {{ ansible_local.app.version }}
      DB Connections: {{ ansible_local.database.connections }}
```

### Variable Types and Precedence

Variables in Ansible follow a specific precedence order (highest to lowest):

1. Extra vars (`-e` command line)
2. Connection variables
3. Task vars
4. Block vars
5. Role and include vars
6. Play vars
7. Host facts
8. Registered vars
9. Set_facts
10. Host vars (inventory)
11. Group vars (inventory)
12. Group vars (/all)
13. Role defaults

**Variable Definition Methods:**

**Inventory Variables:**

```ini
[webservers]
web1.example.com http_port=8080 db_host=db1.example.com

[webservers:vars]
http_port=80
max_connections=200
```

**Playbook Variables:**

```yaml
- hosts: webservers
  vars:
    app_name: myapp
    app_version: 1.0
    packages:
      - nginx
      - python3
  vars_files:
    - vars/common.yml
    - vars/{{ ansible_distribution }}.yml
```

**Variable Files (vars/common.yml):**

```yaml
# Application settings
app_user: appuser
app_group: appgroup
app_home: /opt/myapp

# Database settings
db_name: myapp_db
db_user: myapp_user
db_password: "{{ vault_db_password }}"

# Service settings
service_ports:
  http: 80
  https: 443
  ssh: 22
```

### Variable Manipulation and Filters

**String Manipulation:**

```yaml
- name: String operations
  debug:
    msg: |
      Uppercase: {{ app_name | upper }}
      Default value: {{ undefined_var | default('fallback') }}
      Join list: {{ packages | join(', ') }}
      Replace text: {{ hostname | replace('.', '_') }}
```

**List and Dictionary Operations:**

```yaml
- name: Collection operations
  debug:
    msg: |
      First item: {{ packages | first }}
      Last item: {{ packages | last }}
      Random item: {{ packages | random }}
      Sorted list: {{ packages | sort }}
      Unique items: {{ duplicate_list | unique }}
      Dict keys: {{ user_data | list }}
```

**Mathematical and Comparison:**

```yaml
- name: Math operations
  debug:
    msg: |
      Sum: {{ [1, 2, 3, 4] | sum }}
      Min: {{ numbers | min }}
      Max: {{ numbers | max }}
      Length: {{ packages | length }}
```

**JSON and YAML Processing:**

```yaml
- name: Data format conversion
  debug:
    msg: |
      To JSON: {{ app_config | to_json }}
      From JSON: {{ json_string | from_json }}
      To YAML: {{ app_config | to_nice_yaml }}
```

