## Fork-Join Pattern


The fork-join pattern divides a task into independent subtasks (fork), processes them in parallel, then combines their results (join). This is the fundamental pattern underlying most parallel functional programming.

**Basic Fork-Join Structure**

Split a task into subtasks, execute them concurrently, and merge results.

```javascript
const forkJoin = async (tasks, joinFn) => {
  const results = await Promise.all(tasks.map(task => task()));
  return joinFn(results);
};

// Usage
const result = await forkJoin(
  [
    async () => await fetchUserData(userId),
    async () => await fetchUserPosts(userId),
    async () => await fetchUserFollowers(userId)
  ],
  ([userData, posts, followers]) => ({
    ...userData,
    posts,
    followers
  })
);
```

**Recursive Fork-Join**

Apply fork-join recursively for divide-and-conquer algorithms, with automatic parallelism management.

```javascript
const recursiveForkJoin = async (data, shouldSplit, process, combine) => {
  if (!shouldSplit(data)) {
    return await process(data);
  }
  
  const [left, right] = splitData(data);
  
  const [leftResult, rightResult] = await Promise.all([
    recursiveForkJoin(left, shouldSplit, process, combine),
    recursiveForkJoin(right, shouldSplit, process, combine)
  ]);
  
  return await combine(leftResult, rightResult);
};

// Parallel merge sort
const parallelMergeSort = async (array) => {
  return await recursiveForkJoin(
    array,
    (arr) => arr.length > 1,
    async (arr) => arr, // Base case - already sorted
    async (left, right) => merge(left, right)
  );
};

const merge = (left, right) => {
  const result = [];
  let i = 0, j = 0;
  
  while (i < left.length && j < right.length) {
    if (left[i] <= right[j]) {
      result.push(left[i++]);
    } else {
      result.push(right[j++]);
    }
  }
  
  return [...result, ...left.slice(i), ...right.slice(j)];
};

const splitData = (array) => {
  const mid = Math.floor(array.length / 2);
  return [array.slice(0, mid), array.slice(mid)];
};
```

**Controlled Parallelism Fork-Join**

Limit the degree of parallelism to prevent resource exhaustion while maintaining concurrency benefits.

```javascript
const createForkJoinPool = (maxConcurrency) => {
  let running = 0;
  const queue = [];
  
  const execute = async (task) => {
    while (running >= maxConcurrency) {
      await new Promise(resolve => queue.push(resolve));
    }
    
    running++;
    try {
      return await task();
    } finally {
      running--;
      if (queue.length > 0) {
        queue.shift()();
      }
    }
  };
  
  return {
    forkJoin: async (tasks, joinFn) => {
      const results = await Promise.all(
        tasks.map(task => execute(task))
      );
      return joinFn(results);
    }
  };
};

// Limit to 5 concurrent operations
const pool = createForkJoinPool(5);
const result = await pool.forkJoin(
  manyTasks,
  combineResults
);
```

**Work-Stealing Fork-Join**

Implement work stealing where idle workers can take tasks from busy workers' queues.

```javascript
const createWorkStealingPool = (workerCount) => {
  const workers = Array.from({ length: workerCount }, () => ({
    queue: [],
    busy: false
  }));
  
  let nextWorker = 0;
  
  const scheduleTask = (task) => {
    const worker = workers[nextWorker];
    nextWorker = (nextWorker + 1) % workerCount;
    worker.queue.push(task);
    if (!worker.busy) {
      processQueue(worker);
    }
  };
  
  const processQueue = async (worker) => {
    worker.busy = true;
    
    while (worker.queue.length > 0) {
      const task = worker.queue.shift();
      await task();
      
      // Try to steal work if queue is empty
      if (worker.queue.length === 0) {
        const victim = workers.find(w => w.queue.length > 1);
        if (victim) {
          const stolen = victim.queue.pop();
          if (stolen) worker.queue.push(stolen);
        }
      }
    }
    
    worker.busy = false;
  };
  
  return {
    forkJoin: async (tasks, joinFn) => {
      const results = new Array(tasks.length);
      
      const wrappedTasks = tasks.map((task, index) => async () => {
        results[index] = await task();
      });
      
      wrappedTasks.forEach(scheduleTask);
      
      // Wait for all workers to finish
      await new Promise(resolve => {
        const check = setInterval(() => {
          if (workers.every(w => !w.busy && w.queue.length === 0)) {
            clearInterval(check);
            resolve();
          }
        }, 10);
      });
      
      return joinFn(results);
    }
  };
};
```

**Nested Fork-Join**

Compose multiple levels of fork-join for hierarchical parallel processing.

```javascript
const nestedForkJoin = async (data, processLevel) => {
  const topLevel = await forkJoin(
    data.departments.map(dept => async () => {
      return await forkJoin(
        dept.teams.map(team => async () => {
          return await forkJoin(
            team.members.map(member => async () => 
              await processLevel(member)
            ),
            (memberResults) => ({
              team: team.name,
              results: memberResults
            })
          );
        }),
        (teamResults) => ({
          department: dept.name,
          teams: teamResults
        })
      );
    }),
    (deptResults) => ({
      organization: data.name,
      departments: deptResults
    })
  );
  
  return topLevel;
};

// Process organization hierarchy in parallel at all levels
const orgReport = await nestedForkJoin(
  organizationData,
  async (member) => await generateMemberReport(member)
);
```

**Exception Handling in Fork-Join**

Handle failures in subtasks while preserving successful results or implementing retry logic.

```javascript
const forkJoinSafe = async (tasks, joinFn, errorHandler) => {
  const results = await Promise.allSettled(
    tasks.map((task, index) => 
      task().catch(error => errorHandler(error, index))
    )
  );
  
  const successful = results
    .filter(r => r.status === 'fulfilled')
    .map(r => r.value);
  
  const failed = results
    .map((r, index) => ({ result: r, index }))
    .filter(({ result }) => result.status === 'rejected');
  
  if (failed.length > 0) {
    console.warn(`${failed.length} tasks failed`);
  }
  
  return joinFn(successful, failed);
};

// Usage with error handling
const result = await forkJoinSafe(
  riskyTasks,
  (successful, failed) => ({
    data: successful,
    errors: failed.length,
    success: failed.length === 0
  }),
  (error, taskIndex) => {
    console.error(`Task ${taskIndex} failed:`, error);
    return null;
  }
);
```

**Cancellable Fork-Join**

Implement cancellation tokens to abort fork-join operations mid-execution.

```javascript
const createCancellableToken = () => {
  let cancelled = false;
  const listeners = [];
  
  return {
    cancel() {
      cancelled = true;
      listeners.forEach(fn => fn());
    },
    
    isCancelled() {
      return cancelled;
    },
    
    onCancel(fn) {
      listeners.push(fn);
    },
    
    throwIfCancelled() {
      if (cancelled) throw new Error('Operation cancelled');
    }
  };
};

const cancellableForkJoin = async (tasks, joinFn, cancelToken) => {
  const results = await Promise.all(
    tasks.map(async (task) => {
      cancelToken.throwIfCancelled();
      const
```

