# Syllabus

## 1. Log File Fundamentals

- Common log file locations
- Log file formats (plaintext, JSON, XML, binary)
- Timestamp formats and time zones
- Log rotation and compression
- Log file permissions and ownership
- System vs application logs

## 2. Linux System Logs

- /var/log/syslog and /var/log/messages
- /var/log/auth.log and /var/log/secure
- /var/log/kern.log
- /var/log/dmesg
- /var/log/boot.log
- systemd journal (journalctl)

## 3. Authentication & Access Logs

- SSH login logs
- Failed authentication attempts
- sudo command logs
- PAM (Pluggable Authentication Modules) logs
- wtmp, utmp, btmp analysis
- lastlog examination
- Login session tracking

## 4. Web Server Logs

- Apache access.log format
- Apache error.log analysis
- Nginx access and error logs
- Combined log format (CLF)
- Custom log formats
- Virtual host logs
- SSL/TLS logs

## 5. Application Logs

- PHP error logs
- Python application logs
- Node.js logs
- Java application logs
- Database query logs
- Custom application logging

## 6. Network Service Logs

- FTP server logs (vsftpd, proftpd)
- SMTP mail server logs
- DNS server logs (BIND, dnsmasq)
- DHCP server logs
- Proxy server logs (Squid)
- VPN logs (OpenVPN, WireGuard)

## 7. Firewall & Security Logs

- iptables/nftables logs
- UFW (Uncomplicated Firewall) logs
- fail2ban logs
- SELinux audit logs
- AppArmor logs
- IDS/IPS logs (Snort, Suricata)

## 8. Database Logs

- MySQL/MariaDB logs
- PostgreSQL logs
- MongoDB logs
- Redis logs
- Query logs
- Slow query logs
- Error logs

## 9. Windows Event Logs

- Security event logs
- System event logs
- Application event logs
- Event ID interpretation
- PowerShell logging
- Windows Defender logs

## 10. Command-Line Tools

- grep, egrep, fgrep
- awk and sed
- cut, sort, uniq
- head, tail, less
- wc (word count)
- find and locate
- strings

## 11. Advanced Parsing Tools

- jq (JSON processor)
- xmllint (XML parser)
- csvkit
- awk advanced patterns
- Python one-liners
- Perl one-liners

## 12. Log Aggregation Tools

- Logstash basics
- Filebeat
- rsyslog configuration
- syslog-ng
- Fluentd
- Graylog

## 13. Timeline Analysis

- Event sequencing
- Time correlation
- Time zone conversion
- Chronological reconstruction
- Gap analysis
- Timestamp normalization

## 14. Pattern Recognition

- Regex patterns
- Anomaly detection
- Frequency analysis
- Baseline establishment
- Outlier identification
- Signature matching

## 15. Attack Pattern Identification

- Brute force attempts
- SQL injection indicators
- XSS attack patterns
- Command injection traces
- Path traversal attempts
- File inclusion patterns
- SSRF indicators

## 16. Network Traffic Logs

- tcpdump log analysis
- Wireshark capture files
- NetFlow data
- Zeek (Bro) logs
- Connection logs
- Protocol analysis

## 17. Incident Response Logs

- Process execution logs
- File access logs
- Registry modifications (Windows)
- Memory dump analysis logs
- Persistence mechanisms
- Lateral movement traces

## 18. Container & Virtualization Logs

- Docker container logs
- Kubernetes logs
- LXC/LXD logs
- VMware logs
- VirtualBox logs
- Container runtime logs

## 19. Cloud Service Logs

- AWS CloudTrail
- Azure Activity Logs
- Google Cloud Audit Logs
- S3 access logs
- Lambda function logs
- API Gateway logs

## 20. Log Encoding & Obfuscation

- Base64 encoded data
- URL encoding
- Unicode encoding
- Hex encoding
- Compression artifacts
- Encrypted log sections

## 21. Log Injection Detection

- Log poisoning
- Log forging
- CRLF injection
- Newline injection
- Log tampering indicators
- Integrity verification

## 22. Statistical Analysis

- Log volume analysis
- Event frequency counting
- Distribution analysis
- Correlation coefficients
- Moving averages
- Percentile calculations

## 23. Visualization Techniques

- gnuplot usage
- matplotlib for log data
- Elastic Stack visualization
- Grafana basics
- Timeline charts
- Heat maps

## 24. Scripting & Automation

- Bash scripting for log analysis
- Python log parsing libraries
- Regular expression building
- Loop constructs for batch processing
- Pipeline chaining
- Output formatting

## 25. Kali Linux Specific Tools

- logwatch
- swatch
- MultiTail
- ccze (colorized log viewer)
- lnav (log navigator)
- angle-grinder (agrind)

## 26. Forensic Log Analysis

- Log artifact preservation
- Chain of custody
- Hash verification
- Write-blocker usage
- Evidence extraction
- Deleted log recovery

## 27. CTF-Specific Techniques

- Flag format recognition
- Hidden data in logs
- Steganography in logs
- Code obfuscation
- Puzzle solving from logs
- Multi-stage challenges

## 28. Log File Formats

- Syslog format (RFC 3164, RFC 5424)
- JSON logs
- CSV logs
- Binary logs
- Windows EVT/EVTX
- Proprietary formats

## 29. Data Extraction

- IP address extraction
- Email extraction
- URL extraction
- Username enumeration
- Credential harvesting
- Hash extraction

## 30. Correlation Analysis

- Multi-source correlation
- User activity tracking
- Session reconstruction
- Attack chain mapping
- Pivot point identification
- Cross-reference techniques

## 31. Performance & Optimization

- Large file handling
- Memory-efficient parsing
- Parallel processing
- Indexed searching
- Caching strategies
- Stream processing

## 32. Output & Reporting

- Summary generation
- Report formatting
- Evidence presentation
- Key finding extraction
- IOC (Indicator of Compromise) lists
- Timeline documentation

## 33. Log Analysis Frameworks

- SIEM concepts
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Splunk basics
- Graylog
- OSSEC
- Wazuh

## 34. Cryptographic Artifacts in Logs

- SSL/TLS handshake logs
- Certificate information
- Cipher suite identification
- Encryption protocol logs
- Key exchange logs
- Hash algorithm usage

## 35. Malware Activity Indicators

- C2 communication patterns
- Backdoor connections
- Persistence mechanisms
- File system modifications
- Registry changes (Windows)
- Scheduled task logs

## 36. Web Application Attack Logs

- OWASP Top 10 indicators
- API abuse patterns
- Rate limiting bypass
- Authentication bypass attempts
- Session hijacking traces
- CSRF attack patterns

## 37. Data Exfiltration Detection

- Large data transfers
- Unusual protocols
- Off-hours activity
- Compression indicators
- Encryption before transfer
- Staging directories

## 38. Troubleshooting & Debugging

- Incomplete logs
- Corrupted log files
- Missing timestamps
- Encoding issues
- Truncated entries
- Circular log buffers

---

**Note**: [Inference] This syllabus is structured for CTF log analysis challenges and assumes availability of standard Kali Linux tools. Specific tool capabilities and log formats may vary by challenge.

---

# Log File Fundamentals

## Common Log File Locations

### Linux/Unix Systems

**System-wide logs:**

- `/var/log/` - Primary log directory for most Linux distributions
- `/var/log/syslog` or `/var/log/messages` - General system activity (Debian/Ubuntu vs RHEL/CentOS)
- `/var/log/auth.log` or `/var/log/secure` - Authentication attempts, sudo usage, SSH sessions
- `/var/log/kern.log` - Kernel messages and hardware events
- `/var/log/dmesg` - Boot-time kernel ring buffer messages
- `/var/log/boot.log` - System boot sequence information

**Service-specific logs:**

- `/var/log/apache2/` or `/var/log/httpd/` - Apache web server logs
    - `access.log` - HTTP requests
    - `error.log` - Server errors and warnings
- `/var/log/nginx/` - Nginx web server logs
- `/var/log/mysql/` or `/var/log/mariadb/` - Database server logs
- `/var/log/postgresql/` - PostgreSQL database logs
- `/var/log/vsftpd.log` - FTP server activity
- `/var/log/mail.log` - Mail server (Postfix, Sendmail, etc.)
- `/var/log/cron` - Scheduled task execution

**Application logs:**

- `/var/log/apt/` - Package management (Debian/Ubuntu)
- `/var/log/yum.log` - Package management (RHEL/CentOS)
- `/var/log/fail2ban.log` - Intrusion prevention service
- `/var/log/ufw.log` - Uncomplicated Firewall logs
- `/var/log/audit/audit.log` - SELinux/audit daemon events

**User-specific:**

- `~/.bash_history` - Bash command history per user
- `~/.zsh_history` - Zsh command history
- `~/.mysql_history` - MySQL client command history
- `~/.python_history` - Python interpreter history

### Windows Systems

**Event Logs (viewed via Event Viewer or `wevtutil`):**

