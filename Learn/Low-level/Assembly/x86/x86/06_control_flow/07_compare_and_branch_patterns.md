## Compare and Branch Patterns


Common patterns combine comparisons with conditional branches to implement high-level control structures.

### If-Then Pattern

**High-Level:**

```c
if (a == b) {
    // then block
}
// continue
```

**Assembly:**

```asm
mov eax, [a]
cmp eax, [b]
jne skip_then       ; Jump if condition false
    
; Then block
mov ecx, 1
    
skip_then:
; Continue
```

### If-Then-Else Pattern

**High-Level:**

```c
if (a > b) {
    // then block
} else {
    // else block
}
// continue
```

**Assembly:**

```asm
mov eax, [a]
cmp eax, [b]
jle else_block      ; Jump to else if condition false
    
; Then block
mov ecx, 1
jmp end_if
    
else_block:
; Else block
mov ecx, 0
    
end_if:
; Continue
```

### Nested If Pattern

**High-Level:**

```c
if (a > 0) {
    if (b > 0) {
        // both positive
    }
}
```

**Assembly:**

```asm
mov eax, [a]
test eax, eax
jle skip_outer      ; First condition false
    
mov ebx, [b]
test ebx, ebx
jle skip_inner      ; Second condition false
    
; Both conditions true
mov ecx, 1
    
skip_inner:
skip_outer:
; Continue
```

### While Loop Pattern

**High-Level:**

```c
while (counter > 0) {
    // loop body
    counter--;
}
```

**Assembly (Test-First):**

```asm
while_loop:
    mov eax, [counter]
    test eax, eax
    jle end_while       ; Exit if counter <= 0
    
    ; Loop body
    
    dec dword [counter]
    jmp while_loop
    
end_while:
```

**Assembly (Test-Last / Do-While):**

```asm
do_while:
    ; Loop body
    
    mov eax, [counter]
    dec eax
    mov [counter], eax
    
    test eax, eax
    jg do_while         ; Continue if counter > 0
```

### For Loop Pattern

**High-Level:**

```c
for (i = 0; i < 10; i++) {
    // loop body
}
```

**Assembly:**

```asm
xor ecx, ecx        ; i = 0
    
for_loop:
    cmp ecx, 10
    jge end_for         ; Exit if i >= 10
    
    ; Loop body (ECX holds i)
    
    inc ecx             ; i++
    jmp for_loop
    
end_for:
```

**Optimized with Counter:**

```asm
mov ecx, 10         ; Loop 10 times
    
for_loop:
    ; Loop body
    ; Use (10 - ECX) to get actual index if needed
    
    loop for_loop       ; Decrement and loop
```

### Switch Statement Pattern

**High-Level:**

```c
switch (value) {
    case 0: /* ... */ break;
    case 1: /* ... */ break;
    case 2: /* ... */ break;
    default: /* ... */
}
```

**Assembly (Jump Table):**

```asm
section .data
    jump_table dd case_0, case_1, case_2
    table_size equ ($ - jump_table) / 4

section .text
switch_statement:
    mov eax, [value]
    cmp eax, table_size
    jae default_case    ; Out of range, use default
    
    jmp [jump_table + eax*4]
    
case_0:
    mov ebx, 100
    jmp end_switch
    
case_1:
    mov ebx, 200
    jmp end_switch
    
case_2:
    mov ebx, 300
    jmp end_switch
    
default_case:
    mov ebx, 0
    
end_switch:
```

**Assembly (Sequential Comparisons for Sparse Values):**

```asm
switch_statement:
    mov eax, [value]
    
    cmp eax, 5
    je case_5
    
    cmp eax, 10
    je case_10
    
    cmp eax, 100
    je case_100
    
    jmp default_case
    
case_5:
    mov ebx, 1
    jmp end_switch
    
case_10:
    mov ebx, 2
    jmp end_switch
    
case_100:
    mov ebx, 3
    jmp end_switch
    
default_case:
    mov ebx, 0
    
end_switch:
```

### Multiple Condition Pattern (AND Logic)

**High-Level:**

```c
if (a > 0 && b > 0) {
    // both positive
}
```

**Assembly (Short-Circuit Evaluation):**

```asm
mov eax, [a]
test eax, eax
jle skip            ; First condition false, skip rest
    
mov ebx, [b]
test ebx, ebx
jle skip            ; Second condition false
    
; Both conditions true
mov ecx, 1
    
skip:
```

### Multiple Condition Pattern (OR Logic)

