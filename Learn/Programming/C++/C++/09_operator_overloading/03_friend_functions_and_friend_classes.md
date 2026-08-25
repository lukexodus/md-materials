## **Friend Functions and Friend Classes**


In C++, **friend functions** and **friend classes** allow non-member functions or other classes to access private and protected members of a class.

---

### **Friend Functions**

A **friend function** is a non-member function that has access to the **private** and **protected** members of a class.

#### **When to Use Friend Functions?**

✅ When **two or more classes** need to access each other's private members.  
✅ When implementing **operator overloading** that requires access to private data.  
✅ When a function needs to **access class internals** without being a member.

#### **Example: Accessing Private Members**

```cpp
#include <iostream>
using namespace std;

class Box {
private:
    int width;
public:
    Box(int w) : width(w) {}

    // Declare friend function
    friend void showWidth(Box b);
};

// Friend function definition
void showWidth(Box b) {
    cout << "Width: " << b.width << endl;
}

int main() {
    Box b(10);
    showWidth(b);  // Accessing private member
}
```

**Output:**

```
Width: 10
```

---

### **Friend Classes**

A **friend class** allows all of its member functions to access the **private** and **protected** members of another class.

#### **When to Use Friend Classes?**

✅ When **two tightly coupled classes** need to share private data.  
✅ When an **auxiliary/helper class** needs full access to another class.  
✅ When a class must allow another class to modify its internals **without inheritance**.

#### **Example: Making a Class a Friend**

```cpp
class Engine {
private:
    int horsepower;
public:
    Engine(int hp) : horsepower(hp) {}

    // Declare Car as a friend
    friend class Car;
};

class Car {
public:
    void showEnginePower(Engine e) {
        cout << "Engine Power: " << e.horsepower << " HP" << endl; // Access private member
    }
};

int main() {
    Engine e(250);
    Car c;
    c.showEnginePower(e);
}
```

**Output:**

```
Engine Power: 250 HP
```

---

### **Key Points**

✅ **Friend functions** are non-member functions that access private members.  
✅ **Friend classes** allow full access to another class’s private and protected members.  
✅ **Friendship is not inherited** – derived classes do not get access automatically.  
✅ **Use friend functions/classes only when necessary** to maintain encapsulation.

---

