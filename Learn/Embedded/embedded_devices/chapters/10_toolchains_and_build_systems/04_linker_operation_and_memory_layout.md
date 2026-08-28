## Linker Operation and Memory Layout

### Overview

This content examines the linker's internal operation in more mechanical depth than the linker-scripts content covered — that earlier material focused on *writing* linker scripts (the `MEMORY`/`SECTIONS` syntax and VMA/LMA concepts); this content focuses on what the linker (`arm-none-eabi-ld`, invoked via `gcc` per the GCC-toolchains content) actually *does* internally when it processes object files and a linker script: symbol resolution, relocation, garbage collection, and the multi-pass structure of the linking process itself.

### The Linker's Core Job: Combining Relocatable Object Files

Each object file (`.o`) produced by the assembler (per the assembler-basics content) is **relocatable** — it contains machine code and data, but many addresses within it are not yet finalized, because the compiler/assembler processing a single translation unit has no visibility into where that code will ultimately sit in the final combined binary, or where symbols defined in *other* object files live. The linker's job is to resolve all of this into a single, fully-addressed executable.

Three core operations accomplish this:

1. **Symbol resolution**: matching every symbol *reference* (a function call to `hal_gpio_write`, a variable access to `_sdata`) against exactly one symbol *definition*, across all input object files and libraries.
2. **Relocation**: once a symbol's final address is known, patching every place in the machine code that referenced that symbol (via a placeholder value at compile/assemble time) with the actual resolved address.
3. **Section placement**: applying the `MEMORY`/`SECTIONS` rules from the linker script (covered in depth in the linker-scripts content) to decide where each input section from each object file lands in the final memory layout.

### Symbol Resolution in Detail

Every object file contains a symbol table listing the symbols it **defines** (functions and global/static variables with actual code/data in this file) and the symbols it **references** but does not define (external functions/variables it calls or uses, expected to be resolved by *some other* object file or library).



```
$ arm-none-eabi-nm main.o
00000000 T main
         U hal_gpio_write
00000010 D calibration_offset
00000020 B sensor_buffer
```

