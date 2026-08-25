## Integrity Checks


### Subresource Integrity (SRI) Basics

Subresource Integrity allows browsers to verify that fetched resources haven't been tampered with by comparing the resource against a cryptographic hash.

```javascript
fetch('https://cdn.example.com/script.js', {
  integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC',
  method: 'GET'
})
.then(response => {
  if (!response.ok) {
    throw new Error('Integrity check failed or resource not found');
  }
  return response.text();
})
.then(content => console.log('Resource verified:', content));
```

### Generating Integrity Hashes

#### Using Node.js Crypto Module

```javascript
const crypto = require('crypto');
const fs = require('fs');

function generateIntegrityHash(filePath, algorithm = 'sha384') {
  const content = fs.readFileSync(filePath);
  const hash = crypto.createHash(algorithm).update(content).digest('base64');
  return `${algorithm}-${hash}`;
}

// Usage
const integrity = generateIntegrityHash('./script.js');
console.log(integrity);
// Output: sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC
```

#### Using Web Crypto API

```javascript
async function generateIntegrityFromResponse(response) {
  const content = await response.arrayBuffer();
  const hashBuffer = await crypto.subtle.digest('SHA-384', content);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashBase64 = btoa(String.fromCharCode(...hashArray));
  return `sha384-${hashBase64}`;
}

// Usage
fetch('https://cdn.example.com/file.js')
  .then(response => response.clone())
  .then(generateIntegrityFromResponse)
  .then(hash => console.log('Integrity hash:', hash));
```

### Multiple Hash Algorithms

#### Supporting Multiple Algorithms

```javascript
fetch('https://cdn.example.com/library.js', {
  integrity: 'sha256-hash1 sha384-hash2 sha512-hash3',
  method: 'GET'
})
.then(response => response.text());
```

The browser will use the strongest algorithm it supports (sha512 > sha384 > sha256).

#### Generating Multiple Hashes

```javascript
async function generateMultipleHashes(content) {
  const algorithms = ['SHA-256', 'SHA-384', 'SHA-512'];
  const buffer = new TextEncoder().encode(content);
  
  const hashes = await Promise.all(
    algorithms.map(async algo => {
      const hashBuffer = await crypto.subtle.digest(algo, buffer);
      const hashArray = Array.from(new Uint8Array(hashBuffer));
      const hashBase64 = btoa(String.fromCharCode(...hashArray));
      const algoName = algo.toLowerCase().replace('-', '');
      return `${algoName}-${hashBase64}`;
    })
  );
  
  return hashes.join(' ');
}

// Usage
const content = 'console.log("Hello World");';
generateMultipleHashes(content)
  .then(integrity => console.log(integrity));
```

### CORS and Integrity

#### crossorigin Attribute Requirement

```javascript
// When using integrity with cross-origin requests
fetch('https://cdn.example.com/resource.js', {
  integrity: 'sha384-hash',
  mode: 'cors',
  credentials: 'omit'
})
.then(response => {
  // CORS headers must be present on the server
  return response.text();
});
```

#### Handling CORS Errors

```javascript
async function fetchWithIntegrity(url, integrity) {
  try {
    const response = await fetch(url, {
      integrity: integrity,
      mode: 'cors'
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    return await response.text();
    
  } catch (error) {
    if (error.name === 'TypeError') {
      console.error('CORS or integrity check failed');
    }
    throw error;
  }
}
```

### Integrity Check Failures

#### Detecting Integrity Failures

```javascript
fetch('https://cdn.example.com/script.js', {
  integrity: 'sha384-incorrectHash'
})
.then(response => {
  // This won't execute if integrity fails
  console.log('Integrity passed');
  return response.text();
})
.catch(error => {
  // Integrity failure throws a TypeError
  console.error('Integrity check failed:', error.message);
});
```

#### Fallback Strategy

```javascript
async function fetchWithFallback(primaryUrl, fallbackUrl, integrity) {
  try {
    const response = await fetch(primaryUrl, {
      integrity: integrity
    });
    return await response.text();
    
  } catch (primaryError) {
    console.warn('Primary resource failed, trying fallback');
    
    try {
      const fallbackResponse = await fetch(fallbackUrl, {
        integrity: integrity
      });
      return await fallbackResponse.text();
      
    } catch (fallbackError) {
      throw new Error('Both primary and fallback resources failed');
    }
  }
}

// Usage
fetchWithFallback(
  'https://cdn1.example.com/lib.js',
  'https://cdn2.example.com/lib.js',
  'sha384-hash'
);
```

### Custom Integrity Verification

#### Manual Hash Verification

