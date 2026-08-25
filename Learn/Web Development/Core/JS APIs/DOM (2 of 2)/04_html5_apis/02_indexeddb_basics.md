## IndexedDB Basics


### Architecture and Data Model

IndexedDB implements a transactional NoSQL database system within the browser. Data organizes into databases containing object stores, which hold JavaScript objects indexed by keys.

```javascript
// Database contains multiple object stores
// Each object store contains records (key-value pairs)
// Records can have indexes for alternative lookup paths

Database
├── Object Store: "users"
│   ├── Index: "email"
│   ├── Index: "age"
│   └── Records: { id: 1, name: "Alice", email: "alice@example.com" }
├── Object Store: "posts"
└── Object Store: "comments"
```

### Opening and Creating Databases

```javascript
const request = indexedDB.open('MyDatabase', 1);

request.onerror = (event) => {
  console.error('Database error:', event.target.error);
};

request.onsuccess = (event) => {
  const db = event.target.result;
  // Database ready for operations
};

request.onupgradeneeded = (event) => {
  const db = event.target.result;
  
  // Create object stores only during upgrade
  if (!db.objectStoreNames.contains('users')) {
    const objectStore = db.createObjectStore('users', { keyPath: 'id', autoIncrement: true });
    
    // Create indexes
    objectStore.createIndex('email', 'email', { unique: true });
    objectStore.createIndex('age', 'age', { unique: false });
  }
};
```

### Object Store Creation Strategies

#### Key Path Specification

```javascript
// Use existing property as key
const store = db.createObjectStore('users', { keyPath: 'id' });

// Nested key path
const store = db.createObjectStore('users', { keyPath: 'metadata.userId' });

// Auto-incrementing key
const store = db.createObjectStore('users', { autoIncrement: true });

// Out-of-line keys (manually specified on each operation)
const store = db.createObjectStore('users');
```

### Transaction Model

All database operations occur within transactions. Transactions define scope (object stores) and mode (readonly, readwrite, versionchange):

```javascript
const transaction = db.transaction(['users', 'posts'], 'readwrite');

transaction.oncomplete = () => {
  console.log('Transaction completed successfully');
};

transaction.onerror = (event) => {
  console.error('Transaction failed:', event.target.error);
};

transaction.onabort = () => {
  console.log('Transaction aborted');
};

const userStore = transaction.objectStore('users');
const postStore = transaction.objectStore('posts');
```

#### Transaction Lifecycle

Transactions auto-commit when all requests complete and the microtask queue empties:

```javascript
const transaction = db.transaction(['users'], 'readwrite');
const store = transaction.objectStore('users');

const request = store.add({ name: 'Alice' });

request.onsuccess = () => {
  console.log('Added user');
  // Transaction still active here
  
  // Synchronous operation keeps transaction alive
  store.add({ name: 'Bob' });
};

// Transaction commits after event handlers complete
// and no pending requests remain
```

### CRUD Operations

#### Create (Add/Put)

```javascript
const transaction = db.transaction(['users'], 'readwrite');
const store = transaction.objectStore('users');

// add() fails if key exists
const addRequest = store.add({ id: 1, name: 'Alice', age: 30 });

addRequest.onsuccess = () => {
  console.log('User added, key:', addRequest.result);
};

// put() overwrites existing records
const putRequest = store.put({ id: 1, name: 'Alice Updated', age: 31 });
```

#### Read (Get)

```javascript
const transaction = db.transaction(['users'], 'readonly');
const store = transaction.objectStore('users');

const request = store.get(1);

request.onsuccess = () => {
  const user = request.result;
  if (user) {
    console.log('Found user:', user);
  } else {
    console.log('User not found');
  }
};
```

#### Update (Put)

```javascript
const transaction = db.transaction(['users'], 'readwrite');
const store = transaction.objectStore('users');

// Retrieve, modify, store pattern
const getRequest = store.get(1);

getRequest.onsuccess = () => {
  const user = getRequest.result;
  user.age = 32;
  
  const updateRequest = store.put(user);
  updateRequest.onsuccess = () => {
    console.log('User updated');
  };
};
```

#### Delete

```javascript
const transaction = db.transaction(['users'], 'readwrite');
const store = transaction.objectStore('users');

const request = store.delete(1);

request.onsuccess = () => {
  console.log('User deleted');
};
```

### Cursor-Based Iteration

Cursors provide sequential access to multiple records:

```javascript
const transaction = db.transaction(['users'], 'readonly');
const store = transaction.objectStore('users');

const request = store.openCursor();

request.onsuccess = (event) => {
  const cursor = event.target.result;
  
  if (cursor) {
    console.log('Key:', cursor.key, 'Value:', cursor.value);
    
    // Move to next record
    cursor.continue();
  } else {
    console.log('No more records');
  }
};
```

#### Cursor Direction and Range

```javascript
// Iterate in reverse
store.openCursor(null, 'prev');

// Iterate with key range
const range = IDBKeyRange.bound(1, 10);
store.openCursor(range, 'next');

// Skip to specific key
request.onsuccess = (event) => {
  const cursor = event.target.result;
  if (cursor) {
    if (cursor.key < 5) {
      cursor.continue(5); // Jump to key 5
    } else {
      cursor.continue(); // Normal iteration
    }
  }
};
```

#### Cursor Modification

```javascript
const transaction = db.transaction(['users'], 'readwrite');
const store = transaction.objectStore('users');

store.openCursor().onsuccess = (event) => {
  const cursor = event.target.result;
  
  if (cursor) {
    const user = cursor.value;
    user.lastModified = Date.now();
    
    cursor.update(user); // Update current record
    
    // Or delete current record
    // cursor.delete();
    
    cursor.continue();
  }
};
```

### Index Operations

Indexes enable queries on non-key properties:

```javascript
const transaction = db.transaction(['users'], 'readonly');
const store = transaction.objectStore('users');
const index = store.index('email');

// Get by index
const request = index.get('alice@example.com');

request.onsuccess = () => {
  console.log('User:', request.result);
};

// Get key by index
const keyRequest = index.getKey('alice@example.com');

keyRequest.onsuccess = () => {
  console.log('Primary key:', keyRequest.result);
};

// Iterate via index
index.openCursor().onsuccess = (event) => {
  const cursor = event.target.result;
  if (cursor) {
    console.log('Indexed value:', cursor.key, 'Record:', cursor.value);
    cursor.continue();
  }
};
```

#### Compound Indexes

```javascript
request.onupgradeneeded = (event) => {
  const db = event.target.result;
  const store = db.createObjectStore('users', { keyPath: 'id' });
  
  // Index on array creates compound key
  store.createIndex('name_age', ['lastName', 'firstName', 'age']);
};

// Query with compound key
const index = store.index('name_age');
const range = IDBKeyRange.bound(
  ['Smith', 'A', 20],
  ['Smith', 'Z', 40]
);
index.openCursor(range);
```

### Key Ranges

IDBKeyRange constructs specify query boundaries:

```javascript
// Only key 5
IDBKeyRange.only(5);

// Keys >= 5
IDBKeyRange.lowerBound(5);

// Keys > 5 (open bound)
IDBKeyRange.lowerBound(5, true);

// Keys <= 10
IDBKeyRange.upperBound(10);

// Keys < 10 (open bound)
IDBKeyRange.upperBound(10, true);

// Keys 5 <= x <= 10
IDBKeyRange.bound(5, 10);

// Keys 5 < x < 10 (both open)
IDBKeyRange.bound(5, 10, true, true);
```

#### Range Queries

```javascript
const transaction = db.transaction(['users'], 'readonly');
const store = transaction.objectStore('users');
const index = store.index('age');

// Users aged 25-35
const range = IDBKeyRange.bound(25, 35);

index.openCursor(range).onsuccess = (event) => {
  const cursor = event.target.result;
  if (cursor) {
    console.log('User in age range:', cursor.value);
    cursor.continue();
  }
};
```

### Bulk Operations

#### GetAll and GetAllKeys

```javascript
const transaction = db.transaction(['users'], 'readonly');
const store = transaction.objectStore('users');

// Get all records
const getAllRequest = store.getAll();

getAllRequest.onsuccess = () => {
  console.log('All users:', getAllRequest.result);
};

// Get all keys
const getAllKeysRequest = store.getAllKeys();

getAllKeysRequest.onsuccess = () => {
  console.log('All keys:', getAllKeysRequest.result);
};

// Limited count
const limitedRequest = store.getAll(null, 10); // First 10 records
```

#### Count Operations

```javascript
const transaction = db.transaction(['users'], 'readonly');
const store = transaction.objectStore('users');

const countRequest = store.count();

countRequest.onsuccess = () => {
  console.log('Total users:', countRequest.result);
};

// Count with range
const range = IDBKeyRange.bound(1, 100);
const rangeCountRequest = store.count(range);
```

#### Clear Object Store

```javascript
const transaction = db.transaction(['users'], 'readwrite');
const store = transaction.objectStore('users');

const clearRequest = store.clear();

clearRequest.onsuccess = () => {
  console.log('All records deleted');
};
```

### Version Management

Database schema changes require version upgrades:

```javascript
// Initial version
const request1 = indexedDB.open('MyDB', 1);

request1.onupgradeneeded = (event) => {
  const db = event.target.result;
  db.createObjectStore('users', { keyPath: 'id' });
};

// Later upgrade
const request2 = indexedDB.open('MyDB', 2);

request2.onupgradeneeded = (event) => {
  const db = event.target.result;
  const transaction = event.target.transaction;
  
  if (event.oldVersion < 2) {
    // Add new object store
    db.createObjectStore('posts', { keyPath: 'id' });
    
    // Add index to existing store
    const userStore = transaction.objectStore('users');
    userStore.createIndex('email', 'email', { unique: true });
  }
};
```

#### Data Migration

```javascript
request.onupgradeneeded = (event) => {
  const db = event.target.result;
  const transaction = event.target.transaction;
  
  if (event.oldVersion < 3) {
    const store = transaction.objectStore('users');
    
    // Migrate data structure
    store.openCursor().onsuccess = (event) => {
      const cursor = event.target.result;
      if (cursor) {
        const user = cursor.value;
        
        // Transform old format to new
        user.fullName = `${user.firstName} ${user.lastName}`;
        delete user.firstName;
        delete user.lastName;
        
        cursor.update(user);
        cursor.continue();
      }
    };
  }
};
```

### Error Handling Patterns

#### Request-Level Errors

```javascript
const request = store.get(1);

request.onerror = (event) => {
  console.error('Get failed:', event.target.error);
  event.preventDefault(); // Prevent transaction abort
};
```

#### Transaction-Level Errors

```javascript
const transaction = db.transaction(['users'], 'readwrite');

transaction.onerror = (event) => {
  console.error('Transaction error:', event.target.error);
};

transaction.onabort = (event) => {
  console.log('Transaction aborted');
  
  // Check abort reason
  if (transaction.error) {
    console.error('Abort reason:', transaction.error);
  }
};
```

#### Common Error Types

```javascript
// ConstraintError: Unique constraint violation
store.add({ id: 1, email: 'duplicate@example.com' });

// DataError: Invalid key or key path
store.add({ invalidKey: 'abc' }); // When keyPath expects number

// TransactionInactiveError: Transaction already completed
const transaction = db.transaction(['users'], 'readwrite');
setTimeout(() => {
  transaction.objectStore('users').add({}); // Fails
}, 100);

// NotFoundError: Object store doesn't exist
db.transaction(['nonexistent'], 'readonly');
```

### Promise Wrapper Pattern

Convert callback-based API to promises:

```javascript
function promisifyRequest(request) {
  return new Promise((resolve, reject) => {
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

async function getUser(db, id) {
  const transaction = db.transaction(['users'], 'readonly');
  const store = transaction.objectStore('users');
  return promisifyRequest(store.get(id));
}

// Usage
try {
  const user = await getUser(db, 1);
  console.log('User:', user);
} catch (error) {
  console.error('Error:', error);
}
```

### Storage Limits and Quotas

[Inference] Browser implementations typically provide different storage limits based on persistence type:

```javascript
// Check storage estimate
if (navigator.storage && navigator.storage.estimate) {
  navigator.storage.estimate().then(estimate => {
    console.log('Usage:', estimate.usage);
    console.log('Quota:', estimate.quota);
    console.log('Percentage:', (estimate.usage / estimate.quota * 100).toFixed(2));
  });
}

// Request persistent storage
if (navigator.storage && navigator.storage.persist) {
  navigator.storage.persist().then(granted => {
    if (granted) {
      console.log('Persistent storage granted');
    }
  });
}
```

### Database Deletion

```javascript
const deleteRequest = indexedDB.deleteDatabase('MyDatabase');

deleteRequest.onsuccess = () => {
  console.log('Database deleted');
};

deleteRequest.onerror = () => {
  console.error('Delete failed');
};

deleteRequest.onblocked = () => {
  console.log('Delete blocked by open connections');
};
```

### Multi-Tab Coordination

#### Version Change Blocking

```javascript
const request = indexedDB.open('MyDB', 2);

request.onblocked = () => {
  console.log('Upgrade blocked by other tabs');
  // Notify user to close other tabs
};

// In other tabs, close connection on versionchange
db.onversionchange = () => {
  db.close();
  alert('Database upgrade required. Page will reload.');
  location.reload();
};
```

### Binary Data Storage

```javascript
const transaction = db.transaction(['files'], 'readwrite');
const store = transaction.objectStore('files');

// Store Blob
const blob = new Blob(['file content'], { type: 'text/plain' });
store.add({ id: 1, name: 'document.txt', data: blob });

// Store ArrayBuffer
const buffer = new ArrayBuffer(8);
const view = new Uint8Array(buffer);
view[0] = 255;
store.add({ id: 2, name: 'binary.dat', data: buffer });

// Store File
const fileInput = document.querySelector('input[type="file"]');
const file = fileInput.files[0];
store.add({ id: 3, name: file.name, data: file });
```

### Performance Considerations

#### Batch Operations in Single Transaction

```javascript
// Efficient: Single transaction
const transaction = db.transaction(['users'], 'readwrite');
const store = transaction.objectStore('users');

for (let i = 0; i < 1000; i++) {
  store.add({ id: i, name: `User ${i}` });
}

// Less efficient: Multiple transactions
for (let i = 0; i < 1000; i++) {
  const transaction = db.transaction(['users'], 'readwrite');
  transaction.objectStore('users').add({ id: i, name: `User ${i}` });
}
```

#### Index Selection

```javascript
// Use appropriate index for query
const store = transaction.objectStore('users');

// Query by email (has index) - efficient
const emailIndex = store.index('email');
emailIndex.get('alice@example.com');

// Query by unindexed field - requires full scan
store.openCursor().onsuccess = (event) => {
  const cursor = event.target.result;
  if (cursor) {
    if (cursor.value.city === 'New York') {
      // Process matching record
    }
    cursor.continue();
  }
};
```

---

