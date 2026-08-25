## Overview


### Directories

1. **/bin**: Contains essential executable binaries (programs) that are required for system boot and maintenance. Common commands like `ls`, `cp`, `mv`, `rm`, and `mkdir` are stored here.

2. **/boot**: Contains the files needed for the boot process, including the Linux kernel, initial RAM disk (initramfs/initrd), boot loader configuration files (GRUB), and sometimes the boot loader itself.

3. **/dev**: Contains device files, which are special files that represent hardware devices or pseudo-devices. Devices such as hard drives, partitions, terminals, and input/output devices are represented here.

4. **/etc**: Stores system-wide configuration files. Configuration files for system services, network settings, user authentication, and other system configurations are stored here.

5. **/home**: Contains user home directories. Each user has a separate subdirectory in /home where they can store their personal files and configurations.

6. **/lib** and **/lib64**: Contains shared libraries (dynamic link libraries) that are used by executable binaries and other libraries. /lib is used for 32-bit libraries, while /lib64 is used for 64-bit libraries on systems with a multilib architecture.

7. **/media** and **/mnt**: Mount points for removable media devices such as USB drives, external hard drives, and optical discs. /media is typically used for automatic mounting by desktop environments, while /mnt is used for manual mounting by users or system administrators.

8. **/opt**: Contains optional application software packages that are installed manually and are not managed by the system package manager. Some third-party software packages may be installed in /opt.

9. **/proc**: A virtual filesystem that provides information about system processes and kernel parameters in real-time. It contains directories and files that represent running processes, system resources, and kernel configuration settings.

10. **/root**: The home directory for the root user (superuser). Unlike regular users who have their home directories in /home, the root user's home directory is located at /root.

11. **/sbin**: Contains essential system binaries (programs) that are used for system administration tasks. These binaries are typically meant for use by the root user and perform critical system tasks.

12. **/srv**: Contains data for services provided by the system. This directory is typically used for files that are served by the system, such as websites, FTP files, and version control repositories.

13. **/sys**: A virtual filesystem that exposes information about kernel objects, device drivers, and kernel configuration parameters. It is similar to /proc but focuses on the kernel's runtime state and hardware configuration.

14. **/tmp**: A directory for temporary files. Users and applications can store temporary files here, which are typically deleted upon system reboot or when no longer needed.

15. **/usr**: Contains user-accessible files and directories that are not required for system booting or repairing. It is further divided into subdirectories like /usr/bin, /usr/lib, /usr/include, /usr/share, etc., which contain binaries, libraries, header files, and shared data files used by applications and users.

16. **/var**: Contains variable data files that change during the system's operation. Log files, spool files, temporary files created by daemons, and other files that may change in size or content are stored here.

17. **/run**: A temporary filesystem used by the system and applications to store runtime data. It typically contains system information, such as process IDs (PIDs), sockets, and other transient files needed during system operation.

18. **/etc/opt**: Contains configuration files for optional software packages installed in /opt. Similar to /etc, but specifically for software installed in /opt.

19. **/usr/local**: Contains locally installed software and related files. This directory is typically used for software that is installed manually by the system administrator or from source code, rather than being managed by the system's package manager.

20. **/usr/share**: Contains shared data files used by applications and system-wide resources. It includes architecture-independent files such as documentation, graphics, icons, themes, and localization files.

21. **/usr/include**: Contains header files used by C and C++ compilers. Header files provide function prototypes and declarations needed for compiling software.

22. **/usr/libexec**: Contains executable binaries intended to be executed by other programs rather than directly by users. These binaries are typically internal to system services and not meant to be invoked directly by users.

23. **/usr/sbin**: Contains system administration binaries (programs) that are used for system maintenance and configuration tasks. Similar to /sbin but contains binaries that are not essential for system booting.

24. **/usr/src**: Contains source code files for the Linux kernel and other system software. It is often used by developers and system administrators for compiling and installing custom kernels or kernel modules.

### Log Files

Common log files in Unix systems are typically found within the `/var/log` directory and serve various purposes to track system and application activity.

- **syslog or messages**: These logs contain general system messages and may vary depending on the distribution. Debian-based systems like Ubuntu use `syslog`, while Red Hat-based systems use `messages`.

- **auth.log or secure**: Stores security-related events such as logins, root user actions, and PAM (Pluggable Authentication Modules) outputs. Ubuntu uses `auth.log`, and Red Hat uses `secure`.

- **kern.log**: Records kernel events, errors, and warnings, which can be useful for troubleshooting custom kernels.

- **cron**: Holds information about scheduled tasks (cron jobs) and can be checked for verifying cron jobs are running successfully.

- **maillog or mail.log**: Logs related to mail servers, which are useful for information about email-related services like Postfix and SMTPD.

- **xferlog**: Contains all FTP file transfer sessions, including details about the file names and users who initiated FTP transfers.

- **apache/error_log and apache/access_log**: For Apache server logs, `error_log` captures error messages, while `access_log` records all requests made to the server.

- **httpd/access_log**: This is the access log for the Apache HTTP Server, recording all client requests processed by the server.

- **httpd/error_log**: The error log for the Apache HTTP Server, which logs any errors encountered during operation.

- **mysql/mysql.log**: Logs for the MySQL database server, useful for debugging database issues.

- **nginx/access.log**: Access log for the Nginx web server, showing all requests processed by the server.

