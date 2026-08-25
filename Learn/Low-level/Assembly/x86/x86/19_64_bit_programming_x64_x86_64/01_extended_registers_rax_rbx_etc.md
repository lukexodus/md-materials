## Extended Registers (RAX, RBX, etc.)


### Register Extension Architecture

x86-64 extends the eight general-purpose registers from 32 bits to 64 bits by adding a REX (Register Extension) prefix to instructions. The extended registers are named with an 'R' prefix replacing the 'E' prefix:

```
64-bit: RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP
32-bit: EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP (lower 32 bits)
16-bit: AX,  BX,  CX,  DX,  SI,  DI,  BP,  SP  (lower 16 bits)
8-bit:  AL,  BL,  CL,  DL,  SIL, DIL, BPL, SPL (lower 8 bits)
```

The register hierarchy maintains complete aliasing, where operations on smaller register portions affect the corresponding bits of the full 64-bit register according to specific rules.

### Zero-Extension Behavior

Operations on 32-bit register portions (EAX, EBX, etc.) automatically zero the upper 32 bits of the corresponding 64-bit register. This zero-extension behavior differs from 16-bit and 8-bit operations, which preserve upper bits.

```nasm
mov rax, 0xFFFFFFFFFFFFFFFF  ; RAX = 0xFFFFFFFFFFFFFFFF
mov eax, 1                    ; RAX = 0x0000000000000001 (upper bits zeroed)

mov rax, 0xFFFFFFFFFFFFFFFF  ; RAX = 0xFFFFFFFFFFFFFFFF
mov ax, 1                     ; RAX = 0xFFFFFFFFFFFF0001 (upper bits preserved)
mov al, 1                     ; RAX = 0xFFFFFFFFFFFF0001 (upper bits preserved)
```

[Inference] The 32-bit zero-extension behavior eliminates the need for explicit zero-extension instructions when operating on 32-bit values, simplifying code generation and improving performance. This design choice reflects that 64-bit code commonly operates on 32-bit integers while true 64-bit values are less frequent in many applications.

### Sign-Extension Instructions

When sign-extension is required instead of zero-extension, specific instructions provide this functionality:

**MOVSX** (Move with Sign-Extension) extends signed values from smaller to larger sizes:

```nasm
movsx rax, byte [mem]    ; Sign-extend byte to 64 bits
movsx rax, word [mem]    ; Sign-extend word to 64 bits
movsx rax, dword [mem]   ; Sign-extend dword to 64 bits
```

**MOVSXD** specifically sign-extends 32-bit values to 64 bits. This instruction is sometimes written as **MOVSLQ** in AT&T syntax:

```nasm
movsxd rax, ecx          ; Sign-extend ECX to RAX
movsxd rax, dword [mem]  ; Sign-extend memory dword to RAX
```

[Inference] The availability of both automatic zero-extension (for 32-bit operations) and explicit sign-extension instructions allows efficient handling of both unsigned and signed 32-bit to 64-bit conversions without unnecessary operations.

### High Byte Register Access

x86-64 expands low byte register access to all extended registers (SIL, DIL, BPL, SPL for RSI, RDI, RBP, RSP respectively), which were not accessible as byte registers in 32-bit mode. However, accessing these low byte registers and the traditional high byte registers (AH, BH, CH, DH) in the same instruction requires careful encoding.

When a REX prefix is present (required for SIL, DIL, BPL, SPL, or R8-R15 access), the high byte registers (AH, BH, CH, DH) become inaccessible in that instruction. The encoding space used for high byte registers is repurposed for the extended low byte registers.

```nasm
mov sil, 0x42      ; Valid: access low byte of RSI (requires REX prefix)
mov ah, 0x42       ; Valid: access high byte of RAX (no REX prefix)

; Cannot mix SIL and AH in same instruction due to REX prefix conflict
; mov sil, ah      ; Invalid encoding
```

[Inference] This encoding limitation reflects the constraint of maintaining backward compatibility while extending the register set within the existing instruction format. The practical impact is minimal since modern compilers rarely generate code using high byte registers.

### Instruction Pointer Extension

