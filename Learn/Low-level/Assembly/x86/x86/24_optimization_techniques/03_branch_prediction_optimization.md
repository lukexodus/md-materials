## Branch Prediction Optimization


Branch prediction is critical for maintaining pipeline efficiency. Mispredicted branches cause pipeline flushes, wasting 15-20 cycles on modern processors.

### Understanding Branch Prediction

Modern x86 processors use sophisticated branch predictors:

**Branch Predictor Components:**

- **Pattern History Table (PHT)**: Tracks branch direction history
- **Branch Target Buffer (BTB)**: Caches branch target addresses
- **Return Stack Buffer (RSB)**: Predicts function return addresses
- **Indirect Branch Predictor**: Predicts indirect jump/call targets

**Prediction Accuracy:**

- Well-behaved branches: 95-99% accuracy
- Random branches: ~50% accuracy (guessing)
- Misprediction penalty: 15-20 cycles (pipeline flush)

### Making Branches Predictable

Predictable branch patterns help the predictor achieve high accuracy.

```assembly
; Predictable branch - always or nearly always taken
mov ecx, 1000
.loop:
    ; Loop body
    dec ecx
    jnz .loop               ; Predicted taken 999 times, not taken once

; Predictable pattern - alternating
mov ecx, 0
.loop:
    test ecx, 1
    jz .even
    ; Odd iteration
    jmp .continue
.even:
    ; Even iteration
.continue:
    inc ecx
    cmp ecx, 100
    jl .loop                ; Alternating pattern - predictor learns it

; Unpredictable branch - random data
mov eax, [random_data]
test eax, 1
jz .random_target       ; Unpredictable - 50% misprediction rate
```

### Branch Elimination Through Predication

Eliminating branches entirely removes prediction risk.

**Conditional Moves (CMOV):**

```assembly
; Branchy code - prediction risk
cmp eax, ebx
jle .use_eax
mov ecx, ebx
jmp .done
.use_eax:
mov ecx, eax
.done:

; Branchless - using CMOV
mov ecx, ebx
cmp eax, ebx
cmovle ecx, eax         ; Conditionally move EAX to ECX if EAX <= EBX
; No branch, no misprediction possible

; Multiple conditions
mov result, default_value
cmp eax, 10
cmovg result, value1    ; If EAX > 10
cmp eax, 20
cmovg result, value2    ; If EAX > 20
```

**SETcc Instructions:**

```assembly
; Convert boolean to integer branchlessly
xor eax, eax
cmp ebx, ecx
setg al                 ; AL = 1 if EBX > ECX, else 0
; Use EAX as multiplier or index

; Example: Conditional increment
mov eax, counter
cmp value, threshold
setg bl
movzx ebx, bl
add eax, ebx            ; Increment if condition true
mov counter, eax
```

**Arithmetic Tricks:**

```assembly
; Absolute value without branching
; abs(x) = (x XOR sign_mask) - sign_mask
mov eax, value
mov ebx, eax
sar ebx, 31             ; EBX = 0xFFFFFFFF if negative, 0 if positive
xor eax, ebx
sub eax, ebx            ; EAX = absolute value

; Min/max without branching
; min(a, b) = b + ((a - b) & ((a - b) >> 31))
mov eax, a
mov ebx, b
sub eax, ebx
mov ecx, eax
sar ecx, 31             ; Sign bit propagated
and eax, ecx
add eax, ebx            ; EAX = min(a, b)
```

### Branch Arrangement and Hints

How branches are arranged affects prediction and code layout.

**Static Branch Prediction Hints:** [Inference] Some processors support branch hint prefixes, though their effectiveness varies by microarchitecture.

```assembly
; Branch likely to be taken (forward)
; Place likely code inline, unlikely code out of line
test eax, eax
jz .rare_case           ; Unlikely - predictor assumes forward conditional branches not taken

; Common case inline
; ... common code ...
jmp .continue

.rare_case:             ; Moved out of line
; ... rare code ...

.continue:

; Alternative: Invert condition to make common case fall-through
test eax, eax
jnz .common_case
; Rare case
jmp .continue

.common_case:
; Common case - inline

.continue:
```

**Loop Exit Optimization:**

```assembly
; Poor - exit check at top
.loop:
    cmp ecx, limit
    jge .done           ; Checked every iteration
    ; Loop body
    inc ecx
    jmp .loop
.done:

; Better - exit check at bottom
    cmp ecx, limit
    jge .done
.loop:
    ; Loop body
    inc ecx
    cmp ecx, limit
    jl .loop            ; Predicted taken (backward branch)
.done:
```

### Indirect Branch Optimization

Indirect branches (through registers or memory) are harder to predict.

```assembly
; Indirect jump - prediction depends on history
jmp [jump_table + eax*4]

; Switch statement optimization - use direct branches for small cases
cmp eax, 0
je .case0
cmp eax, 1
je .case1
cmp eax, 2
je .case2
; For larger switch statements, jump table is better
jmp [jump_table + eax*4]

; Function pointer calls - keep targets stable
call [function_ptr]     ; Predictor tracks recent targets

; Virtual function calls - predictor learns common types
mov eax, [object]       ; Get vtable pointer
call [eax + offset]     ; Predictor tracks this call site
```

### Return Stack Buffer Optimization

The RSB predicts function return addresses. Keeping call/return balanced helps prediction.

```assembly
; Balanced calls and returns - RSB works well
call function1
; ... code ...
call function2
; ... code ...
ret                     ; RSB predicts correct return address

; RSB pollution - avoid
call .get_eip
.get_eip:
pop eax                 ; Pop without matching call - pollutes RSB
; This pattern should be avoided

; Tail calls - can confuse RSB
; Instead of:
call other_function
ret

; Consider:
jmp other_function      ; Tail call - doesn't push return address
```

### Profile-Guided Optimization (PGO)

[Inference] Profile-guided optimization uses runtime profiling data to inform compilation decisions, including branch prediction hints and code layout based on actual branch behavior.

```assembly
; After profiling, hot paths are placed inline:
; Cold code moved out of line

function_hot_path:
    ; Common case - inline and optimized
    test eax, eax
    jz .cold_path       ; Jump to out-of-line code
    
    ; Hot path continues
    mov ebx, [eax]
    add ebx, 10
    ret

.cold_path:             ; Placed far from hot path
    ; Rare case handling
    call error_handler
    ret
```

