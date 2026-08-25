## IP Address Validation


Proper validation of IP addresses in URLs is essential for security, functionality, and compatibility.

### IPv4 Validation Rules

**Structural validation:**

1. Exactly four octets separated by dots
2. Each octet is a decimal number
3. Each octet is between 0 and 255
4. No leading zeros (to avoid octal interpretation ambiguity)
5. No whitespace or extra characters

**Regular expression (basic):**

```regex
^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$
```

**Example** validation logic:

```javascript
function isValidIPv4(ip) {
  const octets = ip.split('.');
  if (octets.length !== 4) return false;
  
  return octets.every(octet => {
    const num = parseInt(octet, 10);
    // Check no leading zeros, valid range
    return octet === num.toString() && num >= 0 && num <= 255;
  });
}

// Valid
isValidIPv4('192.168.1.1')      // true
isValidIPv4('255.255.255.255')  // true
isValidIPv4('0.0.0.0')          // true

// Invalid
isValidIPv4('192.168.1')        // false - too few octets
isValidIPv4('192.168.1.256')    // false - octet > 255
isValidIPv4('192.168.01.1')     // false - leading zero
isValidIPv4('192.168.1.1.1')    // false - too many octets
```

**Edge cases:**

```
0.0.0.0              // Valid (unspecified address)
255.255.255.255      // Valid (broadcast address)
192.168.001.1        // Invalid (leading zero)
192.168.1.1a         // Invalid (non-numeric)
192.168. 1.1         // Invalid (whitespace)
```

### IPv6 Validation Rules

**Structural validation:**

1. 0 to 8 hextets (with compression, minimum 2)
2. Each hextet is 1-4 hexadecimal characters
3. Hextets separated by colons
4. At most one `::` compression
5. Optional zone identifier after `%`
6. Optional IPv4 suffix for mapped addresses

**Complexity considerations:** IPv6 validation is significantly more complex than IPv4 due to:

- Multiple valid representations of the same address
- Compression rules with `::`
- Zone identifiers
- IPv4-mapped addresses
- Case insensitivity

**Regular expression (comprehensive):**

```regex
^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|
   ([0-9a-fA-F]{1,4}:){1,7}:|
   ([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|
   ([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|
   ([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|
   ([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|
   ([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|
   [0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|
   :((:[0-9a-fA-F]{1,4}){1,7}|:)|
   fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|
   ::(ffff(:0{1,4}){0,1}:){0,1}
   ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3}
   (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|
   ([0-9a-fA-F]{1,4}:){1,4}:
   ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3}
   (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$
```

**Example** validation function:

```javascript
function isValidIPv6(ip) {
  // Remove zone identifier if present
  const [address, zone] = ip.split('%');
  
  // Split into hextets
  const parts = address.split(':');
  
  // Check for :: compression
  const emptyIndex = parts.indexOf('');
  const hasCompression = emptyIndex !== -1;
  
  if (hasCompression) {
    // Remove consecutive empty strings (::)
    const filtered = parts.filter((p, i) => {
      return p !== '' || (i > 0 && parts[i-1] !== '');
    });
    
    // After compression, must have fewer than 8 hextets
    if (filtered.length >= 8) return false;
  } else {
    // Without compression, must have exactly 8 hextets
    if (parts.length !== 8) return false;
  }
  
  // Validate each hextet
  return parts.every(part => {
    if (part === '') return hasCompression; // Empty only valid with ::
    if (part.length > 4) return false;
    return /^[0-9a-fA-F]+$/.test(part);
  });
}

// Valid
isValidIPv6('2001:db8::1')                    // true
isValidIPv6('2001:db8:85a3::8a2e:370:7334')   // true
isValidIPv6('::1')                            // true
isValidIPv6('fe80::1')                        // true

// Invalid
isValidIPv6('2001:db8::1::2')                 // false - multiple ::
isValidIPv6('gggg::1')                        // false - invalid hex
isValidIPv6('2001:db8:1')                     // false - too few hextets
```

### URL Context Validation

