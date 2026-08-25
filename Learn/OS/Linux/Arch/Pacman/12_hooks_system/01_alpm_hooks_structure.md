## Alpm Hooks Structure


### Overview

Alpm hooks allow pacman to run automated scripts before or after package transactions. They enable actions like rebuilding initramfs after kernel updates, updating desktop databases, or cleaning caches automatically.[1][5]

### Hook Directories

#### Default Hook Locations

Hooks are stored in two primary directories:

**System hooks (package-provided):**
```
/usr/share/libalpm/hooks/
```

Hooks installed by packages live here. These are managed by pacman and shouldn't be manually modified.[4][1]

**User hooks (custom):**
```
/etc/pacman.d/hooks/
```

User-created custom hooks go here. This is the default directory for custom hooks.[5][1][4]

#### Custom Hook Directories

Additional directories can be specified in `/etc/pacman.conf`:

```
[options]
HookDir = /etc/pacman.d/hooks/
HookDir = /usr/local/share/libalpm/hooks/
```

Multiple `HookDir` directives can be used. Hooks in later directories take precedence over hooks in earlier directories.[6][4]

**Note:** `HookDir` paths are absolute; the root path is not automatically prepended.[4][6]

### Hook File Format

#### File Naming

Hook files must:
- Be placed in a hook directory
- Have a `.hook` file extension
- Use descriptive names (e.g., `nvidia-update.hook`, `clear-cache.hook`)

**Example:**
```
/etc/pacman.d/hooks/orphan-check.hook
```

#### INI-Style Structure

Hooks use an INI-style format with two main sections:

**[Trigger]:** Defines when the hook runs
**[Action]:** Defines what the hook executes

### [Trigger] Section

The Trigger section specifies conditions that activate the hook.

#### Required Directives

**Operation:** Defines which transaction type triggers the hook

```
Operation = Install
Operation = Upgrade
Operation = Remove
```

Multiple `Operation` lines can be specified. Valid values:
- `Install` - Package installation
- `Upgrade` - Package upgrade
- `Remove` - Package removal

**Type:** Defines what kind of target triggers the hook

```
Type = Package
Type = File
```

Values:
- `Package` - Triggers on package operations
- `File` - Triggers on file operations

**Target:** Specifies which packages or files trigger the hook

```
Target = linux
Target = *
Target = usr/lib/modules/*/vmlinuz
```

Values can be:
- Specific package names
- Glob patterns with `*`
- File paths (when `Type = File`)

#### Example Trigger

```
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
```

This triggers on installation or upgrade of the `linux` package.

### [Action] Section

The Action section defines what the hook executes.

#### Required Directives

**Description:** Human-readable description shown during execution

```
Description = Updating initramfs...
```

**When:** Specifies when to run relative to the transaction

```
When = PreTransaction
When = PostTransaction
```

Values:
- `PreTransaction` - Before transaction commits
- `PostTransaction` - After transaction completes

**Exec:** Command to execute

```
Exec = /usr/bin/mkinitcpio -P
```

This can be any executable with arguments.

#### Optional Directives

**Depends:** List of executables that must exist for the hook to run

```
Depends = mkinitcpio
```

If dependencies are missing, the hook is silently skipped.

**AbortOnFail:** Whether to abort transaction if hook fails (default: no)

```
AbortOnFail
```

Without value, this enables aborting on failure.

**NeedsTargets:** Pass trigger targets to the Exec command

```
NeedsTargets
```

When enabled, triggered targets are passed as arguments to the command.

### Complete Hook Examples

#### Example 1: Orphan Package Notification

Notify when packages become orphaned:

```
# /etc/pacman.d/hooks/orphan-check.hook
[Trigger]
Operation = Remove
Operation = Install
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Checking for orphaned packages...
When = PostTransaction
Exec = /usr/bin/bash -c "/usr/bin/pacman -Qtd || /usr/bin/echo '=> None found.'"
```

This checks for orphans after any package operation.[3][5]

#### Example 2: Cache Cleaning

Automatically clean package cache after upgrades:

```
# /etc/pacman.d/hooks/paccache-clean.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning package cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk3
```

This keeps only the 3 most recent versions after transactions.

#### Example 3: NVIDIA Module Update

