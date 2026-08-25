## Parameter Passing Conventions


AAPCS defines precise rules for passing arguments to functions, optimizing for register usage while supporting arbitrary parameter lists.

### Register-Based Parameter Passing (ARMv7)

The first four integer or pointer arguments use R0-R3 in order:

```
void func(int a, int b, int c, int d);
@ Called with: a=r0, b=r1, c=r2, d=r3
```

**Example** function call:

```
MOV r0, #10           @ First argument
MOV r1, #20           @ Second argument  
MOV r2, #30           @ Third argument
MOV r3, #40           @ Fourth argument
BL func
```

Arguments beyond the fourth are passed on the stack in reverse order (rightmost argument at lowest address), though AAPCS specifies they appear in forward order above the saved frame:

```
void func(int a, int b, int c, int d, int e, int f);
@ a=r0, b=r1, c=r2, d=r3, e=[sp, #0], f=[sp, #4]
```

**Example** calling with six arguments:

```
MOV r0, #10           @ a
MOV r1, #20           @ b
MOV r2, #30           @ c
MOV r3, #40           @ d
MOV r4, #50           @ e (temporary)
MOV r5, #60           @ f (temporary)
PUSH {r5}             @ Push f (sixth arg)
PUSH {r4}             @ Push e (fifth arg)
BL func
ADD sp, sp, #8        @ Clean up stack arguments
```

### Register-Based Parameter Passing (ARMv8)

The first eight integer or pointer arguments use X0-X7:

```
void func(long a, long b, long c, long d, long e, long f, long g, long h);
@ a=x0, b=x1, c=x2, d=x3, e=x4, f=x5, g=x6, h=x7
```

Arguments beyond the eighth are passed on the stack:

```
void func(long a, ..., long i, long j);
@ a-h in x0-x7, i=[sp, #0], j=[sp, #8]
```

**Example** calling with ten arguments:

```
MOV x0, #10           @ First argument
@ ... set x1-x7 ...
MOV x8, #90           @ Ninth argument (temporary)
MOV x9, #100          @ Tenth argument (temporary)
STP x8, x9, [sp, #-16]!  @ Push both onto stack
BL func
ADD sp, sp, #16       @ Clean up stack arguments
```

### Floating-Point Parameter Passing

Floating-point and SIMD arguments use separate register files:

**ARMv7 with VFP**:

- First 16 single-precision floats use S0-S15
- First 8 double-precision floats use D0-D7
- Additional FP arguments go on stack, 8-byte aligned

```
float func(float a, double b, float c);
@ a=s0, b=d1 (d1 overlaps s2-s3), c=s1
```

**ARMv8**:

- First 8 FP/SIMD arguments use V0-V7 (accessed as S, D, or Q depending on size)
- Additional FP arguments go on stack, aligned to their natural size

```
double func(double a, double b, float c);
@ a=d0, b=d1, c=s2
```

Mixed integer and FP arguments each use their respective register sets independently:

```
void func(int a, float b, int c, double d);
@ ARMv7: a=r0, b=s0, c=r1, d=d1
@ ARMv8: a=x0, b=s0, c=x1, d=d0
```

### Composite Type Parameter Passing

Structures and arrays follow complex rules based on size and composition:

**Small structures (ARMv7)**:

- Structures ≤ 32 bits: Passed in one register, fields packed according to endianness
- Structures 33-64 bits: Passed in two consecutive registers
- Larger structures: Passed by reference (pointer in register)

**Example** small structure:

```c
struct Point {
    short x;
    short y;
};

void plot(struct Point p);
@ p passed in r0: x in lower 16 bits, y in upper 16 bits (little-endian)
```

**Example** calling with structure:

```
MOV r0, #10           @ x = 10
ORR r0, r0, #20, LSL #16  @ y = 20 (packed into upper 16 bits)
BL plot
```

**Small structures (ARMv8)**:

- Structures ≤ 16 bytes: May be passed in registers if sufficient registers available
- Register allocation depends on member types and alignment

**Example** structure in multiple registers:

```c
struct Data {
    long a;
    long b;
};

void process(struct Data d);
@ ARMv8: d.a in x0, d.b in x1
```

