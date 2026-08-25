## Permission System in Linux


### Permission Model

#### Basic Permission Types

Linux implements a three-tier permission system controlling access to files and directories. Each file and directory has three types of permissions applied to three categories of users.

The three permission types are:

- **Read (r)**: Allows viewing file contents or listing directory contents
- **Write (w)**: Allows modifying file contents or creating/deleting files in directories
- **Execute (x)**: Allows running files as programs or accessing directories

The three user categories are:

- **User/Owner (u)**: The file or directory owner
- **Group (g)**: Members of the file's assigned group
- **Others (o)**: All other users on the system

#### Permission Display

Use `ls -l` to view detailed permission information:

```bash
$ ls -l /etc/passwd
-rw-r--r-- 1 root root 2847 Oct 15 14:23 /etc/passwd
```

The permission string `-rw-r--r--` breaks down as:

- First character: File type (`-` for regular file, `d` for directory, `l` for symbolic link)
- Characters 2-4: Owner permissions (`rw-`)
- Characters 5-7: Group permissions (`r--`)
- Characters 8-10: Other permissions (`r--`)

#### File vs Directory Permissions

For files:

- **Read**: View file contents with commands like `cat`, `less`, `head`
- **Write**: Modify file contents with editors or redirection
- **Execute**: Run the file as a program or script

For directories:

- **Read**: List directory contents with `ls`
- **Write**: Create, delete, or rename files within the directory
- **Execute**: Enter the directory with `cd` and access files within it

**Key Points:**

- Directory execute permission is required to access files within it
- Directory write permission allows file creation/deletion regardless of individual file permissions
- Read permission on a directory without execute permission allows listing but not accessing files

### Numeric Permissions

#### Octal Notation System

Numeric permissions use octal (base-8) notation where each digit represents permissions for user, group, and others respectively. Each permission type has a numeric value:

- **Read (r)**: 4
- **Write (w)**: 2
- **Execute (x)**: 1

Permissions are calculated by adding these values:

```bash
# Permission combinations
0 = --- (no permissions)
1 = --x (execute only)
2 = -w- (write only)
3 = -wx (write + execute)
4 = r-- (read only)
5 = r-x (read + execute)
6 = rw- (read + write)
7 = rwx (read + write + execute)
```

#### Common Numeric Permission Patterns

```bash
# Files
644 = rw-r--r-- (owner: read/write, group/others: read only)
600 = rw------- (owner: read/write, group/others: no access)
755 = rwxr-xr-x (owner: full access, group/others: read/execute)
700 = rwx------ (owner: full access, group/others: no access)

# Directories
755 = rwxr-xr-x (standard directory permissions)
750 = rwxr-x--- (group can access, others cannot)
700 = rwx------ (only owner can access)
```

#### Setting Numeric Permissions

```bash
# Set file permissions
chmod 644 file.txt
chmod 755 script.sh
chmod 600 private.key

# Set directory permissions recursively
chmod -R 755 /var/www/html/

# Set different permissions for files and directories
find /path -type f -exec chmod 644 {} \;
find /path -type d -exec chmod 755 {} \;
```

**Example** of permission calculation:

```bash
# For permission 754
# Owner: 7 = 4+2+1 = rwx
# Group: 5 = 4+1 = r-x  
# Others: 4 = 4 = r--
# Result: rwxr-xr--
```

### Symbolic Permissions

#### Symbolic Notation Components

Symbolic permissions use letters and operators to modify permissions:

**Who (user classes):**

- `u`: User/owner
- `g`: Group
- `o`: Others
- `a`: All (equivalent to `ugo`)

**Operators:**

- `+`: Add permissions
- `-`: Remove permissions
- `=`: Set exact permissions (overwrite existing)

**Permissions:**

- `r`: Read
- `w`: Write
- `x`: Execute
- `X`: Execute only if file is directory or already has execute permission
- `s`: Set user ID (SUID) or group ID (SGID)
- `t`: Sticky bit

#### Basic Symbolic Operations

```bash
# Add execute permission for owner
chmod u+x script.sh

# Remove write permission for group and others
chmod go-w file.txt

# Set read-only for everyone
chmod a=r file.txt

# Add read and execute for group
chmod g+rx directory/

# Remove all permissions for others
chmod o-rwx private.txt
```

#### Advanced Symbolic Operations

```bash
# Multiple operations in one command
chmod u+rw,g+r,o-rwx file.txt

# Copy permissions between user classes
chmod u=rw,g=u,o=g file.txt  # [Inference] This sets group and others to match user permissions

# Conditional execute permission
chmod a+X directory/  # Adds execute only to directories and executable files

# Set permissions relative to current permissions
chmod +x script.sh    # Add execute for all users
chmod -w file.txt     # Remove write for all users
```

#### Recursive Symbolic Changes

```bash
# Apply to all files and subdirectories
chmod -R g+w project/

# Apply different permissions to files vs directories
chmod -R a+X directory/  # Execute only on directories
find directory/ -type f -exec chmod 644 {} \;  # Files get 644
find directory/ -type d -exec chmod 755 {} \;  # Directories get 755
```

### Special Permissions

#### Set User ID (SUID)

