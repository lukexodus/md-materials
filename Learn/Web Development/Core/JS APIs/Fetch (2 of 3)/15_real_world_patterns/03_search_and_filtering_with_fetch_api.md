## Search and Filtering with Fetch API


### Query Parameters

Query parameters encode search and filter criteria in the URL. Multiple approaches exist for building query strings:

```javascript
// Manual string concatenation
const searchTerm = 'javascript';
const category = 'tutorials';
fetch(`/api/posts?search=${searchTerm}&category=${category}`);

// URLSearchParams for complex queries
const params = new URLSearchParams({
  search: 'javascript',
  category: 'tutorials',
  sort: 'date',
  order: 'desc'
});
fetch(`/api/posts?${params.toString()}`);

// Building from existing URL
const url = new URL('https://api.example.com/posts');
url.searchParams.append('search', 'javascript');
url.searchParams.append('tags', 'web');
url.searchParams.append('tags', 'frontend'); // Multiple values
fetch(url);
```

### Encoding Special Characters

URLSearchParams automatically handles encoding, but manual encoding may be needed:

```javascript
const query = 'search term with spaces & special!';
const encoded = encodeURIComponent(query);
fetch(`/api/search?q=${encoded}`);

// URLSearchParams handles this automatically
const params = new URLSearchParams({ q: query });
fetch(`/api/search?${params}`); // Properly encoded
```

### Array and Object Parameters

Different APIs expect different formats for complex parameters:

```javascript
// Array as repeated parameters (most common)
const tags = ['javascript', 'react', 'typescript'];
const params = new URLSearchParams();
tags.forEach(tag => params.append('tags', tag));
// Result: ?tags=javascript&tags=react&tags=typescript

// Array as comma-separated
const tagsParam = tags.join(',');
fetch(`/api/posts?tags=${tagsParam}`);
// Result: ?tags=javascript,react,typescript

// Array with bracket notation
tags.forEach((tag, i) => params.append(`tags[${i}]`, tag));
// Result: ?tags[0]=javascript&tags[1]=react&tags[2]=typescript

// Nested objects (JSON in query string)
const filters = {
  author: { name: 'John', verified: true },
  date: { from: '2024-01-01', to: '2024-12-31' }
};
const params = new URLSearchParams({
  filters: JSON.stringify(filters)
});
```

### Range Filters

Numerical and date ranges are common filtering patterns:

```javascript
// Date ranges
const params = new URLSearchParams({
  startDate: '2024-01-01',
  endDate: '2024-12-31',
  minPrice: '10',
  maxPrice: '100'
});

// Using comparison operators (API-dependent)
const params = new URLSearchParams({
  'price[gte]': '10',  // greater than or equal
  'price[lte]': '100', // less than or equal
  'date[gt]': '2024-01-01'
});

// ISO date strings for timestamps
const startDate = new Date('2024-01-01').toISOString();
const params = new URLSearchParams({ created_after: startDate });
```

### Pagination with Search

Combining pagination with search and filters:

```javascript
async function fetchPagedResults(page = 1, filters = {}) {
  const params = new URLSearchParams({
    page: page,
    limit: 20,
    ...filters
  });
  
  const response = await fetch(`/api/posts?${params}`);
  const data = await response.json();
  
  return {
    results: data.results,
    totalPages: data.totalPages,
    currentPage: data.page,
    hasNext: data.hasNext
  };
}

// Usage
const results = await fetchPagedResults(1, {
  search: 'javascript',
  category: 'tutorials',
  sort: 'date'
});
```

### Debouncing Search Requests

Avoid excessive requests during user input:

```javascript
let searchTimeout;

function debounceSearch(query, delay = 300) {
  clearTimeout(searchTimeout);
  
  return new Promise((resolve) => {
    searchTimeout = setTimeout(async () => {
      const params = new URLSearchParams({ q: query });
      const response = await fetch(`/api/search?${params}`);
      const data = await response.json();
      resolve(data);
    }, delay);
  });
}

// Usage with input event
searchInput.addEventListener('input', async (e) => {
  const results = await debounceSearch(e.target.value);
  displayResults(results);
});
```

### AbortController for Search Cancellation

Cancel in-flight requests when new searches begin:

```javascript
let currentController = null;

async function search(query) {
  // Cancel previous request
  if (currentController) {
    currentController.abort();
  }
  
  currentController = new AbortController();
  
  try {
    const params = new URLSearchParams({ q: query });
    const response = await fetch(`/api/search?${params}`, {
      signal: currentController.signal
    });
    
    const data = await response.json();
    return data;
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Search cancelled');
      return null;
    }
    throw error;
  }
}

// Usage
searchInput.addEventListener('input', async (e) => {
  const results = await search(e.target.value);
  if (results) {
    displayResults(results);
  }
});
```

### Combining Debounce and Abort

Optimize search performance with both techniques:

```javascript
class SearchManager {
  constructor(delay = 300) {
    this.delay = delay;
    this.timeout = null;
    this.controller = null;
  }
  
  async search(query) {
    // Clear existing timeout
    clearTimeout(this.timeout);
    
    // Cancel existing request
    if (this.controller) {
      this.controller.abort();
    }
    
    return new Promise((resolve, reject) => {
      this.timeout = setTimeout(async () => {
        this.controller = new AbortController();
        
        try {
          const params = new URLSearchParams({ q: query });
          const response = await fetch(`/api/search?${params}`, {
            signal: this.controller.signal
          });
          
          const data = await response.json();
          resolve(data);
        } catch (error) {
          if (error.name === 'AbortError') {
            resolve(null);
          } else {
            reject(error);
          }
        }
      }, this.delay);
    });
  }
}

// Usage
const searchManager = new SearchManager();
searchInput.addEventListener('input', async (e) => {
  const results = await searchManager.search(e.target.value);
  if (results) {
    displayResults(results);
  }
});
```

### Filter State Management

Maintain filter state across multiple requests:

```javascript
class FilterManager {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
    this.filters = new Map();
  }
  
  setFilter(key, value) {
    if (value === null || value === undefined || value === '') {
      this.filters.delete(key);
    } else {
      this.filters.set(key, value);
    }
  }
  
  setFilters(filters) {
    Object.entries(filters).forEach(([key, value]) => {
      this.setFilter(key, value);
    });
  }
  
  clearFilter(key) {
    this.filters.delete(key);
  }
  
  clearAll() {
    this.filters.clear();
  }
  
  getUrl() {
    const url = new URL(this.baseUrl);
    this.filters.forEach((value, key) => {
      if (Array.isArray(value)) {
        value.forEach(v => url.searchParams.append(key, v));
      } else {
        url.searchParams.append(key, value);
      }
    });
    return url;
  }
  
  async fetch(options = {}) {
    const response = await fetch(this.getUrl(), options);
    return response.json();
  }
}

// Usage
const filters = new FilterManager('https://api.example.com/posts');
filters.setFilter('category', 'tutorials');
filters.setFilter('tags', ['javascript', 'react']);
filters.setFilter('minPrice', 10);

const results = await filters.fetch();
```

### Server-Side Search Patterns

POST requests for complex search criteria:

```javascript
// GET with query params (simple searches)
async function simpleSearch(query) {
  const params = new URLSearchParams({ q: query });
  const response = await fetch(`/api/search?${params}`);
  return response.json();
}

// POST with request body (complex searches)
async function advancedSearch(criteria) {
  const response = await fetch('/api/search', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      query: criteria.query,
      filters: {
        categories: criteria.categories,
        dateRange: {
          start: criteria.startDate,
          end: criteria.endDate
        },
        price: {
          min: criteria.minPrice,
          max: criteria.maxPrice
        }
      },
      sort: criteria.sortBy,
      page: criteria.page,
      limit: criteria.limit
    })
  });
  
  return response.json();
}
```

### Full-Text Search Parameters

Common patterns for full-text search APIs:

```javascript
// Basic full-text search
const params = new URLSearchParams({
  q: 'javascript tutorials',
  fields: 'title,content,tags' // Fields to search
});

// Fuzzy matching and wildcards
const params = new URLSearchParams({
  q: 'javascrpt~2', // Allow 2 character edits
  wildcard: 'java*' // Wildcard search
});

// Boolean operators (API-dependent)
const params = new URLSearchParams({
  q: 'javascript AND (react OR vue) NOT angular'
});

// Phrase search
const params = new URLSearchParams({
  q: '"modern javascript"' // Exact phrase
});

// Highlighting results
const params = new URLSearchParams({
  q: 'javascript',
  highlight: 'true',
  highlight_fields: 'title,content'
});
```

### Faceted Search

Retrieve aggregated filter options alongside results:

```javascript
async function facetedSearch(query) {
  const params = new URLSearchParams({
    q: query,
    facets: 'category,author,tags,year'
  });
  
  const response = await fetch(`/api/search?${params}`);
  const data = await response.json();
  
  return {
    results: data.results,
    facets: {
      categories: data.facets.category, // [{value: 'tutorials', count: 45}, ...]
      authors: data.facets.author,
      tags: data.facets.tags,
      years: data.facets.year
    },
    total: data.total
  };
}

// Applying facet filters
async function searchWithFacets(query, selectedFacets) {
  const params = new URLSearchParams({ q: query });
  
  Object.entries(selectedFacets).forEach(([facet, values]) => {
    if (Array.isArray(values)) {
      values.forEach(v => params.append(facet, v));
    } else {
      params.append(facet, values);
    }
  });
  
  const response = await fetch(`/api/search?${params}`);
  return response.json();
}
```

### Sorting Results

Apply sorting to filtered results:

```javascript
// Single sort field
const params = new URLSearchParams({
  search: 'javascript',
  sort: 'date',
  order: 'desc'
});

// Multiple sort fields
const params = new URLSearchParams({
  search: 'javascript',
  sort: 'relevance,date',
  order: 'desc,desc'
});

// API-specific sort syntax
const params = new URLSearchParams({
  search: 'javascript',
  sort: '-date,+title' // - for desc, + for asc
});

// Dynamic sorting
function buildSortParams(sortFields) {
  const params = new URLSearchParams();
  sortFields.forEach(({ field, direction }) => {
    params.append('sort', `${field}:${direction}`);
  });
  return params;
}

const sortParams = buildSortParams([
  { field: 'relevance', direction: 'desc' },
  { field: 'date', direction: 'desc' }
]);
```

### Caching Search Results

Reduce redundant requests with client-side caching:

```javascript
class SearchCache {
  constructor(ttl = 5 * 60 * 1000) { // 5 minutes default
    this.cache = new Map();
    this.ttl = ttl;
  }
  
  getCacheKey(url, options) {
    return `${url}-${JSON.stringify(options)}`;
  }
  
  get(url, options) {
    const key = this.getCacheKey(url, options);
    const cached = this.cache.get(key);
    
    if (!cached) return null;
    
    if (Date.now() - cached.timestamp > this.ttl) {
      this.cache.delete(key);
      return null;
    }
    
    return cached.data;
  }
  
  set(url, options, data) {
    const key = this.getCacheKey(url, options);
    this.cache.set(key, {
      data,
      timestamp: Date.now()
    });
  }
  
  clear() {
    this.cache.clear();
  }
  
  async fetch(url, options = {}) {
    const cached = this.get(url, options);
    if (cached) {
      return cached;
    }
    
    const response = await fetch(url, options);
    const data = await response.json();
    
    this.set(url, options, data);
    return data;
  }
}

// Usage
const searchCache = new SearchCache();
const results = await searchCache.fetch('/api/search?q=javascript');
```

### URL State Synchronization

Keep search state in sync with browser URL:

```javascript
class SearchStateManager {
  constructor() {
    this.params = new URLSearchParams(window.location.search);
    
    // Listen to back/forward navigation
    window.addEventListener('popstate', () => {
      this.params = new URLSearchParams(window.location.search);
      this.onStateChange();
    });
  }
  
  updateParam(key, value) {
    if (value === null || value === undefined || value === '') {
      this.params.delete(key);
    } else {
      this.params.set(key, value);
    }
    this.updateUrl();
  }
  
  updateParams(updates) {
    Object.entries(updates).forEach(([key, value]) => {
      this.updateParam(key, value);
    });
  }
  
  getParam(key) {
    return this.params.get(key);
  }
  
  getAllParams() {
    return Object.fromEntries(this.params);
  }
  
  updateUrl() {
    const url = new URL(window.location);
    url.search = this.params.toString();
    window.history.pushState({}, '', url);
    this.onStateChange();
  }
  
  async onStateChange() {
    // Override this method to perform search when state changes
    const results = await this.performSearch();
    this.displayResults(results);
  }
  
  async performSearch() {
    const response = await fetch(`/api/search?${this.params}`);
    return response.json();
  }
  
  displayResults(results) {
    // Override to display results
  }
}

// Usage
const searchState = new SearchStateManager();
searchState.updateParam('q', 'javascript');
searchState.updateParam('category', 'tutorials');
```

### Error Handling for Search

Handle common search-related errors:

```javascript
async function robustSearch(query, filters = {}) {
  const params = new URLSearchParams({
    q: query,
    ...filters
  });
  
  try {
    const response = await fetch(`/api/search?${params}`);
    
    if (!response.ok) {
      if (response.status === 400) {
        const error = await response.json();
        throw new Error(`Invalid search parameters: ${error.message}`);
      }
      if (response.status === 429) {
        throw new Error('Too many requests. Please try again later.');
      }
      throw new Error(`Search failed: ${response.statusText}`);
    }
    
    const data = await response.json();
    
    // Validate response structure
    if (!data.results || !Array.isArray(data.results)) {
      throw new Error('Invalid response format');
    }
    
    return data;
    
  } catch (error) {
    if (error.name === 'AbortError') {
      return { results: [], cancelled: true };
    }
    
    if (error.name === 'TypeError') {
      throw new Error('Network error. Please check your connection.');
    }
    
    throw error;
  }
}

// Usage with error display
try {
  const results = await robustSearch(query, filters);
  if (results.cancelled) {
    return;
  }
  displayResults(results);
} catch (error) {
  displayError(error.message);
}
```

### Progressive Search Results

Load and display results incrementally:

```javascript
async function* streamSearchResults(query, batchSize = 10) {
  let page = 1;
  let hasMore = true;
  
  while (hasMore) {
    const params = new URLSearchParams({
      q: query,
      page: page,
      limit: batchSize
    });
    
    const response = await fetch(`/api/search?${params}`);
    const data = await response.json();
    
    yield data.results;
    
    hasMore = data.hasMore;
    page++;
  }
}

// Usage
async function displayProgressiveResults(query) {
  const container = document.getElementById('results');
  container.innerHTML = '';
  
  for await (const batch of streamSearchResults(query)) {
    batch.forEach(result => {
      const element = createResultElement(result);
      container.appendChild(element);
    });
  }
}
```

### Search Suggestions and Autocomplete

Implement typeahead search suggestions:

```javascript
class SearchAutocomplete {
  constructor(inputElement, options = {}) {
    this.input = inputElement;
    this.delay = options.delay || 200;
    this.minChars = options.minChars || 2;
    this.maxResults = options.maxResults || 10;
    this.controller = null;
    this.timeout = null;
    
    this.input.addEventListener('input', (e) => this.handleInput(e));
  }
  
  handleInput(event) {
    const query = event.target.value.trim();
    
    clearTimeout(this.timeout);
    
    if (query.length < this.minChars) {
      this.clearSuggestions();
      return;
    }
    
    this.timeout = setTimeout(() => {
      this.fetchSuggestions(query);
    }, this.delay);
  }
  
  async fetchSuggestions(query) {
    if (this.controller) {
      this.controller.abort();
    }
    
    this.controller = new AbortController();
    
    try {
      const params = new URLSearchParams({
        q: query,
        limit: this.maxResults
      });
      
      const response = await fetch(`/api/suggestions?${params}`, {
        signal: this.controller.signal
      });
      
      const suggestions = await response.json();
      this.displaySuggestions(suggestions);
      
    } catch (error) {
      if (error.name !== 'AbortError') {
        console.error('Suggestion fetch failed:', error);
      }
    }
  }
  
  displaySuggestions(suggestions) {
    // Implementation to display suggestions
  }
  
  clearSuggestions() {
    // Implementation to clear suggestions
  }
}

// Usage
const autocomplete = new SearchAutocomplete(
  document.getElementById('search-input'),
  { delay: 200, minChars: 2 }
);
```

---

