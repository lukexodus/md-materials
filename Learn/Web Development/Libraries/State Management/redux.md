# redux

## What is Redux?

**Redux** is a predictable state container for JavaScript applications. It helps you manage application state in a consistent, centralized way that makes your app's behavior predictable and easier to debug.

**Think of it as**: A single source of truth for all your application data, with strict rules about how that data can change.

**Key principle**: All application state lives in one place (the store), and the only way to change it is by dispatching actions that describe what happened.

## Why Use Redux?

### Problems Redux Solves

**Without Redux**, managing state in large applications gets messy:

```javascript
// Component A
const [user, setUser] = useState(null);

// Component B (deep in tree) needs user
// Must pass through C, D, E as props (prop drilling)
<C user={user}>
  <D user={user}>
    <E user={user}>
      <F user={user} /> // Finally uses it!
```

**With Redux**, any component can access state directly:

```javascript
// Component F - anywhere in tree
const user = useSelector(state => state.user);
```

### When to Use Redux

**Use Redux when**:
- Multiple components need the same state
- State needs to be accessible from many places
- Complex state update logic
- You need time-travel debugging
- State updates follow specific patterns

**Don't use Redux when**:
- Simple app with minimal shared state
- State is only used locally in one component
- You're just starting - add it when you need it

## Core Concepts

Redux has three fundamental concepts that work together.

### Store

The **store** holds your entire application state in a single JavaScript object.

```javascript
// Example store state
{
  user: {
    name: 'John',
    email: 'john@example.com',
    loggedIn: true
  },
  todos: [
    { id: 1, text: 'Learn Redux', completed: false },
    { id: 2, text: 'Build app', completed: false }
  ],
  ui: {
    theme: 'dark',
    sidebarOpen: true
  }
}
```

**Key points**:
- Only ONE store per application
- Read-only - cannot be modified directly
- Plain JavaScript object - no special classes

### Actions

**Actions** are plain JavaScript objects that describe something that happened in your app. They are the only way to trigger a state change.

```javascript
// Action structure
{
  type: 'ADD_TODO',        // Required: describes what happened
  payload: 'Learn Redux'   // Optional: additional data
}
```

**Action examples**:

```javascript
// User clicked login button
{ type: 'LOGIN_REQUEST', payload: { username: 'john', password: 'secret' } }

// API returned user data
{ type: 'LOGIN_SUCCESS', payload: { id: 1, name: 'John' } }

// User clicked increment
{ type: 'INCREMENT' }

// User deleted item
{ type: 'DELETE_TODO', payload: { id: 5 } }
```

**Action types** are usually string constants:

```javascript
// constants/actionTypes.js
export const ADD_TODO = 'ADD_TODO';
export const DELETE_TODO = 'DELETE_TODO';
export const TOGGLE_TODO = 'TOGGLE_TODO';

// Usage
{ type: ADD_TODO, payload: 'Learn Redux' }
```

### Action Creators

**Action creators** are functions that create and return actions. They make dispatching actions easier and more maintainable.

```javascript
// Without action creator
dispatch({ type: 'ADD_TODO', payload: 'Learn Redux' });

// With action creator
const addTodo = (text) => ({
  type: 'ADD_TODO',
  payload: text
});

dispatch(addTodo('Learn Redux'));
```

**Benefits**:
- Reusable
- Easier to test
- Centralized action creation logic
- Can add validation or processing

```javascript
// actions/todoActions.js
export const addTodo = (text) => {
  if (!text || text.trim() === '') {
    console.warn('Cannot add empty todo');
    return { type: 'NOOP' };
  }
  
  return {
    type: 'ADD_TODO',
    payload: {
      id: Date.now(),
      text: text.trim(),
      completed: false
    }
  };
};

export const deleteTodo = (id) => ({
  type: 'DELETE_TODO',
  payload: id
});

export const toggleTodo = (id) => ({
  type: 'TOGGLE_TODO',
  payload: id
});
```

### Reducers

**Reducers** are pure functions that take the current state and an action, then return a new state.

```javascript
// Reducer signature
(previousState, action) => newState
```

**Simple reducer example**:

```javascript
const counterReducer = (state = 0, action) => {
  switch (action.type) {
    case 'INCREMENT':
      return state + 1;
    case 'DECREMENT':
      return state - 1;
    case 'INCREMENT_BY':
      return state + action.payload;
    default:
      return state;  // ALWAYS return current state for unknown actions
  }
};
```

**More complex reducer**:

```javascript
const initialState = {
  todos: [],
  filter: 'ALL'
};

const todoReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'ADD_TODO':
      return {
        ...state,
        todos: [...state.todos, action.payload]
      };
      
    case 'DELETE_TODO':
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.payload)
      };
      
    case 'TOGGLE_TODO':
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      };
      
    case 'SET_FILTER':
      return {
        ...state,
        filter: action.payload
      };
      
    default:
      return state;
  }
};
```

**Reducer rules** (must follow these):

1. **Pure functions**: Same inputs always produce same output
2. **No side effects**: No API calls, no mutations, no random values
3. **No mutations**: Never modify state directly, always return new object
4. **Return state for default case**: Unknown actions should return unchanged state

```javascript
// ❌ WRONG - Mutating state
case 'ADD_TODO':
  state.todos.push(action.payload);  // Mutates state!
  return state;

// ✅ CORRECT - Creating new state
case 'ADD_TODO':
  return {
    ...state,
    todos: [...state.todos, action.payload]
  };

// ❌ WRONG - Side effect
case 'FETCH_USER':
  fetch('/api/user').then(/* ... */);  // Side effect!
  return state;

// ✅ CORRECT - No side effects
case 'FETCH_USER_SUCCESS':
  return {
    ...state,
    user: action.payload
  };
```

### Combining Reducers

For larger apps, split reducers by feature using `combineReducers`:

```javascript
import { combineReducers } from 'redux';

// Feature reducers
const userReducer = (state = null, action) => {
  switch (action.type) {
    case 'LOGIN_SUCCESS':
      return action.payload;
    case 'LOGOUT':
      return null;
    default:
      return state;
  }
};

const todosReducer = (state = [], action) => {
  switch (action.type) {
    case 'ADD_TODO':
      return [...state, action.payload];
    case 'DELETE_TODO':
      return state.filter(todo => todo.id !== action.payload);
    default:
      return state;
  }
};

const uiReducer = (state = { theme: 'light' }, action) => {
  switch (action.type) {
    case 'SET_THEME':
      return { ...state, theme: action.payload };
    default:
      return state;
  }
};

// Combine into root reducer
const rootReducer = combineReducers({
  user: userReducer,
  todos: todosReducer,
  ui: uiReducer
});

export default rootReducer;
```

**Resulting state shape**:

```javascript
{
  user: null,           // from userReducer
  todos: [],            // from todosReducer
  ui: { theme: 'light' } // from uiReducer
}
```

### Dispatch

**Dispatch** is a function that sends actions to the store, triggering the reducer to update state.

```javascript
store.dispatch({ type: 'INCREMENT' });
store.dispatch(addTodo('Learn Redux'));
```

## Creating a Store

Use `createStore()` to create the Redux store:

```javascript
import { createStore } from 'redux';

// Simple store
const store = createStore(counterReducer);

// Store with combined reducers
const store = createStore(rootReducer);

// Store with initial state
const initialState = { count: 10 };
const store = createStore(counterReducer, initialState);
```

