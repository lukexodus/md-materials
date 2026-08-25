## Loops and Iteration


Loops enable task repetition across lists, dictionaries, or other iterable data structures. Ansible provides multiple loop constructs for different iteration patterns.

**Basic Loop with Items:**

```yaml
- name: Install multiple packages
  yum:
    name: "{{ item }}"
    state: present
  loop:
    - httpd
    - mysql-server
    - php
```

**Dictionary Iteration:**

```yaml
- name: Create multiple users
  user:
    name: "{{ item.name }}"
    group: "{{ item.group }}"
    shell: "{{ item.shell }}"
  loop:
    - { name: "john", group: "admin", shell: "/bin/bash" }
    - { name: "jane", group: "users", shell: "/bin/zsh" }
```

**Advanced Loop Constructs:**

```yaml
# Loop with index
- name: Display items with index
  debug:
    msg: "Item {{ ansible_loop.index }}: {{ item }}"
  loop:
    - first
    - second
    - third

# Loop until condition
- name: Wait for service to start
  uri:
    url: "http://{{ inventory_hostname }}:8080/health"
  register: result
  until: result.status == 200
  retries: 5
  delay: 10
```

**Loop Control Options:**

- `loop_control.index_var`: Custom index variable name
- `loop_control.loop_var`: Custom item variable name
- `loop_control.pause`: Delay between iterations
- `loop_control.label`: Custom loop output labeling

