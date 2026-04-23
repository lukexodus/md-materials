# systemd-analyze

A tool for inspecting and debugging the systemd init system — boot performance, unit dependencies, security posture, and unit file correctness.

**Man page:** `man systemd-analyze`

---

## Table of Contents

1. [What is systemd-analyze?](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#what-is-systemd-analyze)
2. [Boot Timing](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#boot-timing)
3. [Critical Chain](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#critical-chain)
4. [Visualizing the Boot](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#visualizing-the-boot)
5. [Unit File Verification](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#unit-file-verification)
6. [Security Analysis](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#security-analysis)
7. [Calendar & Timespan Expressions](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#calendar--timespan-expressions)
8. [Condition & Assert Testing](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#condition--assert-testing)
9. [Dependency Inspection](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#dependency-inspection)
10. [Syscall Filtering Helpers](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#syscall-filtering-helpers)
11. [Configuration Inspection](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#configuration-inspection)
12. [Other Subcommands](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#other-subcommands)
13. [Quick Cheatsheet](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#quick-cheatsheet)

---

## What is systemd-analyze?

`systemd-analyze` is a multi-purpose inspection tool for systemd. Its subcommands fall into a few categories:

- **Boot performance** — how long boot took, what caused delays
- **Unit correctness** — validate unit files before deploying them
- **Security** — score a service's sandbox exposure
- **Expression parsing** — validate calendar and timespan syntax used in timers
- **Dependency graphs** — visualize unit relationships
- **System configuration** — inspect compiled-in defaults and kernel settings

Most subcommands work on the system instance. Add `--user` to inspect the user systemd instance.

```sh
systemd-analyze [SUBCOMMAND] [OPTIONS] [ARGS]
```

---

## Boot Timing

### Overall boot time

```sh
systemd-analyze
# or
systemd-analyze time
```

Example output:

```
Startup finished in 2.764s (firmware) + 1.207s (loader) + 3.891s (kernel)
               + 4.203s (initrd) + 12.447s (userspace) = 24.512s

graphical.target reached after 12.331s in userspace.
```

The phases:

|Phase|Description|
|---|---|
|`firmware`|UEFI / BIOS time before bootloader|
|`loader`|Bootloader (GRUB, systemd-boot)|
|`kernel`|Kernel decompression and init|
|`initrd`|initramfs processing|
|`userspace`|From PID 1 start to the default target|

> **Note:** The firmware and loader times are only available on UEFI systems that expose this via EFI variables.

### Per-unit blame list

```sh
systemd-analyze blame
```

Lists every unit that ran during boot, sorted by how long it took to start (slowest first):

```
  7.241s NetworkManager-wait-online.service
  4.102s plymouth-quit-wait.service
  3.887s dev-sda1.device
  1.203s apt-daily-upgrade.service
   843ms snapd.service
   ...
```

This is the fastest first step for identifying what is slowing down boot. Units near the top are candidates for disabling, masking, or deferring.

### Filter to user instance

```sh
systemd-analyze blame --user
systemd-analyze time --user
```

---

## Critical Chain

Shows the **critical path** through the boot — the sequence of units where each one had to wait for the previous before it could start. This is the chain that determined total boot time.

```sh
systemd-analyze critical-chain
```

Example output:

```
The time when unit became active or started is printed after the "@" character.
The time the unit took to start is printed after the "+" character.

graphical.target @12.331s
└─multi-user.target @12.330s
  └─sshd.service @12.100s +229ms
    └─network.target @12.089s
      └─NetworkManager.service @3.204s +8.884s
        └─dbus.service @3.082s +119ms
          └─basic.target @3.078s
            └─sockets.target @3.077s
              └─...
```

`@` = when the unit became active (wall-clock offset from boot)  
`+` = how long that unit took to start

### Critical chain for a specific unit

```sh
systemd-analyze critical-chain sshd.service
systemd-analyze critical-chain postgresql.service
```

Useful when a specific service starts late and you want to know what it was waiting for.

---

## Visualizing the Boot

### SVG boot chart

```sh
systemd-analyze plot > boot.svg
```

Generates an SVG timeline of all units — their start times and durations — displayed as horizontal bars. Open with any browser or SVG viewer.

```sh
systemd-analyze plot > boot.svg && xdg-open boot.svg
```

The chart shows:

- Each unit as a horizontal bar
- Bar width = activation time
- Color-coded by unit type
- Critical path highlighted

### Dependency graph (DOT format)

```sh
systemd-analyze dot | dot -Tsvg > deps.svg
systemd-analyze dot | dot -Tpng > deps.png
```

Requires `graphviz` (`dot` command) to render. The output can be very large on a full system.

#### Filter the graph

```sh
# Only show dependencies of a specific unit
systemd-analyze dot sshd.service | dot -Tsvg > sshd-deps.svg

# Only certain unit types
systemd-analyze dot --to-pattern='*.target' --from-pattern='*.service' \
  | dot -Tsvg > service-to-target.svg
```

Options:

|Option|Effect|
|---|---|
|`--to-pattern=GLOB`|Only show edges pointing to matching units|
|`--from-pattern=GLOB`|Only show edges from matching units|
|`--order`|Include only ordering edges (Before=/After=)|
|`--require`|Include only requirement edges (Wants=/Requires=)|

---

## Unit File Verification

### Verify a unit file

```sh
systemd-analyze verify /etc/systemd/system/myapp.service
systemd-analyze verify myapp.service           # searches standard paths
```

Checks for:

- Syntax errors
- Unknown directives (with warnings)
- Unresolvable dependencies
- Missing `ExecStart=`
- Invalid values for known directives
- Inconsistent `Type=` and `ExecStart=` combinations

Example output:

```
/etc/systemd/system/myapp.service:12: Unknown key name 'ExecctStart' in section 'Service', ignoring.
/etc/systemd/system/myapp.service: Service has no ExecStart=, ExecStop=, or SuccessAction=. Refusing.
```

No output = no issues found.

### Verify multiple units at once

```sh
systemd-analyze verify /etc/systemd/system/*.service
```

### Verify against a different root

```sh
systemd-analyze --root=/mnt/chroot verify myapp.service
# Useful for validating units in a chroot or disk image before booting
```

### Verify with an image

```sh
systemd-analyze --image=/path/to/disk.img verify myapp.service
```

---

## Security Analysis

### Score a service's sandbox

```sh
systemd-analyze security nginx
systemd-analyze security myapp.service
```

Prints a table of hardening options with their current status, and an overall **exposure score**:

```
  NAME                                                        DESCRIPTION
✗ UserOrDynamicUser=                                         Service runs as root user
✓ SupplementaryGroups=                                       Service has no supplementary groups
✗ PrivateDevices=                                            Service potentially has access to hardware devices
✓ PrivateMounts=                                             Service cannot install system mounts
✗ PrivateNetwork=                                            Service has access to the host network
...

→ Overall exposure level for nginx.service: 9.2 UNSAFE 😨
```

**Score interpretation:**

|Range|Rating|
|---|---|
|0.0–3.9|OK|
|4.0–7.9|MEDIUM|
|8.0–9.9|EXPOSED|
|10.0|UNSAFE|

Lower is better (more hardened).

### Score multiple services

```sh
systemd-analyze security                      # scores all running services
systemd-analyze security --no-pager           # without paging
```

### Use security output to harden a unit

The table shows exactly which `[Service]` directives are missing. Use it as a checklist:

```sh
systemd-analyze security myapp.service 2>&1 | grep '✗'
```

Then add the flagged directives to your unit file or a drop-in:

```ini
[Service]
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
PrivateDevices=yes
RestrictAddressFamilies=AF_INET AF_INET6
SystemCallFilter=@system-service
```

Re-run `systemd-analyze security` after each change to track improvement.

---

## Calendar & Timespan Expressions

### Validate a calendar expression (for `OnCalendar=` in timers)

```sh
systemd-analyze calendar "Mon..Fri 09:00:00"
systemd-analyze calendar "daily"
systemd-analyze calendar "*:0/15"
systemd-analyze calendar "*-*-* 02:30:00"
```

Example output:

```
  Original form: Mon..Fri 09:00:00
Normalized form: Mon..Fri *-*-* 09:00:00
    Next elapse: Mon 2024-01-15 09:00:00 UTC
       (in UTC): Mon 2024-01-15 09:00:00 UTC
       From now: 14h 23min left
```

Shows the normalized form, the next trigger time, and how long until it fires.

### Show multiple upcoming triggers

```sh
systemd-analyze calendar --iterations=5 "Mon..Fri 09:00:00"
```

Prints the next 5 trigger times.

### Common calendar expressions to validate

```sh
systemd-analyze calendar "hourly"
systemd-analyze calendar "daily"
systemd-analyze calendar "weekly"
systemd-analyze calendar "monthly"
systemd-analyze calendar "annually"
systemd-analyze calendar "quarterly"       # every 3 months
systemd-analyze calendar "semiannually"    # every 6 months

systemd-analyze calendar "*:0/5"           # every 5 minutes
systemd-analyze calendar "*:0/30"          # every 30 minutes
systemd-analyze calendar "Sat,Sun 10:00"   # weekends at 10am
systemd-analyze calendar "2024-01-*"       # every day in January 2024
```

### Validate a timespan expression (for `RestartSec=`, `TimeoutSec=`, etc.)

```sh
systemd-analyze timespan 5min
systemd-analyze timespan "1h 30min"
systemd-analyze timespan 500ms
systemd-analyze timespan 2d
```

Output:

```
Original: 1h 30min
      μs: 5400000000
   Human: 1h 30min
```

Timespan units: `us` (microseconds), `ms`, `s` / `sec`, `min`, `h` / `hr`, `d`, `w`, `month`, `year`.

---

## Condition & Assert Testing

Unit files support `Condition*=` and `Assert*=` directives that gate whether a unit starts. `systemd-analyze condition` evaluates them without starting anything.

```sh
systemd-analyze condition 'ConditionPathExists=/etc/myapp/config.yml'
systemd-analyze condition 'ConditionKernelVersion=>=5.15'
systemd-analyze condition 'AssertFileNotEmpty=/etc/passwd'
```

### Multiple conditions at once

```sh
systemd-analyze condition \
  'ConditionPathExists=/etc/myapp/config.yml' \
  'ConditionEnvironment=MYAPP_ENABLED'
```

### Test conditions from a unit file directly

```sh
systemd-analyze verify --man=no myapp.service
```

### Available condition types

```
ConditionArchitecture=
ConditionVirtualization=          # vm, container, kvm, qemu, docker, etc.
ConditionHost=
ConditionKernelCommandLine=
ConditionKernelVersion=
ConditionEnvironment=
ConditionSecurity=                 # selinux, apparmor, smack, ima, tomoyo, audit
ConditionCapability=
ConditionUser=
ConditionGroup=
ConditionControlGroupController=
ConditionPathExists=
ConditionPathExistsGlob=
ConditionPathIsDirectory=
ConditionPathIsSymbolicLink=
ConditionPathIsMountPoint=
ConditionPathIsReadWrite=
ConditionPathIsEncrypted=
ConditionDirectoryNotEmpty=
ConditionFileNotEmpty=
ConditionFileIsExecutable=
ConditionNeedsUpdate=             # /usr or /etc needs update
ConditionFirstBoot=               # true on first boot after installation
ConditionMemory=                  # minimum memory in bytes
ConditionCPUs=                    # minimum CPU count
ConditionCPUFeature=              # CPU feature flags
ConditionOSRelease=
ConditionMemoryPressure=
ConditionCPUPressure=
ConditionIOPressure=
```

---

## Dependency Inspection

### List all units in the boot transaction

```sh
systemd-analyze dump
```

Dumps the complete internal state of systemd — every unit, its properties, dependencies, and current state. Very verbose; pipe through `grep` or `less`.

```sh
systemd-analyze dump | grep -A 20 "nginx.service"
```

### Unit paths

```sh
systemd-analyze unit-paths
```

Prints all directories systemd searches for unit files, in priority order:

```
/etc/systemd/system.control
/run/systemd/system.control
/run/systemd/transient
/run/systemd/generator.early
/etc/systemd/system
/etc/systemd/system.attached
/run/systemd/system
/run/systemd/system.attached
/run/systemd/generator
/usr/local/lib/systemd/system
/usr/lib/systemd/system
/run/systemd/generator.late
```

---

## Syscall Filtering Helpers

systemd groups syscalls into named sets for use with `SystemCallFilter=` in service units.

### List all syscall sets

```sh
systemd-analyze syscall-filter
```

Prints every predefined set and the syscalls it contains:

```
@aio
    io_cancel io_destroy io_getevents io_pgetevents io_setup io_submit io_uring_enter ...

@basic-io
    _llseek close close_range dup dup2 dup3 fstat fstatfs ...

@system-service
    (includes @basic-io @io-event @ipc @network-io @process @signals @sync @timer ...)
```

### Show a specific set

```sh
systemd-analyze syscall-filter @network-io
systemd-analyze syscall-filter @privileged
systemd-analyze syscall-filter @system-service
```

Common sets used in hardening:

|Set|Contains|
|---|---|
|`@system-service`|Reasonable default for most daemons|
|`@basic-io`|Read, write, open, close|
|`@network-io`|Socket, connect, send, recv|
|`@process`|Fork, exec, wait|
|`@privileged`|Syscalls requiring root / capabilities|
|`@obsolete`|Rarely used, legacy syscalls|
|`@raw-io`|Direct hardware I/O (ioperm, iopl)|
|`@reboot`|Reboot, kexec|
|`@swap`|swapon, swapoff|
|`@debug`|ptrace, perf|

### Use in a unit

```ini
[Service]
# Allow only typical service syscalls
SystemCallFilter=@system-service

# Explicitly deny privileged syscalls on top of that
SystemCallFilter=~@privileged ~@raw-io
```

---

## Configuration Inspection

### Show compiled-in defaults

```sh
systemd-analyze cat-config systemd/system.conf
systemd-analyze cat-config systemd/journald.conf
systemd-analyze cat-config systemd/logind.conf
systemd-analyze cat-config systemd/networkd.conf
systemd-analyze cat-config systemd/resolved.conf
systemd-analyze cat-config systemd/timesyncd.conf
```

Shows the effective configuration by merging all drop-in files, in the same way systemd itself reads them. Equivalent to `systemctl cat` but for daemon configuration files rather than unit files.

### Show kernel command line

```sh
systemd-analyze kernel-command-line
```

Prints the kernel command line as parsed by systemd, with each parameter on its own line.

### Show the log level

```sh
systemd-analyze log-level             # print current log level
systemd-analyze log-level debug       # set log level to debug at runtime
systemd-analyze log-level info        # restore to info
```

### Show the log target

```sh
systemd-analyze log-target            # print current log target
systemd-analyze log-target journal    # set to journal
systemd-analyze log-target console    # set to console
```

### Service watchdog information

```sh
systemd-analyze service-watchdogs          # show if watchdogs are enabled globally
systemd-analyze service-watchdogs on       # enable
systemd-analyze service-watchdogs off      # disable
```

---

## Other Subcommands

### `exit-status`

Look up an exit status code by number or name:

```sh
systemd-analyze exit-status 1
systemd-analyze exit-status FAILURE
systemd-analyze exit-status 127
systemd-analyze exit-status SIGTERM
```

Output explains what the code means and what signal caused it (if any).

### `capability`

Look up Linux capability names and numbers:

```sh
systemd-analyze capability               # list all capabilities
systemd-analyze capability cap_net_bind_service
systemd-analyze capability 10
```

Useful when writing `CapabilityBoundingSet=` or `AmbientCapabilities=` in service units.

### `filesystems`

List known filesystem types (for use with `ConditionFileSystem=`):

```sh
systemd-analyze filesystems
```

### `inspect-elf`

Inspect ELF binary metadata relevant to systemd (e.g. `sd_notify` support, OS info in binary):

```sh
systemd-analyze inspect-elf /usr/sbin/nginx
```

### `malloc`

Show which malloc implementation is in use by systemd:

```sh
systemd-analyze malloc
```

---

## Quick Cheatsheet

### Boot performance

|Command|Action|
|---|---|
|`systemd-analyze`|Total boot time|
|`systemd-analyze blame`|Per-unit times, slowest first|
|`systemd-analyze critical-chain`|What caused boot delays|
|`systemd-analyze critical-chain UNIT`|What delayed a specific unit|
|`systemd-analyze plot > boot.svg`|Visual boot timeline|
|`systemd-analyze dot \| dot -Tsvg > g.svg`|Dependency graph|

### Unit validation

|Command|Action|
|---|---|
|`systemd-analyze verify FILE`|Check unit file for errors|
|`systemd-analyze verify *.service`|Check multiple units|
|`systemd-analyze cat-config systemd/system.conf`|Effective daemon config|
|`systemd-analyze unit-paths`|Unit file search paths|
|`systemd-analyze condition 'ConditionX=Y'`|Test a condition expression|

### Security

|Command|Action|
|---|---|
|`systemd-analyze security`|Score all running services|
|`systemd-analyze security NAME`|Score a specific service|
|`systemd-analyze syscall-filter`|List all syscall sets|
|`systemd-analyze syscall-filter @SET`|Show syscalls in a set|
|`systemd-analyze capability`|List all Linux capabilities|

### Timer & timespan

|Command|Action|
|---|---|
|`systemd-analyze calendar EXPR`|Validate + preview calendar|
|`systemd-analyze calendar --iterations=N EXPR`|Show next N trigger times|
|`systemd-analyze timespan EXPR`|Validate a timespan|

### Runtime control

|Command|Action|
|---|---|
|`systemd-analyze log-level`|Show current log level|
|`systemd-analyze log-level debug`|Set log level|
|`systemd-analyze exit-status N`|Look up exit status code|

### Flags

|Flag|Meaning|
|---|---|
|`--user`|Operate on the user systemd instance|
|`--system`|Operate on the system instance (default)|
|`--global`|Operate on global user configuration|
|`--root=PATH`|Use an alternate root directory|
|`--image=PATH`|Use a disk image|
|`--no-pager`|Don't pipe output through a pager|
|`--iterations=N`|Number of iterations (calendar subcommand)|
|`--man=no`|Skip man page checks during verify|

---

_Source: `man systemd-analyze` and [systemd.io](https://systemd.io/). Subcommand availability varies by systemd version — check `systemd-analyze --version` and your distribution's systemd release._