## When to Mock


Mocking is a technique used in unit testing to isolate the code under test (System Under Test - SUT) from its dependencies. Deciding when to mock is a trade-off between test isolation reliability and the risk of coupling tests to implementation details.

**Core Philosophy**

Mocking should be primarily employed at the **architectural boundaries** of your application. The goal is to verify that the SUT interacts correctly with its neighbors, not to replicate the behavior of the neighbors themselves. Excessive mocking leads to brittle tests that pass even when the system is broken (false negatives) or fail during refactoring even when behavior is preserved (false positives).

**Scenarios Requiring Mocks**

- External Services and APIs:
    
    Never make network calls in unit tests. Mocking is mandatory for HTTP clients, third-party SDKs (e.g., AWS S3, Stripe), and microservice calls. This ensures tests are deterministic, fast, and do not incur costs or side effects on external systems.
    
- Non-Deterministic Behavior:
    
    Code that relies on factors outside your control must be mocked to ensure repeatable tests.
    
    - _Time:_ `Date.now()`, `sleep()`, or scheduled tasks.
        
    - _Randomness:_ `Math.random()` or UUID generation.
        
    - _Environment:_ File system presence, environment variables, or sensor data.
        
- Slow or Resource-Intensive Operations:
    
    Any dependency that significantly slows down the test suite, such as complex calculations, video processing, or extensive file I/O, should be mocked to maintain a rapid feedback loop.
    
- Hard-to-Reproduce Error States:
    
    Simulating rare failure modes in real systems is difficult. Mocks allow you to effortlessly trigger edge cases like network timeouts, 500 Internal Server Errors, disk full exceptions, or database connection losses to verify error handling logic.
    
- Undefined Dependencies:
    
    When developing top-down, you may need to write code that collaborates with a component that does not exist yet. Mocks allow you to define the interface and interaction contract before the implementation is written.
    

**Scenarios to Avoid Mocking**

- Value Objects and Data Structures:
    
    Do not mock simple entities, DTOs (Data Transfer Objects), or standard library collections (Lists, Maps). Use the real objects. Mocks here add unnecessary complexity and obscure the test's intent.
    
- Internal Implementation Details (Private Methods):
    
    Mocking private methods or internal helper classes creates high coupling between the test and the specific implementation. If you refactor the code, the test will break even if the output is correct. Test through the public interface.
    
- Third-Party Utility Libraries:
    
    Avoid mocking stable, fast, and deterministic libraries (e.g., Lodash, Apache Commons, math libraries). Wrapping these in mocks adds no value and hides the behavior you are trying to utilize.
    
- The "Mock Everything" Anti-Pattern:
    
    If you mock every single collaborator, you are testing the mocks, not the code. If a test setup requires 50 lines of mock configuration for 2 lines of execution, the design likely violates the Single Responsibility Principle or the test is too granular.
    

**Mocking "Types You Own"**

A critical best practice is to **only mock types you own**. If you need to mock a third-party library, wrap it in your own interface/adapter and mock that adapter.

- _Why:_ Third-party APIs change. If you mock the external API directly throughout your codebase, a library update requires updating mocks in hundreds of places. If you wrap it, you only update the adapter and its specific integration test.
    

**Example: Good vs. Bad Mocking**

- _Bad:_ Mocking a standard `List` class to return a size of 5. Just create a real list with 5 items.
    
- _Bad:_ Mocking a specific SQL query string builder.
    
- _Good:_ Mocking a `PaymentGateway` interface to throw a `PaymentDeclinedException` when `process()` is called.
    

**Conclusion**

Mock when the dependency is slow, expensive, non-deterministic, or external. Use real implementations when the dependency is fast, deterministic, and part of the same logical domain. The sweet spot is typically "Classicist" testing for domain logic (use real objects) and "Mockist" testing for service/boundary layers.

---

