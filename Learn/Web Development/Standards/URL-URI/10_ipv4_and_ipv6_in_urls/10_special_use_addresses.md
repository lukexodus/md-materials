## Special-Use Addresses


Certain IP address ranges are reserved for special purposes and should not be used for general internet communication.

### IPv4 Special-Use Ranges

**0.0.0.0/8 - This Network:**

```
0.0.0.0 to 0.255.255.255
```

**Usage:**

- Source address for unknown/unspecified host
- Used in DHCP before address assignment
- "Any" address for server binding

**Example:**

```javascript
// Bind to all interfaces
server.listen(3000, '0.0.0.0');
```

**Not valid in URLs** as a destination address.

**10.0.0.0/8 - Private Network:**

```
10.0.0.0 to 10.255.255.255
```

**Usage:**

- Large private networks
- Corporate networks
- Not routable on public internet

**Example:**

```
http://10.0.1.50/internal-app
http://10.20.30.40:8080/api
```

**127.0.0.0/8 - Loopback:**

```
127.0.0.0 to 127.255.255.255
```

Covered in the Localhost section above.

**169.254.0.0/16 - Link-Local:**

```
169.254.0.0 to 169.254.255.255
```

**Usage:**

- Automatic Private IP Addressing (APIPA)
- Used when DHCP fails
- Only valid on local network segment

**Example:**

```
http://169.254.1.1/           // Auto-configured device
```

**172.16.0.0/12 - Private Network:**

```
172.16.0.0 to 172.31.255.255
```

**Usage:**

- Medium private networks
- Often used by Docker, VPNs

**Example:**

```
http://172.16.0.1/admin
http://172.18.0.2:8080/       // Docker container
```

**192.0.0.0/24 - IETF Protocol Assignments:**

```
192.0.0.0 to 192.0.0.255
```

**Usage:**

- Reserved for IETF protocol use
- Special documentation and examples

**192.0.2.0/24 - Documentation (TEST-NET-1):**

```
192.0.2.0 to 192.0.2.255
```

**Usage:**

- Documentation examples
- Should never appear in real network traffic

**Example:**

```
http://192.0.2.1/example       // Safe for documentation
```

**192.168.0.0/16 - Private Network:**

```
192.168.0.0 to 192.168.255.255
```

**Usage:**

- Small private networks
- Home networks
- Most

---

