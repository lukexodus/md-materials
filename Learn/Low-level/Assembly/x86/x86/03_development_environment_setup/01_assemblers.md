## Assemblers


An assembler is a program that translates assembly language source code into machine code (object files). Different assemblers use different syntax conventions and support different features.

### NASM (Netwide Assembler)

NASM is a popular, free, open-source assembler that supports Intel syntax and runs on multiple platforms including Windows, Linux, and macOS.

**Key Features:**

- Intel syntax (destination, source operand order)
- Macro support with powerful preprocessing capabilities
- Multiple output formats (ELF, COFF, Mach-O, binary)
- Cross-platform compatibility
- Extensive documentation
- Simple, clean syntax

**Syntax Characteristics:**

NASM uses Intel syntax where the destination operand comes first:

```nasm
mov eax, 5          ; Move 5 into EAX (destination, source)
add ebx, eax        ; Add EAX to EBX
```

**Directives:**

```nasm
section .data       ; Data section
section .bss        ; Uninitialized data section
section .text       ; Code section
global _start       ; Make symbol visible to linker
extern printf       ; Declare external symbol
db 10               ; Define byte
dw 1000             ; Define word (2 bytes)
dd 100000           ; Define double word (4 bytes)
dq 10000000         ; Define quad word (8 bytes)
resb 64             ; Reserve 64 bytes
```

**Example:**

```nasm
section .data
    msg db 'Hello, World!', 0x0A
    len equ $ - msg

section .text
    global _start

_start:
    mov eax, 4          ; sys_write system call
    mov ebx, 1          ; stdout file descriptor
    mov ecx, msg        ; pointer to message
    mov edx, len        ; message length
    int 0x80            ; invoke system call
    
    mov eax, 1          ; sys_exit system call
    xor ebx, ebx        ; exit code 0
    int 0x80
```

**Compilation Commands:**

```bash
# Linux 32-bit
nasm -f elf32 program.asm -o program.o
ld -m elf_i386 program.o -o program

# Linux 64-bit
nasm -f elf64 program.asm -o program.o
ld program.o -o program

# Windows 32-bit
nasm -f win32 program.asm -o program.obj

# Windows 64-bit
nasm -f win64 program.asm -o program.obj

# Raw binary
nasm -f bin bootloader.asm -o bootloader.bin
```

**Macros in NASM:**

```nasm
%macro print_string 2    ; Macro with 2 parameters
    mov eax, 4
    mov ebx, 1
    mov ecx, %1          ; First parameter (string address)
    mov edx, %2          ; Second parameter (length)
    int 0x80
%endmacro

; Usage
print_string msg, len
```

### MASM (Microsoft Macro Assembler)

MASM is Microsoft's assembler for x86 and x86-64 architectures, primarily used on Windows platforms. It's included with Visual Studio.

**Key Features:**

- Intel syntax
- High-level constructs (IF, WHILE, PROC)
- Strong integration with Microsoft development tools
- Support for Windows calling conventions
- Advanced macro capabilities
- Type checking for data

**Syntax Characteristics:**

MASM uses directives that differ from NASM:

```asm
.386                    ; Target 386 processor
.model flat, stdcall    ; Memory model and calling convention
.stack 4096             ; Stack size

.data                   ; Data section
msg BYTE "Hello", 0     ; Define byte array

.code                   ; Code section
main PROC               ; Procedure definition
    ; code here
main ENDP               ; End procedure
END main                ; Program entry point
```

**High-Level Constructs:**

```asm
.IF eax > 5
    mov ebx, 1
.ELSEIF eax == 5
    mov ebx, 2
.ELSE
    mov ebx, 3
.ENDIF

.WHILE eax < 10
    inc eax
.ENDW
```

**Example:**

```asm
.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib

.data
    msg db "Hello, World!", 0

.code
start:
    push offset msg
    call StdOut
    
    push 0
    call ExitProcess
    
end start
```

**Compilation Commands:**

```cmd
REM Using ML.exe (32-bit)
ml /c /coff program.asm
link /subsystem:console program.obj

REM Using ML64.exe (64-bit)
ml64 /c program.asm
link /subsystem:console program.obj
```

**Procedure Definition:**

```asm
AddNumbers PROC uses ebx ecx, num1:DWORD, num2:DWORD
    mov eax, num1
    add eax, num2
    ret
AddNumbers ENDP

; Usage
push 10
push 20
call AddNumbers
```

### GAS (GNU Assembler)

GAS is part of the GNU Binutils package and is the default assembler for GCC. It primarily uses AT&T syntax but can also support Intel syntax.

**Key Features:**

