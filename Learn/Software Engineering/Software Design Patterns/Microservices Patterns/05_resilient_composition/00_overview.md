## Overview


Resilient composition took 0.215s Product: Wireless Headphones Successfully composed despite any service failures

```

**Conclusion:**

API composition provides an essential pattern for aggregating data from distributed microservices into cohesive responses for clients. By orchestrating calls to multiple backend services and merging their results, composition layers simplify client interactions and shield them from the complexity of distributed architectures. This pattern enables microservices to maintain clear domain boundaries while still presenting unified interfaces.

The effectiveness of API composition depends heavily on implementation details. Sequential composition is simple but accumulates latency, while parallel composition significantly improves performance by executing independent calls concurrently. Caching strategies further enhance performance by eliminating redundant service calls, though they introduce consistency considerations. Graceful degradation with fallbacks maintains functionality during partial outages, trading some data completeness for system resilience.

Success with API composition requires careful attention to error handling, timeout management, monitoring, and testing. Circuit breakers prevent cascading failures, distributed tracing provides visibility into complex call chains, and comprehensive testing validates both happy paths and failure scenarios. Security considerations around authentication propagation and authorization enforcement cannot be overlooked.

While API composition adds a coordination layer that could become a bottleneck, proper implementation with parallel execution, caching, and horizontal scaling addresses most performance concerns. The pattern remains particularly valuable in microservices architectures where domain boundaries necessitate distributed data ownership but clients need cohesive views.

**Next Steps:**

1. Identify client use cases that require data from multiple services and would benefit from composition
2. Choose appropriate composition patterns based on latency requirements and data dependencies
3. Implement parallel composition for independent service calls to minimize response times
4. Add response caching with appropriate TTLs based on data volatility and consistency needs
5. Implement circuit breakers and timeouts to prevent cascading failures from unhealthy services
6. Set up distributed tracing to visualize composition flows and identify performance bottlenecks
7. Create comprehensive tests including contract tests to catch breaking changes in backend services
8. Monitor composition metrics including latency percentiles, error rates, and cache hit rates
9. Implement graceful degradation strategies distinguishing between critical and optional data sources
10. Consider Backend for Frontend pattern if different client types need specialized composition logic

---

## CQRS in Microservices

Command Query Responsibility Segregation (CQRS) is an architectural pattern that separates read operations (queries) from write operations (commands) by using different models for updating and reading data. In microservices architectures, CQRS provides a powerful approach to handle complex domain logic, scale read and write operations independently, and optimize each side for its specific purpose.

### Core Concept

CQRS fundamentally challenges the assumption that the same model should be used for both reading and writing data. Traditional CRUD (Create, Read, Update, Delete) applications use a single unified model where the same entities and database schema serve both operations. CQRS proposes splitting this into two distinct models: a command model optimized for writes and business logic enforcement, and a query model optimized for reads and data retrieval.

In a microservices context, this separation becomes even more powerful. Each microservice can implement CQRS independently based on its specific needs. A service handling complex business transactions benefits from the command side's focus on consistency and validation, while the query side can use denormalized views, caching, and read replicas to serve high-volume read requests efficiently.

The pattern emerged from Domain-Driven Design (DDD) practices where complex business domains require sophisticated write models with rich behavior and validation, but read operations need simple, fast access to data in formats optimized for specific use cases. Rather than forcing both concerns into a single model, CQRS acknowledges their different requirements and treats them separately.

### Problem Statement

Microservices face several challenges that CQRS addresses:

**Conflicting Requirements**: Write operations require strong consistency, complex validation, business rule enforcement, and transactional integrity. Read operations prioritize speed, simplicity, denormalized data, and the ability to serve many concurrent requests. A single model cannot optimize for both concerns simultaneously.

**Performance Bottlenecks**: In most systems, reads significantly outnumber writes (often by a ratio of 100:1 or more). Traditional architectures force read operations to work with database schemas designed for transactional writes, leading to complex joins, poor query performance, and unnecessary overhead.

**Scalability Constraints**: Read and write workloads have different scaling characteristics. Writes often require coordination, locks, and consistency checks that limit horizontal scaling. Reads can be distributed across multiple replicas without coordination. A unified model prevents independent scaling of these different workloads.

**Complex Query Requirements**: UI and reporting needs often require data aggregated from multiple entities or even multiple microservices. Building these views from normalized transactional databases involves expensive joins and complex queries that impact performance.

**Stale Data Tolerance**: Many read operations can tolerate slightly stale data (eventual consistency), but this optimization is impossible when reads query the same database that writes are actively modifying with strict consistency requirements.

**Impedance Mismatch**: Object-relational mapping (ORM) frameworks struggle to efficiently handle both complex write operations with aggregate roots and rich domain logic, and simple read operations that need denormalized data in specific formats.

### Solution Architecture

CQRS in microservices implements a clear separation between commands and queries:

**Command Side (Write Model)**: The command side handles all operations that change state. Commands represent intentions to perform actions (PlaceOrder, UpdateInventory, CancelSubscription). Each command is validated against business rules, processed through domain logic, and results in events that capture what happened. The write model uses a normalized database schema designed for transactional integrity, with entities that enforce invariants and maintain consistency.

**Query Side (Read Model)**: The query side handles all read operations. It maintains one or more read models (also called projections or views) that are optimized for specific query patterns. These models are denormalized, can use different database technologies, and are updated asynchronously based on events from the command side. Queries simply retrieve data without triggering business logic or validation.

**Event-Based Synchronization**: Events form the bridge between command and query sides. When the command side processes a command successfully, it publishes events describing what changed. The query side listens to these events and updates its read models accordingly. This asynchronous propagation means the query side operates under eventual consistency.

**Independent Scaling**: Because the sides are separate, they can scale independently. The command side might run on a few instances with powerful processors for complex business logic, while the query side runs on many instances with read replicas to handle high query volumes.

**Different Data Stores**: The command and query sides can use different database technologies. The command side might use a relational database for transactional consistency, while the query side uses document databases, search engines, or caches optimized for specific query patterns.

### Command Side Architecture

The command side focuses on business logic and state changes:

**Command Objects**: Commands are explicit objects representing user intentions. A command might be `PlaceOrderCommand` with properties like customerId, items, shippingAddress, and paymentMethod. Commands are validated before processing to ensure they contain all required information and meet basic format requirements.

**Command Handlers**: Each command type has a corresponding handler that contains the business logic to process that command. The handler loads the relevant domain aggregate, executes business rules, and persists changes if validation succeeds.

**Domain Aggregates**: Aggregates encapsulate business logic and enforce invariants. An Order aggregate ensures items are in stock, calculates totals correctly, applies discounts according to business rules, and prevents invalid state transitions. Aggregates maintain consistency boundaries within their scope.

**Event Sourcing (Optional)**: Many CQRS implementations use event sourcing on the command side, where aggregates are persisted as sequences of events rather than current state snapshots. This provides complete audit trails, temporal queries, and the ability to rebuild state from history.

**Write Database**: The command side database is optimized for transactional writes. It typically uses a relational database with normalized schemas, foreign key constraints, and ACID transactions to ensure consistency.

**Event Publishing**: After successfully processing a command, the handler publishes domain events to an event bus or message broker. These events notify other parts of the system (including the query side) about what changed.

### Query Side Architecture

The query side focuses on efficient data retrieval:

**Query Objects**: Queries are simple request objects specifying what data is needed. Unlike commands, queries don't change state and don't require complex validation. A query might be `GetOrdersByCustomerQuery` with a customerId parameter.

**Query Handlers**: Query handlers retrieve data from read models without executing business logic. They perform simple lookups, apply filtering and pagination, and return data in the exact format needed by the client.

**Read Models (Projections)**: The query side maintains one or more read models, each optimized for specific query patterns. For example, an e-commerce system might have separate read models for product catalogs, customer order history, inventory availability, and sales analytics. Each read model is denormalized and pre-computed for fast retrieval.

**Event Subscribers**: Event subscribers listen to domain events published by the command side. When events arrive, subscribers update the relevant read models. For example, when an OrderPlacedEvent is published, subscribers might update the customer's order history, decrement inventory counts, and add data to analytics tables.

**Read Database**: Read models can use different database technologies optimized for specific query patterns. Document databases like MongoDB work well for hierarchical data, search engines like Elasticsearch excel at full-text search, and Redis provides fast key-value lookups.

**Materialized Views**: Some read models are essentially materialized views that pre-compute complex aggregations, joins, and calculations. Instead of computing these on-the-fly for each query, they're updated incrementally as events arrive.

### Event-Driven Communication

Events are central to CQRS in microservices:

**Domain Events**: These represent facts about things that happened in the business domain. Events are immutable, past-tense facts like OrderPlaced, PaymentProcessed, or InventoryReduced. They contain all relevant information about what occurred, including identifiers, timestamps, and changed data.

**Event Bus**: An event bus or message broker (Kafka, RabbitMQ, AWS SNS/SQS, Azure Service Bus) facilitates communication between command and query sides. The command side publishes events to the bus, and the query side subscribes to relevant events.

**Event Ordering**: For some use cases, event ordering matters. The event bus must guarantee that events from the same aggregate are processed in order. Partition keys or message groups can ensure ordered delivery.

**Idempotency**: Event handlers on the query side must be idempotent since events might be delivered multiple times due to retries. Handlers track processed events using unique event IDs to avoid duplicate processing.

**Event Schema Evolution**: As the system evolves, event schemas change. Versioning strategies allow new event subscribers to handle both old and new event formats, ensuring backward compatibility.

**Multiple Event Subscribers**: Different read models can subscribe to the same events, each extracting relevant information to maintain their specific views. This allows adding new read models without changing the command side.

### Implementation Patterns in Microservices

**Per-Service CQRS**: Each microservice independently decides whether to implement CQRS based on its complexity. Simple services might use traditional CRUD, while complex services with heavy read loads implement full CQRS with separate command and query models.

**Cross-Service Queries**: When a query needs data from multiple microservices, the query side can maintain a read model that aggregates data from multiple command services. Event subscribers listen to events from all relevant services and build a denormalized view.

**API Composition**: Some queries combine data from multiple services at the API Gateway level rather than maintaining a dedicated read model. This works for simple cases but can become inefficient for complex queries or high traffic.

**Service-Specific Read Models**: Different services can maintain their own read models of data owned by other services. When Service A publishes events about its entities, Service B can subscribe and maintain a local read-only cache of relevant data for efficient local queries.

**Shared Query Services**: Dedicated query services can aggregate data from multiple command services and expose optimized query APIs. These services have no command side and exist purely to serve read requests efficiently.

### Eventual Consistency Management

CQRS introduces eventual consistency between command and query sides:

**Consistency Lag**: There's a time delay between when a command succeeds and when the query side reflects those changes. This lag depends on event processing speed, message broker latency, and read model update complexity.

**User Experience Considerations**: Users expect to see their own changes immediately. After creating an order, a user shouldn't see "no orders found." Several patterns address this:

- **Optimistic UI Updates**: The client updates its local state immediately after sending a command, without waiting for the query side to update.
- **Read-Your-Writes Consistency**: After a command succeeds, return the new state directly in the response, or track which version the user wrote and ensure queries return at least that version.
- **Version Tracking**: Include version numbers or timestamps in responses and queries to ensure clients receive data at least as recent as their last write.

**Eventual Consistency Guarantees**: While the query side eventually becomes consistent with the command side, the system provides guarantees about maximum lag times, event ordering, and data completeness.

**Compensating Actions**: When business rules are violated after eventual consistency reveals conflicts (e.g., overbooking when two commands succeed but the aggregate query shows insufficient inventory), compensating actions correct the inconsistency through additional commands.

### Benefits in Microservices

**Independent Scalability**: Command and query sides scale independently based on their specific loads. A service with 1% writes and 99% reads can run one command instance and many query instances with multiple read replicas.

**Performance Optimization**: Each side uses data structures and databases optimized for its purpose. The query side can use denormalized data, caching, indexes optimized for specific queries, and even different database technologies without affecting the command side.

**Flexibility in Data Representation**: The same data can be represented in multiple ways on the query side. Product data might be stored as detailed documents for product pages, as search indices for search functionality, and as aggregated data for analytics, all derived from the same command-side events.

**Simplified Query Logic**: Queries become trivial lookups against pre-computed views rather than complex joins across normalized tables. This improves performance and reduces the chance of errors in query construction.

**Better Domain Modeling**: The command side can focus purely on business logic and invariant enforcement without concerns about query performance. Domain models remain clean and encapsulate business rules without query-related compromises.

**Temporal Queries**: When combined with event sourcing, CQRS enables querying historical states, understanding how data changed over time, and replaying events to rebuild state or create new projections.

**Technology Diversity**: Different services can use different technologies for command and query sides based on their specific needs. One service might use PostgreSQL and Elasticsearch, while another uses MongoDB and Redis.

**Read Model Evolution**: New read models can be added without touching the command side. If a new reporting requirement emerges, create a new event subscriber and build a read model optimized for those reports.

### Challenges and Drawbacks

**Increased Complexity**: CQRS adds significant architectural complexity. Instead of one model, there are two (or more) models to design, implement, test, and maintain. The system has more moving parts with event publishing, subscribers, and eventual consistency to manage.

**Eventual Consistency**: Applications must handle the fact that query results might not reflect recent commands. This requires careful UX design and sometimes additional patterns like read-your-writes consistency.

**Operational Overhead**: More components mean more infrastructure to deploy, monitor, and maintain. Event buses, multiple databases, event subscribers, and read model rebuilding processes all require operational attention.

**Debugging Difficulty**: Tracing requests through command handlers, event publishing, event processing, and read model updates is more complex than following a single execution path. Distributed tracing and comprehensive logging become essential.

**Data Duplication**: The same information exists in both the command-side database and query-side read models, consuming more storage and requiring synchronization mechanisms.

**Event Schema Management**: As events evolve, maintaining compatibility between event publishers and subscribers across system versions requires careful versioning and migration strategies.

**Read Model Rebuilding**: If a read model becomes corrupted or needs to be redesigned, rebuilding it from events can take significant time for systems with large event histories.

**Testing Complexity**: Testing requires verifying both command processing and eventual propagation to query models. Integration tests must account for asynchronous event processing and eventual consistency.

### When to Use CQRS

CQRS is not appropriate for every microservice. Consider CQRS when:

**Complex Business Logic**: The service has rich domain logic with many business rules, invariants, and validations that must be enforced consistently.

**Read/Write Imbalance**: Read operations significantly outnumber write operations (ratios of 10:1 or higher), justifying the complexity of separate optimization.

**Different Query Patterns**: The service needs to support many different query patterns that would be difficult to optimize with a single database schema.

**Performance Requirements**: Query performance is critical and cannot be met with traditional approaches using normalized databases and complex joins.

**Scalability Needs**: Read and write loads need to scale independently, with different scaling characteristics.

**Multiple Representations**: The same data needs to be presented in fundamentally different ways for different use cases (detailed views, search, analytics, reporting).

**Event Sourcing Benefits**: The service would benefit from event sourcing's audit trail, temporal queries, and ability to rebuild state.

Avoid CQRS when:

- The service has simple CRUD operations without complex business logic
- Read and write loads are similar or both are low
- The added complexity isn't justified by the benefits
- The team lacks experience with event-driven architectures and eventual consistency
- Strong consistency between reads and writes is absolutely required

### Implementation Technologies

**Event Stores**:

- EventStoreDB: Purpose-built for event sourcing with native event streaming
- Apache Kafka: Distributed streaming platform that can serve as both event store and event bus
- AWS DynamoDB Streams: For AWS-based systems using DynamoDB
- Custom implementations using relational databases with event tables

**Message Brokers**:

- Apache Kafka: High-throughput, distributed, durable message broker
- RabbitMQ: Feature-rich message broker with flexible routing
- AWS SNS/SQS: Managed pub/sub and queueing services
- Azure Service Bus: Enterprise message broker with advanced features
- Google Cloud Pub/Sub: Scalable messaging service

**Command/Query Frameworks**:

- Axon Framework (Java): Comprehensive CQRS and event sourcing framework
- MediatR (.NET): Mediator pattern implementation for CQRS
- NServiceBus (.NET): Messaging framework supporting CQRS patterns
- Lagom (Java/Scala): Reactive microservices framework with CQRS support
- Eventuate: Event sourcing and CQRS framework for microservices

**Read Model Databases**:

- Elasticsearch: Full-text search and analytics
- MongoDB: Document database for hierarchical data
- Redis: In-memory cache for fast lookups
- PostgreSQL: Relational database with excellent JSON support
- Cassandra: Wide-column store for time-series and high-volume data

### Design Considerations

**Aggregate Boundaries**: Carefully design aggregate boundaries on the command side. Aggregates should represent consistency boundaries that enforce invariants within a single transaction. Cross-aggregate operations use eventual consistency through events.

**Event Granularity**: Design events at appropriate granularity. Too fine-grained events create noise and increase processing overhead. Too coarse-grained events make it difficult for subscribers to extract needed information. Events should represent complete business facts.

**Idempotent Event Handlers**: All event handlers must be idempotent to handle duplicate event delivery. Track processed event IDs, use upsert operations, or design handlers so that processing the same event multiple times produces the same result.

**Read Model Versioning**: Plan for read model evolution. As requirements change, old read models might need to coexist with new ones during transitions. Version read model schemas and provide migration paths.

**Command Validation**: Validate commands at multiple levels. Basic validation (required fields, format) happens immediately. Business rule validation happens in the aggregate. Some validations might need to be eventually consistent.

**Query API Design**: Design query APIs around client needs rather than database structure. Each read model can expose APIs optimized for specific use cases without exposing underlying storage details.

**Error Handling**: Distinguish between business rule violations (which return error responses to clients) and technical failures (which might require retries, circuit breakers, or fallback strategies).

**Monitoring and Observability**: Implement comprehensive monitoring for command processing times, event publishing delays, event processing lag, read model freshness, and error rates across the entire pipeline.

### Event Sourcing Integration

CQRS and event sourcing are often used together, though they're independent patterns:

**Event-Sourced Command Side**: Instead of storing current state, the command side stores all events that led to that state. Aggregates are reconstituted by replaying events. This provides complete audit trails, temporal queries, and the ability to fix bugs by replaying events with corrected logic.

**Snapshot Optimization**: For aggregates with long event histories, snapshots store periodic state checkpoints. Rebuilding starts from the latest snapshot and applies subsequent events, avoiding replay of thousands of events.

**Event Store as Source of Truth**: The event store becomes the system of record. Both command-side state and query-side read models are derived from events and can be rebuilt if corrupted or redesigned.

**Replay Capability**: Read models can be rebuilt or new projections created by replaying historical events. This allows adding new read models without migration scripts or fixing read models that were incorrectly updated.

**Temporal Queries**: Event sourcing enables querying what state was at any point in history, useful for compliance, debugging, and analyzing how situations evolved.

### Security Considerations

**Command Authorization**: Validate that users have permission to execute specific commands. This typically happens before command processing, checking user roles and permissions against the requested operation.

**Query Authorization**: Control access to read models based on user permissions. Different users might see different subsets of data from the same read model based on their authorization level.

**Event Data Sensitivity**: Events might contain sensitive data that should be encrypted at rest and in transit. Consider which subscribers need access to which events and implement appropriate access controls.

**Audit Logging**: CQRS naturally provides audit logs through events, but ensure sensitive operations are logged with sufficient detail for compliance requirements.

**Personal Data Management**: GDPR and similar regulations require the ability to delete personal data. In event-sourced systems, this might require event encryption with user-specific keys or designing events to avoid storing personal data directly.

### Testing Strategies

**Unit Testing Commands**: Test command handlers in isolation by providing specific aggregate states and verifying that correct events are produced and business rules are enforced.

**Unit Testing Queries**: Test query handlers by providing known read model state and verifying correct data retrieval and transformation.

**Integration Testing Events**: Test event publishing and subscription by executing commands and verifying that read models are updated correctly within a reasonable timeout.

**Contract Testing**: Verify that event schemas match expectations between publishers and subscribers, catching breaking changes before deployment.

**Consistency Testing**: Test scenarios where eventual consistency matters, verifying that the system eventually reaches the expected state and handles the consistency lag appropriately.

**Performance Testing**: Load test both command and query sides independently to verify they meet performance requirements and scale appropriately.

### Migration Strategies

**Strangler Pattern**: Gradually migrate from a traditional architecture to CQRS by routing increasing percentages of traffic to the new implementation while keeping the old system running.

**Shadow Mode**: Run CQRS implementation in parallel with the existing system, processing the same commands but not serving queries. Verify correctness before switching query traffic.

**Parallel Writes**: Write to both old and new systems during transition, reading from the old system until confidence is high, then switch to reading from CQRS read models.

**Service-by-Service Migration**: In microservices architectures, migrate one service at a time rather than the entire system, reducing risk and allowing teams to learn from experience.

**Read Model Migration**: When changing read model structure, deploy new event subscribers alongside old ones, build the new read model from events, verify correctness, then switch queries to the new model.

### Common Pitfalls

**Premature Optimization**: Implementing CQRS for simple services that don't need it adds unnecessary complexity without benefits. Start simple and add CQRS when requirements justify the complexity.

**Shared Databases**: Allowing both command and query sides to access the same database defeats the purpose of separation. Events should be the only communication channel between sides.

**Business Logic in Query Handlers**: Query handlers should only retrieve and format data, never execute business logic or validation. All business logic belongs on the command side.

**Ignoring Eventual Consistency**: Designing UX that assumes immediate consistency causes confusion and bugs. Design interfaces that gracefully handle the lag between writes and reads.

**Event Versioning Neglect**: Not planning for event schema evolution leads to breaking changes that require system-wide coordinated deployments. Design events with versioning from the start.

**Monolithic Read Models**: Creating one giant read model that serves all queries misses the point of CQRS. Create multiple specialized read models optimized for specific query patterns.

**Insufficient Monitoring**: Without proper monitoring of event lag, processing errors, and read model health, problems in the asynchronous pipeline go unnoticed until they cause user-visible failures.

**Key Points**

- CQRS separates read operations from write operations using different models optimized for each purpose
- The command side handles state changes through validated commands, domain logic, and event publication
- The query side maintains denormalized read models updated asynchronously from command-side events
- Events form the integration mechanism between command and query sides, enabling eventual consistency
- Command and query sides can scale independently and use different database technologies
- CQRS works particularly well in microservices where services can independently choose whether to implement it
- The pattern introduces eventual consistency, requiring careful UX design and consistency management
- CQRS is most beneficial for services with complex domain logic, high read/write ratios, and diverse query patterns
- Event sourcing often complements CQRS but is a separate pattern that can be used independently
- Implementation requires careful design of aggregates, events, idempotent handlers, and monitoring

**Example**

Consider an order management microservice in an e-commerce platform. Without CQRS, the service might use a traditional model:

```java
// Traditional approach - single model for reads and writes
@Entity
public class Order {
    @Id private String id;
    private String customerId;
    private OrderStatus status;
    @OneToMany private List<OrderItem> items;
    private Address shippingAddress;
    private BigDecimal total;
    // ... more fields
    
    // Business logic mixed with data access concerns
    public void place() {
        if (items.isEmpty()) throw new InvalidOrderException();
        this.status = OrderStatus.PLACED;
        this.total = calculateTotal();
    }
}

@RestController
public class OrderController {
    @Autowired private OrderRepository orderRepository;
    
    @PostMapping("/orders")
    public Order createOrder(@RequestBody CreateOrderRequest request) {
        Order order = new Order(request);
        order.place(); // Business logic and validation
        return orderRepository.save(order);
    }
    
    @GetMapping("/orders/{id}")
    public Order getOrder(@PathVariable String id) {
        return orderRepository.findById(id); // Complex joins for items, customer data
    }
    
    @GetMapping("/customers/{customerId}/orders")
    public List<OrderSummary> getCustomerOrders(@PathVariable String customerId) {
        // Expensive query joining orders, items, products
        return orderRepository.findByCustomerId(customerId);
    }
}
```

With CQRS, the service separates concerns:

```java
// ============= COMMAND SIDE =============

// Commands represent intentions
public class PlaceOrderCommand {
    private final String customerId;
    private final List<OrderItem> items;
    private final Address shippingAddress;
    private final PaymentMethod paymentMethod;
    
    // Constructor, getters, validation
}

public class CancelOrderCommand {
    private final String orderId;
    private final String reason;
}

