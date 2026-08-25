## Error Response Formats with Fetch API


### Standard HTTP Error Structure

Common error response format used across REST APIs:

```javascript
// Typical error response structure
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "status": 400,
    "timestamp": "2024-12-18T10:30:00Z",
    "path": "/api/users",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      },
      {
        "field": "age",
        "message": "Must be at least 18"
      }
    ]
  }
}

// Parsing this format
async function handleStandardError(response) {
  const error = await response.json();
  
  return {
    code: error.error.code,
    message: error.error.message,
    status: error.error.status,
    fields: error.error.details?.map(d => ({
      field: d.field,
      message: d.message
    }))
  };
}
```

### RFC 7807 Problem Details

Standardized error format defined in RFC 7807:

```javascript
// RFC 7807 structure
{
  "type": "https://example.com/problems/validation-error",
  "title": "Validation Error",
  "status": 400,
  "detail": "The request contains invalid parameters",
  "instance": "/api/users/create",
  "invalid-params": [
    {
      "name": "email",
      "reason": "must be a valid email address"
    }
  ]
}

// Parsing RFC 7807 format
async function handleRFC7807Error(response) {
  const problem = await response.json();
  
  return {
    type: problem.type,
    title: problem.title,
    status: problem.status,
    detail: problem.detail,
    instance: problem.instance,
    extensions: Object.fromEntries(
      Object.entries(problem).filter(([key]) => 
        !['type', 'title', 'status', 'detail', 'instance'].includes(key)
      )
    )
  };
}

// Fetch with RFC 7807 handling
async function fetchWithRFC7807(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      'Accept': 'application/problem+json',
      ...options.headers
    }
  });
  
  if (!response.ok) {
    const contentType = response.headers.get('content-type');
    if (contentType?.includes('application/problem+json')) {
      const problem = await handleRFC7807Error(response);
      throw new RFC7807Error(problem);
    }
  }
  
  return response;
}
```

### JSON:API Error Format

Errors following the JSON:API specification:

```javascript
// JSON:API error structure
{
  "errors": [
    {
      "id": "error-123",
      "status": "422",
      "code": "UNPROCESSABLE_ENTITY",
      "title": "Invalid Attribute",
      "detail": "Email must be a valid email address",
      "source": {
        "pointer": "/data/attributes/email",
        "parameter": "email"
      },
      "meta": {
        "timestamp": "2024-12-18T10:30:00Z"
      }
    },
    {
      "id": "error-124",
      "status": "422",
      "code": "UNPROCESSABLE_ENTITY",
      "title": "Invalid Attribute",
      "detail": "Age must be at least 18",
      "source": {
        "pointer": "/data/attributes/age"
      }
    }
  ]
}

// Parsing JSON:API errors
async function handleJSONAPIError(response) {
  const data = await response.json();
  
  return data.errors.map(error => ({
    id: error.id,
    status: parseInt(error.status),
    code: error.code,
    title: error.title,
    detail: error.detail,
    source: error.source,
    meta: error.meta
  }));
}

// Custom error class for JSON:API
class JSONAPIError extends Error {
  constructor(errors) {
    const messages = errors.map(e => e.detail).join('; ');
    super(messages);
    this.name = 'JSONAPIError';
    this.errors = errors;
  }
  
  getFieldErrors() {
    return this.errors
      .filter(e => e.source?.pointer)
      .map(e => ({
        field: e.source.pointer.split('/').pop(),
        message: e.detail
      }));
  }
}
```

### GraphQL Error Format

Error structure used in GraphQL responses:

```javascript
// GraphQL error response
{
  "errors": [
    {
      "message": "Field 'emaill' doesn't exist on type 'User'",
      "locations": [
        {
          "line": 2,
          "column": 3
        }
      ],
      "path": ["user", "emaill"],
      "extensions": {
        "code": "GRAPHQL_VALIDATION_FAILED",
        "typeName": "User",
        "fieldName": "emaill"
      }
    }
  ],
  "data": null
}

// Parsing GraphQL errors
async function handleGraphQLError(response) {
  const result = await response.json();
  
  if (result.errors) {
    return result.errors.map(error => ({
      message: error.message,
      locations: error.locations,
      path: error.path,
      code: error.extensions?.code,
      extensions: error.extensions
    }));
  }
  
  return null;
}

// GraphQL fetch wrapper
async function fetchGraphQL(query, variables = {}) {
  const response = await fetch('/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ query, variables })
  });
  
  const result = await response.json();
  
  if (result.errors) {
    throw new GraphQLError(result.errors, result.data);
  }
  
  return result.data;
}

class GraphQLError extends Error {
  constructor(errors, partialData = null) {
    const messages = errors.map(e => e.message).join('; ');
    super(messages);
    this.name = 'GraphQLError';
    this.errors = errors;
    this.partialData = partialData;
  }
}
```

