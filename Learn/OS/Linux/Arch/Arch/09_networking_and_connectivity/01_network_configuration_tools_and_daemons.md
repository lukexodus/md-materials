## Network Configuration Tools and Daemons


### Network Configuration Overview

**Purpose**: Tools manage network interfaces, addressing, routing, and DNS resolution.[1][2]

**Layered Approach**: Low-level tools and high-level managers.[2]

**Choice**: Select based on system requirements and use case.[2]

### Low-Level Network Tools

#### ip Command

**Modern Replacement**: Supersedes ifconfig and route.[1][2]

**Address Management**:[1][2]

```bash
ip addr show                          # List all addresses
ip addr add 192.168.1.10/24 dev eth0  # Add address
ip addr del 192.168.1.10/24 dev eth0  # Remove address
```

**Interface Control**:[2][1]

```bash
ip link show                # List interfaces
ip link set eth0 up         # Enable interface
ip link set eth0 down       # Disable interface
```

**Routing**:[1]

```bash
ip route show              # Display routing table
ip route add default via 192.168.1.1  # Add default route
ip route del default via 192.168.1.1  # Remove route
```

#### ifconfig (Legacy)

**Deprecated**: Old tool, still available.[1]

**Basic Usage**:[1]

```bash
ifconfig                    # Show all interfaces
ifconfig eth0 192.168.1.10  # Assign address
ifconfig eth0 up            # Enable interface
```

**Not Recommended**: Use `ip` command instead.[1]

#### dhcpcd (DHCP Client Daemon)

**Purpose**: Automatic IP address configuration.[2][1]

**Manual Operation**:[1]

```bash
sudo dhcpcd eth0  # Request address on eth0
```

**Service**:[1]

```bash
sudo systemctl start dhcpcd@eth0
sudo systemctl enable dhcpcd@eth0
```

#### wpa_supplicant

**Wireless Security**: Handles WPA/WPA2/WPA3 authentication.[2][1]

**Configuration**: `/etc/wpa_supplicant/wpa_supplicant.conf`.[1]

**Manual Connection**:[1]

```bash
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

### systemd-networkd

#### Overview

**Modern Approach**: Integrated network configuration.[3][1]

**Installation**: Part of systemd (pre-installed).[1]

**Enable Service**:[1]

```bash
sudo systemctl enable --now systemd-networkd.service
```

#### Configuration Files

**Location**: `/etc/systemd/network/`.[3][1]

**File Naming**: `.network` files.[3]

**Wired DHCP Configuration**:[3][1]

```ini
# /etc/systemd/network/20-wired.network
[Match]
Name=eth0

[Network]
DHCP=yes
```

**Static IP Configuration**:[3][1]

```ini
# /etc/systemd/network/20-static.network
[Match]
Name=eth0

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8 1.1.1.1
```

**Wireless Configuration**:[3]

```ini
# /etc/systemd/network/25-wireless.network
[Match]
Name=wlan0

[Network]
DHCP=yes
IgnoreCarrierLoss=3s
```

#### Management Commands

**Reload Configuration**:[1]

```bash
sudo systemctl reload systemd-networkd
```

**Check Status**:[1]

```bash
systemctl status systemd-networkd
networkctl
```

### systemd-resolved

#### DNS Resolution

**Purpose**: Resolve domain names to IP addresses.[3][1]

**Enable Service**:[1]

```bash
sudo systemctl enable --now systemd-resolved.service
```

#### Configuration

**Main File**: `/etc/systemd/resolved.conf`:[1]

```ini
[Resolve]
DNS=1.1.1.1 1.0.0.1 8.8.8.8
FallbackDNS=9.9.9.9
DNSSec=yes
```

**Static Hostname DNS**: `/etc/systemd/network/` files:[1]

```ini
[Network]
DNS=8.8.8.8 8.8.4.4
```

#### Stub Resolver

**Local Caching**: systemd-resolved provides stub resolver:[1]

```bash
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

**Testing**:[1]

```bash
resolvectl query archlinux.org
```

### NetworkManager

#### Overview

**Comprehensive**: Full network management solution.[4][1]

**Installation**: `sudo pacman -S networkmanager`.[4][1]

**Enable Service**:[4][1]

```bash
sudo systemctl enable --now NetworkManager.service
```

#### Connection Management

**List Connections**:[4][1]

```bash
nmcli connection show
```

**Add Connection**:[4][1]

```bash
nmcli connection add type ethernet ifname eth0 con-name mynet
nmcli connection modify mynet ipv4.method auto
```

**Activate Connection**:[1]

```bash
nmcli connection up mynet
```

**Delete Connection**:[1]

```bash
nmcli connection delete mynet
```

#### Wireless Management

**List Networks**:[1]

```bash
nmcli device wifi list
```

**Connect to Network**:[1]

```bash
nmcli device wifi connect SSID password PASSWORD
```

**Stored Networks**:[1]

```bash
nmcli connection show --active
```

#### Device Management

**Device List**:[1]

```bash
nmcli device show
```

**Enable/Disable Device**:[1]

