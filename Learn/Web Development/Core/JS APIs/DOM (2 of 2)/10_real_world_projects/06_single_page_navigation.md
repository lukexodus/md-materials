## Single-Page Navigation


### History API Methods

**`history.pushState(state, title, url)`** adds a new entry to the browser's session history stack without triggering a page reload. The `state` parameter is an object associated with the history entry, `title` is largely ignored by browsers, and `url` is the new URL to display (must be same-origin).

```javascript
history.pushState(
  { page: 'about', data: { userId: 123 } },
  '',
  '/about'
);
```

**`history.replaceState(state, title, url)`** modifies the current history entry instead of adding a new one. Useful when you want to update the URL or state without creating a back button entry.

```javascript
// Update URL without adding history entry
history.replaceState(
  { ...history.state, scrollY: window.scrollY },
  '',
  window.location.pathname
);
```

**`history.back()`**, **`history.forward()`**, and **`history.go(delta)`** navigate through history. `go()` accepts negative values for backward navigation, positive for forward, or 0 to reload.

```javascript
history.back();        // Same as browser back button
history.go(-2);        // Go back 2 entries
history.go(0);         // Reload current page
```

**`history.state`** returns the state object of the current history entry. Returns `null` if no state was set.

```javascript
const currentState = history.state;
console.log(currentState?.page, currentState?.data);
```

**`history.length`** returns the number of entries in the session history stack.

### Navigation Events

**`popstate` event** fires when the active history entry changes due to user navigation (back/forward buttons) or programmatic calls to `history.back()`, `history.forward()`, or `history.go()`. Does NOT fire for `pushState()` or `replaceState()`.

```javascript
window.addEventListener('popstate', (event) => {
  console.log('State:', event.state);
  console.log('URL:', location.pathname);
  
  // Route based on new URL
  if (event.state?.page) {
    loadPage(event.state.page);
  }
});
```

**`hashchange` event** fires when the URL's fragment identifier changes. Occurs before `popstate` when hash changes.

```javascript
window.addEventListener('hashchange', (event) => {
  console.log('Old URL:', event.oldURL);
  console.log('New URL:', event.newURL);
  console.log('Hash:', location.hash);
});
```

### URL Manipulation

**`location.pathname`**, **`location.search`**, **`location.hash`** provide read/write access to URL components. Writing to these properties triggers navigation.

```javascript
// Read current path
const currentPath = location.pathname;

// Navigate by changing pathname (triggers page reload)
location.pathname = '/new-page';

// Work with URLSearchParams
const params = new URLSearchParams(location.search);
params.set('filter', 'active');
history.pushState(null, '', `?${params}`);
```

**`URL` constructor** parses and manipulates URLs without affecting the current page.

```javascript
const url = new URL('/products', location.origin);
url.searchParams.set('category', 'electronics');
url.searchParams.set('sort', 'price');

history.pushState({ category: 'electronics' }, '', url);
```

### Router Pattern Implementation

```javascript
class Router {
  constructor() {
    this.routes = new Map();
    this.currentRoute = null;
    
    window.addEventListener('popstate', (e) => {
      this.handleRoute(location.pathname, e.state);
    });
    
    // Handle initial load
    this.handleRoute(location.pathname, history.state);
  }
  
  addRoute(path, handler) {
    this.routes.set(path, handler);
  }
  
  navigate(path, state = {}) {
    history.pushState(state, '', path);
    this.handleRoute(path, state);
  }
  
  handleRoute(path, state) {
    const handler = this.routes.get(path);
    if (handler) {
      this.currentRoute = path;
      handler(state);
    } else {
      this.handle404(path);
    }
  }
  
  handle404(path) {
    console.log('Route not found:', path);
  }
}

// Usage
const router = new Router();
router.addRoute('/home', (state) => {
  document.getElementById('content').innerHTML = '<h1>Home</h1>';
});
router.addRoute('/about', (state) => {
  document.getElementById('content').innerHTML = '<h1>About</h1>';
});

// Navigate
router.navigate('/home');
```

