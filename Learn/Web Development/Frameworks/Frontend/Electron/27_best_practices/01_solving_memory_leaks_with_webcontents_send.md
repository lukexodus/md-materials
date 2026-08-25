## Solving Memory Leaks with webContents.send()


### Problem Demonstration

```javascript
// Main Process - Causes memory leak
setInterval(() => {
  mainWindow.webContents.send('update', largeDataObject);
}, 100); // Sending 10 times per second
```

```javascript
// Renderer Process - Memory accumulates
ipcRenderer.on('update', (event, data) => {
  // Processing data without cleanup
  updateUI(data);
});
```

### Solution 1: Throttling Updates

**Throttling** ensures the function executes at most once per specified time period.

```javascript
// Main Process
const throttle = (func, limit) => {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
};

const sendUpdate = throttle((data) => {
  mainWindow.webContents.send('update', data);
}, 1000); // Maximum once per second

// Now use throttled version
setInterval(() => {
  sendUpdate(data);
}, 100);
```

### Solution 2: Debouncing Updates

**Debouncing** delays execution until after a period of inactivity.

```javascript
// Main Process
const debounce = (func, delay) => {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      func.apply(this, args);
    }, delay);
  };
};

const sendUpdate = debounce((data) => {
  mainWindow.webContents.send('update', data);
}, 500); // Wait 500ms after last call

// Rapid calls will only send the last update
dataStream.on('data', (chunk) => {
  sendUpdate(chunk);
});
```

### Solution 3: Proper Listener Cleanup

```javascript
// Renderer Process - BAD (creates multiple listeners)
function setupListener() {
  ipcRenderer.on('update', (event, data) => {
    updateUI(data);
  });
}

setupListener(); // Called multiple times = memory leak
```

```javascript
// Renderer Process - GOOD (cleanup before adding)
function setupListener() {
  // Remove existing listener first
  ipcRenderer.removeAllListeners('update');
  
  ipcRenderer.on('update', (event, data) => {
    updateUI(data);
  });
}
```

### Solution 4: Using once() for Single-Use Listeners

```javascript
// Renderer Process
ipcRenderer.once('update', (event, data) => {
  // Automatically removed after first execution
  updateUI(data);
});
```

### Solution 5: Complete Implementation with Cleanup

```javascript
// Main Process
class UpdateManager {
  constructor(window) {
    this.window = window;
    this.lastSent = 0;
    this.minInterval = 1000; // Minimum 1 second between updates
  }

  sendUpdate(data) {
    const now = Date.now();
    if (now - this.lastSent >= this.minInterval) {
      this.window.webContents.send('update', data);
      this.lastSent = now;
    }
  }
}

const updateManager = new UpdateManager(mainWindow);

setInterval(() => {
  updateManager.sendUpdate(getData());
}, 100);
```

```javascript
// Renderer Process
class UpdateHandler {
  constructor() {
    this.listener = null;
  }

  start() {
    // Clean up existing listener
    this.stop();
    
    // Create new listener
    this.listener = (event, data) => {
      this.processUpdate(data);
    };
    
    ipcRenderer.on('update', this.listener);
  }

  stop() {
    if (this.listener) {
      ipcRenderer.removeListener('update', this.listener);
      this.listener = null;
    }
  }

  processUpdate(data) {
    // Your update logic here
    updateUI(data);
  }
}

const handler = new UpdateHandler();
handler.start();

// Clean up when component unmounts or window closes
window.addEventListener('beforeunload', () => {
  handler.stop();
});
```

### Solution 6: Using Lodash Throttle/Debounce

```javascript
// Install: npm install lodash

// Main Process
const _ = require('lodash');

const sendUpdate = _.throttle((data) => {
  mainWindow.webContents.send('update', data);
}, 1000, { leading: true, trailing: false });

// Or debounce
const sendUpdateDebounced = _.debounce((data) => {
  mainWindow.webContents.send('update', data);
}, 500);
```

### Memory Monitoring

```javascript
// Check for memory leaks during development
setInterval(() => {
  const mem = process.memoryUsage();
  console.log(`Heap Used: ${(mem.heapUsed / 1024 / 1024).toFixed(2)} MB`);
}, 5000);
```

The key principles are: limit update frequency, clean up listeners properly, and avoid creating duplicate listeners.​​​​​​​​​​​​​​​​

---

