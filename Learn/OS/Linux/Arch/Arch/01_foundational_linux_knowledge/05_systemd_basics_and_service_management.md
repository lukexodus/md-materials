## Systemd Basics and Service Management


### Overview and Architecture

**systemd** is the default system and service manager in Arch Linux, replacing the traditional SysV init system. It runs as PID 1 and initializes system components during boot while managing services throughout the system's runtime. Systemd was designed to offer faster boot times, parallelized service startup, and advanced features such as service dependencies and integrated logging.[1][3][9]

**Core Components**: Systemd manages various unit types including services, sockets, targets, devices, and timers. **Unit files** contain configurations for these components and are typically located in `/usr/lib/systemd/system/` (system-provided) or `/etc/systemd/system/` (administrator-customized). Systemd integrates with **journald**, a logging service that aggregates logs from all system services for easier management.[2][3][6]

### Basic Service Management Commands

**`systemctl status [service]`**: Displays the current state of a service, showing whether it is active, inactive, or failed. The output includes the service description, load state, active state, main process ID, memory usage, and related processes.[3]

**`systemctl start [service]`**: Immediately starts a service without affecting its auto-start configuration at boot. The service will not persist after a system reboot unless explicitly enabled.[5][6][3]

**`systemctl stop [service]`**: Immediately stops a running service.[3][5]

**`systemctl restart [service]`**: Stops and then starts the service in one operation, which is useful after configuration changes.[6][3]

**`systemctl reload [service]`**: Reloads the service's configuration files without fully restarting it, if the service supports this feature. This minimizes downtime for services that support configuration reloading.[6][3]

**`systemctl reload-or-restart [service]`**: Attempts to reload the service configuration; if reloading is not supported, it restarts the service instead.[6]

### Boot Behavior Management

**`systemctl enable [service]`**: Configures the service to start automatically when the system boots by creating a symbolic link in the appropriate target directory (typically `/etc/systemd/system/multi-user.target.wants/`). Enabling does not immediately start the service in the current session.[3][6]

**`systemctl disable [service]`**: Prevents the service from starting automatically at boot by removing the symbolic link. The service can still be manually started after boot.[3][6]

**`systemctl mask [service]`**: Prevents a service from starting entirely, even if another service depends on it, by creating a symbolic link to `/dev/null`. This is useful when you want to completely prevent a service from running under any circumstances.[3]

**`systemctl unmask [service]`**: Removes the mask and allows the service to be started normally.[3]

### Service Information and Monitoring

**`systemctl list-units --type=service`**: Lists all active services currently running on the system. This provides a comprehensive overview of service status and unit files in use.[5][3]

**`journalctl -u [service]`**: Displays logs for a specific service using the systemd journal. Common options include:[5][3]

*   **`-f`**: Follows the log output in real-time, displaying new entries as they are generated.[3]
*   **`--since "YYYY-MM-DD HH:MM:SS"`**: Shows logs since a specific date and time.[3]
*   **`--until "YYYY-MM-DD HH:MM:SS"`**: Shows logs until a specific date and time.[3]

### Custom Service Creation

**Basic Structure**: Custom systemd service unit files are placed in `/etc/systemd/system/` and contain three main sections:[5][3]

*   **`[Unit]`**: Metadata for the service, including a description and dependency specifications like `After=network.target` to define when the service should start.[5][3]
*   **`[Service]`**: Runtime behavior, including `ExecStart` (the command to execute), `Restart` (behavior on failure), and `Type` (service type).[5][3]
*   **`[Install]`**: Boot-time behavior, with `WantedBy=multi-user.target` specifying the target under which the service should be started.[5][3]

**Example Configuration**:

```
[Unit]
Description=My Custom Service
After=network.target

[Service]
ExecStart=/usr/bin/mycustomscript.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

**Implementation**: After creating the service file, reload systemd with `sudo systemctl daemon-reload` to recognize the new service. Then enable and start it using `sudo systemctl enable mycustom.service` followed by `sudo systemctl start mycustom.service`.[3]

### Important Considerations

**Start and Enable**: Simply enabling a service does not immediately start it; both `enable` and `start` commands must be executed separately to activate the service both at boot and in the current session.[6]

**Dependency Management**: Services can specify dependencies using directives like `After=` (waits for services to start) or `Requires=` (mandates that dependent services also start). This ensures proper service startup order and prevents conflicts.[3]

**User-Level Services**: Systemd offers the ability to manage services under the user's control with a per-user systemd instance, enabling users to start, stop, enable, and disable services without root privileges.[4]

Sources
[1] systemd - ArchWiki https://wiki.archlinux.org/title/Systemd
[2] systemd.service(5) - Arch manual pages https://man.archlinux.org/man/systemd.service.5.en
[3] How to Enable and Manage systemd Services on Arch Linux https://www.siberoloji.com/how-to-enable-and-manage-systemd-services-on-arch-linux/
[4] systemd/User - ArchWiki https://wiki.archlinux.org/title/Systemd/User
[5] Managing systemd Services: Install, Start, Stop, Pause, and ... https://sphere10.com/articles/how-to/linux/managing-systemd-services-install-start-stop-pause-and-resume
[6] How to use systemctl to manage services and units https://www.ionos.com/digitalguide/server/configuration/systemctl/
[7] Why did ArchLinux embrace Systemd? https://www.reddit.com/r/archlinux/comments/4lzxs3/why_did_archlinux_embrace_systemd/
[8] Moving away from Arch Linux Part 1: Systemd https://halestrom.net/darksleep/blog/005_distrohop_p1/
[9] System and Service Manager https://systemd.io

