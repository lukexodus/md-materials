## Red-green-refactor cycle


This development cycle constitutes the core rhythm of Test-Driven Development (TDD). It imposes a disciplined workflow where code production is strictly driven by test failure, ensuring that no logic is written without a preceding verification step, and no design improvement occurs without a safety net.

**The Three Phases**

1. **Red (Write a Failing Test):**
    
    - **Action:** Write a test case for the next smallest increment of desired functionality.
        
    - **Validation:** Run the test suite. It must fail. If it passes, the logic already exists or the test is defective (false positive).
        
    - **Objective:** Define the interface (API design) from the consumer's perspective and validate the test mechanism itself.
        
    - **State:** Compilation errors (in statically typed languages) count as a "Red" state.
        
2. **Green (Make it Pass):**
    
    - **Action:** Write the minimum amount of production code required to make the failing test pass.
        
    - **Constraint:** Do not write code for future requirements. Do not optimize. Hardcoding values is acceptable at this stage if it satisfies the specific test case.
        
    - **Objective:** Confirm that the system behaves as expected for the specific scenario.
        
    - **State:** All tests in the suite must pass.
        
3. **Refactor (Clean up the Code):**
    
    - **Action:** Improve the internal structure of the code without altering its external behavior.
        
    - **Target:** Remove code smells, reduce duplication (DRY), improve readability, simplify complex logic, and optimize performance.
        
    - **Safety Net:** The tests created in the Red phase serve as regression protection. If a refactoring breaks functionality, the tests will turn Red immediately.
        
    - **Objective:** Pay down technical debt immediately after creating it.
        

**Impact on Software Architecture**

- **Decoupling:** Writing tests first forces the developer to inject dependencies, leading to loosely coupled architectures.
    
- **Interface Segregation:** Since tests act as the first client of the code, interfaces tend to be cleaner and more focused on usability.
    
- **YAGNI (You Ain't Gonna Need It):** The strict adherence to "Green" prevents over-engineering or implementing speculative features.
    

**Example**

**Scenario:** Implementing a simple `Stack` class with a `push` and `pop` method.

**Iteration 1: The `push` method**

1. Red:

Write a test asserting that pushing an item increases size.

Python

```
def test_push_increases_size():
    stack = Stack()
    stack.push("A")
    assert stack.size() == 1
# Output: NameError: name 'Stack' is not defined (Red)
```

2. Green:

Implement the bare minimum to pass.

Python

```
class Stack:
    def __init__(self):
        self._items = []
    
    def push(self, item):
        self._items.append(item)
        
    def size(self):
        return 1 # Hardcoded to pass the specific assertion (Sins are allowed here)
```

_Correction:_ Upon running the test, it passes. However, if we add `stack.push("B"); assert stack.size() == 2`, it fails. We update `size` to return `len(self._items)`. Now it is Green.

3. Refactor:

Inspect the code.

Python

```
class Stack:
    def __init__(self):
        self._storage = [] # Renamed for clarity
    
    def push(self, element):
        self._storage.append(element)
        
    def size(self):
        return len(self._storage)
```

_Result:_ Tests still pass.

**Iteration 2: The `pop` method**

1. Red:

Write a test for popping.

Python

```
def test_pop_returns_element():
    stack = Stack()
    stack.push("A")
    result = stack.pop()
    assert result == "A"
# Output: AttributeError: 'Stack' object has no attribute 'pop' (Red)
```

**2. Green:**

Python

```
class Stack:
    # ... existing code ...
    def pop(self):
        return self._storage.pop()
```

3. Refactor:

Maybe we notice that the underlying list raises an IndexError on an empty pop, but our design requires a custom exception. We refactor the pop method to handle this, ensuring tests are updated if the behavior contract changes, or adding a new test for the empty state.

**Common Pitfalls**

- **Skipping Refactor:** Moving immediately from Green to the next Red leads to "Technical Debt Rot." The code works but becomes unmaintainable.
    
- **Refactoring on Red:** Refactoring while tests are failing makes it impossible to know if the failure is due to the new test or the code changes. **Always refactor on Green.**
    
- **Large Steps:** Writing a test that requires a massive amount of code to pass defeats the purpose of the cycle. Tests should drive granular implementation.

---

