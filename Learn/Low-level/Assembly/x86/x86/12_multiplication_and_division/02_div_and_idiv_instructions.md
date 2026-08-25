## DIV and IDIV Instructions


### DIV (Unsigned Division)

DIV performs unsigned division, dividing a register pair by a single operand and storing both quotient and remainder.

**Operand Sizes and Register Usage:**

```assembly
; 8-bit: AX ÷ operand → AL (quotient), AH (remainder)
div bl          ; AL = AX ÷ BL, AH = AX mod BL

; 16-bit: DX:AX ÷ operand → AX (quotient), DX (remainder)
div cx          ; AX = DX:AX ÷ CX, DX = DX:AX mod CX

; 32-bit: EDX:EAX ÷ operand → EAX (quotient), EDX (remainder)
div ebx         ; EAX = EDX:EAX ÷ EBX, EDX = EDX:EAX mod EBX

; 64-bit: RDX:RAX ÷ operand → RAX (quotient), RDX (remainder)
div rcx         ; RAX = RDX:RAX ÷ RCX, RDX = RDX:RAX mod RCX
```

**Flags Affected:**

- **All flags are undefined after DIV**

**Critical Requirement: Upper Register Must Be Initialized**

```assembly
; CORRECT: Clear upper register before 8-bit division
mov ax, 100         ; Dividend
xor ah, ah          ; Must clear AH (or CBW for signed extension)
mov bl, 7
div bl              ; AL = 14, AH = 2

; INCORRECT: Garbage in AH causes wrong result
mov al, 100         ; AL = 100
; AH contains unknown value!
mov bl, 7
div bl              ; Undefined behavior - wrong result

; CORRECT: Clear upper register before 32-bit division
mov eax, 100
xor edx, edx        ; Must clear EDX
mov ebx, 7
div ebx             ; EAX = 14, EDX = 2
```

**Basic Examples:**

```assembly
; 8-bit division: 100 ÷ 7
mov ax, 100         ; AX = dividend (must use AX, not just AL)
mov bl, 7           ; Divisor
div bl              ; AL = 14 (quotient), AH = 2 (remainder)

; 16-bit division: 1000 ÷ 13
mov ax, 1000
xor dx, dx          ; Clear DX (no high word)
mov cx, 13
div cx              ; AX = 76 (quotient), DX = 12 (remainder)

; 32-bit division: 1,000,000 ÷ 256
mov eax, 1000000
xor edx, edx
mov ebx, 256
div ebx             ; EAX = 3906 (quotient), EDX = 64 (remainder)
```

**Division with Extended Dividend:**

```assembly
; Divide 64-bit number by 32-bit: 0x0000000100000000 ÷ 0x10000
; (4,294,967,296 ÷ 65,536 = 65,536)

mov edx, 1          ; High 32 bits
mov eax, 0          ; Low 32 bits (EDX:EAX = 0x100000000)
mov ebx, 0x10000    ; Divisor
div ebx             ; EAX = 0x10000 (quotient), EDX = 0 (remainder)
```

**Division Overflow - Divide Error Exception:**

```assembly
; This causes #DE (divide error) exception!
mov ax, 1000        ; Dividend
xor ah, ah          ; AH = 0 (AX = 1000)
mov bl, 2           ; Divisor
div bl              ; Quotient (500) doesn't fit in AL (max 255)!
                    ; CPU generates interrupt 0 (divide error)

; Prevent overflow by checking first
mov ax, 1000
mov bl, 2
cmp ax, 255         ; Check if quotient will fit in AL
jae divide_overflow ; If AX >= 255, quotient won't fit in AL (8-bit)

; Safe to divide
xor ah, ah
div bl

divide_overflow:
    ; Handle error - use larger division or different approach
```

**Division by Zero:**

```assembly
; This causes #DE (divide error) exception!
mov eax, 100
xor edx, edx
xor ebx, ebx        ; EBX = 0
div ebx             ; Divide by zero - CPU exception!

; Always check divisor before dividing
test ebx, ebx
jz division_by_zero ; Jump if divisor is zero

; Safe to divide
div ebx

division_by_zero:
    ; Handle error appropriately
```

**Example - Digit Extraction:**

```assembly
; Extract decimal digits from number (right to left)
; Number: 12345 → extract digits 5, 4, 3, 2, 1

extract_digits:
    mov eax, 12345      ; Number to process
    mov ebx, 10         ; Divisor (decimal base)
    
.loop:
    xor edx, edx        ; Clear remainder
    div ebx             ; EAX = quotient, EDX = remainder (digit)
    
    ; Process digit in EDX (0-9)
    add dl, '0'         ; Convert to ASCII
    ; Store or print DL here
    
    test eax, eax       ; Check if quotient is zero
    jnz .loop           ; Continue if more digits remain
    
    ret

; Loop iterations:
; 1: 12345 ÷ 10 → EAX=1234, EDX=5
; 2: 1234 ÷ 10  → EAX=123,  EDX=4
; 3: 123 ÷ 10   → EAX=12,   EDX=3
; 4: 12 ÷ 10    → EAX=1,    EDX=2
; 5: 1 ÷ 10     → EAX=0,    EDX=1
```

### IDIV (Signed Division)