### Link Interception

Intercepting anchor clicks to prevent default navigation and handle routing client-side:

```javascript
document.addEventListener('click', (e) => {
  const link = e.target.closest('a[href]');
  
  if (!link) return;
  
  const href = link.getAttribute('href');
  
  // Check if same-origin and not external
  if (href.startsWith('/') || href.startsWith(location.origin)) {
    e.preventDefault();
    
    const url = new URL(href, location.origin);
    history.pushState(
      { timestamp: Date.now() },
      '',
      url.pathname + url.search + url.hash
    );
    
    // Trigger route handling
    handleRoute(url.pathname);
  }
});
```

### Path Pattern Matching

```javascript
class PathMatcher {
  constructor(pattern) {
    this.paramNames = [];
    this.regex = this.createRegex(pattern);
  }
  
  createRegex(pattern) {
    const regexString = pattern
      .replace(/:\w+/g, (match) => {
        this.paramNames.push(match.slice(1));
        return '([^/]+)';
      })
      .replace(/\*/g, '.*');
    
    return new RegExp(`^${regexString}$`);
  }
  
  match(path) {
    const matches = path.match(this.regex);
    if (!matches) return null;
    
    const params = {};
    this.paramNames.forEach((name, index) => {
      params[name] = matches[index + 1];
    });
    
    return params;
  }
}

// Usage
const matcher = new PathMatcher('/users/:id/posts/:postId');
const params = matcher.match('/users/123/posts/456');
// Returns: { id: '123', postId: '456' }
```

### Query Parameter Management

```javascript
class QueryParams {
  constructor(search = location.search) {
    this.params = new URLSearchParams(search);
  }
  
  get(key) {
    return this.params.get(key);
  }
  
  getAll(key) {
    return this.params.getAll(key);
  }
  
  set(key, value) {
    this.params.set(key, value);
    return this;
  }
  
  delete(key) {
    this.params.delete(key);
    return this;
  }
  
  has(key) {
    return this.params.has(key);
  }
  
  apply(method = 'push') {
    const url = `${location.pathname}?${this.params}`;
    if (method === 'push') {
      history.pushState(null, '', url);
    } else {
      history.replaceState(null, '', url);
    }
  }
  
  toObject() {
    const obj = {};
    this.params.forEach((value, key) => {
      if (obj[key]) {
        obj[key] = Array.isArray(obj[key]) ? [...obj[key], value] : [obj[key], value];
      } else {
        obj[key] = value;
      }
    });
    return obj;
  }
}

// Usage
const query = new QueryParams();
query.set('page', '2').set('sort', 'date').apply('replace');
```

### Scroll Restoration

**`history.scrollRestoration`** controls whether the browser automatically restores scroll position on navigation. Values: `'auto'` (default) or `'manual'`.

```javascript
// Disable automatic scroll restoration
history.scrollRestoration = 'manual';

// Manual scroll management
const scrollPositions = new Map();

window.addEventListener('popstate', (e) => {
  const key = location.pathname;
  
  // Restore scroll position after content loads
  requestAnimationFrame(() => {
    const position = scrollPositions.get(key) || 0;
    window.scrollTo(0, position);
  });
});

// Save scroll position before navigation
function navigateToRoute(path) {
  scrollPositions.set(location.pathname, window.scrollY);
  history.pushState(null, '', path);
  handleRoute(path);
}
```

### State Persistence Strategies

```javascript
// Store complex state with navigation
function navigateWithState(path, appState) {
  const state = {
    timestamp: Date.now(),
    path: path,
    data: appState,
    scrollY: window.scrollY
  };
  
  history.pushState(state, '', path);
  
  // Also persist to sessionStorage for page reloads
  sessionStorage.setItem(`state_${path}`, JSON.stringify(appState));
}

// Restore state on popstate
window.addEventListener('popstate', (e) => {
  if (e.state?.data) {
    restoreAppState(e.state.data);
  } else {
    // Fallback to sessionStorage if state not available
    const stored = sessionStorage.getItem(`state_${location.pathname}`);
    if (stored) {
      restoreAppState(JSON.parse(stored));
    }
  }
});
```

