## Request Chaining with Fetch API


### Sequential Request Patterns

#### Basic Promise Chaining

```javascript
fetch('/api/user/123')
  .then(response => response.json())
  .then(user => {
    console.log('User fetched:', user);
    return fetch(`/api/posts?userId=${user.id}`);
  })
  .then(response => response.json())
  .then(posts => {
    console.log('Posts fetched:', posts);
    return fetch(`/api/comments?postId=${posts[0].id}`);
  })
  .then(response => response.json())
  .then(comments => {
    console.log('Comments fetched:', comments);
  })
  .catch(error => {
    console.error('Chain failed:', error);
  });
```

#### Async/Await Sequential Requests

```javascript
async function fetchUserData(userId) {
  try {
    const userResponse = await fetch(`/api/user/${userId}`);
    const user = await userResponse.json();
    
    const postsResponse = await fetch(`/api/posts?userId=${user.id}`);
    const posts = await postsResponse.json();
    
    const commentsResponse = await fetch(`/api/comments?postId=${posts[0].id}`);
    const comments = await commentsResponse.json();
    
    return { user, posts, comments };
  } catch (error) {
    console.error('Failed to fetch user data:', error);
    throw error;
  }
}
```

### Dependent Request Chains

#### Data Transformation Pipeline

```javascript
async function processDataPipeline(initialId) {
  const step1 = await fetch(`/api/data/${initialId}`)
    .then(res => res.json());
  
  const step2 = await fetch('/api/transform', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(step1)
  }).then(res => res.json());
  
  const step3 = await fetch('/api/enrich', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(step2)
  }).then(res => res.json());
  
  const final = await fetch('/api/finalize', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(step3)
  }).then(res => res.json());
  
  return final;
}
```

#### Conditional Chaining

```javascript
async function conditionalFetch(userId) {
  const user = await fetch(`/api/user/${userId}`).then(r => r.json());
  
  if (user.isPremium) {
    const premiumData = await fetch(`/api/premium/${userId}`)
      .then(r => r.json());
    user.premiumFeatures = premiumData;
  }
  
  if (user.hasNotifications) {
    const notifications = await fetch(`/api/notifications/${userId}`)
      .then(r => r.json());
    user.notifications = notifications;
  }
  
  return user;
}
```

#### Nested Resource Loading

```javascript
async function fetchNestedResources(organizationId) {
  const org = await fetch(`/api/organizations/${organizationId}`)
    .then(r => r.json());
  
  const departments = await fetch(`/api/departments?orgId=${org.id}`)
    .then(r => r.json());
  
  const departmentsWithEmployees = await Promise.all(
    departments.map(async dept => {
      const employees = await fetch(`/api/employees?deptId=${dept.id}`)
        .then(r => r.json());
      
      return { ...dept, employees };
    })
  );
  
  return {
    ...org,
    departments: departmentsWithEmployees
  };
}
```

### Parallel Request Execution

#### Promise.all for Independent Requests

```javascript
async function fetchParallelData(userId) {
  const [user, posts, notifications, settings] = await Promise.all([
    fetch(`/api/user/${userId}`).then(r => r.json()),
    fetch(`/api/posts?userId=${userId}`).then(r => r.json()),
    fetch(`/api/notifications/${userId}`).then(r => r.json()),
    fetch(`/api/settings/${userId}`).then(r => r.json())
  ]);
  
  return { user, posts, notifications, settings };
}
```

#### Promise.allSettled for Fault Tolerance

```javascript
async function fetchWithFallback(userId) {
  const results = await Promise.allSettled([
    fetch(`/api/user/${userId}`).then(r => r.json()),
    fetch(`/api/posts?userId=${userId}`).then(r => r.json()),
    fetch(`/api/activity/${userId}`).then(r => r.json()),
    fetch(`/api/recommendations/${userId}`).then(r => r.json())
  ]);
  
  return {
    user: results[0].status === 'fulfilled' ? results[0].value : null,
    posts: results[1].status === 'fulfilled' ? results[1].value : [],
    activity: results[2].status === 'fulfilled' ? results[2].value : [],
    recommendations: results[3].status === 'fulfilled' ? results[3].value : []
  };
}
```

