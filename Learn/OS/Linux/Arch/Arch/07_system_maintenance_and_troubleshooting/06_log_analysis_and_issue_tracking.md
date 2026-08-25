## Log Analysis and Issue Tracking


### System Logging Overview

**Purpose**: Logs record system events, service activities, and application behavior for diagnostics and troubleshooting .

**Primary Logger**: Systemd-journald centralizes log collection from all sources .

**Accessibility**: Users can query comprehensive system history via journalctl .

### Journalctl Log Queries

#### Basic Log Viewing

**View Recent Logs**: `journalctl` displays logs in reverse chronological order :

```bash
journalctl
```

**Follow Real-Time**: `journalctl -f` displays new entries as generated :

```bash
journalctl -f
```

**Last N Lines**: `journalctl -n 100` shows last 100 entries :

```bash
journalctl -n 50
```

#### Service-Specific Logs

**Query Service**: `journalctl -u servicename` filters logs by service :

```bash
journalctl -u nginx.service
```

**Recent Service Logs**: Combine with `-n` :

```bash
journalctl -u nginx.service -n 50
```

**Follow Service**: Real-time monitoring :

```bash
journalctl -u nginx.service -f
```

### Time-Based Log Analysis

#### Date and Time Filtering

**Since Specific Time**: `journalctl --since` :

```bash
journalctl --since "2025-01-15 10:00:00"
```

**Time Ranges** :
- **`--since "1 hour ago"`**: Last hour 
- **`--since "today"`**: Since midnight 
- **`--since "yesterday"`**: Previous day 
- **`--since "1 week ago"`**: Past week 

**Until Specific Time** :

```bash
journalctl --until "2025-01-15 15:00:00"
```

**Combined Range** :

```bash
journalctl --since "1 hour ago" --until "now"
```

#### Boot-Specific Logs

**Current Boot**: `journalctl -b` or `journalctl --boot=0` :

```bash
journalctl -b
```

**Previous Boot**: `journalctl -b -1` :

```bash
journalctl -b -1
```

**Boot List**: `journalctl --list-boots` shows available boots :

```bash
journalctl --list-boots
```

### Priority and Severity Filtering

#### Priority Levels

**Log Levels** (0=emergency to 7=debug) :
- **`0` or `emerg`**: Emergency 
- **`1` or `alert`**: Alert 
- **`2` or `crit`**: Critical 
- **`3` or `err`**: Error 
- **`4` or `warning`**: Warning 
- **`5` or `notice`**: Notice 
- **`6` or `info`**: Informational 
- **`7` or `debug`**: Debug 

#### Priority Filtering

**Errors Only**: `journalctl -p err` :

```bash
journalctl -p err
```

**Warnings and Above**: `journalctl -p warning` includes warning, err, alert, emerg :

```bash
journalctl -p warning
```

**Debug Messages**: `journalctl -p debug` includes all messages :

```bash
journalctl -p debug
```

### Output Formatting

#### Display Formats

**Verbose Output**: `journalctl -o verbose` shows all metadata :

```bash
journalctl -o verbose
```

**JSON Format**: `journalctl -o json` outputs machine-readable format :

```bash
journalctl -o json | jq .
```

**Short Format**: `journalctl -o short` condensed output :

```bash
journalctl -o short
```

**ISO Timestamps**: `journalctl -o short-iso` uses ISO 8601 format :

```bash
journalctl -o short-iso
```

#### Piping and Analysis

**Search Keyword**: Pipe through grep :

```bash
journalctl | grep "error"
```

**Count Occurrences** :

```bash
journalctl | grep "Failed" | wc -l
```

**Extract Field**: `journalctl -o json | jq '.MESSAGE'` :

```bash
journalctl -o json | jq -r '.MESSAGE' | head -10
```

### Identifying Common Issues

#### Authentication Failures

**SSH Login Attempts**:[1]

```bash
journalctl -u sshd.service | grep "Failed"
```

**Sudo Usage**:[1]

```bash
journalctl SYSLOG_IDENTIFIER=sudo
```

**Failed Auth Count** :

```bash
journalctl | grep -i "authentication failure" | wc -l
```

#### Service Failures

**Failed Service Boot** :

```bash
systemctl list-units --failed
```

**Service Specific Error**:[1]

```bash
journalctl -u service.service -p err
```

**Service Restart Loop** :

```bash
journalctl -u service.service | grep "Restart"
```

#### System Errors

**Kernel Panics**:[1]

```bash
journalctl -p crit | grep -i "panic"
```

**Out of Memory**:[1]

```bash
journalctl | grep -i "out of memory"
```

**Critical Errors** :

```bash
journalctl -p crit -n 50
```

#### Hardware Issues

**Device Disconnection**:[1]

```bash
journalctl | grep -i "removed"
```

**USB Problems**:[1]

```bash
journalctl | grep -i "usb"
```

**Storage Errors**:[1]

```bash
journalctl | grep -i "I/O error"
```

### Log Persistence

#### Storage Configuration

**Volatile Storage**: Default `/run/log/journal/`.[2]

**Persistent Storage**: Enable `/var/log/journal/`:[2]

```bash
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald
```

**Verify Persistence** :

```bash
journalctl --list-boots
```

#### Log Retention

**Maximum Size**: Configure in `/etc/systemd/journald.conf` :

```
SystemMaxUse=500M
SystemMaxFileSize=100M
```

**Disk Usage**: `journalctl --disk-usage` :

```bash
journalctl --disk-usage
```

**Vacuum Storage** :

```bash
sudo journalctl --vacuum-size=500M
sudo journalctl --vacuum-time=30d
```

### Exporting and Backing Up Logs

#### Export to File

**Text Export** :

```bash
journalctl > system_logs.txt
```

**JSON Export** :

```bash
journalctl -o json > logs.json
```

**Specific Timeframe**:[1]

```bash
journalctl --since "2025-01-15" --until "2025-01-16" > daily_log.txt
```

#### Backup Procedures

**Archive Logs**:[1]

```bash
tar -czf logs_backup.tar.gz /var/log/journal/
```

**Export Critical Logs**:[1]

```bash
journalctl -p err --since "1 week ago" > critical_logs.txt
```

### Kernel Messages

#### dmesg Ring Buffer

**Kernel Logs**: `dmesg` displays kernel message buffer:[1]

```bash
dmesg
```

**Follow Output**: `dmesg -w` watches new messages:[1]

```bash
dmesg -w
```

**Recent Messages**:[1]

```bash
dmesg | tail -50
```

#### Kernel Errors

**Error Search**:[1]

```bash
dmesg | grep -i error
```

**Warnings**:[1]

```bash
dmesg | grep -i warning
```

**Hardware Detection**:[1]

```bash
dmesg | grep -i "detected\|found"
```

### Application-Specific Logs

#### Web Server Logs

**Nginx Error Log**:[1]

```bash
sudo tail -f /var/log/nginx/error.log
```

**Apache Error Log**:[1]

```bash
sudo tail -f /var/log/apache2/error.log
```

#### Database Logs

**MySQL**:[1]

```bash
sudo tail -f /var/log/mysql/error.log
```

**PostgreSQL**:[1]

```bash
sudo tail -f /var/log/postgresql/postgresql.log
```

#### Package Manager

**Pacman Logs**:[1]

```bash
grep "installed\|removed" /var/log/pacman.log
```

**Installation History**:[1]

```bash
tail -20 /var/log/pacman.log
```

### Troubleshooting Workflows

#### System Won't Boot

**Check Bootloader Logs**:[1]

```bash
journalctl -b -1 | grep -i "error\|failed"  # Previous boot
```

**Kernel Messages**:[1]

```bash
dmesg | grep -i "panic\|fatal\|error"
```

**Filesystem Check**:[1]

```bash
journalctl | grep -i "fsck\|filesystem"
```

#### Service Malfunction

**Check Service Status** :

```bash
systemctl status service.service
journalctl -u service.service -n 50
```

**Dependencies**:[1]

```bash
journalctl -u service.service | grep -i "dependency\|require"
```

**Recent Changes**:[1]

```bash
journalctl -u service.service --since "1 day ago"
```

#### Performance Issues

**System Load**:[1]

```bash
journalctl | grep -i "load\|memory\|cpu"
```

**Process Issues**:[1]

```bash
journalctl | grep -i "oom\|out of memory"
```

**I/O Problems**:[1]

```bash
journalctl | grep -i "I/O\|block"
```

### Log Analysis Tools

#### lnav (Log Navigator)

**Installation**: `sudo pacman -S lnav` .

**Usage** :

```bash
lnav /var/log
lnav /var/log/nginx
```

**Features** :
- Colorized output 
- Pattern matching 
- Timeline view 

#### grep and awk

**Complex Filtering** :

```bash
journalctl -o json | jq -r 'select(.PRIORITY<3) | .MESSAGE'
```

**Statistics** :

```bash
journalctl | awk '{print $NF}' | sort | uniq -c | sort -rn
```

### Documentation and Alerting

#### Log Aggregation

**Rsyslog**: Forward logs to central server.[1]

**Enterprise Tools**: ELK Stack, Splunk.[1]

**Network Monitoring**: graylog, Loki.[1]

### Best Practices

**Regular Review**: Check logs weekly.[1]

**Alert on Errors**: Monitor critical errors immediately.[1]

**Archive Logs**: Keep historical logs for analysis.[1]

**Search Strategically**: Combine multiple filters .

**Document Findings**: Record issues and resolutions.[1]

**Automate Alerts**: Set up notifications for critical events.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] fstab - ArchWiki https://wiki.archlinux.org/title/Fstab

