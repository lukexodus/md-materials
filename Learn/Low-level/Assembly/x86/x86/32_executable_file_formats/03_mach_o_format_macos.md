## Mach-O Format (macOS)


Mach-O (Mach Object) is the native executable format for macOS, iOS, and other Apple operating systems. It evolved from the Mach microkernel and supports multi-architecture binaries (universal/fat binaries).

### Mach-O File Structure

**Mach-O Header**: The file begins with a header structure (mach_header_64 for 64-bit) containing:

**magic**: Magic number identifying the file:

- 0xFEEDFACE (MH_MAGIC): 32-bit Mach-O
- 0xFEEDFACF (MH_MAGIC_64): 64-bit Mach-O
- 0xCAFEBABE (FAT_MAGIC): Universal binary (big-endian)
- 0xBEBAFECA (FAT_MAGIC): Universal binary (little-endian)
- 0xCAFEBABF (FAT_MAGIC_64): 64-bit universal binary

**cputype**: CPU architecture (CPU_TYPE_X86 = 7, CPU_TYPE_X86_64 = 0x01000007, CPU_TYPE_ARM = 12, CPU_TYPE_ARM64 = 0x0100000C)

**cpusubtype**: CPU variant (e.g., CPU_SUBTYPE_X86_64_ALL, CPU_SUBTYPE_ARM64_ALL)

**filetype**: Type of Mach-O file:

- MH_OBJECT (1): Relocatable object file
- MH_EXECUTE (2): Executable
- MH_DYLIB (6): Dynamic library
- MH_BUNDLE (8): Bundle/plugin
- MH_DYLINKER (7): Dynamic linker
- MH_CORE (4): Core dump
- MH_DSYM (10): Debug symbols

**ncmds**: Number of load commands following the header

**sizeofcmds**: Total size of load commands in bytes

**flags**: Various flags:

- MH_NOUNDEFS: No undefined references
- MH_PIE: Position-independent executable
- MH_DYLDLINK: Dynamic linking
- MH_TWOLEVEL: Two-level namespace binding
- MH_ALLOW_STACK_EXECUTION: Stack is executable
- MH_NO_HEAP_EXECUTION: Heap is not executable

**reserved**: Reserved field (64-bit only)

### Load Commands

Following the header is a sequence of load commands that describe the file's structure and loading requirements. Each load command begins with:

**cmd**: Command type identifier

**cmdsize**: Size of command including command-specific data

Common load command types:

**LC_SEGMENT_64 / LC_SEGMENT**: Defines a memory segment to be mapped. Contains:

- segname: Segment name (e.g., "__TEXT", "__DATA", "__LINKEDIT")
- vmaddr: Virtual memory address
- vmsize: Size in memory
- fileoff: File offset
- filesize: Size in file
- maxprot: Maximum protection (read/write/execute)
- initprot: Initial protection
- nsects: Number of sections in segment
- flags: Segment flags

Each segment contains zero or more sections described by section structures.

**LC_SYMTAB**: Symbol table location:

- symoff: File offset to symbol table
- nsyms: Number of symbol entries
- stroff: File offset to string table
- strsize: Size of string table

**LC_DYSYMTAB**: Dynamic symbol table information for dynamic linking:

- Indices for local, external, and undefined symbols
- Indirect symbol table offset
- Relocation entries for dynamic linker

**LC_LOAD_DYLIB**: Specifies a required dynamic library:

- dylib name (path)
- timestamp
- current version
- compatibility version

**LC_ID_DYLIB**: Identification of a dynamic library (used in .dylib files)

**LC_LOAD_DYLINKER**: Path to dynamic linker:

- Usually /usr/lib/dyld

**LC_MAIN**: Entry point for modern executables:

- entryoff: File offset to entry point
- stacksize: Initial stack size

**LC_UNIXTHREAD**: Entry point for older executables (deprecated):

- Thread state including initial register values

**LC_UUID**: Unique identifier for matching debug symbols:

- 16-byte UUID

**LC_CODE_SIGNATURE**: Code signing information offset

**LC_SEGMENT_SPLIT_INFO**: Information for splitting segments

**LC_FUNCTION_STARTS**: Table of function start addresses for debugging

**LC_DATA_IN_CODE**: Data regions within code sections

