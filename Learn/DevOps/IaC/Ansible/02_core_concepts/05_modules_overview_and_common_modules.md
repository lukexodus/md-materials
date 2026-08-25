## Modules Overview and Common Modules


### Module Categories and Architecture

Ansible modules are discrete units of code that perform specific tasks. They accept parameters, execute operations, and return JSON data with results. Modules run on target hosts and are removed after execution.

**Module Categories:**

- **System**: User management, service control, package installation
- **Files**: File operations, templating, archiving
- **Network**: Network device configuration, HTTP requests
- **Cloud**: Cloud provider resource management
- **Database**: Database operations and management
- **Monitoring**: Monitoring system integration

### Essential System Modules

**user Module:**

```yaml
- name: Create application user
  user:
    name: appuser
    group: appgroup
    home: /opt/app
    shell: /bin/bash
    system: yes
    create_home: yes
```

**group Module:**

```yaml
- name: Create application group
  group:
    name: appgroup
    gid: 1001
    system: yes
```

**service Module:**

```yaml
- name: Manage nginx service
  service:
    name: nginx
    state: started
    enabled: yes
  notify: restart nginx
```

**systemd Module (for systemd-specific features):**

```yaml
- name: Reload systemd and start service
  systemd:
    name: myapp
    state: started
    enabled: yes
    daemon_reload: yes
```

### Package Management Modules

**package Module (distribution-agnostic):**

```yaml
- name: Install packages across distributions
  package:
    name: "{{ item }}"
    state: present
  loop:
    - git
    - curl
    - vim
```

**apt Module (Debian/Ubuntu):**

```yaml
- name: Update package cache and install packages
  apt:
    name: "{{ packages }}"
    state: present
    update_cache: yes
    cache_valid_time: 3600
  vars:
    packages:
      - nginx
      - postgresql
      - python3-pip
```

**yum Module (RHEL/CentOS 7 and earlier):**

```yaml
- name: Install packages and enable repository
  yum:
    name: "{{ item }}"
    state: present
    enablerepo: epel
  loop:
    - htop
    - git
    - python3
```

**dnf Module (RHEL/CentOS 8+, Fedora):**

```yaml
- name: Install package group
  dnf:
    name: "@Development Tools"
    state: present
```

### File Operation Modules

**copy Module:**

```yaml
- name: Copy configuration file
  copy:
    src: files/nginx.conf
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
    backup: yes
  notify: restart nginx
```

**template Module:**

```yaml
- name: Generate configuration from template
  template:
    src: app.conf.j2
    dest: /etc/app/app.conf
    owner: appuser
    group: appgroup
    mode: '0640'
    validate: '/usr/bin/app --config-test %s'
```

**file Module:**

```yaml
- name: Create directory structure
  file:
    path: "{{ item }}"
    state: directory
    mode: '0755'
    owner: appuser
    group: appgroup
  loop:
    - /opt/app/logs
    - /opt/app/data
    - /opt/app/config
```

**lineinfile Module:**

```yaml
- name: Modify configuration file
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?PermitRootLogin'
    line: 'PermitRootLogin no'
    backup: yes
  notify: restart sshd
```

**replace Module:**

```yaml
- name: Replace text in file
  replace:
    path: /etc/nginx/nginx.conf
    regexp: 'worker_processes\s+\d+'
    replace: 'worker_processes {{ ansible_processor_vcpus }}'
```

### Command Execution Modules

**command Module:**

```yaml
- name: Run command with specific conditions
  command: /usr/bin/make install
  args:
    chdir: /opt/source
    creates: /usr/local/bin/myapp
  register: make_result
```

**shell Module:**

```yaml
- name: Execute shell command with pipes
  shell: |
    ps aux | grep nginx | grep -v grep | wc -l
  register: nginx_processes
  changed_when: false
```

**script Module:**

```yaml
- name: Execute local script on remote host
  script: scripts/setup.sh
  args:
    creates: /opt/app/.setup_complete
```

### Archive and Compression Modules

**unarchive Module:**

```yaml
- name: Extract application archive
  unarchive:
    src: https://releases.app.com/app-1.0.tar.gz
    dest: /opt
    remote_src: yes
    owner: appuser
    group: appgroup
    creates: /opt/app-1.0
```

**archive Module:**

```yaml
- name: Create backup archive
  archive:
    path: /opt/app/data
    dest: /backup/app-data-{{ ansible_date_time.epoch }}.tar.gz
    format: gz
```

