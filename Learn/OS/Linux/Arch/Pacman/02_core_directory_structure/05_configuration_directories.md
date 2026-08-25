## Configuration Directories


### Primary Configuration Directory

`/etc/pacman.d/` is the main configuration directory for pacman that contains various configuration files and subdirectories. This directory stores supplementary configuration beyond the primary `/etc/pacman.conf` file.[1][2]

### Directory Naming Convention

The `.d` suffix in `pacman.d` follows a Unix/Linux convention for configuration directories. However, unlike many other programs that automatically read all files within `.d` directories, pacman only reads specific files that are explicitly referenced via `Include` directives in `/etc/pacman.conf`. The directory name `pacman.d` was established during the period when adding `.d` to configuration directory names was becoming a standard practice.[3]

### Standard Files and Subdirectories

#### mirrorlist

`/etc/pacman.d/mirrorlist` contains the list of package repository mirrors. This file is typically included by repository sections in `/etc/pacman.conf` using the `Include` directive:[4][5]

```
[core]
Include = /etc/pacman.d/mirrorlist
```

The mirrorlist file contains `Server` directives with mirror URLs using variable substitution for `$repo` and `$arch`.[6][7]

#### gnupg Directory

`/etc/pacman.d/gnupg/` is the default directory containing GnuPG configuration files used for package signature verification. This location can be overridden using the `GPGDir` directive in `/etc/pacman.conf`:[8][1]

```
GPGDir = /etc/pacman.d/gnupg/
```


**Contents include:**
- `pubring.gpg` - Public keys of package maintainers[1]
- `trustdb.gpg` - Trust database for key validation[1]
- GPG configuration files for signature checking[1]

Before first using pacman, the keyring must be initialized with `pacman-key --init` and populated with official keys using `pacman-key --populate archlinux`.[5]

#### hooks Directory

`/etc/pacman.d/hooks/` is the default directory for user-defined alpm hooks. This location can be overridden or supplemented using the `HookDir` directive in `/etc/pacman.conf`:[6][8][1]

```
HookDir = /etc/pacman.d/hooks/
```


Multiple hook directories can be specified, and pacman searches them in the order listed. User-defined hooks in this directory complement system hooks located in `/usr/share/libalpm/hooks/`.[6][1]

### Configuration Hierarchy

The pacman configuration system follows a hierarchical structure:[9][8]

**Main configuration file:**
- `/etc/pacman.conf` - Primary configuration defining global options and repositories[10][8]

**Supporting directory:**
- `/etc/pacman.d/` - Contains supplementary configuration files[2]

**Repository definitions:**
Repository sections in `/etc/pacman.conf` reference files in `/etc/pacman.d/` through `Include` directives.[4][9]

### Directory Path Overrides

All directory paths used by pacman can be overridden in `/etc/pacman.conf`:[4][8]

**RootDir:** Base directory for all pacman operations (default: `/`)[6][1]

**DBPath:** Database directory (default: `/var/lib/pacman/`)[6][1]

**CacheDir:** Package cache directory (default: `/var/cache/pacman/pkg/`)[6][1]

**GPGDir:** GnuPG directory (default: `/etc/pacman.d/gnupg/`)[4]

**HookDir:** Hook directories (default: `/etc/pacman.d/hooks/`)[6][1]

**LogFile:** Log file location (default: `/var/log/pacman.log`)[4]

### Include Mechanism

The `Include` directive in `/etc/pacman.conf` allows referencing external configuration files. This is primarily used to share mirror lists across multiple repository sections:[4][1]

```
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
```


Files referenced by `Include` directives are typically stored in `/etc/pacman.d/` for organizational consistency.[4]

### Custom Repository Files

Custom or unofficial repository definitions can be stored as separate files in `/etc/pacman.d/` and included in `/etc/pacman.conf`. This keeps custom configurations organized and separate from the main configuration file.[9]

