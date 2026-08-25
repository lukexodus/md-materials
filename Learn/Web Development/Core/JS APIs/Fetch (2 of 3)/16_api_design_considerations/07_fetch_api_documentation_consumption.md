## Fetch API Documentation Consumption


### Reading API Documentation Structure

API documentation typically follows standard organizational patterns. Common sections include:

- Base URL and versioning information
- Authentication requirements
- Endpoint descriptions with HTTP methods
- Request parameters (query, path, body)
- Request headers
- Response formats and status codes
- Error codes and handling
- Rate limiting policies
- Examples and code samples

### Extracting Base URL Information

Identify the base URL from documentation:

```javascript
// Documentation states: "Base URL: https://api.example.com/v2"
const BASE_URL = 'https://api.example.com/v2';

// Make requests relative to base
const response = await fetch(`${BASE_URL}/users`);
```

Some APIs use different base URLs for different environments:

```javascript
const BASE_URLS = {
  production: 'https://api.example.com/v2',
  staging: 'https://staging-api.example.com/v2',
  development: 'https://dev-api.example.com/v2'
};

const BASE_URL = BASE_URLS[process.env.NODE_ENV] || BASE_URLS.production;
```

### Understanding Endpoint Specifications

Documentation lists endpoints with HTTP methods:

```
GET    /users          - List all users
GET    /users/:id      - Get specific user
POST   /users          - Create new user
PUT    /users/:id      - Update user
PATCH  /users/:id      - Partial update user
DELETE /users/:id      - Delete user
```

Translating to fetch calls:

```javascript
// GET /users
const response = await fetch(`${BASE_URL}/users`);

// GET /users/:id
const userId = 123;
const response = await fetch(`${BASE_URL}/users/${userId}`);

// POST /users
const response = await fetch(`${BASE_URL}/users`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'John', email: 'john@example.com' })
});

// PUT /users/:id
const response = await fetch(`${BASE_URL}/users/${userId}`, {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'John Updated', email: 'john@example.com' })
});

// PATCH /users/:id
const response = await fetch(`${BASE_URL}/users/${userId}`, {
  method: 'PATCH',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'John Updated' })
});

// DELETE /users/:id
const response = await fetch(`${BASE_URL}/users/${userId}`, {
  method: 'DELETE'
});
```

### Interpreting Path Parameters

Path parameters are placeholders in the URL:

```
Documentation: GET /users/:userId/posts/:postId
```

Implementation:

```javascript
function getUserPost(userId, postId) {
  return fetch(`${BASE_URL}/users/${userId}/posts/${postId}`);
}

const response = await getUserPost(123, 456);
```

### Parsing Query Parameter Documentation

Documentation formats for query parameters:

```
GET /users
Query Parameters:
  - page (integer, optional): Page number, default 1
  - limit (integer, optional): Items per page, default 20, max 100
  - sort (string, optional): Sort field, format: field or -field
  - filter (string, optional): Filter expression
  - fields (string, optional): Comma-separated field names
```

Implementation:

```javascript
function buildQueryString(params) {
  const searchParams = new URLSearchParams();
  
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null) {
      searchParams.append(key, value);
    }
  }
  
  return searchParams.toString();
}

const params = {
  page: 2,
  limit: 50,
  sort: '-createdAt',
  filter: 'status:active',
  fields: 'id,name,email'
};

const queryString = buildQueryString(params);
const response = await fetch(`${BASE_URL}/users?${queryString}`);
```

### Understanding Request Body Schemas

Documentation provides request body structure:

```
POST /users
Request Body:
{
  "name": "string (required, max 100 chars)",
  "email": "string (required, valid email format)",
  "age": "integer (optional, min 18, max 120)",
  "roles": "array of strings (optional)",
  "address": {
    "street": "string (optional)",
    "city": "string (optional)",
    "country": "string (optional, ISO 3166-1 alpha-2)"
  }
}
```

Implementation with validation:

```javascript
function createUser(userData) {
  // Validate based on documentation
  if (!userData.name || userData.name.length > 100) {
    throw new Error('Invalid name');
  }
  
  if (!userData.email || !isValidEmail(userData.email)) {
    throw new Error('Invalid email');
  }
  
  if (userData.age !== undefined && (userData.age < 18 || userData.age > 120)) {
    throw new Error('Invalid age');
  }
  
  return fetch(`${BASE_URL}/users`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(userData)
  });
}

const response = await createUser({
  name: 'John Doe',
  email: 'john@example.com',
  age: 30,
  roles: ['user', 'moderator'],
  address: {
    city: 'New York',
    country: 'US'
  }
});
```

### Reading Authentication Documentation

Common authentication patterns in documentation:

**API Key in Header:**

```
Authentication: API Key
Header: X-API-Key: your_api_key
```

```javascript
const API_KEY = 'your_api_key_here';

const response = await fetch(`${BASE_URL}/users`, {
  headers: {
    'X-API-Key': API_KEY
  }
});
```

**Bearer Token:**

```
Authentication: Bearer Token
Header: Authorization: Bearer <token>
```

```javascript
const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

const response = await fetch(`${BASE_URL}/users`, {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

**Basic Authentication:**

```
Authentication: Basic Auth
Header: Authorization: Basic <base64(username:password)>
```

```javascript
const username = 'user';
const password = 'pass';
const encoded = btoa(`${username}:${password}`);

const response = await fetch(`${BASE_URL}/users`, {
  headers: {
    'Authorization': `Basic ${encoded}`
  }
});
```

**OAuth 2.0:**

```
Authentication: OAuth 2.0
Header: Authorization: Bearer <access_token>
Token endpoint: POST /oauth/token
```

```javascript
// Get token first
const tokenResponse = await fetch(`${BASE_URL}/oauth/token`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({
    grant_type: 'client_credentials',
    client_id: 'your_client_id',
    client_secret: 'your_client_secret'
  })
});

const { access_token } = await tokenResponse.json();

// Use token
const response = await fetch(`${BASE_URL}/users`, {
  headers: {
    'Authorization': `Bearer ${access_token}`
  }
});
```

### Interpreting Response Documentation

Response structure documentation:

```
GET /users/:id
Response: 200 OK
{
  "id": "integer",
  "name": "string",
  "email": "string",
  "createdAt": "ISO 8601 timestamp",
  "profile": {
    "bio": "string or null",
    "avatar": "URL string or null"
  }
}
```

Handling the response:

```javascript
const response = await fetch(`${BASE_URL}/users/123`);

if (response.ok) {
  const user = await response.json();
  
  console.log(user.id);          // integer
  console.log(user.name);        // string
  console.log(user.email);       // string
  console.log(new Date(user.createdAt)); // Date object
  console.log(user.profile.bio); // string or null
  console.log(user.profile.avatar); // string or null
}
```

### Understanding Status Codes

Documentation lists possible status codes:

```
Status Codes:
  200 OK - Success
  201 Created - Resource created
  204 No Content - Success with no body
  400 Bad Request - Invalid input
  401 Unauthorized - Authentication required
  403 Forbidden - Insufficient permissions
  404 Not Found - Resource not found
  422 Unprocessable Entity - Validation error
  429 Too Many Requests - Rate limit exceeded
  500 Internal Server Error - Server error
  503 Service Unavailable - Service down
