## Real-time Features


### Subscription Implementation

GraphQL subscriptions enable real-time data synchronization between clients and servers, providing instant updates for collaborative applications, live feeds, and dynamic content.

**Basic Subscription Schema Design:**

```javascript
const typeDefs = gql`
  type Subscription {
    postCreated: Post!
    postUpdated(id: ID!): Post!
    postDeleted: ID!
    commentAdded(postId: ID!): Comment!
    userOnline: User!
    userOffline: ID!
    notificationReceived(userId: ID!): Notification!
    messageReceived(conversationId: ID!): Message!
  }

  type Post {
    id: ID!
    title: String!
    content: String!
    author: User!
    comments: [Comment!]!
    createdAt: DateTime!
    updatedAt: DateTime!
  }

  type Comment {
    id: ID!
    content: String!
    author: User!
    post: Post!
    createdAt: DateTime!
  }

  type Notification {
    id: ID!
    type: NotificationType!
    message: String!
    read: Boolean!
    createdAt: DateTime!
  }
`;
```

**Server-side Subscription Resolvers:**

```javascript
const { PubSub } = require('graphql-subscriptions');
const { RedisPubSub } = require('graphql-redis-subscriptions');

// Use Redis for production scaling
const pubsub = new RedisPubSub({
  connection: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    password: process.env.REDIS_PASSWORD
  }
});

const resolvers = {
  Subscription: {
    postCreated: {
      subscribe: () => pubsub.asyncIterator(['POST_CREATED'])
    },
    
    postUpdated: {
      subscribe: (parent, { id }) => {
        return pubsub.asyncIterator([`POST_UPDATED_${id}`]);
      }
    },
    
    commentAdded: {
      subscribe: (parent, { postId }) => {
        return pubsub.asyncIterator([`COMMENT_ADDED_${postId}`]);
      }
    },
    
    notificationReceived: {
      subscribe: withFilter(
        () => pubsub.asyncIterator(['NOTIFICATION_RECEIVED']),
        (payload, variables, context) => {
          // Filter notifications by user
          return payload.notificationReceived.userId === variables.userId;
        }
      )
    },
    
    messageReceived: {
      subscribe: withFilter(
        () => pubsub.asyncIterator(['MESSAGE_RECEIVED']),
        async (payload, variables, context) => {
          // Check if user has access to conversation
          const hasAccess = await checkConversationAccess(
            variables.conversationId,
            context.user.id
          );
          return hasAccess && payload.messageReceived.conversationId === variables.conversationId;
        }
      )
    }
  },

  Mutation: {
    createPost: async (parent, { input }, context) => {
      const post = await context.db.posts.create({
        data: {
          ...input,
          authorId: context.user.id
        },
        include: {
          author: true,
          comments: true
        }
      });

      // Trigger subscription
      pubsub.publish('POST_CREATED', { postCreated: post });
      
      return post;
    },
    
    updatePost: async (parent, { id, input }, context) => {
      const post = await context.db.posts.update({
        where: { id },
        data: input,
        include: {
          author: true,
          comments: true
        }
      });

      // Trigger specific post update
      pubsub.publish(`POST_UPDATED_${id}`, { postUpdated: post });
      
      return post;
    },
    
    addComment: async (parent, { postId, content }, context) => {
      const comment = await context.db.comments.create({
        data: {
          content,
          postId,
          authorId: context.user.id
        },
        include: {
          author: true,
          post: true
        }
      });

      // Trigger comment subscription
      pubsub.publish(`COMMENT_ADDED_${postId}`, { commentAdded: comment });
      
      return comment;
    }
  }
};
```

**Advanced Subscription Patterns:**

