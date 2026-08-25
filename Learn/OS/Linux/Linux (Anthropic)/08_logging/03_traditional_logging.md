## Traditional Logging


### rsyslog Configuration

rsyslog is the enhanced version of the traditional syslog daemon, providing advanced logging capabilities including filtering, forwarding, and high-performance processing. It serves as the primary logging system on most Linux distributions.

#### Configuration Architecture

**Main Configuration Files:**

- `/etc/rsyslog.conf`: Primary configuration file
- `/etc/rsyslog.d/*.conf`: Modular configuration files
- `/etc/default/rsyslog` or `/etc/sysconfig/rsyslog`: Service startup options

**Configuration Syntax:** rsyslog supports multiple configuration formats:

- **Legacy format**: Traditional syslog.conf syntax
- **Advanced format**: RainerScript with enhanced features
- **Object-oriented format**: JSON-like configuration blocks

#### Basic Configuration Structure

**Facility and Priority System:** rsyslog uses facility.priority combinations to categorize and filter messages:

**Facilities:**

- `auth`: Authentication/authorization messages
- `authpriv`: Private authentication messages
- `cron`: Cron daemon messages
- `daemon`: System daemon messages
- `kern`: Kernel messages
- `local0-local7`: Custom application facilities
- `mail`: Mail system messages
- `news`: Network news system messages
- `syslog`: Internal syslog messages
- `user`: Generic user-level messages
- `uucp`: UUCP system messages

**Priorities (Severity Levels):**

- `emerg` (0): System unusable
- `alert` (1): Action must be taken immediately
- `crit` (2): Critical conditions
- `err` (3): Error conditions
- `warning` (4): Warning conditions
- `notice` (5): Normal but significant condition
- `info` (6): Informational messages
- `debug` (7): Debug-level messages

#### Configuration Examples

**Basic Logging Rules:**

```bash
# Log all kernel messages to /var/log/kern.log
kern.*                          /var/log/kern.log

# Log authentication messages to secure log
auth,authpriv.*                 /var/log/secure

# Log all messages except mail to messages file
*.info;mail.none;authpriv.none  /var/log/messages

# Emergency messages to all logged-in users
*.emerg                         :omusrmsg:*

# Critical messages to console
*.crit                          /dev/console
```

**Advanced Filtering:**

```bash
# Property-based filtering
:programname, isequal, "sshd"   /var/log/sshd.log

# Expression-based filtering
if $programname == 'httpd' then /var/log/httpd.log

# Stop processing after match
& stop

# Regular expression filtering
:msg, regex, "error.*database"  /var/log/db-errors.log
```

#### Templates and Output Formats

**Template Definition:**

```bash
# Custom timestamp format
$template CustomFormat,"%timegenerated% %HOSTNAME% %syslogtag%%msg%\n"

# JSON output template
$template JsonFormat,"{\"timestamp\":\"%timegenerated:::date-rfc3339%\",\"host\":\"%hostname%\",\"program\":\"%programname%\",\"message\":\"%msg%\"}\n"

# Use template in rule
*.info;mail.none    /var/log/custom.log;CustomFormat
```

**Built-in Templates:**

- `RSYSLOG_DefaultFormat`: Standard syslog format
- `RSYSLOG_TraditionalFormat`: Legacy syslog format
- `RSYSLOG_FileFormat`: File-optimized format
- `RSYSLOG_ForwardFormat`: Network forwarding format

#### Module Configuration

**Loading Modules:**

```bash
# Load input modules
$ModLoad imuxsock    # Unix socket input
$ModLoad imklog      # Kernel logging
$ModLoad imfile      # File input
$ModLoad imudp       # UDP syslog reception
$ModLoad imtcp       # TCP syslog reception

# Load output modules
$ModLoad omfile      # File output
$ModLoad omfwd       # Forwarding output
$ModLoad ommysql     # MySQL database output
```

**UDP Reception Configuration:**

```bash
# Enable UDP syslog reception on port 514
$ModLoad imudp
$UDPServerRun 514
$UDPServerAddress 192.168.1.100
```

**TCP Reception Configuration:**

```bash
# Enable TCP syslog reception
$ModLoad imtcp
$InputTCPServerRun 514
$InputTCPMaxSessions 500
```

### Log Forwarding

Log forwarding enables centralized logging by sending log messages from multiple systems to a central log server, facilitating monitoring and analysis across distributed environments.

#### Forward Configuration Types

