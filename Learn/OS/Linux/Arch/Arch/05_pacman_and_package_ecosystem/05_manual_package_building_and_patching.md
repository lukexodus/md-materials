## Manual Package Building and Patching


### Arch Build System Overview

**Purpose**: The Arch Build System enables users to compile packages from source using simple shell scripts and configuration files, providing transparency and customization compared to pre-compiled binaries.[1][2]

**Components**:[2]
- **PKGBUILD**: Shell script defining how to fetch, compile, and package software[2]
- **makepkg**: Utility that reads PKGBUILD and builds packages[1][2]
- **Pacman**: Installs compiled packages[1]

**Philosophy**: Allows users to understand exactly what goes into their packages.[2]

### PKGBUILD File Structure

**Location**: PKGBUILD files are typically found in AUR (Arch User Repository) or source code repositories.[2]

**Basic Structure**:[1][2]

```bash
# Metadata
pkgname=mypackage
pkgver=1.0
pkgrel=1
pkgdesc="Description of the package"
arch=('x86_64')
url="https://example.com"
license=('GPL')

# Dependencies
depends=('glibc' 'openssl')
makedepends=('gcc' 'make')
optdepends=('optional-dep: for optional feature')

# Source files
source=("https://example.com/package-1.0.tar.gz")
sha256sums=('checksum')

# Build functions
prepare() {
    cd "$pkgname-$pkgver"
    # Pre-build preparation
}

build() {
    cd "$pkgname-$pkgver"
    ./configure --prefix=/usr
    make
}

package() {
    cd "$pkgname-$pkgver"
    make DESTDIR="$pkgdir" install
}
```

#### PKGBUILD Variables:[1][2]

- **`pkgname`**: Package name[2]
- **`pkgver`**: Package version[2]
- **`pkgrel`**: Package release number[2]
- **`pkgdesc`**: One-line package description[2]
- **`arch`**: Supported architectures (x86_64, i686)[2]
- **`url`**: Project website[2]
- **`license`**: License identifier[2]
- **`depends`**: Runtime dependencies[1][2]
- **`makedepends`**: Compilation-time dependencies[1][2]
- **`optdepends`**: Optional functionality dependencies[2]
- **`source`**: Source files URL or local path[2]
- **`sha256sums`**: Checksums for source file verification[1][2]

### Build Functions

**prepare()**: Pre-compilation preparation, including patching and configuration.[2]

**build()**: Compilation and linking phase.[2]

**package()**: Installation to staging directory.[2]

**check()**: Optional test suite execution (disabled by default).[2]

### makepkg Utility

**Installation**: Included in the base-devel package group.[1]

**Installation**: `sudo pacman -S base-devel`.[1]

#### Basic makepkg Usage

**Compile and Package**: `makepkg` reads PKGBUILD in current directory and builds package.[1][2]

**Install After Building**: `makepkg -i` builds and immediately installs package.[1][2]

**Skip Dependencies Check**: `makepkg -d` compiles without checking dependencies.[1]

**Clean Before Building**: `makepkg -c` removes old source files.[1]

#### makepkg Options:[1][2]

- **`-i`**: Install after building[1]
- **`-d`**: Skip dependency checking[1]
- **`-c`**: Clean old sources[1]
- **`-f`**: Force rebuild even if package exists[2]
- **`-s`**: Install dependencies via sudo[1]
- **`-r`**: Remove build files after successful build[2]

#### Complete Build Example

**Download and Build**:[2]

```bash
cd /tmp
git clone https://aur.archlinux.org/mypackage.git
cd mypackage
makepkg -si
```

This downloads the AUR package, builds it, and installs it.[2]

### Applying Patches

**Patch Concept**: Patches are files containing source code changes, applied before compilation.[1]

**Patch Syntax**: Patches follow unified diff format (.patch or .diff files).[1]

#### Storing Patches

**Location**: Store patches in same directory as PKGBUILD.[1][2]

**PKGBUILD Reference**:[2][1]

```bash
source=('https://example.com/package.tar.gz'
        'myfix.patch'
        'security.patch')
```

