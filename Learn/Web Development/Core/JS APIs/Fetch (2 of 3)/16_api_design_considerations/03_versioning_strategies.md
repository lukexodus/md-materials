## Versioning Strategies


### URL Path Versioning

#### Version in Base Path

```javascript
const API_V1 = 'https://api.example.com/v1';
const API_V2 = 'https://api.example.com/v2';

async function getUserV1(id) {
  const response = await fetch(`${API_V1}/users/${id}`);
  return response.json();
}

async function getUserV2(id) {
  const response = await fetch(`${API_V2}/users/${id}`);
  return response.json();
}

// Client specifying version
const user = await getUserV2(123);
```

#### Version-Specific Endpoints

```javascript
class APIClient {
  constructor(version = 'v2') {
    this.baseUrl = `https://api.example.com/${version}`;
  }
  
  async fetch(endpoint, options = {}) {
    const response = await fetch(`${this.baseUrl}${endpoint}`, options);
    
    if (!response.ok) {
      throw new Error(`API ${this.version} error: ${response.status}`);
    }
    
    return response.json();
  }
  
  async getUser(id) {
    return this.fetch(`/users/${id}`);
  }
  
  async createPost(data) {
    return this.fetch('/posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
  }
}

// Usage
const clientV1 = new APIClient('v1');
const clientV2 = new APIClient('v2');

const legacyUser = await clientV1.getUser(123);
const modernUser = await clientV2.getUser(123);
```

#### Nested Resource Versioning

```javascript
// Version applies to specific resources only
const BASE_URL = 'https://api.example.com';

async function getUsers() {
  // Unversioned endpoint
  const response = await fetch(`${BASE_URL}/users`);
  return response.json();
}

async function getAnalyticsV2(userId) {
  // Versioned nested resource
  const response = await fetch(`${BASE_URL}/users/${userId}/analytics/v2`);
  return response.json();
}

async function getReportsV3(userId) {
  // Different version for different resource
  const response = await fetch(`${BASE_URL}/users/${userId}/reports/v3`);
  return response.json();
}
```

### Header-Based Versioning

#### Accept Header Versioning

```javascript
async function fetchWithVersion(url, version) {
  const response = await fetch(url, {
    headers: {
      'Accept': `application/vnd.example.${version}+json`
    }
  });
  
  return response.json();
}

// Usage
const dataV1 = await fetchWithVersion('https://api.example.com/users', 'v1');
const dataV2 = await fetchWithVersion('https://api.example.com/users', 'v2');
```

#### Custom Version Header

```javascript
async function apiRequest(endpoint, version = '2.0') {
  const response = await fetch(`https://api.example.com${endpoint}`, {
    headers: {
      'API-Version': version,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }
  
  // Server may return different version than requested
  const responseVersion = response.headers.get('API-Version');
  const data = await response.json();
  
  return { data, version: responseVersion };
}

// Client requesting specific version
const result = await apiRequest('/users/123', '2.1');
console.log(`Received version: ${result.version}`);
```

#### Content Negotiation

```javascript
class VersionedAPI {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }
  
  async request(endpoint, options = {}) {
    const { version = 'latest', acceptType = 'json', ...fetchOptions } = options;
    
    const headers = {
      'Accept': this.buildAcceptHeader(version, acceptType),
      ...fetchOptions.headers
    };
    
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...fetchOptions,
      headers
    });
    
    return this.parseResponse(response);
  }
  
  buildAcceptHeader(version, type) {
    const versionPart = version === 'latest' ? '' : `.${version}`;
    return `application/vnd.example${versionPart}+${type}`;
  }
  
  async parseResponse(response) {
    const contentType = response.headers.get('Content-Type');
    
    if (contentType.includes('json')) {
      return response.json();
    } else if (contentType.includes('xml')) {
      return response.text();
    }
    
    return response.blob();
  }
}

// Usage
const api = new VersionedAPI('https://api.example.com');

const v1Data = await api.request('/users', { version: 'v1' });
const v2Data = await api.request('/users', { version: 'v2' });
const latestData = await api.request('/users', { version: 'latest' });
```

### Query Parameter Versioning

#### Simple Version Parameter

```javascript
async function fetchWithQueryVersion(endpoint, version) {
  const url = new URL(`https://api.example.com${endpoint}`);
  url.searchParams.set('version', version);
  
  const response = await fetch(url);
  return response.json();
}

// Usage
const users = await fetchWithQueryVersion('/users', '2');
const posts = await fetchWithQueryVersion('/posts', '3');
```

#### API Version Parameter

```javascript
class QueryVersionAPI {
  constructor(baseUrl, defaultVersion = '1') {
    this.baseUrl = baseUrl;
    this.defaultVersion = defaultVersion;
  }
  