```

Implementing status code handling:

```javascript
async function handleResponse(response) {
  if (response.ok) {
    // 200-299 status codes
    if (response.status === 204) {
      return null; // No content
    }
    return response.json();
  }
  
  // Handle errors based on status code
  switch (response.status) {
    case 400:
      const badRequest = await response.json();
      throw new Error(`Bad Request: ${badRequest.message}`);
    
    case 401:
      throw new Error('Authentication required');
    
    case 403:
      throw new Error('Insufficient permissions');
    
    case 404:
      throw new Error('Resource not found');
    
    case 422:
      const validation = await response.json();
      throw new Error(`Validation error: ${JSON.stringify(validation.errors)}`);
    
    case 429:
      const retryAfter = response.headers.get('Retry-After');
      throw new Error(`Rate limit exceeded. Retry after ${retryAfter} seconds`);
    
    case 500:
      throw new Error('Internal server error');
    
    case 503:
      throw new Error('Service unavailable');
    
    default:
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }
}

try {
  const response = await fetch(`${BASE_URL}/users/123`);
  const data = await handleResponse(response);
  console.log(data);
} catch (error) {
  console.error(error.message);
}
```

### Parsing Error Response Format

Documentation specifies error response structure:

```
Error Response Format:
{
  "error": {
    "code": "string (error code)",
    "message": "string (human-readable)",
    "details": "array or object (optional)"
  }
}
```

Implementation:

```javascript
async function fetchWithErrorHandling(url, options) {
  const response = await fetch(url, options);
  
  if (!response.ok) {
    const errorData = await response.json();
    const error = new Error(errorData.error.message);
    error.code = errorData.error.code;
    error.details = errorData.error.details;
    error.status = response.status;
    throw error;
  }
  
  return response.json();
}

try {
  const data = await fetchWithErrorHandling(`${BASE_URL}/users/invalid`);
} catch (error) {
  console.error('Error code:', error.code);
  console.error('Error message:', error.message);
  console.error('Error details:', error.details);
  console.error('HTTP status:', error.status);
}
```

### Understanding Rate Limiting

Documentation describes rate limits:

```
Rate Limiting:
  - 1000 requests per hour per API key
  - Rate limit info in response headers:
    - X-RateLimit-Limit: Total requests allowed
    - X-RateLimit-Remaining: Requests remaining
    - X-RateLimit-Reset: Unix timestamp of reset time
  - 429 status when exceeded
  - Retry-After header indicates wait time
```

Implementation:

```javascript
class RateLimitedFetcher {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
    this.rateLimitInfo = {};
  }
  
  async fetch(endpoint, options = {}) {
    const response = await fetch(`${this.baseUrl}${endpoint}`, options);
    
    // Extract rate limit info from headers
    this.rateLimitInfo = {
      limit: parseInt(response.headers.get('X-RateLimit-Limit')),
      remaining: parseInt(response.headers.get('X-RateLimit-Remaining')),
      reset: parseInt(response.headers.get('X-RateLimit-Reset'))
    };
    
    if (response.status === 429) {
      const retryAfter = parseInt(response.headers.get('Retry-After'));
      throw new Error(`Rate limit exceeded. Retry after ${retryAfter} seconds`);
    }
    
    return response;
  }
  
  getRateLimitInfo() {
    return this.rateLimitInfo;
  }
  
  getSecondsUntilReset() {
    const now = Math.floor(Date.now() / 1000);
    return Math.max(0, this.rateLimitInfo.reset - now);
  }
}

const fetcher = new RateLimitedFetcher(BASE_URL);
const response = await fetcher.fetch('/users');
console.log('Rate limit info:', fetcher.getRateLimitInfo());
console.log('Seconds until reset:', fetcher.getSecondsUntilReset());
```

### Reading Pagination Documentation

Common pagination patterns:

**Offset-based:**

```
Pagination: Offset-based
Parameters:
  - limit: Items per page (default: 20, max: 100)
  - offset: Number of items to skip (default: 0)
Response includes:
  - total: Total number of items
  - items: Array of data
```

```javascript
async function fetchPaginated(endpoint, page = 1, limit = 20) {
  const offset = (page - 1) * limit;
  const params = new URLSearchParams({ limit, offset });
  
  const response = await fetch(`${BASE_URL}${endpoint}?${params}`);
  const data = await response.json();
  
  return {
    items: data.items,
    total: data.total,
    page,
    totalPages: Math.ceil(data.total / limit),
    hasNext: (offset + limit) < data.total,
    hasPrev: page > 1
  };
}

