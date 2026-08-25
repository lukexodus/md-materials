## React Query Patterns


### Query Functions

#### Basic Query Function Structure

Query functions must return a Promise that resolves to data or throws an error:

```javascript
const fetchUser = async ({ queryKey }) => {
  const [_key, userId] = queryKey;
  const response = await fetch(`/api/users/${userId}`);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  return response.json();
};

function UserProfile({ userId }) {
  const { data, error, isLoading } = useQuery({
    queryKey: ['user', userId],
    queryFn: fetchUser
  });
}
```

#### Extracting Query Key Parameters

Access query key parameters through the `queryKey` array:

```javascript
const fetchPaginatedData = async ({ queryKey, pageParam = 1 }) => {
  const [_key, filters, sortBy] = queryKey;
  
  const params = new URLSearchParams({
    page: pageParam,
    sort: sortBy,
    ...filters
  });
  
  const response = await fetch(`/api/items?${params}`);
  if (!response.ok) throw new Error('Fetch failed');
  
  return response.json();
};

useQuery({
  queryKey: ['items', { status: 'active', category: 'books' }, 'createdAt'],
  queryFn: fetchPaginatedData
});
```

#### Signal Integration for Cancellation

React Query passes an `AbortSignal` to query functions:

```javascript
const fetchWithCancellation = async ({ queryKey, signal }) => {
  const [_key, id] = queryKey;
  
  const response = await fetch(`/api/resource/${id}`, { signal });
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  
  return response.json();
};

useQuery({
  queryKey: ['resource', id],
  queryFn: fetchWithCancellation
});
```

When a query is cancelled (component unmounts or query key changes), the fetch request aborts automatically.

#### Meta Information Access

Query functions receive metadata for advanced use cases:

```javascript
const fetchWithMeta = async ({ queryKey, signal, meta }) => {
  const [_key, id] = queryKey;
  
  const headers = {
    'Content-Type': 'application/json',
    ...(meta?.customHeaders || {})
  };
  
  const response = await fetch(`/api/data/${id}`, {
    signal,
    headers
  });
  
  if (!response.ok) throw new Error('Fetch failed');
  return response.json();
};

useQuery({
  queryKey: ['data', id],
  queryFn: fetchWithMeta,
  meta: {
    customHeaders: { 'X-Custom-Token': token }
  }
});
```

### Error Handling Patterns

#### Response Status Handling

Differentiate between network errors and HTTP errors:

```javascript
class HTTPError extends Error {
  constructor(response) {
    super(`HTTP Error: ${response.status}`);
    this.response = response;
    this.status = response.status;
  }
}

const fetchWithErrorHandling = async ({ queryKey }) => {
  const [_key, id] = queryKey;
  
  try {
    const response = await fetch(`/api/resource/${id}`);
    
    if (!response.ok) {
      throw new HTTPError(response);
    }
    
    return response.json();
  } catch (error) {
    if (error instanceof HTTPError) {
      // HTTP error (4xx, 5xx)
      throw error;
    }
    // Network error
    throw new Error(`Network error: ${error.message}`);
  }
};
```

#### Retry Logic Configuration

Configure retry behavior based on error types:

```javascript
useQuery({
  queryKey: ['resource', id],
  queryFn: fetchResource,
  retry: (failureCount, error) => {
    // Don't retry on 4xx errors
    if (error.status >= 400 && error.status < 500) {
      return false;
    }
    
    // Retry up to 3 times for 5xx or network errors
    return failureCount < 3;
  },
  retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000)
});
```

#### Error Boundary Integration

Handle errors at component boundaries:

```javascript
const fetchUser = async ({ queryKey, signal }) => {
  const [_key, userId] = queryKey;
  const response = await fetch(`/api/users/${userId}`, { signal });
  
  if (!response.ok) {
    const error = new Error('Failed to fetch user');
    error.status = response.status;
    error.info = await response.json().catch(() => ({}));
    throw error;
  }
  
  return response.json();
};

function UserComponent({ userId }) {
  const { data, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: fetchUser,
    useErrorBoundary: (error) => error.status >= 500
  });
  
  if (error && error.status < 500) {
    return <div>User not found</div>;
  }
  
  return <div>{data.name}</div>;
}
```

#### Global Error Handler

Configure default error handling:

```javascript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      queryFn: async ({ queryKey, signal }) => {
        const url = Array.isArray(queryKey) ? queryKey[0] : queryKey;
        const response = await fetch(url, { signal });
        
        if (!response.ok) {
          const error = new Error('Request failed');
          error.status = response.status;
          throw error;
        }
        
        return response.json();
      },
      onError: (error) => {
        console.error('Query error:', error);
        // Send to error tracking service
      }
    }
  }
});
```

### Mutations

#### Basic Mutation Pattern

Execute POST, PUT, DELETE requests:

```javascript
const createUser = async (userData) => {
  const response = await fetch('/api/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(userData)
  });
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  
  return response.json();
};

function CreateUserForm() {
  const mutation = useMutation({
    mutationFn: createUser,
    onSuccess: (data) => {
      console.log('User created:', data);
    },
    onError: (error) => {
      console.error('Creation failed:', error);
    }
  });
  
  const handleSubmit = (formData) => {
    mutation.mutate(formData);
  };
  
  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      handleSubmit(new FormData(e.target));
    }}>
      {mutation.isPending && <div>Creating...</div>}
      {mutation.isError && <div>Error: {mutation.error.message}</div>}
      {/* form fields */}
    </form>
  );
}
```

#### Optimistic Updates

Update UI immediately before server confirmation:

```javascript
const updateTodo = async ({ id, ...updates }) => {
  const response = await fetch(`/api/todos/${id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updates)
  });
  
  if (!response.ok) throw new Error('Update failed');
  return response.json();
};

function TodoItem({ todo }) {
  const queryClient = useQueryClient();
  
  const mutation = useMutation({
    mutationFn: updateTodo,
    onMutate: async (updatedTodo) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['todos'] });
      
      // Snapshot previous value
      const previousTodos = queryClient.getQueryData(['todos']);
      
      // Optimistically update
      queryClient.setQueryData(['todos'], (old) =>
        old.map((t) => t.id === updatedTodo.id ? { ...t, ...updatedTodo } : t)
      );
      
      return { previousTodos };
    },
    onError: (err, updatedTodo, context) => {
      // Rollback on error
      queryClient.setQueryData(['todos'], context.previousTodos);
    },
    onSettled: () => {
      // Refetch after error or success
      queryClient.invalidateQueries({ queryKey: ['todos'] });
    }
  });
  
  return (
    <div>
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={(e) => mutation.mutate({ id: todo.id, completed: e.target.checked })}
      />
    </div>
  );
}
```

#### Sequential Mutations

Chain dependent mutations:

```javascript
function MultiStepForm() {
  const queryClient = useQueryClient();
  
  const createUserMutation = useMutation({
    mutationFn: async (userData) => {
      const response = await fetch('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData)
      });
      if (!response.ok) throw new Error('User creation failed');
      return response.json();
    }
  });
  
  const uploadAvatarMutation = useMutation({
    mutationFn: async ({ userId, file }) => {
      const formData = new FormData();
      formData.append('avatar', file);
      
      const response = await fetch(`/api/users/${userId}/avatar`, {
        method: 'POST',
        body: formData
      });
      if (!response.ok) throw new Error('Avatar upload failed');
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    }
  });
  
  const handleSubmit = async (userData, avatarFile) => {
    try {
      const user = await createUserMutation.mutateAsync(userData);
      await uploadAvatarMutation.mutateAsync({ userId: user.id, file: avatarFile });
    } catch (error) {
      console.error('Form submission failed:', error);
    }
  };
}
```

#### Parallel Mutations

Execute multiple independent mutations:

```javascript
function BulkActions({ selectedIds }) {
  const queryClient = useQueryClient();
  
  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const response = await fetch(`/api/items/${id}`, { method: 'DELETE' });
      if (!response.ok) throw new Error(`Failed to delete ${id}`);
      return id;
    }
  });
  
  const handleBulkDelete = async () => {
    try {
      await Promise.all(
        selectedIds.map((id) => deleteMutation.mutateAsync(id))
      );
      queryClient.invalidateQueries({ queryKey: ['items'] });
    } catch (error) {
      console.error('Bulk delete failed:', error);
    }
  };
  
  return (
    <button 
      onClick={handleBulkDelete}
      disabled={deleteMutation.isPending}
    >
      Delete Selected ({selectedIds.length})
    </button>
  );
}
```

### Cache Invalidation Strategies

#### Selective Invalidation

Invalidate specific queries after mutations:

```javascript
const updateUserMutation = useMutation({
  mutationFn: async ({ userId, updates }) => {
    const response = await fetch(`/api/users/${userId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updates)
    });
    if (!response.ok) throw new Error('Update failed');
    return response.json();
  },
  onSuccess: (data, variables) => {
    // Invalidate specific user query
    queryClient.invalidateQueries({ queryKey: ['user', variables.userId] });
    
    // Invalidate user list
    queryClient.invalidateQueries({ queryKey: ['users'] });
  }
});
```

#### Exact vs Partial Matching

Control invalidation scope:

```javascript
// Invalidate exact match only
queryClient.invalidateQueries({
  queryKey: ['users', { status: 'active' }],
  exact: true
});

// Invalidate all queries starting with ['users']
queryClient.invalidateQueries({
  queryKey: ['users'],
  exact: false
});

// Predicate-based invalidation
queryClient.invalidateQueries({
  predicate: (query) => {
    return query.queryKey[0] === 'users' && 
           query.state.data?.length > 100;
  }
});
```

#### Manual Cache Updates

Directly update cache without invalidation:

```javascript
const createTodoMutation = useMutation({
  mutationFn: async (newTodo) => {
    const response = await fetch('/api/todos', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newTodo)
    });
    if (!response.ok) throw new Error('Creation failed');
    return response.json();
  },
  onSuccess: (createdTodo) => {
    // Add to existing cache
    queryClient.setQueryData(['todos'], (old) => [...old, createdTodo]);
    
    // Or update specific item
    queryClient.setQueryData(['todo', createdTodo.id], createdTodo);
  }
});
```

#### Time-Based Invalidation

Combine with stale time for automatic refetching:

```javascript
useQuery({
  queryKey: ['dashboard'],
  queryFn: fetchDashboard,
  staleTime: 5 * 60 * 1000, // 5 minutes
  refetchInterval: 5 * 60 * 1000, // Refetch every 5 minutes
  refetchIntervalInBackground: true
});

// Manual invalidation still works
const handleRefresh = () => {
  queryClient.invalidateQueries({ queryKey: ['dashboard'] });
};
```

### Prefetching Patterns

#### Route-Based Prefetching

Prefetch data for anticipated navigation:

```javascript
function UserList() {
  const queryClient = useQueryClient();
  const { data: users } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers
  });
  
  const handleHover = (userId) => {
    queryClient.prefetchQuery({
      queryKey: ['user', userId],
      queryFn: () => fetchUser({ queryKey: ['user', userId] }),
      staleTime: 10 * 1000 // Cache for 10 seconds
    });
  };
  
  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>
          <Link
            to={`/users/${user.id}`}
            onMouseEnter={() => handleHover(user.id)}
          >
            {user.name}
          </Link>
        </li>
      ))}
    </ul>
  );
}
```

#### Parallel Prefetching

Prefetch multiple related queries:

```javascript
function DashboardLoader() {
  const queryClient = useQueryClient();
  
  useEffect(() => {
    const prefetchDashboardData = async () => {
      await Promise.all([
        queryClient.prefetchQuery({
          queryKey: ['stats'],
          queryFn: fetchStats
        }),
        queryClient.prefetchQuery({
          queryKey: ['recentActivity'],
          queryFn: fetchRecentActivity
        }),
        queryClient.prefetchQuery({
          queryKey: ['notifications'],
          queryFn: fetchNotifications
        })
      ]);
    };
    
    prefetchDashboardData();
  }, [queryClient]);
  
  return <Outlet />;
}
```

#### Conditional Prefetching

Prefetch based on user behavior or permissions:

```javascript
function AdminPanel() {
  const queryClient = useQueryClient();
  const { data: user } = useQuery({ queryKey: ['currentUser'], queryFn: fetchCurrentUser });
  
  useEffect(() => {
    if (user?.role === 'admin') {
      queryClient.prefetchQuery({
        queryKey: ['adminStats'],
        queryFn: fetchAdminStats
      });
    }
  }, [user, queryClient]);
  
  return <div>{/* admin content */}</div>;
}
```

#### Infinite Query Prefetching

Prefetch next page of infinite queries:

```javascript
function InfiniteList() {
  const { data, fetchNextPage, hasNextPage } = useInfiniteQuery({
    queryKey: ['items'],
    queryFn: fetchItems,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
    initialPageParam: undefined
  });
  
  const lastItemRef = useCallback((node) => {
    if (node && hasNextPage) {
      // Prefetch next page when near bottom
      const observer = new IntersectionObserver((entries) => {
        if (entries[0].isIntersecting) {
          fetchNextPage();
        }
      }, { rootMargin: '100px' });
      
      observer.observe(node);
      return () => observer.disconnect();
    }
  }, [hasNextPage, fetchNextPage]);
  
  return (
    <div>
      {data?.pages.map((page) =>
        page.items.map((item, i) => {
          const isLast = i === page.items.length - 1;
          return (
            <div key={item.id} ref={isLast ? lastItemRef : null}>
              {item.name}
            </div>
          );
        })
      )}
    </div>
  );
}
```

### Infinite Queries

#### Basic Infinite Query Structure

Fetch paginated data with cursor-based pagination:

```javascript
const fetchProjects = async ({ pageParam = 1 }) => {
  const response = await fetch(`/api/projects?cursor=${pageParam}&limit=20`);
  if (!response.ok) throw new Error('Fetch failed');
  
  const data = await response.json();
  return {
    items: data.projects,
    nextCursor: data.nextCursor,
    hasMore: data.hasMore
  };
};

function ProjectList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    status
  } = useInfiniteQuery({
    queryKey: ['projects'],
    queryFn: fetchProjects,
    getNextPageParam: (lastPage) => lastPage.hasMore ? lastPage.nextCursor : undefined,
    initialPageParam: 1
  });
  
  return (
    <div>
      {data?.pages.map((page) =>
        page.items.map((project) => (
          <div key={project.id}>{project.name}</div>
        ))
      )}
      
      {hasNextPage && (
        <button onClick={() => fetchNextPage()} disabled={isFetchingNextPage}>
          {isFetchingNextPage ? 'Loading...' : 'Load More'}
        </button>
      )}
    </div>
  );
}
```

#### Bidirectional Infinite Queries

Support both forward and backward pagination:

```javascript
const fetchMessages = async ({ pageParam = { cursor: null, direction: 'forward' } }) => {
  const { cursor, direction } = pageParam;
  const endpoint = cursor
    ? `/api/messages?cursor=${cursor}&direction=${direction}`
    : '/api/messages';
  
  const response = await fetch(endpoint);
  if (!response.ok) throw new Error('Fetch failed');
  
  const data = await response.json();
  return {
    messages: data.messages,
    nextCursor: data.nextCursor,
    previousCursor: data.previousCursor
  };
};

function MessageThread() {
  const {
    data,
    fetchNextPage,
    fetchPreviousPage,
    hasNextPage,
    hasPreviousPage
  } = useInfiniteQuery({
    queryKey: ['messages', threadId],
    queryFn: fetchMessages,
    getNextPageParam: (lastPage) => 
      lastPage.nextCursor ? { cursor: lastPage.nextCursor, direction: 'forward' } : undefined,
    getPreviousPageParam: (firstPage) =>
      firstPage.previousCursor ? { cursor: firstPage.previousCursor, direction: 'backward' } : undefined,
    initialPageParam: { cursor: null, direction: 'forward' }
  });
  
  return (
    <div>
      {hasPreviousPage && (
        <button onClick={() => fetchPreviousPage()}>Load Earlier</button>
      )}
      
      {data?.pages.map((page) =>
        page.messages.map((msg) => <Message key={msg.id} message={msg} />)
      )}
      
      {hasNextPage && (
        <button onClick={() => fetchNextPage()}>Load More</button>
      )}
    </div>
  );
}
```

#### Infinite Query with Search/Filters

Reset and refetch when filters change:

```javascript
function FilteredProductList() {
  const [filters, setFilters] = useState({ category: 'all', minPrice: 0 });
  
  const {
    data,
    fetchNextPage,
    hasNextPage,
    refetch
  } = useInfiniteQuery({
    queryKey: ['products', filters],
    queryFn: async ({ pageParam = 1 }) => {
      const params = new URLSearchParams({
        page: pageParam,
        category: filters.category,
        minPrice: filters.minPrice
      });
      
      const response = await fetch(`/api/products?${params}`);
      if (!response.ok) throw new Error('Fetch failed');
      
      const data = await response.json();
      return {
        products: data.products,
        nextPage: data.nextPage
      };
    },
    getNextPageParam: (lastPage) => lastPage.nextPage,
    initialPageParam: 1
  });
  
  // Filters change triggers automatic refetch due to queryKey change
  const handleFilterChange = (newFilters) => {
    setFilters(newFilters);
  };
  
  return (
    <div>
      <FilterControls filters={filters} onChange={handleFilterChange} />
      {data?.pages.map((page) =>
        page.products.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))
      )}
    </div>
  );
}
```

#### Infinite Query Mutations

Update infinite query cache after mutations:

```javascript
function InfiniteTaskList() {
  const queryClient = useQueryClient();
  
  const { data } = useInfiniteQuery({
    queryKey: ['tasks'],
    queryFn: fetchTasks,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
    initialPageParam: undefined
  });
  
  const createTaskMutation = useMutation({
    mutationFn: async (newTask) => {
      const response = await fetch('/api/tasks', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newTask)
      });
      if (!response.ok) throw new Error('Creation failed');
      return response.json();
    },
    onSuccess: (createdTask) => {
      queryClient.setQueryData(['tasks'], (old) => {
        if (!old) return old;
        
        return {
          ...old,
          pages: old.pages.map((page, i) => 
            i === 0
              ? { ...page, items: [createdTask, ...page.items] }
              : page
          )
        };
      });
    }
  });
  
  const deleteTaskMutation = useMutation({
    mutationFn: async (taskId) => {
      const response = await fetch(`/api/tasks/${taskId}`, { method: 'DELETE' });
      if (!response.ok) throw new Error('Deletion failed');
      return taskId;
    },
    onSuccess: (deletedId) => {
      queryClient.setQueryData(['tasks'], (old) => {
        if (!old) return old;
        
        return {
          ...old,
          pages: old.pages.map((page) => ({
            ...page,
            items: page.items.filter((task) => task.id !== deletedId)
          }))
        };
      });
    }
  });
}
```

### Dependent Queries

#### Serial Query Execution

Execute queries in sequence when data dependencies exist:

```javascript
function UserPosts({ userId }) {
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: async ({ queryKey }) => {
      const [_key, id] = queryKey;
      const response = await fetch(`/api/users/${id}`);
      if (!response.ok) throw new Error('User fetch failed');
      return response.json();
    }
  });
  
  const { data: posts } = useQuery({
    queryKey: ['posts', user?.id],
    queryFn: async ({ queryKey }) => {
      const [_key, authorId] = queryKey;
      const response = await fetch(`/api/posts?authorId=${authorId}`);
      if (!response.ok) throw new Error('Posts fetch failed');
      return response.json();
    },
    enabled: !!user
  });
  
  if (!user) return <div>Loading user...</div>;
  if (!posts) return <div>Loading posts...</div>;
  
  return (
    <div>
      <h1>{user.name}'s Posts</h1>
      {posts.map((post) => <Post key={post.id} post={post} />)}
    </div>
  );
}
```

#### Conditional Query Execution

Enable queries based on complex conditions:

```javascript
function ConditionalData({ mode, filters }) {
  const shouldFetchAnalytics = mode === 'analytics' && filters.dateRange;
  
  const { data: analyticsData } = useQuery({
    queryKey: ['analytics', filters.dateRange],
    queryFn: async ({ queryKey }) => {
      const [_key, dateRange] = queryKey;
      const response = await fetch(`/api/analytics?start=${dateRange.start}&end=${dateRange.end}`);
      if (!response.ok) throw new Error('Analytics fetch failed');
      return response.json();
    },
    enabled: shouldFetchAnalytics,
    staleTime: 10 * 60 * 1000
  });
  
  return shouldFetchAnalytics ? (
    <AnalyticsView data={analyticsData} />
  ) : (
    <StandardView />
  );
}
```

#### Multiple Dependent Queries

Chain multiple dependent fetches:

```javascript
function TeamProjectDashboard({ teamId }) {
  const { data: team } = useQuery({
    queryKey: ['team', teamId],
    queryFn: fetchTeam
  });
  
  const { data: projects } = useQuery({
    queryKey: ['projects', team?.id],
    queryFn: async ({ queryKey }) => {
      const [_key, id] = queryKey;
      const response = await fetch(`/api/teams/${id}/projects`);
      if (!response.ok) throw new Error('Projects fetch failed');
      return response.json();
    },
    enabled: !!team
  });
  
  const { data: metrics } = useQuery({
    queryKey: ['metrics', projects?.map(p => p.id)],
    queryFn: async ({ queryKey }) => {
      const [_key, projectIds] = queryKey;
      const response = await fetch('/api/metrics', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ projectIds })
      });
      if (!response.ok) throw new Error('Metrics fetch failed');
      return response.json();
    },
    enabled: !!projects && projects.length > 0
  });
  
  if (!team) return <Loading />;
  if (!projects) return <Loading />;
  
  return <Dashboard team={team} projects={projects} metrics={metrics} />;
}
```

### Parallel Queries

#### Multiple Independent Queries

Fetch unrelated data simultaneously:

```javascript
function Dashboard() {
  const userQuery = useQuery({
    queryKey: ['currentUser'],
    queryFn: async () => {
      const response = await fetch('/api/user/current');
      if (!response.ok) throw new Error('User fetch failed');
      return response.json();
    }
  });
  
  const statsQuery = useQuery({
    queryKey: ['stats'],
    queryFn: async () => {
      const response = await fetch('/api/stats');
      if (!response.ok) throw new Error('Stats fetch failed');
      return response.json();
    }
  });
  
  const notificationsQuery = useQuery({
    queryKey: ['notifications'],
    queryFn: async () => {
      const response = await fetch('/api/notifications');
      if (!response.ok) throw new Error('Notifications fetch failed');
      return response.json();
    }
  });
  
  const isLoading = userQuery.isLoading || statsQuery.isLoading || notificationsQuery.isLoading;
  
  if (isLoading) return <Loading />;
  
  return (
    <div>
      <UserInfo user={userQuery.data} />
      <Stats data={statsQuery.data} />
      <Notifications items={notificationsQuery.data} />
    </div>
  );
}
```

#### useQueries for Dynamic Parallel Queries

Fetch variable number of queries:

```javascript
function MultiUserProfiles({ userIds }) {
  const userQueries = useQueries({
    queries: userIds.map((id) => ({
      queryKey: ['user', id],
      queryFn: async () => {
        const response = await fetch(`/api/users/${id}`);
        if (!response.ok) throw new Error(`User ${id} fetch failed`);
        return response.json();
      },
      staleTime: 5 * 60 * 1000
    }))
  });
  
  const allLoading = userQueries.some((q) => q.isLoading);
  const anyError = userQueries.some((q) => q.isError);
  
  if (allLoading) return <Loading />;
  if (anyError) return <Error />;
  
  return (
    <div>
      {userQueries.map((query, i) => (
        <UserCard key={userIds[i]} user={query.data} />
      ))}
    </div>
  );
}
```

#### Combining Parallel and Dependent Queries

Mix independent and dependent query patterns:

```javascript
function ComplexDashboard({ organizationId }) {
  // Independent queries that can run immediately
  const settingsQuery = useQuery({
    queryKey: ['settings'],
    queryFn: fetchSettings
  });
  
  const userQuery = useQuery({
    queryKey: ['currentUser'],
    queryFn: fetchCurrentUser
  });
  
  // Dependent on organizationId
  const orgQuery = useQuery({
    queryKey: ['organization', organizationId],
    queryFn: async ({ queryKey }) => {
      const [_key, id] = queryKey;
      const response = await fetch(`/api/organizations/${id}`);
      if (!response.ok) throw new Error('Org fetch failed');
      return response.json();
    }
  });
  
  // Dependent on organization data
  const teamsQuery = useQuery({
    queryKey: ['teams', orgQuery.data?.id],
    queryFn: async ({ queryKey }) => {
      const [_key, orgId] = queryKey;
      const response = await fetch(`/api/organizations/${orgId}/teams`);
      if (!response.ok) throw new Error('Teams fetch failed');
      return response.json();
    },
    enabled: !!orgQuery.data
  });
  
  return (
    <div>
      <Settings data={settingsQuery.data} />
      <UserProfile user={userQuery.data} />
      <Organization org={orgQuery.data} teams={teamsQuery.data} />
    </div>
  );
}
```

### Background Refetching

#### Automatic Background Updates

Refetch stale data when window regains focus:

```javascript
useQuery({
  queryKey: ['liveData'],
  queryFn: async () => {
    const response = await fetch('/api/live-data');
    if (!response.ok) throw new Error('Fetch failed');
    return response.json();
  },
  staleTime: 30 * 1000, // Consider stale after 30s
  refetchOnWindowFocus: true,
  refetchOnReconnect: true
});
```

#### Polling Pattern

Continuously refetch at intervals:

```javascript
function LiveScoreboard() {
  const { data } = useQuery({
    queryKey: ['scores'],
    queryFn: async () => {
      const response = await fetch('/api/scores/live');
      if (!response.ok) throw new Error('Fetch failed');
      return response.json();
    },
    refetchInterval: 5000, // Poll every 5 seconds
    refetchIntervalInBackground: true
  });
  
  return <Scoreboard scores={data} />;
}
```

#### Adaptive Polling

Adjust polling frequency based on conditions:

```javascript
function AdaptivePolling({ matchId, isLive }) {
  const { data } = useQuery({
    queryKey: ['match', matchId],
    queryFn: async ({ queryKey }) => {
      const [_key, id] = queryKey;
      const response = await fetch(`/api/matches/${id}`);
      if (!response.ok) throw new Error('Fetch failed');
      return response.json();
    },
    refetchInterval: (data) => {
      if (!isLive) return false; // Stop polling
      if (data?.status === 'critical') return 2000; // 2s for critical
      return 10000; // 10s normally
    }
  });
  
  return <MatchDetails match={data} />;
}
```

#### Manual Refetch Control

Trigger refetches programmatically:

```javascript
function DataView() {
  const { data, refetch, isFetching } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
    staleTime: Infinity, // Never auto-refetch
    refetchOnWindowFocus: false
  });
  
  return (
    <div>
      <button onClick={() => refetch()} disabled={isFetching}>
        {isFetching ? 'Refreshing...' : 'Refresh'}
      </button>
      <DataDisplay data={data} />
    </div>
  );
}
```

### Authentication Integration

#### Token Injection

Add authentication headers to all requests:

```javascript
const createAuthenticatedFetcher = (getToken) => {
  return async ({ queryKey, signal }) => {
    const token = await getToken();
    const [url] = queryKey;
    
    const response = await fetch(url, {
      signal,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      if (response.status === 401) {
        throw new Error('Unauthorized');
      }
      throw new Error(`HTTP ${response.status}`);
    }
    
    return response.json();
  };
};

function App() {
  const { getAccessToken } = useAuth();
  
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        queryFn: createAuthenticatedFetcher(getAccessToken)
      }
    }
  });
  
  return (
    <QueryClientProvider client={queryClient}>
      <AppContent />
    </QueryClientProvider>
  );
}
```

#### Token Refresh on 401

Automatically refresh expired tokens:

```javascript
const fetchWithTokenRefresh = async ({ queryKey, signal }, getToken, refreshToken) => {
  const [url] = queryKey;
  
  const makeRequest = async (token) => {
    const response = await fetch(url, {
      signal,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    return response;
  };
  
  let token = await getToken();
  let response = await makeRequest(token);
  
  if (response.status === 401) {
    // Token expired, refresh and retry
    token = await refreshToken();
    response = await makeRequest(token);
  }
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  
  return response.json();
};
```

#### Clearing Queries on Logout

Invalidate all cached data when user logs out:

```javascript
function useLogout() {
  const queryClient = useQueryClient();
  const { logout } = useAuth();
  
  return async () => {
    await logout();
    queryClient.clear(); // Remove all cached queries
  };
}
```

#### Protected Query Access

Prevent queries from executing without authentication:

```javascript
function ProtectedData() {
  const { isAuthenticated, token } = useAuth();
  
  const { data } = useQuery({
    queryKey: ['protectedData'],
    queryFn: async ({ signal }) => {
      const response = await fetch('/api/protected', {
        signal,
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (!response.ok) throw new Error('Fetch failed');
      return response.json();
    },
    enabled: isAuthenticated && !!token
  });
  
  if (!isAuthenticated) return <Login />;
  
  return <DataDisplay data={data} />;
}
```

### Request Deduplication

#### Automatic Deduplication

React Query deduplicates identical concurrent requests:

```javascript
// Both components mount simultaneously
function ComponentA() {
  useQuery({ queryKey: ['user', 1], queryFn: fetchUser });
}

function ComponentB() {
  useQuery({ queryKey: ['user', 1], queryFn: fetchUser });
}

// Only one network request is made
```

**[Inference]** React Query identifies identical queries by comparing queryKey arrays; matching keys result in request sharing.

#### Manual Request Batching

Batch multiple requests into single fetch:

```javascript
// Collect requests over time window
const requestBatcher = (() => {
  let batch = [];
  let timeoutId = null;
  
  return (id) => {
    return new Promise((resolve, reject) => {
      batch.push({ id, resolve, reject });
      
      if (timeoutId) clearTimeout(timeoutId);
      
      timeoutId = setTimeout(async () => {
        const currentBatch = batch;
        batch = [];
        
        try {
          const ids = currentBatch.map(item => item.id);
          const response = await fetch('/api/users/batch', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ ids })
          });
          
          if (!response.ok) throw new Error('Batch fetch failed');
          
          const results = await response.json();
          currentBatch.forEach(({ id, resolve }) => {
            resolve(results[id]);
          });
        } catch (error) {
          currentBatch.forEach(({ reject }) => reject(error));
        }
      }, 10); // 10ms batching window
    });
  };
})();

function UserProfile({ userId }) {
  const { data } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => requestBatcher(userId)
  });
}
```

### Suspense Integration

#### Query Suspense Mode

Use React Suspense for loading states:

```javascript
function UserProfile({ userId }) {
  const { data } = useSuspenseQuery({
    queryKey: ['user', userId],
    queryFn: async ({ queryKey }) => {
      const [_key, id] = queryKey;
      const response = await fetch(`/api/users/${id}`);
      if (!response.ok) throw new Error('Fetch failed');
      return response.json();
    }
  });
  
  // No loading state needed - Suspense boundary handles it
  return <div>{data.name}</div>;
}

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <UserProfile userId={1} />
    </Suspense>
  );
}
```

#### Multiple Suspense Queries

Coordinate multiple suspending queries:

```javascript
function Dashboard() {
  const { data: user } = useSuspenseQuery({
    queryKey: ['user'],
    queryFn: fetchUser
  });
  
  const { data: stats } = useSuspenseQuery({
    queryKey: ['stats'],
    queryFn: fetchStats
  });
  
  // Both queries must resolve before rendering
  return (
    <div>
      <UserInfo user={user} />
      <Stats data={stats} />
    </div>
  );
}

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Dashboard />
    </Suspense>
  );
}
```

#### Nested Suspense Boundaries

Progressive loading with multiple boundaries:

```javascript
function App() {
  return (
    <Suspense fallback={<PageLoading />}>
      <Header />
      
      <Suspense fallback={<ContentLoading />}>
        <MainContent />
        
        <Suspense fallback={<SidebarLoading />}>
          <Sidebar />
        </Suspense>
      </Suspense>
    </Suspense>
  );
}
```

### Server State Synchronization

#### Real-Time Updates via WebSocket

Synchronize query cache with server-sent events:

```javascript
function useWebSocketSync() {
  const queryClient = useQueryClient();
  
  useEffect(() => {
    const ws = new WebSocket('wss://api.example.com/updates');
    
    ws.onmessage = (event) => {
      const update = JSON.parse(event.data);
      
      switch (update.type) {
        case 'USER_UPDATED':
          queryClient.invalidateQueries({ queryKey: ['user', update.userId] });
          break;
        
        case 'ITEM_CREATED':
          queryClient.setQueryData(['items'], (old) => [update.item, ...old]);
          break;
        
        case 'ITEM_DELETED':
          queryClient.setQueryData(['items'], (old) =>
            old.filter(item => item.id !== update.itemId)
          );
          break;
      }
    };
    
    return () => ws.close();
  }, [queryClient]);
}
```

#### Server-Sent Events Integration

Stream updates from server:

```javascript
function useServerEvents(endpoint) {
  const queryClient = useQueryClient();
  
  useEffect(() => {
    const eventSource = new EventSource(endpoint);
    
    eventSource.addEventListener('update', (event) => {
      const data = JSON.parse(event.data);
      queryClient.setQueryData(['liveData'], data);
    });
    
    eventSource.addEventListener('invalidate', (event) => {
      const { queryKey } = JSON.parse(event.data);
      queryClient.invalidateQueries({ queryKey });
    });
    
    return () => eventSource.close();
  }, [endpoint, queryClient]);
}
```

#### Optimistic Concurrency Control

Handle conflicts with ETags or version numbers:

```javascript
const updateWithOCC = async ({ id, version, updates }) => {
  const response = await fetch(`/api/items/${id}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'If-Match': version
    },
    body: JSON.stringify(updates)
  });
  
  if (response.status === 412) {
    // Precondition failed - version conflict
    throw new Error('Version conflict');
  }
  
  if (!response.ok) {
    throw new Error('Update failed');
  }
  
  return response.json();
};

