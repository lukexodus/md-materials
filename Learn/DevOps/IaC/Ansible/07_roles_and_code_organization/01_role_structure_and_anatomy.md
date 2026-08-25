## Role Structure and Anatomy


Ansible roles follow a predefined directory structure that organizes different components of automation logic into distinct, purpose-specific locations. This standardized layout enables Ansible to automatically locate and load role components without explicit path specifications.

**Standard Role Directory Structure:**

```
role_name/
├── tasks/
│   └── main.yml
├── handlers/
│   └── main.yml
├── templates/
├── files/
├── vars/
│   └── main.yml
├── defaults/
│   └── main.yml
├── meta/
│   └── main.yml
├── library/
├── module_utils/
├── lookup_plugins/
└── README.md
```

**Directory Functions:**

**tasks/** contains the primary automation logic executed when the role runs. The `main.yml` file serves as the entry point, though additional task files can be included using `include_tasks` or `import_tasks` directives. Tasks within roles execute in the order specified in `main.yml`.

**handlers/** stores event-driven tasks triggered by notify statements from other tasks. Handlers typically manage service restarts, configuration reloads, or other actions that should occur only when changes are detected. The `main.yml` file contains handler definitions accessible throughout the role.

**templates/** houses Jinja2 template files used by the `template` module to generate dynamic configuration files. Templates can access role variables, facts, and other contextual information to produce customized output for specific hosts or environments.

**files/** contains static files deployed using the `copy` module. Unlike templates, files are transferred without modification, making this directory suitable for binaries, certificates, or configuration files that don't require dynamic content.

**vars/** defines variables with higher precedence than defaults. Variables in `vars/main.yml` typically contain values that should remain consistent across role usage, such as package names, configuration paths, or other role-specific constants.

**defaults/** establishes default variable values that can be overridden by users of the role. This directory provides sensible defaults while allowing customization for specific use cases. Default variables have the lowest precedence in Ansible's variable hierarchy.

**meta/** contains role metadata including dependencies, supported platforms, and descriptive information. The `main.yml` file specifies role dependencies that Ansible resolves automatically before role execution.

**library/** stores custom modules specific to the role. These modules become available for use within the role's tasks without requiring separate installation or configuration.

**module_utils/** contains Python utility code shared among custom modules within the role. This directory enables code reuse and modular development of complex custom functionality.

**lookup_plugins/** houses custom lookup plugins that extend Ansible's data retrieval capabilities within the role context.

**Role Loading Mechanism:**

Ansible searches for roles in multiple locations following a specific precedence order:
1. Roles directory relative to the playbook (`./roles/`)
2. System-wide roles directory (`/etc/ansible/roles/`)
3. User roles directory (`~/.ansible/roles/`)
4. Paths specified in `ansible.cfg` via `roles_path` parameter
5. Collections-based roles

When a role is referenced in a playbook, Ansible automatically loads components from the appropriate directories within the role structure. This automatic loading eliminates the need for explicit path specifications in most scenarios.