- **nginx/error.log**: Error log for the Nginx web server, containing error messages and issues encountered by Nginx.

- **audit/audit.log**: Audit logs, which record system security events and are often used for auditing and compliance purposes.

- **faillog**: Failed login attempts, useful for monitoring and preventing brute force attacks.

- **lastlog**: Last login information for all users, showing the last time each user logged in.

- **wtmp**: A binary file that keeps a log of all logins and logouts since the last reboot.

- **btmp**: Similar to wtmp, but specifically for failed login attempts.

- **dpkg.log**: Log file for the dpkg package manager on Debian-based systems, tracking package installation and removal.

- **yum.log**: For Red Hat-based systems, yum.log keeps track of the operations performed by the YUM package manager.

- **boot.log**: Information about the system boot process, useful for diagnosing startup issues.

- **dmesg**: The kernel ring buffer, containing low-level messages from the system during boot and runtime.

### Environment Variables

1. **PATH**: A colon-separated list of directories that the shell searches for executable files.
2. **HOME**: The user's home directory.
3. **USER** or **LOGNAME**: The username of the current user.
4. **SHELL**: The default shell.
5. **TERM**: Terminal type.
6. **PWD**: The current working directory.
7. **LANG**: Specifies the language and localization settings.
8. **TERM**: Specifies the terminal type.
9. **EDITOR**: The default text editor.
10. **VISUAL**: An alternative default text editor.
11. **TMP** or **TEMP**: Directory for temporary files.
12. **TZ**: Specifies the timezone.
13. **LD_LIBRARY_PATH**: A colon-separated list of directories where shared libraries are searched for.
14. **MANPATH**: A colon-separated list of directories containing manual pages.
15. **DISPLAY**: Specifies the X11 display server.
16. **PS1**: The primary shell prompt.
17. **PS2**: The secondary shell prompt (for continued lines).
18. **PS3**: The prompt used by the select command.
19. **PS4**: The prompt used when executing commands with the -x option.
20. **MAIL**: The location of the user's mailbox.
21. **MAILCHECK**: Interval (in seconds) for checking mail.
22. **OLDPWD**: The previous working directory.
23. **CFLAGS**: Flags for the C compiler.
24. **LDFLAGS**: Flags for the linker.
25. **MAKEFLAGS**: Flags for the make command.
26. **CC**: The C compiler to use.
27. **CXX**: The C++ compiler to use.
28. **JAVA_HOME**: The directory where Java is installed.
29. **CLASSPATH**: The Java classpath.
30. **PYTHONPATH**: The Python module search path.
31. **PYTHONHOME**: The directory containing the Python executable and libraries.
32. **RUBYLIB**: The Ruby library search path.
33. **GEM_HOME**: The directory where Ruby gems are installed.
34. **GEM_PATH**: The search path for Ruby gems.
35. **NODE_PATH**: The search path for Node.js modules.
36. **VISUAL**: An alternative default text editor.
37. **LC_ALL**: Overrides all other locale settings.
38. **LC_COLLATE**: Defines collation rules for string comparison.
39. **LC_CTYPE**: Defines character classification and case conversion rules.
40. **LC_MESSAGES**: Defines the language for messages and help text.
41. **LC_NUMERIC**: Defines number formatting rules.
42. **LC_TIME**: Defines time and date formatting rules.
43. **LESS**: Options for the less pager.
44. **GREP_OPTIONS**: Options for the grep command.
45. **LESSOPEN**: The command to preprocess files viewed with less.
46. **LESSCLOSE**: The command to close the preprocessor used by less.
47. **HISTSIZE**: The maximum number of commands stored in the command history.
48. **HISTFILESIZE**: The maximum number of lines saved in the command history file.
49. **HISTCONTROL**: Determines how the shell treats duplicate entries and commands starting with a space in the history.
50. **TERMINFO**: Directory containing terminal information files.
51. **TZDIR**: Directory containing timezone information files.
52. **HOSTTYPE**: Type of hardware platform.
53. **HOSTALIASES**: Path to a file containing hostname aliases.
54. **HOSTCOLORS**: Path to a file containing terminal color settings.
55. **HOSTFILE**: Path to a file containing host-specific information.
56. **HOSTKEYS**: Path to a file containing host key information.
57. **HOSTNAME**: The name of the current host.
58. **MACHTYPE**: Type of machine architecture.
59. **OSTYPE**: Type of operating system.
60. **HOST**: Hostname of the machine.
61. **LOGNAME**: Login name of the current user.
62. **UID**: User ID of the current user.
63. **GID**: Group ID of the current user's primary group.
64. **EUID**: Effective user ID of the current user.
65. **PPID**: Process ID of the parent process.
66. **GROUPS**: List of supplementary group IDs for the current user.
67. **LD_LIBRARY_PATH**: Colon-separated list of directories to search for shared libraries.
68. **MANPATH**: Colon-separated list of directories to search for manual pages.
69. **COLUMNS**: Number of columns in the terminal window.
70. **LINES**: Number of lines in the terminal window.
71. **SHLVL**: Shell level, incremented each time a new shell is started.
72. **SHELLOPTS**: List of shell options enabled.
73. **RANDOM**: Generates a random number each time it is referenced.
74. **SECONDS**: Number of seconds since the shell was started.
75. **\_**: The last command executed.


---

