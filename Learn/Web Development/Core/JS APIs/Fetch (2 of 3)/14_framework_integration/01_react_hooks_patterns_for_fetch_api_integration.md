## React Hooks Patterns for Fetch API Integration


### Basic Data Fetching

#### useEffect for Single Request

```javascript
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    setLoading(true);
    fetch(`/api/users/${userId}`)
      .then(res => {
        if (!res.ok) throw new Error('Failed to fetch');
        return res.json();
      })
      .then(data => {
        setUser(data);
        setError(null);
      })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  return <div>{user?.name}</div>;
}
```

#### AbortController for Cleanup

```javascript
useEffect(() => {
  const controller = new AbortController();
  
  fetch('/api/data', { signal: controller.signal })
    .then(res => res.json())
    .then(setData)
    .catch(err => {
      if (err.name !== 'AbortError') {
        setError(err.message);
      }
    });

  return () => controller.abort();
}, []);
```

#### Async/Await Pattern

```javascript
useEffect(() => {
  const controller = new AbortController();
  
  async function fetchData() {
    try {
      setLoading(true);
      const res = await fetch('/api/data', { signal: controller.signal });
      if (!res.ok) throw new Error(`HTTP error: ${res.status}`);
      const json = await res.json();
      setData(json);
    } catch (err) {
      if (err.name !== 'AbortError') {
        setError(err.message);
      }
    } finally {
      setLoading(false);
    }
  }
  
  fetchData();
  return () => controller.abort();
}, []);
```

### Custom Hooks

#### useFetch Hook

```javascript
function useFetch(url, options = {}) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const controller = new AbortController();
    
    async function fetchData() {
      try {
        setLoading(true);
        const res = await fetch(url, {
          ...options,
          signal: controller.signal
        });
        
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}: ${res.statusText}`);
        }
        
        const json = await res.json();
        setData(json);
        setError(null);
      } catch (err) {
        if (err.name !== 'AbortError') {
          setError(err);
        }
      } finally {
        if (!controller.signal.aborted) {
          setLoading(false);
        }
      }
    }
    
    fetchData();
    return () => controller.abort();
  }, [url, JSON.stringify(options)]);

  return { data, loading, error };
}
```

#### useFetch with Refetch

```javascript
function useFetch(url, options = {}) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [trigger, setTrigger] = useState(0);

  const refetch = useCallback(() => {
    setTrigger(prev => prev + 1);
  }, []);

  useEffect(() => {
    const controller = new AbortController();
    
    async function fetchData() {
      try {
        setLoading(true);
        const res = await fetch(url, {
          ...options,
          signal: controller.signal
        });
        
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        
        const json = await res.json();
        setData(json);
        setError(null);
      } catch (err) {
        if (err.name !== 'AbortError') {
          setError(err);
        }
      } finally {
        if (!controller.signal.aborted) {
          setLoading(false);
        }
      }
    }
    
    fetchData();
    return () => controller.abort();
  }, [url, trigger, JSON.stringify(options)]);

  return { data, loading, error, refetch };
}
```

#### useAsync for Manual Triggering

```javascript
function useAsync(asyncFunction) {
  const [state, setState] = useState({
    data: null,
    loading: false,
    error: null
  });

  const execute = useCallback(async (...params) => {
    setState({ data: null, loading: true, error: null });
    
    try {
      const data = await asyncFunction(...params);
      setState({ data, loading: false, error: null });
      return data;
    } catch (error) {
      setState({ data: null, loading: false, error });
      throw error;
    }
  }, [asyncFunction]);

  return { ...state, execute };
}

// Usage
function CreateUser() {
  const createUserFn = async (userData) => {
    const res = await fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData)
    });
    if (!res.ok) throw new Error('Failed to create user');
    return res.json();
  };

  const { data, loading, error, execute } = useAsync(createUserFn);

  const handleSubmit = (formData) => {
    execute(formData);
  };

  return (/* form UI */);
}
```

### State Management Patterns

#### useReducer for Complex State

```javascript
const fetchReducer = (state, action) => {
  switch (action.type) {
    case 'FETCH_INIT':
      return { ...state, loading: true, error: null };
    case 'FETCH_SUCCESS':
      return { 
        ...state, 
        loading: false, 
        error: null, 
        data: action.payload 
      };
    case 'FETCH_FAILURE':
      return { 
        ...state, 
        loading: false, 
        error: action.payload 
      };
    default:
      throw new Error(`Unhandled action: ${action.type}`);
  }
};

function useFetchReducer(url, options = {}) {
  const [state, dispatch] = useReducer(fetchReducer, {
    data: null,
    loading: true,
    error: null
  });

  useEffect(() => {
    const controller = new AbortController();
    
    async function fetchData() {
      dispatch({ type: 'FETCH_INIT' });
      
      try {
        const res = await fetch(url, {
          ...options,
          signal: controller.signal
        });
        
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        
        const data = await res.json();
        dispatch({ type: 'FETCH_SUCCESS', payload: data });
      } catch (err) {
        if (err.name !== 'AbortError') {
          dispatch({ type: 'FETCH_FAILURE', payload: err.message });
        }
      }
    }
    
    fetchData();
    return () => controller.abort();
  }, [url, JSON.stringify(options)]);

  return state;
}
```

#### Pagination State

```javascript
function usePaginatedFetch(baseUrl, pageSize = 10) {
  const [state, setState] = useState({
    data: [],
    page: 1,
    hasMore: true,
    loading: false,
    error: null
  });

  const fetchPage = useCallback(async (page) => {
    setState(prev => ({ ...prev, loading: true, error: null }));
    
    try {
      const res = await fetch(`${baseUrl}?page=${page}&limit=${pageSize}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      
      const newData = await res.json();
      
      setState(prev => ({
        ...prev,
        data: page === 1 ? newData : [...prev.data, ...newData],
        page,
        hasMore: newData.length === pageSize,
        loading: false
      }));
    } catch (err) {
      setState(prev => ({ ...prev, error: err.message, loading: false }));
    }
  }, [baseUrl, pageSize]);

  const loadMore = useCallback(() => {
    if (!state.loading && state.hasMore) {
      fetchPage(state.page + 1);
    }
  }, [state.loading, state.hasMore, state.page, fetchPage]);

  const reset = useCallback(() => {
    fetchPage(1);
  }, [fetchPage]);

  useEffect(() => {
    fetchPage(1);
  }, [fetchPage]);

  return { ...state, loadMore, reset };
}
```

### Caching Patterns

#### Simple Cache with useRef

```javascript
function useFetchWithCache(url, options = {}) {
  const cache = useRef({});
  const [state, setState] = useState({
    data: null,
    loading: true,
    error: null
  });

  useEffect(() => {
    const cacheKey = `${url}-${JSON.stringify(options)}`;
    
    if (cache.current[cacheKey]) {
      setState({
        data: cache.current[cacheKey],
        loading: false,
        error: null
      });
      return;
    }

    const controller = new AbortController();
    
    async function fetchData() {
      try {
        setState(prev => ({ ...prev, loading: true }));
        
        const res = await fetch(url, {
          ...options,
          signal: controller.signal
        });
        
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        
        const data = await res.json();
        cache.current[cacheKey] = data;
        
        setState({ data, loading: false, error: null });
      } catch (err) {
        if (err.name !== 'AbortError') {
          setState({ data: null, loading: false, error: err.message });
        }
      }
    }
    
    fetchData();
    return () => controller.abort();
  }, [url, JSON.stringify(options)]);

  return state;
}
```

#### Time-based Cache Invalidation

```javascript
function useFetchWithTTL(url, ttl = 60000, options = {}) {
  const cache = useRef(new Map());
  const [state, setState] = useState({
    data: null,
    loading: true,
    error: null
  });

  useEffect(() => {
    const cacheKey = `${url}-${JSON.stringify(options)}`;
    const cached = cache.current.get(cacheKey);
    
    if (cached && Date.now() - cached.timestamp < ttl) {
      setState({
        data: cached.data,
        loading: false,
        error: null
      });
      return;
    }

    const controller = new AbortController();
    
    async function fetchData() {
      try {
        setState(prev => ({ ...prev, loading: true }));
        
        const res = await fetch(url, {
          ...options,
          signal: controller.signal
        });
        
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        
        const data = await res.json();
        
        cache.current.set(cacheKey, {
          data,
          timestamp: Date.now()
        });
        
        setState({ data, loading: false, error: null });
      } catch (err) {
        if (err.name !== 'AbortError') {
          setState({ data: null, loading: false, error: err.message });
        }
      }
    }
    
    fetchData();
    return () => controller.abort();
  }, [url, ttl, JSON.stringify(options)]);

  return state;
}
```

### Optimistic Updates

#### Mutation with Rollback

```javascript
function useOptimisticMutation(url, options = {}) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const previousData = useRef(null);

  const mutate = useCallback(async (newData, optimisticData) => {
    previousData.current = data;
    setData(optimisticData);
    setLoading(true);
    setError(null);

    try {
      const res = await fetch(url, {
        ...options,
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newData)
      });

      if (!res.ok) throw new Error(`HTTP ${res.status}`);

      const result = await res.json();
      setData(result);
      return result;
    } catch (err) {
      setData(previousData.current);
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [url, data, JSON.stringify(options)]);

  return { data, loading, error, mutate };
}

// Usage
function TodoList() {
  const { data: todos, mutate } = useOptimisticMutation('/api/todos');

  const addTodo = async (text) => {
    const newTodo = { id: Date.now(), text, completed: false };
    const optimisticTodos = [...(todos || []), newTodo];
    
    await mutate({ text }, optimisticTodos);
  };

  return (/* UI */);
}
```

### Parallel and Sequential Requests

#### Parallel Fetching

```javascript
function useParallelFetch(urls) {
  const [state, setState] = useState({
    data: [],
    loading: true,
    error: null
  });

  useEffect(() => {
    const controllers = urls.map(() => new AbortController());
    
    async function fetchAll() {
      try {
        setState(prev => ({ ...prev, loading: true }));
        
        const promises = urls.map((url, index) =>
          fetch(url, { signal: controllers[index].signal })
            .then(res => {
              if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
              return res.json();
            })
        );
        
        const results = await Promise.all(promises);
        setState({ data: results, loading: false, error: null });
      } catch (err) {
        if (err.name !== 'AbortError') {
          setState({ data: [], loading: false, error: err.message });
        }
      }
    }
    
    fetchAll();
    return () => controllers.forEach(c => c.abort());
  }, [JSON.stringify(urls)]);

  return state;
}
```

#### Sequential Dependencies

```javascript
function useSequentialFetch(getUserUrl, getPostsUrl) {
  const [state, setState] = useState({
    user: null,
    posts: null,
    loading: true,
    error: null
  });

  useEffect(() => {
    const controller = new AbortController();
    
    async function fetchSequential() {
      try {
        setState(prev => ({ ...prev, loading: true }));
        
        const userRes = await fetch(getUserUrl, { signal: controller.signal });
        if (!userRes.ok) throw new Error('Failed to fetch user');
        const user = await userRes.json();
        
        const postsRes = await fetch(getPostsUrl(user.id), { 
          signal: controller.signal 
        });
        if (!postsRes.ok) throw new Error('Failed to fetch posts');
        const posts = await postsRes.json();
        
        setState({ user, posts, loading: false, error: null });
      } catch (err) {
        if (err.name !== 'AbortError') {
          setState(prev => ({ 
            ...prev, 
            loading: false, 
            error: err.message 
          }));
        }
      }
    }
    
    fetchSequential();
    return () => controller.abort();
  }, [getUserUrl, getPostsUrl]);

  return state;
}
```

### Debouncing and Throttling

#### Debounced Search

```javascript
function useDebouncedFetch(url, delay = 500) {
  const [query, setQuery] = useState('');
  const [debouncedQuery, setDebouncedQuery] = useState('');
  const [state, setState] = useState({
    data: null,
    loading: false,
    error: null
  });

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedQuery(query);
    }, delay);

    return () => clearTimeout(timer);
  }, [query, delay]);

  useEffect(() => {
    if (!debouncedQuery) {
      setState({ data: null, loading: false, error: null });
      return;
    }

    const controller = new AbortController();
    
    async function search() {
      try {
        setState(prev => ({ ...prev, loading: true }));
        
        const res = await fetch(`${url}?q=${debouncedQuery}`, {
          signal: controller.signal
        });
        
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        
        const data = await res.json();
        setState({ data, loading: false, error: null });
      } catch (err) {
        if (err.name !== 'AbortError') {
          setState({ data: null, loading: false, error: err.message });
        }
      }
    }
    
    search();
    return () => controller.abort();
  }, [debouncedQuery, url]);

  return { ...state, query, setQuery };
}
```

### Polling

#### Interval-based Polling

```javascript
function usePolling(url, interval = 5000, options = {}) {
  const [state, setState] = useState({
    data: null,
    loading: true,
    error: null
  });
  const [isPolling, setIsPolling] = useState(true);

  useEffect(() => {
    if (!isPolling) return;

    const controller = new AbortController();
    
    async function fetchData() {
      try {
        const res = await fetch(url, {
          ...options,
          signal: controller.signal
        });
        
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        
        const data = await res.json();
        setState({ data, loading: false, error: null });
      } catch (err) {
        if (err.name !== 'AbortError') {
          setState(prev => ({ ...prev, error: err.message, loading: false }));
        }
      }
    }
    
    fetchData();
    const timer = setInterval(fetchData, interval);

    return () => {
      controller.abort();
      clearInterval(timer);
    };
  }, [url, interval, isPolling, JSON.stringify(options)]);

  return { ...state, isPolling, setIsPolling };
}
```

#### Conditional Polling

```javascript
function useConditionalPolling(url, shouldPoll, interval = 3000) {
  const [state, setState] = useState({
    data: null,
    loading: true,
    error: null
  });

  useEffect(() => {
    if (!shouldPoll(state.data)) return;

    const controller = new AbortController();
    
    async function fetchData() {
      try {
        const res = await fetch(url, { signal: controller.signal });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        
        const data = await res.json();
        setState({ data, loading: false, error: null });
      } catch (err) {
        if (err.name !== 'AbortError') {
          setState(prev => ({ ...prev, error: err.message, loading: false }));
        }
      }
    }
    
    fetchData();
    const timer = setInterval(fetchData, interval);

    return () => {
      controller.abort();
      clearInterval(timer);
    };
  }, [url, interval, shouldPoll, state.data]);

  return state;
}

// Usage: poll until job is complete
function JobStatus({ jobId }) {
  const shouldPoll = (data) => data?.status !== 'completed';
  const { data } = useConditionalPolling(
    `/api/jobs/${jobId}`,
    shouldPoll,
    2000
  );

  return <div>Status: {data?.status}</div>;
}
```

### Error Handling Patterns

#### Retry Logic

```javascript
function useFetchWithRetry(url, maxRetries = 3, retryDelay = 1000, options = {}) {
  const [state, setState] = useState({
    data: null,
    loading: true,
    error: null,
    retryCount: 0
  });

  useEffect(() => {
    const controller = new AbortController();
    let retryTimeout;
    
    async function fetchWithRetry(attempt = 0) {
      try {
        setState(prev => ({ 
          ...prev, 
          loading: true, 
          retryCount: attempt 
        }));
        
        const res = await fetch(url, {
          ...options,
          signal: controller.signal
        });
        
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        
        const data = await res.json();
        setState({ 
          data, 
          loading: false, 
          error: null, 
          retryCount: attempt 
        });
      } catch (err) {
        if (err.name === 'AbortError') return;
        
        if (attempt < maxRetries) {
          retryTimeout = setTimeout(() => {
            fetchWithRetry(attempt + 1);
          }, retryDelay * Math.pow(2, attempt)); // Exponential backoff
        } else {
          setState({ 
            data: null, 
            loading: false, 
            error: err.message, 
            retryCount: attempt 
          });
        }
      }
    }
    
    fetchWithRetry();
    
    return () => {
      controller.abort();
      clearTimeout(retryTimeout);
    };
  }, [url, maxRetries, retryDelay, JSON.stringify(options)]);

  return state;
}
```

#### Error Boundary Integration

```javascript
function useFetchWithErrorBoundary(url, options = {}) {
  const [state, setState] = useState({
    data: null,
    loading: true,
    error: null
  });

  useEffect(() => {
    const controller = new AbortController();
    
    async function fetchData() {
      try {
        setState(prev => ({ ...prev, loading: true }));
        
        const res = await fetch(url, {
          ...options,
          signal: controller.signal
        });
        
        if (!res.ok) {
          const error = new Error(`HTTP ${res.status}`);
          error.status = res.status;
          throw error;
        }
        
        const data = await res.json();
        setState({ data, loading: false, error: null });
      } catch (err) {
        if (err.name !== 'AbortError') {
          // Throw critical errors to Error Boundary
          if (err.status >= 500) {
            throw err;
          }
          // Handle client errors in component
          setState({ data: null, loading: false, error: err });
        }
      }
    }
    
    fetchData();
    return () => controller.abort();
  }, [url, JSON.stringify(options)]);

  return state;
}
```

### Authentication Patterns

#### Token Refresh

```javascript
function useFetchWithAuth(url, options = {}) {
  const [state, setState] = useState({
    data: null,
    loading: true,
    error: null
  });
  const tokenRef = useRef(null);

  const refreshToken = useCallback(async () => {
    const res = await fetch('/api/refresh-token', {
      method: 'POST',
      credentials: 'include'
    });
    
    if (!res.ok) throw new Error('Token refresh failed');
    
    const { token } = await res.json();
    tokenRef.current = token;
    return token;
  }, []);

  const fetchWithAuth = useCallback(async (token) => {
    const res = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });

    if (res.status === 401) {
      const newToken = await refreshToken();
      return fetch(url, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${newToken}`
        }
      });
    }

    return res;
  }, [url, options, refreshToken]);

  useEffect(() => {
    const controller = new AbortController();
    
    async function fetchData() {
      try {
        setState(prev => ({ ...prev, loading: true }));
        
        const res = await fetchWithAuth(tokenRef.current);
        
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        
        const data = await res.json();
        setState({ data, loading: false, error: null });
      } catch (err) {
        if (err.name !== 'AbortError') {
          setState({ data: null, loading: false, error: err.message });
        }
      }
    }
    
    fetchData();
    return () => controller.abort();
  }, [fetchWithAuth]);

  return state;
}
```

### Suspense Integration

#### Resource Pattern for Suspense

```javascript
function wrapPromise(promise) {
  let status = 'pending';
  let result;
  
  const suspender = promise.then(
    (res) => {
      status = 'success';
      result = res;
    },
    (err) => {
      status = 'error';
      result = err;
    }
  );

  return {
    read() {
      if (status === 'pending') throw suspender;
      if (status === 'error') throw result;
      return result;
    }
  };
}

