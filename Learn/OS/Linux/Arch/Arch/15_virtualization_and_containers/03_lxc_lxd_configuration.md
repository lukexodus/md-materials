## LXC/LXD Configuration


### Introduction to LXC and LXD[1]

**Linux Containers (LXC)** is an OS-level virtualization method that runs multiple isolated Linux systems (containers) on a single host using a shared kernel, making it lightweight compared to full virtualization. **LXD** is a next-generation system container manager built on top of LXC, offering a more user-friendly CLI, REST API, and additional features like container image management, networking, and clustering.[1]

### Installation and Setup[2][1]

Install required packages from the official repositories:[1]

```
sudo pacman -S lxc lxd
```

Optional but useful tools for networking and container management:[1]

```
sudo pacman -S bridge-utils dnsmasq debootstrap rsync
```

Enable required kernel modules for LXC to function properly:[1]

```
sudo modprobe overlay
sudo modprobe aufs
sudo modprobe br_netfilter
```

Persist these modules across reboots by creating `/etc/modules-load.d/lxc.conf`:[1]

```
echo -e "overlay\naufs\nbr_netfilter" | sudo tee /etc/modules-load.d/lxc.conf
```

Start and enable the LXD daemon:[1]

```
sudo systemctl enable --now lxd.service
```

### LXD Initialization[2][1]

Run the interactive initialization prompt to configure LXD:[1]

```
sudo lxd init
```

Configuration questions include clustering preference, storage backend (dir, zfs, or btrfs), network bridge creation, and IPv4/IPv6 address ranges. For a simple local setup, default values are typically sufficient.[1]

### Unprivileged Containers[2]

Unprivileged containers provide enhanced security by mapping container root UID to an unprivileged UID on the host. Modify `/etc/subuid` and `/etc/subgid` to enable unprivileged container execution:[2]

```
# usermod -v 1000000-1000999999 -w 1000000-1000999999 root
```

Add your user to the `lxd` group for direct daemon access:[2]

```
sudo usermod -a -G lxd username
```

### Container Management[2][1]

Launch containers using images from remote servers:[2]

```
lxc launch images:archlinux/current/amd64 arch
lxc launch ubuntu:20.04 ubuntu-container
lxc launch images:centos/8/amd64 centos
```

List available images from the default server:[2]

```
lxc image list images:
lxc image list images:debian
```

Basic container operations:[2][1]

```
lxc list                                    # List all containers
lxc exec arch -- bash                       # Execute shell in container
lxc start container-name                    # Start a container
lxc stop container-name                     # Stop a container
lxc delete container-name                   # Delete a container (--force if running)
```

### Virtual Machines[2]

Launch virtual machines with the `--vm` flag, though VMs support fewer features than containers:[2]

```
lxc launch ubuntu:20.04 --vm myvm
lxc launch ubuntu:20.04 --vm myvm -c security.secureboot=false
```

For non-cloud images, enable the lxd-agent manually by mounting a 9p network share and running the install script.[2]

### LXD Networking[1][2]

LXD automatically creates a default bridge network, typically `lxdbr0`:[1]

```
ip addr show lxdbr0
lxc network show lxdbr0
```

Create custom bridge networks with NAT capability:[1]

```
lxc network create mybridge ipv4.address=10.100.100.1/24 ipv4.nat=true ipv6.address=none
```

Attach networks to containers:[1]

```
lxc network attach mybridge arch-container eth0
```

**Permanent DNS resolution** for container names requires configuring systemd-resolved:[2]

```
# resolvectl dns lxdbr0 $(lxc network get lxdbr0 ipv4.address | cut -d / -f 1)
# resolvectl domain lxdbr0 '~lxd'
```

### Storage Configuration[1][2]

LXD supports multiple storage backends: `dir` (directory), `zfs` (with advanced features like snapshots), and `btrfs` (with compression). Configure storage during `lxd init` or modify profiles after initialization.[2][1]

### Disk Device Mounting[2]

Add read-only disk devices from host to container:[2]

```
lxc config device add containername virtualdiskname disk source=/path/to/host/disk path=/path/to/mountpoint
```

For read-write access in unprivileged containers, use the "shift" method with idmapped mounts (kernel >5.12) or legacy shiftfs. Check kernel support:[2]

```
lxc info
```

Enable shift in disk device configuration:[2]

```
lxc config device set containername devicename shift=true
```

### GUI Application Access[2]

Access Wayland or Xorg applications from containers via socket proxying. Add proxy devices for GPU access:[2]

```
mygpu:
  type: gpu
```

Add Wayland socket device:[2]

```
Waylaysocket:
  bind: container
  connect: unix:/run/user/1000/wayland-0
  listen: unix:/mnt/wayland1/wayland-0
  type: proxy
```

Link sockets inside container and set environment variables:[2]

```
export XDG_RUNTIME_DIR=/run/user/1000
export WAYLAND_DISPLAY=wayland-0
export QT_QPA_PLATFORM=wayland
```

