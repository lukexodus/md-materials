## Handling Broken Packages and Database Issues


### Types of Package Problems

**Corrupted Files**: Package archive damaged or incomplete.[1][2]

**Missing Dependencies**: Required packages unavailable.[2][1]

**Conflicting Packages**: Two packages trying to install same files.[1][2]

**Broken Installation**: Partial installation from interrupted process.[1]

**Database Corruption**: Pacman database files damaged.[2][1]

### Corrupted Package Archives

#### Identifying Corruption

**Checksum Mismatch**:[1]

```
==> Validating source files with sha256sums...
package.tar.gz ... FAILED
```

**Download Interruption**: Network disconnection during download.[1]

**File System Error**: Disk problem affecting package.[1]

#### Resolution Steps

**Delete Package**: Remove corrupted file from cache:[2][1]

```bash
sudo rm /var/cache/pacman/pkg/package.pkg.tar.zst
```

**Retry Download**: Re-download from mirrors:[1]

```bash
sudo pacman -S package_name
```

**Verify Checksum**: Ensure correct integrity:[1]

```bash
pacman -Qi package_name
```

**Change Mirror**: If specific mirror problematic:[1]

```bash
sudo reflector --country 'United States' --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syy
```

### Missing Dependencies

#### Identifying Missing Dependencies

**Error Message**:[1]

```
error: failed to prepare transaction (could not satisfy dependencies)
:: package_name: requires missing_package
```

**Check Dependency Graph**:[1]

```bash
pacman -Sii package_name
pactree package_name
```

#### Resolution

**Install Missing Dependency**:[1]

```bash
sudo pacman -S missing_package
```

**Automatic Resolution**: Normally pacman handles automatically.[1]

**Broken Dependency**: If dependency not available:[1]
1. Wait for package update[1]
2. Find alternative package[1]
3. Request from AUR maintainer[1]

**Orphaned Repository**: Package may require removed repository:[1]

```bash
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```

### Conflicting Files

#### File Ownership Conflicts

**Error Message**:[1]

```
error: failed to commit transaction (conflicting files)
package-a: /usr/lib/file.so exists in filesystem
package-b: /usr/lib/file.so exists in filesystem
```

**Identify Conflict**: Determine which package owns file:[2][1]

```bash
pacman -Qo /usr/lib/file.so
```

#### Resolving Conflicts

**Backup and Remove**:[1]

```bash
sudo mv /usr/lib/file.so /usr/lib/file.so.bak
sudo pacman -S package_name
```

**Forced Overwrite** (Risky):[1]

```bash
sudo pacman -S --overwrite='*' package_name
```

**Caution**: Only use if confident.[1]

**Determine Correct Owner**:[2]
1. Research which package should own file[2]
2. Remove incorrect package[2]
3. Reinstall correct package[2]

### Broken System Installation

#### Package Removal Halted

**Symptoms**: System in inconsistent state.[1]

**Causes**:[1]
- Interrupted upgrade[1]
- Forced shutdown during pacman operation[1]
- Corrupted transaction[1]

#### Recovery Process

**Fix Database**: `sudo pacman -Fyy` rebuilds file database:[1]

```bash
sudo pacman -Fyy
```

**Verify Integrity**: Check installed packages:[1]

```bash
pacman -Qi package_name
```

**Recover Transaction**: `sudo pacman -Syu` completes interrupted upgrade:[1]

```bash
sudo pacman -Syu
```

**Reinstall Affected**: Reinstall broken package:[1]

```bash
sudo pacman -S --force package_name
```

### Database Corruption

#### Database Location

**System Database**: `/var/lib/pacman/local/`.[2][1]

**Package Databases**: `/var/lib/pacman/sync/`.[2][1]

**Backup Location**: Pacman creates backups automatically.[1]

#### Detecting Database Corruption

**Error Messages**:[1]

```
error: could not open file /var/lib/pacman/local/package/desc
error: database corruption detected
```

**Verification**: Check database integrity:[1]

```bash
ls -la /var/lib/pacman/local/ | head
```

#### Recovery Procedures

**Rebuild Sync Database**:[2][1]

```bash
sudo rm -rf /var/lib/pacman/sync/*
sudo pacman -Syy
```

**Removes all cached repositories and re-downloads**.[1]

**Restore from Backup** (If Available):[1]

```bash
sudo cp /var/lib/pacman/local.backup/* /var/lib/pacman/local/
sudo pacman -Fyy
```

**Complete Rebuild** (Last Resort):[1]

```bash
sudo rm -rf /var/lib/pacman/local/*
sudo pacman -Syy
sudo pacman -Syu
```

**Warning**: This is destructive; try gentler methods first.[1]

### Partial Upgrade Issues

#### Recognizing Partial Upgrade

**Symptoms**:[1]
- System won't upgrade[1]
- Conflicting package versions[1]
- Dependency version mismatches[1]

**Cause**: Partial upgrade from `pacman -Sy` followed by `pacman -S`.[1]

#### Fixing Partial Upgrades

**Full Upgrade**: Complete the interrupted upgrade:[1]

```bash
sudo pacman -Syu
```

**Downgrade if Necessary**: Return to consistent state:[1]

```bash
sudo pacman -U /var/cache/pacman/pkg/package-oldversion.pkg.tar.zst
```

**Prevention**: Always use `pacman -Syu`, never `pacman -Sy` alone.[3][1]

### Broken Bootloader

#### Systemd-boot Issues

**Can't Boot**: System won't start.[4][5]

**Boot from Live Media**::[4]
1. Boot Arch live ISO[4]
2. Mount root: `mount /dev/sdXN /mnt`[4]
3. Mount boot: `mount /dev/sdXN /mnt/boot`[4]

**Reinstall Bootloader**:[5]

```bash
arch-chroot /mnt
bootctl install
```

**Verify Configuration**: `/boot/loader/loader.conf`.[5]

#### GRUB Issues

**Won't Boot**: System stuck.[6]

**Recovery Steps**:[6]
1. Boot live ISO[6]
2. Mount filesystems[6]
3. Chroot into system[6]
4. Regenerate GRUB config[6]

**Regenerate Configuration**:[6]

```bash
arch-chroot /mnt
grub-mkconfig -o /boot/grub/grub.cfg
```

### Orphaned Configurations

#### Leftover Config Files

**Symptom**: `.pacnew` files in system.[1]

**Cause**: Pacman preserves user configs during upgrades.[1]

**Identification**:[1]

```bash
find /etc -name "*.pacnew"
find /etc -name "*.pacsave"
```

**Review and Merge**:[1]

```bash
sudo pacdiff
```

**Manual Handling**:[1]

```bash
# Review differences
sudo diff /etc/config.conf /etc/config.conf.pacnew

# Copy if new version preferred
sudo cp /etc/config.conf.pacnew /etc/config.conf

# Delete pacnew file
sudo rm /etc/config.conf.pacnew
```

### Missing Package Manager

#### Pacman Broken

**Symptoms**: Pacman cannot run.[1]

**Recovery**:[1]
1. Boot live ISO[1]
2. Mount root filesystem[1]
3. Reinstall pacman[1]

**From Live Environment**:[1]

```bash
mount /dev/sdXN /mnt
arch-chroot /mnt
pacman -Syu pacman
```

### AUR Package Issues

#### Failed AUR Build

**Build Error**: Compilation fails.[7][1]

**Investigation**:[7]
1. Download PKGBUILD: `yay -G package_name`[7]
2. Review PKGBUILD[7]
3. Check for known issues[7]
4. Report to maintainer[7]

**Alternative Solutions**:[7]
- Use binary from community if available[7]
- Wait for maintainer update[7]
- Submit patch to AUR[7]

#### Dependency Conflicts

**Conflicting Requirements**:[1]

```
error: failed to prepare transaction (conflicting dependencies)
```

**Resolution**:[1]
1. Check what provides dependency[1]
2. Install appropriate version[1]
3. Downgrade if necessary[1]

### Filesystem Issues

#### Disk Full

**Symptoms**: Pacman operations fail with disk full error.[1]

**Check Space**:[1]

```bash
df -h
du -sh /var/cache/pacman/pkg/
```

**Free Space**:[1]
```bash
sudo pacman -Scc  # Clean cache
sudo pacman -Qdtq | sudo pacman -Rns -  # Remove orphans
```

#### Inode Exhaustion

**Symptoms**: "No space left on device" even with free space.[1]

**Check Inodes**:[1]

```bash
df -i
```

**Cause**: Too many small files.[1]

**Solution**: Remove temporary files or rebuild filesystem.[1]

### Emergency Recovery Mode

#### Boot to Rescue

**Fallback Initramfs**: Boot with fallback image:[8]
1. Select fallback boot entry[8]
2. System loads with all modules[8]

**Emergency Shell**: `break=postmount` parameter:[8]

```
options root=PARTUUID=... break=postmount
```

#### Chroot Recovery

**Mount and Enter Chroot**:[1]

```bash
mount /dev/sdXN /mnt
arch-chroot /mnt
```

**Fix Issues Inside Chroot**:[1]
- Reinstall packages[1]
- Rebuild initramfs[1]
- Reconfigure bootloader[1]

### Prevention Best Practices

**Regular Backups**: Keep current system backups.[1]

**Monitor Upgrades**: Watch upgrade process.[1]

**Read News**: Check Arch news before upgrading.[1]

**Slow Connection**: Don't upgrade on unreliable networks.[1]

**UPS Protection**: Use uninterruptible power supply.[1]

**Test Changes**: Build in test environment first.[1]

**Document System**: Maintain configuration notes.[1]

**Keep Live Media**: Have Arch ISO available for recovery.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] A beginner's guide to the Arch User Repository - tilde.town https://tilde.town/~kzimmermann/articles/aur_made_easy.html
[3] Asking for a Safe pacman command list and good practices ... - Reddit https://www.reddit.com/r/archlinux/comments/1g6ydx8/asking_for_a_safe_pacman_command_list_and_good/
[4] System time - ArchWiki https://wiki.archlinux.org/title/System_time
[5] ArchLinux Installation Guide https://gist.github.com/varunagrawal/d27eded739f59228eaf3b746907c6a64
[6] GRUB - ArchWiki https://wiki.archlinux.org/title/GRUB
[7] Notes on creating packages for the Arch User Repository (AUR) https://madskjeldgaard.dk/old-blog/aur-package-workflow/
[8] mkinitcpio - ArchWiki https://wiki.archlinux.org/title/Mkinitcpio

