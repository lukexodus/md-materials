## Tasks, Plays, and Playbooks


The hierarchical relationship between these components forms Ansible's execution model, with each level serving distinct organizational purposes.

**Playbooks** represent the top-level automation document containing one or more plays. They define the complete automation workflow and can include multiple plays targeting different host groups.

**Plays** are individual units within a playbook that target specific hosts or groups. Each play defines variables, tasks, and execution parameters for a particular set of machines.

**Tasks** are the fundamental execution units that call Ansible modules to perform specific actions. They represent individual configuration steps or commands.

**Example Structure:**

```yaml
---
# Playbook level
- name: Web server configuration play
  hosts: webservers
  become: yes
  vars:
    http_port: 80
  tasks:
    - name: Install Apache
      yum:
        name: httpd
        state: present
    
    - name: Start Apache service
      service:
        name: httpd
        state: started

- name: Database configuration play
  hosts: databases
  tasks:
    - name: Install MySQL
      yum:
        name: mysql-server
        state: present
```

