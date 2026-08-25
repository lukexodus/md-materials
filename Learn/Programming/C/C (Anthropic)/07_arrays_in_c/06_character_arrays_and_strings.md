## Character Arrays and Strings


Character arrays in C serve as the primary mechanism for string handling, where strings are represented as arrays of characters terminated by a null character (`\0`).

**String Declaration and Initialization:**

```c
char str1[10];                    // Uninitialized character array
char str2[] = "Hello";            // Size automatically set to 6 (including \0)
char str3[10] = "World";          // Partially filled, rest initialized to \0
char str4[] = {'H', 'i', '\0'};   // Manual character initialization
char str5[20] = {0};              // All elements initialized to \0
```

**String Literals vs Character Arrays:**

```c
char *ptr = "Hello";              // Pointer to string literal (read-only)
char arr[] = "Hello";             // Modifiable character array copy
```

**String Input/Output:**

```c
#include <stdio.h>

char name[50];
printf("Enter name: ");
scanf("%s", name);                // Reads until whitespace
printf("Hello, %s!\n", name);

// Reading line with spaces
fgets(name, sizeof(name), stdin); // Safer for reading lines
puts(name);                       // Prints string with newline
```

**String Manipulation Functions:**

```c
#include <string.h>

char src[] = "Hello";
char dest[20];

// Copy operations
strcpy(dest, src);                // Copy src to dest
strncpy(dest, src, 10);           // Copy at most 10 characters

// Concatenation
strcat(dest, " World");           // Append " World" to dest
strncat(dest, src, 5);            // Append at most 5 characters

// Comparison
int result = strcmp(str1, str2);   // Returns <0, 0, or >0
int result2 = strncmp(str1, str2, 5); // Compare first 5 characters

// Length
int len = strlen(str1);            // Returns string length (excluding \0)
```

**String Processing Example:**

```c
#include <ctype.h>

void toUpperCase(char str[]) {
    for(int i = 0; str[i] != '\0'; i++) {
        str[i] = toupper(str[i]);
    }
}

int countWords(char str[]) {
    int count = 0;
    int inWord = 0;
    
    for(int i = 0; str[i] != '\0'; i++) {
        if(!isspace(str[i])) {
            if(!inWord) {
                count++;
                inWord = 1;
            }
        } else {
            inWord = 0;
        }
    }
    return count;
}
```

**Two-Dimensional Character Arrays:** Useful for storing multiple strings:

```c
char names[5][20];                // Array of 5 strings, each up to 19 chars
char cities[][10] = {
    "New York",
    "London",
    "Tokyo"
};

// Accessing individual strings
strcpy(names[0], "Alice");
printf("%s\n", names[0]);

// Processing all strings
for(int i = 0; i < 3; i++) {
    printf("City %d: %s\n", i+1, cities[i]);
}
```

**Key Points:**

- Every C string must end with null terminator `\0`
- String functions assume null-terminated strings and may cause buffer overflows if terminator is missing
- `scanf("%s", ...)` is vulnerable to buffer overflows; prefer `fgets()` for safer input
- String literals are stored in read-only memory section
- Character arrays can be modified, but string literals cannot
- Always allocate sufficient space for strings, including the null terminator

**Buffer Safety:**

```c
char buffer[10];
// Unsafe
gets(buffer);                     // Deprecated, never use

// Safer alternatives
fgets(buffer, sizeof(buffer), stdin);
scanf("%9s", buffer);             // Limit input to buffer size - 1
```

**Output:** Understanding character arrays and strings is fundamental for text processing in C. The null-terminator convention enables efficient string operations while requiring careful buffer management to prevent security vulnerabilities.

**Conclusion:** Arrays in C provide the foundation for data structure manipulation and are essential for efficient memory usage and algorithm implementation. Mastering array concepts, from basic indexing to multi-dimensional structures and string handling, is crucial for effective C programming.

**Next Steps:** Explore dynamic arrays using malloc/free, array-based data structures like stacks and queues, and advanced string processing techniques including regular expressions and parsing algorithms.

---

