## Manual Intervention Scenarios


### Overview

Manual intervention scenarios occur when Arch Linux updates require user action beyond standard package installation. These situations are announced on the Arch Linux news page and require careful attention to prevent system breakage.

### Sources of Manual Intervention Notices

#### Arch Linux News

**Official news page:**
```
https://archlinux.org/news/
```

Always check before major updates.

**RSS feed:**
```
https://archlinux.org/feeds/news/
```

Subscribe for automatic notifications.

**Check news from terminal:**
```
curl -s https://archlinux.org/feeds/news/ | grep -E '<title>|<pubDate>' | head -20
```

Shows recent news items.

#### Package Install Messages

**Post-install scriptlets:**
During package installation, watch for messages like:
```
:: Important notice from package-name:
   Manual intervention required - see https://archlinux.org/news/...
```

**Save to log:**
```
sudo pacman -Syu 2>&1 | tee pacman-upgrade.log
```

Review log for important notices.

### Common Manual Intervention Categories

#### Filesystem Changes

**Restructuring system paths:**
- Moving directories
- Changing file locations
- Symlink replacements

**Configuration file migrations:**
- Format changes
- Location changes
- Syntax updates

#### Package Splits and Merges

**Package splitting:**
One package becomes multiple smaller packages.

**Package merging:**
Multiple packages consolidated into one.

**Provider changes:**
New package provides functionality of old package.

#### Configuration Format Changes

**New configuration syntax:**
- systemd unit file changes
- Application config format updates
- Service configuration restructuring

#### Deprecated Features

**Removal warnings:**
- Features being phased out
- Compatibility layers removed
- API changes requiring adaptation

### Historical Examples

#### Example 1: Filesystem Package Update (2013)

**Announcement:** "Binaries move to /usr/bin"

**Issue:** `/bin`, `/sbin`, `/usr/sbin` merged into `/usr/bin`

**Manual steps required:**
```
# Before upgrade
pacman -Syu --ignore filesystem,bash
pacman -S bash
pacman -Su
```

**Reason:** Prevented broken system during directory restructuring.

#### Example 2: Glibc Locale Generation (2015)

**Announcement:** "Glibc locale generation changes"

**Issue:** Locale generation method changed

**Manual steps required:**
```
# Uncomment needed locales in /etc/locale.gen
sudo nano /etc/locale.gen

# Regenerate locales
sudo locale-gen
```

**Reason:** System wouldn't generate locales properly without intervention.

#### Example 3: OpenSSH 9.0 Update (2022)

**Announcement:** "OpenSSH 9.0 deprecates SHA-1 signatures"

**Issue:** Old SSH keys using SHA-1 no longer accepted by default

**Manual steps required:**
```
# Generate new key with modern algorithm
ssh-keygen -t ed25519

# Or configure legacy support temporarily
# Add to ~/.ssh/config:
Host old-server
    HostkeyAlgorithms +ssh-rsa
    PubkeyAcceptedAlgorithms +ssh-rsa
```

**Reason:** Security improvement requiring key updates.

#### Example 4: Arch Linux Keyring Master Key Rotation (2023)

**Announcement:** "Arch Linux keyring master key rotation"

**Issue:** Master signing keys updated

**Manual steps required:**
```
# Update keyring before full upgrade
sudo pacman -Sy archlinux-keyring
sudo pacman -Su
```

**Reason:** Old keys couldn't verify new package signatures.

#### Example 5: Systemd-boot Configuration Change (2024)

**Announcement:** "systemd-boot loader.conf format changes"

**Issue:** Boot loader configuration syntax updated

**Manual steps required:**
```
# Update /boot/loader/loader.conf
# Old:
timeout 3
default arch

# New:
timeout 3
default arch.conf
```

**Reason:** Boot loader wouldn't recognize old format.

### Handling Manual Intervention

#### Step-by-Step Procedure

