## Hook Directories


### Overview

Pacman supports a hooks system that allows automated execution of commands before or after package transactions. Hooks provide the ability to run custom scripts during package installations, upgrades, and removals based on specific triggers.[1][5]

### System Hook Directory

`/usr/share/libalpm/hooks/` is the system hook directory where default alpm hooks provided by packages reside. This directory contains hooks installed by system packages and should not be modified by users.[4][5][6][1]

System hooks are maintained by package maintainers and are automatically installed when packages requiring hook functionality are added to the system. These hooks handle standard system operations like rebuilding the initramfs after kernel updates.[3][6]

### User Hook Directory

`/etc/pacman.d/hooks/` is the default directory for user-created custom hooks. This is where administrators should place their own hooks to extend pacman functionality.[5][6][3][4]

This directory must be created manually as it does not exist by default:[6][7]

```
sudo mkdir -p /etc/pacman.d/hooks
```


### HookDir Configuration

Additional hook directories can be specified using the `HookDir` directive in `/etc/pacman.conf`:[11][1][4]

```
HookDir = /path/to/hook/dir
```


Multiple hook directories can be specified, and hooks in later directories take precedence over hooks in earlier directories. The paths are absolute and the root path is not automatically prepended.[4]

**Example configuration:**
```
HookDir = /etc/pacman.d/hooks
HookDir = /usr/local/share/libalpm/hooks
```


### Hook Search Order

Pacman searches for hooks in the following locations:[10][5]

1. System hook directory: `/usr/share/libalpm/hooks/`[5][10]
2. Default user hook directory: `/etc/pacman.d/hooks/`[5][4]
3. Additional directories specified by `HookDir` directives (in order)[4]

Hooks are executed in alphabetical order of their file names, with the ordering ignoring the `.hook` suffix. Hooks prefixed with lower numbers have precedence over those with higher numbers.[6][5]

### Hook File Requirements

Hook files must have the `.hook` suffix to be recognized by pacman. Without this extension, files are ignored even if placed in valid hook directories.[7][6][5]

**Naming convention:**
```
00-example.hook
50-pacman-list.hook
90-mkinitcpio-install.hook
```


The numeric prefix controls execution order, with lower numbers running first.[6]

### Hook Directory Structure

A typical hook directory structure includes:[6]

```
/etc/pacman.d/
├── hooks/
│   ├── 00-backup-boot.hook
│   ├── 50-pacman-list.hook
│   └── 99-flatpak-update.hook
└── hooks.bin/
    └── custom-script.sh
```


While not required, some users create `/etc/pacman.d/hooks.bin/` to store associated scripts called by hooks, keeping the hook directory organized.[6]

### Hook File Format

Hook files follow an INI-style format with two main sections:[5]

#### [Trigger] Section

Defines when the hook should be executed:[5]

**Operation:** Install, Upgrade, or Remove (required, repeatable)[5][6]

**Type:** Path or Package (required)[5][6]

**Target:** Path or package name to monitor (required, repeatable)[6][5]

#### [Action] Section

Defines what the hook executes:[5]

**Description:** Human-readable description (optional)[6][5]

**When:** PreTransaction or PostTransaction (required)[5][6]

**Exec:** Command to execute (required)[6][5]

**Depends:** Package dependencies (optional)[5]

**AbortOnFail:** Stop transaction if hook fails (optional, PreTransaction only)[5]

**NeedsTargets:** Pass target list to command (optional)[5]

### Hook Examples

#### Package List Backup Hook

```
# /etc/pacman.d/hooks/50-pacman-list.hook
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Operation = Remove
Target = *

[Action]
Description = Create a backup list of all installed packages
When = PreTransaction
Exec = /bin/sh -c 'pacman -Qqen > /home/$USER/.cache/package_lists/$(date +%Y-%m-%d_%H:%M)_native.log'
```


#### Flatpak Update Hook

```
# /etc/pacman.d/hooks/99-flatpak-update.hook
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = *

[Action]
Description = Update Flatpak packages
When = PostTransaction
Exec = /usr/bin/flatpak update
```


#### Boot Partition Backup Hook

