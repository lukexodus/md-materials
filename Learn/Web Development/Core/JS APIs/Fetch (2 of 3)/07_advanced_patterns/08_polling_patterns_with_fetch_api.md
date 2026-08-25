## Polling Patterns with Fetch API


### Basic Polling Implementation

#### Simple Interval-Based Polling

```javascript
function startPolling(url, interval = 5000) {
  const intervalId = setInterval(async () => {
    try {
      const response = await fetch(url);
      const data = await response.json();
      console.log('Polled data:', data);
    } catch (error) {
      console.error('Polling error:', error);
    }
  }, interval);
  
  return () => clearInterval(intervalId);
}

// Usage
const stopPolling = startPolling('https://api.example.com/status', 5000);

// Stop polling when needed
stopPolling();
```

#### Polling with Immediate Execution

```javascript
async function pollWithImmediate(url, interval = 5000) {
  const poll = async () => {
    try {
      const response = await fetch(url);
      const data = await response.json();
      console.log('Polled data:', data);
      return data;
    } catch (error) {
      console.error('Polling error:', error);
    }
  };
  
  // Execute immediately
  await poll();
  
  // Then continue polling
  const intervalId = setInterval(poll, interval);
  
  return () => clearInterval(intervalId);
}
```

### Conditional Polling

#### Poll Until Condition Met

```javascript
async function pollUntilCondition(url, conditionFn, options = {}) {
  const {
    interval = 2000,
    maxAttempts = 30,
    onProgress = null
  } = options;
  
  let attempts = 0;
  
  while (attempts < maxAttempts) {
    attempts++;
    
    try {
      const response = await fetch(url);
      const data = await response.json();
      
      if (onProgress) {
        onProgress(data, attempts);
      }
      
      if (conditionFn(data)) {
        return { success: true, data, attempts };
      }
      
      await new Promise(resolve => setTimeout(resolve, interval));
    } catch (error) {
      console.error(`Polling attempt ${attempts} failed:`, error);
      await new Promise(resolve => setTimeout(resolve, interval));
    }
  }
  
  return { success: false, attempts };
}

// Usage
const result = await pollUntilCondition(
  'https://api.example.com/job/123',
  data => data.status === 'completed',
  {
    interval: 3000,
    maxAttempts: 20,
    onProgress: (data, attempt) => {
      console.log(`Attempt ${attempt}: Status is ${data.status}`);
    }
  }
);

if (result.success) {
  console.log('Job completed:', result.data);
} else {
  console.log('Job did not complete within timeout');
}
```

#### Status-Based Polling

```javascript
async function pollJobStatus(jobId, options = {}) {
  const {
    baseUrl = 'https://api.example.com',
    interval = 2000,
    timeout = 60000,
    onStatusChange = null
  } = options;
  
  const startTime = Date.now();
  let lastStatus = null;
  
  while (Date.now() - startTime < timeout) {
    try {
      const response = await fetch(`${baseUrl}/jobs/${jobId}`);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      
      if (data.status !== lastStatus) {
        lastStatus = data.status;
        if (onStatusChange) {
          onStatusChange(data.status, data);
        }
      }
      
      // Terminal states
      if (data.status === 'completed') {
        return { success: true, data, status: 'completed' };
      }
      
      if (data.status === 'failed' || data.status === 'error') {
        return { success: false, data, status: data.status };
      }
      
      // Continue polling for pending/processing states
      await new Promise(resolve => setTimeout(resolve, interval));
    } catch (error) {
      console.error('Polling error:', error);
      await new Promise(resolve => setTimeout(resolve, interval));
    }
  }
  
  return { success: false, status: 'timeout' };
}

// Usage
const result = await pollJobStatus('job-456', {
  interval: 2000,
  timeout: 120000,
  onStatusChange: (status, data) => {
    console.log(`Status changed to: ${status}`);
    if (data.progress) {
      console.log(`Progress: ${data.progress}%`);
    }
  }
});
```

