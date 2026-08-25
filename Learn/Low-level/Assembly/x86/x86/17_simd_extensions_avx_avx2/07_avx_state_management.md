## AVX State Management


### XSAVE/XRSTOR

AVX extends the x87/SSE state management with XSAVE/XRSTOR instructions for saving and restoring extended processor state.

**XSAVE** - Save Processor Extended States

```nasm
xsave [mem]                       ; Save state specified by EDX:EAX
```

**XRSTOR** - Restore Processor Extended States

```nasm
xrstor [mem]                      ; Restore state specified by EDX:EAX
```

**State components** (EDX:EAX bit mask):

- **Bit 0**: x87 FPU state
- **Bit 1**: SSE state (XMM registers)
- **Bit 2**: AVX state (YMM upper halves)
- **Additional bits**: For AVX-512 and other extensions

**Example** of context switching:

```nasm
; Save AVX state before context switch
mov eax, 0x07                     ; x87 + SSE + AVX
xor edx, edx
xsave [context_buffer]

; ... context switch ...

; Restore AVX state
mov eax, 0x07
xor edx, edx
xrstor [context_buffer]
```

### VEX Prefix Details

The VEX prefix encodes AVX instructions with several fields:

**2-byte VEX format** (C5h):

- Byte 0: 0xC5
- Byte 1: R, vvvv, L, pp fields

**3-byte VEX format** (C4h):

- Byte 0: 0xC4
- Byte 1: RXB, m-mmmm fields
- Byte 2: W, vvvv, L, pp fields

**Key fields**:

- **vvvv**: Encodes additional source register (inverted, 4 bits)
- **L**: Vector length (0=128-bit, 1=256-bit)
- **pp**: Implied prefix (00=none, 01=66h, 10=F3h, 11=F2h)
- **W**: Operand size or opcode extension
- **RXB**: Register extensions for 64-bit mode

This encoding enables the three-operand format and efficient instruction representation.

