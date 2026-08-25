## Debugging Tools Introduction


Debugging tools help identify and fix errors in C programs through various techniques and utilities.

### GDB (GNU Debugger)

GDB is the standard debugger for programs compiled with GCC.

**Basic GDB Usage:**

```bash
# Compile with debugging symbols
gcc -g program.c -o program

# Start GDB
gdb ./program
```

**Essential GDB Commands:**

- `run` or `r`: Start program execution
- `break` or `b`: Set breakpoint at line/function
- `continue` or `c`: Continue execution
- `step` or `s`: Execute one line (step into functions)
- `next` or `n`: Execute one line (step over functions)
- `print` or `p`: Print variable value
- `list` or `l`: Show source code
- `backtrace` or `bt`: Show call stack
- `quit` or `q`: Exit GDB

**Advanced GDB Features:**

- Watchpoints: Break when variable changes
- Conditional breakpoints: Break under specific conditions
- Core dump analysis: Examine crashed program state
- Remote debugging: Debug programs on different machines

### LLDB

LLDB is the debugger for Clang/LLVM, with similar functionality to GDB.

**Basic LLDB Commands:**

- `target create program`: Load program
- `run`: Start execution
- `breakpoint set -n function_name`: Set breakpoint
- `thread step-over`: Step over function calls
- `frame variable`: Print local variables

### Static Analysis Tools

**Compiler Warnings:** Enable comprehensive warnings during compilation:

```bash
gcc -Wall -Wextra -Wpedantic -Werror source.c
```

**Clang Static Analyzer:**

```bash
clang --analyze source.c
```

**Cppcheck:**

```bash
cppcheck source.c
```

**Valgrind (Memory Debugging):**

```bash
valgrind --tool=memcheck --leak-check=full ./program
```

### Runtime Debugging Techniques

**Printf Debugging:** Strategic placement of printf statements to trace program execution:

```c
printf("DEBUG: Variable x = %d at line %d\n", x, __LINE__);
```

**Assertion Debugging:**

```c
#include <assert.h>
assert(x > 0);  // Program terminates if condition false
```

**Address Sanitizer:**

```bash
gcc -fsanitize=address -g source.c -o program
```

### IDE Debugging Features

**Visual Studio Code:**

- Integrated debugging with breakpoints
- Variable inspection
- Call stack visualization
- Debug console

**CLion:**

- Advanced debugging interface
- Memory view
- Disassembly view
- Profiling integration

**Key Points:**

- Always compile with `-g` flag for debugging symbols
- Use multiple debugging approaches for complex issues
- Static analysis catches many errors before runtime
- Memory debugging tools are essential for pointer-related issues
- IDE debuggers provide user-friendly interfaces for debugging workflow

**Example Debug Session:**

```c
#include <stdio.h>

int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

int main(void) {
    int num = 5;
    int result = factorial(num);
    printf("Factorial of %d is %d\n", num, result);
    return 0;
}
```

Debug commands:

```
gdb ./program
(gdb) break factorial
(gdb) run
(gdb) print n
(gdb) step
(gdb) continue
```

Understanding these fundamental concepts and tools provides the foundation for effective C programming development, enabling creation of robust, maintainable, and debuggable code across different platforms and environments.

---

