## GraphQL Integration


### Basic GraphQL Requests

GraphQL queries and mutations use POST requests with a JSON body containing the query string and variables. The fetch API handles GraphQL requests identically to REST endpoints, but with a standardized request structure.

```javascript
const query = `
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
    }
  }
`;

const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    query,
    variables: { id: '123' }
  })
});

const { data, errors } = await response.json();
```

GraphQL responses always return HTTP 200 status codes, even for query errors. Errors appear in the `errors` array within the response body, requiring application-level error handling rather than HTTP status code checking.

### Query Structure and Variables

#### Parameterized Queries

Variables separate query structure from dynamic values, enabling query reuse and preventing injection vulnerabilities. Variables use type declarations in the query definition.

```javascript
// Query with multiple variables
const query = `
  query GetProducts($category: String!, $limit: Int, $sortBy: SortOrder) {
    products(category: $category, limit: $limit, sortBy: $sortBy) {
      id
      name
      price
      inventory {
        quantity
        warehouse
      }
    }
  }
`;

const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    query,
    variables: {
      category: 'electronics',
      limit: 20,
      sortBy: 'PRICE_ASC'
    }
  })
});
```

#### Fragments for Reusable Fields

Fragments define reusable field selections, reducing duplication across multiple queries. They're particularly useful when fetching the same entity type in different contexts.

```javascript
const query = `
  fragment ProductFields on Product {
    id
    name
    price
    imageUrl
    rating
  }
  
  query GetProductsAndFeatured {
    products(limit: 10) {
      ...ProductFields
      category
    }
    featuredProducts {
      ...ProductFields
      promotionText
    }
  }
`;

const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ query })
});
```

### Mutations

Mutations modify server-side data and follow the same request structure as queries, but use the `mutation` operation type. Mutations typically return the modified data for client-side updates.

```javascript
const mutation = `
  mutation CreateProduct($input: CreateProductInput!) {
    createProduct(input: $input) {
      id
      name
      price
      createdAt
    }
  }
`;

const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    query: mutation,
    variables: {
      input: {
        name: 'New Product',
        price: 29.99,
        category: 'electronics'
      }
    }
  })
});

const { data, errors } = await response.json();

if (errors) {
  console.error('Mutation failed:', errors);
} else {
  console.log('Created product:', data.createProduct);
}
```

### Batching Multiple Operations

GraphQL supports multiple queries or mutations in a single request, reducing network overhead when fetching related data. Each operation requires a unique name.

```javascript
const batchedOperations = `
  query GetUser($userId: ID!) {
    user(id: $userId) {
      id
      name
      email
    }
  }
  
  query GetUserPosts($userId: ID!) {
    posts(authorId: $userId) {
      id
      title
      createdAt
    }
  }
  
  query GetUserComments($userId: ID!) {
    comments(authorId: $userId) {
      id
      text
      createdAt
    }
  }
`;

const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    query: batchedOperations,
    variables: { userId: '123' }
  })
});

const { data } = await response.json();
// Access: data.user, data.posts, data.comments
```

Servers must explicitly support batched operations. Some implementations use array syntax for truly independent operations:

```javascript
const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify([
    {
      query: 'query { user(id: "1") { name } }',
    },
    {
      query: 'query { posts { title } }',
    }
  ])
});

const results = await response.json(); // Array of responses
```

### Error Handling

#### GraphQL Error Structure

GraphQL errors contain detailed information about what failed and where in the query structure the failure occurred. The `errors` array includes messages, paths, and extensions for debugging.

```javascript
const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    query: 'query { user(id: "invalid") { name email } }'
  })
});

const result = await response.json();

if (result.errors) {
  result.errors.forEach(error => {
    console.error('Message:', error.message);
    console.error('Path:', error.path); // e.g., ['user', 'name']
    console.error('Locations:', error.locations); // Query line/column
    console.error('Extensions:', error.extensions); // Additional context
  });
}

// Partial data may still exist
if (result.data) {
  console.log('Partial data:', result.data);
}
```

#### Network and HTTP Errors

