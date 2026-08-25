## systemd Journaling


### journalctl Usage

The `journalctl` command serves as the primary interface for querying and displaying logs from the systemd journal. It provides powerful filtering and formatting capabilities for system log analysis.

**Basic journalctl commands:**

- `journalctl` - Shows all journal entries from oldest to newest
- `journalctl -r` - Shows entries in reverse chronological order (newest first)
- `journalctl -f` - Follows the journal in real-time (similar to `tail -f`)
- `journalctl -e` - Jumps to the end of the journal
- `journalctl -n 50` - Shows last 50 entries
- `journalctl --no-pager` - Outputs without pagination

**Output formatting options:**

- `journalctl -o short` - Default format with timestamp and message
- `journalctl -o verbose` - Shows all available fields for each entry
- `journalctl -o json` - Outputs entries in JSON format
- `journalctl -o json-pretty` - Pretty-printed JSON format
- `journalctl -o cat` - Shows only the message field
- `journalctl -o export` - Binary export format suitable for backup

**Time-based navigation:**

- `journalctl --since "2024-01-01"` - Shows entries since specific date
- `journalctl --since "1 hour ago"` - Relative time specification
- `journalctl --until "2024-12-31"` - Shows entries until specific date
- `journalctl --since "09:00" --until "17:00"` - Time range within current day
- `journalctl --since yesterday` - Natural language time references
- `journalctl --since "2024-01-01 10:00:00" --until "2024-01-01 11:00:00"` - Precise time range

**Boot-specific logs:**

- `journalctl -b` - Shows logs from current boot
- `journalctl -b -1` - Shows logs from previous boot
- `journalctl -b 2` - Shows logs from specific boot (by boot ID)
- `journalctl --list-boots` - Lists all available boot sessions
- `journalctl -b --since "10 minutes ago"` - Combines boot and time filtering

**Advanced usage patterns:**

- `journalctl -k` - Shows kernel messages only (equivalent to dmesg)
- `journalctl --vacuum-time=2weeks` - Removes journal files older than 2 weeks
- `journalctl --disk-usage` - Shows current disk usage by journal files
- `journalctl --verify` - Verifies journal file integrity
- `journalctl --flush` - Flushes all journal data to persistent storage

### Journal Filtering

The systemd journal supports sophisticated filtering mechanisms to help administrators focus on relevant log entries. Multiple filter criteria can be combined for precise log analysis.

**Unit-based filtering:**

- `journalctl -u service-name` - Shows logs for specific service
- `journalctl -u service-name.service` - Explicit service unit specification
- `journalctl -u "pattern*"` - Wildcard matching for multiple units
- `journalctl -u service1 -u service2` - Multiple specific units
- `journalctl --user-unit=user-service` - User session services

**Priority-based filtering:**

- `journalctl -p err` - Shows error-level messages and above
- `journalctl -p warning..err` - Shows messages between warning and error levels
- `journalctl -p 3` - Numeric priority levels (0=emerg, 7=debug)
- `journalctl -p crit` - Critical messages only

**Priority levels (syslog standard):**

- `emerg` (0) - System is unusable
- `alert` (1) - Action must be taken immediately
- `crit` (2) - Critical conditions
- `err` (3) - Error conditions
- `warning` (4) - Warning conditions
- `notice` (5) - Normal but significant conditions
- `info` (6) - Informational messages
- `debug` (7) - Debug-level messages

**Field-based filtering:**

- `journalctl _PID=1234` - Messages from specific process ID
- `journalctl _UID=1000` - Messages from specific user ID
- `journalctl _COMM=sshd` - Messages from specific command
- `journalctl _HOSTNAME=server01` - Messages from specific hostname
- `journalctl _TRANSPORT=kernel` - Messages from specific transport

**Combining filters:** Multiple filter criteria use AND logic by default:

```bash
journalctl -u nginx.service -p err --since "1 hour ago"
journalctl _SYSTEMD_UNIT=sshd.service _PID=1234
```

**Pattern matching:**

- `journalctl -g "pattern"` - Grep-like pattern matching in message text
- `journalctl -g "error|fail"` - Regular expression patterns
- `journalctl --case-sensitive -g "Error"` - Case-sensitive matching

**Field enumeration:**

- `journalctl -F _SYSTEMD_UNIT` - Lists all available systemd units in journal
- `journalctl -F _COMM` - Lists all commands that have logged messages
- `journalctl -F _PID` - Lists all process IDs in journal

### Persistent vs Volatile Logs

The systemd journal can operate in different storage modes, affecting log persistence across system reboots. Understanding these modes is crucial for log management strategy.

