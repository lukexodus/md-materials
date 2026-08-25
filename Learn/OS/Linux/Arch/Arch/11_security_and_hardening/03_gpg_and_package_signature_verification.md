## GPG and Package Signature Verification


### GPG Overview

**Purpose**: GNU Privacy Guard provides encryption, signing, and authentication .

**Functions** :
- Create cryptographic signatures 
- Verify authenticity 
- Encrypt/decrypt data 
- Manage keys 

**Installation**: Usually pre-installed .

**Verification**: `gpg --version` .

### Key Generation

#### Generate Your Key Pair

**Command** :

```bash
gpg --gen-key
```

or modern method :

```bash
gpg --full-gen-key
```

**Prompts** :
- Key type (RSA recommended) 
- Key size (4096-bit recommended) 
- Validity period 
- Name and email 
- Passphrase 

**Example** :

```
Key type: RSA and RSA (default)
Key size: 4096
Valid for: 0 (no expiry)
Name: John Doe
Email: john@example.com
Passphrase: [secure password]
```

#### Check Generated Keys

**List Keys** :

```bash
gpg --list-keys
```

**Output** :

```
pub   rsa4096 2025-01-01 [SC]
      ABCD1234567890...
uid           [ultimate] John Doe <john@example.com>
sub   rsa4096 2025-01-01 [E]
```

**Key ID**: Last 16 characters of fingerprint .

### Key Management

#### Export Public Key

**ASCII Format** :

```bash
gpg --export -a john@example.com > public-key.asc
```

**Binary Format** :

```bash
gpg --export john@example.com > public-key.gpg
```

**Upload to Server** :

```bash
gpg --send-keys KEYID --keyserver keyserver.ubuntu.com
```

#### Import Public Key

**From File** :

```bash
gpg --import public-key.asc
```

**From Keyserver** :

```bash
gpg --recv-keys KEYID --keyserver keyserver.ubuntu.com
```

#### Trust Levels

**Edit Key** :

```bash
gpg --edit-key john@example.com
```

**Commands** :
- `trust`: Set trust level 
- `sign`: Sign key 
- `quit`: Exit 

**Trust Levels** :
- `1`: Unknown 
- `2`: Not trusted 
- `3`: Marginally trusted 
- `4`: Fully trusted 
- `5`: Ultimate (own key) 

#### Sign a Key

**Verify Identity**: Then sign :

```bash
gpg --sign-key john@example.com
```

**Confirms**: You trust this person's identity .

### Signing Files

#### Create Signature

**Detached Signature** (separate file) :

```bash
gpg --detach-sign --armor document.txt
```

**Creates**: `document.txt.asc` .

**Embedded Signature** (within file) :

```bash
gpg --sign --armor document.txt
```

**Creates**: `document.txt.asc` .

#### Sign Multiple Files

**Batch Signing** :

```bash
for file in *.txt; do
    gpg --detach-sign --armor "$file"
done
```

### Verifying Signatures

#### Verify File

**Check Signature** :

```bash
gpg --verify document.txt.asc
```

**Output** :

```
gpg: Signature made Mon 01 Jan 2024 12:00:00 UTC
gpg: Good signature from "John Doe <john@example.com>"
```

**Bad Signature** :

```
gpg: BAD signature from "John Doe <john@example.com>"
```

**Unknown Signer** :

```
gpg: WARNING: This key is not certified with a trusted signature
```

#### Verify Specific Key

**Trust Before Verifying** :

1. Import public key 
2. Verify fingerprint independently 
3. Trust the key 
4. Verify signature 

**Check Fingerprint** :

```bash
gpg --fingerprint john@example.com
```

### Arch Package Signatures

#### Package Signing

**Arch Maintainer Signs** :

Each official package is signed .

**Signature in Database** :

Signatures stored with packages .

#### Verify Package

**Check Package** :

```bash
pacman -Qi package_name
```

**Shows**: Signature status .

**Manual Verification** :

```bash
pacman -Qii package_name
```

**Detailed Info**: Including signature date .

#### Signing Configuration

**In PKGBUILD** :

```bash
validpgpkeys=('KEYID1' 'KEYID2')
```

**Specifies**: Accepted signing keys .

#### Pacman Database Signatures

**Verify Database** :

```bash
sudo pacman -Sy
```

**Automatic Verification**: pacman checks signatures .

**Configuration**: `/etc/pacman.conf` :

