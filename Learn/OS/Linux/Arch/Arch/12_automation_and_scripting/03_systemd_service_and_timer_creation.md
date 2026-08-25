## Systemd Service and Timer Creation


### Systemd Fundamentals

**Purpose**: Init system managing services and daemons.[1]

**Service**: Runnable program or daemon .

**Timer**: Scheduled execution, like cron.[1]

**Unit**: Configuration file defining service/timer .

**Advantages** :
- Dependency management 
- Parallel startup 
- Status tracking 
- Automatic restart 

### Service Units

#### Unit File Location

**System Services**: `/etc/systemd/system/`.[1]

**User Services**: `~/.config/systemd/user/` .

**Preset Services**: `/usr/lib/systemd/system/` .

#### Basic Service Structure

**Syntax** :

```ini
[Unit]
Description=My Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/myapp
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

**Sections** :
- `[Unit]`: Metadata 
- `[Service]`: Service config 
- `[Install]`: Installation targets 

### Creating a Service

#### Example Service

**Create File**: `/etc/systemd/system/myapp.service` :

```ini
[Unit]
Description=My Application
Documentation=https://example.com/docs
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/start.sh
Restart=on-failure
RestartSec=5s

StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

#### Service Type Options

**simple** :

Process runs in foreground .

**forking** :

Process forks to background :

```ini
Type=forking
PIDFile=/run/myapp.pid
```

**oneshot** :

Runs once, doesn't stay running :

```ini
Type=oneshot
ExecStart=/usr/bin/command
RemainAfterExit=yes
```

**notify** :

Service signals when ready :

```ini
Type=notify
ExecStart=/usr/bin/myapp
```

**dbus** :

Activates via D-Bus .

**idle** :

Starts after other services .

### Service Configuration

#### Basic Options

**Description** :

```ini
Description=My Service Description
```

**User/Group** :

```ini
User=myuser
Group=mygroup
```

**Working Directory** :

```ini
WorkingDirectory=/opt/myapp
```

**Environment Variables** :

```ini
Environment="VAR1=value1"
Environment="VAR2=value2"
EnvironmentFile=/etc/myapp/config
```

**Command Execution** :

```ini
ExecStart=/usr/bin/myapp --option1 value1
ExecStartPre=/usr/bin/prepare.sh
ExecStartPost=/usr/bin/poststart.sh
ExecStop=/usr/bin/stop.sh
ExecReload=/usr/bin/reload.sh
```

#### Restart Behavior

**Automatic Restart** :

```ini
Restart=on-failure
RestartSec=5s
StartLimitInterval=60s
StartLimitBurst=3
```

**Restart Policies** :
- `no`: Don't restart 
- `always`: Always restart 
- `on-success`: Only on exit code 0 
- `on-failure`: Only on failure 
- `on-abnormal`: On signal/timeout 

#### Resource Limits

**Memory Limit** :

```ini
MemoryLimit=512M
MemoryMax=1G
```

**CPU Shares** :

```ini
CPUShares=512
CPUQuota=50%
```

**File Descriptor Limit** :

```ini
LimitNOFILE=65535
```

#### Security and Isolation

**No New Privileges** :

```ini
NoNewPrivileges=yes
```

**Protect System** :

```ini
ProtectSystem=strict
ProtectHome=yes
ReadOnlyPaths=/
ReadWritePaths=/var/lib/myapp
```

**Private Temp** :

```ini
PrivateTmp=yes
```

**Capabilities** :

```ini
CapabilityBoundingSet=~CAP_SYS_ADMIN
```

### Using Services

#### Enable Service

**Enable at Boot** :

```bash
sudo systemctl enable myapp.service
```

**Reload Daemon** :

```bash
sudo systemctl daemon-reload
```

**Start Service** :

```bash
sudo systemctl start myapp.service
```

#### Check Status

**Service Status** :

```bash
sudo systemctl status myapp.service
```

**List Services** :

```bash
systemctl list-units --type=service
```

**Failed Services** :

```bash
systemctl list-units --state=failed
```

#### Control Service

**Stop Service** :

```bash
sudo systemctl stop myapp.service
```

**Restart Service** :

```bash
sudo systemctl restart myapp.service
```

**Reload Service** :

```bash
sudo systemctl reload myapp.service
```

**Disable Service** :

```bash
sudo systemctl disable myapp.service
```

#### View Logs

**Service Logs** :

```bash
journalctl -u myapp.service
```

**Follow Logs** :

```bash
journalctl -u myapp.service -f
```

**Show Errors** :

```bash
journalctl -u myapp.service -p err
```

### Timer Units

#### Timer Concept

**Scheduling**: Replaces cron for systemd services .

**Advantages** :
- Integrated with systemd 
- Reliable execution 
- Systemd logging 
- Easy management 

#### Creating Timers

**Timer File**: `/etc/systemd/system/backup.timer` :

```ini
[Unit]
Description=Daily Backup Timer
Requires=backup.service

[Timer]
OnCalendar=daily
OnBootSec=5min
Persistent=true

[Install]
WantedBy=timers.target
```

**Corresponding Service**: `/etc/systemd/system/backup.service` :

