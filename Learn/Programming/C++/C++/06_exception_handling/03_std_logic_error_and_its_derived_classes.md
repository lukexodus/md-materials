## **std::logic_error and Its Derived Classes**


`std::logic_error` is a **compile-time detectable** exception type in C++. It is used for **errors caused by incorrect program logic**, meaning they should be fixed in code rather than handled dynamically at runtime.

---

### **1. `std::domain_error`**

Thrown when a function receives an **input that is outside its valid domain**.

**Example: Square Root of a Negative Number**

```cpp
#include <iostream>
#include <cmath>
#include <stdexcept>
using namespace std;

double safeSqrt(double x) {
    if (x < 0) throw domain_error("Negative number in sqrt()");
    return sqrt(x);
}

int main() {
    try {
        cout << safeSqrt(-4);
    }
    catch (const domain_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Negative number in sqrt()
```

---

### **2. `std::invalid_argument`**

Thrown when a function receives an **invalid argument** that does not meet its expected format.

**Example: Converting a Non-Numeric String to Integer**

```cpp
#include <iostream>
#include <stdexcept>
using namespace std;

int toInteger(const string& str) {
    if (str.empty() || !isdigit(str[0])) throw invalid_argument("Invalid number format");
    return stoi(str);
}

int main() {
    try {
        cout << toInteger("abc123");  // Invalid input
    }
    catch (const invalid_argument& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Invalid number format
```

---

### **3. `std::length_error`**

Thrown when an **operation exceeds the maximum allowable size** of a container or string.

**Example: Exceeding String Maximum Length**

```cpp
#include <iostream>
#include <stdexcept>
#include <string>
using namespace std;

int main() {
    try {
        string s;
        s.reserve(s.max_size() + 1);  // Too large
    }
    catch (const length_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
}
```

**Output:**

```
Exception: basic_string::reserve
```

---

### **4. `std::out_of_range`**

Thrown when trying to **access an element beyond valid bounds** (e.g., using `.at()` on a vector or string).

**Example: Accessing an Invalid Index**

```cpp
#include <iostream>
#include <vector>
#include <stdexcept>
using namespace std;

int main() {
    try {
        vector<int> nums = {1, 2, 3};
        cout << nums.at(5);  // Out of range
    }
    catch (const out_of_range& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: vector::_M_range_check: __n (which is 5) >= this->size() (which is 3)
```

---

**Key Points**

✅ **`std::domain_error`** → Used for mathematically **invalid inputs**.  
✅ **`std::invalid_argument`** → Used when **bad arguments** are passed to a function.  
✅ **`std::length_error`** → Used when **containers exceed their size limits**.  
✅ **`std::out_of_range`** → Used when **accessing elements beyond valid indices**.

---


