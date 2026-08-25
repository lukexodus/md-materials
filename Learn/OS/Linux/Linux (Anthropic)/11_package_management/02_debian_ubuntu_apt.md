## Debian/Ubuntu (APT)


### APT Command Usage

The Advanced Package Tool (APT) is Debian and Ubuntu's primary package management system, providing a high-level interface for installing, updating, and managing software packages. APT handles dependency resolution, package configuration, and maintains system consistency across package operations.

**Key Points:**

- APT replaces older tools like `apt-get` and `apt-cache` with unified functionality
- Dependency resolution prevents system conflicts
- Package databases track installed software and available updates
- Root privileges are required for most package operations

APT operates through a hierarchical system where packages are stored in repositories, indexed by package databases, and managed through local caches. The system maintains package metadata including dependencies, conflicts, version information, and installation scripts.

The `apt` command provides streamlined syntax compared to legacy tools, combining frequently used operations from `apt-get`, `apt-cache`, and `apt-config`. Interactive features include progress bars, colored output, and confirmation prompts that improve user experience over traditional tools.

Package states in APT include installed, available, upgradable, and held packages. The system tracks package configurations, allowing for complete removal including configuration files or partial removal preserving configurations for potential reinstallation.

**Example:**

```bash
# Update package database
apt update

# Show upgradable packages
apt list --upgradable

# Search for packages
apt search nginx

# Show command help
apt --help
apt install --help
```

#### Cache Management

APT maintains local caches of package information and downloaded packages to improve performance and enable offline operations. The package cache stores downloaded .deb files, while the package database cache contains metadata from repositories.

Cache operations include updating package lists from repositories, cleaning downloaded package files, and managing cache sizes. The `autoclean` operation removes only obsolete package files, while `clean` removes all cached packages.

**Example:**

```bash
# Update package cache
apt update

# Clean package cache
apt autoclean
apt clean

# Show cache statistics
apt-cache stats
du -sh /var/cache/apt/archives/
```

### Package Installation and Removal

Package installation through APT involves downloading packages and their dependencies, verifying integrity, and executing installation scripts. The system ensures dependency satisfaction and handles configuration file management during installation and upgrades.

**Key Points:**

- Dependency resolution automatically installs required packages
- Configuration files are preserved during upgrades when modified
- Package holds prevent unwanted upgrades
- Simulation mode allows testing operations without changes

Installation operations download packages to the local cache, verify cryptographic signatures, and execute pre-installation scripts. Dependencies are resolved recursively, with APT selecting appropriate versions to satisfy all requirements. Post-installation scripts configure services and update system databases.

Package removal offers multiple levels: `remove` uninstalls packages but preserves configuration files, while `purge` completely removes packages including configurations. The `autoremove` operation removes packages that were automatically installed as dependencies but are no longer needed.

Version pinning and package holds provide control over package updates. Holds prevent specific packages from being upgraded, useful for maintaining specific versions or preventing problematic updates. Version pinning through `/etc/apt/preferences` provides fine-grained control over package selection.

**Example:**

```bash
# Install single package
apt install nginx

# Install multiple packages
apt install nginx mysql-server php-fpm

# Install specific version
apt install nginx=1.18.0-6ubuntu14

# Simulate installation
apt install --dry-run nginx

# Remove package (keep configs)
apt remove nginx

# Completely remove package
apt purge nginx

# Remove unnecessary dependencies
apt autoremove
```

#### Dependency Management

APT's dependency resolution engine ensures system consistency by automatically handling package relationships. Dependencies, recommendations, suggestions, and conflicts are evaluated to determine installation requirements and prevent system breakage.

Essential dependencies must be satisfied for package installation, while recommended packages are typically installed unless explicitly disabled. Suggested packages provide optional functionality but aren't automatically installed. Conflicts prevent installation of incompatible packages.

**Example:**

```bash
# Install without recommended packages
apt install --no-install-recommends package-name

# Install with suggested packages
apt install --install-suggests package-name

# Show package dependencies
apt depends nginx
apt rdepends nginx

# Check broken dependencies
apt check
```

#### Package Upgrades

Package upgrades maintain system security and functionality by installing newer package versions. APT distinguishes between regular upgrades that don't remove packages and full upgrades that may remove packages to resolve conflicts.

**Key Points:**

- Regular upgrades preserve installed packages
- Full upgrades may remove conflicting packages
- Dist-upgrades handle major system transitions
- Package holds prevent unwanted upgrades

The `upgrade` command installs newer versions of installed packages without removing any packages. If dependency resolution requires package removal, those packages are not upgraded. The `full-upgrade` command performs upgrades even if package removal is necessary.

Distribution upgrades involve transitioning between major system versions, requiring careful planning and testing. These operations may significantly modify the system, install new packages, or remove obsolete packages.

**Example:**

```bash
# Standard upgrade
apt upgrade

# Full upgrade allowing removals
apt full-upgrade

# Upgrade specific package
apt install --only-upgrade nginx

# Hold package from upgrades
apt-mark hold nginx
apt-mark unhold nginx

# Show held packages
apt-mark showhold
```

### Repository Management

APT repositories are centralized package collections that provide software distribution and updates. Repository management involves configuring sources, managing authentication keys, and controlling package priorities across different repositories.

