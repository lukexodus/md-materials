## Role Dependencies


Role dependencies enable automatic execution of prerequisite roles before the dependent role runs. Dependencies create hierarchical relationships between roles, ensuring proper execution order and eliminating manual dependency management.

**Dependency Declaration:**

Dependencies are specified in the `meta/main.yml` file within the dependencies section:

```yaml
---
dependencies:
  - role: common
  - role: firewall
    vars:
      firewall_allowed_ports:
        - 80
        - 443
  - role: ssl_certificates
    when: enable_ssl | default(false)
```

**Dependency Resolution:**

Ansible resolves dependencies recursively, creating a dependency graph that determines execution order. Dependencies execute before their dependent roles, ensuring required components are available when needed.

**Dependency Execution Rules:**

1. Dependencies execute only once per playbook run, regardless of how many roles depend on them
2. Dependencies execute in the order specified in the `meta/main.yml` file
3. Transitive dependencies (dependencies of dependencies) are resolved automatically
4. Circular dependencies cause execution failures and must be avoided

**Complex Dependency Example:**

A web application role might depend on multiple infrastructure components:

**web_app/meta/main.yml:**
```yaml
---
dependencies:
  - role: common
    vars:
      common_packages:
        - curl
        - wget
        - unzip
  
  - role: database
    vars:
      db_name: "{{ app_database_name }}"
      db_user: "{{ app_database_user }}"
      db_password: "{{ app_database_password }}"
  
  - role: web_server
    vars:
      web_server_port: "{{ app_port | default(8080) }}"
      web_server_ssl_enabled: "{{ app_ssl_enabled | default(false) }}"
  
  - role: monitoring
    when: monitoring_enabled | default(true)
```

**Conditional Dependencies:**

Dependencies can include conditional logic using `when` statements, enabling context-sensitive dependency resolution:

```yaml
---
dependencies:
  - role: selinux
    when: ansible_selinux.status == "enabled"
  
  - role: firewall
    when: firewall_enabled | default(true)
  
  - role: backup_client
    when: backup_enabled | default(false)
```

**Dependency Variable Passing:**

Variables can be passed to dependencies, allowing customization of dependency behavior for specific use cases:

```yaml
---
dependencies:
  - role: nginx
    vars:
      nginx_sites:
        - name: "{{ app_name }}"
          template: app.conf.j2
          listen_port: "{{ app_port }}"
      nginx_remove_default_vhost: true
```

**Dependency Best Practices:**

Dependencies should remain minimal and focused on essential prerequisites. Excessive dependencies create complex execution graphs that become difficult to debug and maintain. Consider whether functionality truly requires a dependency relationship or could be implemented through explicit playbook orchestration.

Dependencies should use stable, well-tested roles to avoid cascading failures. Role authors should document dependencies clearly and specify version requirements when appropriate.

**Avoiding Dependency Conflicts:**

When multiple roles depend on the same base role with different variable requirements, conflicts may arise. Use conditional logic and careful variable naming to prevent conflicts:

```yaml
---
dependencies:
  - role: common
    vars:
      common_packages: "{{ base_packages + role_specific_packages }}"
    when: common_packages is defined
```

