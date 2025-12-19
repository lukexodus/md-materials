# Syllabus

## Module 1: Fundamentals

- What are Service Workers
- Service Worker lifecycle
- Browser support and compatibility
- Security requirements (HTTPS, localhost)
- Scope and registration
- Service Worker vs Web Workers vs Main Thread

## Module 2: Registration and Installation

- Registering a Service Worker
- Registration scope and path rules
- Update mechanisms
- Install event
- Activation event
- Waiting state and skipWaiting()
- Claims and clients.claim()

## Module 3: Service Worker Lifecycle Management

- Lifecycle states (parsed, installing, installed, activating, activated, redundant)
- Update triggers and detection
- Version control strategies
- Handling multiple versions
- Force update patterns
- Unregistering Service Workers

## Module 4: Cache API

- Cache interface overview
- Creating and opening caches
- Adding resources to cache
- Matching cached responses
- Cache strategies (cache-first, network-first, cache-only, network-only)
- Stale-while-revalidate pattern
- Cache versioning and cleanup
- Cache storage limits

## Module 5: Fetch Event and Request Interception

- Fetch event fundamentals
- Request object properties
- Response object properties
- Intercepting network requests
- Modifying requests and responses
- Request modes and credentials
- CORS handling in Service Workers

## Module 6: Caching Strategies (Advanced)

- Cache-first with network fallback
- Network-first with cache fallback
- Cache then network
- Generic fallback
- Combining strategies for different resource types
- Cache expiration strategies
- Partial content and range requests

## Module 7: Background Sync

- Background Sync API overview
- Registering sync events
- Handling sync events
- Retry logic and failure handling
- One-time sync vs periodic sync
- Use cases (form submissions, analytics)

## Module 8: Push Notifications

- Push API fundamentals
- Notification API
- VAPID keys and authentication
- Subscribing to push notifications
- Handling push events
- Notification actions and interactions
- Permission management
- Push notification best practices

## Module 9: Message Communication

- postMessage API
- MessageChannel and MessagePort
- Client-to-Service Worker communication
- Service Worker-to-Client communication
- Broadcast updates
- Communication patterns

## Module 10: Clients API

- WindowClient vs Client
- clients.get()
- clients.matchAll()
- clients.openWindow()
- clients.claim()
- Focusing and navigating clients
- Client types and frameType

## Module 11: Advanced Fetch Patterns

- Streaming responses
- Request/Response cloning
- Custom response generation
- Programmatic redirects
- Handling POST requests
- Form data and multipart requests
- WebSocket handling considerations

## Module 12: Storage and Quota Management

- IndexedDB integration
- Storage estimation and quota
- Persistent storage
- Storage clearing and eviction
- Managing storage across updates
- Data migration strategies

## Module 13: Performance Optimization

- Precaching critical resources
- Runtime caching strategies
- Lazy loading and code splitting
- Resource prioritization
- Bandwidth and latency considerations
- Cache warming techniques
- Performance metrics and monitoring

## Module 14: Offline Functionality

- Detecting online/offline status
- Offline fallback pages
- Offline-first architecture
- Queueing failed requests
- Sync when back online
- Offline UX patterns

## Module 15: Security Considerations

- Service Worker security model
- Same-origin policy
- Content Security Policy (CSP)
- Subresource integrity
- Preventing cache poisoning
- Secure communication practices
- HTTPS requirements and implications

## Module 16: Debugging and Development Tools

- Chrome DevTools Service Worker panel
- Firefox Developer Tools
- Application tab inspection
- Network request inspection
- Cache inspection
- Update on reload
- Bypass for network
- Console logging and debugging techniques

## Module 17: Navigation Preload

- Navigation preload API
- Enabling navigation preload
- Reading preload responses
- Performance benefits
- Use cases and limitations

## Module 18: Foreign Fetch (Deprecated)

- Historical context
- Why it was deprecated
- Alternative approaches

## Module 19: Workbox

- Workbox overview and benefits
- Workbox modules
- Build tools integration
- Precaching with Workbox
- Runtime caching with Workbox
- Workbox strategies
- Workbox plugins

## Module 20: Testing Service Workers

- Unit testing strategies
- Integration testing
- Mock Service Workers (MSW)
- Testing offline scenarios
- Automated testing in CI/CD
- Testing updates and migrations
- Cross-browser testing

## Module 21: Progressive Web Apps (PWA)

- Service Workers in PWA context
- Web App Manifest integration
- Install prompts and banners
- App shell architecture
- PWA best practices
- Lighthouse audits

## Module 22: Migration and Deployment

- Adding Service Workers to existing sites
- Progressive enhancement approach
- Rollout strategies
- Canary deployments
- Monitoring and analytics
- Rollback procedures
- A/B testing with Service Workers

## Module 23: Real-World Patterns

- Single Page Application (SPA) caching
- Multi-page application patterns
- API response caching
- Static asset versioning
- Dynamic content handling
- Third-party script handling
- Analytics and tracking

## Module 24: Advanced Topics

- Service Worker injection attacks prevention
- Content encoding and compression
- Shared Workers interaction
- Multiple Service Workers per origin
- Cross-origin Service Worker considerations
- Service Worker-based A/B testing
- Background Fetch API

## Module 25: Future and Experimental Features

- Periodic Background Sync
- Web Background Synchronization
- Cookie Store API
- Declarative routing proposals
- Service Worker scope extensions
- Emerging patterns and proposals