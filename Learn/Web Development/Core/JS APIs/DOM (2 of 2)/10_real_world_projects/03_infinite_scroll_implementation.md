## Infinite Scroll Implementation


### Core Implementation Patterns

Infinite scroll requires three fundamental components: scroll detection, content loading, and DOM management. The scroll detection determines when to trigger loading, content loading fetches and renders new items, and DOM management prevents memory issues as the list grows.

### Scroll Detection Methods

#### Intersection Observer API

The modern approach uses Intersection Observer to detect when a sentinel element enters the viewport:

```javascript
const sentinel = document.querySelector('.sentinel');
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting && !isLoading) {
      loadMoreContent();
    }
  });
}, {
  rootMargin: '200px' // Trigger 200px before reaching sentinel
});

observer.observe(sentinel);
```

The `rootMargin` parameter controls the trigger distance. Positive values load content before the user reaches the bottom, improving perceived performance. Negative values delay loading until after the sentinel is visible.

#### Scroll Event Listener

Legacy implementations calculate scroll position manually:

```javascript
window.addEventListener('scroll', () => {
  const scrollTop = window.scrollY;
  const windowHeight = window.innerHeight;
  const docHeight = document.documentElement.scrollHeight;
  
  if (scrollTop + windowHeight >= docHeight - 300 && !isLoading) {
    loadMoreContent();
  }
});
```

This approach requires throttling or debouncing to limit calculation frequency:

```javascript
let scrollTimeout;
window.addEventListener('scroll', () => {
  clearTimeout(scrollTimeout);
  scrollTimeout = setTimeout(() => {
    // Scroll position check
  }, 150);
});
```

### State Management

Track loading state, current page/offset, and whether more content exists:

```javascript
let state = {
  isLoading: false,
  currentPage: 1,
  hasMore: true,
  items: []
};

async function loadMoreContent() {
  if (state.isLoading || !state.hasMore) return;
  
  state.isLoading = true;
  showLoadingIndicator();
  
  try {
    const newItems = await fetchContent(state.currentPage);
    
    if (newItems.length === 0) {
      state.hasMore = false;
      hideLoadingIndicator();
      showEndMessage();
      return;
    }
    
    state.items.push(...newItems);
    state.currentPage++;
    renderItems(newItems);
  } catch (error) {
    handleError(error);
  } finally {
    state.isLoading = false;
    hideLoadingIndicator();
  }
}
```

### DOM Rendering Strategies

#### Append-Only Rendering

The simplest approach appends new items to the container:

```javascript
function renderItems(items) {
  const container = document.querySelector('.content-container');
  const fragment = document.createDocumentFragment();
  
  items.forEach(item => {
    const element = createItemElement(item);
    fragment.appendChild(element);
  });
  
  container.appendChild(fragment);
}
```

DocumentFragment batches DOM operations, reducing reflows.

#### Virtual Scrolling

For lists with thousands of items, virtual scrolling renders only visible elements:

```javascript
class VirtualScroller {
  constructor(container, itemHeight, renderItem) {
    this.container = container;
    this.itemHeight = itemHeight;
    this.renderItem = renderItem;
    this.items = [];
    this.visibleStart = 0;
    this.visibleEnd = 0;
    
    this.container.addEventListener('scroll', () => this.onScroll());
  }
  
  setItems(items) {
    this.items = items;
    this.container.style.height = `${items.length * this.itemHeight}px`;
    this.render();
  }
  
  onScroll() {
    const scrollTop = this.container.scrollTop;
    const viewportHeight = this.container.clientHeight;
    
    this.visibleStart = Math.floor(scrollTop / this.itemHeight);
    this.visibleEnd = Math.ceil((scrollTop + viewportHeight) / this.itemHeight);
    
    this.render();
  }
  
  render() {
    const visible = this.items.slice(this.visibleStart, this.visibleEnd);
    const offsetY = this.visibleStart * this.itemHeight;
    
    this.container.innerHTML = '';
    const wrapper = document.createElement('div');
    wrapper.style.transform = `translateY(${offsetY}px)`;
    
    visible.forEach(item => {
      wrapper.appendChild(this.renderItem(item));
    });
    
    this.container.appendChild(wrapper);
  }
}
```

#### Windowing with Buffer

Maintain a sliding window of rendered items with buffer zones:

```javascript
const WINDOW_SIZE = 50;
const BUFFER_SIZE = 10;

function maintainWindow() {
  const allItems = document.querySelectorAll('.item');
  const scrollTop = window.scrollY;
  const viewportHeight = window.innerHeight;
  
  allItems.forEach((item, index) => {
    const rect = item.getBoundingClientRect();
    const isInViewport = rect.top < viewportHeight && rect.bottom > 0;
    const isInBuffer = Math.abs(rect.top) < viewportHeight * 2;
    
    if (!isInViewport && !isInBuffer && allItems.length > WINDOW_SIZE) {
      item.remove();
      // Store removed item data for potential re-rendering
    }
  });
}
```

