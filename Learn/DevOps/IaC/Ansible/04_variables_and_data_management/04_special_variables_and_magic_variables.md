## Special Variables and Magic Variables


Ansible provides numerous built-in variables that expose system information, execution context, and infrastructure metadata automatically during playbook execution. These special variables eliminate the need for custom fact gathering in many scenarios while providing deep integration with Ansible's execution model.

Inventory-related magic variables include `inventory_hostname` for the current host's inventory name, `group_names` containing all groups the current host belongs to, and `groups` providing access to all inventory groups and their members. These variables enable dynamic host selection and cross-host coordination patterns.

Execution context variables like `ansible_play_hosts` list all hosts in the current play, while `ansible_play_batch` shows hosts in the current batch when using serial execution. The `hostvars` magic variable provides access to variables and facts from other hosts, enabling complex coordination scenarios.

Connection and transport variables expose details about how Ansible connects to managed hosts, including `ansible_connection`, `ansible_host`, `ansible_port`, and `ansible_user`. These variables support dynamic connection configuration and troubleshooting scenarios.

**Example** of magic variable usage:

```yaml
- name: Configure database connections
  template:
    src: database.conf.j2
    dest: /etc/app/database.conf
  vars:
    db_servers: "{{ groups['databases'] }}"
    current_env: "{{ group_names | intersect(['production', 'staging', 'development']) | first }}"
```

Fact variables beginning with `ansible_` contain discovered system information like `ansible_os_family`, `ansible_distribution`, `ansible_architecture`, and hardware details. Custom facts can extend this system with application-specific information.

