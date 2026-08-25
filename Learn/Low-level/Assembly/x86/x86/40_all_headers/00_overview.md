## Overview

otool -h -l program
```

### Section Ordering and Layout

**Typical Memory Layout** (low to high addresses):

1. **NULL protection region** (Mach-O __PAGEZERO or implicit)
2. **Code segment** (.text and read-only data)
    - [Inference] Placed low in memory, marked non-writable for security
3. **Data segment** (.data, .bss, heap)
    - [Inference] Writable but non-executable (NX/DEP)
4. **Stack** (grows downward from high addresses)
    - [Inference] Separated from heap to detect stack overflow

**File Layout** (PE):

1. DOS header and stub
2. PE headers
3. Section table
4. Sections (in order: .text, .data, .rdata, .reloc, .rsrc, etc.)

**File Layout** (ELF):

1. ELF header
2. Program header table (optional, usually present in executables)
3. Sections (.text, .rodata, .data, .bss, symbol tables, etc.)
4. Section header table

**File Layout** (Mach-O):

1. Mach-O header
2. Load commands
3. Segment data (with contained sections)
4. Link-edit data (symbols, strings, signatures)

### Section Compression

**ELF**: Supports compressed sections:

- sh_flags includes SHF_COMPRESSED
- Section begins with Elf64_Chdr describing compression
- Used for debug sections to reduce file size
- [Inference] Decompressed by debugger/tools as needed

**PE**: No standard compression, but some packers compress entire sections

**Mach-O**: No standard section compression

### Custom Sections

Developers can create custom sections for special data:

**Embedded Data**:

```c
// GCC/Clang attribute
__attribute__((section("mysection")))
int my_data = 42;

// MSVC pragma
#pragma section("mysection", read)
__declspec(allocate("mysection"))
int my_data = 42;
```

**Assembly**:

```nasm
section mysection
    my_data dd 42
```

[Inference] Custom sections enable embedding configuration data, licensing information, or resources directly in the executable with controlled access permissions.

---

**Related topics for deeper understanding**: Dynamic linker implementation details, Relocation types and processing, Security mitigations (ASLR, DEP, CFG, stack canaries), Debug symbol formats (DWARF, PDB, dSYM), Binary patching and modification, Executable compression and packing, Format-specific extensions (PE overlay, ELF GNU extensions, Mach-O LC_* commands).

---

## File Format Overview

### PE (Portable Executable) - Windows

PE format is used for executables (.exe), dynamic libraries (.dll), kernel drivers (.sys), and other Windows binaries.

**Basic PE structure:**

```
DOS Header (IMAGE_DOS_HEADER)
DOS Stub
PE Signature ("PE\0\0")
COFF File Header (IMAGE_FILE_HEADER)
Optional Header (IMAGE_OPTIONAL_HEADER)
Section Headers (IMAGE_SECTION_HEADER[])
Section Data
```

**DOS Header:**

```c
typedef struct _IMAGE_DOS_HEADER {
    WORD e_magic;      // "MZ" signature (0x5A4D)
    WORD e_cblp;
    WORD e_cp;
    // ... other fields
    LONG e_lfanew;     // Offset to PE header
} IMAGE_DOS_HEADER;
```

**COFF File Header:**

```c
typedef struct _IMAGE_FILE_HEADER {
    WORD  Machine;              // 0x014C = x86, 0x8664 = x64
    WORD  NumberOfSections;
    DWORD TimeDateStamp;
    DWORD PointerToSymbolTable;
    DWORD NumberOfSymbols;
    WORD  SizeOfOptionalHeader;
    WORD  Characteristics;
} IMAGE_FILE_HEADER;
```

**Optional Header:**

```c
typedef struct _IMAGE_OPTIONAL_HEADER {
    WORD  Magic;                    // 0x010B = PE32, 0x020B = PE32+
    BYTE  MajorLinkerVersion;
    BYTE  MinorLinkerVersion;
    DWORD SizeOfCode;
    DWORD SizeOfInitializedData;
    DWORD SizeOfUninitializedData;
    DWORD AddressOfEntryPoint;      // RVA of entry point
    DWORD BaseOfCode;
    DWORD ImageBase;                // Preferred load address
    DWORD SectionAlignment;
    DWORD FileAlignment;
    // ... many other fields
    DWORD NumberOfRvaAndSizes;
    IMAGE_DATA_DIRECTORY DataDirectory[16];
} IMAGE_OPTIONAL_HEADER;
```

**Data Directories:**

```c
typedef struct _IMAGE_DATA_DIRECTORY {
    DWORD VirtualAddress;    // RVA
    DWORD Size;
} IMAGE_DATA_DIRECTORY;

