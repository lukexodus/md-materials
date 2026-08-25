## IPv4 Address Syntax (192.0.2.1)


IPv4 (Internet Protocol version 4) addresses consist of 32 bits divided into four octets, each represented as a decimal number between 0 and 255, separated by periods (dots).

**Basic Structure**:

```
decimal.decimal.decimal.decimal
```

Each decimal number represents 8 bits (one octet), ranging from 0 to 255.

**URL Syntax with IPv4 Addresses**:

When used in URLs, IPv4 addresses replace the hostname component and follow standard URI syntax:

```
scheme://IPv4address[:port][/path][?query][#fragment]
```

**Examples**:

```
http://192.0.2.1
http://192.0.2.1:8080
https://192.0.2.1/path/to/resource
http://192.0.2.1:3000/api/users?id=123
ftp://192.0.2.1/files/document.pdf
https://203.0.113.45:8443/admin
```

**Valid IPv4 Address Ranges**:

**Public IP Addresses**: Routable on the public internet

- Class A: 1.0.0.0 to 126.255.255.255
- Class B: 128.0.0.0 to 191.255.255.255
- Class C: 192.0.0.0 to 223.255.255.255

**Private IP Addresses**: Reserved for private networks (RFC 1918)

- 10.0.0.0 to 10.255.255.255 (Class A private)
- 172.16.0.0 to 172.31.255.255 (Class B private)
- 192.168.0.0 to 192.168.255.255 (Class C private)

**Special-Use Addresses**:

- 127.0.0.0 to 127.255.255.255: Loopback addresses (localhost)
- 169.254.0.0 to 169.254.255.255: Link-local addresses (APIPA)
- 0.0.0.0: Represents "this network" or default route
- 255.255.255.255: Broadcast address

**Common URL Usage Examples**:

```
http://127.0.0.1              → Local loopback (localhost)
http://127.0.0.1:8080         → Local development server
http://192.168.1.1            → Common router address
http://192.168.0.100:3000     → Local network device
http://10.0.0.5/admin         → Private network server
```

**Dotted-Decimal Notation Rules**:

**Standard Format**: Each octet must be represented as a decimal number without leading zeros (except for the number 0 itself):

```
Correct:   192.0.2.1
Correct:   192.0.2.10
Incorrect: 192.000.002.001
Incorrect: 192.0.2.01
```

**Octet Value Constraints**:

- Minimum value per octet: 0
- Maximum value per octet: 255
- Total possible addresses: 4,294,967,296 (2³²)

**Alternative Representations**:

[Inference based on legacy systems] Some systems historically supported alternative IPv4 representations, though these are not recommended for URLs:

**Octal notation**: Octets prefixed with 0 (e.g., 0300.0000.0002.0001) **Hexadecimal notation**: Octets prefixed with 0x (e.g., 0xC0.0x00.0x02.0x01) **Integer notation**: Single 32-bit integer (e.g., 3221225985)

Modern URL parsing typically only accepts standard dotted-decimal notation.

**Parsing and Validation**:

Valid IPv4 addresses in URLs must:

- Contain exactly four octets separated by three periods
- Have each octet value between 0 and 255
- Not contain leading zeros (except for the value 0)
- Not contain any whitespace or special characters

**Invalid Examples**:

```
192.0.2          → Missing octets
192.0.2.256      → Octet exceeds 255
192.0.2.1.5      → Too many octets
192.0.2.-1       → Negative value
192.0.2.1a       → Non-numeric characters
```

**Security Considerations**:

Using IP addresses directly in URLs has security implications:

- No DNS-based protection or filtering
- [Inference] Certificate validation issues with HTTPS (certificates typically issued for domain names, not IP addresses)
- Bypass of host-based security policies
- [Inference] Difficulty in implementing virtual hosting (multiple domains on one IP)
- Exposure of internal network topology when using private addresses

