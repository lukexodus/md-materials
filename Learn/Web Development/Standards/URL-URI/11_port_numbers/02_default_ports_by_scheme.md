## Default Ports by Scheme


### Concept of Default Ports

Default ports are standard port numbers associated with specific URI schemes. When a URI omits the port component, the default port for that scheme is assumed.

**Purpose:**

- Simplify URI syntax by omitting commonly-used ports
- Establish standard conventions for protocols
- Enable automatic connection to correct service

**Behavior:**

```
http://example.com/
// Implicitly: http://example.com:80/

https://example.com/
// Implicitly: https://example.com:443/
```

### Common Scheme Default Ports

**HTTP (Hypertext Transfer Protocol):**

```
Scheme: http://
Default port: 80
Example: http://example.com/ → connects to port 80
```

**HTTPS (HTTP Secure):**

```
Scheme: https://
Default port: 443
Example: https://example.com/ → connects to port 443
```

**FTP (File Transfer Protocol):**

```
Scheme: ftp://
Default port: 21 (control connection)
Note: FTP also uses port 20 for data transfer (active mode)
Example: ftp://ftp.example.com/ → connects to port 21
```

**FTPS (FTP Secure):**

```
Scheme: ftps://
Default port: 990 (implicit FTPS)
Note: Explicit FTPS uses port 21
```

**SSH (Secure Shell):**

```
Scheme: ssh://
Default port: 22
Example: ssh://user@example.com/ → connects to port 22
```

**Telnet:**

```
Scheme: telnet://
Default port: 23
Example: telnet://example.com/ → connects to port 23
```

**SMTP (Simple Mail Transfer Protocol):**

```
Scheme: smtp://
Default port: 25 (unencrypted)
Alternative ports: 587 (submission), 465 (SMTPS)
```

**DNS (Domain Name System):**

```
Scheme: dns://
Default port: 53
```

**LDAP (Lightweight Directory Access Protocol):**

```
Scheme: ldap://
Default port: 389
Example: ldap://directory.example.com/ → connects to port 389
```

**LDAPS (LDAP Secure):**

```
Scheme: ldaps://
Default port: 636
```

**WebSocket:**

```
Scheme: ws://
Default port: 80
Example: ws://example.com/socket → connects to port 80
```

**WebSocket Secure:**

```
Scheme: wss://
Default port: 443
Example: wss://example.com/socket → connects to port 443
```

**RTSP (Real Time Streaming Protocol):**

```
Scheme: rtsp://
Default port: 554
```

**SIP (Session Initiation Protocol):**

```
Scheme: sip://
Default port: 5060 (unencrypted)
Alternative: 5061 (encrypted SIPS)
```

**IRC (Internet Relay Chat):**

```
Scheme: irc://
Default port: 6667 (unencrypted)
Alternative: 6697 (SSL/TLS)
```

**MQTT (Message Queuing Telemetry Transport):**

```
Scheme: mqtt://
Default port: 1883 (unencrypted)
Alternative: 8883 (encrypted)
```

**Redis:**

```
Scheme: redis://
Default port: 6379
```

**PostgreSQL:**

```
Scheme: postgresql://
Default port: 5432
Example: postgresql://localhost/mydb → connects to port 5432
```

**MySQL:**

```
Scheme: mysql://
Default port: 3306
```

**MongoDB:**

```
Scheme: mongodb://
Default port: 27017
```

### Default Port Normalization

URLs specifying the default port explicitly should be normalized to omit it:

**HTTP examples:**

```
http://example.com:80/path
Normalized: http://example.com/path

http://example.com:80/
Normalized: http://example.com/
```

**HTTPS examples:**

```
https://example.com:443/api
Normalized: https://example.com/api
```

**Non-default ports remain:**

```
http://example.com:8080/
// Not normalized (8080 ≠ 80)

https://example.com:8443/
// Not normalized (8443 ≠ 443)
```

### Equivalence with Default Ports

For URI comparison, explicit default ports are equivalent to omitted ports:

**Equivalent URIs:**

```
http://example.com/path
http://example.com:80/path
// These are equivalent

https://example.com/api
https://example.com:443/api
// These are equivalent
```

**Not equivalent:**

```
http://example.com/path
http://example.com:8080/path
// Different ports (80 vs 8080)

http://example.com/path
https://example.com/path
// Different schemes (different default ports: 80 vs 443)
```

### WHATWG URL API Behavior

The WHATWG URL API automatically handles default ports:

**Port property returns empty string for defaults:**

```javascript
const url1 = new URL('http://example.com/');
console.log(url1.port);  // "" (empty, using default 80)

const url2 = new URL('http://example.com:80/');
console.log(url2.port);  // "" (empty, normalized)

const url3 = new URL('http://example.com:8080/');
console.log(url3.port);  // "8080" (non-default, preserved)
```

**Setting default port:**

```javascript
const url = new URL('http://example.com:8080/');
url.port = '80';  // Set to default
console.log(url.port);  // "" (empty)
console.log(url.href);  // "http://example.com/"
```

**Host property behavior:**

```javascript
const url1 = new URL('http://example.com:80/');
console.log(url1.host);      // "example.com" (no port)
console.log(url1.hostname);  // "example.com"

const url2 = new URL('http://example.com:8080/');
console.log(url2.host);      // "example.com:8080" (includes port)
console.log(url2.hostname);  // "example.com"
```

### Scheme-Specific Considerations

**File URLs:** The `file://` scheme typically doesn't use network ports as it accesses local filesystem:

```
file:///path/to/file
// No port concept for local files
```

**Data URLs:** The `data:` scheme embeds data directly and has no host or port:

```
data:text/plain;base64,SGVsbG8=
// No authority component
```

**Mailto URLs:** The `mailto:` scheme doesn't specify a port (SMTP client handles connection):

```
mailto:user@example.com
// No port in URI (SMTP uses port 25/587/465)
```

