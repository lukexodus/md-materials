## Partial Cache Cleaning


### paccache Options for Selective Cleaning

The `paccache` utility from `pacman-contrib` provides granular control over cache cleaning, allowing retention of specific package versions while removing others.[1][2]

### Controlling Version Retention

#### Keep Specific Number of Versions

**Keep 3 versions (default):**
```
sudo paccache -r
```


This removes all cached versions except the three most recent for each package.[1][2]

**Keep 1 version:**
```
sudo paccache -rk1
```


**Keep 2 versions:**
```
sudo paccache -rk2
```


**Keep 5 versions:**
```
sudo paccache -rk5
```

The `-k` or `--keep` flag specifies how many recent versions to retain.[1][3]

### Targeting Specific Package States

#### Clean Only Uninstalled Packages

**Remove all cached versions of uninstalled packages:**
```
sudo paccache -ruk0
```


This removes every cached version of packages no longer installed on the system. The `-u` or `--uninstalled` flag limits the action to uninstalled packages only.[1][3]

**Keep N versions of uninstalled packages:**
```
sudo paccache -ruk2
```

This keeps the two most recent versions of uninstalled packages, removing older versions.

#### Clean Only Installed Packages

The default behavior (without `-u`) operates only on installed packages.[1]

**Keep 1 version of installed packages only:**
```
sudo paccache -rk1
```


This leaves uninstalled package caches untouched.

### Combined Cleaning Strategies

#### Dual-Phase Approach (Recommended)

A popular strategy combines aggressive cleaning of uninstalled packages with conservative retention for installed packages:[3]

```
sudo paccache -ruk0 && sudo paccache -rk2
```


**Actions performed:**
1. Remove all cached versions of uninstalled packages (`-ruk0`)
2. Keep the two most recent versions of installed packages (`-rk2`)

This balances space savings with downgrade/recovery capabilities.[3]

**Alternative with 3 versions retained:**
```
sudo paccache -ruk0 && sudo paccache -rk3
```

This keeps more versions of installed packages for additional rollback flexibility.

### Custom Package Selection Strategies

#### Keep Both Current and Latest Versions

For advanced scenarios where you want to keep the currently installed version plus the latest cached version, custom scripting is required. Standard `paccache` doesn't support this directly.[4]

**Example scenario:**[4]
```
foo-1.0.1-1.pkg.tar.xz  # ← Installed version
foo-1.0.4-1.pkg.tar.xz  # ← Latest cached version
```

Remove all other intermediate versions.[4]

**Custom solution required:** Write a script that:
1. Identifies the installed version from `pacman -Q`
2. Identifies the newest version in cache
3. Removes all other versions[4]

### Dry Run and Verbose Options

#### Preview Changes Before Cleaning

**Dry run mode:**
```
paccache -dk3
```


The `-d` or `--dryrun` flag shows what would be removed without actually deleting files.[3]

**Combined dry run example:**
```
paccache -dk2 && paccache -duk0
```


This shows space savings from keeping 2 versions of installed packages and removing all uninstalled packages, without performing the actual deletion.[3]

#### Verbose Output

**Verbose mode:**
```
sudo paccache -vrk2
```


The `-v` or `--verbose` flag provides detailed output showing which files are being removed.[3]

**Combined verbose cleaning:**
```
sudo paccache -vrk2 && sudo paccache -vruk0
```


This displays comprehensive information about the cleaning process.[3]

### Cleaning Specific Architectures

#### Filter by Architecture

**Target specific architecture:**
```
paccache -r --arch x86_64
```

This cleans only packages for the specified architecture.

**Multiple architectures:**
```
paccache -r --arch x86_64 --arch i686
```

### Cache Directory Options

#### Specify Custom Cache Directory

**Clean alternative cache location:**
```
paccache -r --cachedir /path/to/cache
```

This cleans packages from a non-standard cache directory instead of the default `/var/cache/pacman/pkg/`.

**Multiple cache directories:**
```
paccache -r --cachedir /var/cache/pacman/pkg/ --cachedir /mnt/backup/pkg/
```

This processes multiple cache locations in a single operation.

### Moving Old Packages Instead of Deleting

#### Archive Old Packages

**Move packages to archive directory:**
```
paccache -m /path/to/archive -rk1
```

The `-m` or `--move` flag moves old packages to the specified directory instead of deleting them. This provides a safety net while still cleaning the active cache.

**Example workflow:**
```
sudo mkdir -p /var/cache/pacman/archive
sudo paccache -m /var/cache/pacman/archive -rk1
```

Old packages are preserved in the archive directory for potential future use.

### Automation with Custom Retention

#### Configure paccache.timer Arguments

Edit the configuration file to customize automated cleaning:[1]

```
sudo nano /etc/conf.d/pacman-contrib
```


**Keep only 1 version:**
```
PACCACHE_ARGS='-k1'
```


**Remove uninstalled packages:**
```
PACCACHE_ARGS='-uk0'
```


**Combined strategy:**
```
PACCACHE_ARGS='-rk2 && paccache -ruk0'
```

After modifying, restart the timer:
```
sudo systemctl restart paccache.timer
```

### Custom Pacman Hooks

#### Hook with Specific Retention

Create a hook with custom retention policy:

```
# /etc/pacman.d/hooks/paccache-custom.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning pacman cache (keep 2 versions)...
When = PostTransaction
Exec = /usr/bin/paccache -rk2
```

**Dual-action hook:**
```
Exec = /bin/sh -c '/usr/bin/paccache -ruk0; /usr/bin/paccache -rk2'
```

This executes both commands after every pacman transaction.

### Cleaning Specific Packages

#### Target Individual Packages

While `paccache` doesn't directly support targeting specific packages, manual removal is possible:

```
rm /var/cache/pacman/pkg/package-name-*.pkg.tar.zst
```

**Keep only the latest:**
```
ls -t /var/cache/pacman/pkg/package-name-*.pkg.tar.zst | tail -n +2 | xargs rm
```

This lists packages sorted by time, skips the first (newest), and removes the rest.

### Best Practices for Partial Cleaning

**Balance retention with space:** Keep 2-3 versions of installed packages for easy rollback.[3]

**Aggressively clean uninstalled:** Packages you don't use provide no benefit.[3]

**Use dry run first:** Always preview with `-d` before executing to avoid accidental deletions.[3]

**Automate conservatively:** Automated cleaning should err on the side of keeping more versions.[1]

**Consider disk space:** On systems with limited storage, keep fewer versions (1-2).[3]

**Large systems with ample space:** Keep more versions (5+) for extensive rollback capability.

**Document custom strategies:** If using complex retention policies, document them for future reference.[4]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] How to Clean Package Cache (`pacman -Sc`) on Arch Linux https://www.siberoloji.com/how-to-clean-package-cache-pacman--sc-on-arch-linux/
[3] Don't forget to clean your pacman cache! - Woefe's Blog https://woefe.com/posts/pacman_cache.html
[4] [solved] Pacman cache: Keep currently installed and ... https://bbs.archlinux.org/viewtopic.php?id=232619
[5] Pacman should auto clean the cache : r/archlinux https://www.reddit.com/r/archlinux/comments/1degfsd/pacman_should_auto_clean_the_cache/
[6] Pacman is BLOATING Up My System! (Cleaning the cache ... https://www.youtube.com/watch?v=wp3LfWwCrZE
[7] Pacman Cheatsheet https://gist.github.com/HFTrader/4fb15d461d86634fd1cba5d251ca7925
[8] Discussion about handling orphaned packages - Page 2 https://forum.garudalinux.org/t/discussion-about-handling-orphaned-packages/30881?page=2
[9] Friendly reminder to do some system maintenance https://forum.endeavouros.com/t/friendly-reminder-to-do-some-system-maintenance/24636