// Command handlers process commands
@Service
public class OrderCommandHandler {
    private final OrderRepository orderRepository;
    private final EventPublisher eventPublisher;
    
    @Transactional
    public void handle(PlaceOrderCommand command) {
        // Validate command
        if (command.getItems().isEmpty()) {
            throw new InvalidOrderException("Order must contain items");
        }
        
        // Create aggregate
        Order order = new Order(
            generateOrderId(),
            command.getCustomerId(),
            command.getItems(),
            command.getShippingAddress()
        );
        
        // Execute business logic
        order.place();
        
        // Persist to write database
        orderRepository.save(order);
        
        // Publish events
        eventPublisher.publish(new OrderPlacedEvent(
            order.getId(),
            order.getCustomerId(),
            order.getItems(),
            order.getTotal(),
            order.getShippingAddress(),
            Instant.now()
        ));
    }
    
    @Transactional
    public void handle(CancelOrderCommand command) {
        Order order = orderRepository.findById(command.getOrderId())
            .orElseThrow(() -> new OrderNotFoundException());
        
        // Business logic
        order.cancel(command.getReason());
        
        orderRepository.save(order);
        
        // Publish event
        eventPublisher.publish(new OrderCancelledEvent(
            order.getId(),
            command.getReason(),
            Instant.now()
        ));
    }
}

// Domain aggregate with business logic
public class Order {
    private String id;
    private String customerId;
    private List<OrderItem> items;
    private OrderStatus status;
    private Address shippingAddress;
    private BigDecimal total;
    
    public void place() {
        // Business rules
        if (this.status != OrderStatus.DRAFT) {
            throw new InvalidOrderStateException("Order already placed");
        }
        
        if (this.items.isEmpty()) {
            throw new InvalidOrderException("Order must contain items");
        }
        
        this.status = OrderStatus.PLACED;
        this.total = calculateTotal();
    }
    
    public void cancel(String reason) {
        if (this.status == OrderStatus.DELIVERED) {
            throw new InvalidOrderStateException("Cannot cancel delivered order");
        }
        
        this.status = OrderStatus.CANCELLED;
    }
    
    private BigDecimal calculateTotal() {
        return items.stream()
            .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}

// ============= EVENT PUBLISHING =============

// Domain events
public class OrderPlacedEvent {
    private final String orderId;
    private final String customerId;
    private final List<OrderItem> items;
    private final BigDecimal total;
    private final Address shippingAddress;
    private final Instant timestamp;
    private final String eventId = UUID.randomUUID().toString();
    
    // Constructor, getters
}

public class OrderCancelledEvent {
    private final String orderId;
    private final String reason;
    private final Instant timestamp;
    private final String eventId = UUID.randomUUID().toString();
}

// Event publisher
@Service
public class KafkaEventPublisher implements EventPublisher {
    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    @Override
    public void publish(Object event) {
        String topic = "order-events";
        String key = extractAggregateId(event);
        
        kafkaTemplate.send(topic, key, event)
            .addCallback(
                success -> log.info("Event published: {}", event),
                failure -> log.error("Failed to publish event", failure)
            );
    }
}

// ============= QUERY SIDE =============

// Read models optimized for specific queries
@Document(collection = "order_summaries")
public class OrderSummary {
    @Id private String orderId;
    private String customerId;
    private String customerName;
    private BigDecimal total;
    private int itemCount;
    private OrderStatus status;
    private Instant placedAt;
    