**High-Level:**

```c
if (a == 0 || b == 0) {
    // at least one is zero
}
```

**Assembly (Short-Circuit Evaluation):**

```asm
mov eax, [a]
test eax, eax
jz condition_true   ; First condition true, execute block
    
mov ebx, [b]
test ebx, ebx
jz condition_true   ; Second condition true
    
jmp skip            ; Both conditions false
    
condition_true:
; At least one is zero
mov ecx, 1
    
skip:
```

### Range Check Pattern

**High-Level:**

```c
if (x >= min && x <= max) {
    // x is in range
}
```

**Assembly (Two Comparisons):**

```asm
mov eax, [x]
cmp eax, [min]
jl out_of_range     ; x < min
    
cmp eax, [max]
jg out_of_range     ; x > max
    
; x is in range
mov ecx, 1
    
out_of_range:
```

**Assembly (Unsigned Trick):**

For checking if x is in range [0, max], a single unsigned comparison works:

```asm
mov eax, [x]
cmp eax, [max]
ja out_of_range     ; x > max (unsigned also catches negative)
    
; x is in range [0, max]
mov ecx, 1
    
out_of_range:
```

For checking if x is in range [min, max]:

```asm
mov eax, [x]
sub eax, [min]      ; EAX = x - min
cmp eax, [max]
sub eax, [min]      ; EAX = max - min
ja out_of_range     ; If (x - min) > (max - min), out of range
    
; x is in range [min, max]
mov ecx, 1
    
out_of_range:
```

This works because if x < min, the subtraction produces a large unsigned value that will be greater than (max - min).

### Maximum/Minimum Pattern

**High-Level:**

```c
max = (a > b) ? a : b;
```

**Assembly (Using Conditional Jump):**

```asm
mov eax, [a]
mov ebx, [b]
cmp eax, ebx
jge a_is_max        ; Jump if a >= b
    
mov eax, ebx        ; b is maximum
    
a_is_max:
; EAX contains maximum
mov [max], eax
```

**Assembly (Using CMOVcc - Conditional Move):**

Modern x86 processors support conditional move instructions that avoid branching:

```asm
mov eax, [a]
mov ebx, [b]
cmp eax, ebx
cmovl eax, ebx      ; Move EBX to EAX if EAX < EBX
mov [max], eax
```

Available conditional moves include:

- CMOVE/CMOVZ: Move if equal/zero
- CMOVNE/CMOVNZ: Move if not equal/not zero
- CMOVG/CMOVNLE: Move if greater (signed)
- CMOVGE/CMOVNL: Move if greater or equal (signed)
- CMOVL/CMOVNGE: Move if less (signed)
- CMOVLE/CMOVNG: Move if less or equal (signed)
- CMOVA/CMOVNBE: Move if above (unsigned)
- CMOVAE/CMOVNB: Move if above or equal (unsigned)
- CMOVB/CMOVNAE: Move if below (unsigned)
- CMOVBE/CMOVNA: Move if below or equal (unsigned)

**Example: Find Minimum of Three Values:**

```asm
section .data
    a dd 15
    b dd 8
    c dd 23
    min dd 0

section .text
find_min:
    mov eax, [a]
    mov ebx, [b]
    mov ecx, [c]
    
    ; Compare a and b
    cmp eax, ebx
    cmovg eax, ebx      ; EAX = min(a, b)
    
    ; Compare result with c
    cmp eax, ecx
    cmovg eax, ecx      ; EAX = min(min(a, b), c)
    
    mov [min], eax
    ret
```

### Boolean Expression Evaluation

**High-Level:**

```c
result = (a > 0) && (b < 10) && (c == 5);
```

**Assembly (Short-Circuit with Flag Result):**

```asm
xor edx, edx        ; EDX = 0 (false by default)
    
mov eax, [a]
test eax, eax
jle end_eval        ; First condition false, result is false
    
mov ebx, [b]
cmp ebx, 10
jge end_eval        ; Second condition false, result is false
    
mov ecx, [c]
cmp ecx, 5
jne end_eval        ; Third condition false, result is false
    
mov edx, 1          ; All conditions true
    
end_eval:
mov [result], edx
```

### Array Bounds Checking

**High-Level:**

```c
if (index >= 0 && index < array_size) {
    value = array[index];
}
```

**Assembly:**

