## Subresource Integrity


### Core Concept and Purpose

Subresource Integrity (SRI) is a security feature that enables browsers to verify that files fetched from external sources (particularly CDNs) have not been tampered with or unexpectedly modified. It works by allowing developers to provide a cryptographic hash that the browser must match against the fetched resource before executing or applying it.

When a resource is fetched, the browser computes the hash of the received content and compares it against the integrity attribute value. If the hashes match, the resource is deemed safe and is used. If they don't match, the browser refuses to execute the script, apply the stylesheet, or use the resource, and fires an error event instead.

The primary security concern SRI addresses is the risk of compromised third-party resources. CDNs, while convenient and performant, represent potential attack vectors. If an attacker gains access to a CDN or performs a man-in-the-middle attack, they could inject malicious code into resources served to millions of websites. SRI provides a defense mechanism against such supply chain attacks.

### Hash Generation and Format

#### Supported Hash Algorithms

SRI supports multiple cryptographic hash functions, with varying levels of security:

**SHA-256**

- 256-bit hash function
- Minimum recommended strength
- Widely supported across all browsers
- Format: `sha256-[base64-encoded-hash]`

**SHA-384**

- 384-bit hash function
- Stronger security than SHA-256
- Recommended for high-security scenarios
- Format: `sha384-[base64-encoded-hash]`

**SHA-512**

- 512-bit hash function
- Highest security level
- Largest hash size and computational overhead
- Format: `sha512-[base64-encoded-hash]`

The hash algorithm prefix (sha256, sha384, sha512) is case-insensitive, though lowercase is conventional.

#### Generating Hash Values

**Using OpenSSL**

```bash
# Generate SHA-384 hash
openssl dgst -sha384 -binary script.js | openssl base64 -A

# Generate SHA-512 hash
openssl dgst -sha512 -binary style.css | openssl base64 -A

# For multiple files
for file in *.js; do
  echo "$file: sha384-$(openssl dgst -sha384 -binary "$file" | openssl base64 -A)"
done
```

**Using Node.js**

```javascript
const crypto = require('crypto');
const fs = require('fs');

function generateSRI(filePath, algorithm = 'sha384') {
  const fileContent = fs.readFileSync(filePath);
  const hash = crypto.createHash(algorithm).update(fileContent).digest('base64');
  return `${algorithm}-${hash}`;
}

// Usage
const integrity = generateSRI('script.js', 'sha384');
console.log(integrity);
// Output: sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC
```

**Using Python**

```python
import hashlib
import base64

def generate_sri(file_path, algorithm='sha384'):
    with open(file_path, 'rb') as f:
        content = f.read()
    
    if algorithm == 'sha256':
        hash_obj = hashlib.sha256(content)
    elif algorithm == 'sha384':
        hash_obj = hashlib.sha384(content)
    elif algorithm == 'sha512':
        hash_obj = hashlib.sha512(content)
    
    hash_base64 = base64.b64encode(hash_obj.digest()).decode()
    return f"{algorithm}-{hash_base64}"

# Usage
integrity = generate_sri('script.js', 'sha384')
print(integrity)
```

**Using PowerShell**

```powershell
# Generate SHA-384 hash
$fileContent = Get-Content -Path "script.js" -Raw -Encoding Byte
$hash = [System.Security.Cryptography.SHA384]::Create().ComputeHash($fileContent)
$base64 = [System.Convert]::ToBase64String($hash)
Write-Output "sha384-$base64"
```

**Online Tools**

Several online SRI hash generators exist for quick generation:

- https://www.srihash.org/
- Browser DevTools can also compute hashes

#### Multiple Hash Values

SRI supports specifying multiple hash values in a single integrity attribute, separated by whitespace. This allows for algorithm agility and fallback options:

```html
<script src="https://cdn.example.com/library.js"
        integrity="sha256-abc123... sha384-def456... sha512-ghi789..."
        crossorigin="anonymous"></script>
```

The browser will validate against the strongest algorithm it supports. If the resource matches any of the provided hashes using any supported algorithm, it passes validation.

**Priority Order**

- The browser selects the strongest algorithm from those it supports
- SHA-512 > SHA-384 > SHA-256
- At least one hash must match using the selected algorithm

### Implementation Syntax

#### Script Elements

```html
<!-- Basic SRI implementation -->
<script src="https://cdn.example.com/jquery-3.6.0.min.js"
        integrity="sha384-KyZXEAg3QhqLMpG8r+8fhAXLRk2vvoC2f3B09zVXn8CA5QIVfZOJ3BCsw2P0p/We"
        crossorigin="anonymous"></script>

<!-- Multiple integrity values -->
<script src="https://cdn.example.com/library.js"
        integrity="sha256-abc123def456... sha384-ghi789jkl012..."
        crossorigin="anonymous"></script>

<!-- Inline scripts (not protected by SRI) -->
<script>
  // SRI does not apply to inline scripts
  console.log('This cannot be protected by SRI');
</script>
```

#### Link Elements (Stylesheets)

```html
<!-- Stylesheet with SRI -->
<link rel="stylesheet" 
      href="https://cdn.example.com/bootstrap-5.3.0.min.css"
      integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM"
      crossorigin="anonymous">

<!-- Preload with SRI -->
<link rel="preload"
      href="https://cdn.example.com/font.woff2"
      as="font"
      type="font/woff2"
      integrity="sha384-abc123..."
      crossorigin="anonymous">
```

#### Module Scripts

```html
<!-- ES6 modules with SRI -->
<script type="module"
        src="https://cdn.example.com/module.js"
        integrity="sha384-def456..."
        crossorigin="anonymous"></script>

<!-- Module with import maps -->
<script type="importmap">
{
  "imports": {
    "library": "https://cdn.example.com/library.js"
  }
}
</script>
<script type="module">
  // Note: Import maps don't support SRI directly
  import library from 'library';
</script>
```

