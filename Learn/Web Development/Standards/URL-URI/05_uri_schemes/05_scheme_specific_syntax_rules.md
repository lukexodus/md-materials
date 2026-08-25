## Scheme-Specific Syntax Rules


URI schemes define how the remainder of the URI should be interpreted after the scheme name and colon. Each scheme has its own syntax rules, character restrictions, and semantic requirements defined in its specification.

### General Scheme Syntax Pattern

After the scheme name and colon, URIs follow one of several patterns:

**Hierarchical Schemes** (most common, use `//` after colon):

```
scheme://authority/path?query#fragment
```

**Non-Hierarchical Schemes** (no `//`, data immediately follows colon):

```
scheme:scheme-specific-part
```

The presence or absence of `//` significantly affects parsing. Hierarchical schemes separate authority from path, while non-hierarchical schemes interpret everything after the colon according to scheme-specific rules.

### HTTP and HTTPS Schemes

Defined in RFC 7230, these schemes follow the standard hierarchical structure with specific requirements:

```
http://host[:port]/path[?query][#fragment]
https://host[:port]/path[?query][#fragment]
```

**Syntax Rules**:

- Authority component is mandatory (must include host)
- Default ports: 80 for HTTP, 443 for HTTPS
- Path is optional; empty path is treated as `/`
- Query strings use `key=value` pairs separated by `&`
- Fragment identifies portion of retrieved resource
- All components except scheme are case-sensitive

**Character Encoding**:

- Percent-encoding required for reserved characters in path and query
- Space encoded as `%20` in path, can be `+` or `%20` in query
- Non-ASCII characters must be UTF-8 encoded then percent-encoded

**Example**:

```
https://user:pass@www.example.com:8443/products/item%2042?sort=price&color=blue#reviews
```

### FTP Scheme

Defined in RFC 1738, FTP URLs specify File Transfer Protocol resources:

```
ftp://[user[:password]@]host[:port]/path[;type=typecode]
```

**Syntax Rules**:

- Default port: 21
- Path represents directory structure on FTP server
- Leading `/` in path may indicate absolute path from root or relative to user's home directory (server-dependent)
- Type parameter specifies transfer mode:
    - `type=a`: ASCII text mode
    - `type=i`: Binary/image mode
    - `type=d`: Directory listing

**Example**:

```
ftp://anonymous:email@ftp.example.com/pub/files/document.pdf;type=i
```

[Inference: Modern browsers have deprecated or removed FTP support, though the scheme remains valid for specialized FTP clients and libraries.]

### Mailto Scheme

Defined in RFC 6068, mailto creates email message composition links:

```
mailto:address[,address]*[?header=value[&header=value]*]
```

**Syntax Rules**:

- One or more email addresses separated by commas
- No `//` after colon (non-hierarchical)
- Query parameters specify email headers (subject, body, cc, bcc)
- Header names are case-insensitive
- Values must be percent-encoded
- Line breaks in body represented as `%0D%0A` (CRLF)

**Supported Headers**:

- `subject`: Email subject line
- `body`: Message body text
- `cc`: Carbon copy recipients
- `bcc`: Blind carbon copy recipients
- `to`: Additional recipients (can also be in main address list)

**Example**:

```
mailto:user@example.com,other@example.com?subject=Hello%20World&body=This%20is%20a%20test&cc=copy@example.com
```

### File Scheme

Defined in RFC 8089, file URLs reference local or network-accessible files:

```
file://[host]/path
file:///path
```

**Syntax Rules**:

- Three slashes (`file:///`) indicate localhost
- Host can specify network server (UNC path on Windows)
- Path follows operating system conventions
- On Windows, drive letters appear as `/C:/path`
- On Unix-like systems, absolute paths begin with `/`

**Platform-Specific Examples**:

Windows local file:

```
file:///C:/Users/Documents/file.txt
```

Windows network share:

```
file://server/share/file.txt
```

Unix-like system:

```
file:///home/user/documents/file.txt
```

[Unverified: Browser implementations of file URLs vary significantly in their security restrictions and path handling, particularly regarding cross-origin access and directory listings.]

### Data Scheme

Defined in RFC 2397, data URLs embed data directly within the URI:

```
data:[mediatype][;base64],data
```

**Syntax Rules**:

- No `//` after colon (non-hierarchical)
- Default media type: `text/plain;charset=US-ASCII`
- Optional `;base64` parameter indicates base64 encoding
- Data component contains the actual content
- Comma separates metadata from data
- Percent-encoding applies to data component unless base64 is used

**Media Type Specification**:

- Full MIME type can be specified: `text/html`, `image/png`, `application/json`
- Parameters follow media type: `text/plain;charset=UTF-8`

**Examples**:

Plain text:

```
data:text/plain,Hello%20World
```

HTML content:

```
data:text/html,<h1>Title</h1><p>Content</p>
```

Base64-encoded image:

```
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA...
```

JSON data:

```
data:application/json,{"key":"value","number":42}
```

**Size Limitations**: [Unverified: While the specification doesn't impose length limits, browsers typically restrict data URLs to 2-10 MB depending on implementation, and some contexts (like CSS) may have stricter limits.]

### Tel Scheme

Defined in RFC 3966, tel URIs represent telephone numbers:

```
tel:phone-number[;parameter]*
```

**Syntax Rules**:

- No `//` after colon (non-hierarchical)
- Global numbers must start with `+` and country code
- Local numbers may omit `+` but require context
- Visual separators (hyphens, parentheses, spaces) are allowed but ignored
- Parameters separated by semicolons

**Format Examples**:

Global number:

```
tel:+1-234-567-8900
tel:+12345678900
```

Local number with context:

```
tel:555-0100;phone-context=+1-234
```

With extension:

```
tel:+1-234-567-8900;ext=123
```

**Parameters**:

- `phone-context`: Provides context for local numbers
- `ext`: Extension number
- `isub`: ISDN subaddress

### URN Scheme

Defined in RFC 8141, URNs provide persistent, location-independent identifiers:

```
urn:namespace:namespace-specific-string
```

**Syntax Rules**:

- Namespace identifier (NID) must be registered with IANA
- Namespace-specific string (NSS) follows rules defined by the namespace
- No `//` after colon (non-hierarchical)
- Case sensitivity depends on namespace specification
- Optional components for resolution, query, and fragment

**Common URN Namespaces**:

ISBN (books):

```
urn:isbn:0451450523
urn:isbn:978-0-451-45052-9
```

ISSN (serials):

```
urn:issn:1234-5678
```

UUID:

```
urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6
```

OID (Object Identifier):

```
urn:oid:1.2.3.4.5
```

**Extended Syntax**:

```
urn:namespace:nss?+resolution?=query#fragment
```

### JavaScript Scheme

Used in HTML to execute JavaScript code:

```
javascript:code
```

**Syntax Rules**:

- No `//` after colon (non-hierarchical)
- Code directly follows colon
- Percent-encoding not typically required but supported
- Return value of last expression used as document content if not `undefined`
- `void(0)` or `void 0` prevents navigation

**Examples**:

Alert dialog:

```
javascript:alert('Hello World');
```

No-operation (prevents default link action):

```
javascript:void(0);
```

Multiple statements:

```
javascript:(function(){var x=5;alert(x*2);})();
```

[Unverified: Many modern browsers restrict or block javascript: URLs in certain contexts due to security concerns, particularly in Content Security Policy (CSP) environments.]

### Magnet Scheme

Used for peer-to-peer file sharing, particularly with BitTorrent:

```
magnet:?xt=urn:btih:hash[&parameter]*
```

**Syntax Rules**:

- Query-like format immediately after `?`
- Multiple parameters separated by `&`
- No authority or path components
- Hash identifies content cryptographically

**Common Parameters**:

- `xt`: Exact topic (content hash)
- `dn`: Display name (filename)
- `tr`: Tracker URL (can be repeated)
- `as`: Acceptable source (web seed)
- `xs`: Exact source (direct download)
- `kt`: Keyword topic (search terms)

**Example**:

```
magnet:?xt=urn:btih:cdabcd1234567890abcdef&dn=filename.txt&tr=http://tracker.example.com:80/announce
```

### News and NNTP Schemes

Defined in RFC 5538, these schemes reference Usenet newsgroups and articles:

```
news:newsgroup-name
news:message-id
nntp://host[:port]/newsgroup-name[/article-number]
```

**Syntax Rules**:

News scheme (no authority):

```
news:comp.lang.python
news:<message-id@example.com>
```

NNTP scheme (with server):

```
nntp://news.example.com/comp.lang.python
nntp://news.example.com/comp.lang.python/12345
```

Message IDs enclosed in angle brackets in news URLs, but not in NNTP URLs.

### WebSocket Schemes

Defined in RFC 6455, ws and wss schemes establish WebSocket connections:

```
ws://host[:port]/path[?query]
wss://host[:port]/path[?query]
```

**Syntax Rules**:

- ws: unencrypted WebSocket (default port 80)
- wss: encrypted WebSocket over TLS (default port 443)
- No fragment component (fragments not sent in WebSocket handshake)
- Authority and path components follow HTTP rules
- Used in WebSocket constructor, not directly in HTML links

**Example**:

```
wss://example.com:9000/socket?token=abc123
```

### SSH and SFTP Schemes

Used for Secure Shell connections and file transfers:

```
ssh://[user@]host[:port]
sftp://[user@]host[:port]/path
```

**Syntax Rules**:

- Default port: 22 for both schemes
- User authentication credentials in authority
- Path in sftp indicates remote file location
- Not standardized in RFCs but widely implemented

**Examples**:

```
ssh://admin@server.example.com:2222
sftp://user@files.example.com/home/user/document.txt
```

### Git Scheme

Used for Git repository cloning and operations:

```
git://host[:port]/path
```

**Syntax Rules**:

- Default port: 9418
- Path indicates repository location on server
- No authentication support (unauthenticated protocol)
- Often replaced by git+ssh or https for authenticated access

**Examples**:

```
git://github.com/user/repository.git
git+ssh://git@github.com/user/repository.git
```

### Scheme Comparison Table

Different schemes balance human readability, machine parseability, and semantic meaning:

|Scheme|Hierarchical|Authority Required|Default Port|Primary Use|
|---|---|---|---|---|
|http/https|Yes|Yes|80/443|Web resources|
|ftp|Yes|Yes|21|File transfer|
|file|Yes|No (localhost)|N/A|Local files|
|mailto|No|No|N/A|Email composition|
|data|No|No|N/A|Inline data|
|tel|No|No|N/A|Phone numbers|
|urn|No|No|N/A|Persistent IDs|
|javascript|No|No|N/A|Code execution|
|ws/wss|Yes|Yes|80/443|WebSocket|

**Key Points**: Each scheme's syntax reflects its purpose—hierarchical schemes organize resources by location and path, while non-hierarchical schemes encode data or identifiers directly. Understanding scheme-specific rules is essential for proper URI construction, parsing, and validation.

