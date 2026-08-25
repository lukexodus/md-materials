## Network Services


### NetworkManager Usage

NetworkManager is a dynamic network configuration daemon that simplifies network management through automatic connection handling, profile management, and seamless switching between network interfaces.

#### NetworkManager Architecture

**Core Components:**

- **NetworkManager daemon**: Main service process (`NetworkManager.service`)
- **nmcli**: Command-line interface for network management
- **nmtui**: Text-based user interface for configuration
- **Connection profiles**: Stored network configurations
- **Device management**: Interface control and monitoring

**Service Management:**

```bash
# Check NetworkManager status
systemctl status NetworkManager

# Start/stop NetworkManager
sudo systemctl start NetworkManager
sudo systemctl stop NetworkManager

# Enable/disable at boot
sudo systemctl enable NetworkManager
sudo systemctl disable NetworkManager
```

#### Command-Line Interface (nmcli)

**Device Management:**

```bash
# List all network devices
nmcli device show

# Show device status
nmcli device status

# Show specific device details
nmcli device show eth0

# Connect/disconnect device
nmcli device connect eth0
nmcli device disconnect eth0

# Monitor device changes
nmcli device monitor
```

**Connection Management:**

```bash
# List all connections
nmcli connection show

# Show active connections
nmcli connection show --active

# Show connection details
nmcli connection show "connection-name"

# Create new connection
nmcli connection add type ethernet con-name "office-lan" ifname eth0

# Modify existing connection
nmcli connection modify "office-lan" ipv4.addresses 192.168.1.100/24
nmcli connection modify "office-lan" ipv4.gateway 192.168.1.1
nmcli connection modify "office-lan" ipv4.dns 8.8.8.8,8.8.4.4
nmcli connection modify "office-lan" ipv4.method manual

# Activate/deactivate connection
nmcli connection up "office-lan"
nmcli connection down "office-lan"

# Delete connection
nmcli connection delete "office-lan"
```

#### Network Configuration Examples

**Static IP Configuration:**

```bash
# Create static IP connection
nmcli connection add \
    type ethernet \
    con-name "static-eth0" \
    ifname eth0 \
    ipv4.addresses 192.168.1.50/24 \
    ipv4.gateway 192.168.1.1 \
    ipv4.dns "8.8.8.8,8.8.4.4" \
    ipv4.method manual

# Apply configuration
nmcli connection up "static-eth0"
```

**DHCP Configuration:**

```bash
# Create DHCP connection
nmcli connection add \
    type ethernet \
    con-name "dhcp-eth0" \
    ifname eth0 \
    ipv4.method auto

# Activate DHCP connection
nmcli connection up "dhcp-eth0"
```

**Bridge Configuration:**

```bash
# Create bridge interface
nmcli connection add type bridge con-name br0 ifname br0

# Add ethernet interface to bridge
nmcli connection add type bridge-slave con-name br0-eth0 ifname eth0 master br0

# Configure bridge IP
nmcli connection modify br0 ipv4.addresses 192.168.1.100/24
nmcli connection modify br0 ipv4.gateway 192.168.1.1
nmcli connection modify br0 ipv4.method manual

# Activate bridge
nmcli connection up br0
```

#### NetworkManager Configuration Files

**Main Configuration:**

- `/etc/NetworkManager/NetworkManager.conf`: Primary configuration
- `/etc/NetworkManager/conf.d/*.conf`: Additional configuration files
- `/etc/NetworkManager/system-connections/`: Connection profiles

**Example NetworkManager.conf:**

```ini
[main]
plugins=ifupdown,keyfile
dns=default

[ifupdown]
managed=false

[device]
wifi.scan-rand-mac-address=yes

[logging]
level=INFO
domains=CORE,DEVICE,IP4,IP6,WIFI,DHCP4,DHCP6
```

**Connection Profile Example:**

```ini
# /etc/NetworkManager/system-connections/office-ethernet.nmconnection
[connection]
id=office-ethernet
uuid=12345678-1234-1234-1234-123456789abc
type=ethernet
autoconnect=true

[ethernet]
mac-address-blacklist=

[ipv4]
address1=192.168.1.100/24,192.168.1.1
dns=8.8.8.8;8.8.4.4;
method=manual

[ipv6]
addr-gen-mode=stable-privacy
method=auto
```

### systemd-networkd Basics

systemd-networkd provides network configuration management as part of the systemd ecosystem, offering declarative network configuration through simple text files.

#### systemd-networkd Architecture

**Core Components:**

- **systemd-networkd.service**: Main network management daemon
- **systemd-resolved.service**: DNS resolution service
- **Network files**: `.network` configuration files
- **Netdev files**: `.netdev` virtual device definitions
- **Link files**: `.link` device matching and naming

**Service Management:**

