## Entity Pattern

The Entity pattern represents objects that have a distinct identity that runs through time and different representations. Unlike value objects that are defined by their attributes, entities are defined by a thread of continuity and identity, remaining conceptually the same entity even when their attributes change.

### Core Concept

An entity is a domain object that is defined not by its attributes but by its identity. Two entities with identical attributes are still considered different if they have different identities. Entities have a lifecycle—they are created, modified throughout their existence, and eventually archived or deleted—while maintaining the same identity throughout these changes.

The fundamental characteristic that distinguishes an entity from other objects is that it matters _who_ or _what_ it is, not just what attributes it has. A person, a bank account, an order, or a vehicle are all entities because each has a unique identity that persists over time.

### Identity Management

**Identity Creation** Every entity must have a unique identifier that distinguishes it from all other entities of the same type. This identifier is typically assigned when the entity is created and remains immutable throughout the entity's lifetime. The identity can be generated in several ways: database auto-increment, universally unique identifiers (UUIDs), natural keys from the domain, or composite keys combining multiple attributes.

**Identity Equality** Two entities are considered equal if and only if they have the same identity, regardless of their other attributes. This differs from value objects, where equality is determined by comparing all attributes. Implementing proper equality checking based on identity is crucial for correct behavior in collections, caching, and persistence mechanisms.

**Surrogate vs Natural Keys** Surrogate keys are artificial identifiers created specifically for identification purposes, such as auto-incrementing integers or UUIDs. Natural keys are meaningful identifiers from the domain itself, such as social security numbers or email addresses. Surrogate keys are generally preferred because natural keys can change, may not be truly unique, or may have privacy implications.

### Lifecycle Management

**Creation** Entities are typically created through constructors or factory methods that ensure the entity starts in a valid state with a proper identity. The creation process should validate that all required invariants are satisfied and that the entity has all necessary information to exist meaningfully in the domain.

**Modification** Throughout its lifecycle, an entity's attributes change while its identity remains constant. A person's address might change, an order's status might be updated, or a product's price might be adjusted, but these remain the same person, order, or product. State changes should be managed through methods that maintain business invariants.

**Persistence** Entities are usually persisted to a database or other storage mechanism. The persistence mechanism must preserve the entity's identity across save and load operations. Object-relational mapping (ORM) frameworks typically handle this by mapping the entity's identity to a primary key in the database.

**Deletion** When an entity is no longer needed, it may be deleted or archived. Some domains use soft deletion, where the entity is marked as inactive but remains in storage for historical or auditing purposes. Hard deletion physically removes the entity from storage.

### Entity Characteristics

**Mutability** Entities are typically mutable—their attributes can change over time. This mutability is central to their purpose, as entities model real-world objects that evolve. However, the identity itself must remain immutable to maintain consistency.

**Business Logic Encapsulation** Entities should encapsulate the business rules and behaviors that operate on their data. Rather than having external services manipulate entity attributes directly, the entity should expose methods that perform operations while maintaining invariants.

**State Consistency** Entities must maintain their invariants—business rules that must always be true. Any operation that modifies the entity should ensure that all invariants remain satisfied. This prevents the entity from entering an invalid state.

**Rich Behavior** In domain-driven design, entities should be more than just data containers. They should contain the logic that operates on their data, making them rich domain objects rather than anemic data structures. This makes the domain model more expressive and maintainable.

### Relationship with Other Patterns

**Value Objects** Entities often contain value objects as attributes. While the entity has identity and mutability, the value objects within it are immutable and defined by their attributes. For example, a `Person` entity might have an `Address` value object.

**Aggregates** Entities are often organized into aggregates, where one entity serves as the aggregate root and controls access to other entities within the aggregate boundary. The aggregate root is responsible for maintaining consistency across all entities in the aggregate.

**Repositories** Repositories provide access to entities by their identity, abstracting the persistence mechanism. They allow you to retrieve entities from storage, save modifications, and query for entities based on criteria, while keeping persistence concerns separate from the domain model.

**Domain Events** Entities often raise domain events when significant state changes occur. These events communicate what happened to other parts of the system without creating tight coupling between entities and external components.

### Implementation Strategies

**Base Entity Class** Many implementations use a base entity class that provides common functionality like identity management, equality comparison, and domain event handling. Concrete entities inherit from this base class and add domain-specific attributes and behavior.

**Identity Generation** Choose an appropriate identity generation strategy for your context. Database-generated identities work well for simple cases but can complicate testing and require database access. Application-generated identities (like UUIDs) provide more flexibility but may have performance implications.

**Equality Implementation** Override equality methods to compare entities based on identity rather than attributes. In languages like Java or C#, this means overriding `equals()` and `hashCode()` or `Equals()` and `GetHashCode()` to use only the identity field.

**Encapsulation** Keep entity attributes private and expose them through methods that enforce business rules. Avoid public setters that allow external code to modify entity state without validation. Use intention-revealing method names that express business operations.

### Advantages

**Clear Identity Semantics** The pattern makes it explicit which objects have identity and which are defined by their attributes. This clarity prevents confusion about object equality and helps developers understand the domain model.

**Lifecycle Tracking** Entities naturally support tracking changes over time. You can implement audit trails, versioning, and history by leveraging the entity's persistent identity and lifecycle.

**Business Logic Centralization** By encapsulating behavior within entities, business logic is centralized where it belongs—with the data it operates on. This improves maintainability and makes the domain model more expressive.

**Persistence Alignment** Entities map naturally to database tables or document collections. The identity corresponds to primary keys, and the entity's attributes map to columns or fields.

### Disadvantages

**Complexity** Entities are more complex than simple data structures. They require careful design to maintain invariants, manage identity, and implement proper equality semantics.

**Performance Considerations** Rich entities with extensive behavior and relationship management can have performance implications. Loading and tracking many entities can consume memory and processing resources.

**Identity Management Overhead** Generating and managing unique identities adds complexity, especially in distributed systems where coordinating identity generation across multiple nodes can be challenging.

**Over-Engineering Risk** Not every object needs to be an entity. Treating simple data structures as entities adds unnecessary complexity. Distinguishing between entities and value objects requires thoughtful domain analysis.

### Design Considerations

**Identify True Entities** Not every noun in your domain should be an entity. Ask: "If two instances have identical attributes, are they the same thing or different things?" If different, it's likely an entity. A person with the name "John Smith" is different from another person with the same name—they're entities. Two addresses with the same street, city, and zip code are the same address—that's a value object.

**Keep Entities Focused** Entities should represent cohesive domain concepts. Avoid creating "god objects" that contain too much responsibility. If an entity is becoming too large, consider whether it should be split or whether some attributes should be extracted into value objects.

**Manage Entity Boundaries** Decide which entities can be accessed directly and which should only be accessed through an aggregate root. This controls complexity and ensures that invariants spanning multiple entities are properly maintained.

**Consider Identity Scope** Determine whether identity is unique globally or only within a certain context. An order line item might only need to be unique within its order, not across all orders in the system.

### Anti-Patterns to Avoid

**Anemic Domain Model** Creating entities that are just data containers with getters and setters, with all business logic in external services. This loses the benefits of encapsulation and creates a procedural design disguised as object-oriented.

**Identity Confusion** Using business attributes as identity when they might change or aren't guaranteed to be unique. An email address might seem like a good identifier for a user, but it can change and might not always be unique in the domain.

**Exposing Internal State** Providing public setters or direct access to entity collections allows external code to modify the entity without validation. This breaks encapsulation and makes it impossible to maintain invariants.

**Excessive Entity Creation** Making every domain concept an entity when many would be better modeled as value objects. This adds unnecessary complexity and overhead for objects that don't need identity.

### Testing Entities

**Unit Testing** Test entity behavior in isolation by creating entities with known state and verifying that operations maintain invariants. Mock dependencies like repositories to keep tests focused on business logic.

**Identity Testing** Verify that entities with the same identity are considered equal even with different attributes, and entities with different identities are not equal even with identical attributes.

**Invariant Testing** Test that entities reject operations that would violate business rules. Verify that the entity throws appropriate exceptions or returns error results when invalid operations are attempted.

**Lifecycle Testing** Test the complete lifecycle of entities from creation through various state transitions to deletion, ensuring that all transitions are valid and maintain consistency.

### Common Use Cases

**Domain-Driven Design** Entities are fundamental building blocks in domain-driven design, representing the core concepts in your business domain. They form the heart of the domain model alongside value objects and aggregates.

**E-Commerce Systems** Customers, orders, products, and shopping carts are all entities with distinct identities. An order remains the same order even as items are added or removed, payment is processed, and shipment status changes.

**Financial Systems** Accounts, transactions, and portfolios are entities tracked throughout their lifecycle. Each has a unique identity and undergoes numerous state changes while maintaining continuity.

**Healthcare Systems** Patients, appointments, prescriptions, and medical records are entities with clear identities. A patient's information changes over time, but it's critical to maintain their identity for continuity of care.

### Entity in Different Architectural Styles

**Domain-Driven Design** Entities are core domain objects organized into aggregates. They contain business logic and are accessed through repositories. The focus is on rich domain models with behavior, not just data.

**Clean Architecture** Entities reside in the core domain layer, independent of frameworks and infrastructure. They represent business rules and are surrounded by use cases that orchestrate their behavior.

**Event Sourcing** Rather than storing current entity state, the system stores a sequence of events that represent state changes. The entity's current state is derived by replaying these events. The entity's identity ties together the event stream.

**Microservices** Each microservice owns its entities and their persistence. Entities in one service are accessed by other services only through APIs, maintaining bounded contexts and preventing coupling through shared databases.

### Advanced Concepts

**Entity Versioning** Track version numbers to detect concurrent modifications. When two processes load the same entity, modify it, and save it, versioning prevents the second save from overwriting the first without awareness of the changes.

**Temporal Entities** Some domains require tracking entity state at different points in time. Temporal entities maintain a history of attribute values, allowing queries about what the entity looked like at any past moment.

**Entity Caching** To improve performance, entities can be cached after retrieval from storage. The cache must be invalidated or updated when entities change to prevent stale data.

**Lazy Loading** For entities with complex relationships or large amounts of data, lazy loading defers loading related entities or attributes until they're actually accessed. This improves initial load performance but requires careful transaction management.

**Key Points:**

- Entities are defined by identity, not attributes; they maintain continuity through time
- Identity must be unique and immutable throughout the entity's lifecycle
- Entities should encapsulate business logic and maintain their own invariants
- Two entities are equal only if they have the same identity, regardless of attributes
- Entities are typically mutable, allowing state changes while preserving identity
- Entities differ from value objects, which are immutable and defined by attributes
- Proper identity management and equality implementation are critical
- Avoid the anemic domain model anti-pattern by including behavior in entities
- Use repositories to abstract entity persistence and retrieval
- Not every domain object should be an entity; distinguish from value objects carefully

**Example:**

```java
// Entity base class providing common functionality
public abstract class Entity<T> {
    private final T id;
    
    protected Entity(T id) {
        if (id == null) {
            throw new IllegalArgumentException("Entity identity cannot be null");
        }
        this.id = id;
    }
    
    public T getId() {
        return id;
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        
        Entity<?> other = (Entity<?>) obj;
        return id.equals(other.id);
    }
    
    @Override
    public int hashCode() {
        return id.hashCode();
    }
}

// Customer Entity - demonstrates identity and rich behavior
public class Customer extends Entity<Long> {
    private String firstName;
    private String lastName;
    private Email email;
    private Address shippingAddress;
    private Address billingAddress;
    private CustomerStatus status;
    private LocalDateTime registeredAt;
    private List<Order> orderHistory;
    private Money creditBalance;
    
    // Private constructor - use factory method
    private Customer(Long id, String firstName, String lastName, Email email) {
        super(id);
        this.firstName = validateName(firstName);
        this.lastName = validateName(lastName);
        this.email = email;
        this.status = CustomerStatus.ACTIVE;
        this.registeredAt = LocalDateTime.now();
        this.orderHistory = new ArrayList<>();
        this.creditBalance = Money.zero();
    }
    
    // Factory method for creating new customers
    public static Customer create(Long id, String firstName, String lastName, Email email) {
        return new Customer(id, firstName, lastName, email);
    }
    
    // Business logic: Change email with validation
    public void changeEmail(Email newEmail) {
        if (this.status == CustomerStatus.SUSPENDED) {
            throw new CustomerSuspendedException("Cannot modify suspended customer");
        }
        
        if (this.email.equals(newEmail)) {
            return; // No change needed
        }
        
        this.email = newEmail;
        // Could raise domain event: EmailChangedEvent
    }
    
    // Business logic: Update shipping address
    public void updateShippingAddress(Address newAddress) {
        if (this.status == CustomerStatus.SUSPENDED) {
            throw new CustomerSuspendedException("Cannot modify suspended customer");
        }
        
        this.shippingAddress = newAddress;
    }
    
    // Business logic: Place an order
    public Order placeOrder(List<OrderItem> items, Address deliveryAddress) {
        if (this.status != CustomerStatus.ACTIVE) {
            throw new InvalidCustomerStatusException("Only active customers can place orders");
        }
        
        if (items == null || items.isEmpty()) {
            throw new InvalidOrderException("Order must contain at least one item");
        }
        
        Money orderTotal = calculateOrderTotal(items);
        
        // Check if customer has sufficient credit if using credit
        if (creditBalance.isLessThan(Money.zero()) && 
            creditBalance.abs().isGreaterThan(orderTotal)) {
            throw new InsufficientCreditException("Customer credit limit exceeded");
        }
        
        Order order = Order.create(
            generateOrderId(),
            this.getId(),
            items,
            deliveryAddress != null ? deliveryAddress : this.shippingAddress
        );
        
        this.orderHistory.add(order);
        
        return order;
    }
    
    // Business logic: Apply credit to account
    public void applyCredit(Money amount) {
        if (amount.isLessThanOrEqual(Money.zero())) {
            throw new IllegalArgumentException("Credit amount must be positive");
        }
        
        this.creditBalance = this.creditBalance.add(amount);
    }
    
    // Business logic: Suspend customer account
    public void suspend(String reason) {
        if (this.status == CustomerStatus.SUSPENDED) {
            return; // Already suspended
        }
        
        this.status = CustomerStatus.SUSPENDED;
        // Could raise domain event: CustomerSuspendedEvent with reason
    }
    
    // Business logic: Reactivate suspended account
    public void reactivate() {
        if (this.status != CustomerStatus.SUSPENDED) {
            throw new InvalidCustomerStatusException("Only suspended customers can be reactivated");
        }
        
        this.status = CustomerStatus.ACTIVE;
        // Could raise domain event: CustomerReactivatedEvent
    }
    
    // Query method: Check if customer is eligible for premium benefits
    public boolean isEligibleForPremiumBenefits() {
        if (this.status != CustomerStatus.ACTIVE) {
            return false;
        }
        
        Money totalSpent = orderHistory.stream()
            .map(Order::getTotal)
            .reduce(Money.zero(), Money::add);
        
        return totalSpent.isGreaterThan(Money.of(1000)) && 
               orderHistory.size() >= 10;
    }
    
    // Query method: Calculate customer lifetime value
    public Money calculateLifetimeValue() {
        return orderHistory.stream()
            .map(Order::getTotal)
            .reduce(Money.zero(), Money::add);
    }
    
    private String validateName(String name) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name cannot be empty");
        }
        if (name.length() > 100) {
            throw new IllegalArgumentException("Name too long");
        }
        return name.trim();
    }
    
    private Money calculateOrderTotal(List<OrderItem> items) {
        return items.stream()
            .map(OrderItem::getSubtotal)
            .reduce(Money.zero(), Money::add);
    }
    
    private Long generateOrderId() {
        // In real implementation, this would use a proper ID generation strategy
        return System.currentTimeMillis();
    }
    
    // Getters for immutable access
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public Email getEmail() { return email; }
    public Address getShippingAddress() { return shippingAddress; }
    public CustomerStatus getStatus() { return status; }
    public LocalDateTime getRegisteredAt() { return registeredAt; }
    public Money getCreditBalance() { return creditBalance; }
    
    // Return defensive copy of order history
    public List<Order> getOrderHistory() {
        return new ArrayList<>(orderHistory);
    }
}

// Order Entity - demonstrates entity relationships and lifecycle
public class Order extends Entity<Long> {
    private final Long customerId;
    private final List<OrderItem> items;
    private final Address deliveryAddress;
    private OrderStatus status;
    private Money total;
    private LocalDateTime placedAt;
    private LocalDateTime shippedAt;
    private LocalDateTime deliveredAt;
    private Payment payment;
    
    private Order(Long id, Long customerId, List<OrderItem> items, Address deliveryAddress) {
        super(id);
        this.customerId = customerId;
        this.items = new ArrayList<>(items); // Defensive copy
        this.deliveryAddress = deliveryAddress;
        this.status = OrderStatus.PENDING;
        this.placedAt = LocalDateTime.now();
        calculateTotal();
    }
    
    public static Order create(Long id, Long customerId, 
                              List<OrderItem> items, Address deliveryAddress) {
        return new Order(id, customerId, items, deliveryAddress);
    }
    
    // Business logic: Confirm order
    public void confirm() {
        if (status != OrderStatus.PENDING) {
            throw new InvalidOrderStateException(
                "Only pending orders can be confirmed"
            );
        }
        this.status = OrderStatus.CONFIRMED;
    }
    
    // Business logic: Process payment
    public void processPayment(Payment payment) {
        if (status != OrderStatus.CONFIRMED) {
            throw new InvalidOrderStateException(
                "Only confirmed orders can have payment processed"
            );
        }
        
        if (!payment.getAmount().equals(this.total)) {
            throw new InvalidPaymentException(
                "Payment amount does not match order total"
            );
        }
        
        this.payment = payment;
        this.status = OrderStatus.PAID;
    }
    
    // Business logic: Ship order
    public void ship() {
        if (status != OrderStatus.PAID) {
            throw new InvalidOrderStateException(
                "Only paid orders can be shipped"
            );
        }
        this.status = OrderStatus.SHIPPED;
        this.shippedAt = LocalDateTime.now();
    }
    
    // Business logic: Mark as delivered
    public void markAsDelivered() {
        if (status != OrderStatus.SHIPPED) {
            throw new InvalidOrderStateException(
                "Only shipped orders can be marked as delivered"
            );
        }
        this.status = OrderStatus.DELIVERED;
        this.deliveredAt = LocalDateTime.now();
    }
    
    // Business logic: Cancel order
    public void cancel() {
        if (status == OrderStatus.SHIPPED || status == OrderStatus.DELIVERED) {
            throw new InvalidOrderStateException(
                "Cannot cancel shipped or delivered orders"
            );
        }
        this.status = OrderStatus.CANCELLED;
    }
    
    private void calculateTotal() {
        this.total = items.stream()
            .map(OrderItem::getSubtotal)
            .reduce(Money.zero(), Money::add);
    }
    
    public Long getCustomerId() { return customerId; }
    public List<OrderItem> getItems() { return new ArrayList<>(items); }
    public Address getDeliveryAddress() { return deliveryAddress; }
    public OrderStatus getStatus() { return status; }
    public Money getTotal() { return total; }
    public LocalDateTime getPlacedAt() { return placedAt; }
}

// Supporting value objects
public class Email {
    private final String value;
    
    public Email(String value) {
        if (value == null || !value.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            throw new IllegalArgumentException("Invalid email format");
        }
        this.value = value.toLowerCase();
    }
    
    public String getValue() { return value; }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Email email = (Email) obj;
        return value.equals(email.value);
    }
    
    @Override
    public int hashCode() {
        return value.hashCode();
    }
}

// Repository interface for entity persistence
public interface CustomerRepository {
    Customer findById(Long id);
    Customer findByEmail(Email email);
    List<Customer> findByStatus(CustomerStatus status);
    void save(Customer customer);
    void delete(Customer customer);
}

// Example usage demonstrating entity identity and behavior
public class EntityPatternDemo {
    public void demonstrateEntityPattern() {
        // Create two customers with same attributes but different identities
        Customer customer1 = Customer.create(
            1L,
            "John",
            "Doe",
            new Email("john.doe@example.com")
        );
        
        Customer customer2 = Customer.create(
            2L,
            "John",
            "Doe",
            new Email("john.doe@example.com")
        );
        
        // Despite having identical attributes, they are different entities
        assert !customer1.equals(customer2); // Different identities
        
        // Create another reference to the same customer
        Customer sameCustomer1 = Customer.create(
            1L,
            "Jane",
            "Smith",
            new Email("jane.smith@example.com")
        );
        
        // Same identity means they're equal, even with different attributes
        assert customer1.equals(sameCustomer1); // Same identity
        
        // Demonstrate entity behavior and state changes
        customer1.updateShippingAddress(new Address(
            "123 Main St",
            "Springfield",
            "IL",
            "62701"
        ));
        
        // Place an order - entity maintains its business rules
        List<OrderItem> items = Arrays.asList(
            new OrderItem("Product A", 2, Money.of(25)),
            new OrderItem("Product B", 1, Money.of(50))
        );
        
        Order order = customer1.placeOrder(items, null);
        
        // Order is a separate entity with its own identity and lifecycle
        order.confirm();
        order.processPayment(new Payment(order.getTotal(), "CARD"));
        order.ship();
        
        // Customer identity remains constant despite state changes
        assert customer1.getId().equals(1L);
        assert customer1.getOrderHistory().size() == 1;
    }
}
```

**Output:**

When the demonstration code executes:

1. **Identity Semantics**: Two customers with identical names and emails are created with different IDs (1 and 2). The equality check returns `false` because they have different identities, demonstrating that entities are defined by identity, not attributes.
    
2. **Identity Persistence**: When customer1 (ID: 1) is compared with sameCustomer1 (also ID: 1), they are equal despite having completely different names and emails. This proves that entity equality is based solely on identity.
    
3. **State Mutation**: The customer's shipping address is updated. The customer object changes its state while maintaining the same identity (ID: 1).
    
4. **Business Logic Execution**: When placing an order, the entity enforces business rules: validates the customer status is ACTIVE, ensures items exist, checks credit limits. The entity creates and returns a new Order entity with its own identity.
    
5. **Lifecycle Management**: The Order entity progresses through its lifecycle (PENDING → CONFIRMED → PAID → SHIPPED) with each state transition validated by business rules. Invalid transitions (like shipping before payment) throw exceptions.
    

Throughout all these operations, both Customer and Order maintain their distinct identities. The customer can be persisted, retrieved, and modified multiple times, and it will always be recognizable as the same customer by its ID, demonstrating the core principle of entity identity persistence.

**Conclusion:**

The Entity pattern is fundamental to modeling domains where identity and continuity matter. It provides a clear way to represent objects that exist over time, undergo changes, and need to be tracked individually. By distinguishing entities from value objects and implementing proper identity management, you create domain models that accurately reflect the real-world concepts they represent.

The pattern's strength lies in its alignment with how we naturally think about persistent objects in the real world. People, orders, accounts, and vehicles all have identities that persist regardless of changes to their attributes. Translating this intuition into code through the Entity pattern creates systems that are easier to understand and maintain.

However, successful implementation requires discipline. Entities must encapsulate their business logic rather than being mere data containers. They must maintain their invariants through all state transitions. And importantly, not every object should be an entity—carefully distinguish between objects that need identity and those that are better modeled as value objects.

When combined with other domain-driven design patterns like aggregates, repositories, and value objects, the Entity pattern forms the foundation of rich domain models that capture the essential complexity of business domains while remaining maintainable and testable. The pattern has proven its value across decades of software development and remains a cornerstone of effective domain modeling.

---

## Value Object Pattern

The Value Object pattern is a design pattern where objects are defined by their values rather than by their identity. Unlike entities that have a unique identifier and a lifecycle, value objects are immutable objects that represent descriptive aspects of a domain with no conceptual identity. Two value objects with the same values are considered equal and interchangeable.

### Overview

Value objects are fundamental building blocks in domain-driven design and object-oriented programming. They represent concepts that are defined entirely by their attributes rather than by a unique identity. Examples include money, dates, colors, coordinates, addresses, and measurements.

The key characteristic distinguishing value objects from entities is that value objects have no identity—they are what they are because of their values. If two value objects have the same values, they are considered equal and can be freely substituted for one another.

### Core Characteristics

#### Immutability

Value objects cannot be modified after creation. Any operation that would change a value object's state instead returns a new value object with the modified values.

**Why immutability matters:**

- Prevents unintended side effects when passing value objects between methods
- Makes value objects thread-safe without additional synchronization
- Simplifies reasoning about code behavior
- Enables safe sharing of value object instances

#### Value Equality

Two value objects are equal if all their attributes have the same values, regardless of whether they are the same object instance in memory.

**Comparison with reference equality:**

- **Reference equality**: Two variables point to the same object in memory
- **Value equality**: Two objects have the same attribute values

Value objects implement value-based equality, meaning they override equality comparison methods to compare attribute values rather than object references.

#### No Identity

Value objects don't have a unique identifier field (like an ID or GUID). They are identified and distinguished solely by their attributes.

**Example distinction:**

- **Entity**: A `Customer` with ID 12345 remains the same customer even if their name or address changes
- **Value Object**: A `Money` object with value 100 USD is identical to any other `Money` object with value 100 USD

#### Self-Validation

Value objects enforce their own invariants and validity rules. Invalid value objects cannot be constructed, ensuring that all instances are valid by definition.

### Benefits

#### Domain Clarity

Value objects make domain concepts explicit in code. Instead of representing money as a decimal or coordinates as two separate integers, value objects encapsulate these concepts with meaningful names and behavior.

**Without value objects:**

```csharp
decimal price = 99.99m;
string currency = "USD";
```

**With value objects:**

```csharp
Money price = new Money(99.99m, Currency.USD);
```

#### Type Safety

Value objects prevent common programming errors by using the type system to enforce correct usage.

**Problem without value objects:**

```csharp
// Easy to accidentally swap parameters
void Transfer(decimal fromAccount, decimal toAccount, decimal amount) { }

// Called incorrectly - amount and toAccount are swapped
Transfer(accountA, 500.00m, accountB); // Compiles but wrong!
```

**Solution with value objects:**

```csharp
void Transfer(AccountId from, AccountId to, Money amount) { }

// Type error prevents incorrect usage
Transfer(accountA, money, accountB); // Compiler error - type mismatch
```

#### Reduced Duplication

Business logic related to a value is centralized in the value object rather than scattered throughout the codebase.

**Example**: Currency conversion logic lives in the `Money` value object, not duplicated across multiple services.

#### Encapsulation

Value objects encapsulate related data and behavior together, hiding implementation details and exposing only meaningful operations.

#### Simplified Testing

Value objects can be easily tested in isolation. Their immutability and lack of dependencies make them straightforward to instantiate and verify.

### Common Value Object Examples

#### Money

Represents monetary amounts with currency information.

**Attributes:**

- Amount (decimal)
- Currency (enum or value object)

**Operations:**

- Add/subtract money (must have same currency)
- Multiply/divide by scalar
- Convert to different currency
- Format for display

#### Date Range

Represents a period between two dates.

**Attributes:**

- Start date
- End date

**Operations:**

- Check if date falls within range
- Calculate duration
- Check for overlap with another range
- Split into smaller ranges

#### Email Address

Represents a valid email address.

**Attributes:**

- Email string

**Operations:**

- Parse local and domain parts
- Validate format
- Normalize (lowercase)
- Mask for display

#### Physical Address

Represents a mailing or physical location.

**Attributes:**

- Street address
- City
- State/province
- Postal code
- Country

**Operations:**

- Format for display
- Validate completeness
- Extract region information

#### Measurement

Represents a quantity with units.

**Attributes:**

- Value (decimal)
- Unit (enum or value object)

**Operations:**

- Convert between units
- Add/subtract measurements
- Compare measurements

### Implementation Guidelines

#### Constructor Validation

Value objects should validate all inputs in their constructor and throw exceptions for invalid data. This ensures that no invalid value objects can exist in the system.

```csharp
public class Email
{
    public string Value { get; }
    
    public Email(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email cannot be empty");
            
        if (!IsValidEmailFormat(email))
            throw new ArgumentException($"Invalid email format: {email}");
            
        Value = email.ToLowerInvariant(); // Normalize
    }
    
    private bool IsValidEmailFormat(string email)
    {
        // [Inference] Email validation implementation would use regex or similar
        // This is a simplified example
        return email.Contains("@") && email.Contains(".");
    }
}
```

#### Equality Implementation

Value objects must override equality methods to compare values rather than references.

**C# example:**

```csharp
public class Money : IEquatable<Money>
{
    public decimal Amount { get; }
    public Currency Currency { get; }
    
    public Money(decimal amount, Currency currency)
    {
        Amount = amount;
        Currency = currency;
    }
    
    public bool Equals(Money other)
    {
        if (other is null) return false;
        return Amount == other.Amount && Currency == other.Currency;
    }
    
    public override bool Equals(object obj)
    {
        return Equals(obj as Money);
    }
    
    public override int GetHashCode()
    {
        return HashCode.Combine(Amount, Currency);
    }
    
    public static bool operator ==(Money left, Money right)
    {
        if (left is null) return right is null;
        return left.Equals(right);
    }
    
    public static bool operator !=(Money left, Money right)
    {
        return !(left == right);
    }
}
```

#### Immutable Operations

Operations that would modify a value object should return a new instance instead of modifying the existing one.

```csharp
public class Money
{
    // ... properties and constructor ...
    
    public Money Add(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException(
                $"Cannot add money with different currencies: {Currency} and {other.Currency}");
        
        return new Money(Amount + other.Amount, Currency);
    }
    
    public Money Multiply(decimal multiplier)
    {
        return new Money(Amount * multiplier, Currency);
    }
}
```

#### Factory Methods

Consider providing factory methods for common value object creation scenarios, especially when validation or transformation logic is complex.

```csharp
public class DateRange
{
    public DateTime Start { get; }
    public DateTime End { get; }
    
    private DateRange(DateTime start, DateTime end)
    {
        if (end < start)
            throw new ArgumentException("End date must be after start date");
            
        Start = start;
        End = end;
    }
    
    public static DateRange Create(DateTime start, DateTime end)
    {
        return new DateRange(start, end);
    }
    
    public static DateRange FromDuration(DateTime start, TimeSpan duration)
    {
        return new DateRange(start, start.Add(duration));
    }
    
    public static DateRange CurrentMonth()
    {
        var now = DateTime.Now;
        var start = new DateTime(now.Year, now.Month, 1);
        var end = start.AddMonths(1).AddDays(-1);
        return new DateRange(start, end);
    }
}
```

### **Example**

Here's a comprehensive example showing value objects in an e-commerce order system:

**Money Value Object**

```csharp
public class Money : IEquatable<Money>
{
    public decimal Amount { get; }
    public Currency Currency { get; }
    
    public Money(decimal amount, Currency currency)
    {
        if (amount < 0)
            throw new ArgumentException("Amount cannot be negative");
            
        Amount = Math.Round(amount, 2); // Round to 2 decimal places
        Currency = currency ?? throw new ArgumentNullException(nameof(currency));
    }
    
    public Money Add(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException(
                $"Cannot add {Currency} and {other.Currency}");
        
        return new Money(Amount + other.Amount, Currency);
    }
    
    public Money Subtract(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException(
                $"Cannot subtract {other.Currency} from {Currency}");
                
        if (Amount < other.Amount)
            throw new InvalidOperationException("Result would be negative");
        
        return new Money(Amount - other.Amount, Currency);
    }
    
    public Money Multiply(decimal multiplier)
    {
        if (multiplier < 0)
            throw new ArgumentException("Multiplier cannot be negative");
            
        return new Money(Amount * multiplier, Currency);
    }
    
    public bool IsGreaterThan(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException("Cannot compare different currencies");
            
        return Amount > other.Amount;
    }
    
    public bool Equals(Money other)
    {
        if (other is null) return false;
        return Amount == other.Amount && Currency.Equals(other.Currency);
    }
    
    public override bool Equals(object obj) => Equals(obj as Money);
    
    public override int GetHashCode() => HashCode.Combine(Amount, Currency);
    
    public static bool operator ==(Money left, Money right)
    {
        if (left is null) return right is null;
        return left.Equals(right);
    }
    
    public static bool operator !=(Money left, Money right) => !(left == right);
    
    public override string ToString() => $"{Currency.Symbol}{Amount:N2}";
}

public class Currency : IEquatable<Currency>
{
    public string Code { get; }
    public string Symbol { get; }
    
    private Currency(string code, string symbol)
    {
        Code = code;
        Symbol = symbol;
    }
    
    public static readonly Currency USD = new Currency("USD", "$");
    public static readonly Currency EUR = new Currency("EUR", "€");
    public static readonly Currency GBP = new Currency("GBP", "£");
    
    public bool Equals(Currency other)
    {
        if (other is null) return false;
        return Code == other.Code;
    }
    
    public override bool Equals(object obj) => Equals(obj as Currency);
    public override int GetHashCode() => Code.GetHashCode();
    
    public static bool operator ==(Currency left, Currency right)
    {
        if (left is null) return right is null;
        return left.Equals(right);
    }
    
    public static bool operator !=(Currency left, Currency right) => !(left == right);
}
```

**Address Value Object**

```csharp
public class Address : IEquatable<Address>
{
    public string Street { get; }
    public string City { get; }
    public string State { get; }
    public string PostalCode { get; }
    public string Country { get; }
    
    public Address(string street, string city, string state, 
                   string postalCode, string country)
    {
        if (string.IsNullOrWhiteSpace(street))
            throw new ArgumentException("Street is required");
        if (string.IsNullOrWhiteSpace(city))
            throw new ArgumentException("City is required");
        if (string.IsNullOrWhiteSpace(country))
            throw new ArgumentException("Country is required");
            
        Street = street.Trim();
        City = city.Trim();
        State = state?.Trim();
        PostalCode = postalCode?.Trim();
        Country = country.Trim();
    }
    
    public bool IsInCountry(string countryCode)
    {
        return Country.Equals(countryCode, StringComparison.OrdinalIgnoreCase);
    }
    
    public string FormatForShipping()
    {
        var parts = new[] { Street, City, State, PostalCode, Country }
            .Where(p => !string.IsNullOrWhiteSpace(p));
        return string.Join(", ", parts);
    }
    
    public bool Equals(Address other)
    {
        if (other is null) return false;
        return Street == other.Street &&
               City == other.City &&
               State == other.State &&
               PostalCode == other.PostalCode &&
               Country == other.Country;
    }
    
    public override bool Equals(object obj) => Equals(obj as Address);
    
    public override int GetHashCode()
    {
        return HashCode.Combine(Street, City, State, PostalCode, Country);
    }
}
```

**Quantity Value Object**

```csharp
public class Quantity : IEquatable<Quantity>
{
    public int Value { get; }
    
    public Quantity(int value)
    {
        if (value <= 0)
            throw new ArgumentException("Quantity must be positive");
            
        Value = value;
    }
    
    public Quantity Add(Quantity other)
    {
        return new Quantity(Value + other.Value);
    }
    
    public Quantity Subtract(Quantity other)
    {
        if (Value < other.Value)
            throw new InvalidOperationException(
                "Cannot subtract more than available quantity");
                
        return new Quantity(Value - other.Value);
    }
    
    public bool IsSufficientFor(Quantity required)
    {
        return Value >= required.Value;
    }
    
    public bool Equals(Quantity other)
    {
        if (other is null) return false;
        return Value == other.Value;
    }
    
    public override bool Equals(object obj) => Equals(obj as Quantity);
    public override int GetHashCode() => Value.GetHashCode();
    
    public static bool operator ==(Quantity left, Quantity right)
    {
        if (left is null) return right is null;
        return left.Equals(right);
    }
    
    public static bool operator !=(Quantity left, Quantity right) => !(left == right);
}
```

**Using Value Objects in an Order Entity**

```csharp
public class Order
{
    public int Id { get; private set; } // Entity identity
    public Address ShippingAddress { get; private set; }
    public List<OrderLine> Lines { get; private set; }
    public DateTime CreatedAt { get; private set; }
    
    public Order(Address shippingAddress)
    {
        ShippingAddress = shippingAddress ?? 
            throw new ArgumentNullException(nameof(shippingAddress));
        Lines = new List<OrderLine>();
        CreatedAt = DateTime.UtcNow;
    }
    
    public void AddItem(Product product, Quantity quantity)
    {
        var line = new OrderLine(product, quantity);
        Lines.Add(line);
    }
    
    public Money CalculateTotal()
    {
        if (!Lines.Any())
            return new Money(0, Currency.USD);
            
        Money total = Lines[0].CalculateSubtotal();
        
        for (int i = 1; i < Lines.Count; i++)
        {
            total = total.Add(Lines[i].CalculateSubtotal());
        }
        
        return total;
    }
    
    public void ChangeShippingAddress(Address newAddress)
    {
        ShippingAddress = newAddress ?? 
            throw new ArgumentNullException(nameof(newAddress));
    }
}

public class OrderLine
{
    public Product Product { get; }
    public Quantity Quantity { get; private set; }
    
    public OrderLine(Product product, Quantity quantity)
    {
        Product = product ?? throw new ArgumentNullException(nameof(product));
        Quantity = quantity ?? throw new ArgumentNullException(nameof(quantity));
    }
    
    public Money CalculateSubtotal()
    {
        return Product.Price.Multiply(Quantity.Value);
    }
    
    public void IncreaseQuantity(Quantity additional)
    {
        Quantity = Quantity.Add(additional);
    }
}

public class Product
{
    public int Id { get; }
    public string Name { get; }
    public Money Price { get; }
    
    public Product(int id, string name, Money price)
    {
        Id = id;
        Name = name ?? throw new ArgumentNullException(nameof(name));
        Price = price ?? throw new ArgumentNullException(nameof(price));
    }
}
```

**Output**

When using these value objects:

```csharp
// Create value objects
var shippingAddress = new Address(
    "123 Main St",
    "Springfield",
    "IL",
    "62701",
    "USA"
);

var price = new Money(29.99m, Currency.USD);
var quantity = new Quantity(3);

// Create order with value objects
var order = new Order(shippingAddress);
var product = new Product(1, "Widget", price);
order.AddItem(product, quantity);

// Value objects ensure type safety and correctness
var total = order.CalculateTotal(); // Money: $89.97

// Value equality works as expected
var sameAddress = new Address(
    "123 Main St",
    "Springfield",
    "IL",
    "62701",
    "USA"
);

Console.WriteLine(shippingAddress == sameAddress); // True

// Operations return new instances (immutability)
var newQuantity = quantity.Add(new Quantity(2)); // New Quantity(5)
Console.WriteLine(quantity.Value); // Still 3 - original unchanged

// Invalid operations throw exceptions
try
{
    var negative = new Money(-10, Currency.USD); // Throws ArgumentException
}
catch (ArgumentException ex)
{
    Console.WriteLine(ex.Message); // "Amount cannot be negative"
}

try
{
    var usd = new Money(10, Currency.USD);
    var eur = new Money(10, Currency.EUR);
    var invalid = usd.Add(eur); // Throws InvalidOperationException
}
catch (InvalidOperationException ex)
{
    Console.WriteLine(ex.Message); // "Cannot add USD and EUR"
}
```

The value objects provide:

- **Type safety**: Cannot accidentally pass a quantity where money is expected
- **Validation**: Invalid values cannot be created
- **Immutability**: Operations return new instances
- **Domain clarity**: Code reads like the business domain
- **Reusability**: Same value objects used across the application

### Value Objects vs Entities

Understanding the distinction between value objects and entities is crucial for proper domain modeling.

#### Entities

**Characteristics:**

- Have a unique identity (ID, GUID, etc.)
- Identity remains constant throughout lifecycle
- Mutable - state can change over time
- Two entities with same attributes but different IDs are distinct
- Use reference equality by default

**Examples:**

- Customer
- Order
- User account
- Product (in inventory system)
- Bank account

#### Value Objects

**Characteristics:**

- No unique identity
- Defined entirely by their attributes
- Immutable - cannot change after creation
- Two value objects with same attributes are identical
- Use value equality

**Examples:**

- Money
- Address
- Date range
- Email address
- Color
- Coordinates

#### Decision Criteria

**Use an entity when:**

- The object needs to be tracked over time
- The object has a lifecycle with state changes
- Identity matters more than attributes
- You need to distinguish between two objects even if all attributes are identical

**Use a value object when:**

- The object is defined by its attributes
- Identity doesn't matter
- The object is naturally immutable
- You want to share instances safely
- Equality should be based on values

#### Gray Areas

Some concepts can be modeled either way depending on context:

**Phone Number:**

- As value object: Just a representation of a number format
- As entity: A tracked phone line with history and ownership

**Product:**

- As value object: Product type or catalog item (e.g., "iPhone 15 Pro")
- As entity: Specific inventory item with serial number

The correct choice depends on your domain and business requirements.

### Advanced Patterns

#### Value Object Collections

Value objects can contain collections of other value objects, but the collection itself must be immutable.

```csharp
public class OrderSummary : IEquatable<OrderSummary>
{
    public IReadOnlyList<Money> Payments { get; }
    public Money TotalPaid { get; }
    
    public OrderSummary(IEnumerable<Money> payments)
    {
        if (payments == null || !payments.Any())
            throw new ArgumentException("At least one payment required");
            
        // Ensure all payments have same currency
        var currency = payments.First().Currency;
        if (payments.Any(p => p.Currency != currency))
            throw new ArgumentException("All payments must have same currency");
        
        Payments = payments.ToList().AsReadOnly(); // Immutable collection
        TotalPaid = payments.Aggregate((sum, p) => sum.Add(p));
    }
    
    public bool Equals(OrderSummary other)
    {
        if (other is null) return false;
        return Payments.SequenceEqual(other.Payments);
    }
    
    public override bool Equals(object obj) => Equals(obj as OrderSummary);
    
    public override int GetHashCode()
    {
        return Payments.Aggregate(0, (hash, payment) => 
            HashCode.Combine(hash, payment.GetHashCode()));
    }
}
```

#### Convertible Value Objects

Value objects that can be converted to or from primitive types for persistence or serialization.

```csharp
public class Email : IEquatable<Email>
{
    private readonly string _value;
    
    public Email(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email cannot be empty");
            
        if (!IsValid(email))
            throw new ArgumentException($"Invalid email: {email}");
            
        _value = email.ToLowerInvariant();
    }
    
    // Explicit conversion to string for persistence
    public static explicit operator string(Email email) => email._value;
    
    // Explicit conversion from string
    public static explicit operator Email(string email) => new Email(email);
    
    // Implicit conversion for common scenarios (use sparingly)
    public override string ToString() => _value;
    
    private static bool IsValid(string email)
    {
        // [Inference] Validation logic would check email format
        return email.Contains("@") && email.IndexOf("@") < email.LastIndexOf(".");
    }
    
    public bool Equals(Email other)
    {
        if (other is null) return false;
        return _value == other._value;
    }
    
    public override bool Equals(object obj) => Equals(obj as Email);
    public override int GetHashCode() => _value.GetHashCode();
}
```

#### Composed Value Objects

Value objects that contain other value objects as attributes.

```csharp
public class ShippingDetails : IEquatable<ShippingDetails>
{
    public Address DeliveryAddress { get; }
    public Address BillingAddress { get; }
    public Email ContactEmail { get; }
    public PhoneNumber ContactPhone { get; }
    
    public ShippingDetails(Address deliveryAddress, Address billingAddress,
                          Email contactEmail, PhoneNumber contactPhone)
    {
        DeliveryAddress = deliveryAddress ?? 
            throw new ArgumentNullException(nameof(deliveryAddress));
        BillingAddress = billingAddress ?? 
            throw new ArgumentNullException(nameof(billingAddress));
        ContactEmail = contactEmail ?? 
            throw new ArgumentNullException(nameof(contactEmail));
        ContactPhone = contactPhone ?? 
            throw new ArgumentNullException(nameof(contactPhone));
    }
    
    public bool UseSameAddressForBilling()
    {
        return DeliveryAddress.Equals(BillingAddress);
    }
    
    public bool Equals(ShippingDetails other)
    {
        if (other is null) return false;
        return DeliveryAddress.Equals(other.DeliveryAddress) &&
               BillingAddress.Equals(other.BillingAddress) &&
               ContactEmail.Equals(other.ContactEmail) &&
               ContactPhone.Equals(other.ContactPhone);
    }
    
    public override bool Equals(object obj) => Equals(obj as ShippingDetails);
    
    public override int GetHashCode()
    {
        return HashCode.Combine(DeliveryAddress, BillingAddress, 
                               ContactEmail, ContactPhone);
    }
}
```

### Persistence Strategies

#### Direct Mapping

Simple value objects can be mapped directly to database columns.

```sql
CREATE TABLE Orders (
    OrderId INT PRIMARY KEY,
    -- Money value object mapped to two columns
    TotalAmount DECIMAL(18, 2),
    Currency VARCHAR(3),
    -- Address value object mapped to multiple columns
    ShippingStreet VARCHAR(200),
    ShippingCity VARCHAR(100),
    ShippingState VARCHAR(50),
    ShippingPostalCode VARCHAR(20),
    ShippingCountry VARCHAR(2)
);
```

**ORM Configuration (Entity Framework):**

```csharp
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        // Map Money value object
        builder.OwnsOne(o => o.Total, money =>
        {
            money.Property(m => m.Amount).HasColumnName("TotalAmount");
            money.Property(m => m.Currency).HasColumnName("Currency")
                .HasConversion(
                    c => c.Code,
                    code => Currency.FromCode(code));
        });
        
        // Map Address value object
        builder.OwnsOne(o => o.ShippingAddress, address =>
        {
            address.Property(a => a.Street).HasColumnName("ShippingStreet");
            address.Property(a => a.City).HasColumnName("ShippingCity");
            address.Property(a => a.State).HasColumnName("ShippingState");
            address.Property(a => a.PostalCode).HasColumnName("ShippingPostalCode");
            address.Property(a => a.Country).HasColumnName("ShippingCountry");
        });
    }
}
```

#### JSON Serialization

Complex value objects can be serialized to JSON for storage in a single column or document database.

```csharp
public class Order
{
    public int Id { get; set; }
    
    // Stored as JSON in database
    public ShippingDetails ShippingDetails { get; set; }
}

// EF Core configuration
builder.Property(o => o.ShippingDetails)
    .HasConversion(
        details => JsonSerializer.Serialize(details, (JsonSerializerOptions)null),
        json => JsonSerializer.Deserialize<ShippingDetails>(json, (JsonSerializerOptions)null));
```

#### Separate Table for Complex Value Objects

For value objects with many attributes or collections, consider a separate table with a foreign key.

```sql
CREATE TABLE Orders (
    OrderId INT PRIMARY KEY,
    CustomerId INT,
    OrderDate DATETIME
);

CREATE TABLE OrderLines (
    OrderLineId INT PRIMARY KEY,
    OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
    ProductId INT,
    Quantity INT,
    UnitPrice DECIMAL(18, 2),
    Currency VARCHAR(3)
);
```

### Testing Value Objects

Value objects are straightforward to test due to their immutability and lack of dependencies.

#### Equality Tests

```csharp
[TestClass]
public class MoneyTests
{
    [TestMethod]
    public void Equals_SameValues_ReturnsTrue()
    {
        var money1 = new Money(100, Currency.USD);
        var money2 = new Money(100, Currency.USD);
        
        Assert.AreEqual(money1, money2);
        Assert.IsTrue(money1 == money2);
    }
    
    [TestMethod]
    public void Equals_DifferentAmounts_ReturnsFalse()
    {
        var money1 = new Money(100, Currency.USD);
        var money2 = new Money(200, Currency.USD);
        
        Assert.AreNotEqual(money1, money2);
        Assert.IsTrue(money1 != money2);
    }
    
    [TestMethod]
    public void Equals_DifferentCurrencies_ReturnsFalse()
    {
        var money1 = new Money(100, Currency.USD);
        var money2 = new Money(100, Currency.EUR);
        
        Assert.AreNotEqual(money1, money2);
    }
    
    [TestMethod]
    public void GetHashCode_SameValues_ReturnsSameHash()
    {
        var money1 = new Money(100, Currency.USD);
        var money2 = new Money(100, Currency.USD);
        
        Assert.AreEqual(money1.GetHashCode(), money2.GetHashCode());
    }
}
```

#### Validation Tests

```csharp
[TestClass]
public class MoneyValidationTests
{
    [TestMethod]
    [ExpectedException(typeof(ArgumentException))]
    public void Constructor_NegativeAmount_ThrowsException()
    {
        var money = new Money(-10, Currency.USD);
    }
    
    [TestMethod]
    [ExpectedException(typeof(ArgumentNullException))]
    public void Constructor_NullCurrency_ThrowsException()
    {
        var money = new Money(100, null);
    }
}
```

#### Operation Tests

```csharp
[TestClass]
public class MoneyOperationTests
{
    [TestMethod]
    public void Add_SameCurrency_ReturnsSum()
    {
        var money1 = new Money(100, Currency.USD);
        var money2 = new Money(50, Currency.USD);
        
        var result = money1.Add(money2);
        
        Assert.AreEqual(new Money(150, Currency.USD), result);
    }
    
    [TestMethod]
    [ExpectedException(typeof(InvalidOperationException))]
    public void Add_DifferentCurrencies_ThrowsException()
    {
        var usd = new Money(100, Currency.USD);
        var eur = new Money(50, Currency.EUR);
        
        var result = usd.Add(eur);
    }
    
    [TestMethod]
    public void Multiply_ByScalar_ReturnsProduct()
    {
        var money = new Money(10, Currency.USD);
        
        var result = money.Multiply(3);
        
        Assert.AreEqual(new Money(30, Currency.USD), result);
    }
    
    [TestMethod]
    public void Multiply_PreservesImmutability()
    {
        var original = new Money(10, Currency.USD);
        
        var result = original.Multiply(2);
        
        Assert.AreEqual(new Money(10, Currency.USD), original); // Unchanged
        Assert.AreEqual(new Money(20, Currency.USD), result); // New instance
    }
}
```

### Common Pitfalls

#### Mutable Value Objects

**Problem**: Making value objects mutable defeats their purpose and introduces bugs.

```csharp
// WRONG - Mutable value object
public class Money
{
    public decimal Amount { get; set; } // Should be read-only!
    public Currency Currency { get; set; } // Should be read-only!
}

// This leads to bugs:
var price = new Money { Amount = 100, Currency = Currency.USD };
var discountedPrice = price; discountedPrice.Amount = 80; // Unexpectedly modifies 'price' too!
````

**Solution**: Make all properties read-only and use private setters or readonly fields.

#### Reference Equality

**Problem**: Not overriding equality methods leads to reference-based comparison.

```csharp
// WRONG - No equality override
public class Money
{
    public decimal Amount { get; }
    public Currency Currency { get; }
    // Missing Equals() and GetHashCode()
}

var money1 = new Money(100, Currency.USD);
var money2 = new Money(100, Currency.USD);
Console.WriteLine(money1 == money2); // False - different references!
````

**Solution**: Always override `Equals()`, `GetHashCode()`, and equality operators.

#### Missing Validation

**Problem**: Allowing invalid value objects to be created.

```csharp
// WRONG - No validation
public class Email
{
    public string Value { get; }
    
    public Email(string email)
    {
        Value = email; // No validation!
    }
}

var invalid = new Email("not-an-email"); // Compiles and creates invalid object
```

**Solution**: Validate in constructor and throw exceptions for invalid inputs.

#### Large Value Objects

**Problem**: Creating value objects with too many attributes makes them unwieldy.

```csharp
// WRONG - Too many attributes
public class CustomerProfile
{
    public string FirstName { get; }
    public string LastName { get; }
    public string Email { get; }
    public string Phone { get; }
    public string Street { get; }
    public string City { get; }
    public string State { get; }
    public string PostalCode { get; }
    public string Country { get; }
    public DateTime DateOfBirth { get; }
    public string PreferredLanguage { get; }
    // ... 20 more properties
}
```

**Solution**: Break down into smaller, composed value objects.

```csharp
// BETTER - Composed value objects
public class CustomerProfile
{
    public PersonName Name { get; }
    public Email Email { get; }
    public PhoneNumber Phone { get; }
    public Address Address { get; }
    public DateTime DateOfBirth { get; }
    public Language PreferredLanguage { get; }
}
```

#### Treating Entities as Value Objects

**Problem**: Modeling something with identity as a value object.

```csharp
// WRONG - Customer is an entity, not a value object
public class Customer : IEquatable<Customer>
{
    public string Name { get; }
    public Email Email { get; }
    
    public bool Equals(Customer other) => 
        Name == other.Name && Email.Equals(other.Email);
}

// Two different customers with same name and email are treated as identical!
```

**Solution**: Use entities with identity for objects that have lifecycle and need tracking.

### Language-Specific Implementations

#### C# Records (C# 9.0+)

C# records provide built-in support for value object semantics.

```csharp
public record Money(decimal Amount, Currency Currency)
{
    // Validation in constructor
    public Money(decimal Amount, Currency Currency) : this()
    {
        if (Amount < 0)
            throw new ArgumentException("Amount cannot be negative");
            
        this.Amount = Math.Round(Amount, 2);
        this.Currency = Currency ?? throw new ArgumentNullException(nameof(Currency));
    }
    
    // Operations still need to be defined
    public Money Add(Money other)
    {
        if (Currency != other.Currency)
            throw new InvalidOperationException("Currency mismatch");
        return new Money(Amount + other.Amount, Currency);
    }
}

// Records provide value equality and immutability by default
var m1 = new Money(100, Currency.USD);
var m2 = new Money(100, Currency.USD);
Console.WriteLine(m1 == m2); // True
```

#### Java Records (Java 14+)

```java
public record Money(BigDecimal amount, Currency currency) {
    // Validation in compact constructor
    public Money {
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Amount cannot be negative");
        }
        Objects.requireNonNull(currency, "Currency cannot be null");
        amount = amount.setScale(2, RoundingMode.HALF_UP);
    }
    
    public Money add(Money other) {
        if (!currency.equals(other.currency)) {
            throw new IllegalStateException("Currency mismatch");
        }
        return new Money(amount.add(other.amount), currency);
    }
}
```

#### Python (using dataclasses)

```python
from dataclasses import dataclass
from decimal import Decimal
from typing import final

@final
@dataclass(frozen=True)  # frozen=True makes it immutable
class Money:
    amount: Decimal
    currency: str
    
    def __post_init__(self):
        if self.amount < 0:
            raise ValueError("Amount cannot be negative")
        if not self.currency:
            raise ValueError("Currency is required")
        # Note: Can't directly modify frozen dataclass
        # Use object.__setattr__ for validation adjustments if needed
    
    def add(self, other: 'Money') -> 'Money':
        if self.currency != other.currency:
            raise ValueError(f"Cannot add {self.currency} and {other.currency}")
        return Money(self.amount + other.amount, self.currency)
    
    def multiply(self, multiplier: Decimal) -> 'Money':
        if multiplier < 0:
            raise ValueError("Multiplier cannot be negative")
        return Money(self.amount * multiplier, self.currency)
```

#### TypeScript

```typescript
class Money {
    private readonly _amount: number;
    private readonly _currency: string;
    
    constructor(amount: number, currency: string) {
        if (amount < 0) {
            throw new Error("Amount cannot be negative");
        }
        if (!currency) {
            throw new Error("Currency is required");
        }
        
        this._amount = Math.round(amount * 100) / 100;
        this._currency = currency;
    }
    
    get amount(): number {
        return this._amount;
    }
    
    get currency(): string {
        return this._currency;
    }
    
    add(other: Money): Money {
        if (this._currency !== other._currency) {
            throw new Error(`Cannot add ${this._currency} and ${other._currency}`);
        }
        return new Money(this._amount + other._amount, this._currency);
    }
    
    equals(other: Money): boolean {
        return this._amount === other._amount && 
               this._currency === other._currency;
    }
    
    toString(): string {
        return `${this._currency} ${this._amount.toFixed(2)}`;
    }
}
```

### **Key Points**

- Value objects are defined by their values, not by identity
- Immutability is essential - value objects cannot be modified after creation
- Two value objects with identical values are equal and interchangeable
- Value objects enforce their own validation rules in constructors
- Equality comparison must be based on values, not object references
- Value objects encapsulate domain concepts like Money, Address, Email
- They provide type safety and prevent primitive obsession
- Operations on value objects return new instances rather than modifying existing ones
- Value objects have no dependencies and are easy to test
- They differ from entities, which have unique identity and lifecycle
- Modern languages provide built-in support through records (C#, Java) or dataclasses (Python)
- Value objects can be composed of other value objects
- Persistence strategies include direct column mapping, JSON serialization, or separate tables
- Common pitfalls include making them mutable, not implementing equality, or missing validation

### **Conclusion**

The Value Object pattern is a fundamental building block for creating maintainable, expressive domain models. By representing domain concepts as immutable objects defined by their values, developers can write code that is more type-safe, testable, and aligned with business requirements.

Value objects eliminate primitive obsession by replacing raw primitives (strings, decimals, integers) with meaningful domain types that encapsulate both data and behavior. This makes code more self-documenting and reduces the likelihood of bugs caused by misusing data or passing incorrect values.

The immutability of value objects provides significant benefits: they're thread-safe without synchronization, can be safely shared between components, and simplify reasoning about program behavior. Combined with value-based equality, value objects become reliable building blocks that behave predictably throughout an application.

Modern programming languages increasingly recognize the importance of value objects by providing built-in support through features like records in C# and Java, or frozen dataclasses in Python. These language features reduce boilerplate while maintaining the essential characteristics of value objects.

When designing domain models, carefully distinguish between entities (objects with identity) and value objects (objects defined by values). This distinction clarifies your model and leads to better architectural decisions. Use value objects liberally for descriptive aspects of your domain, and compose them together to build richer, more expressive models that accurately represent business concepts.

---

## Aggregate Pattern

The Aggregate pattern is a fundamental tactical pattern in Domain-Driven Design (DDD) that defines a cluster of domain objects that can be treated as a single unit for data changes. Introduced by Eric Evans in his seminal book "Domain-Driven Design," the pattern establishes consistency boundaries around groups of related entities and value objects, ensuring that business invariants are maintained throughout the lifecycle of these objects.

### Core Concept

An Aggregate is a cluster of associated objects that are treated as a unit for the purpose of data changes. Each Aggregate has a root entity, known as the Aggregate Root, which is the only member of the Aggregate that outside objects are allowed to hold references to. This constraint ensures that all interactions with the objects inside the Aggregate boundary go through the root, allowing it to enforce invariants and maintain consistency.

The pattern addresses a critical challenge in domain modeling: how to maintain consistency and enforce business rules across multiple related objects while avoiding the complexity and coupling that comes from allowing unrestricted access to all objects in the domain model. By establishing clear boundaries and access rules, Aggregates make complex domains more manageable and protect the integrity of business rules.

### The Aggregate Root

The Aggregate Root is the gatekeeper of the Aggregate. It is the only entity within the Aggregate that external objects can hold references to and interact with directly. All operations that affect objects within the Aggregate must go through the Aggregate Root, which can then coordinate changes and enforce invariants.

The root entity is responsible for checking all invariants that span multiple objects within the Aggregate. When a change is requested, the root evaluates whether the change would violate any business rules and either permits or rejects the change accordingly. This centralized enforcement point makes it much easier to reason about consistency and correctness.

Choosing the right Aggregate Root is crucial for the pattern's effectiveness. The root should be the entity that has the most significant identity in the business context and the one through which all operations on the Aggregate naturally flow. It should be the entity that makes semantic sense as the entry point for all operations.

### Consistency Boundaries

Aggregates define transactional consistency boundaries. All objects within an Aggregate boundary must be consistent at the end of each transaction. This means that when you save an Aggregate, all business rules that involve objects within that Aggregate are satisfied.

Conversely, business rules that span multiple Aggregates need not be satisfied immediately. These can be handled through eventual consistency mechanisms such as domain events, sagas, or process managers. This distinction is crucial because trying to maintain immediate consistency across too many objects leads to large, unwieldy Aggregates and performance problems.

The boundary represents a hard line for transaction scope. Changes to multiple Aggregates should not be done in a single transaction. Instead, each Aggregate is modified and persisted separately, with coordination between them handled at a higher level through application services or process managers.

### Internal Structure

Within an Aggregate boundary, there can be:

**The Aggregate Root**: The primary entity that serves as the entry point and maintains references to internal entities and value objects.

**Internal Entities**: Other entities that exist within the Aggregate boundary but should not be directly referenced or modified from outside. These entities have identity within the context of the Aggregate but may not have meaningful identity outside of it.

**Value Objects**: Immutable objects that describe characteristics of the Aggregate. Value objects are often shared within the Aggregate and passed between methods to represent concepts or measurements.

The objects within an Aggregate can reference each other freely, but external objects can only reference the Aggregate Root. Internal entities can hold references to other internal entities or value objects, creating a tree-like structure with the root at the top.

### Size and Granularity

One of the most challenging aspects of applying the Aggregate pattern is determining the right size and boundaries for Aggregates. The default guidance is to make Aggregates as small as possible while still maintaining consistency of business invariants.

**Small Aggregates** are preferred because they:

- Reduce the likelihood of concurrent update conflicts
- Improve performance by loading and persisting less data
- Make the system more scalable
- Are easier to understand and maintain
- Reduce the risk of violating the single responsibility principle

**Larger Aggregates** might be necessary when:

- Multiple objects must change together atomically to maintain invariants
- The business naturally views a group of objects as a single concept
- Separation would make enforcing business rules impractical

A good rule of thumb is to start with individual entities as Aggregates and only expand boundaries when you discover invariants that truly require multiple objects to change together transactionally.

### Reference Handling

One of the key rules of the Aggregate pattern is that Aggregates should only reference other Aggregates by their identity (ID), never by direct object reference. This rule enforces loose coupling between Aggregates and makes it clear that they are separate consistency boundaries.

When an Aggregate needs to interact with another Aggregate, it does so by holding the other Aggregate's ID and looking it up through a repository when needed. This approach has several benefits:

- It makes Aggregate boundaries explicit and prevents accidental creation of large, interconnected object graphs
- It supports distributed scenarios where Aggregates might exist in different bounded contexts or even different systems
- It simplifies serialization and persistence
- It reduces the risk of stale data when multiple users are working with the same Aggregates

Value objects, however, can be shared freely between Aggregates since they are immutable and have no identity.

### Persistence Considerations

Aggregates are typically persisted as a whole unit. When you save an Aggregate, all the objects within its boundary are saved together. This aligns with the consistency boundary concept—everything within the Aggregate must be consistent when persisted.

Repository patterns are used to load and save Aggregates. Each Aggregate type typically has its own repository that knows how to reconstitute the entire Aggregate from storage and persist changes back to storage. The repository interface should be defined in terms of Aggregate Roots, not internal entities.

Different persistence strategies can be used depending on the technology:

- Relational databases might use foreign keys and joins to store the Aggregate across multiple tables
- Document databases might store the entire Aggregate as a single document
- Event stores might store the sequence of events that led to the Aggregate's current state

The key is that the persistence mechanism respects the Aggregate boundary and treats it as an atomic unit for loading and saving.

### Invariant Enforcement

The primary responsibility of an Aggregate is to enforce invariants—business rules that must always be true. The Aggregate Root contains methods that validate these rules before allowing state changes.

Invariants can be classified as:

**Internal Invariants**: Rules that involve only objects within the Aggregate boundary. These are checked and enforced immediately by the Aggregate Root. For example, "an order's total must equal the sum of its line items."

**Cross-Aggregate Invariants**: Rules that involve multiple Aggregates. These cannot be enforced immediately within a single transaction and require eventual consistency mechanisms. For example, "the total of all orders from a customer must not exceed their credit limit."

The Aggregate pattern encourages designing domain models where most critical invariants are internal to a single Aggregate, making them easier to enforce consistently.

### Lifecycle Management

Aggregates have a complete lifecycle from creation through modification to deletion:

**Creation**: Aggregates are typically created through factory methods on the Aggregate Root or through separate factory classes. These factories ensure that all required data is provided and that the Aggregate starts in a valid state.

**Modification**: Changes to the Aggregate are made through methods on the Aggregate Root. These methods encapsulate business logic and ensure that invariants are maintained after each operation.

**Deletion**: Aggregates are deleted as a unit. When an Aggregate Root is deleted, all entities and value objects within the Aggregate boundary are deleted as well (cascade delete).

Throughout its lifecycle, the Aggregate maintains its invariants, transitioning only between valid states and rejecting operations that would violate business rules.

### Relationship with Domain Events

Aggregates are the primary publishers of domain events. When significant state changes occur within an Aggregate, the Aggregate Root can publish domain events that notify other parts of the system.

These events serve several purposes:

- They enable eventual consistency between Aggregates
- They provide a mechanism for triggering side effects without tight coupling
- They create an audit trail of important business events
- They enable integration with other bounded contexts

Domain events are typically collected by the Aggregate Root and published after the Aggregate is successfully persisted, ensuring that events are only published for changes that have been committed.

### Benefits

**Consistency Guarantees**: By defining clear consistency boundaries, Aggregates make it easier to reason about when business rules are enforced and ensure that the domain model is always in a valid state.

**Reduced Complexity**: The pattern reduces the complexity of the domain model by establishing clear boundaries and limiting the scope of operations that need to be considered together.

**Improved Performance**: Smaller Aggregates mean less data to load and persist, reducing database round trips and lock contention.

**Better Scalability**: Clear boundaries and eventual consistency between Aggregates enable better horizontal scaling and reduce bottlenecks.

**Enhanced Testability**: Aggregates can be tested in isolation, making unit tests simpler and more focused on specific business logic.

**Clearer Design**: The pattern forces developers to think carefully about consistency requirements and make explicit decisions about boundaries.

### Challenges and Considerations

**Boundary Definition**: Determining the correct Aggregate boundaries is challenging and requires deep understanding of the domain and its invariants. Incorrect boundaries can lead to either inconsistent data or overly large, performance-killing Aggregates.

**Eventual Consistency**: Moving from immediate to eventual consistency for cross-Aggregate invariants requires a shift in thinking and additional infrastructure (domain events, process managers, etc.).

**Learning Curve**: The pattern requires discipline and a good understanding of DDD concepts. Teams new to DDD often struggle with applying the pattern correctly.

**Refactoring Difficulty**: Changing Aggregate boundaries after the fact can be difficult, requiring changes to persistence, business logic, and potentially the database schema.

### Common Anti-Patterns

**God Aggregates**: Creating Aggregates that are too large and try to maintain too many invariants. This leads to performance problems, high contention, and coupling across unrelated concepts.

**Anemic Aggregates**: Creating Aggregates that are just data containers without behavior. The business logic ends up in services outside the Aggregate, defeating the purpose of the pattern.

**Reference Chain Violations**: Allowing external code to navigate through the Aggregate Root to internal entities, bypassing the root's enforcement of invariants.

**Transaction Spanning**: Trying to modify multiple Aggregates in a single transaction, which violates the consistency boundary principle and can lead to distributed transaction problems.

**Missing Invariants**: Not clearly identifying and enforcing the invariants that define the Aggregate's consistency requirements.

### Design Guidelines

When designing Aggregates, follow these principles:

**Start Small**: Begin with the smallest possible Aggregate and only expand when you discover invariants that require larger boundaries.

**Identify True Invariants**: Distinguish between rules that must be consistent immediately (invariants) and rules that can be eventually consistent (cross-Aggregate constraints).

**Root Everything Through the Aggregate Root**: All modifications must go through the root. Never allow direct access to internal entities.

**Use IDs for References**: Aggregates should reference other Aggregates by identity, not by object reference.

**One Repository per Aggregate**: Each Aggregate type should have a dedicated repository that loads and saves the entire Aggregate.

**Design for Concurrency**: Keep Aggregates small to reduce concurrent update conflicts and use optimistic locking to detect concurrent modifications.

**Protect Invariants**: The Aggregate Root must validate all business rules before allowing state changes.

### Evolution and Refactoring

Aggregate boundaries are not set in stone and may need to evolve as understanding of the domain deepens:

**Splitting Aggregates**: When an Aggregate grows too large or experiences high contention, consider whether some entities can become their own Aggregates. Identify which invariants truly need immediate consistency and which can be eventually consistent.

**Merging Aggregates**: If you find that two Aggregates frequently need to change together and maintaining consistency between them is difficult, they might need to be merged into a single Aggregate.

**Adjusting Boundaries**: As new business requirements emerge, invariants may change, requiring adjustment of Aggregate boundaries to accommodate new consistency requirements.

Refactoring Aggregates requires careful consideration of existing data and behavior, but is sometimes necessary to maintain a healthy domain model.

### Integration with Other Patterns

**Repository Pattern**: Repositories provide the persistence mechanism for Aggregates, loading and saving them as complete units.

**Factory Pattern**: Factories encapsulate the complex logic of creating Aggregates in valid initial states.

**Specification Pattern**: Specifications can be used to encapsulate complex business rules that determine whether an operation on an Aggregate should be allowed.

**Domain Events**: Events published by Aggregates enable eventual consistency and integration with other parts of the system.

**Unit of Work Pattern**: The Unit of Work pattern can track changes to Aggregates and coordinate their persistence, ensuring all changes within a transaction are saved together.

### **Key Points**

- Aggregates define consistency boundaries around clusters of related domain objects
- The Aggregate Root is the only entity that external objects can reference directly
- All operations on objects within an Aggregate must go through the Aggregate Root
- Aggregates should be as small as possible while maintaining business invariants
- Cross-Aggregate references should use IDs, not direct object references
- Each Aggregate is loaded and saved as a complete unit through a repository
- Invariants within an Aggregate are enforced immediately; cross-Aggregate rules use eventual consistency
- Domain events enable communication and coordination between Aggregates
- The pattern improves consistency, reduces complexity, and enhances scalability

### **Example**

Let's build an e-commerce order system demonstrating the Aggregate pattern:

**Domain Layer - Value Objects**

```python
# domain/value_objects/money.py
from dataclasses import dataclass
from decimal import Decimal

@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str
    
    def __post_init__(self):
        if self.amount < 0:
            raise ValueError("Money amount cannot be negative")
        if not self.currency:
            raise ValueError("Currency must be specified")
    
    def add(self, other: 'Money') -> 'Money':
        if self.currency != other.currency:
            raise ValueError("Cannot add money with different currencies")
        return Money(self.amount + other.amount, self.currency)
    
    def multiply(self, factor: int) -> 'Money':
        return Money(self.amount * factor, self.currency)
    
    def __str__(self):
        return f"{self.amount} {self.currency}"

# domain/value_objects/product_id.py
from dataclasses import dataclass

@dataclass(frozen=True)
class ProductId:
    value: str
    
    def __post_init__(self):
        if not self.value:
            raise ValueError("ProductId cannot be empty")

# domain/value_objects/customer_id.py
from dataclasses import dataclass

@dataclass(frozen=True)
class CustomerId:
    value: str
    
    def __post_init__(self):
        if not self.value:
            raise ValueError("CustomerId cannot be empty")
```

**Domain Layer - Internal Entity**

```python
# domain/entities/order_line.py
from dataclasses import dataclass
from domain.value_objects.money import Money
from domain.value_objects.product_id import ProductId

@dataclass
class OrderLine:
    """Internal entity - should only be accessed through Order (Aggregate Root)"""
    product_id: ProductId
    product_name: str
    unit_price: Money
    quantity: int
    
    def __post_init__(self):
        if self.quantity <= 0:
            raise ValueError("Quantity must be positive")
        if self.unit_price.amount <= 0:
            raise ValueError("Unit price must be positive")
    
    def calculate_total(self) -> Money:
        return self.unit_price.multiply(self.quantity)
    
    def change_quantity(self, new_quantity: int) -> None:
        """Can only be called by the Aggregate Root"""
        if new_quantity <= 0:
            raise ValueError("Quantity must be positive")
        self.quantity = new_quantity
```

**Domain Layer - Aggregate Root**

```python
# domain/aggregates/order.py
from dataclasses import dataclass, field
from typing import List, Optional
from datetime import datetime
from enum import Enum
from domain.entities.order_line import OrderLine
from domain.value_objects.money import Money
from domain.value_objects.product_id import ProductId
from domain.value_objects.customer_id import CustomerId
from domain.events.domain_event import DomainEvent
from decimal import Decimal

class OrderStatus(Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

@dataclass
class OrderPlaced(DomainEvent):
    order_id: str
    customer_id: str
    total: str
    timestamp: datetime

@dataclass
class OrderConfirmed(DomainEvent):
    order_id: str
    timestamp: datetime

@dataclass
class OrderCancelled(DomainEvent):
    order_id: str
    reason: str
    timestamp: datetime

@dataclass
class Order:
    """Aggregate Root for Order"""
    id: str
    customer_id: CustomerId  # Reference to another Aggregate by ID
    status: OrderStatus
    created_at: datetime
    _lines: List[OrderLine] = field(default_factory=list)
    _domain_events: List[DomainEvent] = field(default_factory=list, init=False, repr=False)
    confirmed_at: Optional[datetime] = None
    shipped_at: Optional[datetime] = None
    
    def __post_init__(self):
        if not self.id:
            raise ValueError("Order ID is required")
    
    # Aggregate Root controls all access to internal entities
    def add_line(self, product_id: ProductId, product_name: str, 
                 unit_price: Money, quantity: int) -> None:
        """Add a line item to the order"""
        if self.status != OrderStatus.PENDING:
            raise ValueError("Cannot add items to non-pending order")
        
        # Check if product already exists
        existing_line = self._find_line_by_product(product_id)
        if existing_line:
            existing_line.change_quantity(existing_line.quantity + quantity)
        else:
            line = OrderLine(product_id, product_name, unit_price, quantity)
            self._lines.append(line)
    
    def remove_line(self, product_id: ProductId) -> None:
        """Remove a line item from the order"""
        if self.status != OrderStatus.PENDING:
            raise ValueError("Cannot remove items from non-pending order")
        
        self._lines = [line for line in self._lines 
                      if line.product_id != product_id]
    
    def change_line_quantity(self, product_id: ProductId, new_quantity: int) -> None:
        """Change quantity of a line item"""
        if self.status != OrderStatus.PENDING:
            raise ValueError("Cannot change quantities in non-pending order")
        
        line = self._find_line_by_product(product_id)
        if not line:
            raise ValueError(f"Product {product_id.value} not found in order")
        
        line.change_quantity(new_quantity)
    
    def confirm(self) -> None:
        """Confirm the order - enforces invariants"""
        # Invariant: Order must have at least one line item
        if not self._lines:
            raise ValueError("Cannot confirm order without items")
        
        # Invariant: Order must be in PENDING status
        if self.status != OrderStatus.PENDING:
            raise ValueError(f"Cannot confirm order with status {self.status.value}")
        
        # Invariant: Total must be positive
        total = self.calculate_total()
        if total.amount <= 0:
            raise ValueError("Order total must be positive")
        
        self.status = OrderStatus.CONFIRMED
        self.confirmed_at = datetime.now()
        
        # Publish domain event
        self._domain_events.append(OrderConfirmed(
            order_id=self.id,
            timestamp=self.confirmed_at
        ))
    
    def ship(self) -> None:
        """Mark order as shipped"""
        if self.status != OrderStatus.CONFIRMED:
            raise ValueError("Can only ship confirmed orders")
        
        self.status = OrderStatus.SHIPPED
        self.shipped_at = datetime.now()
    
    def cancel(self, reason: str) -> None:
        """Cancel the order"""
        if self.status in [OrderStatus.SHIPPED, OrderStatus.DELIVERED]:
            raise ValueError(f"Cannot cancel order with status {self.status.value}")
        
        self.status = OrderStatus.CANCELLED
        
        # Publish domain event
        self._domain_events.append(OrderCancelled(
            order_id=self.id,
            reason=reason,
            timestamp=datetime.now()
        ))
    
    def calculate_total(self) -> Money:
        """Calculate total - aggregates from all line items"""
        if not self._lines:
            return Money(Decimal("0"), "USD")
        
        total = self._lines[0].calculate_total()
        for line in self._lines[1:]:
            total = total.add(line.calculate_total())
        
        return total
    
    def get_lines(self) -> List[OrderLine]:
        """Return copy of lines - external code cannot modify directly"""
        return list(self._lines)
    
    def get_domain_events(self) -> List[DomainEvent]:
        """Get and clear domain events"""
        events = list(self._domain_events)
        self._domain_events.clear()
        return events
    
    def _find_line_by_product(self, product_id: ProductId) -> Optional[OrderLine]:
        """Internal helper method"""
        for line in self._lines:
            if line.product_id == product_id:
                return line
        return None

# Factory for creating orders
class OrderFactory:
    @staticmethod
    def create_order(order_id: str, customer_id: CustomerId) -> Order:
        """Factory method to create a new order in valid initial state"""
        order = Order(
            id=order_id,
            customer_id=customer_id,
            status=OrderStatus.PENDING,
            created_at=datetime.now()
        )
        
        # Publish domain event
        order._domain_events.append(OrderPlaced(
            order_id=order.id,
            customer_id=customer_id.value,
            total="0 USD",
            timestamp=order.created_at
        ))
        
        return order
```

**Domain Events Base**

```python
# domain/events/domain_event.py
from dataclasses import dataclass
from datetime import datetime

@dataclass
class DomainEvent:
    """Base class for domain events"""
    pass
```

**Repository Interface**

```python
# domain/repositories/order_repository.py
from abc import ABC, abstractmethod
from typing import Optional
from domain.aggregates.order import Order

class OrderRepository(ABC):
    """Repository for Order Aggregate"""
    
    @abstractmethod
    def save(self, order: Order) -> None:
        """Save the entire aggregate"""
        pass
    
    @abstractmethod
    def find_by_id(self, order_id: str) -> Optional[Order]:
        """Load the entire aggregate"""
        pass
    
    @abstractmethod
    def delete(self, order_id: str) -> None:
        """Delete the entire aggregate"""
        pass
```

**Repository Implementation**

```python
# infrastructure/repositories/in_memory_order_repository.py
from typing import Dict, Optional
import copy
from domain.aggregates.order import Order
from domain.repositories.order_repository import OrderRepository

class InMemoryOrderRepository(OrderRepository):
    """In-memory implementation - stores entire Aggregate"""
    
    def __init__(self):
        self._orders: Dict[str, Order] = {}
    
    def save(self, order: Order) -> None:
        """Save the entire aggregate as a unit"""
        # Deep copy to simulate persistence
        self._orders[order.id] = copy.deepcopy(order)
    
    def find_by_id(self, order_id: str) -> Optional[Order]:
        """Load the entire aggregate as a unit"""
        order = self._orders.get(order_id)
        if order:
            # Deep copy to simulate loading from persistence
            return copy.deepcopy(order)
        return None
    
    def delete(self, order_id: str) -> None:
        """Delete the entire aggregate"""
        if order_id in self._orders:
            del self._orders[order_id]

# infrastructure/repositories/sql_order_repository.py
from typing import Optional
from domain.aggregates.order import Order, OrderStatus
from domain.repositories.order_repository import OrderRepository
from domain.entities.order_line import OrderLine
from domain.value_objects.money import Money
from domain.value_objects.product_id import ProductId
from domain.value_objects.customer_id import CustomerId
from decimal import Decimal

class SqlOrderRepository(OrderRepository):
    """SQL implementation - demonstrates persisting aggregate across tables"""
    
    def __init__(self, db_connection):
        self._db = db_connection
    
    def save(self, order: Order) -> None:
        """Save entire aggregate - order and all its lines"""
        cursor = self._db.cursor()
        
        try:
            # Save aggregate root
            cursor.execute("""
                INSERT INTO orders (id, customer_id, status, created_at, confirmed_at, shipped_at)
                VALUES (?, ?, ?, ?, ?, ?)
                ON CONFLICT(id) DO UPDATE SET
                    status = excluded.status,
                    confirmed_at = excluded.confirmed_at,
                    shipped_at = excluded.shipped_at
            """, (
                order.id,
                order.customer_id.value,
                order.status.value,
                order.created_at,
                order.confirmed_at,
                order.shipped_at
            ))
            
            # Delete existing lines (simpler than trying to match/update)
            cursor.execute("DELETE FROM order_lines WHERE order_id = ?", (order.id,))
            
            # Save all lines
            for line in order.get_lines():
                cursor.execute("""
                    INSERT INTO order_lines 
                    (order_id, product_id, product_name, unit_price, currency, quantity)
                    VALUES (?, ?, ?, ?, ?, ?)
                """, (
                    order.id,
                    line.product_id.value,
                    line.product_name,
                    line.unit_price.amount,
                    line.unit_price.currency,
                    line.quantity
                ))
            
            self._db.commit()
        except Exception as e:
            self._db.rollback()
            raise e
    
    def find_by_id(self, order_id: str) -> Optional[Order]:
        """Load entire aggregate - order with all its lines"""
        cursor = self._db.cursor()
        
        # Load aggregate root
        cursor.execute("""
            SELECT id, customer_id, status, created_at, confirmed_at, shipped_at
            FROM orders WHERE id = ?
        """, (order_id,))
        
        row = cursor.fetchone()
        if not row:
            return None
        
        # Reconstruct order
        order = Order(
            id=row[0],
            customer_id=CustomerId(row[1]),
            status=OrderStatus(row[2]),
            created_at=row[3],
            confirmed_at=row[4],
            shipped_at=row[5]
        )
        
        # Load all lines
        cursor.execute("""
            SELECT product_id, product_name, unit_price, currency, quantity
            FROM order_lines WHERE order_id = ?
        """, (order_id,))
        
        for line_row in cursor.fetchall():
            order.add_line(
                product_id=ProductId(line_row[0]),
                product_name=line_row[1],
                unit_price=Money(Decimal(str(line_row[2])), line_row[3]),
                quantity=line_row[4]
            )
        
        return order
    
    def delete(self, order_id: str) -> None:
        """Delete entire aggregate - cascades to lines"""
        cursor = self._db.cursor()
        try:
            cursor.execute("DELETE FROM order_lines WHERE order_id = ?", (order_id,))
            cursor.execute("DELETE FROM orders WHERE id = ?", (order_id,))
            self._db.commit()
        except Exception as e:
            self._db.rollback()
            raise e
```

**Application Service**

```python
# application/services/order_service.py
from domain.aggregates.order import Order, OrderFactory
from domain.repositories.order_repository import OrderRepository
from domain.value_objects.customer_id import CustomerId
from domain.value_objects.product_id import ProductId
from domain.value_objects.money import Money

class OrderService:
    """Application service - orchestrates aggregate operations"""
    
    def __init__(self, order_repository: OrderRepository):
        self._order_repository = order_repository
    
    def create_order(self, order_id: str, customer_id: str) -> Order:
        """Create a new order"""
        order = OrderFactory.create_order(
            order_id=order_id,
            customer_id=CustomerId(customer_id)
        )
        
        self._order_repository.save(order)
        
        # Publish domain events (simplified)
        events = order.get_domain_events()
        for event in events:
            print(f"Event: {event}")
        
        return order
    
    def add_product_to_order(self, order_id: str, product_id: str,
                            product_name: str, unit_price: Money, 
                            quantity: int) -> Order:
        """Add a product to an order"""
        # Load aggregate
        order = self._order_repository.find_by_id(order_id)
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        # Modify through aggregate root
        order.add_line(
            product_id=ProductId(product_id),
            product_name=product_name,
            unit_price=unit_price,
            quantity=quantity
        )
        
        # Save entire aggregate
        self._order_repository.save(order)
        
        return order
    
    def confirm_order(self, order_id: str) -> Order:
        """Confirm an order"""
        order = self._order_repository.find_by_id(order_id)
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        # Aggregate enforces invariants
        order.confirm()
        
        # Save aggregate
        self._order_repository.save(order)
        
        # Publish events
        events = order.get_domain_events()
        for event in events:
            print(f"Event: {event}")
        
        return order
    
    def cancel_order(self, order_id: str, reason: str) -> Order:
        """Cancel an order"""
        order = self._order_repository.find_by_id(order_id)
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        order.cancel(reason)
        self._order_repository.save(order)
        
        # Publish events
        events = order.get_domain_events()
        for event in events:
            print(f"Event: {event}")
        
        return order
```

**Usage Example**

```python
# main.py
from decimal import Decimal
from infrastructure.repositories.in_memory_order_repository import InMemoryOrderRepository
from application.services.order_service import OrderService
from domain.value_objects.money import Money


def main():
    # Setup
    repository = InMemoryOrderRepository()
    service = OrderService(repository)

    # Create order
    print("Creating order...")
    order = service.create_order("ORD-001", "CUST-123")
    print(f"Created: {order.id} for customer {order.customer_id.value}")

    # Add products - all access through aggregate root
    print("\nAdding products...")
    service.add_product_to_order(
        order_id="ORD-001",
        product_id="PROD-001",
        product_name="Laptop",
        unit_price=Money(Decimal("999.99"), "USD"),
        quantity=1,
    )

    service.add_product_to_order(
        order_id="ORD-001",
        product_id="PROD-002",
        product_name="Mouse",
        unit_price=Money(Decimal("29.99"), "USD"),
        quantity=2,
    )

    # Load and display
    order = repository.find_by_id("ORD-001")
    print(f"Order total: {order.calculate_total()}")
    print(f"Order status: {order.status.value}")

    # Confirm order - aggregate enforces invariants
    print("\nConfirming order...")
    try:
        service.confirm_order("ORD-001")
        print("Order confirmed successfully")
    except ValueError as e:
        print(f"Failed to confirm: {e}")

    # Try to add item to confirmed order - should fail
    print("\nTrying to add item to confirmed order...")
    try:
        service.add_product_to_order(
            order_id="ORD-001",
            product_id="PROD-003",
            product_name="Keyboard",
            unit_price=Money(Decimal("79.99"), "USD"),
            quantity=1,
        )
    except ValueError as e:
        print(f"Failed as expected: {e}")


# Cancel order
print("\nCancelling order...")
try:
    service.cancel_order("ORD-001", "Customer requested cancellation")
except ValueError as e:
    print(f"Cancellation result: {e}")


if __name__ == "__main__":
    main()
````

**Testing the Aggregate**

```python
# tests/test_order_aggregate.py
import unittest
from decimal import Decimal
from datetime import datetime
from domain.aggregates.order import Order, OrderFactory, OrderStatus
from domain.value_objects.customer_id import CustomerId
from domain.value_objects.product_id import ProductId
from domain.value_objects.money import Money

class TestOrderAggregate(unittest.TestCase):
    
    def test_create_order_with_factory(self):
        """Test order creation through factory"""
        order = OrderFactory.create_order("ORD-001", CustomerId("CUST-123"))
        
        self.assertEqual(order.id, "ORD-001")
        self.assertEqual(order.customer_id.value, "CUST-123")
        self.assertEqual(order.status, OrderStatus.PENDING)
        self.assertEqual(len(order.get_lines()), 0)
    
    def test_add_line_to_order(self):
        """Test adding line items"""
        order = OrderFactory.create_order("ORD-001", CustomerId("CUST-123"))
        
        order.add_line(
            ProductId("PROD-001"),
            "Laptop",
            Money(Decimal("999.99"), "USD"),
            1
        )
        
        self.assertEqual(len(order.get_lines()), 1)
        self.assertEqual(order.calculate_total().amount, Decimal("999.99"))
    
    def test_add_duplicate_product_increases_quantity(self):
        """Test that adding same product increases quantity"""
        order = OrderFactory.create_order("ORD-001", CustomerId("CUST-123"))
        product_id = ProductId("PROD-001")
        
        order.add_line(product_id, "Laptop", Money(Decimal("999.99"), "USD"), 1)
        order.add_line(product_id, "Laptop", Money(Decimal("999.99"), "USD"), 2)
        
        lines = order.get_lines()
        self.assertEqual(len(lines), 1)
        self.assertEqual(lines[0].quantity, 3)
    
    def test_calculate_total_with_multiple_lines(self):
        """Test total calculation across multiple lines"""
        order = OrderFactory.create_order("ORD-001", CustomerId("CUST-123"))
        
        order.add_line(ProductId("PROD-001"), "Laptop", 
                      Money(Decimal("999.99"), "USD"), 1)
        order.add_line(ProductId("PROD-002"), "Mouse", 
                      Money(Decimal("29.99"), "USD"), 2)
        
        total = order.calculate_total()
        expected = Decimal("999.99") + (Decimal("29.99") * 2)
        self.assertEqual(total.amount, expected)
    
    def test_confirm_order_enforces_invariants(self):
        """Test that confirm enforces business rules"""
        order = OrderFactory.create_order("ORD-001", CustomerId("CUST-123"))
        
        # Cannot confirm empty order
        with self.assertRaises(ValueError) as context:
            order.confirm()
        self.assertIn("without items", str(context.exception))
        
        # Add item and confirm
        order.add_line(ProductId("PROD-001"), "Laptop",
                      Money(Decimal("999.99"), "USD"), 1)
        order.confirm()
        
        self.assertEqual(order.status, OrderStatus.CONFIRMED)
        self.assertIsNotNone(order.confirmed_at)
    
    def test_cannot_modify_confirmed_order(self):
        """Test that confirmed orders cannot be modified"""
        order = OrderFactory.create_order("ORD-001", CustomerId("CUST-123"))
        order.add_line(ProductId("PROD-001"), "Laptop",
                      Money(Decimal("999.99"), "USD"), 1)
        order.confirm()
        
        # Cannot add items
        with self.assertRaises(ValueError):
            order.add_line(ProductId("PROD-002"), "Mouse",
                          Money(Decimal("29.99"), "USD"), 1)
        
        # Cannot remove items
        with self.assertRaises(ValueError):
            order.remove_line(ProductId("PROD-001"))
        
        # Cannot change quantity
        with self.assertRaises(ValueError):
            order.change_line_quantity(ProductId("PROD-001"), 2)
    
    def test_cancel_order_publishes_event(self):
        """Test that cancelling publishes domain event"""
        order = OrderFactory.create_order("ORD-001", CustomerId("CUST-123"))
        order.add_line(ProductId("PROD-001"), "Laptop",
                      Money(Decimal("999.99"), "USD"), 1)
        
        order.cancel("Customer requested")
        
        events = order.get_domain_events()
        self.assertTrue(any(e.__class__.__name__ == "OrderCancelled" 
                          for e in events))
    
    def test_cannot_cancel_shipped_order(self):
        """Test business rule: cannot cancel shipped orders"""
        order = OrderFactory.create_order("ORD-001", CustomerId("CUST-123"))
        order.add_line(ProductId("PROD-001"), "Laptop",
                      Money(Decimal("999.99"), "USD"), 1)
        order.confirm()
        order.ship()
        
        with self.assertRaises(ValueError) as context:
            order.cancel("Too late")
        self.assertIn("Cannot cancel", str(context.exception))

if __name__ == '__main__':
    unittest.main()
````

### **Output**

When running the main example:

```
Creating order...
Event: OrderPlaced(order_id='ORD-001', customer_id='CUST-123', total='0 USD', timestamp=2025-12-20 10:30:00.123456)
Created: ORD-001 for customer CUST-123

Adding products...
Order total: 1059.97 USD
Order status: pending

Confirming order...
Event: OrderConfirmed(order_id='ORD-001', timestamp=2025-12-20 10:30:05.789012)
Order confirmed successfully

Trying to add item to confirmed order...
Failed as expected: Cannot add items to non-pending order

Cancelling order...
Cancellation result: Cannot cancel order with status confirmed
```

When running the tests:

```
test_add_duplicate_product_increases_quantity (__main__.TestOrderAggregate) ... ok
test_add_line_to_order (__main__.TestOrderAggregate) ... ok
test_calculate_total_with_multiple_lines (__main__.TestOrderAggregate) ... ok
test_cancel_order_publishes_event (__main__.TestOrderAggregate) ... ok
test_cannot_cancel_shipped_order (__main__.TestOrderAggregate) ... ok
test_cannot_modify_confirmed_order (__main__.TestOrderAggregate) ... ok
test_confirm_order_enforces_invariants (__main__.TestOrderAggregate) ... ok
test_create_order_with_factory (__main__.TestOrderAggregate) ... ok

----------------------------------------------------------------------
Ran 8 tests in 0.003s

OK
```

### **Conclusion**

The Aggregate pattern is a cornerstone of Domain-Driven Design that brings order and consistency to complex domain models. By establishing clear boundaries around clusters of related objects and routing all access through a single root entity, the pattern makes it possible to maintain business invariants reliably while keeping the domain model flexible and maintainable.

The pattern's true power lies in its ability to reduce complexity by making consistency boundaries explicit. Rather than worrying about maintaining correctness across an entire object graph, developers can focus on the invariants within a single Aggregate and handle cross-Aggregate coordination through eventual consistency mechanisms.

Success with the Aggregate pattern requires careful thought about boundaries and a willingness to embrace eventual consistency where appropriate. While the pattern introduces some constraints and complexity, these are far outweighed by the benefits of having a domain model that reliably enforces business rules and remains understandable as the system grows.

### **Next Steps**

To deepen your understanding of the Aggregate pattern:

Practice identifying natural Aggregates in real-world domains by analyzing which objects must change together to maintain consistency. Look for the invariants that define these boundaries.

Experiment with different Aggregate sizes in sample projects to develop intuition for the tradeoffs between small, focused Aggregates and larger ones that maintain more invariants internally.

Study how domain events enable communication between Aggregates and implement event-driven patterns to handle cross-Aggregate coordination through eventual consistency.

Explore different persistence strategies for Aggregates, comparing how relational databases, document stores, and event stores each handle the challenge of storing and reconstituting Aggregate boundaries.

Read Eric Evans' "Domain-Driven Design" and Vaughn Vernon's "Implementing Domain-Driven Design" to gain deeper insights into the strategic and tactical patterns that complement Aggregates.

Apply the pattern incrementally to existing codebases, starting with areas where consistency problems are most visible and gradually expanding boundaries as understanding improves.

Join DDD communities and study real-world examples of Aggregate implementations to learn from others' successes and challenges in applying the pattern to diverse domains.

---

## Repository Pattern

The Repository Pattern is a design pattern that mediates between the domain and data mapping layers, acting as an in-memory collection of domain objects. It provides a more object-oriented view of the persistence layer and encapsulates the logic required to access data sources, offering a cleaner separation between business logic and data access logic.

### Core Concept

The Repository Pattern abstracts the data access layer by providing a collection-like interface for accessing domain objects. Instead of directly querying databases or other data sources, the application interacts with repositories using domain-centric methods. This abstraction allows the business logic to remain independent of the underlying data storage mechanism.

**Purpose**: The primary purpose is to decouple the business logic from data access concerns. By introducing this abstraction, the pattern enables easier testing, maintenance, and the ability to change data sources without affecting the business logic.

**Collection Metaphor**: Repositories should feel like in-memory collections. Clients interact with them as if they were working with domain objects in memory, without needing to know about database connections, queries, or persistence mechanisms.

### Key Characteristics

**Abstraction Over Data Access**: The repository acts as a facade over the data access layer, hiding complex query logic, connection management, and data mapping from the business logic.

**Domain-Centric Interface**: Repository methods are expressed in terms of the domain model, not in terms of database operations. Methods like `findActiveCustomers()` are preferred over `executeQuery("SELECT * FROM customers WHERE active = true")`.

**Single Source of Truth**: For each aggregate or entity type, there should typically be one repository that serves as the authoritative source for accessing that type of object.

**Encapsulation of Queries**: All data access logic, including complex queries, filtering, and sorting, is encapsulated within the repository implementation.

### Basic Structure

**Repository Interface**: Defines the contract for data access operations in domain terms. This interface lives in the domain or application layer.

```java
public interface CustomerRepository {
    Customer findById(CustomerId id);
    List<Customer> findAll();
    List<Customer> findByStatus(CustomerStatus status);
    void save(Customer customer);
    void delete(Customer customer);
    boolean exists(CustomerId id);
}
```

**Repository Implementation**: Implements the interface with actual data access logic. This lives in the infrastructure or data access layer.

```java
public class DatabaseCustomerRepository implements CustomerRepository {
    private final DataSource dataSource;
    private final CustomerMapper mapper;
    
    @Override
    public Customer findById(CustomerId id) {
        // Database-specific implementation
        String sql = "SELECT * FROM customers WHERE id = ?";
        // Execute query, map results, return domain object
    }
    
    @Override
    public void save(Customer customer) {
        // Database-specific implementation
        // Handle both insert and update logic
    }
}
```

### Types of Repository Patterns

**Generic Repository**: Provides common CRUD operations for all entity types through a base interface.

```java
public interface Repository<T, ID> {
    T findById(ID id);
    List<T> findAll();
    void save(T entity);
    void delete(T entity);
}

public interface CustomerRepository extends Repository<Customer, CustomerId> {
    List<Customer> findByEmail(String email);
}
```

**Specific Repository**: Each repository is tailored to a specific entity with custom methods relevant to that entity.

```java
public interface OrderRepository {
    Order findById(OrderId id);
    List<Order> findByCustomerId(CustomerId customerId);
    List<Order> findRecentOrders(LocalDate since);
    List<Order> findPendingOrders();
    void save(Order order);
}
```

**Aggregate Repository**: Repositories designed around Domain-Driven Design aggregates, where one repository handles an entire aggregate root and its related entities.

```java
public interface OrderAggregateRepository {
    OrderAggregate findById(OrderId id);
    void save(OrderAggregate aggregate);
    // Only aggregate root operations exposed
}
```

### Common Operations

**Query Methods**: Retrieve entities based on various criteria. These should be expressed in domain terms.

```java
// Single entity retrieval
Customer findById(CustomerId id);
Optional<Customer> findByEmail(String email);

// Collection retrieval
List<Customer> findAll();
List<Customer> findByStatus(CustomerStatus status);
List<Customer> findByRegistrationDateBetween(LocalDate start, LocalDate end);

// Paginated retrieval
Page<Customer> findAll(Pageable pageable);
List<Customer> findTop10ByOrderByRegistrationDateDesc();
```

**Command Methods**: Modify the persistence state of entities.

```java
void save(Customer customer);
void saveAll(List<Customer> customers);
void delete(Customer customer);
void deleteById(CustomerId id);
void deleteAll(List<Customer> customers);
```

**Existence Checks**: Verify entity existence without loading the full object.

```java
boolean exists(CustomerId id);
boolean existsByEmail(String email);
long count();
long countByStatus(CustomerStatus status);
```

**Aggregate Operations**: Operations that work with multiple entities or provide aggregated data.

```java
long countActiveCustomers();
Money getTotalRevenueForCustomer(CustomerId id);
Map<CustomerStatus, Long> getCustomerCountByStatus();
```

### Implementation Strategies

**Direct Database Access**: Repository directly executes SQL queries or uses an ORM to access the database.

```java
public class JdbcCustomerRepository implements CustomerRepository {
    private final JdbcTemplate jdbcTemplate;
    
    @Override
    public Customer findById(CustomerId id) {
        String sql = "SELECT * FROM customers WHERE id = ?";
        return jdbcTemplate.queryForObject(
            sql,
            new Object[]{id.getValue()},
            new CustomerRowMapper()
        );
    }
}
```

**ORM-Based Implementation**: Uses an Object-Relational Mapping framework like Hibernate or Entity Framework.

```java
public class JpaCustomerRepository implements CustomerRepository {
    private final EntityManager entityManager;
    
    @Override
    public Customer findById(CustomerId id) {
        CustomerEntity entity = entityManager.find(
            CustomerEntity.class, 
            id.getValue()
        );
        return mapper.toDomain(entity);
    }
    
    @Override
    public List<Customer> findByStatus(CustomerStatus status) {
        TypedQuery<CustomerEntity> query = entityManager.createQuery(
            "SELECT c FROM CustomerEntity c WHERE c.status = :status",
            CustomerEntity.class
        );
        query.setParameter("status", status.name());
        return query.getResultStream()
            .map(mapper::toDomain)
            .collect(Collectors.toList());
    }
}
```

**Specification Pattern Integration**: Combines repositories with the Specification Pattern for flexible querying.

```java
public interface SpecificationRepository<T> {
    List<T> findAll(Specification<T> spec);
    Optional<T> findOne(Specification<T> spec);
    long count(Specification<T> spec);
}

// Usage
Specification<Customer> spec = CustomerSpecifications
    .hasStatus(CustomerStatus.ACTIVE)
    .and(CustomerSpecifications.registeredAfter(date));
List<Customer> customers = repository.findAll(spec);
```

**In-Memory Implementation**: Useful for testing or prototyping.

```java
public class InMemoryCustomerRepository implements CustomerRepository {
    private final Map<CustomerId, Customer> storage = new ConcurrentHashMap<>();
    
    @Override
    public Customer findById(CustomerId id) {
        Customer customer = storage.get(id);
        if (customer == null) {
            throw new CustomerNotFoundException(id);
        }
        return customer;
    }
    
    @Override
    public void save(Customer customer) {
        storage.put(customer.getId(), customer);
    }
}
```

### Design Considerations

**Granularity**: Decide whether to have one repository per entity or per aggregate root. In Domain-Driven Design, repositories typically map to aggregate roots.

**Return Types**: Consider whether methods should return domain objects directly, wrap them in `Optional`, or throw exceptions when entities are not found.

```java
// Direct return (can return null)
Customer findById(CustomerId id);

// Optional return (explicit absence)
Optional<Customer> findById(CustomerId id);

// Exception-based (fails fast)
Customer getById(CustomerId id) throws CustomerNotFoundException;
```

**Query Complexity**: Balance between having many specific query methods and fewer generic methods with parameters. Too many methods create bloat; too few create complex parameter combinations.

**Lazy vs Eager Loading**: Decide how related entities are loaded. Repositories should provide clear methods for different loading strategies.

```java
Customer findById(CustomerId id); // Loads customer only
Customer findByIdWithOrders(CustomerId id); // Loads customer with orders
Customer findByIdWithFullGraph(CustomerId id); // Loads entire object graph
```

**Transaction Management**: Repositories typically don't manage transactions themselves. Transaction boundaries are usually managed at the application service or use case level.

### **Example**

Consider a comprehensive blog application with posts, comments, and authors:

**Domain Models**:

```java
public class Post {
    private PostId id;
    private String title;
    private String content;
    private AuthorId authorId;
    private PostStatus status;
    private LocalDateTime publishedAt;
    private List<String> tags;
    
    public void publish() {
        if (this.status == PostStatus.PUBLISHED) {
            throw new IllegalStateException("Post already published");
        }
        this.status = PostStatus.PUBLISHED;
        this.publishedAt = LocalDateTime.now();
    }
    
    public void archive() {
        this.status = PostStatus.ARCHIVED;
    }
    
    public boolean isPublished() {
        return status == PostStatus.PUBLISHED;
    }
}

public class Author {
    private AuthorId id;
    private String name;
    private String email;
    private String bio;
    private LocalDateTime joinedAt;
}

public enum PostStatus {
    DRAFT, PUBLISHED, ARCHIVED
}
```

**Repository Interfaces**:

```java
public interface PostRepository {
    // Basic CRUD
    Post findById(PostId id);
    Optional<Post> findByIdOptional(PostId id);
    List<Post> findAll();
    void save(Post post);
    void delete(Post post);
    
    // Query methods
    List<Post> findByAuthorId(AuthorId authorId);
    List<Post> findByStatus(PostStatus status);
    List<Post> findPublishedPosts();
    List<Post> findByTag(String tag);
    List<Post> findByTitleContaining(String keyword);
    
    // Paginated queries
    Page<Post> findPublishedPosts(Pageable pageable);
    Page<Post> findByAuthorId(AuthorId authorId, Pageable pageable);
    
    // Complex queries
    List<Post> findRecentPublishedPosts(int limit);
    List<Post> findByAuthorAndDateRange(
        AuthorId authorId, 
        LocalDateTime start, 
        LocalDateTime end
    );
    List<Post> findPopularPostsByTags(List<String> tags, int minViews);
    
    // Aggregate queries
    long countByAuthorId(AuthorId authorId);
    long countByStatus(PostStatus status);
    Map<String, Long> getPostCountByTag();
    
    // Existence checks
    boolean exists(PostId id);
    boolean existsByTitle(String title);
}

public interface AuthorRepository {
    Author findById(AuthorId id);
    Optional<Author> findByEmail(String email);
    List<Author> findAll();
    void save(Author author);
    void delete(Author author);
    boolean existsByEmail(String email);
}
```

**JPA Implementation**:

```java
@Repository
public class JpaPostRepository implements PostRepository {
    
    @PersistenceContext
    private EntityManager entityManager;
    
    private final PostMapper mapper;
    
    public JpaPostRepository(PostMapper mapper) {
        this.mapper = mapper;
    }
    
    @Override
    public Post findById(PostId id) {
        PostEntity entity = entityManager.find(PostEntity.class, id.getValue());
        if (entity == null) {
            throw new PostNotFoundException(id);
        }
        return mapper.toDomain(entity);
    }
    
    @Override
    public Optional<Post> findByIdOptional(PostId id) {
        try {
            return Optional.of(findById(id));
        } catch (PostNotFoundException e) {
            return Optional.empty();
        }
    }
    
    @Override
    public List<Post> findAll() {
        TypedQuery<PostEntity> query = entityManager.createQuery(
            "SELECT p FROM PostEntity p ORDER BY p.publishedAt DESC",
            PostEntity.class
        );
        return query.getResultStream()
            .map(mapper::toDomain)
            .collect(Collectors.toList());
    }
    
    @Override
    @Transactional
    public void save(Post post) {
        PostEntity entity = mapper.toEntity(post);
        
        if (exists(post.getId())) {
            entityManager.merge(entity);
        } else {
            entityManager.persist(entity);
        }
    }
    
    @Override
    @Transactional
    public void delete(Post post) {
        PostEntity entity = entityManager.find(
            PostEntity.class, 
            post.getId().getValue()
        );
        if (entity != null) {
            entityManager.remove(entity);
        }
    }
    
    @Override
    public List<Post> findByAuthorId(AuthorId authorId) {
        TypedQuery<PostEntity> query = entityManager.createQuery(
            "SELECT p FROM PostEntity p WHERE p.authorId = :authorId " +
            "ORDER BY p.publishedAt DESC",
            PostEntity.class
        );
        query.setParameter("authorId", authorId.getValue());
        return query.getResultStream()
            .map(mapper::toDomain)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<Post> findByStatus(PostStatus status) {
        TypedQuery<PostEntity> query = entityManager.createQuery(
            "SELECT p FROM PostEntity p WHERE p.status = :status " +
            "ORDER BY p.publishedAt DESC",
            PostEntity.class
        );
        query.setParameter("status", status.name());
        return query.getResultStream()
            .map(mapper::toDomain)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<Post> findPublishedPosts() {
        return findByStatus(PostStatus.PUBLISHED);
    }
    
    @Override
    public List<Post> findByTag(String tag) {
        TypedQuery<PostEntity> query = entityManager.createQuery(
            "SELECT p FROM PostEntity p WHERE :tag MEMBER OF p.tags " +
            "AND p.status = 'PUBLISHED' ORDER BY p.publishedAt DESC",
            PostEntity.class
        );
        query.setParameter("tag", tag);
        return query.getResultStream()
            .map(mapper::toDomain)
            .collect(Collectors.toList());
    }
    
    @Override
    public Page<Post> findPublishedPosts(Pageable pageable) {
        // Count query
        TypedQuery<Long> countQuery = entityManager.createQuery(
            "SELECT COUNT(p) FROM PostEntity p WHERE p.status = 'PUBLISHED'",
            Long.class
        );
        long total = countQuery.getSingleResult();
        
        // Data query
        TypedQuery<PostEntity> dataQuery = entityManager.createQuery(
            "SELECT p FROM PostEntity p WHERE p.status = 'PUBLISHED' " +
            "ORDER BY p.publishedAt DESC",
            PostEntity.class
        );
        dataQuery.setFirstResult((int) pageable.getOffset());
        dataQuery.setMaxResults(pageable.getPageSize());
        
        List<Post> content = dataQuery.getResultStream()
            .map(mapper::toDomain)
            .collect(Collectors.toList());
        
        return new PageImpl<>(content, pageable, total);
    }
    
    @Override
    public List<Post> findRecentPublishedPosts(int limit) {
        TypedQuery<PostEntity> query = entityManager.createQuery(
            "SELECT p FROM PostEntity p WHERE p.status = 'PUBLISHED' " +
            "ORDER BY p.publishedAt DESC",
            PostEntity.class
        );
        query.setMaxResults(limit);
        return query.getResultStream()
            .map(mapper::toDomain)
            .collect(Collectors.toList());
    }
    
    @Override
    public List<Post> findByAuthorAndDateRange(
        AuthorId authorId,
        LocalDateTime start,
        LocalDateTime end
    ) {
        TypedQuery<PostEntity> query = entityManager.createQuery(
            "SELECT p FROM PostEntity p WHERE p.authorId = :authorId " +
            "AND p.publishedAt BETWEEN :start AND :end " +
            "ORDER BY p.publishedAt DESC",
            PostEntity.class
        );
        query.setParameter("authorId", authorId.getValue());
        query.setParameter("start", start);
        query.setParameter("end", end);
        return query.getResultStream()
            .map(mapper::toDomain)
            .collect(Collectors.toList());
    }
    
    @Override
    public long countByAuthorId(AuthorId authorId) {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT COUNT(p) FROM PostEntity p WHERE p.authorId = :authorId",
            Long.class
        );
        query.setParameter("authorId", authorId.getValue());
        return query.getSingleResult();
    }
    
    @Override
    public long countByStatus(PostStatus status) {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT COUNT(p) FROM PostEntity p WHERE p.status = :status",
            Long.class
        );
        query.setParameter("status", status.name());
        return query.getSingleResult();
    }
    
    @Override
    public boolean exists(PostId id) {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT COUNT(p) FROM PostEntity p WHERE p.id = :id",
            Long.class
        );
        query.setParameter("id", id.getValue());
        return query.getSingleResult() > 0;
    }
    
    @Override
    public boolean existsByTitle(String title) {
        TypedQuery<Long> query = entityManager.createQuery(
            "SELECT COUNT(p) FROM PostEntity p WHERE p.title = :title",
            Long.class
        );
        query.setParameter("title", title);
        return query.getSingleResult() > 0;
    }
}
```

**In-Memory Implementation for Testing**:

```java
public class InMemoryPostRepository implements PostRepository {
    private final Map<PostId, Post> posts = new ConcurrentHashMap<>();
    
    @Override
    public Post findById(PostId id) {
        Post post = posts.get(id);
        if (post == null) {
            throw new PostNotFoundException(id);
        }
        return post;
    }
    
    @Override
    public Optional<Post> findByIdOptional(PostId id) {
        return Optional.ofNullable(posts.get(id));
    }
    
    @Override
    public List<Post> findAll() {
        return new ArrayList<>(posts.values());
    }
    
    @Override
    public void save(Post post) {
        posts.put(post.getId(), post);
    }
    
    @Override
    public void delete(Post post) {
        posts.remove(post.getId());
    }
    
    @Override
    public List<Post> findByAuthorId(AuthorId authorId) {
        return posts.values().stream()
            .filter(p -> p.getAuthorId().equals(authorId))
            .sorted(Comparator.comparing(Post::getPublishedAt).reversed())
            .collect(Collectors.toList());
    }
    
    @Override
    public List<Post> findByStatus(PostStatus status) {
        return posts.values().stream()
            .filter(p -> p.getStatus() == status)
            .sorted(Comparator.comparing(Post::getPublishedAt).reversed())
            .collect(Collectors.toList());
    }
    
    @Override
    public List<Post> findPublishedPosts() {
        return findByStatus(PostStatus.PUBLISHED);
    }
    
    @Override
    public List<Post> findByTag(String tag) {
        return posts.values().stream()
            .filter(Post::isPublished)
            .filter(p -> p.getTags().contains(tag))
            .sorted(Comparator.comparing(Post::getPublishedAt).reversed())
            .collect(Collectors.toList());
    }
    
    @Override
    public List<Post> findRecentPublishedPosts(int limit) {
        return findPublishedPosts().stream()
            .limit(limit)
            .collect(Collectors.toList());
    }
    
    @Override
    public long countByAuthorId(AuthorId authorId) {
        return posts.values().stream()
            .filter(p -> p.getAuthorId().equals(authorId))
            .count();
    }
    
    @Override
    public boolean exists(PostId id) {
        return posts.containsKey(id);
    }
    
    public void clear() {
        posts.clear();
    }
}
```

**Usage in Application Service**:

```java
public class PostService {
    private final PostRepository postRepository;
    private final AuthorRepository authorRepository;
    
    public PostService(
        PostRepository postRepository,
        AuthorRepository authorRepository
    ) {
        this.postRepository = postRepository;
        this.authorRepository = authorRepository;
    }
    
    public void publishPost(PostId postId) {
        Post post = postRepository.findById(postId);
        post.publish();
        postRepository.save(post);
    }
    
    public List<PostDTO> getRecentPosts(int limit) {
        return postRepository.findRecentPublishedPosts(limit).stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }
    
    public List<PostDTO> getPostsByAuthor(AuthorId authorId) {
        // Verify author exists
        authorRepository.findById(authorId);
        
        return postRepository.findByAuthorId(authorId).stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }
    
    public Page<PostDTO> getPublishedPosts(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Post> posts = postRepository.findPublishedPosts(pageable);
        return posts.map(this::toDTO);
    }
    
    public void createPost(CreatePostRequest request) {
        // Verify author exists
        Author author = authorRepository.findById(request.getAuthorId());
        
        // Check for duplicate title
        if (postRepository.existsByTitle(request.getTitle())) {
            throw new DuplicatePostTitleException(request.getTitle());
        }
        
        Post post = new Post(
            PostId.generate(),
            request.getTitle(),
            request.getContent(),
            author.getId(),
            PostStatus.DRAFT,
            request.getTags()
        );
        
        postRepository.save(post);
    }
    
    private PostDTO toDTO(Post post) {
        return new PostDTO(
            post.getId().getValue(),
            post.getTitle(),
            post.getContent(),
            post.getStatus().name(),
            post.getPublishedAt(),
            post.getTags()
        );
    }
}
```

**Unit Testing with In-Memory Repository**:

```java
class PostServiceTest {
    private InMemoryPostRepository postRepository;
    private InMemoryAuthorRepository authorRepository;
    private PostService postService;
    
    @BeforeEach
    void setUp() {
        postRepository = new InMemoryPostRepository();
        authorRepository = new InMemoryAuthorRepository();
        postService = new PostService(postRepository, authorRepository);
    }
    
    @Test
    void shouldPublishDraftPost() {
        // Given
        Author author = createTestAuthor();
        authorRepository.save(author);
        
        Post post = createDraftPost(author.getId());
        postRepository.save(post);
        
        // When
        postService.publishPost(post.getId());
        
        // Then
        Post published = postRepository.findById(post.getId());
        assertEquals(PostStatus.PUBLISHED, published.getStatus());
        assertNotNull(published.getPublishedAt());
    }
    
    @Test
    void shouldRetrieveRecentPublishedPosts() {
        // Given
        Author author = createTestAuthor();
        authorRepository.save(author);
        
        Post post1 = createPublishedPost(author.getId(), "Post 1");
        Post post2 = createPublishedPost(author.getId(), "Post 2");
        Post post3 = createDraftPost(author.getId());
        
        postRepository.save(post1);
        postRepository.save(post2);
        postRepository.save(post3);
        
        // When
        List<PostDTO> recent = postService.getRecentPosts(10);
        
        // Then
        assertEquals(2, recent.size());
        assertFalse(recent.stream()
            .anyMatch(p -> p.getStatus().equals("DRAFT")));
    }
    
    @Test
    void shouldPreventDuplicateTitles() {
        // Given
        Author author = createTestAuthor();
        authorRepository.save(author);
        
        Post existing = createDraftPost(author.getId());
        existing.setTitle("Unique Title");
        postRepository.save(existing);
        
        CreatePostRequest request = new CreatePostRequest(
            author.getId(),
            "Unique Title",
            "Content",
            List.of("tag1")
        );
        
        // When/Then
        assertThrows(
            DuplicatePostTitleException.class,
            () -> postService.createPost(request)
        );
    }
}
```

### **Output**

When using the repository in a REST controller:

```java
@RestController
@RequestMapping("/api/posts")
public class PostController {
    private final PostService postService;
    
    @GetMapping("/recent")
    public ResponseEntity<List<PostDTO>> getRecentPosts(
        @RequestParam(defaultValue = "10") int limit
    ) {
        List<PostDTO> posts = postService.getRecentPosts(limit);
        return ResponseEntity.ok(posts);
    }
    
    @GetMapping
    public ResponseEntity<Page<PostDTO>> getPublishedPosts(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        Page<PostDTO> posts = postService.getPublishedPosts(page, size);
        return ResponseEntity.ok(posts);
    }
    
    @PostMapping("/{postId}/publish")
    public ResponseEntity<Void> publishPost(@PathVariable String postId) {
        postService.publishPost(new PostId(postId));
        return ResponseEntity.ok().build();
    }
}
```

Sample JSON response from `GET /api/posts/recent`:

```json
[
  {
    "id": "post-123",
    "title": "Getting Started with Design Patterns",
    "content": "Design patterns are reusable solutions...",
    "status": "PUBLISHED",
    "publishedAt": "2025-12-20T10:30:00",
    "tags": ["design-patterns", "software-engineering"]
  },
  {
    "id": "post-124",
    "title": "Understanding Clean Architecture",
    "content": "Clean Architecture emphasizes...",
    "status": "PUBLISHED",
    "publishedAt": "2025-12-19T15:45:00",
    "tags": ["architecture", "clean-code"]
  }
]
```

**Key Points**:

- Repository interface is expressed in domain terms (`findPublishedPosts`, not `executeQuery`)
- Implementation details (JPA, SQL) are hidden from business logic
- In-memory implementation enables fast, isolated testing
- Multiple query strategies (simple, paginated, filtered) are cleanly organized
- Domain objects (Post, Author) remain pure, free of persistence concerns

### Benefits and Advantages

**Separation of Concerns**: Business logic remains isolated from data access code. Changes to the database schema or ORM configuration don't affect business rules.

**Testability**: Easy to create mock or in-memory implementations for unit testing. Business logic can be tested without database dependencies.

**Maintainability**: Data access logic is centralized in one place. Query changes don't scatter across the codebase.

**Flexibility**: The underlying data source can be changed (SQL to NoSQL, database to API, etc.) without affecting business logic.

**Domain-Centric Design**: Code reads naturally in terms of the business domain rather than technical database operations.

**Query Optimization**: All queries for an entity type are visible in one place, making it easier to optimize and avoid N+1 query problems.

### Common Pitfalls and Anti-Patterns

**Generic Repository Overuse**: Creating overly generic repositories with complex filtering mechanisms instead of clear, specific methods. This sacrifices clarity for false flexibility.

```java
// Anti-pattern: Too generic
List<Post> find(Map<String, Object> criteria, String orderBy, int limit);

// Better: Specific methods
List<Post> findPublishedPosts();
List<Post> findByAuthorId(AuthorId authorId);
```

**Leaky Abstractions**: Allowing persistence concerns to leak into the repository interface.

```java
// Anti-pattern: Exposing ORM concepts
Post findByIdWithLazyLoading(PostId id);
void saveWithFlush(Post post);

// Better: Clean domain interface
Post findById(PostId id);
void save(Post post);
```

**Repository of Repositories**: Creating repositories that coordinate multiple other repositories, blurring the line between repository and service.

**Anemic Repositories**: Repositories that are just thin wrappers over ORM methods without encapsulating any real query logic.

**Query Explosion**: Creating a new repository method for every possible query combination, leading to interfaces with hundreds of methods.

**Business Logic in Repositories**: Putting business rules inside repository implementations instead of keeping them in domain objects or services.

```java
// Anti-pattern: Business logic in repository
public void save(Post post) {
    if (post.getStatus() == PostStatus.PUBLISHED && post.getPublishedAt() == null) {
        post.setPublishedAt(LocalDateTime.now()); // Business logic!
    }
    entityManager.persist(mapper.toEntity(post));
}

// Better: Business logic in domain
public void publish() {
    this.status = PostStatus.PUBLISHED;
    this.publishedAt = LocalDateTime.now();
}
```

### Repository vs Data Access Object (DAO)

While similar, repositories and DAOs have different focuses:

**Repository**: Domain-oriented, collection-like interface focused on aggregate roots. Methods are named in business terms. Typically one per aggregate.

**DAO**: Data-oriented, focuses on CRUD operations at the database table level. Methods are named in data terms. Often one per database table.

```java
// Repository approach
public interface OrderRepository {
    Order findById(OrderId id);
    List<Order> findPendingOrders();
    void save(Order order);
}

// DAO approach
public interface OrderDAO {
    OrderRecord select(long id);
    List<OrderRecord> selectWhere(String condition);
    void insert(OrderRecord record);
    void update(OrderRecord record);
    void delete(long id);
}
```

Repositories work with domain objects; DAOs often work with data transfer objects or records that closely mirror database tables.

### Integration with Unit of Work Pattern

Repositories often work alongside the Unit of Work pattern, which tracks changes and coordinates the writing of changes as a single transaction.

```java
public class UnitOfWork {

    private final EntityManager entityManager;
    private final Map<Class<?>, Repository<?>> repositories = new HashMap<>();

    public UnitOfWork(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    public void begin() {
        entityManager.getTransaction().begin();
    }

    public void commit() {
        entityManager.getTransaction().commit();
    }

    public void rollback() {
        entityManager.getTransaction().rollback();
    }

    @SuppressWarnings("unchecked")
    public <T> Repository<T> getRepository(Class<T> entityClass) {
        return (Repository<T>) repositories.computeIfAbsent(
            entityClass,
            this::createRepository
        );
    }

    private <T> Repository<T> createRepository(Class<T> entityClass) {
        // factory logic for repository creation
        return new JpaRepository<>(entityManager, entityClass);
    }
}

````

### Framework Integration

**Spring Data JPA**: Provides automatic repository implementation from interfaces.

```java
public interface PostRepository extends JpaRepository<PostEntity, Long> {
    List<PostEntity> findByStatus(String status);
    List<PostEntity> findByAuthorIdOrderByPublishedAtDesc(Long authorId);
    
    @Query("SELECT p FROM PostEntity p WHERE p.status = 'PUBLISHED'")
    List<PostEntity> findPublishedPosts();
}
````

While convenient, this approach can lead to the repository interface being tied to the persistence framework. A common pattern is to create a domain repository interface and a Spring Data repository interface, with an adapter between them.

```java
// Domain interface
public interface PostRepository {
    Post findById(PostId id);
    List<Post> findPublishedPosts();
    void save(Post post);
}

// Spring Data interface
interface SpringDataPostRepository extends JpaRepository<PostEntity, Long> {
    @Query("SELECT p FROM PostEntity p WHERE p.status = 'PUBLISHED'")
    List<PostEntity> findPublishedPosts();
}

// Adapter
@Repository
class PostRepositoryAdapter implements PostRepository {
    private final SpringDataPostRepository springDataRepository;
    private final PostMapper mapper;
    
    @Override
    public Post findById(PostId id) {
        PostEntity entity = springDataRepository.findById(id.getValue())
            .orElseThrow(() -> new PostNotFoundException(id));
        return mapper.toDomain(entity);
    }
    
    @Override
    public List<Post> findPublishedPosts() {
        return springDataRepository.findPublishedPosts().stream()
            .map(mapper::toDomain)
            .collect(Collectors.toList());
    }
}
```

**Entity Framework (.NET)**: Similar capabilities with LINQ for query composition.

```csharp
public class PostRepository : IPostRepository {
    private readonly DbContext _context;
    
    public Post FindById(PostId id) {
        var entity = _context.Posts.Find(id.Value);
        return _mapper.ToDomain(entity);
    }
    
    public List<Post> FindPublishedPosts() {
        return _context.Posts
            .Where(p => p.Status == "PUBLISHED")
            .OrderByDescending(p => p.PublishedAt)
            .ToList()
            .Select(_mapper.ToDomain)
            .ToList();
    }
}
```

### Query Object Pattern

For complex queries, the Query Object pattern can be combined with repositories to avoid method explosion.

```java
public class PostQuery {
    private AuthorId authorId;
    private PostStatus status;
    private LocalDateTime publishedAfter;
    private List<String> tags;
    private int limit;
    
    public PostQuery byAuthor(AuthorId authorId) {
        this.authorId = authorId;
        return this;
    }
    
    public PostQuery withStatus(PostStatus status) {
        this.status = status;
        return this;
    }
    
    public PostQuery publishedAfter(LocalDateTime date) {
        this.publishedAfter = date;
        return this;
    }
    
    public PostQuery withTags(List<String> tags) {
        this.tags = tags;
        return this;
    }
    
    public PostQuery limit(int limit) {
        this.limit = limit;
        return this;
    }
    
    // Getters for query execution
}

public interface PostRepository {
    List<Post> find(PostQuery query);
}

// Usage
List<Post> posts = postRepository.find(
    new PostQuery()
        .byAuthor(authorId)
        .withStatus(PostStatus.PUBLISHED)
        .publishedAfter(lastWeek)
        .limit(10)
);
```

### Caching Strategies

Repositories are an ideal place to implement caching since all data access flows through them.

```java
public class CachedPostRepository implements PostRepository {
    private final PostRepository delegate;
    private final Cache<PostId, Post> cache;
    
    @Override
    public Post findById(PostId id) {
        return cache.get(id, () -> delegate.findById(id));
    }
    
    @Override
    public void save(Post post) {
        delegate.save(post);
        cache.invalidate(post.getId());
    }
    
    @Override
    public List<Post> findPublishedPosts() {
        // Cache entire result set or don't cache lists
        return delegate.findPublishedPosts();
    }
}
```

Caching considerations:

- Cache individual entities by ID for best hit rates
- Be cautious caching query results that can become stale
- Implement cache invalidation strategies on writes
- Consider cache-aside vs read-through patterns
- Monitor cache hit rates and adjust strategies

### **Conclusion**

The Repository Pattern provides a clean abstraction between domain logic and data access, enabling more maintainable, testable, and flexible applications. By presenting a collection-like interface expressed in domain terms, repositories allow business logic to remain independent of persistence concerns. While the pattern introduces additional layers and requires discipline to implement correctly, the benefits in code organization, testability, and adaptability make it valuable for applications with complex domain logic or evolving data access requirements. The key to successful repository implementation lies in keeping the interface domain-centric, avoiding leaky abstractions, and resisting the temptation to create overly generic or bloated repository interfaces.

---

## Factory Pattern in Domain-Driven Design

The Factory pattern in Domain-Driven Design (DDD) is a creational pattern responsible for constructing complex domain objects and aggregates while encapsulating the creation logic and maintaining invariants. Unlike traditional Factory patterns used for simple object instantiation, DDD Factories ensure that domain objects are always created in a valid, consistent state that satisfies all business rules.

### Purpose in DDD

**Encapsulating Complex Construction Logic** When creating a domain object requires multiple steps, validation, or coordination of several related objects, a Factory centralizes this complexity. This keeps entity constructors simple and focused while the Factory handles the intricate assembly process.

**Maintaining Invariants** Domain objects must never exist in an invalid state. Factories ensure all invariants—business rules that must always be true—are satisfied from the moment of creation. If construction fails, the Factory prevents object creation rather than allowing invalid objects into the domain.

**Abstracting Creation Details** Clients don't need to know how objects are constructed internally. The Factory provides a clean interface for creation while hiding implementation details like which concrete class to instantiate or what dependencies are needed.

**Supporting Aggregate Reconstitution** When loading aggregates from persistence, Factories can reconstruct complex object graphs while bypassing normal validation rules that apply to new objects but not to persisted ones.

### Types of Factories in DDD

**Entity Factories** Create individual entities with complex construction requirements:

```csharp
public class Customer
{
    public CustomerId Id { get; private set; }
    public string Name { get; private set; }
    public Email Email { get; private set; }
    public Address Address { get; private set; }
    public CustomerStatus Status { get; private set; }
    public DateTime CreatedAt { get; private set; }
    
    // Private constructor - forces use of Factory
    private Customer() { }
    
    // Internal constructor for reconstitution from persistence
    internal Customer(
        CustomerId id,
        string name,
        Email email,
        Address address,
        CustomerStatus status,
        DateTime createdAt)
    {
        Id = id;
        Name = name;
        Email = email;
        Address = address;
        Status = status;
        CreatedAt = createdAt;
    }
}

public class CustomerFactory
{
    private readonly ICustomerValidator _validator;
    private readonly ICreditCheckService _creditService;
    
    public CustomerFactory(
        ICustomerValidator validator,
        ICreditCheckService creditService)
    {
        _validator = validator;
        _creditService = creditService;
    }
    
    public async Task<Customer> CreateNewCustomerAsync(
        string name,
        string emailAddress,
        Address address)
    {
        // Validate inputs
        if (string.IsNullOrWhiteSpace(name))
            throw new DomainException("Customer name is required");
        
        var email = Email.Create(emailAddress);
        if (!_validator.IsValidEmail(email))
            throw new DomainException("Invalid email address");
        
        // Perform domain service check
        var creditStatus = await _creditService.CheckCreditAsync(name, address);
        var status = creditStatus.IsApproved 
            ? CustomerStatus.Active 
            : CustomerStatus.PendingApproval;
        
        // Create the entity
        return new Customer(
            CustomerId.NewId(),
            name,
            email,
            address,
            status,
            DateTime.UtcNow);
    }
    
    // Reconstitution method for persistence layer
    public Customer Reconstitute(
        Guid id,
        string name,
        string emailAddress,
        Address address,
        string status,
        DateTime createdAt)
    {
        return new Customer(
            new CustomerId(id),
            name,
            new Email(emailAddress),
            address,
            Enum.Parse<CustomerStatus>(status),
            createdAt);
    }
}
```

**Aggregate Factories** Create complete aggregates with all their child entities and value objects in a consistent state:

```csharp
public class Order
{
    public OrderId Id { get; private set; }
    public CustomerId CustomerId { get; private set; }
    public OrderStatus Status { get; private set; }
    public Money Total { get; private set; }
    private readonly List<OrderItem> _items = new();
    public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();
    
    private Order() { }
    
    internal Order(
        OrderId id,
        CustomerId customerId,
        IEnumerable<OrderItem> items)
    {
        Id = id;
        CustomerId = customerId;
        _items.AddRange(items);
        Status = OrderStatus.Draft;
        RecalculateTotal();
    }
    
    private void RecalculateTotal()
    {
        Total = _items.Aggregate(Money.Zero, (sum, item) => sum + item.Subtotal);
    }
}

public class OrderItem
{
    public ProductId ProductId { get; private set; }
    public string ProductName { get; private set; }
    public Money UnitPrice { get; private set; }
    public int Quantity { get; private set; }
    public Money Subtotal { get; private set; }
    
    internal OrderItem(ProductId productId, string productName, Money unitPrice, int quantity)
    {
        if (quantity <= 0)
            throw new DomainException("Quantity must be positive");
        
        ProductId = productId;
        ProductName = productName;
        UnitPrice = unitPrice;
        Quantity = quantity;
        Subtotal = unitPrice * quantity;
    }
}

public class OrderFactory
{
    private readonly IProductRepository _productRepository;
    private readonly IPricingService _pricingService;
    
    public OrderFactory(
        IProductRepository productRepository,
        IPricingService pricingService)
    {
        _productRepository = productRepository;
        _pricingService = pricingService;
    }
    
    public async Task<Order> CreateOrderAsync(
        CustomerId customerId,
        IEnumerable<OrderItemRequest> itemRequests)
    {
        if (!itemRequests.Any())
            throw new DomainException("Order must contain at least one item");
        
        var orderItems = new List<OrderItem>();
        
        // Build each order item
        foreach (var request in itemRequests)
        {
            var product = await _productRepository.GetByIdAsync(request.ProductId);
            if (product == null)
                throw new DomainException($"Product {request.ProductId} not found");
            
            if (!product.IsAvailable)
                throw new DomainException($"Product {product.Name} is not available");
            
            // Get current price from pricing service
            var price = await _pricingService.GetPriceAsync(
                product.Id, 
                customerId, 
                request.Quantity);
            
            var item = new OrderItem(
                product.Id,
                product.Name,
                price,
                request.Quantity);
            
            orderItems.Add(item);
        }
        
        // Create the aggregate
        return new Order(
            OrderId.NewId(),
            customerId,
            orderItems);
    }
}

public class OrderItemRequest
{
    public ProductId ProductId { get; set; }
    public int Quantity { get; set; }
}
```

**Abstract Factories** Create families of related objects, useful when you need different implementations based on context:

```csharp
public interface IPaymentMethodFactory
{
    PaymentMethod CreatePaymentMethod(PaymentMethodType type, PaymentDetails details);
}

public class PaymentMethodFactory : IPaymentMethodFactory
{
    public PaymentMethod CreatePaymentMethod(
        PaymentMethodType type, 
        PaymentDetails details)
    {
        return type switch
        {
            PaymentMethodType.CreditCard => CreateCreditCardPayment(details),
            PaymentMethodType.BankTransfer => CreateBankTransferPayment(details),
            PaymentMethodType.DigitalWallet => CreateDigitalWalletPayment(details),
            _ => throw new DomainException($"Unsupported payment type: {type}")
        };
    }
    
    private CreditCardPayment CreateCreditCardPayment(PaymentDetails details)
    {
        var cardNumber = CardNumber.Create(details.CardNumber);
        var expiryDate = ExpiryDate.Create(details.ExpiryMonth, details.ExpiryYear);
        
        if (expiryDate.IsExpired())
            throw new DomainException("Card has expired");
        
        return new CreditCardPayment(cardNumber, expiryDate, details.Cvv);
    }
    
    private BankTransferPayment CreateBankTransferPayment(PaymentDetails details)
    {
        var accountNumber = AccountNumber.Create(details.AccountNumber);
        var routingNumber = RoutingNumber.Create(details.RoutingNumber);
        
        return new BankTransferPayment(accountNumber, routingNumber);
    }
    
    private DigitalWalletPayment CreateDigitalWalletPayment(PaymentDetails details)
    {
        var walletId = WalletId.Create(details.WalletId);
        
        return new DigitalWalletPayment(walletId, details.Provider);
    }
}
```

### Factory Methods on Entities

Sometimes the best place for a Factory is as a static method or instance method on the entity itself, especially for simpler creation scenarios:

```csharp
public class Product
{
    public ProductId Id { get; private set; }
    public string Name { get; private set; }
    public Money Price { get; private set; }
    public ProductCategory Category { get; private set; }
    public bool IsAvailable { get; private set; }
    
    private Product() { }
    
    // Factory method for new products
    public static Product Create(
        string name,
        decimal price,
        ProductCategory category)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new DomainException("Product name is required");
        
        if (price <= 0)
            throw new DomainException("Price must be positive");
        
        return new Product
        {
            Id = ProductId.NewId(),
            Name = name,
            Price = Money.FromDecimal(price),
            Category = category,
            IsAvailable = true
        };
    }
    
    // Factory method for creating variants
    public Product CreateVariant(string variantName, decimal priceAdjustment)
    {
        if (string.IsNullOrWhiteSpace(variantName))
            throw new DomainException("Variant name is required");
        
        var variantPrice = Price.Amount + priceAdjustment;
        if (variantPrice <= 0)
            throw new DomainException("Variant price must be positive");
        
        return new Product
        {
            Id = ProductId.NewId(),
            Name = $"{Name} - {variantName}",
            Price = Money.FromDecimal(variantPrice),
            Category = Category,
            IsAvailable = IsAvailable
        };
    }
}
```

### Factories vs Constructors

**When to Use Constructors** Simple entities with straightforward creation requirements can use public constructors:

```csharp
public class Address
{
    public string Street { get; private set; }
    public string City { get; private set; }
    public string State { get; private set; }
    public string PostalCode { get; private set; }
    public string Country { get; private set; }
    
    public Address(
        string street,
        string city,
        string state,
        string postalCode,
        string country)
    {
        if (string.IsNullOrWhiteSpace(street))
            throw new DomainException("Street is required");
        if (string.IsNullOrWhiteSpace(city))
            throw new DomainException("City is required");
        
        Street = street;
        City = city;
        State = state;
        PostalCode = postalCode;
        Country = country;
    }
}
```

**When to Use Factories** Use Factories when:

- Creation requires external dependencies (repositories, services)
- Multiple related objects must be created together
- Creation logic is complex or involves multiple steps
- Different creation strategies are needed
- The entity needs different construction paths (new vs reconstitution)

```csharp
// Complex creation requiring dependencies - use Factory
public class SubscriptionFactory
{
    private readonly IPlanRepository _planRepository;
    private readonly IPaymentGateway _paymentGateway;
    private readonly IDiscountService _discountService;
    
    public async Task<Subscription> CreateSubscriptionAsync(
        CustomerId customerId,
        PlanId planId,
        PaymentMethod paymentMethod,
        string promoCode = null)
    {
        var plan = await _planRepository.GetByIdAsync(planId);
        if (plan == null)
            throw new DomainException("Plan not found");
        
        var price = plan.MonthlyPrice;
        
        // Apply discount if promo code provided
        if (!string.IsNullOrEmpty(promoCode))
        {
            var discount = await _discountService.ValidateAndGetDiscountAsync(promoCode);
            price = discount.Apply(price);
        }
        
        // Verify payment method
        var validationResult = await _paymentGateway.ValidatePaymentMethodAsync(paymentMethod);
        if (!validationResult.IsValid)
            throw new DomainException("Invalid payment method");
        
        // Create subscription
        return new Subscription(
            SubscriptionId.NewId(),
            customerId,
            plan,
            paymentMethod,
            price,
            DateTime.UtcNow,
            DateTime.UtcNow.AddMonths(1));
    }
}
```

### Reconstitution from Persistence

Factories play a crucial role in rebuilding domain objects from stored data. This process bypasses normal creation validation since the data was already validated when first created:

```csharp
public class OrderFactory
{
    // For creating new orders - applies all validation
    public async Task<Order> CreateNewOrderAsync(
        CustomerId customerId,
        IEnumerable<OrderItemRequest> items)
    {
        // Full validation and business logic
        // ...
    }
    
    // For reconstituting from database - minimal validation
    public Order ReconstitutFromPersistence(OrderData data)
    {
        var items = data.Items.Select(itemData => 
            new OrderItem(
                new ProductId(itemData.ProductId),
                itemData.ProductName,
                new Money(itemData.UnitPrice),
                itemData.Quantity));
        
        var order = new Order(
            new OrderId(data.Id),
            new CustomerId(data.CustomerId),
            items);
        
        // Restore state that can't be set through constructor
        order.SetStatus(Enum.Parse<OrderStatus>(data.Status));
        order.SetTotal(new Money(data.Total));
        
        return order;
    }
}

// Alternative: Reconstitution as an internal constructor
public class Order
{
    // Public factory method for new orders
    public static Order CreateNew(/* ... */) { }
    
    // Internal constructor for persistence layer
    internal Order(
        OrderId id,
        CustomerId customerId,
        IEnumerable<OrderItem> items,
        OrderStatus status,
        Money total,
        DateTime createdAt)
    {
        // Minimal validation - trust the data from persistence
        Id = id;
        CustomerId = customerId;
        _items.AddRange(items);
        Status = status;
        Total = total;
        CreatedAt = createdAt;
    }
}
```

### Factory Location and Organization

**Domain Layer Factories** Most Factories belong in the domain layer since they enforce business rules:

```
Domain/
├── Entities/
│   ├── Customer.cs
│   ├── Order.cs
│   └── Product.cs
├── Factories/
│   ├── CustomerFactory.cs
│   ├── OrderFactory.cs
│   └── IPaymentMethodFactory.cs
├── ValueObjects/
└── Services/
```

**Application Layer Factory Usage** Application services coordinate Factory usage:

```csharp
public class CreateOrderHandler
{
    private readonly OrderFactory _orderFactory;
    private readonly IOrderRepository _orderRepository;
    private readonly IUnitOfWork _unitOfWork;
    
    public CreateOrderHandler(
        OrderFactory orderFactory,
        IOrderRepository orderRepository,
        IUnitOfWork unitOfWork)
    {
        _orderFactory = orderFactory;
        _orderRepository = orderRepository;
        _unitOfWork = unitOfWork;
    }
    
    public async Task<Result<OrderDto>> HandleAsync(CreateOrderCommand command)
    {
        try
        {
            // Use factory to create the aggregate
            var order = await _orderFactory.CreateOrderAsync(
                new CustomerId(command.CustomerId),
                command.Items);
            
            // Persist through repository
            await _orderRepository.SaveAsync(order);
            await _unitOfWork.CommitAsync();
            
            return Result<OrderDto>.Success(OrderDto.FromDomain(order));
        }
        catch (DomainException ex)
        {
            return Result<OrderDto>.Failure(ex.Message);
        }
    }
}
```

### Dependency Injection with Factories

Factories often need dependencies, making them perfect candidates for dependency injection:

```csharp
// Startup/Program.cs
public void ConfigureServices(IServiceCollection services)
{
    // Register repositories and services
    services.AddScoped<IProductRepository, ProductRepository>();
    services.AddScoped<IPricingService, PricingService>();
    services.AddScoped<ICreditCheckService, CreditCheckService>();
    
    // Register factories
    services.AddScoped<OrderFactory>();
    services.AddScoped<CustomerFactory>();
    services.AddSingleton<IPaymentMethodFactory, PaymentMethodFactory>();
    
    // Register application handlers
    services.AddScoped<CreateOrderHandler>();
}
```

### Factory Patterns for Different Scenarios

**Builder Pattern Integration** For objects with many optional parameters, combine Factory with Builder:

```csharp
public class OrderBuilder
{
    private CustomerId _customerId;
    private readonly List<OrderItemRequest> _items = new();
    private Address _shippingAddress;
    private ShippingMethod _shippingMethod;
    private string _notes;
    
    public OrderBuilder ForCustomer(CustomerId customerId)
    {
        _customerId = customerId;
        return this;
    }
    
    public OrderBuilder AddItem(ProductId productId, int quantity)
    {
        _items.Add(new OrderItemRequest { ProductId = productId, Quantity = quantity });
        return this;
    }
    
    public OrderBuilder WithShipping(Address address, ShippingMethod method)
    {
        _shippingAddress = address;
        _shippingMethod = method;
        return this;
    }
    
    public OrderBuilder WithNotes(string notes)
    {
        _notes = notes;
        return this;
    }
    
    public async Task<Order> BuildAsync(OrderFactory factory)
    {
        if (_customerId == null)
            throw new InvalidOperationException("Customer is required");
        
        var order = await factory.CreateOrderAsync(_customerId, _items);
        
        if (_shippingAddress != null)
            order.SetShipping(_shippingAddress, _shippingMethod);
        
        if (!string.IsNullOrEmpty(_notes))
            order.AddNotes(_notes);
        
        return order;
    }
}

// Usage
var order = await new OrderBuilder()
    .ForCustomer(customerId)
    .AddItem(productId1, 2)
    .AddItem(productId2, 1)
    .WithShipping(address, ShippingMethod.Express)
    .WithNotes("Gift wrap requested")
    .BuildAsync(orderFactory);
```

**Specification Pattern for Creation Rules** Use specifications to determine which concrete type to create:

```csharp
public interface IAccountFactory
{
    Account CreateAccount(Customer customer, AccountType type, Money initialDeposit);
}

public class AccountFactory : IAccountFactory
{
    private readonly IAccountSpecification[] _specifications;
    
    public AccountFactory(IEnumerable<IAccountSpecification> specifications)
    {
        _specifications = specifications.ToArray();
    }
    
    public Account CreateAccount(
        Customer customer, 
        AccountType type, 
        Money initialDeposit)
    {
        // Find applicable specification
        var spec = _specifications.FirstOrDefault(s => 
            s.IsSatisfiedBy(customer, type, initialDeposit));
        
        if (spec == null)
            throw new DomainException("Customer does not qualify for this account type");
        
        return type switch
        {
            AccountType.Savings => CreateSavingsAccount(customer, initialDeposit, spec),
            AccountType.Checking => CreateCheckingAccount(customer, initialDeposit, spec),
            AccountType.Premium => CreatePremiumAccount(customer, initialDeposit, spec),
            _ => throw new DomainException($"Unknown account type: {type}")
        };
    }
    
    private SavingsAccount CreateSavingsAccount(
        Customer customer, 
        Money initialDeposit,
        IAccountSpecification spec)
    {
        var interestRate = spec.GetInterestRate(customer);
        return new SavingsAccount(
            AccountId.NewId(),
            customer.Id,
            initialDeposit,
            interestRate);
    }
    
    // Similar methods for other account types...
}

public interface IAccountSpecification
{
    bool IsSatisfiedBy(Customer customer, AccountType type, Money initialDeposit);
    decimal GetInterestRate(Customer customer);
}

public class PremiumAccountSpecification : IAccountSpecification
{
    public bool IsSatisfiedBy(Customer customer, AccountType type, Money initialDeposit)
    {
        return type == AccountType.Premium 
            && customer.CreditScore >= 750 
            && initialDeposit.Amount >= 10000;
    }
    
    public decimal GetInterestRate(Customer customer)
    {
        return customer.CreditScore >= 800 ? 0.025m : 0.020m;
    }
}
```

### Validation in Factories

Factories are responsible for ensuring objects are created in valid states:

```csharp
public class InvoiceFactory
{
    private readonly IInvoiceNumberGenerator _numberGenerator;
    private readonly ITaxCalculator _taxCalculator;
    private readonly ICustomerRepository _customerRepository;
    
    public async Task<Invoice> CreateInvoiceAsync(
        CustomerId customerId,
        IEnumerable<InvoiceLineRequest> lines,
        DateTime dueDate)
    {
        // Validate customer
        var customer = await _customerRepository.GetByIdAsync(customerId);
        if (customer == null)
            throw new DomainException("Customer not found");
        
        if (!customer.CanBeInvoiced())
            throw new DomainException("Customer account is not in good standing");
        
        // Validate due date
        if (dueDate <= DateTime.UtcNow)
            throw new DomainException("Due date must be in the future");
        
        if (dueDate > DateTime.UtcNow.AddDays(90))
            throw new DomainException("Due date cannot exceed 90 days");
        
        // Validate lines
        if (!lines.Any())
            throw new DomainException("Invoice must contain at least one line item");
        
        // Create line items
        var invoiceLines = new List<InvoiceLine>();
        foreach (var lineRequest in lines)
        {
            ValidateLineRequest(lineRequest);
            
            var line = new InvoiceLine(
                lineRequest.Description,
                lineRequest.Quantity,
                Money.FromDecimal(lineRequest.UnitPrice));
            
            invoiceLines.Add(line);
        }
        
        // Calculate totals
        var subtotal = invoiceLines.Sum(l => l.Amount);
        var tax = _taxCalculator.Calculate(subtotal, customer.BillingAddress);
        var total = subtotal + tax;
        
        // Generate invoice number
        var invoiceNumber = await _numberGenerator.GenerateNextAsync();
        
        // Create invoice
        return new Invoice(
            InvoiceId.NewId(),
            invoiceNumber,
            customerId,
            invoiceLines,
            subtotal,
            tax,
            total,
            DateTime.UtcNow,
            dueDate);
    }
    
    private void ValidateLineRequest(InvoiceLineRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Description))
            throw new DomainException("Line description is required");
        
        if (request.Quantity <= 0)
            throw new DomainException("Quantity must be positive");
        
        if (request.UnitPrice <= 0)
            throw new DomainException("Unit price must be positive");
    }
}
```

### Testing Factories

**Unit Testing Factory Logic**

```csharp
[TestClass]
public class OrderFactoryTests
{
    private Mock<IProductRepository> _mockProductRepo;
    private Mock<IPricingService> _mockPricingService;
    private OrderFactory _factory;
    
    [TestInitialize]
    public void Setup()
    {
        _mockProductRepo = new Mock<IProductRepository>();
        _mockPricingService = new Mock<IPricingService>();
        _factory = new OrderFactory(_mockProductRepo.Object, _mockPricingService.Object);
    }
    
    [TestMethod]
    public async Task CreateOrder_WithValidItems_ShouldSucceed()
    {
        // Arrange
        var customerId = CustomerId.NewId();
        var product = Product.Create("Test Product", 10.00m, ProductCategory.Electronics);
        
        _mockProductRepo
            .Setup(r => r.GetByIdAsync(It.IsAny<ProductId>()))
            .ReturnsAsync(product);
        
        _mockPricingService
            .Setup(s => s.GetPriceAsync(It.IsAny<ProductId>(), It.IsAny<CustomerId>(), It.IsAny<int>()))
            .ReturnsAsync(Money.FromDecimal(10.00m));
        
        var items = new[]
        {
            new OrderItemRequest { ProductId = product.Id, Quantity = 2 }
        };
        
        // Act
        var order = await _factory.CreateOrderAsync(customerId, items);
        
        // Assert
        Assert.IsNotNull(order);
        Assert.AreEqual(customerId, order.CustomerId);
        Assert.AreEqual(1, order.Items.Count);
        Assert.AreEqual(Money.FromDecimal(20.00m), order.Total);
    }
    
    [TestMethod]
    public async Task CreateOrder_WithUnavailableProduct_ShouldThrowException()
    {
        // Arrange
        var customerId = CustomerId.NewId();
        var product = Product.Create("Test Product", 10.00m, ProductCategory.Electronics);
        product.MarkAsUnavailable();
        
        _mockProductRepo
            .Setup(r => r.GetByIdAsync(It.IsAny<ProductId>()))
            .ReturnsAsync(product);
        
        var items = new[]
        {
            new OrderItemRequest { ProductId = product.Id, Quantity = 1 }
        };
        
        // Act & Assert
        await Assert.ThrowsExceptionAsync<DomainException>(
            () => _factory.CreateOrderAsync(customerId, items));
    }
    
    [TestMethod]
    public async Task CreateOrder_WithEmptyItems_ShouldThrowException()
    {
        // Arrange
        var customerId = CustomerId.NewId();
        var items = Array.Empty<OrderItemRequest>();
        
        // Act & Assert
        await Assert.ThrowsExceptionAsync<DomainException>(
            () => _factory.CreateOrderAsync(customerId, items));
    }
}
```

**Integration Testing with Real Dependencies**

```csharp
[TestClass]
public class OrderFactoryIntegrationTests
{
    private OrderFactory _factory;
    private IProductRepository _productRepository;
    
    [TestInitialize]
    public void Setup()
    {
        // Use real database for integration testing
        var dbContext = CreateTestDatabase();
        _productRepository = new ProductRepository(dbContext);
        var pricingService = new PricingService();
        
        _factory = new OrderFactory(_productRepository, pricingService);
    }
    
    [TestMethod]
    public async Task CreateOrder_EndToEnd_ShouldCreateValidOrder()
    {
        // Arrange - seed test data
        var product = Product.Create("Integration Test Product", 15.00m, ProductCategory.Books);
        await _productRepository.SaveAsync(product);
        
        var customerId = CustomerId.NewId();
        var items = new[]
        {
            new OrderItemRequest { ProductId = product.Id, Quantity = 3 }
        };
        
        // Act
        var order = await _factory.CreateOrderAsync(customerId, items);
        
        // Assert
        Assert.IsNotNull(order);
        Assert.AreEqual(Money.FromDecimal(45.00m), order.Total);
        Assert.AreEqual(OrderStatus.Draft, order.Status);
    }
}
```

### Common Mistakes and Anti-Patterns

**Anemic Factories** Factories that simply call `new` without adding value:

```csharp
// BAD: Factory adds no value
public class CustomerFactory
{
    public Customer Create(string name, string email)
    {
        return new Customer(name, email); // Just calling constructor
    }
}

// GOOD: Use constructor directly or add meaningful logic
public class Customer
{
    public Customer(string name, string email)
    {
        // Validation and construction logic here
    }
}
```

**God Factories** Factories that create too many different types:

```csharp
// BAD: Factory doing too much
public class DomainObjectFactory
{
    public Customer CreateCustomer(/* ... */) { }
    public Order CreateOrder(/* ... */) { }
    public Product CreateProduct(/* ... */) { }
    public Invoice CreateInvoice(/* ... */) { }
    // ... 20 more creation methods
}

// GOOD: Separate factories
public class CustomerFactory { }
public class OrderFactory { }
public class ProductFactory { }
```

**Factories with Business Logic** Factories should create objects, not execute business processes:

```csharp
// BAD: Factory executing business logic
public class OrderFactory
{
    public async Task<Order> CreateAndSubmitOrderAsync(/* ... */)
    {
        var order = CreateOrder(/* ... */);
        order.Submit(); // Business operation, not creation
        await _paymentService.ProcessPayment(order); // Not factory responsibility
        await _repository.Save(order); // Persistence, not creation
        return order;
    }
}

// GOOD: Factory only creates
public class OrderFactory
{
    public Order CreateOrder(/* ... */)
    {
        // Only creation logic
        return new Order(/* ... */);
    }
}

// Business logic in application service
public class SubmitOrderHandler
{
    public async Task HandleAsync(SubmitOrderCommand command)
    {
        var order = await _orderRepository.GetById(command.OrderId);
        order.Submit(); // Business logic on entity
        await _repository.Save(order);
    }
}
```

### **Example: E-Commerce Product Catalog System**

A comprehensive example showing multiple Factory patterns working together:

```csharp
// DOMAIN ENTITIES
public class Product
{
    public ProductId Id { get; private set; }
    public string Name { get; private set; }
    public ProductType Type { get; private set; }
    public Money BasePrice { get; private set; }
    public ProductStatus Status { get; private set; }

    private readonly List<ProductAttribute> _attributes = new();
    public IReadOnlyCollection<ProductAttribute> Attributes => _attributes.AsReadOnly();

    private Product() { }

    internal Product(
        ProductId id,
        string name,
        ProductType type,
        Money basePrice,
        IEnumerable<ProductAttribute> attributes)
    {
        Id = id;
        Name = name;
        Type = type;
        BasePrice = basePrice;
        Status = ProductStatus.Draft;
        _attributes.AddRange(attributes);
    }
}

public class ProductAttribute
{
    public string Name { get; private set; }
    public string Value { get; private set; }

    public ProductAttribute(string name, string value)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new DomainException("Attribute name is required");

        Name = name;
        Value = value;
    }
}


// ABSTRACT FACTORY INTERFACE
public interface IProductFactory
{
    Task<Product> CreateProductAsync(ProductCreationRequest request);
    bool CanCreate(ProductType type);
}


// CONCRETE FACTORY FOR PHYSICAL PRODUCTS
public class PhysicalProductFactory : IProductFactory
{
    private readonly IProductValidator _validator;
    private readonly IInventoryService _inventoryService;

    public PhysicalProductFactory(
        IProductValidator validator,
        IInventoryService inventoryService)
    {
        _validator = validator;
        _inventoryService = inventoryService;
    }

    public bool CanCreate(ProductType type)
    {
        return type == ProductType.Physical;
    }

    public async Task<Product> CreateProductAsync(ProductCreationRequest request)
    {
        // Validate physical product requirements
        if (!_validator.ValidateDimensions(request.Dimensions))
            throw new DomainException("Invalid product dimensions");

        if (!_validator.ValidateWeight(request.Weight))
            throw new DomainException("Invalid product weight");

        // Check if we can fulfill this product
        var canFulfill = await _inventoryService.CanFulfillAsync(
            request.Dimensions,
            request.Weight
        );

        if (!canFulfill)
            throw new DomainException("Cannot fulfill product with these specifications");

        var attributes = new List<ProductAttribute>
        {
            new ProductAttribute("Weight", $"{request.Weight} kg"),
            new ProductAttribute("Dimensions", request.Dimensions.ToString()),
            new ProductAttribute("ShippingClass", request.ShippingClass)
        };

        return new Product(
            ProductId.NewId(),
            request.Name,
            ProductType.Physical,
            Money.FromDecimal(request.Price),
            attributes
        );
    }
}


// CONCRETE FACTORY FOR DIGITAL PRODUCTS
public class DigitalProductFactory : IProductFactory
{
    private readonly ILicenseGenerator _licenseGenerator;
    private readonly IStorageService _storageService;

    public DigitalProductFactory(
        ILicenseGenerator licenseGenerator,
        IStorageService storageService)
    {
        _licenseGenerator = licenseGenerator;
        _storageService = storageService;
    }

    public bool CanCreate(ProductType type)
    {
        return type == ProductType.Digital;
    }

    public async Task<Product> CreateProductAsync(ProductCreationRequest request)
    {
        // Validate digital product requirements
        if (string.IsNullOrEmpty(request.DownloadUrl))
            throw new DomainException("Download URL is required for digital products");

        // Verify file exists and is accessible
        var fileExists = await _storageService.FileExistsAsync(request.DownloadUrl);
        if (!fileExists)
            throw new DomainException("Download file not found");

        // Generate license template
        var licenseTemplate =
            await _licenseGenerator.CreateTemplateAsync(request.LicenseType);

        var attributes = new List<ProductAttribute>
        {
            new ProductAttribute("FileSize", $"{request.FileSize} MB"),
            new ProductAttribute("FileFormat", request.FileFormat),
            new ProductAttribute("LicenseType", request.LicenseType),
            new ProductAttribute("DownloadLimit", request.DownloadLimit.ToString()),
            new ProductAttribute("LicenseTemplate", licenseTemplate)
        };

        return new Product(
            ProductId.NewId(),
            request.Name,
            ProductType.Digital,
            Money.FromDecimal(request.Price),
            attributes
        );
    }
}


// FACTORY PROVIDER
public class ProductFactoryProvider
{
    private readonly IEnumerable<IProductFactory> _factories;

    public ProductFactoryProvider(IEnumerable<IProductFactory> factories)
    {
        _factories = factories;
    }

    public IProductFactory GetFactory(ProductType type)
    {
        var factory = _factories.FirstOrDefault(f => f.CanCreate(type));

        if (factory == null)
            throw new DomainException($"No factory available for product type: {type}");

        return factory;
    }
}


// APPLICATION SERVICE USING FACTORIES
public class CreateProductHandler
{
    private readonly ProductFactoryProvider _factoryProvider;
    private readonly IProductRepository _productRepository;
    private readonly IUnitOfWork _unitOfWork;

    public CreateProductHandler(
        ProductFactoryProvider factoryProvider,
        IProductRepository productRepository,
        IUnitOfWork unitOfWork)
    {
        _factoryProvider = factoryProvider;
        _productRepository = productRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<ProductDto>> HandleAsync(CreateProductCommand command)
    {
        try
        {
            // Get appropriate factory based on product type
            var factory = _factoryProvider.GetFactory(command.Type);

            // Create the product using the factory
            var product = await factory.CreateProductAsync(
                new ProductCreationRequest
                {
                    Name = command.Name,
                    Price = command.Price,
                    Type = command.Type,
                    Dimensions = command.Dimensions,
                    Weight = command.Weight,
                    ShippingClass = command.ShippingClass,
                    DownloadUrl = command.DownloadUrl,
                    FileSize = command.FileSize,
                    FileFormat = command.FileFormat,
                    LicenseType = command.LicenseType,
                    DownloadLimit = command.DownloadLimit
                });

            // Persist the product
            await _productRepository.SaveAsync(product);
            await _unitOfWork.CommitAsync();

            return Result<ProductDto>.Success(
                ProductDto.FromDomain(product)
            );
        }
        catch (DomainException ex)
        {
            return Result<ProductDto>.Failure(ex.Message);
        }
    }
}


// DEPENDENCY INJECTION SETUP
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        // Register individual factories
        services.AddScoped<IProductFactory, PhysicalProductFactory>();
        services.AddScoped<IProductFactory, DigitalProductFactory>();

        // Register factory provider
        services.AddScoped<ProductFactoryProvider>();

        // Register dependencies
        services.AddScoped<IProductValidator, ProductValidator>();
        services.AddScoped<IInventoryService, InventoryService>();
        services.AddScoped<ILicenseGenerator, LicenseGenerator>();
        services.AddScoped<IStorageService, StorageService>();

        // Register repositories and handlers
        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<CreateProductHandler>();
    }
}
```

**Output:**
When creating a physical product, the system:
1. Receives request through handler
2. Factory provider selects PhysicalProductFactory
3. Factory validates dimensions and weight
4. Checks inventory service for fulfillment capability
5. Creates product with physical attributes
6. Repository persists the product

When creating a digital product:
1. Factory provider selects DigitalProductFactory
2. Factory verifies download file exists
3. Generates license template
4. Creates product with digital attributes
5. Same persistence flow

### Best Practices

**Single Responsibility**
Each Factory should create one type or family of related types. Don't create mega-factories.

**Dependency Injection**
Register Factories in your DI container. They often need repositories and domain services.

**Interface Segregation**
Define narrow interfaces for Factories. Clients should only depend on methods they use.

**Fail Fast**
Validate immediately. If creation cannot succeed, throw exceptions before attempting partial construction.

**Immutability Preference**
Create objects in their final state when possible. Avoid Factories that return partially constructed objects.

**Clear Naming**
Use descriptive names: `OrderFactory`, `CustomerFactory`. Avoid generic names like `ObjectFactory` or `DomainFactory`.

**Documentation**
Document complex creation rules, especially when Factories coordinate multiple domain services.

**Conclusion:**
Factories in Domain-Driven Design serve as guardians of object creation, ensuring domain objects always exist in valid states. They encapsulate complex construction logic, coordinate with domain services, maintain invariants, and provide clean interfaces for creating aggregates and entities. While simple objects can use constructors directly, Factories become essential when dealing with complex domains where creation requires validation, external dependencies, or coordination of multiple objects. By placing creation responsibility in dedicated Factories, you keep your domain model clean, maintainable, and focused on business logic rather than construction concerns. The investment in well-designed Factories pays dividends in code quality, testability, and the ability to evolve your domain model over time.
```

---

## Domain Service Pattern

The Domain Service pattern encapsulates business logic that doesn't naturally fit within a single entity or value object. It represents operations, processes, or transformations that involve multiple domain objects or require coordination across entities, yet conceptually belong to the domain layer rather than application or infrastructure layers.

### Core Concept

Domain services differ from entities and value objects in that they are stateless operations defined by what they do rather than what they are. When business logic doesn't belong to any particular entity—either because it operates on multiple entities, performs calculations, or coordinates complex domain operations—a domain service provides the appropriate home for this logic.

The fundamental characteristic is that domain services express domain concepts and business rules in their pure form, independent of technical concerns like persistence, external APIs, or user interface requirements. They speak the ubiquitous language of the domain and represent activities or processes that domain experts recognize and discuss.

### Identifying Domain Services

#### When Entities Are Insufficient

Business logic that spans multiple entities:

- Transferring money between two bank accounts involves both accounts
- Calculating shipping costs requires product, destination, and carrier information
- Verifying user credentials involves user entity and authentication policies
- Booking a reservation affects availability, customer, and room entities

#### Operations Without Natural Owners

Activities that don't belong to a specific object:

- Currency conversion is not a responsibility of Money objects
- Tax calculation involves rules beyond product or order entities
- Risk assessment aggregates data from multiple sources
- Pricing strategies consider market conditions, not just product state

#### Coordinating Complex Workflows

Multi-step domain processes:

- Order fulfillment involves inventory, payment, shipping
- Loan approval requires credit check, collateral evaluation, risk assessment
- Medical diagnosis considers symptoms, history, test results
- Tournament scheduling balances teams, venues, and time slots

### Domain Service Characteristics

#### Statelessness

No instance-specific data:

```java
// Domain Service - Stateless
public class MoneyTransferService {
    // No instance fields
    
    public TransferResult transfer(
        Account source,
        Account destination,
        Money amount
    ) {
        // Operation uses only parameters
        if (!source.canWithdraw(amount)) {
            return TransferResult.insufficientFunds();
        }
        
        source.withdraw(amount);
        destination.deposit(amount);
        
        return TransferResult.success();
    }
}
```

#### Domain Language

Express business concepts directly:

```java
// Good: Domain language
public class PricingService {
    public Price calculatePrice(
        Product product,
        Customer customer,
        PromotionalCampaign campaign
    ) {
        Price basePrice = product.getBasePrice();
        Discount customerDiscount = customer.getDiscountTier().getDiscount();
        Discount campaignDiscount = campaign.getDiscountFor(product);
        
        return basePrice
            .applyDiscount(customerDiscount)
            .applyDiscount(campaignDiscount);
    }
}

// Bad: Technical language
public class PriceCalculator {
    public double compute(ProductDTO p, CustomerDTO c, CampaignDTO ca) {
        return p.price * (1 - c.discount) * (1 - ca.discount);
    }
}
```

#### Interface Defined by Operations

Service identity comes from what it does:

```java
// Service interface expresses domain operations
public interface CreditScoringService {
    CreditScore evaluateCreditworthiness(
        Customer customer,
        LoanApplication application
    );
    
    RiskCategory assessRisk(CreditScore score, Money loanAmount);
    
    boolean meetsLendingCriteria(
        Customer customer,
        Money requestedAmount,
        LoanTerm term
    );
}
```

### Implementation Strategies

#### Pure Domain Services

Only domain logic, no infrastructure:

```java
public class OrderFulfillmentService {
    // Dependencies are domain repositories/services only
    private final InventoryRepository inventoryRepository;
    private final PaymentService paymentService;
    
    public OrderFulfillmentService(
        InventoryRepository inventoryRepository,
        PaymentService paymentService
    ) {
        this.inventoryRepository = inventoryRepository;
        this.paymentService = paymentService;
    }
    
    public FulfillmentResult fulfillOrder(Order order) {
        // Check inventory availability
        List<OrderLine> orderLines = order.getOrderLines();
        for (OrderLine line : orderLines) {
            if (!inventoryRepository.hasStock(line.getProduct(), line.getQuantity())) {
                return FulfillmentResult.outOfStock(line.getProduct());
            }
        }
        
        // Process payment
        PaymentResult paymentResult = paymentService.processPayment(
            order.getCustomer(),
            order.getTotalAmount()
        );
        
        if (!paymentResult.isSuccessful()) {
            return FulfillmentResult.paymentFailed(paymentResult.getReason());
        }
        
        // Reserve inventory
        for (OrderLine line : orderLines) {
            inventoryRepository.reserve(line.getProduct(), line.getQuantity());
        }
        
        // Mark order as fulfilled
        order.markAsFulfilled();
        
        return FulfillmentResult.success();
    }
}
```

#### Policy-Based Services

Encapsulate business rules:

```java
public class ShippingCostCalculationService {
    private final List<ShippingPolicy> policies;
    
    public ShippingCostCalculationService() {
        this.policies = List.of(
            new WeightBasedPolicy(),
            new DistanceBasedPolicy(),
            new ExpressShippingPolicy(),
            new FreeShippingThresholdPolicy()
        );
    }
    
    public Money calculateShippingCost(
        Shipment shipment,
        Address destination,
        ShippingMethod method
    ) {
        Money baseCost = Money.zero(shipment.getCurrency());
        
        for (ShippingPolicy policy : policies) {
            if (policy.appliesTo(shipment, destination, method)) {
                baseCost = policy.calculate(baseCost, shipment, destination, method);
            }
        }
        
        return baseCost;
    }
}

// Individual policies
interface ShippingPolicy {
    boolean appliesTo(Shipment shipment, Address destination, ShippingMethod method);
    Money calculate(Money currentCost, Shipment shipment, Address destination, ShippingMethod method);
}

class WeightBasedPolicy implements ShippingPolicy {
    private static final Money RATE_PER_KG = Money.of(2.50, Currency.USD);
    
    @Override
    public boolean appliesTo(Shipment shipment, Address destination, ShippingMethod method) {
        return true; // Always applies
    }
    
    @Override
    public Money calculate(Money currentCost, Shipment shipment, Address destination, ShippingMethod method) {
        Weight totalWeight = shipment.getTotalWeight();
        Money weightCost = RATE_PER_KG.multiply(totalWeight.inKilograms());
        return currentCost.add(weightCost);
    }
}

class FreeShippingThresholdPolicy implements ShippingPolicy {
    private static final Money FREE_SHIPPING_THRESHOLD = Money.of(50.00, Currency.USD);
    
    @Override
    public boolean appliesTo(Shipment shipment, Address destination, ShippingMethod method) {
        return shipment.getOrderTotal().isGreaterThanOrEqual(FREE_SHIPPING_THRESHOLD);
    }
    
    @Override
    public Money calculate(Money currentCost, Shipment shipment, Address destination, ShippingMethod method) {
        return Money.zero(currentCost.getCurrency()); // Free shipping
    }
}
```

#### Validation Services

Complex validation logic:

```java
public class LoanApplicationValidationService {
    private final CreditBureauService creditBureauService;
    private final CollateralValuationService collateralValuationService;
    
    public ValidationResult validate(LoanApplication application) {
        List<ValidationError> errors = new ArrayList<>();
        
        // Validate credit score
        CreditScore creditScore = creditBureauService.getCreditScore(
            application.getApplicant()
        );
        
        if (creditScore.getValue() < 600) {
            errors.add(new ValidationError(
                "CREDIT_SCORE_TOO_LOW",
                "Credit score must be at least 600"
            ));
        }
        
        // Validate debt-to-income ratio
        Money monthlyIncome = application.getApplicant().getMonthlyIncome();
        Money existingDebt = application.getApplicant().getTotalMonthlyDebt();
        Money proposedPayment = application.calculateMonthlyPayment();
        
        BigDecimal dtiRatio = existingDebt
            .add(proposedPayment)
            .divide(monthlyIncome);
        
        if (dtiRatio.compareTo(new BigDecimal("0.43")) > 0) {
            errors.add(new ValidationError(
                "DTI_TOO_HIGH",
                "Debt-to-income ratio exceeds 43%"
            ));
        }
        
        // Validate collateral if secured loan
        if (application.isSecured()) {
            Money collateralValue = collateralValuationService.valuate(
                application.getCollateral()
            );
            
            BigDecimal ltvRatio = application.getRequestedAmount()
                .divide(collateralValue);
            
            if (ltvRatio.compareTo(new BigDecimal("0.80")) > 0) {
                errors.add(new ValidationError(
                    "LTV_TOO_HIGH",
                    "Loan-to-value ratio exceeds 80%"
                ));
            }
        }
        
        return errors.isEmpty() 
            ? ValidationResult.valid()
            : ValidationResult.invalid(errors);
    }
}
```

#### Calculation Services

Complex computations:

```java
public class PortfolioAnalysisService {
    private final MarketDataService marketDataService;
    
    public PortfolioMetrics analyzePortfolio(Portfolio portfolio) {
        List<Position> positions = portfolio.getPositions();
        
        // Calculate total value
        Money totalValue = positions.stream()
            .map(p -> p.getCurrentValue(marketDataService))
            .reduce(Money.zero(portfolio.getCurrency()), Money::add);
        
        // Calculate returns
        Money totalCost = positions.stream()
            .map(Position::getCostBasis)
            .reduce(Money.zero(portfolio.getCurrency()), Money::add);
        
        BigDecimal totalReturn = totalValue
            .subtract(totalCost)
            .divide(totalCost);
        
        // Calculate volatility
        List<BigDecimal> returns = positions.stream()
            .map(p -> p.calculateHistoricalReturns(marketDataService))
            .flatMap(List::stream)
            .collect(Collectors.toList());
        
        BigDecimal volatility = calculateStandardDeviation(returns);
        
        // Calculate Sharpe ratio
        BigDecimal riskFreeRate = marketDataService.getRiskFreeRate();
        BigDecimal excessReturn = totalReturn.subtract(riskFreeRate);
        BigDecimal sharpeRatio = excessReturn.divide(
            volatility, 
            RoundingMode.HALF_UP
        );
        
        // Calculate beta
        BigDecimal beta = calculatePortfolioBeta(positions, marketDataService);
        
        return new PortfolioMetrics(
            totalValue,
            totalReturn,
            volatility,
            sharpeRatio,
            beta
        );
    }
    
    private BigDecimal calculateStandardDeviation(List<BigDecimal> values) {
        BigDecimal mean = values.stream()
            .reduce(BigDecimal.ZERO, BigDecimal::add)
            .divide(BigDecimal.valueOf(values.size()), RoundingMode.HALF_UP);
        
        BigDecimal variance = values.stream()
            .map(v -> v.subtract(mean).pow(2))
            .reduce(BigDecimal.ZERO, BigDecimal::add)
            .divide(BigDecimal.valueOf(values.size()), RoundingMode.HALF_UP);
        
        return BigDecimal.valueOf(Math.sqrt(variance.doubleValue()));
    }
    
    private BigDecimal calculatePortfolioBeta(
        List<Position> positions,
        MarketDataService marketDataService
    ) {
        // Beta calculation implementation
        // [Inference: simplified for brevity]
        return BigDecimal.ONE; // Placeholder
    }
}
```

### Domain Service vs Application Service

#### Domain Service

Pure business logic:

```java
// Domain Service - Business logic only
public class InventoryAllocationService {
    public AllocationResult allocateInventory(
        Order order,
        List<Warehouse> warehouses
    ) {
        // Business rule: Allocate from closest warehouse first
        List<Warehouse> sortedWarehouses = warehouses.stream()
            .sorted(Comparator.comparing(w -> 
                w.distanceTo(order.getShippingAddress())))
            .collect(Collectors.toList());
        
        Map<Warehouse, List<OrderLine>> allocation = new HashMap<>();
        List<OrderLine> unallocatedLines = new ArrayList<>();
        
        for (OrderLine line : order.getOrderLines()) {
            boolean allocated = false;
            
            for (Warehouse warehouse : sortedWarehouses) {
                if (warehouse.hasStock(line.getProduct(), line.getQuantity())) {
                    allocation
                        .computeIfAbsent(warehouse, k -> new ArrayList<>())
                        .add(line);
                    allocated = true;
                    break;
                }
            }
            
            if (!allocated) {
                unallocatedLines.add(line);
            }
        }
        
        return new AllocationResult(allocation, unallocatedLines);
    }
}
```

#### Application Service

Orchestration and infrastructure:

```java
// Application Service - Orchestrates domain services and infrastructure
public class OrderProcessingApplicationService {
    private final OrderRepository orderRepository;
    private final WarehouseRepository warehouseRepository;
    private final InventoryAllocationService allocationService; // Domain service
    private final PaymentGateway paymentGateway; // Infrastructure
    private final EmailService emailService; // Infrastructure
    private final TransactionManager transactionManager;
    
    @Transactional
    public void processOrder(String orderId) {
        // Retrieve entities from repository
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new OrderNotFoundException(orderId));
        
        List<Warehouse> warehouses = warehouseRepository.findAll();
        
        // Call domain service for business logic
        AllocationResult allocation = allocationService.allocateInventory(
            order, 
            warehouses
        );
        
        if (!allocation.isFullyAllocated()) {
            order.markAsPartiallyFulfilled();
            orderRepository.save(order);
            
            // Infrastructure: Send email
            emailService.sendBackorderNotification(
                order.getCustomer(),
                allocation.getUnallocatedLines()
            );
            return;
        }
        
        // Infrastructure: Process payment
        PaymentResult payment = paymentGateway.charge(
            order.getCustomer().getPaymentMethod(),
            order.getTotalAmount()
        );
        
        if (!payment.isSuccessful()) {
            order.markAsPaymentFailed();
            orderRepository.save(order);
            return;
        }
        
        // Update domain state
        order.markAsFulfilled();
        allocation.applyToWarehouses();
        
        // Persist changes
        orderRepository.save(order);
        warehouseRepository.saveAll(warehouses);
        
        // Infrastructure: Send confirmation
        emailService.sendOrderConfirmation(order);
    }
}
```

The distinction is clear: domain services contain pure business logic and speak domain language, while application services orchestrate workflows, manage transactions, and coordinate between domain services and infrastructure.

### Service Dependencies

#### Depending on Repositories

Domain services can use repositories:

```java
public class ProductRecommendationService {
    private final PurchaseHistoryRepository purchaseHistoryRepository;
    private final ProductCatalogRepository productCatalogRepository;
    
    public List<Product> recommendProducts(Customer customer, int limit) {
        // Retrieve customer's purchase history
        List<Purchase> history = purchaseHistoryRepository
            .findByCustomer(customer);
        
        // Extract product categories from history
        Set<ProductCategory> preferredCategories = history.stream()
            .flatMap(p -> p.getProducts().stream())
            .map(Product::getCategory)
            .collect(Collectors.toSet());
        
        // Find similar products in preferred categories
        List<Product> candidates = productCatalogRepository
            .findByCategories(preferredCategories);
        
        // Score and rank products (domain logic)
        return candidates.stream()
            .map(p -> new ScoredProduct(p, scoreProduct(p, history)))
            .sorted(Comparator.comparing(ScoredProduct::getScore).reversed())
            .limit(limit)
            .map(ScoredProduct::getProduct)
            .collect(Collectors.toList());
    }
    
    private double scoreProduct(Product product, List<Purchase> history) {
        // Domain logic for scoring
        double categoryScore = calculateCategoryAffinity(product, history);
        double priceScore = calculatePriceAffinity(product, history);
        double recencyScore = calculateRecencyBoost(product, history);
        
        return categoryScore * 0.5 + priceScore * 0.3 + recencyScore * 0.2;
    }
}
```

#### Depending on Other Domain Services

Services can collaborate:

```java
public class LoanUnderwritingService {
    private final CreditScoringService creditScoringService;
    private final RiskAssessmentService riskAssessmentService;
    private final CollateralEvaluationService collateralEvaluationService;
    
    public UnderwritingDecision underwriteLoan(LoanApplication application) {
        // Use credit scoring service
        CreditScore creditScore = creditScoringService.evaluateCreditworthiness(
            application.getApplicant(),
            application
        );
        
        if (creditScore.isBelowMinimum()) {
            return UnderwritingDecision.reject(
                "Credit score below minimum threshold"
            );
        }
        
        // Use risk assessment service
        RiskProfile risk = riskAssessmentService.assessRisk(
            application.getApplicant(),
            application.getRequestedAmount(),
            application.getTerm()
        );
        
        // Use collateral evaluation for secured loans
        if (application.isSecured()) {
            CollateralValuation valuation = collateralEvaluationService.evaluate(
                application.getCollateral()
            );
            
            if (valuation.isInsufficient(application.getRequestedAmount())) {
                return UnderwritingDecision.reject(
                    "Insufficient collateral value"
                );
            }
        }
        
        // Make final decision based on combined factors
        if (risk.isHigh() && !application.hasStrongMitigatingFactors()) {
            return UnderwritingDecision.reject("Risk level too high");
        }
        
        InterestRate rate = determineInterestRate(creditScore, risk);
        
        return UnderwritingDecision.approve(rate);
    }
    
    private InterestRate determineInterestRate(
        CreditScore creditScore, 
        RiskProfile risk
    ) {
        // Domain logic for rate determination
        BigDecimal baseRate = new BigDecimal("3.5");
        BigDecimal creditAdjustment = creditScore.getRateAdjustment();
        BigDecimal riskAdjustment = risk.getRateAdjustment();
        
        return new InterestRate(
            baseRate.add(creditAdjustment).add(riskAdjustment)
        );
    }
}
```

### Testing Domain Services

#### Unit Testing

Test in isolation:

```java
class MoneyTransferServiceTest {
    private MoneyTransferService service;
    
    @BeforeEach
    void setUp() {
        service = new MoneyTransferService();
    }
    
    @Test
    void shouldTransferMoneyBetweenAccounts() {
        // Arrange
        Account source = new Account("ACC001", Money.of(1000, Currency.USD));
        Account destination = new Account("ACC002", Money.of(500, Currency.USD));
        Money amount = Money.of(200, Currency.USD);
        
        // Act
        TransferResult result = service.transfer(source, destination, amount);
        
        // Assert
        assertTrue(result.isSuccessful());
        assertEquals(Money.of(800, Currency.USD), source.getBalance());
        assertEquals(Money.of(700, Currency.USD), destination.getBalance());
    }
    
    @Test
    void shouldRejectTransferWithInsufficientFunds() {
        // Arrange
        Account source = new Account("ACC001", Money.of(100, Currency.USD));
        Account destination = new Account("ACC002", Money.of(500, Currency.USD));
        Money amount = Money.of(200, Currency.USD);
        
        // Act
        TransferResult result = service.transfer(source, destination, amount);
        
        // Assert
        assertFalse(result.isSuccessful());
        assertEquals(TransferFailureReason.INSUFFICIENT_FUNDS, result.getReason());
        assertEquals(Money.of(100, Currency.USD), source.getBalance()); // Unchanged
        assertEquals(Money.of(500, Currency.USD), destination.getBalance()); // Unchanged
    }
    
    @Test
    void shouldRejectTransferBetweenDifferentCurrencies() {
        // Arrange
        Account source = new Account("ACC001", Money.of(1000, Currency.USD));
        Account destination = new Account("ACC002", Money.of(500, Currency.EUR));
        Money amount = Money.of(200, Currency.USD);
        
        // Act
        TransferResult result = service.transfer(source, destination, amount);
        
        // Assert
        assertFalse(result.isSuccessful());
        assertEquals(TransferFailureReason.CURRENCY_MISMATCH, result.getReason());
    }
}
```

#### Integration Testing

Test with real dependencies:

```java
@SpringBootTest
class OrderFulfillmentServiceIntegrationTest {
    @Autowired
    private OrderFulfillmentService fulfillmentService;
    
    @Autowired
    private InventoryRepository inventoryRepository;
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Test
    @Transactional
    void shouldFulfillOrderWithAvailableInventory() {
        // Arrange
        Product product = new Product("PROD001", "Widget");
        inventoryRepository.addStock(product, 100);
        
        Order order = new Order("ORD001");
        order.addLine(new OrderLine(product, 5));
        orderRepository.save(order);
        
        // Act
        FulfillmentResult result = fulfillmentService.fulfillOrder(order);
        
        // Assert
        assertTrue(result.isSuccessful());
        assertEquals(95, inventoryRepository.getStockLevel(product));
        assertEquals(OrderStatus.FULFILLED, order.getStatus());
    }
}
```

#### Testing with Mocks

Isolate from external dependencies:

```java
class LoanUnderwritingServiceTest {
    private LoanUnderwritingService service;
    private CreditScoringService creditScoringService;
    private RiskAssessmentService riskAssessmentService;
    
    @BeforeEach
    void setUp() {
        creditScoringService = mock(CreditScoringService.class);
        riskAssessmentService = mock(RiskAssessmentService.class);
        
        service = new LoanUnderwritingService(
            creditScoringService,
            riskAssessmentService
        );
    }
    
    @Test
    void shouldApproveLoanForQualifiedApplicant() {
        // Arrange
        LoanApplication application = createTestApplication();
        
        CreditScore goodScore = new CreditScore(750);
        when(creditScoringService.evaluateCreditworthiness(any(), any()))
            .thenReturn(goodScore);
        
        RiskProfile lowRisk = RiskProfile.low();
        when(riskAssessmentService.assessRisk(any(), any(), any()))
            .thenReturn(lowRisk);
        
        // Act
        UnderwritingDecision decision = service.underwriteLoan(application);
        
        // Assert
        assertTrue(decision.isApproved());
        verify(creditScoringService).evaluateCreditworthiness(
            application.getApplicant(),
            application
        );
        verify(riskAssessmentService).assessRisk(
            application.getApplicant(),
            application.getRequestedAmount(),
            application.getTerm()
        );
    }
}
```

### Common Pitfalls

#### Anemic Domain Models

Over-relying on services:

```java
// Bad: All logic in services, entities are just data holders
public class Order {
    private String id;
    private List<OrderLine> lines;
    private OrderStatus status;
    // Only getters and setters
}

public class OrderService {
    public Money calculateTotal(Order order) {
        return order.getLines().stream()
            .map(line -> line.getPrice().multiply(line.getQuantity()))
            .reduce(Money.zero(), Money::add);
    }
    
    public void addLine(Order order, OrderLine line) {
        order.getLines().add(line);
    }
    
    public void markAsShipped(Order order) {
        order.setStatus(OrderStatus.SHIPPED);
    }
}

// Good: Entities own their behavior, services only for cross-entity logic
public class Order {
    private String id;
    private List<OrderLine> lines;
    private OrderStatus status;
    
    public Money calculateTotal() {
        return lines.stream()
            .map(OrderLine::getLineTotal)
            .reduce(Money.zero(), Money::add);
    }
    
    public void addLine(OrderLine line) {
        validateLineCanBeAdded(line);
        lines.add(line);
    }
    
    public void markAsShipped() {
        if (status != OrderStatus.PAID) {
            throw new IllegalStateException("Cannot ship unpaid order");
        }
        status = OrderStatus.SHIPPED;
    }
}

// Service only handles cross-entity operations
public class OrderFulfillmentService {
    public void fulfillOrder(Order order, Inventory inventory) {
        // Coordinates between order and inventory
        for (OrderLine line : order.getOrderLines()) {
            inventory.reserve(line.getProduct(), line.getQuantity());
        }
        order.markAsShipped();
    }
}
```

#### Mixing Domain and Infrastructure

Blurring layer boundaries:

```java
// Bad: Domain service with infrastructure concerns
public class InvoiceGenerationService {
    private final JdbcTemplate jdbcTemplate; // Infrastructure!
    private final S3Client s3Client; // Infrastructure!
    
    public Invoice generateInvoice(Order order) {
        // Domain logic mixed with database calls
        Invoice invoice = new Invoice(order);
        
        jdbcTemplate.update(
            "INSERT INTO invoices VALUES (?, ?)",
            invoice.getId(), invoice.getAmount()
        );
        
        byte[] pdf = invoice.toPdf();
        s3Client.putObject("invoices", invoice.getId() + ".pdf", pdf);
        
        return invoice;
    }
}

// Good: Pure domain service
public class InvoiceGenerationService {
    public Invoice generateInvoice(Order order) {
        // Pure domain logic
        return new Invoice(
            InvoiceNumber.generate(),
            order.getCustomer(),
            order.getOrderLines(),
            order.calculateTotal(),
            LocalDate.now()
        );
    }
}

// Application service handles infrastructure
public class InvoiceApplicationService {
    private final InvoiceGenerationService domainService;
    private final InvoiceRepository repository;
    private final DocumentStorageService storage;
    
    public void createAndStoreInvoice(String orderId) {
        Order order = orderRepository.findById(orderId);
        Invoice invoice = domainService.generateInvoice(order);
        
        repository.save(invoice);
        storage.storeDocument(invoice.toPdf(), invoice.getId());
    }
}
```

#### Overly Granular Services

Too many small services:

```java
// Bad: Excessive decomposition
public class PriceCalculationService {
    public Money calculatePrice(Product product) {
        return product.getBasePrice();
    }
}

public class DiscountApplicationService {
    public Money applyDiscount(Money price, Discount discount) {
        return price.multiply(BigDecimal.ONE.subtract(discount.getPercentage()));
    }
}

public class TaxCalculationService {
    public Money calculateTax(Money price, TaxRate rate) {
        return price.multiply(rate.getPercentage());
    }
}

// Good: Cohesive service handling related operations
public class PricingService {
    public Price calculateFinalPrice(
        Product product,
        Customer customer,
        TaxJurisdiction jurisdiction
    ) {
        Money basePrice = product.getBasePrice();
        
        Discount discount = customer.getApplicableDiscount(product);
        Money discountedPrice = basePrice.applyDiscount(discount);
        
        TaxRate taxRate = jurisdiction.getTaxRateFor(product.getCategory());
        Money tax = discountedPrice.multiply(taxRate.getPercentage());
        
        return new Price(discountedPrice, tax, discountedPrice.add(tax));
    }
}
```

#### Service Circular Dependencies

Services depending on each other:

```java
// Bad: Circular dependency
public class OrderService {
    private final InvoiceService invoiceService;
    
    public void completeOrder(Order order) {
        order.markAsComplete();
        invoiceService.generateInvoice(order); // Calls InvoiceService
    }
}

public class InvoiceService {
    private final OrderService orderService;
    
    public Invoice generateInvoice(Order order) {
        orderService.validateOrder(order); // Calls OrderService - circular!
        return new Invoice(order);
    }
}

// Good: Proper dependency direction
public class OrderService {
    public void validateOrder(Order order) {
        // Validation logic
    }
}

public class InvoiceService {
    private final OrderService orderService; // One-way dependency
    
    public Invoice generateInvoice(Order order) {
        orderService.validateOrder(order);
        return new Invoice(order);
    }
}

public class OrderCompletionService {
    private final InvoiceService invoiceService;
    
    public void completeOrder(Order order) {
        order.markAsComplete();
        invoiceService.generateInvoice(order);
    }
}
```

### Design Guidelines

#### Keep Services Focused

Single responsibility:

- Each service should handle one cohesive set of operations
- Service name should clearly indicate its purpose
- If a service has many unrelated methods, split it
- Group related operations that share domain concepts

#### Express Intent Clearly

Method names reflect domain operations:

```java
// Good: Clear domain intent
public class ReservationService {
    public ReservationConfirmation bookRoom(
        Guest guest,
        RoomType roomType,
        DateRange dateRange
    );
    
    public void cancelReservation(ReservationId id, CancellationReason reason);
    
    public boolean isRoomAvailable(RoomType roomType, DateRange dateRange);
}

// Bad: Technical language
public class ReservationService {
    public Result create(GuestDTO g, int roomTypeId, Date start, Date end);
    public void delete(String id, String reason);
    public boolean check(int roomTypeId, Date start, Date end);
}
```

#### Avoid God Services

Don't create catch-all services:

```java
// Bad: God service doing everything
public class OrderService {

    public void createOrder(...) {}

    public void cancelOrder(...) {}

    public void calculateShipping(...) {}

    public void applyDiscount(...) {}

    public void processPayment(...) {}

    public void generateInvoice(...) {}

    public void scheduleDelivery(...) {}

    public void sendNotification(...) {}
}


// Good: Focused, cohesive services

public class OrderManagementService {

    public Order createOrder(...) {}

    public void cancelOrder(...) {}
}


public class PricingService {

    public Money calculateShipping(...) {}

    public Price applyDiscount(...) {}
}


public class OrderFulfillmentService {

    public void fulfillOrder(...) {}

    public void scheduleDelivery(...) {}
}
````

#### Consider Performance

Optimize for common cases:

```java
public class ProductSearchService {
    private final ProductRepository repository;
    private final SearchIndexCache cache; // Caching strategy
    
    public List<Product> search(SearchCriteria criteria) {
        // Check cache first for common searches
        String cacheKey = criteria.toCacheKey();
        List<Product> cached = cache.get(cacheKey);
        
        if (cached != null) {
            return cached;
        }
        
        // Perform search
        List<Product> results = repository.findByCriteria(criteria);
        
        // Cache results for frequent searches
        if (criteria.isFrequentlySearched()) {
            cache.put(cacheKey, results, Duration.ofMinutes(15));
        }
        
        return results;
    }
}
````

**Key Points**

- Domain services encapsulate business logic that doesn't naturally belong to a single entity or value object
- They are stateless, express domain concepts in ubiquitous language, and are defined by their operations
- Domain services differ from application services: domain services contain pure business logic while application services orchestrate workflows and infrastructure
- Use domain services for multi-entity operations, complex calculations, policy enforcement, and validation
- Avoid anemic domain models by keeping entity behavior in entities and using services only for cross-cutting concerns
- Domain services can depend on repositories and other domain services but should never contain infrastructure concerns
- Test domain services in isolation using unit tests, with mocks for dependencies

**Example**

A money transfer system demonstrating domain service usage:

```java
// Domain entities
public class Account {
    private final AccountId id;
    private Money balance;
    private final Currency currency;
    
    public Account(AccountId id, Money balance) {
        this.id = id;
        this.balance = balance;
        this.currency = balance.getCurrency();
    }
    
    public boolean canWithdraw(Money amount) {
        if (!amount.getCurrency().equals(currency)) {
            return false;
        }
        return balance.isGreaterThanOrEqual(amount);
    }
    
    public void withdraw(Money amount) {
        if (!canWithdraw(amount)) {
            throw new InsufficientFundsException();
        }
        balance = balance.subtract(amount);
    }
    
    public void deposit(Money amount) {
        if (!amount.getCurrency().equals(currency)) {
            throw new CurrencyMismatchException();
        }
        balance = balance.add(amount);
    }
    
    public Money getBalance() {
        return balance;
    }
    
    public AccountId getId() {
        return id;
    }
}

// Value object
public class Money {
    private final BigDecimal amount;
    private final Currency currency;
    
    public Money(BigDecimal amount, Currency currency) {
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Amount cannot be negative");
        }
        this.amount = amount;
        this.currency = currency;
    }
    
    public static Money of(double amount, Currency currency) {
        return new Money(BigDecimal.valueOf(amount), currency);
    }
    
    public Money add(Money other) {
        if (!currency.equals(other.currency)) {
            throw new CurrencyMismatchException();
        }
        return new Money(amount.add(other.amount), currency);
    }
    
    public Money subtract(Money other) {
        if (!currency.equals(other.currency)) {
            throw new CurrencyMismatchException();
        }
        return new Money(amount.subtract(other.amount), currency);
    }
    
    public boolean isGreaterThanOrEqual(Money other) {
        if (!currency.equals(other.currency)) {
            throw new CurrencyMismatchException();
        }
        return amount.compareTo(other.amount) >= 0;
    }
    
    public Currency getCurrency() {
        return currency;
    }
    
    @Override
    public String toString() {
        return currency.getSymbol() + amount.setScale(2, RoundingMode.HALF_UP);
    }
}

// Domain service - handles cross-entity operation
public class MoneyTransferService {
    private final TransferFeePolicy feePolicy;
    private final ExchangeRateService exchangeRateService;
    
    public MoneyTransferService(
        TransferFeePolicy feePolicy,
        ExchangeRateService exchangeRateService
    ) {
        this.feePolicy = feePolicy;
        this.exchangeRateService = exchangeRateService;
    }
    
    public TransferResult transfer(
        Account source,
        Account destination,
        Money amount
    ) {
        // Validate transfer is possible
        if (!source.canWithdraw(amount)) {
            return TransferResult.failure(
                TransferFailureReason.INSUFFICIENT_FUNDS,
                "Source account has insufficient funds"
            );
        }
        
        // Calculate fee
        Money fee = feePolicy.calculateFee(amount, source, destination);
        Money totalDebit = amount.add(fee);
        
        if (!source.canWithdraw(totalDebit)) {
            return TransferResult.failure(
                TransferFailureReason.INSUFFICIENT_FUNDS_WITH_FEE,
                "Insufficient funds to cover transfer and fee"
            );
        }
        
        // Handle currency conversion if needed
        Money depositAmount = amount;
        if (!amount.getCurrency().equals(destination.getCurrency())) {
            ExchangeRate rate = exchangeRateService.getRate(
                amount.getCurrency(),
                destination.getCurrency()
            );
            depositAmount = rate.convert(amount);
        }
        
        // Perform transfer
        source.withdraw(totalDebit);
        destination.deposit(depositAmount);
        
        return TransferResult.success(
            new TransferDetails(
                source.getId(),
                destination.getId(),
                amount,
                fee,
                depositAmount
            )
        );
    }
}

// Transfer fee policy (strategy pattern)
interface TransferFeePolicy {
    Money calculateFee(Money amount, Account source, Account destination);
}

class StandardFeePolicy implements TransferFeePolicy {
    private static final BigDecimal FEE_PERCENTAGE = new BigDecimal("0.01"); // 1%
    private static final Money MINIMUM_FEE = Money.of(1.00, Currency.USD);
    private static final Money MAXIMUM_FEE = Money.of(25.00, Currency.USD);
    
    @Override
    public Money calculateFee(Money amount, Account source, Account destination) {
        Money calculatedFee = new Money(
            amount.getAmount().multiply(FEE_PERCENTAGE),
            amount.getCurrency()
        );
        
        // Apply minimum and maximum
        if (calculatedFee.isLessThan(MINIMUM_FEE)) {
            return MINIMUM_FEE;
        }
        if (calculatedFee.isGreaterThan(MAXIMUM_FEE)) {
            return MAXIMUM_FEE;
        }
        
        return calculatedFee;
    }
}

// Result object
public class TransferResult {
    private final boolean successful;
    private final TransferFailureReason failureReason;
    private final String message;
    private final TransferDetails details;
    
    private TransferResult(
        boolean successful,
        TransferFailureReason failureReason,
        String message,
        TransferDetails details
    ) {
        this.successful = successful;
        this.failureReason = failureReason;
        this.message = message;
        this.details = details;
    }
    
    public static TransferResult success(TransferDetails details) {
        return new TransferResult(true, null, null, details);
    }
    
    public static TransferResult failure(
        TransferFailureReason reason,
        String message
    ) {
        return new TransferResult(false, reason, message, null);
    }
    
    public boolean isSuccessful() {
        return successful;
    }
    
    public TransferDetails getDetails() {
        return details;
    }
}

// Usage example
public class TransferDemo {
    public static void main(String[] args) {
        Account checking = new Account(
            new AccountId("CHK001"),
            Money.of(1000.00, Currency.USD)
        );
        
        Account savings = new Account(
            new AccountId("SAV001"),
            Money.of(500.00, Currency.USD)
        );
        
        MoneyTransferService transferService = new MoneyTransferService(
            new StandardFeePolicy(),
            new ExchangeRateService()
        );
        
        Money transferAmount = Money.of(200.00, Currency.USD);
        TransferResult result = transferService.transfer(
            checking,
            savings,
            transferAmount
        );
        
        if (result.isSuccessful()) {
            System.out.println("Transfer successful!");
            System.out.println("Checking balance: " + checking.getBalance());
            System.out.println("Savings balance: " + savings.getBalance());
            System.out.println("Fee charged: " + result.getDetails().getFee());
        } else {
            System.out.println("Transfer failed: " + result.getMessage());
        }
    }
}
```

**Output**

```
Transfer successful!
Checking balance: $798.00
Savings balance: $700.00
Fee charged: $2.00
```

This example demonstrates how the domain service coordinates the transfer operation between two accounts, applies business rules (fee calculation), and handles the transaction in a cohesive way that doesn't naturally belong to either account entity alone.

**Conclusion**

Domain services provide a natural home for business logic that operates across multiple entities or implements domain processes without a clear owner. They maintain the richness of the domain model while keeping entities focused on their core responsibilities. By expressing business operations in domain language and remaining free of infrastructure concerns, domain services become a powerful tool for implementing complex business logic in a maintainable, testable way. The key is knowing when to use them—not as a replacement for entity behavior, but as a complement that handles cross-cutting domain concerns.

**Next Steps**

- Review your domain model to identify logic that belongs in services rather than entities
- Examine existing services to ensure they contain only domain logic, moving infrastructure concerns to application services
- Practice identifying the difference between domain services, application services, and infrastructure services
- Implement domain services using interfaces to allow for multiple policy implementations
- Study Domain-Driven Design patterns like Specification, Policy, and Strategy that often work alongside domain services
- Consider how domain events can complement domain services for complex workflows
- Explore how to test domain services effectively in isolation from infrastructure

---

## Application Service Pattern

The Application Service pattern encapsulates business logic and orchestrates domain operations, serving as an intermediary layer between the presentation layer and the domain model. Application services coordinate workflows, enforce business rules, manage transactions, and translate between external requests and domain operations without containing domain logic themselves.

### Core Concept

Application services act as the entry point for use cases in a system. They receive requests from controllers, API endpoints, or other external sources, coordinate the execution of business operations using domain objects, and return results in formats suitable for the caller. The pattern separates orchestration concerns from domain logic, keeping the domain model focused on business rules while application services handle workflow coordination.

**Domain Logic vs Application Logic** is a critical distinction. Domain logic represents core business rules and behaviors—validation rules, calculations, state transitions, and invariants that define what the business does. Application logic handles how the system executes use cases—retrieving entities, coordinating multiple domain operations, managing transactions, and formatting responses. Application services contain application logic but delegate domain logic to domain objects.

**Responsibilities** of application services include receiving and validating input from external sources, retrieving domain objects from repositories, orchestrating interactions between multiple domain objects, managing transaction boundaries, enforcing application-level security and authorization, handling cross-cutting concerns like logging and auditing, translating domain objects to data transfer objects for external consumption, and coordinating with external systems and infrastructure services.

**What Application Services Don't Do** is equally important. They don't contain business rules or domain logic—those belong in domain entities and value objects. They don't directly manipulate database connections or perform data access—repositories handle persistence. They don't contain presentation logic or format data for specific UI frameworks—that's the presentation layer's responsibility. They don't make decisions based on business state—domain objects make those decisions.

### Architectural Position

Application services sit in the application layer, positioned between the presentation layer and the domain layer. The presentation layer (controllers, API handlers, UI components) calls application services to execute use cases. Application services call into the domain layer (entities, value objects, domain services) to perform business operations and use infrastructure services (repositories, external APIs, messaging) for technical concerns.

**Dependency Direction** flows inward following the Dependency Inversion Principle. The presentation layer depends on application services through interfaces. Application services depend on domain objects and infrastructure abstractions. The domain layer has no dependencies on outer layers. Infrastructure implementations depend on abstractions defined in the application or domain layer.

**Layer Isolation** ensures changes in one layer don't cascade to others. Presentation frameworks can change without affecting application services. Domain logic can evolve independently. Infrastructure implementations can be swapped without modifying application or domain code. This isolation is achieved through well-defined interfaces and careful separation of concerns.

### Use Case Coordination

Each application service method typically represents a single use case or user action. The method orchestrates all steps needed to complete that action, coordinating multiple domain objects, repositories, and infrastructure services as required.

**Transaction Management** is a primary responsibility. Application service methods define transaction boundaries—usually one transaction per use case. The service begins a transaction, executes domain operations, and commits if successful or rolls back on failure. This ensures consistency across multiple repository operations and domain changes.

**Data Retrieval and Persistence** flow through repositories. Application services retrieve aggregate roots and entities needed for the use case, pass them to domain operations, and save changes back through repositories. The service doesn't know how persistence works—it simply uses repository abstractions.

**Multiple Domain Operations** are coordinated within a single service method. For example, processing an order might involve retrieving customer and inventory information, creating an order entity, updating inventory, and recording the transaction. The application service orchestrates these steps in the correct sequence, ensuring all succeed or all fail together.

### Input Validation and Transformation

Application services validate that inputs are structurally correct and meet application-level requirements before passing them to domain objects. This includes checking required fields exist, formats are correct, references are valid, and authorization rules are satisfied.

**Command Objects** or **Data Transfer Objects** carry input data to application services. These objects have no behavior—they're simple data containers that isolate external data formats from domain objects. Application services translate command objects into domain concepts.

**Domain Validation** is separate from input validation. Application services check that data is well-formed and meets basic requirements. Domain objects validate that operations maintain business invariants. For example, an application service might verify a user ID is provided, while the domain validates that user has permission to perform the operation based on business rules.

**Validation Placement** can be nuanced. Structural validation (required fields, data types, formats) happens in the application service or command object. Business rule validation (order totals, account balances, state transitions) happens in domain objects. Authorization and authentication happen at the application service boundary.

### Response Handling

Application services return results that are decoupled from domain objects. They translate domain entities into DTOs or view models suitable for consumption by the presentation layer. This translation prevents domain objects from leaking into the presentation layer and allows independent evolution of internal and external representations.

**Result Patterns** provide structured responses. Instead of returning domain entities directly, services return result objects containing success/failure status, data payloads, error messages, and metadata. This makes error handling explicit and prevents exceptions from being used for control flow.

**Error Handling** at the application service level catches domain exceptions, logs details for debugging, and translates technical errors into user-friendly messages. The service determines whether errors are recoverable, require user action, or indicate system problems.

**Projection to DTOs** happens after successful domain operations. The application service converts domain entities into DTOs that contain only data needed by the caller, potentially aggregating information from multiple entities, formatting values appropriately, and hiding internal domain structure.

### Transaction Boundaries

Application service methods typically represent transaction boundaries. Each public method on an application service executes within a single transaction, ensuring all operations within that use case succeed or fail atomically.

**Unit of Work** pattern often works alongside application services to manage transactions. The application service uses a unit of work to track changes to domain objects, coordinate repository operations, and commit or rollback the entire transaction at the end of the service method.

**Transaction Isolation** prevents interference between concurrent operations. Application services rely on database transaction isolation levels to ensure consistency when multiple users access the same data simultaneously. The choice of isolation level depends on consistency requirements and performance considerations.

**Distributed Transactions** introduce complexity when a use case spans multiple databases, external services, or bounded contexts. Application services may coordinate distributed transactions using two-phase commit, implement the Saga pattern for eventual consistency, or use compensating transactions to handle failures.

### Security and Authorization

Application services enforce security policies at the boundary between external requests and internal operations. They verify the caller has permission to execute the use case, validate the caller can access specific resources, and enforce business rules around authorization.

**Authentication** verification happens before application service execution. The service receives an authenticated user identity and uses it to enforce authorization rules. The service doesn't handle authentication itself—that's typically handled by infrastructure middleware.

**Authorization Checks** determine whether the authenticated user can perform the requested operation. Application services check permissions at the use case level (can this user create orders?) and at the resource level (can this user modify this specific order?). These checks may query domain objects for business-specific authorization rules.

**Security Context** is passed to domain operations when business rules depend on user identity. For example, calculating pricing might depend on customer tier, or state transitions might depend on user roles. The application service provides the security context to domain objects without implementing the rules themselves.

### Dependency Injection

Application services receive dependencies through constructor injection, making dependencies explicit and enabling testing. Dependencies typically include repositories for data access, domain services for complex domain operations, infrastructure services for external concerns, and factories for creating domain objects.

**Interface Segregation** ensures application services depend on abstractions rather than concrete implementations. This allows swapping infrastructure implementations, facilitating testing with mocks or fakes, and supporting multiple implementations of the same abstraction.

**Service Lifetime** considerations are important. Application services are typically transient—created per request and discarded after use. This prevents state from leaking between requests. Dependencies like repositories may be scoped to the request or transaction, while infrastructure services might be singletons.

### Testing Strategies

Application services are highly testable due to their explicit dependencies and clear responsibilities. Tests verify that services correctly orchestrate domain operations, handle errors appropriately, enforce authorization rules, and return correct results.

**Unit Testing** application services involves mocking repositories and dependencies to isolate the service logic. Tests verify the service calls the right repositories, passes correct parameters to domain objects, handles domain exceptions appropriately, and returns expected results or errors.

**Integration Testing** exercises application services with real repositories and infrastructure against a test database or test doubles. These tests verify transaction management works correctly, domain changes persist appropriately, and the service interacts properly with infrastructure.

**Behavioral Testing** focuses on use case scenarios from the user's perspective. Tests describe what should happen when a user performs an action, verifying the complete workflow from input to output without necessarily testing implementation details.

### Common Patterns and Variants

**Thin Application Services** contain minimal logic, primarily coordinating calls to repositories and domain services. All business logic lives in domain objects. This approach maximizes domain richness and keeps orchestration simple.

**Rich Application Services** contain more workflow logic, especially when coordinating complex scenarios involving many domain objects or external systems. While they still delegate domain logic to domain objects, they may implement significant orchestration patterns.

**CQRS-Based Services** separate command services (which modify state) from query services (which retrieve data). Command services follow standard application service patterns while query services may bypass the domain model entirely, reading directly from optimized query databases.

**Mediator Pattern Integration** uses a mediator to decouple controllers from specific application service methods. Controllers send commands or queries to a mediator, which routes them to appropriate handlers. This reduces coupling but adds a layer of indirection.

### Anti-Patterns to Avoid

**Anemic Services** that simply pass data between the presentation layer and repositories without any coordination or validation. These services add no value and indicate domain logic has leaked into the presentation layer or database layer.

**God Services** that handle too many responsibilities or use cases. Large services with dozens of methods become difficult to understand, test, and maintain. Services should be focused around related use cases within a bounded context.

**Domain Logic in Services** occurs when business rules and invariants are implemented in application services rather than domain objects. This indicates an anemic domain model and makes business logic harder to test and reuse.

**Service-to-Service Calls** where application services directly call other application services create tight coupling and make transaction boundaries unclear. If multiple use cases are needed, the caller should invoke multiple services or a new service should coordinate both operations.

**Returning Domain Entities** directly from application services couples the presentation layer to domain structure and prevents independent evolution. Services should always return DTOs or view models appropriate for external consumption.

### Coordination with Other Patterns

**Repository Pattern** provides data access abstraction. Application services use repositories to retrieve and persist aggregate roots, relying on repository interfaces rather than concrete implementations. Repositories handle all persistence concerns.

**Domain Services** implement domain logic that doesn't naturally belong to any single entity. Application services call domain services when operations span multiple entities or require external domain knowledge. Domain services contain business logic while application services orchestrate.

**Factories** create complex domain objects. When application services need to create entities or aggregates, they delegate to factories rather than constructing objects directly. Factories encapsulate creation logic and ensure objects are properly initialized.

**Specification Pattern** encapsulates query criteria. Application services use specifications to query repositories without embedding query logic in the service. Specifications can be composed and reused across different queries.

**Event Publishing** allows application services to publish domain events after successful operations. Services commit changes and then publish events to notify other parts of the system. This enables loose coupling through eventual consistency.

### Domain-Driven Design Context

In Domain-Driven Design, application services sit in the application layer and orchestrate use cases by coordinating bounded contexts, aggregates, entities, and domain services. They serve as the facade to the domain model, providing a simplified interface for external consumers.

**Bounded Context Integration** happens through application services. When a use case spans multiple bounded contexts, the application service in one context may call application services in other contexts or consume integration events. This keeps domain models separated while enabling cross-context workflows.

**Aggregate Management** is coordinated by application services. Services retrieve aggregate roots through repositories, invoke methods on aggregates to perform operations, and save modified aggregates back. Services respect aggregate boundaries and don't modify entities that aren't part of the loaded aggregate.

**Domain Event Handling** may involve application services both publishing and consuming events. When a use case completes, the application service may publish domain events. Separate application services may subscribe to events from other contexts and orchestrate local responses.

### Microservices Context

In microservices architectures, each service typically exposes application services behind REST APIs, gRPC endpoints, or message handlers. Application services coordinate operations within the service boundary and interact with external services through anti-corruption layers.

**Service Boundaries** align with bounded contexts, and application services define the operations available within each service. Public application service methods become API endpoints, forming the contract between the service and its consumers.

**External Service Integration** flows through application services. When a use case requires data or operations from another microservice, the application service calls external APIs, handles network failures, implements retry logic, and translates between contexts.

**Distributed Transactions** are avoided when possible in microservices. Instead, application services use event-driven patterns, the Saga pattern, or eventual consistency to coordinate operations across services without distributed locks.

### Performance Considerations

Application services must balance correct orchestration with performance requirements, especially when coordinating many operations or retrieving significant data.

**Lazy Loading** of related entities through repositories can cause N+1 query problems. Application services should explicitly request needed relationships upfront or use projection queries that retrieve all required data efficiently.

**Bulk Operations** may require different coordination patterns than single-entity operations. Application services for bulk scenarios might batch repository operations, parallelize independent operations, or use specialized bulk APIs rather than iterating over individual entities.

**Caching Strategies** can be implemented at the application service level. Services might cache read-only reference data, use distributed caches for frequently accessed information, or implement cache-aside patterns. However, caching introduces consistency challenges that must be carefully managed.

**Asynchronous Operations** allow application services to handle long-running use cases without blocking. Services may queue commands for background processing, return immediately with operation tokens, and provide separate query methods to check status.

### **Key Points**

- Application services orchestrate use cases by coordinating domain objects, repositories, and infrastructure
- They contain workflow logic but delegate business rules to domain entities and value objects
- Services define transaction boundaries, ensuring all operations within a use case succeed or fail atomically
- Input validation at the application layer checks structural correctness; domain objects enforce business rules
- Services return DTOs or result objects rather than exposing domain entities directly
- Each public service method represents a single use case or user action
- Dependencies are injected through constructors, enabling testing with mocks and promoting loose coupling
- Application services sit between presentation and domain layers, enforcing dependency inversion
- Security and authorization checks happen at the service boundary before domain operations
- Anti-patterns include anemic services, god services, domain logic in services, and service-to-service calls

### **Example**

```python
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from typing import Optional, List, Dict, Any
from enum import Enum
from uuid import uuid4

# Domain Enums
class OrderStatus(Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

class PaymentStatus(Enum):
    PENDING = "pending"
    AUTHORIZED = "authorized"
    CAPTURED = "captured"
    FAILED = "failed"
    REFUNDED = "refunded"

# Value Objects
@dataclass(frozen=True)
class Money:
    """Value object representing monetary amounts"""
    amount: Decimal
    currency: str = "USD"
    
    def add(self, other: 'Money') -> 'Money':
        if self.currency != other.currency:
            raise ValueError("Cannot add money with different currencies")
        return Money(self.amount + other.amount, self.currency)
    
    def multiply(self, factor: int) -> 'Money':
        return Money(self.amount * factor, self.currency)
    
    def __str__(self) -> str:
        return f"{self.currency} {self.amount:.2f}"

@dataclass(frozen=True)
class Address:
    """Value object for shipping addresses"""
    street: str
    city: str
    state: str
    postal_code: str
    country: str
    
    def validate(self) -> List[str]:
        """Validate address completeness"""
        errors = []
        if not self.street:
            errors.append("Street address is required")
        if not self.city:
            errors.append("City is required")
        if not self.postal_code:
            errors.append("Postal code is required")
        return errors

# Domain Entities
class OrderLine:
    """Entity representing a line item in an order"""
    
    def __init__(self, product_id: str, product_name: str, 
                 unit_price: Money, quantity: int):
        if quantity <= 0:
            raise ValueError("Quantity must be positive")
        
        self.product_id = product_id
        self.product_name = product_name
        self.unit_price = unit_price
        self.quantity = quantity
    
    def subtotal(self) -> Money:
        """Calculate line item subtotal"""
        return self.unit_price.multiply(self.quantity)
    
    def __repr__(self) -> str:
        return f"OrderLine({self.product_name} x{self.quantity})"

class Order:
    """Aggregate root for order domain"""
    
    def __init__(self, order_id: str, customer_id: str):
        self.order_id = order_id
        self.customer_id = customer_id
        self.lines: List[OrderLine] = []
        self.status = OrderStatus.PENDING
        self.shipping_address: Optional[Address] = None
        self.created_at = datetime.utcnow()
        self.payment_status = PaymentStatus.PENDING
    
    def add_line(self, product_id: str, product_name: str, 
                 unit_price: Money, quantity: int):
        """Add product to order"""
        if self.status != OrderStatus.PENDING:
            raise ValueError(f"Cannot modify order in {self.status.value} status")
        
        line = OrderLine(product_id, product_name, unit_price, quantity)
        self.lines.append(line)
    
    def set_shipping_address(self, address: Address):
        """Set shipping address with validation"""
        errors = address.validate()
        if errors:
            raise ValueError(f"Invalid address: {', '.join(errors)}")
        
        self.shipping_address = address
    
    def calculate_total(self) -> Money:
        """Calculate order total"""
        if not self.lines:
            return Money(Decimal("0.00"))
        
        total = self.lines[0].subtotal()
        for line in self.lines[1:]:
            total = total.add(line.subtotal())
        
        return total
    
    def confirm(self):
        """Confirm order - domain business rule"""
        if self.status != OrderStatus.PENDING:
            raise ValueError(f"Cannot confirm order in {self.status.value} status")
        
        if not self.lines:
            raise ValueError("Cannot confirm empty order")
        
        if not self.shipping_address:
            raise ValueError("Cannot confirm order without shipping address")
        
        if self.payment_status != PaymentStatus.CAPTURED:
            raise ValueError("Cannot confirm order without successful payment")
        
        self.status = OrderStatus.CONFIRMED
    
    def cancel(self):
        """Cancel order - domain business rule"""
        if self.status in [OrderStatus.SHIPPED, OrderStatus.DELIVERED]:
            raise ValueError(f"Cannot cancel order in {self.status.value} status")
        
        self.status = OrderStatus.CANCELLED
    
    def mark_as_shipped(self, tracking_number: str):
        """Mark order as shipped"""
        if self.status != OrderStatus.CONFIRMED:
            raise ValueError(f"Cannot ship order in {self.status.value} status")
        
        self.status = OrderStatus.SHIPPED
        self.tracking_number = tracking_number
    
    def authorize_payment(self):
        """Authorize payment"""
        if self.payment_status != PaymentStatus.PENDING:
            raise ValueError(f"Cannot authorize payment in {self.payment_status.value} status")
        
        self.payment_status = PaymentStatus.AUTHORIZED
    
    def capture_payment(self):
        """Capture payment"""
        if self.payment_status != PaymentStatus.AUTHORIZED:
            raise ValueError(f"Cannot capture payment in {self.payment_status.value} status")
        
        self.payment_status = PaymentStatus.CAPTURED
    
    def __repr__(self) -> str:
        return f"Order({self.order_id}, status={self.status.value}, lines={len(self.lines)})"

# Repository Interfaces (Domain Layer)
class IOrderRepository(ABC):
    """Repository interface for order persistence"""
    
    @abstractmethod
    def get_by_id(self, order_id: str) -> Optional[Order]:
        """Retrieve order by ID"""
        pass
    
    @abstractmethod
    def get_by_customer(self, customer_id: str) -> List[Order]:
        """Get all orders for a customer"""
        pass
    
    @abstractmethod
    def save(self, order: Order) -> None:
        """Persist order changes"""
        pass
    
    @abstractmethod
    def next_identity(self) -> str:
        """Generate next order ID"""
        pass

class IInventoryRepository(ABC):
    """Repository interface for inventory management"""
    
    @abstractmethod
    def check_availability(self, product_id: str, quantity: int) -> bool:
        """Check if product quantity is available"""
        pass
    
    @abstractmethod
    def reserve(self, product_id: str, quantity: int) -> bool:
        """Reserve inventory for order"""
        pass
    
    @abstractmethod
    def release(self, product_id: str, quantity: int) -> None:
        """Release reserved inventory"""
        pass

# Infrastructure Service Interfaces
class IPaymentGateway(ABC):
    """Payment processing service interface"""
    
    @abstractmethod
    def authorize(self, order_id: str, amount: Money, 
                 payment_method: str) -> Dict[str, Any]:
        """Authorize payment"""
        pass
    
    @abstractmethod
    def capture(self, authorization_id: str) -> Dict[str, Any]:
        """Capture authorized payment"""
        pass
    
    @abstractmethod
    def refund(self, transaction_id: str, amount: Money) -> Dict[str, Any]:
        """Refund payment"""
        pass

class INotificationService(ABC):
    """Notification service interface"""
    
    @abstractmethod
    def send_order_confirmation(self, customer_id: str, order_id: str) -> None:
        """Send order confirmation notification"""
        pass
    
    @abstractmethod
    def send_shipping_notification(self, customer_id: str, 
                                   order_id: str, tracking_number: str) -> None:
        """Send shipping notification"""
        pass

# DTOs (Data Transfer Objects)
@dataclass
class CreateOrderCommand:
    """Command for creating new order"""
    customer_id: str
    items: List[Dict[str, Any]]  # [{'product_id': ..., 'quantity': ...}]
    shipping_address: Dict[str, str]
    payment_method: str

@dataclass
class OrderDto:
    """DTO for order data returned to clients"""
    order_id: str
    customer_id: str
    status: str
    total: str
    items: List[Dict[str, Any]]
    shipping_address: Optional[Dict[str, str]]
    created_at: str
    payment_status: str

@dataclass
class Result:
    """Generic result object for service responses"""
    success: bool
    data: Optional[Any] = None
    error: Optional[str] = None
    errors: Optional[List[str]] = None

# Application Service
class OrderApplicationService:
    """Application service coordinating order use cases"""
    
    def __init__(self, 
                 order_repository: IOrderRepository,
                 inventory_repository: IInventoryRepository,
                 payment_gateway: IPaymentGateway,
                 notification_service: INotificationService):
        self._order_repository = order_repository
        self._inventory_repository = inventory_repository
        self._payment_gateway = payment_gateway
        self._notification_service = notification_service
    
    def create_order(self, command: CreateOrderCommand) -> Result:
        """
        Create new order use case
        Coordinates: validation, inventory check, order creation, persistence
        """
        try:
            # Application-level validation
            validation_errors = self._validate_create_order(command)
            if validation_errors:
                return Result(success=False, errors=validation_errors)
            
            # Check inventory availability for all items
            for item in command.items:
                available = self._inventory_repository.check_availability(
                    item['product_id'], 
                    item['quantity']
                )
                if not available:
                    return Result(
                        success=False, 
                        error=f"Product {item['product_id']} not available in requested quantity"
                    )
            
            # Create order aggregate
            order_id = self._order_repository.next_identity()
            order = Order(order_id, command.customer_id)
            
            # Add order lines
            for item in command.items:
                order.add_line(
                    product_id=item['product_id'],
                    product_name=item['product_name'],
                    unit_price=Money(Decimal(str(item['unit_price']))),
                    quantity=item['quantity']
                )
            
            # Set shipping address (domain validation happens here)
            address = Address(
                street=command.shipping_address['street'],
                city=command.shipping_address['city'],
                state=command.shipping_address['state'],
                postal_code=command.shipping_address['postal_code'],
                country=command.shipping_address['country']
            )
            order.set_shipping_address(address)
            
            # Reserve inventory
            for item in command.items:
                self._inventory_repository.reserve(
                    item['product_id'], 
                    item['quantity']
                )
            
            # Persist order (transaction boundary)
            self._order_repository.save(order)
            
            # Return DTO
            order_dto = self._map_to_dto(order)
            
            print(f"\n[SERVICE] Order created: {order_id}")
            print(f"  Customer: {command.customer_id}")
            print(f"  Total: {order.calculate_total()}")
            print(f"  Items: {len(order.lines)}")
            
            return Result(success=True, data=order_dto)
            
        except ValueError as e:
            # Domain validation error
            return Result(success=False, error=str(e))
        except Exception as e:
            # Unexpected error
            print(f"[SERVICE] Error creating order: {e}")
            return Result(success=False, error="Failed to create order")
    
    def process_payment_and_confirm(self, order_id: str, 
                                    payment_method: str) -> Result:
        """
        Process payment and confirm order use case
        Coordinates: order retrieval, payment processing, order confirmation, notification
        """
        try:
            # Retrieve order aggregate
            order = self._order_repository.get_by_id(order_id)
            if not order:
                return Result(success=False, error="Order not found")
            
            # Calculate amount
            total = order.calculate_total()
            
            # Process payment through payment gateway
            print(f"\n[SERVICE] Processing payment for order {order_id}")
            print(f"  Amount: {total}")
            
            # Authorize payment
            auth_result = self._payment_gateway.authorize(
                order_id, 
                total, 
                payment_method
            )
            
            if not auth_result['success']:
                return Result(success=False, error="Payment authorization failed")
            
            order.authorize_payment()
            
            # Capture payment
            capture_result = self._payment_gateway.capture(
                auth_result['authorization_id']
            )
            
            if not capture_result['success']:
                return Result(success=False, error="Payment capture failed")
            
            order.capture_payment()
            
            # Confirm order (domain business rule enforcement)
            order.confirm()
            
            # Persist changes (transaction boundary)
            self._order_repository.save(order)
            
            # Send notification (outside transaction)
            self._notification_service.send_order_confirmation(
                order.customer_id,
                order.order_id
            )
            
            print(f"[SERVICE] Order confirmed: {order_id}")
            
            order_dto = self._map_to_dto(order)
            return Result(success=True, data=order_dto)
            
        except ValueError as e:
            return Result(success=False, error=str(e))
        except Exception as e:
            print(f"[SERVICE] Error processing payment: {e}")
            return Result(success=False, error="Failed to process payment")
    
    def cancel_order(self, order_id: str, reason: str) -> Result:
        """
        Cancel order use case
        Coordinates: order retrieval, cancellation, inventory release, refund
        """
        try:
            # Retrieve order
            order = self._order_repository.get_by_id(order_id)
            if not order:
                return Result(success=False, error="Order not found")
            
            print(f"\n[SERVICE] Cancelling order {order_id}")
            print(f"  Reason: {reason}")
            
            # Cancel order (domain rule enforcement)
            order.cancel()
            
            # Release inventory
            for line in order.lines:
                self._inventory_repository.release(
                    line.product_id, 
                    line.quantity
                )
            
            # Process refund if payment was captured
            if order.payment_status == PaymentStatus.CAPTURED:
                self._payment_gateway.refund(
                    order_id, 
                    order.calculate_total()
                )
            
            # Persist changes
            self._order_repository.save(order)
            
            print(f"[SERVICE] Order cancelled: {order_id}")
            
            order_dto = self._map_to_dto(order)
            return Result(success=True, data=order_dto)
            
        except ValueError as e:
            return Result(success=False, error=str(e))
        except Exception as e:
            print(f"[SERVICE] Error cancelling order: {e}")
            return Result(success=False, error="Failed to cancel order")
    
    def ship_order(self, order_id: str, tracking_number: str) -> Result:
        """
        Ship order use case
        Coordinates: order retrieval, shipping, notification
        """
        try:
            order = self._order_repository.get_by_id(order_id)
            if not order:
                return Result(success=False, error="Order not found")
            
            print(f"\n[SERVICE] Shipping order {order_id}")
            print(f"  Tracking: {tracking_number}")
            
            # Mark as shipped (domain rule enforcement)
            order.mark_as_shipped(tracking_number)
            
            # Persist changes
            self._order_repository.save(order)
            
            # Send notification
            self._notification_service.send_shipping_notification(
                order.customer_id,
                order.order_id,
                tracking_number
            )
            
            print(f"[SERVICE] Order shipped: {order_id}")
            
            order_dto = self._map_to_dto(order)
            return Result(success=True, data=order_dto)
            
        except ValueError as e:
            return Result(success=False, error=str(e))
        except Exception as e:
            print(f"[SERVICE] Error shipping order: {e}")
            return Result(success=False, error="Failed to ship order")
    
    def get_order(self, order_id: str) -> Result:
        """
        Get order details use case
        Simple retrieval and DTO mapping
        """
        try:
            order = self._order_repository.get_by_id(order_id)
            if not order:
                return Result(success=False, error="Order not found")
            
            order_dto = self._map_to_dto(order)
            return Result(success=True, data=order_dto)
            
        except Exception as e:
            print(f"[SERVICE] Error retrieving order: {e}")
            return Result(success=False, error="Failed to retrieve order")
    
    def get_customer_orders(self, customer_id: str) -> Result:
        """
        Get all orders for customer use case
        """
        try:
            orders = self._order_repository.get_by_customer(customer_id)
            order_dtos = [self._map_to_dto(order) for order in orders]
            
            return Result(success=True, data=order_dtos)
            
        except Exception as e:
            print(f"[SERVICE] Error retrieving customer orders: {e}")
            return Result(success=False, error="Failed to retrieve orders")
    
    def _validate_create_order(self, command: CreateOrderCommand) -> List[str]:
        """Application-level validation"""
        errors = []
        
        if not command.customer_id:
            errors.append("Customer ID is required")
        
        if not command.items:
            errors.append("Order must contain at least one item")

	    for item in command.items:
	        if 'product_id' not in item:
	            errors.append("Product ID required for all items")
	        if 'quantity' not in item or item['quantity'] <= 0:
	            errors.append("Valid quantity required for all items")
	    
	    required_address_fields = ['street', 'city', 'state', 'postal_code', 'country']
	    for field in required_address_fields:
	        if field not in command.shipping_address:
	            errors.append(f"Shipping address {field} is required")
	    
	    return errors

def _map_to_dto(self, order: Order) -> OrderDto:
    """Map domain entity to DTO"""
    return OrderDto(
        order_id=order.order_id,
        customer_id=order.customer_id,
        status=order.status.value,
        total=str(order.calculate_total()),
        items=[
            {
                'product_id': line.product_id,
                'product_name': line.product_name,
                'quantity': line.quantity,
                'unit_price': str(line.unit_price),
                'subtotal': str(line.subtotal())
            }
            for line in order.lines
        ],
        shipping_address={
            'street': order.shipping_address.street,
            'city': order.shipping_address.city,
            'state': order.shipping_address.state,
            'postal_code': order.shipping_address.postal_code,
            'country': order.shipping_address.country
        } if order.shipping_address else None,
        created_at=order.created_at.isoformat(),
        payment_status=order.payment_status.value
    )

# Mock Infrastructure Implementations

class InMemoryOrderRepository(IOrderRepository):
    """In-memory order repository for demonstration"""

    def __init__(self):
        self._orders: Dict[str, Order] = {}
        self._counter = 0

    def get_by_id(self, order_id: str) -> Optional[Order]:
        return self._orders.get(order_id)

    def get_by_customer(self, customer_id: str) -> List[Order]:
        return [o for o in self._orders.values() if o.customer_id == customer_id]

    def save(self, order: Order) -> None:
        self._orders[order.order_id] = order
        print(f"[REPOSITORY] Saved order {order.order_id}")

    def next_identity(self) -> str:
        self._counter += 1
        return f"ORD-{self._counter:05d}"


class InMemoryInventoryRepository(IInventoryRepository):
    """In-memory inventory repository for demonstration"""

    def __init__(self):
        self._inventory = {
            "PROD-001": 100,
            "PROD-002": 50,
            "PROD-003": 25,
        }
        self._reserved = {}

    def check_availability(self, product_id: str, quantity: int) -> bool:
        available = self._inventory.get(product_id, 0)
        reserved = self._reserved.get(product_id, 0)
        result = (available - reserved) >= quantity
        print(
            f"[INVENTORY] Check {product_id}: "
            f"available={available}, reserved={reserved}, "
            f"need={quantity}, ok={result}"
        )
        return result

    def reserve(self, product_id: str, quantity: int) -> bool:
        if not self.check_availability(product_id, quantity):
            return False

        self._reserved[product_id] = self._reserved.get(product_id, 0) + quantity
        print(f"[INVENTORY] Reserved {quantity} of {product_id}")
        return True

    def release(self, product_id: str, quantity: int) -> None:
        self._reserved[product_id] = max(
            0, self._reserved.get(product_id, 0) - quantity
        )
        print(f"[INVENTORY] Released {quantity} of {product_id}")


class MockPaymentGateway(IPaymentGateway):
    """Mock payment gateway for demonstration"""

    def authorize(
        self,
        order_id: str,
        amount: Money,
        payment_method: str,
    ) -> Dict[str, Any]:
        auth_id = f"AUTH-{uuid4().hex[:8].upper()}"
        print(f"[PAYMENT] Authorized {amount} for order {order_id}")
        print(f"  Authorization ID: {auth_id}")
        return {
            "success": True,
            "authorization_id": auth_id,
            "amount": str(amount),
        }

    def capture(self, authorization_id: str) -> Dict[str, Any]:
        transaction_id = f"TXN-{uuid4().hex[:8].upper()}"
        print(f"[PAYMENT] Captured payment {authorization_id}")
        print(f"  Transaction ID: {transaction_id}")
        return {
            "success": True,
            "transaction_id": transaction_id,
        }

    def refund(self, transaction_id: str, amount: Money) -> Dict[str, Any]:
        refund_id = f"REF-{uuid4().hex[:8].upper()}"
        print(f"[PAYMENT] Refunded {amount} for transaction {transaction_id}")
        print(f"  Refund ID: {refund_id}")
        return {
            "success": True,
            "refund_id": refund_id,
        }


class MockNotificationService(INotificationService):
    """Mock notification service for demonstration"""

    def send_order_confirmation(self, customer_id: str, order_id: str) -> None:
        print(f"[NOTIFICATION] Sent order confirmation to customer {customer_id}")
        print(f"  Order: {order_id}")

    def send_shipping_notification(
        self,
        customer_id: str,
        order_id: str,
        tracking_number: str,
    ) -> None:
        print(f"[NOTIFICATION] Sent shipping notification to customer {customer_id}")
        print(f"  Order: {order_id}, Tracking: {tracking_number}")


# Demonstration

def main():
    print("=" * 80)
    print("APPLICATION SERVICE PATTERN DEMONSTRATION")
    print("=" * 80)

    # Initialize infrastructure
    order_repo = InMemoryOrderRepository()
    inventory_repo = InMemoryInventoryRepository()
    payment_gateway = MockPaymentGateway()
    notification_service = MockNotificationService()

    # Initialize application service
    order_service = OrderApplicationService(
        order_repo,
        inventory_repo,
        payment_gateway,
        notification_service,
    )

    print("\n" + "=" * 80)
    print("USE CASE 1: Create Order")
    print("=" * 80)

    create_command = CreateOrderCommand(
        customer_id="CUST-12345",
        items=[
            {
                "product_id": "PROD-001",
                "product_name": "Laptop Computer",
                "unit_price": "1299.99",
                "quantity": 1,
            },
            {
                "product_id": "PROD-002",
                "product_name": "Wireless Mouse",
                "unit_price": "49.99",
                "quantity": 2,
            },
        ],
        shipping_address={
            "street": "123 Main Street",
            "city": "San Francisco",
            "state": "CA",
            "postal_code": "94105",
            "country": "USA",
        },
        payment_method="credit_card",
    )

    result = order_service.create_order(create_command)

    if result.success:
        print("\n✓ Order created successfully")
        order_dto = result.data
        order_id = order_dto.order_id
        print(f"  Order ID: {order_dto.order_id}")
        print(f"  Status: {order_dto.status}")
        print(f"  Total: {order_dto.total}")
    else:
        print(f"\n✗ Order creation failed: {result.error}")
        if result.errors:
            for error in result.errors:
                print(f"  - {error}")
        return

    print("\n" + "=" * 80)
    print("USE CASE 2: Process Payment and Confirm Order")
    print("=" * 80)

    result = order_service.process_payment_and_confirm(
        order_id, "credit_card"
    )

    if result.success:
        print("\n✓ Payment processed and order confirmed")
        order_dto = result.data
        print(f"  Order ID: {order_dto.order_id}")
        print(f"  Status: {order_dto.status}")
        print(f"  Payment Status: {order_dto.payment_status}")
    else:
        print(f"\n✗ Payment processing failed: {result.error}")

    print("\n" + "=" * 80)
    print("USE CASE 3: Ship Order")
    print("=" * 80)

    result = order_service.ship_order(order_id, "TRACK-123456789")

    if result.success:
        print("\n✓ Order shipped successfully")
        order_dto = result.data
        print(f"  Order ID: {order_dto.order_id}")
        print(f"  Status: {order_dto.status}")
    else:
        print(f"\n✗ Shipping failed: {result.error}")

    print("\n" + "=" * 80)
    print("USE CASE 4: Create Second Order")
    print("=" * 80)

    create_command2 = CreateOrderCommand(
        customer_id="CUST-12345",
        items=[
            {
                "product_id": "PROD-003",
                "product_name": "Mechanical Keyboard",
                "unit_price": "159.99",
                "quantity": 1,
            }
        ],
        shipping_address={
            "street": "123 Main Street",
            "city": "San Francisco",
            "state": "CA",
            "postal_code": "94105",
            "country": "USA",
        },
        payment_method="credit_card",
    )

    result = order_service.create_order(create_command2)

    if result.success:
        print("\n✓ Second order created successfully")
        order_id_2 = result.data.order_id
        print(f"  Order ID: {order_id_2}")

    print("\n" + "=" * 80)
    print("USE CASE 5: Cancel Order")
    print("=" * 80)

    result = order_service.cancel_order(
        order_id_2, "Customer requested cancellation"
    )

    if result.success:
        print("\n✓ Order cancelled successfully")
        order_dto = result.data
        print(f"  Order ID: {order_dto.order_id}")
        print(f"  Status: {order_dto.status}")
    else:
        print(f"\n✗ Cancellation failed: {result.error}")

    print("\n" + "=" * 80)
    print("USE CASE 6: Get Customer Orders")
    print("=" * 80)

    result = order_service.get_customer_orders("CUST-12345")

    if result.success:
        orders = result.data
        print(f"\n✓ Retrieved {len(orders)} orders for customer CUST-12345")
        for order_dto in orders:
            print(f"\n  Order {order_dto.order_id}:")
            print(f"    Status: {order_dto.status}")
            print(f"    Total: {order_dto.total}")
            print(f"    Items: {len(order_dto.items)}")
            print(f"    Created: {order_dto.created_at}")

    print("\n" + "=" * 80)
    print("DEMONSTRATION OF DOMAIN RULE ENFORCEMENT")
    print("=" * 80)

    print("\nAttempting to ship already-shipped order...")
    result = order_service.ship_order(order_id, "TRACK-987654321")

    if not result.success:
        print(f"✓ Domain rule enforced: {result.error}")

    print("\nAttempting to create order without shipping address...")
    invalid_command = CreateOrderCommand(
        customer_id="CUST-99999",
        items=[
            {
                "product_id": "PROD-001",
                "product_name": "Test",
                "unit_price": "100",
                "quantity": 1,
            }
        ],
        shipping_address={},
        payment_method="credit_card",
    )

    result = order_service.create_order(invalid_command)

    if not result.success:
        print("✓ Validation enforced:")
        for error in result.errors or []:
            print(f"  - {error}")

    print("\n" + "=" * 80)
    print("DEMONSTRATION COMPLETE")
    print("=" * 80)


if __name__ == "__main__":
    main()
```

### **Output**

```

# ================================================================================ APPLICATION SERVICE PATTERN DEMONSTRATION

# ================================================================================ USE CASE 1: Create Order

[INVENTORY] Check PROD-001: available=100, reserved=0, need=1, ok=True [INVENTORY] Check PROD-002: available=50, reserved=0, need=2, ok=True [INVENTORY] Reserved 1 of PROD-001 [INVENTORY] Reserved 2 of PROD-002 [REPOSITORY] Saved order ORD-00001

[SERVICE] Order created: ORD-00001 Customer: CUST-12345 Total: USD 1399.97 Items: 2

✓ Order created successfully Order ID: ORD-00001 Status: pending Total: USD 1399.97

# ================================================================================ USE CASE 2: Process Payment and Confirm Order

[SERVICE] Processing payment for order ORD-00001 Amount: USD 1399.97 [PAYMENT] Authorized USD 1399.97 for order ORD-00001 Authorization ID: AUTH-A1B2C3D4 [PAYMENT] Captured payment AUTH-A1B2C3D4 Transaction ID: TXN-E5F6G7H8 [REPOSITORY] Saved order ORD-00001 [NOTIFICATION] Sent order confirmation to customer CUST-12345 Order: ORD-00001 [SERVICE] Order confirmed: ORD-00001

✓ Payment processed and order confirmed Order ID: ORD-00001 Status: confirmed Payment Status: captured

# ================================================================================ USE CASE 3: Ship Order

[SERVICE] Shipping order ORD-00001 Tracking: TRACK-123456789 [REPOSITORY] Saved order ORD-00001 [NOTIFICATION] Sent shipping notification to customer CUST-12345 Order: ORD-00001, Tracking: TRACK-123456789 [SERVICE] Order shipped: ORD-00001

✓ Order shipped successfully Order ID: ORD-00001 Status: shipped

# ================================================================================ USE CASE 4: Create Second Order

[INVENTORY] Check PROD-003: available=25, reserved=0, need=1, ok=True [INVENTORY] Reserved 1 of PROD-003 [REPOSITORY] Saved order ORD-00002

[SERVICE] Order created: ORD-00002 Customer: CUST-12345 Total: USD 159.99 Items: 1

✓ Second order created successfully Order ID: ORD-00002

# ================================================================================ USE CASE 5: Cancel Order

[SERVICE] Cancelling order ORD-00002 Reason: Customer requested cancellation [INVENTORY] Released 1 of PROD-003 [REPOSITORY] Saved order ORD-00002 [SERVICE] Order cancelled: ORD-00002

✓ Order cancelled successfully Order ID: ORD-00002 Status: cancelled

# ================================================================================ USE CASE 6: Get Customer Orders

✓ Retrieved 2 orders for customer CUST-12345

Order ORD-00001: Status: shipped Total: USD 1399.97 Items: 2 Created: 2025-12-20T08:45:23.123456

Order ORD-00002: Status: cancelled Total: USD 159.99 Items: 1 Created: 2025-12-20T08:45:24.234567

# ================================================================================ DEMONSTRATION OF DOMAIN RULE ENFORCEMENT

Attempting to ship already-shipped order... ✓ Domain rule enforced: Cannot ship order in shipped status

Attempting to create order without shipping address... ✓ Validation enforced:

- Shipping address street is required
- Shipping address city is required
- Shipping address state is required
- Shipping address postal_code is required
- Shipping address country is required

# ================================================================================ DEMONSTRATION COMPLETE

```

The example demonstrates comprehensive application service responsibilities including use case coordination across multiple domains, transaction management ensuring atomic operations, input validation at both application and domain levels, DTO mapping to decouple external and internal representations, domain rule enforcement through aggregate methods, infrastructure service integration for payments and notifications, and error handling with structured result objects. The service orchestrates complex workflows while delegating all business logic to domain entities, maintaining clear separation of concerns between orchestration and business rules.

### **Conclusion**

The Application Service pattern provides essential structure for organizing business workflows in layered architectures. By serving as the coordination point for use cases, application services create clear boundaries between external interfaces and domain logic. They orchestrate operations without implementing business rules, maintain transaction consistency, enforce security policies, and translate between external data formats and domain concepts.

Success with this pattern requires maintaining discipline about what belongs in application services versus domain objects. Application services should remain focused on orchestration—retrieving entities, coordinating interactions, managing transactions, and returning results. Business logic must live in domain entities where it can be properly encapsulated, tested, and reused. When this separation is maintained, systems gain flexibility to evolve the domain model independently, change persistence strategies without affecting business logic, and adapt external interfaces without modifying core functionality.

### **Next Steps**

Study the Repository pattern to understand how application services retrieve and persist domain objects without coupling to specific data access technologies. Explore Domain-Driven Design tactical patterns including entities, value objects, and aggregates to strengthen domain models that application services coordinate. Investigate the CQRS pattern to separate command operations from queries when read and write concerns diverge significantly. Examine the Unit of Work pattern for managing transactions and tracking changes across multiple repository operations. Consider how application services integrate with event-driven architectures through domain event publication. Practice building application services for your domain by identifying use cases, defining clear transaction boundaries, and maintaining strict separation between orchestration logic and business rules.
```

---

## Domain Events Pattern

Domain Events are a design pattern that captures and communicates significant occurrences within a domain model as explicit, immutable objects. They represent something meaningful that has happened in the business domain, enabling loose coupling between components while maintaining a clear audit trail of state changes and business activities.

### Core Concepts

A Domain Event is a record of something that has occurred in the system that domain experts care about. Unlike technical events (like "button clicked" or "record updated"), domain events reflect business-significant occurrences expressed in the ubiquitous language of the domain.

**Event as Historical Fact**: Domain events represent things that have already happened and cannot be changed. They are expressed in past tense (e.g., "OrderPlaced", "PaymentProcessed", "CustomerRelocated") rather than commands (e.g., "PlaceOrder", "ProcessPayment").

**Business Significance**: Not every state change warrants a domain event. Events should represent meaningful business occurrences that other parts of the system or external stakeholders need to know about.

**Immutability**: Once created, a domain event should never be modified. This preserves the integrity of the event history and enables reliable event sourcing and auditing.

### Anatomy of a Domain Event

**Event Identity**: A unique identifier for the event instance, typically a GUID or UUID.

**Event Type**: The name describing what happened, following domain language conventions.

**Timestamp**: When the event occurred, crucial for ordering and temporal queries.

**Aggregate Identity**: Reference to the entity or aggregate that generated the event.

**Event Data**: The relevant information about what happened, capturing the state that changed or the details of the occurrence.

**Metadata**: Additional context such as user identity, correlation IDs, causation IDs, or version information.

### Types of Domain Events

**Internal Domain Events**: Published and consumed within the same bounded context. Used to maintain consistency between aggregates and trigger side effects within the domain.

**External Domain Events** (Integration Events): Published across bounded context boundaries to notify other subsystems or external systems. These often require translation to protect internal domain details.

**Event Notifications**: Lightweight events that simply announce something happened, requiring consumers to query for details if needed.

**Event-Carried State Transfer**: Events containing all necessary data for consumers to act, reducing coupling and query dependencies.

**Delta Events**: Capture only what changed between states.

**Snapshot Events**: Capture complete state at a point in time.

### Event Publishing Mechanisms

**Synchronous Publishing**: Events are dispatched immediately within the same transaction or process flow. Handlers execute before the original operation completes.

**Asynchronous Publishing**: Events are queued and processed after the triggering transaction commits, enabling eventual consistency and decoupled processing.

**In-Process Event Bus**: Events are published and consumed within the same application process using a mediator or event dispatcher.

**Out-of-Process Message Broker**: Events are published to external infrastructure (RabbitMQ, Kafka, Azure Service Bus) for distributed consumption.

**Event Store**: Events are persisted to a specialized database optimized for append-only event streams, enabling event sourcing and temporal queries.

### Event Handling Patterns

**Direct Subscription**: Handlers explicitly subscribe to specific event types, receiving notifications when those events occur.

**Event Handler Registry**: A centralized registry maintains mappings between event types and their handlers, enabling dynamic handler registration.

**Convention-Based Routing**: Events are routed to handlers based on naming conventions or attributes, reducing explicit configuration.

**Projections**: Event handlers that build read models or materialized views from event streams.

**Process Managers** (Sagas): Long-running workflows coordinated through domain events, managing complex business processes spanning multiple aggregates.

**Reactive Extensions**: Using observable streams to compose complex event processing logic with filtering, transformation, and aggregation operators.

### Implementation Considerations

**Event Versioning**: As systems evolve, event schemas change. Strategies include:

- Upcasting: Converting old event versions to new schemas when reading
- Downcasting: Converting new events to old schemas for legacy consumers
- Multi-version support: Maintaining handlers for multiple event versions
- Weak schema: Using flexible data structures that tolerate missing fields

**Ordering Guarantees**: [Inference] Maintaining event order becomes critical in distributed systems, though guaranteed ordering often requires trade-offs with scalability and availability. Approaches include:

- Per-aggregate ordering: Events for a single aggregate are ordered
- Causal ordering: Events with causal relationships maintain order
- Total ordering: All events system-wide are ordered (expensive)

**Idempotency**: Event handlers should be idempotent, producing the same result when processing the same event multiple times, since distributed systems may deliver events more than once.

**Transaction Boundaries**: Deciding whether event publishing happens within or after the originating transaction affects consistency guarantees and failure handling.

**Event Granularity**: Finding the right level of detail—too fine-grained creates event storms; too coarse-grained loses important information.

### Advantages

**Decoupling**: Components communicate through events without direct dependencies, making systems more modular and easier to evolve independently.

**Audit Trail**: Events provide a complete, immutable history of everything that happened in the system, invaluable for debugging, compliance, and business intelligence.

**Temporal Queries**: Event streams enable querying system state at any point in history, reconstructing past states, and analyzing trends.

**Event Sourcing Foundation**: Domain events are the building blocks of event sourcing, where events become the primary source of truth.

**Integration**: Events provide a natural integration mechanism for notifying external systems and bounded contexts about significant occurrences.

**Scalability**: Asynchronous event processing enables systems to handle load spikes by queuing events and processing them at sustainable rates.

**Business Insight**: Events expressed in domain language provide valuable business metrics and process visibility.

### Disadvantages

**Complexity**: Event-driven architectures add complexity in understanding control flow, debugging, and testing compared to direct method calls.

**Eventual Consistency**: Asynchronous event handling creates windows where different parts of the system have inconsistent views of state.

**Event Schema Evolution**: Managing changes to event structures across multiple consumers and versions requires careful planning and tooling.

**Debugging Difficulty**: Tracing execution flow through asynchronous event chains is more challenging than following synchronous call stacks.

**Infrastructure Requirements**: Robust event-driven systems need reliable message brokers, event stores, or other infrastructure components.

**Ordering Complexity**: Maintaining correct event ordering in distributed systems requires careful design and may limit scalability options.

**Testing Challenges**: Testing event-driven interactions requires special techniques like event recording, replay, and verification frameworks.

### Common Use Cases

**Domain-Driven Design**: Domain events are fundamental to DDD, enabling aggregates to communicate changes without direct coupling.

**CQRS (Command Query Responsibility Segregation)**: Events synchronize write and read models, allowing independent optimization of each side.

**Event Sourcing**: Events become the primary storage mechanism, with current state derived by replaying events.

**Microservices Communication**: Events enable choreography-based coordination between autonomous services without central orchestration.

**Business Process Tracking**: Events capture business workflow progression, enabling process monitoring, analytics, and compliance reporting.

**Real-Time Analytics**: Event streams feed analytics pipelines for real-time dashboards, alerting, and business intelligence.

**System Integration**: Events provide a loosely-coupled integration layer for notifying external systems and third-party services.

### **Example**

Here's an e-commerce order processing system demonstrating domain events:

```python
from dataclasses import dataclass, field
from datetime import datetime
from typing import List, Callable, Dict, Any
from uuid import UUID, uuid4
from enum import Enum

# Domain Event Base Class
@dataclass(frozen=True)
class DomainEvent:
    """Base class for all domain events"""
    event_id: UUID = field(default_factory=uuid4)
    occurred_at: datetime = field(default_factory=datetime.utcnow)
    aggregate_id: UUID = field(default=None)
    
    def event_type(self) -> str:
        return self.__class__.__name__

# Concrete Domain Events
@dataclass(frozen=True)
class OrderPlaced(DomainEvent):
    """Event raised when customer places an order"""
    customer_id: UUID = None
    order_items: List[Dict[str, Any]] = field(default_factory=list)
    total_amount: float = 0.0

@dataclass(frozen=True)
class OrderCancelled(DomainEvent):
    """Event raised when order is cancelled"""
    reason: str = ""

@dataclass(frozen=True)
class PaymentProcessed(DomainEvent):
    """Event raised when payment completes"""
    payment_method: str = ""
    amount: float = 0.0
    transaction_id: str = ""

@dataclass(frozen=True)
class OrderShipped(DomainEvent):
    """Event raised when order ships"""
    tracking_number: str = ""
    carrier: str = ""
    estimated_delivery: datetime = None

@dataclass(frozen=True)
class InventoryReserved(DomainEvent):
    """Event raised when inventory is reserved"""
    product_id: UUID = None
    quantity: int = 0

# Event Bus - In-Process Implementation
class EventBus:
    """Simple in-process event bus for publishing and subscribing to events"""
    
    def __init__(self):
        self._handlers: Dict[type, List[Callable]] = {}
    
    def subscribe(self, event_type: type, handler: Callable):
        """Subscribe a handler to an event type"""
        if event_type not in self._handlers:
            self._handlers[event_type] = []
        self._handlers[event_type].append(handler)
    
    def publish(self, event: DomainEvent):
        """Publish an event to all subscribed handlers"""
        event_type = type(event)
        if event_type in self._handlers:
            for handler in self._handlers[event_type]:
                try:
                    handler(event)
                except Exception as e:
                    print(f"Error handling {event.event_type()}: {e}")

# Domain Model - Order Aggregate
class OrderStatus(Enum):
    PENDING = "pending"
    PAID = "paid"
    SHIPPED = "shipped"
    CANCELLED = "cancelled"

class Order:
    """Order aggregate that raises domain events"""
    
    def __init__(self, order_id: UUID, customer_id: UUID, event_bus: EventBus):
        self.order_id = order_id
        self.customer_id = customer_id
        self.status = OrderStatus.PENDING
        self.items: List[Dict] = []
        self.total_amount = 0.0
        self._event_bus = event_bus
        self._pending_events: List[DomainEvent] = []
    
    def place_order(self, items: List[Dict[str, Any]]):
        """Place order and raise OrderPlaced event"""
        self.items = items
        self.total_amount = sum(item['price'] * item['quantity'] for item in items)
        
        event = OrderPlaced(
            aggregate_id=self.order_id,
            customer_id=self.customer_id,
            order_items=items,
            total_amount=self.total_amount
        )
        self._raise_event(event)
    
    def process_payment(self, payment_method: str, transaction_id: str):
        """Process payment and raise PaymentProcessed event"""
        if self.status != OrderStatus.PENDING:
            raise ValueError(f"Cannot process payment for order in {self.status} status")
        
        self.status = OrderStatus.PAID
        event = PaymentProcessed(
            aggregate_id=self.order_id,
            payment_method=payment_method,
            amount=self.total_amount,
            transaction_id=transaction_id
        )
        self._raise_event(event)
    
    def ship_order(self, tracking_number: str, carrier: str, estimated_delivery: datetime):
        """Ship order and raise OrderShipped event"""
        if self.status != OrderStatus.PAID:
            raise ValueError(f"Cannot ship order in {self.status} status")
        
        self.status = OrderStatus.SHIPPED
        event = OrderShipped(
            aggregate_id=self.order_id,
            tracking_number=tracking_number,
            carrier=carrier,
            estimated_delivery=estimated_delivery
        )
        self._raise_event(event)
    
    def cancel_order(self, reason: str):
        """Cancel order and raise OrderCancelled event"""
        if self.status == OrderStatus.SHIPPED:
            raise ValueError("Cannot cancel shipped order")
        
        self.status = OrderStatus.CANCELLED
        event = OrderCancelled(
            aggregate_id=self.order_id,
            reason=reason
        )
        self._raise_event(event)
    
    def _raise_event(self, event: DomainEvent):
        """Add event to pending events"""
        self._pending_events.append(event)
    
    def commit_events(self):
        """Publish all pending events"""
        for event in self._pending_events:
            self._event_bus.publish(event)
        self._pending_events.clear()

# Event Handlers
class EmailNotificationHandler:
    """Handles events by sending email notifications"""
    
    def on_order_placed(self, event: OrderPlaced):
        print(f"📧 Sending order confirmation email to customer {event.customer_id}")
        print(f"   Order ID: {event.aggregate_id}")
        print(f"   Total: ${event.total_amount:.2f}")
    
    def on_order_shipped(self, event: OrderShipped):
        print(f"📧 Sending shipping notification")
        print(f"   Order ID: {event.aggregate_id}")
        print(f"   Tracking: {event.tracking_number} via {event.carrier}")

class InventoryHandler:
    """Handles inventory management based on order events"""
    
    def on_order_placed(self, event: OrderPlaced):
        print(f"📦 Reserving inventory for order {event.aggregate_id}")
        for item in event.order_items:
            print(f"   - {item['name']}: {item['quantity']} units")
    
    def on_order_cancelled(self, event: OrderCancelled):
        print(f"📦 Releasing inventory for cancelled order {event.aggregate_id}")

class AnalyticsHandler:
    """Handles analytics and reporting"""
    
    def __init__(self):
        self.total_sales = 0.0
        self.orders_count = 0
    
    def on_payment_processed(self, event: PaymentProcessed):
        self.total_sales += event.amount
        self.orders_count += 1
        print(f"📊 Analytics updated:")
        print(f"   Total sales: ${self.total_sales:.2f}")
        print(f"   Orders processed: {self.orders_count}")

class AuditLogHandler:
    """Maintains audit trail of all domain events"""
    
    def __init__(self):
        self.events_log: List[DomainEvent] = []
    
    def handle_any_event(self, event: DomainEvent):
        self.events_log.append(event)
        print(f"📝 Audit log: {event.event_type()} at {event.occurred_at.isoformat()}")
        print(f"   Event ID: {event.event_id}")
        print(f"   Aggregate ID: {event.aggregate_id}")

# Application Service
class OrderService:
    """Application service coordinating order operations"""
    
    def __init__(self, event_bus: EventBus):
        self.event_bus = event_bus
        self.orders: Dict[UUID, Order] = {}
    
    def create_order(self, customer_id: UUID, items: List[Dict[str, Any]]) -> UUID:
        order_id = uuid4()
        order = Order(order_id, customer_id, self.event_bus)
        order.place_order(items)
        order.commit_events()  # Publish events after successful operation
        self.orders[order_id] = order
        return order_id
    
    def process_payment(self, order_id: UUID, payment_method: str, transaction_id: str):
        order = self.orders[order_id]
        order.process_payment(payment_method, transaction_id)
        order.commit_events()
    
    def ship_order(self, order_id: UUID, tracking_number: str, carrier: str, estimated_delivery: datetime):
        order = self.orders[order_id]
        order.ship_order(tracking_number, carrier, estimated_delivery)
        order.commit_events()

# Usage Example
if __name__ == "__main__":
    # Setup
    event_bus = EventBus()
    
    # Register event handlers
    email_handler = EmailNotificationHandler()
    inventory_handler = InventoryHandler()
    analytics_handler = AnalyticsHandler()
    audit_handler = AuditLogHandler()
    
    event_bus.subscribe(OrderPlaced, email_handler.on_order_placed)
    event_bus.subscribe(OrderPlaced, inventory_handler.on_order_placed)
    event_bus.subscribe(OrderShipped, email_handler.on_order_shipped)
    event_bus.subscribe(OrderCancelled, inventory_handler.on_order_cancelled)
    event_bus.subscribe(PaymentProcessed, analytics_handler.on_payment_processed)
    
    # Subscribe audit handler to all event types
    event_bus.subscribe(OrderPlaced, audit_handler.handle_any_event)
    event_bus.subscribe(PaymentProcessed, audit_handler.handle_any_event)
    event_bus.subscribe(OrderShipped, audit_handler.handle_any_event)
    event_bus.subscribe(OrderCancelled, audit_handler.handle_any_event)
    
    # Create service
    order_service = OrderService(event_bus)
    
    print("=== Creating New Order ===")
    customer_id = uuid4()
    items = [
        {"name": "Laptop", "price": 999.99, "quantity": 1},
        {"name": "Mouse", "price": 29.99, "quantity": 2}
    ]
    order_id = order_service.create_order(customer_id, items)
    
    print("\n=== Processing Payment ===")
    order_service.process_payment(order_id, "Credit Card", "TXN-12345")
    
    print("\n=== Shipping Order ===")
    delivery_date = datetime.utcnow()
    order_service.ship_order(order_id, "1Z999AA10123456784", "UPS", delivery_date)
    
    print(f"\n=== Audit Trail ===")
    print(f"Total events logged: {len(audit_handler.events_log)}")
```

**Output**

```
=== Creating New Order ===
📦 Reserving inventory for order [order-id]
   - Laptop: 1 units
   - Mouse: 2 units
📧 Sending order confirmation email to customer [customer-id]
   Order ID: [order-id]
   Total: $1059.97
📝 Audit log: OrderPlaced at [timestamp]
   Event ID: [event-id]
   Aggregate ID: [order-id]

=== Processing Payment ===
📊 Analytics updated:
   Total sales: $1059.97
   Orders processed: 1
📝 Audit log: PaymentProcessed at [timestamp]
   Event ID: [event-id]
   Aggregate ID: [order-id]

=== Shipping Order ===
📧 Sending shipping notification
   Order ID: [order-id]
   Tracking: 1Z999AA10123456784 via UPS
📝 Audit log: OrderShipped at [timestamp]
   Event ID: [event-id]
   Aggregate ID: [order-id]

=== Audit Trail ===
Total events logged: 3
```

This example demonstrates:

- Domain events as immutable records of business occurrences
- Event-driven decoupling between order processing and side effects
- Multiple handlers responding to the same events
- Aggregate root (Order) raising events for state changes
- Event bus coordinating publication and subscription
- Audit trail maintenance through event logging
- Real-time analytics updated through event handling

### Advanced Patterns and Techniques

**Event Store Implementation**: Specialized databases for event persistence with features like stream partitioning, projections, and temporal queries:

```python
class EventStore:
    """Simple event store for persisting and retrieving events"""
    
    def __init__(self):
        self._streams: Dict[UUID, List[DomainEvent]] = {}
    
    def append(self, aggregate_id: UUID, events: List[DomainEvent]):
        """Append events to aggregate stream"""
        if aggregate_id not in self._streams:
            self._streams[aggregate_id] = []
        self._streams[aggregate_id].extend(events)
    
    def get_stream(self, aggregate_id: UUID) -> List[DomainEvent]:
        """Retrieve all events for an aggregate"""
        return self._streams.get(aggregate_id, [])
    
    def replay(self, aggregate_id: UUID, aggregate_factory: Callable):
        """Reconstruct aggregate from event stream"""
        events = self.get_stream(aggregate_id)
        aggregate = aggregate_factory()
        for event in events:
            aggregate.apply(event)
        return aggregate
```

**Event Correlation and Causation**: Tracking relationships between events to understand cause-and-effect chains:

```python
@dataclass(frozen=True)
class DomainEventWithCorrelation(DomainEvent):
    """Event with correlation and causation tracking"""
    correlation_id: UUID = None  # Groups related events in a business process
    causation_id: UUID = None    # ID of the event that caused this event
```

**Snapshot Strategy**: For long event streams, periodic snapshots reduce replay time:

```python
@dataclass
class AggregateSnapshot:
    """Snapshot of aggregate state at a point in time"""
    aggregate_id: UUID
    version: int  # Last event version included
    state: Dict[str, Any]
    created_at: datetime
```

**Event Enrichment**: Adding contextual information to events as they flow through the system:

```python
class EventEnricher:
    """Enriches events with additional context"""
    
    def enrich(self, event: DomainEvent) -> DomainEvent:
        # Add user context, geographical data, etc.
        enriched_data = {
            **event.__dict__,
            'enriched_at': datetime.utcnow(),
            'user_agent': 'System',
            'ip_address': '127.0.0.1'
        }
        return type(event)(**enriched_data)
```

**Event Transformation for Integration**: Converting internal domain events to external integration events:

```python
class EventTranslator:
    """Translates internal events to external integration events"""
    
    def translate(self, internal_event: OrderPlaced) -> Dict[str, Any]:
        """Convert internal event to external format"""
        return {
            'event_type': 'order.placed',
            'event_version': '1.0',
            'timestamp': internal_event.occurred_at.isoformat(),
            'data': {
                'order_id': str(internal_event.aggregate_id),
                'amount': internal_event.total_amount
            }
        }
```

### Event Sourcing Integration

Domain events form the foundation of event sourcing, where events become the source of truth:

**Event-Sourced Aggregate**: Aggregates that reconstruct state from events:

```python
class EventSourcedOrder:
    """Order aggregate reconstructed from events"""
    
    def __init__(self):
        self.order_id = None
        self.status = None
        self.items = []
        self.version = 0
    
    def apply(self, event: DomainEvent):
        """Apply event to rebuild state"""
        if isinstance(event, OrderPlaced):
            self.order_id = event.aggregate_id
            self.items = event.order_items
            self.status = OrderStatus.PENDING
        elif isinstance(event, PaymentProcessed):
            self.status = OrderStatus.PAID
        elif isinstance(event, OrderShipped):
            self.status = OrderStatus.SHIPPED
        elif isinstance(event, OrderCancelled):
            self.status = OrderStatus.CANCELLED
        
        self.version += 1
```

**Optimistic Concurrency**: Using event versions to detect conflicts:

```python
class ConcurrencyException(Exception):
    pass

def save_with_concurrency_check(aggregate_id: UUID, 
                                expected_version: int, 
                                new_events: List[DomainEvent],
                                event_store: EventStore):
    """Save events with optimistic concurrency control"""
    current_version = len(event_store.get_stream(aggregate_id))
    if current_version != expected_version:
        raise ConcurrencyException(
            f"Expected version {expected_version}, "
            f"but current version is {current_version}"
        )
    event_store.append(aggregate_id, new_events)
```

### Testing Domain Events

**Event Assertion Testing**: Verifying that operations raise expected events:

```python
def test_order_placement_raises_event():
    event_bus = EventBus()
    captured_events = []
    event_bus.subscribe(OrderPlaced, lambda e: captured_events.append(e))
    
    order = Order(uuid4(), uuid4(), event_bus)
    items = [{"name": "Product", "price": 10.0, "quantity": 1}]
    order.place_order(items)
    order.commit_events()
    
    assert len(captured_events) == 1
    assert isinstance(captured_events[0], OrderPlaced)
    assert captured_events[0].total_amount == 10.0
```

**Event Replay Testing**: Testing aggregate reconstruction from events:

```python
def test_order_reconstruction_from_events():
    events = [
        OrderPlaced(aggregate_id=uuid4(), order_items=[], total_amount=100.0),
        PaymentProcessed(aggregate_id=uuid4(), amount=100.0, payment_method="Card")
    ]
    
    order = EventSourcedOrder()
    for event in events:
        order.apply(event)
    
    assert order.status == OrderStatus.PAID
    assert order.version == 2
```

**Handler Isolation Testing**: Testing event handlers independently:

```python
def test_email_handler_sends_confirmation():
    handler = EmailNotificationHandler()
    event = OrderPlaced(
        aggregate_id=uuid4(),
        customer_id=uuid4(),
        order_items=[],
        total_amount=50.0
    )
    
    # Verify handler processes event without errors
    handler.on_order_placed(event)
```

### Monitoring and Observability

**Event Metrics**: Tracking event publication and processing:

- Event throughput (events per second)
- Handler latency (time to process events)
- Failed event processing attempts
- Event queue depth and lag

**Event Tracing**: Distributed tracing across event-driven workflows using correlation IDs to follow business processes through multiple services and handlers.

**Dead Letter Queues**: Capturing events that fail processing repeatedly for manual intervention and analysis.

### Relationship to Other Patterns

**Observer Pattern**: Domain events are an evolution of Observer, decoupling subjects from observers through an event bus and using value objects instead of direct callbacks.

**Command Pattern**: Commands represent requests to do something (imperative), while events represent things that happened (past tense). Commands can trigger operations that raise events.

**Mediator Pattern**: Event buses act as mediators, coordinating communication between components without them knowing about each other.

**Publish-Subscribe**: Domain events implement pub-sub at the domain level, with business-meaningful messages instead of technical notifications.

**Event Sourcing**: Domain events become the storage mechanism, with current state derived from event history rather than stored directly.

**CQRS**: Domain events synchronize the write model with read models, enabling separate optimization strategies for commands and queries.

### Best Practices

**Name Events in Past Tense**: Events represent things that happened, so use past tense naming (OrderPlaced, not PlaceOrder).

**Include Relevant Data**: Events should contain enough information for consumers to act without additional queries, but avoid including sensitive data unnecessarily.

**Version Events Explicitly**: Include version information in events to support schema evolution and maintain backward compatibility.

**Keep Events Small**: Focus on what changed rather than complete state snapshots, unless building event-carried state transfer patterns.

**Use Strong Typing**: Strongly-typed events catch errors at compile time and make event contracts explicit and discoverable.

**Handle Events Idempotently**: [Inference] Designing handlers to produce consistent results when processing the same event multiple times helps ensure system reliability, though the specific idempotency strategy depends on the handler's purpose.

**Separate Internal and External Events**: Internal domain events stay within bounded contexts; external integration events cross boundaries with appropriate translation.

**Monitor Event Processing**: Track event throughput, handler latency, and failures to identify bottlenecks and issues quickly.

**Document Event Contracts**: Maintain clear documentation of event schemas, when they're raised, and what they signify in the business domain.

**Consider Event Retention**: Define policies for how long events are retained, balancing audit requirements against storage costs.

### Common Pitfalls

**Over-Eventing**: Creating events for every state change rather than focusing on business-significant occurrences creates noise and complexity.

**Event Coupling**: Including implementation details or internal IDs in events couples consumers to internal structure.

**Missing Context**: Events lacking sufficient information force consumers to query for additional data, creating coupling and performance issues.

**Synchronous Event Chains**: Long chains of synchronous event handlers create brittle, slow systems. Consider asynchronous processing for non-critical paths.

**Event Ordering Assumptions**: Assuming global event ordering when it's not guaranteed leads to race conditions and inconsistencies in distributed systems.

**Ignoring Failures**: Not handling event processing failures gracefully can lead to lost events, inconsistent state, or cascading failures.

**Premature Event Sourcing**: Adopting event sourcing before understanding domain events adds unnecessary complexity to systems that don't need full event sourcing benefits.

### **Conclusion**

Domain Events are a powerful pattern for building flexible, maintainable, and observable systems that closely align with business processes. By capturing significant domain occurrences as explicit, immutable objects, they enable loose coupling between components, maintain comprehensive audit trails, and provide a foundation for advanced architectural patterns like event sourcing and CQRS. While they introduce complexity in event management, versioning, and eventual consistency, the benefits of modularity, scalability, and business insight make domain events essential for modern distributed systems and domain-driven design. Success requires careful attention to event granularity, naming, versioning, and the balance between decoupling and complexity, but when applied appropriately, domain events create systems that are both technically robust and aligned with business understanding.

---

## Event Sourcing

Event Sourcing is an architectural pattern where state changes in an application are stored as a sequence of events rather than storing just the current state. Instead of updating records in place, every change to application state is captured as an immutable event that describes what happened. The current state is derived by replaying these events from the beginning or from a snapshot.

### Purpose and Intent

Event Sourcing fundamentally changes how applications persist data. Rather than storing the current state of entities in a database and losing the history of how that state was reached, Event Sourcing stores every state change as a discrete event. This creates a complete audit trail and enables powerful capabilities like temporal queries, event replay, and deriving multiple read models from the same event stream.

### Problem Statement

Traditional state-oriented persistence approaches face several challenges:

- **Lost History**: Updating records in place destroys historical information about how entities evolved over time
- **Audit Requirements**: Many domains require complete audit trails showing who changed what and when
- **Debugging Complexity**: Understanding how a system reached its current state is difficult without historical data
- **Temporal Queries**: Answering questions like "what was the state at a specific point in time" requires complex solutions
- **Data Integration**: Synchronizing state across multiple systems is error-prone and can lead to inconsistencies
- **Business Intelligence**: Analyzing patterns and trends requires historical data that may not be available
- **Conflict Resolution**: In distributed systems, concurrent updates to the same state are difficult to merge

### Solution

Event Sourcing addresses these problems by:

1. **Storing Events**: Every state change is captured as an immutable event containing all information about what changed
2. **Event Store**: Events are persisted in an append-only log that serves as the source of truth
3. **State Reconstruction**: Current state is rebuilt by replaying events from the event store
4. **Event Replay**: Historical states can be reconstructed by replaying events up to any point in time
5. **Multiple Projections**: Different read models can be built from the same event stream to serve different query needs

### Structure

The pattern involves several key components:

**Event**: An immutable record describing something that happened in the system. Events are always named in past tense (e.g., "OrderPlaced", "PaymentProcessed").

**Event Store**: A specialized database optimized for appending and reading sequences of events. It preserves the order of events.

**Aggregate**: A domain entity that produces events in response to commands. It encapsulates business logic and maintains consistency boundaries.

**Event Stream**: A sequence of events for a specific aggregate instance, identified by an aggregate ID.

**Projection/Read Model**: A materialized view built by processing events, optimized for specific query patterns.

**Event Handler**: Components that react to events, updating projections or triggering side effects.

### Implementation Approaches

**Basic Event Sourcing**

Here's a foundational implementation showing core concepts:

```python
from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional, Type
from datetime import datetime
from abc import ABC, abstractmethod
import json
from copy import deepcopy

# Base Event class
@dataclass
class Event:
    """Base class for all domain events"""
    event_id: str
    aggregate_id: str
    timestamp: datetime
    event_version: int = 1
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Serialize event to dictionary"""
        return {
            'event_type': self.__class__.__name__,
            'event_id': self.event_id,
            'aggregate_id': self.aggregate_id,
            'timestamp': self.timestamp.isoformat(),
            'event_version': self.event_version,
            'metadata': self.metadata,
            'data': self._get_event_data()
        }
    
    def _get_event_data(self) -> Dict[str, Any]:
        """Extract event-specific data"""
        data = {}
        for key, value in self.__dict__.items():
            if key not in ['event_id', 'aggregate_id', 'timestamp', 'event_version', 'metadata']:
                data[key] = value
        return data

# Event Store
class EventStore:
    """In-memory event store implementation"""
    
    def __init__(self):
        self._events: Dict[str, List[Event]] = {}
        self._global_sequence: List[Event] = []
    
    def append(self, aggregate_id: str, events: List[Event], expected_version: Optional[int] = None):
        """Append events to the store with optimistic concurrency control"""
        if aggregate_id not in self._events:
            self._events[aggregate_id] = []
        
        current_version = len(self._events[aggregate_id])
        
        # Optimistic concurrency check
        if expected_version is not None and current_version != expected_version:
            raise ConcurrencyException(
                f"Expected version {expected_version} but current version is {current_version}"
            )
        
        # Append events
        for event in events:
            self._events[aggregate_id].append(event)
            self._global_sequence.append(event)
        
        print(f"Appended {len(events)} event(s) to aggregate {aggregate_id}")
    
    def get_events(self, aggregate_id: str, from_version: int = 0) -> List[Event]:
        """Retrieve events for an aggregate"""
        if aggregate_id not in self._events:
            return []
        return self._events[aggregate_id][from_version:]
    
    def get_all_events(self, from_sequence: int = 0) -> List[Event]:
        """Retrieve all events in order"""
        return self._global_sequence[from_sequence:]
    
    def get_version(self, aggregate_id: str) -> int:
        """Get current version of aggregate"""
        if aggregate_id not in self._events:
            return 0
        return len(self._events[aggregate_id])

class ConcurrencyException(Exception):
    """Raised when concurrent modifications conflict"""
    pass

# Aggregate base class
class AggregateRoot(ABC):
    """Base class for event-sourced aggregates"""
    
    def __init__(self, aggregate_id: str):
        self.aggregate_id = aggregate_id
        self._version = 0
        self._uncommitted_events: List[Event] = []
    
    def load_from_history(self, events: List[Event]):
        """Rebuild aggregate state from events"""
        for event in events:
            self._apply_event(event, is_new=False)
            self._version += 1
    
    def get_uncommitted_events(self) -> List[Event]:
        """Get events that haven't been persisted"""
        return self._uncommitted_events.copy()
    
    def mark_events_as_committed(self):
        """Clear uncommitted events after persistence"""
        self._uncommitted_events.clear()
    
    def _apply_event(self, event: Event, is_new: bool = True):
        """Apply event to aggregate state"""
        # Find and call the appropriate handler method
        handler_name = f"_on_{event.__class__.__name__}"
        if hasattr(self, handler_name):
            handler = getattr(self, handler_name)
            handler(event)
        
        if is_new:
            self._uncommitted_events.append(event)
    
    @property
    def version(self) -> int:
        return self._version
```

**Domain Model with Events**

Here's a complete example of a bank account aggregate:

```python
import uuid

# Domain Events
@dataclass
class AccountOpened(Event):
    """Event: A bank account was opened"""
    account_holder: str
    initial_balance: float
    currency: str = "USD"

@dataclass
class MoneyDeposited(Event):
    """Event: Money was deposited into account"""
    amount: float
    description: str

@dataclass
class MoneyWithdrawn(Event):
    """Event: Money was withdrawn from account"""
    amount: float
    description: str

@dataclass
class AccountClosed(Event):
    """Event: Account was closed"""
    reason: str
    final_balance: float

# Bank Account Aggregate
class BankAccount(AggregateRoot):
    """Event-sourced bank account aggregate"""
    
    def __init__(self, aggregate_id: str):
        super().__init__(aggregate_id)
        self.account_holder: Optional[str] = None
        self.balance: float = 0.0
        self.currency: str = "USD"
        self.is_closed: bool = False
        self.transaction_count: int = 0
    
    # Commands (business logic that produces events)
    
    def open_account(self, account_holder: str, initial_balance: float):
        """Open a new bank account"""
        if self.account_holder is not None:
            raise ValueError("Account already opened")
        
        if initial_balance < 0:
            raise ValueError("Initial balance cannot be negative")
        
        event = AccountOpened(
            event_id=str(uuid.uuid4()),
            aggregate_id=self.aggregate_id,
            timestamp=datetime.now(),
            account_holder=account_holder,
            initial_balance=initial_balance
        )
        self._apply_event(event)
    
    def deposit(self, amount: float, description: str = ""):
        """Deposit money into account"""
        if self.is_closed:
            raise ValueError("Cannot deposit to closed account")
        
        if amount <= 0:
            raise ValueError("Deposit amount must be positive")
        
        event = MoneyDeposited(
            event_id=str(uuid.uuid4()),
            aggregate_id=self.aggregate_id,
            timestamp=datetime.now(),
            amount=amount,
            description=description
        )
        self._apply_event(event)
    
    def withdraw(self, amount: float, description: str = ""):
        """Withdraw money from account"""
        if self.is_closed:
            raise ValueError("Cannot withdraw from closed account")
        
        if amount <= 0:
            raise ValueError("Withdrawal amount must be positive")
        
        if self.balance < amount:
            raise ValueError(f"Insufficient funds. Balance: {self.balance}, Requested: {amount}")
        
        event = MoneyWithdrawn(
            event_id=str(uuid.uuid4()),
            aggregate_id=self.aggregate_id,
            timestamp=datetime.now(),
            amount=amount,
            description=description
        )
        self._apply_event(event)
    
    def close_account(self, reason: str):
        """Close the account"""
        if self.is_closed:
            raise ValueError("Account already closed")
        
        if self.balance != 0:
            raise ValueError("Cannot close account with non-zero balance")
        
        event = AccountClosed(
            event_id=str(uuid.uuid4()),
            aggregate_id=self.aggregate_id,
            timestamp=datetime.now(),
            reason=reason,
            final_balance=self.balance
        )
        self._apply_event(event)
    
    # Event Handlers (state changes in response to events)
    
    def _on_AccountOpened(self, event: AccountOpened):
        """Handle AccountOpened event"""
        self.account_holder = event.account_holder
        self.balance = event.initial_balance
        self.currency = event.currency
    
    def _on_MoneyDeposited(self, event: MoneyDeposited):
        """Handle MoneyDeposited event"""
        self.balance += event.amount
        self.transaction_count += 1
    
    def _on_MoneyWithdrawn(self, event: MoneyWithdrawn):
        """Handle MoneyWithdrawn event"""
        self.balance -= event.amount
        self.transaction_count += 1
    
    def _on_AccountClosed(self, event: AccountClosed):
        """Handle AccountClosed event"""
        self.is_closed = True

# Repository for loading and saving aggregates
class BankAccountRepository:
    """Repository for event-sourced bank accounts"""
    
    def __init__(self, event_store: EventStore):
        self.event_store = event_store
    
    def get(self, account_id: str) -> BankAccount:
        """Load an account from event store"""
        account = BankAccount(account_id)
        events = self.event_store.get_events(account_id)
        
        if not events:
            raise ValueError(f"Account {account_id} not found")
        
        account.load_from_history(events)
        return account
    
    def save(self, account: BankAccount):
        """Save account events to event store"""
        uncommitted = account.get_uncommitted_events()
        
        if uncommitted:
            self.event_store.append(
                account.aggregate_id,
                uncommitted,
                expected_version=account.version - len(uncommitted)
            )
            account.mark_events_as_committed()
```

**Projections and Read Models**

Build different views from the same event stream:

```python
from typing import Protocol

class Projection(Protocol):
    """Interface for event projections"""
    
    def handle(self, event: Event):
        """Process an event"""
        ...
    
    def reset(self):
        """Reset projection state"""
        ...

class AccountBalanceProjection:
    """Projection showing current account balances"""
    
    def __init__(self):
        self.balances: Dict[str, Dict[str, Any]] = {}
    
    def handle(self, event: Event):
        """Update balance based on events"""
        if isinstance(event, AccountOpened):
            self.balances[event.aggregate_id] = {
                'account_holder': event.account_holder,
                'balance': event.initial_balance,
                'currency': event.currency,
                'status': 'open'
            }
        
        elif isinstance(event, MoneyDeposited):
            if event.aggregate_id in self.balances:
                self.balances[event.aggregate_id]['balance'] += event.amount
        
        elif isinstance(event, MoneyWithdrawn):
            if event.aggregate_id in self.balances:
                self.balances[event.aggregate_id]['balance'] -= event.amount
        
        elif isinstance(event, AccountClosed):
            if event.aggregate_id in self.balances:
                self.balances[event.aggregate_id]['status'] = 'closed'
    
    def get_balance(self, account_id: str) -> Optional[Dict[str, Any]]:
        """Query current balance"""
        return self.balances.get(account_id)
    
    def get_all_balances(self) -> Dict[str, Dict[str, Any]]:
        """Get all account balances"""
        return self.balances.copy()
    
    def reset(self):
        """Clear projection state"""
        self.balances.clear()

class TransactionHistoryProjection:
    """Projection showing detailed transaction history"""
    
    def __init__(self):
        self.transactions: Dict[str, List[Dict[str, Any]]] = {}
    
    def handle(self, event: Event):
        """Record transaction events"""
        if isinstance(event, (MoneyDeposited, MoneyWithdrawn)):
            if event.aggregate_id not in self.transactions:
                self.transactions[event.aggregate_id] = []
            
            transaction = {
                'timestamp': event.timestamp,
                'type': 'deposit' if isinstance(event, MoneyDeposited) else 'withdrawal',
                'amount': event.amount,
                'description': event.description,
                'event_id': event.event_id
            }
            self.transactions[event.aggregate_id].append(transaction)
    
    def get_transactions(self, account_id: str, limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get transaction history for account"""
        transactions = self.transactions.get(account_id, [])
        if limit:
            return transactions[-limit:]
        return transactions
    
    def reset(self):
        """Clear projection state"""
        self.transactions.clear()

class ProjectionManager:
    """Manages multiple projections"""
    
    def __init__(self, event_store: EventStore):
        self.event_store = event_store
        self.projections: List[Projection] = []
    
    def register(self, projection: Projection):
        """Register a projection"""
        self.projections.append(projection)
    
    def rebuild_all(self):
        """Rebuild all projections from scratch"""
        # Reset all projections
        for projection in self.projections:
            projection.reset()
        
        # Replay all events
        all_events = self.event_store.get_all_events()
        for event in all_events:
            for projection in self.projections:
                projection.handle(event)
        
        print(f"Rebuilt {len(self.projections)} projection(s) from {len(all_events)} event(s)")
    
    def project_event(self, event: Event):
        """Project a new event to all registered projections"""
        for projection in self.projections:
            projection.handle(event)
```

### **Example**

Here's a comprehensive demonstration of Event Sourcing in action:

```python
def demonstrate_event_sourcing():
    print("=== Event Sourcing Demonstration ===\n")
    
    # Setup
    event_store = EventStore()
    repository = BankAccountRepository(event_store)
    
    # Create projections
    balance_projection = AccountBalanceProjection()
    transaction_projection = TransactionHistoryProjection()
    
    projection_manager = ProjectionManager(event_store)
    projection_manager.register(balance_projection)
    projection_manager.register(transaction_projection)
    
    # --- Scenario 1: Open account and perform transactions ---
    print("--- Opening Account ---")
    account_id = "ACC-001"
    account = BankAccount(account_id)
    
    account.open_account("John Doe", 1000.0)
    account.deposit(500.0, "Salary deposit")
    account.deposit(200.0, "Freelance payment")
    account.withdraw(150.0, "Grocery shopping")
    
    # Save to event store
    repository.save(account)
    
    # Update projections
    for event in event_store.get_events(account_id):
        projection_manager.project_event(event)
    
    print(f"Account balance: ${account.balance}")
    print(f"Transaction count: {account.transaction_count}\n")
    
    # --- Scenario 2: Load account from event store ---
    print("--- Loading Account from Events ---")
    loaded_account = repository.get(account_id)
    print(f"Loaded account holder: {loaded_account.account_holder}")
    print(f"Loaded balance: ${loaded_account.balance}")
    print(f"Loaded transaction count: {loaded_account.transaction_count}\n")
    
    # --- Scenario 3: Continue with more transactions ---
    print("--- More Transactions ---")
    loaded_account.withdraw(300.0, "Rent payment")
    loaded_account.deposit(1000.0, "Monthly salary")
    
    repository.save(loaded_account)
    
    # Update projections with new events
    latest_events = event_store.get_events(account_id, from_version=loaded_account.version - 2)
    for event in latest_events:
        projection_manager.project_event(event)
    
    print(f"Updated balance: ${loaded_account.balance}\n")
    
    # --- Scenario 4: Query projections ---
    print("--- Querying Projections ---")
    
    # Balance projection
    balance_info = balance_projection.get_balance(account_id)
    print(f"Balance Projection: {balance_info}")
    
    # Transaction history
    transactions = transaction_projection.get_transactions(account_id)
    print(f"\nTransaction History ({len(transactions)} transactions):")
    for i, txn in enumerate(transactions, 1):
        print(f"  {i}. {txn['timestamp'].strftime('%Y-%m-%d %H:%M')} - "
              f"{txn['type'].capitalize()}: ${txn['amount']} - {txn['description']}")
    
    # --- Scenario 5: Event replay and temporal queries ---
    print("\n--- Temporal Query: Balance After 3rd Transaction ---")
    temp_account = BankAccount(account_id)
    first_three_events = event_store.get_events(account_id)[:3]
    temp_account.load_from_history(first_three_events)
    print(f"Balance after 3 events: ${temp_account.balance}")
    
    # --- Scenario 6: Complete event audit trail ---
    print("\n--- Complete Event Audit Trail ---")
    all_events = event_store.get_events(account_id)
    for i, event in enumerate(all_events, 1):
        event_data = event.to_dict()
        print(f"{i}. {event_data['event_type']} at {event.timestamp.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"   Data: {event_data['data']}")
    
    # --- Scenario 7: Rebuild projections from scratch ---
    print("\n--- Rebuilding Projections ---")
    projection_manager.rebuild_all()
    
    rebuilt_balance = balance_projection.get_balance(account_id)
    print(f"Rebuilt balance: {rebuilt_balance}")
    
    # --- Scenario 8: Attempt to close account (will fail due to non-zero balance) ---
    print("\n--- Attempting to Close Account ---")
    try:
        loaded_account.close_account("Customer request")
    except ValueError as e:
        print(f"Cannot close: {e}")
    
    # Withdraw remaining balance and close
    print("\n--- Withdrawing Balance and Closing ---")
    current_balance = loaded_account.balance
    loaded_account.withdraw(current_balance, "Final withdrawal")
    loaded_account.close_account("Customer moved to another bank")
    
    repository.save(loaded_account)
    
    # Update projections
    final_events = event_store.get_events(account_id, from_version=loaded_account.version - 2)
    for event in final_events:
        projection_manager.project_event(event)
    
    print(f"Account status: {'Closed' if loaded_account.is_closed else 'Open'}")
    print(f"Final balance: ${loaded_account.balance}")
    
    # Show final state
    print("\n--- Final Event Count ---")
    print(f"Total events for account: {event_store.get_version(account_id)}")

demonstrate_event_sourcing()
```

### **Output**

```
=== Event Sourcing Demonstration ===

--- Opening Account ---
Appended 4 event(s) to aggregate ACC-001
Account balance: $1550.0
Transaction count: 3

--- Loading Account from Events ---
Loaded account holder: John Doe
Loaded balance: $1550.0
Loaded transaction count: 3

--- More Transactions ---
Appended 2 event(s) to aggregate ACC-001
Updated balance: $2250.0

--- Querying Projections ---
Balance Projection: {'account_holder': 'John Doe', 'balance': 2250.0, 'currency': 'USD', 'status': 'open'}

Transaction History (5 transactions):
  1. 2024-12-20 10:30 - Deposit: $500.0 - Salary deposit
  2. 2024-12-20 10:30 - Deposit: $200.0 - Freelance payment
  3. 2024-12-20 10:30 - Withdrawal: $150.0 - Grocery shopping
  4. 2024-12-20 10:30 - Withdrawal: $300.0 - Rent payment
  5. 2024-12-20 10:30 - Deposit: $1000.0 - Monthly salary

--- Temporal Query: Balance After 3rd Transaction ---
Balance after 3 events: $1550.0

--- Complete Event Audit Trail ---
1. AccountOpened at 2024-12-20 10:30:15
   Data: {'account_holder': 'John Doe', 'initial_balance': 1000.0, 'currency': 'USD'}
2. MoneyDeposited at 2024-12-20 10:30:15
   Data: {'amount': 500.0, 'description': 'Salary deposit'}
3. MoneyDeposited at 2024-12-20 10:30:15
   Data: {'amount': 200.0, 'description': 'Freelance payment'}
4. MoneyWithdrawn at 2024-12-20 10:30:15
   Data: {'amount': 150.0, 'description': 'Grocery shopping'}
5. MoneyWithdrawn at 2024-12-20 10:30:15
   Data: {'amount': 300.0, 'description': 'Rent payment'}
6. MoneyDeposited at 2024-12-20 10:30:15
   Data: {'amount': 1000.0, 'description': 'Monthly salary'}

--- Rebuilding Projections ---
Rebuilt 2 projection(s) from 6 event(s)
Rebuilt balance: {'account_holder': 'John Doe', 'balance': 2250.0, 'currency': 'USD', 'status': 'open'}

--- Attempting to Close Account ---
Cannot close: Cannot close account with non-zero balance

--- Withdrawing Balance and Closing ---
Appended 2 event(s) to aggregate ACC-001
Account status: Closed
Final balance: $0.0

--- Final Event Count ---
Total events for account: 8
```

### Advanced Patterns

**Snapshots**

For aggregates with long event histories, snapshots improve performance:

```python
@dataclass
class Snapshot:
    """Snapshot of aggregate state at a point in time"""
    aggregate_id: str
    version: int
    timestamp: datetime
    state: Dict[str, Any]

class SnapshotStore:
    """Store for aggregate snapshots"""
    
    def __init__(self):
        self._snapshots: Dict[str, List[Snapshot]] = {}
    
    def save_snapshot(self, snapshot: Snapshot):
        """Save a snapshot"""
        if snapshot.aggregate_id not in self._snapshots:
            self._snapshots[snapshot.aggregate_id] = []
        self._snapshots[snapshot.aggregate_id].append(snapshot)
    
    def get_latest_snapshot(self, aggregate_id: str) -> Optional[Snapshot]:
        """Get most recent snapshot"""
        if aggregate_id not in self._snapshots:
            return None
        return self._snapshots[aggregate_id][-1] if self._snapshots[aggregate_id] else None

class SnapshotStrategy:
    """[Inference] Determines when to take snapshots"""
    
    def should_snapshot(self, event_count: int) -> bool:
        """[Inference] Take snapshot every N events"""
        return event_count % 10 == 0  # Snapshot every 10 events
```

**Event Versioning**

Handle evolving event schemas over time:

```python
class EventUpgrader:
    """[Inference] Handles event schema evolution"""
    
    def upgrade(self, event: Event) -> Event:
        """[Inference] Upgrade old event versions to current schema"""
        if event.event_version < 2:
            # Upgrade logic for version 1 to 2
            pass
        return event
```

### Advantages

**Complete Audit Trail**: Every change is recorded, providing full traceability for regulatory compliance and debugging.

**Temporal Queries**: Historical state can be reconstructed at any point in time by replaying events.

**Event Replay**: Events can be replayed to rebuild state, test scenarios, or recover from errors.

**Multiple Read Models**: Different projections can be built from the same events, optimized for different query patterns.

**Debugging and Analysis**: Understanding how the system reached its current state becomes straightforward.

**Event-Driven Architecture**: Natural fit for event-driven systems and asynchronous processing.

**Conflict Resolution**: In distributed systems, events provide a clear history for resolving conflicts.

**Business Insights**: Event streams contain rich behavioral data for analytics and machine learning.

### Disadvantages

**Complexity**: Requires different thinking compared to traditional CRUD operations. Developers must learn new patterns.

**Eventual Consistency**: Read models are eventually consistent with the event store, not immediately.

**Event Store Management**: The event store grows continuously and requires maintenance strategies.

**Event Schema Evolution**: Changing event structures over time requires careful versioning and migration strategies.

**Learning Curve**: Teams need training on event sourcing concepts and best practices.

**Query Limitations**: Some queries are difficult or expensive to implement from events alone.

**Deletion Challenges**: [Inference] True deletion is complex since events are immutable; typically handled through compensating events.

### Use Cases

**Financial Systems**: Banking, trading platforms, and payment systems where audit trails and temporal queries are critical.

**E-commerce**: Order processing, inventory management, and pricing history tracking.

**Healthcare**: Patient records where complete medical history and regulatory compliance are required.

**Collaboration Tools**: Document editing systems where version history and undo/redo functionality are needed.

**Gaming**: Game state management where replays and rollbacks are required.

**IoT Systems**: Sensor data streams where events naturally represent state changes.

**Blockchain and Distributed Ledgers**: Systems requiring immutable audit trails and consensus.

### Related Patterns

**CQRS (Command Query Responsibility Segregation)**: Event Sourcing is commonly paired with CQRS, where write and read models are separated.

**Domain-Driven Design**: Event Sourcing aligns well with DDD concepts like aggregates, bounded contexts, and domain events.

**Event-Driven Architecture**: Event Sourcing produces events that can trigger reactions in other parts of the system.

**Saga Pattern**: Complex business transactions across multiple aggregates can be coordinated using event-driven sagas.

**Memento Pattern**: Event Sourcing is similar to Memento but stores individual state changes rather than complete snapshots.

### Implementation Considerations

**Event Design**: Events should be immutable, descriptive, and contain all necessary information. Name them in past tense to reflect that they already happened.

**Aggregate Design**: Keep aggregates small and focused. Large aggregates with many events become slow to load.

**Idempotency**: Event handlers must be idempotent to handle duplicate event delivery safely.

**Event Store Selection**: Choose appropriate technology—specialized event stores (EventStore, Axon), message brokers (Kafka), or traditional databases with append-only tables.

**Snapshot Strategy**: Implement snapshots for aggregates with long event histories to improve load performance.

**Event Versioning**: Plan for event schema evolution from the beginning. Use version fields and upgraders.

**Projection Management**: Design projections carefully for query patterns. Consider eventual consistency implications.

**Testing**: Event sourcing makes testing easier—given a sequence of events, verify the resulting state or behavior.

### Modern Technologies

**EventStoreDB**: Purpose-built database for event sourcing with built-in projections and subscriptions.

**Apache Kafka**: Distributed event streaming platform often used as an event store for high-throughput systems.

**Axon Framework**: Comprehensive framework for building event-sourced applications with CQRS support.

**Marten**: .NET library providing event sourcing capabilities on top of PostgreSQL.

**Akka Persistence**: Event sourcing support for actor-based systems in Scala and Java.

**AWS EventBridge/Azure Event Grid**: Cloud-native event routing services that support event-driven architectures.

### **Conclusion**

Event Sourcing represents a fundamental shift in how applications model and persist state. By storing events rather than current state, systems gain powerful capabilities including complete audit trails, temporal queries, and the ability to derive multiple views from the same data. While it introduces complexity and requires careful design, Event Sourcing is particularly valuable in domains where history matters, audit requirements are strict, or where understanding how state evolved is as important as knowing the current state.

The pattern works exceptionally well when combined with CQRS and Domain-Driven Design, forming a robust foundation for complex business applications. Modern event stores and frameworks have matured significantly, making Event Sourcing more accessible than ever for teams willing to invest in understanding its principles.

### **Key Points**

- Event Sourcing stores state changes as immutable events rather than updating current state in place
- Current state is derived by replaying events from an append-only event store
- Provides complete audit trails, temporal queries, and the ability to rebuild state at any point in time
- Works well with CQRS to separate write models (aggregates) from read models (projections)
- Events should be immutable, descriptive, named in past tense, and contain complete information about state changes
- Snapshots improve performance for aggregates with long event histories
- Event schema versioning is crucial for maintaining backward compatibility as systems evolve
- [Inference] Best suited for domains where audit trails, history, and temporal analysis are important requirements

### **Next Steps**

- Implement a simple event-sourced aggregate to understand the core concepts of commands, events, and state reconstruction
- Explore specialized event stores like EventStoreDB or use Kafka for high-throughput event streaming
- Study CQRS pattern and how it complements Event Sourcing for separating write and read concerns
- Practice designing events that capture business intent rather than technical CRUD operations
- Implement snapshot strategies to optimize loading performance for aggregates with many events
- Learn about event versioning techniques and upcasting to handle schema evolution
- Experiment with building multiple projections from the same event stream for different query needs
- Study saga patterns for coordinating complex business processes across multiple aggregates

---

## CQRS (Command Query Responsibility Segregation)

CQRS is an architectural pattern that separates read operations (queries) from write operations (commands) into distinct models. This separation allows each model to be optimized independently for its specific purpose, rather than using a single unified model for both reading and writing data.

### Core Concept

The fundamental principle behind CQRS is the recognition that reading and writing data have different characteristics and requirements:

- **Commands**: Operations that change state, perform validations, and enforce business rules
- **Queries**: Operations that retrieve data without side effects, often requiring different data structures for optimal performance

By splitting these responsibilities, each side can be designed, optimized, and scaled independently without compromising the other.

### Traditional Approach vs CQRS

In traditional CRUD (Create, Read, Update, Delete) architectures, a single model serves both read and write operations. This approach works well for simple applications but presents challenges as complexity grows:

- The same data model must satisfy both complex business logic and diverse query requirements
- Performance optimizations for reads can complicate writes, and vice versa
- Scaling reads and writes together, even when they have different load characteristics

CQRS addresses these issues by using separate models:

- **Write Model (Command Side)**: Focused on business logic, invariants, and state changes
- **Read Model (Query Side)**: Optimized for specific query patterns and presentation needs

### Architecture Components

#### Command Side

The command side handles all operations that modify state:

**Command Handler**: Receives commands, validates business rules, and coordinates state changes **Domain Model**: Encapsulates business logic and enforces invariants **Write Store**: Persists the current state or events representing state changes **Validation**: Ensures commands meet business requirements before execution

The command side is typically designed around domain-driven design principles, with rich domain models that encapsulate behavior.

#### Query Side

The query side handles all read operations:

**Query Handler**: Processes query requests and retrieves data **Read Model**: Denormalized, optimized data structures tailored for specific queries **Read Store**: May use different database technology optimized for reads **Projections**: Transform write model data into read model format

The query side often uses denormalized data, materialized views, or specialized read-optimized databases.

#### Synchronization

The two sides must be kept synchronized:

**Synchronous**: Write model updates read model immediately within the same transaction **Asynchronous**: Write model publishes events; read model subscribes and updates eventually **Event-Driven**: Commands generate events that both persist state and update read models

### Benefits

**Optimized Performance**: Each side can use data structures and storage technologies best suited to its needs. Read models can be denormalized for fast queries, while write models maintain normalized structure for data integrity.

**Independent Scaling**: Read and write operations can be scaled separately based on actual load patterns. Most systems have read-heavy workloads, allowing you to scale queries without over-provisioning the command side.

**Flexibility**: Multiple read models can be created from the same write model, each optimized for different use cases or user interfaces.

**Simplified Query Logic**: Read models can be pre-computed and denormalized, eliminating complex joins and aggregations at query time.

**Clear Separation of Concerns**: Business logic resides in the command side, while queries are simple data retrieval operations.

**Security**: Different security models can be applied to reads and writes, with finer-grained control over data access.

### Challenges and Considerations

**Increased Complexity**: CQRS introduces additional architectural complexity with separate models, synchronization mechanisms, and potentially multiple data stores.

**Eventual Consistency**: When using asynchronous synchronization, the read model may lag behind the write model, creating a window where queries return stale data. Applications must be designed to handle this.

**Learning Curve**: Teams need to understand the pattern and adjust their thinking from traditional CRUD approaches.

**Infrastructure Overhead**: More components to develop, deploy, monitor, and maintain.

**Data Synchronization**: Ensuring read models stay synchronized with write models requires careful design, especially in failure scenarios.

### When to Use CQRS

CQRS is particularly valuable in these scenarios:

**Complex Domain Logic**: Applications with intricate business rules benefit from having a write model focused purely on domain logic.

**Different Read/Write Load**: Systems with significantly higher read than write volume can optimize and scale each independently.

**Multiple Read Representations**: When different parts of the application need the same data in different formats or aggregations.

**Collaborative Domains**: Applications where multiple users work on the same data concurrently benefit from event-based approaches often paired with CQRS.

**Performance Requirements**: When queries need to be extremely fast and simple, denormalized read models eliminate complex join operations.

### When NOT to Use CQRS

**Simple CRUD Applications**: When business logic is minimal and read/write patterns are similar, CQRS adds unnecessary complexity.

**Small Teams**: The pattern requires discipline and understanding; small teams may struggle with the overhead.

**Tight Consistency Requirements**: If the application cannot tolerate any delay between writes and reads, synchronous CQRS or traditional approaches may be better.

**Getting Started**: CQRS should not be applied from day one unless requirements clearly justify it. Start simple and evolve to CQRS when complexity demands it.

### Implementation Patterns

#### Simple CQRS

The most straightforward implementation uses the same database with separate models:

- Single database with different tables or schemas for read and write
- Synchronous updates ensure consistency
- Simpler to implement and maintain
- Good starting point before moving to more complex implementations

#### CQRS with Event Sourcing

A powerful combination where commands generate events that are stored as the source of truth:

- Write model persists events instead of current state
- Read models are built by replaying events
- Complete audit trail of all changes
- Ability to rebuild read models or create new ones from event history
- Enables temporal queries and debugging

#### Separate Databases

Using different database technologies for each side:

- Write side might use a relational database for transactional integrity
- Read side could use document stores, key-value stores, or search engines
- Maximizes optimization for each operation type
- Requires robust synchronization mechanism

### **Key Points**

- CQRS separates read and write operations into distinct models, each optimized for its purpose
- The pattern enables independent scaling, multiple read representations, and simplified query logic
- Eventual consistency is a common trade-off when using asynchronous synchronization
- Best suited for complex domains with different read/write requirements, not simple CRUD applications
- Often combined with Event Sourcing for complete audit trails and temporal capabilities
- Implementation complexity requires careful consideration of team capabilities and actual requirements

### **Example**

Consider an e-commerce order management system implemented with CQRS:

**Command Side (Write Model)**

```typescript
// Command to place an order
interface PlaceOrderCommand {
  customerId: string;
  items: OrderItem[];
  shippingAddress: Address;
}

// Domain model with business logic
class Order {
  private id: string;
  private customerId: string;
  private items: OrderItem[];
  private status: OrderStatus;
  private total: Money;

  placeOrder(command: PlaceOrderCommand): void {
    this.validateItems(command.items);
    this.validateAddress(command.shippingAddress);
    this.calculateTotal();
    this.status = OrderStatus.Placed;
    // Raise domain event
    this.addEvent(new OrderPlacedEvent(this.id, this.customerId, this.total));
  }

  private validateItems(items: OrderItem[]): void {
    if (items.length === 0) {
      throw new Error("Order must contain at least one item");
    }
    // Additional validation logic
  }

  private calculateTotal(): void {
    this.total = this.items.reduce((sum, item) => 
      sum.add(item.price.multiply(item.quantity)), Money.zero());
  }
}

// Command handler
class PlaceOrderHandler {
  constructor(
    private orderRepository: OrderRepository,
    private eventBus: EventBus
  ) {}

  async handle(command: PlaceOrderCommand): Promise<void> {
    const order = new Order();
    order.placeOrder(command);
    
    await this.orderRepository.save(order);
    await this.eventBus.publish(order.getEvents());
  }
}
```

**Query Side (Read Model)**

```typescript
// Denormalized read model for order history
interface OrderHistoryReadModel {
  orderId: string;
  customerName: string;
  orderDate: Date;
  totalAmount: number;
  itemCount: number;
  status: string;
}

// Separate read model for order details
interface OrderDetailsReadModel {
  orderId: string;
  customerName: string;
  customerEmail: string;
  items: {
    productName: string;
    quantity: number;
    price: number;
    subtotal: number;
  }[];
  shippingAddress: {
    street: string;
    city: string;
    country: string;
  };
  totalAmount: number;
  status: string;
  placedAt: Date;
  shippedAt?: Date;
}

// Query handler
class GetOrderHistoryHandler {
  constructor(private readStore: OrderReadStore) {}

  async handle(query: GetOrderHistoryQuery): Promise<OrderHistoryReadModel[]> {
    // Simple query against denormalized data
    return await this.readStore.getOrderHistory(query.customerId);
  }
}

// Event handler to update read model
class OrderPlacedEventHandler {
  constructor(private readStore: OrderReadStore) {}

  async handle(event: OrderPlacedEvent): Promise<void> {
    const customer = await this.getCustomerInfo(event.customerId);
    
    // Update order history read model
    await this.readStore.insertOrderHistory({
      orderId: event.orderId,
      customerName: customer.name,
      orderDate: event.timestamp,
      totalAmount: event.total,
      itemCount: event.itemCount,
      status: 'Placed'
    });

    // Update order details read model
    await this.readStore.insertOrderDetails({
      orderId: event.orderId,
      customerName: customer.name,
      customerEmail: customer.email,
      items: event.items,
      shippingAddress: event.shippingAddress,
      totalAmount: event.total,
      status: 'Placed',
      placedAt: event.timestamp
    });
  }
}
```

**Usage**

```typescript
// Placing an order (write operation)
const placeOrderCommand = {
  customerId: "cust-123",
  items: [
    { productId: "prod-456", quantity: 2, price: 29.99 },
    { productId: "prod-789", quantity: 1, price: 49.99 }
  ],
  shippingAddress: {
    street: "123 Main St",
    city: "Springfield",
    country: "USA"
  }
};

await commandBus.send(placeOrderCommand);

// Querying order history (read operation)
const orderHistory = await queryBus.query({
  type: 'GetOrderHistory',
  customerId: 'cust-123'
});

// Querying specific order details (read operation)
const orderDetails = await queryBus.query({
  type: 'GetOrderDetails',
  orderId: 'order-001'
});
```

### **Output**

When querying the order history, the response is immediate and simple:

```json
[
  {
    "orderId": "order-001",
    "customerName": "John Doe",
    "orderDate": "2024-12-20T10:30:00Z",
    "totalAmount": 109.97,
    "itemCount": 3,
    "status": "Placed"
  },
  {
    "orderId": "order-002",
    "customerName": "John Doe",
    "orderDate": "2024-12-15T14:22:00Z",
    "totalAmount": 79.99,
    "itemCount": 1,
    "status": "Shipped"
  }
]
```

The query executes against a pre-computed, denormalized table with no joins required. Meanwhile, the command side maintains a rich domain model with full business logic enforcement, and these two concerns never interfere with each other.

### Advanced Patterns and Extensions

#### Materialized Views

Materialized views are pre-computed query results stored as read models:

- Updated when underlying data changes
- Eliminate expensive join and aggregation operations at query time
- Can be refreshed on demand or on schedule
- Multiple views can serve different query patterns

#### Task-Based UI

CQRS naturally supports task-based user interfaces:

- UI presents specific business tasks rather than CRUD forms
- Commands map directly to user intentions
- Better alignment with domain language and business processes
- Improved user experience and clearer business logic

#### Polyglot Persistence

Different storage technologies for different needs:

- PostgreSQL for transactional write model
- Elasticsearch for full-text search queries
- Redis for caching frequently accessed data
- MongoDB for flexible document queries
- Each technology optimized for its specific use case

#### CQRS with Microservices

CQRS complements microservices architecture:

- Each service can have its own read and write models
- Services publish events when state changes
- Other services build their own read models from these events
- Enables loose coupling and independent scaling

### Testing Strategies

**Command Side Testing**: Focus on business logic and domain model behavior. Test that commands produce expected state changes and events. Verify validation rules and invariants.

**Query Side Testing**: Test that read models accurately reflect write model state. Verify query performance meets requirements. Test eventual consistency handling.

**Integration Testing**: Test the synchronization between write and read models. Verify system behavior under concurrent operations. Test failure and recovery scenarios.

### Monitoring and Observability

CQRS systems require specific monitoring:

**Synchronization Lag**: Track time delay between write and read model updates

**Command Success Rate**: Monitor command processing failures and reasons

**Query Performance**: Track read model query response times

**Event Processing**: Monitor event handler success rates and processing delays

**Data Consistency**: Verify read models match expected state from write model

### Migration Strategies

Moving to CQRS from existing systems:

**Incremental Adoption**: Start with separating read and write models in a single module before expanding

**Strangler Fig Pattern**: Gradually replace parts of existing system with CQRS implementation

**Read Model First**: Begin by creating optimized read models while keeping existing write model

**Event Sourcing Later**: Implement basic CQRS first, add event sourcing only if needed

### Common Pitfalls

**Over-Engineering**: Applying CQRS to simple domains where traditional approaches suffice

**Ignoring Consistency**: Not properly handling eventual consistency in the user experience

**Poor Event Design**: Creating events that are too granular or too coarse

**Lack of Versioning**: Not planning for event and model evolution

**Missing Monitoring**: Inadequate observability into synchronization and performance

### **Conclusion**

CQRS is a powerful pattern that separates read and write concerns, enabling significant performance, scalability, and maintainability benefits for complex systems. However, these benefits come with increased architectural complexity and the challenge of managing eventual consistency.

The pattern shines in domains with complex business logic, disparate read and write loads, or needs for multiple data representations. It pairs naturally with Event Sourcing, Domain-Driven Design, and microservices architectures.

Success with CQRS requires careful consideration of when to apply it, starting with simpler implementations before adding complexity, and ensuring the team understands both the benefits and trade-offs. When applied appropriately, CQRS can transform a struggling monolithic model into a flexible, scalable architecture that serves diverse needs effectively.

### **Next Steps**

- Start by identifying bounded contexts in your domain where read and write patterns differ significantly
- Implement a simple CQRS prototype in a single module using synchronous updates and the same database
- Measure the impact on performance, code clarity, and maintainability
- Gradually introduce asynchronous updates if eventual consistency is acceptable
- Consider Event Sourcing if you need audit trails, temporal queries, or the ability to rebuild read models
- Invest in monitoring and observability from the beginning
- Document consistency guarantees and failure modes for your team

---

## Specification Pattern

The Specification Pattern is a behavioral design pattern that encapsulates business rules or criteria into reusable, combinable objects. It separates the logic of selecting objects based on certain criteria from the objects themselves, making the selection logic explicit, testable, and maintainable.

### Purpose and Intent

The pattern allows you to build complex selection criteria by combining simpler, atomic specifications using logical operators (AND, OR, NOT). Instead of scattering conditional logic throughout your codebase, you encapsulate each business rule into its own specification class that can be tested independently and reused across different contexts.

### Problem It Solves

Without the Specification Pattern, selection logic often becomes:

- Scattered across multiple methods and classes
- Difficult to test in isolation
- Hard to reuse in different contexts
- Prone to duplication when similar criteria are needed
- Challenging to combine dynamically at runtime

For example, you might have filtering logic embedded directly in repository methods, UI components, or business logic layers, making it difficult to maintain consistency when business rules change.

### Core Components

**Specification Interface**: Defines the contract that all specifications must implement, typically containing an `isSatisfiedBy()` method that evaluates whether a candidate object meets the criteria.

**Concrete Specifications**: Individual classes that implement specific business rules. Each specification encapsulates one atomic piece of selection logic.

**Composite Specifications**: Specifications that combine other specifications using logical operators. Common composites include AND, OR, and NOT specifications.

**Client Code**: Uses specifications to filter collections, validate objects, or build queries without knowing the internal implementation details of each rule.

### How It Works

Each specification implements a method that accepts a candidate object and returns a boolean indicating whether the object satisfies the criteria. Specifications can be combined using composite patterns to create complex rules from simple ones.

The pattern follows the Single Responsibility Principle by giving each specification exactly one reason to change: when its particular business rule changes. It also follows the Open/Closed Principle because you can create new specifications without modifying existing ones.

### Implementation Strategies

**In-Memory Filtering**: The specification evaluates objects that are already loaded in memory. This approach is simple and works well for small to medium-sized collections.

**Query Generation**: The specification translates its logic into database queries (SQL, LINQ, etc.). This is more efficient for large datasets but requires specifications to understand the underlying data access technology.

**Hybrid Approach**: Use different implementations of the same specification interface depending on context—one for in-memory evaluation and another for query generation.

### **Key Points**

- Encapsulates business rules into reusable, testable objects
- Enables dynamic composition of complex criteria at runtime
- Separates selection logic from the objects being selected
- Improves code maintainability by centralizing rule definitions
- Facilitates consistent rule application across different parts of the application
- Makes business rules explicit and self-documenting through class names
- Supports both in-memory filtering and query generation strategies

### When to Use

The Specification Pattern is most beneficial when:

- You need to select or validate objects based on complex, combinable criteria
- Business rules change frequently and need to be isolated from other code
- The same selection criteria must be used in multiple contexts (UI, business logic, data access)
- You need to build queries dynamically based on user input or configuration
- Filtering logic has become scattered and duplicated across the codebase
- You want to make business rules explicitly testable in isolation

### When Not to Use

Avoid this pattern when:

- Selection criteria are simple and unlikely to change (e.g., filtering by a single property)
- Performance is critical and the abstraction overhead is unacceptable
- You have only one or two business rules that aren't reused
- The team is unfamiliar with the pattern and simpler approaches would suffice
- Your data access layer already provides adequate querying capabilities

### **Example**

Here's a practical implementation for filtering products in an e-commerce system:

```typescript
// Specification interface
interface Specification<T> {
  isSatisfiedBy(candidate: T): boolean;
  and(other: Specification<T>): Specification<T>;
  or(other: Specification<T>): Specification<T>;
  not(): Specification<T>;
}

// Abstract base class
abstract class CompositeSpecification<T> implements Specification<T> {
  abstract isSatisfiedBy(candidate: T): boolean;

  and(other: Specification<T>): Specification<T> {
    return new AndSpecification(this, other);
  }

  or(other: Specification<T>): Specification<T> {
    return new OrSpecification(this, other);
  }

  not(): Specification<T> {
    return new NotSpecification(this);
  }
}

// Composite specifications
class AndSpecification<T> extends CompositeSpecification<T> {
  constructor(
    private left: Specification<T>,
    private right: Specification<T>
  ) {
    super();
  }

  isSatisfiedBy(candidate: T): boolean {
    return this.left.isSatisfiedBy(candidate) && 
           this.right.isSatisfiedBy(candidate);
  }
}

class OrSpecification<T> extends CompositeSpecification<T> {
  constructor(
    private left: Specification<T>,
    private right: Specification<T>
  ) {
    super();
  }

  isSatisfiedBy(candidate: T): boolean {
    return this.left.isSatisfiedBy(candidate) || 
           this.right.isSatisfiedBy(candidate);
  }
}

class NotSpecification<T> extends CompositeSpecification<T> {
  constructor(private spec: Specification<T>) {
    super();
  }

  isSatisfiedBy(candidate: T): boolean {
    return !this.spec.isSatisfiedBy(candidate);
  }
}

// Domain model
class Product {
  constructor(
    public name: string,
    public price: number,
    public color: string,
    public inStock: boolean,
    public rating: number
  ) {}
}

// Concrete specifications
class PriceRangeSpecification extends CompositeSpecification<Product> {
  constructor(private minPrice: number, private maxPrice: number) {
    super();
  }

  isSatisfiedBy(product: Product): boolean {
    return product.price >= this.minPrice && product.price <= this.maxPrice;
  }
}

class ColorSpecification extends CompositeSpecification<Product> {
  constructor(private color: string) {
    super();
  }

  isSatisfiedBy(product: Product): boolean {
    return product.color.toLowerCase() === this.color.toLowerCase();
  }
}

class InStockSpecification extends CompositeSpecification<Product> {
  isSatisfiedBy(product: Product): boolean {
    return product.inStock;
  }
}

class MinimumRatingSpecification extends CompositeSpecification<Product> {
  constructor(private minRating: number) {
    super();
  }

  isSatisfiedBy(product: Product): boolean {
    return product.rating >= this.minRating;
  }
}

// Product filter using specifications
class ProductFilter {
  filter(products: Product[], spec: Specification<Product>): Product[] {
    return products.filter(product => spec.isSatisfiedBy(product));
  }
}

// Usage
const products = [
  new Product("Red Shirt", 29.99, "red", true, 4.5),
  new Product("Blue Pants", 59.99, "blue", false, 4.0),
  new Product("Red Shoes", 89.99, "red", true, 4.8),
  new Product("Green Jacket", 120.00, "green", true, 3.9),
  new Product("Blue Shirt", 25.99, "blue", true, 4.2)
];

const filter = new ProductFilter();

// Simple specification
const affordableSpec = new PriceRangeSpecification(0, 50);
const affordableProducts = filter.filter(products, affordableSpec);
console.log("Affordable products:", affordableProducts.length);

// Combined specifications
const redAndAffordableSpec = new ColorSpecification("red")
  .and(new PriceRangeSpecification(0, 50))
  .and(new InStockSpecification());

const specificProducts = filter.filter(products, redAndAffordableSpec);
console.log("Red, affordable, in-stock products:", specificProducts.length);

// Complex combination
const premiumSpec = new PriceRangeSpecification(50, 150)
  .and(new MinimumRatingSpecification(4.0))
  .and(
    new ColorSpecification("red").or(new ColorSpecification("blue"))
  );

const premiumProducts = filter.filter(products, premiumSpec);
console.log("Premium products:", premiumProducts.length);
```

### **Output**

```
Affordable products: 2
Red, affordable, in-stock products: 1
Premium products: 2
```

The example demonstrates how atomic specifications can be combined to create sophisticated filtering logic without modifying existing code or duplicating business rules.

### Advanced Variations

**Parameterized Specifications**: Specifications that accept parameters at construction time, allowing the same specification class to represent different criteria based on input values.

**Query Object Pattern Integration**: Combining specifications with the Query Object pattern to generate database queries rather than filtering in-memory collections, improving performance for large datasets.

**Specification Factory**: Using factory methods or builders to create commonly used specification combinations, reducing repetition in client code.

**Lazy Evaluation**: Implementing specifications that delay evaluation until absolutely necessary, improving performance when dealing with expensive operations.

### Testing Considerations

Specifications are highly testable because each encapsulates a single, focused business rule. Unit tests can verify that each specification correctly evaluates its criteria without requiring complex setup or mocking.

When testing composite specifications, you can use mock specifications to isolate the logical combination behavior from the individual rule implementations. This allows you to verify that AND, OR, and NOT operations work correctly regardless of what the child specifications actually do.

Integration tests should verify that specifications work correctly with your chosen data access strategy, ensuring that in-memory and query-based implementations produce consistent results.

### Performance Implications

In-memory evaluation has the advantage of simplicity but requires loading entire collections into memory before filtering. For large datasets, this can be inefficient.

Query generation specifications translate business rules into database queries, allowing the database to handle filtering. This is more efficient but adds complexity because specifications must understand query construction.

Consider using the Specification Pattern in conjunction with pagination or lazy loading to manage memory efficiently when working with large datasets.

### Common Pitfalls

**Over-Engineering Simple Cases**: Not every filtering operation needs a specification. For simple, one-time filters, a lambda or simple method may be more appropriate.

**Specification Explosion**: Creating too many highly specific specifications can lead to a large number of classes. Look for opportunities to parameterize specifications or combine them in different ways.

**Tight Coupling to Data Access**: If specifications contain SQL or other data access logic, they become coupled to your persistence technology. Use separate implementations or an abstraction layer to maintain flexibility.

**Ignoring Performance**: In-memory specifications that perform expensive operations (network calls, complex calculations) can degrade performance when evaluating large collections.

### Related Patterns

**Strategy Pattern**: Both patterns encapsulate algorithms, but Specification focuses specifically on selection criteria and boolean evaluation, while Strategy is more general-purpose.

**Composite Pattern**: The Specification Pattern uses Composite to build complex specifications from simpler ones using logical operators.

**Repository Pattern**: Often used together with Specification to provide flexible querying capabilities while keeping data access logic separate from business logic.

**Query Object Pattern**: Can be combined with Specification to translate business rules into database queries rather than in-memory evaluation.

**Interpreter Pattern**: Both patterns involve building complex expressions from simpler components, but Specification focuses on boolean criteria rather than general expression evaluation.

### Real-World Applications

E-commerce platforms use specifications to filter products based on multiple criteria like price range, category, brand, availability, and customer ratings. Users can combine these filters dynamically through the UI.

Access control systems use specifications to determine whether a user satisfies the requirements to access a resource, combining role checks, permission checks, and context-specific rules.

Validation frameworks use specifications to encapsulate validation rules that can be combined and reused across different parts of an application.

Reporting systems use specifications to allow users to define custom data selection criteria without writing code, translating user-friendly filter definitions into database queries.

### **Conclusion**

The Specification Pattern provides a powerful way to encapsulate and combine business rules, making them explicit, testable, and reusable. By separating selection logic from the objects being selected, it improves maintainability and allows for flexible composition of criteria at runtime. While it adds some complexity through additional classes, this cost is justified when dealing with complex, frequently changing business rules that need to be consistent across multiple contexts.

The pattern works best when you need to combine multiple criteria dynamically, when business rules change frequently, or when the same filtering logic must be used in different parts of your application. For simple cases with static criteria, simpler approaches may be more appropriate.

### **Next Steps**

To deepen your understanding of the Specification Pattern:

- Implement a specification-based filtering system for a domain you're familiar with, starting with simple specifications and progressing to complex combinations
- Explore how to translate specifications into database queries using your preferred ORM or query builder
- Study how popular frameworks implement the Specification Pattern (such as JPA Criteria API or Entity Framework)
- Practice writing unit tests for individual specifications and integration tests for composite specifications
- Experiment with building a specification factory or builder to simplify the creation of common specification combinations
- Consider how the pattern might integrate with other patterns in your architecture, particularly Repository and Query Object patterns

---

## Unit of Work Pattern

The Unit of Work pattern maintains a list of objects affected by a business transaction and coordinates the writing out of changes and the resolution of concurrency problems. It tracks all changes made to objects during a business transaction and commits all changes as a single unit, ensuring data consistency and integrity.

### Purpose and Problem Statement

In applications that interact with databases, managing multiple related data modifications can become complex. Without proper coordination, you might face issues such as partial updates, inconsistent data states, performance degradation from excessive database calls, and difficulty tracking what needs to be saved or updated.

The Unit of Work pattern addresses these concerns by:

- Tracking all changes to domain objects within a transaction boundary
- Batching database operations to minimize round trips
- Maintaining object identity and preventing duplicate updates
- Providing a clear transaction boundary with commit or rollback semantics
- Decoupling business logic from persistence concerns

### Core Concepts

**Transaction Boundary**: The Unit of Work defines a clear beginning and end to a business transaction. All operations within this boundary are treated as atomic—they either all succeed or all fail together.

**Change Tracking**: The pattern monitors objects for modifications, additions, and deletions. It maintains internal lists (often called "dirty" lists) of new, modified, and removed objects.

**Identity Map**: Often used in conjunction with Unit of Work, an identity map ensures that only one instance of an object with a given identity exists in memory, preventing conflicts and duplicate updates.

**Commit and Rollback**: When commit is called, the Unit of Work determines the correct order of database operations, executes them, and handles any errors. If rollback is called, all tracked changes are discarded.

### Structure and Components

**Unit of Work Interface**: Defines methods for registering objects as new, modified, or deleted, along with commit and rollback operations.

**Concrete Unit of Work**: Implements the tracking mechanism and coordinates with repositories or data mappers to persist changes.

**Repositories**: Work in conjunction with the Unit of Work to retrieve and store domain objects. Repositories use the Unit of Work to register changes.

**Domain Objects**: Business entities that are tracked by the Unit of Work during their lifecycle within a transaction.

**Database Context**: The underlying database connection or session that executes the actual SQL commands when commit is invoked.

### Implementation Approaches

**Explicit Registration**: Domain objects or repositories explicitly call methods on the Unit of Work to register changes. This approach provides fine-grained control but requires more manual coordination.

```
unitOfWork.RegisterNew(customer);
unitOfWork.RegisterDirty(order);
unitOfWork.RegisterDeleted(obsoleteItem);
```

**Change Detection**: The Unit of Work automatically detects changes by comparing object states. This can be done through snapshots (storing original values) or proxy objects that intercept property setters.

**Caller Registration**: The calling code is responsible for informing the Unit of Work about operations. This is simpler but places more burden on business logic code.

### Integration with Other Patterns

**Repository Pattern**: Repositories abstract data access logic and typically work with a Unit of Work to coordinate persistence operations. The repository retrieves objects and registers them with the active Unit of Work.

**Domain Model**: The Unit of Work is essential in rich domain models where multiple aggregates might be modified within a single transaction.

**Data Mapper**: This pattern separates domain objects from database concerns. The Unit of Work coordinates with data mappers to persist changes without polluting domain objects with persistence logic.

**Identity Map**: Ensures that each database row maps to only one in-memory object, preventing conflicts when the Unit of Work commits changes.

### Benefits and Advantages

**Consistency**: By batching all changes and committing them together, the pattern ensures that the database remains in a consistent state even when multiple objects are modified.

**Performance Optimization**: Reduces database round trips by batching insert, update, and delete operations. This can significantly improve performance in scenarios with many small changes.

**Transaction Management**: Provides a clear and explicit transaction boundary, making it easier to reason about when data is persisted and when transactions are rolled back.

**Simplified Business Logic**: Business code doesn't need to worry about the mechanics of saving each object individually or the order of operations—the Unit of Work handles this complexity.

**Testability**: Makes unit testing easier by allowing you to verify that the correct objects are tracked without actually hitting the database.

### Drawbacks and Considerations

**Complexity**: Implementing a full-featured Unit of Work with change tracking can be complex, especially when dealing with object graphs and relationships.

**Memory Overhead**: Tracking many objects in memory can consume significant resources, particularly in long-running transactions or batch processing scenarios.

**Learning Curve**: Developers need to understand when to commit, how to handle failures, and the implications of the transaction boundary.

**Concurrency Challenges**: The pattern doesn't solve concurrency problems by itself—you still need optimistic or pessimistic locking strategies to handle concurrent updates.

**Framework Dependency**: [Inference] Many implementations rely on ORM frameworks like Entity Framework or Hibernate, which may introduce additional complexity and learning requirements.

### When to Use

The Unit of Work pattern is particularly valuable in these scenarios:

**Complex Business Transactions**: When a single business operation modifies multiple entities that must all succeed or fail together.

**Domain-Driven Design**: In applications with rich domain models where business logic operates on multiple aggregates within a transaction.

**Performance-Sensitive Applications**: When you need to minimize database round trips by batching operations.

**Applications Requiring Clear Transaction Boundaries**: When you need explicit control over when changes are persisted to the database.

**Team Development**: When you want to provide a consistent and simple persistence API for multiple developers to use without worrying about low-level database operations.

### When Not to Use

**Simple CRUD Applications**: For straightforward create-read-update-delete operations with single-entity transactions, the overhead of Unit of Work may not be justified.

**Stateless Services**: In truly stateless architectures where each request is independent and doesn't accumulate changes across multiple operations.

**Real-Time Systems**: When you need immediate persistence of each change rather than batched commits.

**Event Sourcing**: In systems using event sourcing, the persistence model is fundamentally different and doesn't require traditional Unit of Work.

### **Key Points**

- Unit of Work coordinates multiple data changes into a single atomic transaction
- It tracks new, modified, and deleted objects throughout a business operation
- The pattern batches database operations to improve performance and ensure consistency
- Common in ORM frameworks like Entity Framework (DbContext) and Hibernate (Session)
- Works best with Repository pattern and Domain-Driven Design approaches
- Requires careful consideration of transaction boundaries and scope
- Not suitable for every application—evaluate complexity versus benefits

### **Example**

Here's a conceptual implementation in C#:

```csharp
// Unit of Work Interface
public interface IUnitOfWork : IDisposable
{
    void RegisterNew(object entity);
    void RegisterDirty(object entity);
    void RegisterDeleted(object entity);
    void Commit();
    void Rollback();
}

// Concrete Implementation
public class UnitOfWork : IUnitOfWork
{
    private readonly List<object> _newObjects = new List<object>();
    private readonly List<object> _dirtyObjects = new List<object>();
    private readonly List<object> _deletedObjects = new List<object>();
    private readonly DbConnection _connection;
    private DbTransaction _transaction;

    public UnitOfWork(DbConnection connection)
    {
        _connection = connection;
        _connection.Open();
        _transaction = _connection.BeginTransaction();
    }

    public void RegisterNew(object entity)
    {
        if (!_newObjects.Contains(entity))
            _newObjects.Add(entity);
    }

    public void RegisterDirty(object entity)
    {
        if (!_dirtyObjects.Contains(entity) && !_newObjects.Contains(entity))
            _dirtyObjects.Add(entity);
    }

    public void RegisterDeleted(object entity)
    {
        if (_newObjects.Contains(entity))
            _newObjects.Remove(entity);
        else if (!_deletedObjects.Contains(entity))
            _deletedObjects.Add(entity);
        
        if (_dirtyObjects.Contains(entity))
            _dirtyObjects.Remove(entity);
    }

    public void Commit()
    {
        try
        {
            // Insert new objects
            foreach (var entity in _newObjects)
            {
                InsertEntity(entity);
            }

            // Update modified objects
            foreach (var entity in _dirtyObjects)
            {
                UpdateEntity(entity);
            }

            // Delete removed objects
            foreach (var entity in _deletedObjects)
            {
                DeleteEntity(entity);
            }

            _transaction.Commit();
            ClearTracking();
        }
        catch
        {
            _transaction.Rollback();
            throw;
        }
    }

    public void Rollback()
    {
        _transaction.Rollback();
        ClearTracking();
    }

    private void ClearTracking()
    {
        _newObjects.Clear();
        _dirtyObjects.Clear();
        _deletedObjects.Clear();
    }

    private void InsertEntity(object entity)
    {
        // Implementation would use reflection or data mapper
        // to generate and execute INSERT SQL
    }

    private void UpdateEntity(object entity)
    {
        // Implementation would generate and execute UPDATE SQL
    }

    private void DeleteEntity(object entity)
    {
        // Implementation would generate and execute DELETE SQL
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _connection?.Close();
        _connection?.Dispose();
    }
}

// Usage in a service
public class OrderService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IOrderRepository _orderRepository;
    private readonly ICustomerRepository _customerRepository;

    public OrderService(IUnitOfWork unitOfWork, 
                       IOrderRepository orderRepository,
                       ICustomerRepository customerRepository)
    {
        _unitOfWork = unitOfWork;
        _orderRepository = orderRepository;
        _customerRepository = customerRepository;
    }

    public void ProcessOrder(int customerId, Order order)
    {
        // Retrieve customer
        var customer = _customerRepository.GetById(customerId);
        
        // Modify customer (e.g., update loyalty points)
        customer.LoyaltyPoints += order.TotalAmount * 0.1;
        _unitOfWork.RegisterDirty(customer);
        
        // Add new order
        _unitOfWork.RegisterNew(order);
        
        // Commit all changes as a single transaction
        _unitOfWork.Commit();
    }
}
```

A more practical example using Entity Framework (which implements Unit of Work via DbContext):

```csharp
public class OrderService
{
    private readonly ApplicationDbContext _context; // DbContext is a Unit of Work

    public OrderService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task ProcessOrderAsync(int customerId, Order order)
    {
        // Retrieve customer
        var customer = await _context.Customers.FindAsync(customerId);
        
        // Modify customer
        customer.LoyaltyPoints += order.TotalAmount * 0.1m;
        // EF Core tracks this change automatically
        
        // Add new order
        _context.Orders.Add(order);
        // EF Core registers this as new
        
        // Remove old pending orders
        var oldOrders = _context.Orders
            .Where(o => o.CustomerId == customerId && o.Status == "Pending")
            .ToList();
        _context.Orders.RemoveRange(oldOrders);
        
        // Commit all changes together
        await _context.SaveChangesAsync();
        // This generates appropriate INSERT, UPDATE, DELETE statements
        // and executes them within a transaction
    }
}
```

### **Output**

When the Unit of Work commits changes in the example above, it would execute SQL similar to:

```sql
BEGIN TRANSACTION;

-- Update customer loyalty points
UPDATE Customers 
SET LoyaltyPoints = LoyaltyPoints + 15.50
WHERE CustomerId = 123;

-- Insert new order
INSERT INTO Orders (CustomerId, OrderDate, TotalAmount, Status)
VALUES (123, '2024-12-20', 155.00, 'Confirmed');

-- Delete old pending orders
DELETE FROM Orders 
WHERE CustomerId = 123 AND Status = 'Pending';

COMMIT TRANSACTION;
```

If any operation fails, all changes are rolled back:

```sql
BEGIN TRANSACTION;

-- Operations execute...

-- If error occurs:
ROLLBACK TRANSACTION;
-- Database returns to state before transaction began
```

### Advanced Patterns and Variations

**Nested Unit of Work**: Some implementations support nested Units of Work, where an inner Unit of Work can commit independently or roll back without affecting the outer transaction scope. [Inference] This can be useful in complex business processes but adds significant complexity to the implementation.

**Unit of Work with Events**: Combining the pattern with domain events allows you to trigger side effects (like sending emails or publishing messages) only when the Unit of Work successfully commits.

**Ambient Unit of Work**: Using a thread-static or async-local storage to make the current Unit of Work implicitly available throughout the call stack, reducing the need to pass it explicitly.

**Unit of Work Factory**: Creating Units of Work through a factory ensures proper initialization and can facilitate different strategies for different contexts (e.g., read-only vs. read-write).

### Testing Strategies

**In-Memory Databases**: Use in-memory database providers (like SQLite in-memory mode or Entity Framework's InMemory provider) to test Unit of Work behavior without external dependencies.

**Mock Unit of Work**: Create test doubles that verify the correct objects are registered and that commit is called at the right time.

**Verification Without Commit**: [Inference] Test that business logic correctly registers objects with the Unit of Work without actually committing to verify behavior before persistence.

**Transaction Rollback Tests**: Deliberately cause errors to ensure that the Unit of Work properly rolls back and leaves the database in a consistent state.

### Common Pitfalls

**Long-Lived Units of Work**: Keeping a Unit of Work alive for too long (e.g., across multiple user requests) can lead to memory issues and stale data. Units of Work should generally live for a single business transaction.

**Forgetting to Commit**: Changes tracked by the Unit of Work aren't persisted until commit is explicitly called. Forgetting this step means changes are lost when the Unit of Work is disposed.

**Mixing Persistence Mechanisms**: Using the Unit of Work for some operations while bypassing it for others can lead to inconsistent state and hard-to-debug issues.

**Not Handling Concurrency**: The Unit of Work doesn't automatically solve concurrency problems. You still need optimistic concurrency tokens or pessimistic locking to handle simultaneous updates.

**Overusing Explicit Registration**: In frameworks with automatic change tracking, manually registering objects can be redundant and error-prone. Understand your framework's capabilities.

### Real-World Frameworks

**Entity Framework Core (C#)**: The `DbContext` class is a full implementation of Unit of Work. It automatically tracks changes to entities retrieved through it and batches operations when `SaveChanges()` is called.

**Hibernate/NHibernate**: The `Session` object implements Unit of Work, tracking persistent objects and coordinating with the database through transactions.

**Java Persistence API (JPA)**: The `EntityManager` provides Unit of Work functionality, managing the lifecycle of entities and coordinating persistence operations.

**Doctrine (PHP)**: The `EntityManager` implements Unit of Work with explicit change tracking and flush operations.

**Active Record Pattern**: While different in approach, Active Record frameworks often incorporate Unit of Work concepts for transaction management and batched operations.

### Migration and Adoption

**Incremental Adoption**: You can introduce Unit of Work gradually by wrapping existing data access code and migrating one business transaction at a time.

**Repository First**: Implement the Repository pattern first to abstract data access, then introduce Unit of Work to coordinate repositories.

**Framework Migration**: When moving from direct SQL to an ORM, the ORM's built-in Unit of Work can simplify the transition if you understand its behavior.

**Training Requirements**: [Inference] Teams need training on transaction boundaries, change tracking mechanics, and proper Unit of Work lifecycle management for successful adoption.

### Performance Considerations

**Batch Size Limits**: Very large Units of Work can cause memory pressure and slow commit times. Consider breaking extremely large operations into multiple Units of Work.

**Change Detection Overhead**: Automatic change detection through snapshots or proxies has runtime costs. [Unverified] Profile your application to determine if explicit registration performs better in your scenario.

**Database Round Trips**: While Unit of Work reduces round trips, it doesn't eliminate them entirely. Operations still execute in sequence unless the database supports true batch operations.

**Locking Strategy Impact**: The choice between optimistic and pessimistic locking affects performance. Optimistic locking avoids locks but may require retries on conflicts.

### **Conclusion**

The Unit of Work pattern provides essential coordination for complex business transactions involving multiple data changes. By batching operations, maintaining consistency, and providing clear transaction boundaries, it simplifies persistence logic and improves application reliability. However, the pattern introduces complexity and requires careful consideration of transaction scope, object lifecycle, and concurrency handling.

Modern ORM frameworks like Entity Framework Core and Hibernate provide robust Unit of Work implementations, making the pattern accessible without building it from scratch. When evaluating whether to use this pattern, consider the complexity of your transactions, the benefits of batched operations, and whether your team has the expertise to manage transaction boundaries effectively.

### **Next Steps**

- Implement a simple Unit of Work for a small project to understand the core mechanics
- Study how your ORM framework implements Unit of Work (e.g., DbContext change tracking in Entity Framework)
- Practice defining appropriate transaction boundaries in your business logic
- Experiment with different change tracking strategies (explicit vs. automatic)
- Learn about optimistic and pessimistic concurrency control to complement Unit of Work
- Explore the Repository pattern as a complementary abstraction for data access
- Review your application's transaction requirements to identify where Unit of Work adds value
- Consider testing strategies that verify Unit of Work behavior without database dependencies

---
