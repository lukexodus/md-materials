## Linux Basics


### Unix History and Philosophy

Unix originated in 1969 at Bell Labs, developed by Ken Thompson and Dennis Ritchie. The system was designed around several core principles that continue to influence Linux today. The Unix philosophy emphasizes creating small, focused programs that do one thing well and can be combined through pipes and redirection to accomplish complex tasks.

**Key Points:**

- Unix was initially written in assembly language, then rewritten in C in 1972, making it highly portable
- The philosophy of "everything is a file" treats devices, processes, and system resources as files in the filesystem
- The modular design allows components to be easily replaced or upgraded
- Multi-user and multi-tasking capabilities were built into the system from early versions

The Unix family tree includes various commercial versions like AIX, Solaris, and HP-UX, as well as open-source variants. Linux, created by Linus Torvalds in 1991, follows Unix principles while being built from scratch as a free alternative to proprietary Unix systems.

### Open Source Licensing

Linux operates under the GNU General Public License (GPL), specifically GPL version 2 for the kernel. This licensing model ensures that the source code remains freely available and that any derivative works must also be released under compatible licenses.

The GPL requires that anyone distributing Linux or GPL-licensed software must provide access to the source code. This "copyleft" approach differs from permissive licenses like BSD or MIT, which allow proprietary derivatives. The Free Software Foundation, founded by Richard Stallman, developed the GPL to protect software freedom.

**Key Points:**

- GPL v2 ensures source code availability and prevents proprietary forks
- Different components may use different licenses (libraries often use LGPL)
- Some drivers and firmware use proprietary licenses, creating licensing complexity
- The license has legal implications for commercial software distribution

### Linux Distributions Overview

A Linux distribution combines the Linux kernel with system software, package management, and user applications to create a complete operating system. Distributions serve different purposes and target various user bases.

Major distribution families include:

**Debian-based distributions** use the Advanced Package Tool (APT) and .deb packages. Ubuntu, based on Debian, focuses on user-friendliness and regular release cycles. Debian itself emphasizes stability and free software principles.

**Red Hat-based distributions** use RPM packages and YUM or DNF package managers. Red Hat Enterprise Linux (RHEL) targets enterprise environments, while Fedora serves as a testing ground for new technologies. CentOS (now CentOS Stream) provides a free alternative to RHEL.

**Arch-based distributions** follow a rolling release model with the Pacman package manager. Arch Linux emphasizes simplicity and user control, requiring manual configuration. Manjaro provides a more user-friendly Arch experience.

**SUSE-based distributions** include openSUSE and SUSE Linux Enterprise, popular in European enterprise environments.

**Key Points:**

- Package management systems handle software installation, updates, and dependencies
- Release models vary from fixed releases (Ubuntu) to rolling releases (Arch)
- Desktop environments like GNOME, KDE, and XFCE can be installed on most distributions
- Specialized distributions exist for security (Kali), privacy (Tails), and embedded systems

### Kernel vs Userspace

The Linux system architecture separates into kernel space and user space, providing security and stability through privilege separation.

**Kernel Space** operates with the highest privileges and direct hardware access. The kernel manages:

- Process scheduling and memory management
- Device drivers and hardware abstraction
- System calls that provide interfaces to user programs
- File systems and network protocols
- Security and access control

The kernel runs in protected mode, with its own memory space isolated from user applications. Kernel modules can be loaded and unloaded dynamically, allowing device driver updates without rebooting.

**User Space** contains all applications and services running with restricted privileges. User programs cannot directly access hardware or manipulate other processes without kernel mediation. This includes:

- System daemons and services
- User applications and GUI programs
- System utilities and command-line tools
- Programming language runtimes and interpreters

Communication between user space and kernel space occurs through well-defined interfaces:

- System calls provide programmatic access to kernel functions
- Device files in /dev allow controlled hardware access
- Virtual filesystems like /proc and /sys expose kernel information
- Signals enable process communication and control

**Key Points:**

- Privilege separation prevents user programs from crashing the system
- System calls act as controlled entry points into kernel functionality
- Virtual memory management isolates processes from each other
- The kernel can run in either monolithic or microkernel architectures (Linux uses monolithic)

**Example:** When a user program needs to read a file, it calls the open() system call. The kernel validates permissions, locates the file on storage, and returns a file descriptor. Subsequent read() calls go through the kernel to access the actual data, maintaining security boundaries.

This separation allows Linux to maintain system stability while providing powerful capabilities to user applications through controlled interfaces.

---

