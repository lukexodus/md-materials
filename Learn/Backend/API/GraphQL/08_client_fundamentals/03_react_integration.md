## React Integration


### Apollo Client with React hooks

Apollo Client provides a comprehensive GraphQL client with React hooks that seamlessly integrate GraphQL operations into React components. The hooks-based approach offers better performance, cleaner code, and improved developer experience compared to higher-order components or render props.

**Basic Apollo Client Setup:**

```javascript
import { ApolloClient, InMemoryCache, ApolloProvider } from '@apollo/client';
import { createHttpLink } from '@apollo/client/link/http';
import { setContext } from '@apollo/client/link/context';

const httpLink = createHttpLink({
  uri: 'http://localhost:4000/graphql',
});

const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('authToken');
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : "",
    }
  };
});

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache({
    typePolicies: {
      User: {
        fields: {
          posts: {
            merge(existing = [], incoming) {
              return [...existing, ...incoming];
            }
          }
        }
      }
    }
  }),
  defaultOptions: {
    watchQuery: {
      errorPolicy: 'all',
      fetchPolicy: 'cache-and-network'
    },
    query: {
      errorPolicy: 'all',
      fetchPolicy: 'cache-first'
    }
  }
});

function App() {
  return (
    <ApolloProvider client={client}>
      <div className="App">
        <Router>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/posts" element={<PostList />} />
            <Route path="/profile" element={<Profile />} />
          </Routes>
        </Router>
      </div>
    </ApolloProvider>
  );
}
```

**Advanced Client Configuration:**

```javascript
import { 
  ApolloClient, 
  InMemoryCache, 
  from, 
  createHttpLink 
} from '@apollo/client';
import { onError } from '@apollo/client/link/error';
import { RetryLink } from '@apollo/client/link/retry';

const httpLink = createHttpLink({
  uri: process.env.REACT_APP_GRAPHQL_URI,
  credentials: 'include'
});

const errorLink = onError(({ graphQLErrors, networkError, operation, forward }) => {
  if (graphQLErrors) {
    graphQLErrors.forEach(({ message, locations, path }) => {
      console.error(
        `GraphQL error: Message: ${message}, Location: ${locations}, Path: ${path}`
      );
    });
  }

  if (networkError) {
    console.error(`Network error: ${networkError}`);
    
    // Handle specific network errors
    if (networkError.statusCode === 401) {
      // Redirect to login or refresh token
      window.location.href = '/login';
    }
  }
});

const retryLink = new RetryLink({
  delay: {
    initial: 300,
    max: Infinity,
    jitter: true
  },
  attempts: {
    max: 3,
    retryIf: (error, _operation) => !!error
  }
});

const client = new ApolloClient({
  link: from([errorLink, retryLink, authLink, httpLink]),
  cache: new InMemoryCache({
    possibleTypes: {
      Node: ["User", "Post", "Comment"]
    }
  }),
  connectToDevTools: process.env.NODE_ENV === 'development'
});
```

**Custom Hook for Apollo Client:**

```javascript
import { useApolloClient } from '@apollo/client';
import { useCallback, useEffect } from 'react';

const useAuthenticatedClient = () => {
  const client = useApolloClient();

  const logout = useCallback(() => {
    localStorage.removeItem('authToken');
    client.resetStore();
  }, [client]);

  const updateAuthToken = useCallback((token) => {
    localStorage.setItem('authToken', token);
    client.resetStore();
  }, [client]);

  useEffect(() => {
    const token = localStorage.getItem('authToken');
    if (!token) {
      client.resetStore();
    }
  }, [client]);

  return { logout, updateAuthToken };
};
```

### Query, Mutation, and Subscription Hooks

React hooks for GraphQL operations provide a declarative way to fetch data, perform mutations, and subscribe to real-time updates.

**Query Hook Implementation:**

