# systemd

The init system and service manager for Linux. systemd is PID 1 — the first process started by the kernel, and the parent of everything else. It manages services, targets, mounts, timers, sockets, devices, and more.

> systemd is the default init system on Debian, Ubuntu, Fedora, RHEL, Arch, openSUSE, and most modern Linux distributions.

**Official docs:** `systemd.io` and `man systemd`

---

## Core Concepts

### Units

Everything systemd manages is a **unit**. Units are described by unit files. Unit types are identified by their file extension:

|Extension|Type|Purpose|
|---|---|---|
|`.service`|Service|A daemon or one-shot process|
|`.target`|Target|A group of units; like a runlevel|
|`.timer`|Timer|Schedule for running a service|
|`.socket`|Socket|Network or IPC socket activation|
|`.mount`|Mount|A filesystem mount point|
|`.automount`|Automount|On-demand mount|
|`.device`|Device|A kernel device|
|`.path`|Path|Watch a file/directory for changes|
|`.slice`|Slice|A cgroup hierarchy node|
|`.scope`|Scope|Externally created process group|

### Unit file locations

systemd searches for unit files in order (later overrides earlier):

|Path|Purpose|
|---|---|
|`/lib/systemd/system/`|Vendor/distribution units (don't edit)|
|`/usr/lib/systemd/system/`|Distribution units (don't edit)|
|`/etc/systemd/system/`|Local admin units — **put your files here**|
|`/run/systemd/system/`|Runtime units (transient, lost on reboot)|
|`~/.config/systemd/user/`|User units|

### The daemon

After editing unit files, reload the daemon so systemd sees your changes:

```sh
sudo systemctl daemon-reload
```

---

## systemctl — Managing Units

`systemctl` is the main tool for inspecting and controlling systemd.

### Starting, stopping, restarting

```sh
sudo systemctl start nginx          # start now
sudo systemctl stop nginx           # stop now
sudo systemctl restart nginx        # stop then start
sudo systemctl reload nginx         # reload config without full restart (if supported)
sudo systemctl reload-or-restart nginx   # reload if possible, otherwise restart
```

### Enabling and disabling (boot persistence)

```sh
sudo systemctl enable nginx         # enable at boot (creates symlink)
sudo systemctl disable nginx        # disable at boot (removes symlink)
sudo systemctl enable --now nginx   # enable at boot AND start now
sudo systemctl disable --now nginx  # disable at boot AND stop now
sudo systemctl reenable nginx       # disable then re-enable (refresh symlinks)
```

### Masking

Masking prevents a unit from being started at all — manually or as a dependency:

```sh
sudo systemctl mask nginx           # mask (symlink to /dev/null)
sudo systemctl unmask nginx         # unmask
```

### Status and inspection

```sh
systemctl status nginx              # status, recent log, PID, cgroup
systemctl status                    # system-wide status summary
systemctl is-active nginx           # prints "active" or "inactive"; exit 0 if active
systemctl is-enabled nginx          # prints enabled/disabled/masked/static
systemctl is-failed nginx           # exit 0 if unit is in failed state

systemctl list-units                        # all active units
systemctl list-units --type=service         # only services
systemctl list-units --state=failed         # only failed units
systemctl list-units --all                  # include inactive units
systemctl list-unit-files                   # all installed unit files + enabled state
systemctl list-unit-files --type=service
systemctl list-unit-files --state=enabled
```

### Dependencies

```sh
systemctl list-dependencies nginx           # what nginx depends on
systemctl list-dependencies nginx --reverse # what depends on nginx
systemctl list-dependencies nginx --all     # full recursive tree
```

### Editing units

```sh
sudo systemctl edit nginx           # create a drop-in override (recommended)
sudo systemctl edit --full nginx    # edit a full copy of the unit file
sudo systemctl revert nginx         # remove drop-ins and revert to vendor unit
```

### System state

```sh
sudo systemctl poweroff
sudo systemctl reboot
sudo systemctl suspend
sudo systemctl hibernate
sudo systemctl hybrid-sleep

sudo systemctl rescue               # switch to rescue target (single user)
sudo systemctl emergency            # emergency shell (minimal)
sudo systemctl default              # return to default target
```

---

## Unit Files

Unit files are INI-style text files with sections. Every unit has a `[Unit]` section and an `[Install]` section. Unit-type-specific configuration goes in a type section like `[Service]`, `[Timer]`, etc.

### Common `[Unit]` section

```ini
[Unit]
Description=My Application
Documentation=https://example.com/docs
# Ordering
After=network.target
After=postgresql.service
Before=nginx.service
# Dependencies (soft)
Wants=network.target
# Dependencies (hard — unit fails if dependency fails)
Requires=postgresql.service
# Conflict — cannot run alongside
Conflicts=old-app.service
# Condition — only start if condition is met
ConditionPathExists=/etc/myapp/config.yml
ConditionFileNotEmpty=/etc/myapp/config.yml
```

### Common `[Install]` section

```ini
[Install]
# Which target to attach to when enabled
WantedBy=multi-user.target      # most services
WantedBy=graphical.target       # GUI-dependent services
# Or: become a dependency of another unit
RequiredBy=myother.service
# Or: create an alias
Alias=myapp.service
```

---

## Service Units

The most common unit type.

### Service types

|`Type=`|Behavior|
|---|---|
|`simple`|Default. Main process is specified by `ExecStart`. Ready immediately.|
|`exec`|Like `simple` but considered started only after the binary is exec'd.|
|`forking`|For daemons that fork and exit. Use `PIDFile=` with this.|
|`oneshot`|Runs once and exits. systemd waits for it to finish before proceeding.|
|`notify`|Process notifies systemd when ready (via `sd_notify()`).|
|`notify-reload`|Like `notify` but also sends notification on reload.|
|`dbus`|Ready when a D-Bus name is acquired.|
|`idle`|Like `simple` but delayed until other jobs are idle.|

### Full service unit example

```ini
[Unit]
Description=My Web Application
Documentation=https://example.com
After=network.target postgresql.service
Wants=network.target
Requires=postgresql.service

[Service]
Type=simple

# User and group to run as
User=myapp
Group=myapp

# Working directory
WorkingDirectory=/opt/myapp

# Environment
Environment=NODE_ENV=production
Environment=PORT=3000
EnvironmentFile=/etc/myapp/env     # load variables from a file

# The main process
ExecStart=/usr/bin/node /opt/myapp/server.js

# Optional: run before/after main process
ExecStartPre=/usr/bin/node /opt/myapp/migrate.js
ExecStartPost=/usr/bin/curl -s http://localhost:3000/health
ExecStop=/bin/kill -TERM $MAINPID
ExecReload=/bin/kill -HUP $MAINPID

# Restart behavior
Restart=on-failure
RestartSec=5s
StartLimitIntervalSec=60s
StartLimitBurst=3             # no more than 3 restarts in 60 seconds

# Output
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

# Timeouts
TimeoutStartSec=30s
TimeoutStopSec=30s

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
```

### Restart policies

|`Restart=`|When to restart|
|---|---|
|`no`|Never (default)|
|`always`|Always, regardless of exit status|
|`on-failure`|Only if exit code is non-zero, killed by signal, or timeout|
|`on-abnormal`|If killed by signal, timeout, or watchdog|
|`on-success`|Only if exited with code 0|
|`on-watchdog`|Only on watchdog timeout|
|`on-abort`|Only if killed by uncaught signal|

### Oneshot service

For tasks that run to completion (migrations, setup scripts):

```ini
[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup.sh
RemainAfterExit=yes    # consider the service "active" after the process exits
```

### Template units (instances)

A template unit has `@` in its name: `myapp@.service`. Instantiate it with:

```sh
sudo systemctl start myapp@instance1.service
sudo systemctl start myapp@instance2.service
```

Inside the unit file, `%i` is replaced with the instance name:

```ini
[Service]
ExecStart=/usr/bin/myapp --config /etc/myapp/%i.conf
```

---

## Target Units

Targets group units together and represent system states — similar to runlevels.

### Common targets

|Target|Equivalent|Description|
|---|---|---|
|`poweroff.target`|runlevel 0|Shut down and power off|
|`rescue.target`|runlevel 1|Single-user rescue shell|
|`multi-user.target`|runlevel 3|Multi-user, no GUI|
|`graphical.target`|runlevel 5|Multi-user with GUI|
|`reboot.target`|runlevel 6|Reboot|
|`emergency.target`|—|Emergency shell (minimal)|
|`network.target`|—|Network is up|
|`network-online.target`|—|Network is fully online|
|`default.target`|—|Symlink to the current default target|

### Change the default target

```sh
sudo systemctl get-default                 # show current default
sudo systemctl set-default multi-user.target
sudo systemctl set-default graphical.target
```

### Switch target at runtime

```sh
sudo systemctl isolate multi-user.target   # switch to multi-user now
```

---

## Timer Units

Timers replace cron jobs. Each timer activates a corresponding `.service` unit.

### A timer and its service

```ini
# /etc/systemd/system/backup.service
[Unit]
Description=Daily Backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
User=backup
```

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Run backup daily

[Timer]
# Calendar-based schedule
OnCalendar=daily
# Or more specific:
# OnCalendar=Mon..Fri 02:30:00
# OnCalendar=*-*-* 03:00:00     (every day at 03:00)
# OnCalendar=weekly              (Monday 00:00)
# OnCalendar=hourly

# Spread activation randomly within this window (avoids thundering herd)
RandomizedDelaySec=1800

# If the timer was missed (system was off), run it now
Persistent=true

# Time relative to when the timer unit was activated
# OnActiveSec=10min

# Time relative to system boot
# OnBootSec=5min

# Time relative to last activation
# OnUnitActiveSec=1h

[Install]
WantedBy=timers.target
```

### Managing timers

```sh
sudo systemctl enable --now backup.timer
sudo systemctl status backup.timer
systemctl list-timers                      # all active timers, next trigger time
systemctl list-timers --all               # include inactive timers
sudo systemctl start backup.service        # run the job immediately (manually)
```

### Calendar expression examples

```
OnCalendar=hourly                    → *-*-* *:00:00
OnCalendar=daily                     → *-*-* 00:00:00
OnCalendar=weekly                    → Mon *-*-* 00:00:00
OnCalendar=monthly                   → *-*-01 00:00:00
OnCalendar=Sat,Sun 10:00:00          → weekends at 10am
OnCalendar=Mon..Fri 09:00:00         → weekdays at 9am
OnCalendar=*:0/15                    → every 15 minutes
OnCalendar=*-*-* 02:00:00            → every day at 2am
```

Validate a calendar expression:

```sh
systemd-analyze calendar "Mon..Fri 09:00:00"
```

---

## Socket Units

Socket units allow **socket activation**: systemd listens on a socket and starts the service only when a connection arrives. This speeds up boot and allows services to be started on demand.

```ini
# /etc/systemd/system/myapp.socket
[Unit]
Description=My App Socket

[Socket]
ListenStream=8080              # TCP port
# ListenStream=/run/myapp.sock # Unix socket
# ListenDatagram=514           # UDP
Accept=no                      # pass socket fd to service (don't accept per-connection)

[Install]
WantedBy=sockets.target
```

The corresponding service receives the socket file descriptor from systemd and does not need to bind itself.

```sh
sudo systemctl enable --now myapp.socket
```

---

## Mount & Automount Units

systemd can manage mounts, and these integrate with the dependency system.

### Mount unit

```ini
# /etc/systemd/system/mnt-data.mount
# Unit name must match the mount point path with / replaced by -
[Unit]
Description=Data Volume

[Mount]
What=/dev/sdb1
Where=/mnt/data
Type=ext4
Options=defaults,noatime

[Install]
WantedBy=multi-user.target
```

### Automount unit

```ini
# /etc/systemd/system/mnt-data.automount
[Unit]
Description=Automount Data Volume

[Automount]
Where=/mnt/data
TimeoutIdleSec=600    # unmount after 10 minutes of inactivity

[Install]
WantedBy=multi-user.target
```

Note: `/etc/fstab` entries are automatically converted to mount units at boot by `systemd-fstab-generator`.

---

## journalctl — Viewing Logs

systemd collects all service output in the **journal** — a structured, binary log database. `journalctl` queries it.

### Basic queries

```sh
journalctl                          # all logs, oldest first
journalctl -r                       # reverse (newest first)
journalctl -f                       # follow (like tail -f)
journalctl -e                       # jump to end
journalctl -n 100                   # last 100 lines
journalctl -n 50 -f                 # last 50 lines then follow
```

### Filter by unit

```sh
journalctl -u nginx                 # logs for nginx.service
journalctl -u nginx -f              # follow nginx logs
journalctl -u nginx -u mysql        # logs for multiple units
journalctl -u nginx --since today
```

### Filter by time

```sh
journalctl --since "2024-01-15"
journalctl --since "2024-01-15 10:00:00"
journalctl --until "2024-01-15 12:00:00"
journalctl --since "1 hour ago"
journalctl --since today
journalctl --since yesterday
journalctl -b                       # current boot only
journalctl -b -1                    # previous boot
journalctl -b -2                    # two boots ago
journalctl --list-boots             # list all recorded boots
```

### Filter by priority

```sh
journalctl -p err                   # errors and above
journalctl -p warning               # warnings and above
journalctl -p debug                 # everything (very verbose)
# Priorities: emerg, alert, crit, err, warning, notice, info, debug
```

### Filter by process / PID / UID

```sh
journalctl _PID=1234
journalctl _UID=1000
journalctl _COMM=nginx              # by executable name
journalctl _EXE=/usr/sbin/nginx
```

### Output formats

```sh
journalctl -o short             # default
journalctl -o short-precise     # microsecond timestamps
journalctl -o json              # JSON, one object per line
journalctl -o json-pretty       # pretty-printed JSON
journalctl -o cat               # message only, no metadata
journalctl -o verbose           # all fields
```

### Disk usage and maintenance

```sh
journalctl --disk-usage                    # show journal size on disk
sudo journalctl --vacuum-size=500M         # keep only 500MB of logs
sudo journalctl --vacuum-time=30d          # keep only last 30 days
sudo journalctl --vacuum-files=5           # keep only 5 journal files
```

### Journal configuration

```ini
# /etc/systemd/journald.conf
[Journal]
Storage=persistent          # persist across reboots (auto/volatile/none/persistent)
Compress=yes
SystemMaxUse=1G             # max disk for system journal
SystemKeepFree=200M         # keep at least 200MB free
MaxRetentionSec=1month
MaxFileSec=1week
```

After editing: `sudo systemctl restart systemd-journald`

---

## Analyzing Boot Performance

```sh
systemd-analyze                         # total boot time summary
systemd-analyze blame                   # time each unit took, sorted by duration
systemd-analyze critical-chain          # the critical path (what delayed boot)
systemd-analyze critical-chain nginx    # critical chain for a specific unit
systemd-analyze plot > boot.svg         # SVG chart of boot timeline
systemd-analyze dot | dot -Tpng > deps.png  # dependency graph (requires graphviz)
systemd-analyze verify /path/to/unit    # check a unit file for errors
systemd-analyze calendar "Mon..Fri"     # validate a calendar expression
systemd-analyze security nginx          # analyze sandbox security score of a service
```

---

## User Services

Each user can run their own systemd instance, managing their own services without root. These start at login and stop at logout (unless `loginctl enable-linger` is set).

### User unit location

```
~/.config/systemd/user/
```

### User systemctl commands

```sh
systemctl --user start myapp
systemctl --user enable myapp
systemctl --user status myapp
systemctl --user list-units
journalctl --user -u myapp
```

### Enable linger (run user services without being logged in)

```sh
sudo loginctl enable-linger username    # user services start at boot
sudo loginctl disable-linger username
loginctl show-user username             # check linger status
```

### Example user service

```ini
# ~/.config/systemd/user/myapp.service
[Unit]
Description=My User App

[Service]
ExecStart=/home/alice/bin/myapp
Restart=on-failure
Environment=HOME=/home/alice

[Install]
WantedBy=default.target
```

```sh
systemctl --user daemon-reload
systemctl --user enable --now myapp
```

---

## Resource Control (cgroups)

systemd uses cgroups to limit and account for resource usage per service.

### In a service unit

```ini
[Service]
# CPU
CPUQuota=50%               # max 50% of one CPU core
CPUWeight=100              # relative weight (default 100)

# Memory
MemoryMax=512M             # hard limit — OOM kill if exceeded
MemoryHigh=400M            # soft limit — throttle, swap out
MemorySwapMax=0            # disable swap for this service

# I/O
IOWeight=100               # relative I/O weight
IOReadBandwidthMax=/dev/sda 50M     # max read: 50MB/s
IOWriteBandwidthMax=/dev/sda 20M    # max write: 20MB/s

# Tasks (threads + processes)
TasksMax=512
```

### Inspecting resource usage

```sh
systemctl status nginx              # shows cgroup hierarchy and memory use
systemd-cgtop                       # live top-like view of cgroup resource usage
systemd-cgls                        # tree view of cgroup hierarchy
```

---

## Security & Sandboxing

systemd provides security hardening options in service units. Use `systemd-analyze security <service>` to see what is and is not enabled.

```ini
[Service]
# Run as non-root
User=myapp
Group=myapp

# Filesystem restrictions
ProtectSystem=strict          # make /usr, /boot, /etc read-only
ProtectHome=yes               # make /home, /root, /run/user inaccessible
ReadWritePaths=/var/lib/myapp # allow writes only here
ReadOnlyPaths=/etc/myapp
TemporaryFileSystem=/tmp      # private /tmp
PrivateTmp=yes                # private /tmp namespace

# Device access
PrivateDevices=yes            # no access to physical devices
DeviceAllow=/dev/null rw      # explicitly allow specific devices

# Networking
PrivateNetwork=yes            # completely isolate network (breaks most services)
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX

# System call filtering
SystemCallFilter=@system-service    # only allow typical service syscalls
SystemCallFilter=~@privileged       # deny privileged syscalls
SystemCallArchitectures=native

# Capabilities
CapabilityBoundingSet=            # remove ALL capabilities
AmbientCapabilities=              # no ambient caps
NoNewPrivileges=yes               # process cannot gain new privileges

# Namespaces
PrivateUsers=yes              # new user namespace (maps to nobody outside)
ProtectKernelTunables=yes     # read-only /proc/sys, /sys
ProtectKernelModules=yes      # cannot load kernel modules
ProtectKernelLogs=yes         # cannot access kernel ring buffer
ProtectClock=yes              # cannot change system clock
ProtectHostname=yes           # cannot change hostname
RestrictNamespaces=yes        # cannot create new namespaces
LockPersonality=yes           # lock ABI personality

# Misc
MemoryDenyWriteExecute=yes    # no writable+executable memory (breaks JIT)
RestrictRealtime=yes          # cannot set realtime scheduling
RestrictSUIDSGID=yes          # cannot set SUID/SGID bits
UMask=0077                    # restrictive file creation mask
```

### Checking the security score

```sh
systemd-analyze security nginx
```

This prints a table of hardening options and an exposure score. Lower is more secure.

---

## Dependencies & Ordering

### Dependency directives

|Directive|Meaning|
|---|---|
|`Requires=`|Hard dependency. If dep fails to start, this unit fails.|
|`Wants=`|Soft dependency. If dep fails, this unit continues anyway.|
|`Requisite=`|Dep must already be active; does not start it.|
|`BindsTo=`|Like Requires but also stops this unit if dep stops.|
|`PartOf=`|If dep is stopped or restarted, so is this unit.|
|`Upholds=`|Continuously restart dep if it stops.|
|`Conflicts=`|Cannot be active at the same time.|

### Ordering directives

|Directive|Meaning|
|---|---|
|`Before=`|This unit starts before the listed units|
|`After=`|This unit starts after the listed units|

> Dependencies and ordering are **independent**. `Requires=foo.service` does not mean `foo` starts before this unit — you need `After=foo.service` for that. You usually want both.

```ini
Requires=postgresql.service
After=postgresql.service
```

### Implicit dependencies

Some are added automatically:

- `.service` units get `After=basic.target` implicitly
- `network.target` is added when a service has `After=network.target`
- Mount units create implicit ordering with their parent mounts

---

## Overriding Units (Drop-ins)

The recommended way to customize a vendor unit without replacing it entirely. Drop-in files are merged with the original.

### Create a drop-in

```sh
sudo systemctl edit nginx
# Opens an editor; creates /etc/systemd/system/nginx.service.d/override.conf
```

### Manual drop-in

```sh
sudo mkdir -p /etc/systemd/system/nginx.service.d/
sudo nano /etc/systemd/system/nginx.service.d/override.conf
```

```ini
# /etc/systemd/system/nginx.service.d/override.conf
[Service]
# To clear an existing list directive, first set it empty, then set your value
ExecStartPre=
ExecStartPre=/usr/local/bin/check-config.sh
Restart=always
LimitNOFILE=100000
Environment=MY_VAR=value
```

```sh
sudo systemctl daemon-reload
sudo systemctl restart nginx
```

### View effective unit (with all drop-ins merged)

```sh
systemctl cat nginx
```

---

## Practical Examples

### A minimal web service

```ini
# /etc/systemd/system/myapi.service
[Unit]
Description=My API Server
After=network.target
Wants=network.target

[Service]
Type=exec
User=api
Group=api
WorkingDirectory=/opt/myapi
EnvironmentFile=/etc/myapi/env
ExecStart=/opt/myapi/bin/server
Restart=on-failure
RestartSec=3s
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapi
PrivateTmp=yes
NoNewPrivileges=yes
ProtectSystem=strict
ReadWritePaths=/var/lib/myapi /var/log/myapi

[Install]
WantedBy=multi-user.target
```

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now myapi
journalctl -u myapi -f
```

### A daily cleanup cron replacement

```ini
# /etc/systemd/system/cleanup.service
[Unit]
Description=Clean temp files

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cleanup.sh
User=root
```

```ini
# /etc/systemd/system/cleanup.timer
[Unit]
Description=Daily cleanup at 3am

[Timer]
OnCalendar=*-*-* 03:00:00
RandomizedDelaySec=600
Persistent=true

[Install]
WantedBy=timers.target
```

```sh
sudo systemctl enable --now cleanup.timer
```

### Run a container as a service

```ini
[Unit]
Description=My Docker App
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop myapp
ExecStartPre=-/usr/bin/docker rm myapp
ExecStart=/usr/bin/docker run --name myapp -p 8080:8080 myimage:latest
ExecStop=/usr/bin/docker stop myapp
Restart=always

[Install]
WantedBy=multi-user.target
```

---

## Quick Cheatsheet

### systemctl

|Command|Action|
|---|---|
|`systemctl start NAME`|Start unit|
|`systemctl stop NAME`|Stop unit|
|`systemctl restart NAME`|Restart unit|
|`systemctl reload NAME`|Reload config (no restart)|
|`systemctl enable NAME`|Enable at boot|
|`systemctl disable NAME`|Disable at boot|
|`systemctl enable --now NAME`|Enable + start|
|`systemctl disable --now NAME`|Disable + stop|
|`systemctl mask NAME`|Prevent from ever starting|
|`systemctl unmask NAME`|Unmask|
|`systemctl status NAME`|Status + recent log|
|`systemctl is-active NAME`|Is it running?|
|`systemctl is-enabled NAME`|Is it enabled?|
|`systemctl daemon-reload`|Reload unit files|
|`systemctl list-units`|Active units|
|`systemctl list-units --failed`|Failed units|
|`systemctl list-timers`|Active timers|
|`systemctl edit NAME`|Create drop-in override|
|`systemctl cat NAME`|Show effective unit file|
|`systemctl reboot`|Reboot system|
|`systemctl poweroff`|Power off|

### journalctl

|Command|Action|
|---|---|
|`journalctl -u NAME`|Logs for a unit|
|`journalctl -u NAME -f`|Follow unit logs|
|`journalctl -b`|Current boot|
|`journalctl -b -1`|Previous boot|
|`journalctl -n 100`|Last 100 lines|
|`journalctl -p err`|Errors and above|
|`journalctl --since "1h ago"`|Last hour|
|`journalctl --since today`|Today|
|`journalctl -o json`|JSON output|
|`journalctl --disk-usage`|Journal size|
|`journalctl --vacuum-size=500M`|Trim journal|

### systemd-analyze

|Command|Action|
|---|---|
|`systemd-analyze`|Boot time summary|
|`systemd-analyze blame`|Per-unit boot times|
|`systemd-analyze critical-chain`|Boot critical path|
|`systemd-analyze plot > boot.svg`|Boot timeline chart|
|`systemd-analyze verify FILE`|Validate a unit file|
|`systemd-analyze security NAME`|Security score|
|`systemd-analyze calendar EXPR`|Validate timer expression|

### Unit file sections at a glance

```ini
[Unit]
Description=
After=          # ordering
Wants=          # soft dep
Requires=       # hard dep
Conflicts=

[Service]
Type=           # simple exec oneshot forking notify
User=
ExecStart=
Restart=        # no always on-failure on-abnormal
RestartSec=
Environment=
EnvironmentFile=
WorkingDirectory=
StandardOutput=journal
PrivateTmp=yes
NoNewPrivileges=yes
ProtectSystem=strict

[Timer]
OnCalendar=
Persistent=true
RandomizedDelaySec=

[Install]
WantedBy=multi-user.target
```

---

_Source: [systemd.io](https://systemd.io/), `man systemd`, `man systemd.service`, `man systemd.timer`, `man journalctl`. Always consult the man pages for your installed version — options vary across distributions and systemd versions._