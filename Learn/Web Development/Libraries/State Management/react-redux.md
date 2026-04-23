# React-Redux: Complete Guide

## What is React-Redux?

**React-Redux** is the official Redux binding library for React. It connects your React components to your Redux store, allowing components to read state and dispatch actions.

**Without React-Redux**, you'd need to manually subscribe to store updates and handle re-renders yourself. React-Redux automates this.

## Installation

```bash
npm install react-redux
# or
yarn add react-redux
```

**Note**: You also need Redux itself:
```bash
npm install redux react-redux
```

## Core Concepts

### 1. Provider Component

The `<Provider>` wraps your entire React app and makes the Redux store available to all components.

```javascript
import React from 'react';
import ReactDOM from 'react-dom';
import { createStore } from 'redux';
import { Provider } from 'react-redux';
import App from './App';
import rootReducer from './reducers';

const store = createStore(rootReducer);

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
);
```

**What it does**: Uses React Context under the hood to pass the store down to all child components without prop drilling.

### 2. Hooks API (Modern Approach - React 16.8+)

React-Redux provides hooks for accessing the store in functional components.

#### `useSelector()` - Read State

Extracts data from the Redux store state.

```javascript
import { useSelector } from 'react-redux';

function Counter() {
  // Select just the piece of state you need
  const count = useSelector(state => state.counter.count);
  const user = useSelector(state => state.user.name);
  
  return <div>Count: {count}, User: {user}</div>;
}
```

**Selector function**: `state => state.counter.count`
- Receives the entire Redux state
- Returns the piece you want
- Component re-renders when returned value changes

**Performance tip**: `useSelector()` does a **shallow equality check** (===). If you return a new object/array each time, your component will re-render on every store update.

```javascript
// ❌ BAD - Creates new object every time, causes unnecessary re-renders
const data = useSelector(state => ({
  count: state.counter.count,
  user: state.user.name
}));

// ✅ GOOD - Select primitives separately
const count = useSelector(state => state.counter.count);
const userName = useSelector(state => state.user.name);

// ✅ ALSO GOOD - Use equality function for objects
import { shallowEqual } from 'react-redux';
const data = useSelector(
  state => ({
    count: state.counter.count,
    user: state.user.name
  }),
  shallowEqual
);
```

#### `useDispatch()` - Dispatch Actions

Gets the `dispatch` function to send actions to the store.

```javascript
import { useDispatch } from 'react-redux';

function Counter() {
  const dispatch = useDispatch();
  const count = useSelector(state => state.count);
  
  const increment = () => {
    dispatch({ type: 'INCREMENT' });
  };
  
  const incrementByAmount = (amount) => {
    dispatch({ type: 'INCREMENT_BY', payload: amount });
  };
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+1</button>
      <button onClick={() => incrementByAmount(5)}>+5</button>
    </div>
  );
}
```

**Best practice**: Create action creators for reusability:

```javascript
// actions.js
export const increment = () => ({ type: 'INCREMENT' });
export const incrementBy = (amount) => ({ 
  type: 'INCREMENT_BY', 
  payload: amount 
});

// Counter.js
import { increment, incrementBy } from './actions';

function Counter() {
  const dispatch = useDispatch();
  
  return (
    <button onClick={() => dispatch(increment())}>+1</button>
  );
}
```

#### `useStore()` - Access Store Directly

Gets the Redux store instance itself. **Rarely needed** - prefer `useSelector` and `useDispatch`.

```javascript
import { useStore } from 'react-redux';

function Debug() {
  const store = useStore();
  
  // Can call store methods directly
  console.log(store.getState());
  
  return <div>Check console</div>;
}
```

### 3. Connect API (Legacy/Class Components)

Before hooks, React-Redux used the `connect()` higher-order component (HOC). Still works but less common in new code.

```javascript
import { connect } from 'react-redux';

// Class component
class Counter extends React.Component {
  render() {
    const { count, increment } = this.props;
    return (
      <div>
        <p>Count: {count}</p>
        <button onClick={increment}>+1</button>
      </div>
    );
  }
}

// Map state to props
const mapStateToProps = (state) => ({
  count: state.counter.count
});

// Map dispatch to props
const mapDispatchToProps = (dispatch) => ({
  increment: () => dispatch({ type: 'INCREMENT' })
});

export default connect(mapStateToProps, mapDispatchToProps)(Counter);
```

