## Creating Arch Spin or ISO with ArchISO


### ArchISO Overview

**Purpose**: Tool to create custom Arch Linux ISO images.[1]

**Use Cases** :
- Create custom installation media 
- Build system snapshots 
- Distribute preconfigured systems 
- Create live environments 

**Installation**: `sudo pacman -S archiso`.[1]

### ArchISO Components

#### Directory Structure

**Typical Layout** :

```
myiso/
├── airootfs/          # Root filesystem contents
│   ├── etc/
│   ├── root/
│   └── usr/
├── efiboot/
├── isolinux/
├── pacman.conf        # Package manager config
├── packages.both      # Common packages
├── packages.x86_64    # Architecture-specific
├── profiledef.sh      # Profile definition
└── grub.cfg           # Bootloader config
```

#### Key Files

**profiledef.sh** :

Defines ISO metadata and settings .

**packages.both** :

Packages for all architectures .

**packages.x86_64** :

Architecture-specific packages .

**pacman.conf** :

Package manager configuration .

### Setting Up ArchISO

#### Get ArchISO Template

**Clone from Git** :

```bash
git clone https://git.archlinux.org/archiso.git
cd archiso
git checkout releng  # Stable branch
```

or

**Use Installed Template** :

```bash
mkdir -p ~/iso-build
cp -r /usr/share/archiso/releng/* ~/iso-build/
cd ~/iso-build
```

#### Directory Preparation

**Create Working Directory** :

```bash
mkdir -p ~/iso-build
cd ~/iso-build
```

**Prepare airootfs** :

```bash
mkdir -p airootfs/{etc,root,usr,var/cache/pacman/pkg}
```

### Customizing ISO

#### profiledef.sh Configuration

**Edit Profile** :

```bash
nano profiledef.sh
```

**Key Variables** :

```bash
iso_label="ARCHCUSTOM"          # ISO label
iso_publisher="MyName"           # Publisher
iso_application="My Custom Arch" # Application name
iso_version="2025.01"            # Version
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.grub.esp')
arch="x86_64"
```

#### Package Selection

**Common Packages** :

```bash
nano packages.both
```

**Add Packages** :

```
base
linux
linux-firmware
grub
efibootmgr
networkmanager
vim
nano
git
openssh
```

**X11 Desktop** :

```
xorg-server
xorg-xinit
gnome
gdm
```

**Development** :

```
base-devel
gcc
make
cmake
python
nodejs
```

#### Architecture-Specific

**x86_64 Packages** :

```bash
nano packages.x86_64
```

**GPU Drivers** :

```
nvidia
# or
xf86-video-amdgpu
# or
xf86-video-intel
```

### Building the ISO

#### Basic Build

**Build ISO** :

```bash
cd ~/iso-build
sudo mkarchiso -v -o ~/iso-output .
```

**Parameters** :
- `-v`: Verbose 
- `-o`: Output directory 

**Expected Output** :

```
archcustom-2025.01-x86_64.iso
```

#### Build Process

**Time Estimate** :
- First build: 20-60 minutes 
- Subsequent: 10-30 minutes 

**Monitor** :

```bash
tail -f mkarchiso.log
```

#### Parallel Building

**Speed Up** :

```bash
sudo mkarchiso -v -o ~/iso-output -c 10 .
```

Changes compression level .

### Custom Configuration

#### Pre-Configure System

**Add Files to airootfs** :

```bash
# Add custom config
mkdir -p airootfs/root/.config/
cp ~/.bashrc airootfs/root/.bashrc

# Add startup script
mkdir -p airootfs/root/scripts
cp my-setup.sh airootfs/root/scripts/
```

#### Custom Hook Scripts

**Airootfs Setup** :

Create `airootfs/root/customize_airootfs.sh`:

```bash
#!/bin/bash

set -e

# Run inside chroot during ISO build
# Install additional packages
pacman -Syu --noconfirm

# Enable services
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable gdm

# Create user
useradd -m -s /bin/bash user
echo "user:password" | chpasswd

# Install custom application
cp /opt/myapp /usr/local/bin/
chmod +x /usr/local/bin/myapp
```

**Make Executable** :

```bash
chmod +x airootfs/root/customize_airootfs.sh
```

#### Bootloader Configuration

**GRUB Config** :

```bash
nano airootfs/etc/default/grub
```

**Custom Parameters** :

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_TIMEOUT=10
```

#### Network Configuration

**Default Network Setup** :

```bash
mkdir -p airootfs/etc/systemd/network
```

Create `dhcp.network`:

```
[Match]
Name=*

[Network]
DHCP=yes
```

### ISO Bootloaders

#### Isolinux (BIOS)

**Configuration** :

In `isolinux/isolinux.cfg`:

```
DEFAULT arch
TIMEOUT 50

LABEL arch
    KERNEL vmlinuz-linux
    APPEND initrd=initramfs-linux.img ...
```

#### GRUB (UEFI)

**Configuration** :

In `grub.cfg`:

```
set timeout=10
set default=0

