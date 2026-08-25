## Conditional Compilation


Conditional compilation allows including or excluding code sections based on preprocessor conditions. This enables platform-specific code, debug builds, and feature toggles.

**Basic Conditional Directives**

```c
#if expression
    // code if expression is true
#elif expression
    // code if elif expression is true
#else
    // code if all expressions are false
#endif
```

**Defined/Undefined Testing**

```c
#ifdef MACRO_NAME
    // code if MACRO_NAME is defined
#endif

#ifndef MACRO_NAME
    // code if MACRO_NAME is not defined
#endif

#if defined(MACRO1) && defined(MACRO2)
    // code if both macros are defined
#endif
```

**Conditional Expressions** The preprocessor evaluates constant expressions using:

- Integer arithmetic operators
- Logical operators (&&, ||, !)
- Comparison operators
- `defined()` operator
- Character constants (treated as integers)

**Examples**

```c
#if DEBUG_LEVEL >= 2
    #define VERBOSE_DEBUG
#endif

#ifdef _WIN32
    #include <windows.h>
    #define PATH_SEPARATOR '\\'
#elif defined(__linux__)
    #include <unistd.h>
    #define PATH_SEPARATOR '/'
#else
    #error "Unsupported platform"
#endif
```

**Key Points**

- Conditions are evaluated at preprocessing time
- Only integer constant expressions are allowed
- Undefined macros evaluate to 0 in expressions
- Nested conditional blocks are permitted

