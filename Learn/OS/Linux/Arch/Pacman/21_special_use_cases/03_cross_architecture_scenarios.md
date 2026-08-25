## Cross-Architecture Scenarios


### Overview

Cross-architecture package management involves working with Arch Linux packages across different CPU architectures (x86_64, ARM, i686). This is essential for ARM development, maintaining legacy systems, supporting multiple hardware platforms, and developing for embedded devices.

### Arch Linux Architecture Support

#### Official Architectures

**x86_64 (primary):**
- 64-bit Intel/AMD processors
- Full repository support
- Most packages available
- Standard Arch Linux target

**ARM (aarch64):**
- 64-bit ARM (ARMv8+)
- Raspberry Pi 4/5, many SBCs
- Growing package support
- Arch Linux ARM project

**i686 (legacy):**
- 32-bit Intel/AMD processors
- Limited modern support
- Repository archived
- Mostly for legacy systems

**ARM (armv7h):**
- 32-bit ARM (ARMv7)
- Raspberry Pi 3 and earlier
- Limited package availability
- Arch Linux ARM

#### Check System Architecture

```bash
# Current system architecture
uname -m

# Kernel architecture
arch

# Check CPU flags
cat /proc/cpuinfo | grep flags

# Detailed architecture info
lscpu
```

### Multilib Support (x86_64 + i686)

#### Enabling Multilib on x86_64

**Edit pacman.conf:**
```bash
sudo nano /etc/pacman.conf
```

**Uncomment multilib section:**
```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

**Sync databases:**
```bash
sudo pacman -Sy
```

**Verify multilib:**
```bash
pacman -Sl multilib | head -20
```

#### Installing 32-bit Packages

**Install 32-bit package:**
```bash
sudo pacman -S lib32-openssl
sudo pacman -S lib32-gcc-libs
```

**Query 32-bit packages:**
```bash
pacman -Ql lib32-gcc-libs
```

#### Use Cases for Multilib

**Gaming:**
- Wine (Windows compatibility)
- Steam and Proton
- Legacy games

**Development:**
- Cross-compilation for 32-bit targets
- Testing 32-bit code
- 32-bit development libraries

**Legacy applications:**
- Old 32-bit binaries
- Legacy software support

### ARM Development on x86_64

#### Cross-Compilation Setup

**Install cross-compilation toolchain:**
```bash
sudo pacman -S arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-newlib
```

**For Raspberry Pi (armv7h):**
```bash
sudo pacman -S arm-linux-gnueabihf-gcc
```

**For 64-bit ARM (aarch64):**
```bash
sudo pacman -S aarch64-linux-gnu-gcc
```

#### Create Cross-Compilation Environment

**PKGBUILD for ARM:**
```bash
# PKGBUILD for armv7h target

pkgname=my-arm-app
pkgver=1.0
pkgrel=1
arch=('armv7h')
makedepends=('arm-linux-gnueabihf-gcc')

build() {
    cd "$srcdir/$pkgname-$pkgver"
    arm-linux-gnueabihf-gcc -o my-app main.c
}

package() {
    install -Dm755 "$srcdir/$pkgname-$pkgver/my-app" "$pkgdir/usr/bin/my-app"
}
```

**Build:**
```bash
makepkg -s
```

**Transfer to ARM device:**
```bash
scp my-arm-app-1.0-1-armv7h.pkg.tar.zst user@raspberry-pi:/tmp/
```

#### Qemu Emulation

**Install qemu:**
```bash
sudo pacman -S qemu qemu-arch-extra
```

**Run ARM system emulation:**
```bash
# ARM 32-bit
qemu-system-arm -M virt -m 1024 -drive file=arm-image.img

# ARM 64-bit
qemu-system-aarch64 -M virt -m 1024 -drive file=aarch64-image.img
```

### Arch Linux ARM Systems

#### ARM Target Identification

**Common ARM targets:**
- aarch64 - 64-bit ARM (ARMv8+)
- armv7h - 32-bit ARM (ARMv7, optimized for hard float)
- armv6h - 32-bit ARM (ARMv6, Raspberry Pi 1/Zero)

**Verify on ARM device:**
```bash
uname -m
pacman -Q pacman
```

#### Package Management on ARM

**ARM systems use standard pacman:**
```bash
sudo pacman -Syu              # Update
sudo pacman -S package        # Install
sudo pacman -R package        # Remove
```

**ARM-specific considerations:**
- Slower compile times
- Limited package availability for older ARM versions
- Build from source more common (AUR)
- Resource constraints on embedded systems

#### Arch Linux ARM Installation

**For Raspberry Pi (aarch64):**
```bash
# Download image
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz

# Flash to SD card
sudo dd if=ArchLinuxARM-rpi-aarch64-latest.tar.gz of=/dev/mmcblk0 bs=4M

# Boot and configure
```

### Building AUR Packages for Different Architectures

#### Architecture-Specific PKGBUILD

```bash
# PKGBUILD with architecture-specific handling

pkgname=my-multiarch-app
pkgver=1.0
pkgrel=1
arch=('x86_64' 'i686' 'aarch64')

build() {
    case "$CARCH" in
        x86_64)
            ./configure --prefix=/usr --enable-x86-64
            ;;
        i686)
            ./configure --prefix=/usr --enable-i686
            ;;
        aarch64)
            ./configure --prefix=/usr --enable-arm64
            ;;
    esac
    
    make
}

package() {
    make DESTDIR="$pkgdir" install
}
```

#### Build for Multiple Architectures

**Build script:**
```bash
#!/bin/bash
# build-multiarch.sh

