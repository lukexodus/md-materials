## System and User Hooks


### Overview

Pacman uses two distinct categories of hooks: system hooks provided by packages and user hooks created by administrators. Understanding the difference between these categories is essential for effective hook management and customization.

### System Hooks

#### Location

System hooks are installed by packages and reside in:

```
/usr/share/libalpm/hooks/
```

This directory is managed by pacman and contains hooks that packages install as part of their normal operation.

#### Characteristics

**Package-managed:** System hooks are installed, updated, and removed by packages through pacman.

**Automatic installation:** When you install a package that includes hooks, they're automatically placed in `/usr/share/libalpm/hooks/`.

**Should not be modified:** These hooks are tracked by pacman's database. Manual modifications will be overwritten during package updates.

**Maintained by package maintainers:** Package developers create and maintain these hooks to ensure proper system integration.

#### Common System Hooks

**fontconfig.hook:** Updates font cache when fonts are installed
**update-desktop-database.hook:** Updates desktop file database
**gtk-update-icon-cache.hook:** Updates icon cache for GTK applications
**systemd-daemon-reload.hook:** Reloads systemd when unit files change
**depmod.hook:** Updates kernel module dependencies
**texinfo-install.hook:** Updates GNU Info directory

#### Viewing System Hooks

List all system hooks:

```
ls -la /usr/share/libalpm/hooks/
```

View contents of a system hook:

```
cat /usr/share/libalpm/hooks/fontconfig.hook
```

#### Which Packages Provide Hooks

Find which package owns a system hook:

```
pacman -Qo /usr/share/libalpm/hooks/fontconfig.hook
```

**Example output:**
```
/usr/share/libalpm/hooks/fontconfig.hook is owned by fontconfig 2.14.0-1
```

### User Hooks

#### Location

User hooks are custom hooks created by system administrators and reside in:

```
/etc/pacman.d/hooks/
```

This is the default directory for custom user-created hooks.

#### Characteristics

**User-created:** These hooks are manually written by administrators to customize system behavior.

**Not package-managed:** User hooks are not tracked by any package and persist through system updates.

**Full control:** You have complete control over creation, modification, and deletion.

**Custom automation:** Used to implement site-specific or personal automation needs.

#### Creating the Directory

Ensure the user hooks directory exists:

```
sudo mkdir -p /etc/pacman.d/hooks/
```

This directory doesn't exist by default and must be created before placing custom hooks.

#### Common User Hook Examples

**Custom cache cleaning:**
```
/etc/pacman.d/hooks/clean-cache.hook
```

**Orphan package removal:**
```
/etc/pacman.d/hooks/remove-orphans.hook
```

**Custom notifications:**
```
/etc/pacman.d/hooks/update-notify.hook
```

**Backup automation:**
```
/etc/pacman.d/hooks/backup-configs.hook
```

**Service management:**
```
/etc/pacman.d/hooks/restart-services.hook
```

### Directory Precedence and Overrides

#### Configuration in pacman.conf

The `HookDir` directive in `/etc/pacman.conf` specifies hook directories:

```
[options]
HookDir = /usr/share/libalpm/hooks/
HookDir = /etc/pacman.d/hooks/
```

Multiple `HookDir` lines can be specified, and they're processed in order.

#### Override Mechanism

**Later directories take precedence:** If a hook with the same filename exists in multiple directories, only the one from the last matching `HookDir` executes.

**Example scenario:**

**System hook:** `/usr/share/libalpm/hooks/update-cache.hook`
**User hook:** `/etc/pacman.d/hooks/update-cache.hook`

Result: Only the user hook executes, completely replacing the system version.

#### Selective Override

**Disable a system hook:** Create an empty file with the same name in the user hooks directory:

```
sudo touch /etc/pacman.d/hooks/unwanted-system-hook.hook
```

The empty user hook overrides the system hook, effectively disabling it.

**Modify a system hook:** Copy it to the user directory and modify:

```
sudo cp /usr/share/libalpm/hooks/system-hook.hook /etc/pacman.d/hooks/
sudo nano /etc/pacman.d/hooks/system-hook.hook
```

Your modified version takes precedence.

### Hybrid Approach: Extending System Hooks

#### Complement System Hooks

Rather than overriding, create additional user hooks that work alongside system hooks:

**System hook:** `fontconfig.hook` (updates font cache)
**User hook:** `custom-font-notify.hook` (notifies about font changes)

Both execute independently with different names.

#### Sequential Operation

Use numeric prefixes to ensure user hooks run before or after system hooks:

**System hook:** `update-desktop-database.hook` (no numeric prefix)
**User hook:** `10-desktop-pre-setup.hook` (runs first alphabetically)
**User hook:** `zz-desktop-post-cleanup.hook` (runs last alphabetically)

