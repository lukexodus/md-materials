## Repository Signing


### Overview

Repository signing uses cryptographic signatures to verify the authenticity and integrity of packages and repository databases. This prevents tampering, ensures packages come from trusted sources, and protects against man-in-the-middle attacks.

### Cryptographic Basics

#### How Signing Works

**Public-key cryptography:**
1. Signer creates a key pair (public key + private key)
2. Signer uses private key to create signature for packages
3. Users import signer's public key
4. Pacman verifies signatures using public key
5. If signature is valid, package is trusted

**Benefits:**
- Authenticity - Proves who signed the package
- Integrity - Detects if package was modified
- Non-repudiation - Signer can't deny creating signature

### Setting Up GPG Keys

#### Generate GPG Key Pair

**Create key:**
```bash
gpg --gen-key
```

**Interactive prompts:**
```
Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (9) ECC and ECC
  (10) ECC (sign only)
  (14) Existing key from card

Your selection? 1

What keysize do you want? (3072) 4096

Key is valid for? (0) 0

Is this correct? (y/N) y

Real name: Your Name
Email address: you@example.com
Comment: Repository signing key

Change (N)ame, (E)mail, (C)omment or (O)kay/(Q)uit? O
```

**Verify key creation:**
```bash
gpg --list-keys
```

**Output:**
```
pub   rsa4096 2025-11-01 [SC]
      ABCD1234ABCD1234ABCD1234ABCD1234
uid           [ultimate] Your Name <you@example.com>
sub   rsa4096 2025-11-01 [E]
```

#### Export Public Key

**ASCII-armored format:**
```bash
gpg --armor --export you@example.com > my-public-key.asc
```

**Binary format:**
```bash
gpg --export you@example.com > my-public-key.gpg
```

**Distribute public key:**
```bash
# Copy to repository
cp my-public-key.asc ~/arch-repo/

# Or publish to keyserver
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```

### Signing Packages

#### Sign Individual Package

**Create detached signature:**
```bash
cd ~/arch-repo
gpg --detach-sign --armor package-name-1.0-1-x86_64.pkg.tar.zst
```

**Creates `package-name-1.0-1-x86_64.pkg.tar.zst.asc`**

**Verify signature exists:**
```bash
ls -la package-name-*.asc
```

#### Sign All Packages

**Create script:**
```bash
#!/bin/bash
# sign-packages.sh - Sign all packages in directory

cd ~/arch-repo

for pkg in *.pkg.tar.zst; do
    if [ ! -f "$pkg.asc" ]; then
        echo "Signing $pkg..."
        gpg --detach-sign --armor "$pkg"
    else
        echo "Already signed: $pkg"
    fi
done

echo "Done"
```

**Usage:**
```bash
chmod +x sign-packages.sh
./sign-packages.sh
```

#### Sign Repository Database

**Sign database files:**
```bash
cd ~/arch-repo
gpg --detach-sign --armor myrepo.db.tar.gz
gpg --detach-sign --armor myrepo.files.tar.gz
```

**Automated during repo-add:**
```bash
cd ~/arch-repo

# Sign immediately after repo-add
repo-add myrepo.db.tar.gz *.pkg.tar.zst
gpg --detach-sign --armor myrepo.db.tar.gz
gpg --detach-sign --armor myrepo.files.tar.gz
```

### Configuring Signed Repository

#### Update Pacman Configuration

**Edit `/etc/pacman.conf`:**
```bash
sudo nano /etc/pacman.conf
```

**Add signed repository:**
```ini
[myrepo]
SigLevel = Required
Server = file:///home/username/arch-repo
```

**SigLevel options:**
- `Never` - Don't verify signatures
- `Optional` - Verify if signature exists, don't require
- `Required` - Require valid signatures for all packages
- `TrustAll` - Trust without verification (not recommended)

#### Import Signer's Key

**Import public key from file:**
```bash
gpg --import /path/to/public-key.asc
```

**Import from keyserver:**
```bash
gpg --keyserver keyserver.ubuntu.com --recv-keys KEY_ID
```

**List imported keys:**
```bash
gpg --list-keys
```

#### Trust the Key

**Mark key as trusted:**
```bash
gpg --edit-key your-key-id
```

**In the editor:**
```
gpg> trust

Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5

Do you really want to set this key to ultimately trusted? (y/N) y

gpg> quit
```

### Organization-Wide Signing

#### Shared Key Setup

**Create organization key:**
```bash
gpg --gen-key
# Email: packages@organization.com
```

**Export for distribution:**
```bash
gpg --armor --export packages@organization.com > org-packages.asc
```

**All repository maintainers use this key:**
```bash
# Import shared key
gpg --import org-packages.asc

# Configure trust
gpg --edit-key packages@organization.com
# Trust as described above
```

#### Shared Private Key (Secure Distribution)

**Export private key (careful!):**
```bash
gpg --armor --export-secret-keys packages@organization.com > org-packages-private.asc
```

**Distribute securely:**
```bash
# Encrypt the private key
gpg --symmetric --armor --output org-packages-private.gpg.asc org-packages-private.asc

# Share encrypted file and password separately
```

**Import on other systems:**
```bash
gpg --import org-packages-private.asc
```

### Signing Workflow

#### Complete Signing Script