Network failures and HTTP errors require separate handling from GraphQL-level errors. Check both HTTP response status and GraphQL errors.

```javascript
async function graphqlRequest(query, variables) {
  let response;
  
  try {
    response = await fetch('https://api.example.com/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query, variables })
    });
  } catch (error) {
    // Network error (no connection, DNS failure, etc.)
    throw new Error(`Network error: ${error.message}`);
  }
  
  if (!response.ok) {
    // HTTP error (500, 503, etc.)
    throw new Error(`HTTP error: ${response.status} ${response.statusText}`);
  }
  
  const result = await response.json();
  
  if (result.errors) {
    // GraphQL error (query syntax, validation, resolver errors)
    throw new Error(`GraphQL errors: ${result.errors.map(e => e.message).join(', ')}`);
  }
  
  return result.data;
}
```

### Authentication and Authorization

#### Header-Based Authentication

GraphQL APIs typically use bearer tokens in the Authorization header. Some implementations also support API keys or custom authentication headers.

```javascript
const query = `
  query GetPrivateData {
    currentUser {
      id
      email
      privateNotes
    }
  }
`;

const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${accessToken}`
  },
  body: JSON.stringify({ query })
});
```

#### Token Refresh Handling

Long-lived sessions require token refresh logic to maintain authentication. Implement automatic retry with refreshed tokens for 401 responses.

```javascript
async function graphqlRequestWithRefresh(query, variables) {
  let token = getAccessToken();
  
  let response = await fetch('https://api.example.com/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ query, variables })
  });
  
  // If unauthorized, attempt token refresh
  if (response.status === 401) {
    token = await refreshAccessToken();
    
    response = await fetch('https://api.example.com/graphql', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ query, variables })
    });
  }
  
  return response.json();
}
```

### Caching Strategies

#### Manual Cache Implementation

GraphQL's flexible query structure complicates caching compared to REST. Implement normalized caching by parsing GraphQL responses and storing entities by ID.

```javascript
class GraphQLCache {
  constructor() {
    this.entities = new Map(); // Map<entityType, Map<id, entity>>
    this.queries = new Map();  // Map<queryHash, result>
  }
  
  normalizeAndCache(data, typename) {
    if (!data) return;
    
    if (Array.isArray(data)) {
      return data.map(item => this.normalizeAndCache(item, typename));
    }
    
    if (data.__typename) {
      const type = data.__typename;
      if (!this.entities.has(type)) {
        this.entities.set(type, new Map());
      }
      
      if (data.id) {
        this.entities.get(type).set(data.id, data);
      }
    }
    
    // Recursively normalize nested objects
    Object.keys(data).forEach(key => {
      if (typeof data[key] === 'object' && data[key] !== null) {
        data[key] = this.normalizeAndCache(data[key], typename);
      }
    });
    
    return data;
  }
  
  getEntity(type, id) {
    return this.entities.get(type)?.get(id);
  }
  
  cacheQuery(query, variables, result) {
    const hash = this.hashQuery(query, variables);
    this.queries.set(hash, {
      result,
      timestamp: Date.now()
    });
  }
  
  getQuery(query, variables, maxAge = 60000) {
    const hash = this.hashQuery(query, variables);
    const cached = this.queries.get(hash);
    
    if (cached && Date.now() - cached.timestamp < maxAge) {
      return cached.result;
    }
    
    return null;
  }
  
  hashQuery(query, variables) {
    return `${query}::${JSON.stringify(variables)}`;
  }
}

// Usage
const cache = new GraphQLCache();

async function cachedGraphQLRequest(query, variables) {
  const cached = cache.getQuery(query, variables);
  if (cached) return cached;
  
  const response = await fetch('https://api.example.com/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables })
  });
  
  const result = await response.json();
  
  if (result.data) {
    cache.normalizeAndCache(result.data);
    cache.cacheQuery(query, variables, result);
  }
  
  return result;
}
```

#### HTTP Caching with GET Requests

Some GraphQL servers support GET requests for queries, enabling standard HTTP caching mechanisms. Encode the query and variables as URL parameters.

```javascript
function buildGraphQLGetURL(endpoint, query, variables) {
  const params = new URLSearchParams({
    query: query,
    variables: JSON.stringify(variables)
  });
  
  return `${endpoint}?${params.toString()}`;
}