const result = await fetchPaginated('/users', 2, 50);
```

**Cursor-based:**

```
Pagination: Cursor-based
Parameters:
  - cursor: Opaque cursor string (optional)
  - limit: Items per page (default: 20)
Response includes:
  - items: Array of data
  - nextCursor: Cursor for next page (null if last page)
  - prevCursor: Cursor for previous page (null if first page)
```

```javascript
async function fetchCursorPaginated(endpoint, cursor = null, limit = 20) {
  const params = new URLSearchParams({ limit });
  if (cursor) {
    params.append('cursor', cursor);
  }
  
  const response = await fetch(`${BASE_URL}${endpoint}?${params}`);
  const data = await response.json();
  
  return {
    items: data.items,
    nextCursor: data.nextCursor,
    prevCursor: data.prevCursor,
    hasNext: data.nextCursor !== null,
    hasPrev: data.prevCursor !== null
  };
}

let cursor = null;
const pages = [];

// Fetch first 3 pages
for (let i = 0; i < 3; i++) {
  const result = await fetchCursorPaginated('/users', cursor);
  pages.push(result.items);
  
  if (!result.hasNext) break;
  cursor = result.nextCursor;
}
```

**Page-based:**

```
Pagination: Page-based
Parameters:
  - page: Page number (default: 1)
  - per_page: Items per page (default: 20, max: 100)
Response includes:
  - data: Array of items
  - meta: { current_page, total_pages, total_count, per_page }
```

```javascript
async function fetchPageBased(endpoint, page = 1, perPage = 20) {
  const params = new URLSearchParams({ page, per_page: perPage });
  
  const response = await fetch(`${BASE_URL}${endpoint}?${params}`);
  const json = await response.json();
  
  return {
    items: json.data,
    currentPage: json.meta.current_page,
    totalPages: json.meta.total_pages,
    totalCount: json.meta.total_count,
    perPage: json.meta.per_page,
    hasNext: json.meta.current_page < json.meta.total_pages,
    hasPrev: json.meta.current_page > 1
  };
}

const result = await fetchPageBased('/users', 3, 50);
```

### Understanding Content-Type Requirements

Documentation specifies required Content-Type headers:

```
Content-Type Requirements:
  - JSON requests: application/json
  - Form submissions: application/x-www-form-urlencoded
  - Multipart forms: multipart/form-data
  - Plain text: text/plain
```

Implementation:

```javascript
// JSON request
const jsonResponse = await fetch(`${BASE_URL}/users`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'John', email: 'john@example.com' })
});

// Form-encoded request
const formResponse = await fetch(`${BASE_URL}/login`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({
    username: 'john',
    password: 'secret123'
  })
});

// Multipart form (file upload)
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('description', 'Profile photo');

const uploadResponse = await fetch(`${BASE_URL}/upload`, {
  method: 'POST',
  body: formData // Content-Type automatically set to multipart/form-data
});
```

### Parsing Filtering Documentation

Documentation describes filtering syntax:

```
Filtering:
  Format: field:operator:value
  Operators:
    - eq (equals)
    - ne (not equals)
    - gt (greater than)
    - gte (greater than or equal)
    - lt (less than)
    - lte (less than or equal)
    - in (in list)
    - like (pattern match)
  Multiple filters: Separate with comma
  Example: status:eq:active,age:gte:18,country:in:US,CA,UK
```

Implementation:

```javascript
class FilterBuilder {
  constructor() {
    this.filters = [];
  }
  
  equals(field, value) {
    this.filters.push(`${field}:eq:${value}`);
    return this;
  }
  
  notEquals(field, value) {
    this.filters.push(`${field}:ne:${value}`);
    return this;
  }
  
