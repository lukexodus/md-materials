## Repository System and Mirror Lists


### Repository Concept

A repository is a logical collection of packages that are physically stored on one or more servers. Each server hosting the repository files is called a mirror for the repository. Repositories are defined in `/etc/pacman.conf` where each section (except `[options]`) represents a separate package repository.[1][4]

### Repository Types

#### Official Repositories

Official repositories are maintained by Arch Linux developers and package maintainers. These repositories undergo strict quality control and package verification processes.[3]

#### Unofficial Repositories

Unofficial repositories are maintained by third parties and can be added to `/etc/pacman.conf` to access additional packages not available in official repositories.[1]

### Standard Official Repositories

#### core

The `core` repository is found in `.../core/os/` on mirror servers. This repository contains packages essential for:[3]

- Booting Arch Linux
- Connecting to the Internet
- Building packages
- Management and repair of supported file systems
- System setup processes (e.g., openssh)
- Dependencies of the above packages
- The base meta package

The `core` repository has strict quality requirements where developers and users must sign off on updates before packages are accepted. For low-usage packages, reasonable exposure periods are required, including informing users about updates, requesting signoffs, and keeping packages in core-testing for up to a week depending on change severity.[3]

#### extra

The `extra` repository is found in `.../extra/os/` on mirror servers. This repository contains all packages that do not fit in `core`. It is jointly maintained by Package Maintainers and Arch Developers.[3]

**Examples include:** Xorg, window managers, web browsers, media players, tools for working with languages such as Python and Ruby, and many others.[3]

#### multilib

The `multilib` repository is found in `.../multilib/os/` on mirror servers. This repository contains 32-bit software and libraries that can be used to run and build 32-bit applications on 64-bit installations.[3]

With the `multilib` repository enabled, 32-bit compatible libraries are located under `/usr/lib32/`. The repository is commented out by default and must be manually enabled.[3]

**Enabling multilib:**

Uncomment the `[multilib]` section in `/etc/pacman.conf`:

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```


After enabling, upgrade the system and install desired multilib packages. All multilib packages can be listed with `pacman -Sl multilib`, and 32-bit library package names begin with `lib32-`.[3]

### Repository Precedence

The order of repositories in `/etc/pacman.conf` matters significantly. Repositories listed first take precedence over those listed later when packages in two repositories have identical names, regardless of version number.[4][1]

After adding a new repository, you must upgrade the whole system first before using it.[1]

### Repository Physical Structure

Official repositories use a pool directory structure to avoid duplication. All packages (i686, x86_64, and architecture-independent "any" packages) are stored in the pool directory, such as `ftp://ftp.archlinux.org/pool/`. Symlinks are then placed in the appropriate `$repo/os/$arch/` directories.[2]

The general structure follows:
```
repo/
  os/
    i686/
    x86_64/
```


### Mirror Lists

#### Mirrorlist File Location

Mirror lists for official repositories are stored in `/etc/pacman.d/mirrorlist`. This file contains the list of servers (mirrors) from which packages can be downloaded.[11][1]

#### Mirrorlist Inclusion

Repository sections in `/etc/pacman.conf` typically reference the mirrorlist file using the `Include` directive:[4][1]

```
[core]
Include = /etc/pacman.d/mirrorlist
```


This allows all repositories to share the same mirror list file.[1]

#### Mirror URL Structure

Mirror URLs follow standard naming conventions and support variable interpolation. Common variables include:[5][4]

**$repo:** Expands to the repository name (core, extra, multilib).[5][4]

**$arch:** Expands to the system architecture (x86_64, i686).[5][4]

**Example mirror entry:**
```
Server = http://mirror.us.leaseweb.net/archlinux/$repo/os/$arch
```


During parsing, pacman automatically replaces these variables with appropriate values.[12]

#### Mirror Protocols

