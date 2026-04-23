# journalctl

`journalctl` is the command-line tool for querying and displaying logs from **systemd-journald**, the journal daemon that collects and stores structured log data from the kernel, initrd, services, and user processes.

---

## How the Journal Works

- Logs are stored in **binary format** in `/var/log/journal/` (persistent) or `/run/log/journal/` (volatile, lost on reboot).
- Each entry is structured — it carries metadata (unit name, PID, UID, priority, timestamp, etc.) alongside the message.
- `journalctl` is the query interface. It reads and filters this structured data.

### Persistent vs Volatile Storage

```bash
# Check where your journal is stored
ls /var/log/journal/     # exists → persistent storage
ls /run/log/journal/     # volatile only → logs lost on reboot
```

To enable persistent storage:

```bash
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
sudo systemctl restart systemd-journald
```

Or set in `/etc/systemd/journald.conf`:

```ini
[Journal]
Storage=persistent    # always persist
# Storage=volatile    # always use /run (lost on reboot)
# Storage=auto        # persist if /var/log/journal exists (default)
```

---

## Basic Usage

```bash
# Show all logs (oldest first, opens in pager)
journalctl

# Show all logs, newest first
journalctl -r

# Follow new log entries in real time (like tail -f)
journalctl -f

# Show last N lines
journalctl -n 50
journalctl -n 100 -f    # last 100 lines, then follow
```

---

## Filtering by Unit (Service)

```bash
# Logs for a specific service
journalctl -u nginx
journalctl -u nginx.service    # equivalent

# Follow a service's logs
journalctl -u nginx -f

# Logs for multiple units
journalctl -u nginx -u php-fpm

# Logs for a user unit
journalctl --user -u myapp
```

---

## Filtering by Time

```bash
# Logs since a specific time
journalctl --since "2024-06-01 00:00:00"
journalctl --since "2024-06-01"

# Logs until a specific time
journalctl --until "2024-06-30 23:59:59"

# Time range
journalctl --since "2024-06-01" --until "2024-06-30"

# Relative time expressions
journalctl --since "1 hour ago"
journalctl --since "30 min ago"
journalctl --since yesterday
journalctl --since today
journalctl --since "2 days ago"

# Combine with unit filter
journalctl -u nginx --since "1 hour ago"
```

---

## Filtering by Boot

```bash
# Logs from the current boot only
journalctl -b
journalctl -b 0      # same — 0 means current boot

# Logs from the previous boot
journalctl -b -1

# Two boots ago
journalctl -b -2

# List all recorded boots with their IDs
journalctl --list-boots

# Logs from a specific boot by ID
journalctl -b <boot-id>

# Combine with unit
journalctl -b -1 -u nginx
```

---

## Filtering by Priority (Log Level)

Priorities follow the syslog standard. Specifying a level shows that level **and above** (more severe).

|Value|Name|Meaning|
|---|---|---|
|0|`emerg`|System is unusable|
|1|`alert`|Immediate action required|
|2|`crit`|Critical condition|
|3|`err`|Error condition|
|4|`warning`|Warning condition|
|5|`notice`|Normal but significant|
|6|`info`|Informational|
|7|`debug`|Debug-level messages|

```bash
# Show errors and above (err, crit, alert, emerg)
journalctl -p err

# Show warnings and above
journalctl -p warning

# Show only a specific priority level (use .. range)
journalctl -p err..err       # only errors, not crit/alert/emerg
journalctl -p warning..err   # warnings and errors only

# Combine with unit and time
journalctl -u nginx -p err --since today
```

---

## Filtering by Process / PID / UID

```bash
# Logs from a specific PID
journalctl _PID=1234

# Logs from a specific user ID
journalctl _UID=1000

# Logs from a specific group ID
journalctl _GID=1000

# Logs from a specific executable
journalctl _EXE=/usr/sbin/nginx

# Logs from a specific command name
journalctl _COMM=nginx

# Combine fields (AND logic)
journalctl _UID=1000 _COMM=python3

# OR logic: separate with + on its own
journalctl _UID=1000 + _UID=0
```