// Data directory indices
#define IMAGE_DIRECTORY_ENTRY_EXPORT         0
#define IMAGE_DIRECTORY_ENTRY_IMPORT         1
#define IMAGE_DIRECTORY_ENTRY_RESOURCE       2
#define IMAGE_DIRECTORY_ENTRY_BASERELOC      5
#define IMAGE_DIRECTORY_ENTRY_IAT           12
```

**Section Header:**

```c
typedef struct _IMAGE_SECTION_HEADER {
    BYTE  Name[8];
    DWORD VirtualSize;
    DWORD VirtualAddress;       // RVA where loaded
    DWORD SizeOfRawData;
    DWORD PointerToRawData;     // File offset
    DWORD PointerToRelocations;
    DWORD PointerToLinenumbers;
    WORD  NumberOfRelocations;
    WORD  NumberOfLinenumbers;
    DWORD Characteristics;      // Flags (readable, writable, executable)
} IMAGE_SECTION_HEADER;
```

Common PE sections:

- `.text` - Executable code
- `.data` - Initialized data
- `.bss` - Uninitialized data (virtual only)
- `.rdata` - Read-only data (constants, import tables)
- `.idata` - Import information
- `.edata` - Export information
- `.reloc` - Base relocation table
- `.rsrc` - Resources (icons, strings, dialogs)

### ELF (Executable and Linkable Format) - Linux/Unix

ELF format is used for executables, shared libraries (.so), object files (.o), and core dumps on Unix-like systems.

**Basic ELF structure:**

```
ELF Header
Program Headers (for executables/shared libs)
Section Headers
Section Data
```

**ELF Header:**

```c
typedef struct {
    unsigned char e_ident[16];  // Magic number and other info
    Elf64_Half    e_type;       // Object file type (ET_EXEC, ET_DYN, ET_REL)
    Elf64_Half    e_machine;    // Architecture (EM_X86_64, EM_386)
    Elf64_Word    e_version;    // Object file version
    Elf64_Addr    e_entry;      // Entry point virtual address
    Elf64_Off     e_phoff;      // Program header table offset
    Elf64_Off     e_shoff;      // Section header table offset
    Elf64_Word    e_flags;      // Processor-specific flags
    Elf64_Half    e_ehsize;     // ELF header size
    Elf64_Half    e_phentsize;  // Program header entry size
    Elf64_Half    e_phnum;      // Number of program headers
    Elf64_Half    e_shentsize;  // Section header entry size
    Elf64_Half    e_shnum;      // Number of section headers
    Elf64_Half    e_shstrndx;   // Section header string table index
} Elf64_Ehdr;
```

**e_ident field breakdown:**

```
Offset | Size | Purpose
-------|------|--------
0      | 4    | Magic number: 0x7F, 'E', 'L', 'F'
4      | 1    | Class: 1=32-bit, 2=64-bit
5      | 1    | Data encoding: 1=little-endian, 2=big-endian
6      | 1    | Version: 1=current
7      | 1    | OS/ABI: 0=System V, 3=Linux
8-15   | 8    | Padding
```

**Program Header (Segment):**

```c
typedef struct {
    Elf64_Word  p_type;     // Segment type (PT_LOAD, PT_DYNAMIC, PT_INTERP)
    Elf64_Word  p_flags;    // Segment flags (PF_X, PF_W, PF_R)
    Elf64_Off   p_offset;   // File offset
    Elf64_Addr  p_vaddr;    // Virtual address
    Elf64_Addr  p_paddr;    // Physical address (unused on most systems)
    Elf64_Xword p_filesz;   // Size in file
    Elf64_Xword p_memsz;    // Size in memory
    Elf64_Xword p_align;    // Alignment
} Elf64_Phdr;
```

**Section Header:**

```c
typedef struct {
    Elf64_Word  sh_name;      // Section name (string table offset)
    Elf64_Word  sh_type;      // Section type
    Elf64_Xword sh_flags;     // Section flags
    Elf64_Addr  sh_addr;      // Virtual address
    Elf64_Off   sh_offset;    // File offset
    Elf64_Xword sh_size;      // Section size
    Elf64_Word  sh_link;      // Link to related section
    Elf64_Word  sh_info;      // Extra information
    Elf64_Xword sh_addralign; // Alignment
    Elf64_Xword sh_entsize;   // Entry size for tables
} Elf64_Shdr;
```

Common ELF sections:

- `.text` - Executable code
- `.data` - Initialized data
- `.bss` - Uninitialized data
- `.rodata` - Read-only data
- `.symtab` - Symbol table
- `.strtab` - String table
- `.dynsym` - Dynamic symbol table
- `.dynstr` - Dynamic string table
- `.rel.text`, `.rela.text` - Relocations for .text
- `.rel.dyn`, `.rela.dyn` - Dynamic relocations
- `.rel.plt`, `.rela.plt` - PLT relocations
- `.dynamic` - Dynamic linking information
- `.got` - Global Offset Table
- `.plt` - Procedure Linkage Table
- `.init`, `.fini` - Initialization/finalization code
- `.ctors`, `.dtors` - Constructor/destructor tables

### Mach-O (Mach Object) - macOS/iOS

Mach-O format is used for executables, dynamic libraries (.dylib), object files (.o), and bundles on Apple platforms.

**Basic Mach-O structure:**

```
Mach Header
Load Commands
Segment Data
```

**Mach Header (64-bit):**

```c
struct mach_header_64 {
    uint32_t magic;         // 0xFEEDFACF (64-bit)
    cpu_type_t cputype;     // CPU type (CPU_TYPE_X86_64)
    cpu_subtype_t cpusubtype;
    uint32_t filetype;      // MH_EXECUTE, MH_DYLIB, MH_OBJECT
    uint32_t ncmds;         // Number of load commands
    uint32_t sizeofcmds;    // Size of load commands
    uint32_t flags;         // Flags
    uint32_t reserved;
};
```

**Load Commands:**

Load commands immediately follow the header and describe segments, libraries, entry points, and other file attributes:

```c
struct load_command {
    uint32_t cmd;       // Command type
    uint32_t cmdsize;   // Size including data
};
```

Common load command types:

- `LC_SEGMENT_64` - 64-bit segment
- `LC_SYMTAB` - Symbol table
- `LC_DYSYMTAB` - Dynamic symbol table
- `LC_LOAD_DYLIB` - Load dynamic library
- `LC_MAIN` - Entry point
- `LC_DYLD_INFO_ONLY` - Dynamic linker info

**Segment Command:**

```c
struct segment_command_64 {
    uint32_t cmd;           // LC_SEGMENT_64
    uint32_t cmdsize;
    char segname[16];       // Segment name
    uint64_t vmaddr;        // Virtual memory address
    uint64_t vmsize;        // Virtual memory size
    uint64_t fileoff;       // File offset
    uint64_t filesize;      // File size
    vm_prot_t maxprot;      // Maximum protection
    vm_prot_t initprot;     // Initial protection
    uint32_t nsects;        // Number of sections
    uint32_t flags;
};
```

**Section within Segment:**

```c
struct section_64 {
    char sectname[16];      // Section name
    char segname[16];       // Segment name
    uint64_t addr;          // Virtual address
    uint64_t size;          // Size
    uint32_t offset;        // File offset
    uint32_t align;         // Alignment (power of 2)
    uint32_t reloff;        // Relocation entries offset
    uint32_t nreloc;        // Number of relocations
    uint32_t flags;         // Section type and attributes
    uint32_t reserved1;
    uint32_t reserved2;
    uint32_t reserved3;
};
```

Common Mach-O segments and sections:

- `__PAGEZERO` - Zero-filled guard page
- `__TEXT` segment:
    - `__text` - Executable code
    - `__stubs` - Symbol stubs for dynamic linking
    - `__stub_helper` - Helper code for stubs
    - `__const` - Constants
    - `__cstring` - C strings
- `__DATA` segment:
    - `__data` - Initialized data
    - `__bss` - Uninitialized data
    - `__la_symbol_ptr` - Lazy symbol pointers
    - `__nl_symbol_ptr` - Non-lazy symbol pointers
    - `__const` - Constants that need relocations
- `__LINKEDIT` segment - Symbol and relocation info

### Universal Binaries (Fat Binaries)

**[Inference]** macOS supports universal binaries containing multiple architectures:

```c
struct fat_header {
    uint32_t magic;         // FAT_MAGIC (0xCAFEBABE)
    uint32_t nfat_arch;     // Number of architectures
};

