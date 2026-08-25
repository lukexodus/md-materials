## Repository Configuration


### Configuration File Location

Pacman's main configuration file is `/etc/pacman.conf`. This file controls pacman's behavior and defines which repositories are available for package installation and updates.

### Configuration File Structure

#### Sections

The configuration file uses an INI-style format with sections:

**[options] section:** Global settings that affect pacman's behavior

**Repository sections:** Define available package repositories (e.g., [core], [extra], [multilib])

#### Basic Syntax

```
# Comments start with #
[section-name]
Directive = value
Directive = value1 value2  # Space-separated values
```

### Global Options ([options] Section)

#### Essential Options

**RootDir:** Set the root directory for all pacman operations (default: `/`)

```
RootDir = /
```

**DBPath:** Package database location (default: `/var/lib/pacman/`)

```
DBPath = /var/lib/pacman/
```

**CacheDir:** Package cache directory (default: `/var/cache/pacman/pkg/`)

```
CacheDir = /var/cache/pacman/pkg/
```

Multiple cache directories can be specified:
```
CacheDir = /var/cache/pacman/pkg/
CacheDir = /mnt/storage/cache/
```

**GPGDir:** GnuPG keyring directory (default: `/etc/pacman.d/gnupg/`)

```
GPGDir = /etc/pacman.d/gnupg/
```

**LogFile:** Pacman log location (default: `/var/log/pacman.log`)

```
LogFile = /var/log/pacman.log
```

**HookDir:** Hook directories (default: `/etc/pacman.d/hooks/`)

```
HookDir = /etc/pacman.d/hooks/
HookDir = /usr/share/libalpm/hooks/
```

#### Package Handling Options

**HoldPkg:** Packages that require extra confirmation before removal

```
HoldPkg = pacman glibc
```

This prevents accidental removal of critical packages.

**IgnorePkg:** Packages to skip during upgrades

```
IgnorePkg = linux firefox
```

Useful for temporarily holding back problematic updates.

**IgnoreGroup:** Package groups to skip during upgrades

```
IgnoreGroup = gnome
```

**NoUpgrade:** Files that should never be overwritten during package upgrades

```
NoUpgrade = etc/pacman.conf etc/makepkg.conf
```

Paths are relative to the root directory.

**NoExtract:** Files that should never be extracted from packages

```
NoExtract = usr/share/doc/*
```

#### Architecture Configuration

**Architecture:** System architecture (usually auto-detected)

```
Architecture = auto
```

Or specify explicitly:
```
Architecture = x86_64
```

#### Download and Parallel Operations

**ParallelDownloads:** Number of concurrent downloads (requires pacman 6.0+)

```
ParallelDownloads = 5
```

This significantly speeds up package downloads by downloading multiple packages simultaneously.

#### Miscellaneous Options

**UseSyslog:** Log to system journal in addition to pacman.log

```
UseSyslog
```

**Color:** Enable colored output in terminal

```
Color
```

**CheckSpace:** Check available disk space before installing

```
CheckSpace
```

**VerbosePkgLists:** Display package name, version, and size in lists

```
VerbosePkgLists
```

**ILoveCandy:** Easter egg - changes progress bar to Pac-Man animation

```
ILoveCandy
```

#### Signature Verification

**SigLevel:** Global signature verification requirements

```
SigLevel = Required DatabaseOptional
```

**Common SigLevel values:**
- `Required` - Signatures mandatory for packages
- `Optional` - Signatures checked if present
- `Never` - No signature checking (insecure)
- `PackageRequired` - Package signatures required
- `DatabaseOptional` - Database signatures optional
- `TrustedOnly` - Only accept trusted keys (default)
- `TrustAll` - Accept any signature (debugging only)

**LocalFileSigLevel:** Signature requirements for local packages (`pacman -U`)

```
LocalFileSigLevel = Optional
```

**RemoteFileSigLevel:** Signature requirements for remote repository packages

```
RemoteFileSigLevel = Required
```

### Repository Configuration

#### Official Repositories

Standard Arch Linux repositories:

```
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
```

**Repository order matters:** Pacman searches repositories in the order they appear in the configuration file. If a package exists in multiple repositories, the first match is used.

#### Repository Directives

**Include:** Include another configuration file

```
Include = /etc/pacman.d/mirrorlist
```

The mirrorlist file contains `Server` directives with mirror URLs.

**Server:** Directly specify repository servers

```
[custom-repo]
Server = https://example.com/repo/$arch
Server = file:///home/user/packages
```

