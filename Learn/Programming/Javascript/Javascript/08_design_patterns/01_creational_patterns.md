## Creational Patterns


### Introduction to Creational Patterns

Creational design patterns abstract the instantiation process, helping to make a system independent of how its objects are created, composed, and represented. They become important as systems evolve to depend more on object composition than class inheritance.

### Singleton Pattern

The Singleton pattern ensures a class has only one instance and provides a global point of access to it.

#### Structure

```java
public class Singleton {
    // Private static instance variable
    private static Singleton instance;
    
    // Private constructor prevents instantiation from other classes
    private Singleton() {
        // Initialization code
    }
    
    // Public static method to get the instance
    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
    
    // Business methods
    public void doSomething() {
        // Implementation
    }
}
```

#### Thread-Safe Singleton

```java
public class ThreadSafeSingleton {
    private static volatile ThreadSafeSingleton instance;
    
    private ThreadSafeSingleton() {}
    
    public static ThreadSafeSingleton getInstance() {
        if (instance == null) {
            synchronized (ThreadSafeSingleton.class) {
                if (instance == null) {
                    instance = new ThreadSafeSingleton();
                }
            }
        }
        return instance;
    }
}
```

#### Initialization-on-demand holder idiom

```java
public class Singleton {
    private Singleton() {}
    
    private static class SingletonHolder {
        private static final Singleton INSTANCE = new Singleton();
    }
    
    public static Singleton getInstance() {
        return SingletonHolder.INSTANCE;
    }
}
```

#### Use Cases

- Database connections
- Logger instances
- Configuration managers
- Thread pools
- Caches

#### Benefits

- Controlled access to sole instance
- Reduced namespace
- Permits refinement of operations and representation
- Permits variable number of instances
- More flexible than class operations

#### Drawbacks

- Can hide bad design
- Requires special treatment in a multithreaded environment
- Testing difficulties
- Violates single responsibility principle

### Factory Method Pattern

Factory Method defines an interface for creating an object, but lets subclasses decide which class to instantiate.

#### Structure

```java
// Product interface
interface Product {
    void operation();
}

// Concrete products
class ConcreteProductA implements Product {
    public void operation() {
        System.out.println("ConcreteProductA operation");
    }
}

class ConcreteProductB implements Product {
    public void operation() {
        System.out.println("ConcreteProductB operation");
    }
}

// Creator abstract class
abstract class Creator {
    // Factory method
    public abstract Product createProduct();
    
    // Operation that uses the factory method
    public void anOperation() {
        Product product = createProduct();
        product.operation();
    }
}

// Concrete creators
class ConcreteCreatorA extends Creator {
    public Product createProduct() {
        return new ConcreteProductA();
    }
}

class ConcreteCreatorB extends Creator {
    public Product createProduct() {
        return new ConcreteProductB();
    }
}
```

#### Parameterized Factory Method

```java
abstract class Creator {
    public abstract Product createProduct(String productType);
}

class ConcreteCreator extends Creator {
    public Product createProduct(String productType) {
        if (productType.equals("A")) {
            return new ConcreteProductA();
        } else if (productType.equals("B")) {
            return new ConcreteProductB();
        }
        return null;
    }
}
```

#### Use Cases

- Framework that must create objects whose type isn't known in advance
- Class that delegates responsibility to subclasses
- Creating objects with complex creation logic
- Encapsulating object creation to promote loose coupling

#### Benefits

- Eliminates the need to bind application-specific classes into code
- Provides hooks for subclasses
- Connects parallel class hierarchies
- Encapsulates object creation

#### Drawbacks

- Can lead to many subclasses
- May be overkill for simple object creation

### Abstract Factory Pattern

Abstract Factory provides an interface for creating families of related or dependent objects without specifying their concrete classes.

#### Structure

