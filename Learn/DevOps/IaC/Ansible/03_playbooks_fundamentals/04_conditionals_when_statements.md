## Conditionals (When Statements)


Conditional execution allows tasks to run based on variable values, facts, or previous task results. The `when` statement evaluates expressions using Jinja2 templating syntax.

**Basic Syntax:**

```yaml
- name: Install package on Red Hat systems
  yum:
    name: httpd
    state: present
  when: ansible_os_family == "RedHat"

- name: Install package on Debian systems
  apt:
    name: apache2
    state: present
  when: ansible_os_family == "Debian"
```

**Complex Conditions:**

```yaml
- name: Conditional with multiple criteria
  service:
    name: httpd
    state: started
  when: 
    - ansible_os_family == "RedHat"
    - apache_enabled | default(false)
    - inventory_hostname in groups['webservers']
```

**Conditional Operators:**

- Equality: `==`, `!=`
- Comparison: `<`, `>`, `<=`, `>=`
- Logical: `and`, `or`, `not`
- Membership: `in`, `not in`
- Pattern matching: `match`, `search`

**Variable Testing:**

```yaml
- name: Task runs when variable is defined
  debug:
    msg: "Variable exists"
  when: my_variable is defined

- name: Task runs when variable is undefined
  debug:
    msg: "Variable missing"
  when: my_variable is not defined
```

