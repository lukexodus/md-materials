## Overview

class OrderQueryHandler:
    def __init__(self, mongo_client: MongoClient):
        self.db = mongo_client.orders_read_db
    
    def get_order_summary(self, order_id: str):
        return self.db.order_summaries.find_one({'order_id': order_id})
    
    def get_customer_orders(self, customer_id: str, limit: int = 10):
        return list(self.db.order_summaries.find(
            {'customer_id': customer_id}
        ).sort('placed_at', -1).limit(limit))
    
    def get_customer_history(self, customer_id: str):
        return self.db.customer_histories.find_one({'customer_id': customer_id})
````

**Output**

When a client places an order:

```
POST /orders
{
  "customerId": "cust-123",
  "items": [
    {"productId": "prod-456", "quantity": 2, "price": 29.99},
    {"productId": "prod-789", "quantity": 1, "price": 49.99}
  ],
  "shippingAddress": {
    "street": "123 Main St",
    "city": "Springfield",
    "zip": "12345"
  },
  "paymentMethod": "credit_card"
}

Response (202 Accepted):
{
  "orderId": "order-abc-123",
  "status": "accepted",
  "message": "Order placed successfully"
}
```

The command is processed, events are published, and read models are eventually updated. A subsequent query:

```
GET /orders/order-abc-123

Response (200 OK):
{
  "orderId": "order-abc-123",
  "customerId": "cust-123",
  "total": 109.97,
  "itemCount": 3,
  "status": "PLACED",
  "placedAt": "2024-12-20T15:30:00Z"
}
```

Querying customer history shows aggregated data:

```
GET /customers/cust-123/history

Response (200 OK):
{
  "customerId": "cust-123",
  "customerName": "John Doe",
  "totalOrders": 5,
  "lifetimeValue": 547.89,
  "orders": [
    {
      "orderId": "order-abc-123",
      "total": 109.97,
      "placedAt": "2024-12-20T15:30:00Z",
      "status": "PLACED"
    },
    {
      "orderId": "order-xyz-789",
      "total": 299.99,
      "placedAt": "2024-12-18T10:15:00Z",
      "status": "DELIVERED"
    }
    // ... more orders
  ]
}
```

**Conclusion**

CQRS in microservices provides a powerful architectural pattern for handling complex domains with diverse requirements for reads and writes. By explicitly separating these concerns, teams gain the ability to optimize each side independently, scale based on actual load patterns, and evolve the system without being constrained by a single unified model.

The pattern shines in scenarios where business logic is complex, read and write loads differ significantly, and multiple query patterns must be supported efficiently. When combined with event sourcing, CQRS provides additional benefits like complete audit trails, temporal queries, and the ability to create new projections from historical data.

However, CQRS introduces significant complexity through eventual consistency, event-driven architectures, and the operational overhead of maintaining multiple models and databases. Teams must carefully evaluate whether the benefits justify the costs for each microservice. Not every service needs CQRS—simple CRUD services should remain simple. The pattern should be applied selectively where its advantages clearly outweigh its complexity.

Successful CQRS implementation requires strong technical practices including comprehensive monitoring, distributed tracing, idempotent event handlers, proper error handling, and careful attention to user experience in the face of eventual consistency. Teams that invest in these practices and understand the tradeoffs can leverage CQRS to build highly scalable, performant microservices architectures.

---

## Event Sourcing in Microservices

Event Sourcing is an architectural pattern where the state of a system is determined by a sequence of events rather than storing only the current state. Instead of updating records in place, every change to application state is captured as an immutable event that is appended to an event store. The current state can be reconstructed by replaying these events from the beginning.

### Fundamental Concept

Traditional systems use CRUD (Create, Read, Update, Delete) operations on a database, storing only the current state. If a user's email changes from "old@example.com" to "new@example.com", the database simply overwrites the old value. The history is lost unless explicitly tracked separately.

Event Sourcing inverts this model. Instead of storing the current state, the system stores a sequence of events that describe what happened:

1. `UserRegistered: { userId: "123", email: "old@example.com", timestamp: "..." }`
2. `EmailChanged: { userId: "123", newEmail: "new@example.com", timestamp: "..." }`

The current state is derived by applying these events in order. This event log becomes the source of truth.

### Core Components

