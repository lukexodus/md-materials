## **Abstract Classes and Interfaces**


C++ does not have a built-in `interface` keyword like Java, but it achieves similar functionality using **abstract classes** with **pure virtual functions**.

---

### **Abstract Classes**

An **abstract class** is a class that **cannot be instantiated**. It serves as a blueprint for derived classes and contains at least one **pure virtual function**.

#### **Pure Virtual Function Syntax**

```cpp
virtual returnType functionName(parameters) = 0;
```

**Example:**

```cpp
#include <iostream>
using namespace std;

class Shape {  // Abstract class
public:
    virtual void draw() = 0;  // Pure virtual function
};

class Circle : public Shape {
public:
    void draw() override {  // Implementing the pure virtual function
        cout << "Drawing a Circle" << endl;
    }
};

class Square : public Shape {
public:
    void draw() override {
        cout << "Drawing a Square" << endl;
    }
};

int main() {
    // Shape shape; ❌ Error: Cannot instantiate an abstract class
    Circle c;
    Square s;

    c.draw();  // Output: Drawing a Circle
    s.draw();  // Output: Drawing a Square

    return 0;
}
```

**Key Points:**

- Abstract classes **cannot be instantiated**.
- Derived classes **must override all pure virtual functions**.
- Used when a **common interface** is needed for multiple derived classes.

---

### **Interfaces in C++ (Using Abstract Classes)**

In C++, **interfaces** are implemented using **abstract classes with only pure virtual functions** (no data members or concrete functions).

**Example:**

```cpp
#include <iostream>
using namespace std;

class IAnimal {  // Interface (pure abstract class)
public:
    virtual void makeSound() = 0;  // Pure virtual function
};

class Dog : public IAnimal {
public:
    void makeSound() override {
        cout << "Bark! Bark!" << endl;
    }
};

class Cat : public IAnimal {
public:
    void makeSound() override {
        cout << "Meow! Meow!" << endl;
    }
};

int main() {
    Dog dog;
    Cat cat;

    dog.makeSound();  // Output: Bark! Bark!
    cat.makeSound();  // Output: Meow! Meow!

    return 0;
}
```

**Key Points:**

- **Interfaces** in C++ are **abstract classes with only pure virtual functions**.
- They define a **contract** that derived classes must follow.
- Unlike Java, C++ allows **multiple inheritance**, so a class can inherit multiple interfaces.

---

**Comparison Table**

|Feature|Abstract Class|Interface (Pure Abstract Class)|
|---|---|---|
|Can have variables|✅ Yes|❌ No|
|Can have function implementations|✅ Yes (non-pure virtual functions)|❌ No (only pure virtual functions)|
|Can be instantiated|❌ No|❌ No|
|Multiple inheritance|✅ Yes|✅ Yes|

---

**When to Use Which?**

✅ **Use Abstract Classes** when:

- You need **some** implemented methods.
- You want to provide **default functionality** in a base class.

✅ **Use Interfaces** when:

- You need a **strict contract** with only method declarations.
- You are designing **multiple inheritance** structures.

---

