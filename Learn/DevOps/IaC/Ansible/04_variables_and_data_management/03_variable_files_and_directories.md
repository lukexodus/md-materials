## Variable Files and Directories


Ansible supports multiple approaches for organizing and loading variable files, from simple YAML files to complex directory structures that scale with infrastructure growth and organizational requirements.

The `vars_files` directive within playbooks explicitly loads variable files at play execution time, supporting both static file paths and dynamic path generation using variables. This approach works well for environment-specific configuration files or shared variable sets used across multiple playbooks.

The `include_vars` module provides runtime variable loading with conditional logic, file pattern matching, and directory traversal capabilities. This module supports dynamic variable loading based on discovered conditions, gathered facts, or runtime parameters.

Directory-based variable organization follows conventional patterns where `group_vars/` and `host_vars/` directories automatically load variables based on inventory group names and hostnames. These directories support both single files and subdirectory structures for complex variable sets.

**Key points** for variable file organization include maintaining consistent naming conventions, using environment-specific subdirectories, and implementing validation procedures for variable file syntax and content.

File naming strategies should reflect their scope and purpose. Environment-specific files might use suffixes like `vars-production.yml` or `vars-development.yml`, while functional groupings might use prefixes like `database-vars.yml` or `network-vars.yml`.

Variable file encryption using Ansible Vault protects sensitive information like passwords, API keys, and certificates while maintaining the ability to version control encrypted files safely. Vault integration supports both entire file encryption and string-level encryption for mixed-sensitivity variable files.

