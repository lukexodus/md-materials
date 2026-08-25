## Download Timeout Configuration


### Overview

Pacman's download timeout settings control how long the package manager waits for network operations before considering a download failed. Proper timeout configuration ensures reliable package downloads while avoiding unnecessary delays from unresponsive mirrors.

### Timeout Configuration Location

Timeout settings are not directly configurable in `/etc/pacman.conf`. Instead, pacman relies on the underlying download library (libalpm) and curl for timeout behavior. However, there are several ways to influence and control timeout behavior.

### Default Timeout Behavior

#### Built-in Timeouts

Pacman uses curl internally for downloads, which has default timeout values:

**Connection timeout:** Time to establish connection (default: ~300 seconds)
**Low speed limit:** Minimum acceptable speed (default: 1000 bytes/sec)
**Low speed time:** Duration below minimum speed before aborting (default: 10 seconds)

If download speed drops below 1000 bytes/sec for 10 seconds, the download fails and moves to the next mirror.

### Command-Line Timeout Control

#### Disable Download Timeout

For problematic connections or slow mirrors, disable timeout checking:

```
sudo pacman -Syu --disable-download-timeout
```

This removes download timeout restrictions, allowing very slow downloads to complete. Useful for:
- Very slow internet connections
- High-latency connections (satellite, international)
- Unreliable connections with frequent interruptions
- Large packages on limited bandwidth

**Warning:** This may cause pacman to hang indefinitely on completely stalled downloads.

#### Temporary Override

Use for one-time operations:

```
sudo pacman -S package-name --disable-download-timeout
```

### XferCommand Configuration

#### Custom Download Manager

The `XferCommand` option in `/etc/pacman.conf` allows using external download managers with custom timeout settings:

```
sudo nano /etc/pacman.conf
```

Add or modify in the `[options]` section:

**Using curl with custom timeouts:**
```
[options]
XferCommand = /usr/bin/curl --connect-timeout 60 --max-time 0 -C - -f -o %o %u
```

