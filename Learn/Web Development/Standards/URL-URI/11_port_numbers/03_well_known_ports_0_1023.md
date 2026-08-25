## Well-Known Ports (0-1023)


### Definition and Characteristics

Well-known ports are port numbers from 0 to 1023, reserved for common services and protocols by IANA (Internet Assigned Numbers Authority).

**Key characteristics:**

**Privileged ports:** On Unix-like systems (Linux, macOS, BSD), binding to these ports requires root/superuser privileges.

**Standardization:** Registered with IANA for specific services to ensure global consistency.

**Historical significance:** Established early in Internet history for foundational protocols.

**System services:** Typically used by operating system services rather than user applications.

### Privilege Requirements

**Unix-like systems:**

```bash
# Requires root privileges
sudo node server.js  # Binding to port 80

# Alternative: Use capabilities (Linux)
sudo setcap 'cap_net_bind_service=+ep' /usr/bin/node
node server.js  # Can now bind to port 80 without full root
```

**Windows:** No special privileges required to bind to any port.

**Security implications:**

- Privilege requirement provides security boundary
- Prevents regular users from impersonating system services
- Reduces attack surface by limiting who can bind to critical ports

### Major Well-Known Ports

**Port 20 - FTP Data:**

```
Protocol: FTP (File Transfer Protocol) - Data channel
Usage: Active mode data transfer
Related: Port 21 (control channel)
```

**Port 21 - FTP Control:**

```
Protocol: FTP - Control channel
Usage: Commands and responses
Example: ftp://ftp.example.com/ → port 21
```

**Port 22 - SSH:**

```
Protocol: SSH (Secure Shell)
Usage: Secure remote login, command execution, file transfer (SFTP, SCP)
Example: ssh://user@example.com/ → port 22
Common tools: OpenSSH, PuTTY
```

**Port 23 - Telnet:**

```
Protocol: Telnet
Usage: Unencrypted text communication
Security: Deprecated due to lack of encryption (use SSH instead)
Example: telnet://example.com/ → port 23
```

**Port 25 - SMTP:**

```
Protocol: SMTP (Simple Mail Transfer Protocol)
Usage: Email transmission between mail servers
Example: smtp://mail.example.com/ → port 25
Note: Often blocked by ISPs to prevent spam
```

**Port 53 - DNS:**

```
Protocol: DNS (Domain Name System)
Usage: Domain name resolution
Transport: UDP (primarily), TCP (for large responses, zone transfers)
Example: dns://8.8.8.8/ → port 53
```

**Port 67/68 - DHCP:**

```
Port 67: DHCP Server
Port 68: DHCP Client
Protocol: DHCP (Dynamic Host Configuration Protocol)
Usage: Automatic IP address assignment
```

**Port 69 - TFTP:**

```
Protocol: TFTP (Trivial File Transfer Protocol)
Usage: Simple file transfer (no authentication)
Transport: UDP
Common use: Network device firmware updates
```

**Port 80 - HTTP:**

```
Protocol: HTTP (Hypertext Transfer Protocol)
Usage: Unencrypted web traffic
Example: http://example.com/ → port 80
Default for: Web browsers, web servers
```

**Port 110 - POP3:**

```
Protocol: POP3 (Post Office Protocol version 3)
Usage: Email retrieval from server
Example: pop3://mail.example.com/ → port 110
Secure alternative: Port 995 (POP3S)
```

**Port 119 - NNTP:**

```
Protocol: NNTP (Network News Transfer Protocol)
Usage: Usenet news reading/posting
Example: nntp://news.example.com/ → port 119
```

**Port 123 - NTP:**

```
Protocol: NTP (Network Time Protocol)
Usage: Clock synchronization
Transport: UDP
Example: Time servers like time.nist.gov:123
```

**Port 143 - IMAP:**

```
Protocol: IMAP (Internet Message Access Protocol)
Usage: Email access and management
Example: imap://mail.example.com/ → port 143
Secure alternative: Port 993 (IMAPS)
```

**Port 161/162 - SNMP:**