const url = buildGraphQLGetURL(
  'https://api.example.com/graphql',
  'query GetUser($id: ID!) { user(id: $id) { name } }',
  { id: '123' }
);

const response = await fetch(url, {
  method: 'GET',
  headers: {
    'Accept': 'application/json'
  }
});
```

This approach allows CDN and browser caching based on URL, but only works for queries (not mutations) and may hit URL length limits with complex queries.

### Persisted Queries

Persisted queries reduce bandwidth by sending only a query ID instead of the full query string. The server stores pre-registered queries and executes them by ID.

```javascript
// Client sends hash/ID instead of full query
const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    id: '9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d', // Query hash
    variables: { userId: '123' }
  })
});
```

#### Automatic Persisted Queries (APQ)

APQ allows clients to attempt queries by hash first, falling back to full query if the server doesn't have it cached. The server automatically persists queries on first use.

```javascript
async function apqRequest(query, variables) {
  const queryHash = await sha256(query);
  
  // First attempt: send only the hash
  let response = await fetch('https://api.example.com/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      extensions: {
        persistedQuery: {
          version: 1,
          sha256Hash: queryHash
        }
      },
      variables
    })
  });
  
  let result = await response.json();
  
  // If query not found, send full query
  if (result.errors?.some(e => e.message.includes('PersistedQueryNotFound'))) {
    response = await fetch('https://api.example.com/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query,
        variables,
        extensions: {
          persistedQuery: {
            version: 1,
            sha256Hash: queryHash
          }
        }
      })
    });
    
    result = await response.json();
  }
  
  return result;
}

