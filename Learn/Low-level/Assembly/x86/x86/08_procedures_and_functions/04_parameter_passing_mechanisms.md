## Parameter Passing Mechanisms


### Stack-Based Passing

The traditional method where parameters are pushed onto the stack before calling a procedure.

**Advantages:**

- Supports unlimited parameters
- Enables variable argument lists (va_args)
- Simple and consistent mechanism

**Disadvantages:**

- Memory access slower than registers
- Stack manipulation overhead
- Cache misses possible

**Implementation:**

```assembly
; Passing three parameters via stack
push dword 300      ; Third parameter
push dword 200      ; Second parameter
push dword 100      ; First parameter
call MyFunction
add esp, 12         ; Cleanup (cdecl)

MyFunction:
    push ebp
    mov ebp, esp
    ; Access: [ebp+8], [ebp+12], [ebp+16]
    mov eax, [ebp+8]
    add eax, [ebp+12]
    add eax, [ebp+16]
    pop ebp
    ret
```

**Accessing Stack Parameters:**

```assembly
; Stack frame:
; [ebp+16] = third parameter
; [ebp+12] = second parameter
; [ebp+8]  = first parameter
; [ebp+4]  = return address
; [ebp]    = saved ebp
; [ebp-4]  = first local variable
```

### Register-Based Passing

Modern conventions pass initial parameters in registers for performance.

**Advantages:**

- Much faster than memory access
- Reduces stack manipulation
- Better for frequently called small functions

**Disadvantages:**

- Limited number of registers
- Must save/restore if function uses those registers
- Cannot handle unlimited parameters

**Example - Custom Register Convention:**

```assembly
; Custom convention: first 3 params in EAX, EBX, ECX

; Caller:
mov eax, 100        ; First parameter
mov ebx, 200        ; Second parameter
mov ecx, 300        ; Third parameter
call FastAdd
; Result in EAX

; Callee:
FastAdd:
    add eax, ebx
    add eax, ecx
    ret             ; No stack cleanup needed
```

### Passing by Value vs Reference

**Passing by Value:** Copies the actual data onto the stack or into registers. Changes inside the function don't affect the original.

```assembly
; Pass integer by value
push dword 42
call ModifyValue
add esp, 4

ModifyValue:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ; Get value
    add eax, 10         ; Modify local copy
    pop ebp
    ret
```

**Passing by Reference (Pointer):** Passes the memory address of data. Changes affect the original data.

```assembly
section .data
    value dd 42

section .text
; Pass pointer to integer
push value              ; Push address
call ModifyByReference
add esp, 4

ModifyByReference:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]    ; Get pointer
    add dword [eax], 10 ; Modify value at address
    pop ebp
    ret

; After call, value = 52
```

### Passing Structures

**Small Structures (≤ register size):** Can be passed in registers or as immediate values.

```assembly
; Structure fits in 32 bits
struc Point
    .x: resw 1    ; 16 bits
    .y: resw 1    ; 16 bits
endstruc

; Pack into EAX and pass
mov ax, [point.x]
shl eax, 16
mov ax, [point.y]
push eax
call ProcessPoint
```

**Large Structures:** Pass by reference (pointer to structure).

```assembly
struc Rectangle
    .x:      resd 1
    .y:      resd 1
    .width:  resd 1
    .height: resd 1
endstruc

section .data
    rect: istruc Rectangle
        at Rectangle.x, dd 10
        at Rectangle.y, dd 20
        at Rectangle.width, dd 100
        at Rectangle.height, dd 50
    iend

section .text
; Pass pointer to structure
push rect
call ProcessRectangle
add esp, 4

ProcessRectangle:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]           ; Get pointer
    mov ebx, [eax + Rectangle.x]      ; Access member
    mov ecx, [eax + Rectangle.width]  ; Access member
    ; Process structure members
    pop ebp
    ret
```

### Passing Arrays

Arrays are always passed by reference (pointer to first element).

```assembly
section .data
    array dd 1, 2, 3, 4, 5
    array_size equ 5

section .text
; Pass array and size
push array_size
push array
call SumArray
add esp, 8

SumArray:
    push ebp
    mov ebp, esp
    push esi
    push ecx
    
    mov esi, [ebp+8]        ; Array pointer
    mov ecx, [ebp+12]       ; Array size
    xor eax, eax            ; Sum = 0
    
.loop:
    add eax, [esi]          ; Add current element
    add esi, 4              ; Move to next element (4 bytes)
    loop .loop
    
    pop ecx
    pop esi
    pop ebp
    ret
```

### Variable Argument Lists (Varargs)

Used in functions like `printf` that accept variable numbers of arguments.

**Implementation Requirements:**

- Must use cdecl (caller cleans stack)
- First parameter typically indicates count or format
- Arguments accessed sequentially from stack

**Example:**

```assembly
; int sum_all(int count, ...);
; Sum variable number of integers

section .text
global sum_all

; Call: sum_all(3, 10, 20, 30)
; Caller side:
push 30
push 20
push 10
push 3              ; Count
call sum_all
add esp, 16         ; Clean all parameters

; Callee side:
sum_all:
    push ebp
    mov ebp, esp
    push esi
    push ecx
    
    mov ecx, [ebp+8]        ; Get count
    lea esi, [ebp+12]       ; Point to first vararg
    xor eax, eax            ; Sum = 0
    
.loop:
    test ecx, ecx
    jz .done
    add eax, [esi]          ; Add current argument
    add esi, 4              ; Move to next argument
    dec ecx
    jmp .loop
    
.done:
    pop ecx
    pop esi
    pop ebp
    ret
```

### Return Value Mechanisms

**Integer/Pointer Returns:**

```assembly
; Return in EAX (32-bit) or RAX (64-bit)
GetValue:
    mov eax, 42
    ret
```

**64-bit Integer on 32-bit:**

```assembly
; Return 64-bit value in EDX:EAX
GetLargeValue:
    mov eax, 0x12345678    ; Low 32 bits
    mov edx, 0xABCDEF00    ; High 32 bits
    ret
```

**Floating Point:**

```assembly
; x87 FPU: return in ST(0)
GetFloat:
    fld dword [float_value]
    ret

; SSE: return in XMM0
GetDouble:
    movsd xmm0, [double_value]
    ret
```

**Structure Returns:**

- Small structures (≤8 bytes): returned in EAX/EDX or RAX
- Large structures: caller allocates space, passes pointer as hidden first parameter

```assembly
; Large structure return
; C prototype: Rectangle GetRect(void);

; Caller allocates space:
section .bss
    result: resb Rectangle_size

section .text
; Hidden parameter: pointer to result structure
push result
call GetRect
add esp, 4
; result now contains returned structure

; Callee fills structure at pointer:
GetRect:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]           ; Get result pointer
    mov dword [eax+Rectangle.x], 10
    mov dword [eax+Rectangle.y], 20
    mov dword [eax+Rectangle.width], 100
    mov dword [eax+Rectangle.height], 50
    pop ebp
    ret
```

**Key Points:**

- CALL pushes return address and jumps; RET pops and returns
- Near calls use offset only; far calls include segment (rarely used in modern flat memory models)
- Calling conventions standardize parameter passing, stack cleanup, and register preservation
- cdecl: caller cleans, supports varargs; stdcall: callee cleans, smaller code; fastcall: registers for speed
- x64 uses more registers: Windows uses RCX/RDX/R8/R9; System V uses RDI/RSI/RDX/RCX/R8/R9
- Parameters passed via stack (flexible, slower) or registers (fast, limited)
- Pass by value copies data; pass by reference uses pointers for modification
- Large structures and arrays always passed by reference
- Return values typically in EAX/RAX for integers, ST(0)/XMM0 for floats, EDX:EAX for 64-bit on 32-bit systems

**Related Topics:** Stack frames and local variables, Function prologue and epilogue patterns, Interoperability with high-level languages, Exception handling and stack unwinding, Tail call optimization, Position-independent code (PIC) for shared libraries

---

