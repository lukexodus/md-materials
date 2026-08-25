## Disk Space Optimization


### Analyzing Disk Usage

#### Check Overall Disk Usage

View disk space usage of all mounted filesystems:[1]

```
df -h
```


This displays human-readable output showing used and available space for each partition.[1]

#### Identify Large Directories

Find which directories consume the most space:[1]

```
sudo du -h --max-depth=1 / | sort -hr
```


This shows top-level directories sorted by size. To dig deeper, change the path or increase `--max-depth`.[1]

#### Graphical Disk Analysis Tools

For visual disk space analysis, install GUI tools:[1]

```
sudo pacman -S baobab       # GNOME Disk Usage Analyzer
sudo pacman -S filelight    # KDE Disk Usage
sudo pacman -S ncdu         # Terminal-based
```


**Using ncdu:**
```
ncdu /
```

This provides an interactive terminal interface for exploring disk usage.

### Package Cache Optimization

#### View Cache Size

Check how much space the package cache consumes:[2][1]

```
du -sh /var/cache/pacman/pkg/
```


Over time, this directory can grow to 5-40+ GB.[2][1]

#### Basic Cache Cleaning

**Remove uninstalled packages:**
```
sudo pacman -Sc
```


This removes all cached packages not currently installed.[2][1]

**Remove all cached packages:**
```
sudo pacman -Scc
```


**Warning:** This deletes all cached packages, including recent ones, removing downgrade and offline reinstall capabilities.[1]

#### Intelligent Cache Management with paccache

Install and use `paccache` for controlled cleaning:[1]

```
sudo pacman -S pacman-contrib
sudo paccache -r
```


By default, this keeps the three most recent versions of each package.[1]

**Keep only the latest version:**
```
sudo paccache -rk1
```


**Remove all uninstalled packages:**
```
sudo paccache -ruk0
```


#### Automate Cache Cleanup

Enable weekly automatic cache cleaning:[1]

```
sudo systemctl enable --now paccache.timer
```


### Orphaned Package Removal

#### List Orphaned Packages

Orphaned packages are dependencies no longer required by any installed package:[1]

```
pacman -Qdt
```


#### Remove Orphaned Packages

Remove orphans along with their dependencies and configuration files:[1]

```
sudo pacman -Rns $(pacman -Qdtq)
```


This can free significant space by removing accumulated unneeded dependencies.[1]

### System Log Optimization

#### Journal Log Cleanup

Systemd journal logs can consume substantial space over time:[1]

**View journal disk usage:**
```
journalctl --disk-usage
```


**Clear logs older than 2 weeks:**
```
sudo journalctl --vacuum-time=2weeks
```


**Limit journal to 100MB:**
```
sudo journalctl --vacuum-size=100M
```


**Permanently limit journal size:**
Edit `/etc/systemd/journald.conf`:
```
SystemMaxUse=100M
```


Then restart the journald service:
```
sudo systemctl restart systemd-journald
```


### Temporary Files Cleanup

#### Clear System Temporary Files

Remove temporary files from `/tmp`:[5][1]

```
sudo rm -rf /tmp/*
```


Note: On most systems, `/tmp` is automatically cleaned on reboot or periodically by systemd.[1]

#### Clear User Cache

Remove user-level cache files:[1]

```
rm -rf ~/.cache/*
```


**Warning:** This may reset application preferences and require re-downloading data.[1]

### AUR Cache Cleanup

#### AUR Helper Cache Locations

AUR helpers maintain their own caches in user directories:[1]

- yay: `~/.cache/yay/`
- paru: `~/.cache/paru/`

#### Clean AUR Caches

**Using yay:**
```
yay -Sc
```


**Using paru:**
```
paru -Sc
```


**Manual cleanup:**
```
rm -rf ~/.cache/yay/*
rm -rf ~/.cache/paru/*
```


### Finding Large Files

#### Locate Files Over Specific Size

Find files larger than 100MB:[1]

```
find / -type f -size +100M 2>/dev/null
```


**Find largest 20 files:**
```
find / -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 20
```

#### Using ncdu for Interactive Search

```
sudo ncdu /
```


Navigate directories interactively and identify large files for deletion.[1]

### Partition Management

#### Root Partition Considerations

A common issue is insufficient root partition space. Pacman stores downloads and databases in `/var` (part of the root partition).[3][4]

**Symptoms:**
```
error: not enough free disk space
```


**Recommended root partition sizes:**
- Minimal: 20-30 GB[4]
- Comfortable: 35-50 GB[4]
- Large installations: 50-70 GB[4]

