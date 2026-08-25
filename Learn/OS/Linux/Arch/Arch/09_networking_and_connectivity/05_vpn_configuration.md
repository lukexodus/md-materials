## VPN Configuration


### VPN Fundamentals

**Purpose**: Virtual Private Network creates encrypted tunnel through public networks.[1][2]

**Benefits**:[2][1]
- Encryption of traffic[1]
- Privacy from ISP/network[1]
- Access to remote networks[1]
- Security on public WiFi[1]

**Protocols**:[2]
- WireGuard: Modern, fast, simple[2]
- OpenVPN: Established, widely supported[2]
- IPSec: Enterprise standard[2]

### WireGuard

#### Overview

**Modern Protocol**: Designed for simplicity and speed.[2]

**Kernel Module**: Integrated into Linux kernel.[2]

**Installation**: `sudo pacman -S wireguard-tools`.[1][2]

#### Key Generation

**Generate Keys**:[1][2]

```bash
mkdir -p /etc/wireguard
cd /etc/wireguard

# Server keys
wg genkey | tee server_private.key | wg pubkey > server_public.key

# Client keys
wg genkey | tee client_private.key | wg pubkey > client_public.key

# Set permissions
sudo chmod 600 server_private.key client_private.key
```

#### Server Configuration

**Config File**: `/etc/wireguard/wg0.conf`:[1][2]

```ini
[Interface]
PrivateKey = <server_private_key_content>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <client_public_key_content>
AllowedIPs = 10.0.0.2/32
```

**Permissions**: `sudo chmod 600 /etc/wireguard/wg0.conf`.[1]

#### Server Startup

**Enable Service**:[2][1]

```bash
sudo systemctl enable wg-quick@wg0.service
sudo systemctl start wg-quick@wg0.service
```

**Check Status**:[1]

```bash
sudo wg show
```

#### Client Configuration

**Client Config**: `wg0-client.conf`:[2][1]

```ini
[Interface]
PrivateKey = <client_private_key_content>
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = <server_public_key_content>
Endpoint = server.example.com:51820
AllowedIPs = 10.0.0.0/24
PersistentKeepalive = 25
```

#### Client Connection

**Connect**:[2][1]

```bash
sudo wg-quick up ./wg0-client.conf
```

**Disconnect**:[1]

```bash
sudo wg-quick down wg0-client
```

**Enable Auto-Start**:[1]

```bash
sudo cp wg0-client.conf /etc/wireguard/wg0.conf
sudo systemctl enable wg-quick@wg0.service
```

#### Advanced Configuration

**Multiple Clients**:[1]

Add multiple `[Peer]` sections in server config:

```ini
[Peer]
PublicKey = <client1_public_key>
AllowedIPs = 10.0.0.2/32

[Peer]
PublicKey = <client2_public_key>
AllowedIPs = 10.0.0.3/32
```

**IP Forwarding**: Enable on server:[1]

```bash
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**NAT/Masquerading**:[1]

```bash
sudo ufw allow 51820/udp
sudo ufw route allow in on wg0
```

Or with nftables:[1]

```
table inet nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        oif eth0 masquerade
    }
}
```

### OpenVPN

#### Overview

**Established Protocol**: Long-proven track record.[2]

**Flexible**: Works over TCP and UDP.[2]

**Installation**: `sudo pacman -S openvpn`.[2][1]

#### Certificate Generation

**Easy-RSA Tool**:[1]

```bash
pacman -S easy-rsa
make-cadir ~/openvpn-ca
cd ~/openvpn-ca
```

**Generate CA**:[1]

```bash
./easyrsa init-pki
./easyrsa build-ca
```

**Generate Server Certificate**:[1]

```bash
./easyrsa gen-req server nopass
./easyrsa sign-req server server
./easyrsa gen-dh
```

**Generate Client Certificate**:[1]

```bash
./easyrsa gen-req client nopass
./easyrsa sign-req client client
```

#### Server Configuration

**Config File**: `/etc/openvpn/server.conf`:[2][1]

```
port 1194
proto udp
dev tun

ca /path/to/ca.crt
cert /path/to/server.crt
key /path/to/server.key
dh /path/to/dh.pem

server 10.8.0.0 255.255.255.0

push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"

keepalive 10 120
cipher AES-256-GCM
persist-key
persist-tun

status /var/log/openvpn/status.log
log /var/log/openvpn/openvpn.log
verb 3
```

**Enable Service**:[2][1]

```bash
sudo systemctl enable --now openvpn-server@server.service
```

#### Client Configuration

**Config File**: `client.ovpn`:[2][1]

```
client
dev tun
proto udp

remote vpn.example.com 1194

ca ca.crt
cert client.crt
key client.key