**Storage configuration:** The journal storage behavior is controlled by the `Storage` setting in `/etc/systemd/journald.conf`:

**Storage modes:**

- `persistent` - Logs stored in `/var/log/journal/` and survive reboots
- `volatile` - Logs stored in `/run/log/journal/` and lost on reboot
- `auto` - Uses persistent if `/var/log/journal/` exists, otherwise volatile
- `none` - Disables journal storage (forwards to other log systems only)

**Persistent storage setup:** To enable persistent logging:

```bash
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
sudo systemctl restart systemd-journald
```

**Storage locations:**

- **Persistent**: `/var/log/journal/machine-id/`
- **Volatile**: `/run/log/journal/machine-id/`
- **Configuration**: `/etc/systemd/journald.conf`

**Advantages of persistent logs:**

- Survive system reboots and crashes
- Enable historical analysis and trend identification
- Support forensic investigation of past incidents
- Maintain audit trails for compliance requirements

**Advantages of volatile logs:**

- Reduce wear on storage devices (especially SSDs)
- Prevent log files from consuming excessive disk space
- Faster log writing performance
- Automatic cleanup on reboot

**Hybrid approaches:** Some systems use both persistent and volatile logging:

- Critical system logs stored persistently
- Application logs stored in volatile memory
- Log forwarding to centralized logging systems

**Configuration considerations:** Key settings in `/etc/systemd/journald.conf`:

```ini
[Journal]
Storage=persistent
SystemMaxUse=1G
SystemMaxFileSize=100M
SystemMaxFiles=10
MaxRetentionSec=1month
```

### Journal Maintenance

Proper journal maintenance ensures optimal system performance and prevents storage exhaustion while maintaining necessary log retention for troubleshooting and compliance.

**Disk usage monitoring:**

- `journalctl --disk-usage` - Shows current journal disk usage
- `du -sh /var/log/journal/` - Direct filesystem usage check
- `systemd-analyze plot > boot-analysis.svg` - Boot performance analysis using journal data

**Manual cleanup operations:**

- `journalctl --vacuum-time=1month` - Removes entries older than 1 month
- `journalctl --vacuum-size=500M` - Keeps only 500MB of journal data
- `journalctl --vacuum-files=5` - Keeps only 5 most recent journal files
- `journalctl --rotate` - Forces journal rotation before cleanup

**Automated maintenance configuration:** Journal maintenance is primarily configured in `/etc/systemd/journald.conf`:

**Size-based limits:**

- `SystemMaxUse=1G` - Maximum disk space for persistent journal
- `SystemKeepFree=500M` - Minimum free space to maintain on filesystem
- `SystemMaxFileSize=100M` - Maximum size of individual journal files
- `SystemMaxFiles=10` - Maximum number of journal files to keep
- `RuntimeMaxUse=100M` - Maximum disk space for volatile journal
- `RuntimeMaxFileSize=10M` - Maximum size of volatile journal files

**Time-based retention:**

- `MaxRetentionSec=1month` - Maximum age of journal entries
- `MaxFileSec=1week` - Maximum age of individual journal files before rotation

**Verification and integrity:**

- `journalctl --verify` - Checks journal file integrity
- `journalctl --verify --file=/var/log/journal/*/system.journal` - Verifies specific files
- `systemctl status systemd-journald` - Monitors journal daemon health

**Performance optimization:**

- `Compress=yes` - Enables compression for journal entries
- `SyncIntervalSec=5m` - Controls sync frequency to disk
- `RateLimitInterval=30s` - Rate limiting for excessive logging
- `RateLimitBurst=1000` - Maximum messages per rate limit interval

**Log forwarding configuration:**

- `ForwardToSyslog=yes` - Forwards messages to traditional syslog
- `ForwardToKMsg=no` - Controls forwarding to kernel log buffer
- `ForwardToConsole=no` - Controls console message forwarding
- `ForwardToWall=yes` - Controls wall message forwarding

**Backup strategies:**

- `journalctl -o export > backup.journal` - Export journal in binary format
- `journalctl --since="2024-01-01" --until="2024-12-31" -o json > yearly-logs.json` - JSON export for specific periods
- Regular synchronization to centralized logging infrastructure

**Monitoring and alerting:** Implement monitoring for journal health:

- Disk usage thresholds
- Journal service status
- Log ingestion rates
- Error message frequency patterns

**Key points** for effective journal maintenance include establishing appropriate retention policies, monitoring disk usage regularly, configuring automatic cleanup mechanisms, and implementing backup strategies for critical log data. Regular verification of journal integrity helps ensure log reliability for troubleshooting and audit purposes.

---

