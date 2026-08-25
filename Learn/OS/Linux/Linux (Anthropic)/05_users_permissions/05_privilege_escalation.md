## Privilege Escalation


### su Command Usage

The `su` (substitute user) command allows users to switch to another user account, most commonly to gain root privileges. It creates a new shell session with the target user's environment and permissions.

**Basic su syntax:**

```bash
su [options] [username]
```

**Common su operations:**

```bash
# Switch to root user (requires root password)
su

# Switch to root with full environment
su -

# Switch to specific user
su username
su - username

# Execute single command as root
su -c "command"

# Execute command as specific user
su username -c "command"
```

**Environment handling differences:**

```bash
# Preserve current environment
su root
# Current directory: unchanged
# Environment variables: mostly preserved
# PATH: may not include /sbin, /usr/sbin

# Login shell (recommended)
su - root
# Current directory: target user's home
# Environment variables: target user's environment
# PATH: includes all administrative directories
```

**Advanced su usage:**

```bash
# Switch to user with specific shell
su -s /bin/zsh username

# Execute multiple commands
su -c "cd /var/log && tail -f syslog"

# Switch to user with preserved environment variables
su --preserve-environment username

# Fast user switching (login shell)
su -l username  # Equivalent to su - username
```

**su authentication and security:**

```bash
# Check su usage logs
sudo grep "su:" /var/log/auth.log

# Failed su attempts
sudo grep "FAILED su" /var/log/auth.log

# Successful su sessions
sudo grep "session opened" /var/log/auth.log | grep su
```

**Key points:**

- `su` without username defaults to root user
- `su -` provides clean environment like fresh login
- Requires target user's password (not current user's password)
- All su activity is logged in system authentication logs
- Use `exit` or Ctrl+D to return to original user session

### sudo Configuration

The `sudo` (superuser do) command allows authorized users to execute commands with elevated privileges without knowing the root password. It provides granular access control and comprehensive logging.

**Basic sudo concepts:**

- Users must be authorized in `/etc/sudoers` file
- Authentication uses user's own password (not root password)
- Temporary privilege escalation with automatic timeout
- All sudo activity is logged for auditing

**Common sudo usage patterns:**

```bash
# Execute single command as root
sudo command

# Execute command as specific user
sudo -u username command

# Start interactive root shell
sudo -i

# Start shell preserving environment
sudo -s

# Execute command with specific group
sudo -g groupname command

# Run command in background
sudo nohup long_running_command &
```

**sudo session management:**

```bash
# Extend sudo timeout (enter password once)
sudo -v

# Clear sudo timestamp (force re-authentication)
sudo -k

# List allowed commands for current user
sudo -l

# List allowed commands for specific user
sudo -l -U username

# Check sudo access without executing
sudo -n command  # Non-interactive, fails if authentication required
```

**sudo environment handling:**

```bash
# Preserve specific environment variables
sudo -E command

# Set environment variables for command
sudo VAR=value command

# Execute with clean environment
sudo -i command

# Preserve HOME directory
sudo -H command
```

**sudo security features:**

```bash
# Password timeout configuration (default 15 minutes)
# Configured in /etc/sudoers with timestamp_timeout

# Command logging
sudo tail /var/log/sudo.log      # If configured
sudo journalctl -u sudo         # Systemd systems

# Failed sudo attempts
sudo grep "COMMAND" /var/log/auth.log
sudo grep "authentication failure" /var/log/auth.log | grep sudo
```

**Key points:**

- sudo provides temporary privilege escalation with accountability
- Users authenticate with their own passwords, not root password
- All commands executed via sudo are logged for security auditing
- Session timestamps reduce password prompting frequency
- `sudo -i` creates login shell, `sudo -s` preserves current environment

### sudoers File Editing

The `/etc/sudoers` file controls sudo access permissions and policies. It must be edited using `visudo` to prevent syntax errors that could lock out administrative access.