#### Promise.race for Fastest Response

```javascript
async function fetchFromMultipleSources(endpoint) {
  const sources = [
    'https://api1.example.com',
    'https://api2.example.com',
    'https://api3.example.com'
  ];
  
  const response = await Promise.race(
    sources.map(baseUrl => 
      fetch(`${baseUrl}${endpoint}`).then(r => r.json())
    )
  );
  
  return response;
}
```

### Chain Builder Pattern

#### Fluent Request API

```javascript
class RequestChain {
  constructor(baseUrl = '') {
    this.baseUrl = baseUrl;
    this.requests = [];
    this.results = [];
  }
  
  get(url, options = {}) {
    this.requests.push({
      method: 'GET',
      url,
      options
    });
    return this;
  }
  
  post(url, data, options = {}) {
    this.requests.push({
      method: 'POST',
      url,
      data,
      options
    });
    return this;
  }
  
  then(callback) {
    this.requests.push({
      type: 'transform',
      callback
    });
    return this;
  }
  
  async execute() {
    let previousResult = null;
    
    for (const request of this.requests) {
      if (request.type === 'transform') {
        previousResult = await request.callback(previousResult);
        this.results.push(previousResult);
      } else {
        const url = this.baseUrl + request.url;
        const options = {
          ...request.options,
          method: request.method
        };
        
        if (request.data) {
          options.body = JSON.stringify(request.data);
          options.headers = {
            'Content-Type': 'application/json',
            ...options.headers
          };
        }
        
        const response = await fetch(url, options);
        
        if (!response.ok) {
          throw new Error(`Request failed: ${response.status}`);
        }
        
        previousResult = await response.json();
        this.results.push(previousResult);
      }
    }
    
    return previousResult;
  }
  
  getResults() {
    return this.results;
  }
}

// Usage
const result = await new RequestChain('https://api.example.com')
  .get('/user/123')
  .then(user => ({ userId: user.id, name: user.name }))
  .get('/posts?userId=${user.id}')
  .then(posts => posts.filter(p => p.published))
  .execute();
```

#### Template String URL Builder

```javascript
class ChainedFetch {
  constructor(baseUrl = '') {
    this.baseUrl = baseUrl;
    this.context = {};
  }
  
  async fetch(url, options = {}) {
    const interpolatedUrl = this.interpolate(url);
    const fullUrl = this.baseUrl + interpolatedUrl;
    
    const response = await fetch(fullUrl, options);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const data = await response.json();
    this.context = { ...this.context, ...data };
    
    return this;
  }
  
  interpolate(template) {
    return template.replace(/\${(\w+)}/g, (match, key) => {
      return this.context[key] || match;
    });
  }
  
  async get(url, options = {}) {
    return this.fetch(url, { ...options, method: 'GET' });
  }
  
  async post(url, data, options = {}) {
    return this.fetch(url, {
      ...options,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      },
      body: JSON.stringify(data)
    });
  }
  
  getContext() {
    return this.context;
  }
}

// Usage
const chain = new ChainedFetch('https://api.example.com');

await chain
  .get('/user/123')
  .get('/posts?userId=${id}')  // Uses id from previous response
  .get('/comments?postId=${posts[0].id}');  // Uses posts from previous response

const data = chain.getContext();
```

### Pagination Chains

#### Cursor-Based Pagination

```javascript
async function fetchAllPages(initialUrl) {
  const allData = [];
  let nextUrl = initialUrl;
  
  while (nextUrl) {
    const response = await fetch(nextUrl);
    const data = await response.json();
    
    allData.push(...data.items);
    nextUrl = data.nextPageUrl;
  }
  
  return allData;
}
```

#### Page Number Pagination

```javascript
async function fetchPaginatedData(baseUrl, maxPages = Infinity) {
  const allItems = [];
  let page = 1;
  let hasMore = true;
  
  while (hasMore && page <= maxPages) {
    const response = await fetch(`${baseUrl}?page=${page}&limit=50`);
    const data = await response.json();
    
    allItems.push(...data.items);
    
    hasMore = data.hasMore || data.items.length === 50;
    page++;
  }
  
  return allItems;
}
```

