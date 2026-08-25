## Sandboxing and Isolation (firejail, systemd-nspawn)


### Sandboxing Fundamentals

**Purpose**: Isolate applications to limit damage if compromised.[1]

**Benefits**:[1]
- Contain malware 
- Protect privacy 
- Restrict filesystem access 
- Control resource usage 

**Trade-offs** :
- Performance overhead 
- Reduced functionality 
- Increased complexity 

### Firejail

#### Overview

**Lightweight Sandboxing**: User-space application isolation .

**Approach** :
- Namespace isolation 
- seccomp filtering 
- Capability dropping 

**Installation**: `sudo pacman -S firejail`.[1]

#### Basic Usage

**Run Application Sandboxed** :

```bash
firejail application_name
```

**Example** :

```bash
firejail firefox
firejail chromium
```

**Verify Sandbox** :

```bash
firejail --list
```

Shows running sandboxed applications .

#### Profile Configuration

**Profiles**: Pre-configured sandboxes .

**Location**: `/etc/firejail/` .

**Common Profiles** :
- firefox.profile 
- chromium.profile 
- thunderbird.profile 

**List Profiles** :

```bash
firejail --list-profiles
```

#### Custom Profile

**Create Custom Profile** :

Create `/etc/firejail/myapp.profile`:

```
# Sandbox for myapp
noprofile
caps.drop all
seccomp
private-tmp
private-dev
read-only /etc
read-only /usr
```

**Run with Profile** :

```bash
firejail --profile=/etc/firejail/myapp.profile myapp
```

#### Firejail Options

**No Network** :

```bash
firejail --net=none application
```

**Restricted Network** :

```bash
firejail --net=lo application
```

**Private Home** :

```bash
firejail --private application
```

**Private Temp** :

```bash
firejail --private-tmp application
```

**Read-Only Filesystem** :

```bash
firejail --read-only=/etc application
```

**Blacklist** :

```bash
firejail --blacklist=/home/user/sensitive application
```

**Whitelist** :

```bash
firejail --whitelist=/tmp application
```

#### Advanced Configuration

**Capabilities Dropping** :

```bash
firejail --caps.drop=all application
```

**Seccomp Filter** :

```bash
firejail --seccomp application
```

**CPU Limit** :

```bash
firejail --cpu=1 application
```

**Memory Limit** :

```bash
firejail --memory=512 application
```

#### Filesystem Isolation

**Overlay Filesystem** :

```bash
firejail --overlay application
```

**Overlay Temporary** :

```bash
firejail --overlay-tmpfs application
```

**Chroot Environment** :

```bash
firejail --chroot=/path/to/root application
```

### systemd-nspawn

#### Overview

**Container Namespace**: Lightweight containerization .

**Capabilities** :
- Process isolation 
- Filesystem namespaces 
- Network isolation 
- Resource limits 

**Installation**: Part of systemd (pre-installed) .

#### Basic Usage

**Run Container** :

```bash
sudo systemd-nspawn -D /path/to/rootfs /bin/bash
```

**Interactive Container** :

```bash
sudo systemd-nspawn -i -D /path/to/rootfs
```

**Parameters** :
- `-D`: Root directory 
- `-i`: Interactive shell 

#### Network Configuration

**Virtual Network** :

```bash
sudo systemd-nspawn -D /path --network-veth
```

**Host Network** :

```bash
sudo systemd-nspawn -D /path --network-host
```

**Custom Network** :

```bash
sudo systemd-nspawn -D /path --network-interface=eth0
```

#### Mounting Filesystems

**Bind Mount** :

```bash
sudo systemd-nspawn -D /path -b /home/user:/mnt/home
```

**Read-Only Mount** :

```bash
sudo systemd-nspawn -D /path --bind-ro=/etc:/mnt/etc
```

#### Resource Limits

**CPU Shares** :

```bash
sudo systemd-nspawn -D /path --cpu-shares=512
```

**Memory Limit** :

```bash
sudo systemd-nspawn -D /path -M memory.limit_in_bytes=512M
```

#### User Mapping

**User Namespace** :

```bash
sudo systemd-nspawn -D /path --private-users
```

**UID/GID Mapping** :

```bash
sudo systemd-nspawn -D /path --uid-range=1000:1000
```

### Creating Lightweight Containers

#### Prepare Rootfs

**Install Arch in Container** :

```bash
mkdir -p ~/mycontainer
sudo pacstrap -c -d ~/mycontainer base
```

**Configure Container** :

```bash
sudo arch-chroot ~/mycontainer
# Install necessary packages
exit
```

#### Launch Container

**First Boot** :

```bash
sudo systemd-nspawn -D ~/mycontainer -i
```

**Run Service** :

```bash
sudo systemd-nspawn -D ~/mycontainer /usr/bin/myservice
```

### Systemd Service Isolation

#### Service Hardening

**Systemd Unit**: `/etc/systemd/system/myapp.service` :

```ini
[Unit]
Description=My Application
After=network.target

[Service]
ExecStart=/usr/bin/myapp
Type=simple

# Sandboxing
PrivateTmp=yes
PrivateDevices=yes
ProtectSystem=strict
ProtectHome=yes
NoNewPrivileges=yes
ReadOnlyPaths=/
ReadWritePaths=/var/lib/myapp

# Capabilities
CapabilityBoundingSet=~CAP_SYS_ADMIN
CapabilityBoundingSet=~CAP_NET_ADMIN

# Namespace
PrivateNetwork=no
PrivateUsers=yes

[Install]
WantedBy=multi-user.target
```

#### Common Options

**Restrict Filesystem** :

```ini
ProtectSystem=strict
ProtectHome=yes
ReadOnlyPaths=/
ReadWritePaths=/var/lib/service
```

**Restrict Capabilities** :

```ini
CapabilityBoundingSet=~CAP_SYS_MODULE
CapabilityBoundingSet=~CAP_SYS_BOOT
```

**Restrict Syscalls** :

```ini
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM
```

**Resource Limits** :

```ini
MemoryLimit=512M
CPUQuota=50%
LimitNOFILE=1024
```

### Seccomp Filtering

#### Overview

**System Call Filtering**: Restrict allowed syscalls .

**Reduces Attack Surface**: Limits kernel interface .

#### Custom Seccomp Filter

**JSON Format** :

```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "defaultErrnoRet": 1,
  "archMap": [
    {
      "architecture": "SCMP_ARCH_X86_64",
      "subArchitectures": [
        "SCMP_ARCH_X86"
      ]
    }
  ],
  "syscalls": [
    {
      "names": ["read", "write", "exit", "exit_group"],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

**Apply to Container** :

```bash
sudo systemd-nspawn -D /path --security-opt seccomp=filter.json
```

### AppArmor Profiles

#### Installation

**Install AppArmor**: `sudo pacman -S apparmor` .

**Enable Service** :

```bash
sudo systemctl enable --now apparmor.service
```

#### Basic Profile

**Create Profile**: `/etc/apparmor.d/usr.bin.myapp` :

```
#include <tunables/global>

/usr/bin/myapp {
  #include <abstractions/base>
  #include <abstractions/nameservice>
  
  /usr/bin/myapp r,
  /etc/config r,
  /tmp/** rw,
  /var/lib/myapp/** rw,
  
  deny /etc/shadow r,
  deny /root/** r,
}
```

**Load Profile** :

```bash
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.myapp
```

**Set Mode** :

```bash
sudo aa-enforce /usr/bin/myapp
```

### Docker Alternative

#### Installation

**Install Docker** :

```bash
sudo pacman -S docker
sudo systemctl enable --now docker.service
```

**Add User to Group** :

```bash
sudo usermod -aG docker username
```

#### Run Container

**Simple Container** :

```bash
docker run --rm -it archlinux:latest /bin/bash
```

**With Resource Limits** :

```bash
docker run -m 512m --cpus 1 --rm -it archlinux:latest /bin/bash
```

#### Volume Mounting

**Mount Directory** :

```bash
docker run -v /home/user:/mnt/home --rm -it archlinux:latest /bin/bash
```

### Comparison of Tools

| Tool | Type | Overhead | Complexity | Use Case |
|------|------|----------|-----------|----------|
| **Firejail** | Sandboxing  | Low  | Low  | Desktop apps  |
| **systemd-nspawn** | Containers  | Low-Medium  | Medium  | Lightweight containers  |
| **Docker** | Containers  | Medium  | Medium  | Full isolation  |
| **AppArmor** | MAC  | Very Low  | High  | System-wide  |

### Practical Examples

#### Sandbox Firefox

**Firejail** :

```bash
firejail --profile=/etc/firejail/firefox.profile firefox
```

**High Isolation** :

```bash
firejail --private --net=none firefox
```

#### Isolated Python Script

**Minimal Sandbox** :

```bash
firejail --noprofile --net=lo python script.py
```

#### Container for Testing

**systemd-nspawn** :

```bash
sudo systemd-nspawn -D ~/testenv -i
```

#### Production Service

**Hardened Systemd** :

```ini
[Service]
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
NoNewPrivileges=yes
CapabilityBoundingSet=~CAP_SYS_ADMIN
```

### Best Practices

**Layer Defense**: Use multiple isolation methods .

**Least Privilege**: Restrict only necessary access .

**Test Thoroughly**: Verify isolation doesn't break functionality .

**Monitor Resources**: Watch for escape attempts .

**Update Tools**: Keep sandboxing software current .

**Document Policies**: Record isolation rules .

**Regular Review**: Assess isolation effectiveness .

### Limitations

**Not Foolproof**: Sophisticated attacks may escape .

**Performance**: Isolation adds overhead .

**Complexity**: Harder to configure and debug .

**Kernel Dependent**: Requires kernel features .

***

This comprehensive guide on sandboxing and isolation completes the Arch Linux system administration documentation, providing users with essential knowledge for implementing modern security practices through application isolation, containerization, and access control mechanisms.

Sources
[1] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

