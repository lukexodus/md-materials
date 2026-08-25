## Stack Frame Examples


### Simple Leaf Function

A leaf function (doesn't call other functions) with minimal stack usage:

```asm
add_numbers:
    ; Parameters in RDI (a) and RSI (b)
    ; No frame pointer needed
    MOV RAX, RDI
    ADD RAX, RSI
    RET                 ; 64-bit ABI, RAX contains result
```

This function uses no stack space at all, operating entirely in registers.

### Function with Local Variables

```asm
compute:
    PUSH RBP
    MOV RBP, RSP
    SUB RSP, 32         ; Allocate 32 bytes for locals
    
    ; Local variables:
    ; [RBP-8]:  local1
    ; [RBP-16]: local2
    ; [RBP-24]: local3
    ; [RBP-32]: local4
    
    MOV RAX, RDI        ; Use parameter
    IMUL RAX, RAX       ; Square it
    MOV [RBP-8], RAX    ; Store in local1
    
    MOV RBX, RSI        ; Second parameter
    ADD RBX, RBX        ; Double it
    MOV [RBP-16], RBX   ; Store in local2
    
    ; Compute result using locals
    MOV RAX, [RBP-8]
    ADD RAX, [RBP-16]
    
    MOV RSP, RBP
    POP RBP
    RET
```

### Function Calling Another Function

```asm
outer:
    PUSH RBP
    MOV RBP, RSP
    SUB RSP, 16         ; Allocate space
    PUSH RBX            ; Save callee-saved register
    
    MOV RBX, RDI        ; Save parameter in callee-saved register
    
    ; First call
    MOV RDI, RBX
    MOV RSI, 10
    CALL helper         ; Result in RAX
    MOV [RBP-8], RAX    ; Save result
    
    ; Second call
    MOV RDI, RBX
    MOV RSI, 20
    CALL helper
    
    ; Combine results
    ADD RAX, [RBP-8]
    
    POP RBX             ; Restore saved register
    MOV RSP, RBP
    POP RBP
    RET
```

### Function with Array Allocation

```asm
process_array:
    PUSH RBP
    MOV RBP, RSP
    
    ; Allocate space for 10 64-bit integers (80 bytes)
    ; Round to 16-byte alignment: 80 bytes
    SUB RSP, 80
    
    ; Initialize array
    XOR RCX, RCX        ; Counter
init_loop:
    MOV [RSP + RCX*8], RCX
    INC RCX
    CMP RCX, 10
    JL init_loop
    
    ; Process array
    XOR RAX, RAX        ; Sum accumulator
    XOR RCX, RCX        ; Counter
sum_loop:
    ADD RAX, [RSP + RCX*8]
    INC RCX
    CMP RCX, 10
    JL sum_loop
    
    ; RAX contains sum
    MOV RSP, RBP
    POP RBP
    RET
```

