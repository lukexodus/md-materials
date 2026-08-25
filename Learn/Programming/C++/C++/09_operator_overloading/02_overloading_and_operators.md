## **Overloading `[]`, `()`, `->`, `<<`, and `>>` Operators**


C++ allows **overloading special operators** like `[]`, `()`, `->`, `<<`, and `>>` to extend functionality for **user-defined types** (classes).

---

### **Overloading `[]` (Subscript Operator)**

The subscript operator `[]` is often overloaded to access elements in **custom array-like structures**.

✅ **Example:** Implementing a **custom array class**

```cpp
#include <iostream>
using namespace std;

class Array {
private:
    int data[5];
public:
    Array() { for (int i = 0; i < 5; i++) data[i] = i * 10; }

    // Overloading []
    int& operator[](int index) {
        if (index < 0 || index >= 5) {
            throw out_of_range("Index out of range");
        }
        return data[index];
    }
};

int main() {
    Array arr;
    cout << arr[2] << endl;  // 20
    arr[2] = 50;
    cout << arr[2] << endl;  // 50
}
```

**Output:**

```
20
50
```

---

### **Overloading `()` (Function Call Operator)**

The function call operator `()` can be overloaded to make an object **callable like a function**.

✅ **Example:** Creating a **functor**

```cpp
class Multiply {
public:
    int operator()(int a, int b) {
        return a * b;
    }
};

int main() {
    Multiply mul;
    cout << mul(4, 5) << endl;  // 20
}
```

**Output:**

```
20
```

---

### **Overloading `->` (Arrow Operator)**

The arrow operator `->` is typically overloaded when using **smart pointers or proxy objects**.

✅ **Example:** Implementing a **custom smart pointer**

```cpp
class Demo {
public:
    void show() { cout << "Demo class\n"; }
};

class SmartPtr {
private:
    Demo* ptr;
public:
    SmartPtr(Demo* p) : ptr(p) {}

    // Overloading ->
    Demo* operator->() { return ptr; }
};

int main() {
    SmartPtr sp(new Demo());
    sp->show();  // Calls Demo::show()
}
```

**Output:**

```
Demo class
```

---

### **Overloading `<<` (Stream Insertion) and `>>` (Stream Extraction)**

These operators allow **custom objects** to be printed (`<<`) or read (`>>`) using **cin/cout**.

✅ **Example:** Overloading `<<` and `>>` for a **Point class**

```cpp
#include <iostream>
using namespace std;

class Point {
private:
    int x, y;
public:
    Point(int a = 0, int b = 0) : x(a), y(b) {}

    // Overloading >>
    friend istream& operator>>(istream& in, Point& p) {
        in >> p.x >> p.y;
        return in;
    }

    // Overloading <<
    friend ostream& operator<<(ostream& out, const Point& p) {
        out << "(" << p.x << ", " << p.y << ")";
        return out;
    }
};

int main() {
    Point p;
    cout << "Enter coordinates: ";
    cin >> p;  // Input format: x y
    cout << "Point: " << p << endl;
}
```

**Input:**

```
Enter coordinates: 3 4
```

**Output:**

```
Point: (3, 4)
```

---

**Key Points**

✅ **`[]` is used for custom array indexing.**  
✅ **`()` makes an object callable like a function.**  
✅ **`->` allows proxy objects to access members of another class.**  
✅ **`<<` and `>>` enable formatted input/output for user-defined types.**  
✅ **Overloading these operators makes objects more intuitive to use.**

---

