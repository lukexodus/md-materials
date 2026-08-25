## Security and Integrity Verification (GPG Keys, Checksums)


### Security Overview

**Importance**: Package verification ensures software authenticity and integrity, protecting against tampering, malware injection, and man-in-the-middle attacks.[1][2]

**Layers of Verification**:[2][1]
- Checksum validation[1]
- GPG signature verification[1]
- Package database signing[2]

### Checksums and Hashing

#### Purpose of Checksums

**Integrity Verification**: Checksums detect accidental corruption or deliberate modification.[2][1]

**Automated Verification**: Pacman automatically verifies package checksums during download.[1]

**Non-Cryptographic**: Checksums alone cannot prevent deliberate tampering by attackers with access to signing infrastructure.[1]

#### Checksum Algorithms

**SHA-256**: Current standard for Arch package verification.[2][1]

**Prevalence**:[1]
- Default for official packages[1]
- Cryptographically secure[1]
- 256-bit output[1]

**SHA-512**: Stronger alternative:[1]

```bash
sha512sum filename
```

**MD5**: Legacy, cryptographically broken, should not be used.[1]

**SHA-1**: Deprecated, collisions found, avoid.[1]

#### Generating Checksums

**Calculate Single File**:[1]

```bash
sha256sum package.tar.gz
```

**Output Format**:[1]

```
abcd1234ef5678ab... package.tar.gz
```

**Multiple Files**:[1]

```bash
sha256sum *.tar.gz > checksums.txt
```

**Verify**: `sha256sum -c checksums.txt` verifies all files.[1]

#### PKGBUILD Integration

**sha256sums Array**:[1]

```bash
sha256sums=('abcd1234ef5678ab...'
            'efgh5678ij9012cd...')
```

**Automatic Update**: `updpkgsums` regenerates checksums:[1]

```bash
updpkgsums
```

**Skipping Verification** (Not Recommended):[1]

```bash
sha256sums=('SKIP' 'SKIP')
```

### GPG (GNU Privacy Guard)

#### GPG Overview

**Purpose**: GPG provides cryptographic signing and verification using public-key cryptography.[2][1]

**Authentication**: Signatures prove the signer's identity.[1]

**Non-Repudiation**: Signer cannot deny creating the signature.[1]

**Key Pair System**:[1]
- Public key: Shared for verification[1]
- Private key: Kept secret for signing[1]

#### Installation

**Installation**: `sudo pacman -S gnupg`.[2][1]

**Status**: Usually pre-installed with systemd.[1]

**Verification**: `gpg --version` confirms installation.[2]

### Package Signature Verification

#### Signature Checking in Pacman

**SigLevel Settings**: `/etc/pacman.conf` controls signature verification:[2][1]

```
SigLevel = Required DatabaseOptional
```

**Levels**:[2][1]
- **`Never`**: No signature verification[2]
- **`Optional`**: Verify if present, but not required[1]
- **`Required`**: Fail if signature absent or invalid[1]
- **`TrustedOnly`**: Accept only signatures from trusted keys[2]

**Enforcement**:[2]
- **`DatabaseOptional`**: Database signature optional[2]
- **`DatabaseRequired`**: Database must be signed[2]

#### Repository Configuration

**Global Setting**:[2]

```
SigLevel = Required DatabaseOptional
```

**Per-Repository**:[2]

```
[core]
SigLevel = Required DatabaseRequired
Include = /etc/pacman.d/mirrorlist
```

**Legacy Compatibility**:[2]

```
SigLevel = Never  # Disable for old mirrors
```

### Pacman Keyring Management

#### Keyring Purpose

**Trusted Keys**: `/etc/pacman.d/gnupg/` stores trusted signing keys.[2]

**Initial Population**: Live installation media includes Arch developer keys.[2]

**Updates**: Keys are updated via `pacman-key`.[2]

#### Key Management Commands

**List Installed Keys**: `pacman-key -l` displays all trusted keys.[2]

**Refresh Keys**: `sudo pacman-key --refresh-keys` updates from key servers.[2]

**Initialize Keys**: `sudo pacman-key --init` generates new keyring.[2]

**Add Key**:[2]

```bash
sudo pacman-key --add /path/to/key.asc
```

**Sign Key**: Trust a key by signing:[2]

```bash
sudo pacman-key --lsign-key KEYID
```

**Revoke Key**: Remove trusted key:[2]

```bash
sudo pacman-key --delete KEYID
```

**Export Keys**: Backup keyring:[2]

```bash
sudo pacman-key --export > my-keys.asc
```

### Verification During Installation

#### Automatic Verification

**Default Behavior**: Pacman verifies database and package signatures automatically.[2]

**Silent Success**: Valid signatures cause no output.[2]

**Error Display**: Invalid or missing signatures show warnings.[2]

#### Manual Verification

**Sign Package Files**: Users can verify before installation:[1]

