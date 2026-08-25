## Hook Execution Order


### Basic Execution Sequence

Pacman hooks execute in a specific order based on several factors. Understanding this order is crucial for creating hooks that work correctly, especially when hooks depend on each other or modify the system state.

### Primary Execution Phases

#### PreTransaction Hooks

Hooks with `When = PreTransaction` run **before** any file operations occur:

**Execution sequence:**
1. Database is synced
2. Dependencies are resolved
3. **PreTransaction hooks execute**
4. Files are extracted and installed
5. PostTransaction hooks execute

**Use cases:**
- System validation before changes
- Creating backups
- Checking available disk space
- Preparing the environment
- Operations that might abort the transaction

#### PostTransaction Hooks

Hooks with `When = PostTransaction` run **after** all file operations complete:

**Execution sequence:**
1. Database is synced
2. Dependencies are resolved
3. PreTransaction hooks execute
4. Files are extracted and installed
5. **PostTransaction hooks execute**

**Use cases:**
- Updating system caches
- Rebuilding initramfs
- Cleaning package cache
- Sending notifications
- Running system optimizations
- Operations that finalize the installation

### Alphabetical Ordering

Within each phase (PreTransaction or PostTransaction), hooks execute in **alphabetical order by filename**.

#### Example Ordering

Given these hook files:
```
/etc/pacman.d/hooks/10-backup.hook
/etc/pacman.d/hooks/20-validate.hook
/etc/pacman.d/hooks/30-cleanup.hook
/etc/pacman.d/hooks/50-notify.hook
```

They execute in this order:
1. `10-backup.hook`
2. `20-validate.hook`
3. `30-cleanup.hook`
4. `50-notify.hook`

#### Numbering Convention

A common practice is prefixing hook names with numbers to control execution order:

```
00-critical-first.hook
10-prepare-environment.hook
20-backup-configs.hook
50-main-operation.hook
90-cleanup.hook
99-final-notification.hook
```

This ensures predictable ordering regardless of alphabetical sorting.

### Directory Precedence

When multiple `HookDir` directories are configured in `/etc/pacman.conf`, **later directories take precedence** for hooks with the same name:

```
[options]
HookDir = /usr/share/libalpm/hooks/
HookDir = /etc/pacman.d/hooks/
```

**Precedence rules:**
1. If a hook exists in both directories with the same filename, only the one from `/etc/pacman.d/hooks/` executes
2. This allows overriding system-provided hooks with custom versions
3. Different hook names from both directories all execute (in alphabetical order)

**Example:**

**System hook:** `/usr/share/libalpm/hooks/update-cache.hook`
**User hook:** `/etc/pacman.d/hooks/update-cache.hook`

Only the user hook executes, overriding the system version.

### Execution Order Example

#### Multiple Hooks Scenario

Consider these hooks:

**PreTransaction hooks:**
```
/etc/pacman.d/hooks/10-backup.hook          (When = PreTransaction)
/etc/pacman.d/hooks/20-validate.hook        (When = PreTransaction)
/usr/share/libalpm/hooks/systemd-check.hook (When = PreTransaction)
```

**PostTransaction hooks:**
```
/etc/pacman.d/hooks/50-rebuild-initramfs.hook (When = PostTransaction)
/etc/pacman.d/hooks/90-cleanup.hook           (When = PostTransaction)
/usr/share/libalpm/hooks/update-icon-cache.hook (When = PostTransaction)
```

**Full execution order:**
1. `10-backup.hook` (PreTransaction)
2. `20-validate.hook` (PreTransaction)
3. `systemd-check.hook` (PreTransaction)
4. **[Package installation occurs]**
5. `50-rebuild-initramfs.hook` (PostTransaction)
6. `90-cleanup.hook` (PostTransaction)
7. `update-icon-cache.hook` (PostTransaction)

### Controlling Hook Order

#### Using Numeric Prefixes

Ensure desired execution order with numbered prefixes:

**For sequential operations:**
```
10-stop-service.hook          # Stop service first
20-update-package.hook        # Then handle package
30-configure.hook             # Configure after update
40-start-service.hook         # Restart service last
```

#### Critical Operations First

Place critical hooks early in the sequence:

```
00-disk-space-check.hook      # Check space before anything
05-backup-critical.hook       # Backup before changes
...
95-cleanup.hook               # Clean up after all operations
99-notify-completion.hook     # Final notification
```

#### Dependencies Between Hooks

**Problem:** Hook B depends on Hook A completing first.

**Solution:** Use numeric prefixes to enforce order:

```
10-create-backup.hook         # Creates backup
20-verify-backup.hook         # Verifies the backup created by 10-
```

Alternatively, combine operations into a single hook with a script that handles sequencing.

### Trigger-Based Execution

Hooks only execute if their triggers match the current transaction:

#### Selective Execution Example

**Transaction:** `pacman -S firefox`

**Hooks:**
```
kernel-update.hook    (Target = linux)           → Not executed
firefox-cache.hook    (Target = firefox)         → Executed
all-packages.hook     (Target = *)               → Executed
nvidia-rebuild.hook   (Target = nvidia)          → Not executed
```

Only hooks matching the transaction targets execute, in alphabetical order within their timing phase.

### Complex Ordering Scenarios

#### Multiple Operations with Different Triggers

**Transaction:** `pacman -S linux nvidia`

**PreTransaction execution order:**
1. Hooks targeting `linux` (alphabetically)
2. Hooks targeting `nvidia` (alphabetically)
3. Hooks targeting `*` (alphabetically)

Actually, all matching hooks execute alphabetically regardless of which specific package triggered them.

#### Override System Hook

**System hook:** `/usr/share/libalpm/hooks/30-update-desktop-database.hook`
**Custom hook:** `/etc/pacman.d/hooks/30-update-desktop-database.hook`

The custom hook completely replaces the system hook with the same name. The system version doesn't execute at all.

### Practical Application

#### Example: Kernel Update Workflow

Create a coordinated kernel update process:

```
# /etc/pacman.d/hooks/10-kernel-pre-backup.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = linux

[Action]
Description = Backing up current kernel...
When = PreTransaction
Exec = /usr/local/bin/backup-kernel.sh
```

```
# /etc/pacman.d/hooks/90-kernel-post-rebuild.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = linux

[Action]
Description = Rebuilding initramfs...
When = PostTransaction
Exec = /usr/bin/mkinitcpio -P
```

```
# /etc/pacman.d/hooks/95-kernel-notify.hook
[Trigger]
Operation = Upgrade
Type = Package
Target = linux

[Action]
Description = Kernel updated - reboot required
When = PostTransaction
Exec = /usr/bin/notify-send "Kernel Update" "Reboot required for new kernel"
```

**Execution flow:**
1. `10-kernel-pre-backup.hook` (backup before changes)
2. **[Kernel files installed]**
3. `90-kernel-post-rebuild.hook` (rebuild initramfs)
4. `95-kernel-notify.hook` (notify user)

#### Example: Cleanup Chain

Create sequential cleanup operations:

```
# 10-remove-orphans.hook
[Action]
Description = Removing orphaned packages...
When = PostTransaction
Exec = /bin/sh -c "pacman -Qtdq | pacman -Rns --noconfirm - || true"
```

```
# 20-clean-cache.hook
[Action]
Description = Cleaning package cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk2
```

```
# 30-journal-cleanup.hook
[Action]
Description = Cleaning system journal...
When = PostTransaction
Exec = /usr/bin/journalctl --vacuum-time=2weeks
```

All execute in order after transaction completes.

### Debugging Execution Order

#### View Hook Execution

Watch hooks execute during package operations:

```
sudo pacman -S package_name
```

Observe the "Description" messages showing which hooks run and in what order.

#### Debug Mode

Enable verbose output to see hook matching and execution:

```
sudo pacman -S package_name --debug 2>&1 | grep -E "(hook|running)"
```

This shows detailed information about hook discovery and execution.

#### List All Hooks

Find all hooks on the system:

```
find /usr/share/libalpm/hooks/ /etc/pacman.d/hooks/ -name "*.hook" -type f | sort
```

This shows all available hooks in alphabetical order.

### Best Practices

**Use numeric prefixes:** Prefix hook names with numbers (00-99) to control execution order explicitly.

**Group related hooks:** Use number ranges for related operations (10-19 for backups, 20-29 for validation, etc.).

**Document dependencies:** Add comments in hooks explaining ordering requirements.

**Test individually:** Test hooks in isolation before relying on specific execution order.

**Avoid assumptions:** Don't assume system hooks execute at specific times; they may change.

**Consider timing:** Choose PreTransaction or PostTransaction based on when the operation logically fits.

**Keep it simple:** Minimize dependencies between hooks; prefer self-contained operations.

**Name descriptively:** Even with numeric prefixes, use descriptive names (e.g., `10-backup-kernel.hook`).

Understanding hook execution order ensures your custom automation works predictably and reliably across package operations.