    // Simple getters, no business logic
}

@Document(collection = "customer_order_history")
public class CustomerOrderHistory {
    @Id private String customerId;
    private String customerName;
    private List<OrderHistoryEntry> orders;
    private int totalOrders;
    private BigDecimal lifetimeValue;
    
    public static class OrderHistoryEntry {
        private String orderId;
        private BigDecimal total;
        private Instant placedAt;
        private OrderStatus status;
    }
}

// Event subscribers update read models
@Service
public class OrderReadModelUpdater {
    private final OrderSummaryRepository orderSummaryRepo;
    private final CustomerOrderHistoryRepository customerHistoryRepo;
    private final ProcessedEventRepository processedEventRepo;
    
    @KafkaListener(topics = "order-events", groupId = "order-read-model")
    public void handleEvent(ConsumerRecord<String, Object> record) {
        Object event = record.value();
        String eventId = extractEventId(event);
        
        // Idempotency check
        if (processedEventRepo.existsById(eventId)) {
            log.debug("Event already processed: {}", eventId);
            return;
        }
        
        // Update read models based on event type
        if (event instanceof OrderPlacedEvent) {
            handleOrderPlaced((OrderPlacedEvent) event);
        } else if (event instanceof OrderCancelledEvent) {
            handleOrderCancelled((OrderCancelledEvent) event);
        }
        
        // Mark event as processed
        processedEventRepo.save(new ProcessedEvent(eventId, Instant.now()));
    }
    
