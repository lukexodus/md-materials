## Archive Extraction


### Pacman Package File Structure

Pacman packages are tar archives (typically compressed with zstd, xz, or gzip) containing files to be installed and package metadata. The package file format is `.pkg.tar.zst`, `.pkg.tar.xz`, or `.pkg.tar.gz`.[1][2][3]

### Package Archive Contents

#### Internal Structure

A pacman package archive contains:[2][3]

**Metadata files:**
- `.PKGINFO` - Package information and metadata[3][2]
- `.MTREE` - File integrity checksums and permissions[2][3]
- `.BUILDINFO` - Build environment information[3][2]
- `.INSTALL` (optional) - Pre/post install scripts[3]
- `.CHANGELOG` (optional) - Package changelog[3]

**File hierarchy:**
- Files organized in standard Unix directory structure (`usr/`, `etc/`, etc.)[2]
- Paths are relative to the root filesystem[2]

### Listing Package Contents

#### Using tar to List Files

List the contents of a package archive without extracting:[2][3]

```
tar -tf package-name.pkg.tar.zst
```


**Example:**
```
tar -tf zstd-1.4.9-1-x86_64.pkg.tar.zst
```


**Output shows:**
```
.BUILDINFO
.MTREE
.PKGINFO
usr/
usr/bin/
usr/bin/zstd
usr/lib/
usr/lib/libzstd.so.1.4.9
...
```


#### Using pacman to Query Package Files

Query information from a package file without installing:[4]

```
pacman -Qip /path/to/package.pkg.tar.zst
```


List files that would be installed:
```
pacman -Qlp /path/to/package.pkg.tar.zst
```


### Manual Package Extraction

#### Extract Package Archive

Manually extract a package archive using tar:[3][2]

```
tar -xf package-name.pkg.tar.zst
```


**Extract to specific directory:**
```
tar -xf package-name.pkg.tar.zst -C /destination/path
```

**Extract to root filesystem (dangerous):**
```
sudo tar -xf package-name.pkg.tar.zst -C /
```


**Warning:** Manual extraction bypasses pacman's database tracking. The package manager will not know about manually extracted files.[1][2]

#### Extraction for Inspection

Extract to a temporary location for examination:[2]

```
mkdir /tmp/package-inspection
tar -xf package.pkg.tar.zst -C /tmp/package-inspection
cd /tmp/package-inspection
```


This allows inspecting package contents without affecting the system.[2]

### Examining Package Metadata

#### View .PKGINFO File

After extracting, examine the `.PKGINFO` file for package meta[3][2]

```
tar -xf package.pkg.tar.zst .PKGINFO
cat .PKGINFO
```


**Contents include:**
- Package name and version
- Dependencies
- Conflicts
- Provides
- Architecture
- Build date
- Packager information[3]

#### View .MTREE File

The `.MTREE` file contains file integrity information:[3][2]

```
tar -xf package.pkg.tar.zst .MTREE
zcat .MTREE | less
```


This file is gzipped and contains checksums and permissions for all files in the package.[3][2]

### Emergency Recovery Extraction

#### System Recovery Scenario

When pacman is broken and cannot install packages normally:[1]

**Step 1: Extract package manually**
```
sudo tar -xf /var/cache/pacman/pkg/pacman-*.pkg.tar.zst -C /
```


**Step 2: Rebuild database entry**
```
sudo pacman -S --overwrite "*" pacman
```


This reinstalls pacman to the database after manual file extraction.[1]

**Alternative: Use pacman-static**
Instead of manual extraction, use the static pacman binary which doesn't depend on system libraries:
```
curl -L -o pacman-static https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```


### Extracting Specific Files

#### Extract Individual Files from Package

Extract only specific files from a package archive:

```
tar -xf package.pkg.tar.zst path/to/specific/file
```

**Example - Extract only binaries:**
```
tar -xf firefox.pkg.tar.zst usr/bin/
```

