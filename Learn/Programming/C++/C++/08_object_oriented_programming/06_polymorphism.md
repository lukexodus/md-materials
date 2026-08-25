## Polymorphism


Polymorphism allows objects to take on multiple forms. It's achieved through function overriding and function overloading. It allows methods to be overridden in derived classes and enables functions to operate on objects of multiple classes through a common interface.

- **Function Overriding**: Redefining a base class function in a derived class with the same signature.
- **Function Overloading**: Defining multiple functions with the same name but different parameter lists.

### **Types of Polymorphism**

C++ supports two types:

1. **Compile-time Polymorphism (Static Binding)**
    - Function Overloading
    - Operator Overloading
    - Templates
2. **Run-time Polymorphism (Dynamic Binding)**
    - Function Overriding
    - Virtual Functions

---

### **Compile-time Polymorphism (Static Binding)**

#### **Function Overloading**

Multiple functions with the **same name** but different **parameter lists**.

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

class Math {
public:
    int add(int a, int b) { return a + b; }
    double add(double a, double b) { return a + b; }  // Overloaded function
};

int main() {
    Math obj;
    cout << obj.add(5, 10) << endl;      // Calls int version
    cout << obj.add(2.5, 3.5) << endl;  // Calls double version
}
```

**Output:**

```
15
6
```

---

#### **Operator Overloading**

Allows operators to be redefined for **user-defined types**.

✅ **Example:**

```cpp
class Complex {
public:
    int real, imag;
    Complex(int r, int i) : real(r), imag(i) {}

    Complex operator+(const Complex& c) {  // Overloading +
        return Complex(real + c.real, imag + c.imag);
    }

    void show() { cout << real << " + " << imag << "i" << endl; }
};

int main() {
    Complex c1(3, 4), c2(2, 5);
    Complex c3 = c1 + c2;  // Using overloaded +
    c3.show();
}
```

**Output:**

```
5 + 9i
```

---

### **Run-time Polymorphism (Dynamic Binding)**

#### **Function Overriding**

A **derived class** provides a new definition for a **base class function** with the **same signature**.

✅ **Example:**

```cpp
class Parent {
public:
    virtual void show() { cout << "Parent class\n"; }
};

class Child : public Parent {
public:
    void show() override { cout << "Child class\n"; }  // Overriding base class function
};

int main() {
    Parent* p;
    Child obj;
    p = &obj;
    p->show();  // Calls Child's show() due to virtual function
}
```

**Output:**

```
Child class
```

---

#### **Virtual Functions**

A function in a **base class** marked with `virtual` ensures that the **derived class function** is called, even when accessed through a **base class pointer**.

✅ **Example:**

```cpp
class Animal {
public:
    virtual void makeSound() { cout << "Animal sound\n"; }
};

class Dog : public Animal {
public:
    void makeSound() override { cout << "Woof!\n"; }
};

int main() {
    Animal* a;
    Dog d;
    a = &d;
    a->makeSound();  // Calls Dog's makeSound() due to virtual function
}
```

**Output:**

```
Woof!
```

---

**Key Points**

✅ **Polymorphism allows functions to behave differently based on input or object type.**  
✅ **Compile-time polymorphism (static binding) includes function overloading and operator overloading.**  
✅ **Run-time polymorphism (dynamic binding) includes function overriding and virtual functions.**  
✅ **Use `virtual` for base class functions to enable overriding.**

---

