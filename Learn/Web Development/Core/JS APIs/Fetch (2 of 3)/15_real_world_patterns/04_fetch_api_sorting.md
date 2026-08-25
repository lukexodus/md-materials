## Fetch API Sorting


### Basic Sort Parameter

The fetch API accepts a `sort` parameter in the request options to order results. The sort parameter takes a string value specifying the field name to sort by:

```javascript
const response = await fetch('/api/items?sort=name');
```

### Sort Direction

Sort direction is controlled by prefixing the field name with a plus sign (`+`) for ascending order or a minus sign (`-`) for descending order:

```javascript
// Ascending order (explicit)
const response = await fetch('/api/items?sort=+price');

// Descending order
const response = await fetch('/api/items?sort=-price');

// Ascending order (implicit default)
const response = await fetch('/api/items?sort=price');
```

Most APIs default to ascending order when no prefix is specified.

### Multiple Sort Fields

Multiple sort criteria can be applied by separating field names with commas. The API processes sorts from left to right, with earlier fields taking precedence:

```javascript
// Sort by category ascending, then by price descending
const response = await fetch('/api/items?sort=category,-price');

// Sort by priority descending, status ascending, then date descending
const response = await fetch('/api/items?sort=-priority,+status,-createdAt');
```

### Nested Field Sorting

Nested object properties can be sorted using dot notation:

```javascript
// Sort by nested field
const response = await fetch('/api/users?sort=address.city');

// Sort by deeply nested field
const response = await fetch('/api/orders?sort=customer.billing.zipCode');
```

### URL Encoding

Sort parameters containing special characters, spaces, or non-ASCII characters must be URL-encoded:

```javascript
const sortParam = encodeURIComponent('user.name,-created_at');
const response = await fetch(`/api/items?sort=${sortParam}`);
```

For complex sort strings:

```javascript
const params = new URLSearchParams({
  sort: '-priority,status,customer.name'
});
const response = await fetch(`/api/items?${params}`);
```

### Array-Based Sort Syntax

Some APIs accept array syntax for multiple sort fields:

```javascript
// Using repeated parameters
const response = await fetch('/api/items?sort[]=-price&sort[]=name');

// Using bracket notation with indices
const response = await fetch('/api/items?sort[0]=-price&sort[1]=name');
```

### Case Sensitivity

Sort behavior for string fields varies by implementation:

```javascript
// Case-sensitive sort (default in many systems)
const response = await fetch('/api/items?sort=name');

// Case-insensitive sort (API-dependent)
const response = await fetch('/api/items?sort=name&case=insensitive');
```

[Inference] String comparison typically follows lexicographic ordering where uppercase letters sort before lowercase letters in case-sensitive modes.

### Null Handling

Different APIs handle null or undefined values differently during sorting:

```javascript
// Nulls first
const response = await fetch('/api/items?sort=optionalField&nulls=first');

// Nulls last (common default)
const response = await fetch('/api/items?sort=optionalField&nulls=last');
```

### Combining Sort with Other Parameters

Sort parameters work alongside filtering, pagination, and field selection:

```javascript
const params = new URLSearchParams({
  sort: '-createdAt,name',
  limit: '20',
  offset: '40',
  filter: 'status:active',
  fields: 'id,name,price'
});

const response = await fetch(`/api/items?${params}`);
```

### Sort Order Validation

Client-side validation helps catch errors before making requests:

```javascript
function validateSortParam(sort, allowedFields) {
  const sortFields = sort.split(',').map(s => s.replace(/^[+-]/, ''));
  const invalid = sortFields.filter(f => !allowedFields.includes(f));
  
  if (invalid.length > 0) {
    throw new Error(`Invalid sort fields: ${invalid.join(', ')}`);
  }
}

const allowedFields = ['name', 'price', 'createdAt', 'category'];
const sortParam = '-price,name';
validateSortParam(sortParam, allowedFields);

const response = await fetch(`/api/items?sort=${sortParam}`);
```

### Dynamic Sort Construction

Building sort parameters dynamically based on user input:

```javascript
function buildSortParam(sortConfig) {
  return sortConfig
    .map(({ field, direction }) => {
      const prefix = direction === 'desc' ? '-' : '';
      return `${prefix}${field}`;
    })
    .join(',');
}

const sortConfig = [
  { field: 'priority', direction: 'desc' },
  { field: 'name', direction: 'asc' },
  { field: 'createdAt', direction: 'desc' }
];

const sortParam = buildSortParam(sortConfig);
const response = await fetch(`/api/items?sort=${sortParam}`);
```

### Error Handling

Handling invalid sort parameters:

```javascript
try {
  const response = await fetch('/api/items?sort=-invalidField');
  
  if (!response.ok) {
    const error = await response.json();
    if (response.status === 400 && error.code === 'INVALID_SORT_FIELD') {
      console.error('Invalid sort field:', error.message);
    }
  }
  
  const data = await response.json();
} catch (error) {
  console.error('Request failed:', error);
}
```

### Custom Sort Functions

Some APIs support custom sort expressions or functions:

```javascript
// Custom sort expression (API-dependent syntax)
const response = await fetch('/api/items?sort=custom(price*quantity)');

// Function-based sorting (rare, API-specific)
const response = await fetch('/api/items?sort=fn:calculateScore');
```

[Unverified] Custom sort function support varies significantly between APIs and is not part of standard fetch conventions.

### Performance Considerations

Sorting impacts query performance, especially on large datasets:

```javascript
// Indexed field - faster
const response = await fetch('/api/items?sort=id');

// Non-indexed field - slower
const response = await fetch('/api/items?sort=description');

// Multiple fields - performance depends on indexes
const response = await fetch('/api/items?sort=category,-price,name');
```

[Inference] Database indexes on sort fields significantly improve query performance, but the specific performance characteristics depend on the backend implementation.

### Client-Side vs Server-Side Sorting

Deciding where to sort:

```javascript
// Server-side sort (recommended for large datasets)
const response = await fetch('/api/items?sort=-price&limit=100');
const data = await response.json();

// Client-side sort (suitable for small datasets)
const response = await fetch('/api/items');
const data = await response.json();
const sorted = data.sort((a, b) => b.price - a.price);
```

### RESTful Sort Conventions

Common patterns in REST APIs:

```javascript
// Query parameter style (most common)
fetch('/api/items?sort=name');

// Header-based sorting (rare)
fetch('/api/items', {
  headers: { 'X-Sort': '-createdAt,name' }
});

// Path-based sorting (uncommon)
fetch('/api/items/sorted-by/name');
```

### GraphQL Comparison

For reference, sorting in GraphQL differs from REST:

```javascript
// REST approach
fetch('/api/items?sort=-price,name');

// GraphQL approach
fetch('/graphql', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    query: `
      query {
        items(orderBy: [{ price: DESC }, { name: ASC }]) {
          id
          name
          price
        }
      }
    `
  })
});
```

### Locale-Aware Sorting

String sorting with locale considerations:

```javascript
// Request locale-specific sorting
const response = await fetch('/api/items?sort=name&locale=en-US');

// With collation options
const response = await fetch('/api/items?sort=name&locale=fr-FR&collation=accent');
```

[Unverified] Locale-aware sorting support depends entirely on the API implementation and is not a standard feature of the fetch API itself.

### Sort State Management

Maintaining sort state in applications:

```javascript
class DataFetcher {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
    this.currentSort = null;
  }
  
  async fetchSorted(sortParam) {
    this.currentSort = sortParam;
    const response = await fetch(`${this.baseUrl}?sort=${sortParam}`);
    return response.json();
  }
  
  async refetch() {
    if (this.currentSort) {
      return this.fetchSorted(this.currentSort);
    }
    const response = await fetch(this.baseUrl);
    return response.json();
  }
}

const fetcher = new DataFetcher('/api/items');
const data = await fetcher.fetchSorted('-price,name');
```

### Debugging Sort Issues

Techniques for troubleshooting sort problems:

```javascript
async function fetchWithSortDebug(url, sortParam) {
  const fullUrl = `${url}?sort=${sortParam}`;
  console.log('Sort request:', fullUrl);
  
  const response = await fetch(fullUrl);
  
  console.log('Sort response status:', response.status);
  console.log('Sort response headers:', Object.fromEntries(response.headers));
  
  const data = await response.json();
  console.log('First item:', data[0]);
  console.log('Last item:', data[data.length - 1]);
  
  return data;
}

const data = await fetchWithSortDebug('/api/items', '-price,name');
```

---

