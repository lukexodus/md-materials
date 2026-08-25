## Default Ports (80, 443)


Port numbers identify specific network services on a host. HTTP and HTTPS have well-known default ports registered with the Internet Assigned Numbers Authority (IANA).

**HTTP Default Port: 80**

Port 80 is the standard port for HTTP communication. When a URI uses the http:// scheme without specifying a port number, clients automatically connect to port 80.

**Explicit vs. Implicit Port Specification**:

```
http://example.com          → Connects to port 80 (implicit)
http://example.com:80       → Connects to port 80 (explicit)
http://example.com:8080     → Connects to port 8080 (non-standard)
```

These URIs are functionally equivalent for default ports:

- `http://example.com/path`
- `http://example.com:80/path`

However, for URI comparison and normalization purposes, the explicit port specification should be removed when it matches the scheme's default.

**Common Non-Standard HTTP Ports**:

While port 80 is standard, HTTP servers frequently use alternative ports:

- 8080: Common alternative HTTP port for development and testing
- 8000: Often used for development servers
- 3000: Frequently used by Node.js applications
- 8008: Alternative HTTP port
- 8888: Another common development port

**HTTPS Default Port: 443**

Port 443 is the standard port for HTTPS communication. When a URI uses the https:// scheme without specifying a port number, clients automatically connect to port 443.

**Explicit vs. Implicit Port Specification**:

```
https://example.com         → Connects to port 443 (implicit)
https://example.com:443     → Connects to port 443 (explicit)
https://example.com:8443    → Connects to port 8443 (non-standard)
```

**Common Non-Standard HTTPS Ports**:

- 8443: Common alternative HTTPS port for development and administrative interfaces
- 4443: Sometimes used for HTTPS services
- 9443: Used by various applications for secure communication

**Port Number Constraints**:

- Valid range: 0-65535
- Well-known ports: 0-1023 (typically require administrative privileges)
- Registered ports: 1024-49151 (registered with IANA for specific services)
- Dynamic/private ports: 49152-65535 (available for temporary use)

**Normalization Rules**:

According to RFC 3986, URIs that explicitly specify the default port should be normalized by removing the port component:

```
Normalized:   http://example.com/path
Non-normalized: http://example.com:80/path

Normalized:   https://example.com/path
Non-normalized: https://example.com:443/path
```

**Firewall and Network Considerations**:

[Inference based on common network architecture] Default ports 80 and 443 are typically allowed through corporate firewalls and network security appliances, while non-standard ports may be blocked. This makes default ports more reliable for public-facing services.