In addition to address format validation, URLs require additional checks:

**Square bracket validation (IPv6):**

```javascript
function extractIPv6FromURL(url) {
  const match = url.match(/\[([^\]]+)\]/);
  return match ? match[1] : null;
}

// Extract and validate
const url = 'http://[2001:db8::1]:8080/path';
const ip = extractIPv6FromURL(url);
if (ip && isValidIPv6(ip)) {
  // Valid IPv6 URL
}
```

**Port validation:**

```javascript
function validateIPURL(url) {
  const parsed = new URL(url);
  const hostname = parsed.hostname;
  const port = parsed.port;
  
  // Check if hostname is valid IP
  const isIPv4 = isValidIPv4(hostname);
  const isIPv6 = hostname.startsWith('[') && 
                 hostname.endsWith(']') &&
                 isValidIPv6(hostname.slice(1, -1));
  
  // Validate port if present
  if (port && (parseInt(port) < 1 || parseInt(port) > 65535)) {
    return false;
  }
  
  return isIPv4 || isIPv6;
}
```

### Library-Based Validation

Most programming languages provide IP address validation libraries:

**JavaScript (using built-in URL API):**

```javascript
function isValidIP(ip) {
  try {
    // IPv4
    new URL(`http://${ip}`);
    return true;
  } catch {
    try {
      // IPv6
      new URL(`http://[${ip}]`);
      return true;
    } catch {
      return false;
    }
  }
}
```

**Python (using ipaddress module):**

```python
import ipaddress

def is_valid_ip(ip):
    try:
        ipaddress.ip_address(ip)
        return True
    except ValueError:
        return False

# Usage
is_valid_ip('192.168.1.1')    # True
is_valid_ip('2001:db8::1')    # True
is_valid_ip('invalid')        # False
```

**Node.js (using net module):**

```javascript
const net = require('net');

function isValidIP(ip) {
  return net.isIP(ip) !== 0;
}

function isIPv4(ip) {
  return net.isIP(ip) === 4;
}

function isIPv6(ip) {
  return net.isIP(ip) === 6;
}
```

### Security Validation

**SSRF (Server-Side Request Forgery) prevention:** Validate IP addresses to prevent access to internal networks:

```javascript
function isPrivateIPv4(ip) {
  const octets = ip.split('.').map(Number);
  
  // 10.0.0.0/8
  if (octets[0] === 10) return true;
  
  // 172.16.0.0/12
  if (octets[0] === 172 && octets[1] >= 16 && octets[1] <= 31) return true;
  
  // 192.168.0.0/16
  if (octets[0] === 192 && octets[1] === 168) return true;
  
  // 127.0.0.0/8 (loopback)
  if (octets[0] === 127) return true;
  
  // 169.254.0.0/16 (link-local)
  if (octets[0] === 169 && octets[1] === 254) return true;
  
  return false;
}

function isPrivateIPv6(ip) {
  // ::1 (loopback)
  if (ip === '::1' || ip === '0:0:0:0:0:0:0:1') return true;
  
  // fc00::/7 (unique local)
  if (ip.startsWith('fc') || ip.startsWith('fd')) return true;
  
  // fe80::/10 (link-local)
  if (ip.startsWith('fe8') || ip.startsWith('fe9') || 
      ip.startsWith('fea') || ip.startsWith('feb')) return true;
  
  return false;
}
```

**Allowlist approach:**

```javascript
function isSafeExternalIP(ip) {
  if (isValidIPv4(ip)) {
    return !isPrivateIPv4(ip) && 
           !isSpecialUseIPv4(ip);
  }
  if (isValidIPv6(ip)) {
    return !isPrivateIPv6(ip) && 
           !isSpecialUseIPv6(ip);
  }
  return false;
}
```

**Key Points:**

- Use established libraries for validation when possible
- Regular expressions for IP addresses are complex and error-prone
- Validate both format and security constraints
- Consider context-specific requirements (URL encoding, square brackets)
- Test edge cases thoroughly
- Implement SSRF protections for user-supplied IP addresses

