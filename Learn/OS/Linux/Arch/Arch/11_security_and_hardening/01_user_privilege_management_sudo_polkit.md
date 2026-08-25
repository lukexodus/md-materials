## User Privilege Management (sudo, polkit)


### Privilege Escalation Overview

**Purpose**: Control who can execute administrative commands.[1]

**Security Model**:[1]
- Regular users have limited privileges[1]
- Administrative tasks require elevation[1]
- Audit trail of privileged actions[1]

**Tools**:[1]
- **sudo**: Command-line privilege escalation[1]
- **polkit**: Desktop policy authorization[1]

### sudo Fundamentals

#### sudo Concept

**Purpose**: Execute commands as another user (usually root).[1]

**Default**: User must provide password.[1]

**Security**: Configurable restrictions and logging.[1]

#### Basic sudo Usage

**Execute Command as Root**:[1]

```bash
sudo pacman -Syu
```

**Prompts for Password**: Cached for 15 minutes.[1]

**Different User**:[1]

```bash
sudo -u username command
```

**Run as Root**:[1]

```bash
sudo -i  # Interactive root shell
sudo -s  # Shell as root
```

#### Check sudo Privileges

**User Permissions**:[1]

```bash
sudo -l
```

**Output**: List of allowed commands.[1]

**Specific Command**:[1]

```bash
sudo -l -U username
```

### sudoers Configuration

#### Edit sudoers File

**Never Edit Directly**:[1]

Always use `visudo`.[1]

**Safe Editor**:[1]

```bash
sudo visudo
```

**Default Editor**: nano if EDITOR not set.[1]

**Change Editor**:[1]

```bash
sudo EDITOR=vim visudo
```

#### Basic sudoers Syntax

**Allow User All Commands**:[1]

```
username ALL=(ALL) ALL
```

**Allow Without Password**:[1]

```
username ALL=(ALL) NOPASSWD: ALL
```

**Caution**: Security risk.[1]

#### Group-Based Access

**Group Sudo**:[1]

```
%wheel ALL=(ALL) ALL
```

**Members of wheel group**: Can use sudo.[1]

**Add User to Group**:[1]

```bash
sudo usermod -aG wheel username
```

#### Command-Specific Access

**Single Command**:[1]

```
username ALL=(ALL) /usr/bin/systemctl
```

**Multiple Commands**:[1]

```
username ALL=(ALL) /usr/bin/systemctl, /usr/bin/journalctl
```

**Command with Options**:[1]

```
username ALL=(ALL) /usr/bin/systemctl restart nginx
```

**No Password for Command**:[1]

```
username ALL=(ALL) NOPASSWD: /usr/bin/systemctl
```

### sudo Security Configuration

#### Require Password for sudo

**Default**: Enabled.[1]

**Verify in sudoers**: No `NOPASSWD:` entries.[1]

#### Password Timeout

**Cache Duration**:[1]

```
Defaults timestamp_timeout=15
```

Minutes before re-authentication required.[1]

**Disable Caching**:[1]

```
Defaults timestamp_type=global, timestamp_timeout=0
```

#### Logging

**Enable sudo Logging**:[1]

```
Defaults logfile="/var/log/sudo.log"
```

**View Logs**:[1]

```bash
sudo tail -f /var/log/sudo.log
```

#### TTY Requirement

**Require TTY**:[1]

```
Defaults use_pty
```

Prevents non-interactive abuse.[1]

#### Environment Restrictions

**Preserve User Environment**:[1]

```
Defaults env_reset
```

Prevents privilege escalation via environment.[1]

### sudo Aliases

#### User Aliases

**Define Groups**:[1]

```
User_Alias ADMINS = user1, user2, user3
User_Alias HELPDESK = help1, help2
```

**Grant Access**:[1]

```
ADMINS ALL=(ALL) ALL
HELPDESK ALL=(ALL) /usr/bin/systemctl
```

#### Command Aliases

**Group Commands**:[1]

```
Cmnd_Alias PROCESSES = /usr/bin/systemctl, /usr/bin/journalctl
Cmnd_Alias NETWORKING = /usr/sbin/ip, /usr/sbin/ifconfig
```

**Use in Rules**:[1]

```
username ALL=(ALL) PROCESSES, NETWORKING
```

#### Host Aliases

**Define Hosts**:[1]

```
Host_Alias SERVERS = server1, server2, server3
Host_Alias WORKSTATIONS = ws1, ws2
```

**Host-Specific Rules**:[1]

```
username SERVERS=(ALL) ALL
username WORKSTATIONS=(ALL) /usr/bin/systemctl
```

### Sudoers Examples

#### Development Environment

**Developers Group**:[1]

```
%developers ALL=(ALL) NOPASSWD: /usr/bin/docker
%developers ALL=(ALL) /usr/bin/systemctl restart app
```

#### System Administrators

**Admin Group**:[1]

```
%sudo ALL=(ALL) ALL
```

**No Password**:[1]

```
%sudo ALL=(ALL) NOPASSWD: ALL
```

#### Service Account

**Specific Service**:[1]

```
webserver ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
webserver ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx
```

### Audit sudo Access

#### View sudo History

**Command History**:[1]

```bash
grep sudo /var/log/auth.log
```

**Failed Attempts**:[1]

```bash
grep sudo /var/log/auth.log | grep FAILED
```

#### Log Analysis

**All sudo Commands**:[1]

```bash
sudo journalctl SYSLOG_IDENTIFIER=sudo
```

**Specific User**:[1]