```bash
# Enable and start systemd-networkd
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd

# Check service status
systemctl status systemd-networkd

# Enable DNS resolution
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved

# Link resolved to system DNS
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

#### Configuration File Structure

**Configuration Directories:**

- `/etc/systemd/network/`: System network configuration
- `/run/systemd/network/`: Runtime network configuration
- `/lib/systemd/network/`: Distribution-provided configuration

**File Types and Naming:**

- `*.network`: Network configuration for devices
- `*.netdev`: Virtual network device definitions
- `*.link`: Device link configuration and naming

#### Network Configuration Examples

**Basic Ethernet Configuration:**

```ini
# /etc/systemd/network/20-wired.network
[Match]
Name=eth0

[Network]
DHCP=ipv4
```

**Static IP Configuration:**

```ini
# /etc/systemd/network/25-static.network
[Match]
Name=eth1

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8
DNS=8.8.4.4
```

**Bridge Configuration:**

```ini
# /etc/systemd/network/bridge.netdev
[NetDev]
Name=br0
Kind=bridge

# /etc/systemd/network/bridge.network
[Match]
Name=br0

[Network]
DHCP=ipv4
IPForward=yes

# /etc/systemd/network/bind-bridge.network
[Match]
Name=eth0

[Network]
Bridge=br0
```

#### Advanced systemd-networkd Features

**VLAN Configuration:**

```ini
# /etc/systemd/network/vlan.netdev
[NetDev]
Name=vlan100
Kind=vlan

[VLAN]
Id=100

# /etc/systemd/network/vlan.network
[Match]
Name=vlan100

[Network]
Address=192.168.100.10/24
Gateway=192.168.100.1
```

**Bonding Configuration:**

```ini
# /etc/systemd/network/bond.netdev
[NetDev]
Name=bond0
Kind=bond

[Bond]
Mode=active-backup
MIIMonitorSec=1s

# /etc/systemd/network/bond-slave.network
[Match]
Name=eth0

[Network]
Bond=bond0

# /etc/systemd/network/bond.network
[Match]
Name=bond0

[Network]
DHCP=ipv4
```

#### Debugging and Management

**Network Status Commands:**

```bash
# Show network status
networkctl status

# List all links
networkctl list

# Show specific interface details
networkctl status eth0

# Reload configuration
sudo systemctl reload systemd-networkd

# Monitor network events
journalctl -f -u systemd-networkd
```

### Network Configuration Files

Traditional network configuration involves various system files that define network interfaces, routing, and DNS settings across different Linux distributions.

#### Distribution-Specific Configuration

**Red Hat/CentOS/Fedora Configuration:**

```bash
# /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=eth0
UUID=12345678-1234-1234-1234-123456789abc
DEVICE=eth0
ONBOOT=yes
IPADDR=192.168.1.100
PREFIX=24
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
```

**Debian/Ubuntu Configuration:**

```bash
# /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
    dns-search example.com

auto eth1
iface eth1 inet dhcp
```

**SUSE Configuration:**

```bash
# /etc/sysconfig/network/ifcfg-eth0
BOOTPROTO='static'
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR='192.168.1.100/24'
MTU=''
NAME=''
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
```

#### Global Network Settings

**Hostname Configuration:**

```bash
# /etc/hostname
server01.example.com

# Set hostname dynamically
sudo hostnamectl set-hostname server01.example.com
```

**DNS Configuration:**

```bash
# /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com local
domain example.com
```

**Hosts File:**

```bash
# /etc/hosts
127.0.0.1   localhost localhost.localdomain
127.0.1.1   server01.example.com server01
192.168.1.100   server01.example.com server01
192.168.1.10    gateway.local gateway
```

#### Routing Configuration

**Static Routes:**

```bash
# Red Hat: /etc/sysconfig/network-scripts/route-eth0
192.168.2.0/24 via 192.168.1.254 dev eth0
10.0.0.0/8 via 192.168.1.1 dev eth0

# Debian: Add to /etc/network/interfaces
up route add -net 192.168.2.0/24 gw 192.168.1.254 dev eth0
down route del -net 192.168.2.0/24 gw 192.168.1.254 dev eth0
```

**Persistent Routes:**

```bash
# Create persistent route file
echo "192.168.2.0/24 via 192.168.1.254 dev eth0" >> /etc/network/routes

# Manual route addition
sudo ip route add 192.168.2.0/24 via 192.168.1.254 dev eth0
```

#### Interface Management Commands

**Interface Control:**

```bash
# Bring interface up/down
sudo ifup eth0
sudo ifdown eth0

# Using ip command
sudo ip link set eth0 up
sudo ip link set eth0 down

# Restart networking service
sudo systemctl restart networking  # Debian/Ubuntu
sudo systemctl restart network     # Red Hat/CentOS
```

**Configuration Reload:**

```bash
# Reload network configuration
sudo ifdown eth0 && sudo ifup eth0

# Restart NetworkManager connections
sudo nmcli connection reload
```

### Wireless Networking

Wireless networking involves additional complexity including authentication, encryption, and access point management through various tools and configuration methods.

#### Wireless Tools and Utilities

**Basic Wireless Commands:**

```bash
# Scan for available networks
sudo iwlist scan
sudo iw dev wlan0 scan

# Show wireless interface information
iwconfig
iw dev wlan0 info