**Safe sudoers editing:**

```bash
# Edit sudoers file safely
sudo visudo

# Edit sudoers file with specific editor
sudo EDITOR=nano visudo

# Edit additional sudoers files
sudo visudo -f /etc/sudoers.d/custom-rules

# Check sudoers syntax without editing
sudo visudo -c
```

**sudoers file structure:**

```bash
# User privilege specification format:
# user    host=(runas) command

# Group privilege specification format:
# %group  host=(runas) command

# Examples:
root    ALL=(ALL:ALL) ALL
%sudo   ALL=(ALL:ALL) ALL
john    ALL=(ALL) NOPASSWD: /usr/bin/systemctl
```

**Basic sudoers entries:**

```bash
# Grant full sudo access
username ALL=(ALL:ALL) ALL

# Grant sudo access to group
%groupname ALL=(ALL:ALL) ALL

# Allow specific commands without password
username ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/systemctl

# Allow commands as specific user
username ALL=(webuser) /usr/bin/systemctl restart apache2

# Restrict to specific hosts
username server1,server2=(ALL) ALL
```

**Advanced sudoers configurations:**

```bash
# Command aliases for easier management
Cmnd_Alias SERVICES = /usr/bin/systemctl, /usr/sbin/service
Cmnd_Alias NETWORKING = /sbin/ifconfig, /usr/bin/netstat
Cmnd_Alias SOFTWARE = /usr/bin/apt, /usr/bin/yum, /usr/bin/dnf

# User aliases
User_Alias ADMINS = john, jane, bob
User_Alias DEVELOPERS = alice, charlie

# Host aliases
Host_Alias SERVERS = server1, server2, 192.168.1.0/24

# Apply aliases
ADMINS ALL=(ALL) ALL
DEVELOPERS ALL=(ALL) NOPASSWD: SERVICES
%operators SERVERS=(ALL) NETWORKING
```

**Security-focused sudoers rules:**

```bash
# Require password for all commands (disable NOPASSWD)
username ALL=(ALL) ALL

# Restrict dangerous commands
username ALL=(ALL) ALL, !/bin/su, !/usr/bin/passwd root

# Time-based restrictions [Inference: This syntax may vary by sudo version]
username ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart apache2

# Logging specific commands
Defaults log_host, log_year, logfile="/var/log/sudo.log"
Defaults mailto="admin@company.com"
Defaults mail_badpass, mail_no_user, mail_no_host
```

**sudoers file security options:**

```bash
# Security-related defaults
Defaults env_reset                    # Reset environment variables
Defaults mail_badpass                 # Email failed password attempts
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults passwd_tries=3               # Maximum password attempts
Defaults passwd_timeout=5             # Password prompt timeout
Defaults timestamp_timeout=15         # Session timeout in minutes
Defaults requiretty                   # Require TTY for sudo commands
```

**Include files and modular configuration:**

```bash
# Include additional configuration files
#includedir /etc/sudoers.d

# Create modular configuration
sudo visudo -f /etc/sudoers.d/developers
sudo visudo -f /etc/sudoers.d/service-accounts

# Example: /etc/sudoers.d/web-admins
%web-admins ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart apache2, /usr/bin/systemctl restart nginx
```

**Key points:**

- Always use `visudo` to edit sudoers files to prevent syntax errors
- Syntax errors in sudoers can completely break sudo access
- Use aliases to simplify complex permission sets
- Include files in `/etc/sudoers.d/` for modular configuration
- Test sudoers changes with `sudo -l` before logging out

### Security Best Practices

Implementing proper security practices for privilege escalation protects against unauthorized access and maintains system integrity through monitoring and access control.

**Password and authentication security:**

```bash
# Enforce strong password policies
# /etc/pam.d/common-password
password required pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1

# Configure account lockout after failed attempts
# /etc/pam.d/common-auth
auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900

# Monitor authentication logs
sudo tail -f /var/log/auth.log
sudo journalctl -u ssh -f
```

