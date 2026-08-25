## Operators


### Precedence and Associativity Table

| Precedence | Operator          | Description              | Associativity |
| ---------- | ----------------- | ------------------------ | ------------- |
| 1          | () [] . ->        | Postfix operators        | Left to right |
| 2          | ++ -- + - ! ~ * & | Unary operators          | Right to left |
|            | sizeof _Alignof   |                          |               |
|            | (type)            | Type cast                | Right to left |
| 3          | * / %             | Multiplicative operators | Left to right |
| 4          | + -               | Additive operators       | Left to right |
| 5          | << >>             | Bitwise shift operators  | Left to right |
| 6          | < <= > >=         | Relational operators     | Left to right |
| 7          | == !=             | Equality operators       | Left to right |
| 8          | &                 | Bitwise AND operator     | Left to right |
| 9          | ^                 | Bitwise XOR operator     | Left to right |
| 10         | \|                | Bitwise OR operator      | Left to right |
| 11         | &&                | Logical AND operator     | Left to right |
| 12         | \|\|              | Logical OR operator      | Left to right |
| 13         | ?:                | Conditional operator     | Right to left |
| 14         | = += -= *= /= %=  | Assignment operators     | Right to left |
|            | &= ^= \|= <<= >>= |                          |               |
| 15         | ,                 | Comma operator           | Left to right |

The operators at the top of the table have higher precedence and are evaluated before the operators below them.

### Associativity

1. **Associating Right to Left:**
    - In an expression where operators associate right to left, operations are evaluated starting from the rightmost operator and moving towards the leftmost one.
    - For example, in an expression like `a = b = c`, the assignment operator `=` is evaluated from right to left. This means that the value of `c` is assigned to `b` first, and then the value of `b` (which is now equal to `c`) is assigned to `a`.
2. **Associating Left to Right:**
    - In contrast, when operators associate left to right, operations are evaluated from left to right.
    - For example, in an expression like `a + b - c`, the addition (`+`) and subtraction (`-`) operators are evaluated from left to right. This means that `a` and `b` are first added together, and then the result is subtracted from `c`.

In most programming languages, arithmetic operators like addition, subtraction, multiplication, and division associate left to right. This means that expressions are evaluated following the standard order of operations: parentheses first, then exponentiation, multiplication and division from left to right, and finally addition and subtraction from left to right.

However, the associativity of operators can vary depending on the language and the specific operators involved. For example, in some languages, assignment operators may associate right to left, while in others, they may associate left to right.

### `sizeof`

In C and C++, the `sizeof` operator is used to determine the size, in bytes, of a data type or a variable. It is a compile-time operator that returns the size of its operand.

Here are some key points about the `sizeof` operator:

1. **Determine Size of Data Types**: You can use `sizeof` to determine the size of built-in data types, user-defined types, arrays, and structures.
    
2. **Platform-Dependent**: The size returned by `sizeof` depends on the compiler and the target architecture. For example, `sizeof(int)` might return 4 bytes on a 32-bit system and 8 bytes on a 64-bit system.
    
3. **Determining Array Size**: `sizeof` is often used to determine the size of arrays. For example, `sizeof(array) / sizeof(array[0])` gives the number of elements in the array.
    
4. **Determining Structure Size**: `sizeof` can also be used to determine the size of a structure. It returns the total size in bytes of the members of the structure, including any padding that may be added by the compiler for alignment.
    
5. **Compile-Time Operator**: `sizeof` is a compile-time operator, which means it's evaluated by the compiler rather than at runtime. This makes it very efficient.
    
6. **Return Type**: The return type of `sizeof` is `size_t` (defined in the header `<stddef.h>`), which is an unsigned integer type capable of representing the size of any object in bytes.


Here's a simple example demonstrating the use of `sizeof`:

```c
#include <stdio.h>

int main() {
    int integerType;
    double doubleType;
    char charType;
    int array[10];

    printf("Size of int: %zu bytes\n", sizeof(integerType));
    printf("Size of double: %zu bytes\n", sizeof(doubleType));
    printf("Size of char: %zu byte\n", sizeof(charType));
    printf("Size of array: %zu bytes\n", sizeof(array));
    printf("Number of elements in array: %zu\n", sizeof(array) / sizeof(array[0]));

    return 0;
}
```

Output (example):

```c
Size of int: 4 bytes
Size of double: 8 bytes
Size of char: 1 byte
Size of array: 40 bytes
Number of elements in array: 10
```

In this example, `sizeof` is used to determine the sizes of various data types (`int`, `double`, `char`) and an array (`array`). Additionally, `sizeof(array) / sizeof(array[0])` calculates the number of elements in the array.