IDIV performs signed division with the same register usage as DIV but interprets values as signed integers.

**Sign Extension Required:**

```assembly
; 8-bit signed division requires sign-extending AL to AX
mov al, -100        ; AL = 0x9C
cbw                 ; Sign-extend AL to AX (AX = 0xFF9C)
mov bl, 7
idiv bl             ; AL = -14, AH = -2

; 16-bit signed division requires sign-extending AX to DX:AX
mov ax, -1000
cwd                 ; Sign-extend AX to DX:AX
mov cx, 13
idiv cx             ; AX = -76, DX = -12

; 32-bit signed division requires sign-extending EAX to EDX:EAX
mov eax, -1000000
cdq                 ; Sign-extend EAX to EDX:EAX
mov ebx, 256
idiv ebx            ; EAX = -3906, EDX = -64

; 64-bit signed division (64-bit mode)
mov rax, -1000000000
cqo                 ; Sign-extend RAX to RDX:RAX
mov rbx, 65536
idiv rbx            ; RAX = quotient, RDX = remainder
```

**Sign Extension Instructions:**

```assembly
CBW  ; Convert Byte to Word: sign-extend AL to AX
CWD  ; Convert Word to Dword: sign-extend AX to DX:AX
CDQ  ; Convert Dword to Qword: sign-extend EAX to EDX:EAX
CQO  ; Convert Qword to Oword: sign-extend RAX to RDX:RAX (64-bit mode)
```

**Signed Division Examples:**

```assembly
; Positive ÷ Positive
mov ax, 100
cbw                 ; AX = 0x0064 (no change, already positive)
mov bl, 7
idiv bl             ; AL = 14, AH = 2

; Negative ÷ Positive
mov ax, -100        ; AX = 0xFF9C
cbw                 ; Already sign-extended if loaded correctly
mov bl, 7
idiv bl             ; AL = -14 (0xF2), AH = -2 (0xFE)

; Positive ÷ Negative
mov ax, 100
cbw
mov bl, -7          ; BL = 0xF9
idiv bl             ; AL = -14 (0xF2), AH = 2

; Negative ÷ Negative
mov ax, -100
cbw
mov bl, -7
idiv bl             ; AL = 14, AH = -2
```

**Remainder Sign Rules:**

[Inference] The sign of the remainder matches the sign of the dividend in x86 IDIV:

```assembly
;  100 ÷  7 =  14 remainder  2
;  100 ÷ -7 = -14 remainder  2  (remainder has sign of dividend)
; -100 ÷  7 = -14 remainder -2  (remainder has sign of dividend)
; -100 ÷ -7 =  14 remainder -2  (remainder has sign of dividend)

; Verification:
; dividend = (quotient × divisor) + remainder
; 100 = (-14 × -7) + 2 = 98 + 2 = 100 ✓
; -100 = (-14 × 7) + (-2) = -98 + (-2) = -100 ✓
```

**Comparison: DIV vs IDIV:**

```assembly
; Same bit patterns, different interpretations

; Unsigned interpretation (DIV)
mov ax, 0xFF9C      ; 65436 (unsigned)
xor ah, ah          ; Clear AH: AX = 156
mov bl, 7
div bl              ; AL = 22, AH = 2

; Signed interpretation (IDIV)
mov al, 0x9C        ; -100 (signed)
cbw                 ; Sign-extend: AX = 0xFF9C (-100)
mov bl, 7
idiv bl             ; AL = -14 (0xF2), AH = -2 (0xFE)
```

**Example - Integer Division with Rounding:**

```assembly
; Divide and round to nearest integer (banker's rounding)
divide_round:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]    ; Dividend
    mov ebx, [ebp+12]   ; Divisor
    
    ; Check sign for proper rounding
    xor ecx, ecx
    test eax, eax
    setl cl             ; ECX = 1 if dividend negative
    
    cdq                 ; Sign-extend
    idiv ebx            ; EAX = quotient, EDX = remainder
    
    ; Round: if |remainder| >= |divisor|/2, adjust quotient
    push eax            ; Save quotient
    mov eax, edx        ; Get remainder
    add eax, eax        ; remainder × 2
    
    cmp eax, ebx        ; Compare 2×remainder with divisor
    pop eax             ; Restore quotient
    
    jl .done            ; No rounding needed
    
    test ecx, ecx
    jz .positive_round
    dec eax             ; Round negative down
    jmp .done
    
.positive_round:
    inc eax             ; Round positive up
    
.done:
    pop ebp
    ret

; Examples:
; 7 ÷ 2 = 3.5 → 4 (rounded up)
; 6 ÷ 2 = 3.0 → 3 (exact)
; -7 ÷ 2 = -3.5 → -4 (rounded down)
```

**Example - Modulo Operation:**

```assembly
; Get remainder (modulo) of division
; result = value mod divisor

modulo:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]    ; Value
    mov ebx, [ebp+12]   ; Divisor
    
    xor edx, edx        ; For unsigned
    ; or: cdq           ; For signed
    
    div ebx             ; or idiv for signed
                        ; EDX now contains remainder
    
    mov eax, edx        ; Return remainder in EAX
    
    pop ebp
    ret

; Usage: 100 mod 7 = 2
push 7
push 100
call modulo
add esp, 8
; EAX = 2
```

