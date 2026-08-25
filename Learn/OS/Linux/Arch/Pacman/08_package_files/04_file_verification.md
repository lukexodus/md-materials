## File Verification


### Automatic Package Verification During Installation

#### Signature Verification

Pacman automatically verifies package integrity during installation using GPG signatures. This depends on the `SigLevel` setting configured in `/etc/pacman.conf`.[1]

**Process during installation:**
```
(1/1) checking keys in keyring
(1/1) checking package integrity
```


The signature verification ensures packages haven't been altered or tampered with during download or storage.[1]

#### Checksum vs Signature Verification

**Checksums:** Verify file integrity (detect corruption during download)[1]

**Signatures:** Verify authenticity (cryptographic proof the package comes from trusted source)[1]

Checksums alone are not for security—they only determine if the file was downloaded correctly. Signatures provide actual security guarantees.[1]

### Installed Package File Verification

#### Basic File Presence Check

Verify that all files from an installed package still exist on the system:[2][3]

```
pacman -Qk package_name
```


This checks if files are present but doesn't verify their integrity.[2]

**Check all installed packages:**
```
pacman -Qk
```


#### Thorough Integrity Check

Perform extensive verification including checksums, sizes, and permissions:[2][3]

```
pacman -Qkk package_name
```


The double `-kk` performs comprehensive checks including:
- File presence
- File sizes
- Modification times
- MD5 checksums
- Permissions and ownership[3]

**Check all packages thoroughly:**
```
pacman -Qkk
```


**Important limitation:** `pacman -Qkk` does **not** verify checksums—it only checks file attributes. For actual checksum verification, use `paccheck`.[1]

### Advanced Checksum Verification with paccheck

#### Installing paccheck

The `paccheck` utility from `pacutils` provides genuine checksum verification:[2]

```
sudo pacman -S pacutils
```


#### Checksum Verification Commands

**Verify MD5 checksums:**
```
paccheck --md5sum --quiet
```


**Verify SHA256 checksums:**
```
paccheck --sha256sum --quiet
```

**Combined verification:**
```
paccheck --md5sum --sha256sum --file-properties --quiet
```


This performs comprehensive validation including checksums and file attributes.[4]

**Output interpretation:**
- Displays only packages with integrity issues when using `--quiet`
- Shows which files have been modified, missing, or corrupted
- Reports checksum mismatches

### Verifying Package Archives

#### Manual Checksum Verification

For downloaded package files, verify integrity before installation using standard hash tools:[5][6]

**Generate SHA256 checksum:**
```
sha256sum package.pkg.tar.zst
```


**Compare with official checksum:**
If a checksum file is provided (e.g., `SHA256SUMS`):
```
sha256sum -c SHA256SUMS
```


This checks all files listed in the checksum file and reports matches/mismatches.[5]

**Other checksum algorithms:**
```
md5sum package.pkg.tar.zst
sha1sum package.pkg.tar.zst
sha512sum package.pkg.tar.zst
```


#### GPG Signature Verification

Verify package signature files (`.sig`) manually:

```
gpg --verify package.pkg.tar.zst.sig package.pkg.tar.zst
```

**Import required keys if missing:**
```
gpg --recv-keys KEY_ID
```

### Verification in Package Building

#### makepkg Integrity Checks

During package building, `makepkg` automatically verifies source file checksums defined in the PKGBUILD:[7][8]

**Checksum arrays in PKGBUILD:**
- `md5sums`
- `sha1sums`
- `sha256sums`
- `sha384sums`
- `sha512sums`[8]

**Skip integrity checks (not recommended):**
```
makepkg --skipinteg
```


**Skip only checksum verification:**
```
makepkg --skipchecksums
```


**Skip only PGP verification:**
```
makepkg --skippgpcheck
```


#### SKIP Directive in Checksums

PKGBUILDs can use `SKIP` in checksum arrays to bypass integrity checks for specific sources:[8]

```
sha256sums=('abc123...' 'SKIP' 'def456...')
```


This is useful for user-configurable sources where checksums cannot be predetermined.[8]

### ISO File Verification

#### Verifying Installation Media

When downloading Arch Linux ISO files, verify integrity and authenticity:[9]

**Step 1: Verify checksum (integrity)**
```
sha256sum archlinux-YYYY.MM.DD-x86_64.iso
```


Compare output with the official checksum from the Arch website.[9]

**Step 2: Verify PGP signature (authenticity)**
```
gpg --verify archlinux-YYYY.MM.DD-x86_64.iso.sig
```


**Why both are important:**
- MD5/SHA checksums verify the file wasn't corrupted during download[9]
- PGP signatures prevent malicious tampering even if the website is compromised[9]

A compromised website could provide matching checksums for a malicious ISO, but cannot forge valid PGP signatures.[9]

### Graphical Verification Tools

#### GtkHash

For users preferring GUI tools, `gtkhash` provides graphical checksum verification:[6]

```
sudo pacman -S gtkhash
```


**Features:**
- Calculate multiple hash types simultaneously
- Compare hashes visually
- Verify hash files
- User-friendly interface[6]

**Usage:**
1. Open GtkHash application
2. Add files to verify
3. Click "Hash" to calculate checksums
4. Compare with official checksums[6]

### Best Practices

**Always verify downloads:** Check checksums and signatures for ISO files and packages from untrusted sources.[9]

**Use both checksums and signatures:** Checksums verify integrity; signatures verify authenticity.[1][9]

**Regular integrity checks:** Periodically run `pacman -Qkk` or `paccheck` to detect file corruption or tampering.[4][3]

**Inspect verification output:** Don't ignore warnings about modified files—investigate the cause.[3]

**Configuration files are expected to differ:** Modified config files in `/etc/` are normal and expected.[3]

**Update keyrings:** Keep `archlinux-keyring` updated to avoid signature verification failures.[1]

**Don't skip verification unnecessarily:** Only use `--skipinteg` or `--skippgpcheck` when absolutely necessary and you understand the security implications.[7]

**Verify third-party packages:** Always verify checksums and signatures for packages from sources outside official repositories.[6]

Sources
[1] ELI5: Does pacman -S automatically verify package integrity? https://www.reddit.com/r/archlinux/comments/69n2ty/eli5_does_pacman_s_automatically_verify_package/
[2] [SOLVED] How to check integrity of package files / Pacman ... https://bbs.archlinux.org/viewtopic.php?id=195645
[3] Arch/Manjaro Linux: Checking Installed Package Integrity ... https://buymeacoffee.com/politictech/arch-linux-checking-installed-package-integrity-checksums-file-changes
[4] Check all installed packages for integrity - Pacman & AUR helpers https://forum.endeavouros.com/t/check-all-installed-packages-for-integrity/5297
[5] How to Verify SHA256 Checksum of File in Linux https://www.ubuntumint.com/verify-sha256-checksum-of-file-in-linux/
[6] How to Verify Checksums in Linux https://www.maketecheasier.com/verify-checksums-in-linux/
[7] Allow to skip validity checks · Issue #108 · archlinuxfr/yaourt https://github.com/archlinuxfr/yaourt/issues/108
[8] [pacman-dev] [PATCH] makepkg: Use SKIP in checksum to ... https://lists.archlinux.org/archives/list/pacman-dev@lists.archlinux.org/thread/FX54XEPEKKLREAI3YCWLZBZJD4GWGXRW/
[9] How to verify ArchLinux ISO file with PGP signature, MD5 ... https://www.youtube.com/watch?v=UeQKJOozpFI
[10] Show HN: Checksum.sh verify every install script https://news.ycombinator.com/item?id=33375554


