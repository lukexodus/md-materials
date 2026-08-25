## Log Analysis


### Overview

Log analysis is essential for troubleshooting issues, monitoring system health, and understanding system behavior on Arch Linux. Systemd's journalctl and traditional log files provide comprehensive system activity records.

### Systemd Journal (journalctl)

#### Basic Journal Viewing

**View entire journal:**
```
journalctl
```

Displays all logged messages; use arrow keys or Page Up/Down to navigate.

**View recent logs:**
```
journalctl -n 50
```

Shows last 50 entries.

**Follow logs in real-time:**
```
journalctl -f
```

Similar to `tail -f`; shows new entries as they're logged.

**Follow with last 20 lines:**
```
journalctl -fn 20
```

#### Filtering by Time

**Current boot:**
```
journalctl -b
```

Shows logs from current boot session.

**Previous boot:**
```
journalctl -b -1
```

Use `-2`, `-3`, etc., for older boots.

**List available boots:**
```
journalctl --list-boots
```

**Since specific time:**
```
journalctl --since "2025-11-01 10:00:00"
journalctl --since "1 hour ago"
journalctl --since yesterday
journalctl --since today
```

**Until specific time:**
```
journalctl --until "2025-11-01 12:00:00"
```

**Time range:**
```
journalctl --since "2025-11-01" --until "2025-11-02"
```

**Last hour:**
```
journalctl --since "1 hour ago"
```

#### Filtering by Priority

**Priority levels (syslog standard):**
- 0: emerg (emergency)
- 1: alert
- 2: crit (critical)
- 3: err (error)
- 4: warning
- 5: notice
- 6: info
- 7: debug

**Show errors only:**
```
journalctl -p err
```

**Show warnings and above:**
```
journalctl -p warning
```

**Critical messages from current boot:**
```
journalctl -b -p crit
```

**Errors from today:**
```
journalctl -p err --since today
```

#### Filtering by Service/Unit

**Specific service:**
```
journalctl -u sshd.service
```

**Multiple services:**
```
journalctl -u sshd.service -u systemd-logind.service
```

**Kernel messages:**
```
journalctl -k
```

Or:
```
journalctl _TRANSPORT=kernel
```

**All systemd messages:**
```
journalctl _SYSTEMD_UNIT=systemd-journald.service
```

#### Filtering by Process

**By PID:**
```
journalctl _PID=1234
```

**By executable:**
```
journalctl /usr/bin/firefox
```

**By command:**
```
journalctl _COMM=firefox
```

#### Output Formatting

**Verbose output (all fields):**
```
journalctl -o verbose
```

**JSON format:**
```
journalctl -o json
```

**JSON pretty-print:**
```
journalctl -o json-pretty
```

**Short format (default):**
```
journalctl -o short
```

**Cat format (no metadata):**
```
journalctl -o cat
```

**Timestamped:**
```
journalctl -o short-iso
```

ISO 8601 timestamps.

### Common Troubleshooting Queries

#### Boot Issues

**Check last boot errors:**
```
journalctl -b -p err
```

**Boot process messages:**
```
journalctl -b -u systemd-boot
journalctl -b | grep -i boot
```

**Failed to start services:**
```
systemctl --failed
journalctl -u failed-service.service
```

**Kernel panics or crashes:**
```
journalctl -k -p crit
```

#### Service Problems

**Check specific service:**
```
journalctl -u service-name.service -b
```

**Service with errors:**
```
journalctl -u service-name.service -p err
```

**Recent service activity:**
```
journalctl -u service-name.service --since "10 minutes ago"
```

**Follow service logs:**
```
journalctl -u service-name.service -f
```

#### Network Issues

**NetworkManager logs:**
```
journalctl -u NetworkManager -b
```

**DHCP issues:**
```
journalctl -u dhcpcd -b
```

**DNS resolution:**
```
journalctl -u systemd-resolved -b
```

**SSH connection attempts:**
```
journalctl -u sshd.service | grep "Failed password"
```

#### Hardware Issues

**All kernel messages:**
```
journalctl -k
```

**Hardware errors:**
```
journalctl -k -p err
```

