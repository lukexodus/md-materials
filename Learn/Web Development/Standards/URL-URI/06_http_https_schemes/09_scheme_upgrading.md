## Scheme Upgrading


Scheme upgrading refers to the process of automatically converting HTTP requests to HTTPS, either at the browser, server, or network level. This mechanism protects users from insecure connections and facilitates the web's transition to HTTPS-by-default.

### Browser-Level Upgrading

**Automatic HTTPS Upgrades:** Modern browsers implement various upgrade mechanisms:

1. **Address bar intervention:**

```
User types: example.com
Browser loads: https://example.com (not http://example.com)
```

2. **HTTPS-First Mode:** Browser attempts HTTPS before falling back to HTTP (if enabled).
    
3. **Type-specific upgrades:** Some browsers upgrade specific resource types automatically [Browser-specific behavior varies].
    

**Upgrade-Insecure-Requests CSP Directive:** Web pages can request automatic upgrading via Content Security Policy:

```http
Content-Security-Policy: upgrade-insecure-requests
```

**Effect:**

- All HTTP URLs in page are automatically upgraded to HTTPS
- Applies to all resource types (images, scripts, stylesheets, etc.)
- Prevents mixed content issues
- No code changes required in HTML

**Example:**

```html
<!-- HTML Source -->
<img src="http://example.com/image.jpg">
<script src="http://cdn.example.com/script.js"></script>

<!-- With upgrade-insecure-requests, browser requests -->
https://example.com/image.jpg
https://cdn.example.com/script.js
```

**Meta tag alternative:**

```html
<meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">
```

### Server-Level Upgrading

**HTTP to HTTPS Redirects:** Servers redirect HTTP requests to HTTPS equivalents:

**301 Permanent Redirect:**

```http
HTTP/1.1 301 Moved Permanently
Location: https://example.com/path
```

**302 Found (Temporary):**

```http
HTTP/1.1 302 Found
Location: https://example.com/path
```

**307 Temporary Redirect (preserves method):**

```http
HTTP/1.1 307 Temporary Redirect
Location: https://example.com/path
```

**Example** Apache configuration:

```apache
<VirtualHost *:80>
    ServerName example.com
    Redirect permanent / https://example.com/
</VirtualHost>
```

**Example** Nginx configuration:

```nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

**HSTS Header (Post-Upgrade):** After redirecting to HTTPS, include HSTS header:

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

This prevents future HTTP requests to the domain from the browser.

### Network-Level Upgrading

**HTTPS-by-Default Networks:** Some networks (ISPs, corporate, public Wi-Fi) may implement upgrade proxies [Deployment varies by provider].

**DNS-Level Security:**

- DNS over HTTPS (DoH)
- DNS over TLS (DoT)
- DNSSEC for authenticity verification

These don't directly upgrade HTTP to HTTPS but protect DNS queries that often precede HTTP requests.

### Upgrade Decision Flow

When a browser encounters an HTTP URL:

```
1. Check HSTS preload list
   └─ If present: Use HTTPS (no HTTP attempt)
   └─ If absent: Continue

2. Check HSTS header from previous visits
   └─ If valid HSTS: Use HTTPS (no HTTP attempt)
   └─ If no HSTS: Continue

3. Check upgrade-insecure-requests directive
   └─ If present: Upgrade to HTTPS
   └─ If absent: Continue

4. Check HTTPS-Only Mode setting
   └─ If enabled: Try HTTPS first
   └─ If disabled: Continue

5. Make HTTP request as specified
```

### Implementation Best Practices

**Gradual Migration Strategy:**

**Phase 1: Support both protocols**

```nginx
# HTTP server
server {
    listen 80;
    # Serve content normally
}

# HTTPS server
server {
    listen 443 ssl;
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    # Serve same content
}
```

**Phase 2: Redirect HTTP to HTTPS**

```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```

**Phase 3: Add HSTS with short max-age**

```http
Strict-Transport-Security: max-age=86400
```

**Phase 4: Increase HSTS max-age**

```http
Strict-Transport-Security: max-age=31536000
```

**Phase 5: Add includeSubDomains**

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

**Phase 6: Submit to HSTS preload**

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

### Testing Scheme Upgrades

**Manual testing:**

1. Clear browser cache and HSTS state
2. Visit HTTP version of site
3. Verify redirect to HTTPS
4. Check HSTS header presence
5. Test with HSTS in effect (should skip HTTP entirely)

**Automated testing:**

```bash
# Check HTTP to HTTPS redirect
curl -I http://example.com

# Check HSTS header
curl -I https://example.com | grep -i strict-transport

# Check certificate validity
openssl s_client -connect example.com:443 -servername example.com
```

**Tools:**

- SSL Labs Server Test (ssllabs.com/ssltest)
- Security Headers checker (securityheaders.com)
- HSTS Preload checker (hstspreload.org)
- Browser DevTools Security tab

### Edge Cases and Considerations

**Localhost and development:**

```
http://localhost:3000  → Often not upgraded
http://127.0.0.1:8080  → Often not upgraded
```

Development environments typically exempt localhost from upgrade rules.

**Internal networks:**

```
http://internal.company.local → May need explicit exemption
```

Corporate internal sites may require HTTP access [Configuration-dependent].

**Legacy system integration:**

- API endpoints without HTTPS support
- Third-party services requiring HTTP callbacks
- IoT devices with limited TLS support

**Performance considerations:**

- TLS handshake overhead (mitigated by TLS 1.3, session resumption)
- Certificate chain validation
- OCSP stapling for revocation checking

**Key Points:**

- Multiple layers provide redundant upgrade mechanisms
- Server-side redirects are most reliable for initial visits
- HSTS prevents downgrade attacks after first HTTPS visit
- upgrade-insecure-requests directive fixes mixed content automatically
- Testing should cover all upgrade mechanisms
- Gradual HSTS deployment reduces risk of lockout