```asm
section .data
    array dd 10, 20, 30, 40, 50
    array_size equ ($ - array) / 4
    index dd 2
    value dd 0

section .text
bounds_check:
    mov eax, [index]
    
    ; Single unsigned comparison catches both negative and too large
    cmp eax, array_size
    jae out_of_bounds   ; Jump if index >= array_size (unsigned)
    
    ; Index is valid
    mov ebx, [array + eax*4]
    mov [value], ebx
    jmp done
    
out_of_bounds:
    ; Handle error
    mov dword [value], -1
    
done:
    ret
```

### Loop with Break Pattern

**High-Level:**

```c
for (i = 0; i < 10; i++) {
    if (array[i] == target)
        break;
}
```

**Assembly:**

```asm
section .data
    array dd 5, 12, 7, 23, 15, 8, 19, 3, 11, 6
    target dd 15

section .text
find_target:
    xor ecx, ecx        ; i = 0
    mov edx, [target]
    
for_loop:
    cmp ecx, 10
    jge end_loop        ; Exit if i >= 10
    
    mov eax, [array + ecx*4]
    cmp eax, edx
    je found            ; Break if array[i] == target
    
    inc ecx
    jmp for_loop
    
found:
    ; ECX contains index where found
    jmp done
    
end_loop:
    ; Not found, ECX = 10
    mov ecx, -1         ; Indicate not found
    
done:
    ret
```

### Loop with Continue Pattern

**High-Level:**

```c
for (i = 0; i < 10; i++) {
    if (array[i] < 0)
        continue;
    sum += array[i];
}
```

**Assembly:**

```asm
section .text
sum_positive:
    xor ecx, ecx        ; i = 0
    xor edx, edx        ; sum = 0
    
for_loop:
    cmp ecx, 10
    jge end_loop
    
    mov eax, [array + ecx*4]
    test eax, eax
    js skip_negative    ; Continue if negative
    
    add edx, eax        ; sum += array[i]
    
skip_negative:
    inc ecx
    jmp for_loop
    
end_loop:
    mov [sum], edx
    ret
```

### Nested Loop Pattern

**High-Level:**

```c
for (i = 0; i < rows; i++) {
    for (j = 0; j < cols; j++) {
        // process matrix[i][j]
    }
}
```

**Assembly:**

```asm
section .data
    rows equ 3
    cols equ 4
    matrix dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12

section .text
process_matrix:
    xor esi, esi        ; i = 0
    
outer_loop:
    cmp esi, rows
    jge end_outer
    
    xor edi, edi        ; j = 0
    
inner_loop:
    cmp edi, cols
    jge end_inner
    
    ; Calculate offset: (i * cols + j) * 4
    mov eax, esi
    imul eax, cols
    add eax, edi
    mov ebx, [matrix + eax*4]
    
    ; Process element in EBX
    
    inc edi
    jmp inner_loop
    
end_inner:
    inc esi
    jmp outer_loop
    
end_outer:
    ret
```

### Early Return Pattern

**High-Level:**

```c
int function(int x) {
    if (x < 0)
        return -1;
    if (x == 0)
        return 0;
    return x * 2;
}
```

**Assembly:**

```asm
section .text
function:
    ; Parameter in EAX
    
    test eax, eax
    js negative         ; Return -1 if x < 0
    jz zero            ; Return 0 if x == 0
    
    ; Normal case
    shl eax, 1          ; x * 2
    ret
    
negative:
    mov eax, -1
    ret
    
zero:
    xor eax, eax
    ret
```

### State Machine Pattern

**High-Level:**

```c
enum State { STATE_A, STATE_B, STATE_C };
State current = STATE_A;

while (running) {
    switch (current) {
        case STATE_A: /* ... */ break;
        case STATE_B: /* ... */ break;
        case STATE_C: /* ... */ break;
    }
}
```

**Assembly:**

```asm
section .data
    STATE_A equ 0
    STATE_B equ 1
    STATE_C equ 2
    
    state dd STATE_A
    running dd 1
    
    state_table dd handle_state_a, handle_state_b, handle_state_c

section .text
state_machine:
main_loop:
    mov eax, [running]
    test eax, eax
    jz end_machine
    
    mov eax, [state]
    cmp eax, 2
    ja end_machine      ; Invalid state
    
    call [state_table + eax*4]
    
    jmp main_loop
    
handle_state_a:
    ; State A logic
    ; Potentially change state
    ; mov dword [state], STATE_B
    ret
    
handle_state_b:
    ; State B logic
    ret
    
handle_state_c:
    ; State C logic
    ret
    
end_machine:
    ret
```

