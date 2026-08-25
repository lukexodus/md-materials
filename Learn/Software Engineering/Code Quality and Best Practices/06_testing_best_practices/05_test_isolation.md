## Test isolation


Test isolation is the principle that each automated test case should execute independently of all other test cases. The outcome of a test must depend solely on the code being tested and the test's specific configuration, not on the side effects of previous tests or the order in which tests are run. Achieving strict isolation is critical for building reliable, deterministic, and parallelizable test suites.

**Key Points**

- **Independence:** No test should rely on the state mutated by a prior test (e.g., database records, global variables, file system artifacts).
    
- **Determinism:** An isolated test produces the same result regardless of the environment or the sequence of execution. Flaky tests are often a symptom of poor isolation.
    
- **Parallelization:** High degrees of isolation allow test runners to execute tests concurrently across multiple threads or processes, significantly reducing CI/CD build times.
    
- **State Management:**
    
    - **Setup/Teardown:** Use `beforeEach` and `afterEach` hooks to reset the environment.
        
    - **Transactional Rollbacks:** For database integration tests, wrap each test in a transaction that is rolled back at the end, ensuring no data persists.
        
    - **Mocking/Stubbing:** Replace external volatile dependencies (APIs, time, randomness) with deterministic doubles.
        
- **Shared Resources:** Avoid sharing mutable instances of objects or static fields between tests. If a global resource is unavoidable (e.g., a singleton), it must be explicitly reset.
    

**Example**

The following example demonstrates test isolation issues caused by a shared static list and how to resolve them using proper setup and teardown methods.

_Bad Practice (Shared State):_

Python

```
class ShoppingCart:
    # Anti-pattern: Global mutable state
    items = []

    @classmethod
    def add(cls, item):
        cls.items.append(item)

    @classmethod
    def total(cls):
        return sum(i['price'] for i in cls.items)

# Test 1
def test_add_item():
    ShoppingCart.add({'name': 'Apple', 'price': 10})
    assert ShoppingCart.total() == 10

# Test 2
def test_empty_cart():
    # Fails because 'Apple' from Test 1 is still in the list
    assert ShoppingCart.total() == 0
```

_Good Practice (Isolated State):_

Python

```
import unittest

class ShoppingCart:
    def __init__(self):
        self.items = []

    def add(self, item):
        self.items.append(item)

    def total(self):
        return sum(i['price'] for i in self.items)

class TestShoppingCart(unittest.TestCase):
    def setUp(self):
        # Isolation: A fresh instance is created before EACH test
        self.cart = ShoppingCart()

    def test_add_item(self):
        self.cart.add({'name': 'Apple', 'price': 10})
        self.assertEqual(self.cart.total(), 10)

    def test_empty_cart(self):
        # Passes because this is a new instance of cart
        self.assertEqual(self.cart.total(), 0)

if __name__ == '__main__':
    unittest.main()
```

**Output**

Running the "Good Practice" test suite results in:

Plaintext

```
..
----------------------------------------------------------------------
Ran 2 tests in 0.001s

OK
```

**Conclusion**

Test isolation is non-negotiable for scalable software maintenance. Without it, test suites become fragile, debugging becomes a search for "ghosts" (side effects from unrelated tests), and developers lose trust in the CI pipeline. While isolating tests (especially integration tests) requires more upfront effort in managing fixtures and mocking dependencies, the payoff in stability and speed is exponential.

---

