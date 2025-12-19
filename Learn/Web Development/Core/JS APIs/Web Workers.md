# Syllabus

## Module 1: Foundations

- What are Web Workers
- Browser support and feature detection
- Use cases and benefits
- Limitations and constraints
- Thread model in JavaScript
- Structured clone algorithm
- Same-origin policy for workers

## Module 2: Dedicated Workers

- Creating dedicated workers
- Worker lifecycle
- Terminating workers
- Worker scope and global context
- Importing scripts with `importScripts()`
- Worker error handling
- Debugging workers

## Module 3: Communication Patterns

- `postMessage()` API
- `onmessage` event handler
- Message event object structure
- Transferable objects
- `MessageChannel` API
- Bidirectional communication
- Multiple message handlers

## Module 4: Shared Workers

- Creating shared workers
- Shared worker lifecycle
- Port-based communication
- Connecting multiple contexts
- Managing multiple connections
- Shared worker debugging
- Use cases for shared workers

## Module 5: Service Workers (Distinct Worker Type)

- Service worker registration
- Service worker lifecycle states
- Scope and interception
- Cache API integration
- Offline functionality patterns
- Push notifications
- Background sync

## Module 6: Worker Data Handling

- Serialization limitations
- Transferable objects (ArrayBuffer, MessagePort, etc.)
- SharedArrayBuffer and Atomics
- Structured cloning vs transfer
- Performance considerations
- Large dataset processing
- Binary data handling

## Module 7: Advanced Patterns

- Worker pools
- Task queuing systems
- Load balancing across workers
- Worker state management
- Recursive worker spawning
- Worker factories
- Lazy worker initialization

## Module 8: Performance Optimization

- When to use workers
- Overhead considerations
- Memory management
- Worker reuse strategies
- Batching messages
- Minimizing serialization costs
- Benchmarking worker performance

## Module 9: Error Handling & Debugging

- Error event handling
- `onerror` vs `onmessageerror`
- Debugging tools and techniques
- Chrome DevTools for workers
- Firefox debugging features
- Logging strategies
- Graceful degradation

## Module 10: Worker Modules

- Module workers (`type: 'module'`)
- ES modules in workers
- Dynamic imports in workers
- Module scope differences
- Import maps support
- Module worker browser support

## Module 11: Worker APIs & Features

- Available Web APIs in workers
- Unavailable APIs (DOM, window)
- Timers in workers
- XMLHttpRequest in workers
- Fetch API in workers
- WebSockets in workers
- IndexedDB in workers
- Web Crypto API in workers

## Module 12: Real-World Applications

- Image processing
- Data parsing and transformation
- Cryptographic operations
- Complex calculations
- Audio processing with AudioWorklet
- Canvas rendering offload
- Real-time data processing
- WebAssembly integration with workers

## Module 13: Testing & Quality Assurance

- Unit testing worker code
- Integration testing
- Mocking worker communication
- Testing frameworks compatibility
- Test runner considerations
- Code coverage for workers

## Module 14: Build Tools & Bundlers

- Webpack worker configuration
- Rollup worker plugins
- Vite worker handling
- Parcel worker support
- Inline workers vs separate files
- Worker bundling strategies

## Module 15: Cross-Browser Compatibility

- Browser API differences
- Polyfills and fallbacks
- Progressive enhancement
- Feature detection patterns
- Legacy browser support
- Mobile browser considerations

## Module 16: Security Considerations

- CSP (Content Security Policy) implications
- worker-src directive
- Script injection prevention
- Data validation
- CORS considerations
- Secure communication patterns

## Module 17: Advanced Topics

- Worklets (Paint, Animation, Audio, Layout)
- Worker and Worklet differences
- OffscreenCanvas
- CompressionStream in workers
- Worker navigation
- Worker permissions

## Module 18: Architecture & Design Patterns

- Worker abstraction layers
- Promise-based worker wrappers
- RPC patterns with workers
- Actor model implementation
- Message routing systems
- Worker orchestration