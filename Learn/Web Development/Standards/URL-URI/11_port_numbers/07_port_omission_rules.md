## Port Omission Rules


URI specifications define when ports can be omitted from the authority component. Port omission follows scheme-specific default port conventions.

### Default Ports by Scheme

Each URI scheme defines a default port used when none is specified:

```
http://example.com/path           → Port 80 implied
https://example.com/path          → Port 443 implied
ftp://example.com/file            → Port 21 implied (control)
ssh://example.com                 → Port 22 implied
telnet://example.com              → Port 23 implied
smtp://mail.example.com           → Port 25 implied
dns://ns.example.com              → Port 53 implied
ws://example.com/socket           → Port 80 implied
wss://example.com/socket          → Port 443 implied
```

### Explicit Default Port Specification

Including the default port explicitly is syntactically valid but semantically equivalent to omission:

```
http://example.com:80/path        (explicit default)
http://example.com/path           (implicit default)
    → Both refer to identical resource
```

### Canonical URI Form

URI normalization for comparison or canonicalization typically removes explicit default ports:

**Before Normalization:**

```
https://example.com:443/path?query
http://example.com:80/
ftp://example.com:21/file
```

**After Normalization:**

```
https://example.com/path?query
http://example.com/
ftp://example.com/file
```

This normalization enables proper URI comparison and deduplication. Two URIs differing only in explicit versus implicit default ports are equivalent.

### URI Comparison with Ports

When comparing URIs, port handling follows these rules:

```
Same URIs:
    http://example.com/path
    http://example.com:80/path

Different URIs:
    http://example.com:8080/path
    http://example.com/path

Different URIs:
    https://example.com/path       (port 443)
    http://example.com/path        (port 80)
```

Scheme changes imply different default ports, making the URIs distinct even with identical hosts and paths.

### Empty Port Specification

A colon followed by no port number is syntactically valid but has ambiguous interpretation:

```
http://example.com:/path
```

**Possible Interpretations:**

1. Treat as default port (most common implementation)
2. Treat as error/invalid URI
3. Treat as distinct from default port

[Inference] Different URI parsers may handle this differently, so it should be avoided in production URIs.

### Port in Relative References

Relative URI references that include authority must specify the entire authority component:

```
Base URI: http://example.com:8080/app/page

Relative Reference: //other.com/path
    Resolves to: http://other.com:80/path
    (Uses default port for scheme, not base URI port)

Relative Reference: //other.com:9000/path
    Resolves to: http://other.com:9000/path
```

Relative references do not inherit the port from the base URI when specifying a different authority.

