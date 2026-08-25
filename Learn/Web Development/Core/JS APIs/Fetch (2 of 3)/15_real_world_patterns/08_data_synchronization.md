## Data Synchronization


### Real-time Synchronization

#### WebSocket + Fetch Hybrid

```javascript
function useRealtimeSync(endpoint, wsUrl) {
  const [data, setData] = useState(null);
  const [status, setStatus] = useState('disconnected');
  const wsRef = useRef(null);

  const fetchInitialData = useCallback(async () => {
    const res = await fetch(endpoint);
    if (!res.ok) throw new Error('Failed to fetch');
    const json = await res.json();
    setData(json);
  }, [endpoint]);

  useEffect(() => {
    const ws = new WebSocket(wsUrl);
    wsRef.current = ws;

    ws.onopen = () => {
      setStatus('connected');
      fetchInitialData();
    };

    ws.onmessage = (event) => {
      const update = JSON.parse(event.data);
      setData(prev => {
        if (update.type === 'full') return update.data;
        if (update.type === 'patch') return applyPatch(prev, update.patch);
        return prev;
      });
    };

    ws.onerror = () => setStatus('error');
    ws.onclose = () => setStatus('disconnected');

    return () => ws.close();
  }, [wsUrl, fetchInitialData]);

  return { data, status };
}
```

#### Server-Sent Events

```javascript
function useSSESync(url) {
  const [data, setData] = useState(null);
  const [status, setStatus] = useState('connecting');

  useEffect(() => {
    const eventSource = new EventSource(url);

    eventSource.onopen = () => setStatus('connected');
    eventSource.onmessage = (e) => setData(JSON.parse(e.data));
    eventSource.addEventListener('patch', (e) => {
      const patch = JSON.parse(e.data);
      setData(prev => applyPatch(prev, patch));
    });
    eventSource.onerror = () => setStatus('error');

    return () => eventSource.close();
  }, [url]);

  return { data, status };
}
```

### Optimistic UI

#### Queue-based Updates

```javascript
function useOptimisticQueue(endpoint) {
  const [data, setData] = useState([]);
  const [queue, setQueue] = useState([]);
  const [syncing, setSyncing] = useState(false);

  const processQueue = useCallback(async () => {
    if (queue.length === 0 || syncing) return;

    setSyncing(true);
    const operation = queue[0];

    try {
      const res = await fetch(endpoint, {
        method: operation.method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(operation.data)
      });

      if (!res.ok) throw new Error('Sync failed');
      const result = await res.json();

      setData(prev => prev.map(item =>
        item.id === operation.tempId ? { ...result, id: result.id } : item
      ));

      setQueue(prev => prev.slice(1));
    } catch (err) {
      setData(prev => prev.filter(item => item.id !== operation.tempId));
      setQueue(prev => prev.slice(1));
    } finally {
      setSyncing(false);
    }
  }, [endpoint, queue, syncing]);

  useEffect(() => {
    if (queue.length > 0) processQueue();
  }, [queue, processQueue]);

  const addItem = useCallback((item) => {
    const tempId = `temp-${Date.now()}`;
    setData(prev => [...prev, { ...item, id: tempId, _pending: true }]);
    setQueue(prev => [...prev, { method: 'POST', data: item, tempId }]);
  }, []);

  return { data, addItem, syncing, queueSize: queue.length };
}
```

#### Conflict Resolution

```javascript
function useConflictResolution(endpoint, strategy = 'server-wins') {
  const [data, setData] = useState({});
  const [conflicts, setConflicts] = useState([]);
  const versionRef = useRef({});

  const updateItem = useCallback(async (id, updates) => {
    const currentVersion = versionRef.current[id];
    const optimistic = { ...data[id], ...updates };

    setData(prev => ({ ...prev, [id]: optimistic }));

    try {
      const res = await fetch(`${endpoint}/${id}`, {
        method: 'PATCH',
        headers: { 
          'Content-Type': 'application/json',
          'If-Match': currentVersion
        },
        body: JSON.stringify(updates)
      });

      if (res.status === 412) {
        const serverData = await res.json();
        
        setConflicts(prev => [...prev, {
          id,
          local: optimistic,
          server: serverData.current,
          timestamp: Date.now()
        }]);

        if (strategy === 'server-wins') {
          setData(prev => ({ ...prev, [id]: serverData.current }));
          versionRef.current[id] = serverData.current.version;
        }

        return { conflict: true, data: serverData.current };
      }

      const result = await res.json();
      setData(prev => ({ ...prev, [id]: result }));
      versionRef.current[id] = result.version;

      return { conflict: false, data: result };
    } catch (err) {
      setData(prev => ({ ...prev, [id]: data[id] }));
      throw err;
    }
  }, [endpoint, data, strategy]);

  return { data: Object.values(data), conflicts, updateItem };
}
```