**Example:**
Create `/etc/pacman.d/custom-repo` with repository definitions, then reference it:
```
Include = /etc/pacman.d/custom-repo
```


### Directory Structure for Alternative Installations

When using pacman for chroot installations or managing alternative system roots, the configuration directory structure must be replicated within the target root:[11][12]

```
/mnt/targetroot/
└── etc/
    ├── pacman.conf
    └── pacman.d/
        ├── mirrorlist
        ├── gnupg/
        └── hooks/
```

The `--root` or `--sysroot` options control which root directory pacman operates on, and configuration files are expected within that root.[12]

### Testing Repositories

The `/etc/pacman.d/mirrorlist` file also contains mirrors for testing repositories (`[testing]` and `[multilib-testing]`) which are commented out by default. These testing repositories can be enabled by uncommenting their sections in `/etc/pacman.conf` and rely on the same mirrorlist file.[8]

### Viewing Configuration Paths

Pacman can display all active paths including configuration directories using the verbose flag:[12]

```
pacman -v
```


This shows:
- Root directory
- Configuration file location
- Database path
- Cache directories
- GPG directory
- Hook directories

### Configuration File Restoration

If `/etc/pacman.conf` is accidentally modified or deleted, it can be restored from the pacman package. The default configuration is maintained in the pacman package archive and can be extracted or downloaded from the Arch Linux Git repository.[10]

**Recovery command:**
```
pacman -S pacman --overwrite /etc/pacman.conf
```


Alternatively, download the default configuration directly:
```
curl https://gitlab.archlinux.org/archlinux/packaging/packages/pacman/-/raw/main/pacman.conf -o /etc/pacman.conf
```


### Directory Permissions

Configuration directories and files typically require root ownership and appropriate permissions:[10]

- `/etc/pacman.conf` - Owned by root, readable by all
- `/etc/pacman.d/` - Directory owned by root
- `/etc/pacman.d/gnupg/` - Restricted permissions for security
- `/etc/pacman.d/hooks/` - Owned by root, hooks must be properly formatted

### Required Structure for Custom Environments

When setting up isolated or custom pacman environments, the following directory structure is required:[11]

```
/custom/root/
├── etc/
│   ├── pacman.conf
│   └── pacman.d/
│       ├── mirrorlist
│       ├── gnupg/
│       └── hooks/
├── var/
│   ├── lib/
│   │   └── pacman/
│   │       ├── sync/
│   │       └── local/
│   ├── cache/
│   │   └── pacman/
│   │       └── pkg/
│   └── log/
│       └── pacman.log
```


This complete structure ensures pacman can function correctly in non-standard environments.

Sources
[1] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[2] Change the default location of the database directory https://bbs.archlinux.org/viewtopic.php?id=292182
[3] why pacman uses .d so weirdly? https://bbs.archlinux.org/viewtopic.php?id=306113
[4] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[5] [SOLVED]/etc/pacman.conf and /etc/pacman.d/mirrorlist ... https://bbs.archlinux.org/viewtopic.php?id=278448
[6] Installing Pacman in Arch Linux — When You Blow it Up https://blog.stackademic.com/installing-pacman-in-arch-linux-when-you-blow-it-up-aa40778aa237
[7] How to Use Pacman in Arch Linux https://www.atlantic.net/dedicated-server-hosting/how-to-use-pacman-in-arch-linux/
[8] How to Use Pacman in Arch Linux https://smarttech101.com/how-to-use-pacman-in-arch-linux
[9] How to add new software sources using Pacman? https://www.tencentcloud.com/techpedia/102261
[10] Mistakenly cleared all lines in /etc/pacman.conf what ... https://www.reddit.com/r/archlinux/comments/18yzo6l/mistakenly_cleared_all_lines_in_etcpacmanconf/
[11] Using pacman to Manage Emscripten Packages https://ignore.pl/2022/06/using_pacman_to_manage_emscripten_packages.html
[12] pacman(8) https://pacman.archlinux.page/pacman.8.html
[13] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks

