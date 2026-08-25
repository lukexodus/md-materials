## Filesystem Permissions and ACLs


### Unix Filesystem Permissions Overview

**Foundation**: Traditional Unix permission model.[1]

**Components**:[1]
- Owner (user)[1]
- Group[1]
- Others (everyone else)[1]

**Permission Types**:[1]
- Read (r) = 4[1]
- Write (w) = 2[1]
- Execute (x) = 1[1]

### Understanding Permissions

#### Permission Display

**ls Output**:[1]

```
-rw-r--r-- 1 user group 1234 Jan 1 12:00 file.txt
```

**Breakdown**:[1]
- `-`: Regular file[1]
- `rw-`: Owner permissions (6)[1]
- `r--`: Group permissions (4)[1]
- `r--`: Others permissions (4)[1]

**Directory Permissions**:[1]

```
drwxr-xr-x 2 user group 4096 Jan 1 12:00 directory
```

- `d`: Directory[1]
- `rwx`: Owner can read/write/enter[1]
- `r-x`: Group can read/enter[1]
- `r-x`: Others can read/enter[1]

#### Execute Permission Meaning

**Files**: Execute as program.[1]

**Directories**: Enter directory, access contents.[1]

**Critical**: Users need `x` on parent directories.[1]

### Changing Permissions

#### chmod Command

**Numeric Mode**:[1]

```bash
chmod 755 script.sh
```

**Breakdown**:[1]
- `7` (user): rwx[1]
- `5` (group): r-x[1]
- `5` (others): r-x[1]

**Common Permissions**:[1]
- `755`: rwxr-xr-x (executable)[1]
- `644`: rw-r--r-- (regular file)[1]
- `700`: rwx------ (private)[1]
- `777`: rwxrwxrwx (open)[1]

**Symbolic Mode**:[1]

```bash
chmod u+x file.txt        # Add execute for user
chmod g-w file.txt        # Remove write from group
chmod o=r file.txt        # Set others to read only
chmod a+r file.txt        # Add read for all
```

**Recursive**:[1]

```bash
chmod -R 755 directory/
```

**Directories Only**:[1]

```bash
chmod -R u=rwx,g=rx,o=rx directory/
```

#### chmod Examples

**Make Script Executable**:[1]

```bash
chmod +x script.sh
```

**Secure Private File**:[1]

```bash
chmod 600 private.key
```

**Web Server Directory**:[1]

```bash
chmod 755 /var/www/html
chmod 644 /var/www/html/*.html
```

### Changing Ownership

#### chown Command

**Change User**:[1]

```bash
sudo chown newuser file.txt
```

**Change User and Group**:[1]

```bash
sudo chown user:group file.txt
```

**Recursive**:[1]

```bash
sudo chown -R user:group directory/
```

**Only Group**:[1]

```bash
sudo chown :newgroup file.txt
```

#### chgrp Command

**Change Group**:[1]

```bash
sudo chgrp newgroup file.txt
```

**Recursive**:[1]

```bash
sudo chgrp -R newgroup directory/
```

### Default Permissions

#### umask

**Current Mask**:[1]

```bash
umask
```

**Output**: Four digits (usually 0022).[1]

**Calculation**:[1]
- Files: 666 - umask = default permissions[1]
- Directories: 777 - umask = default permissions[1]

**Example**:[1]
- umask 0022[1]
- Files: 666 - 022 = 644 (rw-r--r--)[1]
- Directories: 777 - 022 = 755 (rwxr-xr-x)[1]

#### Set umask

**Temporary**:[1]

```bash
umask 0077  # Only user can access (600/700)
```

**Persistent**: Edit `~/.bashrc`:[1]

```bash
umask 0077
```

or `/etc/profile` for system-wide:[1]

```bash
umask 0022
```

#### umask Effects

**Restrictive umask** (0077):[1]
- Files: 600[1]
- Directories: 700[1]
- Private by default[1]

**Open umask** (0022):[1]
- Files: 644[1]
- Directories: 755[1]
- World-readable[1]

### Access Control Lists (ACLs)

#### ACL Concept

**Beyond Basic Permissions**: Fine-grained access control.[1]

**Advantages**:[1]
- Multiple users and groups[1]
- Default rules for new files[1]
- Specific permission combinations[1]

**Filesystem Support**: ext4, Btrfs, XFS.[1]

#### Check ACL Support

**Verify Mounting**:[1]

```bash
mount | grep acl
```

**Expected**: `acl` in options.[1]

**Enable ACL**:[1]

In `/etc/fstab`:

```
/dev/sda1 / ext4 defaults,acl 0 1
```

Remount filesystem:[1]

```bash
sudo mount -o remount,acl /
```

### Setting ACLs

#### getfacl Command

**View Current ACL**:[1]

```bash
getfacl file.txt
```

**Output Example**:[1]

```
# file: file.txt
# owner: user
# group: group
user::rw-
group::r--
other::r--
```

#### setfacl Command

**Add User ACL**:[1]

```bash
setfacl -m u:username:rw file.txt
```

**Add Group ACL**:[1]

```bash
setfacl -m g:groupname:rx file.txt
```

**Add Multiple**:[1]

```bash
setfacl -m u:user1:rw,u:user2:r,g:admin:rwx file.txt
```

