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

