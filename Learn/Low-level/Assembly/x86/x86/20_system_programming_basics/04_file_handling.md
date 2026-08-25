## File Handling


File handling in assembly language involves direct interaction with operating system file I/O facilities through system calls or API functions. The specifics vary by operating system, but fundamental concepts remain consistent.

### Linux File Operations (x86-64)

Linux uses system calls for file operations, invoked via the `syscall` instruction on x86-64. System call numbers are placed in RAX, and arguments in RDI, RSI, RDX, R10, R8, R9.

**Common System Call Numbers:**

- sys_read: 0
- sys_write: 1
- sys_open: 2
- sys_close: 3
- sys_lseek: 8
- sys_mmap: 9
- sys_munmap: 11
- sys_stat: 4
- sys_fstat: 5
- sys_creat: 85

**File Descriptors:**

- 0: stdin (standard input)
- 1: stdout (standard output)
- 2: stderr (standard error)

File operations return file descriptors (non-negative integers) on success, or -1 on error.

### Opening Files

**sys_open System Call:**

```asm
; Prototype: int open(const char *pathname, int flags, mode_t mode)
; System call number: 2
; Arguments: rdi = pathname, rsi = flags, rdx = mode
; Returns: file descriptor in rax (or -1 on error)
```

**Open Flags (from fcntl.h):**

- O_RDONLY (0): Read only
- O_WRONLY (1): Write only
- O_RDWR (2): Read and write
- O_CREAT (64 or 0x40): Create if doesn't exist
- O_TRUNC (512 or 0x200): Truncate to zero length
- O_APPEND (1024 or 0x400): Append mode
- O_EXCL (128 or 0x80): Fail if file exists (with O_CREAT)

**Mode Flags (permissions when creating):**

- S_IRUSR (0400): User read permission
- S_IWUSR (0200): User write permission
- S_IXUSR (0100): User execute permission
- S_IRGRP (040): Group read permission
- S_IWGRP (020): Group write permission
- S_IXGRP (010): Group execute permission
- S_IROTH (04): Others read permission
- S_IWOTH (02): Others write permission
- S_IXOTH (01): Others execute permission

**Example 1: Open Existing File for Reading**

```asm
section .data
    filename: db "/tmp/test.txt", 0
    error_msg: db "Failed to open file", 10, 0

section .bss
    fd: resq 1

section .text
    global _start

_start:
    ; open(filename, O_RDONLY, 0)
    mov rax, 2                       ; sys_open
    lea rdi, [filename]              ; pathname
    mov rsi, 0                       ; O_RDONLY
    mov rdx, 0                       ; mode (ignored for existing files)
    syscall
    
    cmp rax, 0
    jl open_error                    ; Negative means error
    
    mov [fd], rax                    ; Save file descriptor
    
    ; ... use file descriptor ...
    
    ; Close file
    mov rax, 3                       ; sys_close
    mov rdi, [fd]
    syscall
    
    ; Exit success
    mov rax, 60                      ; sys_exit
    xor rdi, rdi
    syscall

open_error:
    ; Print error message
    mov rax, 1                       ; sys_write
    mov rdi, 2                       ; stderr
    lea rsi, [error_msg]
    mov rdx, 21                      ; message length
    syscall
    
    ; Exit with error code
    mov rax, 60
    mov rdi, 1
    syscall
```

**Example 2: Create New File with Permissions**

```asm
section .data
    filename: db "output.dat", 0

section .bss
    fd: resq 1

section .text
    global _start

_start:
    ; open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644)
    mov rax, 2                       ; sys_open
    lea rdi, [filename]
    mov rsi, 0x241                   ; O_WRONLY(1) | O_CREAT(64) | O_TRUNC(512)
    mov rdx, 0644o                   ; rw-r--r--
    syscall
    
    mov [fd], rax
    
    ; ... write to file ...
    
    ; Close file
    mov rax, 3
    mov rdi, [fd]
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

### Reading from Files

**sys_read System Call:**

```asm
; Prototype: ssize_t read(int fd, void *buf, size_t count)
; System call number: 0
; Arguments: rdi = fd, rsi = buffer, rdx = count
; Returns: number of bytes read in rax (0 = EOF, -1 = error)
```

**Example 3: Read File Contents**

```asm
section .data
    filename: db "input.txt", 0

section .bss
    fd: resq 1
    buffer: resb 4096                ; 4KB buffer
    bytes_read: resq 1

section .text
    global _start

_start:
    ; Open file
    mov rax, 2
    lea rdi, [filename]
    mov rsi, 0                       ; O_RDONLY
    mov rdx, 0
    syscall
    
    cmp rax, 0
    jl error_exit
    mov [fd], rax

read_loop:
    ; Read from file
    mov rax, 0                       ; sys_read
    mov rdi, [fd]
    lea rsi, [buffer]
    mov rdx, 4096                    ; Read up to 4KB
    syscall
    
    cmp rax, 0
    jl error_exit                    ; Error
    je end_of_file                   ; EOF reached
    
    mov [bytes_read], rax
    
    ; Write to stdout
    mov rax, 1                       ; sys_write
    mov rdi, 1                       ; stdout
    lea rsi, [buffer]
    mov rdx, [bytes_read]
    syscall
    
    jmp read_loop

end_of_file:
    ; Close file
    mov rax, 3
    mov rdi, [fd]
    syscall
    
    ; Exit success
    mov rax, 60
    xor rdi, rdi
    syscall

error_exit:
    mov rax, 60
    mov rdi, 1
    syscall
```

**Output:** Contents of input.txt printed to stdout

### Writing to Files

**sys_write System Call:**

```asm
; Prototype: ssize_t write(int fd, const void *buf, size_t count)
; System call number: 1
; Arguments: rdi = fd, rsi = buffer, rdx = count
; Returns: number of bytes written in rax (-1 = error)
```

**Example 4: Write Data to File**

```asm
section .data
    filename: db "output.txt", 0
    message: db "Hello, File System!", 10
    msg_len equ $ - message

section .bss
    fd: resq 1

section .text
    global _start

_start:
    ; Create/open file for writing
    mov rax, 2
    lea rdi, [filename]
    mov rsi, 0x241                   ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 0644o
    syscall
    
    cmp rax, 0
    jl error_exit
    mov [fd], rax
    
    ; Write message to file
    mov rax, 1                       ; sys_write
    mov rdi, [fd]
    lea rsi, [message]
    mov rdx, msg_len
    syscall
    
    cmp rax, 0
    jl error_exit
    
    ; Close file
    mov rax, 3
    mov rdi, [fd]
    syscall
    
    ; Exit success
    mov rax, 60
    xor rdi, rdi
    syscall

error_exit:
    mov rax, 60
    mov rdi, 1
    syscall
```

**Output:** File "output.txt" created with content "Hello, File System!\n"

### File Positioning (Seeking)

**sys_lseek System Call:**

```asm
; Prototype: off_t lseek(int fd, off_t offset, int whence)
; System call number: 8
; Arguments: rdi = fd, rsi = offset, rdx = whence
; Returns: new file position in rax (-1 = error)
```

**Whence values:**

- SEEK_SET (0): Offset from beginning
- SEEK_CUR (1): Offset from current position
- SEEK_END (2): Offset from end of file

**Example 5: Seek and Read**

```asm
section .data
    filename: db "data.bin", 0

section .bss
    fd: resq 1
    buffer: resb 100

section .text
    global _start

_start:
    ; Open file
    mov rax, 2
    lea rdi, [filename]
    mov rsi, 0                       ; O_RDONLY
    mov rdx, 0
    syscall
    mov [fd], rax
    
    ; Seek to byte 1000
    mov rax, 8                       ; sys_lseek
    mov rdi, [fd]
    mov rsi, 1000                    ; Offset
    mov rdx, 0                       ; SEEK_SET
    syscall
    
    ; Read 100 bytes from position 1000
    mov rax, 0                       ; sys_read
    mov rdi, [fd]
    lea rsi, [buffer]
    mov rdx, 100
    syscall
    
    ; Close file
    mov rax, 3
    mov rdi, [fd]
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