ARCHITECTURES=('x86_64' 'i686' 'aarch64')

for arch in "${ARCHITECTURES[@]}"; do
    echo "Building for $arch..."
    
    # Set build environment
    export CARCH="$arch"
    
    # Clean build
    makepkg -Ccis --noconfirm
    
    # Move built package
    mv *.pkg.tar.zst "../packages/$arch/"
done
```

### Remote Package Building

#### Build for ARM on x86_64

**Set up cross-build environment:**
```bash
# In PKGBUILD
arch=('aarch64')

build() {
    # Use cross-compiler
    aarch64-linux-gnu-gcc -o binary main.c
}
```

**Build with cross tools:**
```bash
makepkg -s  # Installs aarch64-linux-gnu-gcc if needed
```

### Maintaining Multiple Architecture Repositories

#### Multi-Architecture Repository Structure

```bash
mkdir -p ~/arch-repo/{x86_64,i686,aarch64}

# Create separate databases
repo-add ~/arch-repo/x86_64/repo.db.tar.gz ~/arch-repo/x86_64/*.pkg.tar.zst
repo-add ~/arch-repo/i686/repo.db.tar.gz ~/arch-repo/i686/*.pkg.tar.zst
repo-add ~/arch-repo/aarch64/repo.db.tar.gz ~/arch-repo/aarch64/*.pkg.tar.zst
```

#### Configure for Multiple Architectures

**pacman.conf on x86_64:**
```ini
[myrepo-x86_64]
Server = file:///home/user/arch-repo/x86_64

[multilib]
Include = /etc/pacman.d/mirrorlist
```

**pacman.conf on ARM:**
```ini
[myrepo-aarch64]
Server = file:///home/user/arch-repo/aarch64
```

### Container/Virtual Machine Approach

#### Using Docker for Different Architectures

**Build multi-architecture images:**
```bash
# Dockerfile
FROM archlinux:base

RUN pacman -Syu --noconfirm
RUN pacman -S base-devel git --noconfirm

WORKDIR /build
```

**Build for different architectures:**
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t myapp .
```

#### Virtual Machine for ARM Development

**Setup VM with QEMU:**
```bash
# Create ARM system image
qemu-system-aarch64 -M virt -m 2048 -cpu cortex-a72 \
    -drive if=virtio,file=arch-arm.img,format=qcow2
```

### Package Compatibility

#### Check Package Availability

**Query across architectures:**
```bash
# On x86_64
pacman -Si package-name

# Check if available for other architectures
# Visit: https://www.archlinux.org/packages/
```

**For ARM packages:**
```bash
# On ARM device
pacman -Si package-name

# Or check Arch Linux ARM packages
# https://archlinuxarm.org/packages
```

#### Handle Missing Packages

**Build from source:**
```bash
# Clone AUR package
git clone https://aur.archlinux.org/package-name.git
cd package-name

# Modify PKGBUILD if needed for ARM
nano PKGBUILD

# Build
makepkg -si
```

**Use alternative packages:**
```bash
# Find similar package
pacman -Ss alternative

# Install
sudo pacman -S alternative-package
```

### Troubleshooting Cross-Architecture Issues

#### Incompatible Binary

**Error:**
```
cannot execute binary file: Exec format error
```

**Cause:** Binary for different architecture

**Solution:**
```bash
# Check binary architecture
file program

# Build for correct architecture
# Or get correct binary for your arch
```

#### Missing Cross-Compilation Tools

**Error:**
```
aarch64-linux-gnu-gcc: command not found
```

**Solution:**
```bash
sudo pacman -S aarch64-linux-gnu-gcc
```

#### Qemu Segmentation Faults

**Error:**
```
Segmentation fault
```

**Solutions:**
- Update qemu
- Use appropriate machine type: `-M virt`
- Increase memory: `-m 2048`
- Enable KVM if available: `-enable-kvm`

#### ARM Build Failures

**Common issues:**
- Floating-point precision differences
- Endianness assumptions
- Memory constraints
- Missing dependencies

**Debug:**
```bash
makepkg -s 2>&1 | tee build.log
# Review log for specific errors
```

### Performance Considerations

#### Build Times by Architecture

**Approximate relative build times:**
- x86_64: 1x (baseline)
- i686: 1.5x (some packages slower)
- aarch64: 2-5x (depends on hardware)
- armv7h: 3-8x (slower ARM hardware)

#### Optimization for Different Architectures

**PKGBUILD optimization:**
```bash
build() {
    case "$CARCH" in
        x86_64)
            ./configure --prefix=/usr -O3
            ;;
        i686)
            ./configure --prefix=/usr -O2
            ;;
        aarch64)
            ./configure --prefix=/usr -O2
            ;;
    esac
}
```

### Best Practices

**Development:**
- Test on actual hardware when possible
- Use qemu for initial testing
- Automate cross-architecture builds
- Maintain separate package repositories

**Compatibility:**
- Support multiple architectures intentionally
- Document architecture-specific requirements
- Test on each supported architecture
- Handle architecture differences in code

**Performance:**
- Optimize for each architecture
- Use appropriate compiler flags
- Consider resource constraints
- Profile on target hardware

**Maintenance:**
- Keep toolchains updated
- Monitor for architecture-specific issues
- Maintain CI/CD for multiple architectures
- Document architecture decisions

Cross-architecture support enables Arch Linux deployment across diverse hardware platforms, from embedded ARM systems to legacy 32-bit machines, maintaining the flexibility and package management excellence across the ecosystem.

