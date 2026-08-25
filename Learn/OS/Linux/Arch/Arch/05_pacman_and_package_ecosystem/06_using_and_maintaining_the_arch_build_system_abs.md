## Using and Maintaining the Arch Build System (ABS)


### Arch Build System Overview

**Purpose**: The Arch Build System (ABS) is a collection of tools and directories for building and maintaining Arch packages from source. It provides transparency into how official packages are constructed.[1][2]

**Distinction from makepkg**: While makepkg builds individual packages, ABS encompasses the entire infrastructure for managing package sources.[2]

**Components**:[1][2]
- PKGBUILD files for each official package[2]
- Build scripts and utilities[2]
- Patch files and configuration[2]
- Versioning and release management[2]

### ASP (Arch Source Packages)

**Modern Replacement**: ASP is the modern tool for working with Arch package sources, replacing traditional ABS.[1]

**Installation**: `sudo pacman -S asp`.[1]

**Purpose**: Provides Git-based access to official package sources without full ABS repository.[1]

#### ASP Basic Commands

**Checkout Package**: `asp checkout package-name` downloads the package source directory.[1]

**Output**: Creates a `package-name/` directory containing the PKGBUILD.[1]

**Example**:[1]

```bash
asp checkout linux
cd linux
```

This downloads the official Linux kernel PKGBUILD and related files.[1]

**List Branches**: `asp list-all` shows all available packages.[1]

**Diff Changes**: `asp diff package-name` shows changes since last update.[1]

**Update**: `asp update` pulls latest changes from upstream.[1]

### Traditional ABS Repository

**Deprecated Status**: Full ABS repository is less commonly used in modern Arch, superseded by ASP.[1]

**Historical Method**:[1]
- Clone git repository[1]
- Contains PKGBUILD files for entire official repository[1]
- Provides complete history[1]

**Installation** (if desired): `sudo pacman -S svn` or `git clone https://gitlab.archlinux.org/archlinux/packaging/packages.git`.[1]

### Working with Package Sources

#### Obtaining Package Source

**Method 1: ASP** (Recommended):[1]

```bash
asp checkout package-name
cd package-name
makepkg -od  # Download sources without building
```

**Method 2: Manual Download**:[1]

```bash
mkdir -p package-name && cd package-name
# Download PKGBUILD and patches manually
wget https://archlinux.org/packages/.../PKGBUILD
```

#### Inspecting Package Contents

**View PKGBUILD**: `cat PKGBUILD` displays package configuration.[1]

**List Files**: `ls -la` shows associated patches and files.[1]

**Check Patches**: `head -20 patch-name` previews patch content.[1]

### Modifying Official Packages

**Customization Workflow**:[1]
1. Use ASP to checkout package[1]
2. Edit PKGBUILD or patches as needed[1]
3. Change `pkgrel` to indicate custom build[1]
4. Run `makepkg`[1]
5. Install with pacman[1]

**Versioning**: Increment `pkgrel` for each rebuild; example: `pkgrel=1.custom1`.[1]

#### Common Modifications

**Custom Patches**:[1]
- Add patches to source array[1]
- Apply in prepare() function[1]
- Update sha256sums[1]

**Configuration Changes**:[1]
- Modify ./configure flags[1]
- Enable/disable optional features[1]
- Adjust compiler flags[1]

**Dependency Changes**:[1]
- Add/remove depends array entries[1]
- Update makedepends[1]

### Split Packages

**Concept**: Some packages produce multiple binary packages from single PKGBUILD.[2][1]

**Example**: Linux kernel produces multiple packages:[2]
- `linux`: Kernel image[2]
- `linux-headers`: Development headers[2]
- `linux-docs`: Documentation[2]

**Build All**: `makepkg` builds all split packages.[1]

**Package Functions**: Separate `package_*` functions for each split package:[2]

```bash
package_linux() {
    # Package kernel
}

package_linux_headers() {
    # Package headers
}
```

### Rebuilding for Changes

**Trigger Rebuild**: When dependencies change or new features are needed.[1]

**Full Rebuild**: `makepkg -f` forces complete rebuild even if package exists.[1]

**Clean Build**: `makepkg -c` removes old sources and rebuilds.[1]

**After Modification**:[1]
```bash
# Edit PKGBUILD or patches
makepkg -f  # Force rebuild
makepkg -i  # Install immediately
```

### Version Tracking

**Upstream Versions**: Monitor official package versions to catch security updates.[1]

**Check Updates**: `pacman -Qu` shows outdated packages.[1]

**Compare Versions**: View official PKGBUILD to see latest upstream version.[1]

### Patch Management in ABS/ASP

**Patch Files**: Located alongside PKGBUILD in same directory.[2][1]

**Patch Format**: Unified diff format (.patch extension).[1]

**Apply in prepare()**:[1]

```bash
prepare() {
    cd "$pkgname-$pkgver"
    patch -p1 < ../myfix.patch
}
```

**Source Array**:[1]

```bash
source=("https://example.com/package.tar.gz"
        "security-fix.patch"
        "compatibility.patch")
```

### Maintaining Local Builds

**Directory Organization**:[1]
```
~/packages/
├── mypackage/
│   ├── PKGBUILD
│   ├── custom.patch
│   └── build/
└── anotherpackage/
    └── PKGBUILD
```

**Version Control**: Store in Git for tracking modifications.[1]

**Build Script**: Create shell script automating build process:[1]

```bash
#!/bin/bash
for pkg in mypackage anotherpackage; do
    cd ~packages/$pkg
    makepkg -f -i
done
```

### Integration with Pacman

**Priority Over Official**: Custom-built packages are not automatically superseded by official updates.[1]

**Version Comparison**: When upstream version increases, pacman treats custom as older if `pkgver` is lower.[1]

**Manual Override**: `sudo pacman -Syu --ignore=package` prevents reinstalling specific package.[1]

### Security Considerations

**Source Verification**: Check PKGBUILD for suspicious commands before building.[2][1]

**Signature Validation**: Use GPG-signed sources when available.[1]

**Patch Review**: Examine patch content before applying.[1]

**Trusted Sources**: Only use PKGBUILD from official repository or trusted developers.[2]

### Performance Optimization

**Compiler Flags**: Modify `/etc/makepkg.conf` globally:[1]

```bash
CFLAGS="-march=native -O3 -pipe"
CXXFLAGS="$CFLAGS"
MAKEFLAGS="-j$(nproc)"
```

**Architecture Optimization**: `march=native` enables CPU-specific optimizations.[1]

**Parallel Compilation**: `MAKEFLAGS="-j8"` builds with 8 parallel jobs.[1]

### Troubleshooting ABS/ASP

**Source Download Failure**: Verify upstream server availability; try alternate mirror.[1]

**Build Failures**: Check for missing dependencies or compiler incompatibility.[1]

**Patch Conflicts**: Verify patch compatibility with package version.[1]

**Permission Issues**: Run without sudo; use sudo only for pacman operations.[1]

### Best Practices

**Document Changes**: Maintain notes explaining modifications.[1]

**Version Control**: Use Git to track PKGBUILD versions.[1]

**Regular Updates**: Periodically update sources via `asp update`.[1]

**Test Before Installing**: Build and verify package works before full installation.[1]

**Clean Up**: Remove build artifacts after successful builds.[1]

### Integration with Custom Repository

**Host Local Packages**: Create repository containing custom builds:[1]

```bash
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

**Configure Pacman**:[1]

```
[myrepo]
SigLevel = Never
Server = file:///path/to/repo
```

**Priority Management**: Order repositories in `/etc/pacman.conf` to control precedence.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] archlinux/mkinitcpio: Arch Linux initramfs generation tools ... https://github.com/archlinux/mkinitcpio

