## Encryption in Transit


### TLS/HTTPS Enforcement

The fetch API automatically uses the HTTPS protocol when specified in URLs, establishing encrypted connections through TLS handshakes. All modern browsers enforce strict transport security for sensitive operations.

```javascript
// Fetch automatically uses HTTPS encryption
async function secureRequest(endpoint, data) {
  const response = await fetch(`https://api.example.com/${endpoint}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data)
  });
  
  return response.json();
}

// Protocol validation
function ensureHttps(url) {
  const parsedUrl = new URL(url);
  
  if (parsedUrl.protocol !== 'https:') {
    throw new Error('Insecure protocol detected. HTTPS required.');
  }
  
  return url;
}

async function secureOnlyFetch(url, options) {
  const validatedUrl = ensureHttps(url);
  return fetch(validatedUrl, options);
}
```

### Strict Transport Security (HSTS)

HSTS headers force browsers to use HTTPS for all subsequent connections, preventing protocol downgrade attacks.

```javascript
// Server response includes HSTS header:
// Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

class HSTSAwareFetch {
  constructor() {
    this.hstsCache = new Map();
  }
  
  recordHSTS(hostname, maxAge) {
    this.hstsCache.set(hostname, {
      enforceUntil: Date.now() + (maxAge * 1000)
    });
  }
  
  isHSTSEnforced(hostname) {
    const entry = this.hstsCache.get(hostname);
    
    if (!entry) return false;
    
    if (Date.now() > entry.enforceUntil) {
      this.hstsCache.delete(hostname);
      return false;
    }
    
    return true;
  }
  
  async fetch(url, options = {}) {
    const parsedUrl = new URL(url);
    
    // Upgrade to HTTPS if HSTS is enforced
    if (this.isHSTSEnforced(parsedUrl.hostname) && parsedUrl.protocol === 'http:') {
      parsedUrl.protocol = 'https:';
      url = parsedUrl.toString();
    }
    
    const response = await fetch(url, options);
    
    // Parse HSTS header from response
    const hstsHeader = response.headers.get('strict-transport-security');
    if (hstsHeader) {
      const maxAgeMatch = hstsHeader.match(/max-age=(\d+)/);
      if (maxAgeMatch) {
        this.recordHSTS(parsedUrl.hostname, parseInt(maxAgeMatch[1]));
      }
    }
    
    return response;
  }
}

const hstsFetch = new HSTSAwareFetch();
```

### Certificate Pinning Validation

Certificate pinning prevents man-in-the-middle attacks by validating server certificates against known good values. Browser fetch API does not expose certificate details directly, but pinning can be enforced through service workers and Content Security Policy.

```javascript
// Service Worker for certificate pinning
// service-worker.js
const EXPECTED_CERT_HASHES = [
  'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
  'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=' // Backup pin
];

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  if (url.hostname === 'api.example.com') {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          // [Unverified] Browser fetch API does not expose certificate information
          // Certificate validation happens at browser TLS layer
          // Additional validation requires server-side verification
          return response;
        })
        .catch(error => {
          console.error('Certificate validation failed:', error);
          return new Response('Certificate validation failed', { status: 526 });
        })
    );
  }
});

// Client-side CSP header enforcement
// Content-Security-Policy: require-sri-for script style;
```

### Perfect Forward Secrecy

Perfect forward secrecy ensures past communications remain secure even if private keys are compromised. Modern TLS cipher suites automatically provide this protection.

```javascript
// Browser automatically negotiates PFS-enabled cipher suites
// Verification through SecurityInfo (not directly accessible in fetch)

class SecureConnectionValidator {
  async validateConnection(url) {
    try {
      const response = await fetch(url, {
        method: 'HEAD'
      });
      
      // [Unverified] Fetch API does not expose TLS negotiation details
      // Browsers automatically prefer strong cipher suites with PFS
      // Server must support modern TLS 1.2+ with ECDHE/DHE key exchange
      
      return {
        secure: response.url.startsWith('https://'),
        // [Inference] Modern browsers enforce minimum TLS versions
        tlsVersion: 'TLS 1.2+',
        // [Inference] Cipher suite selection happens transparently
        forwardSecrecy: true
      };
    } catch (error) {
      throw new Error(`Connection validation failed: ${error.message}`);
    }
  }
}