- `C:\Windows\System32\winevt\Logs\`
    - `Security.evtx` - Authentication, privilege use, object access
    - `System.evtx` - System component events, drivers, services
    - `Application.evtx` - Application-specific events
    - `Setup.evtx` - Installation and update events
    - `Forwarded Events.evtx` - Events from remote systems

**Common application logs:**

- `C:\inetpub\logs\LogFiles\` - IIS web server logs
- `C:\Windows\NTDS\` - Active Directory database and logs
- `C:\Program Files\` - Application-specific subdirectories
- `C:\ProgramData\` - Hidden directory with application data/logs

**PowerShell logs:**

- PowerShell operational logs in Event Viewer under `Applications and Services Logs > Microsoft > Windows > PowerShell`
- Transcript logs (if enabled) in user-specified locations

**Forensic artifacts:**

- `C:\Windows\Prefetch\` - Application execution artifacts
- `C:\Windows\Tasks\` or `C:\Windows\System32\Tasks\` - Scheduled tasks
- `C:\$Recycle.Bin\` - Deleted file metadata

### Network Devices

**Common paths (varies by vendor):**

- Cisco IOS: `flash:` or `nvram:` (use `show logging`)
- Juniper: `/var/log/` (accessed via CLI or shell)
- Syslog servers: Centralized logging location (configurable)

### Container/Cloud Environments

- Docker: `docker logs <container_id>` or `/var/lib/docker/containers/<container_id>/*-json.log`
- Kubernetes: `kubectl logs <pod_name>` or node-specific paths
- Cloud providers: AWS CloudWatch, Azure Monitor, GCP Cloud Logging (API/console access)

---

## Log File Formats

### Plaintext Logs

**Standard text format** - Most common in Linux/Unix environments.

**Common delimiters:**

- Space-separated: Traditional syslog format
- Tab-separated: Some application logs
- Custom separators: Pipe (`|`), comma (in non-JSON contexts)

**Example (syslog format):**

```
Oct 28 14:23:45 webserver sshd[1234]: Failed password for invalid user admin from 192.168.1.100 port 52341 ssh2
```

**Structure:** `timestamp hostname service[pid]: message`

**Key characteristics:**

- Human-readable
- Easy to grep/parse with basic tools
- No strict schema enforcement
- Variable field counts depending on message type

**Common parsing tools:**

- `grep`, `awk`, `sed` for pattern matching
- `cut` for field extraction
- `tail -f` for real-time monitoring

### JSON Format

**Structured data format** - Increasingly common in modern applications and centralized logging.

**Example:**

```json
{
  "timestamp": "2025-10-28T14:23:45.123Z",
  "level": "ERROR",
  "source_ip": "192.168.1.100",
  "username": "admin",
  "event": "authentication_failure",
  "service": "sshd",
  "pid": 1234
}
```

**Key characteristics:**

- Structured key-value pairs
- Consistent schema (when enforced)
- Easily parsed programmatically
- Supports nested objects and arrays
- Larger file sizes than plaintext

**Parsing tools:**

- `jq` - Command-line JSON processor (essential for CTF)
    
    ```bash
    cat app.log | jq '.source_ip' | sort | uniq -ccat app.log | jq 'select(.level=="ERROR")'
    ```
    
- `python -m json.tool` - Built-in JSON formatter
- Python `json` module for scripting

### XML Format

**Markup-based format** - Common in Windows Event Logs and some enterprise applications.

**Example:**

```xml
<Event>
  <System>
    <EventID>4625</EventID>
    <TimeCreated SystemTime="2025-10-28T14:23:45.123Z"/>
    <Computer>WORKSTATION01</Computer>
  </System>
  <EventData>
    <Data Name="TargetUserName">admin</Data>
    <Data Name="IpAddress">192.168.1.100</Data>
  </EventData>
</Event>
```

**Key characteristics:**

- Hierarchical structure with tags
- Schema validation possible (XSD)
- Verbose compared to JSON
- Self-documenting with tag names
- Windows Event Logs stored as binary but exported as XML

**Parsing tools:**

- `xmllint` - XML parsing and validation
    
    ```bash
    xmllint --xpath '//EventID/text()' event.xml
    ```
    
- `xmlstarlet` - XML transformation and querying
    
    ```bash
    xmlstarlet sel -t -v "//Data[@Name='TargetUserName']" event.xml
    ```
    
- Python `xml.etree.ElementTree` or `lxml` modules

### Binary Formats

**Non-human-readable formats** - Require specific tools to access.

**Common binary log types:**

1. **Windows Event Logs (.evtx)**
    
    - Binary XML format
    - Indexed for performance
    - **Tools:**
        
        ```bash
        # On Windowswevtutil qe Security /f:textGet-WinEvent -LogName Security# On Linux (parsing exported .evtx)python-evtx dump Security.evtxevtx_dump.py Security.evtx
        ```
        
2. **systemd Journal (binary)**
    
    - `/var/log/journal/` or `/run/log/journal/`
    - **Tool:**
        
        ```bash
        journalctl                    # View all logsjournalctl -u sshd.service   # Specific servicejournalctl --since "1 hour ago"journalctl -o json           # Output as JSON
        ```
        
3. **Database logs**
    
    - Some databases use binary formats for transaction logs
    - Require database-specific tools (e.g., MySQL binlog utilities)
4. **Network packet captures (not traditional logs but relevant)**
    
    - `.pcap`, `.pcapng` files
    - **Tools:** `tcpdump`, `tshark`, `Wireshark`

**CTF considerations:**

- Binary logs may hide clues in raw hex data
- Check file headers: `xxd -l 256 logfile` or `hexdump -C logfile | head`
- Magic bytes identify format: `file logfile`

### Compressed/Archived Logs

**Rotation and archival** - Logs are often compressed to save space.

**Common formats:**

- `.gz` - gzip compression: `zcat logfile.gz` or `gunzip -c`
- `.bz2` - bzip2 compression: `bzcat logfile.bz2`
- `.xz` - xz compression: `xzcat logfile.xz`
- `.tar.gz` / `.tgz` - tar archive with gzip: `tar -xzf archive.tar.gz`

**Rotation naming conventions:**

- `logfile.1`, `logfile.2.gz` - incremental rotation
- `logfile-20251028.gz` - date-based rotation

**Direct searching without extraction:**

```bash
zgrep "pattern" logfile.gz
zcat logfile.gz | grep "pattern"
```

---

## Timestamp Formats and Time Zones

### Common Timestamp Formats

**1. Unix Epoch (Seconds since 1970-01-01 00:00:00 UTC)**

```
1730125425
```

- **Conversion:**
    
    ```bash
    date -d @1730125425# Output: Sun Oct 28 14:23:45 UTC 2025
    ```
    
- **Common in:** APIs, databases, system internals

**2. Unix Epoch (Milliseconds)**

```
1730125425123
```

- **Conversion:**
    
    ```bash
    date -d @$(echo 1730125425123 | awk '{print $1/1000}')
    ```
    

**3. ISO 8601 / RFC 3339**

```
2025-10-28T14:23:45Z
2025-10-28T14:23:45.123Z
2025-10-28T14:23:45+08:00
```

- **Format:** `YYYY-MM-DDTHH:MM:SS[.mmm][TZ]`
- **Time zone indicators:**
    - `Z` = UTC (Zulu time)
    - `+HH:MM` or `-HH:MM` = offset from UTC
- **Common in:** JSON logs, modern applications, APIs

**4. RFC 2822 (Email/HTTP date format)**

```
Sun, 28 Oct 2025 14:23:45 +0000
```

- **Common in:** Email headers, HTTP headers

**5. Syslog format (RFC 3164)**

```
Oct 28 14:23:45
```

- **No year** - assumes current year
- **No time zone** - assumes local system time
- **Critical for CTF:** Must determine the system's time zone configuration

**6. Syslog format (RFC 5424)**

```
2025-10-28T14:23:45.123456+00:00
```

- Includes year, fractional seconds, time zone

**7. Apache/Nginx Common Log Format**

```
[28/Oct/2025:14:23:45 +0000]
```

**8. Windows Event Log**

```
2025-10-28T14:23:45.1234567Z
```

- High precision (100-nanosecond intervals)

**9. Custom/Application-specific**

```
28-10-2025 14:23:45
10/28/2025 2:23:45 PM
```

- Varies widely; may require regex patterns for parsing

### Time Zone Handling

**UTC (Coordinated Universal Time)**

- Reference time zone (offset +00:00)
- Most system logs should use UTC for consistency
- **Verification:**
    
    ```bash
    timedatectl                 # Check system timezonecat /etc/timezone           # Debian/Ubuntuls -l /etc/localtime        # Symlink to zoneinfo
    ```
    

**Time zone database locations:**

- `/usr/share/zoneinfo/` - TZ database files

**Converting between time zones:**

```bash
# Convert UTC to specific timezone
TZ='America/New_York' date -d '2025-10-28 14:23:45 UTC'

# Convert specific timezone to UTC
date -u -d '2025-10-28 14:23:45 EST'
```

**Common CTF pitfalls:**

1. **Logs in different time zones** - Correlating events requires normalization
2. **Missing time zone indicators** - Syslog format doesn't include TZ
3. **Daylight Saving Time (DST)** - Changes UTC offset twice yearly
4. **Log rotation around midnight** - May split events across files in different days

**Time synchronization:**

- NTP (Network Time Protocol) should keep systems synchronized
- Check for time drift: `ntpq -p` or `timedatectl show-timesync`
- Desynchronized clocks complicate log correlation in distributed systems

### Parsing Timestamps in CTF Scenarios

**Using `date` for conversion:**

```bash
# Parse various formats to Unix epoch
date -d "Oct 28 14:23:45" +%s
date -d "2025-10-28T14:23:45Z" +%s

# Parse from epoch to human-readable
date -d @1730125425 "+%Y-%m-%d %H:%M:%S"
```

**Using `awk` for timestamp extraction:**

```bash
# Extract timestamp from syslog
awk '{print $1, $2, $3}' /var/log/syslog

# Convert to sortable format
awk '{print $1, $2, $3}' log | while read ts; do date -d "$ts" "+%s"; done
```

**Python for complex parsing:**

```python
from datetime import datetime
import pytz

# Parse ISO 8601
dt = datetime.fromisoformat("2025-10-28T14:23:45+00:00")

# Convert to Unix epoch
epoch = dt.timestamp()

# Parse custom format
dt = datetime.strptime("28/Oct/2025:14:23:45", "%d/%b/%Y:%H:%M:%S")
```

**Time range filtering:**

```bash
# journalctl
journalctl --since "2025-10-28 14:00:00" --until "2025-10-28 15:00:00"

# Using awk with epoch comparison
awk -v start=$(date -d "2025-10-28 14:00" +%s) -v end=$(date -d "2025-10-28 15:00" +%s) \
  '{ts=mktime($0); if(ts>=start && ts<=end) print}' log
```

### Critical CTF Considerations

1. **Always normalize timestamps to UTC** when correlating multiple log sources
2. **Check for clock skew** between systems - may indicate compromise or misconfiguration
3. **Fractional seconds matter** for precise event ordering in high-frequency systems
4. **Year rollover** - Syslog format may create ambiguity if logs span multiple years
5. **Binary timestamp formats** (Windows Event Logs) store as 64-bit integers requiring conversion

**Recommended approach for CTF:**

- Extract all timestamps to Unix epoch format for uniform comparison
- Create a timeline of all events sorted by normalized timestamp
- Flag any time anomalies (backwards time jumps, large gaps, future timestamps)

---

## Log Rotation and Compression

Log rotation prevents disk exhaustion by archiving and compressing old log entries. Understanding rotation mechanisms is critical for CTF scenarios where you need to access historical data or identify when evidence was rotated out.

### logrotate Configuration

Primary configuration file: `/etc/logrotate.conf` Service-specific configs: `/etc/logrotate.d/`

**Key directives:**

```bash
# View main configuration
cat /etc/logrotate.conf

# Check service-specific rotation rules
ls -la /etc/logrotate.d/
cat /etc/logrotate.d/rsyslog
```

**Common rotation parameters:**

- `daily/weekly/monthly` - rotation frequency
- `rotate [n]` - number of rotations to keep
- `compress` - gzip old logs (creates .gz files)
- `delaycompress` - compress on second rotation cycle
- `missingok` - don't error if log is missing
- `notifempty` - don't rotate empty logs
- `create [mode] [owner] [group]` - permissions for new log
- `postrotate/endscript` - commands after rotation

**Manual rotation trigger:**

```bash
# Force rotation for all configs
logrotate -f /etc/logrotate.conf

# Test rotation without executing
logrotate -d /etc/logrotate.conf

# Force rotation for specific service
logrotate -f /etc/logrotate.d/rsyslog

# Check rotation status
cat /var/lib/logrotate/status
```

### Compression Analysis

Rotated logs typically use gzip compression (`.gz` extension). In CTF scenarios, you must decompress to analyze:

```bash
# View compressed log without extracting
zcat /var/log/auth.log.2.gz
zgrep "Failed password" /var/log/auth.log.*.gz

# Search across all compressed auth logs
zgrep -h "session opened" /var/log/auth.log.*.gz | wc -l

# Extract compressed log
gunzip /var/log/syslog.1.gz

# Extract to stdout (preserve original)
gunzip -c /var/log/syslog.1.gz > syslog.1

# Decompress multiple logs
gunzip /var/log/*.gz
```

**Alternative compression formats:**

```bash
# bzip2 compression (.bz2)
bzcat /var/log/messages.1.bz2
bunzip2 /var/log/messages.1.bz2

# xz compression (.xz)
xzcat /var/log/kern.log.1.xz
unxz /var/log/kern.log.1.xz
```

### Rotation Timing Analysis

Determine when logs were rotated to establish timeline gaps:

```bash
# View rotation timestamps
ls -lht /var/log/auth.log*
stat /var/log/auth.log.1

# Check logrotate execution history
grep logrotate /var/log/syslog

# Identify last rotation time
ls -l --time-style=full-iso /var/log/*.gz
```

## Log File Permissions and Ownership

Incorrect permissions can indicate tampering or misconfigurations exploitable in privilege escalation scenarios.

### Standard Permission Patterns

**Critical system logs:**

```bash
# View permissions for key logs
ls -la /var/log/auth.log      # 640 root:adm (typical)
ls -la /var/log/syslog        # 640 root:adm
ls -la /var/log/kern.log      # 640 root:adm
ls -la /var/log/messages      # 640 root:adm

# Check Apache/Nginx logs
ls -la /var/log/apache2/      # 640 root:adm or 644 root:root
ls -la /var/log/nginx/        # 640 root:adm

# Application logs (varies)
ls -la /var/log/mysql/        # Often 640 mysql:adm
```

**Expected ownership patterns:**

- System logs: `root:adm` or `root:root`
- Service logs: `[service_user]:[adm|service_group]`
- Application logs: Application user with appropriate group

### Permission Enumeration Commands

```bash
# Recursively list all log permissions
find /var/log -type f -exec ls -la {} \; 2>/dev/null

# Find world-readable logs (potential info disclosure)
find /var/log -type f -perm -004 2>/dev/null

# Find world-writable logs (tampering risk)
find /var/log -type f -perm -002 2>/dev/null

# Find logs owned by non-root users
find /var/log -type f ! -user root -ls 2>/dev/null

# Check for SUID/SGID on log files (unusual)
find /var/log -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null

# Find logs readable by current user
find /var/log -type f -readable 2>/dev/null
```

### Group Membership Analysis

The `adm` group traditionally provides read access to logs:

```bash
# Check current user's groups
id
groups

# List all users in adm group
getent group adm

# Check if specific user can read logs
sudo -u [username] cat /var/log/auth.log 2>&1

# Enumerate group memberships for privilege escalation
for user in $(cut -d: -f1 /etc/passwd); do 
    groups $user | grep -q adm && echo "$user is in adm group"
done
```

### Permission Modification Detection

```bash
# Check for recent permission changes
find /var/log -type f -mmin -60 -ls   # Modified in last 60 min

# Compare against known-good baseline
stat /var/log/auth.log
getfacl /var/log/auth.log

# Check for extended attributes (rare on logs)
lsattr /var/log/auth.log

# Review audit logs for permission changes
ausearch -m CHMOD -ts recent 2>/dev/null
```

## System vs Application Logs

Understanding log categories helps prioritize analysis during time-constrained CTF scenarios.

### System Logs (Linux)

Located in `/var/log/`, managed by `rsyslog` or `systemd-journald`:

**Primary system logs:**

```bash
# Authentication events (SSH, sudo, login attempts)
/var/log/auth.log          # Debian/Ubuntu
/var/log/secure            # RHEL/CentOS

# General system messages
/var/log/syslog            # Debian/Ubuntu  
/var/log/messages          # RHEL/CentOS

# Kernel ring buffer
/var/log/kern.log
dmesg | less

# Boot messages
/var/log/boot.log

# Cron job execution
/var/log/cron
```

**Quick access commands:**

```bash
# View auth events in real-time
tail -f /var/log/auth.log

# Filter SSH connections
grep sshd /var/log/auth.log

# Last 50 sudo commands
grep sudo /var/log/auth.log | tail -50

# System errors only
grep -i error /var/log/syslog
```

### systemd Journal

Modern systems use `journalctl` for centralized logging:

```bash
# View all logs
journalctl

# Logs since boot
journalctl -b

# Logs from previous boot
journalctl -b -1

# Follow logs (real-time)
journalctl -f

# Filter by service
journalctl -u ssh.service
journalctl -u apache2.service

# Filter by priority
journalctl -p err           # Errors only
journalctl -p warning       # Warnings and above

# Time range filtering
journalctl --since "2024-01-01 00:00:00"
journalctl --since "1 hour ago"
journalctl --since today

# Combine filters
journalctl -u ssh.service --since "10 minutes ago" -p err

# Export to file for analysis
journalctl -u ssh.service > ssh_logs.txt
```

**Journal persistence check:**

```bash
# Verify journal storage location
ls -la /var/log/journal/

# Check journal size
journalctl --disk-usage

# View journal configuration
cat /etc/systemd/journald.conf
```

### Application Logs

Application-specific logs often contain exploitation artifacts:

**Web servers:**

```bash
# Apache
/var/log/apache2/access.log     # HTTP requests
/var/log/apache2/error.log      # Server errors
/var/log/apache2/other_vhosts_access.log

# Nginx  
/var/log/nginx/access.log
/var/log/nginx/error.log

# Quick analysis
tail -1000 /var/log/apache2/access.log | grep -E "\.php|\.jsp|\.asp"
```

**Databases:**

```bash
# MySQL/MariaDB
/var/log/mysql/error.log
/var/log/mysql/mysql.log
/var/log/mysql/slow-query.log

# PostgreSQL
/var/log/postgresql/postgresql-[version]-main.log

# Check for SQL injection attempts (basic)
grep -iE "union|select.*from|insert.*into" /var/log/mysql/mysql.log
```

**Mail servers:**

```bash
# Postfix/Sendmail
/var/log/mail.log
/var/log/mail.err
/var/log/mail.warn
```

**FTP:**

```bash
# vsftpd
/var/log/vsftpd.log

# ProFTPD
/var/log/proftpd/proftpd.log
```

### Application vs System Log Differentiation

**System logs characteristics:**

- Managed by syslog daemon or journald
- Standard facilities (auth, kern, daemon, user)
- Centralized location (`/var/log/`)
- Root or adm group ownership
- Follow syslog format conventions

**Application logs characteristics:**

- Application-specific format
- Often in application subdirectories (`/var/log/[app]/`)
- May use custom rotation mechanisms
- Application user ownership
- Format varies by software (Apache combined format, JSON, custom)

```bash
# Identify log type by format
head -5 /var/log/syslog         # Syslog format: timestamp hostname process[pid]: message
head -5 /var/log/apache2/access.log  # Apache combined format

# Find application-specific log directories
find /var/log -type d -maxdepth 1 | grep -v "^/var/log$"

# Identify active log writers
lsof +D /var/log | grep -v "DIR"
```

### CTF-Specific Log Priority

**High-value targets for CTF scenarios:**

1. `/var/log/auth.log` - privilege escalation, lateral movement
2. Web server access logs - injection payloads, enumeration
3. Application error logs - verbose errors exposing paths/configs
4. Command history (not traditional logs): `~/.bash_history`, `~/.zsh_history`
5. `/var/log/syslog` - service starts/stops, system events

**Critical but often overlooked:**

```bash
# Package manager logs (software changes)
/var/log/apt/history.log        # Debian/Ubuntu
/var/log/dpkg.log
/var/log/yum.log                # RHEL/CentOS

# User activity logs
/var/log/wtmp                   # Login records (binary)
/var/log/btmp                   # Failed logins (binary)
/var/log/lastlog                # Last login per user (binary)

# Parse binary logs
last -f /var/log/wtmp
lastb -f /var/log/btmp
lastlog
```

---

# Linux System Logs

## /var/log/syslog and /var/log/messages

### Overview

`/var/log/syslog` (Debian/Ubuntu-based) and `/var/log/messages` (RHEL/CentOS-based) serve as centralized system activity logs capturing daemon messages, system events, and general operational data. In CTF scenarios, these logs reveal service startups, network configuration changes, cron job executions, and system-level anomalies that may indicate exploitation attempts or misconfigurations.

### File Structure

Both files follow standard syslog format:

```
timestamp hostname process[PID]: message
```

Example:

```
Oct 28 14:23:45 ctf-box systemd[1]: Started Session 5 of user ctfplayer.
```

### Key Analysis Techniques

**Real-time Monitoring:**

```bash
tail -f /var/log/syslog
```

**Filtering by Time Range:**

```bash
grep "Oct 28 14:" /var/log/syslog
sed -n '/Oct 28 14:00/,/Oct 28 15:00/p' /var/log/syslog
```

**Service-Specific Extraction:**

```bash
grep "sshd" /var/log/syslog
grep -E "apache2|nginx|httpd" /var/log/syslog
```

**Pattern Detection for Exploitation Indicators:**

```bash
# Failed service starts (potential exploitation aftermath)
grep -i "failed" /var/log/syslog

# Privilege escalation artifacts
grep -E "sudo|su\[" /var/log/syslog

# Network service restarts (possible config manipulation)
grep -i "restart" /var/log/syslog | grep -E "network|ssh|http"
```

### CTF-Specific Analysis Patterns

**Identify Service Dependencies:**

```bash
# Services that started around a specific timestamp
awk '/Oct 28 14:2[0-9]/ && /Started|Stopped/' /var/log/syslog
```

**Detect Scheduled Task Activity:**

```bash
grep -i "cron" /var/log/syslog
grep "CRON" /var/log/syslog | awk '{print $6,$9}' | sort | uniq -c
```

**Extract Error Messages:**

```bash
grep -i "error\|fail\|critical" /var/log/syslog | less
```

**Correlation with System Boot:**

```bash
# Find boot sequence messages
grep "kernel:" /var/log/syslog | head -n 50

# Identify services started post-boot
awk '/systemd\[1\]: Started/ {print $0}' /var/log/syslog
```

### Advanced Filtering with awk

**Extract Specific Fields:**

```bash
# Show only timestamp, hostname, and message
awk '{print $1, $2, $3, $5, $6, $7}' /var/log/syslog

# Isolate messages from specific hour
awk '$3 ~ /^14:/' /var/log/syslog
```

**Process-Based Analysis:**

```bash
# Count messages per process
awk '{print $5}' /var/log/syslog | sort | uniq -c | sort -rn | head -20
```

### Integration with Other Tools

**Combine with journalctl (systemd systems):**

```bash
# Cross-reference syslog with journal
journalctl --since "14:00" --until "15:00" -u sshd.service

# Compare syslog entries with systemd journal
diff <(grep "sshd" /var/log/syslog) <(journalctl -u sshd -o short-precise --no-pager)
```

**Log Rotation Awareness:**

```bash
# Check rotated logs
zgrep "pattern" /var/log/syslog.*.gz

# Search across current and rotated logs
for log in /var/log/syslog*; do
    if [[ $log == *.gz ]]; then
        zgrep "searchterm" "$log"
    else
        grep "searchterm" "$log"
    fi
done
```

---

## /var/log/auth.log and /var/log/secure

### Overview

`/var/log/auth.log` (Debian/Ubuntu) and `/var/log/secure` (RHEL/CentOS) record authentication events, including SSH logins, sudo usage, user authentication attempts, and PAM (Pluggable Authentication Modules) activity. These are critical for identifying privilege escalation, brute-force attempts, and unauthorized access in CTF challenges.

### Authentication Event Categories

**SSH Authentication:**

```bash
# Successful SSH logins
grep "Accepted" /var/log/auth.log

# Failed SSH attempts
grep "Failed password" /var/log/auth.log

# SSH key authentication
grep "Accepted publickey" /var/log/auth.log
```

**Sudo Activity:**

```bash
# All sudo commands executed
grep "sudo:" /var/log/auth.log

# Specific user sudo history
grep "sudo:.*USER=root" /var/log/auth.log

# Failed sudo attempts
grep "sudo:.*incorrect password" /var/log/auth.log
```

**User Authentication (su, login, etc.):**

```bash
# Direct root login attempts
grep "su\[" /var/log/auth.log | grep "root"

# Session opened/closed
grep "session opened" /var/log/auth.log
```

### Brute-Force Detection

**Identify Multiple Failed Attempts:**

```bash
# Count failed password attempts by IP
grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn

# Extract usernames targeted in attacks
grep "Failed password" /var/log/auth.log | awk '{print $9}' | sort | uniq -c | sort -rn

# Timeline of failed attempts for specific user
grep "Failed password for ctfuser" /var/log/auth.log | awk '{print $1, $2, $3}'
```

**Successful Login After Multiple Failures:**

```bash
# Potential successful brute-force
IP="192.168.1.100"
grep "$IP" /var/log/auth.log | grep -E "Failed|Accepted"
```

### Privilege Escalation Detection

**Sudo Command Analysis:**

```bash
# Extract full command with user context
grep "COMMAND=" /var/log/auth.log | awk -F'COMMAND=' '{print $2}'

# Commands executed as root
grep "COMMAND=" /var/log/auth.log | grep "USER=root"

# Suspicious binary executions
grep "COMMAND=" /var/log/auth.log | grep -E "/tmp|/dev/shm|wget|curl|nc|bash -i"
```

**User Switching Activity:**

```bash
# su attempts with context
grep "su:" /var/log/auth.log | grep -v "session"

# Successful su to root
grep "su:.*session opened for user root" /var/log/auth.log
```

### SSH Key Forensics

**Extract Key Fingerprints:**

```bash
grep "Accepted publickey" /var/log/auth.log | awk '{print $9, $11}'

# Identify key-based logins by user
grep "Accepted publickey" /var/log/auth.log | awk '{print $1, $2, $3, $9}' | sort
```

**Detect Key Addition Events:**

```bash
# This requires correlation with syslog/messages
grep -E "authorized_keys|ssh-keygen" /var/log/syslog
```

### Session Tracking

**Map User Sessions:**

```bash
# Extract session IDs
grep "pam_unix.*session" /var/log/auth.log | awk '{print $3, $11, $13, $15}'

# Session duration analysis [Inference - requires manual calculation]
grep "session opened for user ctfuser" /var/log/auth.log
grep "session closed for user ctfuser" /var/log/auth.log
```

**TTY Analysis:**

```bash
# Identify physical console logins vs remote
grep "session opened" /var/log/auth.log | grep -E "tty[0-9]|pts"
```

### PAM Module Activity

**Authentication Module Failures:**

```bash
grep "pam_" /var/log/auth.log | grep -i "fail\|error\|denied"

# Specific PAM module analysis
grep "pam_unix" /var/log/auth.log
grep "pam_sss" /var/log/auth.log  # SSSD for LDAP/AD
```

### CTF-Specific Patterns

**Backdoor User Detection:**

```bash
# Recently created users (requires cross-referencing /etc/passwd)
grep "useradd\|adduser" /var/log/auth.log

# Users with UID 0 (root equivalent)
awk -F: '$3 == 0 {print $1}' /etc/passwd
```

**Credential Stuffing Indicators:**

```bash
# Multiple usernames from same IP
grep "Failed password" /var/log/auth.log | awk '{print $(NF-3), $9}' | sort | uniq
```

**Anomalous Authentication Times:**

```bash
# Logins during unusual hours (example: 2-5 AM)
grep "Accepted" /var/log/auth.log | awk '$3 ~ /^0[2-5]:/'
```

### Advanced Analysis with awk and sed

**Extract Failed Login Statistics:**

```bash
awk '/Failed password/ {users[$9]++} END {for (u in users) print users[u], u}' /var/log/auth.log | sort -rn
```

**Timeline Reconstruction:**

```bash
# Format: Time | Event | User | IP
grep -E "Accepted|Failed" /var/log/auth.log | awk '{print $1" "$2" "$3, $0}' | sort
```

---

## /var/log/kern.log

### Overview

`/var/log/kern.log` contains kernel-level messages including hardware events, driver loading/unloading, firewall (netfilter/iptables) logs, USB device activity, and kernel panics. In CTF contexts, this log reveals kernel exploits, rootkit loading, network filtering events, and hardware-based attacks.

### Kernel Message Categories

**Hardware Events:**

```bash
# USB device connections
grep -i "usb" /var/log/kern.log

# Disk events
grep -E "sd[a-z]|nvme" /var/log/kern.log

# Network interface changes
grep -E "eth[0-9]|wlan[0-9]|link" /var/log/kern.log
```

**Module Loading:**

```bash
# Loaded kernel modules
grep "module" /var/log/kern.log | grep -i "load"

# Specific module tracking
grep "module_name" /var/log/kern.log

# Module removal
grep "module" /var/log/kern.log | grep -i "unload\|remov"
```

### Firewall and Network Filtering

**iptables/netfilter Logs:**

```bash
# Blocked connections (requires logging rules configured)
grep "UFW BLOCK" /var/log/kern.log
grep "iptables:" /var/log/kern.log

# Extract blocked IPs
grep "UFW BLOCK" /var/log/kern.log | awk '{for(i=1;i<=NF;i++) if($i~/SRC=/) print $i}' | cut -d'=' -f2 | sort | uniq -c | sort -rn

# Blocked ports
grep "UFW BLOCK" /var/log/kern.log | awk '{for(i=1;i<=NF;i++) if($i~/DPT=/) print $i}' | cut -d'=' -f2 | sort | uniq -c | sort -rn
```

**Connection Tracking:**

```bash
# NAT/masquerading events
grep -i "nat\|masq" /var/log/kern.log

# Connection state messages
grep "conntrack" /var/log/kern.log
```

### Exploit Detection Indicators

**Segmentation Faults (Potential Exploits):**

```bash
# Crashed processes
grep "segfault" /var/log/kern.log

# Extract crashing binary and address
grep "segfault" /var/log/kern.log | awk '{print $NF}' | sort | uniq -c | sort -rn
```

**Out of Memory Conditions:**

```bash
# OOM killer activity
grep -i "out of memory" /var/log/kern.log
grep "oom-killer" /var/log/kern.log

# Processes killed by OOM
grep "Killed process" /var/log/kern.log
```

**Kernel Panic Analysis:**

```bash
# Panic messages
grep -i "panic\|oops" /var/log/kern.log

# Extract panic context [Inference - manual analysis needed]
sed -n '/panic/,+20p' /var/log/kern.log
```

### Rootkit Detection

**Suspicious Module Activity:**

```bash
# Modules loaded from unusual paths
grep "insmod\|modprobe" /var/log/kern.log | grep -v "/lib/modules"

# Hidden module detection (requires correlation with lsmod)
lsmod | awk '{print $1}' > /tmp/loaded_modules.txt
grep "module.*loaded" /var/log/kern.log | awk '{print $(NF-1)}' | sort | uniq > /tmp/kern_modules.txt
diff /tmp/loaded_modules.txt /tmp/kern_modules.txt
```

**Kernel Address Space Warnings:**

```bash
# KASLR/SMEP/SMAP violations
grep -E "KASLR|SMEP|SMAP" /var/log/kern.log
```

### USB Device Forensics

**Device Connection Timeline:**

```bash
# USB insertion events
grep "New USB device" /var/log/kern.log

# Extract device identifiers
grep "idVendor\|idProduct" /var/log/kern.log

# Mass storage device mounting
grep "USB Mass Storage" /var/log/kern.log
```

**HID Device Analysis:**

```bash
# Keyboard/mouse connections (potential USB Rubber Ducky)
grep "USB HID" /var/log/kern.log
grep -E "keyboard|mouse" /var/log/kern.log
```

### Network Interface Events

**Interface State Changes:**

```bash
# Link up/down events
grep "link" /var/log/kern.log | grep -E "up|down"

# Promiscuous mode (potential sniffing)
grep "promiscuous" /var/log/kern.log
```

**Driver Loading:**

```bash
# Network driver initialization
grep -E "e1000|rtl8139|ath9k" /var/log/kern.log
```

### Disk and Filesystem Events

**Mount/Unmount Operations:**

```bash
grep -E "mount|umount" /var/log/kern.log

# Filesystem errors
grep -i "ext4\|xfs\|btrfs" /var/log/kern.log | grep -i "error"
```

**SMART Errors:**

```bash
# Disk health warnings
grep -i "smart\|ata.*error" /var/log/kern.log
```

### Advanced Filtering Techniques

**Time-Correlated Event Extraction:**

```bash
# Events within 5 minutes of a specific timestamp
TIMESTAMP="Oct 28 14:30"
grep "$TIMESTAMP" /var/log/kern.log
awk -v start="14:25" -v end="14:35" '$3 >= start && $3 <= end' /var/log/kern.log
```

**Kernel Ring Buffer Cross-Reference:**

```bash
# Compare kern.log with current kernel messages
dmesg -T > /tmp/dmesg_current.txt
diff <(tail -100 /var/log/kern.log) /tmp/dmesg_current.txt
```

**Rate-Based Anomaly Detection:**

```bash
# Messages per minute (high rate = potential DoS/exploit)
awk '{print $1, $2, substr($3,1,5)}' /var/log/kern.log | uniq -c | sort -rn | head -20
```

### CTF Log Correlation Strategy

When analyzing these three log sources together:

```bash
# Cross-reference authentication with kernel events
AUTH_TIME=$(grep "Accepted.*sshd" /var/log/auth.log | tail -1 | awk '{print $1, $2, $3}')
grep "$AUTH_TIME" /var/log/kern.log

# Find system events during suspicious sudo commands
SUDO_TIME=$(grep "COMMAND=/suspicious/path" /var/log/auth.log | awk '{print $1, $2, $3}')
grep "$SUDO_TIME" /var/log/syslog
grep "$SUDO_TIME" /var/log/kern.log

# Timeline reconstruction across all logs
cat <(awk '{print $1, $2, $3, "AUTH:", $0}' /var/log/auth.log) \
    <(awk '{print $1, $2, $3, "SYSLOG:", $0}' /var/log/syslog) \
    <(awk '{print $1, $2, $3, "KERN:", $0}' /var/log/kern.log) | sort
```

**Important Note:** [Inference] Log correlation techniques assume synchronized system clocks. Clock skew may require adjustment. [Unverified] Advanced rootkits may manipulate log entries; always correlate with other forensic artifacts like filesystem timestamps and process memory.

---

## /var/log/dmesg

The kernel ring buffer log capturing hardware initialization, driver loading, and kernel-level events from boot and runtime.

### Direct File Access

```bash
# Read entire dmesg log
cat /var/log/dmesg

# View with pagination
less /var/log/dmesg

# Search for specific hardware
grep -i "usb" /var/log/dmesg
```

### Live Kernel Buffer Access

```bash
# Display current kernel ring buffer
dmesg

# Human-readable timestamps
dmesg -T

# Follow new kernel messages in real-time
dmesg -w

# Show only error and warning messages
dmesg -l err,warn

# Display with facility and level information
dmesg -x

# Clear the ring buffer (requires root)
dmesg -c
```

### CTF-Relevant Filtering

```bash
# Hardware detection (USB devices inserted)
dmesg | grep -i usb

# Network interface changes
dmesg | grep eth0

# Disk/storage events
dmesg | grep -i "sd[a-z]"

# Specific time range (last 100 lines)
dmesg | tail -100

# Parse for suspicious kernel module loading
dmesg | grep "module"
```

### Forensic Analysis Patterns

```bash
# Detect hardware keystroke loggers or USB devices
dmesg | grep -E "USB|HID|input"

# Identify storage device connections (potential data exfiltration)
dmesg -T | grep -E "sd[a-z]|Attached SCSI"

# Look for out-of-memory kills (compromise indicators)
dmesg | grep -i "killed process"

# Check for segmentation faults from exploits
dmesg | grep "segfault"
```

### Output Format Options

```bash
# JSON output (useful for scripting)
dmesg -J

# Raw binary format
dmesg --raw

# Specific facility (kern, user, mail, daemon, etc.)
dmesg -f daemon
```

**Note**: The ring buffer has limited size (typically 256KB-1MB). Old messages are overwritten. The `/var/log/dmesg` file captures boot-time buffer only and is not updated during runtime.

---

## /var/log/boot.log

System service startup log capturing init system messages, service failures, and boot sequence events.

### File Location Variations

```bash
# Standard Red Hat/CentOS/Fedora location
/var/log/boot.log

# Debian/Ubuntu often use
/var/log/boot

# Check which exists
ls -lh /var/log/boot*
```

### Basic Analysis

```bash
# View complete boot log
cat /var/log/boot.log

# Check most recent boot
less /var/log/boot.log

# Find failed services
grep -i "fail" /var/log/boot.log

# Search for specific service
grep "sshd" /var/log/boot.log
```

### Service Status Extraction

```bash
# Extract all OK/FAILED statuses
grep -E "\[.*OK.*\]|\[.*FAILED.*\]" /var/log/boot.log

# List only failed services
grep "FAILED" /var/log/boot.log | awk '{print $NF}'

# Count failures
grep -c "FAILED" /var/log/boot.log
```

### Multi-Boot Analysis

```bash
# View previous boot logs (if logrotate enabled)
cat /var/log/boot.log.1
zcat /var/log/boot.log.2.gz

# Compare current vs previous boot
diff /var/log/boot.log /var/log/boot.log.1
```

### CTF Compromise Indicators

```bash
# Check for suspicious service failures
grep -i -E "fail|error|denied" /var/log/boot.log

# Identify unexpected service starts
grep -i "start" /var/log/boot.log

# Look for persistence mechanisms at boot
grep -E "rc\.local|init\.d" /var/log/boot.log
```

**Note**: Not all distributions populate boot.log extensively. Systemd-based systems primarily use journalctl for boot logging.

---

## systemd journal (journalctl)

The systemd journal provides centralized logging for all system services, kernel messages, and user sessions with structured, indexed binary logs.

### Basic journalctl Commands

```bash
# View all logs (paginated)
journalctl

# Show most recent entries
journalctl -n 50

# Follow live log stream
journalctl -f

# Reverse order (newest first)
journalctl -r

# Show from current boot only
journalctl -b

# Show from previous boot
journalctl -b -1
```

### Time-Based Filtering

```bash
# Since specific timestamp
journalctl --since "2025-10-28 14:30:00"

# Last hour
journalctl --since "1 hour ago"

# Specific time range
journalctl --since "2025-10-28 00:00:00" --until "2025-10-28 23:59:59"

# Yesterday's logs
journalctl --since yesterday --until today

# Last 30 minutes
journalctl --since "30 min ago"
```

### Unit/Service Filtering

```bash
# Logs for specific service
journalctl -u sshd

# Multiple services
journalctl -u sshd -u apache2

# Kernel messages only
journalctl -k

# Follow specific service
journalctl -u nginx -f

# Show service status with last log entries
journalctl -u sshd -n 20 --no-pager
```

### Priority Level Filtering

```bash
# Show only errors and above
journalctl -p err

# Warning level and above
journalctl -p warning

# Critical messages
journalctl -p crit

# Priority levels: emerg(0), alert(1), crit(2), err(3), warning(4), notice(5), info(6), debug(7)
journalctl -p 3
```

### Output Format Options

```bash
# JSON output
journalctl -o json

# JSON-pretty (readable)
journalctl -o json-pretty

# Short format (traditional syslog)
journalctl -o short

# Verbose (all fields)
journalctl -o verbose

# Export binary format
journalctl -o export

# Cat (no metadata)
journalctl -o cat
```

### User and Process Filtering

```bash
# Logs from specific user
journalctl _UID=1000

# Logs from specific process
journalctl _PID=1234

# Logs from executable path
journalctl /usr/bin/sshd

# Combine filters
journalctl _UID=1000 _COMM=bash
```

### Disk Usage and Maintenance

```bash
# Show journal disk usage
journalctl --disk-usage

# Verify journal file integrity
journalctl --verify

# Rotate journal files
journalctl --rotate

# Vacuum by size
journalctl --vacuum-size=500M

# Vacuum by time
journalctl --vacuum-time=7d

# Remove old archived journals
journalctl --vacuum-files=5
```

### Boot Analysis

```bash
# List all boots
journalctl --list-boots

# View specific boot by number
journalctl -b 0     # current
journalctl -b -1    # previous
journalctl -b -2    # two boots ago

# Boot with time range
journalctl -b --since "10 min ago"
```

### Advanced Filtering

```bash
# Grep with context
journalctl -u sshd | grep "Failed password"

# Field-based filtering
journalctl _SYSTEMD_UNIT=sshd.service _PID=1234

# Combine multiple criteria
journalctl -u sshd -p err --since today

# Case-insensitive grep
journalctl -u apache2 | grep -i error

# Show only entries with specific field
journalctl -o verbose | grep "FIELD_NAME="
```

### CTF Exploitation Scenarios

```bash
# Detect SSH brute force attempts
journalctl -u sshd | grep "Failed password"

# Identify privilege escalation
journalctl | grep -i "sudo\|su:"

# Find authentication failures
journalctl _COMM=su | grep "FAILED"

# Detect service crashes (potential exploits)
journalctl -p err | grep -E "segfault|core dump"

# Track user session activity
journalctl _SYSTEMD_UNIT=systemd-logind.service

# Find UID 0 (root) activity
journalctl _UID=0 --since today

# Identify network service authentication
journalctl -u ssh* -u ftp* -u telnet* | grep -i "auth"

# Detect suspicious systemd unit creation
journalctl | grep -E "Started.*\.service" --since "1 hour ago"
```

### Persistent Journal Configuration

```bash
# Location of journal files
ls -lh /var/log/journal/
ls -lh /run/log/journal/  # volatile

# Enable persistent storage
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
sudo systemctl restart systemd-journald

# Configure retention in /etc/systemd/journald.conf
# SystemMaxUse=500M
# MaxRetentionSec=7day
```

### Export and Backup

```bash
# Export to file
journalctl > journal_dump.txt

# Export specific timeframe
journalctl --since "2025-10-28" --until "2025-10-29" > oct28_logs.txt

# Binary export
journalctl -o export > journal.export

# Compressed backup
journalctl | gzip > journal_backup.gz
```

### Real-Time Monitoring Patterns

```bash
# Monitor authentication attempts
journalctl -f | grep -E "sshd|login|su|sudo"

# Watch for errors across all services
journalctl -f -p err

# Track specific user activity
journalctl -f _UID=1000

# Monitor kernel messages
journalctl -f -k

# Multiple services with color
journalctl -f -u sshd -u apache2 --output=short-precise
```

### Journal Field Reference

Common fields for filtering:

- `_PID`: Process ID
- `_UID`: User ID
- `_GID`: Group ID
- `_COMM`: Command name
- `_EXE`: Executable path
- `_SYSTEMD_UNIT`: Systemd unit name
- `_HOSTNAME`: Hostname
- `_TRANSPORT`: Log transport mechanism
- `MESSAGE`: Log message content
- `PRIORITY`: Syslog priority level

---

## Key Differences Between Log Sources

|Feature|dmesg|boot.log|journalctl|
|---|---|---|---|
|**Scope**|Kernel only|Init/boot services|All system logs|
|**Persistence**|Ring buffer (volatile)|File-based|Binary journal|
|**Boot Coverage**|Hardware/kernel init|Service startup|Complete boot process|
|**Runtime Updates**|Yes (live kernel)|No (boot only)|Yes (continuous)|
|**Structured Data**|No|No|Yes (indexed fields)|
|**Timestamp Accuracy**|Relative/absolute|Service-dependent|Microsecond precision|

**Related Topics**: Application-specific logs (/var/log/apache2, /var/log/nginx), authentication logs (/var/log/auth.log, /var/log/secure), syslog configuration (/etc/rsyslog.conf), log rotation (logrotate), centralized logging (syslog-ng, rsyslog forwarding)

---

# Authentication & Access Logs

Authentication and access logs represent the first line of defense in identifying unauthorized access attempts, privilege escalation, and lateral movement in compromised systems. In CTF environments, these logs frequently contain critical evidence of attack paths, credential usage patterns, and backdoor establishment.

## SSH Login Logs

SSH authentication events are recorded across multiple log files depending on your Linux distribution. On Debian-based systems (including Kali), the primary location is `/var/log/auth.log`, while Red Hat-based systems use `/var/log/secure`.

### Primary Log Locations

```bash
# Debian/Ubuntu/Kali
tail -f /var/log/auth.log

# RHEL/CentOS/Fedora
tail -f /var/log/secure

# Generic systemd approach (works across distributions)
journalctl -u ssh -f
journalctl -u sshd -f
```

### Identifying Successful SSH Logins

```bash
# View all successful SSH logins
grep "Accepted" /var/log/auth.log

# Successful password authentications
grep "Accepted password" /var/log/auth.log

# Successful public key authentications
grep "Accepted publickey" /var/log/auth.log

# Extract successful logins with timestamp, user, and source IP
grep "Accepted" /var/log/auth.log | awk '{print $1, $2, $3, $9, $11}'

# Successful logins from specific IP
grep "Accepted" /var/log/auth.log | grep "192.168.1.100"
```

### SSH Session Tracking

```bash
# Find session opened events (indicates shell access granted)
grep "session opened" /var/log/auth.log

# Find session closed events (logout tracking)
grep "session closed" /var/log/auth.log

# Match sessions to specific users
grep "session opened for user" /var/log/auth.log | grep "username"

# Calculate session duration (requires correlation)
grep -E "(session opened|session closed)" /var/log/auth.log | grep "username"
```

### SSH Connection Analysis

```bash
# View all SSH connection attempts
grep "sshd" /var/log/auth.log

# Identify disconnection reasons
grep "Disconnected" /var/log/auth.log

# Find port scanning activity (rapid connection attempts)
grep "Did not receive identification string" /var/log/auth.log

# Identify key exchange and protocol issues
grep "Unable to negotiate" /var/log/auth.log
```

### Advanced SSH Log Parsing

```bash
# Extract unique source IPs that successfully authenticated
grep "Accepted" /var/log/auth.log | awk '{print $11}' | sort -u

# Count successful logins per user
grep "Accepted" /var/log/auth.log | awk '{print $9}' | sort | uniq -c | sort -rn

# Timeline of SSH activity for forensic analysis
grep "sshd" /var/log/auth.log | awk '{print $1, $2, $3}' | uniq -c

# Find authentication method changes (potential attacker adaptation)
grep "Accepted" /var/log/auth.log | awk '{print $1, $2, $6, $9}' | sort
```

## Failed Authentication Attempts

Failed authentication attempts indicate brute-force attacks, credential stuffing, misconfigured services, or reconnaissance activity. High volumes of failures from single sources suggest automated attacks.

### Basic Failed Authentication Queries

```bash
# All failed password attempts
grep "Failed password" /var/log/auth.log

# Failed attempts with usernames and source IPs
grep "Failed password" /var/log/auth.log | awk '{print $1, $2, $9, $11}'

# Count failures per source IP
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn

# Failed attempts for specific user (identify targeted accounts)
grep "Failed password for" /var/log/auth.log | grep "root"
```

### Invalid User Detection

```bash
# Attempts with non-existent usernames (reconnaissance)
grep "Invalid user" /var/log/auth.log

# Extract invalid usernames being tested
grep "Invalid user" /var/log/auth.log | awk '{print $8}' | sort | uniq -c | sort -rn

# Correlate invalid users with source IPs
grep "Invalid user" /var/log/auth.log | awk '{print $8, $10}' | sort
```

### Public Key Authentication Failures

```bash
# Failed public key authentications
grep "Failed publickey" /var/log/auth.log

# Identify users attempting key-based auth without valid keys
grep "Connection closed by authenticating user" /var/log/auth.log
```

### Brute Force Detection Patterns

```bash
# Rapid authentication attempts (potential brute force)
grep "Failed password" /var/log/auth.log | awk '{print $1, $2, $11}' | uniq -c | awk '$1 > 5'

# Multiple failures followed by success (compromised credential indicator)
grep "Failed password\|Accepted password" /var/log/auth.log | grep "192.168.1.50"

# Break-in attempts (system-flagged potential compromises)
grep "POSSIBLE BREAK-IN ATTEMPT" /var/log/auth.log
```

### Authentication Failure Analysis Tools

```bash
# Using fail2ban logs to identify banned IPs
cat /var/log/fail2ban.log | grep "Ban"

# Check fail2ban status for SSH jail
fail2ban-client status sshd

# Parse auth.log with custom threshold
awk '/Failed password/ {print $11}' /var/log/auth.log | sort | uniq -c | awk '$1 > 10 {print $2, $1}'
```

## sudo Command Logs

The `sudo` logging mechanism tracks privilege escalation attempts and successful elevated command execution. This is critical for identifying unauthorized privilege escalation, insider threats, and post-exploitation activity.

### Basic sudo Log Analysis

```bash
# All sudo commands executed
grep "sudo" /var/log/auth.log

# Successful sudo commands with full context
grep "COMMAND=" /var/log/auth.log

# Extract user, command, and timestamp
grep "COMMAND=" /var/log/auth.log | awk '{print $1, $2, $3, $6, $15}'

# sudo commands by specific user
grep "COMMAND=" /var/log/auth.log | grep "USER=username"
```

### Failed sudo Attempts

```bash
# Authentication failures during sudo usage
grep "sudo.*authentication failure" /var/log/auth.log

# Incorrect password attempts
grep "sudo.*pam_unix.*authentication failure" /var/log/auth.log

# Users attempting unauthorized sudo access
grep "NOT in sudoers" /var/log/auth.log

# Extract users violating sudo policy
grep "NOT in sudoers" /var/log/auth.log | awk '{print $6}' | sort | uniq
```

### Privilege Escalation Indicators

```bash
# sudo to root shell (high-risk activity)
grep "COMMAND=/bin/bash\|COMMAND=/bin/sh" /var/log/auth.log

# Password changes via sudo
grep "COMMAND=/usr/bin/passwd" /var/log/auth.log

# User additions (potential backdoor creation)
grep "COMMAND=/usr/sbin/useradd\|COMMAND=/usr/sbin/adduser" /var/log/auth.log

# Sudoers file modifications
grep "COMMAND=.*visudo\|COMMAND=.*sudoers" /var/log/auth.log
```

### Detailed sudo Command Extraction

```bash
# Full command line arguments
grep "COMMAND=" /var/log/auth.log | sed 's/.*COMMAND=/COMMAND=/'

# Commands executed as specific target users
grep "sudo.*USER=root" /var/log/auth.log

# Track sudo session activity
grep "sudo.*session opened\|session closed" /var/log/auth.log

# Identify TTY used for sudo (terminal tracking)
grep "COMMAND=" /var/log/auth.log | grep -oP "TTY=[^ ]+" | sort | uniq -c
```

### Advanced sudo Analysis

```bash
# Correlate sudo failures with successes (learning attempts)
grep "username" /var/log/auth.log | grep -E "(sudo.*authentication failure|COMMAND=)"

# Unusual sudo command patterns
grep "COMMAND=" /var/log/auth.log | awk -F'COMMAND=' '{print $2}' | sort | uniq -c | sort -rn

# Nighttime sudo activity (potential malicious timing)
grep "COMMAND=" /var/log/auth.log | awk '$2 ~ /^(0[0-5]|2[0-3]):/'

# sudo without password (NOPASSWD configured - security concern)
grep "sudo.*NO_PASSWD" /var/log/auth.log
```

## PAM (Pluggable Authentication Modules) Logs

PAM provides the underlying authentication framework for Linux systems. PAM logs capture authentication decisions, module execution, and security policy enforcement across all authentication mechanisms.

### PAM Authentication Events

```bash
# All PAM authentication attempts
grep "pam_unix" /var/log/auth.log

# PAM session management events
grep "pam_unix(.*:session)" /var/log/auth.log

# PAM authentication module decisions
grep "pam_unix(.*:auth)" /var/log/auth.log

# Account validation events
grep "pam_unix(.*:account)" /var/log/auth.log
```

### Service-Specific PAM Analysis

```bash
# SSH PAM authentication
grep "pam_unix(sshd:auth)" /var/log/auth.log

# Login service PAM events
grep "pam_unix(login:auth)" /var/log/auth.log

# sudo PAM authentication
grep "pam_unix(sudo:auth)" /var/log/auth.log

# CRON job PAM sessions
grep "pam_unix(cron:session)" /var/log/auth.log
```

### PAM Authentication Failures

```bash
# All authentication failures through PAM
grep "pam_unix.*authentication failure" /var/log/auth.log

# Extract failed authentication details (user, service, source)
grep "pam_unix.*authentication failure" /var/log/auth.log | grep -oP "(logname=[^ ]+|uid=[^ ]+|ruser=[^ ]+|rhost=[^ ]+)"

# Account locked/expired through PAM
grep "pam_unix.*account.*expired" /var/log/auth.log

# Access denied by PAM policy
grep "pam_access.*denied" /var/log/auth.log
```

### PAM Security Module Analysis

```bash
# pam_tally2 lockouts (deprecated but still present in some systems)
grep "pam_tally2" /var/log/auth.log

# pam_faillock events (modern account lockout mechanism)
grep "pam_faillock" /var/log/auth.log

# Check faillock status for specific user
faillock --user username

# pam_limits violations (resource limit enforcement)
grep "pam_limits" /var/log/auth.log

# pam_deny explicit rejections
grep "pam_deny" /var/log/auth.log
```

### PAM Session Tracking

```bash
# Session opened events (user login established)
grep "pam_unix.*session opened" /var/log/auth.log

# Session closed events (user logout)
grep "pam_unix.*session closed" /var/log/auth.log

# Correlate sessions by UID
grep "pam_unix.*session" /var/log/auth.log | grep "uid=1000"

# Non-standard session creations (potential security issue)
grep "pam_systemd.*session" /var/log/auth.log
```

### Advanced PAM Forensics

```bash
# Multiple PAM module failures (authentication stack issues)
grep "pam_" /var/log/auth.log | grep -v "pam_unix" | grep "failure\|error\|denied"

# PAM module execution order analysis
grep "pam_" /var/log/auth.log | awk '{print $6}' | sort | uniq -c

# Identify custom PAM configurations in use
grep "pam_exec\|pam_script" /var/log/auth.log

# SELinux PAM denials
grep "pam_selinux" /var/log/auth.log | grep "denied"
```

### Cross-Log PAM Correlation

```bash
# Correlate PAM failures across auth.log and syslog
grep "pam_unix.*authentication failure" /var/log/auth.log /var/log/syslog

# Systemd journal PAM entries
journalctl -t sudo -t sshd | grep "pam_"

# PAM configuration validation
grep "pam_" /var/log/auth.log | grep -i "error\|unknown"
```

### Practical CTF Authentication Log Scenarios

```bash
# Scenario 1: Find compromised account
# Look for: Multiple failures followed by success
grep "Failed password\|Accepted password" /var/log/auth.log | grep "username" | tail -20

# Scenario 2: Identify brute force source
# Extract top attacking IPs
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | head -10

# Scenario 3: Track privilege escalation timeline
# Correlate sudo commands with authentication events
grep -E "(Accepted|COMMAND=)" /var/log/auth.log | grep "username"

# Scenario 4: Detect backdoor user creation
grep -E "(useradd|adduser|COMMAND=.*user)" /var/log/auth.log

# Scenario 5: Find suspicious administrative activity
grep "COMMAND=" /var/log/auth.log | grep -E "(visudo|sudoers|shadow|passwd)"
```

### Log Rotation Considerations

```bash
# Check rotated logs (may contain historical evidence)
zgrep "Failed password" /var/log/auth.log.*.gz

# Search across all rotations
for file in /var/log/auth.log*; do 
    echo "=== $file ===" 
    zgrep -h "Accepted password" "$file" 2>/dev/null || grep -h "Accepted password" "$file" 2>/dev/null
done

# Verify log rotation configuration
cat /etc/logrotate.d/rsyslog
```

**Important Related Topics**: To develop comprehensive log analysis skills for CTF scenarios, you should also study: **Application & Service Logs** (covering web server, database, and custom service logging), **System Event Logs** (kernel messages, boot sequences, hardware events), and **Network Activity Logs** (firewall rules, connection tracking, DNS queries). These complement authentication analysis by providing context around service exploitation and lateral movement.

---

## wtmp, utmp, btmp Analysis

### Overview

These three binary log files form the core authentication tracking system on Linux:

- **wtmp** (`/var/log/wtmp`): Historical record of all login/logout events, system boots/shutdowns
- **utmp** (`/var/run/utmp`): Current login sessions (who is logged in right now)
- **btmp** (`/var/log/btmp`): Failed login attempts

All three use the same binary structure (utmp format) but serve different purposes. They are NOT plaintext and require specific tools for analysis.

### wtmp Analysis

**Primary Tool: last**

```bash
# Basic wtmp reading - shows all login sessions
last

# Show last N entries
last -n 20

# Show logins for specific user
last username

# Show system reboot history
last reboot

# Show system shutdown events
last -x shutdown

# Full timestamps (no truncation)
last -F

# Show login source IP/hostname
last -a

# Read from specific wtmp file (useful for analyzing old/rotated logs)
last -f /var/log/wtmp.1

# Filter by time range
last -s 2024-10-01 -t 2024-10-28

# Show logins from specific terminal/TTY
last tty1
```

**Alternative Tool: utmpdump**

```bash
# Dump wtmp to human-readable format
utmpdump /var/log/wtmp

# Convert to text for grep/awk processing
utmpdump /var/log/wtmp | grep "username"

# Restore from text dump (rarely needed)
utmpdump -r < wtmp.txt > /var/log/wtmp
```

**Manual Parsing with Python:**

```bash
python3 << 'EOF'
import struct
import time

# utmp structure format varies by architecture
# Standard x86_64 format
UTMP_SIZE = 384

with open('/var/log/wtmp', 'rb') as f:
    while True:
        data = f.read(UTMP_SIZE)
        if not data or len(data) < UTMP_SIZE:
            break
        
        # Basic parsing (simplified - real structure is complex)
        ut_type = struct.unpack('h', data[0:2])[0]
        ut_user = data[4:36].split(b'\x00')[0].decode('utf-8', errors='ignore')
        ut_line = data[36:68].split(b'\x00')[0].decode('utf-8', errors='ignore')
        ut_time = struct.unpack('i', data[68:72])[0]
        
        if ut_type in [6, 7, 8]:  # USER_PROCESS, DEAD_PROCESS, BOOT_TIME
            print(f"{time.ctime(ut_time)} | {ut_user:12} | {ut_line}")
EOF
```

**Key wtmp Record Types:**

- Type 0: EMPTY (unused entry)
- Type 1: RUN_LVL (system runlevel change)
- Type 2: BOOT_TIME (system boot)
- Type 5: INIT_PROCESS (getty processes)
- Type 6: LOGIN_PROCESS (login prompt)
- Type 7: USER_PROCESS (actual user login)
- Type 8: DEAD_PROCESS (logout/session end)

### utmp Analysis

**Primary Tool: who/w**

```bash
# Show currently logged in users
who

# Detailed information with idle time
w

# Show all information
who -a

# Show boot time
who -b

# Show current runlevel
who -r

# Show login processes
who -l

# Machine-readable output
who -H

# Using utmpdump for current sessions
utmpdump /var/run/utmp
```

**Location:** `/var/run/utmp` (tmpfs, lost on reboot)

**CTF Context:** Useful for detecting concurrent attacker sessions or identifying persistence mechanisms that maintain login sessions.

### btmp Analysis

**Primary Tool: lastb**

```bash
# Show all failed login attempts (requires root)
sudo lastb

# Last N failed attempts
sudo lastb -n 50

# Failed attempts for specific user
sudo lastb username

# Full timestamps
sudo lastb -F

# Show source IPs
sudo lastb -a

# Analyze old btmp files
sudo lastb -f /var/log/btmp.1

# Count failed attempts per user
sudo lastb | awk '{print $1}' | sort | uniq -c | sort -nr

# Identify brute force attempts (many failures from same IP)
sudo lastb | awk '{print $NF}' | sort | uniq -c | sort -nr
```

**Location:** `/var/log/btmp` (requires root access)

**Brute Force Detection Pattern:**

```bash
#!/bin/bash
# Detect potential SSH brute force attacks

echo "Top 10 IPs with failed login attempts:"
sudo lastb | awk '{print $NF}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort | uniq -c | sort -nr | head -10

echo -e "\nTop targeted usernames:"
sudo lastb | awk '{print $1}' | sort | uniq -c | sort -nr | head -10

echo -e "\nFailed attempts timeline (last 24h):"
sudo lastb -F | grep "$(date +%Y)" | head -20
```

### Log Rotation Handling

```bash
# Check for rotated logs
ls -lh /var/log/wtmp* /var/log/btmp*

# Analyze across rotations
for log in /var/log/wtmp*; do
    echo "=== $log ==="
    last -f "$log" | head -10
done

# Combine multiple btmp files for brute force analysis
sudo cat /var/log/btmp* | sudo lastb -f /dev/stdin
```

## lastlog Examination

### Overview

**lastlog** tracks the last login time for EVERY user account on the system, including service accounts. Unlike wtmp/utmp, this is a sparse file indexed by UID.

**Location:** `/var/log/lastlog`

### Basic Analysis

```bash
# Show last login for all users
lastlog

# Specific user
lastlog -u username

# By UID
lastlog -u 1000

# Users who never logged in
lastlog | grep "Never"

# Recent logins (within 7 days)
lastlog -t 7

# Format with full timestamps
lastlog -C

# Limit to specific UID range
lastlog -u 1000-2000
```

### Forensic Applications

**Identify Compromised Service Accounts:**

```bash
# Service accounts (UID < 1000) that have recent logins
lastlog -u 0-999 | grep -v "Never" | grep -v "Username"
```

**[Inference]** If service accounts show recent login activity, this may indicate:

- Privilege escalation exploitation
- Direct credential compromise
- Lateral movement using service credentials

**Detect Dormant Account Usage:**

```bash
# Find accounts that never logged in but exist
awk -F: '{print $1}' /etc/passwd | while read user; do
    lastlog -u "$user" 2>/dev/null | grep -q "Never" && echo "$user: Never logged in"
done
```

### lastlog File Structure

The lastlog file is a **sparse file** where each record is 292 bytes, indexed by UID:

```bash
# Check file size (appears large but is sparse)
ls -lh /var/log/lastlog
du -h /var/log/lastlog  # Shows actual disk usage

# Manual parsing (rarely needed)
python3 << 'EOF'
import struct
import pwd

LASTLOG_SIZE = 292

with open('/var/log/lastlog', 'rb') as f:
    for uid in range(0, 2000):
        f.seek(uid * LASTLOG_SIZE)
        data = f.read(LASTLOG_SIZE)
        
        if len(data) < LASTLOG_SIZE:
            break
            
        ll_time = struct.unpack('i', data[0:4])[0]
        ll_line = data[4:36].split(b'\x00')[0].decode('utf-8', errors='ignore')
        ll_host = data[36:292].split(b'\x00')[0].decode('utf-8', errors='ignore')
        
        if ll_time > 0:
            try:
                username = pwd.getpwuid(uid).pw_name
                import time
                print(f"UID {uid} ({username}): {time.ctime(ll_time)} from {ll_host} on {ll_line}")
            except KeyError:
                pass
EOF
```

## Login Session Tracking

### Active Session Monitoring

**Real-time Tracking:**

```bash
# Current sessions with details
w

# More detailed user information
who -a -H

# Process-level session tracking
ps aux | grep -E "(sshd|login|bash|su)"

# TTY ownership (who owns which terminal)
ls -l /dev/pts/*

# Active SSH sessions specifically
ss -tnp | grep :22 | grep ESTAB

# Show user's processes and terminals
ps -ef --forest | grep -A 5 "sshd:"
```

**Session Relationship Tracking:**

```bash
# Parent-child process relationships for login sessions
pstree -p -u -a

# Find session leader processes
ps -eo pid,ppid,sess,cmd | grep -E "(bash|ssh|login)"

# Identify tmux/screen sessions
ps aux | grep -E "(tmux|screen)"
tmux ls 2>/dev/null
screen -ls 2>/dev/null
```

### Historical Session Analysis

**Session Duration Calculation:**

```bash
# Calculate average session duration for user
last username | awk '/^username/ {
    if ($NF ~ /[0-9]/) {
        # Extract duration (assumes format like (00:05))
        match($0, /\(([0-9:]+)\)/, dur);
        print dur[1];
    }
}'

# Sessions longer than expected (potential persistence)
last | grep -E '\([0-9]{2}:[0-9]{2}\)' | grep -v "(00:"
```

**Timeline Reconstruction:**

```bash
# Build complete authentication timeline
{
    echo "=== Successful Logins ==="
    last -F | head -50
    
    echo -e "\n=== Failed Attempts ==="
    sudo lastb -F | head -20
    
    echo -e "\n=== Last Login Per User ==="
    lastlog -C
} | tee auth_timeline.txt
```

### Detecting Anomalous Sessions

**Identify Suspicious Patterns:**

```bash
#!/bin/bash
# Session anomaly detection script

echo "=== Checking for Unusual Login Times ==="
# Logins during off-hours (example: 2 AM - 6 AM)
last -F | awk '{print $0}' | grep -E '0[2-6]:[0-9]{2}:[0-9]{2}'

echo -e "\n=== Multiple Concurrent Sessions (Same User) ==="
last | head -50 | awk '{print $1}' | sort | uniq -c | sort -nr | head

echo -e "\n=== Logins from Unusual IPs ==="
# Shows all unique source IPs
last -a | awk '{print $NF}' | grep -E '^[0-9]+\.' | sort -u

echo -e "\n=== Sessions Without Logout ==="
# Still logged in sessions might be suspicious
last | grep "still logged in"

echo -e "\n=== Root SSH Logins (if disabled by policy) ==="
last root | grep -v "reboot"

echo -e "\n=== Service Account Interactive Logins ==="
for user in www-data mysql postgres nginx; do
    if last "$user" 2>/dev/null | grep -q "$user"; then
        echo "WARNING: $user has login history!"
    fi
done
```

### Session Correlation with Other Logs

**Combine with System Logs:**

```bash
# Match auth events with system logs by timestamp
# Extract timestamp from last output and query journalctl

last -F | head -20 | while read line; do
    timestamp=$(echo "$line" | awk '{print $4, $5, $6, $7}')
    user=$(echo "$line" | awk '{print $1}')
    
    echo "=== Events for $user at $timestamp ==="
    journalctl --since "$timestamp" --until "1 hour" | grep -E "(ssh|login|session|$user)" | head -5
done
```

### Log Tampering Detection

**[Inference]** Attackers may attempt to clear authentication logs. Detection methods:

```bash
# Check for gaps in wtmp timeline
last | awk '{print $5, $6, $7}' | uniq -c

# Verify log file integrity
stat /var/log/wtmp /var/log/btmp /var/log/lastlog

# Check for immutable flags (protection against deletion)
lsattr /var/log/wtmp /var/log/btmp /var/log/lastlog

# Compare actual login activity with log entries
# If users report being logged in but no wtmp record exists, logs may be tampered
```

**Log Backup Strategy (CTF Defense):**

```bash
# Copy logs to secure location immediately
mkdir -p /root/log_backups
cp -p /var/log/wtmp /var/log/btmp /var/log/lastlog /root/log_backups/

# Create hash for integrity verification
md5sum /var/log/wtmp /var/log/btmp > /root/log_hashes.txt
```

### Tool Integration

**Using aureport (from auditd):**

```bash
# If auditd is enabled, provides detailed authentication reports
aureport --auth
aureport --login
aureport -l --summary
aureport -u --summary  # User activity summary
```

**Using journalctl for Session Tracking:**

```bash
# SSH authentication events
journalctl -u ssh.service | grep -E "(Accepted|Failed)"

# PAM authentication events
journalctl -t sshd | grep pam

# User session events
journalctl _UID=1000  # Track specific user by UID
```

## Critical CTF Considerations

1. **Temporal Analysis**: Cross-reference authentication timestamps with command history (`~/.bash_history`), file modifications, and network connections
2. **Privilege Escalation Tracking**: Look for transitions from regular user to root in session logs
3. **Persistence Detection**: Check for sessions that remain active across system reboots (may indicate backdoors)
4. **Lateral Movement**: Correlate logins from internal IPs after initial compromise
5. **Log Clearing**: Empty or suspiciously recent wtmp/btmp files indicate anti-forensics

**Essential commands for quick triage:**

```bash
last -10                    # Last 10 login sessions
sudo lastb -10              # Last 10 failed attempts
lastlog | grep -v Never     # All accounts that logged in
who -a                      # Current session details
w                           # Active users with commands
```

---

# Web Server Logs

## Apache access.log Format

Apache access logs record every HTTP request made to the server. The default format is the **Common Log Format (CLF)**, though many systems use the **Combined Log Format**.

### Common Log Format (CLF) Structure

```
127.0.0.1 - frank [10/Oct/2025:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
```

**Field breakdown:**

- `127.0.0.1` - Client IP address
- `-` - RFC 1413 identity (usually unused, shown as `-`)
- `frank` - HTTP authenticated username (or `-` if none)
- `[10/Oct/2025:13:55:36 -0700]` - Timestamp with timezone
- `"GET /apache_pb.gif HTTP/1.0"` - Request line (method, URI, protocol)
- `200` - HTTP status code
- `2326` - Response size in bytes (or `-` if none)

### Location and Configuration

**Default log locations:**

```bash
# Debian/Ubuntu
/var/log/apache2/access.log
/var/log/apache2/other_vhosts_access.log

# RHEL/CentOS/Fedora
/var/log/httpd/access_log
```

**Configuration directive:**

```apache
CustomLog /var/log/apache2/access.log common
```

### CTF Analysis Commands

**Basic log inspection:**

```bash
# View last 50 entries
tail -n 50 /var/log/apache2/access.log

# Follow log in real-time
tail -f /var/log/apache2/access.log

# Search for specific IP
grep "192.168.1.100" /var/log/apache2/access.log

# Count requests per IP
awk '{print $1}' /var/log/apache2/access.log | sort | uniq -c | sort -rn

# Extract all requested URIs
awk '{print $7}' /var/log/apache2/access.log | sort | uniq -c | sort -rn
```

**Detecting suspicious activity:**

```bash
# Find failed requests (4xx/5xx status codes)
awk '$9 ~ /^[45]/ {print}' /var/log/apache2/access.log

# Identify potential SQL injection attempts
grep -E "(union|select|insert|update|delete|drop|--)" /var/log/apache2/access.log -i

# Detect directory traversal attempts
grep -E "\.\.|%2e%2e|%252e" /var/log/apache2/access.log -i

# Find POST requests (potential data exfiltration/uploads)
grep "\"POST" /var/log/apache2/access.log

# Identify user-agent anomalies
awk -F'"' '{print $6}' /var/log/apache2/access.log | sort | uniq -c | sort -rn
```

**Time-based analysis:**

```bash
# Extract requests within specific timeframe
awk -F'[' '{print $2}' /var/log/apache2/access.log | grep "10/Oct/2025:13"

# Count requests per hour
awk -F'[: []' '{print $2":"$3}' /var/log/apache2/access.log | sort | uniq -c

# Find requests outside business hours
awk -F'[: []' '$3 ~ /^(0[0-6]|2[0-3])$/ {print}' /var/log/apache2/access.log
```

## Apache error.log Analysis

Error logs capture diagnostic information, including server errors, client errors, and security-related events.

### Error Log Format

```
[Fri Oct 10 13:55:36.123456 2025] [core:error] [pid 35708:tid 140737328441984] [client 192.168.1.100:52312] File does not exist: /var/www/html/favicon.ico
```

**Field breakdown:**

- `[Fri Oct 10 13:55:36.123456 2025]` - Timestamp with microseconds
- `[core:error]` - Module name and log level
- `[pid 35708:tid 140737328441984]` - Process and thread IDs
- `[client 192.168.1.100:52312]` - Client IP and port
- Message content

### Log Levels

From highest to lowest severity:

- `emerg` - System is unusable
- `alert` - Immediate action required
- `crit` - Critical conditions
- `error` - Error conditions
- `warn` - Warning conditions
- `notice` - Normal but significant
- `info` - Informational
- `debug` - Debug-level messages

### Location and Configuration

**Default locations:**

```bash
# Debian/Ubuntu
/var/log/apache2/error.log

# RHEL/CentOS/Fedora
/var/log/httpd/error_log
```

**Configuration:**

```apache
ErrorLog /var/log/apache2/error.log
LogLevel warn
```

### CTF Analysis Commands

**Identifying security issues:**

```bash
# View critical errors only
grep "\[error\]" /var/log/apache2/error.log

# Find PHP execution errors (potential webshell activity)
grep "PHP" /var/log/apache2/error.log

# Detect permission denied errors (privilege escalation attempts)
grep "Permission denied" /var/log/apache2/error.log

# Find segmentation faults (potential exploitation)
grep -i "segfault" /var/log/apache2/error.log

# Identify file not found errors (reconnaissance activity)
grep "File does not exist" /var/log/apache2/error.log | awk '{print $NF}' | sort | uniq -c | sort -rn
```

**Module-specific issues:**

```bash
# SSL/TLS errors
grep "\[ssl:" /var/log/apache2/error.log

# ModSecurity alerts
grep "ModSecurity" /var/log/apache2/error.log

# Authentication failures
grep -E "(auth|password)" /var/log/apache2/error.log -i
```

**Correlation with access logs:**

```bash
# Extract error timestamps and find matching access entries
grep "192.168.1.100" /var/log/apache2/error.log | \
awk '{print $2,$3}' | while read date time; do
    grep "$date.*$time" /var/log/apache2/access.log
done
```

## Nginx Access and Error Logs

Nginx uses similar logging concepts but with different default formats and locations.

### Nginx Access Log Format

**Default combined format:**

```
192.168.1.100 - - [10/Oct/2025:13:55:36 +0000] "GET /index.html HTTP/1.1" 200 612 "http://example.com/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
```

**Field breakdown:**

- `192.168.1.100` - Client IP
- `-` - Remote user (RFC 1413)
- `-` - Authenticated user
- `[10/Oct/2025:13:55:36 +0000]` - Timestamp
- `"GET /index.html HTTP/1.1"` - Request line
- `200` - Status code
- `612` - Bytes sent
- `"http://example.com/"` - HTTP Referer
- `"Mozilla/5.0..."` - User-Agent

### Nginx Log Locations

**Default paths:**

```bash
# Access logs
/var/log/nginx/access.log

# Error logs
/var/log/nginx/error.log

# Per-site logs (common configuration)
/var/log/nginx/example.com.access.log
/var/log/nginx/example.com.error.log
```

### Configuration

**nginx.conf log format definition:**

```nginx
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';

access_log /var/log/nginx/access.log combined;
error_log /var/log/nginx/error.log warn;
```

**Custom format for enhanced CTF analysis:**

```nginx
log_format detailed '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent" '
                    'rt=$request_time uct="$upstream_connect_time" '
                    'uht="$upstream_header_time" urt="$upstream_response_time"';
```

### CTF Analysis Commands for Nginx

**Basic parsing:**

```bash
# Extract client IPs
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20

# Find requests by status code
awk '$9 == 404 {print $7}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# Extract User-Agents
awk -F'"' '{print $6}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# Find largest responses
awk '{print $10, $7}' /var/log/nginx/access.log | sort -rn | head -20
```

**Attack pattern detection:**

```bash
# Identify scanning activity (multiple 404s from same IP)
awk '$9 == 404 {print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | awk '$1 > 50'

# Find potential shell upload attempts
grep -E "\.php|\.jsp|\.asp" /var/log/nginx/access.log | grep "POST"

# Detect XXE/SSRF attempts
grep -E "(file://|gopher://|dict://|ftp://)" /var/log/nginx/access.log

# Identify credential stuffing
awk '$9 == 401 || $9 == 403 {print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn
```

### Nginx Error Log Analysis

**Error log format:**

```
2025/10/10 13:55:36 [error] 1234#1234: *1 open() "/var/www/html/favicon.ico" failed (2: No such file or directory), client: 192.168.1.100, server: example.com, request: "GET /favicon.ico HTTP/1.1", host: "example.com"
```

**Analysis commands:**

```bash
# Find all errors by level
grep "\[error\]" /var/log/nginx/error.log

# Critical errors only
grep "\[crit\]" /var/log/nginx/error.log

# Identify client-side issues
grep "client:" /var/log/nginx/error.log | awk -F'client: ' '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -rn

# Find upstream failures (backend server issues)
grep "upstream" /var/log/nginx/error.log

# SSL/TLS errors
grep -i "ssl" /var/log/nginx/error.log
```

## Combined Log Format (CLF)

The **Combined Log Format** extends the Common Log Format by adding Referer and User-Agent fields.

### Format Specification

```
%h %l %u %t "%r" %>s %b "%{Referer}i" "%{User-agent}i"
```

**Apache directive:**

```apache
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
CustomLog /var/log/apache2/access.log combined
```

**Nginx equivalent:**

```nginx
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

### Variable Definitions

- `%h` / `$remote_addr` - Remote host IP
- `%l` / `-` - Remote logname (RFC 1413, typically unused)
- `%u` / `$remote_user` - Remote user (HTTP auth)
- `%t` / `$time_local` - Time of request
- `%r` / `$request` - Request line
- `%>s` / `$status` - Final status code
- `%b` / `$body_bytes_sent` - Response size
- `%{Referer}i` / `$http_referer` - Referer header
- `%{User-agent}i` / `$http_user_agent` - User-Agent header

### CTF-Specific Combined Format Analysis

**Referer-based detection:**

```bash
# Find requests without referer (potential direct access/bots)
awk -F'"' '$4 == "-" {print}' /var/log/apache2/access.log

# Identify external referers (potential hotlinking/injection)
awk -F'"' '$4 !~ /example\.com/ && $4 != "-" {print $4}' /var/log/apache2/access.log | sort | uniq -c

# Find XSS attempts in referer
grep -E "(<script|javascript:|onerror=|onload=)" /var/log/apache2/access.log
```

**User-Agent analysis:**

```bash
# Detect common attack tools
grep -E "(sqlmap|nikto|nmap|masscan|nessus|burp|metasploit)" /var/log/apache2/access.log -i

# Find empty or suspicious User-Agents
awk -F'"' '$6 == "" || $6 == "-" {print}' /var/log/apache2/access.log

# Identify custom/unusual User-Agents
awk -F'"' '{print $6}' /var/log/apache2/access.log | grep -v "Mozilla" | sort | uniq -c | sort -rn
```

### Log Parsing with GoAccess

GoAccess provides real-time web log analysis:

```bash
# Install GoAccess
apt-get install goaccess

# Apache combined format analysis (real-time)
goaccess /var/log/apache2/access.log --log-format=COMBINED

# Generate HTML report
goaccess /var/log/apache2/access.log -o report.html --log-format=COMBINED

# Real-time dashboard
goaccess /var/log/apache2/access.log -o report.html --log-format=COMBINED --real-time-html

# Nginx analysis
goaccess /var/log/nginx/access.log --log-format=COMBINED
```

### Advanced Parsing with AWK Scripts

**Extract all failed login attempts with context:**

```bash
awk '$9 == 401 || $9 == 403 {
    printf "IP: %s | Time: %s | Request: %s | User-Agent: %s\n", 
    $1, $4, $7, $12
}' /var/log/apache2/access.log
```

**Calculate bandwidth per IP:**

```bash
awk '{ip[$1]+=$10} END {for (i in ip) printf "%-15s %10d bytes\n", i, ip[i]}' \
/var/log/apache2/access.log | sort -k2 -rn
```

**Identify potential DDoS sources:**

```bash
awk '{print $1}' /var/log/nginx/access.log | \
sort | uniq -c | sort -rn | \
awk '$1 > 1000 {printf "%s requests from %s\n", $1, $2}'
```

### Log Analysis Tools Summary

**Command-line tools:**

- `grep` - Pattern matching
- `awk` - Field extraction and processing
- `sed` - Stream editing
- `cut` - Column extraction
- `sort` / `uniq` - Sorting and deduplication
- `wc` - Counting
- `tail` / `head` - File beginning/end viewing

**Specialized tools:**

- `goaccess` - Real-time web log analyzer
- `logwatch` - Automated log analysis
- `awstats` - Web analytics
- `webalizer` - Web statistics
- `logstalgia` - Visual log analysis
- `apache-scalp` - Attack pattern detection

---

## Custom Log Formats

Web servers allow administrators to define custom logging formats beyond the default configurations. Understanding these formats is critical for CTF log analysis as they may contain hidden indicators or deliberately obfuscated information.

### Apache Custom Log Formats

Apache uses the `LogFormat` directive to define custom formats. The syntax is:

```apache
LogFormat "format_string" nickname
CustomLog /path/to/logfile nickname
```

**Common Format Tokens:**

- `%h` - Remote hostname/IP
- `%l` - Remote logname (usually `-`)
- `%u` - Remote user (authenticated)
- `%t` - Time (format: `[day/month/year:hour:minute:second zone]`)
- `%r` - First line of request
- `%>s` - Final status code
- `%b` - Size of response in bytes (excluding headers)
- `%{Referer}i` - Referer header
- `%{User-Agent}i` - User-Agent string
- `%D` - Time taken to serve request (microseconds)
- `%T` - Time taken to serve request (seconds)
- `%I` - Bytes received (including headers)
- `%O` - Bytes sent (including headers)
- `%X` - Connection status when response completed
- `%{COOKIE_NAME}C` - Contents of specific cookie
- `%{HEADER_NAME}i` - Contents of specific request header

**Analyzing Custom Formats in CTF:**

```bash
# Identify the log format from Apache config
grep -r "LogFormat" /etc/apache2/
grep -r "CustomLog" /etc/apache2/

# Common locations on Kali/Debian systems
cat /etc/apache2/apache2.conf
cat /etc/apache2/sites-available/*.conf
```

**Parsing Custom Formats:**

```bash
# Extract the format string from config
grep "LogFormat" /etc/apache2/apache2.conf | grep "combined"

# Use awk with field positions matching your custom format
# Example: Custom format with IP, timestamp, request, status, bytes
awk '{print $1, $4, $7, $9, $10}' /var/log/apache2/access.log

# For complex formats, use Python
python3 << 'EOF'
import re
log_format = r'(?P<ip>\S+) \S+ \S+ \[(?P<time>.*?)\] "(?P<request>.*?)" (?P<status>\d+) (?P<bytes>\S+)'
with open('/var/log/apache2/access.log') as f:
    for line in f:
        match = re.match(log_format, line)
        if match:
            print(match.groupdict())
EOF
```

### Nginx Custom Log Formats

Nginx uses the `log_format` directive:

```nginx
log_format custom_format '$remote_addr - $remote_user [$time_local] "$request" '
                         '$status $body_bytes_sent "$http_referer" '
                         '"$http_user_agent" "$http_x_forwarded_for"';
access_log /var/log/nginx/access.log custom_format;
```

**Key Nginx Variables:**

- `$remote_addr` - Client IP
- `$remote_user` - HTTP authenticated user
- `$time_local` - Local timestamp
- `$request` - Full request line
- `$status` - Response status
- `$body_bytes_sent` - Bytes sent (body only)
- `$http_referer` - Referer header
- `$http_user_agent` - User-Agent
- `$http_x_forwarded_for` - X-Forwarded-For header (proxy chain)
- `$request_time` - Request processing time (seconds, milliseconds precision)
- `$upstream_response_time` - Backend response time
- `$ssl_protocol` - SSL/TLS protocol version
- `$ssl_cipher` - Cipher suite used

**CTF Analysis Commands:**

```bash
# Find Nginx log format
grep -r "log_format" /etc/nginx/
cat /etc/nginx/nginx.conf

# Parse with awk (adjust field numbers)
awk '{print $1, $7, $9}' /var/log/nginx/access.log

# Extract JSON-formatted logs (if custom format uses JSON)
cat /var/log/nginx/access.log | jq '.request, .status, .ip'
```

### IIS Custom Log Formats

IIS logs can use W3C Extended format with custom fields selected via GUI or configuration.

**Common W3C Fields:**

- `date`, `time` - Timestamp components
- `s-ip` - Server IP
- `cs-method` - HTTP method
- `cs-uri-stem` - URI path
- `cs-uri-query` - Query string
- `s-port` - Server port
- `cs-username` - Authenticated username
- `c-ip` - Client IP
- `cs(User-Agent)` - User-Agent
- `cs(Referer)` - Referer
- `sc-status` - HTTP status
- `sc-substatus` - Sub-status code (IIS-specific)
- `sc-win32-status` - Windows error code
- `time-taken` - Request duration (milliseconds)

**Analysis on Kali (IIS logs obtained during CTF):**

```bash
# IIS logs are space-delimited with header lines starting with #
grep -v "^#" iis.log | awk '{print $9, $5, $8}' # c-ip, cs-method, sc-status

# Extract headers to understand field positions
grep "^#Fields:" iis.log
```

### CTF-Specific Custom Format Indicators

In CTF challenges, custom formats may include:

1. **Base64-encoded fields** - Custom tokens that contain encoded flags
2. **Timing covert channels** - Microsecond-level timing fields hiding data
3. **Custom headers** - Non-standard headers logged via `%{X-Custom-Header}i`
4. **Cookie extraction** - Specific cookie values containing session data
5. **Binary data** - Unusual characters or encoding in logged fields

**Detection techniques:**

```bash
# Find unusual characters (potential encoding)
cat access.log | tr -cd '\11\12\15\40-\176' | less # Show only printable ASCII

# Extract all unique custom headers logged
grep -oP '"\K[^"]+(?=")' access.log | grep "^X-" | sort -u

# Identify base64 patterns in logs
grep -oE '[A-Za-z0-9+/]{20,}={0,2}' access.log

# Find timing anomalies
awk '{print $NF}' access.log | sort -n | uniq -c
```

## Virtual Host Logs

Virtual hosts (vhosts) allow multiple domains/sites to run on a single web server. Each vhost can have separate log files, creating multiple log sources to analyze in CTF scenarios.

### Apache Virtual Host Configuration

**Configuration structure:**

```apache
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example
    
    ErrorLog ${APACHE_LOG_DIR}/example_error.log
    CustomLog ${APACHE_LOG_DIR}/example_access.log combined
</VirtualHost>

<VirtualHost *:80>
    ServerName admin.example.com
    DocumentRoot /var/www/admin
    
    ErrorLog ${APACHE_LOG_DIR}/admin_error.log
    CustomLog ${APACHE_LOG_DIR}/admin_access.log combined
</VirtualHost>
```

**Locating vhost configurations:**

```bash
# Debian/Kali Apache
ls -la /etc/apache2/sites-available/
ls -la /etc/apache2/sites-enabled/

# View all enabled vhosts
apache2ctl -S

# Extract ServerName directives
grep -r "ServerName" /etc/apache2/sites-enabled/

# Find all CustomLog directives
grep -r "CustomLog" /etc/apache2/sites-enabled/
```

### Nginx Virtual Host Configuration

```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    root /var/www/example;
    
    access_log /var/log/nginx/example_access.log;
    error_log /var/log/nginx/example_error.log;
}

server {
    listen 80;
    server_name admin.example.com;
    root /var/www/admin;
    
    access_log /var/log/nginx/admin_access.log;
    error_log /var/log/nginx/admin_error.log;
}
```

**Locating Nginx vhosts:**

```bash
# Nginx configuration locations
ls -la /etc/nginx/sites-available/
ls -la /etc/nginx/sites-enabled/

# Show all server blocks
nginx -T | grep -A 10 "server {"

# Extract server_name directives
grep -r "server_name" /etc/nginx/sites-enabled/

# Find all access_log directives
grep -r "access_log" /etc/nginx/sites-enabled/
```

### CTF Analysis of Virtual Host Logs

**Identifying all vhost logs:**

```bash
# Find all log files in standard directories
find /var/log/apache2/ -name "*access*" -o -name "*error*"
find /var/log/nginx/ -name "*access*" -o -name "*error*"

# List by modification time (find recently active vhosts)
ls -lt /var/log/apache2/
ls -lt /var/log/nginx/

# Count log entries per vhost
for log in /var/log/apache2/*access*.log; do
    echo "$log: $(wc -l < $log) entries"
done
```

**Correlating activity across vhosts:**

```bash
# Merge multiple vhost logs by timestamp
# Apache format: [day/month/year:hour:minute:second zone]
sort -t'[' -k2 /var/log/apache2/example_access.log /var/log/apache2/admin_access.log

# For Nginx (ISO timestamp)
sort -k4 /var/log/nginx/example_access.log /var/log/nginx/admin_access.log

# Find common IPs across different vhosts
grep -h -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' /var/log/apache2/example_access.log | sort -u > example_ips.txt
grep -h -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' /var/log/apache2/admin_access.log | sort -u > admin_ips.txt
comm -12 example_ips.txt admin_ips.txt
```

**Name-based vs IP-based vhosts:**

Name-based vhosts rely on the `Host` header, which can be spoofed or missing:

```bash
# Find requests without proper Host header
grep -v "Host:" /var/log/apache2/access.log

# Identify default vhost usage (requests that didn't match any vhost)
# Check logs in default or first-listed vhost config
```

### Hidden or Development Vhosts

CTF scenarios often include undiscovered vhosts that contain flags or vulnerabilities.

**Discovery techniques:**

```bash
# Extract ServerName/ServerAlias from configs
grep -rh "ServerName\|ServerAlias" /etc/apache2/ | awk '{print $2}' | sort -u

# Check /etc/hosts for mapped domains
cat /etc/hosts | grep -v "^#" | grep -v "localhost"

# Analyze Host headers in logs to find undocumented vhosts
awk '{print $1}' /var/log/nginx/access.log | grep -oP 'Host: \K[^\s]+' | sort -u

# DNS enumeration (if applicable)
gobuster dns -d example.com -w /usr/share/wordlists/subdomains.txt
```

**Testing discovered vhosts:**

```bash
# Direct access with curl
curl -H "Host: admin.example.com" http://target-ip/

# Modify /etc/hosts for browser access
echo "192.168.1.100 admin.example.com" >> /etc/hosts
```

### Vhost-Specific Security Misconfigurations

Different vhosts may have different security postures:

```bash
# Compare authentication requirements
grep -r "AuthType" /etc/apache2/sites-enabled/
grep -r "auth_basic" /etc/nginx/sites-enabled/

# Check directory listing permissions
grep -r "Options.*Indexes" /etc/apache2/sites-enabled/
grep -r "autoindex" /etc/nginx/sites-enabled/

# Identify PHP execution differences
grep -r "php_admin_flag" /etc/apache2/sites-enabled/
```

## SSL/TLS Logs

SSL/TLS logs contain information about encrypted connections, certificate validation, cipher negotiations, and protocol versions. These logs are critical for identifying man-in-the-middle attacks, weak cryptography, and certificate-based authentication in CTF challenges.

### Apache SSL/TLS Logging

Apache's `mod_ssl` module provides SSL-specific logging variables.

**Enable SSL logging:**

```apache
<VirtualHost *:443>
    ServerName secure.example.com
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key
    
    # Custom SSL log format
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" SSL:%{SSL_PROTOCOL}x Cipher:%{SSL_CIPHER}x" ssl_combined
    CustomLog ${APACHE_LOG_DIR}/ssl_access.log ssl_combined
    ErrorLog ${APACHE_LOG_DIR}/ssl_error.log
    
    # Detailed SSL logging
    LogLevel ssl:debug
</VirtualHost>
```

**Key SSL variables for logging:**

- `%{SSL_PROTOCOL}x` - SSL/TLS version (SSLv3, TLSv1, TLSv1.1, TLSv1.2, TLSv1.3)
- `%{SSL_CIPHER}x` - Cipher suite negotiated
- `%{SSL_CIPHER_EXPORT}x` - Whether export-grade cipher
- `%{SSL_CIPHER_USEKEYSIZE}x` - Key size in use
- `%{SSL_CIPHER_ALGKEYSIZE}x` - Advertised key size
- `%{SSL_CLIENT_S_DN}x` - Client certificate subject DN
- `%{SSL_CLIENT_I_DN}x` - Client certificate issuer DN
- `%{SSL_CLIENT_VERIFY}x` - Client cert verification result
- `%{SSL_SESSION_ID}x` - SSL session ID
- `%{SSL_SESSION_RESUMED}x` - Whether session resumed
- `%{SSL_TLS_SNI}x` - Server Name Indication (SNI) value

**Analysis commands:**

```bash
# Find SSL-specific log entries
grep "SSL:" /var/log/apache2/ssl_access.log

# Extract cipher suites in use
grep -oP 'Cipher:\K[^\s]+' /var/log/apache2/ssl_access.log | sort | uniq -c

# Find weak ciphers (export, DES, RC4, MD5)
grep -E 'Cipher:.*(EXPORT|DES|RC4|MD5)' /var/log/apache2/ssl_access.log

# Identify TLS versions
grep -oP 'SSL:\K[^\s]+' /var/log/apache2/ssl_access.log | sort | uniq -c

# Find deprecated protocols (SSLv3, TLSv1.0, TLSv1.1)
grep -E 'SSL:(SSLv3|TLSv1\.[01])' /var/log/apache2/ssl_access.log

# Check SSL error log for handshake failures
grep -i "ssl" /var/log/apache2/ssl_error.log
grep -i "handshake" /var/log/apache2/ssl_error.log
```

### Nginx SSL/TLS Logging

Nginx provides similar SSL variables for custom logging.

**Configuration:**

```nginx
log_format ssl_combined '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" '
                        'SSL:$ssl_protocol Cipher:$ssl_cipher '
                        'Session:$ssl_session_id Reused:$ssl_session_reused';

server {
    listen 443 ssl;
    server_name secure.example.com;
    
    ssl_certificate /etc/ssl/certs/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;
    
    access_log /var/log/nginx/ssl_access.log ssl_combined;
    error_log /var/log/nginx/ssl_error.log info;
}
```

**Key Nginx SSL variables:**

- `$ssl_protocol` - TLS version
- `$ssl_cipher` - Cipher suite
- `$ssl_ciphers` - Client-offered ciphers
- `$ssl_curves` - Supported curves
- `$ssl_session_id` - Session ID
- `$ssl_session_reused` - `r` if reused, `.` if not
- `$ssl_server_name` - SNI hostname
- `$ssl_client_cert` - Client certificate (PEM)
- `$ssl_client_s_dn` - Client cert subject
- `$ssl_client_i_dn` - Client cert issuer
- `$ssl_client_verify` - Verification result (SUCCESS, FAILED, NONE)

**Analysis commands:**

```bash
# Extract SSL protocols
awk '{print $12}' /var/log/nginx/ssl_access.log | sort | uniq -c

# Find cipher suites
awk '{print $14}' /var/log/nginx/ssl_access.log | sort | uniq -c

# Identify session resumption rate
grep -o "Reused:[r\.]" /var/log/nginx/ssl_access.log | sort | uniq -c

# Check SSL errors
grep -i "ssl" /var/log/nginx/ssl_error.log
```

### Client Certificate Authentication Logs

When client certificate authentication is enabled, logs contain certificate details.

**Apache configuration:**

```apache
SSLVerifyClient require
SSLVerifyDepth 2
SSLCACertificateFile /etc/ssl/certs/ca-bundle.crt

LogFormat "%h %u \"%{SSL_CLIENT_S_DN}x\" %t \"%r\" %>s %b" clientcert
CustomLog ${APACHE_LOG_DIR}/clientcert_access.log clientcert
```

**Analysis:**

```bash
# Extract client certificate subjects
grep -oP 'CN=[^,]+' /var/log/apache2/clientcert_access.log | sort | uniq -c

# Find failed client cert validations
grep "SSL_CLIENT_VERIFY:FAILED" /var/log/apache2/ssl_error.log

# Identify specific users by certificate CN
grep "CN=john.doe" /var/log/apache2/clientcert_access.log
```

### SNI (Server Name Indication) Analysis

SNI allows multiple SSL certificates on a single IP. The requested hostname is visible in plaintext during the TLS handshake.

```bash
# Extract SNI values from Apache logs
grep -oP 'SSL_TLS_SNI:\K[^\s]+' /var/log/apache2/ssl_access.log | sort | uniq -c

# From Nginx logs
grep -oP '\$ssl_server_name:\K[^\s]+' /var/log/nginx/ssl_access.log | sort | uniq -c

# Network-level SNI extraction (if pcap available)
tshark -r capture.pcap -Y "ssl.handshake.extensions_server_name" -T fields -e ssl.handshake.extensions_server_name | sort | uniq -c
```

### TLS Handshake Failure Analysis

Handshake failures indicate mismatched configurations, attacks, or reconnaissance.

```bash
# Apache SSL error log patterns
grep "SSL handshake failed" /var/log/apache2/ssl_error.log
grep "certificate verify failed" /var/log/apache2/ssl_error.log
grep "no shared cipher" /var/log/apache2/ssl_error.log
grep "unsupported protocol" /var/log/apache2/ssl_error.log

# Nginx error log patterns
grep "SSL_do_handshake() failed" /var/log/nginx/ssl_error.log
grep "peer closed connection" /var/log/nginx/ssl_error.log
grep "certificate verification failed" /var/log/nginx/ssl_error.log

# Count failures by type
grep "SSL" /var/log/apache2/ssl_error.log | awk '{print $NF}' | sort | uniq -c
```

### Perfect Forward Secrecy (PFS) Detection

PFS ensures session keys aren't compromised if the server's private key is compromised later.

```bash
# Identify non-PFS ciphers (typically RSA key exchange)
grep -E 'Cipher:.*-RSA-' /var/log/apache2/ssl_access.log

# Find PFS ciphers (ECDHE, DHE)
grep -E 'Cipher:.*(ECDHE|DHE)' /var/log/apache2/ssl_access.log

# Calculate PFS usage percentage
total=$(wc -l < /var/log/apache2/ssl_access.log)
pfs=$(grep -cE 'Cipher:.*(ECDHE|DHE)' /var/log/apache2/ssl_access.log)
echo "scale=2; $pfs * 100 / $total" | bc
```

### CTF-Specific SSL/TLS Log Analysis

**Common CTF scenarios:**

1. **Weak cipher exploitation** - Finding deprecated ciphers that can be downgraded
2. **Certificate CN/SAN analysis** - Hidden domains in certificate alternate names
3. **Session ID correlation** - Tracking users across multiple connections
4. **Timing attacks** - SSL handshake timing variations hiding covert channels
5. **Client cert flags** - Flags embedded in certificate fields

**Targeted commands:**

```bash
# Find uncommon cipher suites (potential CTF flags)
grep -oP 'Cipher:\K[^\s]+' ssl_access.log | sort | uniq -c | sort -n

# Extract all certificate DNs for hidden data
grep -oP 'SSL_CLIENT_S_DN:\K[^"]+' ssl_access.log

# Analyze SSL session IDs for patterns
grep -oP 'Session:\K[A-F0-9]+' ssl_access.log | while read sid; do
    echo "$sid" | xxd -r -p 2>/dev/null || echo "$sid"
done

# Check for SSL renegotiation patterns
grep -i "renegotiat" /var/log/apache2/ssl_error.log

# Identify BEAST/CRIME/BREACH vulnerable configurations
grep -E "Cipher:.*(CBC|DEFLATE)" ssl_access.log
```

### Tools for SSL/TLS Log Analysis

```bash
# Parse logs with ssldump (if you have packet captures)
ssldump -r capture.pcap -d | grep -A 5 "ServerHello"

# Analyze SSL configuration (not logs, but useful for context)
sslscan target.example.com
nmap --script ssl-enum-ciphers -p 443 target.example.com

# Extract certificates from logs or live connections
openssl s_client -connect target.example.com:443 -showcerts

# Decode base64-encoded certificates in logs
grep "BEGIN CERTIFICATE" logfile | base64 -d | openssl x509 -text -noout
```

---

**Important related subtopics for comprehensive CTF log analysis:**

- **Log correlation techniques** - Combining multiple log sources (web, system, application) for complete attack chain analysis
- **Time synchronization issues** - Handling logs with clock skew or timezone mismatches
- **Log injection and evasion techniques** - Identifying attacker attempts to poison or hide in logs

---

# Application Logs

Application logs record runtime events, errors, and diagnostic information from web applications and services. In CTF scenarios, these logs often contain sensitive information leakage, authentication attempts, error states revealing misconfigurations, or indicators of vulnerable code paths.

## PHP Error Logs

PHP error logs capture runtime errors, warnings, notices, and debug information from PHP applications. These logs are critical for identifying code vulnerabilities, information disclosure, and application logic flaws.

### Log Location Paths

**Linux/Unix Systems:**

- `/var/log/apache2/error.log` (Debian/Ubuntu with Apache)
- `/var/log/httpd/error_log` (RHEL/CentOS with Apache)
- `/var/log/nginx/error.log` (Nginx)
- `/var/log/php-fpm/error.log` (PHP-FPM)
- `/var/log/php/error.log` (standalone PHP)
- Custom locations defined in `php.ini` via `error_log` directive

**Windows Systems:**

- `C:\xampp\apache\logs\error.log` (XAMPP)
- `C:\wamp64\logs\php_error.log` (WAMP)
- `C:\inetpub\logs\LogFiles\` (IIS with PHP)

### Configuration Files

Check `php.ini` for logging configuration:

```bash
# Locate php.ini
php --ini

# Check current error reporting settings
php -i | grep -E "error_log|error_reporting|display_errors"
```

Key directives:

- `error_reporting = E_ALL` - Controls which errors are reported
- `display_errors = On/Off` - Whether errors appear in output
- `log_errors = On` - Enables error logging
- `error_log = /path/to/file` - Log destination

### Log Analysis Commands

**Basic log inspection:**

```bash
# View recent errors
tail -f /var/log/apache2/error.log

# Search for specific error types
grep -i "fatal error" /var/log/apache2/error.log
grep -i "parse error" /var/log/apache2/error.log
grep -i "warning" /var/log/apache2/error.log

# Find SQL errors (potential SQLi indicators)
grep -iE "mysql|mysqli|pdo|sql syntax" /var/log/apache2/error.log

# Search for file inclusion errors
grep -iE "include|require|fopen|file_get_contents" /var/log/apache2/error.log

# Find path disclosure
grep -iE "/var/www|/home|C:\\" /var/log/apache2/error.log
```

**Time-based filtering:**

```bash
# Errors from specific date
grep "28-Oct-2025" /var/log/apache2/error.log

# Last hour of errors (requires timestamp parsing)
awk -v d="$(date --date='1 hour ago' '+%d/%b/%Y:%H')" '$0 ~ d' /var/log/apache2/error.log
```

**Pattern extraction:**

```bash
# Extract all file paths from errors
grep -oE '/[a-zA-Z0-9_/.-]+\.php' /var/log/apache2/error.log | sort -u

# Extract IP addresses from error contexts
grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /var/log/apache2/error.log | sort -u

# Find stack traces
grep -A 20 "Stack trace:" /var/log/apache2/error.log
```

### CTF-Specific Exploitation Patterns

**Information Disclosure:**

```bash
# Database credentials in error messages
grep -iE "access denied.*using password|connection failed.*mysql" /var/log/apache2/error.log

# Absolute path disclosure
grep -oE '/var/www/[a-zA-Z0-9_/.-]+' /var/log/apache2/error.log | sort -u

# Configuration file paths
grep -iE "config\.php|settings\.php|\.env" /var/log/apache2/error.log
```

**Vulnerable Function Usage:**

```bash
# Dangerous functions that may indicate vulnerabilities
grep -iE "eval\(|exec\(|system\(|passthru\(|shell_exec\(|assert\(" /var/log/apache2/error.log

# Unserialize errors (potential object injection)
grep -i "unserialize" /var/log/apache2/error.log

# File operation errors
grep -iE "file_get_contents|fopen|readfile|include|require" /var/log/apache2/error.log
```

**Authentication Bypass Indicators:**

```bash
# Session errors
grep -iE "session_start|session_destroy|session error" /var/log/apache2/error.log

# Authentication failures revealing logic
grep -iE "login|auth|password|credential" /var/log/apache2/error.log
```

### Log Format Understanding

Standard PHP error log format:

```
[Day Mon DD HH:MM:SS.mmmmmm YYYY] [php7:error] [pid XXXXX] [client IP:PORT] PHP Fatal error: Message in /path/to/file.php on line XX
```

Components to analyze:

- **Timestamp**: Correlate with attack timing
- **Error level**: `Fatal error`, `Warning`, `Notice`, `Parse error`
- **Client IP**: Identify attacker source
- **File path**: Vulnerable script location
- **Line number**: Exact vulnerability location
- **Error message**: Nature of the problem

### Automated Analysis Tools

**phpLogReader (custom script example):**

```bash
#!/bin/bash
# Extract critical PHP errors
LOGFILE="/var/log/apache2/error.log"

echo "[+] Fatal Errors:"
grep "PHP Fatal error" "$LOGFILE" | tail -20

echo -e "\n[+] Path Disclosures:"
grep -oE '/var/www/[^ ]+' "$LOGFILE" | sort -u | head -20

echo -e "\n[+] Database Errors:"
grep -iE "mysql|mysqli|pdo" "$LOGFILE" | tail -10
```

**Using awk for structured parsing:**

```bash
# Extract errors by severity
awk -F'[][]' '/PHP Fatal error/ {print $6}' /var/log/apache2/error.log

# Count errors by file
awk '{for(i=1;i<=NF;i++) if($i~/\.php/) print $i}' /var/log/apache2/error.log | sort | uniq -c | sort -rn
```

### Common CTF Scenarios

**Scenario 1: SQL Injection Detection**

```bash
# Look for SQL syntax errors revealing query structure
grep -i "sql syntax" /var/log/apache2/error.log
# Output example: "You have an error in your SQL syntax... near 'admin' LIMIT 1'"
```

**Scenario 2: LFI/RFI Vulnerability**

```bash
# Failed include attempts
grep -iE "failed to open stream|No such file" /var/log/apache2/error.log | grep -E "include|require"
```

**Scenario 3: Credential Discovery**

```bash
# Database connection errors exposing credentials
grep -i "access denied for user" /var/log/apache2/error.log
# May reveal: "Access denied for user 'webapp'@'localhost' (using password: YES)"
```

## Python Application Logs

Python applications use various logging frameworks, most commonly the built-in `logging` module. Log format, location, and verbosity depend heavily on application configuration.

### Log Location Patterns

**Framework-specific locations:**

- **Flask**: Often configured in app initialization, default to stderr/stdout
- **Django**: `settings.py` defines logging, commonly in project root or `/var/log/django/`
- **FastAPI**: Uvicorn/Gunicorn logs, typically stdout or `/var/log/uvicorn/`
- **General Python**: Custom locations via `logging.basicConfig(filename=...)`

**Common paths:**

```bash
/var/log/python/application.log
/var/log/uwsgi/app.log
/var/log/gunicorn/error.log
/home/user/app/logs/app.log
./app.log (application directory)
```

### Python Logging Module Levels

```
CRITICAL (50) - Serious errors, program may crash
ERROR (40) - Serious problems, function failed
WARNING (30) - Indication something unexpected happened
INFO (20) - Confirmation things are working
DEBUG (10) - Detailed diagnostic information
```

### Log Analysis Commands

**Basic inspection:**

```bash
# View application logs
tail -f /var/log/python/application.log

# Filter by log level
grep "ERROR" /var/log/python/application.log
grep "CRITICAL" /var/log/python/application.log
grep "WARNING" /var/log/python/application.log

# Search for exceptions
grep -A 10 "Traceback (most recent call last):" /var/log/python/application.log

# Find specific exception types
grep -iE "ValueError|TypeError|AttributeError|KeyError" /var/log/python/application.log
```

**Framework-specific searches:**

**Django:**

```bash
# Django debug messages
grep "DEBUG" /var/log/django/debug.log

# Database query errors
grep -i "DatabaseError\|OperationalError" /var/log/django/application.log

# Authentication failures
grep -i "authentication\|login failed" /var/log/django/application.log

# Template errors
grep "TemplateDoesNotExist\|TemplateSyntaxError" /var/log/django/application.log
```

**Flask:**

```bash
# Flask errors (often in werkzeug logs)
grep -i "werkzeug" /var/log/flask/application.log

# Route errors
grep -i "404\|405 Method Not Allowed" /var/log/flask/application.log

# Application exceptions
grep -B 5 -A 10 "Exception on" /var/log/flask/application.log
```

### Traceback Analysis

Python tracebacks reveal execution flow and code structure:

```bash
# Extract complete tracebacks
awk '/Traceback \(most recent call last\):/{flag=1} flag; /^[^ ]/ && flag{print "---"; flag=0}' /var/log/python/application.log

# Find file paths in tracebacks
grep -oE 'File "[^"]+", line [0-9]+' /var/log/python/application.log | sort -u

# Extract function names from tracebacks
grep -oE 'in [a-zA-Z_][a-zA-Z0-9_]+' /var/log/python/application.log | sort -u
```

### CTF-Specific Exploitation Patterns

**Deserialization Vulnerabilities:**

```bash
# Pickle-related errors
grep -i "pickle\|unpickle" /var/log/python/application.log

# YAML deserialization (PyYAML)
grep -i "yaml.load" /var/log/python/application.log
```

**Command Injection Indicators:**

```bash
# Subprocess/shell errors
grep -iE "subprocess|os\.system|os\.popen|shell=True" /var/log/python/application.log

# Command not found errors
grep -i "command not found\|No such file or directory" /var/log/python/application.log
```

**Path Traversal:**

```bash
# File operation errors
grep -iE "FileNotFoundError|PermissionError" /var/log/python/application.log

# Suspicious path patterns
grep -oE "(\.\./|\.\.\\\\)+" /var/log/python/application.log
```

**SQL Injection (SQLAlchemy, Django ORM):**

```bash
# SQL syntax errors
grep -i "syntax error\|OperationalError" /var/log/python/application.log

# Raw SQL queries in errors
grep -i "SELECT\|INSERT\|UPDATE\|DELETE" /var/log/python/application.log | grep -i error
```

**SSTI (Server-Side Template Injection):**

```bash
# Template errors revealing injection
grep -iE "TemplateSyntaxError|UndefinedError|SecurityError" /var/log/python/application.log

# Jinja2 specific
grep -i "jinja2" /var/log/python/application.log
```

### Information Disclosure Patterns

```bash
# API keys and secrets in error messages
grep -iE "api[_-]?key|secret|token|password" /var/log/python/application.log

# Environment variables in tracebacks
grep -oE "[A-Z_]+=[^ ]+" /var/log/python/application.log

# Database connection strings
grep -iE "postgresql://|mysql://|mongodb://" /var/log/python/application.log

# Internal IP addresses and ports
grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+" /var/log/python/application.log
```

### Structured Log Analysis (JSON Logs)

Many modern Python applications use JSON logging:

```bash
# Pretty print JSON logs
cat /var/log/python/application.log | jq '.'

# Filter by log level
cat /var/log/python/application.log | jq 'select(.level == "ERROR")'

# Extract specific fields
cat /var/log/python/application.log | jq -r '.message'

# Find logs with exceptions
cat /var/log/python/application.log | jq 'select(.exc_info != null)'

# Time-based filtering
cat /var/log/python/application.log | jq 'select(.timestamp > "2025-10-28T10:00:00")'
```

### Automated Analysis Script

```bash
#!/bin/bash
# Python log analyzer for CTF

LOGFILE="${1:-/var/log/python/application.log}"

echo "[+] Exception Summary:"
grep -c "Traceback" "$LOGFILE"

echo -e "\n[+] Recent Errors:"
grep "ERROR\|CRITICAL" "$LOGFILE" | tail -10

echo -e "\n[+] Unique File Paths:"
grep -oE 'File "[^"]+\.py"' "$LOGFILE" | sort -u | head -20

echo -e "\n[+] Potential Vulnerabilities:"
grep -iE "pickle|yaml\.load|eval\(|exec\(|system\(" "$LOGFILE" | wc -l
echo "  - Deserialization/Code Exec hits found"

echo -e "\n[+] Authentication Events:"
grep -iE "login|authentication|unauthorized" "$LOGFILE" | tail -5
```

## Node.js Logs

Node.js applications typically log to stdout/stderr or use logging libraries like Winston, Bunyan, or Pino. Log structure varies significantly based on the framework and logging configuration.

### Log Location Patterns

**Common locations:**

- **Console output redirected**: `/var/log/nodejs/application.log`
- **PM2 managed**: `~/.pm2/logs/app-error.log` and `~/.pm2/logs/app-out.log`
- **Forever**: `/var/log/forever/application.log`
- **Systemd service**: `journalctl -u service-name`
- **Docker containers**: `docker logs container-name`
- **Custom Winston/Bunyan**: Application-defined paths

**Framework-specific:**

- **Express.js**: Often stdout/stderr, Morgan for HTTP logs
- **Next.js**: `.next/` directory or custom locations
- **Nest.js**: Configured in main.ts, often `/var/log/nestjs/`

### Accessing Logs by Deployment Method

**PM2:**

```bash
# View real-time logs
pm2 logs app-name

# View error logs only
pm2 logs app-name --err

# View specific lines
pm2 logs app-name --lines 100

# Log file locations
ls ~/.pm2/logs/
cat ~/.pm2/logs/app-error-0.log
```

**Systemd:**

```bash
# View service logs
journalctl -u nodejs-app.service

# Follow logs in real-time
journalctl -u nodejs-app.service -f

# Show last 100 lines
journalctl -u nodejs-app.service -n 100

# Filter by time
journalctl -u nodejs-app.service --since "2025-10-28 10:00:00"
```

**Docker:**

```bash
# View container logs
docker logs container-name

# Follow logs
docker logs -f container-name

# Last 100 lines
docker logs --tail 100 container-name

# With timestamps
docker logs -t container-name
```

### Log Analysis Commands

**Basic inspection:**

```bash
# View recent logs
tail -f /var/log/nodejs/application.log

# Search for errors
grep -i "error" /var/log/nodejs/application.log
grep -i "exception" /var/log/nodejs/application.log
grep -i "unhandled" /var/log/nodejs/application.log

# Find stack traces
grep -A 15 "Error:" /var/log/nodejs/application.log

# Specific error types
grep -E "TypeError|ReferenceError|SyntaxError|RangeError" /var/log/nodejs/application.log
```

**JSON log parsing (Winston/Bunyan/Pino):**

```bash
# Pretty print JSON logs
cat /var/log/nodejs/application.log | jq '.'

# Filter by level
cat /var/log/nodejs/application.log | jq 'select(.level == "error")'

# Extract messages
cat /var/log/nodejs/application.log | jq -r '.message'

# Find errors with stack traces
cat /var/log/nodejs/application.log | jq 'select(.stack != null)'

# Bunyan CLI tool
bunyan /var/log/nodejs/application.log

# Filter Bunyan logs
bunyan /var/log/nodejs/application.log -l error
```

### CTF-Specific Exploitation Patterns

**Prototype Pollution:**

```bash
# Look for prototype-related errors
grep -i "prototype\|__proto__\|constructor" /var/log/nodejs/application.log

# Object property errors
grep -i "Cannot read property\|Cannot set property" /var/log/nodejs/application.log
```

**Command Injection:**

```bash
# Child process errors
grep -iE "child_process|exec\(|spawn\(|execSync" /var/log/nodejs/application.log

# Shell command errors
grep -i "sh: \|bash: \|command not found" /var/log/nodejs/application.log

# ENOENT errors (file not found - may indicate command injection attempts)
grep "ENOENT" /var/log/nodejs/application.log
```

**NoSQL Injection (MongoDB):**

```bash
# MongoDB errors
grep -iE "mongodb|mongoose" /var/log/nodejs/application.log

# Query errors
grep -i "MongoError\|CastError" /var/log/nodejs/application.log

# Operator injection indicators
grep -E "\$where|\$gt|\$ne|\$regex" /var/log/nodejs/application.log
```

**Path Traversal:**

```bash
# File system errors
grep -i "EACCES\|EPERM\|ENOENT" /var/log/nodejs/application.log

# Suspicious path patterns
grep -oE "(\.\./|\.\.\\\\)+" /var/log/nodejs/application.log

# Filesystem function errors
grep -iE "readFile|writeFile|access|stat" /var/log/nodejs/application.log
```

**Deserialization/Code Injection:**

```bash
# Unsafe eval usage
grep -i "eval\(|Function(" /var/log/nodejs/application.log

# Serialization errors
grep -i "JSON.parse\|serialize\|deserialize" /var/log/nodejs/application.log

# Template injection (EJS, Pug, etc.)
grep -iE "ejs|pug|handlebars|template" /var/log/nodejs/application.log
```

**JWT and Authentication Issues:**

```bash
# JWT errors
grep -i "jwt\|jsonwebtoken\|token" /var/log/nodejs/application.log

# Authentication failures
grep -iE "authentication|unauthorized|401|403" /var/log/nodejs/application.log

# Session errors
grep -i "session" /var/log/nodejs/application.log
```

### Express.js Specific Analysis

**HTTP request errors:**

```bash
# Method not allowed
grep "405\|Method Not Allowed" /var/log/nodejs/application.log

# Not found routes
grep "404\|Cannot GET\|Cannot POST" /var/log/nodejs/application.log

# Server errors
grep "500\|Internal Server Error" /var/log/nodejs/application.log

# Morgan logs (HTTP request logs)
grep -E "GET|POST|PUT|DELETE|PATCH" /var/log/nodejs/application.log
```

**Middleware errors:**

```bash
# Body parser errors
grep -i "body-parser\|payload too large" /var/log/nodejs/application.log

# CORS errors
grep -i "cors\|cross-origin" /var/log/nodejs/application.log

# Rate limiting hits
grep -i "rate limit\|too many requests" /var/log/nodejs/application.log
```

### Information Disclosure Patterns

```bash
# Environment variables
grep -oE "[A-Z_]+=\S+" /var/log/nodejs/application.log

# API keys and secrets
grep -iE "api[_-]?key|secret|token|password|credential" /var/log/nodejs/application.log

# Database connection strings
grep -iE "mongodb://|postgres://|mysql://|redis://" /var/log/nodejs/application.log

# Internal paths
grep -oE "/home/[^ ]+|/var/[^ ]+|C:\\\\[^ ]+" /var/log/nodejs/application.log

# Port and IP disclosure
grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+" /var/log/nodejs/application.log
```

### Unhandled Exceptions and Promise Rejections

```bash
# Unhandled promise rejections
grep -i "UnhandledPromiseRejectionWarning\|unhandledRejection" /var/log/nodejs/application.log

# Uncaught exceptions
grep -i "uncaughtException" /var/log/nodejs/application.log

# Extract full exception details
awk '/UnhandledPromiseRejectionWarning/,/^$/' /var/log/nodejs/application.log
```

### Performance and Resource Issues

```bash
# Memory leaks or out of memory
grep -i "heap\|memory\|FATAL ERROR" /var/log/nodejs/application.log

# Event loop lag
grep -i "event loop\|timeout\|ETIMEDOUT" /var/log/nodejs/application.log

# Connection pool exhaustion
grep -i "ECONNREFUSED\|ETIMEDOUT\|pool" /var/log/nodejs/application.log
```

### Automated Analysis Script

```bash
#!/bin/bash
# Node.js log analyzer for CTF

LOGFILE="${1:-/var/log/nodejs/application.log}"

echo "[+] Error Summary:"
echo "  Total errors: $(grep -ci error "$LOGFILE")"
echo "  Unhandled rejections: $(grep -c "UnhandledPromiseRejectionWarning" "$LOGFILE")"
echo "  Uncaught exceptions: $(grep -c "uncaughtException" "$LOGFILE")"

echo -e "\n[+] Recent Critical Errors:"
grep -i "error\|exception" "$LOGFILE" | tail -10

echo -e "\n[+] Potential Command Injection:"
grep -iE "child_process|exec|spawn" "$LOGFILE" | wc -l
echo "  child_process usage detected"

echo -e "\n[+] Path Traversal Indicators:"
grep -E "EACCES|ENOENT" "$LOGFILE" | wc -l
echo "  file access errors found"

echo -e "\n[+] Authentication Issues:"
grep -iE "401|403|unauthorized|authentication failed" "$LOGFILE" | tail -5

echo -e "\n[+] Disclosed Information:"
grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" "$LOGFILE" | sort -u | head -10
echo "  (Internal IP addresses)"
```

### Log Correlation Across Application Types

When analyzing multiple application logs simultaneously:

```bash
# Correlate by timestamp
grep "2025-10-28 14:30" /var/log/*/application.log

