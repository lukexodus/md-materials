## Using AUR Helpers (yay, paru, aura, etc.)


### AUR Helpers Overview

**Purpose**: AUR helpers automate the workflow of cloning Git repositories, building packages with makepkg, and installing via pacman, simplifying AUR package management.[1][2]

**Installation Source**: AUR helpers are themselves in the AUR; they must be bootstrapped manually or obtained from binary releases.[2][1]

**Not Official**: Arch does not officially maintain AUR helpers; they are community projects.[1]

**Functionality**: Helpers combine Git version control, makepkg compilation, and pacman installation into unified commands.[1]

### Popular AUR Helpers

#### yay (Yet Another Yaourt)

**Language**: Go.[1]

**Development**: Actively maintained with focus on speed and simplicity.[1]

**Installation**:[3][2]

```bash
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

**Usage**:[2][1]
- **`yay package_name`**: Search and install package interactively[2]
- **`yay -S package_name`**: Install package (like pacman)[1]
- **`yay -Syu`**: Upgrade AUR and official packages[1]
- **`yay -Ss query`**: Search AUR and official repositories[1]
- **`yay -Rns package_name`**: Remove package and dependencies[1]

**Configuration**: `~/.config/yay/config.json` for user settings.[1]

#### paru (Pacman-based AUR-Rust Utility)

**Language**: Rust.[1]

**Focus**: User-friendly interactive experience with detailed prompts.[1]

**Installation**:[1]

```bash
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

**Usage**:[1]
- **`paru package_name`**: Interactive package search and install[1]
- **`paru -S package_name`**: Install package directly[1]
- **`paru --gendb`**: Generate package database for faster searches[1]
- **`paru -G package_name`**: Download PKGBUILD without building[1]
- **`paru --review`**: Review PKGBUILDs before installation[1]

**Features**:[1]
- Detailed dependency information[1]
- Edit prompt before compilation[1]
- Built-in PKGBUILD review tools[1]

#### aura

**Language**: Haskell.[1]

**Multilingual**: Internationalization support.[1]

**Installation**:[1]

```bash
git clone https://aur.archlinux.org/aura.git
cd aura
makepkg -si
```

**Usage**:[1]
- **`aura -A package_name`**: Install AUR packages[1]
- **`aura -Au`**: Update AUR packages[1]
- **`aura -Ax`**: Perform system backups[1]

**Unique Features**:[1]
- Built-in system backup functionality[1]
- Language customization[1]

#### aurutils

**Language**: Bash.[1]

**Philosophy**: Modular collection of standalone utilities.[1]

**Installation**:[1]

```bash
git clone https://aur.archlinux.org/aurutils.git
cd aurutils
makepkg -si
```

**Components**:[1]
- **aur**: Core utility[1]
- **aur-search**: Query AUR[1]
- **aur-fetch**: Download packages[1]
- **aur-build**: Compile packages[1]
- **aur-install**: Install packages[1]

**Advanced Use**: Suitable for scripting and custom workflows.[1]

### Comparison of AUR Helpers

| Helper | Language | Speed | Interactivity | Complexity | Maintenance |
|--------|----------|-------|---------------|-----------|------------|
| **yay** | Go [1] | Fast [1] | Moderate [1] | Simple [1] | Active [1] |
| **paru** | Rust [1] | Very Fast [1] | High [1] | Moderate [1] | Active [1] |
| **aura** | Haskell [1] | Slow [1] | High [1] | Simple [1] | Active [1] |
| **aurutils** | Bash [1] | Moderate [1] | Low [1] | Complex [1] | Active [1] |

### Basic AUR Helper Operations

#### Searching and Installing

**Interactive Search**: `yay firefox` searches and prompts for installation:[2]

```bash
yay firefox
# Lists matching packages with numbers
# User enters number to select and confirm installation
```

**Direct Installation**: `yay -S package_name` installs without interactive prompt.[1]

**Multiple Packages**: `yay -S package1 package2 package3`.[1]

#### System Updates

**Unified Upgrade**: `yay -Syu` upgrades both official and AUR packages.[2][1]

**Official Only**: `yay -Sy` or standard `pacman -Sy`.[1]

**AUR Only**: `yay -Syu --aur` (yay-specific).[1]

#### Searching

**Repository Search**: `yay -Ss keyword` searches all repositories.[2][1]

**Local Search**: `yay -Qs keyword` searches only installed packages.[1]

**File Search**: `yay -Fs filename` finds file in packages.[1]

### Advanced Helper Features

#### PKGBUILD Review

**paru Review Mode**: `paru --review package_name` displays PKGBUILD before compilation.[2][1]

**Manual Inspection**: Most helpers allow editing PKGBUILD before building.[1]

#### Download Without Building

**yay**: `yay -G package_name` clones repository.[1]

**paru**: `paru -G package_name` downloads only.[1]

