## Downgrading Packages


### When to Downgrade

Before downgrading packages, consider the reason. If it's due to a bug, search the Arch Linux Bugtracker for existing issues and report new ones if necessary. It's better to correct bugs or warn other users of issues rather than silently downgrade.[1]

### Important Warnings

**Dependency considerations:** Downgrading one package may require that its dependencies be downgraded as well. When the number of packages to downgrade is large, consider using a snapshot from the Arch Linux Archive to restore all packages to a specific date.[1]

**Configuration files:** Be careful with changes to configuration files and scripts. Pacman will handle this as long as you don't bypass its safeguards.[1]

**Soname changes:** If a downgrade involves a soname change, all dependencies may need downgrading or rebuilding too.[1]

**Process reload:** Similar to upgrading, downgrades are not picked up by already running processes. If the motivation for downgrading is avoiding a bug, be sure to restart affected programs.[1]

**Unsupported on rolling release:** On rolling-release distributions like Arch, only the very latest version of every package is officially supported. Older packages may break and are a temporary solution at best.[2]

### Method 1: Using the Pacman Cache

#### Basic Cache Downgrade

If a package was installed at an earlier stage and the pacman cache was not cleaned, install an earlier version from `/var/cache/pacman/pkg/`:[2][1]

```
sudo pacman -U /var/cache/pacman/pkg/package-old_version.pkg.tar.zst
```


**Example:**
```
sudo pacman -U /var/cache/pacman/pkg/firefox-81.0.1-1-x86_64.pkg.tar.zst
```


This process removes the current package and installs the older version. Dependency changes will be handled, but pacman will not handle version conflicts. If a library or other package needs to be downgraded with the packages, you must downgrade those packages yourself as well.[1]

#### Finding Available Versions in Cache

List available versions in your cache:

```
ls /var/cache/pacman/pkg/ | grep package_name
```

This shows all cached versions of the specified package.

#### Prevent Auto-Upgrade

Once the package is reverted and confirmed to work, temporarily ignore updates by adding the package to the `IgnorePkg` section of `pacman.conf` until the issue with the updated package is resolved:[1]

```
# /etc/pacman.conf
[options]
IgnorePkg = package_name
```


This prevents `pacman -Syu` from upgrading the package until you remove it from `IgnorePkg`.[1]

### Method 2: Using Arch Linux Archive

#### About the Archive

The Arch Linux Archive is a daily snapshot of the official repositories. It can be used to install a previous package version or restore the system to an earlier date.[2][1]

**Archive location:**
```
https://archive.archlinux.org/
```


#### Direct Package Installation

Find and download the desired package version from the archive:

```
sudo pacman -U https://archive.archlinux.org/packages/p/package_name/package_name-version.pkg.tar.zst
```


**Example:**
```
sudo pacman -U https://archive.archlinux.org/packages/f/firefox/firefox-83.0-1-x86_64.pkg.tar.zst
```


#### Browsing the Archive

Navigate the archive by package name:
- Browse by first letter: `https://archive.archlinux.org/packages/f/`
- View specific package: `https://archive.archlinux.org/packages/f/firefox/`
- All versions listed with direct download links[2]

#### System-Wide Date Restoration

To restore all packages to a specific date, modify `/etc/pacman.d/mirrorlist` to point to a snapshot date:[3][1]

```
# /etc/pacman.d/mirrorlist
Server=https://archive.archlinux.org/repos/YYYY/MM/DD/$repo/os/$arch
```


Then run:
```
sudo pacman -Syuu
```


The `-uu` flag allows downgrades. This restores all packages to versions available on the specified date.[3][1]

### Method 3: Using the downgrade Utility

#### Installation

The `downgrade` utility simplifies the downgrade process by checking both local cache and remote servers for old package versions.[4][5][6]

**Install from AUR using Paru:**
```
paru -S downgrade
```


**Install from AUR using Yay:**
```
yay -S downgrade
```


#### Basic Usage

The typical usage syntax is:[6]

```
sudo downgrade [PACKAGE, ...] [-- [PACMAN OPTIONS]]
```


**Downgrade a single package:**
```
sudo downgrade package_name
```


This command lists all available versions of the package (both new and old) from your local cache and remote mirrors. You can then interactively select which version to install.[6]

