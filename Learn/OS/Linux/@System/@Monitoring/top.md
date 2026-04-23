# top

The classic interactive process viewer and system monitor. `top` ships on virtually every Unix and Linux system and requires no installation.

> `top` shows a live, updating view of running processes and system resource usage. Most of its display and behavior is configurable interactively and can be saved to a personal config file.

**Man page:** `man top`  
**Version note:** This guide covers **procps-ng top** — the version on Linux. macOS ships a different implementation with a different interface; differences are noted where relevant.

---

## Table of Contents

1. [Starting top](#starting-top)
2. [The Display — Header Area](#the-display--header-area)
3. [The Display — Task Area](#the-display--task-area)
4. [Interactive Commands](#interactive-commands)
5. [Sorting](#sorting)
6. [Filtering](#filtering)
7. [Display Toggles](#display-toggles)
8. [Fields & Columns](#fields--columns)
9. [Windows & Multiple Views](#windows--multiple-views)
10. [Color & Appearance](#color--appearance)
11. [Batch & Non-interactive Mode](#batch--non-interactive-mode)
12. [Saving Configuration](#saving-configuration)
13. [Signals from top](#signals-from-top)
14. [Alternatives to top](#alternatives-to-top)
15. [Quick Cheatsheet](#quick-cheatsheet)

---

## Starting top

```sh
top                         # default — all processes, sorted by CPU
top -u alice                # only show processes owned by alice
top -u 1000                 # by UID
top -p 1234                 # monitor a specific PID
top -p 1234,5678,9012       # monitor multiple PIDs
top -d 0.5                  # update every 0.5 seconds (default is 3)
top -n 10                   # exit after 10 updates
top -b                      # batch mode (non-interactive, for scripts)
top -b -n 1                 # single snapshot, plain text output
top -H                      # show threads instead of processes
top -i                      # hide idle processes
top -c                      # show full command line (not just process name)
top -o %CPU                 # sort by a specific field on start
top -w 250                  # set output width (for wide terminals or batch mode)
```

---

## The Display — Header Area

The top section of `top` shows system-wide statistics. It updates every cycle.

```
top - 14:32:01 up 3 days, 5:14,  2 users,  load average: 0.42, 0.38, 0.31
Tasks: 312 total,   1 running, 311 sleeping,   0 stopped,   0 zombie
%Cpu(s):  3.2 us,  1.1 sy,  0.0 ni, 95.2 id,  0.3 wa,  0.0 hi,  0.2 si,  0.0 st
MiB Mem :  15894.4 total,   4201.3 free,   7432.1 used,   4261.0 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   7912.4 avail Mem
```

### Line 1 — Uptime & load

| Field | Meaning |
|---|---|
| `14:32:01` | Current time |
| `up 3 days, 5:14` | System uptime |
| `2 users` | Logged-in users |
| `load average: 0.42, 0.38, 0.31` | 1, 5, and 15-minute load averages |

Load average represents the average number of processes in a runnable or uninterruptible state. On a single-core system, a load of 1.0 means fully utilized. On an 8-core system, a load of 8.0 means fully utilized.

### Line 2 — Tasks

| State | Meaning |
|---|---|
| `running` | Currently on CPU |
| `sleeping` | Waiting for an event (I/O, timer, etc.) |
| `stopped` | Suspended via SIGSTOP or `ctrl+z` |
| `zombie` | Exited but parent has not called `wait()` |

### Line 3 — CPU

| Field | Meaning |
|---|---|
| `us` | User space — time in non-niced user processes |
| `sy` | System (kernel) space |
| `ni` | User space with altered nice priority |
| `id` | Idle |
| `wa` | I/O wait — CPU idle while waiting for disk/network |
| `hi` | Hardware interrupt handling |
| `si` | Software interrupt handling |
| `st` | Steal time — time lost to hypervisor (VMs) |

High `wa` → I/O bottleneck. High `sy` → kernel overhead. High `st` → noisy neighbor on a VM.

### Lines 4 & 5 — Memory

| Field | Meaning |
|---|---|
| `total` | Physical RAM installed |
| `free` | Completely unused |
| `used` | In use by processes |
| `buff/cache` | Used by kernel buffers and page cache — available for reclaim |
| `avail Mem` | Estimated memory available for new processes without swapping |

> `avail Mem` is more useful than `free`. The kernel will reclaim `buff/cache` when processes need memory, so free + avail ≈ what you can actually use.

---

## The Display — Task Area

Below the header is the task list. Default columns:

```
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
 1234 alice     20   0  512340  45320  18230 S   2.3   0.3   0:12.34 node
  567 root      20   0 1234560 123456  34567 S   1.1   0.8   5:43.21 java
```

### Column definitions

| Column | Meaning |
|---|---|
| `PID` | Process ID |
| `USER` | Effective user name |
| `PR` | Scheduling priority (kernel-assigned) |
| `NI` | Nice value (-20 = highest priority, 19 = lowest) |
| `VIRT` | Virtual memory — total address space allocated (includes all mapped files, shared libs) |
| `RES` | Resident memory — physical RAM currently in use by this process |
| `SHR` | Shared memory — portion of RES that could be shared with other processes |
| `S` | Process state (see below) |
| `%CPU` | CPU usage since last update |
| `%MEM` | RES as a percentage of total RAM |
| `TIME+` | Total CPU time consumed since process started |
| `COMMAND` | Process name (or full command line with `-c` / `c`) |

### Process states (`S` column)

| Code | State |
|---|---|
| `R` | Running or runnable |
| `S` | Interruptible sleep (waiting for event) |
| `D` | Uninterruptible sleep (usually I/O wait) |
| `T` | Stopped |
| `t` | Stopped by debugger |
| `Z` | Zombie |
| `I` | Idle kernel thread |

`D` state processes cannot be killed — they are in the middle of a kernel operation and must complete it. Many `D` processes usually indicates an I/O or NFS problem.

### VIRT vs RES vs SHR

- **VIRT** is large and often misleading — it includes memory-mapped files, shared libraries, and allocated-but-not-yet-used pages. It does not reflect actual memory pressure.
- **RES** is the realistic per-process RAM consumption, but it double-counts shared memory.
- **SHR** is the part of RES that is actually shared. `RES - SHR` gives the unique private memory used by a process.
- For true memory usage accounting, use `smem` or `/proc/<pid>/smaps`.

---

## Interactive Commands

Press these while `top` is running.

### Help & exit

| Key | Action |
|---|---|
| `h` or `?` | Show help screen |
| `q` | Quit |

### Display control

| Key | Action |
|---|---|
| `Space` or `Enter` | Refresh immediately |
| `d` or `s` | Change update interval (prompts for seconds) |
| `l` | Toggle the uptime/load average line |
| `t` | Cycle through CPU display styles (off → bar → percent) |
| `m` | Cycle through memory display styles (off → bar → percent) |
| `1` | Toggle per-CPU breakdown (show each core separately) |
| `2` | Show NUMA nodes summary (if applicable) |
| `3` | Show NUMA node for each process |
| `I` | Toggle Irix mode — `%CPU` based on one CPU vs all CPUs |
| `B` | Toggle bold display |
| `E` | Cycle memory units in header (KiB → MiB → GiB → TiB → PiB) |
| `e` | Cycle memory units in task list |

### Process list

| Key | Action |
|---|---|
| `c` | Toggle full command line vs process name |
| `H` | Toggle thread view (show threads as individual rows) |
| `i` | Toggle display of idle processes |
| `n` or `#` | Set number of rows to show (0 = unlimited) |
| `S` | Toggle cumulative time mode (TIME+ shows sum including dead children) |
| `v` | Toggle forest / tree view (indent child processes under parents) |
| `V` | Toggle forest view (same as `v` in some versions) |

---

## Sorting

| Key | Sort by |
|---|---|
| `P` | CPU usage (`%CPU`) — default |
| `M` | Memory usage (`%MEM`) |
| `T` | CPU time (`TIME+`) |
| `N` | PID |
| `R` | Reverse sort order |
| `<` | Move sort column left |
| `>` | Move sort column right |
| `f` | Open field manager to select sort column interactively |

Or start with a specific sort field:

```sh
top -o %MEM           # sort by memory on start
top -o RES            # sort by resident memory
top -o TIME+          # sort by CPU time
top -o PID            # sort by PID
```

---

## Filtering

### Filter by user

```sh
top -u alice          # at startup
```

Or interactively:

| Key | Action |
|---|---|
| `u` | Filter by user (prompts — type username or UID; blank = all users) |

### Filter by PID

```sh
top -p 1234,5678
```

### Other filter (by field value)

| Key | Action |
|---|---|
| `o` or `O` | Add a filter expression (`o` = case-insensitive, `O` = case-sensitive) |
| `=` | Clear all active filters |
| `+` | Restore default display after clearing |

Filter expression syntax:

```
FIELD=VALUE          filter where field equals value
FIELD>VALUE          filter where field is greater than value (numeric)
FIELD<VALUE          filter where field is less than value
!FIELD=VALUE         exclude matching rows
```

Examples (entered after pressing `o`):

```
COMMAND=nginx        show only nginx processes
%CPU>5.0             only processes using more than 5% CPU
USER=alice           only alice's processes
!COMMAND=kworker     hide kworker threads
```

Multiple filters are additive (all must match).

---

## Display Toggles

| Key | Toggle |
|---|---|
| `l` | Uptime/load line |
| `t` | Task/CPU summary lines |
| `m` | Memory summary lines |
| `1` | Per-core CPU breakdown |
| `c` | Full command line |
| `H` | Threads mode |
| `i` | Idle processes |
| `v` | Forest (tree) view |
| `S` | Cumulative CPU time |
| `I` | Irix mode (single-CPU % vs all-CPU %) |
| `x` | Highlight sort column |
| `y` | Highlight running (R state) tasks |
| `z` | Toggle color display |
| `b` | Toggle bold/reverse highlight for sort column and running tasks |

---

## Fields & Columns

### Open the field manager

Press `f` to enter the interactive field manager. It shows all available fields:

- Use `↑`/`↓` to navigate
- Press `Space` to toggle a field on/off
- Press `s` to set the selected field as the sort column
- Press `d` to toggle display
- Press `q` to exit the manager

### Notable fields not shown by default

| Field | Meaning |
|---|---|
| `PPID` | Parent PID |
| `UID` | Numeric user ID |
| `RUID` | Real user ID |
| `GID` | Group ID |
| `TTY` | Controlling terminal |
| `WCHAN` | Kernel function where process is sleeping |
| `nTH` | Number of threads |
| `P` | Last used CPU core |
| `PGRP` | Process group ID |
| `SID` | Session ID |
| `%CPU` (already shown) | |
| `SWAP` | Swapped-out memory |
| `CODE` | Size of code (text) segment |
| `DATA` | Size of data + stack |
| `nMaj` | Major page faults (disk reads) since last update |
| `nMin` | Minor page faults |
| `vMj` | Major page faults since process started |
| `vMn` | Minor page faults since process started |
| `USED` | RES + SWAP (total physical memory used) |
| `nsIPC` | IPC namespace inode |
| `nsMNT` | Mount namespace inode |
| `nsNET` | Network namespace inode |
| `nsPID` | PID namespace inode |
| `nsUSER` | User namespace inode |
| `nsUTS` | UTS namespace inode |

Namespace inodes are useful for identifying processes inside containers — processes sharing a namespace inode are in the same container.

---

## Windows & Multiple Views

`top` supports up to four independent windows, each with its own field set, sort order, and filter. This is called **alternate display mode**.

| Key | Action |
|---|---|
| `A` | Toggle alternate display mode (split into 4 windows) |
| `a` | Cycle forward through windows |
| `w` | Cycle backward through windows |
| `g` | Select a window by number (1–4) |
| `G` | Rename the current window |

Each window can be configured independently. For example: window 1 sorted by CPU, window 2 sorted by memory, window 3 filtered to a specific user.

---

## Color & Appearance

Press `z` to toggle color on/off.

Press `Z` to enter the color configuration screen:

```
S = Summary Data,   M = Messages/Prompts,
H = Column Heads,   T = Task Information

1 = Red,    2 = Green,  3 = Yellow, 4 = Blue,
5 = Magenta 6 = Cyan,   7 = White,  8 = default

a = apply to all windows
```

Select a target (S/M/H/T) then a color (1–8). Press `Enter` to save or `q` to exit without saving.

---

## Batch & Non-interactive Mode

Batch mode (`-b`) disables interactive commands and sends output to stdout. Useful for logging, scripting, or piping.

### Single snapshot

```sh
top -b -n 1
top -b -n 1 -o %CPU      # sorted by CPU
top -b -n 1 -u alice     # filtered to user alice
```

### Capture to file

```sh
top -b -n 5 -d 2 > top-log.txt      # 5 iterations, 2-second intervals
```

### Extract just the process table (skip header)

```sh
top -b -n 1 | tail -n +8            # skip first 7 header lines
```

### Parse with awk — top 5 CPU consumers

```sh
top -b -n 1 | awk 'NR>7 {print}' | head -5
```

### Watch a specific process

```sh
top -b -n 1 -p $(pgrep nginx | tr '\n' ',')
```

### Output width for wide columns

```sh
top -b -n 1 -w 512        # prevent column truncation
```

---

## Saving Configuration

Press `W` (capital W) to write the current configuration to:

```
~/.config/procps/toprc
```

This saves:
- Column selection and order
- Sort field
- Update interval
- Color settings
- Display toggles (idle, threads, forest view, etc.)
- Window configurations

The saved config is loaded automatically on next start.

### Reset to defaults

Delete the config file:

```sh
rm ~/.config/procps/toprc
# On older systems it may be at:
rm ~/.toprc
```

---

## Signals from top

You can send signals to processes directly from `top`:

| Key | Action |
|---|---|
| `k` | Kill — prompts for PID then signal number |
| `r` | Renice — prompts for PID then new nice value |

### Sending a signal with `k`

1. Press `k`
2. Type the PID (defaults to the top-listed process)
3. Press `Enter`
4. Type a signal number or name (default is 15 = SIGTERM)
5. Press `Enter`

Common signals:

| Number | Name | Meaning |
|---|---|---|
| `1` | SIGHUP | Reload config (convention) |
| `2` | SIGINT | Interrupt (like ctrl+c) |
| `9` | SIGKILL | Force kill — cannot be caught or ignored |
| `15` | SIGTERM | Graceful terminate (default) |
| `18` | SIGCONT | Continue a stopped process |
| `19` | SIGSTOP | Stop — cannot be caught or ignored |

### Renice with `r`

1. Press `r`
2. Type the PID
3. Enter new nice value (-20 to 19; lower = higher priority; requires root for negative values)

---

## Alternatives to top

| Tool | Notes |
|---|---|
| `htop` | Enhanced top with mouse support, color, horizontal scrolling, tree view by default |
| `btop` | Modern, graphical TUI with charts, mouse support |
| `atop` | Logs to disk; can replay historical system state |
| `glances` | Python-based; network, disk, sensors in one view |
| `ps` | Non-interactive snapshot; scriptable; pairs well with `grep` / `awk` |
| `pidstat` | Per-process CPU/memory/I/O statistics over time (from `sysstat`) |
| `vmstat` | System-wide virtual memory, CPU, I/O statistics |
| `iostat` | Disk I/O statistics per device |
| `iotop` | Like top but sorted by disk I/O |
| `nethogs` | Like top but sorted by network bandwidth per process |

---

## Quick Cheatsheet

### Startup flags

| Flag | Meaning |
|---|---|
| `-u USER` | Filter by user |
| `-p PID[,PID]` | Monitor specific PIDs |
| `-d SECS` | Update interval |
| `-n N` | Exit after N updates |
| `-b` | Batch (non-interactive) mode |
| `-H` | Thread mode |
| `-i` | Hide idle processes |
| `-c` | Full command line |
| `-o FIELD` | Initial sort field |
| `-w WIDTH` | Output width |

### Interactive — display

| Key | Action |
|---|---|
| `1` | Per-CPU breakdown |
| `c` | Toggle command line |
| `H` | Toggle threads |
| `i` | Toggle idle |
| `v` | Tree / forest view |
| `l` `t` `m` | Toggle header lines |
| `E` / `e` | Cycle memory units |
| `z` | Toggle color |
| `Z` | Configure colors |
| `B` | Toggle bold |
| `W` | Save configuration |

### Interactive — sorting & filtering

| Key | Action |
|---|---|
| `P` | Sort by CPU |
| `M` | Sort by memory |
| `T` | Sort by time |
| `N` | Sort by PID |
| `R` | Reverse sort |
| `<` / `>` | Shift sort column |
| `f` | Field manager |
| `u` | Filter by user |
| `o` | Add filter expression |
| `=` | Clear filters |

### Interactive — actions

| Key | Action |
|---|---|
| `k` | Send signal to process |
| `r` | Renice process |
| `d` | Change update interval |
| `q` | Quit |
| `h` | Help |
| `W` | Write config |
| `A` | Alternate window mode |

### Header fields at a glance

| CPU field | Meaning |
|---|---|
| `us` | User space |
| `sy` | Kernel |
| `ni` | Niced user |
| `id` | Idle |
| `wa` | I/O wait |
| `hi` | Hardware IRQ |
| `si` | Software IRQ |
| `st` | Steal (VM) |

---

*Source: `man top` (procps-ng). Behavior and available fields vary between Linux distributions and macOS. Run `top -v` to check your version.*