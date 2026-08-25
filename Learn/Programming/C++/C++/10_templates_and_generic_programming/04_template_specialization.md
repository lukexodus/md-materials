## **Template Specialization**


Template specialization allows customizing the behavior of a **template** for a **specific data type**.

### **Syntax of Template Specialization**

```cpp
template <typename T>
class ClassName {
    // General template definition
};

// Specialized template for a specific type
template <>
class ClassName<SpecificType> {
    // Specialized behavior
};
```

---

### **Example: Template Specialization for `char` Type**

✅ **Example:** A generic class template that handles all types but has a special implementation for `char`.

```cpp
#include <iostream>
using namespace std;

// General template
template <typename T>
class Printer {
public:
    static void print(T value) {
        cout << "Value: " << value << endl;
    }
};

// Specialized template for `char`
template <>
class Printer<char> {
public:
    static void print(char value) {
        cout << "Character: '" << value << "'" << endl;
    }
};

int main() {
    Printer<int>::print(100);
    Printer<double>::print(3.14);
    Printer<char>::print('A');  // Uses specialized template
}
```

**Output:**

```
Value: 100
Value: 3.14
Character: 'A'
```

✅ **When to Use Template Specialization?**

- When a **specific data type** needs **different behavior** from the general template.
- When **optimizing performance** for particular types.

---

