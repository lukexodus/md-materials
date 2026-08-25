## Test coverage goals


Test coverage goals refer to the target metrics set by an engineering team to quantify the extent to which their source code is executed when the test suite runs. While coverage is a useful indicator of code that _is not_ tested, it is a poor indicator of code that _is_ well-tested. Establishing goals involves balancing the cost of writing tests against the risk of undetected defects, moving beyond arbitrary percentages to focus on risk-based coverage.

**Key Points**

- **Metric Types:**
    
    - **Line/Statement Coverage:** The percentage of code lines executed. This is the most basic and common metric but can be misleading as it ignores logic branches.
        
    - **Branch/Decision Coverage:** Ensures that every possible branch (true/false) from each decision point (if, switch) is executed. This is a robust goal for complex logic.
        
    - **Path Coverage:** Measures if every possible execution path through a function has been taken. Often impossible to achieve 100% due to combinatorial explosion.
        
    - **Mutation Score:** A more advanced goal where bugs (mutants) are deliberately introduced to see if the tests fail. High mutation scores indicate a high-quality test suite.
        
- **The Fallacy of 100%:** A generic goal of 100% coverage is often counterproductive. It leads to:
    
    - **Assertion-free tests:** Tests that run code just to bump the counter without verifying behavior.
        
    - **Testing trivial code:** Wasting effort on getters/setters or auto-generated code.
        
    - **False confidence:** Believing the system is bug-free because lines were touched, even if edge cases were missed.
        
- **Context-Driven Goals:**
    
    - **Core Business Logic:** Aim for high coverage (90-100%) with strong branch coverage.
        
    - **Boilerplate/Configuration:** Lower coverage is acceptable; integration tests often cover this implicitly.
        
    - **Legacy Code:** Enforce "coverage on new code." Do not mandate back-filling coverage unless refactoring. Use "diff coverage" as a gatekeeper.
        
- **Trend Analysis:** The trajectory of coverage is often more important than the absolute number. A sudden drop indicates technical debt is being introduced.
    

**Example**

The following comparison illustrates why a raw percentage goal is insufficient and how branch coverage reveals gaps that line coverage hides.

_Scenario: A function to calculate a discount._

JavaScript

```
function calculateDiscount(price, isMember) {
    let finalPrice = price;
    if (isMember) {
        finalPrice = price * 0.90; // 10% off
    }
    return finalPrice;
}
```

_Test A (Achieves 100% Line Coverage, Low Confidence):_

JavaScript

```
test('calculates discount for member', () => {
    // This executes every line in the function.
    // Line Coverage: 100%
    // Branch Coverage: 50% (The 'false' case of isMember is never tested)
    expect(calculateDiscount(100, true)).toBe(90);
});
```

_Test B (Achieves 100% Branch Coverage, High Confidence):_

JavaScript

```
test('calculates discount for member', () => {
    expect(calculateDiscount(100, true)).toBe(90);
});

test('calculates no discount for non-member', () => {
    // This tests the implicit 'else' path.
    // Line Coverage: 100%
    // Branch Coverage: 100%
    expect(calculateDiscount(100, false)).toBe(100);
});
```

**Conclusion**

Test coverage goals should be treated as a tool for identifying gaps rather than a KPI for developer performance. The ideal strategy involves strict goals (high branch coverage) for complex, high-risk modules and relaxed goals for low-risk or declarative code. The ultimate goal is not to execute every line of code, but to verify every requirement and behavior.

---

