## Network Sharing and Bridging


### Network Bridge Fundamentals

**Purpose**: Connects multiple network segments into single network.[1]

**Use Cases**:[1]
- Connect VM to physical network[1]
- Link multiple interfaces[1]
- Create redundant paths[1]

**Concept**: Bridge acts as Layer 2 switch.[1]

### Creating Network Bridge

#### Using ip Command

**Create Bridge**:[1]

```bash
sudo ip link add br0 type bridge
```

**Add Interface**:[1]

```bash
sudo ip link set eth0 master br0
```

**Enable Bridge**:[1]

```bash
sudo ip link set br0 up
sudo ip link set eth0 up
```

**Assign IP**:[1]

```bash
sudo ip addr add 192.168.1.100/24 dev br0
sudo ip route add default via 192.168.1.1
```

#### Persistent Configuration (systemd-networkd)

**Bridge Network File**: `/etc/systemd/network/20-bridge.network`:[1]

```ini
[Match]
Name=eth0

[Network]
Bridge=br0

[Link]
NamePolicy=keep
```

**Bridge Interface File**: `/etc/systemd/network/30-bridge-interface.network`:[1]

```ini
[Match]
Name=br0

[Network]
DHCP=yes
```

**Static IP**:[1]

```ini
[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8
```

#### Persistent Configuration (netctl)

**Create Profile**: `/etc/netctl/bridge`:[1]

```
Description="Bridge"
Interface=br0
Connection=bridge
BindsToInterfaces=(eth0)
IP=dhcp

[IPv4]
# Static IP alternative
# Address=('192.168.1.100/24')
# Routes=('0.0.0.0/0 via 192.168.1.1')
```

**Enable**:[1]

```bash
sudo netctl enable bridge
sudo netctl start bridge
```

### Virtual Network Interfaces

#### TAP Interface

**Purpose**: User-space network interface.[1]

**Create TAP**:[1]

```bash
sudo ip tuntap add mode tap tap0
sudo ip link set tap0 up
```

**Assign IP**:[1]

```bash
sudo ip addr add 192.168.100.1/24 dev tap0
```

**Add to Bridge**:[1]

```bash
sudo ip link set tap0 master br0
```

#### TUN Interface

**Purpose**: Tunnel for routing.[1]

**Create TUN**:[1]

```bash
sudo ip tuntap add mode tun tun0
sudo ip link set tun0 up
```

**Use Case**: VPN, overlay networks.[1]

### Network Address Translation (NAT)

#### Enable IP Forwarding

**System Setting**:[1]

```bash
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**Persistent File**: `/etc/sysctl.d/99-forwarding.conf`:[1]

```
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

#### NAT with iptables (Legacy)

**Masquerade Traffic**:[1]

```bash
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o br0 -j ACCEPT
```

**Save Rules**:[1]

```bash
sudo iptables-save > /etc/iptables/iptables.rules
```

#### NAT with nftables

**NAT Table**: `/etc/nftables.conf`:[1]

```
table inet nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
    }
    
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        oif eth0 masquerade
    }
}
```

**Load Rules**:[1]

```bash
sudo nft -f /etc/nftables.conf
```

#### Port Forwarding

**Forward Port with iptables**:[1]

```bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.100.50:80
```

**Forward Port with nftables**:[1]

```
chain prerouting {
    type nat hook prerouting priority -100; policy accept;
    tcp dport 8080 dnat to 192.168.100.50:80
}
```

### Network Bonding

#### Purpose

**Link Aggregation**: Combine multiple links for bandwidth/redundancy.[1]

**Modes**:[1]
- `balance-rr`: Round-robin[1]
- `active-backup`: One active, others backup[1]
- `balance-alb`: Adaptive load balancing[1]

#### Create Bond

**Using ip**:[1]

```bash
sudo ip link add bond0 type bond mode=active-backup miimon=100
sudo ip link set eth0 master bond0
sudo ip link set eth1 master bond0
sudo ip link set bond0 up
```

**Assign IP**:[1]

```bash
sudo ip addr add 192.168.1.100/24 dev bond0
```

#### Persistent Bond (systemd-networkd)

**Bond Device**: `/etc/systemd/network/20-bond.netdev`:[1]

```ini
[NetDev]
Name=bond0
Kind=bond

[Bond]
Mode=active-backup
MIIMonitorSec=100ms
```

**Member Interfaces**:[1]

Create `/etc/systemd/network/20-eth0.network`:

```ini
[Match]
Name=eth0

[Network]
Bond=bond0
```

Create `/etc/systemd/network/20-eth1.network`:

```ini
[Match]
Name=eth1

[Network]
Bond=bond0
```

**Bond Interface**: `/etc/systemd/network/30-bond0.network`:[1]

```ini
[Match]
Name=bond0

[Network]
DHCP=yes
```

### Proxy Configuration

#### Squid HTTP Proxy

**Installation**: `sudo pacman -S squid`.[2][1]

**Config File**: `/etc/squid/squid.conf`:[1]

```
http_port 3128
http_access allow all
coredump_dir /var/cache/squid
cache_dir ufs /var/cache/squid 100 16 256
```

**Enable Service**:[1]

```bash
sudo systemctl enable --now squid
```

**Client Configuration**:[1]

```bash
export http_proxy=http://proxy-server:3128
export https_proxy=http://proxy-server:3128
```

#### SOCKS Proxy (SSH)

**Create Tunnel**:[1]

```bash
ssh -D 1080 user@remote-server
```

**Configure Application**: Point to `localhost:1080` as SOCKS5 proxy.[1]

### VLAN Configuration

#### Purpose

**Virtual LAN**: Segment network logically.[1]

**Use Case**: Isolate traffic, security zones.[1]

#### Create VLAN

**Using ip**:[1]

```bash
sudo ip link add link eth0 name eth0.100 type vlan id 100
sudo ip addr add 10.100.0.1/24 dev eth0.100
sudo ip link set eth0.100 up
```

**Persistent**: `/etc/systemd/network/20-vlan100.netdev`:[1]

```ini
[NetDev]
Name=eth0.100
Kind=vlan

[VLAN]
Id=100
```

### Multicast and Broadcasting

#### Multicast Routing

**Enable**:[1]

```bash
sudo sysctl net.ipv4.ip_multicast_routing=1
```

**Route Multicast**:[1]

```bash
sudo ip route add 224.0.0.0/4 dev eth0
```

#### mDNS (Multicast DNS)

**Install avahi**: `sudo pacman -S avahi`.[1]

**Enable Service**:[1]

```bash
sudo systemctl enable --now avahi-daemon.service
```

**Browse Services**:[1]

```bash
avahi-browse -r -t _http._tcp
```

### Network Monitoring

#### Check Bridge Status

**List Bridges**:[1]

```bash
brctl show
```

**Bridge Details**:[1]

```bash
sudo ip link show br0
sudo ip addr show br0
```

#### Monitor Traffic

**Real-time Stats**:[1]

```bash
iftop -i eth0
nethogs
```

**Tcpdump Capture**:[1]

```bash
sudo tcpdump -i eth0 -w capture.pcap
```

### Troubleshooting Network Sharing

#### Bridge Won't Create

**Check Bridge Module**:[1]

```bash
lsmod | grep bridge
```

**Load Module**:[1]

```bash
sudo modprobe bridge
```

#### No Traffic on Bridge

**Enable Forwarding**:[1]

```bash
sudo sysctl net.ipv4.ip_forward=1
```

**Check Bridge Membership**:[1]

```bash
brctl show
```

#### NAT Not Working

**Verify Rules**:[1]

```bash
sudo iptables -t nat -L -n
sudo nft list ruleset
```

**Enable Forwarding**:[1]

```bash
sudo sysctl net.ipv4.ip_forward=1
```

### Bonding Troubleshooting

#### Bond Status

**Check Bond**:[1]

```bash
cat /proc/net/bonding/bond0
```

**Member Status**:[1]

```bash
sudo ethtool eth0
sudo ethtool eth1
```

#### Failover Not Working

**MII Monitor**: Ensure monitoring enabled:[1]

```
miimon=100
```

**Check Carrier**:[1]

```bash
ethtool eth0 | grep -i carrier
```

### Best Practices

**Plan Network Layout**: Document topology.[1]

**Test First**: Verify on isolated network.[1]

**Monitor Performance**: Check bandwidth usage.[1]

**Backup Configuration**: Save working setups.[1]

**Enable IP Forwarding**: Required for routing.[1]

**Update Firewall Rules**: Adjust for new topology.[1]

**Document Changes**: Record network modifications.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824


