## Standard C Library Overview


The Standard C Library consists of multiple header files that group related functionality together. Each header file contains function prototypes, macro definitions, and type declarations for specific domains.

**Core Header Files:**

- `stdio.h`: Input/output operations
- `stdlib.h`: General utility functions
- `string.h`: String manipulation functions
- `math.h`: Mathematical functions
- `time.h`: Date and time functions
- `ctype.h`: Character classification and conversion
- `stddef.h`: Standard definitions and types
- `limits.h`: Implementation-defined limits
- `float.h`: Floating-point characteristics
- `errno.h`: Error number definitions

**Library Architecture:**

- Functions are typically implemented in object files linked during compilation
- Header files contain only declarations, not implementations
- Some functionality provided through macros for efficiency
- Platform-specific implementations maintain consistent interfaces

**Standard Compliance Levels:**

- C89/C90: Original ANSI C standard
- C95: Amendment with wide character support
- C99: Added inline functions, variable-length arrays, complex numbers
- C11: Thread support, bounds-checking functions, aligned allocation
- C18: Technical corrections and clarifications

**Linking Requirements:**

- Most functions automatically linked with standard compilation
- Math library may require explicit linking with `-lm` flag
- Thread functions may require `-lpthread` on some systems