#### Link Prefetch and Preload

```html
<!-- Prefetch with SRI -->
<link rel="prefetch"
      href="https://cdn.example.com/next-page-script.js"
      as="script"
      integrity="sha384-xyz789..."
      crossorigin="anonymous">

<!-- DNS prefetch (SRI not applicable) -->
<link rel="dns-prefetch" href="https://cdn.example.com">

<!-- Preconnect (SRI not applicable) -->
<link rel="preconnect" href="https://cdn.example.com" crossorigin>
```

### CORS Requirements

Subresource Integrity requires Cross-Origin Resource Sharing (CORS) to function properly with cross-origin resources. This requirement exists because SRI needs access to the raw resource bytes to compute the hash, which CORS restrictions would normally prevent.

#### The `crossorigin` Attribute

The `crossorigin` attribute is mandatory when using SRI with cross-origin resources. It has two valid values:

**anonymous**

```html
<script src="https://cdn.example.com/library.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>
```

- Sends requests without credentials (no cookies, HTTP authentication, or client-side certificates)
- Most common and recommended for public CDN resources
- Server must respond with `Access-Control-Allow-Origin: *` or the specific origin

**use-credentials**

```html
<script src="https://cdn.example.com/library.js"
        integrity="sha384-..."
        crossorigin="use-credentials"></script>
```

- Sends requests with credentials (cookies, authentication headers)
- Requires server to explicitly allow the origin (cannot use wildcard)
- Server must respond with `Access-Control-Allow-Origin: https://yourdomain.com` and `Access-Control-Allow-Credentials: true`

#### Server Configuration

**CDN/Server Requirements**

For SRI to work with cross-origin resources, the server must send appropriate CORS headers:

```http
Access-Control-Allow-Origin: *
```

Or for credential-based requests:

```http
Access-Control-Allow-Origin: https://yourdomain.com
Access-Control-Allow-Credentials: true
```

**Apache Configuration**

```apache
<IfModule mod_headers.c>
    # Allow all origins for public resources
    Header set Access-Control-Allow-Origin "*"
    
    # Or specific origin
    # Header set Access-Control-Allow-Origin "https://yourdomain.com"
</IfModule>
```

**Nginx Configuration**

```nginx
location ~* \.(js|css|woff2?)$ {
    add_header Access-Control-Allow-Origin "*";
    # Or specific origin
    # add_header Access-Control-Allow-Origin "https://yourdomain.com";
}
```

**Express.js (Node.js)**

```javascript
const express = require('express');
const app = express();

// Allow all origins
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  next();
});

// Or specific origin
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', 'https://yourdomain.com');
  next();
});
```

#### Same-Origin Resources

For same-origin resources, the `crossorigin` attribute is optional but recommended:

```html
<!-- Same-origin without crossorigin (works) -->
<script src="/assets/script.js" integrity="sha384-..."></script>

<!-- Same-origin with crossorigin (recommended) -->
<script src="/assets/script.js" 
        integrity="sha384-..." 
        crossorigin="anonymous"></script>
```

Including `crossorigin` for same-origin resources ensures consistent behavior and allows for potential CDN migration without code changes.

### Fetch API Integration

When using the Fetch API, SRI can be specified through the `integrity` option in the request configuration.

#### Basic Fetch with SRI

```javascript
fetch('https://cdn.example.com/data.json', {
  integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC',
  mode: 'cors',
  credentials: 'omit' // or 'include' for credentials
})
.then(response => {
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return response.json();
})
.then(data => {
  console.log('Data fetched and verified:', data);
})
.catch(error => {
  console.error('Fetch failed or integrity check failed:', error);
});
```

#### Integrity Validation Behavior

When integrity checking fails with the Fetch API:

- The promise rejects with a `TypeError`
- The response is not made available to the caller
- Network error is reported (indistinguishable from other network errors)

```javascript
async function fetchWithIntegrity(url, expectedHash) {
  try {
    const response = await fetch(url, {
      integrity: expectedHash,
      mode: 'cors'
    });
    
    // If we reach here, integrity check passed
    return await response.text();
  } catch (error) {
    // Could be network error OR integrity mismatch
    console.error('Fetch failed:', error.message);
    throw error;
  }
}
```

#### Multiple Resource Fetching

```javascript
const resources = [
  {
    url: 'https://cdn.example.com/library1.js',
    integrity: 'sha384-abc123...'
  },
  {
    url: 'https://cdn.example.com/library2.js',
    integrity: 'sha384-def456...'
  }
];

async function fetchAllResources(resources) {
  const promises = resources.map(resource =>
    fetch(resource.url, {
      integrity: resource.integrity,
      mode: 'cors',
      credentials: 'omit'
    }).then(r => r.text())
  );
  
  try {
    const results = await Promise.all(promises);
    console.log('All resources fetched and verified');
    return results;
  } catch (error) {
    console.error('One or more resources failed integrity check');
    throw error;
  }
}
```

#### Dynamic Script Loading

```javascript
async function loadScriptWithIntegrity(url, integrity) {
  try {
    // Fetch and verify
    const response = await fetch(url, {
      integrity: integrity,
      mode: 'cors',
      credentials: 'omit'
    });
    
    const scriptContent = await response.text();
    
    // Create and execute script
    const script = document.createElement('script');
    script.textContent = scriptContent;
    document.head.appendChild(script);
    
    console.log('Script loaded and executed successfully');
  } catch (error) {
    console.error('Failed to load script:', error);
  }
}

// Usage
loadScriptWithIntegrity(
  'https://cdn.example.com/library.js',
  'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC'
);
```

#### Service Worker Implementation

