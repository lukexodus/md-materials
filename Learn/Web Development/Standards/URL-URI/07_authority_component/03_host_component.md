## Host Component


The host subcomponent identifies the specific host machine or service within the authority's namespace. It is the only mandatory part of the authority for most schemes.

### Host Types

The host can be specified in three formats:

**DNS/registered name:** Domain names and other registered identifiers

```
example.com
subdomain.example.org
localhost
my-server
```

**IPv4 address:** Dotted-decimal notation

```
192.168.1.1
127.0.0.1
10.0.0.255
```

**IPv6 address:** Hexadecimal notation enclosed in brackets

```
[2001:db8::1]
[::1]
[fe80::1%eth0]
```

### DNS Names and Registered Names

A registered name consists of labels separated by dots, following DNS naming conventions.

**Syntax rules (RFC 3986):**

- Labels contain letters, digits, hyphens
- Labels cannot start or end with hyphen
- Labels are case-insensitive
- Maximum label length: 63 characters
- Maximum total length: 253 characters

**Example:**

```
http://www.example.com/
http://api-v2.staging.example.org/
http://EXAMPLE.COM/  // Equivalent to example.com
```

**Percent-encoding in hosts:** Hosts generally use limited character sets, but percent-encoding is allowed for internationalized domain names (IDN) processing:

```
http://ex%61mple.com/  // Decodes to example.com
```

**Special characters:** Per RFC 3986, hosts allow unreserved characters and sub-delimiters, but not the general delimiters `:`, `/`, `?`, `#`, `[`, `]`, `@`

### Internationalized Domain Names (IDN)

Domain names containing non-ASCII Unicode characters require special encoding.

**Encoding process (Punycode):**

1. Unicode domain name provided by user
2. Converted to ASCII using IDNA (Internationalized Domain Names in Applications)
3. Each label with Unicode characters gets `xn--` prefix
4. Unicode characters encoded as ASCII string

**Example:**

```
Original: http://münchen.de/
Encoded:  http://xn--mnchen-3ya.de/

Original: http://例え.jp/
Encoded:  http://xn--r8jz45g.jp/
```

**Mixed scripts:**

```
http://中国.中国/
Encoded: http://xn--fiqs8s.xn--fiqs8s/
```

**Browser behavior:** Modern browsers typically display the decoded Unicode form in the address bar while transmitting the encoded form.

### IPv4 Addresses

IPv4 addresses consist of four decimal octets separated by dots.

**Standard format:**

```
192.168.1.1
10.0.0.0
172.16.254.1
127.0.0.1
```

**Value ranges:**

- Each octet: 0-255
- Total: 2^32 possible addresses (4,294,967,296)

**Example in URI:**

```
http://192.168.1.1/admin
http://127.0.0.1:8080/
ftp://10.0.0.5/files
```

**Leading zeros:** RFC 3986 allows leading zeros, but interpretation varies:

```
http://192.168.001.001/
```

Some systems interpret leading zeros as octal notation, causing ambiguity. **[Inference] Modern practice avoids leading zeros.**

**Alternative formats:** Some systems accept non-standard IPv4 formats (not in RFC 3986):

- Decimal: `3232235777` (representing 192.168.1.1)
- Octal: `0300.0250.0001.0001`
- Hexadecimal: `0xC0.0xA8.0x01.0x01`

**Note:** [Unverified] These alternative formats are not universally supported and should be avoided for interoperability.

**Localhost and loopback:**

```
http://127.0.0.1/  // IPv4 loopback
http://localhost/   // DNS name that resolves to 127.0.0.1
```

### IPv6 Addresses

IPv6 addresses use 128-bit addressing with hexadecimal notation and must be enclosed in brackets within URIs.

**Standard format:**

```
[2001:0db8:0000:0000:0000:0000:0000:0001]
```

**Compressed format:** Consecutive zero groups can be replaced with `::` (once per address):

```
[2001:db8::1]
[::1]  // Loopback address
[::ffff:192.0.2.1]  // IPv4-mapped IPv6 address
```

**Example in URI:**

```
http://[2001:db8::1]/
http://[2001:db8::1]:8080/path
https://[fe80::1%eth0]/  // With zone identifier
```

**Zone identifiers:** Link-local addresses may include a zone identifier (network interface) after a percent sign:

```
[fe80::1%eth0]
[fe80::1%25en0]  // %25 is percent-encoded %
```

**Bracket requirement:** Brackets are mandatory to distinguish the colons in the IPv6 address from the port separator:

```
Correct: http://[2001:db8::1]:80/
Wrong:   http://2001:db8::1:80/  // Ambiguous
```

**IPv4-mapped IPv6:**

```
[::ffff:192.0.2.1]
[::ffff:c000:0201]  // Same address in hex
```

**Parsing challenges:**

**Double colon placement:** Only one `::` allowed per address

```
Valid:   [2001:db8::1]
Invalid: [2001::db8::1]
```

**Group limits:** Maximum 8 groups of 4 hex digits

```
Valid:   [2001:db8:0:0:0:0:0:1]
Invalid: [2001:db8:0:0:0:0:0:0:1]  // 9 groups
```

**Mixed notation:**

```
[2001:db8::192.0.2.1]  // Last 32 bits in IPv4 notation
```

### Localhost Representations

**IPv4 loopback:**

```
127.0.0.1
127.0.0.0/8  // Entire range
```

**IPv6 loopback:**

```
::1
```

**DNS name:**

```
localhost
```

**Example URIs:**

```
http://localhost/
http://127.0.0.1/
http://[::1]/
```

### Host Normalization

Host normalization ensures consistent representation for comparison.

**Case normalization:** DNS names are case-insensitive and should be normalized to lowercase:

```
HTTP://EXAMPLE.COM/ → http://example.com/
http://Example.Com/ → http://example.com/
```

**Percent-encoding normalization:** Decode percent-encoded characters that are in the unreserved set:

```
http://ex%61mple.com/ → http://example.com/
```

**IPv6 compression:** Apply standard compression rules:

```
[2001:0db8:0000:0000:0000:0000:0000:0001] → [2001:db8::1]
```

**IDN normalization:** Ensure consistent Punycode encoding:

```
http://münchen.de/ → http://xn--mnchen-3ya.de/
```

### Empty Host

Some URI schemes allow empty hosts:

**File scheme:**

```
file:///path/to/file  // Empty host, local file
file://host/path      // Named host
```

**Custom schemes:**

```
custom:///resource    // Scheme-dependent interpretation
```

