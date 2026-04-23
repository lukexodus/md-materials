# resolvectl

---

## What It Is

**`resolvectl`** is the command-line interface to **systemd-resolved**, the systemd stub DNS resolver and LLMNR/mDNS client. It lets you query DNS, inspect per-interface resolver configuration, flush caches, and manage DNS-over-TLS settings.

On most modern systemd-based distros, `resolvectl` has replaced `systemd-resolve` (which still works as an alias on most systems).

---

## Prerequisites

systemd-resolved must be running:

```bash
systemctl status systemd-resolved
systemctl enable --now systemd-resolved
```

And `/etc/resolv.conf` should point to the stub resolver:

```bash
ls -la /etc/resolv.conf
# Should symlink to: /run/systemd/resolve/stub-resolv.conf
# or:                /usr/lib/systemd/resolv.conf

# Set it up if not already:
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

---

## DNS Queries

```bash
# Basic lookup (A record)
resolvectl query example.com

# Lookup specific record type
resolvectl query --type=MX example.com
resolvectl query --type=AAAA example.com
resolvectl query --type=TXT example.com
resolvectl query --type=NS example.com
resolvectl query --type=SOA example.com
resolvectl query --type=SRV _https._tcp.example.com
resolvectl query --type=TLSA example.com
resolvectl query --type=CAA example.com

# Reverse lookup (PTR)
resolvectl query 8.8.8.8

# Query via specific interface
resolvectl query --interface=eth0 example.com

# Query via specific protocol
resolvectl query --protocol=dns example.com
resolvectl query --protocol=llmnr example.com
resolvectl query --protocol=mdns example.com

# Force specific DNS server for this query
resolvectl query --dns-server=1.1.1.1 example.com

# Show full DNSSEC validation chain
resolvectl query --validate example.com
```

---

## Status

```bash
# Global status + all interfaces
resolvectl status

# Specific interface only
resolvectl status eth0
resolvectl status wlan0

# Short summary (less verbose)
resolvectl status --no-pager
```

### What status shows

- Global DNS servers configured
- Per-interface DNS servers (from DHCP or static config)
- Search domains per interface
- DNSSEC mode
- DNS-over-TLS mode
- LLMNR and mDNS status per interface
- Current feature level negotiated with upstream DNS

---

## Statistics & Cache

```bash
# Query statistics (cache hits, misses, queries sent)
resolvectl statistics

# Flush the DNS cache
resolvectl flush-caches

# Reset all statistics counters
resolvectl reset-statistics

# Show cache contents
resolvectl show-cache

# Show DNSSEC negative trust anchors
resolvectl nta
```

---

## Per-Interface Configuration

These settings apply for the current session only — they do not persist across reboots or network reconnects. For persistent config, use `.network` files (see below).

```bash
# Set DNS servers for an interface
resolvectl dns eth0 1.1.1.1 8.8.8.8

# Set search domains
resolvectl domain eth0 example.com internal.corp

# Set default route domain (queries not matching other domains go here)
resolvectl domain eth0 ~.

# Enable/disable LLMNR
resolvectl llmnr eth0 yes
resolvectl llmnr eth0 no
resolvectl llmnr eth0 resolve    # receive only, don't respond

# Enable/disable mDNS
resolvectl mdns eth0 yes
resolvectl mdns eth0 no
resolvectl mdns eth0 resolve

# Set DNSSEC mode
resolvectl dnssec eth0 yes
resolvectl dnssec eth0 no
resolvectl dnssec eth0 allow-downgrade

# Set DNS-over-TLS
resolvectl dnsovertls eth0 yes
resolvectl dnsovertls eth0 no
resolvectl dnsovertls eth0 opportunistic
```

---

## Service Resolution (DNS-SD)

```bash
# Browse services on local network (mDNS/DNS-SD)
resolvectl service _http._tcp.local

# Resolve a specific named service
resolvectl service myprinter._ipp._tcp.local

# Lookup OPENPGPKEY record (key by email)
resolvectl openpgp user@example.com

# Lookup TLSA record (TLS certificate association)
resolvectl tlsa tcp example.com:443
```

---

## DNSSEC

```bash
# Check DNSSEC validation for a domain
resolvectl query --validate example.com

# Show DNSSEC status
resolvectl status | grep DNSSEC

# Add a negative trust anchor (mark domain as not DNSSEC-signed)
resolvectl nta example.com

# Remove a negative trust anchor
resolvectl revert eth0     # reverts all runtime changes including NTAs
```

DNSSEC validation requires an upstream resolver that supports it, or systemd-resolved doing validation itself. Mode options:

|Mode|Behavior|
|---|---|
|`yes`|Full validation; reject unsigned responses|
|`allow-downgrade`|Validate when possible, fall back if unsupported upstream|
|`no`|No validation|

---

## Logs & Debugging

```bash
# View systemd-resolved logs
journalctl -u systemd-resolved -f

# Enable verbose DNS logging
resolvectl log-level debug

# Reset log level
resolvectl log-level info

# Check what resolved is actually using
resolvectl status
cat /run/systemd/resolve/resolv.conf     # what resolved sends to glibc
cat /run/systemd/resolve/stub-resolv.conf  # stub listener (127.0.0.53)
```

---

## Persistent Configuration

Runtime `resolvectl` changes are lost on reboot. For persistent DNS config, use systemd-networkd `.network` files:

```ini
# /etc/systemd/network/10-eth0.network

[Match]
Name=eth0

[Network]
DNS=1.1.1.1 8.8.8.8
Domains=example.com ~.
LLMNR=no
MulticastDNS=no
DNSSEC=allow-downgrade
DNSOverTLS=opportunistic
```

Or the global resolved config:

```ini
# /etc/systemd/resolved.conf

[Resolve]
DNS=1.1.1.1 8.8.8.8
FallbackDNS=9.9.9.9
Domains=~.
LLMNR=no
MulticastDNS=no
DNSSEC=allow-downgrade
DNSOverTLS=opportunistic
Cache=yes
DNSStubListener=yes
```

```bash
systemctl restart systemd-resolved    # apply changes
```

---

## /etc/resolv.conf Modes

systemd-resolved operates in different modes depending on how `/etc/resolv.conf` is set up:

|Symlink target|Mode|
|---|---|
|`/run/systemd/resolve/stub-resolv.conf`|Stub mode — all queries go to `127.0.0.53`; recommended|
|`/run/systemd/resolve/resolv.conf`|Direct mode — exposes upstream DNS servers directly|
|Static file (not a symlink)|Bypass mode — resolved is ignored by glibc|
|`/etc/resolv.conf` managed by other tool|Conflict possible|

Stub mode is the recommended setup — it ensures all DNS goes through resolved and benefits from caching, DNSSEC, and DNS-over-TLS.

---

## Tips & Gotchas

- **`resolvectl` changes are not persistent** — use `.network` or `resolved.conf` for anything that needs to survive a reboot or reconnect
- **`127.0.0.53` is the stub listener** — this is what glibc queries in stub mode; not a real external DNS server
- **Search domains affect query behavior** — a domain set with `~.` acts as a catch-all routing domain, sending all unmatched queries to that interface's DNS
- **LLMNR and mDNS are separate protocols** — LLMNR is Windows-originated (UDP 5355); mDNS is the Apple/Bonjour standard (UDP 5353); both resolve local names without a DNS server
- **`resolvectl query` vs `dig`/`nslookup`** — `resolvectl query` goes through systemd-resolved (respects cache, DNSSEC, routing); `dig` bypasses it and queries directly
- **Split DNS works via routing domains** — set `Domains=~corp.internal` on a VPN interface to route those queries there, and `~.` on the default interface for everything else
- **`flush-caches` is useful after DNS changes** — if a record was cached with a wrong value, flushing forces a fresh lookup
- **Multiple interfaces can have different DNS servers** — resolved routes queries to the correct interface based on domain routing rules

---

## Quick Reference

```bash
resolvectl query example.com              Basic lookup
resolvectl query --type=MX example.com    Specific record type
resolvectl query 8.8.8.8                  Reverse lookup
resolvectl status                         Global + interface status
resolvectl status eth0                    Single interface
resolvectl flush-caches                   Clear DNS cache
resolvectl statistics                     Cache hit/miss stats
resolvectl dns eth0 1.1.1.1               Set DNS for interface (runtime)
resolvectl domain eth0 ~.                 Set routing domain
resolvectl log-level debug                Verbose logging
journalctl -u systemd-resolved -f         Live logs
```