**Example 6: Get File Size Using Seek**

```asm
section .data
    filename: db "test.dat", 0

section .bss
    fd: resq 1
    filesize: resq 1

section .text
    global _start

_start:
    ; Open file
    mov rax, 2
    lea rdi, [filename]
    mov rsi, 0
    mov rdx, 0
    syscall
    mov [fd], rax
    
    ; Seek to end
    mov rax, 8                       ; sys_lseek
    mov rdi, [fd]
    mov rsi, 0                       ; Offset 0
    mov rdx, 2                       ; SEEK_END
    syscall
    
    mov [filesize], rax              ; File size now in rax
    
    ; Seek back to beginning
    mov rax, 8
    mov rdi, [fd]
    mov rsi, 0
    mov rdx, 0                       ; SEEK_SET
    syscall
    
    ; Close file
    mov rax, 3
    mov rdi, [fd]
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

### File Metadata (stat)

**sys_stat/sys_fstat System Calls:**

```asm
; Prototype: int stat(const char *pathname, struct stat *statbuf)
; System call number: 4
; Prototype: int fstat(int fd, struct stat *statbuf)
; System call number: 5
```

**struct stat structure (simplified, x86-64 Linux):**

```
Offset | Size | Field
0      | 8    | st_dev (device ID)
8      | 8    | st_ino (inode number)
16     | 8    | st_nlink (number of hard links)
24     | 4    | st_mode (file type and mode)
28     | 4    | st_uid (user ID)
32     | 4    | st_gid (group ID)
36     | 4    | padding
40     | 8    | st_rdev (device ID if special file)
48     | 8    | st_size (total size in bytes)
56     | 8    | st_blksize (block size for I/O)
64     | 8    | st_blocks (number of 512B blocks)
72     | 16   | st_atime (last access time)
88     | 16   | st_mtime (last modification time)
104    | 16   | st_ctime (last status change time)
```

**Example 7: Get File Size Using stat**

```asm
section .data
    filename: db "test.dat", 0

section .bss
    statbuf: resb 144                ; struct stat buffer
    filesize: resq 1

section .text
    global _start

_start:
    ; stat(filename, &statbuf)
    mov rax, 4                       ; sys_stat
    lea rdi, [filename]
    lea rsi, [statbuf]
    syscall
    
    cmp rax, 0
    jl error_exit
    
    ; Extract file size (offset 48)
    mov rax, [statbuf + 48]
    mov [filesize], rax
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

error_exit:
    mov rax, 60
    mov rdi, 1
    syscall
```

### Memory-Mapped Files

Memory-mapped I/O allows treating file contents as memory, enabling efficient random access and reduced system call overhead.

**sys_mmap System Call:**

```asm
; Prototype: void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset)
; System call number: 9
; Arguments: rdi = addr, rsi = length, rdx = prot, r10 = flags, r8 = fd, r9 = offset
; Returns: pointer to mapped area in rax (or -1 on error)
```

**Protection flags (prot):**

- PROT_READ (1): Pages may be read
- PROT_WRITE (2): Pages may be written
- PROT_EXEC (4): Pages may be executed
- PROT_NONE (0): Pages may not be accessed

**Mapping flags:**

- MAP_SHARED (1): Share mapping with other processes
- MAP_PRIVATE (2): Create copy-on-write mapping
- MAP_ANONYMOUS (32 or 0x20): No file backing (for pure memory allocation)
- MAP_FIXED (16): Place mapping at exact address

**Example 8: Memory-Mapped File Reading**

```asm
section .data
    filename: db "data.bin", 0

section .bss
    fd: resq 1
    mapped_addr: resq 1
    filesize: resq 1
    statbuf: resb 144