```javascript
// Custom subscription manager
class SubscriptionManager {
  constructor(pubsub) {
    this.pubsub = pubsub;
    this.subscriptions = new Map();
  }

  subscribe(event, callback, filter = null) {
    const subscriptionId = this.generateId();
    const subscription = {
      id: subscriptionId,
      event,
      callback,
      filter,
      active: true
    };

    this.subscriptions.set(subscriptionId, subscription);
    
    const asyncIterator = this.pubsub.asyncIterator([event]);
    this.handleSubscription(subscription, asyncIterator);
    
    return subscriptionId;
  }

  async handleSubscription(subscription, asyncIterator) {
    try {
      for await (const payload of asyncIterator) {
        if (!subscription.active) break;
        
        if (subscription.filter && !subscription.filter(payload)) {
          continue;
        }
        
        subscription.callback(payload);
      }
    } catch (error) {
      console.error('Subscription error:', error);
    }
  }

  unsubscribe(subscriptionId) {
    const subscription = this.subscriptions.get(subscriptionId);
    if (subscription) {
      subscription.active = false;
      this.subscriptions.delete(subscriptionId);
    }
  }

  generateId() {
    return `sub_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}

// Usage in resolvers
const subscriptionManager = new SubscriptionManager(pubsub);

const resolvers = {
  Subscription: {
    liveUpdates: {
      subscribe: async (parent, args, context) => {
        const userChannels = await getUserChannels(context.user.id);
        return subscriptionManager.subscribe(
          'LIVE_UPDATES',
          (payload) => payload,
          (payload) => userChannels.includes(payload.channel)
        );
      }
    }
  }
};
```

### WebSocket Connection Management

Proper WebSocket connection management ensures reliable real-time communication with connection recovery, heartbeat monitoring, and authentication.

**Apollo Client WebSocket Setup:**

```javascript
import { GraphQLWsLink } from '@apollo/client/link/subscriptions';
import { createClient } from 'graphql-ws';
import { getMainDefinition } from '@apollo/client/utilities';
import { split } from '@apollo/client';

const httpLink = createHttpLink({
  uri: 'http://localhost:4000/graphql'
});

const wsLink = new GraphQLWsLink(
  createClient({
    url: 'ws://localhost:4000/graphql',
    
    connectionParams: () => {
      const token = localStorage.getItem('authToken');
      return {
        authorization: token ? `Bearer ${token}` : null
      };
    },
    
    on: {
      connected: () => {
        console.log('WebSocket connected');
        setConnectionStatus('connected');
      },
      
      closed: () => {
        console.log('WebSocket disconnected');
        setConnectionStatus('disconnected');
      },
      
      error: (error) => {
        console.error('WebSocket error:', error);
        setConnectionStatus('error');
      }
    },
    
    retryAttempts: 5,
    retryWait: async (retries) => {
      const delay = Math.min(1000 * Math.pow(2, retries), 30000);
      await new Promise(resolve => setTimeout(resolve, delay));
    },
    
    shouldRetry: (error) => {
      // Don't retry on authentication errors
      return !error.message.includes('Unauthorized');
    }
  })
);

const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query);
    return (
      definition.kind === 'OperationDefinition' &&
      definition.operation === 'subscription'
    );
  },
  wsLink,
  httpLink
);

const client = new ApolloClient({
  link: splitLink,
  cache: new InMemoryCache()
});
```

**Connection Status Management:**

```javascript
import { useState, useEffect, useCallback } from 'react';

const useWebSocketConnection = () => {
  const [connectionStatus, setConnectionStatus] = useState('connecting');
  const [reconnectAttempts, setReconnectAttempts] = useState(0);
  const [lastSeen, setLastSeen] = useState(null);

  const handleConnectionChange = useCallback((status) => {
    setConnectionStatus(status);
    
    if (status === 'connected') {
      setReconnectAttempts(0);
      setLastSeen(new Date());
    } else if (status === 'disconnected') {
      setReconnectAttempts(prev => prev + 1);
    }
  }, []);

  const resetConnection = useCallback(() => {
    setReconnectAttempts(0);
    setConnectionStatus('connecting');
    // Force reconnection logic here
  }, []);

  return {
    connectionStatus,
    reconnectAttempts,
    lastSeen,
    onConnectionChange: handleConnectionChange,
    resetConnection
  };
};

