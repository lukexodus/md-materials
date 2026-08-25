## Request Batching


### Batching Multiple Requests

Request batching consolidates multiple API calls into a single HTTP request, reducing network overhead and improving performance. Instead of executing sequential fetch calls, you group them together and send them as one payload.

```javascript
const batchRequest = async (requests) => {
  const response = await fetch('/api/batch', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ requests })
  });
  return response.json();
};

const requests = [
  { method: 'GET', url: '/users/1' },
  { method: 'GET', url: '/posts/5' },
  { method: 'POST', url: '/comments', body: { text: 'Hello' } }
];

const results = await batchRequest(requests);
```

### Queue-Based Batching

Implement a queue that collects requests over a time window before sending them together. This pattern is particularly effective for high-frequency operations.

```javascript
class BatchQueue {
  constructor(batchSize = 10, flushInterval = 100) {
    this.queue = [];
    this.batchSize = batchSize;
    this.flushInterval = flushInterval;
    this.timer = null;
    this.pendingPromises = [];
  }

  add(request) {
    return new Promise((resolve, reject) => {
      this.queue.push(request);
      this.pendingPromises.push({ resolve, reject });

      if (this.queue.length >= this.batchSize) {
        this.flush();
      } else if (!this.timer) {
        this.timer = setTimeout(() => this.flush(), this.flushInterval);
      }
    });
  }

  async flush() {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = null;
    }

    if (this.queue.length === 0) return;

    const batch = this.queue.splice(0);
    const promises = this.pendingPromises.splice(0);

    try {
      const response = await fetch('/api/batch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ requests: batch })
      });

      const results = await response.json();

      results.forEach((result, index) => {
        if (result.error) {
          promises[index].reject(new Error(result.error));
        } else {
          promises[index].resolve(result.data);
        }
      });
    } catch (error) {
      promises.forEach(p => p.reject(error));
    }
  }
}

const queue = new BatchQueue();
const userData = await queue.add({ method: 'GET', url: '/users/1' });
const postData = await queue.add({ method: 'GET', url: '/posts/5' });
```

### DataLoader Pattern

DataLoader provides request batching and caching for GraphQL and REST APIs, coalescing requests within a single frame of execution.

```javascript
class DataLoader {
  constructor(batchLoadFn, options = {}) {
    this.batchLoadFn = batchLoadFn;
    this.cache = options.cache !== false;
    this.cacheMap = new Map();
    this.queue = [];
    this.scheduled = false;
  }

  load(key) {
    if (this.cache && this.cacheMap.has(key)) {
      return Promise.resolve(this.cacheMap.get(key));
    }

    return new Promise((resolve, reject) => {
      this.queue.push({ key, resolve, reject });

      if (!this.scheduled) {
        this.scheduled = true;
        process.nextTick(() => this.dispatch());
      }
    });
  }

  async dispatch() {
    this.scheduled = false;
    const queue = this.queue.splice(0);
    const keys = queue.map(q => q.key);

    try {
      const values = await this.batchLoadFn(keys);

      queue.forEach((item, index) => {
        const value = values[index];
        if (this.cache) {
          this.cacheMap.set(item.key, value);
        }
        item.resolve(value);
      });
    } catch (error) {
      queue.forEach(item => item.reject(error));
    }
  }

  clear(key) {
    this.cacheMap.delete(key);
  }

  clearAll() {
    this.cacheMap.clear();
  }
}

const userLoader = new DataLoader(async (ids) => {
  const response = await fetch('/api/users/batch', {
    method: 'POST',
    body: JSON.stringify({ ids })
  });
  return response.json();
});

const user1 = await userLoader.load(1);
const user2 = await userLoader.load(2);
const user3 = await userLoader.load(3);
```

### Promise.all for Parallel Batching

Execute multiple independent requests concurrently using Promise.all, which sends all requests simultaneously rather than sequentially.

```javascript
const fetchMultiple = async (urls) => {
  const requests = urls.map(url => 
    fetch(url).then(res => res.json())
  );
  return Promise.all(requests);
};

const [users, posts, comments] = await fetchMultiple([
  '/api/users',
  '/api/posts',
  '/api/comments'
]);
```

