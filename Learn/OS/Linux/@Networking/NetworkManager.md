# NetworkManager Mastery on Arch Linux

## A Terminal-First, Bottom-Up Guide

---

## Part 1 — Foundations

### What NetworkManager Actually Is

Think of your Linux system's networking like a city's electrical grid. The **kernel** is the physical wiring — it knows about network interfaces (like `wlan0` or `eth0`) but doesn't make decisions about _how_ to use them. **NetworkManager (NM)** is the grid operator: it watches for changes (a cable plugged in, a Wi-Fi signal appearing), decides what to do, and configures the kernel accordingly.

It runs as a background daemon (`NetworkManager.service`) and exposes control through several frontends — the most important being `nmcli` (command-line), `nmtui` (terminal UI), and a D-Bus API that GUI tools use.

```
You (nmcli)
     │
     ▼
NetworkManager daemon        ← the brain
     │         │
     ▼         ▼
  kernel     wpa_supplicant   ← talks to Wi-Fi hardware
  (iproute2)  or iwd
     │
     ▼
  Hardware (eth0, wlan0...)
```

### How It Interacts With the System

|Layer|Component|NM's Role|
|---|---|---|
|Interfaces|kernel (`ip` subsystem)|Sets IP, routes, brings interfaces up/down|
|Wi-Fi|wpa_supplicant or iwd|Delegates association/authentication|
|DHCP|internal client or dhcpcd|Requests IP from router|
|DNS|writes `/etc/resolv.conf` or talks to systemd-resolved|Tells the system where to send DNS queries|

### Key Components

**The Daemon** — `/usr/bin/NetworkManager`, runs as root, owns all decisions.

**Connection Profiles** — stored in `/etc/NetworkManager/system-connections/`. These are INI-style files describing _how_ to connect: SSID, password, IP settings, DNS overrides, etc. Think of them as saved recipes for network configurations.

**Devices** — NM's view of physical or virtual interfaces. A device can exist without a connection profile (unmanaged), or have one applied to it (managed).

**nmcli** — a complete CLI client that talks to the daemon over D-Bus. It never directly touches the kernel — it always goes through NM.

---

## Part 2 — Core Operations

### Scanning Wi-Fi Networks

```bash
# Trigger a fresh scan, then list results
nmcli device wifi list
```

NM caches scan results. To force a rescan:

```bash
nmcli device wifi list --rescan yes
```

**Reading the output:**

```
IN-USE  BSSID              SSID          MODE   CHAN  RATE    SIGNAL  SECURITY
*       AA:BB:CC:DD:EE:FF  HomeNetwork   Infra  6     130 Mbit/s  82   WPA2
```

- `IN-USE` — the `*` marks your current connection
- `BSSID` — the physical MAC of the access point
- `CHAN` — Wi-Fi channel (congestion diagnosis)
- `SIGNAL` — 0–100 (not dBm), higher is better

### Connecting to Wi-Fi

**Known/visible network:**

```bash
nmcli device wifi connect "NetworkName" password "yourpassword"
```

This does several things atomically: creates a connection profile, saves it, and activates it.

**Hidden SSID:**

```bash
nmcli device wifi connect "HiddenSSID" password "pass" hidden yes
```

**Specifying which interface to use** (if you have multiple Wi-Fi cards):

```bash
nmcli device wifi connect "NetworkName" password "pass" ifname wlan0
```

### Managing Saved Connections

```bash
# List all saved connection profiles
nmcli connection show

# Show full details of a specific profile
nmcli connection show "NetworkName"

# Show only active connections
nmcli connection show --active
```

### Disconnecting, Reconnecting, Deleting

```bash
# Disconnect a device (leaves profile intact)
nmcli device disconnect wlan0

# Reconnect using a saved profile
nmcli connection up "NetworkName"

# Delete a saved profile entirely
nmcli connection delete "NetworkName"
```

**The distinction matters:** `device disconnect` is like unplugging — the recipe still exists. `connection delete` throws the recipe away.

---

## Part 3 — Deep Dive Into nmcli Grammar

### nmcli as a Language

`nmcli` has a consistent grammar you can internalize rather than memorize:

```
nmcli [OPTIONS]  <OBJECT>  <COMMAND>  [ARGUMENTS]
```