**LC_DYLD_INFO / LC_DYLD_INFO_ONLY**: Compressed dynamic linking information:

- Rebase info (adjusting internal pointers)
- Binding info (resolving external references)
- Weak binding info
- Lazy binding info
- Export info

**LC_SOURCE_VERSION**: Source code version

**LC_ENCRYPTION_INFO_64**: Encryption information for App Store binaries

### Segments and Sections

Mach-O organizes data into segments, which contain sections. Segments are page-aligned for memory mapping.

**__TEXT Segment**: Contains read-only executable code and data:

- __text: Executable machine code
- __stubs: Stub code for calling imported functions
- __stub_helper: Helper code for lazy symbol binding
- __cstring: C string literals (null-terminated)
- __const: Constant data
- __objc_methname: Objective-C method names
- __objc_classname: Objective-C class names
- __objc_methtype: Objective-C method types
- __unwind_info: Stack unwinding information

**__DATA Segment**: Contains writable data:

- __data: Initialized mutable data
- __bss: Uninitialized data (zeroed at load)
- __common: Uninitialized common symbols
- __const: Initialized constant data that may require relocation
- __dyld: Data used by dynamic linker
- __la_symbol_ptr: Lazy symbol pointers (filled in on first use)
- __nl_symbol_ptr: Non-lazy symbol pointers (filled in at load)
- __objc_classlist: List of Objective-C classes
- __objc_protolist: List of Objective-C protocols
- __objc_imageinfo: Objective-C image information
- __objc_const: Objective-C constant data
- __objc_selrefs: Objective-C selector references
- __objc_classrefs: Objective-C class references
- __objc_data: Objective-C mutable data

**__LINKEDIT Segment**: Contains data for dynamic linker:

- Symbol table
- String table
- Code signature
- Relocation entries
- Function starts
- Data-in-code entries

**__PAGEZERO Segment**: Empty segment at address 0 (several GB) to catch NULL pointer dereferences. Not loaded into memory but reserves virtual address space.

### Section Structures

Each section within a segment has a section_64 structure:

**sectname**: Section name (e.g., "__text", "__data")

**segname**: Segment name this section belongs to

**addr**: Virtual memory address

**size**: Size in bytes

**offset**: File offset to section data

**align**: Alignment as power of 2

**reloff**: File offset to relocation entries

**nreloc**: Number of relocation entries

**flags**: Section type and attributes:

- S_REGULAR: Regular section
- S_ZEROFILL: Zero-filled on demand (.bss)
- S_CSTRING_LITERALS: C string literals
- S_4BYTE_LITERALS: 4-byte literals
- S_8BYTE_LITERALS: 8-byte literals
- S_LITERAL_POINTERS: Pointers to literals
- S_NON_LAZY_SYMBOL_POINTERS: Non-lazy symbol pointers
- S_LAZY_SYMBOL_POINTERS: Lazy symbol pointers
- S_SYMBOL_STUBS: Symbol stubs
- S_MOD_INIT_FUNC_POINTERS: Module initialization function pointers
- S_MOD_TERM_FUNC_POINTERS: Module termination function pointers

### Symbol Table

The symbol table contains nlist_64 structures:

**n_strx**: Index into string table for symbol name

**n_type**: Symbol type and attributes:

- N_UNDF (0x0): Undefined symbol
- N_ABS (0x2): Absolute symbol
- N_SECT (0xe): Defined in a section
- N_EXT (0x1): External symbol
- N_PEXT (0x10): Private external symbol

**n_sect**: Section number (1-based) where symbol is defined

**n_desc**: Symbol descriptor flags

**n_value**: Symbol value (address for defined symbols)

### Dynamic Linking

**dyld**: The dynamic linker (/usr/lib/dyld) loads shared libraries at runtime. It processes the load commands, maps segments, resolves symbols, and performs relocations.

**Two-Level Namespace**: Mach-O uses a two-level namespace where symbols are qualified by both name and library. This prevents symbol conflicts between libraries. [Inference] When linking, the linker records not just the symbol name but also which library provides it.

**Lazy Binding**: Functions from dynamic libraries are resolved on first use through stub functions in __stubs section and lazy symbol pointers in __la_symbol_ptr section:

[Inference] First call to an imported function jumps to a stub, which jumps through a lazy symbol pointer (initially points to stub helper), which calls dyld to resolve the symbol and updates the pointer. Subsequent calls jump directly to the resolved function.

**Non-Lazy Binding**: Global variables and some functions use non-lazy binding, resolved immediately at load time through __nl_symbol_ptr section.

**Rebase and Binding**: Modern Mach-O uses compressed rebase and binding information (LC_DYLD_INFO) instead of traditional relocations:

- Rebase: Adjusts internal pointers when loaded at non-preferred address
- Bind: Resolves external symbols from other libraries

### Universal Binaries

Universal (fat) binaries contain multiple architectures in a single file:

**Fat Header**: Begins with FAT_MAGIC (0xCAFEBABE) followed by the number of architectures

**Fat Arch Structures**: One per architecture, containing:

- cputype and cpusubtype
- offset: File offset to architecture's Mach-O header
- size: Size of architecture's Mach-O
- align: Alignment as power of 2

**Architecture Data**: Each architecture's complete Mach-O file at its specified offset

[Inference] The loader selects the appropriate architecture based on the CPU and loads only that portion of the file.

### Code Signing

macOS requires code signing for many scenarios. The LC_CODE_SIGNATURE command points to:

**CodeDirectory**: Hash tree of all pages in the binary

**Requirements**: Conditions that must be met for code to run

**Entitlements**: Permissions the code requests

**Signature**: Cryptographic signature over the above

[Inference] The kernel verifies the signature before loading and can validate individual pages on demand, preventing code injection and tampering.

### Mach-O Tools and Analysis

**otool**: Object file displaying tool:

- `otool -h file` displays Mach-O header
- `otool -l file` displays load commands
- `otool -L file` displays shared library dependencies
- `otool -t file` displays __text section
- `otool -d file` displays __data section
- `otool -s segname sectname file` displays specific section

**nm**: Symbol table display (same as on Linux)

**lipo**: Manipulates universal binaries:

- `lipo -info file` shows architectures
- `lipo -thin x86_64 file -output output` extracts one architecture
- `lipo -create file1 file2 -output universal` creates universal binary

**codesign**: Code signing utility:

- `codesign -s identity file` signs a binary
- `codesign -v file` verifies signature
- `codesign -d --entitlements - file` displays entitlements

**install_name_tool**: Modifies dynamic library install names and paths

**dyldinfo**: Displays dynamic linking information:

- `dyldinfo -bind file` shows binding information
- `dyldinfo -lazy_bind file` shows lazy binding
- `dyldinfo -export file` shows exported symbols

**MachOView**: GUI tool for exploring Mach-O structure visually

**Hopper / IDA Pro**: Disassemblers with excellent Mach-O support

### Mach-O Example Structure

```
[Mach-O Header]
    [magic - 0xFEEDFACF]
    [cputype - CPU_TYPE_X86_64]
    [cpusubtype]
    [filetype - MH_EXECUTE]
    [ncmds, sizeofcmds]
    [flags - MH_PIE, MH_TWOLEVEL, etc.]
    [Load Commands]
    [LC_SEGMENT_64 - __PAGEZERO] 
    vmaddr: 0x0 vmsize: 0x100000000 (4GB)

[LC_SEGMENT_64 - __TEXT]
    vmaddr: 0x100000000
    vmsize: ...
    sections:
        [__text - executable code]
        [__stubs - import stubs]
        [__stub_helper - stub helper code]
        [__cstring - C strings]
        [__const - constants]

[LC_SEGMENT_64 - __DATA]
    vmaddr: ...
    vmsize: ...
    sections:
        [__data - initialized data]
        [__bss - uninitialized data]
        [__la_symbol_ptr - lazy pointers]
        [__nl_symbol_ptr - non-lazy pointers]

[LC_SEGMENT_64 - __LINKEDIT]
    [symbol table data]
    [string table data]
    [code signature]

[LC_DYLD_INFO_ONLY]
    [rebase_off, rebase_size]
    [bind_off, bind_size]
    [weak_bind_off, weak_bind_size]
    [lazy_bind_off, lazy_bind_size]
    [export_off, export_size]

[LC_SYMTAB]
    [symoff, nsyms]
    [stroff, strsize]

[LC_DYSYMTAB]
    [dynamic symbol info]

[LC_LOAD_DYLINKER]
    name: /usr/lib/dyld

[LC_UUID]
    uuid: [16-byte identifier]

[LC_LOAD_DYLIB - /usr/lib/libSystem.B.dylib]
[LC_LOAD_DYLIB - other dependencies...]

[LC_MAIN]
    entryoff: offset to main()
    stacksize: initial stack size

[LC_CODE_SIGNATURE]
    dataoff: offset to signature
    datasize: signature size
```

[Segment Data] [__TEXT segment data] [__text section - machine code] [__stubs section - import stubs] [other __TEXT sections...]

```
[__DATA segment data]
    [__data section - initialized variables]
    [__bss section - zero-filled space]
    [other __DATA sections...]

[__LINKEDIT segment data]
    [Symbol table entries]
    [String table]
    [Rebase information (compressed)]
    [Binding information (compressed)]
    [Lazy binding information]
    [Export information]
    [Code signature blob]
```

````

## Sections and Segments

Understanding the distinction between sections and segments is crucial for working with executable formats. While terminology varies between formats, the concepts are similar.

### Sections vs Segments

**Sections**: Logical groupings of code and data with specific purposes. Sections are the linker's view of the binary. They organize content by purpose: code, initialized data, uninitialized data, debug information, etc. [Inference] Sections provide fine-grained control during compilation and linking but may not directly correspond to memory layout.

**Segments**: Physical groupings for loading into memory. Segments are the loader's view of the binary. They combine related sections with similar memory protection requirements and are page-aligned for efficient memory mapping. [Inference] Segments optimize runtime behavior by grouping sections that need similar access permissions.

### Section Properties

**Name**: Identifies the section's purpose. Conventions vary by format (PE uses arbitrary names like .text, ELF uses names starting with ., Mach-O uses double underscore prefix like __text).

**Type**: Specifies the section's content type (code, data, symbols, relocations, etc.)

**Flags/Attributes**: Define properties:
- Memory permissions (read, write, execute)
- Load behavior (loaded into memory or metadata only)
- Content characteristics (contains code, initialized data, zero-filled)
- Linking behavior (mergeable, discardable, shared)

**Virtual Address/Size**: Where the section appears in virtual memory and its size in memory

**File Offset/Size**: Where the section appears in the file and its size on disk. [Inference] For zero-filled sections (.bss), file size is often zero while virtual size is non-zero.

**Alignment**: Memory alignment requirement, typically powers of 2 (4, 8, 16, 4096 bytes)

**Relocations**: Information about addresses that need adjustment during linking or loading

**Line Numbers**: Debugging information mapping code to source lines (mostly obsolete, replaced by DWARF/PDB)

### Segment Properties

**Type**: Identifies the segment's purpose (loadable code/data, dynamic information, interpreter path, etc.)

**Permissions**: Memory protection flags (read, write, execute combinations)

**Virtual Address/Size**: Where mapped in virtual memory and memory size

**File Offset/Size**: Location and size in the file

**Alignment**: Page alignment (typically 4KB = 4096 bytes on x86, 16KB on ARM64)

**Relationship to Sections**: Which sections are contained within the segment

### Common Section Types Across Formats

**Code Sections**:
- PE: .text
- ELF: .text, .init, .fini
- Mach-O: __TEXT,__text
- Characteristics: Read-only, executable, contains machine instructions

**Read-Only Data**:
- PE: .rdata
- ELF: .rodata
- Mach-O: __TEXT,__const, __TEXT,__cstring
- Characteristics: Read-only, non-executable, contains constants and strings

**Initialized Data**:
- PE: .data
- ELF: .data
- Mach-O: __DATA,__data
- Characteristics: Read-write, non-executable, contains initialized global/static variables

**Uninitialized Data**:
- PE: .bss
- ELF: .bss
- Mach-O: __DATA,__bss
- Characteristics: Read-write, non-executable, zero-filled at load, occupies no/minimal file space

**Import Information**:
- PE: .idata (or merged into .rdata)
- ELF: .dynsym, .dynstr, .plt, .got
- Mach-O: __DATA,__la_symbol_ptr, __DATA,__nl_symbol_ptr
- Characteristics: Dynamic linking tables, function/variable references

**Export Information**:
- PE: .edata (or merged into .rdata)
- ELF: .dynsym
- Mach-O: Part of LC_DYLD_INFO
- Characteristics: Symbols available to other modules

**Relocation Information**:
- PE: .reloc
- ELF: .rela.text, .rela.data, etc.
- Mach-O: Part of LC_DYLD_INFO or __LINKEDIT
- Characteristics: Address fixup information

**Debug Information**:
- PE: .debug_* sections (DWARF) or separate PDB file
- ELF: .debug_*, .stab, .stabstr
- Mach-O: Separate .dSYM bundle with DWARF data
- Characteristics: Source mapping, variable types, function signatures

**Symbol Tables**:
- PE: COFF symbol table (usually stripped)
- ELF: .symtab, .strtab
- Mach-O: LC_SYMTAB data in __LINKEDIT
- Characteristics: Function and variable names, addresses, types

**Resources** (PE-specific):
- PE: .rsrc
- Contains icons, dialogs, strings, version info, manifests
- Organized in hierarchical tree structure

**Thread-Local Storage**:
- PE: .tls
- ELF: .tdata, .tbss
- Mach-O: __DATA,__thread_data, __DATA,__thread_bss
- Characteristics: Per-thread variables, initialized from template

**Exception Handling**:
- PE: .pdata (x64), .xdata (x64)
- ELF: .eh_frame, .eh_frame_hdr
- Mach-O: __TEXT,__unwind_info
- Characteristics: Stack unwinding information

### Segment Types Across Formats

**Loadable Code Segment**:
- PE: Implicit from section flags
- ELF: PT_LOAD with execute permission
- Mach-O: __TEXT
- Contains: .text, .rodata, and similar sections
- Permissions: Read + Execute

**Loadable Data Segment**:
- PE: Implicit from section flags
- ELF: PT_LOAD without execute permission
- Mach-O: __DATA
- Contains: .data, .bss, and similar sections
- Permissions: Read + Write

**Dynamic Linking Segment**:
- PE: No explicit segment
- ELF: PT_DYNAMIC
- Mach-O: LC_DYLD_INFO, LC_LOAD_DYLIB commands
- Contains: Dynamic linking tables and metadata

**Interpreter Segment**:
- PE: N/A
- ELF: PT_INTERP
- Mach-O: LC_LOAD_DYLINKER
- Contains: Path to dynamic linker

**Program Headers Segment**:
- PE: N/A
- ELF: PT_PHDR
- Mach-O: N/A
- Contains: The program header table itself

**Note Segment**:
- PE: N/A
- ELF: PT_NOTE
- Mach-O: N/A
- Contains: Auxiliary information, build IDs

**Stack Segment**:
- PE: Stack defined by optional header
- ELF: PT_GNU_STACK (permissions only)
- Mach-O: Stack defined by LC_MAIN
- Defines: Stack permissions and size

**Read-Only After Relocation**:
- PE: N/A (use section flags)
- ELF: PT_GNU_RELRO
- Mach-O: Implicit behavior
- Purpose: Security hardening, GOT protection

**Null Pointer Protection**:
- PE: N/A (OS-level protection)
- ELF: First PT_LOAD typically above address 0
- Mach-O: __PAGEZERO segment (multi-GB at address 0)
- Purpose: Catch NULL pointer dereferences

### Section/Segment Alignment

**File Alignment**: Sections are aligned to specific boundaries in the file for efficient I/O:
- PE: Typically 512 bytes (FileAlignment in optional header)
- ELF: Often 1 or 16 bytes for sections
- Mach-O: Varies by section, often 4 or 16 bytes

**Memory Alignment**: Segments must be page-aligned for memory mapping:
- x86/x86-64: 4KB (4096 bytes) pages
- ARM64: 16KB pages (iOS/macOS), 4KB or 64KB on other systems
- PE: SectionAlignment in optional header (typically 4KB)
- ELF: p_align field in program header (typically 4KB or 64KB)
- Mach-O: Implicit page alignment for segments

[Inference] Page alignment enables the OS to map file contents directly into memory using memory-mapped I/O, improving loading performance and enabling shared libraries to share physical memory between processes.

### Zero-Filled Sections

The .bss section (Block Started by Symbol) contains uninitialized global and static variables. [Inference] To save file space, the .bss section occupies minimal or zero bytes in the file but reserves space in memory:

**PE**: .bss has VirtualSize > SizeOfRawData, with SizeOfRawData often zero

**ELF**: .bss has sh_type = SHT_NOBITS, sh_size indicates memory size, no file offset

**Mach-O**: __DATA,__bss has S_ZEROFILL flag, size indicates memory size

[Inference] The loader allocates memory for .bss and zeroes it, meeting C/C++ standards that require static/global variables to be zero-initialized.

### Section Merging and Splitting

**Merging**: Linkers may combine sections:
- PE: .idata and .edata often merged into .rdata
- ELF: Similar sections can be merged with SHF_MERGE flag
- Mach-O: Multiple __TEXT sections combined in __TEXT segment

**Splitting**: Large sections may be split:
- Code split across multiple .text sections for incremental linking
- Data split for different access patterns or memory regions
- Debug information in separate files (PDB, .dSYM)

### Position-Independent Code Considerations

**PIC Sections**: Position-independent executables and shared libraries require special sections:

**GOT (Global Offset Table)**:
- ELF: .got, .got.plt sections
- Mach-O: __DATA,__got section
- Purpose: Indirect access to global variables
- [Inference] GOT entries are fixed up at load time with actual addresses

**PLT (Procedure Linkage Table)**:
- ELF: .plt section
- Mach-O: __TEXT,__stubs, __TEXT,__stub_helper
- Purpose: Indirect calls to external functions
- [Inference] Enables lazy binding where functions are resolved on first call

**Relocations for PIC**:
- Relative relocations adjust addresses based on load address
- Symbol relocations resolve external references
- [Inference] PIC reduces relocations by using PC-relative addressing and GOT/PLT indirection

### Security-Related Sections

**Stack Cookies/Canaries**: Compilers insert guard values on the stack:
- Data stored in read-only section
- [Inference] Checked before function return to detect buffer overflows

**SafeSEH** (PE, x86 only):
- .sxdata section contains registered exception handlers
- [Inference] Prevents exploitation via fake exception handlers

**Control Flow Guard** (PE):
- .gfids section lists valid indirect call targets
- [Inference] Runtime checks prevent calls to invalid addresses

**Relocation Sections**:
- Required for ASLR (Address Space Layout Randomization)
- PE: .reloc section
- ELF: .rela.* sections
- Mach-O: Rebase info in LC_DYLD_INFO

### Debugging Sections

**DWARF Debug Information** (ELF, Mach-O):
- .debug_info: Core debugging data
- .debug_abbrev: Abbreviation tables
- .debug_line: Line number information
- .debug_str: String table
- .debug_aranges: Address ranges
- .debug_frame: Call frame information
- .debug_loc: Location lists
- [Inference] Can be stripped to reduce binary size, moved to separate file

**PDB Files** (PE):
- Separate database file containing debug information
- Not embedded in executable
- Contains symbols, types, source mapping
- [Inference] Allows debugging without bloating distribution binaries

**Symbol Tables for Debugging**:
- ELF: .symtab (can be stripped)
- Mach-O: LC_SYMTAB data
- Contains function names, local variables, types
- [Inference] Stripping removes these but breaks debugging

### Special Purpose Sections

**Constructors/Destructors**:
- PE: .CRT$XCU, .CRT$XTU
- ELF: .init_array, .fini_array, .ctors, .dtors
- Mach-O: __DATA,__mod_init_func, __DATA,__mod_term_func
- Purpose: Functions called before main() and after main() returns
- Used for C++ global object construction/destruction

**Version Information**:
- PE: .rsrc contains VS_VERSION_INFO
- ELF: .gnu.version*, .note.ABI-tag
- Mach-O: LC_SOURCE_VERSION, LC_VERSION_MIN_*
- Purpose: Track binary versions, ABI compatibility

**Build Identification**:
- ELF: .note.gnu.build-id (cryptographic hash)
- Mach-O: LC_UUID (16-byte UUID)
- Purpose: Unique identifier for matching debug symbols

**Comments and Metadata**:
- PE: .comment (rarely used)
- ELF: .comment (compiler info), .note sections
- Mach-O: .comment (rarely used)
- Purpose: Store compiler version, build information

### Viewing Section/Segment Information

**Windows (PE)**:
```bash
