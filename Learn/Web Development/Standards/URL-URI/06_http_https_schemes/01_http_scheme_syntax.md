## http:// Scheme Syntax


The http:// scheme follows the generic URI syntax defined in RFC 3986, with specific conventions established in RFC 7230 and related HTTP specifications. The scheme identifier "http" is case-insensitive but conventionally written in lowercase.

**Complete Syntax Structure**:

```
http://[userinfo@]host[:port][/path][?query][#fragment]
```

**Component Breakdown**:

**Scheme**: The literal string "http" followed by a colon and double slash (http://)

**Userinfo**: [Unverified - rarely used in modern practice] An optional component containing username and optionally password, separated by a colon and followed by an @ symbol. This component is deprecated for security reasons as credentials are transmitted in plain text.

```
http://username:password@example.com/resource
```

**Host**: The domain name or IP address of the server hosting the resource. This component is mandatory.

Valid host formats:

- Domain name: `http://www.example.com`
- IPv4 address: `http://192.168.1.1`
- IPv6 address (enclosed in brackets): `http://[2001:db8::1]`

**Port**: An optional port number following the host, separated by a colon. When omitted, the default port for HTTP is used.

**Path**: The hierarchical path to the resource on the server. An empty path is equivalent to "/".

```
http://example.com/products/electronics/laptops
```

**Query**: Optional parameters following a question mark, typically formatted as key-value pairs separated by ampersands.

```
http://example.com/search?q=laptops&category=electronics&sort=price
```

**Fragment**: An optional identifier following a hash symbol, used to reference a specific section within the resource. The fragment is processed by the client and not sent to the server.

```
http://example.com/documentation#installation
```

**Examples of Valid HTTP URIs**:

```
http://example.com
http://example.com:8080
http://example.com/
http://example.com/path/to/resource
http://subdomain.example.com/resource?param=value
http://192.168.1.100:3000/api/users
http://[2001:db8::1]/index.html
```

**Character Encoding in HTTP URIs**:

All characters in HTTP URIs must be from the ASCII character set. Non-ASCII characters and reserved characters used literally must be percent-encoded:

```
http://example.com/search?q=caf%C3%A9
http://example.com/path%20with%20spaces
```

