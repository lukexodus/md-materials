## Security Headers


### HTTP Strict Transport Security (HSTS)

HSTS enforces secure connections by instructing the User Agent (UA) to interact with the domain only over HTTPS, mitigating Protocol Downgrade Attacks and Cookie Hijacking.

- **Implementation:**
    
    - **Header:** `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload`
        
    - **max-age:** Set to at least 2 years (63,072,000 seconds) to ensure long-term coverage.
        
    - **includeSubDomains:** Mandatory to prevent subdomains from serving content over insecure HTTP.
        
    - **preload:** Required for submission to the browser HSTS Preload List. This hardcodes the HSTS rule into the browser binary, protecting users even on the very first connection (Trust On First Use - TOFU mitigation).
        
- **Deployment Strategy:**
    
    - Start with a low `max-age` (e.g., 5 minutes) and no `preload` directive to test for mixed content issues or certificate misconfigurations.
        
    - Incrementally increase `max-age` (1 week, 1 month, 2 years) before adding `preload`.
        
- **Risk:** Once preloaded, removal takes months to propagate through browser updates. Ensure infrastructure permanently supports HTTPS.
    

### Content Security Policy (CSP)

CSP is the primary defense-in-depth mechanism against Cross-Site Scripting (XSS) and data injection attacks. It operates by defining an allowlist of trusted content sources.

- **Rigorous Configuration:**
    
    - **Default Deny:** Always start with `default-src 'none';`. This forces explicit authorization for every resource type.
        
    - **Script Sources:** Avoid `'unsafe-inline'` and `'unsafe-eval'`. These directives nullify XSS protection.
        
    - **Modern SPAs:** Use **Nonce-based CSP** for dynamic script loading. Generate a cryptographically strong random nonce per request, embed it in the CSP header (`script-src 'nonce-<random>'`), and attach it to authorized `<script>` tags.
        
    - **Strict-Dynamic:** Use `'strict-dynamic'` to allow trusted scripts to load their own dependencies without explicitly whitelisting every downstream URL.
        
- **Object-Src:** Explicitly set `object-src 'none'` to block Flash, Java applets, and other legacy plugin vectors.
    
- **Base-Uri:** Set `base-uri 'self'` or `none` to prevent `<base>` tag injection, which can rebase relative URLs to attacker-controlled domains.
    
- **Reporting:**
    
    - Use `Content-Security-Policy-Report-Only` header during initial policy generation to log violations without breaking functionality.
        
    - Configure `report-to` (and legacy `report-uri`) to stream violation JSON blobs to a centralized logging endpoint for analysis.
        

### X-Content-Type-Options

This header prevents the browser from "MIME-sniffing" a response away from the declared `Content-Type`.

- **Directive:** `X-Content-Type-Options: nosniff`
    
- **Vulnerability Addressed:** Attackers upload a malicious file (e.g., `script.js` disguised as `image.jpg`). Without this header, if the browser detects script-like content, it may execute the file as JavaScript despite the image MIME type.
    
- **Requirement:** Ensure the server sends correct `Content-Type` headers for all assets (e.g., `text/css` for CSS, `application/javascript` for JS). Improper types will cause the browser to block the resource when `nosniff` is active.
    

### X-Frame-Options (XFO) and Frame-Ancestors

Protects against Clickjacking (UI Redressing) by controlling whether the site can be rendered within an `<iframe>`, `<frame>`, `<embed>`, or `<object>`.

- **Directives:**
    
    - `DENY`: Completely prevents framing. Preferred for sites that do not need to be embedded.
        
    - `SAMEORIGIN`: Allows framing only by pages on the same origin.
        
- **Obsolescence Note:** `X-Frame-Options` is superseded by the CSP `frame-ancestors` directive in modern browsers.
    
    - **Best Practice:** Implement _both_ for backward compatibility. If both are present, modern browsers prioritize CSP.
        
    - CSP Example: `Content-Security-Policy: frame-ancestors 'none';` (Equivalent to `DENY`).
        

### Referrer-Policy

Controls how much referrer information (the URL of the previous page) is included in requests sent to other origins.

- **Recommended Directive:** `Referrer-Policy: strict-origin-when-cross-origin`
    
    - **Same-Origin:** Sends the full path (e.g., `https://example.com/page?id=123`).
        
    - **Cross-Origin (HTTPS to HTTPS):** Sends only the origin (e.g., `https://example.com/`). Prevents leakage of sensitive path parameters or tokens.
        
    - **Downgrade (HTTPS to HTTP):** Sends no referrer header.
        
- **Anti-Pattern:** `unsafe-url`. This leaks the full URL to any third-party resource loaded on the page, potentially exposing session tokens or PII in URL parameters.
    

### Permissions-Policy (formerly Feature-Policy)

Allows granular control over browser features and APIs (e.g., Geolocation, Camera, Microphone, USB).

- **Syntax:** `Permissions-Policy: <feature>=<allowlist>`
    
- **Hardening Strategy:** Explicitly disable powerful features that the application does not utilize to reduce the attack surface.
    
    - Example: `Permissions-Policy: geolocation=(), camera=(), microphone=(), payment=(), usb=()`
        
- **Floc/Topics API:** Can be used to opt-out of browser tracking cohorts.
    
    - Example: `Permissions-Policy: interest-cohort=()`
        

### Cache-Control (Security Context)

While primarily for performance, caching directives are critical for preventing the persistence of sensitive data on shared or public endpoints.

- **Sensitive Data:** For endpoints returning PII, financial data, or CSRF tokens.
    
    - `Cache-Control: no-store`
        
    - This directive instructs the browser and intermediate proxies not to write the response to disk or memory.
        
- **Pragma:** Include `Pragma: no-cache` for backwards compatibility with HTTP/1.0 clients.
    

**Related Topics:**

- Cross-Origin Resource Sharing (CORS) Configuration
    
- Cookie Security Attributes (Secure, HttpOnly, SameSite)
    
- Subresource Integrity (SRI)
    
- Server-Side TLS Configuration (Cipher Suites)

---

