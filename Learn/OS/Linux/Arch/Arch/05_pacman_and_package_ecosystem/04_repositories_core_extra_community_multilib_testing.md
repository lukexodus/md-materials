## Repositories: core, extra, community, multilib, testing


### Official Repositories Overview

**Purpose**: Arch Linux official repositories contain essential and popular software packages, readily accessible via pacman. They are maintained by package maintainers and developers following strict quality standards.[1][4]

**Coherence Principle**: Each repository maintains coherence, meaning all packages within it have mutually compatible versions. This ensures system stability when upgrading.[1]

**Continuous Updates**: Unlike fixed-release distributions, Arch repositories continuously update packages as upstream releases new versions. Old package versions are removed when newer ones arrive.[1]

### Stable Repositories

#### core

**Purpose**: Contains packages essential for a functional Arch Linux base system.[4][1]

**Package Categories**:[1]
- Linux kernel and related components[1]
- CPU microcode updates[1]
- Boot managers and firmware[1]
- Console text editors[1]
- Systemd init system[1]
- Pacman package manager[1]
- Filesystem tools (e2fsprogs, btrfs-progs)[1]
- Base meta package and dependencies[1]

**Quality Requirements**: Core maintains stringent quality standards; developers and users must sign off on updates before acceptance. Packages with low usage receive reasonable exposure in core-testing before promotion.[1]

**Default Status**: **Enabled by default**.[4]

**Stability**: Most conservative repository with thorough testing.[4]

#### extra

**Purpose**: Contains packages not qualifying for core, including user applications and desktop environments.[4][1]

**Package Categories**:[1]
- Xorg display server[1]
- Window managers and desktop environments[1]
- Web browsers[1]
- Media players and tools[1]
- Programming language tools (Python, Ruby, Perl)[1]
- Development utilities[1]

**Quality Standards**: Maintained jointly by Package Maintainers and Arch Developers with less stringent requirements than core. Testing period is shorter than core.[4][1]

**Default Status**: **Enabled by default**.[4]

**Size**: Exponentially larger package count than core.[4]

#### multilib

**Purpose**: Provides 32-bit software and libraries enabling execution and compilation of 32-bit applications on 64-bit x86_64 systems.[4][1]

**Primary Use Cases**:[1]
- Steam gaming platform[1]
- Wine Windows compatibility layer[1]
- Legacy 32-bit applications[1]

**Library Location**: 32-bit compatible libraries are installed under `/usr/lib32/`.[1]

**Package Naming**: Multilib 32-bit library packages begin with `lib32-` prefix.[4][1]

**Default Status**: **Not enabled by default** and requires manual configuration.[4][1]

##### Enabling multilib

**Configuration**: Edit `/etc/pacman.conf` and uncomment the multilib section:[4][1]

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

**Synchronize**: `sudo pacman -Syu` updates package database and installs multilib packages if previously unavailable.[4][1]

**List Packages**: `pacman -Sl multilib` displays all available multilib packages.[1]

##### Disabling multilib

**Remove Packages**: `pacman -Qqm | sudo pacman -Rns -` removes all packages from multilib repository [4].

**Comment Configuration**: Re-comment the `[multilib]` section in `/etc/pacman.conf`.[4]

**Update**: `sudo pacman -Syu` synchronizes and removes multilib packages.[4]

### Testing Repositories

**Purpose**: Testing repositories serve as staging areas for package candidates destined for stable repositories.[6]

**Community Testing**: These repositories allow widespread testing before stable release.[6]

**Available Testing Repos**:[6]
- **core-testing**: Candidates for core repository[6]
- **extra-testing**: Candidates for extra repository[6]
- **multilib-testing**: Candidates for multilib repository[6]

**Usage Caution**: Testing repositories should generally be avoided unless specifically participating in package testing. Packages may be unstable or incomplete.[6][1]

**Enabling Testing**: Uncomment testing repository sections in `/etc/pacman.conf`.[1]

### Special-Purpose Repositories

