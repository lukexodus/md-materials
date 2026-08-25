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

