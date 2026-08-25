## Testing and Validation Strategies


Comprehensive testing ensures authority parsing handles both valid inputs correctly and invalid inputs safely. Test suites should cover standard cases, edge cases, security cases, and interoperability cases.

### Standard Cases

Basic authority formats must parse correctly for common scenarios. Testing should cover simple domains, domains with ports, IPv4 addresses with and without ports, IPv6 addresses in brackets with ports, authorities with subdomains, and missing port specifications.

**Example test cases:**

```
Input:  example.com
Expect: host="example.com", port=null

Input:  example.com:8080
Expect: host="example.com", port=8080

Input:  192.168.1.1:443
Expect: host="192.168.1.1", port=443

Input:  [2001:db8::1]:80
Expect: host="2001:db8::1", port=80

Input:  sub.example.com
Expect: host="sub.example.com", port=null
```

### Edge Cases

Edge case testing addresses uncommon but valid inputs and boundary conditions. This includes maximum length domains, single-character labels, numeric-only domains, IPv4 in various formats, compressed IPv6 addresses, and empty authority for appropriate schemes.

**Example edge case tests:**

```
Input:  a.b.c.d.e.f.g.h.i.j.example.com
Expect: valid (many subdomains)

Input:  1.2.3.4
Expect: valid IPv4 address

Input:  [::1]
Expect: valid IPv6 loopback

Input:  example.com:1
Expect: valid (minimum valid port)

Input:  example.com:65535
Expect: valid (maximum valid port)
```

### Invalid Input Handling

Testing must verify that invalid authorities are properly rejected or handled according to policy. Test missing closing bracket for IPv6, port exceeding 65535, negative port numbers, non-numeric ports, spaces in hostnames, double colons in wrong positions, and malformed IPv6 addresses.

**Example invalid input tests:**

```
Input:  [2001:db8::1:8080
Expect: error (missing bracket)

Input:  example.com:70000
Expect: error (port too large)

Input:  example.com:-1
Expect: error (negative port)

Input:  exam ple.com
Expect: error (space in host)

Input:  example..com
Expect: error (empty label)
```

### Security Test Cases

Security testing validates protections against attack patterns. Tests should include SSRF attempts with various IP formats, homograph domain names, credential injection attempts, parser differential inputs, redirect bypass attempts, and malicious userinfo components.

**Example security tests:**

```
Input:  http://trusted.com@attacker.com/
Expect: host="attacker.com" (not "trusted.com")

Input:  http://2130706433/
Expect: recognized as 127.0.0.1 (if blocking localhost)

Input:  http://xn--80ak6aa92e.com/
Expect: recognized as Cyrillic (IDN homograph detection)

Input:  http://0x7f.0x0.0x0.0x1/
Expect: recognized as 127.0.0.1 variant
```

### Cross-Implementation Testing

Testing across different parsers identifies compatibility issues. Compare parsing results between WHATWG-compliant browsers, RFC 3986-compliant libraries, language standard libraries, and web frameworks.

**Example cross-implementation test:**

```
URL: http://example.com:80/

Browser (WHATWG):
  - Normalizes to http://example.com/
  - Omits default port

Strict RFC parser:
  - May preserve port 80
  - Depends on normalization settings

Both should agree on:
  - host="example.com"
  - Semantic equivalence
```

Discrepancies indicate areas requiring careful handling in security-sensitive applications.

