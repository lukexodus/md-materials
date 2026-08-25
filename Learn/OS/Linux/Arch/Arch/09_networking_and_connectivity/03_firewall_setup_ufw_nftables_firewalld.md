## Firewall Setup (ufw, nftables, firewalld)


### Firewall Fundamentals

**Purpose**: Control network traffic, block unauthorized connections, protect system.[1][2]

**Layers**:[1]
- Packet filtering[1]
- Connection tracking[1]
- Rule-based access control[1]

**Linux Kernel**: netfilter framework manages firewall.[1]

**Frontend Tools**: User-friendly interfaces to netfilter.[1]

### UFW (Uncomplicated Firewall)

#### Overview

**Philosophy**: Simple firewall for beginners.[2][1]

**Installation**: `sudo pacman -S ufw`.[2][1]

**Enable Service**:[2][1]

```bash
sudo systemctl enable --now ufw.service
```

#### Basic Usage

**Check Status**:[2][1]

```bash
sudo ufw status
```

**Enable Firewall**:[2][1]

```bash
sudo ufw enable
```

**Disable Firewall**:[1]

```bash
sudo ufw disable
```

#### Inbound/Outbound Rules

**Default Policies**:[2][1]
- Deny incoming[1]
- Allow outgoing[1]

**Change Default**:[1]

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

**Reverse for permissive**:[1]

```bash
sudo ufw default allow incoming
```

#### Allowing Services

**Allow Service**:[2][1]

```bash
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
```

**Allow Specific Port**:[1]

```bash
sudo ufw allow 80/tcp
sudo ufw allow 22/udp
```

**Allow Port Range**:[2][1]

```bash
sudo ufw allow 6000:6007/tcp
```

**Allow from IP**:[1]

```bash
sudo ufw allow from 192.168.1.50 to any port 22
```

#### Denying Traffic

**Deny Service**:[1]

```bash
sudo ufw deny http
```

**Deny Specific Port**:[1]

```bash
sudo ufw deny 23/tcp
```

**Delete Rule**:[1]

```bash
sudo ufw delete allow 80/tcp
```

#### Rule Management

**List Rules**:[2][1]

```bash
sudo ufw show added
sudo ufw status numbered
```

**Enable/Disable Rule**:[1]

```bash
sudo ufw disable
sudo ufw enable
```

**Reset to Defaults**:[1]

```bash
sudo ufw reset
```

#### Logging

**Enable Logging**:[1]

```bash
sudo ufw logging on
```

**Set Log Level**:[1]

```bash
sudo ufw logging high
```

**View Logs**:[1]

```bash
sudo tail -f /var/log/ufw.log
journalctl -u ufw
```

### nftables

#### Overview

**Modern Standard**: Successor to iptables.[2][1]

**Installation**: `sudo pacman -S nftables`.[2][1]

**Enable Service**:[1]

```bash
sudo systemctl enable --now nftables.service
```

#### Configuration File

**Location**: `/etc/nftables.conf`.[1]

**Basic Structure**:[1]

```
#!/usr/bin/env nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority filter; policy drop;
        
        # Accept loopback
        iif lo accept
        
        # Accept established connections
        ct state established,related accept
        
        # Accept SSH
        tcp dport 22 accept
        
        # Accept HTTP/HTTPS
        tcp dport { 80, 443 } accept
    }
    
    chain forward {
        type filter hook forward priority filter; policy drop;
    }
    
    chain output {
        type filter hook output priority filter; policy accept;
    }
}
```

#### Creating Rules

**Simple Rule**:[1]

```
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        iif lo accept
        ct state established,related accept
    }
}
```

**Allow SSH**:[1]

```
table inet filter {
    chain input {
        tcp dport ssh accept
    }
}
```

**Port Range**:[1]

```
tcp dport 8000-9000 accept
```

#### Loading Configuration

**Load Rules**:[1]

```bash
sudo nft -f /etc/nftables.conf
```

**Flush Rules**:[1]

```bash
sudo nft flush ruleset
```

**List Rules**:[1]

```bash
sudo nft list ruleset
```

#### Advanced Configuration

**Network Address Translation (NAT)**:[1]

```
table nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        oif eth0 masquerade
    }
}
```

**Port Forwarding**:[1]

```
table nat {
    chain prerouting {
        type nat hook prerouting priority -100;
        tcp dport 8080 dnat to 192.168.1.100:80
    }
}
```

### firewalld

#### Overview

**Dynamic Management**: Runtime changes without restarting.[2][1]