### Promise.allSettled for Error-Tolerant Batching

When you need all requests to complete regardless of individual failures, Promise.allSettled ensures partial success handling.

```javascript
const fetchAllSettled = async (urls) => {
  const requests = urls.map(url =>
    fetch(url)
      .then(res => res.json())
      .catch(err => ({ error: err.message }))
  );
  return Promise.allSettled(requests);
};

const results = await fetchAllSettled([
  '/api/users',
  '/api/posts',
  '/api/invalid-endpoint'
]);

results.forEach((result, index) => {
  if (result.status === 'fulfilled') {
    console.log(`Request ${index} succeeded:`, result.value);
  } else {
    console.log(`Request ${index} failed:`, result.reason);
  }
});
```

### Chunked Batching

Split large batches into smaller chunks to avoid payload size limits or timeout issues.

```javascript
const chunkArray = (array, size) => {
  const chunks = [];
  for (let i = 0; i < array.length; i += size) {
    chunks.push(array.slice(i, i + size));
  }
  return chunks;
};

const batchWithChunking = async (items, chunkSize = 50) => {
  const chunks = chunkArray(items, chunkSize);
  const results = [];

  for (const chunk of chunks) {
    const response = await fetch('/api/batch', {
      method: 'POST',
      body: JSON.stringify({ items: chunk })
    });
    const data = await response.json();
    results.push(...data);
  }

  return results;
};

const allResults = await batchWithChunking(largeItemArray, 100);
```

### Concurrent Chunk Processing

Process multiple chunks simultaneously while limiting concurrency to prevent overwhelming the server.

```javascript
const batchWithConcurrency = async (items, chunkSize = 50, maxConcurrent = 3) => {
  const chunks = chunkArray(items, chunkSize);
  const results = [];

  for (let i = 0; i < chunks.length; i += maxConcurrent) {
    const batch = chunks.slice(i, i + maxConcurrent);
    const batchResults = await Promise.all(
      batch.map(chunk =>
        fetch('/api/batch', {
          method: 'POST',
          body: JSON.stringify({ items: chunk })
        }).then(res => res.json())
      )
    );
    results.push(...batchResults.flat());
  }

  return results;
};
```

### Debounced Batching

Delay batch execution until a quiet period occurs, useful for user-triggered actions like search queries or form inputs.

```javascript
class DebouncedBatcher {
  constructor(batchFn, delay = 300) {
    this.batchFn = batchFn;
    this.delay = delay;
    this.queue = [];
    this.timer = null;
    this.pending = [];
  }

  add(item) {
    return new Promise((resolve, reject) => {
      this.queue.push(item);
      this.pending.push({ resolve, reject });

      clearTimeout(this.timer);
      this.timer = setTimeout(() => this.execute(), this.delay);
    });
  }

  async execute() {
    if (this.queue.length === 0) return;

    const items = this.queue.splice(0);
    const promises = this.pending.splice(0);

    try {
      const results = await this.batchFn(items);
      results.forEach((result, index) => {
        promises[index].resolve(result);
      });
    } catch (error) {
      promises.forEach(p => p.reject(error));
    }
  }
}

const searchBatcher = new DebouncedBatcher(async (queries) => {
  const response = await fetch('/api/search/batch', {
    method: 'POST',
    body: JSON.stringify({ queries })
  });
  return response.json();
}, 300);

// User types quickly - only last batch executes
searchBatcher.add('ap');
searchBatcher.add('app');
searchBatcher.add('appl');
const results = await searchBatcher.add('apple');
```

### Adaptive Batching

Dynamically adjust batch size based on response times and error rates to optimize throughput.

