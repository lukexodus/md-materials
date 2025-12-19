# Syllabus

## Module 1: JavaScript Engine Fundamentals
- Call stack and execution contexts
- Memory heap and garbage collection
- Event loop mechanics
- Microtasks and macrotasks
- Browser rendering pipeline
- DOM API fundamentals
- Virtual DOM concept origins

## Module 2: React Core Concepts
- Declarative vs imperative paradigms
- Component tree structure
- Reconciliation algorithm overview
- React elements vs components
- React's top-level API
- Rendering phases (render and commit)
- Batching mechanisms

## Module 3: JSX Transformation
- JSX to JavaScript compilation
- Babel plugin architecture
- React.createElement mechanics
- JSX pragma and fragments
- Key prop internals
- Children prop handling
- JSX runtime (classic vs automatic)

## Module 4: Fiber Architecture
- Fiber data structure
- Fiber node properties
- Work loop implementation
- Fiber tree construction
- Current and work-in-progress trees
- Fiber tags and types
- Linked list structure
- Effect list concept

## Module 5: Reconciliation Engine
- Diffing algorithm implementation
- Tree comparison strategies
- Key-based reconciliation
- Component type changes
- Element reuse decisions
- Sibling reconciliation
- Single element reconciliation
- Fragment reconciliation

## Module 6: Rendering Pipeline
- Render phase internals
- Commit phase internals
- BeginWork function
- CompleteWork function
- Effect execution order
- DOM mutation batching
- Layout effects timing
- Passive effects scheduling

## Module 7: Scheduler Implementation
- Priority levels
- Time slicing mechanism
- Work prioritization
- Expiration times
- Task queuing
- Interruptible rendering
- Cooperative scheduling
- Frame deadlines

## Module 8: Concurrent Mode Architecture
- Concurrent rendering theory
- Interruptible work units
- Priority-based rendering
- Starvation prevention
- CPU-bound vs IO-bound work
- Lane model
- Update priorities
- Suspense integration

## Module 9: Hooks Implementation
- Hooks dispatcher
- Fiber hooks linked list
- Hook state storage
- useState implementation
- useEffect implementation
- useReducer implementation
- useCallback and useMemo internals
- useRef implementation
- Custom hooks mechanics
- Rules of hooks enforcement

## Module 10: State Update Mechanism
- Update queue structure
- Update objects
- State calculation algorithm
- Update prioritization
- Batching implementation
- Automatic batching (React 18)
- setState callback timing
- Eager state initialization

## Module 11: Context API Internals
- Context provider implementation
- Context consumer mechanism
- Value propagation algorithm
- Context change detection
- Multiple context optimization
- Context stack management
- Default value handling

## Module 12: Effects System
- Effect tags
- Effect list construction
- Passive effect queue
- Layout effect queue
- Effect cleanup mechanism
- Effect dependency comparison
- Effect timing guarantees
- useLayoutEffect vs useEffect internals

## Module 13: Event System
- Synthetic event implementation
- Event pooling (legacy)
- Event delegation strategy
- Event priority system
- Discrete vs continuous events
- Event bubbling and capturing
- Event plugin architecture
- Native event binding

## Module 14: Suspense Architecture
- Suspense boundary implementation
- Thenable detection
- Suspended component handling
- Cache integration
- Fallback rendering
- Error boundary interaction
- Promise tracking
- Re-suspension mechanics

## Module 15: Server-Side Rendering
- ReactDOMServer implementation
- Streaming renderer architecture
- Hydration algorithm
- Mismatch detection
- Partial hydration
- Selective hydration
- Progressive hydration
- Server component protocol

## Module 16: React Server Components
- Client vs server component split
- Serialization protocol
- Server component rendering
- Client component boundaries
- Asset handling
- Streaming architecture
- Flight protocol
- Integration with bundlers

## Module 17: Memory Management
- Component instance lifecycle
- Fiber cleanup process
- Memory leak prevention
- Detached tree handling
- Event listener cleanup
- Reference retention
- Garbage collection cooperation
- Memory profiling strategies

## Module 18: Performance Internals
- React DevTools Profiler implementation
- Commit phase timing
- Component render tracking
- Bailout optimization
- Memoization internals
- React.memo implementation
- Prop comparison strategies
- Child reconciliation shortcuts

## Module 19: Error Handling System
- Error boundary implementation
- Error propagation mechanism
- Component stack generation
- Recovery strategies
- Error phase handling
- Development vs production errors
- Error logging integration

## Module 20: Transition and Deferred Updates
- useTransition implementation
- useDeferredValue internals
- Transition lane priorities
- Pending state tracking
- Transition callbacks
- Deferred value calculation
- Interrupt and resume logic

## Module 21: Advanced Fiber Mechanics
- Double buffering technique
- Fiber flags system
- Subtree flags propagation
- Static flags optimization
- Deletion tracking
- Placement tracking
- Ref handling in fibers

## Module 22: Lanes and Priority Model
- Lane binary representation
- Lane priority encoding
- Lane merging operations
- Entanglement concept
- Lane expiration
- Batched lane updates
- Default lane assignment

## Module 23: Commit Phase Deep Dive
- Before mutation phase
- Mutation phase
- Layout phase
- Passive phase
- DOM operation batching
- Effect execution order
- Synchronous vs asynchronous commits

## Module 24: Development Tools Integration
- DevTools protocol
- Component tree serialization
- Props inspection mechanism
- State inspection mechanism
- Profiler data collection
- Time travel debugging support
- Hook inspection

## Module 25: React Compiler (Experimental)
- Automatic memoization
- AST transformation
- Dependency tracking
- Compiler optimization passes
- React Forget architecture
- Component compilation
- Hook extraction

## Module 26: Legacy and Migration Paths
- Legacy reconciler
- Stack reconciler architecture
- Migration to Fiber
- Concurrent mode adoption
- Breaking changes history
- Backward compatibility strategies
- Feature flag system

## Module 27: Source Code Organization
- Package structure
- React core packages
- Reconciler package
- Renderer packages
- Shared utilities
- Build system
- Feature flags
- Entry points

## Module 28: Cross-Platform Architecture
- Renderer abstraction
- Host config interface
- Platform-specific implementations
- ReactDOM vs React Native internals
- Custom renderer development
- Host component handling
- Text node handling

## Module 29: Debugging and Diagnostics
- Internal error messages
- Development warnings
- StrictMode implementation
- Concurrent features detection
- Debugging hooks
- Trace mechanisms
- Performance marks

## Module 30: Future Architecture Directions
- Offscreen component rendering
- Activity boundary concept
- Streaming SSR improvements
- Partial hydration evolution
- Compiler-first approach
- Edge runtime support
- Progressive enhancement patterns