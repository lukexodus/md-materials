## IDNA (Internationalized Domain Names in Applications)


Internationalized Domain Names in Applications (IDNA) is a mechanism that enables domain names to contain characters from non-ASCII scripts, allowing users worldwide to access the internet using their native languages and writing systems. IDNA bridges the gap between human-readable international characters and the ASCII-only DNS infrastructure.

### The ASCII Limitation Problem

The Domain Name System (DNS) was designed with ASCII characters, limiting domain names to:

- Letters: a-z (case-insensitive)
- Digits: 0-9
- Hyphen: - (not at start or end)

This restriction excluded billions of users whose languages use non-Latin scripts:

- Chinese: 中国.com
- Arabic: السعودية.com
- Cyrillic: россия.ru
- Devanagari: भारत.in
- Greek: ελλάδα.gr
- Hebrew: ישראל.il

### IDNA Architecture

IDNA enables international domain names through a two-layer architecture:

**User Layer**: Applications display domain names using Unicode characters in the user's native script, providing a natural, localized experience.

**Protocol Layer**: DNS and other internet protocols continue using ASCII-compatible encoding (ACE), ensuring backward compatibility with existing infrastructure.

**Conversion Process**: IDNA defines algorithms to convert between Unicode domain names (U-labels) and their ASCII-compatible representations (A-labels).

### Punycode Encoding

Punycode is the encoding algorithm that converts Unicode strings to ASCII-compatible format:

**Encoding Pattern**:

```
xn--<encoded-string>
```

The `xn--` prefix identifies a Punycode-encoded label, signaling that it represents international characters.

**Examples**:

Chinese domain:

```
Unicode (U-label): 中国
Punycode (A-label): xn--fiqs8s
Full domain: 中国.com → xn--fiqs8s.com
```

Arabic domain:

```
Unicode: السعودية
Punycode: xn--mgberp4a5d4ar
Full domain: السعودية.com → xn--mgberp4a5d4ar.com
```

German domain:

```
Unicode: münchen
Punycode: xn--mnchen-3ya
Full domain: münchen.de → xn--mnchen-3ya.de
```

Greek domain:

```
Unicode: ελλάδα
Punycode: xn--qxam
Full domain: ελλάδα.gr → xn--qxam.gr
```

Mixed ASCII and Unicode:

```
Unicode: café
Punycode: xn--caf-dma
Full domain: café.fr → xn--caf-dma.fr
```

**Punycode Algorithm Characteristics**:

- Efficient encoding of Unicode characters
- Preserves ASCII characters unchanged (except triggering xn-- prefix if any non-ASCII present)
- Case-insensitive encoding
- Variable length output depending on Unicode complexity
- Deterministic and reversible

### IDNA Processing Steps

**User Input to DNS Query**:

1. **Normalization**: Convert Unicode string to normalized form (NFC - Normalization Form C)
    
    ```
    Input: café (with combining acute accent)
    Normalized: café (with precomposed é)
    ```
    
2. **Validation**: Check characters against allowed Unicode code points for domain names
    
3. **Punycode Encoding**: Convert each label (segment between dots) to ASCII-compatible encoding
    
    ```
    café.example.com
    → xn--caf-dma.example.com
    ```
    
4. **DNS Query**: Send ASCII-encoded domain to DNS servers
    

**DNS Response to User Display**:

1. **Receive ASCII Response**: DNS returns ASCII-encoded domain
    
2. **Punycode Detection**: Identify labels with `xn--` prefix
    
3. **Punycode Decoding**: Convert A-labels back to U-labels
    
    ```
    xn--caf-dma.example.com
    → café.example.com
    ```
    
4. **Display**: Show Unicode domain to user in application interface
    

### Label-by-Label Processing

IDNA processes each label (domain segment) independently:

```
例え.テスト.example
```

Becomes:

```
xn--r8jz45g.xn--zckzah.example
```

Where:

- `例え` → `xn--r8jz45g`
- `テスト` → `xn--zckzah`
- `example` remains unchanged (pure ASCII)

This label-by-label approach allows mixing of:

- International labels
- ASCII labels
- Different scripts in different labels (though not recommended)

