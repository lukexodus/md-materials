## Pointer Basics and Syntax


### Declaration and Initialization

Pointer variables are declared using the asterisk (\*) operator, which indicates that the variable will hold a memory address rather than a direct value:

```c
int *ptr;        // Declares a pointer to an integer
char *cptr;      // Declares a pointer to a character
float *fptr;     // Declares a pointer to a float
```

The address-of operator (&) retrieves the memory address of a variable:

```c
int value = 42;
int *ptr = &value;    // ptr now holds the address of value
```

The dereference operator (\*) accesses the value stored at the address contained in a pointer:

```c
int value = 42;
int *ptr = &value;
printf("Value: %d\n", *ptr);    // Outputs: Value: 42
*ptr = 100;                     // Changes value to 100
printf("Value: %d\n", value);   // Outputs: Value: 100
```

**Key points** about pointer syntax:

- The * operator has different meanings in declaration (declares pointer) versus usage (dereferences)
- Uninitialized pointers contain garbage values and should never be dereferenced
- The NULL pointer (value 0) indicates a pointer that doesn't point to valid memory
- Pointer size depends on the system architecture (typically 4 bytes on 32-bit, 8 bytes on 64-bit)

### Memory Addresses and Pointer Values

**Example** demonstrating address relationships:

```c
#include <stdio.h>

int main() {
    int a = 10, b = 20, c = 30;
    int *ptr1 = &a;
    int *ptr2 = &b;
    
    printf("Address of a: %p, Value: %d\n", (void*)&a, a);
    printf("Address of b: %p, Value: %d\n", (void*)&b, b);
    printf("Address of c: %p, Value: %d\n", (void*)&c, c);
    
    printf("ptr1 contains: %p, points to value: %d\n", (void*)ptr1, *ptr1);
    printf("ptr2 contains: %p, points to value: %d\n", (void*)ptr2, *ptr2);
    
    // Pointer reassignment
    ptr1 = &c;
    printf("After reassignment, ptr1 points to: %d\n", *ptr1);
    
    return 0;
}
```

### Pointer Types and Compatibility

C enforces type safety with pointers - a pointer to one type cannot directly point to another type without explicit casting:

```c
int value = 42;
int *int_ptr = &value;
char *char_ptr = (char*)&value;  // Explicit cast required

// void pointers can hold addresses of any type
void *generic_ptr = &value;
int *recovered_ptr = (int*)generic_ptr;  // Cast back to specific type
```

