## **Other Standard Exceptions in C++**


C++ provides additional standard exceptions that handle **memory allocation, type casting, type identification, and unexpected exceptions**.

### **`std::bad_alloc`**

Thrown when **memory allocation fails** using `new`.

**Example: Failing to Allocate a Huge Memory Block**

```cpp
#include <iostream>
#include <new>  // std::bad_alloc
using namespace std;

int main() {
    try {
        int* arr = new int[1'000'000'000'000];  // Too large
    }
    catch (const bad_alloc& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: std::bad_alloc
```

---

### **`std::bad_cast`**

Thrown when **dynamic casting fails** with `dynamic_cast<>` on polymorphic types.

**Example: Invalid Downcasting with `dynamic_cast`**

```cpp
#include <iostream>
#include <typeinfo>
using namespace std;

class Base { virtual void dummy() {} };
class Derived : public Base {};

int main() {
    try {
        Base* b = new Base();
        Derived* d = dynamic_cast<Derived*>(b);  // Invalid cast
        if (!d) throw bad_cast();
    }
    catch (const bad_cast& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: std::bad_cast
```

---

### **`std::bad_typeid`**

Thrown when trying to **get the type of a null pointer** to a polymorphic base class.

**Example: Calling `typeid` on a Null Pointer**

```cpp
#include <iostream>
#include <typeinfo>
using namespace std;

class Base { virtual void dummy() {} };

int main() {
    try {
        Base* b = nullptr;
        cout << typeid(*b).name();  // Causes bad_typeid
    }
    catch (const bad_typeid& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: std::bad_typeid
```

---

### **`std::bad_exception`**

Used to handle **unexpected exceptions** in `throw()` (deprecated in C++11, but still recognized).

**Example: Catching Unexpected Exceptions**

```cpp
#include <iostream>
#include <exception>
using namespace std;

void unexpectedHandler() {
    cout << "Unexpected exception caught!" << endl;
    throw;  // Rethrow
}

int main() {
    set_unexpected(unexpectedHandler);
    
    try {
        throw 42;  // Not declared in throw specifier
    }
    catch (const bad_exception& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Unexpected exception caught!
Exception: std::bad_exception
```

---

**Key Points**  
✅ **`std::bad_alloc`** → Used when **memory allocation fails**.  
✅ **`std::bad_cast`** → Used when **dynamic casting fails**.  
✅ **`std::bad_typeid`** → Used when **`typeid` is called on a null pointer**.  
✅ **`std::bad_exception`** → Used for **unexpected exceptions (legacy feature)**.

---