**Event Store**: A specialized database optimized for appending events and reading event streams. Events are immutable and append-only. Popular event stores include EventStoreDB, Apache Kafka, AWS EventBridge, and PostgreSQL with event sourcing patterns.

**Events**: Immutable records representing facts about something that happened in the past. Events are named in past tense (OrderPlaced, PaymentReceived, InventoryReserved) and contain all information needed to understand what occurred.

**Aggregates**: Domain entities that maintain consistency boundaries. Each aggregate has its own event stream. When an aggregate processes a command, it produces events that represent the state change.

**Event Stream**: An ordered sequence of events for a specific aggregate instance. Identified by an aggregate ID and a partition key.

**Projections**: Read models built by processing event streams. Projections transform events into queryable views optimized for specific read patterns.

**Command Handlers**: Process commands (requests to perform actions) by loading aggregate state from events, executing business logic, and producing new events.

**Event Handlers**: Subscribe to events and perform side effects like updating projections, triggering workflows, or notifying other services.

### How It Works in Microservices

In a microservices architecture, each service maintains its own event store for events it owns. Services communicate through events, creating a distributed event-driven system.

**Write Flow**:

1. Client sends a command (PlaceOrder) to a service
2. Service loads aggregate state by replaying events from the event store
3. Aggregate validates the command and produces new events
4. Events are appended to the event store with optimistic concurrency checks
5. Events are published to a message broker for other services to consume
6. Service updates its projections by applying the new events

**Read Flow**:

1. Client queries a projection (read model) optimized for the specific query
2. Projection returns current state derived from events
3. No event replay needed for reads in normal operation

**Cross-Service Communication**: Services subscribe to events from other services to maintain their own projections or trigger workflows. For example, a Shipping service subscribes to OrderPlaced events from the Order service to initiate shipping processes.

### Event Structure

Events should be self-contained and include all information needed to understand what happened:

```json
{
  "eventId": "uuid-v4",
  "eventType": "OrderPlaced",
  "aggregateId": "order-12345",
  "aggregateType": "Order",
  "version": 3,
  "timestamp": "2024-01-15T10:30:00Z",
  "causationId": "command-uuid",
  "correlationId": "trace-uuid",
  "data": {
    "orderId": "order-12345",
    "customerId": "customer-789",
    "items": [
      {"productId": "prod-1", "quantity": 2, "price": 29.99}
    ],
    "totalAmount": 59.98,
    "currency": "USD",
    "shippingAddress": {
      "street": "123 Main St",
      "city": "Springfield",
      "postalCode": "12345"
    }
  },
  "metadata": {
    "userId": "user-456",
    "ipAddress": "192.168.1.1",
    "userAgent": "Mozilla/5.0..."
  }
}
```

### **Key Points**

- Events are immutable facts that represent something that already happened, never tentative or future actions
- Each aggregate has its own event stream identified by aggregate ID, maintaining consistency within the aggregate boundary
- Event versioning is critical as events live forever; changes must maintain backward compatibility or use upcasting
- The event store is append-only with no updates or deletes, ensuring complete audit trail and temporal queries
- Projections can be rebuilt from scratch by replaying all events, enabling new query patterns without migrating data
- Event ordering within a stream is guaranteed, but global ordering across aggregates requires careful design
- Snapshots optimize performance by caching aggregate state at specific versions, reducing replay cost for long event streams
- Events should capture business intent, not just technical state changes; "OrderPlaced" conveys more meaning than "OrderCreated"

### Benefits in Microservices

**Complete Audit Trail**: Every state change is recorded with full context. You can answer questions like "What was the state on Tuesday?" or "Who changed this and why?"

**Temporal Queries**: Query the system's state at any point in time by replaying events up to that moment. This enables historical analysis and debugging.

**Event-Driven Communication**: Services naturally communicate through events, creating loose coupling and enabling reactive architectures.

**Debugging and Troubleshooting**: Reproduce bugs by replaying the exact sequence of events that led to an issue. No need to reproduce complex user interactions.

**Flexible Read Models**: Create multiple projections optimized for different queries without changing the write model. Add new projections without data migration.

**Business Intelligence**: Events capture business intent and context, providing rich data for analytics and machine learning.

**Microservice Autonomy**: Each service owns its events and can rebuild its state independently without querying other services.