```
# /etc/pacman.d/hooks/00-backup-boot.hook
[Trigger]
Operation = Upgrade
Type = Path
Target = boot/*

[Action]
Description = Backing up /boot partition
When = PreTransaction
Exec = /usr/bin/rsync -a /boot /backup/
```


### Trigger Types

#### Package Triggers

Monitor package operations using `Type = Package`. The `Target` specifies package names, with `*` matching all packages.[6][5]

**Example:**
```
[Trigger]
Type = Package
Target = linux
Target = linux-lts
```


#### Path Triggers

Monitor filesystem paths using `Type = Path`. The `Target` specifies file paths relative to the installation root.[6][5]

**Example:**
```
[Trigger]
Type = Path
Target = usr/lib/modules/*/vmlinuz
Target = boot/*
```


Path triggers use glob patterns and execute when matching files are installed, upgraded, or removed.[5]

### Hook Execution Timing

#### PreTransaction Hooks

Execute before packages are installed, upgraded, or removed. These hooks can abort the transaction if they fail (when `AbortOnFail` is set).[6][5]

PreTransaction hooks are useful for creating backups or validating system state before changes occur.[6]

#### PostTransaction Hooks

Execute after packages are installed, upgraded, or removed. These hooks cannot abort the transaction as changes have already been committed.[5][6]

PostTransaction hooks are useful for rebuilding caches, updating databases, or triggering system reconfigurations.[6]

### Hook Precedence

When multiple hook directories are configured, hooks in later directories take precedence over hooks in earlier directories. If two hooks have the same filename, only the hook from the directory with highest precedence is executed.[4]

This allows users to override system hooks by placing identically-named hooks in custom directories.[4]

### Standard System Hooks

Common system hooks found in `/usr/share/libalpm/hooks/` include:[3]

**90-mkinitcpio-install.hook:** Rebuilds initramfs after kernel updates[3]

**systemd-update.hook:** Updates systemd-related configurations[5]

**update-desktop-database.hook:** Refreshes desktop file caches[5]

**gtk-update-icon-cache.hook:** Updates icon caches for GTK applications[5]

### Hook Resources

Third-party hook collections provide examples and ready-to-use hooks for common tasks:[2][9]

- Package list backups[6]
- Broken package detection[9]
- Filesystem snapshots[6]
- Configuration file backups[2]
- Orphaned package cleanup[9]
- System service restarts[6]

### Debugging Hooks

Pacman displays hook execution in its output, showing the description and timing of each hook. If a hook fails, error messages appear in the pacman output, allowing identification of problematic hooks.[7][5]

To test hook execution without performing actual package operations, use `pacman -S --print` to simulate installations.[5]

### Hook Validation

Hook syntax can be validated by checking the pacman output during operations. Malformed hooks are reported as errors and skipped during execution.[5]

The `alpm-hooks(5)` manual page provides comprehensive documentation on hook file format and options.[5]

### Security Considerations

Hooks execute with root privileges during pacman operations. Only trusted scripts should be placed in hook directories, and hook files should have appropriate permissions to prevent unauthorized modification.[6][5]

User-created hooks in `/etc/pacman.d/hooks/` should be reviewed carefully before use to ensure they perform intended actions safely.[6]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Hear ye Archers - share your Pacman hooks : r/archlinux https://www.reddit.com/r/archlinux/comments/dsnu81/hear_ye_archers_share_your_pacman_hooks/
[3] [SOLVED] Making a pacman hook to backup /boot ... https://bbs.archlinux.org/viewtopic.php?id=289248
[4] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[5] alpm-hooks(5) - Arch manual pages https://man.archlinux.org/man/alpm-hooks.5.en
[6] [HowTo] Create useful Pacman hooks https://forum.manjaro.org/t/howto-create-useful-pacman-hooks/55020
[7] Arch Linux pacman hooks https://www.youtube.com/watch?v=J8EhTmBX6nc
[8] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[9] desbma/pacman-hooks: Arch Linux ... https://github.com/desbma/pacman-hooks
[10] Pacman - Stéphane's cheat sheets https://cheatsheets.stephane.plus/distros/arch-based/pacman/
[11] pacman(8) https://pacman.archlinux.page/pacman.8.html


