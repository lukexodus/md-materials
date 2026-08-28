## Compiler Optimization Flags and Their Effects

### Overview

Compiler optimization flags control the tradeoffs a compiler makes between code size, execution speed, compilation time, and debuggability. In embedded development these tradeoffs carry more weight than in general-purpose application development, because embedded targets are frequently constrained on flash/ROM size, RAM, and execution time budgets (interrupt latency, real-time deadlines), and because aggressive optimization can interact badly with hardware-specific code (volatile accesses, timing-sensitive loops, undefined behavior that was previously "harmless").

### GCC/Clang Optimization Levels

Most embedded toolchains are GCC-based (arm-none-eabi-gcc, avr-gcc, riscv-gcc) or Clang/LLVM-based, and both share a largely compatible `-O` flag scheme.

#### -O0 (No Optimization)

- Default when no `-O` flag is given.
- Compiles fast, produces the most predictable and debuggable code — variable values and control flow map directly to source lines.
- Produces the largest and slowest code; every variable is typically stored to memory rather than kept in registers, since the compiler makes minimal assumptions across statements.
- Used almost exclusively for active debugging sessions, not for shipped firmware. **[Inference]** Timing behavior at `-O0` is often unrepresentative of the final shipped binary, so timing-critical code should not be validated at this level.

#### -O1 (Basic Optimization)

- Enables optimizations that don't significantly increase compile time: dead code elimination, basic constant folding, simple redundant instruction removal.
- Improves code size and speed over `-O0` while remaining reasonably debuggable — variable locations may still be tracked accurately enough for most debugging.

#### -O2 (Full Optimization, No Size/Speed Tradeoff Bias)

- Enables nearly all optimizations that do not involve a speed-for-size tradeoff: instruction scheduling, more aggressive inlining, loop optimizations, vectorization (where the target ISA supports it, e.g., ARM NEON on Cortex-A, not applicable to most Cortex-M cores).
- Most commonly used level for release builds on resource-adequate embedded targets.
- Debugging becomes noticeably harder — variables may be optimized into registers or eliminated entirely, and source-line-to-instruction correlation becomes non-linear due to reordering and inlining.

#### -O3 (Aggressive Optimization)

- Enables everything in `-O2` plus more aggressive inlining, loop unrolling, and vectorization heuristics.
- Frequently increases code size, sometimes significantly, in exchange for speed.
- **[Inference]** On flash-constrained microcontrollers (e.g., parts with 32–128 KB flash), `-O3` code size growth can be a hard blocker regardless of the speed benefit, since the binary may simply not fit.
- **[Unverified]** Whether `-O3` actually outperforms `-O2` is workload-dependent and not guaranteed; GCC's own documentation has historically noted that `-O3` can occasionally produce slower code than `-O2` for certain codebases due to instruction cache pressure from unrolling/inlining, so profiling on real hardware is necessary rather than assuming `-O3` is strictly better.

#### -Os (Optimize for Size)

- Enables most `-O2` optimizations but disables or tunes down those that tend to increase code size (notably aggressive inlining and loop unrolling).
- Very commonly used in embedded/bare-metal contexts specifically because flash size is a hard constraint and speed headroom exists.
- On many small microcontroller projects, `-Os` is the practical default for release builds rather than `-O2`.

#### -Ofast

- Enables `-O3` plus additional optimizations that violate strict standards compliance, most notably floating-point behavior that ignores IEEE 754 exception and rounding rules (equivalent to `-ffast-math`).
- **[Inference]** Generally inadvisable for embedded control systems, sensor fusion, or anything relying on precise floating-point semantics (e.g., NaN/Inf handling, exact rounding for control loop stability), since `-ffast-math` can silently change numerical results in ways that are hard to detect through normal testing.

#### -Og (Optimize for Debugging)

- Introduced to provide a middle ground: reasonable optimization while preserving debuggability better than `-O1`.
- Recommended by GCC's own documentation as the level to use during active development/debugging when some optimization is still desired (e.g., to catch timing-related bugs that don't manifest at `-O0`).

### Optimization Level Comparison

| Flag | Code Size | Speed | Debuggability | Compile Time | Typical Use |
| --- | --- | --- | --- | --- | --- |
| `-O0` | Largest | Slowest | Best | Fastest | Active debugging |
| `-Og` | Large | Slow–Moderate | Good | Fast | Debug builds needing some optimization |
| `-O1` | Moderate | Moderate | Moderate | Moderate | Rarely used in isolation |
| `-Os` | Small | Moderate–Good | Poor | Moderate | Flash-constrained release builds |
| `-O2` | Moderate–Large | Good | Poor | Slower | General release builds |
| `-O3` | Largest (optimized) | Best (workload-dependent) | Poor | Slowest | Performance-critical, flash-abundant targets |
| `-Ofast` | Largest (optimized) | Best (non-compliant FP) | Poor | Slowest | Rarely appropriate in embedded control |

### Optimization and Undefined Behavior

This is the single most important interaction for embedded engineers to understand, and a frequent source of "it worked at -O0 but broke at -O2" bugs.