```bash
#!/bin/bash
# /usr/local/bin/sign-repo
# Complete repository signing workflow

REPO_DIR="$HOME/arch-repo"
REPO_NAME="myrepo"
KEY_ID="your-key-id"

error() {
    echo "Error: $1" >&2
    exit 1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

main() {
    log "Starting repository signing process"
    
    cd "$REPO_DIR" || error "Repository directory not found"
    
    # Sign all unsigned packages
    log "Signing packages..."
    unsigned_count=0
    
    for pkg in *.pkg.tar.zst; do
        if [ ! -f "$pkg.asc" ]; then
            log "Signing: $pkg"
            
            if gpg --detach-sign --armor --default-key "$KEY_ID" "$pkg"; then
                ((unsigned_count++))
            else
                error "Failed to sign $pkg"
            fi
        fi
    done
    
    if [ $unsigned_count -gt 0 ]; then
        log "Signed $unsigned_count packages"
    else
        log "All packages already signed"
    fi
    
    # Rebuild and sign database
    log "Updating repository database..."
    repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst
    
    # Sign database files
    log "Signing database..."
    
    for file in "$REPO_NAME.db.tar.gz" "$REPO_NAME.files.tar.gz"; do
        if [ -f "$file" ]; then
            rm -f "$file.asc"
            
            if gpg --detach-sign --armor --default-key "$KEY_ID" "$file"; then
                log "Signed: $file"
            else
                error "Failed to sign $file"
            fi
        fi
    done
    
    # Verify all signatures
    log "Verifying signatures..."
    
    verify_count=0
    for sig in *.asc; do
        if gpg --verify "$sig" &>/dev/null; then
            ((verify_count++))
        else
            error "Signature verification failed: $sig"
        fi
    done
    
    log "Verified $verify_count signatures"
    
    log "Repository signing complete"
}

main "$@"
```

**Usage:**
```bash
chmod +x /usr/local/bin/sign-repo
sign-repo
```

### Client-Side Verification

#### Manual Signature Verification

**Verify package signature:**
```bash
gpg --verify package-name-1.0-1-x86_64.pkg.tar.zst.asc package-name-1.0-1-x86_64.pkg.tar.zst
```

**Output indicates:**
```
gpg: Signature made Wed Nov  1 10:00:00 2025 CST
gpg:                using RSA key ABCD1234ABCD1234
gpg: Good signature from "Your Name <you@example.com>"
```

#### Automatic Verification

**Pacman automatically verifies when:**
- Repository has `SigLevel = Required`
- Public key is imported and trusted
- Signature file exists alongside package

**Check verification:**
```bash
pacman -S myrepo/signed-package
# No signature errors means verification succeeded
```

### Troubleshooting

#### Signature Verification Failures

**Error:**
```
error: failed to verify the trust on imported keys
```

**Solution:**
```bash
# Import and trust the key
gpg --import public-key.asc
gpg --edit-key key-id
# Type: trust, then select 5 (ultimate)
```

#### Key Expiration

**Check key expiration:**
```bash
gpg --list-keys
```

**Extend expiration:**
```bash
gpg --edit-key your-key-id

gpg> expire
# Follow prompts to set new expiration

gpg> save
```

**Re-export and redistribute:**
```bash
gpg --armor --export you@example.com > updated-public-key.asc
```

#### Multiple Signers

**Repository signed by multiple keys:**
```ini
[multi-signed-repo]
SigLevel = Required
Server = file:///path/to/repo
```

**Import all signer keys:**
```bash
gpg --import signer1.asc
gpg --import signer2.asc
gpg --import signer3.asc
```

**Trust each one:**
```bash
gpg --edit-key signer1-id
# trust -> 5
gpg --edit-key signer2-id
# trust -> 5
```

### Best Practices

**Key security:**
- Protect private key with strong passphrase
- Store backup in secure location
- Never share private key
- Use separate key for repositories if possible

**Signature management:**
- Sign all packages in repository
- Sign database files
- Verify signatures before distribution
- Document signing process

**Distribution:**
- Distribute public key securely
- Use multiple distribution methods
- Include fingerprint for verification
- Document key ID and expiration

**Automation:**
- Automate signing process
- Include in build pipelines
- Verify before uploading
- Log all signing operations

**Maintenance:**
- Rotate keys periodically
- Archive old signatures
- Monitor key expiration
- Update trust settings as needed

### Advanced: Web of Trust

#### Build Trust Network

**Sign other keys:**
```bash
gpg --sign-key other-developers-key
```

**This creates web of trust where multiple developers verify each other.**

#### Distributed Repository Signing

**Multiple maintainers sign same repository:**
```bash
# Maintainer 1
gpg --detach-sign --armor --default-key maintainer1@org myrepo.db.tar.gz

# Maintainer 2  
gpg --detach-sign --armor --default-key maintainer2@org myrepo.db.tar.gz

# Store multiple signatures
mv myrepo.db.tar.gz.asc myrepo.db.tar.gz.asc.maintainer1
```

**Clients verify with any signature:**
```bash
gpg --verify myrepo.db.tar.gz.asc.maintainer1 myrepo.db.tar.gz
```

Repository signing provides cryptographic assurance that packages and repositories haven't been tampered with and come from trusted sources, essential for security in multi-system environments.

