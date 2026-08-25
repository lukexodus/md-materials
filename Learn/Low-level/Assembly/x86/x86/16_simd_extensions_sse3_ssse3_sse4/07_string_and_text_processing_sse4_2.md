## String and Text Processing (SSE4.2)


SSE4.2 introduced specialized instructions for string comparison, pattern matching, and CRC32 computation that accelerate text processing and data integrity operations.

### Packed Compare Strings

**PCMPESTRI** (Packed Compare Explicit Length Strings, Return Index) and **PCMPESTRM** (Return Mask) compare two string operands of explicitly specified lengths. The instructions support various comparison modes controlled by an immediate operand, including equality testing, ranges, substring search, and character set membership.

The control byte specifies:

- Source data format (bytes or words)
- Aggregation operation (equal any, ranges, equal each, equal ordered)
- Polarity (positive, negative, masked positive, masked negative)
- Output selection (index or mask)

**PCMPISTRI** and **PCMPISTRM** provide similar functionality for implicit-length strings (null-terminated), determining string length automatically.

**Example**: Finding first occurrence of character

```nasm
movdqu xmm0, [haystack]     ; String to search
movd xmm1, eax              ; Character to find (in EAX)
pcmpistri xmm1, xmm0, 0x00  ; Equal any, return index in ECX
jc found                     ; CF=1 if match found
```

Control byte fields:

- Bits 0-1: Source data format (00=bytes, 01=words)
- Bits 2-3: Aggregation (00=equal any, 01=ranges, 10=equal each, 11=equal ordered)
- Bits 4-5: Polarity modification
- Bit 6: Output selection (0=index, 1=mask)

The instructions set processor flags indicating various conditions:

- CF (Carry): Set if match/terminator found in source
- ZF (Zero): Set if match/terminator found in destination
- SF (Sign): Set if source length is less than 16
- OF (Overflow): Set if destination length is less than 16

ECX receives the result index for *I variants, while XMM0 receives the bit mask for *M variants.

### Substring Search Applications

[Inference] These instructions efficiently implement substring search, token parsing, and validation operations that would otherwise require complex scalar code with branches. The hardware performs parallel comparison of up to 16 bytes simultaneously.

**Example**: Validating decimal digits

```nasm
section .data
align 16
digit_ranges: db '0', '9'   ; Range definition
              times 14 db 0

section .text
movdqu xmm0, [input_string]
movdqu xmm1, [digit_ranges]
pcmpistrm xmm1, xmm0, 0x14  ; Range test, return mask
pmovmskb eax, xmm0          ; Extract mask to EAX
cmp ax, 0xFFFF              ; Check if all matched
je all_digits_valid
```

### CRC32 Instruction

**CRC32** computes the Cyclic Redundancy Check value using the CRC-32C (Castagnoli) polynomial (0x1EDC6F41), which differs from the CRC-32 polynomial used in Ethernet and ZIP files. The instruction accumulates the CRC value through successive invocations on byte, word, or doubleword operands.

```nasm
xor eax, eax                ; Initialize CRC
crc32 eax, byte [data]      ; Process byte
crc32 eax, byte [data+1]
crc32 eax, dword [data+2]   ; Process dword
```

The instruction operates on general-purpose registers rather than XMM registers, updating the destination register with the new CRC value after processing the source operand.

**Example**: Computing CRC of buffer

```nasm
xor eax, eax                ; CRC accumulator
mov ecx, buffer_length
mov rsi, buffer_ptr

crc_loop:
    crc32 eax, byte [rsi]
    inc rsi
    dec ecx
    jnz crc_loop
    
; EAX now contains CRC32C value
```

[Inference] The CRC32 instruction provides significant acceleration over software implementations by computing the CRC in a single cycle per invocation, though memory access latency may still dominate performance for streaming operations.

### Population Count

**POPCNT** counts the number of bits set to 1 in the source operand, operating on byte, word, doubleword, or quadword general-purpose register values. While categorized with SSE4.2, POPCNT operates on general-purpose registers and has separate CPUID detection.

```nasm
mov rax, 0x0F0F0F0F0F0F0F0F
popcnt rcx, rax             ; RCX = 32 (bit count)
```

This instruction accelerates bit manipulation algorithms, including Hamming distance computation, bit array operations, and combinatorial calculations.

