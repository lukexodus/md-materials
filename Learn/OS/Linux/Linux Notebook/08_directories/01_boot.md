## `/boot`


The `/boot` directory in Linux systems, including Arch Linux, stores critical files required to start the operating system. The most important of these are the Linux kernel, the initial RAM disk (initrd or initramfs), and the bootloader's static configuration files.[5][9]

### What `/boot` Contains

- **Kernel Images:** The kernel, typically named `vmlinuz-linux` or similarly, is the core part of the operating system, loaded into memory at boot to handle hardware and system management.[6][8]
- **Initial RAM Disk (initrd or initramfs):** This is a compressed file, like `initramfs-linux.img`, containing a minimal filesystem loaded into memory before the main system is accessible. Its main function is to provide the necessary drivers and tools needed to mount the real root filesystem, especially needed if your root filesystem is on an advanced storage device or encrypted partition.[2][5]
- **Bootloader Files:** Files that belong to the system's bootloader (such as GRUB) are also stored here, including binaries and configuration files—these direct how the boot process proceeds and where to find the relevant kernel and initramfs images.[9]

### Role in the Boot Process

- When the system powers on, the bootloader (such as GRUB) accesses the `/boot` directory to load both the kernel and the initramfs into memory.[9]
- The kernel itself requires modules and drivers to properly set up hardware; the initramfs provides a temporary root filesystem in memory so these critical drivers can be loaded before the main root filesystem is mounted.[7][5]
- After the kernel is running and has initialized hardware using helpers from initramfs, it then “switches root” to the actual root filesystem on disk and starts the real system's user-space initialization.[8][6]

### Summary Table

| File/Folder                 | Purpose                                                                              |
|-----------------------------|--------------------------------------------------------------------------------------|
| Kernel image (e.g. vmlinuz) | Core operating system loaded first for hardware & system management [6]         |
| Initramfs/initrd            | Minimal, memory-resident OS for loading drivers to access real root filesystem [5]|
| Bootloader files            | Controls how and where the kernel/initramfs are loaded from [9]                  |

These static files in `/boot` are essential for a successful system startup; if damaged or deleted, the system may become unbootable.[9]

Sources
[1] Using the initial RAM disk (initrd) — The Linux Kernel documentation https://www.kernel.org/doc/html/v4.16/admin-guide/initrd.html
[2] Initial ramdisk - Wikipedia https://en.wikipedia.org/wiki/Initial_ramdisk
[3] 12.3. Booting with the Initial Ramdisk https://www.novell.com/documentation/suse91/suselinux-adminguide/html/ch12s03.html
[4] 30.5. Verifying the Initial RAM Disk Image - Red Hat Documentation https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/deployment_guide/sec-verifying_the_initial_ram_disk_image
[5] Introduction to the boot process | Administration Guide | SLES 15 SP7 https://documentation.suse.com/sles/15-SP7/html/SLES-all/cha-boot.html
[6] Understanding the (Embedded) Linux boot process https://kleinembedded.com/understanding-the-embedded-linux-boot-process/
[7] Initial RAM Disk (initramfs) in Linux Boot Process https://www.gopakumar-rajappan.com/p/initial-ram-disk-initramfs-in-linux
[8] Understanding the Linux Boot Process - by Karl William https://opensourceisfun.substack.com/p/understanding-the-linux-boot-process
[9] Arch boot process - ArchWiki https://wiki.archlinux.org/title/Arch_boot_process
[10] How Linux Kernel Boots? https://www.geeksforgeeks.org/linux-unix/how-linux-kernel-boots/
[11] The Kernel Boot Process https://manybutfinite.com/post/kernel-boot-process
[12] The Linux Booting Process - 6 Steps Described in Detail https://www.freecodecamp.org/news/the-linux-booting-process-6-steps-described-in-detail/
[13] Using the initial RAM disk (initrd) https://docs.kernel.org/admin-guide/initrd.html
[14] Looking forward to Linux network configuration in the initial ... https://www.redhat.com/en/blog/network-confi-initrd

