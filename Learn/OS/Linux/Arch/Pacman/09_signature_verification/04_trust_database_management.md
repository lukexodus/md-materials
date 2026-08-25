## Trust Database Management


### Overview

The trust database in pacman's keyring system maintains information about the trustworthiness and validity of GPG keys used for package signature verification. It's stored in `/etc/pacman.d/gnupg/trustdb.gpg` and manages the web of trust relationships between keys.

### Trust Database Operations

#### Update Trust Database

Refresh the trust database using GnuPG's check-trustdb functionality:

```
sudo pacman-key --updatedb
```

Or using the short form:
```
sudo pacman-key -u
```

This operation updates trust relationships and validates the integrity of the trust database. It can be combined with other pacman-key operations to ensure the trust database is current after key modifications.

#### Import Trust Database

Import ownertrust values from `trustdb.gpg` files in specified directories:

```
sudo pacman-key --import-trustdb /path/to/directory
```

This is useful when restoring keyring backups or migrating trust relationships from another system. The specified directory should contain a valid `trustdb.gpg` file.

### Trust Levels in GPG

The GPG web of trust uses several trust levels:

**Unknown:** No trust information available for this key

**Never:** Explicitly marked as not to be trusted

**Marginal:** Some trust, but signatures from this key alone aren't sufficient

**Full:** Complete trust in this key's ability to verify other keys

**Ultimate:** Your own key or keys you absolutely trust (Master Signing Keys)

### Local Signing and Trust

#### Establishing Trust Through Local Signing

When you locally sign a key with `pacman-key --lsign-key`, you're establishing trust:

```
sudo pacman-key --lsign-key keyid
```

This operation modifies the trust database to indicate that you trust this key to sign packages. Local signatures are non-exportable and exist only in your keyring.

#### Editing Key Trust Levels

Interactively adjust a key's trust level:

```
sudo pacman-key --edit-key keyid
```

This presents a GPG menu where you can:
- Set trust levels for keys
- Add or remove signatures
- Manage key attributes
- Update key expiration dates

Within the menu, use the `trust` command to adjust trust levels, then save changes with `save` and exit with `quit`.

### Web of Trust Model in Arch Linux

Arch Linux uses a hierarchical trust model:

**Master Signing Keys:** At the top of the trust hierarchy, these keys are given ultimate trust during `pacman-key --populate archlinux`. They co-sign all official developer keys.

**Developer Keys:** Signed by Master Keys, these keys are automatically trusted through the chain of trust. Developer keys sign individual packages.

**Custom Keys:** For unofficial repositories or AUR packages, you manually establish trust by locally signing the key after verifying its fingerprint.

### Trust Database Maintenance

#### Verify Trust Relationships

Check the trust database for consistency:

```
sudo pacman-key --updatedb
```

This recalculates trust relationships and ensures the database is consistent with the current keyring state.

#### Rebuild After Keyring Issues

If trust database corruption occurs, the keyring can be completely rebuilt:

```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```

This removes the entire keyring directory (including the trust database) and recreates it from scratch. All custom keys and trust relationships must be re-established.

### Trust Database and Signature Verification

The trust database determines whether pacman accepts a package signature:

**Package verification flow:**
1. Pacman encounters a signed package
2. Extracts the signature and signing key ID
3. Checks if the signing key exists in the keyring
4. Queries the trust database to verify the key is trusted
5. If trusted, validates the cryptographic signature
6. Installs package only if all checks pass

**SigLevel configuration** in `/etc/pacman.conf` works in conjunction with the trust database:

```
SigLevel = Required TrustedOnly
```

`TrustedOnly` means pacman consults the trust database and only accepts signatures from trusted keys.

### Common Trust Database Issues

#### Trust Calculation Errors

**Symptom:** Messages about trust calculation failures or marginal trust

**Solution:** Update the trust database and refresh keys:
```
sudo pacman-key --updatedb
sudo pacman-key --refresh-keys
```

#### Missing Trust for Valid Keys

**Symptom:** Packages fail verification despite having the signing key

**Solution:** Locally sign the key to establish trust:
```
sudo pacman-key --finger keyid    # Verify fingerprint
sudo pacman-key --lsign-key keyid
```

#### Expired Keys in Trust Database

**Symptom:** Previously working keys suddenly fail verification

**Solution:** Refresh keys to update expiration information:
```
sudo pacman-key --refresh-keys
```

Or update the archlinux-keyring package:
```
sudo pacman -Sy archlinux-keyring
```

### Direct GPG Access for Advanced Management

For operations beyond pacman-key's scope, access the trust database directly with GnuPG:

```
sudo gpg --homedir /etc/pacman.d/gnupg --check-trustdb
sudo gpg --homedir /etc/pacman.d/gnupg --list-keys --with-colons
sudo gpg --homedir /etc/pacman.d/gnupg --edit-key keyid
```

The `--with-colons` option provides machine-readable output showing trust levels and validity information for each key.

### Best Practices

**Regular updates:** Keep the trust database current by regularly updating the archlinux-keyring package.

**Verify before trusting:** Always verify key fingerprints through independent channels before locally signing keys.

**Minimal custom trust:** Only establish trust relationships for keys you genuinely need and have verified.

**Backup keyring:** Include `/etc/pacman.d/gnupg/` in system backups to preserve trust relationships.

**Monitor expiration:** Periodically refresh keys to catch expiration and revocation updates.

**Don't bypass trust:** Avoid using `SigLevel = TrustAll` in production; it defeats the purpose of the trust database.

**Document custom keys:** Maintain records of why you've trusted specific non-official keys.

The trust database is fundamental to pacman's security model, ensuring that only packages signed by verified, trusted keys are installed on your system


