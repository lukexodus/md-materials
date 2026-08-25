## Fetch API Redux Integration


### Redux Thunk Middleware

Redux Thunk enables action creators to return functions instead of plain objects, allowing asynchronous fetch operations:

```javascript
// Action types
const FETCH_USER_REQUEST = 'FETCH_USER_REQUEST';
const FETCH_USER_SUCCESS = 'FETCH_USER_SUCCESS';
const FETCH_USER_FAILURE = 'FETCH_USER_FAILURE';

// Action creators
const fetchUserRequest = () => ({ type: FETCH_USER_REQUEST });
const fetchUserSuccess = (user) => ({ type: FETCH_USER_SUCCESS, payload: user });
const fetchUserFailure = (error) => ({ type: FETCH_USER_FAILURE, payload: error });

// Thunk action creator
const fetchUser = (userId) => {
  return async (dispatch) => {
    dispatch(fetchUserRequest());
    
    try {
      const response = await fetch(`/api/users/${userId}`);
      
      if (!response.ok) {
        throw new Error(`HTTP error ${response.status}`);
      }
      
      const user = await response.json();
      dispatch(fetchUserSuccess(user));
    } catch (error) {
      dispatch(fetchUserFailure(error.message));
    }
  };
};
```

### Reducer Patterns for Fetch States

Typical reducer structure for handling fetch lifecycle:

```javascript
const initialState = {
  data: null,
  loading: false,
  error: null
};

function userReducer(state = initialState, action) {
  switch (action.type) {
    case FETCH_USER_REQUEST:
      return {
        ...state,
        loading: true,
        error: null
      };
      
    case FETCH_USER_SUCCESS:
      return {
        ...state,
        loading: false,
        data: action.payload,
        error: null
      };
      
    case FETCH_USER_FAILURE:
      return {
        ...state,
        loading: false,
        error: action.payload
      };
      
    default:
      return state;
  }
}
```

### Normalized State Management

Handling relational data from fetch responses:

```javascript
import { normalize, schema } from 'normalizr';

// Define schemas
const userSchema = new schema.Entity('users');
const commentSchema = new schema.Entity('comments', {
  author: userSchema
});
const postSchema = new schema.Entity('posts', {
  author: userSchema,
  comments: [commentSchema]
});

// Thunk with normalization
const fetchPost = (postId) => {
  return async (dispatch) => {
    dispatch({ type: 'FETCH_POST_REQUEST' });
    
    try {
      const response = await fetch(`/api/posts/${postId}`);
      const post = await response.json();
      
      // Normalize nested data
      const normalized = normalize(post, postSchema);
      
      dispatch({
        type: 'FETCH_POST_SUCCESS',
        payload: normalized
      });
    } catch (error) {
      dispatch({ type: 'FETCH_POST_FAILURE', payload: error.message });
    }
  };
};

// Reducer for normalized data
function entitiesReducer(state = { users: {}, posts: {}, comments: {} }, action) {
  switch (action.type) {
    case 'FETCH_POST_SUCCESS':
      return {
        users: { ...state.users, ...action.payload.entities.users },
        posts: { ...state.posts, ...action.payload.entities.posts },
        comments: { ...state.comments, ...action.payload.entities.comments }
      };
    default:
      return state;
  }
}
```

### Request Cancellation with AbortController

Integrating AbortController for cancellable requests:

```javascript
// Store abort controllers
const abortControllers = {};

const fetchUserCancellable = (userId) => {
  return async (dispatch) => {
    // Cancel previous request for this user
    if (abortControllers[userId]) {
      abortControllers[userId].abort();
    }
    
    const controller = new AbortController();
    abortControllers[userId] = controller;
    
    dispatch(fetchUserRequest());
    
    try {
      const response = await fetch(`/api/users/${userId}`, {
        signal: controller.signal
      });
      
      const user = await response.json();
      dispatch(fetchUserSuccess(user));
      
      delete abortControllers[userId];
    } catch (error) {
      if (error.name === 'AbortError') {
        // Request was cancelled, don't dispatch failure
        return;
      }
      dispatch(fetchUserFailure(error.message));
      delete abortControllers[userId];
    }
  };
};

// Cleanup action
const cancelFetchUser = (userId) => {
  return (dispatch) => {
    if (abortControllers[userId]) {
      abortControllers[userId].abort();
      delete abortControllers[userId];
    }
  };
};
```

### Redux Saga Integration

Using sagas for complex fetch orchestration:

