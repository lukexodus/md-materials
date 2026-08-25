## Error Handling and failed_when


### Understanding Task Failure States

Ansible determines task failure through multiple mechanisms: module return codes, changed status, and custom failure conditions. By default, tasks fail when modules return non-zero exit codes or explicitly set failed=true in their return data. The `failed_when` directive overrides default failure detection with custom logic.

**Default Failure Behavior:**

```yaml
- name: Command that might fail
  command: /usr/bin/risky-operation
  # Fails automatically if return code != 0
  
- name: Service operation
  service:
    name: nonexistent-service
    state: started
  # Fails if service doesn't exist or can't be started
```

### Custom Failure Conditions with failed_when

**Basic failed_when Usage:**

```yaml
- name: Check application health
  uri:
    url: "http://{{ inventory_hostname }}:8080/health"
    method: GET
  register: health_check
  failed_when: 
    - health_check.status != 200
    - "'healthy' not in health_check.json.status"

- name: Validate configuration file
  command: /usr/bin/validate-config /etc/app/config.yml
  register: config_validation
  failed_when: 
    - config_validation.rc != 0
    - "'ERROR' in config_validation.stderr"
```

**Complex Failure Logic:**

```yaml
- name: Database connection test
  command: mysql -u {{ db_user }} -p{{ db_password }} -e "SELECT 1"
  register: db_test
  no_log: true  # Hide password from logs
  failed_when:
    - db_test.rc != 0
    - "'Access denied' in db_test.stderr"
    - db_test.stdout_lines | length == 0

- name: Memory usage check
  shell: free -m | awk 'NR==2{printf "%.2f", $3*100/$2}'
  register: memory_usage
  failed_when: memory_usage.stdout | float > 90.0
  tags: health_check
```

### Advanced Error Handling Patterns

**Conditional Failure with Multiple Criteria:**

```yaml
- name: Multi-condition service check
  shell: |
    systemctl is-active {{ service_name }} > /dev/null 2>&1
    echo "RC: $?"
    netstat -tlnp | grep :{{ service_port }} > /dev/null 2>&1
    echo "PORT: $?"
  register: service_status
  failed_when:
    - "'RC: 0' not in service_status.stdout"
    - "'PORT: 0' not in service_status.stdout"
    - service_status.rc != 0

- name: Application deployment validation
  block:
    - name: Check application version
      uri:
        url: "http://{{ inventory_hostname }}/api/version"
      register: version_check
      
    - name: Validate version matches expected
      fail:
        msg: "Deployed version {{ version_check.json.version }} does not match expected {{ expected_version }}"
      when: version_check.json.version != expected_version
      
  rescue:
    - name: Rollback on validation failure
      command: /opt/app/bin/rollback.sh
      register: rollback_result
      
    - name: Report rollback status
      debug:
        msg: "Rollback completed: {{ rollback_result.stdout }}"
```

**Ignore Errors with Conditions:**

```yaml
- name: Optional service configuration
  lineinfile:
    path: /etc/{{ service_name }}/config
    line: "{{ config_line }}"
  register: config_update
  ignore_errors: yes
  failed_when:
    - config_update.failed
    - "'Permission denied' not in config_update.msg"
    - "'No such file' not in config_update.msg"
```

