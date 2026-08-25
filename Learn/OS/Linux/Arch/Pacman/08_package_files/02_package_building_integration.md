## Package Building Integration


### makepkg Overview

`makepkg` is a script that automates the building of packages from source code. It creates packages that can be installed with pacman, integrating seamlessly with Arch Linux's package management system. The requirements for using makepkg are a build-capable Unix platform and a PKGBUILD file.[1][2]

### Prerequisites

#### Install base-devel

Before building packages, install the `base-devel` meta package:[3][1]

```
sudo pacman -S base-devel
```


**Contents include:**
- GCC compiler
- make and autoconf
- binutils
- fakeroot
- pkg-config
- Other essential build tools[1]

Dependencies of `base-devel` are **not** required to be listed as makedepends in PKGBUILD files.[1]

#### Configure sudo

Ensure sudo is configured properly for commands passed to pacman. Alternatively, specify a different authorization command with `PACMAN_AUTH` in `/etc/makepkg.conf`.[1]

**Important security note:** Running `makepkg` as root is disallowed. Building as root is generally considered unsafe since a PKGBUILD may contain arbitrary commands.[1]

### Basic makepkg Workflow

#### Build Package from PKGBUILD

Navigate to the directory containing the PKGBUILD file and run:[3][1]

```
makepkg
```


**Process:**
1. Downloads source files specified in the PKGBUILD
2. Extracts sources to the `src/` directory
3. Compiles the software
4. Packages compiled files into a `.pkg.tar.zst` archive[4][1]

**Result:** A package file is created in the working directory with the format:
```
packagename-version-release-arch.pkg.tar.zst
```


### Automatic Dependency Management

#### Install Build Dependencies

Use the `-s` or `--syncdeps` flag to automatically install missing build dependencies:[3][1]

```
makepkg -s
```


If required dependencies are missing, makepkg will use pacman to install them before building.[1]

**Note:** These dependencies must be available in configured repositories. Dependencies on AUR packages must be installed manually first.[3][1]

#### Remove Build Dependencies

Add the `-r` or `--rmdeps` flag to remove build dependencies after building:[3][1]

```
makepkg -sr
```


This removes dependencies that are no longer needed after the build completes. Dependencies required for using the package (not just building) are retained.[3][1]

### Automatic Installation

#### Install After Building

Use the `-i` or `--install` flag to automatically install the package after successful building:[5][1][3]

```
makepkg -i
```


This is equivalent to running `pacman -U package-file.pkg.tar.zst` after the build completes.[3][1]

#### Combined Flags (Most Common)

The most commonly used combination installs dependencies, builds, installs the package, and removes unnecessary build dependencies:[5][3]

```
makepkg -si
```


Or for complete automation:
```
makepkg -sri
```


**Breakdown:**
- `-s` - Install build dependencies
- `-r` - Remove build-only dependencies after installation
- `-i` - Install the built package[3]

### Package Output Configuration

#### Default Output Location

By default, makepkg creates package tarballs in the working directory where the command is run.[6][1]

#### Custom Output Directories

Configure custom paths in `/etc/makepkg.conf` or `~/.makepkg.conf`:[6][1]

**PKGDEST:** Directory for storing resulting packages[6][1]
```
PKGDEST=~/build/packages/
```


**SRCDEST:** Directory for storing source data[1]
```
SRCDEST=~/build/sources/
```


**SRCPKGDEST:** Directory for storing source packages (built with `makepkg -S`)[1]
```
SRCPKGDEST=~/build/srcpackages/
```


**Tip:** The PKGDEST directory can be cleaned with `paccache -c ~/build/packages/` like the standard pacman cache.[1]

### Package Format Configuration

#### Output File Extension

The package format is controlled by the `PKGEXT` directive in `/etc/makepkg.conf`:[5]

**Default (modern):**
```
PKGEXT='.pkg.tar.zst'
```


**Alternative formats:**
```
PKGEXT='.pkg.tar.xz'
PKGEXT='.pkg.tar.gz'
```


Pacman can install packages with any of these extensions.[5]

### Cleaning Build Artifacts

#### Clean Temporary Files

Use the `-c` or `--clean` flag to remove temporary build files after completion:[3]

```
makepkg -c
```


This deletes the `src/` directory and other temporary files, useful when debugging build issues.[3]

### Manual Installation After Building

#### Install Package File Manually

If you build without the `-i` flag, install the resulting package manually:[3]

