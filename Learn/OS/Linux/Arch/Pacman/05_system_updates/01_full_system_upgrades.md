## Full System Upgrades


### Basic System Upgrade Command

The standard command to perform a full system upgrade in Arch Linux is:[1][2][3][4]

```
sudo pacman -Syu
```


This is the recommended and ideal way to update an Arch system.[1][3]

### Understanding the -Syu Flags

The command breaks down as follows:[4][3]

**-S (Sync):** Synchronize packages from repositories. Tells pacman to install or upgrade packages.[3][4]

**-y (Refresh):** Refresh the package database. Forces pacman to download the latest package database from configured repositories. Updates the local system cache with repository information.[4][3]

**-u (Upgrade):** Perform a full system upgrade. Pacman compares versions of installed packages with those in the repository and upgrades outdated ones. Actually upgrades the packages.[3][4]

### Upgrade Process Flow

When running `pacman -Syu`, the system follows this sequence:[3]

1. Synchronizes package databases from repositories
2. Downloads latest repository metadata
3. Compares installed package versions with repository versions
4. Identifies packages requiring upgrades
5. Resolves dependencies for all upgrades
6. Displays upgrade summary with package list and sizes
7. Prompts for confirmation
8. Downloads packages to cache directory
9. Verifies package signatures
10. Executes PreTransaction hooks
11. Upgrades packages in dependency order
12. Executes PostTransaction hooks
13. Updates package database
14. Logs transaction to `/var/log/pacman.log`

### Best Practices

#### Regular Updates

Arch Linux is a rolling release distribution requiring regular updates. The recommended practice is:[3]

- Update the system regularly (daily or weekly minimum)[3]
- Never leave the system without updates for extended periods[3]
- Always perform full system upgrades before installing new packages[4]

#### Read Before Upgrading

Before running system upgrades, check the Arch Linux website for important announcements:[3]

```
https://archlinux.org/news/
```


Critical updates sometimes require manual intervention or configuration changes announced on the news page.[3]

#### Avoid Partial Upgrades

**Critical warning:** Never perform partial upgrades:[2][4]

```
# DO NOT RUN THIS
pacman -Sy package_name
```


Running `-Sy` without `-u` synchronizes the package database but doesn't upgrade the system, which can lead to dependency issues. This creates a mismatch between installed packages and repository expectations, potentially breaking the system.[4]

**Always use:**
```
pacman -Syu package_name
```


This ensures the system is fully upgraded before installing new packages.[4]

### Advanced Upgrade Options

#### Force Database Refresh

To force re-download of package databases even if they appear up-to-date, use double `-y`:[8][3]

```
sudo pacman -Syyu
```


This is useful when:[3]
- Switching mirror servers
- Suspecting database corruption
- Mirrors are out of sync

The double `-yy` flag forces fresh downloads of all repository databases regardless of their current state.[3]

#### Download-Only Mode

Download packages without installing them using the `-w` flag:[5][3]

```
sudo pacman -Syuw
```


This separates the download and installation steps:[3]
- Downloads all upgrade packages to cache
- Does not perform installation
- Allows later offline installation

**Benefits:**
- Prepare for offline upgrades[3]
- Script and automate downloads[3]
- Separate bandwidth-intensive downloads from installation[5]

**Complete the upgrade later:**
```
sudo pacman -Su
```


This performs the upgrade using already-downloaded packages.[3]

#### Allow Downgrades

Enable package downgrades when repository versions are older than installed versions:[6]

```
sudo pacman -Syuu
```


The double `-uu` flag allows downgrades. This is useful when:[6]
- Switching from testing repositories to stable
- Reverting to older package versions
- Repository versions have been rolled back

### Interrupting Upgrades

#### Safe Interruption Points

Interrupting a system upgrade with `Ctrl+C` is safe at certain stages:[5]

**Safe to interrupt:**
- During database synchronization[5]
- While downloading packages[5]
- During package integrity checks[5]
- At the confirmation prompt before installation[5]

**Dangerous to interrupt:**
- During package installation[5]
- While packages are being extracted[5]
- During scriptlet execution[5]

Interrupting during installation increases risk of system breakage. If an upgrade is interrupted during installation, complete it immediately with `pacman -Syu`.[7]

#### Post-Interruption Recovery

If an upgrade is interrupted after the `-Sy` phase but before completion:[5]

