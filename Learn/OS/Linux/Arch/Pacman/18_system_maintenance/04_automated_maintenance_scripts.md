## Automated Maintenance Scripts


### Overview

Automated maintenance scripts handle routine system tasks without manual intervention, ensuring consistent system upkeep, preventing issues, and saving administrative time. Proper automation balances convenience with safety and control.

### Basic Maintenance Script

#### Comprehensive Weekly Maintenance

```bash
#!/bin/bash
# /usr/local/bin/weekly-maintenance
# Weekly Arch Linux maintenance script

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file
LOG="/var/log/maintenance-$(date +%Y%m%d).log"

# Function to log with timestamp
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

# Function for success messages
success() {
    log "${GREEN}✓ $1${NC}"
}

# Function for error messages
error() {
    log "${RED}✗ $1${NC}"
}

# Function for info messages
info() {
    log "${YELLOW}ℹ $1${NC}"
}

log "=== Starting Weekly Maintenance ==="

# 1. Update package databases
info "Updating package databases..."
if pacman -Sy; then
    success "Package databases updated"
else
    error "Failed to update databases"
fi

# 2. Check for updates (don't install yet)
info "Checking for available updates..."
UPDATES=$(checkupdates 2>/dev/null | wc -l)
if [ $UPDATES -gt 0 ]; then
    info "$UPDATES updates available"
    checkupdates 2>/dev/null | tee -a "$LOG"
else
    success "System is up to date"
fi

# 3. Remove orphaned packages
info "Checking for orphaned packages..."
ORPHANS=$(pacman -Qtdq 2>/dev/null)
if [ -n "$ORPHANS" ]; then
    info "Removing orphaned packages..."
    pacman -Rns --noconfirm $ORPHANS && success "Orphans removed" || error "Failed to remove orphans"
else
    success "No orphaned packages found"
fi

# 4. Clean package cache
info "Cleaning package cache..."
paccache -rk3 && success "Cache cleaned (kept 3 versions)" || error "Cache cleaning failed"
paccache -ruk0 && success "Uninstalled packages removed from cache" || error "Failed to clean uninstalled packages"

# 5. Clean journal logs
info "Cleaning journal logs..."
journalctl --vacuum-time=2weeks && success "Journal logs cleaned" || error "Journal cleaning failed"

# 6. Check for failed services
info "Checking for failed services..."
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -eq 0 ]; then
    success "No failed services"
else
    error "$FAILED failed services detected:"
    systemctl --failed --no-legend | tee -a "$LOG"
fi

# 7. Verify package database integrity
info "Verifying package database..."
if pacman -Dk &> /dev/null; then
    success "Package database integrity verified"
else
    error "Package database has issues"
fi

# 8. Report disk usage
info "Disk usage:"
df -h / /home | tail -2 | tee -a "$LOG"

# 9. Report cache sizes
info "Cache sizes:"
echo "Pacman cache: $(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)" | tee -a "$LOG"
echo "Journal size: $(journalctl --disk-usage 2>/dev/null | grep -oP 'archived and active journals take up \K.*')" | tee -a "$LOG"

# 10. Summary
log "=== Maintenance Complete ==="
log "Log saved to: $LOG"
```

**Installation:**
```
sudo nano /usr/local/bin/weekly-maintenance
sudo chmod +x /usr/local/bin/weekly-maintenance
```

**Test run:**
```
sudo /usr/local/bin/weekly-maintenance
```

### System Update Script with Safety Checks

