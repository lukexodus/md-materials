## Overview

{% endblock %}

{% block custom_config %}
{% endblock %}

{# nginx_config.j2 #}
{% extends "base_config.j2" %}
{% block main_config %}
server {
    listen {{ http_port | default(80) }};
    server_name {{ server_name | default(inventory_hostname) }};
    {% block server_config %}
    root {{ document_root }};
    index index.html index.php;
    {% endblock %}
}
{% endblock %}
```

Macros enable reusable template components that accept parameters and generate consistent output patterns. These function-like constructs reduce code duplication and enable complex configuration patterns to be abstracted into maintainable components.

Complex control structures support nested conditionals, multiple loop types, and exception handling within templates. Loop controls include `loop.index`, `loop.first`, `loop.last`, and `loop.length` variables that enable position-aware template logic. The `loop.previtem` and `loop.nextitem` variables provide access to adjacent iteration values.

Custom filters extend Jinja2's built-in transformation capabilities with domain-specific logic. Ansible includes numerous specialized filters for network operations, data structure manipulation, and system-specific transformations. The `regex_replace`, `regex_search`, and `regex_findall` filters provide powerful text processing capabilities.

**Key points** for advanced templating include understanding template context scope, implementing proper error handling with `default` filters and `ignore undefined` settings, and leveraging template debugging techniques using the `debug` filter and template comments.

Set operations within templates enable complex data manipulation using `union`, `intersect`, `difference`, and `symmetric_difference` filters. These operations support dynamic group membership calculations and configuration merging scenarios.

Template testing provides conditional logic based on data type checking, value validation, and complex boolean expressions. Built-in tests include `defined`, `undefined`, `none`, `number`, `string`, `mapping`, and `sequence`, while custom tests can be created for domain-specific validation requirements.

## Template Module Usage

The template module serves as Ansible's primary mechanism for generating configuration files from Jinja2 templates, offering extensive options for file handling, validation, backup management, and deployment control.

Basic template deployment involves specifying source template paths and destination file locations, with automatic template rendering using the current variable context. The module supports both absolute and relative path specifications, with relative paths resolved against the playbook directory structure.

Template validation enables pre-deployment verification using custom validation commands that test generated configuration files before deployment. This feature prevents deployment of invalid configurations that could disrupt system operations.

**Example** of comprehensive template usage:

```yaml
- name: Deploy nginx configuration
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
    backup: true
    validate: 'nginx -t -c %s'
  notify: restart nginx
  tags: configuration

- name: Generate application config with custom delimiter
  template:
    src: app.properties.j2
    dest: /opt/app/config/application.properties
    variable_start_string: '[['
    variable_end_string: ']]'
    block_start_string: '[%'
    block_end_string: '%]'
```

Backup functionality automatically creates timestamped copies of existing files before template deployment, enabling rollback capabilities and change tracking. Backup files use standardized naming conventions that include timestamps and can be managed through retention policies.

Custom template delimiters accommodate scenarios where default Jinja2 syntax conflicts with target file formats. This capability enables template processing of files that naturally contain curly braces or percent signs without escaping requirements.

**Key points** include understanding template module's integration with handlers for service management, implementing proper file permission management, and leveraging validation commands for configuration integrity verification.

Force deployment controls whether templates overwrite existing files when content changes occur. This setting provides fine-grained control over deployment behavior in scenarios where manual modifications might exist on target systems.

Template module performance optimization includes understanding when template rendering occurs, minimizing complex template logic, and leveraging template caching mechanisms for repeated deployments across multiple hosts.

## File Operations

Ansible provides comprehensive file operation modules that handle copying, fetching, synchronizing, and manipulating files across managed infrastructure with support for complex filtering, permission management, and content validation.

The copy module handles file deployment from control nodes to managed hosts with support for content validation, backup creation, and permission management. Unlike the template module, copy handles static files without template processing, making it suitable for binary files, certificates, and pre-rendered configurations.

Advanced copy operations support directory recursion, file filtering based on patterns, and selective synchronization based on checksums or timestamps. The module integrates with Ansible Vault for encrypted file deployment and supports remote source locations through delegation.

**Example** of advanced file operations:

```yaml
- name: Deploy SSL certificates
  copy:
    src: "{{ item }}"
    dest: /etc/ssl/certs/
    owner: root
    group: ssl-cert
    mode: '0644'
    backup: true
  with_fileglob:
    - "certificates/*.crt"
  notify: reload web server

- name: Fetch log files for analysis
  fetch:
    src: /var/log/application.log
    dest: ./collected-logs/{{ inventory_hostname }}/
    flat: false
    validate_checksum: true
  when: collect_logs | default(false)
```

The fetch module retrieves files from managed hosts to the control node, supporting centralized log collection, configuration backup, and forensic analysis workflows. Fetch operations include checksum validation and support both flat and hierarchical destination directory structures.

Synchronize module leverages rsync for efficient file synchronization between control nodes and managed hosts or between managed hosts. This module provides advanced filtering, compression, and delta synchronization capabilities suitable for large file sets and bandwidth-constrained environments.

File module handles file and directory attribute management including ownership, permissions, symbolic links, and file system properties. This module supports both absolute and symbolic permission specifications with validation of target file existence and type.

**Key points** for file operations include understanding the performance implications of different synchronization methods, implementing proper error handling for file system operations, and leveraging checksum validation for integrity verification.

Archive and unarchive modules provide compression and extraction capabilities with support for multiple archive formats including tar, gzip, bzip2, and zip. These modules integrate with remote source locations and support selective extraction based on file patterns.

## Directory and File Permissions

Permission management in Ansible encompasses traditional Unix permissions, extended attributes, SELinux contexts, and Access Control Lists (ACLs), providing comprehensive security control over file system objects.

Numeric permission modes use octal notation where each digit represents owner, group, and other permissions respectively. Symbolic permission modes use human-readable notation with user classes (u/g/o/a) and permission types (r/w/x) combined with operators (+/-/=).

**Example** of comprehensive permission management:

```yaml
- name: Create secure application directory
  file:
    path: /opt/secure-app
    state: directory
    owner: app-user
    group: app-group
    mode: '0750'
    recurse: true
    setype: admin_home_t  # SELinux context
  
- name: Set ACL for shared directory
  acl:
    path: /shared/data
    entity: developers
    etype: group
    permissions: rwx
    state: present
    recursive: true
```

SELinux integration provides mandatory access control through security contexts that define how processes and files interact within the system security policy. Ansible modules support SELinux context management through the `setype`, `seuser`, and `serole` parameters.

Access Control Lists extend traditional Unix permissions with fine-grained access control for multiple users and groups on individual files and directories. The acl module manages both standard and default ACLs with support for recursive application and inheritance.

Special permission bits including setuid, setgid, and sticky bits provide additional security and functional capabilities. These permissions require careful management to maintain system security while enabling required functionality.

**Key points** include understanding permission inheritance patterns, implementing least-privilege principles, and validating permission changes across diverse Unix-like operating systems with varying default behaviors.

File attribute management extends beyond basic permissions to include extended attributes, immutable flags, and file system-specific properties. These attributes provide additional security layers and functional controls over file system objects.

Permission troubleshooting involves understanding how different permission systems interact, identifying permission conflicts, and implementing diagnostic procedures for permission-related access issues.

## Line-in-File and Block-in-File Operations

Ansible's lineinfile and blockinfile modules provide surgical modification capabilities for existing configuration files, enabling targeted changes without full file replacement while maintaining existing content and structure.

The lineinfile module manages individual lines within files using regular expressions for matching and replacement. This module supports insertion, modification, and deletion operations with precise control over line positioning and content validation.

Advanced lineinfile operations include backreference support for complex text transformations, multiple line matching with firstmatch parameters, and conditional operations based on file content or system state.

**Example** of sophisticated line operations:

```yaml
- name: Update kernel parameters
  lineinfile:
    path: /etc/sysctl.conf
    regexp: '^net\.ipv4\.ip_forward'
    line: 'net.ipv4.ip_forward = 1'
    backup: true
    validate: 'sysctl -p %s'

- name: Remove deprecated configuration
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?PermitRootLogin'
    state: absent
  notify: restart sshd

- name: Add host entry with validation
  lineinfile:
    path: /etc/hosts
    line: "{{ hostvars[item]['ansible_default_ipv4']['address'] }} {{ item }}"
    regexp: "^{{ hostvars[item]['ansible_default_ipv4']['address'] }}"
    backup: true
  loop: "{{ groups['database_servers'] }}"
```

The blockinfile module manages multi-line content blocks within files using customizable markers to identify managed sections. This approach enables complex configuration block insertion while preserving surrounding file content.

Block operations support custom marker formats, content validation, and backup creation. The module automatically manages block boundaries and handles marker updates when block content changes.

**Key points** for line and block operations include implementing proper backup strategies, using validation commands to prevent configuration errors, and understanding how regular expressions interact with file content matching.

Replace module provides global text replacement within files using regular expressions with support for backreferences and multiline patterns. This module complements lineinfile and blockinfile for scenarios requiring broader text transformations.

Idempotency considerations require careful regular expression design to ensure operations produce consistent results across multiple executions. Pattern matching should be specific enough to avoid unintended modifications while flexible enough to handle content variations.

## Configuration File Management

Configuration file management encompasses the complete lifecycle of system configuration including generation, deployment, validation, versioning, and rollback capabilities across diverse application and system types.

Template-driven configuration management uses standardized templates with environment-specific variable files to generate consistent configurations across different deployment environments. This approach enables version control of configuration logic while maintaining environment-specific customization.

Configuration validation strategies include syntax checking, functional testing, and integration validation before deployment. Multi-stage validation processes prevent invalid configurations from reaching production systems while providing detailed error reporting for troubleshooting.

**Example** of comprehensive configuration management:

```yaml
- name: Manage database configuration
  block:
    - name: Generate database config from template
      template:
        src: postgresql.conf.j2
        dest: /tmp/postgresql.conf.new
        validate: 'postgres --check-config -f %s'
      
    - name: Backup current configuration
      copy:
        src: /etc/postgresql/postgresql.conf
        dest: "/etc/postgresql/postgresql.conf.{{ ansible_date_time.epoch }}"
        remote_src: true
      
    - name: Deploy new configuration
      copy:
        src: /tmp/postgresql.conf.new
        dest: /etc/postgresql/postgresql.conf
        remote_src: true
        owner: postgres
        group: postgres
        mode: '0644'
      notify: restart postgresql
      
    - name: Clean up temporary file
      file:
        path: /tmp/postgresql.conf.new
        state: absent
  rescue:
    - name: Configuration deployment failed
      debug:
        msg: "Configuration deployment failed, check validation errors"
      failed_when: true
```

Configuration drift detection compares deployed configurations against expected states using checksums, content comparison, or external validation tools. Automated drift detection enables proactive configuration management and compliance monitoring.

Rollback strategies provide mechanisms for reverting configuration changes when problems occur. These strategies include maintaining configuration backups, implementing configuration versioning, and providing automated rollback procedures.

**Key points** include implementing configuration testing in isolated environments, maintaining configuration change logs, and establishing approval workflows for critical system configurations.

Multi-environment configuration management uses hierarchical variable structures and template inheritance to maintain consistent configuration patterns while accommodating environment-specific requirements. This approach reduces configuration drift between environments while enabling necessary customization.

Configuration security encompasses protecting sensitive configuration data, implementing access controls for configuration files, and maintaining audit trails for configuration changes. Ansible Vault integration provides encryption capabilities for sensitive configuration parameters.

**Output** from effective template and file management includes consistent system configurations, reduced manual intervention, improved change tracking, and reliable rollback capabilities that support operational stability.

**Conclusion**

Advanced template and file management in Ansible requires mastering Jinja2 templating capabilities, understanding file operation modules, and implementing comprehensive configuration management strategies. These capabilities enable sophisticated automation while maintaining system reliability and security.

**Next steps** should focus on implementing configuration validation frameworks, establishing configuration versioning strategies, and integrating with external configuration management tools for enterprise-scale deployments.


---

# Custom Development

Custom development extends Ansible's core functionality through modules, plugins, and specialized components that address unique automation requirements beyond standard module capabilities. This advanced development approach enables organizations to create tailored solutions while maintaining consistency with Ansible's architectural patterns.

## Custom Modules Development

Custom modules encapsulate specific automation logic as discrete, reusable components that integrate seamlessly with Ansible's execution framework. Module development requires understanding Ansible's module architecture, communication protocols, and development conventions.

**Module Architecture Overview:**

Ansible modules execute as separate processes on managed nodes, receiving parameters through JSON input and returning structured results via JSON output. The Ansible controller transfers module code to target systems, executes modules within isolated environments, and processes returned data for subsequent task operations.

**Module Communication Pattern:**

```python
#!/usr/bin/python
