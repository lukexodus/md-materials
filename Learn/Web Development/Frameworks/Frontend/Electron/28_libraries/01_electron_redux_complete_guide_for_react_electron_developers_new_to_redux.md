## Electron-Redux: Complete Guide for React/Electron Developers New to Redux


### What is Redux?

**Redux** is a state management library that helps you manage application data in a predictable way. Think of it as a central storage container for all your app's data.

#### Core Redux Concepts You Need:

1. **Store**: A single JavaScript object that holds your entire application state
   ```javascript
   // Example store state
   ￼{
     user: { name: "John", loggedIn: true },
     todos: ["Buy milk", "Walk dog"]
   }
   ```

2. **Actions**: Plain JavaScript objects that describe what happened
   ```javascript
   // Action example
   ￼{
     type: 'ADD_TODO',
     payload: 'Buy groceries'
   }
   ```

3. **Reducers**: Pure functions that take current state + action, and return new state
   ```javascript
   ￼function todosReducer(state = [], action) {
     ￼if (action.type === 'ADD_TODO') {
       return [...state, action.payload];
     }
     return state;
   }
   ```

4. **Dispatch**: The method to send actions to the store
   ```javascript
   store.dispatch({ type: 'ADD_TODO', payload: 'Buy groceries' });
   ```

### The Electron-Redux Problem It Solves

**[1]** Information about Electron-Redux based on the description you provided, which I'm treating as documentation reference.
