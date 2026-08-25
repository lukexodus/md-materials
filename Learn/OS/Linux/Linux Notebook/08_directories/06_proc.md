## `/proc`


The `/proc` directory is a virtual filesystem in Linux that provides an interface to kernel data structures. It doesn't contain real files but rather runtime system information.

### What /proc Contains

#### Process Information
Each running process has a subdirectory named by its Process ID (PID). For example, `/proc/1234/` contains information about process 1234:

- **cmdline** - Command line arguments used to start the process
- **status** - Human-readable process status information
- **maps** - Memory mappings
- **fd/** - Directory containing symbolic links to open file descriptors
- **environ** - Environment variables
- **cwd** - Symbolic link to current working directory
- **exe** - Symbolic link to the executable file

##### Sample Values from /proc/[PID]/ Files

###### cmdline
```
/usr/bin/python3/home/user/script.py--verbose--output=/tmp/data.txt
```
**Note:** Arguments are separated by null characters (`\0`), often displayed concatenated or with spaces when viewed with `cat`.

###### status
```
Name:	python3
Umask:	0022
State:	S (sleeping)
Tgid:	1234
Ngid:	0
Pid:	1234
PPid:	1150
TracerPid:	0
Uid:	1000	1000	1000	1000
Gid:	1000	1000	1000	1000
FDSize:	256
Groups:	4 24 27 30 46 100 114 1000 
VmPeak:	   45328 kB
VmSize:	   45328 kB
VmRSS:	   12284 kB
VmData:	   15840 kB
Threads:	1
SigQ:	0/15669
SigPnd:	0000000000000000
SigBlk:	0000000000000000
CapInh:	0000000000000000
CapPrm:	0000000000000000
CapEff:	0000000000000000
```

**Name** - Process name (command name, up to 16 characters)

**Umask** - File creation mask that determines default permissions for newly created files

**State** - Current process state: S=sleeping, R=running, Z=zombie, T=stopped, D=uninterruptible sleep

**Tgid** - Thread Group ID (same as PID for main thread)

**Ngid** - NUMA Group ID (0 means not set)

**Pid** - Process ID, unique identifier for this process

**PPid** - Parent Process ID, the process that spawned this one

**TracerPid** - PID of process tracing this one (0 = not being traced/debugged)

**Uid** - Four user IDs: Real, Effective, Saved set, Filesystem UID (determines file access permissions)

**Gid** - Four group IDs: Real, Effective, Saved set, Filesystem GID

**FDSize** - Number of file descriptor slots currently allocated

**Groups** - Supplementary group IDs this process belongs to

**VmPeak** - Peak virtual memory size (highest amount ever used)

**VmSize** - Current total virtual memory size

**VmRSS** - Resident Set Size (physical RAM currently used)

**VmData** - Size of private data segments

**Threads** - Number of threads in this process

**SigQ** - Queued signals (current/maximum allowed)

**SigPnd** - Bitmap of pending signals for this thread

**SigBlk** - Bitmap of blocked signals

**CapInh** - Inheritable capability set (capabilities that can be passed to child processes)

**CapPrm** - Permitted capability set (capabilities this process may use)

**CapEff** - Effective capability set (capabilities currently active)

###### maps
```
55a8b2c00000-55a8b2c01000 r--p 00000000 08:01 1234567    /usr/bin/python3.10
55a8b2c01000-55a8b2c02000 r-xp 00001000 08:01 1234567    /usr/bin/python3.10
55a8b2c02000-55a8b2c03000 r--p 00002000 08:01 1234567    /usr/bin/python3.10
55a8b2c03000-55a8b2c04000 rw-p 00003000 08:01 1234567    /usr/bin/python3.10
7f8e4c000000-7f8e4c021000 rw-p 00000000 00:00 0          [heap]
7f8e5a000000-7f8e5a200000 r-xp 00000000 08:01 2345678    /usr/lib/x86_64-linux-gnu/libc-2.31.so
7ffde0a00000-7ffde0a21000 rw-p 00000000 00:00 0          [stack]
```

###### fd/ (directory listing)
```
lrwx------ 1 user user 64 Dec 27 10:30 0 -> /dev/pts/1
lrwx------ 1 user user 64 Dec 27 10:30 1 -> /dev/pts/1
lrwx------ 1 user user 64 Dec 27 10:30 2 -> /dev/pts/1
lrwx------ 1 user user 64 Dec 27 10:30 3 -> /home/user/data.txt
lrwx------ 1 user user 64 Dec 27 10:30 4 -> socket:[45678]
lrwx------ 1 user user 64 Dec 27 10:30 5 -> /var/log/application.log
```
**Explanation:** 
- 0, 1, 2 = stdin, stdout, stderr (terminal)
- 3 = regular file open for reading/writing
- 4 = network socket
- 5 = log file

###### environ
```
USER=john
HOME=/home/john
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
LANG=en_US.UTF-8
PWD=/home/john/projects
TERM=xterm-256color
DISPLAY=:0
SSH_CONNECTION=192.168.1.100 54321 192.168.1.1 22
```
**Note:** Variables are separated by null characters (`\0`).

###### cwd (symbolic link)
```
lrwxrwxrwx 1 user user 0 Dec 27 10:30 /proc/1234/cwd -> /home/user/projects/myapp
```
**When read:**
```
/home/user/projects/myapp
```

###### exe (symbolic link)
```
lrwxrwxrwx 1 user user 0 Dec 27 10:30 /proc/1234/exe -> /usr/bin/python3.10
```
**When read:**
```
/usr/bin/python3.10
```

These examples show typical values you'd encounter when examining process information in the /proc filesystem.

#### System-Wide Information
- **/proc/cpuinfo** - CPU details (model, cores, flags)
- **/proc/meminfo** - Memory usage statistics
- **/proc/version** - Kernel version information
- **/proc/uptime** - System uptime and idle time
- **/proc/loadavg** - System load averages
- **/proc/filesystems** - Supported filesystem types
- **/proc/mounts** - Currently mounted filesystems
- **/proc/net/** - Network statistics and configuration
- **/proc/sys/** - Kernel parameters that can be modified

### Common Operations

#### Reading Process Information
```bash
# View command of process 1234
cat /proc/1234/cmdline

# Check process status
cat /proc/1234/status

# See which files a process has open
ls -l /proc/1234/fd/
```

#### System Monitoring
```bash
# Check memory info
cat /proc/meminfo

# View CPU information
cat /proc/cpuinfo

# Check system load
cat /proc/loadavg

# See network statistics
cat /proc/net/dev
```

#### Modifying Kernel Parameters
The `/proc/sys/` directory contains tunable kernel parameters:

```bash
# View a parameter
cat /proc/sys/net/ipv4/ip_forward

# Modify a parameter (temporary, until reboot)
echo 1 > /proc/sys/net/ipv4/ip_forward

# For permanent changes, use /etc/sysctl.conf
```

### Practical Uses

#### Debugging and Troubleshooting
- Examine what files a process has open
- Check process environment variables
- Trace memory usage patterns
- Investigate network connections

#### System Administration
- Monitor system resources without external tools
- Tune kernel parameters for performance
- Verify hardware detection
- Check filesystem mount options

#### Security Analysis
- Identify running processes and their executables
- Examine process privileges and capabilities
- Review network connections and listening ports
- Investigate suspicious process behavior

### Important Notes

- **/proc is read-only** for most entries (except /proc/sys/)
- **Data is generated on-demand** - reading a file causes the kernel to generate current information
- **PID directories appear/disappear** as processes start and stop
- **Root privileges required** for some sensitive information
- **Changes to /proc/sys/** are lost on reboot unless made permanent via sysctl configuration

### Example: Finding Which Process Has a File Open

```bash
# Find processes using /var/log/syslog
for pid in /proc/[0-9]*; do
  if grep -q syslog $pid/maps 2>/dev/null; then
    echo "Process $(basename $pid) is using syslog"
  fi
done
```

The /proc filesystem is a powerful interface for system introspection and management, essential for system administrators and developers working on Linux systems.

