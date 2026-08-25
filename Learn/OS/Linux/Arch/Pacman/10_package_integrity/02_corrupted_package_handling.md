## Corrupted Package Handling


### Signs of Package Corruption

Corrupted packages may manifest through various symptoms:

**During download/installation:**
- Checksum verification failures
- Signature verification errors despite valid keys
- Extraction errors during installation
- Incomplete file lists
- Database entry inconsistencies

**Error messages:**
```
error: failed to commit transaction (invalid or corrupted package)
error: package-name: signature is invalid
error: could not open file: Unrecognized archive format
warning: could not fully load metadata for package-name
```

### Common Causes

**Network issues:** Interrupted downloads or transmission errors

**Disk problems:** Bad sectors, filesystem corruption, or insufficient space

**Mirror problems:** Corrupted files on the mirror server

**Cache corruption:** Damaged cached packages from previous downloads

**Memory errors:** RAM issues causing data corruption during operations

**Improper shutdown:** System crash or power loss during package operations

### Immediate Response

#### Clear Package Cache

Remove potentially corrupted cached packages:

```
sudo pacman -Scc
```

This deletes all cached packages, forcing fresh downloads. You'll need to confirm twice—once for cached packages and once for repository databases.

**Alternative (less aggressive):**
```
sudo pacman -Sc
```

This removes only uninstalled package caches, preserving currently installed versions.

#### Force Database Refresh

Re-download repository databases:

```
sudo pacman -Syy
```

The double `-y` forces complete database refresh even if they appear current. This ensures repository metadata is valid.

#### Retry Installation

After clearing the cache and refreshing databases:

```
sudo pacman -Syu
```

This downloads fresh packages and attempts installation again.

### Identifying Corrupted Packages

#### Check Specific Package Integrity

Verify a downloaded package before installation:

```
pacman -Qkk package_name
```

For installed packages, this checks file attributes. For packages in the cache, you can manually verify checksums.

#### List Cache Contents

Examine what's in the cache:

```
ls -lh /var/cache/pacman/pkg/ | grep package-name
```

Look for suspicious file sizes (much smaller than expected) or recent timestamps that don't match download attempts.

#### Verify Package Archive

Test if a cached package archive is valid:

```
tar -tzf /var/cache/pacman/pkg/package-name.pkg.tar.zst > /dev/null
```

If this produces errors, the archive is corrupted. For zstd-compressed packages:

```
zstd -t /var/cache/pacman/pkg/package-name.pkg.tar.zst
```

### Handling Specific Corruption Scenarios

#### Corrupted Database

If pacman's local database is corrupted:

**Symptoms:**
```
error: could not open file /var/lib/pacman/local/package-name/desc
error: failed to prepare transaction (database is not valid)
```

**Solution - Reinstall affected packages:**
```
sudo pacman -S package-name --overwrite '*'
```

This rebuilds the database entry for the package.

**Complete database restoration:**
```
sudo pacman -S $(pacman -Qnq) --overwrite '*'
```

This reinstalls all repository packages, regenerating their database entries. **Warning:** This is time-consuming and downloads many packages.

#### Corrupted Package in Cache

**Remove specific corrupted package:**
```
rm /var/cache/pacman/pkg/package-name-version.pkg.tar.zst
sudo pacman -S package-name
```

This deletes the corrupted cached file and downloads a fresh copy.

#### Mirror-Level Corruption

If a mirror consistently provides corrupted packages:

**Switch mirrors:**
```
sudo pacman-mirrors --fasttrack  # Manjaro
sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist  # Arch
```

Or manually edit `/etc/pacman.d/mirrorlist` to prioritize different mirrors.

**Force fresh download from new mirror:**
```
sudo pacman -Syy
sudo pacman -Scc
sudo pacman -Syu
```

### Preventing Package Corruption

#### Enable Download Verification

Ensure signature verification is enabled in `/etc/pacman.conf`:

```
[options]
SigLevel = Required DatabaseOptional
```

This catches corrupted packages during download before installation.

#### Check Disk Health

Monitor filesystem and disk status:

```
df -h  # Check disk space
sudo smartctl -H /dev/sda  # Check disk health (requires smartmontools)
sudo fsck /dev/sdXn  # Check filesystem (unmounted partitions only)
```

Insufficient disk space or failing hardware causes corruption.

#### Use Reliable Mirrors

Select stable, high-quality mirrors:

```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

HTTPS mirrors provide additional integrity protection during download.

#### Regular System Maintenance

**Keep cache manageable:**
```
sudo paccache -r  # Keep 3 recent versions
```

Large, old caches are more likely to contain corrupted files.

**Regular integrity checks:**
```
paccheck --sha256sum --quiet
```

Detects corruption in installed packages early.

### Recovery from Severe Corruption

#### Reinstall Pacman Itself

If pacman is corrupted and non-functional:

**Using cached package:**
```
sudo tar -xvf /var/cache/pacman/pkg/pacman-*.pkg.tar.zst -C /
sudo pacman -S --overwrite '*' pacman
```

**Using pacman-static:**
```
curl -L -o pacman-static https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```

The static version bypasses library dependencies.

#### Chroot Recovery

If the system won't boot due to corruption:

1. Boot from Arch installation media
2. Mount system partitions:
   ```
   mount /dev/sdXn /mnt
   mount /dev/sdXn /mnt/boot  # If separate boot partition
   ```
3. Chroot into the system:
   ```
   arch-chroot /mnt
   ```
4. Clear cache and reinstall:
   ```
   pacman -Scc
   pacman -Syyu
   ```
5. Exit and reboot:
   ```
   exit
   reboot
   ```

### Advanced Diagnostics

#### Check Download Integrity

Monitor downloads in real-time:

```
sudo pacman -Syu --debug
```

This provides verbose output showing download and verification steps.

#### Examine Pacman Logs

Review `/var/log/pacman.log` for patterns:

```
grep -i error /var/log/pacman.log | tail -20
grep -i warning /var/log/pacman.log | tail -20
```

Look for recurring errors with specific packages or mirrors.

#### Memory Test

If corruption persists across multiple packages:

```
memtest86+
```

Boot into memory testing to rule out RAM issues. Bad RAM causes random corruption.

### When to Report Issues

**Report to mirror operators:**
- Consistent corruption from specific mirrors
- Multiple users reporting same package corruption
- Corruption persists after multiple download attempts

**Report to package maintainers:**
- Corruption in package metadata (PKGBUILD)
- Signature issues with properly configured keyring
- Systematic issues affecting many users

**Report to Arch bug tracker:**
- Database corruption issues
- Pacman bugs causing corruption
- Repository-wide problems

### Best Practices

**Don't ignore warnings:** Address checksum or signature warnings immediately—they indicate potential corruption.

**Keep backups:** Maintain system snapshots or backups for quick recovery from severe corruption.

**Monitor disk health:** Regularly check SMART status and filesystem integrity.

**Use stable mirrors:** Avoid mirrors with frequent downtime or slow speeds.

**Adequate disk space:** Maintain at least 20-30% free space on root partition.

**Regular updates:** Outdated systems accumulate more issues during large updates.

**Clean cache periodically:** Remove old cached packages to prevent accumulation of corrupted files.

**Test after major updates:** Verify system functionality after significant upgrades to catch corruption early.

Package corruption is usually recoverable through cache clearing and re-downloading. Persistent corruption suggests underlying hardware or network issues requiring investigation.

