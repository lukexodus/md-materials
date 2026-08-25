## Keyring Operations


### Overview

`pacman-key` is a wrapper script for GnuPG used to manage pacman's keyring, which is the collection of PGP keys used to check signed packages and databases. It provides the ability to import and export keys, fetch keys from keyservers, and update the key trust database.[2][4][5]

The default keyring location is `/etc/pacman.d/gnupg/`.[4][5][2]

### Initial Keyring Setup

#### Initialize Keyring

Ensure the keyring is properly initialized with required access permissions:[5][6][2]

```
sudo pacman-key --init
```


This creates necessary GnuPG directories and files. The initialization process is required before first using pacman with signature verification.[2][4][5]

#### Populate with Default Keys

Populate the keyring with official Arch Linux master keys and developer keys:[4][5][6][2]

```
sudo pacman-key --populate archlinux
```


This adds the default set of trusted Arch Linux keys to the keyring. Take time to verify the Master Signing Keys when prompted, as these are used to co-sign all other packager keys.[1][9][5][4]

**Complete initial setup:**
```
sudo pacman-key --init
sudo pacman-key --populate archlinux
```


### Listing Keys

#### List All Keys

Display all keys in the public keyring:[6][2][4]

```
pacman-key --list-keys
```


Or using short form:
```
pacman-key -l
```


#### List Specific Keys

List particular keys by keyid:
```
pacman-key --list-keys keyid
```


#### List Keys with Signatures

Show keys along with their signatures:[2][4]

```
pacman-key --list-sigs
```


This provides the same information as `--list-keys` but includes signature details.[2][4]

### Displaying Key Fingerprints

#### Show Fingerprints

Display fingerprints for verification:[6][4][2]

```
pacman-key --finger
```


Or short form:
```
pacman-key -f
```


**For specific keys:**
```
pacman-key --finger keyid
```


Fingerprints should be verified against official sources before trusting keys.[1][4]

### Adding Keys

#### Add Key from File

Import keys from a local file:[6][2][4]

```
sudo pacman-key --add /path/to/keyfile.gpg
```


Or short form:
```
sudo pacman-key -a /path/to/keyfile.gpg
```


If a key already exists, this operation updates it.[4][2]

#### Receive Key from Keyserver

Download keys directly from a keyserver:[6][2][4]

```
sudo pacman-key --recv-keys keyid
```


Or short form:
```
sudo pacman-key -r keyid
```


**Example:**
```
sudo pacman-key --recv-keys "uid|name|email"
```


This retrieves the specified key from the configured keyserver and adds it to the keyring.[4][2]

#### Specify Custom Keyserver

Use an alternative keyserver for key operations:[5][2]

```
sudo pacman-key --keyserver keyserver.ubuntu.com --recv-keys keyid
```


### Signing Keys

#### Locally Sign Key

After importing a key, locally sign it to indicate trust:[8][6][2][4]

```
sudo pacman-key --lsign-key keyid
```


This operation is necessary to make the key valid. The key must already exist in the keyring (imported via `--add` or `--recv-keys`) before signing.[2][4]

**Local signing workflow:**
```
sudo pacman-key --recv-keys keyid
sudo pacman-key --finger keyid    # Verify fingerprint
sudo pacman-key --lsign-key keyid
```


### Refreshing Keys

#### Update Existing Keys

Refresh all keys from the configured keyserver to update their status:[5][4][2]

```
sudo pacman-key --refresh-keys
```


This updates information for keys already in your keyring but **does not add new keys**. It queries the keyserver and refreshes key data, including expiration dates and revocations.[3]

**Note:** Your local key will also be queried, and receiving a "not found" message is normal and not concerning.[1]

#### Difference: --refresh-keys vs archlinux-keyring

**pacman-key --refresh-keys:**
- Updates existing keys in your ring[3]
- Does not add new keys[3]
- Queries keyserver for updates[3]

**pacman -S archlinux-keyring:**
- Adds new keys if any have been added[3]
- Disables revoked keys[3]
- Does not rely on keyserver queries[3]
- Recommended approach for keeping keyring current[3]

### Editing Keys

#### Interactive Key Management

Present a menu for key management tasks:[4][2]

```
sudo pacman-key --edit-key keyid
```


This is useful for adjusting a key's trust level and performing other management operations.[4][2]

### Exporting Keys

#### Export Keys to stdout