```
sudo pacman -U packagename-version-release-arch.pkg.tar.zst
```


This gives more control over when and how the package is installed.[3]

### Signature Verification

#### Automatic Signature Checking

If a signature file (`.sig` or `.asc`) is part of the PKGBUILD source array, makepkg automatically attempts to verify it.[1]

**Important:** Signature checking in makepkg uses the user's keyring, not pacman's keyring.[1]

#### Skip Signature Verification

Temporarily disable signature checking (not recommended):

```
makepkg --skippgpcheck
```


#### Import Missing Keys

If a required public key is missing, import it manually:[1]

```
gpg --recv-keys KEY_ID
```


The PKGBUILD typically contains a `validpgpkeys` entry with required key IDs.[1]

### Package Signing

#### Sign Built Packages

Sign packages after creation for distribution:[1]

```
gpg --detach-sign --output package.pkg.tar.zst.sig package.pkg.tar.zst
```


This creates a detached signature file that can be used with custom repositories.[1]

### Integration with AUR

#### Building AUR Packages

AUR packages provide PKGBUILD files in git repositories:[5]

```
git clone https://aur.archlinux.org/package-name.git
cd package-name
makepkg -si
```


This downloads the PKGBUILD, builds the package, and installs it automatically.[5]

### Advanced makepkg Options

#### Build Source Package Only

Create a source package without building the binary:

```
makepkg -S
```


This downloads and packages source files without compilation.[6]

#### Force Rebuild

Overwrite existing packages:

```
makepkg -f
```

The `-f` or `--force` flag rebuilds the package even if it already exists.[6]

#### Keep Build Directory

Prevent cleaning of the build directory for debugging:

```
makepkg --holdver
```

This maintains the build environment for inspection.

### Packager Identification

#### Set Packager Name

Identify yourself as the packager in `/etc/makepkg.conf` or `~/.makepkg.conf`:[1]

```
PACKAGER="Your Name <email@example.com>"
```


This information is embedded in package metadata and can be queried later.[1]

#### Query Packages by Packager

Find all packages built by a specific packager using `expac`:[1]

```
expac "%n %p" | grep "packagername" | column -t
```


### Error Handling

#### Dependency Conflicts

If makepkg fails due to dependency issues:

1. Check if dependencies are in configured repositories
2. Install missing dependencies manually: `pacman -S --asdeps dep1 dep2`[1]
3. Retry the build

#### Build Failures

When builds fail:

- Review the error output carefully
- Check if source downloads succeeded
- Verify PKGBUILD syntax
- Consult AUR comments or package documentation
- Use `makepkg -c` to clean and retry

### Best Practices

**Never run as root:** Always build packages as a regular user.[1]

**Use -si combination:** The `-si` flags provide the most convenient workflow.[5][3]

**Read PKGBUILDs:** Always review PKGBUILD files before building, especially from untrusted sources.[5]

**Keep base-devel installed:** Maintain this package group for consistent building capability.[3][1]

**Configure output directories:** Centralize built packages for easier management.[1]

**Update regularly:** Run `git pull` in AUR package directories before rebuilding.[5]

**Sign your packages:** Sign packages if distributing to others or maintaining custom repositories.[1]

**Document modifications:** Keep notes on any PKGBUILD customizations you make.

Sources
[1] makepkg - ArchWiki https://wiki.archlinux.org/title/Makepkg
[2] How to rebuild a package using the Arch Linux Build System https://forum.linuxconfig.org/t/how-to-rebuild-a-package-using-the-arch-linux-build-system-linuxconfig-org/4798
[3] Using Makepkg on Arch Linux https://docs.vultr.com/using-makepkg-on-arch-linux
[4] Can someone explain to me how to package a Pacman ... https://www.reddit.com/r/archlinux/comments/rxzl7z/can_someone_explain_to_me_how_to_package_a_pacman/
[5] Using makepkg - Newbie https://forum.endeavouros.com/t/using-makepkg/6433
[6] Where are makepkg outputs packages built? https://stackoverflow.com/questions/21204934/where-are-makepkg-outputs-packages-built
[7] [SOLVED] Installing with 'makepkg -si' vs 'pacman https://bbs.archlinux.org/viewtopic.php?id=300064
[8] Register a local/user-built package in database using ... https://forum.manjaro.org/t/register-a-local-user-built-package-in-database-using-pamac-pacman/151222
[9] Building a package on ArchLinux (ABS / makepkg) https://www.youtube.com/watch?v=HExYZLpqyfk