#### Async Iterator for Pagination

```javascript
async function* paginatedFetch(url, options = {}) {
  const { pageSize = 50, maxPages = Infinity } = options;
  let page = 1;
  
  while (page <= maxPages) {
    const response = await fetch(`${url}?page=${page}&limit=${pageSize}`);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    const data = await response.json();
    
    if (data.items.length === 0) {
      break;
    }
    
    yield data.items;
    
    if (data.items.length < pageSize) {
      break;
    }
    
    page++;
  }
}

// Usage
for await (const items of paginatedFetch('/api/products')) {
  console.log(`Processing ${items.length} items`);
  items.forEach(item => processItem(item));
}
```

#### Lazy Loading Chain

```javascript
class LazyLoadChain {
  constructor(url, pageSize = 20) {
    this.url = url;
    this.pageSize = pageSize;
    this.currentPage = 0;
    this.cache = [];
    this.hasMore = true;
  }
  
  async loadNext() {
    if (!this.hasMore) {
      return null;
    }
    
    this.currentPage++;
    
    const response = await fetch(
      `${this.url}?page=${this.currentPage}&limit=${this.pageSize}`
    );
    
    const data = await response.json();
    
    this.cache.push(...data.items);
    this.hasMore = data.items.length === this.pageSize;
    
    return data.items;
  }
  
  async loadAll() {
    while (this.hasMore) {
      await this.loadNext();
    }
    return this.cache;
  }
  
  getLoaded() {
    return this.cache;
  }
}

// Usage
const loader = new LazyLoadChain('/api/items', 50);
await loader.loadNext(); // Load first page
console.log(loader.getLoaded()); // Get loaded items
```

### Batch Request Processing

#### Batched Fetch with Window

```javascript
async function batchFetchWithWindow(ids, batchSize = 10) {
  const results = [];
  
  for (let i = 0; i < ids.length; i += batchSize) {
    const batch = ids.slice(i, i + batchSize);
    
    const batchResults = await Promise.all(
      batch.map(id => 
        fetch(`/api/item/${id}`).then(r => r.json())
      )
    );
    
    results.push(...batchResults);
  }
  
  return results;
}
```

#### Batch API Request

```javascript
async function fetchBatchAPI(ids) {
  const response = await fetch('/api/batch', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      requests: ids.map(id => ({
        method: 'GET',
        url: `/api/item/${id}`
      }))
    })
  });
  
  const batchResponse = await response.json();
  return batchResponse.responses;
}
```

#### Controlled Concurrency Batch

```javascript
async function batchWithConcurrency(items, fetchFn, concurrency = 5) {
  const results = [];
  const executing = [];
  
  for (const item of items) {
    const promise = fetchFn(item).then(result => {
      executing.splice(executing.indexOf(promise), 1);
      return result;
    });
    
    results.push(promise);
    executing.push(promise);
    
    if (executing.length >= concurrency) {
      await Promise.race(executing);
    }
  }
  
  return Promise.all(results);
}

// Usage
const userIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

const users = await batchWithConcurrency(
  userIds,
  async (id) => {
    const response = await fetch(`/api/user/${id}`);
    return response.json();
  },
  3 // Maximum 3 concurrent requests
);
```

### Waterfall Pattern

#### Sequential Data Enrichment

```javascript
async function enrichDataWaterfall(initialData) {
  let data = initialData;
  
  // Step 1: Fetch user details
  const userResponse = await fetch(`/api/user/${data.userId}`);
  data.user = await userResponse.json();
  
  // Step 2: Fetch user's organization
  const orgResponse = await fetch(`/api/organization/${data.user.orgId}`);
  data.organization = await orgResponse.json();
  
  // Step 3: Fetch organization's settings
  const settingsResponse = await fetch(`/api/settings/${data.organization.id}`);
  data.settings = await settingsResponse.json();
  
  // Step 4: Apply permissions based on settings
  const permissionsResponse = await fetch('/api/permissions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      userId: data.user.id,
      orgId: data.organization.id,
      settingsId: data.settings.id
    })
  });
  data.permissions = await permissionsResponse.json();
  
  return data;
}
```

#### Reduce-Style Chain

```javascript
async function chainedReduce(initialValue, operations) {
  return operations.reduce(async (accPromise, operation) => {
    const acc = await accPromise;
    
    const response = await fetch(operation.url, {
      method: operation.method || 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(acc)
    });
    
    return response.json();
  }, Promise.resolve(initialValue));
}

// Usage
const result = await chainedReduce(
  { userId: 123 },
  [
    { url: '/api/validate', method: 'POST' },
    { url: '/api/enrich', method: 'POST' },
    { url: '/api/transform', method: 'POST' },
    { url: '/api/save', method: 'POST' }
  ]
);
```

### Request Queue System

#### FIFO Queue with Chain

```javascript
class RequestQueue {
  constructor(concurrency = 1) {
    this.concurrency = concurrency;
    this.queue = [];
    this.active = 0;
  }
  
  async add(fn) {
    return new Promise((resolve, reject) => {
      this.queue.push({ fn, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.active >= this.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.active++;
    const { fn, resolve, reject } = this.queue.shift();
    
    try {
      const result = await fn();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.active--;
      this.process();
    }
  }
  
  async chain(requests) {
    const results = [];
    
    for (const request of requests) {
      const result = await this.add(request);
      results.push(result);
    }
    
    return results;
  }
}

// Usage
const queue = new RequestQueue(3);

const results = await queue.chain([
  () => fetch('/api/user/1').then(r => r.json()),
  () => fetch('/api/user/2').then(r => r.json()),
  () => fetch('/api/user/3').then(r => r.json()),
  () => fetch('/api/user/4').then(r => r.json()),
  () => fetch('/api/user/5').then(r => r.json())
]);
```

#### Priority Queue

```javascript
class PriorityRequestQueue {
  constructor(concurrency = 2) {
    this.concurrency = concurrency;
    this.queue = [];
    this.active = 0;
  }
  
  async add(fn, priority = 0) {
    return new Promise((resolve, reject) => {
      const item = { fn, priority, resolve, reject };
      
      // Insert based on priority (higher priority first)
      const insertIndex = this.queue.findIndex(q => q.priority < priority);
      
      if (insertIndex === -1) {
        this.queue.push(item);
      } else {
        this.queue.splice(insertIndex, 0, item);
      }
      
      this.process();
    });
  }
  
  async process() {
    if (this.active >= this.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.active++;
    const { fn, resolve, reject } = this.queue.shift();
    
    try {
      const result = await fn();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.active--;
      this.process();
    }
  }
}

// Usage
const queue = new PriorityRequestQueue(2);

// High priority user data
queue.add(() => fetch('/api/user/current').then(r => r.json()), 10);

// Normal priority
queue.add(() => fetch('/api/posts').then(r => r.json()), 5);

// Low priority analytics
queue.add(() => fetch('/api/analytics').then(r => r.json()), 1);
```

### Dependent Chain with State

#### Stateful Request Chain

```javascript
class StatefulChain {
  constructor() {
    this.state = {};
    this.history = [];
  }
  
  async fetch(url, options = {}) {
    const startTime = Date.now();
    
    const response = await fetch(url, options);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const data = await response.json();
    
    this.history.push({
      url,
      options,
      status: response.status,
      duration: Date.now() - startTime,
      timestamp: new Date().toISOString()
    });
    
    this.state = { ...this.state, ...data };
    
    return data;
  }
  
  async fetchIf(condition, url, options) {
    if (condition(this.state)) {
      return this.fetch(url, options);
    }
    return null;
  }
  
  async fetchWith(urlBuilder, options) {
    const url = urlBuilder(this.state);
    return this.fetch(url, options);
  }
  
  getState() {
    return this.state;
  }
  
  getHistory() {
    return this.history;
  }
  
  reset() {
    this.state = {};
    this.history = [];
  }
}

// Usage
const chain = new StatefulChain();

await chain.fetch('/api/user/123');

await chain.fetchIf(
  state => state.isPremium,
  '/api/premium/features'
);

await chain.fetchWith(
  state => `/api/posts?userId=${state.id}&premium=${state.isPremium}`
);

console.log(chain.getState());
console.log(chain.getHistory());
```

### Transaction-Style Chains

#### Rollback on Failure

```javascript
class TransactionalChain {
  constructor() {
    this.operations = [];
    this.completed = [];
  }
  
  add(operation) {
    this.operations.push(operation);
    return this;
  }
  
  async execute() {
    try {
      for (const op of this.operations) {
        const result = await op.execute();
        this.completed.push({ operation: op, result });
      }
      
      return this.completed.map(c => c.result);
      
    } catch (error) {
      console.error('Transaction failed, rolling back...', error);
      await this.rollback();
      throw error;
    }
  }
  
  async rollback() {
    for (const { operation, result } of this.completed.reverse()) {
      if (operation.rollback) {
        try {
          await operation.rollback(result);
        } catch (rollbackError) {
          console.error('Rollback failed:', rollbackError);
        }
      }
    }
    
    this.completed = [];
  }
}

// Usage
const transaction = new TransactionalChain();

transaction.add({
  execute: async () => {
    const response = await fetch('/api/user', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'John' })
    });
    return response.json();
  },
  rollback: async (result) => {
    await fetch(`/api/user/${result.id}`, { method: 'DELETE' });
  }
});

transaction.add({
  execute: async () => {
    const response = await fetch('/api/profile', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ userId: 'result from previous' })
    });
    return response.json();
  },
  rollback: async (result) => {
    await fetch(`/api/profile/${result.id}`, { method: 'DELETE' });
  }
});

try {
  const results = await transaction.execute();
} catch (error) {
  console.error('Transaction aborted');
}
```

### GraphQL-Style Chaining

#### Nested Resource Fetching

```javascript
async function fetchGraphLike(query) {
  const results = {};
  
  // Root query
  if (query.user) {
    const userResponse = await fetch(`/api/user/${query.user.id}`);
    results.user = await userResponse.json();
    
    // Nested queries
    if (query.user.posts) {
      const postsResponse = await fetch(`/api/posts?userId=${results.user.id}`);
      results.user.posts = await postsResponse.json();
      
      // Deep nested queries
      if (query.user.posts.comments) {
        results.user.posts = await Promise.all(
          results.user.posts.map(async post => {
            const commentsResponse = await fetch(`/api/comments?postId=${post.id}`);
            post.comments = await commentsResponse.json();
            return post;
          })
        );
      }
    }
    
    if (query.user.followers) {
      const followersResponse = await fetch(`/api/followers/${results.user.id}`);
      results.user.followers = await followersResponse.json();
    }
  }
  
  return results;
}

// Usage
const data = await fetchGraphLike({
  user: {
    id: 123,
    posts: {
      comments: true
    },
    followers: true
  }
});
```

#### Field Selection Chain

```javascript
class FieldSelector {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
    this.fields = [];
    this.includes = [];
  }
  
  select(...fields) {
    this.fields.push(...fields);
    return this;
  }
  
  include(resource, fields = []) {
    this.includes.push({ resource, fields });
    return this;
  }
  
  async fetch() {
    const params = new URLSearchParams();
    
    if (this.fields.length > 0) {
      params.set('fields', this.fields.join(','));
    }
    
    if (this.includes.length > 0) {
      params.set('include', this.includes.map(i => i.resource).join(','));
    }
    
    const response = await fetch(`${this.baseUrl}?${params}`);
    let data = await response.json();
    
    // Fetch included resources
    for (const include of this.includes) {
      const includeResponse = await fetch(
        `/api/${include.resource}?parentId=${data.id}`
      );
      data[include.resource] = await includeResponse.json();
    }
    
    return data;
  }
}

// Usage
const user = await new FieldSelector('/api/user/123')
  .select('id', 'name', 'email')
  .include('posts', ['title', 'content'])
  .include('followers')
  .fetch();
```

### Debounced Chain Requests

#### Request Debouncing

