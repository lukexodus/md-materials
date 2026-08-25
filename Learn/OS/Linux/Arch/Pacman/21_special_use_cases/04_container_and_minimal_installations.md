## Container and Minimal Installations


### Overview

Minimal Arch Linux installations optimize for small size, fast boot, and resource efficiency. Container deployments use Arch Linux as a base for Docker, Podman, and other container runtimes. Both approaches require careful package selection and configuration.

### Minimal Installation Principles

#### Core Concept

**Minimal installation philosophy:**
- Install only essential packages
- Remove unnecessary dependencies
- Disable unneeded services
- Optimize for specific use case
- Maintain system flexibility

**Size comparison:**
- Full desktop installation: 15-50 GB
- Server installation: 5-15 GB
- Minimal installation: 1-3 GB
- Container image: 500 MB - 2 GB

### Planning Minimal Installation

#### Define System Purpose

**Server:**
- No GUI
- SSH access
- Core services only
- Minimal packages

**Embedded system:**
- Very small footprint
- Limited resources
- Specific functionality
- No unnecessary tools

**Container:**
- Single purpose
- Minimal layering
- Fast startup
- Small image size

#### Identify Required Packages

**Essential packages (always needed):**
```bash
base               # Arch Linux base
linux              # Kernel
systemd            # Init system
pacman             # Package manager
sudo               # Privilege escalation
```

**Conditional packages:**
```bash
# Networking
dhcpcd             # DHCP client
openssh            # SSH server
curl wget          # Download tools

# Administration
vim nano           # Editors
htop               # System monitor
tmux screen        # Terminal multiplexer

# Utilities
bash-completion    # Command completion
man-db             # Manual pages
```

### Building Minimal Systems

#### Minimal Server Installation

**PKGBUILD for minimal server:**
```bash
#!/bin/bash
# Install minimal server

packages_essential=(
    base
    linux
    linux-firmware
    systemd
    pacman
    sudo
    grub
    efibootmgr
)

packages_system=(
    dhcpcd
    openssh
    curl
    wget
    nano
    htop
)

# Install only essential
sudo pacman -S --needed "${packages_essential[@]}"

# Optionally add system packages
# sudo pacman -S --needed "${packages_system[@]}"

# Remove unneeded packages
sudo pacman -Rns man-db git base-devel
```

#### Minimal Chroot Installation

**Create lean system:**
```bash
# Bootstrap
sudo tar -xzf archlinux-bootstrap-*.tar.zst -C /mnt/minimal

# Enter chroot
sudo arch-chroot /mnt/minimal/root.x86_64/

# Inside chroot - minimal installation
pacman -S base linux grub efibootmgr

# Remove unnecessary packages
pacman -Rns man-db base-devel linux-headers git

# Setup only essential services
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# Exit
exit
```

#### Container Base Image

**Create minimal container image:**
```bash
# From minimal chroot setup
sudo tar -czf minimal-arch-base.tar.gz -C /mnt/minimal root.x86_64/

# Verify size
du -sh minimal-arch-base.tar.gz
```

### Docker Container Creation

#### Dockerfile for Minimal Image

**Basic minimal image:**
```dockerfile
# Dockerfile - Minimal Arch Linux

FROM archlinux:base

# Update package database
RUN pacman -Syu --noconfirm

# Install only essential packages
RUN pacman -S --noconfirm \
    bash \
    curl \
    wget \
    ca-certificates

# Clean package cache
RUN pacman -Scc --noconfirm

# Set working directory
WORKDIR /app

# Default command
CMD ["/bin/bash"]
```

**Build image:**
```bash
docker build -t minimal-arch:latest .
```

**Check image size:**
```bash
docker images minimal-arch
```

**Typical sizes:**
- Minimal: 300-500 MB
- With utilities: 500-800 MB
- Full base: 800 MB+

#### Optimized Multi-Stage Build

