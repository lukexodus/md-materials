## Red Hat/Fedora (DNF/YUM)


### DNF/YUM Usage

DNF (Dandified YUM) serves as the next-generation package manager for Red Hat-based distributions, replacing YUM while maintaining backward compatibility and providing enhanced dependency resolution, improved performance, and better user experience.

**Command structure** follows the pattern `dnf [options] command [package-spec]`, where commands specify the desired action, package specifications identify target packages, and options modify behavior. DNF supports both individual package operations and bulk operations across multiple packages simultaneously.

**Package installation** uses `dnf install package_name` to download and install packages along with their dependencies. DNF automatically resolves dependency chains, downloading required packages from configured repositories. The installation process includes dependency checking, package downloading, GPG signature verification, and final installation with RPM backend operations. Multiple packages can be installed simultaneously by listing them as space-separated arguments.

**Package removal** employs `dnf remove package_name` to uninstall packages and their unused dependencies. DNF identifies packages that depend on the target package and either prevents removal or suggests additional packages for removal. The `dnf autoremove` command removes packages that were installed as dependencies but are no longer needed by any installed package.

**Package updates** utilize `dnf update` without arguments to update all installed packages to their latest available versions, or `dnf update package_name` to update specific packages. The update process downloads newer package versions, resolves dependencies, and replaces existing installations. DNF maintains transaction history allowing rollback of updates through `dnf history undo` operations.

**Package searching** provides multiple approaches to locate packages. The `dnf search keyword` command searches package names and descriptions for specified terms. The `dnf list` command displays installed packages, available packages, or both depending on options. The `dnf info package_name` command provides detailed information about specific packages including version, size, dependencies, and description.

**Transaction history** maintains records of all DNF operations, enabling review and rollback of changes. The `dnf history` command displays chronological transaction records with unique IDs. Specific transactions can be examined with `dnf history info transaction_id`, and problematic transactions can be reversed using `dnf history undo transaction_id`.

**Clean operations** manage DNF cache and temporary files. The `dnf clean metadata` command removes repository metadata forcing fresh downloads on next operation. The `dnf clean packages` removes downloaded packages from cache, while `dnf clean all` performs comprehensive cleanup of all cached data.

**Key points:**

- DNF provides enhanced dependency resolution compared to legacy YUM
- Transaction history enables tracking and rollback of package operations
- Automatic dependency management simplifies package installation and removal
- Cache management commands help maintain system cleanliness and resolve repository issues
- Multiple packages can be operated upon simultaneously for efficiency

**Examples:**

```bash
# Install packages
dnf install httpd mysql-server php

# Update system
dnf update

# Search for packages
dnf search web server
dnf list installed | grep kernel

# Remove packages and dependencies
dnf remove httpd
dnf autoremove

# View transaction history
dnf history
dnf history info 5
dnf history undo 5
```

### RPM Package Management

RPM (Red Hat Package Manager) provides the low-level package management foundation that DNF and YUM utilize, handling individual package files with .rpm extensions and maintaining the system package database.

**RPM package structure** consists of metadata headers and compressed file archives. Headers contain package information including name, version, release, architecture, dependencies, file lists, and installation scripts. The archive section holds actual files, directories, and symbolic links that comprise the package contents. RPM packages use naming conventions following name-version-release.architecture.rpm format.

**Package database** resides in /var/lib/rpm/ and maintains comprehensive records of installed packages, file ownership, checksums, and dependency relationships. The database enables RPM to track which files belong to which packages, verify package integrity, and resolve dependency conflicts. Database corruption can cause system-wide package management issues requiring rebuilding with rpm --rebuilddb.

**Direct RPM operations** bypass higher-level package managers for specific scenarios requiring low-level control. Installation with `rpm -i package.rpm` installs packages without dependency resolution, potentially causing conflicts if dependencies are unmet. Upgrade operations use `rpm -U package.rpm` to replace existing package versions or install new packages. Removal with `rpm -e package_name` uninstalls packages but may fail if other packages depend on the target.

**Package verification** ensures system integrity by comparing installed files against original package specifications. The `rpm -V package_name` command checks file permissions, ownership, timestamps, checksums, and sizes against expected values. Verification output uses single-character codes indicating specific discrepancies: S for size changes, M for mode/permission changes, 5 for MD5 checksum mismatches, D for device file changes, L for readlink path changes, U for user ownership changes, G for group ownership changes, and T for mtime changes.

**Package querying** provides detailed information about installed and uninstalled packages. The `rpm -q` command family offers extensive querying capabilities: `rpm -qa` lists all installed packages, `rpm -qf filename` identifies which package owns a specific file, `rpm -ql package_name` displays files contained in a package, `rpm -qi package_name` shows detailed package information, and `rpm -qd package_name` lists documentation files.

**Package building** involves creating RPM packages from source code using spec files that define build instructions, dependencies, file lists, and installation scripts. The rpmbuild command processes spec files through preparation, compilation, installation, and packaging phases. Building packages requires development tools, source code, and properly configured build environments.

**RPM macros** provide variables and functions that simplify spec file creation and standardize package building across different architectures and distributions. Common macros include %{_bindir} for binary directories, %{_sysconfdir} for configuration directories, and %{_mandir} for manual page locations. Custom macros can be defined in ~/.rpmmacros files for user-specific customizations.

**Key points:**

- RPM manages individual package files and maintains system package database
- Direct RPM operations bypass dependency resolution provided by higher-level tools
- Package verification ensures system integrity and detects unauthorized changes
- Querying capabilities provide comprehensive package and file information
- Package building requires spec files and appropriate development environments

**Examples:**

```bash
# Install RPM package directly
rpm -ivh package.rpm

# Query installed packages
rpm -qa | grep kernel
rpm -qf /usr/bin/ls
rpm -ql httpd

# Verify package integrity
rpm -V httpd
rpm -Va

# Extract files from RPM
rpm2cpio package.rpm | cpio -idmv

# View package information
rpm -qip package.rpm
```

### Repository Configuration

Repository configuration defines software sources that DNF and YUM use to locate, download, and install packages, enabling centralized software distribution and automatic updates.

**Repository files** reside in /etc/yum.repos.d/ directory with .repo extensions, containing configuration sections that define repository characteristics. Each repository requires a unique identifier enclosed in square brackets, followed by configuration parameters that specify repository behavior and access methods.

**Essential repository parameters** include name for human-readable repository descriptions, baseurl or metalink for repository locations, enabled to control repository activation, gpgcheck for signature verification requirements, and gpgkey for public key locations. Additional parameters control caching, priority, bandwidth limits, and authentication requirements.

**Repository URLs** support multiple protocols including HTTP, HTTPS, FTP, and file:// for local repositories. Repository structures must conform to YUM/DNF standards with repodata/ directories containing XML metadata files describing available packages. Mirror lists and metalinks provide redundancy and geographic distribution for improved download performance.

**GPG signature verification** ensures package authenticity and integrity through cryptographic signatures. Repository configuration typically enables gpgcheck and specifies gpgkey URLs pointing to repository maintainer public keys. The first access to signed repositories prompts for key acceptance, and accepted keys are stored in /etc/pki/rpm-gpg/ directory.

**Repository priorities** control package selection when multiple repositories provide the same package. The yum-plugin-priorities package enables priority functionality, with lower numeric values indicating higher priority. Priority configuration prevents inadvertent package replacement from third-party repositories and maintains system stability.

**Local repositories** enable package distribution within organizations or offline environments. Creating local repositories involves collecting RPM packages in directory structures, generating metadata with createrepo command, and configuring repository files pointing to local paths. Local repositories support both file:// URLs for direct access and HTTP serving for network distribution.

**Repository management commands** provide tools for enabling, disabling, and listing configured repositories. The `dnf repolist` command displays active repositories with metadata status. Individual repositories can be temporarily enabled or disabled using --enablerepo and --disablerepo options with DNF commands. The `dnf config-manager` command provides comprehensive repository configuration management.

**Repository caching** improves performance by storing downloaded metadata and packages locally. DNF automatically caches repository metadata in /var/cache/dnf/ directory, refreshing based on metadata expiration settings. Cache management through dnf clean commands resolves issues with stale metadata or corrupted downloads.

**Key points:**

