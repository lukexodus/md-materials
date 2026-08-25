## IPv4-Mapped IPv6 Addresses


IPv4-mapped IPv6 addresses provide a mechanism to represent IPv4 addresses within the IPv6 address space, facilitating interoperability between IPv4 and IPv6 networks.

**Purpose and Usage**:

IPv4-mapped IPv6 addresses allow IPv6-enabled applications to communicate with IPv4-only nodes using IPv6 sockets. This dual-stack approach enables transition from IPv4 to IPv6 while maintaining backward compatibility.

**Address Format**:

IPv4-mapped IPv6 addresses use the prefix ::ffff:0:0/96, followed by the IPv4 address:

```
::ffff:IPv4address
```

**Representation Methods**:

**Method 1: Hexadecimal Notation**

The IPv4 address is converted to hexadecimal and represented as the last two hextets:

```
IPv4: 192.0.2.1

Binary: 11000000 00000000 00000010 00000001
Hex:    c0       00       02       01

IPv6:   ::ffff:c000:0201
```

**Method 2: Dotted-Decimal Notation**

The IPv4 address is represented in dotted-decimal format after the ::ffff: prefix:

```
IPv4:   192.0.2.1
IPv6:   ::ffff:192.0.2.1
```

This mixed notation is more readable and is the preferred representation.

**Complete Format Examples**:

```
Full form (hexadecimal):
0000:0000:0000:0000:0000:ffff:c000:0201

Compressed (hexadecimal):
::ffff:c000:0201

Compressed (dotted-decimal):
::ffff:192.0.2.1
```

**Common IPv4-Mapped IPv6 Addresses**:

```
IPv4 Address       Mapped IPv6 (hex)         Mapped IPv6 (dotted)
127.0.0.1          ::ffff:7f00:0001          ::ffff:127.0.0.1
192.168.1.1        ::ffff:c0a8:0101          ::ffff:192.168.1.1
10.0.0.1           ::ffff:0a00:0001          ::ffff:10.0.0.1
172.16.0.1         ::ffff:ac10:0001          ::ffff:172.16.0.1
8.8.8.8            ::ffff:0808:0808          ::ffff:8.8.8.8
```

**URL Syntax with IPv4-Mapped IPv6 Addresses**:

When used in URLs, IPv4-mapped IPv6 addresses follow IPv6 bracket notation requirements:

```
http://[::ffff:192.0.2.1]
http://[::ffff:192.0.2.1]:8080
https://[::ffff:192.0.2.1]/path/to/resource
http://[::ffff:127.0.0.1]:3000/api
```

**Comparison with Native Formats**:

The same address represented three ways:

```
Native IPv4:               http://192.0.2.1:8080
IPv4-mapped (hexadecimal): http://[::ffff:c000:0201]:8080
IPv4-mapped (dotted):      http://[::ffff:192.0.2.1]:8080
```

**Operational Context**:

**Dual-Stack Systems**: Systems supporting both IPv4 and IPv6 may use IPv4-mapped addresses internally:

- IPv6 sockets can accept connections from IPv4 clients
- Single socket can handle both IPv4 and IPv6 connections
- Operating system translates between address formats

**API and Socket Programming**: [Inference based on common socket implementation] When IPv6 sockets are configured with IPV6_V6ONLY disabled, they can accept IPv4 connections, representing them as IPv4-mapped IPv6 addresses.

**Network Address Translation**: NAT64 and similar transition mechanisms may use IPv4-mapped addresses to facilitate communication between IPv4 and IPv6 networks.

**Distinction from IPv4-Compatible Addresses**:

IPv4-compatible IPv6 addresses (deprecated) used the format ::IPv4address:

```
Deprecated IPv4-compatible: ::192.0.2.1
Current IPv4-mapped:        ::ffff:192.0.2.1
```

IPv4-compatible addresses are obsolete and should not be used. The ::ffff: prefix clearly identifies IPv4-mapped addresses.

**Validation and Parsing**:

Valid IPv4-mapped IPv6 addresses must:

- Begin with ::ffff: (or uncompressed form with all zeros and ffff in positions 5 and 6)
- Contain a valid IPv4 address after the prefix
- Follow standard IPv6 compression rules
- Use bracket notation in URLs

**Examples of Valid and Invalid Formats**:

```
Valid:
::ffff:192.0.2.1
::ffff:c000:0201
0000:0000:0000:0000:0000:ffff:192.0.2.1
[::ffff:192.0.2.1]                        (in URL)

Invalid:
::ffff:256.0.2.1                          → IPv4 octet exceeds 255
::ffff:192.0.2                            → Incomplete IPv4 address
::ffff::192.0.2.1                         → Double compression with prefix
::192.0.2.1                               → Missing ffff prefix (deprecated format)
```

**Application Behavior**:

[Inference] Different applications and systems may handle IPv4-mapped addresses differently:

**Web Servers**: May log IPv4-mapped addresses as native IPv4 for consistency **Access Control**: Security policies may need to recognize both formats **DNS**: Does not typically return IPv4-mapped IPv6 addresses; returns separate A (IPv4) and AAAA (IPv6) records

**Security Considerations**:

**Address Filtering**: Security systems must recognize that IPv4-mapped addresses can bypass IPv4-only filters:

- Firewall rules should account for both formats
- Access control lists should handle IPv4-mapped representations
- [Inference] Attackers might use IPv4-mapped format to evade detection

**Logging and Monitoring**: Systems should normalize addresses for consistent logging:

- Convert IPv4-mapped to native IPv4 for clarity
- Or consistently use one format across all logs
- Correlation requires recognizing equivalent addresses

**Application Compatibility**: Not all applications properly handle IPv4-mapped addresses:

- Some may reject them as invalid
- Others may not correctly extract the IPv4 portion
- Testing required for critical systems

**Best Practices**:

**Prefer Native Formats**: When possible, use native IPv4 or IPv6 addresses rather than IPv4-mapped format in URLs and configuration.

**Consistent Representation**: Within a system, use consistent address representation:

- Log files should use one format
- Configuration should use native formats when possible
- APIs should accept both but normalize internally

**Application Testing**: Test applications with:

- Native IPv4 addresses
- Native IPv6 addresses
- IPv4-mapped IPv6 addresses
- Both hexadecimal and dotted-decimal IPv4-mapped formats

**Documentation**: Clearly specify which address formats are supported and how they are processed.

The use of IP addresses directly in URLs, whether IPv4, IPv6, or IPv4-mapped IPv6, provides flexibility for direct network addressing but introduces considerations around syntax, security, and compatibility that differ from domain name usage. Understanding these formats and their proper representation in URLs is essential for robust network application development and troubleshooting.

---

