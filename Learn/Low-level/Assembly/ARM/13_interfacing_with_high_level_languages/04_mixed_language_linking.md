## Mixed-Language Linking


Mixed-language projects combine C/C++ code with hand-written assembly modules. The linker resolves symbols and combines object files into final executables or libraries.

**Build Process Overview:**

1. **Compile C sources:** `gcc -c file.c -o file.o`
2. **Assemble assembly sources:** `as file.s -o file.o` or `gcc -c file.s -o file.o`
3. **Link object files:** `gcc file1.o file2.o -o program`

**Example Project Structure:**

```
project/
├── main.c           # C main function
├── utils.c          # C utility functions
├── asm_funcs.s      # Assembly functions
└── Makefile
```

**main.c:**

```c
#include <stdio.h>

// Declare assembly functions
extern int asm_add(int a, int b);
extern void asm_process_array(int *arr, int len);

int main() {
    int result = asm_add(10, 20);
    printf("asm_add(10, 20) = %d\n", result);
    
    int arr[] = {1, 2, 3, 4, 5};
    asm_process_array(arr, 5);
    
    for (int i = 0; i < 5; i++) {
        printf("arr[%d] = %d\n", i, arr[i]);
    }
    
    return 0;
}
```

**asm_funcs.s:**

```assembly
.global asm_add
.type asm_add, %function

asm_add:
    ADD     R0, R0, R1
    BX      LR
.size asm_add, .-asm_add

.global asm_process_array
.type asm_process_array, %function

asm_process_array:
    PUSH    {R4, LR}
    MOV     R2, #0               ; index
loop:
    CMP     R2, R1
    BGE     done
    LDR     R3, [R0, R2, LSL #2] ; Load arr[i]
    LSL     R3, R3, #1           ; Multiply by 2
    STR     R3, [R0, R2, LSL #2] ; Store back
    ADD     R2, R2, #1
    B       loop
done:
    POP     {R4, PC}
.size asm_process_array, .-asm_process_array
```

**Makefile:**

```makefile
CC = arm-linux-gnueabihf-gcc
AS = arm-linux-gnueabihf-as
CFLAGS = -O2 -Wall
ASFLAGS = -march=armv7-a

OBJS = main.o utils.o asm_funcs.o

program: $(OBJS)
	$(CC) $(OBJS) -o program

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

utils.o: utils.c
	$(CC) $(CFLAGS) -c utils.c

asm_funcs.o: asm_funcs.s
	$(AS) $(ASFLAGS) asm_funcs.s -o asm_funcs.o

clean:
	rm -f $(OBJS) program
```

**Symbol Visibility and Linking:**

**Global symbols:** Visible across object files. Use `.global` directive in assembly.

**Local symbols:** Private to object file. Default for symbols not declared global.

**Weak symbols:** Can be overridden by strong symbols. Use `.weak` directive.

**Example** with weak symbols:

```assembly
.weak default_handler
.type default_handler, %function

default_handler:
    B       default_handler      ; Infinite loop
.size default_handler, .-default_handler

; User can provide strong symbol to override
```

**Calling Assembly from C++ with Name Mangling:**

C++ mangles function names for overloading. Use `extern "C"` to prevent mangling:

```cpp
// C++ header
#ifdef __cplusplus
extern "C" {
#endif

int asm_function(int a, int b);
void asm_process(void);

#ifdef __cplusplus
}
#endif
```

Assembly remains unchanged—symbols don't have C++ decoration.

**Position-Independent Code (PIC):**

For shared libraries, code must be position-independent. Access global data through GOT (Global Offset Table):

```assembly
.global pic_function
.type pic_function, %function

pic_function:
    PUSH    {R4, LR}
    
    ; Access global variable through GOT
    LDR     R4, .L_got_offset
.L_pc:
    ADD     R4, PC, R4           ; R4 = GOT address
    LDR     R4, [R4]             ; Load actual address
    LDR     R0, [R4]             ; Load variable value
    
    POP     {R4, PC}

.L_got_offset:
    .word   global_var(GOT) - (.L_pc + 8)
```

