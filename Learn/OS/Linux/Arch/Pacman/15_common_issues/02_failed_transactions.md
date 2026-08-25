## Failed Transactions


### Overview

Failed pacman transactions occur when package installations, upgrades, or removals cannot complete successfully. Understanding failure causes and recovery procedures is essential for maintaining a functional Arch Linux system.

### Common Failure Types

#### Transaction Initialization Failures

**Database lock errors:**
```
error: failed to init transaction (unable to lock database)
```

**Cause:** Lock file exists from previous operation or concurrent pacman instance.

**Solution:**
```
sudo rm /var/lib/pacman/db.lck
sudo pacman -Syu
```

**Database not valid:**
```
error: failed to prepare transaction (database is not valid)
```

**Cause:** Corrupted database files.

**Solution:**
```
sudo pacman -Syy
sudo pacman -Dk
```

#### Dependency Conflicts

**Conflicting dependencies:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-a: requires package-b>=1.0
:: package-b: requires package-a<1.0
```

**Cause:** Circular or incompatible dependency requirements.

**Solution:**
```
sudo pacman -Syu  # Update all packages together
```

**Unresolvable dependencies:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: installing package-a breaks dependency 'old-package' required by package-b
```

**Cause:** Package conflicts with existing installations.

**Solution:**
```
sudo pacman -S package-a package-b  # Update both simultaneously
```

Or:
```
sudo pacman -Rdd package-b  # Remove conflicting package (dangerous)
sudo pacman -S package-a
```

#### File Conflicts

**Conflicting files:**
```
error: failed to commit transaction (conflicting files)
package-name: /usr/bin/program exists in filesystem
Errors occurred, no packages were upgraded.
```

**Cause:** File already exists, owned by another package or untracked.

**Solutions:**

**Check file ownership:**
```
pacman -Qo /usr/bin/program
```

**If owned by another package:**
```
sudo pacman -S --overwrite /usr/bin/program package-name
```

**If untracked:**
```
sudo rm /usr/bin/program
sudo pacman -S package-name
```

**Override all conflicts (use cautiously):**
```
sudo pacman -S --overwrite '*' package-name
```

#### Disk Space Errors

**Insufficient space:**
```
error: failed to commit transaction (not enough free disk space)
error: not enough free disk space
```

**Check available space:**
```
df -h /
df -h /var
```

**Solution:**
```
sudo paccache -rk1        # Clean package cache
sudo pacman -Scc          # Remove all cache
sudo journalctl --vacuum-time=2weeks  # Clean logs
sudo pacman -Rns $(pacman -Qdtq)     # Remove orphans
```

Then retry:
```
sudo pacman -Syu
```

#### Download Failures

**Failed to retrieve file:**
```
error: failed retrieving file 'package.pkg.tar.zst' from mirror.example.com : Operation timed out
error: failed to commit transaction (download library error)
```

**Causes:**
- Network connectivity issues
- Mirror problems
- Timeout settings

**Solutions:**

**Update mirrors:**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Refresh databases:**
```
sudo pacman -Syy
```

**Disable timeout:**
```
sudo pacman -Syu --disable-download-timeout
```

**Clean cache and retry:**
```
sudo pacman -Scc
sudo pacman -Syu
```

#### Signature Verification Failures

**Invalid or corrupted package:**
```
error: package-name: signature from "user@archlinux.org" is unknown trust
error: failed to commit transaction (invalid or corrupted package)
```

**Cause:** Outdated keyring or corrupted signatures.

**Solution:**
```
sudo pacman -Sy archlinux-keyring
sudo pacman-key --refresh-keys
sudo pacman -Syu
```

**If persistent:**
```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu
```

#### Scriptlet Failures

**Install script errors:**
```
error: command failed to execute correctly
warning: scriptlet failed to complete successfully
```

**Cause:** Pre/post install scripts encountered errors.

**Solutions:**

**Check logs:**
```
journalctl -b | grep -i error
tail -n 50 /var/log/pacman.log
```

**Skip scriptlets (temporary):**
```
sudo pacman -S --noscriptlet package-name
```

**Reinstall package:**
```
sudo pacman -S package-name
```

### Interrupted Transactions

#### Mid-Transaction Interruption

**Symptoms:**
- Ctrl+C during installation
- System crash during upgrade
- Network disconnection during download

**Recovery steps:**

**1. Remove lock file:**
```
sudo rm /var/lib/pacman/db.lck
```

**2. Check for partial installations:**
```
sudo pacman -Dk
```

**3. Clear potentially corrupted cache:**
```
sudo pacman -Scc
```

**4. Complete the transaction:**
```
sudo pacman -Syu
```

**5. Verify integrity:**
```
pacman -Qkk
```

#### Partial Package Installation

**Package extracted but not registered:**

**Symptoms:**
- Files exist on filesystem
- Package not in database
- Dependency errors

**Solution:**
```
sudo pacman -S --overwrite '*' package-name
```

This reinstalls and properly registers the package.

### Transaction Rollback

#### Pacman Does Not Support Rollback

Unlike some package managers, pacman **does not** automatically rollback failed transactions. Manual intervention is required.

#### Manual Rollback Procedures

**After failed upgrade:**

**1. Identify failed packages:**
```
grep "error:" /var/log/pacman.log | tail -20
```

