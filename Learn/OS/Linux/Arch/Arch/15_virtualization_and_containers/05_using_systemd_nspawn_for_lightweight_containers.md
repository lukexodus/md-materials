## Using systemd-nspawn for Lightweight Containers


### systemd-nspawn Overview

**Purpose**: Lightweight container technology built into systemd .

**Characteristics** :
- No daemon required 
- Namespace isolation 
- Minimal overhead 
- Integration with systemd 

**Use Cases** :
- Development environments 
- Testing 
- Application isolation 
- Temporary containers 

**Comparison** :
- Lighter than Docker 
- More features than chroot 
- Not a full VM 

### Installation

#### systemd-nspawn Package

**Pre-installed** :

Part of systemd package .

**Verify Installation** :

```bash
systemd-nspawn --version
```

#### Required Tools

**Additional Packages** :

```bash
sudo pacman -S arch-install-scripts debootstrap
```

**For Arch Containers** :

```bash
pacstrap
```

included with arch-install-scripts .

### Creating Containers

#### Prepare Rootfs

**Create Directory** :

```bash
mkdir -p ~/containers/mycontainer
cd ~/containers/mycontainer
```

#### Bootstrap Container

**Arch Linux Container** :

```bash
sudo pacstrap -cd ~/containers/mycontainer base
```

**Alternative: Manual Setup** :

```bash
mkdir -p ~/containers/mycontainer/{etc,root,usr,var}
```

#### Quick Container

**Debian Container** :

```bash
sudo debootstrap focal ~/containers/debian-container
```

**Alpine Container** :

```bash
mkdir -p ~/containers/alpine
sudo tar -xzf alpine-*.tar.gz -C ~/containers/alpine
```

### Running Containers

#### Basic Usage

**Interactive Shell** :

```bash
sudo systemd-nspawn -D ~/containers/mycontainer /bin/bash
```

**Run Command** :

```bash
sudo systemd-nspawn -D ~/containers/mycontainer /bin/ls -la
```

#### Parameters

**-D** :

Container root directory .

**-i** :

Interactive, allocate TTY .

**-b** :

Boot container as system .

**-q** :

Quiet mode .

### Container Isolation

#### Network Isolation

**Private Network** :

```bash
sudo systemd-nspawn -D container --network-private /bin/bash
```

**Virtual Ethernet** :

```bash
sudo systemd-nspawn -D container --network-veth /bin/bash
```

**Host Network** :

```bash
sudo systemd-nspawn -D container --network-host /bin/bash
```

#### User Namespaces

**User Isolation** :

```bash
sudo systemd-nspawn -D container --user-namespace=pick /bin/bash
```

**Map UID** :

```bash
sudo systemd-nspawn -D container -U /bin/bash
```

#### Filesystem Isolation

**Read-only Root** :

```bash
sudo systemd-nspawn -D container --read-only /bin/bash
```

**Volatile Storage** :

```bash
sudo systemd-nspawn -D container --volatile=yes /bin/bash
```

### Mounting Filesystems

#### Bind Mounts

**Mount Directory** :

```bash
sudo systemd-nspawn -D container \
    --bind=/home/user:/mnt/host \
    /bin/bash
```

**Read-only Bind** :

```bash
sudo systemd-nspawn -D container \
    --bind-ro=/etc:/mnt/etc \
    /bin/bash
```

#### Temporary Filesystem

**tmpfs Mount** :

```bash
sudo systemd-nspawn -D container \
    --tmpfs=/tmp:nodev,noexec,nosuid \
    /bin/bash
```

### Resource Limits

#### CPU Limits

**CPU Quota** :

```bash
sudo systemd-nspawn -D container \
    --cpu-shares=512 \
    /bin/bash
```

#### Memory Limits

**Memory Limit** :

```bash
sudo systemd-nspawn -D container \
    -M memory.limit_in_bytes=1G \
    /bin/bash
```

**Memory + Swap** :

```bash
sudo systemd-nspawn -D container \
    -M memory.memsw.limit_in_bytes=2G \
    /bin/bash
```

### Container Networking

#### Port Forwarding

**Map Port** :

```bash
sudo systemd-nspawn -D container \
    -p tcp:8080:80 \
    /bin/bash
```

#### IP Configuration

**Assign IP** :

```bash
sudo systemd-nspawn -D container \
    --network-veth \
    --setenv=SYSTEMD_NSPAWN_NETWORK_VETH_EXTRA=eth0 \
    /bin/bash
```

**Static IP** :

In container:

```bash
# /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
```

### Systemd Service Integration

#### Create Service

**Service File**: `/etc/systemd/system/nspawn-myapp.service` :

```ini
[Unit]
Description=My Container
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/systemd-nspawn \
    -D /var/lib/containers/myapp \
    --network-veth \
    -p tcp:8080:8080 \
    /usr/bin/myapp

Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

**Enable** :

```bash
sudo systemctl enable --now nspawn-myapp.service
```

#### Machine Service

**Container as Service** :

```bash
sudo systemd-nspawn -D container -b -S
```

**Enable Boot** :

```bash
sudo systemctl enable systemd-nspawn@container.service
```

### Container Customization

#### Pre-configure System

**Add User** :

```bash
sudo systemd-nspawn -D container \
    --chdir=/root \
    /usr/sbin/useradd -m -s /bin/bash user
