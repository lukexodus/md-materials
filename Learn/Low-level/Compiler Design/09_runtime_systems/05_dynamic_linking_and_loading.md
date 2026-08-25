## Dynamic Linking and Loading


Dynamic linking and loading enable programs to use shared libraries and load code at runtime. These mechanisms support modularity, reduce memory usage through sharing, and enable runtime extensibility.

### Shared Library Architecture

Shared libraries contain code and data that multiple programs can use simultaneously. The operating system loads shared libraries into memory once, allowing multiple processes to share the same library code while maintaining separate data segments.

Position-independent code (PIC) enables shared libraries to be loaded at different memory addresses in different processes. PIC uses relative addressing and indirection tables to avoid hardcoded memory addresses.

### Symbol Resolution

Symbol resolution determines the addresses of functions and variables referenced across module boundaries. Dynamic linking resolves these symbols at load time or runtime rather than during static compilation.

Global Offset Tables (GOT) and Procedure Linkage Tables (PLT) provide indirection mechanisms for accessing dynamically linked symbols. These tables are populated during symbol resolution to redirect references to actual symbol addresses.

### Lazy Loading

Lazy loading defers symbol resolution until symbols are actually used, reducing program startup time. Procedure linkage tables initially point to resolution stubs that perform symbol lookup on first use, then redirect future calls directly to resolved addresses.

**Key points** for dynamic linking:

- Enables sharing of library code between processes
- Supports runtime library updates without program recompilation
- May impact performance due to indirection overhead
- Requires careful handling of library versioning and compatibility

### Runtime Loading

Runtime loading allows programs to load and unload modules dynamically during execution. This capability supports plugin architectures, just-in-time compilation, and adaptive program behavior.

Runtime loading services typically provide:

- Loading modules from files or network sources
- Resolving symbols between loaded modules
- Managing module dependencies and initialization order
- Unloading modules and cleaning up associated resources

