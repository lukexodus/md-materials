## Security Implications of Authority Parsing


Inconsistent authority parsing between security components creates vulnerabilities. Attackers exploit parsing differences to bypass security controls.

### Parser Differential Attacks

When different parts of a system parse URLs differently, attackers craft URLs that bypass security checks but reach malicious destinations.

**Example attack scenario:**

```
URL: http://trusted.com@evil.com/

Security filter parsing:
  - Sees "trusted.com" as host
  - Allows request

Actual request parser:
  - Parses "trusted.com" as userinfo
  - Connects to "evil.com"
```

The security component and request component interpret the same URL differently, allowing the attacker to bypass the trust check.

### SSRF Through Authority Manipulation

Server-Side Request Forgery attacks often exploit authority parsing to access internal resources. Attackers use alternative IP formats, DNS rebinding, authority confusion, and URL parser discrepancies.

**Example SSRF techniques:**

```
Block bypass using integer notation:
  Blocked:  http://127.0.0.1/admin
  Allowed:  http://2130706433/admin  (same address)

DNS rebinding:
  Initial resolution:  attacker.com → 1.2.3.4 (allowed)
  Later resolution:    attacker.com → 127.0.0.1 (internal)

Authority confusion:
  http://127.0.0.1#@example.com/
  Depending on parser, may connect to localhost
```

Robust SSRF protection requires resolving domains to IP addresses before validation, blocking private IP ranges regardless of format, using consistent parsing across all components, and implementing request whitelisting rather than blacklisting.

### Open Redirect Vulnerabilities

Open redirects allow attackers to redirect users to arbitrary URLs. Authority component confusion amplifies these attacks.

**Example vulnerable code:**

```
// Unsafe: trusts user-provided URL
redirect_url = request.get_parameter('url')
if redirect_url.startswith('https://trusted.com'):
    redirect(redirect_url)

Attack:
  https://trusted.com@evil.com/phishing
  - Passes prefix check
  - Redirects to evil.com
```

Safe redirect handling requires parsing URLs completely before validation, verifying host component specifically, using allowlists of complete domains, and displaying interstitial warnings for external redirects.

### Credential Leakage Prevention

Userinfo components in URLs can leak credentials through various channels including browser history, server access logs, referrer headers, and network monitoring.

**Mitigation strategies:**

```
Input sanitization:
  Remove userinfo before logging
  Strip userinfo from displayed URLs
  Warn users about credential exposure

Technical controls:
  Use POST for credentials
  Implement proper authentication mechanisms
  Configure servers to not log userinfo
  Set referrer policies to prevent leakage
```

Modern security practices treat credentials in URLs as a vulnerability requiring remediation rather than a supported feature.