Export public keys from the keyring:[2][4]

```
pacman-key --export keyid
```


Or short form:
```
pacman-key -e keyid
```


**Export all keys:**
```
pacman-key --export
```


If no keyid is specified, all keys are exported.[2][4]

**Save to file:**
```
pacman-key --export keyid > exported-key.gpg
```

### Deleting Keys

#### Remove Keys from Keyring

Delete specific keys identified by keyid:[6][4][2]

```
sudo pacman-key --delete keyid
```


Or short form:
```
sudo pacman-key -d keyid
```


### Importing Keys and Trust Database

#### Import Public Keyring

Import keys from `pubring.gpg` files in specified directories:[2][4]

```
sudo pacman-key --import /path/to/directory
```


#### Import Trust Database

Import ownertrust values from `trustdb.gpg` files:[2][4]

```
sudo pacman-key --import-trustdb /path/to/directory
```


### Updating Trust Database

#### Refresh Trust Database

Update the trust database using GnuPG's check-trustdb functionality:[2][4]

```
sudo pacman-key --updatedb
```


Or short form:
```
sudo pacman-key -u
```


This operation can be specified with other operations.[4][2]

### Verifying Signatures

#### Verify File Signatures

Verify cryptographic signatures on files using keys in the keyring:[5][2][4]

```
pacman-key --verify signature.sig file
```


Or short form:
```
pacman-key -v signature.sig file
```


**Detached signatures:**
With only one argument given, assume the signature is detached and look for a matching data file by stripping the file extension:[4]

```
pacman-key --verify package.pkg.tar.zst.sig
```


This automatically looks for `package.pkg.tar.zst`.[4]

### Additional Options

#### Version Information

Display version information:[2][4]

```
pacman-key --version
```


Or short form:
```
pacman-key -V
```


#### Help Information

Show syntax and command line options:[2][4]

```
pacman-key --help
```


Or short form:
```
pacman-key -h
```


#### Disable Colored Output

Disable colored terminal output:[5][4][2]

```
pacman-key --nocolor
```


#### Verbose Output

Increase output verbosity:[5]

```
pacman-key -v
```


#### Custom GPG Directory

Specify an alternative GnuPG home directory:[5]

```
pacman-key --gpgdir /path/to/gnupg
```


### Advanced Usage with GnuPG

For complex keyring management beyond pacman-key's capabilities, use GnuPG directly with the `--homedir` option pointing at the pacman keyring:[2][4]

```
sudo gpg --homedir /etc/pacman.d/gnupg --list-keys
```


### Important Considerations

**Root privileges required:** Most pacman-key operations require root access to modify the system-wide keyring.[5][4]

**Network connectivity needed:** Operations like refreshing or receiving keys from keyservers require internet access.[5][4]

**Verify fingerprints:** Always verify key fingerprints before signing or trusting keys.[5][4]

**Security warning:** Adding keys from untrusted sources can compromise system security.[5]

**Regular maintenance:** Keep the keyring updated by regularly running `pacman -S archlinux-keyring`.[3]

Sources
[1] pacman/Package signing - ArchWiki https://wiki.archlinux.org/title/Pacman/Package_signing
[2] pacman-key(8) https://pacman.archlinux.page/pacman-key.8.html
[3] refresh-keys and pacman -S archlinux-keyring https://www.reddit.com/r/archlinux/comments/ur12q4/what_is_the_difference_between_pacmankey/
[4] pacman-key(8) - Arch manual pages https://man.archlinux.org/man/pacman-key.8
[5] pacman-key man https://linuxcommandlibrary.com/man/pacman-key
[6] Pacman Key Manager - linux Commands https://hexmos.com/freedevtools/tldr/linux/pacman-key/
[7] pacman key TLDR page https://www.cheat-sheets.org/project/tldr/command/pacman-key/os/linux/
[8] Two PGP Keyrings for Package Management in Arch Linux http://allanmcrae.com/2015/01/two-pgp-keyrings-for-package-management-in-arch-linux/
[9] pacman-key · ArchLabs: Knowledge Base https://avnsgt.gitbooks.io/archlabs-knowledge-base/content/gnupg/pacman-key.html
[10] Arch Linux Pacman: A Detailed Guide with Commands and ... https://dev.to/snigdhaos/arch-linux-pacman-a-detailed-guide-with-commands-and-examples-en5