The C standard permits a compiler to assume undefined behavior never occurs, and to optimize accordingly. At low optimization levels, this assumption often has no visible effect because the compiler generates a fairly literal instruction-by-instruction translation. At higher optimization levels, the compiler actively exploits the assumption:

```c
/* Signed integer overflow is undefined behavior in C. */
int32_t compute(int32_t x) {
    int32_t y = x + 1;
    if (y < x) {
        /* Intended as overflow-check logic */
        handle_overflow();
    }
    return y;
}
```

**[Inference]** At higher optimization levels, a compiler is permitted to reason that since signed overflow is undefined, `x + 1 < x` can never be true for a well-defined program, and may eliminate the `if` branch entirely — silently removing the overflow check the programmer intended. This exact class of bug (UB-reliant overflow checks being optimized away) is well documented across GCC and Clang and is a primary reason MISRA C and similar standards restrict reliance on signed overflow behavior.

Other UB-adjacent constructs that behave differently across optimization levels:

- Reading an uninitialized variable (value may appear stable at `-O0`, since it happens to reflect stale stack memory, but behave unpredictably at `-O2`/`-O3` where the compiler may not even allocate storage for it).
- Strict aliasing violations (accessing memory through an incompatible pointer type) — often "works" at `-O0` and misbehaves at `-O2`+ once the compiler applies alias-based optimizations. The `-fno-strict-aliasing` flag disables this class of optimization when such aliasing is unavoidable (e.g., certain low-level networking or type-punning code), at a performance cost.
- Out-of-bounds array access that happens not to fault at `-O0` due to incidental stack layout, but changes behavior once the compiler reorders or eliminates stack variables at higher optimization.

### The `volatile` Keyword and Optimization

`volatile` is the primary mechanism for telling the compiler "do not optimize away or reorder accesses to this object," and it is essential in embedded code for:

- Memory-mapped hardware registers, where a read or write has a side effect (triggering hardware action) that the compiler cannot infer from the value alone.
- Variables shared with an interrupt service routine (ISR), where the main-line code must re-read the variable on each loop iteration rather than caching it in a register.
- Variables modified by DMA (Direct Memory Access) hardware without CPU instruction involvement.

```c
/* Without volatile: at -O1 and above, the compiler may hoist the
   read of *status_reg out of the loop entirely, since nothing in
   the visible C code appears to change it — resulting in an
   infinite loop even though the hardware register does change. */
uint32_t *status_reg = (uint32_t *)0x40001000;
while ((*status_reg & READY_BIT) == 0) {
    /* busy-wait */
}

/* With volatile: the compiler is required to re-read the actual
   memory location on every iteration */
volatile uint32_t *status_reg = (volatile uint32_t *)0x40001000;
while ((*status_reg & READY_BIT) == 0) {
    /* busy-wait */
}
```

**[Inference]** A very common embedded bug pattern is code that works correctly at `-O0` (where the compiler re-reads memory almost everywhere anyway) and then hangs or misbehaves only once optimization is enabled for release builds, precisely because a `volatile` qualifier was omitted on a register or ISR-shared variable. This is one of the strongest practical arguments for testing on the actual optimization level intended for release, not just at `-O0`.

`volatile` guarantees ordering and non-elision of accesses to that object relative to other volatile accesses; it does **not** provide atomicity, memory barriers across multiple objects, or thread/interrupt-safety for compound read-modify-write operations. **[Inference]** For multi-step operations (e.g., increment-then-store) shared between an ISR and main-line code, `volatile` alone is generally insufficient — disabling interrupts around the critical section, or using a genuinely atomic mechanism where the target/toolchain provides one, is typically required in addition.

### Optimization and Timing-Sensitive Code

Delay loops and precisely-timed bit-banging code are particularly sensitive to optimization level, because their correctness may depend on a specific number of instructions executing per iteration.

```c
/* Fragile: relies on the compiler NOT optimizing the loop away or
   changing its iteration cost. At -O2/-O3 this loop can be
   eliminated entirely, since the loop variable has no observable
   effect outside the loop. */
void delay(volatile uint32_t count) {
    while (count--) {
        /* nothing */
    }
}
```

Marking the parameter `volatile` (as shown) generally prevents elimination of the loop itself, but the *number of cycles per iteration* still depends on the optimization level and instruction scheduling, so this pattern remains a poor way to achieve calibrated timing. **[Inference]** Hardware timers or a cycle-counting mechanism (e.g., the ARM Cortex-M DWT cycle counter, or a dedicated timer peripheral) are generally preferred over instruction-counting delay loops specifically because they are correct independent of optimization level and compiler version.

### Function Inlining

`-O2` and `-O3` inline small functions aggressively by default, particularly `static` functions used once or a few times, since inlining removes call/return overhead and enables further optimization across the former function boundary.

- `inline` keyword: a hint to the compiler, not a command; the compiler may ignore it, and in C (unlike C++) the semantics around external linkage and `inline` require care (`static inline` is the common, unambiguous pattern in embedded C headers).
- `__attribute__((always_inline))` (GCC/Clang extension): forces inlining regardless of heuristics; not portable to non-GCC-compatible compilers.
- `__attribute__((noinline))`: prevents inlining, sometimes used to keep a function's code at a stable address for debugging, or to avoid code bloat from a large function called in many places.
- Excessive inlining at `-O3` increases code size and can hurt instruction-cache performance on cores with small I-caches, potentially offsetting the call-overhead savings.

### Link-Time Optimization (LTO)

`-flto` enables optimization across translation-unit boundaries at link time rather than being limited to what's visible within a single `.c` file at compile time.

- Allows cross-file inlining, dead-code elimination of unused functions/data across the whole program, and more accurate whole-program analysis.
- Can produce meaningfully smaller and faster embedded binaries, since embedded codebases often have many small utility functions called from a single file.
- Increases link time and peak memory usage during the build, which **[Inference]** can matter on constrained CI build systems or very large embedded codebases.
- **[Inference]** LTO can occasionally surface latent bugs that were previously masked by translation-unit boundaries (e.g., a type mismatch across files that per-file compilation didn't have visibility into), so a full test pass after enabling LTO is advisable rather than assuming it is purely a size/speed change.

### Target-Specific and Architecture Flags

Beyond generic `-O` levels, embedded builds typically need architecture-targeting flags for correctness and performance, not just tuning:

- `-mcpu=<core>` (e.g., `-mcpu=cortex-m4`): selects the specific CPU core, affecting available instructions and scheduling.
- `-mfpu=<fpu>` and `-mfloat-abi=<abi>` (e.g., `-mfpu=fpv4-sp-d16 -mfloat-abi=hard`): controls hardware floating-point unit usage versus software floating-point emulation. Mismatches here are a common source of hard faults — mixing `hard` and `soft` float ABI object files, or targeting an FPU instruction set the actual silicon doesn't have, produces incorrect or non-functional binaries rather than merely slower ones.
- `-mthumb` vs `-marm` (ARM targets): selects Thumb (16/32-bit mixed, denser code) versus full 32-bit ARM instruction encoding; nearly all Cortex-M cores support Thumb/Thumb-2 only.
- These flags are correctness-affecting, not purely optimization-tuning, and mismatches between the compiler flags and actual silicon capability are a distinct hazard from the `-O` level discussion above.

### Practical Recommendations for Embedded Projects

- Use `-O0` or `-Og` for active debugging sessions; do not use `-O0` binaries to validate timing-sensitive behavior intended for the shipped `-O2`/`-Os` build.
- Build and test the actual release optimization level regularly during development, not only at the end of a project — many `volatile`-omission and UB-reliance bugs only manifest once optimization is enabled.
- Prefer `-Os` over `-O2`/`-O3` by default on flash-constrained microcontrollers unless profiling demonstrates a specific hot path needs the speed and the resulting code size is acceptable.
- Enable `-Wall -Wextra` (and treat warnings as errors via `-Werror` where practical) alongside optimization flags — many optimization-exposed UB issues also produce a compiler warning, particularly with `-O2` and above, since the optimizer's analysis passes are what surface some of these warnings in the first place.
- Explicitly mark hardware registers, ISR-shared variables, and DMA-target buffers as `volatile`; do not rely on `-O0` testing to validate that these are unnecessary.
- Avoid instruction-counting delay loops; use hardware timers/counters for anything timing-critical, independent of optimization level.
- Where `-flto` is used, run the full test suite again after enabling it rather than assuming it's a transparent size/speed win.
- Document the chosen optimization flags as part of the build configuration under change control for safety-critical or MISRA-governed projects, since the optimization level is itself part of what any verification/validation activity (including MISRA static analysis, which is typically run against the same flags as the release build) needs to account for.

### Optimization Flag Decision Flow

===MERMAID_DIAGRAM===

flowchart TD

A[Select build purpose] --> B{Active debugging?}

B -->|Yes| C[-O0 or -Og]

B -->|No, release build| D{Flash size\nconstrained?}

D -->|Yes| E[-Os]

D -->|No| F{Hot path needs\nmax speed?}

F -->|Yes, profiled| G[-O2 or -O3,\nprofile to confirm]

F -->|No| H[-O2 default]

E --> I{Uses volatile correctly\nfor HW/ISR access?}

G --> I

H --> I

I -->|No| J[Fix before release:\nUB/timing risk]

I -->|Yes| K[Test at chosen\noptimization level]

**Related Topics**

- Understanding and eliminating undefined behavior in C (signed overflow, strict aliasing, uninitialized reads)
- Interrupt service routine (ISR) design and critical section management
- Hardware floating-point ABI configuration (`-mfloat-abi`, `-mfpu`) and common linker mismatches
- Using `-Wall -Wextra -Wpedantic` and static analyzers alongside optimization flags
- Link-Time Optimization (LTO) tradeoffs in large embedded codebases
- Cycle-accurate timing techniques using hardware timers/DWT cycle counters
- Reading and interpreting compiler-generated assembly/disassembly to verify optimization effects