- Part of the GNU toolchain
- AT&T syntax by default (can use Intel syntax with directive)
- Integrated with GCC compiler
- Cross-platform support
- Support for multiple architectures

**AT&T Syntax Characteristics:**

AT&T syntax differs significantly from Intel syntax:

- Source operand comes first (opposite of Intel)
- Register names prefixed with %
- Immediate values prefixed with $
- Memory operand syntax: displacement(base, index, scale)
- Size suffixes on instructions (b=byte, w=word, l=long, q=quad)

**Example (AT&T Syntax):**

```gas
.section .data
msg:
    .ascii "Hello, World!\n"
    len = . - msg

.section .text
.globl _start

_start:
    movl $4, %eax        # sys_write (note: source, destination)
    movl $1, %ebx        # stdout
    movl $msg, %ecx      # message address
    movl $len, %edx      # message length
    int $0x80
    
    movl $1, %eax        # sys_exit
    xorl %ebx, %ebx      # exit code 0
    int $0x80
```

**Intel Syntax in GAS:**

```gas
.intel_syntax noprefix

.section .data
msg:
    .ascii "Hello, World!\n"

.section .text
.globl _start

_start:
    mov eax, 4           # Intel syntax enabled
    mov ebx, 1
    mov ecx, OFFSET msg
    int 0x80
```

**Size Suffixes:**

```gas
movb $10, %al       # Move byte
movw $1000, %ax     # Move word
movl $100000, %eax  # Move long (32-bit)
movq $value, %rax   # Move quad (64-bit)
```

**Memory Addressing:**

```gas
# AT&T: displacement(base, index, scale)
movl 8(%ebp), %eax              # [ebp + 8]
movl array(,%ebx,4), %eax       # array[ebx * 4]
movl 4(%esp,%esi,2), %eax       # [esp + esi * 2 + 4]
```

**Compilation Commands:**

```bash
# Assemble only
as program.s -o program.o

# With 32-bit mode
as --32 program.s -o program.o

# With 64-bit mode
as --64 program.s -o program.o

# Link
ld program.o -o program

# Using GCC (compiles and links)
gcc program.s -o program
```

### FASM (Flat Assembler)

FASM is a fast, self-compiling assembler written entirely in assembly language. It's known for its speed and ability to assemble itself.

**Key Features:**

- Intel syntax
- Self-compiling (bootstrap capability)
- Very fast assembly speed
- Macro preprocessing
- Multiple output formats
- Single-pass assembler with multi-pass optimization
- Can generate executable directly without separate linker

**Syntax Characteristics:**

FASM syntax is similar to NASM but with some differences:

```fasm
format PE console       ; Output format (PE executable)
entry start             ; Entry point

section '.data' data readable writeable
    msg db 'Hello, World!', 0x0A
    len = $ - msg

section '.code' code readable executable
    start:
        push msg
        call [printf]
        
        push 0
        call [ExitProcess]

section '.idata' import data readable
    library kernel32, 'kernel32.dll', \
            msvcrt, 'msvcrt.dll'
            
    import kernel32, ExitProcess, 'ExitProcess'
    import msvcrt, printf, 'printf'
```

**Direct Executable Generation:**

```fasm
format ELF64 executable 3
entry start

segment readable executable

start:
    mov eax, 1          ; sys_write
    mov edi, 1          ; stdout
    mov rsi, msg        ; message
    mov rdx, msg_len    ; length
    syscall
    
    mov eax, 60         ; sys_exit
    xor edi, edi
    syscall

segment readable writeable

msg db 'Hello, World!', 0x0A
msg_len = $ - msg
```

**Macros:**

```fasm
macro print string, length {
    mov eax, 4
    mov ebx, 1
    mov ecx, string
    mov edx, length
    int 0x80
}

; Usage
print msg, len
```

**Compilation Commands:**

```bash
# Assemble to executable directly
fasm program.asm

# Assemble to object file
fasm program.asm program.o

# Windows
fasm program.asm program.exe
```

**Structures in FASM:**

```fasm
struct POINT
    x dd ?
    y dd ?
ends

; Usage
point POINT
mov [point.x], 100
mov [point.y], 200
```

### Assembler Comparison

|Feature|NASM|MASM|GAS|FASM|
|---|---|---|---|---|
|Syntax|Intel|Intel|AT&T (Intel optional)|Intel|
|Platform|Cross-platform|Windows|Cross-platform|Cross-platform|
|License|BSD|Proprietary|GPL|Free (custom)|
|High-level constructs|Limited|Yes|No|Limited|
|Macro system|Good|Excellent|Basic|Good|
|Self-hosting|No|No|No|Yes|
|Direct executable|No|No|No|Yes|

