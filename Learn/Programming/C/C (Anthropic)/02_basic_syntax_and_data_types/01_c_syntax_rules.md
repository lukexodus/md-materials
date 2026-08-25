## C Syntax Rules


C follows strict syntactic conventions that must be adhered to for successful compilation. Every C program begins with preprocessor directives, followed by function declarations and definitions. Statements are terminated with semicolons, and code blocks are enclosed in curly braces. C is case-sensitive, meaning `Variable` and `variable` are treated as distinct identifiers.

The basic structure requires a `main()` function as the entry point. Whitespace (spaces, tabs, newlines) is generally ignored except within string literals and character constants. Comments can be single-line using `//` or multi-line using `/* */` delimiters.

**Key points:**

- Semicolons terminate statements
- Curly braces define code blocks
- Case sensitivity applies throughout
- Whitespace flexibility except in literals
- Comments do not affect program execution

**Example:**

```c
#include <stdio.h>

int main() {
    // Single-line comment
    /* Multi-line
       comment */
    printf("Hello, World!");
    return 0;
}
```

