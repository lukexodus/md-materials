## MSVC Inline Assembly Syntax


Microsoft Visual C++ uses a simpler but less flexible syntax for 32-bit x86 code.

### Basic MSVC Syntax

```c
__asm {
    mov eax, var1
    add eax, var2
    mov result, eax
}
```

Or single-line form:

```c
__asm mov eax, 5
```

### Direct Variable Access

MSVC inline assembly can directly reference C/C++ variables without explicit operand constraints:

```c
int x = 10, y = 20, sum;
__asm {
    mov eax, x
    add eax, y
    mov sum, eax
}
```

### MSVC Limitations

**[Unverified]** MSVC inline assembly has several restrictions:

- Not available for x64 targets (must use separate .asm files or intrinsics)
- No support for extended features like GCC's constraint system
- Limited optimization interaction

MSVC uses Intel syntax exclusively.

