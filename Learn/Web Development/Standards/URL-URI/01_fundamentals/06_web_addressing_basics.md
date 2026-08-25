## Web Addressing Basics


### URL Structure

A complete URL consists of several components that follow a standardized syntax:

```
scheme://username:password@host:port/path?query#fragment
```

**Scheme**: Defines the protocol for accessing the resource (http, https, ftp, mailto, file, data). The scheme is followed by a colon and usually two forward slashes. Different schemes have different rules for the remaining components.

**Authority Component** (optional, follows `//`):

- **Userinfo** (optional): Username and optionally password, separated by colon, followed by `@` symbol
- **Host**: Domain name (example.com) or IP address (192.168.1.1 or [2001:db8::1] for IPv6)
- **Port** (optional): Numeric value preceded by colon, indicates the network port for connection. Default ports are assumed when omitted (80 for HTTP, 443 for HTTPS)

**Path**: Hierarchical structure identifying the resource within the host, uses forward slashes as separators. Can be absolute (starting with /) or relative. An empty path is equivalent to a single forward slash.

**Query** (optional): Begins with `?`, contains key-value pairs typically formatted as `key=value`, separated by `&` or `;`. Used to pass parameters to the resource.

**Fragment** (optional): Begins with `#`, identifies a specific portion within the resource. Not sent to the server but processed by the client (browser).

### Character Encoding

URLs can only contain a limited set of ASCII characters. Characters outside this set must be percent-encoded using the format `%XX` where XX is the hexadecimal value of the character's byte in UTF-8.

Reserved characters that have special meaning in URLs:

```
: / ? # [ ] @ ! $ & ' ( ) * + , ; =
```

When these characters need to appear as data (not as delimiters), they must be percent-encoded. For example, a space becomes `%20` or `+` in query strings, and `#` becomes `%23`.

Unreserved characters (never need encoding):

```
A-Z a-z 0-9 - . _ ~
```

### URL Types

**Absolute URLs**: Contain all components needed to locate a resource from any context:

```
https://www.example.com:443/path/to/resource?key=value#section
```

**Relative URLs**: Defined in relation to a base URL, lacking scheme and often authority:

```
/path/to/resource          (absolute path, relative to host)
resource                   (relative to current directory)
../resource                (relative to parent directory)
?key=value                 (relative to current path, new query)
#section                   (relative to current URL, new fragment)
```

**Protocol-Relative URLs**: Omit the scheme, inheriting it from the current page:

```
//example.com/resource
```

### Common URL Schemes

**http/https**: Web resources using Hypertext Transfer Protocol (Secure)

```
https://example.com/page.html
```

**ftp**: File Transfer Protocol resources

```
ftp://ftp.example.com/files/document.pdf
```

**mailto**: Email addresses

```
mailto:user@example.com?subject=Hello&body=Message
```

**file**: Local file system resources

```
file:///C:/Users/Documents/file.txt
```

**data**: Inline data embedded directly in the URL

```
data:text/html,<h1>Hello</h1>
data:image/png;base64,iVBORw0KG...
```

**tel**: Telephone numbers

```
tel:+1-234-567-8900
```

**javascript**: JavaScript code to execute

```
javascript:void(0)
javascript:alert('Hello')
```