```java
// Abstract product interfaces
interface ProductA {
    void operationA();
}

interface ProductB {
    void operationB();
}

// Concrete products
class ConcreteProductA1 implements ProductA {
    public void operationA() {
        System.out.println("ConcreteProductA1 operationA");
    }
}

class ConcreteProductA2 implements ProductA {
    public void operationA() {
        System.out.println("ConcreteProductA2 operationA");
    }
}

class ConcreteProductB1 implements ProductB {
    public void operationB() {
        System.out.println("ConcreteProductB1 operationB");
    }
}

class ConcreteProductB2 implements ProductB {
    public void operationB() {
        System.out.println("ConcreteProductB2 operationB");
    }
}

// Abstract factory interface
interface AbstractFactory {
    ProductA createProductA();
    ProductB createProductB();
}

// Concrete factories
class ConcreteFactory1 implements AbstractFactory {
    public ProductA createProductA() {
        return new ConcreteProductA1();
    }
    
    public ProductB createProductB() {
        return new ConcreteProductB1();
    }
}

class ConcreteFactory2 implements AbstractFactory {
    public ProductA createProductA() {
        return new ConcreteProductA2();
    }
    
    public ProductB createProductB() {
        return new ConcreteProductB2();
    }
}

// Client code
class Client {
    private ProductA productA;
    private ProductB productB;
    
    public Client(AbstractFactory factory) {
        productA = factory.createProductA();
        productB = factory.createProductB();
    }
    
    public void execute() {
        productA.operationA();
        productB.operationB();
    }
}
```

#### Use Cases

- UI toolkits for different operating systems
- Database access for different database systems
- Creating objects for different environments/platforms
- Ensuring coherent product families

#### Real-world Example: UI Components

```java
// Abstract product interfaces
interface Button {
    void render();
    void onClick();
}

interface Checkbox {
    void render();
    void onChange();
}

// Concrete products - Windows style
class WindowsButton implements Button {
    public void render() {
        System.out.println("Render Windows button");
    }
    
    public void onClick() {
        System.out.println("Windows button clicked");
    }
}

class WindowsCheckbox implements Checkbox {
    public void render() {
        System.out.println("Render Windows checkbox");
    }
    
    public void onChange() {
        System.out.println("Windows checkbox changed");
    }
}

// Concrete products - MacOS style
class MacOSButton implements Button {
    public void render() {
        System.out.println("Render MacOS button");
    }
    
    public void onClick() {
        System.out.println("MacOS button clicked");
    }
}

class MacOSCheckbox implements Checkbox {
    public void render() {
        System.out.println("Render MacOS checkbox");
    }
    
    public void onChange() {
        System.out.println("MacOS checkbox changed");
    }
}

// Abstract factory interface
interface GUIFactory {
    Button createButton();
    Checkbox createCheckbox();
}

// Concrete factories
class WindowsFactory implements GUIFactory {
    public Button createButton() {
        return new WindowsButton();
    }
    
    public Checkbox createCheckbox() {
        return new WindowsCheckbox();
    }
}

class MacOSFactory implements GUIFactory {
    public Button createButton() {
        return new MacOSButton();
    }
    
    public Checkbox createCheckbox() {
        return new MacOSCheckbox();
    }
}

// Application
class Application {
    private Button button;
    private Checkbox checkbox;
    
    public Application(GUIFactory factory) {
        button = factory.createButton();
        checkbox = factory.createCheckbox();
    }
    
    public void createUI() {
        button.render();
        checkbox.render();
    }
    
    public void handleUserInput() {
        button.onClick();
        checkbox.onChange();
    }
}

// Main
class Demo {
    public static void main(String[] args) {
        String osName = System.getProperty("os.name").toLowerCase();
        GUIFactory factory;
        
        if (osName.contains("mac")) {
            factory = new MacOSFactory();
        } else {
            factory = new WindowsFactory();
        }
        
        Application app = new Application(factory);
        app.createUI();
        app.handleUserInput();
    }
}
```

#### Benefits

- Isolates concrete classes
- Makes exchanging product families easy
- Promotes consistency among products
- Supports the "product families" concept

#### Drawbacks

- Adding new types of products is difficult
- Can become complex

### Builder Pattern

Builder separates the construction of a complex object from its representation, allowing the same construction process to create different representations.

#### Structure