### Performance Optimizations

#### Request Batching and Caching

Batch multiple rapid scroll triggers into single requests:

```javascript
let loadTimeout;
let pendingLoad = false;

function requestLoad() {
  if (pendingLoad) return;
  
  pendingLoad = true;
  clearTimeout(loadTimeout);
  
  loadTimeout = setTimeout(() => {
    pendingLoad = false;
    loadMoreContent();
  }, 100);
}
```

Cache loaded pages to prevent redundant fetches:

```javascript
const cache = new Map();

async function fetchContent(page) {
  if (cache.has(page)) {
    return cache.get(page);
  }
  
  const data = await fetch(`/api/items?page=${page}`).then(r => r.json());
  cache.set(page, data);
  return data;
}
```

#### Image Lazy Loading

Defer image loading for off-screen content:

```javascript
function createItemElement(item) {
  const el = document.createElement('div');
  el.innerHTML = `
    <img data-src="${item.imageUrl}" 
         src="placeholder.jpg"
         class="lazy-image">
  `;
  return el;
}

const imageObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const img = entry.target;
      img.src = img.dataset.src;
      img.classList.remove('lazy-image');
      imageObserver.unobserve(img);
    }
  });
});

// Observe images after rendering
document.querySelectorAll('.lazy-image').forEach(img => {
  imageObserver.observe(img);
});
```

#### RequestAnimationFrame for Smooth Updates

Synchronize DOM updates with browser paint cycles:

```javascript
let rafId;
let itemsToRender = [];

function scheduleRender(items) {
  itemsToRender.push(...items);
  
  if (!rafId) {
    rafId = requestAnimationFrame(() => {
      renderBatch(itemsToRender);
      itemsToRender = [];
      rafId = null;
    });
  }
}

function renderBatch(items) {
  const fragment = document.createDocumentFragment();
  items.forEach(item => fragment.appendChild(createItemElement(item)));
  container.appendChild(fragment);
}
```

### Scroll Position Management

#### Restoring Position on Back Navigation

Preserve scroll position when users navigate away and return:

```javascript
// Before navigation
window.addEventListener('beforeunload', () => {
  sessionStorage.setItem('scrollPos', window.scrollY);
  sessionStorage.setItem('loadedPage', state.currentPage);
});

// On page load
window.addEventListener('load', async () => {
  const savedScroll = sessionStorage.getItem('scrollPos');
  const savedPage = sessionStorage.getItem('loadedPage');
  
  if (savedScroll && savedPage) {
    // Load content up to saved page
    for (let i = 1; i <= savedPage; i++) {
      const items = await fetchContent(i);
      renderItems(items);
    }
    
    // Restore scroll position
    window.scrollTo(0, parseInt(savedScroll));
    
    sessionStorage.removeItem('scrollPos');
    sessionStorage.removeItem('loadedPage');
  }
});
```

#### Scroll Anchoring

Prevent layout shifts when content loads above viewport:

```css
.content-container {
  overflow-anchor: auto;
}
```

For manual control:

```javascript
function insertContentAbove(items) {
  const currentScroll = window.scrollY;
  const oldHeight = document.documentElement.scrollHeight;
  
  prependItems(items);
  
  const newHeight = document.documentElement.scrollHeight;
  const heightDiff = newHeight - oldHeight;
  
  window.scrollTo(0, currentScroll + heightDiff);
}
```

### Bidirectional Infinite Scroll

Support loading content in both directions:

```javascript
let state = {
  topPage: 0,
  bottomPage: 1,
  isLoadingTop: false,
  isLoadingBottom: false,
  hasMoreTop: true,
  hasMoreBottom: true
};

const topSentinel = document.querySelector('.top-sentinel');
const bottomSentinel = document.querySelector('.bottom-sentinel');

const topObserver = new IntersectionObserver((entries) => {
  if (entries[0].isIntersecting && !state.isLoadingTop && state.hasMoreTop) {
    loadContentAbove();
  }
});

const bottomObserver = new IntersectionObserver((entries) => {
  if (entries[0].isIntersecting && !state.isLoadingBottom && state.hasMoreBottom) {
    loadContentBelow();
  }
});

topObserver.observe(topSentinel);
bottomObserver.observe(bottomSentinel);

async function loadContentAbove() {
  state.isLoadingTop = true;
  const items = await fetchContent(state.topPage - 1);
  
  if (items.length === 0) {
    state.hasMoreTop = false;
    return;
  }
  
  state.topPage--;
  insertContentAbove(items);
  state.isLoadingTop = false;
}
```

