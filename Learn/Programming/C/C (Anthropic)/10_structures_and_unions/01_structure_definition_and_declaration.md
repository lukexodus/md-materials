## Structure Definition and Declaration


Structures are user-defined composite data types that group related variables of different types under a single name. The `struct` keyword defines a new data type containing multiple members, each with its own type and name. Structure definitions create templates that can be used to declare variables of that structure type.

Structure definitions can be placed at global scope for use throughout the program or within functions for local use. The structure tag (name after `struct`) is optional but enables forward declarations and recursive structure definitions. Members are accessed using the dot operator (`.`) for structure variables and the arrow operator (`->`) for structure pointers.

Structure definitions do not allocate memory until variables of that type are declared. The compiler arranges members in memory according to their declaration order, potentially inserting padding bytes for alignment requirements. The total structure size may exceed the sum of individual member sizes due to alignment padding.

**Key points:**

- Composite data type grouping related variables
- struct keyword defines the template
- Members accessed with dot or arrow operators
- Memory allocated only when variables declared
- Compiler adds padding for alignment

**Example:**

```c
#include <stdio.h>
#include <string.h>

// Structure definition
struct Point {
    int x;
    int y;
};

// Structure with different data types
struct Person {
    char name[50];
    int age;
    float height;
    char gender;
};

// Structure definition with typedef
typedef struct {
    double real;
    double imaginary;
} Complex;

// Structure with tag and typedef
typedef struct Rectangle {
    struct Point top_left;
    struct Point bottom_right;
} Rectangle;

int main() {
    // Structure variable declarations
    struct Point origin;
    struct Person student;
    Complex number;
    Rectangle window;
    
    // Memory size information
    printf("Size of Point: %zu bytes\n", sizeof(struct Point));
    printf("Size of Person: %zu bytes\n", sizeof(struct Person));
    printf("Size of Complex: %zu bytes\n", sizeof(Complex));
    printf("Size of Rectangle: %zu bytes\n", sizeof(Rectangle));
    
    // Demonstrating memory layout
    printf("\nPerson structure member offsets:\n");
    printf("name offset: %zu\n", offsetof(struct Person, name));
    printf("age offset: %zu\n", offsetof(struct Person, age));
    printf("height offset: %zu\n", offsetof(struct Person, height));
    printf("gender offset: %zu\n", offsetof(struct Person, gender));
    
    return 0;
}
```

