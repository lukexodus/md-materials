## IPv4 Addresses


IPv4 addresses identify network hosts using 32-bit numeric addresses. In URLs, they appear in dotted decimal notation with four octets separated by periods.

### Standard Dotted Decimal Format

The standard IPv4 format uses four decimal numbers ranging from 0 to 255, separated by periods. Each number represents one octet (8 bits) of the 32-bit address.

**Example:**

```
http://192.168.1.1/
http://127.0.0.1:8080/
http://10.0.0.1/admin
https://172.16.254.1/
```

Each octet must be between 0 and 255 inclusive. Leading zeros are typically not allowed in standard notation but may be interpreted differently by legacy parsers. For example, "192.168.001.001" might be parsed as "192.168.1.1" by some implementations.

### Alternative IPv4 Formats

Several alternative IPv4 formats exist for historical reasons, though their use is discouraged in modern applications. These formats can create security vulnerabilities when parsers interpret them inconsistently.

Octal notation uses leading zeros to indicate octal (base-8) numbers. The address "0300.0250.0001.0001" equals "192.168.1.1" in decimal. This format is deprecated due to ambiguity and potential for parser confusion.

Hexadecimal notation uses "0x" prefix for base-16 numbers. The address "0xC0.0xA8.0x01.0x01" also represents "192.168.1.1". Mixed formats can combine decimal, octal, and hexadecimal octets.

Integer notation represents the entire address as a single 32-bit integer. The address "3232235777" equals "192.168.1.1". This format calculates as: (192 × 256³) + (168 × 256²) + (1 × 256) + 1.

**Example:**

```
http://192.168.1.1/          (standard decimal)
http://0300.0250.0001.0001/  (octal notation)
http://0xC0.0xA8.0x1.0x1/    (hexadecimal)
http://3232235777/           (integer notation)
```

All these formats can represent the same address, creating security issues when different components of a system parse them differently. A URL filter might block "192.168.1.1" but allow "3232235777", even though they reference the same host.

### IPv4 Address Validation

Proper IPv4 validation requires checking multiple criteria. Each octet must be a valid number between 0 and 255. The address must have exactly four octets. Leading zeros should be rejected or handled consistently. Alternative formats should be normalized or rejected based on security policy.

**Example validation logic:**

```
Valid:   192.168.1.1
Valid:   10.0.0.255
Invalid: 192.168.1.256  (octet exceeds 255)
Invalid: 192.168.1      (only three octets)
Invalid: 192.168.1.1.1  (five octets)
Ambiguous: 192.168.01.1 (leading zero - octal or decimal?)
```

Security-conscious applications should reject alternative formats entirely or normalize them explicitly before processing. The safest approach is accepting only standard dotted decimal notation with no leading zeros.

### Private and Special IPv4 Ranges

Certain IPv4 address ranges have special meanings and security implications. Private address ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) are not routable on the public internet and typically reference internal networks.

Loopback addresses (127.0.0.0/8, typically 127.0.0.1) reference the local host. Link-local addresses (169.254.0.0/16) are self-assigned when DHCP fails. Multicast addresses (224.0.0.0/4) target multiple recipients simultaneously.

Server-Side Request Forgery (SSRF) protections must block or carefully validate requests to these ranges, as attackers may use them to access internal resources or probe network topology.

