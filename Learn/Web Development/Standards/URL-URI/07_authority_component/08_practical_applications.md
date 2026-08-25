## Practical Applications


### URL Construction

**Building URLs programmatically:**

```javascript
function buildAPIURL(config) {
  const url = new URL(`https://${config.host}`);
  
  if (config.port && config.port !== 443) {
    url.port = config.port;
  }
  
  if (config.username && config.password) {
    url.username = config.username;
    url.password = config.password;
  }
  
  url.pathname = config.path;
  
  return url.href;
}

// Usage
buildAPIURL({
  host: 'api.example.com',
  port: 8080,
  path: '/v1/users'
});
// Result: https://api.example.com:8080/v1/users
```

### Host Validation

**Validating user input:**

```javascript
function isValidHost(hostString) {
  // Try to parse as URL
  try {
    const url = new URL(`http://${hostString}/`);
    return true;
  } catch {
    return false;
  }
}

// IPv4 validation
function isIPv4(host) {
  const ipv4Regex = /^(\d{1,3}\.){3}\d{1,3}$/;
  if (!ipv4Regex.test(host)) return false;
  
  return host.split('.').every(octet => {
    const num = parseInt(octet, 10);
    return num >= 0 && num <= 255;
  });
}

// IPv6 validation
function isIPv6(host) {
  return host.startsWith('[') && 
         host.endsWith(']') && 
         host.includes(':');
}
```

### Port Extraction

**Extracting effective port (considering defaults):**

```javascript
function getEffectivePort(url) {
  const urlObj = new URL(url);
  
  if (urlObj.port) {
    return parseInt(urlObj.port, 10);
  }
  
  // Return default port for scheme
  const defaultPorts = {
    'http:': 80,
    'https:': 443,
    'ftp:': 21,
    'ws:': 80,
    'wss:': 443
  };
  
  return defaultPorts[urlObj.protocol] || null;
}

// Usage
getEffectivePort('http://example.com/');      // 80
getEffectivePort('https://example.com:8443/'); // 8443
```

### Security Filtering

**Blocking unsafe authority patterns:**

```javascript
function isSafeAuthority(urlString) {
  try {
    const url = new URL(urlString);
    
    // Block userinfo in web URLs
    if (['http:', 'https:'].includes(url.protocol)) {
      if (url.username || url.password) {
        return false;
      }
    }
    
    // Block private IP ranges (example)
    if (url.hostname.startsWith('192.168.') ||
        url.hostname.startsWith('10.') ||
        url.hostname === 'localhost' ||
        url.hostname === '127.0.0.1') {
      return false;
    }
    
    // Block non-standard ports for HTTP/HTTPS
    const port = parseInt(url.port, 10);
    if (port && (port < 80 || port > 65535)) {
      return false;
    }
    
    return true;
  } catch {
    return false;
  }
}
```

