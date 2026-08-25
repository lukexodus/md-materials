## Authority Parsing Rules


Parsing the authority component correctly requires handling multiple formats, edge cases, and ambiguities. Different standards and implementations approach parsing with varying levels of strictness.

### Basic Parsing Algorithm

Authority parsing begins after identifying the authority through the initial "//" sequence. The parser must identify boundaries between userinfo, host, and port subcomponents.

The algorithm proceeds by searching for delimiters that separate authority from subsequent components (/, ?, #, or end of string). Within the authority, identifying the @ symbol (rightmost occurrence for userinfo/host separation). Identifying the colon for host/port separation (complex with IPv6). Extracting and validating each subcomponent.

**Example parsing:**

```
URL: https://user:pass@example.com:443/path?query

Step 1: Identify authority start after https://
        → user:pass@example.com:443

Step 2: Find @ delimiter
        → userinfo: "user:pass"
        → remaining: "example.com:443"

Step 3: Find port delimiter (rightmost : not in brackets)
        → host: "example.com"
        → port: "443"
```

### Handling IPv6 in Authority

IPv6 addresses complicate authority parsing because they contain colons that could be confused with the port delimiter. Square brackets solve this ambiguity by enclosing the IPv6 address.

The parser must recognize square brackets as IPv6 indicators, extract everything between [ and ] as the IPv6 address, and look for port delimiter only after the closing bracket.

**Example:**

```
URL: http://[2001:db8::1]:8080/path

Parsing steps:
1. Detect [ indicating IPv6
2. Extract to matching ]: "2001:db8::1"
3. Find : after ] for port: "8080"

Result:
  host: "2001:db8::1" (IPv6)
  port: "8080"
```

Without brackets, parsing would fail: `http://2001:db8::1:8080/path` would be ambiguous—is "8080" part of the IPv6 address or the port?

### Userinfo Parsing Edge Cases

The userinfo component can create parsing ambiguities, particularly when @ symbols appear in passwords or usernames through percent-encoding.

The algorithm uses the rightmost @ symbol to separate userinfo from host. This handles @ symbols within userinfo if they're percent-encoded as %40.

**Example:**

```
URL: http://user@domain.com:pass@example.com/

Parsing:
  Rightmost @: splits at second @
  userinfo: "user@domain.com:pass"
  host: "example.com"

If username contains @:
  http://user%40domain.com:pass@example.com/
  userinfo: "user%40domain.com:pass"
  host: "example.com"
  Decoded username: "user@domain.com"
```

Multiple @ symbols without proper encoding create ambiguity. Implementations may differ in handling malformed inputs, making consistent encoding essential.

### Port Parsing and Validation

Port numbers are 16-bit unsigned integers ranging from 0 to 65535. The port subcomponent appears after a colon following the host.

Port parsing must distinguish port delimiters from other colons (especially in IPv6 addresses), validate numeric range (0-65535), handle empty port declarations, and recognize default ports for common schemes.

**Example:**

```
Valid:   example.com:80
Valid:   example.com:8080
Valid:   [2001:db8::1]:443
Invalid: example.com:70000      (exceeds 65535)
Invalid: example.com:abc        (non-numeric)
Special: example.com:           (empty port - may default)
```

Empty port strings (host followed by colon but no digits) are handled differently by various implementations. Some treat it as missing port, others as error. The WHATWG standard treats it as invalid for special schemes like HTTP.

### Default Ports and Normalization

Many URL schemes define default ports that are implied when no port is specified. For comparison and normalization, explicitly specified default ports should be equivalent to missing ports.

**Common default ports:**

```
http://    → 80
https://   → 443
ftp://     → 21
ws://      → 80
wss://     → 443
```

**Normalization examples:**

```
http://example.com:80/  → http://example.com/
https://example.com/    (already normalized)
https://example.com:443/ → https://example.com/
ftp://example.com:21/   → ftp://example.com/
```

Normalized URLs with default ports omitted are considered equivalent to URLs with explicit default ports for caching, comparison, and security policy enforcement.

### Empty Authority Components

Some URL schemes allow empty or missing authority components. The file: scheme often uses empty authority (`file:///path`), indicating local filesystem. Some schemes allow missing authority entirely.

**Example:**

```
file:///C:/path/file.txt     (empty authority)
mailto:user@example.com      (no authority)
data:text/plain,Hello        (no authority)
about:blank                  (no authority)
```

HTTP and HTTPS require non-empty authorities. The WHATWG standard defines "special schemes" that mandate authorities with specific validation rules.

### Handling Malformed Authority

Real-world URLs often contain malformed authority components due to user error, legacy systems, or malicious intent. Implementations must decide between strict validation (rejecting invalid input) and lenient parsing (attempting best-effort interpretation).

Security-sensitive contexts should prefer strict validation to prevent bypasses. User-facing applications might use lenient parsing with validation warnings. Different components of a system should use consistent parsing to avoid security issues.

**Example malformed authorities:**

```
http://example.com::8080/    (double colon)
http://example .com/         (space in host)
http://[::1:8080/            (missing bracket)
http://user@:pass@host.com/  (malformed userinfo)
```

These should generally be rejected rather than attempting creative interpretation, as inconsistent parsing across systems creates vulnerabilities.

### WHATWG Authority Parsing

The WHATWG URL Standard defines precise authority parsing as a state machine. It handles special schemes (http, https, ws, wss, ftp, file) with specific validation requirements and opaque schemes with different rules.

The algorithm processes the authority character by character, transitioning between states based on input. States include authority state, host state, hostname state, port state, and special authority state.

**Key WHATWG behaviors:**

```
1. Special schemes require authority
2. Userinfo deprecated but parsed for http/https
3. IPv6 requires brackets
4. Empty hosts invalid for special schemes
5. Port must be valid number or empty
6. Specific error handling for each violation
```

The standard prioritizes matching existing browser behavior over strict RFC compliance, ensuring web compatibility while providing security through predictable parsing.

### RFC 3986 vs WHATWG Differences

RFC 3986 provides generic URI authority rules applicable to all schemes. It's more permissive about authority structure and leaves scheme-specific details to other specifications. It uses regular expressions for grammar definition.

WHATWG URL Standard specifies exact parsing algorithms for web URLs, provides deterministic behavior for edge cases, includes special handling for common schemes, and defines precise error conditions and recovery.

**Example difference:**

```
URL: http://example.com:99999/

RFC 3986: May parse "99999" as port (exceeds range)
WHATWG:   Parsing fails (port exceeds 65535)

URL: http://example.com:/path

RFC 3986: Allows empty port string
WHATWG:   Fails for special schemes
```

Applications should choose the appropriate standard based on their needs: WHATWG for web browser compatibility, RFC 3986 for generic URI handling across schemes.

