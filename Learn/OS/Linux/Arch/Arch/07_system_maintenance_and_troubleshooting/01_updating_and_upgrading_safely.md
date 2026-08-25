## Updating and Upgrading Safely


### Update vs Upgrade Distinction

**Update (`-Sy`)**: Synchronizes local package database with remote mirrors.[1][2]

**Upgrade (`-Su`)**: Replaces installed packages with newer versions.[1]

**Combined (`-Syu`)**: Standard full system upgrade recommended by Arch.[2][1]

### Safe Upgrade Process

#### Pre-Upgrade Preparation

**Read Arch News**: Check https://archlinux.org/news/ before upgrading.[1]

**Critical Warnings**: Manual intervention announcements appear on front page.[1]

**System Backup**: Create backup of critical data before major upgrades.[1]

**Verify Network**: Ensure stable internet connection.[1]

#### Full System Upgrade

**Standard Command**: `sudo pacman -Syu`.[3][2][1]

**Execution**:[1]
```bash
sudo pacman -Syu
```

**Process**:[2][1]
1. Synchronizes package databases[2]
2. Checks for available updates[2]
3. Displays upgrade list[2]
4. Prompts for confirmation[2]
5. Downloads packages[2]
6. Installs updates[2]

**Review Changes**: Examine package list before confirming.[1]

#### Partial Upgrades Warning

**Critical Rule**: Never perform partial upgrades.[3][1]

**Dangerous Patterns**:[3][1]
```bash
# WRONG: Update database only
sudo pacman -Sy

# WRONG: Install after database update without upgrade
sudo pacman -Sy package_name

# CORRECT: Full upgrade
sudo pacman -Syu
sudo pacman -S package_name
```

**Consequences**: Dependency version mismatches causing system instability.[3][1]

**Exception**: None; always use full upgrades.[1]

### Handling Updates

#### Review Update List

**Package Count**: Note number of packages upgrading.[2]

**Size**: Check total download size.[2]

**Critical Packages**: Pay attention to kernel, systemd, glibc updates.[1]

**Example Output**:[2]
```
Packages (42) [upgrade list]
Total Download Size:   152.00 MiB
Total Installed Size: 624.00 MiB
Net Upgrade Size:      12.00 MiB
```

#### Confirming Upgrades

**Proceed Prompt**: `Proceed with installation? [Y/n]`.[2]

**Accept**: Press Enter or type `Y`.[2]

**Cancel**: Type `n` to abort.[2]

**Automatic Confirmation**: `--noconfirm` flag skips prompts (use carefully).[3]

### Post-Upgrade Actions

#### Reboot Requirements

**Kernel Updates**: Reboot required to use new kernel.[4][1]

**systemd Updates**: Reboot recommended for full effect.[1]

**Graphics Drivers**: May require restart for graphical environment.[1]

**Check Running Kernel**: `uname -r` shows current kernel.[5]

**Check Installed Kernel**: `pacman -Q linux` shows installed version.[5]

#### Service Restarts

**Daemon-reload**: After systemd unit changes:[6]
```bash
sudo systemctl daemon-reload
```

**Service Restart**: Restart affected services:[6]
```bash
sudo systemctl restart servicename
```

**List Failed Services**: Check for issues:[6]
```bash
systemctl list-units --failed
```

### Handling Problematic Updates

#### Package Conflicts

**Conflict Message**:[1]
```
error: failed to commit transaction (conflicting files)
package-name: /path/to/file exists in filesystem
```

**Resolution Steps**:[1]
1. Identify conflicting package[1]
2. Determine which package owns file[1]
3. Backup file if necessary[1]
4. Remove or force overwrite[1]

**Forced Overwrite** (Careful):[1]
```bash
sudo pacman -Syu --overwrite='*'
```

#### Signature Failures

**Invalid Signatures**:[7]
```
error: package-name: signature from "..." is invalid
```

**Resolution**:[7]
```bash
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```

**Key Refresh**:[7]
```bash
sudo pacman-key --refresh-keys
```

#### Database Corruption

**Error Message**:[1]
```
error: could not open file /var/lib/pacman/local/package-name/desc
```

**Resolution**:[1]
```bash
sudo rm -rf /var/lib/pacman/sync/*
sudo pacman -Syy
```

### Upgrade Frequency

#### Recommended Schedule

**Weekly Updates**: Minimum recommendation for desktop systems.[3][2]

**Daily Updates**: Acceptable for active users.[3]

**After Extended Absence**: Special care required after months without updates.[1]

#### Long Gaps Handling

**Extended Downtime**: Systems idle for 3+ months need careful upgrade.[1]

**Staged Approach**:[1]
1. Read all Arch news since last update[1]
2. Update archlinux-keyring first[1]
3. Perform full system upgrade[1]
4. Address any conflicts[1]
5. Reboot system[1]

