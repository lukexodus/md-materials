## Windows API Basics


The Windows API (Win32 API) provides a comprehensive set of functions for interacting with the Windows operating system. From assembly, these functions are called as standard C functions following Windows calling conventions.

### Windows Calling Conventions

**32-bit (x86) conventions:**

**stdcall** - Primary convention for Win32 API:

- Arguments pushed right-to-left on stack
- Callee cleans up stack
- Return value in EAX (or EAX:EDX for 64-bit values)

**cdecl** - Standard C convention:

- Arguments pushed right-to-left on stack
- Caller cleans up stack
- Return value in EAX

**fastcall** - Optimized convention:

- First two arguments in ECX and EDX
- Remaining arguments on stack right-to-left
- Callee cleans up stack

**64-bit (x64) convention:**

Windows uses a unified calling convention for x64:

- First four integer/pointer arguments: RCX, RDX, R8, R9
- First four floating-point arguments: XMM0, XMM1, XMM2, XMM3
- Additional arguments on stack right-to-left
- Caller allocates 32 bytes of shadow space on stack
- Caller cleans up stack
- Return value in RAX (or XMM0 for floats)
- Volatile registers: RAX, RCX, RDX, R8-R11, XMM0-XMM5
- Non-volatile registers: RBX, RBP, RDI, RSI, RSP, R12-R15, XMM6-XMM15

### Calling Windows API from Assembly (32-bit)

**Example:** MessageBoxA function

```nasm
section .data
    title db 'Hello', 0
    message db 'Hello, World!', 0

section .text
    global _start
    extern _MessageBoxA@16
    extern _ExitProcess@4

_start:
    ; MessageBoxA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType)
    push 0              ; uType = MB_OK
    push title          ; lpCaption
    push message        ; lpText
    push 0              ; hWnd = NULL
    call _MessageBoxA@16
    
    ; ExitProcess(0)
    push 0
    call _ExitProcess@4
```

The `@16` and `@4` suffixes indicate the number of bytes for stack cleanup (stdcall decoration).

### Calling Windows API from Assembly (64-bit)

**Example:** MessageBoxA function (x64)

```nasm
section .data
    title db 'Hello', 0
    message db 'Hello, World!', 0

section .text
    global main
    extern MessageBoxA
    extern ExitProcess

main:
    sub rsp, 40         ; Allocate shadow space (32) + alignment (8)
    
    ; MessageBoxA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType)
    xor rcx, rcx        ; hWnd = NULL
    lea rdx, [message]  ; lpText
    lea r8, [title]     ; lpCaption
    xor r9d, r9d        ; uType = MB_OK
    call MessageBoxA
    
    ; ExitProcess(0)
    xor ecx, ecx
    call ExitProcess
```

### Common Windows API Functions

**File operations:**

```nasm
; CreateFileA(lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes,
;             dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile)
extern _CreateFileA@28

; ReadFile(hFile, lpBuffer, nNumberOfBytesToRead, lpNumberOfBytesRead, lpOverlapped)
extern _ReadFile@20

; WriteFile(hFile, lpBuffer, nNumberOfBytesToWrite, lpNumberOfBytesWritten, lpOverlapped)
extern _WriteFile@20

; CloseHandle(hObject)
extern _CloseHandle@4
```

**Memory operations:**

```nasm
; VirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect)
extern _VirtualAlloc@16

; VirtualFree(lpAddress, dwSize, dwFreeType)
extern _VirtualFree@12
```

**Process/Thread operations:**

```nasm
; CreateThread(lpThreadAttributes, dwStackSize, lpStartAddress,
;              lpParameter, dwCreationFlags, lpThreadId)
extern _CreateThread@24

; GetCurrentProcess()
extern _GetCurrentProcess@0

; TerminateProcess(hProcess, uExitCode)
extern _TerminateProcess@8
```

### Windows API Example - File Operations

```nasm
section .data
    filename db 'test.txt', 0
    buffer times 512 db 0
    bytes_read dd 0
    
section .text
    extern _CreateFileA@28
    extern _ReadFile@20
    extern _CloseHandle@4
    
    ; GENERIC_READ = 0x80000000
    ; OPEN_EXISTING = 3
    ; FILE_ATTRIBUTE_NORMAL = 0x80
    
file_read:
    ; CreateFileA
    push 0              ; hTemplateFile
    push 0x80           ; dwFlagsAndAttributes (FILE_ATTRIBUTE_NORMAL)
    push 3              ; dwCreationDisposition (OPEN_EXISTING)
    push 0              ; lpSecurityAttributes
    push 0              ; dwShareMode
    push 0x80000000     ; dwDesiredAccess (GENERIC_READ)
    push filename       ; lpFileName
    call _CreateFileA@28
    
    cmp eax, -1         ; INVALID_HANDLE_VALUE
    je error
    mov ebx, eax        ; Save handle
    
    ; ReadFile
    push 0              ; lpOverlapped
    push bytes_read     ; lpNumberOfBytesRead
    push 512            ; nNumberOfBytesToRead
    push buffer         ; lpBuffer
    push ebx            ; hFile
    call _ReadFile@20
    
    ; CloseHandle
    push ebx
    call _CloseHandle@4
    
error:
    ret
```

### Windows System Architecture

**Kernel32.dll** - Core Windows API functions (file, memory, process management)

**User32.dll** - User interface functions (windows, messages, input)

**Gdi32.dll** - Graphics Device Interface

**Ntdll.dll** - Native API (lower-level interface to Windows kernel)

### Structured Exception Handling (SEH)

**[Inference]** Windows uses SEH for exception handling, which can be accessed from assembly:

```nasm
section .text
    global _main
    extern _printf

_main:
    push ebp
    mov ebp, esp
    
    ; Install exception handler
    push exception_handler
    push dword [fs:0]      ; Previous handler
    mov [fs:0], esp        ; New handler
    
    ; Code that might fault
    mov eax, [0]           ; Access violation
    
    ; Remove handler
    pop dword [fs:0]
    add esp, 4
    
    mov esp, ebp
    pop ebp
    ret

exception_handler:
    ; Exception handler code
    mov eax, 0             ; EXCEPTION_CONTINUE_SEARCH
    ret
```

