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

