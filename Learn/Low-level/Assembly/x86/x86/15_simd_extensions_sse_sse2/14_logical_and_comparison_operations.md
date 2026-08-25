## Logical and Comparison Operations


Logical and comparison operations in SSE/SSE2 operate on packed data, performing bitwise operations or generating comparison masks for conditional processing.

### Bitwise Logical Operations

SSE/SSE2 logical operations treat the 128-bit registers as single bit vectors, regardless of the packed data type interpretation.

#### AND Operations

**ANDPS** - Bitwise AND (Packed Single-Precision)

```nasm
andps xmm0, xmm1          ; XMM0 = XMM0 AND XMM1
andps xmm0, [mem]         ; AND with memory operand
```

**ANDPD** - Bitwise AND (Packed Double-Precision)

```nasm
andpd xmm0, xmm1          ; XMM0 = XMM0 AND XMM1
```

**PAND** - Bitwise AND (Integer)

```nasm
pand xmm0, xmm1           ; XMM0 = XMM0 AND XMM1 (128-bit integer)
```

All three instructions perform identical bitwise operations; the naming convention indicates the intended data type interpretation but does not affect execution behavior.

#### AND NOT Operations

**ANDNPS** - Bitwise AND NOT (Packed Single-Precision)

```nasm
andnps xmm0, xmm1         ; XMM0 = (NOT XMM0) AND XMM1
```

**ANDNPD** - Bitwise AND NOT (Packed Double-Precision)

```nasm
andnpd xmm0, xmm1         ; XMM0 = (NOT XMM0) AND XMM1
```

**PANDN** - Bitwise AND NOT (Integer)

```nasm
pandn xmm0, xmm1          ; XMM0 = (NOT XMM0) AND XMM1
```

The AND NOT operation inverts the first operand before performing the AND, useful for masking operations.

**Example** of masking with ANDNPS:

```nasm
; XMM0 contains mask (0xFFFFFFFF for elements to clear)
; XMM1 contains data
andnps xmm0, xmm1         ; Clear masked elements in XMM1
; Result: Elements where XMM0 was 0x00000000 are preserved,
;         Elements where XMM0 was 0xFFFFFFFF are cleared to 0
```

#### OR Operations

**ORPS** - Bitwise OR (Packed Single-Precision)

```nasm
orps xmm0, xmm1           ; XMM0 = XMM0 OR XMM1
```

**ORPD** - Bitwise OR (Packed Double-Precision)

```nasm
orpd xmm0, xmm1           ; XMM0 = XMM0 OR XMM1
```

**POR** - Bitwise OR (Integer)

```nasm
por xmm0, xmm1            ; XMM0 = XMM0 OR XMM1
```

#### XOR Operations

**XORPS** - Bitwise XOR (Packed Single-Precision)

```nasm
xorps xmm0, xmm1          ; XMM0 = XMM0 XOR XMM1
xorps xmm0, xmm0          ; Zero out XMM0 (common idiom)
```

**XORPD** - Bitwise XOR (Packed Double-Precision)

```nasm
xorpd xmm0, xmm1          ; XMM0 = XMM0 XOR XMM1
```

**PXOR** - Bitwise XOR (Integer)

```nasm
pxor xmm0, xmm1           ; XMM0 = XMM0 XOR XMM1
pxor xmm0, xmm0           ; Zero out XMM0
```

**Example** of sign flipping using XOR:

```nasm
; Create mask with sign bit set (0x80000000 for each float)
mov eax, 0x80000000
movd xmm1, eax
shufps xmm1, xmm1, 0      ; Broadcast to all 4 elements

; XMM0 contains four floats
xorps xmm0, xmm1          ; Flip sign bit of all four floats
```

### Floating-Point Comparison Operations

Floating-point comparisons generate masks where each element is either all 1s (true) or all 0s (false). These masks can be used with logical operations for conditional processing.

#### SSE Single-Precision Comparisons

**CMPPS** - Compare Packed Single-Precision

```nasm
cmpps xmm0, xmm1, imm8    ; Compare with predicate
```

**CMPSS** - Compare Scalar Single-Precision

```nasm
cmpss xmm0, xmm1, imm8    ; Compare lowest float only
```

**Comparison predicates** (imm8 values):

- **0**: EQ (equal)
- **1**: LT (less than)
- **2**: LE (less than or equal)
- **3**: UNORD (unordered - NaN comparison)
- **4**: NEQ (not equal)
- **5**: NLT (not less than)
- **6**: NLE (not less than or equal)
- **7**: ORD (ordered - not NaN)

**Mnemonic variants** (assembler pseudo-instructions):

```nasm
cmpeqps xmm0, xmm1        ; Compare equal (predicate 0)
cmpltps xmm0, xmm1        ; Compare less than (predicate 1)
cmpleps xmm0, xmm1        ; Compare less or equal (predicate 2)
cmpunordps xmm0, xmm1     ; Compare unordered (predicate 3)
cmpneqps xmm0, xmm1       ; Compare not equal (predicate 4)
cmpnltps xmm0, xmm1       ; Compare not less (predicate 5)
cmpnleps xmm0, xmm1       ; Compare not less or equal (predicate 6)
cmpordps xmm0, xmm1       ; Compare ordered (predicate 7)
```

