## Namespaces


In C++, namespaces are used to organize code into logical groups and to prevent naming conflicts. They provide a way to group related code together under a unique identifier.

### Namespace Declaration:

You declare a namespace using the `namespace` keyword followed by the namespace name and the code block containing the declarations within the namespace.

```cpp
namespace MyNamespace {
    // Declarations
    int var1;
    void function1();
}
```

### Accessing Namespaces:

You can access the members of a namespace using the scope resolution operator `::`. 

```cpp
MyNamespace::var1 = 10;
MyNamespace::function1();
```

### Nested Namespaces:

Namespaces can be nested within other namespaces to further organize code.

```cpp
namespace OuterNamespace {
    namespace InnerNamespace {
        // Declarations
    }
}
```

### Using Directive:

The `using` directive allows you to bring the entire namespace or specific members into scope, reducing the need for repetitive qualification.

```cpp
using namespace MyNamespace;
```

### Using Declaration:

The `using` declaration allows you to bring specific members from a namespace into the current scope.

```cpp
using MyNamespace::var1;
```

### Example

```cpp
#include <iostream>

namespace Math {
    const double PI = 3.14159;

    double square(double x) {
        return x * x;
    }
}

int main() {
    using namespace Math;

    std::cout << "PI: " << PI << std::endl;
    std::cout << "Square of 5: " << square(5) << std::endl;

    return 0;
}
```

---

### Anonymous Namespace

An **anonymous namespace** in C++ is a special kind of namespace without a name. It is used to limit the **scope** of functions, variables, and classes to the current translation unit (i.e., the current `.cpp` file). This makes them **internal** to the file, preventing external linkage.

---

#### **Syntax**

```cpp
#include <iostream>

namespace {  // Anonymous namespace
    int secretValue = 42;

    void display() {
        std::cout << "Secret value: " << secretValue << std::endl;
    }
}

int main() {
    display();  // Works fine
    return 0;
}
```

- The `secretValue` variable and `display()` function **can only be accessed within this file**.
- They **cannot be accessed from other files**, even if they include this `.cpp` file.

---

#### **Why Use Anonymous Namespaces?**

1. **Avoid Naming Conflicts**
    - Since elements inside an anonymous namespace are not visible outside the file, you prevent accidental name clashes.
2. **Internal Linkage (Like `static`)**
    - It works similarly to using `static` on global variables and functions in C.
    - Ensures functions and variables do not pollute the global namespace.
3. **Encapsulation & Security**
    - Prevents unintended access to internal implementation details.

---

#### **Anonymous Namespace vs `static` (at File Scope)**

|Feature|Anonymous Namespace|`static` (File Scope)|
|---|---|---|
|Scope|Limited to the file|Limited to the file|
|Usable for Variables|Yes|Yes|
|Usable for Functions|Yes|Yes|
|Usable for Classes|Yes|No|
|Name Clashes Avoided|Yes|No|

- `static` can only be applied to **variables and functions**, while an anonymous namespace can contain **variables, functions, and even classes**.

---

#### **Example: Preventing Name Conflicts**

##### **Without an Anonymous Namespace (Global Conflict)**

```cpp
// file1.cpp
#include <iostream>

void logMessage() {  // Might conflict with another function
    std::cout << "Logging from file1" << std::endl;
}

```

```cpp
// file2.cpp
#include <iostream>

void logMessage() {  // Name conflict if linked with file1.cpp
    std::cout << "Logging from file2" << std::endl;
}
```

When linking both `.cpp` files together, the **compiler will complain about duplicate function names**.

##### **With an Anonymous Namespace (No Conflict)**

```cpp
// file1.cpp
#include <iostream>

namespace {
    void logMessage() {  // No conflict since it's internal to file1.cpp
        std::cout << "Logging from file1" << std::endl;
    }
}

int main() {
    logMessage();
    return 0;
}
```

- Even if another `logMessage()` exists in another file, it **won't conflict** because it's inside an **anonymous namespace**.

***

