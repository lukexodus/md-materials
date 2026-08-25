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