```javascript
async function fetchAndVerify(url, expectedHash, algorithm = 'SHA-384') {
  const response = await fetch(url);
  const content = await response.arrayBuffer();
  
  const hashBuffer = await crypto.subtle.digest(algorithm, content);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashBase64 = btoa(String.fromCharCode(...hashArray));
  const actualHash = `${algorithm.toLowerCase().replace('-', '')}-${hashBase64}`;
  
  if (actualHash !== expectedHash) {
    throw new Error('Integrity verification failed');
  }
  
  return new Response(content);
}

// Usage
fetchAndVerify(
  'https://example.com/data.json',
  'sha384-expectedHashValue'
)
.then(response => response.json())
.then(data => console.log('Verified data:', data));
```

#### Verifying JSON Responses

```javascript
async function fetchJsonWithIntegrity(url, expectedHash) {
  const response = await fetch(url);
  const text = await response.text();
  
  // Compute hash of the text content
  const buffer = new TextEncoder().encode(text);
  const hashBuffer = await crypto.subtle.digest('SHA-384', buffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashBase64 = btoa(String.fromCharCode(...hashArray));
  const computedHash = `sha384-${hashBase64}`;
  
  if (computedHash !== expectedHash) {
    throw new Error('JSON integrity check failed');
  }
  
  return JSON.parse(text);
}
```

### Integrity with Dynamic Content

#### Caching with Integrity

```javascript
class IntegrityCache {
  constructor() {
    this.cache = new Map();
  }
  
  async fetch(url, integrity) {
    const cacheKey = `${url}:${integrity}`;
    
    if (this.cache.has(cacheKey)) {
      console.log('Returning cached content');
      return this.cache.get(cacheKey);
    }
    
    const response = await fetch(url, { integrity });
    const content = await response.text();
    
    this.cache.set(cacheKey, content);
    return content;
  }
  
  clear() {
    this.cache.clear();
  }
}

const cache = new IntegrityCache();
cache.fetch('https://cdn.example.com/lib.js', 'sha384-hash');
```

#### Versioned Resources

```javascript
async function fetchVersionedResource(baseUrl, version, integrity) {
  const url = `${baseUrl}?v=${version}`;
  
  try {
    const response = await fetch(url, {
      integrity: integrity,
      cache: 'default'
    });
    
    if (!response.ok) {
      throw new Error(`Failed to fetch version ${version}`);
    }
    
    return await response.text();
    
  } catch (error) {
    console.error(`Integrity or fetch failed for version ${version}`);
    throw error;
  }
}

// Usage
fetchVersionedResource(
  'https://cdn.example.com/app.js',
  '2.1.0',
  'sha384-hashForVersion2.1.0'
);
```

### Content Security Policy Integration

#### CSP with Integrity

```javascript
// The CSP header would include: require-sri-for script style;
// This forces all scripts and styles to have integrity attributes

function loadScriptWithIntegrity(url, integrity) {
  const script = document.createElement('script');
  script.src = url;
  script.integrity = integrity;
  script.crossOrigin = 'anonymous';
  
  return new Promise((resolve, reject) => {
    script.onload = () => resolve(script);
    script.onerror = () => reject(new Error('Script failed to load'));
    document.head.appendChild(script);
  });
}

// Usage
loadScriptWithIntegrity(
  'https://cdn.example.com/lib.js',
  'sha384-hash'
)
.then(() => console.log('Script loaded and verified'))
.catch(error => console.error('Failed:', error));
```

### Integrity for Binary Data

#### Verifying Binary Files

```javascript
async function fetchBinaryWithIntegrity(url, expectedHash) {
  const response = await fetch(url);
  const arrayBuffer = await response.arrayBuffer();
  
  const hashBuffer = await crypto.subtle.digest('SHA-384', arrayBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashBase64 = btoa(String.fromCharCode(...hashArray));
  const actualHash = `sha384-${hashBase64}`;
  
  if (actualHash !== expectedHash) {
    throw new Error('Binary file integrity check failed');
  }
  
  return arrayBuffer;
}

// Usage
fetchBinaryWithIntegrity(
  'https://example.com/image.png',
  'sha384-hash'
)
.then(buffer => {
  const blob = new Blob([buffer]);
  const url = URL.createObjectURL(blob);
  console.log('Verified image URL:', url);
});
```

#### Stream-Based Verification

```javascript
async function verifyStreamIntegrity(url, expectedHash) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  const chunks = [];
  let totalLength = 0;
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    chunks.push(value);
    totalLength += value.length;
  }
  
  // Combine chunks
  const combined = new Uint8Array(totalLength);
  let position = 0;
  for (const chunk of chunks) {
    combined.set(chunk, position);
    position += chunk.length;
  }
  
  // Verify integrity
  const hashBuffer = await crypto.subtle.digest('SHA-384', combined);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashBase64 = btoa(String.fromCharCode(...hashArray));
  const actualHash = `sha384-${hashBase64}`;
  
  if (actualHash !== expectedHash) {
    throw new Error('Stream integrity verification failed');
  }
  
  return combined;
}
```

### Integrity Manager Pattern

