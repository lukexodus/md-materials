## Coupling between modules


Coupling measures the degree of interdependence between software modules. In high-quality software, the goal is **loose coupling**, where changes in one module have minimal or no impact on others. Tight coupling creates fragile systems that are difficult to test, refactor, and extend.

**Key Points**

- **Goal:** Minimize direct knowledge one module has of another.
    
- **Impact:** Tightly coupled code reduces reusability and increases the risk of "ripple effects" where a small change breaks unrelated features.
    
- **Metric:** A module should have high cohesion (internal focus) and low coupling (external reliance).
    

Types of Coupling (Ordered from Worst to Best)

Understanding the hierarchy of coupling helps in refactoring legacy code toward a cleaner state.

1. **Content Coupling (Pathological):** One module modifies or relies on the internal implementation logic of another (e.g., accessing private class variables). This is the most dangerous form.
    
2. **Global Coupling:** Modules share global state or data. A change in the global data structure can break all modules sharing it.
    
3. **Control Coupling:** One module passes a flag to another, explicitly controlling its internal logic flow. This implies the caller knows too much about the callee's implementation.
    
4. **Stamp (Data Structure) Coupling:** Modules share a composite data structure (like a large DTO or a database record) but use only parts of it.
    
5. **Data Coupling:** Modules share data through parameters (primitives), passing only the specific data needed. This is the ideal state.
    
6. **Message Coupling:** Communication occurs via message passing or events (e.g., Pub/Sub), decoupling the sender from the receiver entirely.
    

Coupling Metrics

Quantitative analysis of coupling often involves two key metrics used to calculate the Instability ($I$) of a module:

- **Afferent Coupling ($C_a$):** The number of classes outside this package that depend on classes within this package (incoming dependencies). High $C_a$ implies the module is responsible and stable.
    
- **Efferent Coupling ($C_e$):** The number of classes inside this package that depend on classes outside this package (outgoing dependencies). High $C_e$ implies the module is unstable and sensitive to change.
    

**Reduction Strategies**

- **Law of Demeter (Principle of Least Knowledge):** A unit should only talk to its immediate friends. Avoid method chaining like `order.getCustomer().getAddress().getZipCode()`.
    
- **Dependency Injection (DI):** Instead of instantiating dependencies internally, receive them via constructors or arguments.
    
- **Intermediaries:** Use Facades or Adapters to isolate domain logic from third-party libraries.
    