**Natural Event Streaming**: Event store naturally becomes an event stream that other services can consume, reducing need for separate message brokers.

### Challenges and Complexity

**Increased Complexity**: Event sourcing adds conceptual and operational complexity. Teams need to understand event modeling, eventual consistency, and projection management.

**Eventual Consistency**: Projections are updated asynchronously, meaning read models may lag behind writes. Applications must handle stale reads gracefully.

**Event Schema Evolution**: Events are permanent, so schema changes require careful versioning strategies. Breaking changes need upcasting or multiple event versions.

**Debugging Distributed Systems**: While event logs help debugging, understanding distributed flows across multiple services and event streams can be challenging.

**Operational Overhead**: Running event stores, managing projections, monitoring event processing lag, and handling replay operations require specialized knowledge.

**Query Complexity**: Not all queries map naturally to projections. Complex ad-hoc queries may require multiple projections or scanning event streams.

**Storage Growth**: Event stores grow indefinitely. Strategies like snapshotting, archiving old events, or event compaction become necessary over time.

**Learning Curve**: Developers accustomed to CRUD patterns need to shift thinking to event-based modeling, which can slow initial development.

### Event Modeling Best Practices

**Use Domain Events**: Events should reflect business concepts, not technical implementations. "CustomerRelocated" is better than "CustomerAddressUpdated".

**Make Events Immutable**: Never modify or delete events. If a mistake occurs, publish a compensating event that corrects it.

**Include Sufficient Context**: Events should be self-contained with all information needed to process them without external queries.

**Name Events in Past Tense**: Events represent facts that already occurred: OrderPlaced, PaymentProcessed, InventoryReserved.

**Separate Commands from Events**: Commands represent intent (PlaceOrder), events represent facts (OrderPlaced). A command may fail; an event has already happened.

**Use Event Versioning**: Include version numbers in events and maintain backward compatibility or implement upcasting for schema changes.

**Capture Business Intent**: Include why something happened, not just what happened. Record user actions, business rules triggered, and contextual information.

### Projection Strategies

**Single-Writer Projections**: Each projection has one event handler updating it, preventing concurrent writes and ensuring consistency.

**Rebuild Capability**: All projections should be rebuildable from events. This allows fixing bugs, adding new projections, or recovering from corruption.

**Idempotent Processing**: Event handlers must be idempotent since events may be processed multiple times due to retries or replays.

**Multiple Projection Types**: Create different projections for different query patterns rather than forcing complex queries on a single projection.

**Materialized Views**: Store denormalized data optimized for specific queries. For example, a CustomerOrderHistory projection aggregates all orders for quick customer lookups.

**CQRS Integration**: Event Sourcing naturally pairs with Command Query Responsibility Segregation, using events for writes and projections for reads.

### Snapshotting

For aggregates with long event histories, replaying thousands of events becomes expensive. Snapshots cache aggregate state at specific versions:

```json
{
  "aggregateId": "order-12345",
  "aggregateType": "Order",
  "version": 1000,
  "timestamp": "2024-01-15T10:30:00Z",
  "state": {
    "status": "Delivered",
    "items": [...],
    "totalAmount": 59.98,
    ...
  }
}
```

When loading aggregate state:

1. Load the latest snapshot (version 1000)
2. Replay only events after version 1000
3. Apply those events to the snapshot state

**Snapshot Strategies**:

- Take snapshots every N events (every 100 events)
- Take snapshots on time intervals (daily)
- Take snapshots based on size thresholds
- Balance snapshot frequency against storage costs

### Event Versioning and Schema Evolution

Events are permanent, so schema changes must be handled carefully:

**Versioning Approaches**:

**Weak Schema**: Store events as JSON with minimal structure. Easy to evolve but loses type safety and validation.

**Upcasting**: Convert old event versions to new versions when reading. Old events remain unchanged; conversion happens during replay.

**Multiple Versions**: Support multiple event versions simultaneously. New code handles both old and new formats.

**Event Transformation**: Periodically rewrite event streams to new versions, though this loses the immutability benefit.

**Best Practice Pattern**:

```typescript
// Store events with version
{
  "eventType": "OrderPlaced",
  "version": 2,  // Explicit version
  "data": { ... }
}

// Upcast on read
function upcastOrderPlaced(event) {
  if (event.version === 1) {
    // Convert v1 to v2: add new required field
    return {
      ...event,
      version: 2,
      data: {
        ...event.data,
        paymentMethod: 'unknown' // Default for missing field
      }
    };
  }
  return event;
}
```

### **Example**

Consider an e-commerce order service using event sourcing:

**Traditional Approach**:

```sql
-- Orders table stores current state
UPDATE orders 
SET status = 'Shipped', shipped_at = NOW() 
WHERE order_id = '12345';

-- Lost information:
-- - When was it packed?
-- - Who approved shipping?
-- - What triggered the shipping?
-- - Was there a delay?
```

**Event Sourcing Approach**:

Event stream for Order aggregate "12345":

```
1. OrderPlaced (version 1)
   - customerId: "customer-789"
   - items: [...]
   - totalAmount: 59.98
   - timestamp: "2024-01-15T10:30:00Z"

2. PaymentAuthorized (version 2)
   - paymentId: "pay-456"
   - amount: 59.98
   - method: "credit_card"
   - timestamp: "2024-01-15T10:30:05Z"

3. InventoryReserved (version 3)
   - items: [{"productId": "prod-1", "quantity": 2}]
   - warehouseId: "warehouse-east"
   - timestamp: "2024-01-15T10:30:10Z"

4. OrderPacked (version 4)
   - packedBy: "employee-321"
   - warehouseId: "warehouse-east"
   - trackingNumber: "TRACK123"
   - timestamp: "2024-01-15T14:20:00Z"

5. OrderShipped (version 5)
   - carrier: "FedEx"
   - trackingNumber: "TRACK123"
   - estimatedDelivery: "2024-01-17"
   - timestamp: "2024-01-15T16:00:00Z"

6. OrderDelivered (version 6)
   - deliveredAt: "2024-01-17T11:30:00Z"
   - signedBy: "Jane Doe"
   - timestamp: "2024-01-17T11:30:00Z"
```

**Command Handler Example**:

```typescript
class OrderCommandHandler {
  async handleShipOrder(command: ShipOrderCommand) {
    // Load aggregate from events
    const order = await this.loadOrder(command.orderId);
    
    // Validate business rules
    if (order.status !== 'Packed') {
      throw new Error('Order must be packed before shipping');
    }
    
    // Produce event
    const event = new OrderShippedEvent({
      orderId: command.orderId,
      carrier: command.carrier,
      trackingNumber: command.trackingNumber,
      estimatedDelivery: command.estimatedDelivery,
      timestamp: new Date()
    });
    
    // Append to event store
    await this.eventStore.append(
      command.orderId,
      [event],
      expectedVersion: order.version // Optimistic concurrency
    );
    
    // Publish for other services
    await this.eventBus.publish(event);
  }
  
  async loadOrder(orderId: string): Promise<Order> {
    // Load snapshot if available
    const snapshot = await this.eventStore.getSnapshot(orderId);
    const startVersion = snapshot ? snapshot.version : 0;
    
    // Load events after snapshot
    const events = await this.eventStore.getEvents(
      orderId,
      fromVersion: startVersion
    );
    
    // Reconstruct state
    const order = snapshot 
      ? Order.fromSnapshot(snapshot)
      : new Order();
    
    events.forEach(event => order.apply(event));
    
    return order;
  }
}
```

**Projection Example** - Customer Order History:

```typescript
class CustomerOrderHistoryProjection {
  async handleOrderPlaced(event: OrderPlacedEvent) {
    await this.db.query(`
      INSERT INTO customer_order_history 
      (customer_id, order_id, order_date, total_amount, status)
      VALUES ($1, $2, $3, $4, 'placed')
    `, [event.customerId, event.orderId, event.timestamp, event.totalAmount]);
  }
  
  async handleOrderShipped(event: OrderShippedEvent) {
    await this.db.query(`
      UPDATE customer_order_history 
      SET status = 'shipped',
          tracking_number = $1,
          estimated_delivery = $2
      WHERE order_id = $3
    `, [event.trackingNumber, event.estimatedDelivery, event.orderId]);
  }
  
  async handleOrderDelivered(event: OrderDeliveredEvent) {
    await this.db.query(`
      UPDATE customer_order_history 
      SET status = 'delivered',
          delivered_at = $1
      WHERE order_id = $2
    `, [event.deliveredAt, event.orderId]);
  }
}
```