```javascript
// service-worker.js
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // Define resources with integrity hashes
  const integrityMap = {
    'https://cdn.example.com/library.js': 'sha384-abc123...',
    'https://cdn.example.com/style.css': 'sha384-def456...'
  };
  
  const integrity = integrityMap[event.request.url];
  
  if (integrity) {
    event.respondWith(
      fetch(event.request.url, {
        integrity: integrity,
        mode: 'cors',
        credentials: 'omit'
      }).catch(error => {
        console.error('Integrity check failed for:', event.request.url);
        // Return fallback or cached version
        return caches.match(event.request);
      })
    );
  }
});
```

### Browser Support and Fallbacks

#### Current Browser Support

Subresource Integrity is widely supported in modern browsers:

- **Chrome/Edge**: Version 45+ (2015)
- **Firefox**: Version 43+ (2015)
- **Safari**: Version 11.1+ (2018)
- **Opera**: Version 32+ (2015)
- **iOS Safari**: Version 11.3+ (2018)
- **Android Browser**: Version 45+ (2015)

Notably, Internet Explorer does not support SRI at all.

#### Feature Detection

```javascript
// Check if SRI is supported
function isSRISupported() {
  return 'integrity' in document.createElement('script');
}

if (isSRISupported()) {
  console.log('SRI is supported');
} else {
  console.warn('SRI is not supported by this browser');
}
```

#### Graceful Degradation Strategies

**Progressive Enhancement Approach**

```html
<!-- Browser will load with or without SRI support -->
<script src="https://cdn.example.com/library.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>

<!-- Fallback to local copy if CDN fails -->
<script>
  window.Library || document.write('<script src="/local/library.js"><\/script>');
</script>
```

**Conditional Loading Based on Support**

```javascript
function loadScript(url, integrity) {
  const script = document.createElement('script');
  script.src = url;
  script.crossOrigin = 'anonymous';
  
  // Only set integrity if supported
  if ('integrity' in script) {
    script.integrity = integrity;
  } else {
    console.warn('SRI not supported, loading without integrity check');
  }
  
  script.onerror = function() {
    console.error('Failed to load script');
    // Fallback to local version
    loadLocalScript();
  };
  
  document.head.appendChild(script);
}
```

**Multiple Fallback Strategy**

```html
<!-- Primary CDN with SRI -->
<script src="https://cdn1.example.com/library.js"
        integrity="sha384-primary..."
        crossorigin="anonymous"
        onerror="loadFromBackupCDN()"></script>

<script>
function loadFromBackupCDN() {
  const script = document.createElement('script');
  script.src = 'https://cdn2.example.com/library.js';
  script.integrity = 'sha384-backup...';
  script.crossOrigin = 'anonymous';
  script.onerror = loadFromLocal;
  document.head.appendChild(script);
}

function loadFromLocal() {
  const script = document.createElement('script');
  script.src = '/local/library.js';
  // No integrity check for local version
  document.head.appendChild(script);
}
</script>
```

#### Polyfill Considerations

There is no true polyfill for SRI because:

- The security guarantees cannot be replicated in JavaScript
- By the time JavaScript executes, potentially malicious code has already loaded
- The hash verification must happen at the browser level before execution

However, a detection and warning system can be implemented:

```javascript
// Warning system for browsers without SRI
(function() {
  if (!('integrity' in document.createElement('script'))) {
    console.warn('⚠️ SRI not supported. Resources may be vulnerable to tampering.');
    
    // Optionally notify server or analytics
    if (navigator.sendBeacon) {
      navigator.sendBeacon('/api/sri-not-supported', JSON.stringify({
        userAgent: navigator.userAgent,
        timestamp: Date.now()
      }));
    }
  }
})();
```

### Content Security Policy Integration

Subresource Integrity works in conjunction with Content Security Policy (CSP) to provide defense-in-depth security.

#### require-sri-for Directive

The `require-sri-for` CSP directive mandates SRI for specified resource types:

```http
Content-Security-Policy: require-sri-for script style;
```

This directive forces all script and style resources to have valid integrity attributes. Without them, the browser will refuse to load the resource.

**HTML Meta Tag**

```html
<meta http-equiv="Content-Security-Policy" 
      content="require-sri-for script style;">
```

**Server Header Examples**

Apache:

```apache
Header set Content-Security-Policy "require-sri-for script style;"
```

Nginx:

```nginx
add_header Content-Security-Policy "require-sri-for script style;";
```

Express.js:

```javascript
app.use((req, res, next) => {
  res.setHeader('Content-Security-Policy', 'require-sri-for script style;');
  next();
});
```

#### Combining CSP Directives

```http
Content-Security-Policy: 
  default-src 'self'; 
  script-src 'self' https://cdn.example.com; 
  style-src 'self' https://cdn.example.com; 
  require-sri-for script style;
```

This policy:

- Restricts scripts and styles to same-origin and specific CDN
- Requires all scripts and styles to have SRI
- Provides multiple layers of protection

#### CSP with Nonces and SRI

When using CSP nonces for inline scripts while requiring SRI for external resources:

```html
<!-- CSP Header -->
<!-- Content-Security-Policy: script-src 'nonce-random123'; require-sri-for script; -->

<!-- Inline script with nonce (SRI not applicable) -->
<script nonce="random123">
  console.log('Inline script allowed by nonce');
</script>

<!-- External script requires SRI -->
<script src="https://cdn.example.com/library.js"
        nonce="random123"
        integrity="sha384-..."
        crossorigin="anonymous"></script>
```

#### Violation Reporting

CSP violations, including SRI failures, can be reported:

```http
Content-Security-Policy: 
  require-sri-for script; 
  report-uri /csp-violation-report;
```

Report format for SRI violation:

```json
{
  "csp-report": {
    "document-uri": "https://example.com/page",
    "violated-directive": "require-sri-for",
    "effective-directive": "require-sri-for",
    "original-policy": "require-sri-for script;",
    "blocked-uri": "https://cdn.example.com/library.js",
    "status-code": 200,
    "source-file": "https://example.com/page",
    "line-number": 42,
    "column-number": 12
  }
}
```

