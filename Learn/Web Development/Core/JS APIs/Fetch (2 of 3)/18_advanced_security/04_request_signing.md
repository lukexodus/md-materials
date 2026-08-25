## Request Signing


### HMAC-based Signing

Generate signatures using HMAC (Hash-based Message Authentication Code) to verify request authenticity:

```javascript
async function generateHMAC(message, secret) {
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secret);
  const messageData = encoder.encode(message);
  
  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign('HMAC', key, messageData);
  
  // Convert to hex string
  return Array.from(new Uint8Array(signature))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

async function signRequest(url, method, body, secret) {
  const timestamp = Date.now().toString();
  const message = `${method}:${url}:${body || ''}:${timestamp}`;
  const signature = await generateHMAC(message, secret);
  
  return {
    signature,
    timestamp
  };
}

// Usage
async function fetchWithHMAC(url, options = {}, secret) {
  const method = options.method || 'GET';
  const body = options.body || '';
  
  const { signature, timestamp } = await signRequest(url, method, body, secret);
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-Signature': signature,
      'X-Timestamp': timestamp
    }
  });
}
```

### AWS Signature V4

Implement AWS-style request signing for API authentication:

```javascript
class AWSSignatureV4 {
  constructor(accessKeyId, secretAccessKey, region, service) {
    this.accessKeyId = accessKeyId;
    this.secretAccessKey = secretAccessKey;
    this.region = region;
    this.service = service;
  }
  
  async sign(request) {
    const url = new URL(request.url);
    const method = request.method || 'GET';
    const timestamp = new Date().toISOString().replace(/[:\-]|\.\d{3}/g, '');
    const date = timestamp.slice(0, 8);
    
    // Canonical request
    const canonicalUri = url.pathname || '/';
    const canonicalQueryString = this.getCanonicalQueryString(url.searchParams);
    const canonicalHeaders = this.getCanonicalHeaders(request.headers, url.host);
    const signedHeaders = this.getSignedHeaders(request.headers);
    const payloadHash = await this.hashPayload(request.body);
    
    const canonicalRequest = [
      method,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      payloadHash
    ].join('\n');
    
    // String to sign
    const credentialScope = `${date}/${this.region}/${this.service}/aws4_request`;
    const canonicalRequestHash = await this.sha256(canonicalRequest);
    const stringToSign = [
      'AWS4-HMAC-SHA256',
      timestamp,
      credentialScope,
      canonicalRequestHash
    ].join('\n');
    
    // Calculate signature
    const signature = await this.calculateSignature(stringToSign, date);
    
    // Authorization header
    const authorization = [
      `AWS4-HMAC-SHA256 Credential=${this.accessKeyId}/${credentialScope}`,
      `SignedHeaders=${signedHeaders}`,
      `Signature=${signature}`
    ].join(', ');
    
    return {
      'Authorization': authorization,
      'X-Amz-Date': timestamp,
      'X-Amz-Content-Sha256': payloadHash
    };
  }
  
  getCanonicalQueryString(params) {
    const sorted = Array.from(params.entries())
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
      .join('&');
    return sorted;
  }
  
  getCanonicalHeaders(headers, host) {
    const canonical = { host };
    
    if (headers) {
      for (const [key, value] of Object.entries(headers)) {
        const lowerKey = key.toLowerCase();
        if (lowerKey.startsWith('x-amz-') || lowerKey === 'content-type') {
          canonical[lowerKey] = value.trim();
        }
      }
    }
    
    return Object.entries(canonical)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, value]) => `${key}:${value}`)
      .join('\n') + '\n';
  }
  
  getSignedHeaders(headers) {
    const headerNames = ['host'];
    
    if (headers) {
      for (const key of Object.keys(headers)) {
        const lowerKey = key.toLowerCase();
        if (lowerKey.startsWith('x-amz-') || lowerKey === 'content-type') {
          headerNames.push(lowerKey);
        }
      }
    }
    
    return headerNames.sort().join(';');
  }
  
  async hashPayload(body) {
    if (!body) return await this.sha256('');
    
    if (typeof body === 'string') {
      return await this.sha256(body);
    }
    
    // For other body types, convert to string
    return await this.sha256(JSON.stringify(body));
  }
  
  async sha256(message) {
    const encoder = new TextEncoder();
    const data = encoder.encode(message);
    const hash = await crypto.subtle.digest('SHA-256', data);
    return Array.from(new Uint8Array(hash))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }
  
  async hmac(key, message) {
    const encoder = new TextEncoder();
    const keyData = typeof key === 'string' ? encoder.encode(key) : key;
    const messageData = encoder.encode(message);
    
    const cryptoKey = await crypto.subtle.importKey(
      'raw',
      keyData,
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign']
    );
    
    return await crypto.subtle.sign('HMAC', cryptoKey, messageData);
  }
  
  async calculateSignature(stringToSign, date) {
    const kDate = await this.hmac(`AWS4${this.secretAccessKey}`, date);
    const kRegion = await this.hmac(kDate, this.region);
    const kService = await this.hmac(kRegion, this.service);
    const kSigning = await this.hmac(kService, 'aws4_request');
    const signature = await this.hmac(kSigning, stringToSign);
    
    return Array.from(new Uint8Array(signature))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }
}

// Usage
const signer = new AWSSignatureV4(
  'AKIAIOSFODNN7EXAMPLE',
  'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
  'us-east-1',
  's3'
);

async function fetchWithAWSSignature(url, options = {}) {
  const signatureHeaders = await signer.sign({
    url,
    method: options.method || 'GET',
    headers: options.headers || {},
    body: options.body
  });
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      ...signatureHeaders
    }
  });
}
```

### JWT-based Request Signing

Sign requests using JSON Web Tokens:

```javascript
async function createJWT(payload, secret, expiresIn = 3600) {
  const header = {
    alg: 'HS256',
    typ: 'JWT'
  };
  
  const now = Math.floor(Date.now() / 1000);
  const claims = {
    ...payload,
    iat: now,
    exp: now + expiresIn
  };
  
  // Base64URL encode
  const base64UrlEncode = (obj) => {
    const json = JSON.stringify(obj);
    const base64 = btoa(json);
    return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  };
  
  const encodedHeader = base64UrlEncode(header);
  const encodedPayload = base64UrlEncode(claims);
  const message = `${encodedHeader}.${encodedPayload}`;
  
  // Sign
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secret);
  const messageData = encoder.encode(message);
  
  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign('HMAC', key, messageData);
  const encodedSignature = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
  
  return `${message}.${encodedSignature}`;
}

async function fetchWithJWT(url, options = {}, secret, payload = {}) {
  const jwt = await createJWT(payload, secret);
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${jwt}`
    }
  });
}
```

### OAuth 1.0a Signature

Implement OAuth 1.0a request signing:

```javascript
class OAuth1Signer {
  constructor(consumerKey, consumerSecret, tokenKey = null, tokenSecret = null) {
    this.consumerKey = consumerKey;
    this.consumerSecret = consumerSecret;
    this.tokenKey = tokenKey;
    this.tokenSecret = tokenSecret;
  }
  
  generateNonce() {
    return Math.random().toString(36).substring(2, 15) +
           Math.random().toString(36).substring(2, 15);
  }
  
  async sign(method, url, params = {}) {
    const oauthParams = {
      oauth_consumer_key: this.consumerKey,
      oauth_nonce: this.generateNonce(),
      oauth_signature_method: 'HMAC-SHA1',
      oauth_timestamp: Math.floor(Date.now() / 1000).toString(),
      oauth_version: '1.0'
    };
    
    if (this.tokenKey) {
      oauthParams.oauth_token = this.tokenKey;
    }
    
    // Combine all parameters
    const allParams = { ...params, ...oauthParams };
    
    // Create parameter string
    const sortedParams = Object.keys(allParams)
      .sort()
      .map(key => `${this.percentEncode(key)}=${this.percentEncode(allParams[key])}`)
      .join('&');
    
    // Create signature base string
    const baseUrl = url.split('?')[0];
    const signatureBase = [
      method.toUpperCase(),
      this.percentEncode(baseUrl),
      this.percentEncode(sortedParams)
    ].join('&');
    
    // Create signing key
    const signingKey = `${this.percentEncode(this.consumerSecret)}&${
      this.tokenSecret ? this.percentEncode(this.tokenSecret) : ''
    }`;
    
    // Generate signature
    const signature = await this.hmacSha1(signatureBase, signingKey);
    oauthParams.oauth_signature = signature;
    
    return oauthParams;
  }
  
  percentEncode(str) {
    return encodeURIComponent(str)
      .replace(/!/g, '%21')
      .replace(/'/g, '%27')
      .replace(/\(/g, '%28')
      .replace(/\)/g, '%29')
      .replace(/\*/g, '%2A');
  }
  
  async hmacSha1(message, key) {
    const encoder = new TextEncoder();
    const keyData = encoder.encode(key);
    const messageData = encoder.encode(message);
    
    const cryptoKey = await crypto.subtle.importKey(
      'raw',
      keyData,
      { name: 'HMAC', hash: 'SHA-1' },
      false,
      ['sign']
    );
    
    const signature = await crypto.subtle.sign('HMAC', cryptoKey, messageData);
    return btoa(String.fromCharCode(...new Uint8Array(signature)));
  }
  
  buildAuthorizationHeader(oauthParams) {
    const parts = Object.keys(oauthParams)
      .sort()
      .map(key => `${this.percentEncode(key)}="${this.percentEncode(oauthParams[key])}"`)
      .join(', ');
    
    return `OAuth ${parts}`;
  }
}

// Usage
const oauth = new OAuth1Signer(
  'consumer-key',
  'consumer-secret',
  'token-key',
  'token-secret'
);

async function fetchWithOAuth1(url, options = {}, queryParams = {}) {
  const method = options.method || 'GET';
  const oauthParams = await oauth.sign(method, url, queryParams);
  const authHeader = oauth.buildAuthorizationHeader(oauthParams);
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': authHeader
    }
  });
}
```

### Request Body Hash Verification

Include body hash in signature to prevent tampering:

```javascript
async function signRequestWithBodyHash(url, method, body, secret) {
  const encoder = new TextEncoder();
  
  // Hash the body
  const bodyData = encoder.encode(body || '');
  const bodyHashBuffer = await crypto.subtle.digest('SHA-256', bodyData);
  const bodyHash = Array.from(new Uint8Array(bodyHashBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  
  // Create signature with body hash
  const timestamp = Date.now().toString();
  const message = `${method}:${url}:${bodyHash}:${timestamp}`;
  
  const keyData = encoder.encode(secret);
  const messageData = encoder.encode(message);
  
  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signatureBuffer = await crypto.subtle.sign('HMAC', key, messageData);
  const signature = Array.from(new Uint8Array(signatureBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  
  return {
    signature,
    bodyHash,
    timestamp
  };
}

async function fetchWithBodyHashSignature(url, options = {}, secret) {
  const method = options.method || 'GET';
  const body = options.body || '';
  
  const { signature, bodyHash, timestamp } = await signRequestWithBodyHash(
    url,
    method,
    body,
    secret
  );
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-Signature': signature,
      'X-Body-Hash': bodyHash,
      'X-Timestamp': timestamp
    }
  });
}
```

### Timestamp-based Replay Protection

Prevent replay attacks using timestamp validation:

```javascript
class ReplayProtectedSigner {
  constructor(secret, maxAge = 300000) { // 5 minutes default
    this.secret = secret;
    this.maxAge = maxAge;
  }
  
  async sign(url, method, body) {
    const timestamp = Date.now();
    const nonce = this.generateNonce();
    const message = `${method}:${url}:${body || ''}:${timestamp}:${nonce}`;
    
    const signature = await this.generateHMAC(message);
    
    return {
      signature,
      timestamp: timestamp.toString(),
      nonce
    };
  }
  
  generateNonce() {
    const array = new Uint8Array(16);
    crypto.getRandomValues(array);
    return Array.from(array)
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }
  
  async generateHMAC(message) {
    const encoder = new TextEncoder();
    const keyData = encoder.encode(this.secret);
    const messageData = encoder.encode(message);
    
    const key = await crypto.subtle.importKey(
      'raw',
      keyData,
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign']
    );
    
    const signature = await crypto.subtle.sign('HMAC', key, messageData);
    return Array.from(new Uint8Array(signature))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }
  
  async verify(signature, timestamp, nonce, url, method, body) {
    const now = Date.now();
    const requestTime = parseInt(timestamp);
    
    // Check timestamp is within acceptable range
    if (now - requestTime > this.maxAge) {
      throw new Error('Request timestamp expired');
    }
    
    if (requestTime > now + 60000) { // Allow 1 minute clock skew
      throw new Error('Request timestamp is in the future');
    }
    
    // Recalculate signature
    const message = `${method}:${url}:${body || ''}:${timestamp}:${nonce}`;
    const expectedSignature = await this.generateHMAC(message);
    
    // Constant-time comparison
    if (signature !== expectedSignature) {
      throw new Error('Invalid signature');
    }
    
    return true;
  }
}

// Usage
const signer = new ReplayProtectedSigner('secret-key', 300000);

async function fetchWithReplayProtection(url, options = {}) {
  const method = options.method || 'GET';
  const body = options.body || '';
  
  const { signature, timestamp, nonce } = await signer.sign(url, method, body);
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-Signature': signature,
      'X-Timestamp': timestamp,
      'X-Nonce': nonce
    }
  });
}
```

### Public Key Signature (RSA)

Sign requests using RSA public/private key pairs:

```javascript
class RSASigner {
  constructor() {
    this.privateKey = null;
    this.publicKey = null;
  }
  
  async generateKeyPair() {
    const keyPair = await crypto.subtle.generateKey(
      {
        name: 'RSASSA-PKCS1-v1_5',
        modulusLength: 2048,
        publicExponent: new Uint8Array([1, 0, 1]),
        hash: 'SHA-256'
      },
      true,
      ['sign', 'verify']
    );
    
    this.privateKey = keyPair.privateKey;
    this.publicKey = keyPair.publicKey;
    
    return keyPair;
  }
  
  async importPrivateKey(pemKey) {
    const pemContents = pemKey
      .replace('-----BEGIN PRIVATE KEY-----', '')
      .replace('-----END PRIVATE KEY-----', '')
      .replace(/\s/g, '');
    
    const binaryDer = Uint8Array.from(atob(pemContents), c => c.charCodeAt(0));
    
    this.privateKey = await crypto.subtle.importKey(
      'pkcs8',
      binaryDer,
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256'
      },
      true,
      ['sign']
    );
  }
  
  async sign(message) {
    if (!this.privateKey) {
      throw new Error('Private key not loaded');
    }
    
    const encoder = new TextEncoder();
    const data = encoder.encode(message);
    
    const signature = await crypto.subtle.sign(
      'RSASSA-PKCS1-v1_5',
      this.privateKey,
      data
    );
    
    return btoa(String.fromCharCode(...new Uint8Array(signature)));
  }
  
  async signRequest(url, method, body) {
    const timestamp = Date.now().toString();
    const message = `${method}:${url}:${body || ''}:${timestamp}`;
    const signature = await this.sign(message);
    
    return {
      signature,
      timestamp
    };
  }
}

// Usage
const rsaSigner = new RSASigner();
await rsaSigner.generateKeyPair();

async function fetchWithRSASignature(url, options = {}) {
  const method = options.method || 'GET';
  const body = options.body || '';
  
  const { signature, timestamp } = await rsaSigner.signRequest(url, method, body);
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-Signature': signature,
      'X-Timestamp': timestamp,
      'X-Signature-Algorithm': 'RSA-SHA256'
    }
  });
}
```

### Custom Header Signature

Sign specific headers to verify their integrity:

```javascript
async function signHeaders(headers, secret) {
  const headerString = Object.entries(headers)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, value]) => `${key.toLowerCase()}:${value}`)
    .join('\n');
  
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secret);
  const messageData = encoder.encode(headerString);
  
  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign('HMAC', key, messageData);
  
  return Array.from(new Uint8Array(signature))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

async function fetchWithHeaderSignature(url, options = {}, secret) {
  const headersToSign = {
    'Content-Type': options.headers?.['Content-Type'] || 'application/json',
    'X-Request-ID': crypto.randomUUID(),
    'X-Timestamp': new Date().toISOString()
  };
  
  const signature = await signHeaders(headersToSign, secret);
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      ...headersToSign,
      'X-Signature': signature,
      'X-Signed-Headers': Object.keys(headersToSign).sort().join(',')
    }
  });
}
```

### Signature Verification Middleware

Create reusable signing wrapper:

```javascript
class RequestSigner {
  constructor(config) {
    this.secret = config.secret;
    this.algorithm = config.algorithm || 'HMAC-SHA256';
    this.includeBody = config.includeBody !== false;
    this.includeTimestamp = config.includeTimestamp !== false;
    this.includeNonce = config.includeNonce !== false;
  }
  
  async signRequest(url, options = {}) {
    const method = options.method || 'GET';
    const components = [method, url];
    
    const headers = { ...options.headers };
    
    if (this.includeTimestamp) {
      headers['X-Timestamp'] = Date.now().toString();
      components.push(headers['X-Timestamp']);
    }
    
    if (this.includeNonce) {
      headers['X-Nonce'] = this.generateNonce();
      components.push(headers['X-Nonce']);
    }
    
    if (this.includeBody && options.body) {
      const bodyHash = await this.hashBody(options.body);
      headers['X-Body-Hash'] = bodyHash;
      components.push(bodyHash);
    }
    
    const message = components.join(':');
    const signature = await this.sign(message);
    
    headers['X-Signature'] = signature;
    headers['X-Signature-Algorithm'] = this.algorithm;
    
    return {
      ...options,
      headers
    };
  }
  
  async sign(message) {
    const encoder = new TextEncoder();
    const keyData = encoder.encode(this.secret);
    const messageData = encoder.encode(message);
    
    const key = await crypto.subtle.importKey(
      'raw',
      keyData,
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign']
    );
    
    const signature = await crypto.subtle.sign('HMAC', key, messageData);
    return Array.from(new Uint8Array(signature))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }
  
  async hashBody(body) {
    const encoder = new TextEncoder();
    const data = encoder.encode(typeof body === 'string' ? body : JSON.stringify(body));
    const hash = await crypto.subtle.digest('SHA-256', data);
    return Array.from(new Uint8Array(hash))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }
  
  generateNonce() {
    const array = new Uint8Array(16);
    crypto.getRandomValues(array);
    return Array.from(array)
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }
}

// Usage
const signer = new RequestSigner({
  secret: 'your-secret-key',
  algorithm: 'HMAC-SHA256',
  includeBody: true,
  includeTimestamp: true,
  includeNonce: true
});

async function signedFetch(url, options = {}) {
  const signedOptions = await signer.signRequest(url, options);
  return fetch(url, signedOptions);
}

// Example request
const response = await signedFetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ key: 'value' })
});
```

---

