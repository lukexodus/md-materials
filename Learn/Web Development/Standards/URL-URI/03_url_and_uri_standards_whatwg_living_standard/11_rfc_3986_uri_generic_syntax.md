## RFC 3986: URI Generic Syntax


RFC 3986, published in 2005, is the foundational standard for URI syntax. It obsoleted RFC 2396 and provides comprehensive rules for URI structure and parsing.

### Scheme Component

The scheme defines the protocol or namespace for the URI. It must begin with a letter and can contain letters, digits, plus (+), period (.), or hyphen (-). The scheme is case-insensitive but conventionally written in lowercase.

Common schemes include http, https, ftp, mailto, file, data, and tel.

### Authority Component

The authority component identifies the governing entity for the resource's namespace. It consists of optional user information, a host (domain name or IP address), and optional port number.

User information is deprecated for security reasons in most modern contexts. The host can be a registered domain name, IPv4 address, or IPv6 address enclosed in brackets. The port number, if present, specifies the TCP/UDP port for connection.

**Example:**

```
https://user:password@www.example.com:8080/path/to/resource
```

- Scheme: https
- User info: user:password (deprecated practice)
- Host: www.example.com
- Port: 8080
- Path: /path/to/resource

### Path Component

The path identifies the specific resource within the scope of the scheme and authority. It consists of a sequence of path segments separated by forward slashes (/). Paths can be absolute (starting with /) or relative (not starting with /).

Path segments can contain unreserved characters (letters, digits, hyphen, period, underscore, tilde) and percent-encoded characters for special or reserved characters.

### Query Component

The query component provides non-hierarchical data, typically as key-value pairs. It begins with a question mark (?) and commonly uses ampersand (&) to separate multiple parameters, though this is a convention rather than a requirement of RFC 3986.

Query parameters enable passing data to the resource, such as search terms, filters, or configuration options.

### Fragment Component

The fragment identifier, preceded by a hash (#), refers to a secondary resource or specific portion within the primary resource. Fragments are processed client-side and are not sent to the server in HTTP requests.

Fragments commonly reference specific sections within documents, timestamps in media files, or application states in single-page applications.

