## Custom Services


### Unit File Creation

**Key points:** Unit files define how systemd manages services, following a structured INI-style format with specific sections and directives.

Unit files are located in:

- `/etc/systemd/system/`: Local configuration files (highest priority)
- `/run/systemd/system/`: Runtime unit files
- `/usr/lib/systemd/system/`: Distribution package unit files

Basic unit file structure:

```ini
[Unit]
Description=Service description
Documentation=man:service(8)
After=network.target
Requires=network.target

[Service]
Type=simple
ExecStart=/path/to/executable
User=service-user
Group=service-group

[Install]
WantedBy=multi-user.target
```

**Example:** Creating a custom web application service:

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Web Application
Documentation=https://myapp.example.com/docs
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/opt/myapp/bin/myapp --config /etc/myapp/config.yaml
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=5
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

After creating unit files, reload systemd configuration:

```bash
sudo systemctl daemon-reload
sudo systemctl enable myapp.service
sudo systemctl start myapp.service
```

### Service Configuration

**Key points:** Service configuration involves multiple sections defining service behavior, dependencies, and execution parameters.

#### Unit Section Directives

Common `[Unit]` section options:

- `Description`: Human-readable service description
- `Documentation`: Links to documentation
- `After`: Services/targets to start after
- `Before`: Services/targets to start before
- `Requires`: Hard dependencies (failure stops this unit)
- `Wants`: Soft dependencies (failure doesn't affect this unit)
- `Conflicts`: Mutually exclusive units

#### Service Section Types

Service types determine process management:

- `Type=simple`: Default, main process doesn't fork
- `Type=forking`: Main process forks and parent exits
- `Type=oneshot`: Process exits after completion
- `Type=notify`: Service sends readiness notification
- `Type=idle`: Delays execution until other jobs finish

**Example:** Forking service configuration:

```ini
[Service]
Type=forking
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/bin/kill -QUIT $MAINPID
PIDFile=/run/nginx.pid
```

#### Execution Directives

Process execution control:

- `ExecStart`: Command to start service
- `ExecStartPre`: Commands before main process
- `ExecStartPost`: Commands after main process starts
- `ExecReload`: Command to reload configuration
- `ExecStop`: Command to stop service
- `ExecStopPost`: Commands after service stops

**Example:** Service with pre/post execution:

```ini
[Service]
ExecStartPre=/usr/bin/mkdir -p /var/run/myservice
ExecStartPre=/usr/bin/chown myservice:myservice /var/run/myservice
ExecStart=/usr/bin/myservice --daemon
ExecReload=/bin/kill -USR1 $MAINPID
ExecStopPost=/usr/bin/rm -rf /var/run/myservice
```

#### Restart Policies

Automatic restart configuration:

- `Restart=no`: Never restart (default)
- `Restart=always`: Always restart
- `Restart=on-success`: Restart on clean exit
- `Restart=on-failure`: Restart on unclean exit
- `Restart=on-abnormal`: Restart on signals/timeouts
- `RestartSec`: Delay between restart attempts

### Timer Units

**Key points:** Timer units provide systemd-based scheduling, serving as a modern alternative to cron with better integration and logging.

Timer units require corresponding service units with matching names:

```
backup-job.timer  → backup-job.service
```

#### Timer Unit Structure

```ini
[Unit]
Description=Run backup job daily
Requires=backup-job.service

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
```

#### Timer Activation Types

**Realtime timers** (calendar-based):

- `OnCalendar`: Absolute time specification
- `OnBootSec`: Time after boot
- `OnStartupSec`: Time after systemd startup
- `OnUnitActiveSec`: Time after unit last activated
- `OnUnitInactiveSec`: Time after unit became inactive

**Calendar expressions:**

```ini
OnCalendar=*-*-* 02:00:00          # Daily at 2 AM
OnCalendar=Mon,Wed,Fri 09:00       # Monday, Wednesday, Friday at 9 AM
OnCalendar=monthly                 # First day of each month
OnCalendar=*-*-01 00:00:00         # First day of month at midnight
OnCalendar=Sat *-*-* 06:00:00      # Every Saturday at 6 AM
```

**Example:** Database backup timer:

```ini
# /etc/systemd/system/db-backup.timer
[Unit]
Description=Database backup timer
Requires=db-backup.service

[Timer]
OnCalendar=02:30
Persistent=true
RandomizedDelaySec=600

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/db-backup.service
[Unit]
Description=Database backup service
After=postgresql.service

[Service]
Type=oneshot
User=postgres
ExecStart=/usr/local/bin/backup-database.sh
```

Timer management commands:

```bash
sudo systemctl enable db-backup.timer
sudo systemctl start db-backup.timer
systemctl list-timers                    # View active timers
systemctl status db-backup.timer         # Check timer status
```

### Service Security Settings

**Key points:** Systemd provides extensive security features to isolate services and limit potential attack surfaces through sandboxing and privilege restriction.

#### User and Group Isolation

```ini
[Service]
User=myservice
Group=myservice
DynamicUser=true                    # Create temporary user/group
SupplementaryGroups=audio video     # Additional group memberships
```

#### Filesystem Restrictions

Filesystem access control:

```ini
[Service]
ProtectSystem=strict               # Read-only /usr, /boot, /efi
ProtectHome=true                   # Hide /home directories
ReadWritePaths=/var/lib/myservice  # Allow write access to specific paths
ReadOnlyPaths=/etc/myservice       # Read-only access to paths
InaccessiblePaths=/etc/shadow      # Hide sensitive files
PrivateTmp=true                    # Private /tmp directory
```

**Example:** Web service with filesystem restrictions:

```ini
[Service]
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/webapp /var/log/webapp
ReadOnlyPaths=/etc/webapp
PrivateTmp=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectControlGroups=true
```

#### Network Security

Network isolation options:

```ini
[Service]
PrivateNetwork=true                # No network access
IPAccounting=true                  # Enable IP accounting
IPAddressAllow=192.168.1.0/24     # Allowed IP ranges
IPAddressDeny=any                  # Denied IP ranges
RestrictAddressFamilies=AF_INET AF_INET6  # Allowed address families
```

#### System Call Filtering

Restrict available system calls:

```ini
[Service]
SystemCallFilter=@system-service   # Predefined system call set
SystemCallFilter=~@clock @cpu @debug @module @mount @obsolete @reboot @swap
SystemCallErrorNumber=EPERM        # Error returned for blocked calls
SystemCallArchitectures=native     # Restrict to native architecture
```

**System call sets:**

- `@system-service`: Common system service calls
- `@network-io`: Network I/O operations
- `@file-system`: File system operations
- `@process`: Process management
- `@signal`: Signal handling

#### Capability Restrictions

Linux capabilities control:

```ini
[Service]
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_SETUID CAP_SETGID
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true               # Prevent privilege escalation
```

#### Resource Limits

Control resource usage:

```ini
[Service]
MemoryAccounting=true
MemoryMax=512M                     # Maximum memory usage
CPUAccounting=true
CPUQuota=50%                       # CPU usage limit
TasksMax=100                       # Maximum number of tasks
LimitNOFILE=1024                   # File descriptor limit
```

#### Complete Security Example

```ini
[Unit]
Description=Secure Web Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/opt/webapp/bin/webapp
User=webapp
Group=webapp

# Filesystem security
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/webapp /var/log/webapp
PrivateTmp=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectControlGroups=true

# Network security
RestrictAddressFamilies=AF_INET AF_INET6
IPAccounting=true

# System call filtering
SystemCallFilter=@system-service
SystemCallFilter=~@clock @debug @module @mount @reboot
SystemCallErrorNumber=EPERM

# Capabilities
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

# Resource limits
MemoryAccounting=true
MemoryMax=256M
CPUAccounting=true
CPUQuota=25%

[Install]
WantedBy=multi-user.target
```

**Best practices for service security:**

- Use dedicated user accounts with minimal privileges
- Enable filesystem protections appropriate for service requirements
- Implement system call filtering to reduce attack surface
- Set resource limits to prevent resource exhaustion
- Regularly audit service configurations for security compliance
- Test security settings in development environments before production deployment

**Conclusion:** Custom systemd services provide robust process management with extensive security features. Proper unit file configuration enables reliable service operation, while timer units offer flexible scheduling capabilities. Security settings create defense-in-depth protection through isolation and privilege restriction.

---

