## Kernel Compilation Process and Config Options


### Kernel Compilation Overview

**Purpose**: Custom kernel with specific features, drivers, and optimizations.[1]

**Advantages** :
- Reduced kernel size 
- Better performance 
- Specific hardware support 
- Security customization 

**Disadvantages** :
- Time-consuming 
- Error-prone 
- Maintenance burden 

**When Needed** :
- Specialized hardware 
- Performance tuning 
- Security hardening 

### Prerequisites

#### Required Packages

**Install Tools** :

```bash
sudo pacman -S base-devel bc pahole
```

**Packages** :
- `base-devel`: Build tools 
- `bc`: Calculator utility 
- `pahole`: Debugging utility 

#### Disk Space

**Requirements** :
- Source: ~200MB 
- Build: ~5-10GB 
- Compiled kernel: ~100-200MB 

**Check Space** :

```bash
df -h /home
```

### Getting Kernel Source

#### Install ABS (Arch Build System)

**Installation**: `sudo pacman -S asp` :

```bash
sudo pacman -S asp
```

#### Download Kernel Sources

**Prepare Directory** :

```bash
mkdir -p ~/kernel
cd ~/kernel
```

**Download from ABS** :

```bash
asp checkout linux
cd linux
```

**Alternative: Manual Download** :

```bash
curl -O https://www.kernel.org/releases/linux-6.8.tar.xz
tar -xf linux-6.8.tar.xz
cd linux-6.8
```

### Kernel Configuration

#### Existing Configuration

**Copy Current Config** :

```bash
zcat /proc/config.gz > .config
```

or

```bash
cp /boot/config-$(uname -r) .config
```

#### Configuration Methods

**menuconfig (Recommended)** :

```bash
make menuconfig
```

Interactive menu-based configuration .

**oldconfig** :

```bash
make oldconfig
```

Updates existing config .

**defconfig** :

```bash
make defconfig
```

Default configuration .

**gconfig (GUI)** :

```bash
make gconfig
```

Graphical interface .

### Common Kernel Options

#### General Setup

**Processor Type** :

```
Processor type and features → Processor family
```

Choose matching CPU .

**Optimizations** :

```
Processor type and features → Optimization level
```

- `-O2`: Default 
- `-O3`: Aggressive 

#### Device Drivers

**USB Support** :

```
Device Drivers → USB support
```

**Networking** :

```
Device Drivers → Network device support
```

**Graphics** :

```
Device Drivers → Graphics support
```

**Audio** :

```
Device Drivers → Sound card support
```

#### Filesystem Support

**ext4** :

```
File systems → ext4
```

**BTRFS** :

```
File systems → Btrfs filesystem support
```

**NTFS** :

```
File systems → NTFS file system support
```

#### Security Options

**SELinux** :

```
Security options → NSA SELinux
```

**AppArmor** :

```
Security options → AppArmor support
```

**Secure Boot** :

```
Security options → EFI Secure Boot
```

### Building the Kernel

#### Compile Process

**Prepare** :

```bash
make clean
make mrproper
```

**Configure** :

```bash
make menuconfig
```

**Build** :

```bash
make -j$(nproc)
```

Uses all CPU cores .

**Expected Time** :
- 15-60 minutes depending on hardware 
- Monitor with `watch -n 1 'top -b -n 1'` 

#### Build Modules

**Compile Modules** :

```bash
make modules -j$(nproc)
```

**Install Modules** :

```bash
sudo make modules_install
```

#### Install Kernel

**Install Kernel** :

```bash
sudo make install
```

**Copies kernel to /boot** .

### Building Custom Kernel from PKGBUILD

#### Using AUR Method

**Download PKGBUILD** :

```bash
cd ~/kernel-build
git clone https://aur.archlinux.org/linux.git
cd linux
```

**Edit PKGBUILD** :

```bash
nano PKGBUILD
```

Modify options :

```bash
_config="config"        # Use custom config
_localversion="-custom" # Kernel suffix
```

**Custom Config** :

Place `.config` in source directory .

**Build** :

```bash
makepkg -s
```

**Install** :

```bash
sudo pacman -U linux-custom-*.pkg.tar.zst
sudo pacman -U linux-headers-custom-*.pkg.tar.zst
```

### Bootloader Configuration

#### systemd-boot Entry

**Create File**: `/boot/loader/entries/arch-custom.conf` :

```
title Arch Linux (Custom Kernel)
linux /vmlinuz-linux-custom
initrd /initramfs-linux-custom.img
options root=PARTUUID=... rw
```

#### GRUB Configuration