# Show wireless statistics
cat /proc/net/wireless
iwconfig wlan0

# Show wireless regulatory domain
iw reg get
```

**Interface Management:**

```bash
# Bring wireless interface up
sudo ip link set wlan0 up
sudo ifconfig wlan0 up

# Set wireless interface down
sudo ip link set wlan0 down

# Monitor wireless events
sudo iw event
```

#### WPA/WPA2 Configuration

**wpa_supplicant Configuration:**

```bash
# /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

# Open network
network={
    ssid="OpenNetwork"
    key_mgmt=NONE
}

# WPA/WPA2 Personal
network={
    ssid="HomeWiFi"
    psk="password123"
    key_mgmt=WPA-PSK
}

# WPA/WPA2 Enterprise
network={
    ssid="CorpWiFi"
    key_mgmt=WPA-EAP
    eap=PEAP
    identity="user@example.com"
    password="password123"
    phase2="auth=MSCHAPV2"
}

# Hidden network
network={
    ssid="HiddenNetwork"
    psk="secretpassword"
    scan_ssid=1
}
```

**Generate PSK from passphrase:**

```bash
# Generate WPA PSK
wpa_passphrase "NetworkName" "password" >> /etc/wpa_supplicant/wpa_supplicant.conf
```

#### NetworkManager Wireless Configuration

**WiFi Connection via nmcli:**

```bash
# Scan for networks
nmcli device wifi list

# Connect to open network
nmcli device wifi connect "OpenNetwork"

# Connect to secured network
nmcli device wifi connect "SecureNetwork" password "password123"

# Connect to hidden network
nmcli device wifi connect "HiddenSSID" password "password123" hidden yes

# Show saved WiFi passwords
sudo nmcli connection show "WiFiNetwork" --show-secrets
```

**WiFi Profile Management:**

```bash
# Create WiFi connection profile
nmcli connection add \
    type wifi \
    con-name "HomeWiFi" \
    ifname wlan0 \
    ssid "HomeNetwork" \
    wifi-sec.key-mgmt wpa-psk \
    wifi-sec.psk "password123"

# Modify WiFi connection
nmcli connection modify "HomeWiFi" wifi-sec.psk "newpassword"

# Set connection priority
nmcli connection modify "HomeWiFi" connection.autoconnect-priority 10
```

#### Wireless Security Configurations

**WEP Configuration (deprecated):**

```bash
# WEP in wpa_supplicant.conf
network={
    ssid="OldNetwork"
    key_mgmt=NONE
    wep_key0="1234567890"
    wep_tx_keyidx=0
}
```

**WPS Configuration:**

```bash
# WPS PIN method
wpa_cli wps_pin any 12345670

# WPS push button method
wpa_cli wps_pbc

# WPS via nmcli
nmcli device wifi connect --wps
```

#### Access Point Mode

**hostapd Configuration:**

```bash
# /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=MyAccessPoint
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=SecurePassword123
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```

**DHCP Server Configuration:**

```bash
# /etc/dhcp/dhcpd.conf for AP
subnet 192.168.4.0 netmask 255.255.255.0 {
    range 192.168.4.2 192.168.4.20;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    option routers 192.168.4.1;
    default-lease-time 600;
    max-lease-time 7200;
}
```

#### Wireless Troubleshooting

**Common Diagnostic Commands:**

```bash
# Check wireless card recognition
lspci | grep -i wireless
lsusb | grep -i wireless

# Check kernel modules
lsmod | grep -i wifi
lsmod | grep -i 802

# Check dmesg for wireless messages
dmesg | grep -i wifi
dmesg | grep -i wlan

# Monitor wireless interface
sudo tcpdump -i wlan0

# Check signal strength
watch -n 1 cat /proc/net/wireless
```

**Connection Debugging:**

```bash
# wpa_supplicant debugging
sudo wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf -d

# NetworkManager debugging
nmcli general logging level DEBUG domains ALL

# Check wireless regulatory settings
iw reg get
sudo iw reg set US
```

**Performance Monitoring:**

```bash
# Wireless statistics
iwconfig wlan0
iw dev wlan0 station dump

# Network throughput testing
iperf3 -c server_ip  # Client mode
iperf3 -s             # Server mode
```

**Key points:**

- NetworkManager provides comprehensive network management with GUI and CLI interfaces
- systemd-networkd offers declarative configuration suitable for servers and embedded systems
- Traditional configuration files vary by distribution but follow similar patterns
- Wireless networking requires additional security and authentication configuration
- Multiple tools exist for wireless management, from low-level utilities to high-level managers

**Conclusion:** Network services in Linux offer multiple approaches ranging from traditional configuration files to modern dynamic management systems. NetworkManager excels in desktop and mobile environments with automatic connection handling, while systemd-networkd provides reliable server-focused networking. Understanding both traditional and modern approaches ensures effective network configuration across diverse Linux environments. Wireless networking adds complexity through security protocols and authentication methods, requiring familiarity with specialized tools and configuration techniques.

---

