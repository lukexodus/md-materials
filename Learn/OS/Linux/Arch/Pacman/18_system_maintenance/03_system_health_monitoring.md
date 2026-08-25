## System Health Monitoring


### Overview

System health monitoring on Arch Linux involves tracking system resources, performance metrics, service status, and potential issues. Proactive monitoring prevents problems before they cause system failures or degraded performance.

### Quick Health Checks

#### Essential Status Commands

**Failed services:**
```
systemctl --failed
```

Should show "0 loaded units listed" on healthy system.

**System load:**
```
uptime
```

Shows load average for 1, 5, and 15 minutes.

**Disk space:**
```
df -h
```

Monitor for partitions over 80% usage.

**Memory usage:**
```
free -h
```

Check available memory and swap usage.

**Top processes:**
```
top
```

Or interactive:
```
htop
```

**Recent errors:**
```
journalctl -p err -b --no-pager | tail -20
```

### Resource Monitoring

#### CPU Monitoring

**Current CPU usage:**
```
top -bn1 | grep "Cpu(s)"
```

**CPU info:**
```
lscpu
cat /proc/cpuinfo
```

**Per-core usage:**
```
mpstat -P ALL
```

Requires `sysstat` package.

**Historical CPU stats:**
```
sar -u 5 12
```

Shows CPU usage every 5 seconds, 12 times.

**CPU temperature:**
```
sensors
```

Requires `lm_sensors` package.

**Setup sensors:**
```
sudo pacman -S lm_sensors
sudo sensors-detect
sensors
```

**Monitor temperature continuously:**
```
watch -n 2 sensors
```

#### Memory Monitoring

**Detailed memory stats:**
```
free -h
```

**Example output:**
```
              total        used        free      shared  buff/cache   available
Mem:           15Gi       5.2Gi       7.8Gi       432Mi       2.8Gi        9.8Gi
Swap:         8.0Gi          0B       8.0Gi
```

**Memory by process:**
```
ps aux --sort=-%mem | head -20
```

Shows top 20 memory-consuming processes.

**Memory details:**
```
cat /proc/meminfo
```

**OOM (Out of Memory) killer logs:**
```
journalctl -b | grep -i "out of memory\|oom"
```

**Swap usage:**
```
swapon --show
```

**Memory pressure:**
```
cat /proc/pressure/memory
```

#### Disk Monitoring

**Disk space usage:**
```
df -h
```

**Disk usage by directory:**
```
du -sh /* 2>/dev/null | sort -h
```

**Largest directories:**
```
sudo du -h / --max-depth=1 2>/dev/null | sort -rh | head -20
```

**Specific partition usage:**
```
du -sh /var/* | sort -h
```

**Find large files:**
```
sudo find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

**Disk I/O stats:**
```
iostat -x 2
```

Requires `sysstat` package; updates every 2 seconds.

**Monitor I/O per process:**
```
sudo iotop
```

Requires `iotop` package.

**SMART disk health:**
```
sudo smartctl -H /dev/sda
```

Requires `smartmontools` package.

**Detailed SMART **
```
sudo smartctl -a /dev/sda
```

#### Network Monitoring

**Network interfaces:**
```
ip addr
```

**Network statistics:**
```
ip -s link
```

**Active connections:**
```
ss -tuln
```

Shows TCP/UDP listening ports.

**Established connections:**
```
ss -tun
```

**Bandwidth usage:**
```
sudo iftop -i eth0
```

Requires `iftop` package.

**Network statistics over time:**
```
sar -n DEV 2 10
```

**Traffic by process:**
```
sudo nethogs
```

Requires `nethogs` package.

**Real-time bandwidth monitor:**
```
bmon
```

Requires `bmon` package.

### Service Health Monitoring

#### Systemd Service Status

**All running services:**
```
systemctl list-units --type=service --state=running
```

**Failed services:**
```
systemctl --failed
```

**Service dependency tree:**
```
systemctl list-dependencies service-name.service
```

**Service resource usage:**
```
systemd-cgtop
```

Shows CPU, memory, I/O per service.

**Specific service status:**
```
systemctl status service-name.service
```

**Service logs:**
```
journalctl -u service-name.service -b
```

#### Critical Services Check

**Essential services:**
```bash
#!/bin/bash
# Check critical services

SERVICES=(
    "sshd.service"
    "NetworkManager.service"
    "systemd-resolved.service"
    "cronie.service"
)

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "✓ $service: Running"
    else
        echo "✗ $service: FAILED"
    fi