### Offline Synchronization

#### IndexedDB Queue

```javascript
function useOfflineSync(endpoint, dbName = 'offline-queue') {
  const [online, setOnline] = useState(navigator.onLine);
  const [pendingCount, setPendingCount] = useState(0);
  const dbRef = useRef(null);

  useEffect(() => {
    const request = indexedDB.open(dbName, 1);

    request.onupgradeneeded = (e) => {
      const db = e.target.result;
      if (!db.objectStoreNames.contains('queue')) {
        db.createObjectStore('queue', { keyPath: 'id', autoIncrement: true });
      }
    };

    request.onsuccess = (e) => {
      dbRef.current = e.target.result;
      updateCount();
    };

    const handleOnline = () => {
      setOnline(true);
      syncQueue();
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', () => setOnline(false));

    return () => {
      window.removeEventListener('online', handleOnline);
      if (dbRef.current) dbRef.current.close();
    };
  }, []);

  const updateCount = useCallback(() => {
    if (!dbRef.current) return;
    const tx = dbRef.current.transaction(['queue'], 'readonly');
    const store = tx.objectStore('queue');
    const req = store.count();
    req.onsuccess = () => setPendingCount(req.result);
  }, []);

  const enqueue = useCallback(async (operation) => {
    if (!dbRef.current) return;
    const tx = dbRef.current.transaction(['queue'], 'readwrite');
    const store = tx.objectStore('queue');
    store.add({ ...operation, timestamp: Date.now() });
    tx.oncomplete = () => {
      updateCount();
      if (online) syncQueue();
    };
  }, [online]);

  const syncQueue = useCallback(async () => {
    if (!dbRef.current || !online) return;
    const tx = dbRef.current.transaction(['queue'], 'readwrite');
    const store = tx.objectStore('queue');
    const req = store.getAll();

    req.onsuccess = async () => {
      for (const item of req.result) {
        try {
          const res = await fetch(`${endpoint}${item.path}`, {
            method: item.method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(item.data)
          });

          if (res.ok) {
            const delTx = dbRef.current.transaction(['queue'], 'readwrite');
            delTx.objectStore('queue').delete(item.id);
          }
        } catch (err) {
          console.error('Sync error:', err);
        }
      }
      updateCount();
    };
  }, [endpoint, online]);

  return { online, pendingCount, enqueue, syncQueue };
}
```

#### Cache-First Strategy

```javascript
function useCacheFirstSync(endpoint) {
  const [data, setData] = useState(null);
  const [cacheAge, setCacheAge] = useState(null);

  const getCacheKey = () => `cache:${endpoint}`;

  const loadCache = useCallback(async () => {
    const cached = localStorage.getItem(getCacheKey());
    if (cached) {
      const { data, timestamp } = JSON.parse(cached);
      setData(data);
      setCacheAge(Date.now() - timestamp);
      return true;
    }
    return false;
  }, [endpoint]);

  const saveCache = useCallback((data) => {
    localStorage.setItem(getCacheKey(), JSON.stringify({
      data,
      timestamp: Date.now()
    }));
  }, [endpoint]);

  const fetchServer = useCallback(async () => {
    const res = await fetch(endpoint);
    if (!res.ok) throw new Error('Fetch failed');
    const json = await res.json();
    setData(json);
    saveCache(json);
    setCacheAge(0);
  }, [endpoint, saveCache]);

  useEffect(() => {
    loadCache().then(hasCache => {
      if (!hasCache) fetchServer();
      else fetchServer(); // Background sync
    });
  }, []);

  return { data, cacheAge };
}
```

