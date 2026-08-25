## Creating Custom Hooks


### Basic Hook Creation Process

Creating custom pacman hooks involves writing an INI-style configuration file and placing it in the appropriate directory. Hooks automate tasks during package operations without manual intervention.

### Step-by-Step Hook Creation

#### Step 1: Create Hook Directory

Ensure the custom hooks directory exists:

```
sudo mkdir -p /etc/pacman.d/hooks/
```

User-created hooks should be placed in `/etc/pacman.d/hooks/` to avoid conflicts with package-managed hooks in `/usr/share/libalpm/hooks/`.

#### Step 2: Create Hook File

Create a new hook file with a descriptive name and `.hook` extension:

```
sudo nano /etc/pacman.d/hooks/your-hook-name.hook
```

#### Step 3: Define Trigger Section

Specify when the hook should activate:

```
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = package-name
```

**Key decisions:**
- Which operations trigger it? (Install, Upgrade, Remove)
- Package-based or file-based trigger?
- Specific targets or all packages (`*`)?

#### Step 4: Define Action Section

Specify what the hook executes:

```
[Action]
Description = Performing custom action...
When = PostTransaction
Exec = /path/to/command --options
```

**Key decisions:**
- PreTransaction or PostTransaction?
- What command to run?
- Should failure abort the transaction?

#### Step 5: Save and Test

Save the file and test by performing the triggering operation:

```
sudo pacman -S target-package
```

Watch for the hook's description message during execution.

### Practical Hook Examples

#### Example 1: Automatic Orphan Cleanup

Remove orphaned packages automatically after removals:

```
# /etc/pacman.d/hooks/remove-orphans.hook
[Trigger]
Operation = Remove
Type = Package
Target = *

[Action]
Description = Removing orphaned packages...
When = PostTransaction
Exec = /bin/sh -c "pacman -Qtdq | pacman -Rns --noconfirm - || true"
```

**Note:** The `|| true` prevents failure if no orphans exist.

#### Example 2: System Cleanup After Upgrades

Perform comprehensive cleanup after system upgrades:

```
# /etc/pacman.d/hooks/cleanup-after-upgrade.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Cleaning system after upgrade...
When = PostTransaction
Exec = /usr/local/bin/system-cleanup.sh
```

**Companion script** (`/usr/local/bin/system-cleanup.sh`):

```bash
#!/bin/bash
# Clean package cache
paccache -rk2
# Remove orphans
orphans=$(pacman -Qtdq)
if [ -n "$orphans" ]; then
    echo "$orphans" | pacman -Rns --noconfirm -
fi
# Clean journal
journalctl --vacuum-time=2weeks
```

Make it executable:
```
sudo chmod +x /usr/local/bin/system-cleanup.sh
```

#### Example 3: Kernel Update Notification

Notify when kernel updates require reboot:

```
# /etc/pacman.d/hooks/kernel-reboot-notify.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = linux
Target = linux-lts
Target = linux-zen

[Action]
Description = Kernel updated - reboot required!
When = PostTransaction
Exec = /usr/bin/notify-send -u critical "Kernel Updated" "System reboot required to use new kernel"
```

**Note:** This requires a desktop environment with notification support.

#### Example 4: Backup Before Critical Updates

Backup important configurations before upgrading critical packages:

```
# /etc/pacman.d/hooks/backup-before-critical.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = systemd
Target = glibc
Target = pacman

[Action]
Description = Backing up critical configurations...
When = PreTransaction
Exec = /usr/local/bin/backup-configs.sh
AbortOnFail
```

**Companion script:**

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/pacman-critical"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/configs-$DATE.tar.gz" \
    /etc/pacman.conf \
    /etc/pacman.d/ \
    /etc/systemd/ \
    /boot/loader/

echo "Backup created: $BACKUP_DIR/configs-$DATE.tar.gz"
```

#### Example 5: Database Optimization

Optimize package database after major operations:

```
# /etc/pacman.d/hooks/optimize-database.hook
[Trigger]
Operation = Install
Operation = Remove
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Optimizing package database...
When = PostTransaction
Exec = /bin/sh -c "pacman-db-upgrade && paccache -rk3"
```

#### Example 6: Update Mirror List Weekly

Refresh mirror list when packages are upgraded (with rate limiting):

```
# /etc/pacman.d/hooks/update-mirrorlist.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist

[Action]
Description = Updating mirror list...
When = PostTransaction
Depends = reflector
Exec = /usr/bin/reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

This only runs when `pacman-mirrorlist` package updates.

#### Example 7: File-Based Trigger

Update icon cache when icon files change:

