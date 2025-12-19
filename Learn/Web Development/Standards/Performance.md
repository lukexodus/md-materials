# Syllabus

## Module 1: Performance Fundamentals

- What is web performance
- Why performance matters
- User perception of speed
- Performance impact on business metrics
- Performance impact on SEO
- Performance budgets concept
- Performance culture in teams
- Performance vs feature tradeoffs
- Mobile vs desktop performance considerations
- Progressive enhancement for performance

## Module 2: Performance Metrics

- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- First Input Delay (FID)
- Interaction to Next Paint (INP)
- Cumulative Layout Shift (CLS)
- Time to First Byte (TTFB)
- Total Blocking Time (TBT)
- Speed Index
- Time to Interactive (TTI)
- First Meaningful Paint (FMP) (deprecated)
- Custom metrics definition
- Synthetic vs Real User Monitoring (RUM)
- Percentile-based metrics (p50, p75, p95, p99)

## Module 3: Core Web Vitals

- Core Web Vitals overview
- LCP optimization strategies
- INP optimization strategies
- CLS optimization strategies
- Core Web Vitals thresholds (good, needs improvement, poor)
- Field data vs lab data
- Core Web Vitals and SEO
- Mobile vs desktop thresholds
- Historical context (FID to INP transition)
- Future of Core Web Vitals

## Module 4: Browser Rendering Pipeline

- DOM construction
- CSSOM construction
- Render tree construction
- Layout (reflow) process
- Paint process
- Composite layers
- GPU acceleration
- Hardware acceleration triggers
- Critical rendering path
- Rendering optimization strategies
- Layer promotion
- Will-change property
- Transform and opacity optimizations

## Module 5: JavaScript Performance

- Parse and compile time
- Execution time optimization
- Event loop and task queue
- Microtasks vs macrotasks
- Call stack optimization
- Memory management
- Garbage collection
- Memory leaks detection and prevention
- Debouncing and throttling
- requestAnimationFrame
- requestIdleCallback
- Web Workers for heavy computation
- Code splitting strategies
- Tree shaking
- Dead code elimination

## Module 6: Resource Hints (W3C)

- dns-prefetch directive
- preconnect directive
- prefetch directive
- prerender directive
- preload directive
- modulepreload for ES modules
- Resource hint priority
- Browser support considerations
- When to use each hint
- Resource hints anti-patterns
- Link rel attribute specifications
- Early hints (HTTP 103)

## Module 7: Navigation Timing API (W3C)

- Navigation Timing Level 1
- Navigation Timing Level 2
- PerformanceNavigationTiming interface
- Timing attributes (domComplete, domContentLoadedEventEnd, etc.)
- Navigation types
- Redirect timing
- DNS lookup timing
- TCP connection timing
- Request and response timing
- DOM processing timing
- Load event timing
- Calculating performance metrics from timing data

## Module 8: Resource Timing API (W3C)

- PerformanceResourceTiming interface
- Resource timing entries
- Timing for individual resources
- initiatorType property
- transferSize, encodedBodySize, decodedBodySize
- Server timing integration
- Resource timing buffer
- PerformanceObserver for resource timing
- Third-party resource monitoring
- Resource timing compression
- Resource Timing Level 2 features

## Module 9: User Timing API (W3C)

- Performance.mark() method
- Performance.measure() method
- Custom performance markers
- Measuring custom user experiences
- PerformanceObserver for user timing
- User Timing Level 3
- Navigation timing integration
- Best practices for custom metrics
- Marking critical user journeys
- Analytics integration

## Module 10: Performance Observer API

- PerformanceObserver interface
- Observing performance entries
- Entry types (mark, measure, navigation, resource, paint, etc.)
- Buffered entries
- Observer options
- Performance entry lifecycle
- Multiple observers
- Observer cleanup
- Performance monitoring patterns

## Module 11: Long Tasks API

- PerformanceLongTaskTiming interface
- Long task detection (>50ms)
- Attribution data
- Long task sources
- Blocking time calculation
- Total Blocking Time (TBT) calculation
- Identifying problematic scripts
- Third-party script impact
- Long task mitigation strategies

## Module 12: Paint Timing API

- First Paint (FP)
- First Contentful Paint (FCP)
- PerformancePaintTiming interface
- Paint timing measurement
- Optimizing paint times
- Above-the-fold content prioritization

## Module 13: Largest Contentful Paint API

- PerformanceLargestContentfulPaint interface
- LCP element identification
- LCP candidates
- LCP timing
- Image LCP optimization
- Text LCP optimization
- LCP and lazy loading
- Measuring LCP accurately