```ini
[Unit]
Description=Backup Service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

#### Calendar Syntax

**Daily** :

```
OnCalendar=daily
OnCalendar=*-*-* 02:00:00
```

**Weekly** :

```
OnCalendar=weekly
OnCalendar=Mon 02:00:00
```

**Monthly** :

```
OnCalendar=monthly
OnCalendar=*-01-01 00:00:00
```

**Specific Times** :

```
OnCalendar=*-*-* 09,12,15:00:00  # 9 AM, 12 PM, 3 PM
OnCalendar=*-*-1,15 02:00:00     # 1st and 15th of month
```

#### Boot Timers

**Run After Boot** :

```ini
OnBootSec=5min
```

**Run After System Startup** :

```ini
OnUnitActiveSec=1h
```

**Persistent** :

```ini
Persistent=true
```

Catches up if missed .

### Timer Examples

#### Daily Cleanup

**Timer**: `/etc/systemd/system/cleanup.timer` :

```ini
[Unit]
Description=Daily System Cleanup
Requires=cleanup.service

[Timer]
OnCalendar=daily
OnBootSec=10min
Persistent=true

[Install]
WantedBy=timers.target
```

**Service**: `/etc/systemd/system/cleanup.service` :

```ini
[Unit]
Description=System Cleanup

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Sc --noconfirm
ExecStart=/usr/bin/journalctl --vacuum-time=30d
ExecStart=/usr/bin/find /tmp -type f -atime +7 -delete
```

#### Hourly Sync

**Timer** :

```ini
OnCalendar=hourly
```

**Service** :

```ini
ExecStart=/usr/local/bin/sync-data.sh
```

#### Random Timing

**Randomize Execution** :

```ini
OnCalendar=*-*-* 03:00:00
RandomizedDelaySec=1h
```

Runs between 3:00 and 4:00 AM .

### Managing Timers

#### Enable Timer

**Start Timer** :

```bash
sudo systemctl enable --now backup.timer
```

#### List Timers

**Active Timers** :

```bash
systemctl list-timers
```

**All Timers** :

```bash
systemctl list-timers --all
```

#### Monitor Timer

**Check Next Execution** :

```bash
systemctl list-timers backup.timer
```

**Manual Trigger** :

```bash
sudo systemctl start backup.service
```

#### Stop Timer

**Disable** :

```bash
sudo systemctl disable backup.timer
```

**Stop** :

```bash
sudo systemctl stop backup.timer
```

### User Services and Timers

#### User Service

**Location**: `~/.config/systemd/user/myapp.service` :

```ini
[Unit]
Description=My User Application
After=network.target

[Service]
Type=simple
ExecStart=%h/.local/bin/myapp
Restart=on-failure

[Install]
WantedBy=default.target
```

**Enable for User** :

```bash
systemctl --user enable myapp.service
systemctl --user start myapp.service
```

**Create Directory** :

```bash
mkdir -p ~/.config/systemd/user
```

#### User Timer

**Create Timer**: `~/.config/systemd/user/sync.timer` :

```ini
[Unit]
Description=Hourly Data Sync
Requires=sync.service

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
```

**Service**: `~/.config/systemd/user/sync.service` :

```ini
[Unit]
Description=Sync Data

[Service]
Type=oneshot
ExecStart=%h/.local/bin/sync.sh
```

**Enable** :

```bash
systemctl --user enable --now sync.timer
```

### Advanced Features

#### Dependencies

**Wait for Service** :

```ini
After=network-online.target
Wants=network-online.target
```

**Require Service** :

```ini
Requires=postgresql.service
```

**Conflict** :

```ini
Conflicts=sleep.target
```

#### Conditions

**Run Only If** :

```ini
ConditionFileNotEmpty=/etc/config
ConditionVirtualization=!vm
ConditionUser=root
```

#### D-Bus Activation

**Activate via D-Bus** :

```ini
[Unit]
Type=dbus
BusName=org.example.MyService

[Service]
ExecStart=/usr/bin/myservice
```

### Troubleshooting

#### Service Won't Start

**Check Service** :

```bash
sudo systemctl status myapp.service
journalctl -u myapp.service -n 50
```

**Validate Configuration** :

```bash
sudo systemd-analyze verify myapp.service
```

#### Permission Denied

**User Issue** :

Ensure correct User specified .

**Fix** :

```ini
User=myuser
```

#### Timer Not Triggering

**Check Timer** :

```bash
systemctl status backup.timer
systemctl list-timers backup.timer
```

**Persistent Check** :

Add `Persistent=true` if needed .

### Best Practices

**Use Absolute Paths** :

```ini
ExecStart=/usr/bin/myapp  # Good
ExecStart=myapp            # Bad
```

**Set User Explicitly** :

```ini
User=myuser
```

**Configure Restart** :

```ini
Restart=on-failure
RestartSec=5s
```

**Log Output** :

```ini
StandardOutput=journal
StandardError=journal
```

**Test Services** :

Use `systemd-analyze` to verify .

**Document Services** :

```ini
Description=Clear description
Documentation=https://example.com/docs
```

***

This comprehensive guide on systemd service and timer creation completes the Arch Linux system administration documentation, providing users with modern, integrated methods for managing services, scheduling tasks, and automating maintenance operations.

Sources
[1] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