### Simple Error Formats

Minimalist error structures used by some APIs:

```javascript
// Simple message-only format
{
  "error": "Invalid email address"
}

// Simple code and message
{
  "code": 400,
  "message": "Bad Request"
}

// Status and error array
{
  "status": "error",
  "errors": ["Email is required", "Password too short"]
}

// Parsing various simple formats
async function handleSimpleError(response) {
  const data = await response.json();
  
  // Try different structures
  if (data.error && typeof data.error === 'string') {
    return { message: data.error };
  }
  
  if (data.message) {
    return { 
      code: data.code || response.status,
      message: data.message 
    };
  }
  
  if (data.errors && Array.isArray(data.errors)) {
    return {
      messages: data.errors
    };
  }
  
  // Fallback
  return { message: 'An error occurred', raw: data };
}
```

### Nested Error Details

Deep error structures with nested validation errors:

```javascript
// Nested validation errors
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "validationErrors": {
      "user": {
        "email": ["Invalid format", "Already exists"],
        "profile": {
          "age": ["Must be at least 18"],
          "address": {
            "zipCode": ["Invalid ZIP code format"]
          }
        }
      }
    }
  }
}

// Flatten nested errors
function flattenErrors(obj, prefix = '') {
  const errors = [];
  
  for (const [key, value] of Object.entries(obj)) {
    const path = prefix ? `${prefix}.${key}` : key;
    
    if (Array.isArray(value)) {
      value.forEach(msg => {
        errors.push({ field: path, message: msg });
      });
    } else if (typeof value === 'object' && value !== null) {
      errors.push(...flattenErrors(value, path));
    }
  }
  
  return errors;
}

// Usage
async function handleNestedError(response) {
  const data = await response.json();
  const flattened = flattenErrors(data.error.validationErrors);
  
  return {
    code: data.error.code,
    message: data.error.message,
    fields: flattened
  };
}
```

### Multi-Language Error Messages

Errors with internationalization support:

```javascript
// Multi-language error format
{
  "error": {
    "code": "INVALID_EMAIL",
    "message": {
      "en": "Invalid email address",
      "es": "Dirección de correo electrónico no válida",
      "fr": "Adresse e-mail invalide"
    },
    "field": "email"
  }
}

// Request errors with Accept-Language
async function fetchWithLanguage(url, locale = 'en', options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      'Accept-Language': locale,
      ...options.headers
    }
  });
  
  if (!response.ok) {
    const error = await response.json();
    return {
      code: error.error.code,
      message: error.error.message[locale] || error.error.message.en,
      field: error.error.field
    };
  }
  
  return response;
}

// Alternative: server returns localized message directly
{
  "error": {
    "code": "INVALID_EMAIL",
    "message": "Dirección de correo electrónico no válida",
    "locale": "es"
  }
}
```

### Rate Limit Error Format

Specialized format for rate limiting errors:

```javascript
// Rate limit error with retry information
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "status": 429,
    "retryAfter": 60,
    "limit": 100,
    "remaining": 0,
    "resetAt": "2024-12-18T11:00:00Z"
  }
}

// Headers-based rate limit info (alternative)
// X-RateLimit-Limit: 100
// X-RateLimit-Remaining: 0
// X-RateLimit-Reset: 1702900800
// Retry-After: 60

// Handling rate limit errors
async function handleRateLimitError(response) {
  const retryAfter = response.headers.get('Retry-After');
  const resetTime = response.headers.get('X-RateLimit-Reset');
  
  if (retryAfter) {
    return {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many requests',
      retryAfter: parseInt(retryAfter),
      resetAt: resetTime ? new Date(parseInt(resetTime) * 1000) : null
    };
  }
  
  // Fallback to body
  const data = await response.json();
  return {
    code: data.error.code,
    message: data.error.message,
    retryAfter: data.error.retryAfter,
    resetAt: data.error.resetAt ? new Date(data.error.resetAt) : null
  };
}

// Automatic retry with backoff
async function fetchWithRateLimitRetry(url, options = {}, maxRetries = 3) {
  let attempts = 0;
  
  while (attempts < maxRetries) {
    const response = await fetch(url, options);
    
    if (response.status === 429) {
      const error = await handleRateLimitError(response);
      const delay = (error.retryAfter || Math.pow(2, attempts)) * 1000;
      
      attempts++;
      if (attempts < maxRetries) {
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
    }
    
    return response;
  }
  
  throw new Error('Rate limit exceeded after max retries');
}
```