### Error Handling and Recovery

Implement retry logic for failed requests:

```javascript
async function fetchWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return await response.json();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, Math.pow(2, i) * 1000));
    }
  }
}

function handleError(error) {
  state.isLoading = false;
  hideLoadingIndicator();
  
  const errorDiv = document.createElement('div');
  errorDiv.className = 'load-error';
  errorDiv.innerHTML = `
    <p>Failed to load content</p>
    <button onclick="retryLoad()">Retry</button>
  `;
  container.appendChild(errorDiv);
}

function retryLoad() {
  document.querySelector('.load-error')?.remove();
  loadMoreContent();
}
```

### Loading Indicators

Provide visual feedback during content loading:

```javascript
function showLoadingIndicator() {
  const loader = document.createElement('div');
  loader.className = 'loading-indicator';
  loader.innerHTML = `
    <div class="spinner"></div>
    <p>Loading more items...</p>
  `;
  container.appendChild(loader);
}

function hideLoadingIndicator() {
  document.querySelector('.loading-indicator')?.remove();
}

// Skeleton screens for better perceived performance
function showSkeletons(count = 5) {
  const fragment = document.createDocumentFragment();
  for (let i = 0; i < count; i++) {
    const skeleton = document.createElement('div');
    skeleton.className = 'skeleton-item';
    fragment.appendChild(skeleton);
  }
  container.appendChild(fragment);
}

function removeSkeletons() {
  document.querySelectorAll('.skeleton-item').forEach(el => el.remove());
}
```

### Memory Management

Monitor and limit memory usage:

```javascript
const MAX_ITEMS = 500;

function pruneOldItems() {
  const items = document.querySelectorAll('.item');
  
  if (items.length > MAX_ITEMS) {
    const toRemove = items.length - MAX_ITEMS;
    
    // Remove items far from viewport
    for (let i = 0; i < toRemove; i++) {
      items[i].remove();
    }
    
    // Update state
    state.items = state.items.slice(toRemove);
  }
}

// Monitor memory usage (if available)
if (performance.memory) {
  setInterval(() => {
    const usedMemory = performance.memory.usedJSHeapSize;
    const totalMemory = performance.memory.jsHeapSizeLimit;
    
    if (usedMemory / totalMemory > 0.9) {
      console.warn('High memory usage, pruning items');
      pruneOldItems();
    }
  }, 5000);
}
```

### Accessibility Considerations

Announce new content to screen readers:

```javascript
function announceNewContent(count) {
  const announcement = document.createElement('div');
  announcement.setAttribute('role', 'status');
  announcement.setAttribute('aria-live', 'polite');
  announcement.className = 'sr-only';
  announcement.textContent = `Loaded ${count} more items`;
  
  document.body.appendChild(announcement);
  
  setTimeout(() => announcement.remove(), 1000);
}

// Allow keyboard navigation to load more
bottomSentinel.setAttribute('tabindex', '0');
bottomSentinel.addEventListener('focus', () => {
  if (!state.isLoading && state.hasMore) {
    loadMoreContent();
  }
});
```

Provide a "Load More" button alternative:

```javascript
function createLoadMoreButton() {
  const button = document.createElement('button');
  button.textContent = 'Load More';
  button.className = 'load-more-btn';
  button.onclick = loadMoreContent;
  return button;
}

// Toggle between automatic and manual loading
let autoLoad = true;

function toggleLoadMode() {
  autoLoad = !autoLoad;
  
  if (autoLoad) {
    observer.observe(sentinel);
    document.querySelector('.load-more-btn')?.remove();
  } else {
    observer.unobserve(sentinel);
    container.appendChild(createLoadMoreButton());
  }
}
```

### URL and History Management

Update URL as user scrolls through content:

```javascript
function updateURLForPage(page) {
  const url = new URL(window.location);
  url.searchParams.set('page', page);
  history.replaceState({ page }, '', url);
}

// Update as content loads
async function loadMoreContent() {
  // ... loading logic
  updateURLForPage(state.currentPage);
}

// Handle browser back/forward
window.addEventListener('popstate', (event) => {
  if (event.state?.page) {
    // Load content for specific page
    loadToPage(event.state.page);
  }
});
```

### Pagination Fallback

Support pagination for scenarios where infinite scroll fails:

```javascript
function initializeScrollOrPagination() {
  // Feature detection
  const supportsIntersectionObserver = 'IntersectionObserver' in window;
  const isLowEndDevice = navigator.hardwareConcurrency < 4;
  
  if (!supportsIntersectionObserver || isLowEndDevice) {
    enablePaginationMode();
  } else {
    enableInfiniteScrollMode();
  }
}

function enablePaginationMode() {
  createPaginationControls();
  container.dataset.mode = 'pagination';
}

function createPaginationControls() {
  const controls = document.createElement('div');
  controls.className = 'pagination-controls';
  controls.innerHTML = `
    <button onclick="loadPreviousPage()">Previous</button>
    <span class="page-number">Page ${state.currentPage}</span>
    <button onclick="loadNextPage()">Next</button>
  `;
  container.after(controls);
}
```

