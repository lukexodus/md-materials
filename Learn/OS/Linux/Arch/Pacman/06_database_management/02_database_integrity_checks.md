## Database Integrity Checks


### Package File Verification

#### Basic File Presence Check

To verify that all files installed by a package are present on the system, use the `-Qk` flag:[1][2][3]

```
pacman -Qk package_name
```


This checks if files from the package still exist on the filesystem. It queries the local package database and verifies file presence.[1][2]

**Check all installed packages:**
```
pacman -Qk
```


This iterates through all installed packages and reports any missing files.[2]

#### Thorough Integrity Check

Pass the `-k` flag twice for a more comprehensive verification:[3][1][2]

```
pacman -Qkk package_name
```


The double `-kk` performs an extensive check including:[3]
- File presence verification
- File size comparison
- Modification time checks
- File permissions verification
- MD5 checksum validation
- SHA256 checksum validation

**Check all packages thoroughly:**
```
pacman -Qkk
```


This provides detailed integrity information for every installed package.[3]

### Understanding Check Output

#### Output Format

The thorough check (`-Qkk`) produces detailed output showing the status of each file:[3]

```
package_name: 1234 total files, 0 altered files
warning: package_name: /path/to/file (Size mismatch)
warning: package_name: /path/to/file (Modification time mismatch)
warning: package_name: /path/to/file (MD5 checksum mismatch)
```


**Status indicators:**
- **No output:** All files are intact and unmodified
- **warning:** Files have been modified or are missing
- **Size mismatch:** File size differs from original
- **Modification time mismatch:** File timestamp changed
- **MD5/SHA256 checksum mismatch:** File contents modified
- **Permission mismatch:** File permissions changed

#### Filtering Results

Show only packages with issues using grep:[2][3]

```
pacman -Qkk 2>&1 | grep -v "0 altered files"
```


This displays only packages with modified or missing files.[3]

**Show missing files only:**
```
pacman -Qkk 2>&1 | grep "missing files"
```

**Show checksum mismatches:**
```
pacman -Qkk 2>&1 | grep "checksum"
```


### Advanced Integrity Checking with paccheck

#### Installing paccheck

The `paccheck` utility from the `pacutils` package provides more advanced integrity checking:[4][1]

```
sudo pacman -S pacutils
```


#### Basic paccheck Usage

Check all installed packages for integrity:[4]

```
paccheck --md5sum --quiet
```


This performs MD5 checksum verification on all package files and displays only packages with issues.[4]

**Available options:**
- `--md5sum` - Verify MD5 checksums
- `--sha256sum` - Verify SHA256 checksums
- `--file-properties` - Check file properties (permissions, ownership)
- `--quiet` - Show only packages with issues
- `--depends` - Check dependencies
- `--opt-depends` - Check optional dependencies

**Comprehensive check:**
```
paccheck --md5sum --sha256sum --file-properties --quiet
```

This performs complete validation including checksums and file properties.[4]

### Package Signature Verification

#### Automatic Verification During Installation

Pacman automatically verifies package integrity during installation using GPG signatures:[5][6]

```
(1/1) checking keys in keyring
(1/1) checking package integrity
```


This validation depends on the `SigLevel` setting in `/etc/pacman.conf`.[1]

#### Signature Verification Errors

**Marginal trust error:**
```
error: package_name: signature from "..." is marginal trust
error: failed to commit transaction (invalid or corrupted package)
```


**Common causes:**
- Outdated GPG keyring
- Corrupted package signatures
- GPG configuration issues

**Resolution:**
```
sudo pacman -Sy archlinux-keyring
sudo pacman-key --refresh-keys
sudo pacman -Syu
```


This updates the keyring and refreshes key signatures.[7]

#### Keyring Reinitialization

For persistent signature issues, reinitialize the keyring:[6]

```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


This completely rebuilds the GPG keyring from scratch.[6]

### Database Verification

#### Check Database Consistency

Verify the integrity of the local package database using `-D` operations:[8]

```
sudo pacman -Dk
```


This checks the package database structure for consistency issues.[8]

#### Rebuild Corrupted Database

If the database is corrupted, reinstall all packages to rebuild it:[2]

```
LC_ALL=C.UTF-8 pacman -Qk 2>/dev/null | grep -v ' 0 missing files' | cut -d: -f1 | while read -r package; do
  pacman -S "$package" --noconfirm
done
```


This identifies packages with issues and reinstalls them, rebuilding database entries.[2]

### Automated Integrity Checking

#### Scheduled Integrity Checks

Create a systemd timer for regular integrity checks:

```
# /etc/systemd/system/pacman-integrity-check.service
[Unit]
Description=Pacman Package Integrity Check

[Service]
Type=oneshot
ExecStart=/usr/bin/paccheck --md5sum --quiet
StandardOutput=journal
```

```
# /etc/systemd/system/pacman-integrity-check.timer
[Unit]
Description=Weekly Pacman Integrity Check

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
```

Enable the timer:
```
sudo systemctl enable --now pacman-integrity-check.timer
```

#### Integrity Check Scripts

Create a script to automate integrity checking and reporting:

```bash
#!/bin/bash
# Check package integrity and report issues

echo "Checking package integrity..."
ISSUES=$(pacman -Qkk 2>&1 | grep -v "0 altered files")

if [ -z "$ISSUES" ]; then
  echo "All packages verified successfully"
else
  echo "Issues found:"
  echo "$ISSUES"
fi
```

### Repairing Integrity Issues

#### Reinstall Modified Packages

For packages with integrity issues, reinstall them:[2]

```
sudo pacman -S package_name
```


This downloads fresh package files and reinstalls, restoring original files.[2]

**Force reinstall with overwrite:**
```
sudo pacman -S --overwrite "*" package_name
```

This reinstalls and overwrites all files, including modified ones.[2]

#### Reinstall All Packages with Issues

Identify and reinstall all packages with integrity problems:

```
pacman -Qkk 2>&1 | grep -v "0 altered files" | cut -d: -f1 | sort -u | xargs sudo pacman -S --noconfirm
```

This finds packages with issues and reinstalls them automatically.

### Configuration File Handling

#### Expected Modifications

Configuration files in `/etc/` are expected to be modified by users. Integrity checks reporting modifications to configuration files are normal and not concerning.[2]

**View backup file status:**
```
pacman -Qii package_name
```


This shows which configuration files have been modified and which remain unmodified.[2]

### Common Integrity Issues

#### Missing Files

Files may be missing if:
- Manually deleted by user
- Removed by other software
- Disk corruption
- Incomplete installation

**Resolution:** Reinstall the package to restore missing files.

#### Checksum Mismatches

Checksum mismatches indicate:
- User modifications (especially in `/etc/`)
- File corruption
- Malware or security compromise
- Normal updates to runtime-generated files

**Resolution:** Investigate the cause before reinstalling. User modifications to configuration files are expected and safe.

#### Permission Mismatches

Permission changes may result from:
- Manual chmod/chown operations
- Security hardening modifications
- Incorrect restoration from backups

**Resolution:** Reinstall package or manually correct permissions.

### Best Practices

**Regular checks:** Perform integrity checks periodically to detect issues early.[4]

**After system issues:** Run integrity checks after crashes, power failures, or disk errors.

**Before major changes:** Verify system integrity before major upgrades or system modifications.

**Document modifications:** Keep records of intentional file modifications to distinguish them from problems.

**Use paccheck for automation:** The `paccheck` utility provides scriptable, precise integrity validation.[4]

**Don't panic on warnings:** Configuration file modifications are normal and expected.[2]

Sources
[1] [SOLVED] How to check integrity of package files / Pacman ... https://bbs.archlinux.org/viewtopic.php?id=195645
[2] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[3] Checking Installed Package Integrity (   Checksums/File Changes) https://buymeacoffee.com/politictech/arch-linux-checking-installed-package-integrity-checksums-file-changes
[4] Check all installed packages for integrity - Pacman & AUR helpers https://forum.endeavouros.com/t/check-all-installed-packages-for-integrity/5297
[5] ELI5: Does pacman -S automatically verify package integrity? - Reddit https://www.reddit.com/r/archlinux/comments/69n2ty/eli5_does_pacman_s_automatically_verify_package/
[6] Arch Linux ARM • View topic - Package integrity check failing https://archlinuxarm.org/forum/viewtopic.php?f=15&t=16707
[7] Pacman update error, corrupted packages - Manjaro Linux Forum https://forum.manjaro.org/t/pacman-update-error-corrupted-packages/114336
[8] pacman(8) https://pacman.archlinux.page/pacman.8.html
[9] How to check file system integrity in Linux? - Tencent Cloud https://www.tencentcloud.com/techpedia/112534
[10] Cannot upgrade Arch Linux (pacman -Syu not working) https://stackoverflow.com/questions/35251359/cannot-upgrade-arch-linux-pacman-syu-not-working

