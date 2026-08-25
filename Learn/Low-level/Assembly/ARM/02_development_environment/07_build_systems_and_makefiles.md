## Build Systems and Makefiles


### Traditional Make

GNU Make uses makefiles to automate the build process by defining rules for transforming source files into targets. Makefiles specify dependencies between files and shell commands to execute when targets are out of date.

**Makefile Structure**

A makefile consists of variables, rules, and directives. Variables store values like compiler names, flags, and file lists. Rules define targets, prerequisites, and recipes (commands to execute). Pattern rules use wildcards to handle multiple files with similar transformations.

**Variables and Flags**

Common makefile variables include `CC` (compiler), `AS` (assembler), `LD` (linker), `CFLAGS` (compiler flags), `ASFLAGS` (assembler flags), and `LDFLAGS` (linker flags). For ARM cross-compilation, these typically reference cross-toolchain executables with appropriate architecture flags.

**Automatic Variables**

Make provides automatic variables that represent parts of the current rule: `$@` is the target filename, `$<` is the first prerequisite, `$^` is all prerequisites, and `$*` is the stem of a pattern rule match. These reduce repetition in recipes.

**Phony Targets**

Phony targets are not actual files but represent commands to execute, marked with `.PHONY` directive. Common phony targets include `all` (default build), `clean` (remove generated files), `install` (copy files to destination), and `debug` (build with debug symbols).

### CMake for ARM Projects

CMake is a cross-platform build system generator that produces makefiles, ninja files, or IDE project files from high-level configuration. For ARM cross-compilation, CMake uses toolchain files that specify the cross-compiler, target architecture, and sysroot location.

**Toolchain Files**

A CMake toolchain file sets variables like `CMAKE_SYSTEM_NAME`, `CMAKE_SYSTEM_PROCESSOR`, `CMAKE_C_COMPILER`, `CMAKE_CXX_COMPILER`, and `CMAKE_FIND_ROOT_PATH`. This file is passed to cmake with `-DCMAKE_TOOLCHAIN_FILE` option to configure cross-compilation.

**Architecture-Specific Flags**

CMakeLists.txt files can conditionally add ARM-specific compiler flags, select assembly source files, and configure target properties based on the processor architecture detected from the toolchain file.

### Build Automation

Modern build systems support parallel compilation, incremental builds, dependency tracking, and out-of-source builds. Parallel compilation with `make -j` utilizes multiple CPU cores. Out-of-source builds separate build artifacts from source code, enabling multiple configurations from the same source tree.

