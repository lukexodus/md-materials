## Debugging Build Processes


### Build Debugging Overview

**Purpose**: Identify and fix issues during compilation and linking .

**Common Issues** :
- Compilation errors 
- Linking failures 
- Missing dependencies 
- Performance problems 

**Tools Available** :
- Compiler flags 
- Build system features 
- Debugging utilities 

### Compiler Debugging Flags

#### Debug Symbols

**Include Debug Info** :

```bash
gcc -g program.c -o program
```

**Debug Levels** :
- `-g`: Basic symbols 
- `-g1`: Minimal 
- `-g2`: Standard 
- `-g3`: Maximal (with macros) 

**With Optimization** :

```bash
gcc -g -O2 program.c -o program
```

Combines debugging with optimization .

#### Verbose Output

**Show Commands** :

```bash
make VERBOSE=1
```

**All Details** :

```bash
gcc -v program.c -o program
```

Shows compiler version and includes .

### Compiler Warning Levels

#### Basic Warnings

**Enable Warnings** :

```bash
gcc -Wall program.c -o program
```

**All Standard Warnings** :

```bash
gcc -Wall -Wextra program.c -o program
```

#### Strict Warnings

**Pedantic Mode** :

```bash
gcc -Wall -Wextra -pedantic program.c -o program
```

**Treat Warnings as Errors** :

```bash
gcc -Wall -Werror program.c -o program
```

#### Specific Warnings

**Undefined Behavior** :

```bash
gcc -Wundefined-behavior program.c -o program
```

**Format Issues** :

```bash
gcc -Wformat program.c -o program
```

**Uninitialized Variables** :

```bash
gcc -Wuninitialized program.c -o program
```

### Address Sanitizer

#### Detect Memory Issues

**Enable ASAN** :

```bash
gcc -fsanitize=address -g program.c -o program
./program
```

**Detects** :
- Buffer overflows 
- Use-after-free 
- Memory leaks 

#### Output

**Error Report** :

```
=================================================================
==12345==ERROR: AddressSanitizer: heap-buffer-overflow
...
```

Provides line numbers and context .

#### Combined Sanitizers

**Multiple Checks** :

```bash
gcc -fsanitize=address,undefined -g program.c -o program
```

### Undefined Behavior Sanitizer

#### Enable UBSan

**Runtime Checking** :

```bash
gcc -fsanitize=undefined -g program.c -o program
./program
```

**Detects** :
- Integer overflow 
- Division by zero 
- Null pointer dereference 

#### Output Example

**Error Message** :

```
program.c:10:5: runtime error: division by zero
```

### Profiling Build Time

#### Time Individual Steps

**Measure Compilation** :

```bash
time gcc program.c -o program
```

**Output** :

```
real    0m1.234s
user    0m1.200s
sys     0m0.034s
```

#### Detailed Build Timing

**Make Timing** :

```bash
time make -j4
```

**With Statistics** :

```bash
make clean
time make
```

Compare sequential vs parallel .

### GDB Debugging

#### Compile for Debugging

**Include Debug Symbols** :

```bash
gcc -g -O0 program.c -o program
```

**-O0**: Disable optimization for debugging .

#### Start GDB

**Launch Debugger** :

```bash
gdb ./program
```

**Inside GDB** :

```
(gdb) run
(gdb) bt              # Backtrace
(gdb) break main      # Set breakpoint
(gdb) continue        # Continue execution
(gdb) print variable  # Print variable
(gdb) quit            # Exit
```

#### Common Commands

**Set Breakpoint** :

```
(gdb) break function_name
(gdb) break filename.c:10
```

**Step Execution** :

```
(gdb) step          # Step into function
(gdb) next          # Step over function
(gdb) finish        # Return from function
```

**Inspect Variables** :

```
(gdb) print variable
(gdb) print *pointer
(gdb) print array[index]
```

### Valgrind Memory Analysis

#### Installation

**Install Valgrind** :

```bash
sudo pacman -S valgrind
```

#### Memory Leak Detection

**Run with Valgrind** :

```bash
valgrind --leak-check=full ./program
```

**Detailed Report** :

```bash
valgrind --leak-check=full --show-leak-kinds=all ./program
```

#### Output Example

**Leak Summary** :

```
LEAK SUMMARY:
  definitely lost: 100 bytes
  indirectly lost: 50 bytes
  possibly lost: 0 bytes
```

#### Advanced Options

**With Symbols** :

```bash
valgrind --leak-check=full --log-file=valgrind.log ./program
```

**Call Graph** :

```bash
valgrind --tool=callgrind ./program
kcachegrind callgrind.out.xxxxx
```

### Makefile Debugging

#### Verbose Output

**Show Rules** :

```bash
make -p
```

Shows all rules and variables .

**Debug Messages** :

In Makefile:

```makefile
debug:
	@echo "VAR=$(VAR)"
	@echo "OBJS=$(OBJS)"
```

**Run Debug** :

```bash
make debug
```

