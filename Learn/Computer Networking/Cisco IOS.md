# Syllabus

## Module 1: Foundations

- Cisco IOS overview and architecture
- Device types (routers, switches, ASAs)
- Boot sequence and IOS image management
- CLI basics and navigation
- Command modes (user EXEC, privileged EXEC, global configuration)
- Context-sensitive help and command completion
- Configuration file structure (startup-config, running-config)
- Basic device hardening and passwords

## Module 2: Device Management

- Hostname and banner configuration
- Password encryption and privilege levels
- Console, VTY, and AUX line configuration
- SSH and Telnet access
- CDP (Cisco Discovery Protocol) and LLDP
- System logging and syslog
- NTP (Network Time Protocol)
- IOS licensing models
- Software upgrade procedures
- Configuration backup and restoration
- TFTP, FTP, and SCP file transfers

## Module 3: Interface Configuration

- Interface types and naming conventions
- Interface configuration modes
- IP addressing (IPv4 and IPv6)
- Interface descriptions
- Speed and duplex settings
- Loopback interfaces
- Interface status verification
- Shutdown and no shutdown commands

## Module 4: Switch Fundamentals

- Layer 2 switching concepts
- MAC address table
- Switch port modes (access, trunk, dynamic)
- Port security
- VLAN configuration and assignment
- VLAN Trunking Protocol (VTP)
- Inter-VLAN routing
- Switch virtual interfaces (SVIs)

## Module 5: Spanning Tree Protocol

- STP fundamentals and operation
- PVST+ (Per-VLAN Spanning Tree Plus)
- Rapid PVST+
- Root bridge election
- Port roles and states
- PortFast and BPDU Guard
- STP tuning and optimization
- Multiple Spanning Tree (MST)

## Module 6: EtherChannel

- EtherChannel concepts
- PAgP (Port Aggregation Protocol)
- LACP (Link Aggregation Control Protocol)
- Layer 2 and Layer 3 EtherChannel
- Load balancing methods
- EtherChannel troubleshooting

## Module 7: Routing Fundamentals

- Routing table structure
- Static routing configuration
- Default routes
- Administrative distance
- Route summarization
- Floating static routes
- IPv4 and IPv6 routing differences

## Module 8: Dynamic Routing - RIP

- RIP version 1 and 2
- RIP configuration and verification
- RIP timers and metrics
- RIP authentication
- RIPng for IPv6

## Module 9: Dynamic Routing - EIGRP

- EIGRP overview and features
- EIGRP metric calculation
- Neighbor relationships
- EIGRP configuration (classic and named mode)
- Feasible successors and topology table
- EIGRP authentication
- Stub routing
- EIGRP for IPv6

## Module 10: Dynamic Routing - OSPF

- OSPF fundamentals and areas
- OSPF network types
- Router ID selection
- Neighbor adjacencies and DR/BDR election
- OSPF configuration (single-area and multi-area)
- LSA types
- OSPF authentication
- OSPF route summarization
- Virtual links
- OSPFv3 for IPv6

## Module 11: Dynamic Routing - BGP

- BGP overview and use cases
- eBGP and iBGP
- BGP neighbor relationships
- BGP attributes and path selection
- BGP configuration basics
- Route filtering and route maps
- BGP communities
- BGP confederation and route reflection

## Module 12: Access Control Lists (ACLs)

- Standard ACLs
- Extended ACLs
- Named ACLs
- ACL wildcard masks
- ACL placement best practices
- Time-based ACLs
- IPv6 ACLs
- ACL troubleshooting and verification

## Module 13: Network Address Translation (NAT)

- NAT concepts and terminology
- Static NAT
- Dynamic NAT
- PAT (Port Address Translation / NAT overload)
- NAT verification and troubleshooting
- IPv6 NAT (NAT64)

## Module 14: DHCP and DNS

- DHCP server configuration
- DHCP relay agent
- DHCP snooping
- DHCP verification
- DNS client configuration
- DNS troubleshooting

## Module 15: First Hop Redundancy Protocols

- HSRP (Hot Standby Router Protocol)
- VRRP (Virtual Router Redundancy Protocol)
- GLBP (Gateway Load Balancing Protocol)
- Active/standby and load balancing concepts
- Preemption and priority
- Interface tracking

## Module 16: Quality of Service (QoS)

- QoS fundamentals and models
- Classification and marking (DSCP, CoS, IP Precedence)
- Policing and shaping
- Queuing mechanisms (FIFO, WFQ, CBWFQ, LLQ)
- Congestion avoidance (WRED)
- QoS verification and monitoring

## Module 17: WAN Technologies

- HDLC and PPP
- PPP authentication (PAP, CHAP)
- Frame Relay basics
- PPPoE configuration
- GRE tunnels
- DMVPN fundamentals

## Module 18: VPN Technologies

- IPsec fundamentals
- Site-to-site VPN configuration
- IKEv1 and IKEv2
- Crypto maps and tunnel protection
- Remote access VPN basics
- SSL VPN overview

## Module 19: IPv6

- IPv6 addressing and notation
- IPv6 address types (global unicast, link-local, multicast)
- EUI-64 address generation
- IPv6 SLAAC and DHCPv6
- ICMPv6 and Neighbor Discovery Protocol
- Dual-stack configuration
- IPv6 tunneling mechanisms
- IPv6 routing protocols (RIPng, EIGRPv6, OSPFv3, BGP4+)

## Module 20: Network Security Features

- AAA (Authentication, Authorization, Accounting)
- TACACS+ and RADIUS
- Local authentication and privilege levels
- 802.1X port-based authentication
- IP Source Guard
- Dynamic ARP Inspection (DAI)
- Control Plane Policing (CoPP)
- Secure management practices

## Module 21: Network Services

- SNMP (v2c and v3)
- NetFlow configuration and analysis
- IP SLA (Service Level Agreement)
- Embedded Event Manager (EEM)
- Network Time Protocol (NTP)
- Syslog configuration and management

## Module 22: Wireless LAN Controller (WLC)

- WLC deployment models
- CAPWAP protocol
- Wireless LAN configuration
- SSID and WLAN setup
- Wireless security (WPA2, WPA3)
- Guest access and FlexConnect

## Module 23: SD-WAN and Automation

- Cisco SD-WAN architecture overview
- Viptela components (vManage, vBond, vSmart, vEdge)
- SD-WAN policy configuration basics
- Automation tools introduction (Ansible, Python)
- NETCONF and RESTCONF APIs
- Model-driven programmability (YANG)

## Module 24: Troubleshooting Methodology

- Structured troubleshooting approaches
- Common show commands
- Debug commands and best practices
- Ping and traceroute utilities
- Packet capture techniques
- Baseline documentation
- Change management procedures

## Module 25: Advanced Topics

- Multi-protocol Label Switching (MPLS) basics
- VRF (Virtual Routing and Forwarding)
- VRF-lite configuration
- Policy-based routing (PBR)
- IP Multicast fundamentals
- PIM (Protocol Independent Multicast)
- IGMP configuration
- Cisco IOS-XE and IOS-XR differences

---

# Foundations

## Cisco IOS Overview and Architecture

Cisco IOS (Internetwork Operating System) is a proprietary network operating system that runs on Cisco routers, switches, and other networking devices. It provides the software infrastructure for routing, switching, security, and network management functions. IOS uses a monolithic kernel architecture where all system services run in a single memory space, though modern versions incorporate modularity through features like IOS XE's separation of control and data planes.

The architecture consists of several key layers: the kernel manages hardware resources and memory, the device drivers interface with physical components, the routing and switching engines process network traffic, and the management plane handles configuration and monitoring. IOS operates primarily through a command-line interface (CLI), though web-based management tools are available on some platforms.

## Device Types

**Routers**

Cisco routers forward packets between networks based on Layer 3 (IP) addressing. They examine destination IP addresses, consult routing tables, and determine the best path for data transmission. Routers perform functions including packet forwarding, routing protocol operation (OSPF, EIGRP, BGP), NAT/PAT translation, access control lists (ACLs), quality of service (QoS), VPN termination, and WAN connectivity. Common router platforms include the ISR series (800, 1000, 4000), ASR series for service providers, and older models like 2800/2900 series.

**Switches**

Cisco switches operate primarily at Layer 2, forwarding frames based on MAC addresses within a local network. Multilayer switches (Layer 3 switches) combine switching and routing capabilities, performing inter-VLAN routing and IP forwarding at wire speed. Switch functions include MAC address learning and forwarding, VLAN segmentation, Spanning Tree Protocol (STP) for loop prevention, port security, EtherChannel link aggregation, and Power over Ethernet (PoE) on supported models. Switch families include Catalyst series (2960, 3650, 3850, 9000), Nexus data center switches, and small business models.

**Adaptive Security Appliances (ASAs)**

ASAs are dedicated security devices running a specialized version of IOS called ASA OS (not traditional IOS, but uses similar CLI concepts). They function as stateful firewalls, VPN concentrators, and intrusion prevention systems. ASAs inspect traffic flows, maintain connection state tables, enforce security policies through access lists, provide site-to-site and remote access VPN capabilities, perform application layer inspection, and integrate with identity services. The ASA platform includes 5500-X series and newer Firepower Threat Defense (FTD) appliances.

## Boot Sequence and IOS Image Management

**Boot Sequence**

When a Cisco device powers on, it executes a specific boot sequence:

1. **Power-On Self-Test (POST)**: Hardware diagnostics verify CPU, memory, and interfaces. POST is stored in ROM and executes automatically.
    
2. **Bootstrap Loader**: A small program in ROM initializes the hardware and locates the IOS image. On routers, this is the ROMMON (ROM Monitor) environment.
    
3. **IOS Image Loading**: The bootstrap loader finds and loads the IOS image from flash memory. The location is determined by the boot system commands in the configuration or default flash location.
    
4. **Configuration Loading**: After IOS loads, the device loads the startup-config from NVRAM into running-config in RAM. If no startup-config exists, the device enters setup mode or presents an empty configuration.
    
5. **Normal Operation**: The device becomes operational with the loaded configuration.
    

**IOS Image Management**

IOS images are typically stored in flash memory (flash: or bootflash:). Image files use naming conventions that indicate platform, feature set, and version (e.g., c2900-universalk9-mz.SPA.157-3.M5.bin). The "mz" indicates the image runs from RAM (copied from flash), while "universal" indicates a combined feature set.

Image management commands:

- `show flash:` displays flash contents and available space
- `show version` shows currently running IOS version, uptime, and boot image
- `boot system flash:filename` configures which image to load
- `copy tftp: flash:` transfers new images to the device
- `verify /md5 flash:filename` verifies image integrity
- `delete flash:filename` removes old images to free space

Multiple boot system commands can be configured as fallback options. If the primary image fails, the device attempts subsequent configured images, then the first valid image in flash, and finally ROMMON mode.

## CLI Basics and Navigation

The Cisco CLI is accessed through console cable, SSH, or Telnet connections. Navigation relies on understanding command structure, shortcuts, and editing features.

**Command Structure**

Commands follow a hierarchical syntax: `command keyword [argument]`. Square brackets indicate optional parameters, curly braces with pipes {option1 | option2} indicate required choices, and angle brackets \<value> indicate user-supplied values.

**Navigation Shortcuts**

- `Tab`: Completes partial commands and keywords
- `Ctrl+A`: Moves cursor to beginning of line
- `Ctrl+E`: Moves cursor to end of line
- `Ctrl+W`: Erases word to left of cursor
- `Ctrl+U`: Erases line
- `Ctrl+C`: Exits configuration mode or cancels command
- `Ctrl+Z`: Exits to privileged EXEC mode from any configuration level
- `Ctrl+Shift+6`: Interrupt sequence (stops ping, traceroute, DNS lookup)
- `Up Arrow` or `Ctrl+P`: Recalls previous command
- `Down Arrow` or `Ctrl+N`: Recalls next command in history

**Terminal Settings**

- `terminal length 0`: Disables page breaks (useful for capturing full outputs)
- `terminal length 24`: Sets screen length for pagination
- `terminal history size 256`: Adjusts command history buffer

**Output Filtering**

IOS supports output filtering with pipe operations:

- `show running-config | include hostname`: Shows only lines containing "hostname"
- `show running-config | begin interface`: Displays from first match onward
- `show running-config | section interface`: Shows complete sections matching keyword
- `show ip interface brief | exclude unassigned`: Excludes lines with "unassigned"

## Command Modes

**User EXEC Mode**

Indicated by the `>` prompt (e.g., `Router>`). This is the initial mode upon login, providing limited monitoring commands with no configuration capability. Available commands include ping, traceroute, show commands (limited set), telnet/ssh to other devices, and enable (to enter privileged EXEC). This mode prevents accidental configuration changes and restricts access to sensitive information.

**Privileged EXEC Mode**

Indicated by the `#` prompt (e.g., `Router#`). Accessed from user EXEC mode by typing `enable` and providing the enable password/secret if configured. This mode grants full access to all show commands, configuration modes, debugging commands, file system operations, and device reload/restart commands. Exit to user EXEC mode with `disable` or `exit`.

**Global Configuration Mode**

Indicated by `(config)#` prompt (e.g., `Router(config)#`). Entered from privileged EXEC with `configure terminal` (or `conf t`). This mode allows device-wide configuration settings including hostname, passwords, user accounts, DNS settings, system time, global routing parameters, and access to specific configuration modes. Exit with `exit` (returns to privileged EXEC) or `Ctrl+Z` or `end` (saves and returns to privileged EXEC).

**Specific Configuration Modes**

From global configuration mode, you enter specific configuration contexts:

- **Interface Configuration**: `interface gigabitethernet0/0` produces `(config-if)#` prompt for configuring specific interfaces
- **Line Configuration**: `line console 0` or `line vty 0 4` produces `(config-line)#` for configuring console or virtual terminal lines
- **Router Configuration**: `router ospf 1` produces `(config-router)#` for routing protocol configuration
- **Subinterface Configuration**: `interface gi0/0.10` produces `(config-subif)#` for 802.1Q subinterfaces
- **VLAN Configuration**: `vlan 10` produces `(config-vlan)#` on switches
- **Access List Configuration**: `ip access-list extended ACL_NAME` produces `(config-ext-nacl)#`

Navigation between modes uses `exit` to move up one level, `end` or `Ctrl+Z` to return directly to privileged EXEC, and typing the desired command to move laterally (automatically exits current mode and enters new one).

**ROMMON Mode**

Indicated by `rommon 1 >` prompt. This is a minimal recovery environment accessed during boot interruption (Ctrl+Break during bootup) or when no valid IOS image loads. ROMMON allows manual boot commands, TFTP recovery (tftpdnld on some platforms), password recovery procedures, and basic hardware diagnostics. This mode is critical for disaster recovery scenarios.

## Context-Sensitive Help and Command Completion

**Question Mark Help**

Typing `?` at any point displays available commands or parameters:

- At prompt: `?` shows all available commands in current mode
- After partial command: `sh?` shows commands starting with "sh"
- After command: `show ?` displays available keywords
- After keyword: `show ip ?` shows next available options
- Mid-command: `show inter?` completes to "interface" options

**Tab Completion**

Pressing Tab after entering enough characters to uniquely identify a command completes it automatically. If multiple matches exist, nothing happens until more characters are typed. This accelerates command entry and reduces typos.

**Error Messages**

IOS provides specific error feedback:

- `% Ambiguous command`: Multiple commands match; type more characters
- `% Incomplete command`: Command requires additional parameters
- `% Invalid input detected at '^' marker`: Syntax error at the caret position
- `% Unknown command or computer name`: Command not recognized in current mode

**Command Abbreviation**

Commands can be abbreviated to the shortest unique string: `conf t` for `configure terminal`, `int gi0/0` for `interface gigabitethernet0/0`, `sh ip int br` for `show ip interface brief`. This efficiency is common in production environments but full commands improve documentation clarity.

## Configuration File Structure

**Startup-Config**

The startup-config resides in NVRAM (Non-Volatile RAM), persisting through power cycles and reboots. This file contains the configuration loaded during boot. To view: `show startup-config` from privileged EXEC mode. The startup-config only updates when explicitly saved using `copy running-config startup-config` or `write memory` (or abbreviated `wr`). If not saved, configuration changes are lost on reload.

**Running-Config**

The running-config exists in RAM and represents the currently active configuration. All changes made through the CLI immediately affect the running-config and take effect instantly [Inference: though some features may require additional actions]. View with `show running-config` from privileged EXEC mode. This file is volatile—it disappears on power loss or reload unless saved to startup-config.

**Configuration File Contents**

Configuration files are structured text with hierarchical indentation:

```
version 15.7
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
!
hostname Router1
!
enable secret 5 $1$mERr$hx5rVt7rPNoS4wqbXKX7m0
!
interface GigabitEthernet0/0
 ip address 192.168.1.1 255.255.255.0
 duplex auto
 speed auto
!
ip route 0.0.0.0 0.0.0.0 192.168.1.254
!
line con 0
 logging synchronous
line vty 0 4
 login
 transport input ssh
!
end
```

Exclamation marks (!) serve as section delimiters and comments. Indentation indicates configuration hierarchy—interface commands are indented under the interface declaration.

**Configuration Management Commands**

- `copy running-config startup-config`: Saves current config to NVRAM (also `write` or `wr`)
- `copy startup-config running-config`: Merges startup-config into running-config (additive operation)
- `write erase` or `erase startup-config`: Deletes startup-config from NVRAM
- `reload`: Reboots device (prompts to save if running-config differs from startup-config)
- `show archive`: Displays configuration archive settings
- `copy running-config tftp:`: Backs up configuration to TFTP server
- `copy tftp: running-config`: Restores configuration from TFTP

**Configuration Register**

The configuration register (16-bit value) controls boot behavior. View with `show version` (last line shows register). Common values:

- `0x2102`: Default—boot normally, load startup-config
- `0x2142`: Bypass startup-config (used in password recovery)
- `0x2101`: Boot to ROMMON

Modify with `config-register 0x2102` in global configuration mode (takes effect after reload).

## Basic Device Hardening and Passwords

**Enable Password vs Enable Secret**

Two methods protect privileged EXEC access:

- `enable password PASSWORD`: Older method storing password in cleartext or Type 7 encryption (weak, reversible)
- `enable secret PASSWORD`: Uses MD5 hashing (Type 5), more secure and cannot be easily reversed

If both are configured, enable secret takes precedence. Best practice: use only enable secret.

**Console Line Security**

The console port (physical connection) should be secured:

```
line console 0
 password CONSOLE_PASSWORD
 login
 exec-timeout 5 0
 logging synchronous
```

- `password` sets the console password
- `login` requires password authentication
- `exec-timeout 5 0` logs out after 5 minutes of inactivity (minutes seconds)
- `logging synchronous` prevents log messages from interrupting command entry

**VTY Line Security (Telnet/SSH)**

Virtual terminal lines handle remote connections:

```
line vty 0 4
 password VTY_PASSWORD
 login local
 transport input ssh
 exec-timeout 10 0
 access-class 10 in
```

- `login local` uses local username database instead of simple password
- `transport input ssh` permits only SSH (blocks Telnet for security)
- `access-class 10 in` applies ACL 10 to restrict source IPs

**Local User Accounts**

Creating local users enables individual authentication:

```
username admin privilege 15 secret ADMIN_PASSWORD
username netops privilege 1 secret USER_PASSWORD
```

Privilege levels range 0-15 (15 = full privileged EXEC, 1 = user EXEC). Combined with `login local` on lines, this provides accountable access.

**SSH Configuration**

SSH provides encrypted remote access:

```
hostname Router1
ip domain-name example.com
crypto key generate rsa modulus 2048
ip ssh version 2
ip ssh time-out 60
ip ssh authentication-retries 3
line vty 0 4
 transport input ssh
 login local
```

- Domain name and hostname are required for RSA key generation
- 2048-bit modulus provides strong encryption
- SSH version 2 is more secure than version 1
- Timeout and retry limits prevent brute force attacks

**Service Password Encryption**

`service password-encryption` encrypts Type 7 passwords in the configuration (weak Vigenère cipher, easily cracked). While better than cleartext, it's not strong security. Type 5 (MD5) and Type 8/9 (PBKDF2) are significantly more secure.

**Banner Messages**

Legal banners warn unauthorized users:

```
banner motd #
Authorized Access Only
Unauthorized access is prohibited
#
banner login #
Enter credentials to proceed
#
```