---

## Filtering by Kernel / Syslog Facility

```bash
# Kernel messages only
journalctl -k
journalctl --dmesg          # same

# Kernel messages from last boot
journalctl -k -b -1

# By syslog facility
journalctl SYSLOG_FACILITY=0    # kern
journalctl SYSLOG_FACILITY=3    # daemon
journalctl SYSLOG_FACILITY=4    # auth
```

---

## Output Formats

```bash
# Default (human-readable, paged)
journalctl

# Short formats
journalctl -o short             # default: timestamp, host, unit, message
journalctl -o short-precise     # microsecond timestamps
journalctl -o short-monotonic   # monotonic timestamps (seconds since boot)
journalctl -o short-unix        # Unix epoch timestamps
journalctl -o short-iso         # ISO 8601 timestamps
journalctl -o short-full        # full timestamp with timezone

# Verbose / structured
journalctl -o verbose           # all fields for each entry
journalctl -o json              # one JSON object per line
journalctl -o json-pretty       # pretty-printed JSON
journalctl -o json-sse          # JSON formatted for server-sent events
journalctl -o export            # binary export format
journalctl -o cat               # message text only, no metadata
```

### JSON output example

```bash
# Parse logs with jq
journalctl -u nginx -o json | jq '._MESSAGE'
journalctl -u nginx -o json-pretty | jq '{time: .__REALTIME_TIMESTAMP, msg: .MESSAGE}'

# Export to a file
journalctl -u nginx -o json > nginx-logs.json
```

---

## Searching / Grep

The journal has no built-in full-text search flag, but you can pipe to `grep`:

```bash
journalctl -u nginx | grep "404"
journalctl -u nginx --since today | grep -i "error"

# With colour preserved
journalctl -u nginx --no-pager | grep --color "failed"

# Using journalctl's built-in grep (systemd 245+)
journalctl -g "pattern"
journalctl -g "GET /api" -u nginx
```

---

## Pager Control

```bash
# Disable pager (print everything to stdout)
journalctl --no-pager

# Useful for scripting or piping
journalctl -u nginx --no-pager | wc -l
journalctl --no-pager -o cat -u myapp | tail -50

# Set a custom pager
SYSTEMD_PAGER=less journalctl
```

---

## Disk Usage and Maintenance

```bash
# Show how much disk space the journal uses
journalctl --disk-usage

# Rotate journal files (archive current active files)
sudo journalctl --rotate

# Delete old journal data by time
sudo journalctl --vacuum-time=7d      # keep last 7 days
sudo journalctl --vacuum-time=1month  # keep last month
sudo journalctl --vacuum-time=1year

# Delete old journal data by size
sudo journalctl --vacuum-size=500M    # keep only 500 MB
sudo journalctl --vacuum-size=1G

# Delete old data by number of files
sudo journalctl --vacuum-files=5      # keep only 5 journal files

# Verify journal file integrity
sudo journalctl --verify
```

### Configure journal size limits persistently

```ini
# /etc/systemd/journald.conf

[Journal]
SystemMaxUse=500M           # max total disk use (persistent)
SystemKeepFree=1G           # always keep this much disk free
SystemMaxFileSize=50M       # max size of a single journal file
SystemMaxFiles=10           # max number of journal files to keep
RuntimeMaxUse=100M          # max use in /run (volatile)
MaxRetentionSec=1month      # max age of journal entries
```

```bash
sudo systemctl restart systemd-journald
```

---

## Journal Fields Reference

Fields can be used as filters: `journalctl FIELD=value`

### Automatically set by journald