```javascript
import { call, put, takeLatest, race, delay } from 'redux-saga/effects';

function* fetchUserSaga(action) {
  try {
    yield put({ type: 'FETCH_USER_REQUEST' });
    
    // Race between fetch and timeout
    const { response, timeout } = yield race({
      response: call(fetch, `/api/users/${action.payload.userId}`),
      timeout: delay(5000)
    });
    
    if (timeout) {
      throw new Error('Request timeout');
    }
    
    if (!response.ok) {
      throw new Error(`HTTP error ${response.status}`);
    }
    
    const user = yield response.json();
    yield put({ type: 'FETCH_USER_SUCCESS', payload: user });
  } catch (error) {
    yield put({ type: 'FETCH_USER_FAILURE', payload: error.message });
  }
}

function* watchFetchUser() {
  yield takeLatest('FETCH_USER', fetchUserSaga);
}
```

### Polling and Auto-Refresh

Implementing periodic data fetching:

```javascript
import { takeLatest, put, call, delay, cancelled } from 'redux-saga/effects';

function* pollDataSaga() {
  try {
    while (true) {
      const response = yield call(fetch, '/api/data');
      const data = yield response.json();
      
      yield put({ type: 'POLL_DATA_SUCCESS', payload: data });
      yield delay(5000); // Poll every 5 seconds
    }
  } catch (error) {
    yield put({ type: 'POLL_DATA_FAILURE', payload: error.message });
  } finally {
    if (yield cancelled()) {
      // Cleanup on cancellation
      console.log('Polling cancelled');
    }
  }
}

function* watchStartPolling() {
  yield takeLatest('START_POLLING', pollDataSaga);
}
```

### Optimistic Updates

Implementing optimistic UI updates before fetch completes:

```javascript
const updateUser = (userId, updates) => {
  return async (dispatch, getState) => {
    const previousUser = getState().users.data[userId];
    
    // Optimistic update
    dispatch({
      type: 'UPDATE_USER_OPTIMISTIC',
      payload: { userId, updates }
    });
    
    try {
      const response = await fetch(`/api/users/${userId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates)
      });
      
      const updatedUser = await response.json();
      
      dispatch({
        type: 'UPDATE_USER_SUCCESS',
        payload: updatedUser
      });
    } catch (error) {
      // Revert to previous state
      dispatch({
        type: 'UPDATE_USER_FAILURE',
        payload: { userId, previousUser, error: error.message }
      });
    }
  };
};

// Reducer
function usersReducer(state = { data: {} }, action) {
  switch (action.type) {
    case 'UPDATE_USER_OPTIMISTIC':
      return {
        ...state,
        data: {
          ...state.data,
          [action.payload.userId]: {
            ...state.data[action.payload.userId],
            ...action.payload.updates
          }
        }
      };
      
    case 'UPDATE_USER_FAILURE':
      return {
        ...state,
        data: {
          ...state.data,
          [action.payload.userId]: action.payload.previousUser
        },
        error: action.payload.error
      };
      
    default:
      return state;
  }
}
```

### Middleware for Request/Response Interception

Custom middleware for centralized fetch handling:

```javascript
const apiMiddleware = (store) => (next) => (action) => {
  if (action.type !== 'API_REQUEST') {
    return next(action);
  }
  
  const { endpoint, method = 'GET', body, types } = action.payload;
  const [requestType, successType, failureType] = types;
  
  store.dispatch({ type: requestType });
  
  const options = {
    method,
    headers: { 'Content-Type': 'application/json' }
  };
  
  if (body) {
    options.body = JSON.stringify(body);
  }
  
  return fetch(endpoint, options)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      store.dispatch({ type: successType, payload: data });
      return data;
    })
    .catch(error => {
      store.dispatch({ type: failureType, payload: error.message });
      throw error;
    });
};

// Usage
dispatch({
  type: 'API_REQUEST',
  payload: {
    endpoint: '/api/users',
    method: 'POST',
    body: { name: 'John' },
    types: ['CREATE_USER_REQUEST', 'CREATE_USER_SUCCESS', 'CREATE_USER_FAILURE']
  }
});
```

### Authentication Token Management

Handling authentication in Redux with fetch:

```javascript
const authenticatedFetch = (url, options = {}) => {
  return (dispatch, getState) => {
    const token = getState().auth.token;
    
    const headers = {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    };
    
    return fetch(url, { ...options, headers })
      .then(response => {
        if (response.status === 401) {
          dispatch({ type: 'AUTH_TOKEN_EXPIRED' });
          throw new Error('Authentication required');
        }
        return response;
      });
  };
};

// Thunk with authenticated fetch
const fetchProtectedData = () => {
  return async (dispatch, getState) => {
    try {
      const response = await dispatch(authenticatedFetch('/api/protected'));
      const data = await response.json();
      dispatch({ type: 'FETCH_PROTECTED_SUCCESS', payload: data });
    } catch (error) {
      dispatch({ type: 'FETCH_PROTECTED_FAILURE', payload: error.message });
    }
  };
};
```

### Token Refresh Flow

Automatic token refresh on expiration:

```javascript
let refreshTokenPromise = null;

