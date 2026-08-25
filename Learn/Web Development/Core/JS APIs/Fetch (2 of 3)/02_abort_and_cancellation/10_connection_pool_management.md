## Connection Pool Management


### Request Queue Pattern

```javascript
class FetchQueue {
  constructor(concurrency = 6) {
    this.concurrency = concurrency;
    this.running = 0;
    this.queue = [];
  }
  
  async add(url, options = {}) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.running >= this.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.running++;
    const { url, options, resolve, reject } = this.queue.shift();
    
    try {
      const response = await fetch(url, options);
      resolve(response);
    } catch (err) {
      reject(err);
    } finally {
      this.running--;
      this.process();
    }
  }
  
  clear() {
    this.queue.forEach(({ reject }) => {
      reject(new Error('Queue cleared'));
    });
    this.queue = [];
  }
}
```

### Connection Reuse with Keep-Alive

```javascript
// Keep-alive is enabled by default in fetch, but can be explicit
const keepAliveAgent = {
  keepalive: true
};

// In Node.js with custom agent
const https = require('https');
const agent = new https.Agent({
  keepAlive: true,
  maxSockets: 10,
  maxFreeSockets: 5,
  timeout: 60000
});

// Cleanup when done
agent.destroy();
```

