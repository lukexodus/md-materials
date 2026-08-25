## udev


**Udev** is a device manager for the Linux kernel that dynamically creates and manages device nodes in the `/dev` directory in response to hardware events.  It runs as a userspace daemon (not in kernel space) that listens for hardware hotplug events and responds with configurable rules.[1][3]

### Core Functionality

Udev handles device detection and management automatically when hardware is connected to or disconnected from a system, including USB devices, storage drives, network adapters, and peripherals.  When a device is detected, udev matches the device against configured rules and performs actions such as creating device nodes, setting permissions, loading firmware, or executing custom scripts.  Unlike older approaches that maintained static device files, udev provides only the device nodes for hardware currently present on the system.[2][1]

### Key Features

**Persistent device naming** ensures devices get the same name regardless of discovery order or which port they're connected to, rather than relying on kernel discovery order which can vary between boots.  This is achieved through identifiers like `/dev/disk/by-id/`, `/dev/disk/by-path/`, and `/dev/disk/by-uuid/`, which provide stable references to devices.[3][1]

Udev executes entirely in userspace, which improves system security and stability by preventing low-level hardware handling from destabilizing the kernel.  The administrative command-line utility `udevadm` provides diagnostics and troubleshooting capabilities.[1]

### On Arch Linux

On Arch Linux, udev is typically integrated with systemd, and the daemon runs as `systemd-udevd.service`.  Udev rules on Arch are located in `/usr/lib/udev/rules.d` for system rules and `/usr/local/lib/udev/rules.d` for custom rules.  You can customize behavior by creating rules that respond to specific device properties like vendor ID, device ID, or physical connection location.[6][7][3]

Sources
[1] udev https://en.wikipedia.org/wiki/Udev
[2] An introduction to Udev: The Linux subsystem for ... https://opensource.com/article/18/11/udev
[3] udev - ArchWiki https://wiki.archlinux.org/title/Udev
[4] what is udev? what does it do? : r/archlinux https://www.reddit.com/r/archlinux/comments/1apvd9k/what_is_udev_what_does_it_do/
[5] Udev: Introduction to Device Management In Modern ... https://www.linux.com/news/udev-introduction-device-management-modern-linux-system/
[6] udev https://www.freedesktop.org/software/systemd/man/udev.html
[7] udev https://wiki.debian.org/udev
[8] Linux Device Management | Udev https://www.youtube.com/watch?v=vbCviEih15s
[9] Linux Network Interface Configuration With udev https://packetpushers.net/blog/udev/


