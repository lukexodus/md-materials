## Installing Base System and Kernel


### Pacstrap Overview

**Purpose**: Pacstrap is a crucial utility designed to install a foundational Arch Linux system into a newly mounted partition or chroot directory. It encapsulates complex steps including creating obligatory directories, setting up the new system root, copying the keyring, and installing specified packages. Pacstrap is pre-installed on the official Arch installation media.[1][2]

**Prerequisites**: The target mount point must be a valid, pre-mounted filesystem before running pacstrap. An active internet connection is required to download packages from repositories. Root privileges are necessary to execute pacstrap.[2]

### Basic Installation Command

**Standard Command**: `pacstrap -K /mnt base linux linux-firmware`.[3][2]

**Parameters**:
*   **`-K`**: Initializes a new pacman keyring instead of copying the host system's keyring. This ensures the installed system uses its own independent keyring.[1]
*   **`/mnt`**: The mount point where the system will be installed (can be any mounted directory).[3][2]
*   **`base`**: The base package group containing essential system utilities, shells, and tools required for a functional Arch system.[4][3]
*   **`linux`**: The default Linux kernel package.[4][3]
*   **`linux-firmware`**: Firmware files for common hardware components, enabling drivers and device detection.[4][3]

### Kernel Alternatives

**Kernel Variants**: The standard `linux` package can be substituted with alternative kernels depending on system requirements:[3]

*   **`linux`**: Default stable kernel with latest features and optimizations[3]
*   **`linux-lts`**: Long-Term Support kernel receiving updates for extended periods, ideal for stability-focused systems[5][4]
*   **`linux-zen`**: Community-driven kernel with performance-oriented patches[3]
*   **`linux-hardened`**: Kernel with security-focused hardening patches[3]

**Alternative Installation**: `pacstrap -K /mnt base linux-lts linux-firmware` installs the LTS kernel instead of the default.[4]

**Omitting Kernel**: The kernel can be omitted entirely when installing in containers or virtual machines, though this is unusual for standard installations.[3]

### Firmware Considerations

**Omitting Firmware**: Linux-firmware can be omitted when installing in virtual machines or containers that do not require hardware-specific drivers. Bare-metal installations require firmware for hardware support.[3]

**Microcode Updates**: Optional microcode packages improve CPU stability and security:[6][4]
*   **`intel-ucode`**: Intel processor microcode updates[6][4]
*   **`amd-ucode`**: AMD processor microcode updates[4]

These packages enable BIOS to apply security patches and performance optimizations at boot time.[4]

### Extended Installation Example

**Comprehensive Base Installation**: `pacstrap -K /mnt base base-devel linux-lts linux-firmware intel-ucode git vim networkmanager`.[6][4]

This command installs:
*   **`base`**: Essential system packages[4]
*   **`base-devel`**: Development tools including compiler, build utilities, and makepkg for package building[1][6]
*   **`linux-lts`**: Long-term support kernel[4]
*   **`linux-firmware`**: Hardware firmware[4]
*   **`intel-ucode`**: Intel microcode updates[4]
*   **`git`**: Version control system[4]
*   **`vim`**: Text editor[4]
*   **`networkmanager`**: Network configuration utility[6]

### Pacstrap Internal Operations

**Workflow**: Pacstrap performs the following steps internally:[2]

1. Creates obligatory system directories in the target root[2]
2. Establishes the new system root via chroot preparation[2]
3. Copies the pacman keyring to the new system[2]
4. Invokes pacman to install specified packages to the target[2]
5. Copies the mirror list to the new system for future package management[2]

**Mirror List Integration**: The mirror list from the live environment (`/etc/pacman.d/mirrorlist`) is automatically copied to the installed system, eliminating the need for manual mirror configuration.[2]

### Installation Options

**Interactive Mode**: `pacstrap -i /mnt base linux linux-firmware` prompts for confirmation before installing each package.[2]

**Custom Configuration**: Additional flags modify pacstrap behavior:[2]

*   **`-C /path/to/pacman.conf`**: Use an alternate pacman configuration file[2]
*   **`-M`**: Use the package cache from the host system instead of the target[2]

### Minimal Installation

**Minimal Base System**: For specialized scenarios such as containers or minimal deployments, use `pacstrap /mnt base` without kernel or firmware. Further configuration occurs post-installation.[3]

### Post-Installation Entry

**Chroot Environment**: After pacstrap completes, enter the newly installed system using `arch-chroot /mnt`. This command changes root into the new system, enabling further configuration as if booted into the installed system.[3][2]

**Chroot Purpose**: Within the chroot, perform essential configuration including:
*   Generating fstab with `genfstab -U /mnt >> /mnt/etc/fstab`[3]
*   Setting timezone[3]
*   Configuring localization[3]
*   Setting hostname[3]
*   Configuring network settings[3]
*   Setting root password[3]
*   Installing bootloader[3]

### Architecture-Specific Installation

**Current Architecture Only**: Pacstrap installs packages for the current live environment architecture (x86_64 on Arch official media). Cross-architecture installation requires specialized tools and configuration.[3]

Sources
[1] pacstrap - ArchWiki https://wiki.archlinux.org/title/Pacstrap
[2] pacstrap man https://linuxcommandlibrary.com/man/pacstrap
[3] Installation guide - ArchWiki https://wiki.archlinux.org/title/Installation_guide
[4] Share your pacstrap : r/archlinux https://www.reddit.com/r/archlinux/comments/szo572/share_your_pacstrap/
[5] pacstrap linux-lts without ever installing 'linux' package ... https://bbs.archlinux.org/viewtopic.php?id=170660
[6] Qqe | pacstrap /mnt - for installing "base" system ? * smart ? ... https://www.facebook.com/groups/archlinuxen/posts/10158041194078393/
[7] Arch Linux Installation: Pacstrap installs essential packages https://www.youtube.com/watch?v=VyElHkfnUDg
[8] Arch Linux https://en.wikipedia.org/wiki/Arch_Linux
[9] Base Installation of Arch Linux + Good to Know https://www.isticktoit.net/?p=2304

