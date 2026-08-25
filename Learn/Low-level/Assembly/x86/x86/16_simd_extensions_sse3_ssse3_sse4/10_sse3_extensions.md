## SSE3 Extensions


SSE3 introduces 13 new instructions focused on horizontal operations, floating-point conversions, and thread synchronization.

### Horizontal Operations

Unlike packed operations that work vertically (corresponding elements across registers), horizontal operations work within a single register, combining adjacent elements.

**HADDPS - Horizontal Add Packed Single-Precision**

`HADDPS xmm1, xmm2/m128`

Adds adjacent pairs of single-precision floating-point values from both operands.

Operation:

```
xmm1[31:0]   = xmm1[31:0] + xmm1[63:32]
xmm1[63:32]  = xmm1[95:64] + xmm1[127:96]
xmm1[95:64]  = xmm2[31:0] + xmm2[63:32]
xmm1[127:96] = xmm2[95:64] + xmm2[127:96]
```

**HADDPD - Horizontal Add Packed Double-Precision**

`HADDPD xmm1, xmm2/m128`

Adds adjacent pairs of double-precision floating-point values.

Operation:

```
xmm1[63:0]   = xmm1[63:0] + xmm1[127:64]
xmm1[127:64] = xmm2[63:0] + xmm2[127:64]
```

**HSUBPS - Horizontal Subtract Packed Single-Precision**

`HSUBPS xmm1, xmm2/m128`

Subtracts adjacent pairs of single-precision values.

Operation:

```
xmm1[31:0]   = xmm1[31:0] - xmm1[63:32]
xmm1[63:32]  = xmm1[95:64] - xmm1[127:96]
xmm1[95:64]  = xmm2[31:0] - xmm2[63:32]
xmm1[127:96] = xmm2[95:64] - xmm2[127:96]
```

**HSUBPD - Horizontal Subtract Packed Double-Precision**

`HSUBPD xmm1, xmm2/m128`

Subtracts adjacent pairs of double-precision values.

### Complex Arithmetic Operations

**ADDSUBPS - Add/Subtract Packed Single-Precision**

`ADDSUBPS xmm1, xmm2/m128`

Alternates between subtraction and addition on adjacent pairs, useful for complex number arithmetic.

Operation:

```
xmm1[31:0]   = xmm1[31:0] - xmm2[31:0]      ; Subtract
xmm1[63:32]  = xmm1[63:32] + xmm2[63:32]    ; Add
xmm1[95:64]  = xmm1[95:64] - xmm2[95:64]    ; Subtract
xmm1[127:96] = xmm1[127:96] + xmm2[127:96]  ; Add
```

**ADDSUBPD - Add/Subtract Packed Double-Precision**

`ADDSUBPD xmm1, xmm2/m128`

Operation:

```
xmm1[63:0]   = xmm1[63:0] - xmm2[63:0]      ; Subtract
xmm1[127:64] = xmm1[127:64] + xmm2[127:64]  ; Add
```

### Data Movement and Duplication

**MOVSHDUP - Move and Duplicate High**

`MOVSHDUP xmm1, xmm2/m128`

Duplicates odd-indexed (high) single-precision elements.

Operation:

```
xmm1[31:0]   = xmm2[63:32]
xmm1[63:32]  = xmm2[63:32]
xmm1[95:64]  = xmm2[127:96]
xmm1[127:96] = xmm2[127:96]
```

**MOVSLDUP - Move and Duplicate Low**

`MOVSLDUP xmm1, xmm2/m128`

Duplicates even-indexed (low) single-precision elements.

Operation:

```
xmm1[31:0]   = xmm2[31:0]
xmm1[63:32]  = xmm2[31:0]
xmm1[95:64]  = xmm2[95:64]
xmm1[127:96] = xmm2[95:64]
```

**MOVDDUP - Move and Duplicate Double-Precision**

`MOVDDUP xmm1, xmm2/m64`

Duplicates a double-precision value to both halves of the destination register.

Operation:

```
xmm1[63:0]   = xmm2[63:0]
xmm1[127:64] = xmm2[63:0]
```

### Conversion and Load Operations

**LDDQU - Load Unaligned Integer 128 Bits**

`LDDQU xmm1, m128`

Special unaligned load optimized for 128-bit integer data that may cross cache line boundaries. [Inference: Performance benefits depend on specific microarchitecture and memory alignment].

### Thread Synchronization

**MONITOR - Set Up Monitor Address**

`MONITOR`

Sets up a linear address range for monitoring. Uses EAX (address), ECX (extensions), and EDX (hints).

**MWAIT - Monitor Wait**

`MWAIT`

Enters an optimized state waiting for a write to the monitored address range. Uses ECX (extensions) and EAX (hints).

These instructions enable efficient thread synchronization by allowing threads to sleep until specific memory locations are modified, reducing power consumption compared to spin-waiting.