### Managing Hooks

#### Listing All Active Hooks

Find all hooks from both directories:

```
find /usr/share/libalpm/hooks/ /etc/pacman.d/hooks/ -name "*.hook" -type f 2>/dev/null | sort
```

#### Checking for Overrides

Identify hooks that exist in both directories (overrides):

```
comm -12 \
  <(ls /usr/share/libalpm/hooks/*.hook 2>/dev/null | xargs -n1 basename | sort) \
  <(ls /etc/pacman.d/hooks/*.hook 2>/dev/null | xargs -n1 basename | sort)
```

This lists filenames present in both directories, indicating user overrides of system hooks.

#### Comparing Hook Versions

View differences between system and user versions:

```
diff /usr/share/libalpm/hooks/hook-name.hook /etc/pacman.d/hooks/hook-name.hook
```

This shows what changes you've made in the user override.

### Backup and Restoration

#### Backup User Hooks

User hooks should be backed up as part of `/etc/`:

```
sudo tar -czf /backup/pacman-hooks-$(date +%Y%m%d).tar.gz /etc/pacman.d/hooks/
```

#### Restore User Hooks

Extract backed-up hooks:

```
sudo tar -xzf /backup/pacman-hooks-20251101.tar.gz -C /
```

#### System Hooks Restoration

System hooks are automatically restored when packages are reinstalled:

```
sudo pacman -S --overwrite /usr/share/libalpm/hooks/\* package-name
```

### Documentation and Maintenance

#### Document User Hooks

Add comments to user hooks explaining their purpose:

```
# /etc/pacman.d/hooks/custom-cleanup.hook
# Purpose: Automatically clean package cache and remove orphans
# Created: 2025-11-01
# Author: System Administrator
# Notes: Runs after every package operation

[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Running custom cleanup...
When = PostTransaction
Exec = /usr/local/bin/cleanup-system.sh
```

#### Maintain a Hook Registry

Keep a log of custom hooks:

```
# /etc/pacman.d/hooks/README
# Custom Hooks Inventory
# Last updated: 2025-11-01

10-backup-kernel.hook     - Backup kernel before updates
20-clean-cache.hook       - Clean package cache after operations
30-remove-orphans.hook    - Remove orphaned packages
90-notify-updates.hook    - Send desktop notifications
```

### Troubleshooting

#### Identify Which Hook Executed

When multiple hooks exist, determine which one ran:

**Enable debug mode:**
```
sudo pacman -S package-name --debug 2>&1 | grep hook-name.hook
```

This shows the full path of the executed hook.

#### Temporarily Disable User Hook

Rename to disable without deleting:

```
sudo mv /etc/pacman.d/hooks/hook.hook /etc/pacman.d/hooks/hook.hook.disabled
```

Re-enable:
```
sudo mv /etc/pacman.d/hooks/hook.hook.disabled /etc/pacman.d/hooks/hook.hook
```

#### Temporarily Disable System Hook

Override with empty user hook:

```
sudo touch /etc/pacman.d/hooks/system-hook-name.hook
```

Remove the override to re-enable:
```
sudo rm /etc/pacman.d/hooks/system-hook-name.hook
```

### Best Practices

**Prefer user hooks for customization:** Create new user hooks rather than modifying system hooks when possible.

**Document overrides:** If you override a system hook, document why and what you changed.

**Use descriptive names:** User hooks should have clear, descriptive names indicating their purpose.

**Version control:** Keep user hooks in version control (git) for tracking changes.

**Test before deploying:** Test user hooks on non-production systems before deploying to critical machines.

**Monitor system hooks:** Be aware of system hooks installed by packages; they may affect behavior.

**Minimize overrides:** Only override system hooks when absolutely necessary; complementary hooks are preferred.

**Backup user hooks:** Include `/etc/pacman.d/hooks/` in regular system backups.

**Clean up unused hooks:** Remove obsolete user hooks to reduce clutter and confusion.

**Check after package updates:** Verify user hook overrides still work correctly after package updates.

### Security Considerations

**Review system hooks:** Understand what system hooks do, especially from third-party repositories.

**Protect user hooks:** Ensure `/etc/pacman.d/hooks/` has appropriate permissions (root-owned, 755).

**Validate hook scripts:** Review external scripts called by hooks for security issues.

**Avoid sensitive ** Don't include passwords or secrets in hook files.

**Limit scope:** Hooks run as root; minimize privileges and operations.

Understanding the distinction between system and user hooks enables effective customization while maintaining system integrity and ensuring hooks survive package updates appropriately.