# Find related errors across PHP, Python, Node
for log in /var/log/{apache2/error.log,python/app.log,nodejs/app.log}; do
  echo "=== $log ==="
  grep -i "database error" "$log" | tail -3
done

# Extract IP addresses from all logs
grep -hroE '([0-9]{1,3}\.){3}[0-9]{1,3}' /var/log/ | sort | uniq -c | sort -rn
```

---

**Important subtopics for deeper CTF log analysis:**

- Web server access logs (Apache, Nginx) - reveals request patterns, attack vectors, and response codes
- Authentication logs (auth.log, secure) - tracks login attempts, privilege escalation, and account compromises
- Database logs (MySQL, PostgreSQL, MongoDB) - exposes query patterns, slow queries, and injection attempts
- System logs (syslog, dmesg, kernel logs) - contains kernel-level events, service starts/stops, and security events

---

## Java Application Logs

Java applications use various logging frameworks including Log4j, Logback, SLF4J, and java.util.logging (JUL). Log format, location, and verbosity depend on framework configuration and application server deployment.

### Log Location Patterns

**Application Server Locations:**

- **Tomcat**: `/var/log/tomcat9/catalina.out`, `/opt/tomcat/logs/`
- **JBoss/WildFly**: `/var/log/jboss/server.log`, `$JBOSS_HOME/standalone/log/`
- **WebLogic**: `$DOMAIN_HOME/servers/AdminServer/logs/`
- **WebSphere**: `/opt/IBM/WebSphere/AppServer/profiles/*/logs/`
- **Spring Boot**: Application directory or configured path, often `./logs/application.log`
- **Standalone JAR**: Working directory or specified in configuration

**Framework-specific configurations:**

- **Log4j**: `log4j.properties` or `log4j2.xml` defines `log4j.appender.file.File`
- **Logback**: `logback.xml` defines `<file>` elements
- **JUL**: `logging.properties` specifies handlers

**Common paths:**

```bash
/var/log/java/application.log
/opt/app/logs/application.log
/home/user/app/logs/app.log
~/logs/application.log
./logs/spring.log
```

### Java Logging Levels

Standard hierarchy (most frameworks):

```
FATAL/SEVERE - Critical errors causing application failure
ERROR - Serious errors, operation failed
WARN/WARNING - Unexpected situations, potential issues
INFO - Informational messages, normal operations
DEBUG - Detailed diagnostic information
TRACE - Very detailed diagnostic information
```

### Log Analysis Commands

**Basic inspection:**

```bash
# View real-time logs
tail -f /var/log/tomcat9/catalina.out

# Filter by log level
grep "ERROR" /var/log/java/application.log
grep "FATAL" /var/log/java/application.log
grep "Exception" /var/log/java/application.log

# Find stack traces
grep -A 30 "Exception:" /var/log/java/application.log

# Specific exception types
grep -E "NullPointerException|SQLException|IOException|ClassCastException" /var/log/java/application.log
```

**Exception analysis:**

```bash
# Extract complete stack traces
awk '/Exception:|Error:/{flag=1} flag{print; if(/^[[:space:]]*at/) next; else flag=0}' /var/log/java/application.log

# Find exception causes
grep -B 2 "Caused by:" /var/log/java/application.log

# Count exception types
grep -oE "[a-zA-Z.]+Exception|[a-zA-Z.]+Error" /var/log/java/application.log | sort | uniq -c | sort -rn

# Extract class names from stack traces
grep -oE "at [a-zA-Z0-9.$_]+\(" /var/log/java/application.log | cut -d'(' -f1 | cut -d' ' -f2 | sort -u
```

**Tomcat-specific analysis:**

```bash
# Servlet errors
grep "servlet" /var/log/tomcat9/catalina.out

# JSP compilation errors
grep "org.apache.jasper" /var/log/tomcat9/catalina.out

# Context initialization errors
grep "Context initialization" /var/log/tomcat9/catalina.out

# Memory issues
grep -i "OutOfMemoryError\|heap\|memory" /var/log/tomcat9/catalina.out
```

**Spring Framework logs:**

```bash
# Spring context errors
grep "org.springframework" /var/log/java/application.log

# Bean creation failures
grep "BeanCreationException\|BeanInitializationException" /var/log/java/application.log

# Database connection issues
grep "DataSource\|JdbcTemplate\|HikariPool" /var/log/java/application.log

# Security/authentication
grep "org.springframework.security" /var/log/java/application.log
```

### CTF-Specific Exploitation Patterns

**Deserialization Vulnerabilities:**

```bash
# Java deserialization errors (potential RCE)
grep -i "ObjectInputStream\|readObject\|deserialize" /var/log/java/application.log

# Commons Collections exploitation indicators
grep "org.apache.commons.collections" /var/log/java/application.log

# Serialization-related exceptions
grep "InvalidClassException\|StreamCorruptedException\|NotSerializableException" /var/log/java/application.log

# Specific gadget chain indicators
grep -E "InvokerTransformer|ChainedTransformer|TemplatesImpl" /var/log/java/application.log
```

**SQL Injection (JDBC):**

```bash
# SQL syntax errors
grep -i "SQLException\|SQL syntax\|SQLSyntaxErrorException" /var/log/java/application.log

# Database error messages
grep -E "ORA-[0-9]+|MySQL|PostgreSQL|MSSQL" /var/log/java/application.log

# PreparedStatement errors
grep "PreparedStatement\|Statement" /var/log/java/application.log

# Exposed SQL queries
grep -iE "SELECT|INSERT|UPDATE|DELETE" /var/log/java/application.log | grep -i error
```

**XML External Entity (XXE):**

```bash
# XML parsing errors
grep -i "SAXParseException\|XMLStreamException\|ParserConfigurationException" /var/log/java/application.log

# External entity indicators
grep -i "DOCTYPE\|ENTITY" /var/log/java/application.log

# Specific parsers
grep -E "DocumentBuilder|SAXParser|XMLReader|Unmarshaller" /var/log/java/application.log
```

**Server-Side Request Forgery (SSRF):**

```bash
# URL connection errors
grep -i "URLConnection\|HttpURLConnection\|URL\|URI" /var/log/java/application.log

# Connection refused/timeout (internal scanning attempts)
grep -i "ConnectException\|SocketTimeoutException\|UnknownHostException" /var/log/java/application.log

# Internal IP access attempts
grep -oE "10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[0-1])\.[0-9]{1,3}\.[0-9]{1,3}" /var/log/java/application.log
```

**Path Traversal:**

```bash
# File operation errors
grep -i "FileNotFoundException\|IOException\|AccessDeniedException" /var/log/java/application.log

# Path traversal patterns
grep -E "\.\./|\.\.\\\\|%2e%2e" /var/log/java/application.log

# File operation methods
grep -E "FileInputStream|FileOutputStream|File\(|Files\." /var/log/java/application.log
```

**Expression Language (EL) Injection:**

```bash
# EL evaluation errors
grep -i "ELException\|ExpressionFactory" /var/log/java/application.log

# JSP EL errors
grep "javax.el" /var/log/java/application.log

# OGNL injection (Struts)
grep -i "ognl\|struts" /var/log/java/application.log
```

**Log4j/Log4Shell (CVE-2021-44228):**

```bash
# JNDI lookup attempts
grep -i "jndi:ldap\|jndi:rmi\|jndi:dns" /var/log/java/application.log

# Log4j error messages
grep "log4j" /var/log/java/application.log

# LDAP connection attempts
grep -i "ldap://\|ldaps://" /var/log/java/application.log

# Suspicious patterns in logs
grep -E "\$\{jndi:|\$\{.*:/" /var/log/java/application.log
```

### Information Disclosure Patterns

```bash
# Database credentials
grep -iE "jdbc:|username|password|connection string" /var/log/java/application.log

# API keys and secrets
grep -iE "api[_-]?key|secret|token|bearer" /var/log/java/application.log

# File system paths
grep -oE "/[a-zA-Z0-9/_.-]+\.java|/[a-zA-Z0-9/_.-]+\.class" /var/log/java/application.log | sort -u

# Environment variables
grep -oE "[A-Z_]+=[^ ]+" /var/log/java/application.log

# Internal hostnames and ports
grep -oE "[a-z0-9.-]+:[0-9]+" /var/log/java/application.log | sort -u

# Class and package structure
grep -oE "at [a-z.]+\.[A-Z][a-zA-Z0-9.]+\(" /var/log/java/application.log | sed 's/at //' | sed 's/\..*//' | sort -u
```

### Spring Boot Specific Analysis

**Actuator endpoint exposure:**

```bash
# Actuator access
grep "/actuator" /var/log/java/application.log