```bash
#!/bin/bash
# /usr/local/bin/safe-update
# Safe system update with pre-checks

set -euo pipefail

# Configuration
MIN_FREE_SPACE=5242880  # 5GB in KB
BACKUP_DIR="/backup"
LOG="/var/log/safe-update-$(date +%Y%m%d-%H%M%S).log"

# Logging
exec 1> >(tee -a "$LOG")
exec 2>&1

echo "=== Safe System Update Script ==="
echo "Started: $(date)"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# 1. Check Arch news
echo "▶ Checking Arch Linux news..."
echo "Visit: https://archlinux.org/news/"
read -p "Have you checked Arch news for manual interventions? (y/n): " NEWS_CHECKED
if [ "$NEWS_CHECKED" != "y" ]; then
    echo "Please check Arch news before updating."
    exit 1
fi

# 2. Check disk space
echo ""
echo "▶ Checking disk space..."
FREE_SPACE=$(df / | tail -1 | awk '{print $4}')
if [ $FREE_SPACE -lt $MIN_FREE_SPACE ]; then
    echo "Error: Insufficient disk space"
    echo "Free space: $(numfmt --to=iec-i --suffix=B $((FREE_SPACE * 1024)))"
    echo "Required: 5GB"
    exit 1
fi
echo "✓ Sufficient disk space: $(numfmt --to=iec-i --suffix=B $((FREE_SPACE * 1024)))"

# 3. Check network connectivity
echo ""
echo "▶ Checking network connectivity..."
if ping -c 3 archlinux.org &>/dev/null; then
    echo "✓ Network connection OK"
else
    echo "Error: No network connection"
    exit 1
fi

# 4. Backup /etc
echo ""
echo "▶ Backing up /etc directory..."
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/etc-$(date +%Y%m%d-%H%M%S).tar.gz" /etc 2>/dev/null
echo "✓ Backup created: $BACKUP_DIR/etc-$(date +%Y%m%d-%H%M%S).tar.gz"

# 5. Create snapshot if Timeshift is available
echo ""
if command -v timeshift &>/dev/null; then
    echo "▶ Creating Timeshift snapshot..."
    timeshift --create --comments "Pre-update $(date +%Y%m%d)" --scripted
    echo "✓ Snapshot created"
else
    echo "ℹ Timeshift not installed, skipping snapshot"
fi

# 6. Update keyring first
echo ""
echo "▶ Updating archlinux-keyring..."
pacman -Sy archlinux-keyring --noconfirm
echo "✓ Keyring updated"

# 7. Show what will be updated
echo ""
echo "▶ Available updates:"
checkupdates 2>/dev/null || echo "System is up to date"
echo ""
read -p "Proceed with system update? (y/n): " PROCEED

if [ "$PROCEED" != "y" ]; then
    echo "Update cancelled"
    exit 0
fi

# 8. Perform system update
echo ""
echo "▶ Starting system update..."
pacman -Syu --noconfirm

# 9. Update AUR packages if helper is available
echo ""
if command -v yay &>/dev/null; then
    echo "▶ Updating AUR packages..."
    sudo -u $(logname) yay -Sua --noconfirm
elif command -v paru &>/dev/null; then
    echo "▶ Updating AUR packages..."
    sudo -u $(logname) paru -Sua --noconfirm
else
    echo "ℹ No AUR helper found, skipping AUR updates"
fi

# 10. Clean up
echo ""
echo "▶ Cleaning up..."
paccache -rk2
paccache -ruk0

# 11. Remove orphans
echo ""
echo "▶ Checking for orphaned packages..."
ORPHANS=$(pacman -Qtdq 2>/dev/null)
if [ -n "$ORPHANS" ]; then
    echo "Removing orphaned packages..."
    pacman -Rns --noconfirm $ORPHANS
else
    echo "No orphaned packages found"
fi

# 12. Check for failed services
echo ""
echo "▶ Checking system health..."
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -eq 0 ]; then
    echo "✓ All services running normally"
else
    echo "⚠ Warning: $FAILED failed services detected"
    systemctl --failed
fi

# 13. Check if reboot needed
echo ""
if [ -f /usr/lib/modules/$(uname -r) ]; then
    echo "✓ Current kernel is up to date"
else
    echo "⚠ Warning: Kernel was updated, reboot recommended"
    read -p "Reboot now? (y/n): " REBOOT
    if [ "$REBOOT" == "y" ]; then
        echo "Rebooting in 5 seconds..."
        sleep 5
        reboot
    fi
fi

echo ""
echo "=== Update Complete ==="
echo "Finished: $(date)"
echo "Log saved to: $LOG"
```

### Automated Cleanup Script

