## Custom Mirror Configurations


### Mirror Configuration Overview

Mirrors are servers that host copies of Arch Linux package repositories. Pacman uses mirrors listed in `/etc/pacman.d/mirrorlist` to download packages. Properly configured mirrors improve download speeds and reliability.

### Mirrorlist File Location

The default mirrorlist is located at:
```
/etc/pacman.d/mirrorlist
```

This file contains a list of available mirror servers for Arch Linux repositories.

### Mirrorlist File Format

#### Basic Syntax

```
## Comment lines start with ##
## Active mirrors are uncommented
Server = https://mirror.example.com/archlinux/$repo/os/$arch
#Server = https://mirror2.example.com/archlinux/$repo/os/$arch
```

**Key elements:**
- Lines starting with `##` are comments
- Lines starting with `#Server` are disabled mirrors
- Active `Server` lines (no `#`) are used by pacman
- Mirrors are tried in order from top to bottom

#### Variable Substitution

**$repo:** Repository name (core, extra, multilib)
**$arch:** System architecture (x86_64)

Example:
```
Server = https://mirror.example.com/archlinux/$repo/os/$arch
```

Expands to:
```
https://mirror.example.com/archlinux/core/os/x86_64
https://mirror.example.com/archlinux/extra/os/x86_64
```

### Including Mirrorlist in pacman.conf

#### Repository Configuration

In `/etc/pacman.conf`, repositories reference the mirrorlist:

```
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
```

The `Include` directive tells pacman to read mirror URLs from the specified file.

### Manual Mirror Configuration

#### Edit Mirrorlist File

Open the mirrorlist for editing:
```
sudo nano /etc/pacman.d/mirrorlist
```

#### Prioritize Fast Mirrors

Move preferred mirrors to the top of the file. Pacman uses mirrors in order, stopping at the first successful one:

**Example organization:**
```
## United States
Server = https://us-mirror1.archlinux.org/archlinux/$repo/os/$arch
Server = https://us-mirror2.archlinux.org/archlinux/$repo/os/$arch

## Europe
Server = https://eu-mirror1.archlinux.org/archlinux/$repo/os/$arch

## Asia
#Server = https://asia-mirror.archlinux.org/archlinux/$repo/os/$arch
```

#### Comment Out Slow Mirrors

Disable unreliable mirrors by adding `#`:
```
#Server = https://slow-mirror.example.com/archlinux/$repo/os/$arch
```

### Automated Mirror Selection

#### Using Reflector (Arch Linux)

Reflector automatically generates an optimized mirrorlist based on various criteria:

**Install reflector:**
```
sudo pacman -S reflector
```

**Generate mirrorlist:**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Common reflector options:**
- `--latest N` - Use N most recently synced mirrors
- `--protocol https` - Use only HTTPS mirrors
- `--sort rate` - Sort by download rate
- `--sort age` - Sort by last sync time
- `--country 'United States,Canada'` - Filter by country
- `--save /path/to/file` - Save to file
- `--fastest N` - Keep only N fastest mirrors

**Example - Country-specific mirrors:**
```
sudo reflector --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Example - Test speeds:**
```
sudo reflector --latest 50 --protocol https --sort rate --fastest 10 --save /etc/pacman.d/mirrorlist
```

#### Using pacman-mirrors (Manjaro)

Manjaro uses its own mirror management tool:

**Fast-track to best mirrors:**
```
sudo pacman-mirrors --fasttrack
```

**Select by country:**
```
sudo pacman-mirrors --country United_States
```

**Interactive mode:**
```
sudo pacman-mirrors --interactive
```

This presents a GUI for selecting mirrors.

#### Automated Reflector Updates

Enable systemd timer for weekly automatic updates:

**Create reflector configuration:**
```
sudo nano /etc/xdg/reflector/reflector.conf
```

**Example configuration:**
```
--save /etc/pacman.d/mirrorlist
--protocol https
--latest 20
--sort rate
```

**Enable timer:**
```
sudo systemctl enable --now reflector.timer
```

This automatically updates the mirrorlist weekly.

### Direct Server Configuration in pacman.conf

#### Bypass Mirrorlist

Define mirrors directly in `/etc/pacman.conf` without using a mirrorlist file:

```
[core]
Server = https://mirror1.example.com/archlinux/$repo/os/$arch
Server = https://mirror2.example.com/archlinux/$repo/os/$arch

