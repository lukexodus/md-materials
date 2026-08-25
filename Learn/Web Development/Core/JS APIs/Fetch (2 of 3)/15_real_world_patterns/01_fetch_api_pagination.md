## Fetch API Pagination


### Pagination Strategies

#### Offset-Based Pagination

Offset-based pagination uses `limit` and `offset` (or `skip`) parameters to navigate through pages. The offset specifies how many records to skip, while the limit defines the page size.

```javascript
async function fetchPageOffset(page, pageSize) {
  const offset = (page - 1) * pageSize;
  const response = await fetch(
    `https://api.example.com/items?limit=${pageSize}&offset=${offset}`
  );
  return response.json();
}

// Fetch multiple pages
async function fetchAllPagesOffset(pageSize) {
  const allItems = [];
  let page = 1;
  let hasMore = true;

  while (hasMore) {
    const data = await fetchPageOffset(page, pageSize);
    allItems.push(...data.items);
    hasMore = data.items.length === pageSize;
    page++;
  }

  return allItems;
}
```

**Advantages:** Simple implementation, direct page access, easy to calculate total pages.

**Disadvantages:** Performance degrades with large offsets as databases must scan and skip records. Data inconsistency occurs if items are added or deleted between requests (page drift).

#### Cursor-Based Pagination

Cursor-based pagination uses a pointer (cursor) to track position in the dataset. The cursor typically encodes the last item's identifier or timestamp.

```javascript
async function fetchPageCursor(cursor, pageSize) {
  const url = new URL('https://api.example.com/items');
  url.searchParams.set('limit', pageSize);
  if (cursor) {
    url.searchParams.set('cursor', cursor);
  }

  const response = await fetch(url);
  return response.json();
}

// Fetch all pages using cursors
async function fetchAllPagesCursor(pageSize) {
  const allItems = [];
  let cursor = null;

  while (true) {
    const data = await fetchPageCursor(cursor, pageSize);
    allItems.push(...data.items);
    
    if (!data.next_cursor) break;
    cursor = data.next_cursor;
  }

  return allItems;
}
```

**Advantages:** Consistent performance regardless of dataset size, no page drift issues, efficient for infinite scroll.

**Disadvantages:** Cannot jump to arbitrary pages, more complex implementation, cursor format varies by API.

#### Page-Based Pagination

Page-based pagination uses explicit page numbers, similar to offset-based but with a clearer semantic.

```javascript
async function fetchPage(pageNumber, pageSize) {
  const response = await fetch(
    `https://api.example.com/items?page=${pageNumber}&per_page=${pageSize}`
  );
  const data = await response.json();
  
  return {
    items: data.items,
    currentPage: data.page,
    totalPages: data.total_pages,
    totalItems: data.total
  };
}

// Navigate through pages
async function fetchPageRange(startPage, endPage, pageSize) {
  const promises = [];
  
  for (let page = startPage; page <= endPage; page++) {
    promises.push(fetchPage(page, pageSize));
  }
  
  return Promise.all(promises);
}
```

#### Keyset Pagination

Keyset pagination (also called seek method) uses the values from the last retrieved record to fetch the next set. This typically involves filtering by a unique, ordered column.

```javascript
async function fetchPageKeyset(lastId, pageSize) {
  const url = new URL('https://api.example.com/items');
  url.searchParams.set('limit', pageSize);
  if (lastId) {
    url.searchParams.set('after_id', lastId);
  }

  const response = await fetch(url);
  return response.json();
}

// Fetch with composite keys (id + timestamp)
async function fetchPageKeysetComposite(lastId, lastTimestamp, pageSize) {
  const url = new URL('https://api.example.com/items');
  url.searchParams.set('limit', pageSize);
  
  if (lastId && lastTimestamp) {
    url.searchParams.set('after_id', lastId);
    url.searchParams.set('after_timestamp', lastTimestamp);
  }

  const response = await fetch(url);
  return response.json();
}
```

**Advantages:** Excellent performance, consistent results, works well with indexes.

**Disadvantages:** Requires ordered, indexed columns, bidirectional navigation is complex.

### Advanced Pagination Patterns

#### Concurrent Page Fetching

```javascript
async function fetchMultiplePagesParallel(startPage, endPage, pageSize) {
  const pagePromises = [];
  
  for (let page = startPage; page <= endPage; page++) {
    pagePromises.push(
      fetch(`https://api.example.com/items?page=${page}&per_page=${pageSize}`)
        .then(res => res.json())
    );
  }
  
  const results = await Promise.all(pagePromises);
  return results.flatMap(result => result.items);
}

// With concurrency limit
async function fetchPagesWithLimit(totalPages, pageSize, concurrency = 5) {
  const allItems = [];
  
  for (let i = 1; i <= totalPages; i += concurrency) {
    const batch = [];
    const end = Math.min(i + concurrency - 1, totalPages);
    
    for (let page = i; page <= end; page++) {
      batch.push(
        fetch(`https://api.example.com/items?page=${page}&per_page=${pageSize}`)
          .then(res => res.json())
      );
    }
    
    const results = await Promise.all(batch);
    allItems.push(...results.flatMap(r => r.items));
  }
  
  return allItems;
}
```

#### Prefetching Next Page

```javascript
class PaginationPrefetcher {
  constructor(baseUrl, pageSize) {
    this.baseUrl = baseUrl;
    this.pageSize = pageSize;
    this.cache = new Map();
    this.prefetchPromises = new Map();
  }

  async fetchPage(page) {
    // Return from cache if available
    if (this.cache.has(page)) {
      return this.cache.get(page);
    }

    // Wait for prefetch if in progress
    if (this.prefetchPromises.has(page)) {
      return this.prefetchPromises.get(page);
    }

    // Fetch current page
    const promise = this._doFetch(page);
    this.prefetchPromises.set(page, promise);
    
    const data = await promise;
    this.cache.set(page, data);
    this.prefetchPromises.delete(page);

    // Prefetch next page
    this._prefetchPage(page + 1);

    return data;
  }

  _prefetchPage(page) {
    if (!this.cache.has(page) && !this.prefetchPromises.has(page)) {
      const promise = this._doFetch(page);
      this.prefetchPromises.set(page, promise);
      
      promise.then(data => {
        this.cache.set(page, data);
        this.prefetchPromises.delete(page);
      }).catch(() => {
        this.prefetchPromises.delete(page);
      });
    }
  }

  async _doFetch(page) {
    const response = await fetch(
      `${this.baseUrl}?page=${page}&per_page=${this.pageSize}`
    );
    return response.json();
  }
}
```

#### Infinite Scroll Implementation

```javascript
class InfiniteScrollPaginator {
  constructor(apiUrl, pageSize, container) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
    this.container = container;
    this.currentPage = 1;
    this.loading = false;
    this.hasMore = true;
    
    this.setupIntersectionObserver();
  }

  setupIntersectionObserver() {
    const sentinel = document.createElement('div');
    sentinel.className = 'scroll-sentinel';
    this.container.appendChild(sentinel);

    this.observer = new IntersectionObserver(
      entries => {
        if (entries[0].isIntersecting && !this.loading && this.hasMore) {
          this.loadMore();
        }
      },
      { threshold: 0.1 }
    );

    this.observer.observe(sentinel);
  }

  async loadMore() {
    if (this.loading || !this.hasMore) return;

    this.loading = true;

    try {
      const response = await fetch(
        `${this.apiUrl}?page=${this.currentPage}&per_page=${this.pageSize}`
      );
      const data = await response.json();

      this.renderItems(data.items);
      this.currentPage++;
      this.hasMore = data.items.length === this.pageSize;
    } catch (error) {
      console.error('Failed to load more:', error);
    } finally {
      this.loading = false;
    }
  }

  renderItems(items) {
    // Implementation depends on UI framework
    items.forEach(item => {
      const element = this.createItemElement(item);
      this.container.insertBefore(
        element,
        this.container.querySelector('.scroll-sentinel')
      );
    });
  }
}
```

#### Bidirectional Pagination

```javascript
class BidirectionalPaginator {
  constructor(apiUrl, pageSize) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
  }

  async fetchNext(cursor) {
    const url = new URL(this.apiUrl);
    url.searchParams.set('limit', this.pageSize);
    if (cursor) {
      url.searchParams.set('after', cursor);
    }

    const response = await fetch(url);
    const data = await response.json();

    return {
      items: data.items,
      nextCursor: data.next_cursor,
      prevCursor: data.items.length > 0 ? data.items[0].id : null
    };
  }

  async fetchPrevious(cursor) {
    const url = new URL(this.apiUrl);
    url.searchParams.set('limit', this.pageSize);
    url.searchParams.set('before', cursor);

    const response = await fetch(url);
    const data = await response.json();

    return {
      items: data.items.reverse(), // Often returned in reverse order
      nextCursor: data.items.length > 0 ? data.items[data.items.length - 1].id : null,
      prevCursor: data.prev_cursor
    };
  }
}
```

### Error Handling and Retry Logic

#### Retry with Exponential Backoff

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  let lastError;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return await response.json();
    } catch (error) {
      lastError = error;
      
      if (attempt < maxRetries) {
        const delay = Math.min(1000 * Math.pow(2, attempt), 10000);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError;
}

// Usage in pagination
async function fetchPageWithRetry(page, pageSize) {
  const url = `https://api.example.com/items?page=${page}&per_page=${pageSize}`;
  return fetchWithRetry(url);
}
```

#### Handling Rate Limits

```javascript
class RateLimitedPaginator {
  constructor(apiUrl, pageSize, requestsPerSecond = 10) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
    this.minInterval = 1000 / requestsPerSecond;
    this.lastRequestTime = 0;
  }

  async fetchPage(page) {
    // Throttle requests
    const now = Date.now();
    const timeSinceLastRequest = now - this.lastRequestTime;
    
    if (timeSinceLastRequest < this.minInterval) {
      await new Promise(resolve => 
        setTimeout(resolve, this.minInterval - timeSinceLastRequest)
      );
    }

    this.lastRequestTime = Date.now();

    const response = await fetch(
      `${this.apiUrl}?page=${page}&per_page=${this.pageSize}`
    );

    // Handle 429 Too Many Requests
    if (response.status === 429) {
      const retryAfter = response.headers.get('Retry-After');
      const delay = retryAfter ? parseInt(retryAfter) * 1000 : 5000;
      
      await new Promise(resolve => setTimeout(resolve, delay));
      return this.fetchPage(page); // Retry
    }

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    return response.json();
  }
}
```

#### Partial Failure Recovery

```javascript
async function fetchAllPagesWithRecovery(totalPages, pageSize) {
  const results = new Array(totalPages).fill(null);
  const failed = [];

  // First attempt: fetch all pages
  const promises = Array.from({ length: totalPages }, (_, i) => {
    const page = i + 1;
    return fetch(`https://api.example.com/items?page=${page}&per_page=${pageSize}`)
      .then(res => res.json())
      .then(data => {
        results[i] = data.items;
      })
      .catch(() => {
        failed.push(page);
      });
  });

  await Promise.allSettled(promises);

  // Retry failed pages
  if (failed.length > 0) {
    for (const page of failed) {
      try {
        const response = await fetch(
          `https://api.example.com/items?page=${page}&per_page=${pageSize}`
        );
        const data = await response.json();
        results[page - 1] = data.items;
      } catch (error) {
        console.error(`Failed to fetch page ${page}:`, error);
      }
    }
  }

  return results.filter(Boolean).flat();
}
```

### Response Parsing and Metadata

#### Extracting Pagination Metadata

```javascript
function parsePaginationHeaders(response) {
  const linkHeader = response.headers.get('Link');
  const totalCount = response.headers.get('X-Total-Count');
  const perPage = response.headers.get('X-Per-Page');
  const currentPage = response.headers.get('X-Page');

  const links = {};
  if (linkHeader) {
    linkHeader.split(',').forEach(link => {
      const [url, rel] = link.split(';').map(s => s.trim());
      const relMatch = rel.match(/rel="(.+)"/);
      if (relMatch) {
        links[relMatch[1]] = url.slice(1, -1); // Remove < >
      }
    });
  }

  return {
    total: totalCount ? parseInt(totalCount) : null,
    perPage: perPage ? parseInt(perPage) : null,
    currentPage: currentPage ? parseInt(currentPage) : null,
    totalPages: totalCount && perPage 
      ? Math.ceil(parseInt(totalCount) / parseInt(perPage))
      : null,
    links
  };
}

async function fetchWithMetadata(url) {
  const response = await fetch(url);
  const data = await response.json();
  const metadata = parsePaginationHeaders(response);

  return { data, metadata };
}
```

#### Link Header Parsing

```javascript
function parseNextPageUrl(response) {
  const linkHeader = response.headers.get('Link');
  if (!linkHeader) return null;

  const nextLinkMatch = linkHeader.match(/<([^>]+)>;\s*rel="next"/);
  return nextLinkMatch ? nextLinkMatch[1] : null;
}

async function fetchAllPagesFromLinks(initialUrl) {
  const allItems = [];
  let nextUrl = initialUrl;

  while (nextUrl) {
    const response = await fetch(nextUrl);
    const data = await response.json();
    
    allItems.push(...data.items);
    nextUrl = parseNextPageUrl(response);
  }

  return allItems;
}
```

#### Handling Different Response Formats

```javascript
class UniversalPaginator {
  constructor(apiUrl) {
    this.apiUrl = apiUrl;
  }

  async fetchPage(page, pageSize) {
    const response = await fetch(
      `${this.apiUrl}?page=${page}&per_page=${pageSize}`
    );
    const data = await response.json();

    // Detect format and normalize
    return this.normalizeResponse(data, response);
  }

  normalizeResponse(data, response) {
    // Format 1: { items: [], page: 1, total: 100 }
    if (data.items && Array.isArray(data.items)) {
      return {
        items: data.items,
        currentPage: data.page || data.current_page,
        totalPages: data.total_pages || data.pages,
        totalItems: data.total || data.total_count,
        hasNext: data.has_next || !!data.next_page
      };
    }

    // Format 2: { data: [], meta: { page: 1, total: 100 } }
    if (data.data && data.meta) {
      return {
        items: data.data,
        currentPage: data.meta.page || data.meta.current_page,
        totalPages: data.meta.total_pages || data.meta.pages,
        totalItems: data.meta.total || data.meta.total_count,
        hasNext: data.meta.has_next
      };
    }

    // Format 3: Array with headers
    if (Array.isArray(data)) {
      const metadata = parsePaginationHeaders(response);
      return {
        items: data,
        ...metadata,
        hasNext: !!metadata.links?.next
      };
    }

    // Format 4: { results: [], next: "url", previous: "url" }
    if (data.results) {
      return {
        items: data.results,
        nextUrl: data.next,
        previousUrl: data.previous,
        hasNext: !!data.next
      };
    }

    throw new Error('Unknown pagination format');
  }
}
```

### State Management

#### Pagination State Object

```javascript
class PaginationState {
  constructor(initialPage = 1, pageSize = 20) {
    this.currentPage = initialPage;
    this.pageSize = pageSize;
    this.totalPages = null;
    this.totalItems = null;
    this.items = [];
    this.loading = false;
    this.error = null;
    this.cursors = { next: null, prev: null };
  }

  setLoading(loading) {
    this.loading = loading;
    this.error = null;
  }

  setError(error) {
    this.loading = false;
    this.error = error;
  }

  setData(items, metadata) {
    this.items = items;
    this.totalPages = metadata.totalPages;
    this.totalItems = metadata.totalItems;
    this.cursors = metadata.cursors || this.cursors;
    this.loading = false;
    this.error = null;
  }

  nextPage() {
    if (this.hasNextPage()) {
      this.currentPage++;
      return true;
    }
    return false;
  }

  previousPage() {
    if (this.hasPreviousPage()) {
      this.currentPage--;
      return true;
    }
    return false;
  }

  goToPage(page) {
    if (page >= 1 && (!this.totalPages || page <= this.totalPages)) {
      this.currentPage = page;
      return true;
    }
    return false;
  }

  hasNextPage() {
    return !this.totalPages || this.currentPage < this.totalPages;
  }

  hasPreviousPage() {
    return this.currentPage > 1;
  }

  reset() {
    this.currentPage = 1;
    this.items = [];
    this.error = null;
  }
}
```

#### Cache Management

```javascript
class PaginationCache {
  constructor(maxSize = 50) {
    this.cache = new Map();
    this.maxSize = maxSize;
    this.accessOrder = [];
  }

  get(key) {
    if (this.cache.has(key)) {
      // Update access order
      this.accessOrder = this.accessOrder.filter(k => k !== key);
      this.accessOrder.push(key);
      return this.cache.get(key);
    }
    return null;
  }

