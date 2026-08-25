## Character Classification Functions


The `<ctype.h>` header provides functions for character classification and conversion.

### Character Testing Functions

**Basic Character Classification:**

```c
#include <stdio.h>
#include <ctype.h>

int main(void) {
    char test_chars[] = {'a', 'A', '5', ' ', '\n', '@', '\0'};
    
    printf("Character classification test:\n");
    printf("Char | isalpha | isdigit | isalnum | isspace | ispunct | isupper | islower\n");
    printf("-----|---------|---------|---------|---------|---------|---------|--------\n");
    
    for (int i = 0; test_chars[i] != '\0'; i++) {
        char ch = test_chars[i];
        printf("'%c'  |   %d     |   %d     |   %d     |   %d     |   %d     |   %d     |   %d\n",
               (ch == '\n') ? 'n' : ch,  // Display 'n' for newline
               isalpha(ch), isdigit(ch), isalnum(ch), 
               isspace(ch), ispunct(ch), isupper(ch), islower(ch));
    }
    
    return 0;
}
```

**String Analysis with Character Functions:**

```c
#include <stdio.h>
#include <ctype.h>
#include <string.h>

void analyze_string(const char *str) {
    int letters = 0, digits = 0, spaces = 0, punctuation = 0, others = 0;
    int uppercase = 0, lowercase = 0;
    
    printf("Analyzing string: \"%s\"\n", str);
    
    for (int i = 0; str[i] != '\0'; i++) {
        char ch = str[i];
        
        if (isalpha(ch)) {
            letters++;
            if (isupper(ch)) uppercase++;
            if (islower(ch)) lowercase++;
        } else if (isdigit(ch)) {
            digits++;
        } else if (isspace(ch)) {
            spaces++;
        } else if (ispunct(ch)) {
            punctuation++;
        } else {
            others++;
        }
    }
    
    printf("Statistics:\n");
    printf("  Total length: %lu\n", strlen(str));
    printf("  Letters: %d (Uppercase: %d, Lowercase: %d)\n", letters, uppercase, lowercase);
    printf("  Digits: %d\n", digits);
    printf("  Spaces: %d\n", spaces);
    printf("  Punctuation: %d\n", punctuation);
    printf("  Others: %d\n", others);
}

int main(void) {
    char samples[][50] = {
        "Hello, World! 123",
        "Programming in C",
        "12345",
        "Special@#$%Characters",
        "MiXeD CaSe StRiNg"
    };
    
    int count = sizeof(samples) / sizeof(samples[0]);
    
    for (int i = 0; i < count; i++) {
        analyze_string(samples[i]);
        printf("\n");
    }
    
    return 0;
}
```

### Character Conversion Functions

**Case Conversion:**

```c
#include <stdio.h>
#include <ctype.h>
#include <string.h>

void to_uppercase(char *str) {
    for (int i = 0; str[i] != '\0'; i++) {
        str[i] = toupper(str[i]);
    }
}

void to_lowercase(char *str) {
    for (int i = 0; str[i] != '\0'; i++) {
        str[i] = tolower(str[i]);
    }
}

void toggle_case(char *str) {
    for (int i = 0; str[i] != '\0'; i++) {
        if (isupper(str[i])) {
            str[i] = tolower(str[i]);
        } else if (islower(str[i])) {
            str[i] = toupper(str[i]);
        }
    }
}

void capitalize_words(char *str) {
    int capitalize_next = 1;  // Capitalize first character
    
    for (int i = 0; str[i] != '\0'; i++) {
        if (isspace(str[i])) {
            capitalize_next = 1;
        } else if (capitalize_next && isalpha(str[i])) {
            str[i] = toupper(str[i]);
            capitalize_next = 0;
        } else if (isalpha(str[i])) {
            str[i] = tolower(str[i]);
        }
    }
}

int main(void) {
    char original[] = "hello WORLD programming";
    char test1[50], test2[50], test3[50], test4[50];
    
    // Make copies for different transformations
    strcpy(test1, original);
    strcpy(test2, original);
    strcpy(test3, original);
    strcpy(test4, original);
    
    printf("Original: %s\n", original);
    
    to_uppercase(test1);
    printf("Uppercase: %s\n", test1);
    
    to_lowercase(test2);
    printf("Lowercase: %s\n", test2);
    
    toggle_case(test3);
    printf("Toggled case: %s\n", test3);
    
    capitalize_words(test4);
    printf("Capitalized words: %s\n", test4);
    
    return 0;
}
```

**Input Validation Using Character Functions:**

```c
#include <stdio.h>
#include <ctype.h>
#include <string.h>

int is_valid_identifier(const char *str) {
    if (str == NULL || strlen(str) == 0) return 0;
    
    // First character must be letter or underscore
    if (!isalpha(str[0]) && str[0] != '_') return 0;
    
    // Remaining characters must be alphanumeric or underscore
    for (int i = 1; str[i] != '\0'; i++) {
        if (!isalnum(str[i]) && str[i] != '_') return 0;
    }
    
    return 1;
}

int is_valid_number(const char *str) {
    if (str == NULL || strlen(str) == 0) return 0;
    
    int i = 0;
    
    // Handle optional sign
    if (str[i] == '+' || str[i] == '-') i++;
    
    // Must have at least one digit
    if (!isdigit(str[i])) return 0;
    
    // Check remaining characters are digits
    while (str[i] != '\0') {
        if (!isdigit(str[i])) return 0;
        i++;
    }
    
    return 1;
}

int main(void) {
    char identifiers[][20] = {
        "valid_name",
        "name123",
        "_private",
        "123invalid",
        "has-hyphen",
        "normal"
    };
    
    char numbers[][10] = {
        "123",
        "-456",
        "+789",
        "12a34",
        "abc",
        ""
    };
    
    printf("Identifier validation:\n");
    for (int i = 0; i < 6; i++) {
        printf("\"%s\": %s\n", identifiers[i], 
               is_valid_identifier(identifiers[i]) ? "Valid" : "Invalid");
    }
    
    printf("\nNumber validation:\n");
    for (int i = 0; i < 6; i++) {
        printf("\"%s\": %s\n", numbers[i], 
               is_valid_number(numbers[i]) ? "Valid" : "Invalid");
    }
    
    return 0;
}
```

**Key Points:**

- C strings are null-terminated character arrays requiring careful memory management
- String manipulation functions from `<string.h>` provide essential operations but [Unverified] may not always prevent buffer overflows
- Safe string functions (strncpy, strncat, fgets) should be preferred over unsafe alternatives
- String comparison uses lexicographical ordering based on character ASCII values
- Character classification functions enable robust text processing and input validation
- [Inference] Manual implementation of string functions provides better understanding of underlying operations but standard library functions are typically optimized for performance

Understanding string handling is fundamental for text processing, user input validation, file parsing, and many other programming tasks in C. Proper string management prevents common vulnerabilities and ensures reliable program operation.

---

