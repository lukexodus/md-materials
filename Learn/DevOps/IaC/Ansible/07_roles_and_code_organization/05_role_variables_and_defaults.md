## Role Variables and Defaults


Role variables provide the primary mechanism for customizing role behavior and adapting automation logic to diverse environments. Understanding variable types, precedence, and best practices enables creation of flexible, reusable roles.

**Variable Types in Roles:**

**Default Variables** (`defaults/main.yml`) provide baseline values that users can override. These variables have the lowest precedence in Ansible's variable hierarchy, making them ideal for user-customizable settings:

```yaml
---
# Web server defaults
web_server_port: 80
web_server_ssl_port: 443
web_server_document_root: /var/www/html
web_server_max_connections: 100
web_server_timeout: 30

# Package defaults
web_server_packages:
  - apache2
  - apache2-utils

# Feature flags
web_server_ssl_enabled: false
web_server_compression_enabled: true
web_server_security_headers_enabled: true
```

**Role Variables** (`vars/main.yml`) contain values that should remain consistent across role usage. These variables have higher precedence than defaults and typically include system-specific constants:

```yaml
---
# System paths (should not be changed by users)
web_server_config_dir: /etc/apache2
web_server_log_dir: /var/log/apache2
web_server_pid_file: /var/run/apache2/apache2.pid

# Service management
web_server_service_name: apache2
web_server_user: www-data
web_server_group: www-data

# OS-specific package mappings
web_server_packages_redhat:
  - httpd
  - httpd-tools
web_server_packages_debian:
  - apache2
  - apache2-utils
```

**Variable Precedence Within Roles:**

Ansible's variable precedence affects how role variables interact with other variable sources:

1. Extra variables (`-e` command line)
2. Task variables
3. Block variables
4. Role and include variables
5. Play variables
6. Host facts and registered variables
7. Host variables (inventory)
8. Group variables (inventory)
9. Role defaults (`defaults/main.yml`)

**Variable Organization Patterns:**

**Namespace Prefixing** prevents variable name conflicts when multiple roles are used together:

```yaml
---
# Instead of generic names
port: 80
ssl_enabled: false

# Use role-specific prefixes
mysql_port: 3306
mysql_ssl_enabled: false
mysql_root_password: "{{ vault_mysql_root_password }}"
```

**Structured Variables** group related configuration options:

```yaml
---
mysql_config:
  port: 3306
  bind_address: "0.0.0.0"
  max_connections: 100
  query_cache_size: "16M"
  
mysql_users:
  - name: app_user
    password: "{{ vault_app_password }}"
    host: "%"
    privileges: "app_db.*:ALL"
  
  - name: backup_user
    password: "{{ vault_backup_password }}"
    host: "localhost"
    privileges: "*.*:SELECT,LOCK TABLES"
```

**Conditional Variable Loading:**

Roles can load different variable files based on conditions:

```yaml
---
- name: Load OS-specific variables
  include_vars: "{{ ansible_os_family }}.yml"

- name: Load version-specific variables
  include_vars: "{{ ansible_distribution }}-{{ ansible_distribution_major_version }}.yml"
  ignore_errors: yes
```

**Variable Files Organization:**

```
vars/
├── main.yml
├── RedHat.yml
├── Debian.yml
├── Ubuntu-18.yml
├── Ubuntu-20.yml
└── CentOS-7.yml
```

**Variable Validation:**

Implement variable validation to catch configuration errors early:

```yaml
---
- name: Validate required variables
  assert:
    that:
      - mysql_root_password is defined
      - mysql_root_password | length > 8
      - mysql_port is number
      - mysql_port > 1024
      - mysql_port < 65536
    fail_msg: "MySQL configuration validation failed"
    success_msg: "MySQL configuration validation passed"

- name: Validate user configuration
  assert:
    that:
      - item.name is defined
      - item.password is defined
      - item.privileges is defined
    fail_msg: "MySQL user {{ item.name | default('undefined') }} missing required fields"
  loop: "{{ mysql_users }}"
  when: mysql_users is defined
```

**Variable Documentation:**

Document variables comprehensively in role README files:

```markdown
## Role Variables

### Required Variables
- `mysql_root_password`: Root password for MySQL installation
- `mysql_databases`: List of databases to create

### Optional Variables
- `mysql_port`: MySQL port (default: 3306)
- `mysql_bind_address`: Bind address (default: 127.0.0.1)
- `mysql_max_connections`: Maximum connections (default: 100)

### Example Configuration
```yaml
mysql_root_password: "{{ vault_mysql_root_password }}"
mysql_databases:
  - name: production_app
    encoding: utf8mb4
    collation: utf8mb4_unicode_ci
mysql_users:
  - name: app_user
    password: "{{ vault_app_password }}"
    host: "%"
    privileges: "production_app.*:ALL"
```

**Advanced Variable Techniques:**

**Variable Merging** combines multiple variable sources:

```yaml
---
- name: Merge default and custom packages
  set_fact:
    final_packages: "{{ default_packages + custom_packages | default([]) }}"

- name: Install packages
  package:
    name: "{{ final_packages }}"
    state: present
```

**Dynamic Variable Generation:**

```yaml
---
- name: Generate dynamic configuration
  set_fact:
    mysql_config_final: "{{ mysql_config_defaults | combine(mysql_config_custom | default({}), recursive=True) }}"
