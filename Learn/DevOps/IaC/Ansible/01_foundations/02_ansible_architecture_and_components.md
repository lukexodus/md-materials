## Ansible Architecture and Components


Ansible's architecture centers on a control node that executes automation tasks against managed nodes through secure communication protocols. The control node houses the Ansible engine, which interprets playbooks and orchestrates task execution across the target infrastructure.

The control node requires Python 2.7 or Python 3.5+ and cannot run on Windows systems, though it can manage Windows targets. Managed nodes require minimal prerequisites: SSH access and Python 2.6+ or Python 3.5+ for Unix-like systems, or PowerShell 3.0+ and .NET Framework 4.0+ for Windows systems.

**Core Components:**

**Ansible Engine** processes playbooks and manages execution flow, handling task distribution, result collection, and error handling across managed infrastructure.

**Inventory** defines the hosts and groups that Ansible manages, supporting static files, dynamic scripts, or cloud provider integrations. Inventory can include variables, connection parameters, and grouping hierarchies that influence task execution.

**Modules** represent discrete units of work executed on managed nodes. Ansible includes over 3,000 modules covering system administration, cloud provisioning, network configuration, and application deployment scenarios.

**Playbooks** contain ordered lists of tasks written in YAML format, defining the desired configuration state for managed systems. Playbooks support variables, conditionals, loops, and handlers for complex automation scenarios.

**Tasks** represent individual module executions with specific parameters. Tasks run sequentially by default but support parallel execution and conditional logic.

**Handlers** provide event-driven task execution, typically used for service restarts or configuration reloads triggered by configuration changes.

**Variables** enable dynamic content in playbooks through host-specific, group-specific, or globally defined values. Variable precedence rules determine which values take effect when multiple definitions exist.

**Templates** use Jinja2 templating engine to generate dynamic configuration files based on variables and conditional logic.

The execution model follows a predictable pattern: Ansible reads inventory to identify target hosts, generates Python modules based on task definitions, transfers modules to managed nodes via SSH/WinRM, executes modules remotely, collects results, and removes temporary files.

