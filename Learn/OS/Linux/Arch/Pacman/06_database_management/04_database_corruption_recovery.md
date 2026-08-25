## Database Corruption Recovery


### Signs of Database Corruption

A broken or corrupted pacman database may result in errors such as:[1]

```
error: failed to init transaction (unable to lock database)
error: database file for 'core' does not exist
error: could not find or read package
error: failed to commit transaction (invalid or corrupted package)
warning: database file for 'extra' is missing
```


These errors indicate issues like:[1]
- Database corruption
- Missing or accidentally deleted files
- Inconsistent metadata due to forced removals
- Interrupted transactions (system crash during upgrade)

### Safety Precautions

#### Backup the Database

Before attempting recovery, backup the database if still accessible:[1]

```
sudo cp -a /var/lib/pacman/ /var/lib/pacman.bak/
```


#### Use Live ISO if Needed

If your system is not booting, mount partitions and chroot into your system:[2][1]

```
# Boot from Arch installation media
mount /dev/sdXn /mnt
mount /dev/sdXn /mnt/boot  # If separate boot partition
arch-chroot /mnt
```


### Step 1: Check and Remove Database Lock

#### Remove Lock File

If pacman complains about a locked database:[3][4][1]

```
sudo rm /var/lib/pacman/db.lck
```


**Important:** Only do this if you're certain no pacman process is currently running.[1]

The lock file `/var/lib/pacman/db.lck` is created when pacman runs and prevents multiple instances from corrupting the database. If pacman crashes or is forcefully terminated, this file may remain and block future operations.[3]

#### Verify No Running Processes

Check for running pacman processes before removing the lock:[4]

```
ps -aux | grep -i pacman
```


If you see only the grep command itself, no other process is using pacman.[4]

### Step 2: Update Sync Databases

#### Refresh Repository Databases

If sync databases are missing or outdated, refresh them:[1]

```
sudo pacman -Sy
```


If that fails with missing files in `/var/lib/pacman/sync`, delete them and try again:[4][1]

```
sudo rm -f /var/lib/pacman/sync/*.db
sudo pacman -Sy
```


This downloads fresh `.db` files for all enabled repositories in `/etc/pacman.conf`.[5]

#### Force Complete Refresh

For persistent database issues, force re-download all databases:[5][1]

```
sudo pacman -Syy
```


### Step 3: Reinstall Broken Packages

#### Single Package Reinstallation

If a specific package has corrupted meta[6][1]

```
sudo pacman -S package-name --overwrite '*'
```


This forces reinstallation and overwrites any existing files.[1]

**Without dependency checks:**
```
sudo pacman -S --needed --noconfirm package-name
```


#### Recover Missing Package Metadata

If entire package directories are missing from `/var/lib/pacman/local/`, the files may still exist on your system:[1]

**Download package from archive:**
```
wget https://archive.archlinux.org/packages/p/package-name/package-name-version.pkg.tar.zst
```


**Reinstall to rebuild database entry:**
```
sudo pacman -U package-name-version.pkg.tar.zst --overwrite '*'
```


This reinstalls the package and re-registers it in the local database.[1]

### Step 4: Rebuild Database for Missing Entries

#### Identify Packages with Missing mtree

Use this command to find and reinstall packages with database corruption:[5]

```
pacman --dbonly -S $(LC_ALL=C pacman -Qkk 2>/dev/null | sed '/no mtree/!d; s/:.*//g')
```


**Explanation:**
- `pacman --dbonly -S` - Reinstalls packages but only modifies the database without extracting files
- `pacman -Qkk` - Checks integrity of installed packages
- `LC_ALL=C` - Ensures consistent locale settings for predictable output
- `sed '/no mtree/!d; s/:.*//g'` - Filters output to identify packages with missing mtree entries (indicator of database corruption)

### Step 5: Restore Complete Local Database

#### Method 1: Using pacrecover Script

The official method for complete database restoration:[7]

**Generate package lists:**
```
paclog-pkglist /var/log/pacman.log | ./pacrecover >files.list 2>pkglist.orig
```


This creates:
- `files.list` - Paths to locally available packages
- `pkglist.orig` - Packages missing from cache (must be downloaded)

**Restrict to repository packages:**
```
{ cat pkglist.orig; pacman -Slq; } | sort | uniq -d > pkglist
```


**Ensure base packages included:**
```
comm -23 <({ echo base ; expac -l '\n' '%E' base; } | sort) pkglist.orig >> pkglist
```


**Define recovery helper function:**
```bash
recovery-pacman() {
  pacman "$@" \
    --log /dev/null \
    --noscriptlet \
    --dbonly \
    --overwrite "*" \
    --nodeps \
    --needed
}
```


