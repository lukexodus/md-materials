## Auditing Tools (auditd, Lynis, chkrootkit)


### System Auditing Overview

**Purpose**: Monitor and analyze system activity for security, compliance, and troubleshooting .

**Tools Available** :
- **auditd**: Kernel audit framework 
- **Lynis**: Security auditing tool 
- **chkrootkit**: Rootkit detection 

**Use Cases** :
- Detect unauthorized access 
- Monitor file changes 
- Compliance reporting 
- Rootkit detection 

### auditd (Audit Framework)

#### Overview

**Kernel Module**: auditd provides kernel-level auditing .

**Capabilities** :
- System call tracking 
- File access monitoring 
- User activity logging 
- Authentication events 

**Installation**: `sudo pacman -S audit` .

#### Enable Service

**Start auditd** :

```bash
sudo systemctl enable --now auditd.service
```

**Verify Running** :

```bash
sudo systemctl status auditd
```

#### Basic Configuration

**Config File**: `/etc/audit/audit.rules` .

**Simple Rule Example** :

```
# Monitor /etc/passwd
-w /etc/passwd -p wa -k passwd_changes

# Monitor /etc/shadow
-w /etc/shadow -p wa -k shadow_changes

# Monitor sudo commands
-a always,exit -F arch=b64 -S execve -F uid!=0 -k sudo_exec
```

**Permanent Rules**: Edit `/etc/audit/rules.d/audit.rules` .

#### Rule Syntax

**Components** :
- `-w`: Watch file 
- `-p`: Permissions (r=read, w=write, x=execute, a=attribute) 
- `-k`: Rule key for identification 
- `-a`: Audit rule 
- `-F`: Filter 

#### Load Rules

**Apply Rules** :

```bash
sudo augenrules --load
```

or

```bash
sudo auditctl -R /etc/audit/rules.d/audit.rules
```

**Verify Loaded** :

```bash
sudo auditctl -l
```

#### View Audit Logs

**Search Logs** :

```bash
sudo ausearch -k passwd_changes
```

**Recent Events** :

```bash
sudo tail -f /var/log/audit/audit.log
```

**Parse Logs** :

```bash
sudo aureport
```

**By Event** :

```bash
sudo aureport -e
```

#### Monitoring Examples

**SSH Login Attempts** :

```
-a always,exit -F arch=b64 -S connect -F a2=22 -k ssh_connect
```

**File Deletion** :

```
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -k file_deletion
```

**Privilege Escalation** :

```
-a always,exit -F arch=b64 -S execve -F uid=0 -F auid!=0 -k priv_escalation
```

#### auditd Limitations

**Performance**: Can impact system performance .

**Storage**: Logs consume disk space .

**Complexity**: Learning curve for rule creation .

### Lynis

#### Overview

**Security Auditing Tool**: Comprehensive system security scanning .

**Capabilities** :
- Security configuration audit 
- Vulnerability detection 
- Compliance checking 
- Security hardening suggestions 

**Installation**: `sudo pacman -S lynis` .

#### Basic Audit

**Run Full Audit** :

```bash
sudo lynis audit system
```

**Output**: Detailed security report .

**Generate Report** :

```bash
sudo lynis audit system --quick
```

#### Audit Options

**Quiet Mode** :

```bash
sudo lynis audit system -q
```

**Verbose Output** :

```bash
sudo lynis audit system -v
```

**Specific Category** :

```bash
sudo lynis audit system --tests HARDENING
```

#### Report Analysis

**Report Location**: `/var/log/lynis-report.dat` .

**Key Sections** :
- **Warnings**: Potential security issues 
- **Suggestions**: Hardening recommendations 
- **Passed**: Security checks passed 

#### Sample Recommendations

**Common Issues** :
- Firewall not enabled 
- Weak password policies 
- Unnecessary services running 
- Outdated software 

#### Automated Audits

**Schedule Audits** :

Create `/etc/systemd/system/lynis-audit.timer`:

```ini
[Unit]
Description=Weekly Lynis Security Audit

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
```

Create `/etc/systemd/system/lynis-audit.service`:

```ini
[Unit]
Description=Lynis Security Audit

[Service]
Type=oneshot
ExecStart=/usr/bin/lynis audit system -q
StandardOutput=journal
```

**Enable** :

```bash
sudo systemctl enable --now lynis-audit.timer
```

### chkrootkit

#### Overview

**Rootkit Detection**: Scans for rootkit indicators .

**Detection Methods** :
- File comparison 
- Signature matching 
- Behavioral analysis 

**Installation**: `sudo pacman -S chkrootkit` .

#### Basic Scan

**Run Scan** :

```bash
sudo chkrootkit
```

**Output**: Comprehensive rootkit check .

#### Scan Options

**Quiet Output** :

```bash
sudo chkrootkit -q
```