**Example** of comparison operation:

```nasm
; XMM0: [1.0][2.5][3.0][4.5]
; XMM1: [1.5][2.0][3.0][4.0]
cmpltps xmm0, xmm1
; XMM0: [0xFFFFFFFF][0x00000000][0x00000000][0x00000000]
;        1.0 < 1.5   2.5 not< 2.0  3.0 not< 3.0  4.5 not< 4.0
```

#### SSE2 Double-Precision Comparisons

**CMPPD** - Compare Packed Double-Precision

```nasm
cmppd xmm0, xmm1, imm8    ; Compare two doubles
```

**CMPSD** - Compare Scalar Double-Precision

```nasm
cmpsd xmm0, xmm1, imm8    ; Compare lowest double only
```

Uses the same predicate values (0-7) as single-precision comparisons.

**Mnemonic variants**:

```nasm
cmpeqpd xmm0, xmm1        ; Compare equal
cmpltpd xmm0, xmm1        ; Compare less than
cmplepd xmm0, xmm1        ; Compare less or equal
cmpunordpd xmm0, xmm1     ; Compare unordered
cmpneqpd xmm0, xmm1       ; Compare not equal
cmpnltpd xmm0, xmm1       ; Compare not less
cmpnlepd xmm0, xmm1       ; Compare not less or equal
cmpordpd xmm0, xmm1       ; Compare ordered
```

#### Comparison with EFLAGS Update

**COMISS** - Compare Scalar Single-Precision and Set EFLAGS

```nasm
comiss xmm0, xmm1         ; Compare and update ZF, PF, CF
```

**COMISD** - Compare Scalar Double-Precision and Set EFLAGS

```nasm
comisd xmm0, xmm1         ; Compare and update ZF, PF, CF
```

**UCOMISS** - Unordered Compare Scalar Single-Precision

```nasm
ucomiss xmm0, xmm1        ; Compare (NaN-safe) and update flags
```

**UCOMISD** - Unordered Compare Scalar Double-Precision

```nasm
ucomisd xmm0, xmm1        ; Compare (NaN-safe) and update flags
```

These instructions update EFLAGS for use with conditional jump instructions:

- **ZF=1, PF=1, CF=1**: Unordered (NaN present)
- **ZF=1, PF=0, CF=0**: Equal
- **ZF=0, PF=0, CF=1**: Less than
- **ZF=0, PF=0, CF=0**: Greater than

**Example** with conditional branching:

```nasm
comiss xmm0, xmm1
ja greater_label          ; Jump if XMM0 > XMM1
je equal_label            ; Jump if XMM0 == XMM1
jb less_label             ; Jump if XMM0 < XMM1
jp unordered_label        ; Jump if unordered (NaN)
```

### Integer Comparison Operations

SSE2 provides packed integer comparisons that generate element-wise masks.

#### Byte Comparisons

**PCMPEQB** - Compare Packed Bytes for Equal

```nasm
pcmpeqb xmm0, xmm1        ; Compare 16 bytes
```

**PCMPGTB** - Compare Packed Signed Bytes for Greater Than

```nasm
pcmpgtb xmm0, xmm1        ; Compare 16 signed bytes
```

#### Word Comparisons

**PCMPEQW** - Compare Packed Words for Equal

```nasm
pcmpeqw xmm0, xmm1        ; Compare 8 words
```

**PCMPGTW** - Compare Packed Signed Words for Greater Than

```nasm
pcmpgtw xmm0, xmm1        ; Compare 8 signed words
```

#### Doubleword Comparisons

**PCMPEQD** - Compare Packed Doublewords for Equal

```nasm
pcmpeqd xmm0, xmm1        ; Compare 4 doublewords
```

**PCMPGTD** - Compare Packed Signed Doublewords for Greater Than

```nasm
pcmpgtd xmm0, xmm1        ; Compare 4 signed doublewords
```

**Example** of integer comparison:

```nasm
; XMM0: [10][20][30][40] (4 doublewords)
; XMM1: [15][20][25][45] (4 doublewords)
pcmpgtd xmm0, xmm1
; XMM0: [0x00000000][0x00000000][0xFFFFFFFF][0x00000000]
;        10 not> 15   20 not> 20   30 > 25      40 not> 45
```

### Conditional Selection Using Masks

Comparison masks enable conditional selection without branching through combination of logical operations.

**Example** of conditional selection (blend operation):

```nasm
; Select elements from XMM1 where condition is true, else from XMM2
; XMM0 contains comparison mask (result from cmpps/cmppd/pcmp*)

; Method: result = (mask AND a) OR ((NOT mask) AND b)
movaps xmm3, xmm0         ; Copy mask
andps xmm0, xmm1          ; Mask AND XMM1
andnps xmm3, xmm2         ; (NOT mask) AND XMM2
orps xmm0, xmm3           ; Combine results
; XMM0 now contains conditional selection
```

