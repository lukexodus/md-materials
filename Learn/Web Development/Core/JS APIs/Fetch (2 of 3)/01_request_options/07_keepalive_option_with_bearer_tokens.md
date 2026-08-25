## Keepalive Option with Bearer Tokens


### Basic Syntax

```javascript
fetch('https://api.example.com/data', {
  method: 'POST',
  keepalive: true,
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({ data: 'value' })
});
```

### Purpose and Behavior

The `keepalive` option allows fetch requests to continue even after the page that initiated them has been unloaded or navigated away. This is particularly useful for analytics, logging, and cleanup operations.

```javascript
// Request continues even if user closes tab/navigates away
window.addEventListener('beforeunload', () => {
  fetch('https://api.example.com/logout', {
    method: 'POST',
    keepalive: true,
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
});
```

### Size Limitations

Keepalive requests have a maximum body size of 64 KiB (65,536 bytes) per request. This limit applies to the entire request body.

```javascript
const data = JSON.stringify({ userId: 123, action: 'click' });
const bodySize = new Blob([data]).size;

if (bodySize <= 65536) {
  fetch('https://api.example.com/analytics', {
    method: 'POST',
    keepalive: true,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: data
  });
} else {
  // Handle oversized payload
  console.error('Payload exceeds keepalive limit');
}
```

### Use Cases with Authentication

#### Session Termination

```javascript
function logoutUser(token) {
  fetch('https://api.example.com/auth/logout', {
    method: 'POST',
    keepalive: true,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ timestamp: Date.now() })
  });
  
  // Clear local token
  sessionStorage.removeItem('authToken');
}

window.addEventListener('beforeunload', () => {
  const token = sessionStorage.getItem('authToken');
  if (token) {
    logoutUser(token);
  }
});
```

#### Analytics Events

```javascript
function trackEvent(eventName, eventData, token) {
  const payload = {
    event: eventName,
    data: eventData,
    timestamp: Date.now()
  };

  fetch('https://api.example.com/analytics', {
    method: 'POST',
    keepalive: true,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });
}

// Track page exit
window.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'hidden') {
    const token = sessionStorage.getItem('authToken');
    trackEvent('page_exit', { duration: getSessionDuration() }, token);
  }
});
```

#### Error Reporting

```javascript
function reportError(error, token) {
  const errorReport = {
    message: error.message,
    stack: error.stack,
    url: window.location.href,
    userAgent: navigator.userAgent,
    timestamp: Date.now()
  };

  fetch('https://api.example.com/errors', {
    method: 'POST',
    keepalive: true,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(errorReport)
  });
}

window.addEventListener('error', (event) => {
  const token = sessionStorage.getItem('authToken');
  if (token) {
    reportError(event.error, token);
  }
});
```

### Combination with Page Lifecycle Events

#### beforeunload Event

```javascript
window.addEventListener('beforeunload', (event) => {
  const token = sessionStorage.getItem('authToken');
  
  fetch('https://api.example.com/session/end', {
    method: 'POST',
    keepalive: true,
    headers: {
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      sessionId: getSessionId(),
      duration: getSessionDuration()
    })
  });
  
  // Note: Cannot reliably wait for response here
});
```

#### pagehide Event

```javascript
// More reliable than beforeunload for mobile
window.addEventListener('pagehide', (event) => {
  const token = sessionStorage.getItem('authToken');
  
  if (event.persisted) {
    // Page is being cached (bfcache)
    console.log('Page entering bfcache');
  }
  
  fetch('https://api.example.com/tracking/pagehide', {
    method: 'POST',
    keepalive: true,
    headers: {
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ timestamp: Date.now() })
  });
});
```

#### visibilitychange Event

```javascript
document.addEventListener('visibilitychange', () => {
  const token = sessionStorage.getItem('authToken');
  
  if (document.visibilityState === 'hidden') {
    // Page is being hidden
    fetch('https://api.example.com/tracking/visibility', {
      method: 'POST',
      keepalive: true,
      headers: {
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        state: 'hidden',
        timestamp: Date.now()
      })
    });
  }
});
```

### Browser Support and Fallbacks

```javascript
function sendWithKeepalive(url, token, data) {
  if ('keepalive' in Request.prototype) {
    // Browser supports keepalive
    return fetch(url, {
      method: 'POST',
      keepalive: true,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });
  } else {
    // Fallback to navigator.sendBeacon
    const blob = new Blob(
      [JSON.stringify(data)],
      { type: 'application/json' }
    );
    
    // Note: sendBeacon doesn't support custom headers
    // [Inference] Token must be sent via URL or alternative method
    const urlWithToken = `${url}?token=${encodeURIComponent(token)}`;
    navigator.sendBeacon(urlWithToken, blob);
  }
}
```

### Keepalive vs sendBeacon Comparison

```javascript
// fetch with keepalive - supports custom headers
fetch('https://api.example.com/analytics', {
  method: 'POST',
  keepalive: true,
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});

// sendBeacon - no custom headers, but simpler
// Cannot send Authorization header directly
const blob = new Blob([JSON.stringify(data)], { type: 'application/json' });
navigator.sendBeacon('https://api.example.com/analytics', blob);
```

### Limitations and Constraints

#### No Response Handling

```javascript
// Cannot reliably access response with keepalive during unload
window.addEventListener('beforeunload', () => {
  const token = sessionStorage.getItem('authToken');
  
  fetch('https://api.example.com/data', {
    method: 'POST',
    keepalive: true,
    headers: { 'Authorization': `Bearer ${token}` },
    body: JSON.stringify({ data: 'value' })
  })
  .then(response => response.json())
  .then(data => {
    // [Unverified] This may not execute if page unloads
    console.log(data);
  });
});
```

#### Request Queuing

```javascript
// Multiple keepalive requests queue and execute
window.addEventListener('beforeunload', () => {
  const token = sessionStorage.getItem('authToken');
  
  // All these requests will be queued
  fetch('https://api.example.com/event1', {
    method: 'POST',
    keepalive: true,
    headers: { 'Authorization': `Bearer ${token}` },
    body: JSON.stringify({ event: 1 })
  });
  
  fetch('https://api.example.com/event2', {
    method: 'POST',
    keepalive: true,
    headers: { 'Authorization': `Bearer ${token}` },
    body: JSON.stringify({ event: 2 })
  });
  
  fetch('https://api.example.com/event3', {
    method: 'POST',
    keepalive: true,
    headers: { 'Authorization': `Bearer ${token}` },
    body: JSON.stringify({ event: 3 })
  });
});
```

#### Payload Size Validation

```javascript
function sendKeepaliveWithValidation(url, token, data) {
  const body = JSON.stringify(data);
  const size = new TextEncoder().encode(body).length;
  
  const MAX_KEEPALIVE_SIZE = 65536; // 64 KiB
  
  if (size > MAX_KEEPALIVE_SIZE) {
    // Split or truncate data
    console.error(`Payload size ${size} exceeds keepalive limit`);
    
    // Option 1: Truncate
    const truncated = JSON.stringify({
      ...data,
      _truncated: true
    });
    
    // Option 2: Send without keepalive
    // Option 3: Send to queue for later
    
    return false;
  }
  
  fetch(url, {
    method: 'POST',
    keepalive: true,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: body
  });
  
  return true;
}
```

### Security Considerations

#### Token Exposure During Unload

```javascript
// Token remains in memory during keepalive request
// [Inference] Ensure tokens are not logged or exposed elsewhere

window.addEventListener('beforeunload', () => {
  const token = sessionStorage.getItem('authToken');
  
  // DO: Use keepalive for logout
  fetch('https://api.example.com/logout', {
    method: 'POST',
    keepalive: true,
    headers: { 'Authorization': `Bearer ${token}` }
  });
  
  // DON'T: Log sensitive data
  // console.log('Logging out with token:', token); // SECURITY RISK
});
```

#### HTTPS Requirement

```javascript
// Keepalive requests should only be sent over HTTPS
function sendSecureKeepalive(url, token, data) {
  if (!url.startsWith('https://')) {
    console.error('Keepalive requests must use HTTPS');
    return;
  }
  
  fetch(url, {
    method: 'POST',
    keepalive: true,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  });
}
```

### Practical Implementation Pattern

```javascript
class KeepaliveTracker {
  constructor(endpoint, tokenProvider) {
    this.endpoint = endpoint;
    this.tokenProvider = tokenProvider;
    this.queue = [];
    this.maxPayloadSize = 65536;
    
    this.setupListeners();
  }
  
  setupListeners() {
    window.addEventListener('beforeunload', () => this.flush());
    window.addEventListener('pagehide', () => this.flush());
    
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'hidden') {
        this.flush();
      }
    });
  }
  
  track(eventName, eventData) {
    this.queue.push({
      event: eventName,
      data: eventData,
      timestamp: Date.now()
    });
    
    // Auto-flush if queue gets large
    if (this.queue.length >= 10) {
      this.flush();
    }
  }
  
  flush() {
    if (this.queue.length === 0) return;
    
    const token = this.tokenProvider();
    if (!token) return;
    
    const payload = JSON.stringify({ events: this.queue });
    const size = new TextEncoder().encode(payload).length;
    
    if (size <= this.maxPayloadSize) {
      fetch(this.endpoint, {
        method: 'POST',
        keepalive: true,
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: payload
      });
      
      this.queue = [];
    } else {
      // Send in batches
      const midpoint = Math.floor(this.queue.length / 2);
      const batch1 = this.queue.slice(0, midpoint);
      const batch2 = this.queue.slice(midpoint);
      
      this.sendBatch(batch1, token);
      this.sendBatch(batch2, token);
      
      this.queue = [];
    }
  }
  
  sendBatch(events, token) {
    const payload = JSON.stringify({ events });
    
    fetch(this.endpoint, {
      method: 'POST',
      keepalive: true,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: payload
    });
  }
}

// Usage
const tracker = new KeepaliveTracker(
  'https://api.example.com/analytics',
  () => sessionStorage.getItem('authToken')
);

tracker.track('page_view', { url: window.location.href });
tracker.track('button_click', { buttonId: 'submit' });
```

---