**Example - Extract only documentation:**
```
tar -xf package.pkg.tar.zst usr/share/doc/
```

### Archive Format Handling

#### Different Compression Formats

Pacman packages can use various compression formats:

**zstd (modern default):**
```
tar -xf package.pkg.tar.zst
```

**xz (older standard):**
```
tar -xf package.pkg.tar.xz
```

**gzip (legacy):**
```
tar -xf package.pkg.tar.gz
```

**Uncompressed:**
```
tar -xf package.pkg.tar
```

Modern tar automatically detects compression format, so the same command works for all:
```
tar -xf package.pkg.tar.*
```

### Viewing Compressed Metadata Without Extraction

#### Using zcat for Gzipped Files

View gzipped metadata files directly:[2]

```
tar -xOf package.pkg.tar.zst .MTREE | zcat | less
```


The `-O` flag outputs to stdout, piping to `zcat` for decompression and `less` for viewing.[2]

### Package Archive Tools

#### File Command

Identify the archive type:

```
file package.pkg.tar.zst
```

**Output:**
```
package.pkg.tar.zst: Zstandard compressed data
```

#### Archive Utilities

Common tools for working with package archives:

- `tar` - Extract and list archive contents
- `zcat` / `zless` / `zgrep` - Work with gzipped files
- `xzcat` / `xzless` - Work with xz-compressed files
- `zstdcat` - Work with zstd-compressed files

### Security Considerations

#### Avoid Manual Extraction

**Warning:** Manually extracting packages to the root filesystem is dangerous and should only be done in emergency recovery scenarios.[1]

**Risks:**
- Bypasses pacman database tracking
- No dependency verification
- No conflict checking
- Can overwrite important system files
- Leaves system in inconsistent state

**Proper alternative:** Always use `pacman -U` for package installation, which handles extraction safely with database integration.[1]

### Educational Package Exploration

#### Learning Package Structure

Extract packages to examine their structure for educational purposes:[2]

```
# Copy package to temporary location
cp /var/cache/pacman/pkg/package.pkg.tar.zst /tmp/
cd /tmp

# Extract package
tar -xf package.pkg.tar.zst

# Explore contents
tree -L 3

# Read metadata
cat .PKGINFO
cat .BUILDINFO
zcat .MTREE | less
```


This helps understand how pacman packages are organized and what files they install.[2]

### Best Practices

**Use pacman for installation:** Always prefer `pacman -U` over manual extraction for actual installation.[1]

**Extract to safe locations:** When inspecting packages, extract to temporary directories, not root.[2]

**Examine before installing:** Review package contents before installation to understand what will be installed.

**Respect meta** Package metadata files (`.PKGINFO`, `.MTREE`) provide important information about the package.

**Emergency only:** Only manually extract to root filesystem in emergency recovery scenarios when pacman is completely broken.[1]

**Database consistency:** If you manually extract files, always reinstall properly afterward to update pacman's database.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] How do you learn how pacman & AUR helpers work? https://www.reddit.com/r/archlinux/comments/ncofi1/how_do_you_learn_how_pacman_aur_helpers_work/
[3] What Makes a Pacman Package https://gist.github.com/Earnestly/bebad057f40a662b5cc3
[4] pacman(8) https://pacman.archlinux.page/pacman.8.html
[5] archive_read_extract(3) - Arch manual pages https://man.archlinux.org/man/archive_read_extract.3.en
[6] Is it safe to manually delete a package from the ... https://www.facebook.com/groups/archlinuxen/posts/10158299629538393/
[7] Unzip Command in Linux https://www.geeksforgeeks.org/linux-unix/unzip-command-in-linux/
[8] Package Management https://www.msys2.org/docs/package-management/
[9] What is a package? And what do package managers like ... https://www.reddit.com/r/linux4noobs/comments/1gr90ad/what_is_a_package_and_what_do_package_managers/
[10] How to Manage Packages in Arch Using Pacman | Linode Docs https://www.linode.com/docs/guides/pacman-package-manager/