**USB device events:**
```
journalctl -k | grep -i usb
```

**Disk/storage issues:**
```
journalctl -k | grep -i "error\|fail" | grep -i "sd\|nvme"
```

#### Authentication and Security

**Failed login attempts:**
```
journalctl _SYSTEMD_UNIT=systemd-logind.service | grep "Failed"
```

**Sudo usage:**
```
journalctl _COMM=sudo
```

**PAM authentication:**
```
journalctl | grep pam
```

**All authentication events:**
```
journalctl -t sshd -t sudo -t login
```

### Package Management Logs

#### Pacman Log File

**Location:**
```
/var/log/pacman.log
```

**View recent operations:**
```
tail -n 100 /var/log/pacman.log
```

**Search for specific package:**
```
grep "package-name" /var/log/pacman.log
```

**Last system upgrade:**
```
grep "starting full system upgrade" /var/log/pacman.log | tail -1
```

**Recently installed packages:**
```
grep "installed" /var/log/pacman.log | tail -20
```

**Recently removed packages:**
```
grep "removed" /var/log/pacman.log | tail -20
```

**Packages updated today:**
```
grep "$(date +%Y-%m-%d)" /var/log/pacman.log | grep "upgraded"
```

**Transaction errors:**
```
grep "error:" /var/log/pacman.log | tail -20
```

**All operations on specific package:**
```
grep -E "(installed|upgraded|removed) package-name" /var/log/pacman.log
```

### Advanced Journal Queries

#### Complex Filtering

**Multiple conditions:**
```
journalctl -u sshd.service -p err --since "1 hour ago"
```

**Exclude specific units:**
```
journalctl -b | grep -v "systemd-udevd"
```

**Boolean logic with grep:**
```
journalctl -b | grep -E "(error|fail|critical)"
```

#### Investigating Specific Issues

**Memory issues:**
```
journalctl -b | grep -i "out of memory\|oom"
```

**Disk full errors:**
```
journalctl -b | grep -i "no space left"
```

**Segmentation faults:**
```
journalctl -b | grep "segfault"
```

**Coredumps:**
```
journalctl -b | grep -i "core dump"
coredumpctl list
```

**Permission denied errors:**
```
journalctl -b | grep -i "permission denied"
```

### Journal Maintenance

#### Check Journal Size

**Disk usage:**
```
journalctl --disk-usage
```

**Example output:**
```
Archived and active journals take up 512.0M in the file system.
```

#### Clean Old Logs

**By time (keep 2 weeks):**
```
sudo journalctl --vacuum-time=2weeks
```

**By size (keep 500MB):**
```
sudo journalctl --vacuum-size=500M
```

**By number of files:**
```
sudo journalctl --vacuum-files=5
```

**Verify cleanup:**
```
journalctl --disk-usage
```

#### Configure Journal Limits

**Edit configuration:**
```
sudo nano /etc/systemd/journald.conf
```

**Common settings:**
```ini
[Journal]
SystemMaxUse=500M
SystemKeepFree=1G
SystemMaxFileSize=100M
MaxRetentionSec=2week
```

**Apply changes:**
```
sudo systemctl restart systemd-journald
```

### Traditional Log Files

#### Important Log Locations

**System logs directory:**
```
/var/log/
```

**Common log files:**
```
/var/log/Xorg.0.log          # X server
/var/log/pacman.log          # Package manager
/var/log/boot.log            # Boot messages (if configured)
/var/log/btmp                # Failed logins
/var/log/wtmp                # Login records
```

**Application logs:**
```
~/.xsession-errors           # X session errors
~/.local/share/xorg/         # User X logs
```

#### Viewing Traditional Logs

**Xorg logs:**
```
cat /var/log/Xorg.0.log
grep -i "error\|warning" /var/log/Xorg.0.log
```

**Last logins:**
```
last -n 20
```

**Failed login attempts:**
```
sudo lastb
```

### Log Analysis Tools

#### grep for Pattern Matching

**Case-insensitive search:**
```
journalctl -b | grep -i "error"
```

**Multiple patterns:**
```
journalctl -b | grep -E "error|fail|critical"
```

