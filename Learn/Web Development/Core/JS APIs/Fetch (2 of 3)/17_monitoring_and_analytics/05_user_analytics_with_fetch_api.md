## User Analytics with Fetch API


### Tracking User Events

Event tracking forms the foundation of user analytics implementation. The fetch API enables asynchronous transmission of user interaction data to analytics endpoints without blocking the user interface.

```javascript
async function trackEvent(eventName, eventData) {
  try {
    await fetch('https://analytics.example.com/events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        event: eventName,
        timestamp: Date.now(),
        ...eventData
      })
    });
  } catch (error) {
    console.error('Analytics tracking failed:', error);
  }
}

// Usage
trackEvent('button_click', {
  buttonId: 'checkout',
  pageUrl: window.location.href,
  userId: getCurrentUserId()
});
```

### Session Tracking

Session management requires consistent identification across multiple requests. Implementing session tracking involves generating unique session identifiers and persisting them throughout the user's visit.

```javascript
function getSessionId() {
  let sessionId = sessionStorage.getItem('analytics_session_id');
  
  if (!sessionId) {
    sessionId = `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    sessionStorage.setItem('analytics_session_id', sessionId);
  }
  
  return sessionId;
}

async function trackPageView() {
  await fetch('https://analytics.example.com/pageviews', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      sessionId: getSessionId(),
      url: window.location.href,
      referrer: document.referrer,
      timestamp: Date.now()
    })
  });
}
```

### Batching Analytics Requests

Batching reduces server load and network overhead by accumulating multiple events before transmission. This approach optimizes performance while maintaining data accuracy.

```javascript
class AnalyticsBatcher {
  constructor(endpoint, maxBatchSize = 10, flushInterval = 5000) {
    this.endpoint = endpoint;
    this.maxBatchSize = maxBatchSize;
    this.flushInterval = flushInterval;
    this.queue = [];
    this.timer = null;
    
    this.startTimer();
  }
  
  track(event) {
    this.queue.push({
      ...event,
      timestamp: Date.now()
    });
    
    if (this.queue.length >= this.maxBatchSize) {
      this.flush();
    }
  }
  
  async flush() {
    if (this.queue.length === 0) return;
    
    const batch = [...this.queue];
    this.queue = [];
    
    try {
      await fetch(this.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ events: batch })
      });
    } catch (error) {
      console.error('Failed to send analytics batch:', error);
      // [Inference] Re-queuing might cause duplicate events in some implementations
      this.queue.unshift(...batch);
    }
    
    this.startTimer();
  }
  
  startTimer() {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => this.flush(), this.flushInterval);
  }
}

const analytics = new AnalyticsBatcher('https://analytics.example.com/batch');
analytics.track({ event: 'page_view', page: '/home' });
analytics.track({ event: 'click', element: 'nav_menu' });
```

### Beacon API for Reliable Tracking

The Beacon API provides guaranteed delivery of analytics data during page unload events, addressing the limitation where standard fetch requests may be cancelled when users navigate away.

```javascript
function trackPageExit() {
  const data = JSON.stringify({
    event: 'page_exit',
    sessionId: getSessionId(),
    timeOnPage: performance.now(),
    url: window.location.href
  });
  
  // Beacon API ensures delivery even during page unload
  navigator.sendBeacon('https://analytics.example.com/events', data);
}

window.addEventListener('beforeunload', trackPageExit);
window.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'hidden') {
    trackPageExit();
  }
});
```

### User Identification and Attribution

Persistent user identification across sessions requires careful management of identifiers while respecting privacy considerations.

```javascript
function getUserId() {
  let userId = localStorage.getItem('analytics_user_id');
  
  if (!userId) {
    userId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    localStorage.setItem('analytics_user_id', userId);
  }
  
  return userId;
}

async function identifyUser(userAttributes) {
  await fetch('https://analytics.example.com/identify', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      userId: getUserId(),
      sessionId: getSessionId(),
      attributes: userAttributes,
      timestamp: Date.now()
    })
  });
}

// Associate user with attributes
identifyUser({
  plan: 'premium',
  signupDate: '2024-01-15',
  country: 'US'
});
```

### Custom Event Properties

Rich event metadata enables detailed behavioral analysis and segmentation capabilities.

```javascript
async function trackWithProperties(eventName, properties) {
  const enrichedData = {
    event: eventName,
    properties: {
      ...properties,
      // Automatically captured context
      screenWidth: window.innerWidth,
      screenHeight: window.innerHeight,
      userAgent: navigator.userAgent,
      language: navigator.language,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
    },
    userId: getUserId(),
    sessionId: getSessionId(),
    timestamp: Date.now()
  };
  
  await fetch('https://analytics.example.com/events', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(enrichedData)
  });
}

// Track purchase with detailed properties
trackWithProperties('purchase_completed', {
  productId: 'prod_123',
  productName: 'Premium Subscription',
  price: 29.99,
  currency: 'USD',
  paymentMethod: 'credit_card'
});
```

### Error and Performance Tracking

Monitoring application health through error tracking and performance metrics provides operational insights alongside user behavior data.

```javascript
// Error tracking
window.addEventListener('error', (event) => {
  fetch('https://analytics.example.com/errors', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      type: 'javascript_error',
      message: event.message,
      filename: event.filename,
      lineno: event.lineno,
      colno: event.colno,
      stack: event.error?.stack,
      userId: getUserId(),
      sessionId: getSessionId(),
      url: window.location.href,
      timestamp: Date.now()
    })
  }).catch(err => console.error('Failed to report error:', err));
});

// Performance tracking
window.addEventListener('load', () => {
  const perfData = performance.getEntriesByType('navigation')[0];
  
  fetch('https://analytics.example.com/performance', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      domContentLoaded: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
      loadComplete: perfData.loadEventEnd - perfData.loadEventStart,
      dnsLookup: perfData.domainLookupEnd - perfData.domainLookupStart,
      tcpConnection: perfData.connectEnd - perfData.connectStart,
      serverResponse: perfData.responseEnd - perfData.requestStart,
      domProcessing: perfData.domComplete - perfData.domLoading,
      userId: getUserId(),
      sessionId: getSessionId(),
      url: window.location.href,
      timestamp: Date.now()
    })
  }).catch(err => console.error('Failed to report performance:', err));
});
```

### Retry Logic and Failure Handling

Network failures require robust retry mechanisms to maintain data integrity while avoiding excessive retransmission attempts.

```javascript
async function fetchWithRetry(url, options, maxRetries = 3) {
  let lastError;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      // Don't retry client errors (4xx)
      if (response.status >= 400 && response.status < 500) {
        throw new Error(`Client error: ${response.status}`);
      }
      
      lastError = new Error(`Server error: ${response.status}`);
    } catch (error) {
      lastError = error;
      
      if (attempt < maxRetries) {
        // Exponential backoff
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw lastError;
}

async function trackEventWithRetry(eventName, eventData) {
  try {
    await fetchWithRetry('https://analytics.example.com/events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        event: eventName,
        ...eventData
      })
    });
  } catch (error) {
    console.error('Analytics tracking failed after retries:', error);
    // Store in IndexedDB for later retry
    storeFailedEvent(eventName, eventData);
  }
}
```

### Offline Analytics Buffering

Supporting offline-first applications requires local persistence of analytics events with background synchronization when connectivity resumes.

```javascript
class OfflineAnalytics {
  constructor(endpoint) {
    this.endpoint = endpoint;
    this.dbName = 'analytics_offline';
    this.storeName = 'pending_events';
    this.db = null;
    
    this.initDB();
    this.setupSyncListener();
  }
  
  async initDB() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, 1);
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };
      
      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        if (!db.objectStoreNames.contains(this.storeName)) {
          db.createObjectStore(this.storeName, { keyPath: 'id', autoIncrement: true });
        }
      };
    });
  }
  
  async track(eventData) {
    const event = {
      ...eventData,
      timestamp: Date.now()
    };
    
    if (navigator.onLine) {
      try {
        await this.sendEvent(event);
      } catch (error) {
        await this.storeEvent(event);
      }
    } else {
      await this.storeEvent(event);
    }
  }
  
  async sendEvent(event) {
    const response = await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(event)
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
  }
  
  async storeEvent(event) {
    const transaction = this.db.transaction([this.storeName], 'readwrite');
    const store = transaction.objectStore(this.storeName);
    await store.add(event);
  }
  
  async syncPendingEvents() {
    if (!navigator.onLine) return;
    
    const transaction = this.db.transaction([this.storeName], 'readonly');
    const store = transaction.objectStore(this.storeName);
    const events = await store.getAll();
    
    for (const event of events) {
      try {
        await this.sendEvent(event);
        await this.deleteEvent(event.id);
      } catch (error) {
        console.error('Failed to sync event:', error);
        break; // Stop syncing on first failure
      }
    }
  }
  
  async deleteEvent(id) {
    const transaction = this.db.transaction([this.storeName], 'readwrite');
    const store = transaction.objectStore(this.storeName);
    await store.delete(id);
  }
  
  setupSyncListener() {
    window.addEventListener('online', () => {
      this.syncPendingEvents();
    });
  }
}

const offlineAnalytics = new OfflineAnalytics('https://analytics.example.com/events');
offlineAnalytics.track({
  event: 'page_view',
  page: '/dashboard'
});
```

### Rate Limiting Client-Side Tracking

Implementing client-side rate limits prevents excessive analytics traffic from individual users while maintaining data quality.

```javascript
class RateLimitedAnalytics {
  constructor(endpoint, maxEventsPerMinute = 60) {
    this.endpoint = endpoint;
    this.maxEventsPerMinute = maxEventsPerMinute;
    this.eventTimestamps = [];
  }
  
  async track(eventData) {
    const now = Date.now();
    const oneMinuteAgo = now - 60000;
    
    // Remove timestamps older than one minute
    this.eventTimestamps = this.eventTimestamps.filter(ts => ts > oneMinuteAgo);
    
    if (this.eventTimestamps.length >= this.maxEventsPerMinute) {
      console.warn('Rate limit exceeded, event not tracked:', eventData);
      return;
    }
    
    this.eventTimestamps.push(now);
    
    try {
      await fetch(this.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...eventData,
          timestamp: now
        })
      });
    } catch (error) {
      console.error('Failed to track event:', error);
    }
  }
}

const rateLimitedAnalytics = new RateLimitedAnalytics('https://analytics.example.com/events', 60);
```

### Privacy-Compliant Tracking

Respecting user privacy preferences requires implementing consent management and data minimization strategies.

```javascript
class PrivacyCompliantAnalytics {
  constructor(endpoint) {
    this.endpoint = endpoint;
    this.consentGiven = this.checkConsent();
  }
  
  checkConsent() {
    return localStorage.getItem('analytics_consent') === 'granted';
  }
  
  grantConsent() {
    localStorage.setItem('analytics_consent', 'granted');
    this.consentGiven = true;
  }
  
  revokeConsent() {
    localStorage.setItem('analytics_consent', 'revoked');
    this.consentGiven = false;
    // Clear existing identifiers
    localStorage.removeItem('analytics_user_id');
    sessionStorage.removeItem('analytics_session_id');
  }
  
  async track(eventData) {
    if (!this.consentGiven) {
      console.log('Analytics tracking skipped - no consent');
      return;
    }
    
    // Anonymize IP on server-side, but signal preference
    const privacySettings = {
      anonymizeIp: true,
      doNotTrack: navigator.doNotTrack === '1'
    };
    
    await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        ...eventData,
        privacySettings,
        timestamp: Date.now()
      })
    });
  }
}

const privacyAnalytics = new PrivacyCompliantAnalytics('https://analytics.example.com/events');

// Consent management UI
function handleConsentResponse(granted) {
  if (granted) {
    privacyAnalytics.grantConsent();
  } else {
    privacyAnalytics.revokeConsent();
  }
}
```

### A/B Testing Integration

Analytics systems frequently integrate with experimentation platforms to correlate user behavior with test variants.

```javascript
async function trackExperimentView(experimentId, variantId) {
  await fetch('https://analytics.example.com/experiments', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      event: 'experiment_view',
      experimentId,
      variantId,
      userId: getUserId(),
      sessionId: getSessionId(),
      timestamp: Date.now()
    })
  });
}

async function trackConversion(experimentId, variantId, conversionData) {
  await fetch('https://analytics.example.com/conversions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      event: 'conversion',
      experimentId,
      variantId,
      ...conversionData,
      userId: getUserId(),
      sessionId: getSessionId(),
      timestamp: Date.now()
    })
  });
}

// Usage
const variant = assignUserToVariant('homepage_redesign_2024');
trackExperimentView('homepage_redesign_2024', variant);

// Later, when conversion happens
trackConversion('homepage_redesign_2024', variant, {
  conversionType: 'signup',
  value: 29.99
});
```

### Real-Time Analytics Streaming

Server-Sent Events or WebSockets enable real-time analytics dashboards by streaming events as they occur.

```javascript
class RealtimeAnalytics {
  constructor(endpoint, streamEndpoint) {
    this.endpoint = endpoint;
    this.streamEndpoint = streamEndpoint;
    this.eventSource = null;
  }
  
  async track(eventData) {
    await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        ...eventData,
        timestamp: Date.now()
      })
    });
  }
  
  subscribeToRealtimeEvents(callback) {
    this.eventSource = new EventSource(this.streamEndpoint);
    
    this.eventSource.onmessage = (event) => {
      const data = JSON.parse(event.data);
      callback(data);
    };
    
    this.eventSource.onerror = (error) => {
      console.error('EventSource error:', error);
      this.eventSource.close();
    };
  }
  
  unsubscribe() {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
    }
  }
}

const realtimeAnalytics = new RealtimeAnalytics(
  'https://analytics.example.com/events',
  'https://analytics.example.com/stream'
);

// Subscribe to real-time updates for dashboard
realtimeAnalytics.subscribeToRealtimeEvents((event) => {
  updateDashboard(event);
});
```

### Cross-Domain Tracking

Tracking users across multiple domains requires careful coordination of identifiers while respecting same-origin policy constraints.

```javascript
async function initCrossDomainTracking(domains) {
  const userId = getUserId();
  const sessionId = getSessionId();
  
  // Add tracking parameters to cross-domain links
  document.addEventListener('click', (event) => {
    const link = event.target.closest('a');
    
    if (!link) return;
    
    const url = new URL(link.href);
    const isDifferentDomain = url.hostname !== window.location.hostname;
    const isTrackedDomain = domains.includes(url.hostname);
    
    if (isDifferentDomain && isTrackedDomain) {
      url.searchParams.set('_uid', userId);
      url.searchParams.set('_sid', sessionId);
      link.href = url.toString();
    }
  });
  
  // Check for incoming tracking parameters
  const urlParams = new URLSearchParams(window.location.search);
  const incomingUserId = urlParams.get('_uid');
  const incomingSessionId = urlParams.get('_sid');
  
  if (incomingUserId && incomingSessionId) {
    localStorage.setItem('analytics_user_id', incomingUserId);
    sessionStorage.setItem('analytics_session_id', incomingSessionId);
    
    // Track cross-domain transition
    await fetch('https://analytics.example.com/cross-domain', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        event: 'cross_domain_transition',
        fromDomain: document.referrer ? new URL(document.referrer).hostname : null,
        toDomain: window.location.hostname,
        userId: incomingUserId,
        sessionId: incomingSessionId,
        timestamp: Date.now()
      })
    });
    
    // Clean URL
    window.history.replaceState({}, '', window.location.pathname);
  }
}

initCrossDomainTracking(['example.com', 'shop.example.com', 'blog.example.com']);
```

### Funnel and Conversion Tracking

Multi-step conversion funnels require sequential event tracking with proper attribution and drop-off analysis.

```javascript
class FunnelTracker {
  constructor(endpoint, funnelId) {
    this.endpoint = endpoint;
    this.funnelId = funnelId;
    this.funnelSteps = [];
  }
  
  async trackStep(stepName, stepData = {}) {
    const stepInfo = {
      funnelId: this.funnelId,
      stepName,
      stepIndex: this.funnelSteps.length,
      stepData,
      userId: getUserId(),
      sessionId: getSessionId(),
      timestamp: Date.now()
    };
    
    this.funnelSteps.push(stepInfo);
    
    await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        event: 'funnel_step',
        ...stepInfo
      })
    });
  }
  
  async trackCompletion(completionData = {}) {
    await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        event: 'funnel_completion',
        funnelId: this.funnelId,
        steps: this.funnelSteps,
        completionData,
        totalDuration: Date.now() - this.funnelSteps[0].timestamp,
        userId: getUserId(),
        sessionId: getSessionId(),
        timestamp: Date.now()
      })
    });
    
    this.funnelSteps = [];
  }
  
  async trackAbandonment(abandonmentReason) {
    await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        event: 'funnel_abandonment',
        funnelId: this.funnelId,
        completedSteps: this.funnelSteps,
        lastStep: this.funnelSteps[this.funnelSteps.length - 1]?.stepName,
        abandonmentReason,
        userId: getUserId(),
        sessionId: getSessionId(),
        timestamp: Date.now()
      })
    });
  }
}

// Usage example: Checkout funnel
const checkoutFunnel = new FunnelTracker('https://analytics.example.com/events', 'checkout_v2');

checkoutFunnel.trackStep('cart_view', { itemCount: 3, cartValue: 89.97 });
checkoutFunnel.trackStep('shipping_info', { shippingMethod: 'express' });
checkoutFunnel.trackStep('payment_info', { paymentMethod: 'credit_card' });
checkoutFunnel.trackCompletion({ orderId: 'ORD-12345', totalValue: 89.97 });
```

### Custom Dimension Tracking

Enriching events with custom dimensions enables sophisticated segmentation and analysis across business-specific attributes.

```javascript
class DimensionTracker {
  constructor(endpoint) {
    this.endpoint = endpoint;
    this.customDimensions = {};
  }
  
  setDimension(key, value) {
    this.customDimensions[key] = value;
  }
  
  setDimensions(dimensions) {
    this.customDimensions = {
      ...this.customDimensions,
      ...dimensions
    };
  }
  
  clearDimension(key) {
    delete this.customDimensions[key];
  }
  
  async track(eventName, eventData = {}) {
    await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        event: eventName,
        properties: eventData,
        dimensions: this.customDimensions,
        userId: getUserId(),
        sessionId: getSessionId(),
        timestamp: Date.now()
      })
    });
  }
}

const dimensionTracker = new DimensionTracker('https://analytics.example.com/events');

// Set user-level dimensions
dimensionTracker.setDimensions({
  subscriptionTier: 'premium',
  accountAge: '180_days',
  userSegment: 'power_user',
  experimentVariant: 'control'
});

// Track events with enriched dimensions
dimensionTracker.track('feature_used', {
  featureName: 'advanced_reporting',
  usageCount: 5
});
```

---

