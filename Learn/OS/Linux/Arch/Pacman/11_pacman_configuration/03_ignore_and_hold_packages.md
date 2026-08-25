## Ignore and Hold Packages


### IgnorePkg Configuration

The `IgnorePkg` directive in `/etc/pacman.conf` prevents specific packages from being upgraded during system updates.[3][5][6]

#### Basic Syntax

Edit `/etc/pacman.conf` and locate the `[options]` section:

```
sudo nano /etc/pacman.conf
```

Add packages to ignore:

```
[options]
IgnorePkg = package_name
```


**Multiple packages on one line (space-separated):**
```
IgnorePkg = linux firefox vlc
```


**Multiple packages on separate lines:**
```
IgnorePkg = linux
IgnorePkg = firefox
IgnorePkg = vlc
```


Both formats can be combined and work identically.[1]

#### Example: Ignore Kernel Updates

A common use case is holding back kernel updates when using proprietary drivers:

```
[options]
IgnorePkg = linux linux-headers
```


This prevents kernel and matching headers from updating, ensuring driver compatibility.[5]

#### Verification

After configuring, run a system update to verify:

```
sudo pacman -Syu
```

You'll see warnings for ignored packages:
```
warning: linux: ignoring package upgrade (6.8.1.arch1-1 => 6.9.0.arch1-1)
warning: firefox: ignoring package upgrade (120.0-1 => 121.0-1)
```


This confirms the packages are being skipped.[5]

### IgnoreGroup Configuration

The `IgnoreGroup` directive ignores all packages in a specified group during upgrades.[7][6]

#### Syntax

```
[options]
IgnoreGroup = group_name
```


**Multiple groups (space-separated):**
```
IgnoreGroup = gnome plasma
```

**Example: Ignore Desktop Environment**
```
IgnoreGroup = plasma-desktop
```


This prevents all packages in the `plasma-desktop` group from updating.[6]

#### Shell-Style Glob Patterns

`IgnoreGroup` supports glob patterns:
```
IgnoreGroup = gnome*
```


This matches all groups beginning with "gnome".[7]

### Temporary Ignoring (Command-Line)

For one-time upgrades, use the `--ignore` flag without modifying configuration files.[3][8][5][6]

#### Single Package

```
sudo pacman -Syu --ignore linux
```


#### Multiple Packages (Comma-Separated)

```
sudo pacman -Syu --ignore linux,firefox
```


**Note:** Commas separate packages; no spaces after commas.[1][8]

#### Multiple --ignore Flags

Alternative syntax using repeated flags:
```
sudo pacman -Syu --ignore linux --ignore firefox --ignore vlc
```


Both methods work identically.[1]

#### Temporary Group Ignoring

```
sudo pacman -Syu --ignoregroup plasma-desktop
```


This ignores an entire group for one upgrade cycle.[6]

### Manually Updating Ignored Packages

#### Override IgnorePkg Temporarily

When a package is in `IgnorePkg`, explicitly installing it bypasses the ignore directive:[5][1]

```
sudo pacman -S package_name
```


**Pacman assumes you're smarter than it**: Explicitly requesting an ignored package overrides the ignore setting.[1]

**Example:**
```
sudo pacman -S linux
```

This updates the kernel even if it's in `IgnorePkg`.[5]

#### Install and Resume Ignoring

Pacman will prompt for confirmation:
```
:: linux is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n]
```


Answer `y` to proceed. The package returns to the ignore list after installation.[6]

### Limitations and Considerations

#### No Wildcard Support

`IgnorePkg` does **not** support wildcards like `linux*`. Each package must be explicitly listed:[5]

**Incorrect:**
```
IgnorePkg = linux*
```

**Correct:**
```
IgnorePkg = linux linux-headers linux-docs linux-lts
```


For kernel packages, you must list all related components individually.[5]

#### Partial Upgrades Risk

**Critical warning**: Ignoring packages creates partial upgrade scenarios, which are **unsupported** on Arch Linux. This can lead to:[2]
- Dependency conflicts
- System instability
- Package breakage
- Difficult-to-diagnose issues

**Best practices:**
- Use `IgnorePkg` sparingly and temporarily
- Monitor ignored packages regularly
- Update ignored packages as soon as possible
- Document why packages are ignored[5]

#### Rolling Release Considerations

Arch Linux is a rolling release; long-term package ignoring eventually causes dependency problems. If you need stable versions:[2]
- Consider using containers or VMs for critical services
- Use LTS alternatives (Ubuntu Server, Rocky Linux) for databases or production services
- Regularly review and minimize ignored packages[2]

