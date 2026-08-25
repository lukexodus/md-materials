## Mirror Ranking and Selection


### Understanding Mirrors

Mirrors are servers that host copies of Arch Linux package repositories. Selecting fast, reliable mirrors is crucial for optimal package download speeds and system maintenance efficiency. Mirrors differ in geographic location, bandwidth, synchronization frequency, and reliability.

### Mirror Configuration File

#### Mirrorlist Location

The default mirrorlist file is located at:

```
/etc/pacman.d/mirrorlist
```

This file contains a list of available mirror servers that pacman uses to download packages.

#### Mirrorlist Format

```
## Country: United States
Server = https://mirrors.example.com/archlinux/$repo/os/$arch

## Country: Germany
#Server = https://mirror.de/archlinux/$repo/os/$arch
```

**Active mirrors:** Uncommented `Server` lines
**Disabled mirrors:** Lines starting with `#Server`
**Comments:** Lines starting with `##`

Pacman tries mirrors in order from top to bottom, using the first successful connection.

### Manual Mirror Ranking

#### Backup Current Mirrorlist

Before making changes, backup the existing configuration:

```
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
```

#### Selecting Mirrors Manually

Edit the mirrorlist:

```
sudo nano /etc/pacman.d/mirrorlist
```

**Move fast mirrors to the top:**

```
## Fastest mirrors
Server = https://fast-mirror1.com/archlinux/$repo/os/$arch
Server = https://fast-mirror2.com/archlinux/$repo/os/$arch

## Backup mirrors
#Server = https://slower-mirror.com/archlinux/$repo/os/$arch
```

**Geographic considerations:**
- Prioritize mirrors in your country or region
- Closer mirrors generally have lower latency
- Time zone proximity may affect peak load times

#### Testing Mirrors Manually

Test mirror download speed using curl:

```
time curl -o /dev/null https://mirror.example.com/archlinux/core/os/x86_64/core.db
```

Compare times across multiple mirrors to identify the fastest.

**Check mirror sync status:**
```
curl -s https://mirror.example.com/archlinux/lastupdate
```

Compare the timestamp with other mirrors to ensure up-to-date synchronization.

### Automated Mirror Ranking with Reflector

#### Installing Reflector

Reflector is the recommended tool for automated mirror ranking on Arch Linux:

```
sudo pacman -S reflector
```

#### Basic Reflector Usage

**Update mirrorlist with 20 fastest mirrors:**

```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

This fetches the 20 most recently synchronized mirrors, filters by HTTPS protocol, sorts by download rate, and saves to the mirrorlist.

#### Reflector Options

**--latest N:** Select N most recently synchronized mirrors

```
sudo reflector --latest 10
```

Ensures mirrors are up-to-date (recently synced with master servers).

**--protocol https|http|rsync:** Filter by protocol

```
sudo reflector --protocol https          # HTTPS only
sudo reflector --protocol https,http     # Both HTTPS and HTTP
```

HTTPS provides encrypted downloads and is recommended.

**--sort {age,rate,country,score,delay}:** Sort criteria

```
sudo reflector --sort rate      # By download speed
sudo reflector --sort age       # By sync time (newest first)
sudo reflector --sort delay     # By mirror delay
```

Rate-based sorting provides fastest downloads.

**--country 'Country1,Country2':** Filter by country

```
sudo reflector --country 'United States'
sudo reflector --country 'United States,Canada'
sudo reflector --country Germany
```

Limits mirrors to specific countries for geographic proximity.

**--fastest N:** Select N fastest mirrors (tests actual speed)

```
sudo reflector --latest 50 --fastest 10
```

Tests actual download speeds from 50 recent mirrors and selects the 10 fastest.

**--age N:** Limit to mirrors synced within the last N hours

```
sudo reflector --age 12      # Synced within last 12 hours
sudo reflector --age 24      # Synced within last 24 hours
```

**--save /path/to/file:** Save output to file

```
sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
```

Directly updates the mirrorlist file.

**--threads N:** Number of threads for speed testing

```
sudo reflector --threads 10
```

Increases parallelism during mirror speed tests.

**--verbose:** Show detailed output

```
sudo reflector --verbose --latest 20
```

Displays mirror information and rating process.

#### Practical Reflector Examples

**Fast, nearby mirrors (US):**
```
sudo reflector --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Globally optimized mirrors:**
```
sudo reflector --latest 50 --protocol https --sort rate --fastest 10 --save /etc/pacman.d/mirrorlist
```

**Fresh, high-quality mirrors:**
```
sudo reflector --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Comprehensive selection:**
```
sudo reflector --latest 200 --protocol https --fastest 20 --sort rate --threads 20 --save /etc/pacman.d/mirrorlist
```

### Automated Reflector Updates

#### Systemd Timer (Recommended)

Enable automatic weekly mirrorlist updates:

**Create reflector configuration:**

```
sudo nano /etc/xdg/reflector/reflector.conf
```

**Example configuration:**
```
# Reflector configuration file for systemd service