### Hash-Based Navigation

```javascript
// Parse hash routes
function parseHash() {
  const hash = location.hash.slice(1); // Remove #
  const [path, search] = hash.split('?');
  const params = new URLSearchParams(search);
  
  return { path, params };
}

// Hash router
const hashRouter = {
  routes: new Map(),
  
  init() {
    window.addEventListener('hashchange', () => {
      this.handleRoute();
    });
    this.handleRoute();
  },
  
  handleRoute() {
    const { path, params } = parseHash();
    const handler = this.routes.get(path);
    
    if (handler) {
      handler(Object.fromEntries(params));
    }
  },
  
  navigate(path, params = {}) {
    const search = new URLSearchParams(params).toString();
    location.hash = search ? `${path}?${search}` : path;
  }
};

// Usage
hashRouter.routes.set('/home', (params) => {
  console.log('Home route', params);
});
hashRouter.init();
hashRouter.navigate('/home', { tab: 'settings' });
```

### Navigation Guards

```javascript
class GuardedRouter {
  constructor() {
    this.routes = new Map();
    this.beforeNavigate = [];
    this.afterNavigate = [];
    this.currentPath = null;
  }
  
  addGuard(phase, callback) {
    this[phase].push(callback);
  }
  
  async navigate(path, state = {}) {
    // Run before guards
    for (const guard of this.beforeNavigate) {
      const result = await guard(path, this.currentPath);
      if (result === false) {
        console.log('Navigation cancelled by guard');
        return false;
      }
    }
    
    // Perform navigation
    history.pushState(state, '', path);
    this.currentPath = path;
    
    const handler = this.routes.get(path);
    if (handler) {
      await handler(state);
    }
    
    // Run after guards
    for (const guard of this.afterNavigate) {
      await guard(path);
    }
    
    return true;
  }
}

// Usage
const router = new GuardedRouter();

router.addGuard('beforeNavigate', async (to, from) => {
  if (hasUnsavedChanges()) {
    return confirm('You have unsaved changes. Leave anyway?');
  }
  return true;
});

router.addGuard('afterNavigate', async (path) => {
  // Track page views
  analytics.track('pageview', { path });
  
  // Scroll to top
  window.scrollTo(0, 0);
});
```

### Prefetching Strategy

```javascript
// Prefetch routes on hover
function setupPrefetch() {
  const prefetched = new Set();
  
  document.addEventListener('mouseover', (e) => {
    const link = e.target.closest('a[href]');
    if (!link) return;
    
    const href = link.getAttribute('href');
    if (prefetched.has(href)) return;
    
    if (href.startsWith('/')) {
      prefetched.add(href);
      
      // Prefetch data for route
      fetch(`/api/data?path=${href}`)
        .then(res => res.json())
        .then(data => {
          // Cache data
          routeDataCache.set(href, data);
        });
    }
  });
}
```

### Nested Routes

```javascript
class NestedRouter {
  constructor() {
    this.routes = [];
  }
  
  addRoute(pattern, handler, children = []) {
    this.routes.push({
      matcher: new PathMatcher(pattern),
      handler,
      children
    });
  }
  
  match(path) {
    const segments = path.split('/').filter(Boolean);
    return this.matchSegments(segments, this.routes);
  }
  
  matchSegments(segments, routes, params = {}, matched = []) {
    if (segments.length === 0) return { matched, params };
    
    const currentPath = '/' + segments.join('/');
    
    for (const route of routes) {
      const routeParams = route.matcher.match(currentPath);
      
      if (routeParams) {
        matched.push(route);
        return {
          matched,
          params: { ...params, ...routeParams }
        };
      }
      
      // Try partial match for nested routes
      if (route.children.length > 0) {
        const partialPath = '/' + segments[0];
        const partialParams = route.matcher.match(partialPath);
        
        if (partialParams) {
          const result = this.matchSegments(
            segments.slice(1),
            route.children,
            { ...params, ...partialParams },
            [...matched, route]
          );
          if (result) return result;
        }
      }
    }
    
    return null;
  }
  
  async render(path) {
    const match = this.match(path);
    
    if (!match) {
      console.log('No route matched');
      return;
    }
    
    // Render each level
    for (const route of match.matched) {
      await route.handler(match.params);
    }
  }
}
```

