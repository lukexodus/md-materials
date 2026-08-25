## Logging and journald Management


### systemd-journald Overview

**Purpose**: Systemd-journald is the centralized logging service included with systemd, collecting logs from the kernel, services, and system utilities into a unified journal. It replaces traditional syslog mechanisms with a more structured, queryable logging system.[1][2]

**Log Collection**: Journald aggregates messages from all system services, the Linux kernel, and user processes, providing comprehensive system activity records.[2][3]

**Structured Logging**: Unlike traditional text logs, journald stores logs with structured metadata including timestamps, process information, priority levels, and custom fields.[1]

### Journal Service Management

**Service**: `systemd-journald.service` runs by default in Arch Linux.[1]

**Enable/Start**: The service is typically enabled by default; manually enable with `systemctl enable --now systemd-journald`.[1]

**User Journal**: User-level journald instances run for unprivileged users via `systemd-journald@user-NNNN.service`.[1]

### Basic Journal Queries

**View Recent Logs**: `journalctl` displays recent journal entries in reverse chronological order.[3][4][1]

**Follow Logs in Real-Time**: `journalctl -f` continuously displays new log entries as they are generated.[4][3]

**Show Last N Lines**: `journalctl -n 50` displays the last 50 journal entries.[4]

**Combine Options**: `journalctl -f -n 20` follows logs while showing the last 20 entries.[4]

### Filtering Journal Entries

**By Service**: `journalctl -u [service]` displays logs for a specific service.[3][4]

**Example**: `journalctl -u nginx.service -n 100` shows the last 100 nginx log entries.[4]

**By Time Range**:[3]
- **`--since "YYYY-MM-DD HH:MM:SS"`**: Logs since specified time[3]
- **`--until "YYYY-MM-DD HH:MM:SS"`**: Logs until specified time[3]
- **`--since "1 hour ago"`**: Logs from the past hour[3]
- **`--since "today"`**: Logs from today[3]

**By Priority Level**: `journalctl -p [level]` filters by log severity.[4][3]

**Priority Levels**:[4]
- **`0` or `emerg`**: Emergency[4]
- **`1` or `alert`**: Alert[4]
- **`2` or `crit`**: Critical[4]
- **`3` or `err`**: Error[4]
- **`4` or `warning`**: Warning[4]
- **`5` or `notice`**: Notice[4]
- **`6` or `info`**: Informational[4]
- **`7` or `debug`**: Debug[4]

**Example**: `journalctl -p err -n 50` displays last 50 error messages.[4]

**By Boot**: `journalctl -b` displays logs from the current boot.[3]

**Previous Boot**: `journalctl -b -1` shows logs from the previous boot.[3]

**By Process ID**: `journalctl _PID=1234` displays logs from specific process.[3]

**By Executable**: `journalctl /usr/bin/nginx` shows logs from specific executable.[3]

### Journal Output Formats

**Default Format**: Readable human format with timestamp and priority.[1]

**Verbose Format**: `journalctl -o verbose` displays all metadata fields.[3]

**JSON Format**: `journalctl -o json` outputs logs as JSON objects.[1][3]

**Short Format**: `journalctl -o short` displays condensed output.[1]

**Timestamp Variations**:[1]
- **`-o short-iso`**: ISO 8601 timestamp format[1]
- **`-o short-precise`**: High-precision timestamps[1]
- **`-o short-monotonic`**: Monotonic timestamps since boot[1]

### Journal Storage and Persistence

**Default Storage**: By default, journald stores logs in `/run/log/journal/` (volatile, cleared on reboot).[1]

**Persistent Storage**: Configure permanent log storage in `/var/log/journal/`.[1]

**Enable Persistence**: Create the directory and configure storage:[1]

```
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald
```

**Verify**: `journalctl --disk-usage` shows current journal size.[1][4]

### Journal Configuration

**Configuration File**: `/etc/systemd/journald.conf` controls journald behavior.[1]

