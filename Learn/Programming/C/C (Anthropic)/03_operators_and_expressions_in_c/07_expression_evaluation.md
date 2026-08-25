## Expression Evaluation


Expression evaluation in C follows specific rules and can have side effects that affect program behavior.

**Sequence Points:** Sequence points are specific moments during execution where all side effects of previous evaluations are complete:

- End of full expression (statements ending with semicolon)
- After evaluation of first operand in `&&`, `||`, `?:`, and `,` operators
- Before function call (after argument evaluation)

**Undefined Behavior:** Modifying a variable multiple times between sequence points results in undefined behavior:

```c
i = ++i + 1;        // Undefined behavior
a[i] = i++;         // Undefined behavior
```

**Order of Evaluation:** [Unverified] The order of operand evaluation in most operators is unspecified, meaning the compiler can choose the order. Only `&&`, `||`, `?:`, and `,` operators guarantee left-to-right evaluation.

**Side Effects:** Operations that modify program state beyond returning a value:

- Assignment operations
- Increment and decrement operators
- Function calls that modify global variables or parameters

**Key Points:**

- Avoid expressions with multiple modifications to the same variable
- Use parentheses for clarity, even when not required by precedence
- Be aware that compiler optimizations may change evaluation order
- Function argument evaluation order is unspecified

**Example:**

```c
int i = 5;
int arr[10] = {0};

// Safe expressions
int a = i + 1;
int b = ++i;              // i becomes 6
int c = i++;              // c gets 6, i becomes 7

// Problematic expressions (undefined behavior)
// int d = i++ + ++i;     // Don't do this
// arr[i++] = i;          // Don't do this

// Using sequence points safely
if (i > 5 && ++i < 10) {  // i incremented only if first condition true
    printf("i is %d\n", i);
}
```

**Output:** The result of expression evaluation depends on operator precedence, associativity, and the specific values involved. Understanding these concepts is crucial for writing predictable and maintainable C code.

**Conclusion:** Mastering operators and expressions in C requires understanding not just individual operator behavior, but also their interactions through precedence, associativity, and evaluation rules. This knowledge forms the foundation for writing efficient and bug-free C programs.

**Next Steps:** Consider exploring advanced topics like the comma operator in detail, volatile keyword effects on expression evaluation, and compiler-specific optimization behaviors that can affect expression results.

---

