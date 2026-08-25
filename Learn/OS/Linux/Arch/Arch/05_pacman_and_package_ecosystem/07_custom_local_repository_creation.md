## Custom Local Repository Creation


### Local Repository Overview

**Purpose**: Creating a custom local repository enables centralized management of self-built packages, enabling their distribution and installation via pacman.[1][2]

**Benefits**:[2][1]
- Centralized package management[1]
- Version control and package tracking[1]
- Automated dependency resolution[1]
- Easy distribution to multiple systems[1]
- Integration with pacman's standard workflow[1]

**Use Cases**:[1]
- Maintaining personal builds across multiple machines[1]
- Testing custom packages before official release[1]
- Distributing organization-specific packages[1]

### Setting Up Repository Directory

**Directory Creation**: Create a dedicated directory for repository packages:[1]

```bash
mkdir -p ~/packages/myrepo
cd ~/packages/myrepo
```

**Subdirectories**:[1]

```
myrepo/
├── x86_64/              # 64-bit packages
├── i686/                # 32-bit packages (if applicable)
└── any/                 # Architecture-independent packages
```

### Building Packages for Repository

**Compilation**: Build packages in separate working directories:[1]

```bash
mkdir -p ~/build/mypackage
cd ~/build/mypackage
cp /path/to/PKGBUILD .
makepkg
```

**Output Location**: Compiled packages appear in build directory.[1]

**Package Naming**: Packages are named `pkgname-pkgver-pkgrel-arch.pkg.tar.zst`.[1]

**Copy to Repository**: Move compiled packages to repository directory:[1]

```bash
mv mypackage-1.0-1-x86_64.pkg.tar.zst ~/packages/myrepo/x86_64/
```

### Creating Repository Database

**repo-add Tool**: Part of pacman package; creates and maintains repository database.[2][1]

**Installation**: `sudo pacman -S pacman` (typically pre-installed).[1]

#### Initial Database Creation

**Basic Command**: `repo-add myrepo.db.tar.gz package1.pkg.tar.zst package2.pkg.tar.zst`.[2][1]

**Parameters**:[2][1]
- **`myrepo.db.tar.gz`**: Repository database filename[2]
- **`package*.pkg.tar.zst`**: Individual package files to add[2]

**Complete Example**:[2][1]

```bash
cd ~/packages/myrepo/x86_64
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

**Generated Files**:[1]
- **`myrepo.db.tar.gz`**: Main repository database[1]
- **`myrepo.db.tar.gz.old`**: Backup of previous database[1]
- **`myrepo.files.tar.gz`**: File listing for package searches[1]

### Database Maintenance

**Adding Packages**: When building new packages, re-run repo-add:[1]

```bash
repo-add myrepo.db.tar.gz newpackage.pkg.tar.zst
```

**Removing Packages**: Use repo-remove to delete from database:[1]

```bash
repo-remove myrepo.db.tar.gz oldpackage
```

**Verify Database**: `tar -tzf myrepo.db.tar.gz` lists database contents.[1]

#### Automated Maintenance Script

**Bash Script**:[1]

```bash
#!/bin/bash
REPO_DIR="$HOME/packages/myrepo/x86_64"
cd "$REPO_DIR"

# Remove old database backups
rm -f *.old

# Recreate database from all packages
rm -f myrepo.db.tar.gz myrepo.files.tar.gz
repo-add myrepo.db.tar.gz *.pkg.tar.zst

echo "Repository updated successfully"
```

**Schedule**: Run via cron for periodic automatic updates:[1]

```bash
# Add to crontab
0 * * * * ~/bin/update_repo.sh
```

### Configuring Pacman

**Edit pacman.conf**: Add custom repository to `/etc/pacman.conf`:[2][1]

```
[myrepo]
SigLevel = Never
Server = file:///home/username/packages/myrepo/$arch
```

**Parameters**:[2][1]
- **`[myrepo]`**: Repository name[1]
- **`SigLevel = Never`**: Disable signature verification for local packages[1]
- **`Server = file://...`**: Local filesystem path[1]
- **`$arch`**: Automatic architecture substitution (x86_64, i686)[1]

#### Repository Priority

**Precedence**: Repository order in `/etc/pacman.conf` determines priority.[1]

**High Priority**: Place custom repository early to prioritize over official:[1]