MOT (Message of the Day) displays before login; login banner shows at login prompt. Use delimiters (## in examples) that don't appear in banner text.

**Additional Hardening**

- `no ip domain-lookup`: Prevents accidental DNS lookups from typos (device won't hang trying to resolve mistyped commands)
- `service tcp-keepalives-in`: Terminates dead TCP sessions
- `service tcp-keepalives-out`: Maintains TCP connections
- `no cdp run`: Disables CDP globally if not needed (CDP advertises device information)
- `no ip http server`: Disables HTTP web server if unused
- `ip http secure-server`: Enables HTTPS if web access needed
- `ntp authenticate`: Secures Network Time Protocol
- `logging buffered 51200`: Increases log buffer size

**AAA (Authentication, Authorization, Accounting)**

For enterprise environments, AAA provides centralized security:

```
aaa new-model
aaa authentication login default group tacacs+ local
aaa authorization exec default group tacacs+ local
aaa accounting exec default start-stop group tacacs+
```

This configuration uses TACACS+ server for authentication/authorization, falling back to local accounts if server unavailable, and logs all privileged EXEC sessions.

**Key Points**

- **Never leave default configurations**: Unsecured devices are vulnerable immediately upon network connection
- **Enable secret over enable password**: MD5 hashing provides substantially better protection
- **Use SSH exclusively**: Telnet transmits credentials in cleartext; SSH encrypts all traffic
- **Implement local or AAA authentication**: Simple line passwords lack accountability and granular control
- **Restrict VTY access with ACLs**: Limit administrative access to known management networks
- **Set exec-timeout values**: Prevent abandoned sessions from remaining authenticated indefinitely
- **Disable unused services**: CDP, HTTP server, and other services increase attack surface when unnecessary
- **Regular password rotation**: Update credentials periodically following security policies
- **Document configurations**: Maintain external backups with version control for recovery scenarios

**Related Topics for Comprehensive Cisco IOS Understanding**

To build upon these foundations, consider exploring: interface configuration (IP addressing, descriptions, speed/duplex), VLAN configuration and trunking (802.1Q, VTP), routing protocols (static routes, OSPF, EIGRP, BGP), access control lists (standard, extended, named), NAT/PAT configuration, DHCP server and relay configuration, spanning-tree protocol mechanisms, EtherChannel and port aggregation, Quality of Service (QoS) fundamentals, IPsec VPN configuration, and logging and SNMP monitoring.

---

# Device Management

## Hostname and Banner Configuration

### Hostname Configuration

The hostname identifies a Cisco device on the network and appears in the CLI prompt. It should be descriptive and follow organizational naming conventions.

```
Router> enable
Router# configure terminal
Router(config)# hostname R1
R1(config)#
```

**Key points:**

- Hostname changes take effect immediately
- Must start with a letter
- Can contain letters, digits, and hyphens
- Cannot exceed 63 characters
- Case-sensitive
- Appears in system logs and prompts

### Banner Configuration

Banners display messages to users connecting to the device. Four types exist:

**Message of the Day (MOTD) Banner:**

```
R1(config)# banner motd #
Enter TEXT message. End with the character '#'.
******************************************
* Unauthorized access is prohibited     *
* All access is logged and monitored    *
******************************************
#
R1(config)#
```

**Login Banner:**

```
R1(config)# banner login #
Enter TEXT message. End with the character '#'.
User Access Verification Required
#
```

**EXEC Banner:**

```
R1(config)# banner exec #
Enter TEXT message. End with the character '#'.
Welcome to R1 - Production Router
#
```

**Incoming Banner:**

```
R1(config)# banner incoming #
Enter TEXT message. End with the character '#'.
Reverse Telnet Session
#
```

**Key points:**

- MOTD banner displays before login prompt
- Login banner displays after MOTD, before username/password prompt
- EXEC banner displays after successful login
- Incoming banner displays for reverse Telnet connections
- Use delimiters that don't appear in the banner text
- Legal language in banners can support prosecution of unauthorized access

## Password Encryption and Privilege Levels

### Password Types

**Console Password:**

```
R1(config)# line console 0
R1(config-line)# password cisco123
R1(config-line)# login
```

**Enable Password (Legacy):**

```
R1(config)# enable password cisco123
```

**Enable Secret (Recommended):**

```
R1(config)# enable secret Str0ngP@ss
```

**Key points:**

- Enable secret uses MD5 hashing (Type 5)
- Enable secret takes precedence over enable password
- Enable password stores in plaintext by default
- Never use both enable password and enable secret with the same value

### Password Encryption

**Service Password-Encryption:**

```
R1(config)# service password-encryption
```

This applies Type 7 (Vigenère cipher) encryption to plaintext passwords:

```
R1(config)# do show running-config | include password
enable password 7 0822455D0A16
```

**Key points:**

- Type 7 encryption is weak and easily reversible
- Only encrypts plaintext passwords (Type 0)
- Does not re-encrypt already encrypted passwords
- Does not affect enable secret (Type 5) or Type 8/9 passwords
- Applied to: console, VTY, AUX passwords, and enable password

**Type 8 and Type 9 Encryption:**

```
R1(config)# enable algorithm-type scrypt secret Str0ngP@ss
```

**Output:**

```
R1# show running-config | include enable
enable secret 9 $9$XnKE8vGnEH2KvE$7qKJHKLmnP4RSXvH9KvLnP2QsE
```

**Key points:**

- Type 8 uses PBKDF2-HMAC-SHA256
- Type 9 uses scrypt (strongest, recommended for new configurations)
- Requires IOS 15.3(3)M or later
- Cannot be decrypted (one-way hash)

### Privilege Levels

Cisco IOS supports 16 privilege levels (0-15):

**Default Levels:**

- Level 0: Predefined for minimal access (disable, enable, exit, help, logout)
- Level 1: User EXEC mode (default unprivileged level)
- Level 15: Privileged EXEC mode (enable mode)
- Levels 2-14: Custom privilege levels

**Creating Custom Privilege Levels:**

```
R1(config)# privilege exec level 5 show running-config
R1(config)# privilege exec level 5 configure terminal
R1(config)# privilege configure level 5 interface
R1(config)# privilege interface level 5 ip address
R1(config)# privilege interface level 5 shutdown
R1(config)# privilege interface level 5 no shutdown
```

**Configuring User with Privilege Level:**

```
R1(config)# username admin privilege 15 secret Admin@123
R1(config)# username operator privilege 5 secret Oper@123
R1(config)# username monitor privilege 1 secret Mon@123
```

**Enabling Specific Privilege Level:**

```
R1> enable 5
Password: 
R1#
```

**Setting Enable Password per Level:**

```
R1(config)# enable secret level 5 Level5P@ss
R1(config)# enable secret level 10 Level10P@ss
```

**Verification:**

```
R1# show privilege
Current privilege level is 15

R1# show running-config | section username
username monitor privilege 1 secret 9 $9$1L6E2vGmEH3KuE$7qK...
username operator privilege 5 secret 9 $9$2M7F3wHnFI4LvF$8rL...
username admin privilege 15 secret 9 $9$3N8G4xIoGJ5MwG$9sM...
```

**Key points:**

- Commands assigned to lower privilege levels automatically available to higher levels
- Privilege level 0 cannot be customized
- Must configure commands at multiple configuration levels for full functionality
- Use `show privilege` to verify current level
- Custom levels provide granular access control without AAA

## Console, VTY, and AUX Line Configuration

### Console Line Configuration

The console port provides local administrative access:

```
R1(config)# line console 0
R1(config-line)# password Cons0le@123
R1(config-line)# login
R1(config-line)# logging synchronous
R1(config-line)# exec-timeout 5 30
R1(config-line)# history size 100
```

**With Local Username Authentication:**

```
R1(config)# username admin privilege 15 secret Admin@123
R1(config)# line console 0
R1(config-line)# login local
R1(config-line)# logging synchronous
R1(config-line)# exec-timeout 10 0
```

**Key points:**

- `login` requires password configured with `password` command
- `login local` uses local username database
- `logging synchronous` prevents log messages from interrupting commands
- `exec-timeout minutes seconds` sets idle timeout (0 0 = never timeout)
- `history size` configures command history buffer
- Only one console line exists: line console 0

### VTY Line Configuration

VTY (Virtual Teletype) lines handle remote access via Telnet and SSH:

```
R1(config)# line vty 0 4
R1(config-line)# password VTY@123
R1(config-line)# login
R1(config-line)# exec-timeout 15 0
R1(config-line)# logging synchronous
R1(config-line)# transport input telnet ssh
```

**With Access Control:**

```
R1(config)# access-list 10 permit 192.168.1.0 0.0.0.255
R1(config)# access-list 10 permit 10.10.10.0 0.0.0.255
R1(config)# access-list 10 deny any log
R1(config)# 
R1(config)# line vty 0 4
R1(config-line)# access-class 10 in
R1(config-line)# login local
R1(config-line)# transport input ssh
```

**Extended VTY Lines:**

```
R1(config)# line vty 0 15
R1(config-line)# login local
R1(config-line)# transport input ssh
```

**Key points:**

- Default VTY lines: 0-4 (5 concurrent sessions)
- Can extend to 0-15 or higher depending on platform
- `transport input` controls allowed protocols (telnet, ssh, all, none)
- `access-class` applies ACL to VTY access
- `login local` recommended over simple password
- Configure all VTY lines identically for consistency

### AUX Line Configuration

The auxiliary port supports modem connections and out-of-band management:

```
R1(config)# line aux 0
R1(config-line)# password AUX@123
R1(config-line)# login
R1(config-line)# exec-timeout 5 0
R1(config-line)# transport input telnet
R1(config-line)# no exec
```

**For Modem Connection:**

```
R1(config)# line aux 0
R1(config-line)# login local
R1(config-line)# modem InOut
R1(config-line)# transport input all
R1(config-line)# flowcontrol hardware
R1(config-line)# speed 115200
```

**Key points:**

- AUX port rarely used in modern networks
- Security risk if not properly configured
- Use `no exec` to disable EXEC shell if not needed
- Only one AUX line: line aux 0
- Consider disabling if not in use: `transport input none`

### Common Line Configuration Parameters

```
R1(config-line)# exec-timeout 10 0
R1(config-line)# logging synchronous
R1(config-line)# history size 50
R1(config-line)# session-timeout 30
R1(config-line)# absolute-timeout 60
R1(config-line)# login block-for 120 attempts 3 within 60
R1(config-line)# login on-failure log
R1(config-line)# login on-success log
```

**Key points:**

- `session-timeout` disconnects after specified minutes of connectivity
- `absolute-timeout` disconnects after specified minutes regardless of activity
- `login block-for` implements login failure rate-limiting
- Apply consistent security settings across all line types

## SSH and Telnet Access

### Telnet Configuration

Telnet provides unencrypted remote access (not recommended for production):

```
R1(config)# hostname R1
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# ip address 192.168.1.1 255.255.255.0
R1(config-if)# no shutdown
R1(config-if)# exit
R1(config)#
R1(config)# line vty 0 4
R1(config-line)# password Telnet@123
R1(config-line)# login
R1(config-line)# transport input telnet
```

**Testing Telnet:**

```
PC> telnet 192.168.1.1
Trying 192.168.1.1 ... Open

User Access Verification

Password: 
R1>
```

**Key points:**

- Transmits credentials in plaintext
- Should only be used in isolated lab environments
- Blocked by many security policies
- No encryption of session data
- Use SSH instead for production networks

### SSH Configuration

SSH provides encrypted remote access and authentication.

**Prerequisites:**

- Hostname configured
- Domain name configured
- RSA key pair generated
- Local user accounts or AAA configured
- IOS image with cryptographic features (k9)

**SSH Version 2 Configuration:**

```
R1(config)# hostname R1
R1(config)# ip domain-name example.com
R1(config)# crypto key generate rsa modulus 2048
The name for the keys will be: R1.example.com
% The key modulus size is 2048 bits
% Generating 2048 bit RSA keys, keys will be non-exportable...
[OK] (elapsed time was 1 seconds)

R1(config)# ip ssh version 2
R1(config)# ip ssh time-out 60
R1(config)# ip ssh authentication-retries 3
R1(config)# 
R1(config)# username admin privilege 15 secret Admin@SSH123
R1(config)# 
R1(config)# line vty 0 4
R1(config-line)# login local
R1(config-line)# transport input ssh
R1(config-line)# exit
```

**Verification:**

```
R1# show ip ssh
SSH Enabled - version 2.0
Authentication timeout: 60 secs; Authentication retries: 3
Minimum expected Diffie Hellman key size : 1024 bits
IOS Keys in SECSH format(ssh-rsa, base64 encoded):
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC8...

R1# show ssh
Connection Version Mode Encryption  Hmac         State           Username
0          2.0     IN   aes128-cbc  hmac-sha1    Session started admin
0          2.0     OUT  aes128-cbc  hmac-sha1    Session started admin

R1# show crypto key mypubkey rsa
% Key pair was generated at: 10:25:30 UTC Jan 15 2025
Key name: R1.example.com
 Storage Device: not specified
 Usage: General Purpose Key
 Key is not exportable.
 Key Data:
  30819F30 0D06092A 864886F7 0D010101 05000381 8D003081 89028181 00BC...
% Key pair was generated at: 10:25:30 UTC Jan 15 2025
Key name: R1.example.com.server
 Temporary key
 Usage: Encryption Key
 Key is not exportable.
 Key Data:
  307C300D 06092A86 4886F70D 01010105 00036B00 30680261 00D4E8F3 C2B9...
```

**Configuring SSH with Stronger Parameters:**

```
R1(config)# ip ssh version 2
R1(config)# ip ssh dh min size 2048
R1(config)# ip ssh server algorithm encryption aes256-ctr aes192-ctr aes128-ctr
R1(config)# ip ssh server algorithm mac hmac-sha2-256 hmac-sha2-512
R1(config)# ip ssh server algorithm kex diffie-hellman-group14-sha1
```

**SSH Client Usage:**

```
R2# ssh -l admin 192.168.1.1
Password: 

R1>
```

**Alternative SSH Client Syntax:**

```
R2# ssh -v 2 -c aes256-ctr admin@192.168.1.1
```

**Key points:**

- RSA key modulus minimum: 1024 bits (2048+ recommended)
- SSH version 2 is more secure than version 1
- Domain name required for RSA key generation
- Keys named: `hostname.domain-name`
- `transport input ssh` disables Telnet
- Delete keys: `crypto key zeroize rsa`
- Regenerate keys after hostname or domain change
- IOS image must support cryptography (k9 designation)

### SSH Public Key Authentication

**Generating User Keys (on client):**

```
client$ ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Your identification has been saved in /home/user/.ssh/id_rsa.
Your public key has been saved in /home/user/.ssh/id_rsa.pub.
```

**Configuring Router for Public Key Authentication:**

```
R1(config)# ip ssh pubkey-chain
R1(conf-ssh-pubkey)# username admin
R1(conf-ssh-pubkey-user)# key-string
R1(conf-ssh-pubkey-data)# AAAAB3NzaC1yc2EAAAADAQABAAABAQC8...
R1(conf-ssh-pubkey-data)# exit
R1(conf-ssh-pubkey-user)# exit
R1(conf-ssh-pubkey)# exit
```

**Key points:**

- Public key authentication more secure than passwords
- User still needs entry in local database
- Can combine with password authentication
- Supports RSA and DSA key types

## CDP (Cisco Discovery Protocol) and LLDP

### Cisco Discovery Protocol (CDP)

CDP is a Cisco proprietary Layer 2 protocol for discovering directly connected Cisco devices.

**CDP Global Configuration:**

```
R1(config)# cdp run                    ! Enable CDP globally
R1(config)# cdp timer 60               ! Advertisement interval (default: 60 seconds)
R1(config)# cdp holdtime 180           ! Hold time (default: 180 seconds)
R1(config)# cdp advertise-v2           ! Enable CDPv2
```

**CDP Interface Configuration:**

```
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# cdp enable              ! Enable CDP on interface
R1(config-if)# no cdp enable           ! Disable CDP on interface
```

**CDP Verification Commands:**

```
R1# show cdp
Global CDP information:
    Sending CDP packets every 60 seconds
    Sending a holdtime value of 180 seconds
    Sending CDPv2 advertisements is enabled

R1# show cdp neighbors
Capability Codes: R - Router, T - Trans Bridge, B - Source Route Bridge
                  S - Switch, H - Host, I - IGMP, r - Repeater, P - Phone,
                  D - Remote, C - CVTA, M - Two-port Mac Relay

Device ID        Local Intrfce     Holdtme    Capability  Platform  Port ID
SW1              Gig 0/0           165        S I         WS-C2960  Gig 0/1
R2               Gig 0/1           155        R S I       ISR4321   Gig 0/0

Total cdp entries displayed : 2

R1# show cdp neighbors detail
-------------------------
Device ID: SW1
Entry address(es): 
  IP address: 192.168.1.10
Platform: cisco WS-C2960-24TT-L,  Capabilities: Switch IGMP 
Interface: GigabitEthernet0/0,  Port ID (outgoing port): GigabitEthernet0/1
Holdtime : 165 sec

Version :
Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(2)SE11
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.

advertisement version: 2
Protocol Hello:  OUI=0x00000C, Protocol ID=0x0112; payload len=27
VTP Management Domain: ''
Native VLAN: 1
Duplex: full
Management address(es): 
  IP address: 192.168.1.10

-------------------------
Device ID: R2
Entry address(es): 
  IP address: 10.1.1.2
Platform: Cisco ISR4321/K9,  Capabilities: Router Switch IGMP 
Interface: GigabitEthernet0/1,  Port ID (outgoing port): GigabitEthernet0/0
Holdtime : 155 sec

Version :
Cisco IOS Software [Fuji], ISR Software (X86_64_LINUX_IOSD-UNIVERSALK9-M)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.

advertisement version: 2
VTP Management Domain: ''
Duplex: full
Management address(es): 
  IP address: 10.1.1.2

Total cdp entries displayed : 2

R1# show cdp entry R2
-------------------------
Device ID: R2
Entry address(es): 
  IP address: 10.1.1.2
Platform: Cisco ISR4321/K9,  Capabilities: Router Switch IGMP 
Interface: GigabitEthernet0/1,  Port ID (outgoing port): GigabitEthernet0/0
Holdtime : 150 sec
...

R1# show cdp interface
GigabitEthernet0/0 is up, line protocol is up
  Encapsulation ARPA
  Sending CDP packets every 60 seconds
  Holdtime is 180 seconds
GigabitEthernet0/1 is up, line protocol is up
  Encapsulation ARPA
  Sending CDP packets every 60 seconds
  Holdtime is 180 seconds

R1# show cdp traffic
CDP counters :
    Total packets output: 245, Input: 198
    Hdr syntax: 0, Chksum error: 0, Encaps failed: 0
    No memory: 0, Invalid packet: 0, 
    CDP version 1 advertisements output: 0, Input: 0
    CDP version 2 advertisements output: 245, Input: 198
```

**Clearing CDP Table:**

```
R1# clear cdp table
R1# clear cdp counters
```

**Key points:**

- Operates at Layer 2 (data link layer)
- Multicast address: 0100.0CCC.CCCC
- Discovers only directly connected Cisco devices
- Transmits device type, IOS version, IP addresses, platform
- Security risk: reveals network topology information
- Should be disabled on interfaces facing untrusted networks
- CDPv2 adds additional information (Native VLAN, duplex)

**Security Best Practice:**

```
R1(config)# no cdp run                                    ! Disable globally
! OR
R1(config)# interface range gigabitEthernet 0/0 - 1
R1(config-if-range)# no cdp enable                        ! Disable per interface
```

### Link Layer Discovery Protocol (LLDP)

LLDP is an IEEE 802.1AB standard protocol for vendor-neutral device discovery.

**LLDP Global Configuration:**

```
R1(config)# lldp run                              ! Enable LLDP globally
R1(config)# lldp timer 30                         ! Advertisement interval (default: 30 seconds)
R1(config)# lldp holdtime 120                     ! Hold time (default: 120 seconds)
R1(config)# lldp reinit 2                         ! Delay before re-init (default: 2 seconds)
```

**LLDP Interface Configuration:**

```
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# lldp transmit                      ! Enable LLDP transmission
R1(config-if)# lldp receive                       ! Enable LLDP reception
R1(config-if)# no lldp transmit                   ! Disable transmission
R1(config-if)# no lldp receive                    ! Disable reception
```

**LLDP Verification Commands:**

```
R1# show lldp
Global LLDP Information:
    Status: ACTIVE
    LLDP advertisements are sent every 30 seconds
    LLDP hold time advertised is 120 seconds
    LLDP interface reinitialisation delay is 2 seconds

R1# show lldp neighbors
Capability codes:
    (R) Router, (B) Bridge, (T) Telephone, (C) DOCSIS Cable Device
    (W) WLAN Access Point, (P) Repeater, (S) Station, (O) Other

Device ID           Local Intf     Hold-time  Capability      Port ID
SW1                 Gi0/0          120        B               Gi0/1
R2                  Gi0/1          120        R               Gi0/0

Total entries displayed: 2

R1# show lldp neighbors detail
------------------------------------------------
Chassis id: aabb.cc00.1000
Port id: Gi0/1
Port Description: GigabitEthernet0/1
System Name: SW1

System Description: 
Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(2)SE11
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.

Time remaining: 115 seconds
System Capabilities: B
Enabled Capabilities: B
Management Addresses:
    IP: 192.168.1.10
Auto Negotiation - supported, enabled
Physical media capabilities:
    1000baseT(FD)
    100base-TX(FD)
    100base-TX(HD)
    10base-T(FD)
    10base-T(HD)
Media Attachment Unit type: 30
Vlan ID: 1

------------------------------------------------
Chassis id: aabb.cc00.2000
Port id: Gi0/0
Port Description: GigabitEthernet0/0
System Name: R2

System Description: 
Cisco IOS Software [Fuji], ISR Software (X86_64_LINUX_IOSD-UNIVERSALK9-M)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.

Time remaining: 110 seconds
System Capabilities: R
Enabled Capabilities: R
Management Addresses:
    IP: 10.1.1.2
Auto Negotiation - supported, enabled
Physical media capabilities:
    1000baseT(FD)
Media Attachment Unit type: 30

Total entries displayed: 2

R1# show lldp entry R2
------------------------------------------------
Chassis id: aabb.cc00.2000
Port id: Gi0/0
Port Description: GigabitEthernet0/0
System Name: R2
...

R1# show lldp interface
GigabitEthernet0/0:
    Tx: enabled
    Rx: enabled
    Tx state: IDLE
    Rx state: WAIT FOR FRAME

GigabitEthernet0/1:
    Tx: enabled
    Rx: enabled
    Tx state: IDLE
    Rx state: WAIT FOR FRAME

R1# show lldp traffic
LLDP traffic statistics:
    Total frames out: 312
    Total entries aged: 0
    Total frames in: 245
    Total frames received in error: 0
    Total frames discarded: 0
    Total TLVs discarded: 0
    Total TLVs unrecognized: 0
```

**Key points:**

- IEEE 802.1AB standard (vendor-neutral)
- Multicast address: 0180.C200.000E
- Discovers multi-vendor network devices
- More widely supported than CDP in heterogeneous environments
- Transmits system name, description, capabilities, management address
- Can coexist with CDP
- Should be disabled on untrusted interfaces
- Separate transmit/receive control per interface

### CDP vs LLDP Comparison

|Feature|CDP|LLDP|
|---|---|---|
|Standard|Cisco proprietary|IEEE 802.1AB|
|Vendor support|Cisco only|Multi-vendor|
|Default interval|60 seconds|30 seconds|
|Default holdtime|180 seconds|120 seconds|
|Multicast MAC|0100.0CCC.CCCC|0180.C200.000E|
|Default state|Enabled (on Cisco)|Disabled|

## System Logging and Syslog

### Logging Destinations

Cisco IOS supports multiple logging destinations:

**Console Logging:**

```
R1(config)# logging console                       ! Enable console logging
R1(config)# logging console informational         ! Set level
R1(config)# no logging console                    ! Disable console logging
```

**Monitor (VTY) Logging:**

```
R1(config)# logging monitor warnings              ! Set monitor level
R1# terminal monitor                               ! Enable for current session
R1# terminal no monitor                            ! Disable for current session
```

**Buffered Logging:**

```
R1(config)# logging buffered 16384                ! Set buffer size (bytes)
R1(config)# logging buffered debugging            ! Set level
R1# show logging                                   ! View buffered logs
R1# clear logging                                  ! Clear log buffer
```

**Syslog Server:**

```
R1(config)# logging host 192.168.1.100            ! Syslog server IP
R1(config)# logging host 192.168.1.100 transport udp port 514
R1(config)# logging trap notifications            ! Set level for syslog
R1(config)# logging source-interface loopback 0   ! Source interface
R1(config)# logging facility local5               ! Facility code
```

### Logging Severity Levels

|Level|Keyword|Description|Example|
|---|---|---|---|
|0|emergencies|System unusable|Device shutdown|
|1|alerts|Immediate action needed|Temperature critical|
|2|critical|Critical conditions|Hardware failure|
|3|errors|Error conditions|Interface down|
|4|warnings|Warning conditions|Configuration change|
|5|notifications|Normal but significant|Line protocol up/down|
|6|informational|Informational messages|ACL match|
|7|debugging|Debug messages|Packet details|

**Key points:**

- Configuring a level includes all higher severity levels
- Level 7 (debugging) includes all messages
- Level 0 (emergencies) includes only emergencies

**Setting Logging Levels:**

```
R1(config)# logging console warnings              ! Levels 0-4 to console
R1(config)# logging monitor notifications         ! Levels 0-5 to monitor
R1(config)# logging buffered informational        ! Levels 0-6 to buffer
R1(config)# logging trap errors                   ! Levels 0-3 to syslog
```

### Syslog Message Format

**Standard Format:**

```
%FACILITY-SEVERITY-MNEMONIC: Message-text
```

**Example:**

```
%LINK-3-UPDOWN: Interface GigabitEthernet0/0, changed state to down
%LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet0/0, changed state to down
%SYS-5-CONFIG_I: Configured from console by admin on vty0 (192.168.1.50)
```

**With Timestamps and Sequence Numbers:**

```
R1(config)# service timestamps log datetime msec localtime show-timezone
R1(config)# service timestamps debug datetime msec localtime show-timezone
R1(config)# service sequence-numbers
```

**Output:**

```
000045: Jan 15 2025 14:23:15.234 PST: %LINK-3-UPDOWN: Interface GigabitEthernet0/0, changed state to down
000046: Jan 15 2025 14:23:16.235 PST: %LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet0/0, changed state to down
```

### Advanced Logging Configuration

**Rate Limiting:**

```
R1(config)# logging rate-limit console 10 except errors
R1(config)# logging rate-limit all 100
```

**Discriminator (Filtering):**

```
R1(config)# logging discriminator FILTER facility includes LINEPROTO
R1(config)# logging discriminator NOCDP mnemonics drops CDP
R1(config)# logging console discriminator FILTER
R1(config)# logging host 192.168.1.100 discriminator NOCDP
```

**Logging to Multiple Servers:**

```
R1(config)# logging host 192.168.1.100
R1(config)# logging host 192.168.1.101
R1(config)# logging host 10.10.10.50
```

**Enabling Logging for Specific Features:**

```
R1(config)# logging trap debugging
R1(config)# access-list 100 permit ip any any log
R1(config)# logging on                            ! Enable logging globally
```

### Logging Verification

**Show Logging:**

```
R1# show logging
Syslog logging: enabled (0 messages dropped, 3
messages rate-limited, 0 flushes, 0 overruns, xml disabled, filtering disabled)

No Active Message Discriminator.

No Inactive Message Discriminator.

    Console logging: level warnings, 245 messages logged, xml disabled,
                     filtering disabled
    Monitor logging: level debugging, 0 messages logged, xml disabled,
                     filtering disabled
    Buffer logging:  level informational, 1024 messages logged, xml disabled,
                    filtering disabled
    Exception Logging: size (4096 bytes)
    Count and timestamp logging messages: disabled
    Persistent logging: disabled

No active filter modules.

    Trap logging: level informational, 312 message lines logged
        Logging to 192.168.1.100  (udp port 514, audit disabled,
              link up),
              512 message lines logged, 
              0 message lines rate-limited, 
              0 message lines dropped-by-MD, 
              xml disabled, sequence number disabled
              filtering disabled
        Logging Source-Interface:       VRF Name:

Log Buffer (16384 bytes):

000045: Jan 15 2025 14:23:15.234 PST: %LINK-3-UPDOWN: Interface GigabitEthernet0/0, changed state to down
000046: Jan 15 2025 14:23:16.235 PST: %LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet0/0, changed state to down
000047: Jan 15 2025 14:25:42.156 PST: %SYS-5-CONFIG_I: Configured from console by admin on vty0 (192.168.1.50)
```

**Show Logging History:**
```
R1# show logging history
Syslog History Table: 1 maximum table entries,
                      saving level warnings or higher
45 messages ignored, 0 dropped, 0 recursion drops
    entry number 1 : %LINK-3-UPDOWN
    Interface GigabitEthernet0/0, changed state to down
    timestamp: 245
```

**Debugging Considerations:**
```
R1# debug ip routing
IP routing debugging is on
R1# undebug all                                   ! Disable all debugging
All possible debugging has been turned off
```

**Key points:**
- Debug output uses CPU resources extensively
- Use debugging cautiously on production devices
- Debug output goes to console by default (use `terminal monitor` for VTY)
- Always disable debugging when troubleshooting complete
- `undebug all` or `no debug all` disables all debugging

### Syslog Best Practices

**Recommended Configuration:**
```
R1(config)# service timestamps log datetime msec localtime show-timezone
R1(config)# service timestamps debug datetime msec localtime show-timezone
R1(config)# service sequence-numbers
R1(config)# clock timezone PST -8
R1(config)# clock summer-time PDT recurring
R1(config)# ntp server 192.168.1.200
R1(config)# 
R1(config)# logging buffered 32768 informational
R1(config)# logging console warnings
R1(config)# logging monitor informational
R1(config)# logging trap informational
R1(config)# logging source-interface loopback 0
R1(config)# logging host 192.168.1.100
R1(config)# logging host 192.168.1.101
```

**Key points:**
- Use NTP for accurate timestamps across devices
- Configure timezone and daylight saving time
- Send logs to redundant syslog servers
- Use appropriate severity levels to avoid log flooding
- Enable sequence numbers for log analysis
- Use source-interface for consistent syslog source addresses
- Monitor syslog server storage capacity
- Implement log rotation on syslog servers

## NTP (Network Time Protocol)

### NTP Overview

NTP synchronizes clocks across network devices using a hierarchical stratum system.

**Stratum Levels:**
- Stratum 0: Reference clocks (atomic clocks, GPS)
- Stratum 1: Servers directly connected to stratum 0
- Stratum 2: Servers synchronized to stratum 1
- Stratum 3-15: Each level synchronized to level above
- Stratum 16: Unsynchronized

### NTP Client Configuration

**Basic NTP Client:**
```
R1(config)# ntp server 192.168.1.200
R1(config)# ntp server 192.168.1.201
R1(config)# ntp server 10.10.10.100 prefer
```

**With Source Interface:**
```
R1(config)# interface loopback 0
R1(config-if)# ip address 1.1.1.1 255.255.255.255
R1(config-if)# exit
R1(config)# ntp source loopback 0
R1(config)# ntp server 192.168.1.200
```

**Key points:**
- `prefer` keyword designates preferred NTP server
- Configure multiple NTP servers for redundancy
- Source interface provides consistent source IP
- NTP uses UDP port 123

### NTP Server Configuration

**Configuring Device as NTP Server:**
```
R1(config)# ntp master 3                          ! Stratum 3 server
```

**Key points:**
- Default stratum when using `ntp master`: 8
- Lower stratum number = higher priority
- Should only configure `ntp master` if device has accurate clock source
- Typically used in isolated networks without internet access

### NTP Authentication

**Configuring NTP Authentication:**
```
R1(config)# ntp authenticate
R1(config)# ntp authentication-key 1 md5 NTP@SecretKey123
R1(config)# ntp trusted-key 1
R1(config)# ntp server 192.168.1.200 key 1
```

**On NTP Server:**
```
NTP-Server(config)# ntp authenticate
NTP-Server(config)# ntp authentication-key 1 md5 NTP@SecretKey123
NTP-Server(config)# ntp trusted-key 1
NTP-Server(config)# ntp master 2
```

**Key points:**
- Authentication prevents rogue NTP servers
- All devices must share same key and key number
- Keys are MD5 hashed
- Multiple keys can be configured for key rotation

### NTP Access Control

**Restricting NTP Access:**
```
R1(config)# access-list 10 permit 192.168.1.0 0.0.0.255
R1(config)# access-list 10 permit 10.10.10.0 0.0.0.255
R1(config)# ntp access-group peer 10
```

**NTP Access Group Types:**
```
R1(config)# ntp access-group query-only 10        ! Allow only time queries
R1(config)# ntp access-group serve-only 10        ! Allow time requests
R1(config)# ntp access-group serve 10             ! Allow time requests and queries
R1(config)# ntp access-group peer 10              ! Allow full NTP peering
```

**Key points:**
- `query-only`: Most restrictive, control queries only
- `serve-only`: Allow time synchronization requests
- `serve`: Allow time sync and control queries
- `peer`: Least restrictive, full synchronization
- Apply in order: peer > serve > serve-only > query-only

### NTP Verification

**Show NTP Status:**
```
R1# show ntp status
Clock is synchronized, stratum 3, reference is 192.168.1.200
nominal freq is 250.0000 Hz, actual freq is 249.9995 Hz, precision is 2**18
ntp uptime is 145200 (1/100 of seconds), resolution is 4016
reference time is E4C8A1F2.3D70A3D7 (14:23:46.240 PST Mon Jan 15 2025)
clock offset is -2.5432 msec, root delay is 15.23 msec
root dispersion is 45.67 msec, peer dispersion is 2.34 msec
loopfilter state is 'CTRL' (Normal Controlled Loop), drift is -0.000012345 s/s
system poll interval is 64, last update was 23 sec ago.
```

**Show NTP Associations:**
```
R1# show ntp associations

  address         ref clock       st   when   poll reach  delay  offset   disp
*~192.168.1.200  .GPS.            1     45     64   377  10.23   -2.54   1.25
+~192.168.1.201  .GPS.            1     52     64   377  11.45   -1.87   2.13
 ~10.10.10.100   192.168.1.200    2    102     64   377  25.67   +5.23   3.45
 * sys.peer, # selected, + candidate, - outlyer, x falseticker, ~ configured
```

**Show NTP Associations Detail:**
```
R1# show ntp associations detail
192.168.1.200 configured, our_master, sane, valid, stratum 1
ref ID .GPS., time E4C8A1F2.3D70A3D7 (14:23:46.240 PST Mon Jan 15 2025)
our mode client, peer mode server, our poll intvl 64, peer poll intvl 64
root delay 0.00 msec, root disp 2.34, reach 377, sync dist 12.345
delay 10.23 msec, offset -2.5432 msec, dispersion 1.25
precision 2**6, version 4
org time E4C8A234.5F8C9D2E (14:25:56.373 PST Mon Jan 15 2025)
rec time E4C8A234.60A3B4F1 (14:25:56.377 PST Mon Jan 15 2025)
xmt time E4C8A234.61B2C5D8 (14:25:56.382 PST Mon Jan 15 2025)
filtdelay =    10.23   11.34   10.87   12.01   11.56   10.98   11.23   10.67
filtoffset =   -2.54   -2.89   -2.67   -3.12   -2.78   -2.45   -2.91   -2.56
filterror =     1.25    2.34    3.45    4.56    5.67    6.78    7.89    8.91
```

**Useful Verification Commands:**
```
R1# show ntp status                               ! Overall NTP status
R1# show ntp associations                         ! NTP peer summary
R1# show ntp associations detail                  ! Detailed peer info
R1# show clock                                    ! Current system time
R1# show clock detail                             ! Time source details
```

**Output Examples:**
```
R1# show clock
14:28:34.567 PST Mon Jan 15 2025

R1# show clock detail
14:28:42.123 PST Mon Jan 15 2025
Time source is NTP
```

**Key points:**
- `*` indicates synchronized peer (sys.peer)
- `+` indicates candidate for synchronization
- `-` indicates outlier (rejected)
- `x` indicates falseticker (bad time source)
- `~` indicates configured peer
- `reach` value 377 (octal) = 255 (decimal) = 8 consecutive successful polls
- Synchronization takes several minutes
- Stratum increases by 1 from reference clock

### NTP Peer Configuration

**Configuring NTP Peers (Symmetric Active Mode):**
```
R1(config)# ntp peer 192.168.1.2
R1(config)# ntp peer 192.168.1.3

R2(config)# ntp peer 192.168.1.1
R2(config)# ntp peer 192.168.1.3

R3(config)# ntp peer 192.168.1.1
R3(config)# ntp peer 192.168.1.2
```

**Key points:**
- Peer mode for devices at same stratum level
- Both devices attempt to synchronize with each other
- Provides redundancy in NTP topology
- Used in meshed NTP architectures

### Timezone and Daylight Saving Time

**Configuring Timezone:**
```
R1(config)# clock timezone PST -8                 ! Pacific Standard Time
R1(config)# clock timezone EST -5                 ! Eastern Standard Time
R1(config)# clock timezone UTC 0                  ! Coordinated Universal Time
R1(config)# clock timezone JST 9                  ! Japan Standard Time
```

**Configuring Daylight Saving Time:**
```
R1(config)# clock summer-time PDT recurring       ! US Pacific Daylight Time
R1(config)# clock summer-time EDT recurring       ! US Eastern Daylight Time
```

**Custom Daylight Saving Time:**
```
R1(config)# clock summer-time PDT recurring 2 Sunday March 02:00 1 Sunday November 02:00
```

**Key points:**
- Timezone offset in hours from UTC
- Positive for east of UTC, negative for west
- `recurring` uses built-in DST rules
- Can specify custom DST start/end dates
- Timezone configuration independent of NTP

### Manual Clock Configuration

**Setting Clock Manually (Privileged EXEC):**
```
R1# clock set 14:30:00 15 January 2025
```

**Key points:**
- Format: `clock set hh:mm:ss day month year`
- Manual setting lost after reload without NTP
- Use only for initial configuration or when NTP unavailable
- NTP will override manual setting once synchronized

### NTP Troubleshooting

**Common Issues:**

**Problem: Clock not synchronizing**
```
R1# show ntp status
Clock is unsynchronized, stratum 16, no reference clock
```

**Troubleshooting steps:**
1. Verify NTP server reachability: `ping 192.168.1.200`
2. Check NTP associations: `show ntp associations`
3. Verify reach value (should increase to 377)
4. Check for ACLs blocking UDP 123
5. Verify NTP authentication configuration matches
6. Wait sufficient time (5-10 minutes minimum)

**Problem: High offset or dispersion**
```
R1# show ntp associations
  address         ref clock       st   when   poll reach  delay  offset   disp
*~192.168.1.200  .GPS.            1     12     64   377  10.23  +250.4  45.67
```

**Possible causes:**
- Network latency or jitter
- Incorrect timezone configuration
- Faulty NTP server clock
- Local clock drift

**Debugging NTP:**
```
R1# debug ntp all                                 ! Enable all NTP debugging
R1# debug ntp packets                             ! Debug NTP packets
R1# debug ntp validity                            ! Debug NTP validity checks
R1# debug ntp sync                                ! Debug synchronization
R1# undebug all                                   ! Disable all debugging
```

**Key points:**
- NTP synchronization requires patience (several poll intervals)
- Poll interval increases as clock stability improves
- Initial poll interval: 64 seconds, can increase to 1024 seconds
- Use debug commands cautiously on production devices

## IOS Licensing Models

### License Types

Cisco IOS uses different licensing models depending on platform and IOS version.

**Traditional IOS (Pre-15.0):**
- Feature sets bundled into IOS images
- IP Base, IP Services, Advanced Security, etc.
- License embedded in IOS image filename

**IOS 15.0+ Universal Image:**
- Single universal image contains all features
- Software activation via license keys
- Right-To-Use (RTU) licensing

**IOS-XE:**
- Smart Licensing (cloud-based)
- Traditional license files
- Evaluation mode available

### License Levels (ISR G2 Example)

**Technology Packages:**
- IP Base: Basic routing and switching
- Security: Firewall, VPN, IPS features
- Unified Communications: Voice features
- Data: Advanced routing protocols (EIGRP, OSPF, BGP)

**Example tiers:**
```
ipbasek9      - IP Base with crypto
securityk9    - Security features
datak9        - Data features  
uck9          - Unified Communications
```

### Viewing License Information

**Show License:**
```
R1# show license
Index 1 Feature: ipbasek9
        Period left: Life time
        License Type: Permanent
        License State: Active, In Use
        License Count: Non-Counted
        License Priority: Medium

Index 2 Feature: securityk9
        Period left: 8 weeks 4 days
        Period Used: 0 minute 0 second
        License Type: EvalRightToUse
        License State: Active, In Use
        License Count: Non-Counted
        License Priority: None

Index 3 Feature: datak9
        Period left: Not Activated
        Period Used: 0 minute 0 second
        License Type: EvalRightToUse
        License State: Not in Use, EULA not accepted
        License Count: Non-Counted
        License Priority: None
```

**Show License UDI (Unique Device Identifier):**
```
R1# show license udi
Device#   PID                   SN              UDI
------------------------------------------------------------------
*0        CISCO2901/K9          FTX152400KS     CISCO2901/K9:FTX152400KS
```

**Show Version (includes license info):**
```
R1# show version
Cisco IOS Software, C2900 Software (C2900-UNIVERSALK9-M), Version 15.4(3)M6
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2016 by Cisco Systems, Inc.
Compiled Fri 17-Jun-16 10:08 by prod_rel_team

ROM: System Bootstrap, Version 15.0(1r)M16, RELEASE SOFTWARE (fc1)

R1 uptime is 2 days, 4 hours, 23 minutes
System returned to ROM by reload at 12:34:56 PST Mon Jan 13 2025
System image file is "flash0:c2900-universalk9-mz.SPA.154-3.M6.bin"
Last reload type: Normal Reload
Last reload reason: Reload Command

...

Technology Package License Information for Module:'c2900' 

-----------------------------------------------------------------
Technology    Technology-package           Technology-package
              Current       Type           Next reboot  
------------------------------------------------------------------
ipbase        ipbasek9      Permanent      ipbasek9
security      None          None           None
uc            None          None           None
data          None          None           None

Configuration register is 0x2102
```

**Show License Feature:**
```
R1# show license feature
Feature name             Enforcement  Evaluation  Subscription   Enabled  RightToUse
ipbasek9                 yes          no          no             yes      no
securityk9               yes          yes         no             yes      yes
uck9                     yes          yes         no             no       yes
datak9                   yes          yes         no             no       yes
```

### Installing Licenses

**Installing Permanent License:**
```
R1# license install flash0:FTX152400KS_201501151423.lic
Installing licenses from "flash0:FTX152400KS_201501151423.lic"
Installing...Feature:datak9...Successful:Supported
1/1 licenses were successfully installed
0/1 licenses were existing licenses
0/1 licenses were failed to install
```

**Accepting EULA and Activating Evaluation License:**
```
R1# configure terminal
R1(config)# license accept end user agreement
R1(config)# license boot module c2900 technology-package securityk9
R1(config)# exit
R1# reload
```

**Key points:**
- License files named: `PID_SN_yyyymmddhhmmss.lic`
- Permanent licenses survive reload
- Evaluation licenses expire after 60 days
- Reload required to activate some licenses
- License stored in flash, not in configuration

### Backing Up Licenses

**Saving License to Flash:**
```
R1# license save flash0:all_licenses.lic
License data saved to flash0:all_licenses.lic
```

**Transferring License:**
```
R1# copy flash0:all_licenses.lic tftp:
Address or name of remote host []? 192.168.1.100
Destination filename [all_licenses.lic]? R1_licenses_backup.lic
!
2345 bytes copied in 0.523 secs (4485 bytes/sec)
```

### Removing Licenses

**Clearing License:**
```
R1# license clear securityk9
Clear license feature securityk9? [yes/no]: yes
R1# reload
```

**Disabling License:**
```
R1(config)# no license boot module c2900 technology-package securityk9
R1(config)# exit
R1# reload
```

**Key points:**
- `license clear` removes license from license storage
- `no license boot` prevents license activation at boot
- Reload required for changes to take effect
- Clearing license doesn't delete license file from flash

### Smart Licensing (Modern Platforms)

**Smart Licensing Overview:**
- Cloud-based licensing management
- Centralized through Cisco Smart Software Manager (CSSM)
- No license files required
- Automatic license tracking and reporting

**Smart Licensing Configuration:**
```
R1# configure terminal
R1(config)# license smart enable
R1(config)# license smart url https://smartreceiver.cisco.com/licservice/license
R1(config)# license smart transport smart
```

**Registering Device:**
```
R1# license smart register idtoken \<TOKEN>
*Jan 15 14:35:23.456: %SMART_LIC-6-AGENT_ENABLED: Smart Agent for Licensing is enabled
*Jan 15 14:35:45.789: %SMART_LIC-6-AUTHORIZATION_INSTALL_SUCCESS
```

**Verification:**
```
R1# show license summary
Smart Licensing is ENABLED

Registration:
  Status: REGISTERED
  Smart Account: Example Corp
  Virtual Account: Network Infrastructure
  Export-Controlled Functionality: Allowed
  Initial Registration: SUCCEEDED on Jan 15 14:35:45 2025 PST
  Last Renewal Attempt: None
  Next Renewal Attempt: Jul 14 14:35:45 2025 PST

License Authorization:
  Status: AUTHORIZED on Jan 15 14:35:46 2025 PST
  Last Communication Attempt: SUCCEEDED on Jan 15 14:35:46 2025 PST
  Next Communication Attempt: Jan 16 14:35:46 2025 PST

License Usage:
  License                 Entitlement tag               Count Status
  -----------------------------------------------------------------------------
  network-advantage       (C9300_NW_Advantage)          1     IN USE
  dna-advantage           (C9300_DNA_Advantage)         1     IN USE
```

**Key points:**
- Token generated from Cisco Smart Software Manager portal
- Device communicates with CSSM periodically
- Can operate in disconnected mode for up to 90 days
- Supports satellite/on-premise licensing for air-gapped networks

## Software Upgrade Procedures

### Pre-Upgrade Preparation

**Verify Current IOS:**
```
R1# show version | include Software|image
Cisco IOS Software, C2900 Software (C2900-UNIVERSALK9-M), Version 15.4(3)M6
System image file is "flash0:c2900-universalk9-mz.SPA.154-3.M6.bin"
```

**Check Flash Memory:**
```
R1# show flash:
-#- --length-- -----date/time------ path
1   117835268  Jan 10 2025 10:23:45 +00:00 c2900-universalk9-mz.SPA.154-3.M6.bin
2      245678  Jan 10 2025 10:25:12 +00:00 config_backup.cfg

256487424 bytes total (138404992 bytes free)
```

**Calculate Required Space:**
```
R1# dir flash:
Directory of flash0:/

    1  -rw-   117835268  Jan 10 2025 10:23:45 +00:00  c2900-universalk9-mz.SPA.154-3.M6.bin
    2  -rw-      245678  Jan 10 2025 10:25:12 +00:00  config_backup.cfg

256487424 bytes total (138404992 bytes free)
```

**Key points:**
- Verify sufficient flash space for new image
- New image typically 100-200MB depending on platform
- Keep old image as backup if space permits
- Download release notes for new IOS version
- Check hardware/memory requirements
- Verify feature compatibility

### Downloading New IOS Image

**Copy from TFTP Server:**
```
R1# copy tftp: flash:
Address or name of remote host []? 192.168.1.100
Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin
Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 
Accessing tftp://192.168.1.100/c2900-universalk9-mz.SPA.157-3.M5.bin...
Loading c2900-universalk9-mz.SPA.157-3.M5.bin from 192.168.1.100 (via GigabitEthernet0/0): !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 125456789 bytes]

125456789 bytes copied in 245.678 secs (510789 bytes/sec)
```

**Copy from FTP Server:**
```
R1# copy ftp: flash:
Address or name of remote host []? 192.168.1.100
Source username [R1]? ftpuser
Source password? ftppass
Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin
Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 125456789 bytes]
```

**Copy from SCP Server (Secure):**
```
R1# copy scp: flash:
Address or name of remote host []? 192.168.1.100
Source username []? scpuser
Source filename []? /cisco-ios/c2900-universalk9-mz.SPA.157-3.M5.bin
Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 
Password: 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 125456789 bytes]
```

**Copy from HTTP/HTTPS:**
```
R1# copy http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin flash:
Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 
Accessing http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin...
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 125456789 bytes]
```

**Key points:**
- TFTP limited to files \<32MB (not suitable for modern IOS images on most platforms)
- FTP transfers faster than TFTP
- SCP recommended for security (encrypted transfer)
- HTTP/HTTPS useful when file servers available
- Monitor transfer progress (exclamation marks indicate successful segments)

### Verifying IOS Image Integrity

**MD5 Hash Verification:**
```
R1# verify /md5 flash:c2900-universalk9-mz.SPA.157-3.M5.bin
...........................................................
...........................................................
...Done!
verify /md5 (flash:c2900-universalk9-mz.SPA.157-3.M5.bin) = a1b2c3d4e5f67890a1b2c3d4e5f67890
```

Compare with MD5 hash from Cisco.com download page.

**Digital Signature Verification:**
```
R1# show software authenticity file flash:c2900-universalk9-mz.SPA.157-3.M5.bin
File Name                   : flash:c2900-universalk9-mz.SPA.157-3.M5.bin
Image type                  : Development
File Integrity              : Signature Verified
```

**Key points:**
- Always verify MD5/SHA hash before using new image
- Hash mismatch indicates corrupted download
- Digital signature verification confirms authentic Cisco image
- Re-download if verification fails

### Configuring Boot System

**Setting Boot System Variable:**
```
R1# configure terminal
R1(config)# boot system flash:c2900-universalk9-mz.SPA.157-3.M5.bin
R1(config)# boot system flash:c2900-universalk9-mz.SPA.154-3.M6.bin
R1(config)# end
R1# copy running-config startup-config
```

**Verification:**
```
R1# show running-config | include boot
boot-start-marker
boot system flash:c2900-universalk9-mz.SPA.157-3.M5.bin
boot system flash:c2900-universalk9-mz.SPA.154-3.M6.bin
boot-end-marker
```

**Key points:**
- Multiple boot system commands create fallback chain
- Router attempts boot in order configured
- First successful boot stops process
- If all fail, router boots from ROMMON
- Always save configuration before reload

### Performing the Upgrade

**Reload with Configuration Save Prompt:**
```
R1# reload
System configuration has been modified. Save? [yes/no]: yes
Building configuration...
[OK]
Proceed with reload? [confirm]

*Jan 15 14:45:12.345: %SYS-5-RELOAD: Reload requested by admin on console.
...
(Router reboots)
...
```

**Scheduled Reload:**
```
R1# reload in 10
Reload scheduled in 10 minutes by admin on console
Reload reason: Planned IOS upgrade

R1# reload cancel                                 ! Cancel scheduled reload
```

**Reload at Specific Time:**
```
R1# reload at 02:00 15 Jan
Reload scheduled for 02:00:00 PST Mon Jan 15 2025 (in 11 hours and 14 minutes) by admin on console
```

**Key points:**
- Schedule reloads during maintenance windows
- Notify users of planned downtime
- Monitor reload process via console connection
- Have rollback plan ready
- Test new IOS in lab environment first

### Post-Upgrade Verification

**Verify New IOS Version:**
```
R1# show version
Cisco IOS Software, C2900 Software (C2900-UNIVERSALK9-M), Version 15.7(3)M5
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2018 by Cisco Systems, Inc.
Compiled Wed 01-Aug-18 12:34 by prod_rel_team

ROM: System Bootstrap, Version 15.0(1r)M16, RELEASE SOFTWARE (fc1)

R1 uptime is 5 minutes
System returned to ROM by reload at 14:45:23 PST Mon Jan 15 2025
System image file is "flash0:c2900-universalk9-mz.SPA.157-3.M5.bin"
Last reload type: Normal Reload
Last reload reason: Reload Command
...
```

**Verify Configuration Retained:**
```
R1# show running-config
...

R1# show startup-config
...
```

**Verify Interfaces:**
```
R1# show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
GigabitEthernet0/0         192.168.1.1     YES NVRAM  up                    up      
GigabitEthernet0/1         10.1.1.1        YES NVRAM  up                    up      
Loopback0                  1.1.1.1         YES NVRAM  up
up
```

**Verify Routing:**
```
R1# show ip route Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2 E1 - OSPF external type 1, E2 - OSPF external type 2 i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2 ia - IS-IS inter area, * - candidate default, U - per-user static route o - ODR, P - periodic downloaded static route, H - NHRP, l - LISP a - application route + - replicated route, % - next hop override, p - overrides from PfR

Gateway of last resort is 192.168.1.254 to network 0.0.0.0

S* 0.0.0.0/0 [1/0] via 192.168.1.254 1.0.0.0/32 is subnetted, 1 subnets C 1.1.1.1 is directly connected, Loopback0 10.0.0.0/8 is variably subnetted, 2 subnets, 2 masks C 10.1.1.0/24 is directly connected, GigabitEthernet0/1 L 10.1.1.1/32 is directly connected, GigabitEthernet0/1 192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks C 192.168.1.0/24 is directly connected, GigabitEthernet0/0 L 192.168.1.1/32 is directly connected, GigabitEthernet0/0

```

**Verify Routing Protocols:**
```

R1# show ip protocols *** IP Routing is NSF aware ***

Routing Protocol is "ospf 1" Outgoing update filter list for all interfaces is not set Incoming update filter list for all interfaces is not set Router ID 1.1.1.1 Number of areas in this router is 1. 1 normal 0 stub 0 nssa Maximum path: 4 Routing for Networks: 192.168.1.0 0.0.0.255 area 0 10.1.1.0 0.0.0.255 area 0 Routing Information Sources: Gateway Distance Last Update 2.2.2.2 110 00:03:45 3.3.3.3 110 00:03:45 Distance: (default is 110)

```

**Verify Key Services:**
```

R1# show ntp status Clock is synchronized, stratum 3, reference is 192.168.1.200

R1# show cdp neighbors Device ID Local Intrfce Holdtme Capability Platform Port ID SW1 Gig 0/0 165 S I WS-C2960 Gig 0/1 R2 Gig 0/1 155 R S I ISR4321 Gig 0/0

R1# show users Line User Host(s) Idle Location

- 0 con 0 admin idle 00:00:00  
    194 vty 0 netadmin idle 00:05:23 192.168.1.50

Interface User Mode Idle Peer Address

```

**Key points:**
- Verify all critical features operational
- Check interface status and IP connectivity
- Confirm routing protocols converged
- Test SSH/Telnet access
- Verify NTP synchronization
- Check system logs for errors
- Validate license status if applicable

### Rollback Procedures

**If upgrade fails or issues discovered:**

**Method 1: Change boot system priority:**
```

R1# configure terminal R1(config)# no boot system flash:c2900-universalk9-mz.SPA.157-3.M5.bin R1(config)# end R1# copy running-config startup-config R1# reload

```

**Method 2: Boot from ROMMON:**
```

rommon 1 > boot flash:c2900-universalk9-mz.SPA.154-3.M6.bin

```

**Method 3: TFTP boot from ROMMON:**
```

rommon 1 > IP_ADDRESS=192.168.1.1 rommon 2 > IP_SUBNET_MASK=255.255.255.0 rommon 3 > DEFAULT_GATEWAY=192.168.1.254 rommon 4 > TFTP_SERVER=192.168.1.100 rommon 5 > TFTP_FILE=c2900-universalk9-mz.SPA.154-3.M6.bin rommon 6 > tftpdnld rommon 7 > boot

```

**Key points:**
- Always maintain previous working IOS image
- Document rollback procedures before upgrade
- Test rollback in lab if possible
- Keep console access available during upgrade
- Have TFTP server ready with known-good image

### Deleting Old IOS Images

**After successful upgrade and testing:**
```

R1# delete flash:c2900-universalk9-mz.SPA.154-3.M6.bin Delete filename [c2900-universalk9-mz.SPA.154-3.M6.bin]? Delete flash:c2900-universalk9-mz.SPA.154-3.M6.bin? [confirm]

```

**Squeeze Flash (recover deleted space):**
```

R1# squeeze flash: All deleted files will be removed. Continue? [confirm] Squeezing flash filesys (erasing sector blocks) ... !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

```

**Key points:**
- Wait at least 24-48 hours before deleting old image
- Ensure new image stable in production
- Keep old image if flash space permits
- `delete` marks file for deletion but doesn't reclaim space
- `squeeze` permanently removes deleted files and reclaims space
- `squeeze` operation can take several minutes

## Configuration Backup and Restoration

### Local Configuration Backup

**Copying Configuration to Flash:**
```

R1# copy running-config flash:config-backup-20250115.cfg Destination filename [config-backup-20250115.cfg]? 6789 bytes copied in 0.234 secs (29013 bytes/sec)

R1# dir flash: Directory of flash0:/

```
1  -rw-   125456789  Jan 15 2025 14:45:23 +00:00  c2900-universalk9-mz.SPA.157-3.M5.bin
2  -rw-        6789  Jan 15 2025 15:12:45 +00:00  config-backup-20250115.cfg
```

256487424 bytes total (130902144 bytes free)

```

**Copying Startup-Config to Flash:**
```

R1# copy startup-config flash:startup-backup.cfg Destination filename [startup-backup.cfg]? 6789 bytes copied in 0.189 secs (35942 bytes/sec)

```

**Key points:**
- Use descriptive filenames with dates
- Running-config contains current active configuration
- Startup-config used after reload
- Configurations typically small (few KB to few MB)
- Regular backups essential for disaster recovery

### Remote Configuration Backup

**Backup to TFTP Server:**
```

R1# copy running-config tftp: Address or name of remote host []? 192.168.1.100 Destination filename [r1-confg]? R1-running-config-20250115.cfg !! 6789 bytes copied in 0.456 secs (14889 bytes/sec)

```

**Backup to FTP Server:**
```

R1# copy running-config ftp: Address or name of remote host []? 192.168.1.100 Destination username [R1]? ftpuser Destination password? ftppass Destination filename [r1-confg]? R1-running-config-20250115.cfg ! 6789 bytes copied in 0.334 secs (20327 bytes/sec)

```

**Backup to SCP Server:**
```

R1# copy running-config scp: Address or name of remote host []? 192.168.1.100 Destination username []? scpuser Destination filename [r1-confg]? /backups/R1-running-config-20250115.cfg Password: ! 6789 bytes copied in 0.412 secs (16478 bytes/sec)

```

**Backup to USB:**
```

R1# copy running-config usbflash0:R1-backup-20250115.cfg 6789 bytes copied in 0.156 secs (43519 bytes/sec)

```

**Key points:**
- TFTP simple but insecure
- FTP faster than TFTP, but credentials in plaintext
- SCP recommended (encrypted transfer)
- USB backup useful for offline storage
- Automate backups for production networks

### Automated Configuration Backup

**Using Archive Configuration:**
```

R1# configure terminal R1(config)# archive R1(config-archive)# path tftp://192.168.1.100/configs/$h-$t R1(config-archive)# time-period 1440 R1(config-archive)# write-memory R1(config-archive)# exit

```

**Manual Archive Save:**
```

R1# archive config

```

**Variables in archive path:**
- `$h` = hostname
- `$t` = timestamp (YYYYMMDD-HHMMSS)

**Example resulting filename:**
```

R1-20250115-151245-1 R1-20250115-163012-2 R1-20250116-091523-3

```

**Key points:**
- `time-period` in minutes (1440 = 24 hours)
- `write-memory` triggers backup on configuration save
- Sequential number appended to filename
- Automatic backup reduces human error
- Configure on all production devices

### Configuration Restoration

**Restoring from Flash:**
```

R1# copy flash:config-backup-20250115.cfg running-config Destination filename [running-config]? 6789 bytes copied in 0.123 secs (55195 bytes/sec)

```

**Restoring from TFTP:**
```

R1# copy tftp: running-config Address or name of remote host []? 192.168.1.100 Source filename []? R1-running-config-20250115.cfg Destination filename [running-config]? Accessing tftp://192.168.1.100/R1-running-config-20250115.cfg... Loading R1-running-config-20250115.cfg from 192.168.1.100 (via GigabitEthernet0/0): ! [OK - 6789 bytes]

6789 bytes copied in 1.234 secs (5501 bytes/sec)

```

**Restoring Startup-Config:**
```

R1# copy tftp: startup-config Address or name of remote host []? 192.168.1.100 Source filename []? R1-startup-config-20250115.cfg Destination filename [startup-config]? ! [OK - 6789 bytes]

6789 bytes copied in 1.123 secs (6047 bytes/sec) R1# reload

```

**Key points:**
- Restoring to running-config applies immediately
- Restoring to startup-config requires reload
- Merge operation: new config added to existing
- Lines in backup override conflicting lines in running-config
- To completely replace: `write erase` then restore

### Configuration Replace

**Complete Configuration Replacement:**
```

R1# configure replace flash:config-backup-20250115.cfg This will apply all necessary additions and deletions to replace the current running configuration with the contents of the specified configuration file, which is assumed to be a complete configuration, not a partial configuration. Enter Y if you are sure you want to proceed. ? [no]: yes

Total number of passes: 1 Rollback Done

```

**Configuration Replace with Rollback:**
```

R1# configure replace flash:config-backup-20250115.cfg force time 5

```

**Key points:**
- `configure replace` removes lines not in backup file
- `force` bypasses confirmation prompt
- `time` value enables automatic rollback if connection lost
- Safer than manual copy for complete restoration
- Requires IOS 12.3(7)T or later

### Archive Compare and Rollback

**Viewing Archive History:**
```

R1# show archive The maximum archive configurations allowed is 14. The next archive file will be named flash:archive-config-1 Archive # Name 1 flash:archive-config-1 2 flash:archive-config-2 3 flash:archive-config-3 <- Most Recent 4  
5  
...

```

**Comparing Configurations:**
```

R1# show archive config differences flash:archive-config-2 flash:archive-config-3 Contextual Config Diffs: +no ip http server +interface GigabitEthernet0/1 +description Link to R2 +ip address 10.1.1.1 255.255.255.0

```

**Rolling Back Configuration:**
```

R1# configure revert now Loading configuration from flash:archive-config-2

R1# configure revert timer 5 Loading configuration from flash:archive-config-2 The configuration will be reverted in 5 minutes unless confirmed. R1# configure confirm ! Confirm to keep changes

```

**Key points:**
- Rollback restores previous configuration version
- `timer` provides automatic revert (safety mechanism)
- `confirm` cancels automatic revert
- Useful for risky configuration changes
- Always test in lab before production use

### Configuration Templates

**Creating Configuration Template:**
```

R1# show running-config | redirect flash:template-base-router.cfg

R1# more flash:template-base-router.cfg ! ! Last configuration change at 15:45:23 PST Mon Jan 15 2025 ! version 15.7 service timestamps debug datetime msec localtime show-timezone service timestamps log datetime msec localtime show-timezone service password-encryption service sequence-numbers ! hostname TEMPLATE ! ...

```

**Using Template for New Device:**
```

NewRouter# copy tftp: running-config Address or name of remote host []? 192.168.1.100 Source filename []? template-base-router.cfg Destination filename [running-config]? ! [OK - 8456 bytes]

NewRouter# configure terminal NewRouter(config)# hostname R3 R3(config)# interface gigabitEthernet 0/0 R3(config-if)# ip address 192.168.3.1 255.255.255.0 R3(config-if)# no shutdown ...

```

**Key points:**
- Templates ensure consistent baseline configuration
- Remove device-specific parameters (hostname, IP addresses, keys)
- Version control templates like code
- Customize template after applying
- Reduces configuration errors and deployment time

## TFTP, FTP, and SCP File Transfers

### TFTP Configuration and Usage

**Configuring TFTP Server (on external server):**
- Install TFTP server software (Tftpd64, SolarWinds TFTP, etc.)
- Configure root directory
- Disable firewall restrictions for UDP port 69
- Ensure network connectivity

**TFTP Upload from Router:**
```
R1# copy flash:c2900-universalk9-mz.SPA.157-3.M5.bin tftp: Address or name of remote host []? 192.168.1.100 Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 125456789 bytes copied in 456.789 secs (274567 bytes/sec)
```

**TFTP Download to Router:**
```
R1# copy tftp: flash: Address or name of remote host []? 192.168.1.100 Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Accessing tftp://192.168.1.100/c2900-universalk9-mz.SPA.157-3.M5.bin... Loading c2900-universalk9-mz.SPA.157-3.M5.bin from 192.168.1.100 (via GigabitEthernet0/0): !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [OK - 125456789 bytes]

125456789 bytes copied in 512.345 secs (244897 bytes/sec)
```

**TFTP Limitations:**
- Maximum file size: typically 32MB (protocol limitation)
- No authentication mechanism
- No encryption
- Uses UDP (unreliable transport)
- Not suitable for modern IOS images (usually >100MB)
- Acceptable for configuration files only

**Key points:**
- Legacy protocol, simple to configure
- Insecure for production environments
- Blocked by many firewalls (UDP 69)
- Consider alternatives for large files
- Useful for emergency recovery scenarios

### FTP Configuration and Usage

**Configuring FTP Credentials on Router:**
```
R1# configure terminal R1(config)# ip ftp username ftpuser R1(config)# ip ftp password ftppass123 R1(config)# exit
```

**FTP Upload from Router:**
```
R1# copy flash:c2900-universalk9-mz.SPA.157-3.M5.bin ftp: Address or name of remote host []? 192.168.1.100 Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Writing c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 125456789 bytes copied in 234.567 secs (534891 bytes/sec)
```

**FTP Download to Router:**
```
R1# copy ftp: flash: Address or name of remote host []? 192.168.1.100 Source username [ftpuser]? Source password [ftppass123]? Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Accessing ftp://192.168.1.100/c2900-universalk9-mz.SPA.157-3.M5.bin... Loading c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [OK - 125456789 bytes]

125456789 bytes copied in 198.456 secs (632147 bytes/sec)
```

**Interactive FTP (alternative method):**
```
R1# copy ftp: flash: Address or name of remote host []? 192.168.1.100 Source username []? ftpuser Source password? ftppass123 Source filename []? c2900-universalk9-mz.SPA.157-3.M5.bin Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? ...
```

**FTP Passive Mode:**
```
R1# configure terminal R1(config)# ip ftp passive R1(config)# exit
```

**Key points:**
- Faster than TFTP (TCP vs UDP)
- Supports large files (no 32MB limitation)
- Uses TCP ports 20 (data) and 21 (control)
- Credentials transmitted in plaintext (security risk)
- Passive mode helps with firewall/NAT traversal
- Suitable for internal networks only

### SCP Configuration and Usage

**Prerequisites for SCP:**
- SSH must be configured and operational
- Username and password authentication required
- RSA keys generated on router

**Enabling SCP Server on Router:**
```
R1# configure terminal R1(config)# ip scp server enable R1(config)# aaa new-model R1(config)# aaa authentication login default local R1(config)# aaa authorization exec default local R1(config)# username scpuser privilege 15 secret ScpP@ss123 R1(config)# exit
```

**SCP Upload from Router:**
```
R1# copy flash:c2900-universalk9-mz.SPA.157-3.M5.bin scp: Address or name of remote host []? 192.168.1.100 Destination username []? scpuser Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? /backups/IOS/c2900-universalk9-mz.SPA.157-3.M5.bin Password: Sending file modes: C0644 125456789 c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 125456789 bytes copied in 245.123 secs (511897 bytes/sec)
```

**SCP Download to Router:**
```
R1# copy scp: flash: Address or name of remote host []? 192.168.1.100 Source username []? scpuser Source filename []? /cisco-ios/c2900-universalk9-mz.SPA.157-3.M5.bin Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Password: Receiving file modes: C0644 125456789 c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [OK - 125456789 bytes]

125456789 bytes copied in 234.789 secs (534278 bytes/sec)
```

**Specifying Full SCP URI:**
```
R1# copy scp://scpuser@192.168.1.100//cisco-ios/c2900-universalk9-mz.SPA.157-3.M5.bin flash: Password: ...
```

**Key points:**
- Most secure file transfer method (encrypted)
- Uses SSH (TCP port 22)
- Requires AAA configuration (basic or full)
- Privilege level 15 typically required for file operations
- Supports absolute paths on server
- Recommended for production environments
- Slower than FTP due to encryption overhead

### Comparison of File Transfer Protocols

| Feature | TFTP | FTP | SCP |
|---------|------|-----|-----|
| Protocol | UDP | TCP | SSH/TCP |
| Port(s) | 69 | 20, 21 | 22 |
| Authentication | None | Username/Password | SSH keys or Username/Password |
| Encryption | No | No | Yes |
| File size limit | ~32MB | Unlimited | Unlimited |
| Speed | Slow | Fast | Moderate (encryption overhead) |
| Reliability | Low (UDP) | High (TCP) | High (TCP) |
| Security | Very Low | Low | High |
| Complexity | Simple | Moderate | Complex |
| Firewall-friendly | Moderate | Low (active mode) | High |
| Production use | Emergency only | Internal networks | Recommended |

### HTTP/HTTPS File Transfers

**HTTP Download:**
```
R1# copy http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin flash: Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? Accessing http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin... Loading http://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [OK - 125456789 bytes]

125456789 bytes copied in 221.456 secs (566542 bytes/sec)
```

**HTTPS Download with Authentication:**
```
R1# configure terminal R1(config)# ip http client username httpuser R1(config)# ip http client password HttpP@ss123 R1(config)# exit

R1# copy https://192.168.1.100/ios-images/c2900-universalk9-mz.SPA.157-3.M5.bin flash:
```

**Enabling HTTP Server on Router:**
```
R1# configure terminal R1(config)# ip http server R1(config)# ip http authentication local R1(config)# ip http secure-server ! HTTPS R1(config)# ip http port 8080 ! Custom port R1(config)# exit
```

**Key points:**
- HTTP simple for downloading files
- HTTPS provides encryption
- Requires web server setup on source
- HTTP server on router enables web-based management
- Disable HTTP server if not needed (security)
- Can use basic or digest authentication
- Useful when centralized file server available

### USB File Transfers

**Checking USB Filesystem:**
```
R1# dir usbflash0: Directory of usbflash0:/
```
1  -rw-     6789  Jan 15 2025 15:30:12 +00:00  config-backup.cfg
2  -rw-   125456789  Jan 15 2025 15:45:23 +00:00  c2900-universalk9-mz.SPA.157-3.M5.bin
```
8000000000 bytes total (7874536422 bytes free)
```

**Copying to USB:**
```
R1# copy running-config usbflash0:R1-backup-20250115.cfg 6789 bytes copied in 0.234 secs (29013 bytes/sec)

R1# copy flash:c2900-universalk9-mz.SPA.157-3.M5.bin usbflash0: 125456789 bytes copied in 89.456 secs (1402456 bytes/sec)
```

**Copying from USB:**
```
R1# copy usbflash0:c2900-universalk9-mz.SPA.157-3.M5.bin flash: Destination filename [c2900-universalk9-mz.SPA.157-3.M5.bin]? 125456789 bytes copied in 92.123 secs (1361897 bytes/sec)
```

**Key points:**
- USB provides portable offline backup
- FAT32 filesystem typical (4GB file size limit per file)
- Useful for devices without network connectivity
- Insert USB while router running (hot-swappable on most platforms)
- Remove safely: no unmount required on Cisco IOS
- Verify USB recognized: `show file systems`

### File System Management

**Viewing Available File Systems:**
```
R1# show file systems File Systems:
```
   Size(b)       Free(b)      Type  Flags  Prefixes
```
- 256487424 130902144 flash rw flash0: flash:# 8000000000 7874536422 usbf rw usbflash0: - - opaque rw bs: - - opaque rw vb: 262136 257909 nvram rw nvram: - - network rw tftp: - - network rw ftp: - - network rw http: - - network rw https: - - network rw scp: - - opaque ro null: - - opaque ro tar: - - network rw rcp: - - network rw system: - - opaque wo xmodem: - - opaque wo ymodem:
```

**Changing Default Filesystem:**
```
R1# cd usbflash0: R1# pwd usbflash0:

R1# cd flash: R1# pwd flash:
```

**Key points:**
- `*` indicates current default filesystem
- `rw` = read/write, `ro` = read-only, `wo` = write-only
- `flash:` typically default on most platforms
- Network filesystems accessible via protocols
- NVRAM stores startup-config (limited size)

**Important Related Topics:**
- Configuration management systems (RANCID, Oxidized)
- Network automation for backups (Ansible, Python)
- Centralized configuration repositories (Git)
- Disaster recovery planning and testing
- Change management procedures
- Configuration compliance auditing

---

# Cisco IOS Interface Configuration

## Interface Types and Naming Conventions

Cisco devices use standardized naming conventions that identify the interface type, module location, and port number. The format typically follows: **InterfaceType[slot/subslot/]port**.

**Physical Interface Types:**

- **Ethernet**: Et0/0, Et0/1 (older platforms)
- **Fast Ethernet**: Fa0/1, Fa0/2 (100 Mbps)
- **Gigabit Ethernet**: Gi0/0/1, Gi1/0/1 (1 Gbps)
- **Ten Gigabit Ethernet**: Te0/1/0, Te1/1/0 (10 Gbps)
- **Twenty-Five Gigabit Ethernet**: TwentyFiveGigE0/0/1 (25 Gbps)
- **Forty Gigabit Ethernet**: Fo0/1/0 (40 Gbps)
- **Hundred Gigabit Ethernet**: Hu0/1/0 (100 Gbps)
- **Serial**: S0/0/0, S0/1/0 (WAN connections)

**Logical Interface Types:**

- **Loopback**: Lo0, Lo1, Lo100
- **Tunnel**: Tu0, Tu1
- **VLAN**: Vlan1, Vlan10, Vlan100
- **Port-channel**: Po1, Po2 (EtherChannel)
- **Bridge Virtual Interface**: BVI1

**Naming Components:**

- **Slot**: Physical slot in chassis where line card is installed
- **Subslot**: Secondary slot position (modular cards)
- **Port**: Individual port number on the interface card

**Platform Variations:** Different Cisco platforms may use slightly different conventions. ISR routers typically use format Gi0/0/0, while switches might use Gi1/0/1. Catalyst switches often number interfaces starting from 1, while routers commonly start from 0.

## Interface Configuration Modes

Cisco IOS uses hierarchical configuration modes to manage interface settings.

**Global Configuration Mode:**

```
Router> enable
Router# configure terminal
Router(config)#
```

**Interface Configuration Mode:**

```
Router(config)# interface gigabitethernet 0/0/1
Router(config-if)#
```

**Multiple Interface Configuration:**

```
Router(config)# interface range gigabitethernet 0/0/1-4
Router(config-if-range)#
```

**Interface Configuration Commands:** All interface-specific commands are entered in interface configuration mode. Changes take effect immediately unless the interface is administratively down.

**Sub-interface Configuration:**

```
Router(config)# interface gigabitethernet 0/0/1.10
Router(config-subif)#
```

Sub-interfaces enable VLAN tagging and multiple logical interfaces on a single physical port.

## IP Addressing (IPv4 and IPv6)

**IPv4 Configuration:**

```
Router(config-if)# ip address 192.168.1.1 255.255.255.0
Router(config-if)# ip address 10.1.1.1 255.255.255.252 secondary
```

The primary IP address is configured first, followed by any secondary addresses using the `secondary` keyword.

**DHCP Client Configuration:**

```
Router(config-if)# ip address dhcp
Router(config-if)# ip address dhcp hostname router1
```

**IPv6 Configuration:**

```
Router(config-if)# ipv6 address 2001:db8:1::1/64
Router(config-if)# ipv6 address fe80::1 link-local
Router(config-if)# ipv6 enable
```

**IPv6 Autoconfiguration:**

```
Router(config-if)# ipv6 address autoconfig
Router(config-if)# ipv6 address dhcp
```

**Dual Stack Configuration:** Both IPv4 and IPv6 can be configured simultaneously on the same interface:

```
Router(config-if)# ip address 192.168.1.1 255.255.255.0
Router(config-if)# ipv6 address 2001:db8:1::1/64
Router(config-if)# ipv6 enable
```

**Unnumbered Interfaces:**

```
Router(config-if)# ip unnumbered loopback0
```

This borrows the IP address from another interface, commonly used on point-to-point links.

## Interface Descriptions

Interface descriptions provide documentation and identification for network interfaces.

**Configuration:**

```
Router(config-if)# description Link to Core Switch - Vlan 100
Router(config-if)# description WAN Connection to ISP - Circuit ID: 12345
Router(config-if)# description Management Interface - VLAN 999
```

**Best Practices:**

- Include connected device information
- Reference circuit IDs for WAN links
- Specify VLAN information
- Include contact information for third-party circuits
- Use consistent naming conventions across the organization

**Character Limitations:** Descriptions support up to 240 characters on most platforms. Special characters and spaces are supported.

**Verification:**

```
Router# show interfaces description
Router# show ip interface brief
```

## Speed and Duplex Settings

Network interfaces can operate at different speeds and duplex modes depending on hardware capabilities.

**Speed Configuration:**

```
Router(config-if)# speed 100
Router(config-if)# speed 1000
Router(config-if)# speed auto
```

**Duplex Configuration:**

```
Router(config-if)# duplex full
Router(config-if)# duplex half
Router(config-if)# duplex auto
```

**Auto-negotiation:**

```
Router(config-if)# speed auto
Router(config-if)# duplex auto
```

Auto-negotiation is the default setting on most modern interfaces and automatically determines the best speed and duplex combination.

**Manual Configuration Scenarios:**

- Connecting to legacy devices that don't support auto-negotiation
- Troubleshooting speed/duplex mismatches
- Enforcing specific performance requirements
- Connecting to devices with known auto-negotiation issues

**Common Speed/Duplex Combinations:**

- 10 Mbps half-duplex
- 10 Mbps full-duplex
- 100 Mbps half-duplex
- 100 Mbps full-duplex
- 1000 Mbps full-duplex (Gigabit Ethernet doesn't support half-duplex)

**Mismatch Issues:** Speed and duplex mismatches cause performance problems, including excessive collisions, frame errors, and reduced throughput. Both ends of a link must be configured identically when using manual settings.

## Loopback Interfaces

Loopback interfaces are logical interfaces that remain operational as long as the device is powered on, making them ideal for specific network functions.

**Configuration:**

```
Router(config)# interface loopback 0
Router(config-if)# ip address 10.1.1.1 255.255.255.255
Router(config-if)# ipv6 address 2001:db8:1::1/128
Router(config-if)# description Router ID for OSPF and BGP
```

**Common Use Cases:**

- Router identification for routing protocols (OSPF Router ID, BGP Router ID)
- Management access (always reachable if device is operational)
- Termination point for VPN tunnels
- Source interface for network services (SNMP, Syslog, NTP)
- Testing and troubleshooting (ping, traceroute)

**Subnet Mask Considerations:** Loopback interfaces typically use /32 (255.255.255.255) subnet masks for IPv4 and /128 for IPv6, as they represent a single host address.

**Multiple Loopback Interfaces:**

```
Router(config)# interface loopback 1
Router(config-if)# ip address 10.2.2.2 255.255.255.255
Router(config)# interface loopback 100
Router(config-if)# ip address 172.16.1.1 255.255.255.255
```

Different loopback interfaces can serve different purposes or represent different services on the same device.

**Routing Protocol Integration:** Loopback interfaces are automatically advertised by routing protocols and provide stable endpoints for network communication.

## Interface Status Verification

Multiple commands provide different views of interface status and configuration.

**Basic Interface Status:**

```
Router# show interfaces
Router# show interfaces gigabitethernet 0/0/1
Router# show interfaces brief
Router# show ip interface brief
```

**Interface Statistics:**

```
Router# show interfaces gigabitethernet 0/0/1 stats
Router# show interfaces counters
Router# show interfaces counters errors
```

**Layer 2 Information:**

```
Router# show interfaces status
Router# show interfaces switchport
Router# show interfaces trunk
```

**Layer 3 Information:**

```
Router# show ip interface
Router# show ip interface gigabitethernet 0/0/1
Router# show ipv6 interface
Router# show ipv6 interface brief
```

**Key Status Indicators:**

**Administrative Status:**

- up: Interface is enabled (`no shutdown`)
- administratively down: Interface is disabled (`shutdown`)

**Operational Status:**

- up: Interface is functioning and has physical connectivity
- down: Interface has no physical connectivity or hardware issues

**Protocol Status:**

- up: Layer 3 protocols are operational
- down: Layer 3 protocols are not operational

**Common Status Combinations:**

- up/up: Interface is fully operational
- administratively down/down: Interface is intentionally disabled
- up/down: Physical connection exists but protocol issues prevent operation
- down/down: No physical connectivity

## Shutdown and No Shutdown Commands

Interface shutdown commands control the administrative state of network interfaces.

**Shutdown Command:**

```
Router(config-if)# shutdown
```

The shutdown command administratively disables an interface, setting its status to "administratively down." This prevents all traffic from passing through the interface.

**No Shutdown Command:**

```
Router(config-if)# no shutdown
```

The no shutdown command administratively enables an interface, allowing it to become operational if physical connectivity exists.

**Default Behavior:**

- **Router interfaces**: Shutdown by default (administratively down)
- **Switch interfaces**: No shutdown by default (up if connected)

**Use Cases for Shutdown:**

- Maintenance activities
- Security isolation
- Preventing unwanted connections
- Troubleshooting network issues
- Decommissioning interfaces

**Use Cases for No Shutdown:**

- Enabling new interfaces
- Restoring service after maintenance
- Activating standby connections
- Initial interface configuration

**Range Configuration:**

```
Router(config)# interface range gigabitethernet 0/0/1-8
Router(config-if-range)# shutdown
Router(config-if-range)# no shutdown
```

Multiple interfaces can be shutdown or enabled simultaneously using interface ranges.

**Verification:**

```
Router# show interfaces status
Router# show ip interface brief
```

These commands display the administrative and operational status of all interfaces, showing which are shutdown and which are active.

**Key points** to remember: Interface configuration in Cisco IOS follows a hierarchical structure where global configuration leads to interface-specific configuration. Most interface changes take effect immediately, but some may require interface bouncing (shutdown/no shutdown) to fully implement. Always verify configuration changes using appropriate show commands to ensure proper operation.

---

# Switch Fundamentals

## Layer 2 Switching Concepts

Layer 2 switching operates at the Data Link layer of the OSI model, making forwarding decisions based on MAC addresses. Switches learn MAC addresses from incoming frames, store them in the MAC address table (CAM table), and use this information to forward frames only to the appropriate destination port rather than flooding to all ports.

**Frame Forwarding Methods:**

- **Store-and-Forward**: The switch receives the entire frame, performs error checking via CRC (Cyclic Redundancy Check), then forwards it. This method provides error detection but introduces latency.
- **Cut-Through**: The switch reads only the destination MAC address (first 6 bytes after preamble) and immediately begins forwarding. This reduces latency but doesn't check for errors.
- **Fragment-Free**: A hybrid approach that reads the first 64 bytes to detect collision fragments before forwarding.

**Switching Operations:** When a frame arrives, the switch examines the source MAC address and associates it with the ingress port. It then looks up the destination MAC address in its table. If found, the frame is forwarded to that specific port (unicast). If not found, the frame is flooded to all ports except the ingress port (unknown unicast). Broadcast and multicast frames are flooded to all ports in the same VLAN.

**Switch Learning Process:** The MAC address table is dynamically built as frames traverse the switch. Each entry contains the MAC address, associated port, VLAN ID, and a timestamp. Entries age out after 300 seconds (5 minutes) of inactivity by default, though this timer is configurable.

## MAC Address Table

The MAC address table (also called CAM table or Content Addressable Memory table) is the core database that enables switching functionality. It maps MAC addresses to physical switch ports and VLAN associations.

**Table Operations:**

- **Learning**: When a frame enters a port, the switch records the source MAC address, port number, and VLAN in the table
- **Aging**: Entries are removed after the aging timer expires without activity (default 300 seconds)
- **Flooding**: When destination MAC is unknown, the switch floods the frame to all ports in the VLAN except the source port
- **Forwarding**: When destination MAC exists in table, frame is sent only to that port

**Viewing MAC Address Table:**

```
Switch# show mac address-table
Switch# show mac address-table dynamic
Switch# show mac address-table address [mac-address]
Switch# show mac address-table interface [interface-id]
Switch# show mac address-table vlan [vlan-id]
```

**Managing MAC Address Table:**

```
Switch(config)# mac address-table aging-time [seconds]
Switch# clear mac address-table dynamic
Switch# clear mac address-table dynamic address [mac-address]
Switch# clear mac address-table dynamic interface [interface-id]
```

**Static MAC Address Entries:** You can manually configure static MAC entries that never age out:

```
Switch(config)# mac address-table static [mac-address] vlan [vlan-id] interface [interface-id]
```

**Table Size Limitations:** Different switch models have varying MAC address table capacities, ranging from 8,000 entries on small switches to over 100,000 on enterprise models. When the table fills, the switch may drop new learning attempts or remove older entries.

## Switch Port Modes

Switch ports can operate in different modes that determine how they handle VLAN traffic and participate in network segmentation.

**Access Mode:** Access ports belong to a single VLAN and typically connect end devices like computers, phones, or printers. They send and receive untagged frames.

```
Switch(config)# interface gigabitethernet 0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
```

Access ports strip any VLAN tags from incoming frames and add the configured VLAN tag when forwarding frames into the switch fabric. When forwarding to end devices, tags are removed again.

**Trunk Mode:** Trunk ports carry traffic for multiple VLANs simultaneously and use VLAN tagging (802.1Q or ISL) to identify which VLAN each frame belongs to. Trunks typically interconnect switches or connect switches to routers for inter-VLAN routing.

```
Switch(config)# interface gigabitethernet 0/24
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk encapsulation dot1q
Switch(config-if)# switchport trunk allowed vlan 10,20,30
Switch(config-if)# switchport trunk native vlan 99
```

The native VLAN carries untagged traffic on a trunk. By default, this is VLAN 1, but changing it is a security best practice. Frames in the native VLAN traverse the trunk without 802.1Q tags.

**Dynamic Desirable Mode:** The port actively attempts to negotiate a trunk link using Dynamic Trunking Protocol (DTP). It will form a trunk if the neighbor port is set to trunk, desirable, or auto mode.

```
Switch(config-if)# switchport mode dynamic desirable
```

**Dynamic Auto Mode:** The port passively waits for DTP negotiation. It will become a trunk only if the neighbor actively negotiates (trunk or desirable mode). If both sides are auto, they remain access ports.

```
Switch(config-if)# switchport mode dynamic auto
```

**Port Mode Negotiation (DTP):** DTP is enabled by default on Cisco switches but can be disabled for security:

```
Switch(config-if)# switchport nonegotiate
```

**Verification Commands:**

```
Switch# show interfaces [interface-id] switchport
Switch# show interfaces trunk
Switch# show dtp interface [interface-id]
```

## Port Security

Port security restricts which MAC addresses can send traffic through a switch port, protecting against MAC flooding attacks, unauthorized device connections, and network access control violations.

**Security Violation Modes:**

- **Protect**: Drops packets from unauthorized MAC addresses but doesn't log or disable the port. Traffic from authorized MACs continues normally.
- **Restrict**: Drops packets from unauthorized MACs, increments a violation counter, and logs SNMP traps and syslog messages. Port remains operational.
- **Shutdown**: Disables the port by placing it in err-disabled state, sends SNMP trap, logs syslog message. This is the default mode and requires manual or automatic recovery.

**Basic Port Security Configuration:**

```
Switch(config)# interface gigabitethernet 0/5
Switch(config-if)# switchport mode access
Switch(config-if)# switchport port-security
Switch(config-if)# switchport port-security maximum 2
Switch(config-if)# switchport port-security violation restrict
Switch(config-if)# switchport port-security mac-address sticky
```

**MAC Address Learning Methods:**

- **Static**: Manually configure allowed MAC addresses that persist in running and startup configs
    
    ```
    Switch(config-if)# switchport port-security mac-address [mac-address]
    ```
    
- **Dynamic**: Switch learns MAC addresses dynamically up to the maximum, but they're lost on reload
- **Sticky**: Dynamically learned MACs are converted to static entries in the running config and can be saved

**Aging Configuration:** Port security can age out learned MAC addresses to allow flexibility:

```
Switch(config-if)# switchport port-security aging time 120
Switch(config-if)# switchport port-security aging type {absolute | inactivity}
```

Absolute aging removes MACs after the specified time regardless of activity. Inactivity aging removes MACs only after they've been inactive for the timer duration.

**Recovery from Err-Disabled:** When a port is shut down due to violation, recovery options include:

```
! Manual recovery
Switch(config)# interface gigabitethernet 0/5
Switch(config-if)# shutdown
Switch(config-if)# no shutdown

! Automatic recovery
Switch(config)# errdisable recovery cause psecure-violation
Switch(config)# errdisable recovery interval 300
```

**Verification Commands:**

```
Switch# show port-security
Switch# show port-security interface [interface-id]
Switch# show port-security address
Switch# show errdisable recovery
```

## VLAN Configuration and Assignment

Virtual LANs (VLANs) logically segment a physical network into separate broadcast domains, improving security, performance, and management flexibility. Each VLAN operates as if it were a separate physical LAN.

**VLAN Ranges:**

- **Normal Range VLANs (1-1005)**: Stored in vlan.dat file in flash memory, can be configured in global configuration mode, supports VTP
- **Extended Range VLANs (1006-4094)**: Stored only in running configuration, requires VTP transparent mode, not all features supported on all platforms
- **Reserved VLANs**: VLAN 1 (default), 1002-1005 (Token Ring and FDDI defaults)

**Creating VLANs:**

```
Switch(config)# vlan 10
Switch(config-vlan)# name SALES
Switch(config-vlan)# exit

Switch(config)# vlan 20
Switch(config-vlan)# name ENGINEERING
Switch(config-vlan)# exit

Switch(config)# vlan 30
Switch(config-vlan)# name MANAGEMENT
```

**Assigning Ports to VLANs:**

```
Switch(config)# interface gigabitethernet 0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10

! Range assignment
Switch(config)# interface range gigabitethernet 0/2-10
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 20
```

**VLAN 1 Considerations:** VLAN 1 is the default VLAN for all ports and cannot be deleted. It carries control plane traffic like CDP, VTP, PAgP, DTP, and STP BPDUs. Best practice is to avoid using VLAN 1 for user data and configure an alternative native VLAN on trunks.

**Voice VLANs:** Cisco IP phones can use dual VLANs - one for voice traffic and one for data from connected PCs:

```
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
Switch(config-if)# switchport voice vlan 50
```

The phone tags voice traffic with VLAN 50 while passing data traffic untagged in VLAN 10.

**Deleting VLANs:**

```
Switch(config)# no vlan 10

! Delete entire VLAN database
Switch# delete flash:vlan.dat
Switch# reload
```

**Verification Commands:**

```
Switch# show vlan brief
Switch# show vlan id [vlan-id]
Switch# show vlan name [vlan-name]
Switch# show interfaces [interface-id] switchport
Switch# show running-config
```

## VLAN Trunking Protocol (VTP)

VTP is a Cisco proprietary protocol that propagates VLAN configuration changes across a switched network, reducing administrative overhead in large environments. VTP operates over trunk links and can automatically add, delete, or rename VLANs across multiple switches.

**VTP Modes:**

- **Server**: Can create, modify, and delete VLANs. Advertises VLAN information and synchronizes with other switches. Default mode on Cisco switches. VLAN configuration stored in vlan.dat.
- **Client**: Cannot create, modify, or delete VLANs locally. Receives and forwards VTP advertisements. Synchronizes VLAN database with servers. VLAN configuration not stored locally after reload.
- **Transparent**: Can create, modify, and delete VLANs locally, but changes are not propagated. Forwards VTP advertisements from other switches without processing them. VLAN configuration stored in running config.
- **Off** (VTPv3 only): Disables VTP entirely. Does not process or forward VTP advertisements.

**VTP Configuration:**

```
Switch(config)# vtp domain COMPANY
Switch(config)# vtp mode {server | client | transparent}
Switch(config)# vtp password SecurePass123
Switch(config)# vtp version {1 | 2 | 3}
Switch(config)# vtp pruning
```

**VTP Domain:** All switches in a VTP domain must share the same domain name (case-sensitive). Switches only accept VTP advertisements from switches in the same domain. A switch with a null domain name accepts the first VTP advertisement it receives.

**VTP Revision Number:** VTP uses configuration revision numbers to determine which switch has the most recent VLAN information. Each time a VLAN change is made on a server, the revision number increments by one. When a switch receives an advertisement with a higher revision number, it overwrites its local VLAN database.

**VTP Pruning:** VTP pruning increases available bandwidth by restricting flooded traffic to trunk links that actually need it. If a VLAN has no active ports on a switch, pruning prevents broadcasts and unknown unicast traffic for that VLAN from traversing the trunk.

```
Switch(config)# vtp pruning
Switch(config)# interface gigabitethernet 0/24
Switch(config-if)# switchport trunk pruning vlan 10,20,30
```

**VTP Version Differences:**

- **VTP v1**: Basic VLAN propagation, supports normal range VLANs (1-1005)
- **VTP v2**: Adds support for Token Ring VLANs and unrecognized Type-Length-Value (TLV) forwarding
- **VTP v3**: Supports extended range VLANs, requires primary server election, enhanced authentication, private VLAN support

**VTP Security Considerations:** VTP can cause network-wide VLAN deletion if a switch with a higher revision number and incorrect VLAN database is connected. Best practices include:

- Always configure VTP passwords for domain authentication
- Reset revision number to zero before adding switches (change to transparent mode, then back)
- Use VTP transparent mode in smaller networks or when centralized management isn't needed
- Consider disabling VTP entirely in modern networks with configuration management tools

**Resetting VTP Revision Number:**

```
Switch(config)# vtp mode transparent
Switch(config)# vtp mode server
! Or delete vlan.dat and reload
Switch# delete flash:vlan.dat
Switch# reload
```

**Verification Commands:**

```
Switch# show vtp status
Switch# show vtp password
Switch# show vtp counters
```

## Inter-VLAN Routing

VLANs create isolated broadcast domains that cannot communicate without Layer 3 routing. Inter-VLAN routing enables traffic to flow between different VLANs through a router or Layer 3 switch.

**Router-on-a-Stick (Legacy Method):** A single router interface connects to a switch trunk, with subinterfaces configured for each VLAN. Each subinterface has an IP address serving as the default gateway for its respective VLAN.

```
! Router configuration
Router(config)# interface gigabitethernet 0/0
Router(config-if)# no shutdown
Router(config-if)# exit

Router(config)# interface gigabitethernet 0/0.10
Router(config-subif)# encapsulation dot1q 10
Router(config-subif)# ip address 192.168.10.1 255.255.255.0
Router(config-subif)# exit

Router(config)# interface gigabitethernet 0/0.20
Router(config-subif)# encapsulation dot1q 20
Router(config-subif)# ip address 192.168.20.1 255.255.255.0
Router(config-subif)# exit

! Switch trunk configuration
Switch(config)# interface gigabitethernet 0/1
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk allowed vlan 10,20
```

Each subinterface uses 802.1Q encapsulation to tag frames with the appropriate VLAN ID. Traffic from VLAN 10 arrives at subinterface 0/0.10, gets routed by the router, and returns through the appropriate subinterface.

**Layer 3 Switch (Modern Method):** Multilayer switches perform routing directly in hardware using ASICs (Application-Specific Integrated Circuits), providing wire-speed inter-VLAN routing without the bottleneck of an external router.

```
! Enable IP routing
Switch(config)# ip routing

! Configure SVIs for each VLAN
Switch(config)# interface vlan 10
Switch(config-if)# ip address 192.168.10.1 255.255.255.0
Switch(config-if)# no shutdown
Switch(config-if)# exit

Switch(config)# interface vlan 20
Switch(config-if)# ip address 192.168.20.1 255.255.255.0
Switch(config-if)# no shutdown
Switch(config-if)# exit

! Configure access ports
Switch(config)# interface range gigabitethernet 0/1-10
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 10

Switch(config)# interface range gigabitethernet 0/11-20
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 20
```

**Routed Ports on Layer 3 Switches:** Physical switch ports can be configured as routed interfaces (no switching), functioning like router interfaces:

```
Switch(config)# interface gigabitethernet 0/1
Switch(config-if)# no switchport
Switch(config-if)# ip address 10.1.1.1 255.255.255.0
Switch(config-if)# no shutdown
```

**Routing Protocol Configuration:** Layer 3 switches can run routing protocols to exchange routes with other Layer 3 devices:

```
Switch(config)# router ospf 1
Switch(config-router)# network 192.168.10.0 0.0.0.255 area 0
Switch(config-router)# network 192.168.20.0 0.0.0.255 area 0
```

**Verification Commands:**

```
Switch# show ip interface brief
Switch# show ip route
Switch# show interfaces trunk
Switch# show vlan brief
Router# show ip interface brief
Router# show ip route
```

## Switch Virtual Interfaces (SVIs)

Switch Virtual Interfaces are logical Layer 3 interfaces associated with VLANs on a switch. SVIs enable remote management, inter-VLAN routing, and provide default gateway functionality for VLANs.

**SVI Characteristics:**

- Each VLAN can have one SVI assigned with an IP address
- SVIs exist in software; they have no physical interface
- The SVI for a VLAN becomes active when at least one port in that VLAN is up/up and forwarding
- SVIs can be managed, monitored, and configured like physical interfaces
- SVIs reduce the number of physical interfaces required for routing between VLANs

**Creating SVIs:**

```
Switch(config)# interface vlan 10
Switch(config-if)# ip address 192.168.10.1 255.255.255.0
Switch(config-if)# description Sales Department Gateway
Switch(config-if)# no shutdown

Switch(config)# interface vlan 20
Switch(config-if)# ip address 192.168.20.1 255.255.255.0
Switch(config-if)# description Engineering Gateway
Switch(config-if)# no shutdown
```

**Management VLAN SVI:** The management VLAN allows remote access to the switch via Telnet, SSH, or HTTP. Typically configured on a dedicated VLAN separate from user data:

```
Switch(config)# vlan 99
Switch(config-vlan)# name MANAGEMENT
Switch(config-vlan)# exit

Switch(config)# interface vlan 99
Switch(config-if)# ip address 192.168.99.2 255.255.255.0
Switch(config-if)# no shutdown
Switch(config-if)# exit

Switch(config)# ip default-gateway 192.168.99.1
```

The `ip default-gateway` command is required on Layer 2 switches to reach management networks beyond the local subnet. Layer 3 switches use routing tables instead.

**SVI Requirements:** For an SVI to reach the up/up state:

1. The VLAN must exist in the VLAN database
2. The VLAN must have at least one access port or trunk port carrying that VLAN in an up/up state
3. The SVI must not be manually shutdown
4. IP routing must be enabled if used for inter-VLAN routing (`ip routing`)

**SVI Benefits:**

- Eliminates need for separate physical interfaces for each VLAN
- Faster routing performance (hardware-based)
- Simplified cabling and reduced equipment costs
- Provides gateway functionality for hosts in VLANs
- Enables dynamic routing protocol participation

**SVI Limitations:**

- Not all switch models support SVIs (requires Layer 3 capabilities)
- Number of SVIs may be limited by switch platform
- Each SVI consumes memory and processing resources
- SVI state depends on underlying VLAN and port status

**Configuring SVI Helper Features:**

```
! DHCP relay for hosts using external DHCP server
Switch(config)# interface vlan 10
Switch(config-if)# ip helper-address 192.168.100.10

! HSRP for gateway redundancy
Switch(config)# interface vlan 10
Switch(config-if)# standby 1 ip 192.168.10.1
Switch(config-if)# standby 1 priority 110
Switch(config-if)# standby 1 preempt
```

**Verification Commands:**

```
Switch# show ip interface brief
Switch# show interfaces vlan 10
Switch# show ip route
Switch# show vlan brief
Switch# show ip interface vlan 10
```

**Key points:**

- Layer 2 switches forward based on MAC addresses and learn dynamically, maintaining a MAC address table with aging timers.
- Switch ports operate as access (single VLAN, untagged), trunk (multiple VLANs, tagged), or dynamic modes with DTP negotiation.
- Port security restricts MAC addresses per port with protect, restrict, or shutdown violation actions to prevent unauthorized access.
- VLANs segment networks into logical broadcast domains with normal range (1-1005) and extended range (1006-4094) support.
- VTP propagates VLAN configurations across switches in server, client, or transparent modes using revision numbers for synchronization.
- Inter-VLAN routing uses router-on-a-stick with subinterfaces or Layer 3 switches with SVIs for hardware-based routing.
- SVIs provide Layer 3 gateway functionality for VLANs and enable switch management without requiring physical routed interfaces.

---

# Spanning Tree Protocol

## Spanning Tree Protocol Fundamentals and Operation

Spanning Tree Protocol (STP) is a Layer 2 network protocol designed to prevent loops in switched Ethernet networks. Network loops occur when multiple physical paths exist between switches, causing broadcast storms, MAC address table instability, and frame duplication. Without loop prevention, a single broadcast frame would circulate indefinitely, consuming all available bandwidth within seconds.

**The Loop Problem**

In a redundant switched network, broadcast frames are flooded out all ports except the incoming port. If multiple paths exist between switches, these frames return to their origin, get flooded again, and multiply exponentially. Simultaneously, switches receive the same frame on different ports with identical source MAC addresses, causing MAC address table thrashing as the switch constantly updates which port leads to that MAC address.

**STP Solution**

STP creates a loop-free logical topology by strategically blocking redundant paths while maintaining physical redundancy. When a link fails, STP recalculates and unblocks alternate paths, restoring connectivity. The protocol operates by having switches exchange Bridge Protocol Data Units (BPDUs) containing information about bridge IDs, path costs, and port roles.

**IEEE Standards**

The original STP is defined in IEEE 802.1D (1990). This standard has evolved through several iterations:

- **802.1D (original)**: Convergence time of 30-50 seconds
- **802.1D-2004**: Incorporated Rapid Spanning Tree Protocol improvements
- **802.1w**: Rapid Spanning Tree Protocol (RSTP) - convergence in 1-3 seconds
- **802.1s**: Multiple Spanning Tree Protocol (MST) - maps multiple VLANs to spanning tree instances

**BPDU Structure**

BPDUs carry STP information between switches. Configuration BPDUs (sent every 2 seconds by default) contain:

- Root Bridge ID (priority + MAC address)
- Root Path Cost (cumulative cost to reach root bridge)
- Sender Bridge ID
- Sender Port ID
- Message Age, Max Age, Hello Time, Forward Delay timers

Topology Change Notification (TCN) BPDUs signal network topology changes to the root bridge.

**STP Algorithm Operation**

STP follows a four-step process:

1. **Elect one root bridge**: All switches in the broadcast domain participate in selecting a single root bridge based on lowest bridge ID.
    
2. **Select root ports**: Each non-root switch selects one root port—the port with the lowest path cost to reach the root bridge.
    
3. **Select designated ports**: For each network segment, one designated port is chosen—the port with the lowest cost path to the root bridge for that segment.
    
4. **Block non-designated ports**: All remaining ports are placed in blocking state to prevent loops.
    

**Bridge ID Components**

The Bridge ID is an 8-byte value combining:

- **Bridge Priority** (2 bytes): Default 32768, configurable in increments of 4096 (values 0-61440)
- **MAC Address** (6 bytes): Lowest MAC address on the switch

In modern implementations (PVST+), the priority field is subdivided:

- 4 bits for priority (0-15, representing 0-61440 in 4096 increments)
- 12 bits for VLAN ID (extended system ID)

The effective priority becomes: (configured priority) + (VLAN ID). For VLAN 10 with priority 32768: 32768 + 10 = 32778.

**Path Cost Calculation**

STP uses cumulative path cost to determine best paths. Port costs are based on bandwidth:

**Original 802.1D Costs:**

- 10 Mbps: 100
- 100 Mbps: 19
- 1 Gbps: 4
- 10 Gbps: 2

**Revised 802.1D-1998 Costs:**

- 10 Mbps: 2,000,000
- 100 Mbps: 200,000
- 1 Gbps: 20,000
- 10 Gbps: 2,000
- 100 Gbps: 200

Cisco switches default to the revised (long) cost method. Path cost accumulates as BPDUs traverse switches—each switch adds its ingress port cost to the received root path cost.

**Tie-Breaking Rules**

When multiple paths have equal cost, STP uses tie-breakers in order:

1. Lowest root bridge ID
2. Lowest root path cost
3. Lowest sender bridge ID
4. Lowest sender port ID
5. Lowest receiver port ID

## PVST+ (Per-VLAN Spanning Tree Plus)

PVST+ is a Cisco proprietary enhancement to STP that runs a separate spanning tree instance for each VLAN. Standard 802.1D runs a single spanning tree for all VLANs, which cannot load-balance traffic across redundant links—all VLANs use the same blocked/forwarding ports.

**PVST+ Operation**

Each VLAN maintains its own:

- Root bridge election
- Port roles and states
- BPDU exchange (using VLAN-specific BPDUs)
- Convergence timers

This independence allows different root bridges per VLAN, enabling load balancing across redundant links. VLAN 10 traffic might forward through Switch A while VLAN 20 traffic forwards through Switch B, utilizing multiple physical paths simultaneously.

**PVST+ BPDUs**

PVST+ uses:

- **PVST+ BPDUs**: Sent on native VLAN (untagged) for trunk ports, encapsulated in SNAP format with destination MAC 01:00:0C:CC:CC:CD
- **Standard 802.1D BPDUs**: Also sent on native VLAN for backward compatibility

On 802.1Q trunks, PVST+ sends separate BPDUs for each VLAN, tagged with appropriate VLAN IDs.

**Configuration Example**

```
! Configure Switch A as root for VLANs 10, 30
spanning-tree vlan 10,30 priority 24576
spanning-tree vlan 20,40 priority 28672

! Configure Switch B as root for VLANs 20, 40
spanning-tree vlan 10,30 priority 28672
spanning-tree vlan 20,40 priority 24576
```

This configuration creates active/active load balancing where each switch is primary root for half the VLANs.

**Verification Commands**

- `show spanning-tree`: Displays spanning tree status for all VLANs
- `show spanning-tree vlan 10`: Shows VLAN-specific spanning tree details
- `show spanning-tree summary`: Overview of spanning tree mode and VLAN instances
- `show spanning-tree root`: Shows root bridge information for each VLAN
- `show spanning-tree bridge`: Displays local bridge information

**PVST+ Advantages**

- Load balancing across redundant links by using different paths for different VLANs
- Flexibility in root bridge placement per VLAN
- Optimization for VLAN topology and traffic patterns

**PVST+ Disadvantages**

- High CPU and memory utilization with many VLANs (100+ VLANs = 100+ STP instances)
- Increased BPDU traffic on trunk links
- Complexity in large environments
- Cisco proprietary (interoperability limitations with non-Cisco equipment)

## Rapid PVST+

Rapid PVST+ combines Rapid Spanning Tree Protocol (RSTP / 802.1w) improvements with Cisco's per-VLAN approach. The primary enhancement is dramatically faster convergence—RSTP converges in 1-3 seconds compared to traditional STP's 30-50 seconds.

**Key RSTP Improvements**

**Enhanced Port Roles**

RSTP defines port roles more explicitly:

- **Root Port**: Best path to root bridge (same as 802.1D)
- **Designated Port**: Best path to root on a segment (same as 802.1D)
- **Alternate Port**: Backup path to root bridge (previously blocking)
- **Backup Port**: Backup path to same segment (previously blocking)
- **Disabled Port**: Administratively shut down

Alternate and backup ports remain in discarding state but can transition to forwarding much faster than 802.1D blocking ports.

**Port States**

RSTP simplifies port states:

- **Discarding**: Combines 802.1D blocking, listening, and disabled states; does not learn MAC addresses or forward frames
- **Learning**: Learns MAC addresses but does not forward frames
- **Forwarding**: Learns MAC addresses and forwards frames

This reduction from five states to three eliminates unnecessary transition delays.

**Proposal/Agreement Mechanism**

RSTP introduces rapid convergence through active negotiation between switches:

1. When a switch connects to a segment, it sends a proposal BPDU suggesting it become the designated switch
2. The receiving switch, if inferior, immediately blocks all non-edge designated ports
3. The receiving switch sends an agreement BPDU
4. The proposing switch immediately transitions its port to forwarding state

This synchronization happens in 1-2 seconds rather than waiting 30 seconds through listening and learning states.

**Edge Ports (PortFast)**

RSTP recognizes edge ports (ports connected to end devices, not switches). Edge ports immediately transition to forwarding state without waiting or sending proposals. If a BPDU is received on an edge port, it immediately loses edge port status and enters normal STP operation.

**Link Types**

RSTP recognizes three link types:

- **Point-to-point**: Full-duplex connections between switches (proposal/agreement works)
- **Shared**: Half-duplex or hub connections (falls back to 802.1D behavior)
- **Edge**: Connections to end devices

**BPDU Handling**

RSTP treats BPDUs differently:

- All switches generate and send BPDUs every hello time (2 seconds default), not just the root bridge
- If a switch misses three consecutive BPDUs (6 seconds), it considers the neighbor lost and immediately recalculates
- BPDUs act as keepalives; faster failure detection enables faster convergence

**Backward Compatibility**

Rapid PVST+ switches detect legacy 802.1D BPDUs and automatically fall back to classic STP behavior on those ports. The port operates in 802.1D mode until no legacy BPDUs are received for the migration delay period (typically 3 seconds).

**Configuration**

Rapid PVST+ is the default spanning-tree mode on modern Cisco switches:

```
! Verify or set spanning-tree mode
spanning-tree mode rapid-pvst

! Configure root bridge for VLAN 10
spanning-tree vlan 10 root primary

! Alternative: manual priority configuration
spanning-tree vlan 10 priority 24576

! Configure secondary root bridge
spanning-tree vlan 10 root secondary
```

The `root primary` command sets priority to 24576 or 4096 less than the current root, ensuring this switch becomes root. The `root secondary` command sets priority to 28672, making it the backup root.

**Verification**

```
show spanning-tree vlan 10

VLAN0010
  Spanning tree enabled protocol rstp
  Root ID    Priority    24586
             Address     0023.04ee.be01
             Cost        4
             Port        23 (GigabitEthernet1/0/23)
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32778  (priority 32768 sys-id-ext 10)
             Address     f8b7.e203.5b00
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  300 sec

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Gi1/0/23            Root FWD 4         128.23   P2p
Gi1/0/24            Altn BLK 4         128.24   P2p
```

The output shows "protocol rstp" confirming Rapid PVST+ operation, port roles (Root, Altn for Alternate), and port states (FWD for Forwarding, BLK for Blocking/Discarding).

## Root Bridge Election

Root bridge election is the foundation of STP operation. All switches in a broadcast domain participate in electing a single root bridge, which becomes the reference point for all path calculations.

**Election Process**

1. **Initial assumption**: When a switch boots, it assumes it is the root bridge and advertises itself with BPDUs containing its own bridge ID as both root bridge ID and sender bridge ID.
    
2. **BPDU comparison**: Switches receive BPDUs from neighbors and compare the advertised root bridge ID with their own belief about the root.
    
3. **Superior BPDU adoption**: If a received BPDU contains a lower root bridge ID, the switch updates its belief and begins forwarding that information. The switch changes its BPDUs to reflect the superior root bridge ID while keeping its own bridge ID as sender.
    
4. **Convergence**: Eventually all switches agree on which bridge has the lowest bridge ID. That bridge becomes the root bridge.
    

**Bridge ID Comparison**

The 8-byte bridge ID is compared as a single value, with priority being most significant:

- Priority is compared first (lower wins)
- If priorities are equal, MAC address determines the winner (lower wins)
- MAC addresses are guaranteed unique, ensuring deterministic election

**Root Bridge Characteristics**

The root bridge:

- All its ports become designated ports (forwarding state)
- Generates configuration BPDUs every hello time (2 seconds default)
- Sets the timing parameters (hello, max age, forward delay) for the entire spanning tree
- Never has a root port (it is the root)

**Strategic Root Placement**

Root bridge placement significantly affects network performance. Best practices include:

**Central placement**: Position the root bridge at the network core where it has high-bandwidth connections to all distribution switches. Placing the root at the network edge forces suboptimal traffic paths.

**Deterministic selection**: Never rely on default elections (lowest MAC address). Explicitly configure root bridges to ensure predictable topology and prevent low-end switches from becoming root.

**Primary and secondary roots**: Configure both a primary root (lowest priority) and secondary root (second-lowest priority) for redundancy. If the primary fails, the secondary automatically assumes the role without random re-election.

**Configuration Methods**

```
! Method 1: Macro command (recommended for simplicity)
spanning-tree vlan 10 root primary
spanning-tree vlan 10 root secondary

! Method 2: Manual priority (recommended for precise control)
spanning-tree vlan 10 priority 24576    ! Primary root
spanning-tree vlan 10 priority 28672    ! Secondary root

! Method 3: Ensure this switch is always root
spanning-tree vlan 10 priority 0        ! Lowest possible priority
```

The `root primary` command examines current root priority and sets local priority to 24576 (or 4096 less than current root if root priority is below 24576). The `root secondary` command sets priority to 28672.

**Priority Guidelines**

Since extended system ID uses 12 bits for VLAN ID, priority must be a multiple of 4096:

- 0, 4096, 8192, 12288, 16384, 20480, 24576, 28672, 32768 (default), 36864, 40960, 45056, 49152, 53248, 57344, 61440

Common practice:

- Primary root: 24576
- Secondary root: 28672
- All other switches: 32768 (default)

**Load Balancing Through Root Manipulation**

In networks with multiple VLANs, configure different root bridges per VLAN group for load distribution:

```
! Core Switch 1 - Root for VLANs 1-50
spanning-tree vlan 1-50 priority 24576
spanning-tree vlan 51-100 priority 28672

! Core Switch 2 - Root for VLANs 51-100
spanning-tree vlan 1-50 priority 28672
spanning-tree vlan 51-100 priority 24576
```

This configuration ensures redundant links carry production traffic rather than remaining completely blocked.

**Verification and Monitoring**

```
! View root bridge information
show spanning-tree root

                                        Root    Hello Max Fwd
Vlan                   Root ID          Cost    Time  Age Dly  Root Port
---------------- -------------------- --------- ----- --- ---  ----------------
VLAN0010         24586 0023.04ee.be01        4     2   20  15  Gi1/0/23
VLAN0020         24596 0023.04ee.be01        4     2   20  15  Gi1/0/23

! View local bridge information  
show spanning-tree bridge

                                                   Hello  Max  Fwd
Vlan                         Bridge ID              Time  Age  Dly  Protocol
---------------- --------------------------------- -----  ---  ---  --------
VLAN0010         32778 (32768, 10) f8b7.e203.5b00    2    20   15  rstp
VLAN0020         32788 (32768, 20) f8b7.e203.5b00    2    20   15  rstp

! Detailed VLAN spanning tree view
show spanning-tree vlan 10
```

## Port Roles and States

STP assigns roles and states to switch ports based on their position in the spanning tree topology. Understanding these roles and states is critical for troubleshooting and optimization.

**Port Roles (802.1D and RSTP)**

**Root Port**

- One root port per non-root switch
- Port with best path (lowest cost) to root bridge
- Always in forwarding state [Inference: in a stable topology]
- Selection criteria: lowest root path cost, then tie-breakers (sender bridge ID, sender port ID, receiver port ID)
- If root port fails, the switch recalculates and promotes alternate port to root port

**Designated Port**

- One designated port per network segment
- Port with best path to root on that segment
- Always in forwarding state [Inference: in a stable topology]
- On root bridge, all ports are designated ports
- Designated port "represents" that segment's connection toward the root

**Alternate Port (RSTP)**

- Backup path to root bridge
- Receives BPDUs from another switch that has a better path to root
- In discarding state but ready for rapid transition
- If root port fails, alternate port can immediately transition to root port (within 1-3 seconds in RSTP)

**Backup Port (RSTP)**

- Backup connection to the same segment
- Receives BPDUs from the same switch (typically hub scenario or loopback)
- In discarding state
- Less common in modern switched networks

**Disabled Port**

- Administratively shut down
- Does not participate in spanning tree

**Port States (802.1D Classic STP)**

**Blocking**

- Does not forward frames
- Does not learn MAC addresses
- Receives BPDUs only
- Prevents loops while maintaining topology awareness
- Transition to listening: 20 seconds (max age timer)

**Listening**

- Does not forward frames
- Does not learn MAC addresses
- Sends and receives BPDUs
- Builds active topology knowledge
- Duration: 15 seconds (forward delay timer)

**Learning**

- Does not forward frames
- Learns MAC addresses and populates MAC address table
- Sends and receives BPDUs
- Prepares for forwarding by building MAC table
- Duration: 15 seconds (forward delay timer)

**Forwarding**

- Forwards frames
- Learns MAC addresses
- Sends and receives BPDUs
- Normal operational state for root and designated ports

**Disabled**

- Administratively down
- Does not participate in STP

**Transition Timeline (802.1D)**

When a blocked port transitions to forwarding:

- Blocking → Listening: 20 seconds (max age)
- Listening → Learning: 15 seconds (forward delay)
- Learning → Forwarding: 15 seconds (forward delay)
- Total: 50 seconds (20 + 15 + 15)

In practice, convergence typically takes 30-50 seconds depending on when topology change occurs relative to timers.

**Port States (RSTP/Rapid PVST+)**

**Discarding**

- Combines 802.1D blocking, listening, and disabled states
- Does not forward frames or learn MAC addresses
- Receives BPDUs
- Alternate and backup ports remain in discarding state

**Learning**

- Does not forward frames
- Learns MAC addresses
- Rapid transition possible with proposal/agreement

**Forwarding**

- Forwards frames
- Learns MAC addresses
- Normal operational state

**RSTP State Transitions**

RSTP achieves faster convergence through:

- Edge ports: Immediate transition to forwarding (0 seconds)
- Point-to-point links with proposal/agreement: 1-3 seconds
- Loss of BPDU (3 missed hellos): Immediate alternate port promotion (≈6 seconds detection + 1-3 seconds transition)

**Port Role and State Verification**

```
show spanning-tree vlan 10

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Gi1/0/1             Desg FWD 4         128.1    P2p Edge
Gi1/0/23            Root FWD 4         128.23   P2p
Gi1/0/24            Altn BLK 4         128.24   P2p
```

- **Role**: Root, Desg (Designated), Altn (Alternate), Back (Backup)
- **Sts**: FWD (Forwarding), BLK (Blocking/Discarding), LRN (Learning), LIS (Listening)
- **Type**: P2p (point-to-point), Shr (shared), Edge (PortFast enabled)

**Detailed Port Information**

```
show spanning-tree interface gigabitethernet1/0/23 detail

Port 23 (GigabitEthernet1/0/23) of VLAN0010 is designated forwarding
  Port path cost 4, Port priority 128, Port Identifier 128.23
  Designated root has priority 24586, address 0023.04ee.be01
  Designated bridge has priority 24586, address 0023.04ee.be01
  Designated port id is 128.23, designated path cost 0
  Timers: message age 0, forward delay 0, hold 0
  Number of transitions to forwarding state: 1
  Link type is point-to-point by default
  BPDU: sent 3524, received 0
```

This output shows BPDU statistics, path costs, transition counts, and detailed role information useful for troubleshooting convergence issues or suboptimal paths.

## PortFast and BPDU Guard

PortFast and BPDU Guard are complementary features that optimize STP behavior for end-device connections while maintaining network security.

**PortFast Operation**

PortFast (called "Edge Port" in RSTP terminology) instructs a switch port to immediately transition to forwarding state when connected, bypassing listening and learning states. This eliminates the 30-second delay that would otherwise occur when an end device (workstation, printer, server) connects to the network.

**When to Use PortFast**

PortFast should be enabled only on access ports connecting to end devices:

- Workstations and laptops
- Printers and copiers
- IP phones
- Servers (single-attached)
- Access points
- Cameras and IoT devices

**When NOT to Use PortFast**

Never enable PortFast on:

- Trunk ports between switches
- Ports connecting to other switches
- Ports connecting to hubs
- Any port that could receive BPDUs from another switch

Enabling PortFast on inter-switch connections can create temporary loops during topology changes, potentially causing network outages.

**PortFast Configuration**

```
! Enable PortFast on specific interface
interface gigabitethernet1/0/5
 switchport mode access
 spanning-tree portfast
 
! Enable PortFast on all access ports globally
spanning-tree portfast default

! Disable PortFast on specific interface (if globally enabled)
interface gigabitethernet1/0/23
 spanning-tree portfast disable
```

When enabling PortFast, the switch displays a warning:

```
%Warning: portfast should only be enabled on ports connected to a single
host. Connecting hubs, concentrators, switches, bridges, etc... to this
interface when portfast is enabled, can cause temporary bridging loops.
Use with CAUTION
```

**PortFast Behavior**

- Port immediately enters forwarding state when link comes up
- If BPDU is received, PortFast is automatically disabled on that port
- Port enters normal STP operation if BPDUs detected
- TCN (Topology Change Notification) is not generated when PortFast port goes up/down (reduces unnecessary MAC table flushes)

**BPDU Guard Operation**

BPDU Guard provides security by shutting down ports if BPDUs are received. This prevents unauthorized switches from connecting to the network and potentially disrupting the spanning tree topology or creating loops.

**BPDU Guard Use Cases**

- Enforce policy that end-user ports never connect to switches
- Prevent rogue switches from being introduced to the network
- Protect against malicious attacks attempting to manipulate spanning tree
- Detect misconfigured ports (PortFast enabled on uplink ports)
- Meet security compliance requirements

**BPDU Guard Configuration**

```
! Enable BPDU Guard on specific interface
interface gigabitethernet1/0/5
 spanning-tree portfast
 spanning-tree bpduguard enable

! Enable BPDU Guard globally on all PortFast ports
spanning-tree portfast bpduguard default
```

The global configuration automatically applies BPDU Guard to all interfaces with PortFast enabled (either explicitly or via `portfast default`).

**BPDU Guard Behavior**

When BPDU Guard is enabled and a BPDU is received:

1. Port is immediately placed in err-disabled state
2. Syslog message is generated indicating BPDU Guard violation
3. Port LED typically turns amber/orange
4. Port remains disabled until manually recovered or auto-recovery is configured

**Recovery from err-disabled**

```
! Manual recovery
interface gigabitethernet1/0/5
 shutdown
 no shutdown

! Configure automatic recovery (global configuration)
errdisable recovery cause bpduguard
errdisable recovery interval 300

! Verify err-disabled status
show interfaces status err-disabled
show errdisable recovery
```

Auto-recovery automatically brings the port back up after the configured interval (300 seconds = 5 minutes). This is useful in environments where temporary misconnections occur, though manual recovery provides better security oversight.

**Verification**

```
! Verify PortFast configuration
show running-config interface gigabitethernet1/0/5

interface GigabitEthernet1/0/5
 switchport mode access
 spanning-tree portfast
 spanning-tree bpduguard enable

! Check spanning-tree interface details
show spanning-tree interface gi1/0/5 detail

Port 5 (GigabitEthernet1/0/5) of VLAN0010 is designated forwarding
  Port path cost 4, Port priority 128, Port Identifier 128.5
  Designated root has priority 24586, address 0023.04ee.be01
  Designated bridge has priority 32778, address f8b7.e203.5b00
  Designated port id is 128.5, designated path cost 4
  Timers: message age 0, forward delay 0, hold 0
  Number of transitions to forwarding state: 1
  Link type is point-to-point by default
  Bpdu guard is enabled
  BPDU: sent 245, received 0

! View err-disabled interfaces
show interfaces status err-disabled

Port      Name               Status       Reason               Err-disabled Vlans
Gi1/0/8                      err-disabled bpduguard
```

**Best Practice Configuration Template**

```
! Global configuration for all access ports
spanning-tree portfast default
spanning-tree portfast bpduguard default

! Enable auto-recovery with notification monitoring
errdisable recovery cause bpduguard
errdisable recovery interval 300

! Configure specific access port
interface range gigabitethernet1/0/1-48
 switchport mode access
 switchport access vlan 10
 ! PortFast and BPDU Guard applied via global defaults
 
! Explicitly disable on uplinks
interface range gigabitethernet1/0/49-52
 switchport mode trunk
 spanning-tree portfast disable
 spanning-tree bpduguard disable
```

**Additional Guard Features**

**Root Guard** Prevents external switches from becoming root bridge. If superior BPDUs are received, the port enters root-inconsistent state.

```
interface gigabitethernet1/0/23
 spanning-tree guard root
```

**Loop Guard** Prevents alternate or root ports from becoming designated ports due to unidirectional link failure.

```
interface gigabitethernet1/0/23
 spanning-tree guard loop
```

## STP Tuning and Optimization

Optimizing spanning tree involves adjusting timers, costs, and priorities to achieve faster convergence, optimal load balancing, and predictable behavior.

**Timer Adjustment**

STP uses three primary timers:

- **Hello Time**: Interval between configuration BPDUs (default 2 seconds)
- **Max Age**: How long a switch waits before declaring a BPDU aged out (default 20 seconds)
- **Forward Delay**: Time spent in listening and learning states (default 15 seconds each)

**Timer Configuration**

```
! Configure timers on root bridge (propagates to entire tree)
spanning-tree vlan 10 hello-time 1
spanning-tree vlan 10 max-age 10
spanning-tree vlan 10 forward-time 10
```

**Timer Relationships and Constraints**

IEEE 802.1D defines mathematical relationships between timers to prevent instability:

- Max Age ≥ 2 × (Hello Time + 1)
- Forward Delay ≥ (Max Age / 2) + 1

Example valid combinations:

- Hello 1s, Max Age 6s, Forward Delay 4s (aggressive)
- Hello 2s, Max Age 20s, Forward Delay 15s (default)

**[Inference] Aggressive Timer Risks:**

Reducing timers accelerates convergence but increases risks:

- False-positive topology changes from transient link flaps
- Increased CPU utilization processing frequent BPDUs
- Greater sensitivity to network congestion causing BPDU loss
- Potential instability in large topologies

Modern deployments typically use RSTP/Rapid PVST+ rather than timer tuning for faster convergence.

**Cost-Based Path Manipulation**

Modifying port costs influences path selection without changing root bridge:

```
! Increase cost to make path less preferred
interface gigabitethernet1/0/24
 spanning-tree vlan 10 cost 100

! Decrease cost to make path more preferred  
interface gigabitethernet1/0/23
 spanning-tree vlan 10 cost 1
```

**Cost Manipulation Use Cases:**

- Force traffic through higher-bandwidth links when physical speeds don't reflect capacity differences
- Implement traffic engineering for specific VLANs
- Work around physical topology constraints
- Test failover scenarios

**Priority-Based Port Selection**

When multiple ports have equal cost to root, port priority determines selection (lower priority wins, default 128):

```
interface gigabitethernet1/0/23
 spanning-tree vlan 10 port-priority 64
```

Port priority ranges 0-224 in increments of 16: 0, 16, 32, 48, 64, 80, 96, 112, 128 (default), 144, 160, 176, 192, 208, 224.

**Backbone Fast and Uplink Fast (Legacy 802.1D Optimizations)**

These Cisco proprietary features accelerate 802.1D convergence but are superseded by RSTP:

**BackboneFast**: Reduces convergence from 50 seconds to 30 seconds when indirect link failure occurs (failure not directly connected to the switch). Enabled with `spanning-tree backbonefast`.

**UplinkFast**: Reduces convergence to 1-3 seconds for direct link failures on access switches. Modifies bridge priority to 49152 and port costs by +3000, ensuring the switch is never elected root. Enabled with `spanning-tree uplinkfast`.

These features are unnecessary with RSTP/Rapid PVST+, which provides equivalent or better convergence natively.

**BPDU Filtering**

BPDU filtering prevents ports from sending or receiving BPDUs:

```
! Global configuration (affects PortFast ports)
spanning-tree portfast bpdufilter default

! Interface-specific configuration
interface gigabitethernet1/0/5
 spanning-tree bpdufilter enable
```

**Global BPDU filter behavior**: PortFast ports don't send BPDUs initially. If BPDU is received, BPDU filtering is disabled and port operates normally. This allows PortFast ports to avoid sending unnecessary BPDUs while detecting switch connections.

**Interface-specific BPDU filter behavior**: Port never sends or receives BPDUs. Spanning tree is effectively disabled on that port. **[Unverified: This configuration is extremely dangerous and should rarely be used, as it can create loops if another switch connects.]**

**Appropriate BPDU Filtering Use Cases:**

- Service provider demarcation points where customer equipment shouldn't participate in provider STP
- Specific security boundaries requiring complete STP isolation
- Integration with legacy equipment that malfunctions when receiving BPDUs

**BPDU filtering should not be used as a substitute for BPDU Guard**, as it silently ignores BPDUs rather than shutting down the port, providing no security notification or protection.

**Topology Change Optimization**

When topology changes occur, switches flush MAC address tables and relearn MAC addresses, temporarily causing flooding of unicast traffic. Reducing unnecessary topology changes improves stability:

```
! Enable PortFast on access ports (prevents TCN on link flap)
spanning-tree portfast default

! Configure TCN suppression
interface gigabitethernet1/0/5
 switchport mode access
 spanning-tree portfast
```

PortFast ports do not generate Topology Change Notifications (TCNs) when their link state changes, preventing unnecessary MAC table flushes throughout the network when end devices disconnect or reboot.

**Load Balancing Strategies**

**VLAN-Based Load Balancing:**

Distribute traffic across redundant links by varying root bridge per VLAN:

```
! Core Switch 1
spanning-tree vlan 10,30,50 priority 24576
spanning-tree vlan 20,40,60 priority 28672

! Core Switch 2  
spanning-tree vlan 10,30,50 priority 28672
spanning-tree vlan 20,40,60 priority 24576
```

**Cost-Based Load Balancing:**

Manipulate costs to distribute traffic when root bridge must remain consistent:

```
! Switch A - prefer path through uplink 1 for VLAN 10
interface gigabitethernet1/0/23
 spanning-tree vlan 10 cost 10
interface gigabitethernet1/0/24
 spanning-tree vlan 10 cost 20

! Same switch - prefer path through uplink 2 for VLAN 20
interface gigabitethernet1/0/23
 spanning-tree vlan 20 cost 20
interface gigabitethernet1/0/24
 spanning-tree vlan 20 cost 10
```

**Link Aggregation as STP Alternative:**

EtherChannel (IEEE 802.3ad / LACP) bundles multiple physical links into a logical link, appearing as a single interface to spanning tree:

```
interface range gigabitethernet1/0/23-24
 channel-group 1 mode active
 
interface port-channel1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30
```

This provides true load balancing across member links while maintaining loop prevention, avoiding STP's inherent blocking of redundant paths.

**Verification and Monitoring**

```
! View spanning-tree inconsistencies
show spanning-tree inconsistentports

! Monitor root bridge changes
show spanning-tree root history

! View topology changes
show spanning-tree detail | include topology

! Monitor per-VLAN costs and priorities
show spanning-tree vlan 10 | include cost|priority
```

**Optimization Best Practices:**

- Use Rapid PVST+ or MST instead of legacy 802.1D
- Implement PortFast on all access ports connecting to end devices
- Enable BPDU Guard globally for security
- Explicitly configure root bridges rather than relying on default election
- Configure secondary root bridges for redundancy
- Use EtherChannel for true load balancing rather than complex STP manipulation
- Document all non-default configurations for troubleshooting
- Monitor topology changes through syslog and SNMP traps
- Establish change control procedures for spanning tree modifications

**Common Tuning Mistakes:**

- Setting timers too aggressively causing instability
- Enabling PortFast on inter-switch links creating temporary loops
- Using BPDU filtering instead of BPDU Guard
- Configuring multiple VLANs with identical priorities defeating load balancing
- Modifying costs without understanding full topology impact
- Forgetting to configure secondary root bridge
- Over-complicating STP design rather than using simpler architectures (like L3 to access layer)

## Multiple Spanning Tree (MST)

Multiple Spanning Tree Protocol (MST / IEEE 802.1s) addresses scalability limitations of PVST+ by mapping multiple VLANs to spanning tree instances. While PVST+ requires a separate STP instance per VLAN (100 VLANs = 100 instances), MST groups VLANs into instances, drastically reducing CPU and memory consumption.

**MST Fundamentals**

MST divides the network into MST regions. Within each region:

- Multiple VLANs map to a limited number of instances (typically 1-16)
- Internal Spanning Tree (IST) coordinates between instances
- Common Spanning Tree (CST) connects different regions

All switches in an MST region must have:

- Same MST configuration name
- Same MST configuration revision number
- Same VLAN-to-instance mapping

Switches with matching configurations belong to the same region; different configurations create separate regions.

**MST Instances**

MST supports up to 65 instances (0-4094), though practical deployments use far fewer:

- **Instance 0 (IST)**: Internal Spanning Tree, mandatory, includes all VLANs not explicitly mapped
- **Instances 1-4094**: User-defined mappings

**Example MST Design:**

- Instance 0: Management VLANs (1, 99)
- Instance 1: User VLANs (10-50)
- Instance 2: Voice VLANs (100-150)
- Instance 3: Guest VLANs (200-250)

This reduces 241 PVST+ instances to 4 MST instances, decreasing resource consumption by approximately 98%.

**MST Configuration**

```
! Enter MST configuration mode
spanning-tree mode mst

! Configure MST region parameters
spanning-tree mst configuration
 name REGION_WEST
 revision 1
 instance 1 vlan 10-50
 instance 2 vlan 100-150
 instance 3 vlan 200-250
 exit

! Configure root bridge for instances
spanning-tree mst 0 priority 24576
spanning-tree mst 1 priority 24576
spanning-tree mst 2 priority 28672
spanning-tree mst 3 priority 28672

! Verify configuration before applying
show spanning-tree mst configuration
```

**Critical MST Configuration Rules:**

All switches in a region must have **identical** configuration:

- Region name must match exactly (case-sensitive)
- Revision number must match
- VLAN-to-instance mappings must be identical

A single mismatch causes switches to operate in different regions, creating a CST boundary with suboptimal convergence.

**MST Region Boundaries**

When MST regions connect to each other or to PVST+ domains:

- CST provides inter-region connectivity
- IST Instance 0 represents the entire region to external networks
- Region appears as a single virtual switch to external topology

**MST Port Roles**

MST uses RSTP port roles with enhancements:

- **Root Port**: Best path to CIST (Combined IST) root
- **Designated Port**: Best path for segment
- **Alternate Port**: Backup path to root
- **Backup Port**: Backup to same segment
- **Master Port**: Connects MST region to CIST root (at region boundary)
- **Boundary Port**: Connects to different MST region or PVST+ domain

**MST and PVST+ Interoperability**

MST can coexist with PVST+ through boundary ports. Boundary port behavior:

- MST switch generates PVST+ BPDUs on boundary ports for all VLANs
- IST Instance 0 interacts with all PVST+ VLANs
- If PVST+ topology is inconsistent (different root per VLAN), MST may detect inconsistency

**[Inference] This interoperability adds complexity** and is typically avoided in production by standardizing on one protocol per network domain.

**MST Convergence**

MST inherits RSTP's rapid convergence mechanisms:

- Proposal/agreement handshake on point-to-point links
- Edge ports transition immediately to forwarding
- Convergence typically completes in 1-3 seconds
- Independent convergence per instance within region

**MST Load Balancing**

Configure different root bridges per instance for load distribution:

```
! Core Switch 1 - root for instances 0 and 1
spanning-tree mst 0 priority 24576
spanning-tree mst 1 priority 24576
spanning-tree mst 2 priority 28672
spanning-tree mst 3 priority 28672

! Core Switch 2 - root for instances 2 and 3
spanning-tree mst 0 priority 28672
spanning-tree mst 1 priority 28672
spanning-tree mst 2 priority 24576
spanning-tree mst 3 priority 24576
```

VLANs in instances 0-1 use paths through Core Switch 1, while VLANs in instances 2-3 use paths through Core Switch 2, achieving load distribution across redundant links.

**MST Verification**

```
! Verify MST configuration
show spanning-tree mst configuration

Name      [REGION_WEST]
Revision  1     Instances configured 4

Instance  Vlans mapped
--------  ---------------------------------------------------------------------
0         1,51-99,151-199,251-4094
1         10-50
2         100-150
3         200-250

! View MST instance details
show spanning-tree mst 1

###### MST1    vlans mapped:   10-50
Bridge        address 0023.04ee.be01  priority  24577 (24576 sysid 1)
Root          this switch for MST1

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Gi1/0/23         Desg FWD 20000     128.23   P2p Bound(PVST)
Gi1/0/24         Desg FWD 20000     128.24   P2p Bound(PVST)

! View MST region and boundary information
show spanning-tree mst detail
```

**MST Design Considerations**

**Advantages:**

- Dramatically reduced resource utilization (CPU, memory)
- Supports networks with hundreds of VLANs efficiently
- Maintains RSTP rapid convergence
- Provides load balancing through instance-based root bridge variation
- Industry standard (IEEE 802.1s)

**Disadvantages:**

- More complex configuration requiring exact match across region
- Configuration errors create region boundaries with unexpected behavior
- Troubleshooting requires understanding IST, CST, and instance relationships
- Limited per-VLAN granularity within instances
- Interoperability with PVST+ adds complexity

**When to Use MST:**

- Large networks with 50+ VLANs
- Data center environments with VLAN proliferation
- Networks requiring resource optimization
- Standardized environments with strict change control

**When to Use PVST+/Rapid PVST+:**

- Networks with fewer than 50 VLANs
- Environments requiring maximum per-VLAN control
- Organizations without MST expertise
- Networks prioritizing simplicity over optimization

**MST Migration Strategy**

Migrating from PVST+ to MST requires careful planning:

1. **Document existing topology**: Map current root bridges, blocked ports, and traffic paths for all VLANs
2. **Design MST instances**: Group VLANs logically (by function, location, or security zone)
3. **Establish maintenance window**: Complete migration during low-traffic period
4. **Configure MST on all switches simultaneously**: Prepare configurations offline, apply rapidly to minimize inconsistency
5. **Verify instance 0 root**: Ensure IST root bridge is correct before enabling
6. **Monitor convergence**: Watch for topology changes and verify expected paths
7. **Validate traffic flows**: Confirm no VLANs lost connectivity
8. **Document final configuration**: Update network diagrams and configuration standards

**MST Configuration Template**

```
! Standard MST configuration for region
spanning-tree mode mst

spanning-tree mst configuration
 name CORPORATE_NETWORK
 revision 2
 ! Instance 1: User data VLANs
 instance 1 vlan 10,20,30,40,50
 ! Instance 2: Voice VLANs
 instance 2 vlan 110,120,130
 ! Instance 3: Server VLANs
 instance 3 vlan 200,210,220
 ! Instance 0: Remaining VLANs (default mapping)
 exit

! Root bridge configuration
spanning-tree mst 0 root primary
spanning-tree mst 1 root primary
spanning-tree mst 2 root secondary
spanning-tree mst 3 root secondary

! PortFast and BPDU Guard on access ports
spanning-tree portfast default
spanning-tree portfast bpduguard default

! Hello time adjustment (optional)
spanning-tree mst hello-time 2
spanning-tree mst max-age 20
spanning-tree mst forward-time 15
```

**MST Troubleshooting**

**Common Issues:**

**Region Mismatch:** Switches with different names, revisions, or mappings operate in separate regions. Symptom: unexpected topology, additional hops, or suboptimal paths.

Solution: Verify configuration match with `show spanning-tree mst configuration` on all switches.

**Inconsistent Root Bridge:** If MST boundaries connect to PVST+ with different roots per VLAN, MST may detect inconsistency.

Solution: Standardize PVST+ root bridges or complete MST migration.

**Unexpected Blocking:** Load balancing may not work as intended if instance mappings don't align with traffic patterns.

Solution: Review VLAN-to-instance mappings and adjust root bridge priorities.

**Rapid Convergence Failure:** If convergence takes longer than expected, check for non-point-to-point links or shared media.

Solution: Verify link types with `show spanning-tree mst interface detail`.

**Monitoring and Maintenance**

```
! Regular verification commands
show spanning-tree mst
show spanning-tree mst configuration
show spanning-tree mst 1 detail
show spanning-tree inconsistentports

! Log analysis for topology changes
show logging | include TOPOLOGY|STP

! Interface-specific debugging
debug spanning-tree mst events
```

**Related Topics for Advanced STP Understanding**

To build comprehensive spanning-tree expertise, explore: STP protection mechanisms (Root Guard, Loop Guard, UDLD), STP in virtual environments (vPC, VSS, StackWise), Layer 3 design alternatives to STP (routed access layer), troubleshooting STP loops and convergence issues, STP interaction with EtherChannel/LACP, STP security considerations and attack vectors, optimizing STP for VoIP and real-time traffic, STP behavior during switch stack operations, integrating STP with SDN controllers, and comparing STP alternatives like TRILL and SPB.

---

# Cisco EtherChannel

## EtherChannel Concepts

EtherChannel combines multiple physical Ethernet links into a single logical link to increase bandwidth and provide redundancy between network devices. This technology aggregates parallel links to create higher-capacity connections while maintaining fault tolerance.

**Fundamental Principles:** EtherChannel treats multiple physical interfaces as a single logical interface called a port-channel. Traffic is distributed across member links using various load-balancing algorithms, and if one physical link fails, traffic automatically redistributes across remaining active links.

**Benefits:**

- **Increased Bandwidth**: Aggregates bandwidth of multiple physical links
- **Redundancy**: Provides fault tolerance through link failover
- **Load Distribution**: Spreads traffic across multiple paths
- **Simplified Configuration**: Single logical interface for configuration management
- **STP Integration**: Appears as single link to Spanning Tree Protocol

**Key Requirements:** All physical interfaces in an EtherChannel must have identical configurations:

- Same speed and duplex settings
- Same VLAN configuration (for Layer 2)
- Same access or trunk mode
- Compatible switch port settings

**Port-Channel Interface:** The logical interface created by EtherChannel uses the naming convention Po1, Po2, etc. This interface can be configured like any other interface with IP addressing, VLANs, and other settings.

**Maximum Links:** Most Cisco platforms support up to 8 active physical links per EtherChannel, though some platforms may support fewer. Additional links can be configured as standby.

## PAgP (Port Aggregation Protocol)

PAgP is Cisco's proprietary protocol for automatically forming EtherChannel connections between compatible Cisco devices.

**PAgP Modes:**

**Auto Mode:**

```
Switch(config-if)# channel-group 1 mode auto
```

The interface responds to PAgP packets but does not initiate negotiation. Forms EtherChannel only if the other side is set to desirable mode.

**Desirable Mode:**

```
Switch(config-if)# channel-group 1 mode desirable
```

The interface actively sends PAgP packets and initiates negotiation. Can form EtherChannel with auto or desirable modes on the other side.

**Working Combinations:**

- Desirable ↔ Desirable: Forms EtherChannel
- Desirable ↔ Auto: Forms EtherChannel
- Auto ↔ Auto: Does not form EtherChannel

**PAgP Operation:** PAgP exchanges information about interface capabilities, including speed, duplex, and VLAN configuration. The protocol ensures both sides have compatible configurations before forming the EtherChannel.

**PAgP Packets:** The protocol uses multicast frames sent every 30 seconds to maintain the EtherChannel and detect configuration changes. If PAgP packets are not received, the protocol can remove interfaces from the channel.

**Limitations:** PAgP only works between Cisco devices and cannot interoperate with other vendors' equipment. For multi-vendor environments, LACP provides standardized link aggregation.

## LACP (Link Aggregation Control Protocol)

LACP is the IEEE 802.3ad standard protocol for link aggregation, providing interoperability between different vendor equipment.

**LACP Modes:**

**Active Mode:**

```
Switch(config-if)# channel-group 1 mode active
```

The interface actively sends LACP packets and initiates negotiation. Similar to PAgP desirable mode.

**Passive Mode:**

```
Switch(config-if)# channel-group 1 mode passive
```

The interface responds to LACP packets but does not initiate negotiation. Similar to PAgP auto mode.

**Working Combinations:**

- Active ↔ Active: Forms EtherChannel
- Active ↔ Passive: Forms EtherChannel
- Passive ↔ Passive: Does not form EtherChannel

**LACP Priority System:** LACP uses system priority values to determine which device controls the EtherChannel formation:

```
Switch(config)# lacp system-priority 100
```

Lower values indicate higher priority. Default system priority is 32768.

**Port Priority:** Individual interface priority within LACP:

```
Switch(config-if)# lacp port-priority 100
```

Used to determine which interfaces become active when more than 8 interfaces are configured in a channel group.

**LACP Timers:**

```
Switch(config-if)# lacp rate fast
Switch(config-if)# lacp rate normal
```

- **Fast**: LACP packets sent every 1 second
- **Normal**: LACP packets sent every 30 seconds (default)

**LACP Operation:** LACP exchanges Link Aggregation Control Protocol Data Units (LACPDUs) to negotiate and maintain the EtherChannel. The protocol continuously monitors link status and automatically adjusts the channel membership.

## Layer 2 and Layer 3 EtherChannel

EtherChannel operates at both Layer 2 (switching) and Layer 3 (routing) depending on the configuration and device capabilities.

**Layer 2 EtherChannel:**

**Access Port Configuration:**

```
Switch(config)# interface range gigabitethernet 1/0/1-2
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 10
Switch(config-if-range)# channel-group 1 mode active
Switch(config-if-range)# exit
Switch(config)# interface port-channel 1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
```

**Trunk Port Configuration:**

```
Switch(config)# interface range gigabitethernet 1/0/3-4
Switch(config-if-range)# switchport mode trunk
Switch(config-if-range)# switchport trunk allowed vlan 10,20,30
Switch(config-if-range)# channel-group 2 mode active
Switch(config-if-range)# exit
Switch(config)# interface port-channel 2
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk allowed vlan 10,20,30
```

**Layer 3 EtherChannel:**

**Routed Interface Configuration:**

```
Switch(config)# interface range gigabitethernet 1/0/5-6
Switch(config-if-range)# no switchport
Switch(config-if-range)# channel-group 3 mode active
Switch(config-if-range)# exit
Switch(config)# interface port-channel 3
Switch(config-if)# no switchport
Switch(config-if)# ip address 192.168.1.1 255.255.255.252
```

**Layer 3 Requirements:**

- Interfaces must be configured as routed ports (`no switchport`)
- IP addressing applied to port-channel interface
- Routing protocols can use the logical interface
- Supports both IPv4 and IPv6 addressing

**Mixed Layer Considerations:** All member interfaces must operate at the same layer. Layer 2 and Layer 3 interfaces cannot be mixed within the same EtherChannel.

## Load Balancing Methods

EtherChannel uses various algorithms to distribute traffic across member links, ensuring efficient utilization of available bandwidth.

**Load Balancing Options:**

**Source MAC Address:**

```
Switch(config)# port-channel load-balance src-mac
```

Traffic distribution based on source MAC address. Ensures frames from the same source follow the same path.

**Destination MAC Address:**

```
Switch(config)# port-channel load-balance dst-mac
```

Traffic distribution based on destination MAC address. Ensures frames to the same destination follow the same path.

**Source and Destination MAC:**

```
Switch(config)# port-channel load-balance src-dst-mac
```

Uses both source and destination MAC addresses for load balancing, providing better distribution.

**Source IP Address:**

```
Switch(config)# port-channel load-balance src-ip
```

Distribution based on source IP address for Layer 3 traffic.

**Destination IP Address:**

```
Switch(config)# port-channel load-balance dst-ip
```

Distribution based on destination IP address for Layer 3 traffic.

**Source and Destination IP:**

```
Switch(config)# port-channel load-balance src-dst-ip
```

Uses both source and destination IP addresses, providing optimal distribution for most scenarios.

**Source and Destination Port:**

```
Switch(config)# port-channel load-balance src-dst-port
```

Includes Layer 4 port numbers in the load-balancing algorithm.

**Algorithm Operation:** The switch performs a hash calculation on selected packet fields to determine which physical link carries each frame. The same flow always uses the same physical link, maintaining packet ordering.

**Platform Variations:** Different Cisco platforms support different load-balancing methods. Newer platforms typically support more sophisticated algorithms including Layer 4 information.

## EtherChannel Troubleshooting

EtherChannel issues often stem from configuration mismatches, protocol negotiation failures, or physical connectivity problems.

**Common Issues:**

**Configuration Mismatch:** All member interfaces must have identical configurations. Mismatched settings prevent EtherChannel formation or cause erratic behavior.

**Typical Mismatches:**

- Speed/duplex settings
- VLAN configuration
- Access/trunk mode differences
- Native VLAN mismatches on trunk ports

**Protocol Negotiation Failures:** Incompatible negotiation modes prevent EtherChannel establishment:

- PAgP auto ↔ auto
- LACP passive ↔ passive
- Mixing PAgP and LACP modes

**Physical Issues:**

- Cable faults
- Port hardware failures
- Inconsistent physical connections

**Diagnostic Commands:**

**EtherChannel Status:**

```
Switch# show etherchannel summary
Switch# show etherchannel 1 detail
Switch# show etherchannel 1 port-channel
```

**Protocol-Specific Information:**

```
Switch# show pagp neighbor
Switch# show pagp 1 internal
Switch# show lacp neighbor
Switch# show lacp 1 internal
Switch# show lacp 1 counters
```

**Interface Status:**

```
Switch# show interfaces port-channel 1
Switch# show interfaces gigabitethernet 1/0/1 etherchannel
Switch# show spanning-tree interface port-channel 1
```

**Load Balancing Verification:**

```
Switch# show etherchannel load-balance
Switch# show etherchannel 1 load-balance
Switch# test etherchannel load-balance interface port-channel 1 mac 0000.1111.2222 0000.3333.4444
```

**Troubleshooting Steps:**

1. **Verify Physical Connectivity**: Ensure all cables are properly connected and ports are operational
2. **Check Configuration Consistency**: Compare configurations of all member interfaces
3. **Verify Protocol Settings**: Confirm compatible negotiation modes on both sides
4. **Monitor Protocol Messages**: Check for PAgP or LACP packet exchange
5. **Review Error Counters**: Look for errors that might indicate hardware issues
6. **Test Load Distribution**: Verify traffic is distributed across all member links

**Common Error Messages:**

- "Port-channel X: ports not compatible"
- "LACP: neighbor not responding"
- "PAgP: inconsistent partner"

**Resolution Strategies:**

- Reset EtherChannel configuration and reconfigure step by step
- Verify both sides of connection have compatible settings
- Use protocol debugging for detailed troubleshooting information
- Consider using manual (on) mode for basic aggregation without protocols

**Key points** for successful EtherChannel implementation: All member interfaces must have identical configurations, appropriate negotiation modes must be selected for the environment, and load-balancing methods should be chosen based on traffic patterns. Regular monitoring ensures optimal performance and early detection of potential issues.

---

# Routing Fundamentals

## Routing Table Structure

The routing table is a data structure stored in router memory containing information about network destinations and the paths to reach them. Routers consult this table to make forwarding decisions for every packet.

**Routing Table Components:**

Each route entry contains specific fields that guide forwarding decisions:

- **Route Source**: Indicates how the route was learned (directly connected, static, dynamic routing protocol). Denoted by codes such as C (connected), S (static), R (RIP), D (EIGRP), O (OSPF), B (BGP).
- **Destination Network**: The target network address and subnet mask in CIDR notation (e.g., 192.168.10.0/24).
- **Administrative Distance**: Trustworthiness metric of the route source (lower is more preferred). Shown in brackets [AD/Metric].
- **Metric**: Cost to reach the destination network, calculated differently by each routing protocol. Shown in brackets [AD/Metric].
- **Next-Hop Address**: IP address of the next router in the path to the destination, or the exit interface.
- **Exit Interface**: The local interface through which packets should be forwarded to reach the next hop.
- **Route Timestamp**: How long the route has been in the routing table.

**Viewing the Routing Table:**

```
Router# show ip route
Router# show ip route [network]
Router# show ip route [protocol]
Router# show ipv6 route
```

**Example Routing Table Entry:**

```
D    192.168.20.0/24 [90/2170112] via 10.1.1.2, 00:05:32, GigabitEthernet0/0
```

This breaks down as:

- D = EIGRP learned route
- 192.168.20.0/24 = destination network
- [90/2170112] = administrative distance 90, metric 2170112
- via 10.1.1.2 = next-hop IP address
- 00:05:32 = route age in routing table
- GigabitEthernet0/0 = exit interface

**Route Types:**

- **Directly Connected (C)**: Networks attached to router interfaces that are in up/up state. Automatically added when interface is configured with an IP address and activated.
- **Local (L)**: The specific IP address configured on the router interface, always with /32 mask for IPv4 or /128 for IPv6. Used for local packet processing.
- **Static (S)**: Manually configured routes that remain until administratively removed or interface goes down.
- **Dynamic**: Routes learned through routing protocols like RIP, EIGRP, OSPF, or BGP.

**Longest Prefix Match:**

When multiple routes match a destination, the router selects the route with the longest prefix length (most specific match). A packet destined for 192.168.10.50 would prefer route 192.168.10.0/24 over 192.168.0.0/16, even if the latter has a better metric.

**Route Lookup Process:**

1. Router receives packet and extracts destination IP address
2. Searches routing table for longest prefix match
3. If match found, forwards packet to next-hop or exit interface
4. If no match found, uses default route if configured
5. If no default route exists, drops packet and sends ICMP Destination Unreachable

**Classful vs Classless Routing Table:**

Modern routers use classless routing tables, displaying routes with their specific subnet masks regardless of class boundaries. The `ip classless` command (enabled by default) allows routers to forward packets using supernet routes when no exact match exists.

**Route Recursion:**

When a route lists only a next-hop IP address without an exit interface, the router must perform recursive lookup to determine the actual exit interface by finding another route that resolves the next-hop address.

## Static Routing Configuration

Static routes are manually configured path entries that specify how to reach specific destination networks. They remain in the routing table until removed or until the associated interface goes down.

**Standard Static Route Syntax:**

```
Router(config)# ip route [destination-network] [subnet-mask] [next-hop-ip | exit-interface]
```

**Next-Hop Static Route:**

```
Router(config)# ip route 192.168.20.0 255.255.255.0 10.1.1.2
```

The router performs recursive lookup to determine which interface connects to 10.1.1.2 before forwarding packets. This adds slight processing overhead but is necessary on multi-access networks.

**Exit Interface Static Route:**

```
Router(config)# ip route 192.168.20.0 255.255.255.0 GigabitEthernet0/1
```

Packets are forwarded directly out the specified interface. This works well for point-to-point links but creates issues on multi-access networks where the router doesn't know the Layer 2 address for encapsulation.

**Fully Specified Static Route:**

```
Router(config)# ip route 192.168.20.0 255.255.255.0 GigabitEthernet0/1 10.1.1.2
```

Specifies both exit interface and next-hop address, combining benefits of both methods. The router knows exactly where to forward without recursive lookup and has the next-hop IP for ARP resolution. This is the preferred configuration method for most scenarios.

**IPv6 Static Route Configuration:**

```
Router(config)# ipv6 unicast-routing
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 2001:DB8:ACAD:1::2
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0 2001:DB8:ACAD:1::2
```

IPv6 static routes follow the same logic as IPv4, but the `ipv6 unicast-routing` command must be enabled first to activate IPv6 routing.

**Link-Local Next-Hop (IPv6):**

When using IPv6 link-local addresses as next-hop, the exit interface must be specified:

```
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0 FE80::2
```

Link-local addresses are not unique globally, so the router needs to know which interface connects to that link-local address.

**Static Route Verification:**

```
Router# show ip route static
Router# show ipv6 route static
Router# show running-config | section ip route
Router# show ip route [destination-network]
```

**When to Use Static Routes:**

- Small networks with few routers and predictable topology
- Stub networks with single exit point
- Default routes to ISPs
- Backup routes for dynamic routing protocol failures
- Security-sensitive paths requiring explicit control
- Reducing routing protocol overhead and bandwidth

**Static Route Limitations:**

- No automatic adaptation to topology changes
- Administrative burden increases with network size
- Human configuration errors can create routing loops or black holes
- Lack of load balancing capabilities compared to dynamic protocols (though multiple static routes to same destination enable basic load sharing)

## Default Routes

A default route is a special static route matching all packets that don't match any other specific route in the routing table. It functions as a "gateway of last resort," forwarding traffic to unknown destinations.

**IPv4 Default Route Configuration:**

```
Router(config)# ip route 0.0.0.0 0.0.0.0 [next-hop-ip | exit-interface]
```

**Example Configurations:**

```
! Next-hop default route
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1

! Exit interface default route
Router(config)# ip route 0.0.0.0 0.0.0.0 Serial0/0/0

! Fully specified default route
Router(config)# ip route 0.0.0.0 0.0.0.0 Serial0/0/0 203.0.113.1
```

The 0.0.0.0/0 notation represents all possible IP addresses (match everything), with a prefix length of zero bits.

**IPv6 Default Route Configuration:**

```
Router(config)# ipv6 route ::/0 [next-hop-ipv6 | exit-interface]

! Examples
Router(config)# ipv6 route ::/0 2001:DB8:ACAD:1::1
Router(config)# ipv6 route ::/0 Serial0/0/0
Router(config)# ipv6 route ::/0 Serial0/0/0 FE80::1
```

The ::/0 notation is IPv6 equivalent, representing all IPv6 addresses with zero prefix length.

**Default Route Use Cases:**

- **Stub Networks**: Networks with only one exit point don't need specific routes to every external destination
- **ISP Connections**: Customer routers forward all Internet-bound traffic to ISP without maintaining full Internet routing table
- **Hub-and-Spoke Topologies**: Spoke routers use default routes pointing to hub
- **Simplifying Configuration**: Reduces routing table size and configuration complexity

**Propagating Default Routes:**

Dynamic routing protocols can advertise default routes to other routers:

```
! OSPF default route propagation
Router(config)# router ospf 1
Router(config-router)# default-information originate

! EIGRP default route propagation
Router(config)# router eigrp 100
Router(config-router)# redistribute static

! RIPv2 default route propagation
Router(config)# router rip
Router(config-router)# default-information originate
```

**Verification:**

```
Router# show ip route
Router# show ip route 0.0.0.0
Router# show ipv6 route
Router# show ipv6 route ::/0
```

A default route appears in the routing table as:

```
S*   0.0.0.0/0 [1/0] via 203.0.113.1
```

The asterisk (*) denotes this as the gateway of last resort.

**Default Route Priority:**

If multiple default routes exist (static and dynamically learned), the router selects based on administrative distance. A static default route (AD 1) is preferred over OSPF external default route (AD 110).

## Administrative Distance

Administrative Distance (AD) is a value representing the trustworthiness or reliability of a routing information source. When a router learns routes to the same destination from multiple sources, AD determines which route is installed in the routing table. Lower AD values indicate more trusted sources.

**Default Administrative Distance Values:**

|Route Source|AD Value|
|---|---|
|Directly Connected|0|
|Static Route|1|
|EIGRP Summary Route|5|
|External BGP (eBGP)|20|
|Internal EIGRP|90|
|OSPF|110|
|IS-IS|115|
|RIP|120|
|External EIGRP|170|
|Internal BGP (iBGP)|200|
|Unknown/Unreliable|255 (not installed)|

**Route Selection Process:**

When multiple routes to the same destination exist:

1. Router compares prefix lengths first (longest match wins)
2. If prefix lengths are equal, compares administrative distances
3. Route with lowest AD is installed in routing table
4. If ADs are equal, metric determines selection (protocol-specific)
5. If metrics are equal, load balancing may occur (if supported)

**Viewing Administrative Distance:**

```
Router# show ip route
D    192.168.20.0/24 [90/2170112] via 10.1.1.2, 00:05:32, GigabitEthernet0/0
```

The first number in brackets [90/2170112] is the AD (90 = EIGRP internal).

**Modifying Administrative Distance:**

You can adjust AD values to prefer certain routing sources over others, though this should be done carefully:

**Static Route AD Modification:**

```
Router(config)# ip route 192.168.20.0 255.255.255.0 10.1.1.2 150
```

This creates a floating static route (covered in detail in a later section) with AD 150, making it less preferred than OSPF (110) or RIP (120) but available as backup.

**Routing Protocol AD Modification:**

```
! Modify OSPF distance for all OSPF routes
Router(config)# router ospf 1
Router(config-router)# distance 115

! Modify EIGRP distance for all EIGRP routes
Router(config)# router eigrp 100
Router(config-router)# distance eigrp 95 175
```

The EIGRP command sets internal EIGRP routes to AD 95 and external to AD 175.

**Selective AD Modification with Access Lists:**

```
Router(config)# access-list 1 permit 192.168.10.0 0.0.0.255
Router(config)# router ospf 1
Router(config-router)# distance 95 10.1.1.2 0.0.0.0 1
```

This sets AD to 95 only for OSPF routes from neighbor 10.1.1.2 matching access-list 1.

**AD vs Metric:**

AD and metric serve different purposes:

- **AD**: Compares trustworthiness between different routing protocols or sources
- **Metric**: Compares path quality within the same routing protocol

AD is evaluated first. Only if AD values are equal does the router compare metrics.

**Example scenario:**

```
O    192.168.50.0/24 [110/65] via 10.1.1.2, 00:10:23, GigabitEthernet0/0
D    192.168.50.0/24 [90/2170112] via 10.2.1.2, 00:08:15, GigabitEthernet0/1
```

Even though OSPF has a better metric (65 vs 2170112), EIGRP route is installed because EIGRP AD (90) is lower than OSPF AD (110). Metrics from different protocols cannot be directly compared.

**AD Best Practices:**

- Avoid modifying default AD values unless absolutely necessary
- Document any AD changes thoroughly
- Understand that changing AD can affect routing behavior network-wide
- Use AD modification sparingly for traffic engineering or creating backup paths

## Route Summarization

Route summarization (also called route aggregation or supernetting) combines multiple contiguous network addresses into a single routing advertisement. This reduces routing table size, decreases routing update traffic, and improves network stability.

**Benefits of Route Summarization:**

- **Smaller Routing Tables**: Fewer entries consume less memory and reduce lookup time
- **Reduced Update Traffic**: Less bandwidth consumed by routing protocol updates
- **Stability**: Topology changes within summarized area don't trigger updates outside the summary boundary
- **Faster Convergence**: Fewer routes to recalculate during topology changes
- **Reduced CPU Utilization**: Less processing required for routing updates

**Summarization Requirements:**

Networks must be contiguous and properly subnetted for summarization. You cannot summarize non-contiguous address blocks into a single summary.

**Calculating Summary Routes:**

To create a summary route:

1. Convert network addresses to binary
2. Identify common leftmost bits across all networks
3. Count the number of common bits (this becomes subnet mask)
4. Set remaining bits to zero for summary network address

**Example Calculation:**

Summarize these networks:

- 192.168.16.0/24
- 192.168.17.0/24
- 192.168.18.0/24
- 192.168.19.0/24

Binary representation:

```
192.168.16.0 = 11000000.10101000.00010000.00000000
192.168.17.0 = 11000000.10101000.00010001.00000000
192.168.18.0 = 11000000.10101000.00010010.00000000
192.168.19.0 = 11000000.10101000.00010011.00000000
                                  ^^ These bits differ
```

Common bits: 22 bits match (11000000.10101000.000100)

Summary route: 192.168.16.0/22 (covers 192.168.16.0 through 192.168.19.255)

**CIDR Block Size Reference:**

- /22 = 4 Class C networks (1024 addresses)
- /23 = 2 Class C networks (512 addresses)
- /21 = 8 Class C networks (2048 addresses)
- /20 = 16 Class C networks (4096 addresses)

**OSPF Route Summarization:**

OSPF performs summarization at Area Border Routers (ABRs) when routes are injected from one area into the backbone, and at Autonomous System Boundary Routers (ASBRs) for external routes.

```
! Summarization at ABR for inter-area routes
Router(config)# router ospf 1
Router(config-router)# area 1 range 192.168.16.0 255.255.252.0

! Summarization for external routes at ASBR
Router(config-router)# summary-address 10.0.0.0 255.0.0.0
```

**EIGRP Route Summarization:**

EIGRP allows manual summarization on any interface, providing flexibility for network design:

```
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip summary-address eigrp 100 192.168.16.0 255.255.252.0

! IPv6 EIGRP summarization
Router(config-if)# ipv6 summary-address eigrp 100 2001:DB8:ACAD::/48
```

When EIGRP creates a summary route, it automatically installs a local summary route to the Null0 interface to prevent routing loops for addresses within the summary range that don't have specific matches.

**BGP Route Summarization:**

BGP uses the aggregate-address command:

```
Router(config)# router bgp 65001
Router(config-router)# aggregate-address 192.168.0.0 255.255.0.0 summary-only
```

The `summary-only` keyword suppresses advertisement of more specific routes, sending only the aggregate.

**Static Route Summarization:**

Static routes can be manually configured as summaries:

```
Router(config)# ip route 192.168.16.0 255.255.252.0 10.1.1.2
```

This single static route replaces multiple specific static routes for 192.168.16.0/24 through 192.168.19.0/24.

**Discontiguous Networks:**

[Inference] Networks separated by different major network addresses cannot be summarized together without including unwanted address space. For example, attempting to summarize 10.1.0.0/16 and 10.3.0.0/16 into 10.0.0.0/14 also includes 10.2.0.0/16, which may not be part of your network.

**Verification Commands:**

```
Router# show ip route
Router# show ip protocols
Router# show ip ospf border-routers
Router# show ip eigrp topology
```

## Floating Static Routes

A floating static route is a backup static route configured with a higher administrative distance than the primary route. It remains inactive in the routing table until the primary route fails, then automatically takes over.

**Floating Static Route Concept:**

By default, static routes have AD of 1, making them more preferred than any dynamic routing protocol. By increasing the AD of a backup static route above the primary route's AD, the backup "floats" above the routing table, installing only when needed.

**Configuration Syntax:**

```
Router(config)# ip route [destination] [mask] [next-hop] [AD-value]
```

**Basic Floating Static Route Example:**

Primary route learned via OSPF (AD 110):

```
Router(config)# router ospf 1
Router(config-router)# network 10.0.0.0 0.255.255.255 area 0
```

Backup floating static route with AD 115:

```
Router(config)# ip route 0.0.0.0 0.0.0.0 Serial0/1/0 115
```

Under normal conditions, OSPF route is installed (AD 110). If OSPF route fails, the static route (AD 115) is installed.

**Floating Static Default Route:**

Common implementation for backup Internet connectivity:

```
! Primary default route via OSPF
Router(config)# router ospf 1
Router(config-router)# default-information originate

! Backup floating static default route via secondary ISP
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.5 120
```

If OSPF-learned default route fails, router automatically switches to static default route.

**Multiple Floating Static Routes:**

You can configure multiple backup routes with progressively higher AD values:

```
! Primary EIGRP route (AD 90)
Router(config)# router eigrp 100
Router(config-router)# network 10.0.0.0

! First backup - static route with AD 95
Router(config)# ip route 192.168.100.0 255.255.255.0 10.1.1.2 95

! Second backup - static route with AD 100
Router(config)# ip route 192.168.100.0 255.255.255.0 10.2.2.2 100
```

Routes install in order: EIGRP (90) → 10.1.1.2 (95) → 10.2.2.2 (100) as each previous route fails.

**IPv6 Floating Static Routes:**

```
! Primary OSPFv3 route (AD 110)
Router(config)# ipv6 router ospf 1
Router(config-rtr)# router-id 1.1.1.1

! Backup floating static route with AD 120
Router(config)# ipv6 route ::/0 Serial0/1/0 2001:DB8:FEED::1 120
```

**Tracking Objects for More Reliable Failover:**

[Inference] Basic floating static routes depend on interface status or routing protocol convergence to trigger failover. IP SLA (Service Level Agreement) tracking provides more sophisticated failure detection:

```
! Configure IP SLA to ping critical destination
Router(config)# ip sla 1
Router(config-ip-sla)# icmp-echo 203.0.113.1
Router(config-ip-sla-echo)# frequency 10
Router(config-ip-sla-echo)# exit
Router(config)# ip sla schedule 1 start-time now life forever

! Create tracking object
Router(config)# track 1 ip sla 1 reachability

! Primary static route with tracking
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1 track 1

! Floating static route as backup
Router(config)# ip route 0.0.0.0 0.0.0.0 198.51.100.1 10
```

If ICMP echo to 203.0.113.1 fails, tracking object becomes down, primary route is removed, and floating static route (AD 10) is installed.

**Use Cases:**

- Redundant WAN links where primary uses MPLS and backup uses Internet
- Dual ISP connections for Internet redundancy
- Branch offices with primary dynamic routing and backup static paths
- Cost-sensitive scenarios where backup link should only activate when primary fails

**Verification:**

```
Router# show ip route
Router# show ip route static
Router# show track
Router# show ip sla statistics
```

When primary route is active, floating static won't appear in routing table. It only appears after primary fails.

**Considerations:**

- Failover speed depends on interface failure detection or routing protocol convergence time
- Floating static routes don't provide load balancing (only one route active at a time)
- Ensure backup path AD is higher than all primary routing sources
- Test failover scenarios to verify proper operation

## IPv4 and IPv6 Routing Differences

While routing fundamentals remain similar between IPv4 and IPv6, several operational and configuration differences exist due to protocol design changes.

**Enabling Routing:**

**IPv4**: Routing is enabled by default on Cisco routers. No global command required.

**IPv6**: Must be explicitly enabled:

```
Router(config)# ipv6 unicast-routing
```

Without this command, the router will not forward IPv6 packets or participate in IPv6 routing protocols.

**Address Configuration:**

**IPv4**: Requires manual IP address and subnet mask:

```
Router(config-if)# ip address 192.168.1.1 255.255.255.0
```

**IPv6**: Supports multiple configuration methods:

```
! Manual configuration
Router(config-if)# ipv6 address 2001:DB8:ACAD:1::1/64

! EUI-64 autoconfiguration
Router(config-if)# ipv6 address 2001:DB8:ACAD:1::/64 eui-64

! Link-local only
Router(config-if)# ipv6 enable
```

IPv6 interfaces automatically generate link-local addresses (FE80::/10) when IPv6 is enabled. Each interface can have multiple IPv6 addresses of different types simultaneously.

**Static Route Configuration:**

**IPv4**:

```
Router(config)# ip route 192.168.20.0 255.255.255.0 10.1.1.2
Router(config)# ip route 192.168.20.0 255.255.255.0 GigabitEthernet0/0
```

**IPv6**:

```
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 2001:DB8:ACAD:1::2
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0 FE80::2
```

When using IPv6 link-local addresses as next-hop, exit interface must be specified because link-local addresses are not globally unique.

**Default Route Notation:**

**IPv4**: 0.0.0.0/0

```
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1
```

**IPv6**: ::/0

```
Router(config)# ipv6 route ::/0 2001:DB8:FEED::1
```

**Routing Table Differences:**

**IPv4 Routing Table**:

```
Router# show ip route
```

Shows:

- Connected networks (C)
- Local interface addresses /32 (L)
- Static routes (S)
- Dynamic routes with protocol codes

**IPv6 Routing Table**:

```
Router# show ipv6 route
```

Shows:

- Connected networks (C)
- Local interface addresses /128 (L)
- Link-local routes (L) for FE80::/10
- Static routes (S)
- Dynamic routes with protocol codes

IPv6 routing table includes explicit entries for link-local addresses used for neighbor discovery and routing protocol adjacencies.

**NAT Requirements:**

**IPv4**: NAT (Network Address Translation) commonly used due to address exhaustion. Private addresses (RFC 1918) require translation for Internet access.

**IPv6**: NAT typically not required due to vast address space (128-bit addresses). Networks use global unicast addresses for end-to-end connectivity. NPTv6 (Network Prefix Translation) exists but is less common.

**Broadcast vs Multicast:**

**IPv4**: Uses broadcasts (255.255.255.255 or subnet broadcasts) for certain operations like ARP and DHCP discovery.

**IPv6**: No broadcast concept. Uses multicast addresses instead:

- All-nodes multicast: FF02::1
- All-routers multicast: FF02::2
- Solicited-node multicast: FF02::1:FF00:0/104

**Neighbor Discovery:**

**IPv4**: Uses ARP (Address Resolution Protocol) to map IP addresses to MAC addresses. ARP operates at Layer 2 and is separate from IP.

**IPv6**: Uses ICMPv6 Neighbor Discovery Protocol (NDP) with:

- Neighbor Solicitation (NS) - equivalent to ARP request
- Neighbor Advertisement (NA) - equivalent to ARP reply
- Router Solicitation (RS)
- Router Advertisement (RA)
- Redirect messages

NDP is integrated into ICMPv6, providing enhanced security and functionality.

**Routing Protocol Versions:**

**IPv4 Routing Protocols**: RIPv2, EIGRP for IPv4, OSPFv2, BGP-4

**IPv6 Routing Protocols**: RIPng (RIP next generation), EIGRP for IPv6, OSPFv3, BGP-4 (with IPv6 extensions)

Configuration differs significantly:

**OSPFv2 (IPv4)**:

```
Router(config)# router ospf 1
Router(config-router)# network 10.1.1.0 0.0.0.255 area 0
```

**OSPFv3 (IPv6)**:

```
Router(config)# ipv6 router ospf 1
Router(config-rtr)# router-id 1.1.1.1
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 ospf 1 area 0
```

OSPFv3 is enabled per-interface rather than using network statements. It still requires an IPv4-format router ID even though routing IPv6.

**EIGRP Configuration:**

**EIGRP for IPv4**:

```
Router(config)# router eigrp 100
Router(config-router)# network 10.0.0.0
```

**EIGRP for IPv6**:

```
Router(config)# ipv6 router eigrp 100
Router(config-rtr)# eigrp router-id 1.1.1.1
Router(config-rtr)# no shutdown
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 eigrp 100
```

IPv6 EIGRP requires explicit no shutdown command and is enabled per-interface.

**Administrative Distance:**

Administrative distance values remain the same for equivalent protocols between IPv4 and IPv6:

- Directly Connected: 0
- Static: 1
- EIGRP: 90 (internal), 170 (external)
- OSPF: 110
- RIP/RIPng: 120

**Fragmentation:**

**IPv4**: Routers can fragment packets if they exceed the MTU of outgoing interface. The fragment bit in IP header controls this behavior.

**IPv6**: Routers do not fragment packets. Source host must perform Path MTU Discovery to determine appropriate packet size. If packet exceeds MTU, router drops it and sends ICMPv6 "Packet Too Big" message back to source.

**Header Simplification:**

IPv6 header is simpler despite longer addresses:

- Fixed 40-byte header (IPv4 variable 20-60 bytes)
- No header checksum (reduces processing)
- No fragmentation fields in main header
- Options handled via extension headers

This simplification improves routing performance.

**Address Types in Routing:**

**IPv4**: Unicast, multicast (224.0.0.0/4), broadcast, limited broadcast

**IPv6**: Unicast (global, unique local, link-local), multicast (FF00::/8), anycast (assigned from unicast space). No broadcast addresses exist.

**Verification Commands:**

**IPv4**:

```
Router# show ip interface brief
Router# show ip route
Router# show ip protocols
Router# show ip arp
```

**IPv6**:

```
Router# show ipv6 interface brief
Router# show ipv6 route
Router# show ipv6 protocols
Router# show ipv6 neighbors
```

The `show ipv6 neighbors` command displays IPv6 neighbor discovery cache (equivalent to IPv4 ARP table).

**Key points:**

- Routing tables contain destination networks, administrative distance/metric in brackets, next-hop addresses, exit interfaces, and route sources indicated by protocol codes.
- Static routes are manually configured using destination network, subnet mask, and next-hop or exit interface, with fully specified routes combining both for optimal performance.
- Default routes (0.0.0.0/0 for IPv4, ::/0 for IPv6) match all destinations not matching more specific routes and function as gateway of last resort.
- Administrative distance (0-255) determines route preference between different sources, with lower values more trusted (connected=0, static=1, EIGRP=90, OSPF=110, RIP=120).
- Route summarization combines contiguous networks into single advertisement by identifying common leftmost bits, reducing table size and update overhead.
- Floating static routes use higher administrative distance values than primary routes to create automatic failover when primary paths fail, typically configured 5-10 AD values above the primary route source.
- IPv6 routing requires explicit enablement with `ipv6 unicast-routing`, uses link-local addresses for next-hop on local links, lacks broadcast support, and integrates neighbor discovery into ICMPv6 rather than using separate ARP protocol.

## Related Topics Worth Exploring

**Dynamic Routing Protocol Operations** - Understanding how RIP, EIGRP, OSPF, and BGP dynamically learn and maintain routes would build on these routing fundamentals, including metric calculations, convergence behavior, and protocol-specific configurations.

**Policy-Based Routing (PBR)** - Advanced routing technique that makes forwarding decisions based on criteria beyond destination address, such as source address, packet size, or application type, using route-maps to override normal routing table decisions.

**Route Redistribution** - The process of exchanging routing information between different routing protocols or routing domains, including metric translation, administrative distance manipulation, and preventing routing loops during redistribution.

**IPv6 Transition Mechanisms** - Technologies like dual-stack, tunneling (6to4, ISATAP, GRE), and translation (NAT64) that enable IPv4 and IPv6 coexistence during the gradual migration period.