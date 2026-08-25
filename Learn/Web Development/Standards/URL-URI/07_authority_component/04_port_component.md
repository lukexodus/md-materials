## Port Component


The port subcomponent specifies the network port for connection. It appears after the host, separated by a colon.

### Syntax

```
port = *DIGIT
```

The port consists of zero or more decimal digits.

**Example:**

```
http://example.com:8080/
              └──port──┘
```

### Port Ranges

**Valid range:** 0-65535 (16-bit unsigned integer)

**Reserved ports:** 0-1023 (well-known ports, often require elevated privileges)

**Registered ports:** 1024-49151 (registered with IANA)

**Dynamic/private ports:** 49152-65535 (ephemeral ports)

**Example:**

```
http://example.com:80/      // Valid
http://example.com:8080/    // Valid
http://example.com:65535/   // Valid, maximum
http://example.com:65536/   // Invalid, exceeds range
```

### Default Ports

Each URI scheme defines a default port used when no port is specified.

**Common default ports:**

```
http://     → port 80
https://    → port 443
ftp://      → port 21
ssh://      → port 22
smtp://     → port 25
ws://       → port 80
wss://      → port 443
```

**Example:**

```
http://example.com/
// Equivalent to: http://example.com:80/

https://example.com/
// Equivalent to: https://example.com:443/
```

### Port Normalization

When a port matches the scheme's default, it should be omitted during normalization:

**Example:**

```
http://example.com:80/   → http://example.com/
https://example.com:443/ → https://example.com/
ftp://example.com:21/    → ftp://example.com/
```

**Non-default ports are preserved:**

```
http://example.com:8080/   // Not normalized
https://example.com:8443/  // Not normalized
```

### Empty Port

A colon without following digits represents an empty port:

```
http://example.com:/path
              └empty┘
```

**RFC 3986 behavior:** Empty port is syntactically valid.

**WHATWG behavior:** [Inference] Empty port typically treated as omitted, using default port.

**Example:**

```
http://example.com:/
// RFC 3986: Valid with empty port
// WHATWG: Treated as http://example.com/
```

### Port Parsing

**Algorithm:**

1. Locate the last colon in the authority
2. If colon precedes IPv6 brackets, it's part of the IPv6 address
3. Everything after the last colon (outside brackets) is the port
4. Parse as decimal integer
5. Validate range (0-65535)

**Example parsing:**

```
http://example.com:8080/path

1. Find last colon: position 18
2. No brackets involved
3. Port string: "8080"
4. Parse: 8080
5. Valid (0 ≤ 8080 ≤ 65535)
```

**IPv6 edge case:**

```
http://[2001:db8::1]:8080/

1. Find last colon: position 20 (after brackets)
2. Colon at position 7, 12, 15 are inside brackets
3. Port string: "8080"
4. Parse: 8080
5. Valid
```

### Leading Zeros in Ports

**RFC 3986:** Allows leading zeros, interprets as decimal

```
http://example.com:0080/  // Port 80
```

**Normalization:** Leading zeros should be removed

```
http://example.com:0080/ → http://example.com:80/
                         → http://example.com/  (default port)
```

**Note:** Unlike IPv4 addresses, ports are always interpreted as decimal, never octal, even with leading zeros.

### Port in Different Contexts

**Web browsers:**

```
http://example.com:8080/
https://localhost:3000/
```

**Database connections:**

```
postgresql://localhost:5432/mydb
mysql://host:3306/database
mongodb://localhost:27017/
```

**API endpoints:**

```
http://api.example.com:8080/v1/users
https://service.example.com:443/api  // Explicit default
```

**WebSocket connections:**

```
ws://example.com:8080/socket
wss://example.com:443/socket
```

### Port Security Considerations

**Privileged ports (0-1023):** On Unix-like systems, binding to these ports typically requires root privileges.

**Firewall rules:** Many networks restrict which ports can be accessed. Common allowed ports: 80, 443, 8080, 8443.

**Port scanning:** Exposing non-standard ports may invite port scanning attacks.

**Well-known port conflicts:** Using well-known ports for non-standard services can cause confusion:

```
http://example.com:22/  // HTTP on SSH port (confusing)
```

**[Inference] Best practices:**

- Use standard ports for standard services
- Document non-standard port usage clearly
- Implement proper firewall rules
- Avoid exposing unnecessary ports
- Use HTTPS (443) for sensitive services

