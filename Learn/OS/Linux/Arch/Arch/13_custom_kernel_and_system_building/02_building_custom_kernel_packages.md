## Building Custom Kernel Packages


### Custom Kernel Package Overview

**Purpose**: Create installable kernel packages maintaining Arch standards .

**Advantages** :
- Easy installation and removal 
- Version tracking 
- Dependency management 
- System integration 

**Method**: Build using PKGBUILD .

### Preparation

#### Required Tools

**Install Dependencies** :

```bash
sudo pacman -S base-devel asp git bc pahole
```

**Build Directory** :

```bash
mkdir -p ~/kernel-custom
cd ~/kernel-custom
```

#### Get Arch Kernel PKGBUILD

**Clone from AUR** :

```bash
git clone https://aur.archlinux.org/linux.git
cd linux
```

or

**Use asp** :

```bash
asp checkout linux
cd linux
trunk
```

### Understanding PKGBUILD

#### PKGBUILD Structure

**Standard Sections** :

```bash
# Metadata
pkgname=linux-custom
pkgver=6.8.0
pkgrel=1

# Sources and checksums
source=("kernel.tar.xz")
sha256sums=('...')

# Build function
build() {
    ...
}

# Package function
package() {
    ...
}
```

#### Key Variables

**Package Name** :

```bash
pkgname=linux-custom
```

Affects kernel name .

**Local Version** :

```bash
_localversion="-custom"
```

Appended to kernel version .

**Build Flags** :

```bash
_config="config"  # Use custom .config
```

### Creating Custom PKGBUILD

#### Copy and Modify

**Backup Original** :

```bash
cp PKGBUILD PKGBUILD.orig
```

**Edit PKGBUILD** :

```bash
nano PKGBUILD
```

#### Modify Package Name

**Change Name** :

```bash
pkgname=linux-custom
pkgbase=linux-custom
```

**Update Depends** :

```bash
depends=('coreutils' 'kmod' 'initramfs')
optdepends=('crda: to set the correct wireless channels of your country')
```

#### Set Local Version

**Kernel Suffix** :

```bash
_localversion="-custom"
```

Results in `6.8.0-custom` .

#### Configuration Options

**Use Custom Config** :

```bash
_config="config"
```

or

**Modify Build Function** :

```bash
build() {
    cd linux-$pkgver
    
    # Use existing config
    cp ../.config .
    
    # Or generate from menu
    make menuconfig
    
    # Build
    make -j$(nproc)
}
```

### Building Custom Kernel

#### Prepare Configuration

**Copy Base Config** :

```bash
zcat /proc/config.gz > .config
```

or

```bash
cp /boot/config-$(uname -r) .config
```

**Place in Build Directory** :

```bash
cp .config linux/
```

#### Create Patch (Optional)

**Modify Kernel** :

```bash
cd linux-$pkgver
# Make your changes
cd ..
```

**Create Patch** :

```bash
diff -Naur linux-original linux-modified > custom.patch
```

**Add to PKGBUILD** :

```bash
source=("kernel.tar.xz" "custom.patch")
```

**Apply in build()** :

```bash
patch -p1 < ../custom.patch
```

#### Build Process

**Start Build** :

```bash
makepkg -s
```

**Parameters** :
- `-s`: Install missing dependencies 
- `-c`: Clean before build 
- `-r`: Remove build directory 

**Expected Output** :

```
linux-custom-6.8.0-1-x86_64.pkg.tar.zst
linux-custom-headers-6.8.0-1-x86_64.pkg.tar.zst
```

#### Monitor Build

**Watch Progress** :

```bash
watch -n 5 'ps aux | grep make'
```

or

```bash
tail -f build.log
```

**Typical Time** :
- 30-120 minutes depending on hardware 

### Installing Custom Kernel

#### Install Packages

**Install Kernel** :

```bash
sudo pacman -U linux-custom-*.pkg.tar.zst
```

**Install Headers** :

```bash
sudo pacman -U linux-custom-headers-*.pkg.tar.zst
```

**Install Both** :

```bash
sudo pacman -U linux-custom*.pkg.tar.zst
```

#### Bootloader Configuration

**systemd-boot Entry** :

Create `/boot/loader/entries/arch-custom.conf`:

```
title   Arch Linux Custom
linux   /vmlinuz-linux-custom
initrd  /initramfs-linux-custom.img
options root=PARTUUID=... rw
```

**GRUB** :

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Automatically detects new kernel .

#### First Boot

**Reboot** :

```bash
sudo reboot
```

**Select Custom Kernel** :

Choose from boot menu .

**Verify** :

```bash
uname -r
```

Should show `-custom` suffix .

### Advanced PKGBUILD Customization

#### Optimization Options

**CPU-Specific** :

In `build()`:

```bash
./scripts/config --set-str CONFIG_MARCH native
```

**Performance** :

```bash
./scripts/config --set-str CONFIG_HZ 1000
./scripts/config --enable CONFIG_PREEMPT_FULL
```

#### Modular Build

**All Modules** :

```bash
./scripts/config --enable CONFIG_MODULES
./scripts/config --enable CONFIG_MODULES_UNLOAD
```

**Module Signing** :

```bash
./scripts/config --enable CONFIG_MODULE_SIG
```

#### Security Options

**SELinux** :

```bash
./scripts/config --enable CONFIG_SECURITY_SELINUX
```

**AppArmor** :