|Field|Description|
|---|---|
|`_HOSTNAME`|Hostname of the machine|
|`_TRANSPORT`|How the message arrived (`journal`, `syslog`, `kernel`, `stdout`, `audit`)|
|`_PID`|Process ID|
|`_UID`|User ID of the process|
|`_GID`|Group ID|
|`_COMM`|Command name (basename of executable)|
|`_EXE`|Path to the executable|
|`_CMDLINE`|Full command line|
|`_SYSTEMD_UNIT`|Systemd unit name|
|`_SYSTEMD_USER_UNIT`|User unit name|
|`_SYSTEMD_SLICE`|Cgroup slice|
|`_BOOT_ID`|Boot ID (UUID)|
|`_MACHINE_ID`|Machine ID|
|`__REALTIME_TIMESTAMP`|Wall clock time (microseconds since epoch)|
|`__MONOTONIC_TIMESTAMP`|Monotonic time since boot (microseconds)|

### Set by the logging process (trusted if from journal, not syslog)

|Field|Description|
|---|---|
|`MESSAGE`|The log message|
|`PRIORITY`|Syslog priority (0–7)|
|`SYSLOG_FACILITY`|Syslog facility number|
|`SYSLOG_IDENTIFIER`|Syslog tag / program name|
|`CODE_FILE`|Source file (if set by the program)|
|`CODE_LINE`|Source line number|
|`CODE_FUNC`|Function name|

```bash
# List all unique values of a field
journalctl -F _SYSTEMD_UNIT     # list all units that have logged
journalctl -F _TRANSPORT
journalctl -F PRIORITY
```

---

## Remote / Container Logs

```bash
# Read a journal from a directory (e.g. a copied /var/log/journal)
journalctl -D /path/to/journal/dir

# Read from a journal file directly
journalctl --file /var/log/journal/<machine-id>/system.journal

# Merge multiple journal files
journalctl --file /path/a.journal --file /path/b.journal

# Read logs from a container or chroot
journalctl -D /var/lib/machines/mycontainer/var/log/journal
```

---

## Forwarding Logs

### Forward to syslog

```ini
# /etc/systemd/journald.conf
[Journal]
ForwardToSyslog=yes
```

### Forward to /dev/console

```ini
ForwardToConsole=yes
TTYPath=/dev/tty12     # which console
```

### Forward to kmsg

```ini
ForwardToKMsg=yes
```

### Forward to a remote journal (systemd-journal-remote)

```bash
sudo apt install systemd-journal-remote

# On the receiving host
sudo systemctl enable --now systemd-journal-remote.socket

# On the sending host
sudo apt install systemd-journal-upload
# Configure /etc/systemd/journal-upload.conf
sudo systemctl enable --now systemd-journal-upload
```

---

## Practical Tips

**`-f` + `-u` is your daily driver.** `journalctl -u myservice -f` tails a service's logs in real time — the first thing to run when troubleshooting a service.

**`-b` keeps context clean.** Adding `-b` to any query limits output to the current boot, which cuts out old noise immediately.

**`--no-pager` for scripting.** Any time you pipe `journalctl` output into another command, add `--no-pager` to prevent the pager from intercepting the pipe.

**`-o cat` for clean message-only output.** Strips all metadata. Useful when you only care about the message text:

```bash
journalctl -u myapp -o cat --no-pager
```

**`-o json | jq` for structured analysis.** The journal's binary format carries rich metadata. Exporting to JSON and processing with `jq` lets you do things grep cannot:

```bash
journalctl -u nginx -o json --no-pager \
  | jq -r 'select(.PRIORITY <= "3") | .MESSAGE'
```

**Check `--disk-usage` regularly.** On systems with verbose logging, the journal can grow large. Set `SystemMaxUse` in `journald.conf` to cap it.

**`--since today` is faster than a time range.** It is a shorthand that resolves to midnight of the current day, which is quicker to type and easy to remember.

**Use `--list-boots` to navigate incidents.** When investigating a crash or reboot, `journalctl --list-boots` shows you all recorded boots with timestamps. Pick the relevant boot ID and use `-b <id>` to scope all queries to that boot.

```bash
# Full incident workflow
journalctl --list-boots
journalctl -b -1 -p err          # errors from last boot
journalctl -b -1 -u myservice    # full service log from last boot
journalctl -b -1 -k              # kernel messages from last boot
```

> **[Inference]** Some features (e.g. `-g` for grep, newer output formats) require systemd 245 or later. Verify with `journalctl --version` on your system.