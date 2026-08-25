## Pointers to Structures


Pointers to structures store memory addresses of structure variables, enabling indirect access and efficient parameter passing. The arrow operator (`->`) provides convenient syntax for accessing members through pointers, equivalent to `(*ptr).member`. Structure pointers enable dynamic memory allocation, linked data structures, and efficient function parameter passing.

Pointer arithmetic with structure pointers advances by the size of the entire structure, enabling traversal of structure arrays. Structure pointers can be used for self-referential structures, creating linked lists, trees, and other dynamic data structures.

Function parameters using structure pointers avoid copying entire structures, improving performance for large structures. However, this allows functions to modify the original structure unless the pointer is declared as `const`.

**Key points:**

- Store addresses of structure variables
- Arrow operator for member access through pointers
- Enable dynamic memory allocation
- Efficient parameter passing without copying
- Support self-referential structures

**Example:**

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Node {
    int data;
    struct Node* next;  // Self-referential pointer
};

struct Student {
    int id;
    char name[30];
    float gpa;
};

// Function using structure pointer parameter
void print_student(const struct Student* s) {
    printf("ID: %d, Name: %s, GPA: %.2f\n", s->id, s->name, s->gpa);
}

// Function modifying structure through pointer
void update_gpa(struct Student* s, float new_gpa) {
    s->gpa = new_gpa;
    printf("Updated GPA for %s to %.2f\n", s->name, s->gpa);
}

// Function creating dynamic structure
struct Student* create_student(int id, const char* name, float gpa) {
    struct Student* new_student = malloc(sizeof(struct Student));
    if (new_student != NULL) {
        new_student->id = id;
        strcpy(new_student->name, name);
        new_student->gpa = gpa;
    }
    return new_student;
}

// Linked list functions
struct Node* create_node(int value) {
    struct Node* new_node = malloc(sizeof(struct Node));
    if (new_node != NULL) {
        new_node->data = value;
        new_node->next = NULL;
    }
    return new_node;
}

void insert_at_beginning(struct Node** head, int value) {
    struct Node* new_node = create_node(value);
    if (new_node != NULL) {
        new_node->next = *head;
        *head = new_node;
    }
}

void print_list(struct Node* head) {
    struct Node* current = head;
    printf("List: ");
    while (current != NULL) {
        printf("%d ", current->data);
        current = current->next;
    }
    printf("\n");
}

void free_list(struct Node* head) {
    while (head != NULL) {
        struct Node* temp = head;
        head = head->next;
        free(temp);
    }
}

int main() {
    // Structure pointer basics
    struct Student s1 = {101, "Alice Johnson", 3.75};
    struct Student* ptr = &s1;
    
    // Access through pointer
    printf("Direct access: %s\n", s1.name);
    printf("Pointer access: %s\n", ptr->name);
    printf("Pointer access (alternative): %s\n", (*ptr).name);
    
    // Function calls with structure pointer
    print_student(ptr);
    update_gpa(ptr, 3.85);
    print_student(&s1);  // Pass address directly
    
    // Dynamic structure allocation
    struct Student* dynamic_student = create_student(102, "Bob Smith", 3.92);
    if (dynamic_student != NULL) {
        printf("\nDynamic student: ");
        print_student(dynamic_student);
        
        // Modify dynamic structure
        dynamic_student->id = 999;
        strcpy(dynamic_student->name, "Robert Smith");
        print_student(dynamic_student);
        
        free(dynamic_student);
    }
    
    // Array of structure pointers
    struct Student students[] = {
        {201, "Carol Davis", 3.45},
        {202, "David Wilson", 3.78},
        {203, "Eva Brown", 3.91}
    };
    
    struct Student* student_ptrs[3];
    for (int i = 0; i < 3; i++) {
        student_ptrs[i] = &students[i];
    }
    
    printf("\nArray of structure pointers:\n");
    for (int i = 0; i < 3; i++) {
        print_student(student_ptrs[i]);
    }
    
    // Linked list demonstration
    struct Node* head = NULL;
    
    insert_at_beginning(&head, 10);
    insert_at_beginning(&head, 20);
    insert_at_beginning(&head, 30);
    
    print_list(head);
    
    // Pointer arithmetic with structures
    printf("\nPointer arithmetic:\n");
    struct Student* first = &students[0];
    struct Student* second = first + 1;  // Points to next structure
    
    printf("First student: %s\n", first->name);
    printf("Second student: %s\n", second->name);
    printf("Pointer difference: %ld\n", second - first);
    
    free_list(head);
    
    return 0;
}
```