**2. Downgrade from cache:**
```
sudo pacman -U /var/cache/pacman/pkg/package-old-version.pkg.tar.zst
```

**3. Hold problematic packages:**
```
# Add to /etc/pacman.conf
IgnorePkg = problematic-package
```

**4. Report issue and wait for fix**

### Database Corruption Recovery

#### Symptoms

```
error: could not open file /var/lib/pacman/local/package/desc
error: failed to prepare transaction (database is not valid)
```

#### Recovery Procedures

**1. Check database integrity:**
```
sudo pacman -Dk
```

**2. Refresh sync databases:**
```
sudo pacman -Syy
```

**3. Reinstall corrupted package:**
```
sudo pacman -S package-name --overwrite '*'
```

**4. If widespread corruption, rebuild database:**
```
sudo pacman -S $(pacman -Qq) --overwrite '*'
```

**Warning:** This reinstalls all packages and takes significant time.

### Network-Related Failures

#### Timeout Issues

**Symptoms:**
```
error: failed retrieving file: Operation timed out after 10000 milliseconds
```

**Solutions:**

**Disable timeout:**
```
sudo pacman -Syu --disable-download-timeout
```

**Configure XferCommand with longer timeout:**
```
# /etc/pacman.conf
XferCommand = /usr/bin/curl --connect-timeout 120 -C - -f -o %o %u
```

**Switch mirrors:**
```
sudo reflector --country 'YourCountry' --latest 10 --save /etc/pacman.d/mirrorlist
```

#### SSL/TLS Errors

**Symptoms:**
```
error: failed retrieving file: SSL certificate problem
```

**Solutions:**

**Update ca-certificates:**
```
sudo pacman -S ca-certificates
```

**Check system time:**
```
timedatectl status
sudo timedatectl set-ntp true
```

**Temporarily use HTTP (insecure):**
```
sudo reflector --protocol http --latest 20 --save /etc/pacman.d/mirrorlist
```

### Conflict Resolution Strategies

#### Resolving Package Conflicts

**Multiple packages provide the same file:**

**Example:**
```
:: package-a and package-b are in conflict (both provide /usr/bin/tool)
```

**Solution:**
```
sudo pacman -S package-a
:: package-a and package-b are in conflict. Remove package-b? [y/N] y
```

Allow pacman to remove the conflicting package.

#### Dependency Loop Breaking

**Circular dependencies:**

**Symptoms:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-a: requires package-b
:: package-b: requires package-a
```

**Solution:**
```
sudo pacman -S package-a package-b --overwrite '*'
```

Install both simultaneously.

### Emergency Recovery

#### Broken Pacman

If pacman itself is broken:

**Using pacman-static:**
```
wget https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```

#### Chroot Recovery

For systems that won't boot:

**1. Boot from Arch installation media**

**2. Mount system:**
```
mount /dev/sdXn /mnt
mount /dev/sdXn /mnt/boot  # If separate boot partition
```

**3. Chroot:**
```
arch-chroot /mnt
```

**4. Fix pacman issues:**
```
rm /var/lib/pacman/db.lck
pacman -Syu
```

**5. Exit and reboot:**
```
exit
reboot
```

### Preventive Measures

#### Pre-Transaction Checks

**Before major upgrades:**

**1. Read Arch news:**
```
https://archlinux.org/news/
```

**2. Check available space:**
```
df -h /
```

**3. Update keyring first:**
```
sudo pacman -Sy archlinux-keyring
```

**4. Backup critical **
```
sudo rsync -av /etc /backup/etc-$(date +%Y%m%d)
```

**5. Have rescue media ready:**
Keep Arch installation USB accessible.

#### Safe Update Practices

**Update regularly:** Frequent small updates are safer than infrequent large ones.

**Avoid partial upgrades:** Always use `pacman -Syu`, never `pacman -Sy package-name`.

**Test on non-critical systems:** Test updates on development machines first.

**Monitor during updates:** Watch for warnings and errors during transactions.

**Keep cache:** Maintain package cache for downgrade capability.

### Logging and Diagnostics

#### Check Transaction Logs

**Recent pacman operations:**
```
tail -n 100 /var/log/pacman.log
```

**Failed transactions:**
```
grep "error:" /var/log/pacman.log
```

**Last transaction:**
```
grep "starting full system upgrade" /var/log/pacman.log | tail -1
```

**Today's operations:**
```
grep "$(date +%Y-%m-%d)" /var/log/pacman.log
```

#### System Journal

**Pacman-related errors:**
```
journalctl -u pacman.service -b
journalctl | grep -i pacman | tail -50
```

**Boot errors after failed upgrade:**
```
journalctl -b -p err
```

### Best Practices

**Read error messages carefully:** Errors often indicate the exact solution.

**Check news before updating:** Manual intervention announcements prevent failures.

**Maintain adequate disk space:** Keep 20-30% free on root partition.

**Update keyring regularly:** Old keyrings cause signature failures.

**Use reliable mirrors:** Fast, stable mirrors prevent download failures.

**Don't force solutions:** Understand why a failure occurred before overriding.

**Document recovery steps:** Keep notes on how you resolved issues.

**Test recovery procedures:** Understand recovery before emergencies.

**Backup before major changes:** System snapshots enable easy rollback.

**Report bugs:** Help improve Arch by reporting reproducible failures.

Proper handling of failed transactions minimizes system downtime and prevents cascading issues that could require complete reinstallation