const ConnectionStatus = () => {
  const { connectionStatus, reconnectAttempts, resetConnection } = useWebSocketConnection();

  const getStatusColor = () => {
    switch (connectionStatus) {
      case 'connected': return 'green';
      case 'connecting': return 'yellow';
      case 'disconnected': return 'red';
      default: return 'gray';
    }
  };

  const getStatusText = () => {
    switch (connectionStatus) {
      case 'connected': return 'Connected';
      case 'connecting': return 'Connecting...';
      case 'disconnected': 
        return `Disconnected ${reconnectAttempts > 0 ? `(${reconnectAttempts} attempts)` : ''}`;
      default: return 'Unknown';
    }
  };

  return (
    <div className="connection-status">
      <div className={`status-indicator ${getStatusColor()}`} />
      <span>{getStatusText()}</span>
      
      {connectionStatus === 'disconnected' && (
        <button onClick={resetConnection} className="retry-button">
          Retry
        </button>
      )}
    </div>
  );
};
```

**Heartbeat and Health Monitoring:**

```javascript
class WebSocketHealthMonitor {
  constructor(wsClient) {
    this.wsClient = wsClient;
    this.heartbeatInterval = null;
    this.lastPong = Date.now();
    this.isHealthy = true;
  }

  start() {
    this.heartbeatInterval = setInterval(() => {
      this.sendPing();
    }, 30000); // Send ping every 30 seconds

    this.wsClient.on('pong', () => {
      this.lastPong = Date.now();
      this.isHealthy = true;
    });

    this.wsClient.on('error', () => {
      this.isHealthy = false;
    });

    this.wsClient.on('close', () => {
      this.isHealthy = false;
      this.stop();
    });
  }

  stop() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }
  }

  sendPing() {
    if (this.wsClient.readyState === WebSocket.OPEN) {
      this.wsClient.ping();
      
      // Check if we received pong within timeout
      setTimeout(() => {
        if (Date.now() - this.lastPong > 35000) {
          this.isHealthy = false;
          this.wsClient.terminate();
        }
      }, 35000);
    }
  }

  getHealthStatus() {
    return {
      isHealthy: this.isHealthy,
      lastPong: this.lastPong,
      connectionState: this.wsClient.readyState
    };
  }
}
```

### Real-time UI Updates

Implementing smooth real-time UI updates requires careful state management, optimistic updates, and conflict resolution strategies.

**Real-time Data Synchronization:**

```javascript
import { useSubscription, useMutation, useQuery } from '@apollo/client';

const LIVE_POSTS_SUBSCRIPTION = gql`
  subscription LivePosts {
    postCreated {
      id
      title
      content
      author {
        id
        name
        avatar
      }
      createdAt
    }
    postUpdated {
      id
      title
      content
      updatedAt
    }
    postDeleted
  }
`;

const GET_POSTS = gql`
  query GetPosts($first: Int!, $after: String) {
    posts(first: $first, after: $after) {
      edges {
        node {
          id
          title
          content
          author {
            id
            name
            avatar
          }
          createdAt
          updatedAt
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

const LivePostList = () => {
  const { data, loading, error } = useQuery(GET_POSTS, {
    variables: { first: 20 }
  });

  useSubscription(LIVE_POSTS_SUBSCRIPTION, {
    onData: ({ data: subscriptionData, client }) => {
      const { postCreated, postUpdated, postDeleted } = subscriptionData.data;

      if (postCreated) {
        handlePostCreated(postCreated, client);
      }
      
      if (postUpdated) {
        handlePostUpdated(postUpdated, client);
      }
      
      if (postDeleted) {
        handlePostDeleted(postDeleted, client);
      }
    }
  });

  const handlePostCreated = (newPost, client) => {
    const existingData = client.readQuery({ query: GET_POSTS });
    
    if (existingData) {
      client.writeQuery({
        query: GET_POSTS,
        data: {
          posts: {
            ...existingData.posts,
            edges: [
              { node: newPost, cursor: newPost.id },
              ...existingData.posts.edges
            ]
          }
        }
      });
    }
  };

  const handlePostUpdated = (updatedPost, client) => {
    client.cache.modify({
      id: client.cache.identify(updatedPost),
      fields: {
        title: () => updatedPost.title,
        content: () => updatedPost.content,
        updatedAt: () => updatedPost.updatedAt
      }
    });
  };

  const handlePostDeleted = (deletedPostId, client) => {
    client.cache.evict({
      id: client.cache.identify({
        __typename: 'Post',
        id: deletedPostId
      })
    });
  };

  if (loading) return <PostListSkeleton />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div className="live-post-list">
      {data?.posts.edges.map(({ node: post }) => (
        <LivePostCard key={post.id} post={post} />
      ))}
    </div>
  );
};
```

