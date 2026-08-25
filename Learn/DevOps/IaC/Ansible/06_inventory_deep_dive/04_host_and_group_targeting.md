## Host and Group Targeting


Ansible provides flexible patterns for targeting specific hosts or groups during playbook execution. These patterns enable precise control over automation scope and execution boundaries.

**Basic Targeting Patterns:**

```bash
# Single host
ansible-playbook site.yml -i inventory -l web1.example.com

# Multiple hosts
ansible-playbook site.yml -i inventory -l "web1.example.com,web2.example.com"

# Group targeting
ansible-playbook site.yml -i inventory -l webservers

# All hosts in multiple groups
ansible-playbook site.yml -i inventory -l "webservers,databases"
```

**Advanced Pattern Matching:**

```bash
# Wildcard patterns
ansible-playbook site.yml -l "web*.example.com"
ansible-playbook site.yml -l "*.prod.example.com"

# Regular expressions
ansible-playbook site.yml -l "~web[0-9]+\.example\.com"

# Range patterns
ansible-playbook site.yml -l "web[1:5].example.com"
```

**Boolean Operations:**

```bash
# Intersection (hosts in both groups)
ansible-playbook site.yml -l "webservers:&production"

# Union (hosts in either group)
ansible-playbook site.yml -l "webservers:databases"

# Exclusion (hosts in first group but not second)
ansible-playbook site.yml -l "webservers:!staging"

# Complex combinations
ansible-playbook site.yml -l "production:&webservers:!maintenance"
```

**Host Attributes Targeting:**

```bash
# Target by group membership
ansible-playbook site.yml -l "group_names['webservers']"

# Target by inventory hostname
ansible-playbook site.yml -l "inventory_hostname.startswith('web')"
```