  async get(endpoint, params = {}, version = null) {
    const url = new URL(`${this.baseUrl}${endpoint}`);
    
    // Add version parameter
    url.searchParams.set('api_version', version || this.defaultVersion);
    
    // Add other query parameters
    Object.entries(params).forEach(([key, value]) => {
      url.searchParams.set(key, value);
    });
    
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }
    
    return response.json();
  }
}

// Usage
const api = new QueryVersionAPI('https://api.example.com', '2');

const users = await api.get('/users', { limit: 10 });
const usersV3 = await api.get('/users', { limit: 10 }, '3');
```

#### Mixed Versioning Strategy

```javascript
async function flexibleVersionRequest(endpoint, options = {}) {
  const {
    version,
    versionMethod = 'header', // 'header', 'query', or 'path'
    ...fetchOptions
  } = options;
  
  let url = `https://api.example.com${endpoint}`;
  const headers = { ...fetchOptions.headers };
  
  switch (versionMethod) {
    case 'path':
      url = `https://api.example.com/v${version}${endpoint}`;
      break;
      
    case 'query':
      const urlObj = new URL(url);
      urlObj.searchParams.set('version', version);
      url = urlObj.toString();
      break;
      
    case 'header':
    default:
      headers['API-Version'] = version;
      break;
  }
  
  const response = await fetch(url, {
    ...fetchOptions,
    headers
  });
  
  return response.json();
}

// Usage - same interface, different versioning methods
const pathVersioned = await flexibleVersionRequest('/users', {
  version: '2',
  versionMethod: 'path'
});

const headerVersioned = await flexibleVersionRequest('/users', {
  version: '2',
  versionMethod: 'header'
});

const queryVersioned = await flexibleVersionRequest('/users', {
  version: '2',
  versionMethod: 'query'
});
```

### Version Negotiation

#### Client Version Preference

```javascript
class NegotiatingClient {
  constructor(baseUrl, supportedVersions) {
    this.baseUrl = baseUrl;
    this.supportedVersions = supportedVersions; // ['2.0', '1.5', '1.0']
  }
  
  async request(endpoint, options = {}) {
    // Request with version preference list
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers: {
        'Accept-Version': this.supportedVersions.join(', '),
        ...options.headers
      }
    });
    
    // Check which version server returned
    const serverVersion = response.headers.get('API-Version');
    
    if (!this.supportedVersions.includes(serverVersion)) {
      console.warn(`Server returned unsupported version: ${serverVersion}`);
    }
    
    const data = await response.json();
    return { data, version: serverVersion };
  }
}

// Usage
const client = new NegotiatingClient('https://api.example.com', ['2.0', '1.5']);
const result = await client.request('/users');
console.log(`Using API version: ${result.version}`);
```

### Fallback Version Handling

```javascript
async function requestWithFallback(endpoint, preferredVersion, fallbackVersions = []) {
  const versions = [preferredVersion, ...fallbackVersions];
  
  for (const version of versions) {
    try {
      const response = await fetch(`https://api.example.com/${version}${endpoint}`);
      
      if (response.ok) {
        const data = await response.json();
        return { data, version, success: true };
      }
      
      // Try next version on 404 or 410 (Gone)
      if (response.status === 404 || response.status === 410) {
        console.warn(`Version ${version} not available, trying next...`);
        continue;
      }
      
      // For other errors, throw
      throw new Error(`Request failed with status ${response.status}`);
      
    } catch (error) {
      // If this was the last version, throw the error
      if (version === versions[versions.length - 1]) {
        throw new Error(`All versions failed. Last error: ${error.message}`);
      }
      
      console.warn(`Version ${version} failed: ${error.message}`);
    }
  }
  
  // This shouldn't be reached, but just in case
  throw new Error('No versions succeeded');
}

// Usage
try {
  const result = await requestWithFallback('/users/123', 'v3', ['v2', 'v1']);
  console.log(`Successfully fetched data using version: ${result.version}`);
  console.log(result.data);
} catch (error) {
  console.error('Request failed:', error.message);
}
```

### Media Type Versioning

```javascript
async function requestWithMediaType(endpoint, version) {
  const response = await fetch(`https://api.example.com${endpoint}`, {
    headers: {
      'Accept': `application/vnd.myapi.${version}+json`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }
  
  return response.json();
}

// Usage
const data = await requestWithMediaType('/users/123', 'v2');
```

### Semantic Versioning in URLs

```javascript
async function requestWithSemanticVersion(endpoint, major, minor = 0, patch = 0) {
  const version = patch > 0 ? `v${major}.${minor}.${patch}` : `v${major}.${minor}`;
  
  const response = await fetch(`https://api.example.com/${version}${endpoint}`, {
    headers: {
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }
  
  return response.json();
}

// Usage
const data = await requestWithSemanticVersion('/users/123', 2, 1, 0);
```

### Version Deprecation Warnings

```javascript
async function requestWithDeprecationCheck(endpoint, version) {
  const response = await fetch(`https://api.example.com/${version}${endpoint}`);
  
  // Check for deprecation warnings in response headers
  const deprecationWarning = response.headers.get('Deprecation');
  const sunset = response.headers.get('Sunset');
  const link = response.headers.get('Link');
  
  if (deprecationWarning) {
    console.warn(`⚠️ API version ${version} is deprecated`);
    if (sunset) {
      console.warn(`Sunset date: ${sunset}`);
    }
    if (link) {
      console.warn(`Migration guide: ${link}`);
    }
  }
  
  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }
  
  return response.json();
}

// Usage
const data = await requestWithDeprecationCheck('/users/123', 'v1');
```

### Version Detection from Response

```javascript
async function requestWithVersionDetection(endpoint) {
  const response = await fetch(`https://api.example.com${endpoint}`);
  
  // Detect version from response header
  const apiVersion = response.headers.get('API-Version') || 
                     response.headers.get('X-API-Version');
  
  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }
  
  const data = await response.json();
  
  return {
    data,
    version: apiVersion,
    timestamp: new Date().toISOString()
  };
}

// Usage
const result = await requestWithVersionDetection('/users/123');
console.log(`Response from API version: ${result.version}`);
```

### Content Negotiation Based Versioning

```javascript
async function requestWithContentNegotiation(endpoint, acceptedVersions) {
  const acceptHeader = acceptedVersions
    .map(v => `application/vnd.myapi.${v}+json`)
    .join(', ');
  
  const response = await fetch(`https://api.example.com${endpoint}`, {
    headers: {
      'Accept': acceptHeader,
      'Content-Type': 'application/json'
    }
  });
  
  const contentType = response.headers.get('Content-Type');
  const versionMatch = contentType?.match(/vnd\.myapi\.([^+]+)/);
  const usedVersion = versionMatch ? versionMatch[1] : 'unknown';
  
  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }
  
  const data = await response.json();
  
  return { data, usedVersion };
}

// Usage
const result = await requestWithContentNegotiation('/users/123', ['v3', 'v2', 'v1']);
console.log(`API responded with version: ${result.usedVersion}`);
```

### Version Range Requests

```javascript
async function requestWithVersionRange(endpoint, minVersion, maxVersion) {
  const response = await fetch(`https://api.example.com${endpoint}`, {
    headers: {
      'Accept-Version': `>=${minVersion} <=${maxVersion}`,
      'Content-Type': 'application/json'
    }
  });
  
  const actualVersion = response.headers.get('API-Version');
  
  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }
  
  const data = await response.json();
  
  return {
    data,
    requestedRange: `${minVersion}-${maxVersion}`,
    actualVersion
  };
}

// Usage
const result = await requestWithVersionRange('/users/123', '2.0', '3.0');
console.log(`Requested: ${result.requestedRange}, Got: ${result.actualVersion}`);
```

### Default Version with Override

```javascript
const DEFAULT_API_VERSION = 'v2';

async function requestWithDefaultVersion(endpoint, versionOverride = null) {
  const version = versionOverride || DEFAULT_API_VERSION;
  
  const response = await fetch(`https://api.example.com/${version}${endpoint}`, {
    headers: {
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }
  
  return response.json();
}

// Usage
const data1 = await requestWithDefaultVersion('/users/123'); // Uses v2
const data2 = await requestWithDefaultVersion('/users/123', 'v3'); // Uses v3
```

### Version Migration Helper

```javascript
async function migrateVersion(endpoint, fromVersion, toVersion, transformFn) {
  // Fetch from old version
  const oldResponse = await fetch(`https://api.example.com/${fromVersion}${endpoint}`);
  
  if (!oldResponse.ok) {
    throw new Error(`Failed to fetch from ${fromVersion}`);
  }
  
  const oldData = await oldResponse.json();
  
  // Transform data for new version
  const transformedData = transformFn ? transformFn(oldData) : oldData;
  
  // Verify with new version
  const newResponse = await fetch(`https://api.example.com/${toVersion}${endpoint}`);
  
  if (!newResponse.ok) {
    console.warn(`New version ${toVersion} not available, using transformed old data`);
    return { data: transformedData, migrated: true, version: toVersion };
  }
  
  const newData = await newResponse.json();
  
  return { data: newData, migrated: false, version: toVersion };
}

// Usage
const result = await migrateVersion('/users/123', 'v1', 'v2', (oldData) => ({
  ...oldData,
  // Transform old format to new format
  fullName: `${oldData.firstName} ${oldData.lastName}`
}));
```

---

