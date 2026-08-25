## User Management


### User Types and Properties

Linux systems distinguish between different types of users based on their privileges, purposes, and system roles. Understanding these distinctions is crucial for proper system administration and security.

**System user types:**

- **Root user (UID 0)**: Superuser with unrestricted access to all system resources
- **System users (UID 1-999)**: Service accounts for daemons and system processes
- **Regular users (UID 1000+)**: Interactive users with limited privileges
- **Service users**: Specialized accounts for specific applications or services

**User identification properties:**

```bash
# User ID (UID) - unique numerical identifier
# Group ID (GID) - primary group membership
# Username - human-readable account name
# Home directory - user's personal directory space
# Login shell - default command interpreter
```

**User account storage locations:**

- `/etc/passwd` - User account information
- `/etc/shadow` - Encrypted passwords and password policies
- `/etc/group` - Group definitions and memberships
- `/etc/gshadow` - Group password information
- `/etc/login.defs` - Default user creation settings
- `/etc/default/useradd` - Default useradd configuration

**Password file structure (/etc/passwd):**

```
username:x:UID:GID:GECOS:home_directory:login_shell
```

**Example entries:**

```
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
john:x:1000:1000:John Doe,,,:/home/john:/bin/bash
```

**Shadow file structure (/etc/shadow):**

```
username:encrypted_password:last_change:min_age:max_age:warn_period:inactive_period:expiration_date:reserved
```

**Key points:**

- UID 0 is always root, regardless of username
- UIDs below 1000 are typically reserved for system accounts
- The 'x' in /etc/passwd indicates passwords are stored in /etc/shadow
- GECOS field contains user information like full name and contact details

### User Creation (useradd)

The `useradd` command creates new user accounts with specified properties and default settings. It modifies system files and creates necessary directories.

**Basic syntax:**

```bash
useradd [options] username
```

**Common useradd options:**

```bash
# Create user with home directory
useradd -m username

# Specify user ID
useradd -u 1500 username

# Set primary group
useradd -g groupname username

# Add to supplementary groups
useradd -G group1,group2,group3 username

# Set home directory path
useradd -d /custom/home/path username

# Set login shell
useradd -s /bin/zsh username

# Set account expiration date
useradd -e 2024-12-31 username

# Create system account
useradd -r username

# Add comment/GECOS information
useradd -c "Full Name,Room,Work Phone,Home Phone" username
```

**Comprehensive user creation examples:**

```bash
# Basic user with home directory
sudo useradd -m john

# Advanced user creation
sudo useradd -m -u 1500 -g users -G sudo,docker -s /bin/bash -c "John Doe" john

# System service user
sudo useradd -r -s /usr/sbin/nologin -d /var/lib/myservice myservice

# User with custom home and no login
sudo useradd -m -d /opt/appuser -s /bin/false appuser
```

**Default settings configuration:**

```bash
# View current defaults
useradd -D

# Modify default home directory base
sudo useradd -D -b /home

# Set default shell
sudo useradd -D -s /bin/bash

# Set default group
sudo useradd -D -g users
```

**Post-creation tasks:**

```bash
# Set initial password
sudo passwd username

# Create additional directories
sudo mkdir -p /home/username/{Documents,Downloads,Pictures}

# Set proper ownership
sudo chown -R username:username /home/username

# Copy skeleton files
sudo cp -r /etc/skel/. /home/username/
```

**Key points:**

- Use `-m` to create home directory automatically
- System users (`-r`) typically have UIDs below 1000 and no shell access
- Always set passwords after user creation
- Default settings are defined in `/etc/default/useradd` and `/etc/login.defs`

### User Modification (usermod)

The `usermod` command modifies existing user account properties without recreating the account. It can change most user attributes while preserving existing data.

**Basic syntax:**

```bash
usermod [options] username
```

**Common modification operations:**

```bash
# Change username
sudo usermod -l newname oldname

# Change user ID
sudo usermod -u 1600 username

# Change primary group
sudo usermod -g newgroup username

# Set supplementary groups (replaces existing)
sudo usermod -G group1,group2 username

# Add to supplementary groups (append)
sudo usermod -a -G newgroup username

# Change home directory
sudo usermod -d /new/home/path username

# Move home directory to new location
sudo usermod -d /new/home/path -m username

# Change login shell
sudo usermod -s /bin/zsh username

# Change GECOS information
sudo usermod -c "New Full Name" username
```

