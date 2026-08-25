## Common Pitfalls


### Assuming Response Order Matches Request Order

[Inference] Network latency varies based on request size, server load, routing, and processing complexity. Smaller or cached responses often return faster than earlier, larger requests.

### Not Handling Aborted Requests

AbortError must be caught explicitly; otherwise it propagates as an unhandled rejection:

```javascript
// Wrong: AbortError treated as failure
try {
  await fetch(url, { signal });
} catch (error) {
  showErrorMessage(error); // Shows error for intentional cancellation
}

// Correct: Distinguish abort from failure
try {
  await fetch(url, { signal });
} catch (error) {
  if (error.name === 'AbortError') {
    return; // Expected cancellation
  }
  showErrorMessage(error);
}
```

### Shared AbortController Across Independent Requests

Using one controller for multiple independent requests causes unintended cancellations:

```javascript
// Wrong: One controller for all requests
const controller = new AbortController();

fetch('/api/user', { signal: controller.signal });
fetch('/api/posts', { signal: controller.signal });

controller.abort(); // Cancels BOTH requests

// Correct: Separate controllers
const userController = new AbortController();
const postsController = new AbortController();

fetch('/api/user', { signal: userController.signal });
fetch('/api/posts', { signal: postsController.signal });
```

### Race Conditions in Error Handlers

Error handling itself can race with subsequent requests:

```javascript
// Problematic: error handler may run after newer request
let currentError = null;

fetch(url1).catch(error => {
  currentError = error; // May overwrite error from url2
});

fetch(url2).catch(error => {
  currentError = error;
});

// Better: Track errors per request
const errors = new Map();

async function fetchTracked(id, url) {
  try {
    return await fetch(url);
  } catch (error) {
    errors.set(id, error);
    throw error;
  }
}
```

### Relying on Finally Blocks Without Sequencing

Finally blocks execute regardless of resolution order:

```javascript
// Problematic
let isLoading = false;

async function fetchData(url) {
  isLoading = true;
  try {
    return await fetch(url);
  } finally {
    isLoading = false; // May clear loading state from newer request
  }
}

// Better: Track per request
const loadingStates = new Map();

async function fetchData(id, url) {
  loadingStates.set(id, true);
  try {
    return await fetch(url);
  } finally {
    loadingStates.set(id, false);
  }
}
```