**Key Points:**

- Repository sources are defined in `/etc/apt/sources.list` and `/etc/apt/sources.list.d/`
- GPG keys authenticate repository packages
- Repository priorities control package selection
- Third-party repositories extend available software

Repository configuration files specify repository URLs, distribution names, and components. The main sources.list file contains primary system repositories, while the sources.list.d directory contains individual repository files for easier management.

Repository components typically include `main` (officially supported free software), `restricted` (supported proprietary software), `universe` (community-maintained free software), and `multiverse` (unsupported software with legal restrictions). Different distributions may use different component names.

Authentication through GPG keys ensures package integrity and authenticity. Repository keys must be added to the system keyring before packages can be installed. The `apt-key` command traditionally managed keys, though modern systems use `/etc/apt/trusted.gpg.d/` for key storage.

**Example:**

```bash
# View configured repositories
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/

# Add repository key
wget -qO - https://example.com/key.gpg | apt-key add -
# Modern approach
wget -qO - https://example.com/key.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/example.gpg

# Add repository
echo "deb https://example.com/ubuntu focal main" > /etc/apt/sources.list.d/example.list

# Update after repository changes
apt update
```

#### Repository Priorities

Repository priorities control package selection when multiple repositories provide the same package. Priority values range from 1 to 1000, with higher values taking precedence. Default priorities are typically 500 for normal repositories and 100 for backports.

Pin priorities in `/etc/apt/preferences` or `/etc/apt/preferences.d/` override default priorities. Specific packages, versions, or entire repositories can be pinned to control upgrade behavior and package selection.

**Example:**

```bash
# Check repository priorities
apt-cache policy

# Check specific package policy
apt-cache policy nginx

# Create pin priority file
cat > /etc/apt/preferences.d/example << EOF
Package: *
Pin: origin "example.com"
Pin-Priority: 600
EOF
```

#### PPA Management

Personal Package Archives (PPAs) provide additional software sources for Ubuntu systems. PPAs are typically maintained by individual developers or organizations and offer software not available in official repositories.

**Key Points:**

- PPAs extend software availability beyond official repositories
- `add-apt-repository` simplifies PPA management
- PPA software may not receive official security updates [Inference]
- PPA removal should include package downgrading or removal

PPA management involves adding repositories, importing GPG keys, and managing package installations from these sources. The `software-properties-common` package provides tools for PPA management including the `add-apt-repository` command.

**Example:**

```bash
# Add PPA
add-apt-repository ppa:user/ppa-name
apt update

# Remove PPA
add-apt-repository --remove ppa:user/ppa-name

# List installed PPAs
ls /etc/apt/sources.list.d/
apt-cache policy | grep -E '^[0-9]'
```

### Package Information

APT provides comprehensive package information including descriptions, dependencies, installation status, and version details. Information commands help users understand package contents, relationships, and suitability before installation.

**Key Points:**

- Package metadata includes dependencies, conflicts, and descriptions
- File listings show package contents
- Version information aids in selection decisions
- Search capabilities help discover relevant packages

The `apt show` command displays detailed package information including description, dependencies, installation size, and maintainer information. This information helps users evaluate packages before installation and understand package relationships.

Package searching supports both name and description searches, with regular expression capabilities for complex queries. Search results include package names, versions, and brief descriptions to aid in package selection.

**Example:**

```bash
# Show package details
apt show nginx

# Show all package versions
apt list nginx -a

# Search packages
apt search web server
apt search --names-only nginx

# Show package files
dpkg -L nginx
apt-file list nginx
```

#### Package Status Information

Package status information reveals current installation state, configuration status, and available actions. Status categories include installed, not-installed, upgradable, and held packages.

**Example:**

```bash
# List installed packages
apt list --installed

# List upgradable packages
apt list --upgradable

# Show package installation status
dpkg -l nginx
dpkg -s nginx

# Check package integrity
debsums nginx
```

#### Package Content Analysis

Package content analysis reveals files installed by packages, configuration files, and documentation locations. This information aids in troubleshooting, system analysis, and understanding package impact.

**Example:**

```bash
# Show package files
dpkg -L package-name

# Find package owning file
dpkg -S /usr/bin/nginx

# Show package configuration files
dpkg-query -W -f='${Conffiles}\n' package-name

# Search package contents
apt-file search filename
```

#### Repository Package Information

Repository package information includes available versions, package relationships across repositories, and package change histories. This information helps users understand package evolution and make informed decisions about installations and upgrades.

**Example:**

```bash
# Show package policy across repositories
apt-cache policy package-name

# Show package dependencies
apt-cache depends package-name
apt-cache rdepends package-name

# Show package changelog
apt changelog package-name

# Show package information from cache
apt-cache show package-name
```

**Conclusion:** APT provides comprehensive package management capabilities for Debian and Ubuntu systems, handling complex dependency relationships while maintaining system stability. Effective APT usage requires understanding repository management, package relationships, and information gathering techniques. Regular maintenance through updates and upgrades keeps systems secure and functional, while careful repository management expands software availability while maintaining system integrity.

**Next Steps:** Advanced APT topics include custom repository creation, package building and modification, automated update management, and integration with configuration management systems for large-scale deployments.

---

