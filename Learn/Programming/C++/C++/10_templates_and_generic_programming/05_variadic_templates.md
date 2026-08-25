## **Variadic Templates**


Variadic templates allow **handling an arbitrary number of template parameters**, making templates more flexible.

### **Syntax of Variadic Templates**

```cpp
template <typename... Args>
class ClassName {
    // Variadic template definition
};
```

- `Args...` represents **a pack of types**.
- `sizeof...(Args)` gets the number of arguments.

### **Example: Variadic Function Template (Recursive Unpacking)**

✅ **Example:** A function template that prints multiple arguments.

```cpp
#include <iostream>
using namespace std;

// Base case: No arguments left to print
void print() {
    cout << "End of arguments." << endl;
}

// Variadic template function
template <typename First, typename... Rest>
void print(First first, Rest... rest) {
    cout << first << " ";
    print(rest...);  // Recursively call with remaining arguments
}

int main() {
    print(1, 2.5, "Hello", 'A');
}
```

**Output:**

```
1 2.5 Hello A End of arguments.
```

### **Example: Variadic Class Template**

✅ **Example:** A class template that stores a **tuple** of multiple types.

```cpp
#include <iostream>
#include <tuple>
using namespace std;

template <typename... Args>
class Data {
private:
    tuple<Args...> values;
public:
    Data(Args... args) : values(args...) {}

    void show() { cout << "Stored values in tuple!" << endl; }
};

int main() {
    Data<int, double, string> d(10, 3.14, "C++");
    d.show();
}
```

**Output:**

```
Stored values in tuple!
```

✅ **When to Use Variadic Templates?**

- When a **function/class** needs to handle **any number of parameters**.
- When designing **flexible, reusable** libraries.

---

**Key Points**

✅ **Template specialization** allows customizing templates for **specific data types**.  
✅ **Variadic templates** enable **handling multiple types dynamically**.  
✅ **Recursive unpacking** is a common technique for variadic functions.  
✅ **Use wisely** to balance flexibility and readability.

***