**Specific Check** :

```bash
sudo chkrootkit -r /
```

**Report Only** :

```bash
sudo chkrootkit -r / 2>/dev/null | grep INFECTED
```

#### Interpretation

**INFECTED**: Found rootkit indicator .

**SUSPICIOUS**: Unusual pattern detected .

**NOT FOUND**: Check passed .

**WARNING**: Manual verification needed .

#### chkrootkit Tests

**Checks Performed** :
- sniffer: Network sniffing 
- rootdir: Root directory issues 
- sniffer_arp: ARP spoofing 
- processes: Hidden processes 
- files: Rootkit signatures 

#### Scheduled Scanning

**Cron Job** :

```bash
# Add to crontab
0 2 * * * /usr/bin/sudo /usr/bin/chkrootkit -q 2>&1 | mail -s "chkrootkit Report" admin@example.com
```

### rkhunter

#### Installation and Setup

**Install** :

```bash
sudo pacman -S rkhunter
```

**Initialize Database** :

```bash
sudo rkhunter --update
sudo rkhunter --propupd
```

#### Running Scans

**Full Scan** :

```bash
sudo rkhunter --check --skip-warnings
```

**Quick Scan** :

```bash
sudo rkhunter --check --quick
```

**With Report** :

```bash
sudo rkhunter --check --report-warnings-only
```

#### rkhunter Configuration

**Config File**: `/etc/rkhunter.conf` .

**Common Settings** :

```
MAIL-ON-WARNING="root@localhost"
REPORT_WARNINGS_ONLY=1
COPY_LOG_ON_ERROR=1
```

### AIDE (File Integrity Monitoring)

#### Installation

**Install** :

```bash
sudo pacman -S aide
```

#### Initialize Database

**Create Baseline** :

```bash
sudo aide --init
```

**Move Database** :

```bash
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

#### Check Integrity

**Compare Changes** :

```bash
sudo aide --check
```

**Output**: Files that changed .

#### Create New Database

**After Approved Changes** :

```bash
sudo aide --init
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

### Compliance Checking

#### CIS Benchmark

**Purpose**: Center for Internet Security standards .

**Manual Check** :

```bash
sudo lynis audit system --tests COMPLIANCE
```

#### NIST Recommendations

**Security Guidelines** :

Use auditd to monitor NIST controls .

#### Generating Reports

**Audit Report** :

```bash
sudo lynis audit system > audit_report.txt
```

**Include in Compliance** :

Document findings and remediation .

### Log Analysis

#### ausearch

**Search Audit Logs** :

```bash
sudo ausearch -k passwd_changes
```

**By User** :

```bash
sudo ausearch -u username
```

**By Date** :

```bash
sudo ausearch --start today
```

#### aureport

**Summary Report** :

```bash
sudo aureport -h
```

**By User** :

```bash
sudo aureport -u
```

**By File** :

```bash
sudo aureport -f
```

### Automated Alerting

#### Email Alerts

**ausearch with Email** :

```bash
#!/bin/bash
RESULT=$(sudo ausearch -k suspicious -m NOW)
if [ -n "$RESULT" ]; then
    echo "$RESULT" | mail -s "Audit Alert" admin@example.com
fi
```

**Schedule in Cron** :

```
*/5 * * * * /usr/local/bin/check-audit.sh
```

#### Systemd Journal Integration

**Monitor Specific Events** :

```bash
sudo journalctl -f | grep -i "error\|warning"
```

### Best Practices

**Regular Audits**: Run audits weekly or monthly .

**Review Logs**: Monitor audit logs regularly .

**Document Baseline**: Record initial security state .

**Address Issues**: Fix identified problems promptly .

**Keep Tools Updated**: Update auditing tools regularly .

**Test Alerts**: Verify monitoring is working .

**Archive Logs**: Keep historical audit records .

**Combine Tools**: Use multiple tools for comprehensive coverage .

### Limitations

**False Positives**: Tools may report non-issues .

**Performance Impact**: Comprehensive auditing uses resources .

**Manual Verification**: Some findings require investigation .

**Rootkits Can Hide**: Sophisticated rootkits may evade detection .

### Advanced Auditing

#### Custom auditd Rules

**Complex Monitoring** :

```
-a always,exit -F arch=b64 -S open,openat -F dir=/var/www -F success=0 -k web_access_denied
```

#### Monitoring Network Changes

**Network Activity** :

```bash
sudo auditctl -a always,exit -F arch=b64 -S socket,connect,sendto
```

#### API and Application Monitoring

**Application Calls** :

```bash
sudo ausearch -m EXECVE | grep -i sensitive_app
```

***

This comprehensive auditing tools section completes the Arch Linux administration guide, providing users with the knowledge to implement comprehensive system monitoring, rootkit detection, and security auditing to maintain secure and compliant systems.