const validator = new SecureConnectionValidator();
```

### End-to-End Payload Encryption

Application-layer encryption provides defense-in-depth by encrypting sensitive data before transmission, independent of transport security.

```javascript
class E2EEncryptedFetch {
  constructor(publicKey) {
    this.publicKey = publicKey;
  }
  
  async encryptPayload(data) {
    const jsonData = JSON.stringify(data);
    const encodedData = new TextEncoder().encode(jsonData);
    
    // Import public key for encryption
    const cryptoKey = await crypto.subtle.importKey(
      'spki',
      this.base64ToArrayBuffer(this.publicKey),
      {
        name: 'RSA-OAEP',
        hash: 'SHA-256'
      },
      false,
      ['encrypt']
    );
    
    // Encrypt data
    const encryptedData = await crypto.subtle.encrypt(
      { name: 'RSA-OAEP' },
      cryptoKey,
      encodedData
    );
    
    return this.arrayBufferToBase64(encryptedData);
  }
  
  async decryptPayload(encryptedData, privateKey) {
    const cryptoKey = await crypto.subtle.importKey(
      'pkcs8',
      this.base64ToArrayBuffer(privateKey),
      {
        name: 'RSA-OAEP',
        hash: 'SHA-256'
      },
      false,
      ['decrypt']
    );
    
    const decryptedData = await crypto.subtle.decrypt(
      { name: 'RSA-OAEP' },
      cryptoKey,
      this.base64ToArrayBuffer(encryptedData)
    );
    
    const decodedData = new TextDecoder().decode(decryptedData);
    return JSON.parse(decodedData);
  }
  
  base64ToArrayBuffer(base64) {
    const binaryString = atob(base64);
    const bytes = new Uint8Array(binaryString.length);
    for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    return bytes.buffer;
  }
  
  arrayBufferToBase64(buffer) {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }
  
  async fetch(url, data, options = {}) {
    const encryptedPayload = await this.encryptPayload(data);
    
    return fetch(url, {
      ...options,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      },
      body: JSON.stringify({
        encrypted: encryptedPayload
      })
    });
  }
}

const e2eFetch = new E2EEncryptedFetch('PUBLIC_KEY_BASE64');

await e2eFetch.fetch('https://api.example.com/sensitive', {
  ssn: '123-45-6789',
  creditCard: '4111111111111111'
});
```

### Symmetric Encryption for Large Payloads

Hybrid encryption combines symmetric and asymmetric algorithms for efficient encryption of large data transfers.

```javascript
class HybridEncryptionFetch {
  async generateSessionKey() {
    return crypto.subtle.generateKey(
      {
        name: 'AES-GCM',
        length: 256
      },
      true,
      ['encrypt', 'decrypt']
    );
  }
  
  async encryptWithSessionKey(data, sessionKey) {
    const encodedData = new TextEncoder().encode(JSON.stringify(data));
    const iv = crypto.getRandomValues(new Uint8Array(12));
    
    const encryptedData = await crypto.subtle.encrypt(
      {
        name: 'AES-GCM',
        iv: iv
      },
      sessionKey,
      encodedData
    );
    
    return {
      encryptedData: this.arrayBufferToBase64(encryptedData),
      iv: this.arrayBufferToBase64(iv)
    };
  }
  
  async encryptSessionKey(sessionKey, recipientPublicKey) {
    const exportedKey = await crypto.subtle.exportKey('raw', sessionKey);
    
    const cryptoKey = await crypto.subtle.importKey(
      'spki',
      this.base64ToArrayBuffer(recipientPublicKey),
      {
        name: 'RSA-OAEP',
        hash: 'SHA-256'
      },
      false,
      ['encrypt']
    );
    
    const encryptedKey = await crypto.subtle.encrypt(
      { name: 'RSA-OAEP' },
      cryptoKey,
      exportedKey
    );
    
    return this.arrayBufferToBase64(encryptedKey);
  }
  
  async fetch(url, data, recipientPublicKey, options = {}) {
    // Generate ephemeral session key
    const sessionKey = await this.generateSessionKey();
    
    // Encrypt payload with session key (fast symmetric encryption)
    const { encryptedData, iv } = await this.encryptWithSessionKey(data, sessionKey);
    
    // Encrypt session key with recipient's public key
    const encryptedSessionKey = await this.encryptSessionKey(sessionKey, recipientPublicKey);
    
    return fetch(url, {
      ...options,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      },
      body: JSON.stringify({
        encryptedData,
        encryptedKey: encryptedSessionKey,
        iv
      })
    });
  }
  
  arrayBufferToBase64(buffer) {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }
  
  base64ToArrayBuffer(base64) {
    const binaryString = atob(base64);
    const bytes = new Uint8Array(binaryString.length);
    for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    return bytes.buffer;
  }
}

const hybridFetch = new HybridEncryptionFetch();

await hybridFetch.fetch(
  'https://api.example.com/upload',
  { largeDocument: '...' },
  'RECIPIENT_PUBLIC_KEY_BASE64'
);
```

### Encrypted Headers and Metadata

Protecting request metadata prevents information leakage through HTTP headers and query parameters.

```javascript
class EncryptedHeaderFetch {
  constructor(sharedSecret) {
    this.sharedSecret = sharedSecret;
  }
  
  async deriveKey(salt) {
    const encoder = new TextEncoder();
    const keyMaterial = await crypto.subtle.importKey(
      'raw',
      encoder.encode(this.sharedSecret),
      { name: 'PBKDF2' },
      false,
      ['deriveBits', 'deriveKey']
    );
    
    return crypto.subtle.deriveKey(
      {
        name: 'PBKDF2',
        salt: encoder.encode(salt),
        iterations: 100000,
        hash: 'SHA-256'
      },
      keyMaterial,
      { name: 'AES-GCM', length: 256 },
      false,
      ['encrypt', 'decrypt']
    );
  }
  
  async encryptHeader(value, salt) {
    const key = await this.deriveKey(salt);
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const encodedValue = new TextEncoder().encode(value);
    
    const encrypted = await crypto.subtle.encrypt(
      { name: 'AES-GCM', iv },
      key,
      encodedValue
    );
    
    return {
      encrypted: this.arrayBufferToBase64(encrypted),
      iv: this.arrayBufferToBase64(iv)
    };
  }
  
  async fetch(url, options = {}) {
    const salt = crypto.getRandomValues(new Uint8Array(16));
    const saltBase64 = this.arrayBufferToBase64(salt);
    
    // Encrypt sensitive headers
    const encryptedHeaders = {};
    const sensitiveHeaders = ['X-User-ID', 'X-Session-Token', 'X-API-Key'];
    
    for (const [key, value] of Object.entries(options.headers || {})) {
      if (sensitiveHeaders.includes(key)) {
        const { encrypted, iv } = await this.encryptHeader(value, salt);
        encryptedHeaders[`X-Encrypted-${key}`] = `${encrypted}:${iv}`;
      } else {
        encryptedHeaders[key] = value;
      }
    }
    
    encryptedHeaders['X-Encryption-Salt'] = saltBase64;
    
    return fetch(url, {
      ...options,
      headers: encryptedHeaders
    });
  }
  
  arrayBufferToBase64(buffer) {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }
}

const encryptedHeaderFetch = new EncryptedHeaderFetch('SHARED_SECRET_KEY');

await encryptedHeaderFetch.fetch('https://api.example.com/data', {
  headers: {
    'X-User-ID': 'user_123456',
    'X-Session-Token': 'session_abc789',
    'Content-Type': 'application/json'
  }
});
```

### Request Signing and Integrity Verification

HMAC signatures ensure request integrity and authenticity, preventing tampering during transit.

```javascript
class SignedRequestFetch {
  constructor(secretKey) {
    this.secretKey = secretKey;
  }
  
  async importKey() {
    const encoder = new TextEncoder();
    return crypto.subtle.importKey(
      'raw',
      encoder.encode(this.secretKey),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign', 'verify']
    );
  }
  
  async signRequest(method, url, body, timestamp) {
    const key = await this.importKey();
    
    // Create canonical string
    const canonicalString = `${method}\n${url}\n${timestamp}\n${body || ''}`;
    const encoder = new TextEncoder();
    const data = encoder.encode(canonicalString);
    
    const signature = await crypto.subtle.sign('HMAC', key, data);
    
    return this.arrayBufferToHex(signature);
  }
  
  async verifySignature(signature, method, url, body, timestamp) {
    const key = await this.importKey();
    
    const canonicalString = `${method}\n${url}\n${timestamp}\n${body || ''}`;
    const encoder = new TextEncoder();
    const data = encoder.encode(canonicalString);
    
    const signatureBuffer = this.hexToArrayBuffer(signature);
    
    return crypto.subtle.verify('HMAC', key, signatureBuffer, data);
  }
  
  async fetch(url, options = {}) {
    const method = options.method || 'GET';
    const body = options.body || '';
    const timestamp = Date.now().toString();
    
    const signature = await this.signRequest(method, url, body, timestamp);
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'X-Signature': signature,
        'X-Timestamp': timestamp,
        'X-Signature-Algorithm': 'HMAC-SHA256'
      }
    });
  }
  
  arrayBufferToHex(buffer) {
    const bytes = new Uint8Array(buffer);
    return Array.from(bytes)
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }
  
  hexToArrayBuffer(hex) {
    const bytes = new Uint8Array(hex.length / 2);
    for (let i = 0; i < hex.length; i += 2) {
      bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
    }
    return bytes.buffer;
  }
}

const signedFetch = new SignedRequestFetch('SECRET_SIGNING_KEY');

await signedFetch.fetch('https://api.example.com/transaction', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    amount: 100.00,
    recipient: 'user_456'
  })
});
```

### Encrypted WebSocket Connections

WebSocket security requires WSS protocol (WebSockets over TLS) for encrypted bidirectional communication.

```javascript
class SecureWebSocketClient {
  constructor(url, protocols = []) {
    // Enforce WSS protocol
    if (!url.startsWith('wss://')) {
      throw new Error('WebSocket URL must use wss:// protocol');
    }
    
    this.url = url;
    this.protocols = protocols;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }
  
  connect() {
    return new Promise((resolve, reject) => {
      this.ws = new WebSocket(this.url, this.protocols);
      
      this.ws.onopen = () => {
        this.reconnectAttempts = 0;
        resolve();
      };
      
      this.ws.onerror = (error) => {
        reject(error);
      };
      
      this.ws.onclose = () => {
        this.handleReconnection();
      };
    });
  }
  
  async sendEncrypted(data, encryptionKey) {
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      throw new Error('WebSocket not connected');
    }
    
    // Additional application-layer encryption
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const encodedData = new TextEncoder().encode(JSON.stringify(data));
    
    const encrypted = await crypto.subtle.encrypt(
      { name: 'AES-GCM', iv },
      encryptionKey,
      encodedData
    );
    
    const payload = {
      encrypted: this.arrayBufferToBase64(encrypted),
      iv: this.arrayBufferToBase64(iv)
    };
    
    this.ws.send(JSON.stringify(payload));
  }
  
  async handleReconnection() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('Max reconnection attempts reached');
      return;
    }
    
    this.reconnectAttempts++;
    const delay = Math.pow(2, this.reconnectAttempts) * 1000;
    
    setTimeout(() => {
      this.connect().catch(error => {
        console.error('Reconnection failed:', error);
      });
    }, delay);
  }
  
  arrayBufferToBase64(buffer) {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }
}

const secureWs = new SecureWebSocketClient('wss://realtime.example.com/stream');
await secureWs.connect();
```

### Encrypted File Upload

Large file uploads require streaming encryption to manage memory efficiently while maintaining security.

```javascript
class EncryptedFileUpload {
  async encryptFile(file, password) {
    const salt = crypto.getRandomValues(new Uint8Array(16));
    const iv = crypto.getRandomValues(new Uint8Array(12));
    
    // Derive key from password
    const keyMaterial = await this.deriveKeyMaterial(password);
    const key = await this.deriveKey(keyMaterial, salt);
    
    // Read file as array buffer
    const fileBuffer = await file.arrayBuffer();
    
    // Encrypt file content
    const encryptedContent = await crypto.subtle.encrypt(
      { name: 'AES-GCM', iv },
      key,
      fileBuffer
    );
    
    // Create encrypted file with metadata
    const metadata = {
      originalName: file.name,
      originalSize: file.size,
      mimeType: file.type,
      salt: this.arrayBufferToBase64(salt),
      iv: this.arrayBufferToBase64(iv)
    };
    
    return {
      encryptedContent,
      metadata
    };
  }
  
  async deriveKeyMaterial(password) {
    const encoder = new TextEncoder();
    return crypto.subtle.importKey(
      'raw',
      encoder.encode(password),
      { name: 'PBKDF2' },
      false,
      ['deriveBits', 'deriveKey']
    );
  }
  
