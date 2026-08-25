## Boot Optimization (systemd-analyze, journal trimming)


### Boot Performance Overview

**Importance**: Fast boot improves user experience.[1]

**Measurement**: Tools quantify boot time.[1]

**Optimization**: Identify bottlenecks and eliminate.[1]

**Trade-offs**: Balance speed with functionality.[1]

### systemd-analyze

#### Overview

**Purpose**: Analyzes systemd boot performance.[1]

**Installation**: Included with systemd (pre-installed).[1]

**Output**: Shows boot time breakdown.[1]

#### Basic Analysis

**Total Boot Time**:[1]

```bash
systemd-analyze
```

**Output Example**:[1]

```
Startup finished in 2.156s (kernel) + 3.421s (userspace) = 5.577s
graphical.target reached after 3.421s in userspace
```

**Detailed Timing**:[1]

```bash
systemd-analyze time
```

#### Service Dependencies

**Boot Sequence**:[1]

```bash
systemd-analyze plot > boot.svg
```

Creates visual timeline of service startup.[1]

**View Diagram**: Open `boot.svg` in browser.[1]

**Critical Path**: Shows longest dependency chain.[1]

#### Slow Services

**List Slow Services**:[1]

```bash
systemd-analyze blame
```

**Output Example**:[1]

```
          2.341s nginx.service
          1.987s mysql.service
          1.654s sshd.service
```

**Sorted by Time**: Slowest services listed first.[1]

#### Unit Dependencies

**Service Dependencies**:[1]

```bash
systemd-analyze critical-chain
```

**Shows**: Chain of services blocking startup.[1]

**Example**:[1]

```
graphical.target @3.421s
└─multi-user.target @3.421s
  └─nginx.service @1.080s +2.341s
    └─network.target @1.020s
```

### Identifying Bottlenecks

#### Slow Kernel Boot

**Kernel Time**: First number from `systemd-analyze`.[1]

**Typical**: 1-2 seconds.[1]

**Excessive**: > 3 seconds indicates issue.[1]

**Debug**:[1]

```bash
dmesg | tail -50
```

**Check for Errors**: Look for failed initialization.[1]

#### Slow Userspace

**Userspace Time**: Second number.[1]

**Identify Culprits**:[1]

```bash
systemd-analyze blame | head -10
```

**Investigate Top Services**:[1]

```bash
systemctl status slow-service
journalctl -u slow-service -n 50
```

#### Filesystem Issues

**Disk I/O**: Major boot slowdown cause.[1]

**Check Load**:[1]

```bash
iostat
iotop
```

**fstab Issues**: Misconfigured mounts:[1]

```bash
systemctl status local-fs.target
```

### Service Optimization

#### Disable Unnecessary Services

**List Services**:[1]

```bash
systemctl list-unit-files --type=service
```

**Check Running**:[1]

```bash
systemctl list-units --type=service --all
```

**Disable Service**:[1]

```bash
sudo systemctl disable service-name
```

**Impact**: Faster boot if service not needed.[1]

#### Parallel Startup

**Already Parallel**: systemd starts services in parallel by default.[1]

**Verify**: Check `systemd-analyze plot` for overlapping bars.[1]

**Sequential Dependency**: Services starting sequentially indicate dependency chain.[1]

#### Type Selection

**Type=simple**: Service starts immediately.[1]

**Type=forking**: Service forks to background.[1]

**Type=oneshot**: Runs once, doesn't persist.[1]

**Type=notify**: Service signals when ready.[1]

**Efficient**: Use `Type=notify` for slow services.[1]

### Unit File Optimization

#### Dependencies

**After Directive**:[1]

```ini
After=network.target
```

Delays start until network available, may slow boot.[1]

**Wants Directive**:[1]

```ini
Wants=optional-service
```

Flexible dependency, doesn't delay if missing.[1]

**Requires Directive**:[1]

```ini
Requires=critical-service
```

Hard dependency, fails if unavailable.[1]

#### Socket Activation

**Purpose**: Delay service start until first connection.[1]

**Systemd Socket Unit**: `/etc/systemd/system/service.socket`:[1]

```ini
[Unit]
Description=Service Socket

[Socket]
ListenStream=8080

[Install]
WantedBy=sockets.target
```

**Service**: Modified to wait for socket activation:[1]

```ini
[Unit]
Requires=service.socket

[Service]
Type=notify
ExecStart=/usr/bin/service
```

**Benefit**: Service not started until needed.[1]

### Journal Management

#### Journal Location

**Persistent**: `/var/log/journal/` .

**Volatile**: `/run/log/journal/` .

**Configuration**: `/etc/systemd/journald.conf` .

