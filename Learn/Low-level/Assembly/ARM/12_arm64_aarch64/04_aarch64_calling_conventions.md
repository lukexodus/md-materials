## AArch64 Calling Conventions


The AArch64 Procedure Call Standard (AAPCS64) defines how functions pass arguments, return values, and manage the stack.

### Procedure Call Standard (AAPCS64)

**Register Roles:**

```
X0-X7:   Argument/result registers (caller-saved)
X8:      Indirect result location register
X9-X15:  Temporary registers (caller-saved)
X16-X17: Intra-procedure-call registers (IP0, IP1)
X18:     Platform register (reserved)
X19-X28: Callee-saved registers
X29:     Frame pointer (FP)
X30:     Link register (LR)
SP:      Stack pointer (must be 16-byte aligned)
```

**Parameter Passing:**

```assembly
; First 8 integer arguments in X0-X7
function_8_args:
    ; X0 = arg1, X1 = arg2, ..., X7 = arg8
    ADD X0, X0, X1              ; Use arguments
    ADD X0, X0, X2
    RET

; Additional arguments on stack
function_10_args:
    ; X0-X7 = first 8 arguments
    ; [SP] = arg9, [SP+8] = arg10
    LDR X8, [SP]                ; Load 9th argument
    LDR X9, [SP, #8]            ; Load 10th argument
    ADD X0, X0, X8
    ADD X0, X0, X9
    RET
```

**Return Values:**

```assembly
; Integer return in X0
function_returns_int:
    MOV X0, #42                 ; Return value in X0
    RET

; 128-bit return in X0-X1
function_returns_128bit:
    MOV X0, #0x1234567890ABCDEF ; Lower 64 bits
    MOV X1, #0xFEDCBA098765432  ; Upper 64 bits
    RET

; Large structure return via X8
function_returns_struct:
    ; X8 points to caller-allocated space
    ; Caller passes pointer in X8
    STR X0, [X8]                ; Store first field
    STR X1, [X8, #8]            ; Store second field
    STR X2, [X8, #16]           ; Store third field
    ; Don't modify X8
    RET

; Caller side
caller:
    SUB SP, SP, #32             ; Allocate space for result
    MOV X8, SP                  ; Pass pointer in X8
    BL function_returns_struct
    ; Result now in [SP] through [SP+23]
    LDR X0, [SP]                ; Access result
    ADD SP, SP, #32             ; Deallocate
```

**Floating-Point Arguments:**

```assembly
; First 8 FP arguments in V0-V7 (as S0-S7 or D0-D7)
function_fp_args:
    ; D0 = arg1, D1 = arg2, etc. (double precision)
    FADD D0, D0, D1             ; Add first two arguments
    RET

; Mixed integer and FP arguments
function_mixed:
    ; X0 = integer arg1
    ; D0 = double arg1
    ; X1 = integer arg2
    ; D1 = double arg2
    SCVTF D2, X0                ; Convert integer to double
    FADD D0, D0, D2             ; Add to FP argument
    RET
```

### Stack Frame Layout

**Standard Stack Frame:**

```assembly
; Function prologue
function:
    ; Save frame pointer and link register
    STP X29, X30, [SP, #-16]!   ; Pre-decrement SP by 16
    MOV X29, SP                 ; Set frame pointer
    
    ; Allocate local variables
    SUB SP, SP, #32             ; Allocate 32 bytes
    
    ; Save callee-saved registers if needed
    STP X19, X20, [SP, #16]
    
    ; Function body
    ; Local variables at [SP], [SP+8], etc.
    ; Saved registers at higher addresses
    
    ; Function epilogue
    LDP X19, X20, [SP, #16]     ; Restore callee-saved
    ADD SP, SP, #32             ; Deallocate locals
    LDP X29, X30, [SP], #16     ; Restore FP, LR
    RET
```

**Stack Frame Diagram:**

```
Higher addresses
+------------------+
| Previous frame   |
+------------------+
| Saved FP         | <- X29 (frame pointer)
+------------------+
| Saved LR         |
+------------------+
| Saved X19        |
+------------------+
| Saved X20        |
+------------------+
| Local var 1      |
+------------------+
| Local var 2      |
+------------------+
| ...              | <- SP (stack pointer)
+------------------+
Lower addresses
```

**Example** - Complete function with locals:

