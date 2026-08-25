## Structure Initialization and Access


Structure initialization can occur during declaration using brace-enclosed initializer lists or through individual member assignment after declaration. Designated initializers allow initialization of specific members by name, improving code clarity and enabling partial initialization with remaining members set to zero.

Member access uses the dot operator for structure variables. Assignment between structure variables of the same type copies all members. Uninitialized structure members contain garbage values for automatic variables, while global and static structures are zero-initialized by default.

Initialization order must match member declaration order when using positional initializers. Designated initializers can appear in any order and can be mixed with positional initializers, though designated initializers must follow positional ones.

**Key points:**

- Brace-enclosed initializers during declaration
- Designated initializers specify members by name
- Dot operator accesses structure members
- Structure assignment copies all members
- Uninitialized members contain garbage values

**Example:**

```c
#include <stdio.h>
#include <string.h>

struct Student {
    int id;
    char name[30];
    float gpa;
    int year;
};

struct Product {
    int code;
    char description[50];
    double price;
    int quantity;
};

int main() {
    // Various initialization methods
    struct Student s1 = {101, "Alice Johnson", 3.75, 2};  // Positional
    
    struct Student s2 = {
        .id = 102,
        .name = "Bob Smith",
        .gpa = 3.92,
        .year = 3
    };  // Designated initializers
    
    struct Student s3 = {103, "Carol Davis"};  // Partial initialization
    
    struct Product p1 = {
        .code = 2001,
        .description = "Wireless Mouse",
        .price = 29.99
        // quantity not initialized, will be 0
    };
    
    // Assignment after declaration
    struct Student s4;
    s4.id = 104;
    strcpy(s4.name, "David Wilson");
    s4.gpa = 3.45;
    s4.year = 1;
    
    // Structure assignment
    struct Student s5 = s2;  // Copy all members
    
    // Modify copied structure
    strcpy(s5.name, "Bob Smith Jr.");
    s5.id = 105;
    
    // Display information
    printf("Student 1: ID=%d, Name=%s, GPA=%.2f, Year=%d\n",
           s1.id, s1.name, s1.gpa, s1.year);
    
    printf("Student 2: ID=%d, Name=%s, GPA=%.2f, Year=%d\n",
           s2.id, s2.name, s2.gpa, s2.year);
    
    printf("Student 3: ID=%d, Name=%s, GPA=%.2f, Year=%d\n",
           s3.id, s3.name, s3.gpa, s3.year);
    
    printf("Product: Code=%d, Desc=%s, Price=$%.2f, Qty=%d\n",
           p1.code, p1.description, p1.price, p1.quantity);
    
    printf("Student 5 (copy): ID=%d, Name=%s\n", s5.id, s5.name);
    printf("Original Student 2: ID=%d, Name=%s\n", s2.id, s2.name);
    
    return 0;
}
```

