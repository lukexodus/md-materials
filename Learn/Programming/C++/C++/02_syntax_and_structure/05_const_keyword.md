## `const` keyword


The `const` keyword is used to declare entities (variables, functions, etc.) as constant, indicating that their value cannot be changed after initialization.

### Constant Variables:

```cpp
const int SIZE = 10; // Declare a constant integer variable
```

In this example, `SIZE` is a constant integer variable, and its value cannot be modified once it's initialized.

### Benefits of `const`:

- **Safety**: Helps prevent accidental modification of variables.
- **Readability**: Clearly indicates intent and usage of entities.
- **Compiler Optimization**: Enables the compiler to perform optimizations, knowing that values won't change.