```bash
./scripts/config --enable CONFIG_SECURITY_APPARMOR
```

**KASAN** :

```bash
./scripts/config --enable CONFIG_KASAN
```

### Custom PKGBUILD Example

#### Full Example

**Complete PKGBUILD** :

```bash
pkgbase=linux-custom
pkgname=linux-custom
pkgver=6.8.0
pkgrel=1
pkgdesc="Linux kernel with custom optimizations"
arch=('x86_64')
url="https://www.kernel.org/"
license=('GPL2')

depends=('coreutils' 'kmod' 'initramfs')
makedepends=('bc' 'pahole' 'gcc' 'binutils' 'make')

source=("https://www.kernel.org/releases/linux-${pkgver}.tar.xz"
        "config")
sha256sums=('...')

_kernelname=-custom
_localversion="-custom"

build() {
    cd linux-$pkgver
    
    # Use provided config
    cp ../config .config
    
    # Optional: Run menuconfig
    # make menuconfig
    
    # Build kernel and modules
    make -j$(nproc)
}

package() {
    cd linux-$pkgver
    
    # Install kernel
    install -Dm644 arch/x86/boot/bzImage \
        "$pkgdir/boot/vmlinuz-${pkgbase}"
    
    # Install System.map
    install -Dm644 System.map \
        "$pkgdir/usr/lib/modules/${pkgver}${_localversion}/build/System.map"
    
    # Install modules
    make INSTALL_MOD_PATH="$pkgdir/usr" modules_install
    
    # Remove build and source links
    rm -f "$pkgdir"/usr/lib/modules/${pkgver}${_localversion}/{build,source}
}
```

### Testing Custom Kernel

#### Verify Build Quality

**Check Size** :

```bash
ls -lh linux-custom*.pkg.tar.zst
```

**Verify Installation** :

```bash
pacman -Qi linux-custom
```

#### Boot Testing

**Safe Testing** :

1. Keep original kernel 
2. Create new boot entry 
3. Boot custom kernel 
4. Test stability 

**Performance Baseline** :

```bash
time stress-ng --cpu 4 --timeout 60
```

#### System Stress Test

**Full Load** :

```bash
stress-ng --cpu 4 --vm 2 --timeout 300
```

**Monitor** :

```bash
watch -n 1 'top -b -n 1'
```

### Troubleshooting

#### Build Fails

**Missing Dependencies** :

```bash
sudo pacman -S bison flex ncurses perl python
```

**Config Error** :

```bash
make clean
make oldconfig
make menuconfig
```

**Start Fresh** :

```bash
makepkg -c
```

#### Boot Issues

**Doesn't Boot** :

1. Boot fallback initramfs 
2. Boot original kernel 
3. Review build log 
4. Check kernel parameters 

**Module Loading** :

```bash
lsmod | grep module_name
modinfo module_name
```

#### Performance Issues

**Degraded Performance** :

Review kernel options :

```
Processor type → Optimization level
```

**Try Default Settings** :

Rebuild without custom options .

### Maintaining Custom Kernel

#### Version Updates

**New Kernel Version** :

1. Update `pkgver` in PKGBUILD 
2. Update source URL 
3. Update checksums 
4. Rebuild 

**Script to Update** :

```bash
#!/bin/bash
NEW_VER=$1
sed -i "s/pkgver=.*/pkgver=$NEW_VER/" PKGBUILD
makepkg -f --checksums
```

#### Configuration Preservation

**Save Working Config** :

```bash
cp linux/.config saved-config-6.8.0
```

**Reuse Config** :

```bash
cp saved-config-6.8.0 linux/.config
```

### Creating Package Repository

#### Local Repository

**Create Directory** :

```bash
mkdir -p ~/kernel-repo
cp linux-custom*.pkg.tar.zst ~/kernel-repo/
```

**Add to pacman.conf** :

```ini
[custom-kernels]
SigLevel = Optional TrustAll
Server = file:///home/user/kernel-repo
```

**Build Database** :

```bash
cd ~/kernel-repo
repo-add custom-kernels.db.tar.gz *.pkg.tar.zst
```

#### Install from Repository

**Update Database** :

```bash
sudo pacman -Sy
```

**Install** :

```bash
sudo pacman -S linux-custom
```

### Automation

#### Build Script

**Automate Builds** :

```bash
#!/bin/bash

VERSION=$1
WORKDIR=~/kernel-build

mkdir -p $WORKDIR
cd $WORKDIR

# Get source
git clone https://aur.archlinux.org/linux.git
cd linux

# Configure
sed -i "s/pkgver=.*/pkgver=$VERSION/" PKGBUILD

# Build
makepkg -s --noconfirm

# Install
sudo pacman -U linux-custom*.pkg.tar.zst --noconfirm
```

**Usage** :

```bash
./build-kernel.sh 6.8.0
```

### Best Practices

**Backup Configuration**: Save working .config .

**Test in VM**: Try before main system .

**Keep Original**: Maintain stock kernel .

**Document Changes**: Record modifications .

**Version Control**: Store PKGBUILD in git .

**Monitor Performance**: Benchmark changes .

**Regular Updates**: Keep current with upstream .

***

This comprehensive guide on building custom kernel packages completes the advanced Arch Linux system administration documentation, providing users with production-ready methods for creating, maintaining, and distributing custom kernels while maintaining compatibility with the Arch packaging ecosystem.

