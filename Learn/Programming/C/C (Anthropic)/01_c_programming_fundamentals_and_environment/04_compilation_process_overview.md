## Compilation Process Overview


The compilation process transforms C source code into executable machine code through multiple stages.

### Four Main Stages

**Preprocessing Stage:**

- Handles preprocessor directives
- Includes header files
- Expands macros
- Removes comments
- Produces expanded source code (.i files)

Command to see preprocessor output:

```bash
gcc -E source.c -o source.i
```

**Compilation Stage:**

- Parses preprocessed code
- Performs syntax and semantic analysis
- Generates assembly code
- Produces assembly files (.s files)

Command to generate assembly:

```bash
gcc -S source.c -o source.s
```

**Assembly Stage:**

- Converts assembly code to machine code
- Creates object files (.o files)
- Contains machine instructions and symbol tables

Command to create object file:

```bash
gcc -c source.c -o source.o
```

**Linking Stage:**

- Combines object files
- Resolves external references
- Links with libraries
- Produces executable file

Command for linking:

```bash
gcc source.o -o executable
```

### Compilation Workflow Visualization

```
source.c → [Preprocessor] → source.i → [Compiler] → source.s → [Assembler] → source.o → [Linker] → executable
```

### Build Process Considerations

**Header Dependencies:**

- Changes in header files require recompilation of dependent source files
- Use of include guards or `#pragma once` prevents multiple inclusions

**Library Linking:**

- Static libraries (.a, .lib): Code included in executable
- Dynamic libraries (.so, .dll): Linked at runtime
- System libraries: Usually linked dynamically

**Makefile Usage:**

```makefile
CC=gcc
CFLAGS=-Wall -Wextra -std=c99 -g
TARGET=program
SOURCES=main.c functions.c

$(TARGET): $(SOURCES)
    $(CC) $(CFLAGS) $(SOURCES) -o $(TARGET)

clean:
    rm -f $(TARGET)
```

