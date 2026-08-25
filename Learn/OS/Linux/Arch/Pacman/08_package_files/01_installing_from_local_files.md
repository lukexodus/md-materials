## Installing from Local Files


### Basic Local Package Installation

#### Using the -U Flag

To install a package from a local file (not from a remote repository), use the `-U` or `--upgrade` flag:[1][2][3][4]

```
sudo pacman -U /path/to/package/package_name-version.pkg.tar.zst
```


**Examples:**
```
sudo pacman -U ~/Downloads/firefox-120.0-1-x86_64.pkg.tar.zst
sudo pacman -U /var/cache/pacman/pkg/linux-6.5.9-1-x86_64.pkg.tar.zst
```


**Key features:**
- Installs the specified package file[2]
- Automatically resolves and installs dependencies from configured sync repositories[2]
- Can be used with packages built from AUR or downloaded manually[1]

### Keeping Package in Cache

#### Using file:// Protocol

To install a local package and keep a copy in pacman's cache, use the `file://` prefix with an absolute path:[3][5]

```
sudo pacman -U file:///path/to/package/package_name-version.pkg.tar.zst
```


**Example:**
```
sudo pacman -U file:///home/user/packages/firefox-120.0-1-x86_64.pkg.tar.zst
```


This syntax ensures the package is copied to `/var/cache/pacman/pkg/` during installation, providing a cached copy for future use.[5]

### Installing Remote Packages

#### Install from URL

Pacman can download and install packages directly from remote URLs:[3][5]

```
sudo pacman -U https://example.com/repo/package-1.0-1-x86_64.pkg.tar.zst
```


**Examples:**
```
sudo pacman -U https://archive.archlinux.org/packages/f/firefox/firefox-119.0-1-x86_64.pkg.tar.zst
```


Pacman downloads the package, verifies it, and installs with automatic dependency resolution from configured repositories.[5]

### Dependency Resolution

#### Automatic Dependency Installation

When installing local packages with `-U`, pacman automatically resolves and installs required dependencies from sync repositories:[2]

```
sudo pacman -U /path/to/package.pkg.tar.zst
```


**Process:**
1. Pacman examines the local package's dependencies
2. Searches configured sync repositories for required dependencies
3. Downloads and installs dependencies automatically
4. Installs the local package[2]

**Important:** Dependencies are fetched from sync repositories, not from the local directory containing the package. For dependency resolution from local files, a proper local repository must be configured.[2]

### Installing Multiple Local Packages

#### Specify Multiple Files

Install several local packages simultaneously:

```
sudo pacman -U /path/to/package1.pkg.tar.zst /path/to/package2.pkg.tar.zst /path/to/package3.pkg.tar.zst
```

**Using wildcards:**
```
sudo pacman -U /path/to/packages/*.pkg.tar.zst
```

This installs all package files in the specified directory.

### Installing from Cache

#### Reinstall from Cached Package

Packages in `/var/cache/pacman/pkg/` can be reinstalled directly:

```
sudo pacman -U /var/cache/pacman/pkg/package-name-version.pkg.tar.zst
```

This is useful for:
- Downgrading to older versions
- Reinstalling after accidental removal
- System recovery when repositories are unavailable

### Local Repository Setup

#### When Local Directory Has Many Packages

For directories containing many packages where you want proper dependency resolution among local files, create a local repository:[2]

**Step 1: Create repository database**
```
repo-add /path/to/repo/custom.db.tar.gz /path/to/repo/*.pkg.tar.zst
```


This creates a repository database file that indexes all packages in the directory.[2]

**Step 2: Add repository to pacman.conf**
```
# /etc/pacman.conf
[custom]
SigLevel = Optional TrustAll
Server = file:///path/to/repo
```


**Step 3: Synchronize and install**
```
sudo pacman -Sy
sudo pacman -S package_name
```


Now pacman can install packages from the local repository with full dependency resolution, treating local packages like repository packages.[2]

### Installation Options

#### Install as Dependency

Mark a local package as a dependency rather than explicitly installed:

```
sudo pacman -U --asdeps /path/to/package.pkg.tar.zst
```


This affects orphan detection—the package will be considered a dependency.[4]

#### Install as Explicit

Mark a local package as explicitly installed (default behavior):

```
sudo pacman -U --asexplicit /path/to/package.pkg.tar.zst
```


#### Skip Dependency Checks

**Warning:** This is dangerous and can break your system.[2]

```
sudo pacman -U --nodeps /path/to/package.pkg.tar.zst
```