**Command Sequence**:[1]
```bash
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```

### Advanced Upgrade Options

#### Download Only

**Purpose**: Download packages without installing.[2][1]

**Command**: `sudo pacman -Syw`.[1]

**Use Case**: Prepare for offline installation later.[1]

#### Ignore Packages

**Temporarily Skip**: Exclude specific packages from upgrade:[3][1]
```bash
sudo pacman -Syu --ignore=package_name
```

**Multiple Packages**:[1]
```bash
sudo pacman -Syu --ignore=package1,package2
```

**Persistent Ignore**: Add to `/etc/pacman.conf`:[1]
```
IgnorePkg = package_name
```

**Warning**: Creates partial upgrade; use sparingly.[1]

#### Force Refresh

**Force Database Download**: `sudo pacman -Syyu`.[8]

**Use Case**: Mirror sync issues or corrupted databases.[8]

### Monitoring Updates

#### Check Available Updates

**List Upgradable**: `pacman -Qu` lists packages with available updates.[2][1]

**Count**: `pacman -Qu | wc -l` shows number of updates [2].

**Detailed Information**: `checkupdates` from pacman-contrib:[1]
```bash
sudo pacman -S pacman-contrib
checkupdates
```

#### Package Information

**Upstream Version**: `pacman -Sii package_name`.[8]

**Changelog**: `pacman -Qc package_name`.[1]

**Dependencies**: `pactree package_name`.[1]

### Rollback and Downgrade

#### Package Cache

**Location**: `/var/cache/pacman/pkg/` stores downloaded packages.[1]

**Retention**: Old versions remain until cleaned.[1]

**Downgrade from Cache**:[1]
```bash
sudo pacman -U /var/cache/pacman/pkg/package-old-version.pkg.tar.zst
```

#### Downgrade Tool

**Installation**: `downgrade` from AUR automates rollback.[1]

**Usage**:[1]
```bash
downgrade package_name
# Interactive menu shows available versions
```

**Arch Archive**: Downloads from archive.archlinux.org if cache missing.[1]

### Troubleshooting Upgrade Issues

#### Dependency Breakage

**Symptoms**: Applications fail to start after upgrade.[1]

**Diagnosis**: Check for missing libraries:[1]
```bash
ldd /usr/bin/application
```

**Resolution**: Full system upgrade usually fixes:[1]
```bash
sudo pacman -Syu
```

#### Kernel Panic

**Symptoms**: System fails to boot after kernel upgrade.[1]

**Recovery**:[1]
1. Boot with fallback initramfs[1]
2. Regenerate initramfs[1]
3. Check bootloader configuration[1]

**Fallback Boot**: Select fallback entry in boot menu.[9]

#### Configuration File Conflicts

**Pacnew Files**: New configuration versions saved as `.pacnew`.[1]

**Pacdiff**: Compare and merge differences:[1]
```bash
sudo pacman -S pacman-contrib
sudo pacdiff
```

**Manual Merge**: Copy desired changes to original config.[1]

### Best Practices

**Regular Updates**: Weekly or biweekly schedule prevents large upgrades.[3]

**Read News First**: Always check Arch news before upgrading.[1]

**Full Upgrades Only**: Never perform partial upgrades.[3][1]

**Backup Critical Data**: Maintain current backups.[1]

**Test After Upgrade**: Verify system functionality.[1]

**Monitor Logs**: Check `journalctl -p err` for errors.[1]

**Reboot Promptly**: Don't delay kernel update reboots.[4]

**Keep Notes**: Document any manual interventions.[1]

**Maintain Stable Network**: Avoid interrupting downloads.[1]

**Review Package List**: Examine what's changing before confirming.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Using pacman Commands in Arch Linux [Beginner's Guide] - It's FOSS https://itsfoss.com/pacman-command/
[3] Asking for a Safe pacman command list and good practices ... - Reddit https://www.reddit.com/r/archlinux/comments/1g6ydx8/asking_for_a_safe_pacman_command_list_and_good/
[4] Kernel or mkinitcpio update: do i have to reboot? ... https://bbs.archlinux.org/viewtopic.php?id=295811
[5] Upgrade Kernel on Arch Linux https://linuxhint.com/upgrade-kernel-on-arch-linux/
[6] systemd - ArchWiki https://wiki.archlinux.org/title/Systemd
[7] Arch's Pacman 7.1 Package Manager Brings Stronger ... https://linuxiac.com/arch-pacman-7-1-package-manager-brings-stronger-signature-enforcement/
[8] Pacman Commands Cheat Sheet for Arch Linux - UbuntuMint https://www.ubuntumint.com/archlinux-pacman-cheatsheet/
[9] mkinitcpio - ArchWiki https://wiki.archlinux.org/title/Mkinitcpio