#### Staging Repositories

**Purpose**: Used for specific rebuilds preventing broken packages in testing repositories.[6]

**Repositories**:[6]
- **core-staging**[6]
- **extra-staging**[6]

**Critical Warning**: **These should not be used under any circumstances**. Systems updating from staging repositories will "unquestionably break".[6]

#### Desktop Environment Unstable

**Purpose**: Provide early access to new desktop environment versions before testing release.[6]

**Repositories**:[6]
- **gnome-unstable**: GNOME packages before testing release[6]
- **kde-unstable**: KDE packages before testing release[6]

**Use Case**: Users wanting cutting-edge GNOME or KDE versions.[6]

### community Repository (Historical)

**Historical Status**: The community repository was historically maintained by Trusted Users and contained popular AUR packages.[5]

**Current Status**: Community repository was merged with extra in May 2023.[6]

**Impact**: All community packages are now in extra; no separate community repository exists.[6]

### Repository Configuration

**Configuration File**: `/etc/pacman.conf` defines enabled repositories and their mirror sources.[5][1]

**Repository Order**: Repository precedence is determined by file order; repositories listed first are prioritized.[11]

**Mirror Configuration**:[5]

```
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
```

### Adding Custom Repositories

**Create Mirror List**: Create a file in `/etc/pacman.d/` for third-party mirrors:[5]

```
# /etc/pacman.d/mirrorlist-custom
Server = https://repository.example.com/$repo/$arch
```

**Configure pacman.conf**:[5]

```
[custom-repo]
Include = /etc/pacman.d/mirrorlist-custom
```

**Security**: Only add trusted repositories; packages are executed with root privileges.[5]

### Repository Statistics

**Official Repository Size**: Arch official repositories contain approximately 11,000 packages.[2]

**AUR Size**: The Arch User Repository contains approximately 55,000 packages.[2]

**Total Software**: Combined official and AUR repositories provide more software than most other distributions.[2]

### Best Practices

**Enable Minimal Repos**: Use only repositories needed for your use case.[4]

**Avoid Testing**: Do not enable testing repositories for production systems.[1]

**Never Use Staging**: Under no circumstances use staging repositories.[6]

**Multilib Only if Needed**: Enable multilib only if 32-bit application support is required.[1]

**Backup Pacman.conf**: Save `/etc/pacman.conf` before modifications.[1]

**Update After Changes**: Always run `sudo pacman -Syu` after repository configuration changes.[4][1]

### Repository Priority and Conflicts

**Explicit Priority**: When multiple repositories have the same package, the repository listed first in `/etc/pacman.conf` takes precedence.[11]

**Version Independence**: Repository priority is based on configuration order, not package version.[11]

**Forcing Repository**: To install from a specific repository: `sudo pacman -S extra/package-name`.[11]

Sources
[1] Official repositories - ArchWiki https://wiki.archlinux.org/title/Official_repositories
[2] Arch repos contain more software than any other distro ... https://www.reddit.com/r/archlinux/comments/179zebv/arch_repos_contain_more_software_than_any_other/
[3] Arch User Repository - ArchWiki https://wiki.archlinux.org/title/Arch_User_Repository
[4] Core, Extra, Multilib? Unraveling the Arch Linux Repositories https://itsfoss.com/arch-linux-repos/
[5] Repositories in Arch Linux: official and AUR https://rs1.es/tutorials/2021/09/01/repositories-arch-linux.html
[6] Arch Linux https://en.wikipedia.org/wiki/Arch_Linux
[7] Linux Repositories Explained: Manage Packages, Updates ... https://serverspace.io/support/help/repositories-in-linux/
[8] A beginner's guide to the Arch User Repository https://tilde.town/~kzimmermann/articles/aur_made_easy.html
[9] General recommendations - ArchWiki https://wiki.archlinux.org/title/General_recommendations
[10] How Do Arch User Repository Packages Become Official? https://www.youtube.com/watch?v=NRCSztR1W7o
[11] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman

