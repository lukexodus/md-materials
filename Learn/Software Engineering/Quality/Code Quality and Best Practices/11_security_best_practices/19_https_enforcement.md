## HTTPS Enforcement


### HTTP Strict Transport Security (HSTS)

HSTS is the primary mechanism to eliminate the "Trust on First Use" (TOFU) vulnerability and prevent protocol downgrade attacks (e.g., SSL Stripping). It instructs user agents to interact with the domain exclusively over HTTPS for a specified duration.1

- Header Implementation:
    
    The Strict-Transport-Security header must be sent with every HTTPS response.
    
    HTTP
    
    ```
    Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
    ```
    
- **Directives:**
    
    - `max-age`: Specifies the duration in seconds the browser should remember the enforcement.2 Production value should be at least two years (`63072000`).
        
    - `includeSubDomains`: Applies the rule to all subdomains. Critical for preventing cookie tossing attacks and subdomain hijacking.3
        
    - `preload`: Consent for inclusion in the browser hardcoded HSTS Preload List.4
        
- HSTS Preload List:
    
    To protect the very first connection attempt (before the header is ever received), domains must be submitted to the HSTS Preload List maintained by browser vendors.5
    
    - _Warning:_ Preloading is difficult to reverse. Removal takes months to propagate to stable browser versions.6 Ensure comprehensive HTTPS support across all subdomains and internal routing before submission.
        

### Server-Side Redirection Strategy

While HSTS handles client-side enforcement, server-side redirection captures the initial non-secure request.

- 301 Moved Permanently:
    
    Use HTTP 301 status codes for redirecting HTTP traffic to HTTPS. This instructs search engines to transfer SEO ranking to the secure URL and allows browsers to cache the redirect.7
    
    - _Avoid 302 Found:_ 302 redirects are temporary and do not transfer link equity, nor do they encourage the browser to update bookmarks.8
        
- Canonicalization:
    
    Ensure redirects resolve to a single canonical origin (e.g., http://www.example.com -> https://example.com) to prevent duplicate content issues and split-brain DNS scenarios.
    
- Load Balancer Termination:
    
    In architectures using TLS termination at the Load Balancer (e.g., AWS ALB, Nginx), the backend application must inspect the X-Forwarded-Proto header. If the value is http, the application must issue a redirect, preventing infinite redirect loops between the LB and the application.
    

### TLS Configuration and Cipher Suites

Enforcing HTTPS requires rigorous configuration of the underlying TLS protocol to mitigate attacks like POODLE, BEAST, or CRIME.

- **Protocol Versions:**
    
    - **Disable:** SSLv2, SSLv3, TLS 1.0, and TLS 1.1. These are cryptographically broken.
        
    - **Enable:** TLS 1.2 and TLS 1.3.
        
- Cipher Suites:
    
    Prioritize Authenticated Encryption with Associated Data (AEAD) algorithms and Forward Secrecy (FS).
    
    - **Preferred:** ECDHE-ECDSA-AES256-GCM-SHA384, ECDHE-RSA-AES256-GCM-SHA384, TLS_AES_256_GCM_SHA384.
        
    - **Curve Preferences:** Prioritize X25519 or P-256 curves for key exchange.
        
- Key Exchange:
    
    Ensure Diffie-Hellman parameters are at least 2048 bits. Pre-generated 1024-bit DH parameters (common in default configurations) are vulnerable to Logjam attacks.
    

### Content Security Policy (CSP) Integration

CSP acts as a secondary enforcement layer to prevent Mixed Content warnings (loading HTTP resources on an HTTPS page).

- upgrade-insecure-requests:
    
    Include this directive in the CSP header. It instructs the user agent to transparently rewrite insecure URLs (HTTP) to secure URLs (HTTPS) before making the network request.
    
    HTTP
    
    ```
    Content-Security-Policy: upgrade-insecure-requests; default-src https:
    ```
    
- Block-all-mixed-content:
    
    Deprecated in favor of upgrade-insecure-requests, but effectively blocks HTTP resources if rewriting is not possible.
    

### Cookie Security

HTTPS enforcement is incomplete without securing the state transport mechanism.

- Secure Flag:
    
    All cookies must have the Secure attribute set. This prevents the cookie from being transmitted over an unencrypted HTTP connection.9
    
- Cookie Prefixes:
    
    Use the __Host- prefix for maximum security. A cookie named __Host-SessionId must have the Secure flag, must originate from the secure origin, must not have a Domain attribute (scoping it to the exact host), and must have Path=/.
    
    HTTP
    
    ```
    Set-Cookie: __Host-SessionId=xyz; Secure; HttpOnly; SameSite=Strict; Path=/
    ```
    

### Certificate Management and Automation

- Automated Renewal:
    
    Implement ACME protocol (e.g., Certbot) to automate certificate issuance and renewal.10 Manual management leads to expiration outages.11
    
- Certificate Transparency (CT):
    
    Ensure the Certificate Authority (CA) publishes logs to CT servers. Chrome and Safari require SCTs (Signed Certificate Timestamps) for EV and DV certificates.
    
- Wildcard Certificates:
    
    Minimize use. If a wildcard private key (*.example.com) is compromised, all subdomains are vulnerable. Prefer specific SAN (Subject Alternative Name) certificates for critical infrastructure.
    

**Related Topics:** Content Security Policy (CSP), TLS/SSL Handshake Optimization, Load Balancing Strategies, DNS Security (DNSSEC).

---

