## Package Signature Checking


### Overview of Package Signing

Pacman uses OpenPGP keys in a web of trust model to verify that packages are authentic. Each package distributed through Arch Linux repositories is cryptographically signed by package maintainers, and these signatures are verified during installation.[1][4][5]

### How Signature Verification Works

#### Verification Process

When installing packages, pacman performs the following steps:[2][4][5]

1. **Download phase:** Package and its signature file (`.sig`) are downloaded
2. **Signature checking:** Pacman verifies the GPG signature against known trusted keys[4]
3. **Key validation:** Ensures the signing key is trusted through the web of trust[1]
4. **Installation:** Package is installed only if signature verification succeeds[5]

**Installation output shows:**
```
(1/1) checking keys in keyring
(x/100) checking package integrity
```


The "checking package integrity" phase verifies all `.sig` files with GPG, which can take significant time for large package sets (30-40% of total installation time).[2]

### SigLevel Configuration

#### Understanding SigLevel

The `SigLevel` option in `/etc/pacman.conf` determines the trust level required to install packages. This can be configured globally in the `[options]` section or per-repository.[7][5][1]

#### Default Configuration

**Standard secure configuration:**
```
# /etc/pacman.conf
[options]
SigLevel = Required DatabaseOptional
```


**Breakdown:**
- `Required` - Package signatures are mandatory[1]
- `DatabaseOptional` - Repository databases don't require signatures (work in progress)[1]
- `TrustedOnly` - Implied default, only trusts verified keys[1]

#### Repository-Specific Settings

Configure signature checking per repository:[5][1]

```
[core]
SigLevel = PackageRequired
Include = /etc/pacman.d/mirrorlist

[extra]
SigLevel = PackageRequired
Include = /etc/pacman.d/mirrorlist
```


Repository-specific `SigLevel` settings override global settings.[1]

### SigLevel Options

#### Trust Levels

**Required:** Signatures are mandatory; unsigned packages will be rejected[1]

**Optional:** Signatures are checked if present but not required[1]

**Never:** Signature checking is completely disabled[7][1]

**TrustedOnly:** Only keys in the web of trust are accepted (default)[1]

**TrustAll:** Accept any signature, even from unverified keys (debugging only)[7][1]

#### Scope Modifiers

**Package:** Applies to package files[1]

**Database:** Applies to repository databases[1]

**Combined examples:**
```
SigLevel = PackageRequired DatabaseOptional
SigLevel = PackageOptional
SigLevel = Required TrustedOnly
```


### Local vs Remote Packages

#### LocalFileSigLevel

The `LocalFileSigLevel` setting controls signature requirements for locally installed packages (`pacman -U`):[5][1]

```
LocalFileSigLevel = Optional
```


This allows installing self-built packages without signing them with makepkg.[1]

#### RemoteFileSigLevel

Controls requirements for packages from remote repositories:

```
RemoteFileSigLevel = Required
```


### Web of Trust Model

#### Trust Chain Structure

Pacman's trust model follows a hierarchical chain:[1]

**Official packages:**
1. Developer signs package with their key
2. Developer's key is signed by Arch Linux Master Signing Keys
3. User locally signs the Master Signing Keys
4. Trust flows: User → Master Keys → Developer Keys → Packages[1]

**Unofficial packages:**
1. Developer signs package
2. User locally signs developer's key directly
3. Trust flows: User → Developer Key → Packages[1]

**Custom packages:**
1. User signs package with their own key
2. Direct trust relationship[1]

### Signature Verification Errors

#### Common Error Messages

**Unknown trust error:**
```
error: package_name: signature from "user@archlinux.org" is unknown trust
error: failed to commit transaction (invalid or corrupted package)
```


**Invalid signature error:**
```
error: package_name: signature from "..." is invalid
error: failed to commit transaction (invalid or corrupted package (PGP signature))
```


#### Primary Causes

**Outdated keyring:** The `archlinux-keyring` package needs updating[3][6]

**Uninitialized keyring:** Keys haven't been properly initialized[3]