```javascript
class DebouncedChain {
  constructor(delay = 300) {
    this.delay = delay;
    this.timeouts = new Map();
  }
  
  async fetch(key, url, options = {}) {
    return new Promise((resolve, reject) => {
      // Clear existing timeout for this key
      if (this.timeouts.has(key)) {
        clearTimeout(this.timeouts.get(key));
      }
      
      const timeoutId = setTimeout(async () => {
        try {
          const response = await fetch(url, options);
          const data = await response.json();
          this.timeouts.delete(key);
          resolve(data);
        } catch (error) {
          this.timeouts.delete(key);
          reject(error);
        }
      }, this.delay);
      
      this.timeouts.set(key, timeoutId);
    });
  }
  
  cancel(key) {
    if (this.timeouts.has(key)) {
      clearTimeout(this.timeouts.get(key));
      this.timeouts.delete(key);
    }
  }
  
  cancelAll() {
    this.timeouts.forEach(timeoutId => clearTimeout(timeoutId));
    this.timeouts.clear();
  }
}

// Usage
const debounced = new DebouncedChain(500);

// Only the last call will execute
debounced.fetch('search', '/api/search?q=hello');
debounced.fetch('search', '/api/search?q=hello world');
debounced.fetch('search', '/api/search?q=hello world!');
```

### Memoized Chain

#### Request Result Caching

```javascript
class MemoizedChain {
  constructor(ttl = 60000) {
    this.cache = new Map();
    this.ttl = ttl;
  }
  
  getCacheKey(url, options = {}) {
    const method = options.method || 'GET';
    const body = options.body || '';
    return `${method}:${url}:${body}`;
  }
  
  async fetch(url, options = {}) {
    const key = this.getCacheKey(url, options);
    const cached = this.cache.get(key);
    
    if (cached && Date.now() - cached.timestamp < this.ttl) {
      return cached.data;
    }
    
    const response = await fetch(url, options);
    const data = await response.json();
    
    this.cache.set(key, {
      data,
      timestamp: Date.now()
    });
    
    return data;
  }
  
  async chain(...requests) {
    const results = [];
    
    for (const [url, options] of requests) {
      const result = await this.fetch(url, options);
      results.push(result);
    }
    
    return results;
  }
  
  clear() {
    this.cache.clear();
  }
  
  invalidate(url, options = {}) {
    const key = this.getCacheKey(url, options);
    this.cache.delete(key);
  }
}

// Usage
const memoized = new MemoizedChain(30000);

// First call hits API
const result1 = await memoized.fetch('/api/user/123');

// Second call returns cached result
const result2 = await memoized.fetch('/api/user/123');
```

### Observable Chain Pattern

#### Event-Driven Request Chain

```javascript
class ObservableChain {
  constructor() {
    this.observers = {
      start: [],
      progress: [],
      complete: [],
      error: []
    };
  }
  
  on(event, callback) {
    if (this.observers[event]) {
      this.observers[event].push(callback);
    }
    return this;
  }
  
  emit(event, data) {
    if (this.observers[event]) {
      this.observers[event].forEach(callback => callback(data));
    }
  }
  
  async execute(requests) {
    this.emit('start', { total: requests.length });
    
    const results = [];
    
    for (let i = 0; i < requests.length; i++) {
      try {
        const [url, options] = requests[i];
        const response = await fetch(url, options);
        const data = await response.json();
        
        results.push(data);
        
        this.emit('progress', {
          index: i,
          total: requests.length,
          completed: i + 1,
          result: data
        });
      } catch (error) {
        this.emit('error', { index: i, error });
        throw error;
      }
    }
    
    this.emit('complete', { results });
    return results;
  }
}

// Usage
const chain = new ObservableChain();

chain
  .on('start', ({ total }) => {
    console.log(`Starting ${total} requests`);
  })
  .on('progress', ({ completed, total }) => {
    console.log(`Progress: ${completed}/${total}`);
  })
  .on('complete', ({ results }) => {
    console.log('All requests completed', results);
  })
  .on('error', ({ index, error }) => {
    console.error(`Request ${index} failed:`, error);
  });

await chain.execute([
  ['/api/user/1', {}],
  ['/api/user/2', {}],
  ['/api/user/3', {}]
]);
```

---