The instruction pointer extends to 64 bits as RIP, though not all 64 bits are implemented. Current processors implement 48 or 57 bits of virtual address space, with higher-order bits required to be sign-extensions of the highest implemented bit (canonical address form).

Non-canonical addresses (those not properly sign-extended) cause general protection faults if used. [Inference] This requirement maintains address space organization and prevents accidental access to reserved regions.

The RIP register is not directly accessible for general operations but can be read via specific instructions (LEA with RIP-relative addressing) and is modified by control flow instructions.

### RIP-Relative Addressing

x86-64 introduces RIP-relative addressing, where memory operands are specified as offsets from the current instruction pointer. This addressing mode facilitates position-independent code and efficient global data access:

```nasm
mov rax, [rel global_var]    ; Load from address RIP + offset
lea rdi, [rel string_data]   ; Compute address relative to RIP
call [rel function_ptr]      ; Call through RIP-relative pointer
```

The assembler calculates the offset from the end of the instruction to the target symbol. [Inference] RIP-relative addressing eliminates the need for complex position-independent code sequences used in 32-bit x86, where obtaining the instruction pointer required special call/pop techniques.

### Stack Pointer and Frame Pointer

RSP (stack pointer) and RBP (frame pointer) extend to 64 bits, supporting 64-bit address space for stack operations. The stack grows downward from high addresses toward low addresses, maintaining the same behavior as 32-bit mode.

Stack alignment requirements in 64-bit mode are stricter than 32-bit: the stack must be 16-byte aligned before a CALL instruction. [Inference] This alignment requirement facilitates efficient use of SSE/AVX instructions that benefit from aligned memory access and ensures consistent behavior across all function calls.

```nasm
; Stack frame prologue maintaining 16-byte alignment
push rbp                ; Save frame pointer (8 bytes)
mov rbp, rsp            ; Set up new frame pointer
sub rsp, 32             ; Allocate stack space (maintain 16-byte alignment)
```

### FLAGS Register Extension

The FLAGS register extends to 64 bits as RFLAGS, though most upper bits remain reserved. The architectural flags (CF, PF, AF, ZF, SF, OF, etc.) occupy the same bit positions as 32-bit EFLAGS. Additional mode and system flags reside in the extended region, but general-purpose application code primarily interacts with the lower 32 bits.

**PUSHFQ** and **POPFQ** push and pop the 64-bit RFLAGS register, extending the 32-bit PUSHFD and POPFD instructions:

```nasm
pushfq              ; Push 64-bit RFLAGS
; ... modify flags ...
popfq               ; Restore RFLAGS
```

### Arithmetic Operations

64-bit arithmetic operations use the extended registers with the same instruction mnemonics as 32-bit operations. The REX.W prefix bit indicates 64-bit operand size:

```nasm
add rax, rbx        ; 64-bit addition
sub rsi, 8          ; 64-bit subtraction with immediate
imul rcx, rdx       ; 64-bit signed multiplication
idiv r8             ; 64-bit signed division (RDX:RAX ÷ R8)
```

Extended precision arithmetic uses the same carry flag mechanisms as 32-bit:

```nasm
; 128-bit addition: (RDX:RAX) + (RCX:RBX)
add rax, rbx        ; Add low 64 bits
adc rdx, rcx        ; Add high 64 bits with carry
```

### Immediate Value Encoding

64-bit immediate values present an encoding challenge. Most instructions cannot encode full 64-bit immediates directly. Instead, they use sign-extended 32-bit immediates:

```nasm
mov rax, 0x12345678              ; 32-bit immediate, zero-extended
mov rax, 0xFFFFFFFF80000000      ; 32-bit signed immediate, sign-extended

; For arbitrary 64-bit values, use MOV with 64-bit immediate
movabs rax, 0x123456789ABCDEF0   ; Full 64-bit immediate (10 bytes)
```

**MOVABS** (the 64-bit variant of MOV with absolute addressing) can encode full 64-bit immediate values but produces large instruction sizes (2-byte opcode + REX prefix + 8-byte immediate = 11 bytes).

[Inference] The limitation on immediate sizes reflects the trade-off between instruction encoding space and operand flexibility. Most integer constants fit within 32 bits, making sign-extended immediates sufficient for typical code while keeping instruction size manageable.

