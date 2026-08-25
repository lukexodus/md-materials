## **Scope Resolution**


The **scope resolution operator (`::`)** in C++ is used to access a member or function that is out of the current scope. It is particularly useful when handling **global and local variable conflicts, class inheritance, namespaces, and static members**.

---

### **Accessing Global Variables**

If a **local variable** has the same name as a **global variable**, the `::` operator allows access to the global variable.

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

int x = 10; // Global variable

int main() {
    int x = 20; // Local variable
    cout << "Local x: " << x << endl;
    cout << "Global x: " << ::x << endl; // Accessing global x
}
```

**Output:**

```
Local x: 20
Global x: 10
```

---

### **Accessing Static Class Members**

Static members belong to the class rather than an instance, so they must be accessed using the class name and `::`.

✅ **Example:**

```cpp
class Test {
public:
    static int count; // Declaration
};

int Test::count = 5; // Definition

int main() {
    cout << "Static count: " << Test::count << endl;
}
```

**Output:**

```
Static count: 5
```

---

### **Defining Class Member Functions Outside the Class**

The `::` operator is used when defining **member functions outside the class definition**.

✅ **Example:**

```cpp
class MyClass {
public:
    void show(); // Function declaration
};

void MyClass::show() {  // Function definition using scope resolution
    cout << "Hello from MyClass" << endl;
}

int main() {
    MyClass obj;
    obj.show();
}
```

**Output:**

```
Hello from MyClass
```

---

### **Accessing Base Class Members in Inheritance**

When a derived class overrides a base class function, you can access the base class version using `::`.

✅ **Example:**

```cpp
class Parent {
public:
    void show() { cout << "Parent class\n"; }
};

class Child : public Parent {
public:
    void show() { cout << "Child class\n"; }
    void display() { Parent::show(); }  // Accessing base class function
};

int main() {
    Child obj;
    obj.show();
    obj.display();  // Calls Parent's show()
}
```

**Output:**

```
Child class
Parent class
```

---

### **Accessing Namespaces**

The `::` operator is used to access members inside a **specific namespace**.

✅ **Example:**

```cpp
#include <iostream>
namespace First {
    int x = 10;
}

namespace Second {
    int x = 20;
}

int main() {
    cout << "First::x: " << First::x << endl;
    cout << "Second::x: " << Second::x << endl;
}
```

**Output:**

```
First::x: 10
Second::x: 20
```

---

### **Key Points**

✅ **Use `::` to access global variables when shadowed by local variables.**  
✅ **Access static class members using `ClassName::member`.**  
✅ **Define class functions outside the class with `ClassName::FunctionName()`.**  
✅ **Access base class members in inheritance using `BaseClass::Function()`.**  
✅ **Use `::` to access specific namespaces in case of naming conflicts.**

***