**Perform recovery:**
```
recovery-pacman -Sy
recovery-pacman -S $(cat files.list)
recovery-pacman -S $(cat pkglist)
```


#### Method 2: Reinstall All Packages

Reinstall all packages from the explicitly installed list:[1]

```
comm -12 <(pacman -Qqen | sort) <(pacman -Qq | sort) > pkglist.txt
sudo pacman -S --needed - < pkglist.txt
```


#### Method 3: Reinstall from Cache

If `/var/cache/pacman/pkg/` is intact, reinstall from cached packages:[1]

```
cd /var/cache/pacman/pkg/
sudo pacman -U *.pkg.tar.zst --overwrite '*' --noconfirm
```


This repopulates the local database from cached packages.[1]

### Step 6: Fix Mirror Configuration

#### Update Mirror List

A misconfigured or outdated mirror can break sync operations:[1]

```
sudo pacman -S reflector
sudo reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```


**Then retry:**
```
sudo pacman -Syy
```


### Step 7: Repair GPG Keyring

#### Regenerate Keys and Signatures

If pacman throws GPG signature errors:[8][1]

```
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


#### Complete Keyring Rebuild

For persistent signature issues, delete and rebuild the entire keyring:[1]

```
sudo rm -r /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


**Update archlinux-keyring first:**
```
sudo pacman -Sy archlinux-keyring
```


### Step 8: Check for Missing ALPM_DB_VERSION

#### Verify Database Version File

If database operations fail with "failed to initialise alpm library":[7]

```
ls /var/lib/pacman/local/ALPM_DB_VERSION
```


**If missing, run:**
```
sudo pacman-db-upgrade
sudo pacman -Sy
```


This recreates the database version file and synchronizes repositories.[7]

### Recovery from Pacman Cache

#### Create Empty Metadata Files

If package metadata is missing but files exist on the system:[6]

1. Identify the package and version
2. Create empty metadata files in `/var/lib/pacman/local/package-version/`
3. Reinstall with force:
   ```
   sudo pacman -U --force /var/cache/pacman/pkg/package.pkg.tar.zst
   ```


This allows pacman to reinstall and regenerate proper metadata.[6]

### Prevention Strategies

#### Best Practices

**Never interrupt pacman:** Especially during upgrades. Always let transactions complete.[1]

**Avoid --force:** Unless absolutely necessary, as it can cause file conflicts and orphan packages.[1]

**Enable automatic cache cleaning:**
```
sudo systemctl enable paccache.timer
sudo systemctl start paccache.timer
```


**Keep backups:** Of important directories like `/etc`, `/var/lib/pacman`, and `/boot`.[5]

**Use snapshots:** Consider using `timeshift` or `snapper` with Btrfs for snapshot-based system recovery.[2][1]

### Using pacman-contrib Tools

Install useful maintenance utilities:[1]

```
sudo pacman -S pacman-contrib
```


**Available tools:**
- `paccache` - Clean old cached packages
- `checkupdates` - Check for updates without syncing
- `paclog` - View pacman logs
- `pacdiff` - Identify modified config files

These tools help audit and fix underlying issues after database recovery.[1]

### Emergency Recovery with pacman-static

If pacman itself is broken and cannot run:[9][10]

```
curl -L -o pacman-static https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```

This static version bypasses library dependencies and can repair a broken pacman installation.[10][9]

Sources
[1] How to Recover from a Broken `pacman` Database on ... https://www.siberoloji.com/how-to-recover-from-a-broken-pacman-database-on-arch-linux/
[2] Recovering from a Corrupted Arch Linux Upgrade https://www.soimort.org/notes/170407
[3] Fixing pacman error : r/archlinux https://www.reddit.com/r/archlinux/comments/sijck2/fixing_pacman_error/
[4] [Solved] 'failed to synchronize all databases' Error in Arch https://itsfoss.com/failed-to-synchronize-all-databases/
[5] Fixing a Corrupt Pacman Database in Arch Linux - tsc.id.au https://tsc.id.au/til/2024/12/fixing-a-corrupt-pacman-database-in-arch-linux/
[6] [SOLVED] Corrupted pacman database / ... https://bbs.archlinux.org/viewtopic.php?id=230357
[7] pacman/Restore local database https://wiki.archlinux.org/title/Pacman/Restore_local_database
[8] Pacman/Pamac - Invalid or corrupted database - Support https://forum.manjaro.org/t/pacman-pamac-invalid-or-corrupted-database/127063
[9] How to repair broken packages using Pacman? https://www.tencentcloud.com/techpedia/102256
[10] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[11] fix corrupted pacman database - ArcoLinux https://www.youtube.com/watch?v=icICjb18I1k


