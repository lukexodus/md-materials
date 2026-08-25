## ELF Format (Linux/Unix)


The Executable and Linkable Format (ELF) is the standard binary format for Linux, BSD, Solaris, and most Unix-like systems. It is used for executables, shared libraries (.so), object files (.o), and core dumps.

### ELF File Structure

**ELF Header**: Every ELF file begins with a 52-byte (32-bit) or 64-byte (64-bit) header starting with the magic number 0x7F followed by "ELF" (0x7F 0x45 0x4C 0x46). The header contains:

**e_ident**: 16-byte identification array containing:

- Magic number (bytes 0-3): 0x7F, 'E', 'L', 'F'
- Class (byte 4): 1 for 32-bit, 2 for 64-bit
- Data encoding (byte 5): 1 for little-endian, 2 for big-endian
- Version (byte 6): 1 for current version
- OS/ABI (byte 7): 0 for System V, 3 for Linux, others for BSD variants
- ABI version (byte 8)
- Padding (bytes 9-15): reserved for future use

**e_type**: Object file type (1 = relocatable, 2 = executable, 3 = shared object, 4 = core dump)

**e_machine**: Target architecture (3 = x86, 62 = x86-64, 40 = ARM, 183 = AArch64)

**e_version**: Object file version (always 1)

**e_entry**: Virtual address of the entry point (first instruction to execute)

**e_phoff**: File offset to program header table

**e_shoff**: File offset to section header table

**e_flags**: Processor-specific flags

**e_ehsize**: Size of ELF header

**e_phentsize**: Size of one program header entry

**e_phnum**: Number of program header entries

**e_shentsize**: Size of one section header entry

**e_shnum**: Number of section header entries

**e_shstrndx**: Section header table index of the section name string table

### Program Headers (Segments)

Program headers describe segments for loading. The loader uses these to map file contents to memory. Each program header (Elf64_Phdr) contains:

**p_type**: Segment type:

- PT_NULL (0): Unused entry
- PT_LOAD (1): Loadable segment
- PT_DYNAMIC (2): Dynamic linking information
- PT_INTERP (3): Path to interpreter (dynamic linker)
- PT_NOTE (4): Auxiliary information
- PT_PHDR (7): Program header table itself
- PT_TLS (7): Thread-Local Storage template
- PT_GNU_STACK: Stack executability flags
- PT_GNU_RELRO: Read-only after relocation

**p_flags**: Segment permissions (read=4, write=2, execute=1, combined with OR)

**p_offset**: File offset where segment begins

**p_vaddr**: Virtual address where segment should be loaded

**p_paddr**: Physical address (unused on most systems)

**p_filesz**: Size of segment in file

**p_memsz**: Size of segment in memory (can exceed p_filesz for .bss)

**p_align**: Alignment requirement (p_vaddr ≡ p_offset mod p_align)

### Section Headers

Section headers describe sections for linking and debugging. Executables use program headers for loading, but section headers provide detailed information. Each section header (Elf64_Shdr) contains:

**sh_name**: Offset into section name string table

**sh_type**: Section type:

- SHT_NULL (0): Unused
- SHT_PROGBITS (1): Program data (.text, .data, .rodata)
- SHT_SYMTAB (2): Symbol table
- SHT_STRTAB (3): String table
- SHT_RELA (4): Relocation entries with addends
- SHT_HASH (5): Symbol hash table
- SHT_DYNAMIC (6): Dynamic linking information
- SHT_NOTE (7): Notes
- SHT_NOBITS (8): Occupies no file space (.bss)
- SHT_REL (9): Relocation entries without addends
- SHT_DYNSYM (11): Dynamic symbol table
- SHT_INIT_ARRAY (14): Array of constructor functions
- SHT_FINI_ARRAY (15): Array of destructor functions

**sh_flags**: Section attributes:

- SHF_WRITE (0x1): Writable during execution
- SHF_ALLOC (0x2): Occupies memory during execution
- SHF_EXECINSTR (0x4): Contains executable instructions
- SHF_MERGE (0x10): Data can be merged
- SHF_STRINGS (0x20): Contains null-terminated strings
- SHF_TLS (0x400): Thread-local storage

**sh_addr**: Virtual address where section is loaded (0 if not loaded)

**sh_offset**: File offset to section data

**sh_size**: Size of section in bytes

**sh_link**: Section header table index link (interpretation depends on section type)

**sh_info**: Extra information (interpretation depends on section type)

**sh_addralign**: Address alignment constraint

**sh_entsize**: Size of entries if section holds table

### Common ELF Sections

**.text**: Executable code, marked as readable and executable (R-X)

**.rodata**: Read-only data including string literals and constants (R--)

**.data**: Initialized writable data including global and static variables (RW-)

**.bss**: Uninitialized data, zeroed at load time. Occupies no file space (only sh_size is non-zero, sh_offset is meaningless) (RW-)

**.symtab**: Symbol table for linking and debugging, contains function and variable symbols

**.strtab**: String table for symbol names referenced by .symtab

**.dynsym**: Dynamic symbol table for runtime linking

**.dynstr**: String table for dynamic symbol names

**.rel.text / .rela.text**: Relocation entries for .text section

**.rel.data / .rela.data**: Relocation entries for .data section

**.plt**: Procedure Linkage Table for lazy binding of dynamic functions

**.got**: Global Offset Table containing addresses of global variables and functions

**.got.plt**: Part of GOT used by PLT for function resolution

**.init**: Initialization code executed before main()

