## Nested Structures


Nested structures contain other structures as members, enabling hierarchical data organization. Inner structures can be defined separately and referenced by name, or defined inline within the outer structure. Nested structures support multiple levels of nesting, creating complex data hierarchies.

Access to nested structure members requires chaining the dot operator for each level of nesting. The compiler calculates offsets for nested members by adding the outer structure offset to the inner structure member offset. Initialization of nested structures uses nested brace notation or designated initializers.

Nested structures enable modeling of real-world relationships and complex data structures. Common applications include geometric shapes with coordinate points, employee records with address information, and tree or graph node structures with child references.

**Key points:**

- Structures containing other structures as members
- Support multiple levels of nesting
- Access with chained dot operators
- Nested brace initialization
- Enable hierarchical data modeling

**Example:**

```c
#include <stdio.h>
#include <string.h>

// Basic structures for nesting
struct Date {
    int day;
    int month;
    int year;
};

struct Address {
    char street[50];
    char city[30];
    char state[20];
    int zip_code;
};

// Nested structure
struct Employee {
    int id;
    char name[40];
    struct Date birth_date;
    struct Date hire_date;
    struct Address home_address;
    double salary;
};

// Structure with inline nested definition
struct Book {
    char title[60];
    char author[40];
    struct {
        int day;
        int month;
        int year;
    } publication_date;  // Inline structure definition
    double price;
};

// Deeply nested structure
struct Company {
    char name[50];
    struct Address headquarters;
    struct {
        struct Employee manager;
        struct Employee employees[5];
        int employee_count;
    } department;
};

int main() {
    // Initialize nested structure
    struct Employee emp1 = {
        .id = 1001,
        .name = "John Anderson",
        .birth_date = {15, 6, 1990},
        .hire_date = {.day = 1, .month = 3, .year = 2020},
        .home_address = {
            .street = "123 Oak Street",
            .city = "Springfield",
            .state = "IL",
            .zip_code = 62701
        },
        .salary = 55000.0
    };
    
    // Initialize structure with inline nested structure
    struct Book book1 = {
        .title = "C Programming Guide",
        .author = "Jane Smith",
        .publication_date = {20, 8, 2023},
        .price = 49.99
    };
    
    // Access nested members
    printf("Employee Information:\n");
    printf("ID: %d\n", emp1.id);
    printf("Name: %s\n", emp1.name);
    printf("Birth Date: %d/%d/%d\n", 
           emp1.birth_date.day, emp1.birth_date.month, emp1.birth_date.year);
    printf("Hire Date: %d/%d/%d\n",
           emp1.hire_date.day, emp1.hire_date.month, emp1.hire_date.year);
    printf("Address: %s, %s, %s %d\n",
           emp1.home_address.street, emp1.home_address.city,
           emp1.home_address.state, emp1.home_address.zip_code);
    printf("Salary: $%.2f\n", emp1.salary);
    
    printf("\nBook Information:\n");
    printf("Title: %s\n", book1.title);
    printf("Author: %s\n", book1.author);
    printf("Publication Date: %d/%d/%d\n",
           book1.publication_date.day,
           book1.publication_date.month,
           book1.publication_date.year);
    printf("Price: $%.2f\n", book1.price);
    
    // Modify nested structure members
    emp1.salary += 5000.0;
    emp1.hire_date.year = 2021;
    strcpy(emp1.home_address.city, "Chicago");
    
    printf("\nUpdated Employee Salary: $%.2f\n", emp1.salary);
    printf("Updated Hire Year: %d\n", emp1.hire_date.year);
    printf("Updated City: %s\n", emp1.home_address.city);
    
    return 0;
}
```

