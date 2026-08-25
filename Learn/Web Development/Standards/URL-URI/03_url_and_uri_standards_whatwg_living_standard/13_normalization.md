## Normalization


URI normalization is the process of converting URIs into a consistent, canonical form for comparison. Different URI strings can refer to the same resource, making normalization essential for caching, deduplication, and security.

### Syntax-Based Normalization

Syntax-based normalization applies transformations that are guaranteed to preserve semantic equivalence according to URI syntax rules.

Case normalization converts scheme and host to lowercase, as these components are case-insensitive. Percent-encoding normalization uppercases hexadecimal digits in percent-encoded triplets and decodes unreserved characters that are unnecessarily encoded.

Path segment normalization removes dot segments (. and ..) according to the algorithm specified in RFC 3986. This resolves relative references and removes redundant navigation.

**Example:**

```
Before: HTTP://Example.COM:80/path/../other/./file.html
After: http://example.com/other/file.html
```

### Scheme-Based Normalization

Scheme-based normalization applies rules specific to particular URI schemes. For HTTP and HTTPS, this includes removing default ports (80 for HTTP, 443 for HTTPS) and ensuring absolute paths start with a slash.

Empty path components can be replaced with "/" for HTTP(S) URIs. Query and fragment components may undergo scheme-specific normalization based on their semantics.

### Protocol-Based Normalization

Protocol-based normalization requires protocol-level knowledge and may involve network access. This includes resolving directory indexes, removing duplicate slashes, and handling case-insensitive file systems.

This level of normalization is less deterministic and may change resource identity in some cases.

