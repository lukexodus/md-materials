## Function Overloading


Function overloading in C++ is a feature that allows you to have multiple functions with the same name but different parameters within the same scope. The compiler differentiates these functions based on the number, type, and order of the parameters. This is particularly useful when you want to perform similar operations but with different types or numbers of arguments.

**Key Points of Function Overloading**:
1. **Same Name, Different Parameters:** All overloaded functions must have the same name, but they must differ in the parameter list (either in the number of parameters, their types, or both).
2. **Return Type:** The return type of the functions can be different, but it alone cannot be used to distinguish overloaded functions. The parameter list must be different.
3. **Compile-Time Polymorphism:** Function overloading is an example of compile-time polymorphism, meaning the decision about which function to call is made at compile time based on the arguments passed.

**Example of Function Overloading**:
```cpp
#include <iostream>
using namespace std;

// Function to add two integers
int add(int a, int b) {
    return a + b;
}

// Function to add three integers
int add(int a, int b, int c) {
    return a + b + c;
}

// Function to add two doubles
double add(double a, double b) {
    return a + b;
}

int main() {
    cout << "add(10, 20) = " << add(10, 20) << endl;           // Calls int add(int, int)
    cout << "add(10, 20, 30) = " << add(10, 20, 30) << endl;   // Calls int add(int, int, int)
    cout << "add(10.5, 20.5) = " << add(10.5, 20.5) << endl;   // Calls double add(double, double)
    return 0;
}
```

**Output**:
```
add(10, 20) = 30
add(10, 20, 30) = 60
add(10.5, 20.5) = 31
```

### How Function Overloading Works:
- **Matching Arguments:** When a function is called, the compiler looks for the function whose parameter list matches the arguments passed. If a match is found, that function is called.
- **Ambiguity:** If the compiler finds two or more functions that could match the call (e.g., due to implicit type conversions), it results in a compile-time error due to ambiguity.

### Overloading and Default Arguments:
When using function overloading, be cautious with default arguments. If two overloaded functions could potentially be called with the same set of arguments (considering default values), it might create ambiguity.

### Example of Potential Ambiguity:
```cpp
void func(int a, int b = 10) { /*...*/ }
void func(int a) { /*...*/ }
```
Calling `func(5);` in this scenario would be ambiguous, as it could match either of the overloaded functions.

### Benefits of Function Overloading:
- **Code Readability:** Makes the code easier to understand by using the same function name for similar operations.
- **Convenience:** Allows the programmer to define multiple functions that perform similar tasks but with different data types or parameters.

In summary, function overloading is a powerful tool in C++ that allows for more flexible and readable code by enabling functions with the same name to handle different types or numbers of arguments.

---