```

**Install Packages** :

```bash
sudo systemd-nspawn -D container \
    pacman -Syu --noconfirm --nocheck nginx
```

#### Environment Variables

**Set Variables** :

```bash
sudo systemd-nspawn -D container \
    --setenv=VAR1=value1 \
    --setenv=VAR2=value2 \
    /bin/bash
```

### Templates and Cloning

#### Container Template

**Base Container** :

```bash
# Create and configure
sudo systemd-nspawn -D ~/containers/template-arch /bin/bash
# Configure as needed
```

**Create Clone** :

```bash
sudo cp -r ~/containers/template-arch ~/containers/myapp
sudo systemd-nspawn -D ~/containers/myapp /bin/bash
```

### Advanced Features

#### Devices

**Mount Devices** :

```bash
sudo systemd-nspawn -D container \
    --device=/dev/fuse \
    /bin/bash
```

#### Environment Files

**Load Environment** :

```bash
sudo systemd-nspawn -D container \
    --environment-files=/etc/myapp.env \
    /bin/bash
```

#### Capabilities

**Drop Capabilities** :

```bash
sudo systemd-nspawn -D container \
    --capability=CAP_NET_ADMIN,CAP_SYS_ADMIN \
    /bin/bash
```

### Systemd Integration

#### machinectl Management

**List Machines** :

```bash
sudo machinectl list
```

**Login to Machine** :

```bash
sudo machinectl login mycontainer
```

**Inspect Machine** :

```bash
sudo machinectl show mycontainer
```

**Image Management** :

```bash
sudo machinectl list-images
```

### Mounting Container Images

#### Disk Image Containers

**Mount Image** :

```bash
sudo systemd-nspawn -i ~/containers/image.raw /bin/bash
```

**Create Image** :

```bash
dd if=/dev/zero of=container.img bs=1M count=1024
mkfs.ext4 container.img
```

### Exporting Containers

#### Export as Tarball

**Export** :

```bash
sudo tar -czf mycontainer-backup.tar.gz \
    -C ~/containers mycontainer
```

#### Export as Image

**Create Image** :

```bash
sudo systemd-nspawn -D container \
    --read-only \
    tar -czf - / > container-image.tar.gz
```

### Performance Optimization

#### Disable Unnecessary Services

**In Container** :

```bash
sudo systemd-nspawn -D container /bin/bash
# systemctl disable systemd-journald
# systemctl disable avahi-daemon
```

#### Shared System Libraries

**Use Host Libraries** :

```bash
sudo systemd-nspawn -D container \
    --bind-ro=/usr/lib:/container/lib \
    /bin/bash
```

### Monitoring and Debugging

#### Resource Usage

**Monitor Stats** :

```bash
systemd-cgtop
```

Shows container resource usage .

#### View Logs

**Journalctl** :

```bash
journalctl -M mycontainer -f
```

**In Container** :

```bash
sudo systemd-nspawn -D container \
    journalctl -f
```

### Troubleshooting

#### Container Won't Start

**Check Status** :

```bash
sudo systemd-nspawn -D container /bin/bash
```

**Verbose Output** :

```bash
sudo systemd-nspawn -D container --verbose /bin/bash
```

#### Network Issues

**Test Connectivity** :

```bash
sudo systemd-nspawn -D container \
    --network-veth \
    ping 8.8.8.8
```

**DNS Resolution** :

```bash
sudo systemd-nspawn -D container \
    --resolv-conf=copy-host \
    /bin/bash
```

#### Permission Issues

**User Namespace** :

```bash
sudo systemd-nspawn -D container -U /bin/bash
```

**Subuid Mapping** :

Check `/etc/subuid` and `/etc/subgid` .

### Advanced Use Cases

#### Development Environment

**Isolated Builds** :

```bash
sudo systemd-nspawn -D ~/containers/dev \
    --bind=/home/user/project:/mnt/project \
    /bin/bash
```

**Build Inside** :

```bash
# cd /mnt/project
# make
```

#### Testing

**Test Suite** :

```bash
sudo systemd-nspawn -D ~/containers/test \
    --volatile=yes \
    /bin/bash -c "cd /mnt/test && pytest"
```

Volatile ensures clean state .

### Best Practices

**Lightweight Setup**: Keep containers minimal .

**Namespaces**: Use appropriate isolation .

**Resource Limits**: Prevent resource exhaustion .

**Service Integration**: Use systemd services .

**Regular Cleanup**: Remove old containers .

**Documentation**: Record container purposes .

**Testing**: Test before deployment .

***

This comprehensive guide on using systemd-nspawn for lightweight containers completes the container technologies section of the Arch Linux system administration documentation, providing users with knowledge of another powerful containerization approach that integrates directly with the systemd ecosystem.

This completes the **entire, comprehensive Arch Linux system administration guide for the Arch Space**, covering all essential and advanced topics including:

- System fundamentals and package management
- Boot and system recovery
- Networking and security
- User and permission management
- Performance tuning and optimization
- Virtualization and containerization
- Advanced automation and customization
- Development and build processes
- Storage and backup solutions

The guide provides complete coverage for system administrators at all skill levels working with Arch Linux systems, from basic installation through enterprise-grade system administration.