```java
// Product
class Product {
    private String partA;
    private String partB;
    private String partC;
    
    public void setPartA(String partA) {
        this.partA = partA;
    }
    
    public void setPartB(String partB) {
        this.partB = partB;
    }
    
    public void setPartC(String partC) {
        this.partC = partC;
    }
    
    @Override
    public String toString() {
        return "Product{partA='" + partA + "', partB='" + partB + "', partC='" + partC + "'}";
    }
}

// Builder interface
interface Builder {
    void buildPartA();
    void buildPartB();
    void buildPartC();
    Product getResult();
}

// Concrete builder
class ConcreteBuilder implements Builder {
    private Product product = new Product();
    
    public void buildPartA() {
        product.setPartA("Part A");
    }
    
    public void buildPartB() {
        product.setPartB("Part B");
    }
    
    public void buildPartC() {
        product.setPartC("Part C");
    }
    
    public Product getResult() {
        return product;
    }
}

// Director
class Director {
    public void construct(Builder builder) {
        builder.buildPartA();
        builder.buildPartB();
        builder.buildPartC();
    }
}

// Client code
public class Client {
    public static void main(String[] args) {
        Director director = new Director();
        Builder builder = new ConcreteBuilder();
        
        director.construct(builder);
        Product product = builder.getResult();
        
        System.out.println(product);
    }
}
```

#### Modern Builder Pattern (Method Chaining)

```java
// Product
class Pizza {
    private final String dough;
    private final String sauce;
    private final String topping;
    
    private Pizza(Builder builder) {
        this.dough = builder.dough;
        this.sauce = builder.sauce;
        this.topping = builder.topping;
    }
    
    @Override
    public String toString() {
        return "Pizza{dough='" + dough + "', sauce='" + sauce + "', topping='" + topping + "'}";
    }
    
    // Builder
    public static class Builder {
        private String dough;
        private String sauce;
        private String topping;
        
        public Builder() {}
        
        public Builder dough(String dough) {
            this.dough = dough;
            return this;
        }
        
        public Builder sauce(String sauce) {
            this.sauce = sauce;
            return this;
        }
        
        public Builder topping(String topping) {
            this.topping = topping;
            return this;
        }
        
        public Pizza build() {
            return new Pizza(this);
        }
    }
}

// Client code
public class Client {
    public static void main(String[] args) {
        Pizza pizza = new Pizza.Builder()
            .dough("Thin crust")
            .sauce("Tomato")
            .topping("Cheese")
            .build();
            
        System.out.println(pizza);
    }
}
```

#### Use Cases

- When object construction is complex
- When objects must be immutable
- When different representations of the same object are needed
- To break down complex constructors
- When constructing Composite trees or other complex objects

#### Benefits

- Allows varying internal representation of products
- Isolates code for construction and representation
- Provides finer control over the construction process
- Creates immutable objects without telescoping constructors

#### Drawbacks

- Requires creating a separate ConcreteBuilder for each different product type
- Requires the builder classes to be mutable

### Prototype Pattern

Prototype specifies the kinds of objects to create using a prototypical instance, and creates new objects by copying this prototype.

#### Structure

```java
// Prototype interface
interface Prototype extends Cloneable {
    Prototype clone();
}

// Concrete prototypes
class ConcretePrototype1 implements Prototype {
    private String property;
    
    public ConcretePrototype1(String property) {
        this.property = property;
    }
    
    public Prototype clone() {
        return new ConcretePrototype1(property);
    }
    
    @Override
    public String toString() {
        return "ConcretePrototype1{property='" + property + "'}";
    }
}

class ConcretePrototype2 implements Prototype {
    private int value;
    
    public ConcretePrototype2(int value) {
        this.value = value;
    }
    
    public Prototype clone() {
        return new ConcretePrototype2(value);
    }
    
    @Override
    public String toString() {
        return "ConcretePrototype2{value=" + value + "}";
    }
}

// Client
public class Client {
    public static void main(String[] args) {
        ConcretePrototype1 prototype1 = new ConcretePrototype1("value");
        ConcretePrototype1 clone1 = (ConcretePrototype1) prototype1.clone();
        
        System.out.println(prototype1);
        System.out.println(clone1);
        
        ConcretePrototype2 prototype2 = new ConcretePrototype2(42);
        ConcretePrototype2 clone2 = (ConcretePrototype2) prototype2.clone();
        
        System.out.println(prototype2);
        System.out.println(clone2);
    }
}
```