#### Dry Run

**No Actual Build** :

```bash
make -n
```

Shows commands without executing .

**Print Recipes** :

```bash
make --print-data-base
```

### CMake Debugging

#### Verbose Build

**Show Commands** :

```bash
cmake --build . --verbose
```

or

```bash
make VERBOSE=1
```

#### CMake Debug Messages

**Print Variables** :

In CMakeLists.txt:

```cmake
message(STATUS "Variable: ${VAR}")
message(FATAL_ERROR "Debug output")
```

**Run Verbose** :

```bash
cmake -DCMAKE_MESSAGE_LOG_LEVEL=DEBUG .
```

#### Check Generated Files

**CMake Output** :

```bash
cat CMakeCache.txt | grep VARIABLE
```

### Autotools Debugging

#### Configure Debug

**Verbose Configure** :

```bash
./configure --verbose
```

**Check Log** :

```bash
cat config.log | tail -100
```

#### Build Debugging

**Show Compilation** :

```bash
make V=1
```

or

```bash
./configure && make VERBOSE=1
```

### Linker Debugging

#### Missing Symbols

**Error** :

```
undefined reference to `function'
```

**Find Symbol** :

```bash
nm /usr/lib/libfile.a | grep function
```

**Link Library** :

```bash
gcc program.c -o program -lfile
```

#### Symbol Resolution

**Check Symbols** :

```bash
nm program
```

Shows all symbols .

**Undefined Symbols** :

```bash
nm -u program
```

Lists undefined symbols .

#### Linker Map

**Generate Map File** :

```bash
gcc -Wl,-Map=program.map program.c -o program
```

**Contents** :

```
cat program.map | head -20
```

Shows memory layout .

### Build System Issues

#### Missing Dependencies

**Check Requirements** :

```bash
./configure
cat config.log | grep -i error
```

**Install Missing** :

```bash
sudo pacman -S missing-package-dev
```

#### Environment Variables

**Set Paths** :

```bash
export CFLAGS="-O2 -march=native"
export LDFLAGS="-L/usr/local/lib"
export CPPFLAGS="-I/usr/local/include"
./configure
```

#### Library Paths

**Runtime Library Path** :

```bash
ldd program
```

Shows linked libraries .

**Rpath Setting** :

```bash
gcc program.c -o program -Wl,-rpath,/custom/lib
```

### Build Log Analysis

#### Capture Build Output

**Full Log** :

```bash
make 2>&1 | tee build.log
```

**Error Only** :

```bash
make 2>&1 | tee build.log | grep -i error
```

#### Parse Warnings

**Count Warnings** :

```bash
grep -i warning build.log | wc -l
```

**Extract Details** :

```bash
grep -i warning build.log | head -20
```

#### Find Errors

**Locate Errors** :

```bash
grep -i error build.log
```

**Context** :

```bash
grep -i error -B 2 -A 2 build.log
```

### Debugging PKGBUILD

#### Test Build

**Local Build** :

```bash
makepkg -L
```

Logs to `fakeroot.log` .

**Verbose** :

```bash
makepkg -L --verbose
```

#### Check Steps

**Extract Only** :

```bash
makepkg -e
```

**No Compile** :

Just extract source .

**Prep Only** :

```bash
makepkg -o
```

Runs build and package functions .

### GCC Diagnostic Options

#### Color Diagnostics

**Colored Output** :

```bash
gcc -fdiagnostics-color=always program.c -o program
```

**Better Readability** :

Highlights errors in terminal .

#### Show Column Numbers

**Precise Location** :

```bash
gcc -fshow-column program.c -o program
```

**Output** :

```
program.c:10:5: error: ...
```

Shows exact column .

### Performance Profiling

#### Compile-Time Performance

**Benchmark** :

```bash
time make clean
time make -j1
time make -j4
time make -j8
```

Compare parallelization impact .

#### Runtime Profiling

**Generate Profile** :

```bash
gcc -pg program.c -o program
./program
gprof program gmon.out
```

Shows function call times .

### Best Practices

**Enable Warnings**: Start with `-Wall` .

**Use Sanitizers**: Catch issues early .

**Save Logs**: Archive build output .

**Version Control**: Track build configuration .

**Incremental Builds**: Use dependencies .

**Test Compilers**: Try multiple versions .

**Document Issues**: Record solutions .

### Troubleshooting Checklist

**1. Compilation Errors** :
- Check syntax 
- Verify includes 
- Review compiler output 

**2. Linking Errors** :
- Check library paths 
- Verify symbols 
- Review link order 

**3. Runtime Issues** :
- Use debugger 
- Check memory 
- Profile performance 

**4. Build System** :
- Verify dependencies 
- Check environment 
- Review configuration 

***

This comprehensive guide on debugging build processes completes the full Arch Linux system administration documentation, providing users with essential tools and techniques to troubleshoot compilation issues, optimize build processes, and maintain high-quality software development practices within the Arch Linux ecosystem.

