## Module 6: Command Line Interfaces


### 6.1 Command Line Fundamentals

- What is a command line interface (CLI)?
- CLI vs GUI: advantages and use cases
- Terminal vs shell vs console
- Types of shells (Bash, Zsh, Fish, PowerShell, cmd)
- Command structure and syntax
- Getting help (man pages, --help flags, info)

### 6.2 Shell Basics

- Starting and exiting shells
- Command prompt anatomy
- Running commands
- Command history navigation
- Tab completion
- Command editing shortcuts
- Clearing the screen

### 6.3 File System Navigation

- Understanding file system hierarchy
- Absolute vs relative paths
- Current working directory concept
- Navigation commands
    - `pwd` - print working directory
    - `cd` - change directory
    - `ls` - list directory contents
- Path shortcuts (`.`, `..`, `~`, `-`)
- Directory structure conventions (Unix/Linux vs Windows)

### 6.4 File and Directory Operations

- Creating files and directories
    - `touch`, `mkdir`
- Copying, moving, renaming
    - `cp`, `mv`
- Removing files and directories
    - `rm`, `rmdir`
- Viewing file contents
    - `cat`, `less`, `more`, `head`, `tail`
- File globbing and wildcards (`*`, `?`, `[]`)
- Recursive operations

### 6.5 File Permissions and Ownership

- Permission concepts (read, write, execute)
- User types (owner, group, others)
- Permission representation (symbolic and octal)
- Viewing permissions (`ls -l`)
- Changing permissions
    - `chmod` (symbolic and numeric modes)
- Changing ownership
    - `chown`, `chgrp`
- Special permissions (setuid, setgid, sticky bit)
- `umask` for default permissions

### 6.6 Text Processing

- Searching within files
    - `grep` and regular expressions
- Text manipulation
    - `sed` - stream editor
    - `awk` - pattern scanning and processing
- Sorting and uniqueness
    - `sort`, `uniq`
- Counting
    - `wc` - word count
- Cutting and pasting
    - `cut`, `paste`
- Comparing files
    - `diff`, `cmp`

### 6.7 Input/Output Redirection and Pipes

- Standard streams (stdin, stdout, stderr)
- Output redirection
    - `>` (overwrite), `>>` (append)
- Input redirection (`<`)
- Error redirection (`2>`, `2>&1`)
- Pipes (`|`) for chaining commands
- Command substitution
- Here documents and here strings

### 6.8 Process Management

- Understanding processes
- Viewing processes
    - `ps`, `top`, `htop`
- Process IDs (PID) and parent processes (PPID)
- Foreground vs background processes
- Job control
    - `&`, `jobs`, `fg`, `bg`
- Signals and killing processes
    - `kill`, `killall`, `pkill`
- Process priority (`nice`, `renice`)

### 6.9 System Information and Monitoring

- System information commands
    - `uname`, `hostname`, `whoami`
- Disk usage
    - `df`, `du`
- Memory information
    - `free`, `vmstat`
- System uptime and load
    - `uptime`, `w`
- Network information
    - `ifconfig`/`ip`, `netstat`/`ss`
- Logging and system messages
    - `dmesg`, log files in `/var/log`

### 6.10 Environment Variables

- What are environment variables?
- Viewing environment variables
    - `env`, `printenv`, `echo $VAR`
- Setting environment variables
    - Temporary and persistent
- Common environment variables
    - `PATH`, `HOME`, `USER`, `SHELL`
- Modifying PATH
- Shell initialization files (`.bashrc`, `.bash_profile`, `.zshrc`)

### 6.11 Shell Scripting Basics

- Creating and executing shell scripts
- Shebang line (`#!/bin/bash`)
- Making scripts executable
- Variables and quoting
- Command-line arguments (`$1`, `$2`, `$@`, `$#`)
- Conditional statements (`if`, `case`)
- Loops (`for`, `while`, `until`)
- Functions
- Exit status and return codes

### 6.12 Networking Commands

- Testing connectivity
    - `ping`, `traceroute`
- DNS lookup
    - `nslookup`, `dig`, `host`
- Downloading files
    - `wget`, `curl`
- Secure file transfer
    - `scp`, `rsync`
- Remote access
    - `ssh`, `telnet`
- Network configuration
    - `ifconfig`/`ip addr`

### 6.13 Package Management

- Package managers overview (apt, yum, dnf, pacman, brew, choco)
- Installing packages
- Updating packages
- Removing packages
- Searching for packages
- Repository management

### 6.14 Compression and Archiving

- Archive creation and extraction
    - `tar`
- Compression utilities
    - `gzip`, `bzip2`, `xz`, `zip`, `unzip`
- Combined operations (tar with compression)

### 6.15 Command Line Productivity

- Aliases
- Shell functions
- Command history search (Ctrl+R)
- Multiple commands (`;`, `&&`, `||`)
- Terminal multiplexers (`screen`, `tmux`)
- Keyboard shortcuts
- Customizing the prompt

### 6.16 Windows Command Line

- Command Prompt (cmd) basics
- PowerShell introduction
- Common Windows CLI commands
- Differences from Unix/Linux commands
- Windows Subsystem for Linux (WSL)

### 6.17 Security and Best Practices

- Running commands as superuser (`sudo`, `su`)
- Security implications of commands
- Avoiding dangerous commands
- Verifying downloaded scripts
- Secure credential handling
- Command line security best practices

---

