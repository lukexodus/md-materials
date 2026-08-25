## Differences Between RFC 3986 and WHATWG URL Standard


While both standards describe URLs, they serve different purposes and have notable differences in scope, precision, and handling of edge cases.

### Philosophical Approach

RFC 3986 is a generic specification for all URIs, not just URLs used on the web. It provides a framework that URI schemes can build upon. The WHATWG URL Standard is specifically designed for web URLs and describes actual browser behavior.

RFC 3986 leaves many details to scheme-specific specifications, while WHATWG provides complete, deterministic parsing for web URLs.

### Parsing Precision

The WHATWG standard provides explicit state machine algorithms for parsing, while RFC 3986 uses regular expressions and prose descriptions that can be interpreted differently.

For ambiguous inputs, the WHATWG standard specifies exact behavior, while RFC 3986 may leave behavior undefined or implementation-dependent.

### Host Parsing

The WHATWG standard includes detailed rules for parsing and validating hostnames, including domain name validation, IPv4 address formats (including legacy formats), IPv6 address syntax, and percent-encoded hosts.

RFC 3986 provides basic syntax but leaves validation details to other specifications like DNS and IP address standards.

### Special URLs

The WHATWG standard defines special schemes (http, https, file, ftp, ws, wss) with specific parsing rules. RFC 3986 treats all schemes generically, leaving special handling to scheme-specific specifications.

### Relative URL Resolution

Both standards describe relative URL resolution, but the WHATWG standard provides more detailed algorithms that handle edge cases explicitly. The WHATWG approach is designed to match browser behavior precisely.