```bash
sudo journalctl SYSLOG_IDENTIFIER=sudo | grep username
```

### sudo Troubleshooting

#### User Not in sudoers

**Error**:[1]

```
username is not in the sudoers file
```

**Add User**:[1]

```bash
sudo usermod -aG wheel username
```

Or edit sudoers.[1]

#### sudo Asks for Password Repeatedly

**Issue**: Password re-prompted constantly.[1]

**Check Timeout**:[1]

```
Defaults timestamp_timeout=15
```

**Increase Timeout**:[1]

```
Defaults timestamp_timeout=30
```

#### Incorrect sudoers Syntax

**Symptom**: Can't run sudo at all.[1]

**Check Syntax**:[1]

```bash
sudo visudo -c
```

**Exit Without Saving**: Ctrl+X in visudo.[1]

### polkit Overview

**Purpose**: Flexible authorization framework for desktop actions .

**Use Cases** :
- System updates without password 
- Mounting drives 
- Network management 
- Power management 

#### polkit vs sudo

**sudo**:[1]
- Command-line tool[1]
- Executes commands as root[1]
- Simple allow/deny[1]

**polkit** :
- Desktop authorization 
- Fine-grained policies 
- Context-aware decisions 

### polkit Configuration

#### Policy Files

**Location**: `/etc/polkit-1/rules.d/` .

**Extension**: `.rules` files .

**Format**: JavaScript-based rules .

#### Example polkit Rule

**Allow User Action Without Password** :

Create `/etc/polkit-1/rules.d/50-myapp.rules`:

```javascript
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.systemd1.manage-units" &&
        subject.local == true &&
        subject.active == true) {
        return polkit.Result.YES;
    }
});
```

**Explanation** :
- Action ID to authorize 
- Subject conditions 
- Decision result 

#### Interactive Authorization

**Default polkit** :

Presents authentication dialog to user .

**User Can Approve**: Without administrator password .

### Common polkit Rules

#### System Updates

**Allow User to Update** :

```javascript
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.packagekit.install-packages" &&
        subject.local == true &&
        subject.active == true) {
        return polkit.Result.YES;
    }
});
```

#### Drive Mounting

**Auto-Mount USB Drives** :

```javascript
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.udisks2.filesystem-mount" &&
        subject.local == true &&
        subject.active == true) {
        return polkit.Result.YES;
    }
});
```

#### Power Management

**Power Actions** :

```javascript
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.login1.power-off" ||
         action.id == "org.freedesktop.login1.suspend") &&
        subject.local == true &&
        subject.active == true) {
        return polkit.Result.YES;
    }
});
```

### User and Group Management

#### Create User

**New User**:[1]

```bash
sudo useradd -m -s /bin/bash username
```

**Parameters**:[1]
- `-m`: Create home directory[1]
- `-s`: Login shell[1]

#### Set Password

**Initial Password**:[1]

```bash
sudo passwd username
```

**User Can Change**:[1]

```bash
passwd
```

#### Add to Groups

**Add to wheel**:[1]

```bash
sudo usermod -aG wheel username
```

**Add to Multiple**:[1]

```bash
sudo usermod -aG wheel,docker,audio username
```

#### Remove User

**Delete User**:[1]

```bash
sudo userdel -r username
```

**Parameter `-r`**: Remove home directory.[1]

#### List Users

**All Users**:[1]

```bash
cat /etc/passwd | grep -v nologin
```

**User Groups**:[1]

```bash
groups username
id username
```

### Group Management

#### Create Group

**New Group**:[1]

```bash
sudo groupadd groupname
```

#### Add User to Group

**Add Member**:[1]

```bash
sudo usermod -aG groupname username
```

**Verify**:[1]

```bash
groups username
```

#### Remove User from Group

**Remove Member**:[1]

```bash
sudo gpasswd -d username groupname
```

#### Delete Group

**Remove Group**:[1]

```bash
sudo groupdel groupname
```

### File Permissions

#### Basic Permissions

**Read (r)**: 4[1]

**Write (w)**: 2[1]

**Execute (x)**: 1[1]

**Numeric Values**:[1]
- 7 = rwx[1]
- 6 = rw-[1]
- 5 = r-x[1]
- 4 = r--[1]

#### Change Permissions

**chmod Command**:[1]

```bash
chmod 755 script.sh   # rwxr-xr-x
chmod 644 file.txt    # rw-r--r--
chmod 700 private/    # rwx------
```

**Symbolic**:[1]

```bash
chmod u+x script.sh   # Add execute for user
chmod g+r file.txt    # Add read for group
chmod o-r file.txt    # Remove read for others
```

#### Change Ownership

**chown Command**:[1]

```bash
sudo chown user file.txt
sudo chown user:group file.txt
sudo chown -R user:group directory/
```

### Privilege Escalation Security

#### Principle of Least Privilege

**Minimal Access**:[1]
- Users only need required privileges[1]
- Restrict by command, not all commands[1]
- Remove root from wheel if unnecessary[1]

#### Monitor Privilege Use

**Audit sudo**:[1]

```bash
sudo journalctl SYSLOG_IDENTIFIER=sudo
```

**Regular Review**:[1]

Check who has administrative access.[1]

#### Best Practices

**Don't Use Root Account**:[1]

Use sudo instead.[1]

**Require Password**:[1]

Avoid NOPASSWD unless necessary.[1]

**Specific Commands**:[1]

Limit to exact commands needed.[1]

**Regular Audits**:[1]

Review sudoers periodically.[1]

**Protect sudoers File**:[1]

File permissions should be 0440.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman

