## Common Schemes


### HTTP and HTTPS

**http (Hypertext Transfer Protocol)** is the foundational scheme for the World Wide Web, defined in RFC 7230. It specifies unencrypted transmission of web content between clients and servers over TCP/IP networks.

**https (HTTP Secure)** extends HTTP with encryption using TLS (Transport Layer Security), defined in RFC 2818. It provides confidentiality, integrity, and authentication for web communications.

**Syntax:**

```
http://host[:port]/path[?query][#fragment]
https://host[:port]/path[?query][#fragment]

Examples:
http://example.com/page.html
https://secure.example.com:443/login
https://example.com/search?q=term&limit=10
https://example.com/article#section-2
```

**Components:**

- **host**: Domain name or IP address (required)
- **port**: Optional (default 80 for HTTP, 443 for HTTPS)
- **path**: Hierarchical resource location
- **query**: Key-value parameters following "?"
- **fragment**: Reference to document section following "#"

HTTPS has become the standard for web traffic. Modern browsers mark HTTP sites as "not secure," and many services require HTTPS for security-sensitive operations.

### FTP

**ftp (File Transfer Protocol)** enables file transfer between clients and servers, defined in RFC 1738. It supports directory navigation, file upload/download, and basic file management operations.

**Syntax:**

```
ftp://[user[:password]@]host[:port]/path

Examples:
ftp://ftp.example.com/pub/files/
ftp://user:pass@ftp.example.com/private/document.pdf
ftp://ftp.example.com:2121/archive/
```

FTP URLs may include authentication credentials, though this practice is discouraged for security reasons. Anonymous FTP access typically uses "anonymous" as the username.

Modern usage has declined in favor of HTTPS, SFTP (SSH File Transfer Protocol), and cloud storage APIs. Many browsers have deprecated or removed FTP support.

### FILE

**file** accesses resources on local filesystems, defined in RFC 8089. It references files and directories on the local machine or network-accessible file shares.

**Syntax:**

```
file://[host]/path
file:///path (localhost implied)

Examples:
file:///home/user/documents/report.pdf
file:///C:/Users/Admin/Desktop/image.jpg
file://server.local/share/file.txt
```

The file scheme typically uses three slashes (///) for local files on Unix-like systems, where the empty host component represents localhost. Windows paths require special handling for drive letters.

**Key Points:**

- Limited to local or network filesystem access
- No standardized authentication or encryption
- Browser support varies due to security concerns
- Path syntax depends on operating system conventions

### MAILTO

**mailto** initiates email composition, defined in RFC 6068. It specifies recipient addresses and optionally includes subject, body, and other email headers.

**Syntax:**

```
mailto:address[@host][?headers]

Examples:
mailto:user@example.com
mailto:support@example.com?subject=Help%20Request
mailto:contact@example.com?subject=Inquiry&body=Message%20text
mailto:sales@example.com?cc=manager@example.com&bcc=archive@example.com
```

The scheme triggers the user's default email client with pre-populated fields. Multiple recipients can be specified using comma separation.

### TEL and SMS

**tel** identifies telephone numbers according to RFC 3966, using the E.164 international format.

**sms** initiates SMS text messaging, similar to mailto for email.

**Syntax:**

```
tel:+1-555-123-4567
tel:+442071234567
sms:+1-555-123-4567?body=Message%20text

Examples:
tel:+1-800-555-0199
sms:+447700900123
```

### DATA

**data** embeds small data items inline within URIs, defined in RFC 2397. It encodes content directly rather than referencing external resources.

**Syntax:**

```
data:[mediatype][;base64],data

Examples:
data:text/plain;charset=utf-8,Hello%20World
data:text/html,<h1>Title</h1>
data:image/png;base64,iVBORw0KGgoAAAANS...
```

Data URIs are useful for embedding images, stylesheets, or scripts within HTML/CSS, reducing HTTP requests. However, they increase document size and cannot be cached separately.

### URN

**urn (Uniform Resource Name)** provides persistent, location-independent identifiers, defined in RFC 8141. URNs use namespace identifiers (NID) to organize naming systems.

**Syntax:**

```
urn:nid:nss

Examples:
urn:isbn:978-0-123456-78-9
urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66
urn:ietf:rfc:3986
urn:doi:10.1000/182
```

Common URN namespaces include ISBN (books), UUID (universally unique identifiers), DOI (digital object identifiers), and ISSN (serial publications).

### Additional Common Schemes

**javascript** executes JavaScript code when activated, primarily in web browsers.

```
javascript:alert('Hello')
javascript:void(0)
```

**ws/wss** (WebSocket/WebSocket Secure) enable bidirectional communication channels over TCP.

```
ws://example.com/socket
wss://example.com/socket
```

**magnet** specifies resources available through peer-to-peer file sharing networks.

```
magnet:?xt=urn:btih:hash&dn=name
```

**Key Points:**

- HTTP/HTTPS dominate web traffic (70%+ of all URIs)
- HTTPS is now standard practice for security
- FTP usage has significantly declined
- Specialized schemes serve specific application domains
- Mobile platforms introduced app-specific URI schemes

Different schemes serve distinct purposes in the internet ecosystem, enabling diverse resource types and access methods within the unified URI framework.