### Security Considerations

#### Protection Scope

**What SRI Protects Against**

- Compromised CDN serving modified files
- Man-in-the-middle attacks modifying resources in transit
- Accidental file corruption during transmission
- BGP hijacking affecting CDN routes
- DNS spoofing attacks redirecting to malicious servers

**What SRI Does Not Protect Against**

- Vulnerabilities in the library itself
- Malicious code intentionally included in the original library version
- Inline scripts (not subject to SRI)
- Resources loaded dynamically without integrity checks
- XSS attacks injecting code directly into the page
- Compromised website serving malicious inline content

#### Hash Algorithm Selection

**SHA-256**

- Minimum acceptable security level
- Faster computation
- Smaller hash size (44 characters base64)
- Suitable for most use cases

**SHA-384**

- Recommended balance of security and performance
- 128-bit security level
- Moderate hash size (64 characters base64)
- Industry standard for SRI

**SHA-512**

- Highest security level
- 256-bit security level
- Largest hash size (88 characters base64)
- Overkill for most scenarios but useful for critical applications

**Algorithm Agility**

Specifying multiple algorithms provides future-proofing:

```html
<script src="https://cdn.example.com/library.js"
        integrity="sha384-current... sha512-future..."
        crossorigin="anonymous"></script>
```

If a vulnerability is discovered in SHA-384, browsers can fall back to SHA-512 without requiring code changes.

#### Hash Update Management

**Challenges**

- Library updates change file content, invalidating hashes
- Automated updates break SRI-protected resources
- Manual hash regeneration required for each version

**Version Pinning Strategy**

```html
<!-- Pin to specific version -->
<script src="https://cdn.example.com/library@3.6.0/library.min.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>

<!-- Avoid version ranges that auto-update -->
<!-- BAD: This will break when the file updates -->
<script src="https://cdn.example.com/library@3/library.min.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>
```

**Automated Hash Management**

Build tool integration:

```javascript
// Webpack plugin
const SriPlugin = require('webpack-subresource-integrity');

module.exports = {
  plugins: [
    new SriPlugin({
      hashFuncNames: ['sha384'],
      enabled: process.env.NODE_ENV === 'production'
    })
  ]
};
```

```javascript
// Gulp task
const gulp = require('gulp');
const sri = require('gulp-sri');

gulp.task('sri', () => {
  return gulp.src('dist/index.html')
    .pipe(sri({
      algorithms: ['sha384']
    }))
    .pipe(gulp.dest('dist'));
});
```

**Version Tracking System**

```javascript
// sri-config.json
{
  "resources": [
    {
      "url": "https://cdn.example.com/jquery-3.6.0.min.js",
      "integrity": "sha384-...",
      "version": "3.6.0",
      "lastUpdated": "2024-01-15"
    },
    {
      "url": "https://cdn.example.com/bootstrap-5.3.0.min.css",
      "integrity": "sha384-...",
      "version": "5.3.0",
      "lastUpdated": "2024-01-15"
    }
  ]
}
```

#### Privacy Implications

**Timing Attacks**

SRI validation timing could theoretically leak information:

- Hash computation time varies with file size
- Network timing patterns might reveal resource identity
- Cache status might be inferred from timing differences

In practice, these are minimal concerns as:

- Timing variations are small and noisy
- Other factors dominate timing (network latency, server response time)
- Browsers implement timing attack mitigations

**Cache Partitioning**

Modern browsers implement cache partitioning, which affects SRI-protected resources:

- Resources are cached per-origin
- Same CDN resource loaded by different sites requires separate cache entries
- SRI doesn't change this behavior but is compatible with partitioned caches

#### Error Handling Security

**Information Disclosure**

SRI failures should not leak sensitive information:

```javascript
// POOR: Reveals internal URLs
fetch(url, { integrity: hash })
  .catch(error => {
    console.error('Failed to load: ' + url, error);
  });

// BETTER: Generic error message
fetch(url, { integrity: hash })
  .catch(error => {
    console.error('Resource integrity check failed');
    // Log details server-side for debugging
    logToServer({ type: 'sri-failure', timestamp: Date.now() });
  });
```

**Graceful Degradation**

Avoid cascade failures:

```javascript
async function loadCriticalResource(url, integrity) {
  try {
    const response = await fetch(url, {
      integrity: integrity,
      mode: 'cors'
    });
    return await response.text();
  } catch (error) {
    // Don't let SRI failure break entire application
    console.error('SRI check failed, using fallback');
    return loadFallbackResource();
  }
}
```

### Performance Implications

#### Hash Computation Overhead

**Browser-Side Performance**

The browser must compute hashes for integrity checking:

- Hash computation is fast (milliseconds for typical resources)
- Happens during resource download (parallel processing)
- Negligible impact on page load time
- Cached resources skip recomputation

**Benchmark Example**

```javascript
// Measuring hash computation time
async function benchmarkHashComputation(url) {
  const start = performance.now();
  
  const response = await fetch(url);
  const buffer = await response.arrayBuffer();
  
  const hashBuffer = await crypto.subtle.digest('SHA-384', buffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashBase64 = btoa(String.fromCharCode.apply(null, hashArray));
  
  const end = performance.now();
  console.log(`Hash computation took ${end - start}ms`);
  console.log(`File size: ${buffer.byteLength} bytes`);
  console.log(`Hash: sha384-${hashBase64}`);
}
```

Typical results:

- Small file (10 KB): < 1ms
- Medium file (100 KB): 1-3ms
- Large file (1 MB): 5-15ms

#### Network Performance

**Additional Bytes**

Integrity attributes add to HTML document size:

- SHA-256: ~44 characters
- SHA-384: ~64 characters
- SHA-512: ~88 characters
- Plus attribute name and quotes: ~80-110 bytes total per resource

For a page with 10 external resources using SHA-384:

- Additional size: ~800 bytes
- Negligible impact compared to typical HTML size
- Well worth the security benefit

**Caching Behavior**

SRI affects caching positively:

- Resources with integrity hashes can be aggressively cached
- No need to revalidate if integrity matches
- Reduces unnecessary network requests

```html
<!-- Browser can cache confidently -->
<script src="https://cdn.example.com/library.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>

<!-- Cache-Control header can be more aggressive -->
```

Server header:

```http
Cache-Control: public, max-age=31536000, immutable
```

The `immutable` directive works well with SRI, as the integrity hash guarantees the content hasn't changed.

#### CDN Considerations

**Multiple CDN Strategy**

Using multiple CDN providers with SRI:

```html
<script src="https://cdn1.example.com/library.js"
        integrity="sha384-..."
        crossorigin="anonymous"
        onerror="this.onerror=null; this.src='https://cdn2.example.com/library.js'"></script>
```

This provides:

- Redundancy if primary CDN fails
- Same integrity hash works across CDNs (same file)
- Automatic fallback with maintained security

**CDN Best Practices**

- Use CDNs that support CORS properly
- Verify CDN sends correct `Access-Control-Allow-Origin` headers
- Choose CDNs with good uptime records
- Test fallback chains before production deployment

### Build Pipeline Integration

#### Webpack Configuration

```javascript
// webpack.config.js
const HtmlWebpackPlugin = require('html-webpack-plugin');
const SubresourceIntegrityPlugin = require('webpack-subresource-integrity');

module.exports = {
  output: {
    filename: '[name].[contenthash].js',
    crossOriginLoading: 'anonymous'
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: 'src/index.html'
    }),
    new SubresourceIntegrityPlugin({
      hashFuncNames: ['sha384', 'sha512'],
      enabled: process.env.NODE_ENV === 'production'
    })
  ]
};
```

Generated HTML:

```html
<script src="/main.a1b2c3d4.js" 
        integrity="sha384-... sha512-..." 
        crossorigin="anonymous"></script>
```

#### Gulp Integration

```javascript
const gulp = require('gulp');
const sri = require('gulp-sri-hash');

gulp.task('generate-sri', () => {
  return gulp.src('dist/**/*.html')
    .pipe(sri({
      algo: 'sha384',
      crossOrigin: 'anonymous'
    }))
    .pipe(gulp.dest('dist'));
});
```

#### Grunt Integration

```javascript
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-sri');
  
  grunt.initConfig({
    sri: {
      generate: {
        src: ['dist/**/*.html'],
        options: {
          algorithms: ['sha384'],
          crossorigin: 'anonymous'
        }
      }
    }
  });
  
  grunt.registerTask('default', ['sri']);
};
```

#### NPM Scripts

```json
{
  "scripts": {
    "build": "webpack --mode production",
    "postbuild": "node scripts/generate-sri.js",
    "verify-sri": "node scripts/verify-sri.js"
  }
}
```

```javascript
// scripts/generate-sri.js
const fs = require('fs');
const crypto = require('crypto');
const glob = require('glob');

function generateSRI(filePath) {
  const content = fs.readFileSync(filePath);
  const hash = crypto
    .createHash('sha384')
    .update(content)
    .digest('base64');

  return `sha384-${hash}`;
}

// Find all HTML files
glob('dist/**/*.html', (err, files) => {
  if (err) {
    throw err;
  }

  files.forEach((file) => {
    let html = fs.readFileSync(file, 'utf8');

    // Find script and link tags, add integrity
    html = html.replace(
      /<(script|link)[^>]+src=["']([^"']+)["'][^>]*>/g,
      (match, tag, src) => {
        if (src.startsWith('http')) {
          // External resources – integrity should be pre-generated
          return match;
        }

        // Local resources
        const integrity = generateSRI(`dist/${src}`);
        return match.replace(
          '>',
          ` integrity="${integrity}" crossorigin="anonymous">`
        );
      }
    );

    fs.writeFileSync(file, html);
  });
});

````

#### Continuous Integration

```yaml
# .github/workflows/build.yml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install dependencies
        run: npm install
      
      - name: Build
        run: npm run build
      
      - name: Generate SRI
        run: npm run generate-sri
      
      - name: Verify SRI
        run: npm run verify-sri
      
      - name: Deploy
        run: npm run deploy
````

### Testing and Validation

#### Manual Verification

**Browser DevTools**

Testing SRI in browser console:

```javascript
// Check if element has integrity attribute
const script = document.querySelector('script[src*="cdn"]');
console.log('Integrity:', script.integrity);
console.log('Crossorigin:', script.crossOrigin);

// Test integrity with Fetch API
async function testIntegrity(url, integrity) {
  try {
    const response = await fetch(url, {
      integrity: integrity,
      mode: 'cors'
    });
    console.log('✓ Integrity check passed');
    return true;
  } catch (error) {
    console.error('✗ Integrity check failed:', error);
    return false;
  }
}

// Usage
testIntegrity(
  'https://cdn.example.com/library.js',
  'sha384-...'
);
```

**Network Panel Verification**

In browser DevTools Network panel:

1. Load page with SRI-protected resources
2. Check each resource:
    - Status should be 200 OK
    - No console errors about integrity
    - Response headers include CORS headers
3. Modify integrity hash to incorrect value
4. Reload page
5. Verify resource fails to load with integrity error

#### Automated Testing

**Jest Test Suite**

