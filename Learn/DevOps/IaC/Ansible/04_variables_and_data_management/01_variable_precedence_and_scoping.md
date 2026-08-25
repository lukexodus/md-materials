## Variable Precedence and Scoping


Ansible follows a strict variable precedence hierarchy that determines which variable value takes priority when the same variable is defined in multiple locations. This precedence system ensures predictable behavior and allows for sophisticated override patterns.

The complete precedence order from lowest to highest priority includes:

Command line values through `-e` or `--extra-vars` hold the highest precedence, making them ideal for runtime overrides and CI/CD pipeline integration. Task variables defined within individual tasks come next, followed by block variables that apply to groups of tasks. Play variables affect entire playbooks, while role variables provide defaults for reusable components.

Inventory variables split into host-specific and group-specific categories, with host variables taking precedence over group variables. Facts gathered by Ansible's setup module can be overridden by explicitly set variables. Connection variables control how Ansible connects to managed hosts, while role defaults provide fallback values when no other variable source defines a value.

**Key points** about variable scoping include the understanding that variables exist within specific contexts. Play-scoped variables remain available throughout a playbook's execution, while task-scoped variables only exist within their immediate context. Host-scoped variables attach to specific inventory hosts, and global variables apply across all execution contexts.

Variable inheritance follows logical patterns where child groups inherit variables from parent groups, and individual hosts inherit from their associated groups. This inheritance model supports hierarchical organization patterns common in enterprise environments.

