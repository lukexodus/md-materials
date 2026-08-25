## SIMD Instructions Basics


SIMD (Single Instruction Multiple Data) instructions perform the same operation on multiple data elements simultaneously within a single register. ARM architectures provide SIMD capabilities through NEON extensions (Advanced SIMD) and earlier SIMD instructions in ARMv6.

### SIMD Architecture Overview

**Register Organization**

NEON provides 32 64-bit registers (D0-D31) or 16 128-bit registers (Q0-Q15) for SIMD operations. Q registers are formed by pairs of D registers: Q0 = {D1, D0}, Q1 = {D3, D2}, etc. These registers are separate from the general-purpose r0-r15 registers.

**Data Type Support**

SIMD instructions operate on vectors of 8-bit, 16-bit, 32-bit, or 64-bit elements. A 128-bit Q register can hold sixteen 8-bit values, eight 16-bit values, four 32-bit values, or two 64-bit values. Instructions specify element size with suffixes: .8, .16, .32, .64.

**Signed and Unsigned Operations**

Most SIMD instructions have signed and unsigned variants, indicated by additional suffixes. For example, VADD.I16 adds signed or unsigned 16-bit integers (same operation), while VMAX.S16 finds maximum treating values as signed, and VMAX.U16 treats them as unsigned.

### Basic NEON Instructions

**VADD - Vector Addition**

VADD adds corresponding elements from two source vectors, storing results in a destination vector. All additions occur in parallel.

**Example:**

```assembly
@ Add eight 16-bit values in parallel
@ Q0 = {a0, a1, a2, a3, a4, a5, a6, a7}
@ Q1 = {b0, b1, b2, b3, b4, b5, b6, b7}
VADD.I16 Q2, Q0, Q1
@ Q2 = {a0+b0, a1+b1, a2+b2, a3+b3, a4+b4, a5+b5, a6+b6, a7+b7}

@ Add four 32-bit values in parallel
VADD.I32 Q3, Q4, Q5

@ Add sixteen 8-bit values in parallel
VADD.I8 Q6, Q7, Q8
```

**VSUB - Vector Subtraction**

VSUB subtracts corresponding elements of the second vector from the first vector.

**Example:**

```assembly
VSUB.I16 Q0, Q1, Q2         @ Q0 = Q1 - Q2 (eight 16-bit subtractions)
VSUB.I32 D0, D1, D2         @ D0 = D1 - D2 (two 32-bit subtractions)
```

**VMUL - Vector Multiplication**

VMUL multiplies corresponding elements from two vectors. [Inference: The result width typically matches input width, potentially losing high-order bits for large products].

**Example:**

```assembly
VMUL.I16 Q0, Q1, Q2         @ Q0 = Q1 * Q2 (eight 16-bit multiplications)
VMUL.I32 D0, D1, D2         @ D0 = D1 * D2 (two 32-bit multiplications)
```

**VMAX/VMIN - Vector Maximum/Minimum**

VMAX computes the maximum of corresponding elements, VMIN computes the minimum. Signed and unsigned variants compare values differently.

**Example:**

```assembly
@ Maximum of signed 16-bit values
VMAX.S16 Q0, Q1, Q2         @ Q0[i] = max(Q1[i], Q2[i])

@ Minimum of unsigned 8-bit values
VMIN.U8 Q3, Q4, Q5          @ Q3[i] = min(Q4[i], Q5[i])
```

**VLD1/VST1 - Vector Load/Store**

VLD1 loads multiple elements from memory into SIMD registers, VST1 stores SIMD registers to memory. These instructions support various configurations for different data layouts.

**Example:**

```assembly
@ Load 128 bits (16 bytes) from memory
VLD1.8 {Q0}, [r0]           @ Load 16 bytes from address in r0

@ Load 64 bits (8 bytes) into D register
VLD1.32 {D0}, [r1]          @ Load 2x32-bit values

@ Store 128 bits to memory
VST1.8 {Q1}, [r2]           @ Store 16 bytes to address in r2

@ Load with post-increment
VLD1.16 {Q2}, [r3]!         @ Load and increment r3 by 16
```

### SIMD Use Cases

**Parallel Arithmetic**

Processing arrays of values benefits from SIMD by operating on multiple elements per instruction. Adding two arrays of 16-bit integers processes eight elements per VADD.I16 instead of one per ADD.

**Example:**

```assembly
@ Add two arrays of 128 16-bit integers
@ r0 = pointer to array A
@ r1 = pointer to array B
@ r2 = pointer to result array
MOV r3, #128/8              @ Loop counter (128 elements / 8 per iteration)
add_arrays:
    VLD1.16 {Q0}, [r0]!     @ Load 8 elements from A, post-increment
    VLD1.16 {Q1}, [r1]!     @ Load 8 elements from B, post-increment
    VADD.I16 Q2, Q0, Q1     @ Add 8 elements in parallel
    VST1.16 {Q2}, [r2]!     @ Store 8 results, post-increment
    SUBS r3, r3, #1
    BNE add_arrays
```

**Color Conversion**

Image processing operations like RGB to grayscale conversion or color space transformations benefit from parallel processing of multiple pixels.

**Example:**

```assembly
@ Convert 8 RGB pixels to grayscale (simplified)
@ Grayscale = 0.3*R + 0.59*G + 0.11*B
@ Using integer approximation: Grayscale = (77*R + 150*G + 29*B) >> 8

@ Assuming RGB data is loaded with R, G, B components separated
VDUP.16 Q4, r4              @ Broadcast red coefficient (77)
VDUP.16 Q5, r5              @ Broadcast green coefficient (150)
VDUP.16 Q6, r6              @ Broadcast blue coefficient (29)

VMUL.I16 Q0, Q0, Q4         @ Multiply 8 red values
VMUL.I16 Q1, Q1, Q5         @ Multiply 8 green values
VMUL.I16 Q2, Q2, Q6         @ Multiply 8 blue values

VADD.I16 Q0, Q0, Q1         @ Sum red and green
VADD.I16 Q0, Q0, Q2         @ Add blue component

VSHR.U16 Q0, Q0, #8         @ Divide by 256 (shift right 8)
```

**Audio Processing**

Mixing multiple audio channels, applying filters, or performing FFT operations parallelize naturally with SIMD.

### SIMD Limitations

**Data Alignment**

[Inference: SIMD load and store operations may require aligned memory addresses for optimal performance or correctness, depending on the specific instruction and architecture. Unaligned accesses might be slower or unsupported].

**Code Complexity**

SIMD code is typically more complex than scalar equivalents, requiring careful data layout and loop restructuring. The benefit must justify the development and maintenance cost.

**Architecture Availability**

Not all ARM cores include NEON extensions. ARMv7-A typically includes NEON, but ARMv7-R and ARMv7-M implementations vary. Code must detect and adapt to SIMD availability or provide scalar fallbacks.