### Navigation Timing

```javascript
class NavigationTimer {
  constructor() {
    this.timings = new Map();
  }
  
  start(id) {
    this.timings.set(id, {
      start: performance.now(),
      marks: []
    });
  }
  
  mark(id, label) {
    const timing = this.timings.get(id);
    if (timing) {
      timing.marks.push({
        label,
        time: performance.now() - timing.start
      });
    }
  }
  
  end(id) {
    const timing = this.timings.get(id);
    if (timing) {
      timing.duration = performance.now() - timing.start;
      console.log(`Navigation ${id}:`, timing);
      return timing;
    }
  }
}

// Usage
const navTimer = new NavigationTimer();

function navigate(path) {
  const id = `nav_${Date.now()}`;
  navTimer.start(id);
  
  history.pushState(null, '', path);
  navTimer.mark(id, 'history_updated');
  
  fetchRouteData(path).then(data => {
    navTimer.mark(id, 'data_loaded');
    renderRoute(data);
    navTimer.mark(id, 'render_complete');
    navTimer.end(id);
  });
}
```

### Focus Management

```javascript
function handleRouteChange(path) {
  // Announce route change to screen readers
  announceRouteChange(path);
  
  // Focus management
  const main = document.querySelector('main');
  if (main) {
    // Make focusable temporarily
    main.setAttribute('tabindex', '-1');
    main.focus();
    
    // Remove after focus
    main.addEventListener('blur', () => {
      main.removeAttribute('tabindex');
    }, { once: true });
  }
}

function announceRouteChange(path) {
  const announcer = document.getElementById('route-announcer') || 
    createAnnouncer();
  
  announcer.textContent = `Navigated to ${getPageTitle(path)}`;
}

function createAnnouncer() {
  const div = document.createElement('div');
  div.id = 'route-announcer';
  div.setAttribute('role', 'status');
  div.setAttribute('aria-live', 'polite');
  div.setAttribute('aria-atomic', 'true');
  div.style.cssText = 'position:absolute;left:-10000px;width:1px;height:1px;overflow:hidden;';
  document.body.appendChild(div);
  return div;
}
```

### Memory Leak Prevention

```javascript
class RouterWithCleanup {
  constructor() {
    this.currentCleanup = null;
    this.abortController = null;
  }
  
  async navigate(path) {
    // Cancel ongoing requests
    if (this.abortController) {
      this.abortController.abort();
    }
    this.abortController = new AbortController();
    
    // Run cleanup from previous route
    if (this.currentCleanup) {
      this.currentCleanup();
      this.currentCleanup = null;
    }
    
    history.pushState(null, '', path);
    
    // Load new route
    const cleanup = await this.loadRoute(path, this.abortController.signal);
    this.currentCleanup = cleanup;
  }
  
  async loadRoute(path, signal) {
    const response = await fetch(`/api${path}`, { signal });
    const data = await response.json();
    
    const eventListeners = [];
    
    // Render with tracked listeners
    const addTrackedListener = (element, event, handler) => {
      element.addEventListener(event, handler);
      eventListeners.push({ element, event, handler });
    };
    
    render(data, addTrackedListener);
    
    // Return cleanup function
    return () => {
      eventListeners.forEach(({ element, event, handler }) => {
        element.removeEventListener(event, handler);
      });
      eventListeners.length = 0;
    };
  }
}
```

[Inference: The specific performance characteristics of different routing implementations depend on application complexity, but cleanup patterns are generally necessary to prevent memory leaks in long-running SPAs]

---

