## Basic Linux/Unix Command Line Skills


Effective Ansible usage requires foundational Linux/Unix command line proficiency for troubleshooting, file manipulation, and system administration tasks on both control nodes and managed infrastructure.

**File System Navigation:**

`pwd` displays current working directory. `ls` lists directory contents with options like `-la` for detailed listing including hidden files. `cd` changes directories using absolute paths (`/etc/ansible`) or relative paths (`../inventory`).

File path understanding distinguishes absolute paths (beginning with `/`) from relative paths (relative to current location). The tilde (`~`) represents user home directory, while dot (`.`) represents current directory and double-dot (`..`) represents parent directory.

**File Operations:**

`cat filename` displays file contents. `less filename` provides paginated viewing with search capabilities (`/search_term`). `head -n 10 filename` shows first 10 lines, while `tail -n 10 filename` shows last 10 lines. `tail -f filename` follows file changes in real-time.

`cp source destination` copies files and directories (`-r` for recursive directory copying). `mv source destination` moves or renames files. `rm filename` removes files (`-rf` for recursive directory removal, use cautiously).

**Text Processing:**

`grep pattern filename` searches for text patterns within files. `grep -r pattern directory` searches recursively through directories. `grep -v pattern filename` shows lines not matching the pattern.

`sed 's/old/new/g' filename` performs stream editing for text substitution. `awk '{print $1}' filename` extracts specific fields from structured text.

**File Permissions and Ownership:**

`ls -l` displays detailed file information including permissions, ownership, and timestamps. Permission format shows user, group, and other permissions using read (r), write (w), and execute (x) flags.

`chmod 755 filename` modifies file permissions using octal notation. `chmod u+x filename` adds execute permission for user using symbolic notation. `chown user:group filename` changes file ownership.

**Process Management:**

`ps aux` displays running processes with detailed information. `ps aux | grep ansible` filters processes containing "ansible". `top` or `htop` provide interactive process monitoring.

`kill PID` terminates processes by process ID. `kill -9 PID` forces process termination. `killall process_name` terminates all processes matching the name.

**Network Diagnostics:**

`ping hostname` tests network connectivity. `ssh user@hostname` establishes SSH connections. `scp file user@hostname:/path` copies files over SSH.

`netstat -tulnp` displays network connections and listening ports. `ss -tulnp` provides similar functionality with improved performance.

**System Information:**

`uname -a` displays system information including kernel version and architecture. `df -h` shows disk usage in human-readable format. `free -h` displays memory usage. `uptime` shows system load and uptime statistics.

**Environment Variables:**

`env` displays all environment variables. `echo $VARIABLE_NAME` shows specific variable values. `export VARIABLE_NAME=value` sets environment variables for current session.

**Command History and Shortcuts:**

`history` displays command history. `!number` executes specific command from history. `!!` repeats last command. `!string` executes most recent command beginning with string.

Ctrl+C interrupts running commands. Ctrl+Z suspends processes (resume with `fg`). Ctrl+R searches command history interactively.

**File Editing:**

Basic familiarity with text editors proves essential. `nano filename` provides simple editing with on-screen command help. `vi filename` or `vim filename` offer more powerful editing capabilities requiring mode understanding (insert mode via `i`, command mode via Escape, save and quit via `:wq`).

**Output Redirection:**

`command > file` redirects output to file (overwrites). `command >> file` appends output to file. `command 2> file` redirects error output. `command &> file` redirects both output and errors.

`command | grep pattern` pipes command output to grep for filtering. Multiple pipes chain commands: `command1 | grep pattern | sort | uniq`.

These foundational skills enable effective Ansible troubleshooting, inventory management, and automation development across diverse Unix-like environments.

---

