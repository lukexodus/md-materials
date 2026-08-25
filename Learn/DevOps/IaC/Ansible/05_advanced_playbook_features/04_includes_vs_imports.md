## Includes vs Imports


### Understanding the Difference

Includes are processed at runtime (dynamic), while imports are processed at parse time (static). This fundamental difference affects variable resolution, conditional evaluation, and performance characteristics.

### Import Statements (Static)

**Import Playbooks:**

```yaml
# main.yml
- import_playbook: site-preparation.yml
- import_playbook: application-deployment.yml
- import_playbook: post-deployment-tests.yml

# site-preparation.yml
- hosts: all
  gather_facts: yes
  tasks:
    - name: Update package cache
      package:
        update_cache: yes
    
    - name: Install prerequisites
      package:
        name: "{{ prerequisite_packages }}"
        state: present
```

**Import Tasks:**

```yaml
# main-playbook.yml
- hosts: webservers
  tasks:
    - import_tasks: common-setup.yml
    - import_tasks: webserver-config.yml
      vars:
        server_type: apache
        max_connections: 1000

# common-setup.yml
- name: Create application user
  user:
    name: "{{ app_user | default('webapp') }}"
    system: yes
    home: /opt/webapp

- name: Create application directories
  file:
    path: "{{ item }}"
    state: directory
    owner: "{{ app_user | default('webapp') }}"
  loop:
    - /opt/webapp/logs
    - /opt/webapp/data
    - /opt/webapp/config
```

**Import Roles:**

```yaml
- hosts: databases
  tasks:
    - import_role:
        name: mysql-server
      vars:
        mysql_root_password: "{{ vault_mysql_root_password }}"
        mysql_databases:
          - name: production_db
            encoding: utf8
            collation: utf8_general_ci
    
    - import_role:
        name: backup-configuration
      vars:
        backup_schedule: "0 2 * * *"
        retention_days: 30
```

### Include Statements (Dynamic)

**Include Tasks with Conditions:**

```yaml
- hosts: all
  tasks:
    - include_tasks: "{{ ansible_distribution | lower }}-setup.yml"
    
    - include_tasks: ssl-setup.yml
      when: enable_ssl | default(false)
    
    - include_tasks: monitoring-setup.yml
      when: "'monitoring' in group_names"

# ubuntu-setup.yml
- name: Install Ubuntu-specific packages
  apt:
    name: "{{ ubuntu_packages }}"
    state: present
    update_cache: yes

- name: Configure Ubuntu firewall
  ufw:
    rule: allow
    port: "{{ item }}"
  loop: "{{ firewall_ports }}"

# centos-setup.yml
- name: Install CentOS-specific packages
  yum:
    name: "{{ centos_packages }}"
    state: present

- name: Configure CentOS firewall
  firewalld:
    port: "{{ item }}/tcp"
    permanent: yes
    state: enabled
  loop: "{{ firewall_ports }}"
```

**Include with Loops:**

```yaml
- name: Configure multiple virtual hosts
  include_tasks: vhost-setup.yml
  vars:
    vhost_name: "{{ item.name }}"
    vhost_document_root: "{{ item.document_root }}"
    vhost_ssl_enabled: "{{ item.ssl | default(false) }}"
  loop: "{{ virtual_hosts }}"

# vhost-setup.yml
- name: Create document root for {{ vhost_name }}
  file:
    path: "{{ vhost_document_root }}"
    state: directory
    owner: www-data
    group: www-data
    mode: '0755'

- name: Configure virtual host {{ vhost_name }}
  template:
    src: vhost.conf.j2
    dest: "/etc/apache2/sites-available/{{ vhost_name }}.conf"
  notify: reload apache

- name: Enable virtual host {{ vhost_name }}
  command: a2ensite {{ vhost_name }}
  notify: reload apache
  when: ansible_distribution == "Ubuntu"
```

**Dynamic Role Inclusion:**

```yaml
- hosts: application_servers
  tasks:
    - name: Include application-specific roles
      include_role:
        name: "{{ item }}"
      loop: "{{ application_roles }}"
      when: item in available_roles

    - name: Configure load balancer if multiple app servers
      include_role:
        name: haproxy
      vars:
        backend_servers: "{{ groups['application_servers'] }}"
      when: groups['application_servers'] | length > 1
```

### Performance and Behavioral Differences

**Import Characteristics:**

- [Unverified] Processed at playbook parse time, potentially faster execution
- Variables must be defined before import statement
- Conditionals evaluated once during parsing
- Cannot use loops directly on import statements
- [Unverified] Better for static, predictable workflows

**Include Characteristics:**

- Processed during task execution, more flexible
- Variables can be passed dynamically
- Conditionals evaluated during execution
- Can be used with loops and dynamic conditions
- [Unverified] Better for dynamic, conditional workflows