### Authentication Error Formats

Errors specific to authentication and authorization:

```javascript
// Authentication error with challenge
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication required",
    "status": 401,
    "challenge": "Bearer realm=\"API\", error=\"invalid_token\"",
    "loginUrl": "https://example.com/login",
    "expiresAt": "2024-12-18T10:00:00Z"
  }
}

// OAuth2 error format
{
  "error": "invalid_token",
  "error_description": "The access token expired",
  "error_uri": "https://docs.example.com/oauth/errors/invalid_token"
}

// Authorization error with required permissions
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Insufficient permissions",
    "status": 403,
    "requiredPermissions": ["users:write", "users:delete"],
    "currentPermissions": ["users:read"]
  }
}

// Handling auth errors
async function handleAuthError(response) {
  const data = await response.json();
  
  if (response.status === 401) {
    return {
      type: 'authentication',
      code: data.error.code || data.error,
      message: data.error.message || data.error_description,
      challenge: data.error.challenge,
      loginUrl: data.error.loginUrl
    };
  }
  
  if (response.status === 403) {
    return {
      type: 'authorization',
      code: data.error.code,
      message: data.error.message,
      requiredPermissions: data.error.requiredPermissions,
      currentPermissions: data.error.currentPermissions
    };
  }
}
```

### Validation Error Formats

Detailed validation error structures:

```javascript
// Field-level validation errors
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "status": 422,
    "fields": {
      "email": {
        "value": "invalid-email",
        "errors": [
          {
            "rule": "format",
            "message": "Must be a valid email address"
          }
        ]
      },
      "password": {
        "value": "123",
        "errors": [
          {
            "rule": "minLength",
            "message": "Must be at least 8 characters",
            "params": { "min": 8, "actual": 3 }
          },
          {
            "rule": "complexity",
            "message": "Must contain uppercase, lowercase, and numbers"
          }
        ]
      }
    }
  }
}

// Parse validation errors into usable format
function parseValidationErrors(errorData) {
  const fieldErrors = {};
  
  for (const [field, data] of Object.entries(errorData.error.fields)) {
    fieldErrors[field] = {
      value: data.value,
      messages: data.errors.map(e => e.message),
      rules: data.errors.map(e => ({
        name: e.rule,
        params: e.params
      }))
    };
  }
  
  return fieldErrors;
}

// Alternative: flat array format
{
  "errors": [
    {
      "field": "email",
      "code": "INVALID_FORMAT",
      "message": "Invalid email format",
      "value": "invalid-email"
    },
    {
      "field": "password",
      "code": "TOO_SHORT",
      "message": "Password must be at least 8 characters",
      "constraint": { "minLength": 8 }
    }
  ]
}
```

### Business Logic Error Formats

Errors representing business rule violations:

```javascript
// Business rule violation
{
  "error": {
    "code": "INSUFFICIENT_FUNDS",
    "message": "Cannot complete transaction",
    "status": 422,
    "context": {
      "accountBalance": 100.00,
      "requestedAmount": 150.00,
      "currency": "USD"
    },
    "suggestion": "Please reduce the amount or add funds to your account"
  }
}

// Conflict error
{
  "error": {
    "code": "RESOURCE_CONFLICT",
    "message": "Cannot delete user with active subscriptions",
    "status": 409,
    "conflicts": [
      {
        "resource": "subscription",
        "id": "sub_123",
        "reason": "Active subscription exists"
      }
    ],
    "resolution": {
      "action": "cancel_subscriptions",
      "url": "/api/users/123/subscriptions"
    }
  }
}

// Handling business errors
class BusinessError extends Error {
  constructor(errorData) {
    super(errorData.message);
    this.name = 'BusinessError';
    this.code = errorData.code;
    this.status = errorData.status;
    this.context = errorData.context;
    this.suggestion = errorData.suggestion;
    this.conflicts = errorData.conflicts;
    this.resolution = errorData.resolution;
  }
  
  isRetryable() {
    const retryableCodes = ['TEMPORARY_ERROR', 'SERVICE_UNAVAILABLE'];
    return retryableCodes.includes(this.code);
  }
  
  hasResolution() {
    return !!this.resolution;
  }
}
```

