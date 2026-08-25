## Cache Directory (`/var/cache/pacman/pkg/`)


### Directory Purpose and Location

`/var/cache/pacman/pkg/` is the default location where pacman stores downloaded package files. This directory is defined by the `CacheDir` option in the `[options]` section of `/etc/pacman.conf`. The cache directory serves as a local repository of package files that have been downloaded from remote mirrors.[1][4][6]

### Package File Format

Downloaded packages are stored as `.pkg.tar.zst` files (or other supported compression formats like `.pkg.tar.xz`, `.pkg.tar.gz`). These are complete binary packages ready for installation or reinstallation without requiring network access.[3][4]

### Cache Behavior

Pacman does not remove old or uninstalled package versions automatically. When packages are installed or upgraded, the downloaded files remain in the cache directory indefinitely unless manually cleaned. This means the cache grows continuously over time as packages are installed, updated, and upgraded.[9][1][3]

### Advantages of Caching

#### Downgrading Capability

The cache allows downgrading packages without retrieving previous versions through other means such as the Arch Linux Archive. If a newer package version causes problems, reverting to an older cached version is straightforward.[1]

#### Offline Reinstallation

Packages that have been uninstalled can be easily reinstalled directly from the cache directory without requiring a new download from the repository. This is particularly useful for systems with limited or unreliable network connectivity.[3][1]

#### Recovery and Troubleshooting

The cache provides a safety net for system recovery, allowing reinstallation of specific package versions that were previously working.[1][3]

### Cache Growth Management

The cache directory can grow indefinitely if not managed. It is necessary to deliberately clean up the cache periodically to prevent the directory from growing to unmanageable sizes. Users frequently report cache directories consuming 10-30+ GB of disk space when left unmanaged.[9][3][1]

### Cleaning the Cache

#### Using pacman -Sc

The command `pacman -Sc` removes all cached packages that are not currently installed. This provides a moderate level of cache cleaning while preserving packages for currently installed software.[3]

#### Using pacman -Scc

The command `pacman -Scc` removes all cached files regardless of installation status. This completely empties the cache directory, freeing maximum disk space but removing the ability to downgrade or reinstall without downloading.[3]

**Warning:** This operation prompts for confirmation and will remove all package cache files.[3]

#### Using paccache

The `paccache` script, provided in the `pacman-contrib` package, offers more granular cache management. By default, it deletes all cached versions of installed and uninstalled packages except for the most recent three versions.[1]

**Key features:**
- Preserves multiple recent versions for rollback capability
- Can be configured to retain different numbers of versions
- Handles both installed and uninstalled packages
- Can be automated via systemd timers or cron jobs[7]

**Example usage:**
```
paccache -r
paccache -rk1  # Keep only 1 version
paccache -ruk0 # Remove all uninstalled packages
```


The `-c` switch allows specifying a custom cache directory when using paccache if the location differs from the default.[2]

### Multiple Cache Directories

Multiple cache directories can be specified in `/etc/pacman.conf`, and they are tried in the order listed. If a package file is not found in any cache directory, it will be downloaded to the first cache directory with write access.[6]

**Configuration example:**
```
CacheDir = /var/cache/pacman/pkg/
CacheDir = /mnt/storage/pacman/cache/
```


This configuration allows distributing package cache across multiple filesystems or storage devices.[6]

### Cache Directory Path Configuration

The cache directory location can be overridden in `/etc/pacman.conf` using the `CacheDir` directive:[6]

```
CacheDir = /path/to/cache/dir
```


This is an absolute path, and the root path is not automatically prepended. When changing the cache directory location, the trailing slash must be retained.[2][6][1]

### Relocating the Cache Directory

If relocating the cache directory to a more convenient location, several methods are available:[1]

#### Recommended: CacheDir Configuration

Set the `CacheDir` option in `/etc/pacman.conf` to the new directory path. This is the recommended solution for changing cache location.[1]

#### Mounting Dedicated Storage

Mount a dedicated partition or Btrfs subvolume at `/var/cache/pacman/pkg/`. This approach keeps the default path while using separate storage.[1]

#### Bind Mounting

Bind-mount a selected directory to `/var/cache/pacman/pkg/`. This provides flexibility in storage location while maintaining the standard path.[1]

**Warning:** Do not symlink `/var/cache/pacman/pkg/` to another location. This will cause pacman to misbehave, especially when pacman attempts to update itself.[1]

### Querying Cache Directory Location

The current cache directory can be displayed using:[8]

```
pacman -v
```

This shows comprehensive configuration information including cache directories.[8]

For scripting purposes, the cache directory can be extracted with:[8]

```
pacman -v | grep Cache | awk '{print $3}'
```

Alternatively, when using the default config file location:[8]

```
awk '/Cache/ {print $3}' /etc/pacman.conf
```

### Cache Directory Structure

The cache directory itself is a flat structure containing package files. Package files are named according to the pattern:[4]

```
packagename-version-release-architecture.pkg.tar.compression
```

**Example:**
```
firefox-120.0-1-x86_64.pkg.tar.zst
linux-6.5.9.arch2-1-x86_64.pkg.tar.zst
```

### Download and Copy Behavior

When pacman installs or updates packages, it downloads (or in the case of a local repository, copies) the `.pkg.tar.zst` file to the cache directory. The package is then extracted and installed from this cached copy.[4]

### AUR Helper Caches

AUR helpers such as `yay` and `paru` maintain their own separate cache directories, typically in `~/.cache/yay/` or `~/.cache/paru/`. These caches store both downloaded source files and built packages, and must be cleaned separately from the pacman cache.[7]

### Automation of Cache Cleaning

Cache cleaning can be automated through several mechanisms:[7]

#### Systemd Timers

Create a systemd timer unit to run `paccache` periodically, such as weekly or monthly.[7]

#### Pacman Hooks

Implement pacman hooks that automatically clean the cache after every package operation or after specific triggers.[7]

#### Cron Jobs

Schedule `paccache` execution via cron for regular cleanup on a defined schedule.[7]

### Cache and System Snapshots

The package cache directory is useful for system restore scenarios. When combined with system snapshots, the cache enables rolling back to previous package versions even if repository mirrors no longer host those specific versions.[1]

### Required Directory Structure

When setting up custom pacman environments, the cache directory structure must be created properly:[5]

```
var/
└── cache/
    └── pacman/
        └── pkg/
```


For isolated or chroot environments, the `CacheDir` configuration must point to the correct location within the alternate root.[5]

### Write Access Requirements

Pacman requires write access to at least one configured cache directory. If multiple cache directories are specified, pacman attempts to use each in order until finding one with write permissions. Downloaded packages are saved to the first writable cache directory.[6]

### Impact on Disk Space

The cache directory is frequently one of the largest directories on an Arch Linux system. Users with limited disk space, particularly on root partitions, should implement regular cache cleaning strategies to prevent storage exhaustion.[9][3]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] [Solved] Replacing package cache directory for pacman / ... https://bbs.archlinux.org/viewtopic.php?id=178652
[3] what is /var/cache/package/pkg and why is it so large? https://www.reddit.com/r/archlinux/comments/1hgbl1k/what_is_varcachepackagepkg_and_why_is_it_so_large/
[4] [Solved] How does pacman cache work? https://bbs.archlinux.org/viewtopic.php?id=270466
[5] Using pacman to Manage Emscripten Packages https://ignore.pl/2022/06/using_pacman_to_manage_emscripten_packages.html
[6] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[7] Pacman is BLOATING Up My System! (Cleaning the cache ... https://www.youtube.com/watch?v=wp3LfWwCrZE
[8] How to print the pacman cache directory ... https://bbs.archlinux.org/viewtopic.php?id=112379
[9] Why does pacman always have a huge cache? : r/archlinux https://www.reddit.com/r/archlinux/comments/1myqlss/why_does_pacman_always_have_a_huge_cache/