**Store API**:

```javascript
// Get current state
const state = store.getState();

// Dispatch an action
store.dispatch({ type: 'INCREMENT' });

// Subscribe to changes
const unsubscribe = store.subscribe(() => {
  console.log('State changed:', store.getState());
});

// Unsubscribe later
unsubscribe();
```

## Complete Example (Vanilla Redux)

```javascript
// 1. ACTION TYPES
const ADD_TODO = 'ADD_TODO';
const TOGGLE_TODO = 'TOGGLE_TODO';
const SET_FILTER = 'SET_FILTER';

// 2. ACTION CREATORS
const addTodo = (text) => ({
  type: ADD_TODO,
  payload: {
    id: Date.now(),
    text,
    completed: false
  }
});

const toggleTodo = (id) => ({
  type: TOGGLE_TODO,
  payload: id
});

const setFilter = (filter) => ({
  type: SET_FILTER,
  payload: filter
});

// 3. REDUCER
const initialState = {
  todos: [],
  filter: 'ALL'
};

const todoApp = (state = initialState, action) => {
  switch (action.type) {
    case ADD_TODO:
      return {
        ...state,
        todos: [...state.todos, action.payload]
      };
      
    case TOGGLE_TODO:
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      };
      
    case SET_FILTER:
      return {
        ...state,
        filter: action.payload
      };
      
    default:
      return state;
  }
};

// 4. CREATE STORE
import { createStore } from 'redux';
const store = createStore(todoApp);

// 5. SUBSCRIBE TO CHANGES
store.subscribe(() => {
  console.log('Current state:', store.getState());
});

// 6. DISPATCH ACTIONS
store.dispatch(addTodo('Learn Redux'));
store.dispatch(addTodo('Build an app'));
store.dispatch(toggleTodo(store.getState().todos[0].id));
store.dispatch(setFilter('COMPLETED'));

// Current state:
// {
//   todos: [
//     { id: 1234, text: 'Learn Redux', completed: true },
//     { id: 5678, text: 'Build an app', completed: false }
//   ],
//   filter: 'COMPLETED'
// }
```

## Middleware

**Middleware** provides a way to extend Redux with custom functionality. It sits between dispatching an action and the moment it reaches the reducer.

**Common use cases**:
- Logging
- Crash reporting
- Async API calls
- Routing

```javascript
import { createStore, applyMiddleware } from 'redux';

// Simple logger middleware
const logger = store => next => action => {
  console.log('Dispatching:', action);
  const result = next(action);
  console.log('Next state:', store.getState());
  return result;
};

const store = createStore(
  rootReducer,
  applyMiddleware(logger)
);
```

**Middleware signature**:

```javascript
const middleware = store => next => action => {
  // Before reducer
  console.log('Before:', action);
  
  // Pass action to next middleware or reducer
  const result = next(action);
  
  // After reducer
  console.log('After:', store.getState());
  
  return result;
};
```

### Popular Middleware

#### Redux Thunk

Allows action creators to return functions instead of actions, enabling async logic:

```javascript
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';

const store = createStore(rootReducer, applyMiddleware(thunk));

// Async action creator (returns function, not object)
const fetchUser = (userId) => {
  return async (dispatch, getState) => {
    dispatch({ type: 'FETCH_USER_REQUEST' });
    
    try {
      const response = await fetch(`/api/users/${userId}`);
      const user = await response.json();
      dispatch({ type: 'FETCH_USER_SUCCESS', payload: user });
    } catch (error) {
      dispatch({ type: 'FETCH_USER_FAILURE', payload: error.message });
    }
  };
};

// Usage
store.dispatch(fetchUser(123));
```

#### Redux Logger

Logs every action and state change:

```javascript
import { createStore, applyMiddleware } from 'redux';
import logger from 'redux-logger';

const store = createStore(rootReducer, applyMiddleware(logger));
```

#### Multiple Middleware

```javascript
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import logger from 'redux-logger';

const store = createStore(
  rootReducer,
  applyMiddleware(thunk, logger)  // Order matters!
);
```

## Store Enhancers

**Enhancers** are higher-order functions that add capabilities to the store. Middleware is applied via the `applyMiddleware` enhancer.

```javascript
import { createStore, applyMiddleware, compose } from 'redux';

// Combine multiple enhancers
const enhancer = compose(
  applyMiddleware(thunk, logger),
  // Other enhancers...
);

const store = createStore(rootReducer, enhancer);
```

### Redux DevTools

The Redux DevTools Extension is a powerful debugging tool:

```javascript
import { createStore, compose } from 'redux';

const composeEnhancers = 
  window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

const store = createStore(
  rootReducer,
  composeEnhancers(
    applyMiddleware(thunk, logger)
  )
);
```

**DevTools features**:
- Inspect every action and state change
- Time-travel debugging (undo/redo actions)
- Persist state across page reloads
- Export/import state
- Action replay

## Async Logic Patterns

### Using Redux Thunk

```javascript
// Action types
const FETCH_POSTS_REQUEST = 'FETCH_POSTS_REQUEST';
const FETCH_POSTS_SUCCESS = 'FETCH_POSTS_SUCCESS';
const FETCH_POSTS_FAILURE = 'FETCH_POSTS_FAILURE';

// Async action creator
const fetchPosts = () => {
  return async (dispatch, getState) => {
    dispatch({ type: FETCH_POSTS_REQUEST });
    
    try {
      const response = await fetch('/api/posts');
      const posts = await response.json();
      dispatch({ 
        type: FETCH_POSTS_SUCCESS, 
        payload: posts 
      });
    } catch (error) {
      dispatch({ 
        type: FETCH_POSTS_FAILURE, 
        payload: error.message 
      });
    }
  };
};

// Reducer
const initialState = {
  posts: [],
  loading: false,
  error: null
};

const postsReducer = (state = initialState, action) => {
  switch (action.type) {
    case FETCH_POSTS_REQUEST:
      return { ...state, loading: true, error: null };
      
    case FETCH_POSTS_SUCCESS:
      return { ...state, loading: false, posts: action.payload };
      
    case FETCH_POSTS_FAILURE:
      return { ...state, loading: false, error: action.payload };
      
    default:
      return state;
  }
};
```

### Using Redux Saga

Redux Saga uses generator functions for complex async flows:

```javascript
import { call, put, takeEvery } from 'redux-saga/effects';

// Worker saga
function* fetchPostsSaga() {
  try {
    yield put({ type: 'FETCH_POSTS_REQUEST' });
    const posts = yield call(fetch, '/api/posts');
    yield put({ type: 'FETCH_POSTS_SUCCESS', payload: posts });
  } catch (error) {
    yield put({ type: 'FETCH_POSTS_FAILURE', payload: error.message });
  }
}

// Watcher saga
function* watchFetchPosts() {
  yield takeEvery('FETCH_POSTS', fetchPostsSaga);
}

// Root saga
export default function* rootSaga() {
  yield all([
    watchFetchPosts()
  ]);
}
```

## Best Practices

### State Shape