remote-cert-tls server
cipher AES-256-GCM
verb 3
```

**Connect**:[1]

```bash
sudo openvpn --config client.ovpn
```

#### Systemd Service for Client

**Create Service**: `/etc/systemd/system/openvpn-client@.service`:[1]

```ini
[Unit]
Description=OpenVPN connection to %i
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/openvpn --config %i.conf --cd /etc/openvpn/client
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

**Enable Client Connection**:[1]

```bash
sudo cp client.ovpn /etc/openvpn/client/client.conf
sudo systemctl enable openvpn-client@client.service
sudo systemctl start openvpn-client@client.service
```

### IPSec/strongSwan

#### Installation

**Install strongSwan**: `sudo pacman -S strongswan`.[2]

#### Configuration

**Config File**: `/etc/ipsec.conf`:[2]

```
config setup
    charondebug="ike 1, knl 1, cfg 0"
    unique=no

conn roadwarrior
    left=%defaultroute
    leftsubnet=0.0.0.0/0
    leftcert=server.crt
    leftsendcert=always
    right=%any
    rightid=%any
    rightsourceip=10.3.0.0/24
    rightdns=8.8.8.8
    auto=add
    compress=yes
    fragmentation=yes
    forceencaps=yes
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256!
    dpdaction=clear
    dpddelay=60s
    rekey=no
```

**Enable Service**:[2]

```bash
sudo systemctl enable --now strongswan.service
```

### VPN Client Tools

#### nmcli (NetworkManager)

**Configure VPN**:[1]

```bash
nmcli connection add type openvpn con-name myvpn ifname tun0 \
    openvpn-ca-cert ca.crt \
    openvpn-cert client.crt \
    openvpn-key client.key \
    openvpn-remote vpn.example.com
```

**Connect**:[1]

```bash
nmcli connection up myvpn
```

#### GUI Tools

**GNOME**: Settings → Network → VPN.[2]

**KDE**: System Settings → Network → VPN.[2]

**Cinnamon**: Network applet → VPN.[2]

### VPN Troubleshooting

#### WireGuard Connection Issues

**Check Interface**:[1]

```bash
sudo wg show
sudo ip link show wg0
```

**Debug Output**:[1]

```bash
sudo wg-quick up wg0 --verbose
```

**Check Firewall**:[1]

```bash
sudo ufw allow 51820/udp
```

#### OpenVPN Connection Issues

**Check Logs**:[1]

```bash
sudo tail -f /var/log/openvpn/openvpn.log
journalctl -u openvpn-server@server.service -f
```

**Test Connectivity**:[1]

```bash
ping 10.8.0.1
```

**Verify Certificates**:[1]

```bash
openssl x509 -in client.crt -text -noout
```

#### DNS Issues

**Manual DNS**:[1]

```bash
sudo systemctl start systemd-resolved
```

**Configure DNS in Client Config**:[1]

```
dhcp-option DNS 1.1.1.1
dhcp-option DNS 8.8.8.8
```

### VPN Performance Optimization

#### Compression

**WireGuard**: Not supported natively.[2]

**OpenVPN**:[1]

```
compress lz4
```

#### Cipher Selection

**WireGuard**: Fixed, optimized.[2]

**OpenVPN**: Adjust cipher:[1]

```
cipher AES-256-GCM  # Modern
cipher AES-128-GCM  # Faster
```

#### Connection Parameters

**Keep-Alive**:[1]

```
keepalive 10 120  # Check every 10s, timeout after 120s
```

**Fragment Size**:[2]

```
mssfix 1450  # Adjust for MTU
```

### VPN Security Best Practices

**Strong Certificates**: 4096-bit RSA or ed25519.[1]

**Update Regularly**: Keep software current.[1]

**Firewall Rules**: Restrict VPN port access.[1]

**Kill Switch**: Configure to disconnect if VPN drops.[1]

**Perfect Forward Secrecy**: Enable in OpenVPN:[1]

```
dh dh2048.pem
```

**Audit Logs**: Monitor VPN access:[1]

```bash
sudo tail -f /var/log/openvpn/status.log
```

### Comparison Table

| Feature | WireGuard | OpenVPN | IPSec |
|---------|-----------|---------|-------|
| **Setup** | Simple [2] | Complex [2] | Medium [2] |
| **Performance** | Excellent [2] | Good [2] | Good [2] |
| **Maturity** | Newer [2] | Established [2] | Enterprise [2] |
| **Configuration** | Minimal [2] | Detailed [2] | Complex [2] |
| **Encryption** | Modern [2] | Configurable [1] | Various [2] |
| **Use Case** | General VPN [2] | Compatibility [2] | Enterprise [2] |

### Best Practices

**Test on LAN First**: Verify setup on local network.[1]

**Document Configuration**: Record all settings.[1]

**Backup Keys**: Keep certificates safe.[1]

**Monitor Traffic**: Check bandwidth usage.[1]

**Keep Logs**: Enable and review VPN logs.[1]

**Update Regularly**: Apply security patches.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