**Hooks vs Connect**:
- Hooks: More concise, better TypeScript support, easier testing
- Connect: Better memoization out of the box, works with class components

## Complete Example

### Store Setup

```javascript
// store.js
import { createStore } from 'redux';
import rootReducer from './reducers';

const store = createStore(
  rootReducer,
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);

export default store;
```

### Reducers

```javascript
// reducers/index.js
import { combineReducers } from 'redux';
import counterReducer from './counterReducer';
import userReducer from './userReducer';

export default combineReducers({
  counter: counterReducer,
  user: userReducer
});

// reducers/counterReducer.js
const initialState = { count: 0 };

export default function counterReducer(state = initialState, action) {
  switch (action.type) {
    case 'INCREMENT':
      return { count: state.count + 1 };
    case 'DECREMENT':
      return { count: state.count - 1 };
    case 'INCREMENT_BY':
      return { count: state.count + action.payload };
    default:
      return state;
  }
}

// reducers/userReducer.js
const initialState = { name: '', loggedIn: false };

export default function userReducer(state = initialState, action) {
  switch (action.type) {
    case 'LOGIN':
      return { name: action.payload, loggedIn: true };
    case 'LOGOUT':
      return { name: '', loggedIn: false };
    default:
      return state;
  }
}
```

### Action Creators

```javascript
// actions/counterActions.js
export const increment = () => ({ type: 'INCREMENT' });
export const decrement = () => ({ type: 'DECREMENT' });
export const incrementBy = (amount) => ({ 
  type: 'INCREMENT_BY', 
  payload: amount 
});

// actions/userActions.js
export const login = (username) => ({ 
  type: 'LOGIN', 
  payload: username 
});
export const logout = () => ({ type: 'LOGOUT' });
```

### React Components

```javascript
// index.js
import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import store from './store';
import App from './App';

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
);

// App.js
import React from 'react';
import Counter from './Counter';
import UserPanel from './UserPanel';

function App() {
  return (
    <div>
      <h1>My App</h1>
      <UserPanel />
      <Counter />
    </div>
  );
}

export default App;

// Counter.js
import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { increment, decrement, incrementBy } from './actions/counterActions';

function Counter() {
  const count = useSelector(state => state.counter.count);
  const dispatch = useDispatch();
  
  return (
    <div>
      <h2>Counter: {count}</h2>
      <button onClick={() => dispatch(increment())}>+1</button>
      <button onClick={() => dispatch(decrement())}>-1</button>
      <button onClick={() => dispatch(incrementBy(10))}>+10</button>
    </div>
  );
}

export default Counter;

// UserPanel.js
import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { login, logout } from './actions/userActions';

function UserPanel() {
  const { name, loggedIn } = useSelector(state => state.user);
  const dispatch = useDispatch();
  const [input, setInput] = useState('');
  
  const handleLogin = () => {
    dispatch(login(input));
    setInput('');
  };
  
  if (loggedIn) {
    return (
      <div>
        <p>Welcome, {name}!</p>
        <button onClick={() => dispatch(logout())}>Logout</button>
      </div>
    );
  }
  
  return (
    <div>
      <input 
        value={input} 
        onChange={(e) => setInput(e.target.value)}
        placeholder="Username"
      />
      <button onClick={handleLogin}>Login</button>
    </div>
  );
}

export default UserPanel;
```

## Advanced Patterns

### Memoized Selectors (Reselect)

For expensive computations, use memoized selectors to avoid recalculating on every render.

```bash
npm install reselect
```

```javascript
import { createSelector } from 'reselect';

// Input selectors
const getTodos = state => state.todos;
const getFilter = state => state.filter;

// Memoized selector
const getVisibleTodos = createSelector(
  [getTodos, getFilter],
  (todos, filter) => {
    // This only recalculates if todos or filter changes
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

// Usage
function TodoList() {
  const visibleTodos = useSelector(getVisibleTodos);
  // ...
}
```

### Custom Hooks

Create reusable hooks for common patterns:

```javascript
// hooks/useActions.js
import { useDispatch } from 'react-redux';
import { useMemo } from 'react';
import { bindActionCreators } from 'redux';

export function useActions(actions) {
  const dispatch = useDispatch();
  return useMemo(
    () => bindActionCreators(actions, dispatch),
    [actions, dispatch]
  );
}

// Usage
import * as counterActions from './actions/counterActions';

function Counter() {
  const actions = useActions(counterActions);
  const count = useSelector(state => state.counter.count);
  
  return (
    <button onClick={actions.increment}>
      Count: {count}
    </button>
  );
}
```

### TypeScript Support

React-Redux has excellent TypeScript support:

```typescript
// store.ts
import { createStore } from 'redux';
import rootReducer from './reducers';

const store = createStore(rootReducer);

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;

// hooks.ts
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
import type { RootState, AppDispatch } from './store';

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;

// Counter.tsx
import { useAppSelector, useAppDispatch } from './hooks';

function Counter() {
  const count = useAppSelector(state => state.counter.count); // Typed!
  const dispatch = useAppDispatch();
  
  return <div>Count: {count}</div>;
}
```

## Common Patterns & Best Practices

### 1. Structure State by Feature

```javascript
{
  counter: { count: 0 },
  user: { name: '', loggedIn: false },
  todos: { items: [], filter: 'ALL' }
}
```

### 2. Keep Components Minimal

Only select the data you need:
```javascript
// ❌ Selecting too much
const state = useSelector(state => state);

// ✅ Select only what you need
const count = useSelector(state => state.counter.count);
```

### 3. Colocate Connected Components

Keep components that use Redux near their feature:
```
src/
  features/
    counter/
      Counter.js
      counterSlice.js
    user/
      UserPanel.js
      userSlice.js
```

### 4. Normalize Complex State

For nested data, normalize it:
```javascript
// ❌ Nested structure - hard to update
{
  posts: [
    { id: 1, author: { id: 5, name: 'John' }, comments: [...] }
  ]
}

// ✅ Normalized - easier to update
{
  posts: { 1: { id: 1, authorId: 5, commentIds: [10, 11] } },
  users: { 5: { id: 5, name: 'John' } },
  comments: { 10: {...}, 11: {...} }
}
```

## Redux Toolkit (Modern Redux)

**Redux Toolkit** is the official, opinionated toolset for Redux. It simplifies Redux dramatically and is now the recommended way to write Redux.

```bash
npm install @reduxjs/toolkit react-redux
```

Same example with Redux Toolkit:

```javascript
// store.js
import { configureStore } from '@reduxjs/toolkit';
import counterReducer from './counterSlice';
import userReducer from './userSlice';

export const store = configureStore({
  reducer: {
    counter: counterReducer,
    user: userReducer
  }
});

// counterSlice.js
import { createSlice } from '@reduxjs/toolkit';

const counterSlice = createSlice({
  name: 'counter',
  initialState: { count: 0 },
  reducers: {
    increment: state => { state.count += 1; }, // Immer allows mutations!
    decrement: state => { state.count -= 1; },
    incrementBy: (state, action) => { state.count += action.payload; }
  }
});

export const { increment, decrement, incrementBy } = counterSlice.actions;
export default counterSlice.reducer;

// Counter.js - same usage!
import { useSelector, useDispatch } from 'react-redux';
import { increment, decrement } from './counterSlice';

function Counter() {
  const count = useSelector(state => state.counter.count);
  const dispatch = useDispatch();
  
  return (
    <button onClick={() => dispatch(increment())}>
      Count: {count}
    </button>
  );
}
```

**Benefits of Redux Toolkit**:
- Less boilerplate (no action types, action creators, switch statements)
- Immer integration (write "mutating" code that's actually immutable)
- DevTools configured automatically
- Better TypeScript support

## Summary

**React-Redux connects React to Redux:**

1. **`<Provider>`** - Wrap app to provide store
2. **`useSelector()`** - Read state in components
3. **`useDispatch()`** - Dispatch actions in components
4. **`connect()`** - Legacy HOC for class components

**Best practices:**
- Use hooks in functional components
- Select only needed state
- Create action creators
- Consider Redux Toolkit for new projects
- Use memoized selectors for expensive computations

**Data flow:**
1. User interacts with UI
2. Component dispatches action
3. Redux reducer updates state
4. React-Redux detects change
5. Component re-renders with new data