  greaterThan(field, value) {
    this.filters.push(`${field}:gt:${value}`);
    return this;
  }
  
  greaterThanOrEqual(field, value) {
    this.filters.push(`${field}:gte:${value}`);
    return this;
  }
  
  lessThan(field, value) {
    this.filters.push(`${field}:lt:${value}`);
    return this;
  }
  
  lessThanOrEqual(field, value) {
    this.filters.push(`${field}:lte:${value}`);
    return this;
  }
  
  in(field, values) {
    this.filters.push(`${field}:in:${values.join(',')}`);
    return this;
  }
  
  like(field, pattern) {
    this.filters.push(`${field}:like:${pattern}`);
    return this;
  }
  
  build() {
    return this.filters.join(',');
  }
}

const filter = new FilterBuilder()
  .equals('status', 'active')
  .greaterThanOrEqual('age', 18)
  .in('country', ['US', 'CA', 'UK'])
  .build();

const response = await fetch(`${BASE_URL}/users?filter=${encodeURIComponent(filter)}`);
```

### Reading Versioning Information

API versioning strategies in documentation:

**URL Path Versioning:**

```
Versioning: URL path
Format: /v{version}/resource
Current: v2
Example: https://api.example.com/v2/users
```

```javascript
const API_VERSION = 'v2';
const BASE_URL = `https://api.example.com/${API_VERSION}`;

const response = await fetch(`${BASE_URL}/users`);
```

**Header Versioning:**

```
Versioning: Accept header
Format: Accept: application/vnd.example.v{version}+json
Current: v2
Example: Accept: application/vnd.example.v2+json
```

```javascript
const API_VERSION = '2';

const response = await fetch(`${BASE_URL}/users`, {
  headers: {
    'Accept': `application/vnd.example.v${API_VERSION}+json`
  }
});
```

**Query Parameter Versioning:**

```
Versioning: Query parameter
Format: ?version={version}
Current: 2
Example: https://api.example.com/users?version=2
```

```javascript
const API_VERSION = '2';

const response = await fetch(`${BASE_URL}/users?version=${API_VERSION}`);
```

### Understanding Field Selection

Documentation for field selection:

```
Field Selection:
  Parameter: fields
  Format: Comma-separated field names
  Nested fields: Use dot notation
  Example: ?fields=id,name,email,profile.bio
```

Implementation:

```javascript
function selectFields(fields) {
  return fields.join(',');
}

const selectedFields = selectFields(['id', 'name', 'email', 'profile.bio', 'profile.avatar']);
const response = await fetch(`${BASE_URL}/users?fields=${selectedFields}`);

// Alternative: Fluent interface
class FieldSelector {
  constructor() {
    this.fields = [];
  }
  
  select(...fields) {
    this.fields.push(...fields);
    return this;
  }
  
  build() {
    return this.fields.join(',');
  }
}

const fields = new FieldSelector()
  .select('id', 'name', 'email')
  .select('profile.bio', 'profile.avatar')
  .build();

const response2 = await fetch(`${BASE_URL}/users?fields=${fields}`);
```

### Reading Webhook Documentation

Webhook configuration from documentation:

```
Webhooks:
  Endpoint: POST /webhooks
  Events: user.created, user.updated, user.deleted
  Payload: JSON with event data
  Headers: X-Webhook-Signature for verification
  Retry: 3 attempts with exponential backoff
```

Setting up webhooks:

```javascript
async function createWebhook(url, events) {
  const response = await fetch(`${BASE_URL}/webhooks`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      url,
      events,
      active: true
    })
  });
  
  return response.json();
}

const webhook = await createWebhook(
  'https://myapp.com/webhook/handler',
  ['user.created', 'user.updated', 'user.deleted']
);
```

### Understanding Batch Operations

Batch operation documentation:

```
Batch Operations:
  Endpoint: POST /batch
  Request Body:
    {
      "operations": [
        { "method": "POST", "path": "/users", "body": {...} },
        { "method": "GET", "path": "/users/123" },
        { "method": "DELETE", "path": "/users/456" }
      ]
    }
  Response: Array of individual responses
