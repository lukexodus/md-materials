## Limiting Execution Scope


Execution scope control prevents unintended automation impact by restricting playbook runs to specific subsets of infrastructure. These mechanisms provide safety boundaries for operational tasks.

**Command-Line Limiting:**

```bash
# Limit to specific hosts
ansible-playbook deploy.yml --limit "web1.example.com,web2.example.com"

# Limit to host pattern
ansible-playbook deploy.yml --limit "web*.prod.example.com"

# Limit to group intersection
ansible-playbook deploy.yml --limit "webservers:&production"

# Exclude specific hosts
ansible-playbook deploy.yml --limit "all:!maintenance"
```

**Playbook-Level Targeting:**

```yaml
---
- name: Production web server deployment
  hosts: "webservers:&production:!maintenance"
  serial: 2  # Limit concurrent execution
  max_fail_percentage: 10  # Stop if >10% of hosts fail
  tasks:
    - name: Deploy application
      # Task definition
```

**Serial Execution Control:**

```yaml
---
- name: Rolling deployment
  hosts: webservers
  serial:
    - 1        # First host
    - 25%      # Then 25% of remaining
    - 100%     # Then all remaining
  tasks:
    - name: Update application
      # Task definition
```

**Batch Processing:**

```yaml
---
- name: Maintenance tasks
  hosts: all
  strategy: free  # Allow hosts to run independently
  throttle: 5     # Maximum 5 concurrent hosts
  tasks:
    - name: System updates
      # Task definition
```

**Run-Once Patterns:**

```yaml
---
- name: Database migration
  hosts: databases
  run_once: true  # Execute on first host only
  delegate_to: "{{ groups['databases'][0] }}"
  tasks:
    - name: Run migration script
      # Task definition
```

