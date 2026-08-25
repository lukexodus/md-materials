## Network Configuration


### Network Configuration Overview

Arch Linux provides multiple network configuration solutions for different use cases and preferences. Each solution manages different OSI layers: wireless connectivity (layer 2), IP address assignment (layer 3), and DNS resolution.[1][2]

### systemd-networkd

**Overview**: Systemd-networkd is a system daemon that manages network configurations, detecting and configuring network devices as they appear. It is included in systemd, the default Arch init system.[3]

#### Installation and Enablement

**Service**: Systemd-networkd is pre-installed as part of base systemd.[3]

**Enable Service**: `systemctl enable --now systemd-networkd.service`.[3]

**Optional DNS Resolution**: Configure `systemd-resolved` for DNS functionality (recommended for DHCP-based configurations).[3]

#### Wired Connection (DHCP)

**Configuration File**: Create `/etc/systemd/network/20-wired.network`:[3]

```
[Match]
Name=enp1s0

[Link]
RequiredForOnline=routable

[Network]
DHCP=yes
```

**Parameters**:[3]
*   **`[Match] Name=`**: Specifies the interface name (use `ip link` to identify)[3]
*   **`DHCP=yes`**: Enables DHCP for automatic IP assignment[3]
*   **`RequiredForOnline=routable`**: Marks the interface as required for online status[3]

#### Wired Connection (Static IP)

**Static Configuration**:[3]

```
[Match]
Name=enp1s0

[Network]
Address=10.1.10.9/24
Address=2001:db8:1234:5678::1/64
Gateway=10.1.10.1
Gateway=fe80::1
DNS=10.1.10.1
DNS=2001:db8:1122::3344:1
```

**Parameters**:[3]
*   **`Address=`**: IPv4 or IPv6 address with CIDR notation[3]
*   **`Gateway=`**: Default gateway for routing[3]
*   **`DNS=`**: DNS server addresses[3]

#### Wireless Connection

**Configuration File**: Create `/etc/systemd/network/25-wireless.network`:[3]

```
[Match]
Name=wlp2s0

[Link]
RequiredForOnline=routable

[Network]
DHCP=yes
IgnoreCarrierLoss=3s
```

**Parameters**:[3]
*   **`IgnoreCarrierLoss=3s`**: Prevents interface reconfiguration during wireless roaming to different access points[3]

**Wireless Authentication**: Use iwd or wpa_supplicant for wireless authentication.[3]

### iwd (iNet Wireless Daemon)

**Overview**: Iwd is a modern wireless daemon providing both Wi-Fi authentication and built-in network configuration capabilities. It replaces the traditional wpa_supplicant/wpa_cli combination with a simpler interface.[4][5]

#### Installation and Enablement

**Installation**: `pacman -S iwd`.[5]

**Enable Service**: `systemctl enable --now iwd`.[5]

**Verification**: Run `iwctl` to enter the interactive shell; confirm connection to iwd daemon.[5]

#### Configuration File

**Main Configuration**: Create or edit `/etc/iwd/main.conf`:[4][5]

```
[General]
use_default_interface=true

[Network]
EnableNetworkConfiguration=true
NameResolvingService=systemd
EnableIPv6=true
```

**Parameters**:[4][5]
*   **`use_default_interface=true`**: Preserves the default interface name (required for systemd-networkd compatibility)[5]
*   **`EnableNetworkConfiguration=true`**: Activates iwd's built-in DHCP client and IP configuration[4]
*   **`NameResolvingService=systemd`**: Uses systemd-resolved for DNS (alternative: `resolvconf`)[4]
*   **`EnableIPv6=true`**: Enables IPv6 support (default in v2.0+)[4]

#### Wireless Connection (iwctl)

**Connect to Network**: Use the `iwctl` interactive interface:[4]

```
iwctl station wlan0 connect NetworkSSID
```

**Network Disconnection**: `iwctl station wlan0 disconnect`.[4]

**Known Networks**: Networks are stored in `/var/lib/iwd/` with filenames like `NetworkName.psk` (pre-shared key) or `NetworkName.open`.[4]

#### Static IP Configuration with iwd

**Static IP**: Edit network configuration file in `/var/lib/iwd/`:[4]

```
/var/lib/iwd/spaceship.psk:

[IPv4]
Address=192.168.1.10
Netmask=255.255.255.0
Gateway=192.168.1.1
Broadcast=192.168.1.255
DNS=192.168.1.1
```

**Network Identification**: Replace `spaceship` with the actual SSID and `.psk` with the network type (`.open`, `.psk`, `.8021x`).[4]

### NetworkManager

**Overview**: NetworkManager is a comprehensive network configuration daemon providing automatic detection and connection management. It supports both wired and wireless connections with graphical interface options.[6]

#### Installation and Enablement

**Installation**: `pacman -S networkmanager`.[7]

**Enable Service**: `systemctl enable --now NetworkManager`.[7]

#### CLI Tool (nmcli)

**List Connections**: `nmcli device show`.[8]

**Create Connection**: `nmcli connection add type wifi ifname wlp2s0 con-name MyNetwork ssid MySSID`.[8]

**Connect**: `nmcli connection up MyNetwork`.[8]

#### Graphical Tools

**nmtui**: Terminal UI for NetworkManager configuration.[8]

**GNOME Settings**: Graphical network settings in GNOME Desktop Environment.[8]

**KDE Plasma**: Network configuration in KDE settings.[8]

#### iwd Backend

**Enable iwd**: Configure NetworkManager to use iwd as the wireless backend instead of wpa_supplicant:[5]

Edit `/etc/NetworkManager/NetworkManager.conf`:

```
[device]
wifi.backend=iwd
```

### systemd-resolved

**DNS Resolution**: Systemd-resolved provides DNS name resolution for applications.[3]

**Enable Service**: `systemctl enable --now systemd-resolved`.[3]

**Configuration**: `/etc/systemd/resolved.conf` allows custom DNS servers.[3]

**Stub Mode**: Link `/etc/resolv.conf` to the systemd-resolved stub resolver:[3]

```
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

### Comparison and Selection

| Feature | systemd-networkd | iwd (built-in) | NetworkManager |
|---------|------------------|----------------|----------------|
| **Wired Support** | Yes [3] | Yes [4] | Yes [6] |
| **Wireless Support** | Via external daemon [3] | Yes, native [4] | Yes [6] |
| **DHCP** | Integrated [3] | Integrated (0.19+) [4] | Integrated [6] |
| **DNS Resolution** | Via systemd-resolved [3] | Via systemd-resolved/resolvconf [4] | Integrated [6] |
| **Configuration** | Text files [3] | Text files [4] | GUI/CLI [6] |
| **Complexity** | Low [3] | Low [4] | Moderate [6] |
| **GUI Support** | No [3] | No (CLI only) [4] | Yes [6] |
| **Desktop Integration** | Limited [3] | Limited [4] | Excellent [6] |
| **Performance** | Lightweight [9] | Lightweight [5] | Resource-intensive [6] |
| **Use Case** | Servers, minimal setups [3] | Minimalist desktops [5] | Desktop environments [6] |

### Recommended Configurations

**Minimal Setup**: systemd-networkd + systemd-resolved + iwd.[5][3]

**Desktop Setup**: NetworkManager with graphical interface.[6]

**Laptop Setup**: systemd-networkd + iwd + systemd-resolved for balance of simplicity and functionality.[9]

### Service Conflict Prevention

**Single Network Manager**: Only one network manager daemon should run simultaneously.[10][3]

**Verification**: Check running services with `systemctl --type=service | grep -E 'networkd|NetworkManager|connman'` [3].

**Disable Conflicting Services**: `systemctl disable [service_name]` removes conflicting managers.[3]

Sources
[1] Network configuration - ArchWiki https://wiki.archlinux.org/title/Network_configuration
[2] Choosing the Right Network Manager and Its Configuration ... https://bbs.archlinux.org/viewtopic.php?id=302342
[3] systemd-networkd - ArchWiki https://wiki.archlinux.org/title/Systemd-networkd
[4] iwd - ArchWiki https://wiki.archlinux.org/title/Iwd
[5] simple wifi setup with iwd and networkd https://insanity.industries/post/simple-wifi/
[6] NetworkManager - ArchWiki https://wiki.archlinux.org/title/NetworkManager
[7] Arch Linux Installation: Easy Step-by-Step Guide https://linuxconfig.org/arch-linux-installation-easy-step-by-step-guide
[8] Adding a user with sudo privileges to Arch. : r/linuxquestions https://www.reddit.com/r/linuxquestions/comments/c1dp5f/adding_a_user_with_sudo_privileges_to_arch/
[9] Network stack choice - networkd vs iwd built-in / Newbie ... https://bbs.archlinux.org/viewtopic.php?id=288514
[10] Network Setup with iwd : r/archlinux https://www.reddit.com/r/archlinux/comments/jijbh1/network_setup_with_iwd/
[11] Switching to iwd/iwctl : r/archlinux https://www.reddit.com/r/archlinux/comments/yobev4/switching_to_iwdiwctl/
[12] Using iwd to connect to a wireless network (Part 1 https://groups.google.com/g/linux.debian.user/c/qDeS_GrnAk4

