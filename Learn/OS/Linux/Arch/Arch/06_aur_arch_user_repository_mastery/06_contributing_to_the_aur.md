## Contributing to the AUR


### AUR Contribution Overview

**Purpose**: The Arch User Repository enables community members to share and maintain packages, democratizing package availability and allowing users to become package maintainers.[1][2]

**Community-Driven**: All AUR packages are maintained by volunteers; Arch Linux project provides infrastructure.[1]

**Low Barrier**: Anyone with Arch Linux knowledge can contribute packages.[2]

### Account Setup

#### Creating AUR Account

**Registration**: Visit https://aur.archlinux.org and create account.[2][1]

**Username Requirements**:[2]
- 3-16 characters[2]
- Alphanumeric and hyphens only[2]
- Must be unique[2]

**Email Verification**: Confirm email address to activate account.[2]

**Password**: Use strong, unique password.[2]

#### SSH Key Configuration

**Purpose**: SSH keys enable secure repository operations without password entry.[2]

**Generate Key Pair**:[2]

```bash
ssh-keygen -t ed25519 -f ~/.ssh/aur -C "aur"
```

**Parameters**:[2]
- `-t ed25519`: Modern, secure key type[2]
- `-f ~/.ssh/aur`: Key file location[2]
- `-C "aur"`: Comment identifier[2]

**SSH Config**: Create `~/.ssh/config` entry:[2]

```
Host aur.archlinux.org
    IdentityFile ~/.ssh/aur
    User aur
```

**Upload Public Key**:[2]
1. Copy contents of `~/.ssh/aur.pub`[2]
2. Log into AUR web interface[2]
3. Paste into "SSH Public Key" field[2]
4. Save[2]

**Verify**: Test connection:[2]

```bash
ssh aur.archlinux.org
```

**Expected Response**: "Interactive shell is disabled" message confirms connectivity.[2]

### Creating New Packages

#### Package Preparation

**PKGBUILD Creation**: Develop complete, tested PKGBUILD.[1][2]

**Requirements**:[1]
- Valid bash syntax[1]
- Correct dependencies[1]
- Working build process[1]
- Proper checksums[1]

**Generate .SRCINFO**:[2]

```bash
makepkg --printsrcinfo > .SRCINFO
```

**Purpose**: Pre-generated metadata for AUR search indexing.[2]

**Inclusion**: Must be committed with every update.[2]

#### Initial Repository Creation

**Clone Empty Repository**:[2]

```bash
git clone ssh://aur.archlinux.org/newpackage.git
cd newpackage
```

**Repository**: Created automatically on first push.[2]

**Add Files**:[2]

```bash
cp ~/mypackage/PKGBUILD .
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO
git commit -m "Initial commit: add newpackage package"
git push
```

**Verification**: Package appears on AUR after push.[2]

### Maintaining Packages

#### Regular Updates

**Version Bumps**: Update when upstream releases new versions.[1][2]

**Modification Workflow**:[2]
1. Update `pkgver` in PKGBUILD[2]
2. Reset `pkgrel=1`[2]
3. Update `source` URL if changed[2]
4. Run `updpkgsums`[2]
5. Regenerate .SRCINFO[2]
6. Commit and push[2]

**Commit Message**:[2]

```bash
git commit -m "pkgver bump: 1.0 -> 2.0"
git push
```

#### Bug Fixes

**User Reports**: Monitor package page for comments.[1]

**Patch Application**:[2]
1. Create/apply patch[2]
2. Update PKGBUILD[2]
3. Increment `pkgrel`[2]
4. Regenerate .SRCINFO[2]
5. Commit with descriptive message[2]

**Example**:[2]

```bash
git commit -m "Fix build with recent GCC version"
```

#### Dependency Changes

**Update Dependencies**:[2]

```bash
depends=('newdep' 'anotherdep')
makedepends=('build-tool')
optdepends=('optional: optional feature')
```

**Regenerate .SRCINFO**: Required for every change:[2]

```bash
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO
git commit -m "Update dependencies"
git push
```

### Package Naming and Standards

#### Naming Conventions

**lowercase**: Use only lowercase letters.[1][2]

**Hyphens**: Use hyphens instead of underscores.[2]

**Version Suffix**: Append version to avoid conflicts:[1]
- `package-nightly` for development versions[1]
- `package-lts` for long-term support versions[1]

**lib32- Prefix**: For 32-bit libraries on multilib systems:[1]

```bash
lib32-openssl
```

#### PKGBUILD Standards

**Metadata Completeness**:[1][2]
- Accurate `pkgdesc` (one-line description)[1]
- Valid `license` from SPDX list[1]
- Working `url` to project website[1]

**Dependencies Accuracy**:[1]
- Include all runtime `depends`[1]
- List all compilation `makedepends`[1]
- Document useful `optdepends`[1]

**File Organization**:[1]
- Clean `package()` function[1]
- Remove unnecessary files[1]
- Follow standard directory structure[1]

### Licensing Considerations

**License Specification**: PKGBUILD must identify software license.[1][2]

**SPDX Identifiers**: Use standardized licenses:[1]

```bash
license=('GPL3')
license=('Apache2')
license=('MIT')
```

**Proprietary**: For closed-source software:[1]

```bash
license=('custom: proprietary')
```

**Multiple Licenses**: Combine with plus sign:[1]

```bash
license=('GPL2' 'MIT')
```

### Troubleshooting Contributions

#### SSH Connection Issues

**Test SSH**: Verify key connectivity:[2]

```bash
ssh -v aur.archlinux.org
```

**Key Permissions**: Ensure proper permissions:[2]

```bash
chmod 600 ~/.ssh/aur
chmod 700 ~/.ssh
```

**SSH Agent**: Load key if using passphrase:[2]

```bash
ssh-add ~/.ssh/aur
```

#### Git Errors

**Authentication Failure**:[2]

```
Permission denied (publickey)
```

**Solution**: Verify SSH key is uploaded and configured.[2]

**Merge Conflicts**: Avoid by keeping repository current:[2]

```bash
git pull
```

**Orphaned Package**: Cannot push to new package:[2]

Solution: Contact AUR administrator.[2]

### Package Promotion to Official

#### Criteria for Promotion

**Popularity**: Typically 10+ votes or 1% usage.[1]

**Quality Standards**:[1]
- Well-maintained PKGBUILD[1]
- Active upstream development[1]
- Community demand[1]

**Maintainer Reputation**: Reliable package history.[1]

#### Promoting Packages

**Request Adoption**: Comment on package page requesting adoption.[1]

**Trusted User Review**: Package Maintainers evaluate for promotion.[1]

**Transfer**: Successfully promoted packages move to extra repository.[1]

### Community Guidelines

#### Code of Conduct

**Respect**: Treat other maintainers professionally.[1]

**Responsiveness**: Address user comments and reports.[1]

**Quality**: Maintain high packaging standards.[1]

#### Etiquette

**Avoid Duplicates**: Check if package already exists.[1]

**Avoid Over-Splitting**: Don't create package for every minor tool.[1]

**Descriptive Names**: Use clear, unambiguous names.[1]

**Clear Descriptions**: Write helpful package descriptions.[1]

### Dealing with Package Conflicts

#### Duplicate Packages

**Search First**: Verify package doesn't already exist.[1][2]

**Contact Existing Maintainer**: Propose collaboration.[1]

**Alternative Names**: Use distinct naming if necessary.[1]

#### Package Takeover

**Unmaintained Packages**: Request adoption.[1][2]

**Notification**: AUR maintainers receive notification.[1]

**Approval**: Typically granted if original maintainer inactive.[1]

### Version Control Workflow

#### Git Workflow

**Clone Repository**:[2]

```bash
git clone ssh://aur.archlinux.org/mypackage.git
cd mypackage
```

**Make Changes**:[2]

```bash
# Edit PKGBUILD
nano PKGBUILD

# Regenerate metadata
makepkg --printsrcinfo > .SRCINFO

# Stage changes
git add PKGBUILD .SRCINFO

# Commit
git commit -m "Descriptive commit message"

# Push
git push
```

**Verify**: Changes visible on AUR web interface within minutes.[2]

### Documentation and Maintainability

#### Clear PKGBUILDs

**Comments**: Explain non-obvious decisions:[2]

```bash
# Custom: Disabled documentation to reduce install size
./configure --disable-doc
```

**Variable Names**: Use meaningful local variables:[2]

```bash
_commit=abc123
_libver=2.0
```

#### Maintenance Notes

**README**: Optional file documenting package specifics:[2]

```
# mypackage

This package includes custom patches for [reason].

Dependencies require [specific versions].
```

### Security Considerations

**GPG Signing**: Optional but recommended.[1][2]

**Signature Keys**: Add to PKGBUILD:[2]

```bash
validpgpkeys=('KEYID')
```

**Upstream Verification**: Always verify source authenticity.[1]

### Best Practices

**Test Thoroughly**: Build and verify installation before pushing.[1][2]

**Document Changes**: Use clear commit messages.[1][2]

**Maintain Responsiveness**: Reply promptly to user comments.[1]

**Follow Standards**: Adhere to Arch packaging guidelines.[1]

**Keep Dependencies Minimal**: Only include necessary dependencies.[1]

**Use Official When Possible**: Prefer official packages for users.[1]

**Communicate Clearly**: Maintain transparent relationship with community.[1]

Sources
[1] Arch User Repository - ArchWiki https://wiki.archlinux.org/title/Arch_User_Repository
[2] Notes on creating packages for the Arch User Repository (AUR) https://madskjeldgaard.dk/old-blog/aur-package-workflow/


