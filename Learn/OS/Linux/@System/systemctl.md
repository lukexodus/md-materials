# systemctl

`systemctl` is the primary command-line tool for controlling **systemd** — the init system and service manager used by most modern Linux distributions (Debian, Ubuntu, Fedora, Arch, RHEL, etc.). It manages services, sockets, timers, mounts, and other units.

---

## Core Concepts

### Units

Everything systemd manages is a **unit**. Units are defined by files with typed extensions:

|Extension|Type|Purpose|
|---|---|---|
|`.service`|Service|A daemon or one-shot process|
|`.socket`|Socket|Network or IPC socket (activates a service on connection)|
|`.timer`|Timer|Scheduled activation (cron replacement)|
|`.target`|Target|Group of units (like runlevels)|
|`.mount`|Mount|A filesystem mount point|
|`.automount`|Automount|On-demand mounting|
|`.device`|Device|A kernel device|
|`.path`|Path|File/directory watch (activates a service on change)|
|`.slice`|Slice|Resource control group|
|`.scope`|Scope|Externally created processes|

When no extension is given, systemctl assumes `.service`.

```bash
systemctl start nginx        # same as:
systemctl start nginx.service
```

### Unit File Locations

|Path|Purpose|
|---|---|
|`/lib/systemd/system/`|Vendor-provided units (distro packages)|
|`/usr/lib/systemd/system/`|Vendor-provided units (alternative location)|
|`/etc/systemd/system/`|System administrator units (override vendor)|
|`/run/systemd/system/`|Runtime units (lost on reboot)|
|`~/.config/systemd/user/`|User units (for `--user` mode)|

Files in `/etc/systemd/system/` take precedence over `/lib/systemd/system/`.

---

## Service Management

Most commands require root (or `sudo`) for system units.

```bash
# Start a service
sudo systemctl start nginx

# Stop a service
sudo systemctl stop nginx

# Restart a service (stop then start)
sudo systemctl restart nginx

# Reload a service (reload config without full restart, if supported)
sudo systemctl reload nginx

# Reload or restart (reload if supported, restart otherwise)
sudo systemctl reload-or-restart nginx

# Send SIGHUP to the main process
sudo systemctl kill --signal=SIGHUP nginx
```

---

## Enable / Disable (Autostart)

Enabling a service creates a symlink so it starts automatically at boot.

```bash
# Enable at boot
sudo systemctl enable nginx

# Enable and start immediately
sudo systemctl enable --now nginx

# Disable autostart
sudo systemctl disable nginx

# Disable and stop immediately
sudo systemctl disable --now nginx

# Re-enable (disable + enable in one step)
sudo systemctl reenable nginx

# Prevent a service from ever being started (mask it)
sudo systemctl mask nginx

# Unmask
sudo systemctl unmask nginx
```

> **Masking** creates a symlink to `/dev/null`, making the unit impossible to start — even as a dependency. Useful for units you never want running (e.g. a conflicting service).

---

## Status and Inspection

```bash
# Show service status (most-used command)
systemctl status nginx

# Short status: is it active?
systemctl is-active nginx       # prints "active" or "inactive", exits 0/1

# Is it enabled at boot?
systemctl is-enabled nginx      # prints "enabled", "disabled", "masked", etc.

# Did it fail?
systemctl is-failed nginx       # exits 0 if failed

# Show all properties of a unit
systemctl show nginx

# Show a specific property
systemctl show nginx --property=MainPID
systemctl show nginx --property=ActiveState

# Show the unit file
systemctl cat nginx

# Show unit file location
systemctl status nginx | grep Loaded
```

---

## Listing Units

```bash
# List all active units
systemctl list-units

# List all units (including inactive)
systemctl list-units --all

# List only services
systemctl list-units --type=service

# List only failed units
systemctl list-units --state=failed
systemctl --failed                   # shorthand

# List all installed unit files and their state
systemctl list-unit-files

# List only service unit files
systemctl list-unit-files --type=service

# List timers
systemctl list-timers
systemctl list-timers --all
```

---

## Logs (journalctl)

`systemctl status` shows recent log lines, but `journalctl` gives full access.

```bash
# Logs for a specific service
journalctl -u nginx

# Follow logs in real time
journalctl -u nginx -f

# Logs since last boot
journalctl -u nginx -b

# Logs from a specific time
journalctl -u nginx --since "2024-01-01 00:00:00"
journalctl -u nginx --since "1 hour ago"
journalctl -u nginx --since today

# Show last N lines
journalctl -u nginx -n 50

# Show errors only
journalctl -u nginx -p err

# Priority levels (from low to high)
# debug info notice warning err crit alert emerg

# Kernel messages
journalctl -k

# All logs, current boot
journalctl -b

# Previous boot
journalctl -b -1

# Disk usage by journal
journalctl --disk-usage

# Vacuum old logs
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=500M
```

