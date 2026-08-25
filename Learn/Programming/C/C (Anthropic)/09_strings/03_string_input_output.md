## String Input/Output


String input and output operations require careful handling to prevent buffer overflows and ensure proper formatting.

### String Output Functions

**printf() Family:**

```c
#include <stdio.h>

int main(void) {
    char name[] = "Alice";
    int age = 25;
    double height = 5.7;
    
    // Basic string output
    printf("Name: %s\n", name);
    
    // Formatted output with field width
    printf("Name: %10s\n", name);      // Right-aligned in 10 characters
    printf("Name: %-10s|\n", name);    // Left-aligned in 10 characters
    
    // Precision specifier (maximum characters)
    printf("Name: %.3s\n", name);      // Print only first 3 characters
    
    // Combined formatting
    printf("Person: %s, Age: %d, Height: %.1f\n", name, age, height);
    
    return 0;
}
```

**puts() Function:**

```c
#include <stdio.h>

int main(void) {
    char messages[][30] = {
        "First message",
        "Second message",
        "Third message"
    };
    
    // puts() automatically adds newline
    puts("Using puts() function:");
    
    for (int i = 0; i < 3; i++) {
        puts(messages[i]);
    }
    
    // Comparison with printf
    printf("Using printf(): ");
    printf("%s", messages[0]);  // No automatic newline
    printf("\n");  // Manual newline
    
    return 0;
}
```

### String Input Functions

**scanf() for String Input:**

```c
#include <stdio.h>

int main(void) {
    char word[50];
    char sentence[100];
    
    printf("Enter a single word: ");
    scanf("%s", word);  // Stops at whitespace
    
    printf("You entered: %s\n", word);
    
    // Clear input buffer before next input
    while (getchar() != '\n');
    
    printf("Enter a sentence: ");
    scanf("%99[^\n]", sentence);  // Read until newline, limit to 99 chars
    
    printf("You entered: %s\n", sentence);
    
    return 0;
}
```

**gets() Alternative - fgets():**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char input[100];
    
    printf("Enter a line of text: ");
    
    // fgets() is safer than gets()
    if (fgets(input, sizeof(input), stdin) != NULL) {
        // Remove newline if present
        size_t len = strlen(input);
        if (len > 0 && input[len - 1] == '\n') {
            input[len - 1] = '\0';
        }
        
        printf("You entered: %s\n", input);
        printf("Length: %lu characters\n", strlen(input));
    }
    
    return 0;
}
```

**Character Input Functions:**

```c
#include <stdio.h>

int main(void) {
    char buffer[100];
    int i = 0;
    char ch;
    
    printf("Enter characters (press Enter to finish): ");
    
    // Read character by character
    while ((ch = getchar()) != '\n' && i < sizeof(buffer) - 1) {
        buffer[i] = ch;
        i++;
    }
    buffer[i] = '\0';  // Null terminate
    
    printf("You entered: %s\n", buffer);
    printf("Character count: %d\n", i);
    
    return 0;
}
```

### File String Operations

**Reading Strings from Files:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    FILE *file = fopen("sample.txt", "r");
    char line[256];
    int line_number = 1;
    
    if (file == NULL) {
        printf("Error opening file\n");
        return 1;
    }
    
    printf("File contents:\n");
    while (fgets(line, sizeof(line), file) != NULL) {
        // Remove newline if present
        line[strcspn(line, "\n")] = '\0';
        printf("Line %d: %s\n", line_number, line);
        line_number++;
    }
    
    fclose(file);
    return 0;
}
```

