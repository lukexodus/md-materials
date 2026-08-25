## **Class Templates**


A **class template** allows creating **generic classes** that work with different data types, making code more reusable and flexible.

---

### **Syntax of Class Templates**

A class template is defined using the `template` keyword followed by **template parameters** inside angle brackets (`<>`).

```cpp
template <typename T>
class ClassName {
private:
    T data;
public:
    ClassName(T value) : data(value) {}  // Constructor
    void show() { cout << data << endl; } // Member function
};
```

- `T` is a **placeholder** for a data type.
- `typename` and `class` can be used interchangeably in templates.

---

### **Example: Generic Class for a Box**

✅ **Example:** A generic class that stores and displays a value.

```cpp
#include <iostream>
using namespace std;

template <typename T>
class Box {
private:
    T value;
public:
    Box(T val) : value(val) {}  
    void show() { cout << "Value: " << value << endl; }
};

int main() {
    Box<int> intBox(10);
    Box<double> doubleBox(5.5);
    Box<string> stringBox("Hello");

    intBox.show();
    doubleBox.show();
    stringBox.show();
}
```

**Output:**

```
Value: 10
Value: 5.5
Value: Hello
```

---

### **Class Templates with Multiple Parameters**

✅ **Example:** A class template with **two** data types.

```cpp
template <typename T1, typename T2>
class Pair {
private:
    T1 first;
    T2 second;
public:
    Pair(T1 a, T2 b) : first(a), second(b) {}
    void show() { cout << "First: " << first << ", Second: " << second << endl; }
};

int main() {
    Pair<int, double> p1(10, 3.14);
    Pair<string, char> p2("Alice", 'A');

    p1.show();
    p2.show();
}
```

**Output:**

```
First: 10, Second: 3.14
First: Alice, Second: A
```

---

**Key Points**

✅ **Class templates** allow creating **generic** classes that work with different data types.  
✅ The **`template` keyword** defines templates, and `typename` or `class` declares type placeholders.  
✅ **Multiple template parameters** can be used for handling multiple types.  
✅ The compiler **instantiates** specific class versions based on the types used.

---

