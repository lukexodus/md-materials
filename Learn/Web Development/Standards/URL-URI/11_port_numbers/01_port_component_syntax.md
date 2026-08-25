## Port Component Syntax


### Basic Syntax Structure

The port component in URI syntax consists of zero or more decimal digits following a colon after the host:

```
authority = [userinfo@]host[:port]
port = *DIGIT
```

**Position in URI:**

```
scheme://host:port/path?query#fragment
           └──┬──┘
              port
```

### Character Restrictions

**Allowed characters:** Only decimal digits (0-9)

**No other characters permitted:**

- No letters: `http://example.com:80ab/` is invalid
- No signs: `http://example.com:+80/` is invalid
- No spaces: `http://example.com:80 80/` is invalid
- No hexadecimal: `http://example.com:0x50/` is invalid

**Example valid ports:**

```
http://example.com:80/
https://example.com:443/
http://localhost:3000/
ftp://ftp.example.com:21/
```

**Example invalid ports:**

```
http://example.com:8080a/     // Contains letter
http://example.com:80.80/     // Contains period
http://example.com:0x50/      // Hexadecimal notation
http://example.com:-80/       // Negative sign
```

### Length Limitations

**Maximum value:** 65535 (2^16 - 1)

**Minimum value:** 0

**Binary representation:** 16 bits

**Decimal digits:** 1 to 5 digits maximum

```
Valid range examples:
0       // Minimum
1       // Single digit
80      // Two digits
8080    // Four digits
65535   // Maximum (five digits)

Invalid:
65536   // Exceeds maximum
100000  // Exceeds maximum
```

### Empty Port Syntax

A colon followed immediately by a delimiter represents an empty port:

```
http://example.com:/path
                  ↑
              empty port
```

**RFC 3986 interpretation:** Syntactically valid but semantically means "use default port"

**WHATWG interpretation:** Treated as if no port was specified

**Example behavior:**

```javascript
// WHATWG URL API
const url = new URL('http://example.com:/path');
console.log(url.port);  // "" (empty string)
console.log(url.href);  // "http://example.com/path"
```

### Port Separator Ambiguity

The colon (`:`) serves multiple purposes in URIs, requiring careful parsing:

**Separates username from password:**

```
http://user:pass@example.com/
           ↑
    password separator
```

**Separates host from port:**

```
http://example.com:8080/
                  ↑
           port separator
```

**Part of IPv6 address:**

```
http://[2001:db8::1]:8080/
            ↑     ↑     ↑
     IPv6 colons  port separator
```

**Parsing rule:** The last colon outside of brackets (after the host) indicates the port separator.

**Example parsing:**

```
http://user:pass@example.com:8080/path
        ↑1       ↑2              ↑3

Colon 1: Password separator (in userinfo)
Colon 2: End of userinfo (before @)
Colon 3: Port separator (last colon in authority)
```

**IPv6 example:**

```
http://[2001:db8::1]:8080/
        └─IPv6 addr─┘ ↑
                   port separator (after ])
```

### Leading Zeros

RFC 3986 allows leading zeros in port numbers, but they are interpreted as decimal (not octal):

```
http://example.com:0080/
                   ↑
            leading zeros
```

**Interpretation:** Always decimal, never octal

```
:0080  →  80 (decimal)
:0123  →  123 (decimal, NOT octal)
:00080 →  80 (decimal)
```

**Normalization:** Leading zeros should be removed:

```
Original:   http://example.com:0080/
Normalized: http://example.com:80/
            http://example.com/     (if 80 is default for scheme)
```

**Comparison with IPv4:** Unlike IPv4 octets where leading zeros historically indicated octal (implementation-dependent), port numbers are always decimal regardless of leading zeros.

### Port Parsing Algorithm

**Step-by-step process:**

1. **Locate the port separator:**
    
    - Find the last colon in the authority component
    - Ensure it's outside IPv6 brackets (after `]` if present)
    - Ensure it's after the userinfo component (after `@` if present)
2. **Extract port string:**
    
    - All characters between the colon and the next delimiter (`/`, `?`, `#`, or end)
3. **Validate characters:**
    
    - Verify all characters are decimal digits (0-9)
    - Empty string is valid (means default port)
4. **Parse as integer:**
    
    - Convert string to integer (ignore leading zeros)
    - Treat empty string as "no port specified"
5. **Range validation:**
    
    - Verify value is between 0 and 65535 inclusive
    - Values outside this range are invalid

**Example implementation:**

```javascript
function parsePort(authority) {
  // Find last colon outside brackets
  let colonIndex = -1;
  let inBrackets = false;
  
  for (let i = authority.length - 1; i >= 0; i--) {
    if (authority[i] === ']') inBrackets = true;
    if (authority[i] === '[') inBrackets = false;
    if (authority[i] === ':' && !inBrackets) {
      colonIndex = i;
      break;
    }
  }
  
  if (colonIndex === -1) return null; // No port
  
  const portString = authority.slice(colonIndex + 1);
  
  // Validate digits only
  if (!/^\d*$/.test(portString)) {
    throw new Error('Invalid port: non-digit characters');
  }
  
  // Empty port string means default
  if (portString === '') return null;
  
  const port = parseInt(portString, 10);
  
  // Validate range
  if (port < 0 || port > 65535) {
    throw new Error('Invalid port: out of range');
  }
  
  return port;
}

// Usage
parsePort('example.com:8080');           // 8080
parsePort('[2001:db8::1]:8080');         // 8080
parsePort('example.com:');               // null (empty port)
parsePort('example.com:65536');          // Error: out of range
parsePort('example.com:80abc');          // Error: non-digit characters
```

### Port in Different URI Components

**Authority component only:** Port numbers only appear in the authority component, never in path, query, or fragment:

```
Valid:   http://example.com:8080/path?query#fragment
Invalid: http://example.com/path:8080
Invalid: http://example.com/path?port=8080:value
```

**Multiple colons handling:**

```
Userinfo with port:
ftp://user:pass@example.com:21/
      └userinfo┘ └─host──┘ └┘
                          port

IPv6 with port:
http://[fe80::1]:8080/
       └IPv6──┘ └─┘
                port
```

