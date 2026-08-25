## Permission Formats


Linux file permissions can be represented in several formats that help to understand and manage access control. The main permission formats are:

### 1. Symbolic Notation (Text format)
- Permissions are shown as a string of characters like `-rwxr-xr--`.
- The first character indicates the file type:
  - `-` for regular file
  - `d` for directory
  - `l` for symbolic link, etc.
- The next nine characters are grouped into three sets of three:
  - User (owner) permissions: `rwx` (read, write, execute)
  - Group permissions: `r-x`
  - Others (world) permissions: `r--`
- Characters meanings:
  - `r` = read permission
  - `w` = write permission
  - `x` = execute permission
  - `-` = no permission
- Additional letters like `s` or `t` may appear for special permissions like SUID, SGID, and sticky bit.

Example: `-rwxr-xr--` means owner can read, write, execute; group can read and execute; others can read only.

***

### 2. Octal (Numeric) Notation
- Uses numbers to represent permissions.
- Each permission type is assigned a numeric value:
  - Read = 4
  - Write = 2
  - Execute = 1
- For each of user, group, and others, sum the values for granted permissions.
- Permissions are written as three digits (or four, if special bits included), e.g., `755`.
- The digits represent user, group, and others respectively.

Example:
- `7` (4+2+1) = read, write, execute
- `5` (4+0+1) = read, execute
- `4` = read only

So `755` means user has `rwx`, group has `r-x`, others have `r-x`.

***

### 3. Special Permissions in Numeric Notation (4-digit)
- The first digit denotes special permissions:
  - 4 = SUID
  - 2 = SGID
  - 1 = Sticky bit
- The next three digits represent normal permissions for user, group, and others.

Example:
- `4755` means SUID bit set + normal permissions `755`.

***

### 4. Symbolic Mode for Changing Permissions
- Used with `chmod` commands.
- Format is `[ugoa][+-=][rwx]`
  - `u` = user, `g` = group, `o` = others, `a` = all
  - `+` adds permission, `-` removes permission, `=` sets exact permission
- Examples:
  - `chmod u+x file` adds execute permission to the user.
  - `chmod go-w file` removes write permission from group and others.
  - `chmod a=r file` sets read-only permission for all.

"others" refers to all users who are not the owner of the file and are not members of the group that owns the file.

***

### Summary Table of Formats

| Format            | Example           | Explanation                                |
|-------------------|-------------------|--------------------------------------------|
| Symbolic notation | `-rwxr-xr--`      | Read, write, execute for owner; r-x for group; r for others |
| Octal notation    | `755`             | Numeric summation of permissions per user/group/others |
| Special bits + Octal | `4755`           | SUID + normal permissions                   |
| Symbolic chmod    | `u+x`, `go-w`     | Modifying permissions using descriptive letters and symbols |

These permission formats are fundamental for Linux file security and system administration, allowing clear control over who can read, write, or execute files and directories.

