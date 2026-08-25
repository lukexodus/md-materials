## Infinite Scroll with Fetch API


### Core Implementation Pattern

Infinite scroll monitors the viewport and scroll position to trigger data fetching when users approach the content boundary. The fundamental pattern involves three components: scroll detection, fetch execution, and DOM manipulation.

```javascript
let page = 1;
let loading = false;
let hasMore = true;

async function loadMore() {
  if (loading || !hasMore) return;
  
  loading = true;
  try {
    const response = await fetch(`/api/items?page=${page}&limit=20`);
    const data = await response.json();
    
    if (data.items.length === 0) {
      hasMore = false;
      return;
    }
    
    appendItems(data.items);
    page++;
  } catch (error) {
    handleError(error);
  } finally {
    loading = false;
  }
}
```

### Scroll Detection Strategies

#### Threshold-Based Detection

Calculate remaining scroll distance and trigger when crossing a threshold:

```javascript
function checkScroll() {
  const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
  const windowHeight = window.innerHeight;
  const documentHeight = document.documentElement.scrollHeight;
  
  const distanceFromBottom = documentHeight - (scrollTop + windowHeight);
  const threshold = 300; // pixels from bottom
  
  if (distanceFromBottom < threshold) {
    loadMore();
  }
}

window.addEventListener('scroll', checkScroll);
```

#### Intersection Observer Approach

Modern, performant method using a sentinel element:

```javascript
const sentinel = document.querySelector('#sentinel');
let observer;

function initIntersectionObserver() {
  observer = new IntersectionObserver(
    (entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          loadMore();
        }
      });
    },
    {
      root: null, // viewport
      rootMargin: '200px', // trigger 200px before sentinel visible
      threshold: 0
    }
  );
  
  observer.observe(sentinel);
}
```

### Debouncing and Throttling

Prevent excessive fetch calls during rapid scrolling:

```javascript
// Throttle approach
function throttle(func, delay) {
  let lastCall = 0;
  return function(...args) {
    const now = Date.now();
    if (now - lastCall >= delay) {
      lastCall = now;
      func(...args);
    }
  };
}

const throttledCheck = throttle(checkScroll, 200);
window.addEventListener('scroll', throttledCheck);

// Debounce approach
function debounce(func, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func(...args), delay);
  };
}
```

### State Management

Maintain application state to prevent race conditions and duplicate requests:

```javascript
class InfiniteScrollManager {
  constructor(apiEndpoint, container) {
    this.apiEndpoint = apiEndpoint;
    this.container = container;
    this.page = 1;
    this.loading = false;
    this.hasMore = true;
    this.abortController = null;
  }
  
  async fetchPage() {
    if (this.loading || !this.hasMore) return;
    
    // Cancel previous request if still pending
    if (this.abortController) {
      this.abortController.abort();
    }
    
    this.abortController = new AbortController();
    this.loading = true;
    this.showLoader();
    
    try {
      const response = await fetch(
        `${this.apiEndpoint}?page=${this.page}&limit=20`,
        { signal: this.abortController.signal }
      );
      
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      
      const data = await response.json();
      
      if (data.items.length === 0 || data.items.length < 20) {
        this.hasMore = false;
      }
      
      this.renderItems(data.items);
      this.page++;
    } catch (error) {
      if (error.name !== 'AbortError') {
        this.handleError(error);
      }
    } finally {
      this.loading = false;
      this.hideLoader();
      this.abortController = null;
    }
  }
  
  reset() {
    this.page = 1;
    this.hasMore = true;
    this.loading = false;
    this.container.innerHTML = '';
  }
}
```

### Pagination Strategies

#### Offset-Based Pagination

```javascript
// Client side
const limit = 20;
const offset = (page - 1) * limit;
const url = `/api/items?limit=${limit}&offset=${offset}`;

// Common API response structure
{
  items: [...],
  total: 1000,
  limit: 20,
  offset: 40,
  hasMore: true
}
```

#### Cursor-Based Pagination

More reliable for real-time data where items may be added/removed:

```javascript
let cursor = null;

async function fetchWithCursor() {
  const url = cursor 
    ? `/api/items?cursor=${cursor}&limit=20`
    : `/api/items?limit=20`;
  
  const response = await fetch(url);
  const data = await response.json();
  
  cursor = data.nextCursor; // null when no more data
  hasMore = data.nextCursor !== null;
  
  return data.items;
}

// Typical cursor response
{
  items: [...],
  nextCursor: "eyJpZCI6MTAwLCJ0aW1lc3RhbXAiOjE2MzI0....",
  hasMore: true
}
```

### Error Handling and Retry Logic

```javascript
class RetryableFetch {
  constructor(maxRetries = 3, baseDelay = 1000) {
    this.maxRetries = maxRetries;
    this.baseDelay = baseDelay;
  }
  
  async fetchWithRetry(url, options = {}, attempt = 1) {
    try {
      const response = await fetch(url, options);
      
      if (!response.ok) {
        if (response.status >= 500 && attempt < this.maxRetries) {
          // Server error, retry with exponential backoff
          const delay = this.baseDelay * Math.pow(2, attempt - 1);
          await this.sleep(delay);
          return this.fetchWithRetry(url, options, attempt + 1);
        }
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return response;
    } catch (error) {
      if (attempt < this.maxRetries && this.isNetworkError(error)) {
        const delay = this.baseDelay * Math.pow(2, attempt - 1);
        await this.sleep(delay);
        return this.fetchWithRetry(url, options, attempt + 1);
      }
      throw error;
    }
  }
  
  isNetworkError(error) {
    return error.name === 'TypeError' || error.message.includes('fetch');
  }
  
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Usage
const retryFetch = new RetryableFetch(3, 1000);
const response = await retryFetch.fetchWithRetry('/api/items?page=5');
```

### Performance Optimization

#### Request Deduplication

Prevent multiple simultaneous requests for the same data:

```javascript
class RequestCache {
  constructor() {
    this.pending = new Map();
  }
  
  async fetch(url, options) {
    const key = `${url}-${JSON.stringify(options)}`;
    
    if (this.pending.has(key)) {
      return this.pending.get(key);
    }
    
    const promise = fetch(url, options)
      .then(response => response.json())
      .finally(() => {
        this.pending.delete(key);
      });
    
    this.pending.set(key, promise);
    return promise;
  }
}
```

#### Virtual Scrolling Integration

For massive datasets, combine infinite scroll with virtual scrolling:

```javascript
class VirtualInfiniteScroll {
  constructor(container, itemHeight, bufferSize = 10) {
    this.container = container;
    this.itemHeight = itemHeight;
    this.bufferSize = bufferSize;
    this.items = [];
    this.visibleStart = 0;
    this.visibleEnd = 0;
  }
  
  calculateVisibleRange() {
    const scrollTop = this.container.scrollTop;
    const viewportHeight = this.container.clientHeight;
    
    this.visibleStart = Math.max(0, 
      Math.floor(scrollTop / this.itemHeight) - this.bufferSize
    );
    this.visibleEnd = Math.min(
      this.items.length,
      Math.ceil((scrollTop + viewportHeight) / this.itemHeight) + this.bufferSize
    );
  }
  
  render() {
    this.calculateVisibleRange();
    const visibleItems = this.items.slice(this.visibleStart, this.visibleEnd);
    
    // Set container height for scrollbar
    this.container.style.height = `${this.items.length * this.itemHeight}px`;
    
    // Offset visible items
    const offset = this.visibleStart * this.itemHeight;
    // Render visibleItems with offset...
  }
  
  shouldLoadMore() {
    const scrollBottom = this.container.scrollTop + this.container.clientHeight;
    const totalHeight = this.items.length * this.itemHeight;
    return totalHeight - scrollBottom < this.itemHeight * 5;
  }
}
```

### Loading States and UI Feedback

```javascript
class LoadingStateManager {
  constructor() {
    this.loader = document.querySelector('.loader');
    this.endMessage = document.querySelector('.end-message');
    this.errorMessage = document.querySelector('.error-message');
  }
  
  showLoader() {
    this.loader.classList.add('active');
    this.hideError();
    this.hideEndMessage();
  }
  
  hideLoader() {
    this.loader.classList.remove('active');
  }
  
  showEndMessage() {
    this.hideLoader();
    this.endMessage.classList.add('visible');
  }
  
  showError(message) {
    this.hideLoader();
    this.errorMessage.textContent = message;
    this.errorMessage.classList.add('visible');
  }
  
  hideError() {
    this.errorMessage.classList.remove('visible');
  }
  
  hideEndMessage() {
    this.endMessage.classList.remove('visible');
  }
}
```

### Skeleton Loading Pattern

Display placeholder content while fetching:

```javascript
function renderSkeletons(count = 5) {
  const container = document.querySelector('.items-container');
  const fragment = document.createDocumentFragment();
  
  for (let i = 0; i < count; i++) {
    const skeleton = document.createElement('div');
    skeleton.className = 'skeleton-item';
    skeleton.innerHTML = `
      <div class="skeleton-avatar"></div>
      <div class="skeleton-text"></div>
      <div class="skeleton-text short"></div>
    `;
    fragment.appendChild(skeleton);
  }
  
  container.appendChild(fragment);
}

function removeSkeletons() {
  document.querySelectorAll('.skeleton-item').forEach(el => el.remove());
}

// In loadMore function
async function loadMore() {
  renderSkeletons();
  try {
    const data = await fetchData();
    removeSkeletons();
    renderItems(data);
  } catch (error) {
    removeSkeletons();
    handleError(error);
  }
}
```

### Prefetching Strategy

Anticipate user behavior and preload next page:

```javascript
class PrefetchManager {
  constructor(prefetchThreshold = 2) {
    this.prefetchThreshold = prefetchThreshold; // pages ahead
    this.prefetchedData = new Map();
  }
  
  async prefetch(page) {
    if (this.prefetchedData.has(page)) return;
    
    try {
      const response = await fetch(`/api/items?page=${page}&limit=20`);
      const data = await response.json();
      this.prefetchedData.set(page, data);
      
      // Clean old cached data
      if (this.prefetchedData.size > 5) {
        const oldestKey = this.prefetchedData.keys().next().value;
        this.prefetchedData.delete(oldestKey);
      }
    } catch (error) {
      console.warn(`Prefetch failed for page ${page}`, error);
    }
  }
  
  async getPage(page) {
    // Trigger prefetch of next page
    this.prefetch(page + this.prefetchThreshold);
    
    if (this.prefetchedData.has(page)) {
      const data = this.prefetchedData.get(page);
      this.prefetchedData.delete(page);
      return data;
    }
    
    // Fallback to normal fetch
    const response = await fetch(`/api/items?page=${page}&limit=20`);
    return response.json();
  }
}
```

### Abort and Cleanup

Properly cancel requests when component unmounts or user navigates:

```javascript
class InfiniteScrollController {
  constructor() {
    this.abortController = null;
    this.observer = null;
  }
  
  async load() {
    // Abort previous request
    this.abort();
    
    this.abortController = new AbortController();
    
    try {
      const response = await fetch('/api/items', {
        signal: this.abortController.signal
      });
      // Process response...
    } catch (error) {
      if (error.name === 'AbortError') {
        console.log('Request cancelled');
        return;
      }
      throw error;
    }
  }
  
  abort() {
    if (this.abortController) {
      this.abortController.abort();
      this.abortController = null;
    }
  }
  
  destroy() {
    this.abort();
    
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
    
    window.removeEventListener('scroll', this.scrollHandler);
  }
}

// Usage
const controller = new InfiniteScrollController();

// When navigating away or unmounting
controller.destroy();
```

### Handling Network Conditions

Adapt behavior based on connection quality:

```javascript
class AdaptiveInfiniteScroll {
  constructor() {
    this.connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
    this.itemsPerPage = this.getOptimalPageSize();
  }
  
  getOptimalPageSize() {
    if (!this.connection) return 20;
    
    const effectiveType = this.connection.effectiveType;
    
    switch (effectiveType) {
      case 'slow-2g':
      case '2g':
        return 5;
      case '3g':
        return 10;
      case '4g':
        return 20;
      default:
        return 20;
    }
  }
  
  updatePageSize() {
    this.itemsPerPage = this.getOptimalPageSize();
  }
  
  init() {
    if (this.connection) {
      this.connection.addEventListener('change', () => {
        this.updatePageSize();
      });
    }
  }
  
  async fetchItems(page) {
    const url = `/api/items?page=${page}&limit=${this.itemsPerPage}`;
    const response = await fetch(url);
    return response.json();
  }
}
```

### Data Synchronization

Handle real-time updates while maintaining scroll position:

```javascript
class SyncedInfiniteScroll {
  constructor() {
    this.items = [];
    this.newItemsQueue = [];
    this.syncInterval = null;
  }
  
  startSync(intervalMs = 30000) {
    this.syncInterval = setInterval(() => {
      this.checkForNewItems();
    }, intervalMs);
  }
  
  async checkForNewItems() {
    const latestId = this.items[0]?.id;
    if (!latestId) return;
    
    const response = await fetch(`/api/items/since/${latestId}`);
    const newItems = await response.json();
    
    if (newItems.length > 0) {
      this.newItemsQueue.push(...newItems);
      this.showNewItemsNotification(newItems.length);
    }
  }
  
  showNewItemsNotification(count) {
    const notification = document.createElement('div');
    notification.className = 'new-items-notification';
    notification.textContent = `${count} new items available`;
    notification.onclick = () => this.prependNewItems();
    document.body.appendChild(notification);
  }
  
  prependNewItems() {
    if (this.newItemsQueue.length === 0) return;
    
    // Save scroll position
    const scrollTop = window.pageYOffset;
    const firstItem = document.querySelector('.item');
    const firstItemOffset = firstItem?.offsetTop || 0;
    
    // Prepend items
    this.items.unshift(...this.newItemsQueue);
    this.renderItems(this.newItemsQueue, 'prepend');
    
    // Restore scroll position
    const newOffset = firstItem?.offsetTop || 0;
    window.scrollTo(0, scrollTop + (newOffset - firstItemOffset));
    
    this.newItemsQueue = [];
  }
  
  stopSync() {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
    }
  }
}
```

### Memory Management

Prevent memory leaks with large datasets:

```javascript
class MemoryEfficientScroll {
  constructor(maxItems = 200) {
    this.maxItems = maxItems;
    this.items = [];
    this.removedCount = 0;
  }
  
  addItems(newItems) {
    this.items.push(...newItems);
    
    // Remove old items if exceeding limit
    if (this.items.length > this.maxItems) {
      const removeCount = this.items.length - this.maxItems;
      this.items.splice(0, removeCount);
      this.removedCount += removeCount;
      
      // Remove corresponding DOM elements
      this.removeOldDOMElements(removeCount);
    }
  }
  
  removeOldDOMElements(count) {
    const container = document.querySelector('.items-container');
    const elements = container.querySelectorAll('.item');
    
    for (let i = 0; i < count && i < elements.length; i++) {
      elements[i].remove();
    }
  }
  
  getTotalItemCount() {
    return this.removedCount + this.items.length;
  }
}
```

### Accessibility Considerations

Announce loading states to screen readers:

```javascript
class AccessibleInfiniteScroll {
  constructor() {
    this.liveRegion = this.createLiveRegion();
  }
  
  createLiveRegion() {
    const region = document.createElement('div');
    region.setAttribute('role', 'status');
    region.setAttribute('aria-live', 'polite');
    region.setAttribute('aria-atomic', 'true');
    region.className = 'sr-only';
    document.body.appendChild(region);
    return region;
  }
  
  announce(message) {
    this.liveRegion.textContent = message;
  }
  
  async loadMore() {
    this.announce('Loading more items');
    
    try {
      const data = await fetchData();
      this.renderItems(data);
      this.announce(`Loaded ${data.length} more items. ${this.getTotalCount()} items total.`);
    } catch (error) {
      this.announce('Failed to load more items. Please try again.');
    }
  }
  
  setupKeyboardNavigation() {
    // Allow keyboard users to trigger load more
    const loadButton = document.createElement('button');
    loadButton.textContent = 'Load more items';
    loadButton.onclick = () => this.loadMore();
    loadButton.className = 'load-more-button';
    document.querySelector('.container').appendChild(loadButton);
  }
}
```

### Complete Implementation Example

```javascript
class InfiniteScrollImplementation {
  constructor(config) {
    this.apiEndpoint = config.apiEndpoint;
    this.container = document.querySelector(config.container);
    this.itemRenderer = config.itemRenderer;
    
    // State
    this.page = 1;
    this.loading = false;
    this.hasMore = true;
    this.items = [];
    
    // Controllers
    this.abortController = null;
    this.observer = null;
    
    // Configuration
    this.pageSize = config.pageSize || 20;
    this.prefetchThreshold = config.prefetchThreshold || 200;
    
    this.init();
  }
  
  init() {
    this.setupIntersectionObserver();
    this.loadInitialData();
  }
  
  setupIntersectionObserver() {
    const sentinel = document.createElement('div');
    sentinel.className = 'scroll-sentinel';
    this.container.appendChild(sentinel);
    
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting && !this.loading && this.hasMore) {
            this.loadMore();
          }
        });
      },
      {
        root: null,
        rootMargin: `${this.prefetchThreshold}px`,
        threshold: 0
      }
    );
    
    this.observer.observe(sentinel);
  }
  
  async loadInitialData() {
    await this.loadMore();
  }
  
  async loadMore() {
    if (this.loading || !this.hasMore) return;
    
    this.loading = true;
    this.showLoader();
    
    if (this.abortController) {
      this.abortController.abort();
    }
    this.abortController = new AbortController();
    
    try {
      const response = await fetch(
        `${this.apiEndpoint}?page=${this.page}&limit=${this.pageSize}`,
        { signal: this.abortController.signal }
      );
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      const data = await response.json();
      
      if (data.items.length === 0) {
        this.hasMore = false;
        this.showEndMessage();
        return;
      }
      
      if (data.items.length < this.pageSize) {
        this.hasMore = false;
      }
      
      this.items.push(...data.items);
      this.renderItems(data.items);
      this.page++;
      
    } catch (error) {
      if (error.name !== 'AbortError') {
        this.handleError(error);
      }
    } finally {
      this.loading = false;
      this.hideLoader();
      this.abortController = null;
    }
  }
  
  renderItems(items) {
    const fragment = document.createDocumentFragment();
    
    items.forEach(item => {
      const element = this.itemRenderer(item);
      fragment.appendChild(element);
    });
    
    const sentinel = this.container.querySelector('.scroll-sentinel');
    this.container.insertBefore(fragment, sentinel);
  }
  
  showLoader() {
    const loader = this.container.querySelector('.loader');
    if (loader) loader.classList.add('active');
  }
  
  hideLoader() {
    const loader = this.container.querySelector('.loader');
    if (loader) loader.classList.remove('active');
  }
  
  showEndMessage() {
    const message = document.createElement('div');
    message.className = 'end-message';
    message.textContent = 'No more items to load';
    const sentinel = this.container.querySelector('.scroll-sentinel');
    this.container.insertBefore(message, sentinel);
  }
  
  handleError(error) {
    console.error('Failed to load items:', error);
    const errorEl = document.createElement('div');
    errorEl.className = 'error-message';
    errorEl.textContent = 'Failed to load items. Click to retry.';
    errorEl.onclick = () => {
      errorEl.remove();
      this.loadMore();
    };
    const sentinel = this.container.querySelector('.scroll-sentinel');
    this.container.insertBefore(errorEl, sentinel);
  }
  
  reset() {
    this.page = 1;
    this.loading = false;
    this.hasMore = true;
    this.items = [];
    
    // Clear container except sentinel
    const sentinel = this.container.querySelector('.scroll-sentinel');
    this.container.innerHTML = '';
    this.container.appendChild(sentinel);
    
    this.loadMore();
  }
  
  destroy() {
    if (this.abortController) {
      this.abortController.abort();
    }
    
    if (this.observer) {
      this.observer.disconnect();
    }
  }
}

// Usage
const infiniteScroll = new InfiniteScrollImplementation({
  apiEndpoint: '/api/items',
  container: '.items-container',
  pageSize: 20,
  prefetchThreshold: 200,
  itemRenderer: (item) => {
    const div = document.createElement('div');
    div.className = 'item';
    div.innerHTML = `
      <h3>${item.title}</h3>
      <p>${item.description}</p>
    `;
    return div;
  }
});
```

---

