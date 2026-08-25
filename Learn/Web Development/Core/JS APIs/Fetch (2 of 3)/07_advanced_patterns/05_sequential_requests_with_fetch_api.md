## Sequential Requests with Fetch API


### Basic Sequential Execution

Sequential requests execute one after another, where each request waits for the previous one to complete before starting.

```javascript
async function executeSequentially(urls) {
  const results = [];
  
  for (const url of urls) {
    const response = await fetch(url);
    const data = await response.json();
    results.push(data);
  }
  
  return results;
}

// Usage
const urls = [
  '/api/step1',
  '/api/step2',
  '/api/step3'
];

const results = await executeSequentially(urls);
```

### Sequential with Error Handling

```javascript
async function sequentialWithErrorHandling(urls) {
  const results = [];
  const errors = [];
  
  for (let i = 0; i < urls.length; i++) {
    try {
      const response = await fetch(urls[i]);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      const data = await response.json();
      results.push({ index: i, url: urls[i], data, success: true });
    } catch (error) {
      errors.push({ index: i, url: urls[i], error: error.message });
      results.push({ index: i, url: urls[i], success: false, error: error.message });
    }
  }
  
  return { results, errors };
}
```

### Sequential with Stop-on-Error

```javascript
async function sequentialStopOnError(urls) {
  const results = [];
  
  for (const url of urls) {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`Request to ${url} failed with status ${response.status}`);
    }
    
    const data = await response.json();
    results.push(data);
  }
  
  return results;
}

// Usage
try {
  const results = await sequentialStopOnError(urls);
  console.log('All requests succeeded:', results);
} catch (error) {
  console.error('Stopped due to error:', error.message);
}
```

### Dependent Sequential Requests

Each request depends on data from the previous request.

```javascript
async function dependentSequentialRequests(userId) {
  // Step 1: Get user
  const userResponse = await fetch(`/api/users/${userId}`);
  const user = await userResponse.json();
  
  // Step 2: Get user's posts (depends on user data)
  const postsResponse = await fetch(`/api/posts?userId=${user.id}`);
  const posts = await postsResponse.json();
  
  // Step 3: Get comments for first post (depends on posts data)
  if (posts.length > 0) {
    const commentsResponse = await fetch(`/api/comments?postId=${posts[0].id}`);
    const comments = await commentsResponse.json();
    
    return { user, posts, comments };
  }
  
  return { user, posts, comments: [] };
}

// Usage
const data = await dependentSequentialRequests(123);
```

### Sequential with Dynamic URL Generation

```javascript
async function sequentialWithDynamicURLs(initialUrl, maxDepth = 5) {
  const results = [];
  let currentUrl = initialUrl;
  let depth = 0;
  
  while (currentUrl && depth < maxDepth) {
    const response = await fetch(currentUrl);
    const data = await response.json();
    
    results.push(data);
    
    // Get next URL from response (pagination, etc.)
    currentUrl = data.nextUrl || data.links?.next || null;
    depth++;
  }
  
  return results;
}

// Usage - handle pagination
const allPages = await sequentialWithDynamicURLs('/api/items?page=1');
```

### Sequential Pipeline with Transformations

```javascript
class RequestPipeline {
  constructor() {
    this.steps = [];
  }
  
  addStep(url, options, transform) {
    this.steps.push({ url, options, transform });
    return this;
  }
  
  async execute(initialData = {}) {
    let context = { ...initialData };
    const results = [];
    
    for (const step of this.steps) {
      // Resolve URL with context data
      const url = typeof step.url === 'function' 
        ? step.url(context) 
        : step.url;
      
      // Resolve options with context data
      const options = typeof step.options === 'function'
        ? step.options(context)
        : step.options || {};
      
      // Execute request
      const response = await fetch(url, options);
      const data = await response.json();
      
      // Transform data
      const transformed = step.transform 
        ? await step.transform(data, context) 
        : data;
      
      results.push(transformed);
      
      // Update context for next step
      context = { ...context, ...transformed };
    }
    
    return { results, context };
  }
}

// Usage
const pipeline = new RequestPipeline();

pipeline
  .addStep(
    '/api/authenticate',
    { method: 'POST', body: JSON.stringify({ username: 'user', password: 'pass' }) },
    (data) => ({ token: data.token })
  )
  .addStep(
    (context) => `/api/user/profile`,
    (context) => ({
      headers: { 'Authorization': `Bearer ${context.token}` }
    }),
    (data, context) => ({ profile: data, token: context.token })
  )
  .addStep(
    (context) => `/api/user/${context.profile.id}/settings`,
    (context) => ({
      headers: { 'Authorization': `Bearer ${context.token}` }
    }),
    (data) => ({ settings: data })
  );

const { results, context } = await pipeline.execute();
```

### Sequential with Rate Limiting

```javascript
async function sequentialWithRateLimit(urls, delayMs = 1000) {
  const results = [];
  
  for (let i = 0; i < urls.length; i++) {
    const response = await fetch(urls[i]);
    const data = await response.json();
    results.push(data);
    
    // Wait before next request (except after last one)
    if (i < urls.length - 1) {
      await new Promise(resolve => setTimeout(resolve, delayMs));
    }
  }
  
  return results;
}

// Usage
const results = await sequentialWithRateLimit(urls, 2000); // 2 second delay between requests
```

### Sequential with Progress Tracking

```javascript
async function sequentialWithProgress(urls, onProgress) {
  const results = [];
  const total = urls.length;
  
  for (let i = 0; i < urls.length; i++) {
    const url = urls[i];
    
    // Notify progress before request
    if (onProgress) {
      onProgress({
        current: i + 1,
        total,
        percentage: ((i + 1) / total) * 100,
        currentUrl: url,
        stage: 'requesting'
      });
    }
    
    try {
      const response = await fetch(url);
      const data = await response.json();
      
      results.push({
        url,
        success: true,
        data
      });
      
      // Notify progress after successful request
      if (onProgress) {
        onProgress({
          current: i + 1,
          total,
          percentage: ((i + 1) / total) * 100,
          currentUrl: url,
          stage: 'completed'
        });
      }
    } catch (error) {
      results.push({
        url,
        success: false,
        error: error.message
      });
      
      // Notify progress after failed request
      if (onProgress) {
        onProgress({
          current: i + 1,
          total,
          percentage: ((i + 1) / total) * 100,
          currentUrl: url,
          stage: 'failed',
          error: error.message
        });
      }
    }
  }
  
  return results;
}

// Usage
const results = await sequentialWithProgress(urls, (progress) => {
  console.log(`${progress.percentage.toFixed(2)}% - ${progress.stage} - ${progress.currentUrl}`);
  // Update UI progress bar
  document.getElementById('progress').style.width = `${progress.percentage}%`;
});
```

### Sequential with Retry Logic

```javascript
async function sequentialWithRetry(urls, maxRetries = 3, retryDelay = 1000) {
  const results = [];
  
  for (const url of urls) {
    let lastError;
    let attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        const response = await fetch(url);
        
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        
        const data = await response.json();
        results.push({ url, success: true, data, attempts: attempt + 1 });
        break; // Success, exit retry loop
      } catch (error) {
        lastError = error;
        attempt++;
        
        if (attempt < maxRetries) {
          // Exponential backoff
          const delay = retryDelay * Math.pow(2, attempt - 1);
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }
    
    // All retries failed
    if (attempt === maxRetries) {
      results.push({
        url,
        success: false,
        error: lastError.message,
        attempts: maxRetries
      });
    }
  }
  
  return results;
}

// Usage
const results = await sequentialWithRetry(urls, 3, 1000);
```

### Sequential Batch Processing

```javascript
async function sequentialBatchProcessor(items, batchSize, processor) {
  const results = [];
  
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    
    console.log(`Processing batch ${Math.floor(i / batchSize) + 1} of ${Math.ceil(items.length / batchSize)}`);
    
    // Process batch sequentially
    for (const item of batch) {
      const result = await processor(item);
      results.push(result);
    }
    
    // Optional: delay between batches
    if (i + batchSize < items.length) {
      await new Promise(resolve => setTimeout(resolve, 500));
    }
  }
  
  return results;
}

// Usage
const items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

const results = await sequentialBatchProcessor(items, 3, async (item) => {
  const response = await fetch(`/api/process/${item}`);
  return response.json();
});
```

### Sequential with Conditional Execution

```javascript
async function sequentialConditional(requests) {
  const results = [];
  
  for (const request of requests) {
    const { url, options, condition, skipOnError } = request;
    
    // Check condition before executing
    if (condition && !condition(results)) {
      console.log(`Skipping ${url} due to condition`);
      continue;
    }
    
    try {
      const response = await fetch(url, options);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      const data = await response.json();
      results.push({ url, success: true, data });
    } catch (error) {
      if (skipOnError) {
        console.log(`Skipping error for ${url}`);
        results.push({ url, success: false, error: error.message });
        continue;
      }
      
      throw error; // Stop execution
    }
  }
  
  return results;
}

// Usage
const requests = [
  {
    url: '/api/step1',
    options: { method: 'GET' }
  },
  {
    url: '/api/step2',
    options: { method: 'POST' },
    condition: (results) => results[0]?.success && results[0]?.data?.canProceed,
    skipOnError: true
  },
  {
    url: '/api/step3',
    options: { method: 'GET' },
    condition: (results) => results.length >= 2
  }
];

const results = await sequentialConditional(requests);
```

### Sequential State Machine

```javascript
class SequentialStateMachine {
  constructor() {
    this.states = new Map();
    this.currentState = null;
    this.context = {};
  }
  
  addState(name, handler, transitions = {}) {
    this.states.set(name, { handler, transitions });
    
    if (!this.currentState) {
      this.currentState = name;
    }
    
    return this;
  }
  
  async execute() {
    const results = [];
    const visited = new Set();
    
    while (this.currentState) {
      // Prevent infinite loops
      if (visited.has(this.currentState)) {
        throw new Error(`Infinite loop detected at state: ${this.currentState}`);
      }
      visited.add(this.currentState);
      
      const state = this.states.get(this.currentState);
      if (!state) {
        throw new Error(`Unknown state: ${this.currentState}`);
      }
      
      console.log(`Executing state: ${this.currentState}`);
      
      try {
        // Execute state handler
        const result = await state.handler(this.context);
        results.push({ state: this.currentState, result });
        
        // Update context
        this.context = { ...this.context, ...result };
        
        // Determine next state
        let nextState = null;
        
        for (const [condition, targetState] of Object.entries(state.transitions)) {
          if (condition === 'default') {
            nextState = targetState;
          } else if (typeof condition === 'function' && condition(this.context)) {
            nextState = targetState;
            break;
          } else if (this.context[condition]) {
            nextState = targetState;
            break;
          }
        }
        
        this.currentState = nextState;
      } catch (error) {
        results.push({ state: this.currentState, error: error.message });
        
        // Check for error transition
        if (state.transitions.onError) {
          this.currentState = state.transitions.onError;
        } else {
          throw error;
        }
      }
    }
    
    return { results, context: this.context };
  }
}

// Usage
const machine = new SequentialStateMachine();

machine
  .addState('authenticate', async (context) => {
    const response = await fetch('/api/auth', {
      method: 'POST',
      body: JSON.stringify({ user: 'admin', pass: 'secret' })
    });
    const data = await response.json();
    return { token: data.token, authenticated: true };
  }, {
    authenticated: 'fetchProfile',
    onError: 'failed'
  })
  .addState('fetchProfile', async (context) => {
    const response = await fetch('/api/profile', {
      headers: { 'Authorization': `Bearer ${context.token}` }
    });
    const profile = await response.json();
    return { profile, hasPermission: profile.role === 'admin' };
  }, {
    hasPermission: 'fetchAdminData',
    default: 'fetchUserData'
  })
  .addState('fetchAdminData', async (context) => {
    const response = await fetch('/api/admin/data', {
      headers: { 'Authorization': `Bearer ${context.token}` }
    });
    return { adminData: await response.json() };
  }, {
    default: 'complete'
  })
  .addState('fetchUserData', async (context) => {
    const response = await fetch('/api/user/data', {
      headers: { 'Authorization': `Bearer ${context.token}` }
    });
    return { userData: await response.json() };
  }, {
    default: 'complete'
  })
  .addState('failed', async (context) => {
    console.error('Authentication failed');
    return { failed: true };
  }, {})
  .addState('complete', async (context) => {
    console.log('Process complete');
    return { completed: true };
  }, {});

const { results, context } = await machine.execute();
```

### Sequential with Timeout per Request