### Differential Sync

#### Delta Updates

```javascript
function useDeltaSync(endpoint) {
  const [data, setData] = useState([]);
  const [lastSync, setLastSync] = useState(null);

  const fetchDelta = useCallback(async () => {
    const params = new URLSearchParams();
    if (lastSync) params.set('since', lastSync.toISOString());

    const res = await fetch(`${endpoint}?${params}`);
    if (!res.ok) throw new Error('Delta fetch failed');

    const delta = await res.json();

    setData(prev => {
      let updated = [...prev];

      if (delta.deleted) {
        updated = updated.filter(item => !delta.deleted.includes(item.id));
      }

      if (delta.updated) {
        delta.updated.forEach(newItem => {
          const idx = updated.findIndex(item => item.id === newItem.id);
          if (idx >= 0) updated[idx] = newItem;
          else updated.push(newItem);
        });
      }

      return updated;
    });

    setLastSync(new Date());
  }, [endpoint, lastSync]);

  return { data, fetchDelta, lastSync };
}
```

#### Three-way Merge

```javascript
function useThreeWayMerge(endpoint) {
  const [data, setData] = useState({});
  const baselineRef = useRef({});
  const dirtyRef = useRef(new Set());

  const merge = useCallback((base, local, server) => {
    const merged = { ...base };

    Object.keys({ ...local, ...server }).forEach(key => {
      const baseVal = base[key];
      const localVal = local[key];
      const serverVal = server[key];

      if (localVal === serverVal) {
        merged[key] = localVal;
      } else if (localVal === baseVal) {
        merged[key] = serverVal;
      } else if (serverVal === baseVal) {
        merged[key] = localVal;
      } else {
        merged[key] = { _conflict: true, local: localVal, server: serverVal };
      }
    });

    return merged;
  }, []);

  const updateLocal = useCallback((id, updates) => {
    setData(prev => {
      dirtyRef.current.add(id);
      return { ...prev, [id]: { ...prev[id], ...updates } };
    });
  }, []);

  const sync = useCallback(async () => {
    const dirtyIds = Array.from(dirtyRef.current);
    if (dirtyIds.length === 0) return;

    const res = await fetch(`${endpoint}/sync`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ids: dirtyIds })
    });

    const serverData = await res.json();

    setData(prev => {
      const merged = { ...prev };
      dirtyIds.forEach(id => {
        const base = baselineRef.current[id] || {};
        merged[id] = merge(base, prev[id], serverData[id]);
        baselineRef.current[id] = serverData[id];
      });
      return merged;
    });

    dirtyRef.current.clear();
  }, [endpoint, merge]);

  return { data: Object.values(data), updateLocal, sync };
}
```

### Batch Synchronization

#### Batch Processor

```javascript
function useBatchSync(endpoint, batchSize = 10, delay = 1000) {
  const [pending, setPending] = useState([]);
  const [processing, setProcessing] = useState(false);

  const processBatch = useCallback(async () => {
    if (processing || pending.length === 0) return;

    setProcessing(true);
    const batch = pending.slice(0, batchSize);

    try {
      const res = await fetch(`${endpoint}/batch`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ operations: batch })
      });

      if (res.ok) {
        setPending(prev => prev.slice(batchSize));
      }
    } catch (err) {
      console.error('Batch failed:', err);
    } finally {
      setProcessing(false);
    }
  }, [endpoint, batchSize, pending, processing]);

  useEffect(() => {
    if (pending.length >= batchSize) {
      processBatch();
    } else if (pending.length > 0) {
      const timer = setTimeout(processBatch, delay);
      return () => clearTimeout(timer);
    }
  }, [pending, batchSize, delay, processBatch]);

  const addOperation = useCallback((op) => {
    setPending(prev => [...prev, { ...op, id: Date.now() }]);
  }, []);

  return { addOperation, pendingCount: pending.length, processing };
}
```

### Eventual Consistency

#### CRDT Operations

