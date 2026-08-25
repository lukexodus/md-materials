## **Rvalue References (`&&`)**


An **rvalue reference** allows binding to **temporary objects** (rvalues), enabling efficient resource transfers.

✅ **Example: Binding Rvalue References**

```cpp
#include <iostream>
using namespace std;

void func(int& x) { cout << "Lvalue reference\n"; }
void func(int&& x) { cout << "Rvalue reference\n"; }

int main() {
    int a = 10;
    func(a);     // Calls lvalue reference overload
    func(20);    // Calls rvalue reference overload
}
```

**Output:**

```
Lvalue reference
Rvalue reference
```

🔹 `int&` binds to **lvalues** (named variables).  
🔹 `int&&` binds to **rvalues** (temporary values like `20`).

---

