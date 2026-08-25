## Playbook Structure and Syntax


Ansible playbooks follow a specific YAML structure with defined sections and formatting requirements. The basic anatomy consists of plays, which contain tasks that execute on target hosts.

**Key Points:**

- Playbooks begin with three dashes (---) as YAML document markers
- Each playbook contains one or more plays
- YAML indentation must use spaces, not tabs
- Comments use the hash symbol (#)
- String values can be quoted or unquoted depending on content

**Basic Structure:**

```yaml
---
- name: Playbook description
  hosts: target_hosts
  become: yes
  vars:
    variable_name: value
  tasks:
    - name: Task description
      module_name:
        parameter: value
```

**Essential Elements:**

- `name`: Descriptive label for the play or task
- `hosts`: Target machines or groups where tasks execute
- `become`: Privilege escalation (sudo/root access)
- `vars`: Variable definitions for the play
- `tasks`: Ordered list of actions to perform

