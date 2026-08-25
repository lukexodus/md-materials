## Interface Segregation


The Interface Segregation Principle (ISP) states that clients should not be forced to depend on methods they do not use. This principle deals with the disadvantages of "fat" or "bloated" interfaces. ISP suggests breaking down large interfaces into smaller, more specific ones so that clients only need to know about the methods that are of interest to them.

**Key Points**

- **Role Interfaces vs. Header Interfaces:** A header interface accidentally extracts every public method of a class into an interface. A role interface is designed based on how a client _uses_ the object. ISP promotes role interfaces.
    
- **Pollution and Coupling:** When a client depends on a class that implements a fat interface, it technically depends on methods it doesn't call. If the fat interface changes (e.g., a method is added for a different client), the original client may need to be recompiled or redeployed, even though its logic didn't change.
    
- **Violation Indicators:**
    
    - **Unimplemented Methods:** If you implement an interface and find yourself writing empty methods, throwing `UnsupportedOperationException`, or returning `null` just to satisfy the compiler, you are likely violating ISP.
        
    - **Fat Classes:** Classes that implement multiple unrelated behaviors often indicate that the interfaces they implement are too broad.
        
- **Architectural Implications:** ISP helps in keeping systems decoupled. In compiled languages like C++ or Java, it reduces build times by minimizing the blast radius of changes. In dynamically typed languages, it serves as semantic documentation, clarifying exactly what subset of behaviors a function requires.
    
- **Granularity Trade-off:** While segregation is good, over-segregation can lead to an explosion of interfaces (e.g., one interface per method). The goal is cohesion: group methods that change together and are used together.
    

**Example**

**Bad Practice (Fat Interface):**

Java

```
public interface SmartDevice {
    void print();
    void fax();
    void scan();
}

public class BasicInkjet implements SmartDevice {
    public void print() {
        // Actual printing logic
    }

    public void fax() {
        // Violation: Basic printers cannot fax.
        throw new UnsupportedOperationException();
    }

    public void scan() {
        // Violation: Basic printers cannot scan.
        throw new UnsupportedOperationException();
    }
}
```

**Refactored (Segregated Interfaces):**

Java

```
public interface Printer {
    void print();
}

public interface Scanner {
    void scan();
}

public interface FaxMachine {
    void fax();
}

// Client only implements what it needs.
public class BasicInkjet implements Printer {
    public void print() {
        // Actual printing logic
    }
}

// Advanced devices can implement multiple specific interfaces.
public class OfficeAllInOne implements Printer, Scanner, FaxMachine {
    public void print() { ... }
    public void scan() { ... }
    public void fax() { ... }
}
```

---

