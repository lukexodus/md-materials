## Tags for Selective Execution


Tags provide granular control over playbook execution, allowing selective running of specific tasks or groups of tasks. They enhance development workflows and operational flexibility.

**Task Tagging:**

```yaml
- name: Install web server
  yum:
    name: httpd
    state: present
  tags:
    - packages
    - webserver
    - install

- name: Configure web server
  template:
    src: httpd.conf.j2
    dest: /etc/httpd/conf/httpd.conf
  tags:
    - configuration
    - webserver
```

**Play-Level Tags:**

```yaml
- name: Database setup
  hosts: databases
  tags:
    - database
    - setup
  tasks:
    - name: Install MySQL
      yum:
        name: mysql-server
        state: present
```

**Execution Commands:**

```bash
# Run only tasks tagged with 'webserver'
ansible-playbook site.yml --tags webserver

# Skip tasks tagged with 'database'
ansible-playbook site.yml --skip-tags database

# Run multiple tags
ansible-playbook site.yml --tags "packages,configuration"

# List all available tags
ansible-playbook site.yml --list-tags
```

**Special Tags:**

- `always`: Tasks run regardless of tag selection
- `never`: Tasks run only when explicitly requested
- `tagged`: Run all tagged tasks
- `untagged`: Run all untagged tasks
- `all`: Run all tasks (default behavior)

**Tag Inheritance:**

```yaml
- name: Web server setup
  hosts: webservers
  tags: webserver
  tasks:
    - name: Install Apache  # Inherits 'webserver' tag
      yum:
        name: httpd
        state: present
    
    - name: Special configuration
      template:
        src: special.conf.j2
        dest: /etc/httpd/conf.d/special.conf
      tags:
        - special  # Has both 'webserver' and 'special' tags
```

**Advanced Tag Usage:** [Inference] Tags can be applied dynamically based on conditions, though this requires careful consideration of execution flow and variable scope.

```yaml
- name: Conditional tagging example
  debug:
    msg: "Environment specific task"
  tags:
    - "{{ environment }}"
  when: environment is defined
```

**Best Practices:**

- Use consistent tag naming conventions across playbooks
- Apply descriptive tags that reflect task purpose or component
- Consider tag inheritance when structuring plays and tasks
- Document tag usage for team collaboration
- Test tag combinations to ensure expected behavior

---

