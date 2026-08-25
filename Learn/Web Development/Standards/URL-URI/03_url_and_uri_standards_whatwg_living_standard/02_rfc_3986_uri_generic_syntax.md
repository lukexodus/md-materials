## RFC 3986: URI Generic Syntax


RFC 3986 represents the IETF's authoritative specification for URI syntax. This standard provides a rigorous, formal grammar for constructing and parsing URIs.

### URI Components Structure

The generic URI syntax follows this pattern:

```
URI = scheme:[//authority]path[?query][#fragment]
authority = [userinfo@]host[:port]
```

### Scheme Component

The scheme defines the protocol or namespace being used. It must begin with a letter and contain only letters, digits, plus (+), period (.), or hyphen (-).

**Example:**

```
http:
https:
ftp:
mailto:
file:
data:
```

### Authority Component

The authority component identifies the governing namespace and typically contains the host, optional port, and optional user information.

**Host formats:**

- DNS names: `example.com`, `subdomain.example.org`
- IPv4 addresses: `192.168.1.1`
- IPv6 addresses: `[2001:db8::1]`
- Registered names: any sequence of allowed characters

**Port specification:**

```
http://example.com:8080/path
```

**User information** (deprecated for security reasons):

```
ftp://user:password@ftp.example.com/file.txt
```

### Path Component

The path identifies a resource within the scope of the authority. It consists of segments separated by forward slashes.

**Path types:**

- Absolute path: begins with `/`
- Relative path: does not begin with `/`
- Empty path: valid in some schemes

**Example:**

```
/catalog/products/item123
/docs/api/v2/reference.html
```

### Query Component

The query component provides non-hierarchical data, typically key-value pairs. It begins with a question mark (?).

**Example:**

```
?category=electronics&sort=price&order=asc
?q=search+term&page=2
```

### Fragment Component

The fragment identifies a secondary resource or a portion of the primary resource. It begins with a hash (#) and is not sent to the server.

**Example:**

```
#section-3
#introduction
```

### Percent-Encoding

RFC 3986 defines percent-encoding (URL encoding) for representing characters outside the allowed set. Characters are encoded as `%` followed by two hexadecimal digits.

**Reserved characters:**

```
: / ? # [ ] @ ! $ & ' ( ) * + , ; =
```

**Unreserved characters** (no encoding needed):

```
A-Z a-z 0-9 - . _ ~
```

**Example:**

```
Original: /search?q=hello world
Encoded:  /search?q=hello%20world

Original: /user@email/profile
Encoded:  /user%40email/profile
```

### URI Normalization

RFC 3986 defines several normalization techniques to determine URI equivalence:

**Syntax-based normalization:**

- Case normalization for scheme and host
- Percent-encoding normalization
- Path segment normalization (removing `.` and `..`)

**Example:**

```
http://example.com:80/a/b/../c/./d
Normalized: http://example.com/a/c/d
```

### Relative References

RFC 3986 provides algorithms for resolving relative references against a base URI.

**Relative reference types:**

- Network-path reference: `//example.com/path`
- Absolute-path reference: `/path/to/resource`
- Relative-path reference: `../other/resource`
- Empty reference: references the base URI
- Fragment-only reference: `#fragment`

**Resolution example:**

```
Base: http://example.com/a/b/c
Relative: ../d/e
Result: http://example.com/a/d/e
```

