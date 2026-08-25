## Bandwidth Management


### Overview

Bandwidth management in pacman allows you to control download speeds, prioritize network usage, and prevent package operations from consuming all available bandwidth. This is particularly useful on shared networks, metered connections, or when running background updates.

### XferCommand for Bandwidth Control

Since pacman doesn't have built-in bandwidth limiting, you must use external download managers through the `XferCommand` directive in `/etc/pacman.conf`.

### Using Curl with Rate Limiting

#### Basic Rate Limiting

Edit `/etc/pacman.conf`:

```
sudo nano /etc/pacman.conf
```

Add to the `[options]` section:

```
[options]
XferCommand = /usr/bin/curl --limit-rate 500K -C - -f -o %o %u
```

**`--limit-rate 500K`:** Limits download speed to 500 KB/sec

**Common rate specifications:**
- `100K` - 100 kilobytes per second
- `1M` - 1 megabyte per second
- `2M` - 2 megabytes per second
- `10M` - 10 megabytes per second

**Note:** Use capital K/M for kilobytes/megabytes; lowercase k/m for kilobits/megabits.

#### Dynamic Rate Limiting

**Percentage-based limiting (requires calculation):**

For a 10 Mbps connection, limit to 50% (5 Mbps = ~625 KB/sec):
```
XferCommand = /usr/bin/curl --limit-rate 625K -C - -f -o %o %u
```

For a 100 Mbps connection, limit to 30% (~3.75 MB/sec):
```
XferCommand = /usr/bin/curl --limit-rate 3750K -C - -f -o %o %u
```

#### Time-Based Rate Limiting

Combine with cron or systemd timers for time-aware bandwidth management:

**Day configuration (generous):**
```
# /etc/pacman.d/pacman-day.conf
XferCommand = /usr/bin/curl --limit-rate 5M -C - -f -o %o %u
```

**Night configuration (unlimited):**
```
# /etc/pacman.d/pacman-night.conf
XferCommand = /usr/bin/curl -C - -f -o %o %u
```

Switch configurations based on time using scripts or systemd services.

### Using Wget with Rate Limiting

#### Basic Wget Configuration

```
XferCommand = /usr/bin/wget --limit-rate=500K --passive-ftp -c -O %o %u
```

**`--limit-rate=500K`:** Limits to 500 KB/sec

**Benefits of wget:**
- Simpler syntax for some users
- Well-established tool
- Good retry mechanisms

#### Advanced Wget Options

```
XferCommand = /usr/bin/wget --limit-rate=1M --timeout=60 --tries=3 --passive-ftp -c -O %o %u
```

**Combined features:**
- Rate limiting
- Timeout control
- Automatic retries

### Using Aria2c for Advanced Bandwidth Management

Aria2c provides sophisticated bandwidth control and parallel downloads:

#### Basic Aria2c Configuration

```
XferCommand = /usr/bin/aria2c --max-download-limit=500K --allow-overwrite=true --continue=true --file-allocation=none --log-level=error --max-tries=2 --max-connection-per-server=2 --min-split-size=5M --no-conf --remote-time=true --summary-interval=0 --timeout=60 --dir=/ --out=%o %u
```

**`--max-download-limit=500K`:** Global download speed limit

#### Per-File Bandwidth Limits

```
XferCommand = /usr/bin/aria2c --max-download-limit=1M --max-connection-per-server=1 --allow-overwrite=true --continue=true --dir=/ --out=%o %u
```

Limits each file to 1 MB/sec with single connection per server.

#### Schedule-Based Bandwidth

**Create time-aware script:**

```bash
#!/bin/bash
# /usr/local/bin/pacman-aria2c-adaptive

HOUR=$(date +%H)

if [ $HOUR -ge 8 ] && [ $HOUR -lt 18 ]; then
    # Daytime: 500 KB/sec limit
    LIMIT="500K"
else
    # Nighttime: 5 MB/sec limit
    LIMIT="5M"
fi

/usr/bin/aria2c --max-download-limit=$LIMIT --allow-overwrite=true --continue=true --dir=/ --out=$2 $3
```

**Make executable:**
```
sudo chmod +x /usr/local/bin/pacman-aria2c-adaptive
```

**Configure in pacman.conf:**
```
XferCommand = /usr/local/bin/pacman-aria2c-adaptive %o %u
```

### System-Wide Bandwidth Management

#### Using tc (Traffic Control)

For system-wide bandwidth shaping affecting all applications:

**Limit outbound bandwidth to 1 Mbps:**
```
sudo tc qdisc add dev eth0 root tbf rate 1mbit burst 32kbit latency 400ms
```

**Remove limit:**
```
sudo tc qdisc del dev eth0 root
```

**Note:** Replace `eth0` with your network interface (find with `ip addr`).

#### Using wondershaper

Wondershaper provides simplified bandwidth management:

**Install:**
```
sudo pacman -S wondershaper
```

**Limit interface to 1 Mbps download, 512 Kbps upload:**
```
sudo wondershaper eth0 1024 512
```

**Remove limits:**
```
sudo wondershaper clear eth0
```

**Make persistent:**
```
sudo systemctl enable wondershaper@eth0
```

### QoS and Traffic Prioritization

#### Prioritize Interactive Traffic

Use tc to deprioritize bulk downloads while maintaining responsiveness:

```bash
#!/bin/bash
# Simple QoS script
INTERFACE="eth0"

# Create root qdisc
tc qdisc add dev $INTERFACE root handle 1: htb default 12

# Create main class (10 Mbps)
tc class add dev $INTERFACE parent 1: classid 1:1 htb rate 10mbit

# High priority (interactive)
tc class add dev $INTERFACE parent 1:1 classid 1:10 htb rate 5mbit ceil 10mbit prio 1
# Low priority (bulk downloads)
tc class add dev $INTERFACE parent 1:1 classid 1:12 htb rate 3mbit ceil 8mbit prio 2

# Filter pacman traffic to low priority
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 u32 match ip sport 80 0xffff flowid 1:12
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 u32 match ip sport 443 0xffff flowid 1:12
```

This prioritizes interactive traffic over bulk downloads.

### Metered Connection Handling

#### Download-Only Mode

For metered connections, download packages without installing:

```
sudo pacman -Syuw
```

**Benefits:**
- Download during off-peak/unlimited hours
- Install later without bandwidth usage
- Review package sizes before downloading

#### Manual Package Selection

Download specific packages only:

```
sudo pacman -Sw package1 package2 package3
```

Install later:
```
sudo pacman -S package1 package2 package3
```

Packages install from cache without redownloading.

### Monitoring Bandwidth Usage

#### Real-Time Network Monitoring

**Using iftop:**
```
sudo pacman -S iftop
sudo iftop -i eth0
```

Shows real-time bandwidth usage per connection.

**Using nethogs:**
```
sudo pacman -S nethogs
sudo nethogs eth0
```

Shows bandwidth usage per process (including pacman).

**Using bmon:**
```
sudo pacman -S bmon
bmon
```

Graphical bandwidth monitor in terminal.

#### Check Download Progress

Pacman shows download progress with size information:

```
downloading package-1.0-1-x86_64.pkg.tar.zst...
(5/100) package-1.0-1-x86_64.pkg.tar.zst    15.2 MiB  2.45 MiB/s 00:06 [######################] 100%
```

Monitor to ensure rate limiting is working.

### Practical Bandwidth Scenarios

#### Scenario 1: Shared Home Network

Limit pacman to avoid impacting other users:

```
XferCommand = /usr/bin/curl --limit-rate 1M -C - -f -o %o %u
```

Leaves bandwidth for browsing, streaming, and gaming.

#### Scenario 2: Metered Mobile Connection

Strict bandwidth control to minimize data usage:

```
XferCommand = /usr/bin/curl --limit-rate 100K -C - -f -o %o %u
```

Very conservative for expensive mobile data.

#### Scenario 3: Daytime Office Network

Be courteous during business hours:

**Create time-based wrapper:**
```bash
#!/bin/bash
# /usr/local/bin/pacman-office-hours

HOUR=$(date +%H)
WEEKDAY=$(date +%u)  # 1-7 (Monday-Sunday)

if [ $WEEKDAY -le 5 ] && [ $HOUR -ge 9 ] && [ $HOUR -lt 17 ]; then
    # Office hours: 200 KB/sec
    RATE="200K"
else
    # After hours: 5 MB/sec
    RATE="5M"
fi

/usr/bin/curl --limit-rate $RATE -C - -f -o $1 $2
```

**Configure:**
```
XferCommand = /usr/local/bin/pacman-office-hours %o %u
```

#### Scenario 4: Server Background Updates

Minimal bandwidth for server updates during business hours:

```
XferCommand = /usr/bin/curl --limit-rate 50K -C - -f -o %o %u
```

Run updates during maintenance windows with higher limits.

#### Scenario 5: Unlimited Night Bandwidth

**Create scheduled configuration:**

```bash
#!/bin/bash
# /usr/local/bin/update-pacman-config

HOUR=$(date +%H)

if [ $HOUR -ge 1 ] && [ $HOUR -lt 7 ]; then
    # Night: unlimited
    cat > /etc/pacman.conf.d/50-xfercommand.conf << 'EOF'
[options]
XferCommand = /usr/bin/curl -C - -f -o %o %u
EOF
else
    # Day: limited
    cat > /etc/pacman.conf.d/50-xfercommand.conf << 'EOF'
[options]
XferCommand = /usr/bin/curl --limit-rate 500K -C - -f -o %o %u
EOF
fi
```

**Schedule with systemd timer to run before updates.**

### Testing Bandwidth Limits

#### Verify Rate Limiting Works

**Monitor with nethogs during pacman operation:**

Terminal 1:
```
sudo nethogs eth0
```

Terminal 2:
```
sudo pacman -Syu
```

Observe pacman's bandwidth usage matches your limit.

#### Measure Actual Download Speed

**Time a known package download:**
```
time sudo pacman -Sw firefox
```

Calculate speed from package size and time taken.

### Best Practices

**Set realistic limits:** Don't set limits so low that updates become impractical.

**Consider parallel downloads:** If using `ParallelDownloads`, remember the rate limit applies per connection, not globally.

**Monitor and adjust:** Test bandwidth limits and adjust based on actual network impact.

**Document settings:** Comment your XferCommand explaining the rate limit choice.

**Be network-friendly:** On shared networks, limit bandwidth during peak hours.

**Use adaptive limits:** Implement time-based limits if your usage patterns vary.

**Balance speed and courtesy:** Find a balance between update speed and network impact.

**Test before committing:** Verify bandwidth limits work as expected before relying on them.

**Consider caching:** For multiple systems, use a local mirror to reduce external bandwidth.

**Plan large updates:** Schedule major system upgrades during off-peak or unlimited periods.

Effective bandwidth management ensures package operations don't negatively impact other network activities while still maintaining reasonable update times.