**Optimistic Updates with Conflict Resolution:**

```javascript
const useLivePostActions = () => {
  const [updatePost] = useMutation(UPDATE_POST);
  const [deletePost] = useMutation(DELETE_POST);

  const handleOptimisticUpdate = useCallback(async (postId, updates) => {
    const optimisticUpdate = {
      __typename: 'Post',
      id: postId,
      ...updates,
      updatedAt: new Date().toISOString()
    };

    try {
      await updatePost({
        variables: { id: postId, input: updates },
        optimisticResponse: {
          updatePost: optimisticUpdate
        },
        update: (cache, { data }) => {
          // Handle successful update
          const updatedPost = data.updatePost;
          
          cache.modify({
            id: cache.identify({ __typename: 'Post', id: postId }),
            fields: {
              title: () => updatedPost.title,
              content: () => updatedPost.content,
              updatedAt: () => updatedPost.updatedAt
            }
          });
        },
        onError: (error) => {
          // Handle conflict resolution
          if (error.graphQLErrors.some(e => e.extensions.code === 'CONFLICT')) {
            handleConflictResolution(postId, updates, error);
          }
        }
      });
    } catch (error) {
      console.error('Update failed:', error);
    }
  }, [updatePost]);

  const handleConflictResolution = async (postId, localUpdates, error) => {
    const conflictData = error.graphQLErrors[0].extensions.conflictData;
    
    // Show conflict resolution UI
    const resolution = await showConflictDialog({
      local: localUpdates,
      remote: conflictData,
      post: { id: postId }
    });

    if (resolution.action === 'merge') {
      await handleOptimisticUpdate(postId, resolution.mergedData);
    } else if (resolution.action === 'overwrite') {
      await handleOptimisticUpdate(postId, localUpdates);
    }
  };

  return { handleOptimisticUpdate };
};
```

**Real-time Collaboration Features:**

```javascript
const useCollaborativeEditing = (postId) => {
  const [collaborators, setCollaborators] = useState([]);
  const [cursorPositions, setCursorPositions] = useState({});
  const [typingUsers, setTypingUsers] = useState(new Set());

  const { data: subscriptionData } = useSubscription(
    COLLABORATIVE_EDITING_SUBSCRIPTION,
    {
      variables: { postId },
      onData: ({ data }) => {
        const { collaboratorJoined, collaboratorLeft, cursorMoved, userTyping } = data.data;

        if (collaboratorJoined) {
          setCollaborators(prev => [...prev, collaboratorJoined]);
        }

        if (collaboratorLeft) {
          setCollaborators(prev => prev.filter(c => c.id !== collaboratorLeft.id));
          setCursorPositions(prev => {
            const updated = { ...prev };
            delete updated[collaboratorLeft.id];
            return updated;
          });
        }

        if (cursorMoved) {
          setCursorPositions(prev => ({
            ...prev,
            [cursorMoved.userId]: cursorMoved.position
          }));
        }

        if (userTyping) {
          setTypingUsers(prev => new Set([...prev, userTyping.userId]));
          
          // Remove typing indicator after delay
          setTimeout(() => {
            setTypingUsers(prev => {
              const updated = new Set(prev);
              updated.delete(userTyping.userId);
              return updated;
            });
          }, 3000);
        }
      }
    }
  );

  const [publishCursorPosition] = useMutation(PUBLISH_CURSOR_POSITION);
  const [publishTypingStatus] = useMutation(PUBLISH_TYPING_STATUS);

  const handleCursorMove = useCallback((position) => {
    publishCursorPosition({
      variables: { postId, position }
    });
  }, [publishCursorPosition, postId]);

  const handleTypingStart = useCallback(() => {
    publishTypingStatus({
      variables: { postId, typing: true }
    });
  }, [publishTypingStatus, postId]);

  return {
    collaborators,
    cursorPositions,
    typingUsers,
    onCursorMove: handleCursorMove,
    onTypingStart: handleTypingStart
  };
};
```

