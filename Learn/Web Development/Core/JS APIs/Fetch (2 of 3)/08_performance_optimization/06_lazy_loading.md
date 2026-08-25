## Lazy Loading


### Core Concepts

Lazy loading defers fetching resources until they're needed, reducing initial load time and bandwidth consumption. With the fetch API, this involves triggering requests based on user interaction, viewport visibility, or application state rather than on initial page load.

The primary benefits include:

- Reduced initial bundle size and faster time-to-interactive
- Lower bandwidth usage for users who don't access all content
- Improved perceived performance through progressive content loading
- Better resource prioritization for critical rendering paths

### Implementation Patterns

#### On-Demand Loading

Trigger fetch requests when users explicitly request content:

```javascript
let userData = null;

async function loadUserData() {
  if (userData) return userData;
  
  const response = await fetch('/api/user/profile');
  userData = await response.json();
  return userData;
}

// Only fetches when called
button.addEventListener('click', async () => {
  const data = await loadUserData();
  displayProfile(data);
});
```

#### Intersection Observer Pattern

Load content when elements enter the viewport:

```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const img = entry.target;
      fetch(img.dataset.src)
        .then(res => res.blob())
        .then(blob => {
          img.src = URL.createObjectURL(blob);
          observer.unobserve(img);
        });
    }
  });
}, { rootMargin: '50px' });

document.querySelectorAll('img[data-src]').forEach(img => {
  observer.observe(img);
});
```

#### Scroll-Based Pagination

Implement infinite scroll with progressive data fetching:

```javascript
let page = 1;
let loading = false;
let hasMore = true;

async function loadMoreItems() {
  if (loading || !hasMore) return;
  
  loading = true;
  const response = await fetch(`/api/items?page=${page}&limit=20`);
  const data = await response.json();
  
  if (data.items.length === 0) {
    hasMore = false;
  } else {
    appendItems(data.items);
    page++;
  }
  
  loading = false;
}

window.addEventListener('scroll', () => {
  const { scrollTop, scrollHeight, clientHeight } = document.documentElement;
  
  if (scrollTop + clientHeight >= scrollHeight - 500) {
    loadMoreItems();
  }
});
```

### Route-Based Code Splitting

#### Dynamic Imports with Fetch

Combine dynamic imports with fetch for component-level lazy loading:

```javascript
const routes = {
  '/dashboard': () => import('./Dashboard.js'),
  '/profile': () => import('./Profile.js'),
  '/settings': () => import('./Settings.js')
};

async function navigate(path) {
  const loadComponent = routes[path];
  if (!loadComponent) return;
  
  // Load component code
  const module = await loadComponent();
  
  // Fetch component data
  const response = await fetch(`/api${path}`);
  const data = await response.json();
  
  // Render with data
  module.default(data);
}
```

#### Preloading Strategies

Anticipate navigation and preload resources:

```javascript
const preloadCache = new Map();

function preloadRoute(path) {
  if (preloadCache.has(path)) return;
  
  const promise = Promise.all([
    import(`./routes${path}.js`),
    fetch(`/api${path}`).then(r => r.json())
  ]);
  
  preloadCache.set(path, promise);
}

// Preload on hover
document.querySelectorAll('a[data-route]').forEach(link => {
  link.addEventListener('mouseenter', () => {
    preloadRoute(link.dataset.route);
  }, { once: true });
});

async function navigateToRoute(path) {
  const [module, data] = await (preloadCache.get(path) || 
    Promise.all([
      import(`./routes${path}.js`),
      fetch(`/api${path}`).then(r => r.json())
    ])
  );
  
  module.default(data);
}
```

### Caching Strategies

#### Memory Caching

Prevent redundant fetches with in-memory storage:

```javascript
class LazyCache {
  constructor() {
    this.cache = new Map();
    this.pending = new Map();
  }
  
  async fetch(url, options = {}) {
    // Return cached data
    if (this.cache.has(url)) {
      return this.cache.get(url);
    }
    
    // Return pending request if already fetching
    if (this.pending.has(url)) {
      return this.pending.get(url);
    }
    
    // Create new fetch request
    const promise = fetch(url, options)
      .then(res => res.json())
      .then(data => {
        this.cache.set(url, data);
        this.pending.delete(url);
        return data;
      })
      .catch(err => {
        this.pending.delete(url);
        throw err;
      });
    
    this.pending.set(url, promise);
    return promise;
  }
  
  invalidate(url) {
    this.cache.delete(url);
  }
  
  clear() {
    this.cache.clear();
    this.pending.clear();
  }
}

const cache = new LazyCache();
```

