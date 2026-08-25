## **Custom Exception Handling**


C++ allows defining **custom exceptions** by creating user-defined exception classes. This provides **more descriptive error handling** and allows programmers to define **specific error scenarios** for their applications.

---

### **Creating a Custom Exception Class**

A custom exception class should:  
✔️ Inherit from `std::exception` (or any standard exception).  
✔️ Override the `what()` method to provide an error message.

**Example: Custom Division by Zero Exception**

```cpp
#include <iostream>
#include <exception>
using namespace std;

class DivisionByZeroException : public exception {
public:
    const char* what() const noexcept override {
        return "Error: Division by zero is not allowed!";
    }
};

double safeDivide(double a, double b) {
    if (b == 0) throw DivisionByZeroException();
    return a / b;
}

int main() {
    try {
        cout << safeDivide(10, 0);
    }
    catch (const DivisionByZeroException& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Error: Division by zero is not allowed!
```

---

### **Custom Exception with Additional Data**

Custom exceptions can store additional details like error codes.

**Example: Custom Exception with Error Code**

```cpp
#include <iostream>
#include <exception>
using namespace std;

class CustomException : public exception {
private:
    string message;
    int errorCode;
public:
    CustomException(string msg, int code) : message(move(msg)), errorCode(code) {}

    const char* what() const noexcept override {
        return message.c_str();
    }

    int getCode() const { return errorCode; }
};

int main() {
    try {
        throw CustomException("File not found", 404);
    }
    catch (const CustomException& e) {
        cout << "Exception: " << e.what() << " (Error Code: " << e.getCode() << ")" << endl;
    }
}
```

**Output:**

```
Exception: File not found (Error Code: 404)
```

---

### **Throwing and Catching Custom Exceptions**

✔️ Use `throw` to raise exceptions.  
✔️ Use `try-catch` to handle them.

**Example: Multiple Custom Exceptions**

```cpp
#include <iostream>
#include <exception>
using namespace std;

class InvalidInputException : public exception {
public:
    const char* what() const noexcept override {
        return "Invalid input detected!";
    }
};

class OutOfRangeException : public exception {
public:
    const char* what() const noexcept override {
        return "Value is out of range!";
    }
};

void checkValue(int value) {
    if (value < 0) throw InvalidInputException();
    if (value > 100) throw OutOfRangeException();
    cout << "Valid value: " << value << endl;
}

int main() {
    try {
        checkValue(-5);
    }
    catch (const InvalidInputException& e) {
        cout << "Exception: " << e.what() << endl;
    }
    catch (const OutOfRangeException& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Invalid input detected!
```

---

### **Key Points**

✅ Custom exceptions **extend `std::exception`** for consistency.  
✅ Override `what()` to provide **meaningful error messages**.  
✅ Store **additional information** (e.g., error codes, messages).  
✅ **Use multiple catch blocks** for handling different exceptions.

---

