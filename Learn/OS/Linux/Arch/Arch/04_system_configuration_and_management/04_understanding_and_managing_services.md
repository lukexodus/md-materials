## Understanding and Managing Services


### systemctl Overview

**Purpose**: Systemctl is the command-line interface for managing systemd services, units, and the init system. It provides comprehensive control over system services, enabling users to start, stop, enable, disable, and monitor service states.[1][2][3]

**Authority**: Most service management commands require root privileges through sudo. User-level services can be managed without root by individual users.[3][4]

### Service Status and Information

**Service Status**: `systemctl status [service]` displays comprehensive service state information.[2][3]

**Output Includes**:[2]
- Service name and description[2]
- Load state (loaded, not-found)[2]
- Active state (active/running, inactive/dead, failed)[2]
- Process ID (PID) of main process[2]
- Memory and CPU usage[2]
- Recent log entries[2]

**Example Output**:[2]

```
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: disabled)
     Active: active (running) since Mon 2024-01-15 10:23:45 UTC; 5 days ago
    Process: 1234 ExecStart=/usr/bin/nginx -g daemon off; (code=exited, status=0/SUCCESS)
   Main PID: 1235 (nginx)
     Memory: 12.5M
     CPU: 2.3s
```

**List All Services**: `systemctl list-units --type=service` displays all active services.[5][2]

**List Failed Services**: `systemctl list-units --type=service --failed` shows services that encountered errors.[5]

### Service Control Commands

**Start Service**: `sudo systemctl start [service]` immediately starts the service in the current session.[3][5][2]

**Stop Service**: `sudo systemctl stop [service]` halts the service.[3][5][2]

**Restart Service**: `sudo systemctl restart [service]` stops and starts the service sequentially.[3][2]

**Reload Configuration**: `sudo systemctl reload [service]` reloads the service's configuration files without restarting. This minimizes downtime for services supporting configuration reloading.[3][2]

**Reload or Restart**: `sudo systemctl reload-or-restart [service]` attempts to reload; if unsupported, the service restarts.[3]

**Reexec (Advanced)**: `sudo systemctl reexec` reexecutes the systemd manager itself, useful after systemd package updates.[2]

### Boot-Time Configuration

**Enable Service**: `sudo systemctl enable [service]` configures the service to start automatically at boot.[3][2]

**Implementation**: Creates a symbolic link in `/etc/systemd/system/[target].wants/` directory, typically `multi-user.target.wants/`.[3][2]

**Enable and Start**: `sudo systemctl enable --now [service]` enables at boot and immediately starts.[3][2]

**Disable Service**: `sudo systemctl disable [service]` prevents automatic startup at boot.[3][2]

**Implementation**: Removes the symbolic link created by enable.[2]

**Check Status**: `systemctl is-enabled [service]` returns whether the service is enabled or disabled.[2]

### Advanced Service Management

**Mask Service**: `sudo systemctl mask [service]` completely prevents a service from starting, even if dependencies require it.[2]

**Implementation**: Creates a symbolic link from the service file to `/dev/null`.[2]

**Unmask Service**: `sudo systemctl unmask [service]` removes the mask and allows normal operation.[2]

**Reload Daemon**: `sudo systemctl daemon-reload` reloads systemd manager configuration.[3][2]

**Purpose**: Must be executed after creating, modifying, or deleting unit files in `/etc/systemd/system/` or `/usr/lib/systemd/system/`.[2]

### Service Logging

**View Service Logs**: `journalctl -u [service]` displays logs for a specific service using the systemd journal.[5][2]

**Common Options**:[5][2]
- **`-f`**: Follows log output in real-time, displaying new entries as generated[2]
- **`--since "YYYY-MM-DD HH:MM:SS"`**: Shows logs since specified date/time[2]
- **`--until "YYYY-MM-DD HH:MM:SS"`**: Shows logs until specified date/time[2]
- **`-n [number]`**: Displays the last N log lines[5]
- **`-p [level]`**: Filters by log level (err, warning, info, debug)[5]

**Example**:[2]

```
journalctl -u nginx.service -n 50 -f
```

This displays the last 50 lines of nginx logs and follows new entries.[2]

### Service Dependencies

**After Directive**: `After=network.target` specifies that the service should start after specified units.[2]

**Requires Directive**: `Requires=network.target` mandates that specified units must also start; failure of required units prevents service start.[2]

**Wants Directive**: `Wants=optional-service` requests optional dependencies; service starts even if dependencies fail.[2]

### Querying Service Information

**Unit File Path**: `systemctl cat [service]` displays the complete unit file.[2]

**Show Unit Properties**: `systemctl show [service]` lists all properties and current values.[2]

**Show Specific Property**: `systemctl show -p [property] [service]` displays a specific property.[2]

### Service Targets and Runlevels

**Multi-User Target**: `systemctl get-default` shows the default boot target.[2]

**Set Default Target**: `sudo systemctl set-default graphical.target` configures the default boot target.[2]

**Available Targets**:[2]
- **`graphical.target`**: GUI environment with multi-user support[2]
- **`multi-user.target`**: Multi-user text mode without GUI[2]
- **`rescue.target`**: Minimal single-user mode with emergency shell[2]
- **`poweroff.target`**: System shutdown[2]
- **`reboot.target`**: System reboot[2]
- **`suspend.target`**: System suspend[2]
- **`hibernate.target`**: System hibernation[2]

### User-Level Services

**User Services**: Systemd supports per-user service instances managed by individual users.[4]

**Location**: User service files in `~/.config/systemd/user/`.[4]

**Management**: `systemctl --user [command] [service]` manages user services.[4]

**Enable User Service**: `systemctl --user enable [service]` enables user-level service.[4]

**Start User Service**: `systemctl --user start [service]` starts user-level service.[4]

**List User Services**: `systemctl --user list-units --type=service` lists active user services.[4]

### Creating Custom Services

**Service File Location**: Create custom services in `/etc/systemd/system/` for system-wide services.[2]

**Basic Structure**:[5][2]

```
[Unit]
Description=My Custom Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/myservice
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Key Sections**:[5][2]
- **`[Unit]`**: Metadata and dependencies[2]
- **`[Service]`**: Runtime behavior and execution[2]
- **`[Install]`**: Boot-time installation directives[2]

**Load New Service**: After creating the unit file, execute `sudo systemctl daemon-reload`.[3][2]

**Enable New Service**: `sudo systemctl enable --now mycustom.service` enables and starts.[2]

### Service Type Specifications

**Type=simple**: Default; service runs in foreground. Systemd considers it started immediately after ExecStart.[5]

**Type=forking**: Service forks into background; systemd waits for process parent to exit.[5]

**Type=oneshot**: Executes once and exits; useful for startup/shutdown scripts.[5]

**Type=notify**: Service notifies systemd when startup is complete.[5]

### Practical Service Management Workflow

**Install Service Package**: `sudo pacman -S nginx`.[3]

**Check Status**: `systemctl status nginx`.[3]

**Start Service**: `sudo systemctl start nginx`.[3]

**Enable at Boot**: `sudo systemctl enable nginx`.[3]

**View Logs**: `journalctl -u nginx -f`.[3]

**Modify Configuration**: Edit service configuration files.[3]

**Reload Service**: `sudo systemctl reload nginx`.[3]

**Disable at Boot**: `sudo systemctl disable nginx`.[3]

### Troubleshooting Common Issues

**Service Failed**: Check logs with `journalctl -u [service] -n 50` to identify errors.[2]

**Service Not Starting**: Verify unit file syntax with `systemctl cat [service]`.[2]

**Dependency Issues**: Check required services with `systemctl show -p Requires [service]`.[2]

**Permission Denied**: Ensure command is preceded by `sudo` for system services.[3]

**Service Hangs**: Use `systemctl kill [service]` to forcefully terminate.[2]

Sources
[1] systemd - ArchWiki https://wiki.archlinux.org/title/Systemd
[2] How to Enable and Manage systemd Services on Arch Linux https://www.siberoloji.com/how-to-enable-and-manage-systemd-services-on-arch-linux/
[3] How to use systemctl to manage services and units https://www.ionos.com/digitalguide/server/configuration/systemctl/
[4] systemd/User - ArchWiki https://wiki.archlinux.org/title/Systemd/User
[5] Managing systemd Services: Install, Start, Stop, Pause, and ... https://sphere10.com/articles/how-to/linux/managing-systemd-services-install-start-stop-pause-and-resume

