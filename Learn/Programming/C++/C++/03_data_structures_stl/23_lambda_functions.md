## **Lambda Functions**


Lambda functions in C++ are **anonymous functions** that allow defining small, concise functions inline. They are useful for short operations that do not require a full function declaration. Introduced in **C++11**, lambdas have become an essential feature in **modern C++ programming**.

---

### **Syntax of a Lambda Function**

```cpp
[ capture_list ] ( parameters ) -> return_type { function_body };
```

- **`capture_list`** → Captures external variables (optional).
- **`parameters`** → Function parameters (like normal functions).
- **`return_type`** → (Optional) Return type of the lambda.
- **`function_body`** → The actual code of the lambda.

---

### **Basic Lambda Function**

✅ **Lambda that prints a message**

```cpp
#include <iostream>
using namespace std;

int main() {
    auto greet = []() { cout << "Hello, Lambda!" << endl; };
    greet();
}
```

✅ **Lambda that takes parameters and returns a value**

```cpp
#include <iostream>
using namespace std;

int main() {
    auto add = [](int a, int b) { return a + b; };
    cout << "Sum: " << add(5, 3);
}
```

---

### **Capturing Variables in Lambdas**

#### **1. Capture by Value (`[var]`)**

✅ **A snapshot of the variable’s value is taken (does not modify original variable).**

```cpp
#include <iostream>
using namespace std;

int main() {
    int x = 10;
    auto lambda = [x]() { cout << "Captured x: " << x << endl; };
    x = 20;  // Does not affect lambda
    lambda();
}
```

**Output:**

```
Captured x: 10
```

#### **2. Capture by Reference (`[&var]`)**

✅ **Modifies the original variable.**

```cpp
#include <iostream>
using namespace std;

int main() {
    int x = 10;
    auto lambda = [&x]() { x += 5; };
    lambda();
    cout << "Modified x: " << x << endl;
}
```

**Output:**

```
Modified x: 15
```

#### **3. Capture All Variables**

✅ **Capture everything by value (`[=]`) or by reference (`[&]`).**

```cpp
#include <iostream>
using namespace std;

int main() {
    int a = 5, b = 10;
    
    auto byValue = [=]() { cout << "a: " << a << ", b: " << b << endl; };
    auto byReference = [&]() { a *= 2; b *= 3; };

    byValue();
    byReference();
    cout << "Modified a: " << a << ", b: " << b << endl;
}
```

**Output:**

```
a: 5, b: 10
Modified a: 10, b: 30
```

---

### **Returning Values from a Lambda**

#### **1. Implicit Return Type**

✅ **C++ automatically deduces return type based on the expression.**

```cpp
auto multiply = [](int x, int y) { return x * y; };
```

#### **2. Explicit Return Type (`-> type`)**

✅ **Useful for complex return types.**

```cpp
auto divide = [](int a, int b) -> double { return (double)a / b; };
```

---

### **Using Lambdas with STL Algorithms**

#### **1. `std::sort` with a Lambda Comparator**

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> nums = {4, 2, 8, 1, 5};

    sort(nums.begin(), nums.end(), [](int a, int b) { return a > b; });

    for (int num : nums) cout << num << " ";
}
```

**Output:**

```
8 5 4 2 1
```

#### **2. `std::for_each` to Apply a Function**

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> nums = {1, 2, 3, 4, 5};

    for_each(nums.begin(), nums.end(), [](int &n) { n *= 2; });

    for (int num : nums) cout << num << " ";
}
```

**Output:**

```
2 4 6 8 10
```

#### **3. `std::count_if` with a Lambda Predicate**

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> nums = {3, 6, 7, 10, 15, 18};

    int count = count_if(nums.begin(), nums.end(), [](int x) { return x % 3 == 0; });

    cout << "Count of multiples of 3: " << count;
}
```

**Output:**

```
Count of multiples of 3: 4
```

---

### **Key Points**

✅ **Lambdas allow inline, anonymous functions for quick operations.**  
✅ **Capturing variables lets lambdas use external scope.**  
✅ **STL algorithms benefit from lambdas for clean, efficient code.**  
✅ **Implicit and explicit return types offer flexibility.**  
✅ **Useful for functional programming and event-driven logic.**

---

