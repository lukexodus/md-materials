## Cache Cleaning Strategies


### Understanding the Package Cache

The package cache in `/var/cache/pacman/pkg/` stores all downloaded packages. Pacman does not automatically remove old or uninstalled package versions, causing the directory to grow indefinitely without manual intervention. Over time, this can consume significant disk space—users commonly report 10-40GB of cached packages.[1][2][3][4]

### Why Keep the Cache

**Downgrading capability:** Allows reverting to previous package versions without downloading from archives.[2][4]

**Offline reinstallation:** Enables reinstalling packages without internet access.[4]

**System recovery:** Provides a local backup of packages for emergency restoration.[4]

**Tradeoff:** Balancing disk space against recovery/downgrade capabilities requires periodic cleaning.[4]

### Method 1: Using paccache (Recommended)

#### Basic paccache Command

The `paccache` script from `pacman-contrib` is the recommended method for cache cleaning:[3][2][4]

```
sudo paccache -r
```


**Default behavior:** Removes all cached versions of packages except the three most recent versions. This strikes a balance between saving space and retaining downgrade/reinstall capabilities.[3][2][4]

#### Install pacman-contrib

If `paccache` is not available, install it first:[3][4]

```
sudo pacman -S pacman-contrib
```


#### Customizing Retention Count

**Keep only one version:**
```
sudo paccache -rk1
```


This keeps only the most recent version of each installed package and removes all others.[2][4]

**Keep two versions:**
```
sudo paccache -rk2
```

**Keep five versions:**
```
sudo paccache -rk5
```

The `-k` flag specifies how many recent versions to retain.[2]

#### Remove Uninstalled Packages

**Remove all cached versions of uninstalled packages:**
```
sudo paccache -ruk0
```


The `-u` flag limits the action to uninstalled packages, and `-k0` keeps zero versions (removes all).[4][2]

#### Combined Strategy (Most Popular)

A highly recommended combination removes uninstalled packages completely while keeping recent versions of installed packages:[1]

```
sudo paccache -ruk0 && sudo paccache -rk3
```


This two-step approach:
1. Removes all cached versions of uninstalled packages
2. Keeps the three most recent versions of installed packages

### Method 2: Using Pacman Built-in Options

#### pacman -Sc (Moderate Cleaning)

Remove all cached packages that are not currently installed:[5][2][4]

```
sudo pacman -Sc
```


**Actions performed:**
- Removes all uninstalled package files from cache[4]
- Keeps only packages that are currently installed[4]
- Removes unused repository databases[4]

**Confirmation prompt:**
```
Do you want to remove all other packages from cache? [y/N]
Do you want to remove unused repositories? [Y/n]
```


**Limitation:** Unlike `paccache`, this command does not offer the option to keep multiple versions of installed packages—it removes all uninstalled package versions entirely.[2][4]

#### pacman -Scc (Aggressive Cleaning)

Remove all cached packages, including those currently installed:[5][2][4]

```
sudo pacman -Scc
```


**Actions performed:**
- Deletes **all** cached packages (installed or not)[4]
- Deletes all repository databases[4]
- Completely empties `/var/cache/pacman/pkg/`[5]

**WARNING:** This is extremely aggressive and should only be used when desperate for space. After running this:[4]
- Cannot downgrade packages without redownloading
- Cannot reinstall packages offline
- Must redownload packages if corruption occurs[4]

**Double confirmation required:**
```
Do you want to remove all files from cache? [y/N]
Do you want to remove unused sync repositories? [y/N]
```


### Automation Strategies

#### Automated Weekly Cleaning with Timer

Enable the systemd timer to automatically clean the cache weekly:[3][2]

```
sudo systemctl enable --now paccache.timer
```


This runs `paccache -r` weekly, keeping the three most recent versions by default.[2]

#### Configure Timer Arguments

Customize the timer behavior by editing the configuration file:[2]

```
sudo nano /etc/conf.d/pacman-contrib
```


**Examples:**
```
PACCACHE_ARGS='-k1'      # Keep only 1 version
PACCACHE_ARGS='-uk0'     # Remove all uninstalled packages
PACCACHE_ARGS='-rk2'     # Keep 2 versions
```


After modifying, reload the timer:
```
sudo systemctl restart paccache.timer
```

#### Pacman Hook for Automatic Cleaning

Create a hook to run paccache automatically after every pacman transaction:[6][7][2]

**Install from AUR:**
```
yay -S paccache-hook
```


**Manual hook creation:**
```
# /etc/pacman.d/hooks/paccache.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk3
```


