## Wireless Setup and Troubleshooting


### Wireless Fundamentals

**Components**:[1][2]
- Wireless hardware (adapter/card)[2]
- Firmware/drivers[2]
- Authentication daemon[2]
- Network manager[2]

**Protocols**:[2]
- WiFi (802.11) standards[2]
- WPA/WPA2/WPA3 security[2]

**Process**: Hardware → Driver → Authentication → IP configuration.[1]

### Hardware Detection

#### Identify Wireless Adapter

**List Devices**:[1][2]

```bash
ip link show
lspci | grep -i network
lsusb | grep -i network
```

**Expected Output**: Identifies network device:[1]

```
wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
```

#### Check Driver Status

**Load Status**:[1]

```bash
lsmod | grep wifi
lsmod | grep driver_name
```

**Missing Driver**: Module not loaded.[1]

**dmesg Check**:[1]

```bash
dmesg | grep -i wireless
dmesg | grep -i firmware
```

### Driver Installation

#### Identify Required Driver

**Determine Hardware**:[1]

```bash
lspci -nn | grep -i network
```

**Output Example**:[1]

```
Intel Corporation Wireless 7260 [8086:0891]
```

#### Common Drivers

**Intel Wireless**:[1]

```bash
sudo pacman -S linux-firmware
```

**Qualcomm Atheros**:[1]

```bash
sudo pacman -S linux-firmware
```

**Broadcom**:[1]

```bash
sudo pacman -S broadcom-wl
```

**Realtek**:[1]

```bash
sudo pacman -S linux-firmware
```

**Ralink/MediaTek**:[1]

```bash
sudo pacman -S linux-firmware
```

**Installation**:[1]

```bash
sudo pacman -Sy archlinux-keyring
sudo pacman -S linux-firmware
```

#### Kernel Module

**Load Module**:[1]

```bash
sudo modprobe iwlwifi       # Intel
sudo modprobe ath9k         # Atheros
sudo modprobe brcmfmac      # Broadcom
```

**Verify Loading**:[1]

```bash
lsmod | grep driver_name
```

**Permanent Loading**: Add to `/etc/modprobe.d/`:[1]

```bash
echo "iwlwifi" | sudo tee /etc/modprobe.d/wireless.conf
```

### Wireless Authentication

#### iwd Setup

**Installation**:[3]

```bash
sudo pacman -S iwd
sudo systemctl enable --now iwd.service
```

**Connect to Network**:[3]

```bash
iwctl
[iwd] device list
[iwd] station wlan0 get-networks
[iwd] station wlan0 connect SSID
# Enter password
```

#### wpa_supplicant Setup

**Installation**:[2][1]

```bash
sudo pacman -S wpa_supplicant
```

**Configuration**: `/etc/wpa_supplicant/wpa_supplicant.conf`:[1]

```
ctrl_interface=/run/wpa_supplicant
update_config=1

network={
    ssid="NETWORK_NAME"
    psk="PASSWORD"
    key_mgmt=WPA-PSK
}
```

**Generate PSK Hash**:[1]

```bash
wpa_passphrase "SSID" "PASSWORD" > /etc/wpa_supplicant/wpa_supplicant.conf
```

**Manual Connection**:[1]

```bash
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

#### NetworkManager

**Installation**:[2][1]

```bash
sudo pacman -S networkmanager
sudo systemctl enable --now NetworkManager.service
```

**Connect**:[2][1]

```bash
nmcli device wifi list
nmcli device wifi connect SSID password PASSWORD
```

### IP Address Configuration

#### DHCP (Dynamic)

**Automatic Configuration**:[2][1]

```bash
sudo dhcpcd wlan0
```

**Service-Based**:[1]

```bash
sudo systemctl start dhcpcd@wlan0
sudo systemctl enable dhcpcd@wlan0
```

#### Static IP

**Using ip Command**:[1]

```bash
sudo ip addr add 192.168.1.50/24 dev wlan0
sudo ip route add default via 192.168.1.1
```

**Using systemd-networkd**:[1]

Create `/etc/systemd/network/25-wireless.network`:

```ini
[Match]
Name=wlan0

[Network]
Address=192.168.1.50/24
Gateway=192.168.1.1
DNS=8.8.8.8
```

### Wireless Troubleshooting

#### Interface Not Showing Up

**Symptoms**: No wlan0 interface.[1]

**Check Hardware**:[1]

```bash
rfkill list all
```

**Unblocked Required**:[1]

```bash
sudo rfkill unblock wifi
```

**Load Module**:[1]

```bash
sudo modprobe iwlwifi
```

**Check dmesg**:[1]

```bash
dmesg | tail -20
```

#### Can't See Networks

**Scan Networks**:[2][1]

```bash
sudo iw dev wlan0 scan
```

**Using iwctl**:[3]

```bash
iwctl station wlan0 get-networks
```

**Region Setting**: May limit visible networks:[1]

```bash
sudo iw reg set US  # Set your country code
```

#### Authentication Failures

**Symptoms**: Wrong password error.[1]

**Check Configuration**:[1]

```bash
sudo cat /etc/wpa_supplicant/wpa_supplicant.conf
```

**Debug Output**:[1]

```bash
sudo wpa_supplicant -d -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

**Verbose Logs**:[1]

```bash
journalctl -u wpa_supplicant -f
```

#### No IP Address Obtained

**Symptoms**: Connected but no IP.[1]

**Check DHCP**:[1]

```bash
sudo dhcpcd -d wlan0
```

**Manual Configuration**:[1]

```bash
sudo ip addr add 192.168.1.100/24 dev wlan0
sudo ip route add default via 192.168.1.1
ping 8.8.8.8
```

**DHCP Log**:[1]

```bash
journalctl -u dhcpcd@wlan0 -f
```

#### Slow Connection

**Signal Strength**:[1]

```bash
iw dev wlan0 link
```

**Poor Signal**: Try moving closer to router.[1]

**Interference**: Check for conflicting WiFi networks:[1]

```bash
sudo iw dev wlan0 scan | grep -i ssid
```

#### Connection Drops

**Power Management**:[1]

Disable aggressive power saving:

```bash
sudo iw dev wlan0 set power_save off
```

**Persistent Configuration**: `/etc/modprobe.d/wireless.conf`:[1]

```
options iwlwifi power_save=0
options ath9k ps_enable=0
```

**Roaming Issues**:[1]

In systemd-networkd:

```ini
[Network]
IgnoreCarrierLoss=3s
```

#### Firmware Issues

**Missing Firmware**:[1]

```bash
dmesg | grep -i firmware
```

**Installation**:[1]

```bash
sudo pacman -S linux-firmware
```

**Specific Firmware**:[1]

```bash
sudo pacman -S linux-firmware-bnx2x linux-firmware-liquidio
```

### Advanced Configuration

#### Multiple Networks

**Store Networks**: iwd stores in `/var/lib/iwd/`:[3]

```
SSID.psk
SSID.open
```

**Automatic Reconnection**:[3]

Previously connected networks auto-connect.[3]

**Priority Networks**: NetworkManager allows priority:[1]

```bash
nmcli connection modify SSID connection.autoconnect-priority 100
```

#### Hidden Networks

**Connect to Hidden SSID**:[2]

```bash
nmcli device wifi connect SSID --ask
```

Or add manually:[1]

```bash
iwctl known-networks add SSID
iwctl station wlan0 connect-hidden SSID
```

#### WPS Connection

**WiFi Protected Setup**:[1]

```bash
sudo wpa_cli wps_pbc
```

**Push Button**: Press WPS button on router.[1]

#### Enterprise Networks

**WPA2-Enterprise (RADIUS)**:[1]

```
network={
    ssid="enterprise-ssid"
    key_mgmt=WPA-EAP
    eap=TTLS
    identity="username"
    password="password"
    phase2="auth=MSCHAPV2"
}
```

### Network Diagnostics

#### Connectivity Testing

**Basic Test**:[1]

```bash
ping -c 4 8.8.8.8
```

**DNS Resolution**:[1]

```bash
nslookup archlinux.org
resolvectl query archlinux.org
```

**Signal Strength**:[1]

```bash
iw dev wlan0 link
```

**Throughput Test**:[1]

```bash
sudo iperf3 -s  # Server
iperf3 -c server_ip  # Client
```

#### Packet Analysis

**Capture Traffic**:[1]

```bash
sudo tcpdump -i wlan0 -w capture.pcap
```

**Analyze with Wireshark**:[1]

```bash
wireshark capture.pcap
```

### Configuration Examples

#### Complete DHCP Setup

**Step-by-Step**:[1]

```bash
# 1. Load driver
sudo modprobe iwlwifi

# 2. Enable interface
sudo ip link set wlan0 up

# 3. Connect to network (iwd)
iwctl station wlan0 connect SSID

# 4. Get IP address
sudo dhcpcd wlan0

# 5. Test
ping 8.8.8.8
```

#### Complete Static Setup

**Step-by-Step**:[1]

```bash
# 1. Connect to network
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf

# 2. Assign static IP
sudo ip addr add 192.168.1.100/24 dev wlan0
sudo ip route add default via 192.168.1.1

# 3. Set DNS
sudo nano /etc/resolv.conf
# Add: nameserver 8.8.8.8

# 4. Test
ping archlinux.org
```

### Best Practices

**Check Hardware First**: Verify adapter detection.[1]

**Load Drivers Early**: Test driver loading immediately.[1]

**Use Modern Tools**: Prefer iwd or NetworkManager.[3][1]

**Monitor Logs**: Check journalctl for issues.[1]

**Test Connection**: Verify each step works.[1]

**Document Setup**: Record working configuration.[1]

**Keep Firmware Updated**: Maintain current linux-firmware.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Network configuration - ArchWiki https://wiki.archlinux.org/title/Network_configuration
[3] iwd - ArchWiki https://wiki.archlinux.org/title/Iwd