**Example:**
```
sudo downgrade opera
```


#### Interactive Selection

When you run `downgrade`, it presents a numbered list of available versions:

```
Available packages:
   1) opera-75.0.3969.171-1 (local)
   2) opera-74.0.3911.232-1 (remote)
   3) opera-73.0.3856.344-1 (remote)
   4) opera-72.0.3815.400-1 (remote)
```

Select the number corresponding to the desired version and press Enter.[6]

#### Add to IgnorePkg

After selecting and installing a version, `downgrade` prompts whether to add the package to `IgnorePkg` in `/etc/pacman.conf`. Confirming this prevents future automatic upgrades of the package.[6]

### Method 4: Downgrading the Kernel

#### Kernel Downgrade Procedure

In case of issues with a new kernel, Linux packages can be downgraded using the pacman cache. Go into `/var/cache/pacman/pkg/` and downgrade at least `linux`, `linux-headers`, and any kernel modules:[1]

```
sudo pacman -U linux-6.16.1.arch1-1-x86_64.pkg.tar.zst linux-headers-6.16-1-x86_64.pkg.tar.zst virtualbox-host-modules-arch-7.2.0-2-x86_64.pkg.tar.zst
```


Use the actual file paths from your cache directory.[1]

#### Kernel Downgrade from Live USB

If you are unable to boot after a kernel update, downgrade the kernel by chrooting into the system:[1]

1. Boot using Arch Linux USB flash installation media
2. Mount the system partition: `mount /dev/sdXN /mnt`
3. Mount `/boot` if on separate partition: `mount /dev/sdXN /mnt/boot`
4. Mount `/var` if on separate partition: `mount /dev/sdXN /mnt/var`
5. Chroot into the system: `arch-chroot /mnt`
6. Navigate to pacman cache and downgrade: `pacman -U /var/cache/pacman/pkg/linux-*.pkg.tar.zst`
7. Exit chroot: `exit`
8. Reboot[1]

### Method 5: Rebuilding the Package

#### From Official Repositories

If the package is unavailable in cache or archive, rebuild it from source:[1]

1. Retrieve the PKGBUILD with ABS
2. Change the software version in the PKGBUILD
3. Build with `makepkg`

Alternatively, find the package on the Packages website, click "View Changes", and navigate to the desired version. Download the necessary files and rebuild the package.[1]

#### From AUR

Old AUR packages can be built by checking out an old commit in the AUR package Git repository:[1]

```
git clone https://aur.archlinux.org/package_name.git
cd package_name
git log  # Find commit hash for desired version
git checkout commit_hash
makepkg -si
```


### Best Practices

**Test the downgrade:** After downgrading, test the package thoroughly to ensure it resolves the issue.[6]

**Monitor for updates:** Keep track of upstream bug reports to know when the issue is fixed.[1]

**Temporary solution:** Treat downgrades as temporary. Update to the latest version once the issue is resolved.[2][6]

**Document the issue:** Note why you downgraded and what symptoms prompted it for future reference.[1]

**Avoid partial downgrades:** When downgrading libraries, ensure all dependent packages are compatible.[1]

**Keep cache intact:** Don't clean the pacman cache if you anticipate needing to downgrade.[1]

Sources
[1] Downgrading packages - ArchWiki https://wiki.archlinux.org/title/Downgrading_packages
[2] How to downgrade a specfic package using Pacman - Stack Overflow https://stackoverflow.com/questions/69195690/how-to-downgrade-a-specfic-package-using-pacman
[3] is there an easy way to downgrade? (Arch-Linux specifically) - Reddit https://www.reddit.com/r/kde/comments/1bd165w/plasma_6_busted_up_my_whole_everything_is_there/
[4] AUR (en) - downgrade - Arch Linux https://aur.archlinux.org/packages/downgrade
[5] Downgrade packages in Arch Linux - GitHub https://github.com/archlinux-downgrade/downgrade
[6] How To Downgrade A Package In Arch Linux - OSTechNix https://ostechnix.com/downgrade-package-arch-linux/
[7] How to downgrade packages in Arch Linux. - YouTube https://www.youtube.com/watch?v=npFRcuuvNsA
[8] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman

