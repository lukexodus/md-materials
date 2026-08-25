## Name Mangling


Name mangling (name decoration) is the encoding of function and variable names by compilers to include type information, namespace, and class membership in the symbol name. This enables function overloading and type-safe linking but creates challenges for assembly-C++ interoperability.

### Why Mangling Exists

**Function Overloading**: C++ allows multiple functions with the same name but different parameters. Mangling encodes parameter types into the symbol name to distinguish them.

**Type Safety**: The linker can verify that function declarations match definitions by comparing mangled names.

**Namespace Support**: Mangling includes namespace information to prevent symbol collisions.

**Template Instantiation**: Each template instantiation gets a unique mangled name.

### Mangling Schemes

**Itanium C++ ABI** (used by GCC, Clang on most platforms):

- Format starts with `_Z` followed by encoded name length and name
- `_Z3fooi` represents `foo(int)`
- `_Z3fooif` represents `foo(int, float)`
- `_ZN9namespace3fooEi` represents `namespace::foo(int)`
- `_ZN7MyClass6methodEv` represents `MyClass::method(void)`

**Microsoft Visual C++ Mangling**:

- Format uses `?` prefix followed by encoded names
- `?foo@@YAXH@Z` represents `void foo(int)`
- Encodes calling convention, return type, and parameter types

**C Mangling**: C does not mangle names (in most implementations). The symbol name is identical to the function name, sometimes with a platform-specific prefix like `_` on some systems.

### Demangling

Tools like `c++filt` (GNU) or `undname` (Microsoft) can demangle symbols:

```bash
$ c++filt _ZN7MyClass6methodEi
MyClass::method(int)
```

Compilers provide demangling APIs like `abi::__cxa_demangle()` for runtime demangling.

### extern "C" Linkage

The `extern "C"` declaration prevents name mangling, making C++ symbols compatible with C and assembly:

```cpp
extern "C" {
    void my_function(int x);  // Symbol: my_function (not mangled)
}
```

This is essential for assembly-C++ interoperability because assembly code uses literal symbol names. [Inference] Without `extern "C"`, assembly code cannot predict the mangled name the C++ compiler will generate.

### Name Mangling Challenges

**Non-Standard**: Mangling schemes vary between compilers and even versions. Code expecting a specific mangled name may break when changing compilers.

**Binary Compatibility**: Changes to function signatures cause different mangled names, breaking binary compatibility even if the ABI remains compatible.

**Debugging Complexity**: Stack traces and debugger output show mangled names, requiring demangling for readability.

