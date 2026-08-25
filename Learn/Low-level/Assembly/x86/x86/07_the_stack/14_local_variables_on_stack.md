## Local Variables on Stack


Local variables are allocated on the stack within a function's stack frame, providing automatic memory management with function scope lifetime.

### Allocating Local Variables

Stack space is reserved by subtracting from RSP:

```nasm
function:
    push rbp
    mov rbp, rsp
    sub rsp, 32             ; Allocate 32 bytes for local variables
    
    ; Local variables:
    ; [rbp - 4]  : int var1 (4 bytes)
    ; [rbp - 8]  : int var2 (4 bytes)
    ; [rbp - 16] : long var3 (8 bytes)
    ; [rbp - 24] : long var4 (8 bytes)
    ; [rbp - 32] : char array[8] (8 bytes)
```

### Accessing Local Variables

Local variables are accessed using negative offsets from RBP (or positive offsets from RSP when no frame pointer):

```nasm
; With frame pointer
mov dword [rbp - 4], 100    ; var1 = 100
mov dword [rbp - 8], 200    ; var2 = 200
mov rax, [rbp - 16]         ; Load var3
mov [rbp - 24], rax         ; var4 = var3

; Without frame pointer (assuming RSP offset is known)
mov dword [rsp + 28], 100   ; var1 = 100 (assuming 32 bytes allocated)
mov dword [rsp + 24], 200   ; var2 = 200
```

### Local Arrays and Buffers

Arrays are allocated contiguously on the stack:

```c
// C code
void function() {
    char buffer[256];
    int array[10];
    // ...
}
```

```nasm
; Assembly equivalent
function:
    push rbp
    mov rbp, rsp
    sub rsp, 304            ; 256 + 40 + 8 (padding for alignment)
    
    ; buffer at [rbp - 256]
    ; array at [rbp - 296]  (after buffer)
    
    ; Accessing buffer[i]
    lea rax, [rbp - 256]    ; Load buffer base address
    mov rbx, [index]        ; Load index
    mov byte [rax + rbx], 'A'  ; buffer[i] = 'A'
    
    ; Accessing array[i]
    lea rax, [rbp - 296]    ; Load array base address
    mov rbx, [index]
    mov dword [rax + rbx*4], 100  ; array[i] = 100
```

### Structure Variables on Stack

Structure (struct) variables are laid out according to their member alignment:

```c
// C code
struct Point {
    int x;      // offset 0, size 4
    int y;      // offset 4, size 4
};

void function() {
    struct Point p;
    p.x = 10;
    p.y = 20;
}
```

```nasm
; Assembly equivalent
function:
    push rbp
    mov rbp, rsp
    sub rsp, 16             ; 8 bytes for struct + 8 for alignment
    
    ; p.x at [rbp - 8]
    ; p.y at [rbp - 4]
    
    mov dword [rbp - 8], 10     ; p.x = 10
    mov dword [rbp - 4], 20     ; p.y = 20
```

### Variable Lifetime and Scope

Stack local variables exist only during function execution:

1. **Allocation**: Space reserved during function prologue
2. **Usage**: Variables accessed throughout function body
3. **Deallocation**: Space automatically reclaimed during epilogue

Variables in different stack frames are independent, enabling recursion:

```nasm
recursive_function:
    push rbp
    mov rbp, rsp
    sub rsp, 16             ; Each recursive call gets its own locals
    
    mov dword [rbp - 4], 42 ; This local is independent per call
    
    ; Recursive call
    call recursive_function ; Creates new stack frame
    
    ; Original local still intact after return
    mov eax, [rbp - 4]      ; Still 42
    
    leave
    ret
```

### Initialization Considerations

Stack local variables are **not automatically initialized** to zero. They contain whatever data was previously at those memory locations:

```nasm
function:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    
    ; [rbp - 4] contains garbage (uninitialized)
    mov eax, [rbp - 4]      ; Reads unpredictable value
    
    ; Must explicitly initialize
    mov dword [rbp - 4], 0  ; Properly initialized to 0
```

This differs from global variables, which are typically zero-initialized by the loader.

### Large Local Allocations

Large local allocations require special consideration:

```nasm
function_with_large_buffer:
    push rbp
    mov rbp, rsp
    sub rsp, 8192           ; Allocate 8KB buffer
    
    ; Potential issue: may exceed single stack page
    ; May require stack probing on some platforms
```

On Windows, stack probing ensures all intermediate stack pages are touched to trigger page allocation. Linux typically handles this through page fault handling [Inference about OS memory management behavior].