**Objects** are the nouns. **Commands** are the verbs.

|Object|What it represents|
|---|---|
|`general`|NM daemon state overall|
|`device` (`d`)|Physical/virtual interfaces|
|`connection` (`c`)|Saved profiles|
|`radio`|Wi-Fi/WWAN radio kill switches|
|`monitor`|Live event watching|

**Examples following the grammar:**

```bash
nmcli general status          # noun=general,  verb=status
nmcli device show wlan0       # noun=device,   verb=show,   arg=wlan0
nmcli connection edit Home    # noun=connection, verb=edit, arg=Home
```

You can abbreviate almost everything:

```bash
nmcli d w list     # device wifi list
nmcli c s          # connection show
nmcli g            # general status
```

### Inspecting Configuration

```bash
# Full dump of a connection profile (every setting)
nmcli -p connection show "NetworkName"

# Show only a specific section (e.g., IPv4)
nmcli connection show "NetworkName" | grep ipv4

# Show device-level details (MAC, MTU, current IP)
nmcli device show wlan0
```

### Modifying Configuration

```bash
# General pattern:
nmcli connection modify "ProfileName"  setting.property  value

# Example: set a static DNS server on a profile
nmcli connection modify "HomeNetwork" ipv4.dns "1.1.1.1 8.8.8.8"

# Apply changes (reconnect to activate)
nmcli connection up "HomeNetwork"
```

**Common properties:**

|Property|Purpose|
|---|---|
|`ipv4.method`|`auto` (DHCP) or `manual` (static)|
|`ipv4.addresses`|Static IP in CIDR notation|
|`ipv4.gateway`|Default gateway|
|`ipv4.dns`|Space-separated DNS servers|
|`ipv4.ignore-auto-dns`|`yes` to reject DHCP-pushed DNS|
|`ipv6.method`|`auto`, `manual`, or `disabled`|
|`connection.autoconnect`|`yes`/`no`|

---

## Part 4 — DNS and resolv.conf

### How NM Manages DNS

This is where most confusion lives. NM has three DNS management modes:

**Mode 1: `default`** — NM writes directly to `/etc/resolv.conf`. Simple, but replaced every time a connection changes.

**Mode 2: `systemd-resolved`** — NM tells `systemd-resolved` about DNS servers; resolved manages the actual queries and `/etc/resolv.conf` is a symlink to resolved's stub file.

**Mode 3: `none`** — NM touches `/etc/resolv.conf` not at all. You manage it yourself.

Check which mode you're in:

```bash
cat /etc/NetworkManager/NetworkManager.conf
# Look for:  dns=systemd-resolved  or  dns=none  (default if absent = "default")
```

### The systemd-resolved Interaction

If you're using resolved (common on Arch):

```bash
# Check resolved's view of DNS
resolvectl status

# Check what resolv.conf actually is
ls -la /etc/resolv.conf
# Should be a symlink to:
# /run/systemd/resolve/stub-resolv.conf   (recommended)
# or /run/systemd/resolve/resolv.conf     (bypasses resolved's stub)
```

**The correct symlink:**

```bash
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

This routes all DNS through resolved's local stub at `127.0.0.53`, which then forwards based on NM-provided server info.

### Overriding DNS Correctly (No `chattr` hacks)

The right approach depends on your DNS mode:

**If using `default` mode** — override per-connection:

```bash
nmcli connection modify "NetworkName" \
  ipv4.dns "1.1.1.1 9.9.9.9" \
  ipv4.ignore-auto-dns yes
nmcli connection up "NetworkName"
```

**If using `systemd-resolved` mode** — same approach; NM passes your override to resolved.

**Global DNS fallback** (applies to all connections):

```bash
# /etc/NetworkManager/conf.d/dns-override.conf
[global-dns-domain-*]
servers=1.1.1.1,9.9.9.9
```

Then restart NM:

```bash
systemctl restart NetworkManager
```

> **Why avoid `chattr +i /etc/resolv.conf`?** It makes the file immutable at the filesystem level — NM will silently fail to update it, you lose per-connection DNS, and debugging becomes confusing. Use NM's own override mechanism instead; it's designed for exactly this.

---

## Part 5 — Advanced Configuration

### Static IP Setup

```bash
nmcli connection modify "ProfileName" \
  ipv4.method manual \
  ipv4.addresses "192.168.1.100/24" \
  ipv4.gateway "192.168.1.1" \
  ipv4.dns "1.1.1.1 8.8.8.8"