### Offline Support and Sync

Implementing offline support ensures applications remain functional without network connectivity and synchronize data when connectivity is restored.

**Offline-First Cache Strategy:**

```javascript
import { persistCache, LocalStorageWrapper } from 'apollo3-cache-persist';
import { InMemoryCache } from '@apollo/client';

const cache = new InMemoryCache({
  typePolicies: {
    Post: {
      fields: {
        comments: {
          merge: (existing = [], incoming) => [...existing, ...incoming]
        }
      }
    }
  }
});

// Persist cache to local storage
const initializeCache = async () => {
  await persistCache({
    cache,
    storage: new LocalStorageWrapper(window.localStorage),
    maxSize: 1048576 * 10, // 10MB
    debug: process.env.NODE_ENV === 'development'
  });
};

// Network status detection
const useNetworkStatus = () => {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return isOnline;
};
```

**Offline Queue Management:**

```javascript
class OfflineQueue {
  constructor() {
    this.queue = this.loadQueue();
    this.processing = false;
  }

  loadQueue() {
    const stored = localStorage.getItem('offlineQueue');
    return stored ? JSON.parse(stored) : [];
  }

  saveQueue() {
    localStorage.setItem('offlineQueue', JSON.stringify(this.queue));
  }

  addOperation(operation) {
    const queueItem = {
      id: this.generateId(),
      operation,
      timestamp: Date.now(),
      retryCount: 0
    };

    this.queue.push(queueItem);
    this.saveQueue();
  }

  async processQueue(apolloClient) {
    if (this.processing || this.queue.length === 0) return;

    this.processing = true;

    while (this.queue.length > 0) {
      const item = this.queue[0];

      try {
        await this.executeOperation(item.operation, apolloClient);
        this.queue.shift();
      } catch (error) {
        item.retryCount++;
        
        if (item.retryCount >= 3) {
          // Remove failed item after 3 retries
          this.queue.shift();
          console.error('Operation failed after 3 retries:', error);
        } else {
          // Move to end of queue for retry
          this.queue.push(this.queue.shift());
        }
      }
    }

    this.processing = false;
    this.saveQueue();
  }

  async executeOperation(operation, apolloClient) {
    if (operation.type === 'mutation') {
      return await apolloClient.mutate({
        mutation: operation.mutation,
        variables: operation.variables
      });
    } else if (operation.type === 'query') {
      return await apolloClient.query({
        query: operation.query,
        variables: operation.variables,
        fetchPolicy: 'network-only'
      });
    }
  }

  generateId() {
    return `op_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}
