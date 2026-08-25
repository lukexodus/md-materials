## Pointer to Structures


Pointers to structures enable dynamic memory allocation, linked data structures, and efficient parameter passing.

**Basic Structure Pointer Usage**

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int id;
    char name[50];
    float salary;
} Employee;

void print_employee(Employee *emp) {
    printf("ID: %d, Name: %s, Salary: %.2f\n", 
           emp->id, emp->name, emp->salary);
}

Employee* create_employee(int id, const char *name, float salary) {
    Employee *emp = malloc(sizeof(Employee));
    if (emp != NULL) {
        emp->id = id;
        strncpy(emp->name, name, sizeof(emp->name) - 1);
        emp->name[sizeof(emp->name) - 1] = '\0';
        emp->salary = salary;
    }
    return emp;
}

int main() {
    Employee *emp1 = create_employee(101, "John Doe", 50000.0);
    Employee *emp2 = create_employee(102, "Jane Smith", 55000.0);
    
    if (emp1) print_employee(emp1);
    if (emp2) print_employee(emp2);
    
    free(emp1);
    free(emp2);
    
    return 0;
}
```

**Linked List Implementation**

```c
#include <stdio.h>
#include <stdlib.h>

typedef struct Node {
    int data;
    struct Node *next;
} Node;

typedef struct {
    Node *head;
    int size;
} LinkedList;

LinkedList* create_list() {
    LinkedList *list = malloc(sizeof(LinkedList));
    if (list) {
        list->head = NULL;
        list->size = 0;
    }
    return list;
}

void insert_front(LinkedList *list, int data) {
    Node *new_node = malloc(sizeof(Node));
    if (new_node && list) {
        new_node->data = data;
        new_node->next = list->head;
        list->head = new_node;
        list->size++;
    }
}

void print_list(LinkedList *list) {
    if (!list) return;
    
    Node *current = list->head;
    printf("List: ");
    while (current) {
        printf("%d -> ", current->data);
        current = current->next;
    }
    printf("NULL\n");
}

void destroy_list(LinkedList *list) {
    if (!list) return;
    
    Node *current = list->head;
    while (current) {
        Node *temp = current;
        current = current->next;
        free(temp);
    }
    free(list);
}

int main() {
    LinkedList *list = create_list();
    
    insert_front(list, 10);
    insert_front(list, 20);
    insert_front(list, 30);
    
    print_list(list);
    printf("Size: %d\n", list->size);
    
    destroy_list(list);
    return 0;
}
```

