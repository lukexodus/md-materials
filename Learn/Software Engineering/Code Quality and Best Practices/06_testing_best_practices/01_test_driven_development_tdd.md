## Test-driven development (TDD)


Test-Driven Development (TDD) is a discipline where the writing of automated unit tests precedes the implementation of the code. It is primarily a design technique that drives the architecture of the system to be decoupled, testable, and robust. It relies on a short feedback loop to ensure correctness and maintainability.

**The Three Laws of TDD**

Robert C. Martin (Uncle Bob) formalized the discipline into three strict rules that govern the minute-by-minute workflow:

1. **You are not allowed to write any production code unless it is to make a failing unit test pass.**
    
2. **You are not allowed to write any more of a unit test than is sufficient to fail; and compilation failures are failures.**
    
3. **You are not allowed to write any more production code than is sufficient to pass the one failing unit test.**
    

**The Red-Green-Refactor Cycle**

The operational mechanism of TDD is a repeating micro-cycle:

- **Red (Write a failing test):** Write a small test that defines a desired improvement or new function. This phase acts as the design phase for the API. You must run the test and watch it fail (including compilation errors) to ensure the test mechanism is working and the test is actually checking what you expect.
    
- **Green (Make it pass):** Write only enough code to make the test pass. The focus here is purely on meeting the requirement. It is acceptable to violate best practices (e.g., hardcoding values, duplication) in this specific step to achieve the "Green" state quickly.12
    
- **Refactor (Improve the code):** Clean up the new code. This is where code quality is introduced. You remove dupl3ication, abstract concepts, and improve names, relying on the test suite to ensure no regression occurs. This phase applies to both production code and test code.
    

**TDD Styles: State vs. Behavior**

There are two primary schools of thought regarding how tests should verify the system under test (SUT):

- **Classic / Detroit / Chicago Style (State Verification):**
    
    - Focuses on the state of the object or the return value of the method.
        
    - Tests usually instantiate the SUT and potentially some collaborators.
        
    - Verifies that `sut.doSomething()` results in a specific state change or value.
        
    - **Pro:** Tests are less brittle to refactoring internal implementation details.
        
    - **Con:** Can identify defects later in the integration chain if dependencies are heavy.
        
- **London / Mockist Style (Behavior Verification):**
    
    - Focuses on the interactions between the SUT and its collaborators.
        
    - Heavily relies on mocks, spies, and stubs to isolate the SUT.
        
    - Verifies that `sut.doSomething()` called `collaborator.method()` with specific arguments.
        
    - **Pro:** Enforces strict isolation and helps discover interfaces (Outside-In development).
        
    - **Con:** Tests can become brittle; refactoring implementation often requires updating tests even if behavior hasn't changed.
        

**Common Anti-Patterns**

- **The Liar:** A test that passes but does not actually test the scenario it purports to (e.g., no assertions).
    
- **The Inspector:** A test that violates encapsulation by inspecting private fields or methods, making refactoring impossible without breaking tests.
    
- **The Giant:** A unit test that spans hundreds of lines, testing multiple behaviors simultaneously. This obscures the reason for failure.
    
- **Mockery:** Excessive use of mocks where the test becomes a tautology (testing the mock configuration rather than the logic).
    

**Example**

The following example demonstrates a standard TDD cycle for implementing a `Stack`.

_Cycle 1: The Foundation_

**Step 1 (Red):** Write a test ensuring a new stack is empty.

Java

```
@Test
void newlyCreatedStackShouldBeEmpty() {
    Stack stack = new Stack();
    assertTrue(stack.isEmpty()); // Fails: Stack class or method doesn't exist
}
```

**Step 2 (Green):** Implement the bare minimum.

Java

```
public class Stack {
    public boolean isEmpty() {
        return true; // Hardcoded to pass
    }
}
```

**Step 3 (Refactor):** No refactoring needed yet.

_Cycle 2: Adding Functionality_

**Step 1 (Red):** Write a test for pushing an item.

Java

```
@Test
void afterPushingElementStackShouldNotBeEmpty() {
    Stack stack = new Stack();
    stack.push(1);
    assertFalse(stack.isEmpty()); // Fails
}
```

**Step 2 (Green):** Implement minimum logic to pass both tests.

Java

```
public class Stack {
    private int size = 0;

    public boolean isEmpty() {
        return size == 0;
    }

    public void push(int element) {
        size++;
    }
}
```

**Step 3 (Refactor):** The code is clean, but check if test setup is duplicated.

Java

```
// Refactoring Test Code
private Stack stack;

@BeforeEach
void setUp() {
    stack = new Stack();
}
// Tests now use the shared 'stack' instance.
```

_Cycle 3: Complex Logic_

**Step 1 (Red):** Handle Pop.

Java

```
@Test
void popShouldReturnPushedElement() {
    stack.push(10);
    assertEquals(10, stack.pop()); // Fails
}
```

**Step 2 (Green):** Implement backing storage.

Java

```
public class Stack {
    private int size = 0;
    private int[] elements = new int[10];

    public boolean isEmpty() { return size == 0; }

    public void push(int element) {
        elements[size++] = element;
    }

    public int pop() {
        return elements[--size];
    }
}
```

**Step 3 (Refactor):** The `elements` array has a hardcoded size. If a requirement for dynamic sizing arises, we would write a failing test for `push` when full, then implement the resizing logic.

**Key Points**

- **Design Tool:** TDD is primarily about designing better interfaces and decoupling dependencies, not just verifying correctness.
    
- **Confidence:** TDD provides a safety net that allows developers to refactor aggressively.
    
- **Documentation:** Tests serve as executable documentation that describes exactly how the system behaves and how to use the API.
    
- **Cost:** TDD has a higher initial overhead but significantly reduces long-term maintenance costs and bug density.

---