```

## Meta Information and Platforms

Role metadata provides essential information about role requirements, supported platforms, dependencies, and descriptive details that enable proper role usage and distribution through Ansible Galaxy.

**Meta File Structure:**

The `meta/main.yml` file contains structured metadata following specific schema requirements:

```yaml
---
galaxy_info:
  author: "Your Name"
  description: "Role description"
  company: "Your Company (optional)"
  license: "MIT"
  min_ansible_version: "2.9"
  
  platforms:
    - name: EL
      versions:
        - 7
        - 8
        - 9
    
    - name: Ubuntu
      versions:
        - bionic
        - focal
        - jammy
    
    - name: Debian
      versions:
        - buster
        - bullseye
        - bookworm
  
  galaxy_tags:
    - web
    - apache
    - httpd
    - ssl

dependencies:
  - role: common
    vars:
      common_timezone: "UTC"
  
  - role: firewall
    when: firewall_enabled | default(true)
```

**Galaxy Information Fields:**

**author** identifies the role creator and serves as the primary contact for role-related questions and issues.

**description** provides a concise explanation of role functionality and purpose. This field appears in Galaxy search results and role listings.

**company** optionally identifies the organization associated with role development and maintenance.

**license** specifies the legal terms under which the role is distributed. Common choices include MIT, Apache-2.0, GPL-3.0, and BSD-3-Clause.

**min_ansible_version** defines the minimum Ansible version required for role execution. This prevents compatibility issues when roles use features unavailable in older Ansible versions.

**issue_tracker_url** provides a link to the bug tracking system where users can report problems and request features.

**github_branch** specifies the default branch for Galaxy imports when using GitHub integration.

**Platform Specification:**

Platform declarations inform users about tested and supported operating systems. Each platform entry includes a name and list of supported versions:

**Platform Names** use standardized identifiers:
- EL (Enterprise Linux - RHEL, CentOS, Rocky Linux)
- Fedora
- Ubuntu
- Debian
- SLES (SUSE Linux Enterprise Server)
- opensuse (openSUSE)
- Alpine
- ArchLinux
- FreeBSD
- MacOSX
- Windows

**Version Specifications** can use specific version numbers, codenames, or ranges:

```yaml
platforms:
  - name: Ubuntu
    versions:
      - "18.04"
      - "20.04"
      - "22.04"
      - bionic
      - focal
      - jammy
  
  - name: EL
    versions:
      - 7
      - 8
      - 9
  
  - name: Debian
    versions:
      - buster
      - bullseye
      - bookworm
      - "10"
      - "11"
      - "12"
```

**Galaxy Tags:**

Tags enable role categorization and improve discoverability within Galaxy search results. Effective tags describe role functionality, target systems, and use cases:

```yaml
galaxy_tags:
  - web
  - webserver
  - apache
  - httpd
  - ssl
  - tls
  - security
  - lamp
  - php
  - database
  - mysql
  - monitoring
  - logging
```

**Tag Guidelines:**
- Use lowercase, descriptive terms
- Include primary technology names (apache, nginx, mysql)
- Add functional categories (web, database, monitoring)
- Include protocol and security terms when relevant (ssl, tls, https)
- Avoid overly generic tags (server, linux, config)

**Advanced Metadata Features:**

**Role Collections Integration:**

```yaml
---
galaxy_info:
  namespace: company_name
  name: web_server
  version: "1.2.3"
  description: "Enterprise web server configuration"
  
  dependencies:
    - name: company_name.common
      version: ">=1.0.0"
```

**Conditional Platform Support:**

[Inference] Roles may need to declare platform-specific limitations or requirements through documentation rather than metadata, as the meta file format doesn't support conditional platform declarations.

**Version Constraints:**

```yaml
dependencies:
  - role: external_role
    version: ">=1.0.0,<2.0.0"
  
  - role: another_role
    version: "~>1.2.0"  # Compatible with 1.2.x but not 1.3.x
```

**Metadata Validation:**

Ansible Galaxy validates metadata during role import, checking for required fields, valid platform names, and proper YAML syntax. Common validation errors include:

- Missing required fields (author, description, license)
- Invalid platform names or version formats
- Malformed dependency specifications
- Circular dependency declarations

**Documentation Integration:**

Metadata complements role documentation by providing structured information that Galaxy can parse and display. Comprehensive README files should expand on metadata information with detailed usage examples, variable documentation, and implementation guidance.

**Role Versioning Strategy:**

[Inference] Effective role maintenance requires consistent versioning strategies that align with semantic versioning principles:

- Major versions (X.0.0) for breaking changes
- Minor versions (0.X.0) for new features
- Patch versions (0.0.X) for bug fixes

**Metadata Best Practices:**

Keep metadata current with role capabilities and testing coverage. Outdated platform declarations or version requirements can mislead users and cause deployment failures.

Use descriptive, accurate tags that reflect actual role functionality rather than aspirational or marketing-oriented terms.

Document platform-specific limitations or requirements in both metadata and README files to set appropriate user expectations.

Maintain dependency versions to prevent conflicts with other roles and ensure reproducible deployments across different environments.

---

# Templates and File Management

File and template management forms the backbone of configuration management in Ansible, enabling administrators to deploy, modify, and maintain system configurations across diverse infrastructure environments. Advanced templating capabilities, combined with sophisticated file operation modules, provide the tools necessary for managing complex configuration scenarios while maintaining consistency and version control.

## Jinja2 Templating Advanced Features

Advanced Jinja2 templating extends beyond basic variable substitution to include complex data manipulation, conditional logic, custom functions, and template composition patterns that enable sophisticated configuration generation.

Template inheritance creates hierarchical template structures where base templates define common patterns and child templates customize specific sections. This approach reduces duplication while maintaining consistency across similar configuration files. Base templates use block definitions that child templates can override or extend, supporting modular configuration approaches.

**Example** of template inheritance:

```jinja2
{# base_config.j2 #}