```
# /etc/pacman.d/hooks/icon-cache.hook
[Trigger]
Type = File
Operation = Install
Operation = Upgrade
Operation = Remove
Target = usr/share/icons/*

[Action]
Description = Updating icon cache...
When = PostTransaction
Exec = /usr/bin/gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor
```

#### Example 8: Conditional Hook with Dependencies

Only run if specific tools are installed:

```
# /etc/pacman.d/hooks/flatpak-update.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = flatpak

[Action]
Description = Updating Flatpak applications...
When = PostTransaction
Depends = flatpak
Exec = /usr/bin/flatpak update --noninteractive
```

If `flatpak` isn't installed, the hook is silently skipped.

### Advanced Hook Techniques

#### Using NeedsTargets

Pass triggered package names to the script:

```
# /etc/pacman.d/hooks/log-upgrades.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Logging upgraded packages...
When = PostTransaction
NeedsTargets
Exec = /usr/local/bin/log-packages.sh
```

**Script receives package names as arguments:**

```bash
#!/bin/bash
# /usr/local/bin/log-packages.sh
LOG_FILE="/var/log/pacman-upgrades.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

for package in "$@"; do
    echo "[$DATE] Upgraded: $package" >> "$LOG_FILE"
done
```

#### Combining Multiple Triggers

Match multiple conditions:

```
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
Target = linux-headers
Target = nvidia
Target = nvidia-dkms
```

This triggers on any of these packages being installed or upgraded.

#### Error Handling in Hooks

Ensure hooks don't break transactions:

```
[Action]
Description = Running optional cleanup...
When = PostTransaction
Exec = /bin/sh -c "cleanup-command || echo 'Cleanup failed but continuing'"
```

Or use `AbortOnFail` only for critical operations:

```
[Action]
Description = Critical validation...
When = PreTransaction
Exec = /usr/local/bin/validate-system.sh
AbortOnFail
```

### Testing Custom Hooks

#### Dry Run Testing

Test without actual installation:

```
pacman -S package_name --print
```

This shows what would happen but doesn't execute.

#### Verbose Testing

See detailed hook execution:

```
pacman -S package_name --debug 2>&1 | grep -i hook
```

#### Manual Hook Execution

Test the command independently:

```
/path/to/command --options
```

Ensure it works correctly before integrating into a hook.

### Common Pitfalls

**Avoid interactive commands:** Hooks run non-interactively; commands requiring user input will hang or fail.

**Path issues:** Use absolute paths for all executables and files.

**Permissions:** Hooks run as root but may need to consider file ownership.

**Exit codes:** Non-zero exit codes can abort transactions if `AbortOnFail` is set.

**Performance:** Slow hooks delay package operations; keep them efficient.

**Infinite loops:** Don't create hooks that trigger themselves (e.g., a hook that runs `pacman -S`).

### Debugging Hook Issues

#### Check Hook Syntax

Validate INI format:
```
cat /etc/pacman.d/hooks/your-hook.hook
```

Ensure proper section headers and directive names.

#### View Hook Output

Watch pacman output during operations:
```
sudo pacman -S package_name
```

Look for your hook's description message.

#### Test Hook Command Directly

Run the `Exec` command manually:
```
sudo /path/to/command --options
```

Verify it executes without errors.

#### Check Dependencies

Ensure `Depends` executables exist:
```
which dependency-name
```

### Disabling Hooks Temporarily

#### Rename Hook File

Temporarily disable without deleting:
```
sudo mv /etc/pacman.d/hooks/hook.hook /etc/pacman.d/hooks/hook.hook.disabled
```

Re-enable:
```
sudo mv /etc/pacman.d/hooks/hook.hook.disabled /etc/pacman.d/hooks/hook.hook
```

#### Use NoExtract

Prevent specific hook from loading (in `/etc/pacman.conf`):
```
[options]
NoExtract = etc/pacman.d/hooks/problematic-hook.hook
```

### Best Practices

**Start simple:** Begin with basic hooks and gradually add complexity.

**Test thoroughly:** Test hooks on non-production systems first.

**Use descriptive names:** Filename should indicate purpose (e.g., `nvidia-rebuild.hook`).

**Document purpose:** Add comments at the top of hook files.

**Handle errors gracefully:** Use `|| true` or proper error handling to prevent transaction failures.

**Specify dependencies:** Use `Depends` to prevent failures when tools are missing.

**Avoid side effects:** Don't modify the system state unexpectedly.

**Consider timing:** Choose PreTransaction or PostTransaction appropriately.

**Keep hooks focused:** One hook, one purpose.

**Log actions:** Consider logging what hooks do for troubleshooting.

Custom hooks are powerful automation tools that keep your Arch Linux system maintained, optimized, and consistent without manual intervention after package operations.