```bash
pacman -Si package_name
```

**Include Signature Info**: Signature details shown in package info.[2]

**Verify Manually**:[1]

```bash
gpg --verify package.pkg.tar.zst.sig package.pkg.tar.zst
```

### Creating GPG Signatures

#### Generate Key Pair

**Create Keys**:[1]

```bash
gpg --gen-key
```

**Interactive Setup**:[1]
- Key type (RSA recommended)[1]
- Key size (4096 bits)[1]
- Validity period[1]
- Name and email[1]

#### Sign Package

**Create Signature**:[1]

```bash
gpg --detach-sign --armor package.pkg.tar.zst
```

**Output**: Creates `package.pkg.tar.zst.asc` signature file.[1]

**Signature Types**:[2]
- **Detached**: Separate signature file[2]
- **Binary**: Embedded in file[2]

### AUR Package Security

#### PKGBUILD Review

**Critical Practice**: Always review PKGBUILDs before building.[3][2]

**Security Check**:[3]
- Search for suspicious commands[3]
- Verify URLs are legitimate[3]
- Check for network connections during build[3]
- Confirm file modifications[3]

#### Signature Validation in PKGBUILD

**validpgpkeys**: Specifies expected signing keys:[4][2]

```bash
validpgpkeys=('KEYID1' 'KEYID2')
```

**Source Signature**:[2]

```bash
source=("https://example.com/package.tar.gz"
        "https://example.com/package.tar.gz.asc")

validpgpkeys=('1234567890ABCDEF')
```

**Verification**: Makepkg validates source signatures.[2]

### Checksum Verification in PKGBUILDs

#### PKGBUILD Checksums

**Hash Arrays**:[1]

```bash
sha256sums=('checksum1' 'checksum2')
sha512sums=('checksum1' 'checksum2')
```

**Algorithm Selection**: Defaults to sha256sums.[1]

**Multiple Algorithms**: Use highest security algorithm available.[1]

#### Automatic Makepkg Verification

**Verification Step**:[1]

```
==> Validating source files with sha256sums...
  -> Downloading package.tar.gz... PASSED
  -> myfix.patch... PASSED
```

**Failure Handling**: Build stops on checksum mismatch.[1]

#### Updating Checksums

**Regenerate All**:[1]

```bash
updpkgsums
```

**Manual Update**:[1]

```bash
sha256sum *.tar.gz *.patch >> ~/.temp
# Edit PKGBUILD with values from temp file
```

### Secure Network Communication

#### HTTPS Verification

**Default**: Pacman uses HTTPS for repository downloads.[2]

**Certificate Validation**: System CA certificates verify server identity.[2]

**Custom CAs**: For private mirrors, configure CA certificates.[2]

#### Mirror Trust

**Trusted Mirrors**: Use official Arch mirrors listed on archlinux.org.[2]

**Custom Mirrors**: Verify legitimacy before adding.[2]

**URL Scheme**: Always use HTTPS for remote repositories:[2][1]

```
Server = https://mirror.example.com/$repo/$arch
```

### Troubleshooting Verification Failures

#### Unknown Key Error

**Issue**:[2]

```
error: keyring is not writable
error: Required key missing from keyring
```

**Solution**:[2]
```bash
sudo pacman-key --refresh-keys
sudo pacman -S archlinux-keyring
```

#### Signature Failure

**Issue**:[2]

```
error: failed to verify the signature
```

**Causes**:[2]
- Key not in keyring[2]
- Signature corrupted[2]
- Signer key revoked[2]

**Solution**:[2]
- Update keyring[2]
- Verify package source[2]
- Check for known key issues[2]

#### Checksum Mismatch

**Issue**:[1]

```
==> Validating source files with sha256sums...
source.tar.gz ... FAILED
```

**Solutions**:[1]
- Delete source and retry download[1]
- Verify checksum is correct[1]
- Check upstream source integrity[1]

### Best Practices

**Verify Always**: Enable signature verification in pacman.conf.[2]

**Review PKGBUILDs**: Always examine before compilation.[3][2]

**Keep Keys Updated**: Regular `pacman-key --refresh-keys`.[2]

**Use HTTPS**: Enforce HTTPS for all repositories.[2]

**Document Trust**: Maintain records of trusted keys.[1]

**Backup Keyring**: Regularly backup `/etc/pacman.d/gnupg/`.[2]

**Monitor Security**: Subscribe to archlinux-announce mailing list.[2]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Arch's Pacman 7.1 Package Manager Brings Stronger ... https://linuxiac.com/arch-pacman-7-1-package-manager-brings-stronger-signature-enforcement/
[3] Arch User Repository - ArchWiki https://wiki.archlinux.org/title/Arch_User_Repository
[4] Notes on creating packages for the Arch User Repository (AUR) https://madskjeldgaard.dk/old-blog/aur-package-workflow/

