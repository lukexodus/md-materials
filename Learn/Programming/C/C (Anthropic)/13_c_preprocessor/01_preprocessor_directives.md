## Preprocessor Directives


Preprocessor directives are commands that instruct the preprocessor to perform specific operations on the source code. All directives begin with # and must appear as the first non-whitespace character on a line.

**Key Points**

- Directives are processed before compilation
- They operate on text, not on C language constructs
- Multiple directives can appear on separate lines
- Whitespace before # is ignored, but # must be the first non-whitespace character

**Common Directives**

- `#include` - includes the contents of another file
- `#define` - creates macro definitions
- `#undef` - removes macro definitions
- `#if`, `#ifdef`, `#ifndef` - conditional compilation
- `#else`, `#elif`, `#endif` - conditional compilation blocks
- `#line` - changes line number information
- `#pragma` - compiler-specific instructions
- `#error` - generates compilation error with message

**Examples**

```c
#include <stdio.h>
#define MAX_SIZE 100
#ifdef DEBUG
    #define PRINT(x) printf(x)
#else
    #define PRINT(x)
#endif
```

