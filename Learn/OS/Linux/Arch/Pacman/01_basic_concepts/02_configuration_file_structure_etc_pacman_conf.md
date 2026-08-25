## Configuration File Structure (`/etc/pacman.conf`)


### File Overview

The `/etc/pacman.conf` file is the main configuration file for the pacman package manager. Pacman, using libalpm, reads this configuration file each time it is invoked. The file controls both global behavior and repository-specific settings.[3]

### Basic Syntax Rules

All directive names must be written in CamelCase. Incorrect casing such as `noupgrade` or `NOUPGRADE` will not be recognized. Comments are supported only by beginning a line with the hash (`#`) symbol and cannot begin in the middle of a line.[11][3]

The configuration file is divided into sections or repositories. Each section is defined by a name within square brackets.[3]

### File Structure

The configuration file consists of two main types of sections: the `[options]` section and repository sections.[3]

### Options Section

The `[options]` section defines global options that apply to pacman's overall behavior. This section appears at the beginning of the configuration file and is the only section that does not define a package repository.[3]

**Key Directives:**

**RootDir:** Specifies the root directory for all pacman operations, defaulting to `/`.[12]

**DBPath:** Sets the database directory path where pacman stores information about installed packages, defaulting to `/var/lib/pacman/`.[12]

**CacheDir:** Defines where pacman stores downloaded package files, defaulting to `/var/cache/pacman/pkg/`. Multiple cache directories can be specified and are tried in the order listed.[1][11]

**LogFile:** Specifies the location of the pacman log file, defaulting to `/var/log/pacman.log`.[11]

**GPGDir:** Sets the directory containing GnuPG configuration files for package signature verification, defaulting to `/etc/pacman.d/gnupg/`.[11]

**HookDir:** Specifies directories to search for alpm hooks in addition to the system hook directory, defaulting to `/etc/pacman.d/hooks/`.[11]

**HoldPkg:** Lists packages that pacman should not remove unless explicitly overridden, typically including critical system packages.[5][3]

**IgnorePkg:** Specifies packages that should not be upgraded during system updates.[13]

**IgnoreGroup:** Lists package groups that should be ignored during updates.[13]

**NoUpgrade:** Prevents specified files from being upgraded, preserving local modifications.[3]

**NoExtract:** Prevents specified files from being extracted from packages during installation.[3]

**Architecture:** Defines the system architecture, typically auto-detected.[3]

**Color:** Enables colored output in pacman.[11]

**TotalDownload:** Shows the total download size in package operations.[11]

**CheckSpace:** Performs a disk space check before installing packages.[11]

**VerbosePkgLists:** Displays additional package information during operations.[11]

**ParallelDownloads:** Enables downloading multiple packages simultaneously, with a numeric value specifying the maximum concurrent downloads.[13]

**SigLevel:** Defines the default signature verification level for packages.[3]

### Repository Sections

Each repository section defines a package repository that pacman can use when searching for packages in sync mode. Repository sections follow the `[options]` section in the configuration file.[3]

**Section Names:**

Repository names are defined by strings within square brackets, such as `[core]` and `[extra]`. Repository names must be unique, and the name `local` is reserved for the database of installed packages.[3]

The order of repositories in the configuration file matters significantly. Repositories listed first take precedence over those listed later when packages in two repositories have identical names, regardless of version number.[3]

**Repository Directives:**

**Server:** Defines the URL location where packages can be found. Multiple `Server` directives can be specified for redundancy. URLs follow standard naming conventions, and local directories can be specified using the `file://` prefix.[3]

**Include:** References an external file containing repository server definitions, commonly used to include mirrorlist files. A typical usage is `Include = /etc/pacman.d/mirrorlist`.[3]

**CacheServer:** Specifies alternative cache servers for package downloads.[3]

**SigLevel:** Overrides the global signature verification level for a specific repository.[3]

**Usage:** Defines how the repository should be used with options including Sync, Search, Install, Upgrade, and All. This allows fine-grained control over repository usage for different operations.[3]

### Variable Interpolation

During parsing, pacman defines the `$repo` variable to the name of the current section. This is commonly utilized in files specified using the `Include` directive so all repositories can use the same mirrorfile.[3]

Pacman also defines the `$arch` variable to the first (or only) value of the Architecture option, allowing the same mirrorfile to be used for different architectures.[3]

**Example:**
```
Server = https://mirror.example.com/$repo/os/$arch
```

This expands to the appropriate repository name and architecture automatically.[3]

### Configuration Example

```
# /etc/pacman.conf
[options]
NoUpgrade = etc/passwd etc/group etc/shadow
NoUpgrade = etc/fstab

[core]
Include = /etc/pacman.d/core

[custom]
Server = file:///home/pkgs
```


### Standard Repository Sections

Typical Arch Linux installations include the following repository sections in order:[8]

**[core]:** Contains essential packages required for a functional base system.[8]

**[extra]:** Provides additional packages that are officially supported.[8]

**[multilib]:** Contains 32-bit libraries for running 32-bit applications on 64-bit systems (optional, commented out by default).[8]

### Validation and Querying

The `pacman-conf` utility can be used to parse and query the configuration file in a script-friendly manner. It properly handles non-trivial configuration features such as variable interpolation and the Include directive.[5]

**Example:**
```
pacman-conf HoldPkg
pacman-conf -r core Usage
pacman-conf --repo-list
```


This utility guarantees output matching the configuration values that pacman itself would use.[5]

### Configuration File Relationship

The `/etc/pacman.conf` file works in conjunction with `/etc/pacman.d/mirrorlist`, which contains the list of servers for official package repositories. The mirrorlist is typically included via the `Include` directive in repository sections.[8][3]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Whats the content of the pacman.config file from a base ... https://www.reddit.com/r/archlinux/comments/rqifft/whats_the_content_of_the_pacmanconfig_file_from_a/
[3] pacman.conf(5) - Arch manual pages https://man.archlinux.org/man/pacman.conf.5.en
[4] pacman.conf https://gist.github.com/setkeh/4221991
[5] pacman-conf(8) - Arch manual pages https://man.archlinux.org/man/core/pacman/pacman-conf.8.en
[6] files/pacman.conf - system.linux.archlinux https://gitlab.mn.tu-dresden.de/sdm/system.linux.archlinux/-/blob/stable/files/pacman.conf
[7] Broken pacman.conf config - KDE https://forum.garudalinux.org/t/broken-pacman-conf-config/28856
[8] [SOLVED]/etc/pacman.conf and /etc/pacman.d/mirrorlist ... https://bbs.archlinux.org/viewtopic.php?id=278448
[9] How to Use Pacman in Arch Linux https://smarttech101.com/how-to-use-pacman-in-arch-linux
[10] Archlinux Cheat Sheet: Configuration Files Pacman Xorg ... https://www.scribd.com/document/379480808/archcheatsheet-pdf
[11] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[12] Change the default location of the database directory https://bbs.archlinux.org/viewtopic.php?id=292182
[13] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks


