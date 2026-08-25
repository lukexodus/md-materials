## Case Sensitivity in Schemes


Case sensitivity varies across different URI components, with specific rules governing scheme names, host names, paths, and other elements. Proper handling of case prevents broken links and ensures correct resource identification.

### Scheme Name Case Rules

According to RFC 3986, scheme names are **case-insensitive**. All three representations below are equivalent:

```
HTTP://example.com/path
http://example.com/path
HtTp://example.com/path
```

**Normalization**: The specification recommends normalizing scheme names to lowercase for consistency. Parsers must treat schemes case-insensitively, but producers should emit lowercase schemes.

**Implementation**:

```javascript
// Both are valid and equivalent
new URL('HTTP://example.com')
new URL('http://example.com')
// Both resolve to: http://example.com/
```

**Historical Context**: Early URI specifications allowed mixed case, but lowercase became the universal convention. Modern systems convert schemes to lowercase during normalization.

### Authority Component Case Sensitivity

The authority component has mixed case sensitivity rules:

**Host Names (Domain Names)**: Case-insensitive according to DNS specifications (RFC 1034, RFC 1035). These are equivalent:

```
http://EXAMPLE.COM/path
http://example.com/path
http://ExAmPlE.cOm/path
```

DNS resolution treats all domain names case-insensitively. Normalization converts hostnames to lowercase.

**IP Addresses**: Case-insensitive for hexadecimal characters in IPv6 addresses:

```
http://[2001:DB8::1]/path
http://[2001:db8::1]/path
```

IPv4 addresses contain only digits and dots (no case consideration).

**Userinfo (Username/Password)**: Case-sensitivity depends on the authentication system. The URI specification treats userinfo as case-sensitive, but individual systems may differ:

```
http://User:Pass@example.com/    // May differ from:
http://user:pass@example.com/
```

[Inference: Most modern authentication systems treat usernames case-insensitively for usability, but passwords are typically case-sensitive for security.]

**Port Numbers**: Only digits, no case consideration.

**Normalization**: Convert hostnames and IPv6 addresses to lowercase; preserve userinfo case unless system-specific knowledge indicates otherwise.

### Path Component Case Sensitivity

Path case sensitivity is **server-dependent** and varies by operating system and server configuration.

**Unix/Linux Servers**: Paths are case-sensitive by default:

```
http://example.com/Path/File.txt    // Different from:
http://example.com/path/file.txt
```

These URLs reference different resources on Unix systems. Requesting the wrong case results in 404 errors.

**Windows Servers**: Often case-insensitive (but case-preserving):

```
http://example.com/Path/File.txt    // Same as:
http://example.com/path/file.txt
```

Both URLs typically retrieve the same resource, though the file system stores the original case.

**macOS Servers**: Default HFS+ and APFS file systems are case-insensitive but case-preserving, similar to Windows.

**Best Practices**:

- Treat paths as case-sensitive in development to ensure cross-platform compatibility
- Use consistent casing (typically lowercase) for paths
- Configure URL rewriting or redirects to normalize case variations
- Test on case-sensitive systems even if deploying to case-insensitive environments

**Example of Case-Sensitive Path Issue**:

```
// Link in HTML
<a href="/products/category">Products</a>

// Actual file path on server
/Products/Category

// Result: 404 on case-sensitive systems
```

### Query Component Case Sensitivity

Query parameters are **case-sensitive** according to URI specifications, but interpretation depends on the application:

**Parameter Names**: Generally case-sensitive:

```
http://example.com/search?Query=test     // Different from:
http://example.com/search?query=test
```

Server applications decide whether to treat parameter names case-sensitively.

**Parameter Values**: Always case-sensitive:

```
http://example.com/search?query=Test     // Different from:
http://example.com/search?query=test
```

Search for "Test" vs "test" produces different results if search is case-sensitive.

**Common Convention**: Many web applications treat parameter names case-insensitively for usability but preserve value case sensitivity. Database queries and filters typically respect value case.

**Example**:

```
// E-commerce site may treat these the same:
?Category=Electronics
?category=electronics

// But these search for different products:
?product=iPhone
?product=iphone
```

### Fragment Identifier Case Sensitivity

Fragment identifiers are **case-sensitive** according to RFC 3986, but interpretation depends on the document format:

**HTML IDs**: Case-sensitive in HTML5:

```html
<div id="Section"></div>

<!-- This will not match: -->
<a href="#section">Link</a>

<!-- This will match: -->
<a href="#Section">Link</a>
```

**XML IDs**: Always case-sensitive.

**Plain Text**: No standard interpretation; case-sensitivity depends on viewer implementation.

**Best Practice**: Use consistent casing for fragment identifiers and matching element IDs to avoid broken anchors.

### Percent-Encoded Characters

Hexadecimal digits in percent-encoding are case-insensitive:

```
http://example.com/path%2Fto    // Same as:
http://example.com/path%2fto
```

Both represent the same character (`/`). Normalization converts hex digits to uppercase.

**Normalization Example**:

```
Original:  http://example.com/path%2fto
Normalized: http://example.com/path%2Fto
```

However, different percent-encoded representations of case-sensitive characters are distinct:

```
http://example.com/Path    // Different from:
http://example.com/path    // Which differs from:
http://example.com/%50ath  // (where %50 = 'P')
```

The last two are equivalent after decoding, but differ from the first on case-sensitive systems.

### Scheme-Specific Case Rules

Some schemes define additional case sensitivity rules:

**HTTP/HTTPS**: Recommends case-sensitive paths but case-insensitive hostnames. Query and fragment case sensitivity determined by application.

**File Scheme**: Case sensitivity follows underlying file system (Unix: sensitive, Windows/macOS: insensitive).

**Mailto**: Email addresses in the local part (before `@`) may be case-sensitive depending on mail server, though most treat them insensitively. Domain part is always case-insensitive.

**Data Scheme**: Media type is case-insensitive; data payload case sensitivity depends on type.

**URN**: Case sensitivity specified by individual namespace definitions. Some namespaces (like ISBN) are case-insensitive, others require exact case matching.

### URI Comparison and Equivalence

RFC 3986 defines comparison algorithms that account for case sensitivity:

**Simple String Comparison**: Fastest but catches only identical URIs:

```
http://Example.com/path ≠ http://example.com/path
```

**Syntax-Based Normalization**: Applies case normalization rules:

1. Lowercase scheme and hostname
2. Uppercase percent-encoding hex digits
3. Decode unnecessary percent-encoded characters
4. Remove default ports

After normalization:

```
HTTP://Example.com:80/Path%2fto%2Fresource%7e
Becomes:
http://example.com/Path/to/resource~
```

**Scheme-Based Normalization**: Applies scheme-specific rules (removing default ports, normalizing paths).

**Protocol-Based Normalization**: Requires understanding server behavior (path case sensitivity, redirects, content negotiation).

### Case Sensitivity Security Implications

Case sensitivity mismatches can create security vulnerabilities:

**Access Control Bypass**: If access controls use case-sensitive matching but the server is case-insensitive:

```
// Blocked by security rule
/admin/delete

// Might bypass rule if comparison is case-sensitive
/Admin/delete
```

**Cache Poisoning**: Case variations might create separate cache entries for the same resource, potentially serving malicious content.

**Duplicate Content**: Search engines may treat case variants as different URLs, diluting SEO value.

**Best Security Practice**: Normalize URLs at application entry points, treating path components consistently regardless of server file system case sensitivity.

### Practical Recommendations

**For URI Producers** (applications generating URIs):

- Always emit lowercase schemes and hostnames
- Use consistent path casing (preferably lowercase)
- Document whether your API treats parameters case-sensitively
- Normalize URIs before storing or comparing

**For URI Consumers** (applications parsing URIs):

- Treat schemes and hostnames case-insensitively
- Preserve original case for paths, queries, and fragments unless you have specific knowledge about the target system
- Implement normalization for comparison operations
- Consider security implications of case sensitivity in access control

**For Web Developers**:

- Use lowercase for all URI components when possible
- Test on case-sensitive systems (Linux/Unix)
- Implement canonical URLs with proper redirects
- Configure servers to handle case variations appropriately (301 redirects to canonical form)

**Key Points**: Case sensitivity in URIs is not uniform—schemes and hostnames are case-insensitive, while paths, queries, and fragments are case-sensitive by specification but may be treated differently by specific servers or applications. Understanding these distinctions prevents broken links, security issues, and integration problems.

