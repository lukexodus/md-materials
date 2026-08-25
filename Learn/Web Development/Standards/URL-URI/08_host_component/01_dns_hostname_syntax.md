## DNS Hostname Syntax


DNS hostnames follow specific syntax rules defined in RFC 1123, which updated the original RFC 952 specifications. These rules govern the formation of valid hostnames used in the host subcomponent of URIs.

**Character Set:**

```
hostname = *( label "." ) label
label = (ALPHA / DIGIT) *( (ALPHA / DIGIT / "-") (ALPHA / DIGIT) )
```

Valid characters include:

- Letters: A-Z, a-z (case-insensitive)
- Digits: 0-9
- Hyphen: - (not at start or end of label)

**Label Rules:**

Each label (segment between dots) must satisfy:

- Minimum length: 1 character
- Maximum length: 63 octets
- Must start with alphanumeric character
- Must end with alphanumeric character
- May contain hyphens in middle positions
- Cannot be all-numeric (except for IPv4 addresses)

**Examples of Valid Labels:**

```
example
example-site
a1b2c3
test-123-server
```

**Examples of Invalid Labels:**

```
-example        (starts with hyphen)
example-        (ends with hyphen)
ex@mple         (contains invalid character)
123.456.789     (appears as IPv4, but octets exceed 255)
a_label         (underscore not permitted in hostnames, though allowed in DNS generally)
```

**Total Hostname Length:**

The complete hostname, including all labels and dots, cannot exceed 253 octets in DNS wire format (255 octets total, minus 2 for encoding). When represented in ASCII form with dots, this typically means 253 characters maximum.

**Case Insensitivity:**

DNS hostnames are case-insensitive. The following are considered identical:

```
Example.COM
example.com
EXAMPLE.com
ExAmPlE.CoM
```

Standard normalization converts hostnames to lowercase for comparison and canonical representation.

**Internationalized Domain Names (IDN):**

Non-ASCII characters in domain names use Punycode encoding with the "xn--" prefix:

```
münchen.de           (Unicode representation)
xn--mnchen-3ya.de    (ASCII-compatible encoding)

日本.jp              (Unicode)
xn--wgv71a.jp        (Punycode)

παράδειγμα.gr        (Greek)
xn--hxajbheg2az3al.gr (Punycode)
```

The encoding process:

1. Unicode domain is normalized using Nameprep (RFC 3491)
2. Each label with non-ASCII characters is encoded using Punycode algorithm
3. Encoded labels receive "xn--" prefix
4. Result is ASCII-compatible encoding (ACE)

**Numeric Restrictions:**

While labels can contain digits, pure numeric labels (like "123") can create ambiguity with IPv4 addresses. Many systems and specifications impose additional restrictions:

```
example.123           (technically valid)
123.example.com       (valid, TLD distinguishes from IPv4)
192.168.1.1          (IPv4 address, not hostname)
```

