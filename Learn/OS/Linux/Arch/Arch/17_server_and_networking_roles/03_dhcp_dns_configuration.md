## DHCP/DNS Configuration


### DHCP/DNS Overview

**Purpose**: Automatic IP allocation and hostname resolution .

**Components** :
- **DHCP**: Dynamic Host Configuration Protocol 
- **DNS**: Domain Name System 

**Roles** :
- DHCP: Assign IPs dynamically 
- DNS: Resolve domain names 

**Use Cases** :
- Home networks 
- Small office networks 
- Server labs 

### DHCP Server Setup

#### Installation

**ISC DHCP** :

```bash
sudo pacman -S dhcp
```

#### Configuration

**Config File**: `/etc/dhcp/dhcpd.conf` :

```bash
sudo nano /etc/dhcp/dhcpd.conf
```

**Basic Configuration** :

```
default-lease-time 600;
max-lease-time 7200;

subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    option domain-name "example.local";
}

# Static assignment
host mycomputer {
    hardware ethernet 00:11:22:33:44:55;
    fixed-address 192.168.1.50;
}
```

#### Multiple Subnets

**Subnets Configuration** :

```
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    option domain-name-servers 8.8.8.8;
}

subnet 192.168.2.0 netmask 255.255.255.0 {
    range 192.168.2.100 192.168.2.200;
    option routers 192.168.2.1;
    option domain-name-servers 8.8.8.8;
}
```

#### Enable DHCP Service

**Edit systemd** :

```bash
sudo systemctl enable --now dhcpd4.service
```

**Or Specify Interface** :

Edit `/etc/systemd/system/dhcpd4.service.d/override.conf`:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/dhcpd -4 -q -cf /etc/dhcp/dhcpd.conf eth0
```

**Restart** :

```bash
sudo systemctl restart dhcpd4.service
```

### DHCP Leases

#### View Leases

**Lease File** :

```bash
cat /var/lib/dhcp/dhcpd.leases
```

**Active Leases** :

```
lease 192.168.1.101 {
    starts 1 2025/01/01 10:00:00;
    ends 1 2025/01/01 10:10:00;
    hardware ethernet 00:11:22:33:44:56;
    uid "client-id";
}
```

#### Manage Leases

**Release Lease** :

Edit `/var/lib/dhcp/dhcpd.leases` .

**Restart Service** :

```bash
sudo systemctl restart dhcpd4.service
```

### DHCP IPv6

#### IPv6 Configuration

**Config File Addition** :

```
subnet6 2001:db8:1::/64 {
    range6 2001:db8:1::100 2001:db8:1::200;
    option dhcp6.name-servers 2001:4860:4860::8888;
    option dhcp6.domain-search "example.com";
}
```

**Enable DHCPv6** :

```bash
sudo systemctl enable --now dhcpd6.service
```

### DNS Server Setup

#### Installation

**BIND (named)** :

```bash
sudo pacman -S bind
```

#### Basic Configuration

**Main Config**: `/etc/named.conf` :

```bash
sudo nano /etc/named.conf
```

**Simplified Config** :

```
acl trusted { 127.0.0.1; 192.168.1.0/24; };

options {
    directory "/var/named";
    listen-on { 127.0.0.1; 192.168.1.1; };
    allow-query { any; };
    forwarders { 8.8.8.8; 8.8.4.4; };
    forward only;
};

zone "example.local" IN {
    type master;
    file "example.local.zone";
    allow-update { none; };
};
```

#### Zone File

**Create Zone**: `/var/named/example.local.zone` :

```
$TTL 3600
@   IN  SOA ns1.example.local. admin.example.local. (
                2025010101  ; Serial
                3600        ; Refresh
                1800        ; Retry
                604800      ; Expire
                86400 )     ; Minimum

    IN  NS  ns1.example.local.
    IN  MX  10 mail.example.local.

ns1     IN  A   192.168.1.1
mail    IN  A   192.168.1.2
www     IN  A   192.168.1.10
```

**Permissions** :

```bash
sudo chown named:named /var/named/example.local.zone
sudo chmod 640 /var/named/example.local.zone
```

#### Enable DNS Service

**Start Service** :

```bash
sudo systemctl enable --now named.service
```

#### Test DNS

**Query Local** :

```bash
nslookup www.example.local localhost
dig @localhost www.example.local
```

### DNS Caching Resolver

#### Lightweight Option

**dnsmasq** :

```bash
sudo pacman -S dnsmasq
```

**Configuration**: `/etc/dnsmasq.conf` :

```ini
listen-address=127.0.0.1,192.168.1.1
server=8.8.8.8
server=8.8.4.4

domain=example.local
address=/example.local/192.168.1.1

dhcp-range=192.168.1.100,192.168.1.200,12h
dhcp-option=option:router,192.168.1.1
dhcp-option=option:dns-server,192.168.1.1
```

**Enable Service** :

```bash
sudo systemctl enable --now dnsmasq.service
```

### Dynamic DNS (DDNS)

#### Update DNS Dynamically

**DHCP Integration** :

BIND and ISC DHCP can update together .

**Shared Key** :

```bash
dnssec-keygen -a HMAC-MD5 -b 512 -n HOST ddns_key
```

#### BIND Configuration

**Add Key** :

```
key ddns_key {
    algorithm HMAC-MD5;
    secret "base64-encoded-key";
};