```

**Offline-Aware Components:**

```javascript
const OfflineAwarePostList = () => {
  const isOnline = useNetworkStatus();
  const [offlineQueue] = useState(() => new OfflineQueue());
  const apolloClient = useApolloClient();

  const { data, loading, error } = useQuery(GET_POSTS, {
    fetchPolicy: isOnline ? 'cache-and-network' : 'cache-only',
    errorPolicy: 'all'
  });

  const [createPost] = useMutation(CREATE_POST, {
    onError: (error) => {
      if (!isOnline) {
        // Add to offline queue
        offlineQueue.addOperation({
          type: 'mutation',
          mutation: CREATE_POST,
          variables: { input: postData }
        });
      }
    }
  });

  useEffect(() => {
    if (isOnline) {
      offlineQueue.processQueue(apolloClient);
    }
  }, [isOnline, apolloClient, offlineQueue]);

  const handleCreatePost = async (postData) => {
    if (isOnline) {
      await createPost({ variables: { input: postData } });
    } else {
      // Store optimistically in cache
      const optimisticPost = {
        __typename: 'Post',
        id: `temp_${Date.now()}`,
        ...postData,
        author: getCurrentUser(),
        createdAt: new Date().toISOString(),
        offline: true
      };

      apolloClient.cache.modify({
        fields: {
          posts: (existingPosts = []) => [optimisticPost, ...existingPosts]
        }
      });

      // Add to offline queue
      offlineQueue.addOperation({
        type: 'mutation',
        mutation: CREATE_POST,
        variables: { input: postData }
      });
    }
  };

  return (
    <div className="post-list">
      {!isOnline && (
        <div className="offline-banner">
          <AlertCircle size={16} />
          You're offline. Changes will sync when connection is restored.
        </div>
      )}
      
      {data?.posts.map(post => (
        <PostCard 
          key={post.id} 
          post={post}
          offline={post.offline}
          onUpdate={(updates) => handleUpdatePost(post.id, updates)}
        />
      ))}
    </div>
  );
};
```

**Conflict Resolution for Offline Sync:**

```javascript
const useConflictResolution = () => {
  const [conflicts, setConflicts] = useState([]);

  const detectConflicts = useCallback((localData, remoteData) => {
    const conflicts = [];

    for (const localItem of localData) {
      const remoteItem = remoteData.find(r => r.id === localItem.id);
      
      if (remoteItem && remoteItem.updatedAt > localItem.updatedAt) {
        conflicts.push({
          id: localItem.id,
          local: localItem,
          remote: remoteItem,
          type: 'update_conflict'
        });
      }
    }

    return conflicts;
  }, []);

  const resolveConflict = useCallback(async (conflict, resolution) => {
    let resolvedData;

    switch (resolution.strategy) {
      case 'use_remote':
        resolvedData = conflict.remote;
        break;
      case 'use_local':
        resolvedData = conflict.local;
        break;
      case 'merge':
        resolvedData = mergeObjects(conflict.local, conflict.remote);
        break;
      default:
        resolvedData = conflict.remote;
    }

    // Update cache with resolved data
    await updateCacheWithResolution(conflict.id, resolvedData);
    
    setConflicts(prev => prev.filter(c => c.id !== conflict.id));
  }, []);

  const mergeObjects = (local, remote) => {
    // Custom merge logic based on data types
    return {
      ...remote,
      ...local,
      updatedAt: Math.max(
        new Date(local.updatedAt).getTime(),
        new Date(remote.updatedAt).getTime()
      )
    };
  };

  return {
    conflicts,
    detectConflicts,
    resolveConflict
  };
};
```

**Key Points:**

- Implement GraphQL subscriptions with proper filtering and authentication
- Use Redis PubSub for scalable real-time features across multiple servers
- Manage WebSocket connections with heartbeat monitoring and automatic reconnection
- Handle real-time UI updates with optimistic updates and conflict resolution
- Implement offline-first architecture with local caching and sync queues
- Provide visual feedback for connection status and offline operations
- Use subscription filtering to minimize unnecessary network traffic
- Implement collaborative editing features with cursor tracking and typing indicators

**Example** of a complete real-time application structure:

```javascript
// Real-time enabled application
const RealTimeApp = () => {
  const isOnline = useNetworkStatus();
  const { connectionStatus } = useWebSocketConnection();

  return (
    <div className="real-time-app">
      <ConnectionStatus status={connectionStatus} />
      
      {!isOnline && <OfflineBanner />}
      
      <Routes>
        <Route path="/posts" element={<LivePostList />} />
        <Route path="/chat" element={<RealTimeChat />} />
        <Route path="/collaborate" element={<CollaborativeEditor />} />
      </Routes>
    </div>
  );
};
```

This comprehensive approach ensures robust real-time features that work reliably across different network conditions while providing excellent user experiences through proper offline support and conflict resolution.

---