**Variable substitution:**
- `$repo` - Repository name
- `$arch` - System architecture

**SigLevel (per-repository):** Override global signature requirements

```
[custom-repo]
SigLevel = Optional TrustAll
Server = https://example.com/repo/$arch
```

**Usage:** Repository usage priority

```
[repo-name]
Usage = Search Install Upgrade All
```

Values: `Sync`, `Search`, `Install`, `Upgrade`, `All`

### Mirror Configuration

#### Mirrorlist File

The `/etc/pacman.d/mirrorlist` file contains available mirrors:

```
## Arch Linux repository mirrorlist
Server = https://mirror1.example.com/archlinux/$repo/os/$arch
Server = https://mirror2.example.com/archlinux/$repo/os/$arch
#Server = https://mirror3.example.com/archlinux/$repo/os/$arch
```

**Format:**
- Uncommented lines are active
- Lines starting with `#` are disabled
- Mirrors are tried in order until one succeeds

#### Updating Mirrorlist

**Using reflector (Arch Linux):**
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Using pacman-mirrors (Manjaro):**
```
sudo pacman-mirrors --fasttrack
```

**Manual editing:**
```
sudo nano /etc/pacman.d/mirrorlist
```

Move preferred mirrors to the top by uncommenting them and commenting out others.

### Custom Repositories

#### Adding Third-Party Repositories

Add custom repository sections to `/etc/pacman.conf`:

```
[custom-repo]
SigLevel = Optional TrustAll
Server = https://custom-repo.example.com/$arch
```

**Then synchronize:**
```
sudo pacman -Sy
```

#### Local Repository

Create a local repository for custom packages:

```
[local]
SigLevel = Optional TrustAll
Server = file:///home/user/repo
```

**Create the repository database:**
```
repo-add /home/user/repo/local.db.tar.gz /home/user/repo/*.pkg.tar.zst
```

#### AUR Helpers and Custom Repos

Some AUR helpers (like `chaotic-aur`) provide additional repositories:

```
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
```

Follow the repository's specific setup instructions for keyring initialization.

### Testing Repositories

#### Enabling Testing Repos

Arch Linux provides testing repositories for pre-release packages:

```
[core-testing]
Include = /etc/pacman.d/mirrorlist

[extra-testing]
Include = /etc/pacman.d/mirrorlist

[multilib-testing]
Include = /etc/pacman.d/mirrorlist
```

**Important:** Place testing repositories **before** their stable counterparts so they take precedence:

```
[core-testing]
Include = /etc/pacman.d/mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist
```

**Warning:** Testing repositories contain unstable packages. Only enable if you're prepared to handle issues and provide feedback.

### Configuration Validation

#### Test Configuration

Verify configuration syntax:

```
pacman -v
```

This displays current configuration including all paths and repositories.

#### Check Repository Status

List all configured repositories:

```
pacman -Sl
```

This queries all repositories and lists available packages.

**Check specific repository:**
```
pacman -Sl repository-name
```

### Configuration Best Practices

**Backup configuration:** Before making changes, backup `/etc/pacman.conf`:
```
sudo cp /etc/pacman.conf /etc/pacman.conf.backup
```

**Comment changes:** Document modifications with comments:
```
# 2025-11-01: Added custom repository for work packages
[work-repo]
Server = https://repo.work.com/$arch
```

**Minimal IgnorePkg:** Only ignore packages temporarily; resolve issues properly rather than permanently ignoring updates.

**Use Include for mirrors:** Keep mirror lists in `/etc/pacman.d/mirrorlist` for easier management.

**Signature verification:** Keep `SigLevel = Required` for security; only use `Optional` or `TrustAll` for trusted custom repositories.

**Test after changes:** Run `pacman -Sy` after configuration changes to ensure repositories are accessible.

**Repository order:** Place higher-priority repositories first in the configuration.

**Regular updates:** Keep the mirrorlist updated for best download speeds.

**Document custom repos:** Maintain a list of custom repositories and why they're needed.

### Restoring Default Configuration

If configuration becomes corrupted:

**Download default config:**
```
sudo curl -o /etc/pacman.conf https://gitlab.archlinux.org/archlinux/packaging/packages/pacman/-/raw/main/pacman.conf
```

**Or reinstall pacman package:**
```
sudo pacman -S pacman --overwrite /etc/pacman.conf
```

Configuration management is essential for controlling pacman's behavior, defining available packages, and maintaining system security through proper signature verification settings.