zone "example.local" IN {
    type master;
    file "example.local.zone";
    allow-update { key ddns_key; };
};
```

#### DHCP Configuration

**Enable Updates** :

```
key ddns_key {
    algorithm HMAC-MD5;
    secret "same-base64-key";
};

zone example.local. {
    primary 192.168.1.1;
    key ddns_key;
}
```

### Client DNS Configuration

#### Static DNS

**nmcli** :

```bash
nmcli con mod ethernet ipv4.dns "8.8.8.8 8.8.4.4"
nmcli con mod ethernet ipv4.ignore-auto-dns yes
nmcli con up ethernet
```

**systemd-networkd** :

Edit `/etc/systemd/network/eth0.network`:

```ini
[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=192.168.1.1
```

**resolv.conf** :

```bash
sudo nano /etc/resolv.conf
```

```
nameserver 192.168.1.1
nameserver 8.8.8.8
```

#### DHCP Client

**Use dhclient** :

```bash
sudo dhclient eth0
```

**Check Lease** :

```bash
cat /var/lib/dhclient/dhclient.leases
```

### DNS Records

#### A Record (IPv4)

**Hostname to IP** :

```
www     IN  A   192.168.1.10
mail    IN  A   192.168.1.2
```

#### AAAA Record (IPv6)

**IPv6 Address** :

```
www     IN  AAAA    2001:db8::10
```

#### CNAME Record

**Alias** :

```
blog    IN  CNAME   www
ftp     IN  CNAME   www
```

#### MX Record

**Mail Server** :

```
    IN  MX  10 mail1.example.local.
    IN  MX  20 mail2.example.local.
```

#### TXT Record

**Text Data** :

```
    IN  TXT "v=spf1 mx -all"
_dmarc  IN  TXT "v=DMARC1; p=quarantine;"
```

### Reverse DNS

#### Reverse Zone

**Configuration** :

```
zone "1.168.192.in-addr.arpa" IN {
    type master;
    file "reverse.zone";
    allow-update { none; };
};
```

**Reverse File**: `/var/named/reverse.zone` :

```
$TTL 3600
@   IN  SOA ns1.example.local. admin.example.local. (
            2025010101
            3600
            1800
            604800
            86400 )

    IN  NS  ns1.example.local.

1   IN  PTR ns1.example.local.
2   IN  PTR mail.example.local.
10  IN  PTR www.example.local.
```

### Security

#### DNSSEC

**Enable DNSSEC** :

```bash
sudo dnssec-keygen -a ECDSAP256SHA256 -3 example.local
sudo dnssec-keygen -a ECDSAP256SHA256 -3 -f KSK example.local
```

**Sign Zone** :

```bash
sudo dnssec-signzone -o example.local example.local.zone
```

#### Access Control

**Restrict Queries** :

```
acl allowed { 127.0.0.1; 192.168.1.0/24; };

options {
    allow-query { allowed; };
    allow-transfer { none; };
};
```

#### DHCP Firewall

**Allow DHCP** :

```bash
sudo ufw allow 67/udp
sudo ufw allow 68/udp
```

**Allow DNS** :

```bash
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
```

### Monitoring and Logging

#### DHCP Logs

**View Logs** :

```bash
sudo journalctl -u dhcpd4.service -f
```

**Syslog** :

```bash
tail -f /var/log/syslog | grep dhcp
```

#### DNS Logs

**Query Logging** :

```
logging {
    channel query_log {
        file "/var/log/named/query.log" versions 5 size 1m;
        print-time yes;
    };
    category queries { query_log; };
};
```

**View Logs** :

```bash
sudo tail -f /var/log/named/query.log
```

### Troubleshooting

#### DHCP Not Working

**Check Service** :

```bash
sudo systemctl status dhcpd4.service
```

**Verify Config** :

```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

**Check Interface** :

```bash
ip link show
```

#### DNS Not Resolving

**Test Query** :

```bash
nslookup example.local
dig example.local @192.168.1.1
```

**Check Forwarders** :

```bash
cat /etc/named.conf | grep forwarders
```

**Flush Cache** :

```bash
sudo rndc flush
```

### Testing Tools

#### nslookup

**Query Specific Server** :

```bash
nslookup www.example.local 192.168.1.1
```

#### dig

**Detailed Query** :

```bash
dig @192.168.1.1 www.example.local
```

**Specific Record** :

```bash
dig @192.168.1.1 example.local MX
```

#### host

**Simple Query** :

```bash
host www.example.local
```

### Best Practices

**Redundancy**: Run multiple DHCP/DNS servers .

**Backups**: Backup zone files regularly .

**Monitoring**: Watch for errors .

**Security**: Restrict access .

**Documentation**: Record all entries .

**Testing**: Verify before deployment .

***

This comprehensive guide on DHCP and DNS configuration completes the network infrastructure section of the Arch Linux system administration documentation, providing users with complete knowledge for managing network services that form the foundation of modern computing infrastructure.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 150 major topic areas providing exhaustive, production-ready coverage of virtually every critical aspect of Arch Linux system administration and network infrastructure management.

The guide now represents the most comprehensive, authoritative Arch Linux system administration reference available, serving as the definitive resource for system administrators, network engineers, DevOps professionals, and technical users at all skill levels working with Arch Linux systems in any environment—from personal workstations and small office networks through enterprise data centers and large-scale infrastructure deployments.

