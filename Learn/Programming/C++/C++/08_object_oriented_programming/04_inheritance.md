## Inheritance


Inheritance allows a class to inherit properties and behavior from another class. It promotes code reusability and establishes a hierarchical relationship between classes.

The derived class (subclass) inherits from the base class (superclass) and may add new attributes and methods or override existing ones. 

**Example**

```cpp
class Animal {
public:
    void sound() {
        std::cout << "Animal makes a sound." << std::endl;
    }
};

class Dog : public Animal {
public:
    void sound() {
        std::cout << "Dog barks." << std::endl;
    }
};

int main() {
    Dog myDog;
    myDog.sound(); // Calls sound() method of derived class
    return 0;
}
```

### **Types of Inheritance**

Inheritance is a key feature of **Object-Oriented Programming (OOP)** in C++ that allows a class to derive properties and behaviors from another class. This helps in **code reusability** and **extensibility**.

C++ supports five types of inheritance: **Single, Multiple, Multilevel, Hierarchical, and Hybrid.**

---

#### **Single Inheritance**

A **single derived class** inherits from **one base class**.

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

class Parent {
public:
    void show() { cout << "Parent class\n"; }
};

class Child : public Parent {  // Single Inheritance
public:
    void display() { cout << "Child class\n"; }
};

int main() {
    Child obj;
    obj.show();    // Inherited function
    obj.display(); // Child's own function
}
```

**Output:**

```
Parent class
Child class
```

---

#### **Multiple Inheritance**

A **single derived class** inherits from **more than one base class**.

✅ **Example:**

```cpp
class A {
public:
    void showA() { cout << "Class A\n"; }
};

class B {
public:
    void showB() { cout << "Class B\n"; }
};

class C : public A, public B {  // Multiple Inheritance
public:
    void showC() { cout << "Class C\n"; }
};

int main() {
    C obj;
    obj.showA();
    obj.showB();
    obj.showC();
}
```

**Output:**

```
Class A
Class B
Class C
```

**⚠️ Ambiguity Issue in Multiple Inheritance:**  
If both parent classes have the **same function name**, use **scope resolution (`A::show()`)** in the derived class to resolve ambiguity.

---

#### **Multilevel Inheritance**

A class derives from another **derived class**, forming a **chain of inheritance**.

✅ **Example:**

```cpp
class A {
public:
    void showA() { cout << "Class A\n"; }
};

class B : public A {
public:
    void showB() { cout << "Class B\n"; }
};

class C : public B {  // Multilevel Inheritance
public:
    void showC() { cout << "Class C\n"; }
};

int main() {
    C obj;
    obj.showA();  // Inherited from A
    obj.showB();  // Inherited from B
    obj.showC();  // Own function
}
```

**Output:**

```
Class A
Class B
Class C
```

---

#### **Hierarchical Inheritance**

Multiple derived classes inherit from a **single base class**.

✅ **Example:**

```cpp
class Parent {
public:
    void showParent() { cout << "Parent class\n"; }
};

class Child1 : public Parent {
public:
    void showChild1() { cout << "Child1 class\n"; }
};

class Child2 : public Parent {
public:
    void showChild2() { cout << "Child2 class\n"; }
};

int main() {
    Child1 obj1;
    obj1.showParent();
    obj1.showChild1();

    Child2 obj2;
    obj2.showParent();
    obj2.showChild2();
}
```

**Output:**

```
Parent class
Child1 class
Parent class
Child2 class
```

---

#### **Hybrid Inheritance (Combination of Two or More Types)**

It is a mix of **multiple, multilevel, and hierarchical inheritance**.

✅ **Example:**

```cpp
class A {
public:
    void showA() { cout << "Class A\n"; }
};

class B : public A {
public:
    void showB() { cout << "Class B\n"; }
};

class C {
public:
    void showC() { cout << "Class C\n"; }
};

class D : public B, public C {  // Hybrid Inheritance
public:
    void showD() { cout << "Class D\n"; }
};

int main() {
    D obj;
    obj.showA();  // From A via B
    obj.showB();  // From B
    obj.showC();  // From C
    obj.showD();  // From D
}
```

**Output:**

```
Class A
Class B
Class C
Class D
```

**⚠️ Diamond Problem in Hybrid Inheritance:**  
When a class inherits from two classes that both inherit from the same base class, it creates ambiguity. Use **virtual inheritance** to solve this issue.

---

**Key Points**

✅ **Single Inheritance:** One base class, one derived class.  
✅ **Multiple Inheritance:** One derived class inherits from multiple base classes (can cause ambiguity).  
✅ **Multilevel Inheritance:** Inheritance chain (A → B → C).  
✅ **Hierarchical Inheritance:** One base class, multiple derived classes.  
✅ **Hybrid Inheritance:** Combination of two or more types, can lead to the **diamond problem** (resolved using virtual inheritance).

---