  async deriveKey(keyMaterial, salt) {
    return crypto.subtle.deriveKey(
      {
        name: 'PBKDF2',
        salt: salt,
        iterations: 100000,
        hash: 'SHA-256'
      },
      keyMaterial,
      { name: 'AES-GCM', length: 256 },
      false,
      ['encrypt', 'decrypt']
    );
  }
  
  async upload(file, password, uploadUrl) {
    const { encryptedContent, metadata } = await this.encryptFile(file, password);
    
    // Create form data
    const formData = new FormData();
    const encryptedBlob = new Blob([encryptedContent], { type: 'application/octet-stream' });
    formData.append('file', encryptedBlob, `${file.name}.encrypted`);
    formData.append('metadata', JSON.stringify(metadata));
    
    const response = await fetch(uploadUrl, {
      method: 'POST',
      body: formData
    });
    
    if (!response.ok) {
      throw new Error(`Upload failed: ${response.status}`);
    }
    
    return response.json();
  }
  
  arrayBufferToBase64(buffer) {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }
}

const encryptedUpload = new EncryptedFileUpload();

const fileInput = document.querySelector('input[type="file"]');
const file = fileInput.files[0];

await encryptedUpload.upload(
  file,
  'user_password_123',
  'https://api.example.com/upload'
);
```

### Chunked Encrypted Streaming

Streaming encryption for large files reduces memory consumption by processing data in chunks.

```javascript
class StreamingEncryptedUpload {
  constructor(chunkSize = 1024 * 1024) { // 1MB chunks
    this.chunkSize = chunkSize;
  }
  
  async uploadEncrypted(file, password, uploadUrl) {
    const salt = crypto.getRandomValues(new Uint8Array(16));
    const keyMaterial = await this.deriveKeyMaterial(password);
    const key = await this.deriveKey(keyMaterial, salt);
    
    // Initialize upload session
    const sessionResponse = await fetch(`${uploadUrl}/init`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        fileName: file.name,
        fileSize: file.size,
        salt: this.arrayBufferToBase64(salt)
      })
    });
    
    const { uploadId } = await sessionResponse.json();
    
    // Upload encrypted chunks
    const totalChunks = Math.ceil(file.size / this.chunkSize);
    
    for (let chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
      const start = chunkIndex * this.chunkSize;
      const end = Math.min(start + this.chunkSize, file.size);
      const chunk = file.slice(start, end);
      
      await this.uploadChunk(chunk, chunkIndex, uploadId, key, uploadUrl);
    }
    
    // Finalize upload
    const finalizeResponse = await fetch(`${uploadUrl}/finalize`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        uploadId,
        totalChunks
      })
    });
    
    return finalizeResponse.json();
  }
  
  async uploadChunk(chunk, chunkIndex, uploadId, key, uploadUrl) {
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const chunkBuffer = await chunk.arrayBuffer();
    
    const encryptedChunk = await crypto.subtle.encrypt(
      { name: 'AES-GCM', iv },
      key,
      chunkBuffer
    );
    
    const formData = new FormData();
    formData.append('uploadId', uploadId);
    formData.append('chunkIndex', chunkIndex.toString());
    formData.append('iv', this.arrayBufferToBase64(iv));
    formData.append('chunk', new Blob([encryptedChunk]));
    
    const response = await fetch(`${uploadUrl}/chunk`, {
      method: 'POST',
      body: formData
    });
    
    if (!response.ok) {
      throw new Error(`Chunk upload failed: ${response.status}`);
    }
  }
  
  async deriveKeyMaterial(password) {
    const encoder = new TextEncoder();
    return crypto.subtle.importKey(
      'raw',
      encoder.encode(password),
      { name: 'PBKDF2' },
      false,
      ['deriveBits', 'deriveKey']
    );
  }
  
  async deriveKey(keyMaterial, salt) {
    return crypto.subtle.deriveKey(
      {
        name: 'PBKDF2',
        salt: salt,
        iterations: 100000,
        hash: 'SHA-256'
      },
      keyMaterial,
      { name: 'AES-GCM', length: 256 },
      false,
      ['encrypt', 'decrypt']
    );
  }
  
  arrayBufferToBase64(buffer) {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }
}

const streamingUpload = new StreamingEncryptedUpload();

await streamingUpload.uploadEncrypted(
  largeFile,
  'encryption_password',
  'https://api.example.com/upload'
);
```

### Mutual TLS Authentication

Mutual TLS (mTLS) requires both client and server to present certificates, providing bidirectional authentication. The fetch API relies on browser certificate management for client certificates.

```javascript
// Browser prompts for client certificate when server requests it
// Certificates managed through browser settings or OS keychain

class MTLSFetch {
  async fetch(url, options = {}) {
    // [Unverified] Browser automatically presents client certificate if configured
    // Server must be configured to request and validate client certificates
    
    try {
      const response = await fetch(url, {
        ...options,
        credentials: 'include', // Include certificates
        mode: 'cors'
      });
      
      if (response.status === 495) {
        // [Inference] Server rejected client certificate
        throw new Error('Client certificate validation failed');
      }
      
      return response;
    } catch (error) {
      if (error.message.includes('certificate')) {
        throw new Error('mTLS authentication failed: ' + error.message);
      }
      throw error;
    }
  }
  
  async validateServerCertificate(url) {
    // [Unverified] Fetch API does not expose server certificate details
    // Certificate validation occurs at browser TLS layer
    // Additional validation requires server-side implementation
    
    try {
      const response = await fetch(url, {
        method: 'HEAD'
      });
      
      return {
        valid: response.ok,
        url: response.url
      };
    } catch (error) {
      return {
        valid: false,
        error: error.message
      };
    }
  }
}

const mtlsFetch = new MTLSFetch();

await mtlsFetch.fetch('https://secure-api.example.com/data', {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
});
```

### DNS over HTTPS (DoH)

DNS over HTTPS encrypts DNS queries, preventing DNS-based surveillance and man-in-the-middle attacks. Browser implementations handle DoH transparently.

```javascript
// Modern browsers support DoH configuration
// Queries encrypted automatically when DoH is enabled

class SecureDNSValidator {
  constructor() {
    this.dohProviders = [
      'https://cloudflare-dns.com/dns-query',
      'https://dns.google/dns-query'
    ];
  }
  
  async queryDNS(domain, recordType = 'A') {
    const dohUrl = this.dohProviders[0];
    
    const response = await fetch(`${dohUrl}?name=${domain}&type=${recordType}`, {
      headers: {
        'Accept': 'application/dns-json'
      }
    });
    
    if (!response.ok) {
      throw new Error(`DNS query failed: ${response.status}`);
    }
    
    return response.json();
}

async validateDomain(domain) { 
		try {
		 const result = await this.queryDNS(domain);
	  return {
	    domain,
	    valid: result.Status === 0,
	    answers: result.Answer || [],
	    secure: true // Query performed over HTTPS
	  };
	} catch (error) {
	  return {
	    domain,
	    valid: false,
	    error: error.message,
	    secure: false
	  };
	}
  }
}

const dnsValidator = new SecureDNSValidator(); const validation = await dnsValidator.validateDomain('example.com');
````

### Content Security Policy Integration

CSP headers restrict resource loading to trusted sources, preventing injection attacks that could compromise encrypted communications.

```javascript
class CSPAwareFetch {
  constructor() {
    this.trustedDomains = new Set([
      'https://api.example.com',
      'https://cdn.example.com'
    ]);
  }
  
  validateURL(url) {
    const parsedUrl = new URL(url);
    const origin = `${parsedUrl.protocol}//${parsedUrl.hostname}`;
    
    if (!this.trustedDomains.has(origin)) {
      throw new Error(`URL ${origin} not in trusted domains list`);
    }
    
    if (parsedUrl.protocol !== 'https:') {
      throw new Error('Only HTTPS URLs are allowed');
    }
    
    return true;
  }
  
  async fetch(url, options = {}) {
    this.validateURL(url);
    
    const response = await fetch(url, options);
    
    // Verify CSP headers in response
    const csp = response.headers.get('content-security-policy');
    if (!csp) {
      console.warn('Response missing Content-Security-Policy header');
    }
    
    return response;
  }
  
  addTrustedDomain(domain) {
    if (!domain.startsWith('https://')) {
      throw new Error('Only HTTPS domains can be added');
    }
    this.trustedDomains.add(domain);
  }
}

const cspFetch = new CSPAwareFetch();

await cspFetch.fetch('https://api.example.com/data', {
  method: 'GET'
});
````

---



---