---

## System State

```bash
# Reboot
sudo systemctl reboot

# Power off
sudo systemctl poweroff

# Suspend (sleep)
sudo systemctl suspend

# Hibernate
sudo systemctl hibernate

# Hybrid sleep (suspend + hibernate)
sudo systemctl hybrid-sleep

# Halt (stop OS but don't power off)
sudo systemctl halt

# Rescue mode (single-user-like)
sudo systemctl rescue

# Emergency mode (minimal, no mounts)
sudo systemctl emergency
```

---

## Targets (Runlevels)

Targets are groups of units representing a system state — they replace SysV runlevels.

|Target|SysV equivalent|Description|
|---|---|---|
|`poweroff.target`|0|Shut down|
|`rescue.target`|1|Single-user mode|
|`multi-user.target`|2/3/4|Multi-user, no GUI|
|`graphical.target`|5|Multi-user with GUI|
|`reboot.target`|6|Reboot|
|`emergency.target`|—|Emergency shell|

```bash
# Show current default target (what boots into)
systemctl get-default

# Set the default target
sudo systemctl set-default multi-user.target
sudo systemctl set-default graphical.target

# Switch to a target now (without reboot)
sudo systemctl isolate multi-user.target
sudo systemctl isolate graphical.target

# Show dependencies of a target
systemctl list-dependencies graphical.target
```

---

## Dependencies

```bash
# Show what a unit depends on
systemctl list-dependencies nginx

# Show what depends on a unit (reverse)
systemctl list-dependencies nginx --reverse

# Show full recursive tree
systemctl list-dependencies nginx --all
```

---

## Reloading systemd Configuration

After creating or editing unit files, tell systemd to re-read them:

```bash
sudo systemctl daemon-reload
```

Always run this after:

- Creating a new unit file
- Editing an existing unit file in `/etc/systemd/system/`
- Changing drop-in override files

---

## Writing a Service Unit File

Unit files go in `/etc/systemd/system/` for custom services.

### Simple service

```ini
# /etc/systemd/system/myapp.service

[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/myapp --config /etc/myapp/config.yaml
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now myapp
```

### Service Types

|Type|Use when|
|---|---|
|`simple`|Process started by `ExecStart` is the main process (default)|
|`exec`|Like `simple` but waits until exec() succeeds|
|`forking`|Process forks and parent exits (traditional daemon)|
|`oneshot`|Process runs once and exits; systemd waits for it to finish|
|`notify`|Process sends `sd_notify()` when ready|
|`dbus`|Service is ready when it acquires a D-Bus name|
|`idle`|Like `simple` but delayed until other jobs finish|

### Restart Options

```ini
Restart=no               # never restart (default)
Restart=on-success       # restart only on clean exit
Restart=on-failure       # restart on non-zero exit, signal, timeout
Restart=on-abnormal      # restart on signal, timeout, watchdog
Restart=always           # always restart
RestartSec=5s            # wait before restarting
StartLimitIntervalSec=60 # window for start limit counting
StartLimitBurst=5        # max starts within the interval
```

### Environment Variables

```ini
[Service]
Environment="NODE_ENV=production"
Environment="PORT=3000"
EnvironmentFile=/etc/myapp/env       # load from a file (KEY=VALUE format)
```

### Resource Limits

```ini
[Service]
LimitNOFILE=65536         # open file descriptors
LimitNPROC=4096           # max processes
MemoryLimit=512M          # memory limit (older syntax)
MemoryMax=512M            # memory limit (newer syntax)
CPUQuota=50%              # max CPU usage
```

### Security Hardening Options

```ini
[Service]
NoNewPrivileges=yes                  # prevent privilege escalation
ProtectSystem=strict                 # mount /usr, /boot read-only
ProtectHome=yes                      # make /home, /root inaccessible
PrivateTmp=yes                       # isolated /tmp
PrivateDevices=yes                   # no access to physical devices
CapabilityBoundingSet=               # drop all capabilities
ReadWritePaths=/var/lib/myapp        # explicitly allow write access
```

---

## Drop-in Overrides

Instead of editing vendor unit files directly (which get overwritten on updates), use drop-in override files.

```bash
# Open/create the override file in an editor automatically
sudo systemctl edit nginx

# Edit the full unit file (not recommended for vendor units)
sudo systemctl edit --full nginx
```

This creates `/etc/systemd/system/nginx.service.d/override.conf`.