```dockerfile
# Multi-stage build for smaller images

FROM archlinux:base as builder

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel git

WORKDIR /build
COPY . .

# Build application
RUN make clean && make

# Runtime stage - minimal
FROM archlinux:base

# Copy only built artifacts
COPY --from=builder /build/app /usr/local/bin/

# Install minimal runtime dependencies
RUN pacman -S --noconfirm ca-certificates && \
    pacman -Scc --noconfirm

ENTRYPOINT ["/usr/local/bin/app"]
```

**Build:**
```bash
docker build -t app:minimal -f Dockerfile .
```

#### Application-Specific Container

**Python application:**
```dockerfile
FROM archlinux:base

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm python python-pip

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pacman -Scc --noconfirm

COPY app.py .
CMD ["python", "app.py"]
```

**Node.js application:**
```dockerfile
FROM archlinux:base

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm nodejs npm

WORKDIR /app
COPY package*.json ./
RUN npm ci --production
RUN pacman -Scc --noconfirm

COPY . .
CMD ["node", "app.js"]
```

### Podman Container Creation

#### Containerfile for Podman

**Containerfile (Podman equivalent):**
```dockerfile
# Containerfile - Minimal Arch with Podman

FROM archlinux:base

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm curl wget ca-certificates
RUN pacman -Scc --noconfirm

WORKDIR /app
CMD ["/bin/bash"]
```

**Build:**
```bash
podman build -t minimal-arch:latest -f Containerfile .
```

**Run:**
```bash
podman run -it minimal-arch:latest
```

### Size Optimization Techniques

#### Package Cache Cleaning

**In Dockerfile:**
```dockerfile
# After installations
RUN pacman -Scc --noconfirm
```

**Effect:**
- Removes package cache
- Saves ~1-2 GB per image layer

#### Removing Build Dependencies

```dockerfile
FROM archlinux:base

# Build stage
RUN pacman -S --noconfirm gcc make
RUN gcc --version  # Verify build tools

# Remove build tools after use
RUN pacman -Rns --noconfirm gcc make

# Verify removal
RUN which gcc || echo "gcc removed"
```

#### Consolidating RUN Commands

**Inefficient (multiple layers):**
```dockerfile
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm package1
RUN pacman -S --noconfirm package2
RUN pacman -Scc --noconfirm
```

**Efficient (single layer):**
```dockerfile
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm package1 package2 && \
    pacman -Scc --noconfirm
```

#### Using .dockerignore

**.dockerignore file:**
```
.git
.gitignore
*.md
tests/
docs/
```

Prevents unnecessary files in build context.

### Minimal System Configuration

#### Services Configuration

**Disable unnecessary services:**
```bash
# SSH server (if needed)
sudo systemctl enable sshd

# Networking
sudo systemctl enable systemd-networkd
sudo systemctl enable systemd-resolved

# Disable graphical targets
sudo systemctl set-default multi-user.target
```

**Disable unused services:**
```bash
# List services
systemctl list-unit-files

# Disable
sudo systemctl disable bluetooth.service
sudo systemctl disable cups.service
```

#### Kernel Parameters

**Optimize for minimal system:**
```bash
# /etc/sysctl.conf
vm.swappiness=10
net.core.netdev_max_backlog=5000
```

**Reduce kernel modules:**
```bash
# Check loaded modules
lsmod

# Prevent loading unneeded modules
echo "install usb_storage /bin/true" | sudo tee -a /etc/modprobe.d/disable-modules.conf
```

### Container Registry and Distribution

#### Build for Multiple Architectures

**Build multi-arch image:**
```bash
# Using buildx (Docker)
docker buildx build --platform linux/amd64,linux/arm64 \
    -t myrepo/minimal-arch:latest \
    --push .

# Using Podman
podman build --arch amd64 -t minimal-arch:amd64 .
podman build --arch arm64 -t minimal-arch:arm64 .
```

#### Push to Registry

**Docker Hub:**
```bash
# Tag image
docker tag minimal-arch:latest myusername/minimal-arch:latest

# Push
docker push myusername/minimal-arch:latest
```

