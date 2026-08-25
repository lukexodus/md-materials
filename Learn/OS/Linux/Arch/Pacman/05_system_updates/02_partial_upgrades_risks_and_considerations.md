## Partial Upgrades (Risks and Considerations)


### Definition of Partial Upgrades

A partial upgrade occurs when the package database is synchronized but the full system upgrade is not completed, leading to mismatched package versions. This happens when running `pacman -Sy` followed by `pacman -S package_name` instead of `pacman -Syu`.[1][2][3]

### Why Partial Upgrades Are Unsupported

Arch Linux is a rolling release distribution where new library versions are continuously pushed to repositories. When libraries are updated, developers and package maintainers rebuild all dependent packages against the new library versions.[2][3]

**Critical issue:** Arch does not use versioned dependencies. This means packages don't specify exact library versions they require—they expect the current repository version.[1]

### The Fundamental Problem

#### Dependency Version Mismatches

When only some packages are upgraded, dependency version mismatches occur:[4][3][2][1]

**Example scenario:**
1. Two packages depend on the same library (e.g., `libcurl`)
2. A library update changes the shared object version (soname bump)
3. Package A is rebuilt against the new library version
4. You run `pacman -Sy` (sync database) but not `-Syu` (full upgrade)
5. Later, you run `pacman -S packageA` which installs the new version
6. This also upgrades `libcurl` as a dependency
7. Package B still expects the old `libcurl` version
8. Package B is now broken because it can't find the old library version[2][1]

#### ABI Breakage

Shared library updates often include ABI (Application Binary Interface) changes:[1][2]

**Real-world example:**
```
curl package gets updated with a soname version bump
pacman package is rebuilt against new curl
You update only curl → pacman breaks (can't find new curl)
You update only pacman → pacman breaks (can't find old curl)
```


The critical problem: **If pacman itself breaks, you cannot use pacman to fix the system**.[1]

### Dangerous Commands to Avoid

#### pacman -Sy package

**Never run:**
```
pacman -Sy package_name
```


This synchronizes the database and then installs a package without upgrading the system. This is the most common cause of partial upgrades.[3][2]

#### pacman -Sy Followed by pacman -S

**Never run:**
```
pacman -Sy
pacman -S package_name
```


This creates the same partial upgrade scenario. Even if you don't intend to install anything immediately after `-Sy`, you might forget later and accidentally create a partial upgrade.[3][2][1]

#### Interrupted pacman -Syu

**Dangerous scenario:**
```
pacman -Syu
[Packages listed for upgrade]
:: Proceed with installation? [Y/n] n
```


Saying "No" to the upgrade after `-Sy` has already run leaves the database synced but packages not upgraded. This is equivalent to running `pacman -Sy` alone.[4]

**If interrupted:** You must complete the upgrade before any other operations. The error must be resolved and the upgrade completed as soon as possible.[2][3]

#### pacman -Syuw

**Risky command:**
```
pacman -Syuw
```


This downloads packages but doesn't install them, while still synchronizing the database. It carries the same partial upgrade risks as `pacman -Sy`.[3][5]

### Real-World Consequences

#### System-Level Breakage

**Best case scenario:** A minor application stops working until you complete the full upgrade.[4]

**Worst case scenario:** Critical system packages like `systemd`, `glibc`, or `pacman` itself break. This can result in:[4]
- Inability to boot the system[4]
- Broken package manager preventing recovery[1]
- Complete system reinstallation required[4]

#### Example Breakage Scenario

**Detailed walkthrough:**[4]

1. You install your system (all packages at version X)
2. Time passes, Arch repositories update packages
3. You try to install a new package with `pacman -S coolpackage`
4. Installation fails because your database is outdated
5. You run `pacman -Sy` to refresh the database
6. You run `pacman -S coolpackage` successfully
7. The new package requires `libfoo.so.2`
8. Pacman upgrades `libfoo` from version 1 to version 2 as a dependency
9. An existing package `oldprogram` still depends on `libfoo.so.1`
10. `oldprogram` is now broken and cannot run[4]

### Safe Alternatives

#### checkupdates Utility

Use `checkupdates` from `pacman-contrib` to safely check for available upgrades without syncing the database:[2][1]

```
checkupdates
```


This downloads databases to a separate location, avoiding the partial upgrade risk. Even though it sees new updates, pacman still uses the old database.[2][1]

**Download packages without installing:**
```
checkupdates -d
```


This downloads pending updates to the cache without synchronizing the main database. Later, you can run `pacman -Syu` quickly using cached packages.[2][1]

#### Always Use pacman -Syu

**Correct approach:**
```
pacman -Syu
```


This synchronizes the database and performs a full system upgrade in one atomic operation.[3][2]

**When installing new packages:**
```
pacman -Syu package_name
```


This ensures the system is fully upgraded before installing the new package.[3][2]

### Additional Considerations

#### IgnorePkg and IgnoreGroup

Using `IgnorePkg` or `IgnoreGroup` in `/etc/pacman.conf` creates intentional partial upgrades:[5][2]

```
IgnorePkg = package_name
```


**Warning:** Be very careful with these directives. They can cause the same issues as partial upgrades when ignored packages have dependency relationships with upgrading packages.[2]

If you must ignore packages, monitor their dependencies closely.[2]

#### Local AUR Packages

Systems with locally built packages (AUR packages) require rebuilding when their dependencies receive soname bumps. AUR helpers like `yay` or `paru` handle this automatically, but manual builds must be monitored.[2]

#### Library Soname Bumps

When libraries receive soname bumps, they are **not backwards compatible**. Never "fix" broken binaries by creating symlinks to old library versions:[2]

**Don't do this:**
```
ln -s libfoo.so.2 libfoo.so.1  # WRONG
```


The proper fix is always a complete system upgrade:[2]
```
pacman -Syu
```

### Recovery from Partial Upgrades

#### If Partial Upgrade Occurs

If you've accidentally created a partial upgrade scenario:[2]

1. **Do not install any packages**
2. Complete the full system upgrade immediately:
   ```
   pacman -Syu
   ```
3. Ensure the upgrade completes successfully
4. Only after successful upgrade, proceed with other operations

#### If Pacman Itself Breaks

If pacman is broken due to a partial upgrade:[1]

**Use pacman-static:**
```
curl -L -o pacman-static https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu
```

This static version bypasses library dependencies and can repair the system.[5]

### Why Other Distros Don't Have This Issue

#### Versioned Dependencies

Most distributions (like Debian/Ubuntu) use versioned dependencies:[4]
- Packages specify exact library versions required
- Multiple library versions coexist on the system
- Old and new versions available simultaneously
- Partial upgrades less likely to break dependencies[4]

#### Arch Design Philosophy

Arch Linux deliberately avoids keeping old libraries around:[4]
- Only current versions in repositories
- Cleaner system with less bloat
- Rolling release model requires all packages stay synchronized
- Trade-off: partial upgrades cause breakage[4]

### Best Practices Summary

**Always:**
- Run `pacman -Syu` for all system updates
- Complete interrupted upgrades immediately
- Use `checkupdates` to safely check for updates
- Read Arch Linux news before upgrading

**Never:**
- Run `pacman -Sy` alone
- Run `pacman -Sy package_name`
- Decline upgrades after syncing database
- Create symlinks to "fix" library issues

**Remember:** "The situation is all old or all new, no accidental partial upgrade".[1]

Sources
[1] Confused about arch linux partial upgrades : r/archlinux https://www.reddit.com/r/archlinux/comments/m5nw0k/confused_about_arch_linux_partial_upgrades/
[2] System maintenance - ArchWiki https://wiki.archlinux.org/title/System_maintenance
[3] How does pulseaudio work when `pulseaudio` isn't installed? https://forum.garudalinux.org/t/how-does-pulseaudio-work-when-pulseaudio-isnt-installed/14351/3
[4] Sy bad? (Beyond it being a "partial upgrade") / Newbie ... https://bbs.archlinux.org/viewtopic.php?id=241092
[5] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[6] Block updates if you have unread Arch Linux news https://forum.endeavouros.com/t/block-updates-if-you-have-unread-arch-linux-news/17003
[7] > Pacman doesn't support 'partial upgrades'[2] (once you ... https://news.ycombinator.com/item?id=29131080
[8] Arch Linux upgrade problems - It's FOSS Community https://itsfoss.community/t/arch-linux-upgrade-problems/11710