**Key Settings**:[1]
- **`Storage=`**: Storage location (`volatile`, `persistent`, `auto`)[1]
- **`Compress=`**: Compress old journals (yes/no)[1]
- **`RateLimitInterval=` and `RateLimitBurst=`**: Rate limiting to prevent log flooding[1]
- **`SystemMaxUse=`**: Maximum journal size on disk[1]
- **`SystemMaxFileSize=`**: Maximum size per journal file[1]
- **`MaxFileSec=`**: Rotate journal files this frequency[1]

**Example Configuration**:[1]

```
[Journal]
Storage=persistent
Compress=yes
SystemMaxUse=500M
SystemMaxFileSize=100M
RateLimitInterval=1min
RateLimitBurst=1000
```

**Reload Configuration**: `sudo systemctl restart systemd-journald` applies changes.[1]

### Journal Disk Usage Management

**View Disk Usage**: `journalctl --disk-usage` displays total journal size.[4][1]

**Vacuum by Size**: `sudo journalctl --vacuum-size=500M` removes old logs to reduce size.[4][1]

**Vacuum by Time**: `sudo journalctl --vacuum-time=30d` removes logs older than 30 days.[4][1]

**Vacuum by Files**: `sudo journalctl --vacuum-files=5` keeps only 5 journal files.[1]

### Exporting and Analyzing Logs

**Export to File**: `journalctl > journal_export.txt` saves logs to text file.[3]

**Export as JSON**: `journalctl -o json > journal_export.json` exports structured data.[3]

**Pipe to grep**: `journalctl | grep "error"` searches for specific keywords [3].

**Complex Filtering**: 

```bash
journalctl -u nginx.service -p err --since "2024-01-15" --until "2024-01-16" -o json
```

This displays error messages from nginx between specific dates in JSON format.[3]

### Journal Metadata Fields

**Accessible Fields**: Query specific metadata with underscore-prefixed variables:[1]

- **`_PID`**: Process ID[1]
- **`_UID`**: User ID[1]
- **`_GID`**: Group ID[1]
- **`_HOSTNAME`**: Host name[1]
- **`PRIORITY`**: Log level priority[1]
- **`SYSLOG_IDENTIFIER`**: Syslog identifier (service name)[1]
- **`MESSAGE`**: Log message text[1]
- **`_COMM`**: Command name[1]
- **`_EXE`**: Executable path[1]

### Practical Logging Examples

**Troubleshoot Boot Issues**: `journalctl -b 0 -p err` shows errors from current boot.[3]

**Monitor Service Restart**: `journalctl -u [service] -f` follows service in real-time during restart.[2]

**Audit Failed Login Attempts**: `journalctl SYSLOG_IDENTIFIER=sudo` displays sudo execution logs.[3]

**Kernel Messages**: `journalctl -k` displays kernel logs.[3]

**Last 100 System Errors**: `journalctl -p 3 -n 100` shows last 100 critical/error messages.[4]

### Forwarding Logs to Syslog

**Legacy Support**: For compatibility with traditional syslog utilities, install `syslog-ng`.[1]

**Configuration**: Systemd-journald can forward logs to external logging systems.[1]

### Journal Security

**Access Control**: Regular users see only their own service logs; root sees all logs.[1]

**Sensitive Data**: Logs may contain passwords or sensitive configuration; restrict access appropriately.[1]

**Audit Trail**: All journal entries include creation timestamps and source identification for accountability.[1]

### Integration with Log Aggregation

**External Tools**: Tools like `lnav` (log navigator) and `multitail` provide enhanced log viewing.[3]

**Centralized Logging**: Enterprise setups forward journald output to centralized logging services like ELK Stack or Splunk.[1]

Sources
[1] systemd - ArchWiki https://wiki.archlinux.org/title/Systemd
[2] How to use systemctl to manage services and units https://www.ionos.com/digitalguide/server/configuration/systemctl/
[3] How to Enable and Manage systemd Services on Arch Linux https://www.siberoloji.com/how-to-enable-and-manage-systemd-services-on-arch-linux/
[4] Managing systemd Services: Install, Start, Stop, Pause, and ... https://sphere10.com/articles/how-to/linux/managing-systemd-services-install-start-stop-pause-and-resume

