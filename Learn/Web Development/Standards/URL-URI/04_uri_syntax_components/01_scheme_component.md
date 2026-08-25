## Scheme Component


The scheme component identifies the protocol or naming system used to interpret the resource identifier. It appears at the beginning of the URI and is case-insensitive, though lowercase is conventional.

**Syntax Structure:**

```
scheme = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
```

The scheme consists of a sequence starting with a letter, followed by any combination of letters, digits, plus (+), hyphen (-), or period (.). The scheme is terminated by a colon (:).

**Common Scheme Examples:**

- `http` and `https` for web resources
- `ftp` for file transfer protocol
- `mailto` for email addresses
- `file` for local file system access
- `data` for inline data
- `tel` for telephone numbers
- `urn` for uniform resource names
- `ws` and `wss` for WebSocket connections

**Scheme Registration:**

Schemes are registered with IANA (Internet Assigned Numbers Authority). Registered schemes follow standardized specifications, while provisional or private schemes may be used for specific applications. The scheme determines how the remainder of the URI is parsed and interpreted.

**Case Sensitivity:**

While schemes themselves are case-insensitive per RFC 3986, the interpretation of the rest of the URI depends on the scheme specification. Normalizing schemes to lowercase is standard practice.