**sudo security hardening:**

```bash
# Secure sudoers defaults
Defaults env_reset
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults use_pty                      # Use pseudo-terminal
Defaults logfile="/var/log/sudo.log"
Defaults log_host, log_year
Defaults requiretty                   # Require terminal for sudo
Defaults !visiblepw                   # Don't show password prompts
```

**Access control principles:**

```bash
# Principle of least privilege - grant minimal necessary access
developer ALL=(www-data) NOPASSWD: /usr/bin/systemctl restart apache2

# Avoid wildcards in command specifications
# Bad: user ALL=(ALL) /bin/*
# Good: user ALL=(ALL) /bin/systemctl, /bin/cat /var/log/apache2/*

# Regular access reviews
sudo -l -U username                   # Review user permissions
sudo visudo -c                        # Verify sudoers syntax
```

**Monitoring and auditing:**

```bash
# Enable comprehensive sudo logging
Defaults log_host, log_year, logfile="/var/log/sudo.log"
Defaults syslog=authpriv
Defaults syslog_goodpri=info
Defaults syslog_badpri=alert

# Monitor sudo usage
sudo grep "COMMAND" /var/log/sudo.log
sudo journalctl -u sudo

# Set up log rotation
# /etc/logrotate.d/sudo
/var/log/sudo.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
}
```

**Root account security:**

```bash
# Disable root SSH login
# /etc/ssh/sshd_config
PermitRootLogin no

# Lock root account password
sudo passwd -l root

# Monitor root access attempts
sudo grep "root" /var/log/auth.log
sudo lastb root

# Audit root-equivalent access
sudo awk -F: '$3 == 0 {print $1}' /etc/passwd  # Find UID 0 accounts
```

**Network and session security:**

```bash
# Restrict sudo to local connections only
Defaults requiretty
Defaults !visiblepw

# Configure session timeouts
Defaults timestamp_timeout=5          # Reduce timeout to 5 minutes
Defaults passwd_timeout=1             # 1 minute password timeout

# Monitor active sessions
who -u                                # Show active user sessions
last                                  # Show login history
sudo ss -tulpn                        # Monitor network connections
```

**Emergency access procedures:**

```bash
# Maintain emergency access methods
# 1. Physical console access
# 2. Single-user mode access
# 3. Recovery boot options

# Document emergency procedures
# /root/emergency-access.txt with instructions
# Maintain offline administrative documentation

# Regular backup of critical files
sudo cp /etc/sudoers /root/sudoers.backup.$(date +%Y%m%d)
sudo cp /etc/passwd /root/passwd.backup.$(date +%Y%m%d)
sudo cp /etc/shadow /root/shadow.backup.$(date +%Y%m%d)
```

**Security monitoring alerts:**

```bash
# Configure email alerts for sudo violations
Defaults mailto="security@company.com"
Defaults mail_badpass, mail_no_user, mail_no_host

# Set up automated monitoring
# Example: Alert on multiple failed sudo attempts
#!/bin/bash
THRESHOLD=5
TIMEFRAME="10 minutes ago"
FAILED_COUNT=$(sudo journalctl --since="$TIMEFRAME" | grep "sudo.*authentication failure" | wc -l)
if [ "$FAILED_COUNT" -gt "$THRESHOLD" ]; then
    echo "Alert: $FAILED_COUNT failed sudo attempts in last 10 minutes" | mail -s "Security Alert" admin@company.com
fi
```

**Key points:**

- Implement defense in depth with multiple security layers
- Regular auditing and monitoring of privileged access is essential
- Follow principle of least privilege for all sudo grants
- Maintain emergency access procedures and documentation
- Keep security configurations updated and tested regularly

**Related topics:** SELinux/AppArmor mandatory access controls, PAM authentication modules, system auditing with auditd, and centralized logging solutions complement privilege escalation security.

---