#### Time-Based Invalidation

Implement stale-while-revalidate pattern:

```javascript
class TTLCache {
  constructor(ttl = 300000) { // 5 minutes default
    this.cache = new Map();
    this.ttl = ttl;
  }
  
  async fetch(url) {
    const cached = this.cache.get(url);
    const now = Date.now();
    
    if (cached && now - cached.timestamp < this.ttl) {
      return cached.data;
    }
    
    // Stale data available, return it while revalidating
    if (cached) {
      this.revalidate(url);
      return cached.data;
    }
    
    // No cache, fetch fresh
    return this.fetchAndCache(url);
  }
  
  async fetchAndCache(url) {
    const response = await fetch(url);
    const data = await response.json();
    
    this.cache.set(url, {
      data,
      timestamp: Date.now()
    });
    
    return data;
  }
  
  async revalidate(url) {
    try {
      await this.fetchAndCache(url);
    } catch (err) {
      console.error('Revalidation failed:', err);
    }
  }
}
```

### Progressive Enhancement

#### Skeleton Screens

Display placeholders while fetching:

```javascript
async function loadContent(containerId, url) {
  const container = document.getElementById(containerId);
  
  // Show skeleton
  container.innerHTML = `
    <div class="skeleton">
      <div class="skeleton-line"></div>
      <div class="skeleton-line"></div>
      <div class="skeleton-line short"></div>
    </div>
  `;
  
  try {
    const response = await fetch(url);
    const data = await response.json();
    
    // Replace with actual content
    container.innerHTML = renderContent(data);
  } catch (err) {
    container.innerHTML = '<div class="error">Failed to load content</div>';
  }
}
```

#### Prioritized Loading

Load critical content first, defer secondary content:

```javascript
async function loadPage() {
  // Critical: Load immediately
  const criticalPromises = [
    fetch('/api/hero').then(r => r.json()),
    fetch('/api/navigation').then(r => r.json())
  ];
  
  const [hero, nav] = await Promise.all(criticalPromises);
  renderHero(hero);
  renderNav(nav);
  
  // Secondary: Load after critical content
  requestIdleCallback(async () => {
    const [sidebar, footer] = await Promise.all([
      fetch('/api/sidebar').then(r => r.json()),
      fetch('/api/footer').then(r => r.json())
    ]);
    
    renderSidebar(sidebar);
    renderFooter(footer);
  });
  
  // Tertiary: Load on interaction
  setupLazyLoadingForBelow();
}
```

### Error Handling and Fallbacks

#### Retry Mechanisms

Implement exponential backoff for failed lazy loads:

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      return await response.json();
    } catch (err) {
      lastError = err;
      
      if (i < maxRetries - 1) {
        const delay = Math.min(1000 * Math.pow(2, i), 10000);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw lastError;
}
```

#### Graceful Degradation

Provide fallback content when lazy loading fails:

```javascript
class LazySection {
  constructor(element) {
    this.element = element;
    this.url = element.dataset.lazyUrl;
    this.fallback = element.dataset.fallback;
    this.loaded = false;
  }
  
  async load() {
    if (this.loaded) return;
    
    try {
      const response = await fetch(this.url);
      const html = await response.text();
      this.element.innerHTML = html;
      this.loaded = true;
    } catch (err) {
      console.error('Lazy load failed:', err);
      
      if (this.fallback) {
        this.element.innerHTML = this.fallback;
      } else {
        this.element.innerHTML = `
          <div class="lazy-error">
            <p>Content unavailable</p>
            <button onclick="this.parentElement.parentElement.reload()">
              Retry
            </button>
          </div>
        `;
      }
    }
  }
  
  reload() {
    this.loaded = false;
    this.load();
  }
}
```

### Performance Optimization

#### Request Batching

Combine multiple lazy-loaded requests:

```javascript
class RequestBatcher {
  constructor(delay = 50) {
    this.queue = [];
    this.delay = delay;
    this.timeout = null;
  }
  
  fetch(url) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, resolve, reject });
      
      clearTimeout(this.timeout);
      this.timeout = setTimeout(() => this.flush(), this.delay);
    });
  }
  
  async flush() {
    if (this.queue.length === 0) return;
    
    const batch = this.queue.splice(0);
    const urls = batch.map(item => item.url);
    
    try {
      const response = await fetch('/api/batch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ urls })
      });
      
      const results = await response.json();
      
      batch.forEach((item, index) => {
        if (results[index].error) {
          item.reject(new Error(results[index].error));
        } else {
          item.resolve(results[index].data);
        }
      });
    } catch (err) {
      batch.forEach(item => item.reject(err));
    }
  }
}