Rebuild NVIDIA modules after kernel updates:

```
# /etc/pacman.d/hooks/nvidia-update.hook
[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = nvidia
Target = linux

[Action]
Description = Updating NVIDIA module...
When = PostTransaction
Depends = nvidia-dkms
Exec = /usr/bin/dkms autoinstall
```

This ensures NVIDIA drivers are rebuilt when the kernel or driver updates.

#### Example 4: Desktop Database Update

Update desktop file database when .desktop files change:

```
# /etc/pacman.d/hooks/update-desktop-database.hook
[Trigger]
Type = File
Operation = Install
Operation = Upgrade
Operation = Remove
Target = usr/share/applications/*.desktop

[Action]
Description = Updating desktop file database...
When = PostTransaction
Exec = /usr/bin/update-desktop-database --quiet
```

This triggers on .desktop file changes using file-based matching.

### Hook Execution Order

#### Precedence Rules

When multiple hooks match the same trigger:

1. Hooks are sorted alphabetically by filename
2. Hooks in later `HookDir` directories override earlier ones with the same name
3. All matching hooks execute in sorted order

#### Execution Timing

**PreTransaction hooks:**
- Run before any file operations
- Can abort transaction if `AbortOnFail` is set
- Useful for validation or preparation

**PostTransaction hooks:**
- Run after all file operations complete
- Cannot abort the transaction
- Useful for cleanup, notifications, or system updates

### Hook Limitations

**Not interactive:** Hooks cannot prompt for user input. Pacman hooks are non-interactive by design.[1]

**Root context:** Hooks run with root privileges as part of the pacman process.[2]

**No output capture:** Hook output goes to stdout/stderr; pacman doesn't capture or process it.

**Execution order:** Can't guarantee order between different hooks beyond alphabetical sorting.

### Debugging Hooks

#### Test Hook Execution

View which hooks would run without executing:

```
pacman -S package_name --print
```

Check pacman output for "running" messages showing hook execution.

#### Verbose Output

Enable debug mode to see hook details:

```
pacman -S package_name --debug
```

This shows hook matching and execution information.

#### Check Hook Syntax

Validate hook file syntax by reading it:

```
cat /etc/pacman.d/hooks/your-hook.hook
```

Ensure proper INI format with correct section headers and directives.

### Best Practices

**Descriptive names:** Use clear, descriptive hook filenames indicating their purpose.

**Specific targets:** Target specific packages when possible rather than using `Target = *` to avoid unnecessary executions.

**Error handling:** Include error checking in Exec commands, especially for critical operations.

**Dependencies:** Specify `Depends` to prevent hooks from failing when required executables are missing.

**AbortOnFail judiciously:** Only use for critical operations where failure should prevent package installation.

**Document hooks:** Add comments in hook files explaining their purpose and behavior.

**Test before deploying:** Test custom hooks on non-production systems first.

**Minimal logic:** Keep hooks simple; use external scripts for complex operations.

**Consider performance:** Avoid resource-intensive operations in hooks that run frequently.

Alpm hooks provide powerful automation capabilities for maintaining system consistency and automating routine tasks during package management operations.

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Use Pacman Hooks to Cleanup Disk Space - archlinux https://www.reddit.com/r/archlinux/comments/1fgs5ex/use_pacman_hooks_to_cleanup_disk_space/
[3] pacman/Tips and tricks - ArchWiki https://wiki.archlinux.org/title/Pacman/Tips_and_tricks
[4] pacman.conf(5) https://pacman.archlinux.page/pacman.conf.5.html
[5] Pacman - Stéphane's cheat sheets https://cheatsheets.stephane.plus/distros/arch-based/pacman/
[6] pacman.conf(5) - Arch manual pages https://man.archlinux.org/man/pacman.conf.5.en
[7] desbma/pacman-hooks: Arch Linux ... https://github.com/desbma/pacman-hooks
[8] [SOLVED] New "HOOKS" configuration / Pacman & ... https://bbs.archlinux.org/viewtopic.php?id=159203
[9] How to Use Pacman in Arch Linux https://smarttech101.com/how-to-use-pacman-in-arch-linux
[10] A friendly guide to Pacman on Arch Linux and Arch-based ... https://www.youtube.com/watch?v=Napx5_6iBJ4

