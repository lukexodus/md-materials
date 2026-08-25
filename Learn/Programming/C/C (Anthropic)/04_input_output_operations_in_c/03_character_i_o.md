## Character I/O


Character-level I/O operations provide precise control over individual character processing. The primary functions handle single character operations:

### Input Functions

- `getchar()` - reads single character from stdin
- `getc(FILE *)` - reads single character from specified stream
- `fgetc(FILE *)` - functionally identical to getc but guaranteed to be a function

### Output Functions

- `putchar(int)` - writes single character to stdout
- `putc(int, FILE *)` - writes single character to specified stream
- `fputc(int, FILE *)` - functionally identical to putc but guaranteed to be a function

**Example** of character I/O processing:

```c
#include <stdio.h>
#include <ctype.h>

int main() {
    int ch;
    int uppercase_count = 0;
    
    printf("Enter text (Ctrl+D to end):\n");
    
    while ((ch = getchar()) != EOF) {
        if (isupper(ch)) {
            uppercase_count++;
        }
        putchar(tolower(ch));
    }
    
    printf("\nUppercase letters converted: %d\n", uppercase_count);
    return 0;
}
```

Character I/O functions return `int` rather than `char` to accommodate the special `EOF` value (-1), which indicates end-of-file or error conditions.

**Key points** for character I/O:

- Always use `int` type for variables storing character input
- Check for `EOF` in input loops
- Character functions are often implemented as macros for efficiency
- Buffering still applies to character I/O operations

