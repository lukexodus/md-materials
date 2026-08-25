## State Management


### Register Aliasing

The critical architectural constraint of MMX is register aliasing with the x87 FPU stack. When MMX instructions write to MM0-MM7, they modify the corresponding FP registers ST0-ST7. This aliasing creates several management challenges:

The x87 tag word, which tracks whether FP registers contain valid data, empty slots, or special values, is set to indicate valid data in all registers after MMX operations. This causes the FPU stack mechanism to treat all registers as occupied.

### EMMS Instruction

**EMMS** (Empty MMX State) must be executed before any x87 floating-point operations following MMX code. This instruction sets all x87 tag word bits to indicate empty registers, allowing proper FPU operation.

Failing to execute EMMS between MMX and FPU code causes incorrect FPU behavior because the FPU interprets MMX integer data as floating-point values. The performance impact of missing EMMS can be severe, as the FPU may generate exceptions or produce incorrect results.

The typical usage pattern requires EMMS placement at transition boundaries:

```nasm
; MMX operations
movq mm0, [source]
paddb mm0, [value]
movq [dest], mm0

emms                    ; Required before FPU code

; x87 FPU operations
fld dword [float_val]
fadd st0, st1
```

### Context Switching

Operating system context switches must save and restore MMX state as part of the extended processor state. Modern operating systems handle this automatically, but the aliasing with x87 means MMX state is preserved through the FPU save/restore mechanism (FXSAVE/FXRSTOR instructions on newer processors, or FSAVE/FRSTOR on older ones).

### State Transitions

Mixing MMX and x87 code within the same function creates state transition overhead. Each EMMS instruction incurs a penalty because it must reset FPU state. Well-designed code minimizes these transitions by batching MMX operations together and using EMMS sparingly at logical boundaries.

