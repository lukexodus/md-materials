## Service Management


### Service Control with systemctl

The `systemctl` command is the primary interface for controlling systemd services on modern Linux distributions. It provides comprehensive control over system services, including starting, stopping, enabling, and disabling services.

**Basic service control commands:**

- `systemctl start service-name` - Starts a service immediately
- `systemctl stop service-name` - Stops a running service
- `systemctl restart service-name` - Stops and then starts a service
- `systemctl reload service-name` - Reloads service configuration without stopping
- `systemctl enable service-name` - Enables service to start at boot
- `systemctl disable service-name` - Prevents service from starting at boot
- `systemctl mask service-name` - Completely disables a service, preventing manual or automatic starts
- `systemctl unmask service-name` - Removes masking from a service

**Advanced control options:**

- `systemctl reload-or-restart service-name` - Attempts reload, falls back to restart if reload unavailable
- `systemctl isolate target-name` - Switches to a specific target, stopping services not required by that target
- `systemctl rescue` - Switches to rescue mode
- `systemctl emergency` - Switches to emergency mode

### Service Status Checking

Monitoring service status is crucial for system administration and troubleshooting. The `systemctl status` command provides detailed information about service states.

**Status checking commands:**

- `systemctl status service-name` - Shows detailed status of a specific service
- `systemctl is-active service-name` - Returns whether service is currently running
- `systemctl is-enabled service-name` - Returns whether service is enabled for boot
- `systemctl is-failed service-name` - Returns whether service is in failed state
- `systemctl list-units --type=service` - Lists all loaded services
- `systemctl list-units --type=service --state=running` - Lists only running services
- `systemctl list-units --type=service --state=failed` - Lists failed services

**Status output interpretation:** The status output includes several key components:

- **Loaded state**: Shows if the service unit file is loaded and its location
- **Active state**: Indicates if the service is active, inactive, or failed
- **Main PID**: Process ID of the main service process
- **Tasks**: Number of tasks associated with the service
- **Memory usage**: Current memory consumption
- **CGroup**: Control group hierarchy showing related processes
- **Recent log entries**: Last few log messages related to the service

**Service states explained:**

- `active (running)` - Service is currently executing
- `active (exited)` - Service completed successfully and is not running
- `active (waiting)` - Service is active but waiting for an event
- `inactive (dead)` - Service is not running
- `failed` - Service failed to start or crashed
- `activating` - Service is in the process of starting
- `deactivating` - Service is in the process of stopping

### Service Dependencies

Understanding service dependencies is essential for proper system management. Services often depend on other services, targets, or system resources to function correctly.

**Dependency types:**

- **Requires**: Hard dependency - if the required unit fails, this unit fails
- **Wants**: Soft dependency - failure of wanted unit doesn't affect this unit
- **Before/After**: Ordering dependencies - controls startup/shutdown sequence
- **Conflicts**: Negative dependency - units cannot run simultaneously
- **BindsTo**: Similar to Requires but also stops if the bound unit stops unexpectedly
- **PartOf**: When the specified unit stops, this unit stops too

**Viewing dependencies:**

- `systemctl list-dependencies service-name` - Shows what the service depends on
- `systemctl list-dependencies service-name --reverse` - Shows what depends on the service
- `systemctl list-dependencies service-name --all` - Shows complete dependency tree
- `systemctl show service-name` - Displays all unit properties including dependencies

**Dependency management:** Service unit files define dependencies in the `[Unit]` section. Common dependency directives include:

```
[Unit]
Description=Example Service
Requires=network.target
After=network.target
Wants=postgresql.service
Conflicts=conflicting-service.service
```

**Target dependencies:** Services often depend on system targets that represent system states:

- `basic.target` - Basic system services
- `network.target` - Network connectivity
- `multi-user.target` - Multi-user system
- `graphical.target` - Graphical user interface
- `sysinit.target` - System initialization

### Service Troubleshooting

Effective service troubleshooting requires systematic analysis of service states, logs, and system resources. Multiple tools and techniques help identify and resolve service issues.

**Initial diagnosis steps:**

1. Check service status with `systemctl status service-name`
2. Review recent logs using `journalctl -u service-name`
3. Examine system resource usage
4. Verify configuration file syntax
5. Check file permissions and ownership

**Log analysis with journalctl:**

- `journalctl -u service-name` - Shows all logs for the service
- `journalctl -u service-name --since "1 hour ago"` - Recent logs
- `journalctl -u service-name -f` - Follow logs in real-time
- `journalctl -u service-name -p err` - Error-level messages only
- `journalctl -u service-name --no-pager` - Output without pagination
- `journalctl -xe` - Recent system logs with explanations

**Common troubleshooting scenarios:**

**Service fails to start:**

- Check for syntax errors in configuration files
- Verify required dependencies are available
- Examine file permissions on service binaries and configuration
- Check if required ports are already in use
- Review SELinux or AppArmor policies if applicable

**Service crashes repeatedly:**

- Analyze core dumps if available
- Check system resource limits
- Examine application-specific logs
- Monitor memory and CPU usage during operation
- Verify library dependencies are satisfied

**Service performance issues:**

- Monitor resource consumption with `systemctl show service-name`
- Use `systemd-cgtop` to view resource usage by cgroup
- Check for memory leaks or excessive CPU usage
- Analyze network connectivity if service is network-dependent

**Configuration validation:**

- Use `systemctl daemon-reload` after modifying unit files
- Validate configuration syntax with service-specific tools
- Test configuration changes in development environment first
- Use `systemctl cat service-name` to view the complete unit file

**Emergency recovery:**

- Boot into rescue mode if critical services fail
- Use `systemctl --failed` to identify all failed services
- Disable problematic services temporarily with `systemctl mask`
- Access emergency shell if system becomes unresponsive

**Debugging techniques:**

- Enable debug logging in service configuration
- Use `strace` to trace system calls made by service processes
- Monitor file system access with `inotify` tools
- Use `lsof` to check open files and network connections
- Examine environment variables with `systemctl show-environment`

**Key points** for effective service troubleshooting include maintaining detailed logs, understanding service dependencies, monitoring system resources, and having a systematic approach to problem diagnosis. Regular monitoring and proactive maintenance help prevent many service-related issues.

---