```
Port 161: SNMP Agent
Port 162: SNMP Trap
Protocol: SNMP (Simple Network Management Protocol)
Usage: Network device monitoring and management
```

**Port 389 - LDAP:**

```
Protocol: LDAP (Lightweight Directory Access Protocol)
Usage: Directory services access
Example: ldap://directory.example.com/ → port 389
Secure alternative: Port 636 (LDAPS)
```

**Port 443 - HTTPS:**

```
Protocol: HTTPS (HTTP Secure)
Usage: Encrypted web traffic (HTTP over TLS/SSL)
Example: https://example.com/ → port 443
Default for: Secure web browsers, web APIs
```

**Port 445 - SMB:**

```
Protocol: SMB (Server Message Block)
Usage: Windows file sharing, printer sharing
Also known as: Microsoft-DS
Security: Frequently targeted by malware
```

**Port 465 - SMTPS:**

```
Protocol: SMTPS (SMTP Secure)
Usage: Email submission over SSL/TLS (deprecated, then revived)
Note: Port 587 with STARTTLS is preferred
```

**Port 514 - Syslog:**

```
Protocol: Syslog
Usage: System logging
Transport: UDP (traditionally), TCP (modern)
```

**Port 587 - SMTP Submission:**

```
Protocol: SMTP (Mail Submission)
Usage: Email client to mail server submission
Security: Typically requires authentication and STARTTLS
Preferred over: Port 25 for email clients
```

**Port 636 - LDAPS:**

```
Protocol: LDAPS (LDAP Secure)
Usage: LDAP over SSL/TLS
Example: ldaps://directory.example.com/ → port 636
```

**Port 853 - DNS over TLS:**

```
Protocol: DoT (DNS over TLS)
Usage: Encrypted DNS queries
Example: Cloudflare's 1.1.1.1:853
```

**Port 989/990 - FTPS:**

```
Port 989: FTPS Data (implicit)
Port 990: FTPS Control (implicit)
Protocol: FTPS (FTP over SSL/TLS)
Usage: Secure file transfer
```

**Port 993 - IMAPS:**

```
Protocol: IMAPS (IMAP Secure)
Usage: IMAP over SSL/TLS
Example: imaps://mail.example.com/ → port 993
```

**Port 995 - POP3S:**

```
Protocol: POP3S (POP3 Secure)
Usage: POP3 over SSL/TLS
Example: pop3s://mail.example.com/ → port 995
```

### Reserved and Special Ports

**Port 0:**

```
Meaning: System-assigned port
Usage: Request OS to assign any available port
Not valid in URIs: Cannot explicitly specify port 0
Example use case: Socket binding in programming
```

```python
# Python example
import socket
sock = socket.socket()
sock.bind(('', 0))  # OS assigns available port
actual_port = sock.getsockname()[1]
print(f"Assigned port: {actual_port}")
```

**Ports 1-9:** Various historical services, rarely used today.

**Port 7 - Echo:**

```
Protocol: Echo
Usage: Testing, debugging (echoes back received data)
Security: Typically disabled due to abuse potential
```

**Port 9 - Discard:**

```
Protocol: Discard
Usage: Testing (discards all received data)
Security: Typically disabled
```

### Security Considerations for Well-Known Ports

**Common attack targets:**

- Port 22 (SSH): Brute-force attacks, credential stuffing
- Port 80/443 (HTTP/HTTPS): Web application attacks, DDoS
- Port 25 (SMTP): Spam relay attempts
- Port 445 (SMB): Ransomware, worm propagation
- Port 3389 (RDP): Brute-force attacks

**[Inference] Best practices:**

- Change default ports for sensitive services when possible
- Use firewall rules to restrict access
- Implement rate limiting and intrusion detection
- Disable unused services
- Use VPNs or SSH tunneling for remote access

**Port scanning awareness:** Well-known ports are frequently scanned by attackers searching for vulnerable services.

```bash
# Example: Common port scan (informational only)
nmap -p 20-1023 target.example.com
```

