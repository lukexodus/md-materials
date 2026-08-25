## Zone Identifiers in IPv6


Zone identifiers (also called scope IDs) specify which network interface to use for link-local and site-local IPv6 addresses.

### Purpose and Use Cases

Zone identifiers are necessary because link-local addresses are not globally unique:

```
fe80::1    // Could exist on multiple network interfaces
```

Without a zone identifier, the system cannot determine which interface to use.

**Scenarios requiring zone identifiers:**

- Link-local addresses (fe80::/10)
- Site-local addresses (deprecated, fec0::/10)
- Multicast addresses with link-local or site-local scope
- Multiple network interfaces with overlapping address spaces

### Syntax

**Operating system syntax:**

```
fe80::1%eth0           // Linux/Unix
fe80::1%en0            // macOS
fe80::1%3              // Windows (interface index)
fe80::1%Local Area Connection  // Windows (interface name)
```

**URL syntax:** The `%` character must be percent-encoded as `%25` in URLs:

```
http://[fe80::1%25eth0]/       // Correct URL encoding
http://[fe80::1%eth0]/         // Invalid - unencoded %
```

**Example:**

```
# System command
ping6 fe80::1%eth0

# Equivalent URL
http://[fe80::1%25eth0]:8080/api
```

### Zone Identifier Format

**Interface names (Linux/macOS):**

```
[fe80::1%25lo]          // Loopback interface
[fe80::1%25eth0]        // Ethernet interface 0
[fe80::1%25wlan0]       // Wireless interface 0
[fe80::1%25en0]         // macOS Ethernet
[fe80::1%25bridge0]     // Bridge interface
```

**Interface indices (Windows/numeric):**

```
[fe80::1%251]           // Interface index 1
[fe80::1%252]           // Interface index 2
[fe80::1%2512]          // Interface index 12
```

**Encoded special characters:** If interface names contain special characters, additional encoding may be required:

```
[fe80::1%25Local%20Area%20Connection]   // Windows interface with spaces
```

### Validation Rules

Zone identifiers have specific validation requirements:

**Allowed characters (before URL encoding):**

- Alphanumeric: `a-z`, `A-Z`, `0-9`
- Special: `-`, `.`, `_`, `~`
- System-specific characters [Operating system-dependent]

**Length limitations:**

- Maximum length varies by operating system [Typically 15-255 characters]
- Shorter names preferred for compatibility

**Case sensitivity:**

- Generally case-insensitive on most systems [Operating system-dependent]
- Preserve case for best compatibility

### Browser and Application Support

**Support status:**

- Modern browsers support zone identifiers with `%25` encoding
- Older browsers may reject URLs with zone identifiers
- Some HTTP libraries require explicit zone identifier support
- Server applications rarely need to handle zone identifiers [Typically used for client-side local connections]

**Example** browser behavior:

```javascript
// Modern browsers
fetch('http://[fe80::1%25eth0]:8080/api')
  .then(response => response.json())
  .catch(error => console.error(error));

// May work in some contexts
new URL('http://[fe80::1%25eth0]/path')
```

### Security Considerations

**Zone identifier validation:**

- Always validate zone identifiers to prevent injection attacks
- Restrict to known interface names or indices
- Reject unexpected characters or formats

**Information disclosure:** Interface names can reveal system configuration [Inference]:

```
[fe80::1%25corporate_network]   // Reveals network naming
[fe80::1%25eth0_dmz]            // Reveals network topology
```

**Access control:** Link-local addresses with zone identifiers should be restricted to localhost or trusted networks [Inference - security best practice].

### Practical Examples

**Web server on link-local address:**

```bash
# Start server
python3 -m http.server 8000 --bind fe80::1%eth0

# Access from same machine
curl 'http://[fe80::1%25eth0]:8000/'

# Access from another machine on same link
curl 'http://[fe80::1%25eth1]:8000/'  # Using client's interface
```

**Docker container networking:**

```bash
# Container with IPv6 link-local
docker run -p [fe80::1%25docker0]:8080:80 nginx

# Access container
curl 'http://[fe80::1%25docker0]:8080/'
```

**IoT device discovery:**

```javascript
// Discover devices on local network
const devices = [
  'http://[fe80::1%25eth0]:8080',
  'http://[fe80::2%25eth0]:8080',
  'http://[fe80::3%25eth0]:8080'
];

// Query each device
devices.forEach(url => {
  fetch(url + '/status')
    .then(response => response.json())
    .then(data => console.log(data));
});
```

**Key Points:**

- Zone identifiers specify network interface for link-local addresses
- `%` must be encoded as `%25` in URLs
- Required for fe80::/10 addresses on multi-interface systems
- Format varies by operating system (names vs. indices)
- Validate zone identifiers to prevent security issues
- Support varies across browsers and HTTP libraries