```javascript
// sri.test.js
const fs = require('fs');
const crypto = require('crypto');
const { JSDOM } = require('jsdom');

describe('Subresource Integrity Tests', () => {
  let dom;
  
  beforeAll(() => {
    const html = fs.readFileSync('dist/index.html', 'utf8');
    dom = new JSDOM(html);
  });
  
  test('All external scripts have integrity attribute', () => {
    const scripts = dom.window.document.querySelectorAll('script[src^="http"]');
    scripts.forEach(script => {
      expect(script.integrity).toBeTruthy();
      expect(script.integrity).toMatch(/^sha(256|384|512)-/);
    });
  });
  
  test('All external stylesheets have integrity attribute', () => {
    const links = dom.window.document.querySelectorAll('link[rel="stylesheet"][href^="http"]');
    links.forEach(link => {
      expect(link.integrity).toBeTruthy();
      expect(link.integrity).toMatch(/^sha(256|384|512)-/);
    });
  });
  
  test('All external resources have crossorigin attribute', () => {
    const elements = dom.window.document.querySelectorAll('[src^="http"][integrity], [href^="http"][integrity]');
    elements.forEach(element => {
      expect(element.crossOrigin).toBe('anonymous');
    });
  });
  
  test('Local file integrity hashes are correct', () => {
    const scripts = dom.window.document.querySelectorAll('script[src^="/"]');
    scripts.forEach(script => {
      if (script.integrity) {
        const filePath = `dist${script.src}`;
        const content = fs.readFileSync(filePath);
        const [algo, expectedHash] = script.integrity.split('-');
        const actualHash = crypto.createHash(algo).update(content).digest('base64');
        expect(actualHash).toBe(expectedHash);
      }
    });
  });
});
```

**Playwright E2E Tests**

```javascript
// e2e/sri.spec.js
const { test, expect } = require('@playwright/test');

test.describe('SRI Protection', () => {
  test('should load page successfully with valid SRI', async ({ page }) => {
    await page.goto('https://example.com');
    
    // Check no console errors
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });
    
    await page.waitForLoadState('networkidle');
    expect(errors).toHaveLength(0);
  });
  
  test('should fail to load resource with incorrect SRI', async ({ page }) => {
    // Intercept and modify integrity hash
    await page.route('**/*.js', route => {
      const response = route.fetch();
      // In real test, modify HTML to have wrong hash
    });
    
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error' && msg.text().includes('integrity')) {
        errors.push(msg.text());
      }
    });
    
    await page.goto('https://example.com');
    expect(errors.length).toBeGreaterThan(0);
  });
});
```

#### Security Audit Tools

**Lighthouse Audit**

```javascript
// Run Lighthouse with SRI checks
const lighthouse = require('lighthouse');
const chromeLauncher = require('chrome-launcher');

async function auditSRI(url) {
  const chrome = await chromeLauncher.launch({ chromeFlags: ['--headless'] });
  
  const options = {
    logLevel: 'info',
    output: 'json',
    onlyCategories: ['best-practices'],
    port: chrome.port
  };
  
  const runnerResult = await lighthouse(url, options);
  const audits = runnerResult.lhr.audits;
  
  // Check external scripts audit
  const externalScripts = audits['external-anchors-use-rel-noopener'];
  console.log('SRI Status:', externalScripts);
  
  await chrome.kill();
}
```

**Custom SRI Validator**

```javascript
const https = require('https');
const crypto = require('crypto');

async function validateSRI(url, expectedIntegrity) {
  return new Promise((resolve, reject) => {
    https.get(url, response => {
      const chunks = [];
      
      response.on('data', chunk => chunks.push(chunk));
      
      response.on('end', () => {
        const content = Buffer.concat(chunks);
        const [algo, expectedHash] = expectedIntegrity.split('-');
        const actualHash = crypto.createHash(algo).update(content).digest('base64');
        
        if (actualHash === expectedHash) {
          resolve({ valid: true, url, integrity: expectedIntegrity });
        } else {
          reject({
            valid: false,
            url,
            expected: expectedIntegrity,
            actual: `${algo}-${actualHash}`
          });
        }
      });
    }).on('error', reject);
  });
}

// Usage
validateSRI(
  'https://cdn.example.com/library.js',
  'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC'
)
.then(result => console.log('✓ Valid:', result))
.catch(error => console.error('✗ Invalid:', error));
```

### Real-World Implementation Examples

#### Bootstrap CDN

```html
<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" 
      rel="stylesheet" 
      integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" 
      crossorigin="anonymous">

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" 
        integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" 
        crossorigin="anonymous"></script>
```

#### jQuery CDN

```html
<!-- jQuery Core -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"
        integrity="sha384-1H217gwSVyLSIfaLxHbE7dRb3v4mYCKbpQvzx0cegeju1MVsGrX5xXxAvs/HgeFs"
        crossorigin="anonymous"></script>

<!-- jQuery UI -->
<link rel="stylesheet" 
      href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css"
      integrity="sha384-TbH77 േhJR3SvZCxMSp9aWkJn5KfVqZ/c6xOEjJkCDEbY+1o9oHPyKODYE9U5xE"
      crossorigin="anonymous">

<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"
        integrity="sha384-aumgKJp8vMwUCqQwi8wWnfJDJ9tPvHJQm1LJzQwZhLCQx4A0xJPHI0c9AKpWqv3f"
        crossorigin="anonymous"></script>
```

#### Font Awesome

```html
<!-- Font Awesome CSS -->
<link rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
      integrity="sha384-iw3OoTErCYJq0xO0E++TqC1FvP4r+kFI3WuLFLGwLZfXm05F2ZLDlKkTSqmQdJHy"
      crossorigin="anonymous">

<!-- Font Awesome Webfonts (preload) -->
<link rel="preload"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/webfonts/fa-solid-900.woff2"
      as="font"
      type="font/woff2"
      integrity="sha384-EvSTjfC1Z7XFznXBL2fxvRLLZ6YdQqRpMQcMvnz7RK7m9E5jt0DfXJMxGPdUqXh9"
      crossorigin="anonymous">
```