**Inverted match (exclude):**
```
journalctl -b | grep -v "Started"
```

**Count occurrences:**
```
journalctl -b | grep -c "error"
```

**Context lines:**
```
journalctl -b | grep -A 5 -B 5 "error"
```

Shows 5 lines before and after each match.

#### awk for Field Extraction

**Extract specific fields:**
```
journalctl -o short | awk '{print $1, $2, $5}'
```

**Filter by field value:**
```
journalctl -o short | awk '$5 == "sshd"'
```

**Count by service:**
```
journalctl -b -o json | jq -r '._SYSTEMD_UNIT' | sort | uniq -c | sort -rn | head
```

#### less for Interactive Viewing

**Search while viewing:**
```
journalctl -b | less
```

In less:
- `/pattern` - Search forward
- `?pattern` - Search backward
- `n` - Next match
- `N` - Previous match
- `q` - Quit

### Practical Analysis Scenarios

#### Scenario 1: System Won't Boot

**From recovery environment:**
```
# Mount system
mount /dev/sdXn /mnt
journalctl --root=/mnt -b -1 -p err
```

Analyzes previous boot's errors.

#### Scenario 2: Service Keeps Crashing

**View crash history:**
```
journalctl -u service-name.service --since "24 hours ago"
```

**Find crash pattern:**
```
journalctl -u service-name.service | grep -B 5 "Failed\|Stopped"
```

**Check resource limits:**
```
journalctl -u service-name.service | grep -i "limit\|resource"
```

#### Scenario 3: Performance Issues

**High load investigation:**
```
journalctl -b | grep -i "cpu\|load\|performance"
```

**Memory pressure:**
```
journalctl -b | grep -i "memory\|swap"
```

**I/O issues:**
```
journalctl -k | grep -i "i/o error"
```

#### Scenario 4: Security Audit

**All authentication events:**
```
journalctl -b | grep -i "auth\|login\|sudo"
```

**Failed access attempts:**
```
journalctl -b | grep -i "failed\|denied\|invalid"
```

**Privilege escalation:**
```
journalctl _COMM=sudo
```

**Account changes:**
```
journalctl | grep -i "user\|group\|password"
```

### Automated Log Analysis

#### Daily Error Summary Script

```bash
#!/bin/bash
# Daily error summary

REPORT="/tmp/error-report-$(date +%Y%m%d).txt"

echo "=== Daily Error Summary ===" > "$REPORT"
echo "Date: $(date)" >> "$REPORT"
echo "" >> "$REPORT"

# Critical errors
echo "Critical Errors:" >> "$REPORT"
journalctl --since today -p crit --no-pager >> "$REPORT"
echo "" >> "$REPORT"

# Service failures
echo "Failed Services:" >> "$REPORT"
systemctl --failed --no-pager >> "$REPORT"
echo "" >> "$REPORT"

# Kernel errors
echo "Kernel Errors:" >> "$REPORT"
journalctl -k --since today -p err --no-pager >> "$REPORT"

# Email or display report
cat "$REPORT"
```

#### Log Monitoring with Alerts

```bash
#!/bin/bash
# Monitor for critical messages

journalctl -f -p crit | while read line; do
    echo "CRITICAL: $line"
    notify-send "Critical System Error" "$line"
    # Or send email
    # echo "$line" | mail -s "Critical Error" admin@example.com
done
```

### Best Practices

**Regular review:** Check logs weekly for warnings and errors.

**Prioritize errors:** Focus on error and critical messages first.

**Use filters:** Narrow logs to specific services or time periods.

**Correlate events:** Look for patterns across different logs.

**Archive important logs:** Save logs from critical incidents.

**Clean regularly:** Prevent logs from consuming excessive disk space.

**Monitor in real-time:** Use `journalctl -f` during troubleshooting.

**Understand context:** Read surrounding messages, not just the error line.

**Document findings:** Keep notes on recurring issues and solutions.

**Learn patterns:** Recognize common error messages and their meanings.

Effective log analysis is critical for maintaining system health, diagnosing problems quickly, and understanding system behavior on Arch Linux.