Mirrors can use various protocols including HTTP, HTTPS, FTP, and file:// for local directories. Local repository mirrors can be specified using the file:// prefix with the full directory path.[4][5]

### Defining Repository Mirrors

Each repository section allows defining mirrors in two ways:[1]

#### Direct Server Definitions

Mirrors can be listed directly in the repository section using multiple `Server` directives:[4]

```
[core]
Server = ftp://ftp.archlinux.org/$repo/os/$arch
Server = http://mirror.example.com/$repo/os/$arch
```


#### External Mirror Files

Mirrors can be defined in a dedicated external file referenced through the `Include` directive. This is the standard approach for official repositories:[1][4]

```
[core]
Include = /etc/pacman.d/mirrorlist
```


### Mirror Selection Order

When multiple mirrors are specified, pacman tries them in the order listed. If a server is specified directly in the repository section, it is tried before mirrors from included files:[4]

```
[core]
# use this server first
Server = ftp://ftp.archlinux.org/$repo/os/$arch
# next use servers as defined in the mirrorlist below
Include = /etc/pacman.d/mirrorlist
```


### Mirror Configuration

Mirrors must be configured before using pacman for package operations. The default mirror list may be outdated and should be updated with appropriate mirrors based on geographical location and performance.[5]

After modifying the mirrorlist, update all package indexes with `pacman -Syu`.[5]

### Custom Repositories

Custom or personal repositories can be added to `/etc/pacman.conf` by defining new repository sections. Local repositories can be created using `repo-add` and referenced with file:// URLs.[2]

**Example custom repository:**
```
[custom]
Server = file:///home/pkgs
```


### Repository Security

Each repository can define its own signature verification level using the `SigLevel` directive. This overrides the global `SigLevel` setting defined in the `[options]` section.[1]

The default configuration `SigLevel = Required DatabaseOptional` enables signature verification for all packages on a global level. This adds an extra layer of security to package management operations.[1]

### Repository Database

When pacman synchronizes with repositories, it downloads repository database files that contain information about available packages. These databases are stored locally in `/var/lib/pacman/` and allow pacman to perform queries and determine available updates.[13]

### Cache Servers

Repositories can also define `CacheServer` directives to specify alternative cache servers for package downloads. This provides additional flexibility in mirror configuration and can improve download performance.[12]

### Repository Usage Control

The `Usage` directive in repository sections defines how the repository should be used. Options include:[12]

- **Sync:** Use for synchronizing package databases
- **Search:** Use when searching for packages
- **Install:** Use when installing packages
- **Upgrade:** Use when upgrading packages
- **All:** Enable for all operations

This allows fine-grained control over repository usage for different operations.[12]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Location of "any" packages in a local repository structure https://bbs.archlinux.org/viewtopic.php?id=163109
[3] Official repositories - ArchWiki https://wiki.archlinux.org/title/Official_repositories
[4] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[5] How to Use Pacman in Arch Linux https://www.atlantic.net/dedicated-server-hosting/how-to-use-pacman-in-arch-linux/
[6] Arch Linux https://en.wikipedia.org/wiki/Arch_Linux
[7] Arch User Repository - ArchWiki https://wiki.archlinux.org/title/Arch_User_Repository
[8] Install Arch in custom folder structure : r/archlinux https://www.reddit.com/r/archlinux/comments/qbzak6/install_arch_in_custom_folder_structure/
[9] Understanding pacman -Syu Command in Arch Linux https://itsfoss.com/pacman-syu/
[10] How to Use Pacman in Arch Linux https://smarttech101.com/how-to-use-pacman-in-arch-linux
[11] [SOLVED]/etc/pacman.conf and /etc/pacman.d/mirrorlist ... https://bbs.archlinux.org/viewtopic.php?id=278448
[12] pacman.conf(5) - Arch manual pages https://man.archlinux.org/man/pacman.conf.5.en
[13] Change the default location of the database directory https://bbs.archlinux.org/viewtopic.php?id=292182