#### React from CDN

```html
<!-- React Development -->
<script crossorigin 
        src="https://unpkg.com/react@18/umd/react.development.js"
        integrity="sha384-..."></script>
<script crossorigin 
        src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"
        integrity="sha384-..."></script>

<!-- React Production -->
<script crossorigin 
        src="https://unpkg.com/react@18/umd/react.production.min.js"
        integrity="sha384-KxEF3FJ3JxqG7DvCXQ8T1F5Q6yJ8b9YxNk6yI8N8G5mR6Kj2Lq4JQ7C5Sw8M9Tn"
        crossorigin="anonymous"></script>
<script crossorigin 
        src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"
        integrity="sha384-J9YXuB8bCzqS2xqJ9c4eJYQp1nLqF6YvPbCzBnXq2nJqF6YvPbCzBnXq2nJq6Yv"
        crossorigin="anonymous"></script>
```

#### Google Fonts (Limited SRI Support)

Google Fonts don't provide SRI hashes because fonts may be served differently based on browser capabilities. Alternative approach:

```html
<!-- Self-host fonts with SRI -->
<link rel="preload"
      href="/fonts/roboto-v30-latin-regular.woff2"
      as="font"
      type="font/woff2"
      integrity="sha384-abc123..."
      crossorigin="anonymous">

<style>
@font-face {
  font-family: 'Roboto';
  src: url('/fonts/roboto-v30-latin-regular.woff2') format('woff2');
}
</style>
```

### Advanced Patterns and Techniques

#### Dynamic Integrity Generation

For applications that generate HTML dynamically:

```javascript
// Server-side (Node.js/Express)
const crypto = require('crypto');
const fs = require('fs');

function generateIntegrityHash(filePath, algorithm = 'sha384') {
  const content = fs.readFileSync(filePath);
  const hash = crypto.createHash(algorithm).update(content).digest('base64');
  return `${algorithm}-${hash}`;
}

app.get('/', (req, res) => {
  const scriptHash = generateIntegrityHash('./public/app.js');
  const styleHash = generateIntegrityHash('./public/style.css');
  
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <link rel="stylesheet" 
            href="/style.css" 
            integrity="${styleHash}"
            crossorigin="anonymous">
    </head>
    <body>
      <script src="/app.js" 
              integrity="${scriptHash}"
              crossorigin="anonymous"></script>
    </body>
    </html>
  `);
});
```

#### Subresource Integrity with Service Workers

Advanced caching strategy with SRI:

```javascript
// service-worker.js
const RESOURCE_CACHE = 'resources-v1';

const resources = [
  {
    url: 'https://cdn.example.com/library.js',
    integrity: 'sha384-abc123...'
  },
  {
    url: 'https://cdn.example.com/style.css',
    integrity: 'sha384-def456...'
  }
];

// Install event - prefetch and verify
self.addEventListener('install', event => {
  event.waitUntil(
    Promise.all(
      resources.map(resource =>
        fetch(resource.url, {
          integrity: resource.integrity,
          mode: 'cors'
        })
        .then(response => {
          if (response.ok) {
            return caches.open(RESOURCE_CACHE)
              .then(cache => cache.put(resource.url, response));
          }
          throw new Error(`Failed to fetch ${resource.url}`);
        })
      )
    )
  );
});

// Fetch event - serve from cache with integrity verification
self.addEventListener('fetch', event => {
  const resource = resources.find(r => r.url === event.request.url);
  
  if (resource) {
    event.respondWith(
      caches.match(event.request)
        .then(cachedResponse => {
          if (cachedResponse) {
            // Verify cached response still matches integrity
            return cachedResponse.clone().arrayBuffer()
              .then(buffer => {
                return crypto.subtle.digest('SHA-384', buffer)
                  .then(hashBuffer => {
                    const hashArray = Array.from(new Uint8Array(hashBuffer));
                    const hashBase64 = btoa(String.fromCharCode.apply(null, hashArray));
                    const computedIntegrity = `sha384-${hashBase64}`;
                    
                    if (computedIntegrity === resource.integrity) {
                      return cachedResponse;
                    } else {
                      // Cache corruption detected, fetch fresh copy
                      console.warn('Cache integrity mismatch, refetching');
                      return fetch(event.request, {
                        integrity: resource.integrity,
                        mode: 'cors'
                      });
                    }
                  });
              });
          }
          
          // Not in cache, fetch with integrity check
          return fetch(event.request, {
            integrity: resource.integrity,
            mode: 'cors'
          });
        })
    );
  }
});
```

#### Conditional SRI Based on Environment

```javascript
// config.js
const environment = process.env.NODE_ENV || 'development';

const cdnConfig = {
  development: {
    useIntegrity: false, // Easier debugging
    useCDN: false // Local files
  },
  staging: {
    useIntegrity: true,
    useCDN: true
  },
  production: {
    useIntegrity: true,
    useCDN: true
  }
};

function generateScriptTag(src, localSrc, integrity) {
  const config = cdnConfig[environment];
  const url = config.useCDN ? src : localSrc;
  const integrityAttr = config.useIntegrity && integrity 
    ? ` integrity="${integrity}"` 
    : '';
  const crossoriginAttr = config.useCDN ? ' crossorigin="anonymous"' : '';
  
  return `<script src="${url}"${integrityAttr}${crossoriginAttr}></script>`;
}

// Usage
const scriptTag = generateScriptTag(
  'https://cdn.example.com/library.js',
  '/local/library.js',
  'sha384-abc123...'
);
```

#### Progressive Enhancement with SRI

```html
<!DOCTYPE html>
<html>
<head>
  <!-- Critical CSS inline (no SRI) -->
  <style>
    /* Critical above-the-fold styles */
  </style>
  
  <!-- Async load full CSS with SRI -->
  <link rel="preload"
        href="https://cdn.example.com/style.css"
        as="style"
        integrity="sha384-..."
        crossorigin="anonymous"
        onload="this.onload=null;this.rel='stylesheet'">
  
  <!-- Fallback for no-JS -->
  <noscript>
    <link rel="stylesheet" 
          href="https://cdn.example.com/style.css"
          integrity="sha384-..."
          crossorigin="anonymous">
  </noscript>
