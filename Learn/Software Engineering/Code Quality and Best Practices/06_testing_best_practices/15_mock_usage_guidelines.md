## Mock Usage Guidelines


Effective usage of mocks is essential for creating isolated, fast, and reliable unit tests.1 Misuse of mocks frequently leads to brittle tests that pass despite broken production code or fail purely due to internal refactoring. These guidelines focus on when and how to apply mocks to maintain test suite integrity.

**Key Points**

- **Only Mock Types You Own:** Avoid mocking third-party libraries or external APIs directly.2 Instead, create a thin wrapper (adapter) around the external dependency and mock that wrapper. This insulates your tests from API changes in the third-party library.
    
- **Mock Roles, Not Objects:** Focus on the interaction between the System Under Test (SUT) and its collaborators. Mocks should verify the _protocol_ (messages passed), not the internal state of the collaborator.
    
- **Don't Mock Value Objects:** Never mock simple data structures, entities, or value objects (e.g., `List`, `String`, `UserDTO`). Instantiating the real object is faster, less error-prone, and provides higher fidelity.
    
- **Command vs. Query Separation:**
    
    - **Stubs** should be used for **Queries** (methods that return a result and have no side effects).
        
    - **Mocks** (verification) should be used for **Commands** (methods that perform a side effect, like sending an email or saving to a database).
        
- **Avoid Partial Mocks:** If you find yourself mocking only part of a class while using real implementations for other methods, the class likely violates the Single Responsibility Principle. Split the class instead of using partial mocks.
    

**Mocking Boundaries**

- **Architectural Seams:** Mocks should be applied at architectural boundaries (e.g., between the Application Layer and the Infrastructure Layer).
    
- **Deterministic Behavior:** Use mocks to simulate hard-to-reproduce scenarios, such as network timeouts, 500 server errors, or specific dates/times.3
    

**Anti-Patterns**

- **Chain Mocking (The Train Wreck):**
    
    - _Bad:_ `when(context.getRequest().getSession().getAttribute("user")).thenReturn(user)`
        
    - _Why:_ This violates the Law of Demeter and couples the test to the deep internal structure of the dependencies.
        
    - _Fix:_ Pass the specific dependency (`Attribute` or `Session`) directly to the SUT.
        
- **Overspecification:**
    
    - _Bad:_ Verifying every single method call on a collaborator, even those irrelevant to the specific behavior being tested.
        
    - _Why:_ Makes refactoring impossible because changing any internal implementation detail breaks the test.
        
    - _Fix:_ Only verify the specific side effect required by the business logic (e.g., `verify(mailer).send(...)`).
        
- **Mocking Concrete Classes:**
    
    - Prefer mocking interfaces. Mocking concrete classes often requires bytecode manipulation (like CGLIB or ByteBuddy) and hides the fact that the design might be too coupled.
        

**Example**

**Scenario:** A `UserService` needs to register a user. It must save the user to a repository (Command) and checks if the email already exists (Query).

**Bad Usage (Over-mocking & Mocking Value Objects)**

Java

```
// Anti-pattern: Mocking a simple DTO/Value Object
User userMock = mock(User.class); 
when(userMock.getEmail()).thenReturn("test@example.com");

// Anti-pattern: Verifying a Query interaction (Stubbing is sufficient)
when(userRepo.exists("test@example.com")).thenReturn(false);
service.register(userMock);
verify(userRepo).exists("test@example.com"); // Redundant verification
```

**Good Usage (Separation & Real Values)**

Java

```
// Use real value object
User user = new User("test@example.com"); 

// Stub the Query (Input configuration)
when(userRepo.exists("test@example.com")).thenReturn(false);

service.register(user);

// Verify ONLY the Command (Side Effect)
verify(userRepo).save(user); 
// Do NOT verify userRepo.exists(); it's an implementation detail of the check.
```

**Next Steps**

When reviewing code, flag any test setup that requires more than 3-4 lines of mock configuration ("when...thenReturn"). This usually indicates high coupling or that the SUT is doing too much.

---