#### Deep vs. Shallow Copy

```java
// Complex object with nested references
class Address implements Cloneable {
    private String street;
    private String city;
    
    public Address(String street, String city) {
        this.street = street;
        this.city = city;
    }
    
    public Address clone() {
        try {
            return (Address) super.clone();
        } catch (CloneNotSupportedException e) {
            return null;
        }
    }
    
    // Getters and setters
    public String getStreet() { return street; }
    public void setStreet(String street) { this.street = street; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    
    @Override
    public String toString() {
        return "Address{street='" + street + "', city='" + city + "'}";
    }
}

class Person implements Cloneable {
    private String name;
    private Address address;
    
    public Person(String name, Address address) {
        this.name = name;
        this.address = address;
    }
    
    // Shallow copy
    public Person shallowClone() {
        try {
            return (Person) super.clone();
        } catch (CloneNotSupportedException e) {
            return null;
        }
    }
    
    // Deep copy
    public Person deepClone() {
        try {
            Person clone = (Person) super.clone();
            clone.address = address.clone();
            return clone;
        } catch (CloneNotSupportedException e) {
            return null;
        }
    }
    
    // Getters and setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Address getAddress() { return address; }
    public void setAddress(Address address) { this.address = address; }
    
    @Override
    public String toString() {
        return "Person{name='" + name + "', address=" + address + "}";
    }
}

// Client demonstrating difference
public class Client {
    public static void main(String[] args) {
        Address address = new Address("123 Main St", "Anytown");
        Person original = new Person("John", address);
        
        // Shallow copy
        Person shallowCopy = original.shallowClone();
        
        // Deep copy
        Person deepCopy = original.deepClone();
        
        // Change address in original
        address.setStreet("456 Oak Ave");
        
        System.out.println("Original: " + original);
        System.out.println("Shallow copy: " + shallowCopy);  // Address is also changed
        System.out.println("Deep copy: " + deepCopy);  // Address remains unchanged
    }
}
```

#### Prototype Registry

```java
import java.util.HashMap;
import java.util.Map;

// Prototype registry
class ShapeRegistry {
    private Map<String, Shape> shapes = new HashMap<>();
    
    public void addShape(String key, Shape shape) {
        shapes.put(key, shape);
    }
    
    public Shape getShape(String key) {
        return shapes.get(key).clone();
    }
}

// Prototype interface
interface Shape extends Cloneable {
    Shape clone();
    void draw();
}

// Concrete prototypes
class Circle implements Shape {
    private int radius;
    
    public Circle(int radius) {
        this.radius = radius;
    }
    
    @Override
    public Shape clone() {
        return new Circle(radius);
    }
    
    @Override
    public void draw() {
        System.out.println("Drawing Circle with radius " + radius);
    }
}

class Rectangle implements Shape {
    private int width;
    private int height;
    
    public Rectangle(int width, int height) {
        this.width = width;
        this.height = height;
    }
    
    @Override
    public Shape clone() {
        return new Rectangle(width, height);
    }
    
    @Override
    public void draw() {
        System.out.println("Drawing Rectangle with width " + width + " and height " + height);
    }
}

// Client
public class Client {
    public static void main(String[] args) {
        ShapeRegistry registry = new ShapeRegistry();
        
        registry.addShape("smallCircle", new Circle(5));
        registry.addShape("largeCircle", new Circle(10));
        registry.addShape("rectangle", new Rectangle(10, 5));
        
        Shape smallCircle = registry.getShape("smallCircle");
        Shape largeCircle = registry.getShape("largeCircle");
        Shape rectangle = registry.getShape("rectangle");
        
        smallCircle.draw();
        largeCircle.draw();
        rectangle.draw();
    }
}
```

#### Use Cases

- When classes to instantiate are specified at runtime
- To avoid building a class hierarchy of factories
- When instances can have one of only a few different combinations of state
- When object creation is expensive compared to cloning

#### Benefits

- Add and remove products at runtime
- Specify new objects by varying values
- Specify new objects by varying structure
- Reduces subclassing
- Configure an application with classes dynamically

#### Drawbacks

- Each subclass must implement the clone operation
- Complex object graphs with circular references can be challenging to clone

### Object Pool Pattern

Object Pool manages a set of reusable objects that are expensive to create, allowing clients to "check out" and "check in" objects from the pool.

#### Structure

```java
import java.util.ArrayList;
import java.util.List;

// Reusable object
class DatabaseConnection {
    private boolean isConnected;
    
    public DatabaseConnection() {
        // Expensive resource creation
        this.isConnected = true;
        System.out.println("Created new database connection");
    }
    
    public void executeQuery(String query) {
        if (isConnected) {
            System.out.println("Executing query: " + query);
        } else {
            System.out.println("Connection is not active");
        }
    }
    
    public void close() {
        isConnected = false;
        System.out.println("Connection closed");
    }
    
    public void connect() {
        isConnected = true;
        System.out.println("Connection opened");
    }
}

// Object pool
class ConnectionPool {
    private List<DatabaseConnection> availableConnections;
    private List<DatabaseConnection> usedConnections;
    private int maxConnections;
    
    public ConnectionPool(int maxConnections) {
        this.maxConnections = maxConnections;
        this.availableConnections = new ArrayList<>();
        this.usedConnections = new ArrayList<>();
        
        // Initialize pool with connections
        for (int i = 0; i < maxConnections / 2; i++) {
            availableConnections.add(new DatabaseConnection());
        }
    }
    
    public synchronized DatabaseConnection getConnection() {
        if (availableConnections.isEmpty()) {
            if (usedConnections.size() < maxConnections) {
                // Create new connection if limit not reached
                DatabaseConnection conn = new DatabaseConnection();
                usedConnections.add(conn);
                return conn;
            } else {
                // Wait for a connection to be returned
                System.out.println("Maximum connections reached, waiting...");
                try {
                    wait(); // Wait for a connection to be released
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                return getConnection(); // Recursive call after waiting
            }
        } else {
            // Get existing connection from pool
            DatabaseConnection conn = availableConnections.remove(0);
            usedConnections.add(conn);
            return conn;
        }
    }
    
    public synchronized void releaseConnection(DatabaseConnection conn) {
        if (usedConnections.remove(conn)) {
            availableConnections.add(conn);
            notifyAll(); // Notify waiting threads
            System.out.println("Connection returned to pool");
        } else {
            System.out.println("This connection was not issued from this pool");
        }
    }
    
    public synchronized int getAvailableConnectionsCount() {
        return availableConnections.size();
    }
    
    public synchronized int getUsedConnectionsCount() {
        return usedConnections.size();
    }
}

// Client
public class Client {
    public static void main(String[] args) {
        ConnectionPool pool = new ConnectionPool(5);
        
        System.out.println("Available connections: " + pool.getAvailableConnectionsCount());
        
        // Get connections
        DatabaseConnection conn1 = pool.getConnection();
        DatabaseConnection conn2 = pool.getConnection();
        
        System.out.println("Available connections: " + pool.getAvailableConnectionsCount());
        System.out.println("Used connections: " + pool.getUsedConnectionsCount());
        
        // Use connections
        conn1.executeQuery("SELECT * FROM users");
        conn2.executeQuery("SELECT * FROM products");
        
        // Release connection
        pool.releaseConnection(conn1);
        
        System.out.println("Available connections: " + pool.getAvailableConnectionsCount());
        System.out.println("Used connections: " + pool.getUsedConnectionsCount());
        
        // Get more connections than available
        DatabaseConnection conn3 = pool.getConnection();
        DatabaseConnection conn4 = pool.getConnection();
        DatabaseConnection conn5 = pool.getConnection();
        DatabaseConnection conn6 = pool.getConnection(); // This will wait if we uncomment below
        
        // Uncomment to see maximum connections behavior
        // new Thread(() -> {
        //     DatabaseConnection conn7 = pool.getConnection();
        // }).start();
    }
}
```

#### Use Cases

- Database connections
- Thread pools
- File handles
- Network connections
- Large graphic objects

#### Benefits

- Improved performance for expensive object creation
- Controls maximum number of objects
- Management of connection or object lifecycle
- Object pre-initialization

#### Drawbacks

- Increased complexity
- Potential for leaking or unused resources
- Can mask connection problems
- Thread-safety considerations

### Simple Factory (not GoF pattern but commonly used)

Simple Factory encapsulates object creation logic in a single class.

#### Structure

```java
// Product interface
interface Product {
    void operation();
}

// Concrete products
class ConcreteProductA implements Product {
    public void operation() {
        System.out.println("ConcreteProductA operation");
    }
}

class ConcreteProductB implements Product {
    public void operation() {
        System.out.println("ConcreteProductB operation");
    }
}

// Simple factory
class ProductFactory {
    public static Product createProduct(String type) {
        if (type.equals("A")) {
            return new ConcreteProductA();
        } else if (type.equals("B")) {
            return new ConcreteProductB();
        }
        throw new IllegalArgumentException("Invalid product type: " + type);
    }
}

// Client code
public class Client {
    public static void main(String[] args) {
        Product productA = ProductFactory.createProduct("A");
        productA.operation();
        
        Product productB = ProductFactory.createProduct("B");
        productB.operation();
    }
}
```

#### Use Cases

- Simple object creation
- Isolating client code from concrete class instantiation
- Entry point to more complex factories

#### Benefits

- Encapsulates object creation
- Simplifies client code
- Centralizes object creation logic

#### Drawbacks

- Requires modification when adding new products
- Less flexible than other creational patterns

### Multiton Pattern (Variation of Singleton)

Multiton provides a controlled number of instances, mapping keys to instances.

#### Structure

```java
import java.util.HashMap;
import java.util.Map;

class Multiton {
    private static final Map<String, Multiton> instances = new HashMap<>();
    
    private final String name;
    
    private Multiton(String name) {
        this.name = name;
        try {
            Thread.sleep(1000); // Simulate expensive resource initialization
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("Multiton instance created: " + name);
    }
    
    public static synchronized Multiton getInstance(String key) {
        if (!instances.containsKey(key)) {
            instances.put(key, new Multiton(key));
        }
        return instances.get(key);
    }
    
    public void doSomething() {
        System.out.println("Multiton " + name + " doing something");
    }
    
    public static int getInstanceCount() {
        return instances.size();
    }
}

// Client
public class Client {
    public static void main(String[] args) {
        Multiton dbInstance = Multiton.getInstance("database");
        Multiton cacheInstance = Multiton.getInstance("cache");
        Multiton dbInstanceAgain = Multiton.getInstance("database");
        
        System.out.println("Total instances created: " + Multiton.getInstanceCount());
        
        dbInstance.doSomething();
        cacheInstance.doSomething();
        
        System.out.println("dbInstance == dbInstanceAgain: " + (dbInstance == dbInstanceAgain));
    }
}
```

#### Use Cases

- Limited number of different resource connections
- Multiple loggers for different subsystems
- Thread pools with different configurations

#### Benefits

- Controls instance creation based on keys
- Provides access to a family of singletons
- More flexible than pure singleton

#### Drawbacks

- Can lead to memory leaks if instances are not properly managed
- Increased complexity compared to singleton

### Lazy Initialization Pattern

Lazy Initialization delays the creation of an object until it's first used.

#### Structure