const fetchWithTokenRefresh = (url, options = {}) => {
  return async (dispatch, getState) => {
    const makeRequest = async (token) => {
      const headers = {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      };
      
      return fetch(url, { ...options, headers });
    };
    
    let token = getState().auth.token;
    let response = await makeRequest(token);
    
    if (response.status === 401) {
      // Token expired, refresh it
      if (!refreshTokenPromise) {
        refreshTokenPromise = dispatch(refreshToken())
          .finally(() => {
            refreshTokenPromise = null;
          });
      }
      
      await refreshTokenPromise;
      token = getState().auth.token;
      response = await makeRequest(token);
    }
    
    return response;
  };
};

const refreshToken = () => {
  return async (dispatch, getState) => {
    const refreshToken = getState().auth.refreshToken;
    
    const response = await fetch('/api/auth/refresh', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken })
    });
    
    const { token } = await response.json();
    
    dispatch({ type: 'TOKEN_REFRESHED', payload: token });
    return token;
  };
};
```

### Caching Strategies

Implementing caching in Redux store:

```javascript
const fetchWithCache = (url, cacheTime = 60000) => {
  return async (dispatch, getState) => {
    const cache = getState().cache[url];
    const now = Date.now();
    
    // Return cached data if valid
    if (cache && (now - cache.timestamp) < cacheTime) {
      dispatch({
        type: 'FETCH_FROM_CACHE',
        payload: { url, data: cache.data }
      });
      return cache.data;
    }
    
    // Fetch fresh data
    dispatch({ type: 'FETCH_REQUEST', payload: { url } });
    
    try {
      const response = await fetch(url);
      const data = await response.json();
      
      dispatch({
        type: 'FETCH_SUCCESS',
        payload: { url, data, timestamp: now }
      });
      
      return data;
    } catch (error) {
      dispatch({
        type: 'FETCH_FAILURE',
        payload: { url, error: error.message }
      });
      throw error;
    }
  };
};

// Cache reducer
function cacheReducer(state = {}, action) {
  switch (action.type) {
    case 'FETCH_SUCCESS':
      return {
        ...state,
        [action.payload.url]: {
          data: action.payload.data,
          timestamp: action.payload.timestamp
        }
      };
      
    case 'INVALIDATE_CACHE':
      const { [action.payload.url]: removed, ...rest } = state;
      return rest;
      
    default:
      return state;
  }
}
```

### Batching Multiple Requests

Coordinating multiple fetch operations:

```javascript
const fetchMultiple = (endpoints) => {
  return async (dispatch) => {
    dispatch({ type: 'FETCH_MULTIPLE_REQUEST' });
    
    try {
      const promises = endpoints.map(endpoint => 
        fetch(endpoint).then(res => res.json())
      );
      
      const results = await Promise.all(promises);
      
      dispatch({
        type: 'FETCH_MULTIPLE_SUCCESS',
        payload: results.reduce((acc, data, index) => {
          acc[endpoints[index]] = data;
          return acc;
        }, {})
      });
    } catch (error) {
      dispatch({
        type: 'FETCH_MULTIPLE_FAILURE',
        payload: error.message
      });
    }
  };
};

// Sequential fetching with dependencies
const fetchSequential = () => {
  return async (dispatch) => {
    try {
      const userResponse = await fetch('/api/user');
      const user = await userResponse.json();
      
      dispatch({ type: 'FETCH_USER_SUCCESS', payload: user });
      
      // Fetch depends on user data
      const postsResponse = await fetch(`/api/users/${user.id}/posts`);
      const posts = await postsResponse.json();
      
      dispatch({ type: 'FETCH_POSTS_SUCCESS', payload: posts });
    } catch (error) {
      dispatch({ type: 'FETCH_SEQUENTIAL_FAILURE', payload: error.message });
    }
  };
};
```

### Error Handling Patterns

Centralized error handling:

```javascript
const handleApiError = (error, dispatch) => {
  if (error.name === 'AbortError') {
    // Request cancelled, no action needed
    return;
  }
  
  if (error.message.includes('NetworkError')) {
    dispatch({
      type: 'NETWORK_ERROR',
      payload: 'Network connection lost'
    });
  } else if (error.message.includes('401')) {
    dispatch({ type: 'AUTH_ERROR' });
  } else if (error.message.includes('403')) {
    dispatch({
      type: 'PERMISSION_ERROR',
      payload: 'Access denied'
    });
  } else {
    dispatch({
      type: 'GENERAL_ERROR',
      payload: error.message
    });
  }
};

