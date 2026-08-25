## Compiler Basics


C compilers translate human-readable C source code into machine-executable code. Understanding compiler functionality is essential for effective C development.

### GCC (GNU Compiler Collection)

GCC is the most widely used C compiler, supporting multiple architectures and operating systems.

**Basic Usage:**

```bash
gcc source_file.c -o output_program
```

**Common GCC Options:**

- `-c`: Compile only, don't link
- `-o filename`: Specify output file name
- `-g`: Include debugging information
- `-Wall`: Enable common warnings
- `-Wextra`: Enable additional warnings
- `-std=c99`: Specify C standard version
- `-O2`: Enable optimization level 2
- `-I directory`: Add include directory
- `-L directory`: Add library directory
- `-l library`: Link with library

**Optimization Levels:**

- `-O0`: No optimization (default)
- `-O1`: Basic optimization
- `-O2`: Recommended optimization level
- `-O3`: Aggressive optimization
- `-Os`: Optimize for size

### Clang

Clang is another popular C compiler, part of the LLVM project, known for fast compilation and excellent error messages.

**Basic Usage:**

```bash
clang source_file.c -o output_program
```

**Clang-Specific Features:**

- Superior error and warning messages
- Static analysis capabilities
- Faster compilation times
- Better standards compliance
- Integrated sanitizers for debugging

**Common Clang Options:** Similar to GCC with additional features:

- `-fsanitize=address`: Address sanitizer
- `-fsanitize=memory`: Memory sanitizer
- `-fsanitize=thread`: Thread sanitizer
- `-analyzer-checker`: Static analysis checks

### Microsoft Visual C++ (MSVC)

MSVC is Microsoft's C/C++ compiler for Windows development.

**Basic Usage:**

```cmd
cl source_file.c
```

**Common MSVC Options:**

- `/Fe:filename`: Specify executable name
- `/Zi`: Generate debug information
- `/W4`: Enable high warning level
- `/O2`: Optimize for speed
- `/I directory`: Add include directory

