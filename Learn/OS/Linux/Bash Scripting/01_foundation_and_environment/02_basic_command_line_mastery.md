## Basic Command Line Mastery


### Essential Navigation Commands

The `ls` command lists directory contents with various options for different views. Use `ls -l` for detailed file information including permissions, ownership, and timestamps. The `ls -a` flag reveals hidden files starting with dots, while `ls -la` combines both for comprehensive directory listings.

The `cd` command changes directories, with `cd ~` taking you home, `cd ..` moving up one level, and `cd -` returning to the previous directory. Understanding relative versus absolute paths is crucial - relative paths start from your current location while absolute paths begin from the root directory.

The `pwd` command prints your current working directory, serving as your compass in the file system. This becomes essential when working with relative paths or when you need to reference your current location in scripts.

### File and Directory Management

The `mkdir` command creates directories, with `mkdir -p` creating parent directories as needed. For example, `mkdir -p project/src/main` creates the entire directory structure in one command.

The `rm` command removes files and directories, requiring careful use due to its permanent nature. Use `rm -r` for recursive directory removal and `rm -f` to force deletion without prompts. The combination `rm -rf` is powerful but dangerous - always double-check your target before execution.

The `cp` command copies files and directories, with `cp -r` for recursive copying of directories. The syntax follows `cp source destination`, and you can copy multiple files to a directory by listing them before the destination.

The `mv` command both moves and renames files. Unlike `cp`, it doesn't require a recursive flag for directories since it's relocating rather than duplicating. Use `mv oldname newname` for renaming in the same directory.

### File Permissions and Ownership

Unix file permissions operate on three levels: owner, group, and others. Each level has read (r), write (w), and execute (x) permissions, represented numerically as 4, 2, and 1 respectively.

The `chmod` command modifies permissions using either symbolic or numeric notation. Symbolic notation uses `u` (user), `g` (group), `o` (others), and `a` (all), combined with `+` (add), `-` (remove), or `=` (set exact). Numeric notation uses three digits representing owner, group, and others permissions.

**Example**: `chmod 755 file.sh` grants read, write, and execute to owner, and read and execute to group and others. This is common for executable scripts.

The `chown` command changes file ownership, typically requiring root privileges. Use `chown user:group filename` to change both owner and group simultaneously.

The `umask` command sets default permissions for newly created files and directories. A umask of 022 creates files with 644 permissions and directories with 755 permissions.

### Processes, Jobs, and Background Tasks

#### Processes

A **process** is a running instance of a program with its own memory space, process ID (PID), and system resources. Each process has:

- A unique identifier (PID)
- Its own address space in memory
- Associated file descriptors
- Security attributes (owner, permissions)
- Execution state (running, sleeping, stopped, zombie)

Processes are the fundamental unit of execution in Unix-like systems. When you run a command, the shell creates a new process to execute it.

#### Jobs

A **job** is a shell-level concept representing one or more processes that the shell manages as a single unit. Jobs are:

- Created when you run commands from an interactive shell
- Tracked by the shell (not the kernel)
- Identified by job numbers (e.g., `[1]`, `[2]`)
- Controllable with job control commands (`fg`, `bg`, `jobs`)

A single job can contain multiple processes. For example, a pipeline like `cat file | grep pattern | sort` is one job containing three processes.

#### Background Tasks

A **background task** refers to a job running in the background, meaning:

- It executes without blocking the shell prompt
- Started by appending `&` to a command (e.g., `long_command &`)
- Does not receive keyboard input from the terminal
- May still send output to the terminal unless redirected
- Can be brought to the foreground with `fg`

Background tasks allow you to continue working in the shell while processes execute.

#### Key Distinctions

| Aspect | Process | Job | Background Task |
|--------|---------|-----|-----------------|
| Scope | System-wide | Shell session | Shell session |
| Management | Kernel | Shell | Shell |
| Identifier | PID | Job number | Job number + `&` state |
| Persistence | Survives shell exit (if detached) | Dies when shell exits | Dies when shell exits |
| Control commands | `kill`, `ps` | `jobs`, `fg`, `bg` | `bg`, `fg` |

### Process Management

The `ps` command displays running processes, with `ps aux` showing all processes system-wide including CPU and memory usage. Use `ps -ef` for a different format showing parent-child relationships.

The `kill` command terminates processes by process ID (PID). Different signals serve different purposes: `kill -9` (SIGKILL) forces immediate termination, while `kill -15` (SIGTERM) requests graceful shutdown. Use `killall` to terminate processes by name.

Job control manages processes within your shell session. The `jobs` command lists active jobs, showing their status and job numbers. Use `&` after a command to run it in the background immediately.

The `fg` command brings background jobs to the foreground, while `bg` resumes suspended jobs in the background. Use `Ctrl+Z` to suspend a running foreground job, then `bg` to continue it in the background.

The `nohup` command runs processes immune to hangup signals, useful for long-running tasks that should continue after you log out.

### Input/Output Redirection

Output redirection using `>` sends command output to a file, overwriting existing content. The `>>` operator appends output to a file instead of overwriting.

**Example**: `ls -l > filelist.txt` creates a file with directory contents, while `date >> log.txt` appends the current date to an existing log file.

Input redirection using `<` feeds file contents to a command as input. This is useful for commands that normally read from keyboard input.

The pipe operator `|` connects commands by sending the output of one command as input to another. This creates powerful command chains for data processing.

**Example**: `ps aux | grep python | wc -l` counts running Python processes by chaining three commands together.

- **`2>`** redirects standard error (stderr) to a file
- **`2>&1`** redirects stderr to wherever stdout is currently going
- **`&>`** redirects both stdout and stderr to the same destination
- **`> file 2>&1`** also redirects both streams to the same file (stdout first, then stderr follows)

For example:
```bash
command 2> errors.txt          # Only errors go to errors.txt
command > output.txt 2>&1      # Both stdout and stderr go to output.txt
command &> all.txt             # Both stdout and stderr go to all.txt
```

### Command History and Shortcuts

**Basic history commands:**
- **`history`** displays the command history list
- **`!n`** executes command number n from history
- **`!!`** repeats the last command

**History expansion shortcuts:**
- **`!string`** executes the most recent command starting with "string"
- **`^old^new`** substitutes "old" with "new" in the previous command and executes it

For example:
```bash
history              # Show numbered command history
!150                 # Execute command #150
!!                   # Repeat last command
!git                 # Run most recent command starting with "git"
^tset^test          # Replace "tset" with "test" in previous command
```

This is useful for quickly re-running or modifying recent commands without retyping them.

**Key shortcuts** include:

- `Ctrl+R` for reverse history search
- `Ctrl+A` to move to line beginning
- `Ctrl+E` to move to line end
- `Ctrl+W` to delete the previous word
- `Ctrl+K` to delete from cursor to end of line
- `Ctrl+U` to delete entire line

Tab completion automatically completes file names, command names, and options. Press Tab twice to see all available completions when multiple options exist.

The `alias` command creates shortcuts for frequently used commands. Add aliases to your shell configuration file (.bashrc or .zshrc) for permanent availability.

### Advanced Command Combinations

Command substitution using `$(command)` or backticks captures command output for use in other commands. This enables dynamic command building based on system state.

**Example**: `cp file.txt backup-$(date +%Y%m%d).txt` creates a backup with the current date in the filename.

Conditional execution uses `&&` (AND) and `||` (OR) operators to chain commands based on success or failure. Use `command1 && command2` to run command2 only if command1 succeeds.

**Key points**:

- Master these fundamental commands as they form the foundation of all command-line work
- Practice file permission calculations until they become intuitive
- Understand the distinction between processes, jobs, and background tasks
- Experiment with redirection and pipes to build powerful command chains
- Customize your shell environment with aliases and history settings for improved productivity

Understanding these core concepts provides the foundation for advanced command-line operations, shell scripting, and system administration tasks.

---

