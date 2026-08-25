## xn-- Prefix


The **"xn--" prefix** is the ASCII Compatible Encoding (ACE) prefix that identifies Punycode-encoded internationalized domain name labels in DNS. This prefix distinguishes encoded IDN labels from regular ASCII domain labels, enabling DNS systems to recognize and process them correctly.

**Definition and Purpose:**

According to RFC 3490 and RFC 5891, the ACE prefix "xn--" (case-insensitive) marks the beginning of a Punycode-encoded label. When DNS software encounters this prefix, it recognizes the following characters as an encoded representation of Unicode characters.

The prefix serves multiple functions:

**Identification**: Signals that the label contains Punycode encoding **Namespace separation**: Prevents collision with existing ASCII-only domains **Backward compatibility**: Allows non-IDN-aware systems to process labels as ASCII strings **Detection**: Enables IDN-aware applications to decode and display Unicode

**Structure:**

```
xn--[punycode-encoded-string]

Format: xn-- + punycode(unicode_label)
```

The prefix always appears in lowercase in DNS queries and responses, though it is case-insensitive for processing. The Punycode-encoded portion follows immediately after the prefix.

**Example Transformations:**

```
User sees: münchen.de
DNS queries: xn--mnchen-3ya.de

User sees: 中国.cn
DNS queries: xn--fiqs8s.cn

User sees: москва.рф
DNS queries: xn--80ake.xn--p1ai

User sees: مثال.إختبار
DNS queries: xn--mgbh0fb.xn--kgbechtv

User sees: παράδειγμα.δοκιμή
DNS queries: xn--hxajbheg2az4pqz2a.xn--jxalpdlp
```

**Application in Domain Names:**

The xn-- prefix applies to each label (segment between dots) independently. In a fully internationalized domain name, multiple labels may be encoded:

```
User types: 例え.日本.jp
Browser converts: xn--r8jz45g.xn--wgv71a.jp

User types: مكتب.شركة.مصر
Browser converts: xn--[encoded1].xn--[encoded2].xn--wgbl6i
```

**Key Points:**

- "xn--" is the universal ACE prefix for all IDNs
- Case-insensitive (xn--, XN--, Xn-- all equivalent)
- Applied per label, not to entire domain
- 63-octet label limit includes the "xn--" prefix (4 bytes)
- ASCII labels never receive the prefix
- Must be followed by valid Punycode encoding

**Processing Flow:**

**User Input to DNS Query:**

1. User enters Unicode domain: "münchen.de"
2. Application detects non-ASCII characters
3. Application applies IDNA processing (normalization, validation)
4. Application encodes label to Punycode: "mnchen-3ya"
5. Application prepends "xn--": "xn--mnchen-3ya"
6. DNS query sent for: "xn--mnchen-3ya.de"

**DNS Response to User Display:**

1. DNS returns: "xn--mnchen-3ya.de"
2. Application detects "xn--" prefix
3. Application extracts Punycode: "mnchen-3ya"
4. Application decodes to Unicode: "münchen"
5. User sees: "münchen.de"

**Length Constraints:**

DNS labels are limited to 63 octets (bytes). The "xn--" prefix consumes 4 octets, leaving 59 octets for the Punycode-encoded string:

```
Total label length: ≤ 63 octets
xn-- prefix: 4 octets
Punycode portion: ≤ 59 octets
```

[Inference] This constraint limits how many Unicode characters can appear in a single label, particularly for characters with high code point values that require more encoding space.

**Example:**

```
Short Unicode: 中国
Encoded: xn--fiqs8s (10 total octets)
Within limit: ✓

Long Unicode: αβγδεζηθικλμνξοπρστυφχψω
Encoded: xn--[very long string]
Potential limit issue: may approach 63-octet boundary
```

**Security Implications:**

The xn-- prefix provides a visual indicator that a domain contains encoded non-ASCII characters. However, most users never see the encoded form in modern browsers.

**Homograph attack consideration**: The prefix doesn't prevent confusion attacks where visually similar characters from different scripts create lookalike domains:

```
Legitimate: example.com
Malicious IDN: еxample.com (Cyrillic 'е' looks like Latin 'e')
Encoded: xn--xample-9ub.com
```

Modern browsers implement **IDN display policies** to mitigate homograph attacks:

- Show Punycode for suspicious domains
- Restrict display of IDNs mixing scripts
- Show warning indicators for lookalike domains

**Browser Display Behavior:**

**IDN display** (typical case):

```
Address bar shows: münchen.de
Tooltip/inspect may show: xn--mnchen-3ya.de
```

**Punycode display** (security-triggered):

```
Address bar shows: xn--xample-9ub.com
(Browser detected suspicious pattern)
```

**Registry and Registrar Handling:**

Domain registries store domain names in their ACE-encoded form (xn-- prefix with Punycode) in zone files and databases:

```
Zone file entry:
xn--mnchen-3ya.de.  IN  A  192.0.2.1

Whois database:
Domain Name: xn--mnchen-3ya.de
```

Registrar interfaces typically display both forms:

```
Domain: münchen.de (xn--mnchen-3ya.de)
```

**Email Addresses:**

The xn-- prefix applies to domain portions of email addresses:

```
User enters: user@münchen.de
Email system converts: user@xn--mnchen-3ya.de
SMTP transmission: user@xn--mnchen-3ya.de
Display to user: user@münchen.de
```

The local part (before @) uses different internationalization mechanisms defined in RFC 6531 (SMTPUTF8) rather than Punycode encoding.

**Historical Context:**

The "xn--" prefix was chosen through IETF consensus to:

- Be highly unlikely to collide with existing domains
- Be short to minimize label length consumption
- Be clearly recognizable as special encoding
- Be typeable on all keyboards

Alternative prefixes considered included "bq--", "dq--", and "ra--", but "xn--" was selected as the standard.

**Validation:**

Applications must validate that strings following "xn--" contain valid Punycode:

```
Valid: xn--mnchen-3ya (correct Punycode)
Invalid: xn--invalid!@# (contains invalid Punycode characters)
Invalid: xn-- (empty Punycode portion)
```

[Inference] Invalid xn-- strings should be rejected during domain registration and DNS query processing to prevent malformed IDNs.

**Key Points:**

- "xn--" universally identifies Punycode-encoded IDN labels
- Four-character prefix reduces available encoding space
- Applied per-label in multi-label domains
- Enables transparent IDN processing in DNS infrastructure
- Modern browsers hide encoding from users under normal conditions
- Security policies may force Punycode display for suspicious domains
- Case-insensitive but conventionally lowercase

The xn-- prefix is fundamental to IDN implementation, providing the bridge between Unicode domain names and ASCII-compatible DNS infrastructure while maintaining transparency for end users in typical use cases.

---