    private void handleOrderPlaced(OrderPlacedEvent event) {
        // Update order summary
        OrderSummary summary = new OrderSummary();
        summary.setOrderId(event.getOrderId());
        summary.setCustomerId(event.getCustomerId());
        summary.setTotal(event.getTotal());
        summary.setItemCount(event.getItems().size());
        summary.setStatus(OrderStatus.PLACED);
        summary.setPlacedAt(event.getTimestamp());
        orderSummaryRepo.save(summary);
        
        // Update customer history
        CustomerOrderHistory history = customerHistoryRepo
            .findById(event.getCustomerId())
            .orElse(new CustomerOrderHistory(event.getCustomerId()));
        
        history.addOrder(new OrderHistoryEntry(
            event.getOrderId(),
            event.getTotal(),
            event.getTimestamp(),
            OrderStatus.PLACED
        ));
        history.incrementTotalOrders();
        history.addToLifetimeValue(event.getTotal());
        
        customerHistoryRepo.save(history);
    }
    
    private void handleOrderCancelled(OrderCancelledEvent event) {
        // Update order summary status
        orderSummaryRepo.findById(event.getOrderId()).ifPresent(summary -> {
            summary.setStatus(OrderStatus.CANCELLED);
            orderSummaryRepo.save(summary);
        });
        
        // Update customer history
        customerHistoryRepo.findByOrderId(event.getOrderId()).ifPresent(history -> {
            history.updateOrderStatus(event.getOrderId(), OrderStatus.CANCELLED);
            customerHistoryRepo.save(history);
        });
    }
}

// Query handlers
@Service
public class OrderQueryHandler {

    private final OrderSummaryRepository orderSummaryRepo;
    private final CustomerOrderHistoryRepository customerHistoryRepo;

    public OrderQueryHandler(
        OrderSummaryRepository orderSummaryRepo,
        CustomerOrderHistoryRepository customerHistoryRepo
    ) {
        this.orderSummaryRepo = orderSummaryRepo;
        this.customerHistoryRepo = customerHistoryRepo;
    }

    public OrderSummary getOrderSummary(String orderId) {
        return orderSummaryRepo.findById(orderId)
            .orElseThrow(() -> new OrderNotFoundException(orderId));
    }

    public List<OrderSummary> getCustomerOrders(String customerId, Pageable pageable) {
        // Simple query against denormalized read model
        return orderSummaryRepo.findByCustomerId(customerId, pageable);
    }

    public CustomerOrderHistory getCustomerHistory(String customerId) {
        return customerHistoryRepo.findById(customerId)
            .orElse(new CustomerOrderHistory(customerId));
    }

    public Page<OrderSummary> searchOrders(
        OrderSearchCriteria criteria,
        Pageable pageable
    ) {
        // Complex search against optimized read model
        return orderSummaryRepo.search(criteria, pageable);
    }
}
````

A Python implementation using event sourcing:

```python