```javascript
async function sequentialWithTimeouts(requests, defaultTimeout = 5000) {
  const results = [];
  
  for (const request of requests) {
    const { url, options, timeout = defaultTimeout } = request;
    
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);
      
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      const data = await response.json();
      results.push({ url, success: true, data });
    } catch (error) {
      const isTimeout = error.name === 'AbortError';
      results.push({
        url,
        success: false,
        error: isTimeout ? 'Request timeout' : error.message,
        timeout: isTimeout
      });
    }
  }
  
  return results;
}

// Usage
const requests = [
  { url: '/api/fast', options: {}, timeout: 2000 },
  { url: '/api/slow', options: {}, timeout: 10000 },
  { url: '/api/medium', options: {} } // uses default timeout
];

const results = await sequentialWithTimeouts(requests, 5000);
```

### Sequential Reduce Pattern

```javascript
async function sequentialReduce(urls, reducer, initialValue) {
  let accumulator = initialValue;
  
  for (let i = 0; i < urls.length; i++) {
    const url = urls[i];
    const response = await fetch(url);
    const data = await response.json();
    
    accumulator = await reducer(accumulator, data, i, urls);
  }
  
  return accumulator;
}

// Usage - aggregate data across requests
const total = await sequentialReduce(
  ['/api/sales/jan', '/api/sales/feb', '/api/sales/mar'],
  async (acc, data) => {
    return acc + data.total;
  },
  0
);

// Usage - build nested structure
const nested = await sequentialReduce(
  ['/api/user/1', '/api/user/2', '/api/user/3'],
  async (acc, user) => {
    const postsResponse = await fetch(`/api/posts?userId=${user.id}`);
    const posts = await postsResponse.json();
    
    return {
      ...acc,
      [user.id]: { ...user, posts }
    };
  },
  {}
);
```

### Sequential with Checkpoints

```javascript
class SequentialWithCheckpoints {
  constructor() {
    this.checkpoints = new Map();
  }
  
  async execute(requests, options = {}) {
    const { saveCheckpoint = true, resumeFromCheckpoint = true } = options;
    const results = [];
    let startIndex = 0;
    
    // Try to resume from last checkpoint
    if (resumeFromCheckpoint) {
      const lastCheckpoint = this.getLastCheckpoint();
      if (lastCheckpoint) {
        startIndex = lastCheckpoint.index + 1;
        results.push(...lastCheckpoint.results);
        console.log(`Resuming from checkpoint at index ${startIndex}`);
      }
    }
    
    for (let i = startIndex; i < requests.length; i++) {
      const { url, options } = requests[i];
      
      try {
        const response = await fetch(url, options);
        const data = await response.json();
        
        results.push({ url, success: true, data });
        
        // Save checkpoint
        if (saveCheckpoint) {
          this.saveCheckpoint(i, results);
        }
      } catch (error) {
        results.push({ url, success: false, error: error.message });
        
        // Save checkpoint even on error
        if (saveCheckpoint) {
          this.saveCheckpoint(i, results);
        }
        
        throw error;
      }
    }
    
    // Clear checkpoints on successful completion
    if (saveCheckpoint) {
      this.clearCheckpoints();
    }
    
    return results;
  }
  
  saveCheckpoint(index, results) {
    const checkpoint = {
      index,
      results: [...results],
      timestamp: Date.now()
    };
    
    this.checkpoints.set(index, checkpoint);
    
    // Persist to localStorage for recovery across page reloads
    try {
      localStorage.setItem(
        'sequential_checkpoint',
        JSON.stringify(checkpoint)
      );
    } catch (e) {
      console.warn('Failed to persist checkpoint:', e);
    }
  }
  
  getLastCheckpoint() {
    try {
      const stored = localStorage.getItem('sequential_checkpoint');
      return stored ? JSON.parse(stored) : null;
    } catch (e) {
      return null;
    }
  }
  
  clearCheckpoints() {
    this.checkpoints.clear();
    localStorage.removeItem('sequential_checkpoint');
  }
}

// Usage
const sequential = new SequentialWithCheckpoints();

try {
  const results = await sequential.execute(requests, {
    saveCheckpoint: true,
    resumeFromCheckpoint: true
  });
} catch (error) {
  console.error('Process failed, checkpoint saved. Can resume later.');
}
```

---