  set(key, value) {
    // Remove oldest if at capacity
    if (this.cache.size >= this.maxSize && !this.cache.has(key)) {
      const oldest = this.accessOrder.shift();
      this.cache.delete(oldest);
    }

    this.cache.set(key, value);
    
    // Update access order
    this.accessOrder = this.accessOrder.filter(k => k !== key);
    this.accessOrder.push(key);
  }

  has(key) {
    return this.cache.has(key);
  }

  clear() {
    this.cache.clear();
    this.accessOrder = [];
  }

  getCacheKey(page, filters = {}) {
    const filterString = Object.keys(filters)
      .sort()
      .map(key => `${key}:${filters[key]}`)
      .join('|');
    return `page:${page}|${filterString}`;
  }
}

// Usage
class CachedPaginator {
  constructor(apiUrl, pageSize) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
    this.cache = new PaginationCache();
  }

  async fetchPage(page, filters = {}) {
    const cacheKey = this.cache.getCacheKey(page, filters);
    
    const cached = this.cache.get(cacheKey);
    if (cached) {
      return cached;
    }

    const url = new URL(this.apiUrl);
    url.searchParams.set('page', page);
    url.searchParams.set('per_page', this.pageSize);
    
    Object.entries(filters).forEach(([key, value]) => {
      url.searchParams.set(key, value);
    });

    const response = await fetch(url);
    const data = await response.json();

    this.cache.set(cacheKey, data);
    return data;
  }
}
```

### Performance Optimization

#### Request Deduplication

```javascript
class DeduplicatedPaginator {
  constructor(apiUrl, pageSize) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
    this.pendingRequests = new Map();
  }

  async fetchPage(page) {
    const key = `${page}`;

    // Return existing promise if request is in flight
    if (this.pendingRequests.has(key)) {
      return this.pendingRequests.get(key);
    }

    const promise = this._doFetch(page)
      .finally(() => {
        this.pendingRequests.delete(key);
      });

    this.pendingRequests.set(key, promise);
    return promise;
  }

  async _doFetch(page) {
    const response = await fetch(
      `${this.apiUrl}?page=${page}&per_page=${this.pageSize}`
    );
    return response.json();
  }
}
```

#### Batch Request Optimization

```javascript
async function fetchPagesInBatches(pageRange, pageSize, batchSize = 3) {
  const results = [];
  
  for (let i = 0; i < pageRange.length; i += batchSize) {
    const batch = pageRange.slice(i, i + batchSize);
    const batchPromises = batch.map(page =>
      fetch(`https://api.example.com/items?page=${page}&per_page=${pageSize}`)
        .then(res => res.json())
    );
    
    const batchResults = await Promise.all(batchPromises);
    results.push(...batchResults);
    
    // Optional: delay between batches
    if (i + batchSize < pageRange.length) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }
  }
  
  return results.flatMap(r => r.items);
}
```

#### Streaming Large Datasets

```javascript
async function* streamPages(apiUrl, pageSize) {
  let page = 1;
  let hasMore = true;

  while (hasMore) {
    const response = await fetch(
      `${apiUrl}?page=${page}&per_page=${pageSize}`
    );
    const data = await response.json();

    yield data.items;

    hasMore = data.items.length === pageSize;
    page++;
  }
}

// Usage
async function processAllItems(apiUrl, pageSize) {
  for await (const items of streamPages(apiUrl, pageSize)) {
    // Process each page as it arrives
    items.forEach(item => {
      console.log(item);
    });
  }
}
```

#### Progressive Loading

```javascript
class ProgressivePaginator {
  constructor(apiUrl, pageSize, onProgress) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
    this.onProgress = onProgress;
  }

  async fetchAll(estimatedTotal) {
    const allItems = [];
    let page = 1;
    let hasMore = true;

    while (hasMore) {
      const response = await fetch(
        `${this.apiUrl}?page=${page}&per_page=${this.pageSize}`
      );
      const data = await response.json();

      allItems.push(...data.items);
      hasMore = data.items.length === this.pageSize;

      if (this.onProgress) {
        const progress = estimatedTotal 
          ? Math.min((allItems.length / estimatedTotal) * 100, 100)
          : null;
        
        this.onProgress({
          loaded: allItems.length,
          total: estimatedTotal,
          progress,
          page
        });
      }

      page++;
    }

    return allItems;
  }
}

// Usage
const paginator = new ProgressivePaginator(
  'https://api.example.com/items',
  50,
  ({ loaded, total, progress }) => {
    console.log(`Loaded ${loaded}/${total} (${progress.toFixed(1)}%)`);
  }
);

const items = await paginator.fetchAll(1000);
```

### Filter and Sort Integration

#### Combined Pagination and Filtering

```javascript
class FilteredPaginator {
  constructor(apiUrl, pageSize) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
    this.filters = {};
    this.sortBy = null;
    this.sortOrder = 'asc';
  }

  setFilters(filters) {
    this.filters = { ...filters };
    return this;
  }

  setSort(field, order = 'asc') {
    this.sortBy = field;
    this.sortOrder = order;
    return this;
  }

  async fetchPage(page) {
    const url = new URL(this.apiUrl);
    url.searchParams.set('page', page);
    url.searchParams.set('per_page', this.pageSize);

    // Add filters
    Object.entries(this.filters).forEach(([key, value]) => {
      if (value !== null && value !== undefined && value !== '') {
        url.searchParams.set(key, value);
      }
    });

    // Add sorting
    if (this.sortBy) {
      url.searchParams.set('sort', this.sortBy);
      url.searchParams.set('order', this.sortOrder);
    }

    const response = await fetch(url);
    return response.json();
  }

  clearFilters() {
    this.filters = {};
    return this;
  }
}

// Usage
const paginator = new FilteredPaginator('https://api.example.com/items', 20);
const data = await paginator
  .setFilters({ status: 'active', category: 'electronics' })
  .setSort('price', 'desc')
  .fetchPage(1);
```

#### Dynamic Query Building

```javascript
class QueryBuilder {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
    this.params = new URLSearchParams();
  }

  page(number) {
    this.params.set('page', number);
    return this;
  }

  limit(size) {
    this.params.set('limit', size);
    return this;
  }

  filter(field, operator, value) {
    // Support different filter formats
    if (operator === 'eq') {
      this.params.set(field, value);
    } else if (operator === 'gt') {
      this.params.set(`${field}_gt`, value);
    } else if (operator === 'lt') {
      this.params.set(`${field}_lt`, value);
    } else if (operator === 'contains') {
      this.params.set(`${field}_like`, value);
    }
    return this;
  }

  sort(field, direction = 'asc') {
    const sortValue = direction === 'desc' ? `-${field}` : field;
    this.params.set('sort', sortValue);
    return this;
  }

  search(query) {
    this.params.set('q', query);
    return this;
  }

  build() {
    return `${this.baseUrl}?${this.params.toString()}`;
  }

  async fetch() {
    const url = this.build();
    const response = await fetch(url);
    return response.json();
  }
}

// Usage
const query = new QueryBuilder('https://api.example.com/items')
  .page(1)
  .limit(20)
  .filter('price', 'gt', 100)
  .filter('status', 'eq', 'available')
  .sort('created_at', 'desc')
  .search('laptop');

const data = await query.fetch();
```

### Testing Pagination

#### Mock Paginated Responses

```javascript
function createMockPaginatedApi(totalItems, pageSize) {
  const items = Array.from({ length: totalItems }, (_, i) => ({
    id: i + 1,
    name: `Item ${i + 1}`,
    value: Math.random() * 100
  }));

  return async function mockFetch(page) {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 100));

    const start = (page - 1) * pageSize;
    const end = start + pageSize;
    const pageItems = items.slice(start, end);

    return {
      items: pageItems,
      page,
      per_page: pageSize,
      total: totalItems,
      total_pages: Math.ceil(totalItems / pageSize),
      has_next: end < totalItems,
      has_prev: page > 1
    };
  };
}

// Testing
const mockApi = createMockPaginatedApi(100, 10);
const page1 = await mockApi(1);
const page2 = await mockApi(2);
```

#### Testing Pagination Logic

```javascript
// Test helper for assertions
function createPaginationTester() {
  return {
    async testPageNavigation(paginator, expectedPages) {
      const results = [];
      
      for (let i = 1; i <= expectedPages; i++) {
        const data = await paginator.fetchPage(i);
        results.push(data);
        
        // Verify page numbers
        if (data.page !== i) {
          throw new Error(`Expected page ${i}, got ${data.page}`);
        }
      }
      
      return results;
    },

    async testCursorConsistency(paginator) {
      const firstPass = [];
      const secondPass = [];
      
      // First pass
      let cursor = null;
      for (let i = 0; i < 3; i++) {
        const data = await paginator.fetchPage(cursor);
        firstPass.push(...data.items);
        cursor = data.next_cursor;
        if (!cursor) break;
      }
      
      // Second pass with same cursors
      cursor = null;
      for (let i = 0; i < 3; i++) {
        const data = await paginator.fetchPage(cursor);
        secondPass.push(...data.items);
        cursor = data.next_cursor;
        if (!cursor) break;
      }
      
      // Verify consistency
      if (JSON.stringify(firstPass) !== JSON.stringify(secondPass)) {
        throw new Error('Cursor pagination returned inconsistent results');
      }
      
      return true;
    },

    async testNoDuplicates(paginator, totalPages) {
      const allIds = new Set();
      const duplicates = [];
      
      for (let page = 1; page <= totalPages; page++) {
        const data = await paginator.fetchPage(page);
        
        data.items.forEach(item => {
          if (allIds.has(item.id)) {
            duplicates.push(item.id);
          }
          allIds.add(item.id);
        });
      }
      
      if (duplicates.length > 0) {
        throw new Error(`Found duplicate IDs: ${duplicates.join(', ')}`);
      }
      
      return true;
    },

    async testNoMissingItems(paginator, expectedTotal) {
      const allItems = [];
      let page = 1;
      let hasMore = true;
      
      while (hasMore) {
        const data = await paginator.fetchPage(page);
        allItems.push(...data.items);
        hasMore = data.items.length > 0;
        page++;
        
        if (page > 1000) { // Safety limit
          throw new Error('Too many pages, possible infinite loop');
        }
      }
      
      if (allItems.length !== expectedTotal) {
        throw new Error(
          `Expected ${expectedTotal} items, got ${allItems.length}`
        );
      }
      
      return true;
    }
  };
}
```

#### Mock with Network Failures

```javascript
function createUnreliableMockApi(totalItems, pageSize, failureRate = 0.2) {
  const items = Array.from({ length: totalItems }, (_, i) => ({
    id: i + 1,
    name: `Item ${i + 1}`
  }));
  
  let requestCount = 0;

  return async function mockFetch(page) {
    requestCount++;
    
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 50 + Math.random() * 150));

    // Randomly fail based on failure rate
    if (Math.random() < failureRate) {
      throw new Error('Network error');
    }

    const start = (page - 1) * pageSize;
    const end = start + pageSize;
    const pageItems = items.slice(start, end);

    return {
      items: pageItems,
      page,
      per_page: pageSize,
      total: totalItems,
      total_pages: Math.ceil(totalItems / pageSize),
      request_number: requestCount
    };
  };
}

