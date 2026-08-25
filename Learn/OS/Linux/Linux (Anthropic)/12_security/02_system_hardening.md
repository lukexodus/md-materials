## System Hardening


### Service Minimization

Service minimization reduces attack surface by disabling unnecessary network services, system daemons, and background processes that could provide entry points for attackers.

**Service Enumeration** Identifying running services requires multiple approaches since services can start through various mechanisms. The `systemctl list-units --type=service` command shows systemd-managed services, while `netstat -tlnp` or `ss -tlnp` reveals network-listening processes. Legacy systems may require `chkconfig --list` or examining `/etc/rc.d/` directories.

Each running service represents potential attack vectors, especially those binding to network interfaces. Services like SSH, web servers, and database systems require careful evaluation of necessity versus security risk.

**Default Service Analysis** Most Linux distributions install numerous default services for compatibility and functionality. Common candidates for disabling include print services (CUPS), Bluetooth daemons, NFS services, and legacy networking protocols like rsh or telnet.

Network-facing services pose higher risks than local services. Services binding to `0.0.0.0` accept connections from any interface, while localhost-bound services limit exposure to local processes.

**Service Disabling Methods** Modern systemd-based systems use `systemctl disable service-name` and `systemctl stop service-name` to prevent automatic startup and halt current execution. The `systemctl mask service-name` command prevents accidental re-enabling by creating immutable symlinks.

Legacy SysV init systems require disabling services through `chkconfig service-name off` or removing symlinks from `/etc/rc*.d/` directories. Some services may require additional configuration file modifications to prevent restart.

**Essential Service Identification** Critical services vary by system role but typically include init systems, kernel services, logging daemons, and core networking. Server systems require SSH for remote access, while desktop systems need display managers and audio services.

Service dependency analysis using `systemctl list-dependencies` reveals interconnections that could break functionality when services are disabled. Testing service removal in non-production environments prevents operational disruption.

### Unnecessary Package Removal

Package minimization reduces attack surface, storage usage, and maintenance overhead by removing software components that provide no operational value.

**Package Inventory** Complete package inventories use distribution-specific tools like `dpkg -l` (Debian/Ubuntu), `rpm -qa` (Red Hat/CentOS), or `pacman -Q` (Arch Linux). These listings reveal installed software, versions, and installation sources.

Automated tools like `deborphan` (Debian) or `package-cleanup --leaves` (Red Hat) identify orphaned packages without reverse dependencies. Manual analysis identifies packages installed for testing or development that no longer serve purposes.

**Risk Assessment** High-risk packages include network servers, interpreters for unused languages, development tools on production systems, and legacy compatibility libraries. Packages with frequent security updates or complex codebases present ongoing maintenance burdens.

Documentation and manual page packages consume storage but pose minimal security risks. Kernel modules for unused hardware can be removed but require careful analysis to avoid system instability.

**Safe Removal Procedures** Package removal should follow dependency analysis to prevent breaking essential functionality. The `apt-get --simulate remove` or `yum remove --assumeno` commands preview removal effects without making changes.

Staging environments allow testing package removal effects before production implementation. Configuration file preservation options (`dpkg --purge` vs `dpkg --remove`) determine whether customizations persist through reinstallation.

**Minimal Installation Strategies** Server deployments benefit from minimal base installations that install only essential packages. Container environments particularly benefit from minimal base images that reduce size and attack surface.

Package groups or meta-packages simplify minimal installations by providing curated selections for specific roles. Custom installation profiles can be created for consistent deployment across multiple systems.

### Secure Configuration

Secure configuration hardens system settings, applies security controls, and enforces policies that resist common attack vectors.

**File System Security** Mount options enhance file system security through restrictions like `noexec` (prevent execution), `nosuid` (ignore SUID bits), and `nodev` (ignore device files). Temporary directories (`/tmp`, `/var/tmp`) particularly benefit from these restrictions.

File system permissions follow the principle of least privilege, where files and directories grant minimum necessary access. Default umask settings of 077 or 027 prevent world-readable file creation by unprivileged users.

Extended attributes and Access Control Lists (ACLs) provide fine-grained permissions beyond traditional Unix file modes. SELinux or AppArmor mandatory access controls add additional policy layers.

**Network Configuration** Kernel network parameters control security-relevant behaviors through `/proc/sys/net/` tunables. Disabling IP forwarding (`net.ipv4.ip_forward=0`), enabling SYN flood protection (`net.ipv4.tcp_syncookies=1`), and ignoring ICMP redirects (`net.ipv4.conf.all.accept_redirects=0`) improve network security.

Firewall configuration using iptables, nftables, or firewalld implements network access controls. Default-deny policies with explicit allow rules minimize exposure to unauthorized network access.

Network service binding should prefer specific interfaces over wildcard addresses when possible. SSH configuration benefits from restricting users, disabling root login, and using key-based authentication.

**System Resource Limits** Resource limits prevent denial-of-service attacks and resource exhaustion. The `/etc/security/limits.conf` file or systemd service limits control process counts, memory usage, and file descriptor limits.

Kernel parameters like `kernel.pid_max` control system-wide resource allocation. Process accounting and audit systems track resource usage and provide intrusion detection capabilities.

**Authentication and Authorization** Strong password policies through PAM modules enforce complexity requirements, history restrictions, and account lockout policies. Multi-factor authentication adds security layers beyond password-only access.

Sudo configuration should grant minimal necessary privileges rather than full root access. Role-based access control (RBAC) systems provide more granular privilege delegation than traditional Unix permissions.

### Security Updates

Regular security updates patch vulnerabilities and maintain system security posture against evolving threats.

**Update Mechanisms** Automated update systems like `unattended-upgrades` (Debian/Ubuntu) or `yum-cron` (Red Hat) can install security updates automatically. Configuration options control update timing, reboot behavior, and notification settings.

Manual update processes provide more control but require consistent execution. Commands like `apt update && apt upgrade` or `yum update` install available updates after reviewing changes.

**Update Classification** Security updates address vulnerabilities with Common Vulnerabilities and Exposures (CVE) identifiers. Critical updates should be prioritized and may require immediate installation regardless of maintenance windows.

Package repositories separate security updates from general updates, allowing selective installation of security fixes without other package changes. This approach minimizes risk of introducing new bugs while maintaining security.

**Testing and Rollback** Staging environments should test updates before production deployment, particularly for critical systems. Automated testing can verify application functionality after update installation.

Rollback procedures enable recovery from problematic updates. Package managers provide downgrade capabilities, while system snapshots or backups enable complete system restoration.

Configuration management tools like Ansible, Puppet, or Chef can automate update deployment while maintaining consistency across multiple systems.

**Vulnerability Management** Vulnerability scanners like OpenVAS, Nessus, or distribution-specific tools identify systems requiring security updates. Regular scanning schedules ensure timely identification of security issues.

Vulnerability databases and security advisories provide information about threat severity, exploitation methods, and mitigation strategies. Subscription to distribution security mailing lists ensures awareness of new vulnerabilities.

**Key points:**

- Service minimization reduces attack surface by disabling unnecessary daemons and network services
- Package removal eliminates unused software that could contain vulnerabilities
- Secure configuration applies hardening settings across file systems, networking, and authentication
- Regular security updates patch known vulnerabilities and maintain protection against emerging threats
- Testing and rollback procedures ensure updates don't compromise system stability

---