```javascript
// ✅ GOOD - Normalized, flat structure
{
  users: {
    byId: {
      1: { id: 1, name: 'John' },
      2: { id: 2, name: 'Jane' }
    },
    allIds: [1, 2]
  },
  posts: {
    byId: {
      10: { id: 10, title: 'Post 1', authorId: 1 }
    },
    allIds: [10]
  }
}

// ❌ BAD - Nested, duplicated data
{
  users: [
    { 
      id: 1, 
      name: 'John',
      posts: [
        { id: 10, title: 'Post 1', author: { id: 1, name: 'John' } }
      ]
    }
  ]
}
```

### Reducer Composition

Split large reducers into smaller, focused ones:

```javascript
// todos/todosReducer.js
const todosReducer = (state = [], action) => {
  switch (action.type) {
    case 'ADD_TODO':
      return [...state, todoReducer(undefined, action)];
    case 'TOGGLE_TODO':
    case 'EDIT_TODO':
      return state.map(todo => todoReducer(todo, action));
    default:
      return state;
  }
};

// Single todo reducer
const todoReducer = (state, action) => {
  switch (action.type) {
    case 'ADD_TODO':
      return {
        id: action.payload.id,
        text: action.payload.text,
        completed: false
      };
    case 'TOGGLE_TODO':
      if (state.id !== action.payload) return state;
      return { ...state, completed: !state.completed };
    default:
      return state;
  }
};
```

### Action Structure

Follow Flux Standard Action (FSA) format:

```javascript
// ✅ FSA-compliant
{
  type: 'ADD_TODO',
  payload: { text: 'Learn Redux' }
}

{
  type: 'FETCH_ERROR',
  payload: new Error('Network failed'),
  error: true
}

{
  type: 'UPDATE_USER',
  payload: { id: 1, name: 'John' },
  meta: { timestamp: Date.now() }
}

// ❌ Not FSA-compliant
{
  type: 'ADD_TODO',
  text: 'Learn Redux',  // Should be in payload
  id: 123
}
```

### Folder Structure

```
src/
  store/
    index.js              // Store creation
  features/
    todos/
      todosSlice.js       // Actions + reducer
      TodoList.js         // Components
    users/
      usersSlice.js
      UserProfile.js
  app/
    App.js
    rootReducer.js        // Combine all reducers
```

## Redux Toolkit (Modern Redux)

**Redux Toolkit** is the official, recommended way to write Redux. It simplifies Redux dramatically.

```bash
npm install @reduxjs/toolkit
```

### Creating a Slice

A "slice" is a collection of reducer logic and actions for a single feature:

```javascript
import { createSlice } from '@reduxjs/toolkit';

const todosSlice = createSlice({
  name: 'todos',
  initialState: [],
  reducers: {
    addTodo: (state, action) => {
      // "Mutating" code works thanks to Immer!
      state.push({
        id: Date.now(),
        text: action.payload,
        completed: false
      });
    },
    toggleTodo: (state, action) => {
      const todo = state.find(t => t.id === action.payload);
      if (todo) {
        todo.completed = !todo.completed;
      }
    },
    deleteTodo: (state, action) => {
      return state.filter(t => t.id !== action.payload);
    }
  }
});

// Auto-generated action creators
export const { addTodo, toggleTodo, deleteTodo } = todosSlice.actions;

// Export reducer
export default todosSlice.reducer;
```

### Configuring the Store

```javascript
import { configureStore } from '@reduxjs/toolkit';
import todosReducer from './features/todos/todosSlice';
import userReducer from './features/users/userSlice';

const store = configureStore({
  reducer: {
    todos: todosReducer,
    user: userReducer
  }
  // DevTools, thunk, and immutability checks included automatically!
});

export default store;
```

### Async Logic with createAsyncThunk

```javascript
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

// Async thunk
export const fetchPosts = createAsyncThunk(
  'posts/fetchPosts',
  async (userId) => {
    const response = await fetch(`/api/posts?userId=${userId}`);
    return response.json();
  }
);

const postsSlice = createSlice({
  name: 'posts',
  initialState: {
    posts: [],
    status: 'idle',  // 'idle' | 'loading' | 'succeeded' | 'failed'
    error: null
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchPosts.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(fetchPosts.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.posts = action.payload;
      })
      .addCase(fetchPosts.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message;
      });
  }
});

export default postsSlice.reducer;

// Usage
dispatch(fetchPosts(123));
```

### Redux Toolkit Benefits

**Compared to vanilla Redux**:

```javascript
// VANILLA REDUX - ~50 lines
const ADD_TODO = 'ADD_TODO';
const addTodo = (text) => ({ type: ADD_TODO, payload: text });
const todosReducer = (state = [], action) => {
  switch (action.type) {
    case ADD_TODO:
      return [...state, { id: Date.now(), text: action.payload }];
    default:
      return state;
  }
};

// REDUX TOOLKIT - ~15 lines
const todosSlice = createSlice({
  name: 'todos',
  initialState: [],
  reducers: {
    addTodo: (state, action) => {
      state.push({ id: Date.now(), text: action.payload });
    }
  }
});
```

**Features**:
- No action types needed
- No action creators needed
- No switch statements
- "Mutable" updates via Immer
- Built-in async handling
- DevTools configured automatically
- TypeScript support out of the box

## Data Flow Summary

The complete Redux data flow:

1. **User interacts** → Click button, submit form, etc.
2. **Component dispatches action** → `dispatch(addTodo('Learn Redux'))`
3. **Store runs reducer** → Reducer receives current state + action
4. **Reducer returns new state** → Pure function creates new state object
5. **Store saves new state** → State tree updated
6. **UI updates** → Components re-render with new data

```
┌─────────────┐
│     UI      │
│  Component  │
└──────┬──────┘
       │ 1. User clicks
       ↓
┌─────────────┐
│  dispatch() │
│   (action)  │
└──────┬──────┘
       │ 2. Action sent to store
       ↓
┌─────────────┐
│   Reducer   │
│ (old state, │
│   action)   │
└──────┬──────┘
       │ 3. Computes new state
       ↓
┌─────────────┐
│    Store    │
│ (new state) │
└──────┬──────┘
       │ 4. Notifies subscribers
       ↓
┌─────────────┐
│     UI      │
│  (re-render)│
└─────────────┘
```

## Common Patterns

### Loading States

```javascript
const initialState = {
  data: null,
  loading: false,
  error: null
};

// Actions: REQUEST, SUCCESS, FAILURE pattern
const dataReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'FETCH_DATA_REQUEST':
      return { ...state, loading: true, error: null };
    case 'FETCH_DATA_SUCCESS':
      return { data: action.payload, loading: false, error: null };
    case 'FETCH_DATA_FAILURE':
      return { ...state, loading: false, error: action.payload };
    default:
      return state;
  }
};
```

### Optimistic Updates

```javascript
const addTodoOptimistic = (text) => {
  return async (dispatch) => {
    const tempId = Date.now();
    
    // Optimistically add to UI
    dispatch({ 
      type: 'ADD_TODO_OPTIMISTIC', 
      payload: { id: tempId, text } 
    });
    
    try {
      const response = await fetch('/api/todos', {
        method: 'POST',
        body: JSON.stringify({ text })
      });
      const todo = await response.json();
      
      // Replace temp with real data
      dispatch({ 
        type: 'ADD_TODO_SUCCESS', 
        payload: { tempId, todo } 
      });
    } catch (error) {
      // Rollback on error
      dispatch({ 
        type: 'ADD_TODO_FAILURE', 
        payload: tempId 
      });
    }
  };
};
```

