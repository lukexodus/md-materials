## MXCSR Control Register


The MXCSR (SSE Control and Status Register) controls floating-point operation behavior and reports exceptions.

**MXCSR bit layout**:

- **Bits 0-5**: Exception flags (IE, DE, ZE, OE, UE, PE)
- **Bits 6**: DAZ (Denormals Are Zero)
- **Bits 7-12**: Exception masks (IM, DM, ZM, OM, UM, PM)
- **Bits 13-14**: Rounding control (00=nearest, 01=down, 10=up, 11=toward zero)
- **Bit 15**: FTZ (Flush To Zero)

**LDMXCSR** - Load MXCSR Register

```nasm
ldmxcsr [mem]             ; Load 32-bit value into MXCSR
```

**STMXCSR** - Store MXCSR Register

```nasm
stmxcsr [mem]             ; Store MXCSR to 32-bit memory location
```

**Example** of setting rounding mode:

```nasm
; Set rounding mode to truncate (toward zero)
stmxcsr [temp_mxcsr]      ; Save current MXCSR
mov eax, [temp_mxcsr]
and eax, 0xFFFF9FFF       ; Clear rounding control bits
or eax, 0x6000            ; Set bits 13-14 to 11 (toward zero)
mov [temp_mxcsr], eax
ldmxcsr [temp_mxcsr]      ; Load modified MXCSR

; ... perform conversions with truncation ...

; Restore original MXCSR
ldmxcsr [original_mxcsr]
```

**Example** of enabling flush-to-zero mode:

```nasm
; Enable FTZ to treat denormals as zero (performance optimization)
stmxcsr [mxcsr_storage]
mov eax, [mxcsr_storage]
or eax, 0x8000            ; Set bit 15 (FTZ)
mov [mxcsr_storage], eax
ldmxcsr [mxcsr_storage]
```