This executes after every package operation, automatically keeping the cache under control.[6]

**More aggressive hook (remove uninstalled):**
```
Exec = /usr/bin/paccache -ruk0
```


#### Cron Job Automation

Schedule regular cache cleaning with cron:[6]

```
sudo crontab -e
```

**Weekly cleanup (every Sunday at 3 AM):**
```
0 3 * * 0 /usr/bin/paccache -rk3
```


**Monthly cleanup (first day of month):**
```
0 3 1 * * /usr/bin/paccache -rk2
```

### Cleaning AUR Helper Caches

#### AUR Helper Cache Locations

AUR helpers maintain separate caches that must be cleaned independently:[8][6]

**yay cache:**
```
~/.cache/yay/
```


**paru cache:**
```
~/.cache/paru/
```


#### Built-in AUR Helper Cleaning

**Using yay:**
```
yay -Sc     # Clean uninstalled AUR packages
yay -Scc    # Clean all AUR cache
```


**Clean after every operation:**
```
yay -S package --cleanafter
```


**Using paru:**
```
paru -Sc    # Clean uninstalled AUR packages
paru -Scc   # Clean all AUR cache
```

#### Manual AUR Cache Cleaning

Remove all AUR build files and cached packages:[6]

```
rm -rf ~/.cache/yay/*
rm -rf ~/.cache/paru/*
```


### Advanced Cache Management Scripts

#### Combined Cleanup Script

Create a comprehensive cleanup script:[6]

```bash
#!/bin/bash
# /usr/local/bin/paccache-clear

# Clean pacman cache (keep 3 versions)
echo "Cleaning pacman cache..."
paccache -rk3

# Clean uninstalled packages
echo "Removing uninstalled packages from cache..."
paccache -ruk0

# Clean yay cache
if command -v yay &> /dev/null; then
  echo "Cleaning yay cache..."
  yay -Sc --noconfirm
fi

# Clean paru cache
if command -v paru &> /dev/null; then
  echo "Cleaning paru cache..."
  paru -Sc --noconfirm
fi

echo "Cache cleaning complete!"
```


Make it executable:
```
sudo chmod +x /usr/local/bin/paccache-clear
```

Run with:
```
sudo paccache-clear
```

### Cache Size Monitoring

#### Check Cache Size

View the current cache size:[3][6]

```
du -sh /var/cache/pacman/pkg/
```


**Detailed breakdown:**
```
du -h /var/cache/pacman/pkg/ | tail -1
```

#### Count Cached Packages

Count how many package files are cached:

```
ls /var/cache/pacman/pkg/ | wc -l
```

#### List Largest Cached Packages

Identify which packages consume the most space:

```
du -h /var/cache/pacman/pkg/* | sort -h | tail -20
```

This shows the 20 largest cached package files.

### Best Practices

**Regular cleaning:** Clean the cache weekly or monthly to prevent excessive growth.[7][3]

**Conservative retention:** Keep at least 2-3 recent versions to enable easy downgrading if issues arise.[1][4]

**Automate the process:** Use systemd timers or pacman hooks to avoid manual intervention.[2][6]

**Clean uninstalled packages aggressively:** These provide no benefit since the packages aren't on your system.[1]

**Avoid -Scc unless necessary:** The aggressive cleaning removes all downgrade/recovery capabilities.[4]

**Monitor disk space:** Regularly check cache size to identify when cleaning is needed.[6]

**Include AUR caches:** Don't forget to clean AUR helper caches separately.[6]

Sources
[1] clear your pacman cache. I freed 40 GB by clearing mine https://www.reddit.com/r/archlinux/comments/q8e6lx/psa_clear_your_pacman_cache_i_freed_40_gb_by/
[2] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[3] How To Clean The Package Cache In Arch Linux https://ostechnix.com/recommended-way-clean-package-cache-arch-linux/
[4] How to Clean Package Cache (`pacman -Sc`) on Arch Linux https://www.siberoloji.com/how-to-clean-package-cache-pacman--sc-on-arch-linux/
[5] [SOLVED] Question about cleaning the package cache https://bbs.archlinux.org/viewtopic.php?id=285219
[6] Pacman is BLOATING Up My System! (Cleaning the cache ... https://www.youtube.com/watch?v=wp3LfWwCrZE
[7] Friendly reminder to do some system maintenance https://forum.endeavouros.com/t/friendly-reminder-to-do-some-system-maintenance/24636
[8] Clearing cache? · Issue #772 · Jguer/yay https://github.com/Jguer/yay/issues/772

