## String Manipulation Functions


The C standard library provides numerous functions for string manipulation through the `<string.h>` header.

### String Copying Functions

**strcpy() - String Copy:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char source[] = "Original string";
    char destination[50];
    
    // Copy entire string
    strcpy(destination, source);
    printf("Source: %s\n", source);
    printf("Destination: %s\n", destination);
    
    // Demonstrate potential buffer overflow risk
    char small_buffer[5];
    // strcpy(small_buffer, source);  // Dangerous! Buffer overflow
    
    return 0;
}
```

**strncpy() - Safe String Copy:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char source[] = "This is a long string";
    char destination[15];
    
    // Copy at most n-1 characters, ensuring null termination
    strncpy(destination, source, sizeof(destination) - 1);
    destination[sizeof(destination) - 1] = '\0';  // Ensure null termination
    
    printf("Source: %s\n", source);
    printf("Truncated destination: %s\n", destination);
    
    return 0;
}
```

### String Concatenation Functions

**strcat() - String Concatenation:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char greeting[50] = "Hello, ";
    char name[] = "World!";
    
    // Append name to greeting
    strcat(greeting, name);
    printf("Concatenated: %s\n", greeting);
    
    // Multiple concatenations
    char result[100] = "C ";
    strcat(result, "is ");
    strcat(result, "a ");
    strcat(result, "powerful ");
    strcat(result, "language.");
    
    printf("Result: %s\n", result);
    
    return 0;
}
```

**strncat() - Safe String Concatenation:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char buffer[20] = "Hello";
    char addition[] = " Programming World";
    
    // Concatenate at most n characters
    strncat(buffer, addition, sizeof(buffer) - strlen(buffer) - 1);
    
    printf("Safe concatenation: %s\n", buffer);
    
    return 0;
}
```

### String Length Function

**strlen() - String Length:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char strings[][30] = {
        "Short",
        "Medium length string",
        "This is a much longer string example",
        ""  // Empty string
    };
    
    int count = sizeof(strings) / sizeof(strings[0]);
    
    for (int i = 0; i < count; i++) {
        printf("String %d: \"%s\" (Length: %lu)\n", 
               i, strings[i], strlen(strings[i]));
    }
    
    return 0;
}
```

### Custom String Functions

**Manual String Length:**

```c
#include <stdio.h>

int my_strlen(const char *str) {
    int length = 0;
    while (str[length] != '\0') {
        length++;
    }
    return length;
}

int main(void) {
    char test[] = "Custom function test";
    
    printf("String: %s\n", test);
    printf("Custom strlen: %d\n", my_strlen(test));
    printf("Standard strlen: %lu\n", strlen(test));
    
    return 0;
}
```

**Manual String Copy:**

```c
#include <stdio.h>

void my_strcpy(char *dest, const char *src) {
    int i = 0;
    while (src[i] != '\0') {
        dest[i] = src[i];
        i++;
    }
    dest[i] = '\0';  // Add null terminator
}

int main(void) {
    char original[] = "Source string";
    char copy[50];
    
    my_strcpy(copy, original);
    
    printf("Original: %s\n", original);
    printf("Copy: %s\n", copy);
    
    return 0;
}
```