#### Applying Patches in prepare()

**Function Definition**:[1][2]

```bash
prepare() {
    cd "$pkgname-$pkgver"
    patch -p1 < "$srcdir/myfix.patch"
    patch -p1 < "$srcdir/security.patch"
}
```

**Parameters**:[1]
- **`-p1`**: Strip first path component from patch[1]
- **`< "$srcdir/patch.patch"`**: Apply patch file[1]

### Creating Custom Patches

**Generate Patch**: Compare original and modified files:[1]

```bash
diff -u original.file modified.file > mychanges.patch
```

**Apply to Existing File**: Use patch command to test:[1]

```bash
patch -p0 < mychanges.patch
```

**Integrate into PKGBUILD**: Add patch to source array and apply in prepare().[1]

### Verification and Security

**Checksum Verification**: Makepkg automatically verifies source file checksums.[2][1]

**Generate Checksums**: `updpkgsums` automatically updates sha256sums array:[1]

```bash
updpkgsums
```

**Manual Checksum Calculation**: `sha256sum filename` generates checksum.[1]

**Signature Verification**: PKGBUILD can verify GPG signatures:[2]

```bash
validpgpkeys=('DEADBEEF')
```

### Common Build Issues

**Missing Dependencies**: `makepkg` displays missing dependencies; install with `sudo pacman -S [dependency]`.[1]

**Permission Denied**: Don't run makepkg as root; use sudo for specific tasks.[1]

**Compilation Errors**: Check error output; often indicates incompatible patches or outdated sources.[2]

**Patch Application Failure**: Verify patch format and compatibility with source version.[1]

### Post-Build Package Management

**Package Location**: Compiled packages stored in current directory with name `pkgname-pkgver-pkgrel-arch.pkg.tar.zst`.[2][1]

**Install Package**: `sudo pacman -U package.pkg.tar.zst`.[2]

**Install and Sign**: `sudo pacman -U --config /etc/pacman.conf package.pkg.tar.zst`.[1]

### Modifying Official Packages

**Get Source**: `asp checkout package-name` retrieves official package source.[1]

**Clone to Directory**: Creates `package-name/` directory with PKGBUILD.[1]

**Modify**: Edit PKGBUILD and patches as needed.[1]

**Build**: Run `makepkg` in modified directory.[1]

### Custom Package Repository

**Local Repository**: Create custom pacman repository with self-built packages.[1]

**Initialize Repository**: `repo-add myrepo.db.tar.gz package.pkg.tar.zst` creates repository database.[1]

**Configure**: Add to `/etc/pacman.conf`:[1]

```
[myrepo]
SigLevel = Never
Server = file:///path/to/repo
```

**Use**: `sudo pacman -Syu && sudo pacman -S package-name` installs from custom repository.[1]

### Performance Considerations

**Compilation Time**: Building from source takes significantly longer than installing binaries.[2]

**Disk Space**: Compilation requires temporary space for object files during build process.[1]

**CPU Load**: Builds consume system resources; avoid during critical tasks.[2]

**Parallel Compilation**: Set `MAKEFLAGS=-j$(nproc)` in environment for parallel jobs.[1]

### Working with AUR Packages

**AUR Structure**: Most AUR packages contain PKGBUILD designed for easy customization.[2]

**Modification Workflow**:[2]
1. Clone or download AUR package[2]
2. Review PKGBUILD for security[2]
3. Apply custom patches if needed[2]
4. Run makepkg[2]
5. Install with pacman[2]

### Best Practices

**Review PKGBUILD**: Always examine PKGBUILD before building, especially from untrusted sources.[2][1]

**Verify Checksums**: Ensure source file checksums match expected values.[1]

**Test Patches**: Test patches before integrating into PKGBUILD.[1]

**Backup**: Keep backup of successful builds.[2]

**Document Changes**: Comment modifications explaining reasoning.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] archlinux/mkinitcpio: Arch Linux initramfs generation tools ... https://github.com/archlinux/mkinitcpio