### Undo/Redo

```javascript
const undoable = (reducer) => {
  const initialState = {
    past: [],
    present: reducer(undefined, {}),
    future: []
  };
  
  return (state = initialState, action) => {
    const { past, present, future } = state;
    
    switch (action.type) {
      case 'UNDO':
        if (past.length === 0) return state;
        return {
          past: past.slice(0, -1),
          present: past[past.length - 1],
          future: [present, ...future]
        };
        
      case 'REDO':
        if (future.length === 0) return state;
        return {
          past: [...past, present],
          present: future[0],
          future: future.slice(1)
        };
        
      default:
        const newPresent = reducer(present, action);
        if (present === newPresent) return state;
        return {
          past: [...past, present],
          present: newPresent,
          future: []
        };
    }
  };
};
```

## Testing Redux

### Testing Reducers

```javascript
import todosReducer from './todosReducer';

describe('todosReducer', () => {
  it('should return initial state', () => {
    expect(todosReducer(undefined, {})).toEqual([]);
  });
  
  it('should handle ADD_TODO', () => {
    const action = {
      type: 'ADD_TODO',
      payload: { id: 1, text: 'Test', completed: false }
    };
    
    expect(todosReducer([], action)).toEqual([
      { id: 1, text: 'Test', completed: false }
    ]);
  });
  
  it('should handle TOGGLE_TODO', () => {
    const initialState = [
      { id: 1, text: 'Test', completed: false }
    ];
    
    const action = { type: 'TOGGLE_TODO', payload: 1 };
    
    expect(todosReducer(initialState, action)).toEqual([
      { id: 1, text: 'Test', completed: true }
    ]);
  });
});
```

### Testing Action Creators

```javascript
import { addTodo } from './actions';

describe('addTodo', () => {
  it('should create an action to add a todo', () => {
    const text = 'Test todo';
    const expectedAction = {
      type: 'ADD_TODO',
      payload: { text, id: expect.any(Number), completed: false }
    };
    
    expect(addTodo(text)).toMatchObject(expectedAction);
  });
});
```

### Testing Async Actions (with Thunk)

```javascript
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import { fetchPosts } from './actions';

const middlewares = [thunk];
const mockStore = configureMockStore(middlewares);

describe('async actions', () => {
  it('creates FETCH_POSTS_SUCCESS when fetching posts', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve([{ id: 1, title: 'Post 1' }])
      })
    );
    
    const expectedActions = [
      { type: 'FETCH_POSTS_REQUEST' },
      { type: 'FETCH_POSTS_SUCCESS', payload: [{ id: 1, title: 'Post 1' }] }
    ];
    
    const store = mockStore({ posts: [] });
    await store.dispatch(fetchPosts());
    
    expect(store.getActions()).toEqual(expectedActions);
  });
});
```

## Performance Optimization

### Selector Memoization

Use Reselect to avoid expensive recalculations:

```javascript
import { createSelector } from 'reselect';

const getTodos = state => state.todos;
const getFilter = state => state.filter;

// This only recalculates when todos or filter changes
const getVisibleTodos = createSelector(
  [getTodos, getFilter],
  (todos, filter) => {
    switch (filter) {
      case 'COMPLETED':
        return todos.filter(t => t.completed);
      case 'ACTIVE':
        return todos.filter(t => !t.completed);
      default:
        return todos;
    }
  }
);
```

### Normalizing State

```javascript
// Before normalization
{
  posts: [
    { id: 1, author: { id: 5, name: 'John' }, comments: [...] }
  ]
}

// After normalization
{
  posts: {
    byId: { 1: { id: 1, authorId: 5, commentIds: [10, 11] } },
    allIds: [1]
  },
  users: {
    byId: { 5: { id: 5, name: 'John' } },
    allIds: [5]
  },
  comments: {
    byId: { 10: {...}, 11: {...} },
    allIds: [10, 11]
  }
}
```

Use `normalizr` library for automatic normalization:

```javascript
import { normalize, schema } from 'normalizr';

const user = new schema.Entity('users');
const comment = new schema.Entity('comments');
const post = new schema.Entity('posts', {
  author: user,
  comments: [comment]
});

const normalizedData = normalize(originalData, [post]);
```

## Summary

**Redux in a nutshell**:

- **Single source of truth**: One store holds all state
- **State is read-only**: Only way to change is dispatch actions
- **Changes via pure functions**: Reducers compute new state
- **Predictable**: Same actions + state = same result
- **Debuggable**: Time-travel, action history, state inspection

**When to use**: Shared state across many components, complex state logic, need for debugging tools

**Modern approach**: Use Redux Toolkit for 70% less boilerplate and better developer experience

---

# Redux Thunk

Redux Thunk is a middleware library for Redux that allows you to write action creators that return functions instead of plain action objects. This enables handling of asynchronous logic in Redux applications.

## Core Concept

In standard Redux, action creators return plain objects:

```javascript
// Standard action creator
const increment = () => ({
  type: 'INCREMENT'
});
```

With Redux Thunk, action creators can return functions:

```javascript
// Thunk action creator
const incrementAsync = () => {
  return (dispatch, getState) => {
    setTimeout(() => {
      dispatch({ type: 'INCREMENT' });
    }, 1000);
  };
};
```

## How It Works

Redux Thunk intercepts actions. When it receives a function instead of an object, it calls that function with `dispatch` and `getState` as arguments. This allows the function to:

- Dispatch multiple actions
- Access current state
- Perform asynchronous operations
- Conditionally dispatch based on state

## Installation

```bash
npm install redux-thunk
```

## Basic Setup

```javascript
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import rootReducer from './reducers';

const store = createStore(
  rootReducer,
  applyMiddleware(thunk)
);
```

With Redux Toolkit (modern approach):

```javascript
import { configureStore } from '@reduxjs/toolkit';
import rootReducer from './reducers';

const store = configureStore({
  reducer: rootReducer,
  // Thunk is included by default
});
```

## Common Use Cases

**Async API Calls:**

```javascript
const fetchUsers = () => {
  return async (dispatch) => {
    dispatch({ type: 'FETCH_USERS_REQUEST' });
    
    try {
      const response = await fetch('/api/users');
      const data = await response.json();
      dispatch({ 
        type: 'FETCH_USERS_SUCCESS', 
        payload: data 
      });
    } catch (error) {
      dispatch({ 
        type: 'FETCH_USERS_FAILURE', 
        payload: error.message 
      });
    }
  };
};
```

**Conditional Dispatching:**

```javascript
const incrementIfOdd = () => {
  return (dispatch, getState) => {
    const { counter } = getState();
    
    if (counter % 2 !== 0) {
      dispatch({ type: 'INCREMENT' });
    }
  };
};
```

**Dispatching Multiple Actions:**

```javascript
const complexOperation = () => {
  return (dispatch) => {
    dispatch({ type: 'START_OPERATION' });
    dispatch({ type: 'PROCESS_DATA' });
    dispatch({ type: 'END_OPERATION' });
  };
};
```

## Function Signature

Thunk functions receive two parameters:

- `dispatch`: Function to dispatch actions to the store
- `getState`: Function that returns current state

They can also receive a third parameter for extra arguments if configured:

```javascript
const store = createStore(
  rootReducer,
  applyMiddleware(thunk.withExtraArgument({ api }))
);

const fetchUser = (id) => {
  return (dispatch, getState, { api }) => {
    return api.fetchUser(id).then(user => {
      dispatch({ type: 'USER_LOADED', payload: user });
    });
  };
};
```

## Modern Alternatives

[Inference] Redux Toolkit's `createAsyncThunk` is commonly used as a more structured alternative to writing thunks manually. It generates action types and creators automatically.

```javascript
import { createAsyncThunk } from '@reduxjs/toolkit';

const fetchUsers = createAsyncThunk(
  'users/fetch',
  async () => {
    const response = await fetch('/api/users');
    return response.json();
  }
);
```

## Key Characteristics

- Lightweight (the library itself is very small)
- Allows any async logic in action creators
- Provides access to dispatch and state
- Returns values from thunks can be used (useful for component logic)
- [Inference] Does not provide built-in caching, request cancellation, or other advanced features that some other middleware solutions offer

---

# Redux Saga

Redux Saga is a middleware library for Redux that handles side effects (asynchronous operations, data fetching, etc.) using ES6 Generators. It provides a more powerful and testable approach to managing complex async flows compared to simpler solutions.

## Core Concept

Redux Saga uses generator functions (sagas) to manage side effects. Generators allow you to write async code that looks synchronous and can be paused and resumed.

```javascript
// Basic saga example
function* fetchUserSaga(action) {
  try {
    const user = yield call(api.fetchUser, action.payload);
    yield put({ type: 'FETCH_USER_SUCCESS', payload: user });
  } catch (error) {
    yield put({ type: 'FETCH_USER_FAILURE', payload: error.message });
  }
}
```

## How It Works

Sagas listen for dispatched actions and execute side effects in response. Instead of directly performing side effects, sagas yield "effects" - plain JavaScript objects that describe the operation. The saga middleware interprets these effects and executes them.

## Installation

```bash
npm install redux-saga
```

## Basic Setup

```javascript
import { createStore, applyMiddleware } from 'redux';
import createSagaMiddleware from 'redux-saga';
import rootReducer from './reducers';
import rootSaga from './sagas';

// Create the saga middleware
const sagaMiddleware = createSagaMiddleware();

// Mount it on the Store
const store = createStore(
  rootReducer,
  applyMiddleware(sagaMiddleware)
);

// Run the saga
sagaMiddleware.run(rootSaga);
```

## Core Effects

Redux Saga provides several effect creators:

**`call`** - Calls a function (returns a promise or value):

```javascript
const result = yield call(fetch, '/api/user');
const data = yield call([obj, obj.method], arg1, arg2);
```

**`put`** - Dispatches an action:

```javascript
yield put({ type: 'USER_LOADED', payload: user });
```

**`take`** - Waits for an action to be dispatched:

```javascript
const action = yield take('BUTTON_CLICKED');
```

**`takeEvery`** - Spawns a saga on each action:

```javascript
yield takeEvery('FETCH_USER_REQUEST', fetchUserSaga);
```

**`takeLatest`** - Cancels previous saga if still running, starts new one:

```javascript
yield takeLatest('FETCH_USER_REQUEST', fetchUserSaga);
```

**`select`** - Gets data from state:

```javascript
const user = yield select(state => state.user);
```

**`fork`** - Creates a non-blocking saga (continues without waiting):

```javascript
const task = yield fork(backgroundTask);
```