struct fat_arch {
    cpu_type_t cputype;
    cpu_subtype_t cpusubtype;
    uint32_t offset;        // File offset to architecture
    uint32_t size;
    uint32_t align;
};
```

## Symbol Tables

Symbol tables map names (identifiers) to addresses and contain information about functions, variables, and other program entities.

### PE Symbol Tables

**[Inference]** PE files use COFF symbol table format, though modern PE files often use debug information (PDB files) instead:

```c
typedef struct _IMAGE_SYMBOL {
    union {
        BYTE ShortName[8];
        struct {
            DWORD Short;
            DWORD Long;
        } Name;
        DWORD LongName[2];
    } N;
    DWORD Value;
    SHORT SectionNumber;
    WORD Type;
    BYTE StorageClass;
    BYTE NumberOfAuxSymbols;
} IMAGE_SYMBOL;
```

**Export Directory:**

PE export tables allow other binaries to import functions:

```c
typedef struct _IMAGE_EXPORT_DIRECTORY {
    DWORD Characteristics;
    DWORD TimeDateStamp;
    WORD MajorVersion;
    WORD MinorVersion;
    DWORD Name;                     // DLL name RVA
    DWORD Base;                     // Ordinal base
    DWORD NumberOfFunctions;
    DWORD NumberOfNames;
    DWORD AddressOfFunctions;       // RVA to function addresses array
    DWORD AddressOfNames;           // RVA to function names array
    DWORD AddressOfNameOrdinals;    // RVA to ordinals array
} IMAGE_EXPORT_DIRECTORY;
```

**Example:** Locating an exported function:

```
1. Parse PE headers to find export directory
2. Read AddressOfNames array to find name strings
3. Search for desired function name
4. Use index to look up ordinal in AddressOfNameOrdinals
5. Use ordinal to index AddressOfFunctions
6. Result is RVA of function
```

### ELF Symbol Tables

ELF maintains separate symbol tables for static and dynamic linking:

**Symbol Table Entry:**

```c
typedef struct {
    Elf64_Word    st_name;   // Symbol name (string table offset)
    unsigned char st_info;   // Symbol type and binding
    unsigned char st_other;  // Symbol visibility
    Elf64_Half    st_shndx;  // Section index
    Elf64_Addr    st_value;  // Symbol value (address/offset)
    Elf64_Xword   st_size;   // Symbol size
} Elf64_Sym;
```

**st_info field breakdown:**

```c
// Binding (upper 4 bits)
#define STB_LOCAL   0    // Local symbol
#define STB_GLOBAL  1    // Global symbol
#define STB_WEAK    2    // Weak symbol

// Type (lower 4 bits)
#define STT_NOTYPE  0    // Unspecified type
#define STT_OBJECT  1    // Data object
#define STT_FUNC    2    // Function
#define STT_SECTION 3    // Section
#define STT_FILE    4    // Source file name

// Macros to manipulate st_info
#define ELF64_ST_BIND(i)   ((i) >> 4)
#define ELF64_ST_TYPE(i)   ((i) & 0xf)
#define ELF64_ST_INFO(b,t) (((b) << 4) + ((t) & 0xf))
```

**st_other field (visibility):**

```c
#define STV_DEFAULT   0    // Default visibility
#define STV_INTERNAL  1    // Internal visibility
#define STV_HIDDEN    2    // Hidden symbol
#define STV_PROTECTED 3    // Protected symbol
```

**Symbol table sections:**

- `.symtab` - Complete symbol table (may be stripped)
- `.dynsym` - Dynamic symbol table (required for dynamic linking)
- `.strtab` - String table for .symtab
- `.dynstr` - String table for .dynsym

**Example:** Reading symbol from .symtab:

```c
// Pseudocode for symbol lookup
Elf64_Ehdr *ehdr = (Elf64_Ehdr *)file_base;
Elf64_Shdr *shdr = (Elf64_Shdr *)(file_base + ehdr->e_shoff);

