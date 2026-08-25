## Pre-Installation Preparation


### Hardware Verification

**BIOS/UEFI Configuration**: Access the BIOS/UEFI settings before booting the Arch installation media. Enable UEFI boot mode if installing on modern hardware, and disable Secure Boot to avoid signature verification complications. Configure the boot order to prioritize the USB device containing the Arch installation media.[1][2]

**Boot Mode Verification**: After booting into the live environment, verify the system is running in the intended boot mode. Use the command `cat /sys/firmware/efi/fw_platform_size` to check UEFI mode; if it returns 64, the system boots in UEFI mode. For BIOS systems, this file will not exist.[3]

**Disk Device Identification**: Once booted into the live system, identify the target storage devices using `lsblk` or `fdisk` commands. These tools display all block devices recognized by the system, including internal drives and external USB devices. Common device designations include `/dev/sda`, `/dev/nvme0n1` for NVMe SSDs, and `/dev/mmcblk0` for SD cards.[3]

**Storage Capacity**: Ensure the target disk has sufficient capacity for the desired installation; minimal Arch installations require approximately 1-2 GB, though practical systems typically need 20+ GB. Check storage space using `lsblk -h` to display sizes in human-readable format.[2][3]

### Network Setup

**Initial Network Status**: The live installation environment has systemd-networkd, systemd-resolved, iwd, and ModemManager enabled by default and preconfigured. This automatic configuration means network connectivity is typically functional immediately upon boot for supported hardware.[3]

**Interface Detection**: List available network interfaces using `ip link`. This command displays all network adapters including Ethernet ports and wireless cards. Output includes interface names like `eth0`, `wlan0`, or manufacturer-specific names like `wlp1s0`.[4][1][3]

**Wireless Configuration**: For wireless connections, verify the wireless card is not blocked by checking rfkill status with `rfkill list`. If blocked, unblock the card with `rfkill unblock wlan`. Use the `iwctl` command-line interface to scan for available networks and connect. Basic steps include entering `iwctl` interactive mode, scanning networks with `station name_of_adapter get-networks`, and connecting with `station name_of_adapter connect network_name`.[2][3]

**DHCP Configuration**: For most networks, DHCP provides automatic IP address and DNS server assignment. Systemd-networkd handles this automatically for Ethernet, WLAN, and WWAN interfaces out of the box. After connecting to the network (either physically or wirelessly), addresses are typically assigned automatically.[4][3]

**Static IP Configuration**: If the network lacks a DHCP server, configure a static IP address manually using iproute2 commands. This requires specifying the IP address, subnet mask, gateway, and DNS servers.[4]

**Connectivity Verification**: Test network connectivity using `ping ping.archlinux.org`. Successful ping responses confirm internet access is functional. This verification is essential before proceeding with package downloads.[2][3]

### System Clock Synchronization

**Automatic Synchronization**: In the live environment, systemd-timesyncd is enabled by default. The system clock synchronizes automatically once internet connection is established.[3]

**Manual Verification**: Verify clock synchronization using `timedatectl` command. This displays current system time, timezone, and synchronization status.[3]

**NTP Enablement**: Ensure NTP (Network Time Protocol) is enabled for automatic time synchronization with the command `timedatectl set-ntp true`. Accurate system time is critical for security and system stability.[2]

### Mirror Optimization

**Mirror Selection**: Arch Linux distributes packages through multiple mirror servers worldwide. Packages must be downloaded from official Arch Linux mirrors during installation.[2]

**Mirror Speed Optimization**: The `reflector` utility optimizes mirror selection based on geographic location and server responsiveness. Command syntax: `reflector -c 'Country Name' -a 12 --sort rate --save /etc/pacman.d/mirrorlist`.[2]

*   **`-c 'Country Name'`**: Specifies geographic location; use single quotes for multi-word country names like 'United States'[2]
*   **`-a 12`**: Selects mirrors updated within the last 12 hours, ensuring current package availability[2]
*   **`--sort rate`**: Sorts mirrors by download speed[2]
*   **`--save /etc/pacman.d/mirrorlist`**: Saves optimized mirror list to the specified path[2]

**Default Configuration**: If reflector is not available or used, the default `/etc/pacman.d/mirrorlist` already contains many mirrors; installation will proceed successfully with default selection.[2]

### Keyboard Layout Configuration

**Live Environment Setup**: Set the keyboard layout for the installation environment using `loadkeys layout_code`. For example, `loadkeys br` configures Brazilian Portuguese layout. This affects only the live environment; the installed system configuration occurs separately.[1]

**Layout Persistence**: The keyboard layout set during installation must be configured in the installed system for persistence. This is typically accomplished through X11 configuration or console configuration.[1]

### Pre-Installation Checklist

**Summary of Prerequisites**:

*   Boot mode (UEFI or BIOS) verified and enabled appropriately[1]
*   Target storage device identified and verified[3]
*   Network connectivity established and tested[3]
*   System clock synchronized[3]
*   Mirror list optimized for location and speed[2]
*   Keyboard layout configured for installation environment[1]
*   Internet access confirmed via `ping` command[3]

**Documentation Review**: Keep the official Arch Linux Installation Guide accessible during the process. Reference materials help clarify commands and decision points.[1][3]

Related topics for enhanced pre-installation preparation include **partitioning planning** (deciding partition layout), **encryption setup** (LUKS configuration), and **backup strategies** for existing data on the target device.[5][3]

Sources
[1] Arch Linux step to step installation guide https://gist.github.com/eltonvs/d8977de93466552a3448d9822e265e38
[2] Comprehensive Arch Linux Installation Guide https://www.liquidweb.com/blog/arch-linux-installation-guide/
[3] Installation guide - ArchWiki https://wiki.archlinux.org/title/Installation_guide
[4] Network configuration - ArchWiki https://wiki.archlinux.org/title/Network_configuration
[5] General recommendations - ArchWiki https://wiki.archlinux.org/title/General_recommendations
[6] How To Install Arch Linux The First Time https://www.youtube.com/watch?v=FxeriGuJKTM
[7] About to install arch for the first time, anything I should ... https://www.reddit.com/r/archlinux/comments/1e1vefc/about_to_install_arch_for_the_first_time_anything/
[8] Arch Linux Installation: Easy Step-by-Step Guide https://linuxconfig.org/arch-linux-installation-easy-step-by-step-guide
[9] Arch Installation Guide https://dev.to/joybtw/arch-installation-guide-7bj

