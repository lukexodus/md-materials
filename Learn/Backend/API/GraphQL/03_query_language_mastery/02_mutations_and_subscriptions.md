## Mutations and Subscriptions


### Mutation syntax and patterns

Mutations in GraphQL are operations that modify data on the server, analogous to POST, PUT, PATCH, and DELETE operations in REST APIs. They follow a specific syntax and adhere to conventions that promote consistency and predictability.

**Basic Mutation Syntax:** GraphQL mutations are defined in the schema using the `Mutation` type and follow a structured pattern. A typical mutation definition includes the mutation name, input parameters, and return type:

```graphql
type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
  deleteUser(id: ID!): DeleteUserPayload!
}
```

**Input Types Pattern:** Best practices recommend using input types for mutation parameters rather than scalar arguments. This approach provides better organization, validation, and future extensibility:

```graphql
input CreateUserInput {
  name: String!
  email: String!
  age: Int
  preferences: UserPreferencesInput
}

input UserPreferencesInput {
  newsletter: Boolean!
  notifications: NotificationSettingsInput!
}
```

**Payload Types Pattern:** Mutations typically return payload types that include both the mutated data and metadata about the operation. This pattern allows for comprehensive error handling and provides additional context:

```graphql
type CreateUserPayload {
  user: User
  errors: [UserError!]!
  clientMutationId: String
}

type UserError {
  field: String
  message: String!
  code: String
}
```

**Client Mutation ID Pattern:** The `clientMutationId` field allows clients to track mutations and correlate responses with requests, particularly useful in environments where multiple mutations might be in flight simultaneously.

**Atomic Operations:** Mutations should be designed as atomic operations that either succeed completely or fail without partial state changes. This principle ensures data consistency and simplifies error handling.

**Ordering and Side Effects:** GraphQL mutations are executed serially in the order they appear in the request, unlike queries which can be executed in parallel. This guarantees predictable behavior when mutations have dependencies or side effects.

**Bulk Operations:** For operations affecting multiple items, consider providing bulk mutation patterns:

```graphql
type Mutation {
  createUsers(input: [CreateUserInput!]!): CreateUsersPayload!
  updateUsers(input: [UpdateUserInput!]!): UpdateUsersPayload!
}
```

### Input validation and error handling

Effective input validation and error handling are crucial for robust GraphQL APIs, ensuring data integrity and providing meaningful feedback to clients.

**Schema-Level Validation:** GraphQL's type system provides the first layer of validation by enforcing type constraints, required fields, and structure validation. The schema acts as a contract that automatically validates incoming data against defined types.

**Custom Scalar Validation:** Custom scalars enable domain-specific validation logic. For example, an `Email` scalar can validate email format, while a `PhoneNumber` scalar can enforce phone number patterns:

```graphql
scalar Email
scalar PhoneNumber

type User {
  email: Email!
  phone: PhoneNumber
}
```

**Input Validation Patterns:** Server-side validation should occur at multiple levels:

**Field-Level Validation:** Individual fields are validated for format, length, and business rule compliance. This includes checking email formats, password strength, and data range constraints.

**Object-Level Validation:** Cross-field validation ensures that related fields maintain consistency. For example, validating that a user's birth date is consistent with their stated age.

**Business Logic Validation:** Higher-level validation ensures operations comply with business rules, such as verifying user permissions or checking account balances before transactions.

**Error Handling Strategies:** GraphQL provides several approaches for handling and communicating errors:

**GraphQL Errors:** Standard GraphQL errors are returned in the `errors` array of the response. These errors include a message and can contain additional fields like `path`, `locations`, and `extensions`:

```json
{
  "errors": [
    {
      "message": "Email address is already registered",
      "locations": [{"line": 2, "column": 3}],
      "path": ["createUser"],
      "extensions": {
        "code": "DUPLICATE_EMAIL",
        "field": "email"
      }
    }
  ]
}
```

**Union Types for Errors:** Some teams prefer using union types to make errors part of the schema, providing strongly-typed error handling:

```graphql
union CreateUserResult = User | ValidationError | DuplicateEmailError

type ValidationError {
  field: String!
  message: String!
}

type DuplicateEmailError {
  email: String!
  message: String!
}
```

**Payload-Based Error Handling:** The payload pattern allows mixing successful results with field-level errors:

```graphql
type CreateUserPayload {
  user: User
  errors: [UserError!]!
  success: Boolean!
}
```

**Error Classification:** Errors should be classified by type and severity:

- Validation errors (client-side fixable)
- Authorization errors (permission-related)
- System errors (server-side issues)
- Business logic errors (rule violations)

### Real-time subscriptions

GraphQL subscriptions enable real-time communication between clients and servers, allowing applications to receive live updates when data changes.

**Subscription Syntax:** Subscriptions use a syntax similar to queries but represent long-lived connections that push data to clients:

```graphql
type Subscription {
  messageAdded(chatId: ID!): Message!
  userStatusChanged(userId: ID!): UserStatus!
  orderStatusUpdated(orderId: ID!): Order!
}
```

**Transport Protocols:** Subscriptions require transport protocols that support bidirectional communication:

**WebSockets:** The most common transport for GraphQL subscriptions, providing low-latency, full-duplex communication. WebSocket connections maintain persistent connections between clients and servers.

**Server-Sent Events (SSE):** A simpler alternative for scenarios where only server-to-client communication is needed. SSE provides automatic reconnection and is easier to implement through firewalls and proxies.

**WebSocket Subprotocols:** Standard subprotocols like `graphql-ws` and `graphql-transport-ws` define how GraphQL operations are transmitted over WebSocket connections, ensuring compatibility between different client and server implementations.

**Subscription Execution Model:** Subscriptions follow an asynchronous execution model where the server maintains active subscriptions and pushes updates when relevant events occur.

**Event Sources:** Subscriptions can be triggered by various event sources:

- Database changes (using triggers or change streams)
- Message queues (Redis, RabbitMQ, Apache Kafka)
- External webhooks
- Internal application events

**Filtering and Arguments:** Subscriptions support arguments for filtering and customization:

```graphql
subscription {
  messageAdded(
    chatId: "123"
    messageType: TEXT
    userId: "user456"
  ) {
    id
    content
    author {
      name
    }
    timestamp
  }
}
```

**Subscription Resolvers:** Server-side subscription resolvers typically use async iterators or event emitters to manage the flow of data:

```javascript
const messageAdded = {
  subscribe: (parent, args, context) => {
    return context.pubsub.asyncIterator([`MESSAGE_ADDED_${args.chatId}`]);
  }
};
```

### Subscription lifecycle management

Managing subscription lifecycles is crucial for maintaining performance, preventing memory leaks, and ensuring proper resource cleanup.

**Connection Management:** Subscription connections must be properly established, maintained, and terminated:

**Connection Initialization:** Clients initiate subscription connections through WebSocket handshakes, including authentication tokens and connection parameters. The server validates credentials and establishes the connection context.

**Keep-Alive Mechanisms:** Long-lived connections require keep-alive mechanisms to detect and handle connection failures. This includes ping/pong frames and connection timeout handling.

**Graceful Termination:** Connections should be terminated gracefully when clients disconnect or when the server shuts down, ensuring proper cleanup of resources and subscriptions.

**Subscription Registration:** Active subscriptions must be tracked and managed on the server:

**Subscription Storage:** Servers maintain registries of active subscriptions, typically using in-memory data structures or distributed caches. This includes mapping subscription IDs to client connections and subscription parameters.

**Subscription Deduplication:** Multiple clients subscribing to the same events should be handled efficiently, avoiding duplicate processing and leveraging shared event streams where possible.

**Dynamic Subscription Management:** Subscriptions can be added, modified, or removed during the connection lifetime, requiring dynamic management of subscription registries.

**Memory Management:** Subscriptions can consume significant memory resources, requiring careful management:

**Resource Cleanup:** Unused subscriptions, closed connections, and expired resources must be cleaned up promptly to prevent memory leaks. This includes removing subscription entries from registries and closing event streams.

**Subscription Limits:** Implement limits on the number of concurrent subscriptions per client or globally to prevent resource exhaustion attacks.

**Backpressure Handling:** When events are generated faster than they can be consumed, implement backpressure mechanisms to prevent memory buildup, such as buffering limits and client disconnection for slow consumers.

**Error Handling and Recovery:** Subscription systems require robust error handling and recovery mechanisms:

**Connection Recovery:** Clients should implement automatic reconnection logic with exponential backoff to handle temporary connection failures.

**Subscription Resumption:** Consider implementing subscription resumption mechanisms that allow clients to resume subscriptions from specific points in time or sequence numbers.

**Error Propagation:** Subscription errors should be properly propagated to clients while maintaining connection stability for other active subscriptions.

**Monitoring and Observability:** Subscription systems require comprehensive monitoring:

**Connection Metrics:** Track the number of active connections, subscription counts, and connection duration to understand system load and performance.

**Event Metrics:** Monitor event generation rates, delivery latency, and error rates to ensure subscription system health.

**Resource Utilization:** Monitor memory usage, CPU utilization, and network bandwidth to identify potential bottlenecks and scaling needs.

**Authentication and Authorization:** Subscription security requires ongoing validation:

**Token Refresh:** Long-lived connections may require token refresh mechanisms to maintain authentication without interrupting subscriptions.

**Dynamic Authorization:** User permissions may change during subscription lifetime, requiring periodic re-authorization checks for sensitive subscriptions.

**Subscription Scoping:** Ensure subscriptions are properly scoped to user permissions and cannot access unauthorized data.

**Key points:**

- Mutations follow structured patterns using input types and payload types for consistency and error handling
- Input validation occurs at multiple levels: schema, field, object, and business logic
- Subscriptions enable real-time communication using WebSockets or Server-Sent Events
- Subscription lifecycle management includes connection handling, resource cleanup, and monitoring
- Proper error handling and security measures are essential for robust subscription systems

---