**Regenerate GRUB** :

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Automatically detects new kernel .

### Kernel Parameters

#### Boot Parameters

**Add to Kernel Command Line** :

```
options ... quiet splash nomodeset
```

**Common Parameters** :
- `nomodeset`: Disable graphics during boot 
- `quiet`: Suppress messages 
- `ro`: Mount read-only 

#### CPU-Specific Options

**Enable CPU Optimizations** :

```
CONFIG_GENERIC_CPU=n
CONFIG_MARCH_NATIVE=y
```

**Performance** :

```
CONFIG_HZ=1000
CONFIG_HZ_1000=y
```

### Kernel Module Building

#### Out-of-Tree Modules

**Build Module** :

```bash
make -C /path/to/kernel M=$(pwd) modules
```

**Install Module** :

```bash
sudo make -C /path/to/kernel M=$(pwd) modules_install
```

#### Module Parameters

**Set on Boot** :

In kernel command line or `/etc/modprobe.d/` :

```
options module_name param1=value param2=value
```

### Optimization Techniques

#### CPU Detection

**Native Optimizations** :

```bash
./scripts/config --enable CONFIG_GENERIC_CPU=n
./scripts/config --enable CONFIG_MARCH_NATIVE=y
```

**Automatic Detection** :

```bash
make menuconfig
# Processor type → Native optimization
```

#### Reduce Size

**Minimal Config** :

```bash
make allnoconfig
```

**Add Only Needed** :

```bash
./scripts/config --enable CONFIG_MODULES
./scripts/config --enable CONFIG_EXT4_FS
```

#### Performance Tuning

**Preemption** :

```
General setup → Preemption Model
```

Choose "Fully Preemptible" for responsiveness .

**Scheduler** :

```
Processor type → Scheduler type
```

### Troubleshooting

#### Compilation Fails

**Missing Dependencies** :

```bash
sudo pacman -S bison flex ncurses
```

**Config Error** :

```bash
make mrproper
make menuconfig
```

Reset and reconfigure .

#### Kernel Won't Boot

**Boot to Fallback** :

Select fallback initramfs in bootloader .

**Check Messages** :

```bash
dmesg | tail -50
```

**Rebuild with Debug** :

```bash
make clean
make -j1
```

Slower but better error messages .

#### Module Loading Fails

**Reload Modules** :

```bash
sudo modprobe -r module_name
sudo modprobe module_name
```

**Check Compatibility** :

```bash
modinfo module_name
```

### Performance Testing

#### Before/After Comparison

**Record Baseline** :

```bash
time stress-ng --cpu 4 --timeout 60
```

**After Compilation** :

```bash
time stress-ng --cpu 4 --timeout 60
```

Compare results .

#### Benchmark Tools

**Geekbench** :

```bash
pacman -S geekbench
```

**Sysbench** :

```bash
pacman -S sysbench
```

### Kernel Development Tips

#### Version Control

**Git Access** :

```bash
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
git checkout v6.8
```

#### Documentation

**Build Docs** :

```bash
make htmldocs
```

**Read Docs** :

```bash
firefox Documentation/html/index.html
```

#### Kernel Parameters

**Current Parameters** :

```bash
cat /proc/cmdline
```

**Change at Runtime** :

```bash
echo value | sudo tee /proc/sys/kernel/parameter
```

### Best Practices

**Start with Arch Config**: Use existing config as base .

**Backup Before Compiling**: Create restore point .

**Keep Old Kernel**: Keep working kernel as fallback .

**Document Changes**: Record config modifications .

**Test on VM First**: Try custom kernel in virtual machine .

**Use Binary Search**: Bisect for problem-causing option .

**Monitor Performance**: Benchmark before and after .

**Join Forums**: Seek help from community .

### Common Configurations

#### Minimal Kernel

**For Servers** :

```
CONFIG_MODULES=y
CONFIG_MODULES_UNLOAD=n
CONFIG_SYN_COOKIES=y
CONFIG_IP_DEFRAG=n
```

#### Performance Kernel

**For Workstations** :

```
CONFIG_PREEMPT=y
CONFIG_HZ=1000
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_SCALING=y
```

#### Security Kernel

**Hardened** :

```
CONFIG_KASAN=y
CONFIG_UBSAN=y
CONFIG_SECURITY_APPARMOR=y
CONFIG_FORTIFY_SOURCE=y
```

***

This comprehensive guide on kernel compilation completes the Arch Linux system administration documentation, providing users with advanced knowledge for building custom kernels optimized for their specific needs and hardware configurations.

Sources
[1] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