// Test retry logic
async function testRetryLogic() {
  const mockApi = createUnreliableMockApi(100, 10, 0.3);
  let successCount = 0;
  let retryCount = 0;

  async function fetchWithRetry(page, maxRetries = 3) {
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const data = await mockApi(page);
        successCount++;
        return data;
      } catch (error) {
        retryCount++;
        if (attempt === maxRetries) throw error;
        await new Promise(r => setTimeout(r, 100 * Math.pow(2, attempt)));
      }
    }
  }

  await fetchWithRetry(1);
  console.log(`Success: ${successCount}, Retries: ${retryCount}`);
}
```

#### Integration Test Example

```javascript
async function testPaginationIntegration() {
  const results = {
    passed: [],
    failed: []
  };

  const tests = [
    {
      name: 'Fetch all pages sequentially',
      fn: async () => {
        const mockApi = createMockPaginatedApi(50, 10);
        const allItems = [];
        
        for (let page = 1; page <= 5; page++) {
          const data = await mockApi(page);
          allItems.push(...data.items);
        }
        
        if (allItems.length !== 50) {
          throw new Error(`Expected 50 items, got ${allItems.length}`);
        }
      }
    },
    {
      name: 'Handle empty results',
      fn: async () => {
        const mockApi = createMockPaginatedApi(15, 10);
        const page2 = await mockApi(2);
        
        if (page2.items.length !== 5) {
          throw new Error('Second page should have 5 items');
        }
        
        if (page2.has_next) {
          throw new Error('Should not have next page');
        }
      }
    },
    {
      name: 'Concurrent page fetching',
      fn: async () => {
        const mockApi = createMockPaginatedApi(100, 10);
        
        const promises = [
          mockApi(1),
          mockApi(2),
          mockApi(3)
        ];
        
        const results = await Promise.all(promises);
        const totalItems = results.reduce((sum, r) => sum + r.items.length, 0);
        
        if (totalItems !== 30) {
          throw new Error(`Expected 30 items, got ${totalItems}`);
        }
      }
    },
    {
      name: 'Cache effectiveness',
      fn: async () => {
        const cache = new PaginationCache(10);
        let fetchCount = 0;
        
        async function cachedFetch(page) {
          const key = `page-${page}`;
          const cached = cache.get(key);
          
          if (cached) return cached;
          
          fetchCount++;
          const mockApi = createMockPaginatedApi(100, 10);
          const data = await mockApi(page);
          cache.set(key, data);
          return data;
        }
        
        await cachedFetch(1);
        await cachedFetch(1); // Should use cache
        await cachedFetch(2);
        await cachedFetch(1); // Should use cache
        
        if (fetchCount !== 2) {
          throw new Error(`Expected 2 fetches, got ${fetchCount}`);
        }
      }
    }
  ];

  for (const test of tests) {
    try {
      await test.fn();
      results.passed.push(test.name);
    } catch (error) {
      results.failed.push({ name: test.name, error: error.message });
    }
  }

  return results;
}
```

### Real-World Examples

#### GitHub API Pagination

```javascript
class GitHubPaginator {
  constructor(token) {
    this.token = token;
    this.baseUrl = 'https://api.github.com';
  }

  async fetchRepositories(username, perPage = 30) {
    const repos = [];
    let page = 1;
    let hasMore = true;

    while (hasMore) {
      const url = `${this.baseUrl}/users/${username}/repos?per_page=${perPage}&page=${page}`;
      
      const response = await fetch(url, {
        headers: {
          'Authorization': `token ${this.token}`,
          'Accept': 'application/vnd.github.v3+json'
        }
      });

      const data = await response.json();
      repos.push(...data);

      // GitHub uses Link header for pagination
      const linkHeader = response.headers.get('Link');
      hasMore = linkHeader && linkHeader.includes('rel="next"');
      page++;
    }

    return repos;
  }

  async fetchIssues(owner, repo, state = 'open') {
    const issues = [];
    const url = new URL(`${this.baseUrl}/repos/${owner}/${repo}/issues`);
    url.searchParams.set('state', state);
    url.searchParams.set('per_page', 100);

    let nextUrl = url.toString();

    while (nextUrl) {
      const response = await fetch(nextUrl, {
        headers: {
          'Authorization': `token ${this.token}`,
          'Accept': 'application/vnd.github.v3+json'
        }
      });

      const data = await response.json();
      issues.push(...data);

      // Extract next URL from Link header
      const linkHeader = response.headers.get('Link');
      nextUrl = this.parseNextUrl(linkHeader);
    }

    return issues;
  }

  parseNextUrl(linkHeader) {
    if (!linkHeader) return null;
    
    const links = linkHeader.split(',');
    const nextLink = links.find(link => link.includes('rel="next"'));
    
    if (!nextLink) return null;
    
    const match = nextLink.match(/<([^>]+)>/);
    return match ? match[1] : null;
  }
}
```

#### REST API with Cursor Pagination

```javascript
class TwitterStylePaginator {
  constructor(apiUrl, bearerToken) {
    this.apiUrl = apiUrl;
    this.bearerToken = bearerToken;
  }