menuentry "Arch Linux" {
    search --set=root --label ARCHCUSTOM
    linux /boot/vmlinuz-linux
    initrd /boot/initramfs-linux.img
}
```

### Advanced Customization

#### Custom Wallpaper

**Add Image** :

```bash
cp wallpaper.png airootfs/usr/share/pixmaps/
```

**Set Default** :

In `airootfs/etc/lightdm/lightdm-gtk-greeter.conf`:

```
background=/usr/share/pixmaps/wallpaper.png
```

#### Pre-installed Applications

**Add Applications** :

```bash
# In packages.both
firefox
thunderbird
libreoffice
```

**Pre-configure** :

```bash
mkdir -p airootfs/root/.mozilla/
cp -r ~/.mozilla/* airootfs/root/.mozilla/
```

#### Custom Services

**Add Service** :

```bash
mkdir -p airootfs/etc/systemd/system/
cp myservice.service airootfs/etc/systemd/system/
```

**Enable** :

In `customize_airootfs.sh`:

```bash
systemctl enable myservice
```

### Building Live Environment

#### Live Boot Support

**Enable Live Mode** :

```bash
cp -r /usr/share/archiso/configs/releng/* ~/iso-build/
```

**Default Packages** :

Included by default .

#### Custom Live Desktop

**Configure Desktop** :

```bash
# Install desktop packages
nano packages.both
```

**Preconfigure Apps** :

```bash
mkdir -p airootfs/root/.config/
```

### Testing ISO

#### QEMU Testing

**Install QEMU** :

```bash
sudo pacman -S qemu
```

**Test Boot** :

```bash
qemu-system-x86_64 -cdrom ~/iso-output/archcustom-2025.01-x86_64.iso -m 2G
```

**With EFI** :

```bash
qemu-system-x86_64 \
    -cdrom ~/iso-output/archcustom-2025.01-x86_64.iso \
    -m 2G \
    -bios /usr/share/edk2-ovmf/x64/OVMF.fd
```

#### VirtualBox Testing

**Create VM** :

1. Create new VM 
2. Set ISO as boot device 
3. Boot and test 

#### USB Testing

**Write to USB** :

```bash
sudo dd if=~/iso-output/archcustom-2025.01-x86_64.iso of=/dev/sdX bs=4M status=progress
sudo sync
```

**Physical Boot** :

1. Insert USB 
2. Boot from USB 
3. Verify functionality 

### Distribution

#### Sign ISO

**Create Signature** :

```bash
gpg --detach-sign ~/iso-output/archcustom-2025.01-x86_64.iso
```

**Verify Later** :

```bash
gpg --verify archcustom-2025.01-x86_64.iso.sig
```

#### Create Checksums

**SHA256** :

```bash
sha256sum ~/iso-output/archcustom-2025.01-x86_64.iso > SHA256SUMS
```

**Verification** :

```bash
sha256sum -c SHA256SUMS
```

#### Host Downloads

**Simple HTTP** :

```bash
cd ~/iso-output
python -m http.server 8000
```

**Mirror** :

Setup rsync to distribute .

### Build Automation

#### Automated Build Script

**Build Script** :

```bash
#!/bin/bash

ISO_BUILD_DIR=~/iso-build
ISO_OUTPUT=~/iso-output
ISO_VERSION=2025.01

cd "$ISO_BUILD_DIR"

# Update packages
sudo pacman -Sy

# Build ISO
sudo mkarchiso -v -o "$ISO_OUTPUT" .

# Sign
gpg --detach-sign "$ISO_OUTPUT/archcustom-${ISO_VERSION}-x86_64.iso"

# Create checksums
cd "$ISO_OUTPUT"
sha256sum * > SHA256SUMS

echo "ISO build complete: archcustom-${ISO_VERSION}-x86_64.iso"
```

#### Scheduled Builds

**Systemd Service** :

```ini
[Unit]
Description=Build Custom Arch ISO

[Service]
Type=oneshot
ExecStart=/usr/local/bin/build-iso.sh
```

**Timer** :

```ini
[Timer]
OnCalendar=monthly
OnBootSec=1h
```

### Troubleshooting

#### Build Fails

**Check Logs** :

```bash
sudo tail -f /tmp/archiso.*/*/build.log
```

**Clean and Retry** :

```bash
sudo mkarchiso -v -c -o ~/iso-output ~/iso-build
```

#### ISO Won't Boot

**Check Bootloader** :

Verify `isolinux.cfg` and `grub.cfg` .

**Verify Filesystem** :

Mount ISO and check structure .

#### Package Installation Issues

**Update Mirrors** :

```bash
sudo pacman -Sc
sudo pacman -Sy
```

**Check Package Names** :

Verify all packages exist .

### Best Practices

**Use Version Control**: Track ISO configuration .

**Document Changes**: Record customizations .

**Test Thoroughly**: Verify before distribution .

**Sign Releases**: Cryptographically sign ISOs .

**Maintain Changelog**: Document version changes .

**Automate Builds**: Use scripts for consistency .

**Archive Old ISOs**: Keep for reference .

***

This comprehensive guide on creating Arch spins and ISOs with ArchISO completes the entire Arch Linux system administration documentation, providing users with the knowledge to create customized, distributable Arch Linux installations tailored to specific needs and requirements.

Sources
[1] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