### Example override (add an environment variable)

```ini
# /etc/systemd/system/nginx.service.d/override.conf

[Service]
Environment="MY_VAR=hello"
```

```bash
# After editing, reload
sudo systemctl daemon-reload
sudo systemctl restart nginx
```

To remove an override:

```bash
sudo systemctl revert nginx
```

---

## Timers (cron replacement)

A timer unit activates a corresponding service unit on a schedule.

### Monotonic timer (relative to system events)

```ini
# /etc/systemd/system/backup.timer

[Unit]
Description=Run backup every 6 hours

[Timer]
OnBootSec=10min          # first run 10 minutes after boot
OnUnitActiveSec=6h       # then every 6 hours

[Install]
WantedBy=timers.target
```

### Realtime (calendar) timer

```ini
[Timer]
OnCalendar=daily                     # every day at midnight
OnCalendar=weekly                    # every Monday at midnight
OnCalendar=Mon..Fri 09:00            # weekdays at 9am
OnCalendar=*-*-* 02:30:00            # every day at 02:30
OnCalendar=2024-01-01 00:00:00       # specific date/time
Persistent=true                      # run missed triggers after downtime
```

```bash
# The timer activates backup.service (same name, different extension)
sudo systemctl enable --now backup.timer

# List all timers and their next trigger time
systemctl list-timers

# Test a calendar expression
systemd-analyze calendar "Mon..Fri 09:00"
```

---

## User Units

Systemd can manage per-user services that run without root, under `--user`.

```bash
# All commands work the same with --user
systemctl --user start myapp
systemctl --user enable myapp
systemctl --user status myapp
journalctl --user -u myapp

# User unit files go in:
~/.config/systemd/user/

# Reload user daemon
systemctl --user daemon-reload

# Enable lingering (run user services even when not logged in)
sudo loginctl enable-linger username
```

---

## Analyzing Boot Performance

```bash
# Show time each unit took during boot
systemd-analyze blame

# Show total boot time (firmware + loader + kernel + userspace)
systemd-analyze

# Show a critical chain of slow units
systemd-analyze critical-chain

# Generate an SVG boot timing chart
systemd-analyze plot > boot.svg

# Verify a unit file for errors
systemd-analyze verify /etc/systemd/system/myapp.service
```

---

## Common Patterns

### Check why a service failed

```bash
systemctl status myapp.service
journalctl -u myapp.service -n 50 --no-pager
```

### Restart a service if it is running, start it if not

```bash
sudo systemctl reload-or-restart myapp
```

### Run something once at boot (oneshot)

```ini
[Unit]
Description=Initialize database
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/init-db.sh
RemainAfterExit=yes      # unit stays "active" after the process exits

[Install]
WantedBy=multi-user.target
```

### Run a service as a specific user

```ini
[Service]
User=appuser
Group=appgroup
```

### Ensure a service starts after another

```ini
[Unit]
After=postgresql.service
Requires=postgresql.service    # hard dependency — fail if postgres isn't up
# or:
Wants=postgresql.service       # soft dependency — start postgres but don't fail
```

---

## Quick Reference

```bash
# The five commands you use most often
sudo systemctl start <unit>
sudo systemctl stop <unit>
sudo systemctl restart <unit>
sudo systemctl enable --now <unit>
systemctl status <unit>

# After editing unit files
sudo systemctl daemon-reload

# Debug
systemctl --failed
journalctl -u <unit> -f
systemd-analyze blame
```

---

## Practical Tips

**Use `enable --now` and `disable --now`.** These combine the enable/disable with an immediate start/stop, saving a second command.

**Never edit files in `/lib/systemd/system/` directly.** They are owned by packages and will be overwritten on updates. Always use drop-in overrides via `systemctl edit` or place custom files in `/etc/systemd/system/`.

**`daemon-reload` does not restart services.** It only re-reads unit files. You still need `systemctl restart` for changes to take effect.

**`Restart=on-failure` is the safe default for most daemons.** It handles crashes and OOM kills without restarting on intentional `systemctl stop`.

**Use `PrivateTmp=yes` and `NoNewPrivileges=yes` for any service you write.** They are low-friction hardening options that meaningfully reduce attack surface.

**`journalctl -f -u <service>` is your friend during development.** Follow logs in real time while testing a new service unit.

**`systemd-analyze verify`** catches syntax errors and missing dependencies in unit files before you try to run them.

> **[Inference]** Some options (e.g. `MemoryMax`, `CPUQuota`, newer security options) require a sufficiently recent systemd version and a kernel with cgroup v2 support. Verify with `systemctl --version` and `systemd-analyze` on your specific system.