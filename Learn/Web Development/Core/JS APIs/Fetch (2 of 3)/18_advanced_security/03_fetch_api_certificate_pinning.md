## Fetch API Certificate Pinning


### Browser Limitations

Certificate pinning is **not directly supported** in the Fetch API or in web browsers for JavaScript applications. Browsers handle TLS/SSL certificate validation automatically at the network layer, and web applications cannot access or override this validation process.

The browser's built-in certificate validation:

- Checks certificate chain of trust
- Verifies certificate hasn't expired
- Validates certificate revocation status
- Ensures hostname matches certificate

Web applications cannot:

- Access raw certificate data during fetch requests
- Implement custom certificate validation logic
- Pin specific certificates or public keys
- Override browser certificate decisions

### Why Certificate Pinning is Unavailable

#### Security Architecture

Browsers intentionally prevent certificate pinning in web contexts to:

- Prevent malicious sites from bypassing security warnings
- Maintain user control over trusted certificate authorities
- Avoid breaking legitimate traffic through corporate proxies
- Protect users from outdated or compromised pins

#### Network Layer Abstraction

The Fetch API operates at the application layer and has no access to:

- TLS handshake details
- Certificate chain information
- Raw certificate bytes
- Connection security parameters

### Alternative Security Measures

#### Subresource Integrity (SRI)

While not certificate pinning, SRI provides integrity verification for fetched resources:

```javascript
// For <script> and <link> tags (not fetch)
<script 
  src="https://cdn.example.com/library.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/ux..."
  crossorigin="anonymous">
</script>
```

**Important**: SRI only works with `<script>`, `<link>`, and `<style>` tags, not with the Fetch API directly.

#### Content Security Policy (CSP)

Restrict which domains can be contacted:

```javascript
// Set via HTTP header (server-side)
Content-Security-Policy: connect-src 'self' https://api.example.com;

// Or via meta tag
<meta http-equiv="Content-Security-Policy" 
      content="connect-src 'self' https://api.example.com;">
```

This limits fetch requests to specific origins but doesn't validate certificates.

#### HTTPS Enforcement

Always use HTTPS and enable HSTS:

```javascript
// Server sends header
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

This ensures browsers always use HTTPS but doesn't pin certificates.

### Detecting Certificate Issues

While you cannot implement pinning, you can detect when certificate validation fails:

```javascript
async function fetchWithCertificateDetection(url) {
  try {
    const response = await fetch(url);
    return { success: true, response };
  } catch (error) {
    // [Unverified] Certificate errors may appear as network errors
    // Browsers don't expose specific certificate failure reasons
    
    if (error.name === 'TypeError' && error.message.includes('Failed to fetch')) {
      // Could be certificate error, network error, or CORS issue
      return {
        success: false,
        possibleCertificateIssue: true,
        error: error.message
      };
    }
    
    return { success: false, error: error.message };
  }
}
```

**Note**: Browsers do not expose specific certificate validation failure reasons to JavaScript for security reasons.

### Public Key Pinning (Deprecated)

HTTP Public Key Pinning (HPKP) was a mechanism for certificate pinning but has been **deprecated and removed** from browsers:

```javascript
// DEPRECATED - Do not use
Public-Key-Pins: pin-sha256="base64=="; max-age=expireTime
```

HPKP was removed due to:

- Risk of site lockout with misconfiguration
- Potential for ransom attacks
- Complexity in key rotation
- Better alternatives available

### Certificate Transparency

Modern browsers support Certificate Transparency (CT) automatically:

```javascript
// Browsers verify CT logs automatically
// No JavaScript API available to check CT status
```

Certificate Transparency helps detect:

- Mis-issued certificates
- Compromised certificate authorities
- Unauthorized certificate issuance

### Native Mobile App Pinning

Certificate pinning **is available** in native mobile applications but not in web browsers:

#### iOS Example (Swift)

```swift
// Native iOS - NOT available in web browsers
func urlSession(_ session: URLSession, 
                didReceive challenge: URLAuthenticationChallenge,
                completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    // Custom certificate validation
    let serverTrust = challenge.protectionSpace.serverTrust
    // Validate against pinned certificate
}
```

#### Android Example (Kotlin)

```kotlin
// Native Android - NOT available in web browsers
val certificatePinner = CertificatePinner.Builder()
    .add("example.com", "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
    .build()

val client = OkHttpClient.Builder()
    .certificatePinner(certificatePinner)
    .build()
```

### Service Worker Considerations

Service Workers can intercept fetch requests but still cannot validate certificates:

```javascript
// Service Worker - certificate validation NOT available
self.addEventListener('fetch', (event) => {
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // Cannot access certificate information here
        // Cannot perform custom certificate validation
        return response;
      })
      .catch(error => {
        // Cannot determine if error was certificate-related
        console.log('Fetch failed:', error);
        throw error;
      })
  );
});
```

### Security Headers for Enhanced Protection

While not certificate pinning, these headers improve security:

#### Expect-CT Header (Deprecated)

```javascript
// Server sends (now deprecated)
Expect-CT: max-age=86400, enforce, report-uri="https://example.com/report"
```

Modern browsers enforce CT by default without this header.

#### Certificate Authority Authorization (CAA)

DNS-level control over certificate issuance (configured at DNS level, not in JavaScript):

```
example.com. CAA 0 issue "letsencrypt.org"
example.com. CAA 0 issuewild "letsencrypt.org"
```

### Verifying HTTPS Connection

You can verify a connection uses HTTPS but cannot inspect the certificate:

```javascript
function isSecureConnection(url) {
  const urlObj = new URL(url);
  return urlObj.protocol === 'https:';
}

