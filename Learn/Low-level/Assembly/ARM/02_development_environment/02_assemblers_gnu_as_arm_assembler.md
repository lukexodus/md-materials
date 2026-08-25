## Assemblers (GNU AS, ARM Assembler)


### GNU Assembler (GAS)

The GNU Assembler (as) is part of the GNU Binutils package and uses AT&T or unified ARM syntax.

**Basic Invocation:**

```bash
# Assemble to object file
arm-none-eabi-as -mcpu=cortex-m4 -mthumb -o output.o input.s

# Common options
-g              # Include debugging information
-march=armv7-m  # Specify architecture
-mfpu=fpv4-sp-d16 # Floating-point unit
-W              # Suppress warnings
```

**Syntax Modes:**

```assembly
# Unified Assembly Language (UAL) - recommended
.syntax unified
.thumb

add r0, r1, r2    # Same syntax for ARM and Thumb

# Divided syntax (legacy)
.syntax divided
.arm
add r0, r1, r2    # ARM mode
.thumb
adds r0, r1, r2   # Thumb mode (note 's' suffix)
```

**Directives:**

```assembly
.section .text    # Code section
.section .data    # Initialized data
.section .bss     # Uninitialized data

.global _start    # Export symbol
.extern func      # External symbol reference

.align 4          # Align to 4-byte boundary
.word 0x12345678  # 32-bit constant
.byte 0xFF        # 8-bit constant
.ascii "text"     # String without null terminator
.asciz "text"     # String with null terminator

.equ CONSTANT, 100  # Define constant
.set VALUE, 0x20    # Alternative constant definition
```

**Conditional Assembly:**

```assembly
.ifdef DEBUG
    mov r0, #1
.else
    mov r0, #0
.endif

.if PLATFORM == 1
    bl platform1_init
.elseif PLATFORM == 2
    bl platform2_init
.endif
```

**Macros:**

```assembly
.macro PUSH_REGS reg1, reg2, reg3
    push {\reg1, \reg2, \reg3}
.endm

.macro DELAY cycles
    mov r0, #\cycles
loop_\@:
    subs r0, r0, #1
    bne loop_\@
.endm

# Usage
PUSH_REGS r4, r5, r6
DELAY 1000
```

### ARM Assembler (armasm)

ARM's proprietary assembler with advanced features and optimizations.

**Invocation:**

```bash
# Basic assembly
armasm --cpu=Cortex-M4 -g input.s -o output.o

# Options
--cpu=<name>        # Specify processor
--fpu=<name>        # Specify FPU
--apcs=/interwork   # ARM/Thumb interworking
--debug             # Debug tables
--keep              # Keep intermediate files
```

**Syntax Differences:**

```assembly
; armasm uses semicolons for comments
; Area directive instead of .section
        AREA MyCode, CODE, READONLY
        
        EXPORT _start
        ENTRY

_start  PROC
        MOV     r0, #10
        BL      function
        BX      lr
        ENDP

function PROC
        ADD     r0, r0, #5
        BX      lr
        ENDP

        AREA MyData, DATA, READWRITE
buffer  SPACE   256         ; Reserve 256 bytes
value   DCD     0x12345678  ; Define 32-bit word

        END
```

**Advanced Features:**

```assembly
; Frame directives for stack unwinding
function PROC
        FRAME PUSH {r4-r7, lr}
        FRAME ADDRESS sp, 20
        ; Function body
        FRAME POP {r4-r7, pc}
        ENDP

; PRESERVE8 directive for 8-byte stack alignment
        PRESERVE8

; REQUIRE8 - require 8-byte aligned stack
        REQUIRE8

; ROUT - local label scope
loop    ROUT
%F1     ; Forward reference to local label 1
        B       %F1
1       ; Local label 1
        B       %B1  ; Backward reference to label 1
```

### Inline Assembly in C

Embedding assembly in C code using GCC or armclang.

**GCC Inline Assembly:**

```c
// Basic template
asm volatile (
    "assembly code"
    : output operands
    : input operands
    : clobbered registers
);

// Example: Add two numbers
int add(int a, int b) {
    int result;
    asm volatile (
        "add %[out], %[in1], %[in2]"
        : [out] "=r" (result)
        : [in1] "r" (a), [in2] "r" (b)
    );
    return result;
}

// Memory barrier
#define memory_barrier() asm volatile("dmb" ::: "memory")

// Disable interrupts
static inline void disable_irq(void) {
    asm volatile ("cpsid i" ::: "memory");
}

// Enable interrupts
static inline void enable_irq(void) {
    asm volatile ("cpsie i" ::: "memory");
}
```

**Constraint Characters:**

```c
"r"  // General register
"l"  // Low register (r0-r7)
"h"  // High register (r8-r15)
"m"  // Memory operand
"i"  // Immediate constant
"I"  // Immediate 0-255
"J"  // Immediate -255 to -1
"K"  // Immediate shifted constant
"=r" // Write-only register
"+r" // Read-write register
"&r" // Early clobber register
```

