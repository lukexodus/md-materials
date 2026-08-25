## Assertions Best Practices


Assertions are a tool for verifying assumptions made by the programmer about the state of the program during execution. They represent conditions that should theoretically never be false if the code is correct. Unlike error handling, which manages expected runtime problems (like network failures or missing files), assertions target logic errors and bugs within the code itself.

**Scope and Applicability**

- **Internal Invariants:** Use assertions to enforce internal invariants—conditions that must hold true at specific points in execution. This includes private method preconditions, postconditions, and class invariants.
    
- **Unreachable Code:** Place assertions in code paths that are logically impossible to reach (e.g., the `default` case of a `switch` statement that covers all enum values) to catch regression bugs immediately.
    
- **Development vs. Production:** Assertions are primarily a development and debugging aid. In many languages (C, C++, Java, Python), they can be globally disabled (stripped out) in production builds for performance. Therefore, they must never control business logic or critical safety checks.
    

**Validation Strategy**

- **Do Not Validate External Input:** Never use assertions to validate data coming from external sources (user input, file systems, network). External input is unreliable by definition; use standard error handling (exceptions, return codes) for these cases.
    
- **Design by Contract:** Adopt a "Design by Contract" mindset where assertions define the contract of internal interfaces. The caller guarantees the precondition, and the callee guarantees the postcondition.
    

**Side Effects and State**

- **Purely Passive:** Expressions inside an assertion must be side-effect free. They should not modify variables, allocate resources, or alter the program state. If an assertion is stripped in production, the state modification would vanish, causing distinct behaviors between debug and release builds (Heisenbugs).
    
- **Example of Side Effect Violation:**
    
    Java
    
    ```
    // Bad: The list is only cleared if assertions are enabled
    assert list.clear(); 
    ```
    

**Message Clarity**

- **Descriptive Failures:** Always provide a descriptive message expression alongside the boolean condition. The message should explain _what_ assumption failed and include relevant variable values to aid in immediate diagnosis without needing a debugger attached.
    
- **Variable Context:** Include the values of the variables involved in the comparison, not just the static string "Assertion failed".
    

**Performance and Redundancy**

- **Heavy Computation:** Be cautious when asserting conditions that require expensive computation (e.g., verifying the integrity of a large graph structure). While acceptable in debug builds, ensure these checks do not inadvertently leak into production builds or make the debug build unusable due to slowness.
    
- **Redundant Checks:** Avoid asserting conditions that the compiler or runtime environment already guarantees (e.g., checking if a strictly typed non-nullable reference is not null in languages that enforce null safety).
    

**Example: Java**

Java

```
public class Stack {
    private int size = 0;
    private Object[] elements;

    // Private method: Internal logic only.
    // We assume the caller (our own public methods) handles bounds correctly.
    private void internalPush(Object element) {
        // Invariant check: Size should never be negative
        assert size >= 0 : "Stack size is negative: " + size;
        
        // Post-condition check is valid here
        int oldSize = size;
        elements[size++] = element;
        
        // Ensure state changed as expected
        assert size == oldSize + 1 : "Size did not increment";
    }

    public void push(Object element) {
        // Public API: Validate input with Exceptions, NOT assertions
        if (element == null) {
            throw new IllegalArgumentException("Cannot push null");
        }
        internalPush(element);
    }
}
```

**Example: Python**

Python

```
def calculate_discount(price, discount_rate):
    # Public argument validation: Use Exceptions
    if price < 0:
        raise ValueError("Price cannot be negative")
    
    # Internal logic verification
    final_price = price * (1 - discount_rate)

    # Assertion: The result of this logic must logically be <= original price
    # If this fails, the math above is wrong.
    assert final_price <= price, f"Final price {final_price} > original {price}"
    
    return final_price

def process_data(data_list):
    # Bad Practice: Side effect in assertion
    # If optimization (-O) is on, pop() never happens.
    # assert data_list.pop() == "header" 
    
    # Good Practice
    header = data_list.pop()
    assert header == "header", f"Expected 'header', got {header}"
```

---

