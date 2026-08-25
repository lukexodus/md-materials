## Parallel Map


Parallel map applies a transformation function to each element of a collection concurrently, utilizing multiple threads or processes to improve performance on large datasets. Unlike sequential map which processes elements one at a time, parallel map distributes the work across available computational resources.

**Core Concept**

Split the input collection into chunks, process each chunk independently and simultaneously, then combine the results in the original order. The transformation function must be pure and free of side effects to ensure thread safety and correctness.

```javascript
// Basic parallel map using Promise.all
const parallelMap = async (array, asyncFn) => {
  return await Promise.all(array.map(item => asyncFn(item)));
};

// Usage
const numbers = [1, 2, 3, 4, 5];
const results = await parallelMap(numbers, async (n) => {
  await simulateWork(100); // Simulate async operation
  return n * 2;
});
// All transformations happen concurrently
```

**Chunked Parallel Processing**

For very large arrays, process in batches to control concurrency and prevent resource exhaustion. This limits the number of simultaneous operations while still gaining parallelism benefits.

```javascript
const parallelMapChunked = async (array, asyncFn, chunkSize = 10) => {
  const results = [];
  
  for (let i = 0; i < array.length; i += chunkSize) {
    const chunk = array.slice(i, i + chunkSize);
    const chunkResults = await Promise.all(chunk.map(asyncFn));
    results.push(...chunkResults);
  }
  
  return results;
};

// Process 1000 items, 50 at a time
const largeDataset = Array.from({ length: 1000 }, (_, i) => i);
const processed = await parallelMapChunked(
  largeDataset,
  async (n) => await heavyComputation(n),
  50
);
```

**Worker Pool Pattern**

Implement a worker pool to manage a fixed number of concurrent workers, queuing tasks and processing them as workers become available.

```javascript
const createWorkerPool = (workerCount) => {
  let activeWorkers = 0;
  const queue = [];
  
  const processNext = () => {
    if (queue.length === 0 || activeWorkers >= workerCount) return;
    
    const { task, resolve, reject } = queue.shift();
    activeWorkers++;
    
    task()
      .then(resolve)
      .catch(reject)
      .finally(() => {
        activeWorkers--;
        processNext();
      });
  };
  
  return {
    execute(task) {
      return new Promise((resolve, reject) => {
        queue.push({ task, resolve, reject });
        processNext();
      });
    }
  };
};

const parallelMapWithPool = async (array, asyncFn, poolSize = 5) => {
  const pool = createWorkerPool(poolSize);
  return await Promise.all(
    array.map(item => pool.execute(() => asyncFn(item)))
  );
};

// Only 5 items processed simultaneously, rest queued
const results = await parallelMapWithPool(
  largeArray,
  expensiveOperation,
  5
);
```

**Partition-Based Parallelism**

Divide data across multiple partitions processed independently, useful for CPU-intensive operations that can leverage multiple cores.

```javascript
// Simulating parallel execution with Web Workers concept
const parallelMapPartitioned = async (array, fn, partitionCount = 4) => {
  const partitionSize = Math.ceil(array.length / partitionCount);
  const partitions = [];
  
  for (let i = 0; i < partitionCount; i++) {
    const start = i * partitionSize;
    const end = Math.min(start + partitionSize, array.length);
    partitions.push(array.slice(start, end));
  }
  
  // Each partition processed in parallel
  const partitionResults = await Promise.all(
    partitions.map(async (partition) => {
      return partition.map(fn); // Sequential within partition
    })
  );
  
  // Flatten results
  return partitionResults.flat();
};

// Divide work across 4 logical processors
const data = Array.from({ length: 1000 }, (_, i) => i);
const squared = await parallelMapPartitioned(
  data,
  (n) => n * n,
  4
);
```

**Error Handling in Parallel Map**

Handle failures gracefully without losing successful results, implementing strategies like fail-fast or collect-all-results.

```javascript
const parallelMapSafe = async (array, asyncFn) => {
  const results = await Promise.allSettled(
    array.map(item => asyncFn(item))
  );
  
  return results.map((result, index) => ({
    index,
    status: result.status,
    value: result.status === 'fulfilled' ? result.value : undefined,
    error: result.status === 'rejected' ? result.reason : undefined
  }));
};

// Usage
const mixedResults = await parallelMapSafe(urls, async (url) => {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Failed: ${url}`);
  return await response.json();
});

const successful = mixedResults.filter(r => r.status === 'fulfilled');
const failed = mixedResults.filter(r => r.status === 'rejected');
```

**Ordered vs Unordered Results**

Choose between maintaining input order (ordered) or accepting results as they complete (unordered) for better performance.

```javascript
// Ordered - maintains original sequence
const orderedParallelMap = async (array, asyncFn) => {
  return await Promise.all(array.map(asyncFn));
};

// Unordered - accepts results as they complete
const unorderedParallelMap = async (array, asyncFn) => {
  const results = [];
  const promises = array.map(async (item, index) => {
    const result = await asyncFn(item);
    return { index, result };
  });
  
  for (const promise of promises) {
    const { result } = await promise;
    results.push(result);
  }
  
  return results;
};

// Stream results as they arrive
const streamingParallelMap = (array, asyncFn, onResult) => {
  const promises = array.map(async (item, index) => {
    const result = await asyncFn(item);
    onResult(result, index);
    return result;
  });
  
  return Promise.all(promises);
};

await streamingParallelMap(
  items,
  processItem,
  (result, index) => console.log(`Item ${index} completed:`, result)
);
```

**Adaptive Concurrency**

Dynamically adjust parallelism based on system load or performance metrics.

```javascript
const adaptiveParallelMap = async (array, asyncFn, initialConcurrency = 10) => {
  let concurrency = initialConcurrency;
  const results = [];
  let index = 0;
  
  const adjustConcurrency = (executionTime) => {
    if (executionTime < 100) concurrency = Math.min(concurrency + 2, 50);
    else if (executionTime > 500) concurrency = Math.max(concurrency - 2, 1);
  };
  
  while (index < array.length) {
    const chunk = array.slice(index, index + concurrency);
    const startTime = Date.now();
    
    const chunkResults = await Promise.all(
      chunk.map(item => asyncFn(item))
    );
    
    const executionTime = Date.now() - startTime;
    adjustConcurrency(executionTime / chunk.length);
    
    results.push(...chunkResults);
    index += chunk.length;
  }
  
  return results;
};
```

---