## Module 14: Layout Instability API

- Layout shift detection
- Cumulative Layout Shift calculation
- Layout shift entries
- Impact region and fraction
- Session windows for CLS
- Identifying layout shift sources
- CLS debugging techniques
- Preventing layout shifts

## Module 15: Event Timing API

- PerformanceEventTiming interface
- First Input Delay measurement
- Interaction to Next Paint measurement
- Event processing time
- Event duration
- Input delay tracking
- Slow event handlers identification
- Event timing thresholds

## Module 16: Server Timing API

- Server-Timing HTTP header
- PerformanceServerTiming interface
- Custom server metrics
- Backend timing exposure
- Database query timing
- API call timing
- Cache hit/miss timing
- CDN timing information

## Module 17: Network Information API

- NetworkInformation interface
- Connection type detection
- Effective connection type (ECT)
- Downlink speed estimation
- RTT (Round Trip Time)
- saveData property
- Adaptive loading based on connection
- Connection change events
- Data saver mode detection

## Module 18: Image Optimization

- Image format selection (JPEG, PNG, WebP, AVIF, SVG)
- Image compression techniques
- Responsive images (srcset, sizes)
- Picture element
- Art direction
- Image lazy loading
- Native lazy loading (loading="lazy")
- Intersection Observer for custom lazy loading
- Progressive JPEG
- Image CDN usage
- Image optimization tools
- Placeholder strategies (LQIP, SQIP, blur-up)
- Image dimensions to prevent CLS

## Module 19: Video and Media Optimization

- Video format selection
- Video compression
- Adaptive bitrate streaming (HLS, DASH)
- Video lazy loading
- Poster images
- Preload strategies for video
- Video autoplay considerations
- Media Source Extensions (MSE)
- Video codec selection (H.264, H.265, VP9, AV1)
- Audio optimization
- Media queries for video

## Module 20: Font Optimization

- Font loading strategies
- font-display property (swap, optional, fallback, block)
- FOIT (Flash of Invisible Text)
- FOUT (Flash of Unstyled Text)
- FOFT (Flash of Faux Text)
- Font subsetting
- Variable fonts
- Preloading fonts
- Self-hosted vs CDN fonts
- Font format selection (WOFF2, WOFF, TTF)
- Unicode-range subsetting
- Font loading API

## Module 21: CSS Performance

- CSS selector performance
- CSS specificity optimization
- Critical CSS extraction
- CSS code splitting
- Unused CSS removal
- CSS containment
- CSS will-change property
- CSS animations vs JavaScript animations
- Transform and opacity for animations
- CSS custom properties performance
- CSS-in-JS performance considerations
- Stylesheet organization

## Module 22: JavaScript Loading Strategies

- Script tag placement
- async attribute
- defer attribute
- type="module"
- Dynamic imports
- Inline scripts vs external scripts
- Script loading order
- Third-party script optimization
- Script bundling strategies
- Module bundling vs unbundling
- HTTP/2 considerations

## Module 23: Code Splitting

- Route-based splitting
- Component-based splitting
- Vendor splitting
- Dynamic imports
- React.lazy and Suspense
- Webpack code splitting
- Vite code splitting
- Rollup code splitting
- esbuild code splitting
- Chunk optimization
- Granular chunking strategies

## Module 24: Tree Shaking

- ES modules and tree shaking
- Side effect analysis
- Package.json sideEffects field
- Webpack tree shaking
- Rollup tree shaking
- Dead code elimination
- CommonJS vs ES modules
- Optimizing for tree shaking
- Library publishing best practices

## Module 25: Minification and Compression

- HTML minification
- CSS minification
- JavaScript minification
- Terser configuration
- Source maps for debugging
- Gzip compression
- Brotli compression
- Compression levels
- Server configuration for compression
- Pre-compression strategies
- Content-Encoding header

## Module 26: Bundling and Build Tools

- Webpack optimization
- Vite optimization
- Rollup optimization
- esbuild performance
- Parcel optimization
- Build time optimization
- Development vs production builds
- Mode-specific optimizations
- Asset pipeline optimization
- Build caching strategies

## Module 27: Caching Strategies

- HTTP caching fundamentals
- Cache-Control header
- ETag and Last-Modified
- Immutable content
- Cache busting techniques
- Content hashing
- Service Worker caching
- Cache-first strategies
- Network-first strategies
- Stale-while-revalidate
- Cache API
- IndexedDB for caching
- Memory caching
- Application cache (deprecated)

## Module 28: Service Workers

- Service Worker lifecycle
- Install and activate events
- Fetch event interception
- Caching strategies implementation
- Offline functionality
- Background sync
- Push notifications
- Workbox library
- Service Worker registration
- Service Worker update strategies
- Service Worker debugging
- Precaching vs runtime caching

## Module 29: Progressive Web Apps (PWA)

- PWA principles
- App shell architecture
- PRPL pattern (Push, Render, Pre-cache, Lazy-load)
- Web App Manifest
- Installability
- Offline-first approach
- App-like experiences
- PWA performance benefits
- Lighthouse PWA audit

## Module 30: HTTP/2 and HTTP/3

- HTTP/2 multiplexing
- Server push
- Header compression (HPACK)
- Binary protocol benefits
- HTTP/2 vs HTTP/1.1 optimization differences
- Domain sharding obsolescence
- HTTP/3 and QUIC
- 0-RTT connection establishment
- Migration from HTTP/1.1
- Server configuration for HTTP/2

## Module 31: CDN and Edge Computing

- Content Delivery Network basics
- Edge caching
- Geographic distribution
- CDN selection criteria
- Edge computing capabilities
- Edge Side Includes (ESI)
- CDN performance monitoring
- Multi-CDN strategies
- CDN failover
- Static asset delivery via CDN
- Dynamic content via CDN
- Edge Workers (Cloudflare Workers, etc.)

## Module 32: Server-Side Rendering (SSR)

- SSR benefits for performance
- Time to First Byte optimization
- Hydration performance
- Streaming SSR
- Progressive hydration
- Selective hydration
- Islands architecture
- SSR caching strategies
- SSR vs Static Site Generation (SSG)
- Incremental Static Regeneration (ISR)
- On-demand ISR

## Module 33: Static Site Generation

- Build-time rendering
- Performance benefits of SSG
- Content versioning
- Deployment strategies
- Hybrid rendering (SSG + SSR)
- Distributed Persistent Rendering (DPR)
- Stale content strategies
- Build time optimization
- JAMstack architecture

## Module 34: Client-Side Rendering Optimization

- Initial bundle size reduction
- Route-based code splitting
- Component lazy loading
- Virtual scrolling
- Windowing techniques
- React optimization (useMemo, useCallback, React.memo)
- Vue optimization techniques
- State management performance
- Reconciliation optimization

## Module 35: Database Performance

- Query optimization
- Indexing strategies
- N+1 query problem
- Connection pooling
- Caching layers (Redis, Memcached)
- Read replicas
- Database sharding
- Query result caching
- ORM performance considerations
- Database monitoring

## Module 36: API Performance

- RESTful API optimization
- GraphQL performance
- Over-fetching and under-fetching
- API response caching
- API pagination
- API rate limiting
- Batch requests
- GraphQL query complexity
- DataLoader pattern
- API response compression
- gRPC for performance

## Module 37: Third-Party Scripts

- Third-party impact measurement
- Async loading third-party scripts
- Self-hosting third-party resources
- Third-party script facades
- Tag managers optimization
- Analytics script optimization
- Social media widget optimization
- Ad script optimization
- Consent management performance
- A/B testing script optimization

## Module 38: Web Assembly (Wasm)

- WebAssembly performance benefits
- Use cases for Wasm
- Compiling to Wasm (C/C++, Rust)
- Wasm module loading
- JavaScript and Wasm interop
- Wasm vs JavaScript performance
- Threading in Wasm
- SIMD in Wasm
- Wasm tools and debugging

## Module 39: Memory Management

- Memory profiling
- Heap snapshots
- Memory leak detection
- Detached DOM nodes
- Circular references
- WeakMap and WeakSet usage
- Memory-efficient data structures
- Object pooling
- Garbage collection optimization
- Memory pressure handling

## Module 40: Performance Monitoring Tools

- Chrome DevTools Performance panel
- Lighthouse
- WebPageTest
- PageSpeed Insights
- Chrome User Experience Report (CrUX)
- Real User Monitoring (RUM) tools
- Synthetic monitoring tools
- Application Performance Monitoring (APM)
- Custom performance dashboards
- Continuous performance monitoring
- Performance regression detection

## Module 41: Lighthouse

- Lighthouse scoring
- Performance score calculation
- Opportunities section
- Diagnostics section
- Lighthouse CI
- Custom Lighthouse configuration
- Lighthouse API
- User flow testing
- Lighthouse plugins
- Interpreting Lighthouse results

## Module 42: Chrome DevTools

- Performance panel overview
- Recording performance profiles
- Flame charts interpretation
- Bottom-up view
- Call tree view
- Event log analysis
- Screenshots during recording
- CPU throttling
- Network throttling
- Coverage panel
- Memory profiler
- Performance monitor

## Module 43: WebPageTest

- Test configuration
- Multiple location testing
- Connection speed simulation
- Filmstrip view
- Video comparison
- Waterfall chart analysis
- Content breakdown
- Domain breakdown
- Request prioritization analysis
- Third-party analysis
- Custom metrics
- WebPageTest API

## Module 44: Real User Monitoring (RUM)

- RUM vs synthetic monitoring
- Field data collection
- Performance data aggregation
- Geographic segmentation
- Device segmentation
- Browser segmentation
- RUM implementation strategies
- Sampling strategies
- Privacy considerations
- RUM data analysis
- Alerting on performance regressions

## Module 45: Performance Budgets

- Setting performance budgets
- Metric-based budgets
- Resource-based budgets (size, count)
- Timing-based budgets
- Enforcing budgets in CI/CD
- Budget monitoring
- Budget adjustment strategies
- Team accountability
- Trade-off analysis

## Module 46: Critical Path Optimization

- Identifying critical resources
- Critical CSS inline
- Critical JavaScript inline
- Defer non-critical resources
- Preload critical resources
- Async non-critical resources
- Critical rendering path analysis
- Above-the-fold optimization
- Progressive rendering

## Module 47: Adaptive Loading

- Network-aware loading
- Device-aware loading
- Memory-aware loading
- CPU-aware loading
- Battery-aware loading
- Data saver mode
- Reduced motion preferences
- Light/dark theme performance
- Responsive components
- Adaptive media delivery

## Module 48: Mobile Performance

- Mobile-specific challenges
- Touch event optimization
- Scroll performance on mobile
- Mobile network characteristics
- Mobile CPU limitations
- Mobile memory constraints
- Mobile battery considerations
- PWA on mobile
- AMP (Accelerated Mobile Pages)
- Mobile-first optimization

## Module 49: Accessibility Performance

- Accessibility tree construction cost
- ARIA attribute performance
- Focus management performance
- Screen reader performance
- Keyboard navigation performance
- Semantic HTML benefits
- Reduced motion for performance
- Accessible loading indicators
- Performance and WCAG compliance

## Module 50: Animation Performance

- 60 FPS target
- requestAnimationFrame usage
- CSS animations vs JavaScript
- Transform and opacity
- Compositor-only properties
- Animation throttling
- Scroll-linked animations
- Web Animations API
- Intersection Observer for animations
- Lottie animation optimization
- Canvas animation optimization
- SVG animation optimization

## Module 51: Scroll Performance

- Passive event listeners
- Scroll throttling and debouncing
- Virtual scrolling
- Infinite scroll optimization
- Intersection Observer usage
- CSS containment for scroll
- will-change for scroll
- Scroll jank debugging
- Layout thrashing prevention
- Position: sticky performance

## Module 52: Form Performance

- Input debouncing
- Validation timing
- Async validation
- Form submission optimization
- Large form handling
- Autocomplete optimization
- Typeahead performance
- File upload optimization
- Multi-step form optimization
- Progressive enhancement for forms

## Module 53: Web Vitals Library

- web-vitals npm package
- Measuring Core Web Vitals
- Custom metric reporting
- Attribution data collection
- Web Vitals and analytics integration
- Debug builds
- Polyfills for older browsers
- CLS attribution
- INP attribution
- LCP attribution

## Module 54: Performance Patterns

- RAIL model (Response, Animation, Idle, Load)
- PRPL pattern
- App shell model
- Islands architecture
- Micro-frontends performance
- Component lazy loading patterns
- Data prefetching patterns
- Optimistic UI updates
- Progressive enhancement pattern
- Graceful degradation

## Module 55: React Performance

- React.memo for component memoization
- useMemo hook
- useCallback hook
- useTransition for concurrent features
- useDeferredValue
- Suspense for data fetching
- Lazy loading components
- Code splitting in React
- React DevTools Profiler
- Virtual DOM optimization
- Key prop optimization
- Avoiding unnecessary re-renders
- Context API performance
- State management performance (Redux, Zustand, Jotai)

## Module 56: Vue Performance

- Computed properties caching
- Watchers optimization
- v-once directive
- v-memo directive
- Functional components
- Async components
- Vue DevTools performance profiling
- Reactivity system optimization
- Virtual scrolling in Vue
- Vuex performance patterns
- Pinia performance

## Module 57: Angular Performance

- Change detection strategies
- OnPush change detection
- TrackBy for ngFor
- Lazy loading modules
- Preloading strategies
- AOT (Ahead-of-Time) compilation
- Tree shaking in Angular
- Angular Universal (SSR)
- Angular service workers
- Zone.js optimization
- RxJS optimization
- NgRx performance patterns

## Module 58: Svelte Performance

- Compile-time optimization
- No virtual DOM overhead
- Reactive declarations
- Stores optimization
- SvelteKit performance
- SSR with SvelteKit
- Code splitting in Svelte
- Animation performance in Svelte
- Svelte transitions optimization

## Module 59: Backend Performance

- Response time optimization
- Server-side caching
- Horizontal scaling
- Vertical scaling
- Load balancing
- Microservices performance
- Serverless cold starts
- Database connection pooling
- API gateway optimization
- Message queue optimization
- Background job processing
- Async processing patterns

## Module 60: DNS and Network

- DNS lookup optimization
- DNS prefetching
- CDN DNS configuration
- Anycast DNS
- TCP connection optimization
- TLS handshake optimization
- TLS 1.3 benefits
- Connection reuse (Keep-Alive)
- HTTP pipelining (deprecated)
- Reducing request count
- Domain sharding (HTTP/1.1 only)
- Connection coalescing (HTTP/2)

## Module 61: Security and Performance

- Security headers performance impact
- CSP (Content Security Policy) performance
- Subresource Integrity (SRI)
- HTTPS performance considerations
- Certificate validation
- OCSP stapling
- Certificate transparency
- Security vs performance tradeoffs
- DDoS mitigation performance
- Rate limiting implementation

## Module 62: Testing Performance

- Performance test automation
- Load testing tools (JMeter, k6)
- Stress testing
- Spike testing
- Soak testing
- Performance regression testing
- A/B testing for performance
- Canary deployments
- Blue-green deployments
- Feature flags for performance testing

## Module 63: Continuous Performance

- Performance in CI/CD pipelines
- Automated performance tests
- Performance gates in deployment
- Performance monitoring dashboards
- Alerting on performance degradation
- Performance SLOs (Service Level Objectives)
- Performance SLIs (Service Level Indicators)
- Performance SLAs (Service Level Agreements)
- Performance post-mortems
- Performance culture

## Module 64: Advanced Optimization Techniques

- Memoization strategies
- Virtualization techniques
- Web Workers for parallelism
- SharedArrayBuffer
- Atomics API
- OffscreenCanvas
- Transferable objects
- Streams API for large data
- Compression streams
- Background Fetch API
- Periodic Background Sync

## Module 65: Emerging Technologies

- HTTP/3 adoption
- QUIC protocol
- Early Hints (103 status)
- Priority Hints API
- Speculation Rules API
- Navigation API
- View Transitions API
- Container queries performance
- CSS cascade layers
- CSS @scope performance

## Module 66: E-commerce Performance

- Product listing optimization
- Product detail page performance
- Cart performance
- Checkout optimization
- Payment processing performance
- Product image optimization
- Product search performance
- Recommendation engine optimization
- Inventory checking performance
- Order processing optimization

## Module 67: Media-Heavy Sites

- Image gallery optimization
- Video platform performance
- Audio streaming optimization
- Live streaming performance
- User-generated content optimization
- Content moderation performance
- Transcoding optimization
- Thumbnail generation
- Media search optimization
- Content recommendation performance

## Module 68: Social Media Performance

- Feed rendering optimization
- Infinite scroll performance
- Real-time updates
- Notification system performance
- Chat and messaging optimization
- Post creation performance
- Media upload optimization
- Comment thread rendering
- Social graph queries
- Activity feed performance

## Module 69: SaaS Application Performance

- Dashboard rendering
- Large dataset visualization
- Real-time data updates
- Report generation performance
- Data export optimization
- Multi-tenancy performance
- User permission checking
- Audit logging performance
- Search across tenants
- Webhook delivery optimization

## Module 70: Case Studies and Best Practices

- Large-scale performance improvements
- Migration success stories
- Performance regression incidents
- Performance optimization ROI
- Industry benchmarks
- Performance anti-patterns
- Common mistakes and fixes
- Performance checklist
- Performance optimization workflow
- Long-term performance maintenance

## Module 71: Project Implementations

- Blog optimization project
- E-commerce site performance overhaul
- Dashboard application optimization
- Media streaming platform optimization
- Social media feed performance
- SaaS application performance tuning
- Mobile app web view optimization
- Progressive Web App conversion
- Legacy site modernization
- Real-time application optimization
- International site performance
- Accessible performance optimization