### Removing Packages from Ignore List

#### Edit Configuration File

Remove or comment out the `IgnorePkg` line:

**Before:**
```
IgnorePkg = vlc firefox
```

**After (remove vlc):**
```
IgnorePkg = firefox
```

Or comment out to disable:
```
#IgnorePkg = vlc firefox
```


Save the file and run `pacman -Syu` to update previously ignored packages.[6]

### HoldPkg vs IgnorePkg

#### HoldPkg Configuration

`HoldPkg` is different from `IgnorePkg`—it requires **extra confirmation** before removal but doesn't prevent upgrades:

```
[options]
HoldPkg = pacman glibc
```

**Purpose**: Protects critical system packages from accidental removal.

**Behavior**: Prompts for additional confirmation when attempting to remove listed packages.

**Use case**: Prevents accidentally removing essential packages like `pacman` or `glibc` that would break the system.

#### Comparison

**IgnorePkg:**
- Prevents upgrades
- Allows removal
- Used to hold back updates

**HoldPkg:**
- Allows upgrades
- Protects from removal
- Used to protect critical packages

### Practical Use Cases

#### Case 1: Problematic Kernel Update

A new kernel breaks your system:

**Temporary solution:**
```
sudo pacman -Syu --ignore linux,linux-headers
```

**Permanent (until fixed):**
```
[options]
IgnorePkg = linux linux-headers
```


Monitor Arch news for kernel fixes, then remove from ignore list.[5]

#### Case 2: Custom-Compiled Software

You've compiled a package with custom patches:

```
[options]
IgnorePkg = custom-package
```

This prevents pacman from overwriting your custom build.[5]

#### Case 3: Driver Compatibility

NVIDIA or VirtualBox drivers lag behind kernel updates:

```
[options]
IgnorePkg = linux linux-headers
```


Update only when matching driver versions are available.[5]

#### Case 4: Testing Before Production

Hold back packages on production systems while testing on development machines:

```
[options]
IgnorePkg = postgresql nginx
```

Update after verifying stability in test environment.

### Monitoring Ignored Packages

#### List Current Ignored Packages

View current configuration:
```
grep "^IgnorePkg" /etc/pacman.conf
grep "^IgnoreGroup" /etc/pacman.conf
```

#### Check Available Updates for Ignored Packages

See what updates are being held back:
```
pacman -Qu
```

Ignored packages won't appear here, so manually check:
```
pacman -Si package_name | grep Version
pacman -Qi package_name | grep Version
```

Compare repository vs installed versions.

### Best Practices

**Use sparingly**: Only ignore packages when absolutely necessary.[5]

**Document reasons**: Add comments in `pacman.conf` explaining why packages are ignored:
```
# Holding linux kernel - NVIDIA driver compatibility
IgnorePkg = linux linux-headers
```


**Regular review**: Periodically check if ignored packages can be updated safely.[5]

**Prefer --ignore flag**: For one-time deferrals, use command-line `--ignore` instead of editing configuration.[5]

**Monitor dependencies**: Watch for dependency conflicts caused by ignored packages.[2]

**Update ASAP**: Return to normal updates as soon as issues are resolved.[5]

**Read Arch news**: Check archlinux.org/news before ignoring packages—manual intervention instructions may exist.[5]

**Security considerations**: Ignoring packages may delay security updates; evaluate risks carefully.[5]

Package ignoring is a powerful feature for managing problematic updates, but should be used judiciously to avoid creating system instability through partial upgrades.

Sources
[1] pacman -Syu - ignore multiple packages https://bbs.archlinux.org/viewtopic.php?id=42319
[2] Can I force pacman to ignore a file while updating ... https://www.reddit.com/r/archlinux/comments/1e2b70k/can_i_force_pacman_to_ignore_a_file_while/
[3] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[4] Keep system updated with everything "but" - Pacman & ... https://forum.endeavouros.com/t/keep-system-updated-with-everything-but/25543
[5] How to Ignore Specific Package Updates on Arch Linux https://www.siberoloji.com/how-to-ignore-specific-package-updates-on-arch-linux/
[6] Ignore A Package From Being Upgraded In Arch Linux https://ostechnix.com/safely-ignore-package-upgraded-arch-linux/
[7] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[8] How to Ignore Kernel Upgrades on Arch Linux | Cyrus Yip's blog https://cyrusyip.org/en/posts/2022/06/30/ignore-kernel-upgrades-on-arch/
[9] Exclude an AUR package from updating https://forum.manjaro.org/t/exclude-an-aur-package-from-updating/174575

