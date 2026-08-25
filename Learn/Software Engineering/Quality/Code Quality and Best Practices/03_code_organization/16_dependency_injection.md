## Dependency Injection


Dependency Injection (DI) is a specific implementation of the Inversion of Control (IoC) principle, where the control of object creation and dependency management is transferred from the object itself to an external container or framework. It is a fundamental technique for achieving loose coupling in enterprise applications.

**Key Points**

- **Decoupling Creation from Usage:** In traditional programming, a class often creates its own dependencies using the `new` keyword. This tightly couples the class to specific implementations. DI removes this responsibility, allowing the class to focus solely on its behavior while an assembler (or DI container) provides the necessary dependencies.
    
- **Testability:** This is the primary driver for DI adoption in code quality. If a class instantiates a heavy resource (e.g., a database connection or a network socket) internally, unit testing becomes difficult or slow. By injecting dependencies, test harnesses can easily swap real implementations with mocks, stubs, or spies, allowing for isolated testing of business logic.
    
- **Types of Injection:**
    
    - **Constructor Injection:** The preferred method. Dependencies are provided through the class constructor. This ensures the object is always in a valid state upon instantiation and allows fields to be marked as `final` (immutable).
        
    - **Setter Injection:** Dependencies are provided via public setter methods. This allows for optional dependencies or changing dependencies at runtime but risks leaving the object in an incomplete state if the setter is not called.
        
    - **Field/Property Injection:** Dependencies are injected directly into fields (often using annotations like `@Inject` or `@Autowired`). While convenient, this is generally considered an anti-pattern because it hides dependencies, makes the class difficult to instantiate in unit tests without a reflection-based framework, and violates encapsulation.
        
- **The Composition Root:** The wiring of dependencies should happen in a centralized location (the Composition Root), such as the application entry point or a configuration module. This keeps the rest of the codebase unaware of the DI mechanics.
    
- **Dependency Inversion Principle (DIP):** DI facilitates DIP (the "D" in SOLID). High-level modules should not depend on low-level modules; both should depend on abstractions. DI allows you to inject an interface (abstraction) rather than a concrete class.
    

**Example**

**Bad Practice (Tightly Coupled):**

Java

```
public class OrderService {
    private final DatabaseRepository repository;

    public OrderService() {
        // Hard dependency on a specific implementation.
        // Cannot test OrderService without a running database.
        this.repository = new SqlDatabaseRepository();
    }

    public void placeOrder(Order order) {
        repository.save(order);
    }
}
```

**Refactored (Constructor Injection):**

Java

```
public class OrderService {
    private final Repository repository;

    // Dependency is requested, not created.
    // Accepts any implementation of the Repository interface.
    public OrderService(Repository repository) {
        this.repository = repository;
    }

    public void placeOrder(Order order) {
        repository.save(order);
    }
}

// Usage (Composition Root):
Repository repo = new SqlDatabaseRepository(); // Or MockRepository for testing
OrderService service = new OrderService(repo);
```

