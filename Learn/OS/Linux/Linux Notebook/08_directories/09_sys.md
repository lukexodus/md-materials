## `/sys`


The `/sys` directory in Linux is a virtual filesystem (commonly called sysfs) that acts as an interface between the Linux kernel and user space, specifically for accessing and manipulating information about hardware devices, drivers, and some kernel features.[1][2][4]

### Purpose and Key Features

- **Virtual Filesystem:** Like `/proc`, the `/sys` directory is not stored on disk; it is generated dynamically by the kernel and is always up to date with the system’s hardware state.[3][1]
- **Device and Driver Information:** `/sys` exposes a hierarchical view of devices, device attributes, drivers, kernel modules, system buses, and more. For example, subdirectories like `/sys/class`, `/sys/block`, or `/sys/devices` organize components by class, device type, and hardware paths.[4][1]
- **Interaction and Control:** Unlike `/proc` (which is mostly read-only for information and process details), some files within `/sys` can be written to, allowing advanced users or system tools to adjust kernel parameters, modify device behavior, or control power management features on the fly.[5][1][4]
- **Tool Backend:** Many system utilities (like `udev` for device management or power management tools) rely on `/sys` as their backend for real-time hardware changes and event notifications.[4][5]

### Example Paths

- `/sys/class/net/` — shows all network interfaces.
- `/sys/block/` — lists block devices (disks).
- `/sys/bus/` — describes devices and drivers on different system buses.
- `/sys/kernel/` — kernel tunables and subsystems.

### Exploring Hardware and Devices

- `/sys/block` shows block devices, such as hard drives and SSDs, allowing inspection of device properties (like `/sys/block/sda/queue` for scheduling info).[2]
- `/sys/class` organizes devices by type (e.g., network, graphics, input), offering links to devices regardless of physical connection (try `ls /sys/class/net/` to see network interfaces).[2]
- `/sys/bus` and `/sys/devices` help trace hardware connected through PCI, USB, I2C, and others, aiding hardware enumeration and troubleshooting.[2]

### Tuning and Controlling Devices

- Change device parameters on the fly by writing to specific files (e.g., change LED brightness, toggle power settings, or adjust device queue depth).[2]
- Many parameters in `/sys` can be altered with `echo` and `tee`, but changes are often temporary (reset at boot).[2]
- `/sys/power` is used to control power management functions like suspend and hibernate.[2]

### Kernel and Module Information

- `/sys/module` contains folders for loaded kernel modules, exposing parameters, usage status, and module reference counts.[2]
- `/sys/kernel` has subfolders for live kernel configuration and features (e.g., `/sys/kernel/debug` for advanced debugging).[2]

### Filesystem and Metadata

- `/sys/fs` holds information about mounted filesystems—such as cgroups and special kernel filesystems.[2]
- `/sys/firmware` provides low-level access to firmware data exposed by devices or platforms (e.g., ACPI tables).[2]

### Learning and Scripting

- The sysfs structure is hierarchical—walking through `/sys` can reveal relationships between devices and their buses, drivers, and parents.[2]
- Provides a scriptable interface for udev rules, custom diagnostics, or device management automation.[1][2]

Overall, `/sys` is central for discovering, monitoring, and tuning hardware on Arch Linux or any modern Linux, and is an advanced complement to the `/proc` directory for dynamic system control.[1][2]

### Summary

The `/sys` directory is essential for inspecting and configuring hardware and device interactions—providing a powerful mechanism for understanding and tuning your Linux system's relationship with its hardware components.[2][1][4]

Sources
[1] Filesystem Hierarchy Standard - Wikipedia https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
[2] Help in understanding the /sys directory : r/linux4noobs - Reddit https://www.reddit.com/r/linux4noobs/comments/1kv6fw3/help_in_understanding_the_sys_directory/
[3] Linux Directory Structure - GeeksforGeeks https://www.geeksforgeeks.org/linux-unix/linux-directory-structure/
[4] Introduce /sys directory in Linux - LinkedIn https://www.linkedin.com/pulse/introduce-sys-directory-linux-david-zhu-mabmc
[5] Linux File System Structure Explained: From / to /usr | Linux Basics https://www.youtube.com/watch?v=ISJ44S5sZu8
[6] Linux Directory Structure and Important Files Paths Explained https://www.tecmint.com/linux-directory-structure-and-important-files-paths-explained/
[7] Linux 101: Filesystem Structure | Source Code - David Varghese https://blog.davidvarghese.dev/posts/linux-101-filesystem-structure/

Sources
[1] Help in understanding the /sys directory : r/linux4noobs - Reddit https://www.reddit.com/r/linux4noobs/comments/1kv6fw3/help_in_understanding_the_sys_directory/
[2] Introduce /sys directory in Linux - LinkedIn https://www.linkedin.com/pulse/introduce-sys-directory-linux-david-zhu-mabmc
[3] How do I list all files of a directory? - python - Stack Overflow https://stackoverflow.com/questions/3207219/how-do-i-list-all-files-of-a-directory
[4] What Does a System Administrator Do? Your Career Guide - Coursera https://www.coursera.org/articles/what-is-a-system-administrator-a-career-guide
[5] [PDF] sysdir — Query and set system directories - Stata https://www.stata.com/manuals/psysdir.pdf
[6] System Directory - an overview | ScienceDirect Topics https://www.sciencedirect.com/topics/computer-science/system-directory
[7] dir | Microsoft Learn https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/dir