```
[myrepo]
...
[core]
...
[extra]
...
```

### Synchronizing Repository

**Update Database**: After configuration, synchronize pacman cache:[2][1]

```bash
sudo pacman -Sy
```

**Verify**: List available packages from custom repository:[1]

```bash
pacman -Sl myrepo
```

### Installing from Custom Repository

**Install Packages**: Standard pacman commands work with custom repository:[2][1]

```bash
sudo pacman -S myrepo/package1 myrepo/package2
```

**Automatic Installation**: Without explicit repository specification, pacman respects priority:[1]

```bash
sudo pacman -S package1  # Installs from first matching repository
```

### Remote Repository Setup

**Network Sharing**: Share repository over network for multiple machines.[1]

**HTTP Server**: Use Apache or Nginx:[1]

```
Server = http://192.168.1.100/myrepo/$arch
```

**SSH Access**: Enable remote PKGBUILD building:[1]

```
Server = ssh://user@192.168.1.100/home/user/packages/myrepo/$arch
```

**SMB/CIFS**: Windows network sharing:[1]

```
Server = smb://server/share/myrepo/$arch
```

### Package Organization

**Naming Convention**: Establish consistent naming:[1]
- Repository name indicates purpose[1]
- Version numbers follow upstream releases[1]
- Release numbers track rebuild count[1]

**Directory Structure**:[1]

```
myrepo/
├── x86_64/
│   ├── mypackage-1.0-1-x86_64.pkg.tar.zst
│   ├── mypackage-1.0-2-x86_64.pkg.tar.zst
│   └── another-2.0-1-x86_64.pkg.tar.zst
├── i686/
│   ├── mypackage-1.0-1-i686.pkg.tar.zst
│   └── another-2.0-1-i686.pkg.tar.zst
└── any/
    └── config-1.0-1-any.pkg.tar.zst
```

### Archiving Old Packages

**Separate Archive**: Move old versions to archive directory:[1]

```bash
mkdir -p ~/packages/myrepo-archive
mv ~/packages/myrepo/x86_64/*-1.0-* ~/packages/myrepo-archive/
```

**Rebuild Database**: Remove archived packages from active database:[1]

```bash
cd ~/packages/myrepo/x86_64
repo-remove myrepo.db.tar.gz oldpackage
```

### Backup and Recovery

**Backup Database**: Regular backups protect repository integrity:[1]

```bash
cp ~/packages/myrepo/x86_64/myrepo.db.tar.gz ~/backup/
```

**Export Package List**: Document installed packages:[1]

```bash
pacman -Q > package_list.txt
```

**Restore**: Recreate database from packages:[1]

```bash
cd ~/packages/myrepo/x86_64
rm -f myrepo.db.tar.gz
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

### Security Considerations

**Signature Keys**: For production repositories, use GPG signing:[1]

```bash
repo-add --sign -k KEYID myrepo.db.tar.gz *.pkg.tar.zst
```

**File Permissions**: Restrict repository directory access:[1]

```bash
chmod 755 ~/packages/myrepo
chmod 644 ~/packages/myrepo/x86_64/*
```

**Network Security**: Use HTTPS for remote repositories:[1]

```
Server = https://example.com/myrepo/$arch
```

### Troubleshooting

**Package Not Found**: Verify database includes package:[1]

```bash
tar -tzf myrepo.db.tar.gz | grep -i package
```

**Synchronization Issues**: Clear pacman cache and resync:[1]

```bash
sudo pacman -Syy
```

**File Conflicts**: Check for duplicate packages across repositories:[1]

```bash
pacman -Sl myrepo | sort
```

**Database Corruption**: Rebuild from scratch:[1]

```bash
cd ~/packages/myrepo/x86_64
rm -f myrepo.db.tar.gz myrepo.files.tar.gz
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

### Best Practices

**Consistent Naming**: Use predictable package naming conventions.[1]

**Regular Updates**: Rebuild database when adding packages.[1]

**Document Contents**: Maintain list of packages and versions.[1]

**Version Control**: Track PKGBUILD changes in Git.[1]

**Regular Backups**: Backup repository database and important packages.[1]

**Testing**: Verify packages install and work correctly.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Official repositories web interface https://wiki.archlinux.org/title/Official_repositories_web_interface

