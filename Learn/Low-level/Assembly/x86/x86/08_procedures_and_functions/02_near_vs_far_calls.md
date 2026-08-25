## Near vs Far Calls


The distinction between near and far calls relates to segmented memory models used in real mode and 16-bit protected mode. This affects how much information is stored for the return address.

**Near Calls:**

- Transfer control within the same code segment
- Only the offset (IP/EIP) is pushed onto the stack
- Default in 32-bit and 64-bit flat memory models
- Uses 2 bytes (16-bit) or 4 bytes (32-bit) for return address

```assembly
; Near call (32-bit)
call near procedure    ; Pushes only EIP
                      ; Stack: ESP -> [4-byte offset]
```

**Far Calls:**

- Transfer control to a different code segment
- Both segment selector (CS) and offset (IP/EIP) are pushed
- Used in segmented memory models (real mode, 16-bit protected mode)
- Uses 4 bytes (16-bit: 2 CS + 2 IP) or 6 bytes (32-bit: 2 CS + 4 EIP)

```assembly
; Far call (16-bit real mode)
call far 0x1000:0x0050    ; Pushes CS, then IP
                          ; Stack: SP -> [2-byte IP]
                          ;              [2-byte CS]

; Far return
retf                      ; Pops IP, then CS
```

**Modern Usage:** In 32-bit and 64-bit flat memory models (Windows, Linux), far calls are rarely used since all code resides in a single logical address space. Near calls are the standard.

**Example - Segment Transition (16-bit):**

```assembly
; Real mode far call example
segment1:
    mov ax, 0x1234
    call far segment2:proc2    ; CS:IP both change
    ; Return here
    
segment2:
proc2:
    mov bx, ax
    retf                       ; Far return, restore CS:IP
```