**1. Check Arch news before updating:**
```
# Visit https://archlinux.org/news/
# Or use RSS reader
# Or check from terminal:
curl -s https://archlinux.org/feeds/news/ | grep -E '<title>|<pubDate>' | head -10
```

**2. Read full announcement:**
- Understand what's changing
- Note required manual steps
- Identify affected systems/configurations

**3. Backup critical **
```
sudo cp -a /etc /backup/etc-$(date +%Y%m%d)
sudo cp -a /boot /backup/boot-$(date +%Y%m%d)
```

**4. Create system snapshot (if available):**
```
sudo timeshift --create --comments "Before manual intervention"
# or
sudo btrfs subvolume snapshot / /.snapshots/pre-intervention-$(date +%Y%m%d)
```

**5. Follow manual steps exactly:**
Execute commands as specified in the announcement.

**6. Proceed with system update:**
```
sudo pacman -Syu
```

**7. Verify system functionality:**
- Check services: `systemctl --failed`
- Verify boot: `journalctl -b -p err`
- Test critical applications

**8. Monitor for issues:**
Watch logs and system behavior for 24-48 hours.

### Common Manual Intervention Patterns

#### Package Rename Pattern

**Scenario:** Package renamed, no automatic transition

**Example announcement:**
```
Package 'old-name' replaced by 'new-name'
Manual action required:
  pacman -S new-name
  pacman -R old-name
```

**Steps:**
```
sudo pacman -S new-name
sudo pacman -Rns old-name
```

#### Configuration File Migration

**Scenario:** Configuration file location or format changed

**Example announcement:**
```
Package-name configuration moved from /etc/old/config to /etc/new/config
Manual migration required for custom configurations.
```

**Steps:**
```
# Backup old config
sudo cp /etc/old/config /etc/old/config.bak

# Copy to new location
sudo cp /etc/old/config /etc/new/config

# Adjust format if needed (check documentation)
sudo nano /etc/new/config

# Test new configuration
sudo systemctl restart service-name

# Remove old config when confirmed working
sudo rm /etc/old/config
```

#### Service Unit Changes

**Scenario:** Systemd unit file changes

**Example announcement:**
```
Service-name.service unit file changed. 
User-created overrides in /etc/systemd/system/ may need updating.
```

**Steps:**
```
# Check for overrides
systemctl cat service-name.service

# Review /etc/systemd/system/ for custom units
ls /etc/systemd/system/service-name.service.d/

# Update overrides to match new format
sudo systemctl edit service-name.service

# Reload systemd
sudo systemctl daemon-reload

# Restart service
sudo systemctl restart service-name
```

#### Library Soname Bump

**Scenario:** Major library version change requiring rebuilds

**Example announcement:**
```
Library libfoo.so.5 updated to libfoo.so.6
AUR packages may need rebuilding.
```

**Steps:**
```
# List foreign packages (AUR)
pacman -Qm

# Rebuild AUR packages
yay -S $(pacman -Qmq) --rebuild
# or
paru -S $(pacman -Qmq) --rebuild

# Check for broken links
sudo ldconfig
ldd /path/to/binary | grep "not found"
```

### Automation and Monitoring

#### News Checking Script

```bash
#!/bin/bash
# /usr/local/bin/check-arch-news

NEWS_URL="https://archlinux.org/feeds/news/"
CACHE_FILE="/tmp/arch-news-cache"

# Fetch current news
CURRENT_NEWS=$(curl -s "$NEWS_URL" | grep '<title>' | head -5)

# Check if news changed
if [ -f "$CACHE_FILE" ]; then
    CACHED_NEWS=$(cat "$CACHE_FILE")
    if [ "$CURRENT_NEWS" != "$CACHED_NEWS" ]; then
        echo "=== NEW ARCH LINUX NEWS DETECTED ==="
        echo "$CURRENT_NEWS"
        echo "=== Visit https://archlinux.org/news/ ==="
        
        # Send notification
        notify-send "Arch News Update" "New announcements available"
    fi
fi

# Update cache
echo "$CURRENT_NEWS" > "$CACHE_FILE"
```