**Cross-Service Integration**:

The Shipping service subscribes to OrderPacked events:

```typescript
class ShippingService {
  async handleOrderPacked(event: OrderPackedEvent) {
    // Create shipping label
    const label = await this.shippingProvider.createLabel({
      orderId: event.orderId,
      warehouse: event.warehouseId,
      ...
    });
    
    // Publish ShippingLabelCreated event
    await this.eventBus.publish(new ShippingLabelCreatedEvent({
      orderId: event.orderId,
      labelId: label.id,
      trackingNumber: label.trackingNumber
    }));
  }
}
```

The Inventory service subscribes to OrderPlaced events:

```typescript
class InventoryService {
  async handleOrderPlaced(event: OrderPlacedEvent) {
    for (const item of event.items) {
      const reserved = await this.reserveInventory(
        item.productId,
        item.quantity
      );
      
      if (reserved) {
        await this.eventBus.publish(new InventoryReservedEvent({
          orderId: event.orderId,
          productId: item.productId,
          quantity: item.quantity
        }));
      } else {
        await this.eventBus.publish(new InventoryReservationFailedEvent({
          orderId: event.orderId,
          productId: item.productId,
          reason: 'insufficient_stock'
        }));
      }
    }
  }
}
```

### **Output**

**Benefits Realized**:

- Complete audit trail of every order state change with timestamps and actors
- Ability to answer "What was the order status on January 16?" by replaying events
- Easy debugging: replay exact sequence of events that led to any issue
- New projections added without touching write model (e.g., "Average time from packed to shipped")
- Services loosely coupled through events rather than direct API calls
- Business intelligence: analyze patterns like "Why do orders take longer to ship on Mondays?"

**Operational Metrics**:

- Event append time: 5-10ms
- Projection lag: 100-500ms for real-time projections
- Aggregate load time (with snapshots): 20-50ms for typical orders
- Storage: ~500 bytes per event, ~50 events per order lifecycle = 25KB per order

### Integration Patterns

**Event Store as Message Broker**: Some event stores (like Kafka) serve dual purpose as both storage and message broker, simplifying architecture.

**Outbox Pattern**: Ensure events are published atomically with database commits by writing to an outbox table, then publishing asynchronously.

**Event Transformation**: Gateway services can transform external events into domain events or vice versa for cross-system integration.

**Event Replay Endpoints**: Provide administrative endpoints to replay events for specific aggregates or projections for debugging or recovery.

### Monitoring and Operations

**Key Metrics to Track**:

- Event append throughput and latency
- Projection lag (time between event creation and projection update)
- Event processing errors and dead letter queue sizes
- Event store disk usage and growth rate
- Aggregate snapshot hit rates
- Command processing latency

**Operational Procedures**:

- Projection rebuild procedures and estimated time windows
- Event archiving strategies for old events
- Disaster recovery and backup procedures for event stores
- Monitoring dashboards showing event flows across services
- Alerting on projection lag exceeding thresholds

### Testing Strategies

**Unit Tests**: Test aggregate behavior by giving events as input and asserting expected events as output.

**Integration Tests**: Test event handlers and projections by publishing test events and verifying state changes.

**Event Replay Tests**: Test projection rebuilds by replaying production events against new projection code.

**Property-Based Tests**: Generate random event sequences and verify invariants always hold.

**Contract Tests**: Verify event schemas match contracts between producers and consumers.

### When to Use Event Sourcing

Event Sourcing is valuable when:

- Audit trail and compliance are critical requirements
- You need temporal queries or historical state reconstruction
- Business processes are naturally event-driven
- Multiple services need to react to state changes
- Debugging complex workflows requires event replay
- You're building a microservices architecture with service autonomy
- Domain experts think in terms of events and workflows

### When to Avoid Event Sourcing

Consider simpler alternatives when:

- Application is primarily CRUD with simple state management
- Team lacks experience with event-driven architectures and eventual consistency
- Strong consistency and immediate read-after-write are required
- Infrastructure complexity is already overwhelming
- Domain model is simple and doesn't benefit from event history
- Query patterns don't map well to projections and require complex ad-hoc queries

### Migration Strategies