--save /etc/pacman.d/mirrorlist
--protocol https
--country 'United States'
--latest 20
--sort rate
--age 12
```

**Enable the systemd timer:**

```
sudo systemctl enable reflector.timer
sudo systemctl start reflector.timer
```

**Check timer status:**
```
systemctl status reflector.timer
```

**Manual trigger:**
```
sudo systemctl start reflector.service
```

This runs reflector immediately using the configured settings.

#### Cron Job Alternative

Schedule reflector with cron:

```
sudo crontab -e
```

**Weekly update (Sundays at 3 AM):**
```
0 3 * * 0 /usr/bin/reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Monthly update (first day at 2 AM):**
```
0 2 1 * * /usr/bin/reflector --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

#### Pacman Hook for Automatic Updates

Create a hook to update mirrors when the mirrorlist package updates:

```
sudo nano /etc/pacman.d/hooks/mirrorlist-update.hook
```

**Hook content:**
```
[Trigger]
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist

[Action]
Description = Updating mirror list with reflector...
When = PostTransaction
Depends = reflector
Exec = /usr/bin/reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

This automatically optimizes mirrors when the official mirrorlist package updates.

### Using Pacman-Mirrors (Manjaro)

Manjaro uses its own mirror management tool:

#### Basic Pacman-Mirrors Commands

**Fast-track to best mirrors:**
```
sudo pacman-mirrors --fasttrack
```

Automatically selects the fastest mirrors.

**Select by country:**
```
sudo pacman-mirrors --country United_States
sudo pacman-mirrors --country Germany,France
```

**Interactive mode:**
```
sudo pacman-mirrors --interactive
```

Opens a GUI for manual mirror selection.

**Generate ranked mirrorlist:**
```
sudo pacman-mirrors --api --set-branch stable --protocol https
```

**Update database after changing mirrors:**
```
sudo pacman -Syy
```

### Mirror Quality Indicators

#### Synchronization Status

**Check mirror freshness:**
```
curl -s https://mirror.example.com/archlinux/lastupdate
```

Compare the timestamp with the official Arch Linux repository. Mirrors should sync at least daily.

**Arch Linux mirror status page:**
```
https://archlinux.org/mirrors/status/
```

Shows detailed mirror information including:
- Last sync time
- Sync frequency
- Completion percentage
- Average delay

#### Mirror Speed Testing

**Simple download test:**
```
time curl -o /dev/null https://mirror.example.com/archlinux/core/os/x86_64/core.db
```

**Comprehensive test with multiple files:**
```bash
#!/bin/bash
MIRROR="https://mirror.example.com/archlinux"
for repo in core extra; do
  echo "Testing $repo..."
  time curl -o /dev/null "$MIRROR/$repo/os/x86_64/$repo.db"
done
```

#### Mirror Reliability

**Connection stability:** Mirrors that frequently timeout or have connection issues should be avoided.

**Uptime:** Check mirror status page for historical uptime information.

**Bandwidth:** High-bandwidth mirrors handle multiple connections better.

**HTTPS availability:** HTTPS support indicates a well-maintained mirror.

### Troubleshooting Mirror Issues

#### Slow Downloads

**Symptoms:**
- Package downloads are slow
- Updates take excessive time

**Solutions:**

**Regenerate mirrorlist with reflector:**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Try different geographic regions:**
```
sudo reflector --country 'Canada,United_States' --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
```

**Test individual mirrors manually** and disable slow ones in the mirrorlist.

#### Mirror Out of Sync

**Symptoms:**
- Packages not found errors
- Version mismatches
- Database errors

**Solutions:**

**Force database refresh:**
```
sudo pacman -Syy
```

**Select only recently synced mirrors:**
```
sudo reflector --age 6 --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
```

**Check mirror status:**
Visit https://archlinux.org/mirrors/status/ and avoid mirrors with high delay or low completion percentage.

#### Connection Failures

**Symptoms:**
- "Failed to retrieve" errors
- Timeout messages
- Connection refused

**Solutions:**

**Use multiple mirrors:** Keep several mirrors active in the mirrorlist for redundancy:
```
sudo reflector --latest 20 --save /etc/pacman.d/mirrorlist
```

**Switch protocols (HTTPS vs HTTP):**
```
sudo reflector --protocol http --latest 20 --save /etc/pacman.d/mirrorlist
```

**Try different countries:**
```
sudo reflector --country 'Germany,France,Netherlands' --latest 10 --save /etc/pacman.d/mirrorlist
```

### Best Practices

**Regular updates:** Update mirrorlist monthly or when experiencing slow downloads.

**Multiple mirrors:** Keep 10-20 mirrors active for redundancy and load distribution.

**Geographic diversity:** Include mirrors from multiple regions to handle regional outages.

**Protocol preference:** Use HTTPS for security and often better performance.

**Monitor performance:** Periodically check download speeds and adjust as needed.

**Automation:** Use reflector timer for hands-off mirror maintenance.

**Recent sync required:** Prioritize mirrors synced within the last 12-24 hours.

**Backup mirrorlist:** Always backup before making manual changes.

**Test after changes:** Run `pacman -Sy` to verify mirrors work correctly.

**Consider connection type:** WiFi may perform differently than wired; test accordingly.

Proper mirror ranking and selection dramatically improves package management performance, making system updates faster and more reliable.

