## String Representation in C


C strings are implemented as arrays of characters with a null terminator marking the end of the string.

### Character Arrays and String Literals

**String Literal Representation:**

```c
char str[] = "Hello, World!";
// Equivalent to:
char str[] = {'H', 'e', 'l', 'l', 'o', ',', ' ', 'W', 'o', 'r', 'l', 'd', '!', '\0'};
```

**Memory Layout:**

```
Index:  0  1  2  3  4  5  6  7  8  9  10 11 12 13
Value: 'H''e''l''l''o'','  ' ''W''o''r''l' 'd' '!' '\0'
```

### String Declaration Methods

**Static Array Declaration:**

```c
#include <stdio.h>

int main(void) {
    // Fixed-size character array
    char greeting[20] = "Hello";
    
    // Automatic sizing based on initializer
    char message[] = "Welcome to C programming";
    
    // Character-by-character initialization
    char word[6] = {'H', 'e', 'l', 'l', 'o', '\0'};
    
    // Partially initialized (remaining elements are '\0')
    char buffer[50] = "Initial";
    
    printf("Greeting: %s\n", greeting);
    printf("Message: %s\n", message);
    printf("Word: %s\n", word);
    printf("Buffer: %s\n", buffer);
    
    return 0;
}
```

**String Pointers:**

```c
#include <stdio.h>

int main(void) {
    // Pointer to string literal (read-only)
    char *ptr = "Hello, World!";
    
    // Array of string pointers
    char *fruits[] = {"Apple", "Banana", "Cherry", "Date"};
    
    // Two-dimensional character array
    char colors[][10] = {"Red", "Green", "Blue", "Yellow"};
    
    printf("Pointer string: %s\n", ptr);
    
    for (int i = 0; i < 4; i++) {
        printf("Fruit %d: %s\n", i, fruits[i]);
    }
    
    for (int i = 0; i < 4; i++) {
        printf("Color %d: %s\n", i, colors[i]);
    }
    
    return 0;
}
```

### String Storage Types

**Stack Storage (Automatic):**

```c
char local_string[100];  // Stack allocation
```

**Static Storage:**

```c
static char static_string[100];  // Static allocation
```

**String Literals (Read-Only):**

```c
char *literal = "Cannot modify this";  // Stored in read-only memory
```

### String Length and Size

**Calculating String Properties:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char text[] = "Programming";
    
    // String length (excluding null terminator)
    int length = strlen(text);
    
    // Array size (including null terminator)
    int size = sizeof(text);
    
    printf("String: %s\n", text);
    printf("Length: %d characters\n", length);
    printf("Array size: %d bytes\n", size);
    
    // Character access
    printf("First character: %c\n", text[0]);
    printf("Last character: %c\n", text[length - 1]);
    
    return 0;
}
```