Typically handled automatically by assembler/linker when using `-fPIC` flag.

**Static vs Dynamic Linking:**

**Static linking:** Embeds all code into executable. Larger binary, no runtime dependencies.

```bash
gcc main.o asm_funcs.o -static -o program
```

**Dynamic linking:** Uses shared libraries (.so). Smaller binary, requires libraries at runtime.

```bash
gcc main.o asm_funcs.o -o program
```

**Creating Shared Library with Assembly:**

```bash
# Compile with PIC
gcc -fPIC -c main.c
as -march=armv7-a asm_funcs.s -o asm_funcs.o

# Create shared library
gcc -shared -o libmylib.so main.o asm_funcs.o

# Link against shared library
gcc app.c -L. -lmylib -o app
```

**Section Placement:**

Assembly code can specify sections for fine-grained control:

```assembly
.section .text.fast, "ax", %progbits
.global fast_function
fast_function:
    ; Critical function placed in specific section
    BX      LR

.section .data.shared, "aw", %progbits
.global shared_buffer
shared_buffer:
    .space 1024

.section .rodata
.global constant_table
constant_table:
    .word 1, 2, 3, 4, 5
```

Linker script controls section placement in memory:

```ld
SECTIONS
{
    .text : { *(.text .text.*) }
    .text.fast : { *(.text.fast) }  /* Place in fast memory */
    .data : { *(.data .data.*) }
    .rodata : { *(.rodata*) }
    .bss : { *(.bss .bss.*) }
}
```

**Debugging Mixed-Language Code:**

GDB supports debugging mixed C/assembly:

```bash
# Compile with debug symbols
gcc -g -c main.c
as -g asm_funcs.s -o asm_funcs.o
gcc main.o asm_funcs.o -o program

# Debug
gdb program
(gdb) break asm_add
(gdb) run
(gdb) disassemble
(gdb) info registers
(gdb) step 
(gdb) stepi # Step single instruction
````

**DWARF Debug Information in Assembly:**

Add debug directives for better debugging experience:

```assembly
.file   "asm_funcs.s"
.text
.global asm_add
.type   asm_add, %function

asm_add:
    .loc 1 5 0               # File 1, line 5, column 0
    .cfi_startproc           # Call Frame Information start
    ADD     R0, R0, R1
    .loc 1 6 0
    BX      LR
    .cfi_endproc
.size asm_add, .-asm_add
````

**Interoperability Considerations:**

**Alignment Requirements:** ARM requires different alignments for different data types:

- Byte: 1-byte alignment
- Halfword: 2-byte alignment
- Word: 4-byte alignment
- Doubleword: 8-byte alignment

Misaligned access may cause faults or performance degradation depending on CPU configuration.

```assembly
.data
.align 2                     # 4-byte alignment (2^2)
int_array:
    .word 1, 2, 3, 4

.align 3                     # 8-byte alignment (2^3)
double_value:
    .quad 0x123456789ABCDEF0
```

**Structure Packing and Padding:**

C structures may have padding for alignment. Assembly must match C layout:

```c
// C structure
struct Data {
    char a;        // Offset 0
    // 3 bytes padding
    int b;         // Offset 4
    short c;       // Offset 8
    // 2 bytes padding
    long long d;   // Offset 16 (must be 8-byte aligned)
};  // Total size: 24 bytes
```

Assembly accessing structure:

```assembly
; R0 points to struct Data
LDRB    R1, [R0, #0]         ; Load a
LDR     R2, [R0, #4]         ; Load b
LDRH    R3, [R0, #8]         ; Load c
LDRD    R4, R5, [R0, #16]    ; Load d (64-bit)
```

**Calling Conventions Across Platforms:**

Different platforms may use different conventions:

**Linux EABI (Embedded ABI):**

- Soft float: FP in integer registers
- Hard float: FP in VFP registers
- System call number in R7

**Bare metal:**

- Custom conventions possible
- No OS-enforced ABI
- Document carefully

**RTOS (e.g., FreeRTOS):**

- May define custom conventions
- Stack requirements for task context
- Interrupt handling considerations

**Example - FreeRTOS task in assembly:**