### LXC Direct Usage[3]

For lower-level LXC management without LXD, create containers with download template:[3]

```
# lxc-create --name playtime --template download -- --dist archlinux --release current --arch amd64
```

Basic LXC operations:[3]

```
# lxc-ls -f                         # List containers
# lxc-start -n playtime             # Start container
# lxc-stop -n playtime              # Stop container
# lxc-console -n playtime           # Login to container
# lxc-attach -n playtime --clear-env # Attach to container
```

### LXC Networking with lxc-net[3]

The LXC project ships `lxc-net` which creates a NAT bridge `lxcbr0`. Enable in `/etc/default/lxc-net`:[3]

```
USE_LXC_BRIDGE="true"
```

Start the service:[3]

```
sudo systemctl enable --now lxc-net.service
```

Configure advanced networking in `/etc/default/lxc-net`:[3]

```
LXC_BRIDGE="lxcbr0"
LXC_ADDR="10.0.3.1"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="10.0.3.0/24"
LXC_DHCP_RANGE="10.0.3.2,10.0.3.254"
LXC_DHCP_MAX="253"
```

Define static container IPs in `/etc/lxc/dnsmasq.conf`:[3]

```
dhcp-host=playtime,10.0.3.100
```

### Firewall Integration[3][2]

For **ufw** users, allow LXD bridge traffic:[2]

```
# ufw allow in on lxdbr0
# ufw route allow in on lxdbr0
```

For **nftables**, add forwarding rules in `/etc/nftables.conf`:[3]

```
iifname "lxcbr0" accept comment "Allow lxc containers"
iifname "lxcbr0" oifname "eth0" accept comment "Allow forwarding from lxcbr0 to eth0"
iifname "eth0" oifname "lxcbr0" accept comment "Allow forwarding from eth0 to lxcbr0"
```

For **firewalld** with LXD, create a dedicated zone:[4]

```
$ firewall-cmd --permanent --new-zone=lxd
$ firewall-cmd --permanent --zone=lxd --add-forward
$ firewall-cmd --permanent --zone=lxd --set-target ACCEPT
$ firewall-cmd --permanent --zone=lxd --change-interface=lxdbr0
```

### Container Cloning and Snapshots[3]

Clone containers using overlayfs snapshots for minimal disk overhead:[3]

```
# lxc-copy -n base -N snap1 -B overlayfs -s
# lxc-copy -n base -N snap2 -B overlayfs -s
```

Destroy snapshots without affecting the base container:[3]

```
# lxc-destroy -n snap1 -f
```

### Troubleshooting[3][2]

If UEFI firmware error occurs when starting VMs, disable secure boot:[2]

```
lxc launch ubuntu:20.04 test-vm --vm -c security.secureboot=false
```

For IPv4 issues with systemd-networkd in unprivileged containers, create `/etc/systemd/system/systemd-networkd.service.d/lxc.conf`:[2]

```
[Service]
BindReadOnlyPaths=/sys
```

For containers with Docker installed on the host blocking LXD networking:[2]

```
# iptables -I DOCKER-USER -i lxdbr0 -o interface -j ACCEPT
# iptables -I DOCKER-USER -o lxdbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

If ping fails in unprivileged containers, set capabilities on the ping binary:[3]

```
# lxc-attach -n foo -- chmod u+s /usr/bin/ping
```

Check kernel configuration compliance:[2]

```
$ lxc-checkconfig
```

Related topics: Custom kernel compilation for container support; Cgroup delegation for unprivileged user containers; systemd-nspawn as an alternative containerization method.

Sources
[1] How to Manage LXC/LXD Containers on Arch Linux | Siberoloji https://www.siberoloji.com/how-to-manage-lxc-lxd-containers-on-arch-linux/
[2] LXD - ArchWiki https://wiki.archlinux.org/title/LXD
[3] Linux Containers - ArchWiki https://wiki.archlinux.org/title/Linux_Containers
[4] Isolated Development With Containers: Part 1 - Raniz' Blog https://raniz.blog/2022-08-12_devcontainers1/
[5] A Brief Introduction to LXC Containers - John Ramsden https://ramsdenj.com/posts/2016-11-23-a-brief-introduction-to-lxc-containers/
[6] Install LXD on Arch Linux using the Snap Store https://snapcraft.io/install/lxd/arch
[7] Help needed with configuring (bridge) network in LXC ... https://bbs.archlinux.org/viewtopic.php?id=208642
[8] LXD 2.0: Installing and configuring LXD [2/12] - Stéphane Graber https://stgraber.org/2016/03/15/lxd-2-0-installing-and-configuring-lxd-212/
[9] How to install LXD https://documentation.ubuntu.com/lxd/latest/installing/
[10] L.1. Setting up the multi-arch Linux LXC container farm for ... https://networkupstools.org/docs/user-manual.chunked/_setting_up_the_multi_arch_linux_lxc_container_farm_for_nut_ci.html


