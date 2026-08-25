## Source code organization


Internal organization of the `src` directory dictates the modularity and maintainability of the application. The primary goal is to minimize coupling and maximize cohesion.

**Key Points**

- **Package by Feature (Vertical Slicing):**
    
    - Instead of grouping by technical layer (e.g., controllers, services, repositories), group code by business domain or feature (e.g., `orders`, `users`, `payments`).
        
    - **Advantage:** All code related to a specific feature sits together. modifying the "Order" feature requires touching files in only one folder. It adheres to the Common Closure Principle.
        
    - **Disadvantage:** Can lead to code duplication if shared utilities are not managed correctly (solved by a `shared` or `common` module).
        
- **Package by Layer (Horizontal Slicing):**
    
    - Groups code by technical function (`views`, `models`, `controllers`).
        
    - **Critique:** High coupling between layers. A simple feature change often requires modifications across the entire directory tree. Generally discouraged for complex applications in favor of vertical slicing or Clean Architecture.
        
- **Hexagonal/Clean Architecture:**
    
    - Strictly enforces dependency rules. The inner circle (Domain/Entities) knows nothing of the outer circles (Infrastructure, UI, Database).
        
    - **Core/Domain:** Pure business logic, no framework dependencies.
        
    - **Adapters/Infrastructure:** Implementations of interfaces defined in the core (e.g., SQL repositories, HTTP handlers).
        
- **Shared Kernel / Utilities:**
    
    - Code reused across multiple features (e.g., Date formatting, String manipulation, Custom Exceptions) should reside in a `shared`, `common`, or `util` package.
        
    - **Warning:** Guard against this becoming a "god package" or a dumping ground for disparate logic.
        
- **Dependency Direction:**
    
    - Dependencies must always point inwards (towards higher-level policies) or sideways (peer modules).
        
    - Avoid circular dependencies (Package A imports B, B imports A) at all costs. This is often a symptom of poor boundary definition.
        
- **Encapsulation Boundaries:**
    
    - Use language-specific visibility modifiers (e.g., `package-private` in Java, `internal` in .NET, `_underscore` in Python/JS) to hide implementation details within a module. Only expose the public API necessary for other modules to consume.
        

**Example**

**Package by Feature structure (Go/Node/Python style):**

Plaintext

```
src/
├── auth/                 # Feature: Authentication
│   ├── service.code      # Business logic
│   ├── handler.code      # HTTP/API layer
│   └── repository.code   # Database access
├── orders/               # Feature: Orders
│   ├── models.code
│   ├── service.code
│   └── order_placed_event.code
├── shared/               # Shared Utilities
│   ├── logger/
│   └── errors/
└── main.code             # Entry point / Composition root
```