Only use this in recovery scenarios when you understand the consequences.[2]

### Handling Conflicts

#### Overwrite Conflicting Files

If installation fails due to file conflicts:

```
sudo pacman -U --overwrite '*' /path/to/package.pkg.tar.zst
```

This forces installation by overwriting conflicting files.

**Target specific paths:**
```
sudo pacman -U --overwrite /usr/lib/libfoo.so /path/to/package.pkg.tar.zst
```

### Verification and Security

#### Package Signature Verification

Pacman automatically verifies package signatures during installation based on the `SigLevel` setting in `/etc/pacman.conf`.[6]

For local packages without signatures or with unknown signatures, you may need to adjust the signature level or skip verification (not recommended for security).

**Skip signature checks (risky):**
```
sudo pacman -U --dbonly /path/to/package.pkg.tar.zst
```

### Database-Only Installation

#### Register Package Without Extracting Files

Install a package to the database only, without extracting files:

```
sudo pacman -U --dbonly /path/to/package.pkg.tar.zst
```


**Use cases:**
- Manually compiled software needs registration in the database[7]
- System recovery when files are already in place
- Testing and development scenarios

**Warning:** This creates a database entry without actually installing files, which can lead to inconsistencies.[7]

### Batch Installation Scripts

#### Install All Packages from Directory

```bash
#!/bin/bash
# Install all packages from a directory

PACKAGE_DIR="/path/to/packages"

for pkg in "$PACKAGE_DIR"/*.pkg.tar.zst; do
  echo "Installing $pkg..."
  sudo pacman -U --noconfirm "$pkg"
done
```

**With error handling:**
```bash
#!/bin/bash
PACKAGE_DIR="/path/to/packages"

for pkg in "$PACKAGE_DIR"/*.pkg.tar.zst; do
  if sudo pacman -U --noconfirm "$pkg"; then
    echo "✓ Successfully installed: $pkg"
  else
    echo "✗ Failed to install: $pkg"
  fi
done
```

### Common Issues and Solutions

#### Missing Dependencies

**Issue:** Local package requires dependencies not in sync repositories.

**Solution:** Either:
1. Install dependencies manually first
2. Set up a complete local repository with all dependencies[2]

#### File Path Errors

**Issue:** Pacman can't find the package file.

**Solutions:**
- Use absolute paths instead of relative paths
- Verify the file exists: `ls -l /path/to/package.pkg.tar.zst`
- Check file permissions: ensure the file is readable

#### Version Conflicts

**Issue:** Local package version conflicts with installed version.

**Solution:** Remove the existing package first:
```
sudo pacman -R package_name
sudo pacman -U /path/to/new-package.pkg.tar.zst
```

### Best Practices

**Verify package integrity:** Check checksums before installing packages from untrusted sources.

**Keep packages cached:** Use `file://` protocol to maintain cache copies for future use.[5]

**Use local repositories for large collections:** If managing many local packages, set up a proper repository.[2]

**Test in safe environments:** Test local package installations in virtual machines or test systems first.

**Document sources:** Keep records of where local packages came from and why they're needed.

**Maintain dependencies:** Ensure all dependencies are available in sync repositories or your local repository.[2]

**Backup before installation:** Back up important data before installing untrusted local packages.

Sources
[1] How do I install a local/downloaded package using Yay? https://www.reddit.com/r/archlinux/comments/ln65dh/how_do_i_install_a_localdownloaded_package_using/
[2] How to install packages from local folder / Pacman & ... https://bbs.archlinux.org/viewtopic.php?id=119953
[3] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[4] Using pacman Commands in Arch Linux [Beginner's Guide] https://itsfoss.com/pacman-command/
[5] Pacman Cheatsheet https://gist.github.com/HFTrader/4fb15d461d86634fd1cba5d251ca7925
[6] ELI5: Does pacman -S automatically verify package integrity? - Reddit https://www.reddit.com/r/archlinux/comments/69n2ty/eli5_does_pacman_s_automatically_verify_package/
[7] Register a local/user-built package in database using ... https://forum.manjaro.org/t/register-a-local-user-built-package-in-database-using-pamac-pacman/151222
[8] How to Use Pacman in Arch Linux https://www.atlantic.net/dedicated-server-hosting/how-to-use-pacman-in-arch-linux/
[9] How to find where a package is installed by pacman? https://stackoverflow.com/questions/22681578/how-to-find-where-a-package-is-installed-by-pacman