**Purpose**: Review PKGBUILD before committing to compilation.[1]

#### Database Generation

**paru**: `paru --gendb` generates local database for fast searching.[1]

**Performance**: Subsequent searches run faster without server queries.[1]

**Update**: Periodic regeneration keeps database current.[1]

### Configuration and Customization

#### yay Configuration

**Config File**: `~/.config/yay/config.json`.[1]

**Example Settings**:[1]

```json
{
  "aururl": "https://aur.archlinux.org",
  "builddir": "/tmp/makepkg",
  "editor": "nano",
  "makepkgbin": "makepkg"
}
```

#### paru Configuration

**Config File**: `~/.config/paru/paru.conf`.[1]

**Example Settings**:[1]

```
[options]
PacmanBin = /usr/bin/pacman
MakepkgBin = /usr/bin/makepkg
Sudo = /usr/bin/sudo
```

#### Compiler Flags

**Global Setting**: Modify `/etc/makepkg.conf` for all builds:[1]

```bash
CFLAGS="-march=native -O3 -pipe"
MAKEFLAGS="-j$(nproc)"
```

**Per-Helper**: Some helpers read `makepkg.conf` automatically.[1]

### Handling Dependencies

**Automatic Resolution**: Helpers resolve AUR dependencies automatically.[2][1]

**Mixed Dependencies**: Helpers identify which dependencies are in official repos versus AUR.[1]

**Build Dependencies**: Automatically installed during compilation, removed after if not needed.[1]

**Optional Dependencies**: Listed but not automatically installed; users install manually.[1]

### Working with Build Failures

**Compilation Error**: Helper displays error output from makepkg.[1]

**Investigation**:[1]
1. Review error message[1]
2. Use `-G` option to download and inspect PKGBUILD[1]
3. Check for missing build dependencies[1]
4. Consult AUR package page for known issues[1]

**Outdated PKGBUILD**: Some packages become outdated when upstream changes.[1]

**Alternative**: Look for updated community fork or submit report.[1]

### Removing Packages

**Uninstall**: `yay -Rns package_name` removes package, dependencies, and configuration.[1]

**Keep Config**: `yay -R package_name` removes package only.[1]

**Cascade Removal**: `yay -Rc package_name` removes package and packages depending on it.[1]

### Security Considerations

**PKGBUILD Review**: Always review before building from untrusted sources.[2][1]

**Helper Automation**: Helpers reduce review opportunities; manual builds ensure thorough inspection.[1]

**Maintain Vigilance**: Helpers should not reduce security awareness.[1]

**Mailing List**: Subscribe to aur-general for security announcements.[1]

### Best Practices

**Choose One Helper**: Stick with single helper for consistency; mixing causes conflicts.[1]

**Review Regularly**: Periodically review PKGBUILDs even for trusted packages.[2]

**Update Frequently**: Regular `yay -Syu` maintains security patches.[1]

**Document Installation**: Keep notes of manually installed AUR packages.[1]

**Verify Installation**: Test installed packages work correctly.[2]

**Backup Configuration**: Backup helper configurations for system recovery.[1]

### Common Issues

**Network Errors**: Re-run command; transient network issues often resolve.[1]

**Build Failures**: Check upstream project for known issues.[1]

**Dependency Conflicts**: Resolve manually or wait for package updates.[1]

**Permission Denied**: Ensure build directory is writable.[1]

**Outdated Database**: Regenerate with `paru --gendb` or similar.[1]

### Bootstrapping AUR Helpers

**Chicken-Egg Problem**: First AUR helper installation requires manual bootstrap.[3][1]

**Process**:[3]
1. Install base-devel: `sudo pacman -S base-devel`[3]
2. Clone helper: `git clone https://aur.archlinux.org/helper.git`[3]
3. Build: `cd helper && makepkg -si`[3]
4. Use for future AUR packages[3]

### Helper Comparison Recommendations

**Beginners**: Use yay for simplicity and speed.[1]

**Advanced Users**: Use paru for control and interactivity.[1]

**Automation**: Use aurutils for scripting and customization.[1]

**International Users**: Consider aura for language support.[1]

### Disabling Helpers

**Manual Workflow**: Users can revert to manual Git/makepkg at any time.[1]

**Uninstall**: `pacman -R yay` removes helper (packages remain).[1]

**Return to Manual**: Clone and build packages directly with makepkg.[1]

Sources
[1] Arch User Repository - ArchWiki https://wiki.archlinux.org/title/Arch_User_Repository
[2] A beginner's guide to the Arch User Repository - tilde.town https://tilde.town/~kzimmermann/articles/aur_made_easy.html
[3] Build And Install Packages From The Arch User Repository (AUR). https://roughlea.wordpress.com/linux-administration/installing-arch-linux-on-raspberry-pi/build-and-install-packages-from-the-arch-user-repository-aur/

