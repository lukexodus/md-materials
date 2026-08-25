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

