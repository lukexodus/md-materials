## Regular Maintenance Routines


### Overview

Regular maintenance keeps an Arch Linux system clean, secure, and performing optimally. Establishing consistent maintenance routines prevents common issues, manages disk space, and ensures system reliability.

### Daily Maintenance

#### Quick Health Check

**Check for failed services:**
```
systemctl --failed
```

Should show "0 loaded units listed." If services failed, investigate.

**Check system errors:**
```
journalctl -p err -b
```

Shows error-level messages from current boot. Empty output is ideal.

**Check disk space:**
```
df -h /
```

Ensure root partition has at least 20% free space.

**Quick update check:**
```
checkupdates
```

Or:
```
pacman -Qu
```

Shows available updates without installing.

### Weekly Maintenance

#### System Update

**Full system upgrade:**
```
sudo pacman -Syu
```

**With AUR packages (if using helper):**
```
yay -Syu
paru -Syu
```

**Best practice workflow:**

**1. Check Arch news:**
```
# Visit https://archlinux.org/news/
# Or with paru:
paru -Pww
```

**2. Update keyring first (if significant time passed):**
```
sudo pacman -Sy archlinux-keyring
```

**3. Perform update:**
```
sudo pacman -Syu
```

**4. Reboot if kernel updated:**
```
# Check if kernel was updated
grep "upgraded linux" /var/log/pacman.log | tail -1

# Reboot if necessary
sudo reboot
```

#### Remove Orphaned Packages

**List orphans:**
```
pacman -Qtdq
```

Shows packages installed as dependencies but no longer required.

**Remove orphans:**
```
sudo pacman -Rns $(pacman -Qtdq)
```

**With AUR helper:**
```
yay -Yc
paru -c
```

**Example output:**
```
checking dependencies...

Packages (5) old-dep-1.0-1  old-lib-2.0-1  unused-tool-3.0-1

Total Removed Size: 45.2 MiB

:: Do you want to remove these packages? [Y/n]
```

#### Clean Package Cache

**Keep 3 recent versions:**
```
sudo paccache -r
```

**Keep 1 recent version:**
```
sudo paccache -rk1
```

**Remove uninstalled packages from cache:**
```
sudo paccache -ruk0
```

**Check cache size:**
```
du -sh /var/cache/pacman/pkg/
```

**Complete cache cleanup (not recommended):**
```
sudo pacman -Scc
```

Only use when severely limited on space; removes all cached packages.

### Bi-Weekly Maintenance

#### Update AUR Packages

**With AUR helper:**
```
yay -Syu
paru -Syu
```

**Manual update for critical AUR packages:**
```
cd ~/aur/package-name
git pull
cat PKGBUILD  # Review changes
makepkg -si
```

#### System Log Management

**Check journal size:**
```
journalctl --disk-usage
```

**Clean old logs (keep 2 weeks):**
```
sudo journalctl --vacuum-time=2weeks
```

**Clean by size (keep 500MB):**
```
sudo journalctl --vacuum-size=500M
```

**Configure persistent limit:**
```
# Edit /etc/systemd/journald.conf
SystemMaxUse=500M
```

Then restart journald:
```
sudo systemctl restart systemd-journald
```

#### Check Failed Login Attempts

**View failed logins:**
```
journalctl _SYSTEMD_UNIT=sshd.service | grep "Failed password"
```

**Check authentication logs:**
```
journalctl -u systemd-logind -b
```

### Monthly Maintenance

#### Development Package Updates

**Update -git, -svn, -hg packages:**
```
yay -Syu --devel
paru -Syu --devel
```

These packages don't have version numbers, so helpers can't detect updates automatically.

#### Database Optimization

**Check database integrity:**
```
sudo pacman -Dk
```

**Verify package files:**
```
pacman -Qkk | grep -v "0 altered files"
```

Shows packages with modified files.

**Update files database:**
```
sudo pacman -Fy
```

Enables file search with `pacman -F filename`.

#### Mirror List Update

