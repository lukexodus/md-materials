## Essential Shell Commands and Navigation


### Navigation Commands

**`pwd`** (Print Working Directory): Displays the absolute path of the current directory. This command is useful for confirming your location within the filesystem hierarchy.[5][6]

**`cd`** (Change Directory): Moves between directories in the filesystem. Examples include `cd /home/username/Documents` to navigate to a specific path, `cd ~` to return to the home directory, `cd -` to return to the previous directory, and `cd ../` to move to the parent directory. Without arguments, `cd` defaults to the home directory.[1][6][5]

**`ls`** (List): Lists files and directories in the current directory. Common options include `ls -l` for detailed output showing permissions, ownership, and modification dates; `ls -a` to display hidden files (those starting with a dot); and `ls -lah` for a comprehensive listing with all files in human-readable format.[6][1][5]

### File and Directory Operations

**`touch`**: Creates an empty file or updates the timestamp of an existing file. Syntax: `touch filename.txt`.[1][5][6]

**`mkdir`** (Make Directory): Creates a new directory. Syntax: `mkdir new_folder`.[5][6][1]

**`cp`** (Copy): Copies files or directories. Syntax: `cp file.txt /path/to/destination/` copies a file, while `cp -r folder /path/to/destination/` recursively copies an entire directory and its contents.[6][1][5]

**`mv`** (Move): Moves files to different directories or renames them. Syntax: `mv oldname.txt newname.txt` renames a file, while `mv file.txt /path/to/destination/` moves a file to another location.[1][5][6]

**`rm`** (Remove): Deletes files permanently. Syntax: `rm filename.txt` removes a file, while `rm -r foldername` recursively deletes a directory and its contents. This command cannot be easily undone, so careful use is recommended.[5][6][1]

### File Viewing and Examination

**`cat`** (Concatenate): Displays the entire contents of a file on the terminal. Syntax: `cat file.txt`.[1]

**`less`**: Displays file contents one page at a time, allowing scrolling for large files. Exit by pressing `q`.[1]

**`head`**: Shows the first 10 lines of a file by default. Syntax: `head -n 20 file.txt` displays the first 20 lines.[1]

**`tail`**: Shows the last 10 lines of a file by default. Syntax: `tail -n 20 file.txt` displays the last 20 lines.[1]

### User and System Information

**`who`**: Lists users currently logged into the system, displaying username, terminal, login time, and originating IP address.[1]

**`whoami`**: Displays the username of the current user.[3]

**`uname`**: Displays system information including kernel name, hostname, kernel release, kernel version, and machine hardware name.[3]

### User Management

**`useradd`**: Creates a new user account. Syntax: `sudo useradd -m username` creates a user with a home directory.[1]

**`passwd`**: Sets or changes a user's password. Syntax: `sudo passwd username`.[1]

**`su`** (Substitute User): Switches to a different user account. Syntax: `su - username` switches to the specified user and loads their environment. When used without arguments, it switches to the root user.[1]

**`userdel`**: Removes a user account. Syntax: `sudo userdel username` deletes the user but preserves their home directory unless specified otherwise.[1]

### File Search and Examination

**`find`**: Searches for files and directories within a specified path. Syntax: `find /home/user -name "*.txt"` locates all files with a `.txt` extension in the `/home/user` directory.[5]

**`grep`**: Searches for lines matching a pattern within files. Used in combination with pipes, it can filter command output.[5]

### Archiving and Compression

**`tar`**: Archives or extracts files into tarball format. Syntax: `tar -cvf archive.tar file1.txt file2.txt` creates an archive, while common options include `-c` (create), `-v` (verbose), `-f` (file), and `-x` (extract).[5]

### Remote Access

**`ssh`**: Connects to remote machines via Secure Shell. Syntax: `ssh user@remote_host` establishes a secure connection to a remote system.[5]

### Help and Documentation

**`man`** (Manual): Displays manual pages for commands. Syntax: `man ls` shows documentation for the `ls` command.[3]

### Command Composition

**Piping**: Multiple commands can be combined using the pipe operator (`|`), allowing the output of one command to serve as input for another [5]. Examples include `ps aux | head -n 10` to view the top 10 processes and `grep "error" log.txt | sort` to search and sort log entries [5].

Related topics for advanced navigation include tools like **fzf** (fuzzy finder), **zoxide** (smart directory jumper), and **ranger** or **yazi** (file managers) for enhanced terminal navigation efficiency.[2]

Sources
[1] Arch Linux Cheat Sheet: Essential Commands for New Users https://www.tecmint.com/arch-linux-beginner-commands/
[2] How do you guys navigate in the terminal quickly : r/archlinux https://www.reddit.com/r/archlinux/comments/1b9cirl/how_do_you_guys_navigate_in_the_terminal_quickly/
[3] 50+ Essential Linux Commands: A Comprehensive Guide https://www.digitalocean.com/community/tutorials/linux-commands
[4] Command-line shell https://wiki.archlinux.org/title/Command-line_shell
[5] Basic Shell Commands in Linux: Complete List https://www.geeksforgeeks.org/linux-unix/basic-shell-commands-in-linux/
[6] Linux Commands: Basic Syntax, Consistency & Challenges https://contabo.com/blog/linux-commands/
[7] Help:Reading - ArchWiki https://wiki.archlinux.org/title/Help:Reading
[8] Arch Linux pacman – Just the Most Useful Commands https://psychocod3r.wordpress.com/2021/07/11/arch-linux-pacman-just-the-most-useful-commands/
[9] Arch Linux Commands Cheatsheet https://gist.github.com/yufengwng/9cff3fc82403e3f3052d
[10] Installation guide - ArchWiki https://wiki.archlinux.org/title/Installation_guide

