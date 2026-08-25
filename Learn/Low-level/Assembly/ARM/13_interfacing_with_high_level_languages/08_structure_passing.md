## Structure Passing


Structures are passed according to size and composition rules.

**Small structures (≤ 16 bytes):**

```c
// C structure
struct Point {
    int x;
    int y;
};

struct Point add_points(struct Point a, struct Point b) {
    struct Point result;
    result.x = a.x + b.x;
    result.y = a.y + b.y;
    return result;
}
```

```asm
; Assembly implementation
; struct Point is 8 bytes (two ints)
; Passed in single register X0 (a) and X1 (b)
; Returned in X0

.global add_points
add_points:
    ; X0 = {a.x (W0), a.y (bits [63:32])}
    ; X1 = {b.x (W1), b.y (bits [63:32])}
    
    ; Extract fields
    ; a.x in W0 (lower 32 bits)
    LSR X2, X0, #32             ; a.y in W2
    ; b.x in W1
    LSR X3, X1, #32             ; b.y in W3
    
    ; Add
    ADD W4, W0, W1              ; result.x = a.x + b.x
    ADD W5, W2, W3              ; result.y = a.y + b.y
    
    ; Pack result
    ORR X0, X4, X5, LSL #32     ; X0 = {result.x, result.y}
    RET

; Alternative: Structure passed by components
; If structure has 2 integer members, may be in W0, W1
add_points_v2:
    ; W0 = a.x, W1 = a.y, W2 = b.x, W3 = b.y
    ADD W0, W0, W2              ; result.x
    ADD W1, W1, W3              ; result.y
    ; Return in W0, W1
    RET
```

**Structure with mixed types:**

```c
struct Mixed {
    int i;
    float f;
};

float process_mixed(struct Mixed m) {
    return m.i + m.f;
}
```

```asm
; Mixed int/float structure
; Passed in X0 (int in W0, float in bits [63:32])
process_mixed:
    ; Extract int (lower 32 bits)
    ; W0 already has the int
    
    ; Extract float (upper 32 bits)
    LSR X1, X0, #32
    FMOV S1, W1                 ; Move to float register
    
    ; Convert int to float and add
    SCVTF S0, W0                ; Convert int to float
    FADD S0, S0, S1             ; Add
    
    RET
```

**Medium structures (> 16 bytes, ≤ 4 members):**

```c
struct Vector4 {
    float x, y, z, w;
};

struct Vector4 add_vectors(struct Vector4 a, struct Vector4 b) {
    struct Vector4 result;
    result.x = a.x + b.x;
    result.y = a.y + b.y;
    result.z = a.z + b.z;
    result.w = a.w + b.w;
    return result;
}
```

```asm
; Structure of 4 floats (16 bytes total)
; Can be passed in SIMD register V0, V1
; Or in S0-S3, S4-S7 depending on ABI variant

; Method 1: SIMD registers (HFA - Homogeneous Float Aggregate)
add_vectors_simd:
    ; V0 = {a.x, a.y, a.z, a.w} as .4S
    ; V1 = {b.x, b.y, b.z, b.w} as .4S
    
    FADD V0.4S, V0.4S, V1.4S    ; Vector add all components
    ; Result in V0
    RET

; Method 2: Individual float registers
add_vectors_regs:
    ; S0 = a.x, S1 = a.y, S2 = a.z, S3 = a.w
    ; S4 = b.x, S5 = b.y, S6 = b.z, S7 = b.w
    
    FADD S0, S0, S4             ; result.x
    FADD S1, S1, S5             ; result.y
    FADD S2, S2, S6             ; result.z
    FADD S3, S3, S7             ; result.w
    ; Return in S0-S3
    RET
```

**Large structures (> 16 bytes, non-HFA):**

```c
struct LargeData {
    long a, b, c, d, e;         // 40 bytes
};

struct LargeData process_large(struct LargeData data) {
    data.a += 1;
    data.b += 2;
    data.c += 3;
    data.d += 4;
    data.e += 5;
    return data;
}
```

```asm
; Large structures passed by reference
; X0 = pointer to input structure
; X8 = pointer to return value location (caller-allocated)
process_large:
    ; Load structure members
    LDP X1, X2, [X0]            ; a, b
    LDP X3, X4, [X0, #16]       ; c, d
    LDR X5, [X0, #32]           ; e
    
    ; Modify
    ADD X1, X1, #1
    ADD X2, X2, #2
    ADD X3, X3, #3
    ADD X4, X4, #4
    ADD X5, X5, #5
    
    ; Store to return location (X8)
    STP X1, X2, [X8]
    STP X3, X4, [X8, #16]
    STR X5, [X8, #32]
    
    ; Return pointer to result
    MOV X0, X8
    RET

; Calling large structure function
call_large:
    STP X29, X30, [SP, #-96]!
    MOV X29, SP
    
    ; Allocate structure on stack
    ADD X0, SP, #16             ; Input structure
    ADD X8, SP, #56             ; Return structure
    
    ; Initialize input
    MOV X1, #10
    STR X1, [X0]                ; data.a = 10
    ; ... initialize other members
    
    BL process_large
    
    ; Result now in [SP, #56]
    LDR X0, [SP, #56]           ; Access result.a
    
    LDP X29, X30, [SP], #96
    RET
```

**Homogeneous aggregates (HFA/HVA):**

```c
// Homogeneous Float Aggregate (HFA)
struct FloatArray {
    float data[4];
};

// Homogeneous Vector Aggregate (HVA)
struct Vec2Array {
    struct { float x, y; } vecs[4];
};
```

```asm
; HFA: Up to 4 float members (or arrays totaling ≤4 floats)
; Passed in S0-S3 or as a SIMD vector

process_hfa:
    ; S0-S3 contain the 4 floats
    FADD S0, S0, S1
    FADD S2, S2, S3
    FADD S0, S0, S2
    ; Return sum in S0
    RET

; HVA: Up to 4 vector members
; Passed in V0-V3

process_hva:
    ; V0-V3 each contain {x, y} as .2S
    FADD V0.2S, V0.2S, V1.2S
    FADD V2.2S, V2.2S, V3.2S
    FADD V0.2S, V0.2S, V2.2S
    ; Return in V0
    RET
```

**Bit fields in structures:**

```c
struct BitFields {
    unsigned int a : 5;
    unsigned int b : 11;
    unsigned int c : 16;
};

void set_bitfields(struct BitFields *bf, int a, int b, int c) {
    bf->a = a;
    bf->b = b;
    bf->c = c;
}
```

```asm
; Bit field structure (32 bits total)
; Layout: [a:5][b:11][c:16]
; Offset:  0-4   5-15  16-31

    ; X0 = bf pointer
    ; W1 = a (value to set in bits 0-4)
    ; W2 = b (value to set in bits 5-15)
    ; W3 = c (value to set in bits 16-31)
    
    ; Load current value
    LDR W4, [X0]
    
    ; Clear and set field 'a' (bits 0-4)
    BIC W4, W4, #0x1F           ; Clear bits 0-4
    AND W5, W1, #0x1F           ; Mask input to 5 bits
    ORR W4, W4, W5              ; Set bits 0-4
    
    ; Clear and set field 'b' (bits 5-15)
    MOV W5, #0x7FF              ; Mask for 11 bits
    BIC W4, W4, W5, LSL #5      ; Clear bits 5-15
    AND W5, W2, #0x7FF          ; Mask input to 11 bits
    ORR W4, W4, W5, LSL #5      ; Set bits 5-15
    
    ; Clear and set field 'c' (bits 16-31)
    MOV W5, #0xFFFF
    BIC W4, W4, W5, LSL #16     ; Clear bits 16-31
    AND W5, W3, #0xFFFF         ; Mask input to 16 bits
    ORR W4, W4, W5, LSL #16     ; Set bits 16-31
    
    ; Store result
    STR W4, [X0]
    RET

; Extract bit fields
get_bitfields:
    ; X0 = bf pointer
    ; Returns: W0 = a, W1 = b, W2 = c
    
    LDR W3, [X0]                ; Load structure
    
    ; Extract 'a' (bits 0-4)
    AND W0, W3, #0x1F
    
    ; Extract 'b' (bits 5-15)
    UBFX W1, W3, #5, #11        ; Extract 11 bits at offset 5
    
    ; Extract 'c' (bits 16-31)
    LSR W2, W3, #16             ; Shift right 16 bits
    
    RET
```

**Packed structures (alignment override):**

```c
struct __attribute__((packed)) PackedData {
    char c;         // 1 byte
    int i;          // 4 bytes (normally would be aligned to 4-byte boundary)
    short s;        // 2 bytes
};  // Total: 7 bytes (not 12)

void access_packed(struct PackedData *p) {
    p->i = 42;
}
```

```asm
; Packed structure - unaligned access
access_packed:
    ; X0 = pointer to packed structure
    ; Offset of 'i' is 1 (after char), not aligned
    
    MOV W1, #42
    
    ; Method 1: Byte-by-byte access (safe on all ARM)
    STRB W1, [X0, #1]           ; Store byte 0
    LSR W2, W1, #8
    STRB W2, [X0, #2]           ; Store byte 1
    LSR W2, W1, #16
    STRB W2, [X0, #3]           ; Store byte 2
    LSR W2, W1, #24
    STRB W2, [X0, #4]           ; Store byte 3
    RET

; Method 2: Unaligned access (ARMv8 supports this)
access_packed_unaligned:
    MOV W1, #42
    STR W1, [X0, #1]            ; Unaligned store (slower but works)
    RET

; Reading from packed structure
read_packed:
    ; Method 1: Byte-by-byte
    LDRB W0, [X0, #1]           ; Byte 0
    LDRB W1, [X0, #2]           ; Byte 1
    LDRB W2, [X0, #3]           ; Byte 2
    LDRB W3, [X0, #4]           ; Byte 3
    
    ORR W0, W0, W1, LSL #8      ; Combine bytes
    ORR W0, W0, W2, LSL #16
    ORR W0, W0, W3, LSL #24
    RET

; Method 2: Unaligned load
read_packed_unaligned:
    LDR W0, [X0, #1]            ; Unaligned load
    RET
```

**Nested structures:**

```c
struct Inner {
    int x;
    int y;
};

struct Outer {
    struct Inner a;
    struct Inner b;
    int z;
};

void process_nested(struct Outer *out) {
    out->a.x += out->b.x;
    out->a.y += out->b.y;
    out->z = out->a.x + out->a.y;
}
```

```asm
; Nested structure layout:
; Offset 0: a.x (4 bytes)
; Offset 4: a.y (4 bytes)
; Offset 8: b.x (4 bytes)
; Offset 12: b.y (4 bytes)
; Offset 16: z (4 bytes)
; Total: 20 bytes

process_nested:
    ; X0 = pointer to Outer
    
    ; Load a.x, a.y
    LDP W1, W2, [X0]            ; a.x, a.y
    
    ; Load b.x, b.y
    LDP W3, W4, [X0, #8]        ; b.x, b.y
    
    ; Add
    ADD W1, W1, W3              ; a.x += b.x
    ADD W2, W2, W4              ; a.y += b.y
    
    ; Store updated a
    STP W1, W2, [X0]
    
    ; Calculate z
    ADD W5, W1, W2              ; z = a.x + a.y
    STR W5, [X0, #16]           ; Store z
    
    RET
```

**Union handling:**

```c
union Value {
    int i;
    float f;
    char bytes[4];
};

void set_union_int(union Value *v, int x) {
    v->i = x;
}

float get_union_float(union Value *v) {
    return v->f;
}
```

```asm
; Union - all members share same memory
; Size = size of largest member (4 bytes)

set_union_int:
    ; X0 = pointer to union, W1 = value
    STR W1, [X0]                ; Store as int
    RET

get_union_float:
    ; X0 = pointer to union
    LDR W0, [X0]                ; Load 4 bytes
    FMOV S0, W0                 ; Move to float register
    RET

; Type punning through union
type_pun:
    ; Reinterpret float bits as int
    ; S0 = float input
    
    SUB SP, SP, #16             ; Allocate stack space
    STR S0, [SP]                ; Store as float
    LDR W0, [SP]                ; Load as int
    ADD SP, SP, #16
    RET
```

**Complex structures with mixed alignment:**

```c
struct Complex {
    char c;         // 1 byte, offset 0
    // 3 bytes padding
    int i;          // 4 bytes, offset 4
    double d;       // 8 bytes, offset 8 (needs 8-byte alignment)
    short s;        // 2 bytes, offset 16
    // 6 bytes padding at end for array alignment
};  // Total: 24 bytes
```

```asm
; Access complex structure with proper alignment
access_complex:
    ; X0 = pointer to Complex
    
    ; Load char (offset 0)
    LDRB W1, [X0]
    
    ; Load int (offset 4)
    LDR W2, [X0, #4]
    
    ; Load double (offset 8)
    LDR D0, [X0, #8]
    
    ; Load short (offset 16)
    LDRH W3, [X0, #16]
    
    ; Modify and store
    ADD W1, W1, #1
    STRB W1, [X0]
    
    ADD W2, W2, #10
    STR W2, [X0, #4]
    
    FADD D0, D0, D0
    STR D0, [X0, #8]
    
    ADD W3, W3, #100
    STRH W3, [X0, #16]
    
    RET

; Calculate structure size and alignment at runtime
sizeof_complex:
    MOV X0, #24                 ; sizeof(struct Complex)
    RET

alignof_complex:
    MOV X0, #8                  ; alignof(struct Complex) = 8 (for double)
    RET
```

**Flexible array member (FAM):**

```c
struct FlexArray {
    int count;
    int data[];     // Flexible array member
};

void init_flex_array(struct FlexArray *arr, int count) {
    arr->count = count;
    for (int i = 0; i < count; i++) {
        arr->data[i] = i;
    }
}
```

```asm
; Flexible array member - array at end of structure
init_flex_array:
    ; X0 = pointer to FlexArray
    ; W1 = count
    
    STP X29, X30, [SP, #-16]!
    
    ; Store count
    STR W1, [X0]                ; arr->count = count
    
    ; Initialize loop
    MOV W2, #0                  ; i = 0
    ADD X3, X0, #4              ; Pointer to arr->data
    
    CMP W1, #0
    B.LE done
    
loop:
    STR W2, [X3], #4            ; data[i] = i, advance pointer
    ADD W2, W2, #1              ; i++
    CMP W2, W1
    B.LT loop
    
done:
    LDP X29, X30, [SP], #16
    RET

; Allocate flexible array structure
; Size = sizeof(struct) + count * sizeof(element)
alloc_flex_array:
    ; W0 = count
    STP X29, X30, [SP, #-16]!
    
    ; Calculate size: 4 (count) + count * 4 (data)
    LSL W1, W0, #2              ; count * 4
    ADD W0, W1, #4              ; Total size
    
    ; Call malloc
    BL malloc                   ; X0 = allocated pointer
    
    LDP X29, X30, [SP], #16
    RET
```

**Structure copying:**

```c
struct Data {
    long values[10];
};

void copy_struct(struct Data *dest, const struct Data *src) {
    *dest = *src;
}
```

```asm
; Efficient structure copy (80 bytes)
copy_struct:
    ; X0 = dest, X1 = src
    
    ; Copy using register pairs (16 bytes at a time)
    LDP X2, X3, [X1]
    STP X2, X3, [X0]
    
    LDP X2, X3, [X1, #16]
    STP X2, X3, [X0, #16]
    
    LDP X2, X3, [X1, #32]
    STP X2, X3, [X0, #32]
    
    LDP X2, X3, [X1, #48]
    STP X2, X3, [X0, #48]
    
    LDP X2, X3, [X1, #64]
    STP X2, X3, [X0, #64]
    
    RET

; Generic memcpy for large structures
memcpy_struct:
    ; X0 = dest, X1 = src, X2 = size
    
    CMP X2, #0
    B.LE done
    
    ; Copy in 16-byte chunks
copy_loop:
    CMP X2, #16
    B.LT copy_remaining
    
    LDP X3, X4, [X1], #16
    STP X3, X4, [X0], #16
    SUB X2, X2, #16
    B copy_loop
    
copy_remaining:
    ; Copy remaining bytes
    CBZ X2, done
    
byte_loop:
    LDRB W3, [X1], #1
    STRB W3, [X0], #1
    SUBS X2, X2, #1
    B.NE byte_loop
    
done:
    RET

; Optimized with SIMD (copy 16 bytes per iteration)
memcpy_simd:
    ; X0 = dest, X1 = src, X2 = size
    
    CMP X2, #16
    B.LT small_copy
    
simd_loop:
    LDR Q0, [X1], #16           ; Load 128 bits
    STR Q0, [X0], #16           ; Store 128 bits
    SUBS X2, X2, #16
    B.GE simd_loop
    
    ADD X2, X2, #16             ; Adjust for overshoot
    
small_copy:
    CBZ X2, exit
    
small_loop:
    LDRB W3, [X1], #1
    STRB W3, [X0], #1
    SUBS X2, X2, #1
    B.NE small_loop
    
exit:
    RET
```

**Structure with function pointers (vtables):**

```c
struct Operations {
    int (*add)(int, int);
    int (*subtract)(int, int);
    int (*multiply)(int, int);
};

int call_operation(struct Operations *ops, int a, int b) {
    return ops->add(a, b);
}
```

```asm
; Structure containing function pointers
; Offset 0: add pointer
; Offset 8: subtract pointer
; Offset 16: multiply pointer

call_operation:
    ; X0 = ops pointer
    ; W1 = a, W2 = b
    
    STP X29, X30, [SP, #-16]!
    
    ; Load function pointer
    LDR X3, [X0]                ; ops->add
    
    ; Setup arguments (already in W1, W2)
    MOV W0, W1                  ; First arg
    MOV W1, W2                  ; Second arg
    
    ; Call through pointer
    BLR X3                      ; Indirect call
    
    ; Result in W0
    LDP X29, X30, [SP], #16
    RET

; Implement operations
add_impl:
    ADD W0, W0, W1
    RET

subtract_impl:
    SUB W0, W0, W1
    RET

multiply_impl:
    MUL W0, W0, W1
    RET

; Initialize operations structure
init_operations:
    ; X0 = pointer to Operations structure
    
    ADRP X1, add_impl
    ADD X1, X1, :lo12:add_impl
    STR X1, [X0]                ; ops->add = add_impl
    
    ADRP X1, subtract_impl
    ADD X1, X1, :lo12:subtract_impl
    STR X1, [X0, #8]            ; ops->subtract = subtract_impl
    
    ADRP X1, multiply_impl
    ADD X1, X1, :lo12:multiply_impl
    STR X1, [X0, #16]           ; ops->multiply = multiply_impl
    
    RET
```

**Interfacing with C++ classes:**

```cpp
class Calculator {
private:
    int value;
    
public:
    Calculator(int v);
    int add(int x);
    int get_value();
    virtual int compute();      // Virtual function
};
```

```asm
; C++ class layout:
; Offset 0: vtable pointer (if has virtual functions)
; Offset 8: member 'value'

; Constructor: Calculator::Calculator(int)
; Mangled name: _ZN10CalculatorC1Ei
_ZN10CalculatorC1Ei:
    ; X0 = this pointer
    ; W1 = v parameter
    
    ; Setup vtable pointer
    ADRP X2, _ZTV10Calculator   ; vtable address
    ADD X2, X2, :lo12:_ZTV10Calculator
    ADD X2, X2, #16             ; Skip typeinfo pointers
    STR X2, [X0]                ; Store vtable pointer
    
    ; Initialize member
    STR W1, [X0, #8]            ; this->value = v
    
    RET

; Member function: Calculator::add(int)
; Mangled name: _ZN10Calculator3addEi
_ZN10Calculator3addEi:
    ; X0 = this pointer
    ; W1 = x parameter
    
    LDR W2, [X0, #8]            ; Load this->value
    ADD W2, W2, W1              ; value + x
    STR W2, [X0, #8]            ; Store back
    MOV W0, W2                  ; Return new value
    RET

; Member function: Calculator::get_value()
; Mangled name: _ZN10Calculator9get_valueEv
_ZN10Calculator9get_valueEv:
    ; X0 = this pointer
    LDR W0, [X0, #8]            ; Return this->value
    RET

; Virtual function: Calculator::compute()
; Called through vtable
_ZN10Calculator7computeEv:
    ; X0 = this pointer
    LDR W0, [X0, #8]            ; Return this->value
    RET

; Call virtual function
call_virtual:
    ; X0 = Calculator object pointer
    STP X29, X30, [SP, #-16]!
    
    ; Load vtable pointer
    LDR X1, [X0]                ; vtable pointer
    
    ; Load function pointer from vtable
    LDR X2, [X1]                ; First virtual function
    
    ; Call through vtable
    BLR X2
    
    LDP X29, X30, [SP], #16
    RET

; Vtable layout (read-only data)
.section .rodata
.align 3
_ZTV10Calculator:
    .quad 0                     ; Offset to top
    .quad _ZTI10Calculator      ; Typeinfo pointer
    .quad _ZN10Calculator7computeEv  ; compute() function pointer
```

**Key Points:**

- Name mangling encodes type information in symbol names; C uses simple names while C++ mangles based on Itanium ABI conventions
- ABI compatibility requires following register conventions (X0-X7 for args, X19-X28 callee-saved) and 16-byte stack alignment
- Volatile registers (X0-X18) can be clobbered by calls; callee-saved registers (X19-X28) must be preserved
- Structure passing depends on size: ≤16 bytes in registers, HFA/HVA in SIMD registers, larger structures by reference with return location in X8
- Packed structures and bit fields require careful byte-level manipulation
- C++ classes add vtable pointers and name mangling complexity

[Inference] Specific ABI details may vary slightly between platforms (Linux, iOS, Windows) though all follow AAPCS64 baseline - platform-specific variations primarily affect system calls and dynamic linking.

[Inference] Compiler optimizations may pass structures differently than baseline ABI when inlining or using link-time optimization, but external interfaces must follow standard ABI for compatibility.

---

