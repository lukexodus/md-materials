## IPv6 Bracket Notation Requirement


When IPv6 addresses are used in URLs, they must be enclosed in square brackets to distinguish the colons in the address from the colon that separates the host from the port number.

**Mandatory Bracket Syntax**:

```
scheme://[IPv6address][:port][/path][?query][#fragment]
```

**Rationale for Brackets**:

Without brackets, ambiguity arises because both IPv6 addresses and URL syntax use colons:

```
Ambiguous:  http://2001:db8::1:8080/path
            Is ":8080" part of the address or the port?

Clear:      http://[2001:db8::1]:8080/path
            IPv6 address: 2001:db8::1
            Port: 8080
```

**URL Examples with IPv6 Addresses**:

```
http://[2001:db8::1]
http://[2001:db8::1]:8080
https://[2001:db8::1]/path/to/resource
http://[2001:db8::1]:3000/api/users?id=123
ftp://[2001:db8::1]/files/document.pdf
https://[2001:db8:0:42::8a2e:370:7334]:8443/admin
http://[::1]                              → IPv6 loopback
http://[::1]:8080                         → Local development server
```

**Bracket Notation Rules**:

**Required Elements**:

- Opening bracket [ must immediately follow the // in the authority component
- Closing bracket ] must appear after the complete IPv6 address
- No spaces allowed inside brackets
- IPv6 address must be valid according to IPv6 syntax rules

**With Port Numbers**:

```
Correct:   http://[2001:db8::1]:8080
Incorrect: http://[2001:db8::1:8080]     → Port inside brackets
Incorrect: http://2001:db8::1:8080       → Missing brackets
```

**Zone Identifier in URLs**:

When zone identifiers are included, they remain inside the brackets:

```
http://[fe80::1%eth0]
http://[fe80::1%eth0]:8080/path
```

However, percent signs in URLs are typically used for percent-encoding, which can create complications. The zone identifier's percent sign must be percent-encoded as %25:

```
http://[fe80::1%25eth0]
http://[fe80::1%25eth0]:8080/path
```

**Comparison with Domain Names**:

IPv6 addresses in URLs differ from domain names:

```
Domain:     http://example.com:8080
IPv4:       http://192.0.2.1:8080
IPv6:       http://[2001:db8::1]:8080
```

Only IPv6 addresses require brackets; IPv4 addresses and domain names do not.

**Browser and Client Support**:

[Inference based on modern standards] Contemporary web browsers and HTTP clients properly support IPv6 bracket notation. However, older software or improperly configured systems may not correctly parse IPv6 URLs.

**Parsing and Validation Challenges**:

URL parsers must:

- Detect opening bracket after // to identify IPv6 address
- Extract complete IPv6 address including compression
- Validate IPv6 syntax within brackets
- Distinguish closing bracket from path or query components
- Handle zone identifiers with percent-encoding
- Identify port number after closing bracket

**Invalid Examples**:

```
http://2001:db8::1                    → Missing brackets
http://[2001:db8::1                   → Missing closing bracket
http://2001:db8::1]                   → Missing opening bracket
http://[2001:db8::1:8080]/path        → Port inside brackets
http://[2001:db8::g1]                 → Invalid hex digit 'g'
http://[2001:db8:::1]                 → Multiple double colons
```

**HTTPS Certificate Validation**:

[Inference] HTTPS with IPv6 addresses faces similar challenges as with IPv4:

- Certificates are typically issued for domain names
- Subject Alternative Name (SAN) extension can include IP addresses
- Certificate validation may fail if IP address is not in certificate
- Many Certificate Authorities do not issue certificates for IP addresses

