# clang

`clang` is a C, C++, and Objective-C compiler front end built on the LLVM compiler infrastructure. It is the default compiler on macOS and is widely used on Linux as an alternative to GCC.

---

## Installation

```bash
# Debian / Ubuntu
sudo apt install clang

# Install a specific version
sudo apt install clang-17

# Arch / Manjaro
sudo pacman -S clang

# Fedora
sudo dnf install clang

# macOS (ships with Xcode Command Line Tools)
xcode-select --install

# macOS (specific LLVM version via Homebrew)
brew install llvm

# Windows
# Download the LLVM installer from https://releases.llvm.org
# Or via winget:
winget install LLVM.LLVM
```

```bash
# Verify installation
clang --version
clang++ --version
```

---

## clang vs clang++ vs clang-cl

|Command|Use for|
|---|---|
|`clang`|C source files|
|`clang++`|C++ source files|
|`clang-cl`|MSVC-compatible driver (Windows)|

`clang` can compile C++ with `-x c++`, but `clang++` is the conventional command and sets C++-appropriate defaults.

---

## Compilation Pipeline

A source file goes through four stages. You can stop at any stage.

```
Source (.c / .cpp)
      │
      ▼
  Preprocessing   →  clang -E        →  .i / .ii
      │
      ▼
  Compilation     →  clang -S        →  .s  (assembly)
      │
      ▼
  Assembly        →  clang -c        →  .o  (object file)
      │
      ▼
  Linking         →  clang           →  executable
```

```bash
clang -E file.c               # preprocess only (output to stdout)
clang -S file.c               # compile to assembly (.s)
clang -c file.c               # compile to object file (.o)
clang file.c -o program       # full compile + link to executable
```

---

## Basic Usage

```bash
# Compile and link a single file
clang file.c -o program

# Compile multiple files
clang file1.c file2.c -o program

# C++
clang++ file.cpp -o program

# Compile without linking
clang -c file.c               # produces file.o

# Link object files
clang file1.o file2.o -o program
```

---

## Language Standards

```bash
clang -std=c89 file.c
clang -std=c99 file.c
clang -std=c11 file.c
clang -std=c17 file.c
clang -std=c23 file.c         # C23 (support varies by version)

clang++ -std=c++11 file.cpp
clang++ -std=c++14 file.cpp
clang++ -std=c++17 file.cpp
clang++ -std=c++20 file.cpp
clang++ -std=c++23 file.cpp   # support varies by version

# GNU extensions (common default on Linux)
clang -std=gnu17 file.c
clang++ -std=gnu++17 file.cpp
```

---

## Optimization Levels

|Flag|Level|Description|
|---|---|---|
|`-O0`|None|No optimization. Fastest compile, easiest to debug. Default.|
|`-O1`|Basic|Quick optimizations, minimal impact on debug info.|
|`-O2`|Standard|Most optimizations without space/speed tradeoffs.|
|`-O3`|Aggressive|Additional vectorization, inlining, loop unrolling.|
|`-Os`|Size|Optimize for small binary size.|
|`-Oz`|Smallest|More aggressive size reduction than `-Os`.|
|`-Og`|Debug|Optimize but preserve debuggability.|
|`-Ofast`|Unsafe|`-O3` + non-standard floating point optimizations.|

```bash
clang -O2 file.c -o program
clang -O3 -march=native file.c -o program   # also tune for current CPU
```

---

## Warnings

```bash
clang -Wall file.c              # common warnings
clang -Wextra file.c            # additional warnings
clang -Wpedantic file.c         # strict standard conformance warnings
clang -Werror file.c            # treat all warnings as errors
clang -Weverything file.c       # every warning clang knows (very verbose)
clang -w file.c                 # suppress all warnings

# Disable a specific warning
clang -Wall -Wno-unused-variable file.c

# Useful individual warnings
clang -Wshadow file.c           # variable shadowing
clang -Wconversion file.c       # implicit type conversions
clang -Wnull-dereference file.c
clang -Wformat=2 file.c         # stricter printf/scanf format checking
```

> **Note:** `-Weverything` is a clang-specific flag. It is useful for discovery but not recommended for production builds — it enables warnings that intentionally conflict with each other.

---

## Debugging

```bash
# Include debug symbols
clang -g file.c -o program      # DWARF debug info (default format)
clang -g3 file.c -o program     # include macro definitions
clang -glldb file.c -o program  # optimize for lldb
clang -ggdb file.c -o program   # optimize for gdb

# Disable optimizations for cleaner debugging
clang -g -O0 file.c -o program
```

Use with `lldb` (clang's native debugger) or `gdb`:

```bash
lldb ./program
gdb ./program
```

---

## Sanitizers

Sanitizers instrument your binary at compile time to detect bugs at runtime.

```bash
# AddressSanitizer — detects memory errors (buffer overflow, use-after-free, etc.)
clang -fsanitize=address -g file.c -o program

# UndefinedBehaviorSanitizer — detects undefined behavior
clang -fsanitize=undefined -g file.c -o program

# ThreadSanitizer — detects data races
clang -fsanitize=thread -g file.c -o program

# MemorySanitizer — detects use of uninitialized memory (Linux only)
clang -fsanitize=memory -g file.c -o program

# Combine sanitizers (address + undefined is a common combo)
clang -fsanitize=address,undefined -g file.c -o program

# LeakSanitizer (often included with AddressSanitizer)
clang -fsanitize=address -fsanitize-address-use-after-scope file.c -o program
```

> **[Inference]** Sanitizers add runtime overhead (typically 2–10× slowdown depending on type). They are intended for development and testing builds, not production.

---

## Include Paths and Defines

```bash
# Add an include search path
clang -I/path/to/headers file.c

# Add multiple include paths
clang -I./include -I/usr/local/include file.c

# Define a preprocessor macro
clang -DDEBUG file.c
clang -DVERSION=2 file.c
clang -DNDEBUG file.c           # disable assert()

# Undefine a macro
clang -UFOO file.c
```

---

## Linking

```bash
# Link a library (e.g. libm, libpthread)
clang file.c -lm
clang file.c -lpthread
clang file.c -lm -lpthread

# Add a library search path
clang file.c -L/path/to/libs -lmylib

# Link a static library directly
clang file.c /path/to/libfoo.a

# Link as shared library
clang -shared -fPIC file.c -o libfoo.so

# Prevent linking the standard library
clang -nostdlib file.c

# Link with C++ standard library (when using clang for C++ object files)
clang file.o -lstdc++
# or just use clang++
clang++ file.o -o program
```

---

## Output Control

```bash
clang file.c -o program            # set output filename
clang -c file.c -o file.o          # object file with custom name
clang -S file.c -o file.asm        # assembly with custom name

# Emit LLVM IR (intermediate representation)
clang -emit-llvm -S file.c -o file.ll    # human-readable LLVM IR
clang -emit-llvm -c file.c -o file.bc    # LLVM bitcode (binary)

# Read and optimize LLVM IR
clang file.ll -o program
```

---

## Target Architecture

```bash
# Cross-compile for a different architecture
clang --target=aarch64-linux-gnu file.c
clang --target=x86_64-linux-gnu file.c
clang --target=wasm32-wasi file.c          # WebAssembly

# Tune for the current machine's CPU
clang -march=native file.c

# Specific CPU architectures
clang -march=x86-64 file.c
clang -march=armv8-a file.c

# Print the default target triple
clang -print-target-triple
```

---

## Useful Diagnostic Flags

```bash
# Show all include paths clang searches
clang -v file.c

# Print the full compilation command without running it
clang -### file.c

# Show preprocessed output
clang -E file.c

# Show dependency files (for Makefiles)
clang -M file.c
clang -MM file.c               # exclude system headers
clang -MD file.c               # write deps to .d file alongside .o

# Check syntax without generating output
clang --analyze file.c
clang -fsyntax-only file.c     # parse and type-check only, no codegen

# Show system include and library paths
clang -print-search-dirs
```

---

## Static Analysis

clang includes a built-in static analyzer:

```bash
# Run the static analyzer on a file
clang --analyze file.c

# More detailed: use scan-build wrapper (ships with clang)
scan-build make
scan-build clang file.c -o program

# View HTML report (scan-build generates it automatically)
scan-build -V clang file.c -o program
```

`scan-build` wraps your build command and intercepts all clang calls to run analysis, then generates an HTML report of findings.

---

## clang-format

`clang-format` auto-formats C/C++ source code.

```bash
# Format a file in-place
clang-format -i file.cpp

# Format and print to stdout (no modification)
clang-format file.cpp

# Use a specific style
clang-format -style=LLVM file.cpp
clang-format -style=Google file.cpp
clang-format -style=Mozilla file.cpp
clang-format -style=WebKit file.cpp
clang-format -style=Microsoft file.cpp
clang-format -style=GNU file.cpp

# Format a range of lines only
clang-format -lines=10:50 file.cpp

# Generate a .clang-format config file
clang-format -style=Google -dump-config > .clang-format
```

Once a `.clang-format` file exists in your project root, `clang-format` uses it automatically.

---

## clang-tidy

`clang-tidy` is a linter and static analysis tool that checks for bugs, style issues, and modernization opportunities.

```bash
# Run on a file
clang-tidy file.cpp

# Apply fixes automatically
clang-tidy file.cpp --fix

# Run specific checks
clang-tidy file.cpp -checks="modernize-*"
clang-tidy file.cpp -checks="bugprone-*,performance-*"
clang-tidy file.cpp -checks="-*,clang-analyzer-*"   # only analyzer checks

# List all available checks
clang-tidy --list-checks -checks="*"

# Use with a compile_commands.json
clang-tidy -p build/ file.cpp
```

### Common check categories

|Category|What it flags|
|---|---|
|`modernize-*`|Suggests modern C++ idioms (e.g. use `nullptr`, range-for, `auto`)|
|`bugprone-*`|Likely bugs (e.g. integer overflow, suspicious string usage)|
|`performance-*`|Unnecessary copies, inefficient constructs|
|`readability-*`|Code clarity issues|
|`clang-analyzer-*`|Deep static analysis (similar to `--analyze`)|
|`cppcoreguidelines-*`|C++ Core Guidelines conformance|
|`cert-*`|CERT coding standards|

---

## compile_commands.json

Many clang tools (clang-tidy, clangd, etc.) work best with a compilation database — a `compile_commands.json` file that records exactly how each file was compiled.

```bash
# Generate with CMake
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..

# Generate with Bear (wraps any build system)
bear -- make
bear -- clang file.c -o program

# Generate with ninja
ninja -C build -t compdb > compile_commands.json
```

Place or symlink `compile_commands.json` at the project root.

---

## clangd (Language Server)

`clangd` is the clang-based language server for editors (VS Code, Neovim, Emacs, etc.).

```bash
# Install
sudo apt install clangd
brew install llvm    # includes clangd on macOS

# Run manually (editors invoke it automatically)
clangd --help

# Check version
clangd --version
```

In VS Code, install the **clangd** extension (by LLVM). It uses `compile_commands.json` for accurate completions, go-to-definition, and diagnostics. Disable the Microsoft C/C++ IntelliSense engine when using clangd to avoid conflicts.

---

## Common Flag Reference

|Flag|Description|
|---|---|
|`-o <file>`|Output file name|
|`-c`|Compile to object file, no link|
|`-S`|Compile to assembly|
|`-E`|Preprocess only|
|`-g`|Debug symbols|
|`-O0` to `-O3`|Optimization levels|
|`-Wall`|Common warnings|
|`-Wextra`|Extra warnings|
|`-Werror`|Warnings as errors|
|`-std=<std>`|Language standard|
|`-I<dir>`|Add include path|
|`-L<dir>`|Add library path|
|`-l<name>`|Link a library|
|`-D<macro>`|Define preprocessor macro|
|`-U<macro>`|Undefine macro|
|`-march=<arch>`|Target CPU architecture|
|`--target=<triple>`|Cross-compilation target|
|`-fsanitize=<type>`|Enable a sanitizer|
|`-fPIC`|Position-independent code (for shared libs)|
|`-shared`|Build a shared library|
|`-nostdlib`|Don't link standard library|
|`-emit-llvm`|Emit LLVM IR|
|`-fsyntax-only`|Check syntax, no codegen|
|`-v`|Verbose output|
|`-###`|Print commands without running|
|`-pipe`|Use pipes instead of temp files|
|`-fno-exceptions`|Disable C++ exceptions|
|`-fno-rtti`|Disable C++ RTTI|
|`-flto`|Link-time optimization|

---

## Practical Tips

**Prefer `-O2` for release builds.** `-O3` can be faster but occasionally produces surprising behavior with floating point or strict aliasing. `-O2` is the safer default for most programs.

**Always use sanitizers during development.** Running with `-fsanitize=address,undefined` catches a large class of bugs at minimal inconvenience. Keep a debug build with sanitizers enabled alongside your release build.

**Use `-fsyntax-only` for fast feedback.** If you just want to know whether code compiles without generating output, `-fsyntax-only` skips codegen and is noticeably faster on large files.

**`-Weverything` is for discovery, not for keeping.** Run it once on a codebase to see what warnings exist, then selectively enable the ones that matter. Using it permanently produces too much noise to be useful.

**clangd + compile_commands.json is the best editor setup.** Generate `compile_commands.json` with CMake or Bear, point clangd at it, and you get accurate completions, real-time diagnostics, and go-to-definition across the whole project.

**`-flto` for link-time optimization.** Adding `-flto` at both compile and link time allows the optimizer to work across translation units. Can meaningfully improve performance of release builds.

```bash
# Full recommended debug build
clang -std=c17 -g -O0 -Wall -Wextra -fsanitize=address,undefined file.c -o program_debug

# Full recommended release build
clang -std=c17 -O2 -Wall -Wextra -DNDEBUG file.c -o program_release
```

> **[Inference]** Specific flag availability and behavior can vary between clang versions. Always check `clang --version` and consult `clang --help` or the LLVM documentation for your specific version when exact behavior matters.