**UDP Forwarding:**

```bash
# Forward all messages via UDP
*.*    @logserver.example.com:514

# Forward specific facility via UDP
mail.*  @192.168.1.200:514

# Forward with template
*.*    @logserver.example.com:514;JsonFormat
```

**TCP Forwarding:**

```bash
# Forward all messages via TCP
*.*    @@logserver.example.com:514

# Forward with reliability features
*.*    @@logserver.example.com:514
$ActionQueueType LinkedList
$ActionQueueFileName srvrfwd
$ActionResumeRetryCount -1
$ActionQueueSaveOnShutdown on
```

**RELP (Reliable Event Logging Protocol):**

```bash
# Load RELP module
$ModLoad omrelp

# Configure RELP forwarding
*.*    :omrelp:logserver.example.com:2514
```

#### Advanced Forwarding Options

**Conditional Forwarding:**

```bash
# Forward only error messages
*.err   @@logserver.example.com:514

# Forward based on content
:msg, contains, "CRITICAL"  @@alertserver.example.com:514

# Forward specific programs
:programname, isequal, "httpd"  @@weblogserver.example.com:514
```

**Failover Configuration:**

```bash
# Primary and backup servers
*.*    @@primary-log.example.com:514
& @@backup-log.example.com:514
```

**Queue Configuration for Reliability:**

```bash
# Configure forwarding queue
$ActionQueueType LinkedList
$ActionQueueFileName fwdRule1
$ActionQueueMaxDiskSpace 1g
$ActionQueueSaveOnShutdown on
$ActionQueueTimeoutEnqueue 10
$ActionResumeRetryCount -1
*.*    @@logserver.example.com:514
```

#### Log Server Configuration

**Receiving Server Setup:**

```bash
# Enable network reception
$ModLoad imudp
$UDPServerRun 514
$ModLoad imtcp
$InputTCPServerRun 514

# Separate logs by source host
$template RemoteHost,"/var/log/remote/%HOSTNAME%/%programname%.log"
*.* ?RemoteHost

# Stop local processing of remote messages
& stop
```

### Custom Log Files

Custom log files allow applications and services to maintain separate, organized logging outside the standard system logs.

#### Application-Specific Logging

**Web Server Logging:**

```bash
# Apache logs
local0.*    /var/log/apache2/application.log

# Nginx custom logging
local1.*    /var/log/nginx/custom.log
```

**Database Logging:**

```bash
# MySQL application logs
local2.*    /var/log/mysql/application.log

# PostgreSQL custom logs
local3.*    /var/log/postgresql/custom.log
```

#### File Input Module Configuration

**Monitoring Custom Files:**

```bash
# Load file input module
$ModLoad imfile

# Monitor custom application log
$InputFileName /opt/myapp/logs/application.log
$InputFileTag myapp:
$InputFileStateFile stat-myapp
$InputFileSeverity info
$InputFileFacility local4
$InputRunFileMonitor

# Process monitored file content
local4.*    /var/log/myapp.log
```

**Multiple File Monitoring:**

```bash
# Monitor multiple log files
$InputFileName /var/log/app1/error.log
$InputFileTag app1-error:
$InputFileStateFile stat-app1-error
$InputFileSeverity error
$InputFileFacility local5
$InputRunFileMonitor

$InputFileName /var/log/app2/access.log
$InputFileTag app2-access:
$InputFileStateFile stat-app2-access
$InputFileSeverity info
$InputFileFacility local6
$InputRunFileMonitor
```

#### Log Rotation Integration

**logrotate Configuration:**

```bash
# /etc/logrotate.d/custom-app
/var/log/custom/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    postrotate
        /usr/bin/killall -HUP rsyslogd
    endscript
}
```

**rsyslog Log Rotation Handling:**

```bash
# Signal handling for log rotation
$WorkDirectory /var/spool/rsyslog
$PrivDropToUser syslog
$PrivDropToGroup syslog

# Reopen files on HUP signal
$ResetConfigVariables
```

#### Structured Logging

**JSON Log Format:**

```bash
# JSON template for structured logging
$template JsonFormat,"{\"@timestamp\":\"%timegenerated:::date-rfc3339%\",\"host\":\"%hostname%\",\"severity\":\"%syslogseverity-text%\",\"facility\":\"%syslogfacility-text%\",\"program\":\"%programname%\",\"message\":\"%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\"}\n"

# Apply JSON format to custom logs
local7.*    /var/log/json/application.json;JsonFormat
```

