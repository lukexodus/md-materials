## Table of Contents: Fastify

### Introduction to Fastify

- What is Fastify and why use it
- Fastify vs Express vs Koa vs Hapi
- Architecture overview and design philosophy
- Performance benchmarks and internals
- Versioning and release policy
- Community, ecosystem, and resources

### Environment Setup

- Node.js version requirements
- Installing Fastify via npm and yarn
- Project scaffolding with fastify-cli
- Directory structure conventions
- Environment variables and .env management
- Nodemon and hot-reloading for development

### Core Server Concepts

- Creating a Fastify instance
- Server options and configuration object
- Starting and stopping the server
- Listening on host and port
- HTTPS and HTTP/2 setup
- Graceful shutdown

### Routing

- Defining GET, POST, PUT, PATCH, DELETE routes
- Route shorthand methods
- Full route declaration syntax
- Route-level options
- URL parameters and wildcards
- Query string handling
- Nested and grouped routes
- Route prefixing
- Constraints and route versioning
- HEAD and OPTIONS handling

### Request Object

- Anatomy of the Request object
- Accessing params, query, and body
- Request headers
- Raw request object
- Request id and logging integration
- IP address and connection info
- Custom request properties

### Reply Object

- Anatomy of the Reply object
- Sending responses with reply.send
- Status codes and reply.code
- Setting and managing headers
- Redirects
- Streaming responses
- Hijacking the response
- reply.raw access
- Trailers

### Schema Validation

- JSON Schema fundamentals
- Body validation schema
- Query string validation schema
- Params validation schema
- Headers validation schema
- Response validation schema
- Reusing schemas with $ref and $id
- Shared schema registry
- AJV configuration and custom keywords
- Custom validators

### Serialization

- How Fastify serializes responses
- Fast-json-stringify overview
- Response schema for serialization
- Custom serializers
- Serializer per content type
- Disabling serialization

### Plugin System

- Plugin architecture and encapsulation model
- Registering plugins with fastify.register
- Plugin scope and context isolation
- Plugin options and prefix
- Async plugins
- Plugin dependencies with fastify-plugin
- Breaking encapsulation intentionally
- Plugin load order
- Writing reusable plugins
- Publishing plugins to npm

### Hooks

- Hook lifecycle overview
- onRequest hook
- preParsing hook
- preValidation hook
- preHandler hook
- preSerialization hook
- onSend hook
- onResponse hook
- onError hook
- onRoute hook
- onRegister hook
- onReady and onClose hooks
- onTimeout hook
- Hook scope and encapsulation
- Multiple hooks per lifecycle event

### Middleware

- Middleware vs hooks distinction
- Using @fastify/middie for Express middleware compatibility
- Adding middleware with addHook
- Scoped vs global middleware
- Migrating Express middleware

### Decorators

- fastify.decorate for server-level decoration
- fastify.decorateRequest
- fastify.decorateReply
- Decorator dependencies
- Using decorators across plugins
- Encapsulation and decorator scope

### Error Handling

- Default error handling behavior
- Custom error handler with setErrorHandler
- HTTP errors with @fastify/sensible
- Creating custom error classes
- Schema validation errors
- Async error propagation
- Not found handler with setNotFoundHandler
- 404 and 500 customization
- Error serialization

### Logging

- Built-in Pino logger
- Logger configuration options
- Log levels
- Request-level logger
- Child loggers
- Logging redaction and serializers
- Custom logger integration
- Pretty printing in development
- Log transport and destinations
- Structured logging best practices

### Content Type Parsing

- Default content type parsers
- Registering custom content type parsers
- Parsing application/json
- Parsing application/x-www-form-urlencoded
- Parsing multipart/form-data
- Raw body access
- Removing default parsers

### File Uploads

- Multipart handling with @fastify/multipart
- Single and multiple file uploads
- Streaming file uploads
- File size and field limits
- Saving files to disk
- Integrating with cloud storage

### Static File Serving

- Serving static assets with @fastify/static
- Root directory configuration
- Prefix and decorateReply options
- Caching headers
- Directory listing
- Multiple static roots

### Authentication and Authorization

- Authentication strategies overview
- JWT authentication with @fastify/jwt
- Session-based authentication with @fastify/session
- Cookie management with @fastify/cookie
- OAuth2 with @fastify/oauth2
- Basic auth with @fastify/basic-auth
- Passport.js integration
- Role-based access control patterns
- Route-level auth guards
- Protecting routes with preHandler hooks

### CORS and Security Headers

- Enabling CORS with @fastify/cors
- CORS configuration options
- Security headers with @fastify/helmet
- Rate limiting with @fastify/rate-limit
- CSRF protection with @fastify/csrf-protection
- Content security policy

### Caching

- HTTP cache headers
- ETag and conditional requests
- Server-side caching patterns
- Redis caching integration
- Response caching with plugins
- Cache invalidation strategies

### Database Integration

- Connecting to PostgreSQL with @fastify/postgres
- Using Knex.js with Fastify
- Prisma ORM integration
- TypeORM integration
- Mongoose and MongoDB integration
- Redis with @fastify/redis
- SQLite integration
- Connection pooling
- Database plugin encapsulation patterns
- Transaction management

### TypeScript Support

- Setting up TypeScript with Fastify
- Typing the Fastify instance
- Generic types for request and reply
- Typing route schemas
- Typing plugins and decorators
- TypeBox for schema and type sharing
- Zod integration for validation
- Type-safe route handlers
- Augmenting Fastify types

### OpenAPI and Documentation

- Swagger integration with @fastify/swagger
- Swagger UI with @fastify/swagger-ui
- Generating OpenAPI 3.0 specs
- Documenting routes with schema metadata
- Tags, descriptions, and examples
- Authentication documentation
- Exporting and hosting API docs

### Testing

- Testing philosophy for Fastify apps
- Using fastify.inject for in-process testing
- Setting up Jest with Fastify
- Setting up Node Test Runner
- Unit testing route handlers
- Integration testing plugins
- Mocking dependencies
- Testing authentication flows
- Testing validation errors
- Code coverage setup
- Testing with tap

### WebSockets

- WebSocket support with @fastify/websocket
- Upgrading HTTP to WebSocket
- WebSocket route handlers
- Broadcasting messages
- Managing connections
- WebSocket authentication
- Error handling in WebSockets

### Server-Sent Events

- SSE fundamentals
- Implementing SSE with reply streaming
- SSE plugin patterns
- Client reconnection handling
- SSE vs WebSocket trade-offs

### GraphQL Integration

- GraphQL with Mercurius
- Defining schema and resolvers
- GraphQL subscriptions
- DataLoader integration
- GraphQL authentication and context
- Mercurius gateway and federation

### Microservices and Inter-Service Communication

- Fastify in a microservices architecture
- Service discovery patterns
- HTTP client with undici
- gRPC integration
- Message queues with BullMQ
- Event-driven patterns with NATS
- RabbitMQ integration

### Performance Optimization

- Understanding Fastify's performance model
- Schema compilation and caching
- Reducing serialization overhead
- Avoiding performance anti-patterns
- Profiling with Clinic.js
- Benchmarking with autocannon
- Memory management
- Cluster mode with Node.js
- Worker threads integration
- Keep-alive and connection reuse

### Process Management and Deployment

- Running with PM2
- Running with systemd
- Dockerizing a Fastify application
- Docker Compose setup
- Kubernetes deployment basics
- Environment-specific configuration
- Zero-downtime restarts
- Health check endpoints
- Readiness and liveness probes

### Monitoring and Observability

- Metrics with Prometheus and @fastify/metrics
- OpenTelemetry integration
- Distributed tracing
- Grafana dashboards for Fastify
- Error tracking with Sentry
- Alerting strategies

### Advanced Plugin Patterns

- Plugin composition and layering
- Context-aware plugins
- Plugin versioning and compatibility
- Building internal plugin libraries
- Monorepo plugin management
- Plugin testing strategies

### Advanced Routing Patterns

- Dynamic route registration
- Route enumeration and introspection
- Multi-tenant routing
- API versioning strategies
- Conditional route loading
- Custom constraint strategies

### Fastify CLI and Tooling

- fastify-cli commands overview
- Generating projects and plugins
- Running and watching with CLI
- Environment flags
- CLI plugin auto-loading
- Custom CLI scripts

### Application Architecture Patterns

- Flat plugin architecture
- Feature-based modular structure
- Domain-driven design with Fastify
- Separation of concerns in handlers
- Repository pattern with Fastify
- Service layer patterns
- Dependency injection approaches
- Configuration management at scale

### Migration and Interoperability

- Migrating from Express to Fastify
- Migrating from Hapi to Fastify
- Coexisting with legacy middleware
- Incremental adoption strategies
- Wrapping Fastify in other frameworks

### Security Best Practices

- Input sanitization
- SQL injection prevention patterns
- XSS mitigation
- Dependency auditing
- Secrets management
- TLS configuration hardening
- Least privilege principle for routes
- Security audit checklist for Fastify apps