**Options explained:**
- `--connect-timeout 60` - Maximum 60 seconds to establish connection
- `--max-time 0` - No maximum time limit for total download (0 = unlimited)
- `-C -` - Continue partial downloads
- `-f` - Fail silently on server errors
- `-o %o` - Output to file (%o is pacman's output path variable)
- `%u` - URL to download (%u is pacman's URL variable)

**More conservative timeouts:**
```
XferCommand = /usr/bin/curl --connect-timeout 30 --speed-limit 1000 --speed-time 30 -C - -f -o %o %u
```

**Options:**
- `--connect-timeout 30` - 30 seconds to connect
- `--speed-limit 1000` - Minimum 1000 bytes/sec
- `--speed-time 30` - Fail if below speed limit for 30 seconds

**Using wget:**
```
XferCommand = /usr/bin/wget --timeout=60 --passive-ftp -c -O %o %u
```

**Options:**
- `--timeout=60` - 60-second timeout for all operations
- `--passive-ftp` - Use passive FTP mode
- `-c` - Continue partial downloads
- `-O %o` - Output file

**Using aria2c (parallel downloader):**
```
XferCommand = /usr/bin/aria2c --allow-overwrite=true --continue=true --file-allocation=none --log-level=error --max-tries=2 --max-connection-per-server=2 --max-file-not-found=5 --min-split-size=5M --no-conf --remote-time=true --summary-interval=60 --timeout=60 --dir=/ --out=%o %u
```

This provides advanced download features including better timeout handling.

### Environment Variables

#### Curl Configuration File

Create a custom curl configuration for pacman:

```
sudo nano /etc/pacman.d/curl.conf
```

**Example configuration:**
```
connect-timeout = 60
max-time = 0
speed-limit = 1000
speed-time = 30
retry = 3
retry-delay = 5
```

**Use in XferCommand:**
```
XferCommand = /usr/bin/curl -K /etc/pacman.d/curl.conf -C - -f -o %o %u
```

The `-K` flag loads the configuration file.

### Network-Specific Timeout Strategies

#### Fast, Reliable Connection

For fast, stable connections, use aggressive timeouts to quickly skip bad mirrors:

```
XferCommand = /usr/bin/curl --connect-timeout 10 --speed-limit 5000 --speed-time 10 -C - -f -o %o %u
```

**Benefits:**
- Quickly fails on unresponsive mirrors
- Moves to next mirror rapidly
- Higher speed requirements ensure quality downloads

#### Slow or Unreliable Connection

For slow or unstable connections, use lenient timeouts:

```
XferCommand = /usr/bin/curl --connect-timeout 120 --speed-limit 500 --speed-time 60 -C - -f -o %o %u
```

Or disable timeouts entirely:
```
sudo pacman -Syu --disable-download-timeout
```

**Benefits:**
- Tolerates slower speeds
- Waits longer for mirror response
- Completes downloads on marginal connections

#### Satellite or High-Latency Connection

For high-latency connections (satellite, international):

```
XferCommand = /usr/bin/curl --connect-timeout 300 --speed-limit 100 --speed-time 120 -C - -f -o %o %u
```

**Characteristics:**
- Very long connection timeout (300 seconds)
- Very low minimum speed (100 bytes/sec)
- Extended grace period (120 seconds)

### Retry Configuration

#### Curl Retry Options

Configure automatic retries for failed downloads:

```
XferCommand = /usr/bin/curl --retry 5 --retry-delay 3 --retry-max-time 120 --connect-timeout 60 -C - -f -o %o %u
```

**Options:**
- `--retry 5` - Retry up to 5 times on transient errors
- `--retry-delay 3` - Wait 3 seconds between retries
- `--retry-max-time 120` - Maximum 120 seconds total retry time
- `--connect-timeout 60` - 60 seconds per connection attempt

#### Mirror Fallback

Pacman automatically tries the next mirror when a download fails. Ensure multiple mirrors are configured in `/etc/pacman.d/mirrorlist` for effective fallback:

```
Server = https://mirror1.example.com/archlinux/$repo/os/$arch
Server = https://mirror2.example.com/archlinux/$repo/os/$arch
Server = https://mirror3.example.com/archlinux/$repo/os/$arch
```

### Troubleshooting Timeout Issues

#### Frequent Timeout Errors

**Symptoms:**
```
error: failed retrieving file 'package.pkg.tar.zst' from mirror.example.com : Operation timed out after 10000 milliseconds
```

**Solutions:**

**1. Disable timeout temporarily:**
```
sudo pacman -Syu --disable-download-timeout
```

**2. Update mirrorlist to faster mirrors:**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**3. Increase timeout values in XferCommand:**
```
XferCommand = /usr/bin/curl --connect-timeout 120 -C - -f -o %o %u
```

**4. Check internet connection:**
```
ping -c 4 archlinux.org
```

#### Stalled Downloads

**Symptoms:**
- Downloads start but never complete
- Progress bar stops moving
- No error messages

**Solutions:**

**1. Use speed-based timeout:**
```
XferCommand = /usr/bin/curl --speed-limit 1000 --speed-time 30 -C - -f -o %o %u
```

**2. Enable retry with timeout:**
```
XferCommand = /usr/bin/curl --retry 3 --retry-delay 5 --max-time 600 -C - -f -o %o %u
```

**3. Switch to different mirrors:**
```
sudo reflector --country 'YourCountry' --latest 10 --save /etc/pacman.d/mirrorlist
```

#### Connection Refused or Immediate Failures

**Symptoms:**
- Instant failures without attempting download
- "Connection refused" errors

**Solutions:**

**1. Check mirror availability:**
```
curl -I https://mirror.example.com/archlinux/core/os/x86_64/core.db
```

**2. Switch protocols (HTTPS vs HTTP):**
```
sudo reflector --protocol http --latest 20 --save /etc/pacman.d/mirrorlist
```

**3. Verify firewall settings:**
```
sudo iptables -L
```

Ensure outbound HTTPS/HTTP traffic is allowed.

### Best Practices

**Match timeouts to connection:** Configure timeouts appropriate for your internet speed and reliability.

**Use multiple mirrors:** Keep 10-20 mirrors active for automatic fallback.

**Enable retries:** Configure automatic retries to handle transient network issues.

**Speed-based timeouts:** Prefer `--speed-limit` over `--max-time` to catch stalled downloads.

**Conservative connection timeout:** Use reasonable connection timeouts (30-60 seconds) to detect dead mirrors.

**Test configuration changes:** Verify timeout settings work with test downloads.

**Document custom settings:** Comment your XferCommand configuration explaining choices.

**Monitor download performance:** Adjust timeouts based on actual download behavior.

**Balance patience and responsiveness:** Too short = premature failures; too long = wasted time on bad mirrors.

**Keep fallback options:** Don't disable all timeouts; always have a maximum limit.

### Example Configurations for Common Scenarios

#### Home Broadband (50+ Mbps)

```
XferCommand = /usr/bin/curl --connect-timeout 30 --speed-limit 5000 --speed-time 15 --retry 3 -C - -f -o %o %u
```

#### Mobile/Cellular Connection

```
XferCommand = /usr/bin/curl --connect-timeout 60 --speed-limit 1000 --speed-time 30 --retry 5 --retry-delay 10 -C - -f -o %o %u
```

#### University/Corporate Network

```
XferCommand = /usr/bin/curl --connect-timeout 20 --speed-limit 10000 --speed-time 10 --retry 2 -C - -f -o %o %u
```

#### Satellite/High-Latency

```
XferCommand = /usr/bin/curl --connect-timeout 300 --speed-limit 500 --speed-time 60 --retry 10 -C - -f -o %o %u
```

#### Unreliable/Flaky Connection

```
XferCommand = /usr/bin/curl --connect-timeout 120 --speed-limit 500 --speed-time 45 --retry 10 --retry-delay 15 --retry-max-time 300 -C - -f -o %o %u
```

Proper timeout configuration ensures reliable package downloads while minimizing time wasted on unresponsive mirrors or stalled connections.