```

Implementation:

```javascript
async function batchOperation(operations) {
  const response = await fetch(`${BASE_URL}/batch`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ operations })
  });
  
  return response.json();
}

const results = await batchOperation([
  {
    method: 'POST',
    path: '/users',
    body: { name: 'John', email: 'john@example.com' }
  },
  {
    method: 'GET',
    path: '/users/123'
  },
  {
    method: 'DELETE',
    path: '/users/456'
  }
]);

results.forEach((result, index) => {
  console.log(`Operation ${index}:`, result.status, result.body);
});
```

### Reading Timeout Recommendations

Documentation specifies timeout behavior:

```
Timeouts:
  - Default server timeout: 30 seconds
  - Long-running operations: Use async endpoints
  - Recommended client timeout: 60 seconds
  - Async operations return 202 Accepted with Location header
```

Implementation:

```javascript
async function fetchWithTimeout(url, options = {}, timeoutMs = 60000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    return response;
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeoutMs}ms`);
    }
    
    throw error;
  }
}

// Regular request with timeout
const response = await fetchWithTimeout(`${BASE_URL}/users`, {}, 30000);

// Long-running async operation
const asyncResponse = await fetchWithTimeout(`${BASE_URL}/reports/generate`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ type: 'annual', year: 2024 })
});

if (asyncResponse.status === 202) {
  const location = asyncResponse.headers.get('Location');
  console.log('Check status at:', location);
  
  // Poll for completion
  let completed = false;
  while (!completed) {
    await new Promise(resolve => setTimeout(resolve, 5000)); // Wait 5s
    
    const statusResponse = await fetch(location);
    const status = await statusResponse.json();
    
    if (status.state === 'completed') {
      completed = true;
      console.log('Result:', status.result);
    } else if (status.state === 'failed') {
      throw new Error('Operation failed: ' + status.error);
    }
  }
}
```

### Building SDK from Documentation

Creating a reusable API client:

```javascript
class APIClient {
  constructor(config) {
    this.baseUrl = config.baseUrl;
    this.apiKey = config.apiKey;
    this.version = config.version || 'v2';
    this.timeout = config.timeout || 30000;
  }
  
  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}/${this.version}${endpoint}`;
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);
    
    const defaultHeaders = {
      'Content-Type': 'application/json',
      'X-API-Key': this.apiKey
    };
    
    try {
      const response = await fetch(url, {
        ...options,
        headers: {
          ...defaultHeaders,
          ...options.headers
        },
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error.message);
      }
      
      if (response.status === 204) {
        return null;
      }
      
      return response.json();
    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  }
  
  // User endpoints
  async listUsers(params = {}) {
    const queryString = new URLSearchParams(params).toString();
    return this.request(`/users${queryString ? '?' + queryString : ''}`);
  }
  
  async getUser(userId) {
    return this.request(`/users/${userId}`);
  }
  
  async createUser(userData) {
    return this.request('/users', {
      method: 'POST',
      body: JSON.stringify(userData)
    });
  }
  
  async updateUser(userId, userData) {
    return this.request(`/users/${userId}`, {
      method: 'PUT',
      body: JSON.stringify(userData)
    });
  }
  
  async deleteUser(userId) {
    return this.request(`/users/${userId}`, {
      method: 'DELETE'
    });
  }
}

// Usage
const client = new APIClient({
  baseUrl: 'https://api.example.com',
  apiKey: 'your_api_key',
  version: 'v2',
  timeout: 60000
});

const users = await client.listUsers({ page: 1, limit: 50 });
const user = await client.getUser(123);
const newUser = await client.createUser({ name: 'John', email: 'john@example.com' });
```

---