- Repository files in /etc/yum.repos.d/ define software sources for package managers
- GPG signature verification ensures package authenticity and system security
- Repository priorities prevent conflicts when multiple sources provide identical packages
- Local repositories enable offline or organizational package distribution
- Metadata caching improves performance but requires periodic cleanup

**Examples:**

```bash
# View repository configuration
dnf repolist
dnf repolist all

# Enable/disable repositories
dnf --enablerepo=epel install package
dnf config-manager --disable fedora

# Add new repository
dnf config-manager --add-repo https://example.com/repo

# Create local repository
createrepo /path/to/packages
dnf config-manager --add-repo file:///path/to/packages

# Repository file example
cat > /etc/yum.repos.d/custom.repo << EOF
[custom-repo]
name=Custom Repository  
baseurl=https://repo.example.com/el8/
enabled=1
gpgcheck=1
gpgkey=https://repo.example.com/RPM-GPG-KEY
EOF
```

### Package Groups

Package groups organize related packages into logical collections, simplifying bulk software installation and system configuration for specific purposes or environments.

**Group concepts** bundle packages that serve common functions, reducing the complexity of installing complete software stacks. Groups typically include mandatory packages that are always installed, default packages that are normally installed but can be excluded, and optional packages that require explicit selection for installation.

**Group types** encompass different organizational approaches. Environment groups represent complete desktop environments or server configurations, containing multiple package groups and individual packages. Regular groups focus on specific functionality like development tools, office applications, or multimedia support. Language groups provide localization support for specific languages and regions.

**Group discovery** utilizes `dnf group list` to display available package groups, showing both installed and available groups. The `dnf group info group_name` command provides detailed information about group contents, including mandatory, default, and optional packages. Hidden groups can be revealed using the --hidden option with group commands.

**Group installation** employs `dnf group install "group_name"` to install complete package groups with their default package selections. Group names containing spaces require quotation marks for proper parsing. The installation process resolves dependencies for all selected packages and handles conflicts between group members and existing packages.

**Group customization** allows selective installation of group components. The `--with-optional` option includes optional packages during group installation. Individual packages can be excluded using `--exclude=package_name` options. Post-installation package additions can be made with standard DNF install commands.

**Group removal** uses `dnf group remove "group_name"` to uninstall packages associated with specific groups. [Inference] Group removal typically removes only packages that were installed as part of the group and are not required by other installed software. Dependencies shared with other packages or groups remain installed to prevent system breakage.

**Group updates** maintain group package collections as repositories provide newer versions. The `dnf group update "group_name"` command updates all packages within the specified group to their latest available versions. Group updates follow the same dependency resolution processes as individual package updates.

**Custom groups** can be created through comps.xml files that define group metadata, package lists, and relationships. [Unverified] Organizations may create custom groups for standardized software deployments or role-specific package collections. Custom group creation requires understanding of comps.xml format and repository metadata generation.

**Environment groups** provide comprehensive system configurations for specific use cases. Common environments include "Fedora Workstation" for desktop systems, "Minimal Install" for basic server deployments, "Server" for general server configurations, and "Virtualization Host" for hypervisor systems. Environment selection typically occurs during system installation but can be modified post-installation.

**Key points:**

- Package groups simplify installation of related software collections
- Groups contain mandatory, default, and optional package classifications
- Environment groups provide complete system configurations for specific roles
- Group operations handle dependency resolution across multiple packages simultaneously
- Custom groups enable organizational standardization of software deployments

**Examples:**

```bash
# List available groups
dnf group list
dnf group list --hidden

# View group information
dnf group info "Development Tools"
dnf group info --hidden "Core"

# Install package groups
dnf group install "Web Server"
dnf group install "Development Tools" --with-optional

# Remove package groups
dnf group remove "Office Suite and Productivity"

# Install environment groups
dnf group install "Fedora Workstation"
dnf environment install "Virtualization Host"

# Mark group as installed
dnf group mark install "System Tools"
```

Understanding Red Hat/Fedora package management through DNF, RPM, repository configuration, and package groups enables effective system administration, software deployment, and maintenance operations. These tools provide comprehensive package lifecycle management from installation through updates and removal, with robust dependency resolution and system integrity protection.

---