**.fini**: Finalization code executed after main() returns

**.init_array / .fini_array**: Arrays of function pointers for constructors/destructors

**.dynamic**: Dynamic linking information including required shared libraries

**.interp**: Path to dynamic linker/loader (e.g., /lib64/ld-linux-x86-64.so.2)

**.note**: Auxiliary information like build ID, ABI tags

**.eh_frame**: Exception handling frame information for stack unwinding

**.comment**: Compiler version and build information

**.shstrtab**: Section header string table (section names)

### Symbol Tables

Symbol table entries (Elf64_Sym) describe functions, variables, and other symbols:

**st_name**: Offset into string table for symbol name

**st_info**: Symbol type and binding:

- Binding: LOCAL (0), GLOBAL (1), WEAK (2)
- Type: NOTYPE (0), OBJECT (1), FUNC (2), SECTION (3), FILE (4), TLS (6)

**st_other**: Symbol visibility (DEFAULT, HIDDEN, PROTECTED)

**st_shndx**: Section header table index where symbol is defined (SHN_UNDEF for undefined symbols)

**st_value**: Symbol value (address for defined symbols, 0 for undefined)

**st_size**: Symbol size in bytes

### Dynamic Linking

**Dynamic Section**: The .dynamic section contains tags describing dynamic linking requirements:

- DT_NEEDED: Required shared library name
- DT_SONAME: Shared object name
- DT_SYMTAB: Address of symbol table
- DT_STRTAB: Address of string table
- DT_PLTGOT: Address of PLT/GOT
- DT_RELA: Address of relocation table
- DT_INIT: Address of initialization function
- DT_FINI: Address of termination function

**PLT and GOT**: Position-independent code uses the PLT/GOT mechanism for function calls:

[Inference] On first call to an external function, the PLT entry jumps to a resolver that finds the actual function address and updates the GOT. Subsequent calls jump directly to the resolved address, implementing lazy binding.

**PLT Entry Structure** (x86-64):

```assembly
; First PLT entry (special)
push [GOT+8]        ; Link map pointer
jmp [GOT+16]        ; Jump to resolver

; Typical PLT entry
jmp [GOT+offset]    ; Jump to function (initially points to next instruction)
push index          ; Push relocation index
jmp PLT[0]          ; Jump to resolver
```

### Relocations

Relocation entries (Elf64_Rela) describe address fixups needed for linking:

**r_offset**: Location where relocation applies

**r_info**: Symbol table index and relocation type encoded together

**r_addend**: Constant addend used in relocation computation

Common relocation types for x86-64:

- R_X86_64_64: Direct 64-bit reference
- R_X86_64_PC32: PC-relative 32-bit reference
- R_X86_64_GLOB_DAT: GOT entry for global variable
- R_X86_64_JUMP_SLOT: PLT entry for function
- R_X86_64_RELATIVE: Adjust by program base address

### Position-Independent Code (PIC)

Shared libraries are compiled as PIC to allow loading at any address. PIC uses:

**RIP-relative addressing** (x86-64): References memory relative to instruction pointer

```assembly
mov rax, [rel variable]     ; Access variable using RIP-relative
lea rdi, [rel string]       ; Load address using RIP-relative
```

**GOT for global variables**: Access through Global Offset Table

```assembly
mov rax, [rel variable@GOTPCREL]  ; Get address from GOT
mov eax, [rax]                     ; Access the variable
```

**PLT for functions**: Call through Procedure Linkage Table

```assembly
call function@PLT              ; Call through PLT
```

### ELF Tools and Analysis

**readelf**: Primary tool for examining ELF files:

- `readelf -h file` displays ELF header
- `readelf -l file` displays program headers (segments)
- `readelf -S file` displays section headers
- `readelf -s file` displays symbol table
- `readelf -r file` displays relocations
- `readelf -d file` displays dynamic section

**objdump**: Disassembler and object file analyzer:

- `objdump -d file` disassembles code sections
- `objdump -t file` displays symbol table
- `objdump -x file` displays all headers

**nm**: Lists symbols from object files

- `nm -D file` lists dynamic symbols
- `nm -g file` lists global symbols only

**ldd**: Lists shared library dependencies

- `ldd executable` shows required .so files

**patchelf**: Modifies ELF executables (change interpreter, rpath, etc.)

**eu-readelf**: Enhanced readelf from elfutils package

### ELF Example Structure

```
[ELF Header]
    [e_ident - magic, class, encoding, etc.]
    [e_type, e_machine, e_version]
    [e_entry - entry point]
    [e_phoff - program header offset]
    [e_shoff - section header offset]
    [other header fields]

[Program Header Table]
    [PT_LOAD segment - .text, .rodata]
    [PT_LOAD segment - .data, .bss]
    [PT_DYNAMIC segment]
    [PT_INTERP segment]
    [PT_GNU_STACK segment]

[.interp section - "/lib64/ld-linux-x86-64.so.2"]
[.text section - executable code]
[.rodata section - read-only data]
[.data section - initialized data]
[.bss section - uninitialized data (no file space)]
[.symtab section - symbol table]
[.strtab section - string table]
[.dynsym section - dynamic symbols]
[.dynstr section - dynamic strings]
[.rela.dyn section - relocations]
[.rela.plt section - PLT relocations]
[.plt section - procedure linkage table]
[.got section - global offset table]
[.dynamic section - dynamic linking info]

[Section Header Table]
    [Section header for each section above]
    
[.shstrtab section - section name strings]
```