#### Enable Persistent Storage

**Create Directory** :

```bash
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald
```

**Verify** :

```bash
sudo journalctl --list-boots
```

#### Journal Size Management

**Check Disk Usage** :

```bash
journalctl --disk-usage
```

**Output Example** :

```
Archived and active journals take up 412.0M on disk.
```

**Current Size Limit** :

```
cat /etc/systemd/journald.conf | grep SystemMax
```

### Journal Trimming

#### Manual Trimming

**Vacuum by Size** :

```bash
sudo journalctl --vacuum-size=500M
```

Reduces journal to 500MB .

**Vacuum by Time** :

```bash
sudo journalctl --vacuum-time=30d
```

Removes logs older than 30 days .

**Vacuum to N Files** :

```bash
sudo journalctl --vacuum-files=5
```

Keeps only 5 journal files .

#### Automatic Trimming

**Configuration**: `/etc/systemd/journald.conf` :

```ini
[Journal]
Storage=persistent
SystemMaxUse=500M
SystemMaxFileSize=100M
SystemMaxFiles=10
RuntimeMaxUse=100M
RuntimeMaxFileSize=25M
RuntimeMaxFiles=5
```

**Parameters** :
- `SystemMaxUse`: Total disk usage limit 
- `SystemMaxFileSize`: Single file size limit 
- `SystemMaxFiles`: Maximum number of files 

**Reload**: `sudo systemctl restart systemd-journald` .

#### Scheduled Cleanup

**Systemd Timer**: `/etc/systemd/system/journal-vacuum.service` :

```ini
[Unit]
Description=Vacuum Journal

[Service]
Type=oneshot
ExecStart=/usr/bin/journalctl --vacuum-time=30d
```

**Timer**: `/etc/systemd/system/journal-vacuum.timer` :

```ini
[Unit]
Description=Daily Journal Vacuum

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

**Enable** :

```bash
sudo systemctl enable --now journal-vacuum.timer
```

### Boot Parameter Optimization

#### Kernel Parameters

**Current Parameters**:[1]

```bash
cat /proc/cmdline
```

**Modify** (systemd-boot): Edit boot entry in `/boot/loader/entries/`.[1]

**Optimization Parameters**:[1]
- `quiet`: Suppress boot messages[1]
- `loglevel=3`: Reduce log verbosity[1]
- `nomodeset`: Disable graphics during boot[1]

#### Plymouth Boot Splash

**Purpose**: Faster perceived boot time.[1]

**Installation**: `sudo pacman -S plymouth`.[1]

**Enable**: Modify boot parameters:[1]

```
options root=... quiet splash
```

### Monitoring Boot Performance

#### Continuous Monitoring

**Regular Analysis**:[1]

```bash
systemd-analyze blame > boot_times.txt
date >> boot_times.txt
```

**Track Changes**: Compare over time.[1]

#### After Optimization

**Before/After Comparison**:[1]

1. Record initial boot time[1]
2. Apply optimization[1]
3. Reboot and measure new time[1]
4. Calculate improvement[1]

### Common Optimization Opportunities

#### Network Timeout

**Issue**: Waiting for network that won't come up.[1]

**Solution**: Change dependency:[1]

```ini
After=network-online.target
Wants=network-online.target
```

to

```ini
After=network.target
```

#### Timeout Services

**Check for Timeouts**:[1]

```bash
journalctl | grep -i timeout
```

**Reduce Timeout**: Service unit file:[1]

```ini
[Service]
TimeoutStartSec=10  # Instead of default 90s
```

#### RAID Assembly

**Issue**: Long delays assembling RAID.[1]

**Solution**: Use `mdadm` instead of kernel raid:[1]

```bash
echo "DEVICE partitions" | sudo tee /etc/mdadm.conf
sudo mdadm --assemble --scan --force
```

#### Unused Filesystems

**Issue**: Checking/mounting unused filesystems.[1]

**Check fstab**:[1]

```bash
cat /etc/fstab
```

**Comment Unused**: Reduce startup checks.[1]

### Optimization Best Practices

**Measure First**: Use systemd-analyze to identify issues.[1]

**One Change at a Time**: Modify one thing, measure impact.[1]

**Test Changes**: Reboot and verify improvements.[1]

**Document**: Record optimizations applied.[1]

**Balance**: Don't sacrifice functionality for speed.[1]

**Monitor Regularly**: Recheck after updates.[1]

### Performance Targets

**Excellent**: < 3 seconds.[1]

**Good**: 3-5 seconds.[1]

**Acceptable**: 5-10 seconds.[1]

**Poor**: > 10 seconds.[1]

Depends on hardware and services.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman

