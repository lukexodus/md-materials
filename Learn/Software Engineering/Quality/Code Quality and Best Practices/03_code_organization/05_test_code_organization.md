## Test code organization


![Image of unit testing pyramid](https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcT1QXwQP4hmNP2lHcFGIKR3WveDzezN9MrVjvVC7eZFiyYqhCsYTn1dPoh8L-wzqt07BX3eRA9zbvvxEbRgbgO0HZG_Lb7DGVwf564Q-J27HPPQEuQ)

Getty Images

Test organization strategies impact the ease of writing tests and the speed of the feedback loop. The structure should support the "Testing Pyramid" (many unit tests, fewer integration tests, very few E2E tests).

**Key Points**

- **Co-location vs. Separation:**
    
    - **Co-location (Side-by-Side):** Unit tests are placed in the same directory as the source file (e.g., `user_service.js` and `user_service.test.js`).
        
        - _Pros:_ High visibility; developers see tests immediately when editing code. Refactoring is easier as tests move with the code.
            
        - _Cons:_ Clutters the source view in file explorers.
            
    - **Separation (Parallel Tree):** Tests reside in a top-level `tests/` directory that mirrors the `src/` structure (e.g., `src/users/Service.java` corresponds to `tests/users/ServiceTest.java`).
        
        - _Pros:_ Keeps deployment artifacts clean; clear separation of production vs. test code.
            
        - _Cons:_ Drift between source structure and test structure happens easily.
            
- **Categorization by Type:**
    
    - **Unit Tests:** Isolate business logic. Should run extremely fast (milliseconds). External dependencies (DB, Network) must be mocked.
        
    - **Integration Tests:** Verify interactions between modules or with external systems (Database, APIs). These should be separated from unit tests to allow running fast test suites independently of slow ones.
        
    - **E2E (End-to-End) Tests:** Simulate user behavior from the entry point. Usually reside in a completely separate root-level folder (e.g., `e2e/` or `cypress/`) as they treat the application as a black box.
        
- **Test Fixtures and Factories:**
    
    - Avoid hardcoding complex objects in test cases. Use a dedicated `fixtures/` or `factories/` directory to generate test data.
        
    - Use the "Object Mother" pattern or "Test Data Builders" to create consistent states for testing.
        
- **Naming Conventions:**
    
    - Test files must have a distinct suffix (e.g., `_test`, `.spec`, `Test`) to be easily identified by test runners and excluded from build artifacts.
        
    - Test function names should describe the behavior, not just the function being tested (e.g., `should_throw_error_when_email_invalid` rather than `test_email_validation`).
        
- **Configuration:**
    
    - Test-specific configuration (mock database URLs, test keys) should be isolated in a `test_config` or specific environment variables, ensuring tests never accidentally run against production or development databases.
        

**Example**

**Separated directory strategy (Common in Java/Python):**

Plaintext

```
project-root/
├── src/
│   └── payment/
│       └── processor.py
├── tests/
│   ├── unit/
│   │   └── payment/
│   │       └── test_processor.py   # Mocks network calls
│   ├── integration/
│   │   └── payment/
│   │       └── test_stripe_api.py  # Hits actual sandbox API
│   └── conftest.py                 # Shared fixtures/setup
└── e2e/
    └── checkout_flow_test.py       # Selenium/Playwright script
```

---