```bash
#!/bin/bash
# /usr/local/bin/auto-cleanup
# Automated system cleanup

LOG="/var/log/cleanup-$(date +%Y%m%d).log"
exec 1> >(tee -a "$LOG")
exec 2>&1

echo "=== Automated Cleanup Script ==="
echo "Started: $(date)"

# 1. Clean package cache (keep 2 versions)
echo ""
echo "▶ Cleaning package cache..."
paccache -rk2
paccache -ruk0

CACHE_SIZE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
echo "Current cache size: $CACHE_SIZE"

# 2. Clean journal logs (keep 2 weeks)
echo ""
echo "▶ Cleaning journal logs..."
journalctl --vacuum-time=2weeks

JOURNAL_SIZE=$(journalctl --disk-usage | grep -oP 'archived and active journals take up \K[^ ]*')
echo "Current journal size: $JOURNAL_SIZE"

# 3. Clean user caches (optional)
echo ""
echo "▶ Cleaning user caches..."

# Browser caches
for user in /home/*; do
    username=$(basename "$user")
    if [ -d "$user/.cache/mozilla" ]; then
        find "$user/.cache/mozilla" -type f -atime +30 -delete
        echo "Cleaned Firefox cache for $username"
    fi
    if [ -d "$user/.cache/chromium" ]; then
        find "$user/.cache/chromium" -type f -atime +30 -delete
        echo "Cleaned Chromium cache for $username"
    fi
done

# 4. Clean thumbnails
echo ""
echo "▶ Cleaning thumbnail caches..."
for user in /home/*; do
    username=$(basename "$user")
    if [ -d "$user/.cache/thumbnails" ]; then
        find "$user/.cache/thumbnails" -type f -atime +30 -delete
        echo "Cleaned thumbnails for $username"
    fi
done

# 5. Clean temporary files
echo ""
echo "▶ Cleaning temporary files..."
find /tmp -type f -atime +7 -delete 2>/dev/null
find /var/tmp -type f -atime +7 -delete 2>/dev/null

# 6. Remove old log files
echo ""
echo "▶ Removing old log files..."
find /var/log -name "*.old" -delete
find /var/log -name "*.gz" -mtime +30 -delete

# 7. Report space freed
echo ""
echo "=== Cleanup Summary ==="
df -h / | tail -1

echo ""
echo "Cleanup completed: $(date)"
```

### AUR Package Rebuild Script

```bash
#!/bin/bash
# /usr/local/bin/rebuild-aur
# Rebuild AUR packages after library updates

LOG="/var/log/aur-rebuild-$(date +%Y%m%d).log"
exec 1> >(tee -a "$LOG")
exec 2>&1

echo "=== AUR Package Rebuild Script ==="
echo "Started: $(date)"

# Check if AUR helper is available
if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    echo "Error: No AUR helper found (yay or paru)"
    exit 1
fi

# Get list of foreign packages
echo ""
echo "▶ Checking for foreign packages..."
FOREIGN=$(pacman -Qmq)

if [ -z "$FOREIGN" ]; then
    echo "No foreign packages installed"
    exit 0
fi

echo "Found $(echo "$FOREIGN" | wc -l) foreign packages"

# Show packages to rebuild
echo ""
echo "Packages to rebuild:"
echo "$FOREIGN"

read -p "Proceed with rebuild? (y/n): " PROCEED
if [ "$PROCEED" != "y" ]; then
    echo "Rebuild cancelled"
    exit 0
fi

# Rebuild packages
echo ""
echo "▶ Rebuilding packages..."

if command -v yay &>/dev/null; then
    yay -S $FOREIGN --rebuild --noconfirm
elif command -v paru &>/dev/null; then
    paru -S $FOREIGN --rebuild --noconfirm
fi

echo ""
echo "=== Rebuild Complete ==="
echo "Finished: $(date)"
```

### Health Check and Alert Script

