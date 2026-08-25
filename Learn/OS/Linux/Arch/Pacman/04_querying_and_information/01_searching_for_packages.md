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