### Character Restrictions

IDNA defines which Unicode characters are permitted in domain names:

**Allowed Characters**:

- Letters from various scripts (Latin, Chinese, Arabic, Cyrillic, etc.)
- Digits from various scripts
- Certain marks and symbols specific to writing systems
- Hyphen-minus (U+002D)

**Disallowed Characters**:

- Control characters
- Whitespace characters
- Format characters
- Most punctuation and symbols
- Bidirectional control characters (in most contexts)
- Unassigned code points

**Contextual Rules**: Some characters allowed only in specific contexts:

- Middle dot (·) only in Catalan l·l combinations
- Zero-width joiner/non-joiner only with appropriate scripts
- Arabic-Indic digits only with Arabic script

### Right-to-Left (RTL) Script Handling

IDNA includes special rules for right-to-left scripts like Arabic and Hebrew:

**Bidi Rule**: Ensures consistent directionality within labels:

- If a label contains RTL characters, it must follow RTL rules
- Mixing LTR and RTL must follow specific patterns
- Prevents visual confusion from directional ambiguity

**Example**:

```
Arabic: مثال.com
Display: com.مثال (may appear reversed in some contexts)
Encoding: xn--mgbh0fb.com
```

**Display Challenges**: RTL domains may display differently depending on:

- Operating system
- Browser rendering
- Font support
- Surrounding text context

### IDNA Versions

Two major IDNA versions exist with significant differences:

**IDNA2003** (RFC 3490, 3491, 3492):

- Original IDNA specification
- More permissive character allowances
- Used Nameprep for string preparation
- Based on Unicode 3.2

**IDNA2008** (RFC 5890-5894):

- Updated specification addressing IDNA2003 limitations
- Stricter character validation
- Protocol-independent Unicode normalization
- Based on Unicode properties that evolve with Unicode versions
- Better security considerations

The differences between versions create compatibility challenges addressed in the next section.

### Protocol Integration

IDNA integrates with various internet protocols:

**HTTP/HTTPS**: Browsers convert Unicode domains to Punycode for HTTP Host headers and TLS Server Name Indication (SNI):

```
User types: https://例え.jp
Browser sends Host: xn--r8jz45g.jp
```

**Email**: Email addresses can contain IDN domains:

```
User display: user@例え.jp
SMTP transmission: user@xn--r8jz45g.jp
```

**DNS**: All DNS queries use Punycode-encoded A-labels, maintaining ASCII compatibility.

**Certificates**: SSL/TLS certificates can be issued for IDN domains, with the domain appearing as Punycode in the certificate but displayed as Unicode to users.

### IDNA Benefits

**Accessibility**: Enables internet access for non-English speakers using native scripts, removing language barriers.

**Cultural Identity**: Allows businesses and organizations to represent their brands authentically in native scripts.

**User Experience**: Simplifies domain memorization and typing for users in their native languages.

**Market Reach**: Enables localized domain names for international markets.

**Linguistic Preservation**: Supports minority languages and scripts in the digital space.

### Implementation Considerations

**Application Requirements**:

- Unicode text processing capabilities
- Punycode encoding/decoding libraries
- Normalization algorithms
- Character validation against IDNA rules
- Proper display of mixed scripts

**DNS Server Compatibility**: DNS servers don't require IDNA awareness since they only process ASCII-encoded A-labels. The encoding/decoding happens in applications.

**Database Storage**: Applications must decide whether to store:

- Unicode form (U-labels): Human-readable, requires conversion for DNS
- Punycode form (A-labels): DNS-ready, less human-readable
- Both forms: Redundant but optimizes for different use cases

**Testing Requirements**:

- Verify encoding/decoding accuracy
- Test with various Unicode scripts
- Validate character restriction enforcement
- Check proper handling of edge cases (mixed scripts, RTL text)

**Key Points**: IDNA enables international domain names through Punycode encoding, converting Unicode characters to ASCII-compatible format for DNS compatibility while displaying native scripts to users. The system processes each domain label independently and includes strict character validation to ensure security and consistency. IDNA represents a critical advancement in internet accessibility, allowing billions of users to interact with the internet in their native languages.