```javascript
class AdaptiveBatcher {
  constructor(minBatch = 5, maxBatch = 100) {
    this.minBatch = minBatch;
    this.maxBatch = maxBatch;
    this.currentBatch = minBatch;
    this.queue = [];
    this.pending = [];
    this.metrics = { successes: 0, failures: 0, avgTime: 0 };
  }

  adjustBatchSize() {
    const successRate = this.metrics.successes / 
      (this.metrics.successes + this.metrics.failures);

    if (successRate > 0.95 && this.metrics.avgTime < 1000) {
      this.currentBatch = Math.min(this.currentBatch * 1.5, this.maxBatch);
    } else if (successRate < 0.8 || this.metrics.avgTime > 2000) {
      this.currentBatch = Math.max(this.currentBatch * 0.75, this.minBatch);
    }

    this.currentBatch = Math.floor(this.currentBatch);
  }

  async add(item) {
    return new Promise((resolve, reject) => {
      this.queue.push(item);
      this.pending.push({ resolve, reject });

      if (this.queue.length >= this.currentBatch) {
        this.flush();
      }
    });
  }

  async flush() {
    if (this.queue.length === 0) return;

    const batch = this.queue.splice(0, this.currentBatch);
    const promises = this.pending.splice(0, this.currentBatch);
    const startTime = Date.now();

    try {
      const response = await fetch('/api/batch', {
        method: 'POST',
        body: JSON.stringify({ items: batch })
      });

      const results = await response.json();
      const duration = Date.now() - startTime;

      this.metrics.successes++;
      this.metrics.avgTime = (this.metrics.avgTime + duration) / 2;

      results.forEach((result, index) => {
        promises[index].resolve(result);
      });
    } catch (error) {
      this.metrics.failures++;
      promises.forEach(p => p.reject(error));
    }

    this.adjustBatchSize();
  }
}
```

### Priority-Based Batching

Process high-priority requests before low-priority ones while still maintaining batching efficiency.

```javascript
class PriorityBatcher {
  constructor() {
    this.queues = {
      high: [],
      normal: [],
      low: []
    };
    this.pending = new Map();
    this.processing = false;
  }

  add(item, priority = 'normal') {
    return new Promise((resolve, reject) => {
      const id = Math.random();
      this.queues[priority].push({ id, item });
      this.pending.set(id, { resolve, reject });

      if (!this.processing) {
        this.process();
      }
    });
  }

  async process() {
    this.processing = true;

    while (this.hasItems()) {
      const batch = this.getNextBatch();
      
      try {
        const items = batch.map(b => b.item);
        const response = await fetch('/api/batch', {
          method: 'POST',
          body: JSON.stringify({ items })
        });

        const results = await response.json();

        batch.forEach((item, index) => {
          const pending = this.pending.get(item.id);
          pending.resolve(results[index]);
          this.pending.delete(item.id);
        });
      } catch (error) {
        batch.forEach(item => {
          const pending = this.pending.get(item.id);
          pending.reject(error);
          this.pending.delete(item.id);
        });
      }
    }

    this.processing = false;
  }

  hasItems() {
    return this.queues.high.length > 0 ||
           this.queues.normal.length > 0 ||
           this.queues.low.length > 0;
  }

  getNextBatch(maxSize = 10) {
    const batch = [];

    while (batch.length < maxSize && this.hasItems()) {
      if (this.queues.high.length > 0) {
        batch.push(this.queues.high.shift());
      } else if (this.queues.normal.length > 0) {
        batch.push(this.queues.normal.shift());
      } else if (this.queues.low.length > 0) {
        batch.push(this.queues.low.shift());
      }
    }

    return batch;
  }
}

const batcher = new PriorityBatcher();
await batcher.add({ action: 'update' }, 'high');
await batcher.add({ action: 'log' }, 'low');
```

### GraphQL Query Batching

Combine multiple GraphQL queries into a single HTTP request, reducing roundtrips for applications making numerous small queries.

```javascript
const batchGraphQLQueries = async (queries) => {
  const response = await fetch('/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(queries)
  });

  return response.json();
};

const queries = [
  { query: '{ user(id: 1) { name email } }' },
  { query: '{ posts(limit: 10) { title author } }' },
  { query: '{ comments(postId: 5) { text user } }' }
];

const results = await batchGraphQLQueries(queries);
```

