## Building Packages Manually with makepkg


### makepkg Overview

**Purpose**: Makepkg is the utility that automates the entire package building process, from source download through compilation to package creation.[1][2][3]

**Location**: Included in the pacman package, pre-installed on Arch systems.[1]

**Workflow**: Reads PKGBUILD, executes build functions, and produces installable `.pkg.tar.zst` package.[2]

### Prerequisites

#### Base Development Tools

**Installation**: `sudo pacman -S base-devel`.[3][1]

**Includes**:[3]
- `gcc`: C/C++ compiler[3]
- `make`: Build automation[3]
- `pacman`: Package manager[3]
- `sudo`: Privilege escalation[3]
- Git and other utilities[3]

**Verification**: `which makepkg` confirms installation.[1]

#### User Setup

**Non-root User**: Never run makepkg as root. Makepkg refuses to execute with root privileges.[1][3]

**Build Directory**: Create working directory for builds:[1]

```bash
mkdir -p ~/builds
cd ~/builds
```

### Basic makepkg Usage

#### Compile Package

**Simple Build**: `makepkg` in directory containing PKGBUILD:[2][1]

```bash
cd ~/builds/mypackage
makepkg
```

**Output**: Creates `.pkg.tar.zst` file in current directory.[2][1]

**Filename Format**: `pkgname-pkgver-pkgrel-arch.pkg.tar.zst`.[2]

#### Build and Install

**Combined Operation**: `makepkg -i` builds and immediately installs:[1][3]

```bash
cd ~/builds/mypackage
makepkg -i
```

**Automatic Dependency Installation**: With `-i`, makepkg uses pacman to install dependencies.[1]

### makepkg Options

#### Cleaning Options

**`-c` (--clean)**: Remove old sources before building.[1][3]

```bash
makepkg -c
```

**Purpose**: Ensures fresh source download, removing cached old versions.[1]

**`-C` (--cleanbuild)**: Remove entire source and build directories:[3]

```bash
makepkg -C
```

**Use Case**: Start completely fresh for troubleshooting.[3]

#### Dependency Handling

**`-d` (--nodeps)**: Skip dependency checking:[1][3]

```bash
makepkg -d
```

**Caution**: Compilation will fail if dependencies are missing.[1]

**`-s` (--syncdeps)**: Automatically install missing dependencies via sudo:[3][1]

```bash
makepkg -s
```

**Effect**: Pacman installs any missing makedepends automatically.[3]

#### Rebuilding Options

**`-f` (--force)**: Force rebuild even if package exists:[1][3]

```bash
makepkg -f
```

**Purpose**: Useful after modifying PKGBUILD.[1]

**`-e` (--noextract)**: Do not extract sources:[3]

```bash
makepkg -e
```

**Use Case**: Recompile without re-extracting (faster for debugging).[3]

#### Installation Options

**`-i` (--install)**: Install package after building:[1][3]

```bash
makepkg -i
```

**Effect**: Automatically runs `pacman -U` on compiled package.[1]

**`-r` (--rmdeps)**: Remove makedepends after successful build:[3][1]

```bash
makepkg -r
```

**Purpose**: Cleans up compilation-only dependencies.[1]

#### Output Options

**`-v` (--verbose)**: Display detailed build output:[3]

```bash
makepkg -v
```

**Purpose**: Aids troubleshooting with additional information.[3]

### Common Command Combinations

**Full Build with Dependencies and Installation**:[1][3]

```bash
makepkg -si
```

**Parameters**:
- **`-s`**: Install dependencies[1]
- **`-i`**: Install after building[1]

**Recommended for Most Users**.[3]

**Clean Build with Full Dependency Management**:[1]

```bash
makepkg -Ccsi
```

**Parameters**:
- **`-C`**: Full clean[1]
- **`-c`**: Clean sources[1]
- **`-s`**: Sync dependencies[1]
- **`-i`**: Install[1]

**Use for Fresh Builds**.[1]

**Force Rebuild Without Dependencies**:[3]

```bash
makepkg -fde
```

**Parameters**:
- **`-f`**: Force[3]
- **`-d`**: Skip dependency check[3]
- **`-e`**: Don't extract[3]

**Use for Quick Recompilation After Changes**.[3]

### Obtaining PKGBUILD

#### From Official Repositories

**Using ASP**:[1]

```bash
asp checkout linux
cd linux
makepkg -si
```

**Using Git Clone**:[1]

```bash
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/linux.git
cd linux
makepkg -si
```

#### From AUR

**Clone Repository**:[3][1]

```bash
git clone https://aur.archlinux.org/mypackage.git
cd mypackage
makepkg -si
```

#### Custom or Local

**Create Directory**:[3]

```bash
mkdir -p ~/builds/mypackage
cd ~/builds/mypackage
# Copy or create PKGBUILD
makepkg -si
```

### Build Process Execution

#### Execution Stages

**Automatic Progression**:[2]

