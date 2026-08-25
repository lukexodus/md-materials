## Mixing C Code With C++ Code


**Header Files**: Both C and C++ use header files for declarations and prototypes. C header files can be included in C++ code using `extern "C"` to inform the C++ compiler that the declarations follow C naming conventions.

```cpp
extern "C" {
  #include "c_header.h"
}
```


Example of mixing C and C++ code:

```cpp
// c_code.c
#include <stdio.h>

void c_function() {
    printf("This is a C function\n");
}

// cpp_code.cpp
#include <iostream>

extern "C" {
    void c_function(); // Declaration of the C function
}

int main() {
    std::cout << "This is a C++ function" << std::endl;
    c_function(); // Calling the C function
    return 0;
}
```

***

