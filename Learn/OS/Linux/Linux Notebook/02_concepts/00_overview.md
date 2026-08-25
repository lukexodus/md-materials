## Overview


### Root User vs Non-root User

In Linux, there is a significant difference between using the **root user** and a **non-root user**, primarily in terms of **permissions**, **security**, and **system administration**. Here’s an overview:

---

**Root User**

The **root user** is the system's superuser and has unrestricted access to all files, commands, and resources on the system. It is intended for administrative tasks.

**Characteristics of Root User:**

1. **Full Permissions**:
    - The root user can read, write, and execute any file or command, even those that other users are restricted from accessing.
2. **System Administration**:
    - Tasks such as installing or updating software, configuring system-wide settings, managing other users, and modifying system files (e.g., `/etc`, `/usr`, `/var`) require root privileges.
3. **Command Prompt**:
    - The prompt for the root user typically ends with a `#` (e.g., `root@hostname:#`), distinguishing it from non-root users whose prompt ends with `$`.
4. **Security Risks**:
    - Since the root user has unrestricted permissions, any mistakes (like deleting system files or misconfiguring critical services) can severely harm the system.
    - Unauthorized access to the root account can compromise the entire system.
5. **Examples of Tasks Requiring Root**:
    - Modifying system files: `vim /etc/hostname`
    - Managing services: `systemctl restart nginx`
    - Installing software: `dnf install apache2`
    - Creating new users: `useradd john`

---

**Non-Root Users**

Non-root users are regular users with limited privileges, intended for everyday use. They are restricted from performing administrative or system-critical tasks unless explicitly granted permissions.

**Characteristics of Non-Root Users:**

1. **Limited Permissions**:
    
    - Non-root users can only modify files they own or have been given permission to access.
    - They cannot install software, manage services, or modify system files.
2. **Security**:
    
    - Non-root users are safer for daily tasks because they limit the risk of accidentally harming the system.
    - If a non-root user’s account is compromised, the damage is limited to that user’s files and processes.
3. **Command Prompt**:
    
    - The prompt for non-root users usually ends with a `$` (e.g., `username@hostname:$`).
4. **Examples of Tasks Performed by Non-Root Users**:
    
    - Creating or editing files in their home directory (`~/`): `vim myfile.txt`
    - Running personal scripts or applications: `./myscript.sh`
    - Using software: `firefox`
    - Managing user-specific settings and preferences.

---

**Switching Between Root and Non-Root Users**

1. **Switching to Root User**:
    
    - You can switch to the root user using the `su` (substitute user) command:
        
        ```bash
        su -
        ```
        
        Enter the root password when prompted.
        
    - Alternatively, you can execute a command as root using `sudo`:
        
        ```bash
        sudo <command>
        ```
        
        This temporarily grants root privileges to a non-root user (if the user is authorized in `/etc/sudoers`).
        
2. **Switching to a Non-Root User**:
    
    - As the root user, you can switch to another user:
        
        ```bash
        su - <username>
        ```
        

---

**Advantages of Using Non-Root Users**

1. **Security**:
    - Non-root users limit the risk of accidental or intentional system-wide damage.
    - If a non-root account is compromised, the attacker’s access is limited to that user’s files and processes.
2. **Best Practice**:
    - For day-to-day activities like browsing, coding, or running applications, it is recommended to use a non-root user.
    - Only switch to root when necessary (e.g., for administrative tasks).

---

**Advantages of Using Root**

1. **Full System Control**:
    - The root user can perform any task without restrictions, making it essential for system administration and troubleshooting.
2. **Efficiency**:
    - Root privileges allow you to execute administrative commands without needing to prepend `sudo` or adjust permissions.

---

**Risks of Always Using Root**

1. **Accidental Mistakes**:
    - A simple command like `rm -rf /` can wipe the entire system if run as root.
    - Misconfigurations can lead to system instability or failure.
2. **Security Vulnerability**:
    - If you are logged in as root and leave your session open, it creates a significant security risk.
    - Malware or unauthorized users could exploit root privileges to harm the system.

---

**Best Practices**

1. **For Root**:
    - Only use the root account when absolutely necessary.
    - Use `sudo` for one-off administrative tasks instead of switching to the root user entirely.
    - Always log out of the root session when done.
2. **For Non-Root Users**:
    
    - Use a non-root account for day-to-day activities.
    - Grant specific permissions (via `sudo`) to non-root users if they need limited administrative access.

---

**Summary Table: Root vs. Non-Root Users**

|Feature|Root User|Non-Root User|
|---|---|---|
|**Permissions**|Full, unrestricted access|Limited to user-owned files/processes|
|**Prompt Symbol**|`#`|`$`|
|**Use Case**|System administration tasks|Day-to-day activities|
|**Security Risk**|High|Low|
|**Typical Commands**|Managing services, editing system files|Running apps, creating/editing personal files|

For maximum security and stability, use a non-root user for most activities and switch to root only when necessary.

### Login Shells vs Non-Login Shells

When working with the Bash shell in Linux, it's important to understand the distinction between **login shells** and **non-login shells**. Each type of shell has different behaviors and uses, which can affect how your environment is set up.

**Login Shells**

- **Definition**: A login shell is initiated when a user logs into the system. This can occur through a terminal login, SSH session, or when starting a terminal emulator that is configured to act as a login shell.
- **Characteristics**:
    - It reads specific configuration files to set up the environment. For Bash, this typically includes `/etc/profile` and `~/.bash_profile`, `~/.bash_login`, or `~/.profile` if the former files do not exist
- The shell is usually indicated by a dash in the process name (e.g., `-bash`), which signifies that it is a login shell
- **Use Cases**: Login shells are used to establish the user environment upon logging in, setting up environment variables, paths, and other configurations necessary for the user session.

**Non-Login Shells**

- **Definition**: A non-login shell is started without a user logging in. This typically occurs when you open a new terminal window or tab in a graphical environment.
- **Characteristics**:
    - Non-login shells read the `~/.bashrc` file for configuration settings, which is where you typically define aliases, functions, and shell options
    - They do not read the login-specific files like `.bash_profile` or `.profile`.