### Async Operation Error Formats

Errors from long-running or asynchronous operations:

```javascript
// Async operation error
{
  "error": {
    "code": "OPERATION_FAILED",
    "message": "Background job failed",
    "status": 500,
    "operationId": "job_123",
    "startedAt": "2024-12-18T10:00:00Z",
    "failedAt": "2024-12-18T10:05:00Z",
    "phase": "processing",
    "cause": {
      "code": "EXTERNAL_SERVICE_ERROR",
      "message": "Payment processor unavailable"
    },
    "statusUrl": "/api/operations/job_123"
  }
}

// Polling for operation status
async function pollOperationStatus(operationId, interval = 2000) {
  while (true) {
    const response = await fetch(`/api/operations/${operationId}`);
    const data = await response.json();
    
    if (data.status === 'completed') {
      return data.result;
    }
    
    if (data.status === 'failed') {
      throw new OperationError(data.error);
    }
    
    await new Promise(resolve => setTimeout(resolve, interval));
  }
}

class OperationError extends Error {
  constructor(errorData) {
    super(errorData.message);
    this.name = 'OperationError';
    this.operationId = errorData.operationId;
    this.phase = errorData.phase;
    this.cause = errorData.cause;
  }
}
```

### Batch Operation Error Formats

Errors from operations affecting multiple resources:

```javascript
// Batch operation with partial failures
{
  "status": "partial_success",
  "summary": {
    "total": 10,
    "successful": 7,
    "failed": 3
  },
  "results": [
    {
      "id": "item_1",
      "status": "success",
      "data": { "id": "123" }
    },
    {
      "id": "item_2",
      "status": "error",
      "error": {
        "code": "DUPLICATE",
        "message": "Item already exists"
      }
    },
    {
      "id": "item_3",
      "status": "error",
      "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid email format",
        "field": "email"
      }
    }
  ]
}

// Parsing batch results
function parseBatchResults(batchResponse) {
  const successful = [];
  const failed = [];
  
  batchResponse.results.forEach(result => {
    if (result.status === 'success') {
      successful.push({
        id: result.id,
        data: result.data
      });
    } else {
      failed.push({
        id: result.id,
        error: result.error
      });
    }
  });
  
  return {
    summary: batchResponse.summary,
    successful,
    failed,
    hasErrors: failed.length > 0
  };
}

// Batch operation error class
class BatchError extends Error {
  constructor(batchResponse) {
    const failedCount = batchResponse.summary.failed;
    super(`Batch operation failed: ${failedCount} items`);
    this.name = 'BatchError';
    this.summary = batchResponse.summary;
    this.results = batchResponse.results;
    this.failed = batchResponse.results.filter(r => r.status === 'error');
  }
  
  getFailedIds() {
    return this.failed.map(r => r.id);
  }
  
  getErrorsByCode(code) {
    return this.failed.filter(r => r.error.code === code);
  }
}
```

### Error Response with Trace Information

Errors including debugging and tracing data:

```javascript
// Error with trace information
{
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected error occurred",
    "status": 500,
    "requestId": "req_abc123",
    "timestamp": "2024-12-18T10:30:00Z",
    "trace": {
      "traceId": "trace_xyz789",
      "spanId": "span_456",
      "parentSpanId": "span_123"
    },
    "debug": {
      "service": "user-service",
      "version": "1.2.3",
      "instance": "instance-5"
    }
  }
}

// Production vs development error details
// Production response (minimal)
{
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected error occurred",
    "requestId": "req_abc123"
  }
}

// Development response (detailed)
{
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "Database connection timeout",
    "requestId": "req_abc123",
    "stack": "Error: Connection timeout\n    at Database.connect...",
    "query": "SELECT * FROM users WHERE id = $1",
    "params": [123]
  }
}

// Handling errors with trace info
async function fetchWithTracing(url, options = {}) {
  const requestId = generateRequestId();
  
  const response = await fetch(url, {
    ...options,
    headers: {
      'X-Request-ID': requestId,
      ...options.headers
    }
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new TracedError({
      ...error.error,
      clientRequestId: requestId
    });
  }
  
  return response;
}

class TracedError extends Error {
  constructor(errorData) {
    super(errorData.message);
    this.name = 'TracedError';
    this.code = errorData.code;
    this.requestId = errorData.requestId;
    this.clientRequestId = errorData.clientRequestId;
    this.trace = errorData.trace;
  }
  
  getTraceUrl() {
    if (this.trace?.traceId) {
      return `https://trace.example.com/${this.trace.traceId}`;
    }
    return null;
  }
}
```

### Unified Error Handler

Comprehensive error handler supporting multiple formats:

```javascript
class UnifiedErrorHandler {
  constructor(options = {}) {
    this.defaultFormat = options.defaultFormat || 'standard';
    this.formats = {
      standard: this.parseStandardError,
      rfc7807: this.parseRFC7807Error,
      jsonapi: this.parseJSONAPIError,
      graphql: this.parseGraphQLError,
      simple: this.parseSimpleError
    };
  }
  
  async handle(response) {
    const contentType = response.headers.get('content-type');
    
    // Detect format from content-type
    let format = this.defaultFormat;
    if (contentType?.includes('application/problem+json')) {
      format = 'rfc7807';
    } else if (contentType?.includes('application/vnd.api+json')) {
      format = 'jsonapi';
    }
    
    try {
      const data = await response.json();
      const parser = this.formats[format] || this.parseStandardError;
      return parser.call(this, response, data);
    } catch (e) {
      // Fallback for non-JSON responses
      const text = await response.text();
      return this.parseTextError(response, text);
    }
  }
  
  parseStandardError(response, data) {
    return {
      format: 'standard',
      code: data.error?.code || 'UNKNOWN_ERROR',
      message: data.error?.message || data.message || 'An error occurred',
      status: response.status,
      details: data.error?.details || [],
      raw: data
    };
  }
  
  parseRFC7807Error(response, data) {
    return {
      format: 'rfc7807',
      code: data.type?.split('/').pop() || 'UNKNOWN_ERROR',
      message: data.detail || data.title,
      status: data.status,
      title: data.title,
      instance: data.instance,
      extensions: this.extractExtensions(data),
      raw: data
    };
  }
  
  parseJSONAPIError(response, data) {
    const errors = data.errors || [];
    return {
      format: 'jsonapi',
      code: errors[0]?.code || 'UNKNOWN_ERROR',
      message: errors.map(e => e.detail).join('; '),
      status: response.status,
      errors: errors,
      raw: data
    };
  }
  
  parseGraphQLError(response, data) {
    const errors = data.errors || [];
    return {
      format: 'graphql',
      code: errors[0]?.extensions?.code || 'UNKNOWN_ERROR',
      message: errors.map(e => e.message).join('; '),
      status: response.status,
      errors: errors,
      partialData: data.data,
      raw: data
    };
  }
  
  parseSimpleError(response, data) {
    return {
      format: 'simple',
      code: data.code || 'UNKNOWN_ERROR',
      message: data.error || data.message || 'An error occurred',
      status: response.status,
      raw: data
    };
  }
  
  parseTextError(response, text) {
    return {
      format: 'text',
      code: 'UNKNOWN_ERROR',
      message: text || response.statusText,
      status: response.status,
      raw: text
    };
  }
  
  extractExtensions(data) {
    const reserved = ['type', 'title', 'status', 'detail', 'instance'];
    return Object.fromEntries(
      Object.entries(data).filter(([key]) => !reserved.includes(key))
    );
  }
}

// Usage
const errorHandler = new UnifiedErrorHandler();

async function robustFetch(url, options = {}) {
  const response = await fetch(url, options);
  
  if (!response.ok) {
    const error = await errorHandler.handle(response);
    throw new APIError(error);
  }
  
  return response;
}

class APIError extends Error {
  constructor(errorData) {
    super(errorData.message);
    this.name = 'APIError';
    this.code = errorData.code;
    this.status = errorData.status;
    this.format = errorData.format;
    this.details = errorData.details;
    this.errors = errorData.errors;
    this.raw = errorData.raw;
  }
}
```

---

