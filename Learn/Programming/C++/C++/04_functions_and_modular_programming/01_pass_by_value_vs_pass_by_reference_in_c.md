## **Pass by Value vs. Pass by Reference in C++**


When passing arguments to functions in C++, you can do so in two main ways: **Pass by Value** and **Pass by Reference**. Each method has different behaviors and use cases.

---

### **Pass by Value**

When a function is called with **pass by value**, a **copy** of the argument is created, and modifications inside the function do **not** affect the original variable.

**Example:**

```cpp
#include <iostream>
using namespace std;

void modifyValue(int x) {
    x = x * 2; // This change is local to the function
}

int main() {
    int num = 10;
    modifyValue(num);
    cout << "Value of num: " << num << endl; // Output: 10
    return 0;
}
```

**Key Points:**

- A **copy** of the argument is made.
- The original value remains **unchanged**.
- Useful for **small data types** or when you **don’t want** the function to modify the original variable.

---

### **Pass by Reference**

In **pass by reference**, the function receives a **reference** to the original variable, meaning changes inside the function will **affect** the original value.

**Example:**

```cpp
#include <iostream>
using namespace std;

void modifyValue(int &x) { // Reference parameter
    x = x * 2;
}

int main() {
    int num = 10;
    modifyValue(num);
    cout << "Value of num: " << num << endl; // Output: 20
    return 0;
}
```

**Key Points:**

- The function works with the **actual variable**, not a copy.
- Any **modifications inside** the function affect the **original variable**.
- Used when you **want** the function to modify the original variable.

---

### **Pass by Pointer (Similar to Pass by Reference)**

Another way to pass by reference is by using pointers.

**Example:**

```cpp
#include <iostream>
using namespace std;

void modifyValue(int *x) { // Pointer parameter
    *x = *x * 2;
}

int main() {
    int num = 10;
    modifyValue(&num);
    cout << "Value of num: " << num << endl; // Output: 20
    return 0;
}
```

**Key Points:**

- The function receives the **address** of the variable.
- The function modifies the **actual value** using the pointer.
- Useful for **dynamic memory allocation** and when dealing with arrays.

---

### **Comparison Table**

| Feature                   | Pass by Value | Pass by Reference | Pass by Pointer |
| ------------------------- | ------------- | ----------------- | --------------- |
| Copy of argument          | ✅ Yes         | ❌ No              | ❌ No            |
| Affects original variable | ❌ No          | ✅ Yes             | ✅ Yes           |
| Used for constants        | ✅ Yes         | ❌ No              | ❌ No            |
| Can pass NULL             | ❌ No          | ❌ No              | ✅ Yes           |
| Requires extra memory     | ✅ Yes         | ❌ No              | ❌ No            |

---

### **When to Use Which?**

✅ **Use Pass by Value** when:

- You **don’t want** to modify the original data.
- The variable is **small** (e.g., `int`, `char`, `float`).

✅ **Use Pass by Reference** when:

- You **want** to modify the original variable.
- You need better performance for **large data types** (e.g., `std::string`, `vector`).

✅ **Use Pass by Pointer** when:

- You need to **handle NULL values**.
- You’re working with **dynamic memory** or **arrays**.