### Retry Logic for Failed Batches

Implement exponential backoff and selective retry for failed batch requests.

```javascript
class RetryBatcher {
  constructor(maxRetries = 3, baseDelay = 1000) {
    this.maxRetries = maxRetries;
    this.baseDelay = baseDelay;
  }

  async executeBatch(items, retryCount = 0) {
    try {
      const response = await fetch('/api/batch', {
        method: 'POST',
        body: JSON.stringify({ items })
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      if (retryCount < this.maxRetries) {
        const delay = this.baseDelay * Math.pow(2, retryCount);
        await new Promise(resolve => setTimeout(resolve, delay));
        return this.executeBatch(items, retryCount + 1);
      }
      throw error;
    }
  }

  async executeWithPartialRetry(items) {
    try {
      return await this.executeBatch(items);
    } catch (error) {
      // Retry failed items individually
      const results = [];
      for (const item of items) {
        try {
          const result = await this.executeBatch([item]);
          results.push(result[0]);
        } catch (err) {
          results.push({ error: err.message, item });
        }
      }
      return results;
    }
  }
}
```

### Response Aggregation Patterns

Handle different response formats and aggregate results appropriately.

```javascript
const aggregateBatchResponses = async (requests) => {
  const response = await fetch('/api/batch', {
    method: 'POST',
    body: JSON.stringify({ requests })
  });

  const results = await response.json();

  return {
    successful: results.filter(r => !r.error),
    failed: results.filter(r => r.error),
    byType: results.reduce((acc, r) => {
      const type = r.type || 'unknown';
      if (!acc[type]) acc[type] = [];
      acc[type].push(r);
      return acc;
    }, {}),
    summary: {
      total: results.length,
      succeeded: results.filter(r => !r.error).length,
      failed: results.filter(r => r.error).length
    }
  };
};
```

### Server-Side Batch Processing

Backend implementation to handle batched requests efficiently.

```javascript
// Express.js example
app.post('/api/batch', async (req, res) => {
  const { requests } = req.body;
  
  const results = await Promise.allSettled(
    requests.map(async (request) => {
      try {
        switch (request.method) {
          case 'GET':
            return await handleGet(request.url);
          case 'POST':
            return await handlePost(request.url, request.body);
          case 'PUT':
            return await handlePut(request.url, request.body);
          case 'DELETE':
            return await handleDelete(request.url);
          default:
            throw new Error(`Unsupported method: ${request.method}`);
        }
      } catch (error) {
        return { error: error.message };
      }
    })
  );

  const formatted = results.map(result => {
    if (result.status === 'fulfilled') {
      return { data: result.value };
    } else {
      return { error: result.reason.message };
    }
  });

  res.json(formatted);
});
```

### Cache-Aware Batching

Check cache before batching requests, only fetching uncached data.

```javascript
class CachingBatcher {
  constructor() {
    this.cache = new Map();
    this.queue = [];
    this.pending = new Map();
  }

  async get(key) {
    if (this.cache.has(key)) {
      return this.cache.get(key);
    }

    return new Promise((resolve, reject) => {
      const id = Math.random();
      this.queue.push({ id, key });
      this.pending.set(id, { resolve, reject, key });

      setTimeout(() => this.flush(), 10);
    });
  }

  async flush() {
    if (this.queue.length === 0) return;

    const batch = this.queue.splice(0);
    const keys = batch.map(b => b.key);

    try {
      const response = await fetch('/api/batch', {
        method: 'POST',
        body: JSON.stringify({ keys })
      });

      const results = await response.json();

      batch.forEach((item, index) => {
        const result = results[index];
        this.cache.set(item.key, result);
        
        const pending = this.pending.get(item.id);
        pending.resolve(result);
        this.pending.delete(item.id);
      });
    } catch (error) {
      batch.forEach(item => {
        const pending = this.pending.get(item.id);
        pending.reject(error);
        this.pending.delete(item.id);
      });
    }
  }

  invalidate(key) {
    this.cache.delete(key);
  }
}
```

---