done
```

### Log Monitoring

#### Real-Time Log Monitoring

**Follow all logs:**
```
journalctl -f
```

**Follow errors only:**
```
journalctl -f -p err
```

**Follow specific service:**
```
journalctl -u service-name.service -f
```

**Kernel messages:**
```
journalctl -kf
```

**Multiple services:**
```
journalctl -u sshd.service -u NetworkManager.service -f
```

#### Error Detection

**Recent errors:**
```
journalctl -p err --since "1 hour ago" --no-pager
```

**Critical messages:**
```
journalctl -p crit -b
```

**Segmentation faults:**
```
journalctl -b | grep segfault
```

**Core dumps:**
```
coredumpctl list
coredumpctl info
```

### Package System Health

#### Pacman Database Integrity

**Check database:**
```
sudo pacman -Dk
```

**Verify installed files:**
```
pacman -Qkk | grep -v "0 altered files"
```

Shows packages with modified files.

**Check for broken dependencies:**
```
pacman -Dk
```

**Orphaned packages:**
```
pacman -Qtdq
```

**Foreign packages (AUR):**
```
pacman -Qm
```

#### Comprehensive Package Check

```bash
#!/bin/bash
# Package system health check

echo "=== Package System Health ==="

# Database integrity
echo "Database integrity:"
sudo pacman -Dk

# Broken packages
echo -e "\nPackages with file issues:"
pacman -Qkk 2>&1 | grep -v "0 altered files"

# Orphans
ORPHANS=$(pacman -Qtdq | wc -l)
echo -e "\nOrphaned packages: $ORPHANS"

# Failed upgrades
echo -e "\nRecent errors:"
grep "error:" /var/log/pacman.log | tail -5

# Cache size
CACHE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
echo -e "\nCache size: $CACHE"
```

### Automated Monitoring Scripts

#### Daily Health Check Script

```bash
#!/bin/bash
# Daily system health check

REPORT="/tmp/health-$(date +%Y%m%d).txt"

echo "=== System Health Report ===" > "$REPORT"
echo "Date: $(date)" >> "$REPORT"
echo "" >> "$REPORT"

# System load
echo "System Load:" >> "$REPORT"
uptime >> "$REPORT"
echo "" >> "$REPORT"

# Disk space
echo "Disk Space:" >> "$REPORT"
df -h / /home >> "$REPORT"
echo "" >> "$REPORT"

# Memory
echo "Memory Usage:" >> "$REPORT"
free -h >> "$REPORT"
echo "" >> "$REPORT"

# Failed services
echo "Failed Services:" >> "$REPORT"
systemctl --failed --no-pager >> "$REPORT"
echo "" >> "$REPORT"

# Recent errors
echo "Recent Errors (last 24 hours):" >> "$REPORT"
journalctl --since "24 hours ago" -p err --no-pager | tail -20 >> "$REPORT"
echo "" >> "$REPORT"

# Orphaned packages
ORPHANS=$(pacman -Qtdq | wc -l)
echo "Orphaned packages: $ORPHANS" >> "$REPORT"
echo "" >> "$REPORT"

# Display report
cat "$REPORT"

# Alert if issues found
ISSUES=$(grep -c "FAILED\|error:" "$REPORT")
if [ $ISSUES -gt 0 ]; then
    notify-send "System Health Alert" "$ISSUES issues detected"
fi
```

**Schedule with cron:**
```
0 9 * * * /usr/local/bin/daily-health-check
```

#### Resource Alert Script

```bash
#!/bin/bash
# Alert on resource thresholds

# CPU threshold (80%)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if (( $(echo "$CPU > 80" | bc -l) )); then
    echo "WARNING: CPU usage at ${CPU}%"
fi

# Disk threshold (80%)
DISK=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK -gt 80 ]; then
    echo "WARNING: Root partition ${DISK}% full"
fi

# Memory threshold (90%)
MEM_PERCENT=$(free | grep Mem | awk '{print ($3/$2) * 100}')
if (( $(echo "$MEM_PERCENT > 90" | bc -l) )); then
    echo "WARNING: Memory usage at ${MEM_PERCENT}%"
fi

# Failed services
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -gt 0 ]; then
    echo "WARNING: $FAILED failed services detected"
fi
```

### GUI Monitoring Tools

#### System Monitors

**GNOME System Monitor:**
```
sudo pacman -S gnome-system-monitor
gnome-system-monitor
```

**KDE System Monitor:**
```
sudo pacman -S plasma-systemmonitor
plasma-systemmonitor
```

**htop (terminal-based):**
```
sudo pacman -S htop
htop
```

**btop (modern terminal monitor):**
```
sudo pacman -S btop
btop
```

**glances (comprehensive):**
```
sudo pacman -S glances
glances
```

#### Resource Graphs

**Conky (customizable display):**
```
sudo pacman -S conky
conky
```

**Netdata (web-based):**
```
sudo pacman -S netdata
sudo systemctl enable --now netdata
# Access at http://localhost:19999
```

### Hardware Health Monitoring

#### Temperature Monitoring

**Setup sensors:**
```
sudo pacman -S lm_sensors
sudo sensors-detect
```

Answer "yes" to all questions.

**View temperatures:**
```
sensors
```

**Monitor continuously:**
```
watch -n 2 sensors
```

**CPU temperature threshold alert:**
```bash
#!/bin/bash
# Check CPU temperature