  async fetchTweets(userId, maxResults = 100) {
    const allTweets = [];
    let nextToken = null;

    do {
      const url = new URL(`${this.apiUrl}/users/${userId}/tweets`);
      url.searchParams.set('max_results', Math.min(maxResults, 100));
      
      if (nextToken) {
        url.searchParams.set('pagination_token', nextToken);
      }

      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${this.bearerToken}`
        }
      });

      const data = await response.json();
      
      if (data.data) {
        allTweets.push(...data.data);
      }

      nextToken = data.meta?.next_token;
      
      // Stop if we've reached desired amount
      if (allTweets.length >= maxResults) {
        break;
      }
    } while (nextToken);

    return allTweets.slice(0, maxResults);
  }

  async *streamTweets(userId) {
    let nextToken = null;

    do {
      const url = new URL(`${this.apiUrl}/users/${userId}/tweets`);
      url.searchParams.set('max_results', 100);
      
      if (nextToken) {
        url.searchParams.set('pagination_token', nextToken);
      }

      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${this.bearerToken}`
        }
      });

      const data = await response.json();
      
      if (data.data) {
        yield data.data;
      }

      nextToken = data.meta?.next_token;
    } while (nextToken);
  }
}
```

#### GraphQL Pagination

```javascript
class GraphQLPaginator {
  constructor(endpoint, token) {
    this.endpoint = endpoint;
    this.token = token;
  }

  async fetchWithPagination(query, variables = {}, pageSize = 50) {
    const allResults = [];
    let hasNextPage = true;
    let endCursor = null;

    while (hasNextPage) {
      const response = await fetch(this.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.token}`
        },
        body: JSON.stringify({
          query,
          variables: {
            ...variables,
            first: pageSize,
            after: endCursor
          }
        })
      });

      const result = await response.json();
      
      if (result.errors) {
        throw new Error(result.errors[0].message);
      }

      const { edges, pageInfo } = result.data.repository.issues;
      
      allResults.push(...edges.map(edge => edge.node));
      
      hasNextPage = pageInfo.hasNextPage;
      endCursor = pageInfo.endCursor;
    }

    return allResults;
  }

  // Example query structure
  static ISSUES_QUERY = `
    query GetIssues($owner: String!, $name: String!, $first: Int!, $after: String) {
      repository(owner: $owner, name: $name) {
        issues(first: $first, after: $after) {
          edges {
            node {
              id
              title
              state
              createdAt
            }
            cursor
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  `;
}

// Usage
const paginator = new GraphQLPaginator('https://api.github.com/graphql', 'token');
const issues = await paginator.fetchWithPagination(
  GraphQLPaginator.ISSUES_QUERY,
  { owner: 'facebook', name: 'react' },
  100
);
```

#### Elasticsearch-Style Pagination

```javascript
class SearchPaginator {
  constructor(apiUrl) {
    this.apiUrl = apiUrl;
  }

  // Search After pagination (recommended for deep pagination)
  async searchAfter(query, searchAfter = null, size = 10) {
    const body = {
      query: {
        match: { content: query }
      },
      size,
      sort: [
        { timestamp: 'desc' },
        { _id: 'desc' }
      ]
    };

    if (searchAfter) {
      body.search_after = searchAfter;
    }

    const response = await fetch(`${this.apiUrl}/_search`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });

    const data = await response.json();
    const hits = data.hits.hits;
    
    return {
      results: hits.map(hit => hit._source),
      nextSearchAfter: hits.length > 0 
        ? hits[hits.length - 1].sort 
        : null,
      total: data.hits.total.value
    };
  }

  async fetchAllResults(query, size = 100) {
    const allResults = [];
    let searchAfter = null;

    while (true) {
      const page = await this.searchAfter(query, searchAfter, size);
      allResults.push(...page.results);
      
      if (!page.nextSearchAfter || page.results.length < size) {
        break;
      }
      
      searchAfter = page.nextSearchAfter;
    }

    return allResults;
  }

  // From/Size pagination (for shallow pagination only)
  async fromSize(query, from = 0, size = 10) {
    const response = await fetch(`${this.apiUrl}/_search`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query: {
          match: { content: query }
        },
        from,
        size
      })
    });

    const data = await response.json();
    
    return {
      results: data.hits.hits.map(hit => hit._source),
      total: data.hits.total.value
    };
  }

  // Scroll API (for exporting large datasets)
  async initializeScroll(query, size = 1000, scrollTime = '2m') {
    const response = await fetch(
      `${this.apiUrl}/_search?scroll=${scrollTime}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          query: {
            match: { content: query }
          },
          size
        })
      }
    );

    const data = await response.json();
    
    return {
      scrollId: data._scroll_id,
      results: data.hits.hits.map(hit => hit._source),
      total: data.hits.total.value
    };
  }

  async continueScroll(scrollId, scrollTime = '2m') {
    const response = await fetch(`${this.apiUrl}/_search/scroll`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        scroll: scrollTime,
        scroll_id: scrollId
      })
    });

    const data = await response.json();
    
    return {
      scrollId: data._scroll_id,
      results: data.hits.hits.map(hit => hit._source)
    };
  }

  async clearScroll(scrollId) {
    await fetch(`${this.apiUrl}/_search/scroll`, {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        scroll_id: scrollId
      })
    });
  }

  async exportAllData(query) {
    const allResults = [];
    const initial = await this.initializeScroll(query);
    
    allResults.push(...initial.results);
    let scrollId = initial.scrollId;

    try {
      while (true) {
        const page = await this.continueScroll(scrollId);
        
        if (page.results.length === 0) break;
        
        allResults.push(...page.results);
        scrollId = page.scrollId;
      }
    } finally {
      await this.clearScroll(scrollId);
    }

    return allResults;
  }
}
```

### Edge Cases and Gotchas

#### Handling Time-Based Pagination

```javascript
class TimeBasedPaginator {
  constructor(apiUrl, pageSize) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
  }

  async fetchByTimeRange(startTime, endTime) {
    const allItems = [];
    let currentEndTime = endTime;

    while (true) {
      const url = new URL(this.apiUrl);
      url.searchParams.set('start_time', startTime);
      url.searchParams.set('end_time', currentEndTime);
      url.searchParams.set('limit', this.pageSize);
      url.searchParams.set('sort', 'desc'); // Newest first

      const response = await fetch(url);
      const data = await response.json();

      if (data.items.length === 0) break;

      allItems.push(...data.items);

      // Use oldest item's timestamp for next page
      const oldestItem = data.items[data.items.length - 1];
      currentEndTime = oldestItem.timestamp;

      // Avoid infinite loop if timestamp doesn't change
      if (data.items.length < this.pageSize) break;

      // Small delay to avoid overwhelming server
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    return allItems;
  }

  // Handle items with identical timestamps
  async fetchByTimeWithTieBreaker(startTime, endTime) {
    const allItems = [];
    const seenIds = new Set();
    let currentEndTime = endTime;
    let lastId = null;

    while (true) {
      const url = new URL(this.apiUrl);
      url.searchParams.set('start_time', startTime);
      url.searchParams.set('end_time', currentEndTime);
      url.searchParams.set('limit', this.pageSize);
      
      if (lastId) {
        url.searchParams.set('last_id', lastId);
      }

      const response = await fetch(url);
      const data = await response.json();

      if (data.items.length === 0) break;

      // Filter out duplicates
      const newItems = data.items.filter(item => !seenIds.has(item.id));
      newItems.forEach(item => seenIds.add(item.id));
      allItems.push(...newItems);

      const oldestItem = data.items[data.items.length - 1];
      currentEndTime = oldestItem.timestamp;
      lastId = oldestItem.id;

      if (data.items.length < this.pageSize) break;
    }

    return allItems;
  }
}
```

#### Handling Concurrent Modifications

```javascript
class VersionedPaginator {
  constructor(apiUrl, pageSize) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
  }

  async fetchConsistentSnapshot() {
    // Get a snapshot version first
    const snapshotResponse = await fetch(`${this.apiUrl}/snapshot`);
    const { snapshot_id, total } = await snapshotResponse.json();

    const allItems = [];
    let page = 1;
    const totalPages = Math.ceil(total / this.pageSize);

    while (page <= totalPages) {
      const url = new URL(`${this.apiUrl}/items`);
      url.searchParams.set('snapshot_id', snapshot_id);
      url.searchParams.set('page', page);
      url.searchParams.set('per_page', this.pageSize);

      const response = await fetch(url);
      const data = await response.json();

      allItems.push(...data.items);
      page++;
    }

    return allItems;
  }

  // Use ETags for optimistic locking
  async fetchWithETag(page) {
    const url = `${this.apiUrl}?page=${page}&per_page=${this.pageSize}`;
    
    const response = await fetch(url);
    const etag = response.headers.get('ETag');
    const data = await response.json();

    return {
      data,
      etag,
      async refetch() {
        const refetchResponse = await fetch(url, {
          headers: { 'If-None-Match': etag }
        });

        if (refetchResponse.status === 304) {
          return { data, unchanged: true };
        }

        const newData = await refetchResponse.json();
        return { data: newData, unchanged: false };
      }
    };
  }
}
```

#### Handling Missing Pages

```javascript
async function fetchWithGapDetection(apiUrl, expectedPages, pageSize) {
  const results = new Map();
  const missing = [];

  // Fetch all pages
  const promises = Array.from({ length: expectedPages }, (_, i) => {
    const page = i + 1;
    return fetch(`${apiUrl}?page=${page}&per_page=${pageSize}`)
      .then(res => res.json())
      .then(data => results.set(page, data))
      .catch(() => missing.push(page));
  });

  await Promise.allSettled(promises);

  // Retry missing pages
  for (const page of missing) {
    try {
      const response = await fetch(
        `${apiUrl}?page=${page}&per_page=${pageSize}`
      );
      const data = await response.json();
      results.set(page, data);
    } catch (error) {
      console.error(`Failed to fetch page ${page}:`, error);
    }
  }

  // Convert to array and check for gaps
  const sortedResults = Array.from(results.entries())
    .sort(([a], [b]) => a - b)
    .map(([_, data]) => data.items)
    .flat();

  return sortedResults;
}
```

#### Handling Large Offset Performance Issues

```javascript
class HybridPaginator {
  constructor(apiUrl, pageSize) {
    this.apiUrl = apiUrl;
    this.pageSize = pageSize;
  }

  // Use offset for first few pages, switch to cursor for deep pagination
  async fetchPage(page) {
    const threshold = 10; // Switch to cursor after 10 pages

    if (page <= threshold) {
      return this.fetchWithOffset(page);
    } else {
      // Calculate cursor based on threshold
      const skipPages = threshold;
      const cursor = await this.getCursorAtPage(skipPages);
      const remainingPages = page - skipPages;
      return this.fetchWithCursor(cursor, remainingPages);
    }
  }

  async fetchWithOffset(page) {
    const offset = (page - 1) * this.pageSize;
    const url = `${this.apiUrl}?limit=${this.pageSize}&offset=${offset}`;
    
    const response = await fetch(url);
    return response.json();
  }

  async getCursorAtPage(page) {
    const offset = (page - 1) * this.pageSize;
    const url = `${this.apiUrl}?limit=1&offset=${offset}`;
    
    const response = await fetch(url);
    const data = await response.json();
    return data.items[0]?.id;
  }

  async fetchWithCursor(cursor, pagesToSkip) {
    let currentCursor = cursor;
    
    // Skip pages using cursor
    for (let i = 0; i < pagesToSkip; i++) {
      const response = await fetch(
        `${this.apiUrl}?limit=${this.pageSize}&cursor=${currentCursor}`
      );
      const data = await response.json();
      currentCursor = data.next_cursor;
    }

    // Fetch target page
    const response = await fetch(
      `${this.apiUrl}?limit=${this.pageSize}&cursor=${currentCursor}`
    );
    return response.json();
  }
}
```

---

