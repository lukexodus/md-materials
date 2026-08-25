## GPG Key Management


### Overview of Pacman's Keyring System

Pacman uses OpenPGP keys in a web of trust model to verify that packages are authentic. The `pacman-key` utility is a wrapper script for GnuPG that manages pacman's keyring—the collection of PGP keys used to check signed packages and databases.[1][2][3]

The keyring is stored by default in `/etc/pacman.d/gnupg/`.[2][3][4]

### Initial Keyring Setup

#### Initialize the Keyring

Initialize pacman's keyring before first use:[3][1][2]

```
sudo pacman-key --init
```


This creates necessary GnuPG directories and files, ensuring the keyring is properly initialized with required access permissions.[2][3]

#### Populate with Master Keys

Populate the keyring with official Arch Linux master keys and developer keys:[3][1][2]

```
sudo pacman-key --populate archlinux
```


**Important:** Take time to verify the Master Signing Keys when prompted, as these are used to co-sign (and therefore trust) all other packager keys.[1]

**Complete initial setup:**
```
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


### Verifying Master Keys

OpenPGP keys are too large (2048+ bits) for humans to verify directly, so they are hashed to create a 40-hex-digit fingerprint. The last eight digits serve as the "short key ID," while the last sixteen digits form the "long key ID".[1]

**Display key fingerprints:**
```
pacman-key --finger keyid
```


Compare displayed fingerprints against official sources to verify authenticity.[1]

### Managing Developer Keys

#### Automatic Key Downloads

Official Arch Linux developer and package maintainer keys are signed by master keys, so they don't need manual signing. When pacman encounters an unrecognized key, it prompts to download it from a keyserver configured in `/etc/pacman.d/gnupg/gpg.conf`.[1]

Once downloaded, developer keys can verify all packages signed by that developer without re-downloading.[1]

#### Refreshing Keys

Update existing keys from keyservers:[2][3][1]

```
sudo pacman-key --refresh-keys
```


This updates key information and trust status from remote keyservers. Your local key will also be queried, and receiving a "not found" message is normal and not concerning.[1]

**Note:** The `archlinux-keyring` package (a dependency of `base`) contains the latest keys. Keys can be updated either by upgrading this package or manually refreshing them.[1]

### Adding Unofficial Keys

For custom repositories or AUR packages with signatures, add third-party keys:[1]

#### Import Key from Keyserver

If the key is available on a keyserver:[1]

```
sudo pacman-key --recv-keys keyid
```


#### Import Key from File

If provided with a keyfile download:[1]

```
sudo pacman-key --add /path/to/downloaded/keyfile
```


#### Verify Key Fingerprint

Always verify the fingerprint before trusting:[1]

```
pacman-key --finger keyid
```


Compare the fingerprint against the one provided by the key owner through a trusted channel.[1]

#### Locally Sign the Key

Finally, locally sign the imported key to trust it:[1]

```
sudo pacman-key --lsign-key keyid
```


This indicates you trust this key to sign packages.[1]

### Listing and Exporting Keys

#### List All Keys

Display all keys in the keyring:[3][2]

```
pacman-key --list-keys
```


Or list specific keys:
```
pacman-key --list-keys keyid
```

#### Export Keys

Export keys to stdout or a file:[3][2]

```
pacman-key --export keyid
```


Export all keys:
```
pacman-key --export
```


#### Display Fingerprints

Show fingerprints for all or specific keys:[3][2]

```
pacman-key --finger
pacman-key --finger keyid
```


### Removing Keys

Delete specific keys from the keyring:[3][2]

```
sudo pacman-key --delete keyid
```


### Troubleshooting Keyring Issues

#### Common Problems

Keyring issues typically arise from:[5][1]
- Outdated `archlinux-keyring` package[5][1]
- Incorrect system clock/date[1]
- ISP blocking keyserver ports[1]
- Cached unsigned packages from previous attempts[1]
- Improperly configured `dirmngr`[1]

#### Signature Verification Errors

**Error messages:**
```
error: package: signature from "..." is unknown trust
error: failed to commit transaction (invalid or corrupted package)
```


**Primary solution - Update archlinux-keyring:**
```
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```


This updates the keyring before performing a full system upgrade.[6][7]

#### Complete Keyring Reset

When standard fixes fail, completely regenerate the keyring:[8][9]

```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


