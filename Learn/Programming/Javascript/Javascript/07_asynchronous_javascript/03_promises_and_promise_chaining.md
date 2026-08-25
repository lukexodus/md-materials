## Promises and Promise Chaining


### Understanding Promises

Promises are objects that represent the eventual completion (or failure) of an asynchronous operation and its resulting value. They were introduced in ES6 (ECMAScript 2015) to address the challenges of managing asynchronous code and to provide a more elegant alternative to callback-based approaches.

**Key Points:**

- Promises represent a value that might not be available yet
- They have three states: pending, fulfilled, or rejected
- Once settled (fulfilled or rejected), a promise cannot change state
- Promises are chainable, allowing for sequence control of asynchronous operations
- They help avoid the "callback hell" problem in JavaScript

### Promise States

A Promise exists in one of these states:

- **Pending**: Initial state, neither fulfilled nor rejected
- **Fulfilled**: The operation completed successfully, and the promise has a resulting value
- **Rejected**: The operation failed, and the promise has a reason for the failure
- **Settled**: A term to describe a promise that is either fulfilled or rejected, but not pending

### Creating Promises

The Promise constructor takes an executor function with two parameters: `resolve` and `reject`.

```javascript
const myPromise = new Promise((resolve, reject) => {
  // Asynchronous operation
  const success = true;
  
  if (success) {
    resolve('Operation completed successfully!');
  } else {
    reject(new Error('Operation failed!'));
  }
});
```

### Consuming Promises

Promises provide `.then()`, `.catch()`, and `.finally()` methods for handling their resolution:

```javascript
myPromise
  .then(result => {
    console.log('Success:', result);
  })
  .catch(error => {
    console.error('Error:', error);
  })
  .finally(() => {
    console.log('Promise settled (fulfilled or rejected)');
  });
```

### Promise Chaining

One of the most powerful features of promises is the ability to chain them together for sequential asynchronous operations.

**Key Points:**

- Each `.then()` returns a new Promise
- Values returned from `.then()` handlers are automatically wrapped in resolved promises
- Thrown errors or rejected promises in handlers are propagated down the chain
- This approach creates a flat sequence of operations instead of nested callbacks

### Basic Promise Chaining

```javascript
fetchUserData(userId)
  .then(userData => {
    console.log('User data:', userData);
    return fetchUserPosts(userData.id);
  })
  .then(posts => {
    console.log('User posts:', posts);
    return fetchPostComments(posts[0].id);
  })
  .then(comments => {
    console.log('Post comments:', comments);
  })
  .catch(error => {
    console.error('Error in promise chain:', error);
  });
```

### Value Transformation in Promise Chains

Each `.then()` can transform the value from the previous promise:

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json(); // Parse JSON response
  })
  .then(data => {
    // Transform the data
    return data.items.map(item => ({
      id: item.id,
      name: item.name.toUpperCase(),
      createdAt: new Date(item.created_at)
    }));
  })
  .then(transformedData => {
    console.log('Transformed data:', transformedData);
  })
  .catch(error => {
    console.error('Error:', error);
  });
```

### Error Handling in Promise Chains

Errors propagate down the chain until caught:

```javascript
fetchData()
  .then(data => {
    if (!data.isValid) {
      throw new Error('Invalid data');
    }
    return processData(data);
  })
  .then(processedData => {
    return saveData(processedData);
  })
  .then(savedResult => {
    console.log('Data saved:', savedResult);
  })
  .catch(error => {
    // This will catch any error thrown in any of the previous promises
    console.error('Operation failed:', error);
  });
```

### Returning Promises in Chain Handlers

When you return a promise from a `.then()` handler, the next `.then()` waits for that promise to settle:

```javascript
function getUserData(userId) {
  return fetch(`/api/users/${userId}`)
    .then(response => response.json());
}

function getUserPosts(userId) {
  return fetch(`/api/users/${userId}/posts`)
    .then(response => response.json());
}

getUserData('user123')
  .then(user => {
    console.log('User:', user);
    // Return another promise to chain
    return getUserPosts(user.id);
  })
  .then(posts => {
    console.log('User posts:', posts);
  })
  .catch(error => {
    console.error('Error:', error);
  });
```

### Advanced Promise Chaining Patterns

#### Conditional Chaining

```javascript
checkUserPermission(userId)
  .then(hasPermission => {
    if (hasPermission) {
      return fetchProtectedData();
    } else {
      return fetchPublicData();
    }
  })
  .then(data => {
    console.log('Retrieved data:', data);
  });
```

#### Parallel Operations in Sequence

```javascript
// Process array of items sequentially
function processSequentially(items) {
  return items.reduce((promise, item) => {
    return promise.then(results => {
      return processItem(item).then(result => {
        return [...results, result];
      });
    });
  }, Promise.resolve([]));
}

// Usage
const items = [1, 2, 3, 4, 5];
processSequentially(items)
  .then(results => {
    console.log('All processed:', results);
  });
```

#### Promise Chain Branching

```javascript
function fetchData() {
  return fetch('/api/data')
    .then(response => response.json());
}

// Branch the promise chain
const dataPromise = fetchData();

// Branch 1: Process data for UI
dataPromise
  .then(data => renderUI(data))
  .catch(error => showUIError(error));

// Branch 2: Save data to local storage
dataPromise
  .then(data => localStorage.setItem('cached_data', JSON.stringify(data)))
  .catch(error => console.error('Cache error:', error));
```

### Promise Combinators and Helpers

#### **`Promise.all([...])`**

Waits for **all promises** to resolve.  
If **any promise rejects**, it **immediately rejects** with that reason.

```javascript
Promise.all([
  Promise.resolve(1),
  Promise.resolve(2),
  Promise.resolve(3)
]).then(console.log); // [1, 2, 3]
```

```javascript
Promise.all([
  Promise.resolve(1),
  Promise.reject("fail"),
  Promise.resolve(3)
]).catch(console.error); // "fail"
```

---

#### **`Promise.race([...])`**

Returns a promise that resolves/rejects **as soon as the first promise settles** (resolves or rejects).

```javascript
Promise.race([
  new Promise(res => setTimeout(() => res("A"), 500)),
  new Promise(res => setTimeout(() => res("B"), 100))
]).then(console.log); // "B"
```

---

#### **`Promise.resolve(value)`**

Returns a promise that **immediately resolves** with the given value.  
If the value is a promise, it **adopts** its state.

```javascript
Promise.resolve(42).then(console.log); // 42

Promise.resolve(Promise.resolve("hi")).then(console.log); // "hi"
```

---

#### **`Promise.reject(reason)`**

Returns a promise that **immediately rejects** with the given reason.

```javascript
Promise.reject("error").catch(console.error); // "error"
```

---

#### **`Promise.allSettled([...])`**

Waits for **all promises to settle** (either fulfilled or rejected).  
Never short-circuits. Returns an array of result objects with `status` and `value` or `reason`.

```javascript
Promise.allSettled([
  Promise.resolve("OK"),
  Promise.reject("Failed")
]).then(results => console.log(results));
```

**Output:**
```js
[
  { status: "fulfilled", value: "OK" },
  { status: "rejected", reason: "Failed" }
]
```

Use this when you **want all results, even if some fail**.

---

#### **`Promise.any([...])`**

Returns the **first fulfilled** promise.  
If **all promises reject**, it throws an `AggregateError`.

```javascript
Promise.any([
  Promise.reject("A"),
  Promise.resolve("B"),
  Promise.resolve("C")
]).then(console.log); // "B"
```

If all fail:

```javascript
Promise.any([
  Promise.reject("A"),
  Promise.reject("B")
]).catch(e => console.error(e instanceof AggregateError)); // true
```

Use this when **you want the first successful result**, and don’t care about failures unless they all fail.

---

**Comparison Summary**

| Method             | Waits for All? | Rejects Fast? | Returns All? | Returns First Success? |
|--------------------|----------------|---------------|---------------|-------------------------|
| `Promise.all`       | ✅             | ✅ Yes         | ❌ No          | ❌                      |
| `Promise.allSettled`| ✅             | ❌ No          | ✅ Yes         | ❌                      |
| `Promise.race`      | ❌             | ✅/❌ Fastest   | ❌ No          | ✅/❌ (any settled)      |
| `Promise.any`       | ❌             | ❌ No          | ❌ No          | ✅                      |

---

**Conclusion**

Use:
- `Promise.allSettled` for **completeness** (get all outcomes)
- `Promise.any` when **you only care about the first success**
- `Promise.race` for **timeouts or competition**
- `Promise.all` when **you need all to succeed**

---