```bash
#!/bin/bash
# /usr/local/bin/health-check
# System health check with alerts

# Thresholds
CPU_THRESHOLD=80
DISK_THRESHOLD=80
MEM_THRESHOLD=90

# Alert function
alert() {
    MESSAGE="$1"
    echo "ALERT: $MESSAGE"
    
    # Desktop notification
    if command -v notify-send &>/dev/null; then
        notify-send -u critical "System Alert" "$MESSAGE"
    fi
    
    # Log to journal
    logger -p user.crit "health-check: $MESSAGE"
    
    # Email (if configured)
    # echo "$MESSAGE" | mail -s "System Alert" admin@example.com
}

# Check CPU usage
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
if [ $CPU -gt $CPU_THRESHOLD ]; then
    alert "CPU usage high: ${CPU}%"
fi

# Check disk space
DISK=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK -gt $DISK_THRESHOLD ]; then
    alert "Disk usage high: ${DISK}%"
fi

# Check memory usage
MEM_PERCENT=$(free | grep Mem | awk '{printf "%.0f", ($3/$2) * 100}')
if [ $MEM_PERCENT -gt $MEM_THRESHOLD ]; then
    alert "Memory usage high: ${MEM_PERCENT}%"
fi

# Check failed services
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -gt 0 ]; then
    alert "$FAILED services have failed"
fi

# Check for system errors
ERROR_COUNT=$(journalctl -p err --since "1 hour ago" --no-pager | wc -l)
if [ $ERROR_COUNT -gt 10 ]; then
    alert "$ERROR_COUNT errors in the last hour"
fi

# Check available updates
UPDATES=$(checkupdates 2>/dev/null | wc -l)
if [ $UPDATES -gt 50 ]; then
    alert "$UPDATES package updates available"
fi
```

### Systemd Service and Timer Setup

#### Create Systemd Service

```ini
# /etc/systemd/system/weekly-maintenance.service
[Unit]
Description=Weekly System Maintenance
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/weekly-maintenance
StandardOutput=journal
StandardError=journal
```

#### Create Systemd Timer

```ini
# /etc/systemd/system/weekly-maintenance.timer
[Unit]
Description=Run weekly maintenance
Requires=weekly-maintenance.service

[Timer]
OnCalendar=Sun 03:00
Persistent=true
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
```

**Enable timer:**
```
sudo systemctl daemon-reload
sudo systemctl enable --now weekly-maintenance.timer
```

**Check timer status:**
```
systemctl list-timers weekly-maintenance.timer
systemctl status weekly-maintenance.timer
```

**View logs:**
```
journalctl -u weekly-maintenance.service
```

### Multiple Maintenance Timers

#### Daily cleanup timer:
```ini
# /etc/systemd/system/daily-cleanup.timer
[Unit]
Description=Daily cleanup tasks

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target
```

#### Health check timer (every 4 hours):
```ini
# /etc/systemd/system/health-check.timer
[Unit]
Description=System health check

[Timer]
OnCalendar=*-*-* 00/4:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

### Cron-Based Alternative

```cron
# /etc/cron.d/arch-maintenance

# Weekly full maintenance (Sunday 3 AM)
0 3 * * 0 root /usr/local/bin/weekly-maintenance

# Daily cleanup (2 AM)
0 2 * * * root /usr/local/bin/auto-cleanup

# Health check every 4 hours
0 */4 * * * root /usr/local/bin/health-check

# Monthly AUR rebuild (first Sunday, 4 AM)
0 4 1-7 * 0 root /usr/local/bin/rebuild-aur
```

### Best Practices

**Test thoroughly:** Test all scripts manually before automating.

**Log everything:** Maintain detailed logs of all automated actions.

**Set conservative schedules:** Don't run scripts too frequently.

**Include safety checks:** Verify conditions before destructive operations.

**Notification system:** Alert on failures or important events.

**User confirmation:** For critical operations, require manual approval.

**Backup first:** Always backup before automated system changes.

**Monitor execution:** Regularly check that automated tasks are running.

**Document scripts:** Comment code and maintain documentation.

**Version control:** Track script changes in git.

**Idempotent operations:** Scripts should be safe to run multiple times.

**Error handling:** Scripts should handle and report errors gracefully.

Automated maintenance scripts ensure consistent system upkeep while reducing administrative burden, but must be carefully designed and monitored to prevent unintended consequences.

