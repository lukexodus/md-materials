## Creating and Using Roles


Role creation begins with establishing the directory structure and populating it with automation logic tailored to specific infrastructure requirements. Ansible provides tools to scaffold role structures and templates for common use cases.

**Role Creation Methods:**

**Manual Creation** involves creating the directory structure and files manually:

```bash
mkdir -p my_role/{tasks,handlers,templates,files,vars,defaults,meta}
touch my_role/{tasks,handlers,vars,defaults,meta}/main.yml
```

**Ansible Galaxy Command** provides scaffolding capabilities:

```bash
ansible-galaxy init my_role
```

This command creates the complete directory structure with template files containing example content and documentation.

**Role Implementation Example:**

A web server role might contain the following structure:

**tasks/main.yml:**
```yaml
---
- name: Install web server packages
  package:
    name: "{{ web_server_packages }}"
    state: present

- name: Configure web server
  template:
    src: httpd.conf.j2
    dest: "{{ web_server_config_path }}"
    backup: yes
  notify: restart web server

- name: Start and enable web server
  service:
    name: "{{ web_server_service }}"
    state: started
    enabled: yes

- name: Deploy web content
  copy:
    src: "{{ item }}"
    dest: "{{ web_server_document_root }}/"
  with_fileglob:
    - "files/web/*"
```

**defaults/main.yml:**
```yaml
---
web_server_packages:
  - httpd
  - mod_ssl
web_server_service: httpd
web_server_config_path: /etc/httpd/conf/httpd.conf
web_server_document_root: /var/www/html
web_server_port: 80
web_server_ssl_port: 443
```

**handlers/main.yml:**
```yaml
---
- name: restart web server
  service:
    name: "{{ web_server_service }}"
    state: restarted
```

**Using Roles in Playbooks:**

**Basic Role Usage:**
```yaml
---
- hosts: web_servers
  roles:
    - my_role
```

**Role with Variable Overrides:**
```yaml
---
- hosts: web_servers
  roles:
    - role: my_role
      vars:
        web_server_port: 8080
        web_server_packages:
          - nginx
```

**Conditional Role Execution:**
```yaml
---
- hosts: all
  roles:
    - role: my_role
      when: inventory_hostname in groups['web_servers']
```

**Role Tags:**
```yaml
---
- hosts: web_servers
  roles:
    - role: my_role
      tags:
        - web
        - configuration
```

**Mixed Tasks and Roles:**
```yaml
---
- hosts: web_servers
  tasks:
    - name: Pre-role task
      debug:
        msg: "Preparing for role execution"
  
  roles:
    - my_role
  
  post_tasks:
    - name: Post-role task
      debug:
        msg: "Role execution completed"
```

**Role Variable Scope and Precedence:**

Variables defined within roles follow Ansible's variable precedence hierarchy. Role variables in `vars/main.yml` have higher precedence than defaults but lower precedence than playbook variables, extra variables, and inventory variables.

**Role Parameterization:**

Well-designed roles expose configuration options through variables, enabling customization without code modification:

```yaml
---
- hosts: database_servers
  roles:
    - role: mysql
      vars:
        mysql_root_password: "{{ vault_mysql_root_password }}"
        mysql_databases:
          - name: app_production
            encoding: utf8
            collation: utf8_general_ci
        mysql_users:
          - name: app_user
            password: "{{ vault_app_user_password }}"
            host: "%"
            priv: "app_production.*:ALL"
```