- `T` (text): a defined function, resolved to an address within this object file.
- `D` (data): a defined initialized global/static variable (destined for `.data`, per the linker-scripts content's VMA/LMA discussion).
- `B` (BSS): a defined zero-initialized/uninitialized variable (destined for `.bss`).
- `U` (undefined): a *referenced but not defined* symbol — `main.o` calls `hal_gpio_write` but does not itself contain its implementation; the linker must find a `T`-type (or similar) definition for `hal_gpio_write` in some other input object file or library, or the link fails with an "undefined reference" error.

**[Inference]** The extremely common "undefined reference to `X`" linker error that most embedded (and general C/C++) developers encounter is precisely this: the linker completed its scan of all provided object files and libraries and never found a matching `T`/`D`/`B`-type definition for a symbol some object file marked `U` (referenced) — the fix is invariably either supplying the missing object file/library that defines it, correcting a name/signature mismatch (particularly relevant given the `extern "C"`/name-mangling discussion in the interoperability content, where a missing `extern "C"` on one side of a C/C++ boundary produces exactly this class of error due to mismatched mangled names), or, in genuinely unimplemented-stub cases, providing an implementation.

### One-Definition Rule and Multiple-Definition Errors

Symmetrically, if *more than one* input object file defines the *same* global symbol (two files each defining a non-`static` function or variable of the same name), the linker reports a "multiple definition" error — a direct enforcement, at link time, of C/C++'s One Definition Rule for non-`static`/non-`inline` symbols.

**[Inference]** This is one reason `static` (internal linkage, file-scope-only) is generally preferred for helper functions and variables not intended for use outside their defining translation unit — beyond the encapsulation/readability benefit, it also prevents an accidental name collision between, say, a locally-named `init()` helper in two different `.c` files from producing a multiple-definition link error, since `static` symbols are invisible to the linker's cross-file symbol resolution entirely (they never appear as `T`/`D`/`B` in the global symbol table other files can reference).

### Static Libraries (`.a` archives) and Selective Linking

A static library (`.a` file, an "archive") is a bundle of multiple `.o` object files, with an important linking-behavior distinction from ordinary object files passed directly to the linker: **object files within a static library are only pulled into the final binary if something already-included currently needs a symbol they define** — unlike object files listed directly on the link command line, which are always included in full regardless of whether anything references them.

**[Inference]** This selective-inclusion behavior is precisely why link-command *ordering* has historically mattered for static libraries with GNU `ld` in its traditional single-pass mode: if library A (containing a definition needed by library B) is listed *before* library B on the command line, the linker may have already finished considering A's contents (and decided not to pull in the needed object, since nothing *processed so far* referenced it yet) by the time it reaches B and discovers the actual need — producing an undefined-reference error purely due to ordering, resolvable by reordering the libraries or, in modern GNU `ld`, via `--start-group`/`--end-group` (or the equivalent behavior some linker configurations now apply by default) to force the linker to re-scan a group of archives until no further symbols can be resolved from them. This ordering-sensitivity is a frequently confusing aspect of static-library linking for developers newer to embedded/systems-level build configuration, precisely because it doesn't manifest with ordinary (non-archive) object files, where full inclusion is unconditional.

### Garbage Collection: `--gc-sections` in Detail

The `-ffunction-sections -fdata-sections` compiler flags (introduced in the GCC-toolchains content) cause the compiler to place each function and global/static variable into its *own* individually named section, rather than the default behavior of merging all functions into one shared `.text` section and all data into shared `.data`/`.bss` sections. This per-symbol sectioning is what makes the linker's `--gc-sections` option effective: with everything in shared sections, the linker can only discard or keep an entire section as a unit (all-or-nothing); with individual per-symbol sections, it can discard precisely the unreferenced ones.

**[Inference]** The mechanism `--gc-sections` uses is a reachability analysis starting from explicitly-declared **entry points** (the reset vector/entry symbol, and anything marked with `KEEP()` in the linker script, per the linker-scripts content's discussion of protecting the interrupt vector table from exactly this process) — any section not transitively reachable by following symbol references from those roots is discarded from the final binary, directly reducing flash footprint for genuinely unused code/data (common when linking against a large vendor SDK or standard library where only a small fraction of provided functionality is actually used by a given project). This is precisely why the vector table specifically requires `KEEP()`: from the linker's reachability analysis alone, nothing in ordinary application code *references* the vector table by a normal symbol reference (it's read directly by hardware at a fixed address on reset, not called via any instruction the linker can trace), so without `KEEP()` explicitly protecting it, `--gc-sections` would consider it unreachable and discard it — a directly boot-breaking outcome, consistent with the "device fails to boot" symptom table already given in the linker-scripts content.

### Relocation Types and the Relocatable-to-Executable Transformation

Before linking, an object file's machine code contains placeholder values (relocation entries) at every point referencing a symbol whose final address isn't yet known — the linker's relocation pass replaces each placeholder with the symbol's now-resolved final address, adjusted according to the specific relocation type (which encodes *how* the address should be encoded into that particular instruction — a full 32-bit absolute address, a PC-relative branch offset, or other target-specific encodings).



```
$ arm-none-eabi-readelf -r main.o
Relocation section '.rel.text'
Offset     Type            Sym. Name
00000004   R_ARM_CALL      hal_gpio_write
```

**[Inference]** This relocation-entry mechanism is what makes the earlier VMA/LMA distinction (from the linker-scripts content) mechanically possible: the linker doesn't merely *decide* where a section goes, it actively rewrites every instruction/data value throughout the object code that referenced a symbol in that section, substituting the section's finally-assigned address — meaning the entire relocatable-to-executable transformation is a genuinely global, cross-referential pass over all input object files simultaneously, not a simple independent-per-file concatenation.

### Weak Symbols

A **weak symbol** is a symbol definition marked such that the linker will use it *only if no non-weak (strong) definition of the same symbol exists elsewhere* — if a strong definition is found, it silently overrides the weak one with no multiple-definition error (unlike the ordinary strong/strong collision case described above).

```c
/* Vendor SDK provides a weak default handler */
__attribute__((weak)) void SysTick_Handler(void) {
    while (1) { /* default: infinite loop if unimplemented */ }
}
```

```c
/* Application code overriding it — since this is a strong
   (non-weak) definition, the linker uses this instead of the
   vendor's weak default, with no conflict/error */
void SysTick_Handler(void) {
    tick_count++;
}
```

**[Inference]** This mechanism is the standard pattern vendor SDKs use for interrupt handler tables specifically because it lets a vendor provide a complete, always-linkable default implementation for *every* interrupt vector (so the vector table is always fully populated, even for interrupts the application never customizes) while allowing application code to selectively override only the specific handlers it actually cares about, simply by defining a same-named strong function anywhere in the application — without weak symbols, either every single handler would need an application-supplied definition (impractical for chips with dozens of interrupt sources), or the vendor's default table mechanism would need some other, more complex override mechanism entirely.

### The `.map` File: Reading the Linker's Own Account of Its Decisions

The `.map` file (generated via `-Wl,-Map=output.map`, introduced in the linker-scripts and GCC-toolchains content) is the linker's own detailed, human-readable record of every decision described above: which archive members were pulled in and why, where every symbol was ultimately placed, how much space each section consumed, and — for `--gc-sections` — frequently a list of which sections were discarded as unreachable.

**[Inference]** This makes the `.map` file the definitive diagnostic artifact for essentially every linker-level question raised throughout this series: confirming a `KEEP()`-protected section survived garbage collection, verifying a weak-symbol override actually took effect (checking which object file's definition of a given symbol was ultimately used), auditing unexpected code-size growth back to a specific pulled-in archive member, or confirming the VMA/LMA split for `.data`/`.ramfunc`-style sections landed as intended — direct inspection of the `.map` file is generally more reliable for answering "what did the linker actually do" than inferring it indirectly from the linker script's *intent* alone, since the map file reflects the linker's actual executed decisions given the real set of input object files and libraries for that specific build.

### Linker Processing Flow

===MERMAID_DIAGRAM===

flowchart TD

A["Object files (.o)\n+ static libraries (.a)"] --> B["Symbol table\ncollection: T/D/B\ndefined, U referenced"]

B --> C{"Every U symbol\nresolved to exactly\none definition?"}

C -->|"No definition found"| D["Undefined reference\nerror"]

C -->|"Multiple strong\ndefinitions found"| E["Multiple definition\nerror"]

C -->|"Resolved\n(incl. weak symbol\noverride rules)"| F["Section placement\nper linker script\nMEMORY/SECTIONS"]

F --> G{"--gc-sections\nenabled?"}

G -->|"Yes"| H["Reachability analysis\nfrom entry point +\nKEEP() roots"]

H --> I["Discard unreachable\nsections"]

G -->|"No"| J["Keep all sections"]

I --> K["Relocation pass:\npatch addresses into\nmachine code"]

J --> K

K --> L["Linked ELF +\n.map file"]

**Related Topics**

- Diagnosing "undefined reference" and "multiple definition" errors systematically
- `--start-group`/`--end-group` and modern GNU ld archive resolution behavior
- Weak symbol override patterns for vendor interrupt vector tables
- Reading and interpreting `.map` file sections for code-size auditing
- Relocation types and their target-architecture-specific encoding (ARM, RISC-V)
- COMDAT/identical-code-folding as a further linker-level size-reduction technique
- Static vs. dynamic linking tradeoffs (largely inapplicable to bare-metal, contrasted with embedded Linux userspace)