## PE Format (Windows)


The Portable Executable (PE) format is the standard executable format for Windows operating systems. It evolved from the COFF (Common Object File Format) and is used for .exe, .dll, .sys, and other binary file types.

### PE File Structure

**DOS Header and Stub**: Every PE file begins with a DOS header (IMAGE_DOS_HEADER) starting with the signature "MZ" (0x4D5A). This header is followed by a small DOS program that displays "This program cannot be run in DOS mode" when executed in DOS. The DOS header contains `e_lfanew` at offset 0x3C, which points to the PE header.

**PE Signature**: At the offset specified by `e_lfanew`, the PE signature "PE\0\0" (0x50450000) identifies the file as a PE executable. This signature is immediately followed by the COFF File Header.

**COFF File Header**: The IMAGE_FILE_HEADER structure contains:

- Machine type (0x014C for x86, 0x8664 for x64, 0x01C4 for ARM)
- Number of sections
- Timestamp of creation
- Pointer to symbol table (usually zero in executables)
- Number of symbols
- Size of optional header
- Characteristics flags (executable, DLL, system file, etc.)

**Optional Header**: Despite its name, this header is required for executables. It exists in two forms: IMAGE_OPTIONAL_HEADER32 (for 32-bit) and IMAGE_OPTIONAL_HEADER64 (for 64-bit). Key fields include:

- Magic number (0x010B for PE32, 0x020B for PE32+)
- Linker version
- Size of code, initialized data, and uninitialized data
- Entry point address (RVA of the first instruction)
- Base address where the image should be loaded
- Section alignment (in memory) and file alignment (on disk)
- Operating system and subsystem versions
- Image size and header size
- Checksum (validated for drivers and system files)
- Subsystem type (GUI, console, native driver, etc.)
- DLL characteristics (dynamic base, NX compatible, etc.)
- Stack and heap reserve/commit sizes
- Number of data directories

**Data Directories**: The optional header ends with an array of IMAGE_DATA_DIRECTORY structures (typically 16 entries) pointing to important tables:

- Export table (functions exported by DLLs)
- Import table (functions imported from other DLLs)
- Resource table (icons, dialogs, strings, etc.)
- Exception table (structured exception handling data)
- Certificate table (digital signatures)
- Base relocation table (for ASLR support)
- Debug directory (debugging information)
- Thread Local Storage (TLS) directory
- Load configuration directory (SafeSEH, Control Flow Guard)
- Bound import table
- Import Address Table (IAT)
- Delay import descriptor
- COM+ runtime header (.NET metadata)

**Section Table**: An array of IMAGE_SECTION_HEADER structures, one per section. Each entry contains:

- Section name (8 bytes, null-padded, not null-terminated if full)
- Virtual size (size in memory)
- Virtual address (RVA where section is loaded)
- Size of raw data (size on disk)
- Pointer to raw data (file offset)
- Characteristics flags (readable, writable, executable, contains code/data)

### Common PE Sections

**.text**: Contains executable code. Typically marked as readable and executable but not writable. This is where the compiled machine instructions reside.

**.data**: Contains initialized global and static variables. Marked as readable and writable. Values are copied from the file to memory during loading.

**.rdata**: Contains read-only initialized data including constants, string literals, and import tables. Marked as readable only. [Inference] Modern compilers place import tables here to prevent tampering.

**.bss**: Contains uninitialized data that is zeroed at load time. [Inference] This section may not occupy disk space in the PE file, only virtual space.

**.rsrc**: Contains resources such as icons, bitmaps, dialogs, version information, and embedded files. Organized in a hierarchical tree structure with type, name, and language identifiers.

**.reloc**: Contains base relocation information used when the image cannot be loaded at its preferred base address. Contains a list of addresses that need adjustment.

**.idata**: Contains import information, though this is often merged into .rdata in modern executables. Lists DLLs and the functions imported from each.

**.edata**: Contains export information for DLLs. Lists function names, ordinals, and addresses that can be called by other modules.

**.pdata**: Contains exception handling information for x64 binaries, describing stack unwinding procedures for each function.

**.tls**: Contains Thread Local Storage initialization data and callback functions executed during thread creation/termination.

### Import Address Table (IAT)

The IAT is a crucial structure for dynamic linking. During loading, the Windows loader fills the IAT with actual addresses of imported functions:

**Before Loading**: IAT entries point to IMAGE_IMPORT_BY_NAME structures containing function names or ordinal values.

**After Loading**: The loader resolves function addresses from the specified DLLs and overwrites IAT entries with these addresses.

**Function Calls**: Code calls imported functions indirectly through the IAT: `CALL [IAT_entry]`. [Inference] This indirection enables runtime binding and DLL updates without recompiling.

### Relative Virtual Address (RVA)

RVAs are offsets from the image base address. When a PE file is loaded at its base address (e.g., 0x00400000), an RVA of 0x1000 corresponds to memory address 0x00401000. [Inference] RVAs enable position-independence within the binary, as relocations only need to adjust the base, not every internal reference.

### Address Space Layout Randomization (ASLR)

Modern PE files support ASLR through the IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE flag. When enabled, Windows loads the binary at a random base address, improving security. The relocation table enables address fixups when loaded at non-preferred addresses.

### PE Tools and Analysis

**dumpbin**: Microsoft tool for examining PE files. `dumpbin /headers file.exe` displays headers, `/imports` shows imports, `/exports` shows exports.

**PE-bear**: GUI tool for exploring PE structure, viewing sections, imports, exports, and resources.

**CFF Explorer**: Advanced PE editor allowing modification of headers and sections.

**PEview**: Displays PE structure in tree format, useful for learning the format.

**objdump**: GNU tool that can analyze PE files with `-x` (all headers) and `-d` (disassemble) options.

### PE Example Structure

```
[DOS Header - "MZ"]
[DOS Stub Program]
[PE Signature - "PE\0\0" at offset e_lfanew]
[COFF File Header]
[Optional Header]
    [Standard Fields]
    [Windows-Specific Fields]
    [Data Directories Array]
[Section Table]
    [.text section header]
    [.data section header]
    [.rdata section header]
    [.reloc section header]
[Section Data]
    [.text raw data - executable code]
    [.data raw data - initialized variables]
    [.rdata raw data - constants, imports]
    [.reloc raw data - relocation entries]
```

