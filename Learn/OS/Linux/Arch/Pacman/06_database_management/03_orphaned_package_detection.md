## Orphaned Package Detection


### What Are Orphaned Packages

Orphans are packages that were installed as dependencies and are no longer required by any package. They accumulate through normal system usage when:[1][2][3][4]

- Packages are removed without the `-s` flag (which removes unneeded dependencies)[2]
- System updates (`pacman -Syu`) change package dependencies[2]
- A package no longer requires dependencies it previously needed[2]

**Important:** A system update does not automatically remove orphans. You must explicitly clean them up.[2]

### Basic Orphan Detection

#### List All Orphaned Packages

To list all orphaned packages, use the `-Qdt` flags:[5][6][3][1]

```
pacman -Qdt
```


This displays packages with:
- `-Q` - Query installed packages
- `-d` - Installed as dependencies (not explicitly installed)
- `-t` - Not required by any package (unrequired)

**Output format:**
```
package-name 1.0.0-1
another-package 2.3.1-2
```

#### List Orphans (Names Only)

For scripting or piping to removal commands, use quiet mode:[3][1][2]

```
pacman -Qdtq
```


The `-q` flag shows only package names without versions:
```
package-name
another-package
```

**Important:** The `-q` option is crucial when piping to removal commands, as extra information causes `pacman -R` to error out.[2]

### Including Optional Dependencies

#### Strict Orphan Detection

The basic `-Qdt` command lists only **true orphans**—packages that are not required or optionally required by any package.[1]

#### Include Optional Requirements

To also list packages that are optionally required by another package, pass the `-t` flag twice:[1]

```
pacman -Qdtt
```


This expands the list to include packages that satisfy optional dependencies, not just required dependencies.[1]

### Removing Orphaned Packages

#### Basic Removal Command

To remove all orphaned packages, pipe the list to `pacman -Rns`:[4][3][1][2]

```
sudo pacman -Rns $(pacman -Qdtq)
```


Or using pipe syntax:
```
pacman -Qdtq | sudo pacman -Rns -
```


The `-` at the end tells pacman to read the package list from standard input.[3]

**Breakdown of flags:**
- `-R` - Remove packages
- `-n` - Remove configuration files too
- `-s` - Remove unnecessary dependencies recursively

**Warning:** This command is very aggressive and can include packages that are optional dependencies of other packages.[4]

### Safer Orphan Removal

#### Iterative Removal Method

A safer approach is to run the removal command multiple times without the `-s` flag:[4][6]

```
sudo pacman -R $(pacman -Qdtq)
```


Run this command repeatedly until `pacman -Qdtq` returns nothing. This prevents cascading removals that might affect optional dependencies.[6][4]

#### Automated Iterative Function

Create a function for safer iterative removal:[4]

```bash
orph() {
  while [[ $(pacman -Qdtq) ]]
  do
    sudo pacman -R $(pacman -Qdtq)
  done
}
```


Add this to your shell configuration file (`.bashrc`, `.zshrc`) and run `orph` to safely remove orphans.[4]

### Important Warnings

#### Review Before Removal

**Critical:** Always review the list of orphans carefully before removing them. Some orphaned packages may still be useful:[3][4]

1. Check what will be removed:
   ```
   pacman -Qdtq
   ```

2. Investigate unfamiliar packages:
   ```
   pacman -Qi package_name
   ```

3. Only proceed if you're certain the packages are unneeded

**Not all orphans should be removed:** An orphan is just a package installed as a dependency but no longer required by any package—it doesn't necessarily mean the package is useless.[4]

#### Optional Dependencies Risk

The recursive removal method (`pacman -Rns`) can remove packages that are optional dependencies of other installed packages. While these packages aren't strictly required, they may provide functionality you want to keep.[4]

#### Alternative: Mark as Explicit

Instead of removing an orphaned package, you can mark it as explicitly installed to keep it:[5][4]

```
sudo pacman -D --asexplicit package_name
```


This changes the package's install reason from "dependency" to "explicit," preventing it from appearing in orphan lists.[5]

### Detecting Additional Unneeded Packages

#### Beyond Simple Orphans

Some unneeded packages aren't detected by the standard `-Qdt` method:[1]

- Dependency cycles (circular dependencies)
- Excessive dependencies (fulfilled more than once)
- Some non-explicit optionals

**Advanced detection:**
```
pacman -Qqd | pacman -Rsu --print -
```


This lists all packages installed as dependencies and simulates their removal, showing what can be safely removed.[1][3]

**To remove all at once (dangerous):**
```
pacman -Qqd | pacman -Rsu -
```