### Exponential Backoff Polling

#### Adaptive Polling Interval

```javascript
class ExponentialBackoffPoller {
  constructor(options = {}) {
    this.initialInterval = options.initialInterval || 1000;
    this.maxInterval = options.maxInterval || 30000;
    this.multiplier = options.multiplier || 2;
    this.currentInterval = this.initialInterval;
    this.isRunning = false;
    this.timeoutId = null;
  }
  
  async start(url, conditionFn, callbacks = {}) {
    this.isRunning = true;
    this.currentInterval = this.initialInterval;
    
    const poll = async () => {
      if (!this.isRunning) return;
      
      try {
        const response = await fetch(url);
        const data = await response.json();
        
        if (callbacks.onData) {
          callbacks.onData(data);
        }
        
        if (conditionFn(data)) {
          this.stop();
          if (callbacks.onComplete) {
            callbacks.onComplete(data);
          }
          return;
        }
        
        // Increase interval for next poll
        this.currentInterval = Math.min(
          this.currentInterval * this.multiplier,
          this.maxInterval
        );
        
        if (callbacks.onProgress) {
          callbacks.onProgress(data, this.currentInterval);
        }
        
      } catch (error) {
        if (callbacks.onError) {
          callbacks.onError(error);
        }
      }
      
      if (this.isRunning) {
        this.timeoutId = setTimeout(poll, this.currentInterval);
      }
    };
    
    await poll();
  }
  
  stop() {
    this.isRunning = false;
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
  
  reset() {
    this.currentInterval = this.initialInterval;
  }
}

// Usage
const poller = new ExponentialBackoffPoller({
  initialInterval: 1000,
  maxInterval: 32000,
  multiplier: 2
});

poller.start(
  'https://api.example.com/task/789',
  data => data.status === 'done',
  {
    onData: data => console.log('Received:', data),
    onProgress: (data, nextInterval) => {
      console.log(`Next poll in ${nextInterval}ms`);
    },
    onComplete: data => console.log('Task completed:', data),
    onError: error => console.error('Error:', error)
  }
);

// Stop polling when needed
poller.stop();
```

### Long Polling

#### Server-Sent Timeout Pattern

```javascript
async function longPoll(url, options = {}) {
  const {
    timeout = 30000,
    onData = null,
    onError = null,
    shouldContinue = () => true
  } = options;
  
  while (shouldContinue()) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);
      
      const response = await fetch(url, {
        signal: controller.signal,
        headers: {
          'X-Long-Poll-Timeout': timeout.toString()
        }
      });
      
      clearTimeout(timeoutId);
      
      if (response.ok) {
        const data = await response.json();
        
        if (onData) {
          const continuePolling = onData(data);
          if (continuePolling === false) {
            break;
          }
        }
      } else if (response.status === 304) {
        // No new data, continue polling
        continue;
      } else if (response.status >= 500) {
        // Server error, wait before retrying
        await new Promise(resolve => setTimeout(resolve, 5000));
      }
      
    } catch (error) {
      if (error.name === 'AbortError') {
        // Timeout occurred, restart poll
        continue;
      }
      
      if (onError) {
        const continuePolling = onError(error);
        if (continuePolling === false) {
          break;
        }
      }
      
      // Wait before retrying on error
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }
}

// Usage
let isActive = true;

longPoll('https://api.example.com/events/long-poll', {
  timeout: 60000,
  onData: data => {
    console.log('Received data:', data);
    return isActive; // Continue polling if active
  },
  onError: error => {
    console.error('Long poll error:', error);
    return isActive;
  },
  shouldContinue: () => isActive
});

// Stop long polling
// isActive = false;
```

#### Long Polling with Last Event ID

```javascript
class LongPollingClient {
  constructor(url, options = {}) {
    this.url = url;
    this.lastEventId = options.lastEventId || null;
    this.timeout = options.timeout || 45000;
    this.retryDelay = options.retryDelay || 3000;
    this.maxRetries = options.maxRetries || 5;
    this.isRunning = false;
    this.retryCount = 0;
  }
  
  async start(callbacks = {}) {
    this.isRunning = true;
    this.retryCount = 0;
    
    while (this.isRunning && this.retryCount < this.maxRetries) {
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), this.timeout);
        
        const url = new URL(this.url);
        if (this.lastEventId) {
          url.searchParams.set('lastEventId', this.lastEventId);
        }
        
        const response = await fetch(url.toString(), {
          signal: controller.signal,
          headers: {
            'Accept': 'application/json'
          }
        });
        
        clearTimeout(timeoutId);
        
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        
        const data = await response.json();
        
        if (data.eventId) {
          this.lastEventId = data.eventId;
        }
        
        if (callbacks.onMessage) {
          callbacks.onMessage(data);
        }
        
        // Reset retry count on success
        this.retryCount = 0;
        
      } catch (error) {
        if (error.name === 'AbortError') {
          // Timeout, restart immediately
          continue;
        }
        
        this.retryCount++;
        
        if (callbacks.onError) {
          callbacks.onError(error, this.retryCount);
        }
        
        if (this.retryCount >= this.maxRetries) {
          if (callbacks.onMaxRetries) {
            callbacks.onMaxRetries();
          }
          break;
        }
        
        // Exponential backoff
        const delay = this.retryDelay * Math.pow(2, this.retryCount - 1);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  stop() {
    this.isRunning = false;
  }
  
  reset() {
    this.lastEventId = null;
    this.retryCount = 0;
  }
}

// Usage
const client = new LongPollingClient('https://api.example.com/stream', {
  timeout: 60000,
  retryDelay: 2000,
  maxRetries: 10
});

client.start({
  onMessage: data => {
    console.log('Event:', data);
    // Process data
  },
  onError: (error, retryCount) => {
    console.error(`Error (retry ${retryCount}):`, error);
  },
  onMaxRetries: () => {
    console.error('Max retries reached, stopping');
  }
});

// Stop when needed
// client.stop();
```

### Smart Polling with Visibility API

#### Pause When Tab Hidden

```javascript
class VisibilityAwarePoller {
  constructor(url, options = {}) {
    this.url = url;
    this.interval = options.interval || 5000;
    this.backgroundInterval = options.backgroundInterval || 60000;
    this.onData = options.onData || (() => {});
    this.isRunning = false;
    this.timeoutId = null;
    this.currentInterval = this.interval;
    
    this.handleVisibilityChange = this.handleVisibilityChange.bind(this);
  }
  
  start() {
    this.isRunning = true;
    this.currentInterval = document.hidden 
      ? this.backgroundInterval 
      : this.interval;
    
    document.addEventListener('visibilitychange', this.handleVisibilityChange);
    
    this.poll();
  }
  
  stop() {
    this.isRunning = false;
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
    document.removeEventListener('visibilitychange', this.handleVisibilityChange);
  }
  
  handleVisibilityChange() {
    if (document.hidden) {
      console.log('Tab hidden, slowing polling');
      this.currentInterval = this.backgroundInterval;
    } else {
      console.log('Tab visible, resuming normal polling');
      this.currentInterval = this.interval;
      
      // Poll immediately when tab becomes visible
      if (this.timeoutId) {
        clearTimeout(this.timeoutId);
      }
      this.poll();
    }
  }
  
  async poll() {
    if (!this.isRunning) return;
    
    try {
      const response = await fetch(this.url);
      const data = await response.json();
      this.onData(data);
    } catch (error) {
      console.error('Polling error:', error);
    }
    
    if (this.isRunning) {
      this.timeoutId = setTimeout(() => this.poll(), this.currentInterval);
    }
  }
}

// Usage
const poller = new VisibilityAwarePoller('https://api.example.com/updates', {
  interval: 5000,           // 5 seconds when visible
  backgroundInterval: 60000, // 1 minute when hidden
  onData: data => {
    console.log('Update:', data);
  }
});

poller.start();
```

#### Pause Polling Completely When Hidden

```javascript
class PausablePoller {
  constructor(url, interval = 5000) {
    this.url = url;
    this.interval = interval;
    this.intervalId = null;
    this.isRunning = false;
    this.isPaused = false;
    
    this.handleVisibilityChange = this.handleVisibilityChange.bind(this);
  }
  
  start() {
    if (this.isRunning) return;
    
    this.isRunning = true;
    this.isPaused = document.hidden;
    
    document.addEventListener('visibilitychange', this.handleVisibilityChange);
    
    if (!this.isPaused) {
      this.startPolling();
    }
  }
  
  stop() {
    this.isRunning = false;
    this.stopPolling();
    document.removeEventListener('visibilitychange', this.handleVisibilityChange);
  }
  
  startPolling() {
    if (this.intervalId) return;
    
    this.poll(); // Immediate first poll
    this.intervalId = setInterval(() => this.poll(), this.interval);
  }
  
  stopPolling() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }
  
  handleVisibilityChange() {
    if (document.hidden) {
      this.isPaused = true;
      this.stopPolling();
      console.log('Polling paused (tab hidden)');
    } else {
      this.isPaused = false;
      if (this.isRunning) {
        this.startPolling();
        console.log('Polling resumed (tab visible)');
      }
    }
  }
  
  async poll() {
    try {
      const response = await fetch(this.url);
      const data = await response.json();
      console.log('Polled data:', data);
    } catch (error) {
      console.error('Polling error:', error);
    }
  }
}
```

### Polling with Change Detection

#### Hash-Based Change Detection

```javascript
class ChangeDetectionPoller {
  constructor(url, options = {}) {
    this.url = url;
    this.interval = options.interval || 10000;
    this.onDataChange = options.onDataChange || (() => {});
    this.onNoChange = options.onNoChange || (() => {});
    this.lastHash = null;
    this.isRunning = false;
    this.intervalId = null;
  }
  
  async computeHash(data) {
    const str = JSON.stringify(data);
    const encoder = new TextEncoder();
    const dataBuffer = encoder.encode(str);
    const hashBuffer = await crypto.subtle.digest('SHA-256', dataBuffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  }
  
  start() {
    if (this.isRunning) return;
    
    this.isRunning = true;
    this.poll(); // Initial poll
    this.intervalId = setInterval(() => this.poll(), this.interval);
  }
  
  stop() {
    this.isRunning = false;
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }
  
  async poll() {
    try {
      const response = await fetch(this.url);
      const data = await response.json();
      
      const currentHash = await this.computeHash(data);
      
      if (this.lastHash === null) {
        // First poll
        this.lastHash = currentHash;
        this.onDataChange(data, null);
      } else if (currentHash !== this.lastHash) {
        // Data changed
        this.lastHash = currentHash;
        this.onDataChange(data, currentHash);
      } else {
        // No change
        this.onNoChange();
      }
      
    } catch (error) {
      console.error('Polling error:', error);
    }
  }
  
  reset() {
    this.lastHash = null;
  }
}

// Usage
const poller = new ChangeDetectionPoller('https://api.example.com/data', {
  interval: 5000,
  onDataChange: (data, hash) => {
    console.log('Data changed:', data);
    console.log('New hash:', hash);
  },
  onNoChange: () => {
    console.log('No changes detected');
  }
});

poller.start();
```

#### ETag-Based Change Detection

```javascript
class ETagPoller {
  constructor(url, options = {}) {
    this.url = url;
    this.interval = options.interval || 10000;
    this.onChange = options.onChange || (() => {});
    this.onNoChange = options.onNoChange || (() => {});
    this.currentETag = null;
    this.isRunning = false;
    this.intervalId = null;
  }
  
  start() {
    if (this.isRunning) return;
    
    this.isRunning = true;
    this.poll();
    this.intervalId = setInterval(() => this.poll(), this.interval);
  }
  
  stop() {
    this.isRunning = false;
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }
  
  async poll() {
    try {
      const headers = {};
      if (this.currentETag) {
        headers['If-None-Match'] = this.currentETag;
      }
      
      const response = await fetch(this.url, { headers });
      
      if (response.status === 304) {
        // Not modified
        this.onNoChange();
        return;
      }
      
      if (response.ok) {
        const newETag = response.headers.get('ETag');
        const data = await response.json();
        
        if (newETag && newETag !== this.currentETag) {
          this.currentETag = newETag;
          this.onChange(data, newETag);
        }
      }
      
    } catch (error) {
      console.error('Polling error:', error);
    }
  }
  
  reset() {
    this.currentETag = null;
  }
}

// Usage
const etagPoller = new ETagPoller('https://api.example.com/resource', {
  interval: 8000,
  onChange: (data, etag) => {
    console.log('Resource changed:', data);
  },
  onNoChange: () => {
    console.log('Resource unchanged (304)');
  }
});

etagPoller.start();
```

### Adaptive Polling

#### Dynamic Interval Adjustment

```javascript
class AdaptivePoller {
  constructor(url, options = {}) {
    this.url = url;
    this.minInterval = options.minInterval || 1000;
    this.maxInterval = options.maxInterval || 60000;
    this.currentInterval = options.initialInterval || 5000;
    this.adjustmentFactor = options.adjustmentFactor || 1.5;
    this.onData = options.onData || (() => {});
    this.isRunning = false;
    this.timeoutId = null;
    this.consecutiveNoChanges = 0;
  }
  
  start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.poll();
  }
  
  stop() {
    this.isRunning = false;
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
  
  async poll() {
    if (!this.isRunning) return;
    
    try {
      const response = await fetch(this.url);
      const data = await response.json();
      
      const hasChanges = this.onData(data);
      
      if (hasChanges) {
        // Data changed - poll more frequently
        this.consecutiveNoChanges = 0;
        this.currentInterval = Math.max(
          this.minInterval,
          this.currentInterval / this.adjustmentFactor
        );
      } else {
        // No changes - slow down polling
        this.consecutiveNoChanges++;
        this.currentInterval = Math.min(
          this.maxInterval,
          this.currentInterval * this.adjustmentFactor
        );
      }
      
      console.log(`Next poll in ${this.currentInterval}ms (${this.consecutiveNoChanges} no-change streaks)`);
      
    } catch (error) {
      console.error('Polling error:', error);
      // On error, increase interval
      this.currentInterval = Math.min(
        this.maxInterval,
        this.currentInterval * this.adjustmentFactor
      );
    }
    
    if (this.isRunning) {
      this.timeoutId = setTimeout(() => this.poll(), this.currentInterval);
    }
  }
  
  reset() {
    this.currentInterval = 5000;
    this.consecutiveNoChanges = 0;
  }
}

// Usage
let lastData = null;

const adaptivePoller = new AdaptivePoller('https://api.example.com/feed', {
  minInterval: 2000,
  maxInterval: 30000,
  initialInterval: 5000,
  adjustmentFactor: 1.5,
  onData: data => {
    const hasChanges = JSON.stringify(data) !== JSON.stringify(lastData);
    lastData = data;
    
    if (hasChanges) {
      console.log('New data detected:', data);
    }
    
    return hasChanges;
  }
});

adaptivePoller.start();
```

### Polling Queue Manager

#### Multiple Concurrent Polls

```javascript
class PollingQueueManager {
  constructor(options = {}) {
    this.maxConcurrent = options.maxConcurrent || 5;
    this.pollers = new Map();
    this.queue = [];
    this.activeCount = 0;
  }
  
  addPoller(id, url, interval, callback) {
    if (this.pollers.has(id)) {
      console.warn(`Poller ${id} already exists`);
      return;
    }
    
    const poller = {
      id,
      url,
      interval,
      callback,
      isActive: false,
      intervalId: null,
      priority: 0
    };
    
    this.pollers.set(id, poller);
    this.queue.push(poller);
    this.processQueue();
  }
  
  removePoller(id) {
    const poller = this.pollers.get(id);
    if (!poller) return;
    
    this.stopPoller(poller);
    this.pollers.delete(id);
    this.queue = this.queue.filter(p => p.id !== id);
    this.processQueue();
  }
  
  setPriority(id, priority) {
    const poller = this.pollers.get(id);
    if (poller) {
      poller.priority = priority;
      this.queue.sort((a, b) => b.priority - a.priority);
      this.processQueue();
    }
  }
  
  processQueue() {
    while (this.activeCount < this.maxConcurrent && this.queue.length > 0) {
      const poller = this.queue.find(p => !p.isActive);
      if (!poller) break;
      
      this.startPoller(poller);
    }
  }
  
  startPoller(poller) {
    if (poller.isActive) return;
    
    poller.isActive = true;
    this.activeCount++;
    
    const poll = async () => {
      try {
        const response = await fetch(poller.url);
        const data = await response.json();
        poller.callback(data);
      } catch (error) {
        console.error(`Polling error for ${poller.id}:`, error);
      }
    };
    
    poll(); // Immediate execution
    poller.intervalId = setInterval(poll, poller.interval);
  }
  
  stopPoller(poller) {
    if (!poller.isActive) return;
    
    if (poller.intervalId) {
      clearInterval(poller.intervalId);
      poller.intervalId = null;
    }
    
    poller.isActive = false;
    this.activeCount--;
  }
  
  pauseAll() {
    this.pollers.forEach(poller => this.stopPoller(poller));
  }
  
  resumeAll() {
    this.processQueue();
  }
  
  stopAll() {
    this.pollers.forEach(poller => this.stopPoller(poller));
    this.pollers.clear();
    this.queue = [];
  }
  
  getStatus() {
    return {
      total: this.pollers.size,
      active: this.activeCount,
      queued: this.queue.filter(p => !p.isActive).length,
      pollers: Array.from(this.pollers.values()).map(p => ({
        id: p.id,
        url: p.url,
        isActive: p.isActive,
        priority: p.priority
      }))
    };
  }
}

// Usage
const manager = new PollingQueueManager({ maxConcurrent: 3 });

manager.addPoller('user-status', 'https://api.example.com/user/status', 5000, 
  data => console.log('User status:', data));

manager.addPoller('notifications', 'https://api.example.com/notifications', 10000,
  data => console.log('Notifications:', data));

manager.addPoller('messages', 'https://api.example.com/messages', 3000,
  data => console.log('Messages:', data));

// Set priorities
manager.setPriority('messages', 10); // Highest priority

// Check status
console.log(manager.getStatus());

// Pause all polling
// manager.pauseAll();

// Resume
// manager.resumeAll();
```

### Jittered Polling

#### Preventing Thundering Herd

```javascript
class JitteredPoller {
  constructor(url, options = {}) {
    this.url = url;
    this.baseInterval = options.interval || 5000;
    this.jitterPercent = options.jitterPercent || 0.1; // 10% jitter
    this.onData = options.onData || (() => {});
    this.isRunning = false;
    this.timeoutId = null;
  }
  
  calculateInterval() {
    const jitter = this.baseInterval * this.jitterPercent;
    const min = this.baseInterval - jitter;
    const max = this.baseInterval + jitter;
    return Math.random() * (max - min) + min;
  }
  
  start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.poll();
  }
  
  stop() {
    this.isRunning = false;
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
  
  async poll() {
    if (!this.isRunning) return;
    
    try {
      const response = await fetch(this.url);
      const data = await response.json();
      this.onData(data);
    } catch (error) {
      console.error('Polling error:', error);
    }
    
    if (this.isRunning) {
      const nextInterval = this.calculateInterval();
      console.log(`Next poll in ${nextInterval.toFixed(0)}ms`);
      this.timeoutId = setTimeout(() => this.poll(), nextInterval);
    }
  }
}

// Usage - prevents multiple clients from polling simultaneously
const jitteredPoller = new JitteredPoller('https://api.example.com/data', {
  interval: 10000,
  jitterPercent: 0.2, // ±20% jitter (8-12 seconds)
  onData: data => console.log('Data:', data)
});

jitteredPoller.start();
```

#### Full Jitter Exponential Backoff

```javascript
class FullJitterBackoffPoller {
  constructor(url, options = {}) {
    this.url = url;
    this.baseDelay = options.baseDelay || 1000;
    this.maxDelay = options.maxDelay || 60000;
    this.attempt = 0;
    this.onData = options.onData || (() => {});
    this.onError = options.onError || (() => {});
    this.isRunning = false;
    this.timeoutId = null;
  }

  calculateDelay() {
    const exponentialDelay = Math.min(
      this.maxDelay,
      this.baseDelay * Math.pow(2, this.attempt)
    );

    // Full jitter: random value between 0 and exponentialDelay
    return Math.random() * exponentialDelay;
  }

  start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.attempt = 0;
    this.poll();
  }

  stop() {
    this.isRunning = false;
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }

  async poll() {
    if (!this.isRunning) return;

    try {
      const response = await fetch(this.url);

      if (response.ok) {
        const data = await response.json();
        this.onData(data);
        this.attempt = 0; // Reset on success
      } else {
        throw new Error(`HTTP ${response.status}`);
      }

    } catch (error) {
      this.onError(error, this.attempt);
      this.attempt++;
    }

    if (this.isRunning) {
      const delay = this.calculateDelay();
      console.log(
        `Next poll in ${delay.toFixed(0)}ms (attempt ${this.attempt})`
      );
      this.timeoutId = setTimeout(() => this.poll(), delay);
    }
  }

  reset() {
    this.attempt = 0;
  }
}

````

### Cancellable Polling with AbortController

#### Graceful Cancellation

```javascript
class CancellablePoller {
  constructor(url, options = {}) {
    this.url = url;
    this.interval = options.interval || 5000;
    this.timeout = options.timeout || 10000;
    this.onData = options.onData || (() => {});
    this.onCancel = options.onCancel || (() => {});
    this.isRunning = false;
    this.timeoutId = null;
    this.currentController = null;
  }
  
  start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.poll();
  }
  
  stop() {
    this.isRunning = false;
    
    if (this.currentController) {
      this.currentController.abort();
      this.currentController = null;
    }
    
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
  
  async poll() {
    if (!this.isRunning) return;
    
    this.currentController = new AbortController();
    const signal = this.currentController.signal;
    
    try {
      const timeoutId = setTimeout(() => {
        this.currentController.abort();
      }, this.timeout);
      
      const response = await fetch(this.url, { signal });
      clearTimeout(timeoutId);
      
      if (response.ok) {
        const data = await response.json();
        this.onData(data);
      }
      
      this.currentController = null;
      
    } catch (error) {
      if (error.name === 'AbortError') {
        console.log('Request cancelled');
        this.onCancel();
      } else {
        console.error('Polling error:', error);
      }
      
      this.currentController = null;
    }
    
    if (this.isRunning) {
      this.timeoutId = setTimeout(() => this.poll(), this.interval);
    }
  }
}

// Usage
const cancellablePoller = new CancellablePoller('https://api.example.com/data', {
  interval: 5000,
  timeout: 8000,
  onData: data => console.log('Data:', data),
  onCancel: () => console.log('Poll cancelled')
});

cancellablePoller.start();

// Stop immediately, cancelling any in-flight request
// cancellablePoller.stop();
````

### Polling with Network Quality Adaptation

#### Adjust Based on Connection Speed

```javascript
class NetworkAwarePoller {
  constructor(url, options = {}) {
    this.url = url;
    this.baseInterval = options.baseInterval || 5000;
    this.onData = options.onData || (() => {});
    this.isRunning = false;
    this.timeoutId = null;
    
    this.connectionInfo = this.getConnectionInfo();
    this.updateConnectionListener();
  }
  
  getConnectionInfo() {
    const connection = navigator.connection || 
                      navigator.mozConnection || 
                      navigator.webkitConnection;
    
    return {
      effectiveType: connection?.effectiveType || '4g',
      downlink: connection?.downlink || 10,
      rtt: connection?.rtt || 50,
      saveData: connection?.saveData || false
    };
  }
  
  updateConnectionListener() {
    const connection = navigator.connection || 
                      navigator.mozConnection || 
                      navigator.webkitConnection;
    
    if (connection) {
      connection.addEventListener('change', () => {
        this.connectionInfo = this.getConnectionInfo();
        console.log('Connection changed:', this.connectionInfo);
      });
    }
  }
  
  calculateInterval() {
    const { effectiveType, saveData } = this.connectionInfo;
    
    if (saveData) {
      return this.baseInterval * 4; // Much slower when data saver is on
    }
    
    switch (effectiveType) {
      case 'slow-2g':
        return this.baseInterval * 8;
      case '2g':
        return this.baseInterval * 4;
      case '3g':
        return this.baseInterval * 2;
      case '4g':
      default:
        return this.baseInterval;
    }
  }
  
  start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.poll();
  }
  
  stop() {
    this.isRunning = false;
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
  
  async poll() {
    if (!this.isRunning) return;
    
    try {
      const response = await fetch(this.url);
      const data = await response.json();
      this.onData(data);
    } catch (error) {
      console.error('Polling error:', error);
    }
    
    if (this.isRunning) {
      const interval = this.calculateInterval();
      console.log(`Next poll in ${interval}ms (${this.connectionInfo.effectiveType})`);
      this.timeoutId = setTimeout(() => this.poll(), interval);
    }
  }
}

// Usage
const networkPoller = new NetworkAwarePoller('https://api.example.com/data', {
  baseInterval: 5000,
  onData: data => console.log('Data:', data)
});

networkPoller.start();
```

### Coordinated Multi-Resource Polling

#### Poll Multiple Endpoints in Sequence

```javascript
class CoordinatedPoller {
  constructor(endpoints, options = {}) {
    this.endpoints = endpoints; // Array of {url, key}
    this.interval = options.interval || 10000;
    this.onComplete = options.onComplete || (() => {});
    this.onError = options.onError || (() => {});
    this.isRunning = false;
    this.timeoutId = null;
  }
  
  start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.poll();
  }
  
  stop() {
    this.isRunning = false;
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
  
  async poll() {
    if (!this.isRunning) return;
    
    const results = {};
    const errors = {};
    
    for (const endpoint of this.endpoints) {
      try {
        const response = await fetch(endpoint.url);
        if (response.ok) {
          results[endpoint.key] = await response.json();
        } else {
          errors[endpoint.key] = `HTTP ${response.status}`;
        }
      } catch (error) {
        errors[endpoint.key] = error.message;
      }
    }
    
    if (Object.keys(errors).length > 0) {
      this.onError(errors, results);
    }
    
    this.onComplete(results, errors);
    
    if (this.isRunning) {
      this.timeoutId = setTimeout(() => this.poll(), this.interval);
    }
  }
}

// Usage
const coordinated = new CoordinatedPoller([
  { url: 'https://api.example.com/user', key: 'user' },
  { url: 'https://api.example.com/notifications', key: 'notifications' },
  { url: 'https://api.example.com/settings', key: 'settings' }
], {
  interval: 15000,
  onComplete: (results, errors) => {
    console.log('Poll complete:', results);
    if (Object.keys(errors).length > 0) {
      console.error('Some requests failed:', errors);
    }
  }
});

coordinated.start();
```

---