- **Use Cases**: Non-login shells are useful for interactive tasks where you want to use predefined commands and settings without needing to re-establish the entire environment.

**Key Differences**

- **Execution Context**: Login shells are for user login sessions, while non-login shells are for interactive sessions initiated after login.
- **Configuration Files**: Login shells read from files like `.bash_profile`, whereas non-login shells read from `.bashrc`.

Understanding these differences helps in configuring your shell environment effectively, ensuring that the right settings are applied in the appropriate contexts!

#### `.profile`, `.bash_profile`, and `.bashrc`

When working with the Bash shell in Linux, you may encounter several configuration files that help customize your shell environment. Here’s a breakdown of the three main files: **`.profile`**, **`.bash_profile`**, and **`.bashrc`**.

**1. .profile**

- **Purpose**: The `.profile` file is a shell script that is executed for login shells. It is used to set environment variables and execute commands that should run at the start of a user session.
- **Usage**: This file is typically used in systems where Bash is not the default shell. It can be used by other shells as well, making it a more universal option for setting up the environment.

**2. .bash_profile**

- **Purpose**: The `.bash_profile` file is specific to Bash and is executed when Bash is invoked as an interactive login shell. This means it runs when you log in to your system or start a new terminal session that requires a login.
- **Usage**: It is common to use `.bash_profile` to set environment variables and to source `.bashrc` to ensure that the configurations in `.bashrc` are also applied in login shells

**3. .bashrc**

- **Purpose**: The `.bashrc` file is executed for interactive non-login shells. This means it runs when you open a new terminal window or tab, but not when you log in.
- **Usage**: This file is typically used for setting shell options, aliases, and functions that you want available in every interactive shell session

**Key Differences**

- **Execution Context**:
    - `.bash_profile` is for login shells, while `.bashrc` is for non-login shells.
    - `.profile` can be used by various shells, while `.bash_profile` is specific to Bash.
- **Common Practice**: It is common to have `.bash_profile` source `.bashrc` to ensure that all configurations are loaded regardless of how the shell is started. This can be done by adding the following line to your `.bash_profile`:

```bash
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
```

By understanding these files, you can effectively customize your Bash environment to suit your needs!

### Inodes

Inodes, short for "index nodes," are data structures in Unix-like file systems that store metadata about files and directories. Each file and directory on a Unix-like file system is represented by an inode. Inodes contain information such as:

1. **File ownership**: The user and group associated with the file.
2. **File permissions**: The access permissions for the file (read, write, execute) for the owner, group, and others.
3. **File size**: The size of the file in bytes.
4. **File timestamps**: The timestamps indicating when the file was created, last accessed, and last modified.
5. **File type**: Whether the inode represents a regular file, directory, symbolic link, device file, etc.
6. **File data location**: Pointers to the actual data blocks on the disk where the file's content is stored.

Inodes are crucial for the file system's management and operation. They allow the operating system to efficiently locate and manage files and directories on the disk. The number of inodes allocated to a file system at its creation determines the maximum number of files and directories that can be stored on that file system.

When a file system is created, a fixed number of inodes are allocated based on the file system's size and the expected number of files. If a file system runs out of available inodes, it cannot create additional files or directories, even if there is free space available on the disk.

Therefore, monitoring inode usage is important, especially on systems where a large number of small files or directories are expected. The `df -i` command displays inode usage statistics for each mounted file system, helping administrators assess inode utilization and plan storage accordingly.

### Hard Links

Hard links allow multiple directory entries (file names) to point to the same inode, which represents the data blocks of a file. Unlike symbolic links, which are separate files containing the path to the target file, hard links directly reference the inode of the target file.

1. **Same Inode**: Hard links share the same inode number as the original file. Each file name pointing to the same inode is considered a hard link to the file.
    
2. **Link Count**: The number of hard links to a file is stored as metadata in the inode. This link count is incremented each time a new hard link is created and decremented each time a hard link is deleted.
    
3. **Location**: Hard links can only exist within the same filesystem as the target file. They cannot cross filesystem boundaries.
    
4. **File Deletion**: When a file is deleted, its inode and data blocks are only released when the link count reaches zero. Deleting one hard link does not remove the file's contents as long as other hard links to the file exist.
    
5. **File Content**: All hard links to a file share the same content on disk. Changes made to one hard link are reflected in all other hard links to the same file because they all point to the same inode and data blocks.
    
6. **Creation**: Hard links can be created using the `ln` command without any options. For example:
    
    `ln /path/to/original /path/to/hardlink`
    
7. **Indication**: When listing files with `ls -l`, hard links display the number of hard links to the file in the second column
	![[Pasted image 20240207174956.png]]
	The original file is essentially considered as a hard link itself. Files are represented by inodes, which contain metadata about the file and a reference to the actual data blocks on disk. When you create a hard link to a file, you're essentially creating a new directory entry (filename) that points to the same inode as the original file.
    
8. **Usage**: Hard links are commonly used for managing versions of files, and efficiently sharing data between multiple locations without duplicating disk space.

```shell
$ echo "Hello, world!" > original.txt
$ ln original.txt hardlink.txt`
```

In this example, `original.txt` and `hardlink.txt` are hard links to the same file. Both files share the same inode and data blocks, so any changes made to one file are reflected in the other file.

#### Copying Files vs Making Hard Links

1. **Copying Files**:
    - **Purpose**: Copying files creates new, independent copies of the original files.
    - **Implications**:
        - Each copy is a separate file with its own inode, metadata, and data blocks.
        - Changes made to one copy do not affect other copies.
        - Requires additional disk space proportional to the size of the copied files.
        - Suitable for creating backups, distributing files, and modifying files independently.
2. **Making Hard Links**:
    - **Purpose**: Creating hard links establishes multiple directory entries (filenames) that point to the same inode (file).
    - **Implications**:
        - All hard links to the same file share the same inode, metadata, and data blocks.
        - Changes made to one hard link are reflected in all other hard links since they all point to the same underlying data.
        - Does not consume additional disk space (except for directory entries).
        - Deleting any hard link does not immediately delete the file; the file is only removed when all hard links are deleted.
        - Suitable for creating multiple access points to the same data, maintaining versioning systems, and conserving disk space.

### Symblic Links

Symbolic links, also known as soft links, are special files in Unix-like operating systems that serve as pointers or references to other files or directories. They act as shortcuts, allowing users to create links to files or directories located anywhere in the filesystem.

1. **Type**: Symbolic links are files themselves, distinct from the target file or directory they point to.
    
2. **Structure**: Symbolic links contain the path to the target file or directory. This path can be absolute (starting from the root directory) or relative to the location of the symbolic link.
    
3. **Location**: Symbolic links can reside on the same filesystem as the target or on different filesystems.
    
4. **Creation**: Symbolic links can be created using the `ln -s` command. The `-s` option indicates that a symbolic link should be created. For example:
    
    `ln -s /path/to/target /path/to/symlink`
    
5. **Indication**: When listing files with `ls -l`, symbolic links are denoted by an "l" as the first character in the file permissions column.
	![[Pasted image 20240208093538.png]]
    
6. **Symbolic Link Resolution**: When a program accesses a symbolic link, the operating system resolves the link to its target file or directory and accesses the content of the target.
    
7. **Modification and Deletion**: Symbolic links can be easily modified or deleted without affecting the target file or directory. If the target of a symbolic link is deleted, the link becomes a dangling symbolic link. The symbolic link itself remains intact in the filesystem. It's essentially just a small file containing the path to the original file.
    
8. **Use Cases**: Symbolic links are commonly used for creating aliases, managing shared resources, simplifying directory structures, and referencing files or directories that may change location.
    
9. **Example**: Suppose you have a file named `file.txt` located in `/home/user/documents`, and you want to create a symbolic link to it in your home directory. You can create the symbolic link with the following command:
    
    `ln -s /home/user/documents/file.txt ~/file-link`
    
    This creates a symbolic link named `file-link` in your home directory that points to `file.txt`.

Symbolic links were created to overcome the limitations of hard links.
They work by creating a special type of file that contains a text pointer
to the referenced file or directory.

### Hard Links vs Soft Links

1. **Hard Links**:
    - **Usage**:
        - Hard links create additional directory entries (file names) that point directly to the inode of the original file.
        - They provide multiple access points to the same physical data on disk.
        - Changes made to any hard link are reflected in all other hard links since they all point to the same inode.
    - **Features**:
        - Cannot link directories or across filesystems.
        - Cannot link special files or device files.
        - Can be used to create backups and versioning systems where multiple links point to the same data.
        - They cannot link directories or non-regular files.
        - They don't have permissions of their own; they inherit the permissions of the original file.
        - Deleting a hard link does not affect the other hard links or the original file as long as there are still existing hard links.
2. **Symbolic Links (Soft Links)**:
    - **Usage**:
        - Symbolic links are pointers to the path of the original file or directory.
        - They act as shortcuts or aliases to the target file or directory.
        - They can link directories, files across filesystems, and non-existent files or directories.
        - Symbolic links can point to directories, special files, or regular files.
    - **Features**:
        - Can link directories, special files, and across filesystems.
        - They are more flexible but less efficient than hard links.
        - Symbolic links can be created without needing write access to the target file.
        - Changes in the original file name or location do not affect (update) symbolic links unless they are relative and the path changes.
        - Deleting a symbolic link does not affect the target file or directory.

***

### Wildcards

#### Wildcards

**`*` (asterisk)**: Matches zero or more characters.
    - Example: `ls *.txt` matches all files with the `.txt` extension in the current directory.
**`?` (question mark)**: Matches exactly one character.
    - Example: `ls file?.txt` matches files like `file1.txt`, `file2.txt`, etc., but not `file.txt` or `file12.txt`.
**`[ ]` (square brackets)**: Matches any one of the characters enclosed in the brackets.
    - Example: `ls file[123].txt` matches `file1.txt`, `file2.txt`, or `file3.txt`, but not `file4.txt`.
**`{ }` (curly braces)**: Matches any of the comma-separated patterns inside the braces.
    - Example: `ls {*.txt,*.pdf}` matches all files with either the `.txt` or `.pdf` extension.
**`!` (exclamation mark)**: Negates a pattern, matching anything not specified by the pattern.
    - Example: `ls !(*.txt)` matches all files except those with the `.txt` extension.
**`**` (double asterisk)**: Matches zero or more directories and subdirectories.
    - Example: `ls /path/**/*.txt` matches all `.txt` files in `/path` and its subdirectories recursively.
**`+` (plus sign)**: Matches one or more occurrences of the preceding character or group.
    - Example: `ls file+.txt` matches `file.txt`, `filee.txt`, `fileee.txt`, etc., but not `file.txt`.
**`()` (parentheses)**: Groups patterns together.
    - Example: `ls {file,dir}*.txt` matches files and directories that start with `file` or `dir` and have a `.txt` extension.
**`^` (caret)**: Matches the beginning of a line in certain contexts.
    - Example: `grep '^start' file.txt` matches lines that start with `start` in `file.txt`.
**`$` (dollar sign)**: Matches the end of a line in certain contexts.
    - Example: `grep 'end$' file.txt` matches lines that end with `end` in `file.txt`.
**`|` (pipe)**: Represents a logical OR in certain contexts, such as regular expressions.
    - Example: `grep 'pattern1\|pattern2' file.txt` matches lines that contain either `pattern1` or `pattern2` in `file.txt`.
**`?()` (extended globbing)**: Provides more advanced pattern matching capabilities. It's often enabled by the `extglob` shell option in Bash.
    - Example: `ls !(pattern)` matches all files except those that match the pattern.
**`[!...]` (negation in character classes)**: Matches any character not listed within the square brackets.
    - Example: `[!aeiou]` matches any character that is not a vowel.
**`@(pattern|pattern)` (extended globbing)**: Matches one of the given patterns.
    - Example: `ls @(file|dir)*.txt` matches files or directories that start with either `file` or `dir` and have a `.txt` extension.
**`?(pattern)` (extended globbing)**: Matches zero or one occurrence of the given pattern.
    - Example: `ls file?(1).txt` matches files like `file.txt` and `file1.txt`, but not `file11.txt`.
**`*(pattern)` (extended globbing)**: Matches zero or more occurrences of the given pattern.
    - Example: `ls file*(1).txt` matches files like `file.txt`, `file1.txt`, `file11.txt`, etc.
 **`!(pattern)`**: Matches anything except the given pattern. This is part of extended globbing and needs to be enabled with `shopt -s extglob` in Bash.
    - Example: `ls !(file*.txt)` matches all files except those starting with `file` and ending with `.txt`.
 **`+(pattern)`**: Matches one or more occurrences of the given pattern.
    - Example: `ls file+(1).txt` matches files like `file1.txt` and `file11.txt`, but not `file.txt`.

#### Character Classes

1. **Square Brackets `[ ]`**: Square brackets are used to define a character class. Inside the brackets, you specify the characters you want to match.
    - Example: `[aeiou]` matches any single lowercase vowel.
    - Example: `[0-9]` matches any single digit from 0 to 9.
    - Example: `[a-zA-Z]` matches any single uppercase or lowercase letter.
2. **Negation `^`**: When `^` is used at the beginning of a character class, it negates the match and matches any character not listed within the brackets.
    - Example: `[^0-9]` matches any character that is not a digit.
    - Example: `[^aeiou]` matches any character that is not a lowercase vowel.
3. **Character Ranges `-`**: You can specify a range of characters using the hyphen `-` inside a character class.
    - Example: `[a-z]` matches any lowercase letter from a to z.
    - Example: `[A-Z]` matches any uppercase letter from A to Z.
    - Example: `[0-9]` matches any digit from 0 to 9.
4. **Combining Character Classes**: You can combine multiple character classes and ranges within the same set of square brackets.
    - Example: `[a-zA-Z0-9]` matches any alphanumeric character.
    - Example: `[aeiouAEIOU]` matches any lowercase or uppercase vowel.
5. **Escaping Special Characters**: Some characters, such as `^`, `-`, and `]`, have special meanings within character classes. To match these characters literally, you need to escape them with a backslash `\`.
    - Example: `[-+*/]` matches any of the characters `-`, `+`, `*`, or `/`.
    - Example: `[0-9^]` matches any digit from 0 to 9 or the caret `^`.
6. **Predefined Character Classes**: Many regex engines provide shorthand notations for commonly used character classes.
- `\d`: Matches any digit character (equivalent to `[0-9]`).
- `\D`: Matches any non-digit character (equivalent to `[^0-9]`).
- `\w`: Matches any word character (letters, digits, or underscore).
- `\W`: Matches any non-word character (anything not matched by `\w`).
- `\s`: Matches any whitespace character (space, tab, newline).
- `\S`: Matches any non-whitespace character.


**Examples:**

1. `*`: Matches all files.
2. `g*`: Matches any file beginning with `g`.
3. `b*.txt`: Matches any file beginning with `b` followed by any characters and ending with `.txt`.
4. `Data???`: Matches any file beginning with `Data` followed by exactly three characters.
5. `[abc]*`: Matches any file beginning with either an `a`, a `b`, or a `c`.
6. `BACKUP.[0-9][0-9][0-9]`: Matches any file beginning with `BACKUP.` followed by exactly three numerals.
7. `[[:upper:]]*`: Matches any file beginning with an uppercase letter.
8. `[![:digit:]]*`: Matches any file not beginning with a numeral.
9. `*[[:lower:]123]`: Matches any file ending with a lowercase letter or the numerals 1, 2, or 3.

### Regular Expressions (regex)

1. **Literals**:
    - Literal characters match themselves in the text being searched.
2. **Metacharacters**:
    - `.`, `*`, `+`, `?`, `^`, `$`, `\`, `[`, `]`, `(`, `)`, `{`, `}`, `|`
3. **Character Classes**:
    - `[abc]`: Matches 'a', 'b', or 'c'.
    - `[0-9]`: Matches any digit from 0 to 9.
    - `[^abc]`: Negation, matches any character except 'a', 'b', or 'c'.
4. **Quantifiers**:
    - `*`: Matches zero or more occurrences.
    - `+`: Matches one or more occurrences.
    - `?`: Matches zero or one occurrence.
    - `{n}`: Matches exactly n occurrences.
    - `{n,}`: Matches at least n occurrences.
    - `{n,m}`: Matches between n and m occurrences.
5. **Anchors**:
    - `^`: Matches the beginning of a line.
    - `$`: Matches the end of a line.
6. **Grouping**:
    - `()`: Groups parts of a regex together.
    - `(?:)`: Non-capturing group.
7. **Alternation**:
    - `|`: Alternation, matches either of two patterns.
8. **Escape Sequences**:
    - `\`: Escapes metacharacters to match them literally.
    - `\d`: Matches any digit (equivalent to `[0-9]`).
    - `\w`: Matches any word character (letters, digits, underscore).
    - `\s`: Matches any whitespace character (space, tab, newline).
	- `\t`: Tab character.
	- `\n`: Newline character.
	- `\r`: Carriage return character.
	- `\xhh`: Character with hexadecimal code `hh`.
	- `\uhhhh`: Unicode character with hexadecimal code `hhhh`.
9. **Boundary Matchers**:
	1. **Word Boundary (\b)**:
	    - `\b` asserts a position where a word character (alphanumeric or underscore) is not followed or preceded by another word character.
	    - Example: `\bapple\b` matches "apple" but not "pineapple" or "apples".
	2. **Non-Word Boundary (\B)**:
	    - `\B` asserts a position where a word character is followed or preceded by another word character.
	    - Example: `\Bapple\B` matches "pineapple" but not "apple" or "apples".
	3. **String Start (\A)**:
	    - `\A` matches the start of the input string.
	    - Example: `\Aapple` matches "apple" at the very beginning of the string.
	4. **String End (\Z)**:
	    - `\Z` matches the end of the input string or before a newline at the end.
	    - Example: `apple\Z` matches "apple" at the very end of the string.
	5. **String End Before Final Line Break (\z)**:
	    - `\z` matches only at the very end of the input string.
	    - Example: `apple\z` matches "apple" only at the very end of the string, not before any newline.
10. **Flags**:
    - `i`: Case-insensitive matching.
    - `g`: Global matching (find all matches, not just the first).
    - `m`: Multi-line matching (treats beginning and end characters (^ and $) as working across multiple lines).
    - `s`: Single-line mode, changes behavior of `.` to match any character, including newline.
	- `x`: Extended mode, ignores whitespace and allows comments within the pattern.
11. **Lookahead and Lookbehind Assertions**:
	1. **Positive Lookahead (?=...)**:
	    - `(?=...)` asserts that the pattern inside the lookahead must match immediately ahead of the current position.
	    - Example: `foo(?=bar)` matches "foo" only if it is followed by "bar".
	2. **Negative Lookahead (?!...)**:
	    - `(?!...)` asserts that the pattern inside the lookahead must not match immediately ahead of the current position.
	    - Example: `foo(?!bar)` matches "foo" only if it is not followed by "bar".
	3. **Positive Lookbehind (?<=...)**:
	    - `(?<=...)` asserts that the pattern inside the lookbehind must match immediately behind the current position.
	    - Example: `(?<=foo)bar` matches "bar" only if it is preceded by "foo".
	4. **Negative Lookbehind (?<!...)**:
	    - `(?<!...)` asserts that the pattern inside the lookbehind must not match immediately behind the current position.
	    - Example: `(?<!foo)bar` matches "bar" only if it is not preceded by "foo".
	- Lookahead and lookbehind assertions allow you to specify conditions that must be satisfied ahead of or behind the current position without including them in the match.
12. **Backreferences**:
	- `\1`, `\2`, ...: Matches the same text as previously matched by a capturing group.
	- Example: `(a)\1` matches 'aa'.



### Types of Commands

- An executable program like all those files we saw in /usr/bin. Within this category, programs can be compiled binaries such as programs written in C and C++, or programs written in scripting languages such as the shell, Perl, Python, Ruby, and so on. 
- A command built into the shell itself. bash supports a number of commands internally called shell builtins. The cd command, for example, is a shell builtin. 
- A shell function. Shell functions are miniature shell scripts incorporated into the environment.
- An alias. Aliases are commands that we can define ourselves, built from other commands.


### README and Other Program Documentation Files

Many software packages installed on your system have documentation files residing in the `/usr/share/doc` directory. Most of these are stored in ordinary text format and can be viewed with the less command. Some of the files are in HTML format and can be viewed with a web browser. We may encounter some files ending with a `.gz` extension. This indicates that they have been compressed with the gzip compression program. The gzip package includes a special version of `less` called `zless` that will display the contents of gzipcompressed text files.

### File Descriptors

File descriptors are unique identifiers assigned by the operating system to open files, sockets, pipes, and other input/output (I/O) resources. These descriptors are integers that serve as references to the underlying I/O streams. Here are some key points about file descriptors:

1. **Standard File Descriptors**:
    - Unix systems typically provide three standard file descriptors:
        - Standard Input (stdin): File descriptor 0 (usually represented as STDIN_FILENO)
        - Standard Output (stdout): File descriptor 1 (usually represented as STDOUT_FILENO)
        - Standard Error (stderr): File descriptor 2 (usually represented as STDERR_FILENO)
    - These descriptors are pre-opened by the operating system for the process and are available for input/output operations.
2. **Opening Files**:
    - When a file is opened by a process, the operating system assigns it a file descriptor, typically the lowest available integer not already in use by the process.
3. **I/O Operations**:
    - File descriptors are used in system calls and library functions to perform I/O operations such as reading from or writing to files, sockets, or other I/O resources.
    - System calls like `read()`, `write()`, `open()`, `close()`, `pipe()`, and `socket()` take file descriptors as arguments.
4. **Standard Redirection**:
    - File descriptors are essential for redirection of standard input, output, and error streams. For example, the `>` and `&>` redirection operators use file descriptors to direct output to files or other streams.
5. **Limits**:
    - The number of file descriptors available to a process is limited by the system's resource limits. This limit can be modified using system calls like `ulimit` in Unix-like systems.
6. **Closing File Descriptors**:
    
    - It's important to close file descriptors when they are no longer needed to avoid resource leaks. The `close()` system call is used to close file descriptors.
7. **Duplication and Duplexing**:
    - File descriptors can be duplicated using the `dup()` or `dup2()` system calls. Duplication allows multiple file descriptors to refer to the same underlying resource, enabling more flexible I/O operations.

Duplicating file descriptors in Unix-like operating systems serves several purposes and provides flexibility in managing input/output (I/O) operations.

1. **Redirection**:
    - File descriptor duplication allows you to redirect the output of one file descriptor to another, enabling redirection of standard input, output, and error streams.
    - For example, you can duplicate standard output (stdout) to a file descriptor representing a file, a socket, or another process, allowing output to be captured or redirected.
2. **Piping**:
    - When creating pipelines in shell scripts or programs, duplicating file descriptors is necessary to establish communication channels between processes.
    - By duplicating file descriptors and connecting them to the input and output of other processes, you can create pipelines for data processing.
3. **Concurrency**:
    - In concurrent programming scenarios, duplicating file descriptors allows multiple threads or processes to access the same I/O resource without interference.
    - Each thread or process can have its own copy of the file descriptor, ensuring independent access and preventing race conditions.
4. **Resource Sharing**:
    - File descriptor duplication facilitates resource sharing between different parts of a program or between different programs.
    - For example, a parent process can duplicate file descriptors and pass them to child processes for communication or coordination.
5. **Efficiency**:
    - Duplicating file descriptors can improve the efficiency of I/O operations by avoiding the need to reopen files or sockets multiple times.
    - Once a file descriptor is duplicated, both copies refer to the same underlying resource, reducing overhead associated with resource management.

File descriptors in Unix-like operating systems are indeed manipulated using system calls such as `open()`, `read()`, `write()`, `close()`, and `dup()`. These system calls provide low-level access to files and other input/output resources. Here's a brief overview of each system call:

1. **`open()`**: This system call is used to open a file or create a new file if it does not exist. It returns a file descriptor that can be used for subsequent I/O operations. The prototype of `open()` is:
    
    ```c
    int open(const char *pathname, int flags, mode_t mode);
    ```
    
2. **`read()`**: This system call is used to read data from an open file descriptor into a buffer. It reads up to a specified number of bytes from the file descriptor. The prototype of `read()` is:
    
    ```c
    ssize_t read(int fd, void *buf, size_t count);
    ```
    
3. **`write()`**: This system call is used to write data from a buffer to an open file descriptor. It writes up to a specified number of bytes to the file descriptor. The prototype of `write()` is:
    
    ```c
    ssize_t write(int fd, const void *buf, size_t count);
    ```
    
4. **`close()`**: This system call is used to close an open file descriptor. It releases any resources associated with the file descriptor. The prototype of `close()` is:
    
    ```c
    int close(int fd);
    ```
    
5. **`dup()`**: This system call is used to duplicate an existing file descriptor. It returns a new file descriptor that refers to the same open file or resource. The prototype of `dup()` is:
    
    ```c
    int dup(int oldfd);
    ```


These system calls are fundamental for performing input/output operations, file handling, and resource management in Unix-like operating systems. They provide a low-level interface for interacting with files, sockets, pipes, and other I/O resources. Understanding how to use these system calls is essential for systems programming and low-level I/O operations in C and other languages on Unix-like platforms.

### `/dev/null`

`/dev/null` is a special device file that serves as a sink for data. It is often referred to as the "null device" or "bit bucket." The purpose of `/dev/null` is to discard any data written to it and to provide an empty source of data when read from.

1. **Discarding Output**:
    - When data is written to `/dev/null`, it is immediately discarded and not stored anywhere. This makes `/dev/null` useful for discarding unwanted output or data that is not needed.
2. **Empty Source**:
    - Reading from `/dev/null` always returns an end-of-file (EOF) condition, indicating that there is no data available. This makes `/dev/null` useful for providing an empty source of data when reading is required but no actual data is needed.
3. **Usage**:
    - `/dev/null` is commonly used in Unix-like systems for various purposes, including:
        - Discarding error messages or unwanted output from commands by redirecting them to `/dev/null`.
        - Providing empty input to commands or scripts that require input but do not need any actual data.
        - Testing and benchmarking purposes where the focus is on the performance of operations rather than data handling.
4. **Example Usage**:
    
    - Redirecting output to `/dev/null`:
        `command > /dev/null`
        
    - Redirecting both output and error to `/dev/null`:
        `command &> /dev/null`
        
    - Providing empty input from `/dev/null`:
        `cat /dev/null | command`
        
5. **Security and Permissions**:
    - `/dev/null` is a virtual device and does not correspond to any physical storage. As such, it typically has very restrictive permissions (e.g., only root may write to it) to prevent misuse or accidental data loss.

### `/dev/console`

`/dev/console` is a special file in Unix and Unix-like operating systems (like Linux) that represents the system console. The system console is the primary device used to interact with the system, especially for system administrators. It is used to display system messages, logins, and other important information, especially during the boot process and for low-level system management.

**Key Points about `/dev/console`**

1. **System Messages**: During the boot process and in the event of critical system messages, output is often directed to `/dev/console`.

2. **Primary Console**: The system console is considered the primary terminal for system administration tasks. It's typically the terminal associated with the physical keyboard and monitor attached to the machine.

3. **Access**: Only the root user or users with appropriate permissions can write to `/dev/console`.

4. **Redirecting Output**: You can redirect output to `/dev/console` to display messages directly on the system console. For example, you can use the `echo` command to send a message to the console:

    ```bash
    echo "Hello, console!" > /dev/console
    ```

5. **Security and Access Control**: Because `/dev/console` is a critical interface for system administration, access to it is usually tightly controlled to prevent unauthorized users from interacting with the system console.

6. **Device File**: Like other special files in `/dev`, `/dev/console` is a device file, which means it is an interface to a device driver that communicates with the actual hardware (the system console).

**EXAMPLE USAGE**

**Viewing Messages on the Console**

To send a message directly to the console, you can use:

```bash
echo "System maintenance starting" > /dev/console
```

This command writes the message "System maintenance starting" directly to the system console.

**Checking the Device**

To see details about the `/dev/console` device, you can use the `ls` command:

```bash
ls -l /dev/console
```

Output might look like this:

```bash
crw--w---- 1 root tty 5, 1 Aug  1 08:15 /dev/console
```

Here:
- `c` indicates that it's a character device.
- `rw--w----` indicates the permissions (read and write for the owner, and write for the group).
- `root` is the owner.
- `tty` is the group.
- `5, 1` are the major and minor device numbers.

**When `/dev/console` is Useful**

- **During Boot**: Critical messages that occur during the boot process are often directed to the console.
- **System Recovery**: In single-user mode or during system recovery, `/dev/console` is often the main interface for administrative commands.
- **Debugging**: For debugging purposes, especially when other logging facilities are not available, `/dev/console` can be used to output critical information.

Understanding `/dev/console` is crucial for system administrators who need to interact with the system at a low level, especially in environments where physical access to the machine is required.

### Users and Groups

User accounts and groups are managed through several text files located in the `/etc` directory.

1. **/etc/passwd**: This file contains information about user accounts. Each line in the file represents a user account and contains several fields separated by colons (`:`). The fields typically include:
    - Username: The login name for the user.
    - Password: An 'x' character indicating that the encrypted password is stored in the `/etc/shadow` file.
    - User ID (UID): A unique numerical identifier for the user.
    - Group ID (GID): The primary group ID for the user.
    - User information: Additional information about the user, such as the full name.
    - Home directory: The user's home directory.
    - Login shell: The default shell for the user.
2. **/etc/group**: This file contains information about groups on the system. Each line in the file represents a group and includes fields separated by colons (`:`). The fields typically include:
    - Group name: The name of the group.
    - Password: An 'x' character indicating that the encrypted password is stored in the `/etc/gshadow` file.
    - Group ID (GID): A unique numerical identifier for the group.
    - Group members: A comma-separated list of usernames that belong to the group.
3. **/etc/shadow**: This file contains encrypted password information for user accounts. It is readable only by the superuser (root) and stores the hashed passwords for user accounts, among other security-related information.
    
4. **/etc/gshadow**: This file contains encrypted password information for group accounts. Similar to `/etc/shadow`, it is readable only by the superuser and stores the hashed passwords for group accounts.

### Permissions

File permissions are organized into three categories: reading, writing, and executing. These permissions determine what actions users, groups, and others can perform on a file or directory.

1. **Reading (r)**: If a user has read permission for a file, they can read its contents using text editors, viewing commands, or file manipulation tools. For directories, read permission allows users to list the files and subdirectories it contains.
    
2. **Writing (w)**: If a user has write permission for a file, they can edit its contents, append new data, or delete the file entirely. In the case of directories, write permission allows users to create, delete, or rename files and subdirectories within the directory.
    
3. **Executing (x)**: The executing permission (`x`) applies primarily to executable files and scripts. For regular files, execute permission allows users to run the file as a program or script. For directories, execute permission allows users to access the contents of the directory, provided they have appropriate read permissions for the directory and any files or subdirectories within it. Without execute permission on a directory, users cannot access its contents even if they have read permission.


File permissions are represented in Unix systems using a symbolic notation or numeric notation:

- Symbolic notation: `r` for read, `w` for write, and `x` for execute. Permissions are represented by a series of characters such as `-rwxr-xr--`.
- Numeric notation: Each permission is assigned a numeric value. Read permission is represented by `4`, write permission by `2`, and execute permission by `1`. These values are added together to calculate the permission value. For example, read and write permission would be `6` (4 + 2).


### File Types

Various file types are distinguished by a single character at the beginning of the file listing.

- `-`: Regular file: This represents a standard file containing data, text, or program instructions. Most files on a Unix system are regular files.
    
- `d`: Directory: This indicates a directory, which is a special type of file used to organize and store other files and directories. Directories are essential for organizing the file system hierarchy.
    
- `l`: Symbolic link: Also known as a symlink, a symbolic link is a special type of file that points to another file or directory in the file system. It acts as a shortcut or reference to the target file or directory.
    
- `c`: Character device file: This represents a character device, which is a type of special file used for communication with hardware devices that transmit or receive data one character at a time. Examples include terminals, serial ports, and sound cards.
    
- `b`: Block device file: Similar to character device files, block device files are special files used for communication with hardware devices. However, block devices transmit or receive data in fixed-size blocks or chunks. Examples include hard drives, SSDs, and CD-ROM drives.
    
- `s`: Unix domain socket: This represents a special type of file used for inter-process communication (IPC) within the same host system. Unix domain sockets allow processes to communicate by sending and receiving data streams.
    
- `p`: Named pipe (FIFO): Named pipes, also known as FIFOs (First In, First Out), are special types of files used for inter-process communication between unrelated processes. They allow data to flow between processes in a similar manner to regular pipes.

### Processes

In a multitasking environment, the operating system manages multiple processes simultaneously, giving users the illusion of parallel execution. Each process represents an independent execution of a program. Here are some key points:

1. **Process Definition**: A process is an instance of a running program. It includes the program's code, memory space, open files, and other resources needed for execution.
    
2. **Process Creation**: When a user launches a program, the operating system creates a process for that program. This process is assigned a unique Process ID (PID) and is managed by the kernel.
    
3. **Kernel Role**: The kernel is the core of the operating system responsible for managing processes. It allocates resources, schedules processes for execution, and ensures each process gets its share of CPU time.
    
4. **Process States**: A process can be in one of several states, including running, waiting, and terminated. The operating system's scheduler determines which process runs at a given moment.
    
5. **Context Switching**: The rapid switching between processes is known as context switching. The kernel saves the current state of a running process and restores the state of another, allowing the illusion of simultaneous execution.
    
6. **Inter-Process Communication (IPC)**: Processes often need to communicate with each other. The operating system provides mechanisms for IPC, such as pipes, shared memory, and message passing.
    
7. **Process Termination**: A process may terminate voluntarily (e.g., reaching the end of its execution) or involuntarily (e.g., due to an error). The operating system releases the resources associated with a terminated process.

### Process States

#### Running

A process in the **running** state is either:

- Currently executing on a CPU core, or
- Ready to execute and waiting in the run queue for CPU time

In process listings (`ps`, `top`), this appears as:
- `R` (Running or runnable)

Only processes in this state are actively consuming CPU cycles or are immediately ready to do so.

#### Sleeping (Interruptible Sleep)

A process in **sleeping** state is waiting for an event or resource, such as:

- User input from keyboard or mouse
- Data from a network socket
- A timer to expire
- A signal from another process

Key characteristics:
- Can be interrupted by signals
- Not consuming CPU resources
- Status indicator: `S` (Sleeping)

This is the most common state for idle processes.

#### Stopped

A **stopped** process has been suspended and is not executing. This occurs when:

- A stop signal is received (e.g., `SIGSTOP`, `SIGTSTP`)
- The user presses `Ctrl+Z` in the terminal
- A debugger pauses the process

Characteristics:
- Execution is completely paused
- Can be resumed with `SIGCONT` (via `fg` or `bg` commands)
- Status indicator: `T` (Stopped)

The process remains in memory but performs no work.

#### Zombie (Defunct)

A **zombie** process has completed execution but still has an entry in the process table because:

- The process has terminated (via `exit()` or signal)
- Its parent process has not yet read its exit status (via `wait()`)
- The kernel retains minimal information (PID, exit status, resource usage)

Characteristics:
- Consumes no CPU or memory resources (except the process table entry)
- Status indicator: `Z` (Zombie or defunct)
- Cleaned up when parent calls `wait()` or when parent terminates

A zombie is not a running process—it's a bookkeeping entry waiting to be reaped.

#### Uninterruptible Sleep

A process in **uninterruptible sleep** is waiting for a critical operation that cannot be interrupted, typically:

- Disk I/O operations
- Hardware access that must complete atomically
- Certain kernel operations

Characteristics:
- Cannot be interrupted by signals (even `SIGKILL`)
- Usually brief (milliseconds to seconds)
- Status indicator: `D` (Uninterruptible sleep/Disk sleep)
- If persistent, may indicate hardware problems or kernel issues

**[Inference]:** Extended periods in this state often suggest I/O problems, though the exact cause requires investigation of system logs and hardware status.

### Virtual Memory and Swapping

1. **Virtual Memory**:
    - **Definition**: Virtual memory is a memory management technique that provides an illusion of infinite memory to applications by allowing them to use more memory than is physically available in the system's RAM.
    - **Purpose**: It enables the operating system to allocate and manage memory resources effectively, allowing multiple processes to run concurrently without running out of physical memory.
    - **Implementation**: Virtual memory is implemented through a combination of hardware and software mechanisms. The operating system divides the virtual memory space into fixed-size pages, which are mapped to physical memory or storage.
    - **Page Replacement**: When a process accesses a page of memory that is not currently in physical memory, a page fault occurs, and the operating system retrieves the required page from secondary storage (disk) and swaps it into physical memory.
    - **Benefits**: Virtual memory allows for efficient memory utilization, supports multitasking by enabling multiple processes to share memory, and provides memory protection by isolating processes from each other.
2. **Swapping**:
    - **Definition**: Swapping is a technique used by the operating system to move entire processes or parts of processes between physical memory (RAM) and secondary storage (disk) to free up memory for other processes.
    - **Purpose**: Swapping helps prevent memory exhaustion by transferring less frequently used or inactive memory pages to disk when physical memory becomes scarce.
    - **Process**: When the operating system decides to swap out a process or memory page, it writes the contents of the memory to a swap space on disk and updates the process's page table to indicate that the memory is no longer in physical memory.
    - **Performance Impact**: Swapping can have a significant performance impact, as reading and writing to disk is much slower than accessing memory. Excessive swapping, also known as thrashing, can degrade system performance.
    - **Control**: System administrators can configure swapping behavior, such as setting swap space size and controlling swap activity, to optimize performance based on system requirements and workload characteristics.

### Terminal Devices (TTYs)

Terminal devices, commonly referred to as TTYs (Teletype Terminals), are interfaces that allow users to interact with a computer system through text-based input and output. In Unix-like operating systems, including Linux, TTYs play a crucial role in providing a user interface and facilitating communication between users and the system.
1. **Character Devices**:
    - TTYs are represented as character devices in the Unix file system (/dev).
    - They are typically named tty followed by a number or a descriptive identifier (e.g., tty1, ttyS0, pts/0).
    - Physical TTY devices can include serial ports, terminals connected via serial cables, and virtual terminals (e.g., those accessed through graphical user interfaces or remote shell sessions).
2. **Virtual Terminals**:
    - Virtual terminals are software-based TTYs that provide text-based interfaces to users.
    - Users can access virtual terminals directly from the system console or through terminal emulators within graphical environments.
    - Each virtual terminal can support a separate login session or shell session, allowing multiple users to interact with the system simultaneously.
3. **Pseudo-Terminals (PTYs)**:
    - Pseudo-terminals, also known as PTYs, are pairs of virtual character devices used for communication between processes.
    - They consist of a master and a slave device, with the master acting as a controlling terminal for applications and the slave emulating a physical terminal.
    - PTYs are commonly used for terminal emulation, remote shell sessions (e.g., SSH), and interactive command-line interfaces.
4. **Usage and Interaction**:
    - Users interact with TTYs through command-line interfaces, text editors, shell sessions, and other text-based applications.
    - TTYs provide a means for users to input commands, execute programs, view output, and receive system messages and prompts.
    - TTYs support features such as line editing, job control, and signal handling, enhancing the user experience in text-based environments.
5. **Controlling Terminal**:
    - Each process in a Unix-like system is associated with a controlling terminal, which allows it to interact with users and receive input/output from/to a terminal device.
    - The controlling terminal is essential for processes that require user interaction, enabling them to read input from the terminal, display output, and respond to user actions.

### Niceness

Nice processes, often referred to as "niceness," are a concept in Unix-like operating systems that allow users to prioritize the CPU usage of processes. The term "nice" comes from the command used to adjust the priority of processes, which is typically the `nice` command.

1. **Nice Value**:
    - Each process in Unix-like systems has a priority level associated with it, known as the nice value.
    - The nice value ranges from -20 to 19, where lower values indicate higher priority and higher values indicate lower priority.
    - The default nice value is usually 0.
2. **Adjusting Process Priority**:
    - Users can use the `nice` command to launch a process with a specific priority.
    - For example, to start a process with a lower priority (less CPU time), you can use:
        `nice -n 10 command`
        
    - Conversely, to start a process with a higher priority (more CPU time), you can use:
        `nice -n -10 command`
        
3. **Impact on CPU Usage**:
    - Processes with lower nice values (higher priority) are given more CPU time and are scheduled to run more frequently.
    - Processes with higher nice values (lower priority) are given less CPU time and are scheduled to run less frequently, allowing other processes with higher priorities to use more CPU resources.
4. **Usage**:
    - Nice processes are commonly used in scenarios where you want to run background tasks or non-urgent processes without impacting the performance of critical applications or interactive tasks.
    - For example, background tasks like file indexing, backups, or batch processing jobs can be started with higher nice values to ensure they don't interfere with the responsiveness of the system.
    - 

### Why launch a graphical program from CLI?

By launching a program from the command line, you might be able to see error messages that would otherwise be invisible if the program were launched graphically. Sometimes, a program will fail to start up when launched from the graphical menu. By launching it from the command line instead, we may see an error message that will reveal the problem. Also, some graphical programs have interesting and useful command line options.