**Warning:** This deletes all custom keys. You'll need to re-add any third-party repository keys.[8]

#### Change Keyserver

If the default keyserver is unreachable, switch to an alternative:[1]

Edit `/etc/pacman.d/gnupg/gpg.conf`:
```
keyserver hkp://keyserver.ubuntu.com
```


Or use the command-line option:
```
sudo pacman-key --keyserver keyserver.ubuntu.com --recv-keys keyid
```


#### Clean Package Cache

If cached packages contain invalid signatures:[1]

```
sudo pacman -Scc
```


This removes all cached packages, forcing fresh downloads with valid signatures.[1]

#### Verify System Time

Incorrect system time causes signature verification failures:[1]

```
timedatectl status
```

Ensure the clock is set correctly. GPG signatures have validity periods that fail if the system time is wrong.[1]

### Upgrade System Regularly

Regular system upgrades prevent most signing errors. If extended delays are unavoidable, manually sync the database and upgrade `archlinux-keyring` before the full system upgrade:[1]

```
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```


### Direct GnuPG Access

For advanced debugging, access pacman's keyring directly with GnuPG:[1]

```
sudo gpg --homedir /etc/pacman.d/gnupg --list-keys
```


This provides lower-level keyring management capabilities for complex scenarios.[2][1]

### Key Trust Levels

#### Edit Key Trust

Adjust a key's trust level interactively:[2]

```
sudo pacman-key --edit-key keyid
```


This presents a menu for key management tasks, including setting trust levels.[2]

### Security Best Practices

**Verify fingerprints:** Always verify key fingerprints before signing or trusting them.[1]

**Keep keyring updated:** Regularly update `archlinux-keyring` to receive new keys and revocations.[1]

**Use trusted sources:** Only add keys from verified, trustworthy sources.[3]

**Don't disable signatures:** Avoid using `SigLevel = Never` in production—it bypasses all security checks.[6]

**Regular upgrades:** Keep your system updated to prevent keyring inconsistencies.[1]

**Verify master keys:** Take time to verify Arch Linux master signing keys during initial setup.[1]

**Network connectivity required:** Key refresh and receipt operations require internet access.[3]

**Root privileges needed:** Most keyring operations require root access.[3]

Sources
[1] pacman/Package signing - ArchWiki https://wiki.archlinux.org/title/Pacman/Package_signing
[2] pacman-key(8) https://pacman.archlinux.page/pacman-key.8.html
[3] pacman-key man | Linux Command Library https://linuxcommandlibrary.com/man/pacman-key
[4] Two PGP Keyrings for Package Management in Arch Linux http://allanmcrae.com/2015/01/two-pgp-keyrings-for-package-management-in-arch-linux/
[5] Pacman won't let me install anything because of broken pgp keys. https://www.reddit.com/r/archlinux/comments/z9wb5u/pacman_wont_let_me_install_anything_because_of/
[6] Error: archlinux-keyring: signature from is unknown trust https://forum.manjaro.org/t/error-archlinux-keyring-signature-from-is-unknown-trust/166232
[7] Archlinux keyring fails to update - Manjaro Linux Forum https://forum.manjaro.org/t/archlinux-keyring-fails-to-update/164313
[8] pacman suddenly complains about keyring - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=290769
[9] Help with keyring issue - Pacman & AUR helpers - EndeavourOS https://forum.endeavouros.com/t/help-with-keyring-issue/54623
[10] GnuPG - ArchWiki https://wiki.archlinux.org/title/GnuPG