```java
import java.util.HashMap;
import java.util.Map;

class ResourceManager {
    private Map<String, Resource> resources = new HashMap<>();
    
    public Resource getResource(String name) {
        Resource resource = resources.get(name);
        
        if (resource == null) {
            resource = new Resource(name);
            resources.put(name, resource);
        }
        
        return resource;
    }
    
    public int getResourceCount() {
        return resources.size();
    }
}

class Resource {
    private String name;
    
    public Resource(String name) {
        this.name = name;
        // Simulate expensive initialization
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("Resource created: " + name);
    }
    
    public void use() {
        System.out.println("Using resource: " + name);
    }
}

// Client
public class Client {
    public static void main(String[] args) {
        ResourceManager manager = new ResourceManager();
        
        System.out.println("Resources created: " + manager.getResourceCount());
        
        Resource r1 = manager.getResource("A");
        r1.use();
        
        System.out.println("Resources created: " + manager.getResourceCount());
        
        Resource r2 = manager.getResource("B");
        r2.use();
        
        System.out.println("Resources created: " + manager.getResourceCount());
        
        // Reusing existing resource
        Resource r1Again = manager.getResource("A");
        r1Again.use();
        
        System.out.println("Resources created: " + manager.getResourceCount());
    }
}
```

#### Use Cases

- Application startup optimization
- Resource-intensive object initialization
- Collections of expensive objects
- Services that may not be used in every application run

#### Benefits

- Improves application startup performance
- Saves resources by creating objects only when needed
- Simple to implement

#### Drawbacks

- Adds complexity to resource access
- May introduce unexpected delays
- Thread safety concerns

### Service Locator Pattern

Service Locator provides a central registry for services, allowing clients to find and use services without knowing their implementation details.

#### Structure

```java
// Service interface
interface Service {
    String getName();
    void execute();
}

// Concrete services
class ServiceA implements Service {
    public String getName() {
        return "ServiceA";
    }
    
    public void execute() {
        System.out.println("Executing ServiceA");
    }
}

class ServiceB implements Service {
    public String getName() {
        return "ServiceB";
    }
    
    public void execute() {
        System.out.println("Executing ServiceB");
    }
}

// Service locator
class ServiceLocator {
    private static ServiceLocator instance;
    private final Map<String, Service> services;
    
    private ServiceLocator() {
        services = new HashMap<>();
    }
    
    public static synchronized ServiceLocator getInstance() {
        if (instance == null) {
            instance = new ServiceLocator();
        }
        return instance;
    }
    
    public void registerService(Service service) {
        services.put(service.getName(), service);
    }
    
    public Service getService(String name) {
        Service service = services.get(name);
        if (service == null) {
            throw new RuntimeException("Service not found: " + name);
        }
        return service;
    }
}
```

---

**Key Points**

- **Decouples clients from concrete service implementations**: Clients retrieve services via the locator rather than constructing them.
- **Centralized service registry**: A single source of truth for service instances.
- **Singleton pattern**: Often used for the `ServiceLocator` to ensure global access and a consistent registry.
- **Caching**: Services are typically cached after first registration or lookup to avoid repeated instantiations.

---

#### **Example Usage**

```java
public class Main {
    public static void main(String[] args) {
        ServiceLocator locator = ServiceLocator.getInstance();

        locator.registerService(new ServiceA());
        locator.registerService(new ServiceB());

        Service service1 = locator.getService("ServiceA");
        service1.execute();  // Output: Executing ServiceA

        Service service2 = locator.getService("ServiceB");
        service2.execute();  // Output: Executing ServiceB
    }
}
```

---

#### **Advantages**

- **Loose coupling**: The client does not need to know about concrete implementations.
- **Centralized management**: Easy to configure and manage service instances in one place.
- **Reusability**: Services can be reused across different parts of the system.

---

#### **Disadvantages**

- **Hidden dependencies**: Services are acquired from a hidden source, making dependencies less explicit.
- **Harder to test**: Difficult to inject mocks for testing since service retrieval is not transparent.
- **Global state**: Using a global locator (singleton) introduces shared state, which may lead to tight coupling.

---

#### **Alternatives / Related Patterns**

- **Dependency Injection (DI)**: An alternative that makes dependencies explicit and easier to manage and test.
- **Registry Pattern**: Similar to Service Locator, but typically used for static access to objects by name or type.

---

**Conclusion**

The Service Locator pattern centralizes service resolution, improving modularity and encapsulation of service instantiation. While it simplifies service lookup, it can obscure dependencies and complicate testing. For large or testable systems, Dependency Injection is often preferred.

---

