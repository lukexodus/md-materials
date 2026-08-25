## You Aren't Gonna Need It (YAGNI)


YAGNI is a practice from Extreme Programming (XP) that states a programmer should not add functionality until it is deemed necessary. It cautions against speculative coding—implementing features, abstractions, or configurations based on the assumption that they will be needed in the future.

**The Cost of Speculation**

- **Maintenance Overhead:** Code that is written "just in case" must still be tested, documented, and migrated when the rest of the system changes.
    
- **Wrong Abstractions:** Guessing how a future feature will work often leads to incorrect design decisions. When the feature is actually requested, the speculative code often has to be torn out because the real requirements differ from the prediction.
    
- **Opportunity Cost:** Time spent building unneeded features is time stolen from building currently required value.
    

YAGNI vs. Extensibility

YAGNI does not mean writing rigid code that cannot be changed. It means avoiding active implementation of unrequested features. You should write clean, modular code (using DRY and SLA) that is easy to extend later, rather than extending it now for hypothetical scenarios.

**Application Checklist**

- Are you adding a database column because "we might track this later"? -> **Remove it.**
    
- Are you creating an interface with only one implementation because "we might swap this out later"? -> **Remove it.**
    
- Are you writing a utility function that is not currently called by any production code? -> **Remove it.**
    

**Example**

Violating YAGNI:

A developer implements a full CRUD (Create, Read, Update, Delete) repository for a "Log" entity, even though the current requirements only ask to write logs to the database.

Java

```
public class LogRepository {
    public void save(Log log) { ... } // Needed now
    public Log findById(int id) { ... } // Not needed yet
    public void update(Log log) { ... } // Not needed yet
    public void delete(int id) { ... }  // Not needed yet
    public List<Log> findAll() { ... }  // Not needed yet
}
```

Adhering to YAGNI:

Implement only what is required to satisfy the current user story.

Java

```
public class LogRepository {
    public void save(Log log) { ... } // Only implemented method
}
```

---