function EditableItem({ item }) {
  const queryClient = useQueryClient();
  
  const mutation = useMutation({
    mutationFn: updateWithOCC,
    onError: (error) => {
      if (error.message === 'Version conflict') {
        // Refetch latest version
        queryClient.invalidateQueries({ queryKey: ['item', item.id] });
      }
    },
    onSuccess: (updated) => {
      queryClient.setQueryData(['item', item.id], updated);
    }
  });
  
  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      mutation.mutate({
        id: item.id,
        version: item.version,
        updates: formData
      });
    }}>
      {/* form fields */}
    </form>
  );
}
```

### Performance Optimization

#### Structural Sharing

React Query automatically shares unchanged data structures:

```javascript
// Large data structure
const { data: largeList } = useQuery({
  queryKey: ['items'],
  queryFn: fetchItems,
  structuralSharing: true // Default behavior
});

// When refetching, unchanged objects maintain referential equality
// This prevents unnecessary re-renders in child components
```

**[Inference]** Structural sharing compares nested objects to preserve references for unchanged data, reducing re-render frequency.

#### Select Transform

Transform query data without affecting cache:

```javascript
function UserNames() {
  const { data: names } = useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const response = await fetch('/api/users');
      if (!response.ok) throw new Error('Fetch failed');
      return response.json();
    },
    select: (users) => users.map((user) => user.name)
  });
  
  // Only re-renders when names change, not when other user properties change
  return <div>{names.join(', ')}</div>;
}
```

#### Placeholder Data

Show stale data while refetching:

```javascript
function UserProfile({ userId }) {
  const queryClient = useQueryClient();
  
  const { data } = useQuery({
    queryKey: ['user', userId],
    queryFn: fetchUser,
    placeholderData: () => {
      // Use data from user list if available
      const usersData = queryClient.getQueryData(['users']);
      return usersData?.find((user) => user.id === userId);
    }
  });
  
  return <div>{data?.name}</div>;
}
```

#### Initial Data from Cache

Seed new queries with existing cache data:

```javascript
function UserDetails({ userId }) {
  const queryClient = useQueryClient();
  
  const { data } = useQuery({
    queryKey: ['user', userId],
    queryFn: fetchUser,
    initialData: () => {
      const usersData = queryClient.getQueryData(['users']);
      return usersData?.find((user) => user.id === userId);
    },
    initialDataUpdatedAt: () => {
      const queryState = queryClient.getQueryState(['users']);
      return queryState?.dataUpdatedAt;
    }
  });
}
```

#### Query Key Factories

Centralize and type-safe query keys:

```javascript
const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id) => [...userKeys.details(), id] as const
};

// Usage
useQuery({
  queryKey: userKeys.detail(userId),
  queryFn: fetchUser
});

// Invalidate all user queries
queryClient.invalidateQueries({ queryKey: userKeys.all });

// Invalidate user lists only
queryClient.invalidateQueries({ queryKey: userKeys.lists() });
```

#### Garbage Collection Configuration

Control when inactive queries are removed from cache:

```javascript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      cacheTime: 5 * 60 * 1000, // 5 minutes
      staleTime: 30 * 1000, // 30 seconds
      gcTime: 10 * 60 * 1000 // Garbage collect after 10 minutes (v5+)
    }
  }
});

// Per-query override
useQuery({
  queryKey: ['temporary-data'],
  queryFn: fetchData,
  cacheTime: 0 // Remove immediately when unused
});
```

---