**Homogeneous aggregates**: Structures containing 2-4 elements of the same floating-point or vector type may be passed in consecutive FP/SIMD registers:

```c
struct Vec4 {
    float x, y, z, w;
};

void transform(struct Vec4 v);
@ ARMv8: v.x=s0, v.y=s1, v.z=s2, v.w=s3
```

**Large structures**: Structures exceeding register capacity are passed by copying to stack, with the caller placing the copy and passing a pointer. In ARMv8, X8 may point to caller-allocated space for the return value.

### 64-bit Integer Parameter Passing (ARMv7)

64-bit integers require two 32-bit registers and must use an even-odd register pair:

```
void func(int a, long long b, int c);
@ a=r0, b=r2:r3 (skips r1 for alignment), c=[sp, #0]
```

If a 64-bit argument would use R3 and need R4, but R4 isn't available for parameter passing, the entire 64-bit value goes on the stack:

```
void func(int a, int b, int c, long long d);
@ a=r0, b=r1, c=r2, d=[sp, #0]:[sp, #4] (8-byte aligned on stack)
```

The register pair represents little-endian: lower 32 bits in lower-numbered register.

**Example** calling with 64-bit parameter:

```
MOV r0, #1            @ First argument
MOV r2, #0x89ABCDEF   @ Lower 32 bits of second argument
MOV r3, #0x01234567   @ Upper 32 bits of second argument
BL func
```

In ARMv8, 64-bit values simply use one X register without alignment concerns.

### Variable Argument Lists (va_list)

Variadic functions receive parameters identically to fixed-argument functions through the first N arguments. The function then uses `va_start`, `va_arg`, and `va_end` macros (or equivalent assembly) to access additional arguments.

**ARMv7 variadic function**:

```
int printf(const char *format, ...);
@ format in r0, additional arguments in r1-r3 and stack
```

The callee may need to save all argument registers to memory to create a contiguous argument list for `va_arg` traversal:

```
varfunc:
    PUSH {r0-r3}          @ Save all argument registers
    MOV r0, sp            @ Base of saved arguments
    @ Use r0 to access arguments sequentially...
    ADD sp, sp, #16       @ Clean up
    BX lr
```

**ARMv8 variadic function**: Similar approach, potentially saving X0-X7 to create an argument save area.

### Stack Argument Ordering and Alignment

Stack arguments appear at increasing addresses in the order they appear in the parameter list:

```
void func(int a, int b, int c, int d, int e, int f);
@ Stack layout after call (ARMv7):
@ [SP + 0]: e (fifth argument)
@ [SP + 4]: f (sixth argument)
```

Each stack argument is sized and aligned according to its type:

- 1-byte types: occupy 1 byte but typically padded to 4-byte alignment
- 2-byte types: occupy 2 bytes, aligned to 2-byte boundaries
- 4-byte types: occupy 4 bytes, aligned to 4-byte boundaries
- 8-byte types: occupy 8 bytes, aligned to 8-byte boundaries

The total stack space for arguments must maintain the overall stack alignment requirement (8 bytes for ARMv7, 16 bytes for ARMv8).

### Argument Evaluation Order

AAPCS does not mandate argument evaluation order—this is specified by the programming language. In C/C++, evaluation order is unspecified (except for specific operators), so the compiler may evaluate arguments in any order for optimization.

However, arguments must appear in registers and stack positions according to their source code position, regardless of evaluation order.

### Caller vs Callee Stack Cleanup

In AAPCS, the **caller** is responsible for removing stack arguments after the function returns:

```
@ Place arguments on stack
PUSH {r4-r5}          @ Two stack arguments
BL func
ADD sp, sp, #8        @ Caller removes arguments
```

This differs from some other calling conventions (like stdcall) where the callee cleans up. Caller cleanup allows variadic functions to work correctly since the callee doesn't know how many arguments were passed.

### Register Shadowing

Some ABIs define "register save areas" or "shadow space" where the callee can spill register arguments. Standard AAPCS does not require this, but some variants (particularly for Windows on ARM) include shadow space:

[Inference] Shadow space reserves stack locations corresponding to register arguments, even though those arguments were passed in registers. The callee may optionally store register arguments to these locations, simplifying debugging and variadic function implementation.

