## Host and Group Variables


Host and group variables provide the foundation for inventory-based configuration management, allowing administrators to define system-specific and environment-specific settings that Ansible applies automatically based on inventory membership.

Individual host variables attach directly to specific inventory entries and override all group-level settings. These variables handle unique configurations like IP addresses, hostnames, custom ports, or system-specific parameters that don't apply broadly across multiple systems.

Group variables apply to all hosts within defined inventory groups, supporting logical organization patterns like environment separation (development, staging, production), geographic distribution (us-east, eu-west), or functional roles (webservers, databases, load-balancers).

Nested group structures enable sophisticated inheritance patterns where child groups automatically inherit parent group variables while maintaining the ability to override specific values. This hierarchical approach reduces configuration duplication and supports complex infrastructure topologies.

**Example** of effective group variable organization:

```yaml
# group_vars/all.yml
ntp_servers:
  - pool.ntp.org
  - time.google.com

# group_vars/production.yml
environment: production
backup_retention_days: 90

# group_vars/webservers.yml
apache_max_clients: 256
ssl_certificate_path: /etc/ssl/certs
```

Variable composition allows combining multiple group memberships where hosts belonging to multiple groups inherit variables from all associated groups, with precedence rules resolving conflicts predictably.