**`spawn`** - Like fork but detached (errors don't bubble up):

```javascript
yield spawn(independentTask);
```

**`cancel`** - Cancels a forked task:

```javascript
const task = yield fork(someTask);
yield cancel(task);
```

**`race`** - Runs effects in parallel, returns first to complete:

```javascript
const { result, timeout } = yield race({
  result: call(fetchData),
  timeout: delay(5000)
});
```

**`all`** - Runs effects in parallel, waits for all:

```javascript
const [users, posts] = yield all([
  call(fetchUsers),
  call(fetchPosts)
]);
```

## Common Patterns

**Basic API Call:**

```javascript
function* fetchUserSaga(action) {
  try {
    const response = yield call(api.fetchUser, action.payload.id);
    yield put({ type: 'FETCH_USER_SUCCESS', payload: response.data });
  } catch (error) {
    yield put({ type: 'FETCH_USER_FAILURE', payload: error.message });
  }
}

function* watchFetchUser() {
  yield takeEvery('FETCH_USER_REQUEST', fetchUserSaga);
}
```

**Debouncing:**

```javascript
import { delay } from 'redux-saga/effects';

function* handleSearch(action) {
  yield delay(500); // Wait 500ms
  const results = yield call(api.search, action.payload);
  yield put({ type: 'SEARCH_SUCCESS', payload: results });
}

function* watchSearch() {
  yield takeLatest('SEARCH_REQUEST', handleSearch);
}
```

**Polling:**

```javascript
function* pollData() {
  while (true) {
    try {
      const data = yield call(api.fetchData);
      yield put({ type: 'DATA_RECEIVED', payload: data });
      yield delay(5000); // Wait 5 seconds
    } catch (error) {
      yield put({ type: 'DATA_ERROR', payload: error.message });
    }
  }
}

function* watchPolling() {
  while (yield take('START_POLLING')) {
    const task = yield fork(pollData);
    yield take('STOP_POLLING');
    yield cancel(task);
  }
}
```

**Race Conditions (Timeout):**

```javascript
function* fetchWithTimeout() {
  const { response, timeout } = yield race({
    response: call(api.fetchData),
    timeout: delay(3000)
  });

  if (timeout) {
    yield put({ type: 'FETCH_TIMEOUT' });
  } else {
    yield put({ type: 'FETCH_SUCCESS', payload: response });
  }
}
```

**Sequential Async Flow:**

```javascript
function* loginFlow() {
  while (true) {
    const { username, password } = yield take('LOGIN_REQUEST');
    const token = yield call(api.login, username, password);
    yield put({ type: 'LOGIN_SUCCESS', payload: token });
    
    yield take('LOGOUT');
    yield call(api.logout, token);
    yield put({ type: 'LOGOUT_SUCCESS' });
  }
}
```

**Parallel Requests:**

```javascript
function* fetchAllData() {
  try {
    const [users, posts, comments] = yield all([
      call(api.fetchUsers),
      call(api.fetchPosts),
      call(api.fetchComments)
    ]);
    
    yield put({ 
      type: 'FETCH_ALL_SUCCESS', 
      payload: { users, posts, comments }
    });
  } catch (error) {
    yield put({ type: 'FETCH_ALL_FAILURE', payload: error.message });
  }
}
```

## Root Saga

Combine multiple watchers:

```javascript
import { all } from 'redux-saga/effects';

export default function* rootSaga() {
  yield all([
    watchFetchUser(),
    watchSearch(),
    watchPolling(),
    loginFlow()
  ]);
}
```

## Testing

[Inference] Sagas are generally considered easier to test than thunks because they yield plain objects rather than executing side effects directly:

```javascript
import { call, put } from 'redux-saga/effects';
import { fetchUserSaga } from './sagas';

test('fetchUserSaga', () => {
  const action = { type: 'FETCH_USER_REQUEST', payload: { id: 1 } };
  const generator = fetchUserSaga(action);

  // Test the call effect
  expect(generator.next().value).toEqual(call(api.fetchUser, 1));

  // Test the put effect on success
  const user = { id: 1, name: 'John' };
  expect(generator.next(user).value).toEqual(
    put({ type: 'FETCH_USER_SUCCESS', payload: user })
  );

  // Generator is done
  expect(generator.next().done).toBe(true);
});
```

## Advantages

- **Testability**: Effects are plain objects, easy to test without mocking
- **Declarative**: Code describes what should happen, not how
- **Cancellation**: Built-in task cancellation support
- **Complex flows**: Better handling of complex async sequences
- **Coordination**: Easy to coordinate multiple async operations

## Disadvantages

- **Learning curve**: Generators and saga concepts require learning
- **Bundle size**: Larger than Redux Thunk
- **Boilerplate**: [Inference] Generally requires more code setup than simpler solutions
- **Debugging**: [Inference] Generator debugging can be less straightforward than promise-based code

## Redux Saga vs Redux Thunk

**Redux Saga:**

- Uses generators
- Declarative effects
- Better for complex async flows
- Built-in cancellation and race conditions
- More testable
- Steeper learning curve

**Redux Thunk:**

- Uses plain functions
- Imperative style
- Simpler for basic async operations
- Minimal boilerplate
- Smaller bundle size
- Easier to learn

## Modern Context

[Inference] Redux Toolkit's `createAsyncThunk` and RTK Query have become popular alternatives, offering simpler APIs for common use cases. However, Redux Saga remains valuable for applications with complex async requirements like:

- Long-running processes
- Complex coordination between multiple async operations
- Scenarios requiring cancellation
- Debouncing/throttling patterns
- Polling or websocket management

---

# Flux Standard Action (FSA)

Flux Standard Action (FSA) is a convention for structuring Redux actions to ensure consistency across applications and libraries. It provides a standardized shape for action objects.

## Basic Structure

An FSA-compliant action is a plain JavaScript object with specific properties:

```javascript
{
  type: string,           // Required
  payload?: any,          // Optional
  error?: boolean,        // Optional
  meta?: any             // Optional
}
```

## Core Properties

**`type` (required):**

- Must be a string constant
- Identifies the action
- Should describe what happened

```javascript
{
  type: 'ADD_TODO'
}
```

**`payload` (optional):**

- Contains the action's data
- Can be any type (object, string, number, etc.)
- Should be serializable

```javascript
{
  type: 'ADD_TODO',
  payload: {
    id: 1,
    text: 'Learn FSA',
    completed: false
  }
}
```

**`error` (optional):**

- Boolean flag
- When `true`, `payload` should be an error object
- Indicates the action represents a failure

```javascript
{
  type: 'FETCH_USER_FAILURE',
  payload: new Error('Network request failed'),
  error: true
}
```

**`meta` (optional):**

- Contains extra information not part of the payload
- Used for metadata like timestamps, analytics, etc.

```javascript
{
  type: 'ADD_TODO',
  payload: { text: 'Learn FSA' },
  meta: {
    timestamp: Date.now(),
    source: 'mobile_app'
  }
}
```

## Rules and Constraints

1. **An action MUST be a plain JavaScript object**
2. **An action MUST have a `type` property**
3. **An action MAY have a `payload` property**
4. **An action MAY have an `error` property**
5. **An action MAY have a `meta` property**
6. **An action MUST NOT include properties other than `type`, `payload`, `error`, and `meta`**

## Examples

**Simple Action:**

```javascript
{
  type: 'INCREMENT_COUNTER'
}
```

**Action with Payload:**

```javascript
{
  type: 'SET_USER',
  payload: {
    id: 123,
    name: 'John Doe',
    email: 'john@example.com'
  }
}
```

**Error Action:**

```javascript
{
  type: 'LOGIN_FAILURE',
  payload: new Error('Invalid credentials'),
  error: true
}
```

**Action with Meta:**

```javascript
{
  type: 'TRACK_EVENT',
  payload: { event: 'button_click' },
  meta: {
    analytics: true,
    timestamp: 1234567890
  }
}
```

## Action Creators

FSA action creators follow the same pattern:

```javascript
// Simple action creator
const incrementCounter = () => ({
  type: 'INCREMENT_COUNTER'
});

// Action creator with payload
const addTodo = (text) => ({
  type: 'ADD_TODO',
  payload: {
    id: Date.now(),
    text,
    completed: false
  }
});

// Error action creator
const fetchUserFailure = (error) => ({
  type: 'FETCH_USER_FAILURE',
  payload: error,
  error: true
});

// Action creator with meta
const logEvent = (eventName) => ({
  type: 'LOG_EVENT',
  payload: { event: eventName },
  meta: {
    timestamp: Date.now()
  }
});
```

## Async Actions Pattern

FSA works well with async action patterns:

```javascript
// Request action
{
  type: 'FETCH_USER_REQUEST',
  meta: { userId: 123 }
}

// Success action
{
  type: 'FETCH_USER_SUCCESS',
  payload: { id: 123, name: 'John' },
  meta: { userId: 123 }
}

// Failure action
{
  type: 'FETCH_USER_FAILURE',
  payload: new Error('Not found'),
  error: true,
  meta: { userId: 123 }
}
```

## Reducer Handling

Reducers can handle FSA actions consistently:

```javascript
const userReducer = (state = initialState, action) => {
  switch (action.type) {
    case 'FETCH_USER_REQUEST':
      return {
        ...state,
        loading: true,
        error: null
      };
      
    case 'FETCH_USER_SUCCESS':
      return {
        ...state,
        loading: false,
        data: action.payload,
        error: null
      };
      
    case 'FETCH_USER_FAILURE':
      return {
        ...state,
        loading: false,
        error: action.payload // Error object
      };
      
    default:
      return state;
  }
};
```

## Helper Libraries

**redux-actions:**

A library that provides utilities for creating FSA-compliant actions:

```javascript
import { createAction } from 'redux-actions';

// Creates FSA-compliant action creator
const addTodo = createAction('ADD_TODO');

addTodo({ text: 'Learn FSA' });
// Returns: { type: 'ADD_TODO', payload: { text: 'Learn FSA' } }

// With payload transformer
const addTodo = createAction(
  'ADD_TODO',
  (text) => ({ text, id: Date.now() })
);

// With meta creator
const addTodo = createAction(
  'ADD_TODO',
  (text) => ({ text }),
  () => ({ timestamp: Date.now() })
);
```

**Handling reducers with redux-actions:**

```javascript
import { handleActions } from 'redux-actions';

const reducer = handleActions(
  {
    ADD_TODO: (state, action) => ({
      ...state,
      todos: [...state.todos, action.payload]
    }),
    
    FETCH_USER_SUCCESS: (state, action) => ({
      ...state,
      user: action.payload
    }),
    
    FETCH_USER_FAILURE: (state, action) => ({
      ...state,
      error: action.payload
    })
  },
  initialState
);
```

## Benefits

1. **Consistency**: All actions follow the same structure
2. **Predictability**: Reducers can rely on standard shape
3. **Interoperability**: Libraries can work with FSA actions
4. **Error handling**: Standard way to represent errors
5. **Type safety**: Easier to add TypeScript types
6. **Documentation**: Self-documenting action structure

## TypeScript Support

FSA works well with TypeScript:

```typescript
interface Action<P = any> {
  type: string;
  payload?: P;
  error?: boolean;
  meta?: any;
}

// Specific action type
interface AddTodoAction extends Action<{ text: string }> {
  type: 'ADD_TODO';
}

// Action creator with type safety
const addTodo = (text: string): AddTodoAction => ({
  type: 'ADD_TODO',
  payload: { text }
});
```

## Common Patterns

**Normalized Payloads:**

```javascript
{
  type: 'RECEIVE_USERS',
  payload: {
    entities: {
      users: {
        1: { id: 1, name: 'John' },
        2: { id: 2, name: 'Jane' }
      }
    },
    result: [1, 2]
  }
}
```

**Optimistic Updates:**

```javascript
{
  type: 'UPDATE_TODO',
  payload: { id: 1, completed: true },
  meta: {
    optimistic: true,
    rollback: { id: 1, completed: false }
  }
}
```

## Validation

[Inference] You can validate FSA compliance:

```javascript
const isFSA = (action) => {
  return (
    typeof action === 'object' &&
    action !== null &&
    typeof action.type === 'string' &&
    Object.keys(action).every(key => 
      ['type', 'payload', 'error', 'meta'].includes(key)
    )
  );
};
```

## Modern Context

[Inference] While FSA remains a useful convention, Redux Toolkit's `createSlice` and `createAsyncThunk` generate FSA-compliant actions by default, making manual adherence to FSA less critical in modern Redux applications. However, understanding FSA is still valuable for:

- Working with legacy Redux codebases
- Building Redux middleware
- Creating reusable Redux libraries
- Understanding Redux best practices

---

# Redux-Actions

Redux-Actions is a library that provides utilities for creating and handling Flux Standard Actions (FSA) in Redux applications. It reduces boilerplate and ensures action consistency.

## Installation

```bash
npm install redux-actions
```

## Core Functions

### `createAction()`

Creates FSA-compliant action creators.

**Basic Usage:**

```javascript
import { createAction } from 'redux-actions';

const increment = createAction('INCREMENT');

increment();
// Returns: { type: 'INCREMENT' }
```

**With Payload:**

```javascript
const addTodo = createAction('ADD_TODO');

addTodo({ text: 'Learn Redux' });
// Returns: { type: 'ADD_TODO', payload: { text: 'Learn Redux' } }
```

**Payload Creator (Transform Function):**

The second argument transforms the input:

```javascript
const addTodo = createAction(
  'ADD_TODO',
  (text) => ({ id: Date.now(), text, completed: false })
);

addTodo('Learn Redux');
// Returns: {
//   type: 'ADD_TODO',
//   payload: { id: 1234567890, text: 'Learn Redux', completed: false }
// }
```

**Meta Creator:**

The third argument adds metadata:

```javascript
const addTodo = createAction(
  'ADD_TODO',
  (text) => ({ text }), // Payload creator
  (text) => ({ timestamp: Date.now() }) // Meta creator
);

addTodo('Learn Redux');
// Returns: {
//   type: 'ADD_TODO',
//   payload: { text: 'Learn Redux' },
//   meta: { timestamp: 1234567890 }
// }
```

**Identity Payload Creator:**

If no payload creator is provided, the first argument becomes the payload:

```javascript
const setUser = createAction('SET_USER');

setUser({ id: 1, name: 'John' });
// Returns: {
//   type: 'SET_USER',
//   payload: { id: 1, name: 'John' }
// }
```

**Multiple Arguments:**

```javascript
const addTodo = createAction(
  'ADD_TODO',
  (text, priority) => ({ text, priority })
);

addTodo('Learn Redux', 'high');
// Returns: {
//   type: 'ADD_TODO',
//   payload: { text: 'Learn Redux', priority: 'high' }
// }
```

### `createActions()`

Creates multiple action creators at once:

```javascript
import { createActions } from 'redux-actions';

const { increment, decrement, addTodo } = createActions({
  INCREMENT: undefined, // No payload
  DECREMENT: undefined,
  ADD_TODO: (text) => ({ text, id: Date.now() })
});

increment();
// Returns: { type: 'INCREMENT' }

addTodo('Learn Redux');
// Returns: { type: 'ADD_TODO', payload: { text: 'Learn Redux', id: 1234567890 } }
```

**Shorthand Notation:**

```javascript
const { increment, decrement } = createActions(
  'INCREMENT',
  'DECREMENT'
);
```

**Nested Actions:**

```javascript
const { app: { init, reset }, user: { login, logout } } = createActions({
  APP: {
    INIT: undefined,
    RESET: undefined
  },
  USER: {
    LOGIN: (credentials) => credentials,
    LOGOUT: undefined
  }
});

init();
// Returns: { type: 'APP/INIT' }

login({ username: 'john', password: 'secret' });
// Returns: { type: 'USER/LOGIN', payload: { username: 'john', password: 'secret' } }
```

### `handleAction()`

Creates a reducer that handles a single action type:

```javascript
import { handleAction } from 'redux-actions';

const increment = createAction('INCREMENT');

const counterReducer = handleAction(
  increment,
  (state, action) => state + 1,
  0 // Initial state
);
```

**With Next and Throw:**

Separate handlers for success and error actions:

```javascript
const fetchUser = createAction('FETCH_USER');

const userReducer = handleAction(
  fetchUser,
  {
    next: (state, action) => ({
      ...state,
      data: action.payload,
      error: null
    }),
    throw: (state, action) => ({
      ...state,
      error: action.payload
    })
  },
  { data: null, error: null }
);
```

### `handleActions()`

Creates a reducer that handles multiple action types:

```javascript
import { handleActions } from 'redux-actions';

const increment = createAction('INCREMENT');
const decrement = createAction('DECREMENT');
const reset = createAction('RESET');

const counterReducer = handleActions(
  {
    [increment]: (state) => state + 1,
    [decrement]: (state) => state - 1,
    [reset]: () => 0
  },
  0 // Initial state
);
```

**Complete Example:**

```javascript
const addTodo = createAction('ADD_TODO');
const removeTodo = createAction('REMOVE_TODO');
const toggleTodo = createAction('TOGGLE_TODO');

const todosReducer = handleActions(
  {
    [addTodo]: (state, action) => [
      ...state,
      action.payload
    ],
    
    [removeTodo]: (state, action) => 
      state.filter(todo => todo.id !== action.payload),
    
    [toggleTodo]: (state, action) =>
      state.map(todo =>
        todo.id === action.payload
          ? { ...todo, completed: !todo.completed }
          : todo
      )
  },
  [] // Initial state
);
```

**Nested Reducer Maps:**

```javascript
const todosReducer = handleActions(
  {
    ADD_TODO: (state, action) => [...state, action.payload],
    
    REMOVE_TODO: (state, action) => 
      state.filter(todo => todo.id !== action.payload),
    
    'FETCH_TODOS_REQUEST': (state) => state,
    
    'FETCH_TODOS_SUCCESS': {
      next: (state, action) => action.payload,
      throw: (state) => state
    }
  },
  []
);
```

### `combineActions()`

Combines multiple action types to be handled by the same reducer function:

```javascript
import { combineActions } from 'redux-actions';

const increment = createAction('INCREMENT');
const decrement = createAction('DECREMENT');
const reset = createAction('RESET');

const counterReducer = handleActions(
  {
    [combineActions(increment, decrement)]: (state, action) => {
      // Handle both increment and decrement
      return action.type === 'INCREMENT' ? state + 1 : state - 1;
    },
    
    [reset]: () => 0
  },
  0
);
```

**Multiple Actions Same Handler:**

```javascript
const startLoading = createAction('START_LOADING');
const fetchData = createAction('FETCH_DATA');
const submitForm = createAction('SUBMIT_FORM');

const loadingReducer = handleActions(
  {
    [combineActions(startLoading, fetchData, submitForm)]: () => true,
    
    [combineActions('STOP_LOADING', 'DATA_RECEIVED', 'FORM_SUBMITTED')]: () => false
  },
  false
);
```

## Practical Examples

### Complete Todo Application

```javascript
import { createActions, handleActions, combineActions } from 'redux-actions';

// Action Creators
export const {
  addTodo,
  removeTodo,
  toggleTodo,
  editTodo,
  setFilter
} = createActions({
  ADD_TODO: (text) => ({
    id: Date.now(),
    text,
    completed: false
  }),
  
  REMOVE_TODO: (id) => id,
  
  TOGGLE_TODO: (id) => id,
  
  EDIT_TODO: (id, text) => ({ id, text }),
  
  SET_FILTER: (filter) => filter
});

// Todos Reducer
const todosReducer = handleActions(
  {
    [addTodo]: (state, action) => [...state, action.payload],
    
    [removeTodo]: (state, action) =>
      state.filter(todo => todo.id !== action.payload),
    
    [toggleTodo]: (state, action) =>
      state.map(todo =>
        todo.id === action.payload
          ? { ...todo, completed: !todo.completed }
          : todo
      ),
    
    [editTodo]: (state, action) =>
      state.map(todo =>
        todo.id === action.payload.id
          ? { ...todo, text: action.payload.text }
          : todo
      )
  },
  []
);

// Filter Reducer
const filterReducer = handleActions(
  {
    [setFilter]: (state, action) => action.payload
  },
  'SHOW_ALL'
);
```

### Async Actions Pattern

```javascript
import { createAction, handleActions } from 'redux-actions';

// Action creators
const fetchUserRequest = createAction('FETCH_USER_REQUEST');
const fetchUserSuccess = createAction('FETCH_USER_SUCCESS');
const fetchUserFailure = createAction('FETCH_USER_FAILURE');

// Thunk action creator
const fetchUser = (userId) => async (dispatch) => {
  dispatch(fetchUserRequest());
  
  try {
    const response = await fetch(`/api/users/${userId}`);
    const data = await response.json();
    dispatch(fetchUserSuccess(data));
  } catch (error) {
    dispatch(fetchUserFailure(error.message));
  }
};

// Reducer
const userReducer = handleActions(
  {
    [fetchUserRequest]: (state) => ({
      ...state,
      loading: true,
      error: null
    }),
    
    [fetchUserSuccess]: (state, action) => ({
      ...state,
      loading: false,
      data: action.payload,
      error: null
    }),
    
    [fetchUserFailure]: (state, action) => ({
      ...state,
      loading: false,
      error: action.payload
    })
  },
  {
    loading: false,
    data: null,
    error: null
  }
);
```

### Error Handling

```javascript
const saveData = createAction(
  'SAVE_DATA',
  (data) => data,
  (data, error) => {
    if (error) {
      return { error: true };
    }
    return { timestamp: Date.now() };
  }
);

const dataReducer = handleActions(
  {
    [saveData]: {
      next: (state, action) => ({
        ...state,
        data: action.payload,
        lastSaved: action.meta.timestamp
      }),
      
      throw: (state, action) => ({
        ...state,
        error: action.payload
      })
    }
  },
  { data: null, error: null, lastSaved: null }
);
```

## TypeScript Support

```typescript
import { createAction, handleActions, Action } from 'redux-actions';

// Define payload types
interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

// Typed action creators
const addTodo = createAction<Todo>('ADD_TODO');
const removeTodo = createAction<number>('REMOVE_TODO');
const toggleTodo = createAction<number>('TOGGLE_TODO');

// Typed reducer
interface TodosState {
  items: Todo[];
}

const initialState: TodosState = {
  items: []
};

const todosReducer = handleActions<TodosState, any>(
  {
    [addTodo.toString()]: (state, action: Action<Todo>) => ({
      ...state,
      items: [...state.items, action.payload]
    }),
    
    [removeTodo.toString()]: (state, action: Action<number>) => ({
      ...state,
      items: state.items.filter(todo => todo.id !== action.payload)
    })
  },
  initialState
);
```

## Best Practices

**1. Use Action Creators Consistently:**

```javascript
// Good
const addTodo = createAction('ADD_TODO', (text) => ({ text }));
dispatch(addTodo('Learn Redux'));

// Avoid
dispatch({ type: 'ADD_TODO', payload: { text: 'Learn Redux' } });
```

**2. Keep Payload Creators Pure:**

```javascript
// Good - deterministic
const addTodo = createAction('ADD_TODO', (text, id) => ({ text, id }));

// Avoid - non-deterministic
const addTodo = createAction('ADD_TODO', (text) => ({ 
  text, 
  id: Date.now() // Side effect in action creator
}));
```

**3. Use combineActions for Shared Logic:**

```javascript
const loadingReducer = handleActions({
  [combineActions(
    'FETCH_START',
    'SAVE_START',
    'DELETE_START'
  )]: () => true,
  
  [combineActions(
    'FETCH_COMPLETE',
    'SAVE_COMPLETE',
    'DELETE_COMPLETE'
  )]: () => false
}, false);
```

**4. Organize Actions by Domain:**

```javascript
// actions/todos.js
export const { addTodo, removeTodo, toggleTodo } = createActions({
  ADD_TODO: (text) => ({ text }),
  REMOVE_TODO: (id) => id,
  TOGGLE_TODO: (id) => id
});

// actions/user.js
export const { login, logout, updateProfile } = createActions({
  LOGIN: (credentials) => credentials,
  LOGOUT: undefined,
  UPDATE_PROFILE: (data) => data
});
```

## Advantages

1. **Less boilerplate**: Reduces repetitive action creator code
2. **FSA compliance**: Ensures all actions follow FSA standard
3. **Type safety**: Works well with TypeScript
4. **Consistency**: Standardized action and reducer patterns
5. **Readability**: Cleaner, more declarative code

## Limitations

1. **Learning curve**: Additional API to learn
2. **Magic strings**: [Inference] Action type constants as strings can make refactoring harder
3. **Bundle size**: Adds dependency to your project
4. **Less explicit**: [Inference] May be less obvious what actions do compared to plain objects

## Modern Alternatives

[Inference] Redux Toolkit's `createSlice` provides similar functionality with additional benefits:

```javascript
import { createSlice } from '@reduxjs/toolkit';

const todosSlice = createSlice({
  name: 'todos',
  initialState: [],
  reducers: {
    addTodo: (state, action) => {
      state.push(action.payload);
    },
    removeTodo: (state, action) => {
      return state.filter(todo => todo.id !== action.payload);
    }
  }
});

export const { addTodo, removeTodo } = todosSlice.actions;
export default todosSlice.reducer;
```

---

