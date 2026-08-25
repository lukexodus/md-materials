## User Creation and Privilege Management


### User Creation

**Overview**: Creating regular user accounts is essential for system security; running the system as root for daily tasks increases vulnerability to accidental damage or malicious attacks.[1][2]

#### Basic User Creation

**Command**: `useradd -m username`.[2][1]

**Parameters**:
*   **`-m`** (or **`--create-home`**): Creates a home directory at `/home/username`. Without this flag, the user account exists but has no home directory.[1][2]
*   **`username`**: The desired login name[1]

**Example**: `useradd -m john` creates a user named "john" with a home directory at `/home/john`.[2]

#### Automatic Group Creation

**Default Behavior**: When creating a user with `-m`, Arch Linux automatically creates a corresponding group with the same name and assigns it as the user's default group. This "User Private Group" approach is the preferred method, as it ensures newly created files are writable only by the owner by default.[1]

#### Setting User Password

**Password Command**: `passwd username`.[2][1]

**Example**: `passwd john` prompts for a new password, which must be entered twice for confirmation.[2]

**Security Note**: While not required, protecting every user account with a password is highly recommended.[1]

#### Combined Creation

**Single Command**: Users can be created with password in one command using `useradd -m -p "password_hash" username`.[3]

**Caveat**: This method accepts plain-text passwords or hashed passwords; plain-text passwords provide limited security compared to interactive password setting.[3]

#### Custom Home Directory

**Custom Path**: Use the `-d` flag to specify a non-standard home directory.[3]

**Example**: `useradd -d /var/custom_home john` creates user "john" with home directory at `/var/custom_home`.[3]

#### User Modification

**Modify Existing Users**: The `usermod` command changes user account properties.[2]

**Change Home Directory**: `usermod -d /new/home/path username`.[2]

**Add to Group**: `usermod -aG groupname username`. The `-a` flag appends without removing from other groups; `-G` specifies supplementary groups.[2]

#### User Deletion

**Delete User**: `userdel username` removes the user account. The home directory remains unless `-r` flag is used.[2]

**Delete User and Home**: `userdel -r username` removes the user account and home directory.[2]

### Privilege Management with sudo

**Overview**: Sudo allows non-root users to execute commands with elevated (root) privileges when authorized. This delegation enhances security by limiting root access while allowing necessary administrative tasks.[4]

#### sudo Installation

**Installation**: Sudo is installed by default as part of the base package group.[5][6]

**Verification**: Check sudo installation with `which sudo` or `pacman -Q sudo`.[4]

#### Wheel Group Configuration

**Purpose**: The `wheel` group is Arch Linux's designated group for sudo access. Users in this group can execute commands as root.[6][5]

**Add User to Wheel**: `usermod -aG wheel username`.[5][6]

**Verification**: Confirm membership with `groups username`; output should include "wheel".[6]

#### Sudoers File Configuration

**File Location**: `/etc/sudoers` controls sudo behavior and group permissions.[5]

**Editing**: Use `visudo` to safely edit the sudoers file.[6][5]

**Command**: `sudo visudo`.[5]

**Important Note**: Direct editing of `/etc/sudoers` with standard editors can introduce syntax errors that break sudo access. `Visudo` performs syntax validation before saving.[4][5]

#### Enabling Wheel Group

**Uncomment Line**: Within `visudo`, find and uncomment the following line:[5]

```
%wheel ALL=(ALL) ALL
```

This configuration enables all members of the wheel group to execute any command as any user (typically root).[6][5]

**Save**: Exit the editor and `visudo` automatically validates and saves changes.[5]

#### Verification

**Test sudo Access**: After configuration, test with `sudo whoami`.[6][5]

**Expected Output**: The command should return `root`, confirming sudo access is working.[5]

**First-Time sudo**: The first sudo command may prompt for a password; subsequent commands within a 5-minute timeout period do not require re-authentication.[4]

### Sudoers File Syntax

**Syntax Options**: The sudoers file supports various permission configurations.[4]

**Common Configurations**:

*   **`%wheel ALL=(ALL) ALL`**: Members execute any command as any user[5]
*   **`%wheel ALL=(ALL) NOPASSWD:ALL`**: Members execute without password prompts[4]
*   **`username ALL=(root) COMMAND`**: Specific user runs specific command as root[4]
*   **`username ALL=(ALL) NOPASSWD: /usr/bin/pacman`**: User runs pacman without password[4]

**Aliases**: For complex environments, sudoers supports user, host, command, and runas aliases for cleaner configuration.[4]

### Security Best Practices

**Least Privilege**: Grant users only the minimum privileges needed for their tasks.[4]

**Group-Based Access**: Use groups like wheel rather than configuring individual users for easier management.[6]

**Password Protection**: Encourage strong passwords for all user accounts, especially those with sudo access.[5]

**Audit Logging**: Sudo logs all command execution to `/var/log/auth.log`, enabling security audits.[4]

**NOPASSWD Caution**: Avoid `NOPASSWD` entries for potentially dangerous commands like pacman or rm.[4]

### User Account Information

**Display User Info**: `id username` displays user ID, group ID, and group membership.[1]

**List Groups**: `groups username` lists all groups the user belongs to.[6]

**User Database**: User information is stored in `/etc/passwd` (readable by all) and `/etc/shadow` (root-only, encrypted passwords).[1]

Sources
[1] Users and groups - ArchWiki https://wiki.archlinux.org/title/Users_and_groups
[2] How to create and manage user accounts on Arch Linux? https://www.tencentcloud.com/techpedia/100667
[3] How to Add a User on Arch Linux at Felipe's Blog https://freeshell.de/~felipe/blog/01/2024/linux/how-to-add-a-user-on-arch-linux/
[4] Sudo - ArchWiki https://wiki.archlinux.org/title/Sudo
[5] How to Create a Sudo User in Linux https://docs.vultr.com/how-to-create-a-sudo-user-in-linux
[6] How to Set Up `sudo` for a User on Arch Linux https://www.siberoloji.com/how-to-set-up-sudo-for-a-user-on-arch-linux/
[7] Adding a user with sudo privileges to Arch. : r/linuxquestions https://www.reddit.com/r/linuxquestions/comments/c1dp5f/adding_a_user_with_sudo_privileges_to_arch/
[8] How do i add my user to sudoers? https://bbs.archlinux.org/viewtopic.php?id=236848

