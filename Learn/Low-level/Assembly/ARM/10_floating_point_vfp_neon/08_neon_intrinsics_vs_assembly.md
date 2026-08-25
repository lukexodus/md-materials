## NEON Intrinsics vs Assembly


Developers can use NEON through hand-written assembly or compiler intrinsics. Each approach offers distinct trade-offs in portability, maintainability, and control.

**NEON Intrinsics:** C/C++ functions provided by ARM's ACLE (ARM C Language Extensions) specification that map directly to NEON instructions. Intrinsics have prefix `v` or `vq` and use types like `uint8x8_t`, `float32x4_t`, etc.

**Intrinsic Type System:**

**Vector types:**

- `int8x8_t`, `int8x16_t`: 8-bit signed integer vectors (64-bit/128-bit)
- `uint8x8_t`, `uint8x16_t`: 8-bit unsigned integer vectors
- `int16x4_t`, `int16x8_t`: 16-bit signed integer vectors
- `uint16x4_t`, `uint16x8_t`: 16-bit unsigned integer vectors
- `int32x2_t`, `int32x4_t`: 32-bit signed integer vectors
- `uint32x2_t`, `uint32x4_t`: 32-bit unsigned integer vectors
- `int64x1_t`, `int64x2_t`: 64-bit signed integer vectors
- `uint64x1_t`, `uint64x2_t`: 64-bit unsigned integer vectors
- `float32x2_t`, `float32x4_t`: 32-bit floating-point vectors
- `float16x4_t`, `float16x8_t`: 16-bit floating-point vectors (ARMv8.2+)

**Structure types:**

- `int32x4x2_t`: Structure of 2 vectors (for interleaved loads)
- `int32x4x3_t`: Structure of 3 vectors
- `int32x4x4_t`: Structure of 4 vectors

**Intrinsic Naming Convention:**

```
v[q][operation][_lane][_type]
```

- `v`: Vector prefix
- `q`: Quadword (128-bit) operation (absent for 64-bit)
- `operation`: Instruction mnemonic (add, mul, ld1, etc.)
- `_lane`: Lane-specific operation (optional)
- `_type`: Element type suffix (s8, u16, f32, etc.)

**Example** intrinsic names:

- `vaddq_s32`: Add quadword (128-bit) signed 32-bit integers
- `vmul_f32`: Multiply doubleword (64-bit) 32-bit floats
- `vld1q_u8`: Load one quadword of unsigned 8-bit integers
- `vget_lane_s16`: Extract lane from signed 16-bit vector

**Intrinsics Example: Vector Addition**

```c
#include <arm_neon.h>

void vector_add_intrinsics(const int32_t *a, const int32_t *b, int32_t *result, int count) {
    for (int i = 0; i < count; i += 4) {
        int32x4_t va = vld1q_s32(&a[i]);        // Load 4 int32 from a
        int32x4_t vb = vld1q_s32(&b[i]);        // Load 4 int32 from b
        int32x4_t vr = vaddq_s32(va, vb);       // Add vectors
        vst1q_s32(&result[i], vr);              // Store 4 int32 to result
    }
}
```

Equivalent assembly:

```assembly
vector_add_asm:
    ; R0=a, R1=b, R2=result, R3=count
loop:
    VLD1.32 {Q0}, [R0]!
    VLD1.32 {Q1}, [R1]!
    VADD.I32 Q2, Q0, Q1
    VST1.32 {Q2}, [R2]!
    SUBS    R3, R3, #4
    BNE     loop
    BX      LR
```

**Intrinsics Example: Dot Product**

```c
#include <arm_neon.h>

float dot_product_intrinsics(const float *a, const float *b, int count) {
    float32x4_t sum = vdupq_n_f32(0.0f);     // Initialize accumulator to zero
    
    for (int i = 0; i < count; i += 4) {
        float32x4_t va = vld1q_f32(&a[i]);   // Load 4 floats from a
        float32x4_t vb = vld1q_f32(&b[i]);   // Load 4 floats from b
        sum = vmlaq_f32(sum, va, vb);        // sum += va * vb
    }
    
    // Horizontal sum: sum all 4 lanes
    float32x2_t sum_low = vget_low_f32(sum);
    float32x2_t sum_high = vget_high_f32(sum);
    float32x2_t sum_pair = vadd_f32(sum_low, sum_high);
    float32x2_t sum_pairwise = vpadd_f32(sum_pair, sum_pair);
    
    return vget_lane_f32(sum_pairwise, 0);
}
```

**Intrinsics Example: Interleaved Load/Store**

```c
#include <arm_neon.h>

void separate_rgb_intrinsics(const uint8_t *rgb, uint8_t *r, uint8_t *g, uint8_t *b, int pixels) {
    for (int i = 0; i < pixels; i += 8) {
        uint8x8x3_t rgb_pixels = vld3_u8(&rgb[i * 3]);  // Load 8 RGB triplets
        vst1_u8(&r[i], rgb_pixels.val[0]);              // Store R channel
        vst1_u8(&g[i], rgb_pixels.val[1]);              // Store G channel
        vst1_u8(&b[i], rgb_pixels.val[2]);              // Store B channel
    }
}
```

The `vld3_u8` intrinsic maps directly to VLD3.8 instruction, automatically deinterleaving RGB data.

**Assembly Advantages:**

**Precise Control:** Direct register allocation, instruction scheduling, and pipeline management. Critical for squeezing maximum performance from tight loops.

**Register Reuse:** Explicit control over register lifetime enables optimal reuse patterns not always achieved by compilers.

**Instruction Selection:** Access to all NEON instructions including less common operations that may lack intrinsic mappings.

**Optimization Techniques:** Manual loop unrolling, software pipelining, prefetching control.

**Example** assembly optimization with manual scheduling:

```assembly
; Optimized with instruction reordering to hide latency
loop:
    VLD1.32  {Q0}, [R0]!         ; Load A (1 cycle)
    VLD1.32  {Q1}, [R1]!         ; Load B (1 cycle)
    PLD      [R0, #64]           ; Prefetch next A
    VADD.I32 Q2, Q0, Q1          ; Add (latency 4 cycles)
    PLD      [R1, #64]           ; Prefetch next B
    SUBS     R3, R3, #4          ; Decrement counter (fills delay slots)
    VST1.32  {Q2}, [R2]!         ; Store result
    BNE      loop
```

**Intrinsics Advantages:**

**Portability:** Code compiles for multiple architectures. Compiler generates appropriate instructions for target (NEON, SVE, x86 SSE/AVX with translation).

**Maintainability:** C/C++ syntax easier to read, modify, and debug than assembly. Integration with existing codebases straightforward.

**Compiler Optimizations:** Modern compilers apply register allocation, instruction scheduling, loop optimizations. [Inference] Compilers like GCC and Clang have sophisticated NEON optimization passes.

**Type Safety:** Compiler enforces type checking, preventing common assembly errors like register size mismatches.

**ABI Compliance:** Intrinsics automatically follow calling conventions for register preservation and parameter passing.

**Example** intrinsics with compiler auto-vectorization:

```c
#include <arm_neon.h>

// Compiler may further optimize this
void matrix_multiply_4x4(const float *A, const float *B, float *C) {
    for (int i = 0; i < 4; i++) {
        float32x4_t row = vld1q_f32(&A[i * 4]);
        for (int j = 0; j < 4; j++) {
            float32x4_t col = {B[j], B[j+4], B[j+8], B[j+12]};
            float32x4_t prod = vmulq_f32(row, col);
            float32x2_t sum = vadd_f32(vget_low_f32(prod), vget_high_f32(prod));
            sum = vpadd_f32(sum, sum);
            C[i * 4 + j] = vget_lane_f32(sum, 0);
        }
    }
}
```

**Performance Comparison:** [Inference based on observed compiler behavior]

**Well-written intrinsics:** Typically achieve 85-95% of hand-optimized assembly performance. Compilers have improved significantly; the gap has narrowed.

**Hand-optimized assembly:** Achieves maximum performance (100% baseline) but requires expert knowledge and extensive tuning.

**Auto-vectorized C code:** Without intrinsics, compiler auto-vectorization achieves 60-80% of optimal performance for regular patterns, less for complex code.

**Mixed Approach:** Practical development often combines approaches:

```c
#include <arm_neon.h>

void process_data(const float *input, float *output, int count) {
    // Use intrinsics for readability
    int i = 0;
    for (; i < count - 4; i += 4) {
        float32x4_t v = vld1q_f32(&input[i]);
        v = vmulq_f32(v, vdupq_n_f32(2.0f));
        vst1q_f32(&output[i], v);
    }
    
    // Critical section in assembly if needed
    if (i < count) {
        __asm__ volatile (
            "vld1.32 {d0}, [%0]\n"
            "vmul.f32 d0, d0, %1\n"
            "vst1.32 {d0}, [%2]\n"
            : 
            : "r"(&input[i]), "w"(2.0f), "r"(&output[i])
            : "d0", "memory"
        );
    }
}
```

**Debugging Considerations:**

**Intrinsics:** Standard C debuggers work normally. Inspect variables, single-step through code, examine vector contents.

**Assembly:** Requires assembly-level debugging. View register contents through debugger register windows. More difficult to correlate with source.

**Build System Integration:**

Intrinsics require compiler flags to enable NEON:

```bash
# GCC/Clang
gcc -mfpu=neon -mfloat-abi=hard -O3 -o program program.c

# ARMv8 (NEON mandatory)
gcc -march=armv8-a -O3 -o program program.c
```

Assembly modules integrate via inline assembly or separate `.s` files linked into the build.

**Key Points:**

- NEON provides SIMD parallelism for 8, 16, 32, 64-bit data types
- 32 D registers (64-bit) or 16 Q registers (128-bit) shared with VFP
- Parallel processing achieves throughput multiplication (4×, 8×, 16× depending on element size)
- Intrinsics offer portability and maintainability with near-optimal performance
- Hand-coded assembly provides maximum control for performance-critical sections
- Modern approach favors intrinsics with selective assembly optimization

---

