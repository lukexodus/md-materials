## Fused Multiply-Add (FMA)


FMA instructions perform combined multiply-add operations in a single instruction with a single rounding step. Intel introduced FMA3 with Haswell (alongside AVX2), which uses three-operand encoding. AMD initially implemented FMA4 with a four-operand format, but FMA3 became the standard.

### FMA Operation Semantics

FMA computes `result = (a * b) + c` with a single rounding operation after accumulation, providing both performance and numerical accuracy benefits. The single rounding step eliminates intermediate rounding errors that would occur if multiplication and addition were performed separately.

The mathematical operation:

```
FMA(a, b, c) = round(a * b + c)
```

Versus separate operations:

```
MUL_ADD(a, b, c) = round(round(a * b) + c)
```

The difference in rounding can affect numerical stability and accuracy in algorithms that accumulate many products, such as dot products, matrix multiplication, and polynomial evaluation.

### FMA Instruction Variants

FMA3 provides multiple instruction variants based on which operand is both a source and the destination:

**VFMADD132PS/PD** computes `dest = (dest * op3) + op2`, destroying the first multiplicand.

**VFMADD213PS/PD** computes `dest = (op2 * dest) + op3`, destroying the second multiplicand.

**VFMADD231PS/PD** computes `dest = (op2 * op3) + dest`, destroying the addend.

The three-digit suffix encodes operand roles: the first digit indicates which operand serves as destination, while the remaining digits indicate the multiplication operands.

```nasm
vmovaps ymm0, [a]
vmovaps ymm1, [b]
vmovaps ymm2, [c]
vfmadd213ps ymm0, ymm1, ymm2  ; ymm0 = (ymm0 * ymm1) + ymm2
```

### Additional FMA Operations

**VFMSUB** variants compute `(a * b) - c`, performing fused multiply-subtract.

**VFNMADD** variants compute `-(a * b) + c`, negating the product before addition.

**VFNMSUB** variants compute `-(a * b) - c`, negating both product and addend.

Each of these operations exists in 132, 213, and 231 forms corresponding to different destination operand choices.

### Scalar FMA

**VFMADD132SS/SD**, **VFMADD213SS/SD**, **VFMADD231SS/SD** perform FMA on scalar single-precision or double-precision values, operating only on the lowest element while preserving upper elements of the destination register.

### FMA Performance Benefits

[Inference] FMA instructions provide performance improvements by:

**Reduced instruction count**: A single FMA replaces separate multiply and add instructions, reducing pressure on instruction fetch, decode, and retirement pipelines.

**Improved throughput**: On processors with dedicated FMA execution units, one FMA can issue per cycle, achieving twice the throughput of separate multiply and add operations that would require two cycles.

**Reduced latency for dependent chains**: When the result feeds into another FMA, the latency chain is shorter than separate multiply-add sequences.

**Example**: Dot product computation

```nasm
; Traditional approach (2 instructions per iteration)
vmulps ymm0, ymm1, ymm2     ; Multiply
vaddps ymm3, ymm3, ymm0     ; Accumulate

; FMA approach (1 instruction per iteration)
vfmadd231ps ymm3, ymm1, ymm2  ; ymm3 += ymm1 * ymm2
```

[Unverified] The performance gain depends on the specific processor implementation. On processors where FMA throughput matches multiply throughput (one per cycle), the improvement primarily comes from reduced instruction count. On processors with higher FMA throughput or lower FMA latency than separate operations, the gains can be more substantial.

### Numerical Accuracy Benefits

FMA's single rounding step improves accuracy in many numerical algorithms. Algorithms that accumulate many products, such as dot products and matrix operations, experience reduced error accumulation.

The error bound for FMA is:

```
|FMA(a,b,c) - (a*b + c)| ≤ 0.5 ULP
```

Whereas separate multiply-add has:

```
|a*b + c - (a*b + c)| ≤ 1.0 ULP (worst case)
```

[Inference] For single operations, the accuracy difference is minimal. For algorithms performing thousands or millions of multiply-accumulate operations, such as neural network inference or scientific simulations, the cumulative effect of single rounding can measurably improve result quality.

### FMA Usage Example: Matrix Multiplication

```nasm
; Computing C[i][j] += A[i][k] * B[k][j]
; Using FMA for accumulation

vmovaps ymm0, [c_element]   ; Load accumulator
mov rcx, matrix_size

loop_k:
    vbroadcastss ymm1, [a_element]
    vmovaps ymm2, [b_row]
    vfmadd231ps ymm0, ymm1, ymm2  ; accumulator += a * b
    ; Update pointers and continue
    dec rcx
    jnz loop_k

vmovaps [c_element], ymm0   ; Store result
```

