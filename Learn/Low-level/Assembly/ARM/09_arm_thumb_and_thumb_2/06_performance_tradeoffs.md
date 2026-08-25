## Performance Tradeoffs


While Thumb provides code density, it involves performance compromises. Thumb-2 significantly reduces these penalties.

### Original Thumb Limitations

**Restricted Immediate Values:**

```assembly
; ARM - flexible immediates (12-bit encoded, rotated 8-bit values)
MOV r0, #0x12000000     ; Single instruction

; Thumb - 8-bit immediates only
MOV r0, #0xFF           ; Max 8-bit immediate
; For larger values, need multiple instructions or literal pool
LDR r0, =0x12000000     ; Literal pool access (slower)
```

**Limited Shift Operations:**

```assembly
; ARM - shift as part of instruction
ADD r0, r1, r2, LSL #3  ; Single instruction

; Thumb - separate shift required
LSL r2, r2, #3          ; Separate instruction
ADD r0, r1, r2          ; Then add
```

**Conditional Execution:**

```assembly
; ARM - predicated instructions
CMP r0, #10
ADDGT r1, r1, #1        ; Only executes if r0 > 10
ADDLE r2, r2, #1        ; Only executes if r0 <= 10

; Thumb - requires branches
CMP r0, #10
BLE skip
ADD r1, r1, #1
skip:
ADD r2, r2, #1
```

**Register Restrictions Impact:**

```assembly
; Need high registers but only low registers accessible
; Requires register shuffling

; ARM - direct access
ADD r8, r9, r10         ; Single instruction

; Thumb - register shuffling needed
MOV r0, r8              ; Move to low register
MOV r1, r9              ; Move to low register
ADD r0, r0, r1          ; Perform operation
MOV r8, r0              ; Move back
; 4 instructions instead of 1
```

### Thumb-2 Performance Improvements

Thumb-2 eliminates most Thumb limitations:

**Wide Immediates:**

```assembly
; Thumb-2 MOVW/MOVT for 32-bit immediates
MOVW r0, #0x1234        ; Lower 16 bits (2 bytes)
MOVT r0, #0x5678        ; Upper 16 bits (2 bytes)
; Result: r0 = 0x56781234

; Alternative for smaller values
MOV.W r0, #0xFF00       ; 32-bit encoding with flexible immediate
```

**Flexible Operands:**

```assembly
; Thumb-2 - shifted operands available
ADD.W r0, r1, r2, LSL #3    ; 32-bit instruction, same as ARM
```

**IT Blocks for Conditional Execution:**

```assembly
; Thumb-2 IT blocks (covered in detail below)
CMP r0, #10
ITE GT                  ; If-Then-Else
ADDGT r1, r1, #1        ; Executes if GT (Then)
ADDLE r2, r2, #1        ; Executes if LE (Else)
```

### Performance Metrics

**Execution Speed:**

- Thumb instructions may execute in same cycles as ARM equivalents
- Register shuffling and extra instructions add overhead in original Thumb
- Thumb-2 typically within 95-98% of ARM performance
- [Inference] Performance gap primarily from increased instruction count, not slower instruction execution

**Example** - Cycle count comparison (simplified model):

```assembly
; ARM version - 3 instructions, ~3 cycles
ADD r0, r1, r2, LSL #2    ; 1 cycle
LDR r3, [r0, #16]         ; 2 cycles (load latency)
ADD r4, r3, #100          ; 1 cycle

; Original Thumb - 5 instructions, ~5 cycles  
LSL r2, r2, #2            ; 1 cycle
ADD r0, r1, r2            ; 1 cycle
LDR r3, [r0, #16]         ; 2 cycles
MOV r4, r3                ; 1 cycle (if needed)
ADD r4, r4, #100          ; 1 cycle

; Thumb-2 - 3 instructions, ~3 cycles (matches ARM)
ADD.W r0, r1, r2, LSL #2  ; 1 cycle
LDR r3, [r0, #16]         ; 2 cycles
ADD r4, r3, #100          ; 1 cycle
```

### Branch Range Limitations

**Branch Distance:**

```assembly
; ARM - 24-bit signed offset (±32MB range)
B far_target            ; Can reach ±32MB

; Thumb - 11-bit signed offset (±2KB range)
B near_target           ; Limited to ±2KB
; For far branches, use:
BL far_target           ; Branch with link (longer range)
; Or veneer code

; Thumb-2 - 24-bit signed offset in BL/B.W
B.W far_target          ; Wide branch, ±16MB
```

**Veneer Code for Out-of-Range Branches:**

```assembly
; Original target out of Thumb branch range
B far_away              ; Won't reach

; Linker inserts veneer (trampoline)
B veneer                ; Branch to nearby veneer
; ...
veneer:
    LDR pc, =far_away   ; Indirect branch through veneer
```

### Mode Switching Overhead

Switching between ARM and Thumb modes incurs small overhead:

```assembly
; BX - Branch and Exchange (changes instruction set)
.arm                    ; ARM mode
    BX r0               ; Branch to address in r0, switch mode based on bit 0

.thumb                  ; Thumb mode
    BX r1               ; Branch to address in r1, switch mode

; Bit 0 of target address determines mode:
; 0 = ARM mode, 1 = Thumb mode
```

**Example** - Interworking between modes:

```assembly
.thumb
thumb_function:
    PUSH {lr}
    LDR r0, =arm_function
    ORR r0, r0, #0      ; Clear bit 0 for ARM mode
    BLX r0              ; Branch with link and exchange to ARM
    POP {pc}

.arm  
arm_function:
    ; ARM code here
    BX lr               ; Return (LR has correct mode bit)
```

[Inference] Mode switching overhead is typically 0-1 cycles on modern processors with mode prediction, but legacy processors may experience pipeline flush.

