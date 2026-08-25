## Advanced Access Control


### Special Permissions

Special permissions in Linux extend beyond basic read, write, and execute permissions to provide additional security and functionality controls.

#### Setuid (Set User ID)

The setuid permission allows a file to be executed with the privileges of the file owner rather than the user running the file.

**Key points:**

- Represented by 's' in the owner's execute position
- Numeric value: 4000 (4 in the first digit of 4-digit octal)
- Only meaningful on executable files
- Security-sensitive and should be used cautiously

**Example** of setuid implementation:

```bash
# Create a script that needs root privileges
sudo cat > /usr/local/bin/check_logs << 'EOF'
#!/bin/bash
tail -n 20 /var/log/syslog
EOF

# Set ownership and setuid permission
sudo chown root:root /usr/local/bin/check_logs
sudo chmod 4755 /usr/local/bin/check_logs

# Verify setuid is set
ls -l /usr/local/bin/check_logs
# Output: -rwsr-xr-x 1 root root ... check_logs
```

Common setuid programs in Linux systems:

```bash
# Find setuid programs
find /usr/bin -perm -4000 -type f 2>/dev/null
# Examples: passwd, sudo, su, ping
```

#### Setgid (Set Group ID)

Setgid has different behaviors depending on whether it's applied to files or directories.

**On Executable Files:**

- File executes with the group privileges of the file's group
- Represented by 's' in the group's execute position
- Numeric value: 2000 (2 in the first digit)

**On Directories:**

- New files created inherit the directory's group ownership
- Facilitates collaborative work environments

**Example** of setgid on directories:

```bash
# Create shared project directory
sudo mkdir /opt/project_shared
sudo chgrp developers /opt/project_shared
sudo chmod 2775 /opt/project_shared

# Verify setgid is set
ls -ld /opt/project_shared
# Output: drwxrwsr-x 2 root developers ... project_shared

# Test: Files created inherit group
cd /opt/project_shared
touch test_file.txt
ls -l test_file.txt
# Output: -rw-r--r-- 1 user developers ... test_file.txt
```

#### Sticky Bit

The sticky bit restricts file deletion within a directory to the file owner, directory owner, or root.

**Key points:**

- Commonly used on `/tmp` directory
- Represented by 't' in the other's execute position
- Numeric value: 1000 (1 in the first digit)
- Only meaningful on directories in modern Linux

**Example** of sticky bit usage:

```bash
# Check /tmp directory
ls -ld /tmp
# Output: drwxrwxrwt 10 root root ... tmp

# Create directory with sticky bit
mkdir /var/shared_temp
chmod 1777 /var/shared_temp

# Verify sticky bit
ls -ld /var/shared_temp
# Output: drwxrwxrwt 2 root root ... shared_temp
```

#### Combined Special Permissions

Special permissions can be combined using numeric notation:

```bash
# Combine setuid + setgid + sticky bit
chmod 7755 filename  # rwsr-sr-t

# Common combinations
chmod 4755 file      # setuid only
chmod 2755 directory # setgid only
chmod 1755 directory # sticky bit only
chmod 6755 file      # setuid + setgid
```

### Access Control Lists (ACLs)

ACLs provide fine-grained permission control beyond traditional Unix permissions, allowing multiple users and groups to have different access levels on the same file or directory.

#### ACL Basics

ACL support requires filesystem mounting with ACL support and appropriate tools installed.

**Key points:**

- Extend standard permissions with user-specific and group-specific rules
- Support default ACLs for directories
- Use `getfacl` to view and `setfacl` to modify ACLs
- Indicated by '+' at the end of `ls -l` output

**Example** of checking ACL support:

```bash
# Check if filesystem supports ACLs
mount | grep acl
# Or check specific filesystem
tune2fs -l /dev/sda1 | grep acl

# Install ACL tools (if needed)
sudo apt install acl  # Debian/Ubuntu
sudo yum install acl  # RHEL/CentOS
```

#### Setting and Managing ACLs

**Basic ACL Operations:**

```bash
# Create test file and directory
touch test_file.txt
mkdir test_directory

# Set ACL for specific user
setfacl -m u:alice:rw test_file.txt
setfacl -m u:bob:r test_file.txt

# Set ACL for specific group
setfacl -m g:developers:rwx test_directory

# View ACLs
getfacl test_file.txt
# Output:
# # file: test_file.txt
# # owner: user
# # group: user
# user::rw-
# user:alice:rw-
# user:bob:r--
# group::r--
# mask::rw-
# other::r--
```

**Advanced ACL Management:**

```bash
# Remove specific ACL entry
setfacl -x u:alice test_file.txt

# Remove all ACLs
setfacl -b test_file.txt

# Copy ACLs from one file to another
getfacl source_file | setfacl --set-file=- destination_file

# Set default ACLs for directories
setfacl -d -m u:alice:rwx test_directory
setfacl -d -m g:developers:rx test_directory

# Recursive ACL application
setfacl -R -m u:alice:rx /path/to/directory
```

#### ACL Masks and Effective Permissions

The ACL mask determines the maximum effective permissions for named users, named groups, and the owning group.

**Example** of mask behavior:

```bash
# Set ACL with specific permissions
setfacl -m u:alice:rwx test_file.txt
setfacl -m mask:r test_file.txt

# Check effective permissions
getfacl test_file.txt
# Alice's effective permission will be 'r--' due to mask
```

#### Default ACLs for Directories

Default ACLs are inherited by new files and subdirectories created within a directory.

**Example** of default ACL setup:

```bash
# Create project directory structure
mkdir -p /opt/project/{docs,src,logs}

# Set default ACLs
setfacl -d -m u::rwx /opt/project
setfacl -d -m g:developers:rwx /opt/project
setfacl -d -m g:testers:rx /opt/project
setfacl -d -m o::--- /opt/project

# Apply to existing content
setfacl -R -m g:developers:rwx /opt/project
setfacl -R -m g:testers:rx /opt/project

# Test inheritance
cd /opt/project
touch new_file.txt
getfacl new_file.txt  # Will show inherited ACLs
```

### Umask Configuration

Umask (user file creation mask) determines the default permissions for newly created files and directories by specifying which permission bits should be turned off.

#### Understanding Umask Values

Umask works by subtracting permissions from the maximum default permissions:

- Files: 666 (rw-rw-rw-) minus umask
- Directories: 777 (rwxrwxrwx) minus umask

**Key points:**

- Umask values are octal numbers
- Common values: 022, 027, 077
- Applied when files/directories are created
- Can be set per-user or system-wide

**Example** of umask calculations:

```bash
# Current umask
umask
# Output: 0022

# With umask 022:
# New file: 666 - 022 = 644 (rw-r--r--)
# New directory: 777 - 022 = 755 (rwxr-xr-x)

# Test file creation
touch test_umask_file
mkdir test_umask_dir
ls -ld test_umask_*
# File: -rw-r--r--
# Directory: drwxr-xr-x
```

#### Setting Umask Values

**Temporary Umask Changes:**

```bash
# Set restrictive umask for current session
umask 077

# Create file with new umask
touch private_file.txt
ls -l private_file.txt
# Output: -rw------- (only owner can read/write)

# Restore previous umask
umask 022
```

**Permanent Umask Configuration:**

System-wide configuration:

```bash
# Edit /etc/profile or /etc/bash.bashrc
echo "umask 022" >> /etc/profile

# Or in /etc/login.defs
grep UMASK /etc/login.defs
# UMASK 022
```

User-specific configuration:

```bash
# Add to user's ~/.bashrc or ~/.profile
echo "umask 027" >> ~/.bashrc

# For immediate effect
source ~/.bashrc
```

#### Advanced Umask Scenarios

**Conditional Umask Settings:**

```bash
# In ~/.bashrc
if [ $(id -u) -eq 0 ]; then
    umask 022  # Root gets standard umask
else
    umask 027  # Regular users get restrictive umask
fi

# Group-based umask
if groups | grep -q "developers"; then
    umask 002  # Developers share with group
else
    umask 022  # Others use standard
fi
```

**Application-specific Umask:**

```bash
#!/bin/bash
# Script with specific umask requirements

# Save current umask
old_umask=$(umask)

# Set restrictive umask for sensitive operations
umask 077
create_sensitive_files

# Set permissive umask for shared operations  
umask 002
create_shared_files

# Restore original umask
umask $old_umask
```

### Permission Troubleshooting

Systematic approaches to diagnosing and resolving permission-related issues in Linux systems.

#### Common Permission Problems

**Access Denied Errors:**

```bash
# Systematic permission checking
check_permissions() {
    local file_path="$1"
    local current_user=$(whoami)
    
    echo "Checking permissions for: $file_path"
    echo "Current user: $current_user"
    echo "User groups: $(groups)"
    echo
    
    # File existence and basic info
    if [[ -e "$file_path" ]]; then
        ls -la "$file_path"
        echo
        
        # ACL information if available
        if command -v getfacl >/dev/null 2>&1; then
            echo "ACL information:"
            getfacl "$file_path" 2>/dev/null || echo "No ACLs set"
            echo
        fi
        
        # Parent directory permissions
        echo "Parent directory permissions:"
        ls -ld "$(dirname "$file_path")"
        echo
        
        # Test actual access
        echo "Access tests:"
        [[ -r "$file_path" ]] && echo "✓ Readable" || echo "✗ Not readable"
        [[ -w "$file_path" ]] && echo "✓ Writable" || echo "✗ Not writable"
        [[ -x "$file_path" ]] && echo "✓ Executable" || echo "✗ Not executable"
    else
        echo "File does not exist: $file_path"
    fi
}

# Usage
check_permissions /path/to/problematic/file
```

#### Directory Traversal Issues

Permission problems often occur when users lack execute permission on parent directories.

**Example** troubleshooting directory access:

```bash
# Check directory chain permissions
check_directory_chain() {
    local target_path="$1"
    local current_path=""
    
    IFS='/' read -ra PATH_PARTS <<< "$target_path"
    
    for part in "${PATH_PARTS[@]}"; do
        if [[ -n "$part" ]]; then
            current_path="$current_path/$part"
        else
            current_path="/"
        fi
        
        echo "Checking: $current_path"
        ls -ld "$current_path" 2>/dev/null || echo "Cannot access: $current_path"
        
        # Check execute permission on directories
        if [[ -d "$current_path" ]] && [[ ! -x "$current_path" ]]; then
            echo "⚠ Missing execute permission on directory: $current_path"
        fi
        echo
    done
}

# Usage
check_directory_chain /var/www/html/app/config
```

#### Special Permission Troubleshooting

**Setuid/Setgid Issues:**

```bash
# Check for common setuid/setgid problems
troubleshoot_special_perms() {
    local file_path="$1"
    
    if [[ -f "$file_path" ]]; then
        local perms=$(stat -c "%a" "$file_path")
        local owner=$(stat -c "%U" "$file_path")
        local group=$(stat -c "%G" "$file_path")
        
        echo "File: $file_path"
        echo "Permissions: $perms"
        echo "Owner: $owner"
        echo "Group: $group"
        echo
        
        # Check for setuid
        if [[ $((perms & 4000)) -ne 0 ]]; then
            echo "⚠ SETUID bit is set - file executes as $owner"
            [[ "$owner" == "root" ]] && echo "⚠ This file executes with root privileges!"
        fi
        
        # Check for setgid
        if [[ $((perms & 2000)) -ne 0 ]]; then
            echo "⚠ SETGID bit is set - file executes as group $group"
        fi
        
        # Verify execute permission exists
        if [[ ! -x "$file_path" ]]; then
            echo "✗ Execute permission missing - setuid/setgid ineffective"
        fi
    fi
}
```

#### ACL Troubleshooting

**ACL Conflict Resolution:**

```bash
# Diagnose ACL-related permission issues
diagnose_acl_issues() {
    local file_path="$1"
    local username="${2:-$(whoami)}"
    
    echo "ACL diagnosis for $file_path (user: $username)"
    echo "================================================"
    
    # Check if ACLs are present
    if getfacl "$file_path" 2>/dev/null | grep -q "user:"; then
        echo "ACLs detected:"
        getfacl "$file_path"
        echo
        
        # Check effective permissions
        echo "Effective permissions analysis:"
        local mask=$(getfacl "$file_path" 2>/dev/null | grep "^mask:" | cut -d: -f3)
        if [[ -n "$mask" ]]; then
            echo "ACL mask: $mask"
            echo "Note: Effective permissions are limited by mask"
        fi
        
        # Check user-specific ACLs
        local user_acl=$(getfacl "$file_path" 2>/dev/null | grep "^user:$username:")
        if [[ -n "$user_acl" ]]; then
            echo "Specific ACL for $username: $user_acl"
        else
            echo "No specific ACL for $username"
        fi
    else
        echo "No ACLs present - using standard permissions only"
        ls -la "$file_path"
    fi
}
```

#### Comprehensive Permission Audit

**Example** of complete permission audit script:

```bash
#!/bin/bash

permission_audit() {
    local target="$1"
    local report_file="/tmp/permission_audit_$(date +%Y%m%d_%H%M%S).txt"
    
    exec > >(tee "$report_file")
    
    echo "PERMISSION AUDIT REPORT"
    echo "======================="
    echo "Target: $target"
    echo "Date: $(date)"
    echo "User: $(whoami)"
    echo "Groups: $(groups)"
    echo
    
    # Basic file information
    echo "BASIC INFORMATION:"
    ls -la "$target"
    echo
    
    # Special permissions check
    echo "SPECIAL PERMISSIONS:"
    find "$target" -type f \( -perm -4000 -o -perm -2000 -o -perm -1000 \) -ls 2>/dev/null
    echo
    
    # ACL information
    echo "ACCESS CONTROL LISTS:"
    if command -v getfacl >/dev/null 2>&1; then
        getfacl -R "$target" 2>/dev/null | head -50
    else
        echo "ACL tools not available"
    fi
    echo
    
    # World-writable files (security concern)
    echo "WORLD-WRITABLE FILES:"
    find "$target" -type f -perm -002 -ls 2>/dev/null
    echo
    
    # Files without group/other permissions (potentially over-restrictive)
    echo "HIGHLY RESTRICTIVE FILES:"
    find "$target" -type f -perm -700 ! -perm -777 -ls 2>/dev/null
    echo
    
    echo "Report saved to: $report_file"
}

# Usage
permission_audit /path/to/audit
```

**Conclusion:** Advanced access control in Linux requires understanding the interaction between traditional permissions, special permissions, ACLs, and umask settings. Effective troubleshooting involves systematic examination of all these components and their cumulative effects on file access.

**Next steps:** Explore SELinux or AppArmor mandatory access controls, capability-based security models, and integration with centralized authentication systems like LDAP or Active Directory for enterprise environments.

---

