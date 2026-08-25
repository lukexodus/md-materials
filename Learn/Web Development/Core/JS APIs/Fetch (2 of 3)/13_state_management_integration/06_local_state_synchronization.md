## Local State Synchronization


### Optimistic Updates

#### Immediate UI Updates

Apply state changes immediately before the fetch request completes to provide instant user feedback. Store the previous state to enable rollback if the request fails.

```javascript
const optimisticUpdate = async (item) => {
  const previousState = [...items];
  setItems(prev => [...prev, item]);
  
  try {
    const response = await fetch('/api/items', {
      method: 'POST',
      body: JSON.stringify(item)
    });
    const serverItem = await response.json();
    setItems(prev => prev.map(i => i.id === item.id ? serverItem : i));
  } catch (error) {
    setItems(previousState);
    showError('Update failed');
  }
};
```

The temporary client-side ID gets replaced with the server-assigned ID once the response returns. This pattern prevents flickering while maintaining data consistency.

#### Conflict Resolution

When multiple optimistic updates occur simultaneously, implement a queue system to process them sequentially. Track pending operations and their dependencies to avoid race conditions.

```javascript
const updateQueue = [];
let isProcessing = false;

const queueUpdate = async (operation) => {
  updateQueue.push(operation);
  if (!isProcessing) processQueue();
};

const processQueue = async () => {
  isProcessing = true;
  while (updateQueue.length > 0) {
    const operation = updateQueue.shift();
    await operation();
  }
  isProcessing = false;
};
```

#### Rollback Strategies

Implement granular rollback that only reverts the failed operation without affecting successful concurrent updates. Use version numbers or timestamps to identify which state changes belong to which operation.

```javascript
const withRollback = async (updateFn, rollbackFn) => {
  const checkpoint = createCheckpoint();
  updateFn();
  
  try {
    await fetch(/* ... */);
  } catch (error) {
    rollbackFn(checkpoint);
    throw error;
  }
};
```

### Polling Strategies

#### Fixed Interval Polling

Execute fetch requests at regular intervals to keep local state synchronized with the server. Clear intervals on component unmount to prevent memory leaks.

```javascript
useEffect(() => {
  const syncInterval = setInterval(async () => {
    const response = await fetch('/api/state');
    const serverState = await response.json();
    reconcileState(localState, serverState);
  }, 5000);
  
  return () => clearInterval(syncInterval);
}, []);
```

Choose polling intervals based on data volatility and user expectations. High-frequency updates require shorter intervals (1-5 seconds), while less critical data can poll every 30-60 seconds.

#### Adaptive Polling

Adjust polling frequency based on user activity, data freshness, or system load. Reduce polling when the tab is inactive or increase frequency after user interactions.

```javascript
let pollInterval = 10000;

document.addEventListener('visibilitychange', () => {
  pollInterval = document.hidden ? 60000 : 10000;
  restartPolling();
});

const restartPolling = () => {
  clearInterval(currentInterval);
  currentInterval = setInterval(poll, pollInterval);
};
```

Implement exponential backoff when the server returns errors to avoid overwhelming struggling services. Reset to normal intervals once successful responses resume.

#### Long Polling

Keep a fetch request open until the server has new data, then immediately start a new request. This pseudo-real-time approach reduces unnecessary requests compared to fixed polling.

```javascript
const longPoll = async () => {
  try {
    const response = await fetch('/api/updates?timeout=30');
    const updates = await response.json();
    applyUpdates(updates);
  } catch (error) {
    await new Promise(r => setTimeout(r, 5000));
  }
  longPoll(); // Immediately start next poll
};
```

### Synchronization Patterns

#### Last-Write-Wins

The most recent update overwrites previous values regardless of origin. Simple to implement but risks data loss when multiple clients update simultaneously.

```javascript
const sync = async (localData) => {
  const response = await fetch('/api/data', {
    method: 'PUT',
    body: JSON.stringify({
      ...localData,
      timestamp: Date.now()
    })
  });
};
```

#### Timestamp-Based Merging

Compare timestamps between local and server state to determine which changes to apply. Merge non-conflicting changes while flagging conflicts for user resolution.

```javascript
const merge = (local, server) => {
  const merged = {};
  for (const key in { ...local, ...server }) {
    if (!server[key]) merged[key] = local[key];
    else if (!local[key]) merged[key] = server[key];
    else if (local[key].timestamp > server[key].timestamp) {
      merged[key] = local[key];
    } else {
      merged[key] = server[key];
    }
  }
  return merged;
};
```

#### Version Vectors

Track update history across multiple clients using version vectors. Each client maintains counters for all participating clients to detect concurrent modifications and causal relationships.

```javascript
const versionVector = { clientA: 5, clientB: 3, clientC: 2 };

const updateVector = (clientId) => {
  versionVector[clientId] = (versionVector[clientId] || 0) + 1;
  return { ...versionVector };
};

const detectConflict = (v1, v2) => {
  const v1Newer = Object.keys(v1).some(k => v1[k] > (v2[k] || 0));
  const v2Newer = Object.keys(v2).some(k => v2[k] > (v1[k] || 0));
  return v1Newer && v2Newer; // Concurrent updates
};
```

#### Operational Transformation

Transform operations based on concurrent changes to maintain consistency. Each operation includes context about the state it was created against.

```javascript
const transform = (op1, op2) => {
  if (op1.position <= op2.position) {
    return op1;
  } else {
    return { ...op1, position: op1.position + op2.length };
  }
};
```

### Differential Synchronization

#### Delta Updates

Send only changed data rather than the entire state to reduce bandwidth and processing overhead. Calculate diffs client-side before fetch requests.

```javascript
const calculateDiff = (previous, current) => {
  const diff = {};
  for (const key in current) {
    if (JSON.stringify(previous[key]) !== JSON.stringify(current[key])) {
      diff[key] = current[key];
    }
  }
  return diff;
};

const syncDelta = async (previousState, currentState) => {
  const delta = calculateDiff(previousState, currentState);
  if (Object.keys(delta).length === 0) return;
  
  await fetch('/api/sync', {
    method: 'PATCH',
    body: JSON.stringify(delta)
  });
};
```

#### Patch Application

Apply incremental updates to local state when receiving server changes. Use JSON Patch (RFC 6902) format for standardized delta operations.

```javascript
const applyPatch = (state, patch) => {
  const newState = { ...state };
  for (const op of patch) {
    switch (op.op) {
      case 'add':
      case 'replace':
        setPath(newState, op.path, op.value);
        break;
      case 'remove':
        deletePath(newState, op.path);
        break;
    }
  }
  return newState;
};
```

### State Reconciliation

#### Three-Way Merge

Compare local state, server state, and the last synchronized common ancestor to intelligently merge changes from both sides.

```javascript
const threeWayMerge = (base, local, server) => {
  const merged = {};
  
  for (const key of new Set([...Object.keys(local), ...Object.keys(server)])) {
    if (local[key] === server[key]) {
      merged[key] = local[key];
    } else if (local[key] === base[key]) {
      merged[key] = server[key]; // Server changed
    } else if (server[key] === base[key]) {
      merged[key] = local[key]; // Local changed
    } else {
      merged[key] = resolveConflict(base[key], local[key], server[key]);
    }
  }
  
  return merged;
};
```

#### Conflict Detection

Identify concurrent modifications that cannot be automatically merged. Flag conflicts for user review or apply predefined resolution policies.

```javascript
const detectConflicts = (localChanges, serverChanges) => {
  const conflicts = [];
  
  for (const key in localChanges) {
    if (key in serverChanges) {
      if (JSON.stringify(localChanges[key]) !== JSON.stringify(serverChanges[key])) {
        conflicts.push({
          field: key,
          local: localChanges[key],
          server: serverChanges[key]
        });
      }
    }
  }
  
  return conflicts;
};
```

#### Manual Conflict Resolution

Present conflicting changes to users through UI components that allow choosing between versions or manually merging values.

```javascript
const resolveManually = async (conflicts) => {
  const resolutions = await showConflictUI(conflicts);
  
  const resolved = conflicts.map((conflict, i) => ({
    field: conflict.field,
    value: resolutions[i]
  }));
  
  await fetch('/api/resolve', {
    method: 'POST',
    body: JSON.stringify(resolved)
  });
};
```

### Queue Management

#### Offline Queue

Store failed fetch requests in a queue for retry when connectivity returns. Persist the queue to survive page reloads or crashes.

```javascript
class SyncQueue {
  constructor() {
    this.queue = this.loadQueue();
  }
  
  async add(request) {
    this.queue.push({
      url: request.url,
      options: request.options,
      timestamp: Date.now(),
      retries: 0
    });
    this.saveQueue();
    this.processQueue();
  }
  
  async processQueue() {
    while (this.queue.length > 0 && navigator.onLine) {
      const item = this.queue[0];
      try {
        await fetch(item.url, item.options);
        this.queue.shift();
        this.saveQueue();
      } catch (error) {
        item.retries++;
        if (item.retries > 5) {
          this.queue.shift(); // Give up
        }
        break;
      }
    }
  }
}
```

#### Priority Queuing

Process high-priority operations before low-priority ones. Critical updates execute immediately while background synchronization can wait.

```javascript
const priorityQueue = {
  high: [],
  normal: [],
  low: []
};

const enqueue = (operation, priority = 'normal') => {
  priorityQueue[priority].push(operation);
  processNext();
};

const processNext = async () => {
  const operation = 
    priorityQueue.high.shift() ||
    priorityQueue.normal.shift() ||
    priorityQueue.low.shift();
  
  if (operation) {
    await operation();
    processNext();
  }
};
```

#### Deduplication

Merge or eliminate redundant operations in the queue before execution. Multiple updates to the same resource can often be consolidated into a single request.

```javascript
const deduplicate = (queue) => {
  const seen = new Map();
  return queue.filter(op => {
    const key = `${op.method}-${op.url}`;
    if (seen.has(key)) {
      seen.get(key).data = { ...seen.get(key).data, ...op.data };
      return false;
    }
    seen.set(key, op);
    return true;
  });
};
```

### Event-Driven Synchronization

#### State Change Listeners

Trigger synchronization automatically when local state changes. Debounce rapid changes to avoid excessive fetch requests.

```javascript
let syncTimeout;

const onChange = (newState) => {
  clearTimeout(syncTimeout);
  syncTimeout = setTimeout(() => {
    syncToServer(newState);
  }, 1000);
};

const syncToServer = async (state) => {
  await fetch('/api/state', {
    method: 'PUT',
    body: JSON.stringify(state)
  });
};
```

#### Server-Sent Events Integration

Combine fetch with SSE to receive server-initiated updates. Fetch handles client-to-server synchronization while SSE handles server-to-client.

```javascript
const eventSource = new EventSource('/api/events');

eventSource.onmessage = (event) => {
  const serverUpdate = JSON.parse(event.data);
  mergeServerState(serverUpdate);
};

const sendUpdate = async (data) => {
  await fetch('/api/update', {
    method: 'POST',
    body: JSON.stringify(data)
  });
};
```

#### WebSocket Fallback

Use WebSocket for bidirectional real-time sync, falling back to fetch polling when WebSocket connections fail or aren't supported.

```javascript
let ws;
let pollInterval;

const connectWebSocket = () => {
  ws = new WebSocket('wss://api.example.com/sync');
  
  ws.onmessage = (event) => {
    applyUpdate(JSON.parse(event.data));
  };
  
  ws.onerror = () => {
    fallbackToPolling();
  };
};

const fallbackToPolling = () => {
  pollInterval = setInterval(async () => {
    const response = await fetch('/api/state');
    const state = await response.json();
    applyUpdate(state);
  }, 5000);
};
```

### Synchronization State Management

#### Sync Status Tracking

Maintain metadata about synchronization state including last sync time, pending operations, and error conditions.

```javascript
const syncState = {
  lastSync: null,
  pending: [],
  syncing: false,
  errors: []
};

const updateSyncStatus = (status) => {
  Object.assign(syncState, status);
  notifyStatusListeners(syncState);
};
```

#### Progress Indication

Display synchronization progress to users, especially for large datasets or slow connections. Track bytes transferred and estimated completion time.

```javascript
const syncWithProgress = async (data) => {
  const chunks = chunkData(data, 1000);
  
  for (let i = 0; i < chunks.length; i++) {
    await fetch('/api/sync', {
      method: 'POST',
      body: JSON.stringify(chunks[i])
    });
    
    updateProgress({
      current: i + 1,
      total: chunks.length,
      percentage: ((i + 1) / chunks.length) * 100
    });
  }
};
```

#### Error Recovery

Implement automatic retry with exponential backoff for transient failures. Distinguish between retryable errors (network issues) and permanent failures (validation errors).

```javascript
const fetchWithRetry = async (url, options, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      if (!response.ok && response.status >= 500) {
        throw new Error('Server error');
      }
      return response;
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise(r => setTimeout(r, Math.pow(2, i) * 1000));
    }
  }
};
```

### Batch Synchronization

#### Request Batching

Accumulate multiple state changes and send them in a single fetch request to reduce network overhead.

```javascript
let batchQueue = [];
let batchTimeout;

const addToBatch = (change) => {
  batchQueue.push(change);
  
  clearTimeout(batchTimeout);
  batchTimeout = setTimeout(flushBatch, 100);
  
  if (batchQueue.length >= 50) {
    flushBatch();
  }
};

const flushBatch = async () => {
  if (batchQueue.length === 0) return;
  
  const batch = [...batchQueue];
  batchQueue = [];
  
  await fetch('/api/batch', {
    method: 'POST',
    body: JSON.stringify(batch)
  });
};
```

#### Response Aggregation

Process batched server responses and apply multiple state updates atomically to maintain consistency.

```javascript
const processBatchResponse = (responses) => {
  setState(prevState => {
    let newState = { ...prevState };
    
    for (const response of responses) {
      newState = applyUpdate(newState, response);
    }
    
    return newState;
  });
};
```

### Consistency Guarantees

#### Read-Your-Writes

Ensure users see their own changes immediately by updating local state optimistically, even if server confirmation is pending.

```javascript
const writeWithLocalRead = async (data) => {
  const tempId = generateTempId();
  updateLocalState({ ...data, id: tempId });
  
  const response = await fetch('/api/items', {
    method: 'POST',
    body: JSON.stringify(data)
  });
  
  const serverData = await response.json();
  updateLocalState(serverData, tempId);
};
```

#### Monotonic Reads

Prevent users from seeing older versions of data after viewing newer versions by tracking sequence numbers or timestamps.

```javascript
let lastSeenVersion = 0;

const applyUpdate = (update) => {
  if (update.version > lastSeenVersion) {
    setState(update.data);
    lastSeenVersion = update.version;
  }
};
```

#### Causal Consistency

Maintain cause-and-effect relationships between operations. Dependent updates wait for their prerequisites to complete.

```javascript
const dependencies = new Map();

const executeWithDependencies = async (operation) => {
  const deps = dependencies.get(operation.id) || [];
  await Promise.all(deps.map(id => operations.get(id)));
  
  await fetch(operation.url, operation.options);
  operations.set(operation.id, Promise.resolve());
};
```

---

