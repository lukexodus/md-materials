## **std::runtime_error and Its Derived Classes**


`std::runtime_error` is a **runtime-detectable** exception type in C++. It is used for **errors that cannot be determined at compile-time** and typically arise due to system or computational issues.

### **`std::overflow_error`**

Thrown when a **mathematical overflow** occurs during computations.

**Example: Integer Overflow in Multiplication**

```cpp
#include <iostream>
#include <limits>
#include <stdexcept>
using namespace std;

int safeMultiply(int a, int b) {
    if (a > 0 && b > 0 && a > numeric_limits<int>::max() / b)
        throw overflow_error("Multiplication overflow");
    return a * b;
}

int main() {
    try {
        cout << safeMultiply(1'000'000, 3'000'000);
    }
    catch (const overflow_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Multiplication overflow
```

---

### **`std::underflow_error`**

Thrown when a **mathematical underflow** occurs (typically in floating-point operations).

**Example: Underflow in Floating-Point Division**

```cpp
#include <iostream>
#include <limits>
#include <stdexcept>
using namespace std;

double safeDivide(double a, double b) {
    if (b == 0) throw underflow_error("Division underflow");
    return a / b;
}

int main() {
    try {
        cout << safeDivide(1.0, numeric_limits<double>::max());
    }
    catch (const underflow_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Division underflow
```

---

### **`std::range_error`**

Thrown when a **calculated result is outside the valid range** but not necessarily causing an overflow.

**Example: Logarithm of a Negative Number**

```cpp
#include <iostream>
#include <cmath>
#include <stdexcept>
using namespace std;

double safeLog(double x) {
    if (x < 0) throw range_error("Logarithm of a negative number");
    return log(x);
}

int main() {
    try {
        cout << safeLog(-5);
    }
    catch (const range_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Logarithm of a negative number
```

---

### **`std::system_error`**

Thrown for **system-related errors** such as file operations or thread issues.

**Example: Opening a Non-Existent File**

```cpp
#include <iostream>
#include <fstream>
#include <system_error>
using namespace std;

int main() {
    try {
        ifstream file("nonexistent.txt");
        if (!file) throw system_error(error_code(), "File could not be opened");
    }
    catch (const system_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: File could not be opened
```

---

**Key Points**  
✅ **`std::overflow_error`** → Used when **values exceed the maximum allowable limit**.  
✅ **`std::underflow_error`** → Used when **values become too small to be represented accurately**.  
✅ **`std::range_error`** → Used for **results that are out of an expected range**.  
✅ **`std::system_error`** → Used for **system-related issues (files, threads, etc.)**.

---