section .text
    global _start

_start:
    ; Open file
    mov rax, 2
    lea rdi, [filename]
    mov rsi, 0                       ; O_RDONLY
    mov rdx, 0
    syscall
    mov [fd], rax
    
    ; Get file size using fstat
    mov rax, 5                       ; sys_fstat
    mov rdi, [fd]
    lea rsi, [statbuf]
    syscall
    
    mov rax, [statbuf + 48]          ; Extract st_size
    mov [filesize], rax
    
    ; Map file into memory
    mov rax, 9                       ; sys_mmap
    xor rdi, rdi                     ; Let kernel choose address
    mov rsi, [filesize]              ; Map entire file
    mov rdx, 1                       ; PROT_READ
    mov r10, 1                       ; MAP_SHARED
    mov r8, [fd]                     ; File descriptor
    xor r9, r9                       ; Offset 0
    syscall
    
    cmp rax, -1
    je error_exit
    mov [mapped_addr], rax
    
    ; Now file contents accessible via [mapped_addr]
    ; Example: print first byte
    mov rsi, [mapped_addr]
    movzx rax, byte [rsi]            ; Load first byte
    
    ; Unmap memory
    mov rax, 11                      ; sys_munmap
    mov rdi, [mapped_addr]
    mov rsi, [filesize]
    syscall
    
    ; Close file
    mov rax, 3
    mov rdi, [fd]
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

error_exit:
    mov rax, 60
    mov rdi, 1
    syscall
```

**Example 9: Copy File Using mmap**

```asm
section .data
    src_file: db "source.dat", 0
    dst_file: db "destination.dat", 0

section .bss
    src_fd: resq 1
    dst_fd: resq 1
    src_addr: resq 1
    dst_addr: resq 1
    filesize: resq 1
    statbuf: resb 144

section .text
    global _start

_start:
    ; Open source file
    mov rax, 2
    lea rdi, [src_file]
    mov rsi, 0                       ; O_RDONLY
    mov rdx, 0
    syscall
    mov [src_fd], rax
    
    ; Get source file size
    mov rax, 5                       ; sys_fstat
    mov rdi, [src_fd]
    lea rsi, [statbuf]
    syscall
    mov rax, [statbuf + 48]
    mov [filesize], rax
    
    ; Create/open destination file
    mov rax, 2
    lea rdi, [dst_file]
    mov rsi, 0x241                   ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 0644o
    syscall
    mov [dst_fd], rax
    
    ; Truncate destination to source size
    mov rax, 77                      ; sys_ftruncate
    mov rdi, [dst_fd]
    mov rsi, [filesize]
    syscall
    
    ; Map source file (read-only)
    mov rax, 9
    xor rdi, rdi
    mov rsi, [filesize]
    mov rdx, 1                       ; PROT_READ
    mov r10, 1                       ; MAP_SHARED
    mov r8, [src_fd]
    xor r9, r9
    syscall
    mov [src_addr], rax
    
    ; Map destination file (read-write)
    mov rax, 9
    xor rdi, rdi
    mov rsi, [filesize]
    mov rdx, 3                       ; PROT_READ | PROT_WRITE
    mov r10, 1                       ; MAP_SHARED
    mov r8, [dst_fd]
    xor r9, r9
    syscall
    mov [dst_addr], rax
    
    ; Copy memory (simplified - real implementation would loop)
    mov rsi, [src_addr]
    mov rdi, [dst_addr]
    mov rcx, [filesize]
    rep movsb                        ; Copy byte by byte
    
    ; Unmap both files
    mov rax, 11
    mov rdi, [src_addr]
    mov rsi, [filesize]
    syscall
    
    mov rax, 11
    mov rdi, [dst_addr]
    mov rsi, [filesize]
    syscall
    
    ; Close files
    mov rax, 3
    mov rdi, [src_fd]
    syscall
    
    mov rax, 3
    mov rdi, [dst_fd]
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