### Testing Strategies

Simulate scroll events for testing:

```javascript
function simulateScroll(position) {
  window.scrollTo(0, position);
  window.dispatchEvent(new Event('scroll'));
}

function testInfiniteScroll() {
  const docHeight = document.documentElement.scrollHeight;
  
  // Scroll near bottom
  simulateScroll(docHeight - 400);
  
  // Wait for loading
  setTimeout(() => {
    console.assert(state.isLoading, 'Should trigger loading');
  }, 100);
}

// Mock intersection observer for testing
class MockIntersectionObserver {
  constructor(callback) {
    this.callback = callback;
  }
  
  observe(element) {
    this.element = element;
  }
  
  simulateIntersection(isIntersecting) {
    this.callback([{
      target: this.element,
      isIntersecting
    }]);
  }
}
```

### Complete Implementation Example

```javascript
class InfiniteScroll {
  constructor(container, options = {}) {
    this.container = container;
    this.options = {
      threshold: 200,
      pageSize: 20,
      maxItems: 500,
      fetchFunction: null,
      renderFunction: null,
      ...options
    };
    
    this.state = {
      isLoading: false,
      currentPage: 1,
      hasMore: true,
      items: []
    };
    
    this.init();
  }
  
  init() {
    this.createSentinel();
    this.setupObserver();
    this.loadInitialContent();
  }
  
  createSentinel() {
    this.sentinel = document.createElement('div');
    this.sentinel.className = 'scroll-sentinel';
    this.container.appendChild(this.sentinel);
  }
  
  setupObserver() {
    this.observer = new IntersectionObserver(
      (entries) => this.onIntersection(entries),
      { rootMargin: `${this.options.threshold}px` }
    );
    this.observer.observe(this.sentinel);
  }
  
  onIntersection(entries) {
    if (entries[0].isIntersecting && !this.state.isLoading && this.state.hasMore) {
      this.loadMore();
    }
  }
  
  async loadInitialContent() {
    await this.loadMore();
  }
  
  async loadMore() {
    if (this.state.isLoading || !this.state.hasMore) return;
    
    this.state.isLoading = true;
    this.showLoading();
    
    try {
      const newItems = await this.options.fetchFunction(
        this.state.currentPage,
        this.options.pageSize
      );
      
      if (newItems.length === 0) {
        this.state.hasMore = false;
        this.showEndMessage();
        return;
      }
      
      this.state.items.push(...newItems);
      this.state.currentPage++;
      this.render(newItems);
      this.pruneIfNeeded();
      
    } catch (error) {
      this.handleError(error);
    } finally {
      this.state.isLoading = false;
      this.hideLoading();
    }
  }
  
  render(items) {
    const fragment = document.createDocumentFragment();
    
    items.forEach(item => {
      const element = this.options.renderFunction(item);
      fragment.appendChild(element);
    });
    
    this.container.insertBefore(fragment, this.sentinel);
  }
  
  pruneIfNeeded() {
    if (this.state.items.length > this.options.maxItems) {
      const toRemove = this.state.items.length - this.options.maxItems;
      const itemElements = this.container.querySelectorAll('.item');
      
      for (let i = 0; i < toRemove; i++) {
        itemElements[i]?.remove();
      }
      
      this.state.items = this.state.items.slice(toRemove);
    }
  }
  
  showLoading() {
    const loader = document.createElement('div');
    loader.className = 'loading-indicator';
    loader.textContent = 'Loading...';
    this.container.insertBefore(loader, this.sentinel);
  }
  
  hideLoading() {
    this.container.querySelector('.loading-indicator')?.remove();
  }
  
  showEndMessage() {
    const message = document.createElement('div');
    message.className = 'end-message';
    message.textContent = 'No more items';
    this.container.appendChild(message);
  }
  
  handleError(error) {
    console.error('Failed to load content:', error);
    // Implement retry logic here
  }
  
  destroy() {
    this.observer.disconnect();
    this.sentinel.remove();
  }
}

// Usage
const scroller = new InfiniteScroll(
  document.querySelector('.content'),
  {
    fetchFunction: async (page, size) => {
      const response = await fetch(`/api/items?page=${page}&size=${size}`);
      return response.json();
    },
    renderFunction: (item) => {
      const div = document.createElement('div');
      div.className = 'item';
      div.textContent = item.title;
      return div;
    }
  }
);
```

---

