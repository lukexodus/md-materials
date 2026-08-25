## **Function Templates**


A **function template** allows writing **generic functions** that work with different data types without rewriting the function for each type.

---

### **Syntax of Function Templates**

A function template is defined using the `template` keyword followed by **template parameters** inside angle brackets (`<>`).

```cpp
template <typename T>
T functionName(T arg) {
    // Function body
}
```

- `T` is a **placeholder** for a data type (e.g., `int`, `double`, `char`).
- `typename` and `class` are interchangeable in templates.

---

### **Example: Template for Finding Maximum**

✅ **Example:** A generic function to find the maximum of two values.

```cpp
#include <iostream>
using namespace std;

template <typename T>
T getMax(T a, T b) {
    return (a > b) ? a : b;
}

int main() {
    cout << getMax(10, 20) << endl;      // Works with int
    cout << getMax(5.5, 2.3) << endl;    // Works with double
    cout << getMax('a', 'z') << endl;    // Works with char
}
```

**Output:**

```
20
5.5
z
```

---

### **Function Templates with Multiple Parameters**

Templates can accept **multiple types** using multiple template parameters.

✅ **Example:** A function to swap two values of different types.

```cpp
template <typename T1, typename T2>
void swapValues(T1 &a, T2 &b) {
    cout << "Before swap: " << a << " " << b << endl;
    T1 temp = a;
    a = b;
    b = temp;
    cout << "After swap: " << a << " " << b << endl;
}

int main() {
    int x = 5;
    double y = 3.2;
    swapValues(x, y);
}
```

**Output:**

```
Before swap: 5 3.2
After swap: 3 5
```

---

**Key Points**

✅ **Function templates** allow writing generic functions for multiple data types.  
✅ The **`template` keyword** defines templates, and `typename` or `class` declares type placeholders.  
✅ **Multiple template parameters** can be used for functions handling multiple types.  
✅ The compiler generates **specific function versions** based on the types used during function calls.

---

