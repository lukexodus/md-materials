## **try, catch, throw**


Exception handling in C++ is done using `try`, `catch`, and `throw` statements. It allows a program to handle **runtime errors** (exceptions) gracefully instead of crashing.

---

### **Syntax of Exception Handling**

```cpp
try {
    // Code that may cause an exception
    throw exception_value;  // Throw an exception
} 
catch (exception_type variable) {
    // Handle the exception
}
```

---

### **Example: Division by Zero**

```cpp
#include <iostream>
using namespace std;

void divide(int a, int b) {
    if (b == 0) {
        throw "Division by zero error";  // Throw an exception
    }
    cout << "Result: " << a / b << endl;
}

int main() {
    try {
        divide(10, 0);  // This will cause an exception
    }
    catch (const char* msg) {  // Catch the thrown exception
        cout << "Exception: " << msg << endl;
    }
    return 0;
}
```

**Output:**

```
Exception: Division by zero error
```

---

### **Multiple Catch Blocks**

Different exception types can be caught separately.

```cpp
try {
    throw 10;
} 
catch (int e) {
    cout << "Integer exception: " << e << endl;
}
catch (double e) {
    cout << "Double exception: " << e << endl;
}
```

If an exception of type `int` is thrown, the first `catch` block executes.

---

### **Catching All Exceptions (`...`)**

The **ellipsis (`...`)** can catch any type of exception.

```cpp
try {
    throw 3.14;  
} 
catch (...) {  
    cout << "Exception caught!" << endl;
}
```

---

### **Custom Exception Class**

Exceptions can be handled using custom exception classes.

```cpp
class MyException : public exception {
public:
    const char* what() const throw() {
        return "Custom Exception Occurred!";
    }
};

int main() {
    try {
        throw MyException();
    } 
    catch (const exception& e) {
        cout << e.what() << endl;
    }
}
```

**Output:**

```
Custom Exception Occurred!
```

---

**Key Points**

✅ `throw` is used to **raise** an exception.  
✅ `try` **wraps** code that may cause an exception.  
✅ `catch` **handles** exceptions based on type.  
✅ Catch-all (`...`) is used to handle **unknown** exceptions.  
✅ Custom exceptions provide **detailed error handling**.

---