**Schedule with cron:**
```
0 */6 * * * /usr/local/bin/check-arch-news
```

Checks every 6 hours for news updates.

#### Pre-Update Safety Script

```bash
#!/bin/bash
# /usr/local/bin/safe-update

echo "=== Arch Linux Safe Update Script ==="

# 1. Check Arch news
echo "Checking Arch Linux news..."
echo "Visit: https://archlinux.org/news/"
read -p "Have you checked Arch news? (y/n): " CHECKED

if [ "$CHECKED" != "y" ]; then
    echo "Please check Arch news before updating."
    exit 1
fi

# 2. Backup critical directories
echo "Creating backup of /etc..."
sudo cp -a /etc /backup/etc-$(date +%Y%m%d)

# 3. Create snapshot if available
if command -v timeshift &>/dev/null; then
    echo "Creating Timeshift snapshot..."
    sudo timeshift --create --comments "Pre-update $(date +%Y%m%d)"
fi

# 4. Check disk space
FREE_SPACE=$(df / | tail -1 | awk '{print $4}')
if [ $FREE_SPACE -lt 5242880 ]; then  # 5GB in KB
    echo "Warning: Less than 5GB free space"
    read -p "Continue anyway? (y/n): " CONTINUE
    [ "$CONTINUE" != "y" ] && exit 1
fi

# 5. Update keyring first
echo "Updating keyring..."
sudo pacman -Sy archlinux-keyring

# 6. Proceed with system update
echo "Starting system update..."
sudo pacman -Syu

# 7. Check for failed services
echo "Checking for failed services..."
systemctl --failed

echo "=== Update complete ==="
```

### Recovery from Failed Manual Intervention

#### Incomplete Manual Steps

**Problem:** Performed update without completing manual steps

**Symptoms:**
- System won't boot
- Services fail to start
- Applications crash

**Recovery:**

**1. Boot from live USB if necessary**

**2. Chroot into system:**
```
mount /dev/sdXn /mnt
arch-chroot /mnt
```

**3. Review Arch news and complete manual steps:**
Follow the announcement instructions.

**4. Reinstall affected packages:**
```
pacman -S affected-package --overwrite '*'
```

**5. Verify and reboot**

#### Incorrect Manual Steps

**Problem:** Executed manual steps incorrectly

**Recovery:**

**1. Restore backup:**
```
sudo cp -a /backup/etc-20251101/* /etc/
```

**2. Re-read announcement carefully**

**3. Execute correct steps**

**4. Test thoroughly**

### Best Practices

#### Before Updates

**Always check news:** Make it a habit before running `pacman -Syu`.

**Read completely:** Don't skim announcements; understand fully.

**Backup first:** Create backups before any manual intervention.

**Test on non-critical systems:** If possible, test on development machines first.

**Have rescue tools ready:** Keep bootable USB and recovery knowledge available.

#### During Manual Intervention

**Follow exactly:** Execute commands precisely as written.

**Don't improvise:** Stick to official instructions.

**Document actions:** Keep notes on what you did.

**One step at a time:** Complete each step before moving to next.

**Verify each step:** Confirm success before proceeding.

#### After Updates

**Monitor logs:** Watch for errors or warnings.

**Test functionality:** Verify critical services and applications work.

**Check forums:** See if others report issues.

**Keep backups:** Don't delete backups immediately; wait a few days.

**Report problems:** Help community by reporting reproducible issues.

### Resources

**Official news:**
```
https://archlinux.org/news/
```

**Arch Wiki:**
```
https://wiki.archlinux.org/
```

**Forums:**
```
https://bbs.archlinux.org/
```

**Mailing lists:**
```
https://lists.archlinux.org/
```

**IRC:**
```
#archlinux on Libera.Chat
```

Manual intervention scenarios are part of maintaining a rolling-release distribution. Careful attention to announcements and methodical execution of required steps ensures smooth updates without system breakage

