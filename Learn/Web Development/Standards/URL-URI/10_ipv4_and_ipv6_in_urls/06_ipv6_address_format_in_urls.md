## IPv6 Address Format in URLs


IPv6 addresses in URLs require square bracket delimiters to distinguish colons in the address from the port separator.

### Basic Syntax

```
scheme://[ipv6-address]:port/path?query#fragment
```

**Example:**

```
http://[2001:db8::1]/page.html
https://[2001:db8:85a3::8a2e:370:7334]:8443/api
ftp://[::1]/files
```

### Square Bracket Requirements

Square brackets are **mandatory** for IPv6 addresses in URLs to avoid ambiguity:

```
http://[2001:db8::1]:80/       // Correct
http://2001:db8::1:80/          // Incorrect - ambiguous colons
```

Without brackets, the parser cannot distinguish between address colons and the port separator.

### IPv6 Address Notation

**Full notation:**

```
[2001:0db8:0000:0000:0000:0000:0000:0001]
```

**Compressed notation (preferred):**

```
[2001:db8::1]
```

Rules for compression:

- Leading zeros in each hextet can be omitted
- One sequence of consecutive zero hextets can be replaced with `::`
- The `::` notation can appear only once per address

**Example:**

```
2001:0db8:0000:0000:0000:0000:0000:0001   // Full form
2001:db8:0:0:0:0:0:1                       // Leading zeros removed
2001:db8::1                                // Compressed
```

### IPv6 Address Components

IPv6 addresses consist of eight 16-bit hextets written in hexadecimal:

```
2001:db8:85a3:0:0:8a2e:370:7334
 │    │   │   │ │  │    │   │
 └────┴───┴───┴─┴──┴────┴───┴─── 8 hextets (128 bits total)
```

**Valid hexadecimal characters:** `0-9`, `a-f`, `A-F` (case insensitive)

### Special IPv6 Addresses in URLs

**Loopback address:**

```
http://[::1]/          // IPv6 localhost
http://[0:0:0:0:0:0:0:1]/   // Same address, uncompressed
```

**Unspecified address:**

```
[::] or [0:0:0:0:0:0:0:0]   // All zeros
```

**IPv4-mapped IPv6 addresses:**

```
[::ffff:192.168.1.1]        // IPv4 192.168.1.1 mapped to IPv6
[::ffff:c0a8:0101]          // Same address, hex notation
```

**IPv4-compatible IPv6 (deprecated):**

```
[::192.168.1.1]             // Deprecated format
```

### Link-Local Addresses

Link-local addresses require zone identifiers (see dedicated section):

```
[fe80::1%eth0]              // With zone identifier
[fe80::1%25eth0]            // URL-encoded zone identifier
```

