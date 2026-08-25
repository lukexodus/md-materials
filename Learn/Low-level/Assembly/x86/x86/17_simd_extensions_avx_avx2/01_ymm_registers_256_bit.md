## YMM Registers (256-bit)


AVX introduces 256-bit vector registers that extend the SSE architecture while maintaining backward compatibility with existing XMM registers.

### Register Architecture

AVX provides sixteen 256-bit registers designated YMM0 through YMM15 in 64-bit mode, and eight registers (YMM0-YMM7) in 32-bit mode.

**Register organization**:

```
YMM0:  255                                   128 127                                    0
       +---------------------------------------+---------------------------------------+
       |            YMM0[255:128]              |            YMM0[127:0]                |
       |            (Upper 128 bits)           |         (XMM0 - Lower 128 bits)       |
       +---------------------------------------+---------------------------------------+
```

**Key architectural features**:

- **Width**: 256 bits per register
- **Count**: 16 registers (64-bit mode), 8 registers (32-bit mode)
- **Aliasing**: Lower 128 bits of YMM registers alias with XMM registers
- **Upper bits**: YMM0[127:0] = XMM0, YMM1[127:0] = XMM1, etc.

### Register Aliasing Behavior

The lower 128 bits of each YMM register directly map to the corresponding XMM register. This aliasing creates specific behavior patterns:

**Writing to XMM registers**: When an SSE instruction writes to an XMM register, the upper 128 bits of the corresponding YMM register are zeroed.

**Example** of register zeroing:

```nasm
; YMM0 contains: [255:128] = 0x1111... , [127:0] = 0x2222...
vmovaps ymm0, [mem256]         ; Load 256 bits into YMM0

; Use SSE instruction on XMM0
movaps xmm0, [mem128]          ; Write to XMM0
; Now YMM0[255:128] = 0x0000... (zeroed)
; And YMM0[127:0] = loaded value
```

**Writing to YMM registers**: AVX instructions that write to YMM registers update all 256 bits. The corresponding XMM register reflects the lower 128 bits.

**Reading from registers**: Reading XMM registers accesses the lower 128 bits of YMM registers. Reading YMM registers accesses all 256 bits.

### Register Naming Convention

AVX maintains consistent naming across vector widths:

- **YMM**: 256-bit registers (YMM0-YMM15)
- **XMM**: 128-bit registers (XMM0-XMM15), alias to YMM[127:0]
- **ZMM**: 512-bit registers in AVX-512 (ZMM0-ZMM31), not covered here

### Data Types and Layout

YMM registers support multiple data type interpretations, doubling the element count compared to XMM registers.

#### Packed Single-Precision Floats (PS)

**Format**: Eight 32-bit floats per register

```
255     224 223     192 191     160 159     128 127      96 95       64 63       32 31        0
+-----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
|   Float7  |   Float6  |   Float5  |   Float4  |   Float3  |   Float2  |   Float1  |   Float0  |
+-----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
```

- **Element count**: 8 floats
- **Element size**: 32 bits each
- **Use cases**: Graphics, physics, signal processing

#### Packed Double-Precision Floats (PD)

**Format**: Four 64-bit doubles per register

```
255                   192 191                   128 127                    64 63                      0
+-----------------------+-----------------------+-----------------------+-----------------------+
|       Double3         |       Double2         |       Double1         |       Double0         |
+-----------------------+-----------------------+-----------------------+-----------------------+
```

- **Element count**: 4 doubles
- **Element size**: 64 bits each
- **Use cases**: Scientific computing, high-precision calculations

#### Packed Integers (AVX2)

AVX2 extends integer operations to 256-bit width.

**Packed Bytes**: Thirty-two 8-bit integers

```
255   248 247   240 ... 31    24 23    16 15     8 7      0
+-------+-------+...+-------+-------+-------+-------+
| Byte31| Byte30|...| Byte3 | Byte2 | Byte1 | Byte0 |
+-------+-------+...+-------+-------+-------+-------+
```

**Packed Words**: Sixteen 16-bit integers

```
255       240 239       224 ... 31        16 15         0
+-----------+-----------+...+-----------+-----------+
|   Word15  |   Word14  |...|   Word1   |   Word0   |
+-----------+-----------+...+-----------+-----------+
```

**Packed Doublewords**: Eight 32-bit integers

```
255           224 223           192 ... 63            32 31             0
+---------------+---------------+...+---------------+---------------+
|    Dword7     |    Dword6     |...|    Dword1     |    Dword0     |
+---------------+---------------+...+---------------+---------------+
```

**Packed Quadwords**: Four 64-bit integers

```
255                   192 191                   128 127                    64 63                      0
+-----------------------+-----------------------+-----------------------+-----------------------+
|       Qword3          |       Qword2          |       Qword1          |       Qword0          |
+-----------------------+-----------------------+-----------------------+-----------------------+
```