```bash
nmcli device set eth0 managed yes  # Manage device
nmcli radio wifi on                 # Enable WiFi
```

### iwd (iNet Wireless Daemon)

#### Wireless Configuration

**Modern Alternative**: Replaces wpa_supplicant.[5]

**Installation**: `sudo pacman -S iwd`.[5]

**Enable Service**:[5]

```bash
sudo systemctl enable --now iwd.service
```

#### Configuration

**Main File**: `/etc/iwd/main.conf`:[5]

```ini
[General]
use_default_interface=true
EnableNetworkConfiguration=true
NameResolvingService=systemd
```

#### Interactive Interface

**iwctl Command**:[5]

```bash
iwctl
[iwd] device list
[iwd] station wlan0 get-networks
[iwd] station wlan0 connect SSID
# Enter password if prompted
```

**Automatic Connection**:[5]

```bash
# Learned networks auto-connect
iwctl station wlan0 set-property AutoConnect on
```

### Comparison of Tools

| Tool | Type | Configuration | Simplicity | Features |
|------|------|---------------|-----------|----------|
| **systemd-networkd** | Manager [1] | Text files [1] | Simple [1] | Moderate [1] |
| **NetworkManager** | Manager [1] | Text files [1] | Moderate [1] | Comprehensive [1] |
| **iwd** | WiFi daemon [5] | Text file [5] | Simple [5] | WiFi only [5] |
| **dhcpcd** | DHCP [1] | Simple [1] | Easy [1] | DHCP only [1] |
| **wpa_supplicant** | WiFi auth [1] | Complex [1] | Complex [1] | WiFi only [1] |

### Static IP Configuration

#### Using systemd-networkd

**File**: `/etc/systemd/network/20-static.network`:[1]

```ini
[Match]
Name=eth0

[Network]
Address=192.168.1.50/24
Gateway=192.168.1.1
DNS=8.8.8.8

[Link]
NamePolicy=keep
```

#### Using NetworkManager

**nmcli Configuration**:[1]

```bash
nmcli connection modify mynet ipv4.method manual
nmcli connection modify mynet ipv4.addresses 192.168.1.50/24
nmcli connection modify mynet ipv4.gateway 192.168.1.1
nmcli connection modify mynet ipv4.dns 8.8.8.8
nmcli connection up mynet
```

### Bridge Configuration

**Purpose**: Connect multiple networks.[1]

**Setup**:[1]

```bash
sudo ip link add br0 type bridge
sudo ip link set eth0 master br0
sudo ip link set br0 up
sudo dhcpcd br0
```

**Persistent Configuration**:[1]

Create `/etc/systemd/network/30-bridge.network`:

```ini
[Match]
Name=eth0

[Network]
Bridge=br0

[Bridge]
```

### Bonding and Aggregation

**Purpose**: Combine multiple interfaces for redundancy/bandwidth.[1]

**Create Bond**:[1]

```bash
sudo ip link add bond0 type bond mode=active-backup
sudo ip link set eth0 master bond0
sudo ip link set eth1 master bond0
```

### VPN Configuration

#### WireGuard Setup

**Installation**: `sudo pacman -S wireguard-tools`.[1]

**Configuration**: `/etc/wireguard/wg0.conf`:[1]

```ini
[Interface]
PrivateKey = <private_key>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <peer_public_key>
AllowedIPs = 10.0.0.2/32
```

**Activate**:[1]

```bash
sudo wg-quick up wg0
```

### Troubleshooting Network Issues

#### Check Connectivity

**Ping Test**:[1]

```bash
ping -c 4 8.8.8.8
```

**DNS Resolution**:[1]

```bash
nslookup archlinux.org
resolvectl query archlinux.org
```

**Route Display**:[1]

```bash
ip route
```

#### Interface Issues

**Interface Status**:[1]

```bash
ip link show
```

**Debug Interface**:[1]

```bash
sudo ip link set eth0 promisc on  # Monitor mode
sudo tcpdump -i eth0             # Capture packets
```

#### DHCP Issues

**Check dhcpcd**:[1]

```bash
sudo systemctl status dhcpcd@eth0
sudo journalctl -u dhcpcd@eth0 -n 50
```

**Force Renewal**:[1]

```bash
sudo dhcpcd -k eth0
sudo dhcpcd eth0
```

### Best Practices

**Choose One Manager**: Use either systemd-networkd or NetworkManager, not both.[1]

**Documentation**: Document network configuration.[1]

**Testing**: Test changes before making persistent.[1]

**Backup Configuration**: Save working configs.[1]

**Monitor Logs**: Check `journalctl` for issues.[1]

**Security**: Use strong encryption for wireless.[5]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Network configuration - ArchWiki https://wiki.archlinux.org/title/Network_configuration
[3] systemd-networkd - ArchWiki https://wiki.archlinux.org/title/Systemd-networkd
[4] NetworkManager - ArchWiki https://wiki.archlinux.org/title/NetworkManager
[5] iwd - ArchWiki https://wiki.archlinux.org/title/Iwd