```assembly
.global compute_sum
compute_sum:
    ; Parameters: X0 = array, X1 = count
    ; Local variables: sum (X19), temp (X20)
    
    ; Prologue
    STP X29, X30, [SP, #-32]!   ; Save FP, LR, allocate frame
    MOV X29, SP                 ; Set frame pointer
    STP X19, X20, [SP, #16]     ; Save callee-saved registers
    
    ; Initialize locals
    MOV X19, XZR                ; sum = 0
    MOV X20, X0                 ; temp = array pointer
    
loop:
    CBZ X1, done                ; Check if count == 0
    
    LDR X0, [X20], #8           ; Load element, advance pointer
    ADD X19, X19, X0            ; sum += element
    
    SUB X1, X1, #1              ; count--
    B loop
    
done:
    MOV X0, X19                 ; Return sum
    
    ; Epilogue
    LDP X19, X20, [SP, #16]     ; Restore callee-saved
    LDP X29, X30, [SP], #32     ; Restore FP, LR, deallocate
    RET
```

### Caller-Saved vs Callee-Saved

**Caller-Saved Registers (X0-X18):**

```assembly
caller_function:
    ; Save any needed caller-saved registers before call
    MOV X9, #100                ; Use X9 (caller-saved)
    
    ; X9 might be clobbered by callee
    STR X9, [SP, #-16]!         ; Save X9 if needed after call
    BL callee_function
    LDR X9, [SP], #16           ; Restore X9
    
    ; Or don't save if not needed
    MOV X10, #200
    BL another_function         ; X10 will be lost (don't care)
```

**Callee-Saved Registers (X19-X28):**

```assembly
callee_function:
    ; Must save if using callee-saved registers
    STP X29, X30, [SP, #-32]!
    STP X19, X20, [SP, #16]
    
    ; Can use X19-X20 freely
    MOV X19, X0
    MOV X20, X1
    
    ; Call other functions
    BL helper
    ; X19-X20 preserved across call
    
    ADD X0, X19, X20
    
    ; Must restore before returning
    LDP X19, X20, [SP, #16]
    LDP X29, X30, [SP], #32
    RET
```

**Example** - Register usage strategy:

```assembly
; Complex function with multiple calls
complex_function:
    STP X29, X30, [SP, #-64]!   ; Large frame
    MOV X29, SP
    STP X19, X20, [SP, #16]     ; Callee-saved
    STP X21, X22, [SP, #32]
    STP X23, X24, [SP, #48]
    
    ; Use callee-saved for persistent values
    MOV X19, X0                 ; Save arg1 persistently
    MOV X20, X1                 ; Save arg2
    
    ; Use caller-saved for temporaries
    MOV X9, #100
    ADD X10, X9, X19
    
    ; First call (X9-X15 may be clobbered)
    MOV X0, X10
    BL function1
    MOV X21, X0                 ; Save result in callee-saved
    
    ; Second call (X19-X20 still valid)
    MOV X0, X19
    MOV X1, X20
    BL function2
    MOV X22, X0                 ; Save result
    
    ; Combine results
    ADD X0, X21, X22
    
    ; Restore and return
    LDP X23, X24, [SP, #48]
    LDP X21, X22, [SP, #32]
    LDP X19, X20, [SP, #16]
    LDP X29, X30, [SP], #64
    RET
```

### Variadic Functions

**Variable Argument Lists:**

```assembly
; va_list implementation
; Variadic function prototype: int sum(int count, ...)

.global sum
sum:
    ; X0 = count (number of additional arguments)
    ; X1-X7 = first 7 variadic arguments
    ; [SP] onwards = remaining arguments
    
    STP X29, X30, [SP, #-16]!
    MOV X29, SP
    
    MOV X9, XZR                 ; sum = 0
    MOV X10, #0                 ; processed count = 0
    
    ; Process register arguments (X1-X7)
loop_regs:
    CMP X10, X0                 ; Check if done
    B.GE done
    CMP X10, #7                 ; Check if still in registers
    B.GE loop_stack
    
    ; Load from appropriate register (simplified)
    ; In practice, would use computed addressing or table
    CMP X10, #0
    B.NE check1
    ADD X9, X9, X1
    B next_reg
check1:
    CMP X10, #1
    B.NE check2
    ADD X9, X9, X2
    B next_reg
check2:
    ; ... more cases ...
    
next_reg:
    ADD X10, X10, #1
    B loop_regs
    
loop_stack:
    ; Process stack arguments
    SUB X11, X10, #7            ; Stack argument index
    LDR X12, [X29, X11, LSL #3] ; Load from stack
    ADD X9, X9, X12
    ADD X10, X10, #1
    CMP X10, X0
    B.LT loop_stack
    
done:
    MOV X0, X9                  ; Return sum
    LDP X29, X30, [SP], #16
    RET

; Caller
caller:
    MOV X0, #5                  ; Count
    MOV X1, #10                 ; Arg 1
    MOV X2, #20                 ; Arg 2
    MOV X3, #30                 ; Arg 3
    MOV X4, #40                 ; Arg 4
    MOV X5, #50                 ; Arg 5
    BL sum                      ; Result in X0
```

### Structure Passing

**Small Structures (≤16 bytes):**

```assembly
; Structure in registers
; struct Point { long x, y; }

function_point:
    ; X0 = x, X1 = y (structure split into registers)
    ADD X0, X0, X1              ; x + y
    RET

; Caller
caller:
    MOV X0, #10                 ; point.x
    MOV X1, #20                 ; point.y
    BL function_point
```

**Large Structures (>16 bytes):**

```assembly
; Structure passed by reference
; struct LargeData { long a, b, c, d; }

function_large:
    ; X0 = pointer to structure
    LDR X1, [X0]                ; Load first field
    LDR X2, [X0, #8]            ; Load second field
    LDR X3, [X0, #16]           ; Load third field
    LDR X4, [X0, #24]           ; Load fourth field
    ADD X0, X1, X2
    ADD X0, X0, X3
    ADD X0, X0, X4
    RET

; Caller
caller:
    SUB SP, SP, #32             ; Allocate structure on stack
    MOV X1, #10
    STR X1, [SP]                ; field a
    MOV X1, #20
    STR X1, [SP, #8]            ; field b
    MOV X1, #30
    STR X1, [SP, #16]           ; field c
    MOV X1, #40
    STR X1, [SP, #24]           ; field d
    
    MOV X0, SP                  ; Pass pointer
    BL function_large
    
    ADD SP, SP, #32             ; Deallocate
```

### Floating-Point Calling Convention

**FP Parameter Passing:**

```assembly
; V0-V7 for first 8 FP arguments
.global fp_function
fp_function:
    ; D0 = double arg1
    ; S1 = float arg2
    ; D2 = double arg3
    
    FADD D0, D0, D2             ; Add double arguments
    FCVT D1, S1                 ; Convert float to double
    FADD D0, D0, D1             ; Add converted value
    RET                         ; Return in D0

; Mixed integer and FP
.global mixed_function
mixed_function:
    ; X0 = int64 arg
    ; D0 = double arg
    ; X1 = int64 arg
    ; D1 = double arg
    
    SCVTF D2, X0                ; Convert X0 to double
    FADD D0, D0, D2
    SCVTF D2, X1
    FADD D0, D0, D2
    FADD D0, D0, D1
    RET
```

**SIMD/Vector Parameters:**

```assembly
; V0-V7 for vector arguments (full 128-bit)
.global vector_add
vector_add:
    ; V0 = first vector (4x float32)
    ; V1 = second vector (4x float32)
    
    FADD V0.4S, V0.4S, V1.4S    ; Vector add
    RET                         ; Return in V0
```

### Stack Alignment

**16-Byte Alignment Requirement:**

```assembly
; SP must be 16-byte aligned at function entry

function:
    ; Allocate space (must be multiple of 16)
    SUB SP, SP, #32             ; OK: 32 is multiple of 16
    
    ; Store data
    STR X0, [SP]
    STR X1, [SP, #8]
    
    ; Call another function (SP still 16-byte aligned)
    BL other_function
    
    ; Deallocate
    ADD SP, SP, #32
    RET

; BAD: Misaligned allocation
bad_function:
    SUB SP, SP, #24             ; BAD: Not 16-byte aligned
    ; This violates ABI and may cause issues
```

**Variable-Size Allocation:**

```assembly
; Align dynamic allocation
alloca_example:
    ; X0 = size to allocate

    STP     X29, X30, [SP, #-16]!
    MOV     X29, SP

    ; Round up to 16-byte multiple
    ADD     X0, X0, #15             ; Add 15
    AND     X0, X0, #~15            ; Clear low 4 bits (align to 16)

    ; Allocate
    SUB     SP, SP, X0

    ; Use allocated space
    MOV     X1, SP                  ; Pointer to allocated space

    ; ... use space ...

    ; Deallocate: restore SP from frame pointer
    MOV     SP, X29
    LDP     X29, X30, [SP], #16
    RET
````

### Tail Call Optimization

**Tail Call Requirements:**
```assembly
; Tail call: function ends with call to another function
; Can reuse current stack frame if conditions met

.global tail_call_example
tail_call_example:
    ; Save nothing, no local variables
    ; Arguments already in correct registers
    
    ; Prepare arguments for target function
    MOV X0, X1                  ; Shuffle arguments if needed
    MOV X1, X2
    
    ; Jump directly instead of BL
    B target_function           ; Tail call (not BL)
    
; Instead of:
;   BL target_function
;   RET

; More complex example with cleanup
tail_call_with_frame:
    STP X29, X30, [SP, #-32]!
    MOV X29, SP
    STP X19, X20, [SP, #16]
    
    ; Setup for tail call
    MOV X19, X0
    
    ; Prepare arguments
    MOV X0, X19
    MOV X1, #100
    
    ; Cleanup before tail call
    LDP X19, X20, [SP, #16]
    LDP X29, X30, [SP], #32
    
    ; Tail call
    B target_function           ; Jump, don't link
````

### Exception Handling and Unwinding

**Frame Layout for Unwinding:**

```assembly
.global unwind_example
unwind_example:
    ; Standard frame for unwinding
    STP X29, X30, [SP, #-16]!   ; FP and LR saved together
    MOV X29, SP                 ; FP points to saved FP
    
    ; This allows unwinder to:
    ; 1. Follow FP chain: previous FP at [X29]
    ; 2. Get return address: LR at [X29, #8]
    
    ; Allocate more space if needed
    SUB SP, SP, #32
    
    ; Function body
    BL might_throw_exception
    
    ; Normal cleanup
    ADD SP, SP, #32
    LDP X29, X30, [SP], #16
    RET
    
; Unwinder walks stack:
; 1. Current FP in X29
; 2. Previous FP = [X29]
; 3. Return address = [X29, #8]
; 4. Repeat until FP = 0
```

**Compact Unwinding Information:**

```assembly
; ARM64 uses compact unwind encoding
; Stored in __unwind_info section (Mach-O) or .eh_frame (ELF)

.cfi_startproc                  ; Start unwind info
function_with_cfi:
    STP X29, X30, [SP, #-16]!
    .cfi_def_cfa_offset 16      ; CFA offset is 16
    .cfi_offset 29, -16         ; X29 saved at CFA-16
    .cfi_offset 30, -8          ; X30 saved at CFA-8
    
    MOV X29, SP
    .cfi_def_cfa_register 29    ; CFA now relative to X29
    
    ; Function body
    
    LDP X29, X30, [SP], #16
    .cfi_restore 29
    .cfi_restore 30
    .cfi_def_cfa 31, 0          ; Back to SP
    RET
.cfi_endproc
```

### Real-World Examples

**Example** - String length (strlen):

```assembly
.global strlen
strlen:
    ; X0 = string pointer
    ; Returns length in X0
    
    MOV X1, X0                  ; Save original pointer
    
    ; Check alignment
    TST X0, #7                  ; Test if 8-byte aligned
    B.EQ aligned
    
byte_loop:
    LDRB W2, [X0], #1           ; Load byte
    CBZ W2, found_null          ; Check for null
    TST X0, #7                  ; Check alignment
    B.NE byte_loop
    
aligned:
    ; Process 8 bytes at a time
    MOV X3, #0x0101010101010101 ; Mask for null detection
    
word_loop:
    LDR X2, [X0], #8            ; Load 8 bytes
    
    ; Check for null byte using bit tricks
    SUB X4, X2, X3              ; Subtract 0x01 from each byte
    BIC X4, X4, X2              ; Clear with original
    TST X4, X3, LSL #7          ; Test for 0x80 in any byte
    B.EQ word_loop              ; Continue if no null
    
    ; Found null in this word
    SUB X0, X0, #8              ; Back up to start of word
    
byte_search:
    LDRB W2, [X0], #1
    CBZ W2, found_null
    B byte_search
    
found_null:
    SUB X0, X0, X1              ; Length = end - start
    SUB X0, X0, #1              ; Don't count null
    RET
```

**Example** - Memory copy (memcpy):

```assembly
.global memcpy
memcpy:
    ; X0 = dest, X1 = src, X2 = size
    ; Returns dest in X0
    
    MOV X3, X0                  ; Save dest
    CBZ X2, done                ; Handle zero size
    
    ; Check if we can use pairs (16-byte copies)
    CMP X2, #16
    B.LT byte_copy
    
    ; Check alignment
    ORR X4, X0, X1              ; Check both pointers
    TST X4, #7
    B.NE byte_copy              ; Use byte copy if misaligned
    
pair_copy:
    ; Copy 16 bytes at a time
    LDP X4, X5, [X1], #16       ; Load pair
    STP X4, X5, [X0], #16       ; Store pair
    SUBS X2, X2, #16
    B.GE pair_copy
    
    ; Handle remainder
    ADDS X2, X2, #16
    B.EQ done
    
byte_copy:
    LDRB W4, [X1], #1           ; Load byte
    STRB W4, [X0], #1           ; Store byte
    SUBS X2, X2, #1
    B.NE byte_copy
    
done:
    MOV X0, X3                  ; Restore dest
    RET
```

**Example** - Memory set (memset):

```assembly
.global memset
memset:
    ; X0 = dest, X1 = value (byte), X2 = size
    ; Returns dest in X0
    
    MOV X3, X0                  ; Save dest
    CBZ X2, done
    
    ; Replicate byte to all positions
    AND X1, X1, #0xFF
    ORR X1, X1, X1, LSL #8      ; 16-bit
    ORR X1, X1, X1, LSL #16     ; 32-bit
    ORR X1, X1, X1, LSL #32     ; 64-bit
    
    ; Check for large fills
    CMP X2, #16
    B.LT byte_fill
    
    ; Fill 16 bytes at a time
pair_fill:
    STP X1, X1, [X0], #16       ; Store pair
    SUBS X2, X2, #16
    B.GE pair_fill
    
    ; Handle remainder
    ADDS X2, X2, #16
    B.EQ done
    
byte_fill:
    STRB W1, [X0], #1
    SUBS X2, X2, #1
    B.NE byte_fill
    
done:
    MOV X0, X3
    RET
```

**Example** - Quick sort partition:

```assembly
.global partition
partition:
    ; X0 = array, X1 = low, X2 = high
    ; Returns pivot index in X0
    
    STP X29, X30, [SP, #-48]!
    MOV X29, SP
    STP X19, X20, [SP, #16]
    STP X21, X22, [SP, #32]
    
    ; Save parameters
    MOV X19, X0                 ; array
    MOV X20, X1                 ; low (i)
    MOV X21, X2                 ; high
    
    ; Load pivot = array[high]
    LDR X22, [X19, X21, LSL #3]
    
    SUB X20, X20, #1            ; i = low - 1
    
partition_loop:
    CMP X1, X21                 ; j < high?
    B.GE partition_done
    
    ; Load array[j]
    LDR X9, [X19, X1, LSL #3]
    
    ; if (array[j] <= pivot)
    CMP X9, X22
    B.GT skip_swap
    
    ; i++
    ADD X20, X20, #1
    
    ; Swap array[i] and array[j]
    LDR X10, [X19, X20, LSL #3]
    STR X9, [X19, X20, LSL #3]
    STR X10, [X19, X1, LSL #3]
    
skip_swap:
    ADD X1, X1, #1              ; j++
    B partition_loop
    
partition_done:
    ; Final swap: array[i+1] with array[high]
    ADD X20, X20, #1
    LDR X9, [X19, X20, LSL #3]
    LDR X10, [X19, X21, LSL #3]
    STR X10, [X19, X20, LSL #3]
    STR X9, [X19, X21, LSL #3]
    
    MOV X0, X20                 ; Return pivot index
    
    LDP X21, X22, [SP, #32]
    LDP X19, X20, [SP, #16]
    LDP X29, X30, [SP], #48
    RET
```

**Example** - Binary search:

```assembly
.global binary_search
binary_search:
    ; X0 = array, X1 = size, X2 = target
    ; Returns index in X0, or -1 if not found
    
    MOV X3, #0                  ; low = 0
    SUB X4, X1, #1              ; high = size - 1
    
search_loop:
    CMP X3, X4                  ; low <= high?
    B.GT not_found
    
    ; mid = low + (high - low) / 2
    SUB X5, X4, X3              ; high - low
    LSR X5, X5, #1              ; Divide by 2
    ADD X5, X5, X3              ; mid = low + (high-low)/2
    
    ; Load array[mid]
    LDR X6, [X0, X5, LSL #3]
    
    ; Compare with target
    CMP X6, X2
    B.EQ found                  ; array[mid] == target
    B.GT search_left            ; array[mid] > target
    
    ; Search right: low = mid + 1
    ADD X3, X5, #1
    B search_loop
    
search_left:
    ; Search left: high = mid - 1
    SUB X4, X5, #1
    B search_loop
    
found:
    MOV X0, X5                  ; Return mid
    RET
    
not_found:
    MOV X0, #-1                 ; Return -1
    RET
```

### Performance Optimization Tips

**Register Allocation Strategy:**

```assembly
; Good: Use callee-saved for important values across calls
optimized_function:
    STP X29, X30, [SP, #-32]!
    STP X19, X20, [SP, #16]
    
    MOV X19, X0                 ; Important persistent value
    MOV X20, X1
    
    ; Multiple calls - X19, X20 preserved
    MOV X0, X19
    BL function1
    
    MOV X0, X20
    BL function2
    
    ; X19, X20 still valid
    ADD X0, X19, X20
    
    LDP X19, X20, [SP, #16]
    LDP X29, X30, [SP], #32
    RET

; Poor: Unnecessary memory access
unoptimized_function:
    STP X29, X30, [SP, #-32]!
    
    STR X0, [SP, #16]           ; Spill to memory
    STR X1, [SP, #24]
    
    LDR X0, [SP, #16]           ; Reload for each call
    BL function1
    
    LDR X0, [SP, #24]
    BL function2
    
    LDR X0, [SP, #16]           ; Reload again
    LDR X1, [SP, #24]
    ADD X0, X0, X1
    
    LDP X29, X30, [SP], #32
    RET
```

**Minimize Stack Usage:**

```assembly
; Good: Minimal stack frame
leaf_function:
    ; No calls, no need to save LR
    ADD X0, X0, X1
    MUL X0, X0, X2
    RET                         ; No stack frame needed

; Good: Small frame
small_frame_function:
    STP X29, X30, [SP, #-16]!   ; Just FP and LR
    ; Use X9-X15 for temporaries (caller-saved, no save needed)
    MOV X9, #100
    ADD X0, X0, X9
    LDP X29, X30, [SP], #16
    RET

; Poor: Unnecessarily large frame
bloated_function:
    SUB SP, SP, #128            ; Huge allocation
    STP X29, X30, [SP]
    STP X19, X20, [SP, #16]
    ; ... only uses 32 bytes ...
    LDP X19, X20, [SP, #16]
    LDP X29, X30, [SP]
    ADD SP, SP, #128
    RET
```

**Leverage CSEL for Branchless Code:**

```assembly
; Good: Branchless max
max_branchless:
    CMP X0, X1
    CSEL X0, X0, X1, GT         ; Single instruction
    RET

; Poor: Branch-based max
max_branching:
    CMP X0, X1
    B.GT done
    MOV X0, X1
done:
    RET

; Good: Branchless clamping
clamp:
    ; Clamp X0 to range [X1, X2]
    CMP X0, X1
    CSEL X0, X0, X1, GE         ; max(X0, X1)
    CMP X0, X2
    CSEL X0, X0, X2, LE         ; min(X0, X2)
    RET
```

**Optimize Load/Store Patterns:**

```assembly
; Good: Use load/store pairs
efficient_copy:
    LDP X3, X4, [X1], #16       ; Load 2 registers, 16 bytes
    STP X3, X4, [X0], #16       ; Store 2 registers, 16 bytes
    ; 2 instructions, 16 bytes transferred

; Poor: Individual loads/stores
inefficient_copy:
    LDR X3, [X1], #8            ; Load 1 register
    STR X3, [X0], #8            ; Store 1 register
    LDR X4, [X1], #8            ; Load another
    STR X4, [X0], #8            ; Store another
    ; 4 instructions, same 16 bytes

; Good: Prefetch for large copies
large_copy_with_prefetch:
    PRFM PLDL1KEEP, [X1, #64]   ; Prefetch source
    PRFM PSTL1KEEP, [X0, #64]   ; Prefetch destination
    LDP X3, X4, [X1], #16
    STP X3, X4, [X0], #16
    ; Continue...
```

**Alignment Awareness:**

```assembly
; Align hot code to cache line boundaries
.align 6                        ; 64-byte alignment (cache line)
hot_loop:
    ; Critical loop code
    LDR X0, [X1], #8
    ADD X2, X2, X0
    SUBS X3, X3, #1
    B.NE hot_loop
    RET

; Align data structures
.align 3                        ; 8-byte alignment
data_array:
    .quad 1, 2, 3, 4

.align 4                        ; 16-byte alignment for SIMD
vector_data:
    .quad 1, 2, 3, 4
```

