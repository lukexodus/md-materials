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

