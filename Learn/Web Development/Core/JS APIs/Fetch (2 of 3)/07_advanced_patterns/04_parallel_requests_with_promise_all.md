## Parallel Requests with Promise.all()


### Core Mechanism

`Promise.all()` accepts an iterable of promises and returns a single promise that resolves when all input promises resolve, or rejects when any input promise rejects. For fetch operations, this enables concurrent network requests rather than sequential execution.

```javascript
const [users, posts, comments] = await Promise.all([
  fetch('/api/users').then(r => r.json()),
  fetch('/api/posts').then(r => r.json()),
  fetch('/api/comments').then(r => r.json())
]);
```

All three requests initiate simultaneously. Total execution time approximates the slowest request rather than the sum of all requests.

### Execution Timeline Comparison

#### Sequential Execution

```javascript
const users = await fetch('/api/users').then(r => r.json());    // 200ms
const posts = await fetch('/api/posts').then(r => r.json());    // 150ms
const comments = await fetch('/api/comments').then(r => r.json()); // 180ms
// Total: ~530ms
```

Each request waits for the previous to complete before initiating.

#### Parallel Execution

```javascript
const [users, posts, comments] = await Promise.all([
  fetch('/api/users').then(r => r.json()),    // 200ms
  fetch('/api/posts').then(r => r.json()),    // 150ms
  fetch('/api/comments').then(r => r.json())  // 180ms
]);
// Total: ~200ms (longest request)
```

All requests execute concurrently. Total time equals the slowest request plus minimal overhead.

### All-or-Nothing Resolution Behavior

`Promise.all()` rejects immediately when any input promise rejects, short-circuiting remaining operations:

```javascript
try {
  const [data1, data2, data3] = await Promise.all([
    fetch('/api/endpoint1').then(r => r.json()), // Succeeds after 100ms
    fetch('/api/endpoint2').then(r => r.json()), // Fails after 50ms
    fetch('/api/endpoint3').then(r => r.json())  // Succeeds after 150ms
  ]);
} catch (error) {
  // Catches at 50ms when endpoint2 fails
  // data1 and data3 are not accessible even though endpoint1 may have succeeded
}
```

[Inference] The successful requests complete in the background, but their results are discarded. Network resources are consumed for all requests regardless of early rejection.

### Independent Request Patterns

#### Basic Parallel Requests

```javascript
async function fetchDashboardData() {
  const [userProfile, notifications, activityFeed, settings] = await Promise.all([
    fetch('/api/user/profile').then(r => r.json()),
    fetch('/api/notifications').then(r => r.json()),
    fetch('/api/activity').then(r => r.json()),
    fetch('/api/settings').then(r => r.json())
  ]);
  
  return { userProfile, notifications, activityFeed, settings };
}
```

Appropriate when all data is independent and equally required for the operation.

#### Dynamic Request Arrays

```javascript
async function fetchMultipleUsers(userIds) {
  const requests = userIds.map(id => 
    fetch(`/api/users/${id}`).then(r => r.json())
  );
  
  return await Promise.all(requests);
}

// Usage
const users = await fetchMultipleUsers([1, 2, 3, 4, 5]);
```

Scales to arbitrary numbers of requests based on input data.

#### Mixed Request Types

```javascript
const [userData, imageBlob, csvText] = await Promise.all([
  fetch('/api/user').then(r => r.json()),
  fetch('/images/avatar.png').then(r => r.blob()),
  fetch('/data/export.csv').then(r => r.text())
]);
```

Different response processing methods can coexist within the same `Promise.all()`.

### Dependent Request Handling

When requests depend on previous results, structure dependencies carefully:

```javascript
// Anti-pattern: Sequential due to dependency
const user = await fetch('/api/user/me').then(r => r.json());
const [posts, followers] = await Promise.all([
  fetch(`/api/users/${user.id}/posts`).then(r => r.json()),
  fetch(`/api/users/${user.id}/followers`).then(r => r.json())
]);
```

