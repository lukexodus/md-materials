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

