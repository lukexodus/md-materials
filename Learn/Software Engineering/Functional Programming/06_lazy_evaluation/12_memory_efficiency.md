## Memory Efficiency


Lazy evaluation provides significant memory benefits by generating values on-demand rather than storing entire collections, enabling processing of datasets larger than available RAM.

### Constant Memory Usage

```javascript
// Eager: O(n) memory - stores entire array
function eagerSum(n) {
  const numbers = Array.from({ length: n }, (_, i) => i + 1);
  return numbers.reduce((sum, x) => sum + x, 0);
}

console.log(eagerSum(1000000)); // Creates 1M element array

// Lazy: O(1) memory - generates one value at a time
function* lazyRange(n) {
  for (let i = 1; i <= n; i++) {
    yield i;
  }
}

function lazySum(n) {
  let sum = 0;
  for (const num of lazyRange(n)) {
    sum += num;
  }
  return sum;
}

console.log(lazySum(1000000)); // Uses constant memory
```

### No Intermediate Arrays

```javascript
// Eager: Creates 3 intermediate arrays
const eagerResult = [1, 2, 3, 4, 5]
  .map(x => x * 2)      // [2, 4, 6, 8, 10] - stored in memory
  .filter(x => x > 5)   // [6, 8, 10] - stored in memory
  .map(x => x + 1);     // [7, 9, 11] - stored in memory

// Lazy: No intermediate storage
function* lazyPipeline(arr) {
  for (const x of arr) {
    const doubled = x * 2;
    if (doubled > 5) {
      yield doubled + 1;
    }
  }
}

const lazyResult = [...lazyPipeline([1, 2, 3, 4, 5])];
// Processes one element through entire pipeline before next
```

### Processing Large Files

```javascript
// Memory-efficient file processing
async function* readLines(filepath) {
  const fs = require('fs');
  const readline = require('readline');
  
  const stream = fs.createReadStream(filepath);
  const reader = readline.createInterface({ input: stream });
  
  for await (const line of reader) {
    yield line;
  }
}

async function* parseJSON(lines) {
  for await (const line of lines) {
    try {
      yield JSON.parse(line);
    } catch (e) {
      console.log('Invalid JSON:', line);
    }
  }
}

async function* filterRecords(records, predicate) {
  for await (const record of records) {
    if (predicate(record)) {
      yield record;
    }
  }
}

// Process 10GB file with ~10MB memory usage
async function analyzeLogFile(filepath) {
  const lines = readLines(filepath);
  const records = parseJSON(lines);
  const errors = filterRecords(records, r => r.level === 'ERROR');

  let count = 0; 
  for await (const error of errors) {
    count++;
    if (count <= 10) {
      console.log(error); // Show first 10 errors }
    }

  return count;
}
````

### Stream Processing

```javascript
// Process paginated API without storing all pages
async function* fetchAllPages(baseUrl) {
  let page = 1;
  let hasMore = true;
  
  while (hasMore) {
    const response = await fetch(`${baseUrl}?page=${page}`);
    const data = await response.json();
    
    for (const item of data.items) {
      yield item;
    }
    
    hasMore = data.hasMore;
    page++;
  }
}

async function processUsers() {
  const users = fetchAllPages('/api/users');
  let activeCount = 0;
  
  for await (const user of users) {
    if (user.active) {
      activeCount++;
    }
    // Each user processed and discarded immediately
  }
  
  return activeCount;
}
````

### Chunked Processing

```javascript
function* chunks(iterable, size) {
  let chunk = [];
  
  for (const item of iterable) {
    chunk.push(item);
    
    if (chunk.length === size) {
      yield chunk;
      chunk = [];
    }
  }
  
  if (chunk.length > 0) {
    yield chunk;
  }
}

// Process data in batches without loading everything
async function* batchProcess(data, batchSize) {
  for (const chunk of chunks(data, batchSize)) {
    const results = await Promise.all(
      chunk.map(item => processItem(item))
    );
    yield* results;
  }
}

// Process 1M records in batches of 100
const processed = batchProcess(hugeDataset, 100);
for await (const result of processed) {
  // Handle result, previous batch already garbage collected
}
```

### Window Operations

```javascript
function* slidingWindow(iterable, windowSize) {
  const window = [];
  
  for (const item of iterable) {
    window.push(item);
    
    if (window.length > windowSize) {
      window.shift(); // Remove oldest
    }
    
    if (window.length === windowSize) {
      yield [...window];
    }
  }
}

// Calculate moving average over infinite stream
function* movingAverage(stream, windowSize) {
  for (const window of slidingWindow(stream, windowSize)) {
    const avg = window.reduce((s, x) => s + x, 0) / windowSize;
    yield avg;
  }
}

const dataStream = randomStream(0, 100);
const averages = movingAverage(dataStream, 10);

console.log(takeN(5, averages)); // Only keeps 10 values in memory
```

### Avoiding Duplicate Storage

```javascript
// Eager: Duplicates data at each step
function eagerTransform(data) {
  const step1 = data.map(x => ({ value: x }));        // Duplicates
  const step2 = step1.map(obj => ({ ...obj, doubled: obj.value * 2 })); // Duplicates
  return step2;
}

// Lazy: Transforms on-the-fly
function* lazyTransform(data) {
  for (const x of data) {
    yield { value: x, doubled: x * 2 };
  }
}

const millionItems = Array.from({ length: 1000000 }, (_, i) => i);

// Eager uses ~48MB+ (3 arrays of 1M objects)
const eager = eagerTransform(millionItems);

// Lazy uses ~8 bytes (one object at a time)
const lazy = lazyTransform(millionItems);
```

### Database-Style Processing

```javascript
function* select(iterable, fields) {
  for (const item of iterable) {
    const selected = {};
    for (const field of fields) {
      selected[field] = item[field];
    }
    yield selected;
  }
}

function* where(iterable, predicate) {
  for (const item of iterable) {
    if (predicate(item)) {
      yield item;
    }
  }
}

function* join(left, right, leftKey, rightKey) {
  const rightMap = new Map();
  for (const item of right) {
    rightMap.set(item[rightKey], item);
  }
  
  for (const leftItem of left) {
    const rightItem = rightMap.get(leftItem[leftKey]);
    if (rightItem) {
      yield { ...leftItem, ...rightItem };
    }
  }
}

// Query millions of records with minimal memory
const users = fetchUsers(); // Generator
const activeUsers = where(users, u => u.active);
const userSubset = select(activeUsers, ['id', 'name', 'email']);

for (const user of userSubset) {
  // Process one user at a time
}
```

### Memory Profiling Example

```javascript
// Helper to measure memory
function measureMemory(fn, label) {
  if (global.gc) global.gc(); // Force GC if --expose-gc flag set
  
  const before = process.memoryUsage().heapUsed;
  fn();
  const after = process.memoryUsage().heapUsed;
  
  console.log(`${label}: ${((after - before) / 1024 / 1024).toFixed(2)} MB`);
}

// Eager approach
measureMemory(() => {
  const data = Array.from({ length: 100000 }, (_, i) => ({
    id: i,
    value: i * 2,
    squared: i * i
  }));
  
  const filtered = data.filter(x => x.value > 50000);
  const mapped = filtered.map(x => ({ ...x, cubed: x.value * x.value * x.value }));
  
  // Data stored in memory
}, 'Eager');

// Lazy approach
measureMemory(() => {
  function* generate() {
    for (let i = 0; i < 100000; i++) {
      yield { id: i, value: i * 2, squared: i * i };
    }
  }
  
  function* process(data) {
    for (const x of data) {
      if (x.value > 50000) {
        yield { ...x, cubed: x.value * x.value * x.value };
      }
    }
  }
  
  const result = process(generate());
  
  // Consume without storing all
  let count = 0;
  for (const item of result) {
    count++;
  }
}, 'Lazy');

// Lazy uses ~95% less memory
```

### Pagination without Full Load

```javascript
function* paginate(totalItems, pageSize) {
  for (let offset = 0; offset < totalItems; offset += pageSize) {
    const limit = Math.min(pageSize, totalItems - offset);
    yield { offset, limit };
  }
}

async function* fetchPaginated(query, totalItems, pageSize) {
  for (const { offset, limit } of paginate(totalItems, pageSize)) {
    const response = await fetch(
      `/api/data?query=${query}&offset=${offset}&limit=${limit}`
    );
    const items = await response.json();
    yield* items; // Yield each item individually
  }
}

// Process 1M records without loading them all
const allRecords = fetchPaginated('active:true', 1000000, 100);
let processed = 0;

for await (const record of allRecords) {
  // Process record
  processed++;
  
  if (processed % 10000 === 0) {
    console.log(`Processed ${processed} records`);
  }
}
```

### Comparison of Approaches

```javascript
// Memory usage comparison for 1M items

// Array approach: ~64MB
const arrayData = Array.from({ length: 1000000 }, (_, i) => i);
const arrayProcessed = arrayData
  .map(x => x * 2)
  .filter(x => x % 3 === 0)
  .map(x => x + 1);

// Generator approach: ~100 bytes
function* generatorData() {
  for (let i = 0; i < 1000000; i++) {
    const doubled = i * 2;
    if (doubled % 3 === 0) {
      yield doubled + 1;
    }
  }
}

// [Inference] Generator uses approximately 640x less memory
```

### Streaming JSON Parser

```javascript
async function* streamJSONArray(filepath) {
  const fs = require('fs');
  const stream = fs.createReadStream(filepath);
  
  let buffer = '';
  let depth = 0;
  let inString = false;
  let currentObject = '';
  
  for await (const chunk of stream) {
    buffer += chunk.toString();
    
    for (let i = 0; i < buffer.length; i++) {
      const char = buffer[i];
      
      if (char === '"' && buffer[i - 1] !== '\\') {
        inString = !inString;
      }
      
      if (!inString) {
        if (char === '{') depth++;
        if (char === '}') {
          depth--;
          currentObject += char;
          
          if (depth === 1) {
            yield JSON.parse(currentObject);
            currentObject = '';
            continue;
          }
        }
      }
      
      if (depth > 0) {
        currentObject += char;
      }
    }
    
    buffer = '';
  }
}

// Parse multi-GB JSON array without loading into memory
```

**Key Points:**

- Generators maintain O(1) memory regardless of sequence length
- No intermediate array storage during transformations
- Enables processing datasets larger than available RAM
- One value exists in memory at a time during processing
- Essential for streaming data from files, networks, or databases
- Allows chunked and windowed operations efficiently
- [Inference] Can reduce memory usage by 95%+ compared to eager evaluation

---