```javascript
function useCRDTSync(endpoint, userId) {
  const [state, setState] = useState({ items: new Map(), vector: {} });

  const addItem = useCallback(async (item) => {
    const vector = { ...state.vector, [userId]: (state.vector[userId] || 0) + 1 };
    const operation = {
      type: 'add',
      id: `${userId}-${Date.now()}`,
      data: item,
      vector
    };

    setState(prev => {
      const items = new Map(prev.items);
      items.set(operation.id, item);
      return { items, vector };
    });

    await fetch(`${endpoint}/operations`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(operation)
    });
  }, [endpoint, userId, state.vector]);

  return { items: Array.from(state.items.values()), addItem };
}
```

### Polling Strategies

#### Smart Polling

```javascript
function useSmartPolling(endpoint, baseInterval = 5000) {
  const [data, setData] = useState(null);
  const [interval, setInterval] = useState(baseInterval);
  const lastChangeRef = useRef(Date.now());

  useEffect(() => {
    const poll = async () => {
      const res = await fetch(endpoint);
      const json = await res.json();

      if (JSON.stringify(json) !== JSON.stringify(data)) {
        lastChangeRef.current = Date.now();
        setInterval(baseInterval);
      } else {
        const timeSinceChange = Date.now() - lastChangeRef.current;
        if (timeSinceChange > 30000) {
          setInterval(Math.min(interval * 1.5, 60000));
        }
      }

      setData(json);
    };

    poll();
    const timer = setInterval(poll, interval);
    return () => clearInterval(timer);
  }, [endpoint, interval, baseInterval, data]);

  return { data };
}
```

#### Long Polling

```javascript
function useLongPolling(endpoint) {
  const [data, setData] = useState(null);
  const [connected, setConnected] = useState(false);

  useEffect(() => {
    let active = true;

    const poll = async () => {
      try {
        setConnected(true);
        const res = await fetch(`${endpoint}?timeout=30`);
        if (!res.ok) throw new Error('Poll failed');

        const json = await res.json();
        if (active) {
          setData(json);
          poll();
        }
      } catch (err) {
        setConnected(false);
        if (active) {
          setTimeout(poll, 3000);
        }
      }
    };

    poll();

    return () => {
      active = false;
    };
  }, [endpoint]);

  return { data, connected };
}
```

### Sync Coordination

#### Leader Election

```javascript
function useLeaderElection(tabId = Math.random().toString(36)) {
  const [isLeader, setIsLeader] = useState(false);
  const channelRef = useRef(null);

  useEffect(() => {
    const channel = new BroadcastChannel('sync-coordination');
    channelRef.current = channel;

    const heartbeatKey = 'leader-heartbeat';
    
    const checkLeadership = () => {
      const lastHeartbeat = localStorage.getItem(heartbeatKey);
      const now = Date.now();

      if (!lastHeartbeat || now - parseInt(lastHeartbeat) > 5000) {
        localStorage.setItem(heartbeatKey, now.toString());
        setIsLeader(true);
        channel.postMessage({ type: 'leader', id: tabId });
      } else {
        setIsLeader(false);
      }
    };

    channel.onmessage = (e) => {
      if (e.data.type === 'leader' && e.data.id !== tabId) {
        setIsLeader(false);
      }
    };

    checkLeadership();
    const interval = setInterval(checkLeadership, 2000);

    return () => {
      clearInterval(interval);
      channel.close();
    };
  }, [tabId]);

  return isLeader;
}
```

#### Broadcast Updates

```javascript
function useBroadcastSync(channelName = 'data-sync') {
  const [data, setData] = useState(null);
  const channelRef = useRef(null);

  useEffect(() => {
    const channel = new BroadcastChannel(channelName);
    channelRef.current = channel;

    channel.onmessage = (event) => {
      if (event.data.type === 'update') {
        setData(event.data.payload);
      }
    };

    return () => channel.close();
  }, [channelName]);

  const broadcastUpdate = useCallback((newData) => {
    setData(newData);
    channelRef.current?.postMessage({
      type: 'update',
      payload: newData,
      timestamp: Date.now()
    });
  }, []);

  return { data, broadcastUpdate };
}
```

---

