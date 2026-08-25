## IPv6 Addresses


IPv6 addresses use 128-bit identifiers to provide a vastly larger address space than IPv4. They appear in hexadecimal notation with eight groups of four hexadecimal digits separated by colons.

### Standard IPv6 Format

The full IPv6 format contains eight groups of four hexadecimal digits (0-9, a-f, case-insensitive) separated by colons. Each group represents 16 bits of the 128-bit address.

**Example:**

```
http://[2001:0db8:0000:0000:0000:0000:0000:0001]/
http://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/
```

IPv6 addresses in URLs must be enclosed in square brackets to avoid ambiguity with the port separator. Without brackets, the colons in the IPv6 address would be indistinguishable from the port delimiter.

**Example:**

```
http://[2001:db8::1]:8080/path
      └────┬────┘ └┬┘
      IPv6 addr  port
```

### IPv6 Compression Rules

IPv6 addresses can be compressed using specific rules to reduce length. Leading zeros in any group can be omitted, so "0db8" becomes "db8" and "0000" becomes "0".

One sequence of consecutive zero groups can be replaced with a double colon (::). This compression can only be used once per address to maintain unambiguous parsing. The double colon represents one or more groups of zeros.

**Example:**

```
Full:       2001:0db8:0000:0000:0000:0000:0000:0001
Compressed: 2001:db8::1

Full:       2001:0db8:0000:0042:0000:8a2e:0370:7334
Compressed: 2001:db8:0:42:0:8a2e:370:7334
Better:     2001:db8::42:0:8a2e:370:7334
Invalid:    2001:db8::42::7334  (double :: used twice)
```

The loopback address is typically written as `::1` (compressed from 0000:0000:0000:0000:0000:0000:0000:0001). The unspecified address is `::` (all zeros).

### IPv6 Zone Identifiers

Zone identifiers (scope IDs) specify the network interface for link-local addresses. They appear after a percent sign (%) following the IPv6 address. Zone identifiers are necessary when link-local addresses might be ambiguous across multiple interfaces.

**Example:**

```
http://[fe80::1%eth0]/
http://[fe80::1%25eth0]/  (percent-encoded in URLs)
```

In URL contexts, the percent sign in zone identifiers must itself be percent-encoded as "%25" to distinguish it from percent-encoding of other characters. The first example shows the conceptual format, while the second shows the actual URL representation.

### IPv4-Mapped IPv6 Addresses

IPv4-mapped IPv6 addresses embed IPv4 addresses within IPv6 format, facilitating dual-stack implementations. They use the format `::ffff:w.x.y.z` where w.x.y.z is the IPv4 address.

**Example:**

```
::ffff:192.168.1.1  (IPv4 192.168.1.1 mapped to IPv6)
::ffff:c0a8:0101    (same address, IPv4 in hex)
```

These addresses allow IPv6-only applications to communicate with IPv4 hosts. They're commonly used in network stacks but less common in user-facing URLs.

### IPv6 Address Validation

IPv6 validation requires checking format correctness, bracket enclosure in URLs, valid hexadecimal digits, correct use of compression (:: appears at most once), proper zone identifier encoding, and verification of special address ranges.

**Example validation cases:**

```
Valid:   [2001:db8::1]
Valid:   [::1]
Valid:   [fe80::1%25eth0]
Invalid: 2001:db8::1        (missing brackets in URL)
Invalid: [2001:db8:::1]     (malformed compression)
Invalid: [gggg::1]          (invalid hex digit 'g')
Invalid: [2001:db8::1%eth0] (unencoded % in zone ID)
```

### Special IPv6 Address Ranges

IPv6 includes several special address ranges with security implications. The loopback address (::1) references localhost. Link-local addresses (fe80::/10) are valid only on a single network segment. Unique local addresses (fc00::/7) are similar to IPv4 private addresses.

Multicast addresses (ff00::/8) target multiple recipients. Documentation addresses (2001:db8::/32) are reserved for examples and documentation. SSRF protections must account for these ranges in IPv6 contexts.