```assembly
.global task_function
.type task_function, %function

task_function:
    PUSH    {R4-R11, LR}         ; Save context
    
task_loop:
    ; Task work here
    
    ; Call FreeRTOS delay
    MOV     R0, #1000            ; Delay 1000 ticks
    BL      vTaskDelay           ; C function
    
    B       task_loop
    
    ; Task should never return, but if it does:
    POP     {R4-R11, PC}
.size task_function, .-task_function
```

**Optimization Considerations:**

**Link Time Optimization (LTO):** GCC's LTO can optimize across C/assembly boundaries, but assembly prevents many optimizations:

```bash
# Compile with LTO
gcc -flto -c main.c
gcc -c asm_funcs.s           # Assembly not optimized by LTO
gcc -flto main.o asm_funcs.o -o program
```

**Inlining:** Compiler cannot inline assembly functions. Performance-critical small functions may be better as inline assembly or intrinsics.

**Register Allocation:** Compiler has no visibility into assembly register usage. Calling many assembly functions may cause register spilling.

**Example Project - Cryptography Library:**

Mixing C for portability with assembly for performance-critical operations:

**aes.h:**

```c
#ifndef AES_H
#define AES_H

#include <stdint.h>

// C prototypes
void aes_init(uint32_t *key, int key_bits);
void aes_encrypt_block(const uint8_t *input, uint8_t *output);

// Assembly-optimized function
extern void aes_encrypt_block_asm(const uint8_t *input, 
                                   uint8_t *output,
                                   const uint32_t *round_keys,
                                   int num_rounds);

#endif
```

**aes.c:**

```c
#include "aes.h"
#include <string.h>

static uint32_t round_keys[60];
static int num_rounds;

void aes_init(uint32_t *key, int key_bits) {
    // C implementation of key expansion
    num_rounds = (key_bits == 128) ? 10 : 
                 (key_bits == 192) ? 12 : 14;
    
    // Key expansion logic (omitted for brevity)
    // Fills round_keys array
}

void aes_encrypt_block(const uint8_t *input, uint8_t *output) {
    // Use optimized assembly version
    aes_encrypt_block_asm(input, output, round_keys, num_rounds);
}
```

**aes_asm.s:**

```assembly
.global aes_encrypt_block_asm
.type aes_encrypt_block_asm, %function

aes_encrypt_block_asm:
    PUSH    {R4-R11, LR}
    
    ; R0 = input, R1 = output, R2 = round_keys, R3 = num_rounds
    
    ; Load input block (128 bits = 4 words)
    LDMIA   R0, {R4-R7}          ; Load 4 words
    
    ; Initial round key addition
    LDMIA   R2!, {R8-R11}
    EOR     R4, R4, R8
    EOR     R5, R5, R9
    EOR     R6, R6, R10
    EOR     R7, R7, R11
    
    ; Main rounds (using NEON for actual AES implementation)
    ; Simplified here - real implementation would use
    ; AES instructions or NEON-optimized substitution/mixing
    
round_loop:
    SUBS    R3, R3, #1
    BEQ     final_round
    
    ; SubBytes, ShiftRows, MixColumns, AddRoundKey
    ; (Omitted - would use table lookups or NEON)
    
    B       round_loop
    
final_round:
    ; SubBytes, ShiftRows, AddRoundKey (no MixColumns)
    
    ; Store output
    STMIA   R1, {R4-R7}
    
    POP     {R4-R11, PC}
.size aes_encrypt_block_asm, .-aes_encrypt_block_asm
```

**Makefile:**

```makefile
CC = arm-linux-gnueabihf-gcc
AS = arm-linux-gnueabihf-as
AR = arm-linux-gnueabihf-ar

CFLAGS = -O3 -march=armv7-a -mfpu=neon -Wall
ASFLAGS = -march=armv7-a -mfpu=neon

LIB_OBJS = aes.o aes_asm.o
TEST_OBJS = test.o

all: libaes.a test

libaes.a: $(LIB_OBJS)
	$(AR) rcs libaes.a $(LIB_OBJS)

test: $(TEST_OBJS) libaes.a
	$(CC) $(TEST_OBJS) -L. -laes -o test

aes.o: aes.c aes.h
	$(CC) $(CFLAGS) -c aes.c

aes_asm.o: aes_asm.s
	$(AS) $(ASFLAGS) aes_asm.s -o aes_asm.o

test.o: test.c aes.h
	$(CC) $(CFLAGS) -c test.c

clean:
	rm -f *.o libaes.a test
```

