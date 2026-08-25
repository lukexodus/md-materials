## URI Character Encoding


URI character encoding ensures that URIs remain compatible with systems that may have limited character set support. The specification uses percent-encoding (also called URL encoding) to represent characters that are not allowed in their literal form.

**Percent-Encoding Mechanism**: Characters are represented as a percent sign (%) followed by two hexadecimal digits representing the character's byte value in UTF-8 encoding. For example:

- Space character: %20
- Forward slash (when literal): %2F
- Percent sign (when literal): %25

**Unreserved Characters**: These characters do not require encoding and should not be percent-encoded:

- Uppercase and lowercase letters: A-Z, a-z
- Decimal digits: 0-9
- Hyphen: -
- Period: .
- Underscore: _
- Tilde: ~

**Reserved Characters**: Characters with special syntactic meaning in URIs. They must be percent-encoded when used in a literal capacity:

- Reserved for general delimiters: : / ? # [ ] @
- Reserved as sub-delimiters: ! $ & ' ( ) * + , ; =

**Normalization Considerations**:

Character encoding normalization involves several processes:

**Case Normalization**: The scheme and host components are case-insensitive and should be normalized to lowercase. Percent-encoding triplets (the hexadecimal digits) should be normalized to uppercase.

**Percent-Encoding Normalization**: Unreserved characters that are percent-encoded should be decoded. For example, %7E should be normalized to ~.

**Path Segment Normalization**: Removal of dot-segments (. and ..) from the path component according to specified algorithms.

**International Characters**: Non-ASCII characters must be converted to UTF-8, then percent-encoded. For example, the character "ü" (U+00FC) in UTF-8 is encoded as %C3%BC.

```
Original: http://example.com/ümlaut
Encoded:  http://example.com/%C3%BCmlaut
```

**Security and Privacy Implications**:

Character encoding affects security in several ways:

- Improper decoding can lead to security vulnerabilities
- Multiple encodings of the same character may bypass security filters
- Sensitive information in userinfo components is visible in plain text
- Fragment identifiers are not sent to servers but are processed by clients

The specification recommends against including sensitive information in URIs and encourages the use of HTTPS for protection during transmission.

**Implementation Requirements**:

Systems implementing URI processing must:

- Accept percent-encoded octets for characters even when the unencoded character would be valid
- Produce normalized URIs when generating new URIs
- Preserve character encoding in components where it affects resource identification
- Handle internationalized domain names according to relevant standards (Punycode/IDNA)

The character encoding rules ensure interoperability across diverse systems while maintaining the ability to represent resources with complex naming schemes. Proper encoding prevents parsing errors, security vulnerabilities, and ensures consistent resource identification across different platforms and applications.

---

