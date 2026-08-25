## Packed Arithmetic Operations


MMX arithmetic instructions operate on packed data types, performing the same operation simultaneously on all elements. Operations are categorized by arithmetic type and saturation behavior.

### Basic Arithmetic Instructions

#### Addition Operations

**PADDB** - Packed Add Bytes

```nasm
paddb mm0, mm1        ; Add 8 bytes in parallel
```

Each of the 8 bytes in MM0 is added to the corresponding byte in MM1, with wraparound on overflow.

**PADDW** - Packed Add Words

```nasm
paddw mm0, mm1        ; Add 4 words in parallel
```

**PADDD** - Packed Add Doublewords

```nasm
paddd mm0, mm1        ; Add 2 doublewords in parallel
```

**Example** of parallel byte addition:

```nasm
; MM0: [10][20][30][40][50][60][70][80]
; MM1: [05][10][15][20][25][30][35][40]
paddb mm0, mm1
; MM0: [15][30][45][60][75][90][105][120]
```

#### Subtraction Operations

**PSUBB** - Packed Subtract Bytes

```nasm
psubb mm0, mm1        ; Subtract 8 bytes in parallel
```

**PSUBW** - Packed Subtract Words

```nasm
psubw mm0, mm1        ; Subtract 4 words in parallel
```

**PSUBD** - Packed Subtract Doublewords

```nasm
psubd mm0, mm1        ; Subtract 2 doublewords in parallel
```

### Saturating Arithmetic

Saturating arithmetic clamps results to the maximum or minimum representable value instead of wrapping around on overflow/underflow. This behavior is essential for multimedia applications where wraparound produces visually incorrect results.

#### Saturating Addition

**PADDSB** - Packed Add with Saturation (Signed Bytes)

```nasm
paddsb mm0, mm1       ; Add with saturation to -128/+127
```

**PADDSW** - Packed Add with Saturation (Signed Words)

```nasm
paddsw mm0, mm1       ; Add with saturation to -32768/+32767
```

**PADDUSB** - Packed Add Unsigned with Saturation (Bytes)

```nasm
paddusb mm0, mm1      ; Add with saturation to 0/255
```

**PADDUSW** - Packed Add Unsigned with Saturation (Words)

```nasm
paddusw mm0, mm1      ; Add with saturation to 0/65535
```

**Example** showing saturation behavior:

```nasm
; Signed byte saturation
; MM0: [120][100][-100][-120][50][60][70][80]
; MM1: [20][50][-50][-20][10][20][30][40]
paddsb mm0, mm1
; MM0: [127][127][-128][-128][60][80][100][120]
;       ^^^  ^^^  ^^^^  ^^^^  (saturated values)

; Unsigned byte saturation
; MM0: [250][200][150][100][50][60][70][80]
; MM1: [20][100][50][20][10][20][30][40]
paddusb mm0, mm1
; MM0: [255][255][200][120][60][80][100][120]
;       ^^^  ^^^  (saturated to 255)
```

#### Saturating Subtraction

**PSUBSB** - Packed Subtract with Saturation (Signed Bytes)

```nasm
psubsb mm0, mm1       ; Subtract with saturation
```

**PSUBSW** - Packed Subtract with Saturation (Signed Words)

```nasm
psubsw mm0, mm1
```

**PSUBUSB** - Packed Subtract Unsigned with Saturation (Bytes)

```nasm
psubusb mm0, mm1      ; Subtract with saturation to 0
```

**PSUBUSW** - Packed Subtract Unsigned with Saturation (Words)

```nasm
psubusw mm0, mm1
```

### Multiplication Operations

MMX provides multiplication instructions that produce different result sizes based on the operation type.

**PMULLW** - Packed Multiply Low (Words)

```nasm
pmullw mm0, mm1       ; Multiply 4 words, keep low 16 bits
```

Multiplies four 16-bit signed values and stores the lower 16 bits of each 32-bit result.

**PMULHW** - Packed Multiply High (Words)

```nasm
pmulhw mm0, mm1       ; Multiply 4 words, keep high 16 bits
```

Multiplies four 16-bit signed values and stores the upper 16 bits of each 32-bit result.

**PMADDWD** - Packed Multiply and Add (Words to Doublewords)

```nasm
pmaddwd mm0, mm1      ; Multiply-accumulate operation
```

Multiplies four pairs of 16-bit values, producing four 32-bit intermediate products, then adds adjacent pairs to produce two 32-bit results.

**Example** of PMADDWD operation:

```nasm
; MM0: [w3][w2][w1][w0]  (4 words)
; MM1: [v3][v2][v1][v0]  (4 words)
pmaddwd mm0, mm1
; MM0: [w3*v3 + w2*v2][w1*v1 + w0*v0]  (2 doublewords)
```

### Comparison Operations

MMX comparison instructions perform element-wise comparisons and generate masks (all 1s for true, all 0s for false).

**PCMPEQB/W/D** - Packed Compare for Equal

```nasm
pcmpeqb mm0, mm1      ; Compare 8 bytes for equality
pcmpeqw mm0, mm1      ; Compare 4 words for equality
pcmpeqd mm0, mm1      ; Compare 2 doublewords for equality
```