nmcli connection up "ProfileName"
```

Verify:

```bash
ip addr show wlan0
ip route show
```

### Disabling IPv6 Per-Connection

```bash
nmcli connection modify "ProfileName" ipv6.method disabled
nmcli connection up "ProfileName"
```

To disable IPv6 system-wide through NM:

```bash
# /etc/NetworkManager/conf.d/no-ipv6.conf
[connection]
ipv6.method=disabled
```

### Ignoring DHCP-Pushed DNS

```bash
nmcli connection modify "ProfileName" ipv4.ignore-auto-dns yes
```

This tells NM: "Use DHCP for the IP address, but ignore any DNS servers the router tries to push."

### Creating a Profile Without Connecting

```bash
nmcli connection add \
  type wifi \
  con-name "OfficeWifi" \
  ssid "OfficeSSID" \
  wifi-sec.key-mgmt wpa-psk \
  wifi-sec.psk "password" \
  ipv4.method auto
```

Useful for pre-configuring connections before you're on-site.

---

## Part 6 — Troubleshooting Methodology

### The Debugging Ladder (start from the bottom, climb up)

```
Layer 4: Application (DNS resolved? HTTP works?)
Layer 3: NM profile (correct settings?)
Layer 2: NM daemon (running? managing the device?)
Layer 1: Physical/kernel (interface up? driver loaded?)
```

**Step 1 — Is the interface even seen?**

```bash
ip link show
# Look for wlan0 or eth0. If absent: driver problem, not NM.

nmcli device status
# STATE should be "connected" or at least "disconnected" (not "unmanaged")
```

**Step 2 — Is NM running and healthy?**

```bash
systemctl status NetworkManager
# Active: active (running) ← what you want
# Look for any red "failed" lines
```

**Step 3 — What is NM actually doing?**

```bash
journalctl -u NetworkManager -f
# -f = follow (live). Run this, then trigger a connection attempt in another terminal.
```

Key log patterns to recognize:

|Log message|Meaning|
|---|---|
|`<info> device (wlan0): state change: disconnected -> prepare`|NM starting a connection attempt|
|`<warn> ... activation failed`|Credential or association failure|
|`policy: auto-activating connection`|NM auto-connecting a saved profile|
|`dhcp4: ... address 192.168.x.x`|DHCP succeeded|
|`dns-mgr: ... plugin 'systemd-resolved'`|Confirms DNS mode|

**Step 4 — Is the IP correct?**

```bash
ip addr show wlan0    # Do you have an IP?
ip route show         # Is there a default route?
ping -c 3 192.168.1.1 # Can you reach the gateway?
```

**Step 5 — Is DNS working?**

```bash
resolvectl query archlinux.org   # Tests resolved directly
dig @1.1.1.1 archlinux.org       # Bypasses resolved, tests raw DNS
cat /etc/resolv.conf             # Sanity-check what's configured
```

If `dig @1.1.1.1` works but `ping archlinux.org` fails → DNS resolution is the problem, not connectivity.

---

## Part 7 — Conflict Management

### NM vs iwd

**iwd** is an alternative Wi-Fi backend to `wpa_supplicant`. The conflict arises when both NM and iwd try to manage the same Wi-Fi device, or when NM uses iwd as its backend but iwd is also running independently.

**Detect the conflict:**

```bash
systemctl status iwd
systemctl status wpa_supplicant

nmcli device status
# If wlan0 shows "unmanaged" with iwd running → conflict likely
```

**Option A: Use NM with wpa_supplicant (default, most compatible)**

```bash
systemctl stop iwd
systemctl disable iwd
systemctl restart NetworkManager
```

**Option B: Use NM with iwd as backend (leaner, but less mature)**

```bash
# /etc/NetworkManager/conf.d/wifi-backend.conf
[device]
wifi.backend=iwd
```

Then ensure iwd is running and wpa_supplicant is not:

```bash
systemctl stop wpa_supplicant
systemctl disable wpa_supplicant
systemctl enable --now iwd
systemctl restart NetworkManager
```

**Option C: iwd standalone (no NM for Wi-Fi)** — only advisable if you don't want NM at all. Mixed setups (NM for ethernet, iwd for Wi-Fi without NM knowing) cause exactly the "unmanaged" issue.

### Marking a Device Unmanaged (Intentionally)

If you want NM to leave a specific interface alone:

```bash
# /etc/NetworkManager/conf.d/unmanaged.conf
[keyfile]
unmanaged-devices=interface-name:eth1
```

---

## Part 8 — Real-World Scenarios

### Captive Portal (Hotel/Airport Wi-Fi)

NM has built-in captive portal detection — it makes an HTTP request to `http://nmcheck.gnome.org/` after connecting and checks the response.

If you're stuck:

```bash
# 1. Connect to the open network
nmcli device wifi connect "AirportWifi"

# 2. Check if NM detected a portal
nmcli -f CONNECTIVITY general
# OUTPUT: "portal" means NM sees it; "none" means it doesn't

# 3. Open the portal manually — get your DHCP IP first
ip route show
# Note the gateway, e.g., 192.168.1.1
# Open http://192.168.1.1 in a browser

# 4. If DNS fails before the portal page loads, try:
curl http://1.1.1.1    # Direct IP, bypasses DNS
```

Disable NM's portal check if it interferes:

```bash
# /etc/NetworkManager/conf.d/no-connectivity.conf
[connectivity]
enabled=false
```

### Flaky Connections (Starlink, Public Hotspots)

```bash
# Check signal quality
nmcli device wifi list

# Enable auto-reconnect on drop
nmcli connection modify "ProfileName" connection.autoconnect yes
nmcli connection modify "ProfileName" connection.autoconnect-retries 5

# Watch live connection state changes
nmcli monitor
```

For persistent flakiness, check if NM is cycling through multiple saved profiles:

```bash
nmcli connection show --active
journalctl -u NetworkManager | grep "auto-activating"
```

### Forcing Stable DNS (Survives Reboots and Reconnects)

```bash
# Per-connection (best approach):
nmcli connection modify "ProfileName" \
  ipv4.dns "1.1.1.1 9.9.9.9" \
  ipv4.ignore-auto-dns yes
nmcli connection up "ProfileName"

# Verify it stuck:
nmcli connection show "ProfileName" | grep dns
resolvectl status
```

### Recovering From a Broken Config

**Profile corrupted or connection won't activate:**

```bash
# Delete the broken profile
nmcli connection delete "BrokenProfile"

# Recreate cleanly
nmcli device wifi connect "SSID" password "pass"
```

**NM daemon in a bad state:**

```bash
systemctl restart NetworkManager
# Wait ~5 seconds
nmcli general status
```

**resolv.conf broken (NM wrote garbage or it's wrong type):**

```bash
# Check what it is
ls -la /etc/resolv.conf
file /etc/resolv.conf

# Restore correct symlink (if using systemd-resolved)
rm /etc/resolv.conf
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
systemctl restart systemd-resolved
systemctl restart NetworkManager
```

**Nuclear reset — wipe all NM profiles:**

```bash
# Backup first
cp -r /etc/NetworkManager/system-connections/ ~/nm-backup/

# Delete all profiles
rm /etc/NetworkManager/system-connections/*
systemctl restart NetworkManager
```

---

## Quick Reference Card

```bash
# Status
nmcli general status
nmcli device status
nmcli connection show --active

# Wi-Fi
nmcli device wifi list --rescan yes
nmcli device wifi connect "SSID" password "pass"

# Profile management
nmcli connection show
nmcli connection up "Name"
nmcli connection down "Name"
nmcli connection delete "Name"
nmcli connection modify "Name" ipv4.dns "1.1.1.1"

# Debugging
journalctl -u NetworkManager -f
systemctl status NetworkManager
nmcli -f CONNECTIVITY general
resolvectl status

# Conflicts
systemctl status iwd wpa_supplicant
nmcli device status   # look for "unmanaged"
```

---

The mental model to keep: **NM is the single source of truth for your network state.** Every tool you use — `ip`, `resolvectl`, `ping` — is reading consequences of what NM decided. Debug by climbing the ladder from physical layer up, and configure by modifying profiles rather than touching system files directly. That's the discipline that makes NM-managed systems reliable and recoverable.