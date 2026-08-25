## Test Coverage Review


**Key Points**

- **Beyond Line Coverage (The "Happy Path" Trap):**
    
    - **Statement/Line Coverage:** Measures if a line was executed. It is the weakest metric as it does not verify logic, only execution flow. 100% line coverage can still hide 100% of bugs if assertions are missing.
        
    - **Branch/Decision Coverage:** Measures if every `if`, `else`, `case`, and loop entry/exit has been taken. This is the minimum acceptable standard for critical business logic.
        
    - **Condition/Path Coverage:** Verifies every combination of boolean sub-expressions (e.g., in `if A or B`, test `T/F`, `F/T`, `F/F`).
        
- **The "Assertion Roulette" Anti-Pattern:** A high coverage score often hides tests that execute code but lack meaningful assertions. During review, verify that execution is accompanied by state verification (asserting return values, database states, or side effects).
    
- **Mutation Testing:** The only metric that tests the tests. It introduces small changes ("mutants") to the code (e.g., changing `>` to `>=` or `+` to `-`) and checks if the test suite fails. If tests pass despite the code being broken, the coverage is superficial.
    
- **Exclusion Configuration:** Review `coveragerc` or equivalent configuration files. Ensure that Data Transfer Objects (DTOs), auto-generated code, and configuration boilerplate are excluded to prevent inflation of the coverage score.
    
- **Differential Coverage:** Focus reviews on the coverage of _new_ code (the delta) rather than the aggregate total. A PR should not decrease the overall coverage percentage and ideally should have effectively 100% coverage on the changed lines.
    

**Example**

The following Python example demonstrates a scenario where **Line Coverage is 100%**, but **Branch Coverage is incomplete**, and a bug remains undetected.

_Code Under Review:_

Python

```
def process_payment(amount, is_verified):
    # Logic: Only process if amount is positive.
    # Logic: If user is verified, give 10% discount.
    
    discount = 0
    if is_verified:          # Branch A
        discount = 0.10
    
    final_amount = amount * (1 - discount)
    
    if final_amount > 1000:  # Branch B
        return "Requires Approval"
    
    return "Processed"
```

_Bad Test Suite (100% Line Coverage, Weak Verification):_

Python

```
def test_process_payment_happy_path():
    # This test executes every line of code in the function
    # result = process_payment(2000, True)
    # Line execution:
    # 1. is_verified is True -> enters Branch A (discount set)
    # 2. final_amount becomes 1800 (2000 * 0.9)
    # 3. 1800 > 1000 -> enters Branch B (returns "Requires Approval")
    
    assert process_payment(2000, True) == "Requires Approval"
```

Review Finding:

While every line ran, we never tested:

1. `is_verified = False` (Does the default discount remain 0?)
    
2. `final_amount <= 1000` (Does it return "Processed"?)
    
3. `amount` logic (What if amount is negative? The code doesn't handle it, but coverage implies it's "tested".)
    

**Output**

A sophisticated coverage report (like JaCoCo for Java or Istanbul for JS) produces a branch analysis. The text output below highlights the missing scenarios from the example above.

Plaintext

```
----------------------------------------------------------------------
File: payment_processor.py
Stmts   Miss  Cover   Missing
----------------------------------------------------------------------
12      0     100%           
----------------------------------------------------------------------
Branch Analysis:
Line 5:  if is_verified:      -> 50% (Missing: False)
Line 10: if final_amount > 1000: -> 50% (Missing: False)
----------------------------------------------------------------------
Total Branch Coverage: 50%
```

**Conclusion**

Test coverage is a negative metric: low coverage guarantees low quality, but high coverage does not guarantee high quality. The goal of a Test Coverage Review is not to chase a number (e.g., 90%), but to identify **logic gaps**, **missing branches**, and **unasserted side effects**. High-quality reviews treat coverage reports as a heatmap for where to look closer, not as a badge of completion.

---