```ini
SigLevel = Required DatabaseOptional
```

### Keyring Management

#### System Keyring

**Location**: `/etc/pacman.d/gnupg/` .

**Contains**: Trusted package signing keys .

#### Refresh Keys

**Update Keyring** :

```bash
sudo pacman-key --refresh-keys
```

**Downloads**: Latest key information .

#### Initialize Keyring

**Fresh Start** :

```bash
sudo pacman-key --init
```

**Generate new keyring** .

#### Key Ring Status

**Check Status** :

```bash
sudo pacman-key --list-sigs
```

**Shows**: All trusted keys .

#### Populate Keyring

**On Fresh Install** :

```bash
sudo pacman -S archlinux-keyring
sudo pacman -S gnupg
```

**Adds**: Arch Linux developer keys .

### Encrypting with GPG

#### Encrypt File

**Public Key Encryption** :

```bash
gpg --encrypt --recipient john@example.com document.txt
```

**Creates**: `document.txt.gpg` .

**ASCII Output** :

```bash
gpg --encrypt --armor --recipient john@example.com document.txt
```

#### Decrypt File

**Decrypt** :

```bash
gpg --decrypt document.txt.gpg > document.txt
```

**Prompts for Passphrase** .

### GPG Agent

#### Purpose

**Passphrase Caching**: Avoids repeated password entry .

**SSH Support**: Can act as SSH agent .

#### Start GPG Agent

**Usually Automatic** :

Started by desktop environment .

**Manual Start** :

```bash
eval $(gpg-agent --daemon)
```

#### Agent Configuration

**Config File**: `~/.gnupg/gpg-agent.conf` :

```
default-cache-ttl 600
max-cache-ttl 7200
pinentry-program /usr/bin/pinentry
```

**Parameters** :
- `default-cache-ttl`: Cache duration 
- `max-cache-ttl`: Maximum cache 
- `pinentry-program`: Password prompt 

### AUR Package Verification

#### Check PKGBUILD Signature

**Before Building** :

```bash
cd aur-package
gpg --verify .SRCINFO.asc .SRCINFO 2>&1
```

**Should Show**: Valid signature .

#### Verify Source Signature

**In PKGBUILD** :

```bash
validpgpkeys=('DEADBEEF')
source=("https://example.com/package.tar.gz.sig"
        "https://example.com/package.tar.gz")
```

**Verification**: Automatic during `makepkg` .

### Best Practices

**Use Strong Keys**: 4096-bit RSA minimum .

**Protect Passphrase**: Store securely .

**Backup Keys**: Export and store safely :

```bash
gpg --export-secret-keys -a keyid > private-key.asc
```

**Verify Independently**: Check fingerprints outside GPG .

**Trust Carefully**: Only sign keys you've verified .

**Audit Signatures**: Review who has signed your key .

**Keep Software Updated**: Update GPG and keys .

**Review Package Signatures**: Always check before installing AUR packages .

### Troubleshooting

#### Cannot Find Key

**Error**: "Cannot find key" .

**Solution** :

```bash
gpg --recv-keys KEYID --keyserver keyserver.ubuntu.com
```

#### Signature Verification Fails

**Issue**: Bad or missing signature .

**Check** :
1. Key imported 
2. Key trusted 
3. File not modified 

#### Passphrase Not Cached

**Agent Not Running** :

```bash
gpg-agent --daemon
```

**Check Agent** :

```bash
echo $GPG_AGENT_INFO
```

#### Key Expired

**Check Expiry** :

```bash
gpg --list-keys
```

**Extend Expiry** :

```bash
gpg --edit-key keyid
# expire
# [set new expiry]
# save
```

### Advanced GPG Usage

#### Sign Commit

**Git Configuration** :

```bash
git config user.signingkey KEYID
```

**Sign Commit** :

```bash
git commit -S -m "Signed commit"
```

#### Trust Model

**Export Ownertrust** :

```bash
gpg --export-ownertrust > ownertrust.txt
```

**Import Ownertrust** :

```bash
gpg --import-ownertrust ownertrust.txt
```

#### Automated Verification

**Batch Verify** :

```bash
for file in *.asc; do
    gpg --verify "$file" || echo "FAILED: $file"
done
```

This comprehensive guide on GPG and package signature verification completes the Arch Linux system administration documentation, providing users with essential knowledge for securing packages, verifying authenticity, and managing cryptographic operations within the Arch ecosystem.

