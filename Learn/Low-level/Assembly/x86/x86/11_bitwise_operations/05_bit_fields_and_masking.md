## Bit Fields and Masking


### Single Bit Field Operations

**Define bit field masks:**

```nasm
; Using constants
FLAG_ENABLED    equ 0x01                ; Bit 0
FLAG_VISIBLE    equ 0x02                ; Bit 1
FLAG_ACTIVE     equ 0x04                ; Bit 2
FLAG_SELECTED   equ 0x08                ; Bit 3

MASK_LOWER_NIBBLE  equ 0x0F             ; Bits 0-3
MASK_UPPER_NIBBLE  equ 0xF0             ; Bits 4-7
MASK_LOWER_BYTE    equ 0x00FF           ; Bits 0-7
MASK_UPPER_BYTE    equ 0xFF00           ; Bits 8-15
```

**Set bit field to specific value:**

```nasm
; Set bits 7:4 to value 0101
mov al, current_value
and al, 0x0F                            ; Clear bits 7:4
or al, 0x50                             ; Set bits 7:4 to 0101

; Generic: set N-bit field at position P to value V
mov eax, current_value
mov ebx, (1 << N) - 1                   ; Create N-bit mask
shl ebx, P                              ; Position mask
not ebx                                 ; Invert for clearing
and eax, ebx                            ; Clear field
mov ebx, V
shl ebx, P                              ; Position new value
or eax, ebx                             ; Insert new value
```

### Multi-Bit Field Extraction

**Extract field without shift (using mask only):**

```nasm
; Check if bits 6:4 equal specific pattern
mov al, value
and al, 0x70                            ; Isolate bits 6:4
cmp al, 0x30                            ; Compare with pattern 011
je pattern_match
```

**Extract and normalize field:**

```nasm
; Extract 5-bit field at position 3 (bits 7:3)
mov al, value
shr al, 3                               ; Shift to bit 0
and al, 0x1F                            ; Mask to 5 bits (31 max)

; Extract 12-bit field spanning byte boundary
mov ax, word [data]                     ; Load 16 bits
shr ax, 4                               ; Shift to position
and ax, 0x0FFF                          ; Mask to 12 bits
```

**Extract signed bit field:**

```nasm
; Extract 6-bit signed field at bits 9:4
mov ax, word [data]
shr ax, 4                               ; Shift to position
and ax, 0x3F                            ; Mask to 6 bits

; Sign extend from bit 5 to 16 bits
test ax, 0x20                           ; Test sign bit
jz positive                             ; If 0, already correct
or ax, 0xFFC0                           ; Sign extend with 1s
positive:
    ; AX now contains sign-extended value

; Alternative using arithmetic shift
mov ax, word [data]
shl ax, 6                               ; Shift sign bit to position 15
sar ax, 10                              ; Arithmetic shift preserves sign
```

### Multi-Bit Field Insertion

**Insert field at specific position:**

```nasm
; Insert 4-bit value into bits 7:4
mov al, target_value
and al, 0x0F                            ; Clear destination bits
mov bl, field_value
and bl, 0x0F                            ; Mask source to 4 bits
shl bl, 4                               ; Shift to position
or al, bl                               ; Insert field
mov target_value, al

; Insert 10-bit field at bit position 5
mov eax, target_value
mov ebx, 0x7FE0                         ; Mask for bits 14:5
not ebx                                 ; Invert: 0xFFFF801F
and eax, ebx                            ; Clear destination field
mov ecx, field_value
and ecx, 0x3FF                          ; Mask to 10 bits
shl ecx, 5                              ; Position field
or eax, ecx                             ; Insert field
mov target_value, eax
```

**Replace field preserving other bits:**

```nasm
; Replace bits 11:6 with new value
mov ax, current_value
and ax, 0xF03F                          ; Clear bits 11:6 (keep others)
mov bx, new_value
and bx, 0x003F                          ; Ensure 6 bits max
shl bx, 6                               ; Position to bits 11:6
or ax, bx                               ; Merge with preserved bits
```

### Complex Field Operations

**Swap two bit fields:**

```nasm
; Swap fields at bits 7:4 and 3:0
mov al, value
mov bl, al                              ; Copy original
and al, 0x0F                            ; Extract lower field
shl al, 4                               ; Move to upper position
and bl, 0xF0                            ; Extract upper field
shr bl, 4                               ; Move to lower position
or al, bl                               ; Combine swapped fields
```

**Conditional field modification:**

```nasm
; If bit 7 is set, clear bits 3:0, otherwise set them
mov al, value
test al, 0x80                           ; Test bit 7
jz set_lower
    and al, 0xF0                        ; Clear lower 4 bits
    jmp done
set_lower:
    or al, 0x0F                         ; Set lower 4 bits
done:
```

**Merge multiple fields:**

```nasm
; Combine three fields: field1 (4 bits), field2 (3 bits), field3 (5 bits)
mov al, field1
and al, 0x0F                            ; Ensure 4 bits
shl al, 8                               ; Position at bits 11:8

mov bl, field2
and bl, 0x07                            ; Ensure 3 bits
shl bl, 5                               ; Position at bits 7:5
or al, bl

mov cl, field3
and cl, 0x1F                            ; Ensure 5 bits
or al, cl                               ; Position at bits 4:0

; AL now contains: [field1:4][field2:3][field3:5]
```

### Bit Field Structures

**Define bit field structure using constants:**

```nasm
; Status register bit field definition
STATUS_MODE_POS     equ 0
STATUS_MODE_MASK    equ 0x0003          ; Bits 1:0
STATUS_PRIORITY_POS equ 2
STATUS_PRIORITY_MASK equ 0x001C         ; Bits 4:2
STATUS_FLAGS_POS    equ 5
STATUS_FLAGS_MASK   equ 0x00E0          ; Bits 7:5
STATUS_STATE_POS    equ 8
STATUS_STATE_MASK   equ 0x0F00          ; Bits 11:8

; Accessor macros (conceptual - actual implementation varies by assembler)
; Get mode field
mov ax, [status_reg]
and ax, STATUS_MODE_MASK
shr ax, STATUS_MODE_POS                 ; AX = mode value

; Set priority field
mov ax, [status_reg]
and ax, ~STATUS_PRIORITY_MASK           ; Clear priority bits
mov bx, new_priority
and bx, 0x07                            ; Ensure 3 bits
shl bx, STATUS_PRIORITY_POS
or ax, bx
mov [status_reg], ax
```

**Packed structure example:**

```nasm
; RGB565 color format: RRRRRGGG GGGBBBBB
section .data
    color_value dw 0xF800               ; Red = 31, Green = 0, Blue = 0

section .text
    ; Extract RGB components
    mov ax, [color_value]
    
    ; Extract red (bits 15:11)
    mov bx, ax
    shr bx, 11
    and bx, 0x1F                        ; Red component (0-31)
    
    ; Extract green (bits 10:5)
    mov cx, ax
    shr cx, 5
    and cx, 0x3F                        ; Green component (0-63)
    
    ; Extract blue (bits 4:0)
    mov dx, ax
    and dx, 0x1F                        ; Blue component (0-31)
    
    ; Convert to RGB888 (8 bits per channel)
    shl bx, 3                           ; Red: 5 bits → 8 bits
    shl cx, 2                           ; Green: 6 bits → 8 bits
    shl dx, 3                           ; Blue: 5 bits → 8 bits
```