**Cross-Platform Considerations:**

When building for multiple architectures, use conditional assembly:

```assembly
#ifdef __ARM_ARCH_7A__
    ; ARMv7-A specific code
    UDIV    R0, R1, R2
#elif defined(__ARM_ARCH_6__)
    ; ARMv6 fallback
    ; Use division by repeated subtraction
#endif

#ifdef __ARM_NEON__
    ; NEON-optimized path
    VLD1.32 {Q0}, [R0]
    VADD.I32 Q0, Q0, Q1
#else
    ; Scalar fallback
    LDR     R0, [R1]
    ADD     R0, R0, R2
#endif
```

**Testing Mixed-Language Code:**

Create comprehensive test suite:

**test.c:**

```c
#include <stdio.h>
#include <assert.h>
#include "aes.h"

void test_aes_encrypt() {
    uint8_t input[16] = {0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
                         0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF};
    uint8_t output[16];
    uint8_t expected[16] = {/* known good output */};
    
    uint32_t key[4] = {0x00010203, 0x04050607, 0x08090A0B, 0x0C0D0E0F};
    
    aes_init(key, 128);
    aes_encrypt_block(input, output);
    
    assert(memcmp(output, expected, 16) == 0);
    printf("AES test passed\n");
}

int main() {
    test_aes_encrypt();
    return 0;
}
```

**Performance Profiling:**

Profile mixed-language code to identify bottlenecks:

```bash
# Compile with profiling
gcc -pg -O2 main.c asm_funcs.s -o program

# Run program
./program

# Analyze profile
gprof program gmon.out > analysis.txt
```

**Static Analysis:**

Use tools to verify ABI compliance:

```bash
# Check symbols in object files
nm asm_funcs.o

# Verify no undefined symbols
objdump -T program

# Check binary dependencies
ldd program

# Disassemble to verify code generation
objdump -d program > disassembly.txt
```

**Documentation Best Practices:**

Document all assembly functions with clear interface specifications:

```assembly
; ============================================================================
; Function: vector_normalize
; Description: Normalizes a 3D vector to unit length
; 
; Parameters:
;   R0 - Pointer to vector (float[3])
; 
; Returns:
;   None (modifies vector in-place)
; 
; Registers modified: R0-R3, S0-S9
; Stack usage: None
; Calling convention: AAPCS (hard float)
; 
; Example:
;   float vec[3] = {3.0, 4.0, 0.0};
;   vector_normalize(vec);
;   // vec is now {0.6, 0.8, 0.0}
; ============================================================================
.global vector_normalize
.type vector_normalize, %function

vector_normalize:
    ; Implementation here
    BX      LR
.size vector_normalize, .-vector_normalize
```

**Key Points:**

- Follow AAPCS for parameter passing: R0-R3 for arguments, R0 for return
- Preserve callee-saved registers R4-R11, SP, LR when used
- Maintain 8-byte stack alignment at public interfaces
- Use inline assembly for small code snippets with compiler integration
- Create separate assembly files for complex functions
- Mark inline assembly volatile when side effects matter
- Specify accurate clobber lists to prevent optimization bugs
- Use `extern "C"` in C++ to prevent name mangling
- Document assembly function interfaces thoroughly
- Test mixed-language code extensively across optimization levels
- Profile to verify assembly optimizations provide actual benefit

**Related Subtopics:**

Understanding AAPCS details for structure passing, variadic functions, and C++ exception handling would provide deeper insight into ABI complexities. Examining generated assembly from compilers (`gcc -S`) helps understand expected patterns. Exploring hardware-specific extensions like ARM's Pointer Authentication (ARMv8.3) and Branch Target Identification requires specialized knowledge of architectural security features.

---

