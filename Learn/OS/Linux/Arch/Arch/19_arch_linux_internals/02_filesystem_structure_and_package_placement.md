## Filesystem Structure and Package Placement


### Filesystem Hierarchy Overview[1]

Arch Linux follows the **Filesystem Hierarchy Standard (FHS)** combined with systemd conventions, organizing the filesystem into a clear hierarchy from the root directory `/`. This structure separates vendor-supplied operating system resources from variable runtime and configuration data, enabling predictable file organization and system maintenance.[1]

### Root-Level Directories[1]

| Directory | Purpose |
|-----------|---------|
| `/` | Root directory; base point of entire filesystem hierarchy [1] |
| `/boot/` | Bootloader files and kernel images [1] |
| `/efi/` | EFI system partition mounted point [1] |
| `/etc/` | System-wide configuration files [1] |
| `/home/` | User home directories (typically under `$HOME` environment variable) [1] |
| `/root/` | Root user home directory (distinct from `/`) [1] |
| `/srv/` | Data for services provided by the system [1] |
| `/tmp/` | Temporary files accessible to all users; should be created with `mkstemp(3)` or `mkdtemp(3)` [1] |

### Vendor-Supplied Operating System Resources[1]

#### `/usr/` Hierarchy

The `/usr/` directory contains **read-only vendor-supplied application resources**. The directory originated as an overflow location when system storage filled up and now represents the primary location for installed applications.[2][1]

| Directory | Purpose |
|-----------|---------|
| `/usr/bin/` | User-executable binaries that appear in the `$PATH` search path; includes utilities invoked from shell [1] |
| `/usr/lib/` | Libraries for primary system architecture; referenced via `systemd-path system-library-arch` [1] |
| `/usr/lib/` *arch-id*`/` | Multiarchitecture-specific libraries where `arch-id` follows Multiarch Architecture Specifiers (e.g., `x86_64-linux-gnu`) [1] |
| `/usr/share/` | Read-only architecture-independent data shared across multiple packages [1] |
| `/usr/share/doc/` | Package documentation [1] |
| `/usr/share/factory/etc/` | Template configuration files for factory defaults [1] |

#### Legacy Compatibility Symlinks

The `/bin/`, `/sbin/`, and `/usr/sbin/` directories are now **symlinks pointing to `/usr/bin/`** for backward compatibility. Similarly, `/lib/` and `/lib64/` symlink to `/usr/lib/` to maintain ABI compatibility with binaries referencing legacy dynamic loader paths.[1]

### Persistent Variable System Data[1]

The `/var/` hierarchy contains **data that changes during runtime**:[1]

| Directory | Purpose |
|-----------|---------|
| `/var/cache/` | Package cache, application cache files; can be safely deleted if applications can recreate them [1] |
| `/var/lib/` | Persistent private data for packages and system services [1] |
| `/var/log/` | System and application log files [1] |
| `/var/tmp/` | Temporary files preserved across reboots (unlike `/tmp/`); security restrictions identical to `/tmp/` [1] |

### Runtime Data[1]

The `/run/` directory contains **volatile runtime data** created at boot and cleared on shutdown:[1]

| Directory | Purpose |
|-----------|---------|
| `/run/` | Runtime data for services and daemons; always writable [1] |
| `/run/log/` | Runtime log data [1] |
| `/run/user/` | Per-user runtime directories corresponding to `$XDG_RUNTIME_DIR` environment variable [1] |

### Pacman Package Placement[3]

Pacman-managed packages are placed according to FHS standards described above. Query installed file locations with:[3]

```
$ pacman -Ql package_name
```

Query which package owns a specific file:[3]

```
$ pacman -Qo /path/to/file
```

For remote packages, check file ownership:[3]

```
$ pacman -F /path/to/file
```

### Package Cache Directory[3]

Pacman stores downloaded package archives in `/var/cache/pacman/pkg/` by default. This directory **is never automatically cleaned**, allowing downgrades and reinstallation from cache.[3]

**Important:** Do **not** symlink the cache directory; it will cause pacman to misbehave during self-upgrades. Instead, modify the `CacheDir` option in `/etc/pacman.conf`:[3]

```
CacheDir=/path/to/cache/
```

Clean cache with `paccache` from pacman-contrib, which by default keeps 3 recent versions:[3]

```
# paccache -r
# paccache -rk1        # Keep only 1 version
# paccache -ruk0       # Remove all uninstalled packages
```

### User Home Directory Structure[1]

Applications following **XDG Base Directory Specification** place user files in standardized locations:[1]

| Directory | Purpose |
|-----------|---------|
| `~/.cache/` | Cache files; `$XDG_CACHE_HOME` if set [1] |
| `~/.config/` | User configuration; `$XDG_CONFIG_HOME` if set [1] |
| `~/.local/bin/` | User executables appearing in `$PATH`; `~/.local/lib/` for private libraries [1] |
| `~/.local/share/` | User-specific shared data; `$XDG_DATA_HOME` if set [1] |
| `~/.local/state/` | User persistent state data; `$XDG_STATE_HOME` if set [1] |

### Optional Package Installations[4][5]

Packages not in the official repositories may be installed in alternative locations. The `/usr/local/` hierarchy (distinct from `/usr/local/share`) serves **as a reserved location for system-administrator-installed software** outside pacman management. For third-party or self-compiled packages, `/opt/` is an appropriate choice when `/usr/local/` is not suitable.[5][4]

### Write Access Restrictions[1]

**Unprivileged write access** is restricted to specific directories:[1]

- `/tmp/` and `/var/tmp/` (should mount `nosuid,nodev`)
- `/dev/shm/` (shared memory)
- User home directory (`$HOME`)
- User runtime directory (`$XDG_RUNTIME_DIR`)

Root users can write anywhere in the hierarchy, but most of `/usr/` and `/etc/` should only be modified by package managers or administrators.[1]

Related topics: XDG Base Directory Specification compliance for application development; Pacman hooks for automatic file placement during installation; mount options for security hardening of temporary filesystems.

Sources
[1] file-hierarchy(7) - Arch manual pages https://man.archlinux.org/man/file-hierarchy.7.en
[2] The Filesystem Hierarchy Standard | What The Hack https://microsoft.github.io/WhatTheHack/020-LinuxFundamentals/Student/resources/fhs.html
[3] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[4] Install in /usr or /opt? / Creating & Modifying Packages / ... https://bbs.archlinux.org/viewtopic.php?id=151925
[5] ~/.local vs /usr/bin : r/archlinux https://www.reddit.com/r/archlinux/comments/s0ftln/local_vs_usrbin/
[6] Why does the standard Arch filesystem hierarchy not ... https://www.reddit.com/r/archlinux/comments/2woytm/why_does_the_standard_arch_filesystem_hierarchy/
[7] Filesystem Hierarchy Standard https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
[8] Linux File Hierarchy Structure https://www.geeksforgeeks.org/linux-unix/linux-file-hierarchy-structure/
[9] Filesystem Hierarchy Standard https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index
[10] Package installation directory / Newbie Corner ... https://bbs.archlinux.org/viewtopic.php?id=162635


