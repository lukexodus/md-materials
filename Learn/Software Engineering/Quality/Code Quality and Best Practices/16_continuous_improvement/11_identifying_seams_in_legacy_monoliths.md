## Identifying Seams in Legacy Monoliths


Legacy code often lacks dependency injection, making it difficult to isolate the SUT for characterization. Software architects must identify "Seams"—places where behavior can be altered without editing the source code in that location.

**Types of Seams:**

- **Object Seams:** Subclassing a legacy class and overriding a method that talks to an external service (e.g., a database call) to return a fixed string representation of the query instead of executing it.
    
- **Link Seams:** Modifying the classpath or library linking order to load a dummy version of a dependency.
    
- **Preprocessing Seams:** Using compiler directives (less common in interpreted languages) to exclude side-effect-heavy code blocks.
    

Implementation Strategy:

If a method processTransaction() makes a direct static call to BankAPI.send(), refactor the call site to use a protected method getBankApi(). In the test, subclass the component and override getBankApi() to return a mock that logs the call parameters to the Golden Master output rather than executing the transaction.