**Recursive**:[1]

```bash
setfacl -R -m u:username:rwx directory/
```

#### ACL Examples

**Grant User Write Access**:[1]

```bash
setfacl -m u:john:rw document.txt
```

**Grant Group Read**:[1]

```bash
setfacl -m g:developers:rx script.sh
```

**Grant Execute for Directory**:[1]

```bash
setfacl -m u:john:rx directory/
```

### Default ACLs

**For New Files**: Default ACL defines permissions.[1]

**Set Default**:[1]

```bash
setfacl -d -m u:john:rw directory/
```

**Verify Default**:[1]

```bash
getfacl directory/
```

**Shows**:[1]
- Access ACL (current)[1]
- Default ACL (new files)[1]

### Removing ACLs

#### Remove Specific ACL

**Remove User**:[1]

```bash
setfacl -x u:username file.txt
```

**Remove Group**:[1]

```bash
setfacl -x g:groupname file.txt
```

#### Clear All ACLs

**Remove All**:[1]

```bash
setfacl -b file.txt
```

**Recursive**:[1]

```bash
setfacl -R -b directory/
```

**Reset to Defaults**:[1]

```bash
setfacl -b file.txt
chmod 644 file.txt
```

### Special Permissions

#### Setuid (Set User ID)

**Purpose**: Execute as file owner.[1]

**Numeric**: Add 4 to first digit:[1]

```bash
chmod 4755 script.sh
```

**Display**:[1]

```
-rwsr-xr-x
```

`s` replaces user execute.[1]

**Use Case**:[1]
- `passwd` command[1]
- `sudo`[1]

**Security Risk**: Minimize usage.[1]

#### Setgid (Set Group ID)

**Purpose**: Execute as group owner.[1]

**Numeric**: Add 2 to first digit:[1]

```bash
chmod 2755 directory/
```

**Display**:[1]

```
drwxr-sr-x
```

`s` replaces group execute.[1]

**Directory Effect**: New files inherit group.[1]

#### Sticky Bit

**Purpose**: Only owner can delete files.[1]

**Numeric**: Add 1 to first digit:[1]

```bash
chmod 1777 /tmp
```

**Display**:[1]

```
drwxrwxrwt
```

`t` replaces others execute.[1]

**Use Case**:[1]
- Shared directories `/tmp`[1]
- Prevent accidental deletion[1]

### Practical Permission Scenarios

#### Web Server Setup

**Directory Permissions**:[1]

```bash
sudo chmod 755 /var/www/html
```

**File Permissions**:[1]

```bash
sudo chmod 644 /var/www/html/*.html
sudo chmod 644 /var/www/html/*.css
sudo chmod 755 /var/www/html/*.php
```

**Uploaded Files**:[1]

```bash
sudo chown -R www-www-data /var/www/html/uploads
sudo chmod 775 /var/www/html/uploads
```

#### Source Code Repository

**Private Access**:[1]

```bash
chmod 700 .git
chmod 600 .git/config
```

**Team Collaboration**:[1]

```bash
chmod 755 .git
setfacl -m g:developers:rwx .git
chmod 644 .gitignore
```

#### Home Directory Security

**Private Home**:[1]

```bash
chmod 700 ~
```

**Shared Folders**:[1]

```bash
chmod 750 ~/shared
setfacl -m g:friends:rx ~/shared
```

#### Configuration Files

**System Config**:[1]

```bash
sudo chmod 644 /etc/config
```

**Sensitive Config**:[1]

```bash
sudo chmod 600 /etc/secret-config
```

**Root-Only**:[1]

```bash
sudo chmod 700 /root/.ssh
sudo chmod 600 /root/.ssh/id_rsa
```

### Permission Troubleshooting

#### Permission Denied Errors

**Issue**: Cannot access file.[1]

**Check Permissions**:[1]

```bash
ls -la file.txt
```

**Fix**:[1]

```bash
chmod 644 file.txt  # If should be readable
chmod +r file.txt   # Add read permission
```

#### Cannot Execute Script

**Issue**: "Permission denied" when running.[1]

**Check**:[1]

```bash
ls -la script.sh
```

**Fix**:[1]

```bash
chmod +x script.sh
```

#### Directory Access Issues

**Issue**: Cannot enter directory.[1]

**Cause**: No execute permission on directory.[1]

**Fix**:[1]

```bash
chmod u+x directory/
```

#### ACL Not Working

**Issue**: ACL rule not effective.[1]

**Check Mounting**:[1]

```bash
mount | grep acl
```

**Enable**:[1]

```bash
sudo mount -o remount,acl /
```

### Best Practices

**Principle of Least Privilege**: Only necessary permissions.[1]

**Regular Audits**: Review file permissions:[1]

```bash
find / -perm 777 2>/dev/null
find / -perm 4000 2>/dev/null
```

**Secure Critical Files**:[1]
- SSH keys: 600[1]
- Home directory: 700[1]
- Configuration: 644[1]

**Use ACLs Judiciously**: Simplify when possible.[1]

**Document Changes**: Record why permissions set.[1]

**Test Permissions**: Verify intended users can access.[1]

**Avoid World-Writable**: Except `/tmp`.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman

