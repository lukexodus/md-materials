## Predefined Macros


The C standard and compilers define numerous macros automatically, providing information about the compilation environment, source file, and compiler characteristics.

**Standard Predefined Macros**

- `__FILE__` - current source file name (string literal)
- `__LINE__` - current line number (integer)
- `__DATE__` - compilation date ("MMM DD YYYY")
- `__TIME__` - compilation time ("HH:MM:SS")
- `__STDC__` - 1 if conforming C compiler
- `__STDC_VERSION__` - C standard version (199901L for C99, 201112L for C11, etc.)

**Compiler-Specific Macros** Different compilers define their own identification macros:

- GCC: `__GNUC__`, `__GNUC_MINOR__`
- Clang: `__clang__`, `__clang_major__`
- Microsoft: `_MSC_VER`
- Intel: `__INTEL_COMPILER`

**Platform Identification**

- `_WIN32` - Windows (32 or 64-bit)
- `_WIN64` - Windows 64-bit
- `__linux__` - Linux
- `__APPLE__` - macOS/iOS
- `__unix__` - Unix-like systems

**Architecture Macros**

- `__x86_64__` - x86-64 architecture
- `__i386__` - x86 32-bit
- `__ARM_ARCH` - ARM architecture
- `__aarch64__` - ARM 64-bit

**Examples**

```c
#include <stdio.h>

void print_build_info() {
    printf("File: %s\n", __FILE__);
    printf("Line: %d\n", __LINE__);
    printf("Compiled: %s %s\n", __DATE__, __TIME__);
    
#ifdef __STDC_VERSION__
    printf("C Standard: %ld\n", __STDC_VERSION__);
#endif

#ifdef __GNUC__
    printf("GCC Version: %d.%d\n", __GNUC__, __GNUC_MINOR__);
#endif
}

// Conditional compilation based on predefined macros
#if defined(_WIN32)
    #include <windows.h>
    #define SLEEP(ms) Sleep(ms)
#elif defined(__linux__) || defined(__APPLE__)
    #include <unistd.h>
    #define SLEEP(ms) usleep((ms) * 1000)
#endif
```

**Useful Debugging Macros**

```c
#define WHERE() printf("File %s, Line %d\n", __FILE__, __LINE__)

#define ASSERT(cond) \
    do { \
        if (!(cond)) { \
            fprintf(stderr, "Assertion failed: %s, file %s, line %d\n", \
                   #cond, __FILE__, __LINE__); \
            abort(); \
        } \
    } while(0)
```

**Key Points**

- Predefined macros provide compilation context
- They enable portable code across platforms and compilers
- Standard macros are guaranteed to exist
- Compiler-specific macros require conditional testing
- These macros are automatically defined and cannot be undefined

**Advanced Usage**

```c
// Version checking
#if __STDC_VERSION__ >= 201112L
    #include <stdalign.h>  // C11 feature
    #define ALIGNED(n) _Alignas(n)
#else
    #define ALIGNED(n) __attribute__((aligned(n)))  // GCC extension
#endif

// Feature detection
#ifdef __has_include  // C23 feature
    #if __has_include(<threads.h>)
        #include <threads.h>
        #define HAS_THREADS 1
    #endif
#endif
```

The preprocessor serves as a powerful code generation and configuration tool, enabling flexible, portable, and maintainable C programs through careful use of macros, conditional compilation, and file organization.

---

