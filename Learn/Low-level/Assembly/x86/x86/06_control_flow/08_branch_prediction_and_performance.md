## Branch Prediction and Performance


Modern processors use branch prediction to speculatively execute instructions before knowing whether a branch will be taken. Understanding this helps write more efficient code.

### Branch Prediction Basics

**Static Prediction:** [Inference] Processors may use simple heuristics like "backward branches are predicted taken" (common for loops) and "forward branches are predicted not taken."

**Dynamic Prediction:** The CPU maintains a history of branch behavior and predicts based on past execution.

### Branch Misprediction Cost

When a branch is mispredicted, the CPU must flush the pipeline and restart from the correct path. [Inference] This typically costs 10-20 cycles on modern processors, making mispredictions expensive.

### Optimization Strategies

**Eliminate Branches with Conditional Moves:**

**Before:**

```asm
cmp eax, ebx
jg use_a
mov ecx, ebx
jmp done
use_a:
mov ecx, eax
done:
```

**After:**

```asm
mov ecx, ebx
cmp eax, ebx
cmovg ecx, eax      ; No branch, better for unpredictable data
```

**Arrange Predictable Branches First:**

If you know one condition is much more likely, test it first:

```asm
; If x == 0 is rare
test eax, eax
jz rare_case        ; Predicted not taken
    
; Common path here
    
rare_case:
; Rare path here
```

**Use Lookup Tables Instead of Branches:**

**Before:**

```asm
cmp al, 'A'
jb not_upper
cmp al, 'Z'
ja not_upper
; Convert to lowercase
or al, 0x20
not_upper:
```

**After:**

```asm
; Use a 256-byte lookup table for character conversion
movzx eax, al
mov al, [case_table + eax]
```

**Loop Unrolling:**

Reduce branch frequency by processing multiple elements per iteration:

**Before:**

```asm
mov ecx, 100
loop_start:
    ; Process one element
    loop loop_start
```

**After:**

```asm
mov ecx, 25         ; 100 / 4
loop_start:
    ; Process four elements
    loop loop_start
```

### Likely/Unlikely Branches

Some assemblers support hints about branch likelihood, though modern processors often ignore these:

```asm
; Intel syntax (not standard, processor-dependent)
cmp eax, 0
jz unlikely_path, hint_not_taken
```

[Unverified] The effectiveness of branch hints varies by processor generation, and modern CPUs' dynamic predictors often outperform static hints.