# Health check endpoints
grep -E "/health|/info|/metrics|/env" /var/log/java/application.log

# Management endpoints
grep "management.endpoints" /var/log/java/application.log
```

**Configuration issues:**

```bash
# Property resolution errors
grep "PropertySourcesPlaceholderConfigurer\|@Value" /var/log/java/application.log

# Profile activation
grep -i "active profile" /var/log/java/application.log

# Autowiring failures
grep "NoSuchBeanDefinitionException\|UnsatisfiedDependencyException" /var/log/java/application.log
```

### Memory and Performance Issues

```bash
# Out of memory errors
grep -i "OutOfMemoryError\|Java heap space\|PermGen\|Metaspace" /var/log/java/application.log

# Garbage collection logs
grep "GC\|Full GC" /var/log/java/application.log

# Thread dumps
grep "Full thread dump" /var/log/java/application.log

# Deadlocks
grep -i "deadlock" /var/log/java/application.log
```

### Automated Analysis Script

```bash
#!/bin/bash
# Java application log analyzer for CTF

LOGFILE="${1:-/var/log/java/application.log}"

echo "[+] Exception Summary:"
echo "  Total exceptions: $(grep -c "Exception" "$LOGFILE")"
echo "  NullPointerException: $(grep -c "NullPointerException" "$LOGFILE")"
echo "  SQLException: $(grep -c "SQLException" "$LOGFILE")"

