## Changed_when and Reporting


### Controlling Change Detection

The `changed_when` directive customizes when Ansible reports a task as changed, affecting idempotency reporting and handler triggering. This is crucial for command and shell modules that don't inherently track state changes.

**Basic changed_when Usage:**

```yaml
- name: Check and create user if needed
  command: id {{ username }}
  register: user_check
  changed_when: false  # Never report as changed
  failed_when: false   # Don't fail if user doesn't exist

- name: Create user only if doesn't exist
  user:
    name: "{{ username }}"
    state: present
  when: user_check.rc != 0
  # This task properly reports changed status
```

**Conditional Change Detection:**

```yaml
- name: Update configuration file
  shell: |
    if ! grep -q "{{ config_value }}" /etc/app/config; then
      echo "{{ config_value }}" >> /etc/app/config
      echo "CHANGED"
    else
      echo "UNCHANGED"
    fi
  register: config_update
  changed_when: "'CHANGED' in config_update.stdout"

- name: Restart service when config changes
  service:
    name: myapp
    state: restarted
  when: config_update.changed
```

### Advanced Change Detection Patterns

**File Content-Based Changes:**

```yaml
- name: Get current configuration checksum
  stat:
    path: /etc/nginx/nginx.conf
    checksum_algorithm: sha256
  register: config_before

- name: Update nginx configuration
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  register: template_result

- name: Get new configuration checksum
  stat:
    path: /etc/nginx/nginx.conf
    checksum_algorithm: sha256
  register: config_after

- name: Report configuration change
  debug:
    msg: "Configuration {{ 'changed' if config_before.stat.checksum != config_after.stat.checksum else 'unchanged' }}"
  changed_when: config_before.stat.checksum != config_after.stat.checksum
```

**Database Operation Change Detection:**

```yaml
- name: Check if database table exists
  command: mysql -u {{ db_user }} -p{{ db_password }} {{ db_name }} -e "SHOW TABLES LIKE '{{ table_name }}'"
  register: table_check
  no_log: true
  changed_when: false

- name: Create database table
  command: mysql -u {{ db_user }} -p{{ db_password }} {{ db_name }} < /opt/sql/create_table.sql
  register: table_creation
  when: table_check.stdout_lines | length == 0
  changed_when: table_creation.rc == 0
  no_log: true
```

**Service State Change Reporting:**

```yaml
- name: Get current service state
  command: systemctl is-active {{ service_name }}
  register: service_before
  changed_when: false
  failed_when: false

- name: Manage service state
  service:
    name: "{{ service_name }}"
    state: "{{ desired_state }}"
  register: service_action

- name: Report service state change
  debug:
    msg: |
      Service {{ service_name }}:
      Previous state: {{ service_before.stdout }}
      Action taken: {{ service_action.changed }}
      Current state: {{ desired_state }}
  changed_when: service_action.changed
```

