## Core Pacman Commands and Options


### Pacman Syntax Overview

**Command Structure**: Pacman uses a primary operation flag (uppercase letter) followed by optional modifiers (lowercase letters).[1][5]

**Format**: `pacman [options] [packages]`.[2][3]

**Privileges**: Most pacman operations modifying the system require root privileges via `sudo`.[3]

### Primary Operations

**Sync (`-S`)**: Synchronizes packages with repositories, downloading and installing with dependency resolution.[1][2]

**Query (`-Q`)**: Queries the local package database for information about installed packages.[2][3]

**Remove (`-R`)**: Removes installed packages from the system.[3][2]

**Files (`-F`)**: Searches for files in package databases.[4]

### Installation Commands

**Install Package**: `sudo pacman -S package_name`.[5][2]

**Install Multiple Packages**: `sudo pacman -S package1 package2 package3`.[4][2]

**Install from File**: `sudo pacman -U /path/to/package.pkg.tar.zst` installs a local package file.[3]

**Installation Tracking**: Pacman categorizes installed packages as:[2]
- **Explicitly Installed**: Packages installed via `-S` or `-U` command[2]
- **Dependencies**: Packages automatically installed as requirements[2]

**Mark as Dependency**: `sudo pacman -S --asdeps package_name` installs a package as a dependency, not explicitly.[1]

### Update and Upgrade Commands

**Update Package Database**: `sudo pacman -Sy` refreshes local package cache with repository metadata.[5][3]

**Force Database Refresh**: `sudo pacman -Syy` forces full download even if databases appear current.[3]

**Full System Upgrade**: `sudo pacman -Syu` updates database and upgrades all installed packages.[4][5][2]

**Critical Warning**: Never use partial upgrades like `pacman -Sy` followed by `pacman -S`. Always use `pacman -Syu` for system coherence.[1]

### Removal Commands

**Remove Package**: `sudo pacman -R package_name` removes package while keeping dependencies.[4][2]

**Remove with Dependents**: `sudo pacman -Rc package_name` removes package and all packages depending on it.[5]

**Remove with Dependencies**: `sudo pacman -Rs package_name` removes package and unused dependencies.[5][4][2]

**Combined Removal**: `sudo pacman -Rcs package_name` removes package, dependents, and unused dependencies.[5]

**Remove Configuration**: `sudo pacman -Rn package_name` removes package and its configuration files.[2]

**Remove with Everything**: `sudo pacman -Rns package_name` removes package, dependencies, and configuration.[3]

**Clean Orphans**: `pacman -Qdtq | sudo pacman -Rs -` removes all orphaned dependencies [2][4].

### Query Commands

**Package Information**: `pacman -Qi package_name` displays detailed installed package information.[3][2]

**Remote Package Info**: `pacman -Sii package_name` shows information about available package and dependencies.[3]

**List Package Files**: `pacman -Ql package_name` lists all files installed by package.[5][2]

**Find File Owner**: `pacman -Qo /path/to/file` identifies which package owns a file.[5]

**List Installed Packages**: `pacman -Qn` lists all explicitly installed packages.[3]

**Show Dependencies**: `pacman -Qs package_name` lists locally installed packages matching search term.[3]

**Show Out-of-Date**: `pacman -Qu` lists packages newer than installed versions.[1]

### Search Commands

**Search Repositories**: `pacman -Ss keyword` searches package names and descriptions in repositories.[2][3]

**Search Local**: `pacman -Qs keyword` searches locally installed packages.[4][3]

**Search Files**: `pacman -F query` searches for files in package databases.[4]

**Search Files (Regex)**: `pacman -Fx query` searches using regular expressions.[4]

### Cache Management

**View Cache**: Pacman stores downloaded packages in `/var/cache/pacman/pkg/`.[1]

**Check Disk Usage**: `pacman -Sc` removes uninstalled packages from cache.[1]

**Remove All Cache**: `pacman -Scc` removes all cached packages.[1]

**Configuration**: Edit `CacheDir` in `/etc/pacman.conf` to change cache location.[1]

### Advanced Options

**No Confirmation**: `pacman -S --noconfirm package_name` skips user confirmation prompts.[7]

**Quiet Output**: `pacman -S -q package_name` reduces output verbosity.[7]

**Assume Yes**: `-y` or `--refresh` updates package database implicitly.[7]

**Only Download**: `pacman -Sw package_name` downloads package without installing.[1]

**Show Reason**: `pacman -Qe` lists installed packages and why they were installed.[1]

### Group Management

**Install Package Group**: `sudo pacman -S gnome` installs all packages in a group.[1]

**List Group Contents**: `pacman -Sg group_name` lists all packages in a group.[1]

### Downgrade Packages

**Install Older Version**: Access `/var/cache/pacman/pkg/` for cached old packages and use `pacman -U`.[1]

**Alternative**: Use `downgrade` tool from AUR for easier downgrading.[1]

### Comparison Table

| Command | Purpose | Example |
|---------|---------|---------|
| **`-S`** | Sync/Install [5] | `pacman -S nginx` [5] |
| **`-Sy`** | Update database [5] | `pacman -Sy` [5] |
| **`-Syu`** | Full upgrade [5] | `pacman -Syu` [5] |
| **`-Ss`** | Search remote [2] | `pacman -Ss vim` [2] |
| **`-Q`** | Query local [2] | `pacman -Qi vim` [2] |
| **`-Qs`** | Search local [3] | `pacman -Qs vim` [3] |
| **`-Ql`** | List files [2] | `pacman -Ql vim` [2] |
| **`-R`** | Remove [2] | `pacman -R vim` [2] |
| **`-Rs`** | Remove + deps [5] | `pacman -Rs vim` [5] |
| **`-Rc`** | Remove + dependents [5] | `pacman -Rc vim` [5] |
| **`-F`** | Find file [4] | `pacman -F /bin/ls` [4] |
| **`-Qo`** | Find owner [5] | `pacman -Qo /bin/ls` [5] |

### Best Practices

**Regular Updates**: `sudo pacman -Syu` weekly or biweekly maintains system stability.[2]

**Check Before Removing**: Use `pacman -Qi` before removal to understand dependencies.[5]

**Use Query First**: Search repositories with `pacman -Ss` before installation.[3]

**Clean Periodically**: Run `pacman -Sc` occasionally to free disk space.[1]

**Avoid Partial Upgrades**: Never update database without upgrading packages.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Using pacman Commands in Arch Linux [Beginner's Guide] - It's FOSS https://itsfoss.com/pacman-command/
[3] Pacman Commands Cheat Sheet for Arch Linux - UbuntuMint https://www.ubuntumint.com/archlinux-pacman-cheatsheet/
[4] Pacman command in Arch Linux - GeeksforGeeks https://www.geeksforgeeks.org/linux-unix/pacman-command-in-arch-linux/
[5] Arch Linux pacman – Just the Most Useful Commands - Psycho Cod3r https://psychocod3r.wordpress.com/2021/07/11/arch-linux-pacman-just-the-most-useful-commands/
[6] Basic Pacman Commands for Installing and Searching - YouTube https://www.youtube.com/watch?v=azFEB7Z8y8k
[7] Asking for a Safe pacman command list and good practices ... - Reddit https://www.reddit.com/r/archlinux/comments/1g6ydx8/asking_for_a_safe_pacman_command_list_and_good/
[8] Arch Linux Cheat Sheet: Essential Commands for New Users https://www.tecmint.com/arch-linux-beginner-commands/

