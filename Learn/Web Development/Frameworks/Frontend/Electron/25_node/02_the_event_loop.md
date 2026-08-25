## The Event Loop


The event loop is the core mechanism that enables Node.js (and therefore Electron) to perform non-blocking I/O operations despite JavaScript being single-threaded. Understanding it is crucial for writing efficient, performant Electron applications.

### What is the Event Loop?

The event loop is a continuously running process that monitors the call stack and callback queues, executing code, collecting and processing events, and executing queued sub-tasks. It allows Node.js to offload operations to the system kernel whenever possible, then execute callbacks when those operations complete.

**Single-Threaded but Non-Blocking**

JavaScript runs on a single thread, meaning it can only execute one piece of code at a time. However, the event loop allows asynchronous operations to run "in the background" (actually handled by the system or libuv), freeing the main thread to continue executing other code.

### Event Loop Phases

The event loop operates in distinct phases, each with its own queue of callbacks to execute. The loop processes these phases in order, repeatedly.

**The Six Phases**

```
   ┌───────────────────────────┐
┌─>│           timers          │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │     pending callbacks     │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │       idle, prepare       │
│  └─────────────┬─────────────┘      ┌───────────────┐
│  ┌─────────────┴─────────────┐      │   incoming:   │
│  │           poll            │<─────┤  connections, │
│  └─────────────┬─────────────┘      │   data, etc.  │
│  ┌─────────────┴─────────────┐      └───────────────┘
│  │           check           │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
└──┤      close callbacks      │
   └───────────────────────────┘
```

### Phase-by-Phase Breakdown

**1. Timers Phase**

Executes callbacks scheduled by `setTimeout()` and `setInterval()`. [Inference: Based on Node.js event loop documentation]

```javascript
console.log('Start');

setTimeout(() => {
  console.log('Timer 1 (0ms)');
}, 0);

setTimeout(() => {
  console.log('Timer 2 (10ms)');
}, 10);

console.log('End');

// Output:
// Start
// End
// Timer 1 (0ms)
// Timer 2 (10ms) (after 10ms)
```

The timer phase checks if any timer thresholds have been reached and executes their callbacks. Timers are not guaranteed to execute at the exact time specified—they execute as soon as possible after the threshold is reached.

**2. Pending Callbacks Phase**

Executes I/O callbacks deferred from the previous cycle. These are typically system-level callbacks like TCP errors.

```javascript
const fs = require('fs');

// If a file operation encounters an error,
// the error callback executes in pending callbacks phase
fs.readFile('nonexistent.txt', (err, data) => {
  if (err) {
    console.log('Error callback executed');
  }
});
```

**3. Idle, Prepare Phase**

Used internally by Node.js. [Unverified: External code typically doesn't interact with this phase directly]

**4. Poll Phase**

This is the most important phase. It retrieves new I/O events and executes I/O-related callbacks (except close callbacks, timers, and `setImmediate()`).

```javascript
const fs = require('fs');

console.log('Start');

// File read is I/O - callback executes in poll phase
fs.readFile('file.txt', 'utf8', (err, data) => {
  console.log('File read complete');
});

console.log('End');

// Output:
// Start
// End
// File read complete
```

**Poll Phase Behavior:**

The poll phase will wait for incoming connections, requests, etc. However, it won't wait indefinitely. It will move to the next phase if:

- The poll queue is empty and there are `setImmediate()` callbacks waiting
- Timers have reached their threshold

**5. Check Phase**

Executes `setImmediate()` callbacks. This phase allows you to execute callbacks immediately after the poll phase completes.

```javascript
setImmediate(() => {
  console.log('setImmediate callback');
});

setTimeout(() => {
  console.log('setTimeout callback');
}, 0);

// Output order can vary, but typically:
// setTimeout callback
// setImmediate callback
```

**6. Close Callbacks Phase**

Executes close event callbacks, such as `socket.on('close', ...)`.

```javascript
const net = require('net');

const server = net.createServer();

server.on('close', () => {
  console.log('Server closed');
});

server.listen(3000);
server.close();

// 'Server closed' executes in close callbacks phase
```

### Microtasks: process.nextTick() and Promises

Between each phase of the event loop, Node.js processes two special queues called "microtask queues". These have higher priority than the phase queues.

**process.nextTick() Queue**

Executes before any other phase and before Promises. [Inference: Based on Node.js documentation stating nextTick has highest priority]

```javascript
console.log('1: Script start');

setTimeout(() => {
  console.log('2: setTimeout');
}, 0);

Promise.resolve().then(() => {
  console.log('3: Promise');
});

process.nextTick(() => {
  console.log('4: nextTick');
});

console.log('5: Script end');

// Output:
// 1: Script start
// 5: Script end
// 4: nextTick
// 3: Promise
// 2: setTimeout
```

**Promise Microtask Queue**

Executes after `process.nextTick()` but before the next event loop phase.

```javascript
Promise.resolve().then(() => {
  console.log('Promise 1');
}).then(() => {
  console.log('Promise 2');
});

process.nextTick(() => {
  console.log('nextTick 1');
  process.nextTick(() => {
    console.log('nextTick 2');
  });
});

// Output:
// nextTick 1
// nextTick 2
// Promise 1
// Promise 2
```

### Execution Priority Order

From highest to lowest priority:

1. Synchronous code (current call stack)
2. `process.nextTick()` callbacks
3. Promise microtasks (`.then()`, `.catch()`, `.finally()`)
4. Event loop phase callbacks (timers, I/O, check, close)

```javascript
console.log('Sync 1');

setTimeout(() => console.log('setTimeout'), 0);

setImmediate(() => console.log('setImmediate'));

Promise.resolve()
  .then(() => console.log('Promise 1'))
  .then(() => console.log('Promise 2'));

process.nextTick(() => console.log('nextTick 1'));
process.nextTick(() => console.log('nextTick 2'));

console.log('Sync 2');

// Output:
// Sync 1
// Sync 2
// nextTick 1
// nextTick 2
// Promise 1
// Promise 2
// setTimeout
// setImmediate
```

### setTimeout vs setImmediate

The order of execution between `setTimeout(fn, 0)` and `setImmediate(fn)` can vary depending on context.

**In the Main Module:**

The order is non-deterministic because it depends on process performance.

```javascript
setTimeout(() => {
  console.log('setTimeout');
}, 0);

setImmediate(() => {
  console.log('setImmediate');
});

// Output can be either order
```

**Inside an I/O Cycle:**

`setImmediate()` always executes first because it's checked immediately after the poll phase.

```javascript
const fs = require('fs');

fs.readFile(__filename, () => {
  setTimeout(() => {
    console.log('setTimeout');
  }, 0);
  
  setImmediate(() => {
    console.log('setImmediate');
  });
});

// Output (consistent):
// setImmediate
// setTimeout
```

### Common Patterns and Use Cases

**Deferring Work with process.nextTick()**

Use when you want to ensure code runs before any I/O events but after the current operation completes.

```javascript
function asyncOperation(data, callback) {
  // Ensure callback is always asynchronous
  if (!data) {
    process.nextTick(() => {
      callback(new Error('No data provided'));
    });
    return;
  }
  
  // Do actual async work
  setTimeout(() => {
    callback(null, data.toUpperCase());
  }, 100);
}

// Caller can always expect async behavior
asyncOperation('test', (err, result) => {
  console.log(result);
});

console.log('Called asyncOperation');

// Output:
// Called asyncOperation
// (error or result appears next)
```

**Breaking Up CPU-Intensive Work**

Prevent blocking the event loop by breaking work into chunks.

```javascript
function processLargeArray(array) {
  const chunkSize = 1000;
  let index = 0;
  
  function processChunk() {
    const endIndex = Math.min(index + chunkSize, array.length);
    
    for (let i = index; i < endIndex; i++) {
      // Process array[i]
      heavyOperation(array[i]);
    }
    
    index = endIndex;
    
    if (index < array.length) {
      // Schedule next chunk
      setImmediate(processChunk);
    } else {
      console.log('Processing complete');
    }
  }
  
  processChunk();
}

function heavyOperation(item) {
  // Some CPU-intensive work
  for (let i = 0; i < 1000000; i++) {
    Math.sqrt(i);
  }
}

// This keeps the event loop responsive
processLargeArray(new Array(10000));
```

**Avoiding process.nextTick() Recursion**

Be careful with recursive `process.nextTick()` calls—they can starve the event loop.

```javascript
// BAD: This blocks the event loop
let count = 0;
function recursiveNextTick() {
  if (count < 1000) {
    count++;
    process.nextTick(recursiveNextTick);
  }
}

// The event loop can't proceed to timers/I/O
setTimeout(() => {
  console.log('This will be delayed significantly');
}, 0);

recursiveNextTick();

// BETTER: Use setImmediate for recursion
count = 0;
function recursiveImmediate() {
  if (count < 1000) {
    count++;
    setImmediate(recursiveImmediate);
  }
}

// This allows other phases to run between iterations
recursiveImmediate();
```

### Event Loop in Electron Context

Electron has multiple event loops running simultaneously:

**Main Process Event Loop**

Runs the standard Node.js event loop, handling all Node.js operations.

**Renderer Process Event Loop**

Each renderer process has both:

- A Node.js event loop (if Node integration is enabled)
- A browser event loop (for DOM events, rendering, etc.)

```javascript
// Main process
const { app, BrowserWindow } = require('electron');

app.on('ready', () => {
  // This callback executes in main process event loop
  const win = new BrowserWindow();
  
  // Heavy computation in main process
  setImmediate(() => {
    performHeavyComputation();
  });
});

// Renderer process
// Both Node.js and browser event loops are active
document.getElementById('btn').addEventListener('click', () => {
  // Browser event loop handles this
  console.log('Button clicked');
  
  // Node.js event loop handles this
  const fs = require('fs');
  fs.readFile('file.txt', (err, data) => {
    console.log('File read in renderer');
  });
});
```

### Debugging Event Loop Issues

**Checking Event Loop Lag**

Monitor if the event loop is blocked.

```javascript
const { performance } = require('perf_hooks');

let lastCheck = performance.now();

setInterval(() => {
  const now = performance.now();
  const lag = now - lastCheck - 1000; // Expected: ~1000ms
  
  if (lag > 100) {
    console.warn(`Event loop lag: ${lag}ms`);
  }
  
  lastCheck = now;
}, 1000);
```

**Using async_hooks for Tracking**

Track asynchronous operations to understand what's keeping the event loop busy.

```javascript
const async_hooks = require('async_hooks');
const fs = require('fs');

const activeResources = new Map();

const hook = async_hooks.createHook({
  init(asyncId, type, triggerAsyncId) {
    activeResources.set(asyncId, { type, triggerAsyncId });
  },
  destroy(asyncId) {
    activeResources.delete(asyncId);
  }
});

hook.enable();

// After some time, check what's still active
setTimeout(() => {
  console.log('Active async resources:', activeResources.size);
  for (const [id, resource] of activeResources) {
    console.log(`  ${id}: ${resource.type}`);
  }
}, 5000);
```

### Event Loop Best Practices

**Keep Callbacks Fast**

Long-running synchronous code blocks the entire event loop.

```javascript
// BAD: Blocks event loop
app.get('/slow', (req, res) => {
  let sum = 0;
  for (let i = 0; i < 10000000000; i++) {
    sum += i;
  }
  res.send(`Result: ${sum}`);
});

// GOOD: Break into chunks or use worker threads
const { Worker } = require('worker_threads');

app.get('/fast', (req, res) => {
  const worker = new Worker('./heavy-computation.js');
  worker.on('message', (result) => {
    res.send(`Result: ${result}`);
  });
});
```

**Prefer setImmediate over setTimeout(fn, 0)**

`setImmediate()` is more explicit about intent and slightly more efficient for deferring to the next iteration.

```javascript
// Less clear intent
setTimeout(() => {
  doSomethingAsync();
}, 0);

// Clear intent: run after I/O
setImmediate(() => {
  doSomethingAsync();
});
```

**Use process.nextTick() Sparingly**

Only use `process.nextTick()` when you specifically need to run before I/O events. Overuse can starve I/O.

```javascript
// Good use: ensuring async behavior
function myAsyncFunction(callback) {
  process.nextTick(() => {
    callback(null, result);
  });
}

// Questionable use: probably should be setImmediate
process.nextTick(() => {
  doNonUrgentWork();
});
```

### Visualizing Event Loop Flow

```javascript
console.log('1: Sync start');

setTimeout(() => {
  console.log('6: Timer callback');
  
  Promise.resolve().then(() => {
    console.log('7: Promise in timer');
  });
}, 0);

Promise.resolve()
  .then(() => {
    console.log('3: Promise microtask');
    return Promise.resolve();
  })
  .then(() => {
    console.log('4: Chained promise');
  });

process.nextTick(() => {
  console.log('2: nextTick microtask');
  
  process.nextTick(() => {
    console.log('2.5: Nested nextTick');
  });
});

setImmediate(() => {
  console.log('8: setImmediate callback');
});

console.log('5: Sync end');

// Output:
// 1: Sync start
// 5: Sync end
// 2: nextTick microtask
// 2.5: Nested nextTick
// 3: Promise microtask
// 4: Chained promise
// 6: Timer callback
// 7: Promise in timer
// 8: setImmediate callback
```

Understanding the event loop helps you write code that doesn't block, handles errors properly, and performs well—all critical for building responsive Electron applications.

