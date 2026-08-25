## Checksum Verification


### Overview

Checksums are cryptographic hash values used to verify file integrity by detecting accidental corruption during download or storage. In Arch Linux, checksums serve different purposes at various stages of package management.

### Checksums vs Signatures

**Important distinction:**

**Checksums:** Detect accidental corruption or incomplete downloads. They verify data integrity but **not** authenticity. An attacker can modify a file and provide a matching checksum.

**Signatures:** Provide cryptographic proof of authenticity using public key cryptography. They verify that packages come from trusted sources and haven't been tampered with.

Pacman relies primarily on GPG signatures for security, while checksums serve as an integrity check during the build process.

### Checksums in Package Building (makepkg)

#### PKGBUILD Checksum Arrays

When building packages with makepkg, checksums verify source files defined in the PKGBUILD. Multiple checksum algorithms are supported:

```bash
# PKGBUILD example
md5sums=('abc123...' 'def456...')
sha1sums=('...' '...')
sha256sums=('...' '...')
sha384sums=('...' '...')
sha512sums=('...' '...')
```

**Order matters:** Checksum values must correspond to source files in the same order as the `source` array.

#### Generating Checksums

Update or generate checksums for a PKGBUILD:

```
makepkg -g
```

Or:
```
updpkgsums
```

This calculates checksums for all source files and outputs them in the format needed for the PKGBUILD. Copy this output into your PKGBUILD file.

#### Skipping Specific Sources

Use `SKIP` in checksum arrays to bypass verification for specific sources:

```bash
sha256sums=('abc123...' 'SKIP' 'def456...')
```

This is useful for user-provided configuration files or sources where checksums cannot be predetermined.

#### Bypassing Checksum Verification

**Skip all integrity checks (not recommended):**
```
makepkg --skipinteg
```

**Skip only checksum verification:**
```
makepkg --skipchecksums
```

**Warning:** Only bypass checksums when you understand the security implications, such as during development or when working with known local sources.

### Checksums in Installed Packages

#### Package Metadata (.MTREE)

Installed packages include an `.MTREE` file containing file integrity information:

- SHA256 checksums for each file
- File sizes
- Permissions and ownership
- Modification times

This metadata enables verification of installed package files.

#### Basic Verification with pacman

**Check file presence:**
```
pacman -Qk package_name
```

This verifies files exist but does **not** verify checksums.

**Thorough file attribute check:**
```
pacman -Qkk package_name
```

Despite the name "thorough," this checks file attributes (size, modification time, permissions) but **not** actual checksums.

### Advanced Checksum Verification with paccheck

#### Installing paccheck

For genuine checksum verification of installed packages:

```
sudo pacman -S pacutils
```

The `pacutils` package provides `paccheck`, which performs actual checksum validation.

#### Checksum Verification Commands

**Verify MD5 checksums:**
```
paccheck --md5sum --quiet
```

**Verify SHA256 checksums:**
```
paccheck --sha256sum --quiet
```

**Comprehensive verification:**
```
paccheck --md5sum --sha256sum --file-properties --quiet
```

This performs complete validation including both checksums and file attributes.

**Output interpretation:**
- `--quiet` flag shows only packages with issues
- Without `--quiet`, displays detailed information for all packages
- Reports checksum mismatches, missing files, and modified files

#### Understanding Checksum Mismatches

**Expected modifications:** Configuration files in `/etc/` are meant to be user-modified. Checksum mismatches for config files are normal and expected.

**Unexpected modifications:** Checksum mismatches for binaries or libraries may indicate:
- File corruption
- Manual file modification
- Security compromise
- Incomplete package installation

### Manual Checksum Verification

#### Verifying Downloaded Files

For package archives or other files, calculate checksums manually:

**SHA256 (most common):**
```
sha256sum file.pkg.tar.zst
```

**MD5:**
```
md5sum file.pkg.tar.zst
```

**SHA1:**
```
sha1sum file.pkg.tar.zst
```

**SHA512:**
```
sha512sum file.pkg.tar.zst
```

#### Verify Against Checksum Files

If a checksum file is provided (e.g., `SHA256SUMS`):

```
sha256sum -c SHA256SUMS
```

This checks all files listed in the checksum file and reports which match and which don't.

**Example output:**
```
file1.tar.gz: OK
file2.tar.gz: FAILED
```

#### Verify Specific File

Create a temporary checksum file or pipe:

```
echo "abc123...  filename.tar.gz" | sha256sum -c -
```

The `-c` flag checks against the provided checksum, and `-` reads from stdin.

### Checksum Algorithms

**MD5 (128-bit):**
- Fast but cryptographically broken
- Still used for compatibility
- Adequate for detecting accidental corruption
- Not secure against deliberate tampering

**SHA-1 (160-bit):**
- Deprecated due to collision vulnerabilities
- Avoid for new projects

**SHA-256 (256-bit):**
- Current standard for most applications
- Strong security properties
- Good balance of speed and security

**SHA-512 (512-bit):**
- Highest security
- Slower than SHA-256
- Overkill for most use cases

### ISO Verification Workflow

When downloading Arch Linux installation media, verify both integrity and authenticity:

**Step 1: Download files**
```
archlinux-YYYY.MM.DD-x86_64.iso
archlinux-YYYY.MM.DD-x86_64.iso.sig
```

**Step 2: Verify checksum (integrity)**
```
sha256sum archlinux-YYYY.MM.DD-x86_64.iso
```

Compare output with the official checksum from archlinux.org.

**Step 3: Verify signature (authenticity)**
```
gpg --verify archlinux-YYYY.MM.DD-x86_64.iso.sig
```

**Both steps are necessary:** Checksums alone don't protect against malicious files if the checksum source is also compromised. Signatures provide cryptographic proof of authenticity.

### Graphical Tools

#### GtkHash

GUI application for checksum calculation and verification:

```
sudo pacman -S gtkhash
```

**Features:**
- Calculate multiple hash types simultaneously
- Compare hashes visually
- Verify checksum files
- User-friendly interface

**Usage:**
1. Open GtkHash
2. Select file to verify
3. Choose hash algorithms
4. Click "Hash" to calculate
5. Compare with official checksums

### Best Practices

**Use appropriate algorithms:** Prefer SHA-256 or SHA-512 for new checksums; avoid MD5 for security-critical applications.

**Verify sources:** Always obtain checksums from official, trusted sources over secure connections (HTTPS).

**Combine with signatures:** Use checksums for integrity and signatures for authenticity—both together provide comprehensive security.

**Regular integrity checks:** Periodically run `paccheck` to detect file corruption or unauthorized modifications.

**Understand limitations:** Checksums detect corruption but don't prevent malicious tampering unless combined with signatures.

**Configuration files are different:** Don't be alarmed by checksum mismatches for files in `/etc/`—these are expected to be modified.

**Automate verification:** For critical systems, implement automated checksum verification as part of monitoring and maintenance routines.

**Document exceptions:** Keep records of intentional file modifications that cause expected checksum mismatches.

Checksums are a fundamental tool for ensuring file integrity throughout the package management lifecycle, from building packages with makepkg to verifying installed files with paccheck.