The initial user fetch must complete before the parallel requests can begin. Total time: user request + max(posts, followers).

#### Nested Parallelism

```javascript
async function fetchCompleteProfile(userId) {
  // First wave: Independent initial data
  const [user, settings] = await Promise.all([
    fetch(`/api/users/${userId}`).then(r => r.json()),
    fetch(`/api/settings/${userId}`).then(r => r.json())
  ]);
  
  // Second wave: Dependent on first wave results
  const [posts, followers, following] = await Promise.all([
    fetch(`/api/users/${user.id}/posts`).then(r => r.json()),
    fetch(`/api/users/${user.id}/followers`).then(r => r.json()),
    fetch(`/api/users/${user.id}/following`).then(r => r.json())
  ]);
  
  return { user, settings, posts, followers, following };
}
```

Maximizes parallelism within dependency constraints.

### Error Handling Strategies

#### Try-Catch Around Promise.all()

```javascript
try {
  const [users, posts] = await Promise.all([
    fetch('/api/users').then(r => r.json()),
    fetch('/api/posts').then(r => r.json())
  ]);
  // Use data
} catch (error) {
  // Any rejection ends up here
  // Cannot distinguish which request failed without additional logic
  console.error('One or more requests failed:', error);
}
```

Simple but loses context about which request failed and discards successful results.

#### Individual Promise Error Handling

```javascript
const [users, posts] = await Promise.all([
  fetch('/api/users')
    .then(r => r.json())
    .catch(err => {
      console.error('Users fetch failed:', err);
      return []; // Fallback value
    }),
  fetch('/api/posts')
    .then(r => r.json())
    .catch(err => {
      console.error('Posts fetch failed:', err);
      return []; // Fallback value
    })
]);

// users and posts always have values (possibly fallbacks)
```

Each promise handles its own errors. `Promise.all()` never rejects because individual promises always resolve (with fallback values).

#### Response Status Validation

```javascript
async function fetchWithValidation(url) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }
  return response.json();
}

try {
  const [users, posts] = await Promise.all([
    fetchWithValidation('/api/users'),
    fetchWithValidation('/api/posts')
  ]);
} catch (error) {
  // Catches both network errors and non-2xx responses
  console.error('Request failed:', error);
}
```

Ensures HTTP errors trigger rejection, as `fetch()` only rejects on network failures by default.

#### Structured Error Information

```javascript
const results = await Promise.all([
  fetch('/api/users')
    .then(r => r.json())
    .then(data => ({ success: true, data }))
    .catch(error => ({ success: false, error })),
  fetch('/api/posts')
    .then(r => r.json())
    .then(data => ({ success: true, data }))
    .catch(error => ({ success: false, error }))
]);

results.forEach((result, index) => {
  if (result.success) {
    console.log(`Request ${index} succeeded:`, result.data);
  } else {
    console.error(`Request ${index} failed:`, result.error);
  }
});
```

Preserves both successful and failed results with distinguishable status.

### Promise.allSettled() Alternative

`Promise.allSettled()` waits for all promises to settle (resolve or reject) and returns their outcomes:

```javascript
const results = await Promise.allSettled([
  fetch('/api/users').then(r => r.json()),
  fetch('/api/posts').then(r => r.json()),
  fetch('/api/comments').then(r => r.json())
]);

results.forEach((result, index) => {
  if (result.status === 'fulfilled') {
    console.log(`Request ${index}:`, result.value);
  } else {
    console.error(`Request ${index} failed:`, result.reason);
  }
});
```

Advantages over `Promise.all()`:

- Never rejects; always resolves with all outcomes
- Provides detailed status for each promise
- Suitable when partial success is acceptable

Use `Promise.all()` when all requests must succeed; use `Promise.allSettled()` when partial results are useful.

### Performance Considerations

#### Browser Connection Limits

Browsers limit concurrent connections per origin (typically 6-8 for HTTP/1.1, effectively unlimited for HTTP/2):

