## Node.js Clients


### Server-to-Server GraphQL Communication

Server-to-server GraphQL communication enables backend services to interact with GraphQL APIs efficiently, providing a standardized way to fetch and manipulate data across service boundaries. This pattern is particularly valuable in distributed architectures where services need to communicate with each other through well-defined GraphQL interfaces.

Node.js applications can consume GraphQL endpoints using various client libraries, each offering different features for server-side use cases. Popular options include Apollo Client for Node.js, graphql-request for lightweight operations, and custom HTTP clients built with libraries like axios or fetch.

**Key points:**

- Eliminates the need for multiple REST endpoint calls through single GraphQL queries
- Provides strong typing and schema validation for inter-service communication
- Enables efficient data fetching with precise field selection
- Supports both query and subscription operations for real-time data sync

**Example:**

```javascript
const { GraphQLClient } = require('graphql-request');
const { ApolloClient, InMemoryCache, createHttpLink } = require('@apollo/client');

// Lightweight client for simple operations
const simpleClient = new GraphQLClient('http://user-service:4000/graphql', {
  headers: {
    'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`,
    'X-Service-Name': 'order-service'
  }
});

// Apollo Client for complex caching and state management
const apolloClient = new ApolloClient({
  link: createHttpLink({
    uri: 'http://user-service:4000/graphql',
    headers: {
      'Authorization': `Bearer ${process.env.SERVICE_TOKEN}`
    }
  }),
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      errorPolicy: 'all'
    },
    query: {
      errorPolicy: 'all'
    }
  }
});

// Service layer implementation
class UserService {
  async getUser(userId) {
    const query = `
      query GetUser($id: ID!) {
        user(id: $id) {
          id
          name
          email
          profile {
            preferences
            settings
          }
        }
      }
    `;
    
    try {
      const data = await simpleClient.request(query, { id: userId });
      return data.user;
    } catch (error) {
      throw new Error(`Failed to fetch user: ${error.message}`);
    }
  }

  async bulkUpdateUsers(updates) {
    const mutation = `
      mutation BulkUpdateUsers($updates: [UserUpdateInput!]!) {
        bulkUpdateUsers(updates: $updates) {
          success
          errors {
            userId
            message
          }
          updatedUsers {
            id
            name
            updatedAt
          }
        }
      }
    `;

    const result = await apolloClient.mutate({
      mutation: gql(mutation),
      variables: { updates }
    });

    return result.data.bulkUpdateUsers;
  }
}
```

Authentication and authorization become crucial in server-to-server scenarios, often involving service tokens, mutual TLS, or API keys. Error handling must be robust, with proper retry mechanisms and circuit breaker patterns to handle service unavailability.

### GraphQL in Microservices

GraphQL integration in microservices architectures provides a unified data layer that abstracts the complexity of multiple services behind a single, coherent API. This approach enables frontend clients to interact with the entire system through one GraphQL endpoint while maintaining service independence and scalability.

Each microservice can expose its own GraphQL schema, and these schemas can be composed into a federated graph or unified through a gateway layer. This pattern allows teams to develop and deploy services independently while maintaining a consistent API experience.

**Key points:**

- Enables schema composition across multiple services
- Reduces client complexity by providing a single API endpoint
- Supports independent service deployment and scaling
- Facilitates cross-service data fetching and aggregation

**Example:**

```javascript
// Individual service schema
const userServiceSchema = `
  type User {
    id: ID!
    name: String!
    email: String!
    orders: [Order!]!
  }

  type Query {
    user(id: ID!): User
    users(filter: UserFilter): [User!]!
  }

  type Mutation {
    createUser(input: CreateUserInput!): User!
    updateUser(id: ID!, input: UpdateUserInput!): User!
  }
`;

// Service implementation with external data fetching
const userResolvers = {
  Query: {
    user: async (_, { id }) => {
      const user = await UserModel.findById(id);
      return user;
    }
  },
  User: {
    orders: async (user) => {
      // Fetch orders from order service
      const orderService = new OrderService();
      return await orderService.getOrdersByUserId(user.id);
    }
  },
  Mutation: {
    createUser: async (_, { input }) => {
      const user = await UserModel.create(input);
      
      // Notify other services
      await eventBus.publish('user.created', {
        userId: user.id,
        email: user.email
      });
      
      return user;
    }
  }
};

// Cross-service data fetching utility
class ServiceRegistry {
  constructor() {
    this.services = new Map();
    this.clients = new Map();
  }

  register(serviceName, endpoint) {
    this.services.set(serviceName, endpoint);
    this.clients.set(serviceName, new GraphQLClient(endpoint));
  }

  async query(serviceName, query, variables = {}) {
    const client = this.clients.get(serviceName);
    if (!client) {
      throw new Error(`Service ${serviceName} not registered`);
    }
    
    return await client.request(query, variables);
  }
}

// Usage in resolver
const serviceRegistry = new ServiceRegistry();
serviceRegistry.register('order-service', 'http://order-service:4000/graphql');
serviceRegistry.register('payment-service', 'http://payment-service:4000/graphql');

const resolvers = {
  User: {
    orders: async (user) => {
      const query = `
        query GetUserOrders($userId: ID!) {
          ordersByUser(userId: $userId) {
            id
            total
            status
            items {
              id
              name
              price
            }
          }
        }
      `;
      
      const result = await serviceRegistry.query('order-service', query, { 
        userId: user.id 
      });
      return result.ordersByUser;
    }
  }
};
```

Data consistency and transaction management across services require careful consideration. Patterns like saga orchestration, event sourcing, and eventual consistency become important for maintaining data integrity.

### Gateway Patterns

GraphQL gateway patterns provide a unified entry point for client applications while orchestrating requests across multiple backend services. Gateways can implement various strategies including schema stitching, federation, and custom composition to create a cohesive API experience.

Apollo Gateway, GraphQL Mesh, and custom gateway implementations each offer different approaches to schema composition and request routing. The choice depends on factors like schema complexity, performance requirements, and team structure.

**Key points:**

- Provides a single endpoint for multiple GraphQL services
- Handles request routing and response composition
- Implements cross-cutting concerns like authentication and rate limiting
- Enables schema evolution and versioning strategies

**Example:**

```javascript
const { ApolloGateway, IntrospectAndCompose } = require('@apollo/gateway');
const { ApolloServer } = require('apollo-server-express');
const express = require('express');

// Apollo Federation Gateway
const gateway = new ApolloGateway({
  supergraphSdl: new IntrospectAndCompose({
    subgraphs: [
      { name: 'users', url: 'http://user-service:4000/graphql' },
      { name: 'orders', url: 'http://order-service:4000/graphql' },
      { name: 'products', url: 'http://product-service:4000/graphql' }
    ]
  }),
  buildService: ({ url }) => {
    return new RemoteGraphQLDataSource({
      url,
      willSendRequest: ({ request, context }) => {
        // Forward authentication headers
        if (context.user) {
          request.http.headers.set('x-user-id', context.user.id);
          request.http.headers.set('authorization', context.token);
        }
      }
    });
  }
});

// Custom gateway with schema stitching
const { stitchSchemas } = require('@graphql-tools/stitch');
const { introspectSchema, wrapSchema } = require('@graphql-tools/wrap');

async function createStitchedGateway() {
  const userServiceSchema = wrapSchema({
    schema: await introspectSchema(userServiceExecutor),
    executor: userServiceExecutor
  });

  const orderServiceSchema = wrapSchema({
    schema: await introspectSchema(orderServiceExecutor),
    executor: orderServiceExecutor
  });

  return stitchSchemas({
    subschemas: [
      {
        schema: userServiceSchema,
        transforms: [
          new RenameTypes(name => `User${name}`)
        ]
      },
      {
        schema: orderServiceSchema,
        transforms: [
          new FilterTypes(type => !type.name.startsWith('Internal'))
        ]
      }
    ],
    typeDefs: `
      extend type User {
        recentOrders: [Order!]!
      }
    `,
    resolvers: {
      User: {
        recentOrders: async (user, args, context, info) => {
          return await context.orderService.getRecentOrders(user.id);
        }
      }
    }
  });
}

// Gateway with middleware and caching
const app = express();

app.use('/graphql', 
  rateLimiter({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limit each IP to 100 requests per windowMs
  }),
  authenticate,
  responseCache({
    ttl: 300,
    keyGenerator: (req) => {
      return `${req.user?.id || 'anonymous'}:${req.body.query}`;
    }
  })
);

const server = new ApolloServer({
  gateway,
  subscriptions: false,
  context: ({ req }) => ({
    user: req.user,
    token: req.headers.authorization,
    services: {
      userService: new UserService(),
      orderService: new OrderService()
    }
  }),
  formatError: (error) => {
    // Log and sanitize errors
    console.error('GraphQL Error:', error);
    return new Error('Internal server error');
  }
});

server.applyMiddleware({ app, path: '/graphql' });
```

Performance optimization in gateways involves query analysis, result caching, and efficient request batching. Monitoring and observability become critical for understanding query performance and service health.

### Service Mesh Integration

Service mesh integration with GraphQL provides advanced networking capabilities including traffic management, security policies, and observability for GraphQL communications. Popular service mesh solutions like Istio, Linkerd, and Consul Connect can enhance GraphQL deployments with sophisticated routing, load balancing, and security features.

GraphQL services running in a service mesh benefit from automatic TLS termination, circuit breaking, retry policies, and distributed tracing. This integration enables complex deployment patterns like canary releases, blue-green deployments, and progressive traffic shifting.

**Key points:**

- Provides transparent networking and security for GraphQL services
- Enables sophisticated traffic routing and load balancing
- Implements observability and monitoring at the network level
- Supports advanced deployment strategies and fault tolerance

**Example:**

```yaml
# Istio Virtual Service for GraphQL Gateway
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: graphql-gateway
spec:
  hosts:
  - graphql-gateway
  http:
  - match:
    - headers:
        x-user-type:
          exact: premium
    route:
    - destination:
        host: graphql-gateway
        subset: v2
      weight: 100
  - route:
    - destination:
        host: graphql-gateway
        subset: v1
      weight: 80
    - destination:
        host: graphql-gateway
        subset: v2
      weight: 20
    timeout: 30s
    retries:
      attempts: 3
      perTryTimeout: 10s

---
# Destination Rule for load balancing
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: graphql-gateway
spec:
  host: graphql-gateway
  trafficPolicy:
    loadBalancer:
      consistentHash:
        httpHeaderName: "x-user-id"
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 10
    circuitBreaker:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

```javascript
// GraphQL service with service mesh awareness
const { ApolloServer } = require('apollo-server-express');
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

// Health check endpoint for service mesh
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Readiness probe endpoint
app.get('/ready', async (req, res) => {
  try {
    // Check database connectivity
    await db.ping();
    // Check downstream services
    await serviceRegistry.healthCheck();
    res.json({ status: 'ready' });
  } catch (error) {
    res.status(503).json({ status: 'not ready', error: error.message });
  }
});

// Custom middleware for service mesh headers
app.use((req, res, next) => {
  // Extract tracing headers
  const traceId = req.headers['x-trace-id'] || generateTraceId();
  const spanId = req.headers['x-span-id'] || generateSpanId();
  
  // Add to context
  req.tracing = { traceId, spanId };
  
  // Forward to downstream services
  res.set('x-trace-id', traceId);
  next();
});

const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: ({ req }) => ({
    tracing: req.tracing,
    user: req.user,
    services: createServiceClients(req.tracing)
  }),
  plugins: [
    {
      requestDidStart() {
        return {
          didResolveOperation: (context) => {
            // Add operation name to tracing
            context.request.http.headers.set(
              'x-operation-name', 
              context.request.operationName
            );
          },
          didEncounterErrors: (context) => {
            // Report errors to service mesh
            context.errors.forEach(error => {
              reportError(error, context.request.http.headers);
            });
          }
        };
      }
    }
  ]
});

// Service client factory with mesh integration
function createServiceClients(tracing) {
  return {
    userService: new GraphQLClient('http://user-service:4000/graphql', {
      headers: {
        'x-trace-id': tracing.traceId,
        'x-parent-span-id': tracing.spanId
      }
    }),
    orderService: new GraphQLClient('http://order-service:4000/graphql', {
      headers: {
        'x-trace-id': tracing.traceId,
        'x-parent-span-id': tracing.spanId
      }
    })
  };
}

server.applyMiddleware({ app });

// Graceful shutdown for service mesh
process.on('SIGTERM', () => {
  console.log('Received SIGTERM, shutting down gracefully');
  server.close(() => {
    process.exit(0);
  });
});
```

**Related topics:** GraphQL federation architecture, distributed tracing in GraphQL, GraphQL security in microservices, event-driven GraphQL patterns, and GraphQL performance monitoring.

---