// Find .symtab section
for (int i = 0; i < ehdr->e_shnum; i++) {
    if (shdr[i].sh_type == SHT_SYMTAB) {
        Elf64_Sym *symtab = (Elf64_Sym *)(file_base + shdr[i].sh_offset);
        int num_symbols = shdr[i].sh_size / sizeof(Elf64_Sym);
        
        // Find .strtab
        Elf64_Shdr *strtab_shdr = &shdr[shdr[i].sh_link];
        char *strtab = (char *)(file_base + strtab_shdr->sh_offset);
        
        // Iterate symbols
        for (int j = 0; j < num_symbols; j++) {
            char *name = strtab + symtab[j].st_name;
            // Process symbol
        }
    }
}
```

**Symbol versioning:**

**[Inference]** ELF supports symbol versioning for compatibility across library versions:

```c
typedef struct {
    Elf64_Half vd_version;   // Version
    Elf64_Half vd_flags;     // Flags
    Elf64_Half vd_ndx;       // Version index
    Elf64_Half vd_cnt;       // Number of aux entries
    Elf64_Word vd_hash;      // Hash value
    Elf64_Word vd_aux;       // Offset to aux entry
    Elf64_Word vd_next;      // Offset to next version
} Elf64_Verdef;
```

### Mach-O Symbol Tables

**Symbol Table Command:**

```c
struct symtab_command {
    uint32_t cmd;        // LC_SYMTAB
    uint32_t cmdsize;
    uint32_t symoff;     // Symbol table file offset
    uint32_t nsyms;      // Number of symbols
    uint32_t stroff;     // String table file offset
    uint32_t strsize;    // String table size
};
```

**Symbol Table Entry (nlist):**

```c
struct nlist_64 {
    union {
        uint32_t n_strx;     // String table index
    } n_un;
    uint8_t n_type;          // Type and flags
    uint8_t n_sect;          // Section number
    uint16_t n_desc;         // Description field
    uint64_t n_value;        // Value/address
};
```

**n_type field breakdown:**

```c
// Type mask
#define N_TYPE  0x0e
#define N_UNDF  0x0   // Undefined
#define N_ABS   0x2   // Absolute
#define N_SECT  0xe   // Defined in section

// Flags
#define N_EXT   0x01  // External symbol
#define N_PEXT  0x10  // Private external
#define N_STAB  0xe0  // Debug symbol
```

**Dynamic Symbol Table:**

```c
struct dysymtab_command {
    uint32_t cmd;             // LC_DYSYMTAB
    uint32_t cmdsize;
    uint32_t ilocalsym;       // Index of first local symbol
    uint32_t nlocalsym;       // Number of local symbols
    uint32_t iextdefsym;      // Index of first external defined symbol
    uint32_t nextdefsym;      // Number of external defined symbols
    uint32_t iundefsym;       // Index of first undefined symbol
    uint32_t nundefsym;       // Number of undefined symbols
    uint32_t tocoff;          // Table of contents offset
    uint32_t ntoc;            // Entries in TOC
    uint32_t modtaboff;       // Module table offset
    uint32_t nmodtab;         // Entries in module table
    uint32_t extrefsymoff;    // External reference table offset
    uint32_t nextrefsyms;     // Entries in external reference table
    uint32_t indirectsymoff;  // Indirect symbol table offset
    uint32_t nindirectsyms;   // Entries in indirect symbol table
    uint32_t extreloff;       // External relocation entries offset
    uint32_t nextrel;         // Number of external relocations
    uint32_t locreloff;       // Local relocation entries offset
    uint32_t nlocrel;         // Number of local relocations
};
```

### Symbol Resolution

**Static linking resolution order:**

1. Search current object file for symbol definition
2. Search all object files being linked
3. Search static libraries in order specified
4. If not found, generate linker error

**Dynamic linking resolution order (typical):**

1. Check executable's own symbol table
2. Search loaded shared libraries in dependency order
3. For ELF: Use symbol scope and visibility rules
4. For PE: Search only explicitly imported DLLs
5. For Mach-O: Use two-level namespace (library + symbol)

**Symbol binding types:**

- **Local (static)** - Visible only within current file/module
- **Global** - Visible to all linked modules
- **Weak** - Can be overridden by strong symbols
- **Common** - Uninitialized global (legacy C behavior)

**Example:** Assembly with symbol visibility (ELF):

```nasm
section .text

global public_function:function    ; Exported function
global public_data:object         ; Exported data

hidden internal_function:function  ; Hidden from dynamic linker

public_function:
    call internal_function
    ret

internal_function:
    ret

section .data
public_data:
    dd 42
```

## Relocation Entries

Relocations adjust addresses in code and data when files are loaded at different addresses or when linking multiple object files together.

### Types of Relocations

**Absolute relocations** - Complete address replacements

**Relative relocations** - Offset-based, typically PC-relative

**Position-independent relocations** - Support loading at any address

### PE Relocations

**Base Relocation Table:**

PE files contain a base relocation table for ASLR (Address Space Layout Randomization) support:

```c
typedef struct _IMAGE_BASE_RELOCATION {
    DWORD VirtualAddress;    // RVA of relocation block
    DWORD SizeOfBlock;       // Size of this block including header
    // Followed by array of relocation entries (WORDs)
} IMAGE_BASE_RELOCATION;
```

**Relocation Entry Format:**

Each entry is a 16-bit value:

```
Bits 0-11:  Offset within page (12 bits)
Bits 12-15: Relocation type (4 bits)
```

**Relocation types:**

```c
#define IMAGE_REL_BASED_ABSOLUTE       0   // Skip
#define IMAGE_REL_BASED_HIGHLOW        3   // 32-bit address
#define IMAGE_REL_BASED_DIR64          10  // 64-bit address
```

**Example:** Processing PE relocations:

```c
// Pseudocode
DWORD_PTR delta = (DWORD_PTR)loaded_base - image_base;
IMAGE_BASE_RELOCATION *reloc = base_reloc_directory;

while (reloc->VirtualAddress != 0) {
    WORD *reloc_entries = (WORD *)(reloc + 1);
    int count = (reloc->SizeOfBlock - sizeof(IMAGE_BASE_RELOCATION)) / sizeof(WORD);
    
    for (int i = 0; i < count; i++) {
        WORD entry = reloc_entries[i];
        int type = entry >> 12;
        int offset = entry & 0xFFF;
        
        BYTE *target = (BYTE *)loaded_base + reloc->VirtualAddress + offset;
        
        if (type == IMAGE_REL_BASED_HIGHLOW) {
            *(DWORD *)target += (DWORD)delta;
        } else if (type == IMAGE_REL_BASED_DIR64) {
            *(DWORD_PTR *)target += delta;
        }
    }
    
    reloc = (IMAGE_BASE_RELOCATION *)((BYTE *)reloc + reloc->SizeOfBlock);
}
```

### ELF Relocations

ELF uses two relocation entry formats:

**Without explicit addend (REL):**

```c
typedef struct {
    Elf64_Addr r_offset;    // Location to apply relocation
    Elf64_Xword r_info;     // Symbol index and type
} Elf64_Rel;

#define ELF64_R_SYM(i)    ((i) >> 32)
#define ELF64_R_TYPE(i)   ((i) & 0xffffffff)
#define ELF64_R_INFO(s,t) (((s) << 32) + ((t) & 0xffffffff))
```

**With explicit addend (RELA):**

```c
typedef struct {
    Elf64_Addr r_offset;    // Location to apply relocation
    Elf64_Xword r_info;     // Symbol index and type
    Elf64_Sxword r_addend;  // Constant addend
} Elf64_Rela;
```

**Common x86-64 relocation types:**

```c
#define R_X86_64_NONE       0   // No relocation
#define R_X86_64_64         1   // Direct 64-bit absolute
#define R_X86_64_PC32       2   // PC-relative 32-bit signed
#define R_X86_64_GOT32      3   // 32-bit GOT entry
#define R_X86_64_PLT32      4   // 32-bit PLT address
#define R_X86_64_COPY       5   // Copy symbol at runtime
#define R_X86_64_GLOB_DAT   6   // Create GOT entry
#define R_X86_64_JUMP_SLOT  7   // Create PLT entry
#define R_X86_64_RELATIVE   8   // Adjust by program base
#define R_X86_64_GOTPCREL   9   // 32-bit PC-relative GOT offset
#define R_X86_64_32         10  // Direct 32-bit zero-extended
#define R_X86_64_32S        11  // Direct 32-bit sign-extended
#define R_X86_64_16         12  // Direct 16-bit zero-extended
#define R_X86_64_PC16       13  // 16-bit PC-relative
#define R_X86_64_8          14  // Direct 8-bit sign-extended
#define R_X86_64_PC8        15  // 8-bit PC-relative
```

**Common x86 (32-bit) relocation types:**

```c
#define R_386_NONE          0   // No relocation
#define R_386_32            1   // Direct 32-bit absolute
#define R_386_PC32          2   // PC-relative 32-bit
#define R_386_GOT32         3   // 32-bit GOT entry
#define R_386_PLT32         4   // 32-bit PLT address
#define R_386_COPY          5   // Copy symbol at runtime
#define R_386_GLOB_DAT      6   // Create GOT entry
#define R_386_JMP_SLOT      7   // Create PLT entry
#define R_386_RELATIVE      8   // Adjust by program base
#define R_386_GOTOFF        9   // 32-bit offset to GOT
#define R_386_GOTPC         10  // 32-bit PC-relative offset to GOT
```

**Example:** Processing ELF relocations:

```c
// Pseudocode for applying RELA relocations
Elf64_Rela *rela = rela_section;
int count = rela_section_size / sizeof(Elf64_Rela);

for (int i = 0; i < count; i++) {
    Elf64_Sym *sym = &symtab[ELF64_R_SYM(rela[i].r_info)];
    int type = ELF64_R_TYPE(rela[i].r_info);
    Elf64_Addr *location = (Elf64_Addr *)(base + rela[i].r_offset);
    Elf64_Addr symbol_addr = sym->st_value;
    
    switch (type) {
        case R_X86_64_64:
            *location = symbol_addr + rela[i].r_addend;
            break;
        case R_X86_64_PC32:
            *(uint32_t *)location = symbol_addr + rela[i].r_addend - rela[i].r_offset;
            break;
        case R_X86_64_RELATIVE:
            *location = base + rela[i].r_addend;
            break;
        // Other relocation types...
    }
}
```

**Relocation sections:**

- `.rel.text` / `.rela.text` - Relocations for code section
- `.rel.data` / `.rela.data` - Relocations for data section
- `.rel.dyn` / `.rela.dyn` - Dynamic relocations
- `.rel.plt` / `.rela.plt` - PLT relocations

### Mach-O Relocations

**Relocation Entry:**

```c
struct relocation_info {
    int32_t r_address;      // Offset from section start
    uint32_t r_symbolnum:24, // Symbol index or section number
             r_pcrel:1,      // PC-relative flag
             r_length:2,     // Size: 0=byte, 1=word, 2=long, 3=quad
             r_extern:1,     // External symbol flag
             r_type:4;       // Type (architecture-specific)
};
```

**Scattered relocation (for dynamic libraries):**

```c
struct scattered_relocation_info {
    uint32_t r_scattered:1,  // Must be 1
             r_pcrel:1,
             r_length:2,
             r_type:4,
             r_address:24;
    int32_t r_value;         // Target value
};
```

**x86-64 relocation types:**

```c
#define X86_64_RELOC_UNSIGNED    0  // Absolute address
#define X86_64_RELOC_SIGNED      1  // Signed 32-bit displacement
#define X86_64_RELOC_BRANCH      2  // PC-relative branch
#define X86_64_RELOC_GOT_LOAD    3  // Load from GOT
#define X86_64_RELOC_GOT         4  // GOT reference
#define X86_64_RELOC_SUBTRACTOR  5  // Subtraction
#define X86_64_RELOC_SIGNED_1    6  // Signed 32-bit displacement +1
#define X86_64_RELOC_SIGNED_2    7  // Signed 32-bit displacement +2
#define X86_64_RELOC_SIGNED_4    8  // Signed 32-bit displacement +4
#define X86_64_RELOC_TLV         9  // Thread local variable
````

**Example:** Processing Mach-O relocations:

```c
// Pseudocode
struct section_64 *sect = find_section("__TEXT", "__text");
struct relocation_info *relocs = (void *)(file_base + sect->reloff);

for (uint32_t i = 0; i < sect->nreloc; i++) {
    struct relocation_info *r = &relocs[i];
    
    if (r->r_scattered) {
        struct scattered_relocation_info *sr = (void *)r;
        // Process scattered relocation
    } else {
        uint8_t *location = section_base + r->r_address;
        uint64_t symbol_addr;
        
        if (r->r_extern) {
            struct nlist_64 *sym = &symtab[r->r_symbolnum];
            symbol_addr = sym->n_value;
        } else {
            // Section-relative relocation
            symbol_addr = section_addresses[r->r_symbolnum - 1];
        }
        
        switch (r->r_type) {
            case X86_64_RELOC_UNSIGNED:
                if (r->r_length == 3) {  // 64-bit
                    *(uint64_t *)location = symbol_addr;
                }
                break;
            case X86_64_RELOC_SIGNED:
                *(int32_t *)location = symbol_addr - (location + 4);
                break;
            case X86_64_RELOC_BRANCH:
                *(int32_t *)location = symbol_addr - (location + 4);
                break;
            // Other types...
        }
    }
}
````

### Position-Independent Code (PIC) and Relocations

**[Inference]** Position-independent code minimizes relocations by using relative addressing:

**PC-relative addressing (x86-64):**

```nasm
; Instead of absolute addressing:
mov rax, [external_data]    ; Requires relocation

; Use PC-relative:
mov rax, [rel external_data]  ; R_X86_64_PC32 relocation
```

**Global Offset Table (GOT) usage:**

```nasm
; Access external variable through GOT
mov rax, [rel external_data wrt ..got]  ; Load GOT entry address
mov rbx, [rax]                           ; Dereference to get actual data
```

**RIP-relative addressing benefits:**

- Fewer relocations needed
- Better ASLR support
- Smaller relocation tables
- Faster loading times

## Dynamic Linking

Dynamic linking defers symbol resolution until load time or runtime, allowing shared libraries to be loaded into multiple processes.

### Windows Dynamic Linking

**Import Address Table (IAT):**

The IAT contains addresses of imported functions, filled by the Windows loader:

```c
typedef struct _IMAGE_IMPORT_DESCRIPTOR {
    union {
        DWORD Characteristics;
        DWORD OriginalFirstThunk;    // RVA to Import Name Table (INT)
    };
    DWORD TimeDateStamp;
    DWORD ForwarderChain;
    DWORD Name;                      // RVA to DLL name
    DWORD FirstThunk;                // RVA to Import Address Table (IAT)
} IMAGE_IMPORT_DESCRIPTOR;
```

**Import lookup process:**

```
1. Loader reads import descriptor
2. Loads referenced DLL (recursively loads its dependencies)
3. Resolves function addresses from DLL export table
4. Writes addresses into IAT
5. Program calls functions through IAT
```

**Import Name Table Entry:**

```c
typedef struct _IMAGE_IMPORT_BY_NAME {
    WORD Hint;              // Index into export table
    BYTE Name[1];           // Function name (null-terminated)
} IMAGE_IMPORT_BY_NAME;
```

**Thunk Data (pointer-sized entry):**

```c
// 64-bit
typedef union _IMAGE_THUNK_DATA64 {
    ULONGLONG ForwarderString;
    ULONGLONG Function;          // Address of imported function
    ULONGLONG Ordinal;           // Import by ordinal
    ULONGLONG AddressOfData;     // IMAGE_IMPORT_BY_NAME
} IMAGE_THUNK_DATA64;

// Check if import by ordinal
#define IMAGE_ORDINAL_FLAG64  0x8000000000000000
#define IMAGE_ORDINAL64(ord)  ((ord) & 0xFFFF)
```

**Example:** Calling imported function:

```nasm
section .text
extern __imp_MessageBoxA

call_msgbox:
    ; Arguments setup
    push 0
    push caption
    push message
    push 0
    
    ; Call through IAT
    call [__imp_MessageBoxA]
    ret
```

**Delay-load imports:**

**[Inference]** Windows supports delay-loading DLLs (loaded on first use):

```c
typedef struct _IMAGE_DELAYLOAD_DESCRIPTOR {
    DWORD Attributes;
    DWORD DllNameRVA;
    DWORD ModuleHandleRVA;
    DWORD ImportAddressTableRVA;
    DWORD ImportNameTableRVA;
    DWORD BoundImportAddressTableRVA;
    DWORD UnloadInformationTableRVA;
    DWORD TimeDateStamp;
} IMAGE_DELAYLOAD_DESCRIPTOR;
```

**LoadLibrary and GetProcAddress:**

Manual dynamic linking at runtime:

```nasm
section .data
    dll_name db 'user32.dll', 0
    func_name db 'MessageBoxA', 0
    
section .text
    extern _LoadLibraryA@4
    extern _GetProcAddress@8
    
load_function:
    push dll_name
    call _LoadLibraryA@4
    test eax, eax
    jz error
    
    push func_name
    push eax            ; hModule
    call _GetProcAddress@8
    test eax, eax
    jz error
    
    ; EAX now contains function address
    mov [func_ptr], eax
    ret
```

### ELF Dynamic Linking

**Dynamic Section:**

The `.dynamic` section contains entries describing dynamic linking requirements:

```c
typedef struct {
    Elf64_Sxword d_tag;     // Entry type
    union {
        Elf64_Xword d_val;  // Integer value
        Elf64_Addr d_ptr;   // Address value
    } d_un;
} Elf64_Dyn;
```

**Common dynamic tags:**

```c
#define DT_NULL         0   // End of array
#define DT_NEEDED       1   // Dependency (shared library name)
#define DT_PLTRELSZ     2   // Size of PLT relocation entries
#define DT_PLTGOT       3   // Address of PLT/GOT
#define DT_HASH         4   // Address of symbol hash table
#define DT_STRTAB       5   // Address of string table
#define DT_SYMTAB       6   // Address of symbol table
#define DT_RELA         7   // Address of Rela relocations
#define DT_RELASZ       8   // Size of Rela relocations
#define DT_RELAENT      9   // Size of one Rela entry
#define DT_STRSZ        10  // Size of string table
#define DT_SYMENT       11  // Size of symbol table entry
#define DT_INIT         12  // Address of initialization function
#define DT_FINI         13  // Address of finalization function
#define DT_SONAME       14  // Shared object name
#define DT_RPATH        15  // Library search path (deprecated)
#define DT_SYMBOLIC     16  // Symbol resolution starts here
#define DT_REL          17  // Address of Rel relocations
#define DT_RELSZ        18  // Size of Rel relocations
#define DT_RELENT       19  // Size of one Rel entry
#define DT_PLTREL       20  // Type of PLT relocation (DT_REL or DT_RELA)
#define DT_DEBUG        21  // For debugging
#define DT_TEXTREL      22  // Text relocations present
#define DT_JMPREL       23  // Address of PLT relocations
#define DT_BIND_NOW     24  // Process all relocations at load
#define DT_INIT_ARRAY   25  // Array of initialization functions
#define DT_FINI_ARRAY   26  // Array of finalization functions
#define DT_RUNPATH      29  // Library search path
#define DT_FLAGS        30  // Flags
#define DT_GNU_HASH     0x6ffffef5  // GNU hash table
```

**Global Offset Table (GOT):**

The GOT holds addresses of global variables and functions:

```
.got         - GOT for data references
.got.plt     - GOT entries for PLT (functions)
```

**GOT structure (simplified):**

```
GOT[0]: Address of .dynamic section
GOT[1]: Link map pointer (for dynamic linker)
GOT[2]: Dynamic linker resolver function (_dl_runtime_resolve)
GOT[3+]: Function addresses (initially PLT stub addresses)
```

**Procedure Linkage Table (PLT):**

The PLT enables lazy binding of function calls:

**PLT structure:**

```nasm
; PLT[0] - Special entry
.plt:
    push qword [rel GOT+8]     ; Push link map
    jmp [rel GOT+16]           ; Jump to dynamic linker resolver
    nop
    nop

; PLT[1] - First function
.plt.func1:
    jmp [rel GOT+24]           ; Initially points to next instruction
    push 0                     ; Relocation index
    jmp .plt                   ; Jump to PLT[0]

; PLT[2] - Second function
.plt.func2:
    jmp [rel GOT+32]
    push 1                     ; Relocation index
    jmp .plt
```

**Lazy binding process:**

```
1. First call to external function jumps through PLT
2. PLT entry jumps to GOT entry (initially next instruction in PLT)
3. PLT pushes relocation index and jumps to PLT[0]
4. PLT[0] calls dynamic linker resolver (_dl_runtime_resolve)
5. Resolver looks up function address and updates GOT entry
6. Resolver jumps to actual function
7. Subsequent calls jump directly to function through updated GOT
```

**Example:** Calling external function with PLT:

```nasm
section .text
extern printf

main:
    ; First call to printf
    lea rdi, [rel format]
    call printf wrt ..plt    ; Calls through PLT
    ; PLT will resolve printf address on first call
    ret

section .rodata
    format db "Hello", 0
```

**Disable lazy binding (BIND_NOW):**

```nasm
section .dynamic
    dq DT_BIND_NOW, 0    ; Resolve all symbols at load time
    dq DT_FLAGS, DF_BIND_NOW
```

**Symbol resolution with RTLD flags:**

When using `dlopen()`, resolution behavior is controlled:

```c
// RTLD_LAZY: Lazy binding (default)
// RTLD_NOW: Immediate binding
// RTLD_GLOBAL: Make symbols available to subsequently loaded libraries
// RTLD_LOCAL: Symbols not available for symbol resolution

void *handle = dlopen("libexample.so", RTLD_NOW | RTLD_GLOBAL);
void (*func)(void) = dlsym(handle, "function_name");
```

**Hash tables for symbol lookup:**

**Traditional ELF hash (`.hash`):**

```c
typedef struct {
    Elf64_Word nbucket;
    Elf64_Word nchain;
    Elf64_Word buckets[nbucket];
    Elf64_Word chains[nchain];
} Elf_Hash;

// Hash function
unsigned long elf_hash(const unsigned char *name) {
    unsigned long h = 0, g;
    while (*name) {
        h = (h << 4) + *name++;
        if (g = h & 0xf0000000)
            h ^= g >> 24;
        h &= ~g;
    }
    return h;
}
```

**GNU hash (`.gnu.hash`) - more efficient:**

```c
typedef struct {
    uint32_t nbuckets;
    uint32_t symoffset;
    uint32_t bloom_size;
    uint32_t bloom_shift;
    uint64_t bloom[bloom_size];
    uint32_t buckets[nbuckets];
    uint32_t chain[];
} Gnu_Hash;

// GNU hash function
uint32_t gnu_hash(const uint8_t *name) {
    uint32_t h = 5381;
    for (; *name; name++)
        h = (h << 5) + h + *name;
    return h;
}
```

**Library search paths (ELF):**

Dynamic linker searches for libraries in this order:

1. Directories in `DT_RPATH` (deprecated)
2. Directories in `LD_LIBRARY_PATH` environment variable
3. Directories in `DT_RUNPATH`
4. System default paths (`/lib`, `/usr/lib`, etc.)
5. Paths in `/etc/ld.so.conf`

**Interposition (symbol override):**

**[Inference]** ELF allows overriding library functions:

```c
// Override malloc
#define _GNU_SOURCE
#include <dlfcn.h>

void *malloc(size_t size) {
    static void *(*real_malloc)(size_t) = NULL;
    if (!real_malloc)
        real_malloc = dlsym(RTLD_NEXT, "malloc");
    
    // Custom behavior
    printf("malloc(%zu)\n", size);
    return real_malloc(size);
}
```

Using `LD_PRELOAD`:

```bash
LD_PRELOAD=/path/to/override.so ./program
```

### Mach-O Dynamic Linking

**Dynamic Linker Load Command:**

```c
struct dylinker_command {
    uint32_t cmd;           // LC_LOAD_DYLINKER
    uint32_t cmdsize;
    uint32_t name;          // Offset to path (usually /usr/lib/dyld)
};
```

**Dynamic Library Load Command:**

```c
struct dylib_command {
    uint32_t cmd;           // LC_LOAD_DYLIB, LC_LOAD_WEAK_DYLIB, etc.
    uint32_t cmdsize;
    struct dylib dylib;
};

struct dylib {
    uint32_t name;                  // Offset to library path
    uint32_t timestamp;
    uint32_t current_version;
    uint32_t compatibility_version;
};
```

**Two-level namespace:**

**[Inference]** Mach-O uses two-level namespaces (library + symbol) to avoid conflicts:

```
Symbol reference: libSystem.dylib::_printf
Not just: _printf
```

This prevents symbol name collisions between different libraries.

**dyld (Dynamic Linker) operations:**

```
1. Load main executable
2. Parse load commands
3. Load dependent libraries recursively
4. Bind symbols (resolve undefined references)
5. Apply relocations
6. Run initializers
7. Transfer control to entry point
```

**Lazy symbol binding:**

Mach-O uses stub sections for lazy binding:

```c
// Symbol stub section
section "__TEXT,__stubs"
section "__TEXT,__stub_helper"

// Symbol pointer sections
section "__DATA,__la_symbol_ptr"   // Lazy symbol pointers
section "__DATA,__nl_symbol_ptr"   // Non-lazy symbol pointers
```

**Stub example:**

```nasm
; In __stubs section
_printf$stub:
    jmp *_printf$lazy_ptr(%rip)

; In __stub_helper section
_printf$stub_helper:
    lea r11, _printf$lazy_ptr(%rip)
    push r11
    jmp dyld_stub_binder

; In __la_symbol_ptr section
_printf$lazy_ptr:
    .quad _printf$stub_helper    ; Initially points to helper
```

**Binding information:**

Modern Mach-O uses compressed binding info:

```c
struct dyld_info_command {
    uint32_t cmd;               // LC_DYLD_INFO or LC_DYLD_INFO_ONLY
    uint32_t cmdsize;
    uint32_t rebase_off;        // Rebase information offset
    uint32_t rebase_size;
    uint32_t bind_off;          // Binding information offset
    uint32_t bind_size;
    uint32_t weak_bind_off;     // Weak binding information offset
    uint32_t weak_bind_size;
    uint32_t lazy_bind_off;     // Lazy binding information offset
    uint32_t lazy_bind_size;
    uint32_t export_off;        // Export information offset
    uint32_t export_size;
};
```

**Binding opcodes (compressed format):**

```c
#define BIND_OPCODE_DONE                    0x00
#define BIND_OPCODE_SET_DYLIB_ORDINAL_IMM   0x10
#define BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM 0x40
#define BIND_OPCODE_SET_TYPE_IMM            0x50
#define BIND_OPCODE_SET_ADDEND_SLEB         0x60
#define BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB 0x70
#define BIND_OPCODE_ADD_ADDR_ULEB           0x80
#define BIND_OPCODE_DO_BIND                 0x90
#define BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB   0xA0
#define BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED 0xB0
#define BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB 0xC0
```

**dyld shared cache:**

**[Unverified]** macOS/iOS optimize system libraries using shared cache:

- Pre-linked system libraries in `/System/Library/dyld/`
- Symbols pre-bound for faster loading
- Shared across all processes
- Reduces memory footprint and launch time

**dlopen/dlsym on macOS:**

```c
#include <dlfcn.h>

// Load library
void *handle = dlopen("/path/to/library.dylib", RTLD_LAZY | RTLD_LOCAL);

// Get symbol
void (*func)(void) = dlsym(handle, "function_name");

// Clean up
dlclose(handle);
```

**Weak linking:**

**[Inference]** Mach-O supports weak references for optional symbols:

```nasm
; Weak reference to optional function
extern _optional_function
weak _optional_function

call_optional:
    lea rax, [_optional_function]
    test rax, rax
    jz not_available
    call _optional_function
not_available:
    ret
```

### Comparison of Dynamic Linking Approaches

**Key Points:**

**Symbol resolution:**

- **Windows**: Import by name or ordinal through IAT, explicit DLL specification
- **Linux/ELF**: Hash-based symbol lookup, searches all loaded libraries
- **macOS/Mach-O**: Two-level namespace (library + symbol), prevents conflicts

**Lazy binding:**

- **Windows**: Optional delay-load imports
- **Linux/ELF**: PLT/GOT mechanism, controlled by `DT_BIND_NOW`
- **macOS/Mach-O**: Stub sections with lazy symbol pointers

**Symbol visibility:**

- **Windows**: Explicit exports via `.def` files or `__declspec(dllexport)`
- **Linux/ELF**: Visibility attributes (default, hidden, protected)
- **macOS/Mach-O**: Export tries, visibility attributes

**Runtime loading:**

- **Windows**: `LoadLibrary`/`GetProcAddress`
- **Linux/ELF**: `dlopen`/`dlsym`
- **macOS/Mach-O**: `dlopen`/`dlsym` (same as ELF)

**Library versioning:**

- **Windows**: File version resources, side-by-side assemblies
- **Linux/ELF**: SONAME versioning, symbol versioning
- **macOS/Mach-O**: Compatibility version, current version in dylib command

**Security features:**

- **Windows**: ASLR via base relocations, DEP, Control Flow Guard
- **Linux/ELF**: ASLR with PIE, RELRO (relocation read-only), BIND_NOW
- **macOS/Mach-O**: ASLR, code signing requirements, library validation

**Example:** Position-independent executable (PIE) compilation:

```bash
