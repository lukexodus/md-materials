## Table of Contents: tRPC

### Introduction to tRPC

- What is tRPC and why it exists
- tRPC vs REST vs GraphQL
- tRPC vs other type-safe API solutions
- When to use tRPC and when not to
- Overview of the tRPC ecosystem
- tRPC versioning and compatibility

### Core Concepts and Mental Model

- End-to-end type safety explained
- How tRPC achieves type inference
- The router and procedure model
- Client-server contract without code generation
- TypeScript as the schema language

### Project Setup and Installation

- Prerequisites and environment requirements
- Installing tRPC server and client packages
- Setting up a monorepo vs single-repo structure
- TypeScript configuration for tRPC
- Directory structure and conventions
- Setting up a standalone Node.js server
- Setting up with Next.js
- Setting up with Vite and React

### Defining Procedures

- Query procedures
- Mutation procedures
- Subscription procedures
- Input validation with Zod
- Input validation with Yup and Valibot
- Output validation and type inference
- Procedure chaining and reuse
- Default input and output types

### Building Routers

- Creating a root router
- Nested routers and namespacing
- Merging routers
- Router composition patterns
- Exporting the AppRouter type
- Organizing routers at scale

### Context

- What is context in tRPC
- Creating the context function
- Async context creation
- Passing request data into context
- Injecting database clients into context
- Injecting auth session into context
- Inner and outer context pattern

### Middleware

- What is middleware in tRPC
- Creating reusable middleware
- Chaining multiple middleware
- Logging middleware
- Authentication middleware
- Authorization and role-based middleware
- Rate limiting middleware
- Timing and performance middleware
- Context augmentation in middleware

### Error Handling

- TRPCError and error codes
- Throwing errors in procedures
- Custom error formatting
- Error propagation to the client
- Handling errors on the client side
- Global error handling
- Distinguishing client vs server errors

### Input and Output Validation

- Zod schema fundamentals for tRPC
- Complex nested Zod schemas
- Optional and partial inputs
- Validating arrays and unions
- Runtime output validation trade-offs
- Sharing validation schemas between client and server

### tRPC with HTTP Adapters

- Express adapter setup
- Fastify adapter setup
- Fetch adapter for edge runtimes
- AWS Lambda adapter
- Custom adapter creation
- CORS configuration
- Handling raw HTTP requests alongside tRPC

### tRPC with Next.js

- Pages Router integration
- App Router integration
- API route handler setup
- Server-side rendering with tRPC
- Static generation and tRPC
- Using tRPC with Next.js server components
- create-t3-app as a reference setup

### Client Setup

- Creating the tRPC client
- Vanilla client vs React client
- Configuring links
- HTTP link setup
- HTTP batch link setup
- WebSocket link setup
- Splitting links conditionally

### tRPC Links

- What are links and how they work
- terminating vs non-terminating links
- loggerLink
- retryLink
- splitLink
- Custom link creation
- Link composition and ordering

### React Query Integration

- How tRPC wraps TanStack Query
- useQuery for tRPC queries
- useMutation for tRPC mutations
- useInfiniteQuery for paginated data
- Query invalidation and refetching
- Optimistic updates
- Prefetching on the server
- Dehydration and hydration

### Subscriptions and WebSockets

- When to use subscriptions
- Setting up the WebSocket server
- Defining subscription procedures
- Async generators for subscriptions
- Observable-based subscriptions
- Client-side subscription consumption
- Reconnection and error handling in subscriptions

### Authentication and Authorization

- Passing auth tokens from client to server
- Session-based authentication pattern
- JWT-based authentication pattern
- Protected procedure pattern
- Role-based access control
- Per-resource authorization checks
- Integrating NextAuth with tRPC
- Integrating Clerk with tRPC

### Database Integration

- Using Prisma with tRPC
- Using Drizzle ORM with tRPC
- Using Kysely with tRPC
- Passing the database client through context
- Transaction handling in mutations
- Pagination patterns

### Advanced Patterns

- Procedure factories and reusable builders
- Higher-order routers
- Dynamic procedure generation
- Multi-tenant routing patterns
- Feature flag integration
- Dependency injection patterns
- Hexagonal architecture with tRPC

### Testing

- Unit testing procedures in isolation
- Creating a caller for server-side testing
- Mocking context in tests
- Integration testing with a real HTTP server
- Testing middleware
- Testing subscriptions
- End-to-end testing with Playwright and tRPC
- Test utilities and helpers

### Performance Optimization

- Request batching explained
- Configuring and tuning batch behavior
- Caching strategies on the server
- Edge caching with tRPC
- Reducing bundle size on the client
- Lazy loading routers
- Profiling tRPC overhead

### File Uploads and Binary Data

- Handling multipart form data
- File upload patterns with tRPC
- Integrating with cloud storage providers
- Streaming binary responses

### Internationalization and Localization

- Passing locale through context
- Localized error messages
- Locale-aware validation

### Logging, Observability, and Monitoring

- Structured logging in procedures
- Integrating OpenTelemetry
- Tracing requests end to end
- Error tracking with Sentry
- Metrics and dashboards

### Deployment

- Deploying tRPC on Vercel
- Deploying tRPC on Railway and Render
- Deploying tRPC on AWS with Lambda
- Deploying tRPC on a VPS with Docker
- Environment variable management
- Health check endpoints alongside tRPC
- Zero-downtime deployments

### Interoperability and Migration

- Calling tRPC from non-TypeScript clients
- Generating an OpenAPI spec from tRPC
- trpc-openapi integration
- Migrating from REST to tRPC incrementally
- Migrating from GraphQL to tRPC
- Coexisting REST and tRPC endpoints

### Security

- Input sanitization practices
- Preventing over-fetching and over-posting
- CSRF protection with tRPC
- API key authentication
- Secrets management
- Audit logging sensitive operations

### Monorepo and Shared Code

- Sharing the AppRouter type across packages
- Shared Zod schemas across client and server
- tRPC in Turborepo
- tRPC in Nx workspaces
- Package boundary conventions

### tRPC Ecosystem and Tooling

- trpc-openapi
- trpc-panel for API exploration
- zod-to-json-schema
- tRPC DevTools
- Community adapters and plugins
- Staying current with the tRPC changelog

### Real-World Project Capstone

- Designing the data model and router structure
- Implementing authentication end to end
- Building CRUD procedures with validation
- Adding real-time features with subscriptions
- Writing tests for all layers
- Deploying the full application
- Iterating based on performance profiling
