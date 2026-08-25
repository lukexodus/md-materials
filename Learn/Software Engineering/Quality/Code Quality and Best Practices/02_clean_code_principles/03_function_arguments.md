## Function arguments


The ideal number of arguments for a function is zero (niladic). Next comes one (monadic), followed closely by two (dyadic). Three arguments (triadic) should be avoided where possible. More than three (polyadic) requires very special justification and should generally be refactored.

**Key Points**

- **Cognitive Load:** Arguments are hard. They take a lot of conceptual power. You can't easily include a function call in your mental reasoning without understanding its arguments. Reading a function signature with multiple arguments forces the reader to interpret intent, order, and type for every single parameter.
    
- **Testing Difficulty:** Arguments complicate testing significantly. Writing test cases for a function with zero arguments is trivial. Writing tests for a function with three arguments requires testing every combination of those three values (Cartesian product), which often leads to combinatorial explosion in test scenarios.1
    
- **Common Forms:2**
    
    - **Niladic 3(0):** Absolute best for readability. `user.getName()` is clear.
        
    - **Monadic (1):** Usually used for asking a question about the argument (`boolean fileExists("MyFile")`) or transforming the argument (`InputStream fileOpen("MyFile")`).
        
    - **Dyadic (2):** Acceptable for natural pairs, such as Cartesian coordinates (`new Point(0, 0)`). If the two arguments are not naturally ordered or cohesive, they add confusion (e.g., `assertEquals(expected, actual)` vs `assertEquals(actual, expected)`).
        
- **Flag Arguments:** Passing a boolean into a function is a terrible practice. It immediately complicates the signature and loudly proclaims that the function does more than one thing: it does one thing if the flag is true and another if the flag is false. Split the function into two separate functions (e.g., `renderForSuite()` and `renderForSingleTest()` instead of `render(boolean isSuite)`).
    
- **Argument Objects:** If a function seems to need more than two or three arguments, it is likely that some of those arguments should be wrapped into a class of their own.
    
    - _Before:_ `Circle makeCircle(double x, double y, double radius);`
        
    - _After:_ `Circle makeCircle(Point center, double radius);`
        
    - When arguments are grouped, they often represent a new concept (e.g., `x` and `y` become a `Point`).
        
- **Verbs and Keywords:** In monads, the function and argument should form a nice verb/noun pair, like `write(name)`. For polyadic functions, it may be necessary to encode the names of the arguments into the function name to alleviate ordering confusion, e.g., `assertExpectedEqualsActual(expected, actual)`.
    

**Example**

**Bad Practice:**

Java

```
// What does true mean here?
// What is the order of start and end dates?
MetricsCalculator.calculate(true, 2023, 12, 1, 2024, 1, 1);
```

**Refactored:**

Java

```
// Flag argument removed.
// Date components encapsulated in DateRange object.
DateRange fiscalYear = new DateRange(startDate, endDate);
MetricsCalculator.calculateSoftMetrics(fiscalYear);
```

---