**Warning:** This is extremely aggressive. Review the `--print` output first.[1]

#### Duplicate Providers

Detect packages that provide the same item (e.g., multiple font packages):[1]

```
awk '/%(NAME|PROVIDES)%/{flag=1;next}/^$/{flag=0}flag{ printf "%s\t%s\n", FILENAME, $0}' /var/lib/pacman/local/*/desc | sed 's%/var/lib/pacman/local/\(.*\)/desc%\1%g' | sort -k2 | uniq -Df1 | column -etN Package,Provides
```


Review this output and carefully remove redundant packages you don't require.[1]

### Automation and Monitoring

#### Pacman Hook for Orphan Detection

Create a hook to notify when packages become orphaned:[1]

```
# /etc/pacman.d/hooks/orphan-notify.hook
[Trigger]
Operation = Install
Operation = Remove
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Checking for orphaned packages...
When = PostTransaction
Exec = /usr/bin/bash -c "/usr/bin/pacman -Qdt || /usr/bin/echo '=> None found.'"
```


This notifies you after every transaction if orphans are present.[1]

**AUR Package:**
The `pacman-log-orphans-hook` package from AUR provides a more verbose version of this hook.[1]

#### Alias for Quick Cleanup

Create an alias for convenient orphan removal:[4]

```bash
# Add to ~/.bashrc or ~/.zshrc
alias cleanup='sudo pacman -Rns $(pacman -Qdtq)'
```


Then simply run `cleanup` to remove orphans.

### Package Install Reason Tracking

#### How Pacman Tracks Packages

Pacman tracks two types of install reasons:[7][4]

**Explicitly installed:** Packages installed directly by the user with `pacman -S`[9][4]

**Installed as dependency:** Packages installed automatically to satisfy dependencies[7][4]

When a package is no longer required by any explicitly installed package, it becomes an orphan.[4]

#### Checking Install Reason

View a package's install reason:

```
pacman -Qi package_name | grep "Install Reason"
```

**Output:**
```
Install Reason      : Explicitly installed
```
or
```
Install Reason      : Installed as a dependency for another package
```

### Common Workflows

#### After Major Removals

After removing large software suites or desktop environments:

```
sudo pacman -Rns package_name
pacman -Qdt                          # Check for orphans
sudo pacman -Rns $(pacman -Qdtq)   # Remove orphans
```

#### Regular Maintenance

Periodic orphan cleanup as part of system maintenance:

```
# 1. Update system
sudo pacman -Syu

# 2. Check for orphans
pacman -Qdt

# 3. Review and remove
sudo pacman -Rns $(pacman -Qdtq)
```

#### Pre-Removal Verification

Before removing orphans, verify they aren't needed:

```
pacman -Qdtq > orphans.txt          # Save list
cat orphans.txt                     # Review
# Edit orphans.txt to remove packages you want to keep
cat orphans.txt | sudo pacman -R -  # Remove remaining
```

### Best Practices

**Regular checks:** Check for orphans after major package removals or system updates.[2]

**Never automate removal:** Don't automatically remove orphans with hooks or scripts—always review first.[4]

**Use safer methods:** Prefer iterative removal without `-s` over aggressive recursive removal.[4]

**Mark keepers:** If you want to keep an orphan, mark it as explicit rather than repeatedly ignoring it.[5][4]

**Review optional dependencies:** Understand that some orphans may provide optional functionality you want.[4]

**Backup critical systems:** Always maintain backups before bulk package removal operations.[3]

Sources
[1] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[2] Cleaning up unused packages with Pacman https://slar.se/cleaning-up-with-pacman.html
[3] How to remove orphaned unused packages in Arch Linux https://www.cyberciti.biz/faq/delete-remove-orphaned-unused-packages-arch-linux-pacman-command/
[4] Discussion about handling orphaned packages https://forum.garudalinux.org/t/discussion-about-handling-orphaned-packages/30881
[5] Removing unused packages (orphans) command https://www.reddit.com/r/archlinux/comments/1corozn/removing_unused_packages_orphans_command/
[6] How to delete orphaned packages - Pacman vs. Pamac https://forum.endeavouros.com/t/how-to-delete-orphaned-packages-pacman-vs-pamac/45218
[7] how does pacman detect when a package is orphan or " ... https://www.facebook.com/groups/archlinuxen/posts/10155407105783393/
[8] How to use Pacman to automatically remove ... https://www.tencentcloud.com/techpedia/102254
[9] Removing unused packages (orphans) / Pacman & ... https://bbs.archlinux.org/viewtopic.php?id=281968