**System time incorrect:** GPG signatures have time validity; wrong system time causes failures[1]

**Corrupted cache:** Cached packages may have invalid signatures[1]

**Missing keys:** Required signing keys not imported[3]

### Troubleshooting Signature Verification

#### Update Keyring First

Before full system upgrade, update the keyring package:[3][1]

```
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```


This ensures the latest keys are available before verifying other packages.[1]

#### Initialize and Populate Keyring

If the keyring is uninitialized or corrupted:[5][3]

```
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


This creates the keyring directory structure and imports Arch Linux master and developer keys.[5][3]

#### Reset Keyring Completely

For persistent issues, remove and rebuild the keyring:[1]

```
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


**Warning:** This removes all custom keys; you'll need to re-add third-party repository keys.[1]

#### Clear Package Cache

Remove potentially corrupted cached packages:[1]

```
sudo pacman -Scc
```


This forces fresh downloads with valid signatures.[1]

#### Correct System Time

Verify and correct system time if necessary:[1]

```
timedatectl status
sudo ntpd -qg
sudo hwclock -w
```


Incorrect system time causes signature validation failures because signatures have time validity periods.[1]

### Temporary Workarounds

#### Emergency Installation with TrustAll

**Warning:** Use only in emergencies; this is insecure.[7]

Temporarily accept all signatures to install critical packages:

```
# Edit /etc/pacman.conf
SigLevel = TrustAll
```


Install the keyring package:
```
sudo pacman -S archlinux-keyring
```


**Then immediately revert:**
```
# Edit /etc/pacman.conf
SigLevel = Required DatabaseOptional
```


#### Disable Signature Checking

**Warning:** Extremely dangerous; only use for debugging.[1]

```
# /etc/pacman.conf
[options]
SigLevel = Never
#LocalFileSigLevel = Optional
#RemoteFileSigLevel = Required
```


This disables all signature verification, allowing installation of untrusted packages. Comment out any repository-specific `SigLevel` settings as they override global settings.[1]

### Performance Optimization

#### Parallelized Verification

Signature verification is single-threaded by default, consuming 30-40% of installation time. While pacman doesn't natively support parallel verification, advanced users can implement custom parallel verification scripts using GNU parallel to verify multiple `.sig` files simultaneously.[2]

**Note:** This requires advanced scripting and is not officially supported.[2]

### Best Practices

**Always verify signatures:** Keep signature checking enabled for security.[5][1]

**Regular updates:** Update the system regularly to keep keys current.[1]

**Initialize properly:** Ensure keyring is initialized during system setup.[3][5]

**Verify master keys:** Confirm master key fingerprints when prompted during `pacman-key --populate`.[1]

**Don't use TrustAll in production:** Only use for emergency recovery, never permanently.[7][1]

**Update keyring separately:** Before major upgrades, update `archlinux-keyring` first.[1]

**Check system time:** Ensure accurate system time for signature validity.[1]

**Keep logs:** If signature errors occur, check `/var/log/pacman.log` for details.

Sources
[1] pacman/Package signing - ArchWiki https://wiki.archlinux.org/title/Pacman/Package_signing
[2] pacman is 30% faster with parallelized signature verification https://www.reddit.com/r/archlinux/comments/19b8yn4/pacman_is_30_faster_with_parallelized_signature/
[3] Signature Verification Error while trying to install pacman ... https://bbs.archlinux.org/viewtopic.php?id=301379
[4] ELI5: Does pacman -S automatically verify package integrity? https://www.reddit.com/r/archlinux/comments/69n2ty/eli5_does_pacman_s_automatically_verify_package/
[5] Verify all the packages - Pierre Schmitz https://pierre-schmitz.com/verify-all-the-packages/
[6] Arch Linux upgrade problems - It's FOSS Community https://itsfoss.community/t/arch-linux-upgrade-problems/11710
[7] can't install pacman packages because of unknown trust https://steamcommunity.com/app/1675200/discussions/0/7529517132619672170/