**PCMPGTB/W/D** - Packed Compare for Greater Than (Signed)

```nasm
pcmpgtb mm0, mm1      ; Compare 8 signed bytes
pcmpgtw mm0, mm1      ; Compare 4 signed words
pcmpgtd mm0, mm1      ; Compare 2 signed doublewords
```

**Example** of comparison masking:

```nasm
; MM0: [10][20][30][40][50][60][70][80]
; MM1: [15][20][25][40][55][60][65][80]
pcmpgtb mm0, mm1
; MM0: [00][00][FF][00][00][00][FF][00]
;            ^ 30>25      ^ 70>65
```

### Logical Operations

MMX provides standard bitwise logical operations that operate on entire 64-bit registers regardless of packed data type.

**PAND** - Bitwise AND

```nasm
pand mm0, mm1         ; MM0 = MM0 AND MM1
```

**PANDN** - Bitwise AND NOT

```nasm
pandn mm0, mm1        ; MM0 = (NOT MM0) AND MM1
```

**POR** - Bitwise OR

```nasm
por mm0, mm1          ; MM0 = MM0 OR MM1
```

**PXOR** - Bitwise XOR

```nasm
pxor mm0, mm1         ; MM0 = MM0 XOR MM1
pxor mm0, mm0         ; Common idiom to zero a register
```

### Shift Operations

MMX provides both logical and arithmetic shifts on packed data types.

**Logical Shifts**

**PSRLW/D/Q** - Packed Shift Right Logical

```nasm
psrlw mm0, mm1        ; Shift 4 words right (zero fill)
psrlw mm0, 3          ; Shift 4 words right by 3 bits
psrld mm0, mm1        ; Shift 2 doublewords right
psrlq mm0, mm1        ; Shift entire quadword right
```

**PSLLW/D/Q** - Packed Shift Left Logical

```nasm
psllw mm0, mm1        ; Shift 4 words left (zero fill)
pslld mm0, 4          ; Shift 2 doublewords left by 4 bits
psllq mm0, mm1        ; Shift entire quadword left
```

**Arithmetic Shifts**

**PSRAW/D** - Packed Shift Right Arithmetic

```nasm
psraw mm0, mm1        ; Shift 4 words right (sign extend)
psraw mm0, 2          ; Shift 4 words right by 2 bits
psrad mm0, mm1        ; Shift 2 doublewords right (sign extend)
```

**Example** demonstrating shift behavior:

```nasm
; Logical shift (zero fill)
; MM0 (words): [0x8000][0x4000][0x2000][0x1000]
psrlw mm0, 1
; MM0:         [0x4000][0x2000][0x1000][0x0800]

; Arithmetic shift (sign extend)
; MM0 (words): [0x8000][0x4000][0x2000][0x1000]  (as signed: -32768, 16384, 8192, 4096)
psraw mm0, 1
; MM0:         [0xC000][0x2000][0x1000][0x0800]  (as signed: -16384, 8192, 4096, 2048)
```

### Pack and Unpack Operations

These operations convert between different packed data types with saturation or interleaving.

**Pack Operations**

**PACKSSWB** - Pack Signed Words to Signed Bytes with Saturation

```nasm
packsswb mm0, mm1     ; Pack 4+4 words into 8 bytes
```

Converts eight 16-bit signed integers into eight 8-bit signed integers with saturation.

**PACKSSDW** - Pack Signed Doublewords to Signed Words with Saturation

```nasm
packssdw mm0, mm1     ; Pack 2+2 doublewords into 4 words
```

**PACKUSWB** - Pack Unsigned Words to Unsigned Bytes with Saturation

```nasm
packuswb mm0, mm1     ; Pack 4+4 words into 8 bytes (unsigned)
```

**Unpack Operations**

**PUNPCKLBW** - Unpack Low Bytes to Words

```nasm
punpcklbw mm0, mm1    ; Interleave low 4 bytes
```

**PUNPCKHBW** - Unpack High Bytes to Words

```nasm
punpckhbw mm0, mm1    ; Interleave high 4 bytes
```

**PUNPCKLWD** - Unpack Low Words to Doublewords

```nasm
punpcklwd mm0, mm1    ; Interleave low 2 words
```

**PUNPCKHWD** - Unpack High Words to Doublewords

```nasm
punpckhwd mm0, mm1    ; Interleave high 2 words
```

**PUNPCKLDQ** - Unpack Low Doublewords to Quadword

```nasm
punpckldq mm0, mm1    ; Interleave low doublewords
```

**PUNPCKHDQ** - Unpack High Doublewords to Quadword

```nasm
punpckhdq mm0, mm1    ; Interleave high doublewords
```

**Example** of unpacking operation:

```nasm
; MM0: [A7][A6][A5][A4][A3][A2][A1][A0]
; MM1: [B7][B6][B5][B4][B3][B2][B1][B0]
punpcklbw mm0, mm1
; MM0: [B3][A3][B2][A2][B1][A1][B0][A0]
;       Interleaved low 4 bytes from each register
```