```javascript
import { useQuery, gql } from '@apollo/client';

const GET_POSTS = gql`
  query GetPosts($first: Int, $after: String, $filter: PostFilter) {
    posts(first: $first, after: $after, filter: $filter) {
      edges {
        node {
          id
          title
          content
          createdAt
          author {
            id
            name
            avatar
          }
          comments {
            totalCount
          }
        }
        cursor
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
`;

const PostList = () => {
  const { loading, error, data, fetchMore, refetch } = useQuery(GET_POSTS, {
    variables: { first: 10 },
    notifyOnNetworkStatusChange: true,
    fetchPolicy: 'cache-and-network'
  });

  const loadMorePosts = useCallback(() => {
    if (data?.posts.pageInfo.hasNextPage) {
      fetchMore({
        variables: {
          after: data.posts.pageInfo.endCursor
        },
        updateQuery: (prev, { fetchMoreResult }) => {
          if (!fetchMoreResult) return prev;
          
          return {
            posts: {
              ...fetchMoreResult.posts,
              edges: [
                ...prev.posts.edges,
                ...fetchMoreResult.posts.edges
              ]
            }
          };
        }
      });
    }
  }, [data, fetchMore]);

  if (loading && !data) return <PostListSkeleton />;
  if (error) return <ErrorMessage error={error} onRetry={refetch} />;

  return (
    <div>
      {data?.posts.edges.map(({ node: post }) => (
        <PostCard key={post.id} post={post} />
      ))}
      {data?.posts.pageInfo.hasNextPage && (
        <button onClick={loadMorePosts} disabled={loading}>
          {loading ? 'Loading...' : 'Load More'}
        </button>
      )}
    </div>
  );
};
```

**Mutation Hook with Optimistic Updates:**

```javascript
import { useMutation, gql } from '@apollo/client';

const CREATE_POST = gql`
  mutation CreatePost($input: CreatePostInput!) {
    createPost(input: $input) {
      id
      title
      content
      createdAt
      author {
        id
        name
        avatar
      }
    }
  }
`;

const UPDATE_POST = gql`
  mutation UpdatePost($id: ID!, $input: UpdatePostInput!) {
    updatePost(id: $id, input: $input) {
      id
      title
      content
      updatedAt
    }
  }
`;

const PostForm = ({ postId, initialValues, onSuccess }) => {
  const [createPost, { loading: creating }] = useMutation(CREATE_POST, {
    update(cache, { data: { createPost } }) {
      const existingPosts = cache.readQuery({ query: GET_POSTS });
      
      cache.writeQuery({
        query: GET_POSTS,
        data: {
          posts: {
            ...existingPosts.posts,
            edges: [
              { node: createPost, cursor: createPost.id },
              ...existingPosts.posts.edges
            ]
          }
        }
      });
    },
    onCompleted: (data) => {
      onSuccess?.(data.createPost);
    }
  });

  const [updatePost, { loading: updating }] = useMutation(UPDATE_POST, {
    optimisticResponse: (variables) => ({
      updatePost: {
        __typename: 'Post',
        id: variables.id,
        title: variables.input.title,
        content: variables.input.content,
        updatedAt: new Date().toISOString()
      }
    }),
    onError: (error) => {
      // Handle error and potentially revert optimistic update
      console.error('Update failed:', error);
    }
  });

  const handleSubmit = async (values) => {
    try {
      if (postId) {
        await updatePost({
          variables: { id: postId, input: values }
        });
      } else {
        await createPost({
          variables: { input: values }
        });
      }
    } catch (error) {
      // Error handling is done in mutation options
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        placeholder="Post title"
        defaultValue={initialValues?.title}
        disabled={creating || updating}
      />
      <textarea
        placeholder="Post content"
        defaultValue={initialValues?.content}
        disabled={creating || updating}
      />
      <button type="submit" disabled={creating || updating}>
        {creating || updating ? 'Saving...' : 'Save Post'}
      </button>
    </form>
  );
};
```

**Subscription Hook for Real-time Updates:**

```javascript
import { useSubscription, gql } from '@apollo/client';

const POST_CREATED_SUBSCRIPTION = gql`
  subscription PostCreated {
    postCreated {
      id
      title
      content
      createdAt
      author {
        id
        name
        avatar
      }
    }
  }
`;

const COMMENT_ADDED_SUBSCRIPTION = gql`
  subscription CommentAdded($postId: ID!) {
    commentAdded(postId: $postId) {
      id
      content
      createdAt
      author {
        id
        name
        avatar
      }
    }
  }
`;

const RealTimePostList = () => {
  const { data: postsData, loading, error } = useQuery(GET_POSTS);
  
  useSubscription(POST_CREATED_SUBSCRIPTION, {
    onData: ({ data, client }) => {
      const newPost = data.data.postCreated;
      const existingPosts = client.readQuery({ query: GET_POSTS });
      
      client.writeQuery({
        query: GET_POSTS,
        data: {
          posts: {
            ...existingPosts.posts,
            edges: [
              { node: newPost, cursor: newPost.id },
              ...existingPosts.posts.edges
            ]
          }
        }
      });
    }
  });

  if (loading) return <PostListSkeleton />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div>
      {postsData?.posts.edges.map(({ node: post }) => (
        <PostWithComments key={post.id} post={post} />
      ))}
    </div>
  );
};

const PostWithComments = ({ post }) => {
  useSubscription(COMMENT_ADDED_SUBSCRIPTION, {
    variables: { postId: post.id },
    onData: ({ data, client }) => {
      const newComment = data.data.commentAdded;
      
      client.cache.modify({
        id: client.cache.identify(post),
        fields: {
          comments(existingComments = []) {
            return [...existingComments, newComment];
          }
        }
      });
    }
  });

  return <PostCard post={post} />;
};
```

### Loading States and Error Handling

Proper loading states and error handling are crucial for creating responsive and user-friendly GraphQL applications.

**Comprehensive Loading State Management:**

```javascript
import { useState, useCallback } from 'react';
import { useQuery, useMutation } from '@apollo/client';

const useLoadingState = () => {
  const [loadingStates, setLoadingStates] = useState({});

  const setLoading = useCallback((key, isLoading) => {
    setLoadingStates(prev => ({
      ...prev,
      [key]: isLoading
    }));
  }, []);

  const isLoading = useCallback((key) => {
    return loadingStates[key] || false;
  }, [loadingStates]);

  const isAnyLoading = useCallback(() => {
    return Object.values(loadingStates).some(Boolean);
  }, [loadingStates]);

  return { setLoading, isLoading, isAnyLoading };
};

const PostDetail = ({ postId }) => {
  const { setLoading, isLoading, isAnyLoading } = useLoadingState();
  
  const { loading, error, data } = useQuery(GET_POST, {
    variables: { id: postId },
    onCompleted: () => setLoading('post', false),
    onError: () => setLoading('post', false)
  });

  const [deletePost] = useMutation(DELETE_POST, {
    onCompleted: () => setLoading('delete', false),
    onError: () => setLoading('delete', false)
  });

  const handleDelete = useCallback(async () => {
    setLoading('delete', true);
    await deletePost({ variables: { id: postId } });
  }, [deletePost, postId, setLoading]);

  if (loading) return <PostDetailSkeleton />;
  if (error) return <ErrorBoundary error={error} />;

  return (
    <div className={isAnyLoading() ? 'opacity-50' : ''}>
      <PostContent post={data.post} />
      <button 
        onClick={handleDelete}
        disabled={isLoading('delete')}
        className="delete-button"
      >
        {isLoading('delete') ? (
          <span className="spinner">Deleting...</span>
        ) : (
          'Delete Post'
        )}
      </button>
    </div>
  );
};
```

**Advanced Error Handling Patterns:**

```javascript
import { ApolloError } from '@apollo/client';

const ErrorBoundary = ({ error, fallback, onRetry }) => {
  const getErrorMessage = (error) => {
    if (error instanceof ApolloError) {
      if (error.networkError) {
        return 'Network error. Please check your connection.';
      }
      
      if (error.graphQLErrors.length > 0) {
        return error.graphQLErrors[0].message;
      }
    }
    
    return 'An unexpected error occurred.';
  };

  const getErrorType = (error) => {
    if (error instanceof ApolloError) {
      if (error.networkError?.statusCode === 401) {
        return 'unauthorized';
      }
      
      if (error.networkError?.statusCode >= 500) {
        return 'server';
      }
      
      if (error.graphQLErrors.some(e => e.extensions?.code === 'VALIDATION_ERROR')) {
        return 'validation';
      }
    }
    
    return 'unknown';
  };

  const errorType = getErrorType(error);
  const errorMessage = getErrorMessage(error);

  if (fallback) {
    return fallback(error, errorMessage, errorType);
  }

  return (
    <div className={`error-container error-${errorType}`}>
      <h3>Something went wrong</h3>
      <p>{errorMessage}</p>
      
      {errorType === 'unauthorized' && (
        <button onClick={() => window.location.href = '/login'}>
          Login
        </button>
      )}
      
      {onRetry && errorType !== 'unauthorized' && (
        <button onClick={onRetry}>
          Try Again
        </button>
      )}
      
      {process.env.NODE_ENV === 'development' && (
        <details>
          <summary>Error Details</summary>
          <pre>{JSON.stringify(error, null, 2)}</pre>
        </details>
      )}
    </div>
  );
};

const useErrorHandler = () => {
  const [errors, setErrors] = useState([]);

  const addError = useCallback((error) => {
    const errorId = Date.now();
    setErrors(prev => [...prev, { id: errorId, error }]);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      setErrors(prev => prev.filter(e => e.id !== errorId));
    }, 5000);
  }, []);

  const removeError = useCallback((errorId) => {
    setErrors(prev => prev.filter(e => e.id !== errorId));
  }, []);

  const clearErrors = useCallback(() => {
    setErrors([]);
  }, []);

  return { errors, addError, removeError, clearErrors };
};
```

**Skeleton Loading Components:**

```javascript
const PostListSkeleton = () => (
  <div className="space-y-4">
    {[...Array(5)].map((_, i) => (
      <div key={i} className="animate-pulse">
        <div className="flex items-center space-x-4">
          <div className="w-12 h-12 bg-gray-300 rounded-full"></div>
          <div className="flex-1 space-y-2">
            <div className="h-4 bg-gray-300 rounded w-3/4"></div>
            <div className="h-3 bg-gray-300 rounded w-1/2"></div>
          </div>
        </div>
        <div className="mt-4 space-y-2">
          <div className="h-4 bg-gray-300 rounded"></div>
          <div className="h-4 bg-gray-300 rounded w-5/6"></div>
        </div>
      </div>
    ))}
  </div>
);

const PostDetailSkeleton = () => (
  <div className="animate-pulse">
    <div className="h-8 bg-gray-300 rounded w-3/4 mb-4"></div>
    <div className="flex items-center space-x-4 mb-6">
      <div className="w-10 h-10 bg-gray-300 rounded-full"></div>
      <div className="space-y-2">
        <div className="h-4 bg-gray-300 rounded w-24"></div>
        <div className="h-3 bg-gray-300 rounded w-16"></div>
      </div>
    </div>
    <div className="space-y-4">
      {[...Array(3)].map((_, i) => (
        <div key={i} className="h-4 bg-gray-300 rounded"></div>
      ))}
    </div>
  </div>
);
```

### Component Patterns and Best Practices

Effective component patterns ensure maintainable, performant, and reusable GraphQL-powered React applications.

**Container-Presenter Pattern:**

```javascript
// Container component handles GraphQL operations
const PostListContainer = ({ userId, filters }) => {
  const { loading, error, data, fetchMore } = useQuery(GET_POSTS, {
    variables: { userId, ...filters },
    notifyOnNetworkStatusChange: true
  });

  const [deletePost] = useMutation(DELETE_POST, {
    update: (cache, { data: { deletePost } }) => {
      cache.evict({ id: cache.identify(deletePost) });
    }
  });

  const handleDelete = useCallback(async (postId) => {
    await deletePost({ variables: { id: postId } });
  }, [deletePost]);

  const handleLoadMore = useCallback(() => {
    if (data?.posts.pageInfo.hasNextPage) {
      fetchMore({
        variables: {
          after: data.posts.pageInfo.endCursor
        }
      });
    }
  }, [data, fetchMore]);

  return (
    <PostListPresenter
      loading={loading}
      error={error}
      posts={data?.posts}
      onDelete={handleDelete}
      onLoadMore={handleLoadMore}
    />
  );
};

// Presenter component handles UI rendering
const PostListPresenter = ({ 
  loading, 
  error, 
  posts, 
  onDelete, 
  onLoadMore 
}) => {
  if (loading && !posts) return <PostListSkeleton />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div className="post-list">
      {posts?.edges.map(({ node: post }) => (
        <PostCard
          key={post.id}
          post={post}
          onDelete={() => onDelete(post.id)}
        />
      ))}
      
      {posts?.pageInfo.hasNextPage && (
        <LoadMoreButton
          onClick={onLoadMore}
          loading={loading}
        />
      )}
    </div>
  );
};
```

**Custom Hook Pattern:**

```javascript
const usePost = (postId) => {
  const { loading, error, data } = useQuery(GET_POST, {
    variables: { id: postId },
    skip: !postId
  });

  const [updatePost, { loading: updating }] = useMutation(UPDATE_POST);
  const [deletePost, { loading: deleting }] = useMutation(DELETE_POST);

  const handleUpdate = useCallback(async (input) => {
    const { data } = await updatePost({
      variables: { id: postId, input }
    });
    return data.updatePost;
  }, [updatePost, postId]);

  const handleDelete = useCallback(async () => {
    await deletePost({
      variables: { id: postId },
      update: (cache) => {
        cache.evict({ id: cache.identify({ __typename: 'Post', id: postId }) });
      }
    });
  }, [deletePost, postId]);

  return {
    post: data?.post,
    loading,
    error,
    updating,
    deleting,
    updatePost: handleUpdate,
    deletePost: handleDelete
  };
};

// Usage in component
const PostDetail = ({ postId }) => {
  const { 
    post, 
    loading, 
    error, 
    updating, 
    deleting, 
    updatePost, 
    deletePost 
  } = usePost(postId);

  if (loading) return <PostDetailSkeleton />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div>
      <PostContent post={post} />
      <PostActions
        post={post}
        onUpdate={updatePost}
        onDelete={deletePost}
        updating={updating}
        deleting={deleting}
      />
    </div>
  );
};
```

**Higher-Order Component for Authentication:**

```javascript
import { useQuery } from '@apollo/client';

const GET_CURRENT_USER = gql`
  query GetCurrentUser {
    currentUser {
      id
      name
      email
      role
    }
  }
`;

const withAuth = (WrappedComponent, requiredRole = null) => {
  return function AuthenticatedComponent(props) {
    const { loading, error, data } = useQuery(GET_CURRENT_USER);

    if (loading) return <AuthLoadingSkeleton />;
    
    if (error || !data?.currentUser) {
      return <Navigate to="/login" replace />;
    }

    if (requiredRole && data.currentUser.role !== requiredRole) {
      return <UnauthorizedMessage />;
    }

    return <WrappedComponent {...props} currentUser={data.currentUser} />;
  };
};

// Usage
const AdminPanel = withAuth(AdminPanelComponent, 'admin');
const UserProfile = withAuth(UserProfileComponent);
```

**Compound Component Pattern:**

```javascript
const PostCard = ({ post, children }) => {
  return (
    <div className="post-card">
      {children}
    </div>
  );
};

const PostHeader = ({ post }) => (
  <div className="post-header">
    <h3>{post.title}</h3>
    <AuthorInfo author={post.author} />
  </div>
);

const PostContent = ({ post }) => (
  <div className="post-content">
    {post.content}
  </div>
);

const PostActions = ({ post, onEdit, onDelete, onShare }) => (
  <div className="post-actions">
    <button onClick={() => onEdit(post)}>Edit</button>
    <button onClick={() => onDelete(post.id)}>Delete</button>
    <button onClick={() => onShare(post)}>Share</button>
  </div>
);

// Compound exports
PostCard.Header = PostHeader;
PostCard.Content = PostContent;
PostCard.Actions = PostActions;

// Usage
const PostList = () => {
  const { data } = useQuery(GET_POSTS);

  return (
    <div>
      {data?.posts.map(post => (
        <PostCard key={post.id} post={post}>
          <PostCard.Header post={post} />
          <PostCard.Content post={post} />
          <PostCard.Actions 
            post={post}
            onEdit={handleEdit}
            onDelete={handleDelete}
            onShare={handleShare}
          />
        </PostCard>
      ))}
    </div>
  );
};
```

**Key Points:**

- Apollo Client hooks provide declarative GraphQL integration with React
- Configure client with proper error handling, caching, and authentication
- Use useQuery for data fetching with pagination and real-time updates
- Implement optimistic updates and proper cache management in mutations
- Handle loading states with skeleton components and loading indicators
- Create comprehensive error boundaries for different error types
- Separate container and presenter components for better maintainability
- Use custom hooks to encapsulate GraphQL operations and business logic
- Implement authentication patterns with higher-order components or hooks

**Example** of a complete GraphQL-powered React application structure:

```javascript
// App-level structure
const App = () => (
  <ApolloProvider client={client}>
    <Router>
      <ErrorBoundary>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/posts" element={<PostListContainer />} />
          <Route path="/posts/:id" element={<PostDetailContainer />} />
          <Route path="/admin" element={<AdminPanel />} />
        </Routes>
      </ErrorBoundary>
    </Router>
  </ApolloProvider>
);
```

This comprehensive approach ensures scalable, maintainable, and performant GraphQL applications with React, providing excellent user experiences through proper loading states, error handling, and component architecture.

---

