## Linkers and Object File Formats


A linker combines one or more object files produced by assemblers or compilers into a single executable or library. The linker resolves symbol references, assigns final memory addresses, and generates the executable file.

### Object File Formats

Object files contain machine code, data, and metadata about symbols and relocations. Different operating systems use different formats.

### ELF (Executable and Linkable Format)

ELF is the standard object file format for Linux and most Unix-like systems.

**ELF File Types:**

- Relocatable files (.o): Object files that can be linked
- Executable files: Ready-to-run programs
- Shared object files (.so): Dynamic libraries
- Core dump files: Process memory snapshots

**ELF Structure:**

**ELF Header:** Contains metadata about the file including magic number, architecture, entry point, and offsets to other structures.

**Program Headers:** Describe segments for loading into memory (used in executables and shared libraries).

**Section Headers:** Describe sections used during linking (used in relocatable files).

**Common Sections:**

- .text: Executable code
- .data: Initialized data
- .bss: Uninitialized data (Block Started by Symbol)
- .rodata: Read-only data (constants, string literals)
- .symtab: Symbol table
- .strtab: String table
- .rel.text / .rela.text: Relocation information for code
- .rel.data / .rela.data: Relocation information for data

**Symbol Types:**

- STB_LOCAL: Local symbols (not visible outside object file)
- STB_GLOBAL: Global symbols (visible to other object files)
- STB_WEAK: Weak symbols (can be overridden)

**Example: Viewing ELF Information:**

```bash
# Display ELF header
readelf -h program

# Display section headers
readelf -S program

# Display symbol table
readelf -s program

# Display program headers
readelf -l program

# Disassemble sections
objdump -d program

# Display all headers
objdump -x program
```

### PE (Portable Executable)

PE is the executable format for Windows operating systems, used for .exe, .dll, .sys files.

**PE Structure:**

**DOS Header:** Legacy header starting with "MZ" signature for backward compatibility.

**PE Header:** Contains signature "PE\0\0" followed by COFF header.

**COFF Header:** Contains machine type, number of sections, timestamp, symbol table pointer.

**Optional Header:** Contains information about memory layout, entry point, image base address, section alignment.

**Section Headers:** Describe sections in the file.

**Common Sections:**

- .text: Executable code
- .data: Initialized data
- .rdata: Read-only data
- .bss: Uninitialized data
- .idata: Import table (imported functions)
- .edata: Export table (exported functions)
- .reloc: Relocation information
- .rsrc: Resources (icons, strings, dialogs)

**Import Address Table (IAT):** Contains addresses of imported functions from DLLs. The Windows loader fills this table when the program loads.

**Export Directory:** Lists functions and data that a DLL makes available to other modules.

**Example: Viewing PE Information:**

```bash
# Using dumpbin (Visual Studio tool)
dumpbin /headers program.exe
dumpbin /imports program.exe
dumpbin /exports library.dll
dumpbin /disasm program.exe

# Using objdump (MinGW)
objdump -x program.exe
objdump -d program.exe
```

### Mach-O (Mach Object)

Mach-O is the object file format used by macOS, iOS, and other Apple operating systems.

**Mach-O Structure:**

**Header:** Contains magic number, CPU type, file type, number of load commands.

**Load Commands:** Describe memory layout, symbol tables, dynamic linking information.

**Data:** Contains actual code and data segments.

**Common Segments:**

- __TEXT: Read-only executable code and data
- __DATA: Writable data
- __LINKEDIT: Linking and debugging information

**Example: Viewing Mach-O Information:**

```bash
# Display header and load commands
otool -h program
otool -l program

# Display symbol table
nm program

# Disassemble
otool -tV program
```

### COFF (Common Object File Format)

COFF is an older format that influenced both ELF and PE. It's still used in Windows object files (.obj).

**COFF Structure:**

- File header
- Optional header (for executables)
- Section headers
- Sections (code and data)
- Symbol table
- String table

### Linkers

### GNU ld (GNU Linker)

The standard linker for Linux and Unix-like systems, part of GNU Binutils.

**Basic Usage:**

```bash
# Link single object file
ld program.o -o program

# Link multiple object files
ld file1.o file2.o file3.o -o program

# 32-bit linking on 64-bit system
ld -m elf_i386 program.o -o program

# Specify entry point
ld -e main program.o -o program

# Link with dynamic libraries
ld program.o -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o program

# Static linking
ld program.o -static -o program
```

**Linker Script:** A text file that controls the linking process, specifying memory layout and section placement.

**Example Linker Script:**

```ld
ENTRY(_start)

SECTIONS
{
    . = 0x400000;
    
    .text : {
        *(.text)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}
```

**Using Linker Script:**

```bash
ld -T script.ld program.o -o program
```

**Common Linker Options:**

- -o: Specify output file name
- -L: Add directory to library search path
- -l: Link with library (e.g., -lm for libm)
- -static: Create statically linked executable
- -shared: Create shared library
- -Map: Generate map file showing memory layout
- -T: Use custom linker script

### Microsoft LINK

Microsoft's linker for Windows, included with Visual Studio.

**Basic Usage:**

```cmd
REM Link object file
link program.obj

REM Link multiple files
link file1.obj file2.obj file3.obj

REM Specify subsystem
link /subsystem:console program.obj
link /subsystem:windows program.obj

REM Link with libraries
link program.obj kernel32.lib user32.lib

REM Create DLL
link /dll library.obj /out:library.dll

REM Generate map file
link /map program.obj
```

**Common Linker Options:**

- /OUT: Specify output file name
- /SUBSYSTEM: Specify subsystem (console, windows)
- /ENTRY: Specify entry point
- /LIBPATH: Add library search path
- /DLL: Create dynamic link library
- /DEBUG: Generate debugging information
- /MAP: Generate map file

### Gold Linker

A faster alternative to GNU ld, designed for improved performance with large projects.

**Usage:**

```bash
# Use gold instead of ld
ld.gold program.o -o program

# Or configure as default
gcc -fuse-ld=gold program.c -o program
```

### LLD (LLVM Linker)

Modern linker from the LLVM project, designed for speed and compatibility.

**Usage:**

```bash
# Link with LLD
ld.lld program.o -o program

# Use with Clang
clang -fuse-ld=lld program.c -o program
```

### Linking Process

**Symbol Resolution:** The linker matches undefined symbol references with symbol definitions. If a symbol is referenced but not defined anywhere, the linker reports an error.

**Relocation:** The linker adjusts addresses in the code and data to reflect their final positions in memory. Object files contain relocation entries that specify where and how to modify addresses.

**Example: Undefined Reference Error:**

```
undefined reference to `my_function'
```

This occurs when a function is called but never defined or linked.

**Static Linking:** All library code is copied into the final executable. The executable is self-contained but larger.

**Dynamic Linking:** The executable contains references to shared libraries, which are loaded at runtime. The executable is smaller, and multiple programs can share the same library code in memory.

**Position Independent Code (PIC):** Code compiled to work correctly regardless of its absolute address in memory. Required for shared libraries.

**Global Offset Table (GOT):** A table of addresses used for accessing global data in position-independent code.

**Procedure Linkage Table (PLT):** A table used for calling functions in shared libraries. The first call resolves the actual function address through dynamic linking (lazy binding).