echo -e "\n[+] Top 10 Exception Types:"
grep -oE "[a-zA-Z.]+Exception" "$LOGFILE" | sort | uniq -c | sort -rn | head -10

echo -e "\n[+] Deserialization Indicators:"
DESER_COUNT=$(grep -ic "readObject\|deserialize\|ObjectInputStream" "$LOGFILE")
echo "  Potential deserialization usage: $DESER_COUNT occurrences"

echo -e "\n[+] XXE Vulnerability Indicators:"
XXE_COUNT=$(grep -ic "SAXParseException\|ENTITY\|DOCTYPE" "$LOGFILE")
echo "  XML parsing errors: $XXE_COUNT occurrences"

echo -e "\n[+] SSRF Indicators:"
SSRF_COUNT=$(grep -ic "UnknownHostException\|ConnectException" "$LOGFILE")
echo "  Connection errors: $SSRF_COUNT occurrences"

echo -e "\n[+] Log4Shell Indicators:"
grep -i "jndi:" "$LOGFILE" | head -5

echo -e "\n[+] Disclosed File Paths:"
grep -oE "/[a-zA-Z0-9/_.-]+\.java" "$LOGFILE" | sort -u | head -10

echo -e "\n[+] Database Connection Strings:"
grep -i "jdbc:" "$LOGFILE" | head -3

