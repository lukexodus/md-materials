## IPv4 Address Format in URLs


IPv4 addresses in URLs use the standard dotted-decimal notation without special delimiters.

### Basic Syntax

```
scheme://ipv4-address:port/path?query#fragment
```

**Example:**

```
http://192.168.1.1/admin
https://10.0.0.5:8443/api/data
ftp://203.0.113.42/files
```

### Dotted-Decimal Notation

IPv4 addresses consist of four decimal octets (0-255) separated by dots:

```
192.168.1.1
10.0.0.1
172.16.0.0
203.0.113.0
```

**Invalid formats:**

```
192.168.1          // Missing octets
192.168.1.256      // Octet exceeds 255
192.168.1.1.1      // Too many octets
192.168.01.1       // Leading zeros may cause issues
```

### Alternative IPv4 Notations

Some systems historically supported alternative representations, though these are discouraged in URLs:

**Decimal notation:**

```
http://3232235777/   // Equivalent to 192.168.1.1
```

Calculation: `(192 × 256³) + (168 × 256²) + (1 × 256) + 1 = 3232235777`

**Octal notation (deprecated):**

```
http://0300.0250.0001.0001/   // Equivalent to 192.168.1.1
```

**Hexadecimal notation (deprecated):**

```
http://0xC0.0xA8.0x01.0x01/   // Equivalent to 192.168.1.1
```

**Key Points:**

- Use standard dotted-decimal notation in URLs
- Alternative notations may be misinterpreted or blocked by security filters
- Modern browsers and applications generally reject non-standard formats
- Leading zeros can cause octal interpretation issues

### IPv4 Ranges and CIDR Notation

CIDR notation is not valid in URLs but is used for network configuration:

```
192.168.1.0/24     // Network notation (not a URL)
10.0.0.0/8         // Network notation (not a URL)
```

For URL purposes, specify individual IP addresses only.

