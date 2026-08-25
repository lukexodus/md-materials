## Cache Directory Management


### Default Cache Location

Pacman stores downloaded package files in the cache directory specified by the `CacheDir` option in `/etc/pacman.conf`. The default location is `/var/cache/pacman/pkg/`.[1][2][3]

### Configuring Cache Directory

#### Single Cache Directory

To override the default cache location, edit `/etc/pacman.conf`:[2][3]

```
# /etc/pacman.conf
[options]
CacheDir = /path/to/cache/dir
```


**Important notes:**
- This must be an absolute path[2][3]
- The root path is not automatically prepended[3][2]
- The directory must have write permissions for pacman[2]
- Trailing slash is recommended but not required[1]

**Example:**
```
CacheDir = /mnt/storage/pacman/cache/
```

#### Multiple Cache Directories

Multiple cache directories can be specified, and they are tried in the order they are listed:[4][3][2]

**Option 1: Space-separated on one line:**
```
CacheDir = /mnt/external/cache/ /var/cache/pacman/pkg/
```


**Option 2: Multiple lines (recommended):**
```
CacheDir = /mnt/external/cache/
CacheDir = /var/cache/pacman/pkg/
```


**Behavior:**
- When downloading, pacman searches each cache directory in order for existing packages[3][2]
- If a package is not found in any cache directory, it downloads to the first cache directory with write access[2][3]
- Previously downloaded packages in any cache location are reused without re-downloading[2]

### Cache Directory Fallback Strategy

#### Primary and Fallback Locations

A common strategy uses an external drive as primary cache with local fallback:[4]

```
CacheDir = /run/media/username/external-drive/pacman-cache/
CacheDir = /var/cache/pacman/pkg/
```


**Behavior:**
- When external drive is mounted, packages download there[4]
- When external drive is unmounted, packages download to local cache[4]
- Pacman automatically falls back to the second location if the first isn't writable[2]

**Issue:** If the first directory doesn't exist, pacman creates it, which may cause warnings when mounting paths are unavailable.[4]

**Solution:** Use fstab to mount the external location directly to the cache folder when plugged in, so pacman doesn't need to know about physical storage locations.[4]

### Relocating Cache Directory

#### Method 1: Configuration File Change

Update the cache location in `/etc/pacman.conf`:[1]

```
CacheDir = /new/cache/location/
```


**Then move existing cache:**
```
sudo mkdir -p /new/cache/location
sudo mv /var/cache/pacman/pkg/* /new/cache/location/
```


This is the recommended approach for permanent relocation.[1]

#### Method 2: Mounting a Partition

Mount a dedicated partition or filesystem at the default cache location:[1]

```
sudo mount /dev/sdXn /var/cache/pacman/pkg/
```


**Add to `/etc/fstab` for persistence:**
```
/dev/sdXn  /var/cache/pacman/pkg/  ext4  defaults  0  2
```


This keeps the default path while using separate storage.[1]

#### Method 3: Bind Mount

Bind-mount a directory from another location to the default cache path:[1]

```
sudo mount --bind /mnt/storage/cache /var/cache/pacman/pkg/
```


**Add to `/etc/fstab`:**
```
/mnt/storage/cache  /var/cache/pacman/pkg/  none  bind  0  0
```


**Warning:** Do not use symlinks to relocate the cache directory. Symlinks cause pacman to misbehave, especially when pacman attempts to update itself.[1]

### Custom Cache for Special Installations

#### Chroot and Isolated Environments

When managing packages for chroot or isolated environments, specify custom cache locations:[5]

```
# /path/to/environment/etc/pacman.conf
[options]
RootDir = /path/to/environment/
CacheDir = /path/to/environment/var/cache/pacman/
HookDir = /path/to/environment/etc/pacman.d/hooks
GPGDir = /path/to/environment/etc/pacman.d/gnupg
```


**Required directory structure:**
```
/path/to/environment/
├── etc/
│   └── pacman.d/
│       ├── gnupg/
│       └── hooks/
└── var/
    ├── cache/
    │   └── pacman/
    ├── lib/
    │   └── pacman/
    └── log/
```


### Checking Cache Directory Location

#### Display Current Configuration

View the active cache directory with verbose output:

```
pacman -v
```

This shows all configured paths including cache directories.

#### Extract from Configuration File

Parse the configuration file to find cache directories:

```
grep "^CacheDir" /etc/pacman.conf
```

Or get the default if not specified:

```
awk '/^CacheDir/{print $3}' /etc/pacman.conf || echo "/var/cache/pacman/pkg/"
```

### Cache Directory Permissions

#### Required Permissions

The cache directory must be writable by the user running pacman (typically root):

```
sudo chown -R root:root /var/cache/pacman/pkg/
sudo chmod 755 /var/cache/pacman/pkg/
```

**Verify permissions:**
```
ls -ld /var/cache/pacman/pkg/
```

Should show:
```
drwxr-xr-x root root /var/cache/pacman/pkg/
```

### Cache Directory Size Management

#### Check Cache Size

Monitor how much space the cache consumes:

```
du -sh /var/cache/pacman/pkg/
```

**For multiple cache directories:**
```
du -sh /mnt/external/cache/ /var/cache/pacman/pkg/
```

#### Count Cached Packages

Count files in the cache:

```
ls /var/cache/pacman/pkg/ | wc -l
```

### Cleaning Specific Cache Directories

#### Clean Specific Location with paccache

Target a non-default cache directory:

```
paccache -r --cachedir /path/to/cache
```

**Clean multiple cache directories:**
```
paccache -r --cachedir /mnt/external/cache/ --cachedir /var/cache/pacman/pkg/
```

This processes all specified directories in one operation.

### Best Practices

**Use absolute paths:** Always specify full absolute paths in configuration.[3][2]

**Maintain write permissions:** Ensure pacman can write to at least one configured cache directory.[2]

**Order matters:** List preferred cache locations first when using multiple directories.[3][2]

**Avoid symlinks:** Never use symbolic links to redirect the cache directory.[1]

**External storage considerations:** When using external drives, implement proper fallback strategies.[4]

**Consistent structure:** Maintain standard directory structure in custom cache locations.[5]

**Monitor space usage:** Regularly check cache size to prevent disk space exhaustion.

**Clean all cache locations:** Remember to clean all configured cache directories, not just the default.

**Backup strategy:** Include cache directories in backup plans if downgrade capability is important.

**Document custom locations:** Keep records of non-standard cache configurations for system maintenance.

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[3] pacman.conf - pacman package manager configuration file https://manpages.ubuntu.com/manpages/questing/man5/pacman.conf.5.html
[4] How to properly set a second CacheDir in pacman.conf? https://www.reddit.com/r/archlinux/comments/5avvqr/how_to_properly_set_a_second_cachedir_in/
[5] Using pacman to Manage Emscripten Packages https://ignore.pl/2022/06/using_pacman_to_manage_emscripten_packages.html
[6] Change the default location of the database directory https://bbs.archlinux.org/viewtopic.php?id=292182
[7] Clearing Cache with Pacman: Speed Up Arch Linux https://www.linuxactionshow.com/pacman-clear-cache/
[8] Pacman Command To Manage Packages On Arch Linux ... https://www.2daygeek.com/pacman-command-examples-manage-packages-arch-linux-system/