1. **Download**: Sources fetched from URLs[2]
2. **Extract**: Archives decompressed[2]
3. **prepare()**: Pre-compilation setup executed[2]
4. **build()**: Compilation performed[2]
5. **check()**: Tests run (if present)[2]
6. **package()**: Files installed to staging[2]
7. **Compression**: Package archive created[2]

#### Monitoring Progress

**Console Output**: Makepkg displays progress for each stage:[2]

```
==> Downloading sources...
  -> Downloading package.tar.gz...
==> Validating source files...
==> Extracting sources...
==> Entering fakeroot environment...
==> Starting build()...
==> Starting package()...
==> Finished making: package-1.0-1-x86_64.pkg.tar.zst
```

**Stopping on Error**: Build halts immediately on failure, displaying error message.[2]

### Troubleshooting Build Failures

#### Missing Dependencies

**Error Message**:[3]

```
==> Missing build dependencies:
  -> gcc
```

**Solution**: Install with `makepkg -s` or manually:[3]

```bash
sudo pacman -S gcc
makepkg
```

#### Source Download Failure

**Issue**: Server unavailable or URL wrong.[1]

**Diagnosis**: Check URL in PKGBUILD:[1]

```bash
grep source PKGBUILD
```

**Solution**: Verify URL and check network connectivity.[3]

#### Checksum Mismatch

**Error Message**:[1]

```
==> Validating source files with sha256sums...
package.tar.gz ... FAILED
```

**Causes**:[1]
- Source file corrupted[1]
- Checksum incorrect[1]
- Server replaced file[1]

**Solution**:[1]
- Delete source and retry[1]
- Verify checksum manually with `sha256sum`[1]
- Update PKGBUILD with correct checksum[1]

#### Compilation Error

**Issue**: Code fails to compile.[2]

**Diagnosis**: Review error output carefully:[3]

```bash
makepkg 2>&1 | tail -50  # Show last 50 lines
```

**Common Causes**:[3]
- Missing development headers[3]
- Incompatible compiler version[3]
- Obsolete or unmaintained package[3]

#### Permission Denied

**Error Message**:[1]

```
error: You cannot perform this operation unless you are root.
```

**Cause**: Running makepkg as root.[1]

**Solution**: Run as regular user:[1]

```bash
# Correct
makepkg -si

# Wrong
sudo makepkg -si  # Don't do this
```

### Inspecting Build Results

#### Package Contents

**List Files**: `tar -tzf package.pkg.tar.zst` lists package contents:[1]

```bash
tar -tzf mypackage-1.0-1-x86_64.pkg.tar.zst | head -20
```

**Verify Installation**: Check expected files are present.[1]

#### File Locations

**Expected Paths**:[3]
- `/usr/bin`: Executables[3]
- `/usr/lib`: Libraries[3]
- `/usr/share`: Data files[3]
- `/etc`: Configuration files[3]

#### Size Verification

**Check Package Size**: `ls -lh package.pkg.tar.zst`.[1]

**Unusually Large**: May indicate unnecessary files included.[1]

**Solution**: Modify package() function to remove unwanted files.[1]

### Performance Optimization

#### Parallel Compilation

**Environment Variable**: Set `MAKEFLAGS` for parallel jobs:[1]

```bash
export MAKEFLAGS="-j$(nproc)"
makepkg
```

**Calculation**: `$(nproc)` returns CPU core count.[1]

**Persistent Setting**: Add to `~/.bashrc` or `~/.bash_profile`:[1]

```bash
export MAKEFLAGS="-j$(nproc)"
export CFLAGS="-march=native -O3 -pipe"
```

#### Compiler Optimization

**CPU-Specific**: `-march=native` enables architecture-specific optimizations:[1]

```bash
export CFLAGS="-march=native -O3 -pipe"
makepkg
```

**Caveats**:[1]
- Builds slower[1]
- Package optimized for specific CPU[1]
- Cannot run on incompatible CPUs[1]

### Working with Split Packages

**Multiple Outputs**: Some PKGBUILDs create multiple packages.[2]

**Build All**: `makepkg` builds and creates all split packages.[3]

**Output Files**:[3]
```
mypackage-1.0-1-x86_64.pkg.tar.zst
mypackage-docs-1.0-1-x86_64.pkg.tar.zst
mypackage-dev-1.0-1-x86_64.pkg.tar.zst
```

**Install Selectively**: Install only desired packages:[1]

```bash
sudo pacman -U mypackage-1.0-1-x86_64.pkg.tar.zst
# Don't install docs or dev
```

### Best Practices

**Review PKGBUILD**: Always examine before building.[3]

**Use -si**: Combine dependencies and installation.[3]

**Clean Regularly**: Remove old sources with `-c`.[1]

**Document Modifications**: Comment any PKGBUILD changes.[1]

**Test Installation**: Verify package functionality after build.[3]

**Backup Successful Builds**: Keep compiled packages.[1]

**Check Logs**: Review build output for warnings.[3]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] archlinux/mkinitcpio: Arch Linux initramfs generation tools ... https://github.com/archlinux/mkinitcpio
[3] Pacman command in Arch Linux - GeeksforGeeks https://www.geeksforgeeks.org/linux-unix/pacman-command-in-arch-linux/