### Log Analysis Tools

Traditional log analysis involves various command-line tools and techniques for examining, filtering, and extracting information from log files.

#### Command-Line Analysis Tools

**Basic File Examination:**

```bash
# View recent log entries
tail -f /var/log/messages
tail -n 100 /var/log/secure

# Search for specific patterns
grep "ERROR" /var/log/application.log
grep -i "failed" /var/log/auth.log

# Multiple file search
grep -r "connection refused" /var/log/

# Case-insensitive search with line numbers
grep -in "warning" /var/log/syslog
```

**Advanced Pattern Matching:**

```bash
# Regular expressions
grep -E "^[A-Z][a-z]{2} [0-9]{2}" /var/log/messages

# Extended regular expressions
egrep "error|ERROR|Error" /var/log/*.log

# Perl-compatible regular expressions
grep -P "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" /var/log/access.log
```

#### Text Processing Tools

**awk for Log Analysis:**

```bash
# Extract specific fields
awk '{print $1, $3, $5}' /var/log/messages

# Process timestamps
awk '/Jan 15/ {print}' /var/log/syslog

# Count occurrences
awk '/ERROR/ {count++} END {print "Errors:", count}' /var/log/app.log

# Calculate statistics
awk '{bytes+=$10} END {print "Total bytes:", bytes}' /var/log/access.log
```

**sed for Log Manipulation:**

```bash
# Remove timestamps
sed 's/^[A-Z][a-z]* [0-9]* [0-9]*:[0-9]*:[0-9]* //' /var/log/messages

# Extract IP addresses
sed -n 's/.*\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/p' /var/log/access.log

# Replace sensitive information
sed 's/password=[^[:space:]]*/password=REDACTED/g' /var/log/app.log
```

#### Specialized Analysis Tools

**Log File Statistics:**

```bash
# Most frequent IP addresses
awk '{print $1}' /var/log/access.log | sort | uniq -c | sort -nr | head -10

# Error frequency by hour
grep ERROR /var/log/app.log | awk '{print $3}' | cut -d: -f1 | sort | uniq -c

# Response code analysis
awk '{print $9}' /var/log/access.log | sort | uniq -c | sort -nr
```

**Time-Based Analysis:**

```bash
# Logs from specific time range
awk '/Jan 15 09:/ && /Jan 15 17:/ {print}' /var/log/messages

# Today's error messages
grep "$(date '+%b %d')" /var/log/syslog | grep -i error

# Last hour's entries
grep "$(date -d '1 hour ago' '+%b %d %H'):" /var/log/messages
```

#### Log Monitoring and Alerting

**Real-Time Monitoring:**

```bash
# Follow multiple logs simultaneously
tail -f /var/log/messages /var/log/secure /var/log/maillog

# Monitor for specific patterns
tail -f /var/log/app.log | grep --line-buffered ERROR

# Colored output for better visibility
tail -f /var/log/syslog | grep --color=always -E "error|warning|critical"
```

**Automated Analysis Scripts:**

```bash
#!/bin/bash
# Log analysis script example
LOGFILE="/var/log/application.log"
ERRORS=$(grep -c ERROR "$LOGFILE")
WARNINGS=$(grep -c WARNING "$LOGFILE")

if [ $ERRORS -gt 10 ]; then
    echo "High error count: $ERRORS" | mail -s "Log Alert" admin@example.com
fi
```

#### Performance Considerations

**Large File Handling:**

- Use `less` or `more` for large file navigation
- Implement log rotation to prevent excessive file sizes
- Use `head` and `tail` with line limits for sampling
- Consider `zcat` or `zgrep` for compressed logs

**Efficient Searching:**

- Create indexes for frequently searched logs [Inference based on database principles]
- Use specific time ranges to limit search scope
- Implement log parsing pipelines for complex analysis
- Consider dedicated log analysis platforms for high-volume environments

**Key points:**

- rsyslog provides flexible configuration through facilities, priorities, and templates
- Log forwarding enables centralized logging architectures
- Custom log files require proper configuration and rotation management
- Traditional command-line tools remain effective for log analysis and troubleshooting

**Conclusion:** Traditional logging with rsyslog offers comprehensive log management capabilities including advanced filtering, forwarding, and custom file handling. Combined with powerful command-line analysis tools, it provides a robust foundation for system monitoring and troubleshooting. Understanding these traditional approaches remains essential even in environments adopting modern logging solutions.

---