[extra]
Server = https://mirror1.example.com/archlinux/$repo/os/$arch
```

#### Mix Include and Direct Servers

Combine direct servers with mirrorlist:

```
[core]
Server = https://priority-mirror.example.com/archlinux/$repo/os/$arch
Include = /etc/pacman.d/mirrorlist
```

The direct `Server` line is tried first, followed by mirrors from the included file.

### Custom Repository Mirrors

#### Third-Party Repository Configuration

For custom or third-party repositories, specify mirrors directly:

```
[custom-repo]
Server = https://custom-repo.example.com/$arch
Server = https://backup-mirror.example.com/$arch
```

#### Local Mirror Configuration

Use local network mirrors for faster access:

```
[core]
Server = http://192.168.1.100/archlinux/$repo/os/$arch
Include = /etc/pacman.d/mirrorlist
```

The local mirror is tried first, falling back to internet mirrors if unavailable.

#### File Protocol

Use local filesystem as a mirror:

```
[custom-local]
Server = file:///mnt/repo/$arch
```

Useful for offline installations or local package repositories.

### Multiple Mirrorlist Files

#### Separate Mirrorlist for Each Repository

Create repository-specific mirrorlist files:

```
/etc/pacman.d/mirrorlist-core
/etc/pacman.d/mirrorlist-extra
/etc/pacman.d/mirrorlist-multilib
```

Reference them in pacman.conf:
```
[core]
Include = /etc/pacman.d/mirrorlist-core

[extra]
Include = /etc/pacman.d/mirrorlist-extra

[multilib]
Include = /etc/pacman.d/mirrorlist-multilib
```

### Mirror Testing and Selection

#### Test Mirror Speed

Manually test mirror download speeds:

```
curl -o /dev/null https://mirror.example.com/archlinux/core/os/x86_64/core.db
```

Time the download to compare mirrors.

#### Check Mirror Sync Status

Verify mirror freshness:
```
curl -s https://mirror.example.com/archlinux/lastupdate
```

Compare this timestamp with the official Arch repository sync time.

### Troubleshooting Mirror Issues

#### Corrupted Database Errors

If mirrors provide corrupted databases:

**Force refresh:**
```
sudo pacman -Syy
```

**Switch to different mirrors:**
Edit mirrorlist and move reliable mirrors to the top.

#### Slow Downloads

**Switch to geographically closer mirrors:**
```
sudo reflector --country 'YourCountry' --latest 10 --save /etc/pacman.d/mirrorlist
```

**Use faster protocols:**
Prefer HTTPS mirrors over HTTP for better performance in some regions.

#### Mirror Synchronization Delays

Different mirrors sync at different times. If a package isn't available:

**Try multiple mirrors:**
Keep several mirrors active so pacman can fall back to alternatives.

**Wait for sync:**
Newly released packages may take hours to propagate to all mirrors.

### Security Considerations

#### Prefer HTTPS Mirrors

HTTPS provides:
- Encryption during transfer
- Protection against man-in-the-middle attacks
- Integrity verification during download

**Filter for HTTPS only:**
```
sudo reflector --protocol https --latest 20 --save /etc/pacman.d/mirrorlist
```

#### Verify Mirror Authenticity

Mirrors are authenticated through package signatures, not mirror URLs. As long as signature verification is enabled in pacman.conf, packages from any mirror are verified:

```
[options]
SigLevel = Required DatabaseOptional
```

Even if a mirror is compromised, signed packages cannot be tampered with undetected.

### Backup Mirrorlist

Before making changes, backup the current mirrorlist:

```
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
```

Restore if needed:
```
sudo cp /etc/pacman.d/mirrorlist.backup /etc/pacman.d/mirrorlist
```

### Best Practices

**Maintain multiple mirrors:** Keep 5-10 mirrors active for redundancy.

**Regular updates:** Update mirrorlist monthly with reflector or manually.

**Geographic proximity:** Prioritize mirrors in your region for better speeds.

**HTTPS preference:** Use HTTPS mirrors for security and often better performance.

**Test after changes:** Run `pacman -Sy` to verify mirrors work correctly.

**Monitor performance:** If downloads are slow, regenerate mirrorlist.

**Keep backups:** Preserve working mirrorlist configurations.

**Document changes:** Comment reasons for custom mirror selections in the file.

**Automate when possible:** Use reflector timer for hands-off maintenance.

**Handle failures gracefully:** Multiple mirrors ensure download success if one fails.

Proper mirror configuration significantly impacts package management performance, making system updates faster and more reliable.


