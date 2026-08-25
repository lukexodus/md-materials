## Fundamental Data Types


### Byte Operations

A byte is the smallest addressable unit in x86 architecture, consisting of 8 bits. Byte operations work with 8-bit registers (AL, BL, CL, DL, and their extended counterparts in 64-bit mode like DIL, SIL, R8B-R15B).

**Common byte operations:**

- `MOV AL, 0x42` - Move immediate byte value into AL
- `ADD BL, AL` - Add byte in AL to BL
- `SUB CL, 5` - Subtract immediate value from CL
- `INC DL` - Increment byte register
- `DEC AL` - Decrement byte register
- `CMP AL, 0xFF` - Compare byte value
- `AND BL, 0x0F` - Bitwise AND with byte mask
- `OR AL, 0x80` - Bitwise OR to set high bit
- `XOR CL, CL` - Clear byte register (XOR with itself)

Byte memory operations require size specifiers:

```nasm
mov byte ptr [esi], 0x41      ; Store byte at memory address
mov al, byte ptr [edi + 5]    ; Load byte from memory with offset
add byte ptr [ebx], 1          ; Increment byte in memory
```

### Word Operations

A word in x86 assembly is 16 bits (2 bytes). Word operations use 16-bit registers (AX, BX, CX, DX, SI, DI, BP, SP, and R8W-R15W in 64-bit mode).

**Word operation characteristics:**

- Aligned word access (address divisible by 2) is typically faster
- Unaligned access may cause performance penalties or exceptions on older processors
- Word values are stored in little-endian format (least significant byte at lower address)

```nasm
mov ax, 0x1234                 ; Load immediate word
mov word ptr [ebx], ax         ; Store word to memory
add cx, word ptr [esi]         ; Add word from memory to register
sub dx, 100                    ; Subtract immediate from word register
mul bx                         ; Multiply AX by BX (result in DX:AX)
div cx                         ; Divide DX:AX by CX (quotient in AX, remainder in DX)
```

### Dword Operations

A doubleword (dword) is 32 bits (4 bytes). This is the native size for 32-bit x86 processors and uses 32-bit registers (EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP, and R8D-R15D in 64-bit mode).

**Dword characteristics:**

- Default operand size in 32-bit protected mode
- Most efficient size for 32-bit processors
- Alignment on 4-byte boundaries recommended for performance

```nasm
mov eax, 0x12345678            ; Load immediate dword
mov dword ptr [esi], eax       ; Store dword to memory
add ebx, dword ptr [edi + 8]   ; Add dword from memory with offset
imul ecx, edx                  ; Signed multiply (result in EDX:EAX)
shl eax, 4                     ; Shift left 4 bits
rol ebx, 8                     ; Rotate left 8 bits
bswap eax                      ; Byte swap (reverse endianness)
```

### Qword Operations

A quadword (qword) is 64 bits (8 bytes). In 64-bit mode (x86-64), qword operations use 64-bit registers (RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8-R15).

**Qword characteristics:**

- Native size for 64-bit x86-64 processors
- Can address much larger memory spaces
- Required for pointer operations in 64-bit mode
- Alignment on 8-byte boundaries recommended

```nasm
; 64-bit mode examples
mov rax, 0x123456789ABCDEF0    ; Load immediate qword
mov qword ptr [rsi], rax       ; Store qword to memory
add rbx, qword ptr [rdi]       ; Add qword from memory
imul rcx, rdx                  ; 64-bit multiply
shl rax, 32                    ; Shift left 32 bits
```

**In 32-bit mode, qword operations require paired registers:**

```nasm
; 32-bit mode qword example
mov eax, dword ptr [esi]       ; Load low dword
mov edx, dword ptr [esi + 4]   ; Load high dword
add eax, dword ptr [edi]       ; Add low dwords
adc edx, dword ptr [edi + 4]   ; Add high dwords with carry
```