async function sha256(message) {
  const msgBuffer = new TextEncoder().encode(message);
  const hashBuffer = await crypto.subtle.digest('SHA-256', msgBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}
```

### File Uploads

GraphQL file uploads require multipart form data rather than JSON, following the GraphQL multipart request specification.

```javascript
async function uploadFile(file, mutation, variables) {
  const operations = {
    query: mutation,
    variables: variables
  };
  
  const map = {
    '0': ['variables.file']
  };
  
  const formData = new FormData();
  formData.append('operations', JSON.stringify(operations));
  formData.append('map', JSON.stringify(map));
  formData.append('0', file);
  
  const response = await fetch('https://api.example.com/graphql', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`
      // Don't set Content-Type; browser sets it with boundary
    },
    body: formData
  });
  
  return response.json();
}

// Usage
const mutation = `
  mutation UploadFile($file: Upload!) {
    uploadFile(file: $file) {
      url
      filename
      mimetype
    }
  }
`;

const fileInput = document.querySelector('input[type="file"]');
const file = fileInput.files[0];

const result = await uploadFile(file, mutation, { file: null });
```

Multiple file uploads map each file to its variable path:

```javascript
const operations = {
  query: mutation,
  variables: {
    files: [null, null]
  }
};

const map = {
  '0': ['variables.files.0'],
  '1': ['variables.files.1']
};

const formData = new FormData();
formData.append('operations', JSON.stringify(operations));
formData.append('map', JSON.stringify(map));
formData.append('0', file1);
formData.append('1', file2);
```

### Subscriptions via HTTP

GraphQL subscriptions typically use WebSockets, but some implementations support HTTP-based subscriptions through polling or server-sent events.

#### Polling Implementation

Implement subscriptions by repeatedly querying for changes at regular intervals. Include a timestamp or cursor to fetch only new data.

```javascript
async function pollSubscription(query, variables, callback, interval = 5000) {
  let lastFetchTime = new Date().toISOString();
  
  const poll = async () => {
    const response = await fetch('https://api.example.com/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query,
        variables: {
          ...variables,
          since: lastFetchTime
        }
      })
    });
    
    const result = await response.json();
    
    if (result.data) {
      callback(result.data);
      lastFetchTime = new Date().toISOString();
    }
  };
  
  const intervalId = setInterval(poll, interval);
  await poll(); // Initial fetch
  
  return () => clearInterval(intervalId); // Return cleanup function
}

// Usage
const unsubscribe = await pollSubscription(
  `
    query GetNewMessages($since: DateTime!) {
      messages(since: $since) {
        id
        text
        createdAt
      }
    }
  `,
  {},
  (data) => {
    console.log('New messages:', data.messages);
  },
  3000 // Poll every 3 seconds
);

// Later: unsubscribe();
```

#### Server-Sent Events (SSE)

Some GraphQL implementations support subscriptions via SSE, providing real-time updates over HTTP without WebSocket complexity.

```javascript
function subscribeViaSSE(query, variables, callback) {
  const url = new URL('https://api.example.com/graphql/stream');
  url.searchParams.set('query', query);
  url.searchParams.set('variables', JSON.stringify(variables));
  
  const eventSource = new EventSource(url.toString());
  
  eventSource.onmessage = (event) => {
    const result = JSON.parse(event.data);
    callback(result.data);
  };
  
  eventSource.onerror = (error) => {
    console.error('SSE error:', error);
    eventSource.close();
  };
  
  return () => eventSource.close();
}

// Usage
const unsubscribe = subscribeViaSSE(
  `
    subscription OnNewMessage {
      messageAdded {
        id
        text
        author {
          name
        }
      }
    }
  `,
  {},
  (data) => {
    console.log('New message:', data.messageAdded);
  }
);
```

### Request Optimization

#### Query Complexity Analysis

Large queries with deep nesting or multiple connections can overwhelm servers. Some GraphQL servers reject queries exceeding complexity thresholds.

```javascript
// Potentially expensive query
const complexQuery = `
  query GetOrganization($id: ID!) {
    organization(id: $id) {
      name
      users(first: 100) {
        edges {
          node {
            name
            posts(first: 50) {
              edges {
                node {
                  title
                  comments(first: 100) {
                    edges {
                      node {
                        text
                        author {
                          name
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
`;
```

Mitigate complexity by:

- Limiting pagination sizes
- Reducing nesting depth
- Splitting into multiple smaller queries
- Using fragments to identify reusable patterns

#### Field Selection Optimization

Request only needed fields to reduce response payload size and server processing time. Avoid requesting large nested structures when only parent data is needed.

```javascript
// Inefficient: requesting unused fields
const bloatedQuery = `
  query GetUsers {
    users {
      id
      name
      email
      bio
      avatar
      posts {
        id
        title
        content
        createdAt
      }
      settings {
        theme
        notifications
        privacy
      }
    }
  }
`;

// Efficient: request only necessary fields
const optimizedQuery = `
  query GetUsers {
    users {
      id
      name
      avatar
    }
  }
`;
```

### Introspection Queries

GraphQL servers expose their schema through introspection, allowing clients to discover available types, queries, and mutations.

```javascript
const introspectionQuery = `
  query IntrospectionQuery {
    __schema {
      queryType {
        name
      }
      mutationType {
        name
      }
      types {
        name
        kind
        description
        fields {
          name
          type {
            name
            kind
          }
        }
      }
    }
  }
`;

const response = await fetch('https://api.example.com/graphql', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ query: introspectionQuery })
});

const { data } = await response.json();
console.log('Available types:', data.__schema.types);
```

Production servers often disable introspection for security reasons. Use introspection during development to explore the API and generate type definitions.

### Type Safety and Code Generation

#### Generated Types from Schema

Use tools like GraphQL Code Generator to create TypeScript types from the GraphQL schema, providing type safety for queries and responses.

```javascript
// Generated types (example output)
interface GetUserQuery {
  user: {
    id: string;
    name: string;
    email: string;
  } | null;
}

interface GetUserQueryVariables {
  id: string;
}

// Type-safe query function
async function getUser(
  id: string
): Promise<GetUserQuery> {
  const query = `
    query GetUser($id: ID!) {
      user(id: $id) {
        id
        name
        email
      }
    }
  `;
  
  const response = await fetch('https://api.example.com/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      query,
      variables: { id }
    })
  });
  
  const { data } = await response.json();
  return data as GetUserQuery;
}
```

### Rate Limiting and Throttling

GraphQL rate limiting differs from REST due to variable query complexity. Track rate limits by query points or complexity rather than request count.

```javascript
async function graphqlRequestWithRateLimit(query, variables) {
  const response = await fetch('https://api.example.com/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables })
  });
  
  // Check rate limit headers
  const remaining = response.headers.get('X-RateLimit-Remaining');
  const reset = response.headers.get('X-RateLimit-Reset');
  const cost = response.headers.get('X-RateLimit-Cost');
  
  console.log(`Query cost: ${cost}, Remaining: ${remaining}, Resets: ${new Date(parseInt(reset) * 1000)}`);
  
  if (remaining === '0') {
    const waitTime = parseInt(reset) * 1000 - Date.now();
    console.warn(`Rate limit exceeded. Waiting ${waitTime}ms`);
    await new Promise(resolve => setTimeout(resolve, waitTime));
    return graphqlRequestWithRateLimit(query, variables);
  }
  
  return response.json();
}
```

### Pagination Patterns

#### Cursor-Based Pagination

GraphQL commonly uses cursor-based pagination following the Relay connection specification. Cursors provide stable pagination even as data changes.

```javascript
async function fetchAllPages(query, variables = {}) {
  const allItems = [];
  let hasNextPage = true;
  let cursor = null;
  
  while (hasNextPage) {
    const response = await fetch('https://api.example.com/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query,
        variables: {
          ...variables,
          after: cursor,
          first: 50
        }
      })
    });
    
    const { data } = await response.json();
    const connection = data.products;
    
    allItems.push(...connection.edges.map(edge => edge.node));
    
    hasNextPage = connection.pageInfo.hasNextPage;
    cursor = connection.pageInfo.endCursor;
  }
  
  return allItems;
}

// Usage
const query = `
  query GetProducts($after: String, $first: Int!) {
    products(after: $after, first: $first) {
      edges {
        node {
          id
          name
          price
        }
        cursor
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
`;

const allProducts = await fetchAllPages(query);
```

#### Offset-Based Pagination

Some GraphQL APIs use simpler offset/limit pagination. This approach is less stable when data changes but simpler to implement.

```javascript
async function fetchPage(page, pageSize = 20) {
  const query = `
    query GetProducts($offset: Int!, $limit: Int!) {
      products(offset: $offset, limit: $limit) {
        id
        name
        price
      }
      productsCount
    }
  `;
  
  const response = await fetch('https://api.example.com/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      query,
      variables: {
        offset: page * pageSize,
        limit: pageSize
      }
    })
  });
  
  const { data } = await response.json();
  
  return {
    items: data.products,
    total: data.productsCount,
    totalPages: Math.ceil(data.productsCount / pageSize)
  };
}
```

### Debugging and Logging

#### Request/Response Logging

Log GraphQL requests and responses for debugging, including query complexity, execution time, and errors.

```javascript
async function graphqlRequestWithLogging(query, variables) {
  const startTime = performance.now();
  
  console.group('GraphQL Request');
  console.log('Query:', query);
  console.log('Variables:', variables);
  
  const response = await fetch('https://api.example.com/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables })
  });
  
  const result = await response.json();
  const endTime = performance.now();
  
  console.log('Duration:', `${(endTime - startTime).toFixed(2)}ms`);
  console.log('Status:', response.status);
  
  if (result.errors) {
    console.error('Errors:', result.errors);
  }
  
  if (result.data) {
    console.log('Data:', result.data);
  }
  
  console.groupEnd();
  
  return result;
}
```

#### Query Name Tracking

Include operation names in all queries and mutations to improve server-side logging and debugging.

```javascript
// Without operation name (harder to debug)
const query = `
  query {
    user(id: "123") {
      name
    }
  }
`;

// With operation name (easier to track in logs)
const query = `
  query GetUserProfile {
    user(id: "123") {
      name
    }
  }
`;
```

Server logs can then identify specific queries by name rather than just "anonymous query", making performance monitoring and error tracking more effective.

---

