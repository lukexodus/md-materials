## Headers


In C++, headers are files containing declarations and definitions that can be included in other source files. They typically have the extension `.h` for C headers and `.hpp` for C++ headers.

Headers allow you to manage dependencies between different parts of your program by including necessary declarations and definitions.

```cpp
#include "myheader.h" // Include a custom header file
#include <iostream>   // Include a standard library header
```

### Preprocessor Directives:

Headers often contain preprocessor directives to prevent multiple inclusions and to ensure header files are included only once.

```cpp
#ifndef MYHEADER_H
#define MYHEADER_H

// Declarations and definitions

#endif
```

### Forward Declarations:

Headers may contain forward declarations of classes, functions, or variables used in other source files. Forward declarations in C++ are used to inform the compiler about the existence of an identifier (such as a class, function, or variable) before its actual definition.

```cpp
#include <iostream>

// Forward declaration of class B
class B;

class A {
public:
    void doSomething(B& b);
};

class B {
public:
    void doSomethingElse() {
        std::cout << "Doing something else!" << std::endl;
    }
};

void A::doSomething(B& b) {
    b.doSomethingElse();
}

int main() {
    A a;
    B b;
    a.doSomething(b);
    return 0;
}
```

In this example, `class B` is forward-declared before `class A` is defined. This allows `class A` to reference `class B` without needing the full definition of `class B` at that point.
### Inclusion Guards:

Headers often use inclusion guards to prevent multiple inclusions of the same header file in a translation unit.

```cpp
#ifndef MYHEADER_H
#define MYHEADER_H

// Declarations and definitions

#endif
```

---