function fetchData(url) {
  const promise = fetch(url)
    .then(res => {
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json();
    });
  
  return wrapPromise(promise);
}

// Usage with Suspense
function DataComponent({ resource }) {
  const data = resource.read();
  return <div>{JSON.stringify(data)}</div>;
}

function App() {
  const resource = useMemo(() => fetchData('/api/data'), []);
  
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <DataComponent resource={resource} />
    </Suspense>
  );
}
```

### Request Deduplication

#### Preventing Duplicate Requests

```javascript
function useDeduplicatedFetch(url, options = {}) {
  const pendingRequests = useRef(new Map());
  const [state, setState] = useState({
    data: null,
    loading: true,
    error: null
  });

  useEffect(() => {
    const cacheKey = `${url}-${JSON.stringify(options)}`;
    
    if (pendingRequests.current.has(cacheKey)) {
      pendingRequests.current.get(cacheKey).then(
        data => setState({ data, loading: false, error: null }),
        err => setState({ data: null, loading: false, error: err.message })
      );
      return;
    }

    const controller = new AbortController();
    
    const promise = fetch(url, {
      ...options,
      signal: controller.signal
    })
      .then(res => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .finally(() => {
        pendingRequests.current.delete(cacheKey);
      });

    pendingRequests.current.set(cacheKey, promise);

    promise.then(
      data => setState({ data, loading: false, error: null }),
      err => {
        if (err.name !== 'AbortError') {
          setState({ data: null, loading: false, error: err.message });
        }
      }
    );

    return () => controller.abort();
  }, [url, JSON.stringify(options)]);

  return state;
}
```

### Context-based Request Management

#### Global Fetch Context

```javascript
const FetchContext = createContext(null);

function FetchProvider({ children, baseURL, defaultHeaders = {} }) {
  const pendingRequests = useRef(new Map());
  
  const fetcher = useCallback(async (endpoint, options = {}) => {
    const url = `${baseURL}${endpoint}`;
    const config = {
      ...options,
      headers: {
        ...defaultHeaders,
        ...options.headers
      }
    };
    
    const cacheKey = `${url}-${JSON.stringify(config)}`;
    
    if (pendingRequests.current.has(cacheKey)) {
      return pendingRequests.current.get(cacheKey);
    }
    
    const promise = fetch(url, config)
      .then(async res => {
        if (!res.ok) {
          const error = new Error(`HTTP ${res.status}`);
          error.response = res;
          throw error;
        }
        return res.json();
      })
      .finally(() => {
        pendingRequests.current.delete(cacheKey);
      });
    
    pendingRequests.current.set(cacheKey, promise);
    return promise;
  }, [baseURL, defaultHeaders]);

  return (
    <FetchContext.Provider value={fetcher}>
      {children}
    </FetchContext.Provider>
  );
}

function useFetchContext() {
  const fetcher = useContext(FetchContext);
  if (!fetcher) {
    throw new Error('useFetchContext must be used within FetchProvider');
  }
  return fetcher;
}

// Usage in component
function UserList() {
  const fetcher = useFetchContext();
  const [users, setUsers] = useState([]);
  
  useEffect(() => {
    fetcher('/users')
      .then(setUsers)
      .catch(console.error);
  }, [fetcher]);
  
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

---