**Installation**: `sudo pacman -S firewalld`.[2]

**Enable Service**:[2][1]

```bash
sudo systemctl enable --now firewalld.service
```

**Disable conflicting**: Stop UFW if running:[1]

```bash
sudo systemctl stop ufw
sudo systemctl disable ufw
```

#### Firewall Zones

**Concept**: Predefined security levels.[2]

**Available Zones**:[2]
- `drop`: Lowest trust, deny all[2]
- `block`: Deny all, explicit denies[2]
- `public`: Default, minimal trust[2]
- `external`: For NAT, limited trust[2]
- `dmz`: Demilitarized zone[2]
- `work`: Work network[2]
- `home`: Home network[2]
- `internal`: Internal network[2]
- `trusted`: Highest trust, allow all[2]

**Set Default Zone**:[2][1]

```bash
sudo firewall-cmd --set-default-zone=public
```

**List Active Zones**:[2]

```bash
sudo firewall-cmd --get-active-zones
```

#### Managing Services

**List Available Services**:[2][1]

```bash
sudo firewall-cmd --get-services
```

**Allow Service**:[2][1]

```bash
sudo firewall-cmd --add-service=http
sudo firewall-cmd --add-service=https
sudo firewall-cmd --add-service=ssh
```

**Permanent Rule**:[2][1]

```bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

**Remove Service**:[1]

```bash
sudo firewall-cmd --remove-service=http
```

#### Port Management

**Open Port**:[2][1]

```bash
sudo firewall-cmd --add-port=8080/tcp
```

**Permanent Port**:[1]

```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

**Port Range**:[2]

```bash
sudo firewall-cmd --add-port=6000-6007/tcp
```

**List Open Ports**:[1]

```bash
sudo firewall-cmd --list-ports
```

#### Configuration Files

**Zone Files**: `/etc/firewalld/zones/`.[2]

**Service Files**: `/etc/firewalld/services/`.[2]

**Custom Rules**: Add to zone XML files.[2]

### Firewall Comparison

| Feature | UFW | nftables | firewalld |
|---------|-----|----------|-----------|
| **Simplicity** | Easy [1] | Complex [1] | Medium [2] |
| **Learning Curve** | Low [2] | High [2] | Medium [2] |
| **Performance** | Good [2] | Excellent [2] | Good [2] |
| **Dynamic Rules** | No reload needed [1] | Config reload [1] | Live updates [2] |
| **Flexibility** | Limited [2] | Extensive [1] | Very flexible [2] |
| **Use Case** | Desktop/simple [2] | Advanced users [1] | Network servers [2] |

### Practical Firewall Setups

#### Desktop Firewall (UFW)

**Setup**:[1]

```bash
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
```

#### Server Firewall (firewalld)

**Setup**:[2]

```bash
sudo firewall-cmd --set-default-zone=public
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

#### Advanced Firewall (nftables)

**Web Server with SSH**:[1]

```
table inet filter {
    chain input {
        type filter hook input priority filter; policy drop;
        
        iif lo accept
        ct state established,related accept
        ct state invalid drop
        
        # SSH
        tcp dport 22 accept
        
        # HTTP/HTTPS
        tcp dport { 80, 443 } accept
    }
    
    chain forward {
        type filter hook forward priority filter; policy drop;
    }
    
    chain output {
        type filter hook output priority filter; policy accept;
    }
}
```

### Troubleshooting Firewall Issues

#### Service Can't Connect

**Check Rules**:[1]

```bash
# UFW
sudo ufw status numbered

# firewalld
sudo firewall-cmd --list-all

# nftables
sudo nft list ruleset
```

**Test Connectivity**:[1]

```bash
telnet localhost 8080
```

**Temporary Disable**:[1]

```bash
# UFW
sudo ufw disable

# firewalld
sudo firewall-cmd --panic-on
```

#### Firewall Won't Start

**Check Service**:[1]

```bash
sudo systemctl status firewalld
journalctl -u firewalld -f
```

**Conflicting Firewall**:[1]

Ensure only one active:

```bash
sudo systemctl stop ufw
sudo systemctl disable ufw
```

#### Performance Issues

**Check Rules Count**:[1]

```bash
sudo nft list ruleset | wc -l
```

**Optimize**: Consolidate redundant rules.[1]

### Best Practices

**Start Restrictive**: Deny by default, allow specific.[1]

**Document Rules**: Comment purpose of each rule.[1]

**Test Changes**: Verify connectivity

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

