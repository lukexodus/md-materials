## Cross-Compilation Basics


### Toolchain Components

A cross-compilation toolchain consists of compilers, assemblers, linkers, and binary utilities that run on a host architecture but produce code for a target ARM architecture. The GNU toolchain (binutils, GCC, GDB) is the most common open-source option for ARM development.

**Compiler (arm-none-eabi-gcc / arm-linux-gnueabi-gcc)**

The cross-compiler translates C/C++ code into ARM assembly and machine code. Different toolchain prefixes target different environments: `arm-none-eabi-` for bare-metal (no operating system), `arm-linux-gnueabi-` for ARM Linux with soft-float ABI, and `arm-linux-gnueabihf-` for ARM Linux with hard-float ABI.

**Assembler (as)**

The GNU assembler converts ARM assembly source code into object files containing machine code and relocation information. It supports multiple syntax styles including GNU syntax and UAL (Unified Assembler Language).

**Linker (ld)**

The linker combines multiple object files into a single executable or library, resolves symbol references, and arranges code and data according to linker scripts. For bare-metal development, custom linker scripts define memory layout, section placement, and entry points.

**Binary Utilities (objcopy, objdump, nm, size)**

Binary utilities analyze and manipulate object files and executables. `objcopy` extracts raw binary images from ELF files, `objdump` disassembles code and displays section information, `nm` lists symbols, and `size` reports section sizes.

### Target Specifications

Cross-compilation requires specifying the target architecture, processor variant, ABI (Application Binary Interface), and floating-point configuration. Architecture flags like `-march=armv7-a` define instruction set availability, while `-mcpu=cortex-a9` optimizes for specific processors. The `-mfpu` flag selects floating-point hardware (VFPv3, NEON), and `-mfloat-abi` chooses soft, softfp, or hard float calling conventions.

### Sysroot Configuration

For Linux userspace development, the cross-compiler needs access to target architecture headers and libraries through a sysroot. The sysroot is a directory tree containing ARM versions of system libraries and headers, specified with `--sysroot` compiler flag or configured during toolchain build.

### Installation Methods

Cross-compilation toolchains can be installed through package managers (apt, yum, pacman), downloaded as pre-built packages from ARM or Linaro, or built from source using tools like crosstool-ng or buildroot. Package manager installation is simplest but may provide older versions, while building from source offers customization but requires more time and expertise.