```bash
# Set SUID bit (4000 in numeric, s in symbolic)
chmod 4755 program        # Numeric
chmod u+s program         # Symbolic

# Example: passwd command
$ ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 68208 Jul 14 22:50 /usr/bin/passwd
```

#### Set Group ID (SGID)

```bash
# Set SGID bit (2000 in numeric, s in symbolic)
chmod 2755 directory      # Numeric
chmod g+s directory       # Symbolic

# Files created in SGID directory inherit the directory's group
```

#### Sticky Bit

```bash
# Set sticky bit (1000 in numeric, t in symbolic)
chmod 1755 /tmp           # Numeric
chmod +t /tmp             # Symbolic

# Example: /tmp directory
$ ls -ld /tmp
drwxrwxrwt 10 root root 4096 Oct 15 14:25 /tmp
```

### Ownership Management

#### chown Command

The `chown` command changes file and directory ownership:

```bash
# Basic syntax
chown [options] user[:group] file(s)

# Change owner only
chown alice file.txt
chown alice:alice file.txt    # Change both user and group

# Change owner recursively
chown -R alice:developers project/

# Change owner using numeric IDs
chown 1000:1000 file.txt

# Change group only (using colon prefix)
chown :developers file.txt
```

#### chgrp Command

The `chgrp` command changes group ownership:

```bash
# Basic group change
chgrp developers file.txt

# Recursive group change
chgrp -R staff directory/

# Change group using numeric GID
chgrp 100 file.txt

# Change group and show changes
chgrp -v users *.txt
```

#### Ownership Examples

```bash
# Web server file ownership
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/
find /var/www/html/ -type f -exec chmod 644 {} \;

# User home directory setup
chown -R user:user /home/user/
chmod 750 /home/user/
chmod 700 /home/user/.ssh/
chmod 600 /home/user/.ssh/*
```

### Default Permissions and umask

#### Understanding umask

The `umask` command sets default permission masks for newly created files and directories:

```bash
# View current umask
umask
umask -S  # Symbolic format

# Set umask values
umask 022  # Files: 644, Directories: 755
umask 002  # Files: 664, Directories: 775
umask 077  # Files: 600, Directories: 700
```

**Key Points:**

- Default file permissions: 666 minus umask
- Default directory permissions: 777 minus umask
- umask 022 results in files (666-022=644) and directories (777-022=755)

#### Setting Default Permissions

```bash
# In shell configuration files (~/.bashrc, ~/.profile)
umask 022

# For specific applications
umask 002  # More permissive for shared development
```

### Access Control Lists (ACLs)

#### Extended Permissions

[Unverified] Modern Linux systems support Access Control Lists for more granular permission control:

```bash
# Set ACL permissions
setfacl -m u:alice:rwx file.txt
setfacl -m g:developers:rw file.txt

# View ACL permissions
getfacl file.txt

# Remove ACL permissions
setfacl -x u:alice file.txt

# Set default ACLs for directories
setfacl -d -m g:developers:rw directory/
```

### Permission Troubleshooting

#### Common Permission Issues

```bash
# Script won't execute
ls -l script.sh          # Check if execute bit is set
chmod +x script.sh       # Add execute permission

# Cannot access directory
ls -ld directory/        # Check directory permissions
chmod +x directory/      # Add execute permission

# Cannot create files in directory
ls -ld directory/        # Check write permission
chmod u+w directory/     # Add write permission for owner
```

#### Permission Checking Scripts

```bash
#!/bin/bash
check_permissions() {
    local file="$1"
    
    if [ ! -e "$file" ]; then
        echo "File does not exist: $file"
        return 1
    fi
    
    echo "Permissions for: $file"
    ls -l "$file"
    
    # Check specific permissions
    if [ -r "$file" ]; then echo "✓ Readable"; else echo "✗ Not readable"; fi
    if [ -w "$file" ]; then echo "✓ Writable"; else echo "✗ Not writable"; fi
    if [ -x "$file" ]; then echo "✓ Executable"; else echo "✗ Not executable"; fi
}
```

### Security Considerations

#### Best Practices

```bash
# Secure file permissions
chmod 600 ~/.ssh/id_rsa           # Private SSH keys
chmod 644 ~/.ssh/id_rsa.pub       # Public SSH keys
chmod 700 ~/.ssh/                 # SSH directory
chmod 644 ~/.ssh/authorized_keys  # Authorized keys file

# Web server security
find /var/www/ -type d -exec chmod 755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;
chown -R www-data:www-data /var/www/

# Database file security
chmod 600 database.db
chown mysql:mysql database.db
```

#### Permission Auditing

```bash
# Find files with specific permissions
find /home -type f -perm 777 2>/dev/null
find /etc -type f -perm -002 2>/dev/null  # World-writable files
find / -type f -perm -4000 2>/dev/null    # SUID files

# Find files owned by specific user
find / -user root -type f -perm -002 2>/dev/null

# Generate permission report
ls -laR /important/directory/ > permissions_audit.txt
```

**Key Points:**

- Principle of least privilege: Grant minimum necessary permissions
- Regular permission audits help identify security vulnerabilities
- SUID/SGID programs require careful security review
- World-writable files and directories pose security risks

The Linux permission system provides robust access control through its combination of basic permissions, numeric notation, symbolic operations, and ownership management, forming the foundation of system security and multi-user access control.

---

