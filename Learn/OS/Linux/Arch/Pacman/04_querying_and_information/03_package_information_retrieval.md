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