**Update with reflector:**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Or country-specific:**
```
sudo reflector --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**After updating mirrors:**
```
sudo pacman -Syy
```

#### Clean User Cache

**Check cache sizes:**
```
du -sh ~/.cache/*
```

**Clean specific caches:**
```
# Browser cache
rm -rf ~/.cache/mozilla/
rm -rf ~/.cache/chromium/

# Thumbnail cache
rm -rf ~/.cache/thumbnails/

# AUR helper cache
yay -Sc
paru -Sc
```

**Or clean all user cache (careful):**
```
rm -rf ~/.cache/*
```

### Quarterly Maintenance

#### Full System Cleanup

**Comprehensive cleanup script:**

```bash
#!/bin/bash
# Quarterly maintenance script

echo "=== Arch Linux Quarterly Maintenance ==="

# 1. System update
echo "Updating system..."
sudo pacman -Syu

# 2. Update AUR packages with development
if command -v yay &>/dev/null; then
    echo "Updating AUR packages..."
    yay -Syu --devel
fi

# 3. Remove orphans
echo "Removing orphaned packages..."
ORPHANS=$(pacman -Qtdq)
if [ -n "$ORPHANS" ]; then
    sudo pacman -Rns $ORPHANS
else
    echo "No orphans found"
fi

# 4. Clean package cache
echo "Cleaning package cache..."
sudo paccache -rk2
sudo paccache -ruk0

# 5. Clean journal
echo "Cleaning journal logs..."
sudo journalctl --vacuum-time=4weeks

# 6. Update mirror list
echo "Updating mirror list..."
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# 7. Verify system integrity
echo "Verifying package database..."
sudo pacman -Dk

# 8. Display statistics
echo ""
echo "=== System Statistics ==="
echo "Disk usage: $(df -h / | tail -1 | awk '{print $5}')"
echo "Package cache: $(du -sh /var/cache/pacman/pkg/ | cut -f1)"
echo "Journal size: $(journalctl --disk-usage | grep -oP 'archived and active journals take up \K.*')"
echo "Installed packages: $(pacman -Q | wc -l)"
echo "Orphaned packages: $(pacman -Qtd | wc -l)"

echo ""
echo "=== Maintenance Complete ==="
```

**Save as `/usr/local/bin/quarterly-maintenance`:**
```
sudo nano /usr/local/bin/quarterly-maintenance
sudo chmod +x /usr/local/bin/quarterly-maintenance
```

**Run quarterly:**
```
quarterly-maintenance
```

#### Rebuild Problematic AUR Packages

**After major library updates:**
```
# List foreign packages
pacman -Qm

# Rebuild all
yay -S $(pacman -Qmq) --rebuild
```

#### Review Installed Packages

**List explicitly installed packages:**
```
pacman -Qe
```

**Review and remove unused:**
```
pacman -Qe | less
# Remove packages you no longer use
sudo pacman -Rns unused-package
```

**Identify large packages:**
```
expac -H M '%m\t%n' | sort -h | tail -20
```

Shows 20 largest packages.

#### Security Audit

**Check for held packages:**
```
grep "^IgnorePkg" /etc/pacman.conf
```

Review if you still need to hold these packages.

**Update held packages if safe:**
```
# Remove from /etc/pacman.conf
sudo pacman -S previously-held-package
```

**Check for outdated AUR packages:**
Visit AUR pages for critical packages and check for updates or security notices.

### Automated Maintenance

#### Systemd Timer for Weekly Updates

**Create service file:**
```
sudo nano /etc/systemd/system/weekly-update.service
```

**Content:**
```ini
[Unit]
Description=Weekly System Update
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Syu --noconfirm
ExecStart=/usr/bin/paccache -rk3
ExecStart=/usr/bin/journalctl --vacuum-time=2weeks
```

**Create timer file:**
```
sudo nano /etc/systemd/system/weekly-update.timer
```

**Content:**
```ini
[Unit]
Description=Run weekly system update
Requires=weekly-update.service

[Timer]
OnCalendar=Sun 03:00
Persistent=true

[Install]
WantedBy=timers.target
```

**Enable timer:**
```
sudo systemctl enable --now weekly-update.timer
```

**Check timer status:**
```
systemctl list-timers weekly-update.timer
```

#### Pacman Hooks for Automatic Cleanup

**Create cleanup hook:**
```
sudo nano /etc/pacman.d/hooks/cleanup.hook
```

**Content:**
```ini
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning package cache and orphans...
When = PostTransaction
Exec = /bin/sh -c "paccache -rk3; pacman -Qtdq | pacman -Rns --noconfirm - || true"
```

Automatically cleans after every transaction.

### Monitoring and Alerts

#### Check System Health

**Create monitoring script:**
```bash
#!/bin/bash
# System health check

# Failed services
FAILED=$(systemctl --failed --no-legend | wc -l)
[ $FAILED -gt 0 ] && echo "WARNING: $FAILED failed services"

# Disk space
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
[ $USAGE -gt 80 ] && echo "WARNING: Root partition ${USAGE}% full"

# Updates available
UPDATES=$(checkupdates 2>/dev/null | wc -l)
[ $UPDATES -gt 0 ] && echo "INFO: $UPDATES updates available"

# System errors today
ERRORS=$(journalctl -p err -S today --no-pager | wc -l)
[ $ERRORS -gt 0 ] && echo "WARNING: $ERRORS errors logged today"
```

**Schedule daily:**
```
0 9 * * * /usr/local/bin/health-check | mail -s "System Health" you@email.com
```

### Backup Routines

#### Configuration Backup

**Weekly config backup:**
```bash
#!/bin/bash
# Backup important configs

BACKUP_DIR="/backup/configs/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup critical directories
tar -czf "$BACKUP_DIR/etc.tar.gz" /etc
tar -czf "$BACKUP_DIR/home-configs.tar.gz" ~/.config ~/.bashrc ~/.zshrc

# Keep only last 12 backups
find /backup/configs/ -maxdepth 1 -type d -mtime +90 -exec rm -rf {} \;
```

#### System Snapshot

**Using Timeshift (recommended):**
```
sudo timeshift --create --comments "Weekly backup"
```

**Using Btrfs snapshots:**
```
sudo btrfs subvolume snapshot / /.snapshots/$(date +%Y%m%d)
```

### Maintenance Checklist

#### Weekly Checklist

- [ ] Check Arch news
- [ ] Update system (`pacman -Syu`)
- [ ] Remove orphans (`pacman -Rns $(pacman -Qtdq)`)
- [ ] Clean package cache (`paccache -r`)
- [ ] Check failed services (`systemctl --failed`)
- [ ] Review system errors (`journalctl -p err -b`)

#### Monthly Checklist

- [ ] Update development packages (`yay -Syu --devel`)
- [ ] Clean journal logs (`journalctl --vacuum-time=2weeks`)
- [ ] Update mirror list (`reflector`)
- [ ] Review installed packages (`pacman -Qe`)
- [ ] Check disk usage (`df -h`)
- [ ] Clean user caches (`~/.cache/`)
- [ ] Verify package integrity (`pacman -Qkk`)

#### Quarterly Checklist

- [ ] Full system cleanup (run maintenance script)
- [ ] Rebuild AUR packages (`yay -S $(pacman -Qmq) --rebuild`)
- [ ] Review held packages (IgnorePkg)
- [ ] Security audit
- [ ] Create system backup/snapshot
- [ ] Review and document system changes
- [ ] Update documentation of installed packages

### Best Practices

**Regular schedule:** Establish consistent maintenance schedule and stick to it.

**Before major changes:** Always update before installing new software or making system changes.

**Monitor logs:** Regularly review system logs for unusual activity.

**Keep backups:** Maintain recent backups or snapshots.

**Document changes:** Keep notes on system modifications and why you made them.

**Test updates:** If possible, test updates on non-critical systems first.

**Read news:** Always check Arch news before major updates.

**Don't automate blindly:** Understand what automated scripts do.

**Clean conservatively:** Don't delete everything; maintain some cache and history.

**Stay current:** Regular small updates are safer than infrequent large ones.

Regular maintenance prevents most common Arch Linux issues, keeps the system running smoothly, and makes problem-solving easier when issues do arise.

