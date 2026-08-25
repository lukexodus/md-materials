## References


In C++, a reference is an alias or alternative name for an existing variable. It provides a way to access and manipulate the same data as the original variable without creating a copy. Here's an overview of references in C++:

### Declaring References:

```cpp
int x = 10;
int& ref = x; // Reference to variable x
```

- The `&` symbol denotes that `ref` is a reference.
- References must be initialized when declared and cannot be reassigned to refer to another variable.

### Using References:

```cpp
int x = 10;
int& ref = x;

std::cout << ref << std::endl; // Prints the value of x through the reference

ref = 20; // Changes the value of x through the reference
std::cout << x << std::endl;   // Prints 20
```

- Modifying the reference also modifies the original variable.
- Any changes made to the reference are reflected in the original variable and vice versa.

### References as Function Parameters:

```cpp
void increment(int& num) {
    num++;
}

int main() {
    int x = 10;
    increment(x); // Passes x by reference
    std::cout << x << std::endl; // Prints 11
    return 0;
}
```

- Passing by reference allows functions to modify the original variables.
- Changes made to the parameter inside the function affect the original argument.

### Benefits of References:

- **Efficiency**: References avoid the overhead of copying large objects.
- **Convenience**: Provide a cleaner syntax for passing variables to functions.
- **Expressiveness**: Clearly indicate when a function can modify its arguments.

### Restrictions and Best Practices:

- **Initialization**: References must be initialized when declared and cannot be null.
- **Lifetime**: References must refer to valid objects throughout their lifetime.
- **Scope**: References are bound to the scope in which they are declared.

***