#### Expanding Root Partition

If root partition is too small:[4]

1. Backup important data
2. Boot into live environment
3. Resize partitions using tools like `gparted`
4. Shrink home partition if necessary
5. Expand root partition into freed space[4]

#### Single vs Separate Partitions

**Traditional approach:** Separate root and home partitions[4][2]

**Alternative:** Single large partition for both root and home[4]

Benefits of single partition:
- Flexible space usage
- No artificial limits
- Simpler management

Considerations:
- Less isolation between system and user data
- More difficult separate backups[4]

### Package Size Analysis

#### Find Largest Installed Packages

Identify which packages consume the most disk space:[5]

```
expac -H M '%m\t%n' | sort -h
```


Or using pacman:
```
pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h
```

This helps identify candidates for removal when space is critical.[5]

### Optional Space-Saving Measures

#### Remove Unused Locales

Install `localepurge` from AUR to delete unused language packs:[1]

```
yay -S localepurge
```


**Warning:** This may break some applications expecting all locales.[1]

#### Remove Unused Man Pages

For extreme minimalism (not recommended):[1]

```
sudo rm -rf /usr/share/man/*
```


This removes offline documentation, making troubleshooting more difficult.[1]

### Comprehensive Cleanup Summary

A complete system cleanup routine:[1]

```bash
# 1. Clean package cache
sudo paccache -r
sudo paccache -ruk0

# 2. Remove orphaned packages
sudo pacman -Rns $(pacman -Qdtq)

# 3. Clean journal logs
sudo journalctl --vacuum-time=2weeks

# 4. Clean temp files
sudo rm -rf /tmp/*
rm -rf ~/.cache/*

# 5. Clean AUR cache
yay -Sc
# or
paru -Sc

# 6. Check remaining disk usage
df -h
```


### Automation and Maintenance

#### Create Cleanup Script

Automate the cleanup process with a comprehensive script:[6]

```bash
#!/bin/bash
# /usr/local/bin/disk-cleanup

echo "Starting disk cleanup..."

# Clean pacman cache
echo "Cleaning pacman cache..."
paccache -rk2
paccache -ruk0

# Remove orphans
echo "Removing orphaned packages..."
ORPHANS=$(pacman -Qdtq)
if [ -n "$ORPHANS" ]; then
  sudo pacman -Rns $ORPHANS --noconfirm
else
  echo "No orphans found"
fi

# Clean journal
echo "Cleaning journal logs..."
journalctl --vacuum-time=2weeks

# Clean AUR caches
if command -v yay &> /dev/null; then
  echo "Cleaning yay cache..."
  yay -Sc --noconfirm
fi

if command -v paru &> /dev/null; then
  echo "Cleaning paru cache..."
  paru -Sc --noconfirm
fi

# Show results
echo "Disk cleanup complete!"
df -h /
```


#### Schedule Regular Maintenance

Use cron or systemd timers to run cleanup regularly:[6]

```
# Weekly cleanup (add to crontab)
0 3 * * 0 /usr/local/bin/disk-cleanup
```


### Best Practices

**Regular maintenance:** Clean caches and orphans weekly or monthly.[1]

**Monitor disk usage:** Check `df -h` regularly to catch space issues early.[4][1]

**Adequate root partition:** Allocate at least 30-50 GB for root to avoid space constraints.[4]

**Conservative cache retention:** Keep 2-3 package versions for rollback capability.[1]

**Automate when possible:** Use systemd timers and hooks to maintain the system automatically.[1]

**Document customizations:** Keep records of space optimization strategies for consistency.

Sources
[1] How to Free Up Disk Space on Arch Linux | Siberoloji https://www.siberoloji.com/how-to-free-up-disk-space-on-arch-linux/
[2] Pacman, don't eat my disk space - Random Determinism https://randomdeterminism.wordpress.com/2009/04/12/pacman-dont-eat-my-disk-space/
[3] [Resolved] Pacman insufficient storage despite active space check ... https://bbs.archlinux.org/viewtopic.php?id=290740
[4] pacman complains about not enough free disk space : r/archlinux https://www.reddit.com/r/archlinux/comments/j3d9gm/pacman_complains_about_not_enough_free_disk_space/
[5] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[6] Pacman is BLOATING Up My System! (Cleaning the cache in Arch ... https://www.youtube.com/watch?v=wp3LfWwCrZE
[7] Improving performance - ArchWiki https://wiki.archlinux.org/title/Improving_performance
[8] How to allocate space for root and home partitions in Arch Linux? https://www.facebook.com/groups/linux.fans.group/posts/24748692378079211/