const batcher = new RequestBatcher();
```

#### Resource Hints

Optimize network timing with prefetch/preload:

```javascript
function addResourceHint(href, rel = 'prefetch', as = 'fetch') {
  const link = document.createElement('link');
  link.rel = rel;
  link.href = href;
  if (as) link.as = as;
  document.head.appendChild(link);
}

// Prefetch likely next navigation
function prefetchNextRoutes() {
  const currentRoute = window.location.pathname;
  const nextRoutes = predictNextRoutes(currentRoute);
  
  nextRoutes.forEach(route => {
    addResourceHint(`/api${route}`, 'prefetch');
  });
}

// Preload critical lazy resources
function preloadCriticalResources() {
  const criticalUrls = [
    '/api/user/preferences',
    '/api/critical-data'
  ];
  
  criticalUrls.forEach(url => {
    addResourceHint(url, 'preload', 'fetch');
  });
}
```

#### Connection Optimization

Minimize connection overhead for lazy loads:

```javascript
// Use keep-alive connections
const fetchWithKeepalive = (url, options = {}) => {
  return fetch(url, {
    ...options,
    keepalive: true
  });
};

// Prioritize lazy load requests
const fetchWithPriority = (url, priority = 'low') => {
  return fetch(url, {
    priority // 'high', 'low', or 'auto'
  });
};

// Combine both
async function optimizedLazyFetch(url, options = {}) {
  return fetch(url, {
    keepalive: true,
    priority: options.priority || 'low',
    ...options
  });
}
```

### Testing Strategies

#### Simulating Slow Networks

Test lazy loading under poor conditions:

```javascript
class NetworkThrottle {
  constructor(delay = 1000) {
    this.delay = delay;
    this.originalFetch = window.fetch;
  }
  
  enable() {
    window.fetch = async (...args) => {
      await new Promise(resolve => setTimeout(resolve, this.delay));
      return this.originalFetch(...args);
    };
  }
  
  disable() {
    window.fetch = this.originalFetch;
  }
}

// Usage in tests
const throttle = new NetworkThrottle(3000);
throttle.enable();
```

#### Monitoring Lazy Load Metrics

Track performance of lazy-loaded resources:

```javascript
class LazyLoadMonitor {
  constructor() {
    this.metrics = [];
  }
  
  async trackFetch(url, fetchFn) {
    const start = performance.now();
    const startMark = `lazy-start-${url}`;
    const endMark = `lazy-end-${url}`;
    
    performance.mark(startMark);
    
    try {
      const result = await fetchFn();
      performance.mark(endMark);
      
      const duration = performance.now() - start;
      
      this.metrics.push({
        url,
        duration,
        timestamp: Date.now(),
        success: true
      });
      
      performance.measure(`lazy-${url}`, startMark, endMark);
      
      return result;
    } catch (err) {
      performance.mark(endMark);
      
      this.metrics.push({
        url,
        duration: performance.now() - start,
        timestamp: Date.now(),
        success: false,
        error: err.message
      });
      
      throw err;
    }
  }
  
  getMetrics() {
    return {
      total: this.metrics.length,
      successful: this.metrics.filter(m => m.success).length,
      failed: this.metrics.filter(m => !m.success).length,
      avgDuration: this.metrics.reduce((sum, m) => sum + m.duration, 0) / this.metrics.length
    };
  }
}

const monitor = new LazyLoadMonitor();
```

### Advanced Patterns

#### Predictive Prefetching

Use machine learning or heuristics to predict and prefetch:

```javascript
class PredictivePrefetcher {
  constructor() {
    this.navHistory = [];
    this.patterns = new Map();
  }
  
  recordNavigation(from, to) {
    this.navHistory.push({ from, to, timestamp: Date.now() });
    
    // Build pattern map
    const key = from;
    if (!this.patterns.has(key)) {
      this.patterns.set(key, new Map());
    }
    
    const destinations = this.patterns.get(key);
    destinations.set(to, (destinations.get(to) || 0) + 1);
  }
  
  predictNext(current) {
    const destinations = this.patterns.get(current);
    if (!destinations) return [];
    
    // Sort by frequency
    return Array.from(destinations.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([dest]) => dest);
  }
  
  prefetchPredicted(current) {
    const predictions = this.predictNext(current);
    predictions.forEach(route => {
      fetch(`/api${route}`)
        .then(r => r.json())
        .then(data => cache.set(route, data))
        .catch(() => {}); // Silent fail for prefetch
    });
  }
}

const prefetcher = new PredictivePrefetcher();
```

#### Virtual Scrolling

Efficiently render large lists with lazy data fetching:

```javascript
class VirtualList {
  constructor(container, itemHeight, fetchData) {
    this.container = container;
    this.itemHeight = itemHeight;
    this.fetchData = fetchData;
    this.totalItems = 0;
    this.visibleItems = new Map();
    this.buffer = 5;
    
    this.setupScrolling();
  }
  
  setupScrolling() {
    this.container.addEventListener('scroll', () => {
      this.render();
    });
    
    this.render();
  }
  
  async render() {
    const scrollTop = this.container.scrollTop;
    const height = this.container.clientHeight;
    
    const start = Math.floor(scrollTop / this.itemHeight);
    const end = Math.ceil((scrollTop + height) / this.itemHeight);
    
    const startWithBuffer = Math.max(0, start - this.buffer);
    const endWithBuffer = end + this.buffer;
    
    // Fetch data for visible range
    const data = await this.fetchData(startWithBuffer, endWithBuffer);
    
    // Update visible items
    for (let i = startWithBuffer; i < endWithBuffer; i++) {
      if (!this.visibleItems.has(i) && data[i - startWithBuffer]) {
        const element = this.createItem(data[i - startWithBuffer], i);
        this.visibleItems.set(i, element);
        this.container.appendChild(element);
      }
    }
    
    // Remove items outside visible range
    for (const [index, element] of this.visibleItems) {
      if (index < startWithBuffer || index >= endWithBuffer) {
        element.remove();
        this.visibleItems.delete(index);
      }
    }
  }
  
  createItem(data, index) {
    const div = document.createElement('div');
    div.style.position = 'absolute';
    div.style.top = `${index * this.itemHeight}px`;
    div.style.height = `${this.itemHeight}px`;
    div.textContent = data.text;
    return div;
  }
}

// Usage
const list = new VirtualList(
  document.getElementById('list'),
  50,
  async (start, end) => {
    const response = await fetch(`/api/items?start=${start}&end=${end}`);
    return response.json();
  }
);
```

#### Modular Lazy Loading

Component-based lazy loading architecture:

```javascript
class LazyModule {
  constructor(name, loader) {
    this.name = name;
    this.loader = loader;
    this.instance = null;
    this.loading = null;
  }
  
  async load() {
    if (this.instance) return this.instance;
    if (this.loading) return this.loading;
    
    this.loading = Promise.all([
      this.loader.code(),
      this.loader.data?.() || Promise.resolve(null)
    ]).then(([module, data]) => {
      this.instance = new module.default(data);
      this.loading = null;
      return this.instance;
    });
    
    return this.loading;
  }
  
  unload() {
    if (this.instance?.destroy) {
      this.instance.destroy();
    }
    this.instance = null;
  }
}

// Registry
class ModuleRegistry {
  constructor() {
    this.modules = new Map();
  }
  
  register(name, codeLoader, dataLoader) {
    this.modules.set(name, new LazyModule(name, {
      code: codeLoader,
      data: dataLoader
    }));
  }
  
  async load(name) {
    const module = this.modules.get(name);
    if (!module) throw new Error(`Module ${name} not found`);
    return module.load();
  }
  
  unload(name) {
    const module = this.modules.get(name);
    if (module) module.unload();
  }
}

// Usage
const registry = new ModuleRegistry();

registry.register(
  'dashboard',
  () => import('./Dashboard.js'),
  () => fetch('/api/dashboard').then(r => r.json())
);

registry.register(
  'analytics',
  () => import('./Analytics.js'),
  () => fetch('/api/analytics').then(r => r.json())
);

// Load when needed
await registry.load('dashboard');
```

---

