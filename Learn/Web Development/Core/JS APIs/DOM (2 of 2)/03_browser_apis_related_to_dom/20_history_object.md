## History Object


The `history` object is a built-in browser API that provides access to the browser's session history — the list of pages visited in the current tab or frame.

### Accessing the History Object

```javascript
window.history
// or simply
history
```

### Key Properties

#### `history.length`
Returns the number of entries in the session history stack.

```javascript
console.log(history.length); // e.g., 5
```

#### `history.state`
Returns the current state object associated with the history entry (set via `pushState()` or `replaceState()`).

```javascript
console.log(history.state); // null or an object
```

#### `history.scrollRestoration`
Controls whether the browser should restore scroll position when navigating. Values: `'auto'` (default) or `'manual'`.

```javascript
history.scrollRestoration = 'manual';
```

### Key Methods

#### `history.back()`
Navigates to the previous page in history (equivalent to clicking the browser's back button).

```javascript
history.back();
```

#### `history.forward()`
Navigates to the next page in history (equivalent to clicking the browser's forward button).

```javascript
history.forward();
```

#### `history.go()`
Navigates to a specific page in history relative to the current page.

```javascript
history.go(-1);  // same as history.back()
history.go(1);   // same as history.forward()
history.go(-2);  // go back 2 pages
history.go(0);   // reload current page
```

#### `history.pushState()`
Adds a new entry to the session history stack without reloading the page.

```javascript
history.pushState(state, unused, url);
```

**Parameters:**
- `state`: An object associated with the new history entry (max ~2MB depending on browser)
- `unused`: Historically for a title, now ignored by most browsers (pass empty string)
- `url` (optional): The URL for the new history entry (must be same origin)

**Example:**
```javascript
const stateObj = { page: 1, data: 'example' };
history.pushState(stateObj, '', '/page1');
```

#### `history.replaceState()`
Modifies the current history entry instead of creating a new one.

```javascript
history.replaceState(state, unused, url);
```

**Example:**
```javascript
const stateObj = { page: 1, updated: true };
history.replaceState(stateObj, '', '/page1-updated');
```

### The `popstate` Event

Fires when the user navigates through history (back/forward buttons) or when `history.back()`, `history.forward()`, or `history.go()` is called.

```javascript
window.addEventListener('popstate', (event) => {
  console.log('Location:', document.location);
  console.log('State:', event.state);
});
```

**Important:** `popstate` does NOT fire when calling `pushState()` or `replaceState()`.

### Common Use Cases

#### Single Page Application (SPA) Navigation

```javascript
// Navigate to a new "page"
function navigateTo(page) {
  const state = { page: page };
  history.pushState(state, '', `/${page}`);
  renderPage(page);
}

// Handle browser back/forward
window.addEventListener('popstate', (event) => {
  if (event.state && event.state.page) {
    renderPage(event.state.page);
  }
});
```

#### Preserving Scroll Position

```javascript
// Save scroll position before navigation
const scrollPos = window.scrollY;
history.replaceState({ scrollPos }, '', window.location.href);

// Restore on popstate
window.addEventListener('popstate', (event) => {
  if (event.state && event.state.scrollPos) {
    window.scrollTo(0, event.state.scrollPos);
  }
});
```

#### Preventing Back Navigation

```javascript
// Add a dummy state
history.pushState(null, '', window.location.href);

// Prevent going back
window.addEventListener('popstate', () => {
  history.pushState(null, '', window.location.href);
});
```

### Browser Support

The `history` object is supported in all modern browsers. `pushState()` and `replaceState()` are supported in IE10+.

### Security Restrictions

- The new URL must be on the same origin (protocol, domain, and port)
- The state object is serialized, so it cannot contain functions or DOM nodes
- There's a size limit on the state object (typically around 640KB to 2MB depending on the browser)

### Differences from `window.location`

- `history` methods don't cause page reloads (unlike setting `window.location`)
- `history` maintains the session history stack
- `history` allows storing state data with each entry

---

