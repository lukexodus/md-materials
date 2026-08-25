## URI Normalization


Normalization is the process of converting URIs to a canonical form for comparison purposes. RFC 3986 defines several normalization techniques:

### Case Normalization

- **Scheme and host**: Case-insensitive, should be normalized to lowercase
- **Path**: Case-sensitive in most schemes

**Example:**

```
HTTP://Example.COM/Path  →  http://example.com/Path
```

### Percent-Encoding Normalization

- Decode unreserved characters that are percent-encoded
- Uppercase hexadecimal digits in percent-encoding

**Example:**

```
http://example.com/%7Euser  →  http://example.com/~user
http://example.com/%2d      →  http://example.com/-
http://example.com/%2a      →  http://example.com/%2A
```

### Path Segment Normalization

- Remove dot-segments (`.` and `..`)
- Remove empty path segments

**Example:**

```
http://example.com/a/b/../c/./d  →  http://example.com/a/c/d
http://example.com//path         →  http://example.com/path
```

### Default Port Removal

Remove default ports for common schemes:

- HTTP: port 80
- HTTPS: port 443
- FTP: port 21

**Example:**

```
http://example.com:80/path  →  http://example.com/path
https://example.com:443/    →  https://example.com/
```

### Empty Path Normalization

An empty path should be normalized to `/` for HTTP(S) URIs.

**Example:**

```
http://example.com  →  http://example.com/
```