```javascript
class IntegrityManager {
  constructor() {
    this.knownHashes = new Map();
  }
  
  register(url, integrity) {
    this.knownHashes.set(url, integrity);
  }
  
  async fetch(url, options = {}) {
    const integrity = this.knownHashes.get(url);
    
    if (!integrity) {
      console.warn(`No integrity hash registered for ${url}`);
      return fetch(url, options);
    }
    
    return fetch(url, {
      ...options,
      integrity: integrity
    });
  }
  
  async verifyAndCache(url) {
    const response = await this.fetch(url);
    const content = await response.text();
    
    return {
      url,
      content,
      verified: true,
      timestamp: Date.now()
    };
  }
}

// Usage
const manager = new IntegrityManager();
manager.register(
  'https://cdn.example.com/lib.js',
  'sha384-hash'
);

manager.fetch('https://cdn.example.com/lib.js')
  .then(response => response.text())
  .then(content => console.log('Verified content loaded'));
```

### Integrity for APIs

#### API Response Verification

```javascript
async function fetchApiWithIntegrity(url, expectedSignature) {
  const response = await fetch(url);
  const data = await response.json();
  
  // Server includes signature in response
  const serverSignature = response.headers.get('X-Content-Signature');
  
  if (serverSignature !== expectedSignature) {
    throw new Error('API response signature mismatch');
  }
  
  return data;
}
```

#### HMAC Verification

```javascript
async function verifyHMAC(data, secret, receivedHmac) {
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secret);
  const messageData = encoder.encode(JSON.stringify(data));
  
  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign', 'verify']
  );
  
  const signature = await crypto.subtle.sign('HMAC', key, messageData);
  const signatureArray = Array.from(new Uint8Array(signature));
  const signatureHex = signatureArray
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  
  return signatureHex === receivedHmac;
}

// Usage
async function fetchWithHMAC(url, secret) {
  const response = await fetch(url);
  const data = await response.json();
  const hmac = response.headers.get('X-HMAC-Signature');
  
  const isValid = await verifyHMAC(data, secret, hmac);
  
  if (!isValid) {
    throw new Error('HMAC verification failed');
  }
  
  return data;
}
```

### Error Handling for Integrity Checks

#### Comprehensive Error Handling

```javascript
async function safeIntegrityFetch(url, integrity, retries = 3) {
  let lastError;
  
  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      const response = await fetch(url, { integrity });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return await response.text();
      
    } catch (error) {
      lastError = error;
      
      if (error.name === 'TypeError' && error.message.includes('integrity')) {
        console.error('Integrity check failed, not retrying');
        break;
      }
      
      console.warn(`Attempt ${attempt + 1} failed:`, error.message);
      
      if (attempt < retries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
      }
    }
  }
  
  throw new Error(`Failed after ${retries} attempts: ${lastError.message}`);
}
```

#### Logging Integrity Failures

```javascript
class IntegrityLogger {
  constructor() {
    this.failures = [];
  }
  
  async fetch(url, integrity) {
    try {
      const response = await fetch(url, { integrity });
      
      this.log('success', url, integrity);
      return response;
      
    } catch (error) {
      this.log('failure', url, integrity, error);
      throw error;
    }
  }
  
  log(status, url, integrity, error = null) {
    const entry = {
      timestamp: new Date().toISOString(),
      status,
      url,
      integrity,
      error: error?.message
    };
    
    if (status === 'failure') {
      this.failures.push(entry);
    }
    
    console.log('Integrity check:', entry);
  }
  
  getFailures() {
    return this.failures;
  }
}

const logger = new IntegrityLogger();
logger.fetch('https://cdn.example.com/lib.js', 'sha384-hash');
```

### Performance Considerations

#### Preloading with Integrity

```javascript
function preloadWithIntegrity(url, integrity, type = 'script') {
  const link = document.createElement('link');
  link.rel = 'preload';
  link.as = type;
  link.href = url;
  link.integrity = integrity;
  link.crossOrigin = 'anonymous';
  
  document.head.appendChild(link);
}

// Usage
preloadWithIntegrity(
  'https://cdn.example.com/lib.js',
  'sha384-hash',
  'script'
);
```

#### Parallel Fetching with Integrity

```javascript
async function fetchMultipleWithIntegrity(resources) {
  const promises = resources.map(({ url, integrity }) =>
    fetch(url, { integrity })
      .then(response => response.text())
      .then(content => ({ url, content, verified: true }))
      .catch(error => ({ url, error: error.message, verified: false }))
  );
  
  return Promise.all(promises);
}

// Usage
const resources = [
  { url: 'https://cdn.example.com/lib1.js', integrity: 'sha384-hash1' },
  { url: 'https://cdn.example.com/lib2.js', integrity: 'sha384-hash2' },
  { url: 'https://cdn.example.com/lib3.js', integrity: 'sha384-hash3' }
];

fetchMultipleWithIntegrity(resources)
  .then(results => {
    const verified = results.filter(r => r.verified);
    const failed = results.filter(r => !r.verified);
    console.log(`Verified: ${verified.length}, Failed: ${failed.length}`);
  });
```

---