1. The database has been synchronized
2. System is in a partial upgrade state
3. Must complete the upgrade before any other operations
4. Run `pacman -Syu` immediately to finish[5]

Never install new packages with `pacman -S` after an interrupted upgrade—complete the upgrade first.[5]

### Including AUR Packages

#### Official Repositories Only

Standard `pacman -Syu` updates only official repository packages (core, extra, multilib). It does not include AUR (Arch User Repository) packages.[1][4]

#### Updating AUR Packages

For systems with AUR packages, use an AUR helper like `yay` or `paru`:[8][1][4]

```
yay -Syu
```


Or:
```
paru -Syu
```

AUR helpers delegate to pacman for official packages and then update AUR packages. This provides a unified upgrade command for both official and AUR packages.[1][7]

**Separate approach:**
```
sudo pacman -Syu    # Update official repos
yay -Sua            # Update AUR only
```


### Post-Upgrade Maintenance

#### Remove Orphaned Packages

After upgrades, orphaned packages may accumulate. List them with:[3]

```
pacman -Qdt
```


Remove orphaned packages:
```
sudo pacman -Rns $(pacman -Qdtq)
```


**Warning:** Review the list before removing to avoid unintentionally deleting wanted packages.[3]

#### Clean Package Cache

Over time, the package cache grows significantly. Clean old versions:[3]

```
sudo pacman -Sc     # Remove uninstalled packages
sudo pacman -Scc    # Remove all cached packages
```


For more granular control, use `paccache` from `pacman-contrib`:
```
paccache -r         # Keep 3 most recent versions
paccache -rk1       # Keep only 1 version
```

### Handling Upgrade Issues

#### Dependency Conflicts

If the upgrade fails with dependency errors:[8]

1. Read the error message carefully
2. Check Arch Linux news for known issues
3. Identify conflicting packages
4. Remove or update conflicting packages manually
5. Retry the upgrade

**Example scenario:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-query: requires pacman<4.3
```


**Resolution:**
Update or remove the conflicting package:
```
sudo pacman -Rns package-query
sudo pacman -Syu
```


#### Full Database Refresh

When experiencing persistent issues, force full database refresh:[3]

```
sudo pacman -Syyu
```


This ensures repository databases are completely current.[3]

#### Check Mirror Status

If downloads are slow or failing, update mirror list:

```
sudo pacman-mirrors --fasttrack    # Manjaro
sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist  # Arch
```

Then retry the upgrade.

### Upgrade Verification

After completing an upgrade, verify system health:

```
pacman -Qk          # Check all package files
pacman -Qkk         # Thorough file verification
journalctl -xb      # Check system logs for errors
```

### Automation Considerations

When automating system upgrades, use `--noconfirm` cautiously:

```
sudo pacman -Syu --noconfirm
```

This skips confirmation prompts but may cause issues if manual intervention is required. Monitor automated upgrades carefully.

### Reboot Requirements

Some upgrades require system reboots, particularly:
- Kernel updates
- systemd updates
- Critical system library updates

Check if a reboot is needed after major upgrades and reboot when convenient.

Sources
[1] Is "sudo pacman -Syu" the ideal way to update an Arch ... https://www.reddit.com/r/archlinux/comments/9k7znt/is_sudo_pacman_syu_the_ideal_way_to_update_an/
[2] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[3] How to Update the System (`pacman -Syu`) on Arch Linux https://www.siberoloji.com/how-to-update-the-system-pacman--syu-on-arch-linux/
[4] Update your system. - Linux Docs - Fernando Cejas https://linux.fernandocejas.com/docs/how-to/update-your-system
[5] yes] Possible to safely stop upgrade? / Pacman & Package ... https://bbs.archlinux.org/viewtopic.php?id=169223
[6] Pacman equivalent to pamac upgrade --force-refresh https://forum.manjaro.org/t/pacman-equivalent-to-pamac-upgrade-force-refresh/152786
[7] Updating System in Terminal - Pacman & AUR helpers https://forum.endeavouros.com/t/updating-system-in-terminal/8107
[8] Cannot upgrade Arch Linux (pacman -Syu not working) https://stackoverflow.com/questions/35251359/cannot-upgrade-arch-linux-pacman-syu-not-working
[9] Full system update with pamac - Support https://forum.manjaro.org/t/full-system-update-with-pamac/173584
[10] Full system update is giving error on pacman upgrade https://forum.garudalinux.org/t/full-system-update-is-giving-error-on-pacman-upgrade/39236