```javascript
// HTTP/1.1: Only 6 requests execute simultaneously
const requests = Array.from({ length: 20 }, (_, i) => 
  fetch(`/api/data/${i}`).then(r => r.json())
);
await Promise.all(requests);
```

[Inference] Requests 7-20 queue until earlier requests complete. HTTP/2 multiplexing eliminates this bottleneck by allowing many requests over a single connection.

#### Memory Consumption

All response data resides in memory simultaneously:

```javascript
// Each response is ~1MB; peak memory usage ~50MB
const images = await Promise.all(
  Array.from({ length: 50 }, (_, i) => 
    fetch(`/images/${i}.jpg`).then(r => r.blob())
  )
);
```

For large datasets, consider batching:

```javascript
async function fetchInBatches(urls, batchSize = 10) {
  const results = [];
  
  for (let i = 0; i < urls.length; i += batchSize) {
    const batch = urls.slice(i, i + batchSize);
    const batchResults = await Promise.all(
      batch.map(url => fetch(url).then(r => r.json()))
    );
    results.push(...batchResults);
  }
  
  return results;
}
```

Limits concurrent requests and memory usage while maintaining parallelism within batches.

#### Server Load Implications

Parallel requests from many clients create coordinated load spikes:

```javascript
// On page load, every user makes 10 simultaneous requests
useEffect(() => {
  Promise.all([
    fetch('/api/endpoint1'),
    fetch('/api/endpoint2'),
    // ... 8 more endpoints
  ]);
}, []);
```

[Inference] This pattern can overwhelm servers during traffic surges. Stagger non-critical requests or prioritize essential data.

### Request Cancellation

#### AbortController with Promise.all()

```javascript
const controller = new AbortController();
const signal = controller.signal;

try {
  const [users, posts] = await Promise.all([
    fetch('/api/users', { signal }).then(r => r.json()),
    fetch('/api/posts', { signal }).then(r => r.json())
  ]);
} catch (error) {
  if (error.name === 'AbortError') {
    console.log('Requests cancelled');
  }
}

// Cancel all requests
controller.abort();
```

Aborting cancels all in-flight requests that share the signal. [Inference] Network resources are freed, though the browser may complete partial response downloads before fully aborting.

#### Timeout Pattern

```javascript
function fetchWithTimeout(url, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  return fetch(url, { signal: controller.signal })
    .then(r => r.json())
    .finally(() => clearTimeout(timeoutId));
}

try {
  const results = await Promise.all([
    fetchWithTimeout('/api/users', 5000),
    fetchWithTimeout('/api/posts', 5000),
    fetchWithTimeout('/api/comments', 5000)
  ]);
} catch (error) {
  console.error('Request timed out or failed:', error);
}
```

Each request has an independent timeout. The first timeout or error causes `Promise.all()` to reject.

#### Selective Cancellation

```javascript
const controllers = [new AbortController(), new AbortController()];

const [users, posts] = await Promise.all([
  fetch('/api/users', { signal: controllers[0].signal }).then(r => r.json()),
  fetch('/api/posts', { signal: controllers[1].signal }).then(r => r.json())
]);

// Cancel only the posts request
controllers[1].abort();
```

Individual controllers enable selective cancellation without affecting other requests.

### Race Conditions and Data Consistency

#### Order Dependency Issues

```javascript
// Anti-pattern: Assumes response order matches request order
const [userUpdate, accountSync] = await Promise.all([
  fetch('/api/user/update', { method: 'POST', body: userData }),
  fetch('/api/account/sync', { method: 'POST' })
]);
```

[Inference] If `accountSync` completes before `userUpdate`, it may operate on stale user data. Ensure operations are truly independent or enforce ordering.

#### State Management in React

```javascript
function Dashboard() {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    let cancelled = false;
    
    Promise.all([
      fetch('/api/users').then(r => r.json()),
      fetch('/api/posts').then(r => r.json())
    ]).then(([users, posts]) => {
      if (!cancelled) {
        setData({ users, posts });
      }
    });
    
    return () => {
      cancelled = true;
    };
  }, []);
  
  return <div>{/* Render data */}</div>;
}
```

The `cancelled` flag prevents state updates if the component unmounts before requests complete, avoiding React warnings about setting state on unmounted components.

#### Concurrent Modifications

```javascript
// Potentially problematic: Concurrent writes to the same resource
await Promise.all([
  fetch('/api/user/123', { 
    method: 'PATCH', 
    body: JSON.stringify({ name: 'Alice' }) 
  }),
  fetch('/api/user/123', { 
    method: 'PATCH', 
    body: JSON.stringify({ email: 'alice@example.com' }) 
  })
]);
```

[Inference] Server-side behavior depends on implementation. Some servers process requests sequentially, others may have last-write-wins, or may merge updates. For safety, batch modifications into a single request when possible.

### Optimization Patterns

#### Conditional Request Execution

```javascript
async function fetchRequiredData(options) {
  const requests = [];
  
  if (options.includeUsers) {
    requests.push(
      fetch('/api/users').then(r => r.json()).then(data => ({ users: data }))
    );
  }
  
  if (options.includePosts) {
    requests.push(
      fetch('/api/posts').then(r => r.json()).then(data => ({ posts: data }))
    );
  }
  
  if (options.includeComments) {
    requests.push(
      fetch('/api/comments').then(r => r.json()).then(data => ({ comments: data }))
    );
  }
  
  const results = await Promise.all(requests);
  return Object.assign({}, ...results);
}

const data = await fetchRequiredData({ 
  includeUsers: true, 
  includePosts: true 
});
// Only fetches users and posts, skips comments
```

Dynamically constructs the request array based on requirements, avoiding unnecessary network calls.

#### Request Deduplication

```javascript
const requestCache = new Map();

function fetchWithCache(url) {
  if (requestCache.has(url)) {
    return requestCache.get(url);
  }
  
  const promise = fetch(url).then(r => r.json());
  requestCache.set(url, promise);
  
  return promise;
}

// Multiple calls to the same URL reuse the same promise
const [data1, data2, data3] = await Promise.all([
  fetchWithCache('/api/users'),
  fetchWithCache('/api/users'), // Reuses first request
  fetchWithCache('/api/posts')
]);
```

Prevents duplicate requests when the same URL appears multiple times. [Inference] Cache should be cleared or expire based on data freshness requirements.

#### Priority-Based Execution

```javascript
async function fetchWithPriority() {
  // High-priority requests first
  const critical = await Promise.all([
    fetch('/api/critical-data').then(r => r.json()),
    fetch('/api/user-session').then(r => r.json())
  ]);
  
  // Render critical data immediately
  renderCritical(critical);
  
  // Low-priority requests in background
  Promise.all([
    fetch('/api/analytics').then(r => r.json()),
    fetch('/api/recommendations').then(r => r.json())
  ]).then(renderSecondary);
}
```

Staggers requests by priority, allowing critical content to display before less important data loads.

### Advanced Patterns

#### Recursive Promise.all()

```javascript
async function fetchNestedData(ids, depth = 0, maxDepth = 3) {
  if (depth >= maxDepth || ids.length === 0) return [];
  
  const items = await Promise.all(
    ids.map(id => fetch(`/api/items/${id}`).then(r => r.json()))
  );
  
  // Each item contains child IDs
  const allChildIds = items.flatMap(item => item.childIds || []);
  
  const children = await fetchNestedData(allChildIds, depth + 1, maxDepth);
  
  return [...items, ...children];
}
```

Recursively fetches nested data structures with parallelism at each level.

#### Promise.all() with Generators

```javascript
async function* requestGenerator(urls) {
  for (const url of urls) {
    yield fetch(url).then(r => r.json());
  }
}

async function processInParallel(urls, parallelism = 5) {
  const gen = requestGenerator(urls);
  const results = [];
  
  while (true) {
    const batch = [];
    for (let i = 0; i < parallelism; i++) {
      const { value, done } = gen.next();
      if (done) break;
      batch.push(value);
    }
    
    if (batch.length === 0) break;
    
    const batchResults = await Promise.all(batch);
    results.push(...batchResults);
  }
  
  return results;
}
```

Controls parallelism while processing large request lists.

#### Combining with Promise.race()

```javascript
async function fetchWithFallback(primaryUrl, fallbackUrl) {
  const primary = fetch(primaryUrl).then(r => r.json());
  
  // If primary takes >1s, also try fallback
  const fallback = new Promise(resolve => {
    setTimeout(() => {
      fetch(fallbackUrl)
        .then(r => r.json())
        .then(resolve);
    }, 1000);
  });
  
  // Return whichever completes first
  return Promise.race([primary, fallback]);
}

const data = await Promise.all([
  fetchWithFallback('/api/data', '/api/data-backup'),
  fetch('/api/other').then(r => r.json())
]);
```

Combines racing and parallel patterns for resilience.

#### Throttled Parallel Execution

```javascript
async function throttledPromiseAll(tasks, limit = 5) {
  const results = [];
  const executing = [];
  
  for (const task of tasks) {
    const promise = Promise.resolve().then(task);
    results.push(promise);
    
    if (limit <= tasks.length) {
      const executing = promise.then(() => 
        executing.splice(executing.indexOf(executing), 1)
      );
      executing.push(executing);
      
      if (executing.length >= limit) {
        await Promise.race(executing);
      }
    }
  }
  
  return Promise.all(results);
}

// Usage: Limit to 5 concurrent requests
await throttledPromiseAll(
  urls.map(url => () => fetch(url).then(r => r.json())),
  5
);
```

[Inference] Implementation complexity suggests using established libraries (e.g., p-limit) for production use.

### Testing and Debugging

#### Mock Parallel Requests

```javascript
// Jest test example
test('fetches dashboard data in parallel', async () => {
  global.fetch = jest.fn()
    .mockResolvedValueOnce({ json: () => Promise.resolve({ users: [] }) })
    .mockResolvedValueOnce({ json: () => Promise.resolve({ posts: [] }) });
  
  const data = await fetchDashboardData();
  
  expect(fetch).toHaveBeenCalledTimes(2);
  expect(fetch).toHaveBeenCalledWith('/api/users');
  expect(fetch).toHaveBeenCalledWith('/api/posts');
});
```

Verify parallel execution by checking all fetch calls occur before any resolve.

#### Timing Analysis

```javascript
async function measureParallelRequests() {
  const start = performance.now();
  
  await Promise.all([
    fetch('/api/endpoint1').then(r => r.json()),
    fetch('/api/endpoint2').then(r => r.json()),
    fetch('/api/endpoint3').then(r => r.json())
  ]);
  
  const duration = performance.now() - start;
  console.log(`Parallel requests completed in ${duration}ms`);
}
```

Compare duration to sequential execution to verify parallelism benefits.

#### Network Waterfall Inspection

Browser DevTools Network tab shows request timing:

- Parallel requests appear starting at approximately the same time
- Sequential requests show staggered start times
- Connection establishment, waiting, and download phases visible

Look for:

- Requests queued due to connection limits (grey bar in Chrome)
- DNS/SSL overhead affecting first request
- Stalled requests indicating server-side bottlenecks

### Common Pitfalls

#### Mixing Await Inside Array

```javascript
// Anti-pattern: Sequential execution disguised as parallel
const results = await Promise.all([
  await fetch('/api/users').then(r => r.json()), // Wait here
  await fetch('/api/posts').then(r => r.json())  // Then wait here
]);
```

Using `await` inside the array defeats parallelism. Remove `await` from individual promises:

```javascript
// Correct: Parallel execution
const results = await Promise.all([
  fetch('/api/users').then(r => r.json()),
  fetch('/api/posts').then(r => r.json())
]);
```

#### Ignoring Empty Arrays

```javascript
const results = await Promise.all([]); // Returns []
```

Empty input resolves immediately with an empty array. Validate input length if expecting results.

#### Unhandled Rejections in Long Chains

```javascript
await Promise.all([
  fetch('/api/data')
    .then(r => r.json())
    .then(processData)
    .then(validateData) // If this throws, Promise.all() rejects
    .then(saveData)
]);
```

Errors in any step of the promise chain cause rejection. Add `.catch()` to handle errors at appropriate points in the chain.

#### Response Object Reuse

```javascript
// Anti-pattern: Response body can only be read once
const responses = await Promise.all([
  fetch('/api/data1'),
  fetch('/api/data2')
]);

const json1 = await responses[0].json();
const json2 = await responses[0].json(); // Throws: body already read
```

Response bodies are streams that can only be consumed once. Clone if needed multiple times:

```javascript
const response = await fetch('/api/data');
const clone = response.clone();

const json = await response.json();
const text = await clone.text();
```

### Framework Integration

#### React with useEffect

```javascript
function Dashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  useEffect(() => {
    const controller = new AbortController();
    
    Promise.all([
      fetch('/api/users', { signal: controller.signal }).then(r => r.json()),
      fetch('/api/posts', { signal: controller.signal }).then(r => r.json())
    ])
      .then(([users, posts]) => {
        setData({ users, posts });
        setLoading(false);
      })
      .catch(err => {
        if (err.name !== 'AbortError') {
          setError(err);
          setLoading(false);
        }
      });
    
    return () => controller.abort();
  }, []);
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  return <div>{/* Render data */}</div>;
}
```

#### Next.js Server Components

```javascript
// Server Component (async by default)
async function Page() {
  const [users, posts, comments] = await Promise.all([
    fetch('https://api.example.com/users').then(r => r.json()),
    fetch('https://api.example.com/posts').then(r => r.json()),
    fetch('https://api.example.com/comments').then(r => r.json())
  ]);
  
  return (
    <div>
      <UserList users={users} />
      <PostList posts={posts} />
      <CommentList comments={comments} />
    </div>
  );
}
```

Server components execute on the server; parallel fetches complete before rendering.

#### Vue Composition API

```javascript
import { ref, onMounted } from 'vue';

export default {
  setup() {
    const data = ref(null);
    const loading = ref(true);
    
    onMounted(async () => {
      const [users, posts] = await Promise.all([
        fetch('/api/users').then(r => r.json()),
        fetch('/api/posts').then(r => r.json())
      ]);
      
      data.value = { users, posts };
      loading.value = false;
    });
    
    return { data, loading };
  }
};
```

### Performance Monitoring

#### Resource Timing API

```javascript
async function trackParallelRequests() {
  const mark = `parallel-requests-${Date.now()}`;
  performance.mark(`${mark}-start`);
  
  await Promise.all([
    fetch('/api/users').then(r => r.json()),
    fetch('/api/posts').then(r => r.json())
  ]);
  
  performance.mark(`${mark}-end`);
  performance.measure(mark, `${mark}-start`, `${mark}-end`);
  
  const measure = performance.getEntriesByName(mark)[0];
  console.log(`Parallel requests took ${measure.duration}ms`);
}
```

#### Custom Metrics

```javascript
async function fetchWithMetrics(url) {
  const start = performance.now();
  
  try {
    const response = await fetch(url);
    const data = await response.json();
    
    const duration = performance.now() - start;
    
    analytics.track('fetch_success', {
      url,
      duration,
      status: response.status,
      size: JSON.stringify(data).length
    });
    
    return data;
  } catch (error) {
    const duration = performance.now() - start;
    
    analytics.track('fetch_failure', {
      url,
      duration,
      error: error.message
    });
    
    throw error;
  }
}

await Promise.all([
  fetchWithMetrics('/api/users'),
  fetchWithMetrics('/api/posts')
]);
```

Tracks individual request metrics while executing in parallel.

---