</head>
<body>
  <!-- Content -->
  
  <!-- Async scripts with SRI -->
  <script async
          src="https://cdn.example.com/analytics.js"
          integrity="sha384-..."
          crossorigin="anonymous"></script>
  
  <!-- Critical scripts defer with SRI -->
  <script defer
          src="https://cdn.example.com/app.js"
          integrity="sha384-..."
          crossorigin="anonymous"></script>
</body>
</html>
```

### Troubleshooting Common Issues

#### Integrity Mismatch Errors

**Symptom**: Resource fails to load with console error

```
Failed to find a valid digest in the 'integrity' attribute for resource 'https://cdn.example.com/library.js'
```

**Causes and Solutions**:

1. **Incorrect Hash**
    
    - Regenerate hash from actual file
    - Ensure no whitespace or encoding issues
    - Verify you're hashing the correct file version
2. **File Modified**
    
    - CDN updated the file
    - Pin to specific version in URL
    - Regenerate hash for new version
3. **Encoding Issues**
    
    - File served with different encoding
    - Check Content-Encoding headers
    - Generate hash from actual transmitted bytes

**Debug Script**:

```javascript
async function debugIntegrity(url, expectedIntegrity) {
  const response = await fetch(url);
  const buffer = await response.arrayBuffer();
  
  const [algo, expectedHash] = expectedIntegrity.split('-');
  const hashBuffer = await crypto.subtle.digest(
    algo.toUpperCase().replace('SHA', 'SHA-'),
    buffer
  );
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const actualHash = btoa(String.fromCharCode.apply(null, hashArray));
  
  console.log('Expected:', expectedIntegrity);
  console.log('Actual:', `${algo}-${actualHash}`);
  console.log('Match:', expectedHash === actualHash);
  console.log('File size:', buffer.byteLength);
  console.log('Content-Type:', response.headers.get('Content-Type'));
  console.log('Content-Encoding:', response.headers.get('Content-Encoding'));
}
```

#### CORS Issues

**Symptom**: Resource loads without SRI or throws CORS error

```
Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource
```

**Solutions**:

1. **Add crossorigin attribute**

```html
<!-- Before (doesn't work) -->
<script src="https://cdn.example.com/library.js"
        integrity="sha384-..."></script>

<!-- After (works) -->
<script src="https://cdn.example.com/library.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>
```

2. **Verify server CORS headers**

```bash
curl -I https://cdn.example.com/library.js
```

Should include:

```http
Access-Control-Allow-Origin: *
```

3. **Contact CDN provider** if headers missing

#### Browser Compatibility Issues

**Symptom**: SRI works in some browsers but not others

**Solutions**:

1. **Feature detection and fallback**

```javascript
if ('integrity' in document.createElement('script')) {
  // Use SRI
  loadWithIntegrity(url, hash);
} else {
  // Fallback without SRI
  console.warn('SRI not supported');
  loadWithoutIntegrity(url);
}
```

2. **Polyfill alternatives** (limited effectiveness)

```javascript
// Warning system for old browsers
if (!window.crypto || !window.crypto.subtle) {
  console.error('Crypto API not available - SRI may not work');
}
```

#### Performance Degradation

**Symptom**: Page load slower with SRI

**Investigation**:

1. **Measure actual impact**

```javascript
performance.mark('sri-start');

const script = document.createElement('script');
script.src = url;
script.integrity = hash;
script.crossOrigin = 'anonymous';
script.onload = () => {
  performance.mark('sri-end');
  performance.measure('sri-load', 'sri-start', 'sri-end');
  const measure = performance.getEntriesByName('sri-load')[0];
  console.log(`SRI load took: ${measure.duration}ms`);
};

document.head.appendChild(script);
```

2. **Optimize hash algorithm**

```html
<!-- Use SHA-384 instead of SHA-512 for better performance -->
<script src="..."
        integrity="sha384-..."
        crossorigin="anonymous"></script>
```

3. **Preload resources**

```html
<link rel="preload"
      href="https://cdn.example.com/library.js"
      as="script"
      integrity="sha384-..."
      crossorigin="anonymous">
```

#### Cache-Related Issues

**Symptom**: Updated file with old integrity hash

**Solutions**:

1. **Cache busting**

```html
<!-- Add version or hash to filename -->
<script src="https://cdn.example.com/library-v2.0.1.js"
        integrity="sha384-new-hash..."
        crossorigin="anonymous"></script>

<!-- Or query parameter -->
<script src="https://cdn.example.com/library.js?v=2.0.1"
        integrity="sha384-new-hash..."
        crossorigin="anonymous"></script>
```

2. **Clear service worker cache**

```javascript
// In service worker
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CURRENT_CACHE) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
```

3. **Update process**

```javascript
// Deployment script
const updateIntegrity = async () => {
  // 1. Generate new hash
  const newHash = await generateHash('library.js');
  
  // 2. Update HTML
  updateHTML(newHash);
  
  // 3. Clear CDN cache
  await purgeCDNCache();
  
  // 4. Increment service worker version
  bumpServiceWorkerVersion();
};
```

Subresource Integrity provides robust protection against compromised third-party resources through cryptographic verification. While it adds minimal overhead and requires careful hash management, the security benefits—particularly against supply chain attacks—make it an essential practice for modern web applications relying on CDN-hosted resources. Proper implementation requires attention to CORS configuration, hash generation workflows, and integration with build pipelines, but these investments pay dividends in enhanced security and user trust.

---