**Account status modifications:**

```bash
# Lock user account
sudo usermod -L username

# Unlock user account
sudo usermod -U username

# Set account expiration date
sudo usermod -e 2024-12-31 username

# Remove account expiration
sudo usermod -e "" username

# Set password expiration
sudo usermod -f 30 username  # Account disabled 30 days after password expires
```

**Advanced modifications:**

```bash
# Change multiple properties simultaneously
sudo usermod -u 1700 -g staff -G admin,docker -s /bin/zsh -c "Updated User" username

# Move user to different home and update ownership
sudo usermod -d /opt/users/username -m username
sudo chown -R username:username /opt/users/username

# Convert regular user to system user (change UID range)
sudo usermod -u 999 -s /usr/sbin/nologin username
```

**Group membership management:**

```bash
# View current group memberships
groups username
id username

# Remove from all supplementary groups
sudo usermod -G "" username

# Add to sudo group (common administrative task)
sudo usermod -a -G sudo username

# Remove from specific group (requires manual editing or gpasswd)
sudo gpasswd -d username groupname
```

**Key points:**

- Use `-a` with `-G` to append groups rather than replace
- Moving home directories with `-m` preserves file ownership
- Changing usernames requires updating references in cron jobs, file ownership, etc.
- Some changes may require user to log out and back in to take effect

### Password Management (passwd)

The `passwd` command manages user passwords, password policies, and account password status. It interacts with both `/etc/passwd` and `/etc/shadow` files.

**Basic password operations:**

```bash
# Change your own password
passwd

# Change another user's password (requires root)
sudo passwd username

# Set password from command line (non-interactive)
echo "newpassword" | sudo passwd --stdin username  # Red Hat/CentOS
sudo chpasswd <<< "username:newpassword"          # Universal method
```

**Password status and information:**

```bash
# Check password status
sudo passwd -S username

# Display password aging information
sudo chage -l username

# Show all users' password status
sudo passwd -Sa
```

**Account locking and unlocking:**

```bash
# Lock user account (prevents login)
sudo passwd -l username

# Unlock user account
sudo passwd -u username

# Delete password (allows passwordless login)
sudo passwd -d username

# Force password change on next login
sudo passwd -e username
```

**Password aging and policies:**

```bash
# Set maximum password age (days)
sudo chage -M 90 username

# Set minimum password age (days)
sudo chage -m 7 username

# Set password expiration warning period (days)
sudo chage -W 14 username

# Set account expiration date
sudo chage -E 2024-12-31 username

# Set date of last password change
sudo chage -d 2024-01-01 username

# Interactive password aging setup
sudo chage username
```

**Password policy configuration:**

```bash
# System-wide password policies (/etc/login.defs)
PASS_MAX_DAYS   90      # Maximum password age
PASS_MIN_DAYS   7       # Minimum password age  
PASS_WARN_AGE   14      # Warning days before expiration
PASS_MIN_LEN    8       # Minimum password length

# PAM password quality settings (/etc/pam.d/common-password)
# Requires libpam-pwquality or similar
password required pam_pwquality.so retry=3 minlen=8 difok=3
```

**Bulk password operations:**

```bash
# Change multiple passwords from file
# Format: username:password
sudo chpasswd < password_file.txt

# Generate random passwords
openssl rand -base64 12  # Generate random password
pwgen 12 1              # Generate pronounceable password (if installed)

# Set passwords with expiration
echo "user1:temp123" | sudo chpasswd
sudo chage -d 0 user1  # Force change on next login
```

**Password security best practices:**

```bash
# Check password complexity requirements
sudo pam-auth-update  # Configure authentication methods

# Audit password strength
sudo john /etc/shadow          # Password cracking tool (if installed)
sudo pwscore <<< "password"    # Score password strength

# Monitor failed login attempts
sudo lastb                     # Show bad login attempts
sudo grep "authentication failure" /var/log/auth.log
```

**Key points:**

- Regular users can only change their own passwords
- Root can change any user's password without knowing the current one
- Password aging settings affect when users must change passwords
- Locked accounts prevent login but don't disable the account entirely
- Password policies should be configured system-wide for consistency

**Next steps:** Understanding group management, sudo configuration, and user session management will complement these user management fundamentals.

---