**Greenfield**: Start with event sourcing from the beginning, designing aggregates and events first.

**Strangler Pattern**: Gradually migrate existing services to event sourcing, running old and new systems in parallel.

**Event Capture**: Wrap existing system and capture state changes as events, building event store gradually.

**Hybrid Approach**: Use event sourcing only for specific aggregates or bounded contexts where benefits justify complexity.

### **Conclusion**

Event Sourcing provides powerful capabilities for microservices architectures, particularly around audit trails, temporal queries, and event-driven communication. The pattern naturally aligns with domain-driven design and enables service autonomy through event-based integration. However, it introduces significant complexity around eventual consistency, projection management, and operational concerns.

[Inference] The pattern appears most successful when teams have strong domain modeling skills, understand eventual consistency trade-offs, and have clear requirements for audit trails or event replay. The decision to adopt event sourcing should be driven by specific business needs rather than architectural trends, and teams should be prepared for the increased operational complexity it brings.

### **Next Steps**

- Evaluate whether your use cases genuinely benefit from event sourcing's capabilities (audit trail, temporal queries, event-driven integration)
- Assess team readiness for event-driven architecture and eventual consistency patterns
- Start with a pilot on a bounded context where event sourcing provides clear value and risk is contained
- Choose an appropriate event store technology based on your infrastructure, scale, and team expertise (EventStoreDB for pure event sourcing, Kafka for high throughput, PostgreSQL for familiarity)
- Design event schemas carefully with versioning strategy from the start to avoid painful migrations later
- Build monitoring and operational procedures for projection management, event replay, and debugging distributed flows
- Consider CQRS alongside event sourcing to separate write models (events) from read models (projections)
- Train team on event modeling techniques, domain-driven design, and eventual consistency patterns before production use

---

## Service Registry

Service registry is a critical component in microservices architecture that acts as a centralized directory for service instances, enabling dynamic service discovery and load balancing in distributed systems. It maintains a real-time catalog of available service instances, their locations, health status, and metadata.

### Understanding Service Registry

A service registry is a database of service instances and their network locations. As services start, they register themselves with the registry. When services need to communicate with other services, they query the registry to discover available instances. The registry continuously monitors service health and removes unavailable instances from its catalog.

### Why Service Registry is Essential

**Dynamic Service Discovery**

- Services can find each other without hardcoded addresses
- New instances are automatically discoverable
- Failed instances are automatically removed
- Supports elastic scaling

**Decoupling**

- Services don't need to know exact locations of dependencies
- Configuration changes don't require code updates
- Supports multiple environments without reconfiguration

**Load Distribution**

- Registry provides multiple instance locations for load balancing
- Clients can choose instances based on various strategies
- Enables geographic routing and affinity

**Resilience**

- Automatic failover to healthy instances
- Health checking removes problematic instances
- Supports graceful shutdowns and rolling deployments

### Core Components

#### Service Registry Database

Stores information about service instances:

- Service name and version
- Network location (IP address, port)
- Health status
- Metadata (tags, region, load, capabilities)
- Registration timestamp

#### Registration Mechanism

How services register themselves:

- Self-registration - services register directly
- Third-party registration - external process registers services
- Registration API endpoints
- Authentication and authorization

#### Discovery Mechanism

How clients find services:

- Client-side discovery - clients query registry
- Server-side discovery - load balancer queries registry
- DNS-based discovery
- API calls to registry

#### Health Checking

Monitors service availability:

- Heartbeat mechanism - services send periodic signals
- Active health checks - registry polls services
- Passive health checks - monitor actual requests
- Configurable check intervals and timeouts

### Service Registry Patterns

#### Self-Registration Pattern

Services register themselves directly with the registry when they start up.

**How It Works:**

1. Service starts up
2. Service calls registration API with its details
3. Service sends periodic heartbeats to maintain registration
4. Service deregisters when shutting down gracefully

**Key Points:**

- Services are responsible for registration lifecycle
- Requires service code to include registration logic
- More control over registration metadata
- Services must handle registration failures

**Example:** A Node.js service registering with Consul:

```javascript
const consul = require('consul')();

async function registerService() {
  await consul.agent.service.register({
    name: 'payment-service',
    id: 'payment-service-1',
    address: '10.0.1.45',
    port: 8080,
    tags: ['v1', 'production'],
    check: {
      http: 'http://10.0.1.45:8080/health',
      interval: '10s',
      timeout: '5s'
    }
  });
}

// On shutdown
process.on('SIGTERM', async () => {
  await consul.agent.service.deregister('payment-service-1');
  process.exit(0);
});
```

**Output:** Service appears in Consul catalog immediately upon registration. Health checks run every 10 seconds. If health check fails 3 times, service is marked unhealthy. On graceful shutdown, service is removed from catalog.

#### Third-Party Registration Pattern

An external component (service registrar) monitors service instances and registers them.

**How It Works:**

1. Service starts without registration logic
2. External registrar detects new service (via Docker events, Kubernetes API, etc.)
3. Registrar registers service with registry
4. Registrar monitors service health
5. Registrar deregisters service when it stops

**Key Points:**

- Services don't need registration code
- Centralized registration logic
- Better suited for container orchestration platforms
- Registrar is a potential single point of failure

**Example:** Using Registrator with Docker and Consul:

- Registrator runs as Docker container
- Monitors Docker daemon for container events
- Automatically registers containers with Consul
- Uses container metadata for service information
- Deregisters when containers stop

**Output:** When a Docker container with label `SERVICE_NAME=order-service` starts, Registrator automatically registers it in Consul with the service name, container IP, exposed port, and health check endpoint.

#### Client-Side Discovery Pattern

Clients query the registry directly and choose which instance to call.

**How It Works:**

1. Client needs to call a service
2. Client queries service registry for available instances
3. Client selects an instance (using load balancing algorithm)
4. Client calls selected instance directly
5. Client handles failures and retries

**Key Points:**

- Client controls load balancing logic
- No additional network hops
- Clients coupled to registry
- Clients must implement discovery logic

**Example:** Java client using Netflix Eureka:

```java
@Autowired
private DiscoveryClient discoveryClient;

public String callOrderService() {
    List<ServiceInstance> instances = 
        discoveryClient.getInstances("order-service");
    
    if (instances.isEmpty()) {
        throw new ServiceUnavailableException("No instances available");
    }
    
    // Simple round-robin selection
    ServiceInstance instance = instances.get(
        new Random().nextInt(instances.size())
    );
    
    String url = String.format("http://%s:%d/orders",
        instance.getHost(), instance.getPort());
    
    return restTemplate.getForObject(url, String.class);
}
```

**Output:** Client receives list of 3 order-service instances from Eureka, randomly selects one, and makes HTTP request directly to that instance. If request fails, client is responsible for retry logic or selecting another instance.

#### Server-Side Discovery Pattern

Clients make requests to a load balancer, which queries the registry and routes requests.

**How It Works:**

1. Client makes request to load balancer
2. Load balancer queries service registry
3. Load balancer selects healthy instance
4. Load balancer forwards request to instance
5. Load balancer returns response to client

**Key Points:**

- Clients don't need discovery logic
- Centralized load balancing
- Load balancer can be single point of failure
- Additional network hop

**Example:** Using AWS Application Load Balancer with ECS Service Discovery:

- Services register with AWS Cloud Map
- ALB target groups dynamically populated from Cloud Map
- Client calls ALB endpoint: `http://api.example.com/orders`
- ALB routes to healthy order-service instances
- Client unaware of individual instances

**Output:** Client makes single request to `api.example.com`. ALB queries Cloud Map, finds 5 healthy order-service instances, applies round-robin algorithm, forwards request to `10.0.3.22:8080`, and returns response to client. Total latency: 45ms (5ms ALB routing + 40ms service processing).

### Popular Service Registry Implementations

#### Consul

HashiCorp's service mesh solution with built-in service registry.

**Features:**

- Multi-datacenter support
- Health checking (HTTP, TCP, script-based)
- Key-value store
- Service mesh capabilities
- DNS interface for discovery
- Web UI for visualization

**Registration Example:**

```json
{
  "service": {
    "name": "user-service",
    "port": 8080,
    "tags": ["v2", "production"],
    "meta": {
      "version": "2.1.0",
      "region": "us-east-1"
    },
    "check": {
      "http": "http://localhost:8080/health",
      "interval": "10s"
    }
  }
}
```

**Discovery Example:**

```bash
