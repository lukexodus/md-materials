## Access Control


### Mandatory Access Control (MAC)

Mandatory Access Control represents a security paradigm where access permissions are determined by system-wide policies rather than individual user discretion. Unlike Discretionary Access Control (DAC), where file owners can modify permissions, MAC systems enforce centralized security policies that users cannot override.

MAC implementations assign security labels to subjects (processes) and objects (files, network ports, devices). The system kernel enforces access decisions based on these labels and predefined policy rules. This approach prevents privilege escalation attacks that exploit DAC weaknesses, such as users modifying file permissions to grant unauthorized access.

Security labels typically include classifications like confidentiality levels, integrity levels, and categories or compartments. The Bell-LaPadula model focuses on confidentiality by preventing information flow from higher to lower classification levels. The Biba model addresses integrity by preventing corruption through controlled information flow from lower to higher integrity levels.

MAC systems provide several security advantages over traditional DAC models. They prevent Trojan horse attacks where malicious programs execute with user privileges to access sensitive data. Information flow controls limit data leakage between security domains. Centralized policy management ensures consistent security enforcement across the entire system.

### SELinux Basics

Security-Enhanced Linux (SELinux) was developed by the National Security Agency as a MAC implementation for Linux systems. SELinux uses a type enforcement model where every process runs in a specific security context and every system object has an assigned security context.

#### SELinux Architecture

The SELinux architecture consists of three main components: the SELinux kernel module, the security policy, and userspace utilities. The kernel module intercepts system calls and makes access control decisions based on the loaded policy. The policy defines rules governing interactions between different security contexts.

Security contexts in SELinux follow the format `user:role:type:level`. The user component identifies the SELinux user (distinct from Linux users). The role defines what the user can do. The type (or domain for processes) specifies the security domain. The level component supports Multi-Level Security (MLS) and Multi-Category Security (MCS) configurations.

#### SELinux Operating Modes

SELinux operates in three modes: Enforcing, Permissive, and Disabled. In Enforcing mode, SELinux actively blocks unauthorized actions and logs violations. Permissive mode logs policy violations without blocking actions, useful for policy development and testing. Disabled mode completely turns off SELinux functionality.

#### Policy Types

SELinux supports multiple policy types. The targeted policy protects specific network daemons while allowing most user processes to run unconfined. The strict policy confines all processes, providing maximum security at the cost of complexity. The MLS policy adds multi-level security features for environments requiring classification-based access controls.

#### Common SELinux Tools

The `sestatus` command displays current SELinux status and policy information. The `getenforce` and `setenforce` commands check and modify the current enforcement mode. The `ls -Z` and `ps -Z` commands display security contexts for files and processes. The `setsebool` command modifies policy boolean values to adjust behavior without recompiling policies.

Boolean variables in SELinux policies allow runtime policy modifications. For example, the `httpd_can_network_connect` boolean controls whether Apache can make network connections. The `getsebool -a` command lists all available booleans and their current states.

### AppArmor Introduction

AppArmor (Application Armor) provides MAC functionality through pathname-based access controls. Unlike SELinux's label-based approach, AppArmor uses file paths to define access permissions, making it conceptually simpler for many administrators to understand and manage.

#### AppArmor Architecture

AppArmor profiles define security policies for individual applications. These profiles specify which files an application can access, what network operations it can perform, and what system capabilities it requires. Profiles are loaded into the kernel and enforced through the Linux Security Module (LSM) framework.

Profiles operate in two modes: enforcement and complain. Enforcement mode actively blocks unauthorized actions, while complain mode logs violations without preventing them. This approach facilitates profile development and testing.

#### Profile Development

AppArmor profiles are written in a human-readable syntax that specifies file access permissions, network access rules, and capability requirements. File access rules use glob patterns to match pathnames, with permissions including read (r), write (w), execute (x), and others.

The `aa-genprof` utility assists in profile creation by monitoring application behavior and suggesting appropriate permissions. The `aa-logprof` tool helps refine profiles by analyzing log entries and recommending policy adjustments.

#### AppArmor Management

The `aa-status` command displays the current status of AppArmor and loaded profiles. The `aa-enforce` and `aa-complain` commands switch profiles between enforcement and complain modes. Profile management involves editing text files in `/etc/apparmor.d/` and reloading them with `apparmor_parser`.

AppArmor includes pre-built profiles for common applications like web browsers, mail clients, and network services. These profiles provide immediate protection while serving as templates for custom applications.

### Access Control Policies

#### Policy Design Principles

Effective access control policies follow several key principles. The principle of least privilege ensures subjects receive only the minimum permissions necessary for legitimate functions. Need-to-know restrictions limit information access to those requiring it for their duties. Separation of duties prevents any single individual from having excessive control over critical operations.

Policy clarity requires that access rules be unambiguous and verifiable. Complex policies with unclear interactions increase the risk of configuration errors and security gaps. Regular policy reviews identify obsolete permissions and ensure continued alignment with organizational requirements.

#### Policy Implementation Strategies

Role-Based Access Control (RBAC) simplifies policy management by grouping permissions into roles assigned to users. This approach reduces administrative overhead and improves consistency compared to managing individual user permissions. [Inference] RBAC works well in organizations with stable job functions and clear role definitions.

Attribute-Based Access Control (ABAC) makes access decisions based on attributes of subjects, objects, and environmental conditions. This flexible approach supports complex policies but requires careful design to avoid performance impacts and policy conflicts.

#### Policy Testing and Validation

Policy testing should occur in isolated environments that replicate production conditions without risking operational systems. Automated testing tools can verify that policies enforce intended restrictions while allowing legitimate operations. [Inference] Comprehensive testing reduces the risk of policy-related outages when deploying to production systems.

Policy validation involves both technical verification and compliance auditing. Technical verification ensures policies function as designed and don't conflict with system requirements. Compliance auditing confirms policies meet regulatory requirements and organizational standards.

#### Policy Maintenance

Access control policies require ongoing maintenance to remain effective. Regular reviews should identify obsolete rules, verify continued business justification for permissions, and update policies to address new threats or requirements. Change management processes ensure policy modifications are properly tested and documented.

Monitoring and logging provide visibility into policy effectiveness and identify potential issues. Access logs help detect unauthorized activities, policy violations, and legitimate requests blocked by overly restrictive rules. [Inference] Effective logging strategies balance security monitoring needs with storage costs and privacy considerations.

**Key points:**

- MAC systems enforce centralized security policies that users cannot override, preventing many privilege escalation attacks
- SELinux uses type enforcement with security contexts while AppArmor uses pathname-based controls for simpler management
- Effective policies follow least privilege principles and require regular testing, validation, and maintenance
- Policy implementation strategies include RBAC for role-based management and ABAC for attribute-based decisions

**Example:** A web server profile in AppArmor might include:

```
/usr/sbin/apache2 {
  #include <abstractions/apache2-common>
  capability dac_override,
  capability setuid,
  /var/www/html/** r,
  /var/log/apache2/* w,
  /etc/apache2/** r,
}
```

**Important related topics:** Linux capabilities system, container security models, access control auditing tools, integration with identity management systems, and performance considerations for MAC implementations.

---

