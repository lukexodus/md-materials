## **Overloading Arithmetic and Relational Operators**


C++ allows **operator overloading**, enabling **user-defined types** (classes) to use **arithmetic** and **relational** operators just like built-in types.

---

### **Overloading Arithmetic Operators**

Arithmetic operators (`+`, `-`, `*`, `/`, `%`) can be overloaded to perform operations on objects.

#### **Example: Overloading `+` for a Complex Number Class**

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

class Complex {
public:
    int real, imag;
    
    Complex(int r, int i) : real(r), imag(i) {}

    // Overloading +
    Complex operator+(const Complex& c) {
        return Complex(real + c.real, imag + c.imag);
    }

    void show() { cout << real << " + " << imag << "i" << endl; }
};

int main() {
    Complex c1(3, 4), c2(1, 2);
    Complex c3 = c1 + c2;  // Using overloaded +
    c3.show();
}
```

**Output:**

```
4 + 6i
```

---

### **Overloading Relational Operators**

Relational operators (`==`, `!=`, `<`, `>`, `<=`, `>=`) can be overloaded to compare objects.

#### **Example: Overloading `==` for a Point Class**

✅ **Example:**

```cpp
class Point {
public:
    int x, y;
    
    Point(int a, int b) : x(a), y(b) {}

    // Overloading ==
    bool operator==(const Point& p) {
        return (x == p.x && y == p.y);
    }
};

int main() {
    Point p1(2, 3), p2(2, 3), p3(4, 5);

    cout << (p1 == p2) << endl;  // 1 (true)
    cout << (p1 == p3) << endl;  // 0 (false)
}
```

**Output:**

```
1
0
```

---

**Key Points**

✅ **Operator overloading makes custom types behave like built-in types.**  
✅ **Arithmetic operators can be overloaded for mathematical operations on objects.**  
✅ **Relational operators can be overloaded for object comparisons.**  
✅ **Operators should be overloaded as `const` member functions when they do not modify the object.**

---

