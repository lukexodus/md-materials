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