TEMP=$(sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/+//;s/°C//')

if (( $(echo "$TEMP > 80" | bc -l) )); then
    echo "WARNING: CPU temperature at ${TEMP}°C"
    notify-send "Temperature Alert" "CPU at ${TEMP}°C"
fi
```

#### Disk Health

**Install smartmontools:**
```
sudo pacman -S smartmontools
```

**Enable monitoring:**
```
sudo systemctl enable --now smartd
```

**Check disk health:**
```
sudo smartctl -H /dev/sda
```

**Detailed SMART **
```
sudo smartctl -a /dev/sda
```

**Run self-test:**
```
sudo smartctl -t short /dev/sda
```

**View test results:**
```
sudo smartctl -l selftest /dev/sda
```

#### Battery Health (Laptops)

**Battery status:**
```
upower -i /org/freedesktop/UPower/devices/battery_BAT0
```

**Battery percentage:**
```
cat /sys/class/power_supply/BAT0/capacity
```

**Battery health:**
```
cat /sys/class/power_supply/BAT0/health
```

### Performance Metrics

#### System Performance Overview

**Install sysstat:**
```
sudo pacman -S sysstat
sudo systemctl enable --now sysstat
```

**CPU statistics:**
```
sar -u 2 5
```

**Memory statistics:**
```
sar -r 2 5
```

**I/O statistics:**
```
sar -b 2 5
```

**Network statistics:**
```
sar -n DEV 2 5
```

**Historical **
```
sar -f /var/log/sysstat/sa$(date +%d)
```

#### Benchmarking

**Disk speed test:**
```
sudo hdparm -Tt /dev/sda
```

**Disk write speed:**
```
dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync
```

**Memory bandwidth:**
```
sudo pacman -S sysbench
sysbench memory run
```

**CPU benchmark:**
```
sysbench cpu run
```

### Notification System

#### Desktop Notifications

**Using notify-send:**
```bash
#!/bin/bash
# Send desktop notification for issues

if systemctl is-failed --quiet some-service; then
    notify-send -u critical "Service Failed" "some-service has failed"
fi
```

**Email notifications:**
```bash
#!/bin/bash
# Email critical errors

ERRORS=$(journalctl --since "1 hour ago" -p err --no-pager)

if [ -n "$ERRORS" ]; then
    echo "$ERRORS" | mail -s "System Errors" admin@example.com
fi
```

### Monitoring Dashboard

#### Create Status Dashboard Script

```bash
#!/bin/bash
# System dashboard

clear

echo "╔════════════════════════════════════════════════════════╗"
echo "║          SYSTEM HEALTH DASHBOARD                       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Uptime and load
echo "▶ System Status"
uptime
echo ""

# Disk space
echo "▶ Disk Usage"
df -h / /home | tail -2
echo ""

# Memory
echo "▶ Memory"
free -h | grep -E "Mem:|Swap:"
echo ""

# CPU temp
echo "▶ CPU Temperature"
sensors | grep -E "Package id|Core"
echo ""

# Failed services
echo "▶ Service Status"
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -eq 0 ]; then
    echo "✓ All services running normally"
else
    echo "✗ $FAILED failed services:"
    systemctl --failed --no-legend
fi
echo ""

# Recent errors
echo "▶ Recent Errors"
ERROR_COUNT=$(journalctl -p err --since "1 hour ago" --no-pager | wc -l)
echo "Errors in last hour: $ERROR_COUNT"
echo ""

# Updates
echo "▶ Package Updates"
UPDATES=$(checkupdates 2>/dev/null | wc -l)
echo "Available updates: $UPDATES"
```

### Best Practices

**Regular checks:** Review system health daily or weekly.

**Set thresholds:** Define acceptable ranges for resources.

**Automate monitoring:** Use scripts and systemd timers for continuous monitoring.

**Act on alerts:** Investigate warnings promptly.

**Trend analysis:** Track metrics over time to identify patterns.

**Document baselines:** Know what's normal for your system.

**Prioritize issues:** Focus on critical errors first.

**Monitor proactively:** Don't wait for failures to check logs.

**Keep tools updated:** Ensure monitoring tools are current.

**Test alerts:** Verify notification systems work before you need them.

Effective system health monitoring prevents problems, enables quick troubleshooting, and maintains