echo -e "\n[+] Recent Critical Errors:"
grep -E "ERROR|FATAL" "$LOGFILE" | tail -10
```

### Log4j Configuration Analysis

**Locate Log4j configuration:**

```bash
# Find Log4j config files
find / -name "log4j.properties" 2>/dev/null
find / -name "log4j2.xml" 2>/dev/null
find / -name "log4j.xml" 2>/dev/null

# Check classpath locations
find /opt -name "log4j*.jar" 2>/dev/null
find /usr/share -name "log4j*.jar" 2>/dev/null

# Inside running JAR
jar tf application.jar | grep log4j
```

**Analyze configuration:**

```bash
# View Log4j configuration
cat /path/to/log4j.properties

# Find log file locations
grep "log4j.appender.*File" /path/to/log4j.properties

# Check logging levels
grep "log4j.rootLogger" /path/to/log4j.properties
grep "log4j.logger" /path/to/log4j.properties
```

### Java Web Application Frameworks

**Struts2 exploitation indicators:**

```bash
# OGNL injection attempts
grep -i "ognl\|struts2" /var/log/java/application.log

# Struts2 exceptions
grep "com.opensymphony.xwork2\|org.apache.struts2" /var/log/java/application.log

# Action errors
grep "ActionSupport\|ActionContext" /var/log/java/application.log
```

**JSF (JavaServer Faces):**

```bash
# JSF lifecycle errors
grep "javax.faces" /var/log/java/application.log

# ViewState manipulation
grep -i "viewstate\|ViewExpiredException" /var/log/java/application.log
```

## Database Query Logs

Database query logs record executed queries, errors, slow queries, and connection events. These logs are critical for identifying SQL injection, privilege escalation, and data exfiltration attempts in CTF scenarios.

### MySQL/MariaDB Query Logs

**Log Types:**

- **General Query Log**: All client connections and queries
- **Error Log**: Server startup/shutdown, errors, warnings
- **Slow Query Log**: Queries exceeding `long_query_time`
- **Binary Log**: Data modification events (replication/recovery)

**Default locations (Linux):**

```bash
/var/log/mysql/error.log
/var/log/mysql/mysql.log
/var/log/mysql/mysql-slow.log
/var/lib/mysql/hostname.err
/var/lib/mysql/hostname.log
```

**Enable query logging:**

```sql
-- Check current settings
SHOW VARIABLES LIKE 'general_log%';
SHOW VARIABLES LIKE 'slow_query_log%';

-- Enable general query log
SET GLOBAL general_log = 'ON';
SET GLOBAL general_log_file = '/var/log/mysql/query.log';

-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';
```

**Configuration file settings (`/etc/mysql/my.cnf`):**

```ini
[mysqld]
general_log = 1
general_log_file = /var/log/mysql/query.log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
log_queries_not_using_indexes = 1
```

**Query log analysis:**

```bash
# View recent queries
tail -f /var/log/mysql/query.log

# Find queries from specific IP/user
grep "Connect.*192.168.1.100" /var/log/mysql/query.log
grep "user@host: admin" /var/log/mysql/query.log

# Search for specific query patterns
grep -i "SELECT" /var/log/mysql/query.log
grep -i "INSERT\|UPDATE\|DELETE" /var/log/mysql/query.log
grep -i "DROP\|ALTER\|CREATE" /var/log/mysql/query.log

# Find authentication attempts
grep "Connect\|Quit" /var/log/mysql/query.log

# Access denied errors
grep "Access denied" /var/log/mysql/error.log
```

**SQL Injection detection patterns:**

```bash
# Union-based injection
grep -i "UNION.*SELECT" /var/log/mysql/query.log

# Boolean-based blind injection
grep -E "AND.*=|OR.*=|AND.*1=1|OR.*1=1" /var/log/mysql/query.log

# Time-based blind injection
grep -i "SLEEP\|BENCHMARK\|WAIT FOR DELAY" /var/log/mysql/query.log

# Error-based injection
grep -i "EXTRACTVALUE\|UPDATEXML\|EXP\(" /var/log/mysql/query.log

# Stacked queries
grep ";" /var/log/mysql/query.log | grep -v "^--"

# Information schema queries
grep -i "information_schema" /var/log/mysql/query.log

# Comment-based injection
grep -E "/\*|--|\#" /var/log/mysql/query.log
```

**Data exfiltration indicators:**

```bash
# Large result sets
grep -i "SELECT.*FROM" /var/log/mysql/query.log | grep -v "LIMIT"

# INTO OUTFILE usage
grep -i "INTO OUTFILE\|INTO DUMPFILE" /var/log/mysql/query.log

# LOAD_FILE attempts
grep -i "LOAD_FILE" /var/log/mysql/query.log

# Bulk data access
grep -i "SELECT \*" /var/log/mysql/query.log
```

**Privilege escalation indicators:**

```bash
# User manipulation
grep -i "CREATE USER\|DROP USER\|GRANT\|REVOKE" /var/log/mysql/query.log

# Password changes
grep -i "SET PASSWORD\|ALTER USER.*PASSWORD" /var/log/mysql/query.log

# File privilege operations
grep -i "FILE_PRIV\|SUPER_PRIV" /var/log/mysql/query.log
```

### PostgreSQL Query Logs

**Log location:**

```bash
/var/log/postgresql/postgresql-15-main.log
/var/lib/pgsql/data/log/postgresql-*.log
```

**Enable logging (`/etc/postgresql/*/main/postgresql.conf`):**

```ini
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_statement = 'all'           # none, ddl, mod, all
log_duration = on
log_connections = on
log_disconnections = on
log_hostname = on
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
```

**Query log analysis:**

```bash
# View recent logs
tail -f /var/log/postgresql/postgresql-15-main.log

# Find specific user queries
grep "user=admin" /var/log/postgresql/postgresql-15-main.log

# Connection attempts
grep "connection authorized\|connection received" /var/log/postgresql/postgresql-15-main.log

# Failed authentication
grep "authentication failed\|password authentication failed" /var/log/postgresql/postgresql-15-main.log

# Query execution times
grep "duration:" /var/log/postgresql/postgresql-15-main.log | awk '{print $NF}' | sort -n
```

**SQL Injection patterns:**

```bash
# Union-based
grep -i "UNION.*SELECT" /var/log/postgresql/postgresql-15-main.log

# Boolean-based
grep -E "AND.*=.*|OR.*=.*" /var/log/postgresql/postgresql-15-main.log

# Time-based (pg_sleep)
grep -i "pg_sleep" /var/log/postgresql/postgresql-15-main.log

# Error-based
grep -i "ERROR:.*syntax error" /var/log/postgresql/postgresql-15-main.log

# Stacked queries
grep ";.*SELECT\|;.*UPDATE\|;.*DELETE" /var/log/postgresql/postgresql-15-main.log

# Information schema enumeration
grep -i "information_schema\|pg_catalog" /var/log/postgresql/postgresql-15-main.log
```

**PostgreSQL-specific exploitation:**

```bash
# COPY command (file read/write)
grep -i "COPY.*FROM\|COPY.*TO" /var/log/postgresql/postgresql-15-main.log

# Large objects (lo_import/lo_export)
grep -i "lo_import\|lo_export\|lo_create" /var/log/postgresql/postgresql-15-main.log

# Function execution
grep -i "CREATE FUNCTION\|CREATE LANGUAGE" /var/log/postgresql/postgresql-15-main.log

# Extension usage
grep -i "CREATE EXTENSION\|pg_execute_server_program" /var/log/postgresql/postgresql-15-main.log
```

### MongoDB Query Logs

**Log location:**

```bash
/var/log/mongodb/mongod.log
/var/log/mongodb/mongodb.log
```

**Enable profiling and logging:**

```javascript
// Connect to MongoDB
mongosh

// Enable profiling (0=off, 1=slow, 2=all)
db.setProfilingLevel(2);

// Check profiling status
db.getProfilingStatus();

// View profiled queries
db.system.profile.find().pretty();
```

**Configuration (`/etc/mongod.conf`):**

```yaml
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
  verbosity: 1

operationProfiling:
  mode: all
```

**Query log analysis:**

```bash
# View recent logs
tail -f /var/log/mongodb/mongod.log

# Find slow queries
grep -i "Slow query" /var/log/mongodb/mongod.log

# Connection events
grep -i "connection.*accepted\|connection.*ended" /var/log/mongodb/mongod.log

# Authentication failures
grep -i "authentication failed\|SCRAM-SHA" /var/log/mongodb/mongod.log

# Command execution
grep '"command"' /var/log/mongodb/mongod.log
```

**NoSQL Injection patterns:**

```bash
# JavaScript injection in $where
grep '\$where' /var/log/mongodb/mongod.log

# Operator injection
grep -E '\$ne|\$gt|\$lt|\$gte|\$lte|\$regex|\$in' /var/log/mongodb/mongod.log

# eval() usage
grep 'eval(' /var/log/mongodb/mongod.log

# mapReduce injection
grep 'mapReduce' /var/log/mongodb/mongod.log
```

**Extract queries from profiler:**

```javascript
// View all profiled operations
db.system.profile.find({}).pretty();

// Find slow queries
db.system.profile.find({ millis: { $gt: 100 } }).pretty();

// Find queries by collection
db.system.profile.find({ ns: "database.collection" }).pretty();

// Find queries by user
db.system.profile.find({ user: "admin@admin" }).pretty();

// Extract command patterns
db.system.profile.find().forEach(function(doc) {
    printjson(doc.command);
});
```

### MSSQL Query Logs

**Log location:**

```
C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Log\ERRORLOG
```

**Enable auditing (T-SQL):**

```sql
-- Create server audit
USE master;
CREATE SERVER AUDIT CTF_Audit
TO FILE (FILEPATH = 'C:\SQLAudit\');

-- Create audit specification
CREATE SERVER AUDIT SPECIFICATION CTF_Audit_Spec
FOR SERVER AUDIT CTF_Audit
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (FAILED_LOGIN_GROUP),
ADD (BATCH_COMPLETED_GROUP);

-- Enable audit
ALTER SERVER AUDIT CTF_Audit WITH (STATE = ON);
ALTER SERVER AUDIT SPECIFICATION CTF_Audit_Spec WITH (STATE = ON);
```

**Query error log:**

```sql
-- Read error log
EXEC xp_readerrorlog;

-- Search for specific text
EXEC xp_readerrorlog 0, 1, 'Login failed';

-- Search in archive logs
EXEC xp_readerrorlog 1, 1, 'error';
```

**Command-line analysis (PowerShell):**

```powershell
# View error log
Get-Content "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Log\ERRORLOG"

# Find login failures
Select-String -Path "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Log\ERRORLOG" -Pattern "Login failed"

# Search for specific patterns
Select-String -Path "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Log\ERRORLOG" -Pattern "xp_cmdshell|sp_configure"
```

**SQL Injection patterns:**

```powershell
# xp_cmdshell usage
Select-String -Path "ERRORLOG" -Pattern "xp_cmdshell"

# Dynamic SQL
Select-String -Path "ERRORLOG" -Pattern "EXEC.*sp_executesql"

# UNION injection
Select-String -Path "ERRORLOG" -Pattern "UNION.*SELECT"

# Error-based injection
Select-String -Path "ERRORLOG" -Pattern "conversion failed|cast.*error"
```

### SQLite Query Logs

[Inference] SQLite does not have built-in query logging. Query activity must be logged at the application level or through wrapper libraries. Standard SQLite databases write to disk but do not maintain separate query logs like client-server databases.

**Application-level logging approaches:**

- Use Python's `sqlite3` module with custom logging
- Implement query logging in application code
- Use SQLite extensions or triggers for audit trails

### Generic Database Log Analysis

**Automated multi-database log analyzer:**

```bash
#!/bin/bash
# Database log analyzer for CTF

echo "=== Database Log Analysis ==="

# MySQL
if [ -f /var/log/mysql/query.log ]; then
    echo -e "\n[+] MySQL Query Log Analysis:"
    echo "  Total queries: $(wc -l < /var/log/mysql/query.log)"
    echo "  UNION attacks: $(grep -ci "UNION.*SELECT" /var/log/mysql/query.log)"
    echo "  SLEEP usage: $(grep -ci "SLEEP\|BENCHMARK" /var/log/mysql/query.log)"
    echo "  File operations: $(grep -ci "INTO OUTFILE\|LOAD_FILE" /var/log/mysql/query.log)"
fi

# PostgreSQL
if [ -f /var/log/postgresql/postgresql-15-main.log ]; then
    echo -e "\n[+] PostgreSQL Log Analysis:"
    echo "  Total queries: $(grep -c "LOG:.*statement:" /var/log/postgresql/postgresql-15-main.log)"
    echo "  Failed auth: $(grep -c "authentication failed" /var/log/postgresql/postgresql-15-main.log)"
    echo "  COPY commands: $(grep -ci "COPY.*FROM\|COPY.*TO" /var/log/postgresql/postgresql-15-main.log)"
fi

# MongoDB
if [ -f /var/log/mongodb/mongod.log ]; then
    echo -e "\n[+] MongoDB Log Analysis:"
    echo "  Total connections: $(grep -c "connection.*accepted" /var/log/mongodb/mongod.log)"
    echo "  Operator injection: $(grep -cE '\$where|\$ne|\$gt' /var/log/mongodb/mongod.log)"
fi
```

**SQL Injection signature detection:**

```bash
#!/bin/bash
# SQL injection pattern detector

LOGFILE="$1"

echo "[+] SQL Injection Pattern Detection"

patterns=(
    "UNION.*SELECT:Union-based"
    "AND.*1=1|OR.*1=1:Boolean-based"
    "SLEEP\(|BENCHMARK\(:Time-based"
    "EXTRACTVALUE|UPDATEXML:Error-based"
    "INTO OUTFILE|LOAD_FILE:File operations"
    "information_schema:Schema enumeration"
    ";.*SELECT|;.*INSERT:Stacked queries"
    "--.*$|\#.*$|/\*:Comment injection"
)

for pattern in "${patterns[@]}"; do
    IFS=':' read -r regex desc <<< "$pattern"
    count=$(grep -ciE "$regex" "$LOGFILE" 2>/dev/null || echo "0")
    if [ "$count" -gt 0 ]; then
        echo "  [!] $desc: $count occurrences"
    fi
done
```

## Custom Application Logging

Custom application logging refers to application-specific log implementations beyond standard frameworks. These logs often contain business logic events, custom error handling, and application-specific security events valuable in CTF scenarios.

### Custom Log Formats

**Common custom formats:**

- **CSV**: Comma-separated values for structured data
- **JSON**: Structured logging with nested objects
- **Key-Value**: Simple key=value pairs
- **Fixed-width**: Column-based format
- **Syslog**: RFC 5424 or RFC 3164 format
- **Custom delimited**: Tab, pipe, or custom separators

**Examples of custom formats:**

```
# CSV format
timestamp,level,user,action,result,message
2025-10-28 14:30:15,INFO,admin,login,success,"User logged in from 192.168.1.100"

# JSON format
{"timestamp":"2025-10-28T14:30:15Z","level":"INFO","user":"admin","action":"login","ip":"192.168.1.100"}

# Key-value format
time=2025-10-28T14:30:15 level=INFO user=admin action=login ip=192.168.1.100

# Custom delimited
2025-10-28 14:30:15|INFO|admin|login|192.168.1.100|success
```

### Identifying Custom Log Locations

**Common discovery methods:**

```bash
# Search for log files by name patterns
find /var/log -type f -name "*.log" 2>/dev/null
find /opt -type f -name "*.log" 2>/dev/null
find /home -type f -name "*.log" 2>/dev/null

# Find recently modified log files
find /var/log -type f -mmin -60 2>/dev/null

# Search for files containing log-like content
grep -r "ERROR\|WARNING\|INFO" /var/log 2>/dev/null | cut -d: -f1 | sort -u

# Look for custom log directories
ls -la /var/log/*/
ls -la /opt/*/logs/

# Check running processes for open log files
lsof | grep -i "\.log"

# Process-specific log file discovery
lsof -p $(pgrep -f "application_name") | grep -E "\.log|\.txt"
```

**Configuration file analysis:**

```bash
# Find application config files
find / -name "config.ini" -o -name "settings.conf" -o -name ".env" 2>/dev/null

# Search configs for log paths
grep -r "log.*path\|log.*file\|log.*dir" /etc/ 2>/dev/null
grep -r "LOG_FILE\|LOG_PATH" /opt/ 2>/dev/null

# Check environment variables
env | grep -i log
```

### Analyzing CSV Format Logs

**Basic analysis:**

```bash
# View log structure
head -1 /var/log/custom/application.csv
head -10 /var/log/custom/application.csv

# Count total entries
wc -l /var/log/custom/application.csv

# Extract specific columns (column 4 = action)
awk -F',' '{print $4}' /var/log/custom/application.csv | sort -u

# Filter by specific field value
awk -F',' '$4 == "login"' /var/log/custom/application.csv

# Find entries with specific level
grep ",ERROR," /var/log/custom/application.csv grep ",CRITICAL," /var/log/custom/application.csv
````

**Advanced CSV analysis:**
```bash
# Count actions by type
awk -F',' '{print $4}' /var/log/custom/application.csv | sort | uniq -c | sort -rn

# Find failed operations
awk -F',' '$5 == "failed" || $5 == "error"' /var/log/custom/application.csv

# Extract entries for specific user
awk -F',' '$3 == "admin"' /var/log/custom/application.csv

# Time-based filtering (assuming timestamp in column 1)
awk -F',' '$1 >= "2025-10-28 14:00:00" && $1 <= "2025-10-28 15:00:00"' /var/log/custom/application.csv

# Find anomalies (e.g., multiple failed logins)
awk -F',' '$4 == "login" && $5 == "failed" {print $3}' /var/log/custom/application.csv | sort | uniq -c | sort -rn
````

**Using csvkit for advanced analysis:**

```bash
# Install csvkit (if available)
pip install csvkit

# View CSV structure
csvstat /var/log/custom/application.csv

# Query CSV like SQL
csvsql --query "SELECT user, COUNT(*) FROM application WHERE action='login' GROUP BY user" /var/log/custom/application.csv

# Convert to JSON
csvjson /var/log/custom/application.csv

# Filter rows
csvgrep -c action -m "login" /var/log/custom/application.csv
```

### Analyzing JSON Format Logs

**Basic JSON log analysis:**

```bash
# Pretty print JSON logs
cat /var/log/custom/application.json | jq '.'

# Extract all log levels
cat /var/log/custom/application.json | jq -r '.level'

# Filter by log level
cat /var/log/custom/application.json | jq 'select(.level == "ERROR")'

# Extract specific fields
cat /var/log/custom/application.json | jq -r '.timestamp, .user, .action'

# Count entries by action
cat /var/log/custom/application.json | jq -r '.action' | sort | uniq -c | sort -rn
```

**Advanced JSON analysis:**

```bash
# Filter by multiple conditions
cat /var/log/custom/application.json | jq 'select(.level == "ERROR" and .user == "admin")'

# Extract nested fields
cat /var/log/custom/application.json | jq -r '.metadata.ip_address'

# Find entries within time range
cat /var/log/custom/application.json | jq 'select(.timestamp >= "2025-10-28T14:00:00" and .timestamp <= "2025-10-28T15:00:00")'

# Group and count
cat /var/log/custom/application.json | jq -r '.action' | sort | uniq -c

# Search for specific patterns in messages
cat /var/log/custom/application.json | jq 'select(.message | test("password|credential"; "i"))'

# Extract failed operations with details
cat /var/log/custom/application.json | jq 'select(.result == "failed") | {time: .timestamp, user: .user, action: .action, reason: .message}'
```

**JSON log aggregation script:**

```bash
#!/bin/bash
# JSON log analyzer

LOGFILE="$1"

echo "[+] JSON Log Analysis"

echo -e "\n[+] Log Level Distribution:"
jq -r '.level' "$LOGFILE" | sort | uniq -c | sort -rn

echo -e "\n[+] Top 10 Users:"
jq -r '.user // "anonymous"' "$LOGFILE" | sort | uniq -c | sort -rn | head -10

echo -e "\n[+] Top 10 Actions:"
jq -r '.action' "$LOGFILE" | sort | uniq -c | sort -rn | head -10

echo -e "\n[+] Failed Operations:"
jq -r 'select(.result == "failed" or .status == "error") | "\(.timestamp) - \(.user) - \(.action) - \(.message)"' "$LOGFILE" | head -20

echo -e "\n[+] Unique IP Addresses:"
jq -r '.ip // .ip_address // .client_ip' "$LOGFILE" 2>/dev/null | sort -u | wc -l
```

### Analyzing Key-Value Format Logs

**Basic key-value analysis:**

```bash
# View log samples
head -20 /var/log/custom/application.log

# Extract specific key values
grep -oE "user=[^ ]+" /var/log/custom/application.log | cut -d= -f2 | sort -u

# Find entries with specific key-value
grep "action=login" /var/log/custom/application.log

# Extract multiple keys
awk '{for(i=1;i<=NF;i++) if($i~/^(time|user|action)=/) print $i}' /var/log/custom/application.log
```

**Convert key-value to structured format:**

```bash
#!/bin/bash
# Convert key-value logs to CSV

INPUT="$1"
OUTPUT="${2:-converted.csv}"

# Extract unique keys
keys=$(head -100 "$INPUT" | grep -oE "[a-zA-Z_]+=" | sed 's/=$//' | sort -u | tr '\n' ',' | sed 's/,$//')

echo "$keys" > "$OUTPUT"

# Parse and convert each line
while IFS= read -r line; do
    IFS=',' read -ra KEY_ARRAY <<< "$keys"
    row=""
    for key in "${KEY_ARRAY[@]}"; do
        value=$(echo "$line" | grep -oE "$key=[^ ]+" | cut -d= -f2)
        row="$row,$value"
    done
    echo "${row#,}" >> "$OUTPUT"
done < "$INPUT"

echo "[+] Converted to $OUTPUT"
```

**Advanced key-value parsing:**

```bash
# Extract all key-value pairs into associative array (bash 4+)
parse_kv() {
    local line="$1"
    declare -A kv_pairs
    
    for pair in $line; do
        if [[ $pair =~ ^([^=]+)=(.+)$ ]]; then
            kv_pairs["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
        fi
    done
    
    # Access values
    echo "User: ${kv_pairs[user]}, Action: ${kv_pairs[action]}"
}

# Usage
while IFS= read -r line; do
    parse_kv "$line"
done < /var/log/custom/application.log
```

### Custom Log Pattern Analysis

**Common CTF patterns in custom logs:**

```bash
# Authentication events
grep -iE "login|logout|auth|signin|signout" /var/log/custom/application.log

# Failed authentication attempts
grep -iE "failed.*login|auth.*failed|invalid.*password|access.*denied" /var/log/custom/application.log

# Privilege escalation indicators
grep -iE "privilege|permission|role.*change|admin|sudo|su\s" /var/log/custom/application.log

# File access patterns
grep -iE "file.*read|file.*write|download|upload|access.*file" /var/log/custom/application.log

# Database operations
grep -iE "query|database|sql|insert|update|delete|select" /var/log/custom/application.log

# API calls
grep -iE "api.*call|endpoint|request.*to|response.*from" /var/log/custom/application.log

# Suspicious activity
grep -iE "suspicious|anomaly|blocked|rejected|violation" /var/log/custom/application.log

# Error conditions
grep -iE "error|exception|fatal|critical|failure" /var/log/custom/application.log
```

**User behavior analysis:**

```bash
#!/bin/bash
# User activity analyzer for custom logs

LOGFILE="$1"
USER="${2:-all}"

if [ "$USER" = "all" ]; then
    echo "[+] Top 20 Active Users:"
    grep -oE "user[=:][^ ,]+" "$LOGFILE" | cut -d= -f2 | cut -d: -f2 | sort | uniq -c | sort -rn | head -20
else
    echo "[+] Activity for user: $USER"
    grep -E "user[=:]$USER" "$LOGFILE" | wc -l
    echo "  Total actions"
    
    echo -e "\n[+] Actions breakdown:"
    grep -E "user[=:]$USER" "$LOGFILE" | grep -oE "action[=:][^ ,]+" | cut -d= -f2 | cut -d: -f2 | sort | uniq -c | sort -rn
    
    echo -e "\n[+] Failed operations:"
    grep -E "user[=:]$USER" "$LOGFILE" | grep -iE "fail|error|denied" | head -10
    
    echo -e "\n[+] Recent activity:"
    grep -E "user[=:]$USER" "$LOGFILE" | tail -20
fi
```

### Application Security Event Logs

**Common security events in custom logs:**

**Input validation failures:**

```bash
# SQL injection attempts
grep -iE "sql.*injection|union.*select|'; drop|admin'--" /var/log/custom/security.log

# XSS attempts
grep -iE "<script|javascript:|onerror=|onload=" /var/log/custom/security.log

# Path traversal
grep -E "\.\./|\.\.\\\\|%2e%2e" /var/log/custom/security.log

# Command injection
grep -iE ";.*ls|;.*cat|;.*wget|\|.*curl|`.*id`" /var/log/custom/security.log
```

**Rate limiting and abuse:**

```bash
# Identify rate-limited IPs
grep -i "rate.*limit\|too many requests\|429" /var/log/custom/application.log | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort | uniq -c | sort -rn

# Brute force attempts
grep -i "login.*failed\|auth.*failed" /var/log/custom/security.log | grep -oE "user[=:][^ ,]+" | cut -d= -f2 | cut -d: -f2 | sort | uniq -c | sort -rn | head -20

# Multiple failures from same IP
grep -i "failed" /var/log/custom/security.log | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort | uniq -c | sort -rn | head -20
```

**Session and token analysis:**

```bash
# Session hijacking indicators
grep -iE "session.*invalid|session.*expired|token.*invalid" /var/log/custom/security.log

# Multiple sessions from different IPs
awk '/session/ {print $0}' /var/log/custom/security.log | grep -oE "session[=:][^ ,]+" | cut -d= -f2 | cut -d: -f2 | sort | uniq -c | sort -rn

# Token usage patterns
grep -oE "token[=:][^ ,]+" /var/log/custom/application.log | cut -d= -f2 | cut -d: -f2 | sort | uniq -c | sort -rn
```

### Automated Custom Log Analysis Framework

**Generic log analyzer:**

```bash
#!/bin/bash
# Universal custom log analyzer for CTF

LOGFILE="$1"

if [ ! -f "$LOGFILE" ]; then
    echo "Usage: $0 <logfile>"
    exit 1
fi

echo "=== Custom Log Analysis ==="
echo "File: $LOGFILE"
echo "Size: $(du -h "$LOGFILE" | cut -f1)"
echo "Lines: $(wc -l < "$LOGFILE")"

# Detect log format
echo -e "\n[+] Detecting Log Format..."
if head -1 "$LOGFILE" | grep -q "^{"; then
    FORMAT="JSON"
elif head -1 "$LOGFILE" | grep -q ","; then
    FORMAT="CSV"
elif head -1 "$LOGFILE" | grep -qE "[a-zA-Z_]+=[^ ]+"; then
    FORMAT="KEY-VALUE"
else
    FORMAT="UNKNOWN"
fi
echo "  Detected format: $FORMAT"

# Sample entries
echo -e "\n[+] Sample Log Entries:"
head -5 "$LOGFILE"

# Error analysis
echo -e "\n[+] Error/Failure Analysis:"
ERROR_COUNT=$(grep -ciE "error|fail|exception|critical" "$LOGFILE")
echo "  Total errors/failures: $ERROR_COUNT"

if [ $ERROR_COUNT -gt 0 ]; then
    echo -e "\n  Recent errors:"
    grep -iE "error|fail|exception|critical" "$LOGFILE" | tail -10
fi

# Security event detection
echo -e "\n[+] Security Event Detection:"
AUTH_FAIL=$(grep -ciE "auth.*fail|login.*fail|access.*denied" "$LOGFILE")
echo "  Authentication failures: $AUTH_FAIL"

INJECTION=$(grep -ciE "union.*select|<script|\.\.\/|; drop" "$LOGFILE")
echo "  Potential injection attempts: $INJECTION"

# IP address analysis
echo -e "\n[+] IP Address Analysis:"
IPS=$(grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" "$LOGFILE" | sort -u | wc -l)
echo "  Unique IP addresses: $IPS"

if [ $IPS -gt 0 ]; then
    echo -e "\n  Top 10 IPs:"
    grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" "$LOGFILE" | sort | uniq -c | sort -rn | head -10
fi

# Time-based analysis
echo -e "\n[+] Time-Based Analysis:"
if grep -qE "[0-9]{4}-[0-9]{2}-[0-9]{2}" "$LOGFILE"; then
    echo "  First entry: $(grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}" "$LOGFILE" | head -1)"
    echo "  Last entry: $(grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}" "$LOGFILE" | tail -1)"
fi

# User analysis (if user field exists)
echo -e "\n[+] User Analysis:"
if grep -qE "user[=:]" "$LOGFILE"; then
    echo "  Top 10 users:"
    grep -oE "user[=:][^ ,]+" "$LOGFILE" | cut -d= -f2 | cut -d: -f2 | sort | uniq -c | sort -rn | head -10
fi

# Action/Event analysis
echo -e "\n[+] Action/Event Analysis:"
if grep -qE "action[=:]|event[=:]" "$LOGFILE"; then
    echo "  Top 10 actions/events:"
    grep -oE "(action|event)[=:][^ ,]+" "$LOGFILE" | cut -d= -f2 | cut -d: -f2 | sort | uniq -c | sort -rn | head -10
fi

# Anomaly detection
echo -e "\n[+] Potential Anomalies:"

# Unusual user agents
UA_COUNT=$(grep -ciE "user.*agent|useragent" "$LOGFILE")
if [ $UA_COUNT -gt 0 ]; then
    echo "  Unusual user agents detected: $UA_COUNT"
    grep -iE "bot|scanner|nikto|sqlmap|burp|curl|wget|python" "$LOGFILE" | head -5
fi

# Large payloads
LARGE_COUNT=$(grep -E ".{500,}" "$LOGFILE" | wc -l)
echo "  Entries with large payloads (>500 chars): $LARGE_COUNT"

# Rapid requests
echo -e "\n[+] Rapid Request Detection:"
if grep -qE "[0-9]{2}:[0-9]{2}:[0-9]{2}" "$LOGFILE"; then
    echo "  Analyzing request frequency..."
    grep -oE "[0-9]{2}:[0-9]{2}:[0-9]{2}" "$LOGFILE" | cut -d: -f1,2 | sort | uniq -c | sort -rn | head -5
fi

echo -e "\n=== Analysis Complete ==="
```

### Custom Log Correlation

**Cross-log correlation script:**

```bash
#!/bin/bash
# Correlate events across multiple custom logs

APP_LOG="$1"
SECURITY_LOG="$2"
TIMEFRAME="${3:-10}" # minutes

echo "[+] Cross-Log Correlation Analysis"

# Extract suspicious IPs from security log
echo -e "\n[+] Suspicious IPs from security log:"
SUSPICIOUS_IPS=$(grep -iE "blocked|rejected|failed" "$SECURITY_LOG" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort -u)

echo "$SUSPICIOUS_IPS" | head -10

# Find those IPs in application log
echo -e "\n[+] Suspicious IP activity in application log:"
for ip in $SUSPICIOUS_IPS; do
    count=$(grep -c "$ip" "$APP_LOG")
    if [ $count -gt 0 ]; then
        echo "  $ip: $count entries"
        grep "$ip" "$APP_LOG" | head -3
        echo "  ---"
    fi
done

# Time-based correlation
echo -e "\n[+] Time-Correlated Events:"
# Extract timestamps from security events
grep -iE "error|fail|blocked" "$SECURITY_LOG" | grep -oE "[0-9]{2}:[0-9]{2}:[0-9]{2}" | sort -u | while read timestamp; do
    hour=$(echo $timestamp | cut -d: -f1)
    minute=$(echo $timestamp | cut -d: -f2)
    
    # Find related events in app log
    app_events=$(grep "$hour:$minute" "$APP_LOG" | wc -l)
    if [ $app_events -gt 10 ]; then
        echo "  High activity at $timestamp: $app_events events"
    fi
done
```

### Custom Log Visualization Data Extraction

**Extract data for visualization:**

```bash
#!/bin/bash
# Extract time-series data for visualization

LOGFILE="$1"
OUTPUT="${2:-timeseries.csv}"

echo "timestamp,count,level" > "$OUTPUT"

# Extract timestamp and level, then count
grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}.*" "$LOGFILE" | while read line; do
    timestamp=$(echo "$line" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}")
    level=$(echo "$line" | grep -oE "ERROR|WARN|INFO|DEBUG" | head -1)
    echo "$timestamp,1,${level:-UNKNOWN}"
done | awk -F, '{count[$1","$3]++} END {for (key in count) print key","count[key]}' | sort >> "$OUTPUT"

echo "[+] Time-series data exported to $OUTPUT"
```

**Extract user activity for analysis:**

```bash
#!/bin/bash
# Extract user activity matrix

LOGFILE="$1"
OUTPUT="${2:-user_activity.csv}"

echo "user,action,count" > "$OUTPUT"

# Extract user and action pairs
grep -oE "(user|username)[=:][^ ,]+" "$LOGFILE" | cut -d= -f2 | cut -d: -f2 > /tmp/users.txt
grep -oE "action[=:][^ ,]+" "$LOGFILE" | cut -d= -f2 | cut -d: -f2 > /tmp/actions.txt

paste -d, /tmp/users.txt /tmp/actions.txt | sort | uniq -c | awk '{print $2","$1}' >> "$OUTPUT"

rm /tmp/users.txt /tmp/actions.txt

echo "[+] User activity matrix exported to $OUTPUT"
```

### Binary and Encoded Log Analysis

**Handling base64-encoded logs:**

```bash
# Decode base64 log entries
grep -oE "[A-Za-z0-9+/]{20,}={0,2}" /var/log/custom/encoded.log | while read encoded; do
    decoded=$(echo "$encoded" | base64 -d 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "Encoded: $encoded"
        echo "Decoded: $decoded"
        echo "---"
    fi
done

# Search for specific patterns in encoded logs
for line in $(grep -oE "[A-Za-z0-9+/]{20,}={0,2}" /var/log/custom/encoded.log); do
    decoded=$(echo "$line" | base64 -d 2>/dev/null)
    if echo "$decoded" | grep -qi "password\|secret\|key"; then
        echo "Sensitive data found: $decoded"
    fi
done
```

**Hex-encoded log analysis:**

```bash
# Decode hex logs
grep -oE "([0-9a-fA-F]{2} ){10,}" /var/log/custom/hex.log | while read hex; do
    echo "$hex" | xxd -r -p
    echo ""
done

# Search for specific strings in hex logs
echo -n "password" | xxd -p  # Get hex representation
# Then search for that pattern: grep "70617373776f7264" /var/log/custom/hex.log
```

### Log Tampering Detection

**Detect log manipulation:**

```bash
#!/bin/bash
# Detect potential log tampering

LOGFILE="$1"

echo "[+] Log Integrity Analysis"

# Check for time anomalies
echo -e "\n[+] Timestamp Anomalies:"
timestamps=$(grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}" "$LOGFILE" | sort)
prev_ts=""
for ts in $timestamps; do
    if [ -n "$prev_ts" ]; then
        # [Inference] Simple timestamp comparison - may need adjustment based on actual timestamp format
        if [[ "$ts" < "$prev_ts" ]]; then
            echo "  [!] Out-of-order timestamp detected: $ts (after $prev_ts)"
        fi
    fi
    prev_ts="$ts"
done

# Check for gaps in sequential IDs
echo -e "\n[+] Checking for Missing Entries:"
if grep -qE "id[=:]|#[0-9]+" "$LOGFILE"; then
    ids=$(grep -oE "(id[=:]|#)[0-9]+" "$LOGFILE" | grep -oE "[0-9]+" | sort -n)
    prev_id=0
    for id in $ids; do
        if [ $((id - prev_id)) -gt 1 ] && [ $prev_id -ne 0 ]; then
            echo "  [!] Gap detected: missing IDs between $prev_id and $id"
        fi
        prev_id=$id
    done
fi

# Check for suspicious patterns
echo -e "\n[+] Suspicious Patterns:"
DEL_COUNT=$(grep -ciE "delete|remove|clear|truncate" "$LOGFILE")
if [ $DEL_COUNT -gt 0 ]; then
    echo "  [!] Delete/clear operations found: $DEL_COUNT"
    grep -iE "delete|remove|clear|truncate" "$LOGFILE" | head -5
fi

# Check file modification time vs. log timestamps
echo -e "\n[+] File Modification Check:"
FILE_MOD=$(stat -c %y "$LOGFILE" 2>/dev/null || stat -f "%Sm" "$LOGFILE")
LAST_LOG=$(grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}" "$LOGFILE" | tail -1)
echo "  File modified: $FILE_MOD"
echo "  Last log entry: $LAST_LOG"
```

---

**Important related topics for comprehensive CTF log analysis:**

- Log aggregation and SIEM tools (Splunk, ELK Stack, Graylog) - centralized log management and advanced correlation
- Windows Event Logs (Security, Application, System) - Windows-specific log analysis for CTF scenarios
- Network device logs (firewall, IDS/IPS, router) - network-level attack detection and traffic analysis
- Container and orchestration logs (Docker, Kubernetes) - modern application deployment log analysis