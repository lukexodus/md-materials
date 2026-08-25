## String Comparison and Searching


String comparison and searching functions enable text processing and pattern matching operations.

### String Comparison Functions

**strcmp() - String Comparison:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char str1[] = "Apple";
    char str2[] = "Banana";
    char str3[] = "Apple";
    
    int result1 = strcmp(str1, str2);  // Negative (Apple < Banana)
    int result2 = strcmp(str1, str3);  // Zero (Apple == Apple)
    int result3 = strcmp(str2, str1);  // Positive (Banana > Apple)
    
    printf("strcmp(\"%s\", \"%s\") = %d\n", str1, str2, result1);
    printf("strcmp(\"%s\", \"%s\") = %d\n", str1, str3, result2);
    printf("strcmp(\"%s\", \"%s\") = %d\n", str2, str1, result3);
    
    // Practical comparison
    if (strcmp(str1, str3) == 0) {
        printf("\"%s\" and \"%s\" are identical\n", str1, str3);
    }
    
    return 0;
}
```

**strncmp() - Limited String Comparison:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char str1[] = "Programming";
    char str2[] = "Program";
    char str3[] = "Progress";
    
    // Compare first n characters
    int result1 = strncmp(str1, str2, 7);  // Compare "Program"
    int result2 = strncmp(str1, str3, 4);  // Compare "Prog"
    
    printf("strncmp(\"%s\", \"%s\", 7) = %d\n", str1, str2, result1);
    printf("strncmp(\"%s\", \"%s\", 4) = %d\n", str1, str3, result2);
    
    return 0;
}
```

**Case-Insensitive Comparison (Custom Function):**

```c
#include <stdio.h>
#include <ctype.h>

int strcasecmp_custom(const char *str1, const char *str2) {
    while (*str1 && *str2) {
        int c1 = tolower(*str1);
        int c2 = tolower(*str2);
        if (c1 != c2) {
            return c1 - c2;
        }
        str1++;
        str2++;
    }
    return tolower(*str1) - tolower(*str2);
}

int main(void) {
    char str1[] = "Hello";
    char str2[] = "HELLO";
    char str3[] = "hello";
    
    printf("Case-sensitive comparison:\n");
    printf("strcmp(\"%s\", \"%s\") = %d\n", str1, str2, strcmp(str1, str2));
    
    printf("Case-insensitive comparison:\n");
    printf("strcasecmp(\"%s\", \"%s\") = %d\n", str1, str2, strcasecmp_custom(str1, str2));
    printf("strcasecmp(\"%s\", \"%s\") = %d\n", str1, str3, strcasecmp_custom(str1, str3));
    
    return 0;
}
```

### String Searching Functions

**strchr() - Find Character:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char text[] = "Hello, World!";
    char target = 'o';
    
    // Find first occurrence
    char *first_o = strchr(text, target);
    if (first_o != NULL) {
        printf("First '%c' found at position: %ld\n", target, first_o - text);
        printf("Substring from first '%c': %s\n", target, first_o);
    }
    
    // Find last occurrence
    char *last_o = strrchr(text, target);
    if (last_o != NULL) {
        printf("Last '%c' found at position: %ld\n", target, last_o - text);
    }
    
    // Count occurrences
    int count = 0;
    char *ptr = text;
    while ((ptr = strchr(ptr, target)) != NULL) {
        count++;
        ptr++;  // Move past found character
    }
    printf("Total occurrences of '%c': %d\n", target, count);
    
    return 0;
}
```

**strstr() - Find Substring:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char text[] = "The quick brown fox jumps over the lazy dog";
    char pattern[] = "brown";
    
    // Find substring
    char *found = strstr(text, pattern);
    if (found != NULL) {
        printf("Pattern \"%s\" found at position: %ld\n", pattern, found - text);
        printf("Substring from match: %s\n", found);
    } else {
        printf("Pattern \"%s\" not found\n", pattern);
    }
    
    // Find all occurrences
    char haystack[] = "ababababab";
    char needle[] = "ab";
    char *ptr = haystack;
    int position = 0;
    
    printf("Finding all occurrences of \"%s\" in \"%s\":\n", needle, haystack);
    while ((ptr = strstr(ptr, needle)) != NULL) {
        position = ptr - haystack;
        printf("Found at position: %d\n", position);
        ptr++;  // Move past current match to find overlapping matches
    }
    
    return 0;
}
```

**strspn() and strcspn() - Span Functions:**

```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char text[] = "12345abcde67890";
    char digits[] = "0123456789";
    char letters[] = "abcdefghijklmnopqrstuvwxyz";
    
    // strspn: Count initial characters from set
    size_t digit_span = strspn(text, digits);
    printf("Initial digits in \"%s\": %zu characters\n", text, digit_span);
    printf("Initial digit sequence: \"");
    for (size_t i = 0; i < digit_span; i++) {
        printf("%c", text[i]);
    }
    printf("\"\n");
    
    // strcspn: Count initial characters NOT in set
    size_t non_letter_span = strcspn(text, letters);
    printf("Initial non-letters: %zu characters\n", non_letter_span);
    
    // Skip digits and find letters
    char *letter_start = text + digit_span;
    size_t letter_span = strspn(letter_start, letters);
    printf("Letter sequence: \"");
    for (size_t i = 0; i < letter_span; i++) {
        printf("%c", letter_start[i]);
    }
    printf("\"\n");
    
    return 0;
}
```

### Advanced String Searching

**Custom Pattern Matching:**

```c
#include <stdio.h>
#include <string.h>

// Simple wildcard matching (* matches any sequence)
int wildcard_match(const char *pattern, const char *text) {
    if (*pattern == '\0' && *text == '\0') return 1;
    if (*pattern == '*') {
        if (*(pattern + 1) == '\0') return 1;  // * at end matches everything
        while (*text != '\0') {
            if (wildcard_match(pattern + 1, text)) return 1;
            text++;
        }
        return wildcard_match(pattern + 1, text);
    }
    if (*pattern == *text && *pattern != '\0') {
        return wildcard_match(pattern + 1, text + 1);
    }
    return 0;
}

int main(void) {
    char text[] = "hello world";
    
    printf("Text: \"%s\"\n", text);
    printf("Pattern \"h*o\": %s\n", wildcard_match("h*o", text) ? "Match" : "No match");
    printf("Pattern \"*world\": %s\n", wildcard_match("*world", text) ? "Match" : "No match");
    printf("Pattern \"hello*\": %s\n", wildcard_match("hello*", text) ? "Match" : "No match");
    printf("Pattern \"*o*\": %s\n", wildcard_match("*o*", text) ? "Match" : "No match");
    printf("Pattern \"xyz\": %s\n", wildcard_match("xyz", text) ? "Match" : "No match");
    
    return 0;
}
```

