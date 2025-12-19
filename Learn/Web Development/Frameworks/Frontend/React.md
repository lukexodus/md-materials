# Syllabus

## Module 1: JavaScript Foundations
- ES6+ syntax and features
- Asynchronous JavaScript
- Module systems
- Functional programming concepts
- Object-oriented programming patterns
- Closures and scope
- Event loop and concurrency model
- Prototypes and inheritance

## Module 2: React Fundamentals
- JSX syntax and compilation
- Components and props
- State management basics
- Event handling
- Conditional rendering
- Lists and keys
- Forms and controlled components
- Component lifecycle (class components)
- Hooks fundamentals

## Module 3: Advanced Component Patterns
- Higher-Order Components (HOCs)
- Render props pattern
- Compound components
- Controlled and uncontrolled components
- Custom hooks
- Hook composition
- Component composition strategies
- Presentational vs container components

## Module 4: State Management
- useState and useReducer
- Context API
- Redux fundamentals
- Redux Toolkit
- MobX
- Zustand
- Jotai
- Recoil
- State management architecture patterns
- Local vs global state decisions

## Module 5: Side Effects and Data Fetching
- useEffect hook
- useLayoutEffect
- Custom data fetching hooks
- React Query (TanStack Query)
- SWR
- Apollo Client (GraphQL)
- RTK Query
- Suspense for data fetching
- Error boundaries

## Module 6: Routing and Navigation
- React Router fundamentals
- Route parameters and query strings
- Nested routing
- Protected routes
- Code splitting with routes
- Navigation guards
- Route-based code organization
- Alternative routing solutions

## Module 7: Performance Optimization
- React.memo
- useMemo and useCallback
- Code splitting and lazy loading
- Virtualization techniques
- Profiling and debugging performance
- Bundle size optimization
- Server-side rendering (SSR)
- Static site generation (SSG)
- Incremental static regeneration (ISR)
- React Server Components

## Module 8: Component Architecture
- Atomic design methodology
- Feature-based architecture
- Domain-driven design
- Micro-frontend architecture
- Design system development
- Component library creation
- Documentation strategies
- Versioning and distribution

## Module 9: Forms and Validation
- Form libraries (React Hook Form, Formik)
- Schema validation (Zod, Yup)
- Field-level validation
- Form state management
- File uploads
- Multi-step forms
- Dynamic forms
- Accessibility in forms

## Module 10: Testing Strategies
- Unit testing with Jest
- React Testing Library
- Component testing patterns
- Integration testing
- End-to-end testing (Cypress, Playwright)
- Test-driven development (TDD)
- Mocking and stubbing
- Snapshot testing
- Testing hooks
- Testing async operations

## Module 11: TypeScript Integration
- TypeScript fundamentals
- Typing React components
- Generic components
- Typing hooks
- Type inference strategies
- Advanced type patterns
- Third-party library types
- Type-safe state management

## Module 12: Styling Architectures
- CSS Modules
- Styled Components
- Emotion
- Tailwind CSS integration
- CSS-in-JS patterns
- Theme management
- Responsive design patterns
- Animation libraries

## Module 13: Build Tools and Configuration
- Webpack configuration
- Vite
- Build optimization
- Environment variables
- Asset management
- Source maps
- Development vs production builds
- Module federation

## Module 14: Advanced Patterns
- Concurrent rendering
- Transitions API
- Suspense boundaries
- Error handling strategies
- Portal usage
- Refs and DOM manipulation
- Forward refs
- Imperative handles
- Context optimization

## Module 15: Real-Time and WebSockets
- WebSocket integration
- Server-Sent Events (SSE)
- Real-time data synchronization
- Optimistic updates
- Conflict resolution
- Socket.io integration
- WebRTC basics

## Module 16: Accessibility (a11y)
- ARIA attributes
- Semantic HTML
- Keyboard navigation
- Screen reader optimization
- Focus management
- Color contrast and visual design
- Accessibility testing tools
- WCAG compliance

## Module 17: Security
- XSS prevention
- CSRF protection
- Authentication patterns
- Authorization strategies
- Secure token storage
- Content Security Policy
- Input sanitization
- Dependency security

## Module 18: Deployment and DevOps
- CI/CD pipelines
- Docker containerization
- Cloud deployment (Vercel, Netlify, AWS)
- Environment management
- Monitoring and logging
- Error tracking (Sentry)
- Analytics integration
- Performance monitoring

## Module 19: Mobile Development
- React Native fundamentals
- Platform-specific code
- Navigation in React Native
- Native module integration
- Responsive mobile design
- Touch gestures
- Device APIs
- App distribution

## Module 20: Advanced Architecture Patterns
- Micro-frontends
- Module federation
- Monorepo management
- Design patterns (Factory, Observer, Strategy)
- Dependency injection
- SOLID principles in React
- Clean architecture
- Hexagonal architecture
- Domain-driven design implementation

---

# Performance Optimization

## React Server Components

React Server Components (RSC) are a new architecture that allows components to render on the server, separate from client-side JavaScript. They were introduced as an experimental feature and are now stable in frameworks like Next.js 13+.

### What Are Server Components?

Server Components are React components that render exclusively on the server. Unlike traditional server-side rendering (SSR), they don't send their component code to the client—only their rendered output. This means:

- The component logic and dependencies never reach the browser
- No hydration is needed for these components
- They can directly access backend resources (databases, file systems, etc.)

### Key Characteristics

**Server-Only Execution**
Server Components run only during the build process or when the server receives a request. Their code is never included in the client JavaScript bundle.

**Direct Backend Access**
These components can directly query databases, read from the file system, or access server-only APIs without creating separate API endpoints.

**Zero Client JavaScript**
Server Components contribute no JavaScript to the client bundle. This reduces the amount of code users need to download and parse.

**Async by Default**
Server Components can be async functions, allowing you to use `await` directly in the component body for data fetching.

### Server vs. Client Components

**Server Components** (default in Next.js App Router):
- Render on the server
- Can access backend resources directly
- Cannot use React hooks like `useState`, `useEffect`, etc.
- Cannot handle browser events or interactivity
- Don't increase client bundle size

**Client Components** (marked with `'use client'` directive):
- Can use all React features (hooks, state, effects)
- Handle user interactions and browser APIs
- Get sent to the browser as JavaScript
- Can import and use Server Components as children

### Data Fetching Patterns

Server Components change how you fetch data:

```javascript
// Traditional approach - client-side fetch
function ProductList() {
  const [products, setProducts] = useState([]);
  
  useEffect(() => {
    fetch('/api/products')
      .then(res => res.json())
      .then(setProducts);
  }, []);
  
  return <div>{products.map(...)}</div>;
}

// Server Component approach
async function ProductList() {
  const products = await db.products.findMany();
  
  return <div>{products.map(...)}</div>;
}
```

### Composition Rules

[Inference] Based on the architecture, there are specific rules about how Server and Client Components can be composed:

- Server Components can import and render other Server Components
- Server Components can import and render Client Components
- Client Components cannot directly import Server Components
- Client Components can receive Server Components as props (children or other props)

### Benefits

**Performance**
- Reduced JavaScript bundle size since server logic stays on the server
- Faster initial page loads
- Less code for the browser to parse and execute

**Security**
- Sensitive logic and credentials remain on the server
- No exposure of API keys or database queries to the client

**Developer Experience**
- Direct database access without building API layers
- Simpler data fetching with async/await
- Automatic code splitting between server and client

### Limitations

Server Components cannot:
- Use React state (`useState`, `useReducer`)
- Use lifecycle effects (`useEffect`, `useLayoutEffect`)
- Use browser-only APIs
- Handle user interactions directly (onClick, onChange, etc.)
- Use custom hooks that depend on state or effects
- Use Context providers (though they can read from context)

### Streaming and Suspense

Server Components work with React Suspense to enable streaming responses. The server can send parts of the UI as they become ready, rather than waiting for everything to complete.

### Adoption

Currently, the main production implementation is in Next.js 13+ with the App Router. Other frameworks are working on their own implementations.

[Unverified] Specific implementation details may vary between frameworks and versions.

---

