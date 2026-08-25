## Structure Layout Compatibility


### Memory Layout Fundamentals

When interfacing assembly with high-level languages like C/C++, understanding structure layout is critical. The compiler arranges struct members in memory according to specific rules, and assembly code must respect this layout exactly.

**Basic structure in C:**

```c
struct Point {
    int x;      // 4 bytes
    int y;      // 4 bytes
};  // Total: 8 bytes
```

**Corresponding assembly access:**

```nasm
; Assuming rdi points to Point structure
mov eax, [rdi]      ; Load x (offset 0)
mov ebx, [rdi + 4]  ; Load y (offset 4)
```

### Alignment and Padding

Compilers insert padding to satisfy alignment requirements. Each data type typically aligns to its size (or the platform's natural alignment, whichever is smaller).

**C structure with padding:**

```c
struct Mixed {
    char a;     // 1 byte
    // 3 bytes padding
    int b;      // 4 bytes (requires 4-byte alignment)
    char c;     // 1 byte
    // 7 bytes padding (for next struct in array)
};  // Total: 16 bytes
```

**Memory layout:**

```
Offset  Content
0       a (char)
1-3     padding
4       b (int, 4 bytes)
8       c (char)
9-15    padding
```

**Assembly access:**

```nasm
; rdi points to Mixed structure
mov al, [rdi]       ; Load a (offset 0)
mov ebx, [rdi + 4]  ; Load b (offset 4)
mov al, [rdi + 8]   ; Load c (offset 8)
```

### Alignment Rules by Platform

**x86-64 typical alignment requirements:**

- `char`: 1-byte alignment
- `short`: 2-byte alignment
- `int`: 4-byte alignment
- `long`: 8-byte alignment (on 64-bit Unix/Linux)
- `long long`: 8-byte alignment
- `float`: 4-byte alignment
- `double`: 8-byte alignment
- Pointers: 8-byte alignment (on 64-bit)
- Structures: Aligned to their largest member's alignment

**Example with different types:**

```c
struct Aligned {
    char a;         // offset 0, 1 byte
    // 1 byte padding
    short b;        // offset 2, 2 bytes
    // 0 bytes padding (already 4-byte aligned)
    int c;          // offset 4, 4 bytes
    char d;         // offset 8, 1 byte
    // 7 bytes padding
    double e;       // offset 16, 8 bytes (requires 8-byte alignment)
};  // Total: 24 bytes
```

**Assembly access:**

```nasm
mov al, [rdi]           ; a at offset 0
movzx ax, word [rdi + 2]  ; b at offset 2
mov ecx, [rdi + 4]      ; c at offset 4
mov dl, [rdi + 8]       ; d at offset 8
movsd xmm0, [rdi + 16]  ; e at offset 16
```

### Packed Structures

Some compilers support packed structures that eliminate padding:

**C with packed attribute (GCC):**

```c
struct __attribute__((packed)) Packed {
    char a;     // offset 0
    int b;      // offset 1 (no padding!)
    char c;     // offset 5
};  // Total: 6 bytes
```

**Assembly access (careful with alignment):**

```nasm
mov al, [rdi]           ; a at offset 0
mov ebx, [rdi + 1]      ; b at offset 1 (unaligned access!)
mov cl, [rdi + 5]       ; c at offset 5
```

**Warning:** Unaligned accesses may be slower or cause faults on some architectures. On x86, they work but with performance penalties.

### Structure Member Offsets

To maintain compatibility, define offsets as constants:

```nasm
; Structure offsets for Point
POINT_X     equ 0
POINT_Y     equ 4
POINT_SIZE  equ 8

; Usage
mov eax, [rdi + POINT_X]
mov ebx, [rdi + POINT_Y]
```

For complex structures, calculate offsets accounting for alignment:

```nasm
; struct Employee {
;     char name[32];      // offset 0, 32 bytes
;     int id;             // offset 32, 4 bytes
;     double salary;      // offset 40, 8 bytes (needs 8-byte alignment)
; };

EMPLOYEE_NAME       equ 0
EMPLOYEE_ID         equ 32
; Padding: 4 bytes after id (32+4=36, next 8-byte boundary is 40)
EMPLOYEE_SALARY     equ 40
EMPLOYEE_SIZE       equ 48
```

### Nested Structures

Nested structures follow the same rules:

**C code:**

```c
struct Inner {
    int a;
    int b;
};

struct Outer {
    char x;
    // 3 bytes padding
    struct Inner inner;  // offset 4
    char y;
    // 3 bytes padding
};  // Total: 16 bytes
```

**Assembly access:**

```nasm
OUTER_X         equ 0
OUTER_INNER     equ 4
INNER_A         equ 0
INNER_B         equ 4
OUTER_Y         equ 12

; Access outer.x
mov al, [rdi + OUTER_X]

; Access outer.inner.a
mov eax, [rdi + OUTER_INNER + INNER_A]

; Access outer.inner.b
mov ebx, [rdi + OUTER_INNER + INNER_B]

; Access outer.y
mov cl, [rdi + OUTER_Y]
```

### Unions

Unions overlay all members at the same offset:

**C code:**

```c
union Data {
    int i;
    float f;
    char bytes[4];
};  // Size: 4 bytes (largest member)
```

**Assembly access:**

```nasm
; All members start at offset 0
mov eax, [rdi]      ; Access as int
movss xmm0, [rdi]   ; Access as float
mov al, [rdi]       ; Access bytes[0]
mov al, [rdi + 1]   ; Access bytes[1]
```

### Bit Fields

**[Inference]** Bit fields are compiler-specific in layout. Different compilers may pack bits differently, making portable assembly access difficult.

**C code:**

```c
struct Flags {
    unsigned int a : 3;  // 3 bits
    unsigned int b : 5;  // 5 bits
    unsigned int c : 8;  // 8 bits
};  // Packed into 4 bytes (int)
```

**Assembly access requires knowing compiler's bit layout:**

```nasm
; Assuming bits are packed from LSB (typical)
; a: bits 0-2
; b: bits 3-7
; c: bits 8-15

mov eax, [rdi]          ; Load entire int
and eax, 0x7            ; Extract a (bits 0-2)

mov ebx, [rdi]
shr ebx, 3              ; Shift b to position
and ebx, 0x1F           ; Extract b (bits 3-7)

mov ecx, [rdi]
shr ecx, 8              ; Shift c to position
and ecx, 0xFF           ; Extract c (bits 8-15)
```

### Array of Structures

When accessing arrays of structures, account for stride (structure size including padding):

```c
struct Point points[10];
```

**Assembly array access:**

```nasm
; Access points[i].x
; Assuming rsi = array base, rcx = index
imul rax, rcx, POINT_SIZE   ; Calculate offset
mov ebx, [rsi + rax + POINT_X]

; Or using LEA
lea rax, [rsi + rcx*8]      ; If POINT_SIZE = 8
mov ebx, [rax + POINT_X]
```

### Checking Structure Layout

To verify structure layout, use compiler-specific tools or offsetof:

**C code to print offsets:**

```c
#include <stddef.h>
#include <stdio.h>

struct MyStruct {
    char a;
    int b;
    double c;
};

printf("a offset: %zu\n", offsetof(struct MyStruct, a));
printf("b offset: %zu\n", offsetof(struct MyStruct, b));
printf("c offset: %zu\n", offsetof(struct MyStruct, c));
printf("size: %zu\n", sizeof(struct MyStruct));
```

### Platform-Specific Considerations

**Windows vs. Linux structure alignment:**

- Generally follow same rules for basic types
- Differences in `long` type: 4 bytes on Win64, 8 bytes on Linux x64
- Structure packing pragmas differ (`#pragma pack` on MSVC, `__attribute__((packed))` on GCC)

**Example: long type difference:**

```c
struct HasLong {
    long value;  // 4 bytes on Windows x64, 8 bytes on Linux x64
};
```

**Assembly must use conditional assembly or separate builds:**

```nasm
%ifdef WINDOWS
    HASLONG_SIZE equ 4
%else
    HASLONG_SIZE equ 8
%endif
```

**Key Points:**

- Structure members are laid out sequentially with alignment-based padding
- Each type aligns to boundaries (typically its size on x86-64)
- Structure alignment equals its largest member's alignment
- Padding inserted before members and at end of structure
- Packed structures eliminate padding but may cause unaligned access penalties
- [Inference] Bit field layout is compiler-specific and should be avoided for FFI when possible
- Use offsetof or similar mechanisms to verify layout between C and assembly