**Private registry:**
```bash
# Tag for private registry
docker tag minimal-arch:latest registry.example.com/minimal-arch:latest

# Push
docker push registry.example.com/minimal-arch:latest
```

### Minimal Installation Scripts

#### Automated Minimal Setup

```bash
#!/bin/bash
# minimal-install.sh - Automate minimal installation

set -e

# Configuration
HOSTNAME="minimal-host"
TIMEZONE="UTC"
PACKAGES_ESSENTIAL="base linux grub efibootmgr"
PACKAGES_SYSTEM="dhcpcd curl wget"

echo "Creating minimal Arch installation..."

# Mount and bootstrap
mkdir -p /mnt/minimal
mount /dev/sda2 /mnt/minimal
cd /mnt/minimal

# Extract bootstrap
tar -xzf ../archlinux-bootstrap-*.tar.zst

# Enter chroot
arch-chroot root.x86_64/ /bin/bash << CHROOT_END

# Configure system
echo "$HOSTNAME" > /etc/hostname
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# Install packages
pacman -Sy
pacman -S --noconfirm $PACKAGES_ESSENTIAL $PACKAGES_SYSTEM

# Create user
useradd -m user
echo "Set password for user:"
passwd user

# Setup bootloader
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Rebuild initramfs
mkinitcpio -P

echo "Installation complete"

CHROOT_END

echo "Unmounting..."
cd /
umount -R /mnt/minimal

echo "Done - ready to reboot"
```

#### Container Build Automation

```bash
#!/bin/bash
# build-minimal-containers.sh

ARCHITECTURES=("amd64" "arm64")
REGISTRY="myregistry.com"
IMAGE_NAME="minimal-arch"

for arch in "${ARCHITECTURES[@]}"; do
    echo "Building for $arch..."
    
    docker buildx build \
        --platform "linux/$arch" \
        -t "$REGISTRY/$IMAGE_NAME:$arch" \
        --push \
        .
    
    echo "Pushed: $REGISTRY/$IMAGE_NAME:$arch"
done

# Create manifest
docker manifest create "$REGISTRY/$IMAGE_NAME:latest" \
    "$REGISTRY/$IMAGE_NAME:amd64" \
    "$REGISTRY/$IMAGE_NAME:arm64"

docker manifest push "$REGISTRY/$IMAGE_NAME:latest"
echo "Manifest created: $REGISTRY/$IMAGE_NAME:latest"
```

### Minimal System Analysis

#### Measure Installation Size

```bash
# Check disk usage
du -sh /
du -sh /usr /var /opt

# List largest packages
expac -H M '%m\t%n' | sort -rh | head -20

# Find largest files
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

#### Analyze Container Layers

```bash
# Inspect image layers
docker history minimal-arch:latest

# Check image size breakdown
docker inspect minimal-arch:latest | grep -A5 Size

# Analyze layer efficiency
dive minimal-arch:latest  # Requires 'dive' tool
```

### Best Practices

**Installation:**
- Remove build tools after building
- Consolidate package operations
- Clean caches after installations
- Use --needed flag to avoid reinstalls

**Containers:**
- Use multi-stage builds
- Minimize layer count
- Clean caches in each layer
- Remove documentation and debug packages

**Optimization:**
- Profile actual size contributors
- Remove unused packages
- Use base images effectively
- Test minimal configurations

**Maintenance:**
- Document package rationale
- Track dependency changes
- Automate builds and testing
- Version images appropriately

### Typical Minimal Sizes

**Bare system (just kernel/bootloader):**
- 500 MB on disk
- 250 MB compressed

**Server (with SSH, utilities):**
- 2-3 GB on disk
- 500-800 MB compressed
- ~800 MB Docker image

**Container base image:**
- 300-500 MB compressed
- 800 MB - 1.2 GB extracted

**Full application container:**
- 500 MB - 2 GB depending on runtime/dependencies

Minimal installations and container images demonstrate Arch Linux's flexibility and efficiency, enabling deployment on resource-constrained systems while maintaining the full power of the package management system.