// Enhanced thunk with error handling
const fetchWithErrorHandling = (url) => {
  return async (dispatch) => {
    dispatch({ type: 'FETCH_REQUEST' });
    
    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        const error = new Error(`HTTP error ${response.status}`);
        error.status = response.status;
        throw error;
      }
      
      const data = await response.json();
      dispatch({ type: 'FETCH_SUCCESS', payload: data });
    } catch (error) {
      handleApiError(error, dispatch);
      dispatch({ type: 'FETCH_FAILURE', payload: error.message });
    }
  };
};
```

### Redux Toolkit Integration

Modern Redux Toolkit patterns with createAsyncThunk:

```javascript
import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';

// Async thunk with fetch
export const fetchUser = createAsyncThunk(
  'users/fetchUser',
  async (userId, { rejectWithValue }) => {
    try {
      const response = await fetch(`/api/users/${userId}`);
      
      if (!response.ok) {
        throw new Error(`HTTP error ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Slice with automatic action creators
const usersSlice = createSlice({
  name: 'users',
  initialState: {
    entities: {},
    loading: false,
    error: null
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchUser.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchUser.fulfilled, (state, action) => {
        state.loading = false;
        state.entities[action.payload.id] = action.payload;
      })
      .addCase(fetchUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  }
});

export default usersSlice.reducer;
```

### RTK Query Setup

Full-featured data fetching with RTK Query:

```javascript
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

// Define API slice
export const apiSlice = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api',
    prepareHeaders: (headers, { getState }) => {
      const token = getState().auth.token;
      if (token) {
        headers.set('Authorization', `Bearer ${token}`);
      }
      return headers;
    }
  }),
  tagTypes: ['User', 'Post'],
  endpoints: (builder) => ({
    getUser: builder.query({
      query: (userId) => `/users/${userId}`,
      providesTags: (result, error, userId) => [{ type: 'User', id: userId }]
    }),
    updateUser: builder.mutation({
      query: ({ userId, ...patch }) => ({
        url: `/users/${userId}`,
        method: 'PATCH',
        body: patch
      }),
      invalidatesTags: (result, error, { userId }) => [{ type: 'User', id: userId }]
    }),
    getPosts: builder.query({
      query: () => '/posts',
      providesTags: ['Post']
    })
  })
});

export const { useGetUserQuery, useUpdateUserMutation, useGetPostsQuery } = apiSlice;
```

### Pagination Handling

Managing paginated fetch requests:

```javascript
const fetchPage = (page, limit = 20) => {
  return async (dispatch, getState) => {
    const existingData = getState().pagination.data;
    
    dispatch({
      type: 'FETCH_PAGE_REQUEST',
      payload: { page }
    });
    
    try {
      const response = await fetch(`/api/items?page=${page}&limit=${limit}`);
      const data = await response.json();
      
      dispatch({
        type: 'FETCH_PAGE_SUCCESS',
        payload: {
          page,
          data: data.items,
          hasMore: data.hasMore,
          total: data.total
        }
      });
    } catch (error) {
      dispatch({
        type: 'FETCH_PAGE_FAILURE',
        payload: error.message
      });
    }
  };
};

// Pagination reducer
function paginationReducer(state = { data: [], page: 1, hasMore: true }, action) {
  switch (action.type) {
    case 'FETCH_PAGE_SUCCESS':
      return {
        ...state,
        data: action.payload.page === 1 
          ? action.payload.data 
          : [...state.data, ...action.payload.data],
        page: action.payload.page,
        hasMore: action.payload.hasMore,
        total: action.payload.total
      };
      
    default:
      return state;
  }
}
```

### WebSocket to Redux Bridge

Combining fetch initialization with WebSocket updates:

```javascript
const initializeRealtimeData = (resourceId) => {
  return async (dispatch) => {
    // Initial fetch
    dispatch({ type: 'FETCH_RESOURCE_REQUEST' });
    
    try {
      const response = await fetch(`/api/resources/${resourceId}`);
      const data = await response.json();
      
      dispatch({
        type: 'FETCH_RESOURCE_SUCCESS',
        payload: data
      });
      
      // Establish WebSocket for updates
      const ws = new WebSocket(`wss://api.example.com/resources/${resourceId}`);
      
      ws.onmessage = (event) => {
        const update = JSON.parse(event.data);
        dispatch({
          type: 'RESOURCE_UPDATE',
          payload: update
        });
      };
      
      ws.onerror = () => {
        dispatch({ type: 'WEBSOCKET_ERROR' });
      };
      
      // Store WebSocket reference for cleanup
      dispatch({
        type: 'WEBSOCKET_CONNECTED',
        payload: { resourceId, ws }
      });
    } catch (error) {
      dispatch({
        type: 'FETCH_RESOURCE_FAILURE',
        payload: error.message
      });
    }
  };
};
```

---

