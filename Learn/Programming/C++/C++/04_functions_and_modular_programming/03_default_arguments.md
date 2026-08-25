## **Default Arguments**


Default arguments allow a function to be called with fewer parameters by providing default values.

**Syntax:**

```cpp
void greet(string name = "Guest") {
    cout << "Hello, " << name << "!" << endl;
}
```

**Example:**

```cpp
#include <iostream>
using namespace std;

void display(int a, int b = 10) { // Default value for b
    cout << "a: " << a << ", b: " << b << endl;
}

int main() {
    display(5);    // Output: a: 5, b: 10
    display(5, 20); // Output: a: 5, b: 20
    return 0;
}
```

**Key Points:**

- Default values are assigned **from right to left**.
- If a parameter has a default value, all parameters to its **right** must also have default values.
- Default arguments are **declared only in function prototypes**.

---