async function fetchSecure(url) {
  if (!isSecureConnection(url)) {
    throw new Error('Insecure connection: HTTPS required');
  }
  
  return await fetch(url);
}
```

### Mixed Content Detection

Detect and prevent mixed content issues:

```javascript
function detectMixedContent(url) {
  const isPageSecure = window.location.protocol === 'https:';
  const isResourceSecure = new URL(url).protocol === 'https:';
  
  if (isPageSecure && !isResourceSecure) {
    console.warn('Mixed content detected:', url);
    return true;
  }
  
  return false;
}

async function fetchWithMixedContentCheck(url) {
  if (detectMixedContent(url)) {
    throw new Error('Mixed content: Cannot fetch HTTP resource from HTTPS page');
  }
  
  return await fetch(url);
}
```

### Monitoring Certificate Expiration

Certificate expiration monitoring must be done server-side or via external monitoring tools. JavaScript cannot access certificate expiration dates.

### Proxy and Corporate Certificate Issues

Users behind corporate proxies with custom certificates will experience different certificate chains:

```javascript
async function fetchWithProxyAwareness(url) {
  try {
    const response = await fetch(url);
    return response;
  } catch (error) {
    // [Unverified] Could be corporate proxy certificate
    console.log('Fetch failed - possible proxy certificate issue:', error);
    
    // Cannot distinguish between:
    // - Invalid certificate
    // - Corporate proxy certificate
    // - Self-signed certificate
    // - Network error
    
    throw error;
  }
}
```

### Best Practices Without Pinning

#### 1. Use HTTPS Exclusively

```javascript
const API_BASE = 'https://api.example.com'; // Always HTTPS

async function apiRequest(endpoint) {
  return await fetch(`${API_BASE}${endpoint}`);
}
```

#### 2. Validate Response Integrity

```javascript
async function fetchWithIntegrityCheck(url, expectedHash) {
  const response = await fetch(url);
  const data = await response.arrayBuffer();
  
  // Calculate hash
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  
  if (hashHex !== expectedHash) {
    throw new Error('Integrity check failed');
  }
  
  return data;
}
```

#### 3. Monitor for Certificate Warnings

```javascript
// Log all fetch failures for analysis
async function fetchWithLogging(url) {
  try {
    return await fetch(url);
  } catch (error) {
    // Send to monitoring service
    sendToMonitoring({
      type: 'fetch_failure',
      url,
      error: error.message,
      timestamp: Date.now(),
      userAgent: navigator.userAgent
    });
    throw error;
  }
}
```

#### 4. Implement Content Security Policy

```javascript
// Server-side header configuration
const cspHeader = [
  "default-src 'self'",
  "connect-src 'self' https://api.example.com https://cdn.example.com",
  "script-src 'self' 'unsafe-inline'",
  "style-src 'self' 'unsafe-inline'",
  "img-src 'self' data: https:",
  "font-src 'self' data:",
  "upgrade-insecure-requests"
].join('; ');

// Set via server response headers
```

#### 5. Use Trusted CDNs

```javascript
// Use well-known CDNs with good security practices
const TRUSTED_SOURCES = [
  'https://cdn.jsdelivr.net',
  'https://cdnjs.cloudflare.com',
  'https://unpkg.com'
];

function isTrustedSource(url) {
  return TRUSTED_SOURCES.some(trusted => url.startsWith(trusted));
}
```

### Feature Detection

Check what security features are available:

```javascript
function detectSecurityFeatures() {
  return {
    https: window.location.protocol === 'https:',
    crypto: typeof crypto !== 'undefined' && typeof crypto.subtle !== 'undefined',
    csp: typeof SecurityPolicyViolationEvent !== 'undefined',
    hsts: document.location.protocol === 'https:', // [Inference] Likely has HSTS if on HTTPS
    sri: 'integrity' in document.createElement('script'),
    
    // Certificate pinning: NOT available in browsers
    certificatePinning: false,
    
    // Direct certificate access: NOT available
    certificateAccess: false
  };
}

console.log(detectSecurityFeatures());
```

### Server-Side Certificate Validation

For scenarios requiring certificate pinning, implement server-side proxy:

```javascript
// Client-side: fetch through your secure backend
async function fetchViaPinnedProxy(externalUrl, data) {
  // Your backend validates certificates and pins them
  const response = await fetch('https://your-backend.com/api/proxy', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      targetUrl: externalUrl,
      data: data
    })
  });
  
  return response;
}
```

Server-side (Node.js example):

```javascript
// Backend with certificate pinning (Node.js)
const https = require('https');
const crypto = require('crypto');

const PINNED_FINGERPRINT = 'AA:BB:CC:DD:EE:FF:...';

const agent = new https.Agent({
  checkServerIdentity: (host, cert) => {
    const fingerprint = crypto
      .createHash('sha256')
      .update(cert.raw)
      .digest('hex')
      .toUpperCase()
      .match(/.{2}/g)
      .join(':');
    
    if (fingerprint !== PINNED_FINGERPRINT) {
      throw new Error('Certificate pinning failed');
    }
  }
});
```

### Browser Extension Limitations

Even browser extensions cannot implement certificate pinning for web content due to security architecture restrictions.

### Summary

Certificate pinning in the Fetch API:

- ❌ Not available in web browsers
- ❌ No JavaScript API for certificate validation
- ❌ Cannot access certificate data
- ❌ Cannot override browser certificate decisions
- ✅ Available in native mobile apps
- ✅ Can be implemented server-side
- ✅ Alternative security measures available (HTTPS, CSP, SRI)

For applications requiring certificate pinning, implement the validation in:

1. Native mobile applications
2. Server-side proxy layer
3. Desktop applications with system-level access

Web browsers intentionally prevent certificate pinning to maintain security, user control, and compatibility with legitimate network configurations like corporate proxies.

---

