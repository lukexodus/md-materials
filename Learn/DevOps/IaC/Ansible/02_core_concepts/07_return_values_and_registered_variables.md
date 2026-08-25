## Return Values and Registered Variables


### Understanding Return Values

Every Ansible module returns a data structure containing information about the task execution. This data includes success/failure status, changes made, and module-specific information.

**Common Return Values:**

- `changed`: Boolean indicating if task made changes
- `failed`: Boolean indicating task failure
- `msg`: Human-readable message about the result
- `rc`: Return code for command modules
- `stdout`: Standard output from command execution
- `stderr`: Standard error from command execution
- `stdout_lines`: stdout split into list of lines
- `stderr_lines`: stderr split into list of lines

### Registered Variables Usage

**Basic Registration:**

```yaml
- name: Check service status
  command: systemctl is-active nginx
  register: nginx_status
  ignore_errors: yes

- name: Display service status
  debug:
    msg: |
      Return code: {{ nginx_status.rc }}
      Output: {{ nginx_status.stdout }}
      Command ran: {{ nginx_status.cmd }}
      Changed: {{ nginx_status.changed }}
```

**Command Module Registration:**

```yaml
- name: Get system information
  shell: |
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
  register: system_info

- name: Process command output
  debug:
    msg: "{{ item }}"
  loop: "{{ system_info.stdout_lines }}"
```

### Conditional Execution with Registered Variables

**Using Return Codes:**

```yaml
- name: Check if application is running
  command: pgrep myapp
  register: app_check
  ignore_errors: yes

- name: Start application if not running
  service:
    name: myapp
    state: started
  when: app_check.rc != 0

- name: Restart application if running
  service:
    name: myapp
    state: restarted
  when: app_check.rc == 0
```

**Complex Conditionals:**

```yaml
- name: Get disk usage
  shell: df -h / | tail -n 1 | awk '{print $5}' | sed 's/%//'
  register: disk_usage

- name: Alert if disk usage high
  debug:
    msg: "WARNING: Disk usage is {{ disk_usage.stdout }}%"
  when: disk_usage.stdout | int > 80

- name: Clean logs if disk usage critical
  file:
    path: /var/log/old_logs
    state: absent
  when: 
    - disk_usage.stdout | int > 90
    - ansible_distribution == "Ubuntu"
```

### Module-Specific Return Values

**File Module Returns:**

```yaml
- name: Create configuration file
  copy:
    src: app.conf
    dest: /etc/app/app.conf
  register: config_copy

- name: Restart service if config changed
  service:
    name: myapp
    state: restarted
  when: config_copy.changed
```

**Package Module Returns:**

```yaml
- name: Install packages
  package:
    name: "{{ packages }}"
    state: present
  register: package_result

- name: Show installation results
  debug:
    msg: |
      Packages installed: {{ package_result.results | map(attribute='name') | list }}
      Any changes: {{ package_result.changed }}
```

**URI Module Returns:**

```yaml
- name: Check API endpoint
  uri:
    url: "https://api.example.com/health"
    method: GET
  register: api_response

- name: Process API response
  debug:
    msg: |
      Status: {{ api_response.status }}
      Response time: {{ api_response.elapsed }}
      Content: {{ api_response.json }}
  when: api_response.status == 200
```

### Advanced Registration Patterns

**Looping with Registration:**

```yaml
- name: Check multiple services
  service:
    name: "{{ item }}"
  register: service_results
  loop:
    - nginx
    - mysql
    - redis

- name: Report service status
  debug:
    msg: "{{ item.item }} is {{ 'running' if item.status.ActiveState == 'active' else 'not running' }}"
  loop: "{{ service_results.results }}"
```

**Conditional Registration:**

```yaml
- name: Get log file size only if it exists
  stat:
    path: /var/log/app.log
  register: log_stat

- name: Read log tail if file is large
  command: tail -n 50 /var/log/app.log
  register: log_content
  when: 
    - log_stat.stat.exists
    - log_stat.stat.size > 1048576  # 1MB

- name: Display recent log entries
  debug:
    msg: "{{ log_content.stdout_lines }}"
  when: log_content is defined and not log_content.skipped
```

**Complex Data Processing:**

```yaml
- name: Get process information
  shell: ps aux --no-headers
  register: process_list

- name: Parse process data
  set_fact:
    high_cpu_processes: >-
      {{
        process_list.stdout_lines
        | map('regex_replace', '^\S+\s+(\d+)\s+(\S+)\s+(\S+).*$', '\1,\2,\3')
        | map('split', ',')
        | selectattr('2', 'match', '^[0-9.]+$')
        | selectattr('2', 'float', '>', 5.0)
        | list
      }}

- name: Report high CPU processes
  debug:
    msg: "Process {{ item[0] }} using {{ item[2] }}% CPU"
  loop: "{{ high_cpu_processes }}"
```

**Key Points**

Ansible's core concepts form the foundation for infrastructure automation and configuration management. The inventory system provides flexible host management through both static and dynamic approaches, supporting complex organizational structures and variable hierarchies. Configuration management through ansible.cfg enables fine-tuning of behavior, performance, and security settings across different environments.

Ad-hoc commands offer immediate task execution capabilities for operational tasks, while the extensive module library provides specialized functionality for system administration, file management, and service control. The facts system automatically discovers system information, enabling intelligent decision-making in automation workflows.

Variable management and registered return values create powerful conditional logic and data processing capabilities. Understanding these concepts enables building sophisticated automation that adapts to different environments and responds appropriately to changing conditions.

**Related Topics**: Playbook development, role creation, error handling strategies, performance optimization, security best practices, CI/CD integration, testing frameworks (molecule), advanced templating with Jinja2, custom module development.

---

