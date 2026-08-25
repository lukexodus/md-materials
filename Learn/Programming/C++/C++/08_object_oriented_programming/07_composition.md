## **Composition**


**Composition** is a type of object relationship in C++ where one class contains objects of another class as **data members**. It represents a **"has-a"** relationship and enables **code reuse and modular design**.

---

### **Key Characteristics**

✅ **Strong ownership** – The contained object (part) cannot exist independently of the containing object (whole).  
✅ **Lifetime dependency** – The contained object's lifecycle is tied to the owner.  
✅ **Used for code reusability** – Helps build complex objects by combining simpler ones.

---

### **Example: A Car Has an Engine**

A **Car** object contains an **Engine** object. The **Engine** is part of the Car and does not exist independently.

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

class Engine {
public:
    void start() { cout << "Engine started\n"; }
};

class Car {
private:
    Engine engine;  // Car has an Engine (composition)
public:
    void startCar() {
        engine.start();  // Using Engine's function
        cout << "Car started\n";
    }
};

int main() {
    Car myCar;
    myCar.startCar();
}
```

**Output:**

```
Engine started
Car started
```

---

### **Composition vs. Inheritance**

|Feature|Composition|Inheritance|
|---|---|---|
|Relationship|"Has-a"|"Is-a"|
|Flexibility|More flexible, allows modular design|Less flexible, rigid hierarchy|
|Reusability|Can reuse classes without inheritance|Reuses base class methods but ties subclasses|
|Object Lifespan|Contained object depends on the owner|Derived class object can exist independently|

✅ **Use Composition** when an object **contains** another object but **is not** a subclass of it.  
✅ **Use Inheritance** when a class **extends** another class and maintains an **"is-a"** relationship.

---

**Key Points**

✅ **Composition enables modular design and code reusability.**  
✅ **It defines a "has-a" relationship, meaning objects contain other objects.**  
✅ **Contained objects exist only as long as the containing object exists.**  
✅ **Preferred over inheritance when objects are independent but related